module language

import homebrew.language as node_language
import os
import time
import x.json2

// Translated from Homebrew/brew `test/language/node_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:npm_pack_cmd) { ["npm", "pack", "--ignore-scripts"] }` at line 7.
pub fn ruby_node_spec_l7_d1_npm_pack_cmd() []string {
	return ['npm', 'pack', '--ignore-scripts']
}

// Ruby it `it "calls prepend_path when node formula exists only during the first call" do` at line 14.
pub fn ruby_node_spec_l14_d2_calls() bool {
	mut state := node_language.NodeEnvironmentState{
		node_formula_available: true
		node_opt_libexec: '/opt/homebrew/opt/node/libexec'
	}
	first := node_language.setup_npm_environment(mut state)
	second := node_language.setup_npm_environment(mut state)
	return first && !second && state.env_set && state.prepend_calls == 1 && state.path_entries == [
		'/opt/homebrew/opt/node/libexec/bin',
	]
}

// Ruby it `it "does not call prepend_path when node formula does not exist" do` at line 32.
pub fn ruby_node_spec_l32_d3_does() bool {
	mut state := node_language.NodeEnvironmentState{
		node_formula_available: false
	}
	prepended := node_language.setup_npm_environment(mut state)
	return !prepended && state.env_set && state.prepend_calls == 0 && state.path_entries.len == 0
}

// Ruby it `it "removes prepare and prepack scripts" do` at line 42.
pub fn ruby_node_spec_l42_d4_removes() bool {
	root := node_spec_temp_root('remove-scripts') or { return false }
	defer {
		os.rmdir_all(root) or {}
	}
	package_path := os.join_path(root, 'package.json')
	os.write_file(package_path, '{"name":"sample","scripts":{"prepare":"ls","prepack":"ls","test":"ls"}}') or {
		return false
	}
	pack := node_language.pack_for_installation(root, node_spec_successful_pack) or {
		return false
	}
	decoded := json2.decode[json2.Any](os.read_file(package_path) or { return false }) or {
		return false
	}
	package := decoded.as_map()
	scripts := (package['scripts'] or { return false }).as_map()
	return pack == 'pack.tgz' && 'prepare' !in scripts && 'prepack' !in scripts && scripts['test'] or { json2.Any('') }.str() == 'ls'
}

// Ruby let `let(:npm_install_arg) { Pathname("libexec") }` at line 56.
pub fn ruby_node_spec_l56_d5_npm_install_arg() string {
	return 'libexec'
}

// Ruby it `it "raises error with non zero exitstatus" do` at line 62.
pub fn ruby_node_spec_l62_d6_raises() bool {
	root := node_spec_temp_root('failed-pack') or { return false }
	defer {
		os.rmdir_all(root) or {}
	}
	mut state := node_language.NodeEnvironmentState{}
	node_language.std_npm_install_args(mut state, os.join_path(root, ruby_node_spec_l56_d5_npm_install_arg()), root, '/cache', true, 501, node_spec_failed_pack) or {
		return err.msg() == 'npm failed to pack ${root}'
	}
	return false
}

// Ruby it `it "raises error with empty npm pack output" do` at line 67.
pub fn ruby_node_spec_l67_d7_raises() bool {
	root := node_spec_temp_root('empty-pack') or { return false }
	defer {
		os.rmdir_all(root) or {}
	}
	mut state := node_language.NodeEnvironmentState{}
	node_language.std_npm_install_args(mut state, os.join_path(root, ruby_node_spec_l56_d5_npm_install_arg()), root, '/cache', true, 501, node_spec_empty_pack) or {
		return err.msg() == 'npm failed to pack ${root}'
	}
	return false
}

// Ruby it `it "does not raise error with a zero exitstatus" do` at line 72.
pub fn ruby_node_spec_l72_d8_does() bool {
	root := node_spec_temp_root('successful-pack') or { return false }
	defer {
		os.rmdir_all(root) or {}
	}
	libexec := os.join_path(root, ruby_node_spec_l56_d5_npm_install_arg())
	mut state := node_language.NodeEnvironmentState{}
	response := node_language.std_npm_install_args(mut state, libexec, root, '/cache', true, 501, node_spec_successful_pack) or { return false }
	return '--min-release-age=1' in response && '--prefix=${libexec}' in response && os.join_path(root, 'pack.tgz') in response && os.is_dir(os.join_path(libexec, 'lib'))
}

// Ruby it `it "includes only npm install security arguments" do` at line 80.
pub fn ruby_node_spec_l80_d9_includes() bool {
	return node_language.npm_install_security_args('/homebrew/cache', true) == [
		'--min-release-age=1',
		'--cache=/homebrew/cache/npm_cache',
		'--ignore-scripts',
	]
}

// Ruby it `it "includes the default npm install arguments" do` at line 94.
pub fn ruby_node_spec_l94_d10_includes() bool {
	mut state := node_language.NodeEnvironmentState{}
	response := node_language.local_npm_install_args(mut state, '/homebrew/cache', true)
	return '--loglevel=silly' in response && '--build-from-source' in response && '--cache=/homebrew/cache/npm_cache' in response && '--min-release-age=1' in response
}

