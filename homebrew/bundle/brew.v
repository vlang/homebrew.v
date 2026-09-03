module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/brew.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct BundleBrewFormula {
pub:
	name                   string
	desc                   string
	oldnames               []string
	full_name              string
	aliases                []string
	any_version_installed  bool
	args                   []string
	version                string
	installed_on_request   bool = true
	dependencies           []string
	recursive_dependencies []string
	build_dependencies     []string
	conflicts_with         []string
	pinned                 bool
	outdated               bool
	link_set               bool
	link                   bool
	poured_from_bottle     bool
	bottle                 brew_runtime.Value
	bottled                bool
	official_tap           bool
	linked                 bool
	keg_only               bool
}

pub struct BundleBrewState {
pub:
	formulae           []BundleBrewFormula
	installed_formulae []string
	upgrade_formulae   []string
	trusted_formulae   []string
	require_tap_trust  bool
	unavailable        []string
	started_services   []string
}

pub struct BundleBrewOptions {
pub:
	args            []string
	conflicts_with  []string
	restart_service string
	start_service   string
	link_mode       string
	postinstall     string
	version_file    string
	trusted         bool
}

pub struct BundleBrewInstaller {
pub mut:
	full_name              string
	name                   string
	options                BundleBrewOptions
	changed                bool
	installed              bool
	linked                 bool
	keg_only               bool
	upgradable             bool
	formula_conflicts      []string
	service_started        bool
	versioned_service_file string
	env_version            string
	formula_version        string
}

pub struct BundleBrewEffects {
pub:
	command_results      map[string]bool
	postinstall_ok       bool = true
	service_start_ok     bool = true
	service_restart_ok   bool = true
	service_stop_results map[string]bool
}

pub struct BundleBrewActionResult {
pub mut:
	success  bool
	changed  bool
	commands [][]string
	events   []string
	output   []string
	writes   map[string]string
}

pub struct BundleBrewTopoResult {
pub:
	ordered []string
	cycles  [][]string
}

pub struct BundleBrewUpgradeCheck {
pub:
	upgradable bool
	warning    string
	loaded     bool
}

fn bundle_brew_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

fn bundle_brew_strings_value(values []string) brew_runtime.Value {
	return brew_runtime.array_value(values.map(brew_runtime.string_value(it)))
}

fn bundle_brew_strings_from_value(value brew_runtime.Value) []string {
	return value.as_array() or { return [] }.map(it.as_string())
}

fn bundle_brew_bool(value brew_runtime.Value, fallback bool) bool {
	return value.as_bool() or { fallback }
}

fn bundle_brew_full_name(name string) bool {
	parts := name.split('/')
	return parts.len == 3 && parts.all(it != '')
}

pub fn bundle_brew_name_from_full_name(name string) string {
	parts := name.split('/')
	return if parts.len > 0 { parts.last() } else { name }
}

fn bundle_brew_tap_from_full_name(name string) string {
	parts := name.split('/')
	return if parts.len == 3 { '${parts[0]}/${parts[1]}' } else { '' }
}

fn bundle_brew_unique(values []string) []string {
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

fn bundle_brew_string_map_value(values map[string]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

pub fn bundle_brew_formula_value(formula BundleBrewFormula) brew_runtime.Value {
	mut fields := map[string]brew_runtime.Value{}
	fields['name'] = brew_runtime.string_value(formula.name)
	fields['desc'] = brew_runtime.string_value(formula.desc)
	fields['oldnames'] = bundle_brew_strings_value(formula.oldnames)
	fields['full_name'] = brew_runtime.string_value(formula.full_name)
	fields['aliases'] = bundle_brew_strings_value(formula.aliases)
	fields['any_version_installed?'] = brew_runtime.bool_value(formula.any_version_installed)
	fields['args'] = bundle_brew_strings_value(formula.args)
	fields['version'] = if formula.version == '' {
		bundle_brew_nil_value()
	} else {
		brew_runtime.string_value(formula.version)
	}
	fields['installed_on_request?'] = brew_runtime.bool_value(formula.installed_on_request)
	fields['dependencies'] = bundle_brew_strings_value(formula.dependencies)
	fields['recursive_dependencies'] = bundle_brew_strings_value(formula.recursive_dependencies)
	fields['build_dependencies'] = bundle_brew_strings_value(formula.build_dependencies)
	fields['conflicts_with'] = bundle_brew_strings_value(formula.conflicts_with)
	fields['pinned?'] = brew_runtime.bool_value(formula.pinned)
	fields['outdated?'] = brew_runtime.bool_value(formula.outdated)
	fields['link?'] = if formula.link_set {
		brew_runtime.bool_value(formula.link)
	} else {
		bundle_brew_nil_value()
	}
	fields['poured_from_bottle?'] = brew_runtime.bool_value(formula.poured_from_bottle)
	fields['bottle'] = if formula.bottle.type_name == '' {
		brew_runtime.bool_value(false)
	} else {
		formula.bottle
	}
	fields['bottled'] = brew_runtime.bool_value(formula.bottled)
	fields['official_tap'] = brew_runtime.bool_value(formula.official_tap)
	fields['linked?'] = brew_runtime.bool_value(formula.linked)
	fields['keg_only?'] = brew_runtime.bool_value(formula.keg_only)
	return brew_runtime.Value{
		type_name: 'Homebrew::Bundle::Brew::Formula'
		repr: formula.full_name
		map_data: fields
		attributes: {
			'name':      formula.name
			'full_name': formula.full_name
		}
	}
}

pub fn bundle_brew_formula_from_value(value brew_runtime.Value) BundleBrewFormula {
	fields := value.map_data.clone()
	link_value := fields['link?'] or { bundle_brew_nil_value() }
	return BundleBrewFormula{
		name: (fields['name'] or { brew_runtime.string_value(value.attributes['name'] or { bundle_brew_name_from_full_name(value.repr) }) }).as_string()
		desc: (fields['desc'] or { brew_runtime.string_value('') }).as_string()
		oldnames: bundle_brew_strings_from_value(fields['oldnames'] or { bundle_brew_strings_value([]) })
		full_name: (fields['full_name'] or { brew_runtime.string_value(value.attributes['full_name'] or { value.repr }) }).as_string()
		aliases: bundle_brew_strings_from_value(fields['aliases'] or { bundle_brew_strings_value([]) })
		any_version_installed: bundle_brew_bool(fields['any_version_installed?'] or { brew_runtime.bool_value(false) }, false)
		args: bundle_brew_strings_from_value(fields['args'] or { bundle_brew_strings_value([]) })
		version: if (fields['version'] or { bundle_brew_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''} else {
			(fields['version'] or { bundle_brew_nil_value() }).as_string()}
		installed_on_request: bundle_brew_bool(fields['installed_on_request?'] or { brew_runtime.bool_value(true) }, true)
		dependencies: bundle_brew_strings_from_value(fields['dependencies'] or { bundle_brew_strings_value([]) })
		recursive_dependencies: bundle_brew_strings_from_value(fields['recursive_dependencies'] or { bundle_brew_strings_value([]) })
		build_dependencies: bundle_brew_strings_from_value(fields['build_dependencies'] or { bundle_brew_strings_value([]) })
		conflicts_with: bundle_brew_strings_from_value(fields['conflicts_with'] or { bundle_brew_strings_value([]) })
		pinned: bundle_brew_bool(fields['pinned?'] or { brew_runtime.bool_value(false) }, false)
		outdated: bundle_brew_bool(fields['outdated?'] or { brew_runtime.bool_value(false) }, false)
		link_set: link_value.type_name !in ['Nil', 'NilClass', '']
		link: bundle_brew_bool(link_value, false)
		poured_from_bottle: bundle_brew_bool(fields['poured_from_bottle?'] or { brew_runtime.bool_value(false) }, false)
		bottle: fields['bottle'] or { brew_runtime.bool_value(false) }
		bottled: bundle_brew_bool(fields['bottled'] or { brew_runtime.bool_value(false) }, false)
		official_tap: bundle_brew_bool(fields['official_tap'] or { brew_runtime.bool_value(false) }, false)
		linked: bundle_brew_bool(fields['linked?'] or { brew_runtime.bool_value(false) }, false)
		keg_only: bundle_brew_bool(fields['keg_only?'] or { brew_runtime.bool_value(false) }, false)
	}
}

pub fn bundle_brew_options_value(options BundleBrewOptions) brew_runtime.Value {
	return brew_runtime.map_value({
		'args':            bundle_brew_strings_value(options.args)
		'conflicts_with':  bundle_brew_strings_value(options.conflicts_with)
		'restart_service': if options.restart_service == '' {
			bundle_brew_nil_value()
		} else {
			brew_runtime.string_value(options.restart_service)
		}
		'start_service':   if options.start_service == '' {
			bundle_brew_nil_value()
		} else {
			brew_runtime.string_value(options.start_service)
		}
		'link':            if options.link_mode == '' {
			bundle_brew_nil_value()
		} else if options.link_mode == 'true' {
			brew_runtime.bool_value(true)
		} else if options.link_mode == 'false' {
			brew_runtime.bool_value(false)
		} else {
			brew_runtime.string_value(options.link_mode)
		}
		'postinstall':     if options.postinstall == '' {
			bundle_brew_nil_value()
		} else {
			brew_runtime.string_value(options.postinstall)
		}
		'version_file':    if options.version_file == '' {
			bundle_brew_nil_value()
		} else {
			brew_runtime.string_value(options.version_file)
		}
		'trusted':         brew_runtime.bool_value(options.trusted)
	})
}

pub fn bundle_brew_options_from_value(value brew_runtime.Value) BundleBrewOptions {
	fields := value.map_data.clone()
	restart_value := fields['restart_service'] or { bundle_brew_nil_value() }
	start_value := fields['start_service'] or { restart_value }
	link_value := fields['link'] or { bundle_brew_nil_value() }
	return BundleBrewOptions{
		args: bundle_brew_strings_from_value(fields['args'] or { bundle_brew_strings_value([]) })
		conflicts_with: bundle_brew_strings_from_value(fields['conflicts_with'] or { bundle_brew_strings_value([]) })
		restart_service: if restart_value.type_name in ['Nil', 'NilClass', ''] {
			''} else {
			restart_value.as_string()}
		start_service: if start_value.type_name in ['Nil', 'NilClass', ''] {
			''} else {
			start_value.as_string()}
		link_mode: if link_value.type_name in ['Nil', 'NilClass', ''] {
			''} else if link_value.type_name == 'Bool' {
			link_value.bool_data.str()} else {
			link_value.as_string()}
		postinstall: if (fields['postinstall'] or { bundle_brew_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''} else {
			(fields['postinstall'] or { bundle_brew_nil_value() }).as_string()}
		version_file: if (fields['version_file'] or { bundle_brew_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''} else {
			(fields['version_file'] or { bundle_brew_nil_value() }).as_string()}
		trusted: bundle_brew_bool(fields['trusted'] or { brew_runtime.bool_value(false) }, false)
	}
}

pub fn bundle_brew_state_value(state BundleBrewState) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Homebrew::Bundle::Brew::State'
		array_data: state.formulae.map(bundle_brew_formula_value(it))
		map_data: {
			'installed_formulae': bundle_brew_strings_value(state.installed_formulae)
			'upgrade_formulae':   bundle_brew_strings_value(state.upgrade_formulae)
			'trusted_formulae':   bundle_brew_strings_value(state.trusted_formulae)
			'require_tap_trust':  brew_runtime.bool_value(state.require_tap_trust)
			'unavailable':        bundle_brew_strings_value(state.unavailable)
			'started_services':   bundle_brew_strings_value(state.started_services)
		}
	}
}

pub fn bundle_brew_state_from_value(value brew_runtime.Value) BundleBrewState {
	fields := value.map_data.clone()
	return BundleBrewState{
		formulae: value.array_data.map(bundle_brew_formula_from_value(it))
		installed_formulae: bundle_brew_strings_from_value(fields['installed_formulae'] or { bundle_brew_strings_value([]) })
		upgrade_formulae: bundle_brew_strings_from_value(fields['upgrade_formulae'] or { bundle_brew_strings_value([]) })
		trusted_formulae: bundle_brew_strings_from_value(fields['trusted_formulae'] or { bundle_brew_strings_value([]) })
		require_tap_trust: bundle_brew_bool(fields['require_tap_trust'] or { brew_runtime.bool_value(false) }, false)
		unavailable: bundle_brew_strings_from_value(fields['unavailable'] or { bundle_brew_strings_value([]) })
		started_services: bundle_brew_strings_from_value(fields['started_services'] or { bundle_brew_strings_value([]) })
	}
}

pub fn bundle_brew_installer(name string, options BundleBrewOptions) BundleBrewInstaller {
	return BundleBrewInstaller{
		full_name: name
		name: bundle_brew_name_from_full_name(name)
		options: BundleBrewOptions{
			args: options.args.map(if it.starts_with('--') { it } else { '--${it}' })
			conflicts_with: options.conflicts_with.clone()
			restart_service: options.restart_service
			start_service: if options.start_service != '' {
				options.start_service} else {
				options.restart_service}
			link_mode: options.link_mode
			postinstall: options.postinstall
			version_file: options.version_file
			trusted: options.trusted
		}
	}
}

pub fn bundle_brew_installer_value(installer BundleBrewInstaller) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Homebrew::Bundle::Brew'
		repr: installer.full_name
		map_data: {
			'options':                bundle_brew_options_value(installer.options)
			'changed':                brew_runtime.bool_value(installer.changed)
			'installed':              brew_runtime.bool_value(installer.installed)
			'linked':                 brew_runtime.bool_value(installer.linked)
			'keg_only':               brew_runtime.bool_value(installer.keg_only)
			'upgradable':             brew_runtime.bool_value(installer.upgradable)
			'formula_conflicts':      bundle_brew_strings_value(installer.formula_conflicts)
			'service_started':        brew_runtime.bool_value(installer.service_started)
			'versioned_service_file': brew_runtime.string_value(installer.versioned_service_file)
			'env_version':            brew_runtime.string_value(installer.env_version)
			'formula_version':        brew_runtime.string_value(installer.formula_version)
		}
		attributes: {
			'name':      installer.name
			'full_name': installer.full_name
		}
	}
}

pub fn bundle_brew_installer_from_value(value brew_runtime.Value) BundleBrewInstaller {
	fields := value.map_data.clone()
	return BundleBrewInstaller{
		full_name: value.attributes['full_name'] or { value.repr }
		name: value.attributes['name'] or { bundle_brew_name_from_full_name(value.repr) }
		options: bundle_brew_options_from_value(fields['options'] or { brew_runtime.map_value({}) })
		changed: bundle_brew_bool(fields['changed'] or { brew_runtime.bool_value(false) }, false)
		installed: bundle_brew_bool(fields['installed'] or { brew_runtime.bool_value(false) }, false)
		linked: bundle_brew_bool(fields['linked'] or { brew_runtime.bool_value(false) }, false)
		keg_only: bundle_brew_bool(fields['keg_only'] or { brew_runtime.bool_value(false) }, false)
		upgradable: bundle_brew_bool(fields['upgradable'] or { brew_runtime.bool_value(false) }, false)
		formula_conflicts: bundle_brew_strings_from_value(fields['formula_conflicts'] or { bundle_brew_strings_value([]) })
		service_started: bundle_brew_bool(fields['service_started'] or { brew_runtime.bool_value(false) }, false)
		versioned_service_file: (fields['versioned_service_file'] or { brew_runtime.string_value('') }).as_string()
		env_version: (fields['env_version'] or { brew_runtime.string_value('') }).as_string()
		formula_version: (fields['formula_version'] or { brew_runtime.string_value('') }).as_string()
	}
}

fn bundle_brew_formula_map_value(formulae []BundleBrewFormula, full_name bool) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for formula in formulae {
		result[if full_name { formula.full_name } else { formula.name }] = bundle_brew_formula_value(formula)
	}
	return brew_runtime.map_value(result)
}

