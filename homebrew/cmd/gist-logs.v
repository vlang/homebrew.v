module cmd

import ruby
import encoding.utf8
import os
import time

// Translated from Homebrew/brew `cmd/gist-logs.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `run` at line 35.
pub fn ruby_gist_logs_l35_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	result := run_gist_logs(gist_logs_input_from_value(args[0]).request) or {
		return gist_logs_error_value(err.msg())
	}
	return gist_logs_result_value(result)
}

// Ruby method `self.truncate_text_to_approximate_size(str, max_bytes, options = {})` at line 48.
pub fn ruby_gist_logs_l48_d2_self_truncate_text_to_approximate_size(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'text and max_bytes are required')
	}
	max_bytes := args[1].as_int() or { return ruby.object_value('TypeError', err.msg()) }
	front_weight := if args.len > 2 {
		args[2].as_float() or {
			return ruby.object_value('TypeError', err.msg())
		}
	} else {
		0.5
	}
	result := truncate_text_to_approximate_size(args[0].as_string(), int(max_bytes), front_weight) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.string_value(result)
}

// Ruby method `gistify_logs(formula)` at line 79.
pub fn ruby_gist_logs_l79_d3_gistify_logs(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	result := gistify_logs(gist_logs_input_from_value(args[0]).request) or {
		return gist_logs_error_value(err.msg())
	}
	return gist_logs_result_value(result)
}

// Ruby method `brief_build_info(formula, with_hostname:)` at line 131.
pub fn ruby_gist_logs_l131_d4_brief_build_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	request := gist_logs_input_from_value(args[0]).request
	return ruby.string_value(brief_gist_build_info(request.formula, request.environment.os_version, request.options.with_hostname, request.environment.hostname))
}

// Ruby method `load_logs(dir, basedir = dir)` at line 145.
pub fn ruby_gist_logs_l145_d5_load_logs(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'log directory is required')
	}
	dir := args[0].as_string()
	basedir := if args.len > 1 { args[1].as_string() } else { dir }
	logs := load_gist_logs(dir, basedir) or { return gist_logs_error_value(err.msg()) }
	return gist_logs_files_value(logs)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "install"
