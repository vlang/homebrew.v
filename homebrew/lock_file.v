module homebrew

import brew_runtime
import os
import os.filelock

// Translated from Homebrew/brew `lock_file.rb`.
// The original source is retained below until every stub has a typed V body.
pub const lock_contention_error_code = 75

pub struct LockOperationInProgressError {
pub:
	locked_path string
	waited      ?int
}

pub fn (lock_error LockOperationInProgressError) msg() string {
	return operation_in_progress_exception(lock_error.locked_path, lock_error.waited, '', '').message
}

pub fn (lock_error LockOperationInProgressError) code() int {
	return lock_contention_error_code
}

pub struct LockFile {
pub:
	path        string
	locked_path string
pub mut:
	locked bool
mut:
	backend ?filelock.FileLock
}

pub type LockFileAction = fn() !brew_runtime.Value

fn configured_locks_directory() string {
	configured := brew_runtime.environment_value('HOMEBREW_LOCKS')
	if configured != '' {
		return configured
	}
	prefix := brew_runtime.environment_value('HOMEBREW_PREFIX')
	return if prefix == '' {
		os.join_path(os.temp_dir(), 'homebrew-locks')
	} else {
		os.join_path(prefix, 'var', 'homebrew', 'locks')
	}
}

pub fn new_lock_file(lock_type string, locked_path string, locks_directory string) LockFile {
	directory := if locks_directory == '' {
		configured_locks_directory()
	} else {
		locks_directory
	}
	lock_name := os.base(locked_path)
	return LockFile{
		path: os.join_path(directory, '${lock_name}.${lock_type}.lock')
		locked_path: locked_path
	}
}

fn ensure_lock_file_exists(path string) ! {
	os.mkdir_all(os.dir(path))!
	mut handle := os.open_file(path, 'r+') or { os.create(path)! }
	handle.close()
}

pub fn (mut lock_file LockFile) lock() ! {
	if lock_file.locked {
		return
	}
	ensure_lock_file_exists(lock_file.path)!
	mut backend := filelock.new(lock_file.path)
	if !backend.try_acquire() {
		return LockOperationInProgressError{
			locked_path: lock_file.locked_path
		}
	}
	// `filelock.new` uses the platform's nonblocking exclusive flock, including
	// contention between separate instances in this process. Re-checking the
	// pathname closes the unlink/open race before publishing the held backend.
	if !os.exists(lock_file.path) {
		backend.release()
		return lock_file.lock()
	}
	lock_file.backend = backend
	lock_file.locked = true
}

pub fn (mut lock_file LockFile) unlock(unlink bool) ! {
	if !lock_file.locked {
		return
	}
	if mut backend := lock_file.backend {
		if unlink {
			os.rm(lock_file.path) or {}
		}
		backend.release()
	}
	lock_file.backend = none
	lock_file.locked = false
	// V's sidecar flock backend unlinks on release. Ruby keeps ordinary lock
	// files for reuse unless `unlink: true`, so restore the empty inode here.
	if !unlink {
		ensure_lock_file_exists(lock_file.path)!
	}
}

pub fn (mut lock_file LockFile) with_lock(action LockFileAction) !brew_runtime.Value {
	lock_file.lock()!
	defer {
		lock_file.unlock(false) or {}
	}
	return action()
}

// Ruby attr_reader `attr_reader :path` at line 15.
pub fn ruby_lock_file_l15_d1_path(lock_file LockFile) string {
	return lock_file.path
}

// Ruby attr_reader `attr_reader :locked_path` at line 18.
pub fn ruby_lock_file_l18_d2_locked_path(lock_file LockFile) string {
	return lock_file.locked_path
}

// Ruby method `initialize(type, locked_path)` at line 21.
pub fn ruby_lock_file_l21_d3_initialize(lock_type string, locked_path string,
	locks_directory string) LockFile {
	return new_lock_file(lock_type, locked_path, locks_directory)
}

// Ruby method `lock` at line 29.
pub fn ruby_lock_file_l29_d4_lock(mut lock_file LockFile) ! {
	lock_file.lock()!
}

// Ruby method `unlock(unlink: false)` at line 74.
pub fn ruby_lock_file_l74_d5_unlock(mut lock_file LockFile, unlink bool) ! {
	lock_file.unlock(unlink)!
}

// Ruby method `with_lock(&_block)` at line 86.
pub fn ruby_lock_file_l86_d6_with_lock(mut lock_file LockFile,
	action LockFileAction) !brew_runtime.Value {
	return lock_file.with_lock(action)
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
