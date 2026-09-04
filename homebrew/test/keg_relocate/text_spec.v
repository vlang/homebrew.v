module keg_relocate

import ruby
import homebrew
import os

// Translated from Homebrew/brew `test/keg_relocate/text_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:keg) { described_class.new(HOMEBREW_CELLAR/"foo/1.0.0") }` at line 7.
pub fn ruby_text_spec_l7_d1_keg(args ...ruby.Value) ruby.Value {
	return homebrew.keg_relocation_keg_value(text_spec_keg(text_spec_temp('keg')))
}

// Ruby let `let(:dir) { mktmpdir }` at line 9.
pub fn ruby_text_spec_l9_d2_dir(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', text_spec_temp('dir'))
}

// Ruby let `let(:file) { dir/"file.txt" }` at line 10.
pub fn ruby_text_spec_l10_d3_file(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(text_spec_temp('dir'), 'file.txt'))
}

// Ruby let `let(:placeholder) { "@@PLACEHOLDER@@" }` at line 11.
pub fn ruby_text_spec_l11_d4_placeholder(args ...ruby.Value) ruby.Value {
	return ruby.string_value('@@PLACEHOLDER@@')
}

// Ruby method `setup_file(placeholders: false)` at line 17.
pub fn ruby_text_spec_l17_d5_setup_file(args ...ruby.Value) ruby.Value {
	dir := if args.len > 0 { args[0].as_string() } else { text_spec_temp('setup') }
	placeholders := args.len > 1 && args[1].bool_data
	file := text_spec_write_file(dir, placeholders) or { return ruby.object_value('SystemCallError', err.msg()) }
	return ruby.object_value('Pathname', file)
}

// Ruby method `setup_relocation(placeholders: false)` at line 28.
pub fn ruby_text_spec_l28_d6_setup_relocation(args ...ruby.Value) ruby.Value {
	dir := if args.len > 0 { args[0].as_string() } else { text_spec_temp('relocation') }
	return homebrew.keg_relocation_value(text_spec_relocation(dir, args.len > 1 && args[1].bool_data))
}

// Ruby specify `specify "::text_matches_in_file" do` at line 40.
pub fn ruby_text_spec_l40_d7_text_matches_in_file(args ...ruby.Value) ruby.Value {
	dir := text_spec_temp('matches')
	defer { os.rmdir_all(dir) or {} }
	file := text_spec_write_file(dir, false) or { return ruby.bool_value(false) }
	no_matches := homebrew.keg_text_matches_in_file(file, '@@PLACEHOLDER@@', [], [], []) or { return ruby.bool_value(false) }
	matches := homebrew.keg_text_matches_in_file(file, dir, [], [], []) or { return ruby.bool_value(false) }
	return ruby.bool_value(no_matches.len == 0 && matches.len == 2)
}

// Ruby specify `specify "with paths" do` at line 51.
pub fn ruby_text_spec_l51_d8_with(args ...ruby.Value) ruby.Value {
	dir := text_spec_temp('paths')
	defer { os.rmdir_all(dir) or {} }
	file := text_spec_write_file(dir, false) or { return ruby.bool_value(false) }
	keg := text_spec_keg(dir)
	_ := keg.replace_text_in_files(text_spec_relocation(dir, false), [file]) or { return ruby.bool_value(false) }
	expected := '@@PLACEHOLDER@@/file.txt\n/foo${dir}/file.txt\nfoo/bar:@@PLACEHOLDER@@/file.txt\nfoo/bar:/foo${dir}/file.txt\n@@PLACEHOLDER@@/bar.txt:@@PLACEHOLDER@@/baz.txt\n'
	return ruby.bool_value((os.read_file(file) or { return ruby.bool_value(false) }) == expected)
}

// Ruby specify `specify "with placeholders" do` at line 67.
pub fn ruby_text_spec_l67_d9_with(args ...ruby.Value) ruby.Value {
	dir := text_spec_temp('placeholders')
	defer { os.rmdir_all(dir) or {} }
	file := text_spec_write_file(dir, true) or { return ruby.bool_value(false) }
	keg := text_spec_keg(dir)
	_ := keg.replace_text_in_files(text_spec_relocation(dir, true), [file]) or { return ruby.bool_value(false) }
	expected := '${dir}/file.txt\n/foo${dir}/file.txt\nfoo/bar:${dir}/file.txt\nfoo/bar:/foo${dir}/file.txt\n${dir}/bar.txt:${dir}/baz.txt\n'
	return ruby.bool_value((os.read_file(file) or { return ruby.bool_value(false) }) == expected)
}

fn text_spec_temp(name string) string {
	path := os.join_path(os.temp_dir(), 'brew-v-keg-text-${name}-${os.getpid()}')
	os.rmdir_all(path) or {}
	os.mkdir_all(path) or {}
	return path
}

fn text_spec_keg(path string) homebrew.Keg {
	return homebrew.Keg{ path: path, name: 'foo', prefix: os.dir(path), cellar: os.dir(path) }
}

fn text_spec_write_file(dir string, placeholders bool) !string {
	os.mkdir_all(dir)!
	path := if placeholders { '@@PLACEHOLDER@@' } else { dir }
	file := os.join_path(dir, 'file.txt')
	os.write_file(file, '${path}/file.txt\n/foo${path}/file.txt\nfoo/bar:${path}/file.txt\nfoo/bar:/foo${path}/file.txt\n${path}/bar.txt:${path}/baz.txt\n')!
	return file
}

fn text_spec_relocation(dir string, placeholders bool) homebrew.KegRelocation {
	mut relocation := homebrew.new_keg_relocation()
	if placeholders {
		relocation.add_replacement_pair('dir', '@@PLACEHOLDER@@', dir)
	} else {
		relocation.add_replacement_pair_with_path('dir', dir, '@@PLACEHOLDER@@', true)
	}
	return relocation
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
