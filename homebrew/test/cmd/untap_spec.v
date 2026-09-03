module cmd

import brew_runtime
import homebrew.cmd as cmd_core

// Translated from Homebrew/brew `test/cmd/untap_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn untap_spec_tap(name string, formula_names []string, cask_tokens []string) cmd_core.UntapTap {
	return cmd_core.UntapTap{
		name: name
		formula_names: formula_names
		cask_tokens: cask_tokens
	}
}

fn untap_spec_formula(name string, tap_name string, installed bool,
	valid bool) cmd_core.UntapFormula {
	return cmd_core.UntapFormula{
		name: name
		full_name: '${tap_name}/${name}'
		valid: valid
		installed_kegs: if installed {
			[cmd_core.UntapKeg{
				rack: '/cellar/${name}'
				tap: tap_name
			}]
		} else {
			[]
		}
	}
}

fn untap_spec_cask(token string, tap_name string, installed bool,
	deprecated bool) cmd_core.UntapCask {
	return cmd_core.UntapCask{
		token: token
		full_name: '${tap_name}/${token}'
		deprecated: deprecated
		installed: installed
	}
}

fn untap_spec_tap_value(tap cmd_core.UntapTap) brew_runtime.Value {
	return brew_runtime.structured_value('Tap', tap.name, {
		'name':          tap.name
		'core_tap':      tap.core_tap.str()
		'core_cask_tap': tap.core_cask_tap.str()
		'formula_names': tap.formula_names.join(',')
		'cask_tokens':   tap.cask_tokens.join(',')
	})
}

fn untap_spec_formula_value(formula cmd_core.UntapFormula) brew_runtime.Value {
	return brew_runtime.structured_value('Formula', formula.full_name, {
		'name':      formula.name
		'full_name': formula.full_name
		'installed': (formula.installed_kegs.len > 0).str()
		'valid':     formula.valid.str()
	})
}

fn untap_spec_cask_value(cask cmd_core.UntapCask) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Cask', cask.full_name, {
		'token':      cask.token
		'full_name':  cask.full_name
		'installed':  cask.installed.str()
		'deprecated': cask.deprecated.str()
	})
}

// Ruby let `let(:class_instance) { described_class.new(%w[arg1]) }` at line 8.
pub fn ruby_untap_spec_l8_d1_class_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Homebrew::Cmd::Untap'
		repr: 'Homebrew::Cmd::Untap(arg1)'
		map_data: {
			'named': brew_runtime.string_array_value(['arg1'])
		}
	}
}

