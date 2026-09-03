module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/tap.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct BundleTap {
pub:
	name             string
	remote           string
	default_remote   string
	match_references []string
	installed        bool
}

pub struct BundleTapState {
pub:
	taps               []BundleTap
	installed_taps     []string
	installed_override bool
	developer          bool
	github_api_token   string
	trusted_entries    map[string][]string
	skipped_taps       []string
}

pub struct BundleTapEffects {
pub:
	command_results map[string]bool
}

pub struct BundleTapActionResult {
pub:
	success            bool
	state              BundleTapState
	command            []string
	failed_taps        []string
	cache_cleared_taps []string
	output             []string
}

fn bundle_tap_bool(value brew_runtime.Value, fallback bool) bool {
	return value.as_bool() or { fallback }
}

fn bundle_tap_strings(value brew_runtime.Value) []string {
	return value.as_string_array() or { [] }
}

fn bundle_tap_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

fn bundle_tap_unique(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if value !in seen {
			seen[value] = true
			result << value
		}
	}
	return result
}

pub fn bundle_tap_value(tap BundleTap) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Tap'
		repr: tap.name
		map_data: {
			'name':             brew_runtime.string_value(tap.name)
			'remote':           if tap.remote == '' {
				bundle_tap_nil()
			} else {
				brew_runtime.string_value(tap.remote)
			}
			'default_remote':   brew_runtime.string_value(tap.default_remote)
			'match_references': brew_runtime.string_array_value(tap.match_references)
			'installed?':       brew_runtime.bool_value(tap.installed)
		}
		attributes: {
			'name': tap.name
		}
	}
}

pub fn bundle_tap_from_value(value brew_runtime.Value) BundleTap {
	fields := value.map_data.clone()
	remote_value := fields['remote'] or { bundle_tap_nil() }
	return BundleTap{
		name: (fields['name'] or { brew_runtime.string_value(value.attributes['name'] or { value.repr }) }).as_string()
		remote: if remote_value.type_name in ['Nil', 'NilClass'] {
			''
		} else {
			remote_value.as_string()
		}
		default_remote: (fields['default_remote'] or { brew_runtime.string_value('') }).as_string()
		match_references: bundle_tap_strings(fields['match_references'] or { brew_runtime.string_array_value([]) })
		installed: bundle_tap_bool(fields['installed?'] or { brew_runtime.bool_value(true) }, true)
	}
}

fn bundle_taps_value(taps []BundleTap) brew_runtime.Value {
	return brew_runtime.array_value(taps.map(bundle_tap_value(it)))
}

fn bundle_taps_from_value(value brew_runtime.Value) []BundleTap {
	return value.as_array() or { [] }.map(bundle_tap_from_value(it))
}

pub fn bundle_tap_state_value(state BundleTapState) brew_runtime.Value {
	mut trusted := map[string]brew_runtime.Value{}
	for entry_type, entries in state.trusted_entries {
		trusted[entry_type] = brew_runtime.string_array_value(entries)
	}
	return brew_runtime.Value{
		type_name: 'Homebrew::Bundle::Tap::State'
		array_data: state.taps.map(bundle_tap_value(it))
		map_data: {
			'installed_taps':     brew_runtime.string_array_value(state.installed_taps)
			'installed_override': brew_runtime.bool_value(state.installed_override)
			'developer':          brew_runtime.bool_value(state.developer)
			'github_api_token':   brew_runtime.string_value(state.github_api_token)
			'trusted_entries':    brew_runtime.map_value(trusted)
			'skipped_taps':       brew_runtime.string_array_value(state.skipped_taps)
		}
	}
}

pub fn bundle_tap_state_from_value(value brew_runtime.Value) BundleTapState {
	fields := value.map_data.clone()
	mut trusted := map[string][]string{}
	for entry_type, entries in (fields['trusted_entries'] or { brew_runtime.map_value({}) }).as_map() or {
		map[string]brew_runtime.Value{}
	} {
		trusted[entry_type] = bundle_tap_strings(entries)
	}
	return BundleTapState{
		taps: value.array_data.map(bundle_tap_from_value(it))
		installed_taps: bundle_tap_strings(fields['installed_taps'] or { brew_runtime.string_array_value([]) })
		installed_override: bundle_tap_bool(fields['installed_override'] or { brew_runtime.bool_value(false) }, false)
		developer: bundle_tap_bool(fields['developer'] or { brew_runtime.bool_value(false) }, false)
		github_api_token: (fields['github_api_token'] or { brew_runtime.string_value('') }).as_string()
		trusted_entries: trusted
		skipped_taps: bundle_tap_strings(fields['skipped_taps'] or { brew_runtime.string_array_value([]) })
	}
}

