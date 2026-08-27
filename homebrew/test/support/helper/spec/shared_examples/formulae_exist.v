module shared_examples

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/spec/shared_examples/formulae_exist.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "#{f} formula exists", :needs_homebrew_core do` at line 9.
pub fn ruby_formulae_exist_l9_d1_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#{f}', ...args)
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
