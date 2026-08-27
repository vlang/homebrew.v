module keg_relocate

import brew_runtime

// Translated from Homebrew/brew `test/keg_relocate/text_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:keg) { described_class.new(HOMEBREW_CELLAR/"foo/1.0.0") }` at line 7.
pub fn ruby_text_spec_l7_d1_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg', ...args)
}

// Ruby let `let(:dir) { mktmpdir }` at line 9.
pub fn ruby_text_spec_l9_d2_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dir', ...args)
}

// Ruby let `let(:file) { dir/"file.txt" }` at line 10.
pub fn ruby_text_spec_l10_d3_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file', ...args)
}

// Ruby let `let(:placeholder) { "@@PLACEHOLDER@@" }` at line 11.
pub fn ruby_text_spec_l11_d4_placeholder(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('placeholder', ...args)
}

// Ruby method `setup_file(placeholders: false)` at line 17.
pub fn ruby_text_spec_l17_d5_setup_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_file', ...args)
}

// Ruby method `setup_relocation(placeholders: false)` at line 28.
pub fn ruby_text_spec_l28_d6_setup_relocation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_relocation', ...args)
}

// Ruby specify `specify "::text_matches_in_file" do` at line 40.
pub fn ruby_text_spec_l40_d7_text_matches_in_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::text_matches_in_file', ...args)
}

// Ruby specify `specify "with paths" do` at line 51.
pub fn ruby_text_spec_l51_d8_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with', ...args)
}

// Ruby specify `specify "with placeholders" do` at line 67.
pub fn ruby_text_spec_l67_d9_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "keg_relocate"
// 5:
// 6: RSpec.describe Keg do
// 7:   subject(:keg) { described_class.new(HOMEBREW_CELLAR/"foo/1.0.0") }
// 8:
// 9:   let(:dir) { mktmpdir }
// 10:   let(:file) { dir/"file.txt" }
// 11:   let(:placeholder) { "@@PLACEHOLDER@@" }
// 12:
// 13:   before do
// 14:     (HOMEBREW_CELLAR/"foo/1.0.0").mkpath
// 15:   end
// 16:
// 17:   def setup_file(placeholders: false)
// 18:     path = placeholders ? placeholder : dir
// 19:     file.atomic_write <<~EOS
// 20:       #{path}/file.txt
// 21:       /foo#{path}/file.txt
// 22:       foo/bar:#{path}/file.txt
// 23:       foo/bar:/foo#{path}/file.txt
// 24:       #{path}/bar.txt:#{path}/baz.txt
// 25:     EOS
// 26:   end
// 27:
// 28:   def setup_relocation(placeholders: false)
// 29:     relocation = Keg::Relocation.new
// 30:
// 31:     if placeholders
// 32:       relocation.add_replacement_pair :dir, placeholder, dir.to_s
// 33:     else
// 34:       relocation.add_replacement_pair :dir, dir.to_s, placeholder, path: true
// 35:     end
// 36:
// 37:     relocation
// 38:   end
// 39:
// 40:   specify "::text_matches_in_file" do
// 41:     setup_file
// 42:
// 43:     result = described_class.text_matches_in_file(file, placeholder, [], [], nil)
// 44:     expect(result.count).to eq 0
// 45:
// 46:     result = described_class.text_matches_in_file(file, dir.to_s, [], [], nil)
// 47:     expect(result.count).to eq 2
// 48:   end
// 49:
// 50:   describe "#replace_text_in_files" do
// 51:     specify "with paths" do
// 52:       setup_file
// 53:       relocation = setup_relocation
// 54:
// 55:       keg.replace_text_in_files(relocation, files: [file])
// 56:       contents = File.read file
// 57:
// 58:       expect(contents).to eq <<~EOS
// 59:         #{placeholder}/file.txt
// 60:         /foo#{dir}/file.txt
// 61:         foo/bar:#{placeholder}/file.txt
// 62:         foo/bar:/foo#{dir}/file.txt
// 63:         #{placeholder}/bar.txt:#{placeholder}/baz.txt
// 64:       EOS
// 65:     end
// 66:
// 67:     specify "with placeholders" do
// 68:       setup_file placeholders: true
// 69:       relocation = setup_relocation placeholders: true
// 70:
// 71:       keg.replace_text_in_files(relocation, files: [file])
// 72:       contents = File.read file
// 73:
// 74:       expect(contents).to eq <<~EOS
// 75:         #{dir}/file.txt
// 76:         /foo#{dir}/file.txt
// 77:         foo/bar:#{dir}/file.txt
// 78:         foo/bar:/foo#{dir}/file.txt
// 79:         #{dir}/bar.txt:#{dir}/baz.txt
// 80:       EOS
// 81:     end
// 82:   end
// 83: end
