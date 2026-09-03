module test

import homebrew

// Translated from Homebrew/brew `test/bottle_filename_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:filename) { described_class.new(name, version, tag, rebuild) }` at line 8.
pub fn ruby_bottle_filename_spec_l8_d1_filename() !homebrew.BottleFilename {
	return homebrew.new_bottle_filename(ruby_bottle_filename_spec_l10_d2_name(), ruby_bottle_filename_spec_l11_d3_version()!, ruby_bottle_filename_spec_l12_d4_tag()!, ruby_bottle_filename_spec_l13_d5_rebuild())
}

// Ruby let `let(:name) { "user/repo/foo" }` at line 10.
pub fn ruby_bottle_filename_spec_l10_d2_name() string {
	return 'user/repo/foo'
}

// Ruby let `let(:version) { PkgVersion.new(Version.new("1.0"), 0) }` at line 11.
pub fn ruby_bottle_filename_spec_l11_d3_version() !homebrew.PkgVersion {
	return homebrew.new_pkg_version(homebrew.new_version('1.0')!, 0)
}

// Ruby let `let(:tag) { Utils::Bottles::Tag.from_symbol(:x86_64_linux) }` at line 12.
pub fn ruby_bottle_filename_spec_l12_d4_tag() !homebrew.BottleTag {
	return homebrew.bottle_tag_from_symbol('x86_64_linux')
}

// Ruby let `let(:rebuild) { 0 }` at line 13.
pub fn ruby_bottle_filename_spec_l13_d5_rebuild() int {
	return 0
}

// Ruby it `it(:extname) { expect(filename.extname).to eq ".x86_64_linux.bottle.tar.gz" }` at line 16.
pub fn ruby_bottle_filename_spec_l16_d6_extname() !bool {
	return ruby_bottle_filename_spec_l8_d1_filename()!.extname() == '.x86_64_linux.bottle.tar.gz'
}

// Ruby it `it(:extname) { expect(filename.extname).to eq ".x86_64_linux.bottle.tar.gz" }` at line 19.
pub fn ruby_bottle_filename_spec_l19_d7_extname() !bool {
	return ruby_bottle_filename_spec_l8_d1_filename()!.extname() == '.x86_64_linux.bottle.tar.gz'
}

// Ruby let `let(:rebuild) { 1 }` at line 23.
pub fn ruby_bottle_filename_spec_l23_d8_rebuild() int {
	return 1
}

// Ruby it `it(:extname) { expect(filename.extname).to eq ".x86_64_linux.bottle.1.tar.gz" }` at line 25.
pub fn ruby_bottle_filename_spec_l25_d9_extname() !bool {
	filename := homebrew.new_bottle_filename(ruby_bottle_filename_spec_l10_d2_name(), ruby_bottle_filename_spec_l11_d3_version()!, ruby_bottle_filename_spec_l12_d4_tag()!, ruby_bottle_filename_spec_l23_d8_rebuild())!
	return filename.extname() == '.x86_64_linux.bottle.1.tar.gz'
}

// Ruby it `it(:to_s) { expect(filename.to_s).to eq "foo--1.0.x86_64_linux.bottle.tar.gz" }` at line 30.
pub fn ruby_bottle_filename_spec_l30_d10_to_s() !bool {
	return ruby_bottle_filename_spec_l8_d1_filename()!.str() == 'foo--1.0.x86_64_linux.bottle.tar.gz'
}

// Ruby it `it(:to_str) { expect(filename.to_str).to eq "foo--1.0.x86_64_linux.bottle.tar.gz" }` at line 31.
pub fn ruby_bottle_filename_spec_l31_d11_to_str() !bool {
	return ruby_bottle_filename_spec_l8_d1_filename()!.str() == 'foo--1.0.x86_64_linux.bottle.tar.gz'
}

// Ruby it `it(:url_encode) { expect(filename.url_encode).to eq "foo-1.0.x86_64_linux.bottle.tar.gz" }` at line 35.
pub fn ruby_bottle_filename_spec_l35_d12_url_encode() !bool {
	return ruby_bottle_filename_spec_l8_d1_filename()!.url_encode() == 'foo-1.0.x86_64_linux.bottle.tar.gz'
}

// Ruby it `it(:github_packages) { expect(filename.github_packages).to eq "foo--1.0.x86_64_linux.bottle.tar.gz" }` at line 39.
pub fn ruby_bottle_filename_spec_l39_d13_github_packages() !bool {
	return ruby_bottle_filename_spec_l8_d1_filename()!.github_packages() == 'foo--1.0.x86_64_linux.bottle.tar.gz'
}

// Ruby it `it(:json) { expect(filename.json).to eq "foo--1.0.x86_64_linux.bottle.json" }` at line 43.
pub fn ruby_bottle_filename_spec_l43_d14_json() !bool {
	return ruby_bottle_filename_spec_l8_d1_filename()!.json() == 'foo--1.0.x86_64_linux.bottle.json'
}

