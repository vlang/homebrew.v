module homebrew

import ruby
import hash.fnv1a
import x.json2

// Translated from Homebrew/brew `dependency.rb`.
pub enum DependencyTagKind {
	symbol
	option
}

pub struct DependencyTag {
pub:
	kind  DependencyTagKind
	value string
}

pub fn symbol_dependency_tag(value string) DependencyTag {
	return DependencyTag{
		kind: .symbol
		value: value.trim_string_left(':')
	}
}

pub fn option_dependency_tag(value string) DependencyTag {
	return DependencyTag{
		kind: .option
		value: value
	}
}

pub fn dependency_tag(value string) DependencyTag {
	if value.starts_with(':') {
		return symbol_dependency_tag(value)
	}
	return option_dependency_tag(value)
}

pub fn (tag DependencyTag) boundary_string() string {
	return if tag.kind == .symbol { ':${tag.value}' } else { tag.value }
}

pub fn (tag DependencyTag) inspect() string {
	if tag.kind == .symbol {
		return ':${tag.value}'
	}
	escaped := tag.value.replace('\\', '\\\\').replace('"', '\\"')
	return '"${escaped}"'
}

pub struct Dependency {
pub:
	name            string
	tags            []DependencyTag
	tap             string
	uses_from_macos bool
	macos_bounds    map[string]string
}

pub fn new_dependency(name string, tags []string) Dependency {
	return new_dependency_with_tags(name, tags.map(dependency_tag(it)))
}

pub fn new_dependency_with_tags(name string, tags []DependencyTag) Dependency {
	parts := name.split('/')
	return Dependency{
		name: name
		tags: tags.clone()
		tap: if parts.len >= 3 { '${parts[0]}/${parts[1]}' } else { '' }
	}
}

pub fn new_uses_from_macos_dependency(name string, tags []DependencyTag, bounds map[string]string) Dependency {
	mut dependency := new_dependency_with_tags(name, tags)
	return Dependency{
		...dependency
		uses_from_macos: true
		macos_bounds: bounds.clone()
	}
}

pub fn (dependency Dependency) has_symbol_tag(name string) bool {
	return dependency.tags.any(it.kind == .symbol && it.value == name)
}

pub fn (dependency Dependency) equal(other Dependency) bool {
	if dependency.name != other.name || dependency.uses_from_macos != other.uses_from_macos || dependency.tags.len != other.tags.len {
		return false
	}
	for index, tag in dependency.tags {
		other_tag := other.tags[index]
		if tag.kind != other_tag.kind || tag.value != other_tag.value {
			return false
		}
	}
	return !dependency.uses_from_macos || dependency.macos_bounds == other.macos_bounds
}

fn (dependency Dependency) identity_string() string {
	mut parts := [dependency.name]
	for tag in dependency.tags {
		parts << '${int(tag.kind)}:${tag.value.len}:${tag.value}'
	}
	if dependency.uses_from_macos {
		mut keys := dependency.macos_bounds.keys()
		keys.sort()
		for key in keys {
			parts << '${key}:${dependency.macos_bounds[key]}'
		}
	}
	return parts.join('\x1f')
}

pub fn (dependency Dependency) hash_code() u64 {
	return fnv1a.sum64_string(dependency.identity_string())
}

pub fn (dependency Dependency) tap_name() ?string {
	if dependency.tap == '' {
		return none
	}
	return dependency.tap
}

pub fn (dependency Dependency) str() string {
	return dependency.name
}

pub fn (dependency Dependency) inspect() string {
	tags := dependency.tags.map(it.inspect()).join(', ')
	escaped_name := dependency.name.replace('\\', '\\\\').replace('"', '\\"')
	if dependency.uses_from_macos {
		return '#<UsesFromMacOSDependency: "${escaped_name}" [${tags}] ${dependency.macos_bounds}>'
	}
	return '#<Dependency: "${escaped_name}" [${tags}]>'
}

pub fn (dependency Dependency) uses_from_macos_dependency() bool {
	return dependency.uses_from_macos
}

pub fn (dependency Dependency) duplicate_with_formula_name(full_name string) Dependency {
	if dependency.uses_from_macos {
		return new_uses_from_macos_dependency(full_name, dependency.tags, dependency.macos_bounds)
	}
	return new_dependency_with_tags(full_name, dependency.tags)
}

