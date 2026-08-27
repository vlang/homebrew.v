module cask

import brew_runtime

// Translated from Homebrew/brew `cask/uninstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.uninstall_casks(*casks, binaries: false, force: false, verbose: false)` at line 13.
pub fn ruby_uninstall_l13_d1_self_uninstall_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.uninstall_casks', ...args)
}

// Ruby method `self.unpin_for_removal?(cask, force:)` at line 39.
pub fn ruby_uninstall_l39_d2_self_unpin_for_removal(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.unpin_for_removal?', ...args)
}

// Ruby method `self.check_dependent_casks(*casks, named_args: [])` at line 52.
pub fn ruby_uninstall_l52_d3_self_check_dependent_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check_dependent_casks', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask_dependent"
// 5: require "dependents_message"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   class Uninstall
// 10:     extend ::Utils::Output::Mixin
// 11:
// 12:     sig { params(casks: ::Cask::Cask, binaries: T::Boolean, force: T::Boolean, verbose: T::Boolean).void }
// 13:     def self.uninstall_casks(*casks, binaries: false, force: false, verbose: false)
// 14:       require "cask/installer"
// 15:
// 16:       caught_exceptions = []
// 17:
// 18:       casks.each do |cask|
// 19:         odebug "Uninstalling Cask #{cask}"
// 20:
// 21:         raise CaskNotInstalledError, cask if !cask.installed? && !force
// 22:
// 23:         next unless unpin_for_removal?(cask, force:)
// 24:
// 25:         Installer.new(cask, binaries:, force:, verbose:).uninstall
// 26:       rescue => e
// 27:         caught_exceptions << e
// 28:         next
// 29:       end
// 30:
// 31:       return if caught_exceptions.empty?
// 32:
// 33:       raise MultipleCaskErrors, caught_exceptions if caught_exceptions.count > 1
// 34:
// 35:       raise caught_exceptions.fetch(0)
// 36:     end
// 37:
// 38:     sig { params(cask: ::Cask::Cask, force: T::Boolean).returns(T::Boolean) }
// 39:     def self.unpin_for_removal?(cask, force:)
// 40:       return true unless cask.pinned?
// 41:
// 42:       unless force
// 43:         onoe "#{cask.full_name} is pinned. You must unpin it to uninstall."
// 44:         return false
// 45:       end
// 46:
// 47:       cask.unpin
// 48:       true
// 49:     end
// 50:
// 51:     sig { params(casks: ::Cask::Cask, named_args: T::Array[String]).void }
// 52:     def self.check_dependent_casks(*casks, named_args: [])
// 53:       dependents = []
// 54:       all_requireds = casks.map(&:token)
// 55:       requireds = Set.new
// 56:       caskroom = ::Cask::Caskroom.casks
// 57:
// 58:       caskroom.each do |dependent|
// 59:         next if all_requireds.include?(dependent.token)
// 60:
// 61:         d = CaskDependent.new(dependent)
// 62:         dependencies = d.recursive_requirements.filter_map { |r| r.cask if r.is_a?(CaskDependent::Requirement) }
// 63:         found_dependents = dependencies.intersection(all_requireds)
// 64:         next if found_dependents.empty?
// 65:
// 66:         requireds += found_dependents
// 67:         dependents << dependent.token
// 68:       end
// 69:
// 70:       return if dependents.empty?
// 71:
// 72:       DependentsMessage.new(requireds.to_a, dependents, named_args:).output
// 73:     end
// 74:   end
// 75: end
