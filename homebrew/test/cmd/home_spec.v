module cmd

import brew_runtime
import homebrew.cmd as cmd_core

fn home_spec_formula() cmd_core.HomeItem {
	return cmd_core.HomeItem{
		kind: .formula
		name: 'testballhome'
		homepage: 'https://brew.sh/testballhome'
	}
}

fn home_spec_cask(path string, inferred bool) cmd_core.HomeItem {
	return cmd_core.HomeItem{
		kind: .cask
		name: 'local-caffeine'
		homepage: 'https://brew.sh/'
		inferred_as_cask: inferred
		source_path: path
	}
}

// Translated from Homebrew/brew `test/cmd/home_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:testballhome) do` at line 8.
pub fn ruby_home_spec_l8_d1_testballhome(args ...brew_runtime.Value) brew_runtime.Value {
	return cmd_core.home_item_value(home_spec_formula())
}

// Ruby let `let(:testballhome_homepage) do` at line 15.
pub fn ruby_home_spec_l15_d2_testballhome_homepage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(home_spec_formula().homepage)
}

// Ruby let `let(:local_caffeine_path) do` at line 19.
pub fn ruby_home_spec_l19_d3_local_caffeine_path(args ...brew_runtime.Value) brew_runtime.Value {
	root := if args.len > 0 { args[0].as_string() } else { '/tmp/homebrew-test' }
	return brew_runtime.string_value('${root}/cask/Casks/local-caffeine.rb')
}

// Ruby let `let(:local_caffeine_homepage) do` at line 23.
pub fn ruby_home_spec_l23_d4_local_caffeine_homepage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('https://brew.sh/')
}

// Ruby it `it "opens the project page when no formula or cask is specified", :integration_test do` at line 29.
pub fn ruby_home_spec_l29_d5_opens(args ...brew_runtime.Value) brew_runtime.Value {
	plan := cmd_core.plan_home_command('https://brew.sh', [])
	return brew_runtime.bool_value(plan.homepages == ['https://brew.sh'] && plan.messages.len == 0 && plan.warnings.len == 0)
}

// Ruby it `it "opens the homepage for a given Formula" do` at line 36.
pub fn ruby_home_spec_l36_d6_opens(args ...brew_runtime.Value) brew_runtime.Value {
	plan := cmd_core.plan_home_command('https://brew.sh', [home_spec_formula()])
	return brew_runtime.bool_value(plan.homepages == ['https://brew.sh/testballhome'] && plan.messages == [
		'Opening homepage for Formula testballhome',
	])
}

// Ruby it `it "opens the homepage for a given Cask", :cask, :needs_macos do` at line 46.
pub fn ruby_home_spec_l46_d7_opens(args ...brew_runtime.Value) brew_runtime.Value {
	path := if args.len > 0 { args[0].as_string() } else { '/tmp/local-caffeine.rb' }
	inferred := cmd_core.plan_home_command('https://brew.sh', [
		home_spec_cask(path, true),
	])
	explicit := cmd_core.plan_home_command('https://brew.sh', [
		home_spec_cask(path, false),
	])
	return brew_runtime.bool_value(inferred.homepages == ['https://brew.sh/'] && inferred.messages == [
		'Opening homepage for Cask local-caffeine',
	] && inferred.warnings == ['Treating ${path} as a cask'] && explicit.warnings.len == 0)
}

// Ruby it `it "opens the homepages for a given formula and Cask", :cask, :needs_macos do` at line 61.
pub fn ruby_home_spec_l61_d8_opens(args ...brew_runtime.Value) brew_runtime.Value {
	path := if args.len > 0 { args[0].as_string() } else { '/tmp/local-caffeine.rb' }
	plan := cmd_core.plan_home_command('https://brew.sh', [
		home_spec_formula(),
		home_spec_cask(path, true),
	])
	return brew_runtime.bool_value(plan.homepages == [
		'https://brew.sh/testballhome',
		'https://brew.sh/',
	] && plan.messages == [
		'Opening homepage for Formula testballhome',
		'Opening homepage for Cask local-caffeine',
	] && plan.warnings == ['Treating ${path} as a cask'])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/home"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Home do
// 8:   let(:testballhome) do
// 9:     formula("testballhome") do
// 10:       T.bind(self, T.class_of(Formula))
// 11:       homepage "https://brew.sh/testballhome"
// 12:       url "https://brew.sh/testballhome-1.0"
// 13:     end
// 14:   end
// 15:   let(:testballhome_homepage) do
// 16:     testballhome.homepage
// 17:   end
// 18:
// 19:   let(:local_caffeine_path) do
// 20:     cask_path("local-caffeine")
// 21:   end
// 22:
// 23:   let(:local_caffeine_homepage) do
// 24:     Cask::CaskLoader.load(local_caffeine_path).homepage
// 25:   end
// 26:
// 27:   it_behaves_like "parseable arguments"
// 28:
// 29:   it "opens the project page when no formula or cask is specified", :integration_test do
// 30:     expect { brew "home", "HOMEBREW_BROWSER" => "echo" }
// 31:       .to output("https://brew.sh\n").to_stdout
// 32:       .and not_to_output.to_stderr
// 33:       .and be_a_success
// 34:   end
// 35:
// 36:   it "opens the homepage for a given Formula" do
// 37:     stub_formula_loader testballhome, call_original: true
// 38:     cmd = described_class.new(["testballhome"])
// 39:     expect(cmd).to receive(:exec_browser).with(testballhome_homepage)
// 40:
// 41:     expect { cmd.run }
// 42:       .to output(/Opening homepage for Formula testballhome/).to_stdout
// 43:       .and not_to_output.to_stderr
// 44:   end
// 45:
// 46:   it "opens the homepage for a given Cask", :cask, :needs_macos do
// 47:     cmd = described_class.new([local_caffeine_path.to_s])
// 48:     expect(cmd).to receive(:exec_browser).with(local_caffeine_homepage)
// 49:
// 50:     expect { cmd.run }
// 51:       .to output(/Opening homepage for Cask local-caffeine/).to_stdout
// 52:       .and output(/Treating #{Regexp.escape(local_caffeine_path)} as a cask/).to_stderr
// 53:     cmd = described_class.new(["--cask", local_caffeine_path.to_s])
// 54:     expect(cmd).to receive(:exec_browser).with(local_caffeine_homepage)
// 55:
// 56:     expect { cmd.run }
// 57:       .to output(/Opening homepage for Cask local-caffeine/).to_stdout
// 58:       .and not_to_output.to_stderr
// 59:   end
// 60:
// 61:   it "opens the homepages for a given formula and Cask", :cask, :needs_macos do
// 62:     stub_formula_loader testballhome, call_original: true
// 63:     cmd = described_class.new(["testballhome", local_caffeine_path.to_s])
// 64:     expect(cmd).to receive(:exec_browser).with(testballhome_homepage, local_caffeine_homepage)
// 65:
// 66:     expect { cmd.run }
// 67:       .to output(/Opening homepage for Formula testballhome.*Opening homepage for Cask local-caffeine/m).to_stdout
// 68:       .and output(/Treating #{Regexp.escape(local_caffeine_path)} as a cask/).to_stderr
// 69:   end
// 70: end