pub fn bundle_tap_effects_value(effects BundleTapEffects) brew_runtime.Value {
	mut command_results := map[string]brew_runtime.Value{}
	for command, result in effects.command_results {
		command_results[command] = brew_runtime.bool_value(result)
	}
	return brew_runtime.map_value({
		'command_results': brew_runtime.map_value(command_results)
	})
}

pub fn bundle_tap_effects_from_value(value brew_runtime.Value) BundleTapEffects {
	fields := value.as_map() or { map[string]brew_runtime.Value{} }
	mut command_results := map[string]bool{}
	for command, result in (fields['command_results'] or { brew_runtime.map_value({}) }).as_map() or {
		map[string]brew_runtime.Value{}
	} {
		command_results[command] = bundle_tap_bool(result, false)
	}
	return BundleTapEffects{ command_results: command_results }
}

fn bundle_tap_action_value(result BundleTapActionResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'result':             brew_runtime.bool_value(result.success)
		'state':              bundle_tap_state_value(result.state)
		'command':            brew_runtime.string_array_value(result.command)
		'failed_taps':        brew_runtime.string_array_value(result.failed_taps)
		'cache_cleared_taps': brew_runtime.string_array_value(result.cache_cleared_taps)
		'output':             brew_runtime.string_array_value(result.output)
	})
}

pub fn bundle_tap_reset(state BundleTapState) BundleTapState {
	return BundleTapState{
		taps: state.taps.clone()
		developer: state.developer
		github_api_token: state.github_api_token
		trusted_entries: state.trusted_entries.clone()
		skipped_taps: state.skipped_taps.clone()
	}
}

pub fn bundle_tap_taps(state BundleTapState) []BundleTap {
	return state.taps.filter(it.installed)
}

pub fn bundle_tap_names(state BundleTapState) []string {
	return bundle_tap_taps(state).map(it.name)
}

pub fn bundle_tap_installed_names(state BundleTapState) []string {
	return if state.installed_override {
		state.installed_taps.clone()
	} else {
		bundle_tap_names(state)
	}
}

pub fn bundle_tap_preinstall(state BundleTapState, name string, verbose bool) (bool, []string) {
	if name in bundle_tap_installed_names(state) {
		return false, if verbose {
			['Skipping install of ${name} tap. It is already installed.']
		} else {
			[]
		}
	}
	return true, []string{}
}

fn bundle_tap_command_result(effects BundleTapEffects, command []string) bool {
	return effects.command_results[command.join('\x1f')] or { false }
}

pub fn bundle_tap_install(state BundleTapState, name string, preinstall bool, verbose bool,
	force bool, clone_target string, effects BundleTapEffects) BundleTapActionResult {
	if !preinstall {
		return BundleTapActionResult{
			success: true
			state: state
		}
	}
	mut command := ['tap', name]
	if clone_target != '' {
		command << clone_target
	}
	if force || (name.to_lower().starts_with('homebrew/') && state.developer) {
		command << '--force'
	}
	mut output := []string{}
	if verbose {
		output << 'Installing ${name} tap. It is not currently installed.'
	}
	if !bundle_tap_command_result(effects, command) {
		return BundleTapActionResult{
			state: state
			command: command
			failed_taps: [name]
			output: output
		}
	}
	mut installed := bundle_tap_installed_names(state)
	installed << name
	installed = bundle_tap_unique(installed)
	return BundleTapActionResult{
		success: true
		state: BundleTapState{
			...state
			installed_taps: installed
			installed_override: true
		}
		command: command
		cache_cleared_taps: [name]
		output: output
	}
}

pub fn bundle_tap_matches_reference(tap BundleTap, reference string) bool {
	return reference == tap.name || reference == tap.remote || reference in tap.match_references
}

fn bundle_tap_explicitly_trusted(state BundleTapState, tap BundleTap) bool {
	for entry in state.trusted_entries['tap'] or { [] } {
		if bundle_tap_matches_reference(tap, entry) {
			return true
		}
	}
	return false
}

fn bundle_tap_partial_trust(state BundleTapState, tap BundleTap, entry_type string,
	dumped_items []string) []string {
	mut trusted_items := []string{}
	for entry in state.trusted_entries[entry_type] or { [] } {
		separator := entry.last_index('/') or { continue }
		reference := entry[..separator]
		item := entry[separator + 1..]
		if reference == '' || item == '' {
			continue
		}
		if reference != tap.name && !bundle_tap_matches_reference(tap, reference) {
			continue
		}
		if '${tap.name}/${item}' in dumped_items {
			continue
		}
		trusted_items << item
	}
	trusted_items.sort()
	return bundle_tap_unique(trusted_items)
}

