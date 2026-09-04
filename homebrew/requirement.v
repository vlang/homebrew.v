module homebrew

import hash.fnv1a
import homebrew.extend as kernel_extension
import homebrew.utils as formatter_utils
import os

// Translated from Homebrew/brew `requirement.rb`.
pub enum RequirementTagKind {
	symbol
	string
	metadata
}

pub struct RequirementTag {
pub:
	kind         RequirementTagKind
	value        string
	cask         string
	download     string
	has_cask     bool
	has_download bool
}

pub fn symbol_requirement_tag(value string) RequirementTag {
	return RequirementTag{
		kind: .symbol
		value: value.trim_string_left(':')
	}
}

pub fn string_requirement_tag(value string) RequirementTag {
	return RequirementTag{
		kind: .string
		value: value
	}
}

pub fn requirement_metadata_tag(cask string, download string) RequirementTag {
	return RequirementTag{
		kind: .metadata
		cask: cask
		download: download
		has_cask: cask != ''
		has_download: download != ''
	}
}

pub fn requirement_metadata(cask ?string, download ?string) RequirementTag {
	cask_value := cask or { '' }
	download_value := download or { '' }
	has_cask := if _ := cask { true } else { false }
	has_download := if _ := download { true } else { false }
	return RequirementTag{
		kind: .metadata
		cask: cask_value
		download: download_value
		has_cask: has_cask
		has_download: has_download
	}
}

pub fn requirement_tag(value string) RequirementTag {
	return if value.starts_with(':') {
		symbol_requirement_tag(value)
	} else {
		string_requirement_tag(value)
	}
}

pub fn (tag RequirementTag) inspect() string {
	return match tag.kind {
		.symbol { ':${tag.value}' }
		.string { '"${tag.value.replace('\\', '\\\\').replace('"', '\\"')}"' }
		.metadata {
			mut members := []string{}
			if tag.has_cask {
				members << ':cask=>"${tag.cask}"'
			}
			if tag.has_download {
				members << ':download=>"${tag.download}"'
			}
			'{${members.join(', ')}}'
		}
	}
}

pub fn (tag RequirementTag) equal(other RequirementTag) bool {
	return tag.kind == other.kind && tag.value == other.value && tag.cask == other.cask && tag.download == other.download && tag.has_cask == other.has_cask && tag.has_download == other.has_download
}

pub enum RequirementResultKind {
	nil_value
	boolean
	pathname
	object
}

pub struct RequirementResult {
pub:
	kind          RequirementResultKind
	boolean       bool
	value         string
	resolved_path string
}

pub fn nil_requirement_result() RequirementResult {
	return RequirementResult{}
}

pub fn bool_requirement_result(value bool) RequirementResult {
	return RequirementResult{
		kind: .boolean
		boolean: value
	}
}

pub fn path_requirement_result(path string) RequirementResult {
	return RequirementResult{
		kind: .pathname
		value: path
		resolved_path: path
	}
}

pub fn resolved_path_requirement_result(path string, resolved_path string) RequirementResult {
	return RequirementResult{
		kind: .pathname
		value: path
		resolved_path: resolved_path
	}
}

pub fn object_requirement_result(value string) RequirementResult {
	return RequirementResult{
		kind: .object
		value: value
	}
}

pub fn (result RequirementResult) truthy() bool {
	return match result.kind {
		.nil_value { false }
		.boolean { result.boolean }
		else { true }
	}
}

pub struct RequirementEvaluationOptions {
pub:
	env          ?string
	cc           ?string
	build_bottle bool
	bottle_arch  ?string
}

pub struct RequirementExecution {
pub mut:
	environment             map[string]string
	prefix                  string
	cellar                  string
	original_paths          []string
	build_environment_calls int
	env_proc_calls          int
	prepended_paths         []string
}

pub type RequirementSatisfyBlock = fn (Requirement) RequirementResult

pub type RequirementEnvProc = fn (mut RequirementExecution)

pub struct RequirementSatisfier {
pub:
	has_fixed_value bool
	fixed_value     RequirementResult
	build_env       bool = true
	has_proc        bool
	proc            ?RequirementSatisfyBlock
}

pub struct RequirementSatisfierInitialization {
pub:
	options_are_hash bool
	has_build_env    bool
	build_env        bool
	fixed_value      RequirementResult
	has_proc         bool
	proc             ?RequirementSatisfyBlock
}

pub struct RequirementClass {
pub mut:
	name                  string
	identity              string
	abstract              bool
	tap_name              string
	has_tap               bool
	cask_name             string
	has_cask              bool
	download_url          string
	has_download          bool
	fatal_value           bool
	has_fatal             bool
	build_value           bool
	has_build             bool
	has_satisfier         bool
	satisfier             RequirementSatisfier
	build_environment     BuildEnvironment
	has_env_proc          bool
	environment_procedure ?RequirementEnvProc
}

