module lock_file

import homebrew
import homebrew.lock_file as lock_api
import os
import time

// Translated from Homebrew/brew `test/lock_file/download_lock_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn download_lock_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-download-lock-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn download_lock_spec_options(sleeper lock_api.DownloadLockSleeper,
	quiet bool) lock_api.DownloadLockWaitOptions {
	return lock_api.DownloadLockWaitOptions{
		quiet: quiet
		sleeper: sleeper
		warner: lock_api.download_lock_ignore_warning
	}
}

fn download_lock_spec_no_sleep(_seconds f64, _attempt int) {}

// Ruby subject `subject(:download_lock) { described_class.new(Pathname("foo-download")) }` at line 7.
pub fn ruby_download_lock_spec_l7_d1_download_lock(locks_directory string) lock_api.DownloadLock {
	return lock_api.new_download_lock('foo-download', locks_directory)
}

// Ruby let `let(:download_lock_copy) { described_class.new(Pathname("foo-download")) }` at line 9.
pub fn ruby_download_lock_spec_l9_d2_download_lock_copy(locks_directory string) lock_api.DownloadLock {
	return lock_api.new_download_lock('foo-download', locks_directory)
}

// Ruby it `it "acquires the lock immediately when uncontended" do` at line 17.
pub fn ruby_download_lock_spec_l17_d3_acquires() bool {
	root := download_lock_spec_root('uncontended')
	defer {
		os.rmdir_all(root) or {}
	}
	mut download_lock := ruby_download_lock_spec_l7_d1_download_lock(root)
	result := download_lock.lock_or_wait(lock_api.DownloadLockWaitOptions{
		warner: lock_api.download_lock_ignore_warning
	}) or { return false }
	defer {
		download_lock.unlock(false) or {}
	}
	return result.attempts == 1 && result.failed_attempts == 0 && download_lock.lock_file.locked
}

// Ruby it `it "waits for another instance's lock to release, then acquires it" do` at line 21.
pub fn ruby_download_lock_spec_l21_d4_waits() bool {
	root := download_lock_spec_root('waits')
	defer {
		os.rmdir_all(root) or {}
	}
	mut download_lock := ruby_download_lock_spec_l7_d1_download_lock(root)
	mut copy := ruby_download_lock_spec_l9_d2_download_lock_copy(root)
	download_lock.lock() or { return false }
	mut holder := &download_lock
	sleeper := fn [mut holder] (_seconds f64, _attempt int) {
		holder.unlock(false) or {}
	}
	result := copy.lock_or_wait(download_lock_spec_options(sleeper, true)) or { return false }
	defer {
		copy.unlock(false) or {}
	}
	return result.failed_attempts == 1 && copy.lock_file.locked
}

// Ruby it `it "retries until the other instance's lock is released" do` at line 28.
pub fn ruby_download_lock_spec_l28_d5_retries() bool {
	root := download_lock_spec_root('retries')
	defer {
		os.rmdir_all(root) or {}
	}
	mut download_lock := ruby_download_lock_spec_l7_d1_download_lock(root)
	mut copy := ruby_download_lock_spec_l9_d2_download_lock_copy(root)
	download_lock.lock() or { return false }
	mut holder := &download_lock
	sleeper := fn [mut holder] (_seconds f64, attempt int) {
		if attempt >= 3 {
			holder.unlock(false) or {}
		}
	}
	result := copy.lock_or_wait(download_lock_spec_options(sleeper, true)) or { return false }
	defer {
		copy.unlock(false) or {}
	}
	return result.failed_attempts == 3 && result.attempts == 4
}

