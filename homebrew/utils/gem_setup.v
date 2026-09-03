module utils

import brew_runtime
import os
import time

// Translated from Homebrew/brew `utils/gem_setup.rb`.
// The original source is retained below until every stub has a typed V body.

pub const gem_setup_vendor_version = 9

pub struct GemSetupPaths {
pub:
	library          string
	ruby_version     string
	ruby_prefix      string
	gem_bindir       string
	rubygems_version string = '2.2.0'
}

pub struct GemSetupBundlerDefinition {
pub:
	groups       []string
	locked_specs []GemSetupLockedSpec
}

pub struct GemSetupLockedSpec {
pub:
	full_name string
}

@[heap]
pub struct GemSetupState {
pub mut:
	bundler_definition          GemSetupBundlerDefinition
	bundler_definition_set      bool
	user_gem_groups             []string
	user_gem_groups_set         bool
	user_vendor_version         int
	user_vendor_version_set     bool
	bundle_installed_groups     []string
	bundle_installed_groups_set bool
	load_path                   []string
}

pub struct GemSetupEnvironmentConfig {
pub:
	environment map[string]string
	paths       GemSetupPaths
	setup_path  bool = true
}

pub struct GemSetupEnvironmentResult {
pub:
	environment map[string]string
	gem_paths   map[string]string
	gem_home    string
	gem_cache   string
}

pub struct GemSetupMessage {
pub:
	text      string
	exit_code int
}

pub struct GemSetupDependencySpec {
pub:
	full_name     string
	full_gem_path string
	require_paths []string
}

pub struct GemSetupGemSpec {
pub:
	name                     string
	version                  string
	full_name                string
	full_gem_path            string
	require_paths            []string
	runtime_dependency_specs []GemSetupDependencySpec
}

pub struct GemSetupInstallGemRequest {
pub:
	name                  string
	version               string
	setup_gem_environment bool = true
	environment           GemSetupEnvironmentConfig
	available_specs       []GemSetupGemSpec
}

pub struct GemSetupInstallGemResult {
pub:
	specs       []GemSetupGemSpec
	load_path   []string
	installed   bool
	environment GemSetupEnvironmentResult
	messages    []GemSetupMessage
}

pub type GemSetupGemInstaller = fn (string, string) ![]GemSetupGemSpec

pub struct GemSetupCommand {
pub:
	executable                string
	arguments                 []string
	environment               map[string]string
	redirect_stdout_to_stderr bool
	run_as_real_uid           bool
}

pub struct GemSetupCommandResult {
pub:
	stdout  string
	stderr  string
	success bool
}

pub type GemSetupCommandRunner = fn (GemSetupCommand) !GemSetupCommandResult

pub type GemSetupPackageInspector = fn (string) ![]string

pub struct GemSetupBundlerConfig {
pub:
	environment          map[string]string
	paths                GemSetupPaths
	gem_groups_file      string
	vendor_version_file  string
	gem_dir              string
	definition           GemSetupBundlerDefinition
	groups               []string
	only_warn_on_failure bool
	setup_path           bool = true
}

pub struct GemSetupBundlerPlan {
pub:
	environment map[string]string
	gem_paths   map[string]string
	groups      []string
	bundle      string
	skipped     bool
}

pub struct GemSetupBundlerResult {
pub:
	environment               map[string]string
	gem_paths                 map[string]string
	groups                    []string
	commands                  []GemSetupCommand
	warnings                  []string
	errors                    []string
	bundle_installed          bool
	bundle_install_required   bool
	vendor_reinstall_required bool
	bootsnap_reset_required   bool
	skipped_for_tests         bool
	paths_restored            bool
}

fn gem_setup_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn gem_setup_error_value(type_name string, message string) brew_runtime.Value {
	return brew_runtime.object_value(type_name, message)
}

pub fn gem_setup_vendor_directory(paths GemSetupPaths) string {
	return os.join_path(paths.library, 'Homebrew/vendor/bundle/ruby')
}

pub fn gem_setup_gemfile(library string) string {
	return os.join_path(library, 'Homebrew/Gemfile')
}

pub fn gem_setup_bundler_definition(mut state GemSetupState,
	definition GemSetupBundlerDefinition) GemSetupBundlerDefinition {
	if !state.bundler_definition_set {
		state.bundler_definition = definition
		state.bundler_definition_set = true
	}
	return state.bundler_definition
}

pub fn gem_setup_valid_gem_groups(definition GemSetupBundlerDefinition) []string {
	return definition.groups.filter(it != 'default').map(it)
}

pub fn gem_setup_ruby_bindir(prefix string) string {
	return os.join_path(prefix, 'bin')
}

pub fn gem_setup_ohai(message string) GemSetupMessage {
	return GemSetupMessage{ text: '==> ${message}' }
}

pub fn gem_setup_opoo(message string) GemSetupMessage {
	return GemSetupMessage{ text: 'Warning: ${message}' }
}

pub fn gem_setup_odie(message string) GemSetupMessage {
	return GemSetupMessage{
		text: 'Error: ${message}'
		exit_code: 1
	}
}

fn gem_setup_compare_numeric_versions(left string, right string) int {
	left_parts := left.split('.').map(it.int())
	right_parts := right.split('.').map(it.int())
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_value := if index < left_parts.len { left_parts[index] } else { 0 }
		right_value := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_value < right_value {
			return -1
		}
		if left_value > right_value {
			return 1
		}
	}
	return 0
}

fn gem_setup_unset(mut environment map[string]string, key string) {
	environment.delete(key)
}

fn gem_setup_path_entries(path_value string) []string {
	return path_value.split(':')
}

