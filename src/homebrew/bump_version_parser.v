module homebrew

import brew_runtime

// Translated from Homebrew/brew `bump_version_parser.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :arm, :general, :intel` at line 10.
pub fn ruby_bump_version_parser_l10_d1_arm(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arm', ...args)
}

// Ruby attr_reader `attr_reader :arm, :general, :intel` at line 10.
pub fn ruby_bump_version_parser_l10_d2_general(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('general', ...args)
}

// Ruby attr_reader `attr_reader :arm, :general, :intel` at line 10.
pub fn ruby_bump_version_parser_l10_d3_intel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('intel', ...args)
}

// Ruby method `initialize(general: nil, arm: nil, intel: nil)` at line 17.
pub fn ruby_bump_version_parser_l17_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `parse_version(version)` at line 30.
pub fn ruby_bump_version_parser_l30_d5_parse_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_version', ...args)
}

// Ruby method `parse_cask_version(version)` at line 43.
pub fn ruby_bump_version_parser_l43_d6_parse_cask_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_cask_version', ...args)
}

// Ruby method `blank?` at line 52.
pub fn ruby_bump_version_parser_l52_d7_blank(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('blank?', ...args)
}

// Ruby method `==(other)` at line 57.
pub fn ruby_bump_version_parser_l57_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   # Class handling architecture-specific version information.
// 6:   class BumpVersionParser
// 7:     VERSION_SYMBOLS = [:general, :arm, :intel].freeze
// 8:
// 9:     sig { returns(T.nilable(T.any(Version, Cask::DSL::Version))) }
// 10:     attr_reader :arm, :general, :intel
// 11:
// 12:     sig {
// 13:       params(general: T.nilable(T.any(Version, String)),
// 14:              arm:     T.nilable(T.any(Version, String)),
// 15:              intel:   T.nilable(T.any(Version, String))).void
// 16:     }
// 17:     def initialize(general: nil, arm: nil, intel: nil)
// 18:       @general = T.let(parse_version(general), T.nilable(T.any(Version, Cask::DSL::Version))) if general.present?
// 19:       @arm = T.let(parse_version(arm), T.nilable(T.any(Version, Cask::DSL::Version))) if arm.present?
// 20:       @intel = T.let(parse_version(intel), T.nilable(T.any(Version, Cask::DSL::Version))) if intel.present?
// 21:
// 22:       return if @general.present?
// 23:       raise UsageError, "`--version` must not be empty." if arm.blank? && intel.blank?
// 24:     end
// 25:
// 26:     sig {
// 27:       params(version: T.any(Version, String))
// 28:         .returns(T.nilable(T.any(Version, Cask::DSL::Version)))
// 29:     }
// 30:     def parse_version(version)
// 31:       if version.is_a?(Version)
// 32:         version
// 33:       elsif version.is_a?(String)
// 34:         parse_cask_version(version)
// 35:       else
// 36:         # simplecov:disable
// 37:         T.absurd(version)
// 38:         # simplecov:enable
// 39:       end
// 40:     end
// 41:
// 42:     sig { params(version: String).returns(T.nilable(Cask::DSL::Version)) }
// 43:     def parse_cask_version(version)
// 44:       if version == "latest"
// 45:         Cask::DSL::Version.new(:latest)
// 46:       else
// 47:         Cask::DSL::Version.new(version)
// 48:       end
// 49:     end
// 50:
// 51:     sig { returns(T::Boolean) }
// 52:     def blank?
// 53:       @general.blank? && @arm.blank? && @intel.blank?
// 54:     end
// 55:
// 56:     sig { params(other: T.anything).returns(T::Boolean) }
// 57:     def ==(other)
// 58:       case other
// 59:       when BumpVersionParser
// 60:         (general == other.general) && (arm == other.arm) && (intel == other.intel)
// 61:       else
// 62:         false
// 63:       end
// 64:     end
// 65:   end
// 66: end
