module cmd

import ruby
import encoding.utf8
import os
import time

// Translated from Homebrew/brew `cmd/gist-logs.rb`.

pub const gist_logs_glue = '\n[...snip...]\n'

const gist_logs_max_file_size = 1_000_000

pub struct GistLogFile {
pub:
	content string
}

pub struct GistLogsFormula {
pub:
	name       string
	full_name  string
	logs       string
	tap        string
	path       string
	build_time i64
	core       bool
}

pub struct GistLogsOptions {
pub:
	with_hostname bool
	new_issue     bool
	private       bool
}

// GistLogsEnvironment contains the observable results of Homebrew's system and
// GitHub collaborators. Keeping these effects explicit makes the translated
// command deterministic without weakening any of the source command's branches.
pub struct GistLogsEnvironment {
pub:
	os_version          string
	hostname            string
	config_output       string
	doctor_output       string
	credentials_type    string
	created_gist_url    string
	created_issue_url   string
	create_gist_missing bool
	pat_blurb           string
}

pub struct GistLogsRequest {
pub:
	has_formula        bool
	formula            GistLogsFormula
	options            GistLogsOptions
	environment        GistLogsEnvironment
	preinstall_error   string
	build_source_error string
}

pub struct GistLogsResult {
pub:
	preinstall_checked   bool
	build_source_checked bool
	has_formula          bool
	files                map[string]GistLogFile
	description          string
	private              bool
	gist_url             string
	issue_url            string
	issue_repository     string
	issue_title          string
	output               string
}

@[heap]
pub struct GistLogsInput {
pub:
	request GistLogsRequest
}

pub fn gist_logs_input_boundary(input &GistLogsInput) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::GistLogs::Input', '', {
		'gist_logs_input_address': u64(voidptr(input)).str()
	})
}

fn gist_logs_input_from_value(value ruby.Value) &GistLogsInput {
	address := value.attributes['gist_logs_input_address'] or {
		panic('invalid GistLogs command input')
	}
	return unsafe { &GistLogsInput(voidptr(address.u64())) }
}

// truncate_text_to_approximate_size mirrors the Ruby implementation's byte
// slicing. A split UTF-8 sequence is replaced with U+FFFD by the rune roundtrip,
// matching the source's UTF-8 -> UTF-16 -> UTF-8 repair.
pub fn truncate_text_to_approximate_size(text string, max_bytes int, front_weight f64) !string {
	if front_weight < 0.0 || front_weight > 1.0 {
		return error('opts[:front_weight] must be between 0.0 and 1.0')
	}
	if text.len <= max_bytes {
		return text
	}
	max_bytes_in := if max_bytes - gist_logs_glue.len > 1 {
		max_bytes - gist_logs_glue.len
	} else {
		1
	}
	n_front_bytes := int(f64(max_bytes_in) * front_weight)
	n_back_bytes := max_bytes_in - n_front_bytes
	available_front := if n_front_bytes < text.len { n_front_bytes } else { text.len }
	available_back := if n_back_bytes < text.len { n_back_bytes } else { text.len }
	front := if n_front_bytes == 0 { '' } else { text[..available_front] }
	back := if n_back_bytes == 0 { '' } else { text[text.len - available_back..] }
	combined := front + gist_logs_glue + back
	if utf8.validate_str(combined) {
		return combined
	}
	return combined.runes().string()
}

fn gist_logs_formula_full_name(formula GistLogsFormula) string {
	return if formula.full_name != '' { formula.full_name } else { formula.name }
}

fn gist_logs_build_time(formula GistLogsFormula) time.Time {
	return time.unix(formula.build_time).local()
}

pub fn brief_gist_build_info(formula GistLogsFormula, os_version string, with_hostname bool,
	hostname string) string {
	mut result := 'Homebrew build logs for ${gist_logs_formula_full_name(formula)} on ${os_version}\n'
	if with_hostname {
		result += 'Host: ${hostname}\n'
	}
	result += 'Build date: ${gist_logs_build_time(formula).strftime('%Y-%m-%d %H:%M:%S')}\n'
	return result
}

fn gist_logs_relative_path(path string, basedir string) string {
	normalized_base := basedir.trim_right(os.path_separator)
	prefix := normalized_base + os.path_separator
	relative := if path.starts_with(prefix) { path[prefix.len..] } else { os.file_name(path) }
	return relative.replace(os.path_separator, ':')
}

