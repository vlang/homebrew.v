module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/simulate_system.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `os` at line 9.
pub fn ruby_simulate_system_l9_d1_os(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os', ...args)
}

// Ruby method `simulating_or_running_on_linux?` at line 19.
pub fn ruby_simulate_system_l19_d2_simulating_or_running_on_linux(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('simulating_or_running_on_linux?', ...args)
}

// Ruby method `current_os` at line 24.
pub fn ruby_simulate_system_l24_d3_current_os(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current_os', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module SimulateSystem
// 7:       module ClassMethods
// 8:         sig { returns(T.nilable(Symbol)) }
// 9:         def os
// 10:           @os ||= T.let(nil, T.nilable(Symbol))
// 11:           if @os.blank? && Homebrew::EnvConfig.simulate_macos_on_linux?
// 12:             return MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 13:           end
// 14:
// 15:           @os
// 16:         end
// 17:
// 18:         sig { returns(T::Boolean) }
// 19:         def simulating_or_running_on_linux?
// 20:           os.blank? || os == :linux
// 21:         end
// 22:
// 23:         sig { returns(Symbol) }
// 24:         def current_os
// 25:           os || :linux
// 26:         end
// 27:       end
// 28:     end
// 29:   end
// 30: end
// 31:
// 32: Homebrew::SimulateSystem.singleton_class.prepend(OS::Linux::SimulateSystem::ClassMethods)
