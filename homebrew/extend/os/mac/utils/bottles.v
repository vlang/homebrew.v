module utils

import ruby

// Translated from Homebrew/brew `extend/os/mac/utils/bottles.rb`.
pub struct MacBottlesMatchContext {
pub:
	version_prerelease    bool
	developer             bool
	skip_or_later_bottles bool
}

const mac_bottles_versions = {
	'golden_gate': '27'
	'tahoe':       '26'
	'sequoia':     '15'
	'sonoma':      '14'
	'ventura':     '13'
	'monterey':    '12'
	'big_sur':     '11'
	'catalina':    '10.15'
}

fn mac_bottles_tag_value(system string, arch string) ruby.Value {
	standard_arch := if arch == 'intel' {
		'x86_64'
	} else if arch in ['arm', 'aarch64'] { 'arm64' } else { arch }
	symbol := if system == 'all' && standard_arch == 'all' {
		'all'
	} else if system in mac_bottles_versions && standard_arch == 'x86_64' {
		system
	} else {
		'${standard_arch}_${system}'
	}
	return ruby.structured_value('Utils::Bottles::Tag', symbol, {
		'system': system
		'arch':   arch
	})
}

fn mac_bottles_current_tag_value() ruby.Value {
	information := ruby.kernel_info()
	mut system := information.name.to_lower()
	if system == 'darwin' {
		system = match information.release.all_before('.').int() {
			26 { 'golden_gate' }
			25 { 'tahoe' }
			24 { 'sequoia' }
			23 { 'sonoma' }
			22 { 'ventura' }
			21 { 'monterey' }
			20 { 'big_sur' }
			19 { 'catalina' }
			else { information.release.all_before('.') }
		}
	}
	configured_system := ruby.environment_value('HOMEBREW_BOTTLE_SYSTEM')
	if configured_system != '' {
		system = configured_system.to_lower()
	}
	mut arch := 'x86_64'
	$if arm64 {
		arch = 'arm64'
	} $else $if aarch64 {
		arch = 'arm64'
	}
	configured_arch := ruby.environment_value('HOMEBREW_PROCESSOR')
	if configured_arch != '' {
		arch = configured_arch.to_lower()
	}
	return mac_bottles_tag_value(system, arch)
}

fn mac_bottles_system(tag ruby.Value) string {
	return tag.attributes['system'] or { tag.repr }
}

fn mac_bottles_arch(tag ruby.Value) string {
	arch := tag.attributes['arch'] or { 'x86_64' }
	return if arch in ['x86_64', 'intel'] {
		'x86_64'
	} else if arch in ['arm64', 'arm', 'aarch64'] {
		'arm64'
	} else {
		arch
	}
}

fn mac_bottles_version_parts(tag ruby.Value) ![]int {
	version := mac_bottles_versions[mac_bottles_system(tag)] or {
		return error('unknown or unsupported macOS version: ${mac_bottles_system(tag)}')
	}
	return version.split('.').map(it.int())
}

fn mac_bottles_version_not_newer(candidate ruby.Value,
	requested ruby.Value) !bool {
	candidate_parts := mac_bottles_version_parts(candidate)!
	requested_parts := mac_bottles_version_parts(requested)!
	maximum_length := if candidate_parts.len > requested_parts.len {
		candidate_parts.len
	} else {
		requested_parts.len
	}
	for index in 0 .. maximum_length {
		candidate_part := if index < candidate_parts.len { candidate_parts[index] } else { 0 }
		requested_part := if index < requested_parts.len { requested_parts[index] } else { 0 }
		if candidate_part < requested_part {
			return true
		}
		if candidate_part > requested_part {
			return false
		}
	}
	return true
}

fn mac_bottles_collector_tags(collector ruby.Value) []ruby.Value {
	mut tags := []ruby.Value{}
	for specification in collector.array_data {
		if tag := specification.map_data['tag'] {
			tags << tag
		} else if specification.type_name == 'Utils::Bottles::Tag' {
			tags << specification
		}
	}
	return tags
}

fn mac_bottles_exact_tag(collector ruby.Value,
	tag ruby.Value) ?ruby.Value {
	for candidate in mac_bottles_collector_tags(collector) {
		if candidate.repr == tag.repr {
			return candidate
		}
	}
	for candidate in mac_bottles_collector_tags(collector) {
		if candidate.repr == 'all' {
			return candidate
		}
	}
	return none
}

pub fn mac_bottles_tag(tag ?ruby.Value) ruby.Value {
	if supplied := tag {
		return supplied
	}
	return mac_bottles_current_tag_value()
}

pub fn mac_bottles_find_older_compatible_tag(collector ruby.Value,
	tag ruby.Value) ?ruby.Value {
	mac_bottles_version_parts(tag) or { return none }
	for candidate in mac_bottles_collector_tags(collector) {
		if mac_bottles_arch(candidate) != mac_bottles_arch(tag) {
			continue
		}
		if mac_bottles_version_not_newer(candidate, tag) or { false } {
			return candidate
		}
	}
	return none
}

pub fn mac_bottles_find_matching_tag(collector ruby.Value, tag ruby.Value,
	no_older_versions bool, context MacBottlesMatchContext) ?ruby.Value {
	if exact := mac_bottles_exact_tag(collector, tag) {
		return exact
	}
	if no_older_versions || (context.version_prerelease && context.developer && context.skip_or_later_bottles) {
		return none
	}
	return mac_bottles_find_older_compatible_tag(collector, tag)
}

fn mac_bottles_context_from_value(value ruby.Value) MacBottlesMatchContext {
	return MacBottlesMatchContext{
		version_prerelease: (value.attributes['version_prerelease'] or { 'false' }) == 'true'
		developer: (value.attributes['developer'] or { 'false' }) == 'true'
		skip_or_later_bottles: (value.attributes['skip_or_later_bottles'] or { 'false' }) == 'true'
	}
}

fn mac_bottles_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}
