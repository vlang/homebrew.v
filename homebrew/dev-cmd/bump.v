module dev_cmd

import ruby
import homebrew as brew
import json2

// Translated from Homebrew/brew `dev-cmd/bump.rb`.

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

fn bump_nil_value() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn bump_map_string(values map[string]ruby.Value, key string, fallback string) string {
	return (values[key] or { ruby.string_value(fallback) }).as_string()
}

fn bump_map_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	value := values[key] or { return fallback }
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn bump_map_int(values map[string]ruby.Value, key string, fallback int) int {
	value := values[key] or { return fallback }
	return if value.type_name == 'Integer' { int(value.int_data) } else { fallback }
}

fn bump_string_map_from_value(value ruby.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in value.map_data {
		result[key] = item.as_string()
	}
	return result
}

fn bump_bool_map_from_value(value ruby.Value) map[string]bool {
	mut result := map[string]bool{}
	for key, item in value.map_data {
		result[key] = item.bool_data
	}
	return result
}

fn bump_string_map_value(values map[string]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

fn bump_bool_map_value(values map[string]bool) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.bool_value(value)
	}
	return ruby.map_value(result)
}

fn bump_release_value(release BumpRelease) ruby.Value {
	return ruby.Value{
		type_name: 'Release'
		repr: release.version
		map_data: {
			'version':         ruby.string_value(release.version)
			'released_at':     ruby.int_value(release.released_at)
			'prerelease':      ruby.bool_value(release.prerelease)
			'yanked':          ruby.bool_value(release.yanked)
			'artifact_suffix': ruby.string_value(release.artifact_suffix)
			'platform':        ruby.string_value(release.platform)
		}
	}
}

fn bump_release_from_value(value ruby.Value) BumpRelease {
	values := value.map_data.clone()
	return BumpRelease{
		version: bump_map_string(values, 'version', value.repr)
		released_at: (values['released_at'] or { ruby.int_value(0) }).int_data
		prerelease: bump_map_bool(values, 'prerelease', false)
		yanked: bump_map_bool(values, 'yanked', false)
		artifact_suffix: bump_map_string(values, 'artifact_suffix', '')
		platform: bump_map_string(values, 'platform', 'ruby')
	}
}

fn bump_resource_value(resource BumpResource) ruby.Value {
	return ruby.Value{
		type_name: 'Resource'
		repr: resource.name
		map_data: {
			'name':                ruby.string_value(resource.name)
			'current_version':     ruby.string_value(resource.current_version)
			'livecheck_defined':   ruby.bool_value(resource.livecheck_defined)
			'livecheck_skip':      ruby.bool_value(resource.livecheck_skip)
			'tracks_parent':       ruby.bool_value(resource.tracks_parent)
			'latest_version':      ruby.string_value(resource.latest_version)
			'livecheck_error':     ruby.bool_value(resource.livecheck_error)
			'outdated':            ruby.bool_value(resource.outdated)
			'newer_than_upstream': ruby.bool_value(resource.newer_than_upstream)
		}
	}
}