fn bundle_tap_ruby_inspect(value string) string {
	return '"${value.replace('\\', '\\\\').replace('"', '\\"')}"'
}

pub fn bundle_tap_dump(state BundleTapState, dumped_formulae []string, dumped_casks []string) string {
	mut lines := []string{}
	for tap in bundle_tap_taps(state) {
		mut tapline := 'tap "${tap.name}"'
		if tap.remote != '' && tap.remote != tap.default_remote {
			mut remote := tap.remote
			if state.github_api_token != '' {
				remote = remote.replace(state.github_api_token, '#{ENV.fetch("HOMEBREW_GITHUB_API_TOKEN")}')
			}
			tapline += ', "${remote}"'
		}
		if bundle_tap_explicitly_trusted(state, tap) {
			tapline += ', trusted: true'
		} else {
			formulae := bundle_tap_partial_trust(state, tap, 'formula', dumped_formulae)
			casks := bundle_tap_partial_trust(state, tap, 'cask', dumped_casks)
			commands := bundle_tap_partial_trust(state, tap, 'command', [])
			mut options := []string{}
			if formulae.len > 0 {
				options << 'formulae: [${formulae.map(bundle_tap_ruby_inspect(it)).join(', ')}]'
			}
			if casks.len > 0 {
				options << 'casks: [${casks.map(bundle_tap_ruby_inspect(it)).join(', ')}]'
			}
			if commands.len > 0 {
				options << 'commands: [${commands.map(bundle_tap_ruby_inspect(it)).join(', ')}]'
			}
			if options.len > 0 {
				tapline += ', trusted: { ${options.join(', ')} }'
			}
		}
		lines << tapline
	}
	lines.sort()
	return bundle_tap_unique(lines).join('\n')
}

fn bundle_tap_entry_from_value(value brew_runtime.Value) BundleDslEntry {
	fields := value.as_map() or { map[string]brew_runtime.Value{} }
	return BundleDslEntry{
		entry_type: value.attributes['type'] or { (fields['type'] or { brew_runtime.string_value('') }).as_string() }
		name: value.attributes['name'] or { (fields['name'] or { brew_runtime.string_value(value.repr) }).as_string() }
		options: (fields['options'] or { brew_runtime.map_value({}) }).as_map() or { value.map_data.clone() }
	}
}

pub fn bundle_tap_find_actionable(state BundleTapState, entries []BundleDslEntry) []string {
	current_taps := bundle_tap_names(state)
	mut messages := []string{}
	for entry in entries {
		if entry.entry_type != 'tap' || entry.name in state.skipped_taps || entry.name in current_taps {
			continue
		}
		messages << 'Tap ${entry.name} needs to be tapped.'
	}
	return messages
}

// Ruby method `type = :tap` at line 13.
pub fn ruby_tap_l13_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Symbol', 'tap')
}

// Ruby method `check_label = "Tap"` at line 16.
pub fn ruby_tap_l16_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Tap')
}

// Ruby method `reset!` at line 19.
pub fn ruby_tap_l19_d3_reset(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	return bundle_tap_state_value(bundle_tap_reset(state))
}

// Ruby method `preinstall!(name, no_upgrade: false, verbose: false, **_options)` at line 32.
pub fn ruby_tap_l32_d4_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	verbose := if args.len > 3 { bundle_tap_bool(args[3], false) } else { false }
	result, output := bundle_tap_preinstall(state, name, verbose)
	return brew_runtime.map_value({
		'result': brew_runtime.bool_value(result)
		'output': brew_runtime.string_array_value(output)
	})
}

// Ruby method `install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, clone_target: nil,` at line 54.
pub fn ruby_tap_l54_d5_install(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	preinstall := if args.len > 2 { bundle_tap_bool(args[2], true) } else { true }
	verbose := if args.len > 4 { bundle_tap_bool(args[4], false) } else { false }
	force := if args.len > 5 { bundle_tap_bool(args[5], false) } else { false }
	clone_target := if args.len > 6 && args[6].type_name !in ['Nil', 'NilClass'] {
		args[6].as_string()
	} else {
		''
	}
	effects := if args.len > 7 {
		bundle_tap_effects_from_value(args[7])
	} else {
		BundleTapEffects{}
	}
	return bundle_tap_action_value(bundle_tap_install(state, name, preinstall, verbose, force, clone_target, effects))
}

// Ruby method `install_verb(_name = "", _options = {})` at line 84.
pub fn ruby_tap_l84_d6_install_verb(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Tapping')
}