pub fn setup_gem_environment(config GemSetupEnvironmentConfig) !GemSetupEnvironmentResult {
	if gem_setup_compare_numeric_versions(config.paths.rubygems_version, '2.2.0') < 0 {
		return error('RubyGems too old!')
	}
	mut environment := config.environment.clone()
	environment['BUNDLER_NO_OLD_RUBYGEMS_WARNING'] = '1'
	gem_home := os.join_path(gem_setup_vendor_directory(config.paths), config.paths.ruby_version)
	mut gem_cache := ''
	mut gem_paths := {
		'GEM_HOME': gem_home
		'GEM_PATH': gem_home
	}
	if 'HOMEBREW_CACHE' in environment {
		gem_cache = os.join_path(environment['HOMEBREW_CACHE'], 'gem-spec-cache')
		gem_paths['GEM_SPEC_CACHE'] = gem_cache
	}
	// Set TMPDIR so Xcode's `make` doesn't fall back to `/var/tmp/`,
	// which may be not user-writable.
	if 'HOMEBREW_TEMP' in environment {
		environment['TMPDIR'] = environment['HOMEBREW_TEMP']
	} else {
		gem_setup_unset(mut environment, 'TMPDIR')
	}
	if !config.setup_path {
		return GemSetupEnvironmentResult{
			environment: environment
			gem_paths: gem_paths
			gem_home: gem_home
			gem_cache: gem_cache
		}
	}
	if 'PATH' !in environment {
		return error('key not found: PATH')
	}
	// Add necessary Ruby and Gem binary directories to `PATH`.
	mut paths := gem_setup_path_entries(environment['PATH'])
	ruby_bindir := gem_setup_ruby_bindir(config.paths.ruby_prefix)
	if ruby_bindir !in paths {
		paths.prepend(ruby_bindir)
	}
	if config.paths.gem_bindir !in paths {
		paths.prepend(config.paths.gem_bindir)
	}
	environment['PATH'] = paths.join(':')
	// Set envs so the above binaries can be invoked.
	// We don't do this unless requested as some formulae may invoke system Ruby instead of ours.
	environment['GEM_HOME'] = gem_home
	environment['GEM_PATH'] = gem_home
	if gem_cache != '' {
		environment['GEM_SPEC_CACHE'] = gem_cache
	} else {
		gem_setup_unset(mut environment, 'GEM_SPEC_CACHE')
	}
	return GemSetupEnvironmentResult{
		environment: environment
		gem_paths: gem_paths
		gem_home: gem_home
		gem_cache: gem_cache
	}
}

fn gem_setup_spec_matches(spec GemSetupGemSpec, name string, version string) bool {
	return spec.name == name && (version == '' || spec.version == version)
}

pub fn install_gem(request GemSetupInstallGemRequest, mut state GemSetupState,
	installer GemSetupGemInstaller) !GemSetupInstallGemResult {
	environment := if request.setup_gem_environment {
		setup_gem_environment(request.environment)!
	} else {
		GemSetupEnvironmentResult{
			environment: request.environment.environment.clone()
		}
	}
	mut specs := request.available_specs.filter(gem_setup_spec_matches(it, request.name, request.version))
	mut installed := false
	mut messages := []GemSetupMessage{}
	if specs.len == 0 {
		messages << gem_setup_ohai("Installing '${request.name}' gem")
		specs = installer(request.name, request.version) or {
			return error("failed to install the '${request.name}' gem.")
		}
		installed = true
	}
	mut dependency_specs := []GemSetupGemSpec{}
	for spec in specs {
		for dependency in spec.runtime_dependency_specs {
			dependency_specs << GemSetupGemSpec{
				name: dependency.full_name
				full_name: dependency.full_name
				full_gem_path: dependency.full_gem_path
				require_paths: dependency.require_paths.clone()
			}
		}
	}
	specs << dependency_specs
	// Add the specs to the $LOAD_PATH.
	for spec in specs {
		for path in spec.require_paths {
			full_path := os.join_path(spec.full_gem_path, path)
			if full_path !in state.load_path {
				state.load_path.prepend(full_path)
			}
		}
	}
	return GemSetupInstallGemResult{
		specs: specs
		load_path: state.load_path.clone()
		installed: installed
		environment: environment
		messages: messages
	}
}

pub fn gem_setup_find_in_path(executable string, path_value string) ?string {
	for path in gem_setup_path_entries(path_value) {
		candidate := os.join_path(path, executable)
		if os.is_file(candidate) && os.is_executable(candidate) {
			return path
		}
	}
	return none
}

pub fn gem_setup_user_gem_groups(path string, mut state GemSetupState) ![]string {
	if !state.user_gem_groups_set {
		state.user_gem_groups = if os.exists(path) {
			contents := os.read_file(path)!
			if contents == '' { []string{} } else { contents.split_into_lines() }
		} else {
			[]string{}
		}
		state.user_gem_groups_set = true
	}
	return state.user_gem_groups.clone()
}

pub fn gem_setup_write_user_gem_groups(path string, groups []string,
	mut state GemSetupState) ! {
	if state.user_gem_groups_set && state.user_gem_groups == groups && os.exists(path) {
		return
	}
	directory := os.dir(path)
	if !os.is_dir(directory) {
		return error('No such directory: ${directory}')
	}
	// Write the file atomically, in case we're working parallel
	temporary := os.join_path(directory, '${os.base(path)}~.${os.getpid()}.${time.now().unix_nano()}')
	mut renamed := false
	defer {
		if !renamed {
			os.rm(temporary) or {}
		}
	}
	os.write_file(temporary, groups.join('\n'))!
	os.chmod(temporary, 0o644)!
	os.mv(temporary, path)!
	renamed = true
	state.user_gem_groups = groups.clone()
	state.user_gem_groups_set = true
}

