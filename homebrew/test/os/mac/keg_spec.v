module mac

import brew_runtime
import homebrew.extend.os.mac as keg_mac
import os

fn mac_keg_spec_path(name string) string {
	return os.join_path(os.temp_dir(), 'brew-v-mac-keg-${os.getpid()}-${name}')
}

fn mac_keg_spec_make_macho(path string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file_array(path, [u8(0xfe), 0xed, 0xfa, 0xce, 0, 0, 0, 0])!
}

fn mac_keg_spec_hardlinks(include_symlink bool) bool {
	root := mac_keg_spec_path(if include_symlink { 'symlink' } else { 'hardlink' })
	os.rmdir_all(root) or {}
	defer { os.rmdir_all(root) or {} }
	file := os.join_path(root, 'lib', 'i386.dylib')
	mac_keg_spec_make_macho(file) or { return false }
	os.link(file, os.join_path(root, 'lib', 'i386_hardlink.dylib')) or { return false }
	if include_symlink {
		os.symlink(file, os.join_path(root, 'lib', 'i386_symlink.dylib')) or { return false }
	}
	return keg_mac.mac_keg_mach_o_files(root).len == 1
}

fn mac_keg_spec_signer(file string) ! {
	if file == '' {
		return error('missing file')
	}
}

fn mac_keg_spec_invalid_signature_runner(command string,
	arguments []string) keg_mac.MacKegCommandResult {
	if command != 'codesign' {
		return keg_mac.MacKegCommandResult{}
	}
	if arguments.len > 0 && arguments[0] == '--verify' {
		return keg_mac.MacKegCommandResult{ stderr: '${arguments.last()}: invalid signature' }
	}
	return keg_mac.MacKegCommandResult{ success: true }
}

fn mac_keg_spec_unsigned_runner(command string,
	arguments []string) keg_mac.MacKegCommandResult {
	return keg_mac.MacKegCommandResult{
		stderr: if arguments.len > 0 {
			'${arguments.last()}: code object is not signed at all'} else {
			command}
	}
}

// Translated from Homebrew/brew `test/os/mac/keg_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:keg) { described_class.new(keg_path) }` at line 8.
pub fn ruby_keg_spec_l8_d1_keg(args ...brew_runtime.Value) brew_runtime.Value {
	path := if args.len > 0 { args[0].as_string() } else { mac_keg_spec_path('a/1.0') }
	return brew_runtime.structured_value('Keg', path, {
		'path': path
	})
}

// Ruby let `let(:keg_path) { HOMEBREW_CELLAR/"a/1.0" }` at line 13.
pub fn ruby_keg_spec_l13_d2_keg_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(mac_keg_spec_path('Cellar/a/1.0'))
}

// Ruby it `it "skips hardlinks" do` at line 19.
pub fn ruby_keg_spec_l19_d3_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(mac_keg_spec_hardlinks(false))
}

// Ruby it `it "isn't confused by symlinks" do` at line 27.
pub fn ruby_keg_spec_l27_d4_isn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(mac_keg_spec_hardlinks(true))
}

// Ruby let `let(:keg_path) { HOMEBREW_CELLAR/"a/1.0" }` at line 38.
pub fn ruby_keg_spec_l38_d5_keg_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(mac_keg_spec_path('Cellar/a/1.0'))
}

// Ruby let `let(:file) { "#{keg_path}/bin/test" }` at line 39.
pub fn ruby_keg_spec_l39_d6_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(os.join_path(mac_keg_spec_path('Cellar/a/1.0'), 'bin', 'test'))
}

// Ruby it `it "signs patched binaries using ruby-macho on Apple Silicon" do` at line 46.
pub fn ruby_keg_spec_l46_d7_signs(args ...brew_runtime.Value) brew_runtime.Value {
	file := mac_keg_spec_path('Cellar/a/1.0/bin/test')
	result := keg_mac.mac_keg_codesign_patched_binary(file, 11, true, mac_keg_spec_unsigned_runner, mac_keg_spec_signer)
	return brew_runtime.bool_value(result.signed && result.used_macho && result.attempted)
}

// Ruby it `it "re-signs binaries whose signature has been broken using codesign on Intel" do` at line 55.
pub fn ruby_keg_spec_l55_d8_re_signs(args ...brew_runtime.Value) brew_runtime.Value {
	file := mac_keg_spec_path('Cellar/a/1.0/bin/test')
	result := keg_mac.mac_keg_codesign_patched_binary(file, 11, false, mac_keg_spec_invalid_signature_runner, mac_keg_spec_signer)
	return brew_runtime.bool_value(result.signed && !result.used_macho && result.attempted)
}

