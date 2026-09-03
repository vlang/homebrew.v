module unpack_strategy

import brew_runtime
import homebrew.unpack_strategy as typed_unpack
import os
import time

// Translated from Homebrew/brew `test/unpack_strategy/shared_examples.rb`.
// The original source is retained below until every stub has a typed V body.
fn spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn spec_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn spec_temp_dir(label string) string {
	path := os.join_path(os.temp_dir(), 'brew-v-unpack-spec-${label}-${os.getpid()}-${time.now().unix_nano()}')
	os.mkdir_all(path) or { panic(err) }
	return path
}

fn spec_tool_available(name string) bool {
	brew_runtime.find_executable(name) or { return false }
	return true
}

fn spec_run_command(name string, arguments []string, work_directory string) ! {
	program := brew_runtime.find_executable(name)!
	if work_directory == '' {
		result := brew_runtime.run_command(program, arguments)
		if result.exit_code != 0 {
			return error('${name} failed (${result.exit_code}): ${result.output.trim_space()}')
		}
		return
	}
	mut process := os.new_process(program)
	process.set_args(arguments)
	process.set_work_folder(work_directory)
	process.set_redirect_stdio_merged()
	process.run()
	output := process.stdout_slurp()
	process.wait()
	code := process.code
	process.close()
	if code != 0 {
		return error('${name} failed (${code}): ${output.trim_space()}')
	}
}

fn spec_write_bytes(path string, bytes []u8) string {
	os.mkdir_all(os.dir(path)) or { panic(err) }
	os.write_file_array(path, bytes) or { panic(err) }
	return path
}

fn spec_repository_fixture(label string, metadata string, include_test bool) string {
	repository := spec_temp_dir(label)
	os.mkdir_all(os.join_path(repository, metadata)) or { panic(err) }
	if include_test {
		os.write_file(os.join_path(repository, 'test'), '') or { panic(err) }
	}
	return repository
}

fn spec_git_fixture() string {
	repository := spec_temp_dir('git')
	if spec_tool_available('git') {
		spec_run_command('git', ['init', '-q'], repository) or { panic(err) }
		os.write_file(os.join_path(repository, 'test'), '') or { panic(err) }
		spec_run_command('git', ['add', 'test'], repository) or { panic(err) }
		spec_run_command('git', ['-c', 'user.name=Homebrew Test', '-c',
			'user.email=brew-v@example.invalid', 'commit', '-q', '-m', 'Add `test` file.'], repository) or { panic(err) }
		return repository
	}
	os.mkdir_all(os.join_path(repository, '.git')) or { panic(err) }
	os.write_file(os.join_path(repository, 'test'), '') or { panic(err) }
	return repository
}

fn spec_compressed_fixture(label string, compressor string, extension string, magic []u8) string {
	root := spec_temp_dir(label)
	source := os.join_path(root, 'container')
	os.write_file(source, '') or { panic(err) }
	archive := source + extension
	if spec_tool_available(compressor) {
		spec_run_command(compressor, [source], '') or { panic(err) }
		return archive
	}
	os.rm(source) or {}
	return spec_write_bytes(archive, magic)
}

fn spec_tar_fixture() string {
	root := spec_temp_dir('tar')
	source := os.join_path(root, 'source')
	os.mkdir_all(os.join_path(source, 'container')) or { panic(err) }
	archive := os.join_path(root, 'container.tar.gz')
	if spec_tool_available('tar') {
		spec_run_command('tar', ['-czf', archive, '-C', source, 'container'], '') or {
			panic(err)
		}
		return archive
	}
	return spec_write_bytes(archive, [u8(0x1f), 0x8b])
}

fn spec_zip_fixture() string {
	root := spec_temp_dir('zip')
	source := os.join_path(root, 'source')
	os.mkdir_all(os.join_path(source, 'MyFancyApp')) or { panic(err) }
	os.write_file(os.join_path(source, 'MyFancyApp/payload'), '') or { panic(err) }
	archive := os.join_path(root, 'MyFancyApp.zip')
	if spec_tool_available('zip') {
		spec_run_command('zip', ['-q', '-r', archive, 'MyFancyApp'], source) or { panic(err) }
		return archive
	}
	return spec_write_bytes(archive, [u8(`P`), `K`, 0x05, 0x06])
}