fn node_spec_temp_root(label string) !string {
	root := os.join_path(os.temp_dir(), 'brew-v-node-${label}-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(root)!
	return root
}

fn node_spec_successful_pack(command []string, working_directory string) !node_language.NpmPackResult {
	_ = working_directory
	if command != ruby_node_spec_l7_d1_npm_pack_cmd() {
		return error('unexpected npm command')
	}
	return node_language.NpmPackResult{
		stdout: 'pack.tgz\n'
		exit_code: 0
	}
}

fn node_spec_failed_pack(command []string, working_directory string) !node_language.NpmPackResult {
	_ = command
	_ = working_directory
	return node_language.NpmPackResult{
		exit_code: 1
	}
}

fn node_spec_empty_pack(command []string, working_directory string) !node_language.NpmPackResult {
	_ = command
	_ = working_directory
	return node_language.NpmPackResult{
		exit_code: 0
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "language/node"
// 5:
// 6: RSpec.describe Language::Node do
// 7:   let(:npm_pack_cmd) { ["npm", "pack", "--ignore-scripts"] }
// 8:
// 9:   describe "#setup_npm_environment" do
// 10:     before do
// 11:       described_class.env_set = false
// 12:     end
// 13:
// 14:     it "calls prepend_path when node formula exists only during the first call" do
// 15:       node = formula "node" do
// 16:         T.bind(self, T.class_of(Formula))
// 17:         url "node-test-v1.0"
// 18:       end
// 19:       stub_formula_loader(node)
// 20:       without_partial_double_verification do
// 21:         expect(ENV).to receive(:prepend_path)
// 22:       end
// 23:       described_class.setup_npm_environment
// 24:
// 25:       expect(described_class.env_set).to be(true)
// 26:       without_partial_double_verification do
// 27:         expect(ENV).not_to receive(:prepend_path)
// 28:       end
// 29:       described_class.setup_npm_environment
// 30:     end
// 31:
// 32:     it "does not call prepend_path when node formula does not exist" do
// 33:       allow(Formula).to receive(:[]).with("node").and_raise(FormulaUnavailableError.new("node"))
// 34:       without_partial_double_verification do
// 35:         expect(ENV).not_to receive(:prepend_path)
// 36:       end
// 37:       described_class.setup_npm_environment
// 38:     end
// 39:   end
// 40:
// 41:   describe "#std_pack_for_installation" do
// 42:     it "removes prepare and prepack scripts" do
// 43:       mktmpdir.cd do
// 44:         path = Pathname("package.json")
// 45:         path.atomic_write("{\"scripts\":{\"prepare\": \"ls\", \"prepack\": \"ls\", \"test\": \"ls\"}}")
// 46:         allow(Utils).to receive(:popen_read).with(*npm_pack_cmd).and_return(`echo pack.tgz`)
// 47:         described_class.pack_for_installation
// 48:         expect(path.read).not_to include("prepare")
// 49:         expect(path.read).not_to include("prepack")
// 50:         expect(path.read).to include("test")
// 51:       end
// 52:     end
// 53:   end
// 54:
// 55:   describe "#std_npm_install_args" do
// 56:     let(:npm_install_arg) { Pathname("libexec") }
// 57:
// 58:     before do
// 59:       allow(described_class).to receive(:setup_npm_environment)
// 60:     end
// 61:
// 62:     it "raises error with non zero exitstatus" do
// 63:       allow(Utils).to receive(:popen_read).with(*npm_pack_cmd).and_return(`false`)
// 64:       expect { described_class.std_npm_install_args(npm_install_arg) }.to raise_error("npm failed to pack #{Dir.pwd}")
// 65:     end
// 66:
// 67:     it "raises error with empty npm pack output" do
// 68:       allow(Utils).to receive(:popen_read).with(*npm_pack_cmd).and_return(`true`)
// 69:       expect { described_class.std_npm_install_args(npm_install_arg) }.to raise_error("npm failed to pack #{Dir.pwd}")
// 70:     end
// 71:
// 72:     it "does not raise error with a zero exitstatus" do
// 73:       allow(Utils).to receive(:popen_read).with(*npm_pack_cmd).and_return(`echo pack.tgz`)
// 74:       resp = described_class.std_npm_install_args(npm_install_arg)
// 75:       expect(resp).to include("--min-release-age=1", "--prefix=#{npm_install_arg}", "#{Dir.pwd}/pack.tgz")
// 76:     end
// 77:   end
// 78:
// 79:   describe "#npm_install_security_args" do
// 80:     it "includes only npm install security arguments" do
// 81:       expect(described_class.npm_install_security_args).to eq([
// 82:         "--min-release-age=1",
// 83:         "--cache=#{HOMEBREW_CACHE}/npm_cache",
// 84:         "--ignore-scripts",
// 85:       ])
// 86:     end
// 87:   end
// 88:
// 89:   describe "#local_npm_install_args" do
// 90:     before do
// 91:       allow(described_class).to receive(:setup_npm_environment)
// 92:     end
// 93:
// 94:     it "includes the default npm install arguments" do
// 95:       resp = described_class.local_npm_install_args
// 96:       expect(resp).to include("--loglevel=silly", "--build-from-source", "--cache=#{HOMEBREW_CACHE}/npm_cache",
// 97:                               "--min-release-age=1")
// 98:     end
// 99:   end
// 100: end
