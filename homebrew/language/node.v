module language

import ruby
import homebrew.utils
import x.json2

// Translated from Homebrew/brew `language/node.rb`.

pub const node_release_cooldown_days = 1

// NodeEnvironmentState models the module-level env_set guard and the observable
// PATH prepend without mutating the process environment during translation tests.
pub struct NodeEnvironmentState {
pub mut:
	env_set                bool
	node_formula_available bool
	node_opt_libexec       string
	path_entries           []string
	prepend_calls          int
}

pub struct NpmPackResult {
pub:
	stdout    string
	exit_code int
}

pub type NpmPackRunner = fn (command []string, working_directory string) !NpmPackResult

pub struct NodeDependency {
pub:
	name     string
	required bool = true
}

pub fn npm_cache_config(homebrew_cache string) string {
	return 'cache=${ruby.join_path(homebrew_cache.trim_right('/'), 'npm_cache')}'
}

pub fn npm_install_security_args(homebrew_cache string, ignore_scripts bool) []string {
	mut args := [
		'--min-release-age=${node_release_cooldown_days}',
		'--${npm_cache_config(homebrew_cache)}',
	]
	if ignore_scripts {
		args << '--ignore-scripts'
	}
	return args
}

// setup_npm_environment applies the source's guard before attempting to resolve
// Node, so even an unavailable formula is only checked once.
pub fn setup_npm_environment(mut state NodeEnvironmentState) bool {
	if state.env_set {
		return false
	}
	state.env_set = true
	if !state.node_formula_available {
		return false
	}
	path := ruby.join_path(state.node_opt_libexec.trim_right('/'), 'bin')
	mut path_entries := [path]
	path_entries << state.path_entries
	state.path_entries = path_entries
	state.prepend_calls++
	return true
}

// pack_for_installation removes npm lifecycle scripts before invoking the
// injected `npm pack --ignore-scripts` boundary.
pub fn pack_for_installation(working_directory string, runner NpmPackRunner) !string {
	prepare_node_package_json(working_directory)!
	result := runner(['npm', 'pack', '--ignore-scripts'], working_directory)!
	return npm_pack_filename(working_directory, result)
}

pub fn std_npm_install_args(mut environment NodeEnvironmentState, libexec string,
	working_directory string, homebrew_cache string, ignore_scripts bool, effective_uid int,
	runner NpmPackRunner) ![]string {
	setup_npm_environment(mut environment)
	pack := pack_for_installation(working_directory, runner)!
	ruby.make_dir_all(ruby.join_path(libexec, 'lib'))!
	return compose_std_npm_install_args(libexec, working_directory, pack, homebrew_cache, ignore_scripts, effective_uid)
}

pub fn local_npm_install_args(mut environment NodeEnvironmentState, homebrew_cache string,
	ignore_scripts bool) []string {
	setup_npm_environment(mut environment)
	mut args := ['--loglevel=silly', '--build-from-source']
	args << npm_install_security_args(homebrew_cache, ignore_scripts)
	return args
}

pub fn node_shebang_rewrite_info(node_path string) !utils.RewriteInfo {
	return utils.new_shebang_rewrite_info(r'^#! ?(?:/usr/bin/(?:env )?)?node( |$)', '#! /usr/bin/env node '.len, '${node_path}\\1')
}

pub fn detected_node_shebang(dependencies []NodeDependency, prefix string) !utils.RewriteInfo {
	node_dependencies := dependencies.filter(it.required && (it.name == 'node' || it.name.starts_with('node@')))
	if node_dependencies.len == 0 {
		return error('Cannot detect Node shebang: formula does not depend on Node.')
	}
	if node_dependencies.len > 1 {
		return error('Cannot detect Node shebang: formula has multiple Node dependencies.')
	}
	node_path := ruby.join_path(ruby.join_path(ruby.join_path(prefix.trim_right('/'), 'opt'), node_dependencies[0].name), 'bin/node')
	return node_shebang_rewrite_info(node_path)
}

fn default_node_homebrew_cache() string {
	configured := ruby.environment_value('HOMEBREW_CACHE')
	return if configured.len > 0 { configured } else { '/tmp/homebrew-cache' }
}

