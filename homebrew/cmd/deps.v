module cmd

import ruby
import net.urllib

pub enum DepsCombineMode {
	intersection
	union
}

pub enum DepsItemKind {
	dependency
	requirement
}

pub enum DepsDependentKind {
	formula
	cask
}

// DepsItem is the command-side projection of Homebrew's Dependency and
// Requirement objects. The predicate fields correspond directly to the Ruby
// methods queried by DependenciesHelpers.
pub struct DepsItem {
pub:
	kind        DepsItemKind
	name        string
	full_name   string
	display_s   string
	tags        []string
	installed   bool
	satisfied   bool
	build       bool
	test        bool
	optional    bool
	recommended bool
	implicit    bool
}

pub struct DepsDependent {
pub:
	kind                     DepsDependentKind
	name                     string
	full_name                string
	deps                     []DepsItem
	requirements             []DepsItem
	runtime_dependencies     []DepsItem
	any_version_installed    bool
	active_spec_head         bool
	has_runtime_dependencies bool
}

pub struct DepsBrewfileEntry {
pub:
	kind      DepsDependentKind
	dependent DepsDependent
}

pub struct DepsCommandOptions {
pub:
	topological          bool
	direct               bool
	union                bool
	full_name            bool
	include_implicit     bool
	include_build        bool
	include_optional     bool
	include_test         bool
	skip_recommended     bool
	include_requirements bool
	tree                 bool
	prune                bool
	graph                bool
	dot                  bool
	annotate             bool
	installed            bool
	missing              bool
	eval_all             bool
	for_each             bool
	head                 bool
	os                   string
	arch                 string
	formula_only         bool
	cask_only            bool
	brewfile             bool
	brewfile_value       string
	tap_trust_configured bool
	no_env_hints         bool
}

pub struct DepsCommand {
pub:
	options            DepsCommandOptions
	named              []DepsDependent
	installed_formulae []DepsDependent
	installed_casks    []DepsDependent
	all_formulae       []DepsDependent
	all_casks          []DepsDependent
	registry           map[string]DepsDependent
pub mut:
	brewfile_entries         []DepsBrewfileEntry
	use_runtime_dependencies bool = true
}

pub struct DepsCommandResult {
pub mut:
	stdout      string
	stderr      string
	browser_url string
	failed      bool
	error       string
}

pub struct DepsGraph {
pub mut:
	nodes []string
	edges map[string][]DepsItem
}

struct DepsTreeState {
mut:
	failed bool
}

fn deps_item_key(item DepsItem) string {
	return '${int(item.kind)}\0${item.name}\0${item.tags.join('\x1f')}\0${item.build}\0${item.test}\0${item.optional}\0${item.recommended}\0${item.implicit}'
}

fn deps_unique_items(items []DepsItem) []DepsItem {
	mut seen := map[string]bool{}
	mut unique := []DepsItem{}
	for item in items {
		key := deps_item_key(item)
		if key in seen {
			continue
		}
		seen[key] = true
		unique << item
	}
	return unique
}

fn deps_unique_strings(values []string) []string {
	mut seen := map[string]bool{}
	mut unique := []string{}
	for value in values {
		if value in seen {
			continue
		}
		seen[value] = true
		unique << value
	}
	return unique
}

fn deps_unique_dependents(dependents []DepsDependent) []DepsDependent {
	mut seen := map[string]bool{}
	mut unique := []DepsDependent{}
	for dependent in dependents {
		key := '${int(dependent.kind)}\0${dependent.full_name}'
		if key in seen {
			continue
		}
		seen[key] = true
		unique << dependent
	}
	return unique
}

fn deps_item_included(item DepsItem, options DepsCommandOptions, at_root bool) bool {
	if options.skip_recommended && item.recommended {
		return false
	}
	if options.missing && item.satisfied {
		return false
	}
	required := !item.build && !item.test && !item.optional && !item.recommended
	return required || item.recommended || (options.include_implicit && item.implicit) || (options.include_build && item.build) || (options.include_test && at_root && item.test) || (options.include_optional && item.optional)
}

fn deps_select_includes(items []DepsItem, options DepsCommandOptions, at_root bool) []DepsItem {
	return items.filter(deps_item_included(it, options, at_root))
}

fn deps_lookup(command DepsCommand, name string) ?DepsDependent {
	if dependent := command.registry[name] {
		return dependent
	}
	for dependent in command.named {
		if dependent.name == name || dependent.full_name == name {
			return dependent
		}
	}
	for dependent in command.all_formulae {
		if dependent.name == name || dependent.full_name == name {
			return dependent
		}
	}
	for dependent in command.all_casks {
		if dependent.name == name || dependent.full_name == name {
			return dependent
		}
	}
	return none
}

fn deps_recursive_items(command DepsCommand, root DepsDependent, kind DepsItemKind) []DepsItem {
	if kind == .requirement {
		return deps_recursive_requirements(command, root)
	}
	mut expanded := []DepsItem{}
	mut visiting := map[string]bool{}
	deps_expand_items(command, root, root.name, mut expanded, mut visiting)
	return deps_merge_repeats(expanded)
}

fn deps_expand_items(command DepsCommand, dependent DepsDependent, root_name string,
	mut expanded []DepsItem, mut visiting map[string]bool) {
	if dependent.name in visiting {
		return
	}
	visiting[dependent.name] = true
	for item in dependent.deps {
		if !deps_item_included(item, command.options, dependent.name == root_name) {
			continue
		}
		if item.kind == .dependency && item.name in visiting {
			continue
		}
		if item.kind == .dependency {
			if child := deps_lookup(command, item.name) {
				deps_expand_items(command, child, root_name, mut expanded, mut visiting)
			}
		}
		expanded << item
	}
	visiting.delete(dependent.name)
}

fn deps_merge_repeats(items []DepsItem) []DepsItem {
	mut names := []string{}
	mut groups := map[string][]DepsItem{}
	for item in items {
		if item.name !in groups {
			names << item.name
		}
		groups[item.name] << item
	}
	mut merged := []DepsItem{}
	for name in names {
		group := groups[name]
		if group.len == 0 {
			continue
		}
		base := group[0]
		is_required := group.any(!it.recommended && !it.optional)
		is_recommended := !is_required && group.any(it.recommended)
		is_optional := !is_required && !is_recommended
		is_build := group.all(it.build)
		is_implicit := group.all(it.implicit)
		is_test := group.any(it.test)
		mut tags := []string{}
		if is_recommended {
			tags << 'recommended'
		} else if is_optional {
			tags << 'optional'
		}
		if is_build {
			tags << 'build'
		}
		if is_implicit {
			tags << 'implicit'
		}
		for item in group {
			for tag in item.tags {
				if tag !in ['build', 'test', 'optional', 'recommended', 'implicit'] && tag !in tags {
					tags << tag
				}
			}
		}
		if is_test {
			tags << 'test'
		}
		merged << DepsItem{
			...base
			tags: tags
			installed: group.any(it.installed)
			satisfied: group.any(it.satisfied)
			build: is_build
			test: is_test
			optional: is_optional
			recommended: is_recommended
			implicit: is_implicit
		}
	}
	return merged
}

