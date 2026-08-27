module utils

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/utils/bottles.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `tag(tag = nil)` at line 9.
pub fn ruby_bottles_l9_d1_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tag', ...args)
}

// Ruby method `find_matching_tag(tag, no_older_versions: false)` at line 27.
pub fn ruby_bottles_l27_d2_find_matching_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_matching_tag', ...args)
}

// Ruby method `find_older_compatible_tag(tag)` at line 43.
pub fn ruby_bottles_l43_d3_find_older_compatible_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_older_compatible_tag', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Bottles
// 7:       module ClassMethods
// 8:         sig { params(tag: T.nilable(T.any(Symbol, Utils::Bottles::Tag))).returns(Utils::Bottles::Tag) }
// 9:         def tag(tag = nil)
// 10:           if tag.nil?
// 11:             Utils::Bottles::Tag.new(system: MacOS.version.to_sym, arch: ::Hardware::CPU.arch)
// 12:           else
// 13:             super
// 14:           end
// 15:         end
// 16:       end
// 17:
// 18:       module Collector
// 19:         extend T::Helpers
// 20:
// 21:         requires_ancestor { Utils::Bottles::Collector }
// 22:
// 23:         sig {
// 24:           params(tag:               Utils::Bottles::Tag,
// 25:                  no_older_versions: T::Boolean).returns(T.nilable(Utils::Bottles::Tag))
// 26:         }
// 27:         def find_matching_tag(tag, no_older_versions: false)
// 28:           # Used primarily by developers testing beta macOS releases.
// 29:           if no_older_versions ||
// 30:              (OS::Mac.version.prerelease? &&
// 31:                Homebrew::EnvConfig.developer? &&
// 32:                Homebrew::EnvConfig.skip_or_later_bottles?)
// 33:             super(tag)
// 34:           else
// 35:             super(tag) || find_older_compatible_tag(tag)
// 36:           end
// 37:         end
// 38:
// 39:         private
// 40:
// 41:         # Find a bottle built for a previous version of macOS.
// 42:         sig { params(tag: Utils::Bottles::Tag).returns(T.nilable(Utils::Bottles::Tag)) }
// 43:         def find_older_compatible_tag(tag)
// 44:           tag_version = begin
// 45:             tag.to_macos_version
// 46:           rescue MacOSVersion::Error
// 47:             nil
// 48:           end
// 49:
// 50:           return if tag_version.blank?
// 51:
// 52:           tags.find do |candidate|
// 53:             next if candidate.standardized_arch != tag.standardized_arch
// 54:
// 55:             candidate.to_macos_version <= tag_version
// 56:           rescue MacOSVersion::Error
// 57:             false
// 58:           end
// 59:         end
// 60:       end
// 61:     end
// 62:   end
// 63: end
// 64:
// 65: Utils::Bottles.singleton_class.prepend(OS::Mac::Bottles::ClassMethods)
// 66: Utils::Bottles::Collector.prepend(OS::Mac::Bottles::Collector)
