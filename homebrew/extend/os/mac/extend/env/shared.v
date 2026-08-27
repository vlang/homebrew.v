module env

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/extend/ENV/shared.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,` at line 21.
pub fn ruby_shared_l21_d1_setup_build_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_build_environment', ...args)
}

// Ruby method `no_weak_imports_support?` at line 32.
pub fn ruby_shared_l32_d2_no_weak_imports_support(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_weak_imports_support?', ...args)
}

// Ruby method `no_fixup_chains_support?` at line 37.
pub fn ruby_shared_l37_d3_no_fixup_chains_support(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_fixup_chains_support?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module SharedEnvExtension
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
// 25:         # Normalise the system Perl version used, where multiple may be available
// 26:         self["VERSIONER_PERL_VERSION"] = MacOS.preferred_perl_version
// 27:       end
// 28:
// 29:       private
// 30:
// 31:       sig { returns(T::Boolean) }
// 32:       def no_weak_imports_support?
// 33:         compiler == :clang
// 34:       end
// 35:
// 36:       sig { returns(T::Boolean) }
// 37:       def no_fixup_chains_support?
// 38:         # This is supported starting Xcode 13, which ships ld64-711.
// 39:         # https://developer.apple.com/documentation/xcode-release-notes/xcode-13-release-notes
// 40:         # https://en.wikipedia.org/wiki/Xcode#Xcode_11.0_-_14.x_(since_SwiftUI_framework)_2
// 41:         ::DevelopmentTools.ld64_version >= 711
// 42:       end
// 43:     end
// 44:   end
// 45: end
// 46:
// 47: SharedEnvExtension.prepend(OS::Mac::SharedEnvExtension)
