module livecheck

import ruby
import net.urllib
import os
import time

// Translated from Homebrew/brew `livecheck/livecheck.rb`.
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
			kind
		} else if value.type_name.contains('Cask') {
			'cask'
		} else if value.type_name == 'Resource' { 'resource' } else { 'formula' }
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
