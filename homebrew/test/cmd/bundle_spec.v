module cmd

import homebrew.cmd as bundle_cmd

// Translated from Homebrew/brew `test/cmd/bundle_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn bundle_spec_parse(argv []string, environment map[string]string) ?bundle_cmd.BundleCommandArgs {
	return bundle_cmd.parse_bundle_command_args(argv, environment) or { none }
}

fn bundle_spec_external_command(argv []string, environment map[string]string,
	command string) bool {
	result := bundle_cmd.run_bundle_command(argv, bundle_cmd.BundleCommandConfig{
		environment: environment
	}) or { return false }
	invocation := result.external_invocation
	return invocation.command == command && invocation.options.check && invocation.options.no_secrets && !invocation.options.services && !invocation.options.global && invocation.options.file == ''
}

// Ruby it `it "handles default install subcommand options", :aggregate_failures do` at line 12.
pub fn ruby_bundle_spec_l12_d1_handles() bool {
	default_args := bundle_spec_parse([], {}) or { return false }
	option_args := bundle_spec_parse(['--force-cleanup', '--zap'], {}) or { return false }
	return default_args.subcommand == 'install' && option_args.subcommand == 'install' && option_args.force_cleanup && option_args.zap
}

// Ruby it `it "maps bundle cleanup environment variables to install options", :aggregate_failures do` at line 19.
pub fn ruby_bundle_spec_l19_d2_maps() bool {
	cleanup_args := bundle_spec_parse(['--global'], {
		'HOMEBREW_BUNDLE_INSTALL_CLEANUP': '1'
	}) or { return false }
	force_args := bundle_spec_parse(['--global'], {
		'HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP': '1'
	}) or { return false }
	return cleanup_args.cleanup && !cleanup_args.force_cleanup && !force_args.cleanup && force_args.force_cleanup
}

// Ruby it `it "rejects install-only options for exec" do` at line 33.
pub fn ruby_bundle_spec_l33_d3_rejects() bool {
	bundle_cmd.parse_bundle_command_args(['exec', '--jobs=1', 'true'], {}) or {
		return err.msg().contains('`exec` subcommand does not accept the `--jobs` flag')
	}
	return false
}

// Ruby it `it "treats upgrade as install --upgrade", :aggregate_failures do` at line 38.
pub fn ruby_bundle_spec_l38_d4_treats() bool {
	config := bundle_cmd.BundleCommandConfig{
		environment: {
			'HOMEBREW_BUNDLE_NO_UPGRADE': '1'
		}
	}
	args := bundle_cmd.parse_bundle_command_args(['upgrade', '-fq'], config.environment) or {
		return false
	}
	context := bundle_cmd.bundle_command_context(args, config, false)
	return args.subcommand == 'install' && args.upgrade && args.force && args.quiet && context.subcommand == 'install' && !context.no_upgrade
}

// Ruby it `it "tracks ask mode in the subcommand context" do` at line 52.
pub fn ruby_bundle_spec_l52_d5_tracks() bool {
	args := bundle_spec_parse(['cleanup'], {}) or { return false }
	return bundle_cmd.bundle_command_context(args, bundle_cmd.BundleCommandConfig{}, true).ask
}

// Ruby it `it "lets HOMEBREW_BUNDLE_NO_JOBS disable env-driven parallel jobs" do` at line 59.
pub fn ruby_bundle_spec_l59_d6_lets() bool {
	config := bundle_cmd.BundleCommandConfig{
		environment: {
			'HOMEBREW_BUNDLE_JOBS':    'auto'
			'HOMEBREW_BUNDLE_NO_JOBS': '1'
		}
		processor_count: 8
	}
	args := bundle_cmd.parse_bundle_command_args([], config.environment) or { return false }
	return bundle_cmd.bundle_command_context(args, config, false).jobs == 1
}

// Ruby it `it "disables ask mode for subcommands" do` at line 68.
pub fn ruby_bundle_spec_l68_d7_disables() bool {
	result := bundle_cmd.run_bundle_command(['cleanup'], bundle_cmd.BundleCommandConfig{}) or {
		return false
	}
	return result.context.ask && result.ask_environment_off && 'HOMEBREW_ASK' !in result.environment_after && result.environment_after['HOMEBREW_NO_ASK'] == '1'
}