fn deps_recursive_requirements(command DepsCommand, root DepsDependent) []DepsItem {
	mut formulae := [root]
	for dependency in deps_recursive_items(command, root, .dependency) {
		if child := deps_lookup(command, dependency.name) {
			formulae << child
		}
	}
	mut requirements := []DepsItem{}
	for formula in formulae {
		for requirement in formula.requirements {
			if deps_item_included(requirement, command.options, formula.name == root.name) {
				requirements << requirement
			}
		}
	}
	return deps_unique_items(requirements)
}

pub fn deps_input_formulae_and_casks(command DepsCommand) []DepsDependent {
	if !command.options.brewfile {
		return deps_unique_dependents(command.named)
	}
	mut inputs := command.named.clone()
	for entry in command.brewfile_entries {
		if entry.kind == .formula && command.options.cask_only {
			continue
		}
		if entry.kind == .cask && command.options.formula_only {
			continue
		}
		inputs << entry.dependent
	}
	return deps_unique_dependents(inputs)
}

pub fn deps_brewfile_path(value ruby.Value) ?string {
	if value.type_name != 'String' || value.as_string() == '' {
		return none
	}
	return value.as_string()
}

pub fn deps_sorted_dependents(formulae_or_casks []DepsDependent) []DepsDependent {
	mut sorted := formulae_or_casks.clone()
	sorted.sort_with_compare(fn (left &DepsDependent, right &DepsDependent) int {
		return left.name.compare(right.name)
	})
	return sorted
}

pub fn deps_condense_requirements(items []DepsItem, options DepsCommandOptions) []DepsItem {
	mut condensed := items.clone()
	if !options.include_requirements {
		condensed = condensed.filter(it.kind == .dependency)
	}
	if options.installed {
		condensed = condensed.filter(it.kind == .requirement || it.installed)
	}
	return condensed
}

pub fn deps_dep_display_name(item DepsItem, options DepsCommandOptions) string {
	mut display := if item.kind == .requirement {
		if options.include_requirements {
			':${if item.display_s == '' { item.name } else { item.display_s }}'
		} else {
			'::${item.name}'
		}
	} else if options.full_name {
		if item.full_name == '' { item.name } else { item.full_name }
	} else {
		item.name
	}
	if options.annotate {
		if options.tree {
			display += ' '
		}
		if item.build {
			display += ' [build]'
		}
		if item.test {
			display += ' [test]'
		}
		if item.optional {
			display += ' [optional]'
		}
		if item.recommended {
			display += ' [recommended]'
		}
		if item.implicit {
			display += ' [implicit]'
		}
	}
	return display
}

pub fn deps_for_dependent(command DepsCommand, dependent DepsDependent,
	recursive bool) []DepsItem {
	mut dependencies := []DepsItem{}
	if command.use_runtime_dependencies {
		dependencies = dependent.runtime_dependencies.clone()
	} else if recursive {
		dependencies = deps_recursive_items(command, dependent, .dependency)
	} else {
		dependencies = deps_select_includes(dependent.deps, command.options, true)
	}
	mut requirements := []DepsItem{}
	if recursive {
		if command.options.include_requirements {
			requirements = deps_recursive_items(command, dependent, .requirement)
		}
	} else {
		requirements = deps_select_includes(dependent.requirements, command.options, true)
	}
	dependencies << requirements
	return dependencies
}

pub fn deps_for_dependents(command DepsCommand, dependents []DepsDependent,
	mode DepsCombineMode, recursive bool) []DepsItem {
	if dependents.len == 0 {
		return []
	}
	mut combined := deps_for_dependent(command, dependents[0], recursive)
	for dependent in dependents[1..] {
		items := deps_for_dependent(command, dependent, recursive)
		if mode == .union {
			combined << items
			combined = deps_unique_items(combined)
		} else {
			keys := items.map(deps_item_key(it))
			combined = combined.filter(deps_item_key(it) in keys)
		}
	}
	return combined
}

fn deps_or_sentence(values []string) string {
	return match values.len {
		0 { '' }
		1 { values[0] }
		2 { '${values[0]} or ${values[1]}' }
		else { '${values[..values.len - 1].join(', ')} or ${values.last()}' }
	}
}

pub fn deps_check_head_spec(dependents []DepsDependent) string {
	headless := dependents.filter(it.kind == .formula && !it.active_spec_head).map(if it.full_name == '' {
		it.name
	} else {
		it.full_name
	})
	if headless.len == 0 {
		return ''
	}
	return 'No head spec for ${deps_or_sentence(headless)}, using stable spec instead'
}

pub fn deps_puts_deps(command DepsCommand, dependents []DepsDependent,
	recursive bool) (string, string) {
	mut output := ''
	mut warning := ''
	if command.options.head {
		warning = deps_check_head_spec(dependents)
	}
	for dependent in dependents {
		mut items := deps_condense_requirements(deps_for_dependent(command, dependent, recursive), command.options)
		items.sort_with_compare(fn (left &DepsItem, right &DepsItem) int {
			return left.name.compare(right.name)
		})
		displays := items.map(deps_dep_display_name(it, command.options))
		full_name := if dependent.full_name == '' { dependent.name } else { dependent.full_name }
		output += '${full_name}: ${displays.join(' ')}\n'
	}
	return output, warning
}

pub fn deps_dependables(command DepsCommand, dependent DepsDependent) []DepsItem {
	base := if command.use_runtime_dependencies {
		dependent.runtime_dependencies
	} else {
		dependent.deps
	}
	mut dependencies := deps_select_includes(base, command.options, true)
	if command.options.include_requirements {
		mut requirements := deps_select_includes(dependent.requirements, command.options, true)
		requirements << dependencies
		dependencies = requirements.clone()
	}
	return dependencies
}

pub fn deps_graph_deps(command DepsCommand, formula DepsDependent, mut graph DepsGraph,
	recursive bool) {
	if formula.name in graph.edges {
		return
	}
	dependables := deps_dependables(command, formula)
	graph.nodes << formula.name
	graph.edges[formula.name] = dependables
	if !recursive {
		return
	}
	for item in dependables {
		if item.kind != .dependency {
			continue
		}
		if child := deps_lookup(command, item.name) {
			deps_graph_deps(command, child, mut graph, true)
		}
	}
}

pub fn deps_dot_code(command DepsCommand, dependents []DepsDependent, recursive bool) string {
	mut graph := DepsGraph{}
	for dependent in dependents {
		deps_graph_deps(command, dependent, mut graph, recursive)
	}
	mut lines := []string{}
	for node in graph.nodes {
		for item in graph.edges[node] {
			mut attributes := []string{}
			if item.build {
				attributes << 'style = dotted'
			}
			if item.test {
				attributes << 'arrowhead = empty'
			}
			if item.optional {
				attributes << 'color = red'
			} else if item.recommended {
				attributes << 'color = green'
			}
			attribute_text := if attributes.len > 0 { ' [${attributes.join(', ')}]' } else { '' }
			comment := if item.tags.len > 0 {
				' # ${item.tags.map(':' + it).join(', ')}'
			} else {
				''
			}
			lines << '  "${node}" -> "${item.name}"${attribute_text}${comment}'
		}
	}
	return 'digraph {\n${lines.join('\n')}\n}'
}

