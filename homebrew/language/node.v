module language

import brew_runtime
import homebrew.utils
import x.json2

// Translated from Homebrew/brew `language/node.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :env_set` at line 17.
pub fn ruby_node_l17_d1_env_set(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', '')
	}
	state := node_environment_state_from_value(args[0])
	return brew_runtime.bool_value(state.env_set)
}

// Ruby attr_accessor `attr_accessor :env_set` at line 17.
pub fn ruby_node_l17_d2_env_set(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 && args[0].type_name == 'NodeEnvironmentState' {
		node_environment_state_from_value(args[0])
	} else {
		NodeEnvironmentState{}
	}
	value_index := if args.len > 1 && args[0].type_name == 'NodeEnvironmentState' { 1 } else { 0 }
	state.env_set = if args.len > value_index {
		args[value_index].as_bool() or { args[value_index].as_string() == 'true' }
	} else {
		false
	}
	return node_environment_state_value(state)
}

// Ruby method `self.npm_cache_config` at line 21.
pub fn ruby_node_l21_d3_self_npm_cache_config(args ...brew_runtime.Value) brew_runtime.Value {
	cache := if args.len > 0 { args[0].as_string() } else { default_node_homebrew_cache() }
	return brew_runtime.string_value(npm_cache_config(cache))
}

// Ruby method `self.npm_install_security_args(ignore_scripts: true)` at line 26.
pub fn ruby_node_l26_d4_self_npm_install_security_args(args ...brew_runtime.Value) brew_runtime.Value {
	mut cache := default_node_homebrew_cache()
	mut ignore_scripts := true
	if args.len > 0 {
		if args[0].type_name == 'Bool' {
			ignore_scripts = args[0].as_bool() or { true }
		} else {
			cache = args[0].as_string()
		}
	}
	if args.len > 1 {
		ignore_scripts = args[1].as_bool() or { true }
	}
	return brew_runtime.string_array_value(npm_install_security_args(cache, ignore_scripts))
}

// Ruby method `self.pack_for_installation` at line 38.
pub fn ruby_node_l38_d5_self_pack_for_installation(args ...brew_runtime.Value) brew_runtime.Value {
	working_directory := if args.len > 0 {
		args[0].as_string()
	} else {
		brew_runtime.current_directory()
	}
	result := NpmPackResult{
		stdout: if args.len > 1 { args[1].as_string() } else { '' }
		exit_code: if args.len > 2 { int(args[2].as_int() or { 0 }) } else { 0 }
	}
	pack := pack_for_installation_with_result(working_directory, result) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.string_value(pack)
}

// Ruby method `self.setup_npm_environment` at line 64.
pub fn ruby_node_l64_d6_self_setup_npm_environment(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 {
		node_environment_state_from_value(args[0])
	} else {
		NodeEnvironmentState{}
	}
	setup_npm_environment(mut state)
	return node_environment_state_value(state)
}

// Ruby method `self.std_npm_install_args(libexec, ignore_scripts: true)` at line 79.
pub fn ruby_node_l79_d7_self_std_npm_install_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'libexec is required')
	}
	libexec := args[0].as_string()
	working_directory := if args.len > 1 {
		args[1].as_string()
	} else {
		brew_runtime.current_directory()
	}
	result := NpmPackResult{
		stdout: if args.len > 2 { args[2].as_string() } else { '' }
		exit_code: if args.len > 3 { int(args[3].as_int() or { 0 }) } else { 0 }
	}
	cache := if args.len > 4 { args[4].as_string() } else { default_node_homebrew_cache() }
	ignore_scripts := if args.len > 5 { args[5].as_bool() or { true } } else { true }
	effective_uid := if args.len > 6 { int(args[6].as_int() or { -1 }) } else { -1 }
	mut state := if args.len > 7 {
		node_environment_state_from_value(args[7])
	} else {
		NodeEnvironmentState{}
	}
	install_args := std_npm_install_args_with_result(mut state, libexec, working_directory, cache, ignore_scripts, effective_uid, result) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.string_array_value(install_args)
}

// Ruby method `self.local_npm_install_args(ignore_scripts: true)` at line 105.
pub fn ruby_node_l105_d8_self_local_npm_install_args(args ...brew_runtime.Value) brew_runtime.Value {
	cache := if args.len > 0 && args[0].type_name != 'Bool' {
		args[0].as_string()
	} else {
		default_node_homebrew_cache()
	}
	ignore_index := if args.len > 0 && args[0].type_name != 'Bool' { 1 } else { 0 }
	ignore_scripts := if args.len > ignore_index {
		args[ignore_index].as_bool() or { true }
	} else {
		true
	}
	mut state := if args.len > ignore_index + 1 {
		node_environment_state_from_value(args[ignore_index + 1])
	} else {
		NodeEnvironmentState{}
	}
	return brew_runtime.string_array_value(local_npm_install_args(mut state, cache, ignore_scripts))
}

// Ruby method `node_shebang_rewrite_info(node_path)` at line 132.
pub fn ruby_node_l132_d9_node_shebang_rewrite_info(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'node path is required')
	}
	info := node_shebang_rewrite_info(args[0].as_string()) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return utils.rewrite_info_value(info)
}

