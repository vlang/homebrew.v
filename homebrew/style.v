module homebrew

import brew_runtime
import os
import runtime
import x.json2

// Translated from Homebrew/brew `style.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum StyleOutputType {
	print
	json
}

pub struct StyleConfig {
pub:
	prefix                string
	repository            string
	library               string
	library_path          string
	original_brew_file    string
	cache                 string
	tap_directory         string
	ruby_args             []string
	rubocop_path          string
	shellcheck_path       string
	shfmt_path            string
	shfmt_executable_path string
	actionlint_path       string
	known_cops            []string
	known_departments     []string
	cpu_cores             int
	color                 bool
	ci                    bool
	github_actions        bool
	github_workspace      string
}

@[params]
pub struct StyleCheckOptions {
pub:
	fix               bool
	todo              bool
	except_cops       []string
	only_cops         []string
	has_except_cops   bool
	has_only_cops     bool
	display_cop_names bool
	reset_cache       bool
	debug             bool
	verbose           bool
	config            StyleConfig
}

@[params]
pub struct StyleShellcheckOptions {
pub:
	fix             bool
	shellcheck_path string
	config          StyleConfig
}

@[params]
pub struct StyleShfmtOptions {
pub:
	fix        bool
	shfmt_path string
	config     StyleConfig
}

@[params]
pub struct StyleActionlintOptions {
pub:
	actionlint_path string
	shellcheck_path string
	config          StyleConfig
}

pub struct StyleOffenseInput {
pub:
	severity    ?string
	message     string
	cop_name    ?string
	corrected   bool
	correctable bool
	line        int
	column      ?int
}

pub struct StyleOffense {
pub:
	severity    ?string
	message     string
	cop_name    ?string
	corrected   bool
	correctable bool
	location    SourceLocation
}

pub struct StyleOffenseFile {
pub:
	path     string
	offenses []StyleOffenseInput
}

pub struct StyleOffensesEntry {
pub:
	path     string
	offenses []StyleOffense
}

pub struct StyleOffenses {
pub:
	by_path map[string][]StyleOffense
	paths   []string
}

pub struct StyleLintResult {
pub:
	success     bool
	files       []StyleOffenseFile
	stdout      string
	stderr      string
	invocations [][]string
}

pub struct StyleCheckResult {
pub:
	success  bool
	offenses StyleOffenses
}

fn style_env_path(name string, fallback string) string {
	value := brew_runtime.environment_value(name)
	return if value == '' { fallback } else { value }
}

pub fn default_style_config() StyleConfig {
	repository := style_env_path('HOMEBREW_REPOSITORY', brew_runtime.current_directory())
	library := style_env_path('HOMEBREW_LIBRARY', os.join_path(repository, 'Library'))
	library_path := style_env_path('HOMEBREW_LIBRARY_PATH', os.join_path(library, 'Homebrew'))
	prefix := style_env_path('HOMEBREW_PREFIX', repository)
	ruby := style_env_path('HOMEBREW_RUBY_PATH', 'ruby')
	return StyleConfig{
		prefix: prefix
		repository: repository
		library: library
		library_path: library_path
		original_brew_file: style_env_path('HOMEBREW_ORIGINAL_BREW_FILE', os.join_path(repository, 'bin/brew'))
		cache: style_env_path('HOMEBREW_CACHE', os.join_path(os.temp_dir(), 'Homebrew'))
		tap_directory: style_env_path('HOMEBREW_TAP_DIRECTORY', os.join_path(library, 'Taps'))
		ruby_args: [ruby]
		rubocop_path: os.join_path(library_path, 'utils/rubocop.rb')
		shfmt_path: os.join_path(library, 'Homebrew/utils/shfmt.sh')
		cpu_cores: runtime.nr_cpus()
		color: brew_runtime.environment_value('TERM') != ''
		ci: brew_runtime.environment_value('CI') != ''
		github_actions: brew_runtime.environment_value('GITHUB_ACTIONS') != ''
		github_workspace: style_env_path('GITHUB_WORKSPACE', brew_runtime.current_directory())
	}
}

fn normalized_style_config(config StyleConfig) StyleConfig {
	defaults := default_style_config()
	return StyleConfig{
		prefix: if config.prefix == '' { defaults.prefix } else { config.prefix }
		repository: if config.repository == '' { defaults.repository } else { config.repository }
		library: if config.library == '' { defaults.library } else { config.library }
		library_path: if config.library_path == '' {
			defaults.library_path
		} else {
			config.library_path
		}
		original_brew_file: if config.original_brew_file == '' {
			defaults.original_brew_file
		} else {
			config.original_brew_file
		}
		cache: if config.cache == '' { defaults.cache } else { config.cache }
		tap_directory: if config.tap_directory == '' {
			defaults.tap_directory
		} else {
			config.tap_directory
		}
		ruby_args: if config.ruby_args.len == 0 { defaults.ruby_args } else { config.ruby_args }
		rubocop_path: if config.rubocop_path == '' {
			defaults.rubocop_path
		} else {
			config.rubocop_path
		}
		shellcheck_path: config.shellcheck_path
		shfmt_path: if config.shfmt_path == '' { defaults.shfmt_path } else { config.shfmt_path }
		shfmt_executable_path: config.shfmt_executable_path
		actionlint_path: config.actionlint_path
		known_cops: config.known_cops
		known_departments: config.known_departments
		cpu_cores: if config.cpu_cores <= 0 { defaults.cpu_cores } else { config.cpu_cores }
		color: config.color
		ci: config.ci
		github_actions: config.github_actions
		github_workspace: if config.github_workspace == '' {
			defaults.github_workspace
		} else {
			config.github_workspace
		}
	}
}

fn style_find_tool(configured string, name string) !string {
	if configured != '' {
		return configured
	}
	return brew_runtime.find_executable(name) or { return error('Unable to find ${name}') }
}

fn style_existing_real_path(path string) !string {
	if !os.exists(path) {
		return error('No such file or directory: ${path}')
	}
	return os.real_path(path)
}

fn style_recursive_files(root string, accept fn(string) bool) []string {
	if !os.is_dir(root) {
		return []
	}
	mut files := os.walk_ext(root, '', hidden: true)
	files = files.filter(!os.is_dir(it) && accept(it))
	files.sort()
	return files
}

fn style_direct_files(root string, accept fn(string) bool) []string {
	if !os.is_dir(root) {
		return []
	}
	mut files := []string{}
	for name in os.ls(root) or { return [] } {
		path := os.join_path(root, name)
		if !os.is_dir(path) && accept(path) {
			files << path
		}
	}
	files.sort()
	return files
}

fn style_is_shell_file(path string) bool {
	return path.ends_with('.sh')
}

fn style_has_shell_shebang(contents string) bool {
	prefix := if contents.len > 13 { contents[..13] } else { contents }
	for shebang in ['#!/bin/sh', '#! /bin/sh', '#!/bin/bash', '#! /bin/bash'] {
		if prefix == shebang || prefix.starts_with('${shebang} ') || prefix.starts_with('${shebang}\n') {
			return true
		}
	}
	return false
}

fn style_any_optional_string(values map[string]json2.Any, key string) ?string {
	value := values[key] or { return none }
	if value is json2.Null {
		return none
	}
	return value.str()
}

fn style_any_int(values map[string]json2.Any, key string) int {
	value := values[key] or { return 0 }
	return value.int()
}

fn style_any_bool(values map[string]json2.Any, key string) bool {
	value := values[key] or { return false }
	if value is json2.Null {
		return false
	}
	return value.bool()
}

