module bundle

import brew_runtime
import homebrew

// Translated from Homebrew/brew `bundle/cask.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct BundleCask {
pub:
	name                 string
	full_name            string
	desc                 string
	explicit             map[string]brew_runtime.Value
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
	args        map[string]brew_runtime.Value
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

fn bundle_cask_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

fn bundle_cask_strings_value(values []string) brew_runtime.Value {
	return brew_runtime.string_array_value(values)
}

fn bundle_cask_strings_from_value(value brew_runtime.Value) []string {
	return value.as_string_array() or { [] }
}

fn bundle_cask_bool(value brew_runtime.Value, fallback bool) bool {
	return value.as_bool() or { fallback }
}

pub fn bundle_cask_value(cask BundleCask) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Cask::Cask'
		repr: cask.name
		map_data: {
			'name':                 brew_runtime.string_value(cask.name)
			'full_name':            brew_runtime.string_value(cask.full_name)
			'desc':                 if cask.desc == '' {
				bundle_cask_nil_value()} else {
				brew_runtime.string_value(cask.desc)}
			'explicit':             brew_runtime.map_value(cask.explicit)
			'old_tokens':           bundle_cask_strings_value(cask.old_tokens)
			'formula_dependencies': bundle_cask_strings_value(cask.formula_dependencies)
			'pinned?':              brew_runtime.bool_value(cask.pinned)
			'outdated?':            brew_runtime.bool_value(cask.outdated)
			'greedy_outdated?':     brew_runtime.bool_value(cask.greedy_outdated)
		}
		attributes: {
			'name':      cask.name
			'full_name': cask.full_name
		}
	}
}

pub fn bundle_cask_from_value(value brew_runtime.Value) BundleCask {
	fields := value.map_data.clone()
	return BundleCask{
		name: (fields['name'] or { brew_runtime.string_value(value.repr) }).as_string()
		full_name: (fields['full_name'] or { brew_runtime.string_value(value.attributes['full_name'] or { value.repr }) }).as_string()
		desc: if (fields['desc'] or { bundle_cask_nil_value() }).type_name in ['Nil', 'NilClass'] {
			''} else {
			(fields['desc'] or { bundle_cask_nil_value() }).as_string()}
		explicit: (fields['explicit'] or { brew_runtime.map_value({}) }).as_map() or { map[string]brew_runtime.Value{} }
		old_tokens: bundle_cask_strings_from_value(fields['old_tokens'] or { bundle_cask_strings_value([]) })
		formula_dependencies: bundle_cask_strings_from_value(fields['formula_dependencies'] or { bundle_cask_strings_value([]) })
		pinned: bundle_cask_bool(fields['pinned?'] or { brew_runtime.bool_value(false) }, false)
		outdated: bundle_cask_bool(fields['outdated?'] or { brew_runtime.bool_value(false) }, false)
		greedy_outdated: bundle_cask_bool(fields['greedy_outdated?'] or { brew_runtime.bool_value(false) }, false)
	}
}

fn bundle_casks_value(casks []BundleCask) brew_runtime.Value {
	return brew_runtime.array_value(casks.map(bundle_cask_value(it)))
}

fn bundle_casks_from_value(value brew_runtime.Value) []BundleCask {
	return value.as_array() or { [] }.map(bundle_cask_from_value(it))
}

pub fn bundle_cask_state_value(state BundleCaskState) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Homebrew::Bundle::Cask::State'
		array_data: state.casks.map(bundle_cask_value(it))
		map_data: {
			'cask_available':     brew_runtime.bool_value(state.cask_available)
			'loadable_casks':     bundle_casks_value(state.loadable_casks)
			'installed_casks':    bundle_cask_strings_value(state.installed_casks)
			'installed_override': brew_runtime.bool_value(state.installed_override)
			'outdated_casks':     bundle_cask_strings_value(state.outdated_casks)
			'outdated_override':  brew_runtime.bool_value(state.outdated_override)
			'trusted_casks':      bundle_cask_strings_value(state.trusted_casks)
			'home_dir':           brew_runtime.string_value(state.home_dir)
		}
	}
}

