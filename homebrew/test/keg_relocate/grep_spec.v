module keg_relocate

import brew_runtime
import homebrew
import os

// Translated from Homebrew/brew `test/keg_relocate/grep_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:keg) { described_class.new(HOMEBREW_CELLAR/"foo/1.0.0") }` at line 7.
pub fn ruby_grep_spec_l7_d1_keg(args ...brew_runtime.Value) brew_runtime.Value {
	dir := grep_spec_temp('keg')
	return homebrew.keg_relocation_keg_value(grep_spec_keg(dir))
}

// Ruby let `let(:dir) { HOMEBREW_CELLAR/"foo/1.0.0" }` at line 9.
pub fn ruby_grep_spec_l9_d2_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', grep_spec_temp('dir'))
}

// Ruby let `let(:text_file) { dir/"file.txt" }` at line 10.
pub fn ruby_grep_spec_l10_d3_text_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', os.join_path(grep_spec_temp('dir'), 'file.txt'))
}

// Ruby let `let(:binary_file) { dir/"file.bin" }` at line 11.
pub fn ruby_grep_spec_l11_d4_binary_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', os.join_path(grep_spec_temp('dir'), 'file.bin'))
}

// Ruby method `setup_text_file` at line 17.
pub fn ruby_grep_spec_l17_d5_setup_text_file(args ...brew_runtime.Value) brew_runtime.Value {
	dir := if args.len > 0 { args[0].as_string() } else { grep_spec_temp('text') }
	file := grep_spec_write_text(dir) or { return brew_runtime.object_value('SystemCallError', err.msg()) }
	return brew_runtime.object_value('Pathname', file)
}

// Ruby method `setup_binary_file` at line 27.
pub fn ruby_grep_spec_l27_d6_setup_binary_file(args ...brew_runtime.Value) brew_runtime.Value {
	dir := if args.len > 0 { args[0].as_string() } else { grep_spec_temp('binary') }
	file := os.join_path(dir, 'file.bin')
	os.write_file_array(file, [u8(0), `\n`]) or { return brew_runtime.object_value('SystemCallError', err.msg()) }
	return brew_runtime.object_value('Pathname', file)
}

// Ruby specify `specify "find string matches to path" do` at line 34.
pub fn ruby_grep_spec_l34_d7_find(args ...brew_runtime.Value) brew_runtime.Value {
	dir := grep_spec_temp('find')
	defer { os.rmdir_all(dir) or {} }
	_ := grep_spec_write_text(dir) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(homebrew.keg_each_unique_file_matching(grep_spec_keg(dir), dir).len == 1)
}

// Ruby specify `specify "test if file has null bytes" do` at line 47.
pub fn ruby_grep_spec_l47_d8_test(args ...brew_runtime.Value) brew_runtime.Value {
	dir := grep_spec_temp('test')
	defer { os.rmdir_all(dir) or {} }
	binary := os.join_path(dir, 'file.bin')
	os.write_file_array(binary, [u8(0), `\n`]) or { return brew_runtime.bool_value(false) }
	text := grep_spec_write_text(dir) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(homebrew.keg_binary_file(binary) && !homebrew.keg_binary_file(text))
}

fn grep_spec_temp(name string) string {
	path := os.join_path(os.temp_dir(), 'brew-v-keg-grep-${name}-${os.getpid()}')
	os.rmdir_all(path) or {}
	os.mkdir_all(path) or {}
	return path
}

fn grep_spec_keg(path string) homebrew.Keg {
	return homebrew.Keg{ path: path, name: 'foo', prefix: os.dir(path), cellar: os.dir(path) }
}

fn grep_spec_write_text(dir string) !string {
	os.mkdir_all(dir)!
	file := os.join_path(dir, 'file.txt')
	os.write_file(file, '${dir}/file.txt\n/foo${dir}/file.txt\nfoo/bar:${dir}/file.txt\nfoo/bar:/foo${dir}/file.txt\n${dir}/bar.txt:${dir}/baz.txt\n')!
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
// 10:   let(:text_file) { dir/"file.txt" }
// 11:   let(:binary_file) { dir/"file.bin" }
// 12:
// 13:   before do
// 14:     dir.mkpath
// 15:   end
// 16:
// 17:   def setup_text_file
// 18:     text_file.atomic_write <<~EOS
// 19:       #{dir}/file.txt
// 20:       /foo#{dir}/file.txt
// 21:       foo/bar:#{dir}/file.txt
// 22:       foo/bar:/foo#{dir}/file.txt
// 23:       #{dir}/bar.txt:#{dir}/baz.txt
// 24:     EOS
// 25:   end
// 26:
// 27:   def setup_binary_file
// 28:     binary_file.atomic_write <<~EOS
// 29:       \x00
// 30:     EOS
// 31:   end
// 32:
// 33:   describe "#each_unique_file_matching" do
// 34:     specify "find string matches to path" do
// 35:       setup_text_file
// 36:
// 37:       string_matches = Set.new
// 38:       keg.each_unique_file_matching(dir) do |file|
// 39:         string_matches << file
// 40:       end
// 41:
// 42:       expect(string_matches.size).to eq 1
// 43:     end
// 44:   end
// 45:
// 46:   describe "#binary_file?" do
// 47:     specify "test if file has null bytes" do
// 48:       setup_binary_file
// 49:
// 50:       expect(keg.binary_file?(binary_file)).to be true
// 51:
// 52:       setup_text_file
// 53:
// 54:       expect(keg.binary_file?(text_file)).to be false
// 55:     end
// 56:   end
// 57: end
