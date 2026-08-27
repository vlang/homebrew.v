module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/uninstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `uninstall_phase(upgrade: false, reinstall: false, quit: true, **options)` at line 20.
pub fn ruby_uninstall_l20_d1_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `post_uninstall_phase(**options)` at line 52.
pub fn ruby_uninstall_l52_d2_post_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('post_uninstall_phase', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_uninstall"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `uninstall` stanza.
// 9:     class Uninstall < AbstractUninstall
// 10:       UPGRADE_REINSTALL_SKIP_DIRECTIVES = [:signal].freeze
// 11:
// 12:       sig {
// 13:         params(
// 14:           upgrade:   T::Boolean,
// 15:           reinstall: T::Boolean,
// 16:           quit:      T::Boolean,
// 17:           options:   T.anything,
// 18:         ).void
// 19:       }
// 20:       def uninstall_phase(upgrade: false, reinstall: false, quit: true, **options)
// 21:         raw_on_upgrade = directives[:on_upgrade]
// 22:         on_upgrade_syms =
// 23:           case raw_on_upgrade
// 24:           when Symbol
// 25:             [raw_on_upgrade]
// 26:           when Array
// 27:             raw_on_upgrade.map(&:to_sym)
// 28:           else
// 29:             []
// 30:           end
// 31:         on_upgrade_set = on_upgrade_syms.to_set
// 32:
// 33:         filtered_directives = ORDERED_DIRECTIVES.filter do |directive_sym|
// 34:           next false if directive_sym == :rmdir
// 35:           next false if directive_sym == :quit && !quit
// 36:
// 37:           if (upgrade || reinstall) &&
// 38:              UPGRADE_REINSTALL_SKIP_DIRECTIVES.include?(directive_sym) &&
// 39:              on_upgrade_set.exclude?(directive_sym)
// 40:             next false
// 41:           end
// 42:
// 43:           true
// 44:         end
// 45:
// 46:         filtered_directives.each do |directive_sym|
// 47:           dispatch_uninstall_directive(directive_sym, **options, upgrade:)
// 48:         end
// 49:       end
// 50:
// 51:       sig { params(options: T.anything).void }
// 52:       def post_uninstall_phase(**options)
// 53:         dispatch_uninstall_directive(:rmdir, **options)
// 54:       end
// 55:     end
// 56:   end
// 57: end