fn spec_jar_fixture() string {
	root := spec_temp_dir('jar')
	source := os.join_path(root, 'source')
	os.mkdir_all(os.join_path(source, 'META-INF')) or { panic(err) }
	os.write_file(os.join_path(source, 'META-INF/MANIFEST.MF'), 'Manifest-Version: 1.0\n') or {
		panic(err)
	}
	archive := os.join_path(root, 'test.jar')
	if spec_tool_available('zip') {
		spec_run_command('zip', ['-q', '-r', archive, 'META-INF'], source) or { panic(err) }
		return archive
	}
	return spec_write_bytes(archive, [u8(`P`), `K`, 0x05, 0x06])
}

fn spec_xar_fixture() string {
	root := spec_temp_dir('xar')
	source := os.join_path(root, 'source')
	os.mkdir_all(os.join_path(source, 'container')) or { panic(err) }
	archive := os.join_path(root, 'container.xar')
	if spec_tool_available('xar') {
		spec_run_command('xar', ['-cf', archive, 'container'], source) or { panic(err) }
		return archive
	}
	return spec_write_bytes(archive, 'xar!'.bytes())
}

fn spec_dmg_fixture() string {
	root := spec_temp_dir('dmg')
	source := os.join_path(root, 'source')
	os.mkdir_all(os.join_path(source, 'container')) or { panic(err) }
	archive := os.join_path(root, 'container.dmg')
	if spec_tool_available('hdiutil') {
		spec_run_command('hdiutil', ['create', '-quiet', '-srcfolder', source, '-format', 'UDZO',
			archive], '') or { panic(err) }
		return archive
	}
	return spec_write_bytes(archive, []u8{})
}

fn spec_strategy_kind(name string) ?typed_unpack.StrategyKind {
	return typed_unpack.from_type(name)
}

fn spec_detect(path string, kind typed_unpack.StrategyKind) bool {
	return typed_unpack.detect(path, typed_unpack.DetectOptions{}).kind == kind
}

fn spec_value_children(value brew_runtime.Value) []string {
	if value.string_array_data.len > 0 {
		return value.string_array_data.clone()
	}
	return value.array_data.map(it.as_string())
}

fn spec_extract(path string, kind typed_unpack.StrategyKind, expected []string, verbose bool) bool {
	destination := spec_temp_dir('extract')
	defer {
		os.rmdir_all(destination) or {}
	}
	typed_unpack.Strategy{
		kind: kind
		path: os.abs_path(path)
	}.extract(typed_unpack.ExtractOptions{
		destination: destination
		verbose: verbose
	}) or { return false }
	mut children := os.ls(destination) or { return false }
	children.sort()
	mut wanted := expected.clone()
	wanted.sort()
	return children == wanted
}

// Ruby it `it "is correctly detected" do` at line 8.
pub fn ruby_shared_examples_l8_d1_is(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return spec_bool(false)
	}
	kind := spec_strategy_kind(args[1].as_string()) or { return spec_bool(false) }
	return spec_bool(spec_detect(args[0].as_string(), kind))
}

// Ruby specify `specify "#extract" do` at line 14.
pub fn ruby_shared_examples_l14_d2_extract(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return spec_bool(false)
	}
	kind := spec_strategy_kind(args[1].as_string()) or { return spec_bool(false) }
	verbose := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	return spec_bool(spec_extract(args[0].as_string(), kind, spec_value_children(args[2]), verbose))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "mktemp"
// 5: require "unpack_strategy"
// 6:
// 7: RSpec.shared_examples "UnpackStrategy::detect" do
// 8:   it "is correctly detected" do
// 9:     expect(UnpackStrategy.detect(path)).to be_a described_class
// 10:   end
// 11: end
// 12:
// 13: RSpec.shared_examples "#extract" do |children: [], verbose: false|
// 14:   specify "#extract" do
// 15:     Mktemp.new("homebrew-test-unpack").run(chdir: false) do |mktemp|
// 16:       unpack_dir = T.must(mktemp.tmpdir)
// 17:       described_class.new(path).extract(to: unpack_dir, verbose:)
// 18:       expect(unpack_dir.children(false).map(&:to_s)).to match_array children
// 19:     end
// 20:   end
// 21: end
