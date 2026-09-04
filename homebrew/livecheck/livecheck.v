module livecheck

import ruby
import net.urllib
import os
import time

// Translated from Homebrew/brew `livecheck/livecheck.rb`.
// The original source is retained below until every stub has a typed V body.
const unstable_version_keywords = ['alpha', 'beta', 'bpo', 'dev', 'experimental', 'prerelease',
	'preview', 'rc']

pub struct LivecheckPackage {
pub mut:
	kind                    string
	name                    string
	full_name               string
	version                 string
	head_only               bool
	installed_head_commit   string
	latest_head_commit      string
	owner_name              string
	owner_full_name         string
	stable_url              string
	head_url                string
	homepage                string
	url                     string
	mirrors                 []string
	stable_using            string
	head_using              string
	url_using               string
	livecheck_defined       bool
	livecheck_url           ruby.Value
	livecheck_formula       string
	livecheck_cask          string
	livecheck_regex         string
	livecheck_strategy      string
	livecheck_parameters    []string
	livecheck_matches       map[string]string
	livecheck_messages      []string
	livecheck_throttle      int
	livecheck_throttle_days int
	resources               []LivecheckPackage
	tap_name                string
	tap_path                string
	tap_git                 bool
	tap_core                bool
	tap_core_cask           bool
	sourcefile_path         string
	last_updated_timestamp  ?i64
	origin_version          string
	revisions               []LivecheckRevision
}

pub struct LivecheckRevision {
pub:
	revision  string
	version   string
	timestamp i64
}

pub struct LivecheckReferenceResult {
pub:
	has_package bool
	package     LivecheckPackage
	references  []LivecheckPackage
}

fn livecheck_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn livecheck_error(kind string, message string) ruby.Value {
	return ruby.object_value(kind, message)
}

fn livecheck_strings(value ruby.Value) []string {
	if value.type_name == 'NilClass' || value.type_name == '' {
		return []string{}
	}
	return value.as_string_array() or { []string{} }
}

pub fn livecheck_package_value(package LivecheckPackage) ruby.Value {
	mut matches := map[string]ruby.Value{}
	for key, value in package.livecheck_matches {
		matches[key] = ruby.string_value(value)
	}
	mut values := {
		'kind':                    ruby.string_value(package.kind)
		'name':                    ruby.string_value(package.name)
		'full_name':               ruby.string_value(package.full_name)
		'version':                 ruby.string_value(package.version)
		'head_only':               ruby.bool_value(package.head_only)
		'installed_head_commit':   ruby.string_value(package.installed_head_commit)
		'latest_head_commit':      ruby.string_value(package.latest_head_commit)
		'owner_name':              ruby.string_value(package.owner_name)
		'owner_full_name':         ruby.string_value(package.owner_full_name)
		'stable_url':              ruby.string_value(package.stable_url)
		'head_url':                ruby.string_value(package.head_url)
		'homepage':                ruby.string_value(package.homepage)
		'url':                     ruby.string_value(package.url)
		'mirrors':                 ruby.string_array_value(package.mirrors)
		'stable_using':            ruby.string_value(package.stable_using)
		'head_using':              ruby.string_value(package.head_using)
		'url_using':               ruby.string_value(package.url_using)
		'livecheck_defined':       ruby.bool_value(package.livecheck_defined)
		'livecheck_url':           package.livecheck_url
		'livecheck_formula':       ruby.string_value(package.livecheck_formula)
		'livecheck_cask':          ruby.string_value(package.livecheck_cask)
		'livecheck_regex':         ruby.string_value(package.livecheck_regex)
		'livecheck_strategy':      ruby.string_value(package.livecheck_strategy)
		'livecheck_parameters':    ruby.string_array_value(package.livecheck_parameters)
		'livecheck_matches':       ruby.map_value(matches)
		'livecheck_messages':      ruby.string_array_value(package.livecheck_messages)
		'livecheck_throttle':      ruby.int_value(package.livecheck_throttle)
		'livecheck_throttle_days': ruby.int_value(package.livecheck_throttle_days)
		'resources':               ruby.array_value(package.resources.map(livecheck_package_value(it)))
		'tap_name':                ruby.string_value(package.tap_name)
		'tap_path':                ruby.string_value(package.tap_path)
		'tap_git':                 ruby.bool_value(package.tap_git)
		'tap_core':                ruby.bool_value(package.tap_core)
		'tap_core_cask':           ruby.bool_value(package.tap_core_cask)
		'sourcefile_path':         ruby.string_value(package.sourcefile_path)
		'origin_version':          ruby.string_value(package.origin_version)
		'revisions':               ruby.array_value(package.revisions.map(ruby.structured_value('FormulaVersions::Revision', it.revision, {
			'revision':  it.revision
			'version':   it.version
			'timestamp': it.timestamp.str()
		})))
	}
	if timestamp := package.last_updated_timestamp {
		values['last_updated_timestamp'] = ruby.int_value(timestamp)
	}
	return ruby.Value{
		type_name: match package.kind {
			'cask' { 'Cask::Cask' }
			'resource' { 'Resource' }
			else { 'Formula' }
		}
		repr: package.name
		map_data: values
	}
}

fn livecheck_string(values map[string]ruby.Value, key string) string {
	value := values[key] or { return '' }
	return if value.type_name == 'NilClass' { '' } else { value.as_string().trim_left(':') }
}

pub fn livecheck_package_from_value(value ruby.Value) !LivecheckPackage {
	values := value.map_data.clone()
	kind := livecheck_string(values, 'kind')
	mut package := LivecheckPackage{
		kind: if kind != '' {
			kind} else if value.type_name.contains('Cask') {
			'cask'} else if value.type_name == 'Resource' { 'resource' } else { 'formula' }
		name: livecheck_string(values, 'name')
		full_name: livecheck_string(values, 'full_name')
		version: livecheck_string(values, 'version')
		head_only: (values['head_only'] or { ruby.bool_value(false) }).bool_data
		installed_head_commit: livecheck_string(values, 'installed_head_commit')
		latest_head_commit: livecheck_string(values, 'latest_head_commit')
		owner_name: livecheck_string(values, 'owner_name')
		owner_full_name: livecheck_string(values, 'owner_full_name')
		stable_url: livecheck_string(values, 'stable_url')
		head_url: livecheck_string(values, 'head_url')
		homepage: livecheck_string(values, 'homepage')
		url: livecheck_string(values, 'url')
		mirrors: livecheck_strings(values['mirrors'] or { livecheck_nil() })
		stable_using: livecheck_string(values, 'stable_using')
		head_using: livecheck_string(values, 'head_using')
		url_using: livecheck_string(values, 'url_using')
		livecheck_defined: (values['livecheck_defined'] or { ruby.bool_value(false) }).bool_data
		livecheck_url: values['livecheck_url'] or { livecheck_nil() }
		livecheck_formula: livecheck_string(values, 'livecheck_formula')
		livecheck_cask: livecheck_string(values, 'livecheck_cask')
		livecheck_regex: livecheck_string(values, 'livecheck_regex')
		livecheck_strategy: livecheck_string(values, 'livecheck_strategy')
		livecheck_parameters: livecheck_strings(values['livecheck_parameters'] or { livecheck_nil() })
		livecheck_messages: livecheck_strings(values['livecheck_messages'] or { livecheck_nil() })
		livecheck_throttle: int((values['livecheck_throttle'] or { ruby.int_value(0) }).int_data)
		livecheck_throttle_days: int((values['livecheck_throttle_days'] or { ruby.int_value(0) }).int_data)
		tap_name: livecheck_string(values, 'tap_name')
		tap_path: livecheck_string(values, 'tap_path')
		tap_git: (values['tap_git'] or { ruby.bool_value(false) }).bool_data
		tap_core: (values['tap_core'] or { ruby.bool_value(false) }).bool_data
		tap_core_cask: (values['tap_core_cask'] or { ruby.bool_value(false) }).bool_data
		sourcefile_path: livecheck_string(values, 'sourcefile_path')
		origin_version: livecheck_string(values, 'origin_version')
	}
	for key, raw in (values['livecheck_matches'] or { ruby.map_value({}) }).map_data {
		package.livecheck_matches[key] = raw.as_string()
	}
	for raw in (values['resources'] or { ruby.array_value([]ruby.Value{}) }).as_array() or { []ruby.Value{} } {
		package.resources << livecheck_package_from_value(raw)!
	}
	if raw := values['last_updated_timestamp'] {
		package.last_updated_timestamp = raw.int_data
	}
	for raw in (values['revisions'] or { ruby.array_value([]ruby.Value{}) }).as_array() or { []ruby.Value{} } {
		package.revisions << LivecheckRevision{ revision: raw.attributes['revision'] or { raw.as_string() }, version: raw.attributes['version'] or { '' }, timestamp: (raw.attributes['timestamp'] or { '0' }).i64() }
	}
	if package.name == '' {
		package.name = value.as_string()
	}
	if package.full_name == '' {
		package.full_name = package.name
	}
	return package
}

pub fn livecheck_strategy_name(class_name string) string {
	return class_name.all_after_last('::')
}

pub fn livecheck_find_versions_parameters(package LivecheckPackage) []string {
	return package.livecheck_parameters.clone()
}

pub fn livecheck_other_tap_strategy_paths(packages []LivecheckPackage) []string {
	mut taps := map[string]string{}
	for package in packages {
		if package.tap_name != '' && !package.tap_core && !package.tap_core_cask {
			taps[package.tap_name] = os.join_path(package.tap_path, 'livecheck', 'strategy')
		}
	}
	mut names := taps.keys()
	names.sort()
	return names.filter(os.is_dir(taps[it])).map(taps[it])
}

pub fn livecheck_resolve_reference(package LivecheckPackage, catalog map[string]LivecheckPackage) !LivecheckReferenceResult {
	mut current := package
	mut references := []LivecheckPackage{}
	for {
		reference := if current.livecheck_formula != '' {
			current.livecheck_formula
		} else {
			current.livecheck_cask
		}
		if reference == '' {
			return LivecheckReferenceResult{
				references: references
			}
		}
		next := catalog[reference] or { return error('livecheck formula or cask not found') }
		if next.full_name == package.full_name || references.any(it.full_name == next.full_name) {
			return error('Circular formula/cask reference encountered')
		}
		references << next
		current = next
		if current.livecheck_formula == '' && current.livecheck_cask == '' {
			return LivecheckReferenceResult{
				has_package: true
				package: current
				references: references
			}
		}
	}
	return LivecheckReferenceResult{
		references: references
	}
}

pub fn livecheck_package_name(package LivecheckPackage, full_name bool) string {
	return if full_name && package.kind != 'resource' { package.full_name } else { package.name }
}

pub fn livecheck_status_hash(package LivecheckPackage, status string, messages []string) ruby.Value {
	mut meta := {
		'livecheck_defined': ruby.bool_value(package.livecheck_defined)
	}
	if package.kind == 'formula' && package.head_only {
		meta['head_only'] = ruby.bool_value(true)
	}
	mut values := {
		package.kind: ruby.string_value(package.name)
		'status':     ruby.string_value(status)
		'meta':       ruby.map_value(meta)
	}
	if messages.len > 0 {
		values['messages'] = ruby.string_array_value(messages)
	}
	return ruby.map_value(values)
}

pub fn livecheck_url_to_string(url ruby.Value, package LivecheckPackage) !string {
	if url.type_name == 'String' {
		return url.as_string()
	}
	if url.type_name != 'Symbol' {
		return error('`url ${url.as_string()}` does not reference a checkable URL')
	}
	symbol := url.as_string().trim_left(':')
	resolved := match symbol {
		'url' {
			if package.kind in ['cask', 'resource'] { package.url } else { '' }
		}
		'head' {
			if package.kind == 'formula' { package.head_url } else { '' }
		}
		'stable' {
			if package.kind == 'formula' { package.stable_url } else { '' }
		}
		'homepage' {
			if package.kind != 'resource' { package.homepage } else { '' }
		}
		else { '' }
	}
	if resolved == '' {
		return error('`url :${symbol}` does not reference a checkable URL')
	}
	return resolved
}

