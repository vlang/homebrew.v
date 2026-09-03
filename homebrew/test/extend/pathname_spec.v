module extend

import brew_runtime
import homebrew.extend as pathname_extension
import os

// Translated from Homebrew/brew `test/extend/pathname_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "creates script with arguments" do` at line 8.
pub fn ruby_pathname_spec_l8_d1_creates(args ...brew_runtime.Value) brew_runtime.Value {
	root := pathname_spec_root('arguments', args)
	pathname_spec_reset(root) or { return brew_runtime.bool_value(false) }
	wrapper := os.join_path(root, 'wrapper_script')
	target := os.join_path(root, 'test')
	pathname_extension.pathname_write_env_script(wrapper, target, ['foo', 'bar'], [
		pathname_extension.EnvironmentAssignment{
			key: 'TEST'
			value: 'baz'
		},
	]) or { return brew_runtime.bool_value(false) }
	expected := '#!/bin/bash\nTEST="baz" exec "${target}" foo bar "\$@"\n'
	return brew_runtime.bool_value((os.read_file(wrapper) or { '' }) == expected)
}

// Ruby it `it "creates script without arguments" do` at line 18.
pub fn ruby_pathname_spec_l18_d2_creates(args ...brew_runtime.Value) brew_runtime.Value {
	root := pathname_spec_root('without-arguments', args)
	pathname_spec_reset(root) or { return brew_runtime.bool_value(false) }
	wrapper := os.join_path(root, 'wrapper_script')
	pathname_extension.pathname_write_env_script(wrapper, 'test', [], [
		pathname_extension.EnvironmentAssignment{
			key: 'TEST'
			value: 'bar'
		},
		pathname_extension.EnvironmentAssignment{
			key: 'TEST2'
			value: os.join_path(root, 'baz')
		},
	]) or { return brew_runtime.bool_value(false) }
	expected := '#!/bin/bash\nTEST="bar" TEST2="${os.join_path(root, 'baz')}" exec "test"  "\$@"\n'
	return brew_runtime.bool_value((os.read_file(wrapper) or { '' }) == expected)
}

// Ruby it `it "makes scripts read-only executable" do` at line 30.
pub fn ruby_pathname_spec_l30_d3_makes(args ...brew_runtime.Value) brew_runtime.Value {
	root := pathname_spec_root('permissions', args)
	pathname_spec_reset(root) or { return brew_runtime.bool_value(false) }
	wrapper := os.join_path(root, 'wrapper_script')
	pathname_extension.pathname_write_env_script(wrapper, 'test', [], [
		pathname_extension.EnvironmentAssignment{
			key: 'TEST'
			value: 'bar'
		},
	]) or { return brew_runtime.bool_value(false) }
	mode := os.stat(wrapper) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(mode.get_mode().bitmask() & 0o777 == 0o555)
}