// Ruby it `it "does not sign unsigned binaries on Intel" do` at line 69.
pub fn ruby_keg_spec_l69_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	file := mac_keg_spec_path('Cellar/a/1.0/bin/test')
	result := keg_mac.mac_keg_codesign_patched_binary(file, 11, false, mac_keg_spec_unsigned_runner, mac_keg_spec_signer)
	return brew_runtime.bool_value(!result.signed && !result.attempted && !result.used_macho)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "keg"
// 5: require "macho"
// 6:
// 7: RSpec.describe Keg do
// 8:   subject(:keg) { described_class.new(keg_path) }
// 9:
// 10:   include FileUtils
// 11:
// 12:   describe "#mach_o_files" do
// 13:     let(:keg_path) { HOMEBREW_CELLAR/"a/1.0" }
// 14:
// 15:     before { (keg_path/"lib").mkpath }
// 16:
// 17:     after { keg.unlink }
// 18:
// 19:     it "skips hardlinks" do
// 20:       cp dylib_path("i386"), keg_path/"lib/i386.dylib"
// 21:       ln keg_path/"lib/i386.dylib", keg_path/"lib/i386_hardlink.dylib"
// 22:
// 23:       keg.link
// 24:       expect(keg.mach_o_files.count).to eq(1)
// 25:     end
// 26:
// 27:     it "isn't confused by symlinks" do
// 28:       cp dylib_path("i386"), keg_path/"lib/i386.dylib"
// 29:       ln keg_path/"lib/i386.dylib", keg_path/"lib/i386_hardlink.dylib"
// 30:       ln_s keg_path/"lib/i386.dylib", keg_path/"lib/i386_symlink.dylib"
// 31:
// 32:       keg.link
// 33:       expect(keg.mach_o_files.count).to eq(1)
// 34:     end
// 35:   end
// 36:
// 37:   describe "#codesign_patched_binary" do
// 38:     let(:keg_path) { HOMEBREW_CELLAR/"a/1.0" }
// 39:     let(:file) { "#{keg_path}/bin/test" }
// 40:
// 41:     before do
// 42:       keg_path.mkpath
// 43:       allow(MacOS).to receive(:version).and_return(MacOSVersion.new("11"))
// 44:     end
// 45:
// 46:     it "signs patched binaries using ruby-macho on Apple Silicon" do
// 47:       allow(Hardware::CPU).to receive(:arm?).and_return(true)
// 48:       expect(keg).not_to receive(:system_command).with("codesign", any_args)
// 49:       expect(keg).not_to receive(:quiet_system).with("codesign", any_args)
// 50:       expect(MachO).to receive(:codesign!).with(file)
// 51:
// 52:       keg.codesign_patched_binary(file)
// 53:     end
// 54:
// 55:     it "re-signs binaries whose signature has been broken using codesign on Intel" do
// 56:       allow(Hardware::CPU).to receive(:arm?).and_return(false)
// 57:       expect(MachO).not_to receive(:codesign!)
// 58:       expect(keg).to receive(:system_command)
// 59:         .with("codesign", args: ["--verify", file], print_stderr: false)
// 60:         .and_return(instance_double(SystemCommand::Result, stderr: "#{file}: invalid signature"))
// 61:       expect(keg).to receive(:quiet_system)
// 62:         .with("codesign", "--sign", "-", "--force",
// 63:               "--preserve-metadata=entitlements,requirements,flags,runtime", file)
// 64:         .and_return(true)
// 65:
// 66:       keg.codesign_patched_binary(file)
// 67:     end
// 68:
// 69:     it "does not sign unsigned binaries on Intel" do
// 70:       allow(Hardware::CPU).to receive(:arm?).and_return(false)
// 71:       expect(MachO).not_to receive(:codesign!)
// 72:       expect(keg).to receive(:system_command)
// 73:         .with("codesign", args: ["--verify", file], print_stderr: false)
// 74:         .and_return(instance_double(SystemCommand::Result, stderr: "#{file}: code object is not signed at all"))
// 75:       expect(keg).not_to receive(:quiet_system).with("codesign", any_args)
// 76:
// 77:       keg.codesign_patched_binary(file)
// 78:     end
// 79:   end
// 80: end