pub fn bundle_brew_find_formula(state BundleBrewState, name string) ?BundleBrewFormula {
	for formula in state.formulae {
		if formula.full_name == name || formula.name == name {
			return formula
		}
	}
	return none
}

pub fn bundle_brew_formula_aliases(state BundleBrewState) map[string]string {
	mut aliases := map[string]string{}
	for formula in state.formulae {
		for alias in formula.aliases {
			aliases[alias] = formula.full_name
			tap := bundle_brew_tap_from_full_name(formula.full_name)
			if tap != '' {
				aliases['${tap}/${alias}'] = formula.full_name
			}
		}
	}
	return aliases
}

pub fn bundle_brew_formula_oldnames(state BundleBrewState) map[string]string {
	mut oldnames := map[string]string{}
	for formula in state.formulae {
		for oldname in formula.oldnames {
			oldnames[oldname] = formula.full_name
			tap := bundle_brew_tap_from_full_name(formula.full_name)
			if tap != '' {
				oldnames['${tap}/${oldname}'] = formula.full_name
			}
		}
	}
	return oldnames
}

pub fn bundle_brew_formula_in_array(state BundleBrewState, formula string, values []string) bool {
	if formula in values || bundle_brew_name_from_full_name(formula) in values {
		return true
	}
	oldnames := bundle_brew_formula_oldnames(state)
	oldname := oldnames[formula] or { oldnames[bundle_brew_name_from_full_name(formula)] or { '' } }
	if oldname != '' && oldname in values {
		return true
	}
	aliases := bundle_brew_formula_aliases(state)
	resolved := aliases[formula] or { return false }
	return resolved in values || bundle_brew_name_from_full_name(resolved) in values
}

pub fn bundle_brew_formula_installed(state BundleBrewState, formula string) bool {
	if bundle_brew_full_name(formula) {
		return bundle_brew_name_from_full_name(formula) in state.installed_formulae
	}
	return bundle_brew_formula_in_array(state, formula, state.installed_formulae)
}

pub fn bundle_brew_formula_upgradable_check(state BundleBrewState, formula string) BundleBrewUpgradeCheck {
	if !bundle_brew_formula_installed(state, formula) {
		return BundleBrewUpgradeCheck{}
	}
	if bundle_brew_full_name(formula) && state.require_tap_trust && formula !in state.trusted_formulae {
		return BundleBrewUpgradeCheck{
			upgradable: true
			warning: 'Cannot check whether ${formula} is outdated because its tap is not trusted. Run `brew trust --formula ${formula}` to trust it.'
		}
	}
	if !bundle_brew_formula_in_array(state, formula, bundle_brew_upgradable_formulae(state)) {
		return BundleBrewUpgradeCheck{}
	}
	loaded := bundle_brew_find_formula(state, formula) or { return BundleBrewUpgradeCheck{} }
	return BundleBrewUpgradeCheck{ upgradable: loaded.outdated, loaded: true }
}

pub fn bundle_brew_formula_upgradable(state BundleBrewState, formula string) bool {
	return bundle_brew_formula_upgradable_check(state, formula).upgradable
}

pub fn bundle_brew_no_upgrade_with_args(state BundleBrewState, no_upgrade bool, formula string) bool {
	return no_upgrade && formula !in state.upgrade_formulae
}

pub fn bundle_brew_installed_and_up_to_date(state BundleBrewState, formula string, no_upgrade bool) bool {
	if !bundle_brew_formula_installed(state, formula) {
		return false
	}
	if bundle_brew_no_upgrade_with_args(state, no_upgrade, formula) {
		return true
	}
	return !bundle_brew_formula_upgradable(state, formula)
}

pub fn bundle_brew_outdated_formulae(state BundleBrewState) []string {
	return state.formulae.filter(it.outdated).map(it.name)
}

pub fn bundle_brew_pinned_formulae(state BundleBrewState) []string {
	return state.formulae.filter(it.pinned).map(it.name)
}

pub fn bundle_brew_upgradable_formulae(state BundleBrewState) []string {
	pinned := bundle_brew_pinned_formulae(state)
	return bundle_brew_outdated_formulae(state).filter(it !in pinned)
}

pub fn bundle_brew_expected_link_status(link_mode string, keg_only bool) bool {
	return match link_mode {
		'overwrite', 'true' { true }
		'false' { false }
		else { !keg_only }
	}
}

pub fn bundle_brew_link_status_to_check(state BundleBrewState, formula string, options BundleBrewOptions, keg_only bool) ?bool {
	if options.link_mode == '' {
		cached := bundle_brew_find_formula(state, formula) or { return none }
		if !cached.link_set {
			return none
		}
		return !cached.link
	}
	return bundle_brew_expected_link_status(options.link_mode, keg_only)
}

fn bundle_brew_topo_visit(node string, graph map[string][]string, mut active []string,
	mut complete map[string]bool, mut result []string, mut cycles [][]string) {
	if complete[node] or { false } {
		return
	}
	index := active.index(node)
	if index >= 0 {
		cycle := active[index..].clone()
		if !cycles.any(it == cycle) {
			cycles << cycle
		}
		return
	}
	active << node
	mut children := (graph[node] or { []string{} }).clone()
	children.sort()
	for child in children {
		bundle_brew_topo_visit(child, graph, mut active, mut complete, mut result, mut cycles)
	}
	active.delete_last()
	complete[node] = true
	if node !in result {
		result << node
	}
}

pub fn bundle_brew_toposort(graph map[string][]string) BundleBrewTopoResult {
	mut keys := graph.keys()
	keys.sort()
	mut active := []string{}
	mut complete := map[string]bool{}
	mut ordered := []string{}
	mut cycles := [][]string{}
	for key in keys {
		bundle_brew_topo_visit(key, graph, mut active, mut complete, mut ordered, mut cycles)
	}
	return BundleBrewTopoResult{ ordered: ordered, cycles: cycles }
}

pub fn bundle_brew_sort_formulae(state BundleBrewState) BundleBrewTopoResult {
	mut formulae := state.formulae.clone()
	formulae.sort_with_compare(fn (left &BundleBrewFormula, right &BundleBrewFormula) int {
		left_tapped := left.full_name.contains('/')
		right_tapped := right.full_name.contains('/')
		if left_tapped != right_tapped {
			return if left_tapped { 1 } else { -1 }
		}
		return compare_strings(left.full_name, right.full_name)
	})
	mut graph := map[string][]string{}
	for formula in formulae {
		mut dependencies := []string{}
		for dependency in formula.dependencies {
			found := bundle_brew_find_formula(state, dependency) or { continue }
			if found.any_version_installed {
				dependencies << found.full_name
			}
		}
		graph[formula.name] = dependencies.clone()
		graph[formula.full_name] = dependencies.clone()
	}
	return bundle_brew_toposort(graph)
}

pub fn bundle_brew_sorted_formulae(state BundleBrewState) ([]BundleBrewFormula, [][]string) {
	topo := bundle_brew_sort_formulae(state)
	mut sorted := []BundleBrewFormula{}
	for name in topo.ordered {
		formula := bundle_brew_find_formula(state, name) or { continue }
		if !sorted.any(it.full_name == formula.full_name) {
			sorted << formula
		}
	}
	return sorted, topo.cycles
}

pub fn bundle_brew_dump(state BundleBrewState, describe bool, no_restart bool) string {
	formulae, _ := bundle_brew_sorted_formulae(state)
	mut lines := []string{}
	for formula in formulae {
		if !formula.installed_on_request {
			continue
		}
		mut line := ''
		if describe && formula.desc != '' {
			line = formula.desc.split_into_lines().map('# ${it}\n').join('')
		}
		line += 'brew "${formula.full_name}"'
		mut args := formula.args.clone()
		args.sort()
		if args.len > 0 {
			line += ', args: [${args.map('"\${it}"').join(', ')}]'
		}
		if !no_restart && formula.full_name in state.started_services {
			line += ', restart_service: :changed'
		}
		if formula.link_set {
			line += ', link: ${formula.link}'
		}
		if formula.full_name in state.trusted_formulae {
			line += ', trusted: true'
		}
		lines << line
	}
	return lines.join('\n')
}