pub fn bundle_cask_state_from_value(value brew_runtime.Value) BundleCaskState {
	fields := value.map_data.clone()
	return BundleCaskState{
		cask_available: bundle_cask_bool(fields['cask_available'] or { brew_runtime.bool_value(false) }, false)
		casks: value.array_data.map(bundle_cask_from_value(it))
		loadable_casks: bundle_casks_from_value(fields['loadable_casks'] or { bundle_casks_value([]) })
		installed_casks: bundle_cask_strings_from_value(fields['installed_casks'] or { bundle_cask_strings_value([]) })
		installed_override: bundle_cask_bool(fields['installed_override'] or { brew_runtime.bool_value(false) }, false)
		outdated_casks: bundle_cask_strings_from_value(fields['outdated_casks'] or { bundle_cask_strings_value([]) })
		outdated_override: bundle_cask_bool(fields['outdated_override'] or { brew_runtime.bool_value(false) }, false)
		trusted_casks: bundle_cask_strings_from_value(fields['trusted_casks'] or { bundle_cask_strings_value([]) })
		home_dir: (fields['home_dir'] or { brew_runtime.string_value('') }).as_string()
	}
}

pub fn bundle_cask_options_value(options BundleCaskOptions) brew_runtime.Value {
	return brew_runtime.map_value({
		'full_name':   if options.full_name == '' {
			bundle_cask_nil_value()
		} else {
			brew_runtime.string_value(options.full_name)
		}
		'trusted':     brew_runtime.bool_value(options.trusted)
		'greedy':      brew_runtime.bool_value(options.greedy)
		'args':        brew_runtime.map_value(options.args)
		'postinstall': if options.postinstall == '' {
			bundle_cask_nil_value()
		} else {
			brew_runtime.string_value(options.postinstall)
		}
	})
}

