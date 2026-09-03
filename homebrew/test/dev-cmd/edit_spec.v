module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/edit_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "opens a given Formula in an editor", :integration_test do` at line 10.
pub fn ruby_edit_spec_l10_d1_opens(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'edit command input is required')
	}
	result := run_edit(edit_input_from_value(args[0]).options) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.editor_invoked && result.editor_command.len > 0
		&& result.editor_command[0] == '/bin/cat' && result.stdout.contains('# something here')
		&& result.stderr == '')
}

// Ruby it `it "auto-taps core when editing an API-known formula without the tap installed" do` at line 23.
pub fn ruby_edit_spec_l23_d2_auto_taps(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'edit command input is required')
	}
	input := edit_input_from_value(args[0])
	result := run_edit(input.options) or { return brew_runtime.bool_value(false) }
	core_tap_name := edit_core_tap_name(input.options)
	return brew_runtime.bool_value(result.tap_installs.any(it.name == core_tap_name && it.force)
		&& result.editor_invoked)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/edit"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Edit do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "opens a given Formula in an editor", :integration_test do
// 11:     HOMEBREW_REPOSITORY.cd do
// 12:       system "git", "init"
// 13:     end
// 14:
// 15:     setup_test_formula "testball"
// 16:
// 17:     expect { brew "edit", "testball", "HOMEBREW_EDITOR" => "/bin/cat", "HOMEBREW_NO_ENV_HINTS" => "1" }
// 18:       .to output(/# something here/).to_stdout
// 19:       .and not_to_output.to_stderr
// 20:       .and be_a_success
// 21:   end
// 22:
// 23:   it "auto-taps core when editing an API-known formula without the tap installed" do
// 24:     (HOMEBREW_REPOSITORY/".git").mkpath
// 25:
// 26:     allow(CoreTap.instance).to receive(:installed?).and_return(false)
// 27:
// 28:     require "api"
// 29:     allow(Homebrew::API).to receive(:formula_name?).with("testball").and_return(true)
// 30:     allow(Homebrew::API::Formula).to receive(:all_formulae).and_return("testball" => {})
// 31:
// 32:     expect(CoreTap.instance).to receive(:install).with(force: true) do
// 33:       allow(CoreTap.instance).to receive(:installed?).and_return(true)
// 34:       CoreTap.instance.clear_cache
// 35:
// 36:       formula_path = CoreTap.instance.path/"Formula"/"testball.rb"
// 37:       formula_path.dirname.mkpath
// 38:       formula_path.write <<~RUBY
// 39:         class Testball < Formula
// 40:           url "https://brew.sh/testball-1.0"
// 41:         end
// 42:       RUBY
// 43:     end
// 44:
// 45:     allow_any_instance_of(described_class).to receive(:exec_editor)
// 46:
// 47:     described_class.new(["testball"]).run
// 48:   end
// 49: end
