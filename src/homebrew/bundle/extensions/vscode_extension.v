module extensions

import brew_runtime

// Translated from Homebrew/brew `bundle/extensions/vscode_extension.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `type = :vscode` at line 13.
pub fn ruby_vscode_extension_l13_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `check_label = "VSCode Extension"` at line 16.
pub fn ruby_vscode_extension_l16_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_label', ...args)
}

// Ruby method `banner_name = "VSCode (and forks/variants) extensions"` at line 19.
pub fn ruby_vscode_extension_l19_d3_banner_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('banner_name', ...args)
}

// Ruby method `reset!` at line 22.
pub fn ruby_vscode_extension_l22_d4_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset!', ...args)
}

// Ruby method `cleanup_heading` at line 28.
pub fn ruby_vscode_extension_l28_d5_cleanup_heading(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_heading', ...args)
}

// Ruby method `package_record(name, with: nil)` at line 33.
pub fn ruby_vscode_extension_l33_d6_package_record(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('package_record', ...args)
}

// Ruby method `package_manager_executable` at line 40.
pub fn ruby_vscode_extension_l40_d7_package_manager_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('package_manager_executable', ...args)
}

// Ruby method `extensions` at line 48.
pub fn ruby_vscode_extension_l48_d8_extensions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extensions', ...args)
}

// Ruby method `packages` at line 64.
pub fn ruby_vscode_extension_l64_d9_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('packages', ...args)
}

// Ruby method `installed_packages` at line 69.
pub fn ruby_vscode_extension_l69_d10_installed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_packages', ...args)
}

// Ruby method `installed_extensions` at line 74.
pub fn ruby_vscode_extension_l74_d11_installed_extensions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_extensions', ...args)
}

// Ruby method `package_installed?(name, with: nil)` at line 82.
pub fn ruby_vscode_extension_l82_d12_package_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('package_installed?', ...args)
}

// Ruby method `preinstall!(name, with: nil, no_upgrade: false, verbose: false, **_options)` at line 97.
pub fn ruby_vscode_extension_l97_d13_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preinstall!', ...args)
}

// Ruby method `install_package!(name, with: nil, verbose: false)` at line 125.
pub fn ruby_vscode_extension_l125_d14_install_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_package!', ...args)
}

// Ruby method `install!(name, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,` at line 146.
pub fn ruby_vscode_extension_l146_d15_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install!', ...args)
}

// Ruby method `cleanup_items(entries)` at line 169.
pub fn ruby_vscode_extension_l169_d16_cleanup_items(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_items', ...args)
}