pub fn bundle_cask_options_from_value(value brew_runtime.Value) BundleCaskOptions {
	fields := value.as_map() or { map[string]brew_runtime.Value{} }
	return BundleCaskOptions{
		full_name: if (fields['full_name'] or { bundle_cask_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''} else {
			(fields['full_name'] or { bundle_cask_nil_value() }).as_string()}
		trusted: bundle_cask_bool(fields['trusted'] or { brew_runtime.bool_value(false) }, false)
		greedy: bundle_cask_bool(fields['greedy'] or { brew_runtime.bool_value(false) }, false)
		args: (fields['args'] or { brew_runtime.map_value({}) }).as_map() or { map[string]brew_runtime.Value{} }
		postinstall: if (fields['postinstall'] or { bundle_cask_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''} else {
			(fields['postinstall'] or { bundle_cask_nil_value() }).as_string()}
	}
}

pub fn bundle_cask_effects_value(effects BundleCaskEffects) brew_runtime.Value {
	mut commands := map[string]brew_runtime.Value{}
	for key, value in effects.command_results {
		commands[key] = brew_runtime.bool_value(value)
	}
	mut postinstalls := map[string]brew_runtime.Value{}
	for key, value in effects.postinstall_results {
		postinstalls[key] = brew_runtime.bool_value(value)
	}
	return brew_runtime.map_value({
		'command_results':     brew_runtime.map_value(commands)
		'postinstall_results': brew_runtime.map_value(postinstalls)
	})
}

pub fn bundle_cask_effects_from_value(value brew_runtime.Value) BundleCaskEffects {
	fields := value.as_map() or { map[string]brew_runtime.Value{} }
	mut command_results := map[string]bool{}
	for key, result in (fields['command_results'] or { brew_runtime.map_value({}) }).as_map() or { map[string]brew_runtime.Value{} } {
		command_results[key] = bundle_cask_bool(result, false)
	}
	mut postinstall_results := map[string]bool{}
	for key, result in (fields['postinstall_results'] or { brew_runtime.map_value({}) }).as_map() or { map[string]brew_runtime.Value{} } {
		postinstall_results[key] = bundle_cask_bool(result, false)
	}
	return BundleCaskEffects{
		command_results: command_results
		postinstall_results: postinstall_results
	}
}

fn bundle_cask_action_value(result BundleCaskActionResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'result':   brew_runtime.bool_value(result.success)
		'state':    bundle_cask_state_value(result.state)
		'commands': brew_runtime.array_value(result.commands.map(brew_runtime.string_array_value(it)))
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

pub fn bundle_cask_explicit_s(explicit map[string]brew_runtime.Value, home_dir string) string {
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

// Ruby method `type = :cask` at line 16.
pub fn ruby_cask_l16_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Symbol', 'cask')
}

// Ruby method `check_label = "Cask"` at line 19.
pub fn ruby_cask_l19_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Cask')
}

// Ruby method `reset!` at line 22.
pub fn ruby_cask_l22_d3_reset(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	return bundle_cask_state_value(bundle_cask_reset(state))
}

// Ruby method `casks` at line 31.
pub fn ruby_cask_l31_d4_casks(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	return bundle_casks_value(bundle_cask_casks(state))
}

// Ruby method `install_verb(name, options = {})` at line 44.
pub fn ruby_cask_l44_d5_install_verb(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	options := if args.len > 2 {
		bundle_cask_options_from_value(args[2])
	} else {
		BundleCaskOptions{}
	}
	return brew_runtime.string_value(bundle_cask_install_verb(state, name, options))
}

// Ruby method `preinstall!(name, no_upgrade: false, verbose: false, **options)` at line 51.
pub fn ruby_cask_l51_d6_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	no_upgrade := if args.len > 2 { bundle_cask_bool(args[2], false) } else { false }
	verbose := if args.len > 3 { bundle_cask_bool(args[3], false) } else { false }
	options := if args.len > 4 {
		bundle_cask_options_from_value(args[4])
	} else {
		BundleCaskOptions{}
	}
	result, output := bundle_cask_preinstall(state, name, no_upgrade, verbose, options)
	return brew_runtime.map_value({
		'result': brew_runtime.bool_value(result)
		'output': bundle_cask_strings_value(output)
	})
}

// Ruby method `install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, **options)` at line 64.
pub fn ruby_cask_l64_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	preinstall := if args.len > 2 { bundle_cask_bool(args[2], true) } else { true }
	no_upgrade := if args.len > 3 { bundle_cask_bool(args[3], false) } else { false }
	verbose := if args.len > 4 { bundle_cask_bool(args[4], false) } else { false }
	force := if args.len > 5 { bundle_cask_bool(args[5], false) } else { false }
	options := if args.len > 6 {
		bundle_cask_options_from_value(args[6])
	} else {
		BundleCaskOptions{}
	}
	effects := if args.len > 7 {
		bundle_cask_effects_from_value(args[7])
	} else {
		BundleCaskEffects{}
	}
	return bundle_cask_action_value(bundle_cask_install(state, name, preinstall, no_upgrade, verbose, force, options, effects))
}

// Ruby method `installable_or_upgradable?(name, no_upgrade: false, **options)` at line 114.
pub fn ruby_cask_l114_d8_installable_or_upgradable(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	no_upgrade := if args.len > 2 { bundle_cask_bool(args[2], false) } else { false }
	options := if args.len > 3 {
		bundle_cask_options_from_value(args[3])
	} else {
		BundleCaskOptions{}
	}
	return brew_runtime.bool_value(!bundle_cask_installed(state, name) || bundle_cask_upgrading(state, no_upgrade, name, options))
}

