module homebrew

import ruby
import homebrew.extend as pathname_extension
import os

// Translated from Homebrew/brew `build.rb`.

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
		ruby.real_path(formula.linked_keg())
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

fn build_boundary_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn build_boundary_value(build &Build) ruby.Value {
	return ruby.structured_value('Build', build.formula.full_name(), {
		'build_address': u64(voidptr(build)).str()
	})
}

fn build_from_boundary(value ruby.Value) &Build {
	address := value.attribute('build_address') or { panic('invalid Build receiver') }
	return unsafe { &Build(voidptr(address.u64())) }
}

fn build_dependency_boundary_value(dependency Dependency) ruby.Value {
	return ruby.structured_value('Dependency', dependency.inspect(), {
		'name': dependency.name
		'tags': dependency.tags.map(it.boundary_string()).join('\x1e')
	})
}

fn build_requirement_boundary_value(requirement Requirement) ruby.Value {
	return ruby.structured_value('Requirement', requirement.inspect(), {
		'name': requirement.name
		'tags': requirement.tags.map(it.inspect()).join('\x1e')
	})
}

fn build_args_boundary_value(args BuildArgs) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::InstallCmd::Args', '', {
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

fn build_args_from_boundary(value ruby.Value) BuildArgs {
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

fn build_requested_options_from_boundary(value ruby.Value) Options {
	if values := value.as_string_array() {
		return new_options(...values)
	}
	flags := value.attribute('flags') or { value.attribute('args') or { '' } }
	return if flags == '' { new_options() } else { new_options(...flags.split('\x1e')) }
}

fn build_options_boundary_value(options BuildOptions) ruby.Value {
	return ruby.structured_value('BuildOptions', options.used_options().inspect(), {
		'args':    options.args.as_flags().join('\x1e')
		'options': options.options.as_flags().join('\x1e')
	})
}

fn build_install_result_boundary_value(result BuildInstallResult) ruby.Value {
	return ruby.structured_value('BuildInstallResult', result.events.join('\n'), {
		'dependencies':          result.formula_dependencies.map(it.full_name()).join('\x1e')
		'keg_only_dependencies': result.keg_only_dependencies.map(it.full_name()).join('\x1e')
		'run_time_dependencies': result.run_time_dependencies.map(it.full_name()).join('\x1e')
		'stdlibs':               result.stdlibs.join('\x1e')
		'receipt_path':          result.receipt_path
	})
}
