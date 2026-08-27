module extensions

import brew_runtime

// Translated from Homebrew/brew `bundle/extensions/npm.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `type = :npm` at line 12.
pub fn ruby_npm_l12_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `check_label = "npm Package"` at line 15.
pub fn ruby_npm_l15_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_label', ...args)
}

// Ruby method `banner_name = "npm packages"` at line 18.
pub fn ruby_npm_l18_d3_banner_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('banner_name', ...args)
}

// Ruby method `reset!` at line 21.
pub fn ruby_npm_l21_d4_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset!', ...args)
}

// Ruby method `cleanup_heading` at line 27.
pub fn ruby_npm_l27_d5_cleanup_heading(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_heading', ...args)
}

// Ruby method `package_manager_name` at line 32.
pub fn ruby_npm_l32_d6_package_manager_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('package_manager_name', ...args)
}

// Ruby method `package_manager_executable` at line 37.
pub fn ruby_npm_l37_d7_package_manager_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('package_manager_executable', ...args)
}

// Ruby method `packages` at line 42.
pub fn ruby_npm_l42_d8_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('packages', ...args)
}

// Ruby method `install_package!(name, with: nil, verbose: false)` at line 64.
pub fn ruby_npm_l64_d9_install_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_package!', ...args)
}

// Ruby method `installed_packages` at line 73.
pub fn ruby_npm_l73_d10_installed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_packages', ...args)
}

// Ruby method `uninstall_package!(name, executable: Pathname.new(""))` at line 81.
pub fn ruby_npm_l81_d11_uninstall_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_package!', ...args)
}

// Ruby method `parse_package_list(output)` at line 86.
pub fn ruby_npm_l86_d12_parse_package_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_package_list', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5: require "language/node"
// 6:
// 7: module Homebrew
// 8:   module Bundle
// 9:     class Npm < Extension
// 10:       class << self
// 11:         sig { override.returns(Symbol) }
// 12:         def type = :npm
// 13:
// 14:         sig { override.returns(String) }
// 15:         def check_label = "npm Package"
// 16:
// 17:         sig { override.returns(String) }
// 18:         def banner_name = "npm packages"
// 19:
// 20:         sig { override.void }
// 21:         def reset!
// 22:           @packages = T.let(nil, T.nilable(T::Array[String]))
// 23:           @installed_packages = T.let(nil, T.nilable(T::Array[String]))
// 24:         end
// 25:
// 26:         sig { override.returns(T.nilable(String)) }
// 27:         def cleanup_heading
// 28:           banner_name
// 29:         end
// 30:
// 31:         sig { override.returns(String) }
// 32:         def package_manager_name
// 33:           "node"
// 34:         end
// 35:
// 36:         sig { override.returns(T.nilable(Pathname)) }
// 37:         def package_manager_executable
// 38:           which("npm", ORIGINAL_PATHS)
// 39:         end
// 40:
// 41:         sig { override.returns(T::Array[String]) }
// 42:         def packages
// 43:           packages = @packages
// 44:           return packages if packages
// 45:
// 46:           @packages = if (npm = package_manager_executable) &&
// 47:                          (!npm.to_s.start_with?("/") || npm.exist?)
// 48:             with_env(package_manager_env(npm)) do
// 49:               parse_package_list(`#{npm} list -g --depth=0 --json 2>/dev/null`)
// 50:             end
// 51:           end
// 52:           return [] if @packages.nil?
// 53:
// 54:           @packages
// 55:         end
// 56:
// 57:         sig {
// 58:           override.params(
// 59:             name:    String,
// 60:             with:    T.nilable(T::Array[String]),
// 61:             verbose: T::Boolean,
// 62:           ).returns(T::Boolean)
// 63:         }
// 64:         def install_package!(name, with: nil, verbose: false)
// 65:           _ = with
// 66:
// 67:           npm = package_manager_executable!
// 68:
// 69:           Bundle.system(npm.to_s, "install", *Language::Node.npm_install_security_args, "-g", name, verbose:)
// 70:         end
// 71:
// 72:         sig { override.returns(T::Array[String]) }
// 73:         def installed_packages
// 74:           installed_packages = @installed_packages
// 75:           return installed_packages if installed_packages
// 76:
// 77:           @installed_packages = packages.dup
// 78:         end
// 79:
// 80:         sig { override.params(name: String, executable: Pathname).void }
// 81:         def uninstall_package!(name, executable: Pathname.new(""))
// 82:           Bundle.system(executable.to_s, "uninstall", "-g", name, verbose: false)
// 83:         end
// 84:
// 85:         sig { params(output: String).returns(T::Array[String]) }
// 86:         def parse_package_list(output)
// 87:           return [] if output.blank?
// 88:
// 89:           json = JSON.parse(output)
// 90:           deps = json.fetch("dependencies", {})
// 91:           deps.keys.reject { |name| name == "npm" }
// 92:         rescue JSON::ParserError
// 93:           []
// 94:         end
// 95:         private :parse_package_list
// 96:       end
// 97:     end
// 98:   end
// 99: end
