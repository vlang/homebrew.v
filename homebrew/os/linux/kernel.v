module linux

// Translated from Homebrew/brew `os/linux/kernel.rb`.
// The original source is retained below until every stub has a typed V body.

pub fn minimum_kernel_version() string {
	return '3.2'
}

fn kernel_version_parts(version string) []int {
	mut parts := []int{}
	for part in version.split('.') {
		mut digits := ''
		for character in part {
			if character >= `0` && character <= `9` {
				digits += character.ascii_str()
			} else {
				break
			}
		}
		parts << if digits == '' { 0 } else { digits.int() }
	}
	return parts
}

pub fn kernel_version_below_minimum(kernel_version string) bool {
	actual := kernel_version_parts(kernel_version)
	minimum := kernel_version_parts(minimum_kernel_version())
	maximum_parts := if actual.len > minimum.len {
		actual.len
	} else {
		minimum.len
	}
	for index in 0 .. maximum_parts {
		actual_part := if index < actual.len { actual[index] } else { 0 }
		minimum_part := if index < minimum.len { minimum[index] } else { 0 }
		if actual_part != minimum_part {
			return actual_part < minimum_part
		}
	}
	return false
}

// Ruby method `minimum_version` at line 11.
pub fn ruby_kernel_l11_d1_minimum_version() string {
	return minimum_kernel_version()
}

// Ruby method `below_minimum_version?` at line 16.
pub fn ruby_kernel_l16_d2_below_minimum_version(kernel_version string) bool {
	return kernel_version_below_minimum(kernel_version)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     # Helper functions for querying Linux kernel information.
// 7:     module Kernel
// 8:       module_function
// 9:
// 10:       sig { returns(Version) }
// 11:       def minimum_version
// 12:         Version.new "3.2"
// 13:       end
// 14:
// 15:       sig { returns(T::Boolean) }
// 16:       def below_minimum_version?
// 17:         OS.kernel_version < minimum_version
// 18:       end
// 19:     end
// 20:   end
// 21: end
