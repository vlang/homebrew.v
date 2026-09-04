module bundle

import ruby
import homebrew

// Translated from Homebrew/brew `bundle/cask.rb`.
pub struct BundleCask {
pub:
	name                 string
	full_name            string
	desc                 string
	explicit             map[string]ruby.Value
	old_tokens           []string
	formula_dependencies []string
	pinned               bool
	outdated             bool
	greedy_outdated      bool
}

pub struct BundleCaskState {
pub:
	cask_available     bool
	casks              []BundleCask
	loadable_casks     []BundleCask
	installed_casks    []string
	installed_override bool
	outdated_casks     []string
	outdated_override  bool
	trusted_casks      []string
	home_dir           string
}

pub struct BundleCaskOptions {
pub:
	full_name   string
	trusted     bool
	greedy      bool
	args        map[string]ruby.Value
	postinstall string
}

pub struct BundleCaskEffects {
pub:
	command_results     map[string]bool
	postinstall_results map[string]bool
}

pub struct BundleCaskActionResult {
pub:
	success  bool
	state    BundleCaskState
	commands [][]string
	trusted  []string
	output   []string
}

pub struct BundleCaskInstalledResult {
pub:
	installed bool
	warning   string
}

fn bundle_cask_nil_value() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn bundle_cask_strings_value(values []string) ruby.Value {
	return ruby.string_array_value(values)
}

fn bundle_cask_strings_from_value(value ruby.Value) []string {
	return value.as_string_array() or { [] }
}

fn bundle_cask_bool(value ruby.Value, fallback bool) bool {
	return value.as_bool() or { fallback }
}

pub fn bundle_cask_value(cask BundleCask) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: cask.name
		map_data: {
			'name':                 ruby.string_value(cask.name)
			'full_name':            ruby.string_value(cask.full_name)
			'desc':                 if cask.desc == '' {
				bundle_cask_nil_value()
			} else {
				ruby.string_value(cask.desc)
			}
			'explicit':             ruby.map_value(cask.explicit)
			'old_tokens':           bundle_cask_strings_value(cask.old_tokens)
			'formula_dependencies': bundle_cask_strings_value(cask.formula_dependencies)
			'pinned?':              ruby.bool_value(cask.pinned)
			'outdated?':            ruby.bool_value(cask.outdated)
			'greedy_outdated?':     ruby.bool_value(cask.greedy_outdated)
		}
		attributes: {
			'name':      cask.name
			'full_name': cask.full_name
		}
	}
}

pub fn bundle_cask_from_value(value ruby.Value) BundleCask {
	fields := value.map_data.clone()
	return BundleCask{
		name: (fields['name'] or { ruby.string_value(value.repr) }).as_string()
		full_name: (fields['full_name'] or { ruby.string_value(value.attributes['full_name'] or { value.repr }) }).as_string()
		desc: if (fields['desc'] or { bundle_cask_nil_value() }).type_name in ['Nil', 'NilClass'] {
			''
		} else {
			(fields['desc'] or { bundle_cask_nil_value() }).as_string()
		}
		explicit: (fields['explicit'] or { ruby.map_value({}) }).as_map() or { map[string]ruby.Value{} }
		old_tokens: bundle_cask_strings_from_value(fields['old_tokens'] or { bundle_cask_strings_value([]) })
		formula_dependencies: bundle_cask_strings_from_value(fields['formula_dependencies'] or { bundle_cask_strings_value([]) })
		pinned: bundle_cask_bool(fields['pinned?'] or { ruby.bool_value(false) }, false)
		outdated: bundle_cask_bool(fields['outdated?'] or { ruby.bool_value(false) }, false)
		greedy_outdated: bundle_cask_bool(fields['greedy_outdated?'] or { ruby.bool_value(false) }, false)
	}
}

fn bundle_casks_value(casks []BundleCask) ruby.Value {
	return ruby.array_value(casks.map(bundle_cask_value(it)))
}

fn bundle_casks_from_value(value ruby.Value) []BundleCask {
	return value.as_array() or { [] }.map(bundle_cask_from_value(it))
}

pub fn bundle_cask_state_value(state BundleCaskState) ruby.Value {
	return ruby.Value{
		type_name: 'Homebrew::Bundle::Cask::State'
		array_data: state.casks.map(bundle_cask_value(it))
		map_data: {
			'cask_available':     ruby.bool_value(state.cask_available)
			'loadable_casks':     bundle_casks_value(state.loadable_casks)
			'installed_casks':    bundle_cask_strings_value(state.installed_casks)
			'installed_override': ruby.bool_value(state.installed_override)
			'outdated_casks':     bundle_cask_strings_value(state.outdated_casks)
			'outdated_override':  ruby.bool_value(state.outdated_override)
			'trusted_casks':      bundle_cask_strings_value(state.trusted_casks)
			'home_dir':           ruby.string_value(state.home_dir)
		}
	}
}

