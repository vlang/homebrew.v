module homebrew

// Translated from Homebrew/brew `pkg_version.rb`.
// The original source is retained below until every stub has a typed V body.

// PkgVersion is the source-derived combination of a Version and formula revision.
pub struct PkgVersion {
pub:
	version  Version
	revision int
}

// parse_pkg_version translates PkgVersion.parse.
pub fn parse_pkg_version(path string) !PkgVersion {
	if path == '' {
		return error('Version must not be empty')
	}
	mut version_text := path
	mut revision := 0
	if underscore := path.last_index('_') {
		candidate := path[underscore + 1..]
		if candidate != '' && pkg_all_digits(candidate) {
			version_text = path[..underscore]
			revision = candidate.int()
		}
	}
	return PkgVersion{
		version:  new_version(version_text)!
		revision: revision
	}
}

fn pkg_all_digits(value string) bool {
	for character in value {
		if !character.is_digit() {
			return false
		}
	}
	return true
}

// new_pkg_version translates PkgVersion#initialize.
pub fn new_pkg_version(version Version, revision int) PkgVersion {
	return PkgVersion{
		version:  version
		revision: revision
	}
}

// head translates PkgVersion#head?.
pub fn (version PkgVersion) head() bool {
	return version.version.head()
}

// to_s translates PkgVersion#to_str and #to_s.
pub fn (version PkgVersion) to_s() string {
	if version.revision > 0 {
		return '${version.version.to_s()}_${version.revision}'
	}
	return version.version.to_s()
}

// compare_to translates PkgVersion#<=>.
pub fn (version PkgVersion) compare_to(other PkgVersion) int {
	version_comparison := version.version.compare_to(other.version)
	if version_comparison != 0 {
		return version_comparison
	}
	return if version.revision < other.revision {
		-1
	} else if version.revision > other.revision {
		1
	} else {
		0
	}
}

// equals translates Comparable equality and eql?.
pub fn (version PkgVersion) equals(other PkgVersion) bool {
	return version.compare_to(other) == 0
}

// hash translates the [version, revision] hash composition.
pub fn (version PkgVersion) hash() u64 {
	mut result := version.version.hash()
	for shift in 0 .. 8 {
		result = (result ^ u64((version.revision >> (shift * 8)) & 0xff)) * u64(1099511628211)
	}
	return result
}

// major delegates to Version#major.
pub fn (version PkgVersion) major() ?VersionToken {
	return version.version.major()
}

// minor delegates to Version#minor.
pub fn (version PkgVersion) minor() ?VersionToken {
	return version.version.minor()
}

// patch delegates to Version#patch.
pub fn (version PkgVersion) patch() ?VersionToken {
	return version.version.patch()
}

// major_minor delegates to Version#major_minor.
pub fn (version PkgVersion) major_minor() Version {
	return version.version.major_minor()
}

// major_minor_patch delegates to Version#major_minor_patch.
pub fn (version PkgVersion) major_minor_patch() Version {
	return version.version.major_minor_patch()
}

// Ruby attr_reader `attr_reader :version` at line 15.
pub fn ruby_pkg_version_l15_d1_version(version PkgVersion) Version {
	return version.version
}

// Ruby attr_reader `attr_reader :revision` at line 18.
pub fn ruby_pkg_version_l18_d2_revision(version PkgVersion) int {
	return version.revision
}

// Ruby delegate `delegate [:major, :minor, :patch, :major_minor, :major_minor_patch] => :version` at line 20.
pub fn ruby_pkg_version_l20_d3_minor(version PkgVersion) ?VersionToken {
	return version.minor()
}

// Ruby delegate `delegate [:major, :minor, :patch, :major_minor, :major_minor_patch] => :version` at line 20.
pub fn ruby_pkg_version_l20_d4_patch(version PkgVersion) ?VersionToken {
	return version.patch()
}

// Ruby delegate `delegate [:major, :minor, :patch, :major_minor, :major_minor_patch] => :version` at line 20.
pub fn ruby_pkg_version_l20_d5_major_minor(version PkgVersion) Version {
	return version.major_minor()
}

// Ruby delegate `delegate [:major, :minor, :patch, :major_minor, :major_minor_patch] => :version` at line 20.
pub fn ruby_pkg_version_l20_d6_major_minor_patch(version PkgVersion) Version {
	return version.major_minor_patch()
}

// Ruby method `self.parse(path)` at line 23.
pub fn ruby_pkg_version_l23_d7_self_parse(path string) !PkgVersion {
	return parse_pkg_version(path)
}

// Ruby method `initialize(version, revision)` at line 30.
pub fn ruby_pkg_version_l30_d8_initialize(version Version, revision int) PkgVersion {
	return new_pkg_version(version, revision)
}

// Ruby method `head?` at line 36.
pub fn ruby_pkg_version_l36_d9_head(version PkgVersion) bool {
	return version.head()
}

// Ruby method `to_str` at line 41.
pub fn ruby_pkg_version_l41_d10_to_str(version PkgVersion) string {
	return version.to_s()
}

// Ruby method `to_s = to_str` at line 50.
pub fn ruby_pkg_version_l50_d11_to_s(version PkgVersion) string {
	return version.to_s()
}

// Ruby method `<=>(other)` at line 53.
pub fn ruby_pkg_version_l53_d12_anonymous(version PkgVersion, other PkgVersion) int {
	return version.compare_to(other)
}

// Ruby alias `alias eql? ==` at line 59.
pub fn ruby_pkg_version_l59_d13_eql(version PkgVersion, other PkgVersion) bool {
	return version.equals(other)
}

// Ruby method `hash` at line 62.
pub fn ruby_pkg_version_l62_d14_hash(version PkgVersion) u64 {
	return version.hash()
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
