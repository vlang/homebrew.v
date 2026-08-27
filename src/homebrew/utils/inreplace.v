module utils

import brew_runtime

// Translated from Homebrew/brew `utils/inreplace.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(errors)` at line 12.
pub fn ruby_inreplace_l12_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `self.inreplace(paths, before = nil, after = nil, audit_result: true, global: true, &block)` at line 55.
pub fn ruby_inreplace_l55_d2_self_inreplace(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.inreplace', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/string_inreplace_extension"
// 5:
// 6: module Utils
// 7:   # Helper functions for replacing text in files in-place.
// 8:   module Inreplace
// 9:     # Error during text replacement.
// 10:     class Error < RuntimeError
// 11:       sig { params(errors: T::Hash[T.any(String, Pathname), T::Array[String]]).void }
// 12:       def initialize(errors)
// 13:         formatted_errors = errors.reduce(+"inreplace failed\n") do |s, (path, errs)|
// 14:           s << "#{path}:\n" << errs.map { |e| "  #{e}\n" }.join
// 15:         end
// 16:         super formatted_errors.freeze
// 17:       end
// 18:     end
// 19:
// 20:     # Sometimes we have to change a bit before we install. Mostly we
// 21:     # prefer a patch, but if you need the {Formula#prefix prefix} of
// 22:     # this formula in the patch you have to resort to `inreplace`,
// 23:     # because in the patch you don't have access to any variables
// 24:     # defined by the formula, as only `HOMEBREW_PREFIX` is available
// 25:     # in the {DATAPatch embedded patch}.
// 26:     #
// 27:     # ### Examples
// 28:     #
// 29:     # `inreplace` supports regular expressions:
// 30:     #
// 31:     # ```ruby
// 32:     # inreplace "somefile.cfg", /look[for]what?/, "replace by #{bin}/tool"
// 33:     # ```
// 34:     #
// 35:     # `inreplace` supports blocks:
// 36:     #
// 37:     # ```ruby
// 38:     # inreplace "Makefile" do |s|
// 39:     #   s.gsub! "/usr/local", HOMEBREW_PREFIX.to_s
// 40:     # end
// 41:     # ```
// 42:     #
// 43:     # @see StringInreplaceExtension
// 44:     # @api public
// 45:     sig {
// 46:       params(
// 47:         paths:        T.any(T::Enumerable[T.any(String, Pathname)], String, Pathname),
// 48:         before:       T.nilable(T.any(Pathname, Regexp, String)),
// 49:         after:        T.nilable(T.any(Pathname, String, Symbol)),
// 50:         audit_result: T::Boolean,
// 51:         global:       T::Boolean,
// 52:         block:        T.nilable(T.proc.params(s: StringInreplaceExtension).void),
// 53:       ).void
// 54:     }
// 55:     def self.inreplace(paths, before = nil, after = nil, audit_result: true, global: true, &block)
// 56:       paths = Array(paths)
// 57:       after &&= after.to_s
// 58:       before = before.to_s if before.is_a?(Pathname)
// 59:
// 60:       errors = {}
// 61:
// 62:       errors["`paths` (first) parameter"] = ["`paths` was empty"] if paths.all?(&:blank?)
// 63:
// 64:       paths.each do |path|
// 65:         str = File.binread(path)
// 66:         s = StringInreplaceExtension.new(str)
// 67:
// 68:         if before.nil? && after.nil?
// 69:           raise ArgumentError, "Must supply a block or before/after params" unless block
// 70:
// 71:           yield s
// 72:         elsif global
// 73:           s.gsub!(T.must(before), T.must(after), audit_result:)
// 74:         else
// 75:           s.sub!(T.must(before), T.must(after), audit_result:)
// 76:         end
// 77:
// 78:         errors[path] = s.errors unless s.errors.empty?
// 79:
// 80:         Pathname(path).atomic_write(s.inreplace_string)
// 81:       end
// 82:
// 83:       raise Utils::Inreplace::Error, errors if errors.present?
// 84:     end
// 85:   end
// 86: end
