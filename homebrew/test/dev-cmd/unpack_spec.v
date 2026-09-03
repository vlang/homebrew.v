module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `test/dev-cmd/unpack_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn unpack_spec_root(args []brew_runtime.Value, label string) string {
	base := if args.len > 0 {
		args[0].as_string()
	} else {
		os.join_path(os.temp_dir(), 'brew-v-unpack-spec-${os.getpid()}')
	}
	return os.join_path(base, label)
}

fn unpack_spec_reset(path string) ! {
	if os.exists(path) {
		os.rmdir_all(path)!
	}
	os.mkdir_all(path)!
}

// Ruby it `it "unpacks a given Formula's archive", :integration_test do` at line 10.
pub fn ruby_unpack_spec_l10_d1_unpacks(args ...brew_runtime.Value) brew_runtime.Value {
	root := unpack_spec_root(args, 'formula')
	unpack_spec_reset(root) or { return brew_runtime.bool_value(false) }
	source := os.join_path(root, 'source')
	destination := os.join_path(root, 'destination')
	os.mkdir_all(source) or { return brew_runtime.bool_value(false) }
	os.write_file(os.join_path(source, 'README'), 'testball source') or {
		return brew_runtime.bool_value(false)
	}
	package := UnpackPackage{
		kind: .formula
		name: 'testball'
		version: '0.1'
		full_name: 'testball'
		source_path: source
	}
	result := run_unpack(UnpackOptions{
		named: ['testball']
		packages: [package]
		destdir: destination
	}) or { return brew_runtime.bool_value(false) }
	stage_dir := os.join_path(destination, 'testball-0.1')
	return brew_runtime.bool_value(result.items.len == 1 && os.is_dir(stage_dir)
		&& os.read_file(os.join_path(stage_dir, 'README')) or { '' } == 'testball source')
}

// Ruby it `it "unpacks a given Cask's archive" do` at line 21.
pub fn ruby_unpack_spec_l21_d2_unpacks(args ...brew_runtime.Value) brew_runtime.Value {
	root := unpack_spec_root(args, 'cask')
	unpack_spec_reset(root) or { return brew_runtime.bool_value(false) }
	destination := os.join_path(root, 'destination')
	archive := '/Users/alex/code/3rd/brew/Library/Homebrew/test/support/fixtures/cask/caffeine.zip'
	package := UnpackPackage{
		kind: .cask
		token: 'local-caffeine'
		version: '1.2.3'
		full_name: 'local-caffeine'
		fetched_download: archive
	}
	result := run_unpack(UnpackOptions{
		named: ['local-caffeine']
		packages: [package]
		destdir: destination
	}) or { return brew_runtime.bool_value(false) }
	stage_dir := os.join_path(destination, 'local-caffeine-1.2.3')
	return brew_runtime.bool_value(result.items.len == 1 && os.is_dir(stage_dir)
		&& result.items[0].fetched && result.items[0].extract_nestedly)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/unpack"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Unpack do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "unpacks a given Formula's archive", :integration_test do
// 11:     setup_test_formula "testball"
// 12:
// 13:     mktmpdir do |path|
// 14:       expect { brew "unpack", "testball", "--destdir=#{path}" }
// 15:         .to be_a_success
// 16:
// 17:       expect(path/"testball-0.1").to be_a_directory
// 18:     end
// 19:   end
// 20:
// 21:   it "unpacks a given Cask's archive" do
// 22:     caffeine_cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 23:
// 24:     mktmpdir do |path|
// 25:       expect { described_class.new([cask_path("local-caffeine").to_s, "--destdir=#{path}"]).run }
// 26:         .not_to raise_error
// 27:
// 28:       expect(path/"local-caffeine-#{caffeine_cask.version}").to be_a_directory
// 29:     end
// 30:   end
// 31: end
