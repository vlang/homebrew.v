module keg_relocate

import brew_runtime
import homebrew
import os

// Translated from Homebrew/brew `test/keg_relocate/binary_relocation_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:keg) { described_class.new(HOMEBREW_CELLAR/"foo/1.0.0") }` at line 7.
pub fn ruby_binary_relocation_spec_l7_d1_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return homebrew.keg_relocation_keg_value(binary_spec_keg(binary_spec_temp('keg')))
}

// Ruby let `let(:dir) { HOMEBREW_CELLAR/"foo/1.0.0" }` at line 9.
pub fn ruby_binary_relocation_spec_l9_d2_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', binary_spec_temp('dir'))
}

// Ruby let `let(:newdir) { HOMEBREW_CELLAR/"foo" }` at line 10.
pub fn ruby_binary_relocation_spec_l10_d3_newdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', os.dir(binary_spec_temp('dir')))
}

// Ruby let `let(:binary_file) { dir/"file.bin" }` at line 11.
pub fn ruby_binary_relocation_spec_l11_d4_binary_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', os.join_path(binary_spec_temp('dir'), 'file.bin'))
}

// Ruby method `setup_binary_file` at line 17.
pub fn ruby_binary_relocation_spec_l17_d5_setup_binary_file(args ...brew_runtime.Value) brew_runtime.Value {
	dir := if args.len > 0 { args[0].as_string() } else { binary_spec_temp('setup') }
	file := binary_spec_write(dir) or { return brew_runtime.object_value('SystemCallError', err.msg()) }
	return brew_runtime.object_value('Pathname', file)
}

// Ruby specify `specify "replace prefix in binary files" do` at line 24.
pub fn ruby_binary_relocation_spec_l24_d6_replace(args ...brew_runtime.Value) brew_runtime.Value {
	dir := binary_spec_temp('replace')
	defer { os.rmdir_all(os.dir(dir)) or {} }
	newdir := os.dir(dir)
	_ := binary_spec_write(dir) or { return brew_runtime.bool_value(false) }
	keg := binary_spec_keg(dir)
	_ := keg.relocate_build_prefix(dir, newdir) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(homebrew.keg_each_unique_file_matching(keg, dir).len == 0 && homebrew.keg_each_unique_file_matching(keg, newdir).len == 1)
}

fn binary_spec_temp(name string) string {
	path := os.join_path(os.temp_dir(), 'brew-v-keg-binary-${name}-${os.getpid()}', '1.0.0')
	os.rmdir_all(os.dir(os.dir(path))) or {}
	os.mkdir_all(path) or {}
	return path
}

fn binary_spec_keg(path string) homebrew.Keg {
	return homebrew.Keg{ path: path, name: 'foo', prefix: os.dir(os.dir(path)), cellar: os.dir(os.dir(path)) }
}

fn binary_spec_write(dir string) !string {
	os.mkdir_all(dir)!
	file := os.join_path(dir, 'file.bin')
	mut bytes := [u8(0)]
	bytes << dir.bytes()
	bytes << u8(0)
	bytes << `\n`
	os.write_file_array(file, bytes)!
	return file
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
// 9:   let(:dir) { HOMEBREW_CELLAR/"foo/1.0.0" }
// 10:   let(:newdir) { HOMEBREW_CELLAR/"foo" }
// 11:   let(:binary_file) { dir/"file.bin" }
// 12:
// 13:   before do
// 14:     dir.mkpath
// 15:   end
// 16:
// 17:   def setup_binary_file
// 18:     binary_file.atomic_write <<~EOS
// 19:       \x00#{dir}\x00
// 20:     EOS
// 21:   end
// 22:
// 23:   describe "#relocate_build_prefix" do
// 24:     specify "replace prefix in binary files" do
// 25:       setup_binary_file
// 26:
// 27:       keg.relocate_build_prefix(keg, dir, newdir)
// 28:
// 29:       old_prefix_matches = Set.new
// 30:       keg.each_unique_file_matching(dir) do |file|
// 31:         old_prefix_matches << file
// 32:       end
// 33:
// 34:       expect(old_prefix_matches.size).to eq 0
// 35:
// 36:       new_prefix_matches = Set.new
// 37:       keg.each_unique_file_matching(newdir) do |file|
// 38:         new_prefix_matches << file
// 39:       end
// 40:
// 41:       expect(new_prefix_matches.size).to eq 1
// 42:     end
// 43:   end
// 44: end
