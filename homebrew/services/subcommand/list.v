module subcommand

import brew_runtime
import x.json2

// Translated from Homebrew/brew `services/subcommand/list.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn service_list_formula_value(formula ServiceListFormula) brew_runtime.Value {
	mut fields := map[string]brew_runtime.Value{}
	fields['name'] = brew_runtime.string_value(formula.name)
	fields['status'] = brew_runtime.object_value('Symbol', formula.status)
	if formula.user_present {
		fields['user'] = if formula.user_nil {
			brew_runtime.object_value('NilClass', '')
		} else {
			brew_runtime.string_value(formula.user)
		}
	}
	if formula.file_present {
		fields['file'] = if formula.file_nil {
			brew_runtime.object_value('NilClass', '')
		} else {
			brew_runtime.object_value('Pathname', formula.file)
		}
	}
	if formula.exit_present {
		fields['exit_code'] = if formula.exit_nil {
			brew_runtime.object_value('NilClass', '')
		} else {
			brew_runtime.int_value(formula.exit_code)
		}
	}
	fields['loaded'] = brew_runtime.bool_value(formula.loaded)
	return brew_runtime.map_value(fields)
}

fn service_list_formula_from_value(value brew_runtime.Value) !ServiceListFormula {
	fields := value.as_map()!
	user_value := fields['user'] or { brew_runtime.Value{} }
	file_value := fields['file'] or { brew_runtime.Value{} }
	exit_value := fields['exit_code'] or { brew_runtime.Value{} }
	return ServiceListFormula{
		name: (fields['name'] or { brew_runtime.string_value('') }).as_string()
		status: (fields['status'] or { brew_runtime.object_value('Symbol', 'unknown') }).as_string()
		user: user_value.as_string()
		user_present: 'user' in fields
		user_nil: user_value.type_name == 'NilClass'
		file: file_value.as_string()
		file_present: 'file' in fields
		file_nil: file_value.type_name == 'NilClass'
		exit_code: int(exit_value.as_int() or { 0 })
		exit_present: 'exit_code' in fields
		exit_nil: exit_value.type_name == 'NilClass'
		loaded: (fields['loaded'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
	}
}

fn service_list_formulae_from_value(value brew_runtime.Value) ![]ServiceListFormula {
	return value.as_array()!.map(service_list_formula_from_value(it)!)
}

fn service_list_result_value(result ServiceListResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'stdout': brew_runtime.string_value(result.stdout)
		'stderr': brew_runtime.string_value(result.stderr)
	})
}

