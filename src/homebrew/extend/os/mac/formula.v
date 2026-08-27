module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `valid_platform?` at line 12.
pub fn ruby_formula_l12_d1_valid_platform(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_platform?', ...args)
}

// Ruby method `std_cmake_args(install_prefix: prefix, install_libdir: "lib", find_framework: "LAST")` at line 23.
pub fn ruby_formula_l23_d2_std_cmake_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('std_cmake_args', ...args)
}

// Ruby method `std_swift_args` at line 33.
pub fn ruby_formula_l33_d3_std_swift_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('std_swift_args', ...args)
}

// Ruby method `std_zig_args(prefix: self.prefix, release_mode: :fast, cpu: nil)` at line 44.
pub fn ruby_formula_l44_d4_std_zig_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('std_zig_args', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Formula
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::Formula }
// 10:
// 11:       sig { returns(T::Boolean) }
// 12:       def valid_platform?
// 13:         supports_macos?
// 14:       end
// 15:
// 16:       sig {
// 17:         params(
// 18:           install_prefix: T.any(String, ::Pathname),
// 19:           install_libdir: T.any(String, ::Pathname),
// 20:           find_framework: String,
// 21:         ).returns(T::Array[String])
// 22:       }
// 23:       def std_cmake_args(install_prefix: prefix, install_libdir: "lib", find_framework: "LAST")
// 24:         args = super
// 25:
// 26:         # Ensure CMake is using the same SDK we are using.
// 27:         args << "-DCMAKE_OSX_SYSROOT=#{T.must(MacOS.sdk_for_formula(self)).path}"
// 28:
// 29:         args
// 30:       end
// 31:
// 32:       sig { returns(T::Array[String]) }
// 33:       def std_swift_args
// 34:         ["--disable-sandbox"].concat(super)
// 35:       end
// 36:
// 37:       sig {
// 38:         params(
// 39:           prefix:       T.any(String, ::Pathname),
// 40:           release_mode: Symbol,
// 41:           cpu:          T.nilable(Symbol),
// 42:         ).returns(T::Array[String])
// 43:       }
// 44:       def std_zig_args(prefix: self.prefix, release_mode: :fast, cpu: nil)
// 45:         args = super
// 46:         args << "-fno-rosetta" if ::Hardware::CPU.arm?
// 47:         args
// 48:       end
// 49:     end
// 50:   end
// 51: end
// 52:
// 53: Formula.prepend(OS::Mac::Formula)