// 7: require "system_config"
// 8: require "stringio"
// 9: require "socket"
// 10:
// 11: module Homebrew
// 12:   module Cmd
// 13:     class GistLogs < AbstractCommand
// 14:       include Install
// 15:
// 16:       cmd_args do
// 17:         description <<~EOS
// 18:           Upload logs for a failed build of <formula> to a new Gist. Presents an
// 19:           error message if no logs are found.
// 20:         EOS
// 21:         switch "--with-hostname",
// 22:                description: "Include the hostname in the Gist.",
// 23:                odeprecated: true
// 24:         switch "-n", "--new-issue",
// 25:                description: "Automatically create a new issue in the appropriate GitHub repository " \
// 26:                             "after creating the Gist."
// 27:         switch "-p", "--private",
// 28:                description: "The Gist will be marked private and will not appear in listings but will " \
// 29:                             "be accessible with its link."
// 30:
// 31:         named_args :formula, number: 1
// 32:       end
// 33:
// 34:       sig { override.void }
// 35:       def run
// 36:         Install.perform_preinstall_checks_once(all_fatal: true)
// 37:         Install.perform_build_from_source_checks(all_fatal: true)
// 38:         return unless (formula = args.named.to_resolved_formulae.first)
// 39:
// 40:         gistify_logs(formula)
// 41:       end
// 42:
// 43:       # Truncates a text string to fit within a byte size constraint,
// 44:       # preserving character encoding validity. The returned string will
// 45:       # be not much longer than the specified max_bytes, though the exact
// 46:       # shortfall or overrun may vary.
// 47:       sig { params(str: String, max_bytes: Integer, options: T::Hash[Symbol, T.untyped]).returns(String) }
// 48:       def self.truncate_text_to_approximate_size(str, max_bytes, options = {})
// 49:         front_weight = options.fetch(:front_weight, 0.5)
// 50:         raise "opts[:front_weight] must be between 0.0 and 1.0" if front_weight < 0.0 || front_weight > 1.0
// 51:         return str if str.bytesize <= max_bytes
// 52:
// 53:         glue = "\n[...snip...]\n"
// 54:         max_bytes_in = [max_bytes - glue.bytesize, 1].max
// 55:         bytes = str.dup.force_encoding("BINARY")
// 56:         glue_bytes = glue.encode("BINARY")
// 57:         n_front_bytes = (max_bytes_in * front_weight).floor
// 58:         n_back_bytes = max_bytes_in - n_front_bytes
// 59:         if n_front_bytes.zero?
// 60:           front = bytes[1..0]
// 61:           back = bytes[-max_bytes_in..]
// 62:         elsif n_back_bytes.zero?
// 63:           front = bytes[0..(max_bytes_in - 1)]
// 64:           back = bytes[1..0]
// 65:         else
// 66:           front = bytes[0..(n_front_bytes - 1)]
// 67:           back = bytes[-n_back_bytes..]
// 68:         end
// 69:         out = T.must(front) + glue_bytes + T.must(back)
// 70:         out.force_encoding("UTF-8")
// 71:         out.encode!("UTF-16", invalid: :replace)
// 72:         out.encode!("UTF-8")
// 73:         out
// 74:       end
// 75:
// 76:       private
// 77:
// 78:       sig { params(formula: Formula).void }
// 79:       def gistify_logs(formula)
// 80:         files = load_logs(formula.logs)
// 81:         build_time = formula.logs.ctime
// 82:         timestamp = build_time.strftime("%Y-%m-%d_%H-%M-%S")
// 83:
// 84:         s = StringIO.new
// 85:         SystemConfig.dump_verbose_config s
// 86:         # Dummy summary file, asciibetically first, to control display title of gist
// 87:         files["# #{formula.name} - #{timestamp}.txt"] = {
// 88:           content: brief_build_info(formula, with_hostname: args.with_hostname?),
// 89:         }
// 90:         files["00.config.out"] = { content: s.string }
// 91:         files["00.doctor.out"] = { content: Utils.popen_read("#{HOMEBREW_PREFIX}/bin/brew", "doctor", err: :out) }
// 92:         unless formula.core_formula?
// 93:           tap = <<~EOS
// 94:             Formula: #{formula.name}
// 95:                 Tap: #{formula.tap}
// 96:                Path: #{formula.path}
// 97:           EOS
// 98:           files["00.tap.out"] = { content: tap }
// 99:         end
// 100:
// 101:         if GitHub::API.credentials_type == :none
// 102:           odie "`brew gist-logs` requires `$HOMEBREW_GITHUB_API_TOKEN` to be set!"
// 103:         end
// 104:
// 105:         # Description formatted to work well as page title when viewing gist
// 106:         descr = if formula.core_formula?
// 107:           "#{formula.name} on #{OS_VERSION} - Homebrew build logs"
// 108:         else
// 109:           "#{formula.name} (#{formula.full_name}) on #{OS_VERSION} - Homebrew build logs"
// 110:         end
// 111:
// 112:         begin
// 113:           url = GitHub.create_gist(files, descr, private: args.private?)
// 114:         rescue GitHub::API::HTTPNotFoundError
// 115:           odie <<~EOS
// 116:             Your GitHub API token likely doesn't have the `gist` scope.
// 117:             #{GitHub.pat_blurb(GitHub::CREATE_GIST_SCOPES)}
// 118:           EOS
// 119:         end
// 120:
// 121:         if args.new_issue?
// 122:           tap = formula.tap
// 123:           odie "Formula #{formula.name} is not associated with a tap!" unless tap
// 124:           url = GitHub.create_issue(tap.full_name, "#{formula.name} failed to build on #{OS_VERSION}", url)
// 125:         end
// 126:
// 127:         puts url if url
// 128:       end
// 129:
// 130:       sig { params(formula: Formula, with_hostname: T::Boolean).returns(String) }
// 131:       def brief_build_info(formula, with_hostname:)
// 132:         build_time_string = formula.logs.ctime.strftime("%Y-%m-%d %H:%M:%S")
// 133:         string = <<~EOS
// 134:           Homebrew build logs for #{formula.full_name} on #{OS_VERSION}
// 135:         EOS
// 136:         if with_hostname
// 137:           hostname = Socket.gethostname
// 138:           string << "Host: #{hostname}\n"
// 139:         end
// 140:         string << "Build date: #{build_time_string}\n"
// 141:         string.freeze
// 142:       end
// 143:
// 144:       sig { params(dir: Pathname, basedir: Pathname).returns(T::Hash[String, { content: String }]) }
// 145:       def load_logs(dir, basedir = dir)
// 146:         logs = {}
// 147:         if dir.exist?
// 148:           dir.children.sort.each do |file|
// 149:             if file.directory?
// 150:               logs.merge! load_logs(file, basedir)
// 151:             else
// 152:               contents = file.size? ? file.read : "empty log"
// 153:               # small enough to avoid GitHub "unicorn" page-load-timeout errors
// 154:               max_file_size = 1_000_000
// 155:               contents = GistLogs.truncate_text_to_approximate_size(contents, max_file_size, front_weight: 0.2)
// 156:               logs[file.relative_path_from(basedir).to_s.tr("/", ":")] = { content: contents }
// 157:             end
// 158:           end
// 159:         end
// 160:         odie "No logs." if logs.empty?
// 161:
// 162:         logs
// 163:       end
// 164:     end
// 165:   end
// 166: end