pub fn livecheck_checkable_urls(package LivecheckPackage) []string {
	mut urls := []string{}
	match package.kind {
		'formula' {
			if package.stable_url != '' {
				urls << package.stable_url
				urls << package.mirrors
			}
			if package.head_url != '' { urls << package.head_url }
			if package.homepage != '' { urls << package.homepage }
		}
		'cask' {
			if package.url != '' { urls << package.url }
			if package.homepage != '' { urls << package.homepage }
		}
		'resource' {
			if package.url != '' { urls << package.url }
		}
		else {}
	}
	mut unique := []string{}
	for url in urls {
		if url !in unique { unique << url }
	}
	return unique
}

pub fn livecheck_url_host(url string) ?string {
	parsed := urllib.parse(url) or { return none }
	if parsed.host == '' {
		return none
	}
	return parsed.host.to_lower()
}

pub fn livecheck_use_homebrew_curl(package LivecheckPackage, url string) bool {
	host := livecheck_url_host(url) or { return false }
	mut source_hosts := []string{}
	if package.kind == 'formula' {
		if package.stable_using == 'homebrew_curl' {
			if value := livecheck_url_host(package.stable_url) { source_hosts << value }
		}
		if package.head_using == 'homebrew_curl' {
			if value := livecheck_url_host(package.head_url) { source_hosts << value }
		}
	} else if package.kind == 'cask' && package.url_using == 'homebrew_curl' {
		if value := livecheck_url_host(package.url) { source_hosts << value }
	}
	return source_hosts.any(host == it || host.ends_with('.${it}') || it.ends_with('.${host}'))
}

fn livecheck_version_tokens(value string) []int {
	mut tokens := []int{}
	for part in value.split_any('.,-_+') {
		mut digits := ''
		for character in part {
			if character.is_digit() {
				digits += character.ascii_str()
			} else if digits != '' {
				break
			}
		}
		tokens << if digits == '' { 0 } else { digits.int() }
	}
	return tokens
}

fn livecheck_compare_versions(left string, right string) int {
	a := livecheck_version_tokens(left)
	b := livecheck_version_tokens(right)
	length := if a.len > b.len { a.len } else { b.len }
	for index in 0 .. length {
		av := if index < a.len { a[index] } else { 0 }
		bv := if index < b.len { b[index] } else { 0 }
		if av < bv {
			return -1
		}
		if av > bv {
			return 1
		}
	}
	return left.compare(right)
}

fn livecheck_latest(values map[string]string) ?string {
	mut latest := ''
	for _, value in values {
		if latest == '' || livecheck_compare_versions(value, latest) > 0 {
			latest = value
		}
	}
	return if latest == '' { none } else { latest }
}

pub fn livecheck_throttle_allows_bump(package LivecheckPackage, version string, rate ?int, days ?int, now i64) bool {
	if rate == none && days == none {
		return true
	}
	if throttle := rate {
		parts := livecheck_version_tokens(version)
		patch := if parts.len > 2 { parts[2] } else { 0 }
		if patch % throttle == 0 {
			return true
		}
	}
	if throttle_days := days {
		return livecheck_throttle_interval_elapsed(package, throttle_days, now)
	}
	return false
}

pub fn livecheck_latest_version_with_reference(package LivecheckPackage, referenced LivecheckPackage, has_reference bool, references []LivecheckPackage, interval_elapsed ?bool, json bool, full_name bool, verbose bool) ruby.Value {
	mut source := package
	if has_reference {
		if source.livecheck_url.type_name == '' || source.livecheck_url.type_name == 'NilClass' {
			source.livecheck_url = referenced.livecheck_url
		}
		if source.livecheck_regex == '' {
			source.livecheck_regex = referenced.livecheck_regex
		}
		if source.livecheck_strategy == '' {
			source.livecheck_strategy = referenced.livecheck_strategy
		}
		if source.livecheck_matches.len == 0 {
			source.livecheck_matches = referenced.livecheck_matches.clone()
		}
		if source.livecheck_messages.len == 0 {
			source.livecheck_messages = referenced.livecheck_messages.clone()
		}
		if source.livecheck_throttle == 0 {
			source.livecheck_throttle = referenced.livecheck_throttle
		}
		if source.livecheck_throttle_days == 0 {
			source.livecheck_throttle_days = referenced.livecheck_throttle_days
		}
	}
	mut matches := source.livecheck_matches.clone()
	if !package.livecheck_defined {
		for key, value in matches {
			if unstable_version_keywords.any(value.contains(it)) { matches.delete(key) }
		}
	}
	latest := livecheck_latest(matches) or {
		if source.livecheck_messages.len > 0 {
			return livecheck_status_hash(package, 'error', source.livecheck_messages)
		}
		return livecheck_nil()
	}
	mut values := {
		'latest': ruby.object_value('Version', latest)
	}
	if source.livecheck_throttle > 0 || source.livecheck_throttle_days > 0 {
		mut throttled := map[string]string{}
		if source.livecheck_throttle > 0 {
			for key, value in matches {
				if livecheck_throttle_allows_bump(package, value, source.livecheck_throttle, none, time.now().unix()) {
					throttled[key] = value
				}
			}
		}
		elapsed := interval_elapsed or {
			livecheck_throttle_interval_elapsed(package, source.livecheck_throttle_days, time.now().unix())
		}
		if source.livecheck_throttle_days > 0 && elapsed {
			values['latest_throttled'] = ruby.object_value('Version', latest)
		} else if throttled_latest := livecheck_latest(throttled) {
			values['latest_throttled'] = ruby.object_value('Version', throttled_latest)
		} else {
			values['latest_throttled'] = livecheck_nil()
		}
	}
	if json && verbose {
		mut meta := map[string]ruby.Value{}
		if references.len > 0 {
			mut reference_values := []ruby.Value{}
			for item in references {
				reference_values << ruby.map_value({
					item.kind: ruby.string_value(livecheck_package_name(item, full_name))
				})
			}
			meta['references'] = ruby.array_value(reference_values)
		}
		if source.livecheck_strategy != '' {
			meta['strategy'] = ruby.string_value(livecheck_strategy_name(source.livecheck_strategy))
		}
		if source.livecheck_regex != '' {
			meta['regex'] = ruby.string_value(source.livecheck_regex)
		}
		if source.livecheck_throttle > 0 {
			meta['throttle'] = ruby.int_value(source.livecheck_throttle)
		}
		if source.livecheck_throttle_days > 0 {
			meta['throttle_days'] = ruby.int_value(source.livecheck_throttle_days)
		}
		values['meta'] = ruby.map_value(meta)
	}
	return ruby.map_value(values)
}

pub fn livecheck_latest_version(package LivecheckPackage, interval_elapsed ?bool) ruby.Value {
	return livecheck_latest_version_with_reference(package, LivecheckPackage{}, false, []LivecheckPackage{}, interval_elapsed, false, false, false)
}

pub fn livecheck_resource_version_with_options(resource LivecheckPackage, formula_latest string, json bool, full_name bool, verbose bool) ruby.Value {
	mut package := resource
	if package.livecheck_formula == 'parent' {
		package.livecheck_matches = {
			formula_latest: formula_latest
		}
	} else {
		mut substituted := map[string]string{}
		for key, value in package.livecheck_matches {
			substituted[key.replace('{LATEST_VERSION}', formula_latest)] = value
		}
		package.livecheck_matches = substituted.clone()
	}
	latest_info := livecheck_latest_version(package, none)
	if latest_info.type_name == 'NilClass' {
		messages := if package.livecheck_messages.len > 0 {
			package.livecheck_messages
		} else {
			['Unable to get versions']
		}
		return livecheck_status_hash(resource, 'error', messages)
	}
	latest := (latest_info.map_data['latest'] or { livecheck_nil() }).as_string()
	comparison := livecheck_compare_versions(resource.version, latest)
	mut meta := {
		'livecheck_defined': ruby.bool_value(resource.livecheck_defined)
	}
	if package.livecheck_formula == 'parent' {
		owner := if full_name && package.owner_full_name != '' {
			package.owner_full_name
		} else {
			package.owner_name
		}
		meta['references'] = ruby.array_value([
			ruby.map_value({
				'formula': ruby.string_value(owner)
				'symbol':  ruby.Value{ type_name: 'Symbol', repr: 'parent' }
			}),
		])
	}
	if package.livecheck_strategy != '' {
		meta['strategy'] = ruby.string_value(livecheck_strategy_name(package.livecheck_strategy))
	}
	mut values := {
		'resource': ruby.string_value(resource.name)
		'version':  ruby.map_value({
			'current':             ruby.string_value(resource.version)
			'latest':              ruby.string_value(latest)
			'outdated':            ruby.bool_value(comparison < 0)
			'newer_than_upstream': ruby.bool_value(comparison > 0)
		})
		'meta':     ruby.map_value(meta)
	}
	if json && !verbose { values.delete('meta') }
	return ruby.map_value(values)
}

pub fn livecheck_resource_version(resource LivecheckPackage, formula_latest string) ruby.Value {
	return livecheck_resource_version_with_options(resource, formula_latest, false, false, false)
}

pub fn livecheck_find_version_update_revision(package LivecheckPackage, current string) ?string {
	version := if package.origin_version != '' { package.origin_version } else { current }
	mut found := false
	mut revision := ''
	for entry in package.revisions {
		if entry.version == version {
			found = true
			revision = entry.revision
		} else if found {
			break
		}
	}
	return if revision == '' { none } else { revision }
}

pub fn livecheck_timestamp_for_revision(package LivecheckPackage, revision string) ?i64 {
	for entry in package.revisions {
		if entry.revision == revision && entry.timestamp > 0 {
			return entry.timestamp
		}
	}
	return none
}

pub fn livecheck_last_updated_timestamp(package LivecheckPackage) ?i64 {
	if !package.tap_git {
		return none
	}
	if package.kind == 'formula' {
		if revision := livecheck_find_version_update_revision(package, package.version) {
			if timestamp := livecheck_timestamp_for_revision(package, revision) {
				return timestamp
			}
		}
	}
	return package.last_updated_timestamp
}

pub fn livecheck_throttle_interval_elapsed(package LivecheckPackage, days int, now i64) bool {
	if days <= 0 {
		return false
	}
	timestamp := livecheck_last_updated_timestamp(package) or { return false }
	return now - timestamp >= i64(days * 24 * 60 * 60)
}

fn livecheck_keywords(args []ruby.Value) map[string]ruby.Value {
	for index := args.len - 1; index >= 0; index-- {
		if args[index].type_name == 'Hash' {
			return args[index].map_data.clone()
		}
	}
	return map[string]ruby.Value{}
}

fn livecheck_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	value := values[key] or { return fallback }
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

// Ruby method `self.livecheck_strategy_names(strategy_class)` at line 37.
pub fn ruby_livecheck_l37_d1_self_livecheck_strategy_names(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_error('ArgumentError', 'strategy class is required')
	}
	return ruby.string_value(livecheck_strategy_name(args[0].as_string()))
}

// Ruby method `self.livecheck_find_versions_parameters(strategy_class)` at line 43.
pub fn ruby_livecheck_l43_d2_self_livecheck_find_versions_parameters(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([]ruby.Value{})
	}
	return ruby.string_array_value(livecheck_strings(args[0].map_data['parameters'] or { args[0] }))
}

// Ruby method `self.load_other_tap_strategies(formulae_and_casks_to_check)` at line 53.
pub fn ruby_livecheck_l53_d3_self_load_other_tap_strategies(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_nil()
	}
	mut packages := []LivecheckPackage{}
	for raw in args[0].as_array() or { []ruby.Value{} } {
		packages << livecheck_package_from_value(raw) or { continue }
	}
	return ruby.string_array_value(livecheck_other_tap_strategy_paths(packages))
}

// Ruby method `self.resolve_livecheck_reference(` at line 83.
pub fn ruby_livecheck_l83_d4_self_resolve_livecheck_reference(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_error('ArgumentError', 'package is required')
	}
	package := livecheck_package_from_value(args[0]) or { return livecheck_error('TypeError', err.msg()) }
	mut catalog := map[string]LivecheckPackage{}
	if args.len > 1 {
		for key, raw in args[1].map_data {
			catalog[key] = livecheck_package_from_value(raw) or { continue }
		}
	}
	resolved := livecheck_resolve_reference(package, catalog) or { return livecheck_error('RuntimeError', err.msg()) }
	return ruby.array_value([
		if resolved.has_package { livecheck_package_value(resolved.package) } else { livecheck_nil() },
		ruby.array_value(resolved.references.map(livecheck_package_value(it))),
	])
}