fn prepare_node_package_json(working_directory string) ! {
	package_path := ruby.join_path(working_directory, 'package.json')
	if !ruby.is_file(package_path) {
		return
	}
	contents := ruby.read_file(package_path)!
	decoded := json2.decode[json2.Any](contents) or {
		return error('Could not parse package.json! ${err}')
	}
	mut package := decoded.as_map()
	scripts_value := package['scripts'] or { return }
	if scripts_value !is map[string]json2.Any {
		return
	}
	mut scripts := scripts_value.as_map()
	mut removed := false
	for name in ['prepare', 'prepack', 'postpack'] {
		if name in scripts {
			scripts.delete(name)
			removed = true
		}
	}
	if removed {
		package['scripts'] = json2.Any(scripts)
		ruby.atomic_write_file(package_path, json2.encode(json2.Any(package)))!
	}
}

fn npm_pack_filename(working_directory string, result NpmPackResult) !string {
	if result.exit_code != 0 || result.stdout.len == 0 {
		return error('npm failed to pack ${working_directory}')
	}
	without_trailing_newlines := result.stdout.trim_right('\r\n')
	lines := without_trailing_newlines.split('\n')
	if lines.len == 0 {
		return error('npm failed to pack ${working_directory}')
	}
	return lines.last().trim_right('\r')
}

fn pack_for_installation_with_result(working_directory string, result NpmPackResult) !string {
	prepare_node_package_json(working_directory)!
	return npm_pack_filename(working_directory, result)
}

fn std_npm_install_args_with_result(mut environment NodeEnvironmentState, libexec string,
	working_directory string, homebrew_cache string, ignore_scripts bool, effective_uid int,
	result NpmPackResult) ![]string {
	setup_npm_environment(mut environment)
	pack := pack_for_installation_with_result(working_directory, result)!
	ruby.make_dir_all(ruby.join_path(libexec, 'lib'))!
	return compose_std_npm_install_args(libexec, working_directory, pack, homebrew_cache, ignore_scripts, effective_uid)
}

fn compose_std_npm_install_args(libexec string, working_directory string, pack string,
	homebrew_cache string, ignore_scripts bool, configured_uid int) []string {
	mut args := ['--loglevel=silly', '--global', '--build-from-source']
	args << npm_install_security_args(homebrew_cache, ignore_scripts)
	args << '--prefix=${libexec}'
	args << ruby.join_path(working_directory, pack)
	effective_uid := if configured_uid >= 0 { configured_uid } else { ruby.effective_uid() }
	if effective_uid == 0 {
		args << '--unsafe-perm'
	}
	return args
}

fn node_environment_state_value(state NodeEnvironmentState) ruby.Value {
	return ruby.structured_value('NodeEnvironmentState', state.env_set.str(), {
		'env_set':                state.env_set.str()
		'node_formula_available': state.node_formula_available.str()
		'node_opt_libexec':       state.node_opt_libexec
		'path_entries':           state.path_entries.join(':')
		'prepend_calls':          state.prepend_calls.str()
	})
}

fn node_environment_state_from_value(value ruby.Value) NodeEnvironmentState {
	if value.type_name != 'NodeEnvironmentState' {
		return NodeEnvironmentState{}
	}
	entries := value.attributes['path_entries'] or { '' }
	return NodeEnvironmentState{
		env_set: (value.attributes['env_set'] or { 'false' }) == 'true'
		node_formula_available: (value.attributes['node_formula_available'] or { 'false' }) == 'true'
		node_opt_libexec: value.attributes['node_opt_libexec'] or { '' }
		path_entries: if entries.len > 0 { entries.split(':') } else { [] }
		prepend_calls: (value.attributes['prepend_calls'] or { '0' }).int()
	}
}

fn node_dependencies_from_value(value ruby.Value) []NodeDependency {
	return value.array_data.map(NodeDependency{
		name: it.attributes['name'] or { it.as_string() }
		required: (it.attributes['required'] or { 'true' }) == 'true'
	})
}
