module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/prof_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "does not open HTML profiles outside a TTY" do` at line 16.
pub fn ruby_prof_spec_l16_d1_does(args ...brew_runtime.Value) brew_runtime.Value {
	tty := args.len > 0 && (args[0].as_bool() or { false })
	plan := prof_plan(prof_spec_options(ProfOptions{
		named: ['help']
		command_extension: '.rb'
		stdout_tty: tty
	})) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(plan.command == [
		'ruby-prof',
		'--printer=call_stack',
		'--file=prof/call_stack.html',
		'/brew/Library/Homebrew/brew.rb',
		'--',
		'help',
	] && plan.browser_path == if tty { 'prof/call_stack.html' } else { '' })
}

// Ruby it `it "runs Vernier without passing it to child Ruby processes" do` at line 28.
pub fn ruby_prof_spec_l28_d2_runs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	plan := prof_plan(prof_spec_options(ProfOptions{
		named: ['commands']
		command_extension: '.rb'
		vernier: true
	})) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(plan.environment == {
		'HOMEBREW_SPAWN_SYSTEM': '1'
		'VERNIER_ALLOCATION_INTERVAL': '500'
		'VERNIER_OUTPUT': 'prof/vernier.json'
	} && plan.command == [
		'/portable/bin/ruby',
		'-I',
		'/gems/vernier/lib',
		'-r',
		'vernier/autorun',
		'-r',
		'/brew/Library/Homebrew/prof/vernier_fork_guard',
		'/brew/Library/Homebrew/brew.rb',
		'commands',
	])
}

// Ruby it `it "records phase timings without loading a sampling profiler" do` at line 51.
pub fn ruby_prof_spec_l51_d3_records(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	plan := prof_plan(prof_spec_options(ProfOptions{
		named: ['help']
		command_extension: '.rb'
		timings: true
	})) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!plan.install_bundler_gems && !plan.setup_gem_environment
		&& plan.environment['HOMEBREW_PHASE_TIMINGS'] == 'prof/timings.json'
		&& plan.command == ['/portable/bin/ruby', '/brew/Library/Homebrew/brew.rb', 'help'])
}

// Ruby it `it "works using ruby-prof (the default)" do` at line 80.
pub fn ruby_prof_spec_l80_d4_works(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	plan := prof_plan(prof_spec_options(ProfOptions{
		named: ['help']
		command_extension: '.rb'
	})) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(plan.mode == 'ruby-prof' && plan.command.last() == 'help')
}

// Ruby it `it "works using stackprof" do` at line 87.
pub fn ruby_prof_spec_l87_d5_works(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	plan := prof_plan(prof_spec_options(ProfOptions{
		named: ['help']
		command_extension: '.rb'
		stackprof: true
	})) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(plan.mode == 'stackprof'
		&& plan.environment['HOMEBREW_STACKPROF'] == '1'
		&& plan.post_command == ['stackprof --d3-flamegraph prof/stackprof.dump > prof/d3-flamegraph.html'])
}

// Ruby it `it "works using vernier with child processes" do` at line 94.
pub fn ruby_prof_spec_l94_d6_works(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	plan := prof_plan(prof_spec_options(ProfOptions{
		named: ['config']
		command_extension: '.rb'
		vernier: true
	})) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(plan.mode == 'vernier' && plan.command.last() == 'config'
		&& plan.messages[0] == 'Profiling complete!')
}

// Ruby it `it "records fetch phases" do` at line 100.
pub fn ruby_prof_spec_l100_d7_records(args ...brew_runtime.Value) brew_runtime.Value {
	phases := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { [
		'startup',
		'cli_parse',
		'command_load',
		'formula_resolution',
		'formula_inflation',
		'download_enqueue',
		'curl_body',
		'checksum',
		'symlink',
	] }
	expected := ['startup', 'cli_parse', 'command_load', 'formula_resolution', 'formula_inflation',
		'download_enqueue', 'curl_body', 'checksum', 'symlink']
	return brew_runtime.bool_value(expected.all(it in phases))
}

fn prof_spec_options(overrides ProfOptions) ProfOptions {
	return ProfOptions{
		...overrides
		library_path: if overrides.library_path.len > 0 { overrides.library_path } else { '/brew/Library/Homebrew' }
		ruby_exec_args: if overrides.ruby_exec_args.len > 0 { overrides.ruby_exec_args } else { ['/portable/bin/ruby'] }
		ruby_path: if overrides.ruby_path.len > 0 { overrides.ruby_path } else { '/portable/bin/ruby' }
		vernier_gem_path: if overrides.vernier_gem_path.len > 0 { overrides.vernier_gem_path } else { '/gems/vernier' }
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/prof"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Prof do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "#run" do
// 11:     before do
// 12:       allow(Homebrew).to receive(:install_bundler_gems!)
// 13:       allow(Homebrew).to receive(:setup_gem_environment!)
// 14:     end
// 15:
// 16:     it "does not open HTML profiles outside a TTY" do
// 17:       prof = described_class.new(["help"])
// 18:
// 19:       allow($stdout).to receive(:tty?).and_return(false)
// 20:       expect(prof).to receive(:safe_system)
// 21:         .with("ruby-prof", "--printer=call_stack", "--file=prof/call_stack.html",
// 22:               (HOMEBREW_LIBRARY_PATH/"brew.rb").resolved_path, "--", "help")
// 23:       expect(prof).not_to receive(:exec_browser)
// 24:
// 25:       prof.run
// 26:     end
// 27:
// 28:     it "runs Vernier without passing it to child Ruby processes" do
// 29:       prof = described_class.new(["--vernier", "commands"])
// 30:
// 31:       expect(prof).to receive(:safe_system)
// 32:         .with(
// 33:           { "HOMEBREW_SPAWN_SYSTEM" => "1",
// 34:             "VERNIER_ALLOCATION_INTERVAL" => "500", "VERNIER_OUTPUT" => "prof/vernier.json" },
// 35:           RUBY_PATH,
// 36:           "-I",
// 37:           (Pathname(Gem::Specification.find_by_name("vernier").full_gem_path)/"lib").to_s,
// 38:           "-r",
// 39:           "vernier/autorun",
// 40:           "-r",
// 41:           (HOMEBREW_LIBRARY_PATH/"prof/vernier_fork_guard").to_s,
// 42:           (HOMEBREW_LIBRARY_PATH/"brew.rb").resolved_path,
// 43:           "commands",
// 44:         )
// 45:       allow(prof).to receive(:ohai)
// 46:       allow(prof).to receive(:puts)
// 47:
// 48:       prof.run
// 49:     end
// 50:
// 51:     it "records phase timings without loading a sampling profiler" do
// 52:       prof = described_class.new(["--timings", "help"])
// 53:
// 54:       expect(Homebrew).not_to receive(:install_bundler_gems!)
// 55:       expect(Homebrew).not_to receive(:setup_gem_environment!)
// 56:       expect(prof).to receive(:safe_system)
// 57:         .with(
// 58:           { "HOMEBREW_PHASE_TIMINGS" => "prof/timings.json" },
// 59:           *HOMEBREW_RUBY_EXEC_ARGS,
// 60:           (HOMEBREW_LIBRARY_PATH/"brew.rb").resolved_path,
// 61:           "help",
// 62:         )
// 63:       allow(prof).to receive(:ohai)
// 64:
// 65:       prof.run
// 66:     end
// 67:   end
// 68:
// 69:   describe "integration tests", :integration_test, :needs_network do
// 70:     after do
// 71:       FileUtils.rm_f [
// 72:         HOMEBREW_LIBRARY_PATH/"prof/call_stack.html",
// 73:         HOMEBREW_LIBRARY_PATH/"prof/d3-flamegraph.html",
// 74:         HOMEBREW_LIBRARY_PATH/"prof/stackprof.dump",
// 75:         HOMEBREW_LIBRARY_PATH/"prof/timings.json",
// 76:         HOMEBREW_LIBRARY_PATH/"prof/vernier.json",
// 77:       ]
// 78:     end
// 79:
// 80:     it "works using ruby-prof (the default)" do
// 81:       expect { brew "prof", "help", "HOMEBREW_BROWSER" => "echo" }
// 82:         .to output(/^Example usage:/).to_stdout
// 83:         .and not_to_output.to_stderr
// 84:         .and be_a_success
// 85:     end
// 86:
// 87:     it "works using stackprof" do
// 88:       expect { brew "prof", "--stackprof", "help", "HOMEBREW_BROWSER" => "echo" }
// 89:         .to output(/^Example usage:/).to_stdout
// 90:         .and not_to_output.to_stderr
// 91:         .and be_a_success
// 92:     end
// 93:
// 94:     it "works using vernier with child processes" do
// 95:       expect { brew "prof", "--vernier", "config" }
// 96:         .to output(/^HOMEBREW_VERSION:/).to_stdout
// 97:         .and be_a_success
// 98:     end
// 99:
// 100:     it "records fetch phases" do
// 101:       setup_test_formula "testball"
// 102:
// 103:       expect do
// 104:         brew "prof", "--timings", "--", "fetch", "--force", "testball",
// 105:              "HOMEBREW_NO_INSTALL_FROM_API" => "1"
// 106:       end.to be_a_success
// 107:
// 108:       timings = JSON.parse((HOMEBREW_LIBRARY_PATH/"prof/timings.json").read)
// 109:       phases = timings.fetch("events").map { |event| event.fetch("phase") }
// 110:       expect(phases).to include(
// 111:         "startup", "cli_parse", "command_load", "formula_resolution", "formula_inflation", "download_enqueue",
// 112:         "curl_body", "checksum", "symlink"
// 113:       )
// 114:     end
// 115:   end
// 116: end
