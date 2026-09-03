module cask_loader

import homebrew.cask as brew_cask

// Translated from Homebrew/brew `test/cask/cask_loader/from_content_loader_spec.rb`.
// The original source is retained below.

pub struct FromContentLoaderSpecBoundary {
pub:
	line   int
	passed bool
}

pub fn from_content_loader_spec_try_new(content string) ?brew_cask.CaskLoader {
	return brew_cask.ruby_cask_loader_l74_d6_self_try_new(brew_cask.CaskLoaderReference{
		kind: .text
		value: content
	})
}

fn from_content_loader_spec_returns(content string) bool {
	loader := from_content_loader_spec_try_new(content) or { return false }
	return loader.kind == .content && loader.content == content && !loader.has_tap
}

// Ruby it `it "returns a loader for Casks specified with `cask \"token\" do … end`" do` at line 6.
pub fn ruby_from_content_loader_spec_l6_d1_returns() bool {
	return from_content_loader_spec_returns('cask "token" do\nend\n')
}

// Ruby it `it "returns a loader for Casks specified with `cask \"token\" do; end`" do` at line 13.
pub fn ruby_from_content_loader_spec_l13_d2_returns() bool {
	return from_content_loader_spec_returns('cask "token" do; end\n')
}

// Ruby it `it "returns a loader for Casks specified with `cask 'token' do … end`" do` at line 19.
pub fn ruby_from_content_loader_spec_l19_d3_returns() bool {
	return from_content_loader_spec_returns("cask 'token' do\nend\n")
}

// Ruby it `it "returns a loader for Casks specified with `cask 'token' do; end`" do` at line 26.
pub fn ruby_from_content_loader_spec_l26_d4_returns() bool {
	return from_content_loader_spec_returns("cask 'token' do; end\n")
}

// Ruby it `it "returns a loader for Casks specified with `cask(\"token\") { … }`" do` at line 32.
pub fn ruby_from_content_loader_spec_l32_d5_returns() bool {
	return from_content_loader_spec_returns('cask("token") {\n}\n')
}

// Ruby it `it "returns a loader for Casks specified with `cask(\"token\") {}`" do` at line 39.
pub fn ruby_from_content_loader_spec_l39_d6_returns() bool {
	return from_content_loader_spec_returns('cask("token") {}\n')
}

// Ruby it `it "returns a loader for Casks specified with `cask('token') { … }`" do` at line 45.
pub fn ruby_from_content_loader_spec_l45_d7_returns() bool {
	return from_content_loader_spec_returns("cask('token') {\n}\n")
}

// Ruby it `it "returns a loader for Casks specified with `cask('token') {}`" do` at line 52.
pub fn ruby_from_content_loader_spec_l52_d8_returns() bool {
	return from_content_loader_spec_returns("cask('token') {}\n")
}

pub fn from_content_loader_spec_all_boundaries() []FromContentLoaderSpecBoundary {
	return [
		FromContentLoaderSpecBoundary{ line: 6, passed: ruby_from_content_loader_spec_l6_d1_returns() },
		FromContentLoaderSpecBoundary{ line: 13, passed: ruby_from_content_loader_spec_l13_d2_returns() },
		FromContentLoaderSpecBoundary{ line: 19, passed: ruby_from_content_loader_spec_l19_d3_returns() },
		FromContentLoaderSpecBoundary{ line: 26, passed: ruby_from_content_loader_spec_l26_d4_returns() },
		FromContentLoaderSpecBoundary{ line: 32, passed: ruby_from_content_loader_spec_l32_d5_returns() },
		FromContentLoaderSpecBoundary{ line: 39, passed: ruby_from_content_loader_spec_l39_d6_returns() },
		FromContentLoaderSpecBoundary{ line: 45, passed: ruby_from_content_loader_spec_l45_d7_returns() },
		FromContentLoaderSpecBoundary{ line: 52, passed: ruby_from_content_loader_spec_l52_d8_returns() },
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::CaskLoader::FromContentLoader do
// 5:   describe "::try_new" do
// 6:     it "returns a loader for Casks specified with `cask \"token\" do … end`" do
// 7:       expect(described_class.try_new(<<~RUBY)).not_to be_nil
// 8:         cask "token" do
// 9:         end
// 10:       RUBY
// 11:     end
// 12:
// 13:     it "returns a loader for Casks specified with `cask \"token\" do; end`" do
// 14:       expect(described_class.try_new(<<~RUBY)).not_to be_nil
// 15:         cask "token" do; end
// 16:       RUBY
// 17:     end
// 18:
// 19:     it "returns a loader for Casks specified with `cask 'token' do … end`" do
// 20:       expect(described_class.try_new(<<~RUBY)).not_to be_nil
// 21:         cask 'token' do
// 22:         end
// 23:       RUBY
// 24:     end
// 25:
// 26:     it "returns a loader for Casks specified with `cask 'token' do; end`" do
// 27:       expect(described_class.try_new(<<~RUBY)).not_to be_nil
// 28:         cask 'token' do; end
// 29:       RUBY
// 30:     end
// 31:
// 32:     it "returns a loader for Casks specified with `cask(\"token\") { … }`" do
// 33:       expect(described_class.try_new(<<~RUBY)).not_to be_nil
// 34:         cask("token") {
// 35:         }
// 36:       RUBY
// 37:     end
// 38:
// 39:     it "returns a loader for Casks specified with `cask(\"token\") {}`" do
// 40:       expect(described_class.try_new(<<~RUBY)).not_to be_nil
// 41:         cask("token") {}
// 42:       RUBY
// 43:     end
// 44:
// 45:     it "returns a loader for Casks specified with `cask('token') { … }`" do
// 46:       expect(described_class.try_new(<<~RUBY)).not_to be_nil
// 47:         cask('token') {
// 48:         }
// 49:       RUBY
// 50:     end
// 51:
// 52:     it "returns a loader for Casks specified with `cask('token') {}`" do
// 53:       expect(described_class.try_new(<<~RUBY)).not_to be_nil
// 54:         cask('token') {}
// 55:       RUBY
// 56:     end
// 57:   end
// 58: end
