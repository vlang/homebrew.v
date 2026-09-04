module dev_cmd

import ruby
import os
import time

// Translated from Homebrew/brew `dev-cmd/generate-analytics-api.rb`.
// The original source is retained below until every stub has a typed V body.

pub const generate_analytics_api_categories = [
	'build-error',
	'install',
	'install-on-request',
	'core-build-error',
	'core-install',
	'core-install-on-request',
	'cask-install',
	'core-cask-install',
	'os-version',
	'homebrew-devcmdrun-developer',
	'homebrew-env-config',
	'homebrew-os-arch-ci',
	'homebrew-prefixes',
	'homebrew-versions',
	'brew-command-run',
	'brew-command-run-options',
	'brew-test-bot-test',
]
pub const generate_analytics_api_days = ['30', '90', '365']
pub const generate_analytics_api_max_retries = 3

pub struct GenerateAnalyticsApiCommand {
pub:
	argv    []string
	attempt int
}

pub struct GenerateAnalyticsApiCommandResult {
pub:
	output  string
	success bool
}

pub type GenerateAnalyticsApiCommandRunner = fn (GenerateAnalyticsApiCommand) !GenerateAnalyticsApiCommandResult

pub type GenerateAnalyticsApiSleeper = fn (seconds int)

pub struct GenerateAnalyticsApiOptions {
pub:
	output_directory string = '.'
	brew_file        string = 'brew'
	runner           GenerateAnalyticsApiCommandRunner = generate_analytics_api_command_runner
	sleeper          GenerateAnalyticsApiSleeper = generate_analytics_api_sleeper
}

pub struct GenerateAnalyticsApiFormulaResult {
pub:
	output       string
	messages     []string
	retry_delays []int
	attempts     int
}

pub struct GenerateAnalyticsApiOutput {
pub:
	formula_analytics_args []string
	days                   string
	analytics_data_path    string
	analytics_api_path     string
	category_name          string
	data_source            string
}

pub struct GenerateAnalyticsApiResult {
pub:
	outputs       []GenerateAnalyticsApiOutput
	messages      []string
	retry_delays  []int
	written_files []string
	worker_count  int
}

@[heap]
pub struct GenerateAnalyticsApiInput {
pub:
	options GenerateAnalyticsApiOptions
}

@[heap]
pub struct GenerateAnalyticsApiFormulaInput {
pub:
	arguments []string
	options   GenerateAnalyticsApiOptions
}

fn generate_analytics_api_command_runner(command GenerateAnalyticsApiCommand) !GenerateAnalyticsApiCommandResult {
	result := os.execute(command.argv.map(os.quoted_path(it)).join(' '))
	return GenerateAnalyticsApiCommandResult{
		output: result.output
		success: result.exit_code == 0
	}
}

fn generate_analytics_api_sleeper(seconds int) {
	time.sleep(seconds * time.second)
}

fn generate_analytics_api_path(root string, relative string) string {
	if root == '' || root == '.' {
		return relative
	}
	return os.join_path(root, relative)
}

fn generate_analytics_api_remove(path string) {
	if os.is_dir(path) {
		os.rmdir_all(path) or {}
	} else if os.exists(path) {
		os.rm(path) or {}
	}
}

fn generate_analytics_api_category(category string) ([]string, string, string) {
	return match category {
		'core-build-error' {
			['--all-core-formulae-json', '--build-error'], 'build-error', 'homebrew-core'
		}
		'core-install' {
			['--all-core-formulae-json', '--install'], 'install', 'homebrew-core'
		}
		'core-install-on-request' {
			['--all-core-formulae-json', '--install-on-request'], 'install-on-request', 'homebrew-core'
		}
		'core-cask-install' {
			['--all-core-formulae-json', '--cask-install'], 'cask-install', 'homebrew-cask'
		}
		else { ['--${category}'], category, '' }
	}
}

pub fn generate_analytics_json_template(category_name string, data_source string) string {
	data_source_line := if data_source == '' { '' } else { '${data_source}: true' }
	return '---\nlayout: analytics_json\ncategory: ${category_name}\n${data_source_line}\n---\n{{ content }}\n'
}

