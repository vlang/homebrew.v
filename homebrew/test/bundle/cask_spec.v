module bundle

import brew_runtime
import homebrew.bundle as brew_bundle

// Translated from Homebrew/brew `test/bundle/cask_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn cask_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn cask_spec_foo() brew_bundle.BundleCask {
	return brew_bundle.BundleCask{
		name: 'foo'
		full_name: 'foo'
	}
}

fn cask_spec_baz() brew_bundle.BundleCask {
	return brew_bundle.BundleCask{
		name: 'baz'
		full_name: 'baz'
		desc: 'Software'
	}
}

fn cask_spec_bar() brew_bundle.BundleCask {
	return brew_bundle.BundleCask{
		name: 'bar'
		full_name: 'bar'
		explicit: {
			'fontdir':   brew_runtime.string_value('/Library/Fonts')
			'languages': brew_runtime.string_array_value(['zh-TW'])
		}
	}
}

fn cask_spec_dump_state() brew_bundle.BundleCaskState {
	return brew_bundle.BundleCaskState{
		cask_available: true
		casks: [cask_spec_foo(), cask_spec_bar(), cask_spec_baz()]
		trusted_casks: ['bar']
	}
}

fn cask_spec_command_effect(command []string, result bool) brew_bundle.BundleCaskEffects {
	return brew_bundle.BundleCaskEffects{
		command_results: {
			command.join('\x1f'): result
		}
	}
}

fn cask_spec_action_result(value brew_runtime.Value) bool {
	return (value.map_data['result'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
}

// Ruby subject `subject(:dumper) { described_class }` at line 11.
pub fn ruby_cask_spec_l11_d1_dumper(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Homebrew::Bundle::Cask', 'Homebrew::Bundle::Cask')
}

// Ruby specify `specify do` at line 19.
pub fn ruby_cask_spec_l19_d2_do(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{}
	return cask_spec_bool(brew_bundle.bundle_cask_names(state).len == 0 && brew_bundle.bundle_cask_dump(state, false) == '')
}

// Ruby specify `specify do` at line 32.
pub fn ruby_cask_spec_l32_d3_do(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{ cask_available: true }
	return cask_spec_bool(brew_bundle.bundle_cask_names(state).len == 0 && brew_bundle.bundle_cask_dump(state, false) == '')
}

// Ruby it `it "doesn't want to greedily update a non-installed cask" do` at line 37.
pub fn ruby_cask_spec_l37_d4_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(!brew_bundle.bundle_cask_greedy_outdated(brew_bundle.BundleCaskState{
		cask_available: true
	}, 'foo'))
}

// Ruby let `let(:foo) { instance_double(Cask::Cask, to_s: "foo", full_name: "foo", desc: nil, config: nil) }` at line 43.
pub fn ruby_cask_spec_l43_d5_foo(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_bundle.bundle_cask_value(cask_spec_foo())
}

// Ruby let `let(:baz) { instance_double(Cask::Cask, to_s: "baz", full_name: "baz", desc: "Software", config: nil) }` at line 44.
pub fn ruby_cask_spec_l44_d6_baz(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_bundle.bundle_cask_value(cask_spec_baz())
}

// Ruby let `let(:bar) do` at line 45.
pub fn ruby_cask_spec_l45_d7_bar(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_bundle.bundle_cask_value(cask_spec_bar())
}

// Ruby it `it "returns list %w[foo bar baz]" do` at line 67.
pub fn ruby_cask_spec_l67_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(brew_bundle.bundle_cask_names(cask_spec_dump_state()) == [
		'foo',
		'bar',
		'baz',
	])
}

// Ruby it `it "dumps as `cask 'baz'` and `cask 'foo' cask 'bar'` plus descriptions and config values" do` at line 71.
pub fn ruby_cask_spec_l71_d9_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	expected := 'cask "foo"\ncask "bar", args: { fontdir: "/Library/Fonts", language: "zh-TW" }, trusted: true\n# Software\ncask "baz"'
	return cask_spec_bool(brew_bundle.bundle_cask_dump(cask_spec_dump_state(), true) == expected)
}