// Ruby it `it "warns only once no matter how many attempts it takes" do` at line 41.
pub fn ruby_download_lock_spec_l41_d6_warns() bool {
	root := download_lock_spec_root('warning')
	defer {
		os.rmdir_all(root) or {}
	}
	mut download_lock := ruby_download_lock_spec_l7_d1_download_lock(root)
	mut copy := ruby_download_lock_spec_l9_d2_download_lock_copy(root)
	download_lock.lock() or { return false }
	mut holder := &download_lock
	sleeper := fn [mut holder] (_seconds f64, attempt int) {
		if attempt >= 3 {
			holder.unlock(false) or {}
		}
	}
	result := copy.lock_or_wait(download_lock_spec_options(sleeper, false)) or { return false }
	defer {
		copy.unlock(false) or {}
	}
	return result.failed_attempts == 3 && result.warning_messages.len == 1 && result.warning_messages[0].contains('Waiting for another Homebrew process')
}

// Ruby it `it "stays silent while waiting when quiet" do` at line 56.
pub fn ruby_download_lock_spec_l56_d7_stays() bool {
	root := download_lock_spec_root('quiet')
	defer {
		os.rmdir_all(root) or {}
	}
	mut download_lock := ruby_download_lock_spec_l7_d1_download_lock(root)
	mut copy := ruby_download_lock_spec_l9_d2_download_lock_copy(root)
	download_lock.lock() or { return false }
	mut holder := &download_lock
	sleeper := fn [mut holder] (_seconds f64, _attempt int) {
		holder.unlock(false) or {}
	}
	result := copy.lock_or_wait(download_lock_spec_options(sleeper, true)) or { return false }
	defer {
		copy.unlock(false) or {}
	}
	return result.warning_messages.len == 0
}

// Ruby it `it "gives up and raises the original error once the maximum wait time passes" do` at line 63.
pub fn ruby_download_lock_spec_l63_d8_gives() bool {
	root := download_lock_spec_root('gives-up')
	defer {
		os.rmdir_all(root) or {}
	}
	mut download_lock := ruby_download_lock_spec_l7_d1_download_lock(root)
	mut copy := ruby_download_lock_spec_l9_d2_download_lock_copy(root)
	download_lock.lock() or { return false }
	defer {
		download_lock.unlock(false) or {}
	}
	if _ := copy.lock_or_wait(lock_api.DownloadLockWaitOptions{
		quiet: true
		max_wait_seconds: 0.0
		sleeper: download_lock_spec_no_sleep
		warner: lock_api.download_lock_ignore_warning
	}) {
		return false
	} else {
		return err.code() == homebrew.lock_contention_error_code
	}
}

// Ruby it `it "reports how long it waited when giving up" do` at line 71.
pub fn ruby_download_lock_spec_l71_d9_reports() bool {
	root := download_lock_spec_root('reports')
	defer {
		os.rmdir_all(root) or {}
	}
	mut download_lock := ruby_download_lock_spec_l7_d1_download_lock(root)
	mut copy := ruby_download_lock_spec_l9_d2_download_lock_copy(root)
	download_lock.lock() or { return false }
	defer {
		download_lock.unlock(false) or {}
	}
	if _ := copy.lock_or_wait(lock_api.DownloadLockWaitOptions{
		quiet: true
		max_wait_seconds: 0.0
		sleeper: download_lock_spec_no_sleep
		warner: lock_api.download_lock_ignore_warning
	}) {
		return false
	} else {
		return err.msg().contains('Gave up after waiting 0 seconds')
	}
}

