module utils

import brew_runtime

// Translated from Homebrew/brew `utils/path.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.child_of?(parent, child)` at line 10.
pub fn ruby_path_l10_d1_self_child_of(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.child_of?', ...args)
}

// Ruby method `self.ensure_child_of!(parent, child, message:)` at line 18.
pub fn ruby_path_l18_d2_self_ensure_child_of(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ensure_child_of!', ...args)
}

// Ruby method `self.formula_opt_prefix(formula_name)` at line 28.
pub fn ruby_path_l28_d3_self_formula_opt_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_opt_prefix', ...args)
}

// Ruby method `formula_opt_prefix(formula_name)` at line 36.
pub fn ruby_path_l36_d4_formula_opt_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_opt_prefix', ...args)
}

// Ruby method `self.formula_opt_bin(formula_name)` at line 44.
pub fn ruby_path_l44_d5_self_formula_opt_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_opt_bin', ...args)
}

// Ruby method `formula_opt_bin(formula_name)` at line 52.
pub fn ruby_path_l52_d6_formula_opt_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_opt_bin', ...args)
}

// Ruby method `self.formula_opt_lib(formula_name)` at line 60.
pub fn ruby_path_l60_d7_self_formula_opt_lib(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_opt_lib', ...args)
}

// Ruby method `formula_opt_lib(formula_name)` at line 68.
pub fn ruby_path_l68_d8_formula_opt_lib(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_opt_lib', ...args)
}

// Ruby method `self.formula_opt_libexec(formula_name)` at line 76.
pub fn ruby_path_l76_d9_self_formula_opt_libexec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_opt_libexec', ...args)
}

// Ruby method `formula_opt_libexec(formula_name)` at line 84.
pub fn ruby_path_l84_d10_formula_opt_libexec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_opt_libexec', ...args)
}

// Ruby method `self.formula_opt_include(formula_name)` at line 92.
pub fn ruby_path_l92_d11_self_formula_opt_include(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_opt_include', ...args)
}

// Ruby method `formula_opt_include(formula_name)` at line 100.
pub fn ruby_path_l100_d12_formula_opt_include(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_opt_include', ...args)
}

// Ruby method `self.formula_installed_prefixes(formula_names)` at line 108.
pub fn ruby_path_l108_d13_self_formula_installed_prefixes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_installed_prefixes', ...args)
}

// Ruby method `self.formula_any_version_installed?(formula_names)` at line 120.
pub fn ruby_path_l120_d14_self_formula_any_version_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_any_version_installed?', ...args)
}

// Ruby method `formula_any_version_installed?(formula_names)` at line 128.
pub fn ruby_path_l128_d15_formula_any_version_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_any_version_installed?', ...args)
}

// Ruby method `self.formula_opt_bin_path(formula_name, *paths)` at line 136.
pub fn ruby_path_l136_d16_self_formula_opt_bin_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_opt_bin_path', ...args)
}

// Ruby method `self.formula_opt_bin_env(formula_name, *paths)` at line 144.
pub fn ruby_path_l144_d17_self_formula_opt_bin_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_opt_bin_env', ...args)
}

// Ruby method `self.loadable_package_path?(path, package_type)` at line 149.
pub fn ruby_path_l149_d18_self_loadable_package_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.loadable_package_path?', ...args)
}

