module subcommand

import ruby
import x.json2

// Translated from Homebrew/brew `services/subcommand/list.rb`.
pub struct ServiceListStyle {
pub:
	bold          string
	reset         string
	green         string
	default_color string
	red           string
	yellow        string
}

pub struct ServiceListFormula {
pub:
	name         string
	status       string
	user         string
	user_present bool
	user_nil     bool
	file         string
	file_present bool
	file_nil     bool
	exit_code    int
	exit_present bool
	exit_nil     bool
	loaded       bool
}

pub struct ServiceListRequest {
pub:
	formulae    []ServiceListFormula
	json        bool
	stderr_tty  bool
	service_bin string = 'brew services'
	home        string
	style       ServiceListStyle
}

pub struct ServiceListResult {
pub:
	stdout string
	stderr string
}

fn service_list_field(value string, width int) string {
	trimmed := if value.len > width { value[..width] } else { value }
	return trimmed + ' '.repeat(width - trimmed.len)
}

fn service_list_maximum(values []int, minimum int) int {
	mut maximum := minimum
	for value in values {
		if value > maximum {
			maximum = value
		}
	}
	return maximum
}

pub fn service_list_get_status_string(status string, style ServiceListStyle) !string {
	return match status {
		'started', 'scheduled' { '${style.green}${status}${style.reset}' }
		'stopped', 'none' { '${style.default_color}${status}${style.reset}' }
		'error' { '${style.red}error  ${style.reset}' }
		'unknown' { '${style.yellow}unknown${style.reset}' }
		'other' { '${style.yellow}other${style.reset}' }
		else { error('unknown service status `${status}`') }
	}
}

fn service_list_formula_json(formula ServiceListFormula) json2.Any {
	mut fields := map[string]json2.Any{}
	fields['name'] = json2.Any(formula.name)
	fields['status'] = json2.Any(formula.status)
	if formula.user_present {
		fields['user'] = if formula.user_nil { json2.null } else { json2.Any(formula.user) }
	}
	if formula.file_present {
		fields['file'] = if formula.file_nil { json2.null } else { json2.Any(formula.file) }
	}
	if formula.exit_present {
		fields['exit_code'] = if formula.exit_nil {
			json2.null
		} else {
			json2.Any(formula.exit_code)
		}
	}
	return json2.Any(fields)
}

pub fn service_list_print_json(formulae []ServiceListFormula) string {
	services := formulae.map(service_list_formula_json(it))
	encoded := json2.encode(json2.Any(services), prettify: true)
	// Ruby's JSON.pretty_generate indents by two spaces; json2 uses four.
	mut lines := []string{cap: encoded.count('\n') + 1}
	for line in encoded.split('\n') {
		content := line.trim_left(' ')
		indent := line.len - content.len
		lines << ' '.repeat(indent / 2) + content
	}
	return '${lines.join('\n')}\n'
}

pub fn service_list_print_table(formulae []ServiceListFormula, home string,
	style ServiceListStyle) !string {
	mut names := []string{cap: formulae.len}
	mut statuses := []string{cap: formulae.len}
	mut users := []string{cap: formulae.len}
	mut files := []string{cap: formulae.len}
	for formula in formulae {
		mut status := service_list_get_status_string(formula.status, style)!
		if formula.status == 'error' && formula.exit_present && !formula.exit_nil {
			status += formula.exit_code.str()
		}
		file := if formula.loaded {
			formula.file.replace(home, '~')
		} else {
			''
		}
		names << formula.name
		statuses << status
		users << formula.user
		files << file
	}

	longest_name := service_list_maximum(names.map(it.len), 4)
	longest_status := service_list_maximum(statuses.map(it.len), 15)
	longest_user := service_list_maximum(users.map(it.len), 4)

	// `longest_status` includes 9 color characters from `Tty.color` and `Tty.reset`.
	// We don't have these in the header row, so we don't need to add the extra padding.
	mut output := '${style.bold}${service_list_field('Name', longest_name)} ${service_list_field('Status', longest_status - 9)} ${service_list_field('User', longest_user)} File${style.reset}\n'
	for index, name in names {
		output += '${service_list_field(name, longest_name)} ${service_list_field(statuses[index], longest_status)} ${service_list_field(users[index], longest_user)} ${files[index]}\n'
	}
	return output
}

pub fn run_service_list(request ServiceListRequest) !ServiceListResult {
	if request.formulae.len == 0 {
		service_bin := if request.service_bin == '' { 'brew services' } else { request.service_bin }
		return ServiceListResult{
			stdout: if request.json { '[]\n' } else { '' }
			stderr: if request.stderr_tty {
				'Warning: No services available to control with `${service_bin}`\n'
			} else {
				''
			}
		}
	}
	return ServiceListResult{
		stdout: if request.json {
			service_list_print_json(request.formulae)
		} else {
			service_list_print_table(request.formulae, request.home, request.style)!
		}
	}
}

pub fn service_list_formula_value(formula ServiceListFormula) ruby.Value {
	mut fields := map[string]ruby.Value{}
	fields['name'] = ruby.string_value(formula.name)
	fields['status'] = ruby.object_value('Symbol', formula.status)
	if formula.user_present {
		fields['user'] = if formula.user_nil {
			ruby.object_value('NilClass', '')
		} else {
			ruby.string_value(formula.user)
		}
	}
	if formula.file_present {
		fields['file'] = if formula.file_nil {
			ruby.object_value('NilClass', '')
		} else {
			ruby.object_value('Pathname', formula.file)
		}
	}
	if formula.exit_present {
		fields['exit_code'] = if formula.exit_nil {
			ruby.object_value('NilClass', '')
		} else {
			ruby.int_value(formula.exit_code)
		}
	}
	fields['loaded'] = ruby.bool_value(formula.loaded)
	return ruby.map_value(fields)
}

fn service_list_formula_from_value(value ruby.Value) !ServiceListFormula {
	fields := value.as_map()!
	user_value := fields['user'] or { ruby.Value{} }
	file_value := fields['file'] or { ruby.Value{} }
	exit_value := fields['exit_code'] or { ruby.Value{} }
	return ServiceListFormula{
		name: (fields['name'] or { ruby.string_value('') }).as_string()
		status: (fields['status'] or { ruby.object_value('Symbol', 'unknown') }).as_string()
		user: user_value.as_string()
		user_present: 'user' in fields
		user_nil: user_value.type_name == 'NilClass'
		file: file_value.as_string()
		file_present: 'file' in fields
		file_nil: file_value.type_name == 'NilClass'
		exit_code: int(exit_value.as_int() or { 0 })
		exit_present: 'exit_code' in fields
		exit_nil: exit_value.type_name == 'NilClass'
		loaded: (fields['loaded'] or { ruby.bool_value(false) }).as_bool() or { false }
	}
}

fn service_list_formulae_from_value(value ruby.Value) ![]ServiceListFormula {
	return value.as_array()!.map(service_list_formula_from_value(it)!)
}

fn service_list_result_value(result ServiceListResult) ruby.Value {
	return ruby.map_value({
		'stdout': ruby.string_value(result.stdout)
		'stderr': ruby.string_value(result.stderr)
	})
}