pub struct DependencyMinimum {
pub:
	has_version               bool
	version                   Version
	has_revision              bool
	revision                  int
	has_compatibility_version bool
	compatibility_version     int
	bottle_os_version         string
}

pub struct DependencyInstallation {
pub:
	formula_available                   bool
	opt_prefix_exists                   bool
	latest_version_installed            bool
	has_installed_keg                   bool
	installed_keg_name                  string
	possible_names                      []string
	installed_version                   PkgVersion
	formula_revision                    int
	has_formula_compatibility_version   bool
	formula_compatibility_version       int
	has_installed_compatibility_version bool
	installed_compatibility_version     int
	formula_options                     Options
	used_options                        Options
}

pub fn (dependency Dependency) installed_from(installation DependencyInstallation, minimum DependencyMinimum) bool {
	if !installation.formula_available || !installation.opt_prefix_exists {
		return false
	}
	if installation.latest_version_installed {
		return true
	}
	if !minimum.has_version || !installation.has_installed_keg || installation.installed_keg_name !in installation.possible_names {
		return false
	}
	if minimum.has_compatibility_version && installation.has_formula_compatibility_version && installation.has_installed_compatibility_version && installation.installed_compatibility_version == minimum.compatibility_version && installation.formula_compatibility_version == minimum.compatibility_version {
		return true
	}
	if minimum.has_revision {
		minimum_pkg_version := new_pkg_version(minimum.version, minimum.revision)
		return installation.installed_version.compare_to(minimum_pkg_version) >= 0
	}
	if installation.installed_version.version.equals(minimum.version) {
		return installation.formula_revision == 0
	}
	return installation.installed_version.version.compare_to(minimum.version) > 0
}

pub fn (dependency Dependency) missing_options_from(installation DependencyInstallation) Options {
	return dependency.options().intersection(installation.formula_options).minus(installation.used_options)
}

pub fn (dependency Dependency) satisfied_from(installation DependencyInstallation, minimum DependencyMinimum) bool {
	return dependency.installed_from(installation, minimum) && dependency.missing_options_from(installation).empty()
}

pub fn dependency_installation_for_formula(formula Formula) DependencyInstallation {
	mut has_installed_keg := false
	mut installed_keg_name := ''
	mut installed_version := new_pkg_version(null_version(), 0)
	mut installed_compatibility_version := 0
	mut has_installed_compatibility_version := false
	if keg := formula.any_installed_keg() {
		has_installed_keg = true
		installed_keg_name = keg.name
		installed_version = keg.version() or { installed_version }
		tab := tab_for_keg(keg.path) or { empty_tab() }
		if compatibility := tab.versions()['compatibility_version'] {
			if compatibility !is json2.Null {
				installed_compatibility_version = compatibility.int()
				has_installed_compatibility_version = true
			}
		}
	}
	installed_tab := tab_for_formula(formula)
	return DependencyInstallation{
		formula_available: true
		opt_prefix_exists: ruby.path_exists(formula.opt_prefix())
		latest_version_installed: formula.latest_version_installed()
		has_installed_keg: has_installed_keg
		installed_keg_name: installed_keg_name
		possible_names: formula.possible_names()
		installed_version: installed_version
		formula_revision: formula.reference.revision
		has_formula_compatibility_version: formula.has_compatibility_version
		formula_compatibility_version: formula.compatibility_version
		has_installed_compatibility_version: has_installed_compatibility_version
		installed_compatibility_version: installed_compatibility_version
		formula_options: formula.options()
		used_options: installed_tab.used_options()
	}
}

pub fn (dependency Dependency) installed_for_formula(formula Formula, minimum DependencyMinimum) bool {
	return dependency.installed_from(dependency_installation_for_formula(formula), minimum)
}

pub fn (dependency Dependency) satisfied_for_formula(formula Formula, minimum DependencyMinimum) bool {
	return dependency.satisfied_from(dependency_installation_for_formula(formula), minimum)
}

pub fn (dependency Dependency) missing_options_for_formula(formula Formula) Options {
	return dependency.missing_options_from(dependency_installation_for_formula(formula))
}