// Ruby it `it(:json) { expect(filename.json).to eq "foo--1.0.x86_64_linux.bottle.json" }` at line 46.
pub fn ruby_bottle_filename_spec_l46_d15_json() !bool {
	filename := homebrew.new_bottle_filename(ruby_bottle_filename_spec_l10_d2_name(), ruby_bottle_filename_spec_l11_d3_version()!, ruby_bottle_filename_spec_l12_d4_tag()!, ruby_bottle_filename_spec_l23_d8_rebuild())!
	return filename.json() == 'foo--1.0.x86_64_linux.bottle.json'
}

pub struct BottleFilenameSpecFormula {
pub:
	name        string
	pkg_version homebrew.PkgVersion
}

// Ruby subject `subject(:filename) { described_class.create(f, tag, rebuild) }` at line 51.
pub fn ruby_bottle_filename_spec_l51_d16_filename() !homebrew.BottleFilename {
	formula := ruby_bottle_filename_spec_l53_d17_f()!
	return homebrew.new_bottle_filename(formula.name, formula.pkg_version, ruby_bottle_filename_spec_l12_d4_tag()!, ruby_bottle_filename_spec_l13_d5_rebuild())
}

// Ruby let `let(:f) do` at line 53.
pub fn ruby_bottle_filename_spec_l53_d17_f() !BottleFilenameSpecFormula {
	return BottleFilenameSpecFormula{
		name: 'formula_name'
		pkg_version: homebrew.new_pkg_version(homebrew.new_version('1.0')!, 0)
	}
}

// Ruby it `it(:to_s) { expect(filename.to_s).to eq "formula_name--1.0.x86_64_linux.bottle.tar.gz" }` at line 61.
pub fn ruby_bottle_filename_spec_l61_d18_to_s() !bool {
	return ruby_bottle_filename_spec_l51_d16_filename()!.str() == 'formula_name--1.0.x86_64_linux.bottle.tar.gz'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "software_spec"
// 6:
// 7: RSpec.describe Bottle::Filename do
// 8:   subject(:filename) { described_class.new(name, version, tag, rebuild) }
// 9:
// 10:   let(:name) { "user/repo/foo" }
// 11:   let(:version) { PkgVersion.new(Version.new("1.0"), 0) }
// 12:   let(:tag) { Utils::Bottles::Tag.from_symbol(:x86_64_linux) }
// 13:   let(:rebuild) { 0 }
// 14:
// 15:   describe "#extname" do
// 16:     it(:extname) { expect(filename.extname).to eq ".x86_64_linux.bottle.tar.gz" }
// 17:
// 18:     context "when rebuild is 0" do
// 19:       it(:extname) { expect(filename.extname).to eq ".x86_64_linux.bottle.tar.gz" }
// 20:     end
// 21:
// 22:     context "when rebuild is 1" do
// 23:       let(:rebuild) { 1 }
// 24:
// 25:       it(:extname) { expect(filename.extname).to eq ".x86_64_linux.bottle.1.tar.gz" }
// 26:     end
// 27:   end
// 28:
// 29:   describe "#to_s and #to_str" do
// 30:     it(:to_s) { expect(filename.to_s).to eq "foo--1.0.x86_64_linux.bottle.tar.gz" }
// 31:     it(:to_str) { expect(filename.to_str).to eq "foo--1.0.x86_64_linux.bottle.tar.gz" }
// 32:   end
// 33:
// 34:   describe "#url_encode" do
// 35:     it(:url_encode) { expect(filename.url_encode).to eq "foo-1.0.x86_64_linux.bottle.tar.gz" }
// 36:   end
// 37:
// 38:   describe "#github_packages" do
// 39:     it(:github_packages) { expect(filename.github_packages).to eq "foo--1.0.x86_64_linux.bottle.tar.gz" }
// 40:   end
// 41:
// 42:   describe "#json" do
// 43:     it(:json) { expect(filename.json).to eq "foo--1.0.x86_64_linux.bottle.json" }
// 44:
// 45:     context "when rebuild is 1" do
// 46:       it(:json) { expect(filename.json).to eq "foo--1.0.x86_64_linux.bottle.json" }
// 47:     end
// 48:   end
// 49:
// 50:   describe "::create" do
// 51:     subject(:filename) { described_class.create(f, tag, rebuild) }
// 52:
// 53:     let(:f) do
// 54:       formula do
// 55:         T.bind(self, T.class_of(Formula))
// 56:         url "https://brew.sh/foo.tar.gz"
// 57:         version "1.0"
// 58:       end
// 59:     end
// 60:
// 61:     it(:to_s) { expect(filename.to_s).to eq "formula_name--1.0.x86_64_linux.bottle.tar.gz" }
// 62:   end
// 63: end
