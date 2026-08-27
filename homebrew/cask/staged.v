module cask

import brew_runtime

// Translated from Homebrew/brew `cask/staged.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `set_permissions(paths, permissions_str)` at line 19.
pub fn ruby_staged_l19_d1_set_permissions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_permissions', ...args)
}

// Ruby method `set_ownership(paths, user: T.must(User.current), group: "staff")` at line 28.
pub fn ruby_staged_l28_d2_set_ownership(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_ownership', ...args)
}

// Ruby method `remove_nonexistent(paths)` at line 58.
pub fn ruby_staged_l58_d3_remove_nonexistent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remove_nonexistent', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/quarantine"
// 5: require "utils/user"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   # Helper functions for staged casks.
// 10:   module Staged
// 11:     include ::Utils::Output::Mixin
// 12:     extend T::Helpers
// 13:
// 14:     requires_ancestor { ::Cask::DSL::Base }
// 15:
// 16:     Paths = T.type_alias { T.any(String, Pathname, T::Array[T.any(String, Pathname)]) }
// 17:
// 18:     sig { params(paths: Paths, permissions_str: String).void }
// 19:     def set_permissions(paths, permissions_str)
// 20:       full_paths = remove_nonexistent(paths)
// 21:       return if full_paths.empty?
// 22:
// 23:       command.run!("chmod", args: ["-R", "--", permissions_str, *full_paths],
// 24:                             sudo: false)
// 25:     end
// 26:
// 27:     sig { params(paths: Paths, user: T.any(String, User), group: String).void }
// 28:     def set_ownership(paths, user: T.must(User.current), group: "staff")
// 29:       full_paths = remove_nonexistent(paths)
// 30:       return if full_paths.empty?
// 31:
// 32:       # On macOS Ventura or later, modifying the contents of an app bundle
// 33:       # requires App Management permissions, even when using `sudo`. Without
// 34:       # them, every `chown` fails with `Operation not permitted`, so check
// 35:       # upfront: this triggers the system permission prompt (which a plain
// 36:       # `chown` does not) and allows giving the user an actionable error
// 37:       # message instead of a wall of `chown` errors.
// 38:       full_paths.each do |path|
// 39:         next if Quarantine.app_management_permissions_granted?(app: path, command:)
// 40:
// 41:         raise CaskError, <<~EOS
// 42:           Cannot change the ownership of '#{path}' because your terminal does not have App Management permissions.
// 43:           macOS prevents modifying apps without these permissions, even when using `sudo`.
// 44:           To fix this, approve the permissions prompt (if one was just shown) or go to
// 45:           System Settings → Privacy & Security → App Management and add or enable your terminal.
// 46:           Then run this command again.
// 47:         EOS
// 48:       end
// 49:
// 50:       ohai "Changing ownership of paths required by #{cask} with `sudo` (which may request your password)..."
// 51:       command.run!("chown", args: ["-R", "--", "#{user}:#{group}", *full_paths],
// 52:                             sudo: true)
// 53:     end
// 54:
// 55:     private
// 56:
// 57:     sig { params(paths: Paths).returns(T::Array[Pathname]) }
// 58:     def remove_nonexistent(paths)
// 59:       Array(paths).map { |p| Pathname(p).expand_path }.select(&:exist?)
// 60:     end
// 61:   end
// 62: end
