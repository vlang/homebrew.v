module shared_examples

import ruby
import os

// Translated from Homebrew/brew `test/support/helper/spec/shared_examples/formulae_exist.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "#{f} formula exists", :needs_homebrew_core do` at line 9.
pub fn ruby_formulae_exist_l9_d1_f(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(formula_or_alias_exists(args[0].as_string(), args[1].as_string()))
}

pub fn formula_or_alias_exists(homebrew_library_path string, formula string) bool {
	core_tap := os.real_path(os.join_path(homebrew_library_path, '../Taps/homebrew/homebrew-core'))
	formula_root := os.join_path(core_tap, 'Formula')
	if os.is_dir(formula_root) {
		for candidate in os.walk_ext(formula_root, '.rb') {
			if os.file_name(candidate) == '${formula}.rb' && os.exists(candidate) {
				return true
			}
		}
	}
	return os.exists(os.join_path(core_tap, 'Aliases/${formula}'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.shared_examples "formulae exist" do |array|
// 5:   T.bind(self, T.class_of(RSpec::Core::ExampleGroup))
// 6:   formulae = T.cast(array, T::Array[Formula])
// 7:
// 8:   test_each(formulae) do |f|
// 9:     it "#{f} formula exists", :needs_homebrew_core do
// 10:       T.bind(self, RSpec::Core::ExampleGroup)
// 11:
// 12:       core_tap = Pathname("#{HOMEBREW_LIBRARY_PATH}/../Taps/homebrew/homebrew-core")
// 13:       formula_paths = core_tap.glob("Formula/**/#{f}.rb")
// 14:       alias_path = core_tap/"Aliases/#{f}"
// 15:       expect(formula_paths.any?(&:exist?) || alias_path.exist?).to be true
// 16:     end
// 17:   end
// 18: end
