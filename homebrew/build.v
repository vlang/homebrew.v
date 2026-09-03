module homebrew

import brew_runtime
import homebrew.extend as pathname_extension
import os

// Translated from Homebrew/brew `build.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct BuildArgs {
pub:
	ignore_dependencies bool
	env                 string
	cc                  string
	build_bottle        bool
	bottle_arch         string
	debug_symbols       bool
	debug               bool
	keep_tmp            bool
	interactive         bool
	git                 bool
	verbose             bool
}

pub type BuildFormulaHook = fn (formula Formula, mut execution BuildInstallExecution) !

pub type BuildPatchHook = fn (formula Formula, mode string, mut execution BuildInstallExecution) !

// BuildContext supplies the formula loader and the requirement collection that
// are implicit global collaborators in build.rb. Keys may be either dependency
// names or fully-qualified formula names.
pub struct BuildContext {
pub:
	formulae                 map[string]Formula
	dependencies             map[string][]Dependency
	requirements             map[string][]Requirement
	temporary_directory      string
	logs_directory           string
	superenv                 bool
	disable_debrew           bool
	compiler                 string
	update_head_version_hook ?BuildFormulaHook
	patch_hook               ?BuildPatchHook
	install_hook             ?BuildFormulaHook
	interactive_shell_hook   ?BuildFormulaHook
}

pub struct BuildInstallExecution {
pub mut:
	environment                   map[string]string
	events                        []string
	output                        []string
	superenv_deps                 []string
	superenv_keg_only_deps        []string
	superenv_run_time_deps        []string
	requirement_environment_calls int
	requirement_env_proc_calls    int
}

pub struct BuildInstallResult {
pub:
	formula_dependencies  []Formula
	keg_only_dependencies []Formula
	run_time_dependencies []Formula
	environment           map[string]string
	events                []string
	output                []string
	stdlibs               []string
	receipt_path          string
}

@[heap]
pub struct Build {
pub mut:
	formula Formula
	deps    []Dependency
	reqs    []Requirement
	args    BuildArgs
	context BuildContext
}

fn build_formula_key(formula Formula) string {
	return if formula.full_name() != '' { formula.full_name() } else { formula.name() }
}

fn (build &Build) configured_dependencies(formula Formula) []Dependency {
	for key in [build_formula_key(formula), formula.name()] {
		if dependencies := build.context.dependencies[key] {
			return dependencies.clone()
		}
	}
	return formula.deps()
}

fn (build &Build) configured_requirements(formula Formula) []Requirement {
	for key in [build_formula_key(formula), formula.name()] {
		if requirements := build.context.requirements[key] {
			return requirements.clone()
		}
	}
	return []Requirement{}
}

fn (build &Build) formula_for_dependency(dependency Dependency) !Formula {
	if formula := build.context.formulae[dependency.name] {
		return formula
	}
	for _, formula in build.context.formulae {
		if dependency.name in [formula.name(), formula.full_name()] {
			return formula
		}
	}
	return error('Formula unavailable: ${dependency.name}')
}

fn build_requirement_has_tag(requirement Requirement, name string) bool {
	return requirement.tags.any(it.kind == .symbol && it.value == name)
}

fn build_requirement_prune_from_option(requirement Requirement, options BuildOptions) bool {
	if !requirement.optional() && !requirement.recommended() {
		return false
	}
	return options.without_dependable(requirement)
}

fn build_add_requirement(mut requirements []Requirement, candidate Requirement) {
	if !requirements.any(it.equals(candidate)) {
		requirements << candidate
	}
}

fn (build &Build) expand_dependencies_from(dependent Formula, filtered bool,
	mut stack map[string]bool, mut expanded []Dependency) ! {
	dependent_key := build_formula_key(dependent)
	if stack[dependent_key] {
		return
	}
	stack[dependent_key] = true
	defer {
		stack.delete(dependent_key)
	}
	for original_dependency in build.configured_dependencies(dependent) {
		if filtered {
			effective := build.effective_build_options_for(dependent)
			if original_dependency.prune_from_option(effective)
				|| original_dependency.prune_if_build_and_not_formula(dependent.full_name(), build.formula.full_name())
				|| (original_dependency.test() && !original_dependency.build())
				|| original_dependency.implicit() {
				continue
			}
			if original_dependency.build() {
				expanded << original_dependency
				continue
			}
		} else if (original_dependency.optional() || original_dependency.recommended())
			&& original_dependency.prune_from_option(dependent.build) {
			continue
		}

		dependency_formula := build.formula_for_dependency(original_dependency)!
		if !stack[original_dependency.name] && !stack[build_formula_key(dependency_formula)] {
			build.expand_dependencies_from(dependency_formula, filtered, mut stack, mut expanded)!
		}
		expanded << original_dependency.duplicate_with_formula_name(dependency_formula.full_name())
	}
}

