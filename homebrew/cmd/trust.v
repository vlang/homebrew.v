module cmd

import brew_runtime
import x.json2

// Translated from Homebrew/brew `cmd/trust.rb`.
// The original source is retained below until every stub has a typed V body.

pub enum TrustEntryType {
	tap
	formula
	cask
	command
}

pub struct TrustCommandOptions {
pub:
	tap            bool
	taps           bool
	formula        bool
	formulae       bool
	cask           bool
	casks          bool
	command        bool
	commands       bool
	json_requested bool
	json_version   string
	named          []string
}

pub struct TrustCommandTap {
pub:
	name     string
	remote   string
	official bool
	formulae []string
	casks    []string
	commands []string
}

pub struct TrustCommandStore {
pub mut:
	entries map[string][]string
}

pub struct TrustCommandTarget {
pub:
	kind             TrustEntryType
	name             string
	canonical_tap    string
	remote_reference bool
	official         bool
}

pub struct TrustCommandResult {
pub:
	store    TrustCommandStore
	messages []string
	stdout   string
}

pub fn selected_trust_type(options TrustCommandOptions) ?TrustEntryType {
	if options.tap || options.taps {
		return .tap
	}
	if options.formula || options.formulae {
		return .formula
	}
	if options.cask || options.casks {
		return .cask
	}
	if options.command || options.commands {
		return .command
	}
	return none
}

pub fn trust_command_types(selected ?TrustEntryType) []TrustEntryType {
	if kind := selected {
		return [kind]
	}
	return [TrustEntryType.tap, .formula, .cask, .command]
}

fn trust_command_type_name(kind TrustEntryType) string {
	return match kind {
		.tap { 'tap' }
		.formula { 'formula' }
		.cask { 'cask' }
		.command { 'command' }
	}
}

fn trust_command_type_label(kind TrustEntryType) string {
	return match kind {
		.tap { 'taps' }
		.formula { 'formulae' }
		.cask { 'casks' }
		.command { 'commands' }
	}
}

fn trust_command_remote_reference(reference string) bool {
	if reference.starts_with('/') || reference.starts_with('.') || reference.starts_with('~')
		|| reference.contains('://') {
		return true
	}
	colon := reference.index(':') or { return false }
	slash := reference.index('/') or { reference.len }
	return colon < slash && colon + 1 < reference.len
}

fn trust_command_strip_remote_suffix(remote string) string {
	mut result := remote.trim_right('/')
	if result.ends_with('.git') {
		result = result[..result.len - 4]
	}
	return result
}

fn trust_command_normalize_remote(value string) string {
	mut remote := value.trim_space().to_lower()
	if remote == '' {
		return ''
	}
	if remote.starts_with('git@github.com:') {
		remote = 'https://github.com/${remote.all_after('git@github.com:')}'
	} else if remote.starts_with('ssh://git@github.com/') {
		remote = 'https://github.com/${remote.all_after('ssh://git@github.com/')}'
	}
	if remote.starts_with('https://github.com/') || remote.starts_with('http://github.com/') {
		remote = 'https://github.com/${remote.all_after('github.com/')}'
	}
	return trust_command_strip_remote_suffix(remote)
}

fn trust_command_tap_name(name string) !string {
	parts := name.to_lower().split('/')
	if parts.len != 2 || parts.any(it == '') || parts[0] in ['.', '..'] || parts[1] in [
		'.',
		'..',
	] || parts[0].contains('@') || parts[1].contains('@') {
		return error("Invalid tap name: '${name}'")
	}
	return '${parts[0]}/${parts[1].trim_string_left('homebrew-')}'
}

fn trust_command_default_remote(tap_name string) !string {
	canonical := trust_command_tap_name(tap_name)!
	parts := canonical.split('/')
	return 'https://github.com/${parts[0]}/homebrew-${parts[1]}'
}

fn trust_command_same_remote(first string, second string) bool {
	first_normalized := trust_command_normalize_remote(first)
	return first_normalized != '' && first_normalized == trust_command_normalize_remote(second)
}

