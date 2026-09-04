module subcommand

import ruby
import homebrew.services as services_cli
import x.json2

// Translated from Homebrew/brew `services/subcommand/info.rb`.
pub struct ServiceInfoStyle {
pub:
	bold          string
	reset         string
	success       string
	success_reset string
	failure       string
	failure_reset string
}

pub struct ServiceInfoRequest {
pub:
	targets  []map[string]ruby.Value
	json     bool
	verbose  bool
	tty      bool
	no_emoji bool
	style    ServiceInfoStyle
}

fn service_info_value_to_json(value ruby.Value) json2.Any {
	return match value.type_name {
		'Bool' { json2.Any(value.bool_data) }
		'Integer' { json2.Any(value.int_data) }
		'Float' { json2.Any(value.float_data) }
		'Array' {
			mut values := []json2.Any{}
			for item in value.as_array() or { []ruby.Value{} } {
				values << service_info_value_to_json(item)
			}
			json2.Any(values)
		}
		'Hash' {
			mut values := map[string]json2.Any{}
			for key, item in value.map_data {
				values[key] = service_info_value_to_json(item)
			}
			json2.Any(values)
		}
		'NilClass' { json2.null }
		else { json2.Any(value.as_string()) }
	}
}

fn service_info_pretty_json(targets []map[string]ruby.Value) string {
	mut values := []json2.Any{cap: targets.len}
	for target in targets {
		values << service_info_value_to_json(ruby.map_value(target))
	}
	encoded := json2.encode(json2.Any(values), prettify: true)
	// Ruby's JSON.pretty_generate indents by two spaces; json2 uses four.
	mut lines := []string{cap: encoded.count('\n') + 1}
	for line in encoded.split('\n') {
		content := line.trim_left(' ')
		indent := line.len - content.len
		lines << ' '.repeat(indent / 2) + content
	}
	return '${lines.join('\n')}\n'
}

fn service_info_to_s(value ruby.Value) string {
	return match value.type_name {
		'NilClass', '' { '' }
		'Bool' { value.bool_data.str() }
		else { value.as_string() }
	}
}

fn service_info_truthy(value ruby.Value) bool {
	if value.type_name == 'NilClass' || value.type_name == '' {
		return false
	}
	if value.type_name == 'Bool' {
		return value.bool_data
	}
	return true
}

fn service_info_present(value ruby.Value) bool {
	return match value.type_name {
		'NilClass', '' { false }
		'Bool' { value.bool_data }
		'String' { value.as_string() != '' }
		'Array' { (value.as_array() or { []ruby.Value{} }).len > 0 }
		'Hash' { value.map_data.len > 0 }
		else { true }
	}
}

pub fn service_info_pretty_bool(value ruby.Value, tty bool, no_emoji bool,
	style ServiceInfoStyle) string {
	if !tty || no_emoji {
		return service_info_to_s(value)
	}
	mark := if service_info_truthy(value) {
		'${style.success}✔${style.success_reset}'
	} else {
		'${style.failure}✘${style.failure_reset}'
	}
	return '${style.bold}${mark}${style.reset}'
}

fn service_info_field(hash map[string]ruby.Value, name string) ruby.Value {
	return hash[name] or { ruby.object_value('NilClass', '') }
}

fn service_info_non_nil(hash map[string]ruby.Value, name string) bool {
	value := service_info_field(hash, name)
	return value.type_name != 'NilClass' && value.type_name != ''
}

pub fn service_info_output(hash map[string]ruby.Value, verbose bool,
	tty bool, no_emoji bool, style ServiceInfoStyle) string {
	mut output := '${style.bold}${service_info_field(hash, 'name').as_string()}${style.reset} (${service_info_field(hash, 'service_name').as_string()})\n'
	output += 'Running: ${service_info_pretty_bool(service_info_field(hash, 'running'), tty, no_emoji, style)}\n'
	output += 'Loaded: ${service_info_pretty_bool(service_info_field(hash, 'loaded'), tty, no_emoji, style)}\n'
	output += 'Schedulable: ${service_info_pretty_bool(service_info_field(hash, 'schedulable'), tty, no_emoji, style)}\n'
	if service_info_non_nil(hash, 'pid') {
		output += 'User: ${service_info_field(hash, 'user').as_string()}\n'
		output += 'PID: ${service_info_to_s(service_info_field(hash, 'pid'))}\n'
	}
	if !verbose {
		return output
	}

	file := service_info_field(hash, 'file')
	output += 'File: ${file.as_string()} ${service_info_pretty_bool(ruby.bool_value(service_info_present(file)), tty, no_emoji, style)}\n'
	output += 'Registered at login: ${service_info_pretty_bool(service_info_field(hash, 'registered'), tty, no_emoji, style)}\n'
	for field, label in {
		'command':        'Command'
		'working_dir':    'Working directory'
		'root_dir':       'Root directory'
		'log_path':       'Log'
		'error_log_path': 'Error log'
	} {
		if service_info_non_nil(hash, field) {
			output += '${label}: ${service_info_field(hash, field).as_string()}\n'
		}
	}
	if service_info_non_nil(hash, 'interval') {
		output += 'Interval: ${service_info_to_s(service_info_field(hash, 'interval'))}s\n'
	}
	if service_info_non_nil(hash, 'cron') {
		output += 'Cron: ${service_info_field(hash, 'cron').as_string()}\n'
	}
	return output
}

pub fn run_service_info(request ServiceInfoRequest) !string {
	services_cli.cli_check([]services_cli.CliService{len: request.targets.len})!
	if request.json {
		return service_info_pretty_json(request.targets)
	}
	mut output := ''
	for target in request.targets {
		output += service_info_output(target, request.verbose, request.tty, request.no_emoji, request.style)
	}
	return output
}

pub fn service_info_target_value(target map[string]ruby.Value) ruby.Value {
	return ruby.map_value(target)
}

fn service_info_targets_from_value(value ruby.Value) ![]map[string]ruby.Value {
	mut targets := []map[string]ruby.Value{}
	for item in value.as_array()! {
		targets << item.as_map()!
	}
	return targets
}

fn service_info_tty(request map[string]ruby.Value, key string) bool {
	if value := request[key] {
		return value.as_bool() or { false }
	}
	return ruby.stdout_is_terminal()
}
