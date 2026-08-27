module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/formula_cellar_checks.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `valid_library_extension?(filename)` at line 8.
pub fn ruby_formula_cellar_checks_l8_d1_valid_library_extension(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_library_extension?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module FormulaCellarChecks
// 7:       sig { params(filename: ::Pathname).returns(T::Boolean) }
// 8:       def valid_library_extension?(filename)
// 9:         super || filename.basename.to_s.include?(".so.")
// 10:       end
// 11:     end
// 12:   end
// 13: end
// 14:
// 15: FormulaCellarChecks.prepend(OS::Linux::FormulaCellarChecks)