// Ruby it `it "untaps a given Tap", :integration_test do` at line 12.
pub fn ruby_untap_spec_l12_d2_untaps(args ...brew_runtime.Value) brew_runtime.Value {
	result := cmd_core.run_untap_command(cmd_core.UntapCommandInput{
		named: ['homebrew/foo']
		taps: [untap_spec_tap('homebrew/foo', [], [])]
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.untapped == ['homebrew/foo'] && result.stdout == '' && !result.failed)
}

// Ruby it `it "fails without a traceback when given a formula name" do` at line 21.
pub fn ruby_untap_spec_l21_d3_fails(args ...brew_runtime.Value) brew_runtime.Value {
	cmd_core.run_untap_command(cmd_core.UntapCommandInput{
		named: ['homebrew/foo/bar']
	}) or {
		return brew_runtime.bool_value(err.msg() == "Invalid tap name: 'homebrew/foo/bar'")
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "continues untapping remaining taps when uninstallation is declined" do` at line 27.
pub fn ruby_untap_spec_l27_d4_continues(args ...brew_runtime.Value) brew_runtime.Value {
	foo := untap_spec_tap('homebrew/foo', ['homebrew/foo/testball'], [])
	bar := untap_spec_tap('homebrew/bar', [], [])
	result := cmd_core.run_untap_command(cmd_core.UntapCommandInput{
		named: ['homebrew/foo', 'homebrew/bar']
		taps: [foo, bar]
		formulae: [untap_spec_formula('testball', foo.name, true, true)]
		installed_formula_names: ['testball']
		confirmation_exits: [foo.name]
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.failed && result.untapped == [bar.name]
		&& result.stdout.contains('Would untap homebrew/foo')
		&& result.stderr.contains('Refusing to untap homebrew/foo'))
}

// Ruby it `it "lists installed packages before offering to uninstall them and untap" do` at line 54.
pub fn ruby_untap_spec_l54_d5_lists(args ...brew_runtime.Value) brew_runtime.Value {
	tap := untap_spec_tap('homebrew/foo', ['homebrew/foo/testball'], [
		'homebrew/foo/testcask',
	])
	result := cmd_core.run_untap_command(cmd_core.UntapCommandInput{
		named: [tap.name]
		taps: [tap]
		formulae: [untap_spec_formula('testball', tap.name, true, true)]
		casks: [untap_spec_cask('testcask', tap.name, true, false)]
		installed_formula_names: ['testball']
		installed_cask_tokens: ['testcask']
		confirmations: {
			tap.name: true
		}
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.stdout == '==> Would untap homebrew/foo after uninstalling the following formulae and casks:\nhomebrew/foo/testball\nhomebrew/foo/testcask\n'
		&& result.uninstalled_formulae == ['homebrew/foo/testball']
		&& result.uninstalled_casks == ['homebrew/foo/testcask']
		&& result.untapped == [tap.name])
}

// Ruby it `it "force-uninstalls installed packages without prompting before untapping" do` at line 88.
pub fn ruby_untap_spec_l88_d6_force_uninstalls(args ...brew_runtime.Value) brew_runtime.Value {
	tap := untap_spec_tap('homebrew/foo', ['homebrew/foo/testball'], [
		'homebrew/foo/testcask',
	])
	result := cmd_core.run_untap_command(cmd_core.UntapCommandInput{
		named: [tap.name]
		taps: [tap]
		formulae: [untap_spec_formula('testball', tap.name, true, true)]
		casks: [untap_spec_cask('testcask', tap.name, true, false)]
		installed_formula_names: ['testball']
		installed_cask_tokens: ['testcask']
		force: true
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.stdout == '' && !result.failed
		&& result.actions.contains('uninstall_kegs:homebrew/foo:force=true')
		&& result.actions.contains('uninstall_cask:homebrew/foo/testcask:force=true')
		&& result.untapped == [tap.name])
}

// Ruby it `it "does not untap when an installation remains" do` at line 115.
pub fn ruby_untap_spec_l115_d7_does(args ...brew_runtime.Value) brew_runtime.Value {
	tap := untap_spec_tap('homebrew/foo', [], ['homebrew/foo/testcask'])
	result := cmd_core.run_untap_command(cmd_core.UntapCommandInput{
		named: [tap.name]
		taps: [tap]
		casks: [cmd_core.UntapCask{
			token: 'testcask'
			full_name: 'homebrew/foo/testcask'
			installed: true
			remains_after_uninstall: true
		}]
		installed_cask_tokens: ['testcask']
		confirmations: {
			tap.name: true
		}
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.failed && result.untapped.len == 0
		&& result.stderr.contains('Failed to fully uninstall casks from homebrew/foo'))
}

// Ruby method `load_formula(name:, with_formula_file: false, mock_install: false)` at line 139.
pub fn ruby_untap_spec_l139_d8_load_formula(args ...brew_runtime.Value) brew_runtime.Value {
	values := if args.len > 0 {
		args[0].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	name := (values['name'] or { brew_runtime.string_value('testball') }).as_string()
	tap_name := (values['tap'] or { brew_runtime.string_value('homebrew/foo') }).as_string()
	installed := (values['mock_install'] or { brew_runtime.bool_value(false) }).as_bool() or {
		false
	}
	valid := (values['valid'] or { brew_runtime.bool_value(true) }).as_bool() or { true }
	return untap_spec_formula_value(untap_spec_formula(name, tap_name, installed, valid))
}

// Ruby let! `let!(:currently_installed_formula) do` at line 174.
pub fn ruby_untap_spec_l174_d9_currently_installed_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return untap_spec_formula_value(untap_spec_formula('current_install', 'homebrew/foo', true, true))
}

// Ruby it `it "returns the expected formulae" do` at line 188.
pub fn ruby_untap_spec_l188_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	tap := untap_spec_tap('homebrew/foo', ['homebrew/foo/current_install', 'homebrew/foo/no_install'], [])
	formulae := [untap_spec_formula('current_install', tap.name, true, true),
		untap_spec_formula('no_install', tap.name, false, true),
		untap_spec_formula('legacy_install', tap.name, true, true)]
	found := cmd_core.installed_formulae_for(tap, formulae, ['current_install', 'legacy_install'])
	return brew_runtime.bool_value(found.map(it.full_name) == [
		'homebrew/foo/current_install',
	])
}

// Ruby it `it "ignores formulae with invalid specs" do` at line 193.
pub fn ruby_untap_spec_l193_d11_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	tap := untap_spec_tap('homebrew/foo', ['homebrew/foo/current_install', 'homebrew/foo/invalid-spec'], [])
	formulae := [untap_spec_formula('current_install', tap.name, true, true),
		untap_spec_formula('invalid-spec', tap.name, true, false)]
	found := cmd_core.installed_formulae_for(tap, formulae, ['current_install', 'invalid-spec'])
	return brew_runtime.bool_value(found.map(it.full_name) == [
		'homebrew/foo/current_install',
	])
}

// Ruby let `let(:tap) { CoreTap.instance }` at line 218.
pub fn ruby_untap_spec_l218_d12_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return untap_spec_tap_value(cmd_core.UntapTap{
		name: 'homebrew/core'
		core_tap: true
	})
}

// Ruby let `let(:tap) { Tap.fetch("homebrew", "foo") }` at line 224.
pub fn ruby_untap_spec_l224_d13_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return untap_spec_tap_value(untap_spec_tap('homebrew/foo', [], []))
}

// Ruby method `load_cask(token:, with_cask_file: false, mock_install: false, deprecated: false)` at line 236.
pub fn ruby_untap_spec_l236_d14_load_cask(args ...brew_runtime.Value) brew_runtime.Value {
	values := if args.len > 0 {
		args[0].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	token := (values['token'] or { brew_runtime.string_value('testcask') }).as_string()
	tap_name := (values['tap'] or { brew_runtime.string_value('homebrew/foo') }).as_string()
	installed := (values['mock_install'] or { brew_runtime.bool_value(false) }).as_bool() or {
		false
	}
	deprecated := (values['deprecated'] or { brew_runtime.bool_value(false) }).as_bool() or {
		false
	}
	if deprecated {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return untap_spec_cask_value(untap_spec_cask(token, tap_name, installed, false))
}

// Ruby let! `let!(:currently_installed_cask) do` at line 264.
pub fn ruby_untap_spec_l264_d15_currently_installed_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return untap_spec_cask_value(untap_spec_cask('current_install', 'homebrew/foo', true, false))
}

// Ruby it `it "returns the expected casks" do` at line 279.
pub fn ruby_untap_spec_l279_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	tap := untap_spec_tap('homebrew/foo', [], ['homebrew/foo/current_install',
		'homebrew/foo/no_install', 'homebrew/foo/deprecated_method'])
	casks := [untap_spec_cask('current_install', tap.name, true, false),
		untap_spec_cask('no_install', tap.name, false, false),
		untap_spec_cask('legacy_install', tap.name, true, false),
		untap_spec_cask('deprecated_method', tap.name, false, true)]
	found := cmd_core.installed_casks_for(tap, casks, ['current_install', 'legacy_install'])
	return brew_runtime.bool_value(found.map(it.full_name) == [
		'homebrew/foo/current_install',
	])
}

// Ruby let `let(:tap) { CoreCaskTap.instance }` at line 285.
pub fn ruby_untap_spec_l285_d17_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return untap_spec_tap_value(cmd_core.UntapTap{
		name: 'homebrew/cask'
		core_cask_tap: true
	})
}

// Ruby let `let(:tap) { Tap.fetch("homebrew", "foo") }` at line 291.
pub fn ruby_untap_spec_l291_d18_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return untap_spec_tap_value(untap_spec_tap('homebrew/foo', [], []))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cmd/untap"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Untap do
// 8:   let(:class_instance) { described_class.new(%w[arg1]) }
// 9:
// 10:   it_behaves_like "parseable arguments"
// 11:
// 12:   it "untaps a given Tap", :integration_test do
// 13:     setup_test_tap
// 14:
// 15:     expect { brew "untap", "homebrew/foo" }
// 16:       .to output(/Untapped/).to_stderr
// 17:       .and not_to_output.to_stdout
// 18:       .and be_a_success
// 19:   end
// 20:
// 21:   it "fails without a traceback when given a formula name" do
// 22:     expect { described_class.new(["homebrew/foo/bar"]).run }
// 23:       .to output(%r{Error: Invalid tap name: 'homebrew/foo/bar'}).to_stderr
// 24:       .and raise_error(SystemExit)
// 25:   end
// 26:
// 27:   it "continues untapping remaining taps when uninstallation is declined" do
// 28:     tap1 = Tap.fetch("homebrew", "foo")
// 29:     tap2 = Tap.fetch("homebrew", "bar")
// 30:
// 31:     cmd = described_class.new(["homebrew/foo", "homebrew/bar"])
// 32:     allow(cmd.args.named).to receive(:to_installed_taps).and_return([tap1, tap2])
// 33:
// 34:     formula = instance_double(Formula, full_name: "homebrew/foo/testball")
// 35:     allow(cmd).to receive(:installed_formulae_for).with(tap: tap1).and_return([formula])
// 36:     allow(cmd).to receive(:installed_formulae_for).with(tap: tap2).and_return([])
// 37:     allow(cmd).to receive(:installed_casks_for).with(tap: tap1).and_return([])
// 38:     allow(cmd).to receive(:installed_casks_for).with(tap: tap2).and_return([])
// 39:
// 40:     expect(tap1).not_to receive(:uninstall)
// 41:     allow(Homebrew::Ask).to receive(:confirm?)
// 42:       .with(action: "changes")
// 43:       .and_raise(SystemExit)
// 44:     expect(tap2).to receive(:uninstall).with(manual: true)
// 45:
// 46:     expect { cmd.run }
// 47:       .to output(/Refusing to untap.*following installed formulae:/m).to_stderr
// 48:       .and output(%r{Would untap homebrew/foo after uninstalling the following formulae.*testball}m).to_stdout
// 49:     expect(Homebrew).to have_failed
// 50:   ensure
// 51:     Homebrew.failed = false
// 52:   end
// 53:
// 54:   it "lists installed packages before offering to uninstall them and untap" do
// 55:     tap = Tap.fetch("homebrew", "foo")
// 56:     rack = HOMEBREW_CELLAR/"testball"
// 57:     keg = instance_double(Keg, rack:, tab: instance_double(Tab, tap:))
// 58:     formula = instance_double(
// 59:       Formula,
// 60:       full_name:      "homebrew/foo/testball",
// 61:       installed_kegs: [keg],
// 62:       to_s:           "homebrew/foo/testball",
// 63:     )
// 64:     cask = instance_double(Cask::Cask, full_name: "homebrew/foo/testcask", token: "testcask")
// 65:     cmd = described_class.new(["homebrew/foo"])
// 66:
// 67:     allow(cmd.args.named).to receive(:to_installed_taps).and_return([tap])
// 68:     allow(cmd).to receive(:installed_formulae_for).with(tap:).and_return([formula], [])
// 69:     allow(cmd).to receive(:installed_casks_for).with(tap:).and_return([cask], [])
// 70:     allow(Homebrew::Ask).to receive(:confirm?)
// 71:       .with(action: "changes")
// 72:       .and_return(true)
// 73:
// 74:     named_args = [formula.full_name, cask.full_name]
// 75:     expect(Cask::Uninstall).to receive(:check_dependent_casks).with(cask, named_args:).ordered
// 76:     expect(Homebrew::Uninstall).to receive(:uninstall_kegs)
// 77:       .with({ rack => [keg] }, casks: [cask], force: false, named_args:).ordered
// 78:     expect(Cask::Uninstall).to receive(:uninstall_casks).with(cask, force: false)
// 79:     expect(tap).to receive(:uninstall).with(manual: true)
// 80:
// 81:     expect { cmd.run }.to output(<<~EOS).to_stdout
// 82:       ==> Would untap homebrew/foo after uninstalling the following formulae and casks:
// 83:       homebrew/foo/testball
// 84:       homebrew/foo/testcask
// 85:     EOS
// 86:   end
// 87:
// 88:   it "force-uninstalls installed packages without prompting before untapping" do
// 89:     tap = Tap.fetch("homebrew", "foo")
// 90:     rack = HOMEBREW_CELLAR/"testball"
// 91:     keg = instance_double(Keg, rack:, tab: instance_double(Tab, tap:))
// 92:     formula = instance_double(
// 93:       Formula,
// 94:       full_name:      "homebrew/foo/testball",
// 95:       installed_kegs: [keg],
// 96:     )
// 97:     cask = instance_double(Cask::Cask, full_name: "homebrew/foo/testcask")
// 98:     cmd = described_class.new(["--force", "homebrew/foo"])
// 99:
// 100:     allow(cmd.args.named).to receive(:to_installed_taps).and_return([tap])
// 101:     allow(cmd).to receive(:installed_formulae_for).with(tap:).and_return([formula], [])
// 102:     allow(cmd).to receive(:installed_casks_for).with(tap:).and_return([cask], [])
// 103:     expect(Homebrew::Ask).not_to receive(:confirm?)
// 104:
// 105:     named_args = [formula.full_name, cask.full_name]
// 106:     expect(Cask::Uninstall).to receive(:check_dependent_casks).with(cask, named_args:).ordered
// 107:     expect(Homebrew::Uninstall).to receive(:uninstall_kegs)
// 108:       .with({ rack => [keg] }, casks: [cask], force: true, named_args:).ordered
// 109:     expect(Cask::Uninstall).to receive(:uninstall_casks).with(cask, force: true)
// 110:     expect(tap).to receive(:uninstall).with(manual: true)
// 111:
// 112:     expect { cmd.run }.not_to output.to_stdout
// 113:   end
// 114:
// 115:   it "does not untap when an installation remains" do
// 116:     tap = Tap.fetch("homebrew", "foo")
// 117:     cask = instance_double(Cask::Cask, full_name: "homebrew/foo/testcask", token: "testcask")
// 118:     cmd = described_class.new(["homebrew/foo"])
// 119:
// 120:     allow(cmd.args.named).to receive(:to_installed_taps).and_return([tap])
// 121:     allow(cmd).to receive(:installed_formulae_for).with(tap:).and_return([], [])
// 122:     allow(cmd).to receive(:installed_casks_for).with(tap:).and_return([cask], [cask])
// 123:     allow(Homebrew::Ask).to receive(:confirm?)
// 124:       .with(action: "changes")
// 125:       .and_return(true)
// 126:     allow(Homebrew::Uninstall).to receive(:uninstall_kegs)
// 127:     allow(Cask::Uninstall).to receive(:check_dependent_casks)
// 128:     allow(Cask::Uninstall).to receive(:uninstall_casks)
// 129:     expect(tap).not_to receive(:uninstall)
// 130:
// 131:     expect { cmd.run }.to output(%r{Failed to fully uninstall casks from homebrew/foo}).to_stderr
// 132:     expect(Homebrew).to have_failed
// 133:   ensure
// 134:     Homebrew.failed = false
// 135:   end
// 136:
// 137:   describe "#installed_formulae_for" do
// 138:     shared_examples "finds installed formulae in tap", :no_api do
// 139:       def load_formula(name:, with_formula_file: false, mock_install: false)
// 140:         formula = if with_formula_file
// 141:           path = Formulary.find_formula_in_tap(name, tap)
// 142:           path.dirname.mkpath
// 143:           path.write <<~RUBY
// 144:             class #{Formulary.class_s(name)} < Formula
// 145:               url "https://brew.sh/#{name}-1.0.tgz"
// 146:             end
// 147:           RUBY
// 148:           tap.clear_cache
// 149:           Formulary.factory(path)
// 150:         else
// 151:           formula(name, tap:) do
// 152:             T.bind(self, T.class_of(Formula))
// 153:             url "https://brew.sh/#{name}-1.0.tgz"
// 154:           end
// 155:         end
// 156:
// 157:         if mock_install
// 158:           keg_path = HOMEBREW_CELLAR/name/"1.2.3"
// 159:           keg_path.mkpath
// 160:
// 161:           tab_path = keg_path/AbstractTab::FILENAME
// 162:           tab_path.write <<~JSON
// 163:             {
// 164:               "source": {
// 165:                 "tap": "#{tap}"
// 166:               }
// 167:             }
// 168:           JSON
// 169:         end
// 170:
// 171:         formula
// 172:       end
// 173:
// 174:       let!(:currently_installed_formula) do
// 175:         load_formula(name: "current_install", with_formula_file: true, mock_install: true)
// 176:       end
// 177:
// 178:       before do
// 179:         # Formula that is available from a tap but not installed.
// 180:         load_formula(name: "no_install", with_formula_file: true)
// 181:
// 182:         # Formula that was installed from a tap but is no longer available from that tap.
// 183:         load_formula(name: "legacy_install", mock_install: true)
// 184:
// 185:         tap.clear_cache
// 186:       end
// 187:
// 188:       it "returns the expected formulae" do
// 189:         expect(class_instance.installed_formulae_for(tap:).map(&:full_name))
// 190:           .to eq([currently_installed_formula.full_name])
// 191:       end
// 192:
// 193:       it "ignores formulae with invalid specs" do
// 194:         path = Formulary.find_formula_in_tap("invalid-spec", tap)
// 195:         path.dirname.mkpath
// 196:         path.write <<~RUBY
// 197:           class InvalidSpec < Formula
// 198:           end
// 199:         RUBY
// 200:         keg_path = HOMEBREW_CELLAR/"invalid-spec"/"1.2.3"
// 201:         keg_path.mkpath
// 202:
// 203:         (keg_path/AbstractTab::FILENAME).write <<~JSON
// 204:           {
// 205:             "source": {
// 206:               "tap": "#{tap}"
// 207:             }
// 208:           }
// 209:         JSON
// 210:         tap.clear_cache
// 211:
// 212:         expect(class_instance.installed_formulae_for(tap:).map(&:full_name))
// 213:           .to eq([currently_installed_formula.full_name])
// 214:       end
// 215:     end
// 216:
// 217:     context "with core tap" do
// 218:       let(:tap) { CoreTap.instance }
// 219:
// 220:       include_examples "finds installed formulae in tap"
// 221:     end
// 222:
// 223:     context "with non-core tap" do
// 224:       let(:tap) { Tap.fetch("homebrew", "foo") }
// 225:
// 226:       before do
// 227:         tap.formula_dir.mkpath
// 228:       end
// 229:
// 230:       include_examples "finds installed formulae in tap"
// 231:     end
// 232:   end
// 233:
// 234:   describe "#installed_casks_for", :cask do
// 235:     shared_examples "finds installed casks in tap", :no_api do
// 236:       def load_cask(token:, with_cask_file: false, mock_install: false, deprecated: false)
// 237:         cask_source = <<~RUBY
// 238:           cask '#{token}' do
// 239:             version "1.2.3"
// 240:             sha256 :no_check
// 241:
// 242:             url 'https://brew.sh/'
// 243:
// 244:             #{"raise MethodDeprecatedError" if deprecated}
// 245:           end
// 246:         RUBY
// 247:
// 248:         if with_cask_file
// 249:           cask_path = tap.cask_dir/"#{token}.rb"
// 250:           cask_path.parent.mkpath
// 251:           cask_path.write cask_source
// 252:         end
// 253:
// 254:         return if deprecated
// 255:
// 256:         cask_loader = Cask::CaskLoader::FromContentLoader.new(cask_source, tap:)
// 257:         cask = cask_loader.load(config: nil)
// 258:
// 259:         InstallHelper.install_with_caskfile(cask) if mock_install
// 260:
// 261:         cask
// 262:       end
// 263:
// 264:       let!(:currently_installed_cask) do
// 265:         load_cask(token: "current_install", with_cask_file: true, mock_install: true)
// 266:       end
// 267:
// 268:       before do
// 269:         # Cask that is available from a tap but not installed.
// 270:         load_cask(token: "no_install", with_cask_file: true)
// 271:
// 272:         # Cask that was installed from a tap but is no longer available from that tap.
// 273:         load_cask(token: "legacy_install", mock_install: true)
// 274:
// 275:         # Cask that uses deprecated method.
// 276:         load_cask(token: "deprecated_method", with_cask_file: true, deprecated: true)
// 277:       end
// 278:
// 279:       it "returns the expected casks" do
// 280:         expect(class_instance.installed_casks_for(tap:)).to eq([currently_installed_cask])
// 281:       end
// 282:     end
// 283:
// 284:     context "with core cask tap" do
// 285:       let(:tap) { CoreCaskTap.instance }
// 286:
// 287:       include_examples "finds installed casks in tap"
// 288:     end
// 289:
// 290:     context "with non-core cask tap" do
// 291:       let(:tap) { Tap.fetch("homebrew", "foo") }
// 292:
// 293:       include_examples "finds installed casks in tap"
// 294:     end
// 295:   end
// 296: end
