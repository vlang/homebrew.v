module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `test/dev-cmd/extract_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let! `let!(:target) do` at line 11.
pub fn ruby_extract_spec_l11_d1_target(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].as_string() == '' {
		return brew_runtime.object_value('ArgumentError', 'target path is required')
	}
	path := args[0].as_string()
	os.mkdir_all(os.join_path(path, 'Formula')) or {
		return brew_runtime.object_value('SystemCallError', err.msg())
	}
	return brew_runtime.map_value({
		'name': brew_runtime.string_value('homebrew/foo')
		'path': brew_runtime.object_value('Pathname', path)
	})
}

fn extract_spec_retrieves(value brew_runtime.Value, requested_version string,
	formula_version string) bool {
	input := extract_input_from_value(value) or { return false }
	result := run_extract(input.options) or { return false }
	if !os.exists(result.path) || result.stdout != [result.path] {
		return false
	}
	return result.version == requested_version && result.formula_version == formula_version
}

// Ruby it `it "retrieves the most recent version of formula", :integration_test do` at line 45.
pub fn ruby_extract_spec_l45_d2_retrieves(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(extract_spec_retrieves(args[0], '0.2', '0.2'))
}

// Ruby it `it "retrieves the specified version of formula" do` at line 55.
pub fn ruby_extract_spec_l55_d3_retrieves(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(extract_spec_retrieves(args[0], '0.1', '0.1'))
}

// Ruby it `it "retrieves the compatible version of formula" do` at line 63.
pub fn ruby_extract_spec_l63_d4_retrieves(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(extract_spec_retrieves(args[0], '0', '0.2'))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/extract"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Extract do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   context "when extracting a formula" do
// 11:     let!(:target) do
// 12:       path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo"
// 13:       (path/"Formula").mkpath
// 14:       target = Tap.from_path(path)
// 15:       core_tap = CoreTap.instance
// 16:       core_tap.path.cd do
// 17:         system "git", "init"
// 18:         # Start with deprecated bottle syntax
// 19:         formula_file = Formulary.find_formula_in_tap("testball", core_tap)
// 20:         formula_file.dirname.mkpath
// 21:         formula_file.write <<~RUBY
// 22:           class Testball < Formula
// 23:             url "https://brew.sh/testball-0.1.tar.gz"
// 24:
// 25:             bottle do
// 26:               cellar :any
// 27:             end
// 28:
// 29:           end
// 30:         RUBY
// 31:         system "git", "add", "--all"
// 32:         system "git", "commit", "-m", "testball 0.1"
// 33:         # Replace with a valid formula for the next version
// 34:         formula_file.write <<~RUBY
// 35:           class Testball < Formula
// 36:             url "https://brew.sh/testball-0.2.tar.gz"
// 37:           end
// 38:         RUBY
// 39:         system "git", "add", "--all"
// 40:         system "git", "commit", "-m", "testball 0.2"
// 41:       end
// 42:       { name: target.name, path: }
// 43:     end
// 44:
// 45:     it "retrieves the most recent version of formula", :integration_test do
// 46:       path = target[:path]/"Formula/testball@0.2.rb"
// 47:       expect { brew "extract", "testball", target[:name] }
// 48:         .to output(/^#{path}$/).to_stdout
// 49:         .and not_to_output.to_stderr
// 50:         .and be_a_success
// 51:       expect(path).to exist
// 52:       expect(Formulary.factory(path).version).to eq "0.2"
// 53:     end
// 54:
// 55:     it "retrieves the specified version of formula" do
// 56:       path = target[:path]/"Formula/testball@0.1.rb"
// 57:       expect { described_class.new(["testball", target[:name], "--version=0.1"]).run }
// 58:         .to output(/^#{path}$/).to_stdout
// 59:       expect(path).to exist
// 60:       expect(Formulary.factory(path).version).to eq "0.1"
// 61:     end
// 62:
// 63:     it "retrieves the compatible version of formula" do
// 64:       path = target[:path]/"Formula/testball@0.rb"
// 65:       expect { described_class.new(["testball", target[:name], "--version=0"]).run }
// 66:         .to output(/^#{path}$/).to_stdout
// 67:       expect(path).to exist
// 68:       expect(Formulary.factory(path).version).to eq "0.2"
// 69:     end
// 70:   end
// 71: end
