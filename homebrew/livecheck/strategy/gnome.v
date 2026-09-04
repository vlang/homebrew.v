module strategy

import ruby
import homebrew
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/gnome.rb`.
pub struct GnomeInputValues {
pub:
	present bool
	url     string
	regex   PageMatchRegex
}

pub struct GnomeFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

fn gnome_package_name(url string) ?string {
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://download.gnome.org/sources/') {
		'https://download.gnome.org/sources/'.len
	} else if lower.starts_with('http://download.gnome.org/sources/') {
		'http://download.gnome.org/sources/'.len
	} else {
		return none
	}
	remainder := url[prefix_length..]
	package_end := remainder.index('/') or { return none }
	if package_end == 0 {
		return none
	}
	return remainder[..package_end]
}

fn gnome_regex_escape(value string) string {
	mut escaped := ''
	for character in value {
		match character {
			`\t` {
				escaped += r'\t'
			}
			`\n` {
				escaped += r'\n'
			}
			`\r` {
				escaped += r'\r'
			}
			`\f` {
				escaped += r'\f'
			}
			`\\`, `.`, `+`, `*`, `?`, `^`, `$`, `(`, `)`, `[`, `]`, `{`, `}`, `|`, `#`, ` ` {
				escaped += '\\${character.ascii_str()}'
			}
			else {
				escaped += character.ascii_str()
			}
		}
	}
	// Ruby's `Regexp.escape` escapes hyphens, and the source immediately
	// removes that escape with `gsub("\\-")`.
	return escaped
}

pub fn gnome_matches_url(url string) bool {
	if _ := gnome_package_name(url) {
		return true
	}
	return false
}

pub fn gnome_generate_input_values(url string) GnomeInputValues {
	package_name := gnome_package_name(url) or { return GnomeInputValues{} }
	regex_name := gnome_regex_escape(package_name)

	// GNOME archive files seem to use a standard filename format, so we
	// count on the delimiter between the package name and numeric
	// version being a hyphen and the file being a tarball.
	return GnomeInputValues{
		present: true
		url: 'https://download.gnome.org/sources/${package_name}/cache.json'
		regex: PageMatchRegex{
			pattern: '${regex_name}-(\\d+(?:\\.\\d+)*)\\.t'
			case_insensitive: true
		}
	}
}

fn gnome_unstable_version(version_text string) !bool {
	version := homebrew.new_version(version_text)!
	major := version.major() or { return false }
	if homebrew.token_operand_relation(major, '>=', 40)! {
		return false
	}
	minor := version.minor() or { return false }
	if minor.to_s().int() % 2 != 0 || homebrew.token_operand_relation(minor, '>=', 90)! {
		return true
	}
	if patch := version.patch() {
		return homebrew.token_operand_relation(patch, '>=', 90)!
	}
	return false
}

pub fn gnome_find_versions(request GnomeFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := gnome_generate_input_values(request.url)
	generated_regex := if generated.present { ?PageMatchRegex(generated.regex) } else { none }
	effective_regex := if provided := request.regex {
		?PageMatchRegex(provided)
	} else {
		generated_regex
	}
	match_data := page_match_find_versions(PageMatchFindVersionsRequest{
		url: if generated.present { generated.url } else { '' }
		regex: effective_regex
		content: request.content
		options: request.options
		has_block: request.has_block
		block: request.block
	}, fetcher)!
	if request.regex != none {
		return match_data
	}

	// Filter out unstable versions using the old version scheme where
	// the major version is below 40.
	mut matches := map[string]string{}
	for match_text, version_text in match_data.matches {
		if !gnome_unstable_version(version_text)! {
			matches[match_text] = version_text
		}
	}
	return PageMatchData{
		...match_data
		matches: matches
	}
}

fn gnome_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn gnome_match_data_value(result PageMatchData) ruby.Value {
	mut matches := map[string]ruby.Value{}
	for version in result.matches.keys() {
		matches[version] = ruby.object_value('Version', version)
	}
	regex_value := result.regex or { PageMatchRegex{} }
	mut values := {
		'matches': ruby.map_value(matches)
		'regex':   if regex_value.pattern == '' {
			ruby.object_value('NilClass', 'nil')
		} else {
			ruby.object_value('Regexp', regex_value.pattern)
		}
		'url':     ruby.string_value(result.url)
	}
	if result.has_cached {
		values['cached'] = ruby.bool_value(result.cached)
	}
	if result.has_content {
		values['content'] = ruby.string_value(result.content)
	}
	if result.has_final_url {
		values['final_url'] = ruby.string_value(result.final_url)
	}
	if result.has_messages {
		values['messages'] = ruby.string_array_value(result.messages)
	}
	return ruby.map_value(values)
}
