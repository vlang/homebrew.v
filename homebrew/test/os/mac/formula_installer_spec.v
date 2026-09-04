module mac

import ruby
import homebrew.extend.os.mac as mac_installer

// Translated from Homebrew/brew `test/os/mac/formula_installer_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:keg) { described_class.new(keg_path) }` at line 8.
pub fn ruby_formula_installer_spec_l8_d1_keg(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { 'keg_path' }
	return ruby.structured_value('FormulaInstaller', 'FormulaInstaller(${path})', {
		'keg_path': path
	})
}

// Ruby subject `subject(:formula_installer) { described_class.new(Testball.new) }` at line 13.
pub fn ruby_formula_installer_spec_l13_d2_formula_installer(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('FormulaInstaller', 'Testball', {
		'formula':              'Testball'
		'installed_on_request': 'true'
	})
}

// Ruby it `it "is true when non-developer and non-outdated" do` at line 15.
pub fn ruby_formula_installer_spec_l15_d3_is(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mac_installer.mac_fresh_install(false, false, true, false))
}

// Ruby it `it "is false in developer mode" do` at line 22.
pub fn ruby_formula_installer_spec_l22_d4_is(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!mac_installer.mac_fresh_install(true, false, true, false))
}

// Ruby it `it "is false on outdated releases" do` at line 29.
pub fn ruby_formula_installer_spec_l29_d5_is(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!mac_installer.mac_fresh_install(false, true, true, false))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula_installer"
// 5: require "test/support/fixtures/testball"
// 6:
// 7: RSpec.describe FormulaInstaller do
// 8:   subject(:keg) { described_class.new(keg_path) }
// 9:
// 10:   include FileUtils
// 11:
// 12:   describe "#fresh_install" do
// 13:     subject(:formula_installer) { described_class.new(Testball.new) }
// 14:
// 15:     it "is true when non-developer and non-outdated" do
// 16:       formula = Testball.new
// 17:       allow(Homebrew::EnvConfig).to receive_messages(developer?: false)
// 18:       allow(OS::Mac.version).to receive_messages(outdated_release?: false)
// 19:       expect(formula_installer.fresh_install?(formula)).to be true
// 20:     end
// 21:
// 22:     it "is false in developer mode" do
// 23:       formula = Testball.new
// 24:       allow(Homebrew::EnvConfig).to receive_messages(developer?: true)
// 25:       allow(OS::Mac.version).to receive_messages(outdated_release?: false)
// 26:       expect(formula_installer.fresh_install?(formula)).to be false
// 27:     end
// 28:
// 29:     it "is false on outdated releases" do
// 30:       formula = Testball.new
// 31:       allow(Homebrew::EnvConfig).to receive_messages(developer?: false)
// 32:       allow(OS::Mac.version).to receive_messages(outdated_release?: true)
// 33:       expect(formula_installer.fresh_install?(formula)).to be false
// 34:     end
// 35:   end
// 36: end
