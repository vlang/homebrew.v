module utils

import ruby
import os

// Translated from Homebrew/brew `utils/service.rb`.

pub struct ServiceFormula {
pub:
	plist_name           string
	service_name         string
	launchd_service_path string
	systemd_service_path string
}

pub struct ServiceManagerState {
pub:
	launchctl_path    string
	systemctl_path    string
	launchctl_running bool
	systemctl_active  bool
}

pub fn service_running(formula ServiceFormula, state ServiceManagerState) bool {
	if state.launchctl_path != '' {
		return state.launchctl_running
	}
	if state.systemctl_path != '' {
		return state.systemctl_active
	}
	_ = formula
	return false
}

pub fn service_installed(formula ServiceFormula, state ServiceManagerState) bool {
	return (state.launchctl_path != '' && os.exists(formula.launchd_service_path))
		|| (state.systemctl_path != '' && os.exists(formula.systemd_service_path))
}

pub fn service_executable(name string, generic_os bool, path_environment string) ?string {
	if generic_os {
		return none
	}
	for directory in path_environment.split(os.path_delimiter) {
		if directory == '' {
			continue
		}
		path := os.join_path(directory, name)
		if os.is_file(path) && os.is_executable(path) {
			return path
		}
	}
	return none
}

pub fn systemd_quote(value string) string {
	mut result := '"'
	for character in value.bytes() {
		result += match character {
			7 { r'\a' }
			8 { r'\b' }
			12 { r'\f' }
			10 { r'\n' }
			13 { r'\r' }
			9 { r'\t' }
			11 { r'\v' }
			`\\` { r'\\' }
			`"` { r'\"' }
			else { character.ascii_str() }
		}
	}
	return result + '"'
}

fn service_formula_from_value(value ruby.Value) ServiceFormula {
	return ServiceFormula{
		plist_name: value.attributes['plist_name']
		service_name: value.attributes['service_name']
		launchd_service_path: value.attributes['launchd_service_path']
		systemd_service_path: value.attributes['systemd_service_path']
	}
}

fn service_state_from_value(value ruby.Value) ServiceManagerState {
	return ServiceManagerState{
		launchctl_path: value.attributes['launchctl_path']
		systemctl_path: value.attributes['systemctl_path']
		launchctl_running: value.attributes['launchctl_running'] == 'true'
		systemctl_active: value.attributes['systemctl_active'] == 'true'
	}
}
