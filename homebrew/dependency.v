module homebrew

import ruby
import hash.fnv1a
import x.json2

// Translated from Homebrew/brew `dependency.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type DependencyActionBlock = fn(DependencyNode, Dependency) DependencyAction

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

// Ruby attr_reader `attr_reader :name` at line 14.
pub fn ruby_dependency_l14_d1_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(dependable_boundary_receiver(args, 'name').name)
}

// Ruby attr_reader `attr_reader :tap` at line 17.
pub fn ruby_dependency_l17_d2_tap(args ...ruby.Value) ruby.Value {
	dependency := dependable_boundary_receiver(args, 'tap')
	if tap := dependency.tap_name() {
		parts := tap.split('/')
		return ruby.structured_value('Tap', tap, {
			'user': parts[0]
			'repo': parts[1]
		})
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby attr_reader `attr_reader :tags` at line 20.
pub fn ruby_dependency_l20_d3_tags(args ...ruby.Value) ruby.Value {
	dependency := dependable_boundary_receiver(args, 'tags')
	return ruby.string_array_value(dependency.tags.map(it.boundary_string()))
}

// Ruby method `initialize(name, tags = [])` at line 23.
pub fn ruby_dependency_l23_d4_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Dependency#initialize requires a name')
	}
	mut tags := []string{}
	if args.len > 1 {
		tags = if args[1].type_name == 'Array' {
			args[1].as_string_array() or { panic(err) }
		} else {
			tag := if args[1].type_name == 'Symbol' {
				':${args[1].as_string()}'
			} else {
				args[1].as_string()
			}
			[tag]
		}
	}
	return dependency_boundary_value(new_dependency(args[0].as_string(), tags))
}

// Ruby method `==(other)` at line 34.
pub fn ruby_dependency_l34_d5_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'Dependency' {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(dependency_from_boundary(args[0]).equal(dependency_from_boundary(args[1])))
}

// Ruby alias `alias eql? ==` at line 41.
pub fn ruby_dependency_l41_d6_eql(args ...ruby.Value) ruby.Value {
	return ruby_dependency_l34_d5_anonymous(...args)
}

// Ruby method `hash` at line 44.
pub fn ruby_dependency_l44_d7_hash(args ...ruby.Value) ruby.Value {
	return ruby.int_value(i64(dependable_boundary_receiver(args, 'hash').hash_code()))
}

// Ruby method `to_installed_formula` at line 49.
pub fn ruby_dependency_l49_d8_to_installed_formula(args ...ruby.Value) ruby.Value {
	dependency := dependable_boundary_receiver(args, 'to_installed_formula')
	formula := dependency_to_formula(dependency, true, default_formulary_lookup_config()) or {
		panic(err)
	}
	return formula_boundary_value(formula)
}

// Ruby method `to_formula` at line 56.
pub fn ruby_dependency_l56_d9_to_formula(args ...ruby.Value) ruby.Value {
	dependency := dependable_boundary_receiver(args, 'to_formula')
	formula := dependency_to_formula(dependency, false, default_formulary_lookup_config()) or {
		panic(err)
	}
	return formula_boundary_value(formula)
}

// Ruby method `installed?(minimum_version: nil, minimum_revision: nil, minimum_compatibility_version: nil,` at line 70.
pub fn ruby_dependency_l70_d10_installed(args ...ruby.Value) ruby.Value {
	dependency := dependable_boundary_receiver(args, 'installed?')
	return ruby.bool_value(dependency.installed_with_formulary(dependency_minimum_from_boundary_args(args), default_formulary_lookup_config()))
}

// Ruby method `satisfied?(minimum_version: nil, minimum_revision: nil,` at line 127.
pub fn ruby_dependency_l127_d11_satisfied(args ...ruby.Value) ruby.Value {
	dependency := dependable_boundary_receiver(args, 'satisfied?')
	return ruby.bool_value(dependency.satisfied_with_formulary(dependency_minimum_from_boundary_args(args), default_formulary_lookup_config()))
}

// Ruby method `missing_options` at line 134.
pub fn ruby_dependency_l134_d12_missing_options(args ...ruby.Value) ruby.Value {
	dependency := dependable_boundary_receiver(args, 'missing_options')
	options := dependency.missing_options_with_formulary(default_formulary_lookup_config()) or {
		panic(err)
	}
	return formula_options_boundary(options)
}