// Ruby method `cleanup!(extensions)` at line 181.
pub fn ruby_vscode_extension_l181_d17_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     class VscodeExtension < Extension
// 9:       EXTENSION_ID_REGEX = /\A[a-z0-9][a-z0-9-]*\.[a-z0-9][a-z0-9._-]*\z/i
// 10:
// 11:       class << self
// 12:         sig { override.returns(Symbol) }
// 13:         def type = :vscode
// 14:
// 15:         sig { override.returns(String) }
// 16:         def check_label = "VSCode Extension"
// 17:
// 18:         sig { override.returns(String) }
// 19:         def banner_name = "VSCode (and forks/variants) extensions"
// 20:
// 21:         sig { override.void }
// 22:         def reset!
// 23:           @extensions = T.let(nil, T.nilable(T::Array[String]))
// 24:           @installed_extensions = T.let(nil, T.nilable(T::Array[String]))
// 25:         end
// 26:
// 27:         sig { override.returns(T.nilable(String)) }
// 28:         def cleanup_heading
// 29:           "VSCode extensions"
// 30:         end
// 31:
// 32:         sig { override.params(name: String, with: T.nilable(T::Array[String])).returns(Object) }
// 33:         def package_record(name, with: nil)
// 34:           _ = with
// 35:
// 36:           name.downcase
// 37:         end
// 38:
// 39:         sig { override.returns(T.nilable(Pathname)) }
// 40:         def package_manager_executable
// 41:           which("code", ORIGINAL_PATHS) ||
// 42:             which("codium", ORIGINAL_PATHS) ||
// 43:             which("cursor", ORIGINAL_PATHS) ||
// 44:             which("code-insiders", ORIGINAL_PATHS)
// 45:         end
// 46:
// 47:         sig { returns(T::Array[String]) }
// 48:         def extensions
// 49:           extensions = @extensions
// 50:           return extensions if extensions
// 51:
// 52:           @extensions = if (vscode = package_manager_executable)
// 53:             Bundle.exchange_uid_if_needed! do
// 54:               ENV["WSL_DISTRO_NAME"] = ENV.fetch("HOMEBREW_WSL_DISTRO_NAME", nil)
// 55:               `"#{vscode}" --list-extensions 2>/dev/null`
// 56:             end.split("\n").map(&:strip).grep(EXTENSION_ID_REGEX).map(&:downcase)
// 57:           end
// 58:           return [] if @extensions.nil?
// 59:
// 60:           @extensions
// 61:         end
// 62:
// 63:         sig { override.returns(T::Array[String]) }
// 64:         def packages
// 65:           extensions
// 66:         end
// 67:
// 68:         sig { override.returns(T::Array[String]) }
// 69:         def installed_packages
// 70:           installed_extensions
// 71:         end
// 72:
// 73:         sig { returns(T::Array[String]) }
// 74:         def installed_extensions
// 75:           installed_extensions = @installed_extensions
// 76:           return installed_extensions if installed_extensions
// 77:
// 78:           @installed_extensions = extensions.dup
// 79:         end
// 80:
// 81:         sig { override.params(name: String, with: T.nilable(T::Array[String])).returns(T::Boolean) }
// 82:         def package_installed?(name, with: nil)
// 83:           _ = with
// 84:
// 85:           installed_extensions.include?(name.downcase)
// 86:         end
// 87:
// 88:         sig {
// 89:           override.params(
// 90:             name:       String,
// 91:             with:       T.nilable(T::Array[String]),
// 92:             no_upgrade: T::Boolean,
// 93:             verbose:    T::Boolean,
// 94:             _options:   Homebrew::Bundle::EntryOption,
// 95:           ).returns(T::Boolean)
// 96:         }
// 97:         def preinstall!(name, with: nil, no_upgrade: false, verbose: false, **_options)
// 98:           _ = with
// 99:           _ = no_upgrade
// 100:
// 101:           if !package_manager_installed? && Bundle.cask_installed?
// 102:             puts "Installing visual-studio-code. It is not currently installed." if verbose
// 103:             Bundle.system(HOMEBREW_BREW_FILE, "install", "--cask", "visual-studio-code", verbose:)
// 104:           end
// 105:
// 106:           if package_installed?(name)
// 107:             puts "Skipping install of #{name} VSCode extension. It is already installed." if verbose
// 108:             return false
// 109:           end
// 110:
// 111:           unless package_manager_installed?
// 112:             raise "Unable to install #{name} VSCode extension. VSCode is not installed."
// 113:           end
// 114:
// 115:           true
// 116:         end
// 117:
// 118:         sig {
// 119:           override.params(
// 120:             name:    String,
// 121:             with:    T.nilable(T::Array[String]),
// 122:             verbose: T::Boolean,
// 123:           ).returns(T::Boolean)
// 124:         }
// 125:         def install_package!(name, with: nil, verbose: false)
// 126:           _ = with
// 127:
// 128:           vscode = package_manager_executable!
// 129:
// 130:           Bundle.exchange_uid_if_needed! do
// 131:             Bundle.system(vscode, "--install-extension", name, verbose:)
// 132:           end
// 133:         end
// 134:
// 135:         sig {
// 136:           override.params(
// 137:             name:       String,
// 138:             with:       T.nilable(T::Array[String]),
// 139:             preinstall: T::Boolean,
// 140:             no_upgrade: T::Boolean,
// 141:             verbose:    T::Boolean,
// 142:             force:      T::Boolean,
// 143:             _options:   Homebrew::Bundle::EntryOption,
// 144:           ).returns(T::Boolean)
// 145:         }
// 146:         def install!(name, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,
// 147:                      **_options)
// 148:           _ = with
// 149:           _ = no_upgrade
// 150:           _ = force
// 151:
// 152:           return true unless preinstall
// 153:
// 154:           puts "Installing #{name} VSCode extension. It is not currently installed." if verbose
// 155:           return false unless install_package!(name, verbose:)
// 156:
// 157:           package = T.cast(package_record(name), String)
// 158:           installed_extensions << package unless installed_extensions.include?(package)
// 159:           if @extensions
// 160:             @extensions << package unless @extensions.include?(package)
// 161:           else
// 162:             @extensions = [package]
// 163:           end
// 164:
// 165:           true
// 166:         end
// 167:
// 168:         sig { params(entries: T::Array[Object]).returns(T::Array[String]) }
// 169:         def cleanup_items(entries)
// 170:           kept_extensions = entries.filter_map do |entry|
// 171:             entry = T.cast(entry, Dsl::Entry)
// 172:             entry.name.downcase if entry.type == type
// 173:           end
// 174:
// 175:           return [].freeze if kept_extensions.empty?
// 176:
// 177:           packages - kept_extensions
// 178:         end
// 179:
// 180:         sig { params(extensions: T::Array[String]).void }
// 181:         def cleanup!(extensions)
// 182:           vscode = package_manager_executable
// 183:           return if vscode.nil?
// 184:
// 185:           Bundle.exchange_uid_if_needed! do
// 186:             extensions.each do |extension|
// 187:               Kernel.system(vscode.to_s, "--uninstall-extension", extension)
// 188:             end
// 189:           end
// 190:         end
// 191:       end
// 192:     end
// 193:   end
// 194: end
