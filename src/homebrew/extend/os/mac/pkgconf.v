module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/pkgconf.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `macos_sdk_mismatch` at line 9.
pub fn ruby_pkgconf_l9_d1_macos_sdk_mismatch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_sdk_mismatch', ...args)
}

// Ruby method `mismatch_warning_message(mismatch)` at line 35.
pub fn ruby_pkgconf_l35_d2_mismatch_warning_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mismatch_warning_message', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Pkgconf
// 6:     module_function
// 7:
// 8:     sig { returns(T.nilable([String, String])) }
// 9:     def macos_sdk_mismatch
// 10:       # We don't provide suitable bottles for these versions.
// 11:       return if OS::Mac.version.prerelease? || OS::Mac.version.outdated_release?
// 12:
// 13:       pkgconf = begin
// 14:         ::Formula["pkgconf"]
// 15:       rescue FormulaUnavailableError
// 16:         nil
// 17:       end
// 18:       return unless pkgconf&.any_version_installed?
// 19:
// 20:       tab = Tab.for_formula(pkgconf)
// 21:       return unless (built_on = tab.built_on)
// 22:
// 23:       built_on_version = built_on["os_version"]
// 24:                          &.delete_prefix("macOS ")
// 25:                          &.sub(/\.\d+$/, "")
// 26:       return unless built_on_version
// 27:
// 28:       current_version = MacOS.version.to_s
// 29:       return if built_on_version == current_version
// 30:
// 31:       [built_on_version, current_version]
// 32:     end
// 33:
// 34:     sig { params(mismatch: [String, String]).returns(String) }
// 35:     def mismatch_warning_message(mismatch)
// 36:       <<~EOS
// 37:         You have pkgconf installed that was built on macOS #{mismatch[0]},
// 38:                 but you are running macOS #{mismatch[1]}.
// 39:
// 40:         This can cause issues with packages that depend on system libraries, such as libffi.
// 41:         To fix this issue, reinstall pkgconf:
// 42:           brew reinstall pkgconf
// 43:
// 44:         For more information, see: https://github.com/Homebrew/brew/issues/16137
// 45:       EOS
// 46:     end
// 47:   end
// 48: end
