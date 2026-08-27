module homebrew

import brew_runtime

// Translated from Homebrew/brew `os.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.mac?` at line 12.
pub fn ruby_os_l12_d1_self_mac(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.mac?', ...args)
}

// Ruby method `self.linux?` at line 22.
pub fn ruby_os_l22_d2_self_linux(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.linux?', ...args)
}

// Ruby method `self.wsl?` at line 32.
pub fn ruby_os_l32_d3_self_wsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.wsl?', ...args)
}

// Ruby method `self.kernel_version` at line 42.
pub fn ruby_os_l42_d4_self_kernel_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.kernel_version', ...args)
}

// Ruby method `self.kernel_name` at line 51.
pub fn ruby_os_l51_d5_self_kernel_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.kernel_name', ...args)
}

// Ruby method `self.nix_managed_homebrew?` at line 69.
pub fn ruby_os_l69_d6_self_nix_managed_homebrew(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.nix_managed_homebrew?', ...args)
}

// Ruby method `self.nix_managed_homebrew_issues_url` at line 74.
pub fn ruby_os_l74_d7_self_nix_managed_homebrew_issues_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.nix_managed_homebrew_issues_url', ...args)
}

// Ruby method `self.nix_homebrew?` at line 83.
pub fn ruby_os_l83_d8_self_nix_homebrew(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.nix_homebrew?', ...args)
}

// Ruby method `self.nix_darwin?` at line 95.
pub fn ruby_os_l95_d9_self_nix_darwin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.nix_darwin?', ...args)
}

