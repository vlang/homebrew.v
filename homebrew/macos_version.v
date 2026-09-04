module homebrew

import ruby

// Translated from Homebrew/brew `macos_version.rb`.

// MacOSVersion keeps the source's stricter macOS input validation while using
// the translated Version type for ordering and components.
pub struct MacOSVersion {
pub:
	version Version
	is_null bool
}

pub fn macos_symbol_versions() map[string]string {
	return {
		'golden_gate': '27'
		'tahoe':       '26'
		'sequoia':     '15'
		'sonoma':      '14'
		'ventura':     '13'
		'monterey':    '12'
		'big_sur':     '11'
		'catalina':    '10.15'
	}
}

pub fn new_macos_version(value string) !MacOSVersion {
	parts := value.split('.')
	if parts.len == 0 || parts.len > 3 || parts[0].len < 2 || parts.any(it.len == 0
		|| !it.bytes().all(byte_is_digit(it))) {
		return error('unknown or unsupported macOS version: "${value}"')
	}
	return MacOSVersion{
		version: new_version(value)!
	}
}

pub fn null_macos_version() MacOSVersion {
	return MacOSVersion{
		version: null_version()
		is_null: true
	}
}

pub fn macos_version_from_symbol(symbol string) !MacOSVersion {
	versions := macos_symbol_versions()
	value := versions[symbol] or {
		return error('unknown or unsupported macOS version: :${symbol}')
	}
	return new_macos_version(value)
}

pub fn (version MacOSVersion) kernel_major_version() Version {
	major := version.version.major() or { return null_version() }
	major_number := major.number
	kernel_major := if major_number >= 27 {
		major_number
	} else if major_number == 26 {
		major_number - 1
	} else if major_number > 10 {
		major_number + 9
	} else {
		minor := version.version.minor() or { null_version_token() }
		minor.number + 4
	}
	return new_version(kernel_major.str()) or { null_version() }
}

pub fn (version MacOSVersion) compare(other MacOSVersion) int {
	return version.version.compare_to(other.version)
}

pub fn (version MacOSVersion) compare_symbol(symbol string) int {
	if symbol in macos_symbol_versions() && version.to_symbol() == symbol {
		return 0
	}
	other_value := macos_symbol_versions()[symbol] or { symbol }
	other := new_version(other_value) or { return 1 }
	return version.version.compare_to(other)
}

pub fn (version MacOSVersion) strip_patch() MacOSVersion {
	if version.is_null {
		return version
	}
	major := version.version.major() or { return version }
	stripped := if major.number >= 11 {
		major.number.str()
	} else {
		version.version.major_minor().to_s()
	}
	return new_macos_version(stripped) or { version }
}

pub fn (version MacOSVersion) to_symbol() string {
	if version.is_null {
		return 'dunno'
	}
	stripped := version.strip_patch().str()
	for symbol, value in macos_symbol_versions() {
		if value == stripped {
			return symbol
		}
	}
	return 'dunno'
}

pub fn (version MacOSVersion) pretty_name() string {
	return version.to_symbol().split('_').map(title_word(it)).join(' ')
}

pub fn (version MacOSVersion) inspect() string {
	return '#<MacOSVersion: "${version.str()}">'
}

pub fn (version MacOSVersion) outdated_release(oldest_supported string) !bool {
	if oldest_supported.len == 0 {
		return error('HOMEBREW_MACOS_OLDEST_SUPPORTED is not configured')
	}
	return version.compare(new_macos_version(oldest_supported)!) < 0
}

pub fn (version MacOSVersion) prerelease(newest_unsupported string) !bool {
	if newest_unsupported.len == 0 {
		return error('HOMEBREW_MACOS_NEWEST_UNSUPPORTED is not configured')
	}
	return version.compare(new_macos_version(newest_unsupported)!) >= 0
}

pub fn (version MacOSVersion) unsupported_release(oldest_supported string,
	newest_unsupported string) !bool {
	return version.outdated_release(oldest_supported)! || version.prerelease(newest_unsupported)!
}

pub fn (version MacOSVersion) requires_nehalem_cpu(intel bool, oldest_cpu string) !bool {
	if version.is_null {
		return false
	}
	if !intel {
		return error('Unexpected architecture. This only works with Intel architecture.')
	}
	return oldest_cpu == 'nehalem'
}

pub fn (version MacOSVersion) requires_sse4(intel bool, oldest_cpu string) !bool {
	return version.requires_nehalem_cpu(intel, oldest_cpu)
}

pub fn (version MacOSVersion) requires_sse41(intel bool, oldest_cpu string) !bool {
	return version.requires_nehalem_cpu(intel, oldest_cpu)
}

pub fn (version MacOSVersion) requires_sse42(intel bool, oldest_cpu string) !bool {
	return version.requires_nehalem_cpu(intel, oldest_cpu)
}

pub fn (version MacOSVersion) requires_popcnt(intel bool, oldest_cpu string) !bool {
	return version.requires_nehalem_cpu(intel, oldest_cpu)
}

pub fn (version MacOSVersion) str() string {
	return version.version.to_s()
}

fn byte_is_digit(value u8) bool {
	return value >= `0` && value <= `9`
}

fn title_word(value string) string {
	if value.len == 0 {
		return value
	}
	return value[..1].to_upper() + value[1..]
}

fn macos_version_value(version MacOSVersion) ruby.Value {
	return ruby.structured_value('MacOSVersion', version.str(), {
		'value': version.str()
		'null':  version.is_null.str()
		'sym':   version.to_symbol()
	})
}

fn macos_version_from_args(args []ruby.Value) !MacOSVersion {
	if args.len == 0 {
		return error('missing MacOSVersion receiver')
	}
	return macos_version_from_value(args[0])
}

fn macos_version_from_value(value ruby.Value) !MacOSVersion {
	if value.attributes['null'] == 'true' {
		return null_macos_version()
	}
	return new_macos_version(if value.attributes['value'].len > 0 {
		value.attributes['value']
	} else {
		value.as_string()
	})
}
