module cask

import brew_runtime

// Translated from Homebrew/brew `cask/utils.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.privacy_security_preference_pane(access)` at line 17.
pub fn ruby_utils_l17_d1_self_privacy_security_preference_pane(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.privacy_security_preference_pane', ...args)
}

// Ruby method `self.full_disk_access_enabled?` at line 28.
pub fn ruby_utils_l28_d2_self_full_disk_access_enabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.full_disk_access_enabled?', ...args)
}

// Ruby method `self.gain_permissions_mkpath(path, command: SystemCommand)` at line 33.
pub fn ruby_utils_l33_d3_self_gain_permissions_mkpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gain_permissions_mkpath', ...args)
}

// Ruby method `self.gain_permissions_rmdir(path, command: SystemCommand)` at line 45.
pub fn ruby_utils_l45_d4_self_gain_permissions_rmdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gain_permissions_rmdir', ...args)
}

// Ruby method `self.gain_permissions_remove(path, command: SystemCommand)` at line 56.
pub fn ruby_utils_l56_d5_self_gain_permissions_remove(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gain_permissions_remove', ...args)
}

// Ruby method `self.gain_permissions(path, command_args, command, &_block)` at line 92.
pub fn ruby_utils_l92_d6_self_gain_permissions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gain_permissions', ...args)
}

// Ruby method `self.path_occupied?(path)` at line 137.
pub fn ruby_utils_l137_d7_self_path_occupied(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.path_occupied?', ...args)
}

// Ruby method `self.token_from(name)` at line 142.
pub fn ruby_utils_l142_d8_self_token_from(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.token_from', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/user"
// 5: require "open3"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   # Helper functions for various cask operations.
// 10:   module Utils
// 11:     extend ::Utils::Output::Mixin
// 12:
// 13:     BUG_REPORTS_URL = "https://github.com/Homebrew/homebrew-cask#reporting-bugs"
// 14:     FULL_DISK_ACCESS_TCC_PATH = "~/Library/Application Support/com.apple.TCC"
// 15:
// 16:     sig { params(access: String).returns(String) }
// 17:     def self.privacy_security_preference_pane(access)
// 18:       navigation_path = if MacOS.version >= :ventura
// 19:         "System Settings → Privacy & Security"
// 20:       else
// 21:         "System Preferences → Security & Privacy → Privacy"
// 22:       end
// 23:
// 24:       "#{navigation_path} → #{access}"
// 25:     end
// 26:
// 27:     sig { returns(T::Boolean) }
// 28:     def self.full_disk_access_enabled?
// 29:       File.readable?(File.expand_path(FULL_DISK_ACCESS_TCC_PATH))
// 30:     end
// 31:
// 32:     sig { params(path: Pathname, command: T.class_of(SystemCommand)).void }
// 33:     def self.gain_permissions_mkpath(path, command: SystemCommand)
// 34:       dir = path.ascend.find(&:directory?)
// 35:       return if path == dir
// 36:
// 37:       if dir&.writable?
// 38:         path.mkpath
// 39:       else
// 40:         command.run!("mkdir", args: ["-p", "--", path], sudo: true, print_stderr: false)
// 41:       end
// 42:     end
// 43:
// 44:     sig { params(path: Pathname, command: T.class_of(SystemCommand)).void }
// 45:     def self.gain_permissions_rmdir(path, command: SystemCommand)
// 46:       gain_permissions(path, [], command) do |p|
// 47:         if p.parent.writable?
// 48:           FileUtils.rmdir p
// 49:         else
// 50:           command.run!("rmdir", args: ["--", p], sudo: true, print_stderr: false)
// 51:         end
// 52:       end
// 53:     end
// 54:
// 55:     sig { params(path: Pathname, command: T.class_of(SystemCommand)).void }
// 56:     def self.gain_permissions_remove(path, command: SystemCommand)
// 57:       directory = false
// 58:       permission_flags = if path.symlink?
// 59:         ["-h"]
// 60:       elsif path.directory?
// 61:         directory = true
// 62:         ["-R"]
// 63:       elsif path.exist?
// 64:         []
// 65:       else
// 66:         # Nothing to remove.
// 67:         return
// 68:       end
// 69:
// 70:       gain_permissions(path, permission_flags, command) do |p|
// 71:         if p.parent.writable?
// 72:           if directory
// 73:             FileUtils.rm_r p
// 74:           else
// 75:             FileUtils.rm_f p
// 76:           end
// 77:         else
// 78:           recursive_flag = directory ? ["-R"] : []
// 79:           command.run!("/bin/rm", args: recursive_flag + ["-f", "--", p], sudo: true, print_stderr: false)
// 80:         end
// 81:       end
// 82:     end
// 83:
// 84:     sig {
// 85:       params(
// 86:         path:         Pathname,
// 87:         command_args: T::Array[String],
// 88:         command:      T.class_of(SystemCommand),
// 89:         _block:       T.proc.params(path: Pathname).void,
// 90:       ).void
// 91:     }
// 92:     def self.gain_permissions(path, command_args, command, &_block)
// 93:       tried_permissions = false
// 94:       tried_ownership = false
// 95:       begin
// 96:         yield path
// 97:       rescue
// 98:         # in case of permissions problems
// 99:         unless tried_permissions
// 100:           print_stderr = Context.current.debug? || Context.current.verbose?
// 101:           # TODO: Better handling for the case where path is a symlink.
// 102:           #       The `-h` and `-R` flags cannot be combined and behavior is
// 103:           #       dependent on whether the file argument has a trailing
// 104:           #       slash. This should do the right thing, but is fragile.
// 105:           command.run("/usr/bin/chflags",
// 106:                       print_stderr:,
// 107:                       args:         command_args + ["--", "000", path])
// 108:           command.run("chmod",
// 109:                       print_stderr:,
// 110:                       args:         command_args + ["--", "u+rwx", path])
// 111:           command.run("chmod",
// 112:                       print_stderr:,
// 113:                       args:         command_args + ["-N", path])
// 114:           tried_permissions = true
// 115:           retry # rmtree
// 116:         end
// 117:
// 118:         unless tried_ownership
// 119:           # in case of ownership problems
// 120:           # TODO: Further examine files to see if ownership is the problem
// 121:           #       before using `sudo` and `chown`.
// 122:           ohai "Using sudo to gain ownership of path '#{path}'"
// 123:           command.run("chown",
// 124:                       args: command_args + ["--", User.current.to_s, path],
// 125:                       sudo: true)
// 126:           tried_ownership = true
// 127:           # retry chflags/chmod after chown
// 128:           tried_permissions = false
// 129:           retry # rmtree
// 130:         end
// 131:
// 132:         raise
// 133:       end
// 134:     end
// 135:
// 136:     sig { params(path: Pathname).returns(T::Boolean) }
// 137:     def self.path_occupied?(path)
// 138:       path.exist? || path.symlink?
// 139:     end
// 140:
// 141:     sig { params(name: String).returns(String) }
// 142:     def self.token_from(name)
// 143:       name.downcase
// 144:           .gsub("+", "-plus-")
// 145:           .gsub(/[ _·•]/, "-")
// 146:           .gsub(/[^\w@-]/, "")
// 147:           .gsub(/--+/, "-")
// 148:           .delete_prefix("-")
// 149:           .delete_suffix("-")
// 150:     end
// 151:   end
// 152: end