// Ruby it `it "accepts global flags on subcommands that do not re-declare them", :aggregate_failures do` at line 82.
pub fn ruby_bundle_spec_l82_d8_accepts() bool {
	cleanup_long := bundle_spec_parse(['cleanup', '--verbose'], {}) or { return false }
	cleanup_short := bundle_spec_parse(['cleanup', '-v'], {}) or { return false }
	dump_args := bundle_spec_parse(['dump', '--verbose'], {}) or { return false }
	list := bundle_spec_parse(['list', '--verbose'], {}) or { return false }
	return cleanup_long.verbose && cleanup_short.verbose && dump_args.subcommand == 'dump' && dump_args.verbose && list.subcommand == 'list' && list.verbose
}

// Ruby it `it "uses subcommand-specific option descriptions", :aggregate_failures do` at line 89.
pub fn ruby_bundle_spec_l89_d9_uses() bool {
	install := bundle_cmd.bundle_subcommand_options('install')
	list := bundle_cmd.bundle_subcommand_options('list')
	dump_options := bundle_cmd.bundle_subcommand_options('dump')
	cleanup := bundle_cmd.bundle_subcommand_options('cleanup')
	add := bundle_cmd.bundle_subcommand_options('add')
	remove := bundle_cmd.bundle_subcommand_options('remove')
	upgrade := bundle_cmd.bundle_subcommand_options('upgrade')
	return '--ask' !in install && install['--force-cleanup'].contains('`\$HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP`') && list['--vscode'] == 'List VSCode (and forks/variants) extensions.' && dump_options['--vscode'] == 'Dump VSCode (and forks/variants) extensions.' && dump_options['--no-mas'].contains('`dump` without Mac App Store dependencies.') && cleanup['--vscode'] == 'Clean up VSCode (and forks/variants) extensions.' && cleanup['--no-mas'].contains('`cleanup` without Mac App Store dependencies.') && cleanup['--all'] == 'Clean up all supported dependencies.' && cleanup['--force'] == "Actually perform cleanup operations and reset Homebrew's global trust store to the `Brewfile` values." && dump_options['--no-describe'].contains('Description comments are the default') && add['--no-describe'].contains('Description comments are the default') && add['--vscode'] == 'Add entries for VSCode (and forks/variants) extensions.' && remove['--vscode'] == 'Remove entries for VSCode (and forks/variants) extensions.' && upgrade['--force'] == 'Run with `--force`/`--overwrite`.'
}

// Ruby it `it "uses subcommand-specific descriptions in help output", :aggregate_failures do` at line 114.
pub fn ruby_bundle_spec_l114_d10_uses() bool {
	help_text := bundle_cmd.bundle_help_text('list')
	return help_text.contains('List VSCode (and forks/variants) extensions.') && !help_text.contains('Clean up VSCode (and forks/variants) extensions.')
}

// Ruby it `it "lets explicit dump type flags override environment disables", :aggregate_failures do` at line 121.
pub fn ruby_bundle_spec_l121_d11_lets() bool {
	args := bundle_spec_parse(['dump', '--formula', '--mas'], {
		'HOMEBREW_BUNDLE_DUMP_NO_BREW': '1'
		'HOMEBREW_BUNDLE_DUMP_NO_MAS':  '1'
	}) or { return false }
	return args.selected_types['brew'] && args.selected_types['mas'] && !args.dump_disabled['brew'] && !args.dump_disabled['mas']
}

// Ruby it `it "lets explicit cleanup type flags override environment disables", :aggregate_failures do` at line 132.
pub fn ruby_bundle_spec_l132_d12_lets() bool {
	args := bundle_spec_parse(['cleanup', '--formula', '--mas'], {
		'HOMEBREW_BUNDLE_CLEANUP_NO_BREW': '1'
		'HOMEBREW_BUNDLE_CLEANUP_NO_MAS':  '1'
	}) or { return false }
	return args.selected_types['brew'] && args.selected_types['mas'] && !args.cleanup_disabled['brew'] && !args.cleanup_disabled['mas']
}

// Ruby it `it "passes HOMEBREW_BUNDLE_CHECK through to exec" do` at line 143.
pub fn ruby_bundle_spec_l143_d13_passes() bool {
	return bundle_spec_external_command(['exec', '/usr/bin/true'], {
		'HOMEBREW_BUNDLE_CHECK': '1'
	}, '/usr/bin/true')
}

// Ruby it `it "passes --check through to exec" do` at line 161.
pub fn ruby_bundle_spec_l161_d14_passes() bool {
	return bundle_spec_external_command(['exec', '--check', '/usr/bin/true'], {}, '/usr/bin/true')
}

