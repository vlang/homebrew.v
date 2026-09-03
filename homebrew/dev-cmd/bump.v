module dev_cmd

import brew_runtime
import homebrew as brew
import json2

// Translated from Homebrew/brew `dev-cmd/bump.rb`.
// The original source is retained below for source-level traceability.

pub enum BumpPackageKind {
	formula
	cask
}

pub struct BumpPullRequest {
pub:
	title   string
	url     string
	version string
}

pub struct BumpRelease {
pub:
	version         string
	released_at     i64
	prerelease      bool
	yanked          bool
	artifact_suffix string
	platform        string = 'ruby'
}

pub struct BumpResource {
pub:
	name                string
	current_version     string
	livecheck_defined   bool
	livecheck_skip      bool
	tracks_parent       bool
	latest_version      string
	livecheck_error     bool
	outdated            bool
	newer_than_upstream bool
}

pub struct BumpPackage {
pub:
	kind                       BumpPackageKind
	name                       string
	full_name                  string
	tap_name                   string
	tap_remote_repository      string
	version                    string
	current_versions           map[string]string
	latest_versions            map[string]string
	latest_throttled_versions  map[string]string
	deprecated                 map[string]bool
	disabled                   bool
	head_only                  bool
	latest_cask                bool
	allow_bump                 bool = true
	on_system_blocks           bool
	supported_archs            []string
	livecheck_defined          bool
	livecheck_skip_status      string
	livecheck_skip_messages    []string
	livecheck_strategy         string
	livecheck_original_url     string
	livecheck_artifact_suffix  string
	livecheck_throttled        bool
	releases                   []BumpRelease
	repology_latest            string
	installed                  bool
	autobumped                 bool
	resources                  []BumpResource
	pull_requests              []BumpPullRequest
	synced_versions            map[string]string
	throttle                   bool
	github_api_errors          int
	github_authentication_fail bool
	too_many_open_prs          bool
}

pub struct BumpTap {
pub:
	name           string
	official       bool
	autobump_names []string
}

pub struct BumpOptions {
pub:
	full_name        bool
	no_pull_requests bool
	auto             bool
	no_autobump      bool
	formula_only     bool
	cask_only        bool
	eval_all         bool
	tap_trusted      bool
	repology         bool
	tap              string
	installed        bool
	no_fork          bool
	open_pr          bool
	start_with       string
	bump_synced      bool
	ci               bool
	named            []string
}

pub struct BumpRunRequest {
pub:
	options  BumpOptions
	packages []BumpPackage
	taps     []BumpTap
}

pub struct BumpVersions {
pub:
	general string
	arm     string
	intel   string
}

pub struct BumpVersionComparison {
pub:
	multiple_current    bool
	multiple_new        bool
	newer_than_upstream map[string]bool
}

pub struct BumpResourceVersionInfo {
pub:
	name                string
	current_version     string
	latest_version      string
	has_latest_version  bool
	outdated            bool
	newer_than_upstream bool
}

pub struct BumpVersionInfo {
pub:
	kind                          BumpPackageKind
	deprecated                    map[string]bool
	multiple_current              bool
	multiple_new                  bool
	version_name                  string
	current_version               BumpVersions
	new_version                   BumpVersions
	resource_versions             []BumpResourceVersionInfo
	repology_latest               string
	newer_than_upstream           map[string]bool
	cooldown_skipped_versions     map[string]string
	duplicate_pull_requests       string
	maybe_duplicate_pull_requests string
}

pub struct BumpCooldownInfo {
pub:
	latest          string
	strategy        string
	original_url    string
	artifact_suffix string
	releases        []BumpRelease
	now             i64
	cooldown_days   int = 7
}

pub struct BumpLivecheckResult {
pub:
	version          string
	cooldown_skipped string
	is_message       bool
}

pub struct BumpDisplayResult {
pub:
	name            string
	lines           []string
	bump_pr_command []string
	failed          bool
	error           string
}

pub struct BumpHandleResult {
pub:
	displays []BumpDisplayResult
	output   []string
	failed   bool
	error    string
}

pub struct BumpRunResult {
pub:
	selected []string
	handled  BumpHandleResult
	error    string
}

fn bump_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

fn bump_map_string(values map[string]brew_runtime.Value, key string, fallback string) string {
	return (values[key] or { brew_runtime.string_value(fallback) }).as_string()
}

fn bump_map_bool(values map[string]brew_runtime.Value, key string, fallback bool) bool {
	value := values[key] or { return fallback }
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn bump_map_int(values map[string]brew_runtime.Value, key string, fallback int) int {
	value := values[key] or { return fallback }
	return if value.type_name == 'Integer' { int(value.int_data) } else { fallback }
}

fn bump_string_map_from_value(value brew_runtime.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in value.map_data {
		result[key] = item.as_string()
	}
	return result
}

fn bump_bool_map_from_value(value brew_runtime.Value) map[string]bool {
	mut result := map[string]bool{}
	for key, item in value.map_data {
		result[key] = item.bool_data
	}
	return result
}

fn bump_string_map_value(values map[string]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

fn bump_bool_map_value(values map[string]bool) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.bool_value(value)
	}
	return brew_runtime.map_value(result)
}

fn bump_release_value(release BumpRelease) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Release'
		repr: release.version
		map_data: {
			'version':         brew_runtime.string_value(release.version)
			'released_at':     brew_runtime.int_value(release.released_at)
			'prerelease':      brew_runtime.bool_value(release.prerelease)
			'yanked':          brew_runtime.bool_value(release.yanked)
			'artifact_suffix': brew_runtime.string_value(release.artifact_suffix)
			'platform':        brew_runtime.string_value(release.platform)
		}
	}
}

fn bump_release_from_value(value brew_runtime.Value) BumpRelease {
	values := value.map_data.clone()
	return BumpRelease{
		version: bump_map_string(values, 'version', value.repr)
		released_at: (values['released_at'] or { brew_runtime.int_value(0) }).int_data
		prerelease: bump_map_bool(values, 'prerelease', false)
		yanked: bump_map_bool(values, 'yanked', false)
		artifact_suffix: bump_map_string(values, 'artifact_suffix', '')
		platform: bump_map_string(values, 'platform', 'ruby')
	}
}

fn bump_resource_value(resource BumpResource) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Resource'
		repr: resource.name
		map_data: {
			'name':                brew_runtime.string_value(resource.name)
			'current_version':     brew_runtime.string_value(resource.current_version)
			'livecheck_defined':   brew_runtime.bool_value(resource.livecheck_defined)
			'livecheck_skip':      brew_runtime.bool_value(resource.livecheck_skip)
			'tracks_parent':       brew_runtime.bool_value(resource.tracks_parent)
			'latest_version':      brew_runtime.string_value(resource.latest_version)
			'livecheck_error':     brew_runtime.bool_value(resource.livecheck_error)
			'outdated':            brew_runtime.bool_value(resource.outdated)
			'newer_than_upstream': brew_runtime.bool_value(resource.newer_than_upstream)
		}
	}
}

fn bump_resource_from_value(value brew_runtime.Value) BumpResource {
	values := value.map_data.clone()
	return BumpResource{
		name: bump_map_string(values, 'name', value.repr)
		current_version: bump_map_string(values, 'current_version', '')
		livecheck_defined: bump_map_bool(values, 'livecheck_defined', false)
		livecheck_skip: bump_map_bool(values, 'livecheck_skip', false)
		tracks_parent: bump_map_bool(values, 'tracks_parent', false)
		latest_version: bump_map_string(values, 'latest_version', '')
		livecheck_error: bump_map_bool(values, 'livecheck_error', false)
		outdated: bump_map_bool(values, 'outdated', false)
		newer_than_upstream: bump_map_bool(values, 'newer_than_upstream', false)
	}
}

pub fn bump_package_value(package BumpPackage) brew_runtime.Value {
	mut releases := []brew_runtime.Value{}
	for release in package.releases {
		releases << bump_release_value(release)
	}
	mut resources := []brew_runtime.Value{}
	for resource in package.resources {
		resources << bump_resource_value(resource)
	}
	mut pull_requests := []brew_runtime.Value{}
	for pull_request in package.pull_requests {
		pull_requests << brew_runtime.map_value({
			'title':   brew_runtime.string_value(pull_request.title)
			'url':     brew_runtime.string_value(pull_request.url)
			'version': brew_runtime.string_value(pull_request.version)
		})
	}
	return brew_runtime.Value{
		type_name: if package.kind == .formula { 'Formula' } else { 'Cask' }
		repr: package.name
		map_data: {
			'kind':                       brew_runtime.string_value(package.kind.str())
			'name':                       brew_runtime.string_value(package.name)
			'full_name':                  brew_runtime.string_value(package.full_name)
			'tap_name':                   brew_runtime.string_value(package.tap_name)
			'tap_remote_repository':      brew_runtime.string_value(package.tap_remote_repository)
			'version':                    brew_runtime.string_value(package.version)
			'current_versions':           bump_string_map_value(package.current_versions)
			'latest_versions':            bump_string_map_value(package.latest_versions)
			'latest_throttled_versions':  bump_string_map_value(package.latest_throttled_versions)
			'deprecated':                 bump_bool_map_value(package.deprecated)
			'disabled':                   brew_runtime.bool_value(package.disabled)
			'head_only':                  brew_runtime.bool_value(package.head_only)
			'latest_cask':                brew_runtime.bool_value(package.latest_cask)
			'allow_bump':                 brew_runtime.bool_value(package.allow_bump)
			'on_system_blocks':           brew_runtime.bool_value(package.on_system_blocks)
			'supported_archs':            brew_runtime.string_array_value(package.supported_archs)
			'livecheck_defined':          brew_runtime.bool_value(package.livecheck_defined)
			'livecheck_skip_status':      brew_runtime.string_value(package.livecheck_skip_status)
			'livecheck_skip_messages':    brew_runtime.string_array_value(package.livecheck_skip_messages)
			'livecheck_strategy':         brew_runtime.string_value(package.livecheck_strategy)
			'livecheck_original_url':     brew_runtime.string_value(package.livecheck_original_url)
			'livecheck_artifact_suffix':  brew_runtime.string_value(package.livecheck_artifact_suffix)
			'livecheck_throttled':        brew_runtime.bool_value(package.livecheck_throttled)
			'releases':                   brew_runtime.array_value(releases)
			'repology_latest':            brew_runtime.string_value(package.repology_latest)
			'installed':                  brew_runtime.bool_value(package.installed)
			'autobumped':                 brew_runtime.bool_value(package.autobumped)
			'resources':                  brew_runtime.array_value(resources)
			'pull_requests':              brew_runtime.array_value(pull_requests)
			'synced_versions':            bump_string_map_value(package.synced_versions)
			'throttle':                   brew_runtime.bool_value(package.throttle)
			'github_api_errors':          brew_runtime.int_value(package.github_api_errors)
			'github_authentication_fail': brew_runtime.bool_value(package.github_authentication_fail)
			'too_many_open_prs':          brew_runtime.bool_value(package.too_many_open_prs)
		}
	}
}

