module extend

import brew_runtime

// Translated from Homebrew/brew `test/extend/pathname_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "creates script with arguments" do` at line 8.
pub fn ruby_pathname_spec_l8_d1_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "creates script without arguments" do` at line 18.
pub fn ruby_pathname_spec_l18_d2_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "makes scripts read-only executable" do` at line 30.
pub fn ruby_pathname_spec_l30_d3_makes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('makes', ...args)
}

// Ruby it `it "creates scripts for files with mixed environment key types" do` at line 41.
pub fn ruby_pathname_spec_l41_d4_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "raises an exception when file already exists" do` at line 64.
pub fn ruby_pathname_spec_l64_d5_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
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
