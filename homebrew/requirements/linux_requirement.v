module requirements

import ruby

// Translated from Homebrew/brew `requirements/linux_requirement.rb`.

pub fn linux_requirement_satisfied() bool {
	return ruby.kernel_info().name == 'Linux'
}