// Ruby method `run` at line 25.
pub fn ruby_list_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	request_values := if args.len > 0 {
		args[0].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	formulae := service_list_formulae_from_value(request_values['formulae'] or {
		brew_runtime.array_value([]brew_runtime.Value{})
	}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	request := ServiceListRequest{
		formulae: formulae
		json: (request_values['json'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
		stderr_tty: (request_values['stderr_tty'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
		service_bin: (request_values['service_bin'] or { brew_runtime.string_value('brew services') }).as_string()
		home: (request_values['home'] or { brew_runtime.string_value(brew_runtime.environment_value('HOME')) }).as_string()
	}
	result := run_service_list(request) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return service_list_result_value(result)
}

// Ruby method `self.print_json(formulae)` at line 47.
pub fn ruby_list_l47_d2_self_print_json(args ...brew_runtime.Value) brew_runtime.Value {
	formulae := service_list_formulae_from_value(if args.len > 0 {
		args[0]
	} else {
		brew_runtime.array_value([]brew_runtime.Value{})
	}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	return brew_runtime.string_value(service_list_print_json(formulae))
}

// Ruby method `self.print_table(formulae)` at line 58.
pub fn ruby_list_l58_d3_self_print_table(args ...brew_runtime.Value) brew_runtime.Value {
	formulae := service_list_formulae_from_value(if args.len > 0 {
		args[0]
	} else {
		brew_runtime.array_value([]brew_runtime.Value{})
	}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	home := if args.len > 1 { args[1].as_string() } else { brew_runtime.environment_value('HOME') }
	output := service_list_print_table(formulae, home, ServiceListStyle{}) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(output)
}

// Ruby method `self.get_status_string(status)` at line 89.
pub fn ruby_list_l89_d4_self_get_status_string(args ...brew_runtime.Value) brew_runtime.Value {
	status := if args.len > 0 { args[0].as_string() } else { '' }
	value := service_list_get_status_string(status, ServiceListStyle{}) or {
		return brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.string_value(value)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: require "services/cli"
// 7: require "services/formulae"
// 8: require "utils/output"
// 9: module Homebrew
// 10:   module Cmd
// 11:     class Services < Homebrew::AbstractCommand
// 12:       class ListSubcommand < Homebrew::AbstractSubcommand
// 13:         subcommand_args aliases: ["ls"], default: true do
// 14:           usage_banner <<~EOS
// 15:             [`sudo`] `brew services` [`list`] [`--json`] [`--debug`]:
// 16:             List information about all managed services for the current user (or root).
// 17:             Provides more output from Homebrew and `launchctl`(1) or `systemctl`(1) if run with `--debug`.
// 18:           EOS
// 19:           named_args :none
// 20:           switch "--json",
// 21:                  description: "Output as JSON."
// 22:         end
// 23:
// 24:         sig { override.void }
// 25:         def run
// 26:           formulae = Homebrew::Services::Formulae.services_list
// 27:           if formulae.blank?
// 28:             opoo "No services available to control with `#{Homebrew::Services::Cli.bin}`" if $stderr.tty?
// 29:             puts "[]" if args.json?
// 30:             return
// 31:           end
// 32:
// 33:           if args.json?
// 34:             self.class.print_json(formulae)
// 35:           else
// 36:             self.class.print_table(formulae)
// 37:           end
// 38:         end
// 39:
// 40:         extend Utils::Output::Mixin
// 41:
// 42:         JSON_FIELDS = [:name, :status, :user, :file, :exit_code].freeze
// 43:
// 44:         # Print the JSON representation in the CLI
// 45:         # @private
// 46:         sig { params(formulae: T::Array[T::Hash[Symbol, T.untyped]]).void }
// 47:         def self.print_json(formulae)
// 48:           services = formulae.map do |formula|
// 49:             formula.slice(*JSON_FIELDS)
// 50:           end
// 51:
// 52:           puts JSON.pretty_generate(services)
// 53:         end
// 54:
// 55:         # Print the table in the CLI
// 56:         # @private
// 57:         sig { params(formulae: T::Array[T::Hash[Symbol, T.untyped]]).void }
// 58:         def self.print_table(formulae)
// 59:           services = formulae.map do |formula|
// 60:             status = T.must(get_status_string(formula[:status]))
// 61:             status += formula[:exit_code].to_s if formula[:status] == :error
// 62:             file    = formula[:file].to_s.gsub(Dir.home, "~").presence if formula[:loaded]
// 63:
// 64:             { name: formula[:name], status:, user: formula[:user], file: }
// 65:           end
// 66:
// 67:           longest_name = [*services.map { |service| service[:name].length }, 4].max
// 68:           longest_status = [*services.map { |service| service[:status].length }, 15].max
// 69:           longest_user = [*services.map { |service| service[:user]&.length }, 4].compact.max
// 70:
// 71:           # `longest_status` includes 9 color characters from `Tty.color` and `Tty.reset`.
// 72:           # We don't have these in the header row, so we don't need to add the extra padding.
// 73:           headers = "#{Tty.bold}%-#{longest_name}.#{longest_name}<name>s " \
// 74:                     "%-#{longest_status - 9}.#{longest_status - 9}<status>s " \
// 75:                     "%-#{longest_user}.#{longest_user}<user>s %<file>s#{Tty.reset}"
// 76:           row = "%-#{longest_name}.#{longest_name}<name>s " \
// 77:                 "%-#{longest_status}.#{longest_status}<status>s " \
// 78:                 "%-#{longest_user}.#{longest_user}<user>s %<file>s"
// 79:
// 80:           puts format(headers, name: "Name", status: "Status", user: "User", file: "File")
// 81:           services.each do |service|
// 82:             puts format(row, **service)
// 83:           end
// 84:         end
// 85:
// 86:         # Get formula status output
// 87:         # @private
// 88:         sig { params(status: Symbol).returns(T.nilable(String)) }
// 89:         def self.get_status_string(status)
// 90:           case status
// 91:           when :started, :scheduled then "#{Tty.green}#{status}#{Tty.reset}"
// 92:           when :stopped, :none then "#{Tty.default}#{status}#{Tty.reset}"
// 93:           when :error   then "#{Tty.red}error  #{Tty.reset}"
// 94:           when :unknown then "#{Tty.yellow}unknown#{Tty.reset}"
// 95:           when :other then "#{Tty.yellow}other#{Tty.reset}"
// 96:           end
// 97:         end
// 98:       end
// 99:     end
// 100:   end
// 101: end
