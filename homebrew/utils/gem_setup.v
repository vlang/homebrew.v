module utils

import ruby
import os
import time

// Translated from Homebrew/brew `utils/gem_setup.rb`.

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

fn gem_setup_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn gem_setup_error_value(type_name string, message string) ruby.Value {
	return ruby.object_value(type_name, message)
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

fn gem_setup_definition_value(definition GemSetupBundlerDefinition) ruby.Value {
	return ruby.map_value({
		'groups':       ruby.string_array_value(definition.groups)
		'locked_specs': ruby.string_array_value(definition.locked_specs.map(it.full_name))
	})
}

fn gem_setup_environment_result_value(result GemSetupEnvironmentResult) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for key, value in result.environment {
		environment[key] = ruby.string_value(value)
	}
	mut gem_paths := map[string]ruby.Value{}
	for key, value in result.gem_paths {
		gem_paths[key] = ruby.string_value(value)
	}
	return ruby.map_value({
		'environment': ruby.map_value(environment)
		'gem_paths':   ruby.map_value(gem_paths)
		'gem_home':    ruby.string_value(result.gem_home)
		'gem_cache':   ruby.string_value(result.gem_cache)
	})
}

fn gem_setup_string_map_from_value(value ruby.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in value.map_data {
		result[key] = item.as_string()
	}
	return result
}

fn gem_setup_paths_from_value(value ruby.Value) GemSetupPaths {
	values := value.map_data.clone()
	return GemSetupPaths{
		library: (values['library'] or { ruby.string_value('') }).as_string()
		ruby_version: (values['ruby_version'] or { ruby.string_value('') }).as_string()
		ruby_prefix: (values['ruby_prefix'] or { ruby.string_value('') }).as_string()
		gem_bindir: (values['gem_bindir'] or { ruby.string_value('') }).as_string()
		rubygems_version: (values['rubygems_version'] or { ruby.string_value('2.2.0') }).as_string()
	}
}

fn gem_setup_definition_from_value(value ruby.Value) GemSetupBundlerDefinition {
	groups := (value.map_data['groups'] or { ruby.string_array_value([]string{}) }).as_string_array() or {
		[]string{}
	}
	locked := (value.map_data['locked_specs'] or { ruby.string_array_value([]string{}) }).as_string_array() or {
		[]string{}
	}
	return GemSetupBundlerDefinition{
		groups: groups
		locked_specs: locked.map(GemSetupLockedSpec{ full_name: it })
	}
}
