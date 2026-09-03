module dev_cmd

import brew_runtime
import encoding.utf8
import os

// Translated from Homebrew/brew `dev-cmd/update-maintainers.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct UpdateMaintainersOptions {
pub:
	repository       string
	lead_maintainers map[string]string
	maintainers      map[string]string
	diff_success     bool
}

pub struct UpdateMaintainersResult {
pub:
	bundler_groups      []string
	lead_sentence       string
	maintainers_sentence string
	readme_path         string
	diff_command        []string
	regenerate_manpages bool
	manpages_quiet      bool
	stdout              string
	stderr              string
	failed              bool
}

struct MaintainerLink {
	key  string
	text string
}

fn maintainer_sort_key(value string) string {
	return value.runes().filter(utf8.is_letter(it)).string().to_lower()
}

fn maintainer_sentence(members map[string]string, excluded map[string]string) string {
	mut links := []MaintainerLink{}
	for login, name in members {
		if login in excluded {
			continue
		}
		text := '[${name}](https://github.com/${login})'
		links << MaintainerLink{
			key: maintainer_sort_key(text)
			text: text
		}
	}
	links.sort_with_compare(fn (a &MaintainerLink, b &MaintainerLink) int {
		return compare_strings(a.key, b.key)
	})
	values := links.map(it.text)
	return match values.len {
		0 { '' }
		1 { values[0] }
		2 { '${values[0]} and ${values[1]}' }
		else { '${values[..values.len - 1].join(', ')} and ${values.last()}' }
	}
}

fn replace_maintainer_line(content string, marker string, sentence string) string {
	start := content.index(marker) or { return content }
	line_end := content[start..].index('\n') or { content.len - start }
	end := start + line_end
	line := content[start..end]
	are_index := line.index(' are ') or { -1 }
	is_index := line.index(' is ') or { -1 }
	separator := if are_index >= 0 && (is_index < 0 || are_index < is_index) {
		are_index + ' are'.len
	} else if is_index >= 0 {
		is_index + ' is'.len
	} else {
		return content
	}
	dot := line.last_index('.') or { return content }
	if dot < separator {
		return content
	}
	return content[..start + separator] + ' ${sentence}.' + content[start + dot + 1..]
}

pub fn run_update_maintainers(options UpdateMaintainersOptions) !UpdateMaintainersResult {
	lead_sentence := maintainer_sentence(options.lead_maintainers, map[string]string{})
	maintainers_sentence := maintainer_sentence(options.maintainers, options.lead_maintainers)
	readme_path := os.join_path(options.repository, 'README.md')
	content := os.read_file(readme_path)!
	with_leads := replace_maintainer_line(content, "Homebrew's [Lead Maintainers", lead_sentence)
	updated := replace_maintainer_line(with_leads, "Homebrew's other Maintainers", maintainers_sentence)
	os.write_file(readme_path, updated)!
	command := ['git', '-C', options.repository, 'diff', '--exit-code', 'README.md']
	if options.diff_success {
		return UpdateMaintainersResult{
			bundler_groups: ['man']
			lead_sentence: lead_sentence
			maintainers_sentence: maintainers_sentence
			readme_path: readme_path
			diff_command: command
			stderr: 'No changes to list of maintainers.\n'
			failed: true
		}
	}
	return UpdateMaintainersResult{
		bundler_groups: ['man']
		lead_sentence: lead_sentence
		maintainers_sentence: maintainers_sentence
		readme_path: readme_path
		diff_command: command
		regenerate_manpages: true
		manpages_quiet: true
		stdout: 'List of maintainers updated in the README and the generated man pages.\n'
	}
}

@[heap]
pub struct UpdateMaintainersInput {
pub:
	options UpdateMaintainersOptions
}

pub fn update_maintainers_input_boundary(input &UpdateMaintainersInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::UpdateMaintainers::Input', '', {
		'update_maintainers_input_address': u64(voidptr(input)).str()
	})
}

fn update_maintainers_input_from_value(value brew_runtime.Value) &UpdateMaintainersInput {
	address := value.attributes['update_maintainers_input_address'] or {
		panic('invalid UpdateMaintainers input')
	}
	return unsafe { &UpdateMaintainersInput(voidptr(address.u64())) }
}

fn update_maintainers_result_value(result UpdateMaintainersResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'bundler_groups': brew_runtime.string_array_value(result.bundler_groups)
		'lead_sentence': brew_runtime.string_value(result.lead_sentence)
		'maintainers_sentence': brew_runtime.string_value(result.maintainers_sentence)
		'readme_path': brew_runtime.string_value(result.readme_path)
		'diff_command': brew_runtime.string_array_value(result.diff_command)
		'regenerate_manpages': brew_runtime.bool_value(result.regenerate_manpages)
		'manpages_quiet': brew_runtime.bool_value(result.manpages_quiet)
		'stdout': brew_runtime.string_value(result.stdout)
		'stderr': brew_runtime.string_value(result.stderr)
		'failed': brew_runtime.bool_value(result.failed)
	})
}

// Ruby method `run` at line 25.
pub fn ruby_update_maintainers_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return update_maintainers_result_value(run_update_maintainers(update_maintainers_input_from_value(args[0]).options) or {
		return brew_runtime.object_value('Error', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "utils/github"
// 6: require "manpages"
// 7: require "system_command"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class UpdateMaintainers < AbstractCommand
// 12:       include SystemCommand::Mixin
// 13:
// 14:       cmd_args do
// 15:         description <<~EOS
// 16:           Update the list of maintainers in the `Homebrew/brew` README.
// 17:         EOS
// 18:
// 19:         named_args :none
// 20:
// 21:         hide_from_man_page!
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         # Needed for Manpages.regenerate_man_pages below
// 27:         Homebrew.install_bundler_gems!(groups: ["man"])
// 28:
// 29:         lead_maintainers = GitHub.members_by_team("Homebrew", "lead-maintainers")
// 30:         maintainers = GitHub.members_by_team("Homebrew", "maintainers")
// 31:                             .reject { |login, _| lead_maintainers.key?(login) }
// 32:         members = { lead_maintainers:, maintainers: }
// 33:
// 34:         sentences = {}
// 35:         members.each do |group, hash|
// 36:           hash.each { |login, name| hash[login] = "[#{name}](https://github.com/#{login})" }
// 37:           sentences[group] = hash.values.sort_by { |s| s.unicode_normalize(:nfd).gsub(/\P{L}+/, "") }.to_sentence
// 38:         end
// 39:
// 40:         readme = HOMEBREW_REPOSITORY/"README.md"
// 41:
// 42:         content = readme.read
// 43:         content.gsub!(/(Homebrew's \[Lead Maintainers.* (are|is)) .*\./,
// 44:                       "\\1 #{sentences[:lead_maintainers]}.")
// 45:         content.gsub!(/(Homebrew's other Maintainers (are|is)) .*\./,
// 46:                       "\\1 #{sentences[:maintainers]}.")
// 47:
// 48:         File.write(readme, content)
// 49:
// 50:         diff = system_command "git", args: ["-C", HOMEBREW_REPOSITORY, "diff", "--exit-code", "README.md"]
// 51:         if diff.status.success?
// 52:           ofail "No changes to list of maintainers."
// 53:         else
// 54:           Manpages.regenerate_man_pages(quiet: true)
// 55:           puts "List of maintainers updated in the README and the generated man pages."
// 56:         end
// 57:       end
// 58:     end
// 59:   end
// 60: end
