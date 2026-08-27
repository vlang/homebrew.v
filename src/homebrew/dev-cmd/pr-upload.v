module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/pr-upload.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 47.
pub fn ruby_pr_upload_l47_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `check_bottled_formulae!(bottles_hash)` at line 132.
pub fn ruby_pr_upload_l132_d2_check_bottled_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_bottled_formulae!', ...args)
}

// Ruby method `github_releases?(bottles_hash)` at line 144.
pub fn ruby_pr_upload_l144_d3_github_releases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('github_releases?', ...args)
}

// Ruby method `github_packages?(bottles_hash)` at line 155.
pub fn ruby_pr_upload_l155_d4_github_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('github_packages?', ...args)
}

// Ruby method `bottles_hash_from_json_files(json_files, args)` at line 162.
pub fn ruby_pr_upload_l162_d5_bottles_hash_from_json_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottles_hash_from_json_files', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "github_packages"
// 7: require "github_releases"
// 8: require "extend/hash/deep_merge"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class PrUpload < AbstractCommand
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Apply the bottle commit and publish bottles to a host.
// 16:         EOS
// 17:         switch "--keep-old",
// 18:                description: "If the formula specifies a rebuild version, " \
// 19:                             "attempt to preserve its value in the generated DSL. " \
// 20:                             "When using GitHub Packages, this also appends the manifest to the existing list."
// 21:         switch "-n", "--dry-run",
// 22:                description: "Print what would be done rather than doing it."
// 23:         switch "--no-commit",
// 24:                description: "Do not generate a new commit before uploading."
// 25:         switch "--warn-on-upload-failure",
// 26:                description: "Warn instead of raising an error if the bottle upload fails. " \
// 27:                             "Useful for repairing bottle uploads that previously failed."
// 28:         switch "--upload-only",
// 29:                description: "Skip running `brew bottle` before uploading."
// 30:         flag   "--committer=",
// 31:                description: "Specify a committer name and email in `git`'s standard author format.",
// 32:                odeprecated: true
// 33:         flag   "--root-url=",
// 34:                description: "Use the specified <URL> as the root of the bottle's URL instead of Homebrew's default."
// 35:         flag   "--root-url-using=",
// 36:                description: "Use the specified download strategy class for downloading the bottle's URL instead of " \
// 37:                             "Homebrew's default."
// 38:
// 39:         conflicts "--upload-only", "--no-commit"
// 40:
// 41:         named_args :none
// 42:
// 43:         hide_from_man_page!
// 44:       end
// 45:
// 46:       sig { override.void }
// 47:       def run
// 48:         json_files = Dir["*.bottle.json"]
// 49:         odie "No bottle JSON files found in the current working directory" if json_files.blank?
// 50:
// 51:         Homebrew.install_bundler_gems!(groups: ["pr_upload"])
// 52:
// 53:         bottles_hash = bottles_hash_from_json_files(json_files, args)
// 54:
// 55:         unless args.upload_only?
// 56:           if (committer = args.committer)
// 57:             committer = Utils.parse_author!(committer)
// 58:             ENV["GIT_COMMITTER_NAME"] = committer[:name]
// 59:             ENV["GIT_COMMITTER_EMAIL"] = committer[:email]
// 60:           end
// 61:
// 62:           bottle_args = ["bottle", "--merge", "--write"]
// 63:           bottle_args << "--verbose" if args.verbose?
// 64:           bottle_args << "--debug" if args.debug?
// 65:           bottle_args << "--keep-old" if args.keep_old?
// 66:           bottle_args << "--root-url=#{args.root_url}" if args.root_url
// 67:           bottle_args << "--no-commit" if args.no_commit?
// 68:           bottle_args << "--root-url-using=#{args.root_url_using}" if args.root_url_using
// 69:           bottle_args += json_files
// 70:
// 71:           if args.dry_run?
// 72:             dry_run_service = if github_packages?(bottles_hash)
// 73:               # GitHub Packages has its own --dry-run handling.
// 74:               nil
// 75:             elsif github_releases?(bottles_hash)
// 76:               "GitHub Releases"
// 77:             else
// 78:               odie "Service specified by root_url is not recognized"
// 79:             end
// 80:
// 81:             if dry_run_service
// 82:               puts <<~EOS
// 83:                 brew #{bottle_args.join " "}
// 84:                 Upload bottles described by these JSON files to #{dry_run_service}:
// 85:                   #{json_files.join("\n  ")}
// 86:               EOS
// 87:               return
// 88:             end
// 89:           end
// 90:
// 91:           check_bottled_formulae!(bottles_hash)
// 92:
// 93:           safe_system HOMEBREW_BREW_FILE, *bottle_args
// 94:
// 95:           json_files = Dir["*.bottle.json"]
// 96:           if json_files.blank?
// 97:             puts "No bottle JSON files after merge, no upload needed!"
// 98:             return
// 99:           end
// 100:
// 101:           # Reload the JSON files (in case `brew bottle --merge` generated
// 102:           # `all: $SHA256` bottles)
// 103:           bottles_hash = bottles_hash_from_json_files(json_files, args)
// 104:
// 105:           # Check the bottle commits did not break `brew audit`
// 106:           unless args.no_commit?
// 107:             audit_args = ["audit", "--skip-style"]
// 108:             audit_args << "--verbose" if args.verbose?
// 109:             audit_args << "--debug" if args.debug?
// 110:             audit_args += bottles_hash.keys
// 111:             safe_system HOMEBREW_BREW_FILE, *audit_args
// 112:           end
// 113:         end
// 114:
// 115:         if github_releases?(bottles_hash)
// 116:           github_releases = GitHubReleases.new
// 117:           github_releases.upload_bottles(bottles_hash)
// 118:         elsif github_packages?(bottles_hash)
// 119:           github_packages = GitHubPackages.new
// 120:           github_packages.upload_bottles(bottles_hash,
// 121:                                          keep_old:      args.keep_old?,
// 122:                                          dry_run:       args.dry_run?,
// 123:                                          warn_on_error: args.warn_on_upload_failure?)
// 124:         else
// 125:           odie "Service specified by root_url is not recognized"
// 126:         end
// 127:       end
// 128:
// 129:       private
// 130:
// 131:       sig { params(bottles_hash: T::Hash[String, T.untyped]).void }
// 132:       def check_bottled_formulae!(bottles_hash)
// 133:         bottles_hash.each do |name, bottle_hash|
// 134:           formula_path = HOMEBREW_REPOSITORY/bottle_hash["formula"]["path"]
// 135:           formula_version = Formulary.factory(formula_path).pkg_version
// 136:           bottle_version = PkgVersion.parse bottle_hash["formula"]["pkg_version"]
// 137:           next if formula_version == bottle_version
// 138:
// 139:           odie "Bottles are for #{name} #{bottle_version} but formula is version #{formula_version}!"
// 140:         end
// 141:       end
// 142:
// 143:       sig { params(bottles_hash: T::Hash[String, T.untyped]).returns(T::Boolean) }
// 144:       def github_releases?(bottles_hash)
// 145:         @github_releases ||= T.let(bottles_hash.values.all? do |bottle_hash|
// 146:           root_url = bottle_hash["bottle"]["root_url"]
// 147:           url_match = root_url.match GitHubReleases::URL_REGEX
// 148:           _, _, _, tag = *url_match
// 149:
// 150:           tag
// 151:         end, T.nilable(T::Boolean))
// 152:       end
// 153:
// 154:       sig { params(bottles_hash: T::Hash[String, T.untyped]).returns(T::Boolean) }
// 155:       def github_packages?(bottles_hash)
// 156:         @github_packages ||= T.let(bottles_hash.values.all? do |bottle_hash|
// 157:           bottle_hash["bottle"]["root_url"].match? GitHubPackages::URL_REGEX
// 158:         end, T.nilable(T::Boolean))
// 159:       end
// 160:
// 161:       sig { params(json_files: T::Array[String], args: T.untyped).returns(T::Hash[String, T.untyped]) }
// 162:       def bottles_hash_from_json_files(json_files, args)
// 163:         puts "Reading JSON files: #{json_files.join(", ")}" if args.verbose?
// 164:
// 165:         bottles_hash = json_files.reduce({}) do |hash, json_file|
// 166:           hash.deep_merge(JSON.parse(File.read(json_file)))
// 167:         end
// 168:
// 169:         if args.root_url
// 170:           bottles_hash.each_value do |bottle_hash|
// 171:             bottle_hash["bottle"]["root_url"] = args.root_url
// 172:           end
// 173:         end
// 174:
// 175:         bottles_hash
// 176:       end
// 177:     end
// 178:   end
// 179: end
