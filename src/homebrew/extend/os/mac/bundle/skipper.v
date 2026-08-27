module bundle

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/bundle/skipper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `linux_only_entry?(entry)` at line 10.
pub fn ruby_skipper_l10_d1_linux_only_entry(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linux_only_entry?', ...args)
}

// Ruby method `skip?(entry, silent: false)` at line 15.
pub fn ruby_skipper_l15_d2_skip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Bundle
// 7:       module Skipper
// 8:         module ClassMethods
// 9:           sig { params(entry: Homebrew::Bundle::Dsl::Entry).returns(T::Boolean) }
// 10:           def linux_only_entry?(entry)
// 11:             entry.type == :flatpak
// 12:           end
// 13:
// 14:           sig { params(entry: Homebrew::Bundle::Dsl::Entry, silent: T::Boolean).returns(T::Boolean) }
// 15:           def skip?(entry, silent: false)
// 16:             if entry.type == :winget
// 17:               Kernel.puts Formatter.warning "Skipping #{entry.type} #{entry.name} (requires WSL)" unless silent
// 18:               true
// 19:             elsif linux_only_entry?(entry)
// 20:               unless silent
// 21:                 Kernel.puts Formatter.warning "Skipping #{entry.type} #{entry.name} (unsupported on macOS)"
// 22:               end
// 23:               true
// 24:             else
// 25:               super
// 26:             end
// 27:           end
// 28:         end
// 29:       end
// 30:     end
// 31:   end
// 32: end
// 33:
// 34: Homebrew::Bundle::Skipper.singleton_class.prepend(OS::Mac::Bundle::Skipper::ClassMethods)
