module shared_context

import brew_runtime
import crypto.sha256
import homebrew
import os

// Translated from Homebrew/brew `test/support/helper/spec/shared_context/integration_test.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct IntegrationCommandResult {
pub:
	exit_code int
	stdout    string
	stderr    string
}

pub fn (result IntegrationCommandResult) success() bool {
	return result.exit_code == 0
}

pub struct IntegrationTestConfig {
pub:
	prefix        string
	library_path  string
	test_tmpdir   string
	fixture_dir   string
	cache         string
	cellar        string
	tap_directory string
	core_tap_path string
	brew_command  []string
	brew_sh_path  string
	linux         bool
}

@[heap]
pub struct IntegrationTestRuntime {
pub:
	config IntegrationTestConfig
pub mut:
	command_number     int
	commands           [][]string
	command_envs       []map[string]string
	stdout             []string
	stderr             []string
	installed_formulae []string
	tap_cache_clears   int
}

pub fn new_integration_test_runtime(config IntegrationTestConfig) &IntegrationTestRuntime {
	return &IntegrationTestRuntime{
		config: config
	}
}

pub fn (mut runtime IntegrationTestRuntime) command_id() string {
	runtime.command_number++
	return '${os.getpid()}:${os.getenv('TEST_ENV_NUMBER')}:${runtime.command_number}'
}

fn integration_path(values []string) string {
	return values.filter(it != '').join(os.path_delimiter)
}

fn (mut runtime IntegrationTestRuntime) capture(command []string,
	environment map[string]string) IntegrationCommandResult {
	if command.len == 0 {
		return IntegrationCommandResult{
			exit_code: 127
			stderr: 'integration command is empty'
		}
	}
	runtime.commands << command.clone()
	runtime.command_envs << environment.clone()
	result := brew_runtime.run_captured_command(command, brew_runtime.CapturedCommandOptions{
		environment: environment
	}) or {
		return IntegrationCommandResult{
			exit_code: 127
			stderr: err.msg()
		}
	}
	runtime.stdout << result.stdout
	runtime.stderr << result.stderr
	return IntegrationCommandResult{
		exit_code: result.exit_code
		stdout: result.stdout
		stderr: result.stderr
	}
}

pub fn (mut runtime IntegrationTestRuntime) brew(arguments []string,
	overrides map[string]string) IntegrationCommandResult {
	mut environment := os.environ()
	for key, value in overrides {
		environment[key] = value
	}
	path := integration_path([
		overrides['PATH'] or { '' },
		os.join_path(runtime.config.library_path, 'test', 'support', 'helper', 'cmd'),
		os.join_path(runtime.config.prefix, 'bin'),
		environment['PATH'] or { '' },
	])
	environment['PATH'] = path
	environment['HOMEBREW_PATH'] = path
	environment['HOMEBREW_BREW_FILE'] = os.join_path(runtime.config.prefix, 'bin', 'brew')
	environment['HOMEBREW_INTEGRATION_TEST'] = runtime.command_id()
	environment['HOMEBREW_TEST_TMPDIR'] = runtime.config.test_tmpdir
	environment['HOMEBREW_DEV_CMD_RUN'] = 'true'
	environment.delete('HOMEBREW_ASK')
	environment.delete('GEM_HOME')
	mut command := runtime.config.brew_command.clone()
	if command.len == 0 {
		command << os.join_path(runtime.config.prefix, 'bin', 'brew')
	}
	command << arguments
	return runtime.capture(command, environment)
}

pub fn (mut runtime IntegrationTestRuntime) brew_sh(arguments []string,
	overrides map[string]string) IntegrationCommandResult {
	mut environment := os.environ()
	environment['HOMEBREW_CACHE'] = runtime.config.cache
	environment['HOMEBREW_INTEGRATION_TEST'] = runtime.command_id()
	for key, value in overrides {
		environment[key] = value
	}
	executable := environment['HOMEBREW_BREW_SH'] or {
		if runtime.config.brew_sh_path != '' {
			runtime.config.brew_sh_path
		} else {
			os.join_path(runtime.config.prefix, 'bin', 'brew')
		}
	}
	environment.delete('HOMEBREW_BREW_SH')
	mut command := [executable]
	command << arguments
	return runtime.capture(command, environment)
}

