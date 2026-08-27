module cask

import brew_runtime

// Translated from Homebrew/brew `cask/pkg.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.all_matching(regexp, command)` at line 13.
pub fn ruby_pkg_l13_d1_self_all_matching(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.all_matching', ...args)
}

// Ruby attr_reader `attr_reader :package_id` at line 20.
pub fn ruby_pkg_l20_d2_package_id(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('package_id', ...args)
}

// Ruby method `initialize(package_id, command = SystemCommand)` at line 23.
pub fn ruby_pkg_l23_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `uninstall` at line 29.
pub fn ruby_pkg_l29_d4_uninstall(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall', ...args)
}

// Ruby method `forget` at line 63.
pub fn ruby_pkg_l63_d5_forget(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('forget', ...args)
}

// Ruby method `pkgutil_bom_files` at line 74.
pub fn ruby_pkg_l74_d6_pkgutil_bom_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkgutil_bom_files', ...args)
}

// Ruby method `pkgutil_bom_specials` at line 80.
pub fn ruby_pkg_l80_d7_pkgutil_bom_specials(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkgutil_bom_specials', ...args)
}

// Ruby method `pkgutil_bom_dirs` at line 85.
pub fn ruby_pkg_l85_d8_pkgutil_bom_dirs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkgutil_bom_dirs', ...args)
}

// Ruby method `pkgutil_bom_all` at line 91.
pub fn ruby_pkg_l91_d9_pkgutil_bom_all(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkgutil_bom_all', ...args)
}

// Ruby method `root` at line 103.
pub fn ruby_pkg_l103_d10_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('root', ...args)
}

// Ruby method `info` at line 108.
pub fn ruby_pkg_l108_d11_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('info', ...args)
}

// Ruby method `special?(path)` at line 115.
pub fn ruby_pkg_l115_d12_special(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('special?', ...args)
}

// Ruby method `rmdir(path)` at line 125.
pub fn ruby_pkg_l125_d13_rmdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rmdir', ...args)
}