pub fn base_requirement_class() RequirementClass {
	return RequirementClass{
		name: 'Requirement'
		identity: 'Requirement'
		abstract: true
		build_environment: new_build_environment()
	}
}

pub fn new_requirement_class(name string) RequirementClass {
	return RequirementClass{
		name: name
		identity: name
		build_environment: new_build_environment()
	}
}

pub fn anonymous_requirement_class(identity string) RequirementClass {
	return RequirementClass{
		identity: identity
		build_environment: new_build_environment()
	}
}

pub struct Requirement {
pub mut:
	class            RequirementClass
	name             string
	cask             string
	has_cask         bool
	download         string
	has_download     bool
	tags             []RequirementTag
	satisfied_result RequirementResult
	has_result       bool
}

pub struct RequirementComparisonTarget {
pub:
	has_requirement bool
	requirement     Requirement
}

pub fn requirement_comparison_target(requirement Requirement) RequirementComparisonTarget {
	return RequirementComparisonTarget{
		has_requirement: true
		requirement: requirement
	}
}

fn requirement_tags_equal(left []RequirementTag, right []RequirementTag) bool {
	if left.len != right.len {
		return false
	}
	for index, tag in left {
		if !tag.equal(right[index]) {
			return false
		}
	}
	return true
}

pub fn requirement_tags_match(left []RequirementTag, right []RequirementTag) bool {
	return requirement_tags_equal(left, right)
}

fn requirement_class_leaf(name string) string {
	parts := name.split('::')
	return if parts.len == 0 { name } else { parts.last() }
}

pub fn requirement_infer_name(class_name string, cask string) string {
	mut leaf := class_name
	for suffix in ['Dependency', 'Requirement'] {
		if leaf.ends_with(suffix) {
			leaf = leaf[..leaf.len - suffix.len]
			break
		}
	}
	for leaf.contains('::') {
		separator := leaf.index('::') or { break }
		prefix := leaf[..separator]
		if prefix == '' || !prefix.bytes().all(it.is_alnum() || it == `_`) {
			break
		}
		leaf = leaf[separator + 2..]
	}
	if leaf != '' {
		return leaf.to_lower()
	}
	return cask
}

pub fn new_requirement(class RequirementClass, tags []RequirementTag) !Requirement {
	if class.abstract {
		return error('Requirement is declared as abstract; it cannot be instantiated')
	}
	mut cask := class.cask_name
	mut has_cask := class.has_cask
	mut download := class.download_url
	mut has_download := class.has_download
	for tag in tags {
		if tag.kind != .metadata {
			continue
		}
		if !has_cask && tag.has_cask {
			cask = tag.cask
			has_cask = true
		}
		if !has_download && tag.has_download {
			download = tag.download
			has_download = true
		}
	}
	mut stored_tags := tags.clone()
	if class.has_build && class.build_value {
		stored_tags << symbol_requirement_tag('build')
	}
	return Requirement{
		class: class
		name: requirement_infer_name(class.name, cask)
		cask: cask
		has_cask: has_cask
		download: download
		has_download: has_download
		tags: stored_tags
	}
}

pub fn (requirement Requirement) option_names() []string {
	return [requirement.name]
}

pub fn (requirement Requirement) message() string {
	class_label := if requirement.class.name != '' {
		requirement.class.name
	} else {
		requirement.class.identity
	}
	class_name := requirement_class_leaf(class_label)
	mut message := '${class_name} unsatisfied!\n'
	if requirement.has_cask {
		message += 'You can install the necessary cask with:\n  brew install --cask ${requirement.cask}\n'
	}
	if requirement.has_download {
		message += 'You can download from:\n  ${formatter_utils.formatter_url(requirement.download, formatter_utils.current_tty_state())}\n'
	}
	return message
}

pub fn (mut requirement Requirement) satisfied(mut execution RequirementExecution,
	options RequirementEvaluationOptions) bool {
	if !requirement.class.has_satisfier {
		return true
	}
	result := requirement.class.satisfier.yielder(requirement, mut execution, options)
	requirement.satisfied_result = result
	requirement.has_result = true
	return result.truthy()
}

pub fn (requirement Requirement) fatal() bool {
	return requirement.class.has_fatal && requirement.class.fatal_value
}

pub fn (requirement Requirement) build() bool {
	return requirement.tags.any(it.kind == .symbol && it.value == 'build')
}

pub fn (requirement Requirement) optional() bool {
	return requirement.tags.any(it.kind == .symbol && it.value == 'optional')
}

