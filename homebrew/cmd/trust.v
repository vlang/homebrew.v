module cmd

import ruby
import x.json2

// Translated from Homebrew/brew `cmd/trust.rb`.

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

pub fn trust_command_input_boundary(input &TrustCommandInput) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::Trust::Input', '', {
		'trust_command_input_address': u64(voidptr(input)).str()
	})
}

fn trust_command_input_from_value(value ruby.Value) &TrustCommandInput {
	address := value.attributes['trust_command_input_address'] or { panic('invalid Trust command input') }
	return unsafe { &TrustCommandInput(voidptr(address.u64())) }
}

fn trust_command_result_value(result TrustCommandResult) ruby.Value {
	mut entries := map[string]ruby.Value{}
	for key, values in result.store.entries {
		entries[key] = ruby.string_array_value(values)
	}
	return ruby.Value{
		type_name: 'TrustCommandResult'
		repr: result.stdout
		map_data: {
			'store':    ruby.map_value(entries)
			'messages': ruby.string_array_value(result.messages)
			'stdout':   ruby.string_value(result.stdout)
		}
	}
}

fn trust_command_error_value(message string) ruby.Value {
	for type_name in ['Homebrew::CLI::OptionConstraintError', 'OptionParser::MissingArgument',
		'UsageError'] {
		if message.starts_with('${type_name}:') {
			return ruby.object_value(type_name, message.all_after(':').trim_space())
		}
	}
	return ruby.object_value('UsageError', message)
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