fn style_offense_input(values map[string]json2.Any) !StyleOffenseInput {
	message := style_any_optional_string(values, 'message') or {
		return error('style offense has no message')
	}
	location_any := values['location'] or { return error('style offense has no location') }
	location := location_any.as_map()
	column_value := location['column'] or { json2.Any(json2.null) }
	return StyleOffenseInput{
		severity: style_any_optional_string(values, 'severity')
		message: message
		cop_name: style_any_optional_string(values, 'cop_name')
		corrected: style_any_bool(values, 'corrected')
		correctable: style_any_bool(values, 'correctable')
		line: style_any_int(location, 'line')
		column: if !(column_value is json2.Null) {
			style_any_int(location, 'column')
		} else {
			none
		}
	}
}

fn style_rubocop_files(document json2.Any, base_dir string) ![]StyleOffenseFile {
	root := document.as_map()
	files_any := root['files'] or { return error('RuboCop JSON has no files') }
	mut files := []StyleOffenseFile{}
	for file_any in files_any.as_array() {
		file := file_any.as_map()
		raw_path := style_any_optional_string(file, 'path') or {
			return error('RuboCop file has no path')
		}
		path := if os.is_abs_path(raw_path) { raw_path } else { os.join_path(base_dir, raw_path) }
		mut offenses := []StyleOffenseInput{}
		for offense in (file['offenses'] or { json2.Any([]json2.Any{}) }).as_array() {
			offenses << style_offense_input(offense.as_map())!
		}
		files << StyleOffenseFile{
			path: os.abs_path(path)
			offenses: offenses
		}
	}
	return files
}

fn style_shellcheck_files(document json2.Any) ![]StyleOffenseFile {
	mut order := []string{}
	mut grouped := map[string][]StyleOffenseInput{}
	for item_any in document.as_array() {
		mut item := item_any.as_map()
		path := style_any_optional_string(item, 'file') or {
			return error('ShellCheck offense has no file')
		}
		if path !in grouped {
			order << path
			grouped[path] = []
		}
		level := style_any_optional_string(item, 'level') or { '' }
		severity := match level {
			'style' { 'refactor' }
			'info' { 'convention' }
			else { level }
		}
		code := style_any_int(item, 'code')
		line := style_any_int(item, 'line')
		column := style_any_int(item, 'column')
		fix := item['fix'] or { json2.Any(json2.null) }
		grouped[path] << StyleOffenseInput{
			severity: severity
			message: style_any_optional_string(item, 'message') or { '' }
			cop_name: 'SC${code}'
			corrected: false
			correctable: !(fix is json2.Null)
			line: line
			column: column
		}
	}
	return order.map(StyleOffenseFile{
		path: it
		offenses: grouped[it]
	})
}

pub fn new_style_offense(input StyleOffenseInput) StyleOffense {
	location := if column := input.column {
		new_source_location_with_column(input.line, column)
	} else {
		new_source_location(input.line)
	}
	return StyleOffense{
		severity: input.severity
		message: input.message
		cop_name: input.cop_name
		corrected: input.corrected
		correctable: input.correctable
		location: location
	}
}

pub fn new_style_offenses(paths []StyleOffenseFile) !StyleOffenses {
	mut by_path := map[string][]StyleOffense{}
	mut order := []string{}
	for file in paths {
		if file.offenses.len == 0 {
			continue
		}
		path := style_existing_real_path(file.path)!
		if path !in by_path {
			order << path
		}
		by_path[path] = file.offenses.map(new_style_offense(it))
	}
	return StyleOffenses{
		by_path: by_path
		paths: order
	}
}

pub fn (offenses StyleOffenses) for_path(path string) []StyleOffense {
	return (offenses.by_path[os.norm_path(path)] or { []StyleOffense{} }).clone()
}

pub fn (offenses StyleOffenses) entries() []StyleOffensesEntry {
	return offenses.paths.map(StyleOffensesEntry{
		path: it
		offenses: offenses.by_path[it].clone()
	})
}

fn style_escape_annotation(value string) string {
	return value.replace('%', '%25').replace('\n', '%0A').replace('\r', '%0D')
}

fn style_annotation_relevant(path string, workspace string) bool {
	if !os.exists(path) {
		return true
	}
	real_path := os.real_path(path)
	real_workspace := os.real_path(workspace).trim_string_right(os.path_separator)
	return real_path == real_workspace || real_path.starts_with('${real_workspace}${os.path_separator}')
}

pub fn style_check_and_print(files []string, options StyleCheckOptions) !bool {
	result := style_check_impl(files, .print, options)!
	if normalized_style_config(options.config).github_actions && !result.success {
		offenses := style_check_json(files, options)!
		config := normalized_style_config(options.config)
		for entry in offenses.entries() {
			if !style_annotation_relevant(entry.path, config.github_workspace) {
				continue
			}
			for offense in entry.offenses {
				// The pinned Ruby implementation uses the line for both line and column.
				println('::error file=${style_escape_annotation(entry.path)},line=${offense.location.line},col=${offense.location.line}::${style_escape_annotation(offense.message)}')
			}
		}
	}
	return result.success
}

pub fn style_check_json(files []string, options StyleCheckOptions) !StyleOffenses {
	return style_check_impl(files, .json, options)!.offenses
}

pub fn style_check_impl(files []string, output_type StyleOutputType,
	options StyleCheckOptions) !StyleCheckResult {
	config := normalized_style_config(options.config)
	mut ruby_files := []string{}
	mut shell_files := []string{}
	mut actionlint_files := []string{}
	for raw_path in files {
		path := os.norm_path(raw_path)
		match os.file_ext(path) {
			'.rb' { ruby_files << path }
			'.sh' { shell_files << path }
			'.yml' {
				if os.real_path(path).contains('/.github/workflows/') {
					actionlint_files << path
				}
			}
			else {
				ruby_files << path
				if os.real_path(path) in [os.real_path(config.prefix),
					os.real_path(config.repository)] {
					shell_files << style_shell_scripts(config)
				} else {
					shell_files << style_recursive_files(path, style_is_shell_file).filter(!it.contains('/vendor/'))
				}
				actionlint_files << style_direct_files(os.join_path(path, '.github/workflows'), fn (item string) bool {
					return item.ends_with('.yml') || item.ends_with('.yaml')
				})
			}
		}
	}
	rubocop_needed := files.len == 0 || ruby_files.len > 0
	shell_needed := files.len == 0 || shell_files.len > 0
	if files.len == 0 && actionlint_files.len == 0 {
		actionlint_files = style_github_workflow_files(config)
	}
	has_actionlint_workflow := actionlint_files.any(it.ends_with('/.github/workflows/actionlint.yml'))
	actionlint_needed := files.len == 0 || (!has_actionlint_workflow && actionlint_files.len > 0)

	shellcheck_path := if shell_needed || actionlint_needed {
		style_shellcheck(config)!
	} else {
		''
	}
	shfmt_path := if shell_needed { style_shfmt_executable(config)! } else { '' }
	actionlint_path := if actionlint_needed { style_actionlint(config)! } else { '' }

	rubocop_result := if rubocop_needed {
		style_run_rubocop(ruby_files, output_type, options)!
	} else {
		StyleLintResult{ success: true }
	}
	shellcheck_result := if shell_needed {
		style_run_shellcheck(shell_files, output_type, StyleShellcheckOptions{
			fix: options.fix
			shellcheck_path: shellcheck_path
			config: config
		})!
	} else {
		StyleLintResult{ success: true }
	}
	shfmt_result := if shell_needed {
		style_run_shfmt(shell_files, StyleShfmtOptions{
			fix: options.fix
			shfmt_path: shfmt_path
			config: config
		})!
	} else {
		StyleLintResult{ success: true }
	}
	actionlint_result := if actionlint_needed {
		style_run_actionlint(actionlint_files, StyleActionlintOptions{
			actionlint_path: actionlint_path
			shellcheck_path: shellcheck_path
			config: config
		})!
	} else {
		StyleLintResult{ success: true }
	}
	if output_type == .json {
		mut all_files := rubocop_result.files.clone()
		all_files << shellcheck_result.files
		return StyleCheckResult{
			success: rubocop_result.success && shellcheck_result.success && shfmt_result.success && actionlint_result.success
			offenses: new_style_offenses(all_files)!
		}
	}
	return StyleCheckResult{
		success: rubocop_result.success && shellcheck_result.success && shfmt_result.success && actionlint_result.success
	}
}

