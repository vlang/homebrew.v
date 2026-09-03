module utils

import homebrew.utils as inreplace_core
import os

// Translated from Homebrew/brew `test/utils/inreplace_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn inreplace_spec_fixture(name string) !string {
	path := os.join_path(os.temp_dir(), 'brew-v-inreplace-${os.getpid()}-${name}')
	os.rm(path) or {}
	os.write_file(path, 'a\nb\nc\naa\n')!
	return path
}

fn inreplace_spec_missing_block(mut buffer inreplace_core.InreplaceBuffer) {
	buffer.gsub('d', 'f', true)
}

fn inreplace_spec_missing_make_vars(mut buffer inreplace_core.InreplaceBuffer) {
	buffer.change_make_var('VAR', 'value')
	buffer.remove_make_var(['VAR2'])
}

fn inreplace_spec_pathname_block(mut buffer inreplace_core.InreplaceBuffer) {
	buffer.gsub('b', 'f', true)
}

// Ruby let `let(:file) { Tempfile.new("test") }` at line 8.
pub fn ruby_inreplace_spec_l8_d1_file() !string {
	return inreplace_spec_fixture('let')
}

// Ruby it `it "raises error if there are no files given to replace" do` at line 22.
pub fn ruby_inreplace_spec_l22_d2_raises() bool {
	if _ := inreplace_core.inreplace([]string{}, 'd', 'f', inreplace_core.InreplaceOptions{}, none) {
		return false
	} else {
		return err.msg().contains('inreplace failed') && err.msg().contains('`paths` was empty')
	}
}

// Ruby it `it "raises error if there is nothing to replace" do` at line 28.
pub fn ruby_inreplace_spec_l28_d3_raises() !bool {
	path := inreplace_spec_fixture('missing')!
	defer {
		os.rm(path) or {}
	}
	if _ := inreplace_core.inreplace([path], 'd', 'f', inreplace_core.InreplaceOptions{}, none) {
		return false
	} else {
		return err.msg().contains('expected replacement of "d" with "f"')
	}
}

// Ruby it `it "raises error if there is nothing to replace in block form" do` at line 34.
pub fn ruby_inreplace_spec_l34_d4_raises() !bool {
	path := inreplace_spec_fixture('missing-block')!
	defer {
		os.rm(path) or {}
	}
	if _ := inreplace_core.inreplace([path], none, none, inreplace_core.InreplaceOptions{}, inreplace_spec_missing_block) {
		return false
	} else {
		return err.msg().contains('expected replacement of "d" with "f"')
	}
}

// Ruby it `it "raises error if there is no make variables to replace" do` at line 43.
pub fn ruby_inreplace_spec_l43_d5_raises() !bool {
	path := inreplace_spec_fixture('missing-make')!
	defer {
		os.rm(path) or {}
	}
	if _ := inreplace_core.inreplace([path], none, none, inreplace_core.InreplaceOptions{}, inreplace_spec_missing_make_vars) {
		return false
	} else {
		return err.msg().contains('expected to change "VAR" to "value"') && err.msg().contains('expected to remove "VAR2"')
	}
}

// Ruby it `it "substitutes pathname within file" do` at line 52.
pub fn ruby_inreplace_spec_l52_d6_substitutes() !bool {
	path := inreplace_spec_fixture('pathname')!
	defer {
		os.rm(path) or {}
	}
	inreplace_core.inreplace([path], none, none, inreplace_core.InreplaceOptions{}, inreplace_spec_pathname_block)!
	return os.read_file(path)! == 'a\nf\nc\naa\n'
}

// Ruby it `it "substitutes all occurrences within file when `global: true`" do` at line 65.
pub fn ruby_inreplace_spec_l65_d7_substitutes() !bool {
	path := inreplace_spec_fixture('global')!
	defer {
		os.rm(path) or {}
	}
	inreplace_core.inreplace([path], 'a', 'foo', inreplace_core.InreplaceOptions{}, none)!
	return os.read_file(path)! == 'foo\nb\nc\nfoofoo\n'
}

// Ruby it `it "substitutes only the first occurrence when `global: false`" do` at line 75.
pub fn ruby_inreplace_spec_l75_d8_substitutes() !bool {
	path := inreplace_spec_fixture('first')!
	defer {
		os.rm(path) or {}
	}
	inreplace_core.inreplace([path], 'a', 'foo', inreplace_core.InreplaceOptions{
		global: false
	}, none)!
	return os.read_file(path)! == 'foo\nb\nc\naa\n'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "tempfile"
// 5: require "utils/inreplace"
// 6:
// 7: RSpec.describe Utils::Inreplace do
// 8:   let(:file) { Tempfile.new("test") }
// 9:
// 10:   before do
// 11:     File.binwrite(file, <<~EOS)
// 12:       a
// 13:       b
// 14:       c
// 15:       aa
// 16:     EOS
// 17:   end
// 18:
// 19:   after { file.unlink }
// 20:
// 21:   describe ".inreplace" do
// 22:     it "raises error if there are no files given to replace" do
// 23:       expect do
// 24:         described_class.inreplace [], "d", "f"
// 25:       end.to raise_error(Utils::Inreplace::Error)
// 26:     end
// 27:
// 28:     it "raises error if there is nothing to replace" do
// 29:       expect do
// 30:         described_class.inreplace file.path, "d", "f"
// 31:       end.to raise_error(Utils::Inreplace::Error)
// 32:     end
// 33:
// 34:     it "raises error if there is nothing to replace in block form" do
// 35:       expect do
// 36:         described_class.inreplace(file.path) do |s|
// 37:           # Using `gsub!` here is what we want, and it's only a test.
// 38:           s.gsub!("d", "f") # rubocop:disable Performance/StringReplacement
// 39:         end
// 40:       end.to raise_error(Utils::Inreplace::Error)
// 41:     end
// 42:
// 43:     it "raises error if there is no make variables to replace" do
// 44:       expect do
// 45:         described_class.inreplace(file.path) do |s|
// 46:           s.change_make_var! "VAR", "value"
// 47:           s.remove_make_var! "VAR2"
// 48:         end
// 49:       end.to raise_error(Utils::Inreplace::Error)
// 50:     end
// 51:
// 52:     it "substitutes pathname within file" do
// 53:       # For a specific instance of this, see https://github.com/Homebrew/homebrew-core/blob/a8b0b10/Formula/loki.rb#L48
// 54:       described_class.inreplace(file.path) do |s|
// 55:         s.gsub!(Pathname("b"), Pathname("f"))
// 56:       end
// 57:       expect(File.binread(file)).to eq <<~EOS
// 58:         a
// 59:         f
// 60:         c
// 61:         aa
// 62:       EOS
// 63:     end
// 64:
// 65:     it "substitutes all occurrences within file when `global: true`" do
// 66:       described_class.inreplace(file.path, "a", "foo")
// 67:       expect(File.binread(file)).to eq <<~EOS
// 68:         foo
// 69:         b
// 70:         c
// 71:         foofoo
// 72:       EOS
// 73:     end
// 74:
// 75:     it "substitutes only the first occurrence when `global: false`" do
// 76:       described_class.inreplace(file.path, "a", "foo", global: false)
// 77:       expect(File.binread(file)).to eq <<~EOS
// 78:         foo
// 79:         b
// 80:         c
// 81:         aa
// 82:       EOS
// 83:     end
// 84:   end
// 85: end
