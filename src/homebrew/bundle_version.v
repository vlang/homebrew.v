module homebrew

import brew_runtime

// Translated from Homebrew/brew `bundle_version.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.from_info_plist(info_plist_path)` at line 14.
pub fn ruby_bundle_version_l14_d1_self_from_info_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_info_plist', ...args)
}

// Ruby method `self.from_info_plist_content(plist)` at line 20.
pub fn ruby_bundle_version_l20_d2_self_from_info_plist_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_info_plist_content', ...args)
}

// Ruby method `self.from_package_info(package_info_path)` at line 28.
pub fn ruby_bundle_version_l28_d3_self_from_package_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_package_info', ...args)
}

// Ruby attr_reader `attr_reader :short_version, :version` at line 47.
pub fn ruby_bundle_version_l47_d4_short_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('short_version', ...args)
}

// Ruby attr_reader `attr_reader :short_version, :version` at line 47.
pub fn ruby_bundle_version_l47_d5_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `initialize(short_version, version)` at line 50.
pub fn ruby_bundle_version_l50_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `<=>(other)` at line 63.
pub fn ruby_bundle_version_l63_d7_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<=>', ...args)
}

// Ruby method `==(other)` at line 87.
pub fn ruby_bundle_version_l87_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias `alias eql? ==` at line 90.
pub fn ruby_bundle_version_l90_d9_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `nice_version` at line 94.
pub fn ruby_bundle_version_l94_d10_nice_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nice_version', ...args)
}

// Ruby method `nice_parts` at line 99.
pub fn ruby_bundle_version_l99_d11_nice_parts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nice_parts', ...args)
}

// Ruby method `to_h` at line 121.
pub fn ruby_bundle_version_l121_d12_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
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
