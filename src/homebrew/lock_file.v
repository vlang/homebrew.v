module homebrew

import brew_runtime

// Translated from Homebrew/brew `lock_file.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :path` at line 15.
pub fn ruby_lock_file_l15_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby attr_reader `attr_reader :locked_path` at line 18.
pub fn ruby_lock_file_l18_d2_locked_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locked_path', ...args)
}

// Ruby method `initialize(type, locked_path)` at line 21.
pub fn ruby_lock_file_l21_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `lock` at line 29.
pub fn ruby_lock_file_l29_d4_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lock', ...args)
}

// Ruby method `unlock(unlink: false)` at line 74.
pub fn ruby_lock_file_l74_d5_unlock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlock', ...args)
}

// Ruby method `with_lock(&_block)` at line 86.
pub fn ruby_lock_file_l86_d6_with_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with_lock', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "fcntl"
// 5: require "utils/output"
// 6:
// 7: # A lock file to prevent multiple Homebrew processes from modifying the same path.
// 8: class LockFile
// 9:   include Utils::Output::Mixin
// 10:
// 11:   class OpenFileChangedOnDisk < RuntimeError; end
// 12:   private_constant :OpenFileChangedOnDisk
// 13:
// 14:   sig { returns(Pathname) }
// 15:   attr_reader :path
// 16:
// 17:   sig { returns(Pathname) }
// 18:   attr_reader :locked_path
// 19:
// 20:   sig { params(type: Symbol, locked_path: Pathname).void }
// 21:   def initialize(type, locked_path)
// 22:     @locked_path = locked_path
// 23:     lock_name = locked_path.basename.to_s
// 24:     @path = T.let(HOMEBREW_LOCKS/"#{lock_name}.#{type}.lock", Pathname)
// 25:     @lockfile = T.let(nil, T.nilable(File))
// 26:   end
// 27:
// 28:   sig { void }
// 29:   def lock
// 30:     ignore_interrupts do
// 31:       next if @lockfile.present?
// 32:
// 33:       path.dirname.mkpath
// 34:
// 35:       begin
// 36:         lockfile = begin
// 37:           File.open(path, File::RDWR | File::CREAT)
// 38:         rescue Errno::EMFILE
// 39:           odie "The maximum number of open files on this system has been reached. " \
// 40:                "Use `ulimit -n` to increase this limit."
// 41:         end
// 42:         lockfile.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
// 43:
// 44:         if lockfile.flock(File::LOCK_EX | File::LOCK_NB)
// 45:           # This prevents a race condition in case the file we locked doesn't exist on disk anymore, e.g.:
// 46:           #
// 47:           # 1. Process A creates and opens the file.
// 48:           # 2. Process A locks the file.
// 49:           # 3. Process B opens the file.
// 50:           # 4. Process A unlinks the file.
// 51:           # 5. Process A unlocks the file.
// 52:           # 6. Process B locks the file.
// 53:           # 7. Process C creates and opens the file.
// 54:           # 8. Process C locks the file.
// 55:           # 9. Process B and C hold locks to files with different inode numbers. 💥
// 56:           if !path.exist? || lockfile.stat.ino != path.stat.ino
// 57:             lockfile.close
// 58:             raise OpenFileChangedOnDisk
// 59:           end
// 60:
// 61:           @lockfile = lockfile
// 62:           next
// 63:         end
// 64:       rescue OpenFileChangedOnDisk
// 65:         retry
// 66:       end
// 67:
// 68:       lockfile.close
// 69:       raise OperationInProgressError, @locked_path
// 70:     end
// 71:   end
// 72:
// 73:   sig { params(unlink: T::Boolean).void }
// 74:   def unlock(unlink: false)
// 75:     ignore_interrupts do
// 76:       next if @lockfile.nil?
// 77:
// 78:       @path.unlink if unlink
// 79:       @lockfile.flock(File::LOCK_UN)
// 80:       @lockfile.close
// 81:       @lockfile = nil
// 82:     end
// 83:   end
// 84:
// 85:   sig { params(_block: T.proc.void).void }
// 86:   def with_lock(&_block)
// 87:     lock
// 88:     yield
// 89:   ensure
// 90:     unlock
// 91:   end
// 92: end
// 93: require "lock_file/formula_lock"
// 94: require "lock_file/cask_lock"
// 95: require "lock_file/download_lock"
