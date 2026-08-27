module language

import brew_runtime

// Translated from Homebrew/brew `test/language/node_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:npm_pack_cmd) { ["npm", "pack", "--ignore-scripts"] }` at line 7.
pub fn ruby_node_spec_l7_d1_npm_pack_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('npm_pack_cmd', ...args)
}

// Ruby it `it "calls prepend_path when node formula exists only during the first call" do` at line 14.
pub fn ruby_node_spec_l14_d2_calls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('calls', ...args)
}

// Ruby it `it "does not call prepend_path when node formula does not exist" do` at line 32.
pub fn ruby_node_spec_l32_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "removes prepare and prepack scripts" do` at line 42.
pub fn ruby_node_spec_l42_d4_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Ruby let `let(:npm_install_arg) { Pathname("libexec") }` at line 56.
pub fn ruby_node_spec_l56_d5_npm_install_arg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('npm_install_arg', ...args)
}

// Ruby it `it "raises error with non zero exitstatus" do` at line 62.
pub fn ruby_node_spec_l62_d6_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises error with empty npm pack output" do` at line 67.
pub fn ruby_node_spec_l67_d7_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "does not raise error with a zero exitstatus" do` at line 72.
pub fn ruby_node_spec_l72_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "includes only npm install security arguments" do` at line 80.
pub fn ruby_node_spec_l80_d9_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "includes the default npm install arguments" do` at line 94.
pub fn ruby_node_spec_l94_d10_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
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
