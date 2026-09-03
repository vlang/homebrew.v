module homebrew

import encoding.xml

// Translated from Homebrew/brew `bundle_version.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `self.from_info_plist(info_plist_path)` at line 14.
pub fn ruby_bundle_version_l14_d1_self_from_info_plist(info_plist_path string) !BundleVersionLookup {
	return bundle_version_from_info_plist(info_plist_path)
}

// Ruby method `self.from_info_plist_content(plist)` at line 20.
pub fn ruby_bundle_version_l20_d2_self_from_info_plist_content(plist map[string]string) ?BundleVersion {
	return bundle_version_from_info_plist_content(plist)
}

// Ruby method `self.from_package_info(package_info_path)` at line 28.
pub fn ruby_bundle_version_l28_d3_self_from_package_info(package_info_path string) !BundleVersionLookup {
	return bundle_version_from_package_info(package_info_path)
}

// Ruby attr_reader `attr_reader :short_version, :version` at line 47.
pub fn ruby_bundle_version_l47_d4_short_version(bundle BundleVersion) ?string {
	return bundle.short_version
}

// Ruby attr_reader `attr_reader :short_version, :version` at line 47.
pub fn ruby_bundle_version_l47_d5_version(bundle BundleVersion) ?string {
	return bundle.version
}

// Ruby method `initialize(short_version, version)` at line 50.
pub fn ruby_bundle_version_l50_d6_initialize(short_version ?string,
	version ?string) !BundleVersion {
	return new_bundle_version(short_version, version)
}

// Ruby method `<=>(other)` at line 63.
pub fn ruby_bundle_version_l63_d7_anonymous(bundle BundleVersion, other BundleVersion) int {
	return bundle.compare_to(other)
}

// Ruby method `==(other)` at line 87.
pub fn ruby_bundle_version_l87_d8_anonymous(bundle BundleVersion, other BundleVersion) bool {
	return bundle.equals(other)
}

// Ruby alias `alias eql? ==` at line 90.
pub fn ruby_bundle_version_l90_d9_eql(bundle BundleVersion, other BundleVersion) bool {
	return bundle.eql(other)
}

// Ruby method `nice_version` at line 94.
pub fn ruby_bundle_version_l94_d10_nice_version(bundle BundleVersion) string {
	return bundle.nice_version()
}

// Ruby method `nice_parts` at line 99.
pub fn ruby_bundle_version_l99_d11_nice_parts(bundle BundleVersion) []string {
	return bundle.nice_parts()
}