// Ruby method `self.run_checks(` at line 160.
pub fn ruby_livecheck_l160_d5_self_run_checks(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([]ruby.Value{})
	}
	options := livecheck_keywords(args)
	mut packages := []LivecheckPackage{}
	for raw in args[0].as_array() or { []ruby.Value{} } {
		packages << livecheck_package_from_value(raw) or { continue }
	}
	full_name := livecheck_bool(options, 'full_name', false)
	json := livecheck_bool(options, 'json', false)
	verbose := livecheck_bool(options, 'verbose', false)
	quiet := livecheck_bool(options, 'quiet', false)
	newer_only := livecheck_bool(options, 'newer_only', false)
	check_resources := livecheck_bool(options, 'check_resources', false)
	mut name_counts := map[string]int{}
	if !full_name {
		for package in packages {
			name_counts[package.name]++
		}
	}
	mut catalog := map[string]LivecheckPackage{}
	if raw_catalog := options['catalog'] {
		for key, raw in raw_catalog.map_data {
			catalog[key] = livecheck_package_from_value(raw) or { continue }
		}
	}
	mut results := []ruby.Value{}
	for package in packages {
		use_full_name := full_name || name_counts[package.name] > 1
		mut referenced := LivecheckPackage{}
		mut has_reference := false
		mut references := []LivecheckPackage{}
		if package.livecheck_formula != '' || package.livecheck_cask != '' {
			resolved := livecheck_resolve_reference(package, catalog) or {
				if !quiet {
					mut status := livecheck_status_hash(package, 'error', [err.msg()])
					if use_full_name {
						mut status_values := status.map_data.clone()
						status_values[package.kind] = ruby.string_value(package.full_name)
						status = ruby.map_value(status_values)
					}
					results << status
				}
				continue
			}
			has_reference = resolved.has_package
			referenced = resolved.package
			references = resolved.references.clone()
		}
		current_text := if package.head_only {
			package.installed_head_commit
		} else {
			package.version
		}
		if current_text == '' {
			if !quiet {
				mut status := livecheck_status_hash(package, 'error', [
					'Unable to identify current version',
				])
				if use_full_name {
					mut status_values := status.map_data.clone()
					status_values[package.kind] = ruby.string_value(package.full_name)
					status = ruby.map_value(status_values)
				}
				results << status
			}
			continue
		}
		latest := if package.head_only && package.latest_head_commit != '' {
			ruby.map_value({
				'latest': ruby.object_value('Version', package.latest_head_commit)
			})
		} else {
			livecheck_latest_version_with_reference(package, referenced, has_reference, references, none, json, use_full_name, verbose)
		}
		if latest.type_name == 'NilClass' {
			if !quiet {
				mut status := livecheck_status_hash(package, 'error', [
					'Unable to get versions',
				])
				if use_full_name {
					mut status_values := status.map_data.clone()
					status_values[package.kind] = ruby.string_value(package.full_name)
					status = ruby.map_value(status_values)
				}
				results << status
			}
			continue
		}
		if (latest.map_data['status'] or { livecheck_nil() }).as_string() == 'error' {
			if !quiet && !newer_only { results << latest }
			continue
		}
		mut upstream_text := (latest.map_data['latest'] or { livecheck_nil() }).as_string()
		if upstream_text.ends_with('-release') && !current_text.ends_with('-release') {
			upstream_text = upstream_text[..upstream_text.len - '-release'.len]
		}
		comparison := livecheck_compare_versions(current_text, upstream_text)
		outdated := if package.head_only { current_text != upstream_text } else { comparison < 0 }
		if newer_only && !outdated {
			continue
		}
		mut version_values := {
			'current':             ruby.string_value(current_text)
			'latest':              ruby.string_value(upstream_text)
			'outdated':            ruby.bool_value(outdated)
			'newer_than_upstream': ruby.bool_value(!package.head_only && comparison > 0)
		}
		if throttled := latest.map_data['latest_throttled'] {
			version_values['latest_throttled'] = throttled
		}
		mut meta_values := {
			'livecheck_defined': ruby.bool_value(package.livecheck_defined)
		}
		if package.head_only {
			meta_values['head_only'] = ruby.bool_value(true)
		}
		if latest_meta := latest.map_data['meta'] {
			for key, value in latest_meta.map_data {
				meta_values[key] = value
			}
		}
		mut info_values := {
			package.kind: ruby.string_value(livecheck_package_name(package, use_full_name))
			'version':    ruby.map_value(version_values)
			'meta':       ruby.map_value(meta_values)
		}
		if check_resources && package.kind == 'formula' && package.resources.len > 0 {
			mut resources := []ruby.Value{}
			for resource in package.resources {
				resources << livecheck_resource_version(resource, upstream_text)
			}
			info_values['resources'] = ruby.array_value(resources)
		}
		if json && !verbose { info_values.delete('meta') }
		results << ruby.map_value(info_values)
	}
	return ruby.array_value(results)
}

// Ruby method `self.package_or_resource_name(package_or_resource, full_name: false)` at line 430.
pub fn ruby_livecheck_l430_d6_self_package_or_resource_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_error('ArgumentError', 'package is required')
	}
	pkg := livecheck_package_from_value(args[0]) or { return livecheck_error('TypeError', err.msg()) }
	return ruby.string_value(livecheck_package_name(pkg, livecheck_bool(livecheck_keywords(args), 'full_name', false)))
}

// Ruby method `self.cask_name(cask, full_name: false)` at line 446.
pub fn ruby_livecheck_l446_d7_self_cask_name(args ...ruby.Value) ruby.Value {
	return ruby_livecheck_l430_d6_self_package_or_resource_name(...args)
}

// Ruby method `self.formula_name(formula, full_name: false)` at line 453.
pub fn ruby_livecheck_l453_d8_self_formula_name(args ...ruby.Value) ruby.Value {
	return ruby_livecheck_l430_d6_self_package_or_resource_name(...args)
}

// Ruby method `self.status_hash(package_or_resource, status_str, messages = nil, full_name: false, verbose: false)` at line 466.
pub fn ruby_livecheck_l466_d9_self_status_hash(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return livecheck_error('ArgumentError', 'package and status are required')
	}
	pkg := livecheck_package_from_value(args[0]) or { return livecheck_error('TypeError', err.msg()) }
	messages := if args.len > 2 { livecheck_strings(args[2]) } else { []string{} }
	result := livecheck_status_hash(pkg, args[1].as_string(), messages)
	if livecheck_bool(livecheck_keywords(args), 'full_name', false) {
		mut values := result.map_data.clone()
		values[pkg.kind] = ruby.string_value(pkg.full_name)
		return ruby.map_value(values)
	}
	return result
}

// Ruby method `self.print_latest_version(info, verbose: false, ambiguous_cask: false)` at line 492.
pub fn ruby_livecheck_l492_d10_self_print_latest_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_nil()
	}
	info := args[0].map_data.clone()
	version := (info['version'] or { ruby.map_value({}) }).map_data.clone()
	mut name := ''
	for key in ['formula', 'cask', 'resource'] {
		if raw := info[key] {
			name = raw.as_string()
			break
		}
	}
	options := livecheck_keywords(args)
	mut display_name := if 'resource' in info { '  ${name}' } else { name }
	if livecheck_bool(options, 'ambiguous_cask', false) {
		display_name += ' (cask)'
	}
	meta_value := info['meta'] or { ruby.map_value({}) }
	meta := meta_value.map_data.clone()
	if livecheck_bool(options, 'verbose', false) && !(meta['livecheck_defined'] or { ruby.bool_value(true) }).bool_data {
		display_name += ' (guessed)'
	}
	return ruby.string_value('${display_name}: ${(version['current'] or { livecheck_nil() }).as_string()} ==> ${(version['latest'] or { livecheck_nil() }).as_string()}')
}

// Ruby method `self.print_resources_info(info, verbose: false)` at line 515.
pub fn ruby_livecheck_l515_d11_self_print_resources_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	mut lines := []string{}
	for raw in args[0].as_array() or { []ruby.Value{} } {
		if (raw.map_data['status'] or { livecheck_nil() }).as_string() != '' {
			name := (raw.map_data['resource'] or { ruby.string_value('') }).as_string()
			for message in livecheck_strings(raw.map_data['messages'] or { livecheck_nil() }) {
				lines << '${name}: ${message}'
			}
		} else {
			lines << ruby_livecheck_l492_d10_self_print_latest_version(raw, ruby.map_value(livecheck_keywords(args))).as_string()
		}
	}
	return ruby.string_value(lines.join('\n'))
}

// Ruby method `self.livecheck_url_to_string(livecheck_url, package_or_resource)` at line 531.
pub fn ruby_livecheck_l531_d12_self_livecheck_url_to_string(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return livecheck_error('ArgumentError', 'URL and package are required')
	}
	package := livecheck_package_from_value(args[1]) or { return livecheck_error('TypeError', err.msg()) }
	return ruby.string_value(livecheck_url_to_string(args[0], package) or { return livecheck_error('ArgumentError', err.msg()) })
}

// Ruby method `self.checkable_urls(package_or_resource)` at line 552.
pub fn ruby_livecheck_l552_d13_self_checkable_urls(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([]string{})
	}
	package := livecheck_package_from_value(args[0]) or { return livecheck_error('TypeError', err.msg()) }
	return ruby.string_array_value(livecheck_checkable_urls(package))
}

// Ruby method `self.use_homebrew_curl?(formula_or_cask, url)` at line 579.
pub fn ruby_livecheck_l579_d14_self_use_homebrew_curl(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	package := livecheck_package_from_value(args[0]) or { return ruby.bool_value(false) }
	return ruby.bool_value(livecheck_use_homebrew_curl(package, args[1].as_string()))
}

// Ruby method `self.url_host(url)` at line 607.
pub fn ruby_livecheck_l607_d15_self_url_host(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_nil()
	}
	host := livecheck_url_host(args[0].as_string()) or { return livecheck_nil() }
	return ruby.string_value(host)
}

// Ruby method `self.latest_version(` at line 626.
pub fn ruby_livecheck_l626_d16_self_latest_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_nil()
	}
	package := livecheck_package_from_value(args[0]) or { return livecheck_error('TypeError', err.msg()) }
	options := livecheck_keywords(args)
	elapsed := if raw := options['interval_elapsed'] { ?bool(raw.bool_data) } else { none }
	mut referenced := LivecheckPackage{}
	mut has_reference := false
	if raw := options['referenced_formula_or_cask'] {
		referenced = livecheck_package_from_value(raw) or { return livecheck_error('TypeError', err.msg()) }
		has_reference = true
	}
	mut references := []LivecheckPackage{}
	if raw := options['livecheck_references'] {
		for value in raw.as_array() or { []ruby.Value{} } {
			references << livecheck_package_from_value(value) or { continue }
		}
	}
	return livecheck_latest_version_with_reference(package, referenced, has_reference, references, elapsed, livecheck_bool(options, 'json', false), livecheck_bool(options, 'full_name', false), livecheck_bool(options, 'verbose', false))
}

// Ruby method `self.resource_version(` at line 897.
pub fn ruby_livecheck_l897_d17_self_resource_version(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return livecheck_nil()
	}
	resource := livecheck_package_from_value(args[0]) or { return livecheck_error('TypeError', err.msg()) }
	options := livecheck_keywords(args)
	return livecheck_resource_version_with_options(resource, args[1].as_string(), livecheck_bool(options, 'json', false), livecheck_bool(options, 'full_name', false), livecheck_bool(options, 'verbose', false))
}

// Ruby method `self.throttle_allows_bump?(formula_or_cask, version, throttle_rate: nil, throttle_days: nil)` at line 1135.
pub fn ruby_livecheck_l1135_d18_self_throttle_allows_bump(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	package := livecheck_package_from_value(args[0]) or { return ruby.bool_value(false) }
	options := livecheck_keywords(args)
	rate := if raw := options['throttle_rate'] { ?int(int(raw.int_data)) } else { none }
	days := if raw := options['throttle_days'] { ?int(int(raw.int_data)) } else { none }
	now := (options['now'] or { ruby.int_value(time.now().unix()) }).int_data
	return ruby.bool_value(livecheck_throttle_allows_bump(package, args[1].as_string(), rate, days, now))
}

