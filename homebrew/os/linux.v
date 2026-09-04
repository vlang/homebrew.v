module os

import ruby
import os as system_os

pub struct LinuxRuntime {
pub mut:
	languages_cache []string
}

pub fn linux_os_version(lsb_available bool, lsb_output string, fallback string) !string {
	if lsb_available {
		mut description := ''
		mut codename := ''
		for line in lsb_output.split_into_lines() {
			if line.starts_with('Description:') {
				description = line.all_after(':').trim_space()
			} else if line.starts_with('Codename:') {
				codename = line.all_after(':').trim_space()
			}
		}
		if description == '' {
			return error('Failed to parse lsb_release output: ${lsb_output}')
		}
		return if codename == '' || codename == 'n/a' {
			description
		} else {
			'${description} (${codename})'
		}
	}
	return if fallback != '' { fallback } else { 'Unknown' }
}

pub fn linux_inside_docker(dockerenv bool, containerenv bool, cgroup_exists bool,
	cgroup string) bool {
	if dockerenv || containerenv {
		return true
	}
	if !cgroup_exists {
		return false
	}
	for marker in ['azpl_job', 'actions_job', 'docker', 'garden', 'kubepods'] {
		if cgroup.contains(marker) {
			return true
		}
	}
	return false
}

pub fn linux_inside_docker_current() bool {
	cgroup_path := '/proc/1/cgroup'
	return linux_inside_docker(system_os.is_file('/.dockerenv'), system_os.is_file('/run/.containerenv'), system_os.is_file(cgroup_path), if system_os.is_file(cgroup_path) {
		system_os.read_file(cgroup_path) or { '' }
	} else {
		''
	})
}

fn linux_version_parts(version string) []int {
	prefix := version.all_before('-')
	return prefix.split('.').map(it.int())
}

fn linux_compare_versions(left string, right string) int {
	left_parts := linux_version_parts(left)
	right_parts := linux_version_parts(right)
	max_len := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. max_len {
		left_value := if index < left_parts.len { left_parts[index] } else { 0 }
		right_value := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_value != right_value {
			return if left_value < right_value { -1 } else { 1 }
		}
	}
	return 0
}

pub fn linux_wsl_version(is_wsl bool, kernel string) string {
	if !is_wsl {
		return ''
	}
	if kernel.contains('-') && linux_compare_versions(kernel, '5.15') > 0 {
		return '2 (Microsoft Store)'
	}
	if kernel.contains('-microsoft') {
		return '2'
	}
	if kernel.contains('-Microsoft') {
		return '1'
	}
	return ''
}

fn linux_locale_tokens(output string) []string {
	mut tokens := []string{}
	mut token := ''
	for character in output.runes() {
		if character in [` `, `\t`, `\n`, `\r`, `\v`, `\f`, `,`, `(`, `)`, `"`] {
			if token != '' {
				tokens << token
				token = ''
			}
		} else {
			token += character.str()
		}
	}
	if token != '' {
		tokens << token
	}
	return tokens
}

pub fn linux_languages(localectl_output string, environment map[string]string) []string {
	mut values := if localectl_output != '' {
		linux_locale_tokens(localectl_output)
	} else {
		mut keys := environment.keys().filter(it == 'LANG' || it == 'LANGUAGE' || it.starts_with('LC_'))
		keys.sort()
		mut locales := []string{}
		for key in keys {
			if environment[key] != '' {
				locales << environment[key]
			}
		}
		locales
	}
	if values.len == 0 {
		values = ['en_US.utf8']
	}
	return values.map(it.all_before('.').replace('_', '-'))
}

pub fn (mut runtime LinuxRuntime) languages(localectl_output string,
	environment map[string]string) []string {
	if runtime.languages_cache.len == 0 {
		runtime.languages_cache = linux_languages(localectl_output, environment)
	}
	return runtime.languages_cache.clone()
}

// Translated from Homebrew/brew `os/linux.rb`.
