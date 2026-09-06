module strategy

import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/launchpad.rb`.
// V's regex dot spans line breaks, so `[^<]+` preserves Ruby's capture ending
// before the closing element instead of consuming later elements in the page.
pub const launchpad_default_pattern = r'class="[^"]*version[^"]*"[^>]*>\s*Latest version is ([^<]+)\s*</'

pub struct LaunchpadInputValues {
pub:
	present bool
	url     string
}

pub struct LaunchpadFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

fn launchpad_project_name(url string) ?string {
	lower := url.to_lower()
	scheme_length := if lower.starts_with('https://') {
		'https://'.len
	} else if lower.starts_with('http://') {
		'http://'.len
	} else {
		return none
	}
	remainder := url[scheme_length..]
	host_end := remainder.index('/') or { return none }
	host := lower[scheme_length..scheme_length + host_end]
	if host != 'launchpad.net' && !(host.ends_with('.launchpad.net') && host.len > '.launchpad.net'.len) {
		return none
	}
	path := remainder[host_end + 1..]
	project_end := path.index('/') or { path.len }
	if project_end == 0 {
		return none
	}
	return path[..project_end]
}

pub fn launchpad_matches_url(url string) bool {
	return launchpad_project_name(url) != none
}

pub fn launchpad_generate_input_values(url string) LaunchpadInputValues {
	project_name := launchpad_project_name(url) or { return LaunchpadInputValues{} }

	// The main page for the project on Launchpad
	return LaunchpadInputValues{
		present: true
		url: 'https://launchpad.net/${project_name}/'
	}
}

pub fn launchpad_find_versions(request LaunchpadFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := launchpad_generate_input_values(request.url)
	effective_regex := if provided := request.regex {
		?PageMatchRegex(provided)
	} else {
		?PageMatchRegex(PageMatchRegex{
			pattern: launchpad_default_pattern
		})
	}
	return page_match_find_versions(PageMatchFindVersionsRequest{
		url: if generated.present { generated.url } else { '' }
		regex: effective_regex
		content: request.content
		options: request.options
		has_block: request.has_block
		block: request.block
	}, fetcher)
}

fn launchpad_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}
