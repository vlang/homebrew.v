module unpack_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `test/unpack_strategy/subversion_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn subversion_working_copy_fixture(repository string, suffix string) string {
	root := spec_temp_dir('subversion-working-copy')
	working_copy := os.join_path(root, 'checkout${suffix}')
	if spec_tool_available('svnadmin') && spec_tool_available('svn') {
		spec_run_command('svnadmin', ['create', repository], '') or { panic(err) }
		os.mkdir_all(working_copy) or { panic(err) }
		spec_run_command('svn', ['checkout', 'file://${repository}', working_copy], '') or {
			panic(err)
		}
		os.write_file(os.join_path(working_copy, 'test'), '') or { panic(err) }
		spec_run_command('svn', ['add', os.join_path(working_copy, 'test')], '') or { panic(err) }
		spec_run_command('svn', ['commit', working_copy, '-m', 'Add `test` file.'], '') or {
			panic(err)
		}
		return working_copy
	}
	os.mkdir_all(os.join_path(working_copy, '.svn')) or { panic(err) }
	os.write_file(os.join_path(working_copy, 'test'), '') or { panic(err) }
	return working_copy
}

// Ruby let `let(:repo) { mktmpdir }` at line 7.
pub fn ruby_subversion_spec_l7_d1_repo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(spec_temp_dir('subversion-repository'))
}

// Ruby let `let(:working_copy) { mktmpdir }` at line 8.
pub fn ruby_subversion_spec_l8_d2_working_copy(args ...brew_runtime.Value) brew_runtime.Value {
	repository := if args.len > 0 {
		args[0].as_string()
	} else {
		spec_temp_dir('subversion-repository')
	}
	return brew_runtime.string_value(subversion_working_copy_fixture(repository, ''))
}

// Ruby let `let(:path) { working_copy }` at line 9.
pub fn ruby_subversion_spec_l9_d3_path(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[0] } else { ruby_subversion_spec_l8_d2_working_copy() }
}

// Ruby let `let(:working_copy) { mktmpdir(["", "@1.2.3"])  }` at line 24.
pub fn ruby_subversion_spec_l24_d4_working_copy(args ...brew_runtime.Value) brew_runtime.Value {
	repository := if args.len > 0 {
		args[0].as_string()
	} else {
		spec_temp_dir('subversion-at-repository')
	}
	return brew_runtime.string_value(subversion_working_copy_fixture(repository, '@1.2.3'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Subversion, :needs_svnadmin do
// 7:   let(:repo) { mktmpdir }
// 8:   let(:working_copy) { mktmpdir }
// 9:   let(:path) { working_copy }
// 10:
// 11:   before do
// 12:     safe_system "svnadmin", "create", repo
// 13:     safe_system "svn", "checkout", "file://#{repo}", working_copy
// 14:
// 15:     FileUtils.touch working_copy/"test"
// 16:     system "svn", "add", working_copy/"test"
// 17:     system "svn", "commit", working_copy, "-m", "Add `test` file."
// 18:   end
// 19:
// 20:   include_examples "UnpackStrategy::detect"
// 21:   include_examples "#extract", children: ["test"]
// 22:
// 23:   context "when the directory name contains an '@' symbol" do
// 24:     let(:working_copy) { mktmpdir(["", "@1.2.3"])  }
// 25:
// 26:     include_examples "#extract", children: ["test"]
// 27:   end
// 28: end