// Ruby method `detected_node_shebang(formula = T.cast(self, Formula))` at line 141.
pub fn ruby_node_l141_d10_detected_node_shebang(args ...brew_runtime.Value) brew_runtime.Value {
	dependencies := if args.len > 0 {
		node_dependencies_from_value(args[0])
	} else {
		[]NodeDependency{}
	}
	prefix := if args.len > 1 { args[1].as_string() } else { '/opt/homebrew' }
	info := detected_node_shebang(dependencies, prefix) or {
		return brew_runtime.object_value('ShebangDetectionError', err.msg())
	}
	return utils.rewrite_info_value(info)
}

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

pub type NpmPackRunner = fn(command []string, working_directory string) !NpmPackResult

pub struct NodeDependency {
pub:
	name     string
	required bool = true
}

pub fn npm_cache_config(homebrew_cache string) string {
	return 'cache=${brew_runtime.join_path(homebrew_cache.trim_right('/'), 'npm_cache')}'
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
	path := brew_runtime.join_path(state.node_opt_libexec.trim_right('/'), 'bin')
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
	brew_runtime.make_dir_all(brew_runtime.join_path(libexec, 'lib'))!
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
	node_path := brew_runtime.join_path(brew_runtime.join_path(brew_runtime.join_path(prefix.trim_right('/'), 'opt'), node_dependencies[0].name), 'bin/node')
	return node_shebang_rewrite_info(node_path)
}

fn default_node_homebrew_cache() string {
	configured := brew_runtime.environment_value('HOMEBREW_CACHE')
	return if configured.len > 0 { configured } else { '/tmp/homebrew-cache' }
}

fn prepare_node_package_json(working_directory string) ! {
	package_path := brew_runtime.join_path(working_directory, 'package.json')
	if !brew_runtime.is_file(package_path) {
		return
	}
	contents := brew_runtime.read_file(package_path)!
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
		brew_runtime.atomic_write_file(package_path, json2.encode(json2.Any(package)))!
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
	brew_runtime.make_dir_all(brew_runtime.join_path(libexec, 'lib'))!
	return compose_std_npm_install_args(libexec, working_directory, pack, homebrew_cache, ignore_scripts, effective_uid)
}

fn compose_std_npm_install_args(libexec string, working_directory string, pack string,
	homebrew_cache string, ignore_scripts bool, configured_uid int) []string {
	mut args := ['--loglevel=silly', '--global', '--build-from-source']
	args << npm_install_security_args(homebrew_cache, ignore_scripts)
	args << '--prefix=${libexec}'
	args << brew_runtime.join_path(working_directory, pack)
	effective_uid := if configured_uid >= 0 { configured_uid } else { brew_runtime.effective_uid() }
	if effective_uid == 0 {
		args << '--unsafe-perm'
	}
	return args
}

fn node_environment_state_value(state NodeEnvironmentState) brew_runtime.Value {
	return brew_runtime.structured_value('NodeEnvironmentState', state.env_set.str(), {
		'env_set':                state.env_set.str()
		'node_formula_available': state.node_formula_available.str()
		'node_opt_libexec':       state.node_opt_libexec
		'path_entries':           state.path_entries.join(':')
		'prepend_calls':          state.prepend_calls.str()
	})
}

