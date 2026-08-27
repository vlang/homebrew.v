module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/skipper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `skip?(entry, silent: false)` at line 9.
pub fn ruby_skipper_l9_d1_skip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip?', ...args)
}

// Ruby method `tap_failed!(tap_name)` at line 32.
pub fn ruby_skipper_l32_d2_tap_failed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_failed!', ...args)
}

// Ruby attr_writer `attr_writer :failed_taps` at line 38.
pub fn ruby_skipper_l38_d3_failed_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('failed_taps=', ...args)
}

// Ruby attr_writer `attr_writer :skipped_entries` at line 44.
pub fn ruby_skipper_l44_d4_skipped_entries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skipped_entries=', ...args)
}

// Ruby method `skipped_entries` at line 49.
pub fn ruby_skipper_l49_d5_skipped_entries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skipped_entries', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Bundle
// 6:     module Skipper
// 7:       class << self
// 8:         sig { params(entry: Dsl::Entry, silent: T::Boolean).returns(T::Boolean) }
// 9:         def skip?(entry, silent: false)
// 10:           require "bundle/brew"
// 11:
// 12:           full_name = entry.options[:full_name]
// 13:           return true if @failed_taps&.any? do |tap|
// 14:             prefix = "#{tap}/"
// 15:             entry.name.start_with?(prefix) || (full_name.is_a?(String) && full_name.start_with?(prefix))
// 16:           end
// 17:
// 18:           entry_type_skips = Array(skipped_entries[entry.type])
// 19:           return false if entry_type_skips.empty?
// 20:
// 21:           # Check the name or ID particularly for Mac App Store entries where they
// 22:           # can have spaces in the names (and the `mas` output format changes on
// 23:           # occasion).
// 24:           entry_ids = [entry.name, entry.options[:id]&.to_s].compact
// 25:           return false unless entry_type_skips.intersect?(entry_ids)
// 26:
// 27:           puts Formatter.warning "Skipping #{entry.name}" unless silent
// 28:           true
// 29:         end
// 30:
// 31:         sig { params(tap_name: String).void }
// 32:         def tap_failed!(tap_name)
// 33:           @failed_taps ||= T.let([], T.nilable(T::Array[String]))
// 34:           @failed_taps << tap_name
// 35:         end
// 36:
// 37:         sig { params(failed_taps: T.nilable(T::Array[String])).returns(T.nilable(T::Array[String])) }
// 38:         attr_writer :failed_taps
// 39:
// 40:         sig {
// 41:           params(skipped_entries: T.nilable(T::Hash[Symbol, T.nilable(T::Array[String])]))
// 42:             .returns(T.nilable(T::Hash[Symbol, T.nilable(T::Array[String])]))
// 43:         }
// 44:         attr_writer :skipped_entries
// 45:
// 46:         private
// 47:
// 48:         sig { returns(T::Hash[Symbol, T.nilable(T::Array[String])]) }
// 49:         def skipped_entries
// 50:           return @skipped_entries if @skipped_entries
// 51:
// 52:           @skipped_entries ||= T.let({}, T.nilable(T::Hash[Symbol, T.nilable(T::Array[String])]))
// 53:           [:brew, :cask, :mas, :tap, :flatpak, :winget].each do |type|
// 54:             @skipped_entries[type] =
// 55:               ENV["HOMEBREW_BUNDLE_#{type.to_s.upcase}_SKIP"]&.split
// 56:           end
// 57:           @skipped_entries
// 58:         end
// 59:       end
// 60:     end
// 61:   end
// 62: end
// 63:
// 64: require "extend/os/bundle/skipper"
