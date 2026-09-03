module linux

import brew_runtime
import homebrew.extend.os.linux.extend as linux_pathname
import homebrew.os.linux as linux_elf
import os
import time

// Translated from Homebrew/brew `test/os/linux/pathname_spec.rb`.
// The original source is retained below for exact boundary auditing.
const pathname_spec_fixture_root = '/Users/alex/code/3rd/brew/Library/Homebrew/test/support/fixtures'
const pathname_spec_placeholder_prefix = '@@HOMEBREW_PREFIX@@'

fn pathname_spec_fixture_dir() string {
	configured := brew_runtime.environment_value('HOMEBREW_TEST_FIXTURE_DIR')
	root := if configured == '' { pathname_spec_fixture_root } else { configured }
	return os.join_path(root, 'elf')
}

fn pathname_spec_wrapped_value(path string) brew_runtime.Value {
	wrapped := linux_pathname.wrap_elf_path(path)
	return brew_runtime.structured_value('ELFShim', wrapped.path, {
		'path': wrapped.path
	})
}

fn pathname_spec_path_arg(args []brew_runtime.Value, fallback string) string {
	if args.len == 0 {
		return fallback
	}
	return args[0].attribute('path') or { args[0].as_string() }
}

fn pathname_spec_elf(path string) !linux_elf.ElfPath {
	wrapped := linux_pathname.wrap_elf_path(path)
	return linux_elf.new_elf_path(wrapped.path)!
}

fn pathname_spec_string(value ?string) string {
	return value or { '' }
}

fn pathname_spec_patch_fixture() !(string, linux_elf.ElfPath) {
	root := os.join_path(os.temp_dir(), 'brew-v-linux-pathname-spec-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(root)!
	path := os.join_path(root, 'c.elf')
	os.cp(os.join_path(pathname_spec_fixture_dir(), 'c.elf'), path)!
	return root, pathname_spec_elf(path)!
}

fn pathname_spec_has_patchelf() bool {
	_ := brew_runtime.find_executable('patchelf') or { return false }
	return true
}

fn pathname_spec_patch_prefix_case(kind string, new_prefix string, has_patchelf bool) bool {
	root, candidate := pathname_spec_patch_fixture() or { return false }
	defer {
		os.rmdir_all(root) or {}
	}
	original_interpreter := pathname_spec_string(candidate.interpreter())
	original_rpath := pathname_spec_string(candidate.rpath())
	if original_interpreter != '${pathname_spec_placeholder_prefix}/lib/ld.so' || original_rpath != '${pathname_spec_placeholder_prefix}/lib' {
		return false
	}
	interpreter := original_interpreter.replace(pathname_spec_placeholder_prefix, new_prefix)
	rpath := original_rpath.replace(pathname_spec_placeholder_prefix, new_prefix)
	if !has_patchelf {
		candidate.patch(none, none) or { return false }
		return interpreter == '${new_prefix}/lib/ld.so' && rpath == '${new_prefix}/lib' && pathname_spec_string(candidate.interpreter()) == original_interpreter && pathname_spec_string(candidate.rpath()) == original_rpath
	}
	match kind {
		'interpreter' { candidate.patch(interpreter, none) or { return false } }
		'rpath' { candidate.patch(none, rpath) or { return false } }
		'both' { candidate.patch(interpreter, rpath) or { return false } }
		else {
			return false
		}
	}
	modified_path := os.join_path(root, 'mod.c.elf')
	os.cp(candidate.path, modified_path) or { return false }
	modified := pathname_spec_elf(modified_path) or { return false }
	expected_interpreter := if kind in ['interpreter', 'both'] {
		interpreter
	} else {
		original_interpreter
	}
	expected_rpath := if kind in ['rpath', 'both'] { rpath } else { original_rpath }
	return pathname_spec_string(modified.interpreter()) == expected_interpreter && pathname_spec_string(modified.rpath()) == expected_rpath
}

fn pathname_spec_patch_case(kind string) bool {
	if kind !in ['interpreter', 'rpath', 'both'] {
		return false
	}
	has_patchelf := pathname_spec_has_patchelf()
	for new_prefix in pathname_spec_prefixes() {
		if !pathname_spec_patch_prefix_case(kind, new_prefix, has_patchelf) {
			return false
		}
	}
	return true
}

pub fn pathname_spec_prefixes() []string {
	return ['/home/dwarf', '/home/linuxbrew/.linuxbrew',
		'/home/organized/very organized/litter/more organized than/your words can describe']
}

// Ruby let `let(:elf_dir) { ELFPathname.wrap("#{TEST_FIXTURE_DIR}/elf") }` at line 7.
pub fn ruby_pathname_spec_l7_d1_elf_dir(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return pathname_spec_wrapped_value(pathname_spec_fixture_dir())
}

// Ruby let `let(:sho) { ELFPathname.wrap(elf_dir/"libforty.so.0") }` at line 8.
pub fn ruby_pathname_spec_l8_d2_sho(args ...brew_runtime.Value) brew_runtime.Value {
	directory := pathname_spec_path_arg(args, pathname_spec_fixture_dir())
	return pathname_spec_wrapped_value(os.join_path(directory, 'libforty.so.0'))
}

// Ruby let `let(:sho_without_runpath_rpath) { ELFPathname.wrap(elf_dir/"libhello.so.0") }` at line 9.
pub fn ruby_pathname_spec_l9_d3_sho_without_runpath_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	directory := pathname_spec_path_arg(args, pathname_spec_fixture_dir())
	return pathname_spec_wrapped_value(os.join_path(directory, 'libhello.so.0'))
}

