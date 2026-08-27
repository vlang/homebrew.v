module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/simulate_system.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `simulating_or_running_on_macos?` at line 9.
pub fn ruby_simulate_system_l9_d1_simulating_or_running_on_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('simulating_or_running_on_macos?', ...args)
}

// Ruby method `current_os` at line 16.
pub fn ruby_simulate_system_l16_d2_current_os(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current_os', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module SimulateSystem
// 7:       module ClassMethods
// 8:         sig { returns(T::Boolean) }
// 9:         def simulating_or_running_on_macos?
// 10:           return true if Homebrew::SimulateSystem.os.blank?
// 11:
// 12:           [:macos, *MacOSVersion::SYMBOLS.keys].include?(Homebrew::SimulateSystem.os)
// 13:         end
// 14:
// 15:         sig { returns(Symbol) }
// 16:         def current_os
// 17:           ::Homebrew::SimulateSystem.os || MacOS.version.to_sym
// 18:         end
// 19:       end
// 20:     end
// 21:   end
// 22: end
// 23:
// 24: Homebrew::SimulateSystem.singleton_class.prepend(OS::Mac::SimulateSystem::ClassMethods)
