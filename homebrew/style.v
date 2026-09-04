module homebrew

import ruby
import os
import runtime
import x.json2

// Translated from Homebrew/brew `style.rb`.
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
	value := ruby.environment_value(name)
	return if value == '' { fallback } else { value }
}

pub fn default_style_config() StyleConfig {
	repository := style_env_path('HOMEBREW_REPOSITORY', ruby.current_directory())
	library := style_env_path('HOMEBREW_LIBRARY', os.join_path(repository, 'Library'))
	library_path := style_env_path('HOMEBREW_LIBRARY_PATH', os.join_path(library, 'Homebrew'))
	prefix := style_env_path('HOMEBREW_PREFIX', repository)
	ruby_path := style_env_path('HOMEBREW_RUBY_PATH', 'ruby')
	return StyleConfig{
		prefix: prefix
		repository: repository
		library: library
		library_path: library_path
		original_brew_file: style_env_path('HOMEBREW_ORIGINAL_BREW_FILE', os.join_path(repository, 'bin/brew'))
		cache: style_env_path('HOMEBREW_CACHE', os.join_path(os.temp_dir(), 'Homebrew'))
		tap_directory: style_env_path('HOMEBREW_TAP_DIRECTORY', os.join_path(library, 'Taps'))
		ruby_args: [ruby_path]
		rubocop_path: os.join_path(library_path, 'utils/rubocop.rb')
		shfmt_path: os.join_path(library, 'Homebrew/utils/shfmt.sh')
		cpu_cores: runtime.nr_cpus()
		color: ruby.environment_value('TERM') != ''
		ci: ruby.environment_value('CI') != ''
		github_actions: ruby.environment_value('GITHUB_ACTIONS') != ''
		github_workspace: style_env_path('GITHUB_WORKSPACE', ruby.current_directory())
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
	return ruby.find_executable(name) or { return error('Unable to find ${name}') }
}

fn style_existing_real_path(path string) !string {
	if !os.exists(path) {
		return error('No such file or directory: ${path}')
	}
	return os.real_path(path)
}

fn style_recursive_files(root string, accept fn (string) bool) []string {
	if !os.is_dir(root) {
		return []
	}
	mut files := os.walk_ext(root, '', hidden: true)
	files = files.filter(!os.is_dir(it) && accept(it))
	files.sort()
	return files
}

fn style_direct_files(root string, accept fn (string) bool) []string {
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
	mut base_dir := ruby.current_directory()
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