fn bundle_brew_command_ok(effects BundleBrewEffects, command []string) bool {
	return effects.command_results[command.join(' ')] or { true }
}

pub fn bundle_brew_preinstall_instance(mut installer BundleBrewInstaller, state BundleBrewState, no_upgrade bool) bool {
	installer.installed = bundle_brew_formula_installed(state, installer.name)
	installer.upgradable = bundle_brew_formula_upgradable(state, installer.full_name)
	if installer.installed && (bundle_brew_no_upgrade_with_args(state, no_upgrade, installer.name) || !installer.upgradable) {
		installer.changed = false
		return false
	}
	return true
}

pub fn bundle_brew_start_service(installer BundleBrewInstaller) bool {
	return installer.options.start_service != ''
}

pub fn bundle_brew_start_service_needed(installer BundleBrewInstaller) bool {
	return bundle_brew_start_service(installer) && !installer.service_started
}

pub fn bundle_brew_restart_service(installer BundleBrewInstaller) bool {
	return installer.options.restart_service != ''
}

pub fn bundle_brew_restart_service_needed(installer BundleBrewInstaller) bool {
	if !bundle_brew_restart_service(installer) {
		return false
	}
	return installer.options.restart_service == 'always' || installer.changed
}

pub fn bundle_brew_conflicts(installer BundleBrewInstaller) []string {
	mut conflicts := installer.options.conflicts_with.clone()
	conflicts << installer.formula_conflicts
	return bundle_brew_unique(conflicts)
}

pub fn bundle_brew_resolve_conflicts(installer BundleBrewInstaller, state BundleBrewState,
	effects BundleBrewEffects, verbose bool) BundleBrewActionResult {
	mut commands := [][]string{}
	mut events := []string{}
	mut output := []string{}
	for conflict in bundle_brew_conflicts(installer) {
		if !bundle_brew_formula_installed(state, conflict) {
			continue
		}
		if verbose {
			output << 'Unlinking ${conflict} formula.\nIt is currently installed and conflicts with ${installer.name}.'
		}
		command := ['unlink', conflict]
		commands << command
		if !bundle_brew_command_ok(effects, command) {
			return BundleBrewActionResult{ commands: commands, events: events, output: output }
		}
		if bundle_brew_restart_service(installer) {
			if verbose {
				output << 'Stopping ${conflict} service (if it is running).'
			}
			events << 'service:stop:${conflict}'
		}
	}
	return BundleBrewActionResult{ success: true, commands: commands, events: events, output: output }
}

pub fn bundle_brew_install_formula(mut installer BundleBrewInstaller, effects BundleBrewEffects,
	force bool, verbose bool) BundleBrewActionResult {
	mut install_args := installer.options.args.clone()
	if force {
		install_args << ['--force', '--overwrite']
	}
	if installer.options.link_mode == 'false' {
		install_args << '--skip-link'
	}
	mut command := ['install', '--formula', installer.full_name]
	command << install_args
	mut output := []string{}
	if verbose {
		with_args := if install_args.len > 0 {
			' with ${install_args.join(' ')}'
		} else {
			''
		}
		output << 'Installing ${installer.name} formula${with_args}. It is not currently installed.'
	}
	if !bundle_brew_command_ok(effects, command) {
		installer.changed = false
		return BundleBrewActionResult{ commands: [command], output: output }
	}
	installer.changed = true
	installer.installed = true
	return BundleBrewActionResult{
		success: true
		changed: true
		commands: [
			command,
		]
		output: output
	}
}

pub fn bundle_brew_upgrade_formula(mut installer BundleBrewInstaller, effects BundleBrewEffects,
	force bool, verbose bool) BundleBrewActionResult {
	mut upgrade_args := []string{}
	if force {
		upgrade_args << '--force'
	}
	mut command := ['upgrade', '--formula', installer.name]
	command << upgrade_args
	mut output := []string{}
	if verbose {
		with_args := if upgrade_args.len > 0 {
			' with ${upgrade_args.join(' ')}'
		} else {
			''
		}
		output << 'Upgrading ${installer.name} formula${with_args}. It is installed but not up-to-date.'
	}
	if !bundle_brew_command_ok(effects, command) {
		installer.changed = false
		return BundleBrewActionResult{ commands: [command], output: output }
	}
	installer.changed = true
	return BundleBrewActionResult{
		success: true
		changed: true
		commands: [
			command,
		]
		output: output
	}
}

pub fn bundle_brew_link_change(installer BundleBrewInstaller, effects BundleBrewEffects,
	verbose bool) BundleBrewActionResult {
	mut link_args := []string{}
	link_status := bundle_brew_expected_link_status(installer.options.link_mode, installer.keg_only)
	mut command := []string{}
	if link_status {
		if !installer.linked && installer.keg_only {
			link_args << '--force'
		}
		if installer.options.link_mode == 'overwrite' {
			link_args << '--overwrite'
		}
		if !installer.linked {
			command = ['link']
			command << link_args
			command << installer.name
		}
	} else if installer.linked {
		command = ['unlink', installer.name]
	}
	if command.len == 0 {
		return BundleBrewActionResult{ success: true }
	}
	mut output := []string{}
	if verbose {
		verb := if command[0] == 'link' { 'Linking' } else { 'Unlinking' }
		with_args := if link_args.len > 0 { ' with ${link_args.join(' ')}' } else { '' }
		output << '${verb} ${installer.name} formula${with_args}.'
	}
	return BundleBrewActionResult{
		success: bundle_brew_command_ok(effects, command)
		commands: [command]
		output: output
	}
}

pub fn bundle_brew_service_change(installer BundleBrewInstaller, effects BundleBrewEffects,
	verbose bool) BundleBrewActionResult {
	mut output := []string{}
	if bundle_brew_restart_service_needed(installer) {
		if verbose { output << 'Restarting ${installer.name} service.' }
		return BundleBrewActionResult{
			success: effects.service_restart_ok
			events: [
				'service:restart:${installer.full_name}:${installer.versioned_service_file}',
			]
			output: output
		}
	}
	if bundle_brew_start_service_needed(installer) {
		if verbose { output << 'Starting ${installer.name} service.' }
		return BundleBrewActionResult{
			success: effects.service_start_ok
			events: [
				'service:start:${installer.full_name}:${installer.versioned_service_file}',
			]
			output: output
		}
	}
	return BundleBrewActionResult{ success: true }
}

pub fn bundle_brew_postinstall_change(installer BundleBrewInstaller, effects BundleBrewEffects,
	verbose bool) BundleBrewActionResult {
	if installer.options.postinstall == '' || !installer.changed {
		return BundleBrewActionResult{ success: true }
	}
	return BundleBrewActionResult{
		success: effects.postinstall_ok
		events: ['postinstall:${installer.options.postinstall}']
		output: if verbose {
			[
				'Running postinstall for ${installer.name}: ${installer.options.postinstall}',
			]} else {
			[]}
	}
}

pub fn bundle_brew_install_change(mut installer BundleBrewInstaller, state BundleBrewState,
	effects BundleBrewEffects, force bool, verbose bool) BundleBrewActionResult {
	mut events := []string{}
	if installer.options.trusted && bundle_brew_full_name(installer.full_name) {
		events << 'trust:${installer.full_name}'
	}
	if bundle_brew_full_name(installer.full_name) {
		events << 'tap:ensure:${bundle_brew_tap_from_full_name(installer.full_name)}'
	}
	resolved := bundle_brew_resolve_conflicts(installer, state, effects, verbose)
	events << resolved.events
	if !resolved.success {
		return BundleBrewActionResult{ commands: resolved.commands, events: events, output: resolved.output }
	}
	mut change := if installer.installed {
		bundle_brew_upgrade_formula(mut installer, effects, force, verbose)
	} else {
		bundle_brew_install_formula(mut installer, effects, force, verbose)
	}
	mut commands := resolved.commands.clone()
	commands << change.commands
	mut all_events := events.clone()
	all_events << change.events
	mut output := resolved.output.clone()
	output << change.output
	change.commands = commands
	change.events = all_events
	change.output = output
	return change
}

pub fn bundle_brew_install_instance(mut installer BundleBrewInstaller, state BundleBrewState,
	effects BundleBrewEffects, preinstall bool, no_upgrade bool, force bool, verbose bool) BundleBrewActionResult {
	_ = no_upgrade
	mut result := if preinstall {
		bundle_brew_install_change(mut installer, state, effects, force, verbose)
	} else {
		BundleBrewActionResult{ success: true }
	}
	if !installer.installed {
		return result
	}
	service := bundle_brew_service_change(installer, effects, verbose)
	link := bundle_brew_link_change(installer, effects, verbose)
	postinstall := bundle_brew_postinstall_change(installer, effects, verbose)
	result.success = result.success && service.success && link.success && postinstall.success
	result.commands << service.commands
	result.commands << link.commands
	result.commands << postinstall.commands
	result.events << service.events
	result.events << link.events
	result.events << postinstall.events
	result.output << service.output
	result.output << link.output
	result.output << postinstall.output
	if result.success && installer.options.version_file != '' {
		version := if !installer.changed && installer.env_version != '' {
			installer.env_version.split('_')[0]
		} else {
			installer.formula_version
		}
		result.writes[installer.options.version_file] = '${version}\n'
		if verbose {
			result.output << 'Wrote ${installer.name} version ${version} to ${installer.options.version_file}'
		}
	}
	return result
}

fn bundle_brew_effects_from_value(value brew_runtime.Value) BundleBrewEffects {
	mut command_results := map[string]bool{}
	for key, item in (value.map_data['command_results'] or { brew_runtime.map_value({}) }).map_data {
		command_results[key] = bundle_brew_bool(item, true)
	}
	mut stop_results := map[string]bool{}
	for key, item in (value.map_data['service_stop_results'] or { brew_runtime.map_value({}) }).map_data {
		stop_results[key] = bundle_brew_bool(item, true)
	}
	return BundleBrewEffects{
		command_results: command_results
		postinstall_ok: bundle_brew_bool(value.map_data['postinstall_ok'] or { brew_runtime.bool_value(true) }, true)
		service_start_ok: bundle_brew_bool(value.map_data['service_start_ok'] or { brew_runtime.bool_value(true) }, true)
		service_restart_ok: bundle_brew_bool(value.map_data['service_restart_ok'] or { brew_runtime.bool_value(true) }, true)
		service_stop_results: stop_results
	}
}

pub fn bundle_brew_action_value(result BundleBrewActionResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Homebrew::Bundle::Brew::ActionResult'
		repr: result.success.str()
		bool_data: result.success
		array_data: result.commands.map(bundle_brew_strings_value(it))
		map_data: {
			'events':  bundle_brew_strings_value(result.events)
			'output':  bundle_brew_strings_value(result.output)
			'writes':  bundle_brew_string_map_value(result.writes)
			'changed': brew_runtime.bool_value(result.changed)
		}
	}
}

// Ruby method `type = :brew` at line 19.
pub fn ruby_brew_l19_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('brew')
}

// Ruby method `check_label = "Formula"` at line 22.
pub fn ruby_brew_l22_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Formula')
}

// Ruby method `inherited(subclass)` at line 25.
pub fn ruby_brew_l25_d3_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.Value{ type_name: 'InheritedAction', repr: name, bool_data: name != 'Homebrew::Bundle::Brew::Services' }
}

// Ruby method `reset!` at line 32.
pub fn ruby_brew_l32_d4_reset(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bundle_brew_state_value(BundleBrewState{})
}

// Ruby attr_writer `attr_writer :formulae_by_name` at line 50.
pub fn ruby_brew_l50_d5_formulae_by_name(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args.last() } else { bundle_brew_nil_value() }
}

