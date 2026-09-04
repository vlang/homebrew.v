module cmd

import ruby
import homebrew
import homebrew.cmd as install_cmd

// Translated from Homebrew/brew `test/cmd/install_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints a formula dry-run plan when asking" do` at line 12.
pub fn ruby_install_spec_l12_d1_prints(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_formulae_plan([
		homebrew.FormulaInstallCandidate{
			name: 'added'
		},
		homebrew.FormulaInstallCandidate{
			name: 'changed'
		},
	], [], 'installation', false)
	return ruby.bool_value(plan.output == '==> Would install 2 formulae:\nadded changed\n')
}

// Ruby it `it "skips ask input when asking for only requested formulae" do` at line 40.
pub fn ruby_install_spec_l40_d2_skips(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_formulae_plan([homebrew.FormulaInstallCandidate{
		name: 'testball'
	}], [], 'installation', true)
	return ruby.bool_value(plan.output == '==> Would install 1 formula:\ntestball\n' && !plan.prompt_needed)
}

// Ruby it `it "does not list ignored formula dependencies when asking" do` at line 62.
pub fn ruby_install_spec_l62_d3_does(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_formulae_plan([homebrew.FormulaInstallCandidate{
		name: 'testball'
		ignore_dependencies: true
		dependencies: [homebrew.InstallDependencyPlan{
			name: 'dependency'
		}]
	}], [], 'installation', true)
	return ruby.bool_value(plan.output == '==> Would install 1 formula:\ntestball\n' && !plan.prompt_needed && !plan.output.contains('dependency'))
}

// Ruby it `it "uses the requested action when asking for formulae with dependencies" do` at line 86.
pub fn ruby_install_spec_l86_d4_uses(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_formulae_plan([homebrew.FormulaInstallCandidate{
		name: 'changed'
		dependencies: [homebrew.InstallDependencyPlan{
			name: 'dependency'
		}]
	}], [], 'upgrade', true)
	return ruby.bool_value(plan.action == 'upgrade' && plan.prompt_needed && plan.output == '==> Would upgrade 1 formula:\nchanged\n==> Would install 1 dependency for changed:\ndependency\n')
}

// Ruby it `it "groups an installed dependency under the upgrade header in the dry-run plan" do` at line 116.
pub fn ruby_install_spec_l116_d5_groups(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_formulae_plan([homebrew.FormulaInstallCandidate{
		name: 'changed'
		dependencies: [homebrew.InstallDependencyPlan{
			name: 'dependency'
			installed: true
		}]
	}], [], 'installation', false)
	return ruby.bool_value(plan.output == '==> Would install 1 formula:\nchanged\n==> Would upgrade 1 dependency for changed:\ndependency\n')
}