// Ruby it `it "doesn't want to greedily update a non-installed cask" do` at line 82.
pub fn ruby_cask_spec_l82_d10_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(!brew_bundle.bundle_cask_greedy_outdated(cask_spec_dump_state(), 'qux'))
}

// Ruby it `it "wants to greedily update foo if there is an update available" do` at line 86.
pub fn ruby_cask_spec_l86_d11_wants(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(brew_bundle.bundle_cask_greedy_outdated(brew_bundle.BundleCaskState{
		cask_available: true
		casks: [brew_bundle.BundleCask{
			name: 'foo'
			full_name: 'foo'
			greedy_outdated: true
		}]
	}, 'foo'))
}

// Ruby it `it "does not want to greedily update foo if it is pinned" do` at line 92.
pub fn ruby_cask_spec_l92_d12_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(!brew_bundle.bundle_cask_greedy_outdated(brew_bundle.BundleCaskState{
		cask_available: true
		casks: [brew_bundle.BundleCask{
			name: 'foo'
			full_name: 'foo'
			pinned: true
			greedy_outdated: true
		}]
	}, 'foo'))
}

// Ruby it `it "does not want to greedily update bar if there is no update available" do` at line 98.
pub fn ruby_cask_spec_l98_d13_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(!brew_bundle.bundle_cask_greedy_outdated(brew_bundle.BundleCaskState{
		cask_available: true
		casks: [cask_spec_bar()]
	}, 'bar'))
}

// Ruby it `it "returns an empty string when no casks are installed" do` at line 110.
pub fn ruby_cask_spec_l110_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(brew_bundle.bundle_cask_oldnames(brew_bundle.BundleCaskState{}).len == 0)
}

// Ruby it `it "returns a hash with installed casks old names" do` at line 114.
pub fn ruby_cask_spec_l114_d15_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	oldnames := brew_bundle.bundle_cask_oldnames(brew_bundle.BundleCaskState{
		cask_available: true
		casks: [brew_bundle.BundleCask{
			name: 'foo'
			full_name: 'qux/quuz/foo'
			old_tokens: ['oldfoo']
		}, brew_bundle.BundleCask{
			name: 'bar'
			full_name: 'bar'
		}]
	})
	return cask_spec_bool(oldnames == {
		'qux/quuz/oldfoo': 'qux/quuz/foo'
		'oldfoo':          'qux/quuz/foo'
	})
}

// Ruby it `it "returns an empty array" do` at line 132.
pub fn ruby_cask_spec_l132_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(brew_bundle.bundle_cask_formula_dependencies(brew_bundle.BundleCaskState{}, [
		'foo',
	]).len == 0)
}

// Ruby it `it "returns an array of unique formula dependencies" do` at line 146.
pub fn ruby_cask_spec_l146_d17_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{
		cask_available: true
		casks: [brew_bundle.BundleCask{
			name: 'foo'
			full_name: 'foo'
			formula_dependencies: ['baz', 'qux']
		}, brew_bundle.BundleCask{
			name: 'bar'
			full_name: 'bar'
		}]
	}
	return cask_spec_bool(brew_bundle.bundle_cask_formula_dependencies(state, ['foo', 'bar']) == [
		'baz',
		'qux',
	])
}

// Ruby it `it "loads formula dependencies from the cask definition" do` at line 157.
pub fn ruby_cask_spec_l157_d18_loads(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{
		loadable_casks: [brew_bundle.BundleCask{
			name: 'tpack'
			full_name: 'tmuxpack/tpack/tpack'
			formula_dependencies: ['tmux']
		}]
	}
	return cask_spec_bool(brew_bundle.bundle_cask_formula_dependencies(state, [
		'tmuxpack/tpack/tpack',
	]) == ['tmux'])
}

// Ruby it `it "shells out" do` at line 179.
pub fn ruby_cask_spec_l179_d19_shells(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(brew_bundle.bundle_cask_installed_names(brew_bundle.BundleCaskState{}).len == 0)
}

// Ruby it `it "returns result" do` at line 185.
pub fn ruby_cask_spec_l185_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{
		installed_casks: ['foo', 'baz']
		installed_override: true
		outdated_casks: ['baz']
		outdated_override: true
	}
	return cask_spec_bool(brew_bundle.bundle_cask_installed_and_up_to_date(state, 'foo', false) && !brew_bundle.bundle_cask_installed_and_up_to_date(state, 'baz', false))
}

