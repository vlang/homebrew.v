module bundle

import ruby

// Translated from Homebrew/brew `extend/os/linux/bundle/brew_services.rb`.

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