pub fn dependency_to_formula(dependency Dependency, installed bool,
	config FormularyLookupConfig) !Formula {
	mut formula := if installed {
		formulary_resolve(dependency.name, '', false, []string{}, config)!
	} else {
		formulary_factory(dependency.name, '', '', false, []string{}, config)!
	}
	formula.build = new_build_options(dependency.options(), formula.options())
	return formula
}

pub fn (dependency Dependency) installed_with_formulary(minimum DependencyMinimum,
	config FormularyLookupConfig) bool {
	formula := dependency_to_formula(dependency, true, config) or { return false }
	return dependency.installed_for_formula(formula, minimum)
}

pub fn (dependency Dependency) satisfied_with_formulary(minimum DependencyMinimum,
	config FormularyLookupConfig) bool {
	formula := dependency_to_formula(dependency, true, config) or { return false }
	return dependency.satisfied_for_formula(formula, minimum)
}

pub fn (dependency Dependency) missing_options_with_formulary(config FormularyLookupConfig) !Options {
	formula := dependency_to_formula(dependency, true, config)!
	return dependency.missing_options_for_formula(formula)
}

fn collect_formulary_dependency_nodes(dependencies []Dependency, config FormularyLookupConfig,
	mut nodes []DependencyNode, mut visited map[string]bool) ! {
	for dependency in dependencies {
		if dependency.name in visited {
			continue
		}
		visited[dependency.name] = true
		formula := dependency_to_formula(dependency, false, config)!
		nodes << DependencyNode{
			name: formula.name()
			full_name: formula.full_name()
			deps: formula.deps()
			build: formula.build
			lookup_key: dependency.name
		}
		collect_formulary_dependency_nodes(formula.deps(), config, mut nodes, mut visited)!
	}
}

pub fn expand_formula_dependencies(formula Formula, dependencies []Dependency,
	config FormularyLookupConfig) ![]Dependency {
	mut nodes := []DependencyNode{}
	mut visited := map[string]bool{}
	collect_formulary_dependency_nodes(dependencies, config, mut nodes, mut visited)!
	mut expander := new_dependency_expander(nodes)
	root := DependencyNode{
		name: formula.name()
		full_name: formula.full_name()
		deps: dependencies.clone()
		build: formula.build
	}
	return expander.expand(root, dependencies, '', '', false)
}

pub fn expand_dependency_node_dependencies(dependent DependencyNode, dependencies []Dependency,
	config FormularyLookupConfig) ![]Dependency {
	mut nodes := []DependencyNode{}
	mut visited := map[string]bool{}
	collect_formulary_dependency_nodes(dependencies, config, mut nodes, mut visited)!
	mut expander := new_dependency_expander(nodes)
	return expander.expand(dependent, dependencies, '', '', false)
}

pub enum DependencyAction {
	keep
	prune
	skip
	keep_but_prune_recursive_deps
}

pub struct DependencyNode {
pub:
	name       string
	full_name  string
	class_name string = 'Formula'
	deps       []Dependency
	build      BuildOptions
	lookup_key string
}

pub fn new_dependency_node(name string, deps []Dependency, build BuildOptions) DependencyNode {
	return DependencyNode{
		name: name
		full_name: name
		deps: deps.clone()
		build: build
	}
}

pub type DependencyActionBlock = fn (DependencyNode, Dependency) DependencyAction

struct DependencyCacheRecord {
	key          string
	timestamp    string
	cache_id     string
	dependencies []Dependency
}

pub struct DependencyExpansionCache {
mut:
	records []DependencyCacheRecord
}

pub fn new_dependency_expansion_cache() DependencyExpansionCache {
	return DependencyExpansionCache{}
}

pub fn (cache DependencyExpansionCache) entry(key string, timestamp string, cache_id string) ?[]Dependency {
	for record in cache.records {
		if record.key == key && record.timestamp == timestamp && record.cache_id == cache_id {
			return record.dependencies.clone()
		}
	}
	return none
}

pub fn (cache DependencyExpansionCache) cache(key string, timestamp string) map[string][]Dependency {
	mut entries := map[string][]Dependency{}
	for record in cache.records {
		if record.key == key && record.timestamp == timestamp {
			entries[record.cache_id] = record.dependencies.clone()
		}
	}
	return entries
}