// Ruby method `to_h` at line 121.
pub fn ruby_bundle_version_l121_d12_to_h(bundle BundleVersion) map[string]string {
	return bundle.to_h()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: module Homebrew
// 7:   # Representation of a macOS bundle version, commonly found in `Info.plist` files.
// 8:   class BundleVersion
// 9:     include Comparable
// 10:
// 11:     extend SystemCommand::Mixin
// 12:
// 13:     sig { params(info_plist_path: Pathname).returns(T.nilable(T.attached_class)) }
// 14:     def self.from_info_plist(info_plist_path)
// 15:       plist = system_command!("plutil", args: ["-convert", "xml1", "-o", "-", info_plist_path]).plist
// 16:       from_info_plist_content(plist)
// 17:     end
// 18:
// 19:     sig { params(plist: T::Hash[String, T.untyped]).returns(T.nilable(T.attached_class)) }
// 20:     def self.from_info_plist_content(plist)
// 21:       short_version = plist["CFBundleShortVersionString"].presence
// 22:       version = plist["CFBundleVersion"].presence
// 23:
// 24:       new(short_version, version) if short_version || version
// 25:     end
// 26:
// 27:     sig { params(package_info_path: Pathname).returns(T.nilable(T.attached_class)) }
// 28:     def self.from_package_info(package_info_path)
// 29:       require "rexml/document"
// 30:
// 31:       xml = REXML::Document.new(package_info_path.read)
// 32:
// 33:       bundle_version_bundle = xml.get_elements("//pkg-info//bundle-version//bundle").first
// 34:       bundle_id = bundle_version_bundle["id"] if bundle_version_bundle
// 35:       return if bundle_id.blank?
// 36:
// 37:       bundle = xml.get_elements("//pkg-info//bundle").find { |b| b["id"] == bundle_id }
// 38:       return unless bundle
// 39:
// 40:       short_version = bundle["CFBundleShortVersionString"]
// 41:       version = bundle["CFBundleVersion"]
// 42:
// 43:       new(short_version, version) if short_version || version
// 44:     end
// 45:
// 46:     sig { returns(T.nilable(String)) }
// 47:     attr_reader :short_version, :version
// 48:
// 49:     sig { params(short_version: T.nilable(String), version: T.nilable(String)).void }
// 50:     def initialize(short_version, version)
// 51:       # Remove version from short version, if present.
// 52:       short_version = short_version&.sub(/\s*\(#{Regexp.escape(version)}\)\Z/, "") if version
// 53:
// 54:       @short_version = T.let(short_version.presence, T.nilable(String))
// 55:       @version = T.let(version.presence, T.nilable(String))
// 56:
// 57:       return if @short_version || @version
// 58:
// 59:       raise ArgumentError, "`short_version` and `version` cannot both be `nil` or empty"
// 60:     end
// 61:
// 62:     sig { params(other: BundleVersion).returns(T.nilable(Integer)) }
// 63:     def <=>(other)
// 64:       return super unless instance_of?(other.class)
// 65:
// 66:       make_version = ->(v) { v ? Version.new(v) : Version::NULL }
// 67:
// 68:       version = self.version.then(&make_version)
// 69:       other_version = other.version.then(&make_version)
// 70:
// 71:       difference = version <=> other_version
// 72:
// 73:       # If `version` is equal or cannot be compared, compare `short_version` instead.
// 74:       if difference.nil? || difference.zero?
// 75:         short_version = self.short_version.then(&make_version)
// 76:         other_short_version = other.short_version.then(&make_version)
// 77:
// 78:         short_version_difference = short_version <=> other_short_version
// 79:
// 80:         return short_version_difference unless short_version_difference.nil?
// 81:       end
// 82:
// 83:       difference
// 84:     end
// 85:
// 86:     sig { params(other: BundleVersion).returns(T::Boolean) }
// 87:     def ==(other)
// 88:       instance_of?(other.class) && short_version == other.short_version && version == other.version
// 89:     end
// 90:     alias eql? ==
// 91:
// 92:     # Create a nicely formatted version (on a best effort basis).
// 93:     sig { returns(String) }
// 94:     def nice_version
// 95:       nice_parts.join(",")
// 96:     end
// 97:
// 98:     sig { returns(T::Array[String]) }
// 99:     def nice_parts
// 100:       short_version = self.short_version
// 101:       version = self.version
// 102:
// 103:       return [T.must(short_version)] if short_version == version
// 104:
// 105:       if short_version && version
// 106:         return [version] if version.match?(/\A\d+(\.\d+)+\Z/) && version.start_with?("#{short_version}.")
// 107:         return [short_version] if short_version.match?(/\A\d+(\.\d+)+\Z/) && short_version.start_with?("#{version}.")
// 108:
// 109:         if short_version.match?(/\A\d+(\.\d+)*\Z/) && version.match?(/\A\d+\Z/)
// 110:           return [short_version] if short_version.start_with?("#{version}.") || short_version.end_with?(".#{version}")
// 111:
// 112:           return [short_version, version]
// 113:         end
// 114:       end
// 115:
// 116:       [short_version, version].compact
// 117:     end
// 118:     private :nice_parts
// 119:
// 120:     sig { returns(T::Hash[Symbol, String]) }
// 121:     def to_h
// 122:       {
// 123:         short_version:,
// 124:         version:,
// 125:       }.compact
// 126:     end
// 127:   end
// 128: end