fn style_qualified_cop_name(cop string, config StyleConfig) string {
	if cop.contains('/') || config.known_cops.len == 0 {
		return cop
	}
	matches := config.known_cops.filter(it.ends_with('/${cop}'))
	return if matches.len == 1 { matches[0] } else { cop }
}

fn style_valid_cops(cops []string, config StyleConfig) []string {
	qualified := cops.map(style_qualified_cop_name(it, config))
	if config.known_cops.len == 0 && config.known_departments.len == 0 {
		return qualified
	}
	return qualified.filter(it in config.known_cops || it in config.known_departments)
}

pub fn style_run_rubocop(files []string, output_type StyleOutputType,
	options StyleCheckOptions) !StyleLintResult {
	config := normalized_style_config(options.config)
	mut args := ['--force-exclusion']
	if options.fix {
		args << '--autocorrect-all'
	}
	if options.todo {
		args << '--disable-uncorrectable'
	}
	if options.verbose {
		args << '--extra-details'
	}
	if options.has_except_cops {
		cops := style_valid_cops(options.except_cops, config)
		if cops.len > 0 {
			args << ['--except', cops.join(',')]
		}
	} else if options.has_only_cops {
		cops := style_valid_cops(options.only_cops, config)
		if cops.len == 0 {
			return error('RuboCops ${options.only_cops.join(',')} were not found')
		}
		args << ['--only', cops.join(',')]
	}
	mut expanded_files := files.map(os.abs_path(it))
	mut base_dir := brew_runtime.current_directory()
	if expanded_files.len == 0 || (expanded_files.len == 1 && expanded_files[0] == os.abs_path(config.repository)) {
		expanded_files = [config.library_path]
		base_dir = config.library_path
	} else if expanded_files.any(it.starts_with(os.join_path(config.repository, 'docs')) || os.base(it) == 'docs') {
		args << ['--config', os.join_path(config.repository, 'docs/docs_rubocop_style.yml')]
	} else if expanded_files.any(it.starts_with(config.library_path)) {
		base_dir = config.library_path
	} else {
		args << ['--config', os.join_path(config.library, '.rubocop.yml')]
		if expanded_files.any(it.starts_with(config.library)) {
			base_dir = config.library
		}
	}
	os.mkdir_all(config.cache)!
	cache_dir := os.join_path(os.real_path(config.cache), 'style')
	cache_writable := (!os.exists(cache_dir) && os.is_writable(os.dir(cache_dir))) || (os.exists(cache_dir) && os.is_writable(cache_dir))
	mut environment := map[string]?string{}
	if cache_writable {
		args << '--parallel'
		if options.reset_cache && os.exists(cache_dir) {
			os.rmdir_all(cache_dir)!
		}
		environment['XDG_CACHE_HOME'] = cache_dir
	} else {
		args << ['--cache', 'false']
	}
	args << expanded_files
	ruby_args := if config.ruby_args.len == 0 { ['ruby'] } else { config.ruby_args.clone() }
	mut command_args := ruby_args[1..].clone()
	command_args << ['--', config.rubocop_path]
	if output_type == .json {
		command_args << ['--format', 'json']
	}
	command_args << args
	if output_type == .print {
		if options.debug {
			command_args << '--debug'
		}
		if config.ci || expanded_files.filter(!os.is_dir(it)).len == 1 {
			command_args << ['--format', 'clang']
		}
		if config.color {
			command_args << '--color'
		}
	}
	result := run_system_command(ruby_args[0], SystemCommandOptions{
		args: command_args
		environment: environment
		chdir: base_dir
		print_stderr: .discard
	})!
	if output_type == .print {
		print(result.stdout_text())
		eprint(result.stderr_text())
		return StyleLintResult{
			success: result.success()
			stdout: result.stdout_text()
			stderr: result.stderr_text()
			invocations: [result.command.clone()]
		}
	}
	document := style_json_result(result)!
	return StyleLintResult{
		success: result.success()
		files: style_rubocop_files(document, base_dir)!
		stdout: result.stdout_text()
		stderr: result.stderr_text()
		invocations: [result.command.clone()]
	}
}

pub fn style_run_shellcheck(files []string, output_type StyleOutputType,
	options StyleShellcheckOptions) !StyleLintResult {
	config := normalized_style_config(options.config)
	shellcheck_path := if options.shellcheck_path == '' {
		style_shellcheck(config)!
	} else {
		options.shellcheck_path
	}
	mut actual_files := if files.len == 0 { style_shell_scripts(config) } else { files.clone() }
	for index, path in actual_files {
		actual_files[index] = style_existing_real_path(path)!
	}
	base_args := ['--shell=bash', '--enable=all', '--external-sources',
		'--source-path=${config.library}']
	mut invocations := [][]string{}
	if options.fix {
		mut diff_args := ['--format=diff']
		diff_args << base_args
		diff_results := style_shellcheck_chunks(shellcheck_path, actual_files, diff_args, config.cpu_cores)!
		mut patches := ''
		for result in diff_results {
			invocations << result.command.clone()
			patches += result.stdout_text()
		}
		if patches != '' {
			patch_result := run_system_command('patch', SystemCommandOptions{
				args: ['-g', '0', '-f', '-d', '/', '-p0']
				input: [patches]
				must_succeed: true
				print_stderr: .discard
			})!
			invocations << patch_result.command.clone()
		}
	}
	mut output_args := [
		if output_type == .json { '--format=json' } else { '--format=tty' },
	]
	output_args << base_args
	if output_type == .print && config.color {
		output_args << '--color=always'
	}
	results := style_shellcheck_chunks(shellcheck_path, actual_files, output_args, config.cpu_cores)!
	mut stdout := ''
	mut stderr := ''
	mut success := true
	mut files_result := []StyleOffenseFile{}
	for result in results {
		invocations << result.command.clone()
		stdout += result.stdout_text()
		stderr += result.stderr_text()
		success = success && result.success()
		if output_type == .json {
			files_result << style_shellcheck_files(style_json_result(result)!)!
		}
	}
	if output_type == .print {
		print(stdout)
		eprint(stderr)
	}
	return StyleLintResult{
		success: success
		files: files_result
		stdout: stdout
		stderr: stderr
		invocations: invocations
	}
}

pub fn style_shellcheck_chunks(shellcheck_path string, files []string, args []string,
	cores int) ![]SystemCommandResult {
	chunk_count := if cores < files.len { cores } else { files.len }
	if chunk_count <= 0 {
		return []
	}
	chunk_size := (files.len + chunk_count - 1) / chunk_count
	mut results := []SystemCommandResult{}
	for start := 0; start < files.len; start += chunk_size {
		end := if start + chunk_size < files.len { start + chunk_size } else { files.len }
		mut command_args := args.clone()
		command_args << '--'
		command_args << files[start..end]
		results << run_system_command(shellcheck_path, SystemCommandOptions{
			args: command_args
			print_stderr: .discard
		})!
	}
	return results
}