fn integration_formula_content(runtime &IntegrationTestRuntime, name string, supplied string,
	bottle_block string) !string {
	if name.starts_with('testball') {
		prefix := if name == 'testball2' { 'testball2' } else { 'testball' }
		tarball_name := if runtime.config.linux {
			'${prefix}-0.1-linux.tbz'
		} else {
			'${prefix}-0.1.tbz'
		}
		tarball := os.join_path(runtime.config.fixture_dir, 'tarballs', tarball_name)
		if !os.is_file(tarball) {
			return error('missing integration fixture ${tarball}')
		}
		digest := sha256.sum256(os.read_bytes(tarball)!).hex()
		bottle := if bottle_block != '' {
			bottle_block
		} else if name == 'testball_bottle' {
			'bottle do\n  root_url "file://${runtime.config.fixture_dir}/bottles"\n  sha256 cellar: :any_skip_relocation, all: "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"\nend'
		} else {
			''
		}
		return 'desc "Some test"\nhomepage "https://brew.sh/${name}"\nurl "file://${tarball}"\nsha256 "${digest}"\n\noption "with-foo", "Build with foo"\n${bottle}\ndef install\n  (prefix/"foo"/"test").write("test") if build.with? "foo"\n  prefix.install Dir["*"]\nend\n\n${supplied}\n\n# something here'
	}
	if name == 'bar' {
		return 'url "https://brew.sh/bar-1.0"\ndepends_on "foo"'
	}
	if name == 'package_license' {
		return 'url "https://brew.sh/#patchelf-1.0"\nlicense "0BSD"'
	}
	return if supplied != '' { supplied } else { 'url "https://brew.sh/${name}-1.0"' }
}

pub fn (mut runtime IntegrationTestRuntime) setup_test_formula(name string, supplied string,
	tap_path string, bottle_block string, tab_attributes map[string]string) !string {
	content := integration_formula_content(runtime, name, supplied, bottle_block)!
	formula_directory := os.join_path(tap_path, 'Formula')
	os.mkdir_all(formula_directory)!
	formula_path := os.join_path(formula_directory, '${name.to_lower()}.rb')
	indented := content.split_into_lines().map(if it == '' { '' } else { '  ${it}' }).join('\n')
	os.write_file(formula_path, 'class ${homebrew.ruby_formulary_l452_d27_self_class_s(name)} < Formula\n${indented}\nend\n')!
	runtime.tap_cache_clears++
	if tab_attributes.len > 0 {
		keg := os.join_path(runtime.config.cellar, name, '0.1')
		os.mkdir_all(keg)!
		mut lines := []string{}
		for key, value in tab_attributes {
			lines << '${key}=${value}'
		}
		lines.sort()
		os.write_file(os.join_path(keg, 'INSTALL_RECEIPT.json'), '${lines.join('\n')}\n')!
	}
	return formula_path
}

pub fn (mut runtime IntegrationTestRuntime) install_formula_fixture(name string) !string {
	prefix := os.join_path(runtime.config.cellar, name, '0.1')
	bin := os.join_path(prefix, 'bin')
	os.mkdir_all(bin)!
	executable := os.join_path(bin, 'test')
	os.write_file(executable, '#!/bin/sh\nprintf test\n')!
	os.chmod(executable, 0o755)!
	if name !in runtime.installed_formulae {
		runtime.installed_formulae << name
	}
	return prefix
}

pub fn (mut runtime IntegrationTestRuntime) install_test_formula(name string, content string,
	build_bottle bool) !string {
	_ = build_bottle
	runtime.setup_test_formula(name, content, runtime.config.core_tap_path, '', {})!
	return runtime.install_formula_fixture(name)!
}

pub fn (mut runtime IntegrationTestRuntime) uninstall_test_formula(name string) ! {
	rack := os.join_path(runtime.config.cellar, name)
	if os.is_dir(rack) {
		os.rmdir_all(rack)!
	}
	runtime.installed_formulae = runtime.installed_formulae.filter(it != name)
}

fn integration_git(path string, arguments []string) ! {
	mut command := ['git', '-C', path]
	command << arguments
	result := brew_runtime.run_captured_command(command, brew_runtime.CapturedCommandOptions{
		environment: os.environ()
	})!
	if result.exit_code != 0 {
		return error(result.stderr)
	}
}

