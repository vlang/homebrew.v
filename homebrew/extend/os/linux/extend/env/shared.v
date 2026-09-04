module env

// Translated from Homebrew/brew `extend/os/linux/extend/ENV/shared.rb`.
pub fn linux_effective_arch(build_bottle bool, bottle_arch string, oldest_cpu string,
	is_intel bool, is_arm bool) string {
	if build_bottle && bottle_arch != '' {
		return bottle_arch
	}
	if build_bottle {
		return oldest_cpu
	}
	if is_intel || is_arm {
		return 'native'
	}
	return 'dunno'
}