pub fn gem_setup_forget_user_gem_groups(path string, mut state GemSetupState) ! {
	if os.exists(path) {
		os.truncate(path, 0)!
	}
	state.user_gem_groups = []string{}
	state.user_gem_groups_set = true
}

pub fn gem_setup_user_vendor_version(path string, mut state GemSetupState) !int {
	if !state.user_vendor_version_set {
		state.user_vendor_version = if os.exists(path) { os.read_file(path)!.int() } else { 0 }
		state.user_vendor_version_set = true
	}
	return state.user_vendor_version
}

fn gem_setup_unique_sorted(groups []string) []string {
	mut result := []string{}
	for group in groups {
		if group !in result {
			result << group
		}
	}
	result.sort()
	return result
}

fn gem_setup_restore_key(mut environment map[string]string, original map[string]string,
	key string) {
	if key in original {
		environment[key] = original[key]
	} else {
		gem_setup_unset(mut environment, key)
	}
}

fn gem_setup_restore_paths(mut environment map[string]string, original map[string]string) {
	for key in ['PATH', 'GEM_PATH', 'GEM_HOME', 'GEM_SPEC_CACHE', 'BUNDLE_GEMFILE', 'BUNDLE_WITH',
		'BUNDLE_FROZEN'] {
		gem_setup_restore_key(mut environment, original, key)
	}
}

fn gem_setup_combined_groups(requested []string, stored []string, valid []string) []string {
	mut combined := requested.clone()
	for group in stored {
		if group in valid && group !in combined {
			combined << group
		}
	}
	return gem_setup_unique_sorted(combined)
}

fn gem_setup_bundler_environment(config GemSetupBundlerConfig, groups []string,
	setup GemSetupEnvironmentResult) map[string]string {
	mut environment := setup.environment.clone()
	if 'HOMEBREW_BUNDLE_USER_CACHE' in environment {
		environment['BUNDLE_USER_CACHE'] = environment['HOMEBREW_BUNDLE_USER_CACHE']
	}
	environment['BUNDLE_GEMFILE'] = gem_setup_gemfile(config.paths.library)
	environment['BUNDLE_WITH'] = groups.join(' ')
	environment['BUNDLE_FROZEN'] = 'true'
	return environment
}

pub fn plan_install_bundler_gems(config GemSetupBundlerConfig,
	mut state GemSetupState) !GemSetupBundlerPlan {
	valid := gem_setup_valid_gem_groups(config.definition)
	invalid := config.groups.filter(it !in valid)
	if invalid.len > 0 {
		return error('Invalid gem groups: ${invalid.join(', ')}')
	}
	setup := setup_gem_environment(GemSetupEnvironmentConfig{
		environment: config.environment
		paths: config.paths
	})!
	mut environment := setup.environment.clone()
	if 'HOMEBREW_TESTS' in environment {
		if !config.setup_path {
			gem_setup_restore_paths(mut environment, config.environment)
		}
		return GemSetupBundlerPlan{
			environment: environment
			gem_paths: setup.gem_paths
			groups: config.groups.clone()
			skipped: true
		}
	}
	stored := gem_setup_user_gem_groups(config.gem_groups_file, mut state)!
	groups := gem_setup_combined_groups(config.groups, stored, valid)
	environment = gem_setup_bundler_environment(config, groups, setup)
	if state.bundle_installed_groups_set && state.bundle_installed_groups == groups {
		return GemSetupBundlerPlan{
			environment: environment
			gem_paths: setup.gem_paths
			groups: groups
		}
	}
	bundle_directory := gem_setup_find_in_path('bundle', environment['PATH']) or {
		return error('bundle executable not found in PATH')
	}
	return GemSetupBundlerPlan{
		environment: environment
		gem_paths: setup.gem_paths
		groups: groups
		bundle: os.join_path(bundle_directory, 'bundle')
	}
}

fn gem_setup_vendor_reinstall(config GemSetupBundlerConfig, mut state GemSetupState,
	inspector GemSetupPackageInspector) !bool {
	if gem_setup_user_vendor_version(config.vendor_version_file, mut state)! == gem_setup_vendor_version {
		return false
	}
	mut reinstall := false
	for spec in config.definition.locked_specs {
		spec_file := os.join_path(config.gem_dir, 'specifications/${spec.full_name}.gemspec')
		if !os.exists(spec_file) {
			continue
		}
		cache_file := os.join_path(config.gem_dir, 'cache/${spec.full_name}.gem')
		if os.exists(cache_file) {
			contents := inspector(cache_file) or {
				// Malformed, assume broken
				os.rm(cache_file)!
				[]string{}
			}
			mut package_install_intact := true
			for gem_file in contents {
				if !os.exists(os.join_path(config.gem_dir, 'gems/${spec.full_name}/${gem_file}')) {
					package_install_intact = false
					break
				}
			}
			if package_install_intact && os.exists(cache_file) {
				continue
			}
		}
		// Mark gem for reinstallation
		os.rm(spec_file)!
		reinstall = true
	}
	os.mkdir_all(os.dir(config.vendor_version_file))!
	os.write_file(config.vendor_version_file, gem_setup_vendor_version.str())!
	state.user_vendor_version = gem_setup_vendor_version
	state.user_vendor_version_set = true
	return reinstall
}

fn gem_setup_run_bundle(command GemSetupCommand, runner GemSetupCommandRunner,
	mut commands []GemSetupCommand) !GemSetupCommandResult {
	commands << command
	return runner(command)!
}