fn bump_package_from_value(value brew_runtime.Value) !BumpPackage {
	if value.type_name !in ['Formula', 'Cask', 'Hash', 'BumpPackage'] {
		return error('expected Formula or Cask, got ${value.type_name}')
	}
	values := value.map_data.clone()
	mut releases := []BumpRelease{}
	for release in (values['releases'] or { brew_runtime.array_value([]) }).as_array() or { [] } {
		releases << bump_release_from_value(release)
	}
	mut resources := []BumpResource{}
	for resource in (values['resources'] or { brew_runtime.array_value([]) }).as_array() or { [] } {
		resources << bump_resource_from_value(resource)
	}
	mut pull_requests := []BumpPullRequest{}
	for pull_request in (values['pull_requests'] or { brew_runtime.array_value([]) }).as_array() or { [] } {
		pr_values := pull_request.map_data.clone()
		pull_requests << BumpPullRequest{
			title: bump_map_string(pr_values, 'title', '')
			url: bump_map_string(pr_values, 'url', '')
			version: bump_map_string(pr_values, 'version', '')
		}
	}
	kind_text := bump_map_string(values, 'kind', if value.type_name == 'Cask' {
		'cask'
	} else {
		'formula'
	})
	return BumpPackage{
		kind: if kind_text == 'cask' { .cask } else { .formula }
		name: bump_map_string(values, 'name', value.repr)
		full_name: bump_map_string(values, 'full_name', value.repr)
		tap_name: bump_map_string(values, 'tap_name', '')
		tap_remote_repository: bump_map_string(values, 'tap_remote_repository', '')
		version: bump_map_string(values, 'version', '')
		current_versions: bump_string_map_from_value(values['current_versions'] or { brew_runtime.map_value({}) })
		latest_versions: bump_string_map_from_value(values['latest_versions'] or { brew_runtime.map_value({}) })
		latest_throttled_versions: bump_string_map_from_value(values['latest_throttled_versions'] or { brew_runtime.map_value({}) })
		deprecated: bump_bool_map_from_value(values['deprecated'] or { brew_runtime.map_value({}) })
		disabled: bump_map_bool(values, 'disabled', false)
		head_only: bump_map_bool(values, 'head_only', false)
		latest_cask: bump_map_bool(values, 'latest_cask', false)
		allow_bump: bump_map_bool(values, 'allow_bump', true)
		on_system_blocks: bump_map_bool(values, 'on_system_blocks', false)
		supported_archs: (values['supported_archs'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
		livecheck_defined: bump_map_bool(values, 'livecheck_defined', false)
		livecheck_skip_status: bump_map_string(values, 'livecheck_skip_status', '')
		livecheck_skip_messages: (values['livecheck_skip_messages'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
		livecheck_strategy: bump_map_string(values, 'livecheck_strategy', '')
		livecheck_original_url: bump_map_string(values, 'livecheck_original_url', '')
		livecheck_artifact_suffix: bump_map_string(values, 'livecheck_artifact_suffix', '')
		livecheck_throttled: bump_map_bool(values, 'livecheck_throttled', false)
		releases: releases
		repology_latest: bump_map_string(values, 'repology_latest', '')
		installed: bump_map_bool(values, 'installed', false)
		autobumped: bump_map_bool(values, 'autobumped', false)
		resources: resources
		pull_requests: pull_requests
		synced_versions: bump_string_map_from_value(values['synced_versions'] or { brew_runtime.map_value({}) })
		throttle: bump_map_bool(values, 'throttle', false)
		github_api_errors: bump_map_int(values, 'github_api_errors', 0)
		github_authentication_fail: bump_map_bool(values, 'github_authentication_fail', false)
		too_many_open_prs: bump_map_bool(values, 'too_many_open_prs', false)
	}
}

fn bump_options_from_value(value brew_runtime.Value) BumpOptions {
	values := value.map_data.clone()
	return BumpOptions{
		full_name: bump_map_bool(values, 'full_name', false)
		no_pull_requests: bump_map_bool(values, 'no_pull_requests', false)
		auto: bump_map_bool(values, 'auto', false)
		no_autobump: bump_map_bool(values, 'no_autobump', false)
		formula_only: bump_map_bool(values, 'formula', false)
		cask_only: bump_map_bool(values, 'cask', false)
		eval_all: bump_map_bool(values, 'eval_all', false)
		tap_trusted: bump_map_bool(values, 'tap_trusted', false)
		repology: bump_map_bool(values, 'repology', false)
		tap: bump_map_string(values, 'tap', '')
		installed: bump_map_bool(values, 'installed', false)
		no_fork: bump_map_bool(values, 'no_fork', false)
		open_pr: bump_map_bool(values, 'open_pr', false)
		start_with: bump_map_string(values, 'start_with', '')
		bump_synced: bump_map_bool(values, 'bump_synced', false)
		ci: bump_map_bool(values, 'ci', false)
		named: (values['named'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
	}
}

fn bump_versions_value(versions BumpVersions) brew_runtime.Value {
	return brew_runtime.map_value({
		'general': brew_runtime.string_value(versions.general)
		'arm':     brew_runtime.string_value(versions.arm)
		'intel':   brew_runtime.string_value(versions.intel)
	})
}

fn bump_versions_from_value(value brew_runtime.Value) BumpVersions {
	values := value.map_data.clone()
	return BumpVersions{
		general: bump_map_string(values, 'general', value.attributes['general'] or { '' })
		arm: bump_map_string(values, 'arm', value.attributes['arm'] or { '' })
		intel: bump_map_string(values, 'intel', value.attributes['intel'] or { '' })
	}
}

fn (versions BumpVersions) get(name string) string {
	return match name {
		'general' { versions.general }
		'arm' { versions.arm }
		'intel' { versions.intel }
		else { '' }
	}
}

fn (versions BumpVersions) count() int {
	mut count := 0
	if versions.general != '' {
		count++
	}
	if versions.arm != '' {
		count++
	}
	if versions.intel != '' {
		count++
	}
	return count
}

pub fn (versions BumpVersions) equals(other BumpVersions) bool {
	return versions.general == other.general && versions.arm == other.arm && versions.intel == other.intel
}

fn bump_versions_from_map(values map[string]string) BumpVersions {
	return BumpVersions{
		general: values['general'] or { '' }
		arm: values['arm'] or { '' }
		intel: values['intel'] or { '' }
	}
}

fn bump_version_compare(left string, right string) int {
	if left == right {
		return 0
	}
	left_version := brew.new_version(left) or { return if left < right { -1 } else { 1 } }
	right_version := brew.new_version(right) or { return if left < right { -1 } else { 1 } }
	return left_version.compare_to(right_version)
}

pub fn bump_message(value string) bool {
	text := value.trim_space().to_lower()
	return text.starts_with('error:') || text.starts_with('skipped')
		|| text.starts_with('unable to get versions') || text.starts_with('unable to get throttled versions')
}

fn bump_is_version(value string) bool {
	// Ruby preserves the runtime distinction between a Version and Repology's
	// string sentinel. The V representation stores both as strings, so retain
	// that distinction explicitly here.
	return value != '' && value != 'not found' && !bump_message(value)
}

pub fn compare_bump_versions(current BumpVersions, proposed BumpVersions) BumpVersionComparison {
	multiple_current := current.count() > 1
	multiple_new := proposed.count() > 1
	mut comparisons := map[string][]string{}
	for version_type in ['general', 'arm', 'intel'] {
		current_value := current.get(version_type)
		new_value := proposed.get(version_type)
		if current_value != '' && new_value != '' {
			comparisons[version_type] = [current_value, new_value]
		}
	}
	if multiple_current && proposed.general != '' {
		for version_type in ['arm', 'intel'] {
			if current.get(version_type) != '' && version_type !in comparisons {
				comparisons[version_type] = [current.get(version_type), proposed.general]
			}
		}
	}
	if 'general' !in comparisons && current.general != '' && multiple_new {
		mut highest := ''
		for version_type in ['arm', 'intel'] {
			candidate := proposed.get(version_type)
			if bump_is_version(candidate) && (highest == '' || bump_version_compare(candidate, highest) > 0) {
				highest = candidate
			}
		}
		if highest != '' {
			comparisons['general'] = [current.general, highest]
		}
	}
	mut newer := map[string]bool{}
	for version_type, pair in comparisons {
		newer[version_type] = pair.len == 2 && bump_is_version(pair[1])
			&& bump_version_compare(pair[0], pair[1]) > 0
	}
	return BumpVersionComparison{
		multiple_current: multiple_current
		multiple_new: multiple_new
		newer_than_upstream: newer
	}
}

fn bump_prerelease(version string) bool {
	lower := version.to_lower()
	if lower.contains('.dev') {
		return true
	}
	for marker in ['a', 'b', 'rc'] {
		index := lower.last_index(marker) or { continue }
		if index > 0 && index + marker.len < lower.len && lower[index + marker.len].is_digit() {
			return true
		}
	}
	return false
}

fn bump_rubygems_version_token(value string) bool {
	parts := value.split('.')
	if parts.len == 0 || parts[0] == '' || !parts[0][0].is_digit() {
		return false
	}
	for part in parts {
		if part == '' || part.bytes().any(!it.is_alnum()) {
			return false
		}
	}
	return true
}

fn bump_rubygems_platform(original_url string) string {
	if !original_url.starts_with('http://rubygems.org/')
		&& !original_url.starts_with('https://rubygems.org/') {
		return ''
	}
	filename := original_url.all_after_last('/').all_before('?')
	if !filename.ends_with('.gem') {
		return ''
	}
	stem := filename[..filename.len - '.gem'.len]
	parts := stem.split('-')
	for index := parts.len - 1; index > 0; index-- {
		if !bump_rubygems_version_token(parts[index]) {
			continue
		}
		return if index + 1 < parts.len { parts[index + 1..].join('-') } else { 'ruby' }
	}
	return ''
}

pub fn version_with_release_cooldown(info BumpCooldownInfo, current string) string {
	if current == '' || info.latest == '' || bump_version_compare(info.latest, current) <= 0 {
		return ''
	}
	strategy := info.strategy.to_lower()
	if strategy !in ['npm', 'pypi', 'rubygems'] || info.releases.len == 0 {
		return ''
	}
	cutoff := info.now - i64(info.cooldown_days) * 24 * 60 * 60
	current_is_prerelease := if strategy == 'pypi' {
		bump_prerelease(current)
	} else {
		current.contains('-') || bump_prerelease(current)
	}
	rubygems_platform := if strategy == 'rubygems' {
		if info.original_url == '' {
			'ruby'
		} else {
			bump_rubygems_platform(info.original_url)
		}
	} else {
		''
	}
	if strategy == 'rubygems' && rubygems_platform == '' {
		return ''
	}
	mut selected := ''
	mut current_present := false
	for release in info.releases {
		if release.version == current {
			current_present = true
			continue
		}
		if bump_version_compare(release.version, info.latest) > 0
			|| bump_version_compare(release.version, current) < 0 {
			continue
		}
		if release.released_at >= cutoff || release.yanked {
			continue
		}
		if !current_is_prerelease && release.prerelease {
			continue
		}
		if strategy == 'pypi' {
			if info.artifact_suffix != '' && release.artifact_suffix != info.artifact_suffix {
				continue
			}
		} else if strategy == 'rubygems' {
			if release.platform != rubygems_platform {
				continue
			}
		}
		if selected == '' || bump_version_compare(release.version, selected) > 0 {
			selected = release.version
		}
	}
	if selected != '' {
		return selected
	}
	return if current_present { current } else { '' }
}

pub fn skip_ineligible_bump(package BumpPackage) (bool, string) {
	mut skip := false
	mut text := ''
	if package.kind == .formula {
		skip = package.disabled || package.head_only
		text = if package.disabled {
			'Formula is disabled so not accepting updates.'
		} else {
			'Formula is HEAD-only so not accepting updates.'
		}
	} else {
		skip = package.disabled || package.latest_cask
		text = if package.disabled {
			'Cask is disabled so not accepting updates.'
		} else {
			'Cask uses `version :latest` so `brew bump` cannot check it.'
		}
	}
	if !package.allow_bump {
		skip = true
		kind := if package.kind == .formula { 'Formula' } else { 'Cask' }
		text = '${kind} is autobumped so will have bump PRs opened by BrewTestBot every ~3 hours.'
	}
	return skip, if skip { text } else { '' }
}

pub fn skip_bump_repology(package BumpPackage, options BumpOptions) bool {
	if !options.repology {
		return true
	}
	return (options.ci && options.open_pr && package.livecheck_defined)
		|| (package.kind == .formula && package.name.contains('@'))
}

pub fn bump_livecheck_result(package BumpPackage, current string, arch string, now i64) BumpLivecheckResult {
	if package.livecheck_skip_status != '' {
		message := package.livecheck_skip_messages.join('; ')
		if package.livecheck_skip_status == 'error' && message != '' {
			return BumpLivecheckResult{
				version: 'error: ${message}'
				is_message: true
			}
		}
		reason := if message != '' { message } else { package.livecheck_skip_status }
		return BumpLivecheckResult{
			version: 'skipped - ${reason}'
			is_message: true
		}
	}
	if package.livecheck_throttled {
		throttled := package.latest_throttled_versions[arch] or {
			package.latest_throttled_versions['general'] or { '' }
		}
		if throttled == '' {
			return BumpLivecheckResult{
				version: 'unable to get throttled versions'
				is_message: true
			}
		}
		return BumpLivecheckResult{
			version: throttled
		}
	}
	latest := package.latest_versions[arch] or { package.latest_versions['general'] or { '' } }
	if latest == '' {
		return BumpLivecheckResult{
			version: 'unable to get versions'
			is_message: true
		}
	}
	cooldown := version_with_release_cooldown(BumpCooldownInfo{
		latest: latest
		strategy: package.livecheck_strategy
		original_url: package.livecheck_original_url
		artifact_suffix: package.livecheck_artifact_suffix
		releases: package.releases
		now: now
	}, current)
	if cooldown != '' && bump_version_compare(cooldown, latest) < 0 {
		return BumpLivecheckResult{
			version: cooldown
			cooldown_skipped: latest
		}
	}
	return BumpLivecheckResult{
		version: if cooldown != '' { cooldown } else { latest }
	}
}

pub fn collect_bump_resource_versions(package BumpPackage, formula_latest_version string) []BumpResourceVersionInfo {
	mut result := []BumpResourceVersionInfo{}
	for resource in package.resources {
		if !resource.livecheck_defined || resource.livecheck_skip {
			continue
		}
		if resource.tracks_parent {
			result << BumpResourceVersionInfo{
				name: resource.name
				current_version: resource.current_version
				latest_version: formula_latest_version
				has_latest_version: true
				outdated: bump_version_compare(resource.current_version, formula_latest_version) < 0
				newer_than_upstream: bump_version_compare(resource.current_version, formula_latest_version) > 0
			}
			continue
		}
		if resource.livecheck_error || resource.latest_version == '' {
			result << BumpResourceVersionInfo{
				name: resource.name
				current_version: resource.current_version
			}
			continue
		}
		result << BumpResourceVersionInfo{
			name: resource.name
			current_version: resource.current_version
			latest_version: resource.latest_version
			has_latest_version: true
			outdated: resource.outdated
			newer_than_upstream: resource.newer_than_upstream
		}
	}
	return result
}

pub fn retrieve_bump_pull_requests(package BumpPackage, version string) string {
	mut matches := []string{}
	for pull_request in package.pull_requests {
		if version != '' && pull_request.version != version {
			continue
		}
		matches << '${pull_request.title} (${pull_request.url})'
	}
	return matches.join(', ')
}

pub fn synced_bump_formulae(package BumpPackage, new_version string) []string {
	mut result := []string{}
	for name, version in package.synced_versions {
		if name != package.name && version != new_version {
			result << name
		}
	}
	result.sort()
	return result
}

pub fn autobumped_packages(tap BumpTap, packages []BumpPackage, casks bool) []BumpPackage {
	mut result := []BumpPackage{}
	for autobump_name in tap.autobump_names {
		qualified_name := '${tap.name}/${autobump_name}'
		for package in packages {
			if (package.name == autobump_name || package.full_name == qualified_name)
				&& ((casks && package.kind == .cask) || (!casks && package.kind == .formula)) {
				result << package
				break
			}
		}
	}
	return result
}

pub fn version_args_for_bump(current BumpVersions, proposed BumpVersions, comparison BumpVersionComparison, name string) []string {
	mut result := []string{}
	if comparison.multiple_new {
		for arch in ['arm', 'intel'] {
			new_version := proposed.get(arch)
			if new_version == '' || bump_message(new_version) {
				continue
			}
			current_version := if comparison.multiple_current {
				current.get(arch)
			} else {
				current.general
			}
			if current_version != '' && bump_version_compare(new_version, current_version) > 0 {
				result << '--version-${arch}=${new_version}'
			}
		}
	} else if comparison.multiple_current {
		if proposed.general != '' && !bump_message(proposed.general) {
			for arch in ['arm', 'intel'] {
				current_version := current.get(arch)
				if current_version != '' && bump_version_compare(proposed.general, current_version) > 0 {
					result << '--version-${arch}=${proposed.general}'
				}
			}
		}
		_ = name
	} else if proposed.general != '' {
		result << '--version=${proposed.general}'
	}
	return result
}

fn bump_arches(package BumpPackage) []string {
	if !package.on_system_blocks {
		return ['general']
	}
	if package.supported_archs.len > 0 {
		return package.supported_archs.clone()
	}
	return ['arm', 'intel']
}

pub fn retrieve_bump_versions(package BumpPackage, repositories []string, name string, options BumpOptions, now i64) BumpVersionInfo {
	arches := bump_arches(package)
	mut current_versions := map[string]string{}
	mut new_versions := map[string]string{}
	mut deprecated := map[string]bool{}
	mut cooldown_skipped := map[string]string{}
	repology_latest := if repositories.len > 0 && package.repology_latest != '' {
		package.repology_latest
	} else {
		'not found'
	}
	for arch in arches {
		key := if package.on_system_blocks { arch } else { 'general' }
		current := package.current_versions[arch] or {
			package.current_versions['general'] or { package.version }
		}
		current_versions[key] = current
		deprecated[key] = package.deprecated[arch] or {
			package.deprecated['general'] or { false }
		}
		livecheck := bump_livecheck_result(package, current, arch, now)
		if livecheck.cooldown_skipped != '' {
			cooldown_skipped[key] = livecheck.cooldown_skipped
		}
		mut proposed := ''
		if livecheck.is_message || current == 'latest'
			|| (bump_is_version(livecheck.version) && bump_version_compare(livecheck.version, current) >= 0) {
			proposed = livecheck.version
		} else if bump_is_version(repology_latest) && !package.livecheck_defined && current != 'latest'
			&& bump_version_compare(repology_latest, current) > 0 {
			proposed = repology_latest
		}
		if proposed == '' && bump_is_version(livecheck.version) {
			proposed = livecheck.version
		}
		if proposed == '' && bump_is_version(repology_latest) && !package.livecheck_defined {
			proposed = repology_latest
		}
		new_versions[key] = proposed
	}
	if package.on_system_blocks && arches.len == 1 {
		arch := arches[0]
		current_versions = {
			'general': current_versions[arch] or { '' }
		}
		new_versions = {
			'general': new_versions[arch] or { '' }
		}
		if skipped := cooldown_skipped[arch] {
			cooldown_skipped = {
				'general': skipped
			}
		}
	} else if package.on_system_blocks {
		if current_versions['arm'] or { '' } != '' && current_versions['arm'] == current_versions['intel'] {
			current_versions = {
				'general': current_versions['arm']
			}
		}
		if new_versions['arm'] or { '' } != '' && new_versions['arm'] == new_versions['intel'] {
			new_versions = {
				'general': new_versions['arm']
			}
		}
		if cooldown_skipped['arm'] or { '' } != '' && cooldown_skipped['arm'] == cooldown_skipped['intel'] {
			cooldown_skipped = {
				'general': cooldown_skipped['arm']
			}
		}
	}
	current := bump_versions_from_map(current_versions)
	proposed := bump_versions_from_map(new_versions)
	comparison := compare_bump_versions(current, proposed)
	if !comparison.multiple_current && 'general' !in deprecated {
		deprecated = {
			'general': (deprecated['arm'] or { false }) || (deprecated['intel'] or { false })
		}
	}
	resources := if package.kind == .formula && bump_is_version(proposed.general) {
		collect_bump_resource_versions(package, proposed.general)
	} else {
		[]BumpResourceVersionInfo{}
	}
	mut duplicate := ''
	mut maybe_duplicate := ''
	if !options.no_pull_requests {
		mut pull_request_version := ''
		for candidate in [proposed.arm, proposed.intel, proposed.general] {
			if bump_is_version(candidate) && candidate !in [current.arm, current.intel,
				current.general] {
				pull_request_version = candidate
				break
			}
		}
		if pull_request_version != '' {
			duplicate = retrieve_bump_pull_requests(package, pull_request_version)
			if duplicate == '' {
				maybe_duplicate = retrieve_bump_pull_requests(package, '')
			}
		}
	}
	_ = name
	return BumpVersionInfo{
		kind: package.kind
		deprecated: deprecated
		multiple_current: comparison.multiple_current
		multiple_new: comparison.multiple_new
		version_name: if package.kind == .formula { 'formula version:' } else { 'cask version:   ' }
		current_version: current
		new_version: proposed
		resource_versions: resources
		repology_latest: repology_latest
		newer_than_upstream: comparison.newer_than_upstream
		cooldown_skipped_versions: cooldown_skipped
		duplicate_pull_requests: duplicate
		maybe_duplicate_pull_requests: maybe_duplicate
	}
}

fn bump_all_newer_than_upstream(values map[string]bool) bool {
	if values.len == 0 {
		return false
	}
	for _, value in values {
		if !value {
			return false
		}
	}
	return true
}

fn bump_current_version_text(info BumpVersionInfo) string {
	if info.multiple_current {
		arm := if info.current_version.arm != '' {
			info.current_version.arm
		} else {
			info.current_version.general
		}
		intel := if info.current_version.intel != '' {
			info.current_version.intel
		} else {
			info.current_version.general
		}
		arm_newer := if info.newer_than_upstream['arm'] or { false } {
			' (newer than upstream)'
		} else {
			''
		}
		intel_newer := if info.newer_than_upstream['intel'] or { false } {
			' (newer than upstream)'
		} else {
			''
		}
		arm_deprecated := if info.deprecated['arm'] or { false } { ' (deprecated)' } else { '' }
		intel_deprecated := if info.deprecated['intel'] or { false } { ' (deprecated)' } else { '' }
		return 'arm:   ${arm}${arm_newer}${arm_deprecated}\n                          intel: ${intel}${intel_newer}${intel_deprecated}'
	}
	newer := if info.newer_than_upstream['general'] or { false } {
		' (newer than upstream)'
	} else {
		''
	}
	deprecated := if info.deprecated['general'] or { false } { ' (deprecated)' } else { '' }
	return '${info.current_version.general}${newer}${deprecated}'
}

fn bump_new_version_text(info BumpVersionInfo) string {
	if info.multiple_new && info.new_version.arm != '' && info.new_version.intel != '' {
		return 'arm:   ${info.new_version.arm}\n                          intel: ${info.new_version.intel}'
	}
	return info.new_version.general
}

pub fn retrieve_display_and_open_pr(package BumpPackage, name string, repositories []string, ambiguous_cask bool, options BumpOptions, now i64) BumpDisplayResult {
	info := retrieve_bump_versions(package, repositories, name, options, now)
	versions_equal := info.current_version.equals(info.new_version)
	all_newer := bump_all_newer_than_upstream(info.newer_than_upstream)
	mut cooldown_version := ''
	for _, version in info.cooldown_skipped_versions {
		if cooldown_version == '' || bump_version_compare(version, cooldown_version) > 0 {
			cooldown_version = version
		}
	}
	title_name := if ambiguous_cask { '${name} (cask)' } else { name }
	mut title := title_name
	if (info.repology_latest == info.current_version.general || !bump_is_version(info.repology_latest))
		&& versions_equal {
		title = if cooldown_version != '' {
			'${title_name} has a new version in release cooldown'
		} else {
			'${title_name} is up to date!'
		}
	}
	new_versions := bump_new_version_text(info)
	latest_versions := if cooldown_version != '' {
		'${cooldown_version} (released less than 7 days ago)'
	} else {
		'${new_versions}${if package.throttle { ' (throttled)' } else { '' }}'
	}
	mut lines := [title, 'Current ${info.version_name}  ${bump_current_version_text(info)}',
		'Latest livecheck version: ${latest_versions}']
	if cooldown_version != '' {
		lines << 'Bump-ready version:       ${new_versions}'
	}
	if !skip_bump_repology(package, options) {
		lines << 'Latest Repology version:  ${info.repology_latest}'
	}
	outdated_synced := synced_bump_formulae(package, info.new_version.general)
	if package.kind == .formula && !options.bump_synced && outdated_synced.len > 0 {
		lines << 'Version syncing:          ${title_name} version should be kept in sync with ${outdated_synced.join(', ')}.'
	}
	if info.resource_versions.len > 0 {
		lines << 'Resources with livecheck:'
	}
	for resource in info.resource_versions {
		status := if !resource.has_latest_version {
			'unable to get versions'
		} else if resource.newer_than_upstream {
			'${resource.current_version} -> ${resource.latest_version} (newer than upstream)'
		} else {
			'${resource.current_version} -> ${resource.latest_version}'
		}
		lines << '  ${resource.name}: ${status}'
	}
	if !options.no_pull_requests && !bump_message(info.new_version.general) && !versions_equal
		&& !all_newer {
		duplicate_text := if info.duplicate_pull_requests != '' {
			info.duplicate_pull_requests
		} else {
			'none'
		}
		lines << 'Duplicate pull requests:  ${duplicate_text}'
		if info.maybe_duplicate_pull_requests != '' {
			lines << 'Maybe duplicate pull requests: ${info.maybe_duplicate_pull_requests}'
		}
	}
	if !options.open_pr || bump_message(info.new_version.general) || all_newer {
		return BumpDisplayResult{
			name: title_name
			lines: lines
		}
	}
	if package.too_many_open_prs {
		return BumpDisplayResult{
			name: title_name
			lines: lines
			failed: true
			error: 'You have too many PRs open: close or merge some first!'
		}
	}
	if info.new_version.count() == 0 || versions_equal || info.duplicate_pull_requests != '' {
		return BumpDisplayResult{
			name: title_name
			lines: lines
		}
	}
	comparison := BumpVersionComparison{
		multiple_current: info.multiple_current
		multiple_new: info.multiple_new
		newer_than_upstream: info.newer_than_upstream
	}
	version_args := version_args_for_bump(info.current_version, info.new_version, comparison, name)
	if version_args.len == 0 {
		return BumpDisplayResult{
			name: title_name
			lines: lines
		}
	}
	mut command := ['bump-${info.kind.str()}-pr', name]
	command << version_args
	command << '--no-browse'
	command << '--message=Created by `brew bump`'
	if options.no_fork {
		command << '--no-fork'
	}
	if options.bump_synced && outdated_synced.len > 0 {
		command << '--bump-synced=${outdated_synced.join(',')}'
	}
	if info.kind == .formula && info.resource_versions.len > 0 {
		command << '--resource-versions=${json2.encode(info.resource_versions, escape_unicode: true)}'
	}
	return BumpDisplayResult{
		name: title_name
		lines: lines
		bump_pr_command: command
	}
}

pub fn handle_bump_packages(packages []BumpPackage, options BumpOptions, now i64) BumpHandleResult {
	mut displays := []BumpDisplayResult{}
	mut output := []string{}
	mut consecutive_errors := 0
	for package in packages {
		skip, reason := skip_ineligible_bump(package)
		if skip {
			output << package.name
			output << reason
			continue
		}
		if package.github_authentication_fail {
			return BumpHandleResult{
				displays: displays
				output: output
				failed: true
				error: '${package.name}: GitHub authentication failed'
			}
		}
		if package.github_api_errors > 3 {
			consecutive_errors++
			if consecutive_errors >= 5 {
				return BumpHandleResult{
					displays: displays
					output: output
					failed: true
					error: 'Aborting after ${consecutive_errors} consecutive GitHub API errors'
				}
			}
			output << '${package.name}: skipped after a GitHub API error'
			continue
		}
		consecutive_errors = 0
		mut ambiguous_cask := false
		mut ambiguous_name := false
		for other in packages {
			if other.name == package.name && other.full_name != package.full_name {
				ambiguous_name = true
				if package.kind == .cask && other.kind != .cask {
					ambiguous_cask = true
				}
			}
		}
		name := if options.full_name || ambiguous_name { package.full_name } else { package.name }
		repositories := if skip_bump_repology(package, options) {
			[]string{}
		} else {
			[package.repology_latest]
		}
		display := retrieve_display_and_open_pr(package, name, repositories, ambiguous_cask, options, now)
		displays << display
		if display.failed {
			return BumpHandleResult{
				displays: displays
				output: output
				failed: true
				error: display.error
			}
		}
	}
	return BumpHandleResult{
		displays: displays
		output: output
	}
}

fn bump_find_tap(taps []BumpTap, name string) ?BumpTap {
	for tap in taps {
		if tap.name == name {
			return tap
		}
	}
	return none
}

fn bump_kind_selected(package BumpPackage, options BumpOptions) bool {
	if options.formula_only {
		return package.kind == .formula
	}
	if options.cask_only {
		return package.kind == .cask
	}
	return true
}

pub fn run_bump(request BumpRunRequest, now i64) BumpRunResult {
	options := request.options
	eval_all := options.eval_all || (options.named.len == 0 && options.tap_trusted)
	mut selected := []BumpPackage{}
	if options.auto {
		if !options.formula_only && !options.cask_only {
			return BumpRunResult{
				error: '`--formula` or `--cask` must be passed with `--auto`.'
			}
		}
		if options.tap == '' {
			return BumpRunResult{
				error: '`--tap=` must be passed with `--auto`.'
			}
		}
		tap := bump_find_tap(request.taps, options.tap) or {
			return BumpRunResult{
				error: 'Tap `${options.tap}` not found.'
			}
		}
		if tap.autobump_names.len == 0 {
			return BumpRunResult{
				error: 'No autobumped packages found.'
			}
		}
		selected = autobumped_packages(tap, request.packages, options.cask_only)
		if options.bump_synced && options.formula_only {
			mut followers := map[string]bool{}
			for package in selected {
				mut names := package.synced_versions.keys()
				names.sort()
				for index, name in names {
					if index > 0 {
						followers[name] = true
					}
				}
			}
			selected = selected.filter(it.name !in followers)
		}
	} else if options.tap != '' {
		tap := bump_find_tap(request.taps, options.tap) or {
			return BumpRunResult{
				error: 'Tap `${options.tap}` not found.'
			}
		}
		if tap.official {
			return BumpRunResult{
				error: '`--tap` requires `--auto` for official taps.'
			}
		}
		selected = request.packages.filter(it.tap_name == tap.name && bump_kind_selected(it, options))
	} else if options.installed {
		selected = request.packages.filter(it.installed && bump_kind_selected(it, options))
	} else if options.named.len > 0 {
		selected = request.packages.filter((it.name in options.named || it.full_name in options.named)
			&& bump_kind_selected(it, options))
	} else if eval_all {
		selected = request.packages.filter(bump_kind_selected(it, options))
	} else {
		return BumpRunResult{
			error: '`brew bump` without named arguments needs `--installed`, `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!'
		}
	}
	if options.start_with != '' {
		selected = selected.filter(it.name.starts_with(options.start_with))
	}
	if options.no_autobump && eval_all {
		selected = selected.filter(!it.autobumped)
	}
	selected.sort(a.name < b.name)
	mut names := []string{}
	for package in selected {
		names << package.name
	}
	return BumpRunResult{
		selected: names
		handled: handle_bump_packages(selected, options, now)
	}
}

fn bump_version_info_value(info BumpVersionInfo) brew_runtime.Value {
	mut resources := []brew_runtime.Value{}
	for resource in info.resource_versions {
		resources << brew_runtime.map_value({
			'name':                brew_runtime.string_value(resource.name)
			'current_version':     brew_runtime.string_value(resource.current_version)
			'latest_version':      brew_runtime.string_value(resource.latest_version)
			'has_latest_version':  brew_runtime.bool_value(resource.has_latest_version)
			'outdated':            brew_runtime.bool_value(resource.outdated)
			'newer_than_upstream': brew_runtime.bool_value(resource.newer_than_upstream)
		})
	}
	return brew_runtime.map_value({
		'type':                          brew_runtime.string_value(info.kind.str())
		'deprecated':                    bump_bool_map_value(info.deprecated)
		'multiple_versions':             brew_runtime.map_value({
			'current': brew_runtime.bool_value(info.multiple_current)
			'new':     brew_runtime.bool_value(info.multiple_new)
		})
		'version_name':                  brew_runtime.string_value(info.version_name)
		'current_version':               bump_versions_value(info.current_version)
		'new_version':                   bump_versions_value(info.new_version)
		'resource_versions':             brew_runtime.array_value(resources)
		'repology_latest':               brew_runtime.string_value(info.repology_latest)
		'newer_than_upstream':           bump_bool_map_value(info.newer_than_upstream)
		'cooldown_skipped_versions':     bump_string_map_value(info.cooldown_skipped_versions)
		'duplicate_pull_requests':       brew_runtime.string_value(info.duplicate_pull_requests)
		'maybe_duplicate_pull_requests': brew_runtime.string_value(info.maybe_duplicate_pull_requests)
	})
}

fn bump_display_value(result BumpDisplayResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'name':            brew_runtime.string_value(result.name)
		'lines':           brew_runtime.string_array_value(result.lines)
		'bump_pr_command': brew_runtime.string_array_value(result.bump_pr_command)
		'failed':          brew_runtime.bool_value(result.failed)
		'error':           brew_runtime.string_value(result.error)
	})
}

// Ruby method `run` at line 107.
pub fn ruby_bump_l107_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.structured_value('ArgumentError', 'missing bump request', {})
	}
	values := args[args.len - 1].map_data.clone()
	options := bump_options_from_value(values['options'] or { brew_runtime.map_value({}) })
	mut packages := []BumpPackage{}
	for value in (values['packages'] or { brew_runtime.array_value([]) }).as_array() or { [] } {
		packages << bump_package_from_value(value) or {
			return brew_runtime.structured_value('ArgumentError', err.msg(), {})
		}
	}
	mut taps := []BumpTap{}
	for value in (values['taps'] or { brew_runtime.array_value([]) }).as_array() or { [] } {
		tap_values := value.map_data.clone()
		taps << BumpTap{
			name: bump_map_string(tap_values, 'name', value.repr)
			official: bump_map_bool(tap_values, 'official', false)
			autobump_names: (tap_values['autobump_names'] or {
				brew_runtime.string_array_value([])
			}).as_string_array() or { [] }
		}
	}
	result := run_bump(BumpRunRequest{
		options: options
		packages: packages
		taps: taps
	}, (values['now'] or { brew_runtime.int_value(0) }).int_data)
	return brew_runtime.map_value({
		'selected': brew_runtime.string_array_value(result.selected)
		'error':    brew_runtime.string_value(result.error)
		'failed':   brew_runtime.bool_value(result.handled.failed)
	})
}

// Ruby method `skip_ineligible_formulae!(formula_or_cask)` at line 193.
pub fn ruby_bump_l193_d2_skip_ineligible_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	package := bump_package_from_value(args[args.len - 1]) or {
		return brew_runtime.bool_value(false)
	}
	skip, reason := skip_ineligible_bump(package)
	return brew_runtime.map_value({
		'skip':    brew_runtime.bool_value(skip)
		'message': brew_runtime.string_value(reason)
	})
}

// Ruby method `retrieve_versions_by_arch(formula_or_cask:, repositories:, name:)` at line 225.
pub fn ruby_bump_l225_d3_retrieve_versions_by_arch(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return bump_nil_value()
	}
	values := args[args.len - 1].map_data.clone()
	package := bump_package_from_value(values['formula_or_cask'] or { bump_nil_value() }) or {
		return brew_runtime.structured_value('ArgumentError', err.msg(), {})
	}
	repositories := (values['repositories'] or {
		brew_runtime.string_array_value([])
	}).as_string_array() or { [] }
	options := bump_options_from_value(values['options'] or { brew_runtime.map_value({}) })
	return bump_version_info_value(retrieve_bump_versions(package, repositories, bump_map_string(values, 'name', package.name), options, (values['now'] or { brew_runtime.int_value(0) }).int_data))
}

