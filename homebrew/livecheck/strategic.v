module livecheck

import ruby

// Translated from Homebrew/brew `livecheck/strategic.rb`.

pub struct StrategicFindVersionsRequest {
pub:
	url     string
	regex   string
	content string
	options ruby.Value
}

// Strategic is intentionally only an interface, matching the Ruby source: each
// built-in or third-party livecheck strategy supplies both operations.
pub interface Strategic {
	match_url(url string) bool
	find_versions(request StrategicFindVersionsRequest) map[string]ruby.Value
}
