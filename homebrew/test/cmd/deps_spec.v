module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/deps_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "outputs all of a Formula's dependencies and their dependencies on separate lines" do` at line 39.
pub fn ruby_deps_spec_l39_d1_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outputs', ...args)
}

// Ruby it `it "outputs all requested recursive dependencies" do` at line 50.
pub fn ruby_deps_spec_l50_d2_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outputs', ...args)
}

// Ruby it `it "--prune skips already seen recursive dependencies" do` at line 71.
pub fn ruby_deps_spec_l71_d3_prune(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('--prune', ...args)
}

// Ruby it `it "reads inputs from a Brewfile alongside named arguments" do` at line 90.
pub fn ruby_deps_spec_l90_d4_reads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reads', ...args)
}

// Ruby it `it "detects circular dependencies" do` at line 113.
pub fn ruby_deps_spec_l113_d5_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/deps"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Deps, :integration_test, :no_api do
// 8:   include FileUtils
// 9:
// 10:   before do
// 11:     setup_test_formula "bar"
// 12:     setup_test_formula "foo"
// 13:     setup_test_formula "test"
// 14:     setup_test_formula "build"
// 15:     setup_test_formula "optional"
// 16:     setup_test_formula "recommended_test"
// 17:
// 18:     setup_test_formula "baz", <<~RUBY
// 19:       url "https://brew.sh/baz-1.0"
// 20:       depends_on "bar"
// 21:       depends_on "build" => :build
// 22:       depends_on "test" => :test
// 23:       depends_on "optional" => :optional
// 24:       depends_on "recommended_test" => [:recommended, :test]
// 25:       depends_on "installed"
// 26:     RUBY
// 27:
// 28:     # Mock `Formula#any_version_installed?` by creating the tab in a plausible keg directory and opt link
// 29:     keg_dir = HOMEBREW_CELLAR/"installed/1.0"
// 30:     keg_dir.mkpath
// 31:     touch keg_dir/AbstractTab::FILENAME
// 32:     opt_link = HOMEBREW_PREFIX/"opt/installed"
// 33:     opt_link.parent.mkpath
// 34:     FileUtils.ln_sf keg_dir, opt_link
// 35:   end
// 36:
// 37:   it_behaves_like "parseable arguments"
// 38:
// 39:   it "outputs all of a Formula's dependencies and their dependencies on separate lines" do
// 40:     setup_test_formula "installed"
// 41:     expect do
// 42:       brew "deps", "baz", "--include-test", "--missing", "--skip-recommended", "HOMEBREW_REQUIRE_TAP_TRUST" => "1"
// 43:     end
// 44:       .to be_a_success
// 45:       .and output("bar\nfoo\ntest\n").to_stdout
// 46:       .and output(/not the actual runtime dependencies/).to_stderr
// 47:   end
// 48:
// 49:   context "with --tree" do
// 50:     it "outputs all requested recursive dependencies" do
// 51:       setup_test_formula "installed", <<~RUBY
// 52:         url "https://brew.sh/installed-1.0"
// 53:         depends_on "bar"
// 54:       RUBY
// 55:       stdout = <<~EOS
// 56:         baz
// 57:         ├── bar
// 58:         │   └── foo
// 59:         ├── build
// 60:         ├── recommended_test
// 61:         └── installed
// 62:             └── bar
// 63:                 └── foo
// 64:
// 65:       EOS
// 66:       expect { brew "deps", "baz", "--tree", "--include-build" }
// 67:         .to be_a_success
// 68:         .and output(stdout).to_stdout
// 69:     end
// 70:
// 71:     it "--prune skips already seen recursive dependencies" do
// 72:       setup_test_formula "installed", <<~RUBY
// 73:         url "https://brew.sh/installed-1.0"
// 74:         depends_on "bar"
// 75:       RUBY
// 76:       stdout = <<~EOS
// 77:         baz
// 78:         ├── bar
// 79:         │   └── foo
// 80:         ├── recommended_test
// 81:         └── installed
// 82:             └── bar (PRUNED)
// 83:
// 84:       EOS
// 85:       expect { brew "deps", "baz", "--tree", "--prune" }
// 86:         .to be_a_success
// 87:         .and output(stdout).to_stdout
// 88:     end
// 89:
// 90:     it "reads inputs from a Brewfile alongside named arguments" do
// 91:       setup_test_formula "installed"
// 92:       brewfile = HOMEBREW_TEMP/"deps.Brewfile"
// 93:       brewfile.write <<~BREWFILE
// 94:         brew "baz"
// 95:         tap "ignored/tap"
// 96:       BREWFILE
// 97:       stdout = <<~EOS
// 98:         bar
// 99:         └── foo
// 100:
// 101:         baz
// 102:         ├── bar
// 103:         │   └── foo
// 104:         ├── recommended_test
// 105:         └── installed
// 106:
// 107:       EOS
// 108:       expect { brew "deps", "--tree", "bar", "--brewfile=#{brewfile}" }
// 109:         .to be_a_success
// 110:         .and output(stdout).to_stdout
// 111:     end
// 112:
// 113:     it "detects circular dependencies" do
// 114:       setup_test_formula "installed", <<~RUBY
// 115:         url "https://brew.sh/installed-1.0"
// 116:         depends_on "baz"
// 117:       RUBY
// 118:       stdout = <<~EOS
// 119:         baz
// 120:         ├── bar
// 121:         │   └── foo
// 122:         ├── recommended_test
// 123:         └── installed
// 124:             └── baz (CIRCULAR DEPENDENCY)
// 125:
// 126:       EOS
// 127:       expect { brew "deps", "baz", "--tree" }
// 128:         .to be_a_failure
// 129:         .and output(stdout).to_stdout
// 130:     end
// 131:   end
// 132: end