// Ruby method `fetchable_name(name, options = {}, no_upgrade: false)` at line 119.
pub fn ruby_cask_l119_d9_fetchable_name(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	options := if args.len > 2 {
		bundle_cask_options_from_value(args[2])
	} else {
		BundleCaskOptions{}
	}
	no_upgrade := if args.len > 3 { bundle_cask_bool(args[3], false) } else { false }
	if fetchable := bundle_cask_fetchable_name(state, name, options, no_upgrade) {
		return brew_runtime.string_value(fetchable)
	}
	return bundle_cask_nil_value()
}

// Ruby method `cask_installed_and_up_to_date?(cask, no_upgrade: false)` at line 127.
pub fn ruby_cask_l127_d10_cask_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	cask := if args.len > 1 { args[1].as_string() } else { '' }
	no_upgrade := if args.len > 2 { bundle_cask_bool(args[2], false) } else { false }
	return brew_runtime.bool_value(bundle_cask_installed_and_up_to_date(state, cask, no_upgrade))
}

// Ruby method `cask_in_array?(cask, array)` at line 135.
pub fn ruby_cask_l135_d11_cask_in_array(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 0 { args[0].as_string() } else { '' }
	values := if args.len > 1 { bundle_cask_strings_from_value(args[1]) } else { [] }
	return brew_runtime.bool_value(bundle_cask_in_array(cask, values))
}

// Ruby method `cask_installed?(cask)` at line 142.
pub fn ruby_cask_l142_d12_cask_installed(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	cask := if args.len > 1 { args[1].as_string() } else { '' }
	result := bundle_cask_installed_result(state, cask)
	return brew_runtime.map_value({
		'result':  brew_runtime.bool_value(result.installed)
		'warning': if result.warning == '' {
			bundle_cask_nil_value()
		} else {
			brew_runtime.string_value(result.warning)
		}
	})
}

// Ruby method `cask_upgradable?(cask)` at line 156.
pub fn ruby_cask_l156_d13_cask_upgradable(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	cask := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.bool_value(bundle_cask_upgradable(state, cask))
}

// Ruby method `installed_casks` at line 161.
pub fn ruby_cask_l161_d14_installed_casks(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	return bundle_cask_strings_value(bundle_cask_installed_names(state))
}

// Ruby method `outdated_casks` at line 166.
pub fn ruby_cask_l166_d15_outdated_casks(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	return bundle_cask_strings_value(bundle_cask_outdated_casks(state))
}

// Ruby method `cask_names` at line 171.
pub fn ruby_cask_l171_d16_cask_names(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	return bundle_cask_strings_value(bundle_cask_names(state))
}

// Ruby method `outdated_cask_names` at line 176.
pub fn ruby_cask_l176_d17_outdated_cask_names(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	return bundle_cask_strings_value(bundle_cask_outdated_names(state))
}

// Ruby method `cask_is_outdated_using_greedy?(cask_name)` at line 185.
pub fn ruby_cask_l185_d18_cask_is_outdated_using_greedy(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.bool_value(bundle_cask_greedy_outdated(state, name))
}

// Ruby method `dump(describe: false)` at line 195.
pub fn ruby_cask_l195_d19_dump(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	describe := if args.len > 1 { bundle_cask_bool(args[1], false) } else { false }
	return brew_runtime.string_value(bundle_cask_dump(state, describe))
}

// Ruby method `dump_output(describe: false, no_restart: false)` at line 207.
pub fn ruby_cask_l207_d20_dump_output(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	describe := if args.len > 1 { bundle_cask_bool(args[1], false) } else { false }
	return brew_runtime.string_value(bundle_cask_dump(state, describe))
}