pub fn style_run_shfmt(files []string, options StyleShfmtOptions) !StyleLintResult {
	config := normalized_style_config(options.config)
	shfmt_executable := if options.shfmt_path == '' {
		style_shfmt_executable(config)!
	} else {
		options.shfmt_path
	}
	mut actual_files := if files.len == 0 { style_shell_scripts(config) } else { files.clone() }
	actual_files = actual_files.filter(os.norm_path(it) !in [
		os.norm_path(os.join_path(config.repository, 'completions/bash/brew')),
		os.norm_path(os.join_path(config.repository, 'Dockerfile')),
	])
	mut args := ['--language-dialect', 'bash', '--indent', '2', '--case-indent', '--']
	args << actual_files
	if options.fix {
		args.prepend('--write')
	}
	result := run_system_command(config.shfmt_path, SystemCommandOptions{
		args: args
		environment: system_command_environment({
			'HOMEBREW_SHFMT': shfmt_executable
		})
		print_stderr: .discard
	})!
	print(result.stdout_text())
	eprint(result.stderr_text())
	return StyleLintResult{
		success: result.success()
		stdout: result.stdout_text()
		stderr: result.stderr_text()
		invocations: [result.command.clone()]
	}
}

pub fn style_run_actionlint(files []string, options StyleActionlintOptions) !StyleLintResult {
	config := normalized_style_config(options.config)
	actionlint_path := if options.actionlint_path == '' {
		style_actionlint(config)!
	} else {
		options.actionlint_path
	}
	shellcheck_path := if options.shellcheck_path == '' {
		style_shellcheck(config)!
	} else {
		options.shellcheck_path
	}
	actual_files := if files.len == 0 { style_github_workflow_files(config) } else { files.clone() }
	mut tap_configs := []string{}
	for file in actual_files {
		if tap := tap_from_path(file, config.tap_directory) {
			tap_config := os.join_path(tap_path(tap, config.tap_directory), '.github/actionlint.yaml')
			if os.exists(tap_config) && tap_config !in tap_configs {
				tap_configs << tap_config
			}
		}
	}
	config_file := if tap_configs.len == 1 {
		tap_configs[0]
	} else {
		os.join_path(config.repository, '.github/actionlint.yaml')
	}
	mut args := ['-shellcheck', shellcheck_path, '-config-file', config_file, '-ignore',
		'image: string; options: string', '-ignore', 'label .* is unknown']
	if config.color {
		args << '-color'
	}
	args << actual_files
	result := run_system_command(actionlint_path, SystemCommandOptions{
		args: args
		print_stderr: .discard
	})!
	print(result.stdout_text())
	eprint(result.stderr_text())
	return StyleLintResult{
		success: result.success()
		stdout: result.stdout_text()
		stderr: result.stderr_text()
		invocations: [result.command.clone()]
	}
}

pub fn style_json_result(result SystemCommandResult) !json2.Any {
	stdout := result.stdout_text()
	exit_status := result.exit_status or { -1 }
	if exit_status < 0 || exit_status > 1 || stdout.len < 2 {
		result.assert_success()!
		if stdout.len < 2 {
			return error('JSON output must be at least 2 characters')
		}
	}
	return json2.decode[json2.Any](stdout)
}

pub fn style_shell_scripts(raw_config StyleConfig) []string {
	config := normalized_style_config(raw_config)
	mut files := []string{}
	if os.exists(config.original_brew_file) {
		files << os.real_path(config.original_brew_file)
	}
	files << os.join_path(config.repository, 'completions/bash/brew')
	files << os.join_path(config.repository, 'Dockerfile')
	files << style_recursive_files(os.join_path(config.repository, '.devcontainer'), style_is_shell_file)
	files << style_direct_files(os.join_path(config.repository, '.github/scripts'), style_is_shell_file)
	files << style_direct_files(os.join_path(config.repository, 'package/scripts'), fn (path string) bool {
		return true
	})
	files << style_recursive_files(os.join_path(config.library, 'Homebrew'), style_is_shell_file).filter(!it.contains('/vendor/'))
	for path in style_recursive_files(os.join_path(config.library, 'Homebrew/shims'), fn (item string) bool {
		return true
	}) {
		real_path := os.real_path(path)
		if os.is_dir(real_path) || os.base(path) == 'cc' {
			continue
		}
		contents := os.read_file(real_path) or { continue }
		if style_has_shell_shebang(contents) {
			files << real_path
		}
	}
	for directory in ['dev-cmd', 'cmd'] {
		files << style_direct_files(os.join_path(config.library, 'Homebrew/${directory}'), style_is_shell_file)
	}
	for directory in ['Homebrew/utils', 'Homebrew/cask/utils'] {
		files << style_direct_files(os.join_path(config.library, directory), style_is_shell_file)
	}
	return files
}

pub fn style_github_workflow_files(raw_config StyleConfig) []string {
	config := normalized_style_config(raw_config)
	return style_direct_files(os.join_path(config.repository, '.github/workflows'), fn (path string) bool {
		return path.ends_with('.yml')
	})
}

pub fn style_shellcheck(raw_config StyleConfig) !string {
	config := normalized_style_config(raw_config)
	return style_find_tool(config.shellcheck_path, 'shellcheck')
}

pub fn style_shfmt(raw_config StyleConfig) string {
	return normalized_style_config(raw_config).shfmt_path
}

pub fn style_shfmt_executable(raw_config StyleConfig) !string {
	config := normalized_style_config(raw_config)
	return style_find_tool(config.shfmt_executable_path, 'shfmt')
}

pub fn style_actionlint(raw_config StyleConfig) !string {
	config := normalized_style_config(raw_config)
	return style_find_tool(config.actionlint_path, 'actionlint')
}

// Ruby method `self.check_style_and_print(files, **options)` at line 20.
pub fn ruby_style_l20_d1_self_check_style_and_print(files []string,
	options StyleCheckOptions) !bool {
	return style_check_and_print(files, options)
}

// Ruby method `self.check_style_json(files, **options)` at line 41.
pub fn ruby_style_l41_d2_self_check_style_json(files []string,
	options StyleCheckOptions) !StyleOffenses {
	return style_check_json(files, options)
}

// Ruby method `self.check_style_impl(files, output_type,` at line 59.
pub fn ruby_style_l59_d3_self_check_style_impl(files []string, output_type StyleOutputType,
	options StyleCheckOptions) !StyleCheckResult {
	return style_check_impl(files, output_type, options)
}

// Ruby method `self.run_rubocop(files, output_type,` at line 190.
pub fn ruby_style_l190_d4_self_run_rubocop(files []string, output_type StyleOutputType,
	options StyleCheckOptions) !StyleLintResult {
	return style_run_rubocop(files, output_type, options)
}

// Ruby method `self.run_shellcheck(files, output_type, fix: false, shellcheck_path: nil, out: $stdout, err: $stderr)` at line 295.
pub fn ruby_style_l295_d5_self_run_shellcheck(files []string, output_type StyleOutputType,
	options StyleShellcheckOptions) !StyleLintResult {
	return style_run_shellcheck(files, output_type, options)
}

// Ruby method `self.shellcheck_chunks(shellcheck_path, files, args)` at line 377.
pub fn ruby_style_l377_d6_self_shellcheck_chunks(shellcheck_path string, files []string,
	args []string, cores int) ![]SystemCommandResult {
	return style_shellcheck_chunks(shellcheck_path, files, args, cores)
}

