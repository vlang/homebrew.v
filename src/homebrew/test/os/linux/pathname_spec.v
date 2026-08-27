module linux

import brew_runtime

// Translated from Homebrew/brew `test/os/linux/pathname_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:elf_dir) { ELFPathname.wrap("#{TEST_FIXTURE_DIR}/elf") }` at line 7.
pub fn ruby_pathname_spec_l7_d1_elf_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('elf_dir', ...args)
}

// Ruby let `let(:sho) { ELFPathname.wrap(elf_dir/"libforty.so.0") }` at line 8.
pub fn ruby_pathname_spec_l8_d2_sho(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sho', ...args)
}

// Ruby let `let(:sho_without_runpath_rpath) { ELFPathname.wrap(elf_dir/"libhello.so.0") }` at line 9.
pub fn ruby_pathname_spec_l9_d3_sho_without_runpath_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sho_without_runpath_rpath', ...args)
}

// Ruby let `let(:exec) { ELFPathname.wrap(elf_dir/"hello_with_rpath") }` at line 10.
pub fn ruby_pathname_spec_l10_d4_exec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exec', ...args)
}

// Ruby method `patch_elfs` at line 12.
pub fn ruby_pathname_spec_l12_d5_patch_elfs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_elfs', ...args)
}

// Ruby it `it "returns interpreter" do` at line 22.
pub fn ruby_pathname_spec_l22_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns rpath" do` at line 29.
pub fn ruby_pathname_spec_l29_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:placeholder_prefix) { "@@HOMEBREW_PREFIX@@" }` at line 37.
pub fn ruby_pathname_spec_l37_d8_placeholder_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('placeholder_prefix', ...args)
}

// Ruby let `let(:short_prefix) { "/home/dwarf" }` at line 38.
pub fn ruby_pathname_spec_l38_d9_short_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('short_prefix', ...args)
}

// Ruby let `let(:standard_prefix) { "/home/linuxbrew/.linuxbrew" }` at line 39.
pub fn ruby_pathname_spec_l39_d10_standard_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('standard_prefix', ...args)
}

// Ruby let `let(:long_prefix) { "/home/organized/very organized/litter/more organized than/your words can describe" }` at line 40.
pub fn ruby_pathname_spec_l40_d11_long_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('long_prefix', ...args)
}

// Ruby let `let(:prefixes) { [short_prefix, standard_prefix, long_prefix].map { |prefix| ELFPathname.wrap(prefix) } }` at line 41.
pub fn ruby_pathname_spec_l41_d12_prefixes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prefixes', ...args)
}

// Ruby it `it "only interpreter" do` at line 44.
pub fn ruby_pathname_spec_l44_d13_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby it `it "only rpath" do` at line 58.
pub fn ruby_pathname_spec_l58_d14_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby it `it "both" do` at line 72.
pub fn ruby_pathname_spec_l72_d15_both(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('both', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/pathname"
// 5:
// 6: RSpec.describe Pathname do
// 7:   let(:elf_dir) { ELFPathname.wrap("#{TEST_FIXTURE_DIR}/elf") }
// 8:   let(:sho) { ELFPathname.wrap(elf_dir/"libforty.so.0") }
// 9:   let(:sho_without_runpath_rpath) { ELFPathname.wrap(elf_dir/"libhello.so.0") }
// 10:   let(:exec) { ELFPathname.wrap(elf_dir/"hello_with_rpath") }
// 11:
// 12:   def patch_elfs
// 13:     mktmpdir do |tmp_dir|
// 14:       %w[c.elf].each do |elf|
// 15:         FileUtils.cp(elf_dir/elf, tmp_dir/elf)
// 16:         yield ELFPathname.wrap(tmp_dir/elf)
// 17:       end
// 18:     end
// 19:   end
// 20:
// 21:   describe "#interpreter" do
// 22:     it "returns interpreter" do
// 23:       expect(exec.interpreter).to eq "/lib64/ld-linux-x86-64.so.2"
// 24:       expect(sho.interpreter).to be_nil
// 25:     end
// 26:   end
// 27:
// 28:   describe "#rpath" do
// 29:     it "returns rpath" do
// 30:       expect(sho.rpath).to eq "runpath"
// 31:       expect(exec.rpath).to eq "@@HOMEBREW_PREFIX@@/lib"
// 32:       expect(sho_without_runpath_rpath.rpath).to be_nil
// 33:     end
// 34:   end
// 35:
// 36:   describe "#patch!" do
// 37:     let(:placeholder_prefix) { "@@HOMEBREW_PREFIX@@" }
// 38:     let(:short_prefix) { "/home/dwarf" }
// 39:     let(:standard_prefix) { "/home/linuxbrew/.linuxbrew" }
// 40:     let(:long_prefix) { "/home/organized/very organized/litter/more organized than/your words can describe" }
// 41:     let(:prefixes) { [short_prefix, standard_prefix, long_prefix].map { |prefix| ELFPathname.wrap(prefix) } }
// 42:
// 43:     # file is copied as modified_elf to avoid caching issues
// 44:     it "only interpreter" do
// 45:       prefixes.each do |new_prefix|
// 46:         patch_elfs do |elf|
// 47:           interpreter = elf.interpreter.gsub(placeholder_prefix, new_prefix)
// 48:           elf.patch!(interpreter:)
// 49:
// 50:           modified_elf = ELFPathname.wrap(elf.dirname/"mod.#{elf.basename}")
// 51:           FileUtils.cp(elf, modified_elf)
// 52:           expect(modified_elf.interpreter).to eq interpreter
// 53:           expect(modified_elf.rpath).to eq "@@HOMEBREW_PREFIX@@/lib"
// 54:         end
// 55:       end
// 56:     end
// 57:
// 58:     it "only rpath" do
// 59:       prefixes.each do |new_prefix|
// 60:         patch_elfs do |elf|
// 61:           rpath = elf.rpath.gsub(placeholder_prefix, new_prefix)
// 62:           elf.patch!(rpath:)
// 63:
// 64:           modified_elf = ELFPathname.wrap(elf.dirname/"mod.#{elf.basename}")
// 65:           FileUtils.cp(elf, modified_elf)
// 66:           expect(modified_elf.interpreter).to eq "@@HOMEBREW_PREFIX@@/lib/ld.so"
// 67:           expect(modified_elf.rpath).to eq rpath
// 68:         end
// 69:       end
// 70:     end
// 71:
// 72:     it "both" do
// 73:       prefixes.each do |new_prefix|
// 74:         patch_elfs do |elf|
// 75:           interpreter = elf.interpreter.gsub(placeholder_prefix, new_prefix)
// 76:           rpath = elf.rpath.gsub(placeholder_prefix, new_prefix)
// 77:           elf.patch!(interpreter:, rpath:)
// 78:
// 79:           modified_elf = ELFPathname.wrap(elf.dirname/"mod.#{elf.basename}")
// 80:           FileUtils.cp(elf, modified_elf)
// 81:           expect(modified_elf.interpreter).to eq interpreter
// 82:           expect(modified_elf.rpath).to eq rpath
// 83:         end
// 84:       end
// 85:     end
// 86:   end
// 87: end