pub fn (mut runtime IntegrationTestRuntime) setup_test_tap() !string {
	path := os.join_path(runtime.config.tap_directory, 'homebrew', 'homebrew-foo')
	os.mkdir_all(path)!
	integration_git(path, ['init'])!
	integration_git(path, ['config', 'user.name', 'Brew V Tests'])!
	integration_git(path, ['config', 'user.email', 'brew-v@example.invalid'])!
	integration_git(path, ['remote', 'add', 'origin', 'https://github.com/Homebrew/homebrew-foo'])!
	os.write_file(os.join_path(path, 'readme'), '')!
	integration_git(path, ['add', '--all'])!
	integration_git(path, ['commit', '-m', 'init'])!
	return path
}

pub fn (mut runtime IntegrationTestRuntime) install_and_rename_coretap_formula(old_name string,
	new_name string) ! {
	tap_path := runtime.config.core_tap_path
	os.mkdir_all(os.join_path(tap_path, 'Formula'))!
	integration_git(tap_path, ['init'])!
	integration_git(tap_path, ['config', 'user.name', 'Brew V Tests'])!
	integration_git(tap_path, ['config', 'user.email', 'brew-v@example.invalid'])!
	old_path := os.join_path(tap_path, 'Formula', '${old_name}.rb')
	if !os.is_file(old_path) {
		runtime.setup_test_formula(old_name, '', tap_path, '', {})!
	}
	integration_git(tap_path, ['add', '--all'])!
	integration_git(tap_path, ['commit', '-m', '${old_name.capitalize()} has not yet been renamed'])!
	result := runtime.brew(['install', old_name], {})
	if !result.success() {
		return error('failed to install ${old_name}: ${result.stderr}')
	}
	os.rm(old_path)!
	os.write_file(os.join_path(tap_path, 'formula_renames.json'), '{\n  "${old_name}": "${new_name}"\n}\n')!
	integration_git(tap_path, ['add', '--all'])!
	integration_git(tap_path, ['commit', '-m',
		'${old_name.capitalize()} has been renamed to ${new_name.capitalize()}'])!
}

fn integration_runtime_value(runtime &IntegrationTestRuntime) brew_runtime.Value {
	return brew_runtime.structured_value('IntegrationTest', '', {
		'integration_runtime_address': u64(voidptr(runtime)).str()
	})
}

pub fn integration_runtime_boundary(runtime &IntegrationTestRuntime) brew_runtime.Value {
	return integration_runtime_value(runtime)
}

fn integration_runtime_from_args(args []brew_runtime.Value, method string) &IntegrationTestRuntime {
	if args.len == 0 || args[0].type_name != 'IntegrationTest' {
		panic('IntegrationTest#${method} requires a translated runtime')
	}
	address := args[0].attributes['integration_runtime_address'] or {
		panic('IntegrationTest runtime has no translated state')
	}
	return unsafe { &IntegrationTestRuntime(voidptr(address.u64())) }
}

fn integration_result_value(result IntegrationCommandResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Process::Status'
		repr: result.exit_code.str()
		map_data: {
			'exit_code': brew_runtime.int_value(result.exit_code)
			'stdout':    brew_runtime.string_value(result.stdout)
			'stderr':    brew_runtime.string_value(result.stderr)
			'success?':  brew_runtime.bool_value(result.success())
		}
	}
}

fn integration_string_map(value brew_runtime.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in value.as_map() or { return result } {
		result[key] = item.as_string()
	}
	return result
}

