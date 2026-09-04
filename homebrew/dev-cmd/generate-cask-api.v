module dev_cmd

import ruby
import os
import x.json2

// Translated from Homebrew/brew `dev-cmd/generate-cask-api.rb`.
// The original source is retained below until every stub has a typed V body.

const cask_json_template = '---\nlayout: cask_json\n---\n{{ content }}\n'

pub struct GenerateCaskApiCask {
pub:
	token              string
	path               string
	source             string
	pretty_json        string
	serialized_by_tag  map[string]string
	load_error         string
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
	directories       []string
	writes            map[string]string
	no_api            bool
	generating_hash   bool
	simulated_os      string
	simulated_arch    string
	processed_casks   []string
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
	renames := if options.cask_renames_json.trim_space().len > 0 { options.cask_renames_json } else { '{}' }
	migrations := if options.tap_migrations_json.trim_space().len > 0 { options.tap_migrations_json } else { '{}' }
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
		'directories': ruby.string_array_value(result.directories)
		'writes': ruby.map_value(writes)
		'no_api': ruby.bool_value(result.no_api)
		'generating_hash': ruby.bool_value(result.generating_hash)
		'simulated_os': ruby.object_value('Symbol', result.simulated_os)
		'simulated_arch': ruby.object_value('Symbol', result.simulated_arch)
		'processed_casks': ruby.string_array_value(result.processed_casks)
	})
}

// Ruby method `run` at line 33.
pub fn ruby_generate_cask_api_l33_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return generate_cask_api_result_value(run_generate_cask_api(generate_cask_api_input_from_value(args[0]).options) or {
		return ruby.object_value('TapUnavailableError', err.msg())
	})
}

// Ruby method `html_template(title)` at line 97.
pub fn ruby_generate_cask_api_l97_d2_html_template(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'title is required')
	}
	return ruby.string_value(generate_cask_html_template(args[0].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cask/cask"
// 6: require "fileutils"
// 7: require "formula"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class GenerateCaskApi < AbstractCommand
// 12:       CASK_JSON_TEMPLATE = <<~EOS
// 13:         ---
// 14:         layout: cask_json
// 15:         ---
// 16:         {{ content }}
// 17:       EOS
// 18:
// 19:       cmd_args do
// 20:         description <<~EOS
// 21:           Generate `homebrew/cask` API data files for <#{HOMEBREW_API_WWW}>.
// 22:           The generated files are written to the current directory.
// 23:         EOS
// 24:         switch "-n", "--dry-run",
// 25:                description: "Generate API data without writing it to files."
// 26:
// 27:         named_args :none
// 28:
// 29:         hide_from_man_page!
// 30:       end
// 31:
// 32:       sig { override.void }
// 33:       def run
// 34:         tap = CoreCaskTap.instance
// 35:         raise TapUnavailableError, tap.name unless tap.installed?
// 36:
// 37:         unless args.dry_run?
// 38:           directories = ["_data/cask", "api/cask", "api/cask-source", "cask", "api/internal"].freeze
// 39:           FileUtils.rm_rf directories
// 40:           FileUtils.mkdir_p directories
// 41:         end
// 42:
// 43:         Homebrew.with_no_api_env do
// 44:           tap_migrations_json = JSON.dump(tap.tap_migrations)
// 45:           File.write("api/cask_tap_migrations.json", tap_migrations_json) unless args.dry_run?
// 46:
// 47:           Cask::Cask.generating_hash!
// 48:
// 49:           all_casks = {}
// 50:           latest_macos = MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 51:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 52:             tap.cask_files.each do |path|
// 53:               cask = Cask::CaskLoader.load(path)
// 54:               name = cask.token
// 55:               all_casks[name] = cask.to_hash_with_variations
// 56:               json = JSON.pretty_generate(all_casks[name])
// 57:               cask_source = path.read
// 58:               html_template_name = html_template(name)
// 59:
// 60:               unless args.dry_run?
// 61:                 File.write("_data/cask/#{name.tr("+", "_")}.json", "#{json}\n")
// 62:                 File.write("api/cask/#{name}.json", CASK_JSON_TEMPLATE)
// 63:                 File.write("api/cask-source/#{name}.rb", cask_source)
// 64:                 File.write("cask/#{name}.html", html_template_name)
// 65:               end
// 66:             rescue
// 67:               onoe "Error while generating data for cask '#{path.stem}'."
// 68:               raise
// 69:             end
// 70:           end
// 71:
// 72:           canonical_json = JSON.pretty_generate(tap.cask_renames)
// 73:           File.write("_data/cask_canonical.json", "#{canonical_json}\n") unless args.dry_run?
// 74:
// 75:           OnSystem::VALID_OS_ARCH_TAGS.each do |bottle_tag|
// 76:             casks = all_casks.to_h do |token, hash|
// 77:               hash = Homebrew::API::Cask::CaskStructGenerator.generate_cask_struct_hash(hash, bottle_tag:)
// 78:                                                              .serialize
// 79:               [token, hash]
// 80:             end
// 81:
// 82:             json_contents = {
// 83:               casks:,
// 84:               renames:        tap.cask_renames,
// 85:               tap_git_head:   tap.git_head,
// 86:               tap_migrations: tap.tap_migrations,
// 87:             }
// 88:
// 89:             File.write("api/internal/cask.#{bottle_tag}.json", JSON.generate(json_contents)) unless args.dry_run?
// 90:           end
// 91:         end
// 92:       end
// 93:
// 94:       private
// 95:
// 96:       sig { params(title: String).returns(String) }
// 97:       def html_template(title)
// 98:         <<~EOS
// 99:           ---
// 100:           title: '#{title}'
// 101:           layout: cask
// 102:           ---
// 103:           {{ content }}
// 104:         EOS
// 105:       end
// 106:     end
// 107:   end
// 108: end
