module test

import brew_runtime

// Translated from Homebrew/brew `test/lock_file_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:lock_file) { described_class.new(:lock, Pathname("foo")) }` at line 7.
pub fn ruby_lock_file_spec_l7_d1_lock_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lock_file', ...args)
}

// Ruby let `let(:lock_file_copy) { described_class.new(:lock, Pathname("foo")) }` at line 9.
pub fn ruby_lock_file_spec_l9_d2_lock_file_copy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lock_file_copy', ...args)
}

// Ruby it `it "ensures the lock file is created" do` at line 12.
pub fn ruby_lock_file_spec_l12_d3_ensures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensures', ...args)
}

// Ruby it `it "does not raise an error when the same instance is locked multiple times" do` at line 18.
pub fn ruby_lock_file_spec_l18_d4_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "raises an error if another instance is already locked" do` at line 24.
pub fn ruby_lock_file_spec_l24_d5_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "retries until it locks the file that is on disk" do` at line 32.
pub fn ruby_lock_file_spec_l32_d6_retries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retries', ...args)
}

// Ruby it `it "ignores interrupts while locking" do` at line 40.
pub fn ruby_lock_file_spec_l40_d7_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "does not raise an error when already unlocked" do` at line 48.
pub fn ruby_lock_file_spec_l48_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "unlocks when locked" do` at line 52.
pub fn ruby_lock_file_spec_l52_d9_unlocks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlocks', ...args)
}

// Ruby it `it "allows deleting a lock file only by the instance that locked it" do` at line 59.
pub fn ruby_lock_file_spec_l59_d10_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
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
