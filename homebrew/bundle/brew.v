module bundle

import ruby

// Translated from Homebrew/brew `bundle/brew.rb`.
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
	bottle                 ruby.Value
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

fn bundle_brew_nil_value() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn bundle_brew_strings_value(values []string) ruby.Value {
	return ruby.array_value(values.map(ruby.string_value(it)))
}

fn bundle_brew_strings_from_value(value ruby.Value) []string {
	return value.as_array() or { return [] }.map(it.as_string())
}

fn bundle_brew_bool(value ruby.Value, fallback bool) bool {
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

fn bundle_brew_string_map_value(values map[string]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

pub fn bundle_brew_formula_value(formula BundleBrewFormula) ruby.Value {
	mut fields := map[string]ruby.Value{}
	fields['name'] = ruby.string_value(formula.name)
	fields['desc'] = ruby.string_value(formula.desc)
	fields['oldnames'] = bundle_brew_strings_value(formula.oldnames)
	fields['full_name'] = ruby.string_value(formula.full_name)
	fields['aliases'] = bundle_brew_strings_value(formula.aliases)
	fields['any_version_installed?'] = ruby.bool_value(formula.any_version_installed)
	fields['args'] = bundle_brew_strings_value(formula.args)
	fields['version'] = if formula.version == '' {
		bundle_brew_nil_value()
	} else {
		ruby.string_value(formula.version)
	}
	fields['installed_on_request?'] = ruby.bool_value(formula.installed_on_request)
	fields['dependencies'] = bundle_brew_strings_value(formula.dependencies)
	fields['recursive_dependencies'] = bundle_brew_strings_value(formula.recursive_dependencies)
	fields['build_dependencies'] = bundle_brew_strings_value(formula.build_dependencies)
	fields['conflicts_with'] = bundle_brew_strings_value(formula.conflicts_with)
	fields['pinned?'] = ruby.bool_value(formula.pinned)
	fields['outdated?'] = ruby.bool_value(formula.outdated)
	fields['link?'] = if formula.link_set {
		ruby.bool_value(formula.link)
	} else {
		bundle_brew_nil_value()
	}
	fields['poured_from_bottle?'] = ruby.bool_value(formula.poured_from_bottle)
	fields['bottle'] = if formula.bottle.type_name == '' {
		ruby.bool_value(false)
	} else {
		formula.bottle
	}
	fields['bottled'] = ruby.bool_value(formula.bottled)
	fields['official_tap'] = ruby.bool_value(formula.official_tap)
	fields['linked?'] = ruby.bool_value(formula.linked)
	fields['keg_only?'] = ruby.bool_value(formula.keg_only)
	return ruby.Value{
		type_name: 'Homebrew::Bundle::Brew::Formula'
		repr: formula.full_name
		map_data: fields
		attributes: {
			'name':      formula.name
			'full_name': formula.full_name
		}
	}
}

pub fn bundle_brew_formula_from_value(value ruby.Value) BundleBrewFormula {
	fields := value.map_data.clone()
	link_value := fields['link?'] or { bundle_brew_nil_value() }
	return BundleBrewFormula{
		name: (fields['name'] or { ruby.string_value(value.attributes['name'] or { bundle_brew_name_from_full_name(value.repr) }) }).as_string()
		desc: (fields['desc'] or { ruby.string_value('') }).as_string()
		oldnames: bundle_brew_strings_from_value(fields['oldnames'] or { bundle_brew_strings_value([]) })
		full_name: (fields['full_name'] or { ruby.string_value(value.attributes['full_name'] or { value.repr }) }).as_string()
		aliases: bundle_brew_strings_from_value(fields['aliases'] or { bundle_brew_strings_value([]) })
		any_version_installed: bundle_brew_bool(fields['any_version_installed?'] or { ruby.bool_value(false) }, false)
		args: bundle_brew_strings_from_value(fields['args'] or { bundle_brew_strings_value([]) })
		version: if (fields['version'] or { bundle_brew_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''
		} else {
			(fields['version'] or { bundle_brew_nil_value() }).as_string()
		}
		installed_on_request: bundle_brew_bool(fields['installed_on_request?'] or { ruby.bool_value(true) }, true)
		dependencies: bundle_brew_strings_from_value(fields['dependencies'] or { bundle_brew_strings_value([]) })
		recursive_dependencies: bundle_brew_strings_from_value(fields['recursive_dependencies'] or { bundle_brew_strings_value([]) })
		build_dependencies: bundle_brew_strings_from_value(fields['build_dependencies'] or { bundle_brew_strings_value([]) })
		conflicts_with: bundle_brew_strings_from_value(fields['conflicts_with'] or { bundle_brew_strings_value([]) })
		pinned: bundle_brew_bool(fields['pinned?'] or { ruby.bool_value(false) }, false)
		outdated: bundle_brew_bool(fields['outdated?'] or { ruby.bool_value(false) }, false)
		link_set: link_value.type_name !in ['Nil', 'NilClass', '']
		link: bundle_brew_bool(link_value, false)
		poured_from_bottle: bundle_brew_bool(fields['poured_from_bottle?'] or { ruby.bool_value(false) }, false)
		bottle: fields['bottle'] or { ruby.bool_value(false) }
		bottled: bundle_brew_bool(fields['bottled'] or { ruby.bool_value(false) }, false)
		official_tap: bundle_brew_bool(fields['official_tap'] or { ruby.bool_value(false) }, false)
		linked: bundle_brew_bool(fields['linked?'] or { ruby.bool_value(false) }, false)
		keg_only: bundle_brew_bool(fields['keg_only?'] or { ruby.bool_value(false) }, false)
	}
}

pub fn bundle_brew_options_value(options BundleBrewOptions) ruby.Value {
	return ruby.map_value({
		'args':            bundle_brew_strings_value(options.args)
		'conflicts_with':  bundle_brew_strings_value(options.conflicts_with)
		'restart_service': if options.restart_service == '' {
			bundle_brew_nil_value()
		} else {
			ruby.string_value(options.restart_service)
		}
		'start_service':   if options.start_service == '' {
			bundle_brew_nil_value()
		} else {
			ruby.string_value(options.start_service)
		}
		'link':            if options.link_mode == '' {
			bundle_brew_nil_value()
		} else if options.link_mode == 'true' {
			ruby.bool_value(true)
		} else if options.link_mode == 'false' {
			ruby.bool_value(false)
		} else {
			ruby.string_value(options.link_mode)
		}
		'postinstall':     if options.postinstall == '' {
			bundle_brew_nil_value()
		} else {
			ruby.string_value(options.postinstall)
		}
		'version_file':    if options.version_file == '' {
			bundle_brew_nil_value()
		} else {
			ruby.string_value(options.version_file)
		}
		'trusted':         ruby.bool_value(options.trusted)
	})
}

pub fn bundle_brew_options_from_value(value ruby.Value) BundleBrewOptions {
	fields := value.map_data.clone()
	restart_value := fields['restart_service'] or { bundle_brew_nil_value() }
	start_value := fields['start_service'] or { restart_value }
	link_value := fields['link'] or { bundle_brew_nil_value() }
	return BundleBrewOptions{
		args: bundle_brew_strings_from_value(fields['args'] or { bundle_brew_strings_value([]) })
		conflicts_with: bundle_brew_strings_from_value(fields['conflicts_with'] or { bundle_brew_strings_value([]) })
		restart_service: if restart_value.type_name in ['Nil', 'NilClass', ''] {
			''
		} else {
			restart_value.as_string()
		}
		start_service: if start_value.type_name in ['Nil', 'NilClass', ''] {
			''
		} else {
			start_value.as_string()
		}
		link_mode: if link_value.type_name in ['Nil', 'NilClass', ''] {
			''
		} else if link_value.type_name == 'Bool' {
			link_value.bool_data.str()
		} else {
			link_value.as_string()
		}
		postinstall: if (fields['postinstall'] or { bundle_brew_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''
		} else {
			(fields['postinstall'] or { bundle_brew_nil_value() }).as_string()
		}
		version_file: if (fields['version_file'] or { bundle_brew_nil_value() }).type_name in [
			'Nil',
			'NilClass',
		] {
			''
		} else {
			(fields['version_file'] or { bundle_brew_nil_value() }).as_string()
		}
		trusted: bundle_brew_bool(fields['trusted'] or { ruby.bool_value(false) }, false)
	}
}

pub fn bundle_brew_state_value(state BundleBrewState) ruby.Value {
	return ruby.Value{
		type_name: 'Homebrew::Bundle::Brew::State'
		array_data: state.formulae.map(bundle_brew_formula_value(it))
		map_data: {
			'installed_formulae': bundle_brew_strings_value(state.installed_formulae)
			'upgrade_formulae':   bundle_brew_strings_value(state.upgrade_formulae)
			'trusted_formulae':   bundle_brew_strings_value(state.trusted_formulae)
			'require_tap_trust':  ruby.bool_value(state.require_tap_trust)
			'unavailable':        bundle_brew_strings_value(state.unavailable)
			'started_services':   bundle_brew_strings_value(state.started_services)
		}
	}
}

pub fn bundle_brew_state_from_value(value ruby.Value) BundleBrewState {
	fields := value.map_data.clone()
	return BundleBrewState{
		formulae: value.array_data.map(bundle_brew_formula_from_value(it))
		installed_formulae: bundle_brew_strings_from_value(fields['installed_formulae'] or { bundle_brew_strings_value([]) })
		upgrade_formulae: bundle_brew_strings_from_value(fields['upgrade_formulae'] or { bundle_brew_strings_value([]) })
		trusted_formulae: bundle_brew_strings_from_value(fields['trusted_formulae'] or { bundle_brew_strings_value([]) })
		require_tap_trust: bundle_brew_bool(fields['require_tap_trust'] or { ruby.bool_value(false) }, false)
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
				options.start_service
			} else {
				options.restart_service
			}
			link_mode: options.link_mode
			postinstall: options.postinstall
			version_file: options.version_file
			trusted: options.trusted
		}
	}
}

pub fn bundle_brew_installer_value(installer BundleBrewInstaller) ruby.Value {
	return ruby.Value{
		type_name: 'Homebrew::Bundle::Brew'
		repr: installer.full_name
		map_data: {
			'options':                bundle_brew_options_value(installer.options)
			'changed':                ruby.bool_value(installer.changed)
			'installed':              ruby.bool_value(installer.installed)
			'linked':                 ruby.bool_value(installer.linked)
			'keg_only':               ruby.bool_value(installer.keg_only)
			'upgradable':             ruby.bool_value(installer.upgradable)
			'formula_conflicts':      bundle_brew_strings_value(installer.formula_conflicts)
			'service_started':        ruby.bool_value(installer.service_started)
			'versioned_service_file': ruby.string_value(installer.versioned_service_file)
			'env_version':            ruby.string_value(installer.env_version)
			'formula_version':        ruby.string_value(installer.formula_version)
		}
		attributes: {
			'name':      installer.name
			'full_name': installer.full_name
		}
	}
}

pub fn bundle_brew_installer_from_value(value ruby.Value) BundleBrewInstaller {
	fields := value.map_data.clone()
	return BundleBrewInstaller{
		full_name: value.attributes['full_name'] or { value.repr }
		name: value.attributes['name'] or { bundle_brew_name_from_full_name(value.repr) }
		options: bundle_brew_options_from_value(fields['options'] or { ruby.map_value({}) })
		changed: bundle_brew_bool(fields['changed'] or { ruby.bool_value(false) }, false)
		installed: bundle_brew_bool(fields['installed'] or { ruby.bool_value(false) }, false)
		linked: bundle_brew_bool(fields['linked'] or { ruby.bool_value(false) }, false)
		keg_only: bundle_brew_bool(fields['keg_only'] or { ruby.bool_value(false) }, false)
		upgradable: bundle_brew_bool(fields['upgradable'] or { ruby.bool_value(false) }, false)
		formula_conflicts: bundle_brew_strings_from_value(fields['formula_conflicts'] or { bundle_brew_strings_value([]) })
		service_started: bundle_brew_bool(fields['service_started'] or { ruby.bool_value(false) }, false)
		versioned_service_file: (fields['versioned_service_file'] or { ruby.string_value('') }).as_string()
		env_version: (fields['env_version'] or { ruby.string_value('') }).as_string()
		formula_version: (fields['formula_version'] or { ruby.string_value('') }).as_string()
	}
}

fn bundle_brew_formula_map_value(formulae []BundleBrewFormula, full_name bool) ruby.Value {
	mut result := map[string]ruby.Value{}
	for formula in formulae {
		result[if full_name { formula.full_name } else { formula.name }] = bundle_brew_formula_value(formula)
	}
	return ruby.map_value(result)
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
			]
		} else {
			[]
		}
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

fn bundle_brew_effects_from_value(value ruby.Value) BundleBrewEffects {
	mut command_results := map[string]bool{}
	for key, item in (value.map_data['command_results'] or { ruby.map_value({}) }).map_data {
		command_results[key] = bundle_brew_bool(item, true)
	}
	mut stop_results := map[string]bool{}
	for key, item in (value.map_data['service_stop_results'] or { ruby.map_value({}) }).map_data {
		stop_results[key] = bundle_brew_bool(item, true)
	}
	return BundleBrewEffects{
		command_results: command_results
		postinstall_ok: bundle_brew_bool(value.map_data['postinstall_ok'] or { ruby.bool_value(true) }, true)
		service_start_ok: bundle_brew_bool(value.map_data['service_start_ok'] or { ruby.bool_value(true) }, true)
		service_restart_ok: bundle_brew_bool(value.map_data['service_restart_ok'] or { ruby.bool_value(true) }, true)
		service_stop_results: stop_results
	}
}

pub fn bundle_brew_action_value(result BundleBrewActionResult) ruby.Value {
	return ruby.Value{
		type_name: 'Homebrew::Bundle::Brew::ActionResult'
		repr: result.success.str()
		bool_data: result.success
		array_data: result.commands.map(bundle_brew_strings_value(it))
		map_data: {
			'events':  bundle_brew_strings_value(result.events)
			'output':  bundle_brew_strings_value(result.output)
			'writes':  bundle_brew_string_map_value(result.writes)
			'changed': ruby.bool_value(result.changed)
		}
	}
}
