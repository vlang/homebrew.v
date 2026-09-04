module cmd

import ruby

// Translated from Homebrew/brew `cmd/untrust.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `run` at line 31.
pub fn ruby_untrust_l31_d1_run(args ...ruby.Value) ruby.Value {
	store := if args.len > 0 { untrust_store_from_value(args[0]) } else { UntrustStore{} }
	targets := if args.len > 1 {
		(args[1].as_array() or { [] }).map(untrust_target_from_value(it))
	} else {
		[]UntrustTarget{}
	}
	selected := if args.len > 2 && args[2].type_name != 'NilClass' {
		selected_untrust_type(args[2].as_string() == 'tap', args[2].as_string() == 'formula', args[2].as_string() == 'cask', args[2].as_string() == 'command')
	} else {
		none
	}
	return untrust_result_value(run_untrust(store, targets, selected))
}

// Ruby method `selected_type` at line 105.
pub fn ruby_untrust_l105_d2_selected_type(args ...ruby.Value) ruby.Value {
	tap := args.len > 0 && (args[0].as_bool() or { false })
	formula := args.len > 1 && (args[1].as_bool() or { false })
	cask := args.len > 2 && (args[2].as_bool() or { false })
	command := args.len > 3 && (args[3].as_bool() or { false })
	if kind := selected_untrust_type(tap, formula, cask, command) {
		return ruby.string_value(untrust_type_key(kind))
	}
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "trust"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Untrust < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Stop trusting non-official tap formulae, casks or commands.
// 13:           Trusted entries are stored in `${XDG_CONFIG_HOME}/homebrew/trust.json` if
// 14:           `$XDG_CONFIG_HOME` is set or `~/.homebrew/trust.json` otherwise.
// 15:         EOS
// 16:         switch "--tap",
// 17:                description: "Untrust the named tap."
// 18:         switch "--formula", "--formulae",
// 19:                description: "Untrust the named formula."
// 20:         switch "--cask", "--casks",
// 21:                description: "Untrust the named cask."
// 22:         switch "--command", "--commands",
// 23:                description: "Untrust the named external command."
// 24:
// 25:         conflicts "--tap", "--formula", "--cask", "--command"
// 26:
// 27:         named_args :target
// 28:       end
// 29:
// 30:       sig { override.void }
// 31:       def run
// 32:         if args.no_named?
// 33:           types = selected_type ? [selected_type] : [:tap, :formula, :cask, :command]
// 34:           printed = T.let(false, T::Boolean)
// 35:           types.each do |type|
// 36:             values = Homebrew::Trust.untrusted_taps.flat_map do |tap|
// 37:               case type
// 38:               when :tap
// 39:                 [tap.name]
// 40:               when :formula
// 41:                 tap.formula_files.filter_map do |file|
// 42:                   name = file.basename(file.extname).to_s
// 43:                   full_name = "#{tap.name}/#{name}"
// 44:                   full_name unless Homebrew::Trust.trusted?(:formula, full_name)
// 45:                 end
// 46:               when :cask
// 47:                 tap.cask_files.filter_map do |file|
// 48:                   name = file.basename(file.extname).to_s
// 49:                   full_name = "#{tap.name}/#{name}"
// 50:                   full_name unless Homebrew::Trust.trusted?(:cask, full_name)
// 51:                 end
// 52:               when :command
// 53:                 tap.command_files.filter_map do |file|
// 54:                   name = file.basename(file.extname).to_s.delete_prefix("brew-")
// 55:                   full_name = "#{tap.name}/#{name}"
// 56:                   full_name unless Homebrew::Trust.trusted?(:command, full_name)
// 57:                 end
// 58:               else
// 59:                 raise "Unsupported trust type: #{type}"
// 60:               end
// 61:             end.sort
// 62:             next if values.empty?
// 63:
// 64:             label = case type
// 65:             when :tap then "taps"
// 66:             when :formula then "formulae"
// 67:             when :cask then "casks"
// 68:             when :command then "commands"
// 69:             else raise "Unsupported trust type: #{type}"
// 70:             end
// 71:             puts "Untrusted #{label}:"
// 72:             values.each { |value| puts "  #{value}" }
// 73:             printed = true
// 74:           end
// 75:
// 76:           puts "No untrusted taps, formulae, casks or commands." unless printed
// 77:           return
// 78:         end
// 79:
// 80:         args.named.each do |name|
// 81:           item_types = [:formula, :cask, :command]
// 82:           type, trust_name = Homebrew::Trust.target(name, type: selected_type, include_existing: true)
// 83:           if type == :tap && !Tap.remote_reference?(trust_name) && Tap.fetch(trust_name).official?
// 84:             puts "Official tap #{trust_name} is always trusted."
// 85:             next
// 86:           end
// 87:
// 88:           removed = Homebrew::Trust.untrust!(type, trust_name)
// 89:           if type == :tap
// 90:             item_types.each do |item_type|
// 91:               Homebrew::Trust.trusted_entries(item_type).each do |entry|
// 92:                 removed = true if entry.start_with?("#{trust_name}/") && Homebrew::Trust.untrust!(item_type, entry)
// 93:               end
// 94:             end
// 95:           end
// 96:           action = removed ? "Untrusted" : "Not trusted"
// 97:
// 98:           puts "#{action} #{type}: #{trust_name}"
// 99:         end
// 100:       end
// 101:
// 102:       private
// 103:
// 104:       sig { returns(T.nilable(Symbol)) }
// 105:       def selected_type
// 106:         return :tap if args.tap?
// 107:         return :formula if args.formula?
// 108:         return :cask if args.cask?
// 109:
// 110:         :command if args.command? || args.commands?
// 111:       end
// 112:     end
// 113:   end
// 114: end
