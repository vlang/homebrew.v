module dev_cmd

import ruby
import os
import x.json2

// Translated from Homebrew/brew `dev-cmd/generate-cask-api.rb`.

const cask_json_template = '---\nlayout: cask_json\n---\n{{ content }}\n'

pub struct GenerateCaskApiCask {
pub:
	token             string
	path              string
	source            string
	pretty_json       string
	serialized_by_tag map[string]string
	load_error        string
}

pub struct GenerateCaskApiOptions {
pub:
	output_directory    string
	dry_run             bool
	tap_name            string
	tap_installed       bool
	tap_migrations_json string
	cask_renames_json   string
	tap_git_head        string
	latest_macos        string
	casks               []GenerateCaskApiCask
	bottle_tags         []string
}

pub struct GenerateCaskApiResult {
pub:
	directories     []string
	writes          map[string]string
	no_api          bool
	generating_hash bool
	simulated_os    string
	simulated_arch  string
	processed_casks []string
}

pub fn generate_cask_html_template(title string) string {
	return "---\ntitle: '${title}'\nlayout: cask\n---\n{{ content }}\n"
}

fn generate_cask_api_internal_json(options GenerateCaskApiOptions, tag string) string {
	mut entries := []string{}
	for cask in options.casks {
		serialized := cask.serialized_by_tag[tag] or { '{}' }
		entries << '${json2.encode(cask.token)}:${serialized}'
	}
	renames := if options.cask_renames_json.trim_space().len > 0 {
		options.cask_renames_json
	} else {
		'{}'
	}
	migrations := if options.tap_migrations_json.trim_space().len > 0 {
		options.tap_migrations_json
	} else {
		'{}'
	}
	return '{"casks":{${entries.join(',')}},"renames":${renames},"tap_git_head":${json2.encode(options.tap_git_head)},"tap_migrations":${migrations}}'
}

pub fn run_generate_cask_api(options GenerateCaskApiOptions) !GenerateCaskApiResult {
	if !options.tap_installed {
		return error(options.tap_name)
	}
	directories := ['_data/cask', 'api/cask', 'api/cask-source', 'cask', 'api/internal']
	if !options.dry_run {
		for directory in directories {
			path := os.join_path(options.output_directory, directory)
			if os.exists(path) {
				os.rmdir_all(path)!
			}
			os.mkdir_all(path)!
		}
	}
	mut writes := map[string]string{}
	if !options.dry_run {
		writes[os.join_path(options.output_directory, 'api/cask_tap_migrations.json')] = options.tap_migrations_json
	}
	mut processed := []string{}
	for cask in options.casks {
		if cask.load_error.len > 0 {
			stem := os.file_name(cask.path).trim_string_right('.rb')
			return error("Error while generating data for cask '${stem}'.\n${cask.load_error}")
		}
		processed << cask.token
		if !options.dry_run {
			writes[os.join_path(options.output_directory, '_data/cask', '${cask.token.replace('+', '_')}.json')] = '${cask.pretty_json}\n'
			writes[os.join_path(options.output_directory, 'api/cask', '${cask.token}.json')] = cask_json_template
			writes[os.join_path(options.output_directory, 'api/cask-source', '${cask.token}.rb')] = cask.source
			writes[os.join_path(options.output_directory, 'cask', '${cask.token}.html')] = generate_cask_html_template(cask.token)
		}
	}
	if !options.dry_run {
		writes[os.join_path(options.output_directory, '_data/cask_canonical.json')] = '${options.cask_renames_json}\n'
		for tag in options.bottle_tags {
			writes[os.join_path(options.output_directory, 'api/internal', 'cask.${tag}.json')] = generate_cask_api_internal_json(options, tag)
		}
		for path, contents in writes {
			os.mkdir_all(os.dir(path))!
			os.write_file(path, contents)!
		}
	}
	return GenerateCaskApiResult{
		directories: directories
		writes: writes
		no_api: true
		generating_hash: true
		simulated_os: options.latest_macos
		simulated_arch: 'arm'
		processed_casks: processed
	}
}

@[heap]
pub struct GenerateCaskApiInput {
pub:
	options GenerateCaskApiOptions
}

pub fn generate_cask_api_input_boundary(input &GenerateCaskApiInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateCaskApi::Input', '', {
		'generate_cask_api_input_address': u64(voidptr(input)).str()
	})
}

fn generate_cask_api_input_from_value(value ruby.Value) &GenerateCaskApiInput {
	address := value.attributes['generate_cask_api_input_address'] or {
		panic('invalid GenerateCaskApi input')
	}
	return unsafe { &GenerateCaskApiInput(voidptr(address.u64())) }
}

fn generate_cask_api_result_value(result GenerateCaskApiResult) ruby.Value {
	mut writes := map[string]ruby.Value{}
	for path, contents in result.writes {
		writes[path] = ruby.string_value(contents)
	}
	return ruby.map_value({
		'directories':     ruby.string_array_value(result.directories)
		'writes':          ruby.map_value(writes)
		'no_api':          ruby.bool_value(result.no_api)
		'generating_hash': ruby.bool_value(result.generating_hash)
		'simulated_os':    ruby.object_value('Symbol', result.simulated_os)
		'simulated_arch':  ruby.object_value('Symbol', result.simulated_arch)
		'processed_casks': ruby.string_array_value(result.processed_casks)
	})
}
