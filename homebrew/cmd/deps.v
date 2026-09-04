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
	return '${int(item.kind)}\x00${item.name}\x00${item.tags.join('\x1f')}\x00${item.build}\x00${item.test}\x00${item.optional}\x00${item.recommended}\x00${item.implicit}'
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
		key := '${int(dependent.kind)}\x00${dependent.full_name}'
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
