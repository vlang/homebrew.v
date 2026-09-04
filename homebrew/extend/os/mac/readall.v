module mac

import ruby

pub struct MacReadallCask {
pub:
	path             string
	url_present      bool = true
	macos_versions   []int
	macos_comparator string = '>='
	evaluation_error string
}

pub struct MacReadallResult {
pub:
	valid     bool = true
	errors    []string
	processed []string
}

fn mac_readall_version_matches(current int, comparator string, wanted int) bool {
	return match comparator {
		'==' { current == wanted }
		'!=' { current != wanted }
		'>' { current > wanted }
		'>=' { current >= wanted }
		'<' { current < wanted }
		'<=' { current <= wanted }
		else { false }
	}
}

pub fn mac_readall_valid_casks(os_name string, current_macos_version int, arch string,
	casks []MacReadallCask, linux_super_valid bool) MacReadallResult {
	if os_name == 'linux' {
		return MacReadallResult{ valid: linux_super_valid }
	}
	mut valid := true
	mut errors := []string{}
	mut processed := []string{}
	for cask in casks {
		processed << cask.path
		if cask.evaluation_error != '' {
			errors << 'Invalid cask (macOS ${current_macos_version} on ${arch}): ${cask.path}\n${cask.evaluation_error}'
			valid = false
			continue
		}
		if cask.macos_versions.len > 0 && !cask.macos_versions.any(mac_readall_version_matches(current_macos_version, cask.macos_comparator, it)) {
			continue
		}
		if !cask.url_present {
			errors << 'Invalid cask (macOS ${current_macos_version} on ${arch}): ${cask.path}\nMissing URL'
			valid = false
		}
	}
	return MacReadallResult{ valid: valid, errors: errors, processed: processed }
}

fn mac_readall_casks_from_value(value ruby.Value) ![]MacReadallCask {
	mut casks := []MacReadallCask{}
	for item in value.as_array()! {
		values := item.as_map()!
		mut versions := []int{}
		if raw := values['macos_versions'] {
			for version in raw.as_array()! {
				versions << int(version.as_int()!)
			}
		}
		casks << MacReadallCask{
			path: (values['path'] or { return error('cask path is required') }).as_string()
			url_present: (values['url_present'] or { ruby.bool_value(true) }).as_bool()!
			macos_versions: versions
			macos_comparator: (values['macos_comparator'] or { ruby.string_value('>=') }).as_string()
			evaluation_error: (values['evaluation_error'] or { ruby.string_value('') }).as_string()
		}
	}
	return casks
}

// Translated from Homebrew/brew `extend/os/mac/readall.rb`.