pub fn bundle_cask_state_from_value(value ruby.Value) BundleCaskState {
	fields := value.map_data.clone()
	return BundleCaskState{
		cask_available: bundle_cask_bool(fields['cask_available'] or { ruby.bool_value(false) }, false)
		casks: value.array_data.map(bundle_cask_from_value(it))
		loadable_casks: bundle_casks_from_value(fields['loadable_casks'] or { bundle_casks_value([]) })
		installed_casks: bundle_cask_strings_from_value(fields['installed_casks'] or { bundle_cask_strings_value([]) })
		installed_override: bundle_cask_bool(fields['installed_override'] or { ruby.bool_value(false) }, false)
		outdated_casks: bundle_cask_strings_from_value(fields['outdated_casks'] or { bundle_cask_strings_value([]) })
		outdated_override: bundle_cask_bool(fields['outdated_override'] or { ruby.bool_value(false) }, false)
		trusted_casks: bundle_cask_strings_from_value(fields['trusted_casks'] or { bundle_cask_strings_value([]) })
		home_dir: (fields['home_dir'] or { ruby.string_value('') }).as_string()
	}
}

pub fn bundle_cask_options_value(options BundleCaskOptions) ruby.Value {
	return ruby.map_value({
		'full_name':   if options.full_name == '' {
			bundle_cask_nil_value()
		} else {
			ruby.string_value(options.full_name)
		}
		'trusted':     ruby.bool_value(options.trusted)
		'greedy':      ruby.bool_value(options.greedy)
		'args':        ruby.map_value(options.args)
		'postinstall': if options.postinstall == '' {
			bundle_cask_nil_value()
		} else {
			ruby.string_value(options.postinstall)
		}
	})
}

