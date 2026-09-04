module bundle

import ruby

// Translated from Homebrew/brew `extend/os/linux/bundle/bundle.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `prepend_pkgconf_path_if_needed!` at line 11.
pub fn ruby_bundle_l11_d1_prepend_pkgconf_path_if_needed(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.string_value(if args.len > 0 { args[0].as_string() } else { '' })
	}
	return ruby.string_value(prepend_pkgconf_path_if_needed(args[0].as_string(),
		args[1].as_string(), args[2].as_bool() or { false }))
}

pub fn prepend_pkgconf_path_if_needed(current_path string, pkgconf_opt_bin string,
	installed bool) string {
	if !installed {
		return current_path
	}
	if current_path.len == 0 {
		return pkgconf_opt_bin
	}
	return '${pkgconf_opt_bin}:${current_path}'
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Bundle
// 7:       module ClassMethods
// 8:         # Setup pkg-config, if present, to help locate packages
// 9:         # Only need this on Linux as Homebrew provides a shim on macOS
// 10:         sig { void }
// 11:         def prepend_pkgconf_path_if_needed!
// 12:           pkgconf = Formulary.factory("pkgconf")
// 13:           return unless pkgconf.any_version_installed?
// 14:
// 15:           ENV.prepend_path "PATH", pkgconf.opt_bin.to_s
// 16:         end
// 17:       end
// 18:     end
// 19:   end
// 20: end
// 21:
// 22: Homebrew::Bundle.singleton_class.prepend(OS::Linux::Bundle::ClassMethods)
