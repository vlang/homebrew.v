module dsl

import homebrew.cask.dsl as rename_dsl
import os

// Translated from Homebrew/brew `test/cask/dsl/rename_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:rename) { described_class.new(from, to) }` at line 5.
pub fn ruby_rename_spec_l5_d1_rename(from string, to string) rename_dsl.CaskRename {
	return rename_dsl.new_cask_rename(from, to)
}

// Ruby let `let(:from) { "Source File*.pkg" }` at line 7.
pub fn ruby_rename_spec_l7_d2_from() string {
	return 'Source File*.pkg'
}

// Ruby let `let(:to) { "Target File.pkg" }` at line 8.
pub fn ruby_rename_spec_l8_d3_to() string {
	return 'Target File.pkg'
}

// Ruby it `it "sets the from and to attributes" do` at line 11.
pub fn ruby_rename_spec_l11_d4_sets() bool {
	rename := ruby_rename_spec_l5_d1_rename(ruby_rename_spec_l7_d2_from(), ruby_rename_spec_l8_d3_to())
	return rename.from == 'Source File*.pkg' && rename.to == 'Target File.pkg'
}

// Ruby it `it "returns the attributes as a hash" do` at line 18.
pub fn ruby_rename_spec_l18_d5_returns() bool {
	rename := ruby_rename_spec_l5_d1_rename(ruby_rename_spec_l7_d2_from(), ruby_rename_spec_l8_d3_to())
	pairs := rename_dsl.ruby_rename_l44_d5_pairs(rename_dsl.cask_rename_value(rename))
	return (pairs.map_data['from'] or { return false }).as_string() == rename.from && (pairs.map_data['to'] or { return false }).as_string() == rename.to
}

// Ruby it `it "returns the stringified attributes" do` at line 24.
pub fn ruby_rename_spec_l24_d6_returns() bool {
	rename := ruby_rename_spec_l5_d1_rename(ruby_rename_spec_l7_d2_from(), ruby_rename_spec_l8_d3_to())
	value := rename_dsl.cask_rename_value(rename)
	return rename_dsl.ruby_rename_l49_d6_to_s(value).as_string() == value.repr
}

// Ruby let `let(:tmpdir) { mktmpdir }` at line 30.
pub fn ruby_rename_spec_l30_d7_tmpdir(root string) string {
	return root
}

// Ruby let `let(:staged_path) { Pathname(tmpdir) }` at line 31.
pub fn ruby_rename_spec_l31_d8_staged_path(root string) string {
	return ruby_rename_spec_l30_d7_tmpdir(root)
}

// Ruby let `let(:staged_path) { Pathname("/nonexistent/path") }` at line 34.
pub fn ruby_rename_spec_l34_d9_staged_path() string {
	return '/nonexistent/path'
}

// Ruby it `it "does nothing" do` at line 36.
pub fn ruby_rename_spec_l36_d10_does() !bool {
	rename := ruby_rename_spec_l5_d1_rename(ruby_rename_spec_l7_d2_from(), ruby_rename_spec_l8_d3_to())
	rename.perform(ruby_rename_spec_l34_d9_staged_path())!
	return true
}

// Ruby let `let(:from) { "Test App*.pkg" }` at line 42.
pub fn ruby_rename_spec_l42_d11_from() string {
	return 'Test App*.pkg'
}

// Ruby let `let(:to) { "Test App.pkg" }` at line 43.
pub fn ruby_rename_spec_l43_d12_to() string {
	return 'Test App.pkg'
}

// Ruby it `it "renames the first matching file" do` at line 50.
pub fn ruby_rename_spec_l50_d13_renames(root string) !bool {
	staged_path := ruby_rename_spec_l31_d8_staged_path(root)
	os.mkdir_all(staged_path)!
	first := os.join_path(staged_path, 'Test App v1.2.3.pkg')
	second := os.join_path(staged_path, 'Test App v2.0.0.pkg')
	target := os.join_path(staged_path, ruby_rename_spec_l43_d12_to())
	os.write_file(first, 'test content')!
	os.write_file(second, 'other content')!
	ruby_rename_spec_l5_d1_rename(ruby_rename_spec_l42_d11_from(), ruby_rename_spec_l43_d12_to()).perform(staged_path)!
	return os.exists(target) && os.read_file(target)! == 'test content' && !os.exists(first) && os.exists(second)
}

