module utils

import ruby
import homebrew.utils as tar_utils

// Translated from Homebrew/brew `test/utils/tar_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `clear_executable_cache` at line 7.
pub fn ruby_tar_spec_l7_d1_clear_executable_cache(args ...ruby.Value) ruby.Value {
	mut client := tar_utils.tar_client_with(tar_utils.TarExecutableCandidates{
		path_gtar: '/bin/gtar'
	}, tar_spec_valid_runner)
	_ = tar_utils.tar_client_executable(mut client)
	client.candidates = tar_utils.TarExecutableCandidates{}
	still_cached := tar_utils.tar_client_available(mut client)
	tar_utils.tar_client_clear_executable_cache(mut client)
	return ruby.bool_value(still_cached && !tar_utils.tar_client_available(mut client))
}

// Ruby it `it "returns true if tar or gnu-tar is available" do` at line 18.
pub fn ruby_tar_spec_l18_d2_returns(args ...ruby.Value) ruby.Value {
	mut available := tar_utils.tar_client_with(tar_utils.TarExecutableCandidates{
		path_tar: '/bin/tar'
	}, tar_spec_valid_runner)
	mut unavailable := tar_utils.tar_client_with(tar_utils.TarExecutableCandidates{}, tar_spec_valid_runner)
	return ruby.bool_value(tar_utils.tar_client_available(mut available)
		&& !tar_utils.tar_client_available(mut unavailable))
}

// Ruby it `it "does not raise an error when tar and gnu-tar are unavailable" do` at line 28.
pub fn ruby_tar_spec_l28_d3_does(args ...ruby.Value) ruby.Value {
	mut client := tar_utils.tar_client_with(tar_utils.TarExecutableCandidates{}, tar_spec_invalid_runner)
	tar_utils.tar_validate_file(mut client, 'blah') or { return ruby.bool_value(false) }
	return ruby.bool_value(true)
}

// Ruby let `let(:testball_resource) { "#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz" }` at line 34.
pub fn ruby_tar_spec_l34_d4_testball_resource(args ...ruby.Value) ruby.Value {
	fixture_dir := if args.len > 0 { args[0].as_string() } else { 'test/fixtures' }
	return ruby.string_value('${fixture_dir}/tarballs/testball-0.1.tbz')
}

// Ruby let `let(:invalid_resource) { "#{TEST_TMPDIR}/invalid.tgz" }` at line 35.
pub fn ruby_tar_spec_l35_d5_invalid_resource(args ...ruby.Value) ruby.Value {
	temporary_dir := if args.len > 0 { args[0].as_string() } else { '/tmp' }
	return ruby.string_value('${temporary_dir}/invalid.tgz')
}

// Ruby it `it "does not raise an error if file is not a tar file" do` at line 41.
pub fn ruby_tar_spec_l41_d6_does(args ...ruby.Value) ruby.Value {
	mut client := tar_spec_available_client(tar_spec_invalid_runner)
	tar_utils.tar_validate_file(mut client, 'blah') or { return ruby.bool_value(false) }
	return ruby.bool_value(true)
}

// Ruby it `it "does not raise an error if file is valid tar file" do` at line 45.
pub fn ruby_tar_spec_l45_d7_does(args ...ruby.Value) ruby.Value {
	mut client := tar_spec_available_client(tar_spec_valid_runner)
	tar_utils.tar_validate_file(mut client, '/fixtures/tarballs/testball-0.1.tbz') or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(true)
}

// Ruby it `it "raises an error if file is an invalid tar file" do` at line 49.
pub fn ruby_tar_spec_l49_d8_raises(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { '/tmp/invalid.tgz' }
	mut client := tar_spec_available_client(tar_spec_invalid_runner)
	tar_utils.tar_validate_file(mut client, path) or {
		return ruby.bool_value(err.msg() == '${path} is not a valid tar file!')
	}
	return ruby.bool_value(false)
}

fn tar_spec_available_client(runner tar_utils.TarCommandRunner) tar_utils.TarClient {
	return tar_utils.tar_client_with(tar_utils.TarExecutableCandidates{
		path_tar: '/bin/tar'
	}, runner)
}

fn tar_spec_valid_runner(executable string, arguments []string) tar_utils.TarCommandResult {
	return tar_utils.TarCommandResult{
		stdout: if executable == '/bin/tar' || executable == '/bin/gtar' {
			'file.txt\n'
		} else {
			''
		}
		exit_code: if arguments.len == 3 && arguments[0] == '--list' && arguments[1] == '--file' {
			0
		} else {
			1
		}
	}
}

fn tar_spec_invalid_runner(_executable string, _arguments []string) tar_utils.TarCommandResult {
	return tar_utils.TarCommandResult{ exit_code: 1 }
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/tar"
// 5:
// 6: RSpec.describe Utils::Tar do
// 7:   def clear_executable_cache
// 8:     return unless described_class.instance_variable_defined?(:@executable)
// 9:
// 10:     described_class.remove_instance_variable(:@executable)
// 11:   end
// 12:
// 13:   before do
// 14:     clear_executable_cache
// 15:   end
// 16:
// 17:   describe ".available?" do
// 18:     it "returns true if tar or gnu-tar is available" do
// 19:       if described_class.executable
// 20:         expect(described_class).to be_available
// 21:       else
// 22:         expect(described_class).not_to be_available
// 23:       end
// 24:     end
// 25:   end
// 26:
// 27:   describe ".validate_file" do
// 28:     it "does not raise an error when tar and gnu-tar are unavailable" do
// 29:       allow(described_class).to receive(:available?).and_return false
// 30:       expect { described_class.validate_file "blah" }.not_to raise_error
// 31:     end
// 32:
// 33:     context "when tar or gnu-tar is available" do
// 34:       let(:testball_resource) { "#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz" }
// 35:       let(:invalid_resource) { "#{TEST_TMPDIR}/invalid.tgz" }
// 36:
// 37:       before do
// 38:         allow(described_class).to receive(:available?).and_return true
// 39:       end
// 40:
// 41:       it "does not raise an error if file is not a tar file" do
// 42:         expect { described_class.validate_file "blah" }.not_to raise_error
// 43:       end
// 44:
// 45:       it "does not raise an error if file is valid tar file" do
// 46:         expect { described_class.validate_file testball_resource }.not_to raise_error
// 47:       end
// 48:
// 49:       it "raises an error if file is an invalid tar file" do
// 50:         FileUtils.touch invalid_resource
// 51:         expect { described_class.validate_file invalid_resource }.to raise_error SystemExit
// 52:         FileUtils.rm_f invalid_resource
// 53:       end
// 54:     end
// 55:   end
// 56: end