pub fn install_bundler_gems(config GemSetupBundlerConfig, mut state GemSetupState,
	runner GemSetupCommandRunner, inspector GemSetupPackageInspector) !GemSetupBundlerResult {
	original_environment := config.environment.clone()
	plan := plan_install_bundler_gems(config, mut state)!
	mut environment := plan.environment.clone()
	mut commands := []GemSetupCommand{}
	mut warnings := []string{}
	mut errors := []string{}
	mut bundle_installed := false
	mut bootsnap_reset_required := false
	mut install_required := false
	mut vendor_reinstall_required := false
	if plan.skipped {
		return GemSetupBundlerResult{
			environment: environment
			gem_paths: plan.gem_paths
			groups: plan.groups
			skipped_for_tests: true
			paths_restored: !config.setup_path
		}
	}
	if !state.bundle_installed_groups_set || state.bundle_installed_groups != plan.groups {
		check := gem_setup_run_bundle(GemSetupCommand{
			executable: plan.bundle
			arguments: ['check']
			environment: environment
		}, runner, mut commands)!
		check_output := '${check.stdout}${check.stderr}'
		// for some reason sometimes the exit code lies so check the output too.
		install_required = !check.success || check_output.contains('Install missing gems')
		vendor_reinstall_required = gem_setup_vendor_reinstall(config, mut state, inspector)!
		install_required = install_required || vendor_reinstall_required
		if install_required {
			installed := gem_setup_run_bundle(GemSetupCommand{
				executable: plan.bundle
				arguments: ['install']
				environment: environment
				redirect_stdout_to_stderr: true
				run_as_real_uid: true
			}, runner, mut commands)!
			bundle_installed = installed.success
			bootsnap_reset_required = bundle_installed
			if !bundle_installed {
				message := 'failed to run `${plan.bundle} install`!\n'
				if config.only_warn_on_failure {
					warnings << gem_setup_opoo(message).text
				} else {
					errors << gem_setup_odie(message).text
				}
			}
		} else {
			cleaned := gem_setup_run_bundle(GemSetupCommand{
				executable: plan.bundle
				arguments: ['clean']
				environment: environment
				redirect_stdout_to_stderr: true
			}, runner, mut commands)!
			bundle_installed = cleaned.success
			if !bundle_installed {
				message := 'failed to run `${plan.bundle} clean`!\n'
				if config.only_warn_on_failure {
					warnings << gem_setup_opoo(message).text
				} else {
					errors << gem_setup_odie(message).text
				}
			}
		}
		if bundle_installed {
			gem_setup_write_user_gem_groups(config.gem_groups_file, plan.groups, mut state)!
			state.bundle_installed_groups = plan.groups.clone()
			state.bundle_installed_groups_set = true
		}
	}
	setup_again := setup_gem_environment(GemSetupEnvironmentConfig{
		environment: environment
		paths: config.paths
	})!
	environment = setup_again.environment.clone()
	if !config.setup_path {
		// Reset the paths. We need to have at least temporarily changed them while invoking `bundle`.
		gem_setup_restore_paths(mut environment, original_environment)
	}
	return GemSetupBundlerResult{
		environment: environment
		gem_paths: setup_again.gem_paths
		groups: plan.groups
		commands: commands
		warnings: warnings
		errors: errors
		bundle_installed: bundle_installed
		bundle_install_required: install_required
		vendor_reinstall_required: vendor_reinstall_required
		bootsnap_reset_required: bootsnap_reset_required
		paths_restored: !config.setup_path
	}
}

fn gem_setup_definition_value(definition GemSetupBundlerDefinition) brew_runtime.Value {
	return brew_runtime.map_value({
		'groups':       brew_runtime.string_array_value(definition.groups)
		'locked_specs': brew_runtime.string_array_value(definition.locked_specs.map(it.full_name))
	})
}

fn gem_setup_environment_result_value(result GemSetupEnvironmentResult) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for key, value in result.environment {
		environment[key] = brew_runtime.string_value(value)
	}
	mut gem_paths := map[string]brew_runtime.Value{}
	for key, value in result.gem_paths {
		gem_paths[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'environment': brew_runtime.map_value(environment)
		'gem_paths':   brew_runtime.map_value(gem_paths)
		'gem_home':    brew_runtime.string_value(result.gem_home)
		'gem_cache':   brew_runtime.string_value(result.gem_cache)
	})
}

fn gem_setup_string_map_from_value(value brew_runtime.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in value.map_data {
		result[key] = item.as_string()
	}
	return result
}

fn gem_setup_paths_from_value(value brew_runtime.Value) GemSetupPaths {
	values := value.map_data.clone()
	return GemSetupPaths{
		library: (values['library'] or { brew_runtime.string_value('') }).as_string()
		ruby_version: (values['ruby_version'] or { brew_runtime.string_value('') }).as_string()
		ruby_prefix: (values['ruby_prefix'] or { brew_runtime.string_value('') }).as_string()
		gem_bindir: (values['gem_bindir'] or { brew_runtime.string_value('') }).as_string()
		rubygems_version: (values['rubygems_version'] or { brew_runtime.string_value('2.2.0') }).as_string()
	}
}

fn gem_setup_definition_from_value(value brew_runtime.Value) GemSetupBundlerDefinition {
	groups := (value.map_data['groups'] or { brew_runtime.string_array_value([]string{}) }).as_string_array() or {
		[]string{}
	}
	locked := (value.map_data['locked_specs'] or { brew_runtime.string_array_value([]string{}) }).as_string_array() or {
		[]string{}
	}
	return GemSetupBundlerDefinition{
		groups: groups
		locked_specs: locked.map(GemSetupLockedSpec{ full_name: it })
	}
}

// Ruby method `self.gemfile` at line 29.
pub fn ruby_gem_setup_l29_d1_self_gemfile(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return gem_setup_error_value('KeyError', 'key not found: HOMEBREW_LIBRARY')
	}
	return brew_runtime.string_value(gem_setup_gemfile(args[0].as_string()))
}