fn node_environment_state_from_value(value brew_runtime.Value) NodeEnvironmentState {
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

fn node_dependencies_from_value(value brew_runtime.Value) []NodeDependency {
	return value.array_data.map(NodeDependency{
		name: it.attributes['name'] or { it.as_string() }
		required: (it.attributes['required'] or { 'true' }) == 'true'
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "release_cooldown"
// 5: require "utils/output"
// 6: require "utils/path"
// 7:
// 8: module Language
// 9:   # Helper functions for Node formulae.
// 10:   #
// 11:   # @api public
// 12:   module Node
// 13:     extend ::Utils::Output::Mixin
// 14:
// 15:     class << self
// 16:       sig { returns(T.nilable(T::Boolean)) }
// 17:       attr_accessor :env_set
// 18:     end
// 19:
// 20:     sig { returns(String) }
// 21:     def self.npm_cache_config
// 22:       "cache=#{HOMEBREW_CACHE}/npm_cache"
// 23:     end
// 24:
// 25:     sig { params(ignore_scripts: T::Boolean).returns(T::Array[String]) }
// 26:     def self.npm_install_security_args(ignore_scripts: true)
// 27:       args = %W[
// 28:         --min-release-age=#{Homebrew::RELEASE_COOLDOWN_DAYS}
// 29:         --#{npm_cache_config}
// 30:       ]
// 31:
// 32:       args << "--ignore-scripts" if ignore_scripts
// 33:
// 34:       args
// 35:     end
// 36:
// 37:     sig { returns(String) }
// 38:     def self.pack_for_installation
// 39:       # Homebrew assumes the buildpath/testpath will always be disposable
// 40:       # and from npm 5.0.0 the logic changed so that when a directory is
// 41:       # fed to `npm install` only symlinks are created linking back to that
// 42:       # directory, consequently breaking that assumption. We require a tarball
// 43:       # because npm install creates a "real" installation when fed a tarball.
// 44:       package = Pathname("package.json")
// 45:       if package.exist?
// 46:         begin
// 47:           pkg_json = JSON.parse(package.read)
// 48:         rescue JSON::ParserError
// 49:           opoo "Could not parse package.json!"
// 50:           raise
// 51:         end
// 52:         prepare_removed = pkg_json["scripts"]&.delete("prepare")
// 53:         prepack_removed = pkg_json["scripts"]&.delete("prepack")
// 54:         postpack_removed = pkg_json["scripts"]&.delete("postpack")
// 55:         package.atomic_write(JSON.pretty_generate(pkg_json)) if prepare_removed || prepack_removed || postpack_removed
// 56:       end
// 57:       output = Utils.popen_read("npm", "pack", "--ignore-scripts")
// 58:       raise "npm failed to pack #{Dir.pwd}" if !$CHILD_STATUS.exitstatus.zero? || output.lines.empty?
// 59:
// 60:       output.lines.fetch(-1).chomp
// 61:     end
// 62:
// 63:     sig { void }
// 64:     def self.setup_npm_environment
// 65:       # guard that this is only run once
// 66:       return if @env_set
// 67:
// 68:       @env_set = T.let(true, T.nilable(T::Boolean))
// 69:       # explicitly use our npm and node-gyp executables instead of the user
// 70:       # managed ones in HOMEBREW_PREFIX/lib/node_modules which might be broken
// 71:       begin
// 72:         ENV.prepend_path "PATH", Formula["node"].opt_libexec/"bin"
// 73:       rescue FormulaUnavailableError
// 74:         nil
// 75:       end
// 76:     end
// 77:
// 78:     sig { params(libexec: Pathname, ignore_scripts: T::Boolean).returns(T::Array[String]) }
// 79:     def self.std_npm_install_args(libexec, ignore_scripts: true)
// 80:       setup_npm_environment
// 81:
// 82:       pack = pack_for_installation
// 83:
// 84:       # npm 7 requires that these dirs exist before install
// 85:       (libexec/"lib").mkpath
// 86:
// 87:       # npm install args for global style module format installed into libexec
// 88:       # Delay packages published in the last day so builds are less likely to
// 89:       # install a freshly compromised npm release or dependency.
// 90:       args = %w[
// 91:         --loglevel=silly
// 92:         --global
// 93:         --build-from-source
// 94:       ] + npm_install_security_args(ignore_scripts:) + %W[
// 95:         --prefix=#{libexec}
// 96:         #{Dir.pwd}/#{pack}
// 97:       ]
// 98:
// 99:       args << "--unsafe-perm" if Process.uid.zero?
// 100:
// 101:       args
// 102:     end
// 103:
// 104:     sig { params(ignore_scripts: T::Boolean).returns(T::Array[String]) }
// 105:     def self.local_npm_install_args(ignore_scripts: true)
// 106:       setup_npm_environment
// 107:       # npm install args for local style module format
// 108:       # Delay packages published in the last day so builds are less likely to
// 109:       # install a freshly compromised npm release or dependency.
// 110:       %w[
// 111:         --loglevel=silly
// 112:         --build-from-source
// 113:       ] + npm_install_security_args(ignore_scripts:)
// 114:     end
// 115:
// 116:     # Mixin module for {Formula} adding shebang rewrite features.
// 117:     module Shebang
// 118:       extend T::Helpers
// 119:
// 120:       requires_ancestor { Formula }
// 121:
// 122:       module_function
// 123:
// 124:       # A regex to match potential shebang permutations.
// 125:       NODE_SHEBANG_REGEX = %r{\A#! ?(?:/usr/bin/(?:env )?)?node( |$)}
// 126:
// 127:       # The length of the longest shebang matching `SHEBANG_REGEX`.
// 128:       NODE_SHEBANG_MAX_LENGTH = T.let("#! /usr/bin/env node ".length, Integer)
// 129:
// 130:       # @private
// 131:       sig { params(node_path: T.any(String, Pathname)).returns(Utils::Shebang::RewriteInfo) }
// 132:       def node_shebang_rewrite_info(node_path)
// 133:         Utils::Shebang::RewriteInfo.new(
// 134:           NODE_SHEBANG_REGEX,
// 135:           NODE_SHEBANG_MAX_LENGTH,
// 136:           "#{node_path}\\1",
// 137:         )
// 138:       end
// 139:
// 140:       sig { params(formula: Formula).returns(Utils::Shebang::RewriteInfo) }
// 141:       def detected_node_shebang(formula = T.cast(self, Formula))
// 142:         node_deps = formula.deps.select(&:required?).map(&:name).grep(/^node(@.+)?$/)
// 143:         raise ShebangDetectionError.new("Node", "formula does not depend on Node") if node_deps.empty?
// 144:         raise ShebangDetectionError.new("Node", "formula has multiple Node dependencies") if node_deps.length > 1
// 145:
// 146:         node_shebang_rewrite_info(Utils::Path.formula_opt_bin(node_deps.first)/"node")
// 147:       end
// 148:     end
// 149:   end
// 150: end
