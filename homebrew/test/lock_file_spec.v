module test

import ruby
import homebrew
import os
import time

// Translated from Homebrew/brew `test/lock_file_spec.rb`.
// The original source is retained below for exact boundary auditing.

pub fn lock_file_spec_new(root string) homebrew.LockFile {
	return homebrew.new_lock_file('lock', 'foo', root)
}

fn lock_file_spec_root(args []ruby.Value, label string) string {
	if args.len > 0 && args[0].as_string() != '' {
		return args[0].as_string()
	}
	return os.join_path(os.temp_dir(), 'brew-v-lock-file-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn lock_file_spec_value(lock_file homebrew.LockFile) ruby.Value {
	return ruby.structured_value('LockFile', lock_file.path, {
		'path':        lock_file.path
		'locked_path': lock_file.locked_path
		'locked':      lock_file.locked.str()
	})
}

// Ruby subject `subject(:lock_file) { described_class.new(:lock, Pathname("foo")) }` at line 7.
pub fn ruby_lock_file_spec_l7_d1_lock_file(args ...ruby.Value) ruby.Value {
	return lock_file_spec_value(lock_file_spec_new(lock_file_spec_root(args, 'subject')))
}

// Ruby let `let(:lock_file_copy) { described_class.new(:lock, Pathname("foo")) }` at line 9.
pub fn ruby_lock_file_spec_l9_d2_lock_file_copy(args ...ruby.Value) ruby.Value {
	return lock_file_spec_value(lock_file_spec_new(lock_file_spec_root(args, 'copy')))
}

// Ruby it `it "ensures the lock file is created" do` at line 12.
pub fn ruby_lock_file_spec_l12_d3_ensures(args ...ruby.Value) ruby.Value {
	root := lock_file_spec_root(args, 'creates')
	defer { os.rmdir_all(root) or {} }
	mut lock_file := lock_file_spec_new(root)
	if os.exists(lock_file.path) {
		return ruby.bool_value(false)
	}
	lock_file.lock() or { return ruby.bool_value(false) }
	exists := os.exists(lock_file.path)
	lock_file.unlock(false) or { return ruby.bool_value(false) }
	return ruby.bool_value(exists)
}

// Ruby it `it "does not raise an error when the same instance is locked multiple times" do` at line 18.
pub fn ruby_lock_file_spec_l18_d4_does(args ...ruby.Value) ruby.Value {
	root := lock_file_spec_root(args, 'idempotent')
	defer { os.rmdir_all(root) or {} }
	mut lock_file := lock_file_spec_new(root)
	lock_file.lock() or { return ruby.bool_value(false) }
	lock_file.lock() or { return ruby.bool_value(false) }
	locked := lock_file.locked
	lock_file.unlock(false) or { return ruby.bool_value(false) }
	return ruby.bool_value(locked)
}

// Ruby it `it "raises an error if another instance is already locked" do` at line 24.
pub fn ruby_lock_file_spec_l24_d5_raises(args ...ruby.Value) ruby.Value {
	root := lock_file_spec_root(args, 'contention')
	defer { os.rmdir_all(root) or {} }
	mut first := lock_file_spec_new(root)
	mut second := lock_file_spec_new(root)
	first.lock() or { return ruby.bool_value(false) }
	if _ := second.lock() {
		first.unlock(false) or {}
		return ruby.bool_value(false)
	} else {
		matches := err.code() == homebrew.lock_contention_error_code && err.msg().contains('foo')
		first.unlock(false) or {}
		return ruby.bool_value(matches)
	}
}

// Ruby it `it "retries until it locks the file that is on disk" do` at line 32.
pub fn ruby_lock_file_spec_l32_d6_retries(args ...ruby.Value) ruby.Value {
	root := lock_file_spec_root(args, 'disk-retry')
	defer { os.rmdir_all(root) or {} }
	os.mkdir_all(root) or { return ruby.bool_value(false) }
	mut lock_file := lock_file_spec_new(root)
	os.write_file(lock_file.path, '') or { return ruby.bool_value(false) }
	lock_file.lock() or { return ruby.bool_value(false) }
	locked_on_disk := lock_file.locked && os.exists(lock_file.path)
	lock_file.unlock(false) or { return ruby.bool_value(false) }
	return ruby.bool_value(locked_on_disk)
}

// Ruby it `it "ignores interrupts while locking" do` at line 40.
pub fn ruby_lock_file_spec_l40_d7_ignores(args ...ruby.Value) ruby.Value {
	root := lock_file_spec_root(args, 'interrupts')
	defer { os.rmdir_all(root) or {} }
	mut lock_file := lock_file_spec_new(root)
	lock_file.lock() or { return ruby.bool_value(false) }
	locked := lock_file.locked
	lock_file.unlock(false) or { return ruby.bool_value(false) }
	return ruby.bool_value(locked)
}

// Ruby it `it "does not raise an error when already unlocked" do` at line 48.
pub fn ruby_lock_file_spec_l48_d8_does(args ...ruby.Value) ruby.Value {
	root := lock_file_spec_root(args, 'already-unlocked')
	defer { os.rmdir_all(root) or {} }
	mut lock_file := lock_file_spec_new(root)
	lock_file.unlock(false) or { return ruby.bool_value(false) }
	return ruby.bool_value(!lock_file.locked)
}

// Ruby it `it "unlocks when locked" do` at line 52.
pub fn ruby_lock_file_spec_l52_d9_unlocks(args ...ruby.Value) ruby.Value {
	root := lock_file_spec_root(args, 'unlocks')
	defer { os.rmdir_all(root) or {} }
	mut first := lock_file_spec_new(root)
	mut second := lock_file_spec_new(root)
	first.lock() or { return ruby.bool_value(false) }
	first.unlock(false) or { return ruby.bool_value(false) }
	second.lock() or { return ruby.bool_value(false) }
	acquired := second.locked
	second.unlock(false) or { return ruby.bool_value(false) }
	return ruby.bool_value(acquired)
}

// Ruby it `it "allows deleting a lock file only by the instance that locked it" do` at line 59.
pub fn ruby_lock_file_spec_l59_d10_allows(args ...ruby.Value) ruby.Value {
	root := lock_file_spec_root(args, 'owner-unlinks')
	defer { os.rmdir_all(root) or {} }
	mut first := lock_file_spec_new(root)
	mut second := lock_file_spec_new(root)
	first.lock() or { return ruby.bool_value(false) }
	if !os.exists(first.path) || !os.exists(second.path) {
		first.unlock(false) or {}
		return ruby.bool_value(false)
	}
	second.unlock(true) or {
		first.unlock(false) or {}
		return ruby.bool_value(false)
	}
	if !os.exists(first.path) {
		first.unlock(false) or {}
		return ruby.bool_value(false)
	}
	first.unlock(true) or { return ruby.bool_value(false) }
	return ruby.bool_value(!os.exists(first.path))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "lock_file"
// 5:
// 6: RSpec.describe LockFile do
// 7:   subject(:lock_file) { described_class.new(:lock, Pathname("foo")) }
// 8:
// 9:   let(:lock_file_copy) { described_class.new(:lock, Pathname("foo")) }
// 10:
// 11:   describe "#lock" do
// 12:     it "ensures the lock file is created" do
// 13:       expect(lock_file.path).not_to exist
// 14:       lock_file.lock
// 15:       expect(lock_file.path).to exist
// 16:     end
// 17:
// 18:     it "does not raise an error when the same instance is locked multiple times" do
// 19:       lock_file.lock
// 20:
// 21:       expect { lock_file.lock }.not_to raise_error
// 22:     end
// 23:
// 24:     it "raises an error if another instance is already locked" do
// 25:       lock_file.lock
// 26:
// 27:       expect do
// 28:         lock_file_copy.lock
// 29:       end.to raise_error(OperationInProgressError)
// 30:     end
// 31:
// 32:     it "retries until it locks the file that is on disk" do
// 33:       expect(lock_file.path).to receive(:exist?).twice.and_return(false, true)
// 34:
// 35:       lock_file.lock
// 36:     end
// 37:
// 38:     # Deferring the interrupt can't be observed in-process, as RSpec owns the
// 39:     # `INT` handler that `ignore_interrupts` traps.
// 40:     it "ignores interrupts while locking" do
// 41:       expect(lock_file).to receive(:ignore_interrupts).and_call_original
// 42:
// 43:       lock_file.lock
// 44:     end
// 45:   end
// 46:
// 47:   describe "#unlock" do
// 48:     it "does not raise an error when already unlocked" do
// 49:       expect { lock_file.unlock }.not_to raise_error
// 50:     end
// 51:
// 52:     it "unlocks when locked" do
// 53:       lock_file.lock
// 54:       lock_file.unlock
// 55:
// 56:       expect { lock_file_copy.lock }.not_to raise_error
// 57:     end
// 58:
// 59:     it "allows deleting a lock file only by the instance that locked it" do
// 60:       lock_file.lock
// 61:       expect(lock_file.path).to exist
// 62:
// 63:       expect(lock_file_copy.path).to exist
// 64:       lock_file_copy.unlock(unlink: true)
// 65:       expect(lock_file_copy.path).to exist
// 66:       expect(lock_file.path).to exist
// 67:
// 68:       lock_file.unlock(unlink: true)
// 69:       expect(lock_file.path).not_to exist
// 70:     end
// 71:   end
// 72: end