fn trust_command_remote_to_reference(remote string) ?string {
	normalized := trust_command_normalize_remote(remote)
	prefix := 'https://github.com/'
	if normalized.starts_with(prefix) {
		parts := normalized[prefix.len..].split('/')
		if parts.len == 2 && parts[1].starts_with('homebrew-') {
			name := '${parts[0]}/${parts[1]['homebrew-'.len..]}'
			if default_remote := trust_command_default_remote(name) {
				if trust_command_same_remote(normalized, default_remote) {
					return name
				}
			}
		}
	}
	if normalized != '' {
		return normalized
	}
	return none
}

fn trust_command_find_tap(taps []TrustCommandTap, name string) ?TrustCommandTap {
	canonical := trust_command_tap_name(name) or { return none }
	for tap in taps {
		if trust_command_tap_name(tap.name) or { continue } == canonical {
			return TrustCommandTap{
				...tap
				name: canonical
			}
		}
	}
	return none
}

fn trust_command_tap_reference(tap TrustCommandTap) string {
	if tap.remote == '' {
		return tap.name
	}
	default_remote := trust_command_default_remote(tap.name) or { return tap.remote }
	if trust_command_same_remote(tap.remote, default_remote) {
		return tap.name
	}
	return trust_command_normalize_remote(tap.remote)
}

fn trust_command_resolve_tap(name string, taps []TrustCommandTap) !TrustCommandTarget {
	if trust_command_remote_reference(name) {
		reference := trust_command_remote_to_reference(name) or {
			return error('Invalid tap remote URL: ${name}')
		}
		canonical := if trust_command_remote_reference(reference) {
			''
		} else {
			trust_command_tap_name(reference)!
		}
		tap := if canonical != '' {
			trust_command_find_tap(taps, canonical) or { TrustCommandTap{ name: canonical } }
		} else {
			TrustCommandTap{}
		}
		return TrustCommandTarget{
			kind: .tap
			name: reference
			canonical_tap: canonical
			remote_reference: trust_command_remote_reference(reference)
			official: tap.official
		}
	}
	canonical := trust_command_tap_name(name)!
	tap := trust_command_find_tap(taps, canonical) or { TrustCommandTap{ name: canonical } }
	reference := trust_command_tap_reference(tap)
	return TrustCommandTarget{
		kind: .tap
		name: reference
		canonical_tap: canonical
		remote_reference: trust_command_remote_reference(reference)
		official: tap.official
	}
}

fn trust_command_resolve_item(kind TrustEntryType, name string,
	taps []TrustCommandTap) !TrustCommandTarget {
	noun := match kind {
		.formula { 'Formulae' }
		.cask { 'Casks' }
		.command { 'Commands' }
		.tap { 'Taps' }
	}
	parts := name.to_lower().split('/')
	if parts.len != 3 || parts.any(it == '') || parts[0] in ['.', '..'] || parts[1] in [
		'.',
		'..',
	] {
		return error('${noun} must be fully-qualified as <user>/<tap>/<name>.')
	}
	canonical := trust_command_tap_name('${parts[0]}/${parts[1]}')!
	tap := trust_command_find_tap(taps, canonical) or { TrustCommandTap{ name: canonical } }
	reference := trust_command_tap_reference(tap)
	return TrustCommandTarget{
		kind: kind
		name: '${reference}/${parts[2]}'
		canonical_tap: canonical
		remote_reference: trust_command_remote_reference(reference)
		official: tap.official
	}
}

pub fn resolve_trust_command_target(name string, selected ?TrustEntryType,
	taps []TrustCommandTap) !TrustCommandTarget {
	if kind := selected {
		if kind == .tap {
			return trust_command_resolve_tap(name, taps)
		}
		return trust_command_resolve_item(kind, name, taps)
	}
	if name.count('/') == 1 || trust_command_remote_reference(name) {
		return trust_command_resolve_tap(name, taps)
	}
	parts := name.to_lower().split('/')
	if parts.len != 3 || parts[0] in ['.', '..'] || parts[1] in ['.', '..'] {
		return error('Trust targets must be fully-qualified tap, formula, cask or command names.')
	}
	canonical := trust_command_tap_name('${parts[0]}/${parts[1]}')!
	tap := trust_command_find_tap(taps, canonical) or { TrustCommandTap{ name: canonical } }
	token := parts[2]
	mut candidates := []TrustEntryType{}
	if token in tap.formulae {
		candidates << .formula
	}
	if token in tap.casks {
		candidates << .cask
	}
	if token in tap.commands || 'brew-${token}' in tap.commands {
		candidates << .command
	}
	if candidates.len == 0 {
		return error('No formula, cask or command found for ${name}.')
	}
	if candidates.len > 1 {
		return error('Ambiguous trust target ${name}. Use `--formula`, `--cask` or `--command`.')
	}
	return trust_command_resolve_item(candidates[0], name, taps)
}

