module test

import brew_runtime

// Translated from Homebrew/brew `test/formula_installer_bottle_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby alias_matcher `alias_matcher :pour_bottle, :be_pour_bottle` at line 14.
pub fn ruby_formula_installer_bottle_spec_l14_d1_pour_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pour_bottle', ...args)
}

// Ruby matcher `matcher :be_poured_from_bottle do` at line 16.
pub fn ruby_formula_installer_bottle_spec_l16_d2_be_poured_from_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_poured_from_bottle', ...args)
}

// Ruby method `temporarily_install_bottle(formula)` at line 20.
pub fn ruby_formula_installer_bottle_spec_l20_d3_temporarily_install_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('temporarily_install_bottle', ...args)
}

// Ruby method `test_basic_formula_setup(formula)` at line 62.
pub fn ruby_formula_installer_bottle_spec_l62_d4_test_basic_formula_setup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test_basic_formula_setup', ...args)
}

// Ruby specify `specify "basic bottle install" do` at line 82.
pub fn ruby_formula_installer_bottle_spec_l82_d5_basic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('basic', ...args)
}

// Ruby specify `specify "basic bottle install with cellar information on sha256 line" do` at line 91.
pub fn ruby_formula_installer_bottle_spec_l91_d6_basic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('basic', ...args)
}

// Ruby specify `specify "bottle install with a corrupt cached download", :aggregate_failures do` at line 105.
pub fn ruby_formula_installer_bottle_spec_l105_d7_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle', ...args)
}

// Ruby specify `specify "build tools error" do` at line 134.
pub fn ruby_formula_installer_bottle_spec_l134_d8_build(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "formula_installer"
// 6: require "keg"
// 7: require "tab"
// 8: require "cmd/install"
// 9: require "test/support/fixtures/testball"
// 10: require "test/support/fixtures/testball_bottle"
// 11: require "test/support/fixtures/testball_bottle_cellar"
// 12:
// 13: RSpec.describe FormulaInstaller do
// 14:   alias_matcher :pour_bottle, :be_pour_bottle
// 15:
// 16:   matcher :be_poured_from_bottle do
// 17:     match(&:poured_from_bottle)
// 18:   end
// 19:
// 20:   def temporarily_install_bottle(formula)
// 21:     expect(formula).not_to be_latest_version_installed
// 22:     expect(formula).to be_bottled
// 23:     expect(formula).to pour_bottle
// 24:
// 25:     stub_formula_loader(
// 26:       formula("gcc") do
// 27:         T.bind(self, T.class_of(Formula))
// 28:         url "gcc-1.0"
// 29:       end,
// 30:     )
// 31:     stub_formula_loader(
// 32:       formula("glibc") do
// 33:         T.bind(self, T.class_of(Formula))
// 34:         url "glibc-1.0"
// 35:       end,
// 36:     )
// 37:     stub_formula_loader formula
// 38:
// 39:     fi = FormulaInstaller.new(formula)
// 40:     fi.fetch
// 41:     fi.install
// 42:
// 43:     keg = Keg.new(formula.prefix)
// 44:
// 45:     expect(formula).to be_latest_version_installed
// 46:
// 47:     begin
// 48:       expect(keg.tab).to be_poured_from_bottle
// 49:
// 50:       yield formula
// 51:     ensure
// 52:       keg.unlink
// 53:       keg.uninstall
// 54:       formula.clear_cache
// 55:       formula.bottle.clear_cache
// 56:     end
// 57:
// 58:     expect(keg).not_to exist
// 59:     expect(formula).not_to be_latest_version_installed
// 60:   end
// 61:
// 62:   def test_basic_formula_setup(formula)
// 63:     # Test that things made it into the Keg
// 64:     expect(formula.bin).to be_a_directory
// 65:
// 66:     expect(formula.libexec).to be_a_directory
// 67:
// 68:     expect(formula.prefix/"main.c").not_to exist
// 69:
// 70:     # Test that things made it into the Cellar
// 71:     keg = Keg.new formula.prefix
// 72:     keg.link
// 73:
// 74:     bin = HOMEBREW_PREFIX/"bin"
// 75:     expect(bin).to be_a_directory
// 76:
// 77:     expect(formula.libexec).to be_a_directory
// 78:   end
// 79:
// 80:   # This test wraps expect() calls in `test_basic_formula_setup`
// 81:   # rubocop:disable RSpec/NoExpectationExample
// 82:   specify "basic bottle install" do
// 83:     allow(DevelopmentTools).to receive(:installed?).and_return(false)
// 84:     Homebrew::Cmd::InstallCmd.new(["testball_bottle"])
// 85:     temporarily_install_bottle(TestballBottle.new) do |f|
// 86:       test_basic_formula_setup(f)
// 87:     end
// 88:   end
// 89:   # rubocop:enable RSpec/NoExpectationExample
// 90:
// 91:   specify "basic bottle install with cellar information on sha256 line" do
// 92:     allow(DevelopmentTools).to receive(:installed?).and_return(false)
// 93:     Homebrew::Cmd::InstallCmd.new(["testball_bottle_cellar"])
// 94:     temporarily_install_bottle(TestballBottleCellar.new) do |f|
// 95:       test_basic_formula_setup(f)
// 96:
// 97:       # skip_relocation is always false on Linux but can be true on macOS.
// 98:       # see: extend/os/linux/software_spec.rb
// 99:       skip_relocation = !OS.linux?
// 100:
// 101:       expect(f.bottle_specification.skip_relocation?).to eq(skip_relocation)
// 102:     end
// 103:   end
// 104:
// 105:   specify "bottle install with a corrupt cached download", :aggregate_failures do
// 106:     allow(DevelopmentTools).to receive(:installed?).and_return(false)
// 107:     formula = TestballBottle.new
// 108:     bottle = formula.bottle
// 109:     stub_formula_loader formula
// 110:
// 111:     # Simulate a GitHub Packages bottle blob, which is trusted without being
// 112:     # rehashed, so this corrupt download is only noticed when it fails to
// 113:     # extract and must then be discarded and downloaded again.
// 114:     bottle.cached_download.dirname.mkpath
// 115:     bottle.cached_download.write("corrupt" * 1000)
// 116:     allow(bottle).to receive(:downloaded_and_valid?).and_return(true)
// 117:
// 118:     formula_installer = described_class.new(formula)
// 119:     begin
// 120:       expect do
// 121:         Homebrew::Install.fetch_formulae([formula_installer])
// 122:         formula_installer.install
// 123:       end.to output(/Removing corrupt cached download/).to_stderr
// 124:
// 125:       expect(formula).to be_latest_version_installed
// 126:       expect(Homebrew).not_to have_failed
// 127:     ensure
// 128:       Keg.new(formula.prefix).uninstall if formula.prefix.directory?
// 129:       formula.clear_cache
// 130:       bottle.clear_cache
// 131:     end
// 132:   end
// 133:
// 134:   specify "build tools error" do
// 135:     allow(DevelopmentTools).to receive(:installed?).and_return(false)
// 136:
// 137:     # Testball doesn't have a bottle block, so use it to test this behavior
// 138:     formula = Testball.new
// 139:
// 140:     expect(formula).not_to be_latest_version_installed
// 141:     expect(formula).not_to be_bottled
// 142:
// 143:     expect do
// 144:       described_class.new(formula).install
// 145:     end.to raise_error(SystemExit)
// 146:
// 147:     expect(formula).not_to be_latest_version_installed
// 148:   end
// 149: end
