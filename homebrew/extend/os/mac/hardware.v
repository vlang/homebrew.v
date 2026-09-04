module mac

// Translated from Homebrew/brew `extend/os/mac/hardware.rb`.
fn macos_version_number(version string) int {
	return match version.to_lower() {
		'ventura' { 1300 }
		'sonoma' { 1400 }
		'sequoia' { 1500 }
		'tahoe' { 1600 }
		'catalina' { 1015 }
		'big_sur' { 1100 }
		'monterey' { 1200 }
		else {
			parts := version.split('.')
			if parts.len == 0 {
				0
			} else {
				parts[0].int() * 100 + if parts.len > 1 { parts[1].int() } else { 0 }
			}
		}
	}
}

pub fn mac_oldest_cpu(version string, arm64 bool, inherited_cpu string) string {
	if arm64 {
		return 'arm_vortex_tempest'
	}
	version_number := macos_version_number(version)
	if version_number >= 1300 {
		return 'westmere'
	}
	if version_number >= 1015 {
		return 'nehalem'
	}
	return inherited_cpu
}
