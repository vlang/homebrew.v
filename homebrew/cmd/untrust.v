module cmd

import ruby

// Translated from Homebrew/brew `cmd/untrust.rb`.
pub enum UntrustEntryType {
	tap
	formula
	cask
	command
}

pub struct UntrustedTapSnapshot {
pub:
	name     string
	formulae []string
	casks    []string
	commands []string
}

pub struct UntrustStore {
pub:
	trusted        map[string][]string
	untrusted_taps []UntrustedTapSnapshot
}

pub struct UntrustTarget {
pub:
	kind             UntrustEntryType
	name             string
	aliases          []string
	official         bool
	remote_reference bool
}

pub struct UntrustResult {
pub:
	store    UntrustStore
	messages []string
}

pub fn selected_untrust_type(tap bool, formula bool, cask bool, command bool) ?UntrustEntryType {
	if tap {
		return .tap
	}
	if formula {
		return .formula
	}
	if cask {
		return .cask
	}
	if command {
		return .command
	}
	return none
}

fn untrust_type_key(kind UntrustEntryType) string {
	return match kind {
		.tap { 'tap' }
		.formula { 'formula' }
		.cask { 'cask' }
		.command { 'command' }
	}
}

fn untrust_type_label(kind UntrustEntryType) string {
	return match kind {
		.tap { 'taps' }
		.formula { 'formulae' }
		.cask { 'casks' }
		.command { 'commands' }
	}
}

fn untrust_tap_values(tap UntrustedTapSnapshot, kind UntrustEntryType) []string {
	return match kind {
		.tap { [tap.name] }
		.formula { tap.formulae.map('${tap.name}/${it}') }
		.cask { tap.casks.map('${tap.name}/${it}') }
		.command { tap.commands.map('${tap.name}/${it.trim_string_left('brew-')}') }
	}
}

fn untrust_remove(mut trusted map[string][]string, kind UntrustEntryType, name string) bool {
	key := untrust_type_key(kind)
	mut entries := trusted[key].clone()
	index := entries.index(name)
	if index < 0 {
		return false
	}
	entries.delete(index)
	trusted[key] = entries
	return true
}

pub fn run_untrust(store UntrustStore, targets []UntrustTarget,
	selected ?UntrustEntryType) UntrustResult {
	mut trusted := store.trusted.clone()
	mut messages := []string{}
	if targets.len == 0 {
		kinds := if kind := selected {
			[kind]
		} else {
			[UntrustEntryType.tap, .formula, .cask, .command]
		}
		mut printed := false
		for kind in kinds {
			mut values := []string{}
			for tap in store.untrusted_taps {
				for value in untrust_tap_values(tap, kind) {
					if kind == .tap || value !in trusted[untrust_type_key(kind)] {
						values << value
					}
				}
			}
			values.sort()
			if values.len == 0 {
				continue
			}
			messages << 'Untrusted ${untrust_type_label(kind)}:'
			messages << values.map('  ${it}')
			printed = true
		}
		if !printed {
			messages << 'No untrusted taps, formulae, casks or commands.'
		}
		return UntrustResult{
			store: UntrustStore{
				trusted: trusted
				untrusted_taps: store.untrusted_taps.clone()
			}
			messages: messages
		}
	}
	for target in targets {
		if target.kind == .tap && target.official && !target.remote_reference {
			messages << 'Official tap ${target.name} is always trusted.'
			continue
		}
		mut removed := untrust_remove(mut trusted, target.kind, target.name)
		for alias in target.aliases {
			if untrust_remove(mut trusted, target.kind, alias) {
				removed = true
			}
		}
		if target.kind == .tap {
			for item_kind in [UntrustEntryType.formula, .cask, .command] {
				key := untrust_type_key(item_kind)
				for entry in trusted[key].clone() {
					if entry.starts_with('${target.name}/') && untrust_remove(mut trusted, item_kind, entry) {
						removed = true
					}
				}
			}
		}
		action := if removed { 'Untrusted' } else { 'Not trusted' }
		messages << '${action} ${untrust_type_key(target.kind)}: ${target.name}'
	}
	return UntrustResult{
		store: UntrustStore{
			trusted: trusted
			untrusted_taps: store.untrusted_taps.clone()
		}
		messages: messages
	}
}

fn untrust_target_from_value(value ruby.Value) UntrustTarget {
	kind := match value.attribute('kind') or { 'tap' } {
		'formula' { UntrustEntryType.formula }
		'cask' { UntrustEntryType.cask }
		'command' { UntrustEntryType.command }
		else { UntrustEntryType.tap }
	}
	return UntrustTarget{
		kind: kind
		name: value.attribute('name') or { value.as_string() }
		aliases: (value.map_data['aliases'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		official: (value.attribute('official') or { 'false' }) == 'true'
		remote_reference: (value.attribute('remote_reference') or { 'false' }) == 'true'
	}
}

pub fn untrust_target_value(target UntrustTarget) ruby.Value {
	return ruby.Value{
		type_name: 'UntrustTarget'
		repr: target.name
		attributes: {
			'kind':             untrust_type_key(target.kind)
			'name':             target.name
			'official':         target.official.str()
			'remote_reference': target.remote_reference.str()
		}
		map_data: {
			'aliases': ruby.string_array_value(target.aliases)
		}
	}
}

fn untrust_store_from_value(value ruby.Value) UntrustStore {
	mut trusted := map[string][]string{}
	if stored := value.map_data['trusted'] {
		for key, entries in stored.map_data {
			trusted[key] = entries.as_string_array() or { [] }
		}
	}
	mut taps := []UntrustedTapSnapshot{}
	for tap in (value.map_data['untrusted_taps'] or { ruby.array_value([]) }).as_array() or { [] } {
		taps << UntrustedTapSnapshot{
			name: tap.attribute('name') or { tap.as_string() }
			formulae: (tap.map_data['formulae'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
			casks: (tap.map_data['casks'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
			commands: (tap.map_data['commands'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		}
	}
	return UntrustStore{
		trusted: trusted
		untrusted_taps: taps
	}
}

pub fn untrust_store_value(store UntrustStore) ruby.Value {
	mut trusted := map[string]ruby.Value{}
	for key, entries in store.trusted {
		trusted[key] = ruby.string_array_value(entries)
	}
	mut taps := []ruby.Value{}
	for tap in store.untrusted_taps {
		taps << ruby.Value{
			type_name: 'Tap'
			repr: tap.name
			attributes: {
				'name': tap.name
			}
			map_data: {
				'formulae': ruby.string_array_value(tap.formulae)
				'casks':    ruby.string_array_value(tap.casks)
				'commands': ruby.string_array_value(tap.commands)
			}
		}
	}
	return ruby.Value{
		type_name: 'UntrustStore'
		repr: 'untrust store'
		map_data: {
			'trusted':        ruby.map_value(trusted)
			'untrusted_taps': ruby.array_value(taps)
		}
	}
}

fn untrust_result_value(result UntrustResult) ruby.Value {
	return ruby.Value{
		type_name: 'UntrustResult'
		repr: '${result.messages.join('\n')}\n'
		map_data: {
			'store':    untrust_store_value(result.store)
			'messages': ruby.string_array_value(result.messages)
		}
	}
}