pub fn new_build(formula Formula, supplied_options Options, args BuildArgs,
	context BuildContext) !&Build {
	mut configured_formula := formula
	configured_formula.build = new_build_options(supplied_options, configured_formula.options())
	mut build := &Build{
		formula: configured_formula
		args: args
		context: context
	}
	if !args.ignore_dependencies {
		build.deps = build.expand_deps()!
		build.reqs = build.expand_reqs()!
	}
	return build
}

pub fn (build &Build) effective_build_options_for(dependent Formula) BuildOptions {
	build_options := dependent.build.used_options()
	installed_options := tab_for_formula(dependent).used_options()
	return new_build_options(build_options.union(installed_options), dependent.options())
}

pub fn (build &Build) expand_deps() ![]Dependency {
	mut expanded := []Dependency{}
	mut stack := map[string]bool{}
	build.expand_dependencies_from(build.formula, true, mut stack, mut expanded)!
	return merge_repeated_dependencies(expanded)
}

pub fn (build &Build) expand_reqs() ![]Requirement {
	mut recursive_dependencies := []Dependency{}
	mut stack := map[string]bool{}
	build.expand_dependencies_from(build.formula, false, mut stack, mut recursive_dependencies)!
	recursive_dependencies = merge_repeated_dependencies(recursive_dependencies)
	mut formulae := [build.formula]
	for dependency in recursive_dependencies {
		formulae << build.formula_for_dependency(dependency)!
	}
	mut requirements := []Requirement{}
	for dependent in formulae {
		effective := build.effective_build_options_for(dependent)
		for requirement in build.configured_requirements(dependent) {
			if build_requirement_prune_from_option(requirement, effective)
				|| (requirement.build() && dependent.full_name() != build.formula.full_name())
				|| build_requirement_has_tag(requirement, 'test') {
				continue
			}
			build_add_requirement(mut requirements, requirement)
		}
	}
	return requirements
}

fn build_prepend_path(mut environment map[string]string, key string, value string) {
	if value == '' {
		return
	}
	current := environment[key] or { '' }
	environment[key] = if current == '' { value } else { '${value}:${current}' }
}

fn build_prepend_flag(mut environment map[string]string, key string, value string) {
	current := environment[key] or { '' }
	environment[key] = if current == '' { value } else { '${value} ${current}' }
}

fn build_optional_string(value string) ?string {
	if value == '' {
		return none
	}
	return value
}

fn build_logs_directory(build &Build) string {
	if build.context.logs_directory != '' {
		return build.context.logs_directory
	}
	return os.join_path(build.formula.prefix_root, 'var', 'homebrew', 'logs', build.formula.full_name())
}

fn build_git_command(directory string, arguments string) ! {
	if directory == '' || !os.is_dir(directory) {
		return error('build path is not a directory: ${directory}')
	}
	result := os.execute('git -C ${os.quoted_path(directory)} ${arguments}')
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
}

fn build_has_prefix_metafile(prefix string) bool {
	for child in os.ls(prefix) or { return false } {
		path := os.join_path(prefix, child)
		if os.is_file(path) && is_metafile_copied(child) {
			return true
		}
	}
	return false
}