// Ruby method `retrieve_and_display_info_and_open_pr(formula_or_cask, name, repositories, ambiguous_cask: false)` at line 413.
pub fn ruby_bump_l413_d4_retrieve_and_display_info_and_open_pr(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return bump_nil_value()
	}
	values := args[args.len - 1].map_data.clone()
	package := bump_package_from_value(values['formula_or_cask'] or { bump_nil_value() }) or {
		return brew_runtime.structured_value('ArgumentError', err.msg(), {})
	}
	return bump_display_value(retrieve_display_and_open_pr(package, bump_map_string(values, 'name', package.name), (values['repositories'] or {
		brew_runtime.string_array_value([])
	}).as_string_array() or { [] }, bump_map_bool(values, 'ambiguous_cask', false), bump_options_from_value(values['options'] or { brew_runtime.map_value({}) }), (values['now'] or { brew_runtime.int_value(0) }).int_data))
}

// Ruby method `version_args_for_bump(current_version:, new_version:, multiple_versions:, name:)` at line 588.
pub fn ruby_bump_l588_d5_version_args_for_bump(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	values := args[args.len - 1].map_data.clone()
	current := bump_versions_from_value(values['current_version'] or { brew_runtime.map_value({}) })
	proposed := bump_versions_from_value(values['new_version'] or { brew_runtime.map_value({}) })
	multiple := values['multiple_versions'] or { brew_runtime.map_value({}) }
	comparison := BumpVersionComparison{
		multiple_current: bump_map_bool(multiple.map_data, 'current', current.count() > 1)
		multiple_new: bump_map_bool(multiple.map_data, 'new', proposed.count() > 1)
	}
	return brew_runtime.string_array_value(version_args_for_bump(current, proposed, comparison, bump_map_string(values, 'name', '')))
}

