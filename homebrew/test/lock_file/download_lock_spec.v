module lock_file

import brew_runtime

// Translated from Homebrew/brew `test/lock_file/download_lock_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:download_lock) { described_class.new(Pathname("foo-download")) }` at line 7.
pub fn ruby_download_lock_spec_l7_d1_download_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_lock', ...args)
}

// Ruby let `let(:download_lock_copy) { described_class.new(Pathname("foo-download")) }` at line 9.
pub fn ruby_download_lock_spec_l9_d2_download_lock_copy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_lock_copy', ...args)
}

// Ruby it `it "acquires the lock immediately when uncontended" do` at line 17.
pub fn ruby_download_lock_spec_l17_d3_acquires(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('acquires', ...args)
}

// Ruby it `it "waits for another instance's lock to release, then acquires it" do` at line 21.
pub fn ruby_download_lock_spec_l21_d4_waits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('waits', ...args)
}

// Ruby it `it "retries until the other instance's lock is released" do` at line 28.
pub fn ruby_download_lock_spec_l28_d5_retries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retries', ...args)
}

// Ruby it `it "warns only once no matter how many attempts it takes" do` at line 41.
pub fn ruby_download_lock_spec_l41_d6_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby it `it "stays silent while waiting when quiet" do` at line 56.
pub fn ruby_download_lock_spec_l56_d7_stays(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stays', ...args)
}

// Ruby it `it "gives up and raises the original error once the maximum wait time passes" do` at line 63.
pub fn ruby_download_lock_spec_l63_d8_gives(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gives', ...args)
}

// Ruby it `it "reports how long it waited when giving up" do` at line 71.
pub fn ruby_download_lock_spec_l71_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "waits no longer than the caller's remaining time", timeout: 5 do` at line 81.
pub fn ruby_download_lock_spec_l81_d10_waits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('waits', ...args)
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