// Ruby method `cask_oldnames` at line 214.
pub fn ruby_cask_l214_d21_cask_oldnames(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	mut values := map[string]brew_runtime.Value{}
	for key, value in bundle_cask_oldnames(state) {
		values[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `formula_dependencies(cask_list)` at line 229.
pub fn ruby_cask_l229_d22_formula_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	names := if args.len > 1 { bundle_cask_strings_from_value(args[1]) } else { [] }
	return bundle_cask_strings_value(bundle_cask_formula_dependencies(state, names))
}

// Ruby method `upgrading?(no_upgrade, name, options)` at line 253.
pub fn ruby_cask_l253_d23_upgrading(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { bundle_cask_state_from_value(args[0]) } else { BundleCaskState{} }
	no_upgrade := if args.len > 1 { bundle_cask_bool(args[1], false) } else { false }
	name := if args.len > 2 { args[2].as_string() } else { '' }
	options := if args.len > 3 {
		bundle_cask_options_from_value(args[3])
	} else {
		BundleCaskOptions{}
	}
	return brew_runtime.bool_value(bundle_cask_upgrading(state, no_upgrade, name, options))
}

// Ruby method `postinstall_change_state!(name:, options:, verbose:)` at line 262.
pub fn ruby_cask_l262_d24_postinstall_change_state(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	options := if args.len > 1 {
		bundle_cask_options_from_value(args[1])
	} else {
		BundleCaskOptions{}
	}
	verbose := if args.len > 2 { bundle_cask_bool(args[2], false) } else { false }
	effects := if args.len > 3 {
		bundle_cask_effects_from_value(args[3])
	} else {
		BundleCaskEffects{}
	}
	result, output := bundle_cask_postinstall(name, options, verbose, effects)
	return brew_runtime.map_value({
		'result': brew_runtime.bool_value(result)
		'output': bundle_cask_strings_value(output)
	})
}

// Ruby method `explicit_s(cask_config)` at line 271.
pub fn ruby_cask_l271_d25_explicit_s(args ...brew_runtime.Value) brew_runtime.Value {
	explicit := if args.len > 0 {
		args[0].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	home_dir := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.string_value(bundle_cask_explicit_s(explicit, home_dir))
}

// Ruby method `installed_and_up_to_date?(cask, no_upgrade: false)` at line 284.
pub fn ruby_cask_l284_d26_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 || args[1].type_name != 'String' {
		actual := if args.len > 1 { args[1].type_name } else { 'NilClass' }
		repr := if args.len > 1 { args[1].repr } else { '' }
		return brew_runtime.structured_value('RuntimeError', 'cask must be a String, got ${actual}: ${repr}', {
			'message': 'cask must be a String, got ${actual}: ${repr}'
		})
	}
	state := bundle_cask_state_from_value(args[0])
	no_upgrade := if args.len > 2 { bundle_cask_bool(args[2], false) } else { false }
	return brew_runtime.bool_value(bundle_cask_installed_and_up_to_date(state, args[1].as_string(), no_upgrade))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils"
// 5: require "utils/output"
// 6: require "bundle/package_type"
// 7: require "trust"
// 8:
// 9: module Homebrew
// 10:   module Bundle
// 11:     class Cask < Homebrew::Bundle::PackageType
// 12:       extend ::Utils::Output::Mixin
// 13:
// 14:       class << self
// 15:         sig { override.returns(Symbol) }
// 16:         def type = :cask
// 17:
// 18:         sig { override.returns(String) }
// 19:         def check_label = "Cask"
// 20:
// 21:         sig { override.void }
// 22:         def reset!
// 23:           @casks = T.let(nil, T.nilable(T::Array[::Cask::Cask]))
// 24:           @cask_names = T.let(nil, T.nilable(T::Array[String]))
// 25:           @cask_oldnames = T.let(nil, T.nilable(T::Hash[String, String]))
// 26:           @installed_casks = T.let(nil, T.nilable(T::Array[String]))
// 27:           @outdated_casks = T.let(nil, T.nilable(T::Array[String]))
// 28:         end
// 29:
// 30:         sig { returns(T::Array[::Cask::Cask]) }
// 31:         def casks
// 32:           return [] unless Bundle.cask_installed?
// 33:
// 34:           require "cask/caskroom"
// 35:           @casks ||= T.let(::Cask::Caskroom.casks, T.nilable(T::Array[::Cask::Cask]))
// 36:         end
// 37:
// 38:         # Override makes `name` a required argument unlike the parent's default-argument signature.
// 39:         # rubocop:disable Sorbet/AllowIncompatibleOverride
// 40:         sig {
// 41:           override(allow_incompatible: true).params(name: String, options: Homebrew::Bundle::EntryOptions).returns(String)
// 42:         }
// 43:         # rubocop:enable Sorbet/AllowIncompatibleOverride
// 44:         def install_verb(name, options = {})
// 45:           return "Installing" if !cask_installed?(name) || !upgrading?(false, name, options)
// 46:
// 47:           "Upgrading"
// 48:         end
// 49:
// 50:         sig { override.params(name: String, no_upgrade: T::Boolean, verbose: T::Boolean, options: T.untyped).returns(T::Boolean) }
// 51:         def preinstall!(name, no_upgrade: false, verbose: false, **options)
// 52:           if cask_installed?(name) && !upgrading?(no_upgrade, name, options)
// 53:             puts "Skipping install of #{name} cask. It is already installed." if verbose
// 54:             return false
// 55:           end
// 56:
// 57:           true
// 58:         end
// 59:
// 60:         sig {
// 61:           override.params(name: String, preinstall: T::Boolean, no_upgrade: T::Boolean, verbose: T::Boolean,
// 62:                           force: T::Boolean, options: T.untyped).returns(T::Boolean)
// 63:         }
// 64:         def install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, **options)
// 65:           return true unless preinstall
// 66:
// 67:           full_name = T.cast(options.fetch(:full_name, name), String)
// 68:
// 69:           # Only fully-qualified names map to a tap, so unqualified tokens
// 70:           # cannot be meaningfully trusted.
// 71:           Homebrew::Trust.trust!(:cask, full_name) if options[:trusted] && Utils.full_name?(full_name)
// 72:
// 73:           install_result = if cask_installed?(name) && upgrading?(no_upgrade, name, options)
// 74:             status = "#{options[:greedy] ? "may not be" : "not"} up-to-date"
// 75:             puts "Upgrading #{name} cask. It is installed but #{status}." if verbose
// 76:             Bundle.brew("upgrade", "--cask", full_name, verbose:)
// 77:           else
// 78:             args = options.fetch(:args, []).filter_map do |k, v|
// 79:               case v
// 80:               when TrueClass
// 81:                 "--#{k}"
// 82:               when FalseClass, NilClass
// 83:                 nil
// 84:               else
// 85:                 "--#{k}=#{v}"
// 86:               end
// 87:             end
// 88:
// 89:             args << "--force" if force
// 90:             args << "--adopt" unless args.include?("--force")
// 91:             args.uniq!
// 92:
// 93:             with_args = " with #{args.join(" ")}" if args.present?
// 94:             puts "Installing #{name} cask#{with_args}. It is not currently installed." if verbose
// 95:
// 96:             if Bundle.brew("install", "--cask", full_name, *args, verbose:)
// 97:               installed_casks << name
// 98:               true
// 99:             else
// 100:               false
// 101:             end
// 102:           end
// 103:           result = install_result
// 104:
// 105:           if cask_installed?(name)
// 106:             postinstall_result = postinstall_change_state!(name:, options:, verbose:)
// 107:             result &&= postinstall_result
// 108:           end
// 109:
// 110:           result
// 111:         end
// 112:
// 113:         sig { params(name: String, no_upgrade: T::Boolean, options: T.untyped).returns(T::Boolean) }
// 114:         def installable_or_upgradable?(name, no_upgrade: false, **options)
// 115:           !cask_installed?(name) || upgrading?(no_upgrade, name, options)
// 116:         end
// 117:
// 118:         sig { params(name: String, options: Homebrew::Bundle::EntryOptions, no_upgrade: T::Boolean).returns(T.nilable(String)) }
// 119:         def fetchable_name(name, options = {}, no_upgrade: false)
// 120:           full_name = T.cast(options.fetch(:full_name, name), String)
// 121:           return unless installable_or_upgradable?(name, no_upgrade:, **options)
// 122:
// 123:           full_name
// 124:         end
// 125:
// 126:         sig { params(cask: String, no_upgrade: T::Boolean).returns(T::Boolean) }
// 127:         def cask_installed_and_up_to_date?(cask, no_upgrade: false)
// 128:           return false unless cask_installed?(cask)
// 129:           return true if no_upgrade
// 130:
// 131:           !cask_upgradable?(cask)
// 132:         end
// 133:
// 134:         sig { params(cask: String, array: T::Array[String]).returns(T::Boolean) }
// 135:         def cask_in_array?(cask, array)
// 136:           return true if array.include?(cask)
// 137:
// 138:           array.include?(Utils.name_from_full_name(cask))
// 139:         end
// 140:
// 141:         sig { params(cask: String).returns(T::Boolean) }
// 142:         def cask_installed?(cask)
// 143:           return true if cask_in_array?(cask, installed_casks)
// 144:
// 145:           old_name = cask_oldnames[cask]
// 146:           old_name ||= cask_oldnames[Utils.name_from_full_name(cask)]
// 147:           return false unless old_name
// 148:           return false unless cask_in_array?(old_name, installed_casks)
// 149:
// 150:           opoo "#{cask} was renamed to #{old_name}"
// 151:
// 152:           true
// 153:         end
// 154:
// 155:         sig { params(cask: String).returns(T::Boolean) }
// 156:         def cask_upgradable?(cask)
// 157:           cask_in_array?(cask, outdated_casks)
// 158:         end
// 159:
// 160:         sig { returns(T::Array[String]) }
// 161:         def installed_casks
// 162:           @installed_casks ||= cask_names
// 163:         end
// 164:
// 165:         sig { returns(T::Array[String]) }
// 166:         def outdated_casks
// 167:           @outdated_casks ||= outdated_cask_names
// 168:         end
// 169:
// 170:         sig { returns(T::Array[String]) }
// 171:         def cask_names
// 172:           @cask_names ||= casks.map(&:to_s)
// 173:         end
// 174:
// 175:         sig { returns(T::Array[String]) }
// 176:         def outdated_cask_names
// 177:           return [] unless Bundle.cask_installed?
// 178:
// 179:           casks.reject(&:pinned?)
// 180:                .select { |c| c.outdated?(greedy: false) }
// 181:                .map(&:to_s)
// 182:         end
// 183:
// 184:         sig { params(cask_name: String).returns(T::Boolean) }
// 185:         def cask_is_outdated_using_greedy?(cask_name)
// 186:           return false unless Bundle.cask_installed?
// 187:
// 188:           cask = casks.find { |installed_cask| installed_cask.to_s == cask_name }
// 189:           return false if cask.nil? || cask.pinned?
// 190:
// 191:           cask.outdated?(greedy: true)
// 192:         end
// 193:
// 194:         sig { override.params(describe: T::Boolean).returns(String) }
// 195:         def dump(describe: false)
// 196:           trusted_casks = Homebrew::Trust.trusted_entries(:cask)
// 197:           casks.map do |cask|
// 198:             description = "# #{cask.desc}\n" if describe && cask.desc.present?
// 199:             config = ", args: { #{explicit_s(cask.config)} }" if cask.config.present? && cask.config.explicit.present?
// 200:             caskline = "#{description}cask \"#{cask.full_name}\"#{config}"
// 201:             caskline += ", trusted: true" if trusted_casks.include?(cask.full_name)
// 202:             caskline
// 203:           end.join("\n")
// 204:         end
// 205:
// 206:         sig { override.params(describe: T::Boolean, no_restart: T::Boolean).returns(String) }
// 207:         def dump_output(describe: false, no_restart: false)
// 208:           _ = no_restart
// 209:
// 210:           dump(describe:)
// 211:         end
// 212:
// 213:         sig { returns(T::Hash[String, String]) }
// 214:         def cask_oldnames
// 215:           @cask_oldnames ||= casks.each_with_object({}) do |c, hash|
// 216:             oldnames = c.old_tokens
// 217:             next if oldnames.blank?
// 218:
// 219:             oldnames.each do |oldname|
// 220:               hash[oldname] = c.full_name
// 221:               if (tap_name = Utils.tap_from_full_name(c.full_name))
// 222:                 hash["#{tap_name}/#{oldname}"] = c.full_name
// 223:               end
// 224:             end
// 225:           end
// 226:         end
// 227:
// 228:         sig { params(cask_list: T::Array[String]).returns(T::Array[String]) }
// 229:         def formula_dependencies(cask_list)
// 230:           return [] if cask_list.blank?
// 231:
// 232:           require "cask/cask_loader"
// 233:
// 234:           installed_cask_objects = casks
// 235:           cask_list.flat_map do |cask_name|
// 236:             cask = installed_cask_objects.find do |installed_cask|
// 237:               cask_name == installed_cask.to_s || cask_name == installed_cask.full_name
// 238:             end
// 239:             cask ||= begin
// 240:               ::Cask::CaskLoader.load(cask_name)
// 241:             rescue ::Cask::CaskUnavailableError
// 242:               nil
// 243:             end
// 244:             next unless cask
// 245:
// 246:             cask.depends_on[:formula]
// 247:           end.compact
// 248:         end
// 249:
// 250:         private
// 251:
// 252:         sig { params(no_upgrade: T::Boolean, name: String, options: Homebrew::Bundle::EntryOptions).returns(T::Boolean) }
// 253:         def upgrading?(no_upgrade, name, options)
// 254:           return false if no_upgrade
// 255:           return true if cask_upgradable?(name)
// 256:           return false unless options[:greedy]
// 257:
// 258:           cask_is_outdated_using_greedy?(name)
// 259:         end
// 260:
// 261:         sig { params(name: String, options: Homebrew::Bundle::EntryOptions, verbose: T::Boolean).returns(T::Boolean) }
// 262:         def postinstall_change_state!(name:, options:, verbose:)
// 263:           postinstall = T.cast(options.fetch(:postinstall, nil), T.nilable(String))
// 264:           return true if postinstall.blank?
// 265:
// 266:           puts "Running postinstall for #{name}: #{postinstall}" if verbose
// 267:           Kernel.system(postinstall) || false
// 268:         end
// 269:
// 270:         sig { params(cask_config: ::Cask::Config).returns(String) }
// 271:         def explicit_s(cask_config)
// 272:           cask_config.explicit.map do |key, value|
// 273:             # inverse of #env - converts :languages config key back to --language flag
// 274:             if key == :languages
// 275:               key = "language"
// 276:               value = Array(cask_config.explicit.fetch(:languages, [])).join(",")
// 277:             end
// 278:             "#{key}: \"#{value.to_s.sub(/^#{Dir.home}/, "~")}\""
// 279:           end.join(", ")
// 280:         end
// 281:       end
// 282:
// 283:       sig { override.params(cask: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 284:       def installed_and_up_to_date?(cask, no_upgrade: false)
// 285:         raise "cask must be a String, got #{cask.class}: #{cask}" unless cask.is_a?(String)
// 286:
// 287:         self.class.cask_installed_and_up_to_date?(cask, no_upgrade:)
// 288:       end
// 289:     end
// 290:   end
// 291: end