// Ruby method `option_names` at line 143.
pub fn ruby_dependency_l143_d13_option_names(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(dependable_boundary_receiver(args, 'option_names').option_names())
}

// Ruby method `uses_from_macos?` at line 148.
pub fn ruby_dependency_l148_d14_uses_from_macos(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(dependable_boundary_receiver(args, 'uses_from_macos?').uses_from_macos_dependency())
}

// Ruby method `to_s = name` at line 153.
pub fn ruby_dependency_l153_d15_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(dependable_boundary_receiver(args, 'to_s').str())
}

// Ruby method `inspect` at line 156.
pub fn ruby_dependency_l156_d16_inspect(args ...ruby.Value) ruby.Value {
	return ruby.string_value(dependable_boundary_receiver(args, 'inspect').inspect())
}

// Ruby method `dup_with_formula_name(formula)` at line 161.
pub fn ruby_dependency_l161_d17_dup_with_formula_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Dependency#dup_with_formula_name requires a receiver and formula')
	}
	full_name := args[1].attribute('full_name') or { args[1].as_string() }
	return dependency_boundary_value(dependency_from_boundary(args[0]).duplicate_with_formula_name(full_name))
}

// Ruby attr_reader `attr_reader :expand_stack` at line 167.
pub fn ruby_dependency_l167_d18_expand_stack(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value([]string{})
}

// Ruby method `expand(dependent, deps = dependent.deps, cache_key: nil, cache_timestamp: nil, formula_cache: nil, &block)` at line 188.
pub fn ruby_dependency_l188_d19_expand(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Dependency.expand requires a dependent')
	}
	dependencies := if args.len > 1 {
		dependency_boundary_list([args[1]])
	} else if encoded := args[0].map_data['deps'] {
		dependency_boundary_list([encoded])
	} else if args[0].type_name == 'Formula' {
		formula_from_boundary(args[0]).deps()
	} else {
		[]Dependency{}
	}
	expanded := if args[0].type_name == 'Formula' {
		expand_formula_dependencies(formula_from_boundary(args[0]), dependencies, default_formulary_lookup_config()) or { panic(err) }
	} else {
		expand_dependency_node_dependencies(dependency_node_from_boundary(args[0]), dependencies, default_formulary_lookup_config()) or { panic(err) }
	}
	return dependency_list_boundary_value(expanded)
}

// Ruby method `action(dependent, dep, &block)` at line 245.
pub fn ruby_dependency_l245_d20_action(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Dependency.action requires a dependent and dependency')
	}
	action := default_dependency_action(dependency_node_from_boundary(args[0]), dependency_from_boundary(args[1]))
	if action == .keep {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.object_value('Symbol', action.str())
}

// Ruby method `merge_repeats(all)` at line 254.
pub fn ruby_dependency_l254_d21_merge_repeats(args ...ruby.Value) ruby.Value {
	return dependency_list_boundary_value(merge_repeated_dependencies(dependency_boundary_list(args)))
}

// Ruby method `cache(key, cache_timestamp: nil)` at line 270.
pub fn ruby_dependency_l270_d22_cache(args ...ruby.Value) ruby.Value {
	key := if args.len > 0 { args[0].as_string() } else { '' }
	timestamp := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_string()
	} else {
		''
	}
	cache := new_dependency_expansion_cache().cache(key, timestamp)
	return ruby.object_value('Hash', cache.str())
}

