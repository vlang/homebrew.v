module keg_relocate

import brew_runtime

// Translated from Homebrew/brew `test/keg_relocate/relocation_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:prefix) { HOMEBREW_PREFIX.to_s }` at line 7.
pub fn ruby_relocation_spec_l7_d1_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prefix', ...args)
}

// Ruby let `let(:cellar) { HOMEBREW_CELLAR.to_s }` at line 8.
pub fn ruby_relocation_spec_l8_d2_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cellar', ...args)
}

// Ruby let `let(:repository) { HOMEBREW_REPOSITORY.to_s }` at line 9.
pub fn ruby_relocation_spec_l9_d3_repository(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repository', ...args)
}

// Ruby let `let(:library) { HOMEBREW_LIBRARY.to_s }` at line 10.
pub fn ruby_relocation_spec_l10_d4_library(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('library', ...args)
}

// Ruby let `let(:prefix_placeholder) { "@@HOMEBREW_PREFIX@@" }` at line 11.
pub fn ruby_relocation_spec_l11_d5_prefix_placeholder(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prefix_placeholder', ...args)
}

// Ruby let `let(:cellar_placeholder) { "@@HOMEBREW_CELLAR@@" }` at line 12.
pub fn ruby_relocation_spec_l12_d6_cellar_placeholder(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cellar_placeholder', ...args)
}

// Ruby let `let(:repository_placeholder) { "@@HOMEBREW_REPOSITORY@@" }` at line 13.
pub fn ruby_relocation_spec_l13_d7_repository_placeholder(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repository_placeholder', ...args)
}

// Ruby let `let(:library_placeholder) { "@@HOMEBREW_LIBRARY@@" }` at line 14.
pub fn ruby_relocation_spec_l14_d8_library_placeholder(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('library_placeholder', ...args)
}

// Ruby let `let(:escaped_prefix) { /(?:(?<=-F|-I|-L|-isystem)|(?<![a-zA-Z0-9]))#{Regexp.escape(HOMEBREW_PREFIX)}/o }` at line 15.
pub fn ruby_relocation_spec_l15_d9_escaped_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('escaped_prefix', ...args)
}

// Ruby let `let(:escaped_cellar) { /(?:(?<=-F|-I|-L|-isystem)|(?<![a-zA-Z0-9]))#{HOMEBREW_CELLAR}/o }` at line 16.
pub fn ruby_relocation_spec_l16_d10_escaped_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('escaped_cellar', ...args)
}

// Ruby method `setup_relocation` at line 18.
pub fn ruby_relocation_spec_l18_d11_setup_relocation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_relocation', ...args)
}

// Ruby specify `specify "#add_replacement_pair" do` at line 27.
pub fn ruby_relocation_spec_l27_d12_add_replacement_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#add_replacement_pair', ...args)
}

// Ruby specify `specify "#replace_text!" do` at line 36.
pub fn ruby_relocation_spec_l36_d13_replace_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#replace_text!', ...args)
}

// Ruby specify `specify "::path_to_regex" do` at line 62.
pub fn ruby_relocation_spec_l62_d14_path_to_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::path_to_regex', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "keg_relocate"
// 5:
// 6: RSpec.describe Keg::Relocation do
// 7:   let(:prefix) { HOMEBREW_PREFIX.to_s }
// 8:   let(:cellar) { HOMEBREW_CELLAR.to_s }
// 9:   let(:repository) { HOMEBREW_REPOSITORY.to_s }
// 10:   let(:library) { HOMEBREW_LIBRARY.to_s }
// 11:   let(:prefix_placeholder) { "@@HOMEBREW_PREFIX@@" }
// 12:   let(:cellar_placeholder) { "@@HOMEBREW_CELLAR@@" }
// 13:   let(:repository_placeholder) { "@@HOMEBREW_REPOSITORY@@" }
// 14:   let(:library_placeholder) { "@@HOMEBREW_LIBRARY@@" }
// 15:   let(:escaped_prefix) { /(?:(?<=-F|-I|-L|-isystem)|(?<![a-zA-Z0-9]))#{Regexp.escape(HOMEBREW_PREFIX)}/o }
// 16:   let(:escaped_cellar) { /(?:(?<=-F|-I|-L|-isystem)|(?<![a-zA-Z0-9]))#{HOMEBREW_CELLAR}/o }
// 17:
// 18:   def setup_relocation
// 19:     relocation = Keg::Relocation.new
// 20:     relocation.add_replacement_pair :prefix, prefix, prefix_placeholder, path: true
// 21:     relocation.add_replacement_pair :cellar, /#{cellar}/o, cellar_placeholder, path: true
// 22:     relocation.add_replacement_pair :repository_placeholder, repository_placeholder, repository
// 23:     relocation.add_replacement_pair :library_placeholder, library_placeholder, library
// 24:     relocation
// 25:   end
// 26:
// 27:   specify "#add_replacement_pair" do
// 28:     relocation = setup_relocation
// 29:
// 30:     expect(relocation.replacement_pair_for(:prefix)).to eq [escaped_prefix, prefix_placeholder]
// 31:     expect(relocation.replacement_pair_for(:cellar)).to eq [escaped_cellar, cellar_placeholder]
// 32:     expect(relocation.replacement_pair_for(:repository_placeholder)).to eq [repository_placeholder, repository]
// 33:     expect(relocation.replacement_pair_for(:library_placeholder)).to eq [library_placeholder, library]
// 34:   end
// 35:
// 36:   specify "#replace_text!" do
// 37:     relocation = setup_relocation
// 38:
// 39:     text = +"foo"
// 40:     relocation.replace_text!(text)
// 41:     expect(text).to eq "foo"
// 42:
// 43:     text = <<~TEXT
// 44:       #{prefix}/foo
// 45:       #{cellar}/foo
// 46:       foo#{prefix}/bar
// 47:       foo#{cellar}/bar
// 48:       #{repository_placeholder}/foo
// 49:       foo#{library_placeholder}/bar
// 50:     TEXT
// 51:     relocation.replace_text!(text)
// 52:     expect(text).to eq <<~REPLACED
// 53:       #{prefix_placeholder}/foo
// 54:       #{cellar_placeholder}/foo
// 55:       foo#{prefix}/bar
// 56:       foo#{cellar}/bar
// 57:       #{repository}/foo
// 58:       foo#{library}/bar
// 59:     REPLACED
// 60:   end
// 61:
// 62:   specify "::path_to_regex" do
// 63:     expect(described_class.path_to_regex(prefix)).to eq escaped_prefix
// 64:     expect(described_class.path_to_regex("foo.bar")).to eq(/(?:(?<=-F|-I|-L|-isystem)|(?<![a-zA-Z0-9]))foo\.bar/)
// 65:     expect(described_class.path_to_regex(/#{cellar}/o)).to eq escaped_cellar
// 66:     expect(described_class.path_to_regex(/foo.bar/)).to eq(/(?:(?<=-F|-I|-L|-isystem)|(?<![a-zA-Z0-9]))foo.bar/)
// 67:   end
// 68: end
