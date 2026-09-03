module download_strategies

import brew_runtime
import homebrew.download_strategy

// Translated from Homebrew/brew `test/download_strategies/abstract_file_spec.rb`.
// The original source is retained below for exact boundary auditing.

pub const abstract_file_spec_url = 'https://example.com/foo.tar.gz'

fn abstract_file_spec_parses(raw_url string, expected string) brew_runtime.Value {
	return brew_runtime.bool_value(download_strategy.parse_basename(raw_url, true) == expected)
}

// Ruby subject `subject(:strategy) { Class.new(described_class).new(url, "foo", "1.2.3") }` at line 7.
pub fn ruby_abstract_file_spec_l7_d1_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	url := if args.len > 0 { args[0].as_string() } else { abstract_file_spec_url }
	return brew_runtime.structured_value('AbstractFileDownloadStrategy', url, {
		'url':     url
		'name':    'foo'
		'version': '1.2.3'
	})
}

// Ruby let `let(:url) { "https://example.com/foo.tar.gz" }` at line 9.
pub fn ruby_abstract_file_spec_l9_d2_url(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(abstract_file_spec_url)
}

// Ruby it `it "returns the final path segment for simple URLs" do` at line 12.
pub fn ruby_abstract_file_spec_l12_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return abstract_file_spec_parses(abstract_file_spec_url, 'foo.tar.gz')
}

// Ruby it `it "prefers a path segment with an extension over later extensionless segments" do` at line 16.
pub fn ruby_abstract_file_spec_l16_d4_prefers(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return abstract_file_spec_parses('https://example.com/foo-1.0.tar.gz/download', 'foo-1.0.tar.gz')
}

// Ruby it `it "extracts the basename from a response-content-disposition query parameter" do` at line 20.
pub fn ruby_abstract_file_spec_l20_d5_extracts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return abstract_file_spec_parses('https://example.com/download.php?file=ignored&response-content-disposition=attachment;filename="real.tar.gz"', 'real.tar.gz')
}

// Ruby it `it "uses the query value when the path has no extension" do` at line 25.
pub fn ruby_abstract_file_spec_l25_d6_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return abstract_file_spec_parses('https://example.com/download.php?file=foo-1.0.tar.gz', 'foo-1.0.tar.gz')
}

// Ruby it `it "returns the final segment for file:// URLs even when an ancestor directory contains a dot" do` at line 30.
pub fn ruby_abstract_file_spec_l30_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return abstract_file_spec_parses('file:///Users/me/git-repos/github.com/Homebrew/brew/naked_executable', 'naked_executable')
}

// Ruby it `it "returns the final segment for file:// URLs with an extension" do` at line 35.
pub fn ruby_abstract_file_spec_l35_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return abstract_file_spec_parses('file:///tmp/foo.tar.gz', 'foo.tar.gz')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe AbstractFileDownloadStrategy do
// 7:   subject(:strategy) { Class.new(described_class).new(url, "foo", "1.2.3") }
// 8:
// 9:   let(:url) { "https://example.com/foo.tar.gz" }
// 10:
// 11:   describe "#parse_basename" do
// 12:     it "returns the final path segment for simple URLs" do
// 13:       expect(strategy.parse_basename("https://example.com/foo.tar.gz")).to eq("foo.tar.gz")
// 14:     end
// 15:
// 16:     it "prefers a path segment with an extension over later extensionless segments" do
// 17:       expect(strategy.parse_basename("https://example.com/foo-1.0.tar.gz/download")).to eq("foo-1.0.tar.gz")
// 18:     end
// 19:
// 20:     it "extracts the basename from a response-content-disposition query parameter" do
// 21:       url = "https://example.com/download.php?file=ignored&response-content-disposition=attachment;filename=\"real.tar.gz\""
// 22:       expect(strategy.parse_basename(url)).to eq("real.tar.gz")
// 23:     end
// 24:
// 25:     it "uses the query value when the path has no extension" do
// 26:       url = "https://example.com/download.php?file=foo-1.0.tar.gz"
// 27:       expect(strategy.parse_basename(url)).to eq("foo-1.0.tar.gz")
// 28:     end
// 29:
// 30:     it "returns the final segment for file:// URLs even when an ancestor directory contains a dot" do
// 31:       expect(strategy.parse_basename("file:///Users/me/git-repos/github.com/Homebrew/brew/naked_executable"))
// 32:         .to eq("naked_executable")
// 33:     end
// 34:
// 35:     it "returns the final segment for file:// URLs with an extension" do
// 36:       expect(strategy.parse_basename("file:///tmp/foo.tar.gz")).to eq("foo.tar.gz")
// 37:     end
// 38:   end
// 39: end
