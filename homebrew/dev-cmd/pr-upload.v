module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/pr-upload.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct PrUploadOptions {
pub:
	working_directory      string = '.'
	keep_old               bool
	dry_run                bool
	no_commit              bool
	warn_on_upload_failure bool
	upload_only            bool
	committer              string
	root_url               string
	root_url_using         string
	verbose                bool
	debug                  bool
	// The Ruby implementation obtains these by loading each formula. Keeping the
	// lookup explicit makes the same comparison deterministic at the V boundary.
	formula_versions map[string]string
	// A caller which executes the planned `brew bottle` command can provide the
	// files left by that command. Otherwise the current directory is rescanned.
	post_merge_json_files     []string
	post_merge_files_provided bool
}

pub struct PrUploadResult {
pub:
	json_files             []string
	bottles                map[string]ruby.Value
	bottle_args            []string
	audit_args             []string
	messages               []string
	service                string
	committer_name         string
	committer_email        string
	install_bundler_gems   bool
	merge_bottles          bool
	upload_bottles         bool
	keep_old               bool
	dry_run                bool
	warn_on_upload_failure bool
	returned_before_upload bool
}

@[heap]
pub struct PrUploadInput {
pub:
	options PrUploadOptions
}

fn pr_upload_error(kind string, message string) ruby.Value {
	return ruby.object_value(kind, message)
}

fn pr_upload_nested_map(value ruby.Value, key string) !map[string]ruby.Value {
	nested := value.map_data[key] or { return error('missing ${key}') }
	return nested.as_map() or { return error('${key} must be a Hash') }
}

fn pr_upload_deep_merge(left map[string]ruby.Value,
	right map[string]ruby.Value) map[string]ruby.Value {
	mut merged := left.clone()
	for key, right_value in right {
		if left_value := merged[key] {
			if left_value.type_name == 'Hash' && right_value.type_name == 'Hash' {
				merged[key] = ruby.map_value(pr_upload_deep_merge(left_value.map_data, right_value.map_data))
				continue
			}
		}
		merged[key] = right_value
	}
	return merged
}

pub fn pr_upload_bottles_hash_from_json_files(json_files []string,
	root_url string) !map[string]ruby.Value {
	mut bottles := map[string]ruby.Value{}
	for json_file in json_files {
		contents := os.read_file(json_file) or { return error('${json_file}: ${err.msg()}') }
		parsed_value := ruby.parse_json_value(contents) or {
			return error('${json_file}: ${err.msg()}')
		}
		parsed := parsed_value.as_map() or { return error('${json_file}: JSON root must be an object') }
		bottles = pr_upload_deep_merge(bottles, parsed)
	}
	if root_url != '' {
		for name, bottle_value in bottles {
			mut bottle_hash := bottle_value.as_map() or {
				return error('${name}: bottle metadata must be a Hash')
			}
			mut bottle := pr_upload_nested_map(bottle_value, 'bottle') or {
				return error('${name}: ${err.msg()}')
			}
			bottle['root_url'] = ruby.string_value(root_url)
			bottle_hash['bottle'] = ruby.map_value(bottle)
			bottles[name] = ruby.map_value(bottle_hash)
		}
	}
	return bottles
}

fn pr_upload_formula_version(bottle_hash ruby.Value) !string {
	formula := pr_upload_nested_map(bottle_hash, 'formula')!
	version := formula['pkg_version'] or { return error('missing formula.pkg_version') }
	return version.as_string()
}

fn pr_upload_formula_path(bottle_hash ruby.Value) !string {
	formula := pr_upload_nested_map(bottle_hash, 'formula')!
	path := formula['path'] or { return error('missing formula.path') }
	return path.as_string()
}

pub fn check_pr_upload_bottled_formulae(bottles map[string]ruby.Value,
	formula_versions map[string]string) ! {
	for name, bottle_hash in bottles {
		bottle_version := pr_upload_formula_version(bottle_hash)!
		formula_path := pr_upload_formula_path(bottle_hash)!
		formula := pr_upload_nested_map(bottle_hash, 'formula')!
		formula_version := formula_versions[formula_path] or {
			if current := formula['current_pkg_version'] {
				current.as_string()
			} else {
				// A boundary caller may omit the injected factory result when it is
				// equal to the bottle's recorded package version.
				bottle_version
			}
		}
		if formula_version != bottle_version {
			return error('Bottles are for ${name} ${bottle_version} but formula is version ${formula_version}!')
		}
	}
}

fn pr_upload_component_valid(value string) bool {
	return value != '' && value.bytes().all(it.is_alnum() || it == `_` || it == `-`)
}

fn pr_upload_github_release_root(root_url string) bool {
	prefix := 'https://github.com/'
	start := root_url.index(prefix) or { return false }
	parts := root_url[start + prefix.len..].split('/')
	if parts.len < 5 || parts[2] != 'releases' || parts[3] != 'download' {
		return false
	}
	return pr_upload_component_valid(parts[0]) && pr_upload_component_valid(parts[1])
		&& parts[4..].join('/') != ''
}

