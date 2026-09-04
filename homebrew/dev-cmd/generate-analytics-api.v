module dev_cmd

import ruby
import os
import time

// Translated from Homebrew/brew `dev-cmd/generate-analytics-api.rb`.

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