// Ruby method `preinstall!(name, no_upgrade: false, verbose: false, **options)` at line 53.
pub fn ruby_brew_l53_d6_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	mut installer := bundle_brew_installer(args[0].as_string(), if args.len > 1 {
		bundle_brew_options_from_value(args[1])
	} else {
		BundleBrewOptions{}
	})
	state := if args.len > 2 {
		bundle_brew_state_from_value(args[2])
	} else {
		BundleBrewState{}
	}
	no_upgrade := if args.len > 3 { bundle_brew_bool(args[3], false) } else { false }
	return brew_runtime.bool_value(bundle_brew_preinstall_instance(mut installer, state, no_upgrade))
}

// Ruby method `install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, **options)` at line 61.
pub fn ruby_brew_l61_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	mut installer := bundle_brew_installer(args[0].as_string(), if args.len > 1 {
		bundle_brew_options_from_value(args[1])
	} else {
		BundleBrewOptions{}
	})
	state := if args.len > 2 {
		bundle_brew_state_from_value(args[2])
	} else {
		BundleBrewState{}
	}
	installer.installed = bundle_brew_formula_installed(state, installer.name)
	effects := if args.len > 3 {
		bundle_brew_effects_from_value(args[3])
	} else {
		BundleBrewEffects{}
	}
	preinstall := if args.len > 4 { bundle_brew_bool(args[4], true) } else { true }
	force := if args.len > 5 { bundle_brew_bool(args[5], false) } else { false }
	return brew_runtime.bool_value(bundle_brew_install_instance(mut installer, state, effects, preinstall, false, force, false).success)
}

// Ruby method `install_verb(name, options = {})` at line 71.
pub fn ruby_brew_l71_d8_install_verb(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	state := if args.len > 2 {
		bundle_brew_state_from_value(args[2])
	} else {
		BundleBrewState{}
	}
	return brew_runtime.string_value(if bundle_brew_formula_upgradable(state, name) {
		'Upgrading'
	} else {
		'Installing'
	})
}

// Ruby method `formula_installed_and_up_to_date?(formula, no_upgrade: false)` at line 80.
pub fn ruby_brew_l80_d9_formula_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 1 {
		bundle_brew_state_from_value(args[1])
	} else {
		BundleBrewState{}
	}
	no_upgrade := if args.len > 2 { bundle_brew_bool(args[2], false) } else { false }
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_installed_and_up_to_date(state, args[0].as_string(), no_upgrade))
}

// Ruby method `link_status_to_check(formula, options)` at line 88.
pub fn ruby_brew_l88_d10_link_status_to_check(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bundle_brew_nil_value()
	}
	state := if args.len > 2 {
		bundle_brew_state_from_value(args[2])
	} else {
		BundleBrewState{}
	}
	keg_only := if args.len > 3 { bundle_brew_bool(args[3], false) } else { false }
	status := bundle_brew_link_status_to_check(state, args[0].as_string(), bundle_brew_options_from_value(args[1]), keg_only) or { return bundle_brew_nil_value() }
	return brew_runtime.bool_value(status)
}

// Ruby method `expected_link_status?(link, keg_only:)` at line 102.
pub fn ruby_brew_l102_d11_expected_link_status(args ...brew_runtime.Value) brew_runtime.Value {
	mode := if args.len > 0 {
		if args[0].type_name == 'Bool' { args[0].bool_data.str() } else { args[0].as_string() }
	} else {
		''
	}
	keg_only := if args.len > 1 { bundle_brew_bool(args[1], false) } else { false }
	return brew_runtime.bool_value(bundle_brew_expected_link_status(mode, keg_only))
}

// Ruby method `formula_dump_link_status(formula)` at line 114.
pub fn ruby_brew_l114_d12_formula_dump_link_status(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bundle_brew_nil_value()
	}
	formula := bundle_brew_find_formula(bundle_brew_state_from_value(args[1]), args[0].as_string()) or { return bundle_brew_nil_value() }
	return if formula.link_set {
		brew_runtime.bool_value(formula.link)
	} else {
		bundle_brew_nil_value()
	}
}

// Ruby method `no_upgrade_with_args?(no_upgrade, formula_name)` at line 122.
pub fn ruby_brew_l122_d13_no_upgrade_with_args(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 2 {
		bundle_brew_state_from_value(args[2])
	} else {
		BundleBrewState{}
	}
	return brew_runtime.bool_value(args.len > 1 && bundle_brew_no_upgrade_with_args(state, bundle_brew_bool(args[0], false), args[1].as_string()))
}

// Ruby method `formula_in_array?(formula, array)` at line 127.
pub fn ruby_brew_l127_d14_formula_in_array(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 2 {
		bundle_brew_state_from_value(args[2])
	} else {
		BundleBrewState{}
	}
	return brew_runtime.bool_value(args.len > 1 && bundle_brew_formula_in_array(state, args[0].as_string(), bundle_brew_strings_from_value(args[1])))
}

// Ruby method `formula_installed?(formula)` at line 144.
pub fn ruby_brew_l144_d15_formula_installed(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 1 {
		bundle_brew_state_from_value(args[1])
	} else {
		BundleBrewState{}
	}
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_formula_installed(state, args[0].as_string()))
}

// Ruby method `formula_upgradable?(formula)` at line 153.
pub fn ruby_brew_l153_d16_formula_upgradable(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 1 {
		bundle_brew_state_from_value(args[1])
	} else {
		BundleBrewState{}
	}
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_formula_upgradable(state, args[0].as_string()))
}

// Ruby method `installed_formulae` at line 173.
pub fn ruby_brew_l173_d17_installed_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return bundle_brew_strings_value(if args.len > 0 {
		bundle_brew_state_from_value(args[0]).installed_formulae
	} else {
		[]
	})
}

// Ruby method `upgradable_formulae` at line 178.
pub fn ruby_brew_l178_d18_upgradable_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return bundle_brew_strings_value(bundle_brew_upgradable_formulae(if args.len > 0 {
		bundle_brew_state_from_value(args[0])
	} else {
		BundleBrewState{}
	}))
}

// Ruby method `outdated_formulae` at line 183.
pub fn ruby_brew_l183_d19_outdated_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return bundle_brew_strings_value(bundle_brew_outdated_formulae(if args.len > 0 {
		bundle_brew_state_from_value(args[0])
	} else {
		BundleBrewState{}
	}))
}

// Ruby method `pinned_formulae` at line 188.
pub fn ruby_brew_l188_d20_pinned_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return bundle_brew_strings_value(bundle_brew_pinned_formulae(if args.len > 0 {
		bundle_brew_state_from_value(args[0])
	} else {
		BundleBrewState{}
	}))
}

// Ruby method `find_formula(name)` at line 193.
pub fn ruby_brew_l193_d21_find_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bundle_brew_nil_value()
	}
	formula := bundle_brew_find_formula(bundle_brew_state_from_value(args[1]), args[0].as_string()) or { return bundle_brew_nil_value() }
	return bundle_brew_formula_value(formula)
}

// Ruby method `formula_dep_names(name)` at line 199.
pub fn ruby_brew_l199_d22_formula_dep_names(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bundle_brew_strings_value([])
	}
	formula := bundle_brew_find_formula(bundle_brew_state_from_value(args[1]), args[0].as_string()) or { return bundle_brew_strings_value([]) }
	return bundle_brew_strings_value(formula.dependencies)
}

// Ruby method `recursive_dep_names(name)` at line 205.
pub fn ruby_brew_l205_d23_recursive_dep_names(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bundle_brew_strings_value([])
	}
	formula := bundle_brew_find_formula(bundle_brew_state_from_value(args[1]), args[0].as_string()) or { return bundle_brew_strings_value([]) }
	return bundle_brew_strings_value(bundle_brew_unique(formula.recursive_dependencies))
}

// Ruby method `formulae` at line 213.
pub fn ruby_brew_l213_d24_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 {
		bundle_brew_state_from_value(args[0])
	} else {
		BundleBrewState{}
	}
	formulae, _ := bundle_brew_sorted_formulae(state)
	return brew_runtime.array_value(formulae.map(bundle_brew_formula_value(it)))
}

// Ruby method `formulae_by_full_name(name = nil)` at line 228.
pub fn ruby_brew_l228_d25_formulae_by_full_name(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 && args[0].type_name == 'Homebrew::Bundle::Brew::State' {
		bundle_brew_state_from_value(args[0])
	} else if args.len > 1 {
		bundle_brew_state_from_value(args[1])
	} else {
		BundleBrewState{}
	}
	if args.len > 0 && args[0].type_name != 'Homebrew::Bundle::Brew::State' {
		name := args[0].as_string()
		if name in state.unavailable {
			return brew_runtime.map_value({})
		}
		formula := bundle_brew_find_formula(state, name) or { return brew_runtime.map_value({}) }
		return bundle_brew_formula_value(formula)
	}
	return bundle_brew_formula_map_value(state.formulae, true)
}

// Ruby method `formulae_by_name(name)` at line 252.
pub fn ruby_brew_l252_d26_formulae_by_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bundle_brew_nil_value()
	}
	formula := bundle_brew_find_formula(bundle_brew_state_from_value(args[1]), bundle_brew_name_from_full_name(args[0].as_string())) or { return bundle_brew_nil_value() }
	return bundle_brew_formula_value(formula)
}

// Ruby method `dump(describe: false, no_restart: false)` at line 257.
pub fn ruby_brew_l257_d27_dump(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 {
		bundle_brew_state_from_value(args[0])
	} else {
		BundleBrewState{}
	}
	describe := if args.len > 1 { bundle_brew_bool(args[1], false) } else { false }
	no_restart := if args.len > 2 { bundle_brew_bool(args[2], false) } else { false }
	return brew_runtime.string_value(bundle_brew_dump(state, describe, no_restart))
}

// Ruby method `dump_output(describe: false, no_restart: false)` at line 282.
pub fn ruby_brew_l282_d28_dump_output(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_brew_l257_d27_dump(...args)
}

// Ruby method `fetchable_name(name, options = {}, no_upgrade: false)` at line 287.
pub fn ruby_brew_l287_d29_fetchable_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return bundle_brew_nil_value()
	}
	state := if args.len > 2 {
		bundle_brew_state_from_value(args[2])
	} else {
		BundleBrewState{}
	}
	no_upgrade := if args.len > 3 { bundle_brew_bool(args[3], false) } else { false }
	return if bundle_brew_installed_and_up_to_date(state, args[0].as_string(), no_upgrade) {
		bundle_brew_nil_value()
	} else {
		brew_runtime.string_value(args[0].as_string())
	}
}

// Ruby method `formula_aliases` at line 296.
pub fn ruby_brew_l296_d30_formula_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 {
		bundle_brew_state_from_value(args[0])
	} else {
		BundleBrewState{}
	}
	return bundle_brew_string_map_value(bundle_brew_formula_aliases(state))
}

// Ruby method `formula_oldnames` at line 315.
pub fn ruby_brew_l315_d31_formula_oldnames(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 {
		bundle_brew_state_from_value(args[0])
	} else {
		BundleBrewState{}
	}
	return bundle_brew_string_map_value(bundle_brew_formula_oldnames(state))
}

// Ruby method `add_formula(formula)` at line 336.
pub fn ruby_brew_l336_d32_add_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 {
		bundle_brew_formula_value(bundle_brew_formula_from_value(args.last()))
	} else {
		bundle_brew_nil_value()
	}
}

// Ruby method `formula_to_hash(formula)` at line 349.
pub fn ruby_brew_l349_d33_formula_to_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 {
		bundle_brew_formula_value(bundle_brew_formula_from_value(args[0]))
	} else {
		brew_runtime.map_value({})
	}
}

// Ruby method `sort!(formulae)` at line 408.
pub fn ruby_brew_l408_d34_sort(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 {
		bundle_brew_state_from_value(args[0])
	} else {
		BundleBrewState{}
	}
	formulae, cycles := bundle_brew_sorted_formulae(state)
	return brew_runtime.Value{
		type_name: 'SortedFormulae'
		array_data: formulae.map(bundle_brew_formula_value(it))
		map_data: {
			'cycles': brew_runtime.array_value(cycles.map(bundle_brew_strings_value(it)))
		}
	}
}