// Ruby method `self.formula_or_cask_last_updated_timestamp(package_or_resource)` at line 1147.
pub fn ruby_livecheck_l1147_d19_self_formula_or_cask_last_updated_timestamp(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_nil()
	}
	package := livecheck_package_from_value(args[0]) or { return livecheck_nil() }
	timestamp := livecheck_last_updated_timestamp(package) or { return livecheck_nil() }
	return ruby.int_value(timestamp)
}

// Ruby method `self.formula_last_version_update_timestamp(formula, tap:)` at line 1162.
pub fn ruby_livecheck_l1162_d20_self_formula_last_version_update_timestamp(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_nil()
	}
	package := livecheck_package_from_value(args[0]) or { return livecheck_nil() }
	revision := livecheck_find_version_update_revision(package, package.version) or { return livecheck_nil() }
	timestamp := livecheck_timestamp_for_revision(package, revision) or { return livecheck_nil() }
	return ruby.int_value(timestamp)
}

// Ruby method `self.find_version_update_revision(formula, current_version)` at line 1173.
pub fn ruby_livecheck_l1173_d21_self_find_version_update_revision(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return livecheck_nil()
	}
	package := livecheck_package_from_value(args[0]) or { return livecheck_nil() }
	revision := livecheck_find_version_update_revision(package, args[1].as_string()) or { return livecheck_nil() }
	return ruby.string_value(revision)
}

// Ruby method `self.origin_stable_version(formula, formula_versions)` at line 1200.
pub fn ruby_livecheck_l1200_d22_self_origin_stable_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_nil()
	}
	package := livecheck_package_from_value(args[0]) or { return livecheck_nil() }
	return if package.origin_version == '' {
		livecheck_nil()
	} else {
		ruby.object_value('Version', package.origin_version)
	}
}

// Ruby method `self.formula_or_cask_last_commit_timestamp(package_or_resource, tap)` at line 1223.
pub fn ruby_livecheck_l1223_d23_self_formula_or_cask_last_commit_timestamp(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return livecheck_nil()
	}
	package := livecheck_package_from_value(args[0]) or { return livecheck_nil() }
	timestamp := package.last_updated_timestamp or { return livecheck_nil() }
	return ruby.int_value(timestamp)
}

// Ruby method `self.timestamp_for_revision(repository_path, revision)` at line 1274.
pub fn ruby_livecheck_l1274_d24_self_timestamp_for_revision(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return livecheck_nil()
	}
	package := livecheck_package_from_value(args[0]) or { return livecheck_nil() }
	timestamp := livecheck_timestamp_for_revision(package, args[1].as_string()) or { return livecheck_nil() }
	return ruby.int_value(timestamp)
}