// Ruby method `compare_versions(current_version, new_version, formula_or_cask)` at line 630.
pub fn ruby_bump_l630_d6_compare_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bump_nil_value()
	}
	current_index := if args.len >= 3 { args.len - 3 } else { 0 }
	new_index := if args.len >= 3 { args.len - 2 } else { 1 }
	comparison := compare_bump_versions(bump_versions_from_value(args[current_index]), bump_versions_from_value(args[new_index]))
	return brew_runtime.map_value({
		'multiple_versions':   brew_runtime.map_value({
			'current': brew_runtime.bool_value(comparison.multiple_current)
			'new':     brew_runtime.bool_value(comparison.multiple_new)
		})
		'newer_than_upstream': bump_bool_map_value(comparison.newer_than_upstream)
	})
}

// Ruby method `message?(value)` at line 698.
pub fn ruby_bump_l698_d7_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	value := args[args.len - 1]
	if value.type_name !in ['String', 'Cask::DSL::Version'] {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(bump_message(value.as_string()))
}

// Ruby method `version_with_cooldown(version_info, current = nil)` at line 715.
pub fn ruby_bump_l715_d8_version_with_cooldown(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bump_nil_value()
	}
	values := args[args.len - 2].map_data.clone()
	mut releases := []BumpRelease{}
	for release in (values['releases'] or { brew_runtime.array_value([]) }).as_array() or { [] } {
		releases << bump_release_from_value(release)
	}
	selected := version_with_release_cooldown(BumpCooldownInfo{
		latest: bump_map_string(values, 'latest', '')
		strategy: bump_map_string(values, 'strategy', '')
		original_url: bump_map_string(values, 'original_url', '')
		artifact_suffix: bump_map_string(values, 'artifact_suffix', '')
		releases: releases
		now: (values['now'] or { brew_runtime.int_value(0) }).int_data
		cooldown_days: bump_map_int(values, 'cooldown_days', 7)
	}, args[args.len - 1].as_string())
	return if selected == '' {
		bump_nil_value()
	} else {
		brew_runtime.object_value('Version', selected)
	}
}

// Ruby method `skip_repology?(formula_or_cask)` at line 824.
pub fn ruby_bump_l824_d9_skip_repology(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(true)
	}
	package := bump_package_from_value(args[0]) or { return brew_runtime.bool_value(true) }
	options := if args.len > 1 { bump_options_from_value(args[1]) } else { BumpOptions{} }
	return brew_runtime.bool_value(skip_bump_repology(package, options))
}

// Ruby method `handle_formulae_and_casks(formulae_and_casks)` at line 832.
pub fn ruby_bump_l832_d10_handle_formulae_and_casks(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return bump_nil_value()
	}
	mut packages := []BumpPackage{}
	for value in args[0].as_array() or { [] } {
		packages << bump_package_from_value(value) or { continue }
	}
	options := if args.len > 1 { bump_options_from_value(args[1]) } else { BumpOptions{} }
	now := if args.len > 2 { args[2].int_data } else { i64(0) }
	result := handle_bump_packages(packages, options, now)
	mut displays := []brew_runtime.Value{}
	for display in result.displays {
		displays << bump_display_value(display)
	}
	return brew_runtime.map_value({
		'displays': brew_runtime.array_value(displays)
		'output':   brew_runtime.string_array_value(result.output)
		'failed':   brew_runtime.bool_value(result.failed)
		'error':    brew_runtime.string_value(result.error)
	})
}

// Ruby method `livecheck_result(formula_or_cask, current)` at line 911.
pub fn ruby_bump_l911_d11_livecheck_result(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return bump_nil_value()
	}
	package := bump_package_from_value(args[0]) or {
		return brew_runtime.structured_value('ArgumentError', err.msg(), {})
	}
	metadata := if args.len > 2 { args[2].map_data } else { map[string]brew_runtime.Value{} }
	arch := bump_map_string(metadata, 'arch', 'general')
	now := (metadata['now'] or { brew_runtime.int_value(0) }).int_data
	result := bump_livecheck_result(package, args[1].as_string(), arch, now)
	return brew_runtime.array_value([
		brew_runtime.string_value(result.version),
		if result.cooldown_skipped == '' {
			bump_nil_value()
		} else {
			brew_runtime.object_value('Version', result.cooldown_skipped)
		},
	])
}

