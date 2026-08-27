module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/audit_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:audit) { described_class.new(["--tap=homebrew/test"]) }` at line 11.
pub fn ruby_audit_spec_l11_d1_audit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit', ...args)
}

// Ruby let `let(:tap_path) { mktmpdir }` at line 13.
pub fn ruby_audit_spec_l13_d2_tap_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_path', ...args)
}

// Ruby let `let(:macos_only_cask_file) { tap_path/"Casks/macos-only-example.rb" }` at line 14.
pub fn ruby_audit_spec_l14_d3_macos_only_cask_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_only_cask_file', ...args)
}

// Ruby let `let(:linux_cask_file) { tap_path/"Casks/linux-example.rb" }` at line 15.
pub fn ruby_audit_spec_l15_d4_linux_cask_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linux_cask_file', ...args)
}

// Ruby let `let(:linux_only_cask_file) { tap_path/"Casks/linux-only-example.rb" }` at line 16.
pub fn ruby_audit_spec_l16_d5_linux_only_cask_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linux_only_cask_file', ...args)
}

// Ruby let `let(:tap) do` at line 17.
pub fn ruby_audit_spec_l17_d6_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby it `it "audits Linux-supporting casks and skips macOS-only ones on Linux" do` at line 71.
pub fn ruby_audit_spec_l71_d7_audits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audits', ...args)
}

// Ruby it `it "audits Linux-only casks under Linux when running on macOS" do` at line 82.
pub fn ruby_audit_spec_l82_d8_audits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audits', ...args)
}

// Ruby it `it "enables API access when auditing external formulae after it was automatically disabled" do` at line 88.
pub fn ruby_audit_spec_l88_d9_enables(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enables', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dev-cmd/audit"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Audit do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "#run" do
// 11:     subject(:audit) { described_class.new(["--tap=homebrew/test"]) }
// 12:
// 13:     let(:tap_path) { mktmpdir }
// 14:     let(:macos_only_cask_file) { tap_path/"Casks/macos-only-example.rb" }
// 15:     let(:linux_cask_file) { tap_path/"Casks/linux-example.rb" }
// 16:     let(:linux_only_cask_file) { tap_path/"Casks/linux-only-example.rb" }
// 17:     let(:tap) do
// 18:       instance_double(Tap, formula_files: [], cask_files: [macos_only_cask_file, linux_cask_file,
// 19:                                                            linux_only_cask_file])
// 20:     end
// 21:
// 22:     before do
// 23:       macos_only_cask_file.dirname.mkpath
// 24:       macos_only_cask_file.write <<~RUBY
// 25:         cask "macos-only-example" do
// 26:           version "1.0"
// 27:           sha256 arm:   "0000000000000000000000000000000000000000000000000000000000000000",
// 28:                  intel: "1111111111111111111111111111111111111111111111111111111111111111"
// 29:           url "https://example.invalid/x-\#{version}.pkg"
// 30:           name "Example"
// 31:           desc "macOS-only cask"
// 32:           homepage "https://example.invalid/"
// 33:           depends_on macos: :ventura
// 34:           binary "x"
// 35:         end
// 36:       RUBY
// 37:       linux_cask_file.write <<~RUBY
// 38:         cask "linux-example" do
// 39:           version "1.0"
// 40:           sha256 arm:   "0000000000000000000000000000000000000000000000000000000000000000",
// 41:                  intel: "1111111111111111111111111111111111111111111111111111111111111111"
// 42:           url "https://example.invalid/x-\#{version}.tar.gz"
// 43:           name "Example"
// 44:           desc "Linux-supported cask"
// 45:           homepage "https://example.invalid/"
// 46:           binary "x"
// 47:         end
// 48:       RUBY
// 49:       linux_only_cask_file.write <<~RUBY
// 50:         cask "linux-only-example" do
// 51:           version "1.0"
// 52:           sha256 arm64_linux:  "0000000000000000000000000000000000000000000000000000000000000000",
// 53:                  x86_64_linux: "1111111111111111111111111111111111111111111111111111111111111111"
// 54:           url "https://example.invalid/x-\#{version}.tar.gz"
// 55:           name "Example"
// 56:           desc "Linux-only cask"
// 57:           homepage "https://example.invalid/"
// 58:           depends_on :linux
// 59:           binary "x"
// 60:         end
// 61:       RUBY
// 62:
// 63:       allow(Homebrew).to receive(:install_bundler_gems!)
// 64:       ENV.activate_extensions!
// 65:       allow(ENV).to receive(:setup_build_environment)
// 66:       allow(Tap).to receive(:fetch).and_call_original
// 67:       allow(Tap).to receive(:fetch).with("homebrew/test").and_return(tap)
// 68:       allow(Tap).to receive(:installed).and_return([])
// 69:     end
// 70:
// 71:     it "audits Linux-supporting casks and skips macOS-only ones on Linux" do
// 72:       problems = a_string_matching(
// 73:         /\A(?=.*linux-example)(?=.*a sha256 stanza is required)(?!.*macos-only-example).*\z/m,
// 74:       )
// 75:
// 76:       Homebrew::SimulateSystem.with(os: :linux) do
// 77:         expect { audit.run }.to output(problems).to_stdout
// 78:                                                 .and output(/1 problem in 1 cask detected/).to_stderr
// 79:       end
// 80:     end
// 81:
// 82:     it "audits Linux-only casks under Linux when running on macOS" do
// 83:       Homebrew::SimulateSystem.with(os: :macos) do
// 84:         expect { audit.run }.not_to output.to_stdout
// 85:       end
// 86:     end
// 87:
// 88:     it "enables API access when auditing external formulae after it was automatically disabled" do
// 89:       formula_file = tap_path/"Formula/example.rb"
// 90:       formula_file.dirname.mkpath
// 91:       formula_file.write <<~RUBY
// 92:         class Example < Formula
// 93:           desc "Example"
// 94:           homepage "https://example.com"
// 95:           url "https://example.com/example-1.0.tar.gz"
// 96:           sha256 "0000000000000000000000000000000000000000000000000000000000000000"
// 97:
// 98:           depends_on "dependency"
// 99:         end
// 100:       RUBY
// 101:       allow(tap).to receive_messages(formula_files: [formula_file], cask_files: [])
// 102:       formula_auditor = instance_double(Homebrew::FormulaAuditor, audit: nil, problems: [], new_formula_problems: [])
// 103:
// 104:       with_env(HOMEBREW_NO_INSTALL_FROM_API: "1", HOMEBREW_AUTOMATICALLY_SET_NO_INSTALL_FROM_API: "1") do
// 105:         expect(Homebrew::FormulaAuditor).to receive(:new) do
// 106:           expect(Homebrew::EnvConfig.no_install_from_api?).to be(false)
// 107:           formula_auditor
// 108:         end
// 109:
// 110:         audit.run
// 111:       end
// 112:     end
// 113:   end
// 114: end