// Ruby it `it "returns empty array" do` at line 196.
pub fn ruby_cask_spec_l196_d21_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(brew_bundle.bundle_cask_outdated_casks(brew_bundle.BundleCaskState{}).len == 0)
}

// Ruby it `it "returns empty array" do` at line 210.
pub fn ruby_cask_spec_l210_d22_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_spec_bool(brew_bundle.bundle_cask_outdated_casks(brew_bundle.BundleCaskState{
		cask_available: true
	}).len == 0)
}

// Ruby it `it "does not include pinned casks" do` at line 215.
pub fn ruby_cask_spec_l215_d23_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{
		cask_available: true
		casks: [brew_bundle.BundleCask{
			name: 'google-chrome'
			full_name: 'google-chrome'
			pinned: true
			outdated: true
		}, brew_bundle.BundleCask{
			name: 'firefox'
			full_name: 'firefox'
			outdated: true
		}]
	}
	return cask_spec_bool(brew_bundle.bundle_cask_outdated_casks(state) == ['firefox'])
}

// Ruby it `it "skips" do` at line 232.
pub fn ruby_cask_spec_l232_d24_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result, _ := brew_bundle.bundle_cask_preinstall(brew_bundle.BundleCaskState{
		installed_casks: ['google-chrome']
		installed_override: true
	}, 'google-chrome', false, false, brew_bundle.BundleCaskOptions{})
	return cask_spec_bool(!result)
}

// Ruby it `it "upgrades" do` at line 244.
pub fn ruby_cask_spec_l244_d25_upgrades(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{
		installed_casks: ['google-chrome']
		installed_override: true
		outdated_casks: ['google-chrome']
		outdated_override: true
	}
	preinstall, _ := brew_bundle.bundle_cask_preinstall(state, 'google-chrome', false, false, brew_bundle.BundleCaskOptions{})
	action := brew_bundle.bundle_cask_install(state, 'google-chrome', true, false, false, false, brew_bundle.BundleCaskOptions{}, cask_spec_command_effect([
		'upgrade',
		'--cask',
		'google-chrome',
	], true))
	return cask_spec_bool(preinstall && action.success && action.commands == [[
		'upgrade',
		'--cask',
		'google-chrome',
	]])
}

// Ruby it `it "upgrades" do` at line 260.
pub fn ruby_cask_spec_l260_d26_upgrades(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{
		cask_available: true
		casks: [brew_bundle.BundleCask{
			name: 'opera'
			full_name: 'opera'
			greedy_outdated: true
		}]
	}
	options := brew_bundle.BundleCaskOptions{ greedy: true }
	preinstall, _ := brew_bundle.bundle_cask_preinstall(state, 'opera', false, false, options)
	action := brew_bundle.bundle_cask_install(state, 'opera', true, false, false, false, options, cask_spec_command_effect([
		'upgrade',
		'--cask',
		'opera',
	], true))
	return cask_spec_bool(preinstall && action.success && action.commands == [[
		'upgrade',
		'--cask',
		'opera',
	]])
}

// Ruby it `it "installs cask" do` at line 274.
pub fn ruby_cask_spec_l274_d27_installs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{
		installed_override: true
	}
	preinstall, _ := brew_bundle.bundle_cask_preinstall(state, 'google-chrome', false, false, brew_bundle.BundleCaskOptions{})
	action := brew_bundle.bundle_cask_install(state, 'google-chrome', true, false, false, false, brew_bundle.BundleCaskOptions{}, cask_spec_command_effect([
		'install',
		'--cask',
		'google-chrome',
		'--adopt',
	], true))
	return cask_spec_bool(preinstall && action.success && action.commands == [[
		'install',
		'--cask',
		'google-chrome',
		'--adopt',
	]])
}

