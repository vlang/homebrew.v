module mac

import ruby

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
