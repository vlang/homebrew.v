module utils

import brew_runtime

// Translated from Homebrew/brew `test/utils/inreplace_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:file) { Tempfile.new("test") }` at line 8.
pub fn ruby_inreplace_spec_l8_d1_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file', ...args)
}

// Ruby it `it "raises error if there are no files given to replace" do` at line 22.
pub fn ruby_inreplace_spec_l22_d2_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises error if there is nothing to replace" do` at line 28.
pub fn ruby_inreplace_spec_l28_d3_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises error if there is nothing to replace in block form" do` at line 34.
pub fn ruby_inreplace_spec_l34_d4_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises error if there is no make variables to replace" do` at line 43.
pub fn ruby_inreplace_spec_l43_d5_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "substitutes pathname within file" do` at line 52.
pub fn ruby_inreplace_spec_l52_d6_substitutes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('substitutes', ...args)
}

// Ruby it `it "substitutes all occurrences within file when `global: true`" do` at line 65.
pub fn ruby_inreplace_spec_l65_d7_substitutes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('substitutes', ...args)
}

// Ruby it `it "substitutes only the first occurrence when `global: false`" do` at line 75.
pub fn ruby_inreplace_spec_l75_d8_substitutes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('substitutes', ...args)
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