pub fn (requirement Requirement) recommended() bool {
	return requirement.tags.any(it.kind == .symbol && it.value == 'recommended')
}

fn normalized_requirement_path(path string) string {
	if path == '' {
		return path
	}
	return os.norm_path(path)
}

pub fn (requirement Requirement) satisfied_result_parent(prefix string, cellar string) ?string {
	if !requirement.has_result || requirement.satisfied_result.kind != .pathname {
		return none
	}
	resolved := if requirement.satisfied_result.resolved_path != '' {
		requirement.satisfied_result.resolved_path
	} else {
		requirement.satisfied_result.value
	}
	mut parent := normalized_requirement_path(os.dir(resolved))
	cellar_prefix := normalized_requirement_path(cellar).trim_string_right(os.path_separator) + os.path_separator
	if parent.starts_with(cellar_prefix) {
		relative := parent[cellar_prefix.len..]
		parts := relative.split(os.path_separator)
		valid_formula_name := parts.len > 0 && parts[0] != '' && parts[0].bytes().all(it.is_alnum() || it in [
			`_`,
			`+`,
			`-`,
			`.`,
			`@`,
		])
		if parts.len == 3 && valid_formula_name && parts[1] != '' && parts[2] in ['bin', 'sbin'] {
			parent = os.join_path(prefix, 'opt', parts[0], parts[2])
		}
	}
	return parent
}

pub fn (mut requirement Requirement) modify_build_environment(mut execution RequirementExecution,
	options RequirementEvaluationOptions) {
	requirement.satisfied(mut execution, options)
	if requirement.class.has_env_proc {
		procedure := requirement.class.environment_procedure or { return }
		procedure(mut execution)
		execution.env_proc_calls++
	}
	parent := requirement.satisfied_result_parent(execution.prefix, execution.cellar) or { return }
	prefix := normalized_requirement_path(execution.prefix)
	if parent in [os.join_path(prefix, 'bin'), os.join_path(prefix, 'sbin')] {
		return
	}
	path := execution.environment['PATH'] or { '' }
	if parent in path.split(':') {
		return
	}
	execution.environment['PATH'] = if path == '' { parent } else { '${parent}:${path}' }
	execution.prepended_paths << parent
}

pub fn (requirement Requirement) env() BuildEnvironment {
	return requirement.class.build_environment
}

pub fn (requirement Requirement) env_proc() ?RequirementEnvProc {
	return requirement.class.environment_procedure
}

pub fn (class RequirementClass) env_proc() ?RequirementEnvProc {
	return class.environment_procedure
}

pub fn (requirement Requirement) equals(other Requirement) bool {
	return requirement.class.identity == other.class.identity && requirement.name == other.name && requirement_tags_equal(requirement.tags, other.tags)
}

pub fn (requirement Requirement) hash_value() u64 {
	mut identity := '${requirement.class.identity}\x00${requirement.name}'
	for tag in requirement.tags {
		identity += '\x00${int(tag.kind)}:${tag.value}:${tag.cask}:${tag.download}:${tag.has_cask}:${tag.has_download}'
	}
	return fnv1a.sum64_string(identity)
}

pub fn (requirement Requirement) inspect() string {
	return '#<${requirement.class.name}: [${requirement.tags.map(it.inspect()).join(', ')}]>'
}

pub fn (requirement Requirement) display_s() string {
	if requirement.name == '' {
		return ''
	}
	return requirement.name[..1].to_upper() + requirement.name[1..].to_lower()
}

pub struct RequirementMktemp {
pub:
	prefix string
	path   string
}

pub type RequirementMktempBlock = fn (RequirementMktemp) !

pub type RequirementMktempRunner = fn (string, RequirementMktempBlock) !

pub fn (requirement Requirement) run_mktemp(runner RequirementMktempRunner,
	block RequirementMktempBlock) ! {
	runner(requirement.name, block)!
}

pub fn requirement_which(command string, paths []string) ?string {
	return kernel_extension.which(command, paths.join(':'))
}

pub fn inherit_requirement_class(name string, identity string) RequirementClass {
	return RequirementClass{
		name: name
		identity: identity
		build_environment: new_build_environment()
	}
}

pub fn (mut class RequirementClass) cask(value ?string) ?string {
	if supplied := value {
		class.cask_name = supplied
		class.has_cask = true
		return supplied
	}
	return if class.has_cask { class.cask_name } else { none }
}

pub fn (mut class RequirementClass) download(value ?string) ?string {
	if supplied := value {
		class.download_url = supplied
		class.has_download = true
		return supplied
	}
	return if class.has_download { class.download_url } else { none }
}

pub fn (mut class RequirementClass) fatal_dsl(value ?bool) ?bool {
	if supplied := value {
		class.fatal_value = supplied
		class.has_fatal = true
		return supplied
	}
	return if class.has_fatal { class.fatal_value } else { none }
}