fn deps_recursive_tree(command DepsCommand, formula DepsDependent, mut seen map[string]bool,
	prefix string, recursive bool, mut state DepsTreeState) string {
	dependables := deps_dependables(command, formula)
	mut output := ''
	seen[formula.name] = true
	for index, item in dependables {
		last := index == dependables.len - 1
		branch := if last { '└──' } else { '├──' }
		mut display := '${branch} ${deps_dep_display_name(item, command.options)}'
		circular := seen[item.name] or { false }
		pruned := command.options.prune && item.name in seen
		if circular {
			display += ' (CIRCULAR DEPENDENCY)'
			state.failed = true
		} else if pruned {
			display += ' (PRUNED)'
		}
		output += '${prefix}${display}\n'
		if !recursive || circular || pruned || item.kind != .dependency {
			continue
		}
		if child := deps_lookup(command, item.name) {
			addition := if last { '    ' } else { '│   ' }
			output += deps_recursive_tree(command, child, mut seen, prefix + addition, true, mut state)
		}
	}
	seen[formula.name] = false
	return output
}

pub fn deps_recursive_deps_tree(command DepsCommand, formula DepsDependent,
	mut seen map[string]bool, prefix string, recursive bool) (string, bool) {
	mut state := DepsTreeState{}
	return deps_recursive_tree(command, formula, mut seen, prefix, recursive, mut state), state.failed
}

pub fn deps_puts_deps_tree(command DepsCommand, dependents []DepsDependent,
	recursive bool) (string, string, bool) {
	mut output := ''
	mut failed := false
	mut warning := ''
	if command.options.head {
		warning = deps_check_head_spec(dependents)
	}
	for dependent in dependents {
		full_name := if dependent.full_name == '' { dependent.name } else { dependent.full_name }
		output += '${full_name}\n'
		mut seen := map[string]bool{}
		tree, tree_failed := deps_recursive_deps_tree(command, dependent, mut seen, '', recursive)
		output += '${tree}\n'
		failed = failed || tree_failed
	}
	return output, warning, failed
}

fn deps_installed_inputs(command DepsCommand) []DepsDependent {
	if command.options.formula_only {
		return deps_sorted_dependents(command.installed_formulae)
	}
	if command.options.cask_only {
		return deps_sorted_dependents(command.installed_casks)
	}
	mut installed := command.installed_formulae.clone()
	installed << command.installed_casks
	return deps_sorted_dependents(installed)
}

fn deps_all_inputs(command DepsCommand) []DepsDependent {
	mut available := command.all_formulae.clone()
	available << command.all_casks
	return deps_sorted_dependents(available)
}

fn deps_append_warning(mut result DepsCommandResult, warning string) {
	if warning != '' {
		result.stderr += 'Warning: ${warning}\n'
	}
}

pub fn run_deps_command(mut command DepsCommand) DepsCommandResult {
	mut result := DepsCommandResult{}
	if command.options.os == 'all' {
		result.error = '`brew deps --os=all` is not supported.'
		result.failed = true
		return result
	}
	if command.options.arch == 'all' {
		result.error = '`brew deps --arch=all` is not supported.'
		result.failed = true
		return result
	}
	inputs := deps_input_formulae_and_casks(command)
	mut installed := command.options.installed || inputs.all(it.any_version_installed)
	mut reason := ''
	if !installed {
		reason = if command.options.installed {
			'not all the named formulae were installed'
		} else {
			'`--installed` was not passed'
		}
		command.use_runtime_dependencies = false
	}
	for name in ['direct', 'tree', 'graph', 'HEAD', 'skip_recommended', 'missing', 'include_implicit',
		'include_build', 'include_test', 'include_optional'] {
		enabled := match name {
			'direct' { command.options.direct }
			'tree' { command.options.tree }
			'graph' { command.options.graph }
			'HEAD' { command.options.head }
			'skip_recommended' { command.options.skip_recommended }
			'missing' { command.options.missing }
			'include_implicit' { command.options.include_implicit }
			'include_build' { command.options.include_build }
			'include_test' { command.options.include_test }
			'include_optional' { command.options.include_optional }
			else { false }
		}
		if enabled {
			reason = '--${name.replace('_', '-')}' + ' was passed'
			command.use_runtime_dependencies = false
		}
	}
	for name in ['os', 'arch'] {
		value := if name == 'os' { command.options.os } else { command.options.arch }
		if value != '' {
			reason = '--${name} was passed'
			command.use_runtime_dependencies = false
		}
	}
	if !command.use_runtime_dependencies && !command.options.no_env_hints {
		result.stderr += 'Warning: `brew deps` is not the actual runtime dependencies because ${reason}!\n'
		result.stderr += "This means dependencies may differ from a formula's declared dependencies.\n"
		result.stderr += 'Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).\n'
	}
	recursive := !command.options.direct
	if command.options.tree || command.options.graph {
		dependents := if inputs.len > 0 {
			deps_sorted_dependents(inputs)
		} else if command.options.installed {
			deps_installed_inputs(command)
		} else {
			result.error = 'Formula unspecified'
			result.failed = true
			return result
		}
		if command.options.graph {
			dot := deps_dot_code(command, dependents, recursive)
			if command.options.dot {
				result.stdout = '${dot}\n'
			} else {
				result.browser_url = 'https://dreampuf.github.io/GraphvizOnline/#${urllib.query_escape(dot)}'
			}
			return result
		}
		result.stdout, reason, result.failed = deps_puts_deps_tree(command, dependents, recursive)
		deps_append_warning(mut result, reason)
		return result
	}
	eval_all := command.options.eval_all || (inputs.len == 0 && !command.options.installed && !command.options.brewfile && command.options.tap_trust_configured)
	if eval_all {
		result.stdout, reason = deps_puts_deps(command, deps_all_inputs(command), recursive)
		deps_append_warning(mut result, reason)
		return result
	}
	if inputs.len > 0 && command.options.for_each {
		result.stdout, reason = deps_puts_deps(command, deps_sorted_dependents(inputs), recursive)
		deps_append_warning(mut result, reason)
		return result
	}
	if inputs.len == 0 {
		if !command.options.installed {
			result.error = 'Formula unspecified'
			result.failed = true
			return result
		}
		result.stdout, reason = deps_puts_deps(command, deps_installed_inputs(command), recursive)
		deps_append_warning(mut result, reason)
		return result
	}
	dependents := inputs
	if command.options.head {
		deps_append_warning(mut result, deps_check_head_spec(dependents))
	}
	mode := if command.options.union { DepsCombineMode.union } else { DepsCombineMode.intersection }
	mut all_dependencies := deps_for_dependents(command, dependents, mode, recursive)
	all_dependencies = deps_condense_requirements(all_dependencies, command.options)
	mut names := deps_unique_strings(all_dependencies.map(deps_dep_display_name(it, command.options)))
	if !command.options.topological {
		names.sort()
	}
	if names.len > 0 {
		result.stdout = '${names.join('\n')}\n'
	}
	return result
}

