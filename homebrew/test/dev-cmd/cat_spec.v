module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/cat_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses a system bat when configured" do` at line 10.
pub fn ruby_cat_spec_l10_d1_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "prints the content of a given Formula", :integration_test do` at line 36.
pub fn ruby_cat_spec_l36_d2_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/cat"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Cat do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "uses a system bat when configured" do
// 11:     formula_file = Formulary.find_formula_in_tap("testball", CoreTap.instance)
// 12:     formula_file.dirname.mkpath
// 13:     formula_file.write <<~RUBY
// 14:       class Testball < Formula
// 15:         url "https://brew.sh/testball-1.0"
// 16:       end
// 17:     RUBY
// 18:     CoreTap.instance.clear_cache
// 19:
// 20:     cat = described_class.new(["testball"])
// 21:     formula = instance_double(Formula)
// 22:
// 23:     allow(Homebrew::EnvConfig).to receive_messages(bat?: true, bat_config_path: "/tmp/bat.conf", bat_theme: "ansi")
// 24:     allow(Formula).to receive(:[]).with("bat").and_return(formula)
// 25:     allow(formula).to receive(:ensure_installed!).with(
// 26:       reason:           "displaying <formula>/<cask> source",
// 27:       output_to_stderr: true,
// 28:       executable:       "bat",
// 29:     ).and_return(Pathname.new("/usr/bin/bat"))
// 30:
// 31:     expect(cat).to receive(:safe_system).with(Pathname.new("/usr/bin/bat"), formula_file)
// 32:
// 33:     cat.run
// 34:   end
// 35:
// 36:   it "prints the content of a given Formula", :integration_test do
// 37:     formula_file = setup_test_formula "testball"
// 38:     content = formula_file.read
// 39:
// 40:     expect { brew "cat", "testball" }
// 41:       .to output(content).to_stdout
// 42:       .and not_to_output.to_stderr
// 43:       .and be_a_success
// 44:   end
// 45: end