// Ruby method `self.bundler_definition` at line 34.
pub fn ruby_gem_setup_l34_d2_self_bundler_definition(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return gem_setup_error_value('ArgumentError', 'bundler definition is required')
	}
	mut state := GemSetupState{}
	return gem_setup_definition_value(gem_setup_bundler_definition(mut state, gem_setup_definition_from_value(args[0])))
}

// Ruby method `self.valid_gem_groups` at line 39.
pub fn ruby_gem_setup_l39_d3_self_valid_gem_groups(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([]string{})
	}
	definition := if args[0].type_name == 'Hash' {
		gem_setup_definition_from_value(args[0])
	} else {
		GemSetupBundlerDefinition{ groups: args[0].as_string_array() or { []string{} } }
	}
	return brew_runtime.string_array_value(gem_setup_valid_gem_groups(definition))
}

// Ruby method `self.ruby_bindir` at line 50.
pub fn ruby_gem_setup_l50_d4_self_ruby_bindir(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return gem_setup_error_value('ArgumentError', 'Ruby prefix is required')
	}
	return brew_runtime.string_value(gem_setup_ruby_bindir(args[0].as_string()))
}

// Ruby method `self.ohai_if_defined(message)` at line 54.
pub fn ruby_gem_setup_l54_d5_self_ohai_if_defined(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return gem_setup_error_value('ArgumentError', 'message is required')
	}
	return brew_runtime.string_value(gem_setup_ohai(args[0].as_string()).text)
}

// Ruby method `self.opoo_if_defined(message)` at line 62.
pub fn ruby_gem_setup_l62_d6_self_opoo_if_defined(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return gem_setup_error_value('ArgumentError', 'message is required')
	}
	return brew_runtime.string_value(gem_setup_opoo(args[0].as_string()).text)
}

// Ruby method `self.odie_if_defined(message)` at line 70.
pub fn ruby_gem_setup_l70_d7_self_odie_if_defined(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return gem_setup_error_value('ArgumentError', 'message is required')
	}
	message := gem_setup_odie(args[0].as_string())
	return brew_runtime.structured_value('SystemExit', message.text, {
		'status': message.exit_code.str()
	})
}

// Ruby method `self.setup_gem_environment!(setup_path: true)` at line 79.
pub fn ruby_gem_setup_l79_d8_self_setup_gem_environment(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return gem_setup_error_value('ArgumentError', 'gem environment config is required')
	}
	values := args[0].map_data.clone()
	environment_value := values['environment'] or { brew_runtime.map_value({}) }
	paths_value := values['paths'] or { brew_runtime.map_value({}) }
	setup_path := (values['setup_path'] or { brew_runtime.bool_value(true) }).as_bool() or { true }
	result := setup_gem_environment(GemSetupEnvironmentConfig{
		environment: gem_setup_string_map_from_value(environment_value)
		paths: gem_setup_paths_from_value(paths_value)
		setup_path: setup_path
	}) or { return gem_setup_error_value('RuntimeError', err.msg()) }
	return gem_setup_environment_result_value(result)
}

// Ruby method `self.install_gem!(name, version: nil, setup_gem_environment: true)` at line 115.
pub fn ruby_gem_setup_l115_d9_self_install_gem(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return gem_setup_error_value('ArgumentError', 'gem name is required')
	}
	return brew_runtime.map_value({
		'name':                  brew_runtime.string_value(args[0].as_string())
		'version':               if args.len > 1 { args[1] } else { gem_setup_nil_value() }
		'setup_gem_environment': if args.len > 2 { args[2] } else { brew_runtime.bool_value(true) }
		'operation':             brew_runtime.string_value('find_or_install_and_prepend_load_paths')
	})
}

// Ruby method `self.find_in_path(executable)` at line 142.
pub fn ruby_gem_setup_l142_d10_self_find_in_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return gem_setup_nil_value()
	}
	path := gem_setup_find_in_path(args[0].as_string(), args[1].as_string()) or {
		return gem_setup_nil_value()
	}
	return brew_runtime.string_value(path)
}

// Ruby method `self.user_gem_groups` at line 149.
pub fn ruby_gem_setup_l149_d11_self_user_gem_groups(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([]string{})
	}
	mut state := GemSetupState{}
	groups := gem_setup_user_gem_groups(args[0].as_string(), mut state) or {
		return gem_setup_error_value('IOError', err.msg())
	}
	return brew_runtime.string_array_value(groups)
}

// Ruby method `self.write_user_gem_groups(groups)` at line 158.
pub fn ruby_gem_setup_l158_d12_self_write_user_gem_groups(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return gem_setup_error_value('ArgumentError', 'path and groups are required')
	}
	groups := args[1].as_string_array() or {
		return gem_setup_error_value('TypeError', err.msg())
	}
	mut state := GemSetupState{}
	gem_setup_write_user_gem_groups(args[0].as_string(), groups, mut state) or {
		return gem_setup_error_value('IOError', err.msg())
	}
	return brew_runtime.string_array_value(groups)
}

// Ruby method `self.forget_user_gem_groups!` at line 181.
pub fn ruby_gem_setup_l181_d13_self_forget_user_gem_groups(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return gem_setup_error_value('ArgumentError', 'gem groups path is required')
	}
	mut state := GemSetupState{}
	gem_setup_forget_user_gem_groups(args[0].as_string(), mut state) or {
		return gem_setup_error_value('IOError', err.msg())
	}
	return brew_runtime.string_array_value([]string{})
}

// Ruby method `self.user_vendor_version` at line 186.
pub fn ruby_gem_setup_l186_d14_self_user_vendor_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.int_value(0)
	}
	mut state := GemSetupState{}
	version := gem_setup_user_vendor_version(args[0].as_string(), mut state) or {
		return gem_setup_error_value('IOError', err.msg())
	}
	return brew_runtime.int_value(version)
}

