module bundle

// Translated from Homebrew/brew `bundle/tap.rb`.
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
