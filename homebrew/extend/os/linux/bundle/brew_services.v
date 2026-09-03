module bundle

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/bundle/brew_services.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `started_services_without_daemon_manager` at line 10.
pub fn ruby_brew_services_l10_d1_started_services_without_daemon_manager(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(started_services_without_daemon_manager().services)
}

pub struct StartedServicesResult {
pub:
	services []string
	warning  string
}

pub fn started_services_without_daemon_manager() StartedServicesResult {
	return StartedServicesResult{
		warning: 'Skipping `brew services list` due to missing systemctl'
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Bundle
// 7:       module BrewServices
// 8:         module ClassMethods
// 9:           sig { returns(T::Array[String]) }
// 10:           def started_services_without_daemon_manager
// 11:             Homebrew::Bundle::Brew::Services.opoo "Skipping `brew services list` due to missing systemctl"
// 12:             []
// 13:           end
// 14:         end
// 15:       end
// 16:     end
// 17:   end
// 18: end
// 19:
// 20: Homebrew::Bundle::Brew::Services.singleton_class.prepend(OS::Linux::Bundle::BrewServices::ClassMethods)
