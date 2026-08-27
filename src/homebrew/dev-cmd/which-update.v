module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/which-update.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 33.
pub fn ruby_which_update_l33_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `update_and_save!(source:, bottle_json_dir: nil, removed_formulae_file: nil, pull_request: nil,` at line 56.
pub fn ruby_which_update_l56_d2_update_and_save(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update_and_save!', ...args)
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
