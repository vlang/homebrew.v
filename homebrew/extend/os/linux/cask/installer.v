module cask

// Translated from Homebrew/brew `extend/os/linux/cask/installer.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn check_linux_cask_requirements(cask_name string, supports_linux bool) ! {
	if !supports_linux {
		return error('${cask_name}: This cask requires macOS.')
	}
}

// Ruby method `check_stanza_os_requirements` at line 13.
pub fn ruby_installer_l13_d1_check_stanza_os_requirements(cask_name string,
	supports_linux bool) ! {
	check_linux_cask_requirements(cask_name, supports_linux)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Cask
// 7:       module Installer
// 8:         extend T::Helpers
// 9:
// 10:         requires_ancestor { ::Cask::Installer }
// 11:
// 12:         sig { void }
// 13:         def check_stanza_os_requirements
// 14:           return if cask.supports_linux?
// 15:
// 16:           raise ::Cask::CaskError, "#{cask}: This cask requires macOS."
// 17:         end
// 18:       end
// 19:     end
// 20:   end
// 21: end
// 22:
// 23: Cask::Installer.prepend(OS::Linux::Cask::Installer)
