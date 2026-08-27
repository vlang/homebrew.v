module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/tests_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:tests) { described_class.new([]) }` at line 11.
pub fn ruby_tests_spec_l11_d1_tests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tests', ...args)
}

// Ruby it `it "does not require the Linux sandbox when Linux sandboxing is disabled" do` at line 21.
pub fn ruby_tests_spec_l21_d2_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not fail on GitHub Actions when the Linux sandbox is unavailable" do` at line 29.
pub fn ruby_tests_spec_l29_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "fails outside GitHub Actions when the Linux sandbox is unavailable" do` at line 37.
pub fn ruby_tests_spec_l37_d4_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "passes when the Linux sandbox is available" do` at line 44.
pub fn ruby_tests_spec_l44_d5_passes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('passes', ...args)
}

// Ruby subject `subject(:tests) { described_class.new([]) }` at line 52.
pub fn ruby_tests_spec_l52_d6_tests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tests', ...args)
}

// Ruby it `it "keeps generic cache files out of the sandboxed test home" do` at line 60.
pub fn ruby_tests_spec_l60_d7_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "can disable Sorbet runtime" do` at line 67.
pub fn ruby_tests_spec_l67_d8_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby subject `subject(:changed_test_files) { tests.changed_test_files }` at line 80.
pub fn ruby_tests_spec_l80_d9_changed_test_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('changed_test_files', ...args)
}

// Ruby let `let(:tests) { described_class.new([]) }` at line 82.
pub fn ruby_tests_spec_l82_d10_tests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tests', ...args)
}

// Ruby let `let(:changed_file) { "Library/Homebrew/test/cmd/help_spec.rb\n" }` at line 85.
pub fn ruby_tests_spec_l85_d11_changed_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('changed_file', ...args)
}

// Ruby it `it "includes the changed spec file" do` at line 91.
pub fn ruby_tests_spec_l91_d12_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby let `let(:changed_file) { "Library/Homebrew/cmd/help.rb\n" }` at line 97.
pub fn ruby_tests_spec_l97_d13_changed_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('changed_file', ...args)
}

// Ruby it `it "maps the file to its corresponding spec" do` at line 103.
pub fn ruby_tests_spec_l103_d14_maps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('maps', ...args)
}

// Ruby let `let(:changed_file) do` at line 109.
pub fn ruby_tests_spec_l109_d15_changed_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('changed_file', ...args)
}

// Ruby it `it "includes integration tests and excludes unrelated tests", :aggregate_failures do` at line 117.
pub fn ruby_tests_spec_l117_d16_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby let `let(:changed_file) do` at line 124.
pub fn ruby_tests_spec_l124_d17_changed_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('changed_file', ...args)
}

// Ruby it `it "includes cask tests and excludes non-cask tests", :aggregate_failures do` at line 132.
pub fn ruby_tests_spec_l132_d18_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/tests"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Tests do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "#check_test_environment!", :needs_linux do
// 11:     subject(:tests) { described_class.new([]) }
// 12:
// 13:     before do
// 14:       require "extend/os/linux/dev-cmd/tests"
// 15:       require "sandbox"
// 16:
// 17:       allow(Homebrew::EnvConfig).to receive(:sandbox_linux?).and_return(true)
// 18:       allow(GitHub::Actions).to receive(:env_set?).and_return(false)
// 19:     end
// 20:
// 21:     it "does not require the Linux sandbox when Linux sandboxing is disabled" do
// 22:       allow(Homebrew::EnvConfig).to receive(:sandbox_linux?).and_return(false)
// 23:       allow(Sandbox).to receive_messages(available?: false, failure_reason: "sandbox unavailable")
// 24:       expect(Sandbox).not_to receive(:ensure_sandbox_available!)
// 25:
// 26:       expect { tests.check_test_environment! }.not_to raise_error
// 27:     end
// 28:
// 29:     it "does not fail on GitHub Actions when the Linux sandbox is unavailable" do
// 30:       allow(Sandbox).to receive(:available?).and_return(false)
// 31:       allow(GitHub::Actions).to receive(:env_set?).and_return(true)
// 32:       expect(Sandbox).not_to receive(:ensure_sandbox_available!)
// 33:
// 34:       expect { tests.check_test_environment! }.not_to raise_error
// 35:     end
// 36:
// 37:     it "fails outside GitHub Actions when the Linux sandbox is unavailable" do
// 38:       allow(Sandbox).to receive_messages(available?: false, failure_reason: "Landlock is not available.")
// 39:
// 40:       expect { tests.check_test_environment! }
// 41:         .to raise_error(RuntimeError, "Landlock is not available.")
// 42:     end
// 43:
// 44:     it "passes when the Linux sandbox is available" do
// 45:       allow(Sandbox).to receive(:available?).and_return(true)
// 46:
// 47:       expect { tests.check_test_environment! }.not_to raise_error
// 48:     end
// 49:   end
// 50:
// 51:   describe "#setup_environment!" do
// 52:     subject(:tests) { described_class.new([]) }
// 53:
// 54:     before do
// 55:       require "api"
// 56:
// 57:       allow(Homebrew::API).to receive(:fetch_api_files!)
// 58:     end
// 59:
// 60:     it "keeps generic cache files out of the sandboxed test home" do
// 61:       tests.setup_environment!
// 62:
// 63:       expect(ENV.fetch("XDG_CACHE_HOME")).to eq("#{HOMEBREW_CACHE}/tests")
// 64:       expect(ENV.fetch("XDG_CACHE_HOME")).not_to start_with("#{Dir.home}/")
// 65:     end
// 66:
// 67:     it "can disable Sorbet runtime" do
// 68:       ENV["HOMEBREW_TESTS_NO_SORBET_RUNTIME"] = "1"
// 69:       tests.setup_environment!
// 70:
// 71:       expect([
// 72:         ENV.fetch("HOMEBREW_TESTS_NO_SORBET_RUNTIME", nil),
// 73:         ENV.fetch("HOMEBREW_SORBET_RUNTIME", nil),
// 74:         ENV.fetch("HOMEBREW_SORBET_RECURSIVE", nil),
// 75:       ]).to eq(["1", nil, nil])
// 76:     end
// 77:   end
// 78:
// 79:   describe "#changed_test_files" do
// 80:     subject(:changed_test_files) { tests.changed_test_files }
// 81:
// 82:     let(:tests) { described_class.new([]) }
// 83:
// 84:     context "when a spec file changed" do
// 85:       let(:changed_file) { "Library/Homebrew/test/cmd/help_spec.rb\n" }
// 86:
// 87:       before do
// 88:         allow(Utils::Git).to receive(:changed_files).and_return(changed_file.split("\n"))
// 89:       end
// 90:
// 91:       it "includes the changed spec file" do
// 92:         expect(changed_test_files).to include("test/cmd/help_spec.rb")
// 93:       end
// 94:     end
// 95:
// 96:     context "when a non-test Ruby file changed" do
// 97:       let(:changed_file) { "Library/Homebrew/cmd/help.rb\n" }
// 98:
// 99:       before do
// 100:         allow(Utils::Git).to receive(:changed_files).and_return(changed_file.split("\n"))
// 101:       end
// 102:
// 103:       it "maps the file to its corresponding spec" do
// 104:         expect(changed_test_files).to include("test/cmd/help_spec.rb")
// 105:       end
// 106:     end
// 107:
// 108:     context "when integration shared context changed" do
// 109:       let(:changed_file) do
// 110:         "Library/Homebrew/test/support/helper/spec/shared_context/integration_test.rb\n"
// 111:       end
// 112:
// 113:       before do
// 114:         allow(Utils::Git).to receive(:changed_files).and_return(changed_file.split("\n"))
// 115:       end
// 116:
// 117:       it "includes integration tests and excludes unrelated tests", :aggregate_failures do
// 118:         expect(changed_test_files).to include("test/cmd/help_spec.rb")
// 119:         expect(changed_test_files).not_to include("test/dev-cmd/tests_spec.rb")
// 120:       end
// 121:     end
// 122:
// 123:     context "when cask shared context changed" do
// 124:       let(:changed_file) do
// 125:         "Library/Homebrew/test/support/helper/spec/shared_context/homebrew_cask.rb\n"
// 126:       end
// 127:
// 128:       before do
// 129:         allow(Utils::Git).to receive(:changed_files).and_return(changed_file.split("\n"))
// 130:       end
// 131:
// 132:       it "includes cask tests and excludes non-cask tests", :aggregate_failures do
// 133:         expect(changed_test_files).to include("test/cmd/outdated_spec.rb")
// 134:         expect(changed_test_files).not_to include("test/cmd/help_spec.rb")
// 135:         expect(changed_test_files).not_to include("test/dev-cmd/pr-pull_spec.rb")
// 136:         expect(changed_test_files).not_to include("test/cmd/bundle/remove_subcommand_spec.rb")
// 137:       end
// 138:     end
// 139:   end
// 140: end