// Ruby method `dump(dumped_formulae: [], dumped_casks: [])` at line 89.
pub fn ruby_tap_l89_d7_dump(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	dumped_formulae := if args.len > 1 { bundle_tap_strings(args[1]) } else { [] }
	dumped_casks := if args.len > 2 { bundle_tap_strings(args[2]) } else { [] }
	return brew_runtime.string_value(bundle_tap_dump(state, dumped_formulae, dumped_casks))
}

// Ruby method `dump_output(describe: false, no_restart: false)` at line 136.
pub fn ruby_tap_l136_d8_dump_output(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	return brew_runtime.string_value(bundle_tap_dump(state, [], []))
}

// Ruby method `tap_names` at line 144.
pub fn ruby_tap_l144_d9_tap_names(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	return brew_runtime.string_array_value(bundle_tap_names(state))
}

// Ruby method `installed_taps` at line 149.
pub fn ruby_tap_l149_d10_installed_taps(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	return brew_runtime.string_array_value(bundle_tap_installed_names(state))
}

// Ruby method `taps` at line 154.
pub fn ruby_tap_l154_d11_taps(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	return bundle_taps_value(bundle_tap_taps(state))
}

// Ruby method `find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 167.
pub fn ruby_tap_l167_d12_find_actionable(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	entries := if args.len > 1 {
		args[1].as_array() or { [] }.map(bundle_tap_entry_from_value(it))
	} else {
		[]BundleDslEntry{}
	}
	return brew_runtime.string_array_value(bundle_tap_find_actionable(state, entries))
}

// Ruby method `installed_and_up_to_date?(package, no_upgrade: false)` at line 180.
pub fn ruby_tap_l180_d13_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_tap_state_from_value(args[0]) } else { BundleTapState{} }
	package := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.bool_value(package in bundle_tap_installed_names(state))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "bundle/package_type"
