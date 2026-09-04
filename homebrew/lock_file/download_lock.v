module lock_file

import homebrew
import math
import time

// Translated from Homebrew/brew `lock_file/download_lock.rb`.
pub const download_lock_max_wait_seconds = 180.0

pub type DownloadLockClock = fn () i64

pub type DownloadLockSleeper = fn (seconds f64, failed_attempt int)

pub type DownloadLockWarner = fn (message string)

pub struct DownloadLockWaitOptions {
pub:
	quiet            bool
	timeout_seconds  ?f64
	max_wait_seconds f64 = download_lock_max_wait_seconds
	retry_seconds    f64 = 0.1
	clock            DownloadLockClock = download_lock_clock
	sleeper          DownloadLockSleeper = download_lock_sleep
	warner           DownloadLockWarner = download_lock_warn
}

pub struct DownloadLockWaitResult {
pub:
	attempts         int
	failed_attempts  int
	waited_seconds   f64
	warning_messages []string
}

pub struct DownloadLock {
pub:
	download_path string
pub mut:
	lock_file homebrew.LockFile
}

fn download_lock_clock() i64 {
	return time.now().unix_micro() / 1000
}

fn download_lock_sleep(seconds f64, _failed_attempt int) {
	time.sleep(time.Duration(i64(seconds * f64(time.second))))
}

fn download_lock_warn(message string) {
	eprintln('Warning: ${message}')
}

pub fn download_lock_ignore_warning(_message string) {}

pub fn new_download_lock(download_path string, locks_directory string) DownloadLock {
	return DownloadLock{
		download_path: download_path
		lock_file: homebrew.new_lock_file('download', download_path, locks_directory)
	}
}

pub fn (download_lock DownloadLock) path() string {
	return download_lock.lock_file.path
}

pub fn (download_lock DownloadLock) locked_path() string {
	return download_lock.lock_file.locked_path
}

pub fn (mut download_lock DownloadLock) lock() ! {
	download_lock.lock_file.lock()!
}

pub fn (mut download_lock DownloadLock) unlock(unlink bool) ! {
	download_lock.lock_file.unlock(unlink)!
}

pub fn (mut download_lock DownloadLock) lock_or_wait(options DownloadLockWaitOptions) !DownloadLockWaitResult {
	mut max_wait := options.max_wait_seconds
	if timeout := options.timeout_seconds {
		if timeout < max_wait {
			max_wait = timeout
		}
	}
	mut attempts := 0
	mut failed_attempts := 0
	mut waiting_since := i64(0)
	mut waiting := false
	mut warning_messages := []string{}
	for {
		attempts++
		download_lock.lock() or {
			if err.code() != homebrew.lock_contention_error_code {
				return err
			}
			failed_attempts++
			if !waiting {
				waiting = true
				waiting_since = options.clock()
				if !options.quiet {
					message := 'Waiting for another Homebrew process to finish downloading ${download_lock.locked_path()}...'
					warning_messages << message
					options.warner(message)
				}
			}
			waited := f64(options.clock() - waiting_since) / 1000.0
			if waited >= max_wait {
				return homebrew.LockOperationInProgressError{
					locked_path: download_lock.locked_path()
					waited: int(math.round(waited))
				}
			}
			options.sleeper(options.retry_seconds, failed_attempts)
			continue
		}
		waited := if !waiting {
			0.0
		} else {
			f64(options.clock() - waiting_since) / 1000.0
		}
		return DownloadLockWaitResult{
			attempts: attempts
			failed_attempts: failed_attempts
			waited_seconds: waited
			warning_messages: warning_messages
		}
	}
	return error('unreachable download lock wait state')
}
