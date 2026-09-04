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
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.os_version` at line 24.
pub fn ruby_linux_l24_d1_self_os_version(args ...ruby.Value) ruby.Value {
	lsb_available := args.len > 0 && args[0].bool_data
	lsb_output := if args.len > 1 { args[1].as_string() } else { '' }
	fallback := if args.len > 2 { args[2].as_string() } else { '' }
	return ruby.string_value(linux_os_version(lsb_available, lsb_output, fallback) or { panic(err) })
}

// Ruby method `self.wsl?` at line 45.
pub fn ruby_linux_l45_d2_self_wsl(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && args[0].bool_data)
}

// Ruby method `self.inside_docker?` at line 50.
pub fn ruby_linux_l50_d3_self_inside_docker(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(linux_inside_docker_current())
	}
	return ruby.bool_value(linux_inside_docker(args[0].bool_data, args.len > 1 && args[1].bool_data, args.len > 2 && args[2].bool_data, if args.len > 3 {
		args[3].as_string()
	} else {
		''
	}))
}

// Ruby method `self.wsl_version` at line 59.
pub fn ruby_linux_l59_d4_self_wsl_version(args ...ruby.Value) ruby.Value {
	version := linux_wsl_version(args.len > 0 && args[0].bool_data, if args.len > 1 {
		args[1].as_string()
	} else {
		''
	})
	return ruby.structured_value('Version', if version == '' { 'NULL' } else { version }, {
		'version': version
	})
}

// Ruby method `self.languages` at line 75.
pub fn ruby_linux_l75_d5_self_languages(args ...ruby.Value) ruby.Value {
	output := if args.len > 0 { args[0].as_string() } else { '' }
	environment := if args.len > 1 {
		mut result := map[string]string{}
		for key, value in args[1].map_data {
			result[key] = value.as_string()
		}
		result
	} else {
		map[string]string{}
	}
	return ruby.string_array_value(linux_languages(output, environment))
}

// Ruby method `self.language` at line 94.
pub fn ruby_linux_l94_d6_self_language(args ...ruby.Value) ruby.Value {
	languages := if args.len > 0 {
		args[0].as_array() or { [] }.map(it.as_string())
	} else {
		linux_languages('', map[string]string{})
	}
	if languages.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(languages[0])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils"
// 5:
// 6: module OS
// 7:   # Helper module for querying system information on Linux.
// 8:   module Linux
// 9:     raise "Loaded OS::Linux on generic OS!" if ENV["HOMEBREW_TEST_GENERIC_OS"]
// 10:
// 11:     # This check is the only acceptable or necessary one in this file.
// 12:     # rubocop:disable Homebrew/MoveToExtendOS
// 13:     raise "Loaded OS::Linux on macOS!" if OS.mac?
// 14:     # rubocop:enable Homebrew/MoveToExtendOS
// 15:
// 16:     extend Utils::Output::Mixin
// 17:
// 18:     @languages = T.let([], T::Array[String])
// 19:
// 20:     # Get the OS version.
// 21:     #
// 22:     # @api internal
// 23:     sig { returns(String) }
// 24:     def self.os_version
// 25:       if which("lsb_release")
// 26:         lsb_info = Utils.popen_read("lsb_release", "-a")
// 27:         description = lsb_info[/^Description:\s*(.*)$/, 1]&.force_encoding("UTF-8")
// 28:
// 29:         odie "Failed to parse lsb_release output: #{lsb_info.inspect}" unless description
// 30:
// 31:         codename = lsb_info[/^Codename:\s*(.*)$/, 1]
// 32:         if codename.blank? || (codename == "n/a")
// 33:           description
// 34:         else
// 35:           "#{description} (#{codename})"
// 36:         end
// 37:       elsif ::OS_VERSION.present?
// 38:         ::OS_VERSION
// 39:       else
// 40:         "Unknown"
// 41:       end
// 42:     end
// 43:
// 44:     sig { returns(T::Boolean) }
// 45:     def self.wsl?
// 46:       OS.wsl?
// 47:     end
// 48:
// 49:     sig { returns(T::Boolean) }
// 50:     def self.inside_docker?
// 51:       return true if File.file?("/.dockerenv")
// 52:       return true if File.file?("/run/.containerenv")
// 53:       return false unless File.file?("/proc/1/cgroup")
// 54:
// 55:       File.read("/proc/1/cgroup").match?(/azpl_job|actions_job|docker|garden|kubepods/)
// 56:     end
// 57:
// 58:     sig { returns(Version) }
// 59:     def self.wsl_version
// 60:       return Version::NULL unless wsl?
// 61:
// 62:       kernel = OS.kernel_version.to_s
// 63:       if Version.new(T.must(kernel[/^([0-9.]*)-.*/, 1])) > Version.new("5.15")
// 64:         Version.new("2 (Microsoft Store)")
// 65:       elsif kernel.include?("-microsoft")
// 66:         Version.new("2")
// 67:       elsif kernel.include?("-Microsoft")
// 68:         Version.new("1")
// 69:       else
// 70:         Version::NULL
// 71:       end
// 72:     end
// 73:
// 74:     sig { returns(T::Array[String]) }
// 75:     def self.languages
// 76:       return @languages if @languages.present?
// 77:
// 78:       locale_variables = ENV.keys.grep(/^(?:LC_\S+|LANG|LANGUAGE)\Z/).sort
// 79:       ctl_ret = Utils.popen_read("localectl", "list-locales")
// 80:       list = T.let([], T::Array[String])
// 81:       if ctl_ret.present?
// 82:         list = T.cast(ctl_ret.scan(/[^ \n"(),]+/), T::Array[String])
// 83:       elsif locale_variables.present?
// 84:         keys = locale_variables.select { |var| ENV.fetch(var) }
// 85:         list = keys.map { |key| ENV.fetch(key) }
// 86:       else
// 87:         list = ["en_US.utf8"]
// 88:       end
// 89:
// 90:       @languages = list.map { |item| item.split(".").fetch(0).tr("_", "-") }
// 91:     end
// 92:
// 93:     sig { returns(T.nilable(String)) }
// 94:     def self.language
// 95:       languages.first
// 96:     end
// 97:   end
// 98: end