// Ruby method `self.not_tier_one_configuration?` at line 135.
pub fn ruby_os_l135_d10_self_not_tier_one_configuration(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.not_tier_one_configuration?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "version"
// 5:
// 6: # Helper functions for querying operating system information.
// 7: module OS
// 8:   # Check whether the operating system is macOS.
// 9:   #
// 10:   # @api public
// 11:   sig { returns(T::Boolean) }
// 12:   def self.mac?
// 13:     return false if ENV["HOMEBREW_TEST_GENERIC_OS"]
// 14:
// 15:     RbConfig::CONFIG["host_os"].include? "darwin"
// 16:   end
// 17:
// 18:   # Check whether the operating system is Linux.
// 19:   #
// 20:   # @api public
// 21:   sig { returns(T::Boolean) }
// 22:   def self.linux?
// 23:     return false if ENV["HOMEBREW_TEST_GENERIC_OS"]
// 24:
// 25:     RbConfig::CONFIG["host_os"].include? "linux"
// 26:   end
// 27:
// 28:   # Check whether the operating system is Linux on windows (WSL).
// 29:   #
// 30:   # @api public
// 31:   sig { returns(T::Boolean) }
// 32:   def self.wsl?
// 33:     return false if ENV["HOMEBREW_TEST_GENERIC_OS"]
// 34:
// 35:     /-microsoft/i.match?(kernel_version.to_s)
// 36:   end
// 37:
// 38:   # Get the kernel version.
// 39:   #
// 40:   # @api public
// 41:   sig { returns(Version) }
// 42:   def self.kernel_version
// 43:     require "etc"
// 44:     @kernel_version ||= T.let(Version.new(Etc.uname.fetch(:release)), T.nilable(Version))
// 45:   end
// 46:
// 47:   # Get the kernel name.
// 48:   #
// 49:   # @api public
// 50:   sig { returns(String) }
// 51:   def self.kernel_name
// 52:     require "etc"
// 53:     @kernel_name ||= T.let(Etc.uname.fetch(:sysname), T.nilable(String))
// 54:   end
// 55:
// 56:   ::OS_VERSION = T.let(ENV.fetch("HOMEBREW_OS_VERSION").freeze, String)
// 57:
// 58:   # See Linux-CI.md
// 59:   LINUX_CI_OS_VERSION = "Ubuntu 24.04"
// 60:   LINUX_CI_ARM_RUNNER = "ubuntu-24.04-arm"
// 61:   LINUX_GLIBC_CI_VERSION = "2.39"
// 62:   LINUX_GLIBC_NEXT_CI_VERSION = "2.39" # users below this version will be warned by `brew doctor`
// 63:   LINUX_GCC_CI_VERSION = "13" # https://packages.ubuntu.com/noble/gcc
// 64:   LINUX_LIBSTDCXX_CI_VERSION = "6.0.33" # https://packages.ubuntu.com/noble/libstdc++6
// 65:   LINUX_PREFERRED_GCC_COMPILER_FORMULA = T.let("gcc@#{LINUX_GCC_CI_VERSION}".freeze, String)
// 66:   LINUX_PREFERRED_GCC_RUNTIME_FORMULA = "gcc"
// 67:
// 68:   sig { returns(T::Boolean) }
// 69:   def self.nix_managed_homebrew?
// 70:     nix_homebrew? || nix_darwin?
// 71:   end
// 72:
// 73:   sig { returns(String) }
// 74:   def self.nix_managed_homebrew_issues_url
// 75:     if nix_homebrew?
// 76:       "https://github.com/zhaofengli/nix-homebrew/issues"
// 77:     else
// 78:       "https://github.com/nix-darwin/nix-darwin/issues"
// 79:     end
// 80:   end
// 81:
// 82:   sig { returns(T::Boolean) }
// 83:   def self.nix_homebrew?
// 84:     # nix-homebrew sets this repository name, creates this prefix marker and
// 85:     # exports these update values.
// 86:     # https://github.com/zhaofengli/nix-homebrew/blob/aeb2069920742d0d6570089e8b3b8620050bacf2/modules/default.nix#L29-L31
// 87:     # https://github.com/zhaofengli/nix-homebrew/blob/aeb2069920742d0d6570089e8b3b8620050bacf2/modules/default.nix#L115-L125
// 88:     HOMEBREW_REPOSITORY.basename.to_s == ".homebrew-is-managed-by-nix" ||
// 89:       (HOMEBREW_PREFIX/".managed_by_nix_darwin").exist? ||
// 90:       (ENV["HOMEBREW_UPDATE_BEFORE"] == "nix" && ENV["HOMEBREW_UPDATE_AFTER"] == "nix")
// 91:   end
// 92:   private_class_method :nix_homebrew?
// 93:
// 94:   sig { returns(T::Boolean) }
// 95:   def self.nix_darwin?
// 96:     # nix-darwin manages Homebrew through `brew bundle` during activation.
// 97:     # https://github.com/nix-darwin/nix-darwin/blob/8c62fba0854ba15c8917aed18894dbccb48a3777/modules/homebrew.nix#L76-L129
// 98:     ENV.fetch("HOMEBREW_BUNDLE_FILE", "").start_with?("/nix/store/") ||
// 99:       ARGV.each_cons(2).any? { |arg, value| arg == "--file" && value.start_with?("/nix/store/") } ||
// 100:       ARGV.any? { |arg| arg.start_with?("--file=/nix/store/") }
// 101:   end
// 102:   private_class_method :nix_darwin?
// 103:
// 104:   nix_managed_homebrew = T.let(OS.nix_managed_homebrew?, T::Boolean)
// 105:
// 106:   if OS.mac?
// 107:     require "os/mac"
// 108:     require "hardware"
// 109:     # Don't tell people to report issues on non-Tier 1 configurations.
// 110:     if nix_managed_homebrew
// 111:       ISSUES_URL = OS.nix_managed_homebrew_issues_url.freeze
// 112:     elsif !OS::Mac.version.prerelease? &&
// 113:           !OS::Mac.version.outdated_release? &&
// 114:           ARGV.none? { |v| v.start_with?("--cc=") } &&
// 115:           (HOMEBREW_PREFIX.to_s == HOMEBREW_DEFAULT_PREFIX ||
// 116:           (HOMEBREW_PREFIX.to_s == HOMEBREW_MACOS_ARM_DEFAULT_PREFIX && Hardware::CPU.arm?))
// 117:       ISSUES_URL = "https://docs.brew.sh/Troubleshooting"
// 118:     end
// 119:     PATH_OPEN = "/usr/bin/open"
// 120:   elsif OS.linux?
// 121:     require "os/linux"
// 122:     ISSUES_URL = if nix_managed_homebrew
// 123:       OS.nix_managed_homebrew_issues_url
// 124:     else
// 125:       "https://docs.brew.sh/Troubleshooting"
// 126:     end.freeze
// 127:     PATH_OPEN = if wsl? && (wslview = which("wslview"))
// 128:       wslview.to_s
// 129:     else
// 130:       "xdg-open"
// 131:     end.freeze
// 132:   end
// 133:
// 134:   sig { returns(T::Boolean) }
// 135:   def self.not_tier_one_configuration?
// 136:     !defined?(OS::ISSUES_URL)
// 137:   end
// 138: end