// Ruby method `deepest_path_first(paths)` at line 136.
pub fn ruby_pkg_l136_d14_deepest_path_first(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deepest_path_first', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/macos"
// 5: require "utils/output"
// 6:
// 7: module Cask
// 8:   # Helper class for uninstalling `.pkg` installers.
// 9:   class Pkg
// 10:     include ::Utils::Output::Mixin
// 11:
// 12:     sig { params(regexp: String, command: T.class_of(SystemCommand)).returns(T::Array[Pkg]) }
// 13:     def self.all_matching(regexp, command)
// 14:       command.run("/usr/sbin/pkgutil", args: ["--pkgs=#{regexp}"]).stdout.split("\n").map do |package_id|
// 15:         new(package_id.chomp, command)
// 16:       end
// 17:     end
// 18:
// 19:     sig { returns(String) }
// 20:     attr_reader :package_id
// 21:
// 22:     sig { params(package_id: String, command: T.class_of(SystemCommand)).void }
// 23:     def initialize(package_id, command = SystemCommand)
// 24:       @package_id = package_id
// 25:       @command = command
// 26:     end
// 27:
// 28:     sig { void }
// 29:     def uninstall
// 30:       unless pkgutil_bom_files.empty?
// 31:         odebug "Deleting pkg files"
// 32:         @command.run!(
// 33:           "/usr/bin/xargs",
// 34:           args:         ["-0", "--", "/bin/rm", "--"],
// 35:           input:        pkgutil_bom_files.join("\0"),
// 36:           sudo:         true,
// 37:           sudo_as_root: true,
// 38:         )
// 39:       end
// 40:
// 41:       unless pkgutil_bom_specials.empty?
// 42:         odebug "Deleting pkg symlinks and special files"
// 43:         @command.run!(
// 44:           "/usr/bin/xargs",
// 45:           args:         ["-0", "--", "/bin/rm", "--"],
// 46:           input:        pkgutil_bom_specials.join("\0"),
// 47:           sudo:         true,
// 48:           sudo_as_root: true,
// 49:         )
// 50:       end
// 51:
// 52:       unless pkgutil_bom_dirs.empty?
// 53:         odebug "Deleting pkg directories"
// 54:         rmdir(deepest_path_first(pkgutil_bom_dirs))
// 55:       end
// 56:
// 57:       rmdir(root) unless MacOS.undeletable?(root)
// 58:
// 59:       forget
// 60:     end
// 61:
// 62:     sig { void }
// 63:     def forget
// 64:       odebug "Unregistering pkg receipt (aka forgetting)"
// 65:       @command.run!(
// 66:         "/usr/sbin/pkgutil",
// 67:         args:         ["--forget", package_id],
// 68:         sudo:         true,
// 69:         sudo_as_root: true,
// 70:       )
// 71:     end
// 72:
// 73:     sig { returns(T::Array[Pathname]) }
// 74:     def pkgutil_bom_files
// 75:       @pkgutil_bom_files ||= T.let(pkgutil_bom_all.select(&:file?) - pkgutil_bom_specials,
// 76:                                    T.nilable(T::Array[Pathname]))
// 77:     end
// 78:
// 79:     sig { returns(T::Array[Pathname]) }
// 80:     def pkgutil_bom_specials
// 81:       @pkgutil_bom_specials ||= T.let(pkgutil_bom_all.select { special?(it) }, T.nilable(T::Array[Pathname]))
// 82:     end
// 83:
// 84:     sig { returns(T::Array[Pathname]) }
// 85:     def pkgutil_bom_dirs
// 86:       @pkgutil_bom_dirs ||= T.let(pkgutil_bom_all.select(&:directory?) - pkgutil_bom_specials,
// 87:                                   T.nilable(T::Array[Pathname]))
// 88:     end
// 89:
// 90:     sig { returns(T::Array[Pathname]) }
// 91:     def pkgutil_bom_all
// 92:       @pkgutil_bom_all ||= T.let(
// 93:         @command.run!("/usr/sbin/pkgutil", args: ["--files", package_id])
// 94:                 .stdout
// 95:                 .split("\n")
// 96:                 .map { |path| root.join(path) }
// 97:                 .reject { |path| MacOS.undeletable?(path) },
// 98:         T.nilable(T::Array[Pathname]),
// 99:       )
// 100:     end
// 101:
// 102:     sig { returns(Pathname) }
// 103:     def root
// 104:       @root ||= T.let(Pathname.new(info.fetch("volume")).join(info.fetch("install-location")), T.nilable(Pathname))
// 105:     end
// 106:
// 107:     sig { returns(T.untyped) }
// 108:     def info
// 109:       @info ||= T.let(@command.run!("/usr/sbin/pkgutil", args: ["--pkg-info-plist", package_id]).plist, T.untyped)
// 110:     end
// 111:
// 112:     private
// 113:
// 114:     sig { params(path: Pathname).returns(T::Boolean) }
// 115:     def special?(path)
// 116:       path.symlink? || path.chardev? || path.blockdev?
// 117:     end
// 118:
// 119:     # Helper script to delete empty directories after deleting `.DS_Store` files and broken symlinks.
// 120:     # Needed in order to execute all file operations with `sudo`.
// 121:     RMDIR_SH = T.let((HOMEBREW_LIBRARY_PATH/"cask/utils/rmdir.sh").freeze, Pathname)
// 122:     private_constant :RMDIR_SH
// 123:
// 124:     sig { params(path: T.any(Pathname, T::Array[Pathname])).void }
// 125:     def rmdir(path)
// 126:       @command.run!(
// 127:         "/usr/bin/xargs",
// 128:         args:         ["-0", "--", RMDIR_SH.to_s],
// 129:         input:        Array(path).join("\0"),
// 130:         sudo:         true,
// 131:         sudo_as_root: true,
// 132:       )
// 133:     end
// 134:
// 135:     sig { params(paths: T::Array[Pathname]).returns(T::Array[Pathname]) }
// 136:     def deepest_path_first(paths)
// 137:       paths.sort_by { |path| -path.to_s.split(File::SEPARATOR).count }
// 138:     end
// 139:   end
// 140: end