// Ruby method `self.run_shfmt!(files, fix: false, shfmt_path: nil, out: $stdout, err: $stderr)` at line 399.
pub fn ruby_style_l399_d7_self_run_shfmt(files []string,
	options StyleShfmtOptions) !StyleLintResult {
	return style_run_shfmt(files, options)
}

// Ruby method `self.run_actionlint!(files, actionlint_path: nil, shellcheck_path: nil, out: $stdout, err: $stderr)` at line 427.
pub fn ruby_style_l427_d8_self_run_actionlint(files []string,
	options StyleActionlintOptions) !StyleLintResult {
	return style_run_actionlint(files, options)
}

// Ruby method `self.json_result!(result)` at line 459.
pub fn ruby_style_l459_d9_self_json_result(result SystemCommandResult) !json2.Any {
	return style_json_result(result)
}

// Ruby method `self.shell_scripts` at line 469.
pub fn ruby_style_l469_d10_self_shell_scripts(config StyleConfig) []string {
	return style_shell_scripts(config)
}

// Ruby method `self.github_workflow_files` at line 490.
pub fn ruby_style_l490_d11_self_github_workflow_files(config StyleConfig) []string {
	return style_github_workflow_files(config)
}

// Ruby method `self.shellcheck` at line 495.
pub fn ruby_style_l495_d12_self_shellcheck(config StyleConfig) !string {
	return style_shellcheck(config)
}

// Ruby method `self.shfmt` at line 503.
pub fn ruby_style_l503_d13_self_shfmt(config StyleConfig) string {
	return style_shfmt(config)
}

// Ruby method `self.shfmt_executable` at line 508.
pub fn ruby_style_l508_d14_self_shfmt_executable(config StyleConfig) !string {
	return style_shfmt_executable(config)
}

// Ruby method `self.actionlint` at line 516.
pub fn ruby_style_l516_d15_self_actionlint(config StyleConfig) !string {
	return style_actionlint(config)
}

// Ruby method `initialize(paths)` at line 532.
pub fn ruby_style_l532_d16_initialize(paths []StyleOffenseFile) !StyleOffenses {
	return new_style_offenses(paths)
}

// Ruby method `for_path(path)` at line 543.
pub fn ruby_style_l543_d17_for_path(offenses StyleOffenses, path string) []StyleOffense {
	return offenses.for_path(path)
}

// Ruby method `each(&block)` at line 556.
pub fn ruby_style_l556_d18_each(offenses StyleOffenses) []StyleOffensesEntry {
	return offenses.entries()
}

// Ruby attr_reader `attr_reader :message` at line 564.
pub fn ruby_style_l564_d19_message(offense StyleOffense) string {
	return offense.message
}

// Ruby attr_reader `attr_reader :severity, :cop_name` at line 567.
pub fn ruby_style_l567_d20_severity(offense StyleOffense) ?string {
	return offense.severity
}

// Ruby attr_reader `attr_reader :severity, :cop_name` at line 567.
pub fn ruby_style_l567_d21_cop_name(offense StyleOffense) ?string {
	return offense.cop_name
}

// Ruby attr_reader `attr_reader :corrected` at line 570.
pub fn ruby_style_l570_d22_corrected(offense StyleOffense) bool {
	return offense.corrected
}

// Ruby attr_reader `attr_reader :location` at line 573.
pub fn ruby_style_l573_d23_location(offense StyleOffense) SourceLocation {
	return offense.location
}

// Ruby method `initialize(json)` at line 576.
pub fn ruby_style_l576_d24_initialize(input StyleOffenseInput) StyleOffense {
	return new_style_offense(input)
}

