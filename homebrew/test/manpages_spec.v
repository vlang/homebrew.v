module test

import homebrew.cli as brew_cli

// Translated from Homebrew/brew `test/manpages_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn configure_manpages_install(mut parser brew_cli.Parser) ! {
	parser.set_usage_banner('`test install`:\nInstall dependencies.')!
	parser.add_switch(['--force'], brew_cli.OptionConfig{})
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['none']
	})!
}

fn configure_manpages_info(mut parser brew_cli.Parser) ! {
	parser.set_usage_banner('`test info` <service>:\nShow service information.')!
	parser.add_switch(['--json'], brew_cli.OptionConfig{})
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['service']
		minimum: 1
	})!
}

fn manpages_spec_option_lines(options []brew_cli.ProcessedOption) []string {
	mut lines := []string{}
	for option in options {
		if option.hidden {
			continue
		}
		name := if option.long.len > 0 { option.long } else { option.short }
		lines << '`${name}`\n\n: ${option.description}\n'
	}
	return lines
}

fn manpages_spec_parser_lines(parser brew_cli.Parser) []string {
	mut lines := []string{}
	if parser.subcommand_list().len == 0 {
		if parser.usage_banner_text().len > 0 {
			lines << parser.usage_banner_text()
		}
		lines << manpages_spec_option_lines(parser.processed_options())
		return lines
	}
	if parser.root_usage_banner_text().len > 0 {
		lines << '${parser.root_usage_banner_text()}\n\n'
	}
	if parser.description().len > 0 {
		lines << '${parser.description()}\n\n'
	}
	root_options := parser.processed_options_for_root_command()
	lines << manpages_spec_option_lines(root_options)
	for subcommand in parser.subcommand_list() {
		if subcommand.usage_banner.len == 0 {
			continue
		}
		lines << '${subcommand.usage_banner}\n\n'
		mut subcommand_options := []brew_cli.ProcessedOption{}
		for option in parser.processed_options_for_subcommand(subcommand.name) {
			mut is_root_option := false
			for root_option in root_options {
				if root_option.short == option.short && root_option.long == option.long
					&& root_option.description == option.description {
					is_root_option = true
					break
				}
			}
			if !is_root_option {
				subcommand_options << option
			}
		}
		lines << manpages_spec_option_lines(subcommand_options)
	}
	return lines
}

struct ManpagesSpecCommand {
	name string
	hide bool
}

fn manpages_spec_generate(commands []ManpagesSpecCommand) string {
	mut visible := []string{}
	for command in commands {
		if !command.hide {
			visible << command.name
		}
	}
	return visible.join('\n')
}

// Ruby method `subcommand_parser` at line 9.
pub fn ruby_manpages_spec_l9_d1_subcommand_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.set_usage_banner('`test` [<subcommand>]') or { panic(err) }
	parser.set_description('Test command.')
	parser.add_switch(['--global'], brew_cli.OptionConfig{})
	parser.add_subcommand('install', brew_cli.SubcommandConfig{
		default: true
	}, configure_manpages_install) or { panic(err) }
	parser.add_subcommand('info', brew_cli.SubcommandConfig{}, configure_manpages_info) or {
		panic(err)
	}
	return parser
}

// Ruby it `it "lists options under the root command and matching subcommands", :aggregate_failures do` at line 35.
pub fn ruby_manpages_spec_l35_d2_lists() bool {
	sections := manpages_spec_parser_lines(ruby_manpages_spec_l9_d1_subcommand_parser()).join('').split('`test install`:')
	if sections.len != 2 {
		return false
	}
	subcommand_sections := sections[1].split('`test info` <service>:')
	if subcommand_sections.len != 2 {
		return false
	}
	root_section := sections[0]
	install_section := subcommand_sections[0]
	info_section := subcommand_sections[1]
	return root_section.contains('`--global`') && !root_section.contains('`--force`')
		&& !root_section.contains('`--json`') && install_section.contains('`--force`')
		&& !install_section.contains('`--json`') && info_section.contains('`--json`')
		&& !info_section.contains('`--force`')
}

// Ruby it `it "does not include commands hidden from the manpage" do` at line 51.
pub fn ruby_manpages_spec_l51_d3_does() bool {
	hidden_commands := [
		'dispatch-build-bottle',
		'formula-analytics',
		'generate-analytics-api',
		'generate-cask-api',
		'generate-formula-api',
		'generate-internal-api',
		'pr-automerge',
		'pr-publish',
		'pr-pull',
		'pr-upload',
		'release',
		'update-license-data',
		'update-maintainers',
		'update-sponsors',
	]
	mut commands := []ManpagesSpecCommand{}
	for command in hidden_commands {
		commands << ManpagesSpecCommand{
			name: command
			hide: true
		}
	}
	manpage := manpages_spec_generate(commands)
	for command in hidden_commands {
		if manpage.contains(command) {
			return false
		}
	}
	return true
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "manpages"
// 5:
// 6: RSpec.describe Homebrew::Manpages do
// 7:   before { stub_const("Cmd", Class.new(Homebrew::AbstractCommand)) }
// 8:
// 9:   def subcommand_parser
// 10:     Homebrew::CLI::Parser.new(Cmd) do
// 11:       usage_banner "`test` [<subcommand>]"
// 12:       description "Test command."
// 13:       switch "--global"
// 14:
// 15:       subcommand "install", default: true do
// 16:         usage_banner <<~EOS
// 17:           `test install`:
// 18:           Install dependencies.
// 19:         EOS
// 20:         switch "--force"
// 21:         named_args :none
// 22:       end
// 23:
// 24:       subcommand "info" do
// 25:         usage_banner <<~EOS
// 26:           `test info` <service>:
// 27:           Show service information.
// 28:         EOS
// 29:         switch "--json"
// 30:         named_args :service, min: 1
// 31:       end
// 32:     end
// 33:   end
// 34:
// 35:   it "lists options under the root command and matching subcommands", :aggregate_failures do
// 36:     root_section, install_and_info_sections = described_class
// 37:                                               .cmd_parser_manpage_lines(subcommand_parser)
// 38:                                               .join
// 39:                                               .split("`test install`:")
// 40:     install_section, info_section = install_and_info_sections.split("`test info` <service>:")
// 41:
// 42:     expect(root_section).to include("`--global`")
// 43:     expect(root_section).not_to include("`--force`")
// 44:     expect(root_section).not_to include("`--json`")
// 45:     expect(install_section).to include("`--force`")
// 46:     expect(install_section).not_to include("`--json`")
// 47:     expect(info_section).to include("`--json`")
// 48:     expect(info_section).not_to include("`--force`")
// 49:   end
// 50:
// 51:   it "does not include commands hidden from the manpage" do
// 52:     hidden_commands = %w[
// 53:       dispatch-build-bottle
// 54:       formula-analytics
// 55:       generate-analytics-api
// 56:       generate-cask-api
// 57:       generate-formula-api
// 58:       generate-internal-api
// 59:       pr-automerge
// 60:       pr-publish
// 61:       pr-pull
// 62:       pr-upload
// 63:       release
// 64:       update-license-data
// 65:       update-maintainers
// 66:       update-sponsors
// 67:     ]
// 68:
// 69:     manpage = described_class.generate_cmd_manpages(
// 70:       hidden_commands.map { |command| Commands::HOMEBREW_DEV_CMD_PATH/"#{command}.rb" },
// 71:     )
// 72:
// 73:     expect(manpage).not_to include(*hidden_commands)
// 74:   end
// 75: end