// Ruby it `it "trusts the cask before installing it" do` at line 282.
pub fn ruby_cask_spec_l282_d28_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	options := brew_bundle.BundleCaskOptions{
		full_name: 'puma/puma/puma-cask'
		trusted: true
	}
	action := brew_bundle.bundle_cask_install(brew_bundle.BundleCaskState{
		installed_override: true
	}, 'puma-cask', true, false, false, false, options, cask_spec_command_effect([
		'install',
		'--cask',
		'puma/puma/puma-cask',
		'--adopt',
	], true))
	return cask_spec_bool(action.trusted == ['puma/puma/puma-cask'])
}

// Ruby it `it "does not trust an unqualified cask token" do` at line 288.
pub fn ruby_cask_spec_l288_d29_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	action := brew_bundle.bundle_cask_install(brew_bundle.BundleCaskState{
		installed_override: true
	}, 'google-chrome', true, false, false, false, brew_bundle.BundleCaskOptions{
		trusted: true
	}, cask_spec_command_effect(['install', '--cask', 'google-chrome', '--adopt'], true))
	return cask_spec_bool(action.trusted.len == 0)
}

// Ruby it `it "installs cask with arguments" do` at line 294.
pub fn ruby_cask_spec_l294_d30_installs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	options := brew_bundle.BundleCaskOptions{
		args: {
			'appdir': brew_runtime.string_value('/Applications')
		}
	}
	action := brew_bundle.bundle_cask_install(brew_bundle.BundleCaskState{
		installed_override: true
	}, 'firefox', true, false, false, false, options, cask_spec_command_effect([
		'install',
		'--cask',
		'firefox',
		'--appdir=/Applications',
		'--adopt',
	], true))
	return cask_spec_bool(action.success && action.commands == [[
		'install',
		'--cask',
		'firefox',
		'--appdir=/Applications',
		'--adopt',
	]])
}

// Ruby it `it "reports a failure" do` at line 304.
pub fn ruby_cask_spec_l304_d31_reports(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	action := brew_bundle.bundle_cask_install(brew_bundle.BundleCaskState{
		installed_override: true
	}, 'google-chrome', true, false, false, false, brew_bundle.BundleCaskOptions{}, cask_spec_command_effect([
		'install',
		'--cask',
		'google-chrome',
		'--adopt',
	], false))
	return cask_spec_bool(!action.success)
}

// Ruby it `it "includes a flag if true" do` at line 313.
pub fn ruby_cask_spec_l313_d32_includes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	options := brew_bundle.BundleCaskOptions{
		args: {
			'force': brew_runtime.bool_value(true)
		}
	}
	action := brew_bundle.bundle_cask_install(brew_bundle.BundleCaskState{
		installed_override: true
	}, 'iterm', true, false, false, false, options, cask_spec_command_effect([
		'install',
		'--cask',
		'iterm',
		'--force',
	], true))
	return cask_spec_bool(action.success && action.commands == [[
		'install',
		'--cask',
		'iterm',
		'--force',
	]])
}

// Ruby it `it "does not include a flag if false" do` at line 321.
pub fn ruby_cask_spec_l321_d33_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	options := brew_bundle.BundleCaskOptions{
		args: {
			'force': brew_runtime.bool_value(false)
		}
	}
	action := brew_bundle.bundle_cask_install(brew_bundle.BundleCaskState{
		installed_override: true
	}, 'iterm', true, false, false, false, options, cask_spec_command_effect([
		'install',
		'--cask',
		'iterm',
		'--adopt',
	], true))
	return cask_spec_bool(action.success && action.commands == [[
		'install',
		'--cask',
		'iterm',
		'--adopt',
	]])
}

// Ruby it `it "runs the postinstall command" do` at line 339.
pub fn ruby_cask_spec_l339_d34_runs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{
		installed_casks: ['google-chrome']
		installed_override: true
		outdated_casks: ['google-chrome']
		outdated_override: true
	}
	options := brew_bundle.BundleCaskOptions{ postinstall: 'custom command' }
	effects := brew_bundle.BundleCaskEffects{
		command_results: {
			['upgrade', '--cask', 'google-chrome'].join('\x1f'): true
		}
		postinstall_results: {
			'custom command': true
		}
	}
	action := brew_bundle.bundle_cask_install(state, 'google-chrome', true, false, false, false, options, effects)
	return cask_spec_bool(action.success)
}