pub fn (build &Build) install(mut execution BuildInstallExecution) !BuildInstallResult {
	mut formula_dependencies := []Formula{}
	mut keg_only_dependencies := []Formula{}
	mut run_time_dependencies := []Formula{}
	for dependency in build.deps {
		formula := build.formula_for_dependency(dependency)!
		formula_dependencies << formula
		if formula.keg_only() {
			keg_only_dependencies << formula
		}
		if !dependency.build() {
			run_time_dependencies << formula
		}
	}
	for dependency_formula in formula_dependencies {
		if !os.is_dir(dependency_formula.opt_prefix()) {
			build.fixopt(dependency_formula)!
		}
	}

	execution.events << 'activate_extensions:${build.args.env}'
	if build.context.superenv {
		execution.superenv_keg_only_deps = keg_only_dependencies.map(it.full_name())
		execution.superenv_deps = formula_dependencies.map(it.full_name())
		execution.superenv_run_time_deps = run_time_dependencies.map(it.full_name())
	}
	execution.events << 'setup_build_environment'
	mut requirement_execution := RequirementExecution{
		environment: execution.environment.clone()
		prefix: build.formula.prefix_root
		cellar: build.formula.cellar
	}
	for source_requirement in build.reqs {
		mut requirement := source_requirement
		requirement.modify_build_environment(mut requirement_execution, RequirementEvaluationOptions{
			env: build_optional_string(build.args.env)
			cc: build_optional_string(build.args.cc)
			build_bottle: build.args.build_bottle
			bottle_arch: build_optional_string(build.args.bottle_arch)
		})
	}
	execution.environment = requirement_execution.environment.clone()
	execution.requirement_environment_calls = requirement_execution.build_environment_calls
	execution.requirement_env_proc_calls = requirement_execution.env_proc_calls

	if !build.context.superenv {
		for dependency_formula in keg_only_dependencies {
			build_prepend_path(mut execution.environment, 'PATH', os.join_path(dependency_formula.opt_prefix(), 'bin'))
			build_prepend_path(mut execution.environment, 'PKG_CONFIG_PATH', os.join_path(dependency_formula.opt_prefix(), 'lib', 'pkgconfig'))
			build_prepend_path(mut execution.environment, 'PKG_CONFIG_PATH', os.join_path(dependency_formula.opt_prefix(), 'share', 'pkgconfig'))
			build_prepend_path(mut execution.environment, 'ACLOCAL_PATH', os.join_path(dependency_formula.opt_prefix(), 'share', 'aclocal'))
			build_prepend_path(mut execution.environment, 'CMAKE_PREFIX_PATH', dependency_formula.opt_prefix())
			opt_lib := os.join_path(dependency_formula.opt_prefix(), 'lib')
			if os.is_dir(opt_lib) {
				build_prepend_flag(mut execution.environment, 'LDFLAGS', '-L${opt_lib}')
			}
			opt_include := os.join_path(dependency_formula.opt_prefix(), 'include')
			if os.is_dir(opt_include) {
				build_prepend_flag(mut execution.environment, 'CPPFLAGS', '-I${opt_include}')
			}
		}
	}

	temporary_directory := if build.context.temporary_directory != '' {
		build.context.temporary_directory
	} else {
		os.temp_dir()
	}
	for name in ['TMPDIR', 'TEMP', 'TMP'] {
		execution.environment[name] = temporary_directory
	}
	if build.args.debug && !build.context.disable_debrew {
		execution.events << 'extend_debrew'
	}
	if hook := build.context.update_head_version_hook {
		hook(build.formula, mut execution)!
	}
	execution.events << 'update_head_version'
	execution.events << 'brew:fetch=false,keep_tmp=${build.args.keep_tmp},debug_symbols=${build.args.debug_symbols},interactive=${build.args.interactive}'
	execution.environment['HOMEBREW_FORMULA_PREFIX'] = build.formula.prefix()
	execution.environment['HOMEBREW_FORMULA_BUILDPATH'] = build.formula.buildpath
	execution.environment['SOURCE_DATE_EPOCH'] = build.formula.source_modified_time.str()
	execution.environment['TZ'] = 'UTC0'

	if build.args.git {
		if hook := build.context.patch_hook {
			hook(build.formula, 'selective-non-data', mut execution)!
		}
		execution.events << 'selective_patch:false'
		build_git_command(build.formula.buildpath, 'init')!
		build_git_command(build.formula.buildpath, 'add -A')!
		if hook := build.context.patch_hook {
			hook(build.formula, 'selective-data', mut execution)!
		}
		execution.events << 'selective_patch:true'
	} else {
		if hook := build.context.patch_hook {
			hook(build.formula, 'all', mut execution)!
		}
		execution.events << 'patch'
	}

	if build.args.interactive {
		execution.output << 'Entering interactive mode...'
		execution.output << 'Type `exit` to return and finalize the installation.\nInstall to this prefix: ${build.formula.prefix()}'
		if build.args.git {
			execution.output << 'This directory is now a Git repository. Make your changes and then use:\n  git diff | pbcopy\nto copy the diff to the clipboard.'
		}
		if hook := build.context.interactive_shell_hook {
			hook(build.formula, mut execution)!
		}
		execution.events << 'interactive_shell'
		return BuildInstallResult{
			formula_dependencies: formula_dependencies
			keg_only_dependencies: keg_only_dependencies
			run_time_dependencies: run_time_dependencies
			environment: execution.environment.clone()
			events: execution.events.clone()
			output: execution.output.clone()
		}
	}

	formula_prefix := build.formula.prefix()
	logs := build_logs_directory(build)
	os.mkdir_all(formula_prefix)!
	os.mkdir_all(logs)!
	mut used_options := build.formula.build.used_options().as_flags()
	used_options.sort()
	options_line := '${build.formula.full_name()} ${used_options.join(' ')}'.trim_space()
	os.write_file(os.join_path(logs, '00.options.out'), options_line)!
	if hook := build.context.install_hook {
		hook(build.formula, mut execution)!
	}
	execution.events << 'formula_install'
	stdlibs := build.detect_stdlibs()!
	stdlib := if stdlibs.len > 0 { stdlibs[0] } else { '' }
	tab := tab_create_for_formula(build.formula, run_time_dependencies, build.context.compiler, stdlib)
	tab.write()!
	execution.events << 'tab_write'
	if build.formula.buildpath != '' && os.is_dir(build.formula.buildpath) {
		pathname_extension.pathname_install_metafiles(formula_prefix, build.formula.buildpath, is_metafile_copied)!
	}
	libexec := os.join_path(formula_prefix, 'libexec')
	if os.is_dir(libexec) && !build_has_prefix_metafile(formula_prefix) {
		pathname_extension.pathname_install_metafiles(formula_prefix, libexec, is_metafile_copied)!
	}
	build.normalize_pod2man_outputs(build.formula)!
	execution.events << 'normalize_pod2man_outputs'
	return BuildInstallResult{
		formula_dependencies: formula_dependencies
		keg_only_dependencies: keg_only_dependencies
		run_time_dependencies: run_time_dependencies
		environment: execution.environment.clone()
		events: execution.events.clone()
		output: execution.output.clone()
		stdlibs: stdlibs
		receipt_path: os.join_path(formula_prefix, tab_filename)
	}
}

