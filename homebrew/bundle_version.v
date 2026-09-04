module homebrew

import encoding.xml

// Translated from Homebrew/brew `bundle_version.rb`.

// BundleVersion is the typed representation of a macOS bundle version.
pub struct BundleVersion {
pub:
	short_version ?string
	version       ?string
}

// BundleVersionLookup keeps the source's nil result distinct from command,
// file, and XML errors represented by V's result type.
pub struct BundleVersionLookup {
pub:
	found          bool
	bundle_version BundleVersion
}

fn present_bundle_version(value ?string) ?string {
	if raw := value {
		if raw.trim_space() != '' {
			return raw
		}
	}
	return none
}

fn remove_parenthesized_bundle_version(short_version string, version string) string {
	suffix := '(${version})'
	if !short_version.ends_with(suffix) {
		return short_version
	}
	prefix := short_version[..short_version.len - suffix.len]
	return prefix.trim_right(' \t\r\n\v\f')
}

// new_bundle_version translates BundleVersion#initialize.
pub fn new_bundle_version(short_version ?string, version ?string) !BundleVersion {
	mut normalized_short := short_version
	if raw_version := version {
		if raw_short := short_version {
			normalized_short = remove_parenthesized_bundle_version(raw_short, raw_version)
		}
	}
	normalized_short = present_bundle_version(normalized_short)
	normalized_version := present_bundle_version(version)
	if normalized_short == none && normalized_version == none {
		return error('`short_version` and `version` cannot both be `nil` or empty')
	}
	return BundleVersion{
		short_version: normalized_short
		version: normalized_version
	}
}

fn numeric_bundle_version(value string, require_dot bool) bool {
	if value == '' || (require_dot && !value.contains('.')) {
		return false
	}
	for part in value.split('.') {
		if part == '' {
			return false
		}
		for character in part {
			if !character.is_digit() {
				return false
			}
		}
	}
	return true
}

// nice_parts implements the complete best-effort formatting decision tree.
pub fn (bundle BundleVersion) nice_parts() []string {
	short_version := bundle.short_version or { '' }
	version := bundle.version or { '' }
	if short_version != '' && short_version == version {
		return [short_version]
	}
	if short_version != '' && version != '' {
		if numeric_bundle_version(version, true) && version.starts_with('${short_version}.') {
			return [version]
		}
		if numeric_bundle_version(short_version, true) && short_version.starts_with('${version}.') {
			return [short_version]
		}
		if numeric_bundle_version(short_version, false) && numeric_bundle_version(version, false) && !version.contains('.') {
			if short_version.starts_with('${version}.') || short_version.ends_with('.${version}') {
				return [short_version]
			}
			return [short_version, version]
		}
	}
	mut parts := []string{}
	if short_version != '' {
		parts << short_version
	}
	if version != '' {
		parts << version
	}
	return parts
}

// nice_version translates BundleVersion#nice_version.
pub fn (bundle BundleVersion) nice_version() string {
	return bundle.nice_parts().join(',')
}

fn comparable_bundle_version(value ?string) Version {
	if raw := value {
		return new_version(raw) or { null_version() }
	}
	return null_version()
}

// compare_to translates BundleVersion#<=> for the typed BundleVersion domain.
pub fn (bundle BundleVersion) compare_to(other BundleVersion) int {
	difference := comparable_bundle_version(bundle.version).compare_to(comparable_bundle_version(other.version))
	if difference != 0 {
		return difference
	}
	return comparable_bundle_version(bundle.short_version).compare_to(comparable_bundle_version(other.short_version))
}

fn optional_bundle_version_strings_equal(left ?string, right ?string) bool {
	if left_value := left {
		if right_value := right {
			return left_value == right_value
		}
		return false
	}
	return right == none
}

// equals and eql preserve BundleVersion's structural equality semantics.
pub fn (bundle BundleVersion) equals(other BundleVersion) bool {
	return optional_bundle_version_strings_equal(bundle.short_version, other.short_version) && optional_bundle_version_strings_equal(bundle.version, other.version)
}

pub fn (bundle BundleVersion) eql(other BundleVersion) bool {
	return bundle.equals(other)
}

// to_h translates the compact symbol-keyed Ruby hash using V string keys.
pub fn (bundle BundleVersion) to_h() map[string]string {
	mut values := map[string]string{}
	if short_version := bundle.short_version {
		values['short_version'] = short_version
	}
	if version := bundle.version {
		values['version'] = version
	}
	return values
}

// bundle_version_from_info_plist_content translates the nilable hash lookup.
pub fn bundle_version_from_info_plist_content(plist map[string]string) ?BundleVersion {
	short_version := present_bundle_version(plist['CFBundleShortVersionString'] or { none })
	version := present_bundle_version(plist['CFBundleVersion'] or { none })
	if short_version == none && version == none {
		return none
	}
	return new_bundle_version(short_version, version) or { return none }
}

fn found_bundle_version(bundle_version BundleVersion) BundleVersionLookup {
	return BundleVersionLookup{
		found: true
		bundle_version: bundle_version
	}
}

fn bundle_version_attribute(attributes map[string]string, name string) ?string {
	return attributes[name] or { return none }
}

// bundle_version_from_info_plist runs the same plutil conversion as the Ruby
// implementation before consuming the typed plist values.
pub fn bundle_version_from_info_plist(info_plist_path string) !BundleVersionLookup {
	result := run_system_command_or_error('plutil', SystemCommandOptions{
		args: ['-convert', 'xml1', '-o', '-', info_plist_path]
		print_stderr: .discard
	})!
	plist := result.plist() or { return error('plutil did not return an XML property list') }
	if bundle_version := bundle_version_from_info_plist_content(plist.values) {
		return found_bundle_version(bundle_version)
	}
	return BundleVersionLookup{}
}

// bundle_version_from_package_info translates the REXML selection rules while
// keeping file/XML errors distinct from the source's nil result.
pub fn bundle_version_from_package_info(package_info_path string) !BundleVersionLookup {
	document := xml.XMLDocument.from_file(package_info_path)!
	mut bundle_version_bundles := []xml.XMLNode{}
	mut bundles := []xml.XMLNode{}
	for package_info in document.get_elements_by_tag('pkg-info') {
		for bundle_version in package_info.get_elements_by_tag('bundle-version') {
			bundle_version_bundles << bundle_version.get_elements_by_tag('bundle')
		}
		bundles << package_info.get_elements_by_tag('bundle')
	}
	if bundle_version_bundles.len == 0 {
		return BundleVersionLookup{}
	}
	bundle_id := bundle_version_attribute(bundle_version_bundles[0].attributes, 'id') or {
		return BundleVersionLookup{}
	}
	if bundle_id.trim_space() == '' {
		return BundleVersionLookup{}
	}
	for bundle in bundles {
		if (bundle_version_attribute(bundle.attributes, 'id') or { '' }) != bundle_id {
			continue
		}
		short_version := bundle_version_attribute(bundle.attributes, 'CFBundleShortVersionString')
		version := bundle_version_attribute(bundle.attributes, 'CFBundleVersion')
		if short_version == none && version == none {
			return BundleVersionLookup{}
		}
		bundle_version := new_bundle_version(short_version, version) or {
			return BundleVersionLookup{}
		}
		return found_bundle_version(bundle_version)
	}
	return BundleVersionLookup{}
}
