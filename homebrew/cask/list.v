module cask

import brew_runtime

// Translated from Homebrew/brew `cask/list.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.list_casks(*casks, one: false, full_name: false, versions: false)` at line 25.
pub fn ruby_list_l25_d1_self_list_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.list_casks', ...args)
}

// Ruby method `self.list_artifacts(cask)` at line 48.
pub fn ruby_list_l48_d2_self_list_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.list_artifacts', ...args)
}

// Ruby method `self.format_versioned(cask)` at line 63.
pub fn ruby_list_l63_d3_self_format_versioned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.format_versioned', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/relocated"
// 5: require "utils/output"
// 6:
// 7: module Cask
// 8:   module List
// 9:     extend ::Utils::Output::Mixin
// 10:
// 11:     TAP_AND_NAME_COMPARISON = T.let(
// 12:       proc do |a, b|
// 13:         if a.include?("/") && b.exclude?("/")
// 14:           1
// 15:         elsif a.exclude?("/") && b.include?("/")
// 16:           -1
// 17:         else
// 18:           a <=> b
// 19:         end
// 20:       end.freeze,
// 21:       T.proc.params(a: String, b: String).returns(Integer),
// 22:     )
// 23:
// 24:     sig { params(casks: Cask, one: T::Boolean, full_name: T::Boolean, versions: T::Boolean).void }
// 25:     def self.list_casks(*casks, one: false, full_name: false, versions: false)
// 26:       output = if casks.any?
// 27:         casks.each do |cask|
// 28:           raise CaskNotInstalledError, cask unless cask.installed?
// 29:         end
// 30:       else
// 31:         Caskroom.casks
// 32:       end
// 33:
// 34:       if one
// 35:         puts output.map(&:to_s)
// 36:       elsif full_name
// 37:         puts output.map(&:full_name).sort(&TAP_AND_NAME_COMPARISON)
// 38:       elsif versions
// 39:         puts output.map { format_versioned(it) }
// 40:       elsif !output.empty? && casks.any?
// 41:         output.map { list_artifacts(it) }
// 42:       elsif !output.empty?
// 43:         puts Formatter.columns(output.map(&:to_s))
// 44:       end
// 45:     end
// 46:
// 47:     sig { params(cask: Cask).void }
// 48:     def self.list_artifacts(cask)
// 49:       cask.artifacts.group_by(&:class).sort_by { |klass, _| klass.english_name }.each do |klass, artifacts|
// 50:         next if [Artifact::Uninstall, Artifact::Zap].include? klass
// 51:
// 52:         ohai klass.english_name
// 53:         artifacts.each do |artifact|
// 54:           puts artifact.summarize_installed if artifact.respond_to?(:summarize_installed)
// 55:           next if artifact.respond_to?(:summarize_installed)
// 56:
// 57:           puts artifact
// 58:         end
// 59:       end
// 60:     end
// 61:
// 62:     sig { params(cask: Cask).returns(String) }
// 63:     def self.format_versioned(cask)
// 64:       "#{cask}#{cask.installed_version&.prepend(" ")}"
// 65:     end
// 66:   end
// 67: end