fn build_executable_path(keg Keg, path string) bool {
	relative := path.trim_string_left(keg.path).trim_left(os.path_separator)
	first := relative.split(os.path_separator)[0]
	base := os.base(path)
	is_library := base.contains('.so') || base.ends_with('.dylib') || base.ends_with('.a')
	return first in ['bin', 'sbin'] || (os.is_executable(path) && !is_library)
}

fn build_detect_cxx_stdlibs(keg Keg) []string {
	mut libcxx := false
	mut libstdcxx := false
	for path in keg.find() {
		if !os.is_file(path) || build_executable_path(keg, path) {
			continue
		}
		content := os.read_bytes(path) or { continue }.bytestr()
		if content.contains('libc++.so') || content.contains('libc++.dylib')
			|| content.contains('libc++.1.dylib') {
			libcxx = true
		}
		if content.contains('libstdc++.so') || content.contains('libstdc++.dylib') {
			libstdcxx = true
		}
	}
	mut result := []string{}
	if libcxx {
		result << 'libcxx'
	}
	if libstdcxx {
		result << 'libstdcxx'
	}
	return result
}

pub fn (build &Build) detect_stdlibs() ![]string {
	keg := new_keg_with_paths(build.formula.prefix(), build.formula.cellar, build.formula.prefix_root)!
	return build_detect_cxx_stdlibs(keg)
}

pub fn (build &Build) fixopt(formula Formula) ! {
	path := if os.is_dir(formula.linked_keg()) && os.is_link(formula.linked_keg()) {
		brew_runtime.real_path(formula.linked_keg())
	} else if os.is_dir(formula.prefix()) {
		formula.prefix()
	} else {
		children := os.ls(formula.rack()) or {
			return error('${formula.opt_prefix()} not present or broken\nPlease reinstall ${formula.full_name()}. Sorry :(')
		}
		if children.len != 1 || !os.is_dir(os.join_path(formula.rack(), children[0])) {
			return error('${formula.opt_prefix()} not present or broken\nPlease reinstall ${formula.full_name()}. Sorry :(')
		}
		os.join_path(formula.rack(), children[0])
	}
	keg := new_keg_with_paths(path, formula.cellar, formula.prefix_root) or {
		return error('${formula.opt_prefix()} not present or broken\nPlease reinstall ${formula.full_name()}. Sorry :(')
	}
	keg.optlink(false, false) or {
		return error('${formula.opt_prefix()} not present or broken\nPlease reinstall ${formula.full_name()}. Sorry :(')
	}
}

pub fn (build &Build) normalize_pod2man_outputs(formula Formula) ! {
	keg := new_keg_with_paths(formula.prefix(), formula.cellar, formula.prefix_root)!
	keg.normalize_pod2man_outputs()!
}

fn build_boundary_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn build_boundary_value(build &Build) brew_runtime.Value {
	return brew_runtime.structured_value('Build', build.formula.full_name(), {
		'build_address': u64(voidptr(build)).str()
	})
}

fn build_from_boundary(value brew_runtime.Value) &Build {
	address := value.attribute('build_address') or { panic('invalid Build receiver') }
	return unsafe { &Build(voidptr(address.u64())) }
}

fn build_dependency_boundary_value(dependency Dependency) brew_runtime.Value {
	return brew_runtime.structured_value('Dependency', dependency.inspect(), {
		'name': dependency.name
		'tags': dependency.tags.map(it.boundary_string()).join('\x1e')
	})
}

fn build_requirement_boundary_value(requirement Requirement) brew_runtime.Value {
	return brew_runtime.structured_value('Requirement', requirement.inspect(), {
		'name': requirement.name
		'tags': requirement.tags.map(it.inspect()).join('\x1e')
	})
}