fn trust_command_copy_store(store TrustCommandStore) TrustCommandStore {
	mut entries := map[string][]string{}
	for key, values in store.entries {
		entries[key] = values.clone()
	}
	return TrustCommandStore{ entries: entries }
}

fn trust_command_add(mut store TrustCommandStore, kind TrustEntryType, name string) bool {
	key := trust_command_type_name(kind)
	normalized := name.to_lower()
	mut values := store.entries[key].clone()
	if normalized in values {
		return false
	}
	values << normalized
	values.sort()
	store.entries[key] = values
	return true
}

fn trust_command_json_array(values []string, indentation string) string {
	if values.len == 0 {
		return '[]'
	}
	mut lines := ['[']
	for index, value in values {
		comma := if index + 1 < values.len { ',' } else { '' }
		lines << '${indentation}  ${json2.encode(value)}${comma}'
	}
	lines << '${indentation}]'
	return lines.join('\n')
}

pub fn trust_command_json(store TrustCommandStore, selected ?TrustEntryType) string {
	if kind := selected {
		return '${trust_command_json_array(store.entries[trust_command_type_name(kind)], '')}\n'
	}
	mut lines := ['{']
	kinds := trust_command_types(none)
	for index, kind in kinds {
		comma := if index + 1 < kinds.len { ',' } else { '' }
		values := trust_command_json_array(store.entries[trust_command_type_name(kind)], '  ')
		if values == '[]' {
			lines << '  ${json2.encode(trust_command_type_label(kind))}: []${comma}'
		} else {
			value_lines := values.split_into_lines()
			lines << '  ${json2.encode(trust_command_type_label(kind))}: ${value_lines[0]}'
			lines << value_lines[1..value_lines.len - 1]
			lines << '${value_lines.last()}${comma}'
		}
	}
	lines << '}'
	return '${lines.join('\n')}\n'
}

fn trust_command_selected_count(options TrustCommandOptions) int {
	return int(options.tap || options.taps) + int(options.formula || options.formulae) + int(options.cask || options.casks) + int(options.command || options.commands)
}

pub fn run_trust_command(options TrustCommandOptions, initial_store TrustCommandStore,
	taps []TrustCommandTap) !TrustCommandResult {
	if trust_command_selected_count(options) > 1 {
		return error('Homebrew::CLI::OptionConstraintError: `--tap`, `--formula`, `--cask` and `--command` are mutually exclusive.')
	}
	selected := selected_trust_type(options)
	if options.json_requested {
		if options.json_version == '' {
			return error('OptionParser::MissingArgument: missing argument: --json')
		}
		if options.json_version != 'v1' {
			return error('UsageError: invalid JSON version: ${options.json_version}')
		}
		if options.named.len > 0 {
			return error('UsageError: `--json=v1` requires no named arguments.')
		}
		return TrustCommandResult{
			store: trust_command_copy_store(initial_store)
			stdout: trust_command_json(initial_store, selected)
		}
	}
	mut store := trust_command_copy_store(initial_store)
	mut messages := []string{}
	if options.named.len == 0 {
		messages << 'All official taps and commands are trusted.'
		mut printed := false
		for kind in trust_command_types(selected) {
			values := store.entries[trust_command_type_name(kind)]
			if values.len == 0 {
				continue
			}
			messages << 'Trusted ${trust_command_type_label(kind)}:'
			messages << values.map('  ${it}')
			printed = true
		}
		if !printed {
			messages << 'No trusted taps, formulae, casks or commands.'
		}
		return TrustCommandResult{
			store: store
			messages: messages
			stdout: '${messages.join('\n')}\n'
		}
	}
	for name in options.named {
		target := resolve_trust_command_target(name, selected, taps)!
		if target.kind == .tap && !target.remote_reference && target.official {
			messages << 'Official tap ${target.name} is always trusted.'
			continue
		}
		action := if trust_command_add(mut store, target.kind, target.name) {
			'Trusted'
		} else {
			'Already trusted'
		}
		messages << '${action} ${trust_command_type_name(target.kind)}: ${target.name}'
	}
	return TrustCommandResult{
		store: store
		messages: messages
		stdout: '${messages.join('\n')}\n'
	}
}

