module env

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/extend/ENV/std.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,` at line 21.
pub fn ruby_std_l21_d1_setup_build_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_build_environment', ...args)
}

// Ruby method `libxml2` at line 37.
pub fn ruby_std_l37_d2_libxml2(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('libxml2', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Stdenv
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::SharedEnvExtension }
// 10:
// 11:       sig {
// 12:         params(
// 13:           formula:         T.nilable(::Formula),
// 14:           cc:              T.nilable(String),
// 15:           build_bottle:    T.nilable(T::Boolean),
// 16:           bottle_arch:     T.nilable(String),
// 17:           testing_formula: T::Boolean,
// 18:           debug_symbols:   T.nilable(T::Boolean),
// 19:         ).void
// 20:       }
// 21:       def setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,
// 22:                                   testing_formula: false, debug_symbols: false)
// 23:         super
// 24:
// 25:         prepend_path "CPATH", HOMEBREW_PREFIX/"include"
// 26:         prepend_path "LIBRARY_PATH", HOMEBREW_PREFIX/"lib"
// 27:         prepend_path "LD_RUN_PATH", HOMEBREW_PREFIX/"lib"
// 28:
// 29:         return unless formula
// 30:
// 31:         prepend_path "CPATH", formula.include
// 32:         prepend_path "LIBRARY_PATH", formula.lib
// 33:         prepend_path "LD_RUN_PATH", formula.lib
// 34:       end
// 35:
// 36:       sig { void }
// 37:       def libxml2
// 38:         append "CPPFLAGS", "-I#{::Formula["libxml2"].include/"libxml2"}"
// 39:       rescue FormulaUnavailableError
// 40:         nil
// 41:       end
// 42:     end
// 43:   end
// 44: end
// 45:
// 46: Stdenv.prepend(OS::Linux::Stdenv)