fn load_gist_logs_into(dir string, basedir string, mut logs map[string]GistLogFile) ! {
	if !os.exists(dir) {
		return
	}
	mut children := os.ls(dir)!
	children.sort()
	for child in children {
		path := os.join_path(dir, child)
		if os.is_dir(path) {
			load_gist_logs_into(path, basedir, mut logs)!
		} else {
			contents := os.read_file(path)!
			log_contents := if contents.len > 0 {
				truncate_text_to_approximate_size(contents, gist_logs_max_file_size, 0.2)!
			} else {
				'empty log'
			}
			logs[gist_logs_relative_path(path, basedir)] = GistLogFile{
				content: log_contents
			}
		}
	}
}

pub fn load_gist_logs(dir string, basedir string) !map[string]GistLogFile {
	mut logs := map[string]GistLogFile{}
	load_gist_logs_into(dir, basedir, mut logs)!
	if logs.len == 0 {
		return error('No logs.')
	}
	return logs
}

pub fn gistify_logs(request GistLogsRequest) !GistLogsResult {
	formula := request.formula
	mut files := load_gist_logs(formula.logs, formula.logs)!
	timestamp := gist_logs_build_time(formula).strftime('%Y-%m-%d_%H-%M-%S')
	files['# ${formula.name} - ${timestamp}.txt'] = GistLogFile{
		content: brief_gist_build_info(formula, request.environment.os_version, request.options.with_hostname, request.environment.hostname)
	}
	files['00.config.out'] = GistLogFile{
		content: request.environment.config_output
	}
	files['00.doctor.out'] = GistLogFile{
		content: request.environment.doctor_output
	}
	if !formula.core {
		files['00.tap.out'] = GistLogFile{
			content: 'Formula: ${formula.name}\n    Tap: ${formula.tap}\n   Path: ${formula.path}\n'
		}
	}
	if request.environment.credentials_type == 'none' {
		return error('`brew gist-logs` requires `\$HOMEBREW_GITHUB_API_TOKEN` to be set!')
	}
	description := if formula.core {
		'${formula.name} on ${request.environment.os_version} - Homebrew build logs'
	} else {
		'${formula.name} (${gist_logs_formula_full_name(formula)}) on ${request.environment.os_version} - Homebrew build logs'
	}
	if request.environment.create_gist_missing {
		return error("Your GitHub API token likely doesn't have the `gist` scope.\n${request.environment.pat_blurb}")
	}
	mut final_url := request.environment.created_gist_url
	mut issue_url := ''
	mut issue_repository := ''
	mut issue_title := ''
	if request.options.new_issue {
		if formula.tap == '' {
			return error('Formula ${formula.name} is not associated with a tap!')
		}
		issue_repository = formula.tap
		issue_title = '${formula.name} failed to build on ${request.environment.os_version}'
		issue_url = request.environment.created_issue_url
		final_url = issue_url
	}
	return GistLogsResult{
		preinstall_checked: true
		build_source_checked: true
		has_formula: true
		files: files
		description: description
		private: request.options.private
		gist_url: request.environment.created_gist_url
		issue_url: issue_url
		issue_repository: issue_repository
		issue_title: issue_title
		output: if final_url != '' { final_url + '\n' } else { '' }
	}
}

pub fn run_gist_logs(request GistLogsRequest) !GistLogsResult {
	if request.preinstall_error != '' {
		return error(request.preinstall_error)
	}
	if request.build_source_error != '' {
		return error(request.build_source_error)
	}
	if !request.has_formula {
		return GistLogsResult{
			preinstall_checked: true
			build_source_checked: true
		}
	}
	return gistify_logs(request)!
}

fn gist_logs_files_value(files map[string]GistLogFile) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, file in files {
		values[name] = ruby.map_value({
			'content': ruby.string_value(file.content)
		})
	}
	return ruby.map_value(values)
}

fn gist_logs_result_value(result GistLogsResult) ruby.Value {
	return ruby.Value{
		type_name: 'Hash'
		repr: result.output
		map_data: {
			'preinstall_checked':   ruby.bool_value(result.preinstall_checked)
			'build_source_checked': ruby.bool_value(result.build_source_checked)
			'has_formula':          ruby.bool_value(result.has_formula)
			'files':                gist_logs_files_value(result.files)
			'description':          ruby.string_value(result.description)
			'private':              ruby.bool_value(result.private)
			'gist_url':             ruby.string_value(result.gist_url)
			'issue_url':            ruby.string_value(result.issue_url)
			'issue_repository':     ruby.string_value(result.issue_repository)
			'issue_title':          ruby.string_value(result.issue_title)
			'output':               ruby.string_value(result.output)
		}
	}
}

fn gist_logs_error_value(message string) ruby.Value {
	return ruby.object_value('SystemExit', message)
}
