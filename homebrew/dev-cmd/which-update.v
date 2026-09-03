module dev_cmd

import brew_runtime
import homebrew
import homebrew.utils
import os

// Translated from Homebrew/brew `dev-cmd/which-update.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub fn which_update_input_boundary(input &WhichUpdateInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::WhichUpdate::Input', '', {
		'which_update_input_address': u64(voidptr(input)).str()
	})
}

fn which_update_input_from_value(value brew_runtime.Value) &WhichUpdateInput {
	address := value.attributes['which_update_input_address'] or {
		panic('invalid WhichUpdate command input')
	}
	return unsafe { &WhichUpdateInput(voidptr(address.u64())) }
}

fn which_update_result_value(result WhichUpdateResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'source':                brew_runtime.string_value(result.source)
		'updated':               brew_runtime.bool_value(result.updated)
		'repository':            brew_runtime.string_value(result.repository)
		'pull_request_url':      brew_runtime.string_value(result.pull_request_url)
		'removed_formulae':      brew_runtime.string_array_value(result.removed_formulae)
		'removed_entries':       brew_runtime.string_array_value(result.removed_entries)
		'warnings':              brew_runtime.string_array_value(result.warnings)
		'summary_written':       brew_runtime.bool_value(result.summary_written)
		'github_output_written': brew_runtime.bool_value(result.github_output_written)
	})
}

// Ruby method `run` at line 33.
pub fn ruby_which_update_l33_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	options := which_update_input_from_value(args[0]).options
	result := run_which_update(options) or {
		error_type := if options.repository != '' && options.pull_request == '' {
			'Homebrew::CLI::OptionConstraintError'
		} else if err.msg().starts_with('`--repository`') {
			'UsageError'
		} else {
			'Error'
		}
		return brew_runtime.object_value(error_type, err.msg())
	}
	return which_update_result_value(result)
}

// Ruby method `update_and_save!(source:, bottle_json_dir: nil, removed_formulae_file: nil, pull_request: nil,` at line 56.
pub fn ruby_which_update_l56_d2_update_and_save(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	result := which_update_and_save(which_update_input_from_value(args[0]).options) or {
		error_type := if err.msg().starts_with('`--repository`') { 'UsageError' } else { 'Error' }
		return brew_runtime.object_value(error_type, err.msg())
	}
	return brew_runtime.bool_value(result.updated)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # License: MIT
// 5: # The license text can be found in Library/Homebrew/command-not-found/LICENSE
// 6:
// 7: require "abstract_command"
// 8: require "executables_db"
// 9: require "utils/github"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class WhichUpdate < AbstractCommand
// 14:       cmd_args do
// 15:         description <<~EOS
// 16:           Database update for `brew which-formula`.
// 17:         EOS
// 18:         flag   "--bottle-json-dir=",
// 19:                description: "Use generated bottle JSON files in the given directory to update formula entries."
// 20:         flag   "--removed-formulae-file=",
// 21:                description: "Remove database entries for formulae listed in the given file."
// 22:         flag   "--pull-request=",
// 23:                description: "Update entries for formula changes in the given pull request number."
// 24:         flag   "--repository=",
// 25:                depends_on:  "--pull-request",
// 26:                description: "GitHub repository for `--pull-request` (default: `$GITHUB_REPOSITORY`)."
// 27:         flag   "--summary-file=",
// 28:                description: "Output a summary of the changes to a file."
// 29:         named_args :database, number: 1
// 30:       end
// 31:
// 32:       sig { override.void }
// 33:       def run
// 34:         updated = update_and_save! source:                args.named.fetch(0),
// 35:                                    bottle_json_dir:       args.bottle_json_dir,
// 36:                                    removed_formulae_file: args.removed_formulae_file,
// 37:                                    pull_request:          args.pull_request,
// 38:                                    repository:            args.repository,
// 39:                                    summary_file:          args.summary_file
// 40:
// 41:         if (github_output = ENV["GITHUB_OUTPUT"].presence)
// 42:           File.open(github_output, "a") { |file| file.puts "updated=#{updated}" }
// 43:         end
// 44:       end
// 45:
// 46:       sig {
// 47:         params(
// 48:           source:                String,
// 49:           bottle_json_dir:       T.nilable(String),
// 50:           removed_formulae_file: T.nilable(String),
// 51:           pull_request:          T.nilable(String),
// 52:           repository:            T.nilable(String),
// 53:           summary_file:          T.nilable(String),
// 54:         ).returns(T::Boolean)
// 55:       }
// 56:       def update_and_save!(source:, bottle_json_dir: nil, removed_formulae_file: nil, pull_request: nil,
// 57:                            repository: nil, summary_file: nil)
// 58:         source_path = Pathname(source)
// 59:         original_database = source_path.exist? ? source_path.read : nil
// 60:         db = ExecutablesDB.new source
// 61:
// 62:         removed_formulae = if removed_formulae_file.blank? || !File.file?(removed_formulae_file)
// 63:           []
// 64:         else
// 65:           File.readlines(removed_formulae_file, chomp: true).filter_map { |line| line.strip.presence }
// 66:         end
// 67:
// 68:         if pull_request
// 69:           repository = repository.presence || ENV["GITHUB_REPOSITORY"].presence
// 70:           if repository.blank?
// 71:             raise UsageError,
// 72:                   "`--repository` or `$GITHUB_REPOSITORY` is required with `--pull-request`."
// 73:           end
// 74:
// 75:           owner, repo = repository.split("/", 2)
// 76:           if owner.blank? || repo.blank? || repo.include?("/")
// 77:             raise UsageError, "`--repository` must be in the form `owner/repo`."
// 78:           end
// 79:
// 80:           GitHub::API.paginate_rest(GitHub.url_to("repos", owner, repo, "pulls", pull_request, "files")) do |files|
// 81:             T.cast(files, T::Array[T::Hash[String, T.untyped]]).each do |file|
// 82:               filename = file["filename"].to_s
// 83:               next if !filename.start_with?("Formula/") || !filename.end_with?(".rb")
// 84:
// 85:               case file["status"].to_s
// 86:               when "removed"
// 87:                 removed_formulae << File.basename(filename, ".rb")
// 88:               when "renamed"
// 89:                 removed_formulae << File.basename(file["previous_filename"].to_s, ".rb")
// 90:               end
// 91:             end
// 92:           end
// 93:         end
// 94:
// 95:         db.update!(bottle_json_dir:, removed_formulae:)
// 96:         db.save!
// 97:         updated = original_database != source_path.read
// 98:
// 99:         if summary_file
// 100:           File.open(summary_file, "a") do |file|
// 101:             file.puts <<~EOS
// 102:               ## Database Update Summary
// 103:
// 104:               #{updated ? "Updated command-not-found database." : "No changes"}
// 105:             EOS
// 106:           end
// 107:         end
// 108:
// 109:         updated
// 110:       end
// 111:     end
// 112:   end
// 113: end