// Ruby it `it "creates scripts for files with mixed environment key types" do` at line 41.
pub fn ruby_pathname_spec_l41_d4_creates(args ...brew_runtime.Value) brew_runtime.Value {
	root := pathname_spec_root('all-files', args)
	pathname_spec_reset(root) or { return brew_runtime.bool_value(false) }
	input := os.join_path(root, 'input')
	output := os.join_path(root, 'output')
	os.mkdir_all(input) or { return brew_runtime.bool_value(false) }
	os.write_file(os.join_path(input, 'foo'), '') or { return brew_runtime.bool_value(false) }
	os.write_file(os.join_path(input, 'bar'), '') or { return brew_runtime.bool_value(false) }
	environment := [pathname_extension.EnvironmentAssignment{
		key: 'FOO'
		value: 'foo'
	}, pathname_extension.EnvironmentAssignment{
		key: 'BAR'
		value: os.join_path(input, 'test')
	}]
	pathname_extension.pathname_env_script_all_files(input, output, environment) or {
		return brew_runtime.bool_value(false)
	}
	for name in ['foo', 'bar'] {
		expected := '#!/bin/bash\nFOO="foo" BAR="${os.join_path(input, 'test')}" exec "${os.join_path(output, name)}"  "\$@"\n'
		if (os.read_file(os.join_path(input, name)) or { '' }) != expected {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby it `it "raises an exception when file already exists" do` at line 64.
pub fn ruby_pathname_spec_l64_d5_raises(args ...brew_runtime.Value) brew_runtime.Value {
	root := pathname_spec_root('existing-file', args)
	pathname_spec_reset(root) or { return brew_runtime.bool_value(false) }
	input := os.join_path(root, 'input')
	output := os.join_path(root, 'output')
	os.mkdir_all(input) or { return brew_runtime.bool_value(false) }
	os.mkdir_all(output) or { return brew_runtime.bool_value(false) }
	os.write_file(os.join_path(input, 'foo'), '') or { return brew_runtime.bool_value(false) }
	os.write_file(os.join_path(output, 'foo'), '') or { return brew_runtime.bool_value(false) }
	pathname_extension.pathname_env_script_all_files(input, output, [
		pathname_extension.EnvironmentAssignment{
			key: 'FOO'
			value: 'foo'
		},
	]) or { return brew_runtime.bool_value(err.msg().contains('EEXIST')) }
	return brew_runtime.bool_value(false)
}

fn pathname_spec_root(name string, args []brew_runtime.Value) string {
	base := if args.len > 0 {
		args[0].as_string()
	} else {
		os.join_path(os.temp_dir(), 'brew-v-pathname-spec-${os.getpid()}')
	}
	return os.join_path(base, name)
}

fn pathname_spec_reset(path string) ! {
	if os.exists(path) {
		os.rmdir_all(path)!
	}
	os.mkdir_all(path)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/pathname"
// 5:
// 6: RSpec.describe Pathname do
// 7:   describe ".write_env_script" do
// 8:     it "creates script with arguments" do
// 9:       mktmpdir do |tmpdir|
// 10:         (tmpdir/"wrapper_script").write_env_script tmpdir/"test", ["foo", "bar"], TEST: "baz"
// 11:         expect((tmpdir/"wrapper_script").read).to eq(<<~BASH)
// 12:           #!/bin/bash
// 13:           TEST="baz" exec "#{tmpdir}/test" foo bar "$@"
// 14:         BASH
// 15:       end
// 16:     end
// 17:
// 18:     it "creates script without arguments" do
// 19:       mktmpdir do |tmpdir|
// 20:         env = { TEST: "bar" }
// 21:         env["TEST2"] = tmpdir/"baz"
// 22:         (tmpdir/"wrapper_script").write_env_script "test", env
// 23:         expect((tmpdir/"wrapper_script").read).to eq(<<~BASH)
// 24:           #!/bin/bash
// 25:           TEST="bar" TEST2="#{tmpdir}/baz" exec "test"  "$@"
// 26:         BASH
// 27:       end
// 28:     end
// 29:
// 30:     it "makes scripts read-only executable" do
// 31:       mktmpdir do |tmpdir|
// 32:         script = tmpdir/"wrapper_script"
// 33:         script.write_env_script "test", TEST: "bar"
// 34:
// 35:         expect(script.stat.mode & 0777).to eq(0555)
// 36:       end
// 37:     end
// 38:   end
// 39:
// 40:   describe ".env_script_all_files" do
// 41:     it "creates scripts for files with mixed environment key types" do
// 42:       mktmpdir do |input_dir|
// 43:         FileUtils.touch input_dir/"foo"
// 44:         FileUtils.touch input_dir/"bar"
// 45:
// 46:         mktmpdir do |output_dir|
// 47:           env = { FOO: "foo" }
// 48:           env["BAR"] = input_dir/"test"
// 49:           input_dir.env_script_all_files(output_dir, env)
// 50:
// 51:           expect((input_dir/"foo").read).to eq(<<~BASH)
// 52:             #!/bin/bash
// 53:             FOO="foo" BAR="#{input_dir}/test" exec "#{output_dir}/foo"  "$@"
// 54:           BASH
// 55:
// 56:           expect((input_dir/"bar").read).to eq(<<~BASH)
// 57:             #!/bin/bash
// 58:             FOO="foo" BAR="#{input_dir}/test" exec "#{output_dir}/bar"  "$@"
// 59:           BASH
// 60:         end
// 61:       end
// 62:     end
// 63:
// 64:     it "raises an exception when file already exists" do
// 65:       mktmpdir do |input_dir|
// 66:         FileUtils.touch input_dir/"foo"
// 67:
// 68:         mktmpdir do |output_dir|
// 69:           FileUtils.touch output_dir/"foo"
// 70:           expect { input_dir.env_script_all_files(output_dir, FOO: "foo") }.to raise_error(Errno::EEXIST)
// 71:         end
// 72:       end
// 73:     end
// 74:   end
// 75: end