fn build_args_boundary_value(args BuildArgs) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Cmd::InstallCmd::Args', '', {
		'ignore_dependencies': args.ignore_dependencies.str()
		'env':                 args.env
		'cc':                  args.cc
		'build_bottle':        args.build_bottle.str()
		'bottle_arch':         args.bottle_arch
		'debug_symbols':       args.debug_symbols.str()
		'debug':               args.debug.str()
		'keep_tmp':            args.keep_tmp.str()
		'interactive':         args.interactive.str()
		'git':                 args.git.str()
		'verbose':             args.verbose.str()
	})
}

fn build_args_from_boundary(value brew_runtime.Value) BuildArgs {
	return BuildArgs{
		ignore_dependencies: (value.attribute('ignore_dependencies') or { 'false' }) == 'true'
		env: value.attribute('env') or { '' }
		cc: value.attribute('cc') or { '' }
		build_bottle: (value.attribute('build_bottle') or { 'false' }) == 'true'
		bottle_arch: value.attribute('bottle_arch') or { '' }
		debug_symbols: (value.attribute('debug_symbols') or { 'false' }) == 'true'
		debug: (value.attribute('debug') or { 'false' }) == 'true'
		keep_tmp: (value.attribute('keep_tmp') or { 'false' }) == 'true'
		interactive: (value.attribute('interactive') or { 'false' }) == 'true'
		git: (value.attribute('git') or { 'false' }) == 'true'
		verbose: (value.attribute('verbose') or { 'false' }) == 'true'
	}
}

fn build_requested_options_from_boundary(value brew_runtime.Value) Options {
	if values := value.as_string_array() {
		return new_options(...values)
	}
	flags := value.attribute('flags') or { value.attribute('args') or { '' } }
	return if flags == '' { new_options() } else { new_options(...flags.split('\x1e')) }
}

fn build_options_boundary_value(options BuildOptions) brew_runtime.Value {
	return brew_runtime.structured_value('BuildOptions', options.used_options().inspect(), {
		'args':    options.args.as_flags().join('\x1e')
		'options': options.options.as_flags().join('\x1e')
	})
}

fn build_install_result_boundary_value(result BuildInstallResult) brew_runtime.Value {
	return brew_runtime.structured_value('BuildInstallResult', result.events.join('\n'), {
		'dependencies':          result.formula_dependencies.map(it.full_name()).join('\x1e')
		'keg_only_dependencies': result.keg_only_dependencies.map(it.full_name()).join('\x1e')
		'run_time_dependencies': result.run_time_dependencies.map(it.full_name()).join('\x1e')
		'stdlibs':               result.stdlibs.join('\x1e')
		'receipt_path':          result.receipt_path
	})
}

// Ruby attr_reader `attr_reader :formula` at line 25.
pub fn ruby_build_l25_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Build#formula requires a receiver')
	}
	return formula_boundary_value(build_from_boundary(args[0]).formula)
}

// Ruby attr_reader `attr_reader :deps` at line 28.
pub fn ruby_build_l28_d2_deps(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Build#deps requires a receiver')
	}
	return brew_runtime.array_value(build_from_boundary(args[0]).deps.map(build_dependency_boundary_value(it)))
}

// Ruby attr_reader `attr_reader :reqs` at line 31.
pub fn ruby_build_l31_d3_reqs(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Build#reqs requires a receiver')
	}
	return brew_runtime.array_value(build_from_boundary(args[0]).reqs.map(build_requirement_boundary_value(it)))
}

// Ruby attr_reader `attr_reader :args` at line 34.
pub fn ruby_build_l34_d4_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Build#args requires a receiver')
	}
	return build_args_boundary_value(build_from_boundary(args[0]).args)
}

// Ruby method `initialize(formula, options, args:)` at line 37.
pub fn ruby_build_l37_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Build#initialize requires a formula and options')
	}
	formula := formula_from_boundary(args[0])
	install_args := if args.len > 2 { build_args_from_boundary(args[2]) } else { BuildArgs{} }
	build := new_build(formula, build_requested_options_from_boundary(args[1]), install_args, BuildContext{}) or { panic(err) }
	return build_boundary_value(build)
}

// Ruby method `effective_build_options_for(dependent)` at line 51.
pub fn ruby_build_l51_d6_effective_build_options_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Build#effective_build_options_for requires a dependent formula')
	}
	return build_options_boundary_value(build_from_boundary(args[0]).effective_build_options_for(formula_from_boundary(args[1])))
}

// Ruby method `expand_reqs` at line 58.
pub fn ruby_build_l58_d7_expand_reqs(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Build#expand_reqs requires a receiver')
	}
	requirements := build_from_boundary(args[0]).expand_reqs() or { panic(err) }
	return brew_runtime.array_value(requirements.map(build_requirement_boundary_value(it)))
}