pub fn (mut cache DependencyExpansionCache) store(key string, timestamp string, cache_id string, dependencies []Dependency) {
	for index, record in cache.records {
		if record.key == key && record.timestamp == timestamp && record.cache_id == cache_id {
			cache.records[index] = DependencyCacheRecord{
				key: key
				timestamp: timestamp
				cache_id: cache_id
				dependencies: dependencies.clone()
			}
			return
		}
	}
	cache.records << DependencyCacheRecord{
		key: key
		timestamp: timestamp
		cache_id: cache_id
		dependencies: dependencies.clone()
	}
}

pub fn (mut cache DependencyExpansionCache) clear_cache() {
	cache.records = cache.records.filter(it.timestamp != '')
}

pub fn (mut cache DependencyExpansionCache) delete_timestamped_cache_entry(key string, timestamp string) {
	cache.records = cache.records.filter(!(it.key == key && it.timestamp == timestamp))
}

pub struct DependencyExpander {
pub:
	nodes map[string]DependencyNode
mut:
	stack         []string
	cache_state   DependencyExpansionCache
	formula_cache map[string]DependencyNode
}

pub fn new_dependency_expander(nodes []DependencyNode) DependencyExpander {
	mut indexed := map[string]DependencyNode{}
	for node in nodes {
		key := if node.lookup_key != '' { node.lookup_key } else { node.name }
		indexed[key] = node
	}
	return DependencyExpander{
		nodes: indexed
		cache_state: new_dependency_expansion_cache()
		formula_cache: map[string]DependencyNode{}
	}
}

pub fn (expander DependencyExpander) expand_stack() []string {
	return expander.stack.clone()
}

pub fn (mut expander DependencyExpander) clear_cache() {
	expander.cache_state.clear_cache()
}

pub fn (mut expander DependencyExpander) delete_timestamped_cache_entry(key string, timestamp string) {
	expander.cache_state.delete_timestamped_cache_entry(key, timestamp)
}

pub fn (mut expander DependencyExpander) expand(dependent DependencyNode, deps []Dependency,
	cache_key string, cache_timestamp string, use_formula_cache bool) ![]Dependency {
	return expander.expand_internal(dependent, deps, cache_key, cache_timestamp, use_formula_cache, false, default_dependency_action)
}

pub fn (mut expander DependencyExpander) expand_with_action(dependent DependencyNode,
	deps []Dependency, cache_key string, cache_timestamp string, use_formula_cache bool,
	action DependencyActionBlock) ![]Dependency {
	return expander.expand_internal(dependent, deps, cache_key, cache_timestamp, use_formula_cache, true, action)
}

fn default_dependency_action(dependent DependencyNode, dependency Dependency) DependencyAction {
	if (dependency.optional() || dependency.recommended()) && !dependent.build.with_dependable(dependency) {
		return .prune
	}
	return .keep
}

fn (mut expander DependencyExpander) expand_internal(dependent DependencyNode, deps []Dependency,
	cache_key string, cache_timestamp string, use_formula_cache bool, has_action bool,
	action DependencyActionBlock) ![]Dependency {
	if use_formula_cache && cache_key == '' {
		return error('formula_cache requires cache_key')
	}
	expander.stack << dependent.name
	defer {
		expander.stack = expander.stack[..expander.stack.len - 1].clone()
	}
	dependent_cache_id := dependency_cache_id(dependent)
	if cache_key != '' {
		if entry := expander.cache_state.entry(cache_key, cache_timestamp, dependent_cache_id) {
			return entry
		}
	}
	mut expanded := []Dependency{}
	for original_dependency in deps {
		if dependent.name == original_dependency.name {
			continue
		}
		selected_action := if has_action {
			action(dependent, original_dependency)
		} else {
			default_dependency_action(dependent, original_dependency)
		}
		match selected_action {
			.prune {
				continue
			}
			.skip {
				if original_dependency.name in expander.stack {
					continue
				}
				formula := expander.formula_for_dependency(original_dependency, use_formula_cache)!
				expanded << expander.expand_internal(formula, formula.deps, cache_key, cache_timestamp, use_formula_cache, has_action, action)!
			}
			.keep_but_prune_recursive_deps {
				expanded << original_dependency
			}
			.keep {
				if original_dependency.name in expander.stack {
					continue
				}
				formula := expander.formula_for_dependency(original_dependency, use_formula_cache)!
				expanded << expander.expand_internal(formula, formula.deps, cache_key, cache_timestamp, use_formula_cache, has_action, action)!
				expanded << original_dependency.duplicate_with_formula_name(formula.full_name)
			}
		}
	}
	merged := merge_repeated_dependencies(expanded)
	if cache_key != '' {
		expander.cache_state.store(cache_key, cache_timestamp, dependent_cache_id, merged)
	}
	return merged
}