pub fn new_requirement_satisfier(initialization RequirementSatisfierInitialization) RequirementSatisfier {
	if initialization.options_are_hash {
		return RequirementSatisfier{
			build_env: if initialization.has_build_env { initialization.build_env } else { true }
			has_proc: initialization.has_proc
			proc: initialization.proc
		}
	}
	return RequirementSatisfier{
		has_fixed_value: true
		fixed_value: initialization.fixed_value
		has_proc: initialization.has_proc
		proc: initialization.proc
	}
}

pub fn (mut class RequirementClass) satisfy(initialization ?RequirementSatisfierInitialization) ?RequirementSatisfier {
	if supplied := initialization {
		class.satisfier = new_requirement_satisfier(supplied)
		class.has_satisfier = true
		return class.satisfier
	}
	return if class.has_satisfier { class.satisfier } else { none }
}

pub struct RequirementEnvInvocation {
pub:
	settings []string
	has_proc bool
	proc     ?RequirementEnvProc
}

pub fn (mut class RequirementClass) env_dsl(invocation RequirementEnvInvocation) ?BuildEnvironment {
	if invocation.has_proc {
		class.environment_procedure = invocation.proc
		class.has_env_proc = true
		return none
	}
	class.build_environment.merge(invocation.settings)
	return class.build_environment
}

pub fn (satisfier RequirementSatisfier) yielder(requirement Requirement,
	mut execution RequirementExecution, options RequirementEvaluationOptions) RequirementResult {
	if satisfier.has_fixed_value {
		return satisfier.fixed_value
	}
	if satisfier.build_env {
		execution.build_environment_calls++
	}
	if !satisfier.has_proc {
		return nil_requirement_result()
	}
	procedure := satisfier.proc or { return nil_requirement_result() }
	return procedure(requirement)
}

pub struct RequirementDependent {
pub:
	full_name              string
	class_name             string
	recursive_dependencies []RequirementDependent
	requirements           []Requirement
	build_with             []string
}

pub type RequirementExpandFilter = fn (RequirementDependent, Requirement) string

struct RequirementCacheEntry {
	key          string
	cache_id     string
	requirements []Requirement
}

pub struct RequirementExpansionCache {
mut:
	entries []RequirementCacheEntry
}

pub fn new_requirement_expansion_cache() RequirementExpansionCache {
	return RequirementExpansionCache{}
}

fn (cache RequirementExpansionCache) get(key string, cache_id string) ?[]Requirement {
	for entry in cache.entries {
		if entry.key == key && entry.cache_id == cache_id {
			return entry.requirements.clone()
		}
	}
	return none
}

fn (mut cache RequirementExpansionCache) store(key string, cache_id string,
	requirements []Requirement) {
	for index, entry in cache.entries {
		if entry.key == key && entry.cache_id == cache_id {
			cache.entries[index] = RequirementCacheEntry{
				key: key
				cache_id: cache_id
				requirements: requirements.clone()
			}
			return
		}
	}
	cache.entries << RequirementCacheEntry{
		key: key
		cache_id: cache_id
		requirements: requirements.clone()
	}
}

pub fn requirement_cache_id(dependent RequirementDependent) string {
	return '${dependent.full_name}_${dependent.class_name}'
}

pub fn requirement_prune(dependent RequirementDependent, requirement Requirement,
	filter RequirementExpandFilter, has_filter bool) bool {
	if has_filter {
		return filter(dependent, requirement) == dependable_prune
	}
	if requirement.optional() || requirement.recommended() {
		return requirement.name !in dependent.build_with
	}
	return false
}

pub fn expand_requirements(mut cache RequirementExpansionCache, dependent RequirementDependent,
	cache_key ?string, filter RequirementExpandFilter, has_filter bool) []Requirement {
	if key := cache_key {
		if key != '' {
			if cached := cache.get(key, requirement_cache_id(dependent)) {
				return cached.clone()
			}
		}
	}
	mut requirements := []Requirement{}
	mut formulae := dependent.recursive_dependencies.clone()
	formulae.prepend(dependent)
	for formula in formulae {
		for requirement in formula.requirements {
			if requirement_prune(formula, requirement, filter, has_filter) {
				continue
			}
			requirements << requirement
		}
	}
	if key := cache_key {
		if key != '' {
			cache.store(key, requirement_cache_id(dependent), requirements)
		}
	}
	return requirements
}

// Ruby method `==(other)` at line 163.
pub fn requirement_anonymous(requirement Requirement,
	other RequirementComparisonTarget) bool {
	return other.has_requirement && requirement.equals(other.requirement)
}