// Ruby method `expand_deps` at line 69.
pub fn ruby_build_l69_d8_expand_deps(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Build#expand_deps requires a receiver')
	}
	dependencies := build_from_boundary(args[0]).expand_deps() or { panic(err) }
	return brew_runtime.array_value(dependencies.map(build_dependency_boundary_value(it)))
}

// Ruby method `install` at line 83.
pub fn ruby_build_l83_d9_install(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Build#install requires a receiver')
	}
	mut execution := BuildInstallExecution{
		environment: map[string]string{}
	}
	result := build_from_boundary(args[0]).install(mut execution) or { panic(err) }
	return build_install_result_boundary_value(result)
}

// Ruby method `detect_stdlibs` at line 223.
pub fn ruby_build_l223_d10_detect_stdlibs(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Build#detect_stdlibs requires a receiver')
	}
	return brew_runtime.string_array_value(build_from_boundary(args[0]).detect_stdlibs() or {
		panic(err)
	})
}

// Ruby method `fixopt(formula)` at line 233.
pub fn ruby_build_l233_d11_fixopt(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Build#fixopt requires a formula')
	}
	build_from_boundary(args[0]).fixopt(formula_from_boundary(args[1])) or { panic(err) }
	return build_boundary_nil()
}

// Ruby method `normalize_pod2man_outputs!(formula)` at line 250.
pub fn ruby_build_l250_d12_normalize_pod2man_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Build#normalize_pod2man_outputs! requires a formula')
	}
	build_from_boundary(args[0]).normalize_pod2man_outputs(formula_from_boundary(args[1])) or {
		panic(err)
	}
	return build_boundary_nil()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # This script is loaded by formula_installer as a separate instance.