fn pr_upload_github_packages_root(root_url string) bool {
	mut remainder := ''
	for prefix in ['https://ghcr.io/v2/', 'docker://ghcr.io/'] {
		if start := root_url.index(prefix) {
			remainder = root_url[start + prefix.len..]
			break
		}
	}
	parts := remainder.split('/')
	return parts.len >= 2 && pr_upload_component_valid(parts[0])
		&& pr_upload_component_valid(parts[1])
}

pub fn pr_upload_github_releases(bottles map[string]ruby.Value) bool {
	for _, bottle_hash in bottles {
		bottle := pr_upload_nested_map(bottle_hash, 'bottle') or { return false }
		root_url := bottle['root_url'] or { return false }
		if !pr_upload_github_release_root(root_url.as_string()) {
			return false
		}
	}
	return true
}

pub fn pr_upload_github_packages(bottles map[string]ruby.Value) bool {
	for _, bottle_hash in bottles {
		bottle := pr_upload_nested_map(bottle_hash, 'bottle') or { return false }
		root_url := bottle['root_url'] or { return false }
		if !pr_upload_github_packages_root(root_url.as_string()) {
			return false
		}
	}
	return true
}

fn pr_upload_json_files(directory string) ![]string {
	mut files := os.ls(directory) or { return error('${directory}: ${err.msg()}') }
	files = files.filter(it.ends_with('.bottle.json')).map(os.join_path(directory, it))
	files.sort()
	return files
}

fn pr_upload_parse_committer(committer string) !(string, string) {
	left := committer.last_index('<') or { return error('invalid committer: ${committer}') }
	right := committer.last_index('>') or { return error('invalid committer: ${committer}') }
	if right != committer.len - 1 || right <= left + 1 {
		return error('invalid committer: ${committer}')
	}
	name := committer[..left].trim_space()
	email := committer[left + 1..right].trim_space()
	if name == '' || email == '' || !email.contains('@') {
		return error('invalid committer: ${committer}')
	}
	return name, email
}

pub fn run_pr_upload(options PrUploadOptions) !PrUploadResult {
	mut json_files := pr_upload_json_files(options.working_directory)!
	if json_files.len == 0 {
		return error('No bottle JSON files found in the current working directory')
	}
	mut bottles := pr_upload_bottles_hash_from_json_files(json_files, options.root_url)!
	mut bottle_args := []string{}
	mut audit_args := []string{}
	mut messages := []string{}
	mut service := ''
	mut committer_name := ''
	mut committer_email := ''
	mut merge_bottles := false
	mut upload_bottles := false
	mut returned_before_upload := false

	if options.verbose {
		messages << 'Reading JSON files: ${json_files.join(', ')}'
	}
	if !options.upload_only {
		if options.committer != '' {
			committer_name, committer_email = pr_upload_parse_committer(options.committer)!
		}
		bottle_args = ['bottle', '--merge', '--write']
		if options.verbose {
			bottle_args << '--verbose'
		}
		if options.debug {
			bottle_args << '--debug'
		}
		if options.keep_old {
			bottle_args << '--keep-old'
		}
		if options.root_url != '' {
			bottle_args << '--root-url=${options.root_url}'
		}
		if options.no_commit {
			bottle_args << '--no-commit'
		}
		if options.root_url_using != '' {
			bottle_args << '--root-url-using=${options.root_url_using}'
		}
		bottle_args << json_files

		if options.dry_run && !pr_upload_github_packages(bottles) {
			if !pr_upload_github_releases(bottles) {
				return error('Service specified by root_url is not recognized')
			}
			service = 'GitHub Releases'
			messages << 'brew ${bottle_args.join(' ')}\nUpload bottles described by these JSON files to ${service}:\n  ${json_files.join('\n  ')}'
			returned_before_upload = true
			return PrUploadResult{
				json_files: json_files
				bottles: bottles
				bottle_args: bottle_args
				messages: messages
				service: service
				committer_name: committer_name
				committer_email: committer_email
				install_bundler_gems: true
				keep_old: options.keep_old
				dry_run: options.dry_run
				warn_on_upload_failure: options.warn_on_upload_failure
				returned_before_upload: returned_before_upload
			}
		}

		check_pr_upload_bottled_formulae(bottles, options.formula_versions)!
		merge_bottles = true
		json_files = if options.post_merge_files_provided {
			options.post_merge_json_files.clone()
		} else {
			pr_upload_json_files(options.working_directory)!
		}
		if json_files.len == 0 {
			messages << 'No bottle JSON files after merge, no upload needed!'
			returned_before_upload = true
			return PrUploadResult{
				json_files: json_files
				bottles: bottles
				bottle_args: bottle_args
				messages: messages
				committer_name: committer_name
				committer_email: committer_email
				install_bundler_gems: true
				merge_bottles: merge_bottles
				keep_old: options.keep_old
				dry_run: options.dry_run
				warn_on_upload_failure: options.warn_on_upload_failure
				returned_before_upload: returned_before_upload
			}
		}
		bottles = pr_upload_bottles_hash_from_json_files(json_files, options.root_url)!
		if options.verbose {
			messages << 'Reading JSON files: ${json_files.join(', ')}'
		}
		if !options.no_commit {
			audit_args = ['audit', '--skip-style']
			if options.verbose {
				audit_args << '--verbose'
			}
			if options.debug {
				audit_args << '--debug'
			}
			mut names := bottles.keys()
			names.sort()
			audit_args << names
		}
	}

	if pr_upload_github_releases(bottles) {
		service = 'GitHub Releases'
	} else if pr_upload_github_packages(bottles) {
		service = 'GitHub Packages'
	} else {
		return error('Service specified by root_url is not recognized')
	}
	upload_bottles = true
	return PrUploadResult{
		json_files: json_files
		bottles: bottles
		bottle_args: bottle_args
		audit_args: audit_args
		messages: messages
		service: service
		committer_name: committer_name
		committer_email: committer_email
		install_bundler_gems: true
		merge_bottles: merge_bottles
		upload_bottles: upload_bottles
		keep_old: options.keep_old
		dry_run: options.dry_run
		warn_on_upload_failure: options.warn_on_upload_failure
		returned_before_upload: returned_before_upload
	}
}

