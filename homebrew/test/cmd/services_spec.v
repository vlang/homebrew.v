module cmd

import homebrew.cmd as services_core

// Translated from Homebrew/brew `test/cmd/services_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "sets canonical subcommand names", :aggregate_failures do` at line 10.
pub fn ruby_services_spec_l10_d1_sets() bool {
	default_result := services_core.run_services_command([]string{}) or { return false }
	info_result := services_core.run_services_command(['i', 'testball']) or { return false }
	return default_result.subcommand == 'list' && info_result.subcommand == 'info'
}

// Ruby it `it "rejects file-only options for info" do` at line 15.
pub fn ruby_services_spec_l15_d2_rejects() bool {
	services_core.run_services_command(['info', 'testball', '--file=/tmp/service.plist']) or {
		return err.msg().contains('`info` subcommand does not accept the `--file` flag')
	}
	return false
}

// Ruby it `it "uses operation-specific --all descriptions", :aggregate_failures do` at line 20.
pub fn ruby_services_spec_l20_d3_uses() bool {
	expected := {
		'start':   'Start all services and register them to launch at login (or boot).'
		'stop':    'Stop all services and unregister them from launching at login (or boot), unless `--keep` is specified.'
		'run':     'Run all services without registering them to launch at login (or boot).'
		'restart': 'Restart all services.'
		'kill':    'Stop all services immediately but keep them registered to launch at login (or boot).'
		'info':    'List all managed services.'
	}
	for subcommand, description in expected {
		if (services_core.services_all_description(subcommand) or { '' }) != description {
			return false
		}
	}
	return true
}

// Ruby it `it "allows controlling services", :integration_test do` at line 41.
pub fn ruby_services_spec_l41_d4_allows() bool {
	result := services_core.run_services_command(['list']) or { return false }
	return result.subcommand == 'list' && result.output == ''
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/services"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Services, :needs_daemon_manager do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "sets canonical subcommand names", :aggregate_failures do
// 11:     expect(described_class.new([]).args.subcommand).to eq("list")
// 12:     expect(described_class.new(%w[i testball]).args.subcommand).to eq("info")
// 13:   end
// 14:
// 15:   it "rejects file-only options for info" do
// 16:     expect { described_class.new(%w[info testball --file=/tmp/service.plist]) }
// 17:       .to raise_error(UsageError, /`info` subcommand does not accept the `--file` flag/)
// 18:   end
// 19:
// 20:   it "uses operation-specific --all descriptions", :aggregate_failures do
// 21:     subcommand_options = lambda do |subcommand|
// 22:       described_class.parser
// 23:                      .processed_options_for_subcommand(subcommand)
// 24:                      .filter_map do |_, long, description, hidden|
// 25:         [long, description] unless hidden
// 26:       end.to_h
// 27:     end
// 28:
// 29:     expect(subcommand_options.call("start")["--all"])
// 30:       .to eq("Start all services and register them to launch at login (or boot).")
// 31:     expect(subcommand_options.call("stop")["--all"])
// 32:       .to eq("Stop all services and unregister them from launching at login (or boot), unless `--keep` is specified.")
// 33:     expect(subcommand_options.call("run")["--all"])
// 34:       .to eq("Run all services without registering them to launch at login (or boot).")
// 35:     expect(subcommand_options.call("restart")["--all"]).to eq("Restart all services.")
// 36:     expect(subcommand_options.call("kill")["--all"])
// 37:       .to eq("Stop all services immediately but keep them registered to launch at login (or boot).")
// 38:     expect(subcommand_options.call("info")["--all"]).to eq("List all managed services.")
// 39:   end
// 40:
// 41:   it "allows controlling services", :integration_test do
// 42:     expect { brew "services", "list" }
// 43:       .to not_to_output.to_stderr
// 44:       .and not_to_output.to_stdout
// 45:       .and be_a_success
// 46:   end
// 47: end
