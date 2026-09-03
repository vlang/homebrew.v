module test

import brew_runtime
import homebrew.unpack_strategy
import os
import time

// Translated from Homebrew/brew `test/unpack_strategy_spec.rb`.
// The original source is retained below for exact boundary auditing.
const unpack_strategy_spec_payload = 'This file was inside a GZIP inside a BZIP2.'

fn unpack_strategy_spec_temp_dir(label string) !string {
	path := os.join_path(os.temp_dir(), 'brew-v-unpack-strategy-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(path)!
	return path
}

fn unpack_strategy_spec_command(program string, arguments []string) ! {
	executable := brew_runtime.find_executable(program)!
	result := brew_runtime.run_command(executable, arguments)
	if result.exit_code != 0 {
		return error('${program}: ${result.output}')
	}
}

fn unpack_strategy_spec_nested_archive() !string {
	root := unpack_strategy_spec_temp_dir('nested')!
	path := os.join_path(root, 'file')
	os.write_file(path, unpack_strategy_spec_payload)!
	unpack_strategy_spec_command('gzip', [path])!
	unpack_strategy_spec_command('bzip2', [path + '.gz'])!
	return path + '.gz.bz2'
}

fn unpack_strategy_spec_tar_archive(writable bool) !string {
	root := unpack_strategy_spec_temp_dir(if writable { 'tar-writable' } else { 'tar-readonly' })!
	source := os.join_path(root, 'source')
	directories := os.join_path(source, 'A/B/C')
	executable := os.join_path(directories, 'executable')
	os.mkdir_all(directories)!
	os.write_file(executable, '')!
	os.chmod(executable, 0o555)!
	if !writable {
		os.chmod(directories, 0o555)!
	}
	archive := os.join_path(root, 'file.tar')
	unpack_strategy_spec_command('tar', ['--create', '--file', archive, '--directory', source, 'A/'])!
	if !writable {
		os.chmod(directories, 0o755)!
	}
	return archive
}

fn unpack_strategy_spec_basename_archive() !string {
	root := unpack_strategy_spec_temp_dir('basename')!
	source := os.join_path(root, 'source')
	os.mkdir_all(source)!
	os.write_file(os.join_path(source, 'file.txt'), '')!
	archive := os.join_path(root, 'file.xyz')
	unpack_strategy_spec_command('tar', ['--create', '--file', archive, '--directory', source,
		'file.txt'])!
	return archive
}

fn unpack_strategy_spec_path_arg(args []brew_runtime.Value, fallback fn() !string) !string {
	if args.len > 0 && args[0].as_string() != '' {
		return args[0].as_string()
	}
	return fallback()!
}

fn unpack_strategy_spec_bool_arg(args []brew_runtime.Value, fallback bool) bool {
	if args.len == 0 {
		return fallback
	}
	return args[0].as_bool() or { fallback }
}

fn unpack_strategy_spec_result(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

// Ruby subject `subject(:strategy) { described_class.detect(path) }` at line 6.
pub fn ruby_unpack_strategy_spec_l6_d1_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	path := unpack_strategy_spec_path_arg(args, unpack_strategy_spec_nested_archive) or {
		return brew_runtime.object_value('UnpackStrategy', '')
	}
	strategy := unpack_strategy.detect(path, unpack_strategy.DetectOptions{})
	return brew_runtime.structured_value('UnpackStrategy', strategy.path, {
		'kind': strategy.kind.str()
		'path': strategy.path
	})
}

// Ruby let `let(:unpack_dir) { mktmpdir }` at line 8.
pub fn ruby_unpack_strategy_spec_l8_d2_unpack_dir(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	path := unpack_strategy_spec_temp_dir('unpack-dir') or { '' }
	return brew_runtime.object_value('Pathname', path)
}

// Ruby let `let(:file_name) { "file" }` at line 11.
pub fn ruby_unpack_strategy_spec_l11_d3_file_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('file')
}

// Ruby let `let(:path) do` at line 12.
pub fn ruby_unpack_strategy_spec_l12_d4_path(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Pathname', unpack_strategy_spec_nested_archive() or { '' })
}

