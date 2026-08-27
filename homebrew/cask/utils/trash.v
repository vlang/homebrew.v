module utils

import brew_runtime

// Translated from Homebrew/brew `cask/utils/trash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.trash(*paths, command: nil)` at line 18.
pub fn ruby_trash_l18_d1_self_trash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trash', ...args)
}

// Ruby method `self.freedesktop_trash(*paths)` at line 23.
pub fn ruby_trash_l23_d2_self_freedesktop_trash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.freedesktop_trash', ...args)
}

// Ruby method `self.home_trash_path` at line 43.
pub fn ruby_trash_l43_d3_self_home_trash_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.home_trash_path', ...args)
}

// Ruby method `self.trash_path(path, files_path:, info_path:)` at line 49.
pub fn ruby_trash_l49_d4_self_trash_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.trash_path', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/utils"
// 5: require "fileutils"
// 6: require "system_command"
// 7: require "uri"
// 8:
// 9: module Cask
// 10:   module Utils
// 11:     module Trash
// 12:       extend SystemCommand::Mixin
// 13:
// 14:       sig {
// 15:         params(paths: Pathname, command: T.nilable(T.class_of(SystemCommand)))
// 16:           .returns([T::Array[String], T::Array[String]])
// 17:       }
// 18:       def self.trash(*paths, command: nil)
// 19:         freedesktop_trash(*paths)
// 20:       end
// 21:
// 22:       sig { params(paths: Pathname).returns([T::Array[String], T::Array[String]]) }
// 23:       def self.freedesktop_trash(*paths)
// 24:         return [[], []] if paths.empty?
// 25:
// 26:         files_path = home_trash_path/"files"
// 27:         info_path = home_trash_path/"info"
// 28:
// 29:         files_path.mkpath
// 30:         info_path.mkpath
// 31:
// 32:         trashed, untrashable = paths.partition do |path|
// 33:           trash_path(path, files_path:, info_path:)
// 34:           true
// 35:         rescue
// 36:           false
// 37:         end
// 38:
// 39:         [trashed.map(&:to_s), untrashable.map(&:to_s)]
// 40:       end
// 41:
// 42:       sig { returns(Pathname) }
// 43:       def self.home_trash_path
// 44:         Pathname.new(ENV["XDG_DATA_HOME"].presence || "#{Dir.home}/.local/share")/"Trash"
// 45:       end
// 46:       private_class_method :home_trash_path
// 47:
// 48:       sig { params(path: Pathname, files_path: Pathname, info_path: Pathname).void }
// 49:       def self.trash_path(path, files_path:, info_path:)
// 50:         basename = path.basename.to_s
// 51:         deletion_date = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
// 52:         suffix = 0
// 53:
// 54:         Kernel.loop do
// 55:           candidate = suffix.zero? ? basename : "#{basename}.#{suffix}"
// 56:           target_path = files_path/candidate
// 57:           target_info_path = info_path/"#{candidate}.trashinfo"
// 58:
// 59:           if target_path.exist? || target_path.symlink?
// 60:             suffix += 1
// 61:             next
// 62:           end
// 63:
// 64:           begin
// 65:             File.open(target_info_path, File::WRONLY | File::CREAT | File::EXCL, 0600) do |file|
// 66:               file.write <<~EOS
// 67:                 [Trash Info]
// 68:                 Path=#{URI::DEFAULT_PARSER.escape(path.to_s)}
// 69:                 DeletionDate=#{deletion_date}
// 70:               EOS
// 71:             end
// 72:           rescue Errno::EEXIST
// 73:             suffix += 1
// 74:             next
// 75:           end
// 76:
// 77:           begin
// 78:             FileUtils.mv(path, target_path)
// 79:           rescue
// 80:             target_info_path.delete if target_info_path.exist?
// 81:             Kernel.raise
// 82:           end
// 83:
// 84:           return
// 85:         end
// 86:       end
// 87:       private_class_method :trash_path
// 88:     end
// 89:   end
// 90: end
// 91:
// 92: require "extend/os/cask/utils/trash"