@[heap]
pub struct TrustCommandInput {
pub:
	options TrustCommandOptions
	store   TrustCommandStore
	taps    []TrustCommandTap
}

pub fn trust_command_input_boundary(input &TrustCommandInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Cmd::Trust::Input', '', {
		'trust_command_input_address': u64(voidptr(input)).str()
	})
}

fn trust_command_input_from_value(value brew_runtime.Value) &TrustCommandInput {
	address := value.attributes['trust_command_input_address'] or { panic('invalid Trust command input') }
	return unsafe { &TrustCommandInput(voidptr(address.u64())) }
}

fn trust_command_result_value(result TrustCommandResult) brew_runtime.Value {
	mut entries := map[string]brew_runtime.Value{}
	for key, values in result.store.entries {
		entries[key] = brew_runtime.string_array_value(values)
	}
	return brew_runtime.Value{
		type_name: 'TrustCommandResult'
		repr: result.stdout
		map_data: {
			'store':    brew_runtime.map_value(entries)
			'messages': brew_runtime.string_array_value(result.messages)
			'stdout':   brew_runtime.string_value(result.stdout)
		}
	}
}

fn trust_command_error_value(message string) brew_runtime.Value {
	for type_name in ['Homebrew::CLI::OptionConstraintError', 'OptionParser::MissingArgument',
		'UsageError'] {
		if message.starts_with('${type_name}:') {
			return brew_runtime.object_value(type_name, message.all_after(':').trim_space())
		}
	}
	return brew_runtime.object_value('UsageError', message)
}

// Ruby method `run` at line 37.
pub fn ruby_trust_l37_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := trust_command_input_from_value(args[0])
	result := run_trust_command(input.options, input.store, input.taps) or {
		return trust_command_error_value(err.msg())
	}
	return trust_command_result_value(result)
}

// Ruby method `print_json` at line 79.
pub fn ruby_trust_l79_d2_print_json(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := trust_command_input_from_value(args[0])
	return brew_runtime.string_value(trust_command_json(input.store, selected_trust_type(input.options)))
}

// Ruby method `types` at line 96.
pub fn ruby_trust_l96_d3_types(args ...brew_runtime.Value) brew_runtime.Value {
	selected := if args.len > 0 && args[0].type_name != 'NilClass' {
		trust_entry_type_from_string(args[0].as_string()) or {
			return brew_runtime.object_value('ArgumentError', err.msg())
		}
	} else {
		none
	}
	return brew_runtime.string_array_value(trust_command_types(selected).map(trust_command_type_name(it)))
}