// 6: require "trust"
// 7:
// 8: module Homebrew
// 9:   module Bundle
// 10:     class Tap < Homebrew::Bundle::PackageType
// 11:       class << self
// 12:         sig { override.returns(Symbol) }
// 13:         def type = :tap
// 14:
// 15:         sig { override.returns(String) }
// 16:         def check_label = "Tap"
// 17:
// 18:         sig { override.void }
// 19:         def reset!
// 20:           @taps = T.let(nil, T.nilable(T::Array[::Tap]))
// 21:           @installed_taps = T.let(nil, T.nilable(T::Array[String]))
// 22:         end
// 23:
// 24:         sig {
// 25:           override.params(
// 26:             name:       String,
// 27:             no_upgrade: T::Boolean,
// 28:             verbose:    T::Boolean,
// 29:             _options:   Homebrew::Bundle::EntryOption,
// 30:           ).returns(T::Boolean)
// 31:         }
// 32:         def preinstall!(name, no_upgrade: false, verbose: false, **_options)
// 33:           _ = no_upgrade
// 34:
// 35:           if installed_taps.include? name
// 36:             puts "Skipping install of #{name} tap. It is already installed." if verbose
// 37:             return false
// 38:           end
// 39:
// 40:           true
// 41:         end
// 42:
// 43:         sig {
// 44:           override.params(
// 45:             name:         String,
// 46:             preinstall:   T::Boolean,
// 47:             no_upgrade:   T::Boolean,
// 48:             verbose:      T::Boolean,
// 49:             force:        T::Boolean,
// 50:             clone_target: T.nilable(String),
// 51:             _options:     Homebrew::Bundle::EntryOption,
// 52:           ).returns(T::Boolean)
// 53:         }
// 54:         def install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, clone_target: nil,
// 55:                      **_options)
// 56:           _ = no_upgrade
// 57:
// 58:           return true unless preinstall
// 59:
// 60:           puts "Installing #{name} tap. It is not currently installed." if verbose
// 61:           args = []
// 62:           official_tap = name.downcase.start_with? "homebrew/"
// 63:           args << "--force" if force || (official_tap && Homebrew::EnvConfig.developer?)
// 64:
// 65:           success = if clone_target
// 66:             Bundle.brew("tap", name, clone_target, *args, verbose:)
// 67:           else
// 68:             Bundle.brew("tap", name, *args, verbose:)
// 69:           end
// 70:
// 71:           unless success
// 72:             require "bundle/skipper"
// 73:             Homebrew::Bundle::Skipper.tap_failed!(name)
// 74:             return false
// 75:           end
// 76:
// 77:           require "tap"
// 78:           ::Tap.fetch(name).clear_cache
// 79:           installed_taps << name
// 80:           true
// 81:         end
// 82:
// 83:         sig { override.params(_name: String, _options: Homebrew::Bundle::EntryOptions).returns(String) }
// 84:         def install_verb(_name = "", _options = {})
// 85:           "Tapping"
// 86:         end
// 87:
// 88:         sig { override.params(dumped_formulae: T::Array[String], dumped_casks: T::Array[String]).returns(String) }
// 89:         def dump(dumped_formulae: [], dumped_casks: [])
// 90:           taps.map do |tap|
// 91:             remote = if (tap_remote = tap.remote) && tap_remote != tap.default_remote
// 92:               if (api_token = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", false).presence)
// 93:                 # Replace the API token in the remote URL with interpolation.
// 94:                 # Keep the interpolation unevaluated until the Brewfile is evaluated.
// 95:                 tap_remote = tap_remote.gsub api_token, "\#{ENV.fetch(\"HOMEBREW_GITHUB_API_TOKEN\")}"
// 96:               end
// 97:               ", \"#{tap_remote}\""
// 98:             end
// 99:             tapline = "tap \"#{tap.name}\"#{remote}"
// 100:             trusted = if Homebrew::Trust.explicitly_trusted_tap?(tap)
// 101:               true
// 102:             else
// 103:               tap_trust = T.let({}, T::Hash[Symbol, T::Array[String]])
// 104:               {
// 105:                 formula: [:formulae, dumped_formulae],
// 106:                 cask:    [:casks, dumped_casks],
// 107:                 command: [:commands, []],
// 108:               }.each do |type, values|
// 109:                 key, dumped_items = values
// 110:                 trusted_items = Homebrew::Trust.trusted_entries(type).filter_map do |entry|
// 111:                   reference, _, item = entry.rpartition("/")
// 112:                   next if reference.blank? || item.blank?
// 113:                   next if reference != tap.name && !tap.matches_reference?(reference)
// 114:                   next if dumped_items.include?("#{tap.name}/#{item}")
// 115:
// 116:                   item
// 117:                 end.sort.uniq
// 118:                 tap_trust[key] = trusted_items if trusted_items.present?
// 119:               end
// 120:               tap_trust.presence
// 121:             end
// 122:
// 123:             if trusted == true
// 124:               tapline += ", trusted: true"
// 125:             elsif trusted.present?
// 126:               trusted_options = trusted.map do |key, values|
// 127:                 "#{key}: [#{values.map(&:inspect).join(", ")}]"
// 128:               end.join(", ")
// 129:               tapline += ", trusted: { #{trusted_options} }"
// 130:             end
// 131:             tapline
// 132:           end.sort.uniq.join("\n")
// 133:         end
// 134:
// 135:         sig { override.params(describe: T::Boolean, no_restart: T::Boolean).returns(String) }
// 136:         def dump_output(describe: false, no_restart: false)
// 137:           _ = describe
// 138:           _ = no_restart
// 139:
// 140:           dump
// 141:         end
// 142:
// 143:         sig { returns(T::Array[String]) }
// 144:         def tap_names
// 145:           taps.map(&:name)
// 146:         end
// 147:
// 148:         sig { returns(T::Array[String]) }
// 149:         def installed_taps
// 150:           @installed_taps ||= T.let(tap_names, T.nilable(T::Array[String]))
// 151:         end
// 152:
// 153:         sig { returns(T::Array[::Tap]) }
// 154:         def taps
// 155:           @taps ||= begin
// 156:             require "tap"
// 157:             ::Tap.select(&:installed?).to_a
// 158:           end
// 159:         end
// 160:         private :taps
// 161:       end
// 162:
// 163:       sig {
// 164:         override.params(entries: T::Array[Dsl::Entry], exit_on_first_error: T::Boolean,
// 165:                         no_upgrade: T::Boolean, verbose: T::Boolean).returns(T::Array[String])
// 166:       }
// 167:       def find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 168:         _ = exit_on_first_error
// 169:         _ = no_upgrade
// 170:         _ = verbose
// 171:
// 172:         requested_taps = format_checkable(entries)
// 173:         return [] if requested_taps.empty?
// 174:
// 175:         current_taps = self.class.tap_names
// 176:         (requested_taps - current_taps).map { |entry| "Tap #{entry} needs to be tapped." }
// 177:       end
// 178:
// 179:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 180:       def installed_and_up_to_date?(package, no_upgrade: false)
// 181:         _ = no_upgrade
// 182:
// 183:         self.class.installed_taps.include?(T.cast(package, String))
// 184:       end
// 185:     end
// 186:   end
// 187: end
