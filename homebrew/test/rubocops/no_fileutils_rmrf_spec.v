module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/no_fileutils_rmrf_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_no_fileutils_rmrf_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "registers an offense" do` at line 10.
pub fn ruby_no_fileutils_rmrf_spec_l10_d2_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "autocorrects" do` at line 19.
pub fn ruby_no_fileutils_rmrf_spec_l19_d3_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "registers an offense" do` at line 33.
pub fn ruby_no_fileutils_rmrf_spec_l33_d4_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "autocorrects" do` at line 42.
pub fn ruby_no_fileutils_rmrf_spec_l42_d5_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "registers an offense" do` at line 56.
pub fn ruby_no_fileutils_rmrf_spec_l56_d6_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby method `buildpath` at line 63.
pub fn ruby_no_fileutils_rmrf_spec_l63_d7_buildpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('buildpath', ...args)
}

// Ruby it `it "autocorrects" do` at line 73.
pub fn ruby_no_fileutils_rmrf_spec_l73_d8_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby method `buildpath` at line 78.
pub fn ruby_no_fileutils_rmrf_spec_l78_d9_buildpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('buildpath', ...args)
}

// Ruby method `buildpath` at line 89.
pub fn ruby_no_fileutils_rmrf_spec_l89_d10_buildpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('buildpath', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/no_fileutils_rmrf"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::NoFileutilsRmrf do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   describe "rm_rf" do
// 10:     it "registers an offense" do
// 11:       expect_offense(<<~RUBY)
// 12:         rm_rf("path/to/directory")
// 13:         ^^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew/NoFileutilsRmrf: #{RuboCop::Cop::Homebrew::NoFileutilsRmrf::MSG}
// 14:         FileUtils.rm_rf("path/to/directory")
// 15:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew/NoFileutilsRmrf: #{RuboCop::Cop::Homebrew::NoFileutilsRmrf::MSG}
// 16:       RUBY
// 17:     end
// 18:
// 19:     it "autocorrects" do
// 20:       corrected = autocorrect_source(<<~RUBY)
// 21:         rm_rf("path/to/directory")
// 22:         FileUtils.rm_rf("path/to/other/directory")
// 23:       RUBY
// 24:
// 25:       expect(corrected).to eq(<<~RUBY)
// 26:         rm_r("path/to/directory")
// 27:         FileUtils.rm_r("path/to/other/directory")
// 28:       RUBY
// 29:     end
// 30:   end
// 31:
// 32:   describe "rm_f" do
// 33:     it "registers an offense" do
// 34:       expect_offense(<<~RUBY)
// 35:         rm_f("path/to/directory")
// 36:         ^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew/NoFileutilsRmrf: #{RuboCop::Cop::Homebrew::NoFileutilsRmrf::MSG}
// 37:         FileUtils.rm_f("path/to/other/directory")
// 38:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew/NoFileutilsRmrf: #{RuboCop::Cop::Homebrew::NoFileutilsRmrf::MSG}
// 39:       RUBY
// 40:     end
// 41:
// 42:     it "autocorrects" do
// 43:       corrected = autocorrect_source(<<~RUBY)
// 44:         rm_f("path/to/directory")
// 45:         FileUtils.rm_f("path/to/other/directory")
// 46:       RUBY
// 47:
// 48:       expect(corrected).to eq(<<~RUBY)
// 49:         rm("path/to/directory")
// 50:         FileUtils.rm("path/to/other/directory")
// 51:       RUBY
// 52:     end
// 53:   end
// 54:
// 55:   describe "rmtree" do
// 56:     it "registers an offense" do
// 57:       expect_offense(<<~RUBY)
// 58:         rmtree("path/to/directory")
// 59:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew/NoFileutilsRmrf: #{RuboCop::Cop::Homebrew::NoFileutilsRmrf::MSG}
// 60:         other_dir = Pathname("path/to/other/directory")
// 61:         other_dir.rmtree
// 62:         ^^^^^^^^^^^^^^^^ Homebrew/NoFileutilsRmrf: #{RuboCop::Cop::Homebrew::NoFileutilsRmrf::MSG}
// 63:         def buildpath
// 64:           Pathname("path/to/yet/another/directory")
// 65:         end
// 66:         buildpath.rmtree
// 67:         ^^^^^^^^^^^^^^^^ Homebrew/NoFileutilsRmrf: #{RuboCop::Cop::Homebrew::NoFileutilsRmrf::MSG}
// 68:         (path/"here").rmtree
// 69:         ^^^^^^^^^^^^^^^^^^^^ Homebrew/NoFileutilsRmrf: #{RuboCop::Cop::Homebrew::NoFileutilsRmrf::MSG}
// 70:       RUBY
// 71:     end
// 72:
// 73:     it "autocorrects" do
// 74:       corrected = autocorrect_source(<<~RUBY)
// 75:         rmtree("path/to/directory")
// 76:         other_dir = Pathname("path/to/other/directory")
// 77:         other_dir.rmtree
// 78:         def buildpath
// 79:           Pathname("path/to/yet/another/directory")
// 80:         end
// 81:         buildpath.rmtree
// 82:         (path/"here").rmtree
// 83:       RUBY
// 84:
// 85:       expect(corrected).to eq(<<~RUBY)
// 86:         rm_r("path/to/directory")
// 87:         other_dir = Pathname("path/to/other/directory")
// 88:         FileUtils.rm_r(other_dir)
// 89:         def buildpath
// 90:           Pathname("path/to/yet/another/directory")
// 91:         end
// 92:         FileUtils.rm_r(buildpath)
// 93:         FileUtils.rm_r(path/"here")
// 94:       RUBY
// 95:     end
// 96:   end
// 97: end