fn (mut expander DependencyExpander) formula_for_dependency(dependency Dependency,
	use_formula_cache bool) !DependencyNode {
	identity := dependency.identity_string()
	if use_formula_cache {
		if formula := expander.formula_cache[identity] {
			return formula
		}
	}
	formula := expander.nodes[identity] or {
		expander.nodes[dependency.name] or {
			return error('Formula unavailable: ${dependency.name}')
		}
	}
	if use_formula_cache {
		expander.formula_cache[identity] = formula
	}
	return formula
}

pub fn dependency_cache_id(dependent DependencyNode) string {
	full_name := if dependent.full_name != '' { dependent.full_name } else { dependent.name }
	return '${full_name}_${dependent.class_name}'
}

pub fn merge_repeated_dependencies(all []Dependency) []Dependency {
	mut grouped := map[string][]Dependency{}
	mut order := []string{}
	for dependency in all {
		if dependency.name !in grouped {
			order << dependency.name
		}
		grouped[dependency.name] << dependency
	}
	mut merged := []Dependency{cap: order.len}
	for name in order {
		dependencies := grouped[name]
		if dependencies.len == 0 {
			continue
		}
		tags := merge_dependency_tags(dependencies)
		first := dependencies[0]
		if first.uses_from_macos {
			merged << new_uses_from_macos_dependency(name, tags, first.macos_bounds)
		} else {
			merged << new_dependency_with_tags(name, tags)
		}
	}
	return merged
}

pub fn merge_dependency_tags(dependencies []Dependency) []DependencyTag {
	mut other_tags := []DependencyTag{}
	for dependency in dependencies {
		for tag in dependency.tags {
			if tag.kind == .option && !other_tags.any(it.kind == tag.kind && it.value == tag.value) {
				other_tags << tag
			}
		}
	}
	if dependencies.any(it.test()) {
		other_tags << symbol_dependency_tag('test')
	}
	mut merged := merge_dependency_necessity(dependencies)
	merged << merge_dependency_temporality(dependencies)
	merged << other_tags
	return merged
}

pub fn merge_dependency_necessity(dependencies []Dependency) []DependencyTag {
	if dependencies.any(!it.recommended() && !it.optional()) {
		return []
	}
	if dependencies.any(it.recommended()) {
		return [symbol_dependency_tag('recommended')]
	}
	return [symbol_dependency_tag('optional')]
}

pub fn merge_dependency_temporality(dependencies []Dependency) []DependencyTag {
	mut tags := []DependencyTag{}
	if dependencies.len > 0 && dependencies.all(it.build()) {
		tags << symbol_dependency_tag('build')
	}
	if dependencies.len > 0 && dependencies.all(it.implicit()) {
		tags << symbol_dependency_tag('implicit')
	}
	return tags
}

fn dependency_boundary_value(dependency Dependency) ruby.Value {
	return ruby.structured_value('Dependency', dependency.inspect(), {
		'name':            dependency.name
		'tags':            dependency.tags.map(it.boundary_string()).join('\x1e')
		'tap':             dependency.tap
		'uses_from_macos': dependency.uses_from_macos.str()
	})
}

fn dependency_from_boundary(value ruby.Value) Dependency {
	if value.type_name != 'Dependency' {
		panic('expected Dependency, got ${value.type_name}')
	}
	name := value.attribute('name') or { value.as_string() }
	tags_text := value.attribute('tags') or { '' }
	tags := if tags_text == '' { []string{} } else { tags_text.split('\x1e') }
	if (value.attribute('uses_from_macos') or { 'false' }) == 'true' {
		return new_uses_from_macos_dependency(name, tags.map(dependency_tag(it)), map[string]string{})
	}
	return new_dependency(name, tags)
}