// Ruby method `self.trusted_package_root(path)` at line 192.
pub fn ruby_path_l192_d19_self_trusted_package_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trusted_package_root', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils"
// 5:
// 6: module Utils
// 7:   # Helpers for Homebrew path handling and package path validation.
// 8:   module Path
// 9:     sig { params(parent: T.any(Pathname, String), child: T.any(Pathname, String)).returns(T::Boolean) }
// 10:     def self.child_of?(parent, child)
// 11:       parent_pathname = Pathname(parent).expand_path
// 12:       child_pathname = Pathname(child).expand_path
// 13:       child_pathname.ascend { |p| return true if p == parent_pathname }
// 14:       false
// 15:     end
// 16:
// 17:     sig { params(parent: T.any(Pathname, String), child: T.any(Pathname, String), message: String).void }
// 18:     def self.ensure_child_of!(parent, child, message:)
// 19:       return if child_of?(parent, child)
// 20:
// 21:       raise message
// 22:     end
// 23:
// 24:     # The stable install path for a given formula name.
// 25:     #
// 26:     # @api public
// 27:     sig { params(formula_name: String).returns(Pathname) }
// 28:     def self.formula_opt_prefix(formula_name)
// 29:       HOMEBREW_PREFIX/"opt/#{Utils.name_from_full_name(formula_name)}"
// 30:     end
// 31:
// 32:     # The stable install path for a given formula name.
// 33:     #
// 34:     # @api public
// 35:     sig { params(formula_name: String).returns(Pathname) }
// 36:     def formula_opt_prefix(formula_name)
// 37:       Utils::Path.formula_opt_prefix(formula_name)
// 38:     end
// 39:
// 40:     # The `bin` directory under the stable install path for a given formula name.
// 41:     #
// 42:     # @api public
// 43:     sig { params(formula_name: String).returns(Pathname) }
// 44:     def self.formula_opt_bin(formula_name)
// 45:       formula_opt_prefix(formula_name)/"bin"
// 46:     end
// 47:
// 48:     # The `bin` directory under the stable install path for a given formula name.
// 49:     #
// 50:     # @api public
// 51:     sig { params(formula_name: String).returns(Pathname) }
// 52:     def formula_opt_bin(formula_name)
// 53:       Utils::Path.formula_opt_bin(formula_name)
// 54:     end
// 55:
// 56:     # The `lib` directory under the stable install path for a given formula name.
// 57:     #
// 58:     # @api public
// 59:     sig { params(formula_name: String).returns(Pathname) }
// 60:     def self.formula_opt_lib(formula_name)
// 61:       formula_opt_prefix(formula_name)/"lib"
// 62:     end
// 63:
// 64:     # The `lib` directory under the stable install path for a given formula name.
// 65:     #
// 66:     # @api public
// 67:     sig { params(formula_name: String).returns(Pathname) }
// 68:     def formula_opt_lib(formula_name)
// 69:       Utils::Path.formula_opt_lib(formula_name)
// 70:     end
// 71:
// 72:     # The `libexec` directory under the stable install path for a given formula name.
// 73:     #
// 74:     # @api public
// 75:     sig { params(formula_name: String).returns(Pathname) }
// 76:     def self.formula_opt_libexec(formula_name)
// 77:       formula_opt_prefix(formula_name)/"libexec"
// 78:     end
// 79:
// 80:     # The `libexec` directory under the stable install path for a given formula name.
// 81:     #
// 82:     # @api public
// 83:     sig { params(formula_name: String).returns(Pathname) }
// 84:     def formula_opt_libexec(formula_name)
// 85:       Utils::Path.formula_opt_libexec(formula_name)
// 86:     end
// 87:
// 88:     # The `include` directory under the stable install path for a given formula name.
// 89:     #
// 90:     # @api public
// 91:     sig { params(formula_name: String).returns(Pathname) }
// 92:     def self.formula_opt_include(formula_name)
// 93:       formula_opt_prefix(formula_name)/"include"
// 94:     end
// 95:
// 96:     # The `include` directory under the stable install path for a given formula name.
// 97:     #
// 98:     # @api public
// 99:     sig { params(formula_name: String).returns(Pathname) }
// 100:     def formula_opt_include(formula_name)
// 101:       Utils::Path.formula_opt_include(formula_name)
// 102:     end
// 103:
// 104:     # The installed prefix directories for one or more formula names.
// 105:     #
// 106:     # @api public
// 107:     sig { params(formula_names: T.any(String, T::Array[String])).returns(T::Array[Pathname]) }
// 108:     def self.formula_installed_prefixes(formula_names)
// 109:       Array(formula_names).map { |formula_name| HOMEBREW_CELLAR/Utils.name_from_full_name(formula_name) }
// 110:                           .select(&:directory?)
// 111:                           .uniq(&:realpath)
// 112:                           .flat_map(&:subdirs)
// 113:                           .sort_by(&:basename)
// 114:     end
// 115:
// 116:     # Whether any installed keg for one or more formula names has an install receipt.
// 117:     #
// 118:     # @api public
// 119:     sig { params(formula_names: T.any(String, T::Array[String])).returns(T::Boolean) }
// 120:     def self.formula_any_version_installed?(formula_names)
// 121:       formula_installed_prefixes(formula_names).any? { |keg| (keg/"INSTALL_RECEIPT.json").file? }
// 122:     end
// 123:
// 124:     # Whether any installed keg for one or more formula names has an install receipt.
// 125:     #
// 126:     # @api public
// 127:     sig { params(formula_names: T.any(String, T::Array[String])).returns(T::Boolean) }
// 128:     def formula_any_version_installed?(formula_names)
// 129:       Utils::Path.formula_any_version_installed?(formula_names)
// 130:     end
// 131:
// 132:     # The current `PATH` with a formula's stable `bin` directory prepended.
// 133:     #
// 134:     # @api public
// 135:     sig { params(formula_name: String, paths: PATH::Elements).returns(PATH) }
// 136:     def self.formula_opt_bin_path(formula_name, *paths)
// 137:       PATH.new(formula_opt_bin(formula_name), *paths, ENV.fetch("PATH"))
// 138:     end
// 139:
// 140:     # An environment hash with `PATH` prepended by a formula's stable `bin` directory.
// 141:     #
// 142:     # @api public
// 143:     sig { params(formula_name: String, paths: PATH::Elements).returns(T::Hash[String, String]) }
// 144:     def self.formula_opt_bin_env(formula_name, *paths)
// 145:       { "PATH" => formula_opt_bin_path(formula_name, *paths).to_s }
// 146:     end
// 147:
// 148:     sig { params(path: Pathname, package_type: Symbol).returns(T::Boolean) }
// 149:     def self.loadable_package_path?(path, package_type)
// 150:       return true unless Homebrew::EnvConfig.forbid_packages_from_paths?
// 151:
// 152:       path_realpath = path.realpath.to_s
// 153:       path_string = path.to_s
// 154:
// 155:       allowed_paths = [trusted_package_root("#{HOMEBREW_LIBRARY}/Taps/")]
// 156:       allowed_paths << if package_type == :formula
// 157:         trusted_package_root(HOMEBREW_CELLAR)
// 158:       else
// 159:         trusted_package_root(Cask::Caskroom.path)
// 160:       end
// 161:
// 162:       # Casks can also be loaded from local JSON files, not just Ruby.
// 163:       package_extnames = (package_type == :cask) ? %w[.rb .json] : %w[.rb]
// 164:       return true if package_extnames.none? { |ext| path_realpath.end_with?(ext) || path_string.end_with?(ext) }
// 165:
// 166:       # Compare path ancestry, not string prefixes, so `..` can't escape a trusted root.
// 167:       return true if allowed_paths.any? { |root| child_of?(root, path_realpath) }
// 168:       return true if allowed_paths.any? { |root| child_of?(root, path) }
// 169:
// 170:       # Looks like a local path, Ruby file and not a tap.
// 171:       if path_string.include?("./") || path_string.end_with?(".rb") || path_string.count("/") != 2
// 172:         package_type_plural = Utils.pluralize(package_type.to_s, 2)
// 173:         path_realpath_if_different = " (#{path_realpath})" if path_realpath != path_string
// 174:         create_flag = " --cask" if package_type == :cask
// 175:
// 176:         raise <<~WARNING
// 177:           Homebrew requires #{package_type_plural} to be in a tap, rejecting:
// 178:             #{path_string}#{path_realpath_if_different}
// 179:
// 180:           To create a tap, run e.g.
// 181:             brew tap-new <user|org>/<repository>
// 182:           To create a #{package_type} in a tap run e.g.
// 183:             brew create#{create_flag} <url> --tap=<user|org>/<repository>
// 184:         WARNING
// 185:       else
// 186:         # Looks like a tap, let's quietly reject but not error.
// 187:         path_string.count("/") != 2
// 188:       end
// 189:     end
// 190:
// 191:     sig { params(path: T.any(Pathname, String)).returns(String) }
// 192:     def self.trusted_package_root(path)
// 193:       Pathname(path).realpath.to_s
// 194:     rescue Errno::ENOENT, Errno::EACCES, Errno::ENOTDIR
// 195:       Pathname(path).expand_path.to_s
// 196:     end
// 197:     private_class_method :trusted_package_root
// 198:   end
// 199: end
