module os

import brew_runtime

// Translated from Homebrew/brew `os/linux.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.os_version` at line 24.
pub fn ruby_linux_l24_d1_self_os_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.os_version', ...args)
}

// Ruby method `self.wsl?` at line 45.
pub fn ruby_linux_l45_d2_self_wsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.wsl?', ...args)
}

// Ruby method `self.inside_docker?` at line 50.
pub fn ruby_linux_l50_d3_self_inside_docker(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.inside_docker?', ...args)
}

// Ruby method `self.wsl_version` at line 59.
pub fn ruby_linux_l59_d4_self_wsl_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.wsl_version', ...args)
}

// Ruby method `self.languages` at line 75.
pub fn ruby_linux_l75_d5_self_languages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.languages', ...args)
}

// Ruby method `self.language` at line 94.
pub fn ruby_linux_l94_d6_self_language(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.language', ...args)
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
