module api

// Translated from Homebrew/brew `extend/os/mac/api/internal.rb`.
pub struct MacBottleTag {
pub:
	system string
	arch   string
}

pub fn mac_api_fallback_tag(prerelease bool, newest_supported string, arch string,
	effective_tag MacBottleTag) MacBottleTag {
	if prerelease {
		return MacBottleTag{
			system: newest_supported
			arch: arch
		}
	}
	return effective_tag
}
