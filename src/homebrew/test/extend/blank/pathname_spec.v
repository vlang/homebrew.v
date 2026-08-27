module blank

import brew_runtime

// Translated from Homebrew/brew `test/extend/blank/pathname_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:blank) { [described_class.new("")] }` at line 8.
pub fn ruby_pathname_spec_l8_d1_blank(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('blank', ...args)
}

// Ruby let `let(:present) { [described_class.new(" "), described_class.new("."), described_class.new("test")] }` at line 9.
pub fn ruby_pathname_spec_l9_d2_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('present', ...args)
}

// Ruby it `it "is blank if and only if the path string is empty" do` at line 12.
pub fn ruby_pathname_spec_l12_d3_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is present if and only if the path string is not empty" do` at line 19.
pub fn ruby_pathname_spec_l19_d4_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "returns the pathname when present, otherwise nil" do` at line 26.
pub fn ruby_pathname_spec_l26_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "judges by the path string, not filesystem content" do` at line 37.
pub fn ruby_pathname_spec_l37_d6_judges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('judges', ...args)
}

// Ruby it `it "treats an existing empty file as present" do` at line 43.
pub fn ruby_pathname_spec_l43_d7_treats(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('treats', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/blank"
// 5:
// 6: # Modelled on ActiveSupport's `test/core_ext/pathname/blank_test.rb`.
// 7: RSpec.describe Pathname do
// 8:   let(:blank) { [described_class.new("")] }
// 9:   let(:present) { [described_class.new(" "), described_class.new("."), described_class.new("test")] }
// 10:
// 11:   describe "#blank?" do
// 12:     it "is blank if and only if the path string is empty" do
// 13:       blank.each { |path| expect(path.blank?).to be(true), "#{path.inspect} should be blank" }
// 14:       present.each { |path| expect(path.blank?).to be(false), "#{path.inspect} should not be blank" }
// 15:     end
// 16:   end
// 17:
// 18:   describe "#present?" do
// 19:     it "is present if and only if the path string is not empty" do
// 20:       blank.each { |path| expect(path.present?).to be(false), "#{path.inspect} should not be present" }
// 21:       present.each { |path| expect(path.present?).to be(true), "#{path.inspect} should be present" }
// 22:     end
// 23:   end
// 24:
// 25:   describe "#presence" do
// 26:     it "returns the pathname when present, otherwise nil" do
// 27:       blank.each { |path| expect(path.presence).to be_nil }
// 28:       present.each { |path| expect(path.presence).to be path }
// 29:     end
// 30:   end
// 31:
// 32:   describe "filesystem independence" do
// 33:     # Before `Pathname#blank?` was redefined it dispatched to the filesystem
// 34:     # via `Pathname#empty?`, so the empty path string was present and the
// 35:     # existing empty file and directory were blank. A nonexistent path was
// 36:     # present under both implementations.
// 37:     it "judges by the path string, not filesystem content" do
// 38:       expect(described_class.new("").blank?).to be true
// 39:       expect(mktmpdir.present?).to be true
// 40:       expect((mktmpdir/"nonexistent").present?).to be true
// 41:     end
// 42:
// 43:     it "treats an existing empty file as present" do
// 44:       file = mktmpdir/"empty-file"
// 45:       FileUtils.touch file
// 46:
// 47:       expect(file.present?).to be true
// 48:     end
// 49:   end
// 50: end
