module utils

// Translated from Homebrew/brew `utils/ruby_check_version_script.rb`.
fn ruby_version_segments(value string) ?[]int {
	if value == '' {
		return none
	}
	mut segments := []int{}
	for part in value.split('.') {
		mut digits := ''
		for character in part {
			if !character.is_digit() {
				break
			}
			digits += character.str()
		}
		if digits == '' {
			return none
		}
		segments << digits.int()
	}
	return segments
}

fn ruby_version_at_least(running []int, required []int) bool {
	length := if running.len > required.len { running.len } else { required.len }
	for index in 0 .. length {
		left := if index < running.len { running[index] } else { 0 }
		right := if index < required.len { required[index] } else { 0 }
		if left != right {
			return left > right
		}
	}
	return true
}

// check_ruby_version translates the complete top-level script body. `true`
// corresponds to a zero exit status and `false` to Ruby's `abort`/exception.
pub fn check_ruby_version(running_version string, required_version string,
	developer_or_tests bool, use_ruby_from_path bool) bool {
	running := ruby_version_segments(running_version) or { return false }
	required := ruby_version_segments(required_version) or { return false }
	if running.len < 2 || required.len < 2 {
		return false
	}
	if developer_or_tests && use_ruby_from_path && ruby_version_at_least(running, required) {
		return true
	}
	return running[0] == required[0] && running[1] == required[1]
}
