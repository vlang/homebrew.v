module dev_cmd

import ruby
import homebrew
import homebrew.utils
import os

// Translated from Homebrew/brew `dev-cmd/which-update.rb`.

pub struct WhichUpdatePullFile {
pub:
	filename          string
	status            string
	previous_filename string
}

pub struct WhichUpdateOptions {
pub:
	source                  string
	bottle_json_dir         string
	removed_formulae_file   string
	pull_request            string
	repository              string
	github_repository       string
	summary_file            string
	github_output           string
	pull_request_file_pages [][]WhichUpdatePullFile
}

pub struct WhichUpdateResult {
pub:
	source                string
	updated               bool
	repository            string
	pull_request_url      string
	removed_formulae      []string
	removed_entries       []string
	warnings              []string
	summary_written       bool
	github_output_written bool
}

@[heap]
pub struct WhichUpdateInput {
pub:
	options WhichUpdateOptions
}

fn which_update_nonblank(value string) bool {
	return value.trim_space() != ''
}

fn which_update_formula_basename(path string) string {
	if path == '' {
		return ''
	}
	name := os.base(path)
	if name.ends_with('.rb') {
		return name[..name.len - 3]
	}
	return name
}

fn which_update_repository(options WhichUpdateOptions) string {
	if which_update_nonblank(options.repository) {
		return options.repository
	}
	if which_update_nonblank(options.github_repository) {
		return options.github_repository
	}
	return os.getenv('GITHUB_REPOSITORY')
}

fn which_update_github_output(options WhichUpdateOptions) string {
	if which_update_nonblank(options.github_output) {
		return options.github_output
	}
	return os.getenv('GITHUB_OUTPUT')
}

pub fn which_update_and_save(options WhichUpdateOptions) !WhichUpdateResult {
	if !which_update_nonblank(options.source) {
		return error('database source is required')
	}

	source_existed := os.exists(options.source)
	original_database := if source_existed { os.read_file(options.source)! } else { '' }
	mut database := homebrew.load_executables_db(options.source)!

	mut removed_formulae := []string{}
	if which_update_nonblank(options.removed_formulae_file)
		&& os.is_file(options.removed_formulae_file) {
		for line in os.read_lines(options.removed_formulae_file)! {
			name := line.trim_space()
			if name != '' {
				removed_formulae << name
			}
		}
	}

	mut repository := ''
	mut pull_request_url := ''
	if options.pull_request != '' {
		repository = which_update_repository(options)
		if !which_update_nonblank(repository) {
			return error('`--repository` or `\$GITHUB_REPOSITORY` is required with `--pull-request`.')
		}
		parts := repository.split('/')
		if parts.len != 2 || !which_update_nonblank(parts[0])
			|| !which_update_nonblank(parts[1]) {
			return error('`--repository` must be in the form `owner/repo`.')
		}
		pull_request_url = utils.github_url_to('repos', parts[0], parts[1], 'pulls', options.pull_request, 'files')
		for page in options.pull_request_file_pages {
			for file in page {
				if !file.filename.starts_with('Formula/') || !file.filename.ends_with('.rb') {
					continue
				}
				match file.status {
					'removed' {
						removed_formulae << which_update_formula_basename(file.filename)
					}
					'renamed' {
						removed_formulae << which_update_formula_basename(file.previous_filename)
					}
					else {}
				}
			}
		}
	}

	database.update(options.bottle_json_dir, removed_formulae)
	database.save()!
	updated := !source_existed || original_database != os.read_file(options.source)!

	mut summary_written := false
	if options.summary_file != '' {
		mut summary := os.open_append(options.summary_file)!
		summary.write_string('## Database Update Summary\n\n')!
		summary.writeln(if updated {
			'Updated command-not-found database.'
		} else {
			'No changes'
		})!
		summary.close()
		summary_written = true
	}

	return WhichUpdateResult{
		source: options.source
		updated: updated
		repository: repository
		pull_request_url: pull_request_url
		removed_formulae: removed_formulae
		removed_entries: database.removed.clone()
		warnings: database.warnings.clone()
		summary_written: summary_written
	}
}

pub fn run_which_update(options WhichUpdateOptions) !WhichUpdateResult {
	if options.repository != '' && options.pull_request == '' {
		return error('`--repository` requires `--pull-request`.')
	}
	mut result := which_update_and_save(options)!
	github_output := which_update_github_output(options)
	if which_update_nonblank(github_output) {
		mut output := os.open_append(github_output)!
		output.writeln('updated=${result.updated}')!
		output.close()
		result = WhichUpdateResult{
			...result
			github_output_written: true
		}
	}
	return result
}

pub fn which_update_input_boundary(input &WhichUpdateInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::WhichUpdate::Input', '', {
		'which_update_input_address': u64(voidptr(input)).str()
	})
}

fn which_update_input_from_value(value ruby.Value) &WhichUpdateInput {
	address := value.attributes['which_update_input_address'] or {
		panic('invalid WhichUpdate command input')
	}
	return unsafe { &WhichUpdateInput(voidptr(address.u64())) }
}

fn which_update_result_value(result WhichUpdateResult) ruby.Value {
	return ruby.map_value({
		'source':                ruby.string_value(result.source)
		'updated':               ruby.bool_value(result.updated)
		'repository':            ruby.string_value(result.repository)
		'pull_request_url':      ruby.string_value(result.pull_request_url)
		'removed_formulae':      ruby.string_array_value(result.removed_formulae)
		'removed_entries':       ruby.string_array_value(result.removed_entries)
		'warnings':              ruby.string_array_value(result.warnings)
		'summary_written':       ruby.bool_value(result.summary_written)
		'github_output_written': ruby.bool_value(result.github_output_written)
	})
}