// 5: # Thrown exceptions are propagated back to the parent process over a pipe
// 6:
// 7: raise "#{__FILE__} must not be loaded via `require`." if $PROGRAM_NAME != __FILE__
// 8:
// 9: old_trap = trap("INT") { exit! 130 }
// 10:
// 11: require_relative "global"
// 12: require "build_options"
// 13: require "keg"
// 14: require "extend/ENV"
// 15: require "cmd/install"
// 16: require "utils/fork"
// 17: require "utils/output"
// 18: require "extend/pathname/write_mkpath_extension"
// 19:
// 20: # A formula build.
// 21: class Build
// 22:   include Utils::Output::Mixin
// 23:
// 24:   sig { returns(Formula) }
// 25:   attr_reader :formula
// 26:
// 27:   sig { returns(T::Array[Dependency]) }
// 28:   attr_reader :deps
// 29:
// 30:   sig { returns(Requirements) }
// 31:   attr_reader :reqs
// 32:
// 33:   sig { returns(Homebrew::Cmd::InstallCmd::Args) }
// 34:   attr_reader :args
// 35:
// 36:   sig { params(formula: Formula, options: Options, args: Homebrew::Cmd::InstallCmd::Args).void }
// 37:   def initialize(formula, options, args:)
// 38:     @formula = formula
// 39:     @formula.build = BuildOptions.new(options, formula.options)
// 40:     @args = args
// 41:     @deps = T.let([], T::Array[Dependency])
// 42:     @reqs = T.let(Requirements.new, Requirements)
// 43:
// 44:     return if args.ignore_dependencies?
// 45:
// 46:     @deps = expand_deps
// 47:     @reqs = expand_reqs
// 48:   end
// 49:
// 50:   sig { params(dependent: Formula).returns(BuildOptions) }
// 51:   def effective_build_options_for(dependent)
// 52:     args  = dependent.build.used_options
// 53:     args |= Tab.for_formula(dependent).used_options
// 54:     BuildOptions.new(args, dependent.options)
// 55:   end
// 56:
// 57:   sig { returns(Requirements) }
// 58:   def expand_reqs
// 59:     formula.recursive_requirements do |dependent, req|
// 60:       dependent = T.cast(dependent, Formula)
// 61:       build = effective_build_options_for(dependent)
// 62:       if req.prune_from_option?(build) || req.prune_if_build_and_not_dependent?(dependent, formula) || req.test?
// 63:         next Dependable::PRUNE
// 64:       end
// 65:     end
// 66:   end
// 67:
// 68:   sig { returns(T::Array[Dependency]) }
// 69:   def expand_deps
// 70:     formula.recursive_dependencies do |dependent, dep|
// 71:       build = effective_build_options_for(T.cast(dependent, Formula))
// 72:       if dep.prune_from_option?(build) ||
// 73:          dep.prune_if_build_and_not_dependent?(T.cast(dependent, Formula), formula) ||
// 74:          (dep.test? && !dep.build?) || dep.implicit?
// 75:         next Dependable::PRUNE
// 76:       elsif dep.build?
// 77:         next Dependable::KEEP_BUT_PRUNE_RECURSIVE_DEPS
// 78:       end
// 79:     end
// 80:   end
// 81:
// 82:   sig { void }
// 83:   def install
// 84:     formula_deps = deps.map(&:to_formula)
// 85:     keg_only_deps = formula_deps.select(&:keg_only?)
// 86:     run_time_deps = deps.reject(&:build?).map(&:to_formula)
// 87:
// 88:     formula_deps.each do |dep|
// 89:       fixopt(dep) unless dep.opt_prefix.directory?
// 90:     end
// 91:
// 92:     ENV.activate_extensions!(env: args.env)
// 93:
// 94:     if superenv?(args.env)
// 95:       superenv = ENV
// 96:       superenv.keg_only_deps = keg_only_deps
// 97:       superenv.deps = formula_deps
// 98:       superenv.run_time_deps = run_time_deps
// 99:       ENV.setup_build_environment(
// 100:         formula:,
// 101:         cc:            args.cc,
// 102:         build_bottle:  args.build_bottle?,
// 103:         bottle_arch:   args.bottle_arch,
// 104:         debug_symbols: args.debug_symbols?,
// 105:       )
// 106:       reqs.each do |req|
// 107:         req.modify_build_environment(
// 108:           env: args.env, cc: args.cc, build_bottle: args.build_bottle?, bottle_arch: args.bottle_arch,
// 109:         )
// 110:       end
// 111:     else
// 112:       ENV.setup_build_environment(
// 113:         formula:,
// 114:         cc:            args.cc,
// 115:         build_bottle:  args.build_bottle?,
// 116:         bottle_arch:   args.bottle_arch,
// 117:         debug_symbols: args.debug_symbols?,
// 118:       )
// 119:       reqs.each do |req|
// 120:         req.modify_build_environment(
// 121:           env: args.env, cc: args.cc, build_bottle: args.build_bottle?, bottle_arch: args.bottle_arch,
// 122:         )
// 123:       end
// 124:
// 125:       keg_only_deps.each do |dep|
// 126:         ENV.prepend_path "PATH", dep.opt_bin.to_s
// 127:         ENV.prepend_path "PKG_CONFIG_PATH", "#{dep.opt_lib}/pkgconfig"
// 128:         ENV.prepend_path "PKG_CONFIG_PATH", "#{dep.opt_share}/pkgconfig"
// 129:         ENV.prepend_path "ACLOCAL_PATH", "#{dep.opt_share}/aclocal"
// 130:         ENV.prepend_path "CMAKE_PREFIX_PATH", dep.opt_prefix.to_s
// 131:         ENV.prepend "LDFLAGS", "-L#{dep.opt_lib}" if dep.opt_lib.directory?
// 132:         ENV.prepend "CPPFLAGS", "-I#{dep.opt_include}" if dep.opt_include.directory?
// 133:       end
// 134:     end
// 135:
// 136:     new_env = {
// 137:       "TMPDIR" => HOMEBREW_TEMP.to_s,
// 138:       "TEMP"   => HOMEBREW_TEMP.to_s,
// 139:       "TMP"    => HOMEBREW_TEMP.to_s,
// 140:     }
// 141:
// 142:     with_env(new_env) do
// 143:       if args.debug? && !Homebrew::EnvConfig.disable_debrew?
// 144:         require "debrew"
// 145:         formula.extend(Debrew::Formula)
// 146:       end
// 147:
// 148:       formula.update_head_version
// 149:
// 150:       formula.brew(
// 151:         fetch:         false,
// 152:         keep_tmp:      args.keep_tmp?,
// 153:         debug_symbols: args.debug_symbols?,
// 154:         interactive:   args.interactive?,
// 155:       ) do
// 156:         with_env(
// 157:           # For head builds, HOMEBREW_FORMULA_PREFIX should include the commit,
// 158:           # which is not known until after the formula has been staged.
// 159:           HOMEBREW_FORMULA_PREFIX:    formula.prefix,
// 160:           # https://reproducible-builds.org/docs/build-path/
// 161:           HOMEBREW_FORMULA_BUILDPATH: formula.buildpath,
// 162:           # https://reproducible-builds.org/docs/source-date-epoch/
// 163:           SOURCE_DATE_EPOCH:          formula.source_modified_time.to_i.to_s,
// 164:           # Avoid make getting confused about timestamps.
// 165:           # https://github.com/Homebrew/homebrew-core/pull/87470
// 166:           TZ:                         "UTC0",
// 167:         ) do
// 168:           if args.git?
// 169:             formula.selective_patch(is_data: false)
// 170:             system "git", "init"
// 171:             system "git", "add", "-A"
// 172:             formula.selective_patch(is_data: true)
// 173:           else
// 174:             formula.patch
// 175:           end
// 176:
// 177:           if args.interactive?
// 178:             ohai "Entering interactive mode..."
// 179:             puts <<~EOS
// 180:               Type `exit` to return and finalize the installation.
// 181:               Install to this prefix: #{formula.prefix}
// 182:             EOS
// 183:
// 184:             if args.git?
// 185:               puts <<~EOS
// 186:                 This directory is now a Git repository. Make your changes and then use:
// 187:                   git diff | pbcopy
// 188:                 to copy the diff to the clipboard.
// 189:               EOS
// 190:             end
// 191:
// 192:             interactive_shell(formula)
// 193:           else
// 194:             formula.prefix.mkpath
// 195:             formula.logs.mkpath
// 196:
// 197:             (formula.logs/"00.options.out").write \
// 198:               "#{formula.full_name} #{formula.build.used_options.sort.join(" ")}".strip
// 199:
// 200:             Pathname.activate_extensions!
// 201:             formula.install
// 202:
// 203:             stdlibs = detect_stdlibs
// 204:             tab = Tab.create(formula, ENV.compiler, stdlibs.first)
// 205:             tab.write
// 206:
// 207:             # Find and link metafiles
// 208:             formula.prefix.install_metafiles T.must(formula.buildpath)
// 209:             if formula.libexec.exist?
// 210:               require "metafiles"
// 211:               no_metafiles = formula.prefix.children.none? { |p| p.file? && Metafiles.copy?(p.basename.to_s) }
// 212:               formula.prefix.install_metafiles formula.libexec if no_metafiles
// 213:             end
// 214:
// 215:             normalize_pod2man_outputs!(formula)
// 216:           end
// 217:         end
// 218:       end
// 219:     end
// 220:   end
// 221:
// 222:   sig { returns(T::Array[Symbol]) }
// 223:   def detect_stdlibs
// 224:     keg = Keg.new(formula.prefix)
// 225:
// 226:     # The stdlib recorded in the install receipt is used during dependency
// 227:     # compatibility checks, so we only care about the stdlib that libraries
// 228:     # link against.
// 229:     keg.detect_cxx_stdlibs(skip_executables: true)
// 230:   end
// 231:
// 232:   sig { params(formula: Formula).void }
// 233:   def fixopt(formula)
// 234:     path = if formula.linked_keg.directory? && formula.linked_keg.symlink?
// 235:       formula.linked_keg.resolved_path
// 236:     elsif formula.prefix.directory?
// 237:       formula.prefix
// 238:     elsif (children = formula.rack.children.presence) && children.size == 1 &&
// 239:           (first_child = children.first) && first_child.directory?
// 240:       first_child
// 241:     else
// 242:       raise
// 243:     end
// 244:     Keg.new(path).optlink(verbose: args.verbose?)
// 245:   rescue
// 246:     raise "#{formula.opt_prefix} not present or broken\nPlease reinstall #{formula.full_name}. Sorry :("
// 247:   end
// 248:
// 249:   sig { params(formula: Formula).void }
// 250:   def normalize_pod2man_outputs!(formula)
// 251:     keg = Keg.new(formula.prefix)
// 252:     keg.normalize_pod2man_outputs!
// 253:   end
// 254: end
// 255:
// 256: begin
// 257:   # Undocumented opt-out for internal use.
// 258:   # We need to allow formulae from paths here due to how we pass them through.
// 259:   ENV["HOMEBREW_INTERNAL_ALLOW_PACKAGES_FROM_PATHS"] = "1"
// 260:
// 261:   formula_path = ARGV.first
// 262:   args = Homebrew::Cmd::InstallCmd.new.args
// 263:   Context.current = args.context
// 264:
// 265:   error_pipe = Utils.forked_child_error_pipe
// 266:
// 267:   trap("INT", old_trap)
// 268:
// 269:   if formula_path&.end_with?(".json")
// 270:     raise "build.rb received an API JSON file as the formula path: #{formula_path}. " \
// 271:           "This usually means the formula source was not downloaded from the API. " \
// 272:           "Try clearing the cache: rm -rf $(brew --cache)/api-source"
// 273:   end
// 274:
// 275:   formula = args.named.to_formulae.fetch(0)
// 276:   options = Options.create(args.flags_only)
// 277:   build   = Build.new(formula, options, args:)
// 278:
// 279:   build.install
// 280: # Any exception means the build did not complete.
// 281: # The `case` for what to do per-exception class is further down.
// 282: rescue Exception => e # rubocop:disable Lint/RescueException
// 283:   Utils.report_forked_child_error(error_pipe, e)
// 284:   exit! 1
// 285: end