pub fn bundle_cask_options_from_value(value ruby.Value) BundleCaskOptions {
	fields := value.as_map() or { map[string]ruby.Value{} }
	return BundleCaskOptions{
		full_name: if (fields['full_name'] or { bundle_cask_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''
		} else {
			(fields['full_name'] or { bundle_cask_nil_value() }).as_string()
		}
		trusted: bundle_cask_bool(fields['trusted'] or { ruby.bool_value(false) }, false)
		greedy: bundle_cask_bool(fields['greedy'] or { ruby.bool_value(false) }, false)
		args: (fields['args'] or { ruby.map_value({}) }).as_map() or { map[string]ruby.Value{} }
		postinstall: if (fields['postinstall'] or { bundle_cask_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''
		} else {
			(fields['postinstall'] or { bundle_cask_nil_value() }).as_string()
		}
	}
}

pub fn bundle_cask_effects_value(effects BundleCaskEffects) ruby.Value {
	mut commands := map[string]ruby.Value{}
	for key, value in effects.command_results {
		commands[key] = ruby.bool_value(value)
	}
	mut postinstalls := map[string]ruby.Value{}
	for key, value in effects.postinstall_results {
		postinstalls[key] = ruby.bool_value(value)
	}
	return ruby.map_value({
		'command_results':     ruby.map_value(commands)
		'postinstall_results': ruby.map_value(postinstalls)
	})
}

pub fn bundle_cask_effects_from_value(value ruby.Value) BundleCaskEffects {
	fields := value.as_map() or { map[string]ruby.Value{} }
	mut command_results := map[string]bool{}
	for key, result in (fields['command_results'] or { ruby.map_value({}) }).as_map() or { map[string]ruby.Value{} } {
		command_results[key] = bundle_cask_bool(result, false)
	}
	mut postinstall_results := map[string]bool{}
	for key, result in (fields['postinstall_results'] or { ruby.map_value({}) }).as_map() or { map[string]ruby.Value{} } {
		postinstall_results[key] = bundle_cask_bool(result, false)
	}
	return BundleCaskEffects{
		command_results: command_results
		postinstall_results: postinstall_results
	}
}

fn bundle_cask_action_value(result BundleCaskActionResult) ruby.Value {
	return ruby.map_value({
		'result':   ruby.bool_value(result.success)
		'state':    bundle_cask_state_value(result.state)
		'commands': ruby.array_value(result.commands.map(ruby.string_array_value(it)))
		'trusted':  bundle_cask_strings_value(result.trusted)
		'output':   bundle_cask_strings_value(result.output)
	})
}

pub fn bundle_cask_reset(state BundleCaskState) BundleCaskState {
	return BundleCaskState{
		cask_available: state.cask_available
		casks: state.casks.clone()
		loadable_casks: state.loadable_casks.clone()
		trusted_casks: state.trusted_casks.clone()
		home_dir: state.home_dir
	}
}

pub fn bundle_cask_casks(state BundleCaskState) []BundleCask {
	return if state.cask_available { state.casks.clone() } else { [] }
}

pub fn bundle_cask_names(state BundleCaskState) []string {
	return bundle_cask_casks(state).map(it.name)
}

pub fn bundle_cask_outdated_names(state BundleCaskState) []string {
	if !state.cask_available {
		return []
	}
	return state.casks.filter(!it.pinned && it.outdated).map(it.name)
}

pub fn bundle_cask_installed_names(state BundleCaskState) []string {
	return if state.installed_override {
		state.installed_casks.clone()
	} else {
		bundle_cask_names(state)
	}
}

pub fn bundle_cask_outdated_casks(state BundleCaskState) []string {
	return if state.outdated_override {
		state.outdated_casks.clone()
	} else {
		bundle_cask_outdated_names(state)
	}
}

pub fn bundle_cask_oldnames(state BundleCaskState) map[string]string {
	mut oldnames := map[string]string{}
	for cask in bundle_cask_casks(state) {
		for oldname in cask.old_tokens {
			oldnames[oldname] = cask.full_name
			if tap := homebrew.tap_from_full_name(cask.full_name) {
				oldnames['${tap}/${oldname}'] = cask.full_name
			}
		}
	}
	return oldnames
}

pub fn bundle_cask_in_array(cask string, values []string) bool {
	return cask in values || homebrew.name_from_full_name(cask) in values
}

pub fn bundle_cask_installed_result(state BundleCaskState, cask string) BundleCaskInstalledResult {
	installed := bundle_cask_installed_names(state)
	if bundle_cask_in_array(cask, installed) {
		return BundleCaskInstalledResult{ installed: true }
	}
	oldnames := bundle_cask_oldnames(state)
	oldname := oldnames[cask] or { oldnames[homebrew.name_from_full_name(cask)] or { '' } }
	if oldname == '' || !bundle_cask_in_array(oldname, installed) {
		return BundleCaskInstalledResult{}
	}
	return BundleCaskInstalledResult{
		installed: true
		warning: '${cask} was renamed to ${oldname}'
	}
}

pub fn bundle_cask_installed(state BundleCaskState, cask string) bool {
	return bundle_cask_installed_result(state, cask).installed
}

pub fn bundle_cask_upgradable(state BundleCaskState, cask string) bool {
	return bundle_cask_in_array(cask, bundle_cask_outdated_casks(state))
}

pub fn bundle_cask_greedy_outdated(state BundleCaskState, name string) bool {
	if !state.cask_available {
		return false
	}
	for cask in state.casks {
		if cask.name == name {
			return !cask.pinned && cask.greedy_outdated
		}
	}
	return false
}

pub fn bundle_cask_upgrading(state BundleCaskState, no_upgrade bool, name string, options BundleCaskOptions) bool {
	if no_upgrade {
		return false
	}
	if bundle_cask_upgradable(state, name) {
		return true
	}
	return options.greedy && bundle_cask_greedy_outdated(state, name)
}

pub fn bundle_cask_installed_and_up_to_date(state BundleCaskState, cask string, no_upgrade bool) bool {
	if !bundle_cask_installed(state, cask) {
		return false
	}
	return no_upgrade || !bundle_cask_upgradable(state, cask)
}

pub fn bundle_cask_install_verb(state BundleCaskState, name string, options BundleCaskOptions) string {
	return if !bundle_cask_installed(state, name) || !bundle_cask_upgrading(state, false, name, options) {
		'Installing'
	} else {
		'Upgrading'
	}
}

pub fn bundle_cask_preinstall(state BundleCaskState, name string, no_upgrade bool, verbose bool, options BundleCaskOptions) (bool, []string) {
	if bundle_cask_installed(state, name) && !bundle_cask_upgrading(state, no_upgrade, name, options) {
		return false, if verbose {
			['Skipping install of ${name} cask. It is already installed.']
		} else {
			[]
		}
	}
	return true, []string{}
}

fn bundle_cask_unique(values []string) []string {
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

pub fn bundle_cask_install_args(options BundleCaskOptions, force bool) []string {
	mut arguments := []string{}
	for key, value in options.args {
		if value.type_name == 'Bool' {
			if value.bool_data {
				arguments << '--${key}'
			}
		} else if value.type_name !in ['Nil', 'NilClass'] {
			arguments << '--${key}=${value.as_string()}'
		}
	}
	if force {
		arguments << '--force'
	}
	if '--force' !in arguments {
		arguments << '--adopt'
	}
	return bundle_cask_unique(arguments)
}

fn bundle_cask_command_result(effects BundleCaskEffects, command []string) bool {
	return effects.command_results[command.join('\x1f')] or { false }
}

pub fn bundle_cask_postinstall(name string, options BundleCaskOptions, verbose bool, effects BundleCaskEffects) (bool, []string) {
	if options.postinstall.trim_space() == '' {
		return true, []string{}
	}
	result := effects.postinstall_results[options.postinstall] or { false }
	return result, if verbose {
		['Running postinstall for ${name}: ${options.postinstall}']
	} else {
		[]
	}
}

pub fn bundle_cask_install(state BundleCaskState, name string, preinstall bool, no_upgrade bool, verbose bool, force bool, options BundleCaskOptions, effects BundleCaskEffects) BundleCaskActionResult {
	if !preinstall {
		return BundleCaskActionResult{ success: true, state: state }
	}
	full_name := if options.full_name != '' { options.full_name } else { name }
	mut commands := [][]string{}
	mut trusted := []string{}
	mut output := []string{}
	if options.trusted && homebrew.is_full_name(full_name) {
		trusted << full_name
	}
	mut updated := state
	mut install_result := false
	if bundle_cask_installed(state, name) && bundle_cask_upgrading(state, no_upgrade, name, options) {
		status := if options.greedy { 'may not be' } else { 'not' }
		if verbose {
			output << 'Upgrading ${name} cask. It is installed but ${status} up-to-date.'
		}
		command := ['upgrade', '--cask', full_name]
		commands << command
		install_result = bundle_cask_command_result(effects, command)
	} else {
		arguments := bundle_cask_install_args(options, force)
		if verbose {
			with_args := if arguments.len > 0 { ' with ${arguments.join(' ')}' } else { '' }
			output << 'Installing ${name} cask${with_args}. It is not currently installed.'
		}
		mut command := ['install', '--cask', full_name]
		command << arguments
		commands << command
		install_result = bundle_cask_command_result(effects, command)
		if install_result {
			mut installed := bundle_cask_installed_names(updated)
			installed << name
			updated = BundleCaskState{
				...updated
				installed_casks: bundle_cask_unique(installed)
				installed_override: true
			}
		}
	}
	mut result := install_result
	if bundle_cask_installed(updated, name) {
		postinstall_result, postinstall_output := bundle_cask_postinstall(name, options, verbose, effects)
		output << postinstall_output
		result = result && postinstall_result
	}
	return BundleCaskActionResult{
		success: result
		state: updated
		commands: commands
		trusted: trusted
		output: output
	}
}

pub fn bundle_cask_fetchable_name(state BundleCaskState, name string, options BundleCaskOptions, no_upgrade bool) ?string {
	if !bundle_cask_installed(state, name) || bundle_cask_upgrading(state, no_upgrade, name, options) {
		return if options.full_name != '' { options.full_name } else { name }
	}
	return none
}

pub fn bundle_cask_explicit_s(explicit map[string]ruby.Value, home_dir string) string {
	mut values := []string{}
	for original_key, original_value in explicit {
		mut key := original_key
		mut value := original_value.as_string()
		if key == 'languages' {
			key = 'language'
			value = original_value.as_string_array() or { [] }.join(',')
		}
		if home_dir != '' && value.starts_with(home_dir) {
			value = '~${value[home_dir.len..]}'
		}
		values << '${key}: "${value}"'
	}
	return values.join(', ')
}

pub fn bundle_cask_dump(state BundleCaskState, describe bool) string {
	mut lines := []string{}
	for cask in bundle_cask_casks(state) {
		if describe && cask.desc != '' {
			lines << '# ${cask.desc}'
		}
		mut line := 'cask "${cask.full_name}"'
		if cask.explicit.len > 0 {
			line += ', args: { ${bundle_cask_explicit_s(cask.explicit, state.home_dir)} }'
		}
		if cask.full_name in state.trusted_casks {
			line += ', trusted: true'
		}
		lines << line
	}
	return lines.join('\n')
}

pub fn bundle_cask_formula_dependencies(state BundleCaskState, names []string) []string {
	if names.len == 0 {
		return []
	}
	mut dependencies := []string{}
	for name in names {
		mut found := false
		for cask in bundle_cask_casks(state) {
			if cask.name == name || cask.full_name == name {
				dependencies << cask.formula_dependencies
				found = true
				break
			}
		}
		if found {
			continue
		}
		for cask in state.loadable_casks {
			if cask.name == name || cask.full_name == name {
				dependencies << cask.formula_dependencies
				break
			}
		}
	}
	return dependencies
}