// Ruby it `it "can extract nested archives" do` at line 22.
pub fn ruby_unpack_strategy_spec_l22_d5_can(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	archive := unpack_strategy_spec_nested_archive() or {
		return unpack_strategy_spec_result(false)
	}
	root := os.dir(archive)
	defer {
		os.rmdir_all(root) or {}
	}
	destination := os.join_path(root, 'unpack')
	strategy := unpack_strategy.detect(archive, unpack_strategy.DetectOptions{})
	strategy.extract_nestedly(unpack_strategy.ExtractOptions{
		destination: destination
	}) or { return unpack_strategy_spec_result(false) }
	contents := os.read_file(os.join_path(destination, 'file')) or {
		return unpack_strategy_spec_result(false)
	}
	return unpack_strategy_spec_result(contents == unpack_strategy_spec_payload)
}

// Ruby let `let(:directories) { "A/B/C" }` at line 30.
pub fn ruby_unpack_strategy_spec_l30_d6_directories(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('A/B/C')
}

// Ruby let `let(:executable) { "#{directories}/executable" }` at line 31.
pub fn ruby_unpack_strategy_spec_l31_d7_executable(args ...brew_runtime.Value) brew_runtime.Value {
	directories := if args.len > 0 { args[0].as_string() } else { 'A/B/C' }
	return brew_runtime.string_value('${directories}/executable')
}

// Ruby let `let(:writable) { true }` at line 32.
pub fn ruby_unpack_strategy_spec_l32_d8_writable(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby let `let(:path) do` at line 33.
pub fn ruby_unpack_strategy_spec_l33_d9_path(args ...brew_runtime.Value) brew_runtime.Value {
	writable := unpack_strategy_spec_bool_arg(args, true)
	return brew_runtime.object_value('Pathname', unpack_strategy_spec_tar_archive(writable) or {
		''
	})
}

// Ruby it `it "does not recurse into nested directories" do` at line 51.
pub fn ruby_unpack_strategy_spec_l51_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	archive := unpack_strategy_spec_tar_archive(true) or {
		return unpack_strategy_spec_result(false)
	}
	root := os.dir(archive)
	defer {
		os.rmdir_all(root) or {}
	}
	destination := os.join_path(root, 'unpack')
	unpack_strategy.detect(archive, unpack_strategy.DetectOptions{}).extract_nestedly(unpack_strategy.ExtractOptions{
		destination: destination
	}) or { return unpack_strategy_spec_result(false) }
	return unpack_strategy_spec_result(os.is_dir(os.join_path(destination, 'A/B/C')))
}

// Ruby let `let(:writable) { false }` at line 57.
pub fn ruby_unpack_strategy_spec_l57_d11_writable(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(false)
}

// Ruby it `it "makes them writable but not world-writable" do` at line 59.
pub fn ruby_unpack_strategy_spec_l59_d12_makes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	archive := unpack_strategy_spec_tar_archive(false) or {
		return unpack_strategy_spec_result(false)
	}
	root := os.dir(archive)
	defer {
		os.rmdir_all(root) or {}
	}
	destination := os.join_path(root, 'unpack')
	unpack_strategy.detect(archive, unpack_strategy.DetectOptions{}).extract_nestedly(unpack_strategy.ExtractOptions{
		destination: destination
	}) or { return unpack_strategy_spec_result(false) }
	permissions := os.inode(os.join_path(destination, 'A/B/C'))
	return unpack_strategy_spec_result(permissions.owner.write && !permissions.others.write)
}

// Ruby it `it "does not make other files writable" do` at line 66.
pub fn ruby_unpack_strategy_spec_l66_d13_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	archive := unpack_strategy_spec_tar_archive(false) or {
		return unpack_strategy_spec_result(false)
	}
	root := os.dir(archive)
	defer {
		os.rmdir_all(root) or {}
	}
	destination := os.join_path(root, 'unpack')
	unpack_strategy.detect(archive, unpack_strategy.DetectOptions{}).extract_nestedly(unpack_strategy.ExtractOptions{
		destination: destination
	}) or { return unpack_strategy_spec_result(false) }
	// We don't check `writable?` here as that's always true as root.
	mode := os.inode(os.join_path(destination, 'A/B/C/executable')).bitmask()
	return unpack_strategy_spec_result(mode & u32(0o222) == 0)
}

// Ruby let `let(:basename) { "file.xyz" }` at line 76.
pub fn ruby_unpack_strategy_spec_l76_d14_basename(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('file.xyz')
}

// Ruby let `let(:path) do` at line 77.
pub fn ruby_unpack_strategy_spec_l77_d15_path(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Pathname', unpack_strategy_spec_basename_archive() or {
		''
	})
}

