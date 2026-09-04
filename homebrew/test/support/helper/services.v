module helper

import ruby
import homebrew.services
import homebrew.services.system as systemctl

// Translated from Homebrew/brew `test/support/helper/services.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `reset_services_memoization!` at line 16.
pub fn ruby_services_l16_d1_reset_services_memoization(args ...ruby.Value) ruby.Value {
	if args.len > 0 && args[0].type_name == 'Homebrew::Services::System' {
		address := args[0].attributes['system_address'] or {
			return ruby.object_value('ArgumentError', 'invalid Services::System state')
		}
		mut state := unsafe { &services.ServiceSystem(voidptr(address.u64())) }
		state.launchctl_path = ''
		state.launchctl_resolved = false
	}
	if args.len > 1 && args[1].type_name == 'Homebrew::Services::System::Systemctl' {
		address := args[1].attributes['systemctl_state_address'] or {
			return ruby.object_value('ArgumentError', 'invalid Systemctl state')
		}
		mut state := unsafe { &systemctl.SystemctlState(voidptr(address.u64())) }
		state.set_executable(none)
	}
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/system"
// 5: require "services/system/systemctl"
// 6:
// 7: module Test
// 8:   module Helper
// 9:     # Helpers for the `Homebrew::Services` specs.
// 10:     module Services
// 11:       # `Homebrew::Services::System.launchctl` and
// 12:       # `Homebrew::Services::System::Systemctl.executable` memoize their lookups
// 13:       # for the life of the process. Examples that manipulate `PATH` to probe
// 14:       # discovery must clear those caches so they don't leak across examples.
// 15:       sig { void }
// 16:       def reset_services_memoization!
// 17:         Homebrew::Services::System.launchctl = nil
// 18:         Homebrew::Services::System::Systemctl.executable = nil
// 19:       end
// 20:     end
// 21:   end
// 22: end
