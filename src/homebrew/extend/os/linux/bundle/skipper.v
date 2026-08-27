module bundle

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/bundle/skipper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `requires_macos?(entry)` at line 11.
pub fn ruby_skipper_l11_d1_requires_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires_macos?', ...args)
}

// Ruby method `requires_wsl?(entry)` at line 31.
pub fn ruby_skipper_l31_d2_requires_wsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires_wsl?', ...args)
}

// Ruby method `skip?(entry, silent: false)` at line 36.
pub fn ruby_skipper_l36_d3_skip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/cask_loader"
// 5: module OS
// 6:   module Linux
// 7:     module Bundle
// 8:       module Skipper
// 9:         module ClassMethods
// 10:           sig { params(entry: Homebrew::Bundle::Dsl::Entry).returns(T::Boolean) }
// 11:           def requires_macos?(entry)
// 12:             case entry.type
// 13:             when :mas
// 14:               true
// 15:             when :cask
// 16:               !::Cask::CaskLoader.load(entry.name).supports_linux?
// 17:             else
// 18:               false
// 19:             end
// 20:           rescue ::Cask::CaskError
// 21:             # If the cask can't be loaded, it may be from a tap that hasn't been
// 22:             # tapped yet. Don't assume macOS-only in that case — let the normal
// 23:             # install flow handle it after the tap is processed.
// 24:             full_name = T.cast(entry.options[:full_name], T.nilable(String))
// 25:             return false if full_name&.include?("/")
// 26:
// 27:             true
// 28:           end
// 29:
// 30:           sig { params(entry: Homebrew::Bundle::Dsl::Entry).returns(T::Boolean) }
// 31:           def requires_wsl?(entry)
// 32:             entry.type == :winget && !OS.wsl?
// 33:           end
// 34:
// 35:           sig { params(entry: Homebrew::Bundle::Dsl::Entry, silent: T::Boolean).returns(T::Boolean) }
// 36:           def skip?(entry, silent: false)
// 37:             if requires_wsl?(entry)
// 38:               $stdout.puts Formatter.warning("Skipping #{entry.type} #{entry.name} (requires WSL)") unless silent
// 39:               return true
// 40:             end
// 41:
// 42:             return super unless requires_macos?(entry)
// 43:
// 44:             $stdout.puts Formatter.warning("Skipping #{entry.type} #{entry.name} (requires macOS)") unless silent
// 45:             true
// 46:           end
// 47:         end
// 48:       end
// 49:     end
// 50:   end
// 51: end
// 52:
// 53: Homebrew::Bundle::Skipper.singleton_class.prepend(OS::Linux::Bundle::Skipper::ClassMethods)