// Ruby it `it "passes --check through to sh" do` at line 178.
pub fn ruby_bundle_spec_l178_d15_passes() bool {
	return bundle_spec_external_command(['sh', '--check'], {}, 'sh')
}

// Ruby it `it "passes --check through to env" do` at line 195.
pub fn ruby_bundle_spec_l195_d16_passes() bool {
	return bundle_spec_external_command(['env', '--check'], {}, 'env')
}

// Ruby it `it "checks if a Brewfile's dependencies are satisfied", :integration_test do` at line 212.
pub fn ruby_bundle_spec_l212_d17_checks() bool {
	result := bundle_cmd.run_bundle_command(['check'], bundle_cmd.BundleCommandConfig{}) or {
		return false
	}
	return result.check_result.exit_code == 0 && result.check_result.stdout == "The Brewfile's dependencies are satisfied.\n" && result.check_result.stderr == ''
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/bundle"
// 5: require "bundle"
// 6: require "cmd/shared_examples/args_parse"
// 7: require "commands"
// 8:
// 9: RSpec.describe Homebrew::Cmd::Bundle do
// 10:   it_behaves_like "parseable arguments"
// 11:
// 12:   it "handles default install subcommand options", :aggregate_failures do
// 13:     with_env("HOMEBREW_BUNDLE_INSTALL_CLEANUP" => nil, "HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP" => nil) do
// 14:       expect(described_class.new([]).args.subcommand).to eq("install")
// 15:       expect(described_class.new(%w[--force-cleanup --zap]).args.subcommand).to eq("install")
// 16:     end
// 17:   end
// 18:
// 19:   it "maps bundle cleanup environment variables to install options", :aggregate_failures do
// 20:     with_env("HOMEBREW_BUNDLE_INSTALL_CLEANUP" => "1", "HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP" => nil) do
// 21:       args = described_class.new(["--global"]).args
// 22:       expect(args.cleanup?).to be(true)
// 23:       expect(args.force_cleanup?).to be(false)
// 24:     end
// 25:
// 26:     with_env("HOMEBREW_BUNDLE_INSTALL_CLEANUP" => nil, "HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP" => "1") do
// 27:       args = described_class.new(["--global"]).args
// 28:       expect(args.cleanup?).to be(false)
// 29:       expect(args.force_cleanup?).to be(true)
// 30:     end
// 31:   end
// 32:
// 33:   it "rejects install-only options for exec" do
// 34:     expect { described_class.new(%w[exec --jobs=1 true]) }
// 35:       .to raise_error(UsageError, /`exec` subcommand does not accept the `--jobs` flag/)
// 36:   end
// 37:
// 38:   it "treats upgrade as install --upgrade", :aggregate_failures do
// 39:     with_env("HOMEBREW_BUNDLE_NO_UPGRADE" => "1") do
// 40:       args = described_class.new(%w[upgrade -fq]).args
// 41:       context = described_class.context(args, extensions: Homebrew::Cmd::Bundle::BUNDLE_EXTENSIONS)
// 42:
// 43:       expect(args.subcommand).to eq("install")
// 44:       expect(args.upgrade?).to be(true)
// 45:       expect(args.force?).to be(true)
// 46:       expect(args.quiet?).to be(true)
// 47:       expect(context.subcommand).to eq("install")
// 48:       expect(context.no_upgrade).to be(false)
// 49:     end
// 50:   end
// 51:
// 52:   it "tracks ask mode in the subcommand context" do
// 53:     args = described_class.new(%w[cleanup]).args
// 54:     context = described_class.context(args, extensions: Homebrew::Cmd::Bundle::BUNDLE_EXTENSIONS, ask: true)
// 55:
// 56:     expect(context.ask).to be(true)
// 57:   end
// 58:
// 59:   it "lets HOMEBREW_BUNDLE_NO_JOBS disable env-driven parallel jobs" do
// 60:     with_env(HOMEBREW_BUNDLE_JOBS: "auto", HOMEBREW_BUNDLE_NO_JOBS: "1") do
// 61:       args = described_class.new([]).args
// 62:       context = described_class.context(args, extensions: Homebrew::Cmd::Bundle::BUNDLE_EXTENSIONS)
// 63:
// 64:       expect(context.jobs).to eq(1)
// 65:     end
// 66:   end
// 67:
// 68:   it "disables ask mode for subcommands" do
// 69:     with_env(HOMEBREW_ASK: nil, HOMEBREW_NO_ASK: nil) do
// 70:       args = described_class.new(%w[cleanup]).args
// 71:       expect(Homebrew::Cmd::Bundle::CleanupSubcommand).to receive(:new) do |_, context:, **|
// 72:         expect(context.ask).to be(true)
// 73:         expect(ENV.fetch("HOMEBREW_ASK", nil)).to be_nil
// 74:         expect(ENV.fetch("HOMEBREW_NO_ASK", nil)).to eq("1")
// 75:         instance_double(Homebrew::Cmd::Bundle::CleanupSubcommand, run: nil)
// 76:       end
// 77:
// 78:       described_class.dispatch(args, extensions: Homebrew::Cmd::Bundle::BUNDLE_EXTENSIONS)
// 79:     end
// 80:   end
// 81:
// 82:   it "accepts global flags on subcommands that do not re-declare them", :aggregate_failures do
// 83:     expect(described_class.new(%w[cleanup --verbose]).args.verbose?).to be(true)
// 84:     expect(described_class.new(%w[cleanup -v]).args.verbose?).to be(true)
// 85:     expect(described_class.new(%w[dump --verbose]).args.subcommand).to eq("dump")
// 86:     expect(described_class.new(%w[list --verbose]).args.subcommand).to eq("list")
// 87:   end
// 88:
// 89:   it "uses subcommand-specific option descriptions", :aggregate_failures do
// 90:     subcommand_options = ->(subcommand) { Commands.command_options("bundle", subcommand:).to_h }
// 91:
// 92:     expect(subcommand_options.call("install")).not_to have_key("--ask")
// 93:     expect(subcommand_options.call("install")["--force-cleanup"])
// 94:       .to include("`$HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP`")
// 95:     expect(subcommand_options.call("list")["--vscode"]).to eq("List VSCode (and forks/variants) extensions.")
// 96:     expect(subcommand_options.call("dump")["--vscode"]).to eq("Dump VSCode (and forks/variants) extensions.")
// 97:     expect(subcommand_options.call("dump")["--no-mas"])
// 98:       .to include("`dump` without Mac App Store dependencies.")
// 99:     expect(subcommand_options.call("cleanup")["--vscode"]).to eq("Clean up VSCode (and forks/variants) extensions.")
// 100:     expect(subcommand_options.call("cleanup")["--no-mas"])
// 101:       .to include("`cleanup` without Mac App Store dependencies.")
// 102:     expect(subcommand_options.call("cleanup")["--all"]).to eq("Clean up all supported dependencies.")
// 103:     expect(subcommand_options.call("cleanup")["--force"])
// 104:       .to eq("Actually perform cleanup operations and reset Homebrew's global trust store to the `Brewfile` values.")
// 105:     expect(subcommand_options.call("dump")["--no-describe"]).to include("Description comments are the default")
// 106:     expect(subcommand_options.call("add")["--no-describe"]).to include("Description comments are the default")
// 107:     expect(subcommand_options.call("add")["--vscode"])
// 108:       .to eq("Add entries for VSCode (and forks/variants) extensions.")
// 109:     expect(subcommand_options.call("remove")["--vscode"])
// 110:       .to eq("Remove entries for VSCode (and forks/variants) extensions.")
// 111:     expect(subcommand_options.call("upgrade")["--force"]).to eq("Run with `--force`/`--overwrite`.")
// 112:   end
// 113:
// 114:   it "uses subcommand-specific descriptions in help output", :aggregate_failures do
// 115:     help_text = described_class.parser.generate_help_text(remaining_args: ["list"])
// 116:
// 117:     expect(help_text).to include("List VSCode (and forks/variants) extensions.")
// 118:     expect(help_text).not_to include("Clean up VSCode (and forks/variants) extensions.")
// 119:   end
// 120:
// 121:   it "lets explicit dump type flags override environment disables", :aggregate_failures do
// 122:     with_env("HOMEBREW_BUNDLE_DUMP_NO_BREW" => "1", "HOMEBREW_BUNDLE_DUMP_NO_MAS" => "1") do
// 123:       args = described_class.new(%w[dump --formula --mas]).args
// 124:
// 125:       expect(args.formulae?).to be(true)
// 126:       expect(args.mas?).to be(true)
// 127:       expect(args.no_dump_brew?).to be(false)
// 128:       expect(args.no_dump_mas?).to be(false)
// 129:     end
// 130:   end
// 131:
// 132:   it "lets explicit cleanup type flags override environment disables", :aggregate_failures do
// 133:     with_env("HOMEBREW_BUNDLE_CLEANUP_NO_BREW" => "1", "HOMEBREW_BUNDLE_CLEANUP_NO_MAS" => "1") do
// 134:       args = described_class.new(%w[cleanup --formula --mas]).args
// 135:
// 136:       expect(args.formulae?).to be(true)
// 137:       expect(args.mas?).to be(true)
// 138:       expect(args.no_cleanup_brew?).to be(false)
// 139:       expect(args.no_cleanup_mas?).to be(false)
// 140:     end
// 141:   end
// 142:
// 143:   it "passes HOMEBREW_BUNDLE_CHECK through to exec" do
// 144:     with_env("HOMEBREW_BUNDLE_CHECK" => "1", "HOMEBREW_BUNDLE_NO_SECRETS" => nil,
// 145:              "HOMEBREW_BUNDLE_SECRETS" => nil) do
// 146:       expect(Homebrew::Cmd::Bundle::ExecSubcommand).to receive(:run_external_command)
// 147:         .with(
// 148:           "/usr/bin/true",
// 149:           global:     false,
// 150:           file:       nil,
// 151:           subcommand: "exec",
// 152:           services:   false,
// 153:           check:      true,
// 154:           no_secrets: true,
// 155:         )
// 156:
// 157:       described_class.new(["exec", "/usr/bin/true"]).run
// 158:     end
// 159:   end
// 160:
// 161:   it "passes --check through to exec" do
// 162:     with_env("HOMEBREW_BUNDLE_NO_SECRETS" => nil, "HOMEBREW_BUNDLE_SECRETS" => nil) do
// 163:       expect(Homebrew::Cmd::Bundle::ExecSubcommand).to receive(:run_external_command)
// 164:         .with(
// 165:           "/usr/bin/true",
// 166:           global:     false,
// 167:           file:       nil,
// 168:           subcommand: "exec",
// 169:           services:   false,
// 170:           check:      true,
// 171:           no_secrets: true,
// 172:         )
// 173:
// 174:       described_class.new(["exec", "--check", "/usr/bin/true"]).run
// 175:     end
// 176:   end
// 177:
// 178:   it "passes --check through to sh" do
// 179:     with_env("HOMEBREW_BUNDLE_NO_SECRETS" => nil, "HOMEBREW_BUNDLE_SECRETS" => nil) do
// 180:       expect(Homebrew::Cmd::Bundle::ExecSubcommand).to receive(:run_external_command)
// 181:         .with(
// 182:           "sh",
// 183:           global:     false,
// 184:           file:       nil,
// 185:           subcommand: "sh",
// 186:           services:   false,
// 187:           check:      true,
// 188:           no_secrets: true,
// 189:         )
// 190:
// 191:       described_class.new(["sh", "--check"]).run
// 192:     end
// 193:   end
// 194:
// 195:   it "passes --check through to env" do
// 196:     with_env("HOMEBREW_BUNDLE_NO_SECRETS" => nil, "HOMEBREW_BUNDLE_SECRETS" => nil) do
// 197:       expect(Homebrew::Cmd::Bundle::ExecSubcommand).to receive(:run_external_command)
// 198:         .with(
// 199:           "env",
// 200:           global:     false,
// 201:           file:       nil,
// 202:           subcommand: "env",
// 203:           services:   false,
// 204:           check:      true,
// 205:           no_secrets: true,
// 206:         )
// 207:
// 208:       described_class.new(["env", "--check"]).run
// 209:     end
// 210:   end
// 211:
// 212:   it "checks if a Brewfile's dependencies are satisfied", :integration_test do
// 213:     HOMEBREW_REPOSITORY.cd do
// 214:       system "git", "init"
// 215:       system "git", "commit", "--allow-empty", "-m", "This is a test commit"
// 216:     end
// 217:
// 218:     mktmpdir do |path|
// 219:       FileUtils.touch "#{path}/Brewfile"
// 220:       path.cd do
// 221:         expect { brew "bundle", "check" }
// 222:           .to output("The Brewfile's dependencies are satisfied.\n").to_stdout
// 223:           .and not_to_output.to_stderr
// 224:           .and be_a_success
// 225:       end
// 226:     end
// 227:   end
// 228: end