// Ruby method `selected_type` at line 104.
pub fn ruby_trust_l104_d4_selected_type(args ...brew_runtime.Value) brew_runtime.Value {
	options := TrustCommandOptions{
		tap: args.len > 0 && (args[0].as_bool() or { false })
		formula: args.len > 1 && (args[1].as_bool() or { false })
		cask: args.len > 2 && (args[2].as_bool() or { false })
		command: args.len > 3 && (args[3].as_bool() or { false })
		commands: args.len > 4 && (args[4].as_bool() or { false })
	}
	if kind := selected_trust_type(options) {
		return brew_runtime.string_value(trust_command_type_name(kind))
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

fn trust_entry_type_from_string(value string) !TrustEntryType {
	return match value {
		'tap' { TrustEntryType.tap }
		'formula' { TrustEntryType.formula }
		'cask' { TrustEntryType.cask }
		'command' { TrustEntryType.command }
		else { error('unsupported trust type: ${value}') }
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "json"
// 6: require "trust"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Trust < AbstractCommand
// 11:       VALID_TYPES = [:tap, :formula, :cask, :command].freeze
// 12:
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Trust non-official tap formulae, casks or commands so Homebrew may load them.
// 16:           Trusted entries are stored in `${XDG_CONFIG_HOME}/homebrew/trust.json` if
// 17:           `$XDG_CONFIG_HOME` is set or `~/.homebrew/trust.json` otherwise.
// 18:         EOS
// 19:         switch "--tap", "--taps",
// 20:                description: "Trust the named tap."
// 21:         switch "--formula", "--formulae",
// 22:                description: "Trust the named formula."
// 23:         switch "--cask", "--casks",
// 24:                description: "Trust the named cask."
// 25:         switch "--command", "--commands",
// 26:                description: "Trust the named external command."
// 27:         flag "--json=",
// 28:              description: "Print trusted entries as JSON. A <version> number is required. " \
// 29:                           "The only accepted value for <version> is `v1`."
// 30:
// 31:         conflicts "--tap", "--formula", "--cask", "--command"
// 32:
// 33:         named_args :target
// 34:       end
// 35:
// 36:       sig { override.void }
// 37:       def run
// 38:         if args.json
// 39:           raise UsageError, "invalid JSON version: #{args.json}" if args.json != "v1"
// 40:           raise UsageError, "`--json=v1` requires no named arguments." if args.named.present?
// 41:
// 42:           print_json
// 43:           return
// 44:         end
// 45:
// 46:         if args.no_named?
// 47:           puts "All official taps and commands are trusted."
// 48:           printed = T.let(false, T::Boolean)
// 49:           types.each do |type|
// 50:             values = Homebrew::Trust.trusted_entries(type)
// 51:             next if values.empty?
// 52:
// 53:             label = Utils.pluralize(type.to_s, 2)
// 54:             puts "Trusted #{label}:"
// 55:             values.each { |value| puts "  #{value}" }
// 56:             printed = true
// 57:           end
// 58:
// 59:           puts "No trusted taps, formulae, casks or commands." unless printed
// 60:           return
// 61:         end
// 62:
// 63:         args.named.each do |name|
// 64:           type, trust_name = Homebrew::Trust.target(name, type: selected_type)
// 65:           if type == :tap && !Tap.remote_reference?(trust_name) && Tap.fetch(trust_name).official?
// 66:             puts "Official tap #{trust_name} is always trusted."
// 67:             next
// 68:           end
// 69:
// 70:           action = Homebrew::Trust.trust!(type, trust_name) ? "Trusted" : "Already trusted"
// 71:
// 72:           puts "#{action} #{type}: #{trust_name}"
// 73:         end
// 74:       end
// 75:
// 76:       private
// 77:
// 78:       sig { void }
// 79:       def print_json
// 80:         if (type = selected_type)
// 81:           puts JSON.pretty_generate(Homebrew::Trust.trusted_entries(type))
// 82:           return
// 83:         end
// 84:
// 85:         json = T.let({}, T::Hash[String, T::Array[String]])
// 86:
// 87:         types.each do |type|
// 88:           key = Utils.pluralize(type.to_s, 2)
// 89:           json[key] = Homebrew::Trust.trusted_entries(type)
// 90:         end
// 91:
// 92:         puts JSON.pretty_generate(json)
// 93:       end
// 94:
// 95:       sig { returns(T::Array[Symbol]) }
// 96:       def types
// 97:         type = selected_type
// 98:         return [type] if type
// 99:
// 100:         VALID_TYPES
// 101:       end
// 102:
// 103:       sig { returns(T.nilable(Symbol)) }
// 104:       def selected_type
// 105:         return :tap if args.tap?
// 106:         return :formula if args.formula?
// 107:         return :cask if args.cask?
// 108:
// 109:         :command if args.command? || args.commands?
// 110:       end
// 111:     end
// 112:   end
// 113: end
