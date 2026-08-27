module extensions

import brew_runtime

// Translated from Homebrew/brew `bundle/extensions/krew.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `type = :krew` at line 11.
pub fn ruby_krew_l11_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `check_label = "Krew Plugin"` at line 14.
pub fn ruby_krew_l14_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_label', ...args)
}

// Ruby method `banner_name = "Krew plugins"` at line 17.
pub fn ruby_krew_l17_d3_banner_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('banner_name', ...args)
}

// Ruby method `reset!` at line 20.
pub fn ruby_krew_l20_d4_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset!', ...args)
}

// Ruby method `cleanup_heading` at line 27.
pub fn ruby_krew_l27_d5_cleanup_heading(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_heading', ...args)
}

// Ruby method `package_manager_executable` at line 32.
pub fn ruby_krew_l32_d6_package_manager_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('package_manager_executable', ...args)
}

// Ruby method `packages` at line 37.
pub fn ruby_krew_l37_d7_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('packages', ...args)
}

// Ruby method `install_package!(name, with: nil, verbose: false)` at line 57.
pub fn ruby_krew_l57_d8_install_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_package!', ...args)
}

// Ruby method `installed_packages` at line 66.
pub fn ruby_krew_l66_d9_installed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_packages', ...args)
}

// Ruby method `parse_plugin_list(output)` at line 74.
pub fn ruby_krew_l74_d10_parse_plugin_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_plugin_list', ...args)
}

// Ruby method `uninstall_package!(name, executable: Pathname.new(""))` at line 86.
pub fn ruby_krew_l86_d11_uninstall_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_package!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     class Krew < Extension
// 9:       class << self
// 10:         sig { override.returns(Symbol) }
// 11:         def type = :krew
// 12:
// 13:         sig { override.returns(String) }
// 14:         def check_label = "Krew Plugin"
// 15:
// 16:         sig { override.returns(String) }
// 17:         def banner_name = "Krew plugins"
// 18:
// 19:         sig { override.void }
// 20:         def reset!
// 21:           @packages = T.let(nil, T.nilable(T::Array[String]))
// 22:           @installed_packages = T.let(nil, T.nilable(T::Array[String]))
// 23:           @package_manager_executable = T.let(nil, T.nilable(Pathname))
// 24:         end
// 25:
// 26:         sig { override.returns(T.nilable(String)) }
// 27:         def cleanup_heading
// 28:           banner_name
// 29:         end
// 30:
// 31:         sig { override.returns(T.nilable(Pathname)) }
// 32:         def package_manager_executable
// 33:           @package_manager_executable ||= T.let(which("kubectl-krew", ORIGINAL_PATHS), T.nilable(Pathname))
// 34:         end
// 35:
// 36:         sig { override.returns(T::Array[String]) }
// 37:         def packages
// 38:           packages = @packages
// 39:           return packages if packages
// 40:
// 41:           @packages = if package_manager_installed?
// 42:             with_package_manager_env do |krew|
// 43:               parse_plugin_list(`#{krew} list 2>/dev/null`)
// 44:             end
// 45:           else
// 46:             []
// 47:           end
// 48:         end
// 49:
// 50:         sig {
// 51:           override.params(
// 52:             name:    String,
// 53:             with:    T.nilable(T::Array[String]),
// 54:             verbose: T::Boolean,
// 55:           ).returns(T::Boolean)
// 56:         }
// 57:         def install_package!(name, with: nil, verbose: false)
// 58:           _ = with
// 59:
// 60:           with_package_manager_env do |krew|
// 61:             Bundle.system(krew.to_s, "install", name, verbose:)
// 62:           end
// 63:         end
// 64:
// 65:         sig { override.returns(T::Array[String]) }
// 66:         def installed_packages
// 67:           installed_packages = @installed_packages
// 68:           return installed_packages if installed_packages
// 69:
// 70:           @installed_packages = packages.dup
// 71:         end
// 72:
// 73:         sig { params(output: String).returns(T::Array[String]) }
// 74:         def parse_plugin_list(output)
// 75:           output.lines.filter_map do |line|
// 76:             line = line.strip
// 77:             next if line.empty?
// 78:
// 79:             name = line.split(/\s+/).first
// 80:             name.presence
// 81:           end.uniq
// 82:         end
// 83:         private :parse_plugin_list
// 84:
// 85:         sig { override.params(name: String, executable: Pathname).void }
// 86:         def uninstall_package!(name, executable: Pathname.new(""))
// 87:           Bundle.system(executable.to_s, "uninstall", name, verbose: false)
// 88:         end
// 89:       end
// 90:     end
// 91:   end
// 92: end