pub fn run_formula_analytics(arguments []string, options GenerateAnalyticsApiOptions) !GenerateAnalyticsApiFormulaResult {
	joined_arguments := arguments.join(' ')
	mut messages := ['brew formula-analytics ${joined_arguments}']
	mut retry_delays := []int{}
	mut retries := 0
	mut attempts := 1
	mut command_argv := [options.brew_file, 'formula-analytics']
	command_argv << arguments
	mut command_result := options.runner(GenerateAnalyticsApiCommand{
		argv: command_argv
		attempt: attempts
	})!
	for !command_result.success && retries < generate_analytics_api_max_retries {
		// Give InfluxDB some more breathing room.
		delay := [16, 64, 256][retries]
		options.sleeper(delay)
		retry_delays << delay
		retries++
		messages << 'Retrying ${joined_arguments} (${retries}/${generate_analytics_api_max_retries})...'
		attempts++
		command_result = options.runner(GenerateAnalyticsApiCommand{
			argv: command_argv
			attempt: attempts
		})!
	}
	if !command_result.success {
		return error('`brew formula-analytics ${joined_arguments}` failed: ${command_result.output}')
	}
	return GenerateAnalyticsApiFormulaResult{
		output: command_result.output
		messages: messages
		retry_delays: retry_delays
		attempts: attempts
	}
}

pub fn run_generate_analytics_api(options GenerateAnalyticsApiOptions) !GenerateAnalyticsApiResult {
	setup_argv := [options.brew_file, 'formula-analytics', '--setup']
	setup_result := options.runner(GenerateAnalyticsApiCommand{
		argv: setup_argv
		attempt: 1
	}) or { return error('Failed executing `${setup_argv.join(' ')}`: ${err.msg()}') }
	if !setup_result.success {
		return error('Failed executing `${setup_argv.join(' ')}`: ${setup_result.output}')
	}

	root := if options.output_directory == '' { '.' } else { options.output_directory }
	for directory in ['_data/analytics', 'api/analytics'] {
		path := generate_analytics_api_path(root, directory)
		generate_analytics_api_remove(path)
		os.mkdir_all(path)!
	}

	analytics_data_dir := generate_analytics_api_path(root, '_data/analytics')
	analytics_api_dir := generate_analytics_api_path(root, 'api/analytics')
	mut outputs := []GenerateAnalyticsApiOutput{}
	for category in generate_analytics_api_categories {
		mut formula_analytics_args, category_name, data_source := generate_analytics_api_category(category)
		path_suffix := if data_source == '' {
			category_name
		} else {
			os.join_path(category_name, data_source)
		}
		analytics_data_path := os.join_path(analytics_data_dir, path_suffix)
		analytics_api_path := os.join_path(analytics_api_dir, path_suffix)
		os.mkdir_all(analytics_data_path)!
		os.mkdir_all(analytics_api_path)!

		// The `--json` and `--all-core-formulae-json` flags are mutually
		// exclusive, but we need to explicitly set `--json` sometimes,
		// so only set it if we've not already set
		// `--all-core-formulae-json`.
		if '--all-core-formulae-json' !in formula_analytics_args {
			formula_analytics_args << '--json'
		}
		for days in generate_analytics_api_days {
			if days != '30' && category_name == 'build-error' && data_source != '' {
				continue
			}
			outputs << GenerateAnalyticsApiOutput{
				formula_analytics_args: formula_analytics_args.clone()
				days: days
				analytics_data_path: analytics_data_path
				analytics_api_path: analytics_api_path
				category_name: category_name
				data_source: data_source
			}
		}
	}

	mut messages := []string{}
	mut retry_delays := []int{}
	mut written_files := []string{}
	for output in outputs {
		mut arguments := output.formula_analytics_args.clone()
		arguments << '--days-ago=${output.days}'
		formula_result := run_formula_analytics(arguments, options)!
		messages << formula_result.messages
		retry_delays << formula_result.retry_delays
		data_path := os.join_path(output.analytics_data_path, '${output.days}d.json')
		api_path := os.join_path(output.analytics_api_path, '${output.days}d.json')
		os.write_file(data_path, formula_result.output)!
		os.write_file(api_path, generate_analytics_json_template(output.category_name, output.data_source))!
		written_files << data_path
		written_files << api_path
	}
	return GenerateAnalyticsApiResult{
		outputs: outputs
		messages: messages
		retry_delays: retry_delays
		written_files: written_files
		worker_count: 4
	}
}

pub fn generate_analytics_api_input_boundary(input &GenerateAnalyticsApiInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateAnalyticsApi::Input', '', {
		'generate_analytics_api_input_address': u64(voidptr(input)).str()
	})
}

fn generate_analytics_api_input_from_value(value ruby.Value) &GenerateAnalyticsApiInput {
	address := value.attributes['generate_analytics_api_input_address'] or {
		panic('invalid GenerateAnalyticsApi input')
	}
	return unsafe { &GenerateAnalyticsApiInput(voidptr(address.u64())) }
}

pub fn generate_analytics_api_formula_input_boundary(input &GenerateAnalyticsApiFormulaInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateAnalyticsApi::FormulaInput', '', {
		'generate_analytics_api_formula_input_address': u64(voidptr(input)).str()
	})
}

