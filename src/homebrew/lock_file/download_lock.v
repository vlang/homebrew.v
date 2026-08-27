module lock_file

import brew_runtime

// Translated from Homebrew/brew `lock_file/download_lock.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(download_path)` at line 9.
pub fn ruby_download_lock_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `lock_or_wait(quiet: false, timeout: nil)` at line 17.
pub fn ruby_download_lock_l17_d2_lock_or_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lock_or_wait', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A lock file for a download.
// 5: class DownloadLock < LockFile
// 6:   MAX_WAIT_SECONDS = 180
// 7:
// 8:   sig { params(download_path: Pathname).void }
// 9:   def initialize(download_path)
// 10:     super(:download, download_path)
// 11:   end
// 12:
// 13:   # Waits for another process's download to finish instead of failing immediately.
// 14:   # `quiet:` suppresses the warning when the caller is already rendering its own
// 15:   # progress, since an unscheduled write desyncs `DownloadQueue`'s redraw.
// 16:   sig { params(quiet: T::Boolean, timeout: T.nilable(T.any(Integer, Float))).void }
// 17:   def lock_or_wait(quiet: false, timeout: nil)
// 18:     max_wait = MAX_WAIT_SECONDS
// 19:     max_wait = timeout if timeout && timeout < max_wait
// 20:     waiting_since = T.let(nil, T.nilable(Time))
// 21:     begin
// 22:       lock
// 23:     rescue OperationInProgressError
// 24:       if waiting_since.nil?
// 25:         waiting_since = Time.now
// 26:         opoo "Waiting for another Homebrew process to finish downloading #{locked_path}..." unless quiet
// 27:       end
// 28:
// 29:       waited = Time.now - waiting_since
// 30:       raise OperationInProgressError.new(locked_path, waited: waited.round) if waited >= max_wait
// 31:
// 32:       sleep 0.1
// 33:       retry
// 34:     end
// 35:   end
// 36: end
