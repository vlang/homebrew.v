module linux

import ruby

// Translated from Homebrew/brew `extend/os/linux/simulate_system.rb`.

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

fn optional_linux_os_value(value string) ruby.Value {
	return if value.len > 0 {
		ruby.object_value('Symbol', value)
	} else {
		ruby.object_value('Nil', '')
	}
}
