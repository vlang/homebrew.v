module homebrew

import brew_runtime

// Translated from Homebrew/brew `pkg_version.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :version` at line 15.
pub fn ruby_pkg_version_l15_d1_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby attr_reader `attr_reader :revision` at line 18.
pub fn ruby_pkg_version_l18_d2_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('revision', ...args)
}

// Ruby delegate `delegate [:major, :minor, :patch, :major_minor, :major_minor_patch] => :version` at line 20.
pub fn ruby_pkg_version_l20_d3_minor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('minor', ...args)
}

// Ruby delegate `delegate [:major, :minor, :patch, :major_minor, :major_minor_patch] => :version` at line 20.
pub fn ruby_pkg_version_l20_d4_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby delegate `delegate [:major, :minor, :patch, :major_minor, :major_minor_patch] => :version` at line 20.
pub fn ruby_pkg_version_l20_d5_major_minor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('major_minor', ...args)
}

// Ruby delegate `delegate [:major, :minor, :patch, :major_minor, :major_minor_patch] => :version` at line 20.
pub fn ruby_pkg_version_l20_d6_major_minor_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('major_minor_patch]', ...args)
}

// Ruby method `self.parse(path)` at line 23.
pub fn ruby_pkg_version_l23_d7_self_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.parse', ...args)
}

// Ruby method `initialize(version, revision)` at line 30.
pub fn ruby_pkg_version_l30_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `head?` at line 36.
pub fn ruby_pkg_version_l36_d9_head(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('head?', ...args)
}

// Ruby method `to_str` at line 41.
pub fn ruby_pkg_version_l41_d10_to_str(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_str', ...args)
}

// Ruby method `to_s = to_str` at line 50.
pub fn ruby_pkg_version_l50_d11_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `<=>(other)` at line 53.
pub fn ruby_pkg_version_l53_d12_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<=>', ...args)
}

// Ruby alias `alias eql? ==` at line 59.
pub fn ruby_pkg_version_l59_d13_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `hash` at line 62.
pub fn ruby_pkg_version_l62_d14_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hash', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "version"
// 5:
// 6: # Combination of a version and a revision.
// 7: class PkgVersion
// 8:   include Comparable
// 9:   extend Forwardable
// 10:
// 11:   REGEX = /\A(.+?)(?:_(\d+))?\z/
// 12:   private_constant :REGEX
// 13:
// 14:   sig { returns(Version) }
// 15:   attr_reader :version
// 16:
// 17:   sig { returns(Integer) }
// 18:   attr_reader :revision
// 19:
// 20:   delegate [:major, :minor, :patch, :major_minor, :major_minor_patch] => :version
// 21:
// 22:   sig { params(path: String).returns(PkgVersion) }
// 23:   def self.parse(path)
// 24:     _, version, revision = *path.match(REGEX)
// 25:     version = Version.new(version.to_s)
// 26:     new(version, revision.to_i)
// 27:   end
// 28:
// 29:   sig { params(version: Version, revision: Integer).void }
// 30:   def initialize(version, revision)
// 31:     @version = version
// 32:     @revision = revision
// 33:   end
// 34:
// 35:   sig { returns(T::Boolean) }
// 36:   def head?
// 37:     version.head?
// 38:   end
// 39:
// 40:   sig { returns(String) }
// 41:   def to_str
// 42:     if revision.positive?
// 43:       "#{version}_#{revision}"
// 44:     else
// 45:       version.to_s
// 46:     end
// 47:   end
// 48:
// 49:   sig { returns(String) }
// 50:   def to_s = to_str
// 51:
// 52:   sig { params(other: PkgVersion).returns(T.nilable(Integer)) }
// 53:   def <=>(other)
// 54:     version_comparison = (version <=> other.version)
// 55:     return if version_comparison.nil?
// 56:
// 57:     version_comparison.nonzero? || revision <=> other.revision
// 58:   end
// 59:   alias eql? ==
// 60:
// 61:   sig { returns(Integer) }
// 62:   def hash
// 63:     [version, revision].hash
// 64:   end
// 65: end