fn generate_analytics_api_formula_input_from_value(value ruby.Value) &GenerateAnalyticsApiFormulaInput {
	address := value.attributes['generate_analytics_api_formula_input_address'] or {
		panic('invalid GenerateAnalyticsApi formula input')
	}
	return unsafe { &GenerateAnalyticsApiFormulaInput(voidptr(address.u64())) }
}

fn generate_analytics_api_output_value(output GenerateAnalyticsApiOutput) ruby.Value {
	return ruby.map_value({
		'formula_analytics_args': ruby.string_array_value(output.formula_analytics_args)
		'days':                   ruby.string_value(output.days)
		'analytics_data_path':    ruby.string_value(output.analytics_data_path)
		'analytics_api_path':     ruby.string_value(output.analytics_api_path)
		'category_name':          ruby.string_value(output.category_name)
		'data_source':            ruby.string_value(output.data_source)
	})
}

fn generate_analytics_api_result_value(result GenerateAnalyticsApiResult) ruby.Value {
	return ruby.map_value({
		'outputs':       ruby.array_value(result.outputs.map(generate_analytics_api_output_value(it)))
		'messages':      ruby.string_array_value(result.messages)
		'retry_delays':  ruby.array_value(result.retry_delays.map(ruby.int_value(i64(it))))
		'written_files': ruby.string_array_value(result.written_files)
		'worker_count':  ruby.int_value(result.worker_count)
	})
}

// Ruby method `analytics_json_template(category_name, data_source: nil)` at line 35.
pub fn ruby_generate_analytics_api_l35_d1_analytics_json_template(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'category_name is required')
	}
	data_source := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.string_value(generate_analytics_json_template(args[0].as_string(), data_source))
}

// Ruby method `run_formula_analytics(*args)` at line 49.
pub fn ruby_generate_analytics_api_l49_d2_run_formula_analytics(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'formula analytics input is required')
	}
	input := generate_analytics_api_formula_input_from_value(args[0])
	result := run_formula_analytics(input.arguments, input.options) or {
		return ruby.object_value('FatalError', err.msg())
	}
	return ruby.string_value(result.output)
}

// Ruby method `run` at line 70.
pub fn ruby_generate_analytics_api_l70_d3_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	input := generate_analytics_api_input_from_value(args[0])
	result := run_generate_analytics_api(input.options) or {
		error_type := if err.msg().starts_with('Failed executing') {
			'ErrorDuringExecution'
		} else if err.msg().starts_with('`brew formula-analytics') {
			'FatalError'
		} else {
			'Error'
		}
		return ruby.object_value(error_type, err.msg())
	}
	return generate_analytics_api_result_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class GenerateAnalyticsApi < AbstractCommand
