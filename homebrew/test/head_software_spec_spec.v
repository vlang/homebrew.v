module test

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/head_software_spec_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:head_spec) { described_class.new }` at line 7.
pub fn ruby_head_software_spec_spec_l7_d1_head_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return homebrew.ruby_head_software_spec_l8_d1_initialize()
}

// Ruby specify `specify "#version" do` at line 9.
pub fn ruby_head_software_spec_spec_l9_d2_version(args ...brew_runtime.Value) brew_runtime.Value {
	spec := homebrew.new_head_software_spec([])
	return brew_runtime.bool_value(spec.version.to_s() == 'HEAD' && spec.version.head())
}

// Ruby specify `specify "#verify_download_integrity" do` at line 13.
pub fn ruby_head_software_spec_spec_l13_d3_verify_download_integrity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(homebrew.ruby_head_software_spec_l14_d2_verify_download_integrity(brew_runtime.string_value('head.zip')).type_name == 'NilClass')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "head_software_spec"
// 5:
// 6: RSpec.describe HeadSoftwareSpec do
// 7:   subject(:head_spec) { described_class.new }
// 8:
// 9:   specify "#version" do
// 10:     expect(head_spec.version).to eq(Version.new("HEAD"))
// 11:   end
// 12:
// 13:   specify "#verify_download_integrity" do
// 14:     expect(head_spec.verify_download_integrity(Pathname.new("head.zip"))).to be_nil
// 15:   end
// 16: end
