module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/simulate_system.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `os` at line 9.
pub fn ruby_simulate_system_l9_d1_os(args ...brew_runtime.Value) brew_runtime.Value {
	simulated := if args.len > 0 { args[0].as_string() } else { '' }
	simulate_macos := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	newest := if args.len > 2 { args[2].as_string() } else { '' }
	return optional_linux_os_value(effective_os(simulated, simulate_macos, newest))
}

// Ruby method `simulating_or_running_on_linux?` at line 19.
pub fn ruby_simulate_system_l19_d2_simulating_or_running_on_linux(args ...brew_runtime.Value) brew_runtime.Value {
	os_value := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.bool_value(simulating_or_running_on_linux(os_value))
}

// Ruby method `current_os` at line 24.
pub fn ruby_simulate_system_l24_d3_current_os(args ...brew_runtime.Value) brew_runtime.Value {
	os_value := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.object_value('Symbol', current_os(os_value))
}

pub fn effective_os(simulated_os string, simulate_macos_on_linux bool,
	newest_supported_macos string) string {
	if simulated_os.len == 0 && simulate_macos_on_linux {
		return newest_supported_macos
	}
	return simulated_os
}

pub fn simulating_or_running_on_linux(effective_os_value string) bool {
	return effective_os_value.len == 0 || effective_os_value == 'linux'
}

pub fn current_os(effective_os_value string) string {
	return if effective_os_value.len > 0 { effective_os_value } else { 'linux' }
}

fn optional_linux_os_value(value string) brew_runtime.Value {
	return if value.len > 0 {
		brew_runtime.object_value('Symbol', value)
	} else {
		brew_runtime.object_value('Nil', '')
	}
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