// Ruby let `let(:from) { "Exact File.dmg" }` at line 61.
pub fn ruby_rename_spec_l61_d14_from() string {
	return 'Exact File.dmg'
}

// Ruby let `let(:to) { "New Name.dmg" }` at line 62.
pub fn ruby_rename_spec_l62_d15_to() string {
	return 'New Name.dmg'
}

// Ruby it `it "renames the exact file" do` at line 68.
pub fn ruby_rename_spec_l68_d16_renames(root string) !bool {
	os.mkdir_all(root)!
	source := os.join_path(root, ruby_rename_spec_l61_d14_from())
	target := os.join_path(root, ruby_rename_spec_l62_d15_to())
	os.write_file(source, 'dmg content')!
	ruby_rename_spec_l5_d1_rename(ruby_rename_spec_l61_d14_from(), ruby_rename_spec_l62_d15_to()).perform(root)!
	return os.exists(target) && os.read_file(target)! == 'dmg content' && !os.exists(source)
}

// Ruby let `let(:from) { "source.txt" }` at line 78.
pub fn ruby_rename_spec_l78_d17_from() string {
	return 'source.txt'
}

// Ruby let `let(:to) { "subdir/target.txt" }` at line 79.
pub fn ruby_rename_spec_l79_d18_to() string {
	return 'subdir/target.txt'
}

// Ruby it `it "creates the subdirectory and renames the file" do` at line 85.
pub fn ruby_rename_spec_l85_d19_creates(root string) !bool {
	os.mkdir_all(root)!
	source := os.join_path(root, ruby_rename_spec_l78_d17_from())
	target := os.join_path(root, ruby_rename_spec_l79_d18_to())
	os.write_file(source, 'content')!
	ruby_rename_spec_l5_d1_rename(ruby_rename_spec_l78_d17_from(), ruby_rename_spec_l79_d18_to()).perform(root)!
	return os.exists(target) && os.read_file(target)! == 'content' && !os.exists(source)
}

// Ruby let `let(:from) { "nonexistent*.pkg" }` at line 95.
pub fn ruby_rename_spec_l95_d20_from() string {
	return 'nonexistent*.pkg'
}

// Ruby let `let(:to) { "target.pkg" }` at line 96.
pub fn ruby_rename_spec_l96_d21_to() string {
	return 'target.pkg'
}

// Ruby it `it "does nothing" do` at line 98.
pub fn ruby_rename_spec_l98_d22_does(root string) !bool {
	os.mkdir_all(root)!
	ruby_rename_spec_l5_d1_rename(ruby_rename_spec_l95_d20_from(), ruby_rename_spec_l96_d21_to()).perform(root)!
	return !os.exists(os.join_path(root, ruby_rename_spec_l96_d21_to()))
}

// Ruby let `let(:from) { "missing.txt" }` at line 106.
pub fn ruby_rename_spec_l106_d23_from() string {
	return 'missing.txt'
}

// Ruby let `let(:to) { "target.txt" }` at line 107.
pub fn ruby_rename_spec_l107_d24_to() string {
	return 'target.txt'
}

// Ruby it `it "does nothing" do` at line 109.
pub fn ruby_rename_spec_l109_d25_does(root string) !bool {
	os.mkdir_all(root)!
	ruby_rename_spec_l5_d1_rename(ruby_rename_spec_l106_d23_from(), ruby_rename_spec_l107_d24_to()).perform(root)!
	return !os.exists(os.join_path(root, ruby_rename_spec_l107_d24_to()))
}

