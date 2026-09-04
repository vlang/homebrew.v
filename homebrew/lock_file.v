module homebrew

import ruby
import os
import os.filelock

// Translated from Homebrew/brew `lock_file.rb`.
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

pub type LockFileAction = fn () !ruby.Value

fn configured_locks_directory() string {
	configured := ruby.environment_value('HOMEBREW_LOCKS')
	if configured != '' {
		return configured
	}
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
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

pub fn (mut lock_file LockFile) with_lock(action LockFileAction) !ruby.Value {
	lock_file.lock()!
	defer {
		lock_file.unlock(false) or {}
	}
	return action()
}