// Ruby method `initialize(name = "", options = {})` at line 461.
pub fn ruby_brew_l461_d35_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	options := if args.len > 1 {
		bundle_brew_options_from_value(args[1])
	} else {
		BundleBrewOptions{}
	}
	return bundle_brew_installer_value(bundle_brew_installer(name, options))
}

// Ruby method `installed_and_up_to_date?(formula, no_upgrade: false)` at line 477.
pub fn ruby_brew_l477_d36_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.bool_value(false)
	}
	installer := bundle_brew_installer_from_value(args[0])
	state := bundle_brew_state_from_value(args[2])
	name := if args[1].type_name == 'Homebrew::Bundle::Dsl::Entry' {
		args[1].repr
	} else {
		args[1].as_string()
	}
	no_upgrade := if args.len > 3 { bundle_brew_bool(args[3], false) } else { false }
	if !bundle_brew_installed_and_up_to_date(state, name, no_upgrade) {
		return brew_runtime.bool_value(false)
	}
	options := if args[1].type_name == 'Homebrew::Bundle::Dsl::Entry' {
		bundle_brew_options_from_value(brew_runtime.map_value(args[1].map_data))
	} else {
		BundleBrewOptions{}
	}
	status := bundle_brew_link_status_to_check(state, name, options, installer.keg_only) or { return brew_runtime.bool_value(true) }
	return brew_runtime.bool_value(installer.linked == status)
}

// Ruby method `failure_reason(name, no_upgrade:)` at line 489.
pub fn ruby_brew_l489_d37_failure_reason(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.string_value('Formula needs to be installed or updated.')
	}
	installer := bundle_brew_installer_from_value(args[0])
	name := if args[1].type_name == 'Homebrew::Bundle::Dsl::Entry' {
		args[1].repr
	} else {
		args[1].as_string()
	}
	state := bundle_brew_state_from_value(args[2])
	no_upgrade := if args.len > 3 { bundle_brew_bool(args[3], false) } else { false }
	if !bundle_brew_installed_and_up_to_date(state, name, no_upgrade) {
		reason := if bundle_brew_no_upgrade_with_args(state, no_upgrade, name) {
			'needs to be installed.'
		} else {
			'needs to be installed or updated.'
		}
		return brew_runtime.string_value('Formula ${name} ${reason}')
	}
	options := if args[1].type_name == 'Homebrew::Bundle::Dsl::Entry' {
		bundle_brew_options_from_value(brew_runtime.map_value(args[1].map_data))
	} else {
		BundleBrewOptions{}
	}
	status := bundle_brew_link_status_to_check(state, name, options, installer.keg_only) or { return brew_runtime.string_value('Formula ${name} needs to be installed or updated.') }
	return brew_runtime.string_value('Formula ${name} needs to be ${if status {
		'linked'
	} else {
		'unlinked'
	}}.')
}

// Ruby method `find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 509.
pub fn ruby_brew_l509_d38_find_actionable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return bundle_brew_strings_value([])
	}
	installer := bundle_brew_installer_from_value(args[0])
	entries := args[1].as_array() or { return bundle_brew_strings_value([]) }
	state := bundle_brew_state_from_value(args[2])
	exit_first := if args.len > 3 { bundle_brew_bool(args[3], false) } else { false }
	no_upgrade := if args.len > 4 { bundle_brew_bool(args[4], false) } else { false }
	mut failures := []string{}
	for entry in entries {
		name := if entry.type_name == 'Homebrew::Bundle::Dsl::Entry' {
			entry.repr
		} else {
			entry.as_string()
		}
		if !bundle_brew_installed_and_up_to_date(state, name, no_upgrade) {
			failures << 'Formula ${name} ${if bundle_brew_no_upgrade_with_args(state, no_upgrade, name) {
				'needs to be installed.'
			} else {
				'needs to be installed or updated.'
			}}'
			if exit_first {
				break
			}
		}
	}
	_ = installer
	return bundle_brew_strings_value(failures)
}

// Ruby method `preinstall!(no_upgrade: false, verbose: false)` at line 520.
pub fn ruby_brew_l520_d39_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	mut installer := bundle_brew_installer_from_value(args[0])
	state := bundle_brew_state_from_value(args[1])
	return brew_runtime.bool_value(bundle_brew_preinstall_instance(mut installer, state, if args.len > 2 {
		bundle_brew_bool(args[2], false)
	} else {
		false
	}))
}

// Ruby method `install!(preinstall: true, no_upgrade: false, verbose: false, force: false)` at line 531.
pub fn ruby_brew_l531_d40_install(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	mut installer := bundle_brew_installer_from_value(args[0])
	state := bundle_brew_state_from_value(args[1])
	effects := if args.len > 2 {
		bundle_brew_effects_from_value(args[2])
	} else {
		BundleBrewEffects{}
	}
	return brew_runtime.bool_value(bundle_brew_install_instance(mut installer, state, effects, if args.len > 3 {
		bundle_brew_bool(args[3], true)
	} else {
		true
	}, false, if args.len > 4 { bundle_brew_bool(args[4], false) } else { false }, if args.len > 5 {
		bundle_brew_bool(args[5], false)
	} else {
		false
	}).success)
}

// Ruby method `install_change_state!(no_upgrade:, verbose:, force:)` at line 567.
pub fn ruby_brew_l567_d41_install_change_state(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	mut installer := bundle_brew_installer_from_value(args[0])
	state := bundle_brew_state_from_value(args[1])
	effects := if args.len > 2 {
		bundle_brew_effects_from_value(args[2])
	} else {
		BundleBrewEffects{}
	}
	return brew_runtime.bool_value(bundle_brew_install_change(mut installer, state, effects, if args.len > 3 {
		bundle_brew_bool(args[3], false)
	} else {
		false
	}, if args.len > 4 { bundle_brew_bool(args[4], false) } else { false }).success)
}

// Ruby method `start_service?` at line 591.
pub fn ruby_brew_l591_d42_start_service(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_start_service(bundle_brew_installer_from_value(args[0])))
}

// Ruby method `start_service_needed?` at line 596.
pub fn ruby_brew_l596_d43_start_service_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_start_service_needed(bundle_brew_installer_from_value(args[0])))
}

// Ruby method `restart_service?` at line 602.
pub fn ruby_brew_l602_d44_restart_service(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_restart_service(bundle_brew_installer_from_value(args[0])))
}

// Ruby method `restart_service_needed?` at line 607.
pub fn ruby_brew_l607_d45_restart_service_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_restart_service_needed(bundle_brew_installer_from_value(args[0])))
}

// Ruby method `changed?` at line 615.
pub fn ruby_brew_l615_d46_changed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_installer_from_value(args[0]).changed)
}

// Ruby method `service_change_state!(verbose:)` at line 620.
pub fn ruby_brew_l620_d47_service_change_state(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(bundle_brew_service_change(bundle_brew_installer_from_value(args[0]), if args.len > 1 {
		bundle_brew_effects_from_value(args[1])
	} else {
		BundleBrewEffects{}
	}, if args.len > 2 { bundle_brew_bool(args[2], false) } else { false }).success)
}

// Ruby method `link_change_state!(verbose: false)` at line 637.
pub fn ruby_brew_l637_d48_link_change_state(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(bundle_brew_link_change(bundle_brew_installer_from_value(args[0]), if args.len > 1 {
		bundle_brew_effects_from_value(args[1])
	} else {
		BundleBrewEffects{}
	}, if args.len > 2 { bundle_brew_bool(args[2], false) } else { false }).success)
}

// Ruby method `postinstall_change_state!(verbose:)` at line 659.
pub fn ruby_brew_l659_d49_postinstall_change_state(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(bundle_brew_postinstall_change(bundle_brew_installer_from_value(args[0]), if args.len > 1 {
		bundle_brew_effects_from_value(args[1])
	} else {
		BundleBrewEffects{}
	}, if args.len > 2 { bundle_brew_bool(args[2], false) } else { false }).success)
}

// Ruby method `formula_name(formula)` at line 670.
pub fn ruby_brew_l670_d50_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula must be a String or Dsl::Entry')
	}
	if args[0].type_name == 'String' {
		return args[0]
	}
	if args[0].type_name == 'Homebrew::Bundle::Dsl::Entry' {
		return brew_runtime.string_value(args[0].repr)
	}
	return brew_runtime.object_value('TypeError', 'formula must be a String or Dsl::Entry, got ${args[0].type_name}: ${args[0].repr}')
}

// Ruby method `formula_options(formula)` at line 678.
pub fn ruby_brew_l678_d51_formula_options(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 && args[0].type_name == 'Homebrew::Bundle::Dsl::Entry' {
		brew_runtime.map_value(args[0].map_data)
	} else {
		brew_runtime.map_value({})
	}
}

// Ruby method `installed?` at line 685.
pub fn ruby_brew_l685_d52_installed(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(bundle_brew_formula_installed(bundle_brew_state_from_value(args[1]), bundle_brew_installer_from_value(args[0]).name))
}

// Ruby method `linked?` at line 690.
pub fn ruby_brew_l690_d53_linked(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_installer_from_value(args[0]).linked)
}

// Ruby method `keg_only?` at line 695.
pub fn ruby_brew_l695_d54_keg_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && bundle_brew_installer_from_value(args[0]).keg_only)
}

// Ruby method `unlinked_and_keg_only?` at line 700.
pub fn ruby_brew_l700_d55_unlinked_and_keg_only(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	installer := bundle_brew_installer_from_value(args[0])
	return brew_runtime.bool_value(!installer.linked && installer.keg_only)
}

// Ruby method `upgradable?` at line 705.
pub fn ruby_brew_l705_d56_upgradable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	installer := bundle_brew_installer_from_value(args[0])
	return brew_runtime.bool_value(bundle_brew_formula_upgradable(bundle_brew_state_from_value(args[1]), installer.full_name))
}

// Ruby method `conflicts_with` at line 710.
pub fn ruby_brew_l710_d57_conflicts_with(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 {
		bundle_brew_strings_value(bundle_brew_conflicts(bundle_brew_installer_from_value(args[0])))
	} else {
		bundle_brew_strings_value([])
	}
}

// Ruby method `resolve_conflicts!(verbose:)` at line 729.
pub fn ruby_brew_l729_d58_resolve_conflicts(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(bundle_brew_resolve_conflicts(bundle_brew_installer_from_value(args[0]), bundle_brew_state_from_value(args[1]), if args.len > 2 {
		bundle_brew_effects_from_value(args[2])
	} else {
		BundleBrewEffects{}
	}, if args.len > 3 { bundle_brew_bool(args[3], false) } else { false }).success)
}

// Ruby method `install_formula!(verbose:, force:)` at line 752.
pub fn ruby_brew_l752_d59_install_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	mut installer := bundle_brew_installer_from_value(args[0])
	return brew_runtime.bool_value(bundle_brew_install_formula(mut installer, if args.len > 1 {
		bundle_brew_effects_from_value(args[1])
	} else {
		BundleBrewEffects{}
	}, if args.len > 2 { bundle_brew_bool(args[2], false) } else { false }, if args.len > 3 {
		bundle_brew_bool(args[3], false)
	} else {
		false
	}).success)
}

// Ruby method `upgrade_formula!(verbose:, force:)` at line 769.
pub fn ruby_brew_l769_d60_upgrade_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	mut installer := bundle_brew_installer_from_value(args[0])
	return brew_runtime.bool_value(bundle_brew_upgrade_formula(mut installer, if args.len > 1 {
		bundle_brew_effects_from_value(args[1])
	} else {
		BundleBrewEffects{}
	}, if args.len > 2 { bundle_brew_bool(args[2], false) } else { false }, if args.len > 3 {
		bundle_brew_bool(args[3], false)
	} else {
		false
	}).success)
}

