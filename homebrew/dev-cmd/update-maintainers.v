module dev_cmd

import ruby
import encoding.utf8
import os

// Translated from Homebrew/brew `dev-cmd/update-maintainers.rb`.

pub struct UpdateMaintainersOptions {
pub:
	repository       string
	lead_maintainers map[string]string
	maintainers      map[string]string
	diff_success     bool
}

pub struct UpdateMaintainersResult {
pub:
	bundler_groups       []string
	lead_sentence        string
	maintainers_sentence string
	readme_path          string
	diff_command         []string
	regenerate_manpages  bool
	manpages_quiet       bool
	stdout               string
	stderr               string
	failed               bool
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

pub fn update_maintainers_input_boundary(input &UpdateMaintainersInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::UpdateMaintainers::Input', '', {
		'update_maintainers_input_address': u64(voidptr(input)).str()
	})
}

fn update_maintainers_input_from_value(value ruby.Value) &UpdateMaintainersInput {
	address := value.attributes['update_maintainers_input_address'] or {
		panic('invalid UpdateMaintainers input')
	}
	return unsafe { &UpdateMaintainersInput(voidptr(address.u64())) }
}

fn update_maintainers_result_value(result UpdateMaintainersResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups':       ruby.string_array_value(result.bundler_groups)
		'lead_sentence':        ruby.string_value(result.lead_sentence)
		'maintainers_sentence': ruby.string_value(result.maintainers_sentence)
		'readme_path':          ruby.string_value(result.readme_path)
		'diff_command':         ruby.string_array_value(result.diff_command)
		'regenerate_manpages':  ruby.bool_value(result.regenerate_manpages)
		'manpages_quiet':       ruby.bool_value(result.manpages_quiet)
		'stdout':               ruby.string_value(result.stdout)
		'stderr':               ruby.string_value(result.stderr)
		'failed':               ruby.bool_value(result.failed)
	})
}
