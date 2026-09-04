module linux

// Translated from Homebrew/brew `os/linux/kernel.rb`.

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