// Ruby method `self.throttle_interval_elapsed?(package_or_resource, days)` at line 1291.
pub fn ruby_livecheck_l1291_d25_self_throttle_interval_elapsed(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	package := livecheck_package_from_value(args[0]) or { return ruby.bool_value(false) }
	options := livecheck_keywords(args)
	now := (options['now'] or { ruby.int_value(time.now().unix()) }).int_data
	return ruby.bool_value(livecheck_throttle_interval_elapsed(package, int(args[1].int_data), now))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/constants"
// 5: require "livecheck/error"
// 6: require "livecheck/livecheck_version"
// 7: require "livecheck/skip_conditions"
// 8: require "livecheck/strategy"
// 9: require "formula_versions"
// 10: require "uri"
// 11: require "utils/git"
// 12: require "utils/output"
// 13:
// 14: module Homebrew
// 15:   # The {Livecheck} module consists of methods used by the `brew livecheck`
// 16:   # command. These methods print the requested livecheck information
// 17:   # for formulae.
// 18:   module Livecheck
// 19:     extend Utils::Output::Mixin
// 20:
// 21:     NO_CURRENT_VERSION_MSG = "Unable to identify current version"
// 22:     NO_VERSIONS_MSG = "Unable to get versions"
// 23:
// 24:     UNSTABLE_VERSION_KEYWORDS = %w[
// 25:       alpha
// 26:       beta
// 27:       bpo
// 28:       dev
// 29:       experimental
// 30:       prerelease
// 31:       preview
// 32:       rc
// 33:     ].freeze
// 34:     private_constant :UNSTABLE_VERSION_KEYWORDS
// 35:
// 36:     sig { params(strategy_class: T::Class[Strategic]).returns(String) }
// 37:     def self.livecheck_strategy_names(strategy_class)
// 38:       @livecheck_strategy_names ||= T.let({}, T.nilable(T::Hash[T::Class[Strategic], String]))
// 39:       @livecheck_strategy_names[strategy_class] ||= Utils.demodulize(strategy_class.name)
// 40:     end
// 41:
// 42:     sig { params(strategy_class: T::Class[Strategic]).returns(T::Array[Symbol]) }
// 43:     def self.livecheck_find_versions_parameters(strategy_class)
// 44:       @livecheck_find_versions_parameters ||= T.let({}, T.nilable(T::Hash[T::Class[Strategic], T::Array[Symbol]]))
// 45:       @livecheck_find_versions_parameters[strategy_class] ||=
// 46:         (T::Utils.signature_for_method(strategy_class.method(:find_versions))&.parameters ||
// 47:          strategy_class.method(:find_versions).parameters).map(&:second)
// 48:     end
// 49:
// 50:     # Uses `formulae_and_casks_to_check` to identify taps in use other than
// 51:     # homebrew/core and homebrew/cask and loads strategies from them.
// 52:     sig { params(formulae_and_casks_to_check: T::Array[T.any(Formula, Cask::Cask)]).void }
// 53:     def self.load_other_tap_strategies(formulae_and_casks_to_check)
// 54:       other_taps = {}
// 55:       formulae_and_casks_to_check.each do |formula_or_cask|
// 56:         tap = formula_or_cask.tap
// 57:         next unless tap
// 58:         next if tap.core_tap?
// 59:         next if tap.core_cask_tap?
// 60:         next if other_taps[tap.name]
// 61:
// 62:         other_taps[tap.name] = tap
// 63:       end
// 64:       other_taps = other_taps.sort.to_h
// 65:
// 66:       other_taps.each_value do |tap|
// 67:         tap_strategy_path = "#{tap.path}/livecheck/strategy"
// 68:         Dir["#{tap_strategy_path}/*.rb"].each { require(it) } if Dir.exist?(tap_strategy_path)
// 69:       end
// 70:     end
// 71:
// 72:     # Resolve formula/cask references in `livecheck` blocks to a final formula
// 73:     # or cask.
// 74:     sig {
// 75:       params(
// 76:         formula_or_cask:       T.any(Formula, Cask::Cask),
// 77:         first_formula_or_cask: T.any(Formula, Cask::Cask),
// 78:         references:            T::Array[T.any(Formula, Cask::Cask)],
// 79:         full_name:             T::Boolean,
// 80:         debug:                 T::Boolean,
// 81:       ).returns(T.nilable(T::Array[T.untyped]))
// 82:     }
// 83:     def self.resolve_livecheck_reference(
// 84:       formula_or_cask,
// 85:       first_formula_or_cask = formula_or_cask,
// 86:       references = [],
// 87:       full_name: false,
// 88:       debug: false
// 89:     )
// 90:       # Check the `livecheck` block for a formula or cask reference
// 91:       livecheck = formula_or_cask.livecheck
// 92:       livecheck_formula = livecheck.formula
// 93:       livecheck_cask = livecheck.cask
// 94:       return [nil, references] if livecheck_formula.blank? && livecheck_cask.blank?
// 95:
// 96:       # Load the referenced formula or cask
// 97:       referenced_formula_or_cask = Homebrew.with_no_api_env do
// 98:         if livecheck_formula
// 99:           Formulary.factory(livecheck_formula)
// 100:         elsif livecheck_cask
// 101:           Cask::CaskLoader.load(livecheck_cask)
// 102:         else
// 103:           raise "livecheck formula or cask not found"
// 104:         end
// 105:       end
// 106:
// 107:       # Error if a `livecheck` block references a formula/cask that was already
// 108:       # referenced (or itself)
// 109:       if referenced_formula_or_cask == first_formula_or_cask ||
// 110:          referenced_formula_or_cask == formula_or_cask ||
// 111:          references.include?(referenced_formula_or_cask)
// 112:         if debug
// 113:           # Print the chain of references for debugging
// 114:           puts "Reference Chain:"
// 115:           puts package_or_resource_name(first_formula_or_cask, full_name:)
// 116:
// 117:           references << referenced_formula_or_cask
// 118:           references.each do |ref_formula_or_cask|
// 119:             puts package_or_resource_name(ref_formula_or_cask, full_name:)
// 120:           end
// 121:         end
// 122:
// 123:         raise "Circular formula/cask reference encountered"
// 124:       end
// 125:       references << referenced_formula_or_cask
// 126:
// 127:       # Check the referenced formula/cask for a reference
// 128:       next_referenced_formula_or_cask, next_references = resolve_livecheck_reference(
// 129:         referenced_formula_or_cask,
// 130:         first_formula_or_cask,
// 131:         references,
// 132:         full_name:,
// 133:         debug:,
// 134:       )
// 135:
// 136:       # Returning references along with the final referenced formula/cask
// 137:       # allows us to print the chain of references in the debug output
// 138:       [
// 139:         next_referenced_formula_or_cask || referenced_formula_or_cask,
// 140:         next_references,
// 141:       ]
// 142:     end
// 143:
// 144:     # Executes the livecheck logic for each formula/cask in the
// 145:     # `formulae_and_casks_to_check` array and prints the results.
// 146:     sig {
// 147:       params(
// 148:         formulae_and_casks_to_check: T::Array[T.any(Formula, Cask::Cask)],
// 149:         full_name:                   T::Boolean,
// 150:         handle_name_conflict:        T::Boolean,
// 151:         check_resources:             T::Boolean,
// 152:         json:                        T::Boolean,
// 153:         newer_only:                  T::Boolean,
// 154:         extract_plist:               T::Boolean,
// 155:         debug:                       T::Boolean,
// 156:         quiet:                       T::Boolean,
// 157:         verbose:                     T::Boolean,
// 158:       ).void
// 159:     }
// 160:     def self.run_checks(
// 161:       formulae_and_casks_to_check,
// 162:       full_name: false, handle_name_conflict: false, check_resources: false, json: false, newer_only: false,
// 163:       extract_plist: false, debug: false, quiet: false, verbose: false
// 164:     )
// 165:       load_other_tap_strategies(formulae_and_casks_to_check)
// 166:
// 167:       ambiguous_casks = []
// 168:       if handle_name_conflict
// 169:         ambiguous_casks = formulae_and_casks_to_check
// 170:                           .group_by { |item| package_or_resource_name(item, full_name: true) }
// 171:                           .values
// 172:                           .select { |items| items.length > 1 }
// 173:                           .flatten
// 174:                           .grep(Cask::Cask)
// 175:       end
// 176:
// 177:       ambiguous_names = []
// 178:       unless full_name
// 179:         grouped = (formulae_and_casks_to_check - ambiguous_casks).group_by { |item| package_or_resource_name(item) }
// 180:         ambiguous_names = grouped.values.select { |items| items.length > 1 }.flatten
// 181:       end
// 182:
// 183:       has_a_newer_upstream_version = T.let(false, T::Boolean)
// 184:
// 185:       formulae_and_casks_total = formulae_and_casks_to_check.count
// 186:       if json && !quiet && $stderr.tty?
// 187:         Tty.with($stderr) do |stderr|
// 188:           stderr.puts Formatter.headline("Running checks", color: :blue)
// 189:         end
// 190:
// 191:         require "ruby-progressbar"
// 192:         progress = ProgressBar.create(
// 193:           total:          formulae_and_casks_total,
// 194:           progress_mark:  "#",
// 195:           remainder_mark: ".",
// 196:           format:         " %t: [%B] %c/%C ",
// 197:           output:         $stderr,
// 198:         )
// 199:       end
// 200:
// 201:       # Allow ExtractPlist strategy if only one formula/cask is being checked.
// 202:       extract_plist = true if formulae_and_casks_total == 1
// 203:
// 204:       formulae_checked = formulae_and_casks_to_check.map.with_index do |formula_or_cask, i|
// 205:         case formula_or_cask
// 206:         when Formula
// 207:           formula = formula_or_cask
// 208:           formula.head&.downloader&.quiet!
// 209:         when Cask::Cask
// 210:           cask = formula_or_cask
// 211:         end
// 212:
// 213:         use_full_name = full_name || ambiguous_names.include?(formula_or_cask)
// 214:         name = package_or_resource_name(formula_or_cask, full_name: use_full_name)
// 215:
// 216:         referenced_formula_or_cask, livecheck_references =
// 217:           resolve_livecheck_reference(formula_or_cask, full_name: use_full_name, debug:)
// 218:
// 219:         if debug && i.positive?
// 220:           puts <<~EOS
// 221:
// 222:             ----------
// 223:
// 224:           EOS
// 225:         elsif debug
// 226:           puts
// 227:         end
// 228:
// 229:         # Check skip conditions for a referenced formula/cask
// 230:         if referenced_formula_or_cask
// 231:           skip_info = SkipConditions.referenced_skip_information(
// 232:             referenced_formula_or_cask,
// 233:             name,
// 234:             full_name:     use_full_name,
// 235:             verbose:,
// 236:             extract_plist:,
// 237:           )
// 238:         end
// 239:
// 240:         skip_info ||= SkipConditions.skip_information(
// 241:           formula_or_cask,
// 242:           full_name:     use_full_name,
// 243:           verbose:,
// 244:           extract_plist:,
// 245:         )
// 246:         if skip_info.present?
// 247:           next skip_info if json && !newer_only
// 248:
// 249:           SkipConditions.print_skip_information(skip_info) if !newer_only && !quiet
// 250:           next
// 251:         end
// 252:
// 253:         # Use the `stable` version for comparison except for installed
// 254:         # HEAD-only formulae. A formula with `stable` and `head` that's
// 255:         # installed using `--head` will still use the `stable` version for
// 256:         # comparison.
// 257:         current = if formula
// 258:           if formula.head_only?
// 259:             formula_commit = formula.any_installed_version&.version&.commit
// 260:             Version.new(formula_commit) if formula_commit
// 261:           elsif (stable = formula.stable)
// 262:             stable.version
// 263:           end
// 264:         else
// 265:           Version.new(formula_or_cask.version)
// 266:         end
// 267:         unless current
// 268:           raise Livecheck::Error, NO_CURRENT_VERSION_MSG unless json
// 269:           next if quiet
// 270:
// 271:           next status_hash(formula_or_cask, "error", [NO_CURRENT_VERSION_MSG], full_name: use_full_name, verbose:)
// 272:         end
// 273:
// 274:         current_str = current.to_s
// 275:         current = LivecheckVersion.create(formula_or_cask, current)
// 276:
// 277:         latest = if formula&.head_only?
// 278:           Version.new(T.must(formula.head).downloader.fetch_last_commit)
// 279:         else
// 280:           version_info = latest_version(
// 281:             formula_or_cask,
// 282:             referenced_formula_or_cask:,
// 283:             livecheck_references:,
// 284:             json:, full_name: use_full_name, verbose:, debug:
// 285:           )
// 286:           version_info[:latest] if version_info.present?
// 287:         end
// 288:
// 289:         check_for_resources = check_resources && formula_or_cask.is_a?(Formula) && formula_or_cask.resources.present?
// 290:         if check_for_resources
// 291:           resource_version_info = formula_or_cask.resources.map do |resource|
// 292:             res_skip_info ||= SkipConditions.skip_information(resource, verbose:)
// 293:             if res_skip_info.present?
// 294:               res_skip_info
// 295:             else
// 296:               res_version_info = resource_version(
// 297:                 resource,
// 298:                 latest.to_s,
// 299:                 json:,
// 300:                 full_name: use_full_name,
// 301:                 debug:,
// 302:                 quiet:,
// 303:                 verbose:,
// 304:               )
// 305:               if res_version_info.empty?
// 306:                 status_hash(resource, "error", [NO_VERSIONS_MSG], verbose:)
// 307:               else
// 308:                 res_version_info
// 309:               end
// 310:             end
// 311:           end.compact_blank
// 312:           Homebrew.failed = true if resource_version_info.any? { |info| info[:status] == "error" }
// 313:         end
// 314:
// 315:         if latest.blank?
// 316:           raise Livecheck::Error, NO_VERSIONS_MSG unless json
// 317:           next if quiet
// 318:
// 319:           next version_info if version_info.is_a?(Hash) && version_info[:status] && version_info[:messages]
// 320:
// 321:           latest_info = status_hash(formula_or_cask, "error", [NO_VERSIONS_MSG], full_name: use_full_name,
// 322:                                                                                  verbose:)
// 323:           if check_for_resources
// 324:             unless verbose
// 325:               resource_version_info.map! do |info|
// 326:                 info.delete(:meta)
// 327:                 info
// 328:               end
// 329:             end
// 330:             latest_info[:resources] = resource_version_info
// 331:           end
// 332:
// 333:           next latest_info
// 334:         end
// 335:
// 336:         if (m = latest.to_s.match(/(.*)-release$/)) && !current.to_s.match(/.*-release$/)
// 337:           latest = Version.new(m[1])
// 338:         end
// 339:
// 340:         latest_str = latest.to_s
// 341:         latest = LivecheckVersion.create(formula_or_cask, latest)
// 342:
// 343:         is_outdated = if formula&.head_only?
// 344:           # A HEAD-only formula is considered outdated if the latest upstream
// 345:           # commit hash is different than the installed version's commit hash
// 346:           (current != latest)
// 347:         else
// 348:           (current < latest)
// 349:         end
// 350:
// 351:         is_newer_than_upstream = (formula&.stable? || cask) && (current > latest)
// 352:
// 353:         info = {}
// 354:         info[:formula] = name if formula
// 355:         info[:cask] = name if cask
// 356:         info[:version] = {
// 357:           current:             current_str,
// 358:           latest:              latest_str,
// 359:           latest_throttled:    version_info&.dig(:latest_throttled),
// 360:           outdated:            is_outdated,
// 361:           newer_than_upstream: is_newer_than_upstream,
// 362:         }.compact
// 363:         info[:meta] = {
// 364:           livecheck_defined: formula_or_cask.livecheck_defined?,
// 365:         }
// 366:         info[:meta][:head_only] = true if formula&.head_only?
// 367:         info[:meta].merge!(version_info[:meta]) if version_info.present? && version_info.key?(:meta)
// 368:
// 369:         info[:resources] = resource_version_info if check_for_resources
// 370:
// 371:         next if newer_only && !info[:version][:outdated]
// 372:
// 373:         has_a_newer_upstream_version ||= true
// 374:
// 375:         if json
// 376:           progress&.increment
// 377:           info.delete(:meta) unless verbose
// 378:           if check_for_resources && !verbose
// 379:             resource_version_info.map! do |resource_info|
// 380:               resource_info.delete(:meta)
// 381:               resource_info
// 382:             end
// 383:           end
// 384:           next info
// 385:         end
// 386:         puts if debug
// 387:         print_latest_version(info, verbose:, ambiguous_cask: ambiguous_casks.include?(formula_or_cask))
// 388:         print_resources_info(resource_version_info, verbose:) if check_for_resources
// 389:         nil
// 390:       rescue => e
// 391:         Homebrew.failed = true
// 392:         use_full_name = full_name || ambiguous_names.include?(formula_or_cask)
// 393:
// 394:         if json
// 395:           progress&.increment
// 396:           unless quiet
// 397:             status_hash(formula_or_cask, "error", [e.to_s], full_name: use_full_name,
// 398:                                                             verbose:)
// 399:           end
// 400:         elsif !quiet
// 401:           name = package_or_resource_name(formula_or_cask, full_name: use_full_name)
// 402:           name += " (cask)" if ambiguous_casks.include?(formula_or_cask)
// 403:
// 404:           onoe "#{Tty.blue}#{name}#{Tty.reset}: #{e}"
// 405:           if debug && !e.is_a?(Livecheck::Error)
// 406:             require "utils/backtrace"
// 407:             $stderr.puts Utils::Backtrace.clean(e)
// 408:           end
// 409:           print_resources_info(resource_version_info, verbose:) if check_for_resources
// 410:           nil
// 411:         end
// 412:       end
// 413:
// 414:       puts "No newer upstream versions." if newer_only && !has_a_newer_upstream_version && !debug && !json && !quiet
// 415:
// 416:       return unless json
// 417:
// 418:       if progress
// 419:         progress.finish
// 420:         Tty.with($stderr) do |stderr|
// 421:           erase = "#{Tty.up}#{Tty.erase_line}" * 2
// 422:           stderr.print "#{Tty.begin_synchronized_update}#{erase}#{Tty.end_synchronized_update}" unless erase.empty?
// 423:         end
// 424:       end
// 425:
// 426:       puts JSON.pretty_generate(formulae_checked.compact)
// 427:     end
// 428:
// 429:     sig { params(package_or_resource: T.any(Formula, Cask::Cask, Resource), full_name: T::Boolean).returns(String) }
// 430:     def self.package_or_resource_name(package_or_resource, full_name: false)
// 431:       case package_or_resource
// 432:       when Formula
// 433:         formula_name(package_or_resource, full_name:)
// 434:       when Cask::Cask
// 435:         cask_name(package_or_resource, full_name:)
// 436:       when Resource
// 437:         package_or_resource.name.to_s
// 438:       else
// 439:         T.absurd(package_or_resource)
// 440:       end
// 441:     end
// 442:
// 443:     # Returns the fully-qualified name of a cask if the `full_name` argument is
// 444:     # provided; returns the name otherwise.
// 445:     sig { params(cask: Cask::Cask, full_name: T::Boolean).returns(String) }
// 446:     private_class_method def self.cask_name(cask, full_name: false)
// 447:       full_name ? cask.full_name : cask.token
// 448:     end
// 449:
// 450:     # Returns the fully-qualified name of a formula if the `full_name` argument is
// 451:     # provided; returns the name otherwise.
// 452:     sig { params(formula: Formula, full_name: T::Boolean).returns(String) }
// 453:     private_class_method def self.formula_name(formula, full_name: false)
// 454:       full_name ? formula.full_name : formula.name
// 455:     end
// 456:
// 457:     sig {
// 458:       params(
// 459:         package_or_resource: T.any(Formula, Cask::Cask, Resource),
// 460:         status_str:          String,
// 461:         messages:            T.nilable(T::Array[String]),
// 462:         full_name:           T::Boolean,
// 463:         verbose:             T::Boolean,
// 464:       ).returns(T::Hash[Symbol, T.untyped])
// 465:     }
// 466:     def self.status_hash(package_or_resource, status_str, messages = nil, full_name: false, verbose: false)
// 467:       formula = package_or_resource if package_or_resource.is_a?(Formula)
// 468:       cask = package_or_resource if package_or_resource.is_a?(Cask::Cask)
// 469:       resource = package_or_resource if package_or_resource.is_a?(Resource)
// 470:
// 471:       status_hash = {}
// 472:       if formula
// 473:         status_hash[:formula] = formula_name(formula, full_name:)
// 474:       elsif cask
// 475:         status_hash[:cask] = cask_name(cask, full_name:)
// 476:       elsif resource
// 477:         status_hash[:resource] = resource.name
// 478:       end
// 479:       status_hash[:status] = status_str
// 480:       status_hash[:messages] = messages if messages.is_a?(Array)
// 481:
// 482:       status_hash[:meta] = {
// 483:         livecheck_defined: package_or_resource.livecheck_defined?,
// 484:       }
// 485:       status_hash[:meta][:head_only] = true if formula&.head_only?
// 486:
// 487:       status_hash
// 488:     end
// 489:
// 490:     # Formats and prints the livecheck result for a formula/cask/resource.
// 491:     sig { params(info: T::Hash[Symbol, T.untyped], verbose: T::Boolean, ambiguous_cask: T::Boolean).void }
// 492:     private_class_method def self.print_latest_version(info, verbose: false, ambiguous_cask: false)
// 493:       package_or_resource_s = info[:resource].present? ? "  " : ""
// 494:       package_or_resource_s += "#{Tty.blue}#{info[:formula] || info[:cask] || info[:resource]}#{Tty.reset}"
// 495:       package_or_resource_s += " (cask)" if ambiguous_cask
// 496:       package_or_resource_s += " (guessed)" if verbose && !info[:meta][:livecheck_defined]
// 497:
// 498:       current_s = if info[:version][:newer_than_upstream]
// 499:         "#{Tty.red}#{info[:version][:current]}#{Tty.reset}"
// 500:       else
// 501:         info[:version][:current]
// 502:       end
// 503:
// 504:       latest_s = if info[:version][:outdated]
// 505:         "#{Tty.green}#{info[:version][:latest]}#{Tty.reset}"
// 506:       else
// 507:         info[:version][:latest]
// 508:       end
// 509:
// 510:       puts "#{package_or_resource_s}: #{current_s} ==> #{latest_s}"
// 511:     end
// 512:
// 513:     # Prints the livecheck result for the resources of a given Formula.
// 514:     sig { params(info: T::Array[T::Hash[Symbol, T.untyped]], verbose: T::Boolean).void }
// 515:     private_class_method def self.print_resources_info(info, verbose: false)
// 516:       info.each do |r_info|
// 517:         if r_info[:status] && r_info[:messages]
// 518:           SkipConditions.print_skip_information(r_info)
// 519:         else
// 520:           print_latest_version(r_info, verbose:)
// 521:         end
// 522:       end
// 523:     end
// 524:
// 525:     sig {
// 526:       params(
// 527:         livecheck_url:       T.any(String, Symbol),
// 528:         package_or_resource: T.any(Formula, Cask::Cask, Resource),
// 529:       ).returns(String)
// 530:     }
// 531:     def self.livecheck_url_to_string(livecheck_url, package_or_resource)
// 532:       livecheck_url_string = case livecheck_url
// 533:       when String
// 534:         livecheck_url
// 535:       when :url
// 536:         package_or_resource.url&.to_s if package_or_resource.is_a?(Cask::Cask) || package_or_resource.is_a?(Resource)
// 537:       when :head, :stable
// 538:         package_or_resource.public_send(livecheck_url)&.url if package_or_resource.is_a?(Formula)
// 539:       when :homepage
// 540:         package_or_resource.homepage unless package_or_resource.is_a?(Resource)
// 541:       end
// 542:
// 543:       if livecheck_url.is_a?(Symbol) && !livecheck_url_string
// 544:         raise ArgumentError, "`url #{livecheck_url.inspect}` does not reference a checkable URL"
// 545:       end
// 546:
// 547:       livecheck_url_string
// 548:     end
// 549:
// 550:     # Returns an Array containing the formula/cask/resource URLs that can be used by livecheck.
// 551:     sig { params(package_or_resource: T.any(Formula, Cask::Cask, Resource)).returns(T::Array[String]) }
// 552:     def self.checkable_urls(package_or_resource)
// 553:       urls = []
// 554:
// 555:       case package_or_resource
// 556:       when Formula
// 557:         if package_or_resource.stable
// 558:           urls << T.must(package_or_resource.stable).url
// 559:           urls.concat(T.must(package_or_resource.stable).mirrors)
// 560:         end
// 561:         urls << T.must(package_or_resource.head).url if package_or_resource.head
// 562:         urls << package_or_resource.homepage if package_or_resource.homepage
// 563:       when Cask::Cask
// 564:         urls << package_or_resource.url.to_s if package_or_resource.url
// 565:         urls << package_or_resource.homepage if package_or_resource.homepage
// 566:       when Resource
// 567:         urls << package_or_resource.url
// 568:       else
// 569:         T.absurd(package_or_resource)
// 570:       end
// 571:
// 572:       urls.compact.uniq
// 573:     end
// 574:
// 575:     # livecheck should fetch a URL using brewed curl if the formula/cask
// 576:     # contains a `stable`/`url` or `head` URL `using: :homebrew_curl` that
// 577:     # shares the same host or uses it as a parent domain.
// 578:     sig { params(formula_or_cask: T.any(Formula, Cask::Cask), url: String).returns(T::Boolean) }
// 579:     def self.use_homebrew_curl?(formula_or_cask, url)
// 580:       host = url_host(url)
// 581:       return false unless host
// 582:
// 583:       homebrew_curl_hosts = case formula_or_cask
// 584:       when Formula
// 585:         [formula_or_cask.stable, formula_or_cask.head].filter_map do |spec|
// 586:           next unless spec
// 587:           next if spec.using != :homebrew_curl
// 588:           next unless (spec_url = spec.url)
// 589:
// 590:           url_host(spec_url)
// 591:         end
// 592:       when Cask::Cask
// 593:         cask_url = formula_or_cask.url
// 594:         return false if cask_url&.using != :homebrew_curl
// 595:
// 596:         [url_host(cask_url.to_s)].compact
// 597:       end
// 598:
// 599:       homebrew_curl_hosts.any? do |homebrew_curl_host|
// 600:         host == homebrew_curl_host ||
// 601:           host.end_with?(".#{homebrew_curl_host}") ||
// 602:           homebrew_curl_host.end_with?(".#{host}")
// 603:       end
// 604:     end
// 605:
// 606:     sig { params(url: String).returns(T.nilable(String)) }
// 607:     private_class_method def self.url_host(url)
// 608:       URI.parse(url).host&.downcase
// 609:     rescue URI::InvalidURIError
// 610:       nil
// 611:     end
// 612:
// 613:     # Identifies the latest version of the formula/cask and returns a Hash containing
// 614:     # the version information. Returns nil if a latest version couldn't be found.
// 615:     sig {
// 616:       params(
// 617:         formula_or_cask:            T.any(Formula, Cask::Cask),
// 618:         referenced_formula_or_cask: T.nilable(T.any(Formula, Cask::Cask)),
// 619:         livecheck_references:       T::Array[T.any(Formula, Cask::Cask)],
// 620:         json:                       T::Boolean,
// 621:         full_name:                  T::Boolean,
// 622:         verbose:                    T::Boolean,
// 623:         debug:                      T::Boolean,
// 624:       ).returns(T.nilable(T::Hash[Symbol, T.untyped]))
// 625:     }
// 626:     def self.latest_version(
// 627:       formula_or_cask,
// 628:       referenced_formula_or_cask: nil,
// 629:       livecheck_references: [],
// 630:       json: false, full_name: false, verbose: false, debug: false
// 631:     )
// 632:       formula = formula_or_cask if formula_or_cask.is_a?(Formula)
// 633:       cask = formula_or_cask if formula_or_cask.is_a?(Cask::Cask)
// 634:
// 635:       livecheck_defined = formula_or_cask.livecheck_defined?
// 636:       livecheck = formula_or_cask.livecheck
// 637:       referenced_livecheck = referenced_formula_or_cask&.livecheck
// 638:
// 639:       livecheck_options = livecheck.options || referenced_livecheck&.options
// 640:       livecheck_url_options = livecheck_options.url_options.compact
// 641:       livecheck_url = livecheck.url || referenced_livecheck&.url
// 642:       livecheck_regex = livecheck.regex || referenced_livecheck&.regex
// 643:       livecheck_strategy = livecheck.strategy || referenced_livecheck&.strategy
// 644:       livecheck_strategy_block = livecheck.strategy_block || referenced_livecheck&.strategy_block
// 645:       livecheck_throttle = livecheck.throttle || referenced_livecheck&.throttle
// 646:       livecheck_throttle_days = livecheck.throttle_days || referenced_livecheck&.throttle_days
// 647:
// 648:       referenced_package = referenced_formula_or_cask || formula_or_cask
// 649:
// 650:       livecheck_url_string = livecheck_url_to_string(livecheck_url, referenced_package) if livecheck_url
// 651:
// 652:       urls = [livecheck_url_string] if livecheck_url_string
// 653:       urls ||= checkable_urls(referenced_package)
// 654:
// 655:       if debug
// 656:         if formula
// 657:           puts "Formula:          #{formula_name(formula, full_name:)}"
// 658:           puts "Head only?:       true" if formula.head_only?
// 659:         elsif cask
// 660:           puts "Cask:             #{cask_name(formula_or_cask, full_name:)}"
// 661:         end
// 662:         puts "livecheck block?: #{livecheck_defined ? "Yes" : "No"}"
// 663:         if livecheck_throttle || livecheck_throttle_days
// 664:           throttle_items = []
// 665:           if livecheck_throttle
// 666:             throttle_items << "#{livecheck_throttle} #{Utils.pluralize("version", livecheck_throttle)}"
// 667:           end
// 668:           if livecheck_throttle_days
// 669:             throttle_items << "#{livecheck_throttle_days} #{Utils.pluralize("day", livecheck_throttle_days)}"
// 670:           end
// 671:           puts "Throttle:         #{throttle_items.join(" or ")}"
// 672:         end
// 673:
// 674:         livecheck_references.each do |ref_formula_or_cask|
// 675:           case ref_formula_or_cask
// 676:           when Formula
// 677:             puts "Formula Ref:      #{formula_name(ref_formula_or_cask, full_name:)}"
// 678:           when Cask::Cask
// 679:             puts "Cask Ref:         #{cask_name(ref_formula_or_cask, full_name:)}"
// 680:           end
// 681:         end
// 682:       end
// 683:
// 684:       checked_urls = []
// 685:       urls.each_with_index do |original_url, i|
// 686:         url = original_url
// 687:         next if checked_urls.include?(url)
// 688:
// 689:         strategies = Strategy.from_url(
// 690:           url,
// 691:           livecheck_strategy:,
// 692:           regex_provided:     livecheck_regex.present?,
// 693:           block_provided:     livecheck_strategy_block.present?,
// 694:         )
// 695:         strategy = Strategy.from_symbol(livecheck_strategy) || strategies.first
// 696:         next unless strategy
// 697:
// 698:         strategy_name = livecheck_strategy_names(strategy)
// 699:
// 700:         if strategy.respond_to?(:preprocess_url)
// 701:           url = strategy.preprocess_url(url)
// 702:           next if checked_urls.include?(url)
// 703:         end
// 704:
// 705:         if debug
// 706:           puts
// 707:           if livecheck_url.is_a?(Symbol)
// 708:             # This assumes the URL symbol will fit within the available space
// 709:             puts "URL (#{livecheck_url}):".ljust(18, " ") + original_url
// 710:           elsif original_url.present? && original_url != "None"
// 711:             puts "URL:              #{original_url}"
// 712:           end
// 713:           puts "URL (processed):  #{url}" if url != original_url
// 714:           puts "URL Options:      #{livecheck_url_options}" if livecheck_url_options.present?
// 715:           if strategies.present? && verbose
// 716:             puts "Strategies:       #{strategies.map { |s| livecheck_strategy_names(s) }.join(", ")}"
// 717:           end
// 718:           puts "Strategy:         #{strategy_name}" if strategy.present?
// 719:           puts "Regex:            #{livecheck_regex.inspect}" if livecheck_regex.present?
// 720:         end
// 721:
// 722:         if livecheck_strategy.present?
// 723:           if livecheck_url.blank? && strategy.method(:find_versions).parameters.include?([:keyreq, :url])
// 724:             odebug "#{strategy_name} strategy requires a URL"
// 725:             next
// 726:           elsif livecheck_strategy != :page_match && strategies.exclude?(strategy)
// 727:             odebug "#{strategy_name} strategy does not apply to this URL"
// 728:             next
// 729:           end
// 730:         end
// 731:
// 732:         next if strategy.blank?
// 733:
// 734:         if (livecheck_homebrew_curl = livecheck_options.homebrew_curl).nil?
// 735:           case strategy_name
// 736:           when "PageMatch", "HeaderMatch"
// 737:             if (homebrew_curl = use_homebrew_curl?(referenced_package, url))
// 738:               livecheck_options = livecheck_options.merge({ homebrew_curl: })
// 739:               livecheck_homebrew_curl = homebrew_curl
// 740:             end
// 741:           end
// 742:         end
// 743:         puts "Homebrew curl?:   #{livecheck_homebrew_curl ? "Yes" : "No"}" if debug && !livecheck_homebrew_curl.nil?
// 744:
// 745:         # Only use arguments that the strategy's `#find_versions` method
// 746:         # supports
// 747:         find_versions_parameters = livecheck_find_versions_parameters(strategy)
// 748:         strategy_args = {}
// 749:         strategy_args[:cask] = cask if find_versions_parameters.include?(:cask)
// 750:         strategy_args[:url] = url if find_versions_parameters.include?(:url)
// 751:         strategy_args[:regex] = livecheck_regex if find_versions_parameters.include?(:regex)
// 752:         strategy_args[:options] = livecheck_options if find_versions_parameters.include?(:options)
// 753:         strategy_args.compact!
// 754:
// 755:         strategy_data = strategy.find_versions(**strategy_args, &livecheck_strategy_block)
// 756:         match_version_map = strategy_data[:matches]
// 757:         regex = strategy_data[:regex]
// 758:         messages = strategy_data[:messages]
// 759:         checked_urls << url
// 760:
// 761:         if messages.is_a?(Array) && match_version_map.blank?
// 762:           puts messages unless json
// 763:           next if i + 1 < urls.length
// 764:
// 765:           return status_hash(formula_or_cask, "error", messages, full_name:, verbose:)
// 766:         end
// 767:
// 768:         if debug
// 769:           if strategy_data[:url].present? && strategy_data[:url] != url
// 770:             puts "URL (strategy):   #{strategy_data[:url]}"
// 771:           end
// 772:           puts "URL (final):      #{strategy_data[:final_url]}" if strategy_data[:final_url].present?
// 773:           if strategy_data[:regex].present? && strategy_data[:regex] != livecheck_regex
// 774:             puts "Regex (strategy): #{strategy_data[:regex].inspect}"
// 775:           end
// 776:           puts "Cached?:          Yes" if strategy_data[:cached] == true
// 777:         end
// 778:
// 779:         match_version_map.delete_if do |_match, version|
// 780:           next true if version.blank?
// 781:           next false if livecheck_defined
// 782:
// 783:           UNSTABLE_VERSION_KEYWORDS.any? do |rejection|
// 784:             version.to_s.include?(rejection)
// 785:           end
// 786:         end
// 787:         next if match_version_map.blank?
// 788:
// 789:         if debug
// 790:           puts
// 791:           puts "Matched Versions:"
// 792:
// 793:           if verbose
// 794:             match_version_map.each do |match, version|
// 795:               puts "#{match} => #{version.inspect}"
// 796:             end
// 797:           else
// 798:             puts match_version_map.values.join(", ")
// 799:           end
// 800:         end
// 801:
// 802:         version_info = {
// 803:           latest: Version.new(match_version_map.values.max_by { |v| LivecheckVersion.create(formula_or_cask, v) }),
// 804:         }
// 805:
// 806:         if livecheck_throttle || livecheck_throttle_days
// 807:           throttled_match_version_map = if livecheck_throttle
// 808:             match_version_map.select do |_match, version|
// 809:               throttle_allows_bump?(formula_or_cask, version, throttle_rate: livecheck_throttle)
// 810:             end
// 811:           else
// 812:             {}
// 813:           end
// 814:
// 815:           if livecheck_throttle_days &&
// 816:              throttle_allows_bump?(formula_or_cask, version_info[:latest], throttle_days: livecheck_throttle_days)
// 817:             version_info[:latest_throttled] = version_info[:latest]
// 818:           elsif throttled_match_version_map.present?
// 819:             version_info[:latest_throttled] = Version.new(
// 820:               throttled_match_version_map.values.max_by { |v| LivecheckVersion.create(formula_or_cask, v) },
// 821:             )
// 822:           else
// 823:             version_info[:latest_throttled] = nil
// 824:           end
// 825:
// 826:           if debug
// 827:             puts
// 828:             puts "Matched Throttled Versions:"
// 829:
// 830:             if verbose
// 831:               throttled_match_version_map.each do |match, version|
// 832:                 puts "#{match} => #{version.inspect}"
// 833:               end
// 834:             elsif throttled_match_version_map.present?
// 835:               puts throttled_match_version_map.values.join(", ")
// 836:             end
// 837:
// 838:             if version_info[:latest_throttled] == version_info[:latest] && throttled_match_version_map.blank?
// 839:               puts "#{version_info[:latest_throttled]} (throttle interval elapsed)"
// 840:             end
// 841:           end
// 842:         end
// 843:
// 844:         if json && verbose
// 845:           version_info[:meta] = {}
// 846:
// 847:           if livecheck_references.present?
// 848:             version_info[:meta][:references] = livecheck_references.map do |ref_formula_or_cask|
// 849:               case ref_formula_or_cask
// 850:               when Formula
// 851:                 { formula: formula_name(ref_formula_or_cask, full_name:) }
// 852:               when Cask::Cask
// 853:                 { cask: cask_name(ref_formula_or_cask, full_name:) }
// 854:               end
// 855:             end
// 856:           end
// 857:
// 858:           if url != "None"
// 859:             version_info[:meta][:url] = {}
// 860:             version_info[:meta][:url][:symbol] = livecheck_url if livecheck_url.is_a?(Symbol) && livecheck_url_string
// 861:             version_info[:meta][:url][:original] = original_url
// 862:             version_info[:meta][:url][:processed] = url if url != original_url
// 863:             if strategy_data[:url].present? && strategy_data[:url] != url
// 864:               version_info[:meta][:url][:strategy] = strategy_data[:url]
// 865:             end
// 866:             version_info[:meta][:url][:final] = strategy_data[:final_url] if strategy_data[:final_url]
// 867:             version_info[:meta][:url][:options] = livecheck_url_options if livecheck_url_options.present?
// 868:           end
// 869:           version_info[:meta][:strategy] = strategy_name if strategy.present?
// 870:           version_info[:meta][:strategies] = strategies.map { |s| livecheck_strategy_names(s) } if strategies.present?
// 871:           version_info[:meta][:regex] = regex.inspect if regex.present?
// 872:           version_info[:meta][:cached] = true if strategy_data[:cached] == true
// 873:           version_info[:meta][:throttle] = livecheck_throttle if livecheck_throttle
// 874:           version_info[:meta][:throttle_days] = livecheck_throttle_days if livecheck_throttle_days
// 875:
// 876:           version_info[:content] = strategy_data[:content] if strategy_data[:content] && strategy_name == "Pypi"
// 877:         end
// 878:
// 879:         return version_info
// 880:       end
// 881:       nil
// 882:     end
// 883:
// 884:     # Identifies the latest version of a resource and returns a Hash containing the
// 885:     # version information. Returns nil if a latest version couldn't be found.
// 886:     sig {
// 887:       params(
// 888:         resource:       Resource,
// 889:         formula_latest: String,
// 890:         json:           T::Boolean,
// 891:         full_name:      T::Boolean,
// 892:         debug:          T::Boolean,
// 893:         quiet:          T::Boolean,
// 894:         verbose:        T::Boolean,
// 895:       ).returns(T::Hash[Symbol, T.untyped])
// 896:     }
// 897:     def self.resource_version(
// 898:       resource,
// 899:       formula_latest,
// 900:       json: false,
// 901:       full_name: false,
// 902:       debug: false,
// 903:       quiet: false,
// 904:       verbose: false
// 905:     )
// 906:       livecheck_defined = resource.livecheck_defined?
// 907:
// 908:       if debug
// 909:         puts "\n\n"
// 910:         puts "Resource:         #{resource.name}"
// 911:         puts "livecheck block?: #{livecheck_defined ? "Yes" : "No"}"
// 912:       end
// 913:
// 914:       resource_version_info = {}
// 915:
// 916:       livecheck = resource.livecheck
// 917:       livecheck_options = livecheck.options
// 918:       livecheck_url_options = livecheck_options.url_options.compact
// 919:       livecheck_reference = livecheck.formula
// 920:       livecheck_url = livecheck.url
// 921:       livecheck_regex = livecheck.regex
// 922:       livecheck_strategy = livecheck.strategy
// 923:       livecheck_strategy_block = livecheck.strategy_block
// 924:
// 925:       livecheck_url_string = livecheck_url_to_string(livecheck_url, resource) if livecheck_url
// 926:
// 927:       urls = [livecheck_url_string] if livecheck_url_string
// 928:       urls = ["None"] if livecheck_reference == :parent
// 929:       urls ||= checkable_urls(resource)
// 930:
// 931:       checked_urls = []
// 932:       urls.each_with_index do |original_url, i|
// 933:         url = original_url.gsub(Constants::LATEST_VERSION, formula_latest)
// 934:         next if checked_urls.include?(url)
// 935:
// 936:         strategies = Strategy.from_url(
// 937:           url,
// 938:           livecheck_strategy:,
// 939:           regex_provided:     livecheck_regex.present?,
// 940:           block_provided:     livecheck_strategy_block.present?,
// 941:         )
// 942:         strategy = Strategy.from_symbol(livecheck_strategy) || strategies.first
// 943:         next if strategy.blank? && livecheck_reference != :parent
// 944:
// 945:         strategy_name = livecheck_strategy_names(strategy) if strategy.present?
// 946:
// 947:         if strategy.respond_to?(:preprocess_url)
// 948:           url = strategy.preprocess_url(url)
// 949:           next if checked_urls.include?(url)
// 950:         end
// 951:
// 952:         if debug
// 953:           puts
// 954:           if livecheck_url.is_a?(Symbol)
// 955:             # This assumes the URL symbol will fit within the available space
// 956:             puts "URL (#{livecheck_url}):".ljust(18, " ") + original_url
// 957:           elsif original_url.present? && original_url != "None"
// 958:             puts "URL:              #{original_url}"
// 959:           end
// 960:           puts "URL (processed):  #{url}" if url != original_url
// 961:           puts "URL Options:      #{livecheck_url_options}" if livecheck_url_options.present?
// 962:           if strategies.present? && verbose
// 963:             puts "Strategies:       #{strategies.map { |s| livecheck_strategy_names(s) }.join(", ")}"
// 964:           end
// 965:           puts "Strategy:         #{strategy_name}" if strategy.present?
// 966:           puts "Regex:            #{livecheck_regex.inspect}" if livecheck_regex.present?
// 967:           if livecheck_reference == :parent
// 968:             resource_owner = resource.owner
// 969:             raise "Resource owner is nil" if resource_owner.nil?
// 970:
// 971:             formula = if full_name
// 972:               T.cast(resource_owner, ::Formula).full_name
// 973:             else
// 974:               resource_owner.name
// 975:             end
// 976:             puts "Formula Ref:      #{formula} (parent)"
// 977:           end
// 978:         end
// 979:
// 980:         if livecheck_strategy.present?
// 981:           if livecheck_url.blank? && strategy.method(:find_versions).parameters.include?([:keyreq, :url])
// 982:             odebug "#{strategy_name} strategy requires a URL"
// 983:             next
// 984:           elsif livecheck_strategy != :page_match && strategies.exclude?(strategy)
// 985:             odebug "#{strategy_name} strategy does not apply to this URL"
// 986:             next
// 987:           end
// 988:         end
// 989:         puts if debug && strategy.blank? && livecheck_reference != :parent
// 990:         next if strategy.blank? && livecheck_reference != :parent
// 991:
// 992:         if debug && !(livecheck_homebrew_curl = livecheck_options.homebrew_curl).nil?
// 993:           puts "Homebrew curl?:   #{livecheck_homebrew_curl ? "Yes" : "No"}"
// 994:         end
// 995:
// 996:         if livecheck_reference == :parent
// 997:           match_version_map = { formula_latest => Version.new(formula_latest) }
// 998:           cached = true
// 999:         else
// 1000:           # Only use arguments that the strategy's `#find_versions` method
// 1001:           # supports
// 1002:           find_versions_parameters = livecheck_find_versions_parameters(strategy)
// 1003:           strategy_args = {}
// 1004:           strategy_args[:url] = url if find_versions_parameters.include?(:url)
// 1005:           strategy_args[:regex] = livecheck_regex if find_versions_parameters.include?(:regex)
// 1006:           strategy_args[:options] = livecheck_options if find_versions_parameters.include?(:options)
// 1007:           strategy_args.compact!
// 1008:
// 1009:           strategy_data = strategy.find_versions(**strategy_args, &livecheck_strategy_block)
// 1010:           match_version_map = strategy_data[:matches]
// 1011:           regex = strategy_data[:regex]
// 1012:           messages = strategy_data[:messages]
// 1013:           cached = strategy_data[:cached]
// 1014:         end
// 1015:
// 1016:         checked_urls << url
// 1017:
// 1018:         if messages.is_a?(Array) && match_version_map.blank?
// 1019:           puts messages unless json
// 1020:           next if i + 1 < urls.length
// 1021:
// 1022:           return status_hash(resource, "error", messages, verbose:)
// 1023:         end
// 1024:
// 1025:         if debug
// 1026:           if strategy_data&.dig(:url).present? && strategy_data[:url] != url
// 1027:             puts "URL (strategy):   #{strategy_data[:url]}"
// 1028:           end
// 1029:           puts "URL (final):      #{strategy_data[:final_url]}" if strategy_data&.dig(:final_url).present?
// 1030:           if strategy_data&.dig(:regex).present? && strategy_data[:regex] != livecheck_regex
// 1031:             puts "Regex (strategy): #{strategy_data[:regex].inspect}"
// 1032:           end
// 1033:           puts "Cached?:          Yes" if cached == true
// 1034:         end
// 1035:
// 1036:         match_version_map.delete_if do |_match, version|
// 1037:           next true if version.blank?
// 1038:           next false if livecheck_defined
// 1039:
// 1040:           UNSTABLE_VERSION_KEYWORDS.any? do |rejection|
// 1041:             version.to_s.include?(rejection)
// 1042:           end
// 1043:         end
// 1044:         next if match_version_map.blank?
// 1045:
// 1046:         if debug
// 1047:           puts
// 1048:           puts "Matched Versions:"
// 1049:
// 1050:           if verbose
// 1051:             match_version_map.each do |match, version|
// 1052:               puts "#{match} => #{version.inspect}"
// 1053:             end
// 1054:           else
// 1055:             puts match_version_map.values.join(", ")
// 1056:           end
// 1057:         end
// 1058:
// 1059:         res_current = T.must(resource.version)
// 1060:         res_latest = Version.new(match_version_map.values.max_by { |v| LivecheckVersion.create(resource, v) })
// 1061:
// 1062:         return status_hash(resource, "error", [NO_VERSIONS_MSG], verbose:) if res_latest.blank?
// 1063:
// 1064:         is_outdated = res_current < res_latest
// 1065:         is_newer_than_upstream = res_current > res_latest
// 1066:
// 1067:         resource_version_info = {
// 1068:           resource: resource.name,
// 1069:           version:  {
// 1070:             current:             res_current.to_s,
// 1071:             latest:              res_latest.to_s,
// 1072:             outdated:            is_outdated,
// 1073:             newer_than_upstream: is_newer_than_upstream,
// 1074:           },
// 1075:         }
// 1076:
// 1077:         resource_version_info[:meta] = {
// 1078:           livecheck_defined: livecheck_defined,
// 1079:         }
// 1080:         if livecheck_reference == :parent
// 1081:           resource_owner = resource.owner
// 1082:           raise "Resource owner is nil" if resource_owner.nil?
// 1083:
// 1084:           formula = if full_name
// 1085:             T.cast(resource_owner, ::Formula).full_name
// 1086:           else
// 1087:             resource_owner.name
// 1088:           end
// 1089:           resource_version_info[:meta][:references] =
// 1090:             [{ formula:, symbol: :parent }]
// 1091:         end
// 1092:         if url != "None"
// 1093:           resource_version_info[:meta][:url] = {}
// 1094:           if livecheck_url.is_a?(Symbol) && livecheck_url_string
// 1095:             resource_version_info[:meta][:url][:symbol] = livecheck_url
// 1096:           end
// 1097:           resource_version_info[:meta][:url][:original] = original_url
// 1098:           resource_version_info[:meta][:url][:processed] = url if url != original_url
// 1099:           if strategy_data&.dig(:url).present? && strategy_data[:url] != url
// 1100:             resource_version_info[:meta][:url][:strategy] = strategy_data[:url]
// 1101:           end
// 1102:           resource_version_info[:meta][:url][:final] = strategy_data[:final_url] if strategy_data&.dig(:final_url)
// 1103:           resource_version_info[:meta][:url][:options] = livecheck_url_options if livecheck_url_options.present?
// 1104:         end
// 1105:         resource_version_info[:meta][:strategy] = strategy_name if strategy.present?
// 1106:         if strategies.present?
// 1107:           resource_version_info[:meta][:strategies] = strategies.map { |s| livecheck_strategy_names(s) }
// 1108:         end
// 1109:         resource_version_info[:meta][:regex] = regex.inspect if regex.present?
// 1110:         resource_version_info[:meta][:cached] = true if cached == true
// 1111:       rescue => e
// 1112:         Homebrew.failed = true
// 1113:         if json
// 1114:           status_hash(resource, "error", [e.to_s], verbose:)
// 1115:         elsif !quiet
// 1116:           onoe "#{Tty.blue}#{resource.name}#{Tty.reset}: #{e}"
// 1117:           if debug && !e.is_a?(Livecheck::Error)
// 1118:             require "utils/backtrace"
// 1119:             $stderr.puts Utils::Backtrace.clean(e)
// 1120:           end
// 1121:           nil
// 1122:         end
// 1123:       end
// 1124:       resource_version_info
// 1125:     end
// 1126:
// 1127:     sig {
// 1128:       params(
// 1129:         formula_or_cask: T.any(Formula, Cask::Cask),
// 1130:         version:         T.any(String, Version),
// 1131:         throttle_rate:   T.nilable(Integer),
// 1132:         throttle_days:   T.nilable(Integer),
// 1133:       ).returns(T::Boolean)
// 1134:     }
// 1135:     def self.throttle_allows_bump?(formula_or_cask, version, throttle_rate: nil, throttle_days: nil)
// 1136:       return true if throttle_rate.nil? && throttle_days.nil?
// 1137:
// 1138:       unless throttle_rate.nil?
// 1139:         version = Version.new(version) unless version.is_a?(Version)
// 1140:         return true if version.patch.to_i.modulo(throttle_rate).zero?
// 1141:       end
// 1142:
// 1143:       !throttle_days.nil? && throttle_interval_elapsed?(formula_or_cask, throttle_days)
// 1144:     end
// 1145:
// 1146:     sig { params(package_or_resource: T.any(Formula, Cask::Cask)).returns(T.nilable(Integer)) }
// 1147:     def self.formula_or_cask_last_updated_timestamp(package_or_resource)
// 1148:       tap = package_or_resource.tap
// 1149:       return if tap.nil?
// 1150:       return unless tap.git?
// 1151:       return unless Utils::Git.available?
// 1152:
// 1153:       if package_or_resource.is_a?(Formula)
// 1154:         timestamp = formula_last_version_update_timestamp(package_or_resource, tap:)
// 1155:         return timestamp if timestamp.present?
// 1156:       end
// 1157:
// 1158:       formula_or_cask_last_commit_timestamp(package_or_resource, tap)
// 1159:     end
// 1160:
// 1161:     sig { params(formula: Formula, tap: Tap).returns(T.nilable(Integer)) }
// 1162:     private_class_method def self.formula_last_version_update_timestamp(formula, tap:)
// 1163:       stable = formula.stable
// 1164:       return if stable.blank?
// 1165:
// 1166:       version_update_revision = find_version_update_revision(formula, stable.version)
// 1167:       return if version_update_revision.nil?
// 1168:
// 1169:       timestamp_for_revision(tap.path, version_update_revision)
// 1170:     end
// 1171:
// 1172:     sig { params(formula: Formula, current_version: Version).returns(T.nilable(String)) }
// 1173:     private_class_method def self.find_version_update_revision(formula, current_version)
// 1174:       version_update_revision = T.let(nil, T.nilable(String))
// 1175:       found_current_version = T.let(false, T::Boolean)
// 1176:
// 1177:       formula_versions = FormulaVersions.new(formula)
// 1178:       current_version = origin_stable_version(formula, formula_versions) || current_version
// 1179:
// 1180:       formula_versions.rev_list("HEAD") do |revision, path|
// 1181:         formula_versions.formula_at_revision(revision, path) do |historical_formula|
// 1182:           historical_stable = historical_formula.stable
// 1183:           next if historical_stable.blank?
// 1184:
// 1185:           if historical_stable.version == current_version
// 1186:             found_current_version = true
// 1187:             version_update_revision = revision
// 1188:           elsif found_current_version
// 1189:             return version_update_revision
// 1190:           end
// 1191:         end
// 1192:       rescue MacOSVersion::Error, LegacyDSLError
// 1193:         break
// 1194:       end
// 1195:
// 1196:       version_update_revision
// 1197:     end
// 1198:
// 1199:     sig { params(formula: Formula, formula_versions: FormulaVersions).returns(T.nilable(Version)) }
// 1200:     private_class_method def self.origin_stable_version(formula, formula_versions)
// 1201:       tap = formula.tap
// 1202:       return if tap.nil?
// 1203:
// 1204:       revision = Utils.popen_read(
// 1205:         Utils::Git.git, "rev-parse", "origin/HEAD",
// 1206:         chdir: tap.path
// 1207:       ).chomp.presence
// 1208:       return if revision.nil?
// 1209:
// 1210:       relative_path = formula.path.relative_path_from(tap.path).to_s
// 1211:       version = T.let(nil, T.nilable(Version))
// 1212:       formula_versions.formula_at_revision(revision, relative_path) do |historical_formula|
// 1213:         version = historical_formula.stable&.version
// 1214:       end
// 1215:       version
// 1216:     rescue MacOSVersion::Error, LegacyDSLError
// 1217:       nil
// 1218:     end
// 1219:
// 1220:     sig {
// 1221:       params(package_or_resource: T.any(Formula, Cask::Cask), tap: Tap).returns(T.nilable(Integer))
// 1222:     }
// 1223:     private_class_method def self.formula_or_cask_last_commit_timestamp(package_or_resource, tap)
// 1224:       sourcefile = case package_or_resource
// 1225:       when Formula
// 1226:         package_or_resource.path
// 1227:       when Cask::Cask
// 1228:         package_or_resource.sourcefile_path
// 1229:       end
// 1230:       return if sourcefile.nil?
// 1231:
// 1232:       default_branch = Utils.popen_read(
// 1233:         Utils::Git.git,
// 1234:         "symbolic-ref",
// 1235:         "refs/remotes/origin/HEAD",
// 1236:         "--short",
// 1237:         chdir: tap.path,
// 1238:         err:   :close,
// 1239:       ).chomp.presence
// 1240:
// 1241:       # A detached checkout, as used for pull request CI, has no local branch,
// 1242:       # so fall back to the remote-tracking ref and finally the current commit.
// 1243:       refs = [
// 1244:         default_branch,
// 1245:         default_branch&.delete_prefix("origin/"),
// 1246:         "origin/HEAD",
// 1247:         "origin/main",
// 1248:         "main",
// 1249:         "HEAD",
// 1250:       ].compact.uniq
// 1251:
// 1252:       relative_sourcefile = sourcefile.relative_path_from(tap.path).to_s
// 1253:       timestamp = refs.lazy.filter_map do |ref|
// 1254:         Utils.popen_read(
// 1255:           Utils::Git.git,
// 1256:           "log",
// 1257:           ref,
// 1258:           "-1",
// 1259:           "--format=%ct",
// 1260:           "--",
// 1261:           relative_sourcefile,
// 1262:           chdir: tap.path,
// 1263:           err:   :close,
// 1264:         ).chomp.presence
// 1265:       end.first
// 1266:       return if timestamp.nil?
// 1267:
// 1268:       Integer(timestamp, exception: false)
// 1269:     rescue ArgumentError
// 1270:       nil
// 1271:     end
// 1272:
// 1273:     sig { params(repository_path: Pathname, revision: String).returns(T.nilable(Integer)) }
// 1274:     private_class_method def self.timestamp_for_revision(repository_path, revision)
// 1275:       timestamp = Utils.popen_read(
// 1276:         Utils::Git.git,
// 1277:         "show",
// 1278:         "-s",
// 1279:         "--format=%ct",
// 1280:         revision,
// 1281:         chdir: repository_path,
// 1282:       ).chomp.presence
// 1283:       return if timestamp.nil?
// 1284:
// 1285:       Integer(timestamp, exception: false)
// 1286:     rescue ArgumentError
// 1287:       nil
// 1288:     end
// 1289:
// 1290:     sig { params(package_or_resource: T.any(Formula, Cask::Cask), days: Integer).returns(T::Boolean) }
// 1291:     def self.throttle_interval_elapsed?(package_or_resource, days)
// 1292:       return false if days <= 0
// 1293:
// 1294:       last_updated_timestamp = formula_or_cask_last_updated_timestamp(package_or_resource)
// 1295:       return false if last_updated_timestamp.nil?
// 1296:
// 1297:       elapsed_seconds = Time.now.to_i - last_updated_timestamp
// 1298:       elapsed_seconds >= (days * 24 * 60 * 60)
// 1299:     end
// 1300:   end
// 1301: end