pub fn deps_item_value(item DepsItem) ruby.Value {
	return ruby.structured_value(if item.kind == .requirement {
		'Requirement'
	} else {
		'Dependency'
	}, item.name, {
		'kind':        item.kind.str()
		'name':        item.name
		'full_name':   item.full_name
		'display_s':   item.display_s
		'tags':        item.tags.join('\x1f')
		'installed':   item.installed.str()
		'satisfied':   item.satisfied.str()
		'build':       item.build.str()
		'test':        item.test.str()
		'optional':    item.optional.str()
		'recommended': item.recommended.str()
		'implicit':    item.implicit.str()
	})
}

fn deps_item_from_value(value ruby.Value) DepsItem {
	kind := if value.type_name.contains('Requirement') || value.attributes['kind'] or { '' } == 'requirement' {
		DepsItemKind.requirement
	} else {
		DepsItemKind.dependency
	}
	return DepsItem{
		kind: kind
		name: value.attributes['name'] or { value.repr }
		full_name: value.attributes['full_name'] or { value.repr }
		display_s: value.attributes['display_s'] or { value.repr }
		tags: (value.attributes['tags'] or { '' }).split('\x1f').filter(it != '')
		installed: (value.attributes['installed'] or { 'false' }).bool()
		satisfied: (value.attributes['satisfied'] or { 'false' }).bool()
		build: (value.attributes['build'] or { 'false' }).bool()
		test: (value.attributes['test'] or { 'false' }).bool()
		optional: (value.attributes['optional'] or { 'false' }).bool()
		recommended: (value.attributes['recommended'] or { 'false' }).bool()
		implicit: (value.attributes['implicit'] or { 'false' }).bool()
	}
}

pub fn deps_dependent_value(dependent DepsDependent) ruby.Value {
	return ruby.Value{
		type_name: if dependent.kind == .cask { 'CaskDependent' } else { 'Formula' }
		repr: dependent.full_name
		attributes: {
			'kind':                     dependent.kind.str()
			'name':                     dependent.name
			'full_name':                dependent.full_name
			'any_version_installed':    dependent.any_version_installed.str()
			'active_spec_head':         dependent.active_spec_head.str()
			'has_runtime_dependencies': dependent.has_runtime_dependencies.str()
		}
		map_data: {
			'deps':                 ruby.array_value(dependent.deps.map(deps_item_value(it)))
			'requirements':         ruby.array_value(dependent.requirements.map(deps_item_value(it)))
			'runtime_dependencies': ruby.array_value(dependent.runtime_dependencies.map(deps_item_value(it)))
		}
	}
}