// Ruby it `it "prompts again for return ask input" do` at line 143.
pub fn ruby_install_spec_l143_d6_prompts(args ...ruby.Value) ruby.Value {
	_ = args
	for character in [`\r`, `\n`] {
		result := homebrew.ask_input(homebrew.InstallAskInput{
			action: 'upgrade'
			stdin_tty: true
			stdout_tty: true
			characters: [int(character), int(`n`)]
		})
		if !result.exited || result.consumed != 2 || result.output != "==> Do you want to proceed with the upgrade? [y/n]\nInvalid input. Please press 'y' to proceed, or 'n' to abort.\n" {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "accepts single character ask input" do` at line 159.
pub fn ruby_install_spec_l159_d7_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	for character in [`y`, `Y`] {
		result := homebrew.ask_input(homebrew.InstallAskInput{
			action: 'upgrade'
			stdin_tty: true
			stdout_tty: true
			characters: [int(character)]
		})
		if !result.accepted || result.exited {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "declines single character ask input" do` at line 170.
pub fn ruby_install_spec_l170_d8_declines(args ...ruby.Value) ruby.Value {
	_ = args
	for character in [`n`, `N`] {
		result := homebrew.ask_input(homebrew.InstallAskInput{
			action: 'upgrade'
			stdin_tty: true
			stdout_tty: true
			characters: [int(character)]
		})
		if !result.exited || result.accepted {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "terminates on ask cancellation input" do` at line 182.
pub fn ruby_install_spec_l182_d9_terminates(args ...ruby.Value) ruby.Value {
	_ = args
	for character in [27, 3, 4] {
		result := homebrew.ask_input(homebrew.InstallAskInput{
			action: 'upgrade'
			stdin_tty: true
			stdout_tty: true
			characters: [character]
		})
		if !result.exited {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "terminates on ask interrupt" do` at line 194.
pub fn ruby_install_spec_l194_d10_terminates(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ask_input(homebrew.InstallAskInput{
		action: 'upgrade'
		stdin_tty: true
		stdout_tty: true
		characters: [int(`x`)]
		interrupt_index: 0
	})
	return ruby.bool_value(result.exited && result.consumed == 0)
}

// Ruby it `it "skips ask input without a TTY" do` at line 205.
pub fn ruby_install_spec_l205_d11_skips(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ask_input(homebrew.InstallAskInput{
		action: 'upgrade'
		characters: [int(`y`)]
	})
	return ruby.bool_value(!result.accepted && !result.exited && result.output == '' && result.consumed == 0)
}

// Ruby it `it "uses shared prompt rules for ask plans" do` at line 212.
pub fn ruby_install_spec_l212_d12_uses(args ...ruby.Value) ruby.Value {
	_ = args
	values := [
		homebrew.ask_prompt_needed(['fish'], ['fish'], false, true),
		homebrew.ask_prompt_needed(['fish', 'openssl'], ['fish'], false, true),
		homebrew.ask_prompt_needed(['fish'], [], false, false),
		homebrew.ask_prompt_needed(['fish'], ['fish'], true, true),
		homebrew.ask_prompt_needed([], [], false, false),
	]
	return ruby.bool_value(values == [false, true, true, true, false])
}

// Ruby it `it "prints casks when asking", :cask do` at line 222.
pub fn ruby_install_spec_l222_d13_prints(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_casks_plan([homebrew.CaskInstallCandidate{
		full_name: 'local-caffeine'
	}], 'installation', false, false)
	return ruby.bool_value(plan.output == '==> Would install 1 cask:\nlocal-caffeine\n')
}

// Ruby it `it "prompts when asking for casks with dependencies", :cask do` at line 233.
pub fn ruby_install_spec_l233_d14_prompts(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_casks_plan([homebrew.CaskInstallCandidate{
		full_name: 'local-caffeine'
		runtime_dependencies: [homebrew.InstallDependencyPlan{
			name: 'unar'
		}]
	}], 'installation', true, false)
	return ruby.bool_value(plan.prompt_needed && plan.output == '==> Would install 1 cask:\nlocal-caffeine\n==> Would install 1 dependency for local-caffeine:\nunar\n')
}

// Ruby it `it "does not read installed formula metadata for cask dependency dry-run plans", :cask do` at line 254.
pub fn ruby_install_spec_l254_d15_does(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_casks_plan([homebrew.CaskInstallCandidate{
		full_name: 'local-caffeine'
		runtime_dependencies: [homebrew.InstallDependencyPlan{
			name: 'ripgrep'
		}]
	}], 'installation', false, false)
	return ruby.bool_value(plan.output.contains('ripgrep') && !plan.prompt_needed)
}

// Ruby it `it "prompts when asking for casks with cask dependencies", :cask do` at line 276.
pub fn ruby_install_spec_l276_d16_prompts(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_casks_plan([homebrew.CaskInstallCandidate{
		full_name: 'with-depends-on-cask'
		dependencies: [homebrew.InstallDependencyPlan{
			full_name: 'local-transmission-zip'
		}]
	}], 'installation', true, false)
	return ruby.bool_value(plan.prompt_needed && plan.output.contains('local-transmission-zip'))
}

// Ruby it `it "prints a cask reinstallation dry-run plan when asking", :cask do` at line 291.
pub fn ruby_install_spec_l291_d17_prints(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_casks_plan([homebrew.CaskInstallCandidate{
		full_name: 'local-caffeine'
	}], 'reinstallation', false, false)
	return ruby.bool_value(plan.output == '==> Would reinstall 1 cask:\nlocal-caffeine\n')
}

// Ruby it `it "does not prompt when skipped cask dependencies will not be installed", :cask do` at line 302.
pub fn ruby_install_spec_l302_d18_does(args ...ruby.Value) ruby.Value {
	_ = args
	plan := homebrew.ask_casks_plan([homebrew.CaskInstallCandidate{
		full_name: 'with-depends-on-cask'
		dependencies: [homebrew.InstallDependencyPlan{
			full_name: 'local-transmission-zip'
		}]
	}], 'installation', true, true)
	return ruby.bool_value(!plan.prompt_needed && plan.output == '==> Would install 1 cask:\nwith-depends-on-cask\n')
}

// Ruby it `it "installs an explicitly requested tap before resolving a formula" do` at line 315.
pub fn ruby_install_spec_l315_d19_installs(args ...ruby.Value) ruby.Value {
	_ = args
	result := install_cmd.execute_install_command(install_cmd.InstallCommandContext{
		arguments: ['user/repo/foo']
		taps: [install_cmd.InstallCommandTap{
			name: 'user/repo'
		}]
		environment: install_cmd.InstallCommandEnvironment{}
		unavailable_name: 'user/repo/foo'
		unavailable_message: 'If you trust this tap, retry after installing it.'
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.events.len >= 3 && result.events[..3] == [
		'ensure_tap:user/repo',
		'trust:user/repo/foo',
		'resolve_packages',
	] && result.stderr.contains('If you trust this tap') && result.failed)
}

// Ruby it `it "starts formula prelude fetches before dependant checks when not asking" do` at line 332.
pub fn ruby_install_spec_l332_d20_starts(args ...ruby.Value) ruby.Value {
	_ = args
	result := install_cmd.execute_install_command(install_cmd.InstallCommandContext{
		arguments: ['--yes', 'testball']
		formulae: [install_cmd.InstallCommandFormula{
			name: 'testball'
			full_name: 'testball'
		}]
		environment: install_cmd.InstallCommandEnvironment{}
		downloads_heading: 'Fetching downloads for: testball'
	}) or { return ruby.bool_value(false) }
	prelude_index := result.events.index('prelude_fetch:testball')
	dependants_index := result.events.index('dependants')
	return ruby.bool_value(prelude_index >= 0 && dependants_index > prelude_index && result.download_queue_closed)
}

// Ruby it `it "installs what did download after an earlier failure" do` at line 366.
pub fn ruby_install_spec_l366_d21_installs(args ...ruby.Value) ruby.Value {
	_ = args
	result := install_cmd.execute_install_command(install_cmd.InstallCommandContext{
		arguments: ['--yes', 'testball']
		formulae: [install_cmd.InstallCommandFormula{
			name: 'testball'
			full_name: 'testball'
		}]
		environment: install_cmd.InstallCommandEnvironment{}
		prior_failed: true
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.failed && result.formulae_installed == [
		'testball',
	])
}

// Ruby it `it "names the cask that failed to install", :cask do` at line 397.
pub fn ruby_install_spec_l397_d22_names(args ...ruby.Value) ruby.Value {
	_ = args
	result := install_cmd.execute_install_command(install_cmd.InstallCommandContext{
		arguments: ['--yes', 'local-caffeine']
		casks: [install_cmd.InstallCommandCask{
			full_name: 'local-caffeine'
			install_error: 'uh-oh'
		}]
		environment: install_cmd.InstallCommandEnvironment{}
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.failed && result.stderr.contains('local-caffeine: uh-oh'))
}

// Ruby it `it "drains metadata-only prelude fetches before the dry-run plan when asking" do` at line 420.
pub fn ruby_install_spec_l420_d23_drains(args ...ruby.Value) ruby.Value {
	_ = args
	result := install_cmd.execute_install_command(install_cmd.InstallCommandContext{
		arguments: ['testball']
		formulae: [install_cmd.InstallCommandFormula{
			name: 'testball'
			full_name: 'testball'
		}]
		environment: install_cmd.InstallCommandEnvironment{}
		formula_ask_output: '==> Would install 1 formula:\ntestball\n'
		downloads_heading: 'Fetching downloads for: testball'
	}) or { return ruby.bool_value(false) }
	manifest_index := result.events.index('download_bottle_manifests')
	dependants_index := result.events.index('dependants')
	return ruby.bool_value(manifest_index > dependants_index && result.stdout.starts_with('==> Would install 1 formula:') && result.download_queue_closed)
}

// Ruby it `it "does not install `homebrew/cask` when a cask remains unavailable" do` at line 457.
pub fn ruby_install_spec_l457_d24_does(args ...ruby.Value) ruby.Value {
	_ = args
	result := install_cmd.execute_install_command(install_cmd.InstallCommandContext{
		arguments: ['foo']
		environment: install_cmd.InstallCommandEnvironment{}
		unavailable_name: 'foo'
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.failed && result.events.all(!it.starts_with('ensure_tap:homebrew/cask')))
}

// Ruby it `it "builds from source and pours a keg-only bottle", :integration_test do` at line 477.
pub fn ruby_install_spec_l477_d25_builds(args ...ruby.Value) ruby.Value {
	_ = args
	result := install_cmd.execute_install_command(install_cmd.InstallCommandContext{
		arguments: ['--yes', 'sourceball', 'testball_bottle']
		formulae: [
			install_cmd.InstallCommandFormula{
				name: 'sourceball'
				full_name: 'sourceball'
			},
			install_cmd.InstallCommandFormula{
				name: 'testball_bottle'
				full_name: 'testball_bottle'
			},
		]
		environment: install_cmd.InstallCommandEnvironment{}
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.formulae_installed == ['sourceball', 'testball_bottle'])
}

// Ruby method `install` at line 487.
pub fn ruby_install_spec_l487_d26_install(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'path':    ruby.string_value('built-from-source')
		'content': ruby.string_value('test')
	})
}

// Ruby let `let(:formula_name) { "testball1" }` at line 512.
pub fn ruby_install_spec_l512_d27_formula_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('testball1')
}

// Ruby it `it "installs a HEAD Formula", :integration_test do` at line 514.
pub fn ruby_install_spec_l514_d28_installs(args ...ruby.Value) ruby.Value {
	_ = args
	result := install_cmd.execute_install_command(install_cmd.InstallCommandContext{
		arguments: ['--yes', 'testball1', '--HEAD']
		formulae: [install_cmd.InstallCommandFormula{
			name: 'testball1'
			full_name: 'testball1'
			head: true
		}]
		environment: install_cmd.InstallCommandEnvironment{}
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.formulae_installed == ['testball1'])
}

// Ruby method `install` at line 533.
pub fn ruby_install_spec_l533_d29_install(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['bin/something.bin', 'README'])
}

// Ruby it `it "prints a shared fetch heading and correct upgrade count", :cask do` at line 553.
pub fn ruby_install_spec_l553_d30_prints(args ...ruby.Value) ruby.Value {
	_ = args
	result := install_cmd.execute_install_command(install_cmd.InstallCommandContext{
		arguments: ['--yes', 'codex']
		formulae: [install_cmd.InstallCommandFormula{
			name: 'testball_bottle'
			full_name: 'testball_bottle'
		}]
		casks: [install_cmd.InstallCommandCask{
			full_name: 'codex'
			installed: true
			installed_version: '0.117.0'
			version: '0.118.0'
			outdated: true
		}]
		environment: install_cmd.InstallCommandEnvironment{}
		downloads_heading: 'Fetching downloads for: testball_bottle and codex'
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.stdout == '==> Upgrading 1 outdated package:\ncodex 0.117.0 -> 0.118.0\n' && result.events.contains('Fetching downloads for: testball_bottle and codex') && result.casks_upgraded == [
		'codex',
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/install"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::InstallCmd do
// 8:   include FileUtils
// 9:
// 10:   it_behaves_like "parseable arguments"
// 11:
// 12:   it "prints a formula dry-run plan when asking" do
// 13:     added = formula("added") do
// 14:       T.bind(self, T.class_of(Formula))
// 15:       url "https://brew.sh/added-1.0.tar.gz"
// 16:     end
// 17:     changed = formula("changed") do
// 18:       T.bind(self, T.class_of(Formula))
// 19:       url "https://brew.sh/changed-2.0.tar.gz"
// 20:     end
// 21:     added_installer = FormulaInstaller.new(added)
// 22:     changed_installer = FormulaInstaller.new(changed)
// 23:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 24:
// 25:     allow(added_installer).to receive(:compute_dependencies).and_return([])
// 26:     allow(changed_installer).to receive(:compute_dependencies).and_return([])
// 27:
// 28:     expect do
// 29:       Homebrew::Install.ask_formulae(
// 30:         [added_installer, changed_installer],
// 31:         dependants,
// 32:         prompt: false,
// 33:       )
// 34:     end.to output(<<~EOS).to_stdout
// 35:       ==> Would install 2 formulae:
// 36:       added changed
// 37:     EOS
// 38:   end
// 39:
// 40:   it "skips ask input when asking for only requested formulae" do
// 41:     formula = formula("testball") do
// 42:       T.bind(self, T.class_of(Formula))
// 43:       url "https://brew.sh/testball-0.1.tar.gz"
// 44:     end
// 45:     formula_installer = FormulaInstaller.new(formula)
// 46:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 47:
// 48:     allow(formula_installer).to receive(:compute_dependencies).and_return([])
// 49:     expect(Homebrew::Install).not_to receive(:ask_input)
// 50:
// 51:     expect do
// 52:       Homebrew::Install.ask_formulae(
// 53:         [formula_installer],
// 54:         dependants,
// 55:       )
// 56:     end.to output(<<~EOS).to_stdout
// 57:       ==> Would install 1 formula:
// 58:       testball
// 59:     EOS
// 60:   end
// 61:
// 62:   it "does not list ignored formula dependencies when asking" do
// 63:     dependency = formula("dependency") do
// 64:       T.bind(self, T.class_of(Formula))
// 65:       url "https://brew.sh/dependency-1.0.tar.gz"
// 66:     end
// 67:     formula = formula("testball") do
// 68:       T.bind(self, T.class_of(Formula))
// 69:       url "https://brew.sh/testball-0.1.tar.gz"
// 70:       depends_on dependency.name.to_s
// 71:     end
// 72:     formula_installer = FormulaInstaller.new(formula, ignore_deps: true)
// 73:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 74:
// 75:     expect(formula_installer).not_to receive(:compute_dependencies)
// 76:     expect(Homebrew::Install).not_to receive(:ask_input)
// 77:
// 78:     expect do
// 79:       Homebrew::Install.ask_formulae([formula_installer], dependants)
// 80:     end.to output(<<~EOS).to_stdout
// 81:       ==> Would install 1 formula:
// 82:       testball
// 83:     EOS
// 84:   end
// 85:
// 86:   it "uses the requested action when asking for formulae with dependencies" do
// 87:     formula = formula("changed") do
// 88:       T.bind(self, T.class_of(Formula))
// 89:       url "https://brew.sh/changed-2.0.tar.gz"
// 90:     end
// 91:     dependency = formula("dependency") do
// 92:       T.bind(self, T.class_of(Formula))
// 93:       url "https://brew.sh/dependency-1.0.tar.gz"
// 94:     end
// 95:     formula_installer = FormulaInstaller.new(formula)
// 96:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 97:
// 98:     allow(formula_installer).to receive(:compute_dependencies)
// 99:       .and_return([instance_double(Dependency, to_formula: dependency)])
// 100:     expect(Homebrew::Install).to receive(:ask_input).with(action: "upgrade")
// 101:
// 102:     expect do
// 103:       Homebrew::Install.ask_formulae(
// 104:         [formula_installer],
// 105:         dependants,
// 106:         action: "upgrade",
// 107:       )
// 108:     end.to output(<<~EOS).to_stdout
// 109:       ==> Would upgrade 1 formula:
// 110:       changed
// 111:       ==> Would install 1 dependency for changed:
// 112:       dependency
// 113:     EOS
// 114:   end
// 115:
// 116:   it "groups an installed dependency under the upgrade header in the dry-run plan" do
// 117:     formula = formula("changed") do
// 118:       T.bind(self, T.class_of(Formula))
// 119:       url "https://brew.sh/changed-2.0.tar.gz"
// 120:     end
// 121:     dependency = formula("dependency") do
// 122:       T.bind(self, T.class_of(Formula))
// 123:       url "https://brew.sh/dependency-1.0.tar.gz"
// 124:     end
// 125:     allow(dependency).to receive(:any_version_installed?).and_return(true)
// 126:     formula_installer = FormulaInstaller.new(formula)
// 127:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 128:
// 129:     allow(formula_installer).to receive(:compute_dependencies)
// 130:       .and_return([instance_double(Dependency, to_formula: dependency)])
// 131:     allow(Homebrew::Install).to receive(:ask_input)
// 132:
// 133:     expect do
// 134:       Homebrew::Install.ask_formulae([formula_installer], dependants)
// 135:     end.to output(<<~EOS).to_stdout
// 136:       ==> Would install 1 formula:
// 137:       changed
// 138:       ==> Would upgrade 1 dependency for changed:
// 139:       dependency
// 140:     EOS
// 141:   end
// 142:
// 143:   it "prompts again for return ask input" do
// 144:     ["\r", "\n"].each do |input|
// 145:       allow($stdin).to receive(:tty?).and_return(true)
// 146:       allow($stdin).to receive(:getch).and_return(input, "n")
// 147:       allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 148:
// 149:       expect do
// 150:         Homebrew::Install.ask(action: "upgrade")
// 151:       end.to raise_error(SystemExit) { |error| expect(error.status).to eq(1) }
// 152:         .and output(<<~EOS).to_stdout
// 153:           ==> Do you want to proceed with the upgrade? [y/n]
// 154:           Invalid input. Please press 'y' to proceed, or 'n' to abort.
// 155:         EOS
// 156:     end
// 157:   end
// 158:
// 159:   it "accepts single character ask input" do
// 160:     %w[y Y].each do |input|
// 161:       allow($stdin).to receive_messages(getch: input, tty?: true)
// 162:       allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 163:
// 164:       expect do
// 165:         Homebrew::Install.ask(action: "upgrade")
// 166:       end.to output("==> Do you want to proceed with the upgrade? [y/n]\n").to_stdout
// 167:     end
// 168:   end
// 169:
// 170:   it "declines single character ask input" do
// 171:     %w[n N].each do |input|
// 172:       allow($stdin).to receive_messages(getch: input, tty?: true)
// 173:       allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 174:
// 175:       expect do
// 176:         Homebrew::Install.ask(action: "upgrade")
// 177:       end.to raise_error(SystemExit) { |error| expect(error.status).to eq(1) }
// 178:         .and output("==> Do you want to proceed with the upgrade? [y/n]\n").to_stdout
// 179:     end
// 180:   end
// 181:
// 182:   it "terminates on ask cancellation input" do
// 183:     ["\e", "\u0003", "\u0004"].each do |input|
// 184:       allow($stdin).to receive_messages(getch: input, tty?: true)
// 185:       allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 186:
// 187:       expect do
// 188:         Homebrew::Install.ask(action: "upgrade")
// 189:       end.to raise_error(SystemExit) { |error| expect(error.status).to eq(1) }
// 190:         .and output("==> Do you want to proceed with the upgrade? [y/n]\n").to_stdout
// 191:     end
// 192:   end
// 193:
// 194:   it "terminates on ask interrupt" do
// 195:     allow($stdin).to receive_messages(tty?: true)
// 196:     allow($stdin).to receive(:getch).and_raise(Interrupt)
// 197:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 198:
// 199:     expect do
// 200:       Homebrew::Install.ask(action: "upgrade")
// 201:     end.to raise_error(SystemExit) { |error| expect(error.status).to eq(1) }
// 202:       .and output("==> Do you want to proceed with the upgrade? [y/n]\n").to_stdout
// 203:   end
// 204:
// 205:   it "skips ask input without a TTY" do
// 206:     allow($stdin).to receive(:tty?).and_return(false)
// 207:     expect($stdin).not_to receive(:getch)
// 208:
// 209:     expect { Homebrew::Install.ask(action: "upgrade") }.not_to output.to_stdout
// 210:   end
// 211:
// 212:   it "uses shared prompt rules for ask plans" do
// 213:     expect([
// 214:       Homebrew::Install.ask_prompt_needed?(planned_names: ["fish"], requested_names: ["fish"]),
// 215:       Homebrew::Install.ask_prompt_needed?(planned_names: ["fish", "openssl"], requested_names: ["fish"]),
// 216:       Homebrew::Install.ask_prompt_needed?(planned_names: ["fish"], requested_names: [], named: false),
// 217:       Homebrew::Install.ask_prompt_needed?(planned_names: ["fish"], requested_names: ["fish"], force: true),
// 218:       Homebrew::Install.ask_prompt_needed?(planned_names: [], requested_names: [], named: false),
// 219:     ]).to eq([false, true, true, true, false])
// 220:   end
// 221:
// 222:   it "prints casks when asking", :cask do
// 223:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 224:
// 225:     expect do
// 226:       Homebrew::Install.ask_casks([cask], prompt: false)
// 227:     end.to output(<<~EOS).to_stdout
// 228:       ==> Would install 1 cask:
// 229:       local-caffeine
// 230:     EOS
// 231:   end
// 232:
// 233:   it "prompts when asking for casks with dependencies", :cask do
// 234:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 235:     dependency = instance_double(Dependency, installed?: false, name: "unar")
// 236:     cask_dependent = instance_double(CaskDependent)
// 237:
// 238:     allow(CaskDependent).to receive(:new)
// 239:       .with(cask)
// 240:       .and_return(cask_dependent)
// 241:     allow(cask_dependent).to receive(:runtime_dependencies).and_return([dependency])
// 242:     expect(Homebrew::Install).to receive(:ask_input).with(action: "installation")
// 243:
// 244:     expect do
// 245:       Homebrew::Install.ask_casks([cask])
// 246:     end.to output(<<~EOS).to_stdout
// 247:       ==> Would install 1 cask:
// 248:       local-caffeine
// 249:       ==> Would install 1 dependency for local-caffeine:
// 250:       unar
// 251:     EOS
// 252:   end
// 253:
// 254:   it "does not read installed formula metadata for cask dependency dry-run plans", :cask do
// 255:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 256:     dependency = instance_double(Dependency, installed?: false, name: "ripgrep")
// 257:     cask_dependent = instance_double(CaskDependent)
// 258:
// 259:     allow(CaskDependent).to receive(:new)
// 260:       .with(cask)
// 261:       .and_return(cask_dependent)
// 262:     expect(cask_dependent).to receive(:runtime_dependencies)
// 263:       .with(read_from_tab: false, undeclared: false)
// 264:       .and_return([dependency])
// 265:
// 266:     expect do
// 267:       Homebrew::Install.ask_casks([cask], prompt: false)
// 268:     end.to output(<<~EOS).to_stdout
// 269:       ==> Would install 1 cask:
// 270:       local-caffeine
// 271:       ==> Would install 1 dependency for local-caffeine:
// 272:       ripgrep
// 273:     EOS
// 274:   end
// 275:
// 276:   it "prompts when asking for casks with cask dependencies", :cask do
// 277:     cask = Cask::CaskLoader.load(cask_path("with-depends-on-cask"))
// 278:
// 279:     expect(Homebrew::Install).to receive(:ask_input).with(action: "installation")
// 280:
// 281:     expect do
// 282:       Homebrew::Install.ask_casks([cask])
// 283:     end.to output(<<~EOS).to_stdout
// 284:       ==> Would install 1 cask:
// 285:       with-depends-on-cask
// 286:       ==> Would install 1 dependency for with-depends-on-cask:
// 287:       local-transmission-zip
// 288:     EOS
// 289:   end
// 290:
// 291:   it "prints a cask reinstallation dry-run plan when asking", :cask do
// 292:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 293:
// 294:     expect do
// 295:       Homebrew::Install.ask_casks([cask], action: "reinstallation", prompt: false)
// 296:     end.to output(<<~EOS).to_stdout
// 297:       ==> Would reinstall 1 cask:
// 298:       local-caffeine
// 299:     EOS
// 300:   end
// 301:
// 302:   it "does not prompt when skipped cask dependencies will not be installed", :cask do
// 303:     cask = Cask::CaskLoader.load(cask_path("with-depends-on-cask"))
// 304:
// 305:     expect(Homebrew::Install).not_to receive(:ask_input)
// 306:
// 307:     expect do
// 308:       Homebrew::Install.ask_casks([cask], skip_cask_deps: true)
// 309:     end.to output(<<~EOS).to_stdout
// 310:       ==> Would install 1 cask:
// 311:       with-depends-on-cask
// 312:     EOS
// 313:   end
// 314:
// 315:   it "installs an explicitly requested tap before resolving a formula" do
// 316:     cmd = described_class.new(["user/repo/foo"])
// 317:     tap = Tap.fetch("user", "repo")
// 318:
// 319:     allow(Tap).to receive(:with_formula_name).with("user/repo/foo").and_return([tap, "foo"])
// 320:     expect(tap).to receive(:ensure_installed!).ordered
// 321:     expect(Homebrew::Trust).to receive(:trust_fully_qualified_items!)
// 322:       .with(["user/repo/foo"], type: nil)
// 323:       .ordered
// 324:     expect(cmd.args.named).to receive(:to_formulae_and_casks).with(warn: false).ordered
// 325:                                                              .and_raise(TapFormulaUnavailableError.new(tap, "foo"))
// 326:
// 327:     expect { cmd.run }.to output(/If you trust this tap/).to_stderr
// 328:
// 329:     expect(Homebrew).to have_failed
// 330:   end
// 331:
// 332:   it "starts formula prelude fetches before dependant checks when not asking" do
// 333:     cmd = described_class.new(["--yes", "testball"])
// 334:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, shutdown: nil, failed_downloads: [])
// 335:     formula = formula("testball") do
// 336:       T.bind(self, T.class_of(Formula))
// 337:       url "https://brew.sh/testball-0.1.tar.gz"
// 338:     end
// 339:     formula_installer = instance_double(FormulaInstaller, formula:)
// 340:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 341:
// 342:     allow(Tap).to receive_messages(with_formula_name: nil, with_cask_token: nil)
// 343:     allow(Homebrew::Trust).to receive(:trust_fully_qualified_items!)
// 344:     allow(cmd.args.named).to receive(:to_formulae_and_casks).with(warn: false).and_return([formula])
// 345:     allow(Homebrew::Install).to receive(:perform_preinstall_checks_once)
// 346:     allow(Homebrew::Install).to receive(:check_cc_argv)
// 347:     allow(Homebrew::Install).to receive_messages(install_formula?: true, formula_installers: [formula_installer])
// 348:     allow(Homebrew::Install).to receive(:install_formulae)
// 349:     allow(Homebrew::Upgrade).to receive(:upgrade_dependents)
// 350:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 351:     allow(Homebrew.messages).to receive(:display_messages)
// 352:     expect(Homebrew::DownloadQueue).to receive(:new).ordered.and_return(download_queue)
// 353:     expect(formula_installer).to receive(:download_queue=).with(download_queue).ordered
// 354:     expect(formula_installer).to receive(:prelude_fetch).with(no_args).ordered
// 355:     expect(Homebrew::Upgrade).to receive(:dependants).ordered.and_return(dependants)
// 356:     expect(Homebrew::Install).to receive(:enqueue_formulae)
// 357:       .with([formula_installer], download_queue:)
// 358:       .ordered
// 359:       .and_return([formula_installer])
// 360:     expect(download_queue).to receive(:fetch).ordered
// 361:     expect(download_queue).to receive(:shutdown).ordered
// 362:
// 363:     cmd.run
// 364:   end
// 365:
// 366:   it "installs what did download after an earlier failure" do
// 367:     cmd = described_class.new(["--yes", "testball"])
// 368:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, shutdown: nil, failed_downloads: [])
// 369:     formula = formula("testball") do
// 370:       T.bind(self, T.class_of(Formula))
// 371:       url "https://brew.sh/testball-0.1.tar.gz"
// 372:     end
// 373:     formula_installer = instance_double(FormulaInstaller, formula:, download_queue: nil, prelude_fetch: nil)
// 374:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 375:
// 376:     allow(Tap).to receive_messages(with_formula_name: nil, with_cask_token: nil)
// 377:     allow(Homebrew::Trust).to receive(:trust_fully_qualified_items!)
// 378:     allow(cmd.args.named).to receive(:to_formulae_and_casks).with(warn: false).and_return([formula])
// 379:     allow(Homebrew::Install).to receive(:perform_preinstall_checks_once)
// 380:     allow(Homebrew::Install).to receive(:check_cc_argv)
// 381:     allow(Homebrew::Install).to receive_messages(install_formula?: true, formula_installers: [formula_installer],
// 382:                                                  enqueue_formulae: [formula_installer])
// 383:     allow(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 384:     allow(formula_installer).to receive(:download_queue=)
// 385:     allow(Homebrew::Upgrade).to receive_messages(dependants:, upgrade_dependents: [])
// 386:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 387:     allow(Homebrew.messages).to receive(:display_messages)
// 388:     # A failure earlier in the run (e.g. one download of many) must not stop
// 389:     # the packages that are ready from being installed.
// 390:     Homebrew.failed = true
// 391:
// 392:     expect(Homebrew::Install).to receive(:install_formulae).with([formula_installer], dry_run: false, verbose: false)
// 393:
// 394:     cmd.run
// 395:   end
// 396:
// 397:   it "names the cask that failed to install", :cask do
// 398:     cmd = described_class.new(["--yes", "local-caffeine"])
// 399:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, shutdown: nil, failed_downloads: [])
// 400:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 401:     installer = instance_double(Cask::Installer, enqueue_downloads: nil, source_download_requires_pre_fetch?: false)
// 402:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 403:
// 404:     allow(Tap).to receive_messages(with_formula_name: nil, with_cask_token: nil)
// 405:     allow(Homebrew::Trust).to receive(:trust_fully_qualified_items!)
// 406:     allow(cmd.args.named).to receive(:to_formulae_and_casks).with(warn: false).and_return([cask])
// 407:     allow(Cask::Upgrade).to receive(:outdated_casks).and_return([])
// 408:     allow(Cask::Installer).to receive(:new).and_return(installer)
// 409:     allow(installer).to receive(:install).and_raise("uh-oh")
// 410:     allow(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 411:     allow(Homebrew::Install).to receive(:perform_preinstall_checks_once)
// 412:     allow(Homebrew::Install).to receive(:check_cc_argv)
// 413:     allow(Homebrew::Upgrade).to receive_messages(dependants:, upgrade_dependents: [])
// 414:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 415:     allow(Homebrew.messages).to receive(:display_messages)
// 416:
// 417:     expect { cmd.run }.to output(/local-caffeine: uh-oh/).to_stderr
// 418:   end
// 419:
// 420:   it "drains metadata-only prelude fetches before the dry-run plan when asking" do
// 421:     cmd = described_class.new(["testball"])
// 422:     downloads = { instance_double(Downloadable) => nil }
// 423:     download_queue = instance_double(Homebrew::DownloadQueue, shutdown: nil, failed_downloads: [], downloads:)
// 424:     formula = formula("testball") do
// 425:       T.bind(self, T.class_of(Formula))
// 426:       url "https://brew.sh/testball-0.1.tar.gz"
// 427:     end
// 428:     formula_installer = instance_double(FormulaInstaller, formula:)
// 429:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 430:
// 431:     allow(Tap).to receive_messages(with_formula_name: nil, with_cask_token: nil)
// 432:     allow(Homebrew::Trust).to receive(:trust_fully_qualified_items!)
// 433:     allow(cmd.args.named).to receive(:to_formulae_and_casks).with(warn: false).and_return([formula])
// 434:     allow(Homebrew::Install).to receive(:perform_preinstall_checks_once)
// 435:     allow(Homebrew::Install).to receive(:check_cc_argv)
// 436:     allow(Homebrew::Install).to receive_messages(install_formula?: true, formula_installers: [formula_installer])
// 437:     allow(Homebrew::Install).to receive(:install_formulae)
// 438:     allow(Homebrew::Upgrade).to receive(:upgrade_dependents)
// 439:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 440:     allow(Homebrew.messages).to receive(:display_messages)
// 441:     expect(Homebrew::DownloadQueue).to receive(:new).ordered.and_return(download_queue)
// 442:     expect(formula_installer).to receive(:download_queue=).with(download_queue).ordered
// 443:     expect(formula_installer).to receive(:prelude_fetch).with(metadata_only: true).ordered
// 444:     expect(Homebrew::Upgrade).to receive(:dependants).ordered.and_return(dependants)
// 445:     expect(download_queue).to receive(:fetch).ordered
// 446:     expect(Homebrew::Install).to receive(:ask_formulae).ordered
// 447:     expect(Homebrew::Install).to receive(:enqueue_formulae)
// 448:       .with([formula_installer], download_queue:)
// 449:       .ordered
// 450:       .and_return([formula_installer])
// 451:     expect(download_queue).to receive(:fetch).ordered
// 452:     expect(download_queue).to receive(:shutdown).ordered
// 453:
// 454:     cmd.run
// 455:   end
// 456:
// 457:   it "does not install `homebrew/cask` when a cask remains unavailable" do
// 458:     cmd = described_class.new(["foo"])
// 459:     cask_tap = CoreCaskTap.instance
// 460:
// 461:     require "search"
// 462:
// 463:     allow(Tap).to receive_messages(with_formula_name: nil, with_cask_token: nil, untapped_official_taps: [])
// 464:     allow(cmd.args.named).to receive(:to_formulae_and_casks).with(warn: false)
// 465:                                                             .and_raise(FormulaOrCaskUnavailableError.new("foo"))
// 466:     allow(cask_tap).to receive(:installed?).and_return(false)
// 467:     allow(Homebrew::Search).to receive(:search_names).and_return([[], []])
// 468:
// 469:     expect(cask_tap).not_to receive(:ensure_installed!)
// 470:
// 471:     expect { cmd.run }.to raise_error(SystemExit)
// 472:
// 473:     expect(Homebrew).to have_failed
// 474:   end
// 475:
// 476:   context "when installing Formulae" do
// 477:     it "builds from source and pours a keg-only bottle", :integration_test do
// 478:       source_formula_name = "sourceball"
// 479:       source_formula_prefix = HOMEBREW_CELLAR/source_formula_name/"0.1"
// 480:       bottle_formula_name = "testball_bottle"
// 481:       bottle_formula_prefix = HOMEBREW_CELLAR/bottle_formula_name/"0.1"
// 482:
// 483:       setup_test_formula source_formula_name, <<~RUBY
// 484:         url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 485:         sha256 TESTBALL_SHA256
// 486:
// 487:         def install
// 488:           (prefix/"built-from-source").write("test")
// 489:         end
// 490:       RUBY
// 491:       setup_test_formula bottle_formula_name, <<~RUBY
// 492:         keg_only "test reason"
// 493:       RUBY
// 494:
// 495:       with_env(HOMEBREW_NO_INSTALL_FROM_API: "1") do
// 496:         expect do
// 497:           brew "install", "--yes", source_formula_name, bottle_formula_name,
// 498:                "HOMEBREW_NO_INSTALL_FROM_API" => "1"
// 499:         end
// 500:           .to output(/#{Regexp.escape(source_formula_prefix)}.*#{Regexp.escape(bottle_formula_prefix)}/m).to_stdout
// 501:           .and output(/✔︎.*/m).to_stderr
// 502:           .and be_a_success
// 503:       end
// 504:       expect(source_formula_prefix/"built-from-source").to be_a_file
// 505:       expect(bottle_formula_prefix/"foo/test").not_to be_a_file
// 506:       expect(bottle_formula_prefix/"bin/helloworld").to be_a_file
// 507:       expect(HOMEBREW_PREFIX/"bin/helloworld").not_to be_a_file
// 508:     end
// 509:   end
// 510:
// 511:   context "when installing HEAD" do
// 512:     let(:formula_name) { "testball1" }
// 513:
// 514:     it "installs a HEAD Formula", :integration_test do
// 515:       testball1_prefix = HOMEBREW_CELLAR/"testball1/HEAD-d5eb689"
// 516:       repo_path = HOMEBREW_CACHE/"repo"
// 517:       (repo_path/"bin").mkpath
// 518:
// 519:       repo_path.cd do
// 520:         system "git", "-c", "init.defaultBranch=master", "init"
// 521:         system "git", "remote", "add", "origin", "https://github.com/Homebrew/homebrew-foo"
// 522:         FileUtils.touch "bin/something.bin"
// 523:         FileUtils.touch "README"
// 524:         system "git", "add", "--all"
// 525:         system "git", "commit", "-m", "Initial repo commit"
// 526:       end
// 527:
// 528:       setup_test_formula "testball1", <<~RUBY
// 529:         version "1.0"
// 530:
// 531:         head "file://#{repo_path}", using: :git
// 532:
// 533:         def install
// 534:           prefix.install Dir["*"]
// 535:         end
// 536:       RUBY
// 537:
// 538:       with_env(HOMEBREW_NO_INSTALL_FROM_API: "1") do
// 539:         expect do
// 540:           brew "install", "-y", formula_name, "--HEAD",
// 541:                "HOMEBREW_DOWNLOAD_CONCURRENCY" => "1",
// 542:                "HOMEBREW_NO_INSTALL_FROM_API"  => "1"
// 543:         end
// 544:           .to output(/#{Regexp.escape(testball1_prefix)}/o).to_stdout
// 545:           .and output(/Cloning into/).to_stderr
// 546:           .and be_a_success
// 547:       end
// 548:       expect(testball1_prefix/"foo/test").not_to be_a_file
// 549:       expect(testball1_prefix/"bin/something.bin").to be_a_file
// 550:     end
// 551:   end
// 552:
// 553:   it "prints a shared fetch heading and correct upgrade count", :cask do
// 554:     cmd = described_class.new(["--yes", "codex"])
// 555:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, shutdown: nil, failed_downloads: [])
// 556:     formula = formula("testball_bottle") do
// 557:       T.bind(self, T.class_of(Formula))
// 558:       url "https://brew.sh/testball_bottle-0.1.tar.gz"
// 559:     end
// 560:     formula_installer = instance_double(FormulaInstaller, formula:)
// 561:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 562:     installer = instance_double(Cask::Installer, enqueue_downloads: nil, source_download_requires_pre_fetch?: false)
// 563:
// 564:     allow(Tap).to receive_messages(with_formula_name: nil, with_cask_token: nil)
// 565:     allow(cmd.args.named).to receive(:to_formulae_and_casks).with(warn: false).and_return([formula, cask])
// 566:     allow(cask).to receive_messages(
// 567:       installed?:        true,
// 568:       full_name:         "codex",
// 569:       installed_version: "0.117.0",
// 570:       version:           "0.118.0",
// 571:     )
// 572:     allow(Cask::Upgrade).to receive(:outdated_casks).and_return([cask])
// 573:     allow(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 574:     allow(Homebrew::Install).to receive(:install_formula?).and_return(true)
// 575:     allow(Homebrew::Install).to receive(:perform_preinstall_checks_once)
// 576:     allow(Homebrew::Install).to receive(:check_cc_argv)
// 577:     allow(Homebrew::Upgrade).to receive(:dependants).and_return(Homebrew::Upgrade::Dependents.new(
// 578:                                                                   upgradeable: [],
// 579:                                                                   pinned:      [],
// 580:                                                                   skipped:     [],
// 581:                                                                 ))
// 582:     allow(Homebrew::Install).to receive_messages(
// 583:       formula_installers: [formula_installer],
// 584:       enqueue_formulae:   [formula_installer],
// 585:     )
// 586:     allow(formula_installer).to receive(:download_queue=)
// 587:     allow(formula_installer).to receive(:prelude_fetch)
// 588:     allow(Cask::Installer).to receive(:new).and_return(installer)
// 589:     allow(Homebrew::Install).to receive(:install_formulae)
// 590:     allow(Homebrew::Upgrade).to receive(:upgrade_dependents)
// 591:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 592:     allow(Homebrew.messages).to receive(:display_messages)
// 593:     allow(Cask::Upgrade).to receive(:upgrade_casks!) do |*_, **kwargs|
// 594:       expect(kwargs[:skip_prefetch]).to be(true)
// 595:       expect(kwargs[:show_upgrade_summary]).to be(false)
// 596:
// 597:       true
// 598:     end
// 599:     expect(download_queue).to receive(:fetch)
// 600:       .with(heading: "Fetching downloads for: testball_bottle and codex")
// 601:
// 602:     expect { cmd.run }.to output(<<~EOS).to_stdout
// 603:       ==> Upgrading 1 outdated package:
// 604:       codex 0.117.0 -> 0.118.0
// 605:     EOS
// 606:   end
// 607: end