// Ruby it `it "does not pass down the basename of the archive" do` at line 86.
pub fn ruby_unpack_strategy_spec_l86_d16_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	archive := unpack_strategy_spec_basename_archive() or {
		return unpack_strategy_spec_result(false)
	}
	root := os.dir(archive)
	defer {
		os.rmdir_all(root) or {}
	}
	destination := os.join_path(root, 'unpack')
	unpack_strategy.detect(archive, unpack_strategy.DetectOptions{}).extract_nestedly(unpack_strategy.ExtractOptions{
		destination: destination
		basename: 'file.xyz'
	}) or { return unpack_strategy_spec_result(false) }
	return unpack_strategy_spec_result(os.is_file(os.join_path(destination, 'file.txt')))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe UnpackStrategy do
// 5:   describe "#extract_nestedly" do
// 6:     subject(:strategy) { described_class.detect(path) }
// 7:
// 8:     let(:unpack_dir) { mktmpdir }
// 9:
// 10:     context "when extracting a GZIP nested in a BZIP2" do
// 11:       let(:file_name) { "file" }
// 12:       let(:path) do
// 13:         dir = mktmpdir
// 14:
// 15:         (dir/"file").write "This file was inside a GZIP inside a BZIP2."
// 16:         system "gzip", dir.children.first
// 17:         system "bzip2", dir.children.first
// 18:
// 19:         dir.children.first
// 20:       end
// 21:
// 22:       it "can extract nested archives" do
// 23:         strategy.extract_nestedly(to: unpack_dir)
// 24:
// 25:         expect(File.read(unpack_dir/file_name)).to eq("This file was inside a GZIP inside a BZIP2.")
// 26:       end
// 27:     end
// 28:
// 29:     context "when extracting a directory with nested directories" do
// 30:       let(:directories) { "A/B/C" }
// 31:       let(:executable) { "#{directories}/executable" }
// 32:       let(:writable) { true }
// 33:       let(:path) do
// 34:         (mktmpdir/"file.tar").tap do |path|
// 35:           Dir.mktmpdir do |dir|
// 36:             dir = Pathname(dir)
// 37:             (dir/directories).mkpath
// 38:             FileUtils.touch dir/executable
// 39:             FileUtils.chmod 0555, dir/executable
// 40:
// 41:             FileUtils.chmod "-w", dir/directories unless writable
// 42:             begin
// 43:               system "tar", "--create", "--file", path, "--directory", dir, "A/"
// 44:             ensure
// 45:               FileUtils.chmod "+w", dir/directories unless writable
// 46:             end
// 47:           end
// 48:         end
// 49:       end
// 50:
// 51:       it "does not recurse into nested directories" do
// 52:         strategy.extract_nestedly(to: unpack_dir)
// 53:         expect(Pathname.glob(unpack_dir/"**/*")).to include unpack_dir/directories
// 54:       end
// 55:
// 56:       context "which are not writable" do
// 57:         let(:writable) { false }
// 58:
// 59:         it "makes them writable but not world-writable" do
// 60:           strategy.extract_nestedly(to: unpack_dir)
// 61:
// 62:           expect(unpack_dir/directories).to be_writable
// 63:           expect(unpack_dir/directories).not_to be_world_writable
// 64:         end
// 65:
// 66:         it "does not make other files writable" do
// 67:           strategy.extract_nestedly(to: unpack_dir)
// 68:
// 69:           # We don't check `writable?` here as that's always true as root.
// 70:           expect((unpack_dir/executable).stat.mode & 0222).to be_zero
// 71:         end
// 72:       end
// 73:     end
// 74:
// 75:     context "when extracting a nested archive" do
// 76:       let(:basename) { "file.xyz" }
// 77:       let(:path) do
// 78:         (mktmpdir/basename).tap do |path|
// 79:           mktmpdir do |dir|
// 80:             FileUtils.touch dir/"file.txt"
// 81:             system "tar", "--create", "--file", path, "--directory", dir, "file.txt"
// 82:           end
// 83:         end
// 84:       end
// 85:
// 86:       it "does not pass down the basename of the archive" do
// 87:         strategy.extract_nestedly(to: unpack_dir, basename:)
// 88:         expect(unpack_dir/"file.txt").to be_a_file
// 89:       end
// 90:     end
// 91:   end
// 92: end
