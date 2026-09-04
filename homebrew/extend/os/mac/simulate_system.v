module mac

import ruby

// Translated from Homebrew/brew `extend/os/mac/simulate_system.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `simulating_or_running_on_macos?` at line 9.
pub fn ruby_simulate_system_l9_d1_simulating_or_running_on_macos(args ...ruby.Value) ruby.Value {
	os_value := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(simulating_or_running_on_macos(os_value))
}

// Ruby method `current_os` at line 16.
pub fn ruby_simulate_system_l16_d2_current_os(args ...ruby.Value) ruby.Value {
	simulated := if args.len > 0 { args[0].as_string() } else { '' }
	actual := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.object_value('Symbol', current_os(simulated, actual))
}

pub fn simulating_or_running_on_macos(simulated_os string) bool {
	return simulated_os.len == 0 || simulated_os == 'macos'
		|| simulated_os in ruby_macos_symbols()
}

pub fn current_os(simulated_os string, actual_macos_version string) string {
	return if simulated_os.len > 0 { simulated_os } else { actual_macos_version }
}

fn ruby_macos_symbols() []string {
	return ['golden_gate', 'tahoe', 'sequoia', 'sonoma', 'ventura', 'monterey', 'big_sur', 'catalina']
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