fn deps_dependent_from_value(value ruby.Value) DepsDependent {
	deps_values := (value.map_data['deps'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	requirement_values := (value.map_data['requirements'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	runtime_values := (value.map_data['runtime_dependencies'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	return DepsDependent{
		kind: if value.type_name.contains('Cask') || value.attributes['kind'] or { '' } == 'cask' {
			DepsDependentKind.cask
		} else {
			DepsDependentKind.formula
		}
		name: value.attributes['name'] or { value.repr }
		full_name: value.attributes['full_name'] or { value.repr }
		deps: deps_values.map(deps_item_from_value(it))
		requirements: requirement_values.map(deps_item_from_value(it))
		runtime_dependencies: runtime_values.map(deps_item_from_value(it))
		any_version_installed: (value.attributes['any_version_installed'] or { 'false' }).bool()
		active_spec_head: (value.attributes['active_spec_head'] or { 'false' }).bool()
		has_runtime_dependencies: (value.attributes['has_runtime_dependencies'] or { 'false' }).bool()
	}
}

fn deps_bool(value ruby.Value, name string) bool {
	return if field := value.map_data[name] { field.as_bool() or { false } } else { false }
}

fn deps_string(value ruby.Value, name string) string {
	return if field := value.map_data[name] { field.as_string() } else { '' }
}

fn deps_options_from_value(value ruby.Value) DepsCommandOptions {
	return DepsCommandOptions{
		topological: deps_bool(value, 'topological')
		direct: deps_bool(value, 'direct')
		union: deps_bool(value, 'union')
		full_name: deps_bool(value, 'full_name')
		include_implicit: deps_bool(value, 'include_implicit')
		include_build: deps_bool(value, 'include_build')
		include_optional: deps_bool(value, 'include_optional')
		include_test: deps_bool(value, 'include_test')
		skip_recommended: deps_bool(value, 'skip_recommended')
		include_requirements: deps_bool(value, 'include_requirements')
		tree: deps_bool(value, 'tree')
		prune: deps_bool(value, 'prune')
		graph: deps_bool(value, 'graph')
		dot: deps_bool(value, 'dot')
		annotate: deps_bool(value, 'annotate')
		installed: deps_bool(value, 'installed')
		missing: deps_bool(value, 'missing')
		eval_all: deps_bool(value, 'eval_all')
		for_each: deps_bool(value, 'for_each')
		head: deps_bool(value, 'head')
		os: deps_string(value, 'os')
		arch: deps_string(value, 'arch')
		formula_only: deps_bool(value, 'formula_only')
		cask_only: deps_bool(value, 'cask_only')
		brewfile: deps_bool(value, 'brewfile')
		brewfile_value: deps_string(value, 'brewfile_value')
		tap_trust_configured: deps_bool(value, 'tap_trust_configured')
		no_env_hints: deps_bool(value, 'no_env_hints')
	}
}

fn deps_values(value ruby.Value, name string) []ruby.Value {
	return (value.map_data[name] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
}

fn deps_command_from_value(value ruby.Value) DepsCommand {
	options_value := value.map_data['options'] or { value }
	named := deps_values(value, 'named').map(deps_dependent_from_value(it))
	all_formulae := deps_values(value, 'all_formulae').map(deps_dependent_from_value(it))
	all_casks := deps_values(value, 'all_casks').map(deps_dependent_from_value(it))
	installed_formulae := deps_values(value, 'installed_formulae').map(deps_dependent_from_value(it))
	installed_casks := deps_values(value, 'installed_casks').map(deps_dependent_from_value(it))
	mut registry := map[string]DepsDependent{}
	mut registry_dependents := named.clone()
	registry_dependents << all_formulae
	registry_dependents << all_casks
	registry_dependents << installed_formulae
	registry_dependents << installed_casks
	for dependent in registry_dependents {
		registry[dependent.name] = dependent
	}
	mut brewfile_entries := []DepsBrewfileEntry{}
	for entry_value in deps_values(value, 'brewfile_entries') {
		dependent := deps_dependent_from_value(entry_value)
		brewfile_entries << DepsBrewfileEntry{
			kind: dependent.kind
			dependent: dependent
		}
		registry[dependent.name] = dependent
	}
	return DepsCommand{
		options: deps_options_from_value(options_value)
		named: named
		brewfile_entries: brewfile_entries
		installed_formulae: installed_formulae
		installed_casks: installed_casks
		all_formulae: all_formulae
		all_casks: all_casks
		registry: registry
		use_runtime_dependencies: if field := value.map_data['use_runtime_dependencies'] {
			field.as_bool() or { true }
		} else {
			true
		}
	}
}

fn deps_result_value(result DepsCommandResult) ruby.Value {
	return ruby.structured_value(if result.error == '' {
		'DepsCommandResult'
	} else {
		'UsageError'
	}, if result.error == '' { result.stdout } else { result.error }, {
		'stdout':      result.stdout
		'stderr':      result.stderr
		'browser_url': result.browser_url
		'failed':      result.failed.str()
		'error':       result.error
	})
}

fn deps_items_value(items []DepsItem) ruby.Value {
	return ruby.array_value(items.map(deps_item_value(it)))
}

// Translated from Homebrew/brew `cmd/deps.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(argv = ARGV.freeze)` at line 108.
pub fn ruby_deps_l108_d1_initialize(args ...ruby.Value) ruby.Value {
	argv := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	return ruby.structured_value('Homebrew::Cmd::Deps', argv.str(), {
		'argv':                     argv.join('\x1f')
		'use_runtime_dependencies': 'true'
	})
}

// Ruby method `run` at line 114.
pub fn ruby_deps_l114_d2_run(args ...ruby.Value) ruby.Value {
	mut command := if args.len > 0 { deps_command_from_value(args[0]) } else { DepsCommand{} }
	return deps_result_value(run_deps_command(mut command))
}

// Ruby method `input_formulae_and_casks` at line 234.
pub fn ruby_deps_l234_d3_input_formulae_and_casks(args ...ruby.Value) ruby.Value {
	command := if args.len > 0 { deps_command_from_value(args[0]) } else { DepsCommand{} }
	return ruby.array_value(deps_input_formulae_and_casks(command).map(deps_dependent_value(it)))
}

// Ruby method `brewfile_path(value)` at line 255.
pub fn ruby_deps_l255_d4_brewfile_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', '')
	}
	if path := deps_brewfile_path(args[0]) {
		return ruby.string_value(path)
	}
	return ruby.object_value('NilClass', '')
}

// Ruby method `sorted_dependents(formulae_or_casks)` at line 263.
pub fn ruby_deps_l263_d5_sorted_dependents(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	return ruby.array_value(deps_sorted_dependents(values.map(deps_dependent_from_value(it))).map(deps_dependent_value(it)))
}

// Ruby method `condense_requirements(deps)` at line 268.
pub fn ruby_deps_l268_d6_condense_requirements(args ...ruby.Value) ruby.Value {
	items := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	options := if args.len > 1 { deps_options_from_value(args[1]) } else { DepsCommandOptions{} }
	return deps_items_value(deps_condense_requirements(items.map(deps_item_from_value(it)), options))
}

// Ruby method `dep_display_name(dep)` at line 274.
pub fn ruby_deps_l274_d7_dep_display_name(args ...ruby.Value) ruby.Value {
	item := if args.len > 0 { deps_item_from_value(args[0]) } else { DepsItem{} }
	options := if args.len > 1 { deps_options_from_value(args[1]) } else { DepsCommandOptions{} }
	return ruby.string_value(deps_dep_display_name(item, options))
}

// Ruby method `deps_for_dependent(dependency, recursive: false)` at line 304.
pub fn ruby_deps_l304_d8_deps_for_dependent(args ...ruby.Value) ruby.Value {
	dependent := if args.len > 0 { deps_dependent_from_value(args[0]) } else { DepsDependent{} }
	command := if args.len > 1 { deps_command_from_value(args[1]) } else { DepsCommand{} }
	recursive := args.len > 2 && (args[2].as_bool() or { false })
	return deps_items_value(deps_for_dependent(command, dependent, recursive))
}

// Ruby method `deps_for_dependents(dependents, deps_combine_mode:, recursive:)` at line 327.
pub fn ruby_deps_l327_d9_deps_for_dependents(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	command := if args.len > 1 { deps_command_from_value(args[1]) } else { DepsCommand{} }
	mode := if args.len > 2 && args[2].as_string().to_lower() == 'union' {
		DepsCombineMode.union
	} else {
		DepsCombineMode.intersection
	}
	recursive := args.len > 3 && (args[3].as_bool() or { false })
	return deps_items_value(deps_for_dependents(command, values.map(deps_dependent_from_value(it)), mode, recursive))
}

// Ruby method `check_head_spec(dependents)` at line 333.
pub fn ruby_deps_l333_d10_check_head_spec(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	return ruby.string_value(deps_check_head_spec(values.map(deps_dependent_from_value(it))))
}

// Ruby method `puts_deps(dependents, recursive: false)` at line 340.
pub fn ruby_deps_l340_d11_puts_deps(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	command := if args.len > 1 { deps_command_from_value(args[1]) } else { DepsCommand{} }
	recursive := args.len > 2 && (args[2].as_bool() or { false })
	output, warning := deps_puts_deps(command, values.map(deps_dependent_from_value(it)), recursive)
	return ruby.structured_value('DepsOutput', output, {
		'stdout':  output
		'warning': warning
	})
}

// Ruby method `dot_code(dependents, recursive:)` at line 352.
pub fn ruby_deps_l352_d12_dot_code(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	command := if args.len > 1 { deps_command_from_value(args[1]) } else { DepsCommand{} }
	recursive := args.len > 2 && (args[2].as_bool() or { false })
	return ruby.string_value(deps_dot_code(command, values.map(deps_dependent_from_value(it)), recursive))
}

// Ruby method `graph_deps(formula, dep_graph:, recursive:)` at line 380.
pub fn ruby_deps_l380_d13_graph_deps(args ...ruby.Value) ruby.Value {
	formula := if args.len > 0 { deps_dependent_from_value(args[0]) } else { DepsDependent{} }
	command := if args.len > 1 { deps_command_from_value(args[1]) } else { DepsCommand{} }
	recursive := args.len > 2 && (args[2].as_bool() or { false })
	mut graph := DepsGraph{}
	deps_graph_deps(command, formula, mut graph, recursive)
	mut graph_values := map[string]ruby.Value{}
	for node in graph.nodes {
		graph_values[node] = deps_items_value(graph.edges[node])
	}
	return ruby.map_value(graph_values)
}

// Ruby method `puts_deps_tree(dependents, recursive: false)` at line 397.
pub fn ruby_deps_l397_d14_puts_deps_tree(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	command := if args.len > 1 { deps_command_from_value(args[1]) } else { DepsCommand{} }
	recursive := args.len > 2 && (args[2].as_bool() or { false })
	output, warning, failed := deps_puts_deps_tree(command, values.map(deps_dependent_from_value(it)), recursive)
	return ruby.structured_value('DepsTreeOutput', output, {
		'stdout':  output
		'warning': warning
		'failed':  failed.str()
	})
}

// Ruby method `dependables(formula)` at line 407.
pub fn ruby_deps_l407_d15_dependables(args ...ruby.Value) ruby.Value {
	formula := if args.len > 0 { deps_dependent_from_value(args[0]) } else { DepsDependent{} }
	command := if args.len > 1 { deps_command_from_value(args[1]) } else { DepsCommand{} }
	return deps_items_value(deps_dependables(command, formula))
}

// Ruby method `recursive_deps_tree(formula, deps_seen:, prefix:, recursive:)` at line 423.
pub fn ruby_deps_l423_d16_recursive_deps_tree(args ...ruby.Value) ruby.Value {
	formula := if args.len > 0 { deps_dependent_from_value(args[0]) } else { DepsDependent{} }
	command := if args.len > 1 { deps_command_from_value(args[1]) } else { DepsCommand{} }
	prefix := if args.len > 2 { args[2].as_string() } else { '' }
	recursive := args.len > 3 && (args[3].as_bool() or { false })
	mut seen := map[string]bool{}
	output, failed := deps_recursive_deps_tree(command, formula, mut seen, prefix, recursive)
	return ruby.structured_value('DepsTreeOutput', output, {
		'stdout': output
		'failed': failed.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask/caskroom"
// 7: require "dependencies_helpers"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     class Deps < AbstractCommand
// 12:       include DependenciesHelpers
// 13:
// 14:       class DepsCombineMode < T::Enum
// 15:         enums do
// 16:           # enum values are not mutable, and calling .freeze on them breaks Sorbet
// 17:           # rubocop:disable Style/MutableConstant
// 18:           Intersection = new
// 19:           Union = new
// 20:           # rubocop:enable Style/MutableConstant
// 21:         end
// 22:       end
// 23:
// 24:       cmd_args do
// 25:         description <<~EOS
// 26:           Show dependencies for <formula>. When given multiple formula arguments,
// 27:           show the intersection of dependencies for each formula. By default, `deps`
// 28:           shows all required and recommended dependencies.
// 29:
// 30:           If any version of each formula argument is installed and no other options
// 31:           are passed, this command displays their actual runtime dependencies (similar
// 32:           to `brew linkage`), which may differ from a formula's declared dependencies.
// 33:
// 34:           *Note:* `--missing` and `--skip-recommended` have precedence over `--include-*`.
// 35:         EOS
// 36:         switch "-n", "--topological",
// 37:                description: "Sort dependencies in topological order."
// 38:         switch "-1", "--direct", "--declared", "--1",
// 39:                description: "Show only the direct dependencies declared in the formula."
// 40:         switch "--union",
// 41:                description: "Show the union of dependencies for multiple <formula>, instead of the intersection."
// 42:         switch "--full-name",
// 43:                description: "List dependencies by their full name."
// 44:         switch "--include-implicit",
// 45:                description: "Include implicit dependencies used to download and unpack source files."
// 46:         switch "--include-build",
// 47:                description: "Include `:build` dependencies for <formula>."
// 48:         switch "--include-optional",
// 49:                description: "Include `:optional` dependencies for <formula>."
// 50:         switch "--include-test",
// 51:                description: "Include `:test` dependencies for <formula> (non-recursive unless `--graph` or `--tree`)."
// 52:         switch "--skip-recommended",
// 53:                description: "Skip `:recommended` dependencies for <formula>."
// 54:         switch "--include-requirements",
// 55:                description: "Include requirements in addition to dependencies for <formula>."
// 56:         switch "--tree",
// 57:                description: "Show dependencies as a tree. When given multiple formula arguments, " \
// 58:                             "show individual trees for each formula."
// 59:         switch "--prune",
// 60:                depends_on:  "--tree",
// 61:                description: "Prune parts of tree already seen."
// 62:         switch "--graph",
// 63:                description: "Show dependencies as a directed graph."
// 64:         switch "--dot",
// 65:                depends_on:  "--graph",
// 66:                description: "Show text-based graph description in DOT format."
// 67:         switch "--annotate",
// 68:                description: "Mark any build, test, implicit, optional, or recommended dependencies as " \
// 69:                             "such in the output."
// 70:         switch "--installed",
// 71:                description: "List dependencies for formulae that are currently installed. If <formula> is " \
// 72:                             "specified, list only its dependencies that are currently installed."
// 73:         flag   "--brewfile",
// 74:                description: "Use formulae and casks listed in a Brewfile as inputs. " \
// 75:                             "Defaults to `./Brewfile`; use `--brewfile=`<path> to specify another."
// 76:         switch "--missing",
// 77:                description: "Show only missing dependencies."
// 78:         switch "--eval-all",
// 79:                description: "Evaluate all available formulae and casks, whether installed or not, to list " \
// 80:                             "their dependencies.",
// 81:                env:         :eval_all,
// 82:                odeprecated: true
// 83:         switch "--for-each",
// 84:                description: "Switch into the mode used when evaluating all formulae and casks, but only list " \
// 85:                             "dependencies for each provided <formula>, one formula per line."
// 86:         switch "--HEAD",
// 87:                description: "Show dependencies for HEAD version instead of stable version."
// 88:         flag   "--os=",
// 89:                description: "Show dependencies for the given operating system."
// 90:         flag   "--arch=",
// 91:                description: "Show dependencies for the given CPU architecture."
// 92:         switch "--formula", "--formulae",
// 93:                description: "Treat all named arguments as formulae."
// 94:         switch "--cask", "--casks",
// 95:                description: "Treat all named arguments as casks."
// 96:
// 97:         conflicts "--tree", "--graph"
// 98:         conflicts "--installed", "--missing"
// 99:         conflicts "--installed", "--eval-all"
// 100:         conflicts "--brewfile", "--eval-all"
// 101:         conflicts "--formula", "--cask"
// 102:         formula_options
// 103:
// 104:         named_args [:formula, :cask]
// 105:       end
// 106:
// 107:       sig { override.params(argv: T::Array[String]).void }
// 108:       def initialize(argv = ARGV.freeze)
// 109:         super
// 110:         @use_runtime_dependencies = T.let(true, T::Boolean)
// 111:       end
// 112:
// 113:       sig { override.void }
// 114:       def run
// 115:         raise UsageError, "`brew deps --os=all` is not supported." if args.os == "all"
// 116:         raise UsageError, "`brew deps --arch=all` is not supported." if args.arch == "all"
// 117:
// 118:         os, arch = args.os_arch_combinations.fetch(0)
// 119:         eval_all = args.eval_all?
// 120:         eval_all ||= args.no_named? && !args.installed? && !args.brewfile &&
// 121:                      Homebrew::EnvConfig.tap_trust_configured?
// 122:
// 123:         Formulary.enable_factory_cache!
// 124:
// 125:         SimulateSystem.with(os:, arch:) do
// 126:           inputs = input_formulae_and_casks
// 127:           installed = args.installed? || dependents(inputs).all?(&:any_version_installed?)
// 128:           unless installed
// 129:             not_using_runtime_dependencies_reason = if args.installed?
// 130:               "not all the named formulae were installed"
// 131:             else
// 132:               "`--installed` was not passed"
// 133:             end
// 134:
// 135:             @use_runtime_dependencies = false
// 136:           end
// 137:
// 138:           %w[direct tree graph HEAD skip_recommended missing
// 139:              include_implicit include_build include_test include_optional].each do |arg|
// 140:             next unless args.public_send("#{arg}?")
// 141:
// 142:             not_using_runtime_dependencies_reason = "--#{arg.tr("_", "-")} was passed"
// 143:
// 144:             @use_runtime_dependencies = false
// 145:           end
// 146:
// 147:           %w[os arch].each do |arg|
// 148:             next if args.public_send(arg).nil?
// 149:
// 150:             not_using_runtime_dependencies_reason = "--#{arg.tr("_", "-")} was passed"
// 151:
// 152:             @use_runtime_dependencies = false
// 153:           end
// 154:
// 155:           if !@use_runtime_dependencies && !Homebrew::EnvConfig.no_env_hints?
// 156:             opoo <<~EOS
// 157:               `brew deps` is not the actual runtime dependencies because #{not_using_runtime_dependencies_reason}!
// 158:               This means dependencies may differ from a formula's declared dependencies.
// 159:               Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
// 160:             EOS
// 161:           end
// 162:
// 163:           recursive = !args.direct?
// 164:
// 165:           if args.tree? || args.graph?
// 166:             dependents = if inputs.any?
// 167:               sorted_dependents(inputs)
// 168:             elsif args.installed?
// 169:               case args.only_formula_or_cask
// 170:               when :formula
// 171:                 sorted_dependents(Formula.installed)
// 172:               when :cask
// 173:                 sorted_dependents(Cask::Caskroom.casks)
// 174:               else
// 175:                 sorted_dependents(Formula.installed + Cask::Caskroom.casks)
// 176:               end
// 177:             else
// 178:               raise FormulaUnspecifiedError
// 179:             end
// 180:
// 181:             if args.graph?
// 182:               dot_code = dot_code(dependents, recursive:)
// 183:               if args.dot?
// 184:                 puts dot_code
// 185:               else
// 186:                 exec_browser "https://dreampuf.github.io/GraphvizOnline/##{ERB::Util.url_encode(dot_code)}"
// 187:               end
// 188:               return
// 189:             end
// 190:
// 191:             puts_deps_tree(dependents, recursive:)
// 192:             return
// 193:           elsif eval_all
// 194:             puts_deps(sorted_dependents(
// 195:                         Formula.all(eval_all:) + Cask::Cask.all(eval_all:),
// 196:                       ), recursive:)
// 197:             return
// 198:           elsif inputs.any? && args.for_each?
// 199:             puts_deps(sorted_dependents(inputs), recursive:)
// 200:             return
// 201:           end
// 202:
// 203:           if inputs.empty?
// 204:             raise FormulaUnspecifiedError unless args.installed?
// 205:
// 206:             sorted_dependents_formulae_and_casks = case args.only_formula_or_cask
// 207:             when :formula
// 208:               sorted_dependents(Formula.installed)
// 209:             when :cask
// 210:               sorted_dependents(Cask::Caskroom.casks)
// 211:             else
// 212:               sorted_dependents(Formula.installed + Cask::Caskroom.casks)
// 213:             end
// 214:             puts_deps(sorted_dependents_formulae_and_casks, recursive:)
// 215:             return
// 216:           end
// 217:
// 218:           dependents = dependents(inputs)
// 219:           check_head_spec(dependents) if args.HEAD?
// 220:
// 221:           deps_combine_mode = args.union? ? DepsCombineMode::Union : DepsCombineMode::Intersection
// 222:           all_deps = deps_for_dependents(dependents, deps_combine_mode:, recursive:)
// 223:           condense_requirements(all_deps)
// 224:           all_deps.map! { dep_display_name(it) }
// 225:           all_deps.uniq!
// 226:           all_deps.sort! unless args.topological?
// 227:           puts all_deps
// 228:         end
// 229:       end
// 230:
// 231:       private
// 232:
// 233:       sig { returns(T::Array[T.any(Formula, Keg, Cask::Cask)]) }
// 234:       def input_formulae_and_casks
// 235:         named = args.named.to_formulae_and_casks
// 236:         brewfile = args.brewfile
// 237:         return named unless brewfile
// 238:
// 239:         require "bundle/brewfile"
// 240:         require "cask/cask_loader"
// 241:         only = args.only_formula_or_cask
// 242:         from_brewfile = Homebrew::Bundle::Brewfile.read(file: brewfile_path(brewfile)).entries.filter_map do |e|
// 243:           case e.type
// 244:           when :brew then Formulary.resolve(e.name) if only != :cask
// 245:           when :cask then Cask::CaskLoader.load(e.name) if only != :formula
// 246:           end
// 247:         end
// 248:         (named + from_brewfile).uniq
// 249:       end
// 250:
// 251:       # A bare `--brewfile` (no `=path`) yields `true` from OptionParser at
// 252:       # runtime; the generated RBI types it as `T.nilable(String)`, so accept
// 253:       # the wider type here and normalise `true`/`""` to the `nil` default.
// 254:       sig { params(value: T.nilable(T.any(String, TrueClass))).returns(T.nilable(String)) }
// 255:       def brewfile_path(value)
// 256:         value.presence if value.is_a?(String)
// 257:       end
// 258:
// 259:       sig {
// 260:         params(formulae_or_casks: T::Array[T.any(Formula, Keg, Cask::Cask)])
// 261:           .returns(T::Array[T.any(Formula, CaskDependent)])
// 262:       }
// 263:       def sorted_dependents(formulae_or_casks)
// 264:         dependents(formulae_or_casks).sort_by(&:name)
// 265:       end
// 266:
// 267:       sig { params(deps: T::Array[T.any(Dependency, Requirement)]).void }
// 268:       def condense_requirements(deps)
// 269:         deps.select! { |dep| dep.is_a?(Dependency) } unless args.include_requirements?
// 270:         deps.select! { |dep| dep.is_a?(Requirement) || dep.installed? } if args.installed?
// 271:       end
// 272:
// 273:       sig { params(dep: T.any(Requirement, Dependency)).returns(String) }
// 274:       def dep_display_name(dep)
// 275:         str = if dep.is_a? Requirement
// 276:           if args.include_requirements?
// 277:             ":#{dep.display_s}"
// 278:           else
// 279:             # This shouldn't happen, but we'll put something here to help debugging
// 280:             "::#{dep.name}"
// 281:           end
// 282:         elsif args.full_name?
// 283:           dep.to_formula.full_name
// 284:         else
// 285:           dep.name
// 286:         end
// 287:
// 288:         if args.annotate?
// 289:           str = "#{str} " if args.tree?
// 290:           str = "#{str} [build]" if dep.build?
// 291:           str = "#{str} [test]" if dep.test?
// 292:           str = "#{str} [optional]" if dep.optional?
// 293:           str = "#{str} [recommended]" if dep.recommended?
// 294:           str = "#{str} [implicit]" if dep.implicit?
// 295:         end
// 296:
// 297:         str
// 298:       end
// 299:
// 300:       sig {
// 301:         params(dependency: T.any(Formula, CaskDependent), recursive: T::Boolean)
// 302:           .returns(T::Array[T.any(Dependency, Requirement)])
// 303:       }
// 304:       def deps_for_dependent(dependency, recursive: false)
// 305:         includes, ignores = args_includes_ignores(args)
// 306:
// 307:         deps = dependency.runtime_dependencies if @use_runtime_dependencies
// 308:
// 309:         if recursive
// 310:           deps ||= recursive_dep_includes(dependency, includes, ignores)
// 311:           reqs = args.include_requirements? ? recursive_req_includes(dependency, includes, ignores) : Requirements.new
// 312:         else
// 313:           deps ||= select_includes(dependency.deps, ignores, includes)
// 314:           reqs   = select_includes(dependency.requirements, ignores, includes)
// 315:         end
// 316:
// 317:         deps + reqs.to_a
// 318:       end
// 319:
// 320:       sig {
// 321:         params(
// 322:           dependents:        T::Array[T.any(Formula, CaskDependent)],
// 323:           deps_combine_mode: DepsCombineMode,
// 324:           recursive:         T::Boolean,
// 325:         ).returns(T::Array[T.any(Dependency, Requirement)])
// 326:       }
// 327:       def deps_for_dependents(dependents, deps_combine_mode:, recursive:)
// 328:         symbol = (deps_combine_mode == DepsCombineMode::Intersection) ? :& : :|
// 329:         dependents.map { deps_for_dependent(it, recursive:) }.reduce(symbol)
// 330:       end
// 331:
// 332:       sig { params(dependents: T::Array[T.any(Formula, CaskDependent)]).void }
// 333:       def check_head_spec(dependents)
// 334:         headless = dependents.select { it.is_a?(Formula) && it.active_spec_sym != :head }
// 335:                              .to_sentence two_words_connector: " or ", last_word_connector: " or "
// 336:         opoo "No head spec for #{headless}, using stable spec instead" unless headless.empty?
// 337:       end
// 338:
// 339:       sig { params(dependents: T::Array[T.any(Formula, CaskDependent)], recursive: T::Boolean).void }
// 340:       def puts_deps(dependents, recursive: false)
// 341:         check_head_spec(dependents) if args.HEAD?
// 342:         dependents.each do |dependent|
// 343:           deps = deps_for_dependent(dependent, recursive:)
// 344:           condense_requirements(deps)
// 345:           deps.sort_by!(&:name)
// 346:           deps.map! { dep_display_name(it) }
// 347:           puts "#{dependent.full_name}: #{deps.join(" ")}"
// 348:         end
// 349:       end
// 350:
// 351:       sig { params(dependents: T::Array[T.any(Formula, CaskDependent)], recursive: T::Boolean).returns(String) }
// 352:       def dot_code(dependents, recursive:)
// 353:         dep_graph = {}
// 354:         dependents.each { graph_deps(it, dep_graph:, recursive:) }
// 355:
// 356:         dot_code = dep_graph.map do |d, deps|
// 357:           deps.map do |dep|
// 358:             attributes = []
// 359:             attributes << "style = dotted" if dep.build?
// 360:             attributes << "arrowhead = empty" if dep.test?
// 361:             if dep.optional?
// 362:               attributes << "color = red"
// 363:             elsif dep.recommended?
// 364:               attributes << "color = green"
// 365:             end
// 366:             comment = " # #{dep.tags.map(&:inspect).join(", ")}" if dep.tags.any?
// 367:             "  \"#{d.name}\" -> \"#{dep}\"#{" [#{attributes.join(", ")}]" if attributes.any?}#{comment}"
// 368:           end
// 369:         end.flatten.join("\n")
// 370:         "digraph {\n#{dot_code}\n}"
// 371:       end
// 372:
// 373:       sig {
// 374:         params(
// 375:           formula:   T.any(Formula, CaskDependent),
// 376:           dep_graph: T::Hash[T.any(Formula, CaskDependent), T::Array[T.any(Dependency, Requirement)]],
// 377:           recursive: T::Boolean,
// 378:         ).void
// 379:       }
// 380:       def graph_deps(formula, dep_graph:, recursive:)
// 381:         return if dep_graph.key?(formula)
// 382:
// 383:         dependables = dependables(formula)
// 384:         dep_graph[formula] = dependables
// 385:         return unless recursive
// 386:
// 387:         dependables.each do |dep|
// 388:           next unless dep.is_a? Dependency
// 389:
// 390:           graph_deps(Formulary.factory(dep.name),
// 391:                      dep_graph:,
// 392:                      recursive: true)
// 393:         end
// 394:       end
// 395:
// 396:       sig { params(dependents: T::Array[T.any(Formula, CaskDependent)], recursive: T::Boolean).void }
// 397:       def puts_deps_tree(dependents, recursive: false)
// 398:         check_head_spec(dependents) if args.HEAD?
// 399:         dependents.each do |d|
// 400:           puts d.full_name
// 401:           recursive_deps_tree(d, deps_seen: {}, prefix: "", recursive:)
// 402:           puts
// 403:         end
// 404:       end
// 405:
// 406:       sig { params(formula: T.any(Formula, CaskDependent)).returns(T::Array[T.any(Dependency, Requirement)]) }
// 407:       def dependables(formula)
// 408:         includes, ignores = args_includes_ignores(args)
// 409:         deps = @use_runtime_dependencies ? formula.runtime_dependencies : formula.deps
// 410:         deps = select_includes(deps, ignores, includes)
// 411:         reqs = select_includes(formula.requirements, ignores, includes) if args.include_requirements?
// 412:         reqs ||= []
// 413:         reqs + deps
// 414:       end
// 415:
// 416:       sig {
// 417:         params(
// 418:           formula: T.any(Formula, CaskDependent),
// 419:           deps_seen: T::Hash[String, T::Boolean],
// 420:           prefix: String, recursive: T::Boolean
// 421:         ).void
// 422:       }
// 423:       def recursive_deps_tree(formula, deps_seen:, prefix:, recursive:)
// 424:         dependables = dependables(formula)
// 425:         max = dependables.length - 1
// 426:         deps_seen[formula.name] = true
// 427:         dependables.each_with_index do |dep, i|
// 428:           tree_lines = if i == max
// 429:             "└──"
// 430:           else
// 431:             "├──"
// 432:           end
// 433:
// 434:           display_s = "#{tree_lines} #{dep_display_name(dep)}"
// 435:
// 436:           # Detect circular dependencies and consider them a failure if present.
// 437:           is_circular = deps_seen.fetch(dep.name, false)
// 438:           pruned = args.prune? && deps_seen.include?(dep.name)
// 439:           if is_circular
// 440:             display_s = "#{display_s} (CIRCULAR DEPENDENCY)"
// 441:             Homebrew.failed = true
// 442:           elsif pruned
// 443:             display_s = "#{display_s} (PRUNED)"
// 444:           end
// 445:
// 446:           puts "#{prefix}#{display_s}"
// 447:
// 448:           next if !recursive || is_circular || pruned
// 449:
// 450:           prefix_addition = if i == max
// 451:             "    "
// 452:           else
// 453:             "│   "
// 454:           end
// 455:
// 456:           next unless dep.is_a? Dependency
// 457:
// 458:           recursive_deps_tree(Formulary.factory(dep.name),
// 459:                               deps_seen:,
// 460:                               prefix:    prefix + prefix_addition,
// 461:                               recursive: true)
// 462:         end
// 463:
// 464:         deps_seen[formula.name] = false
// 465:       end
// 466:     end
// 467:   end
// 468: end