// 10:       CATEGORIES = %w[
// 11:         build-error install install-on-request
// 12:         core-build-error core-install core-install-on-request
// 13:         cask-install core-cask-install os-version
// 14:         homebrew-devcmdrun-developer homebrew-env-config homebrew-os-arch-ci
// 15:         homebrew-prefixes homebrew-versions
// 16:         brew-command-run brew-command-run-options brew-test-bot-test
// 17:       ].freeze
// 18:
// 19:       # TODO: add brew-command-run-options brew-test-bot-test to above when working.
// 20:       DAYS = %w[30 90 365].freeze
// 21:       MAX_RETRIES = 3
// 22:
// 23:       cmd_args do
// 24:         description <<~EOS
// 25:           Generates analytics API data files for <#{HOMEBREW_API_WWW}>.
// 26:           The generated files are written to the current directory.
// 27:         EOS
// 28:
// 29:         named_args :none
// 30:
// 31:         hide_from_man_page!
// 32:       end
// 33:
// 34:       sig { params(category_name: String, data_source: T.nilable(String)).returns(String) }
// 35:       def analytics_json_template(category_name, data_source: nil)
// 36:         data_source = "#{data_source}: true" if data_source
// 37:
// 38:         <<~EOS
// 39:           ---
// 40:           layout: analytics_json
// 41:           category: #{category_name}
// 42:           #{data_source}
// 43:           ---
// 44:           {{ content }}
// 45:         EOS
// 46:       end
// 47:
// 48:       sig { params(args: String).returns(String) }
// 49:       def run_formula_analytics(*args)
// 50:         puts "brew formula-analytics #{args.join(" ")}"
// 51:
// 52:         retries = 0
// 53:         result = Utils.popen_read(HOMEBREW_BREW_FILE, "formula-analytics", *args, err: :err)
// 54:
// 55:         while !$CHILD_STATUS.success? && retries < MAX_RETRIES
// 56:           # Give InfluxDB some more breathing room.
// 57:           sleep 4**(retries+2)
// 58:
// 59:           retries += 1
// 60:           puts "Retrying #{args.join(" ")} (#{retries}/#{MAX_RETRIES})..."
// 61:           result = Utils.popen_read(HOMEBREW_BREW_FILE, "formula-analytics", *args, err: :err)
// 62:         end
// 63:
// 64:         odie "`brew formula-analytics #{args.join(" ")}` failed: #{result}" unless $CHILD_STATUS.success?
// 65:
// 66:         result
// 67:       end
// 68:
// 69:       sig { override.void }
// 70:       def run
// 71:         safe_system HOMEBREW_BREW_FILE, "formula-analytics", "--setup"
// 72:
// 73:         directories = ["_data/analytics", "api/analytics"]
// 74:         FileUtils.rm_rf directories
// 75:         FileUtils.mkdir_p directories
// 76:
// 77:         root_dir = Pathname.pwd
// 78:         analytics_data_dir = root_dir/"_data/analytics"
// 79:         analytics_api_dir = root_dir/"api/analytics"
// 80:
// 81:         analytics_output_queue = Queue.new
// 82:
// 83:         CATEGORIES.each do |category|
// 84:           formula_analytics_args = []
// 85:
// 86:           case category
// 87:           when "core-build-error"
// 88:             formula_analytics_args << "--all-core-formulae-json"
// 89:             formula_analytics_args << "--build-error"
// 90:             category_name = "build-error"
// 91:             data_source = "homebrew-core"
// 92:           when "core-install"
// 93:             formula_analytics_args << "--all-core-formulae-json"
// 94:             formula_analytics_args << "--install"
// 95:             category_name = "install"
// 96:             data_source = "homebrew-core"
// 97:           when "core-install-on-request"
// 98:             formula_analytics_args << "--all-core-formulae-json"
// 99:             formula_analytics_args << "--install-on-request"
// 100:             category_name = "install-on-request"
// 101:             data_source = "homebrew-core"
// 102:           when "core-cask-install"
// 103:             formula_analytics_args << "--all-core-formulae-json"
// 104:             formula_analytics_args << "--cask-install"
// 105:             category_name = "cask-install"
// 106:             data_source = "homebrew-cask"
// 107:           else
// 108:             formula_analytics_args << "--#{category}"
// 109:             category_name = category
// 110:           end
// 111:
// 112:           path_suffix = File.join(category_name, data_source || "")
// 113:           analytics_data_path = analytics_data_dir/path_suffix
// 114:           analytics_api_path = analytics_api_dir/path_suffix
// 115:
// 116:           FileUtils.mkdir_p analytics_data_path
// 117:           FileUtils.mkdir_p analytics_api_path
// 118:
// 119:           # The `--json` and `--all-core-formulae-json` flags are mutually
// 120:           # exclusive, but we need to explicitly set `--json` sometimes,
// 121:           # so only set it if we've not already set
// 122:           # `--all-core-formulae-json`.
// 123:           formula_analytics_args << "--json" unless formula_analytics_args.include? "--all-core-formulae-json"
// 124:
// 125:           DAYS.each do |days|
// 126:             next if days != "30" && category_name == "build-error" && !data_source.nil?
// 127:
// 128:             analytics_output_queue << {
// 129:               formula_analytics_args: formula_analytics_args.dup,
// 130:               days:                   days,
// 131:               analytics_data_path:    analytics_data_path,
// 132:               analytics_api_path:     analytics_api_path,
// 133:               category_name:          category_name,
// 134:               data_source:            data_source,
// 135:             }
// 136:           end
// 137:         end
// 138:
// 139:         workers = []
// 140:         4.times do
// 141:           workers << Thread.new do
// 142:             until analytics_output_queue.empty?
// 143:               analytics_output_type = begin
// 144:                 analytics_output_queue.pop(true)
// 145:               rescue ThreadError
// 146:                 break
// 147:               end
// 148:
// 149:               days = analytics_output_type[:days]
// 150:               args = ["--days-ago=#{days}"]
// 151:
// 152:               (analytics_output_type[:analytics_data_path]/"#{days}d.json").write \
// 153:                 run_formula_analytics(*analytics_output_type[:formula_analytics_args], *args)
// 154:
// 155:               data_source = analytics_output_type[:data_source]
// 156:               (analytics_output_type[:analytics_api_path]/"#{days}d.json").write \
// 157:                 analytics_json_template(analytics_output_type[:category_name], data_source:)
// 158:             end
// 159:           end
// 160:         end
// 161:         workers.each(&:join)
// 162:       end
// 163:     end
// 164:   end
// 165: end
