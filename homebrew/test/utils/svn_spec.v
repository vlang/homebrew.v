module utils

import ruby
import homebrew.utils as svn_utils

// Translated from Homebrew/brew `test/utils/svn_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `svn_result(stdout = "", success:, stderr: "")` at line 7.
pub fn ruby_svn_spec_l7_d1_svn_result(args ...ruby.Value) ruby.Value {
	stdout := if args.len > 0 { args[0].as_string() } else { '' }
	success := if args.len > 1 { args[1].bool_data } else { false }
	stderr := if args.len > 2 { args[2].as_string() } else { '' }
	return ruby.map_value({
		'stdout':  ruby.string_value(stdout)
		'stderr':  ruby.string_value(stderr)
		'success': ruby.bool_value(success)
	})
}

// Ruby method `clear_version_cache` at line 12.
pub fn ruby_svn_spec_l12_d2_clear_version_cache(args ...ruby.Value) ruby.Value {
	mut client := svn_utils.svn_client_with_runner('/shim/svn', svn_spec_present_runner)
	_ = svn_utils.svn_client_version(mut client)
	svn_utils.svn_client_clear_version_cache(mut client)
	return ruby.bool_value((svn_utils.svn_client_version(mut client) or { '' }) == '1.14.5')
}

// Ruby it `it "returns true when svn version is present" do` at line 23.
pub fn ruby_svn_spec_l23_d3_returns(args ...ruby.Value) ruby.Value {
	mut client := svn_utils.svn_client_with_runner('/shim/svn', svn_spec_present_runner)
	return ruby.bool_value(svn_utils.svn_client_available(mut client))
}

// Ruby it `it "returns false when svn version is missing" do` at line 28.
pub fn ruby_svn_spec_l28_d4_returns(args ...ruby.Value) ruby.Value {
	mut client := svn_utils.svn_client_with_runner('/missing/svn', svn_spec_missing_runner)
	return ruby.bool_value(!svn_utils.svn_client_available(mut client))
}

// Ruby it `it "returns svn version or nil" do` at line 35.
pub fn ruby_svn_spec_l35_d5_returns(args ...ruby.Value) ruby.Value {
	mut present := svn_utils.svn_client_with_runner('/shim/svn', svn_spec_present_runner)
	first := (svn_utils.svn_client_version(mut present) or { '' }) == '1.14.5'
	svn_utils.svn_client_clear_version_cache(mut present)
	mut missing := svn_utils.svn_client_with_runner('/missing/svn', svn_spec_missing_runner)
	return ruby.bool_value(first && svn_utils.svn_client_version(mut missing) == none)
}

// Ruby it `it "returns true when svn is not available" do` at line 52.
pub fn ruby_svn_spec_l52_d6_returns(args ...ruby.Value) ruby.Value {
	mut client := svn_utils.svn_client_with_runner('/missing/svn', svn_spec_missing_runner)
	return ruby.bool_value(svn_utils.svn_client_remote_exists(mut client, 'blah'))
}

// Ruby it `it "returns false when remote does not exist" do` at line 62.
pub fn ruby_svn_spec_l62_d7_returns(args ...ruby.Value) ruby.Value {
	mut client := svn_utils.svn_client_with_runner('/shim/svn', svn_spec_remote_missing_runner)
	return ruby.bool_value(!svn_utils.svn_client_remote_exists(mut client, 'blah'))
}

// Ruby it `it "returns true when remote exists", :needs_network, :needs_svn do` at line 70.
pub fn ruby_svn_spec_l70_d8_returns(args ...ruby.Value) ruby.Value {
	mut client := svn_utils.svn_client_with_runner('/shim/svn', svn_spec_remote_present_runner)
	return ruby.bool_value(svn_utils.svn_client_remote_exists(mut client, 'https://svn.code.sf.net/p/ctags/code/trunk'))
}

fn svn_spec_present_runner(command []string) !svn_utils.SvnCommandResult {
	if command == ['/shim/svn', '--version'] {
		return svn_utils.SvnCommandResult{ stdout: 'svn, version 1.14.5\n' }
	}
	return svn_utils.SvnCommandResult{}
}