// Ruby it `it "reports a failure when postinstall fails" do` at line 345.
pub fn ruby_cask_spec_l345_d35_reports(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := brew_bundle.BundleCaskState{
		installed_casks: ['google-chrome']
		installed_override: true
		outdated_casks: ['google-chrome']
		outdated_override: true
	}
	options := brew_bundle.BundleCaskOptions{ postinstall: 'custom command' }
	effects := brew_bundle.BundleCaskEffects{
		command_results: {
			['upgrade', '--cask', 'google-chrome'].join('\x1f'): true
		}
		postinstall_results: {
			'custom command': false
		}
	}
	action := brew_bundle.bundle_cask_install(state, 'google-chrome', true, false, false, false, options, effects)
	return cask_spec_bool(!action.success)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/cask"
// 6: require "cask"
// 7: require "cask/cask_loader"
// 8:
// 9: RSpec.describe Homebrew::Bundle::Cask do
// 10:   describe "dumping" do
// 11:     subject(:dumper) { described_class }
// 12:
// 13:     context "when brew-cask is not installed" do
// 14:       before do
// 15:         described_class.reset!
// 16:         allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(false)
// 17:       end
// 18:
// 19:       specify do
// 20:         expect(dumper.cask_names).to be_empty
// 21:         expect(dumper.dump).to eql("")
// 22:       end
// 23:     end
// 24:
// 25:     context "when there is no cask" do
// 26:       before do
// 27:         described_class.reset!
// 28:         allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 29:         allow(Cask::Caskroom).to receive(:casks).and_return([])
// 30:       end
// 31:
// 32:       specify do
// 33:         expect(dumper.cask_names).to be_empty
// 34:         expect(dumper.dump).to eql("")
// 35:       end
// 36:
// 37:       it "doesn't want to greedily update a non-installed cask" do
// 38:         expect(dumper.cask_is_outdated_using_greedy?("foo")).to be(false)
// 39:       end
// 40:     end
// 41:
// 42:     context "when casks `foo`, `bar` and `baz` are installed, with `baz` being a formula requirement" do
// 43:       let(:foo) { instance_double(Cask::Cask, to_s: "foo", full_name: "foo", desc: nil, config: nil) }
// 44:       let(:baz) { instance_double(Cask::Cask, to_s: "baz", full_name: "baz", desc: "Software", config: nil) }
// 45:       let(:bar) do
// 46:         instance_double(
// 47:           Cask::Cask, to_s:      "bar",
// 48:                       full_name: "bar",
// 49:                       desc:      nil,
// 50:                       config:    instance_double(
// 51:                         Cask::Config,
// 52:                         explicit: {
// 53:                           fontdir:   "/Library/Fonts",
// 54:                           languages: ["zh-TW"],
// 55:                         },
// 56:                       )
// 57:         )
// 58:       end
// 59:
// 60:       before do
// 61:         described_class.reset!
// 62:
// 63:         allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 64:         allow(Cask::Caskroom).to receive(:casks).and_return([foo, bar, baz])
// 65:       end
// 66:
// 67:       it "returns list %w[foo bar baz]" do
// 68:         expect(dumper.cask_names).to eql(%w[foo bar baz])
// 69:       end
// 70:
// 71:       it "dumps as `cask 'baz'` and `cask 'foo' cask 'bar'` plus descriptions and config values" do
// 72:         expected = <<~RUBY
// 73:           cask "foo"
// 74:           cask "bar", args: { fontdir: "/Library/Fonts", language: "zh-TW" }, trusted: true
// 75:           # Software
// 76:           cask "baz"
// 77:         RUBY
// 78:         allow(Homebrew::Trust).to receive(:trusted_entries).with(:cask).and_return(["bar"])
// 79:         expect(dumper.dump(describe: true)).to eql(expected.chomp)
// 80:       end
// 81:
// 82:       it "doesn't want to greedily update a non-installed cask" do
// 83:         expect(dumper.cask_is_outdated_using_greedy?("qux")).to be(false)
// 84:       end
// 85:
// 86:       it "wants to greedily update foo if there is an update available" do
// 87:         allow(foo).to receive(:pinned?).and_return(false)
// 88:         expect(foo).to receive(:outdated?).with(greedy: true).and_return(true)
// 89:         expect(dumper.cask_is_outdated_using_greedy?("foo")).to be(true)
// 90:       end
// 91:
// 92:       it "does not want to greedily update foo if it is pinned" do
// 93:         allow(foo).to receive(:pinned?).and_return(true)
// 94:         expect(foo).not_to receive(:outdated?)
// 95:         expect(dumper.cask_is_outdated_using_greedy?("foo")).to be(false)
// 96:       end
// 97:
// 98:       it "does not want to greedily update bar if there is no update available" do
// 99:         allow(bar).to receive(:pinned?).and_return(false)
// 100:         expect(bar).to receive(:outdated?).with(greedy: true).and_return(false)
// 101:         expect(dumper.cask_is_outdated_using_greedy?("bar")).to be(false)
// 102:       end
// 103:     end
// 104:
// 105:     describe "#cask_oldnames" do
// 106:       before do
// 107:         described_class.reset!
// 108:       end
// 109:
// 110:       it "returns an empty string when no casks are installed" do
// 111:         expect(dumper.cask_oldnames).to eql({})
// 112:       end
// 113:
// 114:       it "returns a hash with installed casks old names" do
// 115:         foo = instance_double(Cask::Cask, to_s: "foo", old_tokens: ["oldfoo"], full_name: "qux/quuz/foo")
// 116:         bar = instance_double(Cask::Cask, to_s: "bar", old_tokens: [], full_name: "bar")
// 117:         allow(Cask::Caskroom).to receive(:casks).and_return([foo, bar])
// 118:         allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 119:         expect(dumper.cask_oldnames).to eql({
// 120:           "qux/quuz/oldfoo" => "qux/quuz/foo",
// 121:           "oldfoo"          => "qux/quuz/foo",
// 122:         })
// 123:       end
// 124:     end
// 125:
// 126:     describe "#formula_dependencies" do
// 127:       context "when the given casks don't have formula dependencies" do
// 128:         before do
// 129:           described_class.reset!
// 130:         end
// 131:
// 132:         it "returns an empty array" do
// 133:           expect(dumper.formula_dependencies(["foo"])).to eql([])
// 134:         end
// 135:       end
// 136:
// 137:       context "when multiple casks have the same dependency" do
// 138:         before do
// 139:           described_class.reset!
// 140:           foo = instance_double(Cask::Cask, to_s: "foo", full_name: "foo", depends_on: { formula: ["baz", "qux"] })
// 141:           bar = instance_double(Cask::Cask, to_s: "bar", full_name: "bar", depends_on: {})
// 142:           allow(Cask::Caskroom).to receive(:casks).and_return([foo, bar])
// 143:           allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 144:         end
// 145:
// 146:         it "returns an array of unique formula dependencies" do
// 147:           expect(dumper.formula_dependencies(["foo", "bar"])).to eql(["baz", "qux"])
// 148:         end
// 149:       end
// 150:
// 151:       context "when the cask is not installed" do
// 152:         before do
// 153:           described_class.reset!
// 154:           allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(false)
// 155:         end
// 156:
// 157:         it "loads formula dependencies from the cask definition" do
// 158:           cask = instance_double(
// 159:             Cask::Cask,
// 160:             to_s:       "tpack",
// 161:             full_name:  "tmuxpack/tpack/tpack",
// 162:             depends_on: { formula: ["tmux"] },
// 163:           )
// 164:
// 165:           expect(Cask::CaskLoader).to receive(:load).with("tmuxpack/tpack/tpack").and_return(cask)
// 166:
// 167:           expect(dumper.formula_dependencies(["tmuxpack/tpack/tpack"])).to eql(["tmux"])
// 168:         end
// 169:       end
// 170:     end
// 171:   end
// 172:
// 173:   describe "installing" do
// 174:     describe ".installed_casks" do
// 175:       before do
// 176:         described_class.reset!
// 177:       end
// 178:
// 179:       it "shells out" do
// 180:         expect { described_class.installed_casks }.not_to raise_error
// 181:       end
// 182:     end
// 183:
// 184:     describe ".cask_installed_and_up_to_date?" do
// 185:       it "returns result" do
// 186:         described_class.reset!
// 187:         allow(described_class).to receive_messages(installed_casks: ["foo", "baz"],
// 188:                                                    outdated_casks:  ["baz"])
// 189:         expect(described_class.cask_installed_and_up_to_date?("foo")).to be(true)
// 190:         expect(described_class.cask_installed_and_up_to_date?("baz")).to be(false)
// 191:       end
// 192:     end
// 193:
// 194:     context "when brew-cask is not installed" do
// 195:       describe ".outdated_casks" do
// 196:         it "returns empty array" do
// 197:           described_class.reset!
// 198:           expect(described_class.outdated_casks).to eql([])
// 199:         end
// 200:       end
// 201:     end
// 202:
// 203:     context "when brew-cask is installed" do
// 204:       before do
// 205:         described_class.reset!
// 206:         allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 207:       end
// 208:
// 209:       describe ".outdated_casks" do
// 210:         it "returns empty array" do
// 211:           described_class.reset!
// 212:           expect(described_class.outdated_casks).to eql([])
// 213:         end
// 214:
// 215:         it "does not include pinned casks" do
// 216:           pinned_cask = instance_double(Cask::Cask, to_s: "google-chrome", pinned?: true)
// 217:           unpinned_cask = instance_double(Cask::Cask, to_s: "firefox", pinned?: false)
// 218:           allow(pinned_cask).to receive(:outdated?).with(greedy: false).and_return(true)
// 219:           allow(unpinned_cask).to receive(:outdated?).with(greedy: false).and_return(true)
// 220:           allow(Cask::Caskroom).to receive(:casks).and_return([pinned_cask, unpinned_cask])
// 221:
// 222:           expect(described_class.outdated_casks).to eql(["firefox"])
// 223:         end
// 224:       end
// 225:
// 226:       context "when cask is installed" do
// 227:         before do
// 228:           described_class.reset!
// 229:           allow(described_class).to receive(:installed_casks).and_return(["google-chrome"])
// 230:         end
// 231:
// 232:         it "skips" do
// 233:           expect(Homebrew::Bundle).not_to receive(:system)
// 234:           expect(described_class.preinstall!("google-chrome")).to be(false)
// 235:         end
// 236:       end
// 237:
// 238:       context "when cask is outdated" do
// 239:         before do
// 240:           allow(described_class).to receive_messages(installed_casks: ["google-chrome"],
// 241:                                                      outdated_casks:  ["google-chrome"])
// 242:         end
// 243:
// 244:         it "upgrades" do
// 245:           expect(Homebrew::Bundle).to \
// 246:             receive(:system).with(HOMEBREW_BREW_FILE, "upgrade", "--cask", "google-chrome", verbose: false)
// 247:                             .and_return(true)
// 248:           expect(described_class.preinstall!("google-chrome")).to be(true)
// 249:           expect(described_class.install!("google-chrome")).to be(true)
// 250:         end
// 251:       end
// 252:
// 253:       context "when cask is outdated and uses auto-update" do
// 254:         before do
// 255:           described_class.reset!
// 256:           allow(described_class).to receive_messages(cask_names: ["opera"], outdated_cask_names: [])
// 257:           allow(described_class).to receive(:cask_is_outdated_using_greedy?).with("opera").and_return(true)
// 258:         end
// 259:
// 260:         it "upgrades" do
// 261:           expect(Homebrew::Bundle).to \
// 262:             receive(:system).with(HOMEBREW_BREW_FILE, "upgrade", "--cask", "opera", verbose: false)
// 263:                             .and_return(true)
// 264:           expect(described_class.preinstall!("opera", greedy: true)).to be(true)
// 265:           expect(described_class.install!("opera", greedy: true)).to be(true)
// 266:         end
// 267:       end
// 268:
// 269:       context "when cask is not installed" do
// 270:         before do
// 271:           allow(described_class).to receive(:installed_casks).and_return([])
// 272:         end
// 273:
// 274:         it "installs cask" do
// 275:           expect(Homebrew::Bundle).to receive(:brew).with("install", "--cask", "google-chrome", "--adopt",
// 276:                                                           verbose: false)
// 277:                                                     .and_return(true)
// 278:           expect(described_class.preinstall!("google-chrome")).to be(true)
// 279:           expect(described_class.install!("google-chrome")).to be(true)
// 280:         end
// 281:
// 282:         it "trusts the cask before installing it" do
// 283:           allow(Homebrew::Bundle).to receive(:brew).and_return(true)
// 284:           expect(Homebrew::Trust).to receive(:trust!).with(:cask, "puma/puma/puma-cask")
// 285:           described_class.install!("puma-cask", full_name: "puma/puma/puma-cask", trusted: true)
// 286:         end
// 287:
// 288:         it "does not trust an unqualified cask token" do
// 289:           allow(Homebrew::Bundle).to receive(:brew).and_return(true)
// 290:           expect(Homebrew::Trust).not_to receive(:trust!)
// 291:           described_class.install!("google-chrome", trusted: true)
// 292:         end
// 293:
// 294:         it "installs cask with arguments" do
// 295:           expect(Homebrew::Bundle).to(
// 296:             receive(:brew).with("install", "--cask", "firefox", "--appdir=/Applications", "--adopt",
// 297:                                 verbose: false)
// 298:                             .and_return(true),
// 299:           )
// 300:           expect(described_class.preinstall!("firefox", args: { appdir: "/Applications" })).to be(true)
// 301:           expect(described_class.install!("firefox", args: { appdir: "/Applications" })).to be(true)
// 302:         end
// 303:
// 304:         it "reports a failure" do
// 305:           expect(Homebrew::Bundle).to receive(:brew).with("install", "--cask", "google-chrome", "--adopt",
// 306:                                                           verbose: false)
// 307:                                                     .and_return(false)
// 308:           expect(described_class.preinstall!("google-chrome")).to be(true)
// 309:           expect(described_class.install!("google-chrome")).to be(false)
// 310:         end
// 311:
// 312:         context "with boolean arguments" do
// 313:           it "includes a flag if true" do
// 314:             expect(Homebrew::Bundle).to receive(:brew).with("install", "--cask", "iterm", "--force",
// 315:                                                             verbose: false)
// 316:                                                       .and_return(true)
// 317:             expect(described_class.preinstall!("iterm", args: { force: true })).to be(true)
// 318:             expect(described_class.install!("iterm", args: { force: true })).to be(true)
// 319:           end
// 320:
// 321:           it "does not include a flag if false" do
// 322:             expect(Homebrew::Bundle).to receive(:brew).with("install", "--cask", "iterm", "--adopt", verbose: false)
// 323:                                                       .and_return(true)
// 324:             expect(described_class.preinstall!("iterm", args: { force: false })).to be(true)
// 325:             expect(described_class.install!("iterm", args: { force: false })).to be(true)
// 326:           end
// 327:         end
// 328:       end
// 329:
// 330:       context "when the postinstall option is provided" do
// 331:         before do
// 332:           described_class.reset!
// 333:           allow(described_class).to receive_messages(cask_names:          ["google-chrome"],
// 334:                                                      outdated_cask_names: ["google-chrome"])
// 335:           allow(Homebrew::Bundle).to receive(:brew).and_return(true)
// 336:           allow(described_class).to receive(:upgrading?).and_return(true)
// 337:         end
// 338:
// 339:         it "runs the postinstall command" do
// 340:           expect(Kernel).to receive(:system).with("custom command").and_return(true)
// 341:           expect(described_class.preinstall!("google-chrome", postinstall: "custom command")).to be(true)
// 342:           expect(described_class.install!("google-chrome", postinstall: "custom command")).to be(true)
// 343:         end
// 344:
// 345:         it "reports a failure when postinstall fails" do
// 346:           expect(Kernel).to receive(:system).with("custom command").and_return(false)
// 347:           expect(described_class.preinstall!("google-chrome", postinstall: "custom command")).to be(true)
// 348:           expect(described_class.install!("google-chrome", postinstall: "custom command")).to be(false)
// 349:         end
// 350:       end
// 351:     end
// 352:   end
// 353: end