// Ruby method `each_key(&block)` at line 798.
pub fn ruby_brew_l798_d61_each_key(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return bundle_brew_strings_value([])
	}
	mut keys := args[0].map_data.keys()
	keys.sort()
	return bundle_brew_strings_value(keys)
}

// Ruby alias `alias tsort_each_node each_key` at line 801.
pub fn ruby_brew_l801_d62_tsort_each_node(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_brew_l798_d61_each_key(...args)
}

// Ruby method `tsort_each_child(node, &block)` at line 804.
pub fn ruby_brew_l804_d63_tsort_each_child(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bundle_brew_strings_value([])
	}
	mut children := bundle_brew_strings_from_value(args[0].map_data[args[1].as_string()] or { bundle_brew_strings_value([]) })
	children.sort()
	return bundle_brew_strings_value(children)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "tsort"
// 6: require "utils"
// 7: require "utils/topological_hash"
// 8: require "utils/output"
// 9: require "bundle/package_type"
// 10: require "trust"
// 11:
// 12: module Homebrew
// 13:   module Bundle
// 14:     class Brew < Homebrew::Bundle::PackageType
// 15:       extend Utils::Output::Mixin
// 16:
// 17:       class << self
// 18:         sig { override.returns(Symbol) }
// 19:         def type = :brew
// 20:
// 21:         sig { override.returns(String) }
// 22:         def check_label = "Formula"
// 23:
// 24:         sig { override.params(subclass: T.class_of(Homebrew::Bundle::PackageType)).void }
// 25:         def inherited(subclass)
// 26:           return if subclass.name == "Homebrew::Bundle::Brew::Services"
// 27:
// 28:           super
// 29:         end
// 30:
// 31:         sig { override.void }
// 32:         def reset!
// 33:           require "bundle/brew_services"
// 34:
// 35:           Homebrew::Bundle::Brew::Services.reset!
// 36:           @installed_formulae = T.let(nil, T.nilable(T::Array[String]))
// 37:           @outdated_formulae = T.let(nil, T.nilable(T::Array[String]))
// 38:           @pinned_formulae = T.let(nil, T.nilable(T::Array[String]))
// 39:           @formulae = T.let(nil, T.nilable(T::Array[T::Hash[Symbol, T.untyped]]))
// 40:           @formulae_by_full_name = T.let(nil, T.nilable(T::Hash[String, T::Hash[Symbol, T.untyped]]))
// 41:           @formulae_by_name = T.let(nil, T.nilable(T::Hash[String, T::Hash[Symbol, T.untyped]]))
// 42:           @formula_aliases = T.let(nil, T.nilable(T::Hash[String, String]))
// 43:           @formula_oldnames = T.let(nil, T.nilable(T::Hash[String, String]))
// 44:         end
// 45:
// 46:         sig {
// 47:           params(formulae_by_name: T.nilable(T::Hash[String, T::Hash[Symbol, T.untyped]]))
// 48:             .returns(T.nilable(T::Hash[String, T::Hash[Symbol, T.untyped]]))
// 49:         }
// 50:         attr_writer :formulae_by_name
// 51:
// 52:         sig { override.params(name: String, no_upgrade: T::Boolean, verbose: T::Boolean, options: T.untyped).returns(T::Boolean) }
// 53:         def preinstall!(name, no_upgrade: false, verbose: false, **options)
// 54:           new(name, options).preinstall!(no_upgrade:, verbose:)
// 55:         end
// 56:
// 57:         sig {
// 58:           override.params(name: String, preinstall: T::Boolean, no_upgrade: T::Boolean, verbose: T::Boolean,
// 59:                           force: T::Boolean, options: T.untyped).returns(T::Boolean)
// 60:         }
// 61:         def install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, **options)
// 62:           new(name, options).install!(preinstall:, no_upgrade:, verbose:, force:)
// 63:         end
// 64:
// 65:         # Override makes `name` a required argument unlike the parent's default-argument signature.
// 66:         # rubocop:disable Sorbet/AllowIncompatibleOverride
// 67:         sig {
// 68:           override(allow_incompatible: true).params(name: String, options: Homebrew::Bundle::EntryOptions).returns(String)
// 69:         }
// 70:         # rubocop:enable Sorbet/AllowIncompatibleOverride
// 71:         def install_verb(name, options = {})
// 72:           _ = options
// 73:
// 74:           return "Installing" unless formula_upgradable?(name)
// 75:
// 76:           "Upgrading"
// 77:         end
// 78:
// 79:         sig { params(formula: String, no_upgrade: T::Boolean).returns(T::Boolean) }
// 80:         def formula_installed_and_up_to_date?(formula, no_upgrade: false)
// 81:           return false unless formula_installed?(formula)
// 82:           return true if no_upgrade_with_args?(no_upgrade, formula)
// 83:
// 84:           !formula_upgradable?(formula)
// 85:         end
// 86:
// 87:         sig { params(formula: String, options: Homebrew::Bundle::EntryOptions).returns(T.nilable(T::Boolean)) }
// 88:         def link_status_to_check(formula, options)
// 89:           unless options.key?(:link)
// 90:             return case formula_dump_link_status(formula)
// 91:             when true
// 92:               false
// 93:             when false
// 94:               true
// 95:             end
// 96:           end
// 97:
// 98:           expected_link_status?(options[:link], keg_only: Formula[formula].keg_only?)
// 99:         end
// 100:
// 101:         sig { params(link: Homebrew::Bundle::EntryOption, keg_only: T::Boolean).returns(T::Boolean) }
// 102:         def expected_link_status?(link, keg_only:)
// 103:           case link
// 104:           when :overwrite, true
// 105:             true
// 106:           when false
// 107:             false
// 108:           else
// 109:             !keg_only
// 110:           end
// 111:         end
// 112:
// 113:         sig { params(formula: String).returns(T.nilable(T::Boolean)) }
// 114:         def formula_dump_link_status(formula)
// 115:           (
// 116:             @formulae_by_full_name&.[](formula) ||
// 117:             @formulae_by_name&.[](Utils.name_from_full_name(formula))
// 118:           )&.fetch(:link?)
// 119:         end
// 120:
// 121:         sig { params(no_upgrade: T::Boolean, formula_name: String).returns(T::Boolean) }
// 122:         def no_upgrade_with_args?(no_upgrade, formula_name)
// 123:           no_upgrade && Bundle.upgrade_formulae.exclude?(formula_name)
// 124:         end
// 125:
// 126:         sig { params(formula: String, array: T::Array[String]).returns(T::Boolean) }
// 127:         def formula_in_array?(formula, array)
// 128:           return true if array.include?(formula)
// 129:           return true if array.include?(Utils.name_from_full_name(formula))
// 130:
// 131:           old_name = formula_oldnames[formula]
// 132:           old_name ||= formula_oldnames[Utils.name_from_full_name(formula)]
// 133:           return true if old_name && array.include?(old_name)
// 134:
// 135:           resolved_full_name = formula_aliases[formula]
// 136:           return false unless resolved_full_name
// 137:           return true if array.include?(resolved_full_name)
// 138:           return true if array.include?(Utils.name_from_full_name(resolved_full_name))
// 139:
// 140:           false
// 141:         end
// 142:
// 143:         sig { params(formula: String).returns(T::Boolean) }
// 144:         def formula_installed?(formula)
// 145:           # Fully qualified tap formulae can be checked by their Cellar rack name
// 146:           # without loading the formula from an untrusted tap.
// 147:           return installed_formulae.include?(Utils.name_from_full_name(formula)) if Utils.full_name?(formula)
// 148:
// 149:           formula_in_array?(formula, installed_formulae)
// 150:         end
// 151:
// 152:         sig { params(formula: String).returns(T::Boolean) }
// 153:         def formula_upgradable?(formula)
// 154:           return false unless formula_installed?(formula)
// 155:
// 156:           # Reading the formula is needed for authoritative outdated state, so
// 157:           # report trust problems before the upgrade check tries to load it.
// 158:           if Utils.full_name?(formula) && Homebrew::EnvConfig.require_tap_trust?
// 159:             require "trust"
// 160:
// 161:             unless Homebrew::Trust.trusted?(:formula, formula)
// 162:               opoo "Cannot check whether #{formula} is outdated because its tap is not trusted. " \
// 163:                    "Run `brew trust --formula #{formula}` to trust it."
// 164:               return true
// 165:             end
// 166:           end
// 167:
// 168:           # Check local cache first and then authoritative Homebrew source.
// 169:           (formula_in_array?(formula, upgradable_formulae) && Formula[formula].outdated?) || false
// 170:         end
// 171:
// 172:         sig { returns(T::Array[String]) }
// 173:         def installed_formulae
// 174:           @installed_formulae ||= Formula.installed_formula_names
// 175:         end
// 176:
// 177:         sig { returns(T::Array[String]) }
// 178:         def upgradable_formulae
// 179:           outdated_formulae - pinned_formulae
// 180:         end
// 181:
// 182:         sig { returns(T::Array[String]) }
// 183:         def outdated_formulae
// 184:           @outdated_formulae ||= formulae.filter_map { |f| f[:name] if f[:outdated?] }
// 185:         end
// 186:
// 187:         sig { returns(T::Array[String]) }
// 188:         def pinned_formulae
// 189:           @pinned_formulae ||= formulae.filter_map { |f| f[:name] if f[:pinned?] }
// 190:         end
// 191:
// 192:         sig { params(name: String).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
// 193:         def find_formula(name)
// 194:           formula = T.cast(formulae_by_full_name(name), T.nilable(T::Hash[Symbol, T.untyped]))
// 195:           formula.presence || formulae_by_name(name)
// 196:         end
// 197:
// 198:         sig { params(name: String).returns(T::Array[String]) }
// 199:         def formula_dep_names(name)
// 200:           find_formula(name)&.fetch(:dependencies, []) || []
// 201:         end
// 202:
// 203:         # Returns recursive dependency names for lock conflict detection.
// 204:         sig { params(name: String).returns(T::Set[String]) }
// 205:         def recursive_dep_names(name)
// 206:           require "formula"
// 207:           Formula[name].recursive_dependencies.to_set(&:name)
// 208:         rescue FormulaUnavailableError
// 209:           Set.new
// 210:         end
// 211:
// 212:         sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
// 213:         def formulae
// 214:           return @formulae if @formulae
// 215:
// 216:           formulae_by_full_name
// 217:           # formulae_by_full_name sets @formulae as a side effect of calling sort!
// 218:           T.cast(@formulae, T::Array[T::Hash[Symbol, T.untyped]])
// 219:         end
// 220:
// 221:         # Returns the full `@formulae_by_full_name` map when called without a name,
// 222:         # or a single formula's attribute hash when called with a name.
// 223:         sig {
// 224:           params(name: T.nilable(String)).returns(
// 225:             T.nilable(T.any(T::Hash[Symbol, T.untyped], T::Hash[String, T::Hash[Symbol, T.untyped]])),
// 226:           )
// 227:         }
// 228:         def formulae_by_full_name(name = nil)
// 229:           return @formulae_by_full_name[name] if name.present? && @formulae_by_full_name&.key?(name)
// 230:
// 231:           require "formula"
// 232:           require "formulary"
// 233:           Formulary.enable_factory_cache!
// 234:
// 235:           @formulae_by_name ||= {}
// 236:           @formulae_by_full_name ||= {}
// 237:
// 238:           if name.nil?
// 239:             formulae = Formula.installed.map { add_formula(it) }
// 240:             sort!(formulae)
// 241:             return @formulae_by_full_name
// 242:           end
// 243:
// 244:           formula = Formula[name]
// 245:           add_formula(formula)
// 246:         rescue FormulaUnavailableError => e
// 247:           opoo "'#{name}' formula is unreadable: #{e}"
// 248:           {}
// 249:         end
// 250:
// 251:         sig { params(name: String).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
// 252:         def formulae_by_name(name)
// 253:           T.cast(formulae_by_full_name(name), T.nilable(T::Hash[Symbol, T.untyped])) || @formulae_by_name&.[](name)
// 254:         end
// 255:
// 256:         sig { override.params(describe: T::Boolean, no_restart: T::Boolean).returns(String) }
// 257:         def dump(describe: false, no_restart: false)
// 258:           require "bundle/brew_services"
// 259:
// 260:           requested_formula = formulae.select do |f|
// 261:             f[:installed_on_request?]
// 262:           end
// 263:           trusted_formulae = Homebrew::Trust.trusted_entries(:formula)
// 264:           requested_formula.map do |f|
// 265:             brewline = if describe && f[:desc].present?
// 266:               f[:desc].split("\n").map { |s| "# #{s}\n" }.join
// 267:             else
// 268:               ""
// 269:             end
// 270:             brewline += "brew \"#{f[:full_name]}\""
// 271:
// 272:             args = f[:args].map { |arg| "\"#{arg}\"" }.sort.join(", ")
// 273:             brewline += ", args: [#{args}]" unless f[:args].empty?
// 274:             brewline += ", restart_service: :changed" if !no_restart && Services.started?(f[:full_name])
// 275:             brewline += ", link: #{f[:link?]}" unless f[:link?].nil?
// 276:             brewline += ", trusted: true" if trusted_formulae.include?(f[:full_name])
// 277:             brewline
// 278:           end.join("\n")
// 279:         end
// 280:
// 281:         sig { override.params(describe: T::Boolean, no_restart: T::Boolean).returns(String) }
// 282:         def dump_output(describe: false, no_restart: false)
// 283:           dump(describe:, no_restart:)
// 284:         end
// 285:
// 286:         sig { override.params(name: String, options: T::Hash[Symbol, T.untyped], no_upgrade: T::Boolean).returns(T.nilable(String)) }
// 287:         def fetchable_name(name, options = {}, no_upgrade: false)
// 288:           _ = options
// 289:
// 290:           return if formula_installed_and_up_to_date?(name, no_upgrade:)
// 291:
// 292:           name
// 293:         end
// 294:
// 295:         sig { returns(T::Hash[String, String]) }
// 296:         def formula_aliases
// 297:           return @formula_aliases if @formula_aliases
// 298:
// 299:           @formula_aliases = {}
// 300:           formulae.each do |f|
// 301:             aliases = f[:aliases]
// 302:             next if aliases.blank?
// 303:
// 304:             aliases.each do |a|
// 305:               @formula_aliases[a] = f[:full_name]
// 306:               if (tap_name = Utils.tap_from_full_name(f[:full_name]))
// 307:                 @formula_aliases["#{tap_name}/#{a}"] = f[:full_name]
// 308:               end
// 309:             end
// 310:           end
// 311:           @formula_aliases
// 312:         end
// 313:
// 314:         sig { returns(T::Hash[String, String]) }
// 315:         def formula_oldnames
// 316:           return @formula_oldnames if @formula_oldnames
// 317:
// 318:           @formula_oldnames = {}
// 319:           formulae.each do |f|
// 320:             oldnames = f[:oldnames]
// 321:             next if oldnames.blank?
// 322:
// 323:             oldnames.each do |oldname|
// 324:               @formula_oldnames[oldname] = f[:full_name]
// 325:               if (tap_name = Utils.tap_from_full_name(f[:full_name]))
// 326:                 @formula_oldnames["#{tap_name}/#{oldname}"] = f[:full_name]
// 327:               end
// 328:             end
// 329:           end
// 330:           @formula_oldnames
// 331:         end
// 332:
// 333:         private
// 334:
// 335:         sig { params(formula: Formula).returns(T::Hash[Symbol, T.untyped]) }
// 336:         def add_formula(formula)
// 337:           hash = formula_to_hash formula
// 338:
// 339:           raise "formulae_by_name is nil" if @formulae_by_name.nil?
// 340:           raise "formulae_by_full_name is nil" if @formulae_by_full_name.nil?
// 341:
// 342:           @formulae_by_name[hash[:name]] = hash
// 343:           @formulae_by_full_name[hash[:full_name]] = hash
// 344:
// 345:           hash
// 346:         end
// 347:
// 348:         sig { params(formula: Formula).returns(T::Hash[Symbol, T.untyped]) }
// 349:         def formula_to_hash(formula)
// 350:           keg = if formula.linked?
// 351:             link = true if formula.keg_only?
// 352:             formula.linked_keg
// 353:           else
// 354:             link = false unless formula.keg_only?
// 355:             formula.any_installed_prefix
// 356:           end
// 357:
// 358:           if keg
// 359:             require "tab"
// 360:
// 361:             tab = Tab.for_keg(keg)
// 362:             args = tab.used_options.map(&:name)
// 363:             version = begin
// 364:               keg.realpath.basename
// 365:             rescue
// 366:               # silently handle broken symlinks
// 367:               nil
// 368:             end.to_s
// 369:             args << "HEAD" if version.start_with?("HEAD")
// 370:             installed_on_request = tab.installed_on_request
// 371:             runtime_dependencies = if (runtime_deps = tab.runtime_dependencies)
// 372:               T.cast(runtime_deps, T::Array[T::Hash[String, T.untyped]]).filter_map { |d| d["full_name"] }
// 373:             end
// 374:             poured_from_bottle = tab.poured_from_bottle
// 375:           end
// 376:
// 377:           runtime_dependencies ||= formula.runtime_dependencies.map(&:name)
// 378:
// 379:           bottled = if (stable = formula.stable) && stable.bottle_defined?
// 380:             bottle_hash = formula.bottle_hash.deep_symbolize_keys
// 381:             stable.bottled?
// 382:           end
// 383:
// 384:           {
// 385:             name:                   formula.name,
// 386:             desc:                   formula.desc,
// 387:             oldnames:               formula.oldnames,
// 388:             full_name:              formula.full_name,
// 389:             aliases:                formula.aliases,
// 390:             any_version_installed?: formula.any_version_installed?,
// 391:             args:                   Array(args).uniq,
// 392:             version:,
// 393:             installed_on_request?:  installed_on_request != false,
// 394:             dependencies:           runtime_dependencies,
// 395:             build_dependencies:     formula.deps.select(&:build?).map(&:name).uniq,
// 396:             conflicts_with:         formula.conflicts.map(&:name),
// 397:             pinned?:                formula.pinned? || false,
// 398:             outdated?:              formula.outdated? || false,
// 399:             link?:                  link,
// 400:             poured_from_bottle?:    poured_from_bottle || false,
// 401:             bottle:                 bottle_hash || false,
// 402:             bottled:                bottled || false,
// 403:             official_tap:           formula.tap&.official? || false,
// 404:           }
// 405:         end
// 406:
// 407:         sig { params(formulae: T::Array[T::Hash[Symbol, T.untyped]]).void }
// 408:         def sort!(formulae)
// 409:           # Step 1: Sort by formula full name while putting tap formulae behind core formulae.
// 410:           #         So we can have a nicer output.
// 411:           formulae = formulae.sort do |a, b|
// 412:             if a[:full_name].exclude?("/") && b[:full_name].include?("/")
// 413:               -1
// 414:             elsif a[:full_name].include?("/") && b[:full_name].exclude?("/")
// 415:               1
// 416:             else
// 417:               a[:full_name] <=> b[:full_name]
// 418:             end
// 419:           end
// 420:
// 421:           # Step 2: Sort by formula dependency topology.
// 422:           topo = Topo.new
// 423:           formulae.each do |f|
// 424:             topo[f[:name]] = topo[f[:full_name]] = f[:dependencies].filter_map do |dep|
// 425:               ff = formulae_by_name(dep)
// 426:               next if ff.blank?
// 427:               next unless ff[:any_version_installed?]
// 428:
// 429:               ff[:full_name]
// 430:             end
// 431:           end
// 432:
// 433:           raise "formulae_by_full_name is nil" if @formulae_by_full_name.nil?
// 434:           raise "formulae_by_name is nil" if @formulae_by_name.nil?
// 435:
// 436:           # Stale keg-tab dependency data can form a cycle the live graph does not
// 437:           # have (Homebrew/homebrew-bundle#1513), so warn and continue rather than
// 438:           # aborting the whole bundle.
// 439:           sorted = topo.tsort_with_cycles do |cycles|
// 440:             cyclic = cycles.flatten
// 441:                            .filter_map { |name| @formulae_by_full_name[name] || @formulae_by_name[name] }
// 442:                            .uniq { |f| f[:full_name] }
// 443:                            .map { |f| f[:full_name] }
// 444:             opoo <<~EOS
// 445:               Formulae dependency graph sorting found a circular dependency:
// 446:                 #{cyclic.join(", ")}
// 447:               This is usually caused by stale dependency data in installed keg tabs.
// 448:               If it persists, run the following commands and try again:
// 449:                 brew update
// 450:                 brew uninstall --ignore-dependencies --force #{cyclic.join(" ")}
// 451:                 brew install #{cyclic.join(" ")}
// 452:             EOS
// 453:           end
// 454:
// 455:           @formulae = sorted.filter_map { |name| @formulae_by_full_name[name] || @formulae_by_name[name] }
// 456:                             .uniq { |f| f[:full_name] }
// 457:         end
// 458:       end
// 459:
// 460:       sig { params(name: String, options: T::Hash[Symbol, T.untyped]).void }
// 461:       def initialize(name = "", options = {})
// 462:         super()
// 463:         @full_name = name
// 464:         @name = T.let(Utils.name_from_full_name(name), String)
// 465:         @args = T.let(options.fetch(:args, []).map { |arg| "--#{arg}" }, T::Array[String])
// 466:         @conflicts_with_arg = T.let(options.fetch(:conflicts_with, []), T::Array[String])
// 467:         @restart_service = T.let(options[:restart_service], T.nilable(T.any(Symbol, T::Boolean)))
// 468:         @start_service = T.let(options.fetch(:start_service, @restart_service), T.nilable(T.any(Symbol, T::Boolean)))
// 469:         @link = T.let(options.fetch(:link, nil), T.nilable(T.any(Symbol, T::Boolean)))
// 470:         @postinstall = T.let(options.fetch(:postinstall, nil), T.nilable(String))
// 471:         @version_file = T.let(options.fetch(:version_file, nil), T.nilable(String))
// 472:         @trusted = T.let(options.fetch(:trusted, false), T::Boolean)
// 473:         @changed = T.let(nil, T.nilable(T::Boolean))
// 474:       end
// 475:
// 476:       sig { override.params(formula: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 477:       def installed_and_up_to_date?(formula, no_upgrade: false)
// 478:         name = formula_name(formula)
// 479:         return false unless self.class.formula_installed_and_up_to_date?(name, no_upgrade:)
// 480:
// 481:         options = formula_options(formula)
// 482:         link_status = self.class.link_status_to_check(name, options)
// 483:         return true if link_status.nil?
// 484:
// 485:         Formula[name].linked? == link_status
// 486:       end
// 487:
// 488:       sig { override.params(name: Object, no_upgrade: T::Boolean).returns(String) }
// 489:       def failure_reason(name, no_upgrade:)
// 490:         formula = formula_name(name)
// 491:         options = formula_options(name)
// 492:         return super(formula, no_upgrade:) unless self.class.formula_installed_and_up_to_date?(formula, no_upgrade:)
// 493:
// 494:         link_status = self.class.link_status_to_check(formula, options)
// 495:         return super(formula, no_upgrade:) if link_status.nil?
// 496:
// 497:         link_status = link_status ? "linked" : "unlinked"
// 498:         "Formula #{formula} needs to be #{link_status}."
// 499:       end
// 500:
// 501:       sig {
// 502:         override.params(
// 503:           entries:             T::Array[Dsl::Entry],
// 504:           exit_on_first_error: T::Boolean,
// 505:           no_upgrade:          T::Boolean,
// 506:           verbose:             T::Boolean,
// 507:         ).returns(T::Array[String])
// 508:       }
// 509:       def find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 510:         requested = instance_of?(Homebrew::Bundle::Brew) ? checkable_entries(entries) : format_checkable(entries)
// 511:
// 512:         if exit_on_first_error
// 513:           exit_early_check(requested, no_upgrade:)
// 514:         else
// 515:           full_check(requested, no_upgrade:)
// 516:         end
// 517:       end
// 518:
// 519:       sig { params(no_upgrade: T::Boolean, verbose: T::Boolean).returns(T::Boolean) }
// 520:       def preinstall!(no_upgrade: false, verbose: false)
// 521:         if installed? && (self.class.no_upgrade_with_args?(no_upgrade, @name) || !upgradable?)
// 522:           puts "Skipping install of #{@name} formula. It is already installed." if verbose
// 523:           @changed = nil
// 524:           return false
// 525:         end
// 526:
// 527:         true
// 528:       end
// 529:
// 530:       sig { params(preinstall: T::Boolean, no_upgrade: T::Boolean, verbose: T::Boolean, force: T::Boolean).returns(T::Boolean) }
// 531:       def install!(preinstall: true, no_upgrade: false, verbose: false, force: false)
// 532:         install_result = if preinstall
// 533:           install_change_state!(no_upgrade:, verbose:, force:)
// 534:         else
// 535:           true
// 536:         end
// 537:         result = install_result
// 538:
// 539:         if installed?
// 540:           service_result = service_change_state!(verbose:)
// 541:           result &&= service_result
// 542:
// 543:           link_result = link_change_state!(verbose:)
// 544:           result &&= link_result
// 545:
// 546:           postinstall_result = postinstall_change_state!(verbose:)
// 547:           result &&= postinstall_result
// 548:
// 549:           if result && @version_file.present?
// 550:             # Use the version from the environment if it hasn't changed.
// 551:             # Strip the revision number because it's not part of the non-Homebrew version.
// 552:             version = if !changed? && (env_version = Bundle.formula_versions_from_env(@name))
// 553:               PkgVersion.parse(env_version).version
// 554:             else
// 555:               Formula[@full_name].version
// 556:             end.to_s
// 557:             File.write(@version_file, "#{version}\n")
// 558:
// 559:             puts "Wrote #{@name} version #{version} to #{@version_file}" if verbose
// 560:           end
// 561:         end
// 562:
// 563:         result
// 564:       end
// 565:
// 566:       sig { params(no_upgrade: T::Boolean, verbose: T::Boolean, force: T::Boolean).returns(T::Boolean) }
// 567:       def install_change_state!(no_upgrade:, verbose:, force:)
// 568:         require "tap"
// 569:
// 570:         # Trust before tapping: installing the tap loads the formula, which
// 571:         # triggers the trust check before any later step could grant trust.
// 572:         # Only fully-qualified names map to a tap, so unqualified names cannot
// 573:         # be meaningfully trusted.
// 574:         Homebrew::Trust.trust!(:formula, @full_name) if @trusted && Utils.full_name?(@full_name)
// 575:
// 576:         if (tap_with_name = ::Tap.with_formula_name(@full_name))
// 577:           tap, = tap_with_name
// 578:           tap.ensure_installed!
// 579:         end
// 580:
// 581:         return false unless resolve_conflicts!(verbose:)
// 582:
// 583:         if installed?
// 584:           upgrade_formula!(verbose:, force:)
// 585:         else
// 586:           install_formula!(verbose:, force:)
// 587:         end
// 588:       end
// 589:
// 590:       sig { returns(T::Boolean) }
// 591:       def start_service?
// 592:         @start_service.present?
// 593:       end
// 594:
// 595:       sig { returns(T::Boolean) }
// 596:       def start_service_needed?
// 597:         require "bundle/brew_services"
// 598:         start_service? && !Services.started?(@full_name)
// 599:       end
// 600:
// 601:       sig { returns(T::Boolean) }
// 602:       def restart_service?
// 603:         @restart_service.present?
// 604:       end
// 605:
// 606:       sig { returns(T::Boolean) }
// 607:       def restart_service_needed?
// 608:         return false unless restart_service?
// 609:
// 610:         # Restart if `restart_service: :always`, or if the formula was installed or upgraded
// 611:         @restart_service.to_s == "always" || changed?
// 612:       end
// 613:
// 614:       sig { returns(T::Boolean) }
// 615:       def changed?
// 616:         @changed.present?
// 617:       end
// 618:
// 619:       sig { params(verbose: T::Boolean).returns(T::Boolean) }
// 620:       def service_change_state!(verbose:)
// 621:         require "bundle/brew_services"
// 622:
// 623:         file = Services.versioned_service_file(@name)&.to_s
// 624:
// 625:         if restart_service_needed?
// 626:           puts "Restarting #{@name} service." if verbose
// 627:           Services.restart(@full_name, file:, verbose:)
// 628:         elsif start_service_needed?
// 629:           puts "Starting #{@name} service." if verbose
// 630:           Services.start(@full_name, file:, verbose:)
// 631:         else
// 632:           true
// 633:         end
// 634:       end
// 635:
// 636:       sig { params(verbose: T::Boolean).returns(T::Boolean) }
// 637:       def link_change_state!(verbose: false)
// 638:         link_args = []
// 639:         link_status = self.class.expected_link_status?(@link, keg_only: keg_only?)
// 640:         cmd = if link_status
// 641:           link_args << "--force" if unlinked_and_keg_only?
// 642:           link_args << "--overwrite" if @link == :overwrite
// 643:           "link" unless linked?
// 644:         elsif linked?
// 645:           "unlink"
// 646:         end
// 647:
// 648:         if cmd.present?
// 649:           verb = "#{cmd}ing".capitalize
// 650:           with_args = " with #{link_args.join(" ")}" if link_args.present?
// 651:           puts "#{verb} #{@name} formula#{with_args}." if verbose
// 652:           return Bundle.brew(cmd, *link_args, @name, verbose:)
// 653:         end
// 654:
// 655:         true
// 656:       end
// 657:
// 658:       sig { params(verbose: T::Boolean).returns(T::Boolean) }
// 659:       def postinstall_change_state!(verbose:)
// 660:         return true if @postinstall.blank?
// 661:         return true unless changed?
// 662:
// 663:         puts "Running postinstall for #{@name}: #{@postinstall}" if verbose
// 664:         Kernel.system(@postinstall) || false
// 665:       end
// 666:
// 667:       private
// 668:
// 669:       sig { params(formula: Object).returns(String) }
// 670:       def formula_name(formula)
// 671:         return formula.name if formula.is_a?(Dsl::Entry)
// 672:         return formula if formula.is_a?(String)
// 673:
// 674:         raise "formula must be a String or Dsl::Entry, got #{formula.class}: #{formula}"
// 675:       end
// 676:
// 677:       sig { params(formula: Object).returns(Homebrew::Bundle::EntryOptions) }
// 678:       def formula_options(formula)
// 679:         return formula.options if formula.is_a?(Dsl::Entry)
// 680:
// 681:         {}
// 682:       end
// 683:
// 684:       sig { returns(T::Boolean) }
// 685:       def installed?
// 686:         self.class.formula_installed?(@name)
// 687:       end
// 688:
// 689:       sig { returns(T::Boolean) }
// 690:       def linked?
// 691:         Formula[@full_name].linked?
// 692:       end
// 693:
// 694:       sig { returns(T::Boolean) }
// 695:       def keg_only?
// 696:         Formula[@full_name].keg_only?
// 697:       end
// 698:
// 699:       sig { returns(T::Boolean) }
// 700:       def unlinked_and_keg_only?
// 701:         !linked? && keg_only?
// 702:       end
// 703:
// 704:       sig { returns(T::Boolean) }
// 705:       def upgradable?
// 706:         self.class.formula_upgradable?(@full_name)
// 707:       end
// 708:
// 709:       sig { returns(T::Array[String]) }
// 710:       def conflicts_with
// 711:         @conflicts_with ||= T.let(
// 712:           begin
// 713:             conflicts_with = Set.new
// 714:             conflicts_with += @conflicts_with_arg
// 715:
// 716:             if (formula = T.cast(self.class.formulae_by_full_name(@full_name),
// 717:                                  T.nilable(T::Hash[Symbol, T.untyped]))) &&
// 718:               (formula_conflicts_with = formula[:conflicts_with])
// 719:               conflicts_with += formula_conflicts_with
// 720:             end
// 721:
// 722:             conflicts_with.to_a
// 723:           end,
// 724:           T.nilable(T::Array[String]),
// 725:         )
// 726:       end
// 727:
// 728:       sig { params(verbose: T::Boolean).returns(T::Boolean) }
// 729:       def resolve_conflicts!(verbose:)
// 730:         conflicts_with.each do |conflict|
// 731:           next unless self.class.formula_installed?(conflict)
// 732:
// 733:           if verbose
// 734:             puts <<~EOS
// 735:               Unlinking #{conflict} formula.
// 736:               It is currently installed and conflicts with #{@name}.
// 737:             EOS
// 738:           end
// 739:           return false unless Bundle.brew("unlink", conflict, verbose:)
// 740:
// 741:           next unless restart_service?
// 742:
// 743:           require "bundle/brew_services"
// 744:           puts "Stopping #{conflict} service (if it is running)." if verbose
// 745:           Services.stop(conflict, verbose:)
// 746:         end
// 747:
// 748:         true
// 749:       end
// 750:
// 751:       sig { params(verbose: T::Boolean, force: T::Boolean).returns(T::Boolean) }
// 752:       def install_formula!(verbose:, force:)
// 753:         install_args = @args.dup
// 754:         install_args << "--force" << "--overwrite" if force
// 755:         install_args << "--skip-link" if @link == false
// 756:         with_args = " with #{install_args.join(" ")}" if install_args.present?
// 757:         puts "Installing #{@name} formula#{with_args}. It is not currently installed." if verbose
// 758:         unless Bundle.brew("install", "--formula", @full_name, *install_args, verbose:)
// 759:           @changed = nil
// 760:           return false
// 761:         end
// 762:
// 763:         self.class.installed_formulae << @name
// 764:         @changed = true
// 765:         true
// 766:       end
// 767:
// 768:       sig { params(verbose: T::Boolean, force: T::Boolean).returns(T::Boolean) }
// 769:       def upgrade_formula!(verbose:, force:)
// 770:         upgrade_args = []
// 771:         upgrade_args << "--force" if force
// 772:         with_args = " with #{upgrade_args.join(" ")}" if upgrade_args.present?
// 773:         puts "Upgrading #{@name} formula#{with_args}. It is installed but not up-to-date." if verbose
// 774:         unless Bundle.brew("upgrade", "--formula", @name, *upgrade_args, verbose:)
// 775:           @changed = nil
// 776:           return false
// 777:         end
// 778:
// 779:         @changed = true
// 780:         true
// 781:       end
// 782:
// 783:       class Topo < Hash
// 784:         extend T::Generic
// 785:         include TSort
// 786:         include Utils::CycleTolerantTSort
// 787:
// 788:         K = type_member { { fixed: String } }
// 789:         V = type_member { { fixed: T::Array[String] } }
// 790:         Elem = type_member(:out) { { fixed: [String, T::Array[String]] } }
// 791:
// 792:         # TSort interface requires a broader block return type than our implementation.
// 793:         # rubocop:disable Sorbet/AllowIncompatibleOverride
// 794:         sig {
// 795:           override(allow_incompatible: true).params(block: T.proc.params(arg0: String).returns(BasicObject)).void
// 796:         }
// 797:         # rubocop:enable Sorbet/AllowIncompatibleOverride
// 798:         def each_key(&block)
// 799:           keys.each(&block)
// 800:         end
// 801:         alias tsort_each_node each_key
// 802:
// 803:         sig { override.params(node: String, block: T.proc.params(arg0: String).void).void }
// 804:         def tsort_each_child(node, &block)
// 805:           fetch(node, []).sort.each(&block)
// 806:         end
// 807:       end
// 808:     end
// 809:   end
// 810: end
