module pathname

import brew_runtime

// Translated from Homebrew/brew `test/extend/pathname/write_mkpath_extension_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:file_content) { "sample contents" }` at line 12.
pub fn ruby_write_mkpath_extension_spec_l12_d1_file_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_content', ...args)
}

// Ruby it `it "creates parent directories if they do not exist" do` at line 14.
pub fn ruby_write_mkpath_extension_spec_l14_d2_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "raises if file exists and not in append mode or with offset" do` at line 24.
pub fn ruby_write_mkpath_extension_spec_l24_d3_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "allows overwrite if offset is provided" do` at line 32.
pub fn ruby_write_mkpath_extension_spec_l32_d4_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "allows append mode ('a')" do` at line 43.
pub fn ruby_write_mkpath_extension_spec_l43_d5_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "allows append mode ('a+')" do` at line 54.
pub fn ruby_write_mkpath_extension_spec_l54_d6_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/pathname/write_mkpath_extension"
// 5:
// 6: # Use a copy of Pathname with the WriteMkpathExtension prepended to avoid affecting the original class for all tests
// 7: class PathnameCopy < Pathname
// 8:   PathnameCopy.prepend WriteMkpathExtension
// 9: end
// 10:
// 11: RSpec.describe WriteMkpathExtension do
// 12:   let(:file_content) { "sample contents" }
// 13:
// 14:   it "creates parent directories if they do not exist" do
// 15:     mktmpdir do |tmpdir|
// 16:       file = PathnameCopy.new(tmpdir/"foo/bar/baz.txt")
// 17:       expect(file.dirname).not_to exist
// 18:       file.write(file_content)
// 19:       expect(file).to exist
// 20:       expect(file.read).to eq(file_content)
// 21:     end
// 22:   end
// 23:
// 24:   it "raises if file exists and not in append mode or with offset" do
// 25:     mktmpdir do |tmpdir|
// 26:       file = PathnameCopy.new(tmpdir/"file.txt")
// 27:       file.write(file_content)
// 28:       expect { file.write("new content") }.to raise_error(RuntimeError, /Will not overwrite/)
// 29:     end
// 30:   end
// 31:
// 32:   it "allows overwrite if offset is provided" do
// 33:     mktmpdir do |tmpdir|
// 34:       file = PathnameCopy.new(tmpdir/"file.txt")
// 35:       file.write(file_content)
// 36:       expect do
// 37:         file.write("change", 0)
// 38:       end.not_to raise_error
// 39:       expect(file.read).to eq("change contents")
// 40:     end
// 41:   end
// 42:
// 43:   it "allows append mode ('a')" do
// 44:     mktmpdir do |tmpdir|
// 45:       file = PathnameCopy.new(tmpdir/"file.txt")
// 46:       file.write(file_content)
// 47:       expect do
// 48:         file.write(" appended", mode: "a")
// 49:       end.not_to raise_error
// 50:       expect(file.read).to eq("#{file_content} appended")
// 51:     end
// 52:   end
// 53:
// 54:   it "allows append mode ('a+')" do
// 55:     mktmpdir do |tmpdir|
// 56:       file = PathnameCopy.new(tmpdir/"file.txt")
// 57:       file.write(file_content)
// 58:       expect do
// 59:         file.write(" again", mode: "a+")
// 60:       end.not_to raise_error
// 61:       expect(file.read).to include("again")
// 62:     end
// 63:   end
// 64: end