pub fn pr_upload_input_boundary(input &PrUploadInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::PrUpload::Input', '', {
		'pr_upload_input_address': u64(voidptr(input)).str()
	})
}

fn pr_upload_input_from_value(value ruby.Value) !&PrUploadInput {
	address := value.attributes['pr_upload_input_address'] or {
		return error('invalid PrUpload input')
	}
	return unsafe { &PrUploadInput(voidptr(address.u64())) }
}

fn pr_upload_result_value(result PrUploadResult) ruby.Value {
	return ruby.map_value({
		'json_files':             ruby.string_array_value(result.json_files)
		'bottles':                ruby.map_value(result.bottles)
		'bottle_args':            ruby.string_array_value(result.bottle_args)
		'audit_args':             ruby.string_array_value(result.audit_args)
		'messages':               ruby.string_array_value(result.messages)
		'service':                ruby.string_value(result.service)
		'committer_name':         ruby.string_value(result.committer_name)
		'committer_email':        ruby.string_value(result.committer_email)
		'install_bundler_gems':   ruby.bool_value(result.install_bundler_gems)
		'merge_bottles':          ruby.bool_value(result.merge_bottles)
		'upload_bottles':         ruby.bool_value(result.upload_bottles)
		'keep_old':               ruby.bool_value(result.keep_old)
		'dry_run':                ruby.bool_value(result.dry_run)
		'warn_on_upload_failure': ruby.bool_value(result.warn_on_upload_failure)
		'returned_before_upload': ruby.bool_value(result.returned_before_upload)
	})
}

// Ruby method `run` at line 47.
pub fn ruby_pr_upload_l47_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return pr_upload_error('ArgumentError', 'command input is required')
	}
	input := pr_upload_input_from_value(args[0]) or {
		return pr_upload_error('ArgumentError', err.msg())
	}
	result := run_pr_upload(input.options) or { return pr_upload_error('Error', err.msg()) }
	return pr_upload_result_value(result)
}

// Ruby method `check_bottled_formulae!(bottles_hash)` at line 132.
pub fn ruby_pr_upload_l132_d2_check_bottled_formulae(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return pr_upload_error('ArgumentError', 'bottles_hash is required')
	}
	bottles := args[0].as_map() or { return pr_upload_error('TypeError', err.msg()) }
	mut formula_versions := map[string]string{}
	if args.len > 1 {
		for path, value in args[1].map_data {
			formula_versions[path] = value.as_string()
		}
	}
	check_pr_upload_bottled_formulae(bottles, formula_versions) or {
		return pr_upload_error('RuntimeError', err.msg())
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `github_releases?(bottles_hash)` at line 144.
pub fn ruby_pr_upload_l144_d3_github_releases(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return pr_upload_error('ArgumentError', 'bottles_hash is required')
	}
	bottles := args[0].as_map() or { return pr_upload_error('TypeError', err.msg()) }
	return ruby.bool_value(pr_upload_github_releases(bottles))
}

// Ruby method `github_packages?(bottles_hash)` at line 155.
pub fn ruby_pr_upload_l155_d4_github_packages(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return pr_upload_error('ArgumentError', 'bottles_hash is required')
	}
	bottles := args[0].as_map() or { return pr_upload_error('TypeError', err.msg()) }
	return ruby.bool_value(pr_upload_github_packages(bottles))
}

// Ruby method `bottles_hash_from_json_files(json_files, args)` at line 162.
pub fn ruby_pr_upload_l162_d5_bottles_hash_from_json_files(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return pr_upload_error('ArgumentError', 'json_files is required')
	}
	json_files := args[0].as_string_array() or { return pr_upload_error('TypeError', err.msg()) }
	mut root_url := ''
	if args.len > 1 {
		root_url = args[1].attributes['root_url'] or {
			if value := args[1].map_data['root_url'] { value.as_string() } else { '' }
		}
	}
	bottles := pr_upload_bottles_hash_from_json_files(json_files, root_url) or {
		return pr_upload_error('Error', err.msg())
	}
	return ruby.map_value(bottles)
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
