module mac

import ruby

// Translated from Homebrew/brew `extend/os/mac/simulate_system.rb`.

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