fn dependable_boundary_receiver(args []ruby.Value, method string) Dependency {
	if args.len == 0 {
		panic('Dependable#${method} requires a receiver')
	}
	return dependency_from_boundary(args[0])
}

fn build_options_from_boundary(value ruby.Value) BuildOptions {
	if value.type_name != 'BuildOptions' {
		panic('expected BuildOptions, got ${value.type_name}')
	}
	argument_text := value.attribute('args') or { '' }
	option_text := value.attribute('options') or { '' }
	arguments := if argument_text == '' { []string{} } else { argument_text.split('\x1e') }
	options := if option_text == '' { []string{} } else { option_text.split('\x1e') }
	return new_build_options(new_options(...arguments), new_options(...options))
}

fn dependency_boundary_list(args []ruby.Value) []Dependency {
	if args.len == 1 && args[0].type_name in ['DependencyArray', 'Array'] {
		return args[0].string_array_data.map(dependency_from_identity_string(it))
	}
	return args.filter(it.type_name == 'Dependency').map(dependency_from_boundary(it))
}

fn dependency_from_identity_string(identity string) Dependency {
	parts := identity.split('\x1f')
	if parts.len == 0 {
		return new_dependency('', []string{})
	}
	mut tags := []DependencyTag{}
	for encoded in parts[1..] {
		first_colon := encoded.index(':') or { continue }
		second_relative := encoded[first_colon + 1..].index(':') or { continue }
		second_colon := first_colon + second_relative + 1
		kind := encoded[..first_colon].int()
		value := encoded[second_colon + 1..]
		tags << if kind == int(DependencyTagKind.symbol) {
			symbol_dependency_tag(value)
		} else {
			option_dependency_tag(value)
		}
	}
	return new_dependency_with_tags(parts[0], tags)
}

fn dependency_list_boundary_value(dependencies []Dependency) ruby.Value {
	return ruby.Value{
		type_name: 'DependencyArray'
		repr: dependencies.map(it.inspect()).str()
		string_array_data: dependencies.map(it.identity_string())
	}
}

fn dependency_node_from_boundary(value ruby.Value) DependencyNode {
	if value.type_name != 'Formula' && value.type_name != 'CaskDependent' && value.type_name != 'DependencyNode' {
		panic('expected Formula, CaskDependent, or DependencyNode, got ${value.type_name}')
	}
	name := value.attribute('name') or { value.as_string() }
	full_name := value.attribute('full_name') or { name }
	class_name := if value.type_name == 'DependencyNode' {
		value.attribute('class_name') or { 'Formula' }
	} else {
		value.type_name
	}
	args := value.attribute('build_args') or { '' }
	options := value.attribute('build_options') or { '' }
	build := build_options_from_boundary(ruby.structured_value('BuildOptions', '', {
		'args':    args
		'options': options
	}))
	return DependencyNode{
		name: name
		full_name: full_name
		class_name: class_name
		build: build
	}
}

fn dependency_minimum_from_boundary_args(args []ruby.Value) DependencyMinimum {
	mut version := null_version()
	mut has_version := false
	if args.len > 1 && args[1].type_name != 'NilClass' {
		version = new_version(args[1].as_string()) or { panic(err) }
		has_version = true
	}
	mut revision := 0
	mut has_revision := false
	if args.len > 2 && args[2].type_name != 'NilClass' {
		revision = int(args[2].as_int() or { panic(err) })
		has_revision = true
	}
	mut compatibility_version := 0
	mut has_compatibility_version := false
	if args.len > 3 && args[3].type_name != 'NilClass' {
		compatibility_version = int(args[3].as_int() or { panic(err) })
		has_compatibility_version = true
	}
	mut bottle_os_version := ''
	if args.len > 4 && args[4].type_name != 'NilClass' {
		bottle_os_version = args[4].as_string()
	}
	return DependencyMinimum{
		has_version: has_version
		version: version
		has_revision: has_revision
		revision: revision
		has_compatibility_version: has_compatibility_version
		compatibility_version: compatibility_version
		bottle_os_version: bottle_os_version
	}
}
