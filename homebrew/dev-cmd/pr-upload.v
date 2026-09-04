module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/pr-upload.rb`.

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
