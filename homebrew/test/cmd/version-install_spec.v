module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/version-install_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:version_install) { described_class.new(args) }` at line 8.
pub fn ruby_version_install_spec_l8_d1_version_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version_install', ...args)
}

// Ruby let `let(:formulary_factory) { ->(ref, **_opts) { raise FormulaUnavailableError, ref } }` at line 10.
pub fn ruby_version_install_spec_l10_d2_formulary_factory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulary_factory', ...args)
}

// Ruby let `let(:installed_taps) { [] }` at line 11.
pub fn ruby_version_install_spec_l11_d3_installed_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_taps', ...args)
}

// Ruby let `let(:installed_formula_names) { [] }` at line 12.
pub fn ruby_version_install_spec_l12_d4_installed_formula_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_formula_names', ...args)
}

// Ruby let `let(:tap_name) { "tester/homebrew-versions" }` at line 13.
pub fn ruby_version_install_spec_l13_d5_tap_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_name', ...args)
}

// Ruby let `let(:versioned_name) { "#{formula}@#{version}" }` at line 14.
pub fn ruby_version_install_spec_l14_d6_versioned_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('versioned_name', ...args)
}

// Ruby let `let(:args) { [formula, version] }` at line 15.
pub fn ruby_version_install_spec_l15_d7_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby let `let(:version) { "1.2" }` at line 16.
pub fn ruby_version_install_spec_l16_d8_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby let `let(:formula) { "foo" }` at line 17.
pub fn ruby_version_install_spec_l17_d9_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby let `let(:installed_formula_names) { [versioned_name] }` at line 29.
pub fn ruby_version_install_spec_l29_d10_installed_formula_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_formula_names', ...args)
}

// Ruby it `it "skips installation" do` at line 31.
pub fn ruby_version_install_spec_l31_d11_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby let `let(:existing_tap_name) { "alice/homebrew-versions" }` at line 39.
pub fn ruby_version_install_spec_l39_d12_existing_tap_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('existing_tap_name', ...args)
}

// Ruby let `let(:existing_tap) do` at line 40.
pub fn ruby_version_install_spec_l40_d13_existing_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('existing_tap', ...args)
}

// Ruby let `let(:installed_taps) { [existing_tap] }` at line 47.
pub fn ruby_version_install_spec_l47_d14_installed_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_taps', ...args)
}

// Ruby let `let(:install_target) { "#{existing_tap_name}/#{versioned_name}" }` at line 48.
pub fn ruby_version_install_spec_l48_d15_install_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_target', ...args)
}

// Ruby it `it "installs from the existing tap extraction" do` at line 54.
pub fn ruby_version_install_spec_l54_d16_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installs', ...args)
}

// Ruby let `let(:args) { ["#{formula}@#{version}"] }` at line 63.
pub fn ruby_version_install_spec_l63_d17_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby let `let(:versioned_formula) { instance_double(Formula, full_name: "homebrew/core/#{versioned_name}") }` at line 64.
pub fn ruby_version_install_spec_l64_d18_versioned_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('versioned_formula', ...args)
}

// Ruby let `let(:install_target) { "homebrew/core/#{versioned_name}" }` at line 65.
pub fn ruby_version_install_spec_l65_d19_install_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_target', ...args)
}

// Ruby let `let(:formulary_factory) do` at line 66.
pub fn ruby_version_install_spec_l66_d20_formulary_factory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulary_factory', ...args)
}

// Ruby it `it "installs a versioned formula that already exists" do` at line 74.
pub fn ruby_version_install_spec_l74_d21_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installs', ...args)
}

// Ruby let `let(:current_formula) { instance_double(Formula, full_name: "homebrew/core/#{formula}", name: formula, version:) }` at line 83.
pub fn ruby_version_install_spec_l83_d22_current_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current_formula', ...args)
}

// Ruby let `let(:install_target) { "homebrew/core/#{formula}" }` at line 84.
pub fn ruby_version_install_spec_l84_d23_install_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_target', ...args)
}

// Ruby let `let(:formulary_factory) do` at line 85.
pub fn ruby_version_install_spec_l85_d24_formulary_factory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulary_factory', ...args)
}

// Ruby it `it "installs the current formula" do` at line 94.
pub fn ruby_version_install_spec_l94_d25_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installs', ...args)
}

// Ruby let `let(:installed_formula_names) { [formula] }` at line 102.
pub fn ruby_version_install_spec_l102_d26_installed_formula_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_formula_names', ...args)
}

// Ruby it `it "skips installation" do` at line 104.
pub fn ruby_version_install_spec_l104_d27_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby let `let(:tap_installed) { false }` at line 113.
pub fn ruby_version_install_spec_l113_d28_tap_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_installed', ...args)
}

// Ruby let `let(:tap) { instance_double(Tap, name: tap_name, installed?: tap_installed) }` at line 114.
pub fn ruby_version_install_spec_l114_d29_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby it `it "extracts into a new tap when needed" do` at line 122.
pub fn ruby_version_install_spec_l122_d30_extracts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extracts', ...args)
}

// Ruby let `let(:tap_installed) { true }` at line 134.
pub fn ruby_version_install_spec_l134_d31_tap_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_installed', ...args)
}

// Ruby it `it "skips tap creation" do` at line 136.
pub fn ruby_version_install_spec_l136_d32_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cmd/version-install"
// 6:
// 7: RSpec.describe Homebrew::Cmd::VersionInstall do
// 8:   subject(:version_install) { described_class.new(args) }
// 9:
// 10:   let(:formulary_factory) { ->(ref, **_opts) { raise FormulaUnavailableError, ref } }
// 11:   let(:installed_taps) { [] }
// 12:   let(:installed_formula_names) { [] }
// 13:   let(:tap_name) { "tester/homebrew-versions" }
// 14:   let(:versioned_name) { "#{formula}@#{version}" }
// 15:   let(:args) { [formula, version] }
// 16:   let(:version) { "1.2" }
// 17:   let(:formula) { "foo" }
// 18:
// 19:   before do
// 20:     allow(Tap).to receive(:installed).and_return(installed_taps)
// 21:     allow(Formula).to receive(:installed_formula_names).and_return(installed_formula_names)
// 22:     allow(Homebrew::EnvConfig).to receive(:no_github_api?).and_return(true)
// 23:     allow(Formulary).to receive(:factory) { |ref, **opts| formulary_factory.call(ref, **opts) }
// 24:   end
// 25:
// 26:   it_behaves_like "parseable arguments"
// 27:
// 28:   context "when the versioned formula is already installed" do
// 29:     let(:installed_formula_names) { [versioned_name] }
// 30:
// 31:     it "skips installation" do
// 32:       expect(version_install).not_to receive(:safe_system)
// 33:
// 34:       version_install.run
// 35:     end
// 36:   end
// 37:
// 38:   context "when a tap already contains the versioned formula" do
// 39:     let(:existing_tap_name) { "alice/homebrew-versions" }
// 40:     let(:existing_tap) do
// 41:       instance_double(
// 42:         Tap,
// 43:         name:                  existing_tap_name,
// 44:         formula_files_by_name: { versioned_name => Pathname("/tmp/#{versioned_name}.rb") },
// 45:       )
// 46:     end
// 47:     let(:installed_taps) { [existing_tap] }
// 48:     let(:install_target) { "#{existing_tap_name}/#{versioned_name}" }
// 49:
// 50:     before do
// 51:       allow(existing_tap).to receive(:to_s).and_return(existing_tap_name)
// 52:     end
// 53:
// 54:     it "installs from the existing tap extraction" do
// 55:       expect(version_install).to receive(:safe_system)
// 56:         .with(HOMEBREW_BREW_FILE, "install", install_target).once
// 57:
// 58:       version_install.run
// 59:     end
// 60:   end
// 61:
// 62:   context "with formula@version input" do
// 63:     let(:args) { ["#{formula}@#{version}"] }
// 64:     let(:versioned_formula) { instance_double(Formula, full_name: "homebrew/core/#{versioned_name}") }
// 65:     let(:install_target) { "homebrew/core/#{versioned_name}" }
// 66:     let(:formulary_factory) do
// 67:       lambda do |ref, **_opts|
// 68:         return versioned_formula if ref == "#{formula}@#{version}"
// 69:
// 70:         raise FormulaUnavailableError, ref
// 71:       end
// 72:     end
// 73:
// 74:     it "installs a versioned formula that already exists" do
// 75:       expect(version_install).to receive(:safe_system)
// 76:         .with(HOMEBREW_BREW_FILE, "install", install_target).once
// 77:
// 78:       version_install.run
// 79:     end
// 80:   end
// 81:
// 82:   context "when the current formula matches the requested version" do
// 83:     let(:current_formula) { instance_double(Formula, full_name: "homebrew/core/#{formula}", name: formula, version:) }
// 84:     let(:install_target) { "homebrew/core/#{formula}" }
// 85:     let(:formulary_factory) do
// 86:       lambda do |ref, **_opts|
// 87:         return current_formula if ref == formula
// 88:         raise FormulaUnavailableError, ref if ref == "#{formula}@#{version}"
// 89:
// 90:         raise "Unexpected ref: #{ref}"
// 91:       end
// 92:     end
// 93:
// 94:     it "installs the current formula" do
// 95:       expect(version_install).to receive(:safe_system)
// 96:         .with(HOMEBREW_BREW_FILE, "install", install_target).once
// 97:
// 98:       version_install.run
// 99:     end
// 100:
// 101:     context "when the current formula is already installed" do
// 102:       let(:installed_formula_names) { [formula] }
// 103:
// 104:       it "skips installation" do
// 105:         expect(version_install).not_to receive(:safe_system)
// 106:
// 107:         version_install.run
// 108:       end
// 109:     end
// 110:   end
// 111:
// 112:   context "when extracting into a tap" do
// 113:     let(:tap_installed) { false }
// 114:     let(:tap) { instance_double(Tap, name: tap_name, installed?: tap_installed) }
// 115:
// 116:     before do
// 117:       allow(User).to receive(:current).and_return("tester")
// 118:       allow(tap).to receive(:to_s).and_return(tap_name)
// 119:       allow(Tap).to receive(:fetch).with(tap_name).and_return(tap)
// 120:     end
// 121:
// 122:     it "extracts into a new tap when needed" do
// 123:       expect(version_install).to receive(:safe_system)
// 124:         .with(HOMEBREW_BREW_FILE, "tap-new", "--no-git", tap_name).ordered
// 125:       expect(version_install).to receive(:safe_system)
// 126:         .with(HOMEBREW_BREW_FILE, "extract", formula, tap_name, "--version=#{version}").ordered
// 127:       expect(version_install).to receive(:safe_system)
// 128:         .with(HOMEBREW_BREW_FILE, "install", "#{tap_name}/#{versioned_name}").ordered
// 129:
// 130:       version_install.run
// 131:     end
// 132:
// 133:     context "when the tap already exists" do
// 134:       let(:tap_installed) { true }
// 135:
// 136:       it "skips tap creation" do
// 137:         expect(version_install).to receive(:safe_system)
// 138:           .with(HOMEBREW_BREW_FILE, "extract", formula, tap_name, "--version=#{version}").ordered
// 139:         expect(version_install).to receive(:safe_system)
// 140:           .with(HOMEBREW_BREW_FILE, "install", "#{tap_name}/#{versioned_name}").ordered
// 141:
// 142:         version_install.run
// 143:       end
// 144:     end
// 145:   end
// 146: end