fn svn_spec_missing_runner(_command []string) !svn_utils.SvnCommandResult {
	return svn_utils.SvnCommandResult{ exit_code: 1 }
}

fn svn_spec_remote_missing_runner(command []string) !svn_utils.SvnCommandResult {
	if '--version' in command {
		return svn_utils.SvnCommandResult{ stdout: 'svn, version 1.14.5\n' }
	}
	return svn_utils.SvnCommandResult{ exit_code: 1 }
}

fn svn_spec_remote_present_runner(command []string) !svn_utils.SvnCommandResult {
	if '--version' in command {
		return svn_utils.SvnCommandResult{ stdout: 'svn, version 1.14.5\n' }
	}
	if command == ['svn', 'ls', 'https://svn.code.sf.net/p/ctags/code/trunk', '--depth', 'empty'] {
		return svn_utils.SvnCommandResult{}
	}
	return svn_utils.SvnCommandResult{ exit_code: 1 }
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/svn"
// 5:
// 6: RSpec.describe Utils::Svn do
// 7:   def svn_result(stdout = "", success:, stderr: "")
// 8:     status = instance_double(Process::Status, success?: success)
// 9:     instance_double(SystemCommand::Result, to_a: [stdout, stderr, status])
// 10:   end
// 11:
// 12:   def clear_version_cache
// 13:     return unless described_class.instance_variable_defined?(:@version)
// 14:
// 15:     described_class.remove_instance_variable(:@version)
// 16:   end
// 17:
// 18:   before do
// 19:     clear_version_cache
// 20:   end
// 21:
// 22:   describe "::available?" do
// 23:     it "returns true when svn version is present" do
// 24:       allow(described_class).to receive(:version).and_return("1.14.5")
// 25:       expect(described_class).to be_available
// 26:     end
// 27:
// 28:     it "returns false when svn version is missing" do
// 29:       allow(described_class).to receive(:version).and_return(nil)
// 30:       expect(described_class).not_to be_available
// 31:     end
// 32:   end
// 33:
// 34:   describe "::version" do
// 35:     it "returns svn version or nil" do
// 36:       expect(described_class).to receive(:system_command)
// 37:         .with(HOMEBREW_SHIMS_PATH/"shared/svn", args: ["--version"], print_stderr: false)
// 38:         .and_return(svn_result("svn, version 1.14.5\n", success: true))
// 39:
// 40:       expect(described_class.version).to eq("1.14.5")
// 41:
// 42:       clear_version_cache
// 43:       expect(described_class).to receive(:system_command)
// 44:         .with(HOMEBREW_SHIMS_PATH/"shared/svn", args: ["--version"], print_stderr: false)
// 45:         .and_return(svn_result("", success: false))
// 46:
// 47:       expect(described_class.version).to be_nil
// 48:     end
// 49:   end
// 50:
// 51:   describe "::remote_exists?" do
// 52:     it "returns true when svn is not available" do
// 53:       allow(described_class).to receive(:available?).and_return(false)
// 54:       expect(described_class).to be_remote_exists("blah")
// 55:     end
// 56:
// 57:     context "when svn is available" do
// 58:       before do
// 59:         allow(described_class).to receive(:available?).and_return(true)
// 60:       end
// 61:
// 62:       it "returns false when remote does not exist" do
// 63:         expect(described_class).to receive(:system_command)
// 64:           .with("svn", args: ["ls", "blah", "--depth", "empty"], print_stderr: false)
// 65:           .and_return(svn_result(success: false))
// 66:
// 67:         expect(described_class).not_to be_remote_exists("blah")
// 68:       end
// 69:
// 70:       it "returns true when remote exists", :needs_network, :needs_svn do
// 71:         expect(described_class).to be_remote_exists("https://svn.code.sf.net/p/ctags/code/trunk")
// 72:       end
// 73:     end
// 74:   end
// 75: end