fn bump_resource_from_value(value ruby.Value) BumpResource {
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

pub fn bump_package_value(package BumpPackage) ruby.Value {
	mut releases := []ruby.Value{}
	for release in package.releases {
		releases << bump_release_value(release)
	}
	mut resources := []ruby.Value{}
	for resource in package.resources {
		resources << bump_resource_value(resource)
	}
	mut pull_requests := []ruby.Value{}
	for pull_request in package.pull_requests {
		pull_requests << ruby.map_value({
			'title':   ruby.string_value(pull_request.title)
			'url':     ruby.string_value(pull_request.url)
			'version': ruby.string_value(pull_request.version)
		})
	}
	return ruby.Value{
		type_name: if package.kind == .formula { 'Formula' } else { 'Cask' }
		repr: package.name
		map_data: {
			'kind':                       ruby.string_value(package.kind.str())
			'name':                       ruby.string_value(package.name)
			'full_name':                  ruby.string_value(package.full_name)
			'tap_name':                   ruby.string_value(package.tap_name)
			'tap_remote_repository':      ruby.string_value(package.tap_remote_repository)
			'version':                    ruby.string_value(package.version)
			'current_versions':           bump_string_map_value(package.current_versions)
			'latest_versions':            bump_string_map_value(package.latest_versions)
			'latest_throttled_versions':  bump_string_map_value(package.latest_throttled_versions)
			'deprecated':                 bump_bool_map_value(package.deprecated)
			'disabled':                   ruby.bool_value(package.disabled)
			'head_only':                  ruby.bool_value(package.head_only)
			'latest_cask':                ruby.bool_value(package.latest_cask)
			'allow_bump':                 ruby.bool_value(package.allow_bump)
			'on_system_blocks':           ruby.bool_value(package.on_system_blocks)
			'supported_archs':            ruby.string_array_value(package.supported_archs)
			'livecheck_defined':          ruby.bool_value(package.livecheck_defined)
			'livecheck_skip_status':      ruby.string_value(package.livecheck_skip_status)
			'livecheck_skip_messages':    ruby.string_array_value(package.livecheck_skip_messages)
			'livecheck_strategy':         ruby.string_value(package.livecheck_strategy)
			'livecheck_original_url':     ruby.string_value(package.livecheck_original_url)
			'livecheck_artifact_suffix':  ruby.string_value(package.livecheck_artifact_suffix)
			'livecheck_throttled':        ruby.bool_value(package.livecheck_throttled)
			'releases':                   ruby.array_value(releases)
			'repology_latest':            ruby.string_value(package.repology_latest)
			'installed':                  ruby.bool_value(package.installed)
			'autobumped':                 ruby.bool_value(package.autobumped)
			'resources':                  ruby.array_value(resources)
			'pull_requests':              ruby.array_value(pull_requests)
			'synced_versions':            bump_string_map_value(package.synced_versions)
			'throttle':                   ruby.bool_value(package.throttle)
			'github_api_errors':          ruby.int_value(package.github_api_errors)
			'github_authentication_fail': ruby.bool_value(package.github_authentication_fail)
			'too_many_open_prs':          ruby.bool_value(package.too_many_open_prs)
		}
	}
}

fn bump_package_from_value(value ruby.Value) !BumpPackage {
	if value.type_name !in ['Formula', 'Cask', 'Hash', 'BumpPackage'] {
		return error('expected Formula or Cask, got ${value.type_name}')
	}
	values := value.map_data.clone()
	mut releases := []BumpRelease{}
	for release in (values['releases'] or { ruby.array_value([]) }).as_array() or { [] } {
		releases << bump_release_from_value(release)
	}
	mut resources := []BumpResource{}
	for resource in (values['resources'] or { ruby.array_value([]) }).as_array() or { [] } {
		resources << bump_resource_from_value(resource)
	}
	mut pull_requests := []BumpPullRequest{}
	for pull_request in (values['pull_requests'] or { ruby.array_value([]) }).as_array() or { [] } {
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
		current_versions: bump_string_map_from_value(values['current_versions'] or { ruby.map_value({}) })
		latest_versions: bump_string_map_from_value(values['latest_versions'] or { ruby.map_value({}) })
		latest_throttled_versions: bump_string_map_from_value(values['latest_throttled_versions'] or { ruby.map_value({}) })
		deprecated: bump_bool_map_from_value(values['deprecated'] or { ruby.map_value({}) })
		disabled: bump_map_bool(values, 'disabled', false)
		head_only: bump_map_bool(values, 'head_only', false)
		latest_cask: bump_map_bool(values, 'latest_cask', false)
		allow_bump: bump_map_bool(values, 'allow_bump', true)
		on_system_blocks: bump_map_bool(values, 'on_system_blocks', false)
		supported_archs: (values['supported_archs'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		livecheck_defined: bump_map_bool(values, 'livecheck_defined', false)
		livecheck_skip_status: bump_map_string(values, 'livecheck_skip_status', '')
		livecheck_skip_messages: (values['livecheck_skip_messages'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
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
		synced_versions: bump_string_map_from_value(values['synced_versions'] or { ruby.map_value({}) })
		throttle: bump_map_bool(values, 'throttle', false)
		github_api_errors: bump_map_int(values, 'github_api_errors', 0)
		github_authentication_fail: bump_map_bool(values, 'github_authentication_fail', false)
		too_many_open_prs: bump_map_bool(values, 'too_many_open_prs', false)
	}
}

fn bump_options_from_value(value ruby.Value) BumpOptions {
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
		named: (values['named'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
	}
}

fn bump_versions_value(versions BumpVersions) ruby.Value {
	return ruby.map_value({
		'general': ruby.string_value(versions.general)
		'arm':     ruby.string_value(versions.arm)
		'intel':   ruby.string_value(versions.intel)
	})
}

fn bump_versions_from_value(value ruby.Value) BumpVersions {
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

fn bump_version_info_value(info BumpVersionInfo) ruby.Value {
	mut resources := []ruby.Value{}
	for resource in info.resource_versions {
		resources << ruby.map_value({
			'name':                ruby.string_value(resource.name)
			'current_version':     ruby.string_value(resource.current_version)
			'latest_version':      ruby.string_value(resource.latest_version)
			'has_latest_version':  ruby.bool_value(resource.has_latest_version)
			'outdated':            ruby.bool_value(resource.outdated)
			'newer_than_upstream': ruby.bool_value(resource.newer_than_upstream)
		})
	}
	return ruby.map_value({
		'type':                          ruby.string_value(info.kind.str())
		'deprecated':                    bump_bool_map_value(info.deprecated)
		'multiple_versions':             ruby.map_value({
			'current': ruby.bool_value(info.multiple_current)
			'new':     ruby.bool_value(info.multiple_new)
		})
		'version_name':                  ruby.string_value(info.version_name)
		'current_version':               bump_versions_value(info.current_version)
		'new_version':                   bump_versions_value(info.new_version)
		'resource_versions':             ruby.array_value(resources)
		'repology_latest':               ruby.string_value(info.repology_latest)
		'newer_than_upstream':           bump_bool_map_value(info.newer_than_upstream)
		'cooldown_skipped_versions':     bump_string_map_value(info.cooldown_skipped_versions)
		'duplicate_pull_requests':       ruby.string_value(info.duplicate_pull_requests)
		'maybe_duplicate_pull_requests': ruby.string_value(info.maybe_duplicate_pull_requests)
	})
}

fn bump_display_value(result BumpDisplayResult) ruby.Value {
	return ruby.map_value({
		'name':            ruby.string_value(result.name)
		'lines':           ruby.string_array_value(result.lines)
		'bump_pr_command': ruby.string_array_value(result.bump_pr_command)
		'failed':          ruby.bool_value(result.failed)
		'error':           ruby.string_value(result.error)
	})
}