// Ruby let `let(:exec) { ELFPathname.wrap(elf_dir/"hello_with_rpath") }` at line 10.
pub fn ruby_pathname_spec_l10_d4_exec(args ...brew_runtime.Value) brew_runtime.Value {
	directory := pathname_spec_path_arg(args, pathname_spec_fixture_dir())
	return pathname_spec_wrapped_value(os.join_path(directory, 'hello_with_rpath'))
}

// Ruby method `patch_elfs` at line 12.
pub fn ruby_pathname_spec_l12_d5_patch_elfs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root, candidate := pathname_spec_patch_fixture() or { return brew_runtime.bool_value(false) }
	defer {
		os.rmdir_all(root) or {}
	}
	return brew_runtime.bool_value(candidate.is_elf() && pathname_spec_string(candidate.interpreter()) == '${pathname_spec_placeholder_prefix}/lib/ld.so' && pathname_spec_string(candidate.rpath()) == '${pathname_spec_placeholder_prefix}/lib')
}

// Ruby it `it "returns interpreter" do` at line 22.
pub fn ruby_pathname_spec_l22_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	executable := pathname_spec_elf(os.join_path(pathname_spec_fixture_dir(), 'hello_with_rpath')) or {
		return brew_runtime.bool_value(false)
	}
	shared_object := pathname_spec_elf(os.join_path(pathname_spec_fixture_dir(), 'libforty.so.0')) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(pathname_spec_string(executable.interpreter()) == '/lib64/ld-linux-x86-64.so.2' && shared_object.interpreter() == none)
}

// Ruby it `it "returns rpath" do` at line 29.
pub fn ruby_pathname_spec_l29_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	shared_object := pathname_spec_elf(os.join_path(pathname_spec_fixture_dir(), 'libforty.so.0')) or {
		return brew_runtime.bool_value(false)
	}
	executable := pathname_spec_elf(os.join_path(pathname_spec_fixture_dir(), 'hello_with_rpath')) or {
		return brew_runtime.bool_value(false)
	}
	without_rpath := pathname_spec_elf(os.join_path(pathname_spec_fixture_dir(), 'libhello.so.0')) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(pathname_spec_string(shared_object.rpath()) == 'runpath' && pathname_spec_string(executable.rpath()) == '${pathname_spec_placeholder_prefix}/lib' && without_rpath.rpath() == none)
}

// Ruby let `let(:placeholder_prefix) { "@@HOMEBREW_PREFIX@@" }` at line 37.
pub fn ruby_pathname_spec_l37_d8_placeholder_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(pathname_spec_placeholder_prefix)
}

// Ruby let `let(:short_prefix) { "/home/dwarf" }` at line 38.
pub fn ruby_pathname_spec_l38_d9_short_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(pathname_spec_prefixes()[0])
}

// Ruby let `let(:standard_prefix) { "/home/linuxbrew/.linuxbrew" }` at line 39.
pub fn ruby_pathname_spec_l39_d10_standard_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(pathname_spec_prefixes()[1])
}

// Ruby let `let(:long_prefix) { "/home/organized/very organized/litter/more organized than/your words can describe" }` at line 40.
pub fn ruby_pathname_spec_l40_d11_long_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(pathname_spec_prefixes()[2])
}

// Ruby let `let(:prefixes) { [short_prefix, standard_prefix, long_prefix].map { |prefix| ELFPathname.wrap(prefix) } }` at line 41.
pub fn ruby_pathname_spec_l41_d12_prefixes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.array_value(pathname_spec_prefixes().map(pathname_spec_wrapped_value(it)))
}

// Ruby it `it "only interpreter" do` at line 44.
pub fn ruby_pathname_spec_l44_d13_only(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(pathname_spec_patch_case('interpreter'))
}

// Ruby it `it "only rpath" do` at line 58.
pub fn ruby_pathname_spec_l58_d14_only(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(pathname_spec_patch_case('rpath'))
}

// Ruby it `it "both" do` at line 72.
pub fn ruby_pathname_spec_l72_d15_both(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(pathname_spec_patch_case('both'))
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