// Ruby method `clear_cache` at line 283.
pub fn ruby_dependency_l283_d23_clear_cache(args ...ruby.Value) ruby.Value {
	mut cache := new_dependency_expansion_cache()
	cache.clear_cache()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `delete_timestamped_cache_entry(key, cache_timestamp)` at line 292.
pub fn ruby_dependency_l292_d24_delete_timestamped_cache_entry(args ...ruby.Value) ruby.Value {
	mut cache := new_dependency_expansion_cache()
	key := if args.len > 0 { args[0].as_string() } else { '' }
	timestamp := if args.len > 1 { args[1].as_string() } else { '' }
	cache.delete_timestamped_cache_entry(key, timestamp)
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `cache_id(dependent)` at line 304.
pub fn ruby_dependency_l304_d25_cache_id(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Dependency.cache_id requires a dependent')
	}
	return ruby.string_value(dependency_cache_id(dependency_node_from_boundary(args[0])))
}

// Ruby method `formula_for_dependency(dep, formula_cache)` at line 309.
pub fn ruby_dependency_l309_d26_formula_for_dependency(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Dependency.formula_for_dependency requires a dependency') }
	formula := dependency_to_formula(dependency_from_boundary(args[0]), false, default_formulary_lookup_config()) or { panic(err) }
	return formula_boundary_value(formula)
}

// Ruby method `merge_tags(deps)` at line 316.
pub fn ruby_dependency_l316_d27_merge_tags(args ...ruby.Value) ruby.Value {
	tags := merge_dependency_tags(dependency_boundary_list(args))
	return ruby.string_array_value(tags.map(it.boundary_string()))
}

// Ruby method `merge_necessity(deps)` at line 323.
pub fn ruby_dependency_l323_d28_merge_necessity(args ...ruby.Value) ruby.Value {
	tags := merge_dependency_necessity(dependency_boundary_list(args))
	return ruby.string_array_value(tags.map(it.boundary_string()))
}

// Ruby method `merge_temporality(deps)` at line 335.
pub fn ruby_dependency_l335_d29_merge_temporality(args ...ruby.Value) ruby.Value {
	tags := merge_dependency_temporality(dependency_boundary_list(args))
	return ruby.string_array_value(tags.map(it.boundary_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependable"
// 5: require "utils"
// 6:
// 7: # A dependency on another Homebrew formula.
// 8: #
// 9: # @api internal
// 10: class Dependency
// 11:   include Dependable
// 12:
// 13:   sig { returns(String) }
// 14:   attr_reader :name
// 15:
// 16:   sig { returns(T.nilable(Tap)) }
// 17:   attr_reader :tap
// 18:
// 19:   sig { override.returns(T::Array[T.any(Symbol, String, T::Array[T.untyped])]) }
// 20:   attr_reader :tags
// 21:
// 22:   sig { params(name: String, tags: T.any(String, Symbol, T::Array[T.untyped], T::Hash[Symbol, T.anything])).void }
// 23:   def initialize(name, tags = [])
// 24:     @name = name
// 25:     @tags = T.let(Array(tags), T::Array[T.any(Symbol, String)])
// 26:     @tap = T.let(nil, T.nilable(Tap))
// 27:
// 28:     return unless (tap_with_name = Tap.with_formula_name(name))
// 29:
// 30:     @tap, = tap_with_name
// 31:   end
// 32:
// 33:   sig { override.params(other: BasicObject).returns(T::Boolean) }
// 34:   def ==(other)
// 35:     case other
// 36:     when Dependency
// 37:       name == other.name && tags == other.tags
// 38:     else false
// 39:     end
// 40:   end
// 41:   alias eql? ==
// 42:
// 43:   sig { override.returns(Integer) }
// 44:   def hash
// 45:     [name, tags].hash
// 46:   end
// 47:
// 48:   sig { returns(Formula) }
// 49:   def to_installed_formula
// 50:     formula = Formulary.resolve(name)
// 51:     formula.build = BuildOptions.new(options, formula.options)
// 52:     formula
// 53:   end
// 54:
// 55:   sig { returns(Formula) }
// 56:   def to_formula
// 57:     formula = Formulary.factory(name, warn: false)
// 58:     formula.build = BuildOptions.new(options, formula.options)
// 59:     formula
// 60:   end
// 61:
// 62:   sig {
// 63:     params(
// 64:       minimum_version:               T.nilable(Version),
// 65:       minimum_revision:              T.nilable(Integer),
// 66:       minimum_compatibility_version: T.nilable(Integer),
// 67:       bottle_os_version:             T.nilable(String),
// 68:     ).returns(T::Boolean)
// 69:   }
// 70:   def installed?(minimum_version: nil, minimum_revision: nil, minimum_compatibility_version: nil,
// 71:                  bottle_os_version: nil)
// 72:     formula = begin
// 73:       to_installed_formula
// 74:     rescue FormulaUnavailableError
// 75:       nil
// 76:     end
// 77:     return false unless formula
// 78:
// 79:     # If the opt prefix doesn't exist: we likely have an incomplete installation.
// 80:     return false unless formula.opt_prefix.exist?
// 81:
// 82:     return true if formula.latest_version_installed?
// 83:
// 84:     return false if minimum_version.blank?
// 85:
// 86:     installed_keg = formula.any_installed_keg
// 87:     return false unless installed_keg
// 88:
// 89:     # If the keg name doesn't match, we may have moved from an alias to a full formula and need to upgrade.
// 90:     return false unless formula.possible_names.include?(installed_keg.name)
// 91:
// 92:     installed_version = installed_keg.version
// 93:
// 94:     # If both the formula and minimum dependency have a compatibility_version set,
// 95:     # and they match, the dependency is satisfied regardless of version/revision.
// 96:     if minimum_compatibility_version.present? && formula.compatibility_version.present?
// 97:       installed_tab = Tab.for_keg(installed_keg)
// 98:       installed_compatibility_version = installed_tab.source.dig("versions", "compatibility_version")
// 99:
// 100:       # If installed version has same compatibility_version as required, it's compatible
// 101:       return true if installed_compatibility_version == minimum_compatibility_version &&
// 102:                      formula.compatibility_version == minimum_compatibility_version
// 103:     end
// 104:
// 105:     # Tabs prior to 4.1.18 did not have revision or pkg_version fields.
// 106:     # As a result, we have to be more conversative when we do not have
// 107:     # a minimum revision from the tab and assume that if the formula has a
// 108:     # the same version and a non-zero revision that it needs upgraded.
// 109:     if minimum_revision.present?
// 110:       minimum_pkg_version = PkgVersion.new(minimum_version, minimum_revision)
// 111:       installed_version >= minimum_pkg_version
// 112:     elsif installed_version.version == minimum_version
// 113:       formula.revision.zero?
// 114:     else
// 115:       installed_version.version > minimum_version
// 116:     end
// 117:   end
// 118:
// 119:   sig {
// 120:     params(
// 121:       minimum_version:               T.nilable(Version),
// 122:       minimum_revision:              T.nilable(Integer),
// 123:       minimum_compatibility_version: T.nilable(Integer),
// 124:       bottle_os_version:             T.nilable(String),
// 125:     ).returns(T::Boolean)
// 126:   }
// 127:   def satisfied?(minimum_version: nil, minimum_revision: nil,
// 128:                  minimum_compatibility_version: nil, bottle_os_version: nil)
// 129:     installed?(minimum_version:, minimum_revision:, minimum_compatibility_version:, bottle_os_version:) &&
// 130:       missing_options.empty?
// 131:   end
// 132:
// 133:   sig { returns(Options) }
// 134:   def missing_options
// 135:     formula = to_installed_formula
// 136:     required = options
// 137:     required &= formula.options.to_a
// 138:     required -= Tab.for_formula(formula).used_options
// 139:     required
// 140:   end
// 141:
// 142:   sig { override.returns(T::Array[String]) }
// 143:   def option_names
// 144:     [Utils.name_from_full_name(name)].freeze
// 145:   end
// 146:
// 147:   sig { overridable.returns(T::Boolean) }
// 148:   def uses_from_macos?
// 149:     false
// 150:   end
// 151:
// 152:   sig { returns(String) }
// 153:   def to_s = name
// 154:
// 155:   sig { returns(String) }
// 156:   def inspect
// 157:     "#<#{self.class.name}: #{name.inspect} #{tags.inspect}>"
// 158:   end
// 159:
// 160:   sig { params(formula: Formula).returns(T.self_type) }
// 161:   def dup_with_formula_name(formula)
// 162:     self.class.new(formula.full_name.to_s, tags)
// 163:   end
// 164:
// 165:   class << self
// 166:     sig { returns(T.nilable(T::Array[T.any(String, Symbol)])) }
// 167:     attr_reader :expand_stack
// 168:
// 169:     # Expand the dependencies of each dependent recursively, optionally yielding
// 170:     # `[dependent, dep]` pairs to allow callers to apply arbitrary filters to
// 171:     # the list.
// 172:     # The default filter, which is applied when a block is not given, omits
// 173:     # optionals and recommends based on what the dependent has asked for
// 174:     #
// 175:     # @api internal
// 176:     T::Sig::WithoutRuntime.sig {
// 177:       params(
// 178:         # CaskDependent may not be initialized yet, so we don't use a runtime sig
// 179:         dependent:       T.any(Formula, CaskDependent),
// 180:         deps:            T::Array[Dependency],
// 181:         cache_key:       T.nilable(String),
// 182:         cache_timestamp: T.nilable(Time),
// 183:         formula_cache:   T.nilable(T::Hash[Dependency, Formula]),
// 184:         block:           T.nilable(T.proc.params(arg0: T.any(Formula, CaskDependent),
// 185:                                                  arg1: Dependency).returns(T.nilable(Symbol))),
// 186:       ).returns(T::Array[Dependency])
// 187:     }
// 188:     def expand(dependent, deps = dependent.deps, cache_key: nil, cache_timestamp: nil, formula_cache: nil, &block)
// 189:       raise ArgumentError, "formula_cache requires cache_key" if formula_cache && cache_key.blank?
// 190:
// 191:       # Keep track dependencies to avoid infinite cyclic dependency recursion.
// 192:       @expand_stack ||= T.let([], T.nilable(T::Array[T.any(String, Symbol)]))
// 193:       @expand_stack.push dependent.name
// 194:
// 195:       begin
// 196:         if cache_key.present? && (entry = cache(cache_key, cache_timestamp:)[cache_id dependent])
// 197:           return entry.dup
// 198:         end
// 199:
// 200:         expanded_deps = []
// 201:
// 202:         deps.each do |dep|
// 203:           next if dependent.name == dep.name
// 204:
// 205:           case action(dependent, dep, &block)
// 206:           when Dependable::PRUNE
// 207:             next
// 208:           when Dependable::SKIP
// 209:             next if @expand_stack.include? dep.name
// 210:
// 211:             expanded_deps.concat(expand(formula_for_dependency(dep, formula_cache),
// 212:                                         cache_key:, cache_timestamp:, formula_cache:,
// 213:                                         &block))
// 214:           when Dependable::KEEP_BUT_PRUNE_RECURSIVE_DEPS
// 215:             expanded_deps << dep
// 216:           else
// 217:             next if @expand_stack.include? dep.name
// 218:
// 219:             dep_formula = formula_for_dependency(dep, formula_cache)
// 220:             expanded_deps.concat(expand(dep_formula, cache_key:, cache_timestamp:, formula_cache:, &block))
// 221:
// 222:             # Fixes names for renamed/aliased formulae.
// 223:             dep = dep.dup_with_formula_name(dep_formula)
// 224:             expanded_deps << dep
// 225:           end
// 226:         end
// 227:
// 228:         expanded_deps = merge_repeats(expanded_deps)
// 229:         cache(cache_key, cache_timestamp:)[cache_id dependent] = expanded_deps.dup if cache_key.present?
// 230:         expanded_deps
// 231:       ensure
// 232:         @expand_stack.pop
// 233:       end
// 234:     end
// 235:
// 236:     # CaskDependent may not be initialized yet, so we don't use a runtime sig
// 237:     T::Sig::WithoutRuntime.sig {
// 238:       params(
// 239:         dependent: T.any(Formula, CaskDependent),
// 240:         dep:       Dependency,
// 241:         block:     T.nilable(T.proc.params(arg0: T.any(Formula, CaskDependent),
// 242:                                            arg1: Dependency).returns(T.nilable(Symbol))),
// 243:       ).returns(T.nilable(Symbol))
// 244:     }
// 245:     def action(dependent, dep, &block)
// 246:       if block
// 247:         yield dependent, dep
// 248:       elsif dep.optional? || dep.recommended?
// 249:         Dependable::PRUNE unless T.cast(dependent, Formula).build.with?(dep)
// 250:       end
// 251:     end
// 252:
// 253:     sig { params(all: T::Array[Dependency]).returns(T::Array[Dependency]) }
// 254:     def merge_repeats(all)
// 255:       grouped = all.group_by(&:name)
// 256:
// 257:       all.map(&:name).uniq.filter_map do |name|
// 258:         deps = grouped.fetch(name)
// 259:         dep  = deps.first
// 260:         next unless dep
// 261:
// 262:         tags = merge_tags(deps)
// 263:         kwargs = {}
// 264:         kwargs[:bounds] = T.cast(dep, UsesFromMacOSDependency).bounds if dep.uses_from_macos?
// 265:         dep.class.new(name, tags, **kwargs)
// 266:       end
// 267:     end
// 268:
// 269:     sig { params(key: T.nilable(String), cache_timestamp: T.nilable(Time)).returns(T::Hash[T.any(String, Symbol), T.untyped]) }
// 270:     def cache(key, cache_timestamp: nil)
// 271:       @cache = T.let(@cache, T.nilable(T::Hash[Symbol, T.untyped]))
// 272:       @cache ||= { timestamped: {}, not_timestamped: {} }
// 273:
// 274:       if cache_timestamp
// 275:         @cache[:timestamped][cache_timestamp] ||= {}
// 276:         @cache[:timestamped][cache_timestamp][key] ||= {}
// 277:       else
// 278:         @cache[:not_timestamped][key] ||= {}
// 279:       end
// 280:     end
// 281:
// 282:     sig { void }
// 283:     def clear_cache
// 284:       return unless @cache
// 285:
// 286:       # No need to clear the timestamped cache as it's timestamped, and doing so causes problems in `expand`.
// 287:       # See https://github.com/Homebrew/brew/pull/20896#issuecomment-3419257460
// 288:       @cache[:not_timestamped].clear
// 289:     end
// 290:
// 291:     sig { params(key: T.nilable(String), cache_timestamp: T.nilable(Time)).void }
// 292:     def delete_timestamped_cache_entry(key, cache_timestamp)
// 293:       return unless @cache
// 294:       return unless (timestamp_entry = @cache[:timestamped][cache_timestamp])
// 295:
// 296:       timestamp_entry.delete(key)
// 297:       @cache[:timestamped].delete(cache_timestamp) if timestamp_entry.empty?
// 298:     end
// 299:
// 300:     private
// 301:
// 302:     # CaskDependent may not be initialized yet, so we don't use a runtime sig
// 303:     T::Sig::WithoutRuntime.sig { params(dependent: T.any(Formula, CaskDependent)).returns(String) }
// 304:     def cache_id(dependent)
// 305:       "#{dependent.full_name}_#{dependent.class}"
// 306:     end
// 307:
// 308:     sig { params(dep: Dependency, formula_cache: T.nilable(T::Hash[Dependency, Formula])).returns(Formula) }
// 309:     def formula_for_dependency(dep, formula_cache)
// 310:       return dep.to_formula unless formula_cache
// 311:
// 312:       formula_cache[dep] ||= dep.to_formula
// 313:     end
// 314:
// 315:     sig { params(deps: T::Array[Dependency]).returns(T::Array[T.any(String, Symbol)]) }
// 316:     def merge_tags(deps)
// 317:       other_tags = T.let(deps.flat_map(&:option_tags).uniq, T::Array[T.any(String, Symbol)])
// 318:       other_tags << :test if deps.flat_map(&:tags).include?(:test)
// 319:       merge_necessity(deps) + merge_temporality(deps) + other_tags
// 320:     end
// 321:
// 322:     sig { params(deps: T::Array[Dependency]).returns(T::Array[Symbol]) }
// 323:     def merge_necessity(deps)
// 324:       # Cannot use `deps.any?(&:required?)` here due to its definition.
// 325:       if deps.any? { |dep| !dep.recommended? && !dep.optional? }
// 326:         [] # Means required dependency.
// 327:       elsif deps.any?(&:recommended?)
// 328:         [:recommended]
// 329:       else # deps.all?(&:optional?)
// 330:         [:optional]
// 331:       end
// 332:     end
// 333:
// 334:     sig { params(deps: T::Array[Dependency]).returns(T::Array[Symbol]) }
// 335:     def merge_temporality(deps)
// 336:       new_tags = []
// 337:       new_tags << :build if deps.all?(&:build?)
// 338:       new_tags << :implicit if deps.all?(&:implicit?)
// 339:       new_tags
// 340:     end
// 341:   end
// 342: end
// 343: require "dependency/uses_from_macos_dependency"
