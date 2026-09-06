module strategy

import regex

// Translated from Homebrew/brew `livecheck/strategy/electron_builder.rb`.
pub enum ElectronBuilderSelector {
	default_version
	path_regex
	version_regex
}

pub struct ElectronBuilderRequest {
pub:
	url              string
	regex            ?string
	content          ?string
	selector         ElectronBuilderSelector
	case_insensitive bool = true
}

pub struct ElectronBuilderMatchData {
pub:
	matches map[string]string
	regex   ?string
	url     string
	cached  bool
}

pub fn electron_builder_matches_url(url string) bool {
	lower := url.to_lower()
	if !lower.starts_with('http://') && !lower.starts_with('https://') {
		return false
	}
	mut resource := url
	if query_index := resource.index('?') {
		query := resource[query_index + 1..]
		if query == '' || query.contains('/') || query.contains('?') {
			return false
		}
		resource = resource[..query_index]
	}
	path_start := if lower.starts_with('https://') { 8 } else { 7 }
	if resource.len <= path_start || !resource[path_start..].contains('/') {
		return false
	}
	filename := resource.all_after_last('/').to_lower()
	return filename != '' && (filename.ends_with('.yml') || filename.ends_with('.yaml'))
}

fn electron_builder_yaml_scalar(content string, key string) ?string {
	for line in content.split_into_lines() {
		trimmed := line.trim_space()
		prefix := '${key}:'
		if !trimmed.starts_with(prefix) {
			continue
		}
		mut value := trimmed[prefix.len..].trim_space()
		if value.len >= 2 && ((value.starts_with("'") && value.ends_with("'")) || (value.starts_with('"') && value.ends_with('"'))) {
			value = value[1..value.len - 1]
		}
		return value
	}
	return none
}

fn electron_builder_capture(pattern string, value string, case_insensitive bool) ?string {
	// Ruby accepts a trailing hyphen in a character class. Normalizing it to the
	// first position keeps the source regex's meaning with V's regex parser.
	v_pattern := pattern.replace('[._-]', '[-._]').replace('[_-]', '[-_]')
	mut expression := regex.regex_opt(v_pattern) or { return none }
	if case_insensitive {
		expression.flag |= regex.f_ci
	}
	start, _ := expression.find(value)
	if start < 0 {
		return none
	}
	capture := expression.get_group_by_id(value, 0)
	if capture == '' {
		return none
	}
	return capture
}

pub fn electron_builder_find_versions(request ElectronBuilderRequest) !ElectronBuilderMatchData {
	if supplied_regex := request.regex {
		if supplied_regex != '' && request.selector == .default_version {
			return error('ElectronBuilder only supports a regex when using a `strategy` block')
		}
	}
	mut versions := map[string]string{}
	if request.url == '' {
		return ElectronBuilderMatchData{
			matches: versions
			regex: request.regex
			url: request.url
			cached: true
		}
	}
	content := request.content or { '' }
	if content == '' {
		return ElectronBuilderMatchData{
			matches: versions
			regex: request.regex
			url: request.url
			cached: true
		}
	}
	mut version := ''
	match request.selector {
		.default_version {
			version = electron_builder_yaml_scalar(content, 'version') or { '' }
		}
		.path_regex {
			path := electron_builder_yaml_scalar(content, 'path') or { '' }
			pattern := request.regex or { '' }
			version = electron_builder_capture(pattern, path, request.case_insensitive) or { '' }
		}
		.version_regex {
			value := electron_builder_yaml_scalar(content, 'version') or { '' }
			pattern := request.regex or { r'^v?(\d+(?:\.\d+)+)$' }
			version = electron_builder_capture(pattern, value, request.case_insensitive) or { '' }
		}
	}
	if version != '' {
		versions[version] = version
	}
	return ElectronBuilderMatchData{
		matches: versions
		regex: request.regex
		url: request.url
		cached: true
	}
}