// Ruby method `self.install_bundler_gems!(only_warn_on_failure: false, setup_path: true, groups: [])` at line 195.
pub fn ruby_gem_setup_l195_d15_self_install_bundler_gems(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return gem_setup_error_value('ArgumentError', 'bundler config is required')
	}
	values := args[0].map_data.clone()
	paths := gem_setup_paths_from_value(values['paths'] or { brew_runtime.map_value({}) })
	environment := gem_setup_string_map_from_value(values['environment'] or {
		brew_runtime.map_value({})
	})
	definition := gem_setup_definition_from_value(values['definition'] or {
		brew_runtime.map_value({})
	})
	groups := (values['groups'] or { brew_runtime.string_array_value([]string{}) }).as_string_array() or {
		[]string{}
	}
	mut state := GemSetupState{}
	plan := plan_install_bundler_gems(GemSetupBundlerConfig{
		environment: environment
		paths: paths
		gem_groups_file: (values['gem_groups_file'] or { brew_runtime.string_value('') }).as_string()
		vendor_version_file: (values['vendor_version_file'] or { brew_runtime.string_value('') }).as_string()
		gem_dir: (values['gem_dir'] or { brew_runtime.string_value('') }).as_string()
		definition: definition
		groups: groups
		only_warn_on_failure: (values['only_warn_on_failure'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
		setup_path: (values['setup_path'] or { brew_runtime.bool_value(true) }).as_bool() or { true }
	}, mut state) or { return gem_setup_error_value('ArgumentError', err.msg()) }
	mut plan_environment := map[string]brew_runtime.Value{}
	for key, value in plan.environment {
		plan_environment[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'environment': brew_runtime.map_value(plan_environment)
		'groups':      brew_runtime.string_array_value(plan.groups)
		'bundle':      brew_runtime.string_value(plan.bundle)
		'skipped':     brew_runtime.bool_value(plan.skipped)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: true  # rubocop:disable Sorbet/StrictSigil
// 2: # frozen_string_literal: true
// 3:
// 4: # Never `require` anything in this file (except English). It needs to be able to
// 5: # work as the first item in `brew.rb` so we can load gems with Bundler when
// 6: # needed before anything else is loaded (e.g. `json`).
// 7:
// 8: Homebrew::FastBootRequire.from_rubylibdir("English")
// 9:
// 10: module Homebrew
// 11:   # Bump this whenever a committed vendored gem is later added to or exclusion removed from gitignore.
// 12:   # This will trigger it to reinstall properly if `brew install-bundler-gems` needs it.
// 13:   VENDOR_VERSION = 9
// 14:   private_constant :VENDOR_VERSION
// 15:
// 16:   RUBY_BUNDLE_VENDOR_DIRECTORY = (HOMEBREW_LIBRARY_PATH/"vendor/bundle/ruby").freeze
// 17:   private_constant :RUBY_BUNDLE_VENDOR_DIRECTORY
// 18:
// 19:   # This is tracked across Ruby versions.
// 20:   GEM_GROUPS_FILE = (RUBY_BUNDLE_VENDOR_DIRECTORY/".homebrew_gem_groups").freeze
// 21:   private_constant :GEM_GROUPS_FILE
// 22:
// 23:   # This is tracked per Ruby version.
// 24:   VENDOR_VERSION_FILE = (
// 25:     RUBY_BUNDLE_VENDOR_DIRECTORY/"#{RbConfig::CONFIG["ruby_version"]}/.homebrew_vendor_version"
// 26:   ).freeze
// 27:   private_constant :VENDOR_VERSION_FILE
// 28:
// 29:   def self.gemfile
// 30:     File.join(ENV.fetch("HOMEBREW_LIBRARY"), "Homebrew", "Gemfile")
// 31:   end
// 32:   private_class_method :gemfile
// 33:
// 34:   def self.bundler_definition
// 35:     @bundler_definition ||= Bundler::Definition.build(Bundler.default_gemfile, Bundler.default_lockfile, false)
// 36:   end
// 37:   private_class_method :bundler_definition
// 38:
// 39:   def self.valid_gem_groups
// 40:     require "bundler"
// 41:
// 42:     Bundler.with_unbundled_env do
// 43:       ENV["BUNDLE_GEMFILE"] = gemfile
// 44:       groups = bundler_definition.groups
// 45:       groups.delete(:default)
// 46:       groups.map(&:to_s)
// 47:     end
// 48:   end
// 49:
// 50:   def self.ruby_bindir
// 51:     "#{RbConfig::CONFIG["prefix"]}/bin"
// 52:   end
// 53:
// 54:   def self.ohai_if_defined(message)
// 55:     if defined?(ohai)
// 56:       ohai message
// 57:     else
// 58:       $stderr.puts "==> #{message}"
// 59:     end
// 60:   end
// 61:
// 62:   def self.opoo_if_defined(message)
// 63:     if defined?(opoo)
// 64:       opoo message
// 65:     else
// 66:       $stderr.puts "Warning: #{message}"
// 67:     end
// 68:   end
// 69:
// 70:   def self.odie_if_defined(message)
// 71:     if defined?(odie)
// 72:       odie message
// 73:     else
// 74:       $stderr.puts "Error: #{message}"
// 75:       exit 1
// 76:     end
// 77:   end
// 78:
// 79:   def self.setup_gem_environment!(setup_path: true)
// 80:     require "rubygems"
// 81:     raise "RubyGems too old!" if Gem::Version.new(Gem::VERSION) < Gem::Version.new("2.2.0")
// 82:
// 83:     ENV["BUNDLER_NO_OLD_RUBYGEMS_WARNING"] = "1"
// 84:
// 85:     # Match where our bundler gems are.
// 86:     gem_home = "#{RUBY_BUNDLE_VENDOR_DIRECTORY}/#{RbConfig::CONFIG["ruby_version"]}"
// 87:     homebrew_cache = ENV.fetch("HOMEBREW_CACHE", nil)
// 88:     gem_cache = "#{homebrew_cache}/gem-spec-cache" if homebrew_cache
// 89:
// 90:     Gem.paths = {
// 91:       "GEM_HOME"       => gem_home,
// 92:       "GEM_PATH"       => gem_home,
// 93:       "GEM_SPEC_CACHE" => gem_cache,
// 94:     }.compact
// 95:
// 96:     # Set TMPDIR so Xcode's `make` doesn't fall back to `/var/tmp/`,
// 97:     # which may be not user-writable.
// 98:     ENV["TMPDIR"] = ENV.fetch("HOMEBREW_TEMP", nil)
// 99:
// 100:     return unless setup_path
// 101:
// 102:     # Add necessary Ruby and Gem binary directories to `PATH`.
// 103:     paths = ENV.fetch("PATH").split(":")
// 104:     paths.unshift(ruby_bindir) unless paths.include?(ruby_bindir)
// 105:     paths.unshift(Gem.bindir) unless paths.include?(Gem.bindir)
// 106:     ENV["PATH"] = paths.compact.join(":")
// 107:
// 108:     # Set envs so the above binaries can be invoked.
// 109:     # We don't do this unless requested as some formulae may invoke system Ruby instead of ours.
// 110:     ENV["GEM_HOME"] = gem_home
// 111:     ENV["GEM_PATH"] = gem_home
// 112:     ENV["GEM_SPEC_CACHE"] = gem_cache if gem_cache
// 113:   end
// 114:
// 115:   def self.install_gem!(name, version: nil, setup_gem_environment: true)
// 116:     setup_gem_environment! if setup_gem_environment
// 117:
// 118:     specs = Gem::Specification.find_all_by_name(name, version)
// 119:
// 120:     if specs.empty?
// 121:       ohai_if_defined "Installing '#{name}' gem"
// 122:       # `document: []` is equivalent to --no-document
// 123:       # `build_args: []` stops ARGV being used as a default
// 124:       # `env_shebang: true` makes shebangs generic to allow switching between system and Portable Ruby
// 125:       specs = Gem.install name, version, document: [], build_args: [], env_shebang: true
// 126:     end
// 127:
// 128:     specs += specs.flat_map(&:runtime_dependencies)
// 129:                   .flat_map(&:to_specs)
// 130:
// 131:     # Add the specs to the $LOAD_PATH.
// 132:     specs.each do |spec|
// 133:       spec.require_paths.each do |path|
// 134:         full_path = File.join(spec.full_gem_path, path)
// 135:         $LOAD_PATH.unshift full_path unless $LOAD_PATH.include?(full_path)
// 136:       end
// 137:     end
// 138:   rescue Gem::UnsatisfiableDependencyError
// 139:     odie_if_defined "failed to install the '#{name}' gem."
// 140:   end
// 141:
// 142:   def self.find_in_path(executable)
// 143:     ENV.fetch("PATH").split(":").find do |path|
// 144:       File.executable?(File.join(path, executable))
// 145:     end
// 146:   end
// 147:   private_class_method :find_in_path
// 148:
// 149:   def self.user_gem_groups
// 150:     @user_gem_groups ||= if GEM_GROUPS_FILE.exist?
// 151:       GEM_GROUPS_FILE.readlines(chomp: true)
// 152:     else
// 153:       []
// 154:     end
// 155:   end
// 156:   private_class_method :user_gem_groups
// 157:
// 158:   def self.write_user_gem_groups(groups)
// 159:     return if @user_gem_groups == groups && GEM_GROUPS_FILE.exist?
// 160:
// 161:     # Write the file atomically, in case we're working parallel
// 162:     require "tempfile"
// 163:     tmpfile = Tempfile.new([GEM_GROUPS_FILE.basename.to_s, "~"], GEM_GROUPS_FILE.dirname)
// 164:     path = tmpfile.path
// 165:     return if path.nil?
// 166:
// 167:     require "fileutils"
// 168:     begin
// 169:       FileUtils.chmod("+r", path)
// 170:       tmpfile.write(groups.join("\n"))
// 171:       tmpfile.close
// 172:       File.rename(path, GEM_GROUPS_FILE)
// 173:     ensure
// 174:       tmpfile.unlink
// 175:     end
// 176:
// 177:     @user_gem_groups = groups
// 178:   end
// 179:   private_class_method :write_user_gem_groups
// 180:
// 181:   def self.forget_user_gem_groups!
// 182:     GEM_GROUPS_FILE.truncate(0) if GEM_GROUPS_FILE.exist?
// 183:     @user_gem_groups = []
// 184:   end
// 185:
// 186:   def self.user_vendor_version
// 187:     @user_vendor_version ||= if VENDOR_VERSION_FILE.exist?
// 188:       VENDOR_VERSION_FILE.read.to_i
// 189:     else
// 190:       0
// 191:     end
// 192:   end
// 193:   private_class_method :user_vendor_version
// 194:
// 195:   def self.install_bundler_gems!(only_warn_on_failure: false, setup_path: true, groups: [])
// 196:     old_path = ENV.fetch("PATH", nil)
// 197:     old_gem_path = ENV.fetch("GEM_PATH", nil)
// 198:     old_gem_home = ENV.fetch("GEM_HOME", nil)
// 199:     old_gem_spec_cache = ENV.fetch("GEM_SPEC_CACHE", nil)
// 200:     old_bundle_gemfile = ENV.fetch("BUNDLE_GEMFILE", nil)
// 201:     old_bundle_with = ENV.fetch("BUNDLE_WITH", nil)
// 202:     old_bundle_frozen = ENV.fetch("BUNDLE_FROZEN", nil)
// 203:
// 204:     invalid_groups = groups - valid_gem_groups
// 205:     raise ArgumentError, "Invalid gem groups: #{invalid_groups.join(", ")}" unless invalid_groups.empty?
// 206:
// 207:     setup_gem_environment!
// 208:     # Tests should not modify the state of the repository.
// 209:     return if ENV["HOMEBREW_TESTS"]
// 210:
// 211:     # Combine the passed groups with the ones stored in settings.
// 212:     groups |= (user_gem_groups & valid_gem_groups)
// 213:     groups.sort!
// 214:
// 215:     if (homebrew_bundle_user_cache = ENV.fetch("HOMEBREW_BUNDLE_USER_CACHE", nil))
// 216:       ENV["BUNDLE_USER_CACHE"] = homebrew_bundle_user_cache
// 217:     end
// 218:     ENV["BUNDLE_GEMFILE"] = gemfile
// 219:     ENV["BUNDLE_WITH"] = groups.join(" ")
// 220:     ENV["BUNDLE_FROZEN"] = "true"
// 221:
// 222:     if @bundle_installed_groups != groups
// 223:       bundle = File.join(find_in_path("bundle"), "bundle")
// 224:       bundle_check_output = `#{bundle} check 2>&1`
// 225:       bundle_check_failed = !$CHILD_STATUS.success?
// 226:
// 227:       # for some reason sometimes the exit code lies so check the output too.
// 228:       bundle_install_required = bundle_check_failed || bundle_check_output.include?("Install missing gems")
// 229:
// 230:       if user_vendor_version != VENDOR_VERSION
// 231:         # Check if the install is intact. This is useful if any gems are added to gitignore.
// 232:         # We intentionally map over everything and then call `any?` so that we remove the spec of each bad gem.
// 233:         specs = bundler_definition.resolve.materialize(bundler_definition.locked_dependencies)
// 234:         vendor_reinstall_required = specs.map do |spec|
// 235:           spec_file = "#{Gem.dir}/specifications/#{spec.full_name}.gemspec"
// 236:           next false unless File.exist?(spec_file)
// 237:
// 238:           cache_file = "#{Gem.dir}/cache/#{spec.full_name}.gem"
// 239:           if File.exist?(cache_file)
// 240:             require "rubygems/package"
// 241:             package = Gem::Package.new(cache_file)
// 242:
// 243:             package_install_intact = begin
// 244:               contents = package.contents
// 245:
// 246:               # If the gem has contents, ensure we have every file installed it contains.
// 247:               contents&.all? do |gem_file|
// 248:                 File.exist?("#{Gem.dir}/gems/#{spec.full_name}/#{gem_file}")
// 249:               end
// 250:             rescue Gem::Package::Error, Gem::Security::Exception
// 251:               # Malformed, assume broken
// 252:               File.unlink(cache_file)
// 253:               false
// 254:             end
// 255:
// 256:             next false if package_install_intact
// 257:           end
// 258:
// 259:           # Mark gem for reinstallation
// 260:           File.unlink(spec_file)
// 261:           true
// 262:         end.any?
// 263:
// 264:         VENDOR_VERSION_FILE.dirname.mkpath
// 265:         VENDOR_VERSION_FILE.write(VENDOR_VERSION.to_s)
// 266:
// 267:         bundle_install_required ||= vendor_reinstall_required
// 268:       end
// 269:
// 270:       bundle_installed = if bundle_install_required
// 271:         Process.wait(fork do
// 272:           # Native build scripts fail if EUID != UID
// 273:           Process::UID.change_privilege(Process.euid) if Process.euid != Process.uid
// 274:           exec bundle, "install", out: :err
// 275:         end)
// 276:         if $CHILD_STATUS.success?
// 277:           Homebrew::Bootsnap.reset! if defined?(Homebrew::Bootsnap) # Gem install can run before Bootsnap loads
// 278:           true
// 279:         else
// 280:           message = <<~EOS
// 281:             failed to run `#{bundle} install`!
// 282:           EOS
// 283:           if only_warn_on_failure
// 284:             opoo_if_defined message
// 285:           else
// 286:             odie_if_defined message
// 287:           end
// 288:           false
// 289:         end
// 290:       elsif system bundle, "clean", out: :err # even if we have nothing to install, we may have removed gems
// 291:         true
// 292:       else
// 293:         message = <<~EOS
// 294:           failed to run `#{bundle} clean`!
// 295:         EOS
// 296:         if only_warn_on_failure
// 297:           opoo_if_defined message
// 298:         else
// 299:           odie_if_defined message
// 300:         end
// 301:         false
// 302:       end
// 303:
// 304:       if bundle_installed
// 305:         write_user_gem_groups(groups)
// 306:         @bundle_installed_groups = groups
// 307:       end
// 308:     end
// 309:
// 310:     setup_gem_environment!
// 311:   ensure
// 312:     unless setup_path
// 313:       # Reset the paths. We need to have at least temporarily changed them while invoking `bundle`.
// 314:       ENV["PATH"] = old_path
// 315:       ENV["GEM_PATH"] = old_gem_path
// 316:       ENV["GEM_HOME"] = old_gem_home
// 317:       ENV["GEM_SPEC_CACHE"] = old_gem_spec_cache
// 318:       ENV["BUNDLE_GEMFILE"] = old_bundle_gemfile
// 319:       ENV["BUNDLE_WITH"] = old_bundle_with
// 320:       ENV["BUNDLE_FROZEN"] = old_bundle_frozen
// 321:     end
// 322:   end
// 323: end
