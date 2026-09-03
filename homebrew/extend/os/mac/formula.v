module mac

import brew_runtime

pub fn mac_formula_valid_platform(supports_macos bool) bool {
	return supports_macos
}

pub fn mac_formula_std_cmake_args(base []string, sdk_path string) []string {
	mut arguments := base.clone()
	arguments << '-DCMAKE_OSX_SYSROOT=${sdk_path}'
	return arguments
}

pub fn mac_formula_std_swift_args(base []string) []string {
	mut arguments := ['--disable-sandbox']
	arguments << base
	return arguments
}

pub fn mac_formula_std_zig_args(base []string, arm bool) []string {
	mut arguments := base.clone()
	if arm { arguments << '-fno-rosetta' }
	return arguments
}

// Translated from Homebrew/brew `extend/os/mac/formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `valid_platform?` at line 12.
pub fn ruby_formula_l12_d1_valid_platform(args ...brew_runtime.Value) brew_runtime.Value {
	supports := if args.len > 0 { args[0].as_bool() or { panic(err) } } else { true }
	return brew_runtime.bool_value(mac_formula_valid_platform(supports))
}

// Ruby method `std_cmake_args(install_prefix: prefix, install_libdir: "lib", find_framework: "LAST")` at line 23.
pub fn ruby_formula_l23_d2_std_cmake_args(args ...brew_runtime.Value) brew_runtime.Value {
	base := if args.len > 0 { args[0].as_string_array() or { panic(err) } } else { []string{} }
	if args.len < 2 { panic('std_cmake_args requires the formula SDK path') }
	return brew_runtime.string_array_value(mac_formula_std_cmake_args(base, args[1].as_string()))
}

// Ruby method `std_swift_args` at line 33.
pub fn ruby_formula_l33_d3_std_swift_args(args ...brew_runtime.Value) brew_runtime.Value {
	base := if args.len > 0 { args[0].as_string_array() or { panic(err) } } else { []string{} }
	return brew_runtime.string_array_value(mac_formula_std_swift_args(base))
}

// Ruby method `std_zig_args(prefix: self.prefix, release_mode: :fast, cpu: nil)` at line 44.
pub fn ruby_formula_l44_d4_std_zig_args(args ...brew_runtime.Value) brew_runtime.Value {
	base := if args.len > 0 { args[0].as_string_array() or { panic(err) } } else { []string{} }
	arm := if args.len > 1 { args[1].as_bool() or { panic(err) } } else { false }
	return brew_runtime.string_array_value(mac_formula_std_zig_args(base, arm))
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