// Ruby method `retrieve_pull_requests(formula_or_cask, name, version: nil)` at line 973.
pub fn ruby_bump_l973_d12_retrieve_pull_requests(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return bump_nil_value()
	}
	package := bump_package_from_value(args[0]) or {
		return brew_runtime.structured_value('ArgumentError', err.msg(), {})
	}
	version := if args.len > 2 { args[2].as_string() } else { '' }
	result := retrieve_bump_pull_requests(package, version)
	return if result == '' {
		bump_nil_value()
	} else {
		brew_runtime.string_value(result)
	}
}

// Ruby method `collect_resource_versions(formula, formula_latest_version)` at line 994.
pub fn ruby_bump_l994_d13_collect_resource_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.array_value([])
	}
	package := bump_package_from_value(args[0]) or {
		return brew_runtime.structured_value('ArgumentError', err.msg(), {})
	}
	mut result := []brew_runtime.Value{}
	for resource in collect_bump_resource_versions(package, args[1].as_string()) {
		result << brew_runtime.map_value({
			'name':                brew_runtime.string_value(resource.name)
			'current_version':     brew_runtime.string_value(resource.current_version)
			'latest_version':      if resource.has_latest_version {
				brew_runtime.string_value(resource.latest_version)
			} else {
				bump_nil_value()
			}
			'outdated':            brew_runtime.bool_value(resource.outdated)
			'newer_than_upstream': brew_runtime.bool_value(resource.newer_than_upstream)
		})
	}
	return brew_runtime.array_value(result)
}

// Ruby method `synced_with(formula, new_version)` at line 1056.
pub fn ruby_bump_l1056_d14_synced_with(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	package := bump_package_from_value(args[0]) or {
		return brew_runtime.structured_value('ArgumentError', err.msg(), {})
	}
	return brew_runtime.string_array_value(synced_bump_formulae(package, args[1].as_string()))
}

// Ruby method `autobumped_formulae_or_casks(tap, casks: false)` at line 1074.
pub fn ruby_bump_l1074_d15_autobumped_formulae_or_casks(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.array_value([])
	}
	tap_values := args[0].map_data.clone()
	tap := BumpTap{
		name: bump_map_string(tap_values, 'name', args[0].repr)
		official: bump_map_bool(tap_values, 'official', false)
		autobump_names: (tap_values['autobump_names'] or {
			brew_runtime.string_array_value([])
		}).as_string_array() or { [] }
	}
	mut packages := []BumpPackage{}
	for value in args[1].as_array() or { [] } {
		packages << bump_package_from_value(value) or { continue }
	}
	casks := if args.len > 2 {
		if args[2].type_name == 'Bool' {
			args[2].bool_data
		} else {
			bump_map_bool(args[2].map_data, 'casks', false)
		}
	} else {
		false
	}
	mut result := []brew_runtime.Value{}
	for package in autobumped_packages(tap, packages, casks) {
		result << bump_package_value(package)
	}
	return brew_runtime.array_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "bump_version_parser"