pub struct RenameSpecBoundary {
pub:
	line   int
	passed bool
}

pub fn rename_spec_all_boundaries(root string) ![]RenameSpecBoundary {
	os.mkdir_all(root)!
	return [
		RenameSpecBoundary{ line: 5, passed: ruby_rename_spec_l5_d1_rename('a', 'b').from == 'a' },
		RenameSpecBoundary{ line: 7, passed: ruby_rename_spec_l7_d2_from() == 'Source File*.pkg' },
		RenameSpecBoundary{ line: 8, passed: ruby_rename_spec_l8_d3_to() == 'Target File.pkg' },
		RenameSpecBoundary{ line: 11, passed: ruby_rename_spec_l11_d4_sets() },
		RenameSpecBoundary{ line: 18, passed: ruby_rename_spec_l18_d5_returns() },
		RenameSpecBoundary{ line: 24, passed: ruby_rename_spec_l24_d6_returns() },
		RenameSpecBoundary{ line: 30, passed: ruby_rename_spec_l30_d7_tmpdir(root) == root },
		RenameSpecBoundary{ line: 31, passed: ruby_rename_spec_l31_d8_staged_path(root) == root },
		RenameSpecBoundary{ line: 34, passed: ruby_rename_spec_l34_d9_staged_path() == '/nonexistent/path' },
		RenameSpecBoundary{ line: 36, passed: ruby_rename_spec_l36_d10_does()! },
		RenameSpecBoundary{ line: 42, passed: ruby_rename_spec_l42_d11_from() == 'Test App*.pkg' },
		RenameSpecBoundary{ line: 43, passed: ruby_rename_spec_l43_d12_to() == 'Test App.pkg' },
		RenameSpecBoundary{ line: 50, passed: ruby_rename_spec_l50_d13_renames(os.join_path(root, 'glob'))! },
		RenameSpecBoundary{ line: 61, passed: ruby_rename_spec_l61_d14_from() == 'Exact File.dmg' },
		RenameSpecBoundary{ line: 62, passed: ruby_rename_spec_l62_d15_to() == 'New Name.dmg' },
		RenameSpecBoundary{ line: 68, passed: ruby_rename_spec_l68_d16_renames(os.join_path(root, 'exact'))! },
		RenameSpecBoundary{ line: 78, passed: ruby_rename_spec_l78_d17_from() == 'source.txt' },
		RenameSpecBoundary{ line: 79, passed: ruby_rename_spec_l79_d18_to() == 'subdir/target.txt' },
		RenameSpecBoundary{ line: 85, passed: ruby_rename_spec_l85_d19_creates(os.join_path(root, 'subdir'))! },
		RenameSpecBoundary{ line: 95, passed: ruby_rename_spec_l95_d20_from() == 'nonexistent*.pkg' },
		RenameSpecBoundary{ line: 96, passed: ruby_rename_spec_l96_d21_to() == 'target.pkg' },
		RenameSpecBoundary{ line: 98, passed: ruby_rename_spec_l98_d22_does(os.join_path(root, 'no-match'))! },
		RenameSpecBoundary{ line: 106, passed: ruby_rename_spec_l106_d23_from() == 'missing.txt' },
		RenameSpecBoundary{ line: 107, passed: ruby_rename_spec_l107_d24_to() == 'target.txt' },
		RenameSpecBoundary{ line: 109, passed: ruby_rename_spec_l109_d25_does(os.join_path(root, 'missing'))! },
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::DSL::Rename do
// 5:   subject(:rename) { described_class.new(from, to) }
// 6:
// 7:   let(:from) { "Source File*.pkg" }
// 8:   let(:to) { "Target File.pkg" }
// 9:
// 10:   describe "#initialize" do
// 11:     it "sets the from and to attributes" do
// 12:       expect(rename.from).to eq("Source File*.pkg")
// 13:       expect(rename.to).to eq("Target File.pkg")
// 14:     end
// 15:   end
// 16:
// 17:   describe "#pairs" do
// 18:     it "returns the attributes as a hash" do
// 19:       expect(rename.pairs).to eq(from: "Source File*.pkg", to: "Target File.pkg")
// 20:     end
// 21:   end
// 22:
// 23:   describe "#to_s" do
// 24:     it "returns the stringified attributes" do
// 25:       expect(rename.to_s).to eq(rename.pairs.inspect)
// 26:     end
// 27:   end
// 28:
// 29:   describe "#perform_rename" do
// 30:     let(:tmpdir) { mktmpdir }
// 31:     let(:staged_path) { Pathname(tmpdir) }
// 32:
// 33:     context "when staged_path does not exist" do
// 34:       let(:staged_path) { Pathname("/nonexistent/path") }
// 35:
// 36:       it "does nothing" do
// 37:         expect { rename.perform_rename(staged_path) }.not_to raise_error
// 38:       end
// 39:     end
// 40:
// 41:     context "when using glob patterns" do
// 42:       let(:from) { "Test App*.pkg" }
// 43:       let(:to) { "Test App.pkg" }
// 44:
// 45:       before do
// 46:         (staged_path / "Test App v1.2.3.pkg").write("test content")
// 47:         (staged_path / "Test App v2.0.0.pkg").write("other content")
// 48:       end
// 49:
// 50:       it "renames the first matching file" do
// 51:         rename.perform_rename(staged_path)
// 52:
// 53:         expect(staged_path / "Test App.pkg").to exist
// 54:         expect((staged_path / "Test App.pkg").read).to eq("test content")
// 55:         expect(staged_path / "Test App v1.2.3.pkg").not_to exist
// 56:         expect(staged_path / "Test App v2.0.0.pkg").to exist
// 57:       end
// 58:     end
// 59:
// 60:     context "when using exact filenames" do
// 61:       let(:from) { "Exact File.dmg" }
// 62:       let(:to) { "New Name.dmg" }
// 63:
// 64:       before do
// 65:         (staged_path / "Exact File.dmg").write("dmg content")
// 66:       end
// 67:
// 68:       it "renames the exact file" do
// 69:         rename.perform_rename(staged_path)
// 70:
// 71:         expect(staged_path / "New Name.dmg").to exist
// 72:         expect((staged_path / "New Name.dmg").read).to eq("dmg content")
// 73:         expect(staged_path / "Exact File.dmg").not_to exist
// 74:       end
// 75:     end
// 76:
// 77:     context "when target is in a subdirectory" do
// 78:       let(:from) { "source.txt" }
// 79:       let(:to) { "subdir/target.txt" }
// 80:
// 81:       before do
// 82:         (staged_path / "source.txt").write("content")
// 83:       end
// 84:
// 85:       it "creates the subdirectory and renames the file" do
// 86:         rename.perform_rename(staged_path)
// 87:
// 88:         expect(staged_path / "subdir" / "target.txt").to exist
// 89:         expect((staged_path / "subdir" / "target.txt").read).to eq("content")
// 90:         expect(staged_path / "source.txt").not_to exist
// 91:       end
// 92:     end
// 93:
// 94:     context "when no files match the pattern" do
// 95:       let(:from) { "nonexistent*.pkg" }
// 96:       let(:to) { "target.pkg" }
// 97:
// 98:       it "does nothing" do
// 99:         rename.perform_rename(staged_path)
// 100:
// 101:         expect(staged_path / "target.pkg").not_to exist
// 102:       end
// 103:     end
// 104:
// 105:     context "when source file doesn't exist after glob" do
// 106:       let(:from) { "missing.txt" }
// 107:       let(:to) { "target.txt" }
// 108:
// 109:       it "does nothing" do
// 110:         expect { rename.perform_rename(staged_path) }.not_to raise_error
// 111:         expect(staged_path / "target.txt").not_to exist
// 112:       end
// 113:     end
// 114:   end
// 115: end
