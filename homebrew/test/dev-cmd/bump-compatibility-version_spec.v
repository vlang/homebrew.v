module dev_cmd

import ruby

// Translated from Homebrew/brew `test/dev-cmd/bump-compatibility-version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "adds compatibility_version 1 with --write-only" do` at line 15.
pub fn ruby_bump_compatibility_version_spec_l15_d1_adds(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 {
		args[0].as_string()
	} else {
		'class Foo < Formula\n  url "https://brew.sh/foo-1.0"\nend\n'
	}
	updated, version := bump_compatibility_version_source(source, none)
	return ruby.bool_value(version == 1 && updated.contains('  compatibility_version 1\n'))
}

// Ruby it `it "increments compatibility_version with --write-only" do` at line 34.
pub fn ruby_bump_compatibility_version_spec_l34_d2_increments(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 {
		args[0].as_string()
	} else {
		'class Foo < Formula\n  url "https://brew.sh/foo-1.0"\n  compatibility_version 2\nend\n'
	}
	updated, version := bump_compatibility_version_source(source, 2)
	return ruby.bool_value(version == 3 && updated.contains('  compatibility_version 3\n'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/bump-compatibility-version"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::BumpCompatibilityVersion do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "#run" do
// 11:     before do
// 12:       allow(Homebrew).to receive(:install_bundler_gems!)
// 13:     end
// 14:
// 15:     it "adds compatibility_version 1 with --write-only" do
// 16:       formula_path = mktmpdir/"foo.rb"
// 17:       formula_path.write <<~RUBY
// 18:         class Foo < Formula
// 19:           url "https://brew.sh/foo-1.0"
// 20:         end
// 21:       RUBY
// 22:       formula = formula("foo", path: formula_path) do
// 23:         T.bind(self, T.class_of(Formula))
// 24:         url "https://brew.sh/foo-1.0"
// 25:       end
// 26:       command = described_class.new(["--write-only", "foo"])
// 27:       allow(command.args.named).to receive(:to_formulae).and_return([formula])
// 28:
// 29:       command.run
// 30:
// 31:       expect(formula_path.read).to include "  compatibility_version 1\n"
// 32:     end
// 33:
// 34:     it "increments compatibility_version with --write-only" do
// 35:       formula_path = mktmpdir/"foo.rb"
// 36:       formula_path.write <<~RUBY
// 37:         class Foo < Formula
// 38:           url "https://brew.sh/foo-1.0"
// 39:           compatibility_version 2
// 40:         end
// 41:       RUBY
// 42:       formula = formula("foo", path: formula_path) do
// 43:         T.bind(self, T.class_of(Formula))
// 44:         url "https://brew.sh/foo-1.0"
// 45:         compatibility_version 2
// 46:       end
// 47:       command = described_class.new(["--write-only", "foo"])
// 48:       allow(command.args.named).to receive(:to_formulae).and_return([formula])
// 49:
// 50:       command.run
// 51:
// 52:       expect(formula_path.read).to include "  compatibility_version 3\n"
// 53:     end
// 54:   end
// 55: end