// Ruby it `it "waits no longer than the caller's remaining time", timeout: 5 do` at line 81.
pub fn ruby_download_lock_spec_l81_d10_waits() bool {
	root := download_lock_spec_root('caller-timeout')
	defer {
		os.rmdir_all(root) or {}
	}
	mut download_lock := ruby_download_lock_spec_l7_d1_download_lock(root)
	mut copy := ruby_download_lock_spec_l9_d2_download_lock_copy(root)
	download_lock.lock() or { return false }
	defer {
		download_lock.unlock(false) or {}
	}
	if _ := copy.lock_or_wait(lock_api.DownloadLockWaitOptions{
		quiet: true
		timeout_seconds: 0.0
		sleeper: download_lock_spec_no_sleep
		warner: lock_api.download_lock_ignore_warning
	}) {
		return false
	} else {
		return err.code() == homebrew.lock_contention_error_code
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "lock_file/download_lock"
// 5:
// 6: RSpec.describe DownloadLock do
// 7:   subject(:download_lock) { described_class.new(Pathname("foo-download")) }
// 8:
// 9:   let(:download_lock_copy) { described_class.new(Pathname("foo-download")) }
// 10:
// 11:   after do
// 12:     download_lock.unlock
// 13:     download_lock_copy.unlock
// 14:   end
// 15:
// 16:   describe "#lock_or_wait" do
// 17:     it "acquires the lock immediately when uncontended" do
// 18:       expect { download_lock.lock_or_wait }.not_to raise_error
// 19:     end
// 20:
// 21:     it "waits for another instance's lock to release, then acquires it" do
// 22:       download_lock.lock
// 23:       allow(download_lock_copy).to receive(:sleep) { download_lock.unlock }
// 24:
// 25:       expect { download_lock_copy.lock_or_wait }.not_to raise_error
// 26:     end
// 27:
// 28:     it "retries until the other instance's lock is released" do
// 29:       download_lock.lock
// 30:       attempts = 0
// 31:       allow(download_lock_copy).to receive(:sleep) do
// 32:         attempts += 1
// 33:         download_lock.unlock if attempts >= 3
// 34:       end
// 35:
// 36:       download_lock_copy.lock_or_wait
// 37:
// 38:       expect(attempts).to eq(3)
// 39:     end
// 40:
// 41:     it "warns only once no matter how many attempts it takes" do
// 42:       download_lock.lock
// 43:       attempts = 0
// 44:       allow(download_lock_copy).to receive(:sleep) do
// 45:         attempts += 1
// 46:         download_lock.unlock if attempts >= 3
// 47:       end
// 48:
// 49:       expect(download_lock_copy).to receive(:opoo).once.with(
// 50:         /Waiting for another Homebrew process to finish downloading/,
// 51:       ).and_call_original
// 52:
// 53:       download_lock_copy.lock_or_wait
// 54:     end
// 55:
// 56:     it "stays silent while waiting when quiet" do
// 57:       download_lock.lock
// 58:       allow(download_lock_copy).to receive(:sleep) { download_lock.unlock }
// 59:
// 60:       expect { download_lock_copy.lock_or_wait(quiet: true) }.not_to output.to_stderr
// 61:     end
// 62:
// 63:     it "gives up and raises the original error once the maximum wait time passes" do
// 64:       stub_const("DownloadLock::MAX_WAIT_SECONDS", 0)
// 65:       download_lock.lock
// 66:       allow(download_lock_copy).to receive(:sleep)
// 67:
// 68:       expect { download_lock_copy.lock_or_wait(quiet: true) }.to raise_error(OperationInProgressError)
// 69:     end
// 70:
// 71:     it "reports how long it waited when giving up" do
// 72:       stub_const("DownloadLock::MAX_WAIT_SECONDS", 0)
// 73:       download_lock.lock
// 74:       allow(download_lock_copy).to receive(:sleep)
// 75:
// 76:       expect do
// 77:         download_lock_copy.lock_or_wait(quiet: true)
// 78:       end.to raise_error(/Gave up after waiting \d+ seconds/)
// 79:     end
// 80:
// 81:     it "waits no longer than the caller's remaining time", timeout: 5 do
// 82:       download_lock.lock
// 83:       allow(download_lock_copy).to receive(:sleep)
// 84:
// 85:       expect do
// 86:         download_lock_copy.lock_or_wait(quiet: true, timeout: 0)
// 87:       end.to raise_error(OperationInProgressError)
// 88:     end
// 89:   end
// 90: end
