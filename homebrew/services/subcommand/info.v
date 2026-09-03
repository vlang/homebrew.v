module subcommand

import brew_runtime
import homebrew.services as services_cli
import x.json2

// Translated from Homebrew/brew `services/subcommand/info.rb`.
// The original source is retained below until every stub has a typed V body.
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
	targets  []map[string]brew_runtime.Value
	json     bool
	verbose  bool
	tty      bool
	no_emoji bool
	style    ServiceInfoStyle
}

fn service_info_value_to_json(value brew_runtime.Value) json2.Any {
	return match value.type_name {
		'Bool' { json2.Any(value.bool_data) }
		'Integer' { json2.Any(value.int_data) }
		'Float' { json2.Any(value.float_data) }
		'Array' {
			mut values := []json2.Any{}
			for item in value.as_array() or { []brew_runtime.Value{} } {
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

fn service_info_pretty_json(targets []map[string]brew_runtime.Value) string {
	mut values := []json2.Any{cap: targets.len}
	for target in targets {
		values << service_info_value_to_json(brew_runtime.map_value(target))
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

fn service_info_to_s(value brew_runtime.Value) string {
	return match value.type_name {
		'NilClass', '' { '' }
		'Bool' { value.bool_data.str() }
		else { value.as_string() }
	}
}

fn service_info_truthy(value brew_runtime.Value) bool {
	if value.type_name == 'NilClass' || value.type_name == '' {
		return false
	}
	if value.type_name == 'Bool' {
		return value.bool_data
	}
	return true
}

fn service_info_present(value brew_runtime.Value) bool {
	return match value.type_name {
		'NilClass', '' { false }
		'Bool' { value.bool_data }
		'String' { value.as_string() != '' }
		'Array' { (value.as_array() or { []brew_runtime.Value{} }).len > 0 }
		'Hash' { value.map_data.len > 0 }
		else { true }
	}
}

pub fn service_info_pretty_bool(value brew_runtime.Value, tty bool, no_emoji bool,
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

fn service_info_field(hash map[string]brew_runtime.Value, name string) brew_runtime.Value {
	return hash[name] or { brew_runtime.object_value('NilClass', '') }
}

fn service_info_non_nil(hash map[string]brew_runtime.Value, name string) bool {
	value := service_info_field(hash, name)
	return value.type_name != 'NilClass' && value.type_name != ''
}

pub fn service_info_output(hash map[string]brew_runtime.Value, verbose bool,
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
	output += 'File: ${file.as_string()} ${service_info_pretty_bool(brew_runtime.bool_value(service_info_present(file)), tty, no_emoji, style)}\n'
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
	services_cli.ruby_cli_l48_d5_self_check([]services_cli.CliService{len: request.targets.len})!
	if request.json {
		return service_info_pretty_json(request.targets)
	}
	mut output := ''
	for target in request.targets {
		output += service_info_output(target, request.verbose, request.tty, request.no_emoji, request.style)
	}
	return output
}

pub fn service_info_target_value(target map[string]brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.map_value(target)
}

fn service_info_targets_from_value(value brew_runtime.Value) ![]map[string]brew_runtime.Value {
	mut targets := []map[string]brew_runtime.Value{}
	for item in value.as_array()! {
		targets << item.as_map()!
	}
	return targets
}

fn service_info_tty(request map[string]brew_runtime.Value, key string) bool {
	if value := request[key] {
		return value.as_bool() or { false }
	}
	return brew_runtime.stdout_is_terminal()
}

// Ruby method `run` at line 24.
pub fn ruby_info_l24_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	request := if args.len > 0 {
		args[0].as_map() or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	} else {
		map[string]brew_runtime.Value{}
	}
	targets := service_info_targets_from_value(request['targets'] or {
		brew_runtime.array_value([]brew_runtime.Value{})
	}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	result := run_service_info(ServiceInfoRequest{
		targets: targets
		json: (request['json'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
		verbose: (request['verbose'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
		tty: service_info_tty(request, 'stdout_tty')
		no_emoji: (request['no_emoji'] or {
			brew_runtime.bool_value(brew_runtime.environment_value('HOMEBREW_NO_EMOJI') != '')
		}).as_bool() or { false }
	}) or { return brew_runtime.object_value('UsageError', err.msg()) }
	return brew_runtime.string_value(result)
}

// Ruby method `self.pretty_bool(bool)` at line 40.
pub fn ruby_info_l40_d2_self_pretty_bool(args ...brew_runtime.Value) brew_runtime.Value {
	value := if args.len > 0 { args[0] } else { brew_runtime.object_value('NilClass', '') }
	mut request := map[string]brew_runtime.Value{}
	if args.len > 1 {
		request['stdout_tty'] = args[1]
	}
	no_emoji := if args.len > 2 {
		args[2].as_bool() or { false }
	} else {
		brew_runtime.environment_value('HOMEBREW_NO_EMOJI') != ''
	}
	return brew_runtime.string_value(service_info_pretty_bool(value, service_info_tty(request, 'stdout_tty'), no_emoji, ServiceInfoStyle{}))
}

// Ruby method `self.output(hash, verbose:)` at line 51.
pub fn ruby_info_l51_d3_self_output(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'self.output requires a hash')
	}
	hash := args[0].as_map() or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	verbose := args.len > 1 && (args[1].as_bool() or { false })
	mut request := map[string]brew_runtime.Value{}
	if args.len > 2 {
		request['stdout_tty'] = args[2]
	}
	no_emoji := if args.len > 3 {
		args[3].as_bool() or { false }
	} else {
		brew_runtime.environment_value('HOMEBREW_NO_EMOJI') != ''
	}
	return brew_runtime.string_value(service_info_output(hash, verbose, service_info_tty(request, 'stdout_tty'), no_emoji, ServiceInfoStyle{}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: require "services/cli"
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Services < Homebrew::AbstractCommand
// 10:       class InfoSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args aliases: ["i"] do
// 12:           usage_banner <<~EOS
// 13:             [`sudo`] `brew services info` (<formula>|`--all`) [`--json`]:
// 14:             List all managed services for the current user (or root).
// 15:           EOS
// 16:           named_args :service
// 17:           switch "--all",
// 18:                  description: "List all managed services."
// 19:           switch "--json",
// 20:                  description: "Output as JSON."
// 21:         end
// 22:
// 23:         sig { override.void }
// 24:         def run
// 25:           Homebrew::Services::Cli.check!(targets)
// 26:
// 27:           output = targets.map(&:to_hash)
// 28:
// 29:           if args.json?
// 30:             puts JSON.pretty_generate(output)
// 31:             return
// 32:           end
// 33:
// 34:           output.each do |hash|
// 35:             puts self.class.output(hash, verbose: args.verbose?)
// 36:           end
// 37:         end
// 38:
// 39:         sig { params(bool: T.nilable(T.any(String, T::Boolean))).returns(String) }
// 40:         def self.pretty_bool(bool)
// 41:           return bool.to_s if !$stdout.tty? || Homebrew::EnvConfig.no_emoji?
// 42:
// 43:           if bool
// 44:             "#{Tty.bold}#{Formatter.success("✔")}#{Tty.reset}"
// 45:           else
// 46:             "#{Tty.bold}#{Formatter.error("✘")}#{Tty.reset}"
// 47:           end
// 48:         end
// 49:
// 50:         sig { params(hash: T::Hash[Symbol, T.untyped], verbose: T::Boolean).returns(String) }
// 51:         def self.output(hash, verbose:)
// 52:           out = "#{Tty.bold}#{hash[:name]}#{Tty.reset} (#{hash[:service_name]})\n"
// 53:           out += "Running: #{pretty_bool(hash[:running])}\n"
// 54:           out += "Loaded: #{pretty_bool(hash[:loaded])}\n"
// 55:           out += "Schedulable: #{pretty_bool(hash[:schedulable])}\n"
// 56:           out += "User: #{hash[:user]}\n" unless hash[:pid].nil?
// 57:           out += "PID: #{hash[:pid]}\n" unless hash[:pid].nil?
// 58:           return out unless verbose
// 59:
// 60:           out += "File: #{hash[:file]} #{pretty_bool(hash[:file].present?)}\n"
// 61:           out += "Registered at login: #{pretty_bool(hash[:registered])}\n"
// 62:           out += "Command: #{hash[:command]}\n" unless hash[:command].nil?
// 63:           out += "Working directory: #{hash[:working_dir]}\n" unless hash[:working_dir].nil?
// 64:           out += "Root directory: #{hash[:root_dir]}\n" unless hash[:root_dir].nil?
// 65:           out += "Log: #{hash[:log_path]}\n" unless hash[:log_path].nil?
// 66:           out += "Error log: #{hash[:error_log_path]}\n" unless hash[:error_log_path].nil?
// 67:           out += "Interval: #{hash[:interval]}s\n" unless hash[:interval].nil?
// 68:           out += "Cron: #{hash[:cron]}\n" unless hash[:cron].nil?
// 69:
// 70:           out
// 71:         end
// 72:       end
// 73:     end
// 74:   end
// 75: end
