module livecheck

import brew_runtime

// Translated from Homebrew/brew `livecheck/livecheck_version.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.create(package_or_resource, version)` at line 13.
pub fn ruby_livecheck_version_l13_d1_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create', ...args)
}

// Ruby attr_reader `attr_reader :versions` at line 26.
pub fn ruby_livecheck_version_l26_d2_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('versions', ...args)
}

// Ruby method `initialize(versions)` at line 29.
pub fn ruby_livecheck_version_l29_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `<=>(other)` at line 34.
pub fn ruby_livecheck_version_l34_d4_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<=>', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Livecheck
// 6:     # A formula or cask version, split into its component sub-versions.
// 7:     class LivecheckVersion
// 8:       include Comparable
// 9:
// 10:       sig {
// 11:         params(package_or_resource: T.any(Formula, Cask::Cask, Resource), version: Version).returns(LivecheckVersion)
// 12:       }
// 13:       def self.create(package_or_resource, version)
// 14:         versions = case package_or_resource
// 15:         when Formula, Resource
// 16:           [version]
// 17:         when Cask::Cask
// 18:           version.to_s.split(",").map { |s| Version.new(s) }
// 19:         else
// 20:           T.absurd(package_or_resource)
// 21:         end
// 22:         new(versions)
// 23:       end
// 24:
// 25:       sig { returns(T::Array[Version]) }
// 26:       attr_reader :versions
// 27:
// 28:       sig { params(versions: T::Array[Version]).void }
// 29:       def initialize(versions)
// 30:         @versions = versions
// 31:       end
// 32:
// 33:       sig { params(other: T.untyped).returns(T.nilable(Integer)) }
// 34:       def <=>(other)
// 35:         return unless other.is_a?(LivecheckVersion)
// 36:
// 37:         lversions = versions
// 38:         rversions = other.versions
// 39:         max = [lversions.count, rversions.count].max
// 40:         l = r = 0
// 41:
// 42:         while l < max
// 43:           a = lversions[l] || Version::NULL
// 44:           b = rversions[r] || Version::NULL
// 45:
// 46:           if a == b
// 47:             l += 1
// 48:             r += 1
// 49:             next
// 50:           elsif !a.null? && b.null?
// 51:             return 1 if a > Version::NULL
// 52:
// 53:             l += 1
// 54:           elsif a.null? && !b.null?
// 55:             return -1 if b > Version::NULL
// 56:
// 57:             r += 1
// 58:           else
// 59:             return a <=> b
// 60:           end
// 61:         end
// 62:
// 63:         0
// 64:       end
// 65:     end
// 66:   end
// 67: end