// Ruby method `corrected?` at line 586.
pub fn ruby_style_l586_d25_corrected(offense StyleOffense) bool {
	return offense.corrected
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "shellwords"
// 5: require "source_location"
// 6: require "stringio"
// 7: require "system_command"
// 8: require "tap"
// 9: require "utils/output"
// 10:
// 11: module Homebrew
// 12:   # Helper module for running RuboCop.
// 13:   module Style
// 14:     extend Utils::Output::Mixin
// 15:     extend SystemCommand::Mixin
// 16:
// 17:     # Checks style for a list of files, printing simple RuboCop output.
// 18:     # Returns true if violations were found, false otherwise.
// 19:     sig { params(files: T::Array[Pathname], options: T.untyped).returns(T::Boolean) }
// 20:     def self.check_style_and_print(files, **options)
// 21:       success = check_style_impl(files, :print, **options)
// 22:
// 23:       if GitHub::Actions.env_set? && !success
// 24:         check_style_json(files, **options).each do |path, offenses|
// 25:           offenses.each do |o|
// 26:             line = o.location.line
// 27:             column = o.location.line
// 28:
// 29:             annotation = GitHub::Actions::Annotation.new(:error, o.message, file: path, line:, column:)
// 30:             puts annotation if annotation.relevant?
// 31:           end
// 32:         end
// 33:       end
// 34:
// 35:       T.cast(success, T::Boolean)
// 36:     end
// 37:
// 38:     # Checks style for a list of files, returning results as an {Offenses}
// 39:     # object parsed from its JSON output.
// 40:     sig { params(files: T::Array[Pathname], options: T.untyped).returns(Offenses) }
// 41:     def self.check_style_json(files, **options)
// 42:       T.cast(check_style_impl(files, :json, **options), Offenses)
// 43:     end
// 44:
// 45:     sig {
// 46:       params(
// 47:         files:             T::Array[Pathname],
// 48:         output_type:       Symbol,
// 49:         fix:               T::Boolean,
// 50:         todo:              T::Boolean,
// 51:         except_cops:       T.nilable(T::Array[String]),
// 52:         only_cops:         T.nilable(T::Array[String]),
// 53:         display_cop_names: T::Boolean,
// 54:         reset_cache:       T::Boolean,
// 55:         debug:             T::Boolean,
// 56:         verbose:           T::Boolean,
// 57:       ).returns(T.any(Offenses, T::Boolean))
// 58:     }
// 59:     def self.check_style_impl(files, output_type,
// 60:                               fix: false,
// 61:                               todo: false,
// 62:                               except_cops: nil, only_cops: nil,
// 63:                               display_cop_names: false,
// 64:                               reset_cache: false,
// 65:                               debug: false, verbose: false)
// 66:       raise ArgumentError, "Invalid output type: #{output_type.inspect}" if [:print, :json].exclude?(output_type)
// 67:
// 68:       ruby_files = T.let([], T::Array[Pathname])
// 69:       shell_files = T.let([], T::Array[Pathname])
// 70:       actionlint_files = T.let([], T::Array[Pathname])
// 71:       Array(files).map { Pathname(it) }
// 72:                   .each do |path|
// 73:         case path.extname
// 74:         when ".rb"
// 75:           ruby_files << path
// 76:         when ".sh"
// 77:           shell_files << path
// 78:         when ".yml"
// 79:           actionlint_files << path if path.realpath.to_s.include?("/.github/workflows/")
// 80:         else
// 81:           ruby_files << path
// 82:           shell_files += if [HOMEBREW_PREFIX, HOMEBREW_REPOSITORY].include?(path)
// 83:             shell_scripts
// 84:           else
// 85:             path.glob("**/*.sh")
// 86:                 .reject { |file_path| file_path.to_s.include?("/vendor/") || file_path.directory? }
// 87:           end
// 88:           actionlint_files += (path/".github/workflows").glob("*.y{,a}ml")
// 89:         end
// 90:       end
// 91:
// 92:       rubocop_needed = files.blank? || ruby_files.any?
// 93:       shell_needed = files.blank? || shell_files.any?
// 94:
// 95:       actionlint_files = github_workflow_files if files.blank? && actionlint_files.blank?
// 96:       has_actionlint_workflow = actionlint_files.any? do |path|
// 97:         path.to_s.end_with?("/.github/workflows/actionlint.yml")
// 98:       end
// 99:       odebug "actionlint workflow detected. Skipping actionlint checks." if has_actionlint_workflow
// 100:       actionlint_needed = files.blank? || (!has_actionlint_workflow && actionlint_files.any?)
// 101:
// 102:       # Resolve the linter executables (installing them if necessary) before
// 103:       # spawning threads so those threads cannot race to install formulae.
// 104:       shellcheck_path = (shellcheck if shell_needed || actionlint_needed)
// 105:       shfmt_path = (shfmt_executable if shell_needed)
// 106:       actionlint_path = (actionlint if actionlint_needed)
// 107:
// 108:       shellcheck_out = StringIO.new
// 109:       shellcheck_err = StringIO.new
// 110:       shfmt_out = StringIO.new
// 111:       shfmt_err = StringIO.new
// 112:       actionlint_out = StringIO.new
// 113:       actionlint_err = StringIO.new
// 114:
// 115:       # Run the shell and GitHub Actions checks on background threads with
// 116:       # buffered output while RuboCop runs on the main thread.
// 117:       shell_thread = Thread.new do
// 118:         shellcheck_result = if shell_needed
// 119:           run_shellcheck(shell_files, output_type, fix:, shellcheck_path:,
// 120:                          out: shellcheck_out, err: shellcheck_err)
// 121:         elsif output_type == :json
// 122:           []
// 123:         else
// 124:           true
// 125:         end
// 126:         # `shellcheck --fix` and `shfmt --write` may touch the same files so
// 127:         # they must not run concurrently with each other.
// 128:         shfmt_result = !shell_needed || run_shfmt!(shell_files, fix:, shfmt_path:,
// 129:                                                    out: shfmt_out, err: shfmt_err)
// 130:         [shellcheck_result, shfmt_result]
// 131:       end
// 132:       actionlint_thread = Thread.new do
// 133:         !actionlint_needed ||
// 134:           run_actionlint!(actionlint_files, actionlint_path:, shellcheck_path:,
// 135:                           out: actionlint_out, err: actionlint_err)
// 136:       end
// 137:
// 138:       rubocop_result = if rubocop_needed
// 139:         run_rubocop(ruby_files, output_type,
// 140:                     fix:,
// 141:                     todo:,
// 142:                     except_cops:, only_cops:,
// 143:                     display_cop_names:,
// 144:                     reset_cache:,
// 145:                     debug:, verbose:)
// 146:       elsif output_type == :json
// 147:         []
// 148:       else
// 149:         true
// 150:       end
// 151:
// 152:       shellcheck_result, shfmt_result = shell_thread.value
// 153:       actionlint_result = actionlint_thread.value
// 154:
// 155:       [
// 156:         [shellcheck_out, shellcheck_err],
// 157:         [shfmt_out, shfmt_err],
// 158:         [actionlint_out, actionlint_err],
// 159:       ].each do |out, err|
// 160:         $stdout.print out.string
// 161:         $stderr.print err.string
// 162:       end
// 163:
// 164:       if output_type == :json
// 165:         Offenses.new(
// 166:           T.cast(rubocop_result, T::Array[T::Hash[String, T.untyped]]) +
// 167:           T.cast(shellcheck_result, T::Array[T::Hash[String, T.untyped]]),
// 168:         )
// 169:       else
// 170:         rubocop_result && !!shellcheck_result && shfmt_result && actionlint_result
// 171:       end
// 172:     end
// 173:
// 174:     RUBOCOP = T.let((HOMEBREW_LIBRARY_PATH/"utils/rubocop.rb").freeze, Pathname)
// 175:
// 176:     sig {
// 177:       params(
// 178:         files:             T::Array[Pathname],
// 179:         output_type:       Symbol,
// 180:         fix:               T::Boolean,
// 181:         todo:              T::Boolean,
// 182:         except_cops:       T.nilable(T::Array[String]),
// 183:         only_cops:         T.nilable(T::Array[String]),
// 184:         display_cop_names: T::Boolean,
// 185:         reset_cache:       T::Boolean,
// 186:         debug:             T::Boolean,
// 187:         verbose:           T::Boolean,
// 188:       ).returns(T.any(T::Boolean, T::Array[T::Hash[String, T.untyped]]))
// 189:     }
// 190:     def self.run_rubocop(files, output_type,
// 191:                          fix: false, todo: false, except_cops: nil, only_cops: nil, display_cop_names: false,
// 192:                          reset_cache: false,
// 193:                          debug: false, verbose: false)
// 194:       require "warnings"
// 195:
// 196:       Warnings.ignore :parser_syntax do
// 197:         require "rubocop"
// 198:       end
// 199:
// 200:       require "rubocops/all"
// 201:
// 202:       args = %w[
// 203:         --force-exclusion
// 204:       ]
// 205:       args << "--autocorrect-all" if fix
// 206:       args << "--disable-uncorrectable" if todo
// 207:
// 208:       args += ["--extra-details"] if verbose
// 209:
// 210:       if except_cops
// 211:         except_cops.map! { |cop| RuboCop::Cop::Registry.global.qualified_cop_name(cop.to_s, "") }
// 212:         cops_to_exclude = except_cops.select do |cop|
// 213:           RuboCop::Cop::Registry.global.names.include?(cop) ||
// 214:             RuboCop::Cop::Registry.global.departments.include?(cop.to_sym)
// 215:         end
// 216:
// 217:         args << "--except" << cops_to_exclude.join(",") unless cops_to_exclude.empty?
// 218:       elsif only_cops
// 219:         only_cops.map! { |cop| RuboCop::Cop::Registry.global.qualified_cop_name(cop.to_s, "") }
// 220:         cops_to_include = only_cops.select do |cop|
// 221:           RuboCop::Cop::Registry.global.names.include?(cop) ||
// 222:             RuboCop::Cop::Registry.global.departments.include?(cop.to_sym)
// 223:         end
// 224:
// 225:         odie "RuboCops #{only_cops.join(",")} were not found" if cops_to_include.empty?
// 226:
// 227:         args << "--only" << cops_to_include.join(",")
// 228:       end
// 229:
// 230:       files.map!(&:expand_path)
// 231:       base_dir = Dir.pwd
// 232:       if files.blank? || files == [HOMEBREW_REPOSITORY]
// 233:         files = [HOMEBREW_LIBRARY_PATH]
// 234:         base_dir = HOMEBREW_LIBRARY_PATH
// 235:       elsif files.any? { |f| f.to_s.start_with?(HOMEBREW_REPOSITORY/"docs") || (f.basename.to_s == "docs") }
// 236:         args << "--config" << (HOMEBREW_REPOSITORY/"docs/docs_rubocop_style.yml")
// 237:       elsif files.any? { |f| f.to_s.start_with? HOMEBREW_LIBRARY_PATH }
// 238:         base_dir = HOMEBREW_LIBRARY_PATH
// 239:       else
// 240:         args << "--config" << (HOMEBREW_LIBRARY/".rubocop.yml")
// 241:         base_dir = HOMEBREW_LIBRARY if files.any? { |f| f.to_s.start_with? HOMEBREW_LIBRARY }
// 242:       end
// 243:
// 244:       HOMEBREW_CACHE.mkpath
// 245:       cache_dir = HOMEBREW_CACHE.realpath/"style"
// 246:       cache_env = if (!cache_dir.exist? && cache_dir.parent.writable?) || cache_dir.writable?
// 247:         args << "--parallel"
// 248:
// 249:         FileUtils.rm_rf cache_dir if reset_cache
// 250:
// 251:         { "XDG_CACHE_HOME" => cache_dir.to_s }
// 252:       else
// 253:         args << "--cache" << "false"
// 254:
// 255:         {}
// 256:       end
// 257:
// 258:       args += files
// 259:
// 260:       ruby_args = HOMEBREW_RUBY_EXEC_ARGS.dup
// 261:       case output_type
// 262:       when :print
// 263:         args << "--debug" if debug
// 264:
// 265:         # Don't show the default formatter's progress dots
// 266:         # on CI or if only checking a single file.
// 267:         args << "--format" << "clang" if ENV["CI"] || files.one? { |f| !f.directory? }
// 268:
// 269:         args << "--color" if Tty.color?
// 270:
// 271:         system cache_env, *ruby_args, "--", RUBOCOP, *args, chdir: base_dir
// 272:         $CHILD_STATUS.success?
// 273:       when :json
// 274:         result = system_command ruby_args.shift,
// 275:                                 args:  [*ruby_args, "--", RUBOCOP, "--format", "json", *args],
// 276:                                 env:   cache_env,
// 277:                                 chdir: base_dir
// 278:         json = json_result!(result)
// 279:         json["files"].each do |file|
// 280:           file["path"] = File.absolute_path(file["path"], base_dir)
// 281:         end
// 282:       end
// 283:     end
// 284:
// 285:     sig {
// 286:       params(
// 287:         files:           T::Array[Pathname],
// 288:         output_type:     Symbol,
// 289:         fix:             T::Boolean,
// 290:         shellcheck_path: T.nilable(Pathname),
// 291:         out:             T.any(IO, StringIO),
// 292:         err:             T.any(IO, StringIO),
// 293:       ).returns(T.nilable(T.any(T::Boolean, T::Array[T::Hash[String, T.untyped]])))
// 294:     }
// 295:     def self.run_shellcheck(files, output_type, fix: false, shellcheck_path: nil, out: $stdout, err: $stderr)
// 296:       shellcheck_path ||= shellcheck
// 297:       files = shell_scripts if files.blank?
// 298:
// 299:       files = files.map(&:realpath) # use absolute file paths
// 300:
// 301:       args = [
// 302:         "--shell=bash",
// 303:         "--enable=all",
// 304:         "--external-sources",
// 305:         "--source-path=#{HOMEBREW_LIBRARY}",
// 306:       ]
// 307:
// 308:       if fix
// 309:         # patch options:
// 310:         #   -g 0 (--get=0)       : suppress environment variable `PATCH_GET`
// 311:         #   -f   (--force)       : we know what we are doing, force apply patches
// 312:         #   -d / (--directory=/) : change to root directory, since we use absolute file paths
// 313:         #   -p0  (--strip=0)     : do not strip path prefixes, since we are at root directory
// 314:         # NOTE: We use short flags for compatibility.
// 315:         patch_command = %w[patch -g 0 -f -d / -p0]
// 316:         patches = shellcheck_chunks(shellcheck_path, files, ["--format=diff", *args]).map(&:stdout).join
// 317:         Utils.safe_popen_write(*patch_command) { |p| p.write(patches) } if patches.present?
// 318:       end
// 319:
// 320:       case output_type
// 321:       when :print
// 322:         print_args = ["--format=tty", *args]
// 323:         print_args << "--color=always" if Tty.color?
// 324:         results = shellcheck_chunks(shellcheck_path, files, print_args)
// 325:         results.each do |result|
// 326:           out.print result.stdout
// 327:           err.print result.stderr
// 328:         end
// 329:         results.all?(&:success?)
// 330:       when :json
// 331:         results = shellcheck_chunks(shellcheck_path, files, ["--format=json", *args])
// 332:         json = results.flat_map { |result| json_result!(result) }
// 333:
// 334:         # Convert to same format as RuboCop offenses.
// 335:         severity_hash = { "style" => "refactor", "info" => "convention" }
// 336:         json.group_by { |v| v["file"] }
// 337:             .map do |k, v|
// 338:           {
// 339:             "path"     => k,
// 340:             "offenses" => v.map do |o|
// 341:               o.delete("file")
// 342:
// 343:               o["cop_name"] = "SC#{o.delete("code")}"
// 344:
// 345:               level = o.delete("level")
// 346:               o["severity"] = severity_hash.fetch(level, level)
// 347:
// 348:               line = o.delete("line")
// 349:               column = o.delete("column")
// 350:
// 351:               o["corrected"] = false
// 352:               o["correctable"] = o.delete("fix").present?
// 353:
// 354:               o["location"] = {
// 355:                 "start_line"   => line,
// 356:                 "start_column" => column,
// 357:                 "last_line"    => o.delete("endLine"),
// 358:                 "last_column"  => o.delete("endColumn"),
// 359:                 "line"         => line,
// 360:                 "column"       => column,
// 361:               }
// 362:
// 363:               o
// 364:             end,
// 365:           }
// 366:         end
// 367:       end
// 368:     end
// 369:
// 370:     sig {
// 371:       params(
// 372:         shellcheck_path: Pathname,
// 373:         files:           T::Array[Pathname],
// 374:         args:            T::Array[String],
// 375:       ).returns(T::Array[SystemCommand::Result])
// 376:     }
// 377:     private_class_method def self.shellcheck_chunks(shellcheck_path, files, args)
// 378:       require "hardware"
// 379:
// 380:       chunk_count = [Hardware::CPU.cores, files.length].min
// 381:       return [] if chunk_count.zero?
// 382:
// 383:       files.each_slice((files.length.to_f / chunk_count).ceil).map do |chunk|
// 384:         Thread.new do
// 385:           system_command shellcheck_path, args: [*args, "--", *chunk], print_stderr: false
// 386:         end
// 387:       end.map(&:value)
// 388:     end
// 389:
// 390:     sig {
// 391:       params(
// 392:         files:      T::Array[Pathname],
// 393:         fix:        T::Boolean,
// 394:         shfmt_path: T.nilable(Pathname),
// 395:         out:        T.any(IO, StringIO),
// 396:         err:        T.any(IO, StringIO),
// 397:       ).returns(T::Boolean)
// 398:     }
// 399:     def self.run_shfmt!(files, fix: false, shfmt_path: nil, out: $stdout, err: $stderr)
// 400:       shfmt_path ||= shfmt_executable
// 401:       files = shell_scripts if files.blank?
// 402:       # Do not format completions and Dockerfile
// 403:       files.delete(HOMEBREW_REPOSITORY/"completions/bash/brew")
// 404:       files.delete(HOMEBREW_REPOSITORY/"Dockerfile")
// 405:
// 406:       args = ["--language-dialect", "bash", "--indent", "2", "--case-indent", "--", *files]
// 407:       args.unshift("--write") if fix # need to add before "--"
// 408:
// 409:       result = system_command shfmt,
// 410:                               args:,
// 411:                               env:          { "HOMEBREW_SHFMT" => shfmt_path.to_s },
// 412:                               print_stderr: false
// 413:       out.print result.stdout
// 414:       err.print result.stderr
// 415:       result.success?
// 416:     end
// 417:
// 418:     sig {
// 419:       params(
// 420:         files:           T::Array[Pathname],
// 421:         actionlint_path: T.nilable(Pathname),
// 422:         shellcheck_path: T.nilable(Pathname),
// 423:         out:             T.any(IO, StringIO),
// 424:         err:             T.any(IO, StringIO),
// 425:       ).returns(T::Boolean)
// 426:     }
// 427:     def self.run_actionlint!(files, actionlint_path: nil, shellcheck_path: nil, out: $stdout, err: $stderr)
// 428:       actionlint_path ||= actionlint
// 429:       shellcheck_path ||= shellcheck
// 430:       files = github_workflow_files if files.blank?
// 431:
// 432:       tap_configs = files.filter_map do |f|
// 433:         tap = Tap.from_path(f)
// 434:         next unless tap
// 435:
// 436:         tap_config = tap.path/".github/actionlint.yaml"
// 437:         tap_config if tap_config.exist?
// 438:       end.uniq
// 439:
// 440:       config_file = if tap_configs.one?
// 441:         tap_configs.fetch(0)
// 442:       else
// 443:         HOMEBREW_REPOSITORY/".github/actionlint.yaml"
// 444:       end
// 445:
// 446:       # the ignore is to avoid false positives in e.g. actions, homebrew-test-bot
// 447:       args = ["-shellcheck", shellcheck_path,
// 448:               "-config-file", config_file,
// 449:               "-ignore", "image: string; options: string",
// 450:               "-ignore", "label .* is unknown"]
// 451:       args << "-color" if Tty.color?
// 452:       result = system_command actionlint_path, args: [*args, *files], print_stderr: false
// 453:       out.print result.stdout
// 454:       err.print result.stderr
// 455:       result.success?
// 456:     end
// 457:
// 458:     sig { params(result: SystemCommand::Result).returns(T.untyped) }
// 459:     def self.json_result!(result)
// 460:       # An exit status of 1 just means violations were found; other numbers mean
// 461:       # execution errors.
// 462:       # JSON needs to be at least 2 characters.
// 463:       result.assert_success! if !(0..1).cover?(result.status.exitstatus) || result.stdout.length < 2
// 464:
// 465:       JSON.parse(result.stdout)
// 466:     end
// 467:
// 468:     sig { returns(T::Array[Pathname]) }
// 469:     def self.shell_scripts
// 470:       [
// 471:         HOMEBREW_ORIGINAL_BREW_FILE.realpath,
// 472:         HOMEBREW_REPOSITORY/"completions/bash/brew",
// 473:         HOMEBREW_REPOSITORY/"Dockerfile",
// 474:         *HOMEBREW_REPOSITORY.glob(".devcontainer/**/*.sh"),
// 475:         *HOMEBREW_REPOSITORY.glob(".github/scripts/*.sh"),
// 476:         *HOMEBREW_REPOSITORY.glob("package/scripts/*"),
// 477:         *HOMEBREW_LIBRARY.glob("Homebrew/**/*.sh").reject { |path| path.to_s.include?("/vendor/") },
// 478:         *HOMEBREW_LIBRARY.glob("Homebrew/shims/**/*").map(&:realpath).uniq
// 479:                          .reject(&:directory?)
// 480:                          .reject { |path| path.basename.to_s == "cc" }
// 481:                          .select do |path|
// 482:                            %r{^#! ?/bin/(?:ba)?sh( |$)}.match?(path.read(13))
// 483:                          end,
// 484:         *HOMEBREW_LIBRARY.glob("Homebrew/{dev-,}cmd/*.sh"),
// 485:         *HOMEBREW_LIBRARY.glob("Homebrew/{cask/,}utils/*.sh"),
// 486:       ]
// 487:     end
// 488:
// 489:     sig { returns(T::Array[Pathname]) }
// 490:     def self.github_workflow_files
// 491:       HOMEBREW_REPOSITORY.glob(".github/workflows/*.yml")
// 492:     end
// 493:
// 494:     sig { returns(Pathname) }
// 495:     def self.shellcheck
// 496:       require "formula"
// 497:       T.cast(Formula["shellcheck"].ensure_installed!(latest:     true,
// 498:                                                      reason:     "shell style checks",
// 499:                                                      executable: "shellcheck"), Pathname)
// 500:     end
// 501:
// 502:     sig { returns(Pathname) }
// 503:     def self.shfmt
// 504:       HOMEBREW_LIBRARY/"Homebrew/utils/shfmt.sh"
// 505:     end
// 506:
// 507:     sig { returns(Pathname) }
// 508:     private_class_method def self.shfmt_executable
// 509:       require "formula"
// 510:       T.cast(Formula["shfmt"].ensure_installed!(latest:     true,
// 511:                                                 reason:     "formatting shell scripts",
// 512:                                                 executable: "shfmt"), Pathname)
// 513:     end
// 514:
// 515:     sig { returns(Pathname) }
// 516:     def self.actionlint
// 517:       require "formula"
// 518:       T.cast(Formula["actionlint"].ensure_installed!(latest:       true,
// 519:                                                      reason:       "GitHub Actions checks",
// 520:                                                      executable:   "actionlint",
// 521:                                                      version_args: ["-version"]), Pathname)
// 522:     end
// 523:
// 524:     # Collection of style offenses.
// 525:     class Offenses
// 526:       include Enumerable
// 527:       extend T::Generic
// 528:
// 529:       Elem = type_member(:out) { { fixed: Offense } }
// 530:
// 531:       sig { params(paths: T::Array[T::Hash[String, T.untyped]]).void }
// 532:       def initialize(paths)
// 533:         @offenses = T.let({}, T::Hash[Pathname, T::Array[Offense]])
// 534:         paths.each do |f|
// 535:           next if f["offenses"].empty?
// 536:
// 537:           path = Pathname(f["path"]).realpath
// 538:           @offenses[path] = f["offenses"].map { |x| Offense.new(x) }
// 539:         end
// 540:       end
// 541:
// 542:       sig { params(path: T.any(String, Pathname)).returns(T::Array[Offense]) }
// 543:       def for_path(path)
// 544:         @offenses.fetch(Pathname(path), [])
// 545:       end
// 546:
// 547:       # `Enumerable#each` has a generic block type incompatible with the specific
// 548:       # `[Pathname, T::Array[Offense]]` pairs this Hash-backed class yields.
// 549:       # rubocop:disable Sorbet/AllowIncompatibleOverride
// 550:       sig {
// 551:         override(allow_incompatible: true)
// 552:           .params(block: T.proc.params(arg0: [Pathname, T::Array[Homebrew::Style::Offense]]).returns(BasicObject))
// 553:           .returns(T.untyped)
// 554:       }
// 555:       # rubocop:enable Sorbet/AllowIncompatibleOverride
// 556:       def each(&block)
// 557:         @offenses.each(&block)
// 558:       end
// 559:     end
// 560:
// 561:     # A style offense.
// 562:     class Offense
// 563:       sig { returns(String) }
// 564:       attr_reader :message
// 565:
// 566:       sig { returns(T.nilable(String)) }
// 567:       attr_reader :severity, :cop_name
// 568:
// 569:       sig { returns(T::Boolean) }
// 570:       attr_reader :corrected
// 571:
// 572:       sig { returns(SourceLocation) }
// 573:       attr_reader :location
// 574:
// 575:       sig { params(json: T::Hash[String, T.untyped]).void }
// 576:       def initialize(json)
// 577:         @severity = T.let(json["severity"], T.nilable(String))
// 578:         @message = T.let(json.fetch("message"), String)
// 579:         @cop_name = T.let(json["cop_name"], T.nilable(String))
// 580:         @corrected = T.let(json["corrected"], T::Boolean)
// 581:         location = json.fetch("location")
// 582:         @location = T.let(SourceLocation.new(location.fetch("line"), location["column"]), SourceLocation)
// 583:       end
// 584:
// 585:       sig { returns(T::Boolean) }
// 586:       def corrected?
// 587:         @corrected
// 588:       end
// 589:     end
// 590:   end
// 591: end