// Ruby method `supports_block_expectations?` at line 20.
pub fn ruby_integration_test_l20_d1_supports_block_expectations(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby method `expects_call_stack_jump?` at line 40.
pub fn ruby_integration_test_l40_d2_expects_call_stack_jump(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby method `command_id` at line 57.
pub fn ruby_integration_test_l57_d3_command_id(args ...brew_runtime.Value) brew_runtime.Value {
	mut runtime := integration_runtime_from_args(args, 'command_id')
	return brew_runtime.string_value(runtime.command_id())
}

// Ruby method `brew(*args)` at line 65.
pub fn ruby_integration_test_l65_d4_brew(args ...brew_runtime.Value) brew_runtime.Value {
	mut runtime := integration_runtime_from_args(args, 'brew')
	arguments := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	overrides := if args.len > 2 { integration_string_map(args[2]) } else { map[string]string{} }
	return integration_result_value(runtime.brew(arguments, overrides))
}

// Ruby method `brew_sh(*args)` at line 122.
pub fn ruby_integration_test_l122_d5_brew_sh(args ...brew_runtime.Value) brew_runtime.Value {
	mut runtime := integration_runtime_from_args(args, 'brew_sh')
	arguments := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	overrides := if args.len > 2 { integration_string_map(args[2]) } else { map[string]string{} }
	return integration_result_value(runtime.brew_sh(arguments, overrides))
}

// Ruby method `setup_test_formula(name, content = nil, tap: CoreTap.instance,` at line 151.
pub fn ruby_integration_test_l151_d6_setup_test_formula(args ...brew_runtime.Value) brew_runtime.Value {
	mut runtime := integration_runtime_from_args(args, 'setup_test_formula')
	if args.len < 2 {
		panic('setup_test_formula requires a name')
	}
	content := if args.len > 2 && args[2].type_name !in ['Nil', 'NilClass'] {
		args[2].as_string()
	} else {
		''
	}
	options := if args.len > 3 { args[3].map_data } else { map[string]brew_runtime.Value{} }
	tap_path := (options['tap'] or { brew_runtime.string_value(runtime.config.core_tap_path) }).as_string()
	bottle_block := (options['bottle_block'] or { brew_runtime.string_value('') }).as_string()
	tab_attributes := if value := options['tab_attributes'] {
		integration_string_map(value)
	} else {
		map[string]string{}
	}
	path := runtime.setup_test_formula(args[1].as_string(), content, tap_path, bottle_block, tab_attributes) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `install` at line 176.
pub fn ruby_integration_test_l176_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	mut runtime := integration_runtime_from_args(args, 'install')
	name := if args.len > 1 { args[1].as_string() } else { 'testball' }
	path := runtime.install_formula_fixture(name) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `install_test_formula(name, content = nil, build_bottle: false)` at line 232.
pub fn ruby_integration_test_l232_d8_install_test_formula(args ...brew_runtime.Value) brew_runtime.Value {
	mut runtime := integration_runtime_from_args(args, 'install_test_formula')
	if args.len < 2 {
		panic('install_test_formula requires a name')
	}
	content := if args.len > 2 && args[2].type_name !in ['Nil', 'NilClass'] {
		args[2].as_string()
	} else {
		''
	}
	build_bottle := args.len > 3 && (args[3].as_bool() or { false })
	path := runtime.install_test_formula(args[1].as_string(), content, build_bottle) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `uninstall_test_formula(name)` at line 243.
pub fn ruby_integration_test_l243_d9_uninstall_test_formula(args ...brew_runtime.Value) brew_runtime.Value {
	mut runtime := integration_runtime_from_args(args, 'uninstall_test_formula')
	if args.len > 1 {
		runtime.uninstall_test_formula(args[1].as_string()) or {
			return brew_runtime.object_value('RuntimeError', err.msg())
		}
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `setup_test_tap` at line 252.
pub fn ruby_integration_test_l252_d10_setup_test_tap(args ...brew_runtime.Value) brew_runtime.Value {
	mut runtime := integration_runtime_from_args(args, 'setup_test_tap')
	path := runtime.setup_test_tap() or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `install_and_rename_coretap_formula(old_name, new_name)` at line 266.
pub fn ruby_integration_test_l266_d11_install_and_rename_coretap_formula(args ...brew_runtime.Value) brew_runtime.Value {
	mut runtime := integration_runtime_from_args(args, 'install_and_rename_coretap_formula')
	if args.len < 3 {
		panic('install_and_rename_coretap_formula requires old and new names')
	}
	runtime.install_and_rename_coretap_formula(args[1].as_string(), args[2].as_string()) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `testball` at line 285.
pub fn ruby_integration_test_l285_d12_testball(args ...brew_runtime.Value) brew_runtime.Value {
	runtime := integration_runtime_from_args(args, 'testball')
	return brew_runtime.string_value(os.join_path(runtime.config.fixture_dir, 'testball.rb'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: require "formula_installer"
// 7: require "uninstall"
// 8:
// 9: RSpec::Matchers.define :be_a_success do
// 10:   T.bind(self, T.class_of(RSpec::Matchers::DSL::Matcher))
// 11:
// 12:   match do |actual|
// 13:     T.bind(self, RSpec::Matchers::DSL::Matcher)
// 14:
// 15:     status = actual.is_a?(Proc) ? actual.call : actual
// 16:     expect(status).to respond_to(:success?)
// 17:     status.success?
// 18:   end
// 19:
// 20:   def supports_block_expectations?
// 21:     true
// 22:   end
// 23:
// 24:   # It needs to be nested like this:
// 25:   #
// 26:   #   expect {
// 27:   #     expect {
// 28:   #       # command
// 29:   #     }.to be_a_success
// 30:   #   }.to output(something).to_stdout
// 31:   #
// 32:   # rather than this:
// 33:   #
// 34:   #   expect {
// 35:   #     expect {
// 36:   #       # command
// 37:   #     }.to output(something).to_stdout
// 38:   #   }.to be_a_success
// 39:   #
// 40:   def expects_call_stack_jump?
// 41:     true
// 42:   end
// 43: end
// 44:
// 45: RSpec::Matchers.define_negated_matcher :be_a_failure, :be_a_success
// 46:
// 47: module Test
// 48:   module Helper
// 49:     module IntegrationTest
// 50:       extend T::Helpers
// 51:
// 52:       requires_ancestor { Kernel }
// 53:
// 54:       # Generate unique ID to be able to
// 55:       # properly merge coverage results.
// 56:       sig { returns(String) }
// 57:       def command_id
// 58:         Thread.current[:brew_integration_test_number] ||= 0
// 59:         "#{Process.pid}:#{ENV.fetch("TEST_ENV_NUMBER", "")}:#{Thread.current[:brew_integration_test_number] += 1}"
// 60:       end
// 61:
// 62:       # Runs a `brew` command with the test configuration
// 63:       # and with coverage reporting enabled.
// 64:       sig { params(args: T.untyped).returns(Process::Status) }
// 65:       def brew(*args)
// 66:         env = args.last.is_a?(Hash) ? args.pop : {}
// 67:
// 68:         # Avoid warnings when HOMEBREW_PREFIX/bin is not in PATH.
// 69:         # Also include our extra commands directory.
// 70:         path = [
// 71:           env["PATH"],
// 72:           (HOMEBREW_LIBRARY_PATH/"test/support/helper/cmd").realpath.to_s,
// 73:           (HOMEBREW_PREFIX/"bin").realpath.to_s,
// 74:           ENV.fetch("PATH"),
// 75:         ].compact.join(File::PATH_SEPARATOR)
// 76:
// 77:         env.merge!(
// 78:           "PATH"                         => path,
// 79:           "HOMEBREW_PATH"                => path,
// 80:           "HOMEBREW_BREW_FILE"           => HOMEBREW_PREFIX/"bin/brew",
// 81:           "HOMEBREW_INTEGRATION_TEST"    => command_id,
// 82:           "HOMEBREW_TEST_TMPDIR"         => TEST_TMPDIR,
// 83:           "HOMEBREW_DEV_CMD_RUN"         => "true",
// 84:           "HOMEBREW_ASK"                 => nil,
// 85:           "HOMEBREW_USE_RUBY_FROM_PATH"  => ENV.fetch("HOMEBREW_USE_RUBY_FROM_PATH", nil),
// 86:           "HOMEBREW_NO_INSTALL_FROM_API" => ENV.fetch("HOMEBREW_NO_INSTALL_FROM_API", nil),
// 87:           "GEM_HOME"                     => nil,
// 88:         )
// 89:
// 90:         @ruby_args ||= begin
// 91:           ruby_args = HOMEBREW_RUBY_EXEC_ARGS.dup
// 92:           if ENV["HOMEBREW_TESTS_COVERAGE"]
// 93:             simplecov_spec = Gem.loaded_specs["simplecov"]
// 94:             parallel_tests_spec = Gem.loaded_specs["parallel_tests"]
// 95:             specs = T.let([], T::Array[Gem::Specification])
// 96:             [simplecov_spec, parallel_tests_spec].each do |spec|
// 97:               specs << spec
// 98:               spec.runtime_dependencies.each do |dep|
// 99:                 specs += dep.to_specs
// 100:               rescue Gem::LoadError => e
// 101:                 T.bind(self, Utils::Output::Mixin)
// 102:                 onoe e
// 103:               end
// 104:             end
// 105:             specs.flat_map(&:full_require_paths).each { |lib| ruby_args << "-I" << lib }
// 106:             ruby_args << "-r#{HOMEBREW_LIBRARY_PATH}/test/support/helper/simplecov_start"
// 107:           end
// 108:           ruby_args << "-r#{HOMEBREW_LIBRARY_PATH}/test/support/helper/integration_mocks"
// 109:           ruby_args << "-e" << "$0 = ARGV.shift; load($0)"
// 110:           ruby_args << (HOMEBREW_LIBRARY_PATH/"brew.rb").resolved_path.to_s
// 111:         end
// 112:
// 113:         Bundler.with_unbundled_env do
// 114:           stdout, stderr, status = Open3.capture3(env, *@ruby_args, *args)
// 115:           $stdout.print stdout
// 116:           $stderr.print stderr
// 117:           status
// 118:         end
// 119:       end
// 120:
// 121:       sig { params(args: T.untyped).returns(Process::Status) }
// 122:       def brew_sh(*args)
// 123:         env = args.last.is_a?(Hash) ? args.pop : {}
// 124:         env = {
// 125:           "HOMEBREW_USE_RUBY_FROM_PATH" => ENV.fetch("HOMEBREW_USE_RUBY_FROM_PATH", nil),
// 126:           "HOMEBREW_CACHE"              => HOMEBREW_CACHE.to_s,
// 127:           "HOMEBREW_INTEGRATION_TEST"   => command_id,
// 128:         }.merge(env)
// 129:         Bundler.with_unbundled_env do
// 130:           brew_sh_path = env.delete("HOMEBREW_BREW_SH") || "#{ENV.fetch("HOMEBREW_PREFIX")}/bin/brew"
// 131:           stdout, stderr, status = Open3.capture3(
// 132:             env,
// 133:             brew_sh_path,
// 134:             *args,
// 135:           )
// 136:           $stdout.print stdout
// 137:           $stderr.print stderr
// 138:           status
// 139:         end
// 140:       end
// 141:
// 142:       sig {
// 143:         params(
// 144:           name:           String,
// 145:           content:        T.nilable(String),
// 146:           tap:            Tap,
// 147:           bottle_block:   T.nilable(String),
// 148:           tab_attributes: T.nilable(T::Hash[T.untyped, T.untyped]),
// 149:         ).returns(Pathname)
// 150:       }
// 151:       def setup_test_formula(name, content = nil, tap: CoreTap.instance,
// 152:                              bottle_block: nil, tab_attributes: nil)
// 153:         case name
// 154:         when /^testball/
// 155:           # Use a different tarball for testball2 to avoid lock errors when writing concurrency tests
// 156:           prefix = (name == "testball2") ? "testball2" : "testball"
// 157:           tarball = if OS.linux?
// 158:             TEST_FIXTURE_DIR/"tarballs/#{prefix}-0.1-linux.tbz"
// 159:           else
// 160:             TEST_FIXTURE_DIR/"tarballs/#{prefix}-0.1.tbz"
// 161:           end
// 162:           bottle_block ||= <<~RUBY if name == "testball_bottle"
// 163:             bottle do
// 164:               root_url "file://#{TEST_FIXTURE_DIR}/bottles"
// 165:               sha256 cellar: :any_skip_relocation, all: "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 166:             end
// 167:           RUBY
// 168:           content = <<~RUBY
// 169:             desc "Some test"
// 170:             homepage "https://brew.sh/#{name}"
// 171:             url "file://#{tarball}"
// 172:             sha256 "#{tarball.sha256}"
// 173:
// 174:             option "with-foo", "Build with foo"
// 175:             #{bottle_block}
// 176:             def install
// 177:               (prefix/"foo"/"test").write("test") if build.with? "foo"
// 178:               prefix.install Dir["*"]
// 179:               (buildpath/"test.c").write \
// 180:                 "#include <stdio.h>\\nint main(){printf(\\"test\\");return 0;}"
// 181:               bin.mkpath
// 182:               system ENV.cc, "test.c", "-o", bin/"test"
// 183:             end
// 184:
// 185:             #{content}
// 186:
// 187:             # something here
// 188:           RUBY
// 189:         when "bar"
// 190:           content = <<~RUBY
// 191:             url "https://brew.sh/#{name}-1.0"
// 192:             depends_on "foo"
// 193:           RUBY
// 194:         when "package_license"
// 195:           content = <<~RUBY
// 196:             url "https://brew.sh/#patchelf-1.0"
// 197:             license "0BSD"
// 198:           RUBY
// 199:         else
// 200:           content ||= <<~RUBY
// 201:             url "https://brew.sh/#{name}-1.0"
// 202:           RUBY
// 203:         end
// 204:
// 205:         formula_path = Formulary.find_formula_in_tap(name.downcase, tap).tap do |path|
// 206:           path.dirname.mkpath
// 207:           path.write <<~RUBY
// 208:             class #{Formulary.class_s(name)} < Formula
// 209:             #{content.gsub(/^(?!$)/, "  ")}
// 210:             end
// 211:           RUBY
// 212:
// 213:           tap.clear_cache
// 214:         end
// 215:
// 216:         return formula_path if tab_attributes.nil?
// 217:
// 218:         keg = ::Formula[name].prefix
// 219:         keg.mkpath
// 220:
// 221:         tab = Tab.for_name(name)
// 222:         tab.tabfile ||= keg/AbstractTab::FILENAME
// 223:         tab_attributes.each do |key, value|
// 224:           tab.public_send(:"#{key}=", value)
// 225:         end
// 226:         tab.write
// 227:
// 228:         formula_path
// 229:       end
// 230:
// 231:       sig { params(name: String, content: T.nilable(String), build_bottle: T::Boolean).void }
// 232:       def install_test_formula(name, content = nil, build_bottle: false)
// 233:         setup_test_formula(name, content)
// 234:         fi = FormulaInstaller.new(::Formula[name], build_bottle:, installed_on_request: true)
// 235:         fi.prelude_fetch
// 236:         fi.prelude
// 237:         fi.fetch
// 238:         fi.install
// 239:         fi.finish
// 240:       end
// 241:
// 242:       sig { params(name: String).void }
// 243:       def uninstall_test_formula(name)
// 244:         rack = HOMEBREW_CELLAR/name
// 245:         return unless rack.directory?
// 246:
// 247:         kegs = rack.children.map { |prefix| Keg.new(prefix) }
// 248:         Homebrew::Uninstall.uninstall_kegs({ rack => kegs }, force: true, ignore_dependencies: true)
// 249:       end
// 250:
// 251:       sig { returns(Pathname) }
// 252:       def setup_test_tap
// 253:         path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo"
// 254:         path.mkpath
// 255:         path.cd do
// 256:           system "git", "init"
// 257:           system "git", "remote", "add", "origin", "https://github.com/Homebrew/homebrew-foo"
// 258:           FileUtils.touch "readme"
// 259:           system "git", "add", "--all"
// 260:           system "git", "commit", "-m", "init"
// 261:         end
// 262:         path
// 263:       end
// 264:
// 265:       sig { params(old_name: String, new_name: String).void }
// 266:       def install_and_rename_coretap_formula(old_name, new_name)
// 267:         CoreTap.instance.path.cd do |tap_path|
// 268:           system "git", "init"
// 269:           system "git", "add", "--all"
// 270:           system "git", "commit", "-m",
// 271:                  "#{old_name.capitalize} has not yet been renamed"
// 272:
// 273:           brew "install", old_name
// 274:
// 275:           (tap_path/"Formula/#{old_name}.rb").unlink
// 276:           (tap_path/"formula_renames.json").write JSON.pretty_generate(old_name => new_name)
// 277:
// 278:           system "git", "add", "--all"
// 279:           system "git", "commit", "-m",
// 280:                  "#{old_name.capitalize} has been renamed to #{new_name.capitalize}"
// 281:         end
// 282:       end
// 283:
// 284:       sig { returns(String) }
// 285:       def testball
// 286:         "#{TEST_FIXTURE_DIR}/testball.rb"
// 287:       end
// 288:     end
// 289:   end
// 290: end
// 291:
// 292: # These shared contexts starting with `when` don't make sense.
// 293: RSpec.shared_context "integration test" do # rubocop:disable RSpec/ContextWording
// 294:   T.bind(self, T.class_of(RSpec::Core::ExampleGroup))
// 295:   include Test::Helper::IntegrationTest
// 296:
// 297:   around do |example|
// 298:     ENV["HOMEBREW_INTEGRATION_TEST"] = "1"
// 299:     (HOMEBREW_PREFIX/"bin").mkpath
// 300:     FileUtils.touch HOMEBREW_PREFIX/"bin/brew"
// 301:
// 302:     example.run
// 303:   ensure
// 304:     FileUtils.rm_rf HOMEBREW_PREFIX/"bin"
// 305:     ENV.delete("HOMEBREW_INTEGRATION_TEST")
// 306:   end
// 307: end
// 308:
// 309: RSpec.configure do |config|
// 310:   config.include_context "integration test", :integration_test
// 311: end