// 6: require "livecheck/livecheck"
// 7: require "release_cooldown"
// 8: require "utils/curl"
// 9: require "utils/repology"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class Bump < AbstractCommand
// 14:       DEFAULT_CURL_ARGS = [
// 15:         "--compressed",
// 16:         "--fail-with-body",
// 17:         "--location",
// 18:         "--max-redirs",
// 19:         "5",
// 20:         "--silent",
// 21:       ].freeze
// 22:       DEFAULT_CURL_OPTIONS = T.let({
// 23:         connect_timeout: 15,
// 24:         max_time:        55,
// 25:         timeout:         60,
// 26:         retries:         0,
// 27:       }.freeze, T::Hash[Symbol, T.untyped])
// 28:       MAX_CONSECUTIVE_GITHUB_API_ERRORS = 5
// 29:       MAX_GITHUB_API_RETRIES = 3
// 30:       PYPI_UNSTABLE_VERSION_REGEX = /^(?:\d+!)?\d+(?:\.\d+)*(?:a|b|rc)\d+|\.dev\d+$/i
// 31:
// 32:       LIVECHECK_MESSAGE_REGEX = /^(?:error:|skipped|unable to get(?: throttled)? versions)/i
// 33:       NEWER_THAN_UPSTREAM_MSG = " (newer than upstream)"
// 34:
// 35:       class ResourceVersionInfo < T::Struct
// 36:         const :name, String
// 37:         const :current_version, String
// 38:         const :latest_version, T.nilable(String)
// 39:         const :outdated, T::Boolean
// 40:         const :newer_than_upstream, T::Boolean
// 41:       end
// 42:
// 43:       class VersionBumpInfo < T::Struct
// 44:         const :type, Symbol
// 45:         const :deprecated, T::Hash[Symbol, T::Boolean], default: {}
// 46:         const :multiple_versions, T::Hash[Symbol, T::Boolean], default: {}
// 47:         const :version_name, String
// 48:         const :current_version, BumpVersionParser
// 49:         const :new_version, BumpVersionParser
// 50:         const :resource_versions, T::Array[ResourceVersionInfo], default: []
// 51:         const :repology_latest, T.any(String, Version)
// 52:         const :newer_than_upstream, T::Hash[Symbol, T::Boolean], default: {}
// 53:         const :cooldown_skipped_versions, T::Hash[Symbol, Version], default: {}
// 54:         const :duplicate_pull_requests, T.nilable(T.any(T::Array[String], String))
// 55:         const :maybe_duplicate_pull_requests, T.nilable(T.any(T::Array[String], String))
// 56:       end
// 57:
// 58:       cmd_args do
// 59:         description <<~EOS
// 60:           Displays out-of-date packages and the latest version available. If the
// 61:           returned current and livecheck versions differ or when querying specific
// 62:           packages, also displays whether a pull request has been opened with the URL.
// 63:         EOS
// 64:         switch "--full-name",
// 65:                description: "Print formulae/casks with fully-qualified names."
// 66:         switch "--no-pull-requests",
// 67:                description: "Do not retrieve pull requests from GitHub."
// 68:         switch "--auto",
// 69:                description: "Read the list of formulae/casks from the tap autobump list.",
// 70:                hidden:      true
// 71:         switch "--no-autobump",
// 72:                description: "Ignore formulae/casks in autobump list (official repositories only)."
// 73:         switch "--formula", "--formulae",
// 74:                description: "Check only formulae."
// 75:         switch "--cask", "--casks",
// 76:                description: "Check only casks."
// 77:         switch "--eval-all",
// 78:                description: "Evaluate all available formulae and casks.",
// 79:                env:         :eval_all,
// 80:                odeprecated: true
// 81:         switch "--repology",
// 82:                description: "Use Repology to check for outdated packages."
// 83:         flag   "--tap=",
// 84:                description: "Check formulae and casks within the given tap, specified as <user>`/`<repo>."
// 85:         switch "--installed",
// 86:                description: "Check formulae and casks that are currently installed."
// 87:         switch "--no-fork",
// 88:                description: "Don't try to fork the repository."
// 89:         switch "--open-pr",
// 90:                description: "Open a pull request for the new version if none have been opened yet."
// 91:         flag   "--start-with=",
// 92:                description: "Letter or word that the list of package results should alphabetically follow."
// 93:         switch "--bump-synced",
// 94:                description: "Bump additional formulae marked as synced with the given formulae."
// 95:
// 96:         conflicts "--formula", "--cask"
// 97:         conflicts "--tap", "--installed"
// 98:         conflicts "--tap", "--no-autobump"
// 99:         conflicts "--installed", "--eval-all"
// 100:         conflicts "--installed", "--auto"
// 101:         conflicts "--no-pull-requests", "--open-pr"
// 102:
// 103:         named_args [:formula, :cask], without_api: true
// 104:       end
// 105:
// 106:       sig { override.void }
// 107:       def run
// 108:         Homebrew.install_bundler_gems!(groups: ["livecheck"])
// 109:
// 110:         Homebrew.with_no_api_env do
// 111:           eval_all = args.eval_all?
// 112:           eval_all ||= args.no_named? && Homebrew::EnvConfig.tap_trust_configured?
// 113:
// 114:           excluded_autobump = []
// 115:           if args.no_autobump? && eval_all
// 116:             excluded_autobump.concat(autobumped_formulae_or_casks(CoreTap.instance)) if args.formula?
// 117:             excluded_autobump.concat(autobumped_formulae_or_casks(CoreCaskTap.instance, casks: true)) if args.cask?
// 118:           end
// 119:
// 120:           formulae_and_casks = if args.auto?
// 121:             raise UsageError, "`--formula` or `--cask` must be passed with `--auto`." if !args.formula? && !args.cask?
// 122:
// 123:             tap_arg = args.tap
// 124:             raise UsageError, "`--tap=` must be passed with `--auto`." if tap_arg.blank?
// 125:
// 126:             tap = Tap.fetch(tap_arg)
// 127:             autobump_list = tap.autobump
// 128:             what = args.cask? ? "casks" : "formulae"
// 129:             raise UsageError, "No autobumped #{what} found." if autobump_list.blank?
// 130:
// 131:             # Only run bump on the first formula in each synced group
// 132:             if args.bump_synced? && args.formula?
// 133:               synced_formulae = Set.new(tap.synced_versions_formulae.flat_map { it.drop(1) })
// 134:             end
// 135:
// 136:             autobump_list.filter_map do |name|
// 137:               qualified_name = "#{tap.name}/#{name}"
// 138:               next Cask::CaskLoader.load(qualified_name) if args.cask?
// 139:               next if synced_formulae&.include?(name)
// 140:
// 141:               Formulary.factory(qualified_name)
// 142:             end
// 143:           elsif args.tap
// 144:             tap = Tap.fetch(args.tap)
// 145:             raise UsageError, "`--tap` requires `--auto` for official taps." if tap.official?
// 146:
// 147:             formulae = args.cask? ? [] : tap.formula_files.map { |path| Formulary.factory(path) }
// 148:             casks = args.formula? ? [] : tap.cask_files.map { |path| Cask::CaskLoader.load(path) }
// 149:             formulae + casks
// 150:           elsif args.installed?
// 151:             formulae = args.cask? ? [] : Formula.installed
// 152:             casks = args.formula? ? [] : Cask::Caskroom.casks
// 153:             formulae + casks
// 154:           elsif args.named.present?
// 155:             T.cast(args.named.to_formulae_and_casks_with_taps, T::Array[T.any(Formula, Cask::Cask)])
// 156:           elsif eval_all
// 157:             formulae = args.cask? ? [] : Formula.all(eval_all:)
// 158:             casks = args.formula? ? [] : Cask::Cask.all(eval_all:)
// 159:             formulae + casks
// 160:           else
// 161:             raise UsageError,
// 162:                   "`brew bump` without named arguments needs `--installed`, `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 163:                   "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 164:           end
// 165:
// 166:           if (start_with = args.start_with)
// 167:             formulae_and_casks.select! do |formula_or_cask|
// 168:               Utils.name_or_token(formula_or_cask).start_with?(start_with)
// 169:             end
// 170:           end
// 171:
// 172:           formulae_and_casks = formulae_and_casks.sort_by do |formula_or_cask|
// 173:             Utils.name_or_token(formula_or_cask)
// 174:           end
// 175:
// 176:           formulae_and_casks -= excluded_autobump
// 177:
// 178:           if args.repology? && !Utils::Curl.curl_supports_tls13?
// 179:             begin
// 180:               Formula["curl"].ensure_installed!(reason: "Repology queries") unless HOMEBREW_BREWED_CURL_PATH.exist?
// 181:             rescue FormulaUnavailableError
// 182:               opoo "A newer `curl` is required for Repology queries."
// 183:             end
// 184:           end
// 185:
// 186:           handle_formulae_and_casks(formulae_and_casks)
// 187:         end
// 188:       end
// 189:
// 190:       sig {
// 191:         params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(T::Boolean)
// 192:       }
// 193:       def skip_ineligible_formulae!(formula_or_cask)
// 194:         if formula_or_cask.is_a?(Formula)
// 195:           skip = formula_or_cask.disabled? || formula_or_cask.head_only?
// 196:           name = formula_or_cask.name
// 197:           text = "Formula is #{formula_or_cask.disabled? ? "disabled" : "HEAD-only"} so not accepting updates.\n"
// 198:         else
// 199:           skip = formula_or_cask.disabled? || formula_or_cask.version.latest?
// 200:           name = formula_or_cask.token
// 201:           text = if formula_or_cask.disabled?
// 202:             "Cask is disabled so not accepting updates.\n"
// 203:           else
// 204:             "Cask uses `version :latest` so `brew bump` cannot check it.\n"
// 205:           end
// 206:         end
// 207:         if (tap = formula_or_cask.tap) && !tap.allow_bump?(name)
// 208:           skip = true
// 209:           text = "#{text.split.first} is autobumped so will have bump PRs opened by BrewTestBot every ~3 hours.\n"
// 210:         end
// 211:         return false unless skip
// 212:
// 213:         ohai name
// 214:         puts text
// 215:         true
// 216:       end
// 217:
// 218:       sig {
// 219:         params(
// 220:           formula_or_cask: T.any(Formula, Cask::Cask),
// 221:           repositories:    T::Array[String],
// 222:           name:            String,
// 223:         ).returns(VersionBumpInfo)
// 224:       }
// 225:       def retrieve_versions_by_arch(formula_or_cask:, repositories:, name:)
// 226:         is_cask_with_blocks = formula_or_cask.is_a?(Cask::Cask) && formula_or_cask.on_system_blocks_exist?
// 227:         type, version_name = if formula_or_cask.is_a?(Formula)
// 228:           [:formula, "formula version:"]
// 229:         else
// 230:           [:cask, "cask version:   "]
// 231:         end
// 232:
// 233:         deprecated = {}
// 234:         current_versions = {}
// 235:         new_versions = {}
// 236:         cooldown_skipped_versions = {}
// 237:
// 238:         repology_latest = repositories.present? ? Repology.latest_version(repositories) : "not found"
// 239:         repology_latest_is_a_version = repology_latest.is_a?(Version)
// 240:
// 241:         # When blocks are absent, arch is not relevant. For consistency, we
// 242:         # simulate the arm architecture.
// 243:         arch_options = is_cask_with_blocks ? OnSystem::ARCH_OPTIONS : [:arm]
// 244:
// 245:         # If the cask restricts to specific architectures via
// 246:         # `depends_on arch:`, only simulate those architectures.
// 247:         if is_cask_with_blocks && formula_or_cask.is_a?(Cask::Cask)
// 248:           arch_deps = formula_or_cask.depends_on.arch
// 249:           if arch_deps.present?
// 250:             supported_archs = arch_deps.filter_map { |dep| dep[:type] } & arch_options
// 251:             arch_options = supported_archs if supported_archs.present?
// 252:           end
// 253:         end
// 254:
// 255:         arch_options.each do |arch|
// 256:           SimulateSystem.with(arch:) do
// 257:             version_key = is_cask_with_blocks ? arch : :general
// 258:
// 259:             # We reload the formula/cask here to ensure we're getting the
// 260:             # correct version for the current arch
// 261:             if formula_or_cask.is_a?(Formula)
// 262:               loaded_formula_or_cask = formula_or_cask
// 263:               stable = loaded_formula_or_cask.stable
// 264:               raise "unexpected nil stable" unless stable
// 265:
// 266:               current_version_value = stable.version
// 267:             else
// 268:               sourcefile_path = formula_or_cask.sourcefile_path
// 269:               raise "unexpected nil sourcefile_path" unless sourcefile_path
// 270:
// 271:               loaded_formula_or_cask = Cask::CaskLoader.load(sourcefile_path)
// 272:               current_version_value = Version.new(loaded_formula_or_cask.version)
// 273:             end
// 274:
// 275:             deprecated[version_key] = loaded_formula_or_cask.deprecated?
// 276:             formula_or_cask_has_livecheck = loaded_formula_or_cask.livecheck_defined?
// 277:
// 278:             livecheck_latest, cooldown_skipped = livecheck_result(loaded_formula_or_cask, current_version_value)
// 279:             cooldown_skipped_versions[version_key] = cooldown_skipped if cooldown_skipped
// 280:             livecheck_latest_is_a_version = livecheck_latest.is_a?(Version)
// 281:
// 282:             new_version_value = if (livecheck_latest_is_a_version &&
// 283:                                     Livecheck::LivecheckVersion.create(formula_or_cask, livecheck_latest) >=
// 284:                                     Livecheck::LivecheckVersion.create(formula_or_cask, current_version_value)) ||
// 285:                                    current_version_value == "latest" ||
// 286:                                    message?(livecheck_latest)
// 287:               livecheck_latest
// 288:             elsif repology_latest_is_a_version &&
// 289:                   !formula_or_cask_has_livecheck &&
// 290:                   repology_latest > current_version_value &&
// 291:                   current_version_value != "latest"
// 292:               repology_latest
// 293:             end.presence
// 294:
// 295:             # Fall back to the upstream version if there isn't a new version
// 296:             # value at this point, as this will allow us to surface an upstream
// 297:             # version that's lower than the current version.
// 298:             new_version_value ||= livecheck_latest if livecheck_latest_is_a_version
// 299:             new_version_value ||= repology_latest if repology_latest_is_a_version && !formula_or_cask_has_livecheck
// 300:
// 301:             # Store old and new versions
// 302:             current_versions[version_key] = current_version_value
// 303:             new_versions[version_key] = new_version_value
// 304:           end
// 305:         end
// 306:
// 307:         # Consolidate into a single general version when only one architecture
// 308:         # was simulated (e.g. `depends_on arch:` restricts to a single arch) or
// 309:         # when the arm and intel versions are identical, as happens with casks
// 310:         # where only the checksums differ.
// 311:         if is_cask_with_blocks && arch_options.length == 1
// 312:           single_arch = arch_options[0]
// 313:           current_versions = { general: current_versions[single_arch] }
// 314:           new_versions = { general: new_versions[single_arch] }
// 315:           cooldown_skipped_versions = { general: cooldown_skipped_versions[single_arch] }.compact
// 316:         else
// 317:           if current_versions[:arm].present? && current_versions[:arm] == current_versions[:intel]
// 318:             current_versions = { general: current_versions[:arm] }
// 319:           end
// 320:           if new_versions[:arm].present? && new_versions[:arm] == new_versions[:intel]
// 321:             new_versions = { general: new_versions[:arm] }
// 322:           end
// 323:           if cooldown_skipped_versions[:arm].present? &&
// 324:              cooldown_skipped_versions[:arm] == cooldown_skipped_versions[:intel]
// 325:             cooldown_skipped_versions = { general: cooldown_skipped_versions[:arm] }
// 326:           end
// 327:         end
// 328:
// 329:         current_version = BumpVersionParser.new(general: current_versions[:general],
// 330:                                                 arm:     current_versions[:arm],
// 331:                                                 intel:   current_versions[:intel])
// 332:
// 333:         begin
// 334:           new_version = BumpVersionParser.new(general: new_versions[:general],
// 335:                                               arm:     new_versions[:arm],
// 336:                                               intel:   new_versions[:intel])
// 337:         rescue
// 338:           # When livecheck fails, we fail gracefully. Otherwise VersionParser
// 339:           # will raise a usage error
// 340:           new_version = BumpVersionParser.new(general: "unable to get versions")
// 341:         end
// 342:
// 343:         compare_versions(current_version, new_version, formula_or_cask) =>
// 344:           { multiple_versions:, newer_than_upstream: }
// 345:         if !multiple_versions[:current] && deprecated[:general].nil?
// 346:           deprecated = { general: deprecated[:arm] || deprecated[:intel] || false }
// 347:         end
// 348:
// 349:         # Collect resource version info for formulae with resources that have explicit livecheck blocks
// 350:         resource_versions = if formula_or_cask.is_a?(Formula) && new_version.general.is_a?(Version)
// 351:           collect_resource_versions(formula_or_cask, new_version.general.to_s)
// 352:         else
// 353:           []
// 354:         end
// 355:
// 356:         if !args.no_pull_requests? &&
// 357:            !newer_than_upstream.all? { |_k, v| v == true }
// 358:           pull_request_version = nil
// 359:           if (new_version_arm = new_version.arm) &&
// 360:              !message?(new_version_arm) &&
// 361:              (new_version_arm != current_version.arm)
// 362:             # We use the ARM version for the pull request version even if there
// 363:             # are multiple arch versions to be consistent with the behavior of
// 364:             # bump-cask-pr.
// 365:             pull_request_version = new_version_arm.to_s
// 366:           elsif (new_version_intel = new_version.intel) &&
// 367:                 !message?(new_version_intel) &&
// 368:                 (new_version_intel != current_version.intel)
// 369:             pull_request_version = new_version_intel.to_s
// 370:           elsif (new_version_general = new_version.general) &&
// 371:                 !message?(new_version_general) &&
// 372:                 (new_version_general != current_version.general)
// 373:             pull_request_version = new_version_general.to_s
// 374:           end
// 375:
// 376:           if pull_request_version
// 377:             duplicate_pull_requests = retrieve_pull_requests(
// 378:               formula_or_cask,
// 379:               name,
// 380:               version: pull_request_version,
// 381:             )
// 382:
// 383:             maybe_duplicate_pull_requests = if duplicate_pull_requests.nil?
// 384:               retrieve_pull_requests(formula_or_cask, name)
// 385:             end
// 386:           end
// 387:         end
// 388:
// 389:         VersionBumpInfo.new(
// 390:           type:,
// 391:           deprecated:,
// 392:           multiple_versions:,
// 393:           version_name:,
// 394:           current_version:,
// 395:           new_version:,
// 396:           resource_versions:,
// 397:           repology_latest:,
// 398:           newer_than_upstream:,
// 399:           cooldown_skipped_versions:,
// 400:           duplicate_pull_requests:,
// 401:           maybe_duplicate_pull_requests:,
// 402:         )
// 403:       end
// 404:
// 405:       sig {
// 406:         params(
// 407:           formula_or_cask: T.any(Formula, Cask::Cask),
// 408:           name:            String,
// 409:           repositories:    T::Array[String],
// 410:           ambiguous_cask:  T::Boolean,
// 411:         ).void
// 412:       }
// 413:       def retrieve_and_display_info_and_open_pr(formula_or_cask, name, repositories, ambiguous_cask: false)
// 414:         version_info = retrieve_versions_by_arch(formula_or_cask:,
// 415:                                                  repositories:,
// 416:                                                  name:)
// 417:
// 418:         deprecated = version_info.deprecated
// 419:         multiple_versions = version_info.multiple_versions
// 420:         current_version = version_info.current_version
// 421:         new_version = version_info.new_version
// 422:         repology_latest = version_info.repology_latest
// 423:         newer_than_upstream = version_info.newer_than_upstream
// 424:         cooldown_skipped_version = version_info.cooldown_skipped_versions.values.max
// 425:         duplicate_pull_requests = version_info.duplicate_pull_requests
// 426:         maybe_duplicate_pull_requests = version_info.maybe_duplicate_pull_requests
// 427:
// 428:         versions_equal = (new_version == current_version)
// 429:         all_newer_than_upstream = newer_than_upstream.all? { |_k, v| v == true }
// 430:
// 431:         title_name = ambiguous_cask ? "#{name} (cask)" : name
// 432:         title = if (repology_latest == current_version.general || !repology_latest.is_a?(Version)) && versions_equal
// 433:           if cooldown_skipped_version
// 434:             "#{title_name} #{Tty.yellow}has a new version in release cooldown#{Tty.reset}"
// 435:           else
// 436:             "#{title_name} #{Tty.green}is up to date!#{Tty.reset}"
// 437:           end
// 438:         else
// 439:           title_name
// 440:         end
// 441:
// 442:         # Conditionally format output based on type of formula_or_cask
// 443:         current_versions = if multiple_versions[:current]
// 444:           "arm:   #{current_version.arm || current_version.general}" \
// 445:             "#{NEWER_THAN_UPSTREAM_MSG if newer_than_upstream[:arm]}" \
// 446:             "#{" (deprecated)" if deprecated[:arm]}" \
// 447:             "\n                          " \
// 448:             "intel: #{current_version.intel || current_version.general}" \
// 449:             "#{NEWER_THAN_UPSTREAM_MSG if newer_than_upstream[:intel]}" \
// 450:             "#{" (deprecated)" if deprecated[:intel]}"
// 451:         else
// 452:           "#{current_version.general}" \
// 453:             "#{NEWER_THAN_UPSTREAM_MSG if newer_than_upstream[:general]}" \
// 454:             "#{" (deprecated)" if deprecated[:general]}"
// 455:         end
// 456:
// 457:         new_versions = if multiple_versions[:new] && new_version.arm && new_version.intel
// 458:           "arm:   #{new_version.arm}
// 459:                           intel: #{new_version.intel}"
// 460:         else
// 461:           new_version.general
// 462:         end
// 463:
// 464:         throttled = formula_or_cask.livecheck.throttle || formula_or_cask.livecheck.throttle_days
// 465:         latest_versions = if cooldown_skipped_version
// 466:           cooldown_days = Utils.pluralize("day", Homebrew::RELEASE_COOLDOWN_DAYS, include_count: true)
// 467:           "#{cooldown_skipped_version} (released less than #{cooldown_days} ago)"
// 468:         else
// 469:           "#{new_versions}#{" (throttled)" if throttled}"
// 470:         end
// 471:         ohai title
// 472:         puts <<~EOS
// 473:           Current #{version_info.version_name}  #{current_versions}
// 474:           Latest livecheck version: #{latest_versions}
// 475:         EOS
// 476:         puts "Bump-ready version:       #{new_versions}" if cooldown_skipped_version
// 477:         puts <<~EOS unless skip_repology?(formula_or_cask)
// 478:           Latest Repology version:  #{repology_latest}
// 479:         EOS
// 480:         if formula_or_cask.is_a?(Formula) && formula_or_cask.synced_with_other_formulae?
// 481:           outdated_synced_formulae = synced_with(formula_or_cask, new_version.general)
// 482:           if !args.bump_synced? && outdated_synced_formulae.present?
// 483:             puts <<~EOS
// 484:               Version syncing:          #{title_name} version should be kept in sync with
// 485:                                         #{outdated_synced_formulae.join(", ")}.
// 486:             EOS
// 487:           end
// 488:         end
// 489:
// 490:         # Display resource version info for formulae
// 491:         resource_versions = version_info.resource_versions
// 492:         puts "Resources with livecheck:" unless resource_versions.empty?
// 493:         resource_versions.each do |rv|
// 494:           status = if rv.latest_version.nil?
// 495:             "#{Tty.red}unable to get versions#{Tty.reset}"
// 496:           elsif rv.newer_than_upstream
// 497:             "#{Tty.red}#{rv.current_version}#{Tty.reset} -> #{rv.latest_version}#{NEWER_THAN_UPSTREAM_MSG}"
// 498:           elsif rv.outdated
// 499:             "#{rv.current_version} -> #{Tty.green}#{rv.latest_version}#{Tty.reset}"
// 500:           else
// 501:             "#{rv.current_version} -> #{rv.latest_version}"
// 502:           end
// 503:           puts "  #{rv.name}: #{status}"
// 504:         end
// 505:
// 506:         if !args.no_pull_requests? &&
// 507:            !message?(new_version.general) &&
// 508:            !versions_equal &&
// 509:            !all_newer_than_upstream
// 510:           if duplicate_pull_requests
// 511:             duplicate_pull_requests_text = duplicate_pull_requests
// 512:           elsif maybe_duplicate_pull_requests
// 513:             duplicate_pull_requests_text = "none"
// 514:             maybe_duplicate_pull_requests_text = maybe_duplicate_pull_requests
// 515:           else
// 516:             duplicate_pull_requests_text = "none"
// 517:             maybe_duplicate_pull_requests_text = "none"
// 518:           end
// 519:
// 520:           puts "Duplicate pull requests:  #{duplicate_pull_requests_text}"
// 521:           if maybe_duplicate_pull_requests_text
// 522:             puts "Maybe duplicate pull requests: #{maybe_duplicate_pull_requests_text}"
// 523:           end
// 524:         end
// 525:
// 526:         if !args.open_pr? ||
// 527:            message?(new_version.general) ||
// 528:            all_newer_than_upstream
// 529:           return
// 530:         end
// 531:
// 532:         if GitHub.too_many_open_prs?(formula_or_cask.tap)
// 533:           odie "You have too many PRs open: close or merge some first!"
// 534:         end
// 535:
// 536:         if repology_latest.is_a?(Version) &&
// 537:            repology_latest > current_version.general &&
// 538:            repology_latest > new_version.general &&
// 539:            formula_or_cask.livecheck_defined?
// 540:           puts "#{title_name} was not bumped to the Repology version because it has a `livecheck` block."
// 541:         end
// 542:         if new_version.blank? || versions_equal ||
// 543:            (!new_version.general.is_a?(Version) && !multiple_versions[:new])
// 544:           return
// 545:         end
// 546:
// 547:         return if duplicate_pull_requests.present?
// 548:
// 549:         version_args = version_args_for_bump(current_version:, new_version:, multiple_versions:, name:)
// 550:         return if version_args.blank?
// 551:
// 552:         bump_pr_args = [
// 553:           "bump-#{version_info.type}-pr",
// 554:           name,
// 555:           *version_args,
// 556:           "--no-browse",
// 557:           "--message=Created by `brew bump`",
// 558:         ]
// 559:
// 560:         bump_pr_args << "--no-fork" if args.no_fork?
// 561:
// 562:         if args.bump_synced? && outdated_synced_formulae.present?
// 563:           bump_pr_args << "--bump-synced=#{outdated_synced_formulae.join(",")}"
// 564:         end
// 565:
// 566:         # Pass all livecheck-checked resources to bump-formula-pr, including
// 567:         # up-to-date and failed ones, so it can track what was checked
// 568:         if version_info.type == :formula && !resource_versions.empty?
// 569:           require "json"
// 570:           resource_data = resource_versions.map do |rv|
// 571:             { name: rv.name, current_version: rv.current_version, latest_version: rv.latest_version }
// 572:           end
// 573:           bump_pr_args << "--resource-versions=#{resource_data.to_json}"
// 574:         end
// 575:
// 576:         result = system HOMEBREW_BREW_FILE, *bump_pr_args
// 577:         Homebrew.failed = true unless result
// 578:       end
// 579:
// 580:       sig {
// 581:         params(
// 582:           current_version:   BumpVersionParser,
// 583:           new_version:       BumpVersionParser,
// 584:           multiple_versions: T::Hash[Symbol, T::Boolean],
// 585:           name:              String,
// 586:         ).returns(T::Array[String])
// 587:       }
// 588:       def version_args_for_bump(current_version:, new_version:, multiple_versions:, name:)
// 589:         version_args = T.let([], T::Array[String])
// 590:
// 591:         if multiple_versions[:new]
// 592:           (BumpVersionParser::VERSION_SYMBOLS - [:general]).each do |arch|
// 593:             new_arch_version = new_version.public_send(arch)
// 594:             next if new_arch_version.blank? || message?(new_arch_version)
// 595:
// 596:             current_arch_version = if multiple_versions[:current]
// 597:               current_version.public_send(arch)
// 598:             else
// 599:               current_version.general
// 600:             end
// 601:             next if current_arch_version.blank? || new_arch_version <= current_arch_version
// 602:
// 603:             version_args << "--version-#{arch}=#{new_arch_version}"
// 604:           end
// 605:         elsif multiple_versions[:current]
// 606:           if (new_version_general = new_version.general) && !message?(new_version_general)
// 607:             (BumpVersionParser::VERSION_SYMBOLS - [:general]).each do |arch|
// 608:               current_arch_version = current_version.public_send(arch)
// 609:               next if current_arch_version.blank? || new_version_general <= current_arch_version
// 610:
// 611:               version_args << "--version-#{arch}=#{new_version_general}"
// 612:             end
// 613:           end
// 614:
// 615:           opoo "`#{name}` needs to be manually updated using one version" if version_args.blank?
// 616:         elsif new_version.general
// 617:           version_args << "--version=#{new_version.general}"
// 618:         end
// 619:
// 620:         version_args
// 621:       end
// 622:
// 623:       sig {
// 624:         params(
// 625:           current_version: BumpVersionParser,
// 626:           new_version:     BumpVersionParser,
// 627:           formula_or_cask: T.any(Formula, Cask::Cask),
// 628:         ).returns(T::Hash[Symbol, T::Hash[Symbol, T::Boolean]])
// 629:       }
// 630:       def compare_versions(current_version, new_version, formula_or_cask)
// 631:         current_versions = {}
// 632:         new_versions = {}
// 633:         BumpVersionParser::VERSION_SYMBOLS.each do |type|
// 634:           current_version_value = current_version.public_send(type)
// 635:           if current_version_value
// 636:             current_versions[type] = Livecheck::LivecheckVersion.create(formula_or_cask, current_version_value)
// 637:           end
// 638:
// 639:           new_version_value = new_version.public_send(type)
// 640:           if message?(new_version_value)
// 641:             # Store a string, so we can easily tell when a value is a message
// 642:             # rather than a version
// 643:             new_versions[type] = new_version_value.to_s
// 644:           elsif new_version_value
// 645:             new_versions[type] = Livecheck::LivecheckVersion.create(formula_or_cask, new_version_value)
// 646:           end
// 647:         end
// 648:
// 649:         multiple_versions = {
// 650:           current: current_versions.length > 1,
// 651:           new:     new_versions.length > 1,
// 652:         }
// 653:
// 654:         current_version_types = current_versions.keys
// 655:         new_version_types = new_versions.keys
// 656:         comparison_pairs = {}
// 657:
// 658:         # Compare the same version types when shared by current/new versions
// 659:         (current_version_types & new_version_types).each do |type|
// 660:           comparison_pairs[type] = [current_versions[type], new_versions[type]]
// 661:         end
// 662:
// 663:         # Compare current versions to `new_version.general` when the current
// 664:         # version differs by arch but the new version does not
// 665:         if multiple_versions[:current] && new_versions.key?(:general)
// 666:           (current_version_types - new_version_types).each do |type|
// 667:             comparison_pairs[type] ||= [current_versions[type], new_versions[:general]]
// 668:           end
// 669:         end
// 670:
// 671:         # Compare `current_version.general` to the highest new version when the
// 672:         # current version does not differ by arch but the new version does
// 673:         if !comparison_pairs.key?(:general) &&
// 674:            current_versions.key?(:general) &&
// 675:            multiple_versions[:new]
// 676:           highest_new_version = (new_version_types - current_version_types).filter_map do |type|
// 677:             version = new_versions[type]
// 678:             next unless version.is_a?(Livecheck::LivecheckVersion)
// 679:
// 680:             version
// 681:           end.max
// 682:           comparison_pairs[:general] = [current_versions[:general], highest_new_version]
// 683:         end
// 684:
// 685:         newer_than_upstream = {}
// 686:         comparison_pairs.each do |version_type, (current_value, new_value)|
// 687:           newer_than_upstream[version_type] = if new_value.is_a?(Livecheck::LivecheckVersion)
// 688:             (current_value > new_value)
// 689:           else
// 690:             false
// 691:           end
// 692:         end
// 693:
// 694:         { multiple_versions:, newer_than_upstream: }
// 695:       end
// 696:
// 697:       sig { params(value: T.nilable(T.any(Version, Cask::DSL::Version, String))).returns(T::Boolean) }
// 698:       def message?(value)
// 699:         return false if !value.is_a?(Cask::DSL::Version) && !value.is_a?(String)
// 700:
// 701:         value.match?(LIVECHECK_MESSAGE_REGEX)
// 702:       end
// 703:
// 704:       # Identifies the highest upstream version that has been released before
// 705:       # the cooldown interval.
// 706:       #
// 707:       # @param version_info the return hash from `Livecheck.latest_version`
// 708:       # @param current the current version
// 709:       sig {
// 710:         params(
// 711:           version_info: T::Hash[Symbol, T.untyped],
// 712:           current:      T.nilable(T.any(Version, Cask::DSL::Version)),
// 713:         ).returns(T.nilable(Version))
// 714:       }
// 715:       def version_with_cooldown(version_info, current = nil)
// 716:         return unless current
// 717:
// 718:         latest = Version.new(version_info[:latest]) if version_info[:latest]
// 719:         return unless latest
// 720:         return if latest <= current
// 721:
// 722:         strategy = T.cast(version_info.dig(:meta, :strategy), T.nilable(String))
// 723:         case strategy
// 724:         when "Npm"
// 725:           url = version_info.dig(:meta, :url, :strategy)&.delete_suffix("/latest")
// 726:           return unless url
// 727:
// 728:           stdout, _stderr, status = Utils::Curl.curl_output(*DEFAULT_CURL_ARGS, url, **DEFAULT_CURL_OPTIONS).to_a
// 729:           return unless status.success?
// 730:           return if (content = stdout.scrub).blank?
// 731:
// 732:           json = Homebrew::Livecheck::Strategy::Json.parse_json(content)
// 733:           release_dates = json["time"]&.except("created", "modified")
// 734:                                       &.transform_values { |v| DateTime.parse(v) }
// 735:           return unless release_dates.present?
// 736:
// 737:           current_str = current.to_s
// 738:           current_is_prerelease = current_str.include?("-")
// 739:           cooldown_interval = (DateTime.now - Homebrew::RELEASE_COOLDOWN_DAYS)
// 740:           release_dates.sort_by { |_, date| date }.reverse_each do |version_str, date|
// 741:             version = Version.new(version_str)
// 742:             return version if version_str == current_str
// 743:             next if (version > latest) || (version < current)
// 744:
// 745:             # TODO: Properly handle prerelease version comparison
// 746:             next if !current_is_prerelease && version_str.include?("-")
// 747:
// 748:             return version if date < cooldown_interval
// 749:           end
// 750:         when "Pypi"
// 751:           url = version_info.dig(:meta, :url, :strategy)
// 752:           original_url = version_info.dig(:meta, :url, :original)
// 753:           return if !url || !original_url
// 754:
// 755:           suffix = Homebrew::Livecheck::Strategy::Pypi::URL_MATCH_REGEX.match(original_url)&.[](:suffix)
// 756:           return unless suffix
// 757:
// 758:           content = version_info[:content]
// 759:           unless content
// 760:             stdout, _stderr, status = Utils::Curl.curl_output(*DEFAULT_CURL_ARGS, url, **DEFAULT_CURL_OPTIONS).to_a
// 761:             return unless status.success?
// 762:
// 763:             content = stdout.scrub
// 764:           end
// 765:           return if content.blank?
// 766:
// 767:           json = Homebrew::Livecheck::Strategy::Json.parse_json(content)
// 768:           return unless (releases = json["releases"])
// 769:
// 770:           current_str = current.to_s
// 771:           current_is_prerelease = current_str.match?(PYPI_UNSTABLE_VERSION_REGEX)
// 772:           cooldown_interval = (DateTime.now - Homebrew::RELEASE_COOLDOWN_DAYS)
// 773:           releases.sort_by { |k, _| Version.new(k) }.reverse_each do |version_str, assets|
// 774:             version = Version.new(version_str)
// 775:             return version if version_str == current_str
// 776:             next if (version > latest) || (version < current)
// 777:             next if !current_is_prerelease && version_str.match?(PYPI_UNSTABLE_VERSION_REGEX)
// 778:
// 779:             assets.each do |asset|
// 780:               next if asset["yanked"]
// 781:               next unless asset["url"]&.end_with?(suffix)
// 782:               next unless (date_str = asset["upload_time_iso_8601"])
// 783:
// 784:               date = DateTime.parse(date_str)
// 785:               return version if date < cooldown_interval
// 786:             end
// 787:           end
// 788:         when "RubyGems"
// 789:           url = version_info.dig(:meta, :url, :strategy)&.sub(%r{/latest\.json\z}, ".json")
// 790:           original_url = version_info.dig(:meta, :url, :original)
// 791:           return if !url || !original_url
// 792:
// 793:           match = Homebrew::Livecheck::Strategy::RubyGems::URL_MATCH_REGEX.match(original_url)
// 794:           return unless match
// 795:
// 796:           stdout, _stderr, status = Utils::Curl.curl_output(*DEFAULT_CURL_ARGS, url, **DEFAULT_CURL_OPTIONS).to_a
// 797:           return unless status.success?
// 798:           return if (content = stdout.scrub).blank?
// 799:
// 800:           json = Homebrew::Livecheck::Strategy::Json.parse_json(content)
// 801:           return unless json.is_a?(Array)
// 802:
// 803:           current_str = current.to_s
// 804:           cooldown_interval = (DateTime.now - Homebrew::RELEASE_COOLDOWN_DAYS)
// 805:           json.sort_by { |release| Version.new(release["number"]) }.reverse_each do |release|
// 806:             next if release["platform"] != (match[:platform] || "ruby")
// 807:
// 808:             version_str = release["number"]
// 809:             version = Version.new(version_str)
// 810:             return version if version_str == current_str
// 811:             next if (version > latest) || (version < current)
// 812:             next if release["prerelease"] &&
// 813:                     !(Gem::Version.correct?(current_str) && Gem::Version.new(current_str).prerelease?)
// 814:             next unless (date_str = release["created_at"])
// 815:
// 816:             return version if DateTime.parse(date_str) < cooldown_interval
// 817:           end
// 818:         end
// 819:       end
// 820:
// 821:       private
// 822:
// 823:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(T::Boolean) }
// 824:       def skip_repology?(formula_or_cask)
// 825:         return true unless args.repology?
// 826:
// 827:         (ENV["CI"].present? && args.open_pr? && formula_or_cask.livecheck_defined?) ||
// 828:           (formula_or_cask.is_a?(Formula) && formula_or_cask.versioned_formula?)
// 829:       end
// 830:
// 831:       sig { params(formulae_and_casks: T::Array[T.any(Formula, Cask::Cask)]).void }
// 832:       def handle_formulae_and_casks(formulae_and_casks)
// 833:         Livecheck.load_other_tap_strategies(formulae_and_casks)
// 834:
// 835:         ambiguous_casks = []
// 836:         if !args.formula? && !args.cask?
// 837:           ambiguous_casks = formulae_and_casks
// 838:                             .group_by { |item| Livecheck.package_or_resource_name(item, full_name: true) }
// 839:                             .values
// 840:                             .select { |items| items.length > 1 }
// 841:                             .flatten
// 842:                             .grep(Cask::Cask)
// 843:         end
// 844:
// 845:         ambiguous_names = []
// 846:         unless args.full_name?
// 847:           ambiguous_names = (formulae_and_casks - ambiguous_casks)
// 848:                             .group_by { |item| Livecheck.package_or_resource_name(item) }
// 849:                             .values
// 850:                             .select { |items| items.length > 1 }
// 851:                             .flatten
// 852:         end
// 853:
// 854:         consecutive_github_api_errors = 0
// 855:         formulae_and_casks.each_with_index do |formula_or_cask, i|
// 856:           puts if i.positive?
// 857:           next if skip_ineligible_formulae!(formula_or_cask)
// 858:
// 859:           use_full_name = args.full_name? || ambiguous_names.include?(formula_or_cask)
// 860:           name = Livecheck.package_or_resource_name(formula_or_cask, full_name: use_full_name)
// 861:           repository = if formula_or_cask.is_a?(Formula)
// 862:             Repology::HOMEBREW_CORE
// 863:           else
// 864:             Repology::HOMEBREW_CASK
// 865:           end
// 866:
// 867:           package_data = Repology.single_package_query(name, repository:) unless skip_repology?(formula_or_cask)
// 868:
// 869:           github_api_retries = 0
// 870:           begin
// 871:             retrieve_and_display_info_and_open_pr(
// 872:               formula_or_cask,
// 873:               name,
// 874:               package_data&.values&.first || [],
// 875:               ambiguous_cask: ambiguous_casks.include?(formula_or_cask),
// 876:             )
// 877:             consecutive_github_api_errors = 0
// 878:           rescue GitHub::API::RateLimitExceededError => e
// 879:             GitHub::API.sleep_for_rate_limit(e)
// 880:             retry
// 881:           rescue GitHub::API::AuthenticationFailedError
// 882:             # Retrying this for the remaining packages cannot succeed, so stop now.
// 883:             raise
// 884:           rescue GitHub::API::Error => e
// 885:             github_api_retries += 1
// 886:             if github_api_retries <= MAX_GITHUB_API_RETRIES
// 887:               Utils.exponential_backoff_sleep(github_api_retries) do |wait|
// 888:                 onoe "#{name}: retrying in #{wait}s after a GitHub API error: #{e}"
// 889:               end
// 890:               retry
// 891:             end
// 892:
// 893:             consecutive_github_api_errors += 1
// 894:             if consecutive_github_api_errors >= MAX_CONSECUTIVE_GITHUB_API_ERRORS
// 895:               odie "Aborting after #{consecutive_github_api_errors} consecutive GitHub API errors: #{e}"
// 896:             end
// 897:
// 898:             onoe "#{name}: skipped after a GitHub API error: #{e}"
// 899:           end
// 900:         end
// 901:       end
// 902:
// 903:       # Returns the new version (or a message string) and the newest upstream
// 904:       # version skipped due to the release cooldown, if any.
// 905:       sig {
// 906:         params(
// 907:           formula_or_cask: T.any(Formula, Cask::Cask),
// 908:           current:         T.nilable(T.any(Version, Cask::DSL::Version)),
// 909:         ).returns([T.any(Version, String), T.nilable(Version)])
// 910:       }
// 911:       def livecheck_result(formula_or_cask, current)
// 912:         name = Livecheck.package_or_resource_name(formula_or_cask)
// 913:
// 914:         referenced_formula_or_cask, = Livecheck.resolve_livecheck_reference(
// 915:           formula_or_cask,
// 916:           full_name: false,
// 917:           debug:     false,
// 918:         )
// 919:
// 920:         # Check skip conditions for a referenced formula/cask
// 921:         if referenced_formula_or_cask
// 922:           skip_info = Livecheck::SkipConditions.referenced_skip_information(
// 923:             referenced_formula_or_cask,
// 924:             name,
// 925:             full_name: false,
// 926:             verbose:   false,
// 927:           )
// 928:         end
// 929:
// 930:         skip_info ||= Livecheck::SkipConditions.skip_information(
// 931:           formula_or_cask,
// 932:           full_name: false,
// 933:           verbose:   false,
// 934:         )
// 935:
// 936:         if skip_info.present?
// 937:           skip_status = skip_info[:status]
// 938:           skip_messages = skip_info[:messages]
// 939:           skip_message = skip_messages.join("; ") if skip_messages.present?
// 940:           return "error: #{skip_message}", nil if skip_status == "error" && skip_message
// 941:
// 942:           return "skipped - #{skip_message || skip_status}", nil
// 943:         end
// 944:
// 945:         version_info = Livecheck.latest_version(
// 946:           formula_or_cask,
// 947:           referenced_formula_or_cask:,
// 948:           json: true, full_name: false, verbose: true, debug: false
// 949:         )
// 950:         return "unable to get versions", nil if version_info.blank?
// 951:
// 952:         if !version_info.key?(:latest_throttled)
// 953:           latest = Version.new(version_info[:latest])
// 954:           cooldown_version = version_with_cooldown(version_info, current)
// 955:           cooldown_skipped = (latest if cooldown_version && cooldown_version < latest)
// 956:           [cooldown_version || latest, cooldown_skipped]
// 957:         elsif version_info[:latest_throttled].nil?
// 958:           ["unable to get throttled versions", nil]
// 959:         else
// 960:           [Version.new(version_info[:latest_throttled]), nil]
// 961:         end
// 962:       rescue => e
// 963:         ["error: #{e}", nil]
// 964:       end
// 965:
// 966:       sig {
// 967:         params(
// 968:           formula_or_cask: T.any(Formula, Cask::Cask),
// 969:           name:            String,
// 970:           version:         T.nilable(String),
// 971:         ).returns T.nilable(T.any(T::Array[String], String))
// 972:       }
// 973:       def retrieve_pull_requests(formula_or_cask, name, version: nil)
// 974:         tap_remote_repo = formula_or_cask.tap&.remote_repository || formula_or_cask.tap&.full_name
// 975:         odie "unexpected nil tap remote repository" if tap_remote_repo.nil?
// 976:
// 977:         pull_requests = begin
// 978:           GitHub.fetch_pull_requests(name, tap_remote_repo, version:)
// 979:         rescue GitHub::API::ValidationFailedError => e
// 980:           odebug "Error fetching pull requests for #{formula_or_cask} #{name}: #{e}"
// 981:           nil
// 982:         end
// 983:         return if pull_requests.blank?
// 984:
// 985:         pull_requests.map { |pr| "#{pr["title"]} (#{Formatter.url(pr["html_url"])})" }.join(", ")
// 986:       end
// 987:
// 988:       sig {
// 989:         params(
// 990:           formula:                Formula,
// 991:           formula_latest_version: String,
// 992:         ).returns(T::Array[ResourceVersionInfo])
// 993:       }
// 994:       def collect_resource_versions(formula, formula_latest_version)
// 995:         resource_versions = []
// 996:
// 997:         formula.resources.each do |resource|
// 998:           next unless resource.livecheck_defined?
// 999:           next if resource.livecheck.skip?
// 1000:
// 1001:           # Resources that reference :parent track the formula version directly
// 1002:           if resource.livecheck.formula == :parent
// 1003:             current = resource.version.to_s
// 1004:             resource_versions << ResourceVersionInfo.new(
// 1005:               name:                resource.name,
// 1006:               current_version:     current,
// 1007:               latest_version:      formula_latest_version,
// 1008:               outdated:            Version.new(current) < Version.new(formula_latest_version),
// 1009:               newer_than_upstream: Version.new(current) > Version.new(formula_latest_version),
// 1010:             )
// 1011:             next
// 1012:           end
// 1013:
// 1014:           resource_info = Livecheck.resource_version(
// 1015:             resource,
// 1016:             formula_latest_version,
// 1017:             json:      true,
// 1018:             full_name: false,
// 1019:             debug:     false,
// 1020:             quiet:     true,
// 1021:             verbose:   false,
// 1022:           )
// 1023:
// 1024:           if resource_info.empty? || resource_info[:status] == "error"
// 1025:             resource_versions << ResourceVersionInfo.new(
// 1026:               name:                resource.name,
// 1027:               current_version:     resource.version.to_s,
// 1028:               latest_version:      nil,
// 1029:               outdated:            false,
// 1030:               newer_than_upstream: false,
// 1031:             )
// 1032:             next
// 1033:           end
// 1034:
// 1035:           version_info = resource_info[:version]
// 1036:           next if version_info.blank?
// 1037:
// 1038:           resource_versions << ResourceVersionInfo.new(
// 1039:             name:                resource.name,
// 1040:             current_version:     version_info[:current],
// 1041:             latest_version:      version_info[:latest],
// 1042:             outdated:            version_info[:outdated] == true,
// 1043:             newer_than_upstream: version_info[:newer_than_upstream] == true,
// 1044:           )
// 1045:         end
// 1046:
// 1047:         resource_versions
// 1048:       end
// 1049:
// 1050:       sig {
// 1051:         params(
// 1052:           formula:     Formula,
// 1053:           new_version: T.nilable(T.any(Version, Cask::DSL::Version)),
// 1054:         ).returns(T::Array[String])
// 1055:       }
// 1056:       def synced_with(formula, new_version)
// 1057:         synced_with = []
// 1058:
// 1059:         formula.tap&.synced_versions_formulae&.each do |synced_formulae|
// 1060:           next unless synced_formulae.include?(formula.name)
// 1061:
// 1062:           synced_formulae.each do |synced_formula|
// 1063:             synced_formula = Formulary.factory(synced_formula)
// 1064:             next if synced_formula == formula.name
// 1065:
// 1066:             synced_with << synced_formula.name if synced_formula.version != new_version
// 1067:           end
// 1068:         end
// 1069:
// 1070:         synced_with
// 1071:       end
// 1072:
// 1073:       sig { params(tap: Tap, casks: T::Boolean).returns(T::Array[T.any(Formula, Cask::Cask)]) }
// 1074:       def autobumped_formulae_or_casks(tap, casks: false)
// 1075:         autobump_list = tap.autobump
// 1076:         autobump_list.map do |name|
// 1077:           qualified_name = "#{tap.name}/#{name}"
// 1078:           if casks
// 1079:             Cask::CaskLoader.load(qualified_name)
// 1080:           else
// 1081:             Formulary.factory(qualified_name)
// 1082:           end
// 1083:         end
// 1084:       end
// 1085:     end
// 1086:   end
// 1087: end
