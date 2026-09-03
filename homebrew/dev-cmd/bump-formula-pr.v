module dev_cmd

import crypto.sha256
import brew_runtime
import homebrew
import homebrew.extend.file as atomic_file
import homebrew.utils
import os

// Translated from Homebrew/brew `dev-cmd/bump-formula-pr.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct BumpFormulaResource {
pub:
	name             string
	version          string
	url              string
	mirrors          []string
	checksum         string
	owner_name       string
	livecheck_parent bool
	fetch_path       string
	fetched_version  string
	fetched_sha256   string
	fetch_error      string
}

pub struct BumpFormula {
pub:
	name                  string
	full_name             string
	path                  string
	contents              string
	version               string
	url                   string
	tag                   string
	revision              string
	checksum              string
	mirrors               []string
	aliases               []string
	resources             []BumpFormulaResource
	tap_present           bool = true
	tap_git               bool = true
	tap_name              string
	tap_path              string
	tap_remote_repository string
	tap_official          bool
	allow_bump            bool = true
	disabled              bool
	does_not_build        bool
	too_many_open_prs     bool
	throttle_rate         ?int
	throttle_days         ?int
	throttle_allows_bump  bool = true
	download_path         string
	download_sha256       string
	fetched_version       string
	fetched_revision      string
}

pub struct BumpFormulaResourceVersion {
pub:
	current_version string
	latest_version  string
}

pub struct BumpFormulaOptions {
pub:
	version                string
	url                    string
	sha256                 string
	tag                    string
	revision               string
	mirrors                []string
	mirror_supplied        bool
	force                  bool
	dry_run                bool
	write_only             bool
	commit                 bool
	no_audit               bool
	strict                 bool
	online                 bool
	quiet                  bool
	no_browse              bool
	no_fork                bool
	fork_org               string
	message                string
	resource_versions_json string
	skip_synced_versions   bool
	audit_succeeded        bool = true
	brew_file              string
	pr_url                 string
}

pub struct BumpFormulaRunRequest {
pub:
	formula BumpFormula
	options BumpFormulaOptions
}

pub struct BumpFormulaCheckResult {
pub:
	allowed bool
	error   string
	output  []string
}

pub struct BumpFormulaFetchResult {
pub:
	path           string
	version        string
	sha256         string
	forced_version bool
}

pub struct BumpFormulaPullRequestCheck {
pub:
	formula      string
	remote       string
	version      string
	state        string
	file         string
	quiet        bool
	official_tap bool
}

pub struct BumpFormulaNewVersionCheckResult {
pub:
	check ?BumpFormulaPullRequestCheck
	error string
}

pub struct BumpFormulaResourceUpdate {
pub:
	contents string
	status   string
	message  string
}

pub struct BumpFormulaResourceUpdates {
pub:
	contents string
	statuses map[string]string
	warnings []string
}

pub struct BumpFormulaAuditOptions {
pub:
	dry_run              bool
	no_audit             bool
	strict               bool
	online               bool
	skip_synced_versions bool
	brew_file            string
	formula_full_name    string
	succeeded            bool = true
}

pub struct BumpFormulaAuditResult {
pub:
	failed  bool
	command []string
	output  []string
	moved   bool
	error   string
}

pub struct BumpFormulaRunResult {
pub:
	contents           string
	version            string
	branch_name        string
	commit_message     string
	additional_files   []string
	resource_statuses  map[string]string
	pull_request_check ?BumpFormulaPullRequestCheck
	audit              BumpFormulaAuditResult
	pull_request       string
	browser_url        string
	printed_url        string
	output             []string
	error              string
}

fn bump_formula_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn bump_formula_bool(value brew_runtime.Value, fallback bool) bool {
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn bump_formula_map_string(values map[string]brew_runtime.Value, key string,
	fallback string) string {
	return (values[key] or { brew_runtime.string_value(fallback) }).as_string()
}

fn bump_formula_map_bool(values map[string]brew_runtime.Value, key string, fallback bool) bool {
	return bump_formula_bool(values[key] or { brew_runtime.bool_value(fallback) }, fallback)
}

fn bump_formula_optional_int(values map[string]brew_runtime.Value, key string) ?int {
	value := values[key] or { return none }
	if value.type_name in ['Nil', 'NilClass'] {
		return none
	}
	return int(value.int_data)
}

fn bump_formula_string_map_value(values map[string]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

pub fn bump_formula_resource_value(resource BumpFormulaResource) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Resource'
		repr: resource.name
		map_data: {
			'name':             brew_runtime.string_value(resource.name)
			'version':          brew_runtime.string_value(resource.version)
			'url':              brew_runtime.string_value(resource.url)
			'mirrors':          brew_runtime.string_array_value(resource.mirrors)
			'checksum':         brew_runtime.string_value(resource.checksum)
			'owner_name':       brew_runtime.string_value(resource.owner_name)
			'livecheck_parent': brew_runtime.bool_value(resource.livecheck_parent)
			'fetch_path':       brew_runtime.string_value(resource.fetch_path)
			'fetched_version':  brew_runtime.string_value(resource.fetched_version)
			'fetched_sha256':   brew_runtime.string_value(resource.fetched_sha256)
			'fetch_error':      brew_runtime.string_value(resource.fetch_error)
		}
	}
}

fn bump_formula_resource_from_value(value brew_runtime.Value) !BumpFormulaResource {
	if value.type_name !in ['Resource', 'Hash'] {
		return error('expected Resource, got ${value.type_name}')
	}
	values := value.map_data.clone()
	return BumpFormulaResource{
		name: bump_formula_map_string(values, 'name', value.repr)
		version: bump_formula_map_string(values, 'version', '')
		url: bump_formula_map_string(values, 'url', '')
		mirrors: (values['mirrors'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
		checksum: bump_formula_map_string(values, 'checksum', '')
		owner_name: bump_formula_map_string(values, 'owner_name', '')
		livecheck_parent: bump_formula_map_bool(values, 'livecheck_parent', false)
		fetch_path: bump_formula_map_string(values, 'fetch_path', '')
		fetched_version: bump_formula_map_string(values, 'fetched_version', '')
		fetched_sha256: bump_formula_map_string(values, 'fetched_sha256', '')
		fetch_error: bump_formula_map_string(values, 'fetch_error', '')
	}
}

pub fn bump_formula_value(formula BumpFormula) brew_runtime.Value {
	mut resources := []brew_runtime.Value{}
	for resource in formula.resources {
		resources << bump_formula_resource_value(resource)
	}
	mut values := {
		'name':                  brew_runtime.string_value(formula.name)
		'full_name':             brew_runtime.string_value(formula.full_name)
		'path':                  brew_runtime.string_value(formula.path)
		'contents':              brew_runtime.string_value(formula.contents)
		'version':               brew_runtime.string_value(formula.version)
		'url':                   brew_runtime.string_value(formula.url)
		'tag':                   brew_runtime.string_value(formula.tag)
		'revision':              brew_runtime.string_value(formula.revision)
		'checksum':              brew_runtime.string_value(formula.checksum)
		'mirrors':               brew_runtime.string_array_value(formula.mirrors)
		'aliases':               brew_runtime.string_array_value(formula.aliases)
		'resources':             brew_runtime.array_value(resources)
		'tap_present':           brew_runtime.bool_value(formula.tap_present)
		'tap_git':               brew_runtime.bool_value(formula.tap_git)
		'tap_name':              brew_runtime.string_value(formula.tap_name)
		'tap_path':              brew_runtime.string_value(formula.tap_path)
		'tap_remote_repository': brew_runtime.string_value(formula.tap_remote_repository)
		'tap_official':          brew_runtime.bool_value(formula.tap_official)
		'allow_bump':            brew_runtime.bool_value(formula.allow_bump)
		'disabled':              brew_runtime.bool_value(formula.disabled)
		'does_not_build':        brew_runtime.bool_value(formula.does_not_build)
		'too_many_open_prs':     brew_runtime.bool_value(formula.too_many_open_prs)
		'throttle_allows_bump':  brew_runtime.bool_value(formula.throttle_allows_bump)
		'download_path':         brew_runtime.string_value(formula.download_path)
		'download_sha256':       brew_runtime.string_value(formula.download_sha256)
		'fetched_version':       brew_runtime.string_value(formula.fetched_version)
		'fetched_revision':      brew_runtime.string_value(formula.fetched_revision)
	}
	if rate := formula.throttle_rate {
		values['throttle_rate'] = brew_runtime.int_value(rate)
	}
	if days := formula.throttle_days {
		values['throttle_days'] = brew_runtime.int_value(days)
	}
	return brew_runtime.Value{
		type_name: 'Formula'
		repr: formula.name
		map_data: values
	}
}

fn bump_formula_from_value(value brew_runtime.Value) !BumpFormula {
	if value.type_name !in ['Formula', 'Hash'] {
		return error('expected Formula, got ${value.type_name}')
	}
	values := value.map_data.clone()
	mut resources := []BumpFormulaResource{}
	for entry in (values['resources'] or { brew_runtime.array_value([]) }).as_array() or { [] } {
		resources << bump_formula_resource_from_value(entry)!
	}
	return BumpFormula{
		name: bump_formula_map_string(values, 'name', value.repr)
		full_name: bump_formula_map_string(values, 'full_name', bump_formula_map_string(values, 'name', value.repr))
		path: bump_formula_map_string(values, 'path', '')
		contents: bump_formula_map_string(values, 'contents', '')
		version: bump_formula_map_string(values, 'version', '')
		url: bump_formula_map_string(values, 'url', '')
		tag: bump_formula_map_string(values, 'tag', '')
		revision: bump_formula_map_string(values, 'revision', '')
		checksum: bump_formula_map_string(values, 'checksum', '')
		mirrors: (values['mirrors'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
		aliases: (values['aliases'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
		resources: resources
		tap_present: bump_formula_map_bool(values, 'tap_present', true)
		tap_git: bump_formula_map_bool(values, 'tap_git', true)
		tap_name: bump_formula_map_string(values, 'tap_name', '')
		tap_path: bump_formula_map_string(values, 'tap_path', '')
		tap_remote_repository: bump_formula_map_string(values, 'tap_remote_repository', '')
		tap_official: bump_formula_map_bool(values, 'tap_official', false)
		allow_bump: bump_formula_map_bool(values, 'allow_bump', true)
		disabled: bump_formula_map_bool(values, 'disabled', false)
		does_not_build: bump_formula_map_bool(values, 'does_not_build', false)
		too_many_open_prs: bump_formula_map_bool(values, 'too_many_open_prs', false)
		throttle_rate: bump_formula_optional_int(values, 'throttle_rate')
		throttle_days: bump_formula_optional_int(values, 'throttle_days')
		throttle_allows_bump: bump_formula_map_bool(values, 'throttle_allows_bump', true)
		download_path: bump_formula_map_string(values, 'download_path', '')
		download_sha256: bump_formula_map_string(values, 'download_sha256', '')
		fetched_version: bump_formula_map_string(values, 'fetched_version', '')
		fetched_revision: bump_formula_map_string(values, 'fetched_revision', '')
	}
}

fn bump_formula_options_from_value(value brew_runtime.Value) BumpFormulaOptions {
	values := value.map_data.clone()
	return BumpFormulaOptions{
		version: bump_formula_map_string(values, 'version', '')
		url: bump_formula_map_string(values, 'url', '')
		sha256: bump_formula_map_string(values, 'sha256', '')
		tag: bump_formula_map_string(values, 'tag', '')
		revision: bump_formula_map_string(values, 'revision', '')
		mirrors: (values['mirrors'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
		mirror_supplied: bump_formula_map_bool(values, 'mirror_supplied', 'mirrors' in values)
		force: bump_formula_map_bool(values, 'force', false)
		dry_run: bump_formula_map_bool(values, 'dry_run', false)
		write_only: bump_formula_map_bool(values, 'write_only', false)
		commit: bump_formula_map_bool(values, 'commit', false)
		no_audit: bump_formula_map_bool(values, 'no_audit', false)
		strict: bump_formula_map_bool(values, 'strict', false)
		online: bump_formula_map_bool(values, 'online', false)
		quiet: bump_formula_map_bool(values, 'quiet', false)
		no_browse: bump_formula_map_bool(values, 'no_browse', false)
		no_fork: bump_formula_map_bool(values, 'no_fork', false)
		fork_org: bump_formula_map_string(values, 'fork_org', '')
		message: bump_formula_map_string(values, 'message', '')
		resource_versions_json: bump_formula_map_string(values, 'resource_versions', '')
		skip_synced_versions: bump_formula_map_bool(values, 'skip_synced_versions', false)
		audit_succeeded: bump_formula_map_bool(values, 'audit_succeeded', true)
		brew_file: bump_formula_map_string(values, 'brew_file', '')
		pr_url: bump_formula_map_string(values, 'pr_url', '')
	}
}

fn bump_formula_compare_versions(left string, right string) int {
	left_version := homebrew.new_version(left) or { return left.compare(right) }
	right_version := homebrew.new_version(right) or { return left.compare(right) }
	return left_version.compare_to(right_version)
}

pub fn bump_formula_check_throttle(formula BumpFormula, new_version string) BumpFormulaCheckResult {
	if !formula.tap_present || (formula.throttle_rate == none && formula.throttle_days == none) {
		return BumpFormulaCheckResult{ allowed: true }
	}
	if formula.throttle_allows_bump {
		return BumpFormulaCheckResult{ allowed: true }
	}
	mut items := []string{}
	if rate := formula.throttle_rate {
		items << '${rate} releases on multiples of ${rate}'
	}
	if days := formula.throttle_days {
		items << '${days} ${if days == 1 { 'day' } else { 'days' }}'
	}
	return BumpFormulaCheckResult{
		error: '${formula.name} should only be updated every ${items.join(' or ')}'
		output: ['throttled ${formula.name} ${new_version}']
	}
}

pub fn bump_formula_determine_mirror(url string) ?string {
	if url.contains('ftp.gnu.org/gnu') {
		return url.replace_once('ftp.gnu.org/gnu', 'ftpmirror.gnu.org')
	}
	if url.contains('download.savannah.gnu.org') {
		return url.replace_once('download.savannah.gnu.org', 'download-mirror.savannah.gnu.org')
	}
	if url.contains('www.apache.org/dyn/closer.lua?path=') {
		return url.replace_once('www.apache.org/dyn/closer.lua?path=', 'archive.apache.org/dist/')
	}
	if url.contains('mirrors.ocf.berkeley.edu/debian') {
		return url.replace_once('mirrors.ocf.berkeley.edu/debian', 'mirrorservice.org/sites/ftp.debian.org/debian')
	}
	return none
}

pub fn bump_formula_check_for_mirrors(formula string, old_mirrors []string,
	new_mirrors []string, force bool) BumpFormulaCheckResult {
	if new_mirrors.len > 0 || old_mirrors.len == 0 {
		return BumpFormulaCheckResult{ allowed: true }
	}
	if force {
		return BumpFormulaCheckResult{
			allowed: true
			output: [
				'${formula}: Removing all mirrors because a `--mirror=` argument was not specified.',
			]
		}
	}
	return BumpFormulaCheckResult{
		error: '${formula}: a `--mirror=` argument for updating the mirror URL(s) was not specified.\nUse `--force` to remove all mirrors.'
	}
}

pub fn bump_formula_update_url(old_url string, old_version string, new_version string) string {
	mut updated := old_url.replace(old_version, new_version)
	if old_version.contains('.') {
		updated = updated.replace(old_version.replace('.', '_'), new_version.replace('.', '_'))
	}
	old_parts := old_version.split('.')
	new_parts := new_version.split('.')
	if old_parts.len < 2 || old_parts.len != new_parts.len {
		return updated
	}
	partial_old := old_parts[..old_parts.len - 1].join('.')
	partial_new := new_parts[..new_parts.len - 1].join('.')
	if partial_old == '' || partial_new == '' {
		return updated
	}
	for prefix in ['/${partial_old}/', '/v${partial_old}/'] {
		if updated.contains(prefix) {
			replacement := if prefix.starts_with('/v') {
				'/v${partial_new}/'
			} else {
				'/${partial_new}/'
			}
			return updated.replace_once(prefix, replacement)
		}
	}
	return updated
}

pub fn bump_formula_fetch_resource(input BumpFormulaResource, new_version string,
	url string) !BumpFormulaFetchResult {
	if input.fetch_error != '' {
		return error(input.fetch_error)
	}
	detected := if input.fetched_version != '' {
		input.fetched_version
	} else {
		homebrew.detect_version(url, '').to_s()
	}
	forced := new_version != '' && new_version != detected
	version := if forced { new_version } else { detected }
	if version == '' {
		return error("Couldn't identify version, specify it using `--version=`.")
	}
	mut digest := input.fetched_sha256
	if digest == '' && input.fetch_path != '' && os.is_file(input.fetch_path) {
		digest = sha256.sum256(os.read_bytes(input.fetch_path)!).hex()
	}
	return BumpFormulaFetchResult{
		path: input.fetch_path
		version: version
		sha256: digest
		forced_version: forced
	}
}

fn bump_formula_quoted_value(line string) string {
	for quote in ['"', "'"] {
		start := line.index(quote) or { continue }
		tail := line[start + 1..]
		finish := tail.index(quote) or { continue }
		return tail[..finish]
	}
	return ''
}

pub fn bump_formula_version(formula BumpFormula, contents string) string {
	if contents == '' {
		return formula.version
	}
	mut url := formula.url
	mut tag := formula.tag
	for line in contents.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with('version ') {
			version := bump_formula_quoted_value(trimmed)
			if version != '' {
				return version
			}
		}
		if trimmed.starts_with('url ') {
			candidate := bump_formula_quoted_value(trimmed)
			if candidate != '' {
				url = candidate
			}
			tag_index := trimmed.index('tag:') or { -1 }
			if tag_index >= 0 {
				tag_candidate := bump_formula_quoted_value(trimmed[tag_index..])
				if tag_candidate != '' {
					tag = tag_candidate
				}
			}
		}
	}
	return homebrew.detect_version(url, tag).to_s()
}

pub fn bump_formula_check_pull_requests(formula BumpFormula, tap_remote_repo string,
	state string, version string, quiet bool) ?BumpFormulaPullRequestCheck {
	if !formula.tap_present {
		return none
	}
	file := if formula.tap_path != '' && formula.path.starts_with(formula.tap_path + os.path_separator) {
		formula.path[formula.tap_path.len + 1..]
	} else {
		formula.path
	}
	return BumpFormulaPullRequestCheck{
		formula: formula.name
		remote: tap_remote_repo
		version: version
		state: state
		file: file
		quiet: quiet
		official_tap: formula.tap_official
	}
}

pub fn bump_formula_check_new_version(formula BumpFormula, tap_remote_repo string,
	version string, url string, tag string, write_only bool,
	quiet bool) BumpFormulaNewVersionCheckResult {
	mut candidate := version
	if candidate == '' {
		if url == '' {
			return BumpFormulaNewVersionCheckResult{}
		}
		candidate = homebrew.detect_version(url, tag).to_s()
		if candidate == '' {
			return BumpFormulaNewVersionCheckResult{}
		}
	}
	throttle := bump_formula_check_throttle(formula, candidate)
	if !throttle.allowed {
		return BumpFormulaNewVersionCheckResult{ error: throttle.error }
	}
	if write_only {
		return BumpFormulaNewVersionCheckResult{}
	}
	return BumpFormulaNewVersionCheckResult{
		check: bump_formula_check_pull_requests(formula, tap_remote_repo, '', candidate, quiet)
	}
}

fn bump_formula_all_digits(value string) bool {
	if value == '' {
		return false
	}
	for character in value.bytes() {
		if character < `0` || character > `9` {
			return false
		}
	}
	return true
}

pub fn bump_formula_alias_update_pair(formula BumpFormula,
	new_formula_version string) ?[]string {
	mut versioned_alias := ''
	for alias in formula.aliases {
		at := alias.last_index('@') or { continue }
		alias_version := alias[at + 1..]
		parts := alias_version.split('.')
		if parts.len in [1, 2] && parts.all(bump_formula_all_digits(it)) {
			versioned_alias = alias
			break
		}
	}
	if versioned_alias == '' {
		return none
	}
	at := versioned_alias.last_index('@') or { return none }
	name := versioned_alias[..at]
	old_alias_version := versioned_alias[at + 1..]
	new_parts := new_formula_version.split('.')
	old_parts := old_alias_version.split('.')
	if new_parts.len < old_parts.len {
		return none
	}
	new_alias_version := new_parts[..old_parts.len].join('.')
	if bump_formula_compare_versions(new_alias_version, old_alias_version) <= 0 {
		return none
	}
	return [versioned_alias, '${name}@${new_alias_version}']
}

pub fn bump_formula_parse_resource_versions(contents string) !map[string]BumpFormulaResourceVersion {
	if contents.trim_space() == '' {
		return map[string]BumpFormulaResourceVersion{}
	}
	parsed := brew_runtime.parse_json_value(contents)!
	entries := parsed.as_array()!
	mut result := map[string]BumpFormulaResourceVersion{}
	for entry in entries {
		values := entry.as_map()!
		name := bump_formula_map_string(values, 'name', '')
		if name == '' {
			return error('resource version entry is missing a name')
		}
		result[name] = BumpFormulaResourceVersion{
			current_version: bump_formula_map_string(values, 'current_version', '')
			latest_version: bump_formula_map_string(values, 'latest_version', '')
		}
	}
	return result
}

pub fn bump_formula_update_resource_block(formula BumpFormula, resource BumpFormulaResource,
	new_version string) !BumpFormulaResourceUpdate {
	new_url := bump_formula_update_url(resource.url, resource.version, new_version)
	if new_url == resource.url {
		return BumpFormulaResourceUpdate{
			contents: formula.contents
			status: 'url_unchanged'
			message: 'You need to bump resource "${resource.name}" manually since the new URL and old URL are both: ${new_url}'
		}
	}
	mut fetch_resource := resource
	fetched := bump_formula_fetch_resource(fetch_resource, new_version, new_url)!
	if fetched.sha256 == '' && resource.checksum != '' {
		return error('Fetched resource "${resource.name}" has no SHA-256 checksum')
	}
	mut ast := utils.FormulaAst{
		contents: formula.contents
	}
	utils.ast_formula_replace_resource_value(mut ast, resource.name, 'url', brew_runtime.string_value(new_url), brew_runtime.string_value(resource.url))
	for index, old_mirror in resource.mirrors {
		new_mirror := bump_formula_update_url(old_mirror, resource.version, new_version)
		utils.ast_formula_replace_resource_value(mut ast, resource.name, 'mirror', brew_runtime.string_value(new_mirror), brew_runtime.string_value(old_mirror))
	}
	if resource.checksum != '' {
		utils.ast_formula_replace_resource_value(mut ast, resource.name, 'sha256', brew_runtime.string_value(fetched.sha256), brew_runtime.string_value(resource.checksum))
	}
	if fetched.forced_version {
		if utils.ast_formula_resource_stanza_exists(ast, resource.name, 'version') {
			utils.ast_formula_replace_resource_value(mut ast, resource.name, 'version', brew_runtime.string_value(new_version), none)
		} else {
			parent := utils.ast_formula_resource(ast, resource.name)
			utils.ast_formula_add_stanzas_after(mut ast, 'sha256', [utils.AstStanzaPair{
				name: 'version'
				value: brew_runtime.string_value(new_version)
			}], parent)
		}
	}
	return BumpFormulaResourceUpdate{
		contents: ast.contents
		status: 'success'
		message: 'Updating resource "${resource.name}" from ${resource.version} to ${new_version}'
	}
}

pub fn bump_formula_update_matching_version_resources(formula BumpFormula, version string,
	resource_versions map[string]BumpFormulaResourceVersion) BumpFormulaResourceUpdates {
	mut contents := formula.contents
	mut statuses := map[string]string{}
	mut warnings := []string{}
	for resource in formula.resources {
		if !resource.livecheck_parent || resource.name in resource_versions {
			continue
		}
		current_formula := BumpFormula{
			...formula
			contents: contents
		}
		updated := bump_formula_update_resource_block(current_formula, resource, version) or {
			statuses[resource.name] = 'fetch_failed'
			warnings << 'Failed to update resource "${resource.name}": ${err.msg()}'
			continue
		}
		contents = updated.contents
		statuses[resource.name] = updated.status
		if updated.message != '' {
			warnings << updated.message
		}
	}
	return BumpFormulaResourceUpdates{
		contents: contents
		statuses: statuses
		warnings: warnings
	}
}

pub fn bump_formula_update_resources(formula BumpFormula,
	resource_versions map[string]BumpFormulaResourceVersion) BumpFormulaResourceUpdates {
	mut contents := formula.contents
	mut statuses := map[string]string{}
	mut warnings := []string{}
	for resource in formula.resources {
		version_data := resource_versions[resource.name] or { continue }
		if version_data.current_version == '' || version_data.latest_version == '' {
			statuses[resource.name] = 'version_unknown'
			warnings << 'Could not determine versions for resource "${resource.name}"'
			continue
		}
		if version_data.current_version == version_data.latest_version {
			statuses[resource.name] = 'up_to_date'
			continue
		}
		downgraded := bump_formula_compare_versions(version_data.current_version, version_data.latest_version) > 0
		current_formula := BumpFormula{
			...formula
			contents: contents
		}
		updated := bump_formula_update_resource_block(current_formula, resource, version_data.latest_version) or {
			statuses[resource.name] = 'fetch_failed'
			warnings << 'Failed to update resource "${resource.name}": ${err.msg()}'
			continue
		}
		contents = updated.contents
		statuses[resource.name] = if updated.status == 'success' && downgraded {
			'downgraded'
		} else {
			updated.status
		}
	}
	return BumpFormulaResourceUpdates{
		contents: contents
		statuses: statuses
		warnings: warnings
	}
}

pub fn bump_formula_run_audit(formula BumpFormula, alias_rename []string,
	options BumpFormulaAuditOptions) BumpFormulaAuditResult {
	mut audit_args := ['--formula']
	if options.strict {
		audit_args << '--strict'
	}
	if options.online {
		audit_args << '--online'
	}
	if options.skip_synced_versions {
		audit_args << '--except=synced_versions_formulae'
	}
	full_name := if options.formula_full_name != '' {
		options.formula_full_name
	} else {
		formula.full_name
	}
	mut command := []string{}
	if options.brew_file != '' {
		command = [options.brew_file, 'audit']
		command << audit_args
		command << full_name
	}
	if options.dry_run {
		return BumpFormulaAuditResult{
			command: command
			output: [if options.no_audit {
				'Skipping `brew audit`'
			} else {
				'brew audit ${audit_args.join(' ')} ${os.file_name(formula.path)}'
			}]
		}
	}
	mut moved := false
	if alias_rename.len >= 2 && os.exists(alias_rename[0]) {
		os.mv(alias_rename[0], alias_rename[1]) or {
			return BumpFormulaAuditResult{
				failed: true
				command: command
				error: err.msg()
			}
		}
		moved = true
	}
	if options.no_audit {
		return BumpFormulaAuditResult{
			command: command
			output: ['Skipping `brew audit`']
			moved: moved
		}
	}
	mut succeeded := options.succeeded
	mut process_output := []string{}
	if options.brew_file != '' {
		result := os.execute(command.map(os.quoted_path(it)).join(' '))
		succeeded = result.exit_code == 0
		if result.output != '' {
			process_output << result.output
		}
	}
	return BumpFormulaAuditResult{
		failed: !succeeded
		command: command
		output: process_output
		moved: moved
	}
}

fn bump_formula_stable_has(ast utils.FormulaAst, name string) bool {
	for node in utils.ast_formula_stable_children(ast) {
		if node.name == name {
			return true
		}
	}
	return false
}

fn bump_formula_apply_source(formula BumpFormula, options BumpFormulaOptions,
	new_url string, new_hash string, new_tag string, new_revision string,
	new_mirrors []string, forced_version bool) !string {
	mut ast := utils.FormulaAst{
		contents: formula.contents
	}
	if formula.mirrors.len > 0 {
		utils.ast_formula_remove_stable(mut ast, 'mirror', true)
	}
	if formula.checksum != '' {
		utils.ast_formula_replace_stable_value(mut ast, 'url', brew_runtime.string_value(new_url))
		utils.ast_formula_replace_stable_value(mut ast, 'sha256', brew_runtime.string_value(new_hash))
	} else if new_tag != '' {
		utils.ast_formula_replace_stable_hash(mut ast, 'url', 'tag', brew_runtime.string_value(new_tag))
		utils.ast_formula_replace_stable_hash(mut ast, 'url', 'revision', brew_runtime.string_value(new_revision))
	} else if new_url != '' {
		utils.ast_formula_replace_stable_value(mut ast, 'url', brew_runtime.string_value(new_url))
		utils.ast_formula_replace_stable_hash(mut ast, 'url', 'revision', brew_runtime.string_value(new_revision))
	} else {
		utils.ast_formula_replace_stable_hash(mut ast, 'url', 'revision', brew_runtime.string_value(new_revision))
	}
	mut additions := []utils.AstStanzaPair{}
	for mirror in new_mirrors {
		additions << utils.AstStanzaPair{
			name: 'mirror'
			value: brew_runtime.string_value(mirror)
		}
	}
	if forced_version && options.version != '0' {
		if bump_formula_stable_has(ast, 'version') {
			utils.ast_formula_replace_stable_value(mut ast, 'version', brew_runtime.string_value(options.version))
		} else {
			additions << utils.AstStanzaPair{
				name: 'version'
				value: brew_runtime.string_value(options.version)
			}
		}
	} else if forced_version && options.version == '0' && bump_formula_stable_has(ast, 'version') {
		utils.ast_formula_remove_stable(mut ast, 'version', false)
	}
	utils.ast_formula_add_stanzas_after(mut ast, 'url', additions, none)
	return ast.contents
}

pub fn bump_formula_run(request BumpFormulaRunRequest) BumpFormulaRunResult {
	formula := request.formula
	options := request.options
	if options.revision != '' && options.tag == '' && options.version == '' {
		return BumpFormulaRunResult{ error: '`--revision` must be passed with either `--tag` or `--version`!' }
	}
	if formula.name == '' {
		return BumpFormulaRunResult{ error: 'Formula unspecified' }
	}
	if formula.disabled {
		return BumpFormulaRunResult{ error: 'This formula is disabled!' }
	}
	if formula.does_not_build {
		return BumpFormulaRunResult{ error: 'This formula is deprecated and does not build!' }
	}
	if !formula.tap_present {
		return BumpFormulaRunResult{ error: 'This formula is not in a tap!' }
	}
	if !formula.tap_git {
		return BumpFormulaRunResult{ error: "This formula's tap is not a Git repository!" }
	}
	if !formula.allow_bump {
		return BumpFormulaRunResult{ error: '${formula.name} has pull requests automatically opened by BrewTestBot' }
	}
	if !options.write_only && formula.too_many_open_prs {
		return BumpFormulaRunResult{ error: 'You have too many PRs open: close or merge some first!' }
	}
	if formula.url == '' || formula.version == '' {
		return BumpFormulaRunResult{ error: '${formula.name}: no stable specification found!' }
	}
	if formula.tap_remote_repository == '' {
		return BumpFormulaRunResult{ error: '${formula.tap_name} tap does not have a remote repository!' }
	}
	mut check := ?BumpFormulaPullRequestCheck(none)
	if !options.write_only {
		check = bump_formula_check_pull_requests(formula, formula.tap_remote_repository, 'open', '', options.quiet)
	}
	if options.version != '' {
		new_check := bump_formula_check_new_version(formula, formula.tap_remote_repository, options.version, '', '', options.write_only, options.quiet)
		if new_check.error != '' {
			return BumpFormulaRunResult{ error: new_check.error }
		}
		if item := new_check.check {
			check = item
		}
	}
	old_version := formula.version
	mut new_url := options.url
	mut new_tag := options.tag
	mut new_revision := options.revision
	mut new_hash := options.sha256
	mut new_mirrors := if options.mirror_supplied {
		options.mirrors.clone()
	} else {
		[]string{}
	}
	if new_url != '' {
		if mirror := bump_formula_determine_mirror(new_url) {
			if !options.mirror_supplied {
				new_mirrors = [mirror]
			}
			mirror_check := bump_formula_check_for_mirrors(formula.name, formula.mirrors, new_mirrors, options.force)
			if !mirror_check.allowed {
				return BumpFormulaRunResult{ error: mirror_check.error }
			}
		}
	}
	forced_version := options.version != ''
	if formula.checksum != '' {
		if new_url == '' && options.version == '' {
			return BumpFormulaRunResult{ error: '${formula.name}: no `--url` or `--version` argument specified!' }
		}
		if new_url == '' {
			new_url = bump_formula_update_url(formula.url, old_version, options.version)
			if !options.mirror_supplied && formula.mirrors.len > 0 {
				new_mirrors = formula.mirrors.map(bump_formula_update_url(it, old_version, options.version))
			}
		}
		if new_url == formula.url {
			return BumpFormulaRunResult{ error: 'You need to bump this formula manually since the new URL and old URL are both: ${new_url}' }
		}
		if new_hash == '' {
			fetch := bump_formula_fetch_resource(BumpFormulaResource{
				name: formula.name
				fetch_path: formula.download_path
				fetched_version: formula.fetched_version
				fetched_sha256: formula.download_sha256
			}, options.version, new_url) or { return BumpFormulaRunResult{ error: err.msg() } }
			new_hash = fetch.sha256
		}
		if new_hash == '' {
			return BumpFormulaRunResult{ error: 'Fetched formula has no SHA-256 checksum' }
		}
	} else {
		if new_tag == '' && options.version != '' && formula.tag != '' {
			new_tag = formula.tag.replace(old_version, options.version)
		}
		if new_revision == '' {
			new_revision = formula.fetched_revision
		}
		if new_revision == '' {
			return BumpFormulaRunResult{ error: '${formula.name}: the current URL requires specifying a `--revision=` argument.' }
		}
	}
	contents := bump_formula_apply_source(formula, options, new_url, new_hash, new_tag, new_revision, new_mirrors, forced_version) or { return BumpFormulaRunResult{ error: err.msg() } }
	new_version := bump_formula_version(BumpFormula{
		...formula
		url: if new_url != '' { new_url } else { formula.url }
		tag: if new_tag != '' { new_tag } else { formula.tag }
	}, contents)
	comparison := bump_formula_compare_versions(new_version, old_version)
	if comparison < 0 {
		return BumpFormulaRunResult{ error: 'You need to bump this formula manually since changing the version from ${old_version} to ${new_version} would be a downgrade.' }
	}
	if comparison == 0 {
		return BumpFormulaRunResult{ error: 'You need to bump this formula manually since the new version and old version are both ${new_version}.' }
	}
	mut final_contents := contents
	mut resource_statuses := map[string]string{}
	mut output := []string{}
	if !options.dry_run {
		resource_versions := bump_formula_parse_resource_versions(options.resource_versions_json) or {
			output << 'Failed to parse --resource-versions JSON: ${err.msg()}'
			map[string]BumpFormulaResourceVersion{}
		}
		matching := bump_formula_update_matching_version_resources(BumpFormula{
			...formula
			contents: final_contents
		}, new_version, resource_versions)
		final_contents = matching.contents
		for name, status in matching.statuses {
			resource_statuses[name] = status
		}
		output << matching.warnings
		if resource_versions.len > 0 {
			updates := bump_formula_update_resources(BumpFormula{
				...formula
				contents: final_contents
			}, resource_versions)
			final_contents = updates.contents
			for name, status in updates.statuses {
				resource_statuses[name] = status
			}
			output << updates.warnings
		}
	}
	alias_pair := bump_formula_alias_update_pair(formula, new_version) or { []string{} }
	mut alias_paths := []string{}
	if alias_pair.len == 2 {
		alias_paths = alias_pair.map(if formula.tap_path != '' {
			os.join_path(formula.tap_path, 'Aliases', it)
		} else {
			it
		})
		output << 'Renaming alias ${alias_pair[0]} to ${alias_pair[1]}'
	}
	if !options.dry_run && formula.path != '' {
		atomic_file.atomic_write_contents(formula.path, os.dir(formula.path), final_contents) or {
			return BumpFormulaRunResult{ error: err.msg() }
		}
	}
	audit := bump_formula_run_audit(formula, alias_paths, BumpFormulaAuditOptions{
		dry_run: options.dry_run
		no_audit: options.no_audit
		strict: options.strict
		online: options.online
		skip_synced_versions: options.skip_synced_versions
		brew_file: options.brew_file
		formula_full_name: formula.full_name
		succeeded: options.audit_succeeded
	})
	if audit.failed {
		if !options.dry_run && !options.write_only && formula.path != '' {
			atomic_file.atomic_write_contents(formula.path, os.dir(formula.path), formula.contents) or {}
		}
		return BumpFormulaRunResult{
			contents: formula.contents
			version: new_version
			audit: audit
			error: '`brew audit` failed for ${formula.name}!'
		}
	}
	mut result := BumpFormulaRunResult{
		contents: final_contents
		version: new_version
		branch_name: 'bump-${formula.name}-${new_version}'
		commit_message: '${formula.name} ${new_version}'
		additional_files: alias_paths
		resource_statuses: resource_statuses
		pull_request_check: check
		audit: audit
		output: output
	}
	if !(options.write_only && !options.commit) {
		result = BumpFormulaRunResult{
			...result
			pull_request: options.pr_url
			browser_url: if options.pr_url != '' && !options.no_browse {
				options.pr_url
			} else {
				''
			}
			printed_url: if options.pr_url != '' && options.no_browse {
				options.pr_url
			} else {
				''
			}
		}
	}
	return result
}

fn bump_formula_check_value(result BumpFormulaCheckResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'allowed': brew_runtime.bool_value(result.allowed)
		'error':   brew_runtime.string_value(result.error)
		'output':  brew_runtime.string_array_value(result.output)
	})
}

fn bump_formula_fetch_value(result BumpFormulaFetchResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'path':           brew_runtime.string_value(result.path)
		'version':        brew_runtime.string_value(result.version)
		'sha256':         brew_runtime.string_value(result.sha256)
		'forced_version': brew_runtime.bool_value(result.forced_version)
	})
}

fn bump_formula_pull_request_value(check BumpFormulaPullRequestCheck) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'GitHub::PullRequestCheck'
		repr: '${check.formula} ${check.version}'.trim_space()
		map_data: {
			'formula':      brew_runtime.string_value(check.formula)
			'remote':       brew_runtime.string_value(check.remote)
			'version':      brew_runtime.string_value(check.version)
			'state':        brew_runtime.string_value(check.state)
			'file':         brew_runtime.string_value(check.file)
			'quiet':        brew_runtime.bool_value(check.quiet)
			'official_tap': brew_runtime.bool_value(check.official_tap)
		}
	}
}

fn bump_formula_updates_value(updates BumpFormulaResourceUpdates) brew_runtime.Value {
	return brew_runtime.map_value({
		'contents': brew_runtime.string_value(updates.contents)
		'statuses': bump_formula_string_map_value(updates.statuses)
		'warnings': brew_runtime.string_array_value(updates.warnings)
	})
}

fn bump_formula_resource_versions_from_value(value brew_runtime.Value) !map[string]BumpFormulaResourceVersion {
	if value.type_name in ['Nil', 'NilClass'] {
		return map[string]BumpFormulaResourceVersion{}
	}
	values := value.as_map()!
	mut result := map[string]BumpFormulaResourceVersion{}
	for name, entry in values {
		data := entry.as_map()!
		result[name] = BumpFormulaResourceVersion{
			current_version: bump_formula_map_string(data, 'current_version', '')
			latest_version: bump_formula_map_string(data, 'latest_version', '')
		}
	}
	return result
}

fn bump_formula_resource_versions_value(versions map[string]BumpFormulaResourceVersion) brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	for name, version in versions {
		values[name] = brew_runtime.map_value({
			'current_version': brew_runtime.string_value(version.current_version)
			'latest_version':  brew_runtime.string_value(version.latest_version)
		})
	}
	return brew_runtime.map_value(values)
}

fn bump_formula_audit_value(result BumpFormulaAuditResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'failed':  brew_runtime.bool_value(result.failed)
		'command': brew_runtime.string_array_value(result.command)
		'output':  brew_runtime.string_array_value(result.output)
		'moved':   brew_runtime.bool_value(result.moved)
		'error':   brew_runtime.string_value(result.error)
	})
}

fn bump_formula_run_result_value(result BumpFormulaRunResult) brew_runtime.Value {
	mut values := {
		'contents':          brew_runtime.string_value(result.contents)
		'version':           brew_runtime.string_value(result.version)
		'branch_name':       brew_runtime.string_value(result.branch_name)
		'commit_message':    brew_runtime.string_value(result.commit_message)
		'additional_files':  brew_runtime.string_array_value(result.additional_files)
		'resource_statuses': bump_formula_string_map_value(result.resource_statuses)
		'audit':             bump_formula_audit_value(result.audit)
		'pull_request':      brew_runtime.string_value(result.pull_request)
		'browser_url':       brew_runtime.string_value(result.browser_url)
		'printed_url':       brew_runtime.string_value(result.printed_url)
		'output':            brew_runtime.string_array_value(result.output)
		'error':             brew_runtime.string_value(result.error)
	}
	if check := result.pull_request_check {
		values['pull_request_check'] = bump_formula_pull_request_value(check)
	} else {
		values['pull_request_check'] = bump_formula_nil()
	}
	return brew_runtime.Value{
		type_name: 'Homebrew::DevCmd::BumpFormulaPr::Result'
		repr: result.commit_message
		map_data: values
	}
}

// Ruby method `run` at line 99.
pub fn ruby_bump_formula_pr_l99_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula or request is required')
	}
	if args[0].type_name == 'Homebrew::DevCmd::BumpFormulaPr::Request' {
		request_values := args[0].map_data.clone()
		formula := bump_formula_from_value(request_values['formula'] or {
			return brew_runtime.object_value('ArgumentError', 'request formula is required')
		}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
		options := bump_formula_options_from_value(request_values['options'] or {
			brew_runtime.map_value(map[string]brew_runtime.Value{})
		})
		return bump_formula_run_result_value(bump_formula_run(BumpFormulaRunRequest{
			formula: formula
			options: options
		}))
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 1 {
		bump_formula_options_from_value(args[1])
	} else {
		BumpFormulaOptions{}
	}
	return bump_formula_run_result_value(bump_formula_run(BumpFormulaRunRequest{
		formula: formula
		options: options
	}))
}

// Ruby method `check_throttle(formula, new_version)` at line 508.
pub fn ruby_bump_formula_pr_l508_d2_check_throttle(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'formula and new version are required')
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return bump_formula_check_value(bump_formula_check_throttle(formula, args[1].as_string()))
}

// Ruby method `update_matching_version_resources!(formula, version:, resource_versions: nil)` at line 537.
pub fn ruby_bump_formula_pr_l537_d3_update_matching_version_resources(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'formula and version are required')
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	versions := if args.len > 2 {
		bump_formula_resource_versions_from_value(args[2]) or {
			return brew_runtime.object_value('ArgumentError', err.msg())
		}
	} else {
		map[string]BumpFormulaResourceVersion{}
	}
	return bump_formula_updates_value(bump_formula_update_matching_version_resources(formula, args[1].as_string(), versions))
}

// Ruby method `update_resources!(formula, resource_versions:)` at line 550.
pub fn ruby_bump_formula_pr_l550_d4_update_resources(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'formula and resource versions are required')
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	versions := bump_formula_resource_versions_from_value(args[1]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return bump_formula_updates_value(bump_formula_update_resources(formula, versions))
}

// Ruby method `determine_mirror(url)` at line 592.
pub fn ruby_bump_formula_pr_l592_d5_determine_mirror(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'URL is required')
	}
	if mirror := bump_formula_determine_mirror(args[0].as_string()) {
		return brew_runtime.string_value(mirror)
	}
	return bump_formula_nil()
}

// Ruby method `check_for_mirrors(formula, old_mirrors, new_mirrors)` at line 606.
pub fn ruby_bump_formula_pr_l606_d6_check_for_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'formula, old mirrors, and new mirrors are required')
	}
	old_mirrors := args[1].as_string_array() or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	new_mirrors := args[2].as_string_array() or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	force := args.len > 3 && bump_formula_bool(args[3], false)
	return bump_formula_check_value(bump_formula_check_for_mirrors(args[0].as_string(), old_mirrors, new_mirrors, force))
}

// Ruby method `update_url(old_url, old_version, new_version)` at line 620.
pub fn ruby_bump_formula_pr_l620_d7_update_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'old URL, old version, and new version are required')
	}
	return brew_runtime.string_value(bump_formula_update_url(args[0].as_string(), args[1].as_string(), args[2].as_string()))
}

// Ruby method `fetch_resource_and_forced_version(formula_or_resource, new_version, url, **specs)` at line 638.
pub fn ruby_bump_formula_pr_l638_d8_fetch_resource_and_forced_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'formula or resource, version, and URL are required')
	}
	mut resource := BumpFormulaResource{}
	if args[0].type_name == 'Formula' {
		formula := bump_formula_from_value(args[0]) or {
			return brew_runtime.object_value('ArgumentError', err.msg())
		}
		resource = BumpFormulaResource{
			name: formula.name
			fetch_path: formula.download_path
			fetched_version: formula.fetched_version
			fetched_sha256: formula.download_sha256
		}
	} else {
		resource = bump_formula_resource_from_value(args[0]) or {
			return brew_runtime.object_value('ArgumentError', err.msg())
		}
	}
	result := bump_formula_fetch_resource(resource, if args[1].type_name in [
		'Nil',
		'NilClass',
	] {
		''
	} else {
		args[1].as_string()
	}, args[2].as_string()) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return bump_formula_fetch_value(result)
}

// Ruby method `formula_version(formula, contents = nil)` at line 656.
pub fn ruby_bump_formula_pr_l656_d9_formula_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula is required')
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	contents := if args.len > 1 && args[1].type_name !in ['Nil', 'NilClass'] {
		args[1].as_string()
	} else {
		''
	}
	return brew_runtime.string_value(bump_formula_version(formula, contents))
}

// Ruby method `check_pull_requests(formula, tap_remote_repo, state: nil, version: nil)` at line 671.
pub fn ruby_bump_formula_pr_l671_d10_check_pull_requests(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'formula and tap remote repository are required')
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 2 { args[2].map_data.clone() } else { map[string]brew_runtime.Value{} }
	if check := bump_formula_check_pull_requests(formula, args[1].as_string(), bump_formula_map_string(options, 'state', ''), bump_formula_map_string(options, 'version', ''), bump_formula_map_bool(options, 'quiet', false)) {
		return bump_formula_pull_request_value(check)
	}
	return bump_formula_nil()
}

// Ruby method `check_new_version(formula, tap_remote_repo, version: nil, url: nil, tag: nil)` at line 690.
pub fn ruby_bump_formula_pr_l690_d11_check_new_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'formula and tap remote repository are required')
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 2 { args[2].map_data.clone() } else { map[string]brew_runtime.Value{} }
	check := bump_formula_check_new_version(formula, args[1].as_string(), bump_formula_map_string(options, 'version', ''), bump_formula_map_string(options, 'url', ''), bump_formula_map_string(options, 'tag', ''), bump_formula_map_bool(options, 'write_only', false), bump_formula_map_bool(options, 'quiet', false))
	if check.error != '' {
		return brew_runtime.object_value('RuntimeError', check.error)
	}
	if value := check.check {
		return bump_formula_pull_request_value(value)
	}
	return bump_formula_nil()
}

// Ruby method `alias_update_pair(formula, new_formula_version)` at line 705.
pub fn ruby_bump_formula_pr_l705_d12_alias_update_pair(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'formula and new version are required')
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	if pair := bump_formula_alias_update_pair(formula, args[1].as_string()) {
		return brew_runtime.string_array_value(pair)
	}
	return bump_formula_nil()
}

// Ruby method `parse_resource_versions_arg` at line 721.
pub fn ruby_bump_formula_pr_l721_d13_parse_resource_versions_arg(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name in ['Nil', 'NilClass'] || args[0].as_string().trim_space() == '' {
		return bump_formula_nil()
	}
	versions := bump_formula_parse_resource_versions(args[0].as_string()) or {
		return brew_runtime.Value{
			type_name: 'NilClass'
			repr: 'nil'
			map_data: {
				'warning': brew_runtime.string_value('Failed to parse --resource-versions JSON: ${err.msg()}')
			}
		}
	}
	return bump_formula_resource_versions_value(versions)
}

// Ruby method `update_resource_block!(formula, resource, new_version)` at line 744.
pub fn ruby_bump_formula_pr_l744_d14_update_resource_block(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'formula, resource, and new version are required')
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	resource := bump_formula_resource_from_value(args[1]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := bump_formula_update_resource_block(formula, resource, args[2].as_string()) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.map_value({
		'contents': brew_runtime.string_value(result.contents)
		'status':   brew_runtime.object_value('Symbol', ':${result.status}')
		'message':  brew_runtime.string_value(result.message)
	})
}

// Ruby method `run_audit(formula, alias_rename, skip_synced_versions: false)` at line 799.
pub fn ruby_bump_formula_pr_l799_d15_run_audit(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula is required')
	}
	formula := bump_formula_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	aliases := if args.len > 1 && args[1].type_name !in ['Nil', 'NilClass'] {
		args[1].as_string_array() or { [] }
	} else {
		[]string{}
	}
	values := if args.len > 2 { args[2].map_data.clone() } else { map[string]brew_runtime.Value{} }
	return bump_formula_audit_value(bump_formula_run_audit(formula, aliases, BumpFormulaAuditOptions{
		dry_run: bump_formula_map_bool(values, 'dry_run', false)
		no_audit: bump_formula_map_bool(values, 'no_audit', false)
		strict: bump_formula_map_bool(values, 'strict', false)
		online: bump_formula_map_bool(values, 'online', false)
		skip_synced_versions: bump_formula_map_bool(values, 'skip_synced_versions', false)
		brew_file: bump_formula_map_string(values, 'brew_file', '')
		formula_full_name: bump_formula_map_string(values, 'formula_full_name', formula.full_name)
		succeeded: bump_formula_map_bool(values, 'succeeded', true)
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "bump"
// 6: require "fileutils"
// 7: require "formula"
// 8: require "livecheck/livecheck"
// 9: require "utils/tar"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class BumpFormulaPr < AbstractCommand
// 14:       cmd_args do
// 15:         description <<~EOS
// 16:           Create a pull request to update <formula> with a new URL or a new tag.
// 17:
// 18:           If a <URL> is specified, the <SHA-256> checksum of the new download should also
// 19:           be specified. A best effort to determine the <SHA-256> will be made if not supplied
// 20:           by the user.
// 21:
// 22:           If a <tag> is specified, the Git commit <revision> corresponding to that tag
// 23:           should also be specified. A best effort to determine the <revision> will be made
// 24:           if the value is not supplied by the user.
// 25:
// 26:           If a <version> is specified, a best effort to determine the <URL> and <SHA-256> or
// 27:           the <tag> and <revision> will be made if both values are not supplied by the user.
// 28:
// 29:           *Note:* this command cannot be used to transition a formula from a
// 30:           URL-and-SHA-256 style specification into a tag-and-revision style specification,
// 31:           nor vice versa. It must use whichever style specification the formula already uses.
// 32:         EOS
// 33:         switch "-n", "--dry-run",
// 34:                description: "Print what would be done rather than doing it."
// 35:         switch "--write-only",
// 36:                description: "Make the expected file modifications without taking any Git actions."
// 37:         switch "--commit",
// 38:                depends_on:  "--write-only",
// 39:                description: "When passed with `--write-only`, generate a new commit after writing changes " \
// 40:                             "to the formula file."
// 41:         switch "--no-audit",
// 42:                description: "Don't run `brew audit` before opening the PR."
// 43:         switch "--strict",
// 44:                description: "Run `brew audit --strict` before opening the PR."
// 45:         switch "--online",
// 46:                description: "Run `brew audit --online` before opening the PR."
// 47:         switch "--no-browse",
// 48:                description: "Print the pull request URL instead of opening in a browser."
// 49:         switch "--no-fork",
// 50:                description: "Don't try to fork the repository."
// 51:         comma_array "--mirror",
// 52:                     description: "Use the specified <URL> as a mirror URL. If <URL> is a comma-separated list " \
// 53:                                  "of URLs, multiple mirrors will be added."
// 54:         flag   "--fork-org=",
// 55:                description: "Use the specified GitHub organization for forking."
// 56:         flag   "--version=",
// 57:                description: "Use the specified <version> to override the value parsed from the URL or tag. Note " \
// 58:                             "that `--version=0` can be used to delete an existing version override from a " \
// 59:                             "formula if it has become redundant."
// 60:         flag   "--message=",
// 61:                description: "Prepend <message> to the default pull request message."
// 62:         flag   "--url=",
// 63:                description: "Specify the <URL> for the new download. If a <URL> is specified, the <SHA-256> " \
// 64:                             "checksum of the new download should also be specified."
// 65:         flag   "--sha256=",
// 66:                depends_on:  "--url=",
// 67:                description: "Specify the <SHA-256> checksum of the new download."
// 68:         flag   "--tag=",
// 69:                description: "Specify the new git commit <tag> for the formula."
// 70:         flag   "--revision=",
// 71:                description: "Specify the new commit <revision> corresponding to the specified git <tag> " \
// 72:                             "or specified <version>."
// 73:         switch "-f", "--force",
// 74:                description: "Remove all mirrors if `--mirror` was not specified."
// 75:         switch "--install-dependencies",
// 76:                description: "Install missing dependencies required to update resources."
// 77:         flag   "--python-package-name=",
// 78:                description: "Use the specified <package-name> when finding Python resources for <formula>. " \
// 79:                             "If no package name is specified, it will be inferred from the formula's stable URL."
// 80:         comma_array "--python-extra-packages=",
// 81:                     description: "Include these additional Python packages when finding resources."
// 82:         comma_array "--python-exclude-packages=",
// 83:                     description: "Exclude these Python packages when finding resources."
// 84:         comma_array "--bump-synced=",
// 85:                     hidden: true
// 86:         flag   "--resource-versions=",
// 87:                description: "JSON-encoded resource version data from `brew bump`.",
// 88:                hidden:      true
// 89:
// 90:         conflicts "--dry-run", "--write-only"
// 91:         conflicts "--no-audit", "--strict"
// 92:         conflicts "--no-audit", "--online"
// 93:         conflicts "--url", "--tag"
// 94:
// 95:         named_args :formula, max: 1, without_api: true
// 96:       end
// 97:
// 98:       sig { override.void }
// 99:       def run
// 100:         Homebrew.install_bundler_gems!(groups: ["ast"])
// 101:         require "utils/ast"
// 102:         require "utils/pypi"
// 103:
// 104:         if args.revision.present? && args.tag.nil? && args.version.nil?
// 105:           raise UsageError, "`--revision` must be passed with either `--tag` or `--version`!"
// 106:         end
// 107:
// 108:         # As this command is simplifying user-run commands then let's just use a
// 109:         # user path, too.
// 110:         ENV["PATH"] = PATH.new(ORIGINAL_PATHS).to_s
// 111:
// 112:         # Use the user's browser, too.
// 113:         ENV["BROWSER"] = Homebrew::EnvConfig.browser
// 114:
// 115:         @tap_retried = T.let(false, T.nilable(T::Boolean))
// 116:         begin
// 117:           formula = args.named.to_formulae.first
// 118:           raise FormulaUnspecifiedError if formula.blank?
// 119:
// 120:           raise ArgumentError, "This formula is disabled!" if formula.disabled?
// 121:           if formula.deprecation_reason == :does_not_build
// 122:             raise ArgumentError, "This formula is deprecated and does not build!"
// 123:           end
// 124:
// 125:           tap = formula.tap
// 126:           raise ArgumentError, "This formula is not in a tap!" if tap.blank?
// 127:           raise ArgumentError, "This formula's tap is not a Git repository!" unless tap.git?
// 128:         rescue ArgumentError => e
// 129:           odie e.message if @tap_retried
// 130:
// 131:           CoreTap.instance.install(force: true)
// 132:           @tap_retried = true
// 133:           retry
// 134:         end
// 135:
// 136:         odie <<~EOS unless tap.allow_bump?(formula.name)
// 137:           Whoops, the #{formula.name} formula has its version update
// 138:           pull requests automatically opened by BrewTestBot every ~3 hours!
// 139:           We'd still love your contributions, though, so try another one
// 140:           that is excluded from autobump list (i.e. it has 'no_autobump!'
// 141:           method or 'livecheck' block with 'skip'.)
// 142:         EOS
// 143:
// 144:         if !args.write_only? && GitHub.too_many_open_prs?(tap)
// 145:           odie "You have too many PRs open: close or merge some first!"
// 146:         end
// 147:
// 148:         formula_spec = formula.stable
// 149:         odie "#{formula}: no stable specification found!" if formula_spec.blank?
// 150:
// 151:         # This will be run by `brew audit` later so run it first to not start
// 152:         # spamming during normal output.
// 153:         Homebrew.install_bundler_gems!(groups: ["audit", "style"]) unless args.no_audit?
// 154:
// 155:         tap_remote_repo = tap.remote_repository
// 156:         odie "#{tap.name} tap does not have a remote repository!" if tap_remote_repo.nil?
// 157:
// 158:         check_pull_requests(formula, tap_remote_repo, state: "open") unless args.write_only?
// 159:
// 160:         all_formulae = []
// 161:         if args.bump_synced.present?
// 162:           Array(args.bump_synced).each do |formula_name|
// 163:             all_formulae << formula_name
// 164:           end
// 165:         else
// 166:           all_formulae << args.named.first.to_s
// 167:         end
// 168:
// 169:         return if all_formulae.empty?
// 170:
// 171:         added_release_info = Set.new
// 172:
// 173:         commits = all_formulae.filter_map do |formula_name|
// 174:           commit_formula = Formula[formula_name]
// 175:           raise FormulaUnspecifiedError if commit_formula.blank?
// 176:
// 177:           commit_formula_spec = commit_formula.stable
// 178:           odie "#{commit_formula}: no stable specification found!" if commit_formula_spec.blank?
// 179:
// 180:           formula_pr_message = ""
// 181:
// 182:           new_url = args.url
// 183:           new_version = args.version
// 184:
// 185:           check_new_version(commit_formula, tap_remote_repo, version: new_version) if new_version.present?
// 186:
// 187:           opoo "This formula has patches that may be resolved upstream." if commit_formula.patchlist.present?
// 188:           if commit_formula.resources.any? { |resource| !resource.name.start_with?("homebrew-") }
// 189:             opoo "This formula has resources that may need to be updated."
// 190:           end
// 191:
// 192:           old_mirrors = commit_formula_spec.mirrors
// 193:           new_mirrors ||= args.mirror
// 194:           if new_url.present? && (new_mirror = determine_mirror(new_url))
// 195:             new_mirrors ||= [new_mirror]
// 196:             check_for_mirrors(commit_formula.name, old_mirrors, new_mirrors)
// 197:           end
// 198:
// 199:           old_hash = commit_formula_spec.checksum&.hexdigest
// 200:
// 201:           new_hash = args.sha256
// 202:           new_tag = args.tag
// 203:           new_revision = args.revision
// 204:           old_url = T.must(commit_formula_spec.url)
// 205:           old_tag = commit_formula_spec.specs[:tag]
// 206:           old_formula_version = formula_version(commit_formula)
// 207:           old_version = old_formula_version.to_s
// 208:           forced_version = new_version.present?
// 209:           new_url_hash = if new_url.present? && new_hash.present?
// 210:             check_new_version(commit_formula, tap_remote_repo, url: new_url) if new_version.blank?
// 211:             true
// 212:           elsif new_tag.present? && new_revision.present?
// 213:             check_new_version(commit_formula, tap_remote_repo, url: old_url, tag: new_tag) if new_version.blank?
// 214:             false
// 215:           elsif old_hash.blank?
// 216:             if new_tag.blank? && new_version.blank? && new_revision.blank?
// 217:               raise UsageError, "#{formula}: no `--tag` or `--version` argument specified!"
// 218:             end
// 219:
// 220:             if old_tag.present?
// 221:               new_tag ||= old_tag.gsub(old_version, new_version)
// 222:               if new_tag == old_tag
// 223:                 odie <<~EOS
// 224:                   You need to bump this formula manually since the new tag
// 225:                   and old tag are both #{new_tag}.
// 226:                 EOS
// 227:               end
// 228:               check_new_version(commit_formula, tap_remote_repo, url: old_url, tag: new_tag) if new_version.blank?
// 229:               resource_path, forced_version = fetch_resource_and_forced_version(commit_formula, new_version, old_url,
// 230:                                                                                 tag: new_tag)
// 231:               new_revision = Utils.popen_read("git", "-C", resource_path.to_s, "rev-parse", "-q", "--verify", "HEAD")
// 232:               new_revision = new_revision.strip
// 233:             elsif new_revision.blank?
// 234:               odie "#{commit_formula}: the current URL requires specifying a `--revision=` argument."
// 235:             end
// 236:             false
// 237:           elsif new_url.blank? && new_version.blank?
// 238:             raise UsageError, "#{commit_formula}: no `--url` or `--version` argument specified!"
// 239:           else
// 240:             new_url ||= PyPI.update_pypi_url(old_url, new_version) if new_version.present?
// 241:
// 242:             if new_url.blank? && new_version.present?
// 243:               new_url = update_url(old_url, old_version, new_version)
// 244:               if new_mirrors.blank? && old_mirrors.present?
// 245:                 new_mirrors = old_mirrors.map do |old_mirror|
// 246:                   update_url(old_mirror, old_version, new_version)
// 247:                 end
// 248:               end
// 249:             end
// 250:             if new_url == old_url
// 251:               odie <<~EOS
// 252:                 You need to bump this formula manually since the new URL
// 253:                 and old URL are both:
// 254:                   #{new_url}
// 255:               EOS
// 256:             end
// 257:             if new_url.blank?
// 258:               odie "There was an issue generating the updated url, you may need to create the PR manually"
// 259:             end
// 260:             check_new_version(commit_formula, tap_remote_repo, url: new_url) if new_version.blank?
// 261:             resource_path, forced_version = fetch_resource_and_forced_version(commit_formula, new_version, new_url)
// 262:             Utils::Tar.validate_file(resource_path)
// 263:             new_hash = resource_path.sha256
// 264:           end
// 265:
// 266:           old_contents = commit_formula.path.read
// 267:           formula_ast = Utils::AST::FormulaAST.new(old_contents)
// 268:
// 269:           formula_ast.remove_stanza(:revision) if commit_formula.revision.nonzero?
// 270:           formula_ast.remove_stable_stanzas(:mirror) if commit_formula_spec.mirrors.present?
// 271:
// 272:           if new_url_hash.present?
// 273:             formula_ast.replace_stable_stanza_value(:url, T.must(new_url))
// 274:             formula_ast.replace_stable_stanza_value(:sha256, new_hash)
// 275:           elsif new_tag.present?
// 276:             formula_ast.replace_stable_stanza_hash_value(:url, :tag, new_tag)
// 277:             formula_ast.replace_stable_stanza_hash_value(:url, :revision, T.must(new_revision))
// 278:           elsif new_url.present?
// 279:             formula_ast.replace_stable_stanza_value(:url, new_url)
// 280:             formula_ast.replace_stable_stanza_hash_value(:url, :revision, T.must(new_revision))
// 281:           else
// 282:             formula_ast.replace_stable_stanza_hash_value(:url, :revision, T.must(new_revision))
// 283:           end
// 284:
// 285:           stanzas_to_add = []
// 286:           new_mirrors&.each { |mirror| stanzas_to_add << [:mirror, "mirror #{mirror.inspect}"] } if new_url.present?
// 287:           if forced_version && new_version != "0"
// 288:             if formula_ast.stable_stanza?(:version)
// 289:               formula_ast.replace_stable_stanza_value(:version, T.must(new_version))
// 290:             else
// 291:               stanzas_to_add << [:version, T.must(new_version)]
// 292:             end
// 293:           elsif forced_version && new_version == "0"
// 294:             formula_ast.remove_stable_stanza(:version) if formula_ast.stable_stanza?(:version)
// 295:           end
// 296:           formula_ast.add_stable_stanzas_after(:url, stanzas_to_add) if stanzas_to_add.present?
// 297:           new_contents = formula_ast.process
// 298:           commit_formula.path.atomic_write(new_contents) unless args.dry_run?
// 299:
// 300:           new_formula_version = formula_version(commit_formula, new_contents)
// 301:
// 302:           if new_formula_version < old_formula_version
// 303:             commit_formula.path.atomic_write(old_contents) unless args.dry_run?
// 304:             odie <<~EOS
// 305:               You need to bump this formula manually since changing the version
// 306:               from #{old_formula_version} to #{new_formula_version} would be a downgrade.
// 307:             EOS
// 308:           elsif new_formula_version == old_formula_version
// 309:             commit_formula.path.atomic_write(old_contents) unless args.dry_run?
// 310:             odie <<~EOS
// 311:               You need to bump this formula manually since the new version
// 312:               and old version are both #{new_formula_version}.
// 313:             EOS
// 314:           end
// 315:
// 316:           alias_rename = alias_update_pair(commit_formula, new_formula_version)
// 317:           if alias_rename.present?
// 318:             ohai "Renaming alias #{alias_rename.first} to #{alias_rename.last}"
// 319:             alias_rename.map! { |a| tap.alias_dir/a }
// 320:           end
// 321:
// 322:           resource_update_results = {}
// 323:           unless args.dry_run?
// 324:             resources_checked = PyPI.update_python_resources! formula,
// 325:                                                               version:                  new_formula_version.to_s,
// 326:                                                               package_name:             args.python_package_name,
// 327:                                                               extra_packages:           args.python_extra_packages,
// 328:                                                               exclude_packages:         args.python_exclude_packages,
// 329:                                                               install_dependencies:     args.install_dependencies?,
// 330:                                                               quiet:                    args.quiet?,
// 331:                                                               ignore_non_pypi_packages: true
// 332:
// 333:             resource_versions = parse_resource_versions_arg
// 334:             resource_update_results.merge!(
// 335:               update_matching_version_resources!(commit_formula,
// 336:                                                  version:           new_formula_version.to_s,
// 337:                                                  resource_versions:),
// 338:             )
// 339:
// 340:             if resource_versions.present?
// 341:               resource_update_results.merge!(
// 342:                 update_resources!(commit_formula, resource_versions:),
// 343:               )
// 344:             end
// 345:           end
// 346:
// 347:           checked_statuses = [:success, :up_to_date, :downgraded]
// 348:           failed_updates = resource_update_results.reject { |_, v| checked_statuses.include?(v) }
// 349:           downgraded_resources = resource_update_results.select { |_, v| v == :downgraded }
// 350:
// 351:           # Check if there are any resources that still need manual update:
// 352:           unchecked_resources = commit_formula.resources.select do |resource|
// 353:             next false if resource.name.start_with?("homebrew-")
// 354:             next false if resource_update_results.key?(resource.name)
// 355:             next false if resource.livecheck.formula == :parent
// 356:
// 357:             true
// 358:           end
// 359:
// 360:           formula_checkboxes = []
// 361:
// 362:           if failed_updates.any? || (resources_checked.nil? && unchecked_resources.any?)
// 363:             formula_checkboxes << "- [ ] `resource` blocks have been checked for updates."
// 364:
// 365:             if failed_updates.any?
// 366:               formula_checkboxes << "#{failed_updates.map do |name, status|
// 367:                 "  - Resource `#{name}` failed to auto-update (#{status})."
// 368:               end.join("\n")}\n"
// 369:             end
// 370:           end
// 371:
// 372:           if downgraded_resources.any?
// 373:             resource_names = downgraded_resources.keys.map { |name| "`#{name}`" }.join(", ")
// 374:             verb = (downgraded_resources.size == 1) ? "was" : "were"
// 375:             formula_checkboxes <<
// 376:               "**Warning:** #{resource_names} #{verb} " \
// 377:               "downgraded to match the latest upstream version."
// 378:           end
// 379:
// 380:           annotation_comments = %w[TODO FIXME]
// 381:           if annotation_comments.any? { |s| new_contents.include?("#{s}:") }
// 382:             formula_checkboxes << "- [ ] TODO and FIXME comments have been checked."
// 383:           end
// 384:
// 385:           if formula_checkboxes.present?
// 386:             formula_pr_message += <<~EOS
// 387:
// 388:
// 389:               #{formula_checkboxes.join("\n")}
// 390:             EOS
// 391:           end
// 392:
// 393:           if new_url =~ %r{^https://github\.com/([\w-]+)/([\w-]+)/archive/refs/tags/(v?[.0-9]+)\.tar\.}
// 394:             owner = Regexp.last_match(1)
// 395:             repo = Regexp.last_match(2)
// 396:             tag = Regexp.last_match(3)
// 397:             release_id = "#{owner}/#{repo}/#{tag}"
// 398:             github_release_data = begin
// 399:               GitHub::API.open_rest("#{GitHub::API_URL}/repos/#{owner}/#{repo}/releases/tags/#{tag}")
// 400:             rescue GitHub::API::HTTPNotFoundError
// 401:               # If this is a 404: we can't do anything.
// 402:               nil
// 403:             end
// 404:
// 405:             if github_release_data.present? && github_release_data["body"].present? &&
// 406:                added_release_info.exclude?(release_id)
// 407:               pre = "pre" if github_release_data["prerelease"].present?
// 408:               # maximum length of PR body is 65,536 characters so let's truncate release notes to half of that.
// 409:               body = Formatter.truncate(github_release_data["body"], max: 32_768)
// 410:
// 411:               # Ensure the URL is properly HTML encoded to handle any quotes or other special characters
// 412:               html_url = CGI.escapeHTML(github_release_data["html_url"])
// 413:
// 414:               formula_pr_message += <<~XML
// 415:                 <details>
// 416:                   <summary>#{pre}release notes</summary>
// 417:                   <pre>#{body}</pre>
// 418:                   <p>View the full release notes at <a href="#{html_url}">#{html_url}</a>.</p>
// 419:                 </details>
// 420:               XML
// 421:
// 422:               added_release_info << release_id
// 423:             end
// 424:           end
// 425:
// 426:           {
// 427:             sourcefile_path:    commit_formula.path,
// 428:             old_contents:,
// 429:             commit_message:     "#{commit_formula.name} #{new_formula_version}",
// 430:             additional_files:   alias_rename,
// 431:             formula_pr_message:,
// 432:             formula_name:       commit_formula.name,
// 433:             new_version:        new_formula_version,
// 434:           }
// 435:         end
// 436:
// 437:         commits.each do |commit|
// 438:           commit_formula = Formula[commit[:formula_name]]
// 439:           # For each formula, run `brew audit` to check for any issues.
// 440:           audit_result = run_audit(commit_formula, commit[:additional_files],
// 441:                                    skip_synced_versions: args.bump_synced.present?)
// 442:
// 443:           next unless audit_result
// 444:
// 445:           # If `brew audit` fails, revert the changes made to any formula.
// 446:           commits.each do |revert|
// 447:             revert_formula = Formula[revert[:formula_name]]
// 448:             revert_formula.path.atomic_write(revert[:old_contents]) if !args.dry_run? && !args.write_only?
// 449:             revert_alias_rename = revert[:additional_files]
// 450:             if revert_alias_rename && (source = revert_alias_rename.first) && (destination = revert_alias_rename.last)
// 451:               FileUtils.mv source, destination
// 452:             end
// 453:           end
// 454:
// 455:           odie "`brew audit` failed for #{commit[:formula_name]}!"
// 456:         end
// 457:
// 458:         new_formula_version = commits.fetch(0)[:new_version]
// 459:
// 460:         pr_title = if args.bump_synced.nil?
// 461:           "#{formula.name} #{new_formula_version}"
// 462:         else
// 463:           maximum_characters_in_title = 72
// 464:           max = maximum_characters_in_title - new_formula_version.to_s.length - 1
// 465:           "#{Formatter.truncate(Array(args.bump_synced).join(" "), max:)} #{new_formula_version}"
// 466:         end
// 467:
// 468:         pr_message = Homebrew::Bump.pr_message("bump-formula-pr", user_message: args.message)
// 469:         commits.each do |commit|
// 470:           next if commit[:formula_pr_message].empty?
// 471:
// 472:           pr_message += "<h4>#{commit[:formula_name]}</h4>" if commits.length != 1
// 473:           pr_message += "#{commit[:formula_pr_message]}<hr>"
// 474:         end
// 475:
// 476:         return if args.write_only? && !args.commit?
// 477:
// 478:         url = Homebrew::Bump.create_pr(
// 479:           Homebrew::Bump::BumpInfo.new(
// 480:             package_tap: tap,
// 481:             branch_name: "bump-#{formula.name}-#{new_formula_version}",
// 482:             pr_title:,
// 483:             pr_message:,
// 484:             commits:     commits.map do |commit|
// 485:               Homebrew::Bump::Commit.new(
// 486:                 sourcefile_path:  commit[:sourcefile_path],
// 487:                 old_contents:     commit[:old_contents],
// 488:                 commit_message:   commit[:commit_message],
// 489:                 additional_files: commit[:additional_files] || [],
// 490:               )
// 491:             end,
// 492:           ),
// 493:           dry_run:  args.dry_run?,
// 494:           no_fork:  args.no_fork? || args.write_only?,
// 495:           fork_org: args.fork_org,
// 496:           commit:   args.commit?,
// 497:         )
// 498:         return if url.blank?
// 499:
// 500:         if args.no_browse?
// 501:           puts url
// 502:         else
// 503:           exec_browser url
// 504:         end
// 505:       end
// 506:
// 507:       sig { params(formula: Formula, new_version: String).void }
// 508:       def check_throttle(formula, new_version)
// 509:         tap = formula.tap
// 510:         return if tap.nil?
// 511:
// 512:         throttle_rate = formula.livecheck.throttle
// 513:         throttle_days = formula.livecheck.throttle_days
// 514:         return if throttle_rate.nil? && throttle_days.nil?
// 515:
// 516:         return if Livecheck.throttle_allows_bump?(
// 517:           formula,
// 518:           new_version,
// 519:           throttle_rate: throttle_rate,
// 520:           throttle_days: throttle_days,
// 521:         )
// 522:
// 523:         throttle_items = []
// 524:         throttle_items << "#{throttle_rate} releases on multiples of #{throttle_rate}" if throttle_rate
// 525:         throttle_items << "#{throttle_days} #{Utils.pluralize("day", throttle_days)}" if throttle_days
// 526:
// 527:         odie "#{formula} should only be updated every #{throttle_items.join(" or ")}"
// 528:       end
// 529:
// 530:       sig {
// 531:         params(
// 532:           formula:           Formula,
// 533:           version:           String,
// 534:           resource_versions: T.nilable(T::Hash[String, T::Hash[Symbol, T.nilable(String)]]),
// 535:         ).returns(T::Hash[String, Symbol])
// 536:       }
// 537:       def update_matching_version_resources!(formula, version:, resource_versions: nil)
// 538:         resource_versions ||= {}
// 539:         formula.resources
// 540:                .select { |r| r.livecheck.formula == :parent && resource_versions[r.name].blank? }
// 541:                .to_h { |resource| [resource.name, update_resource_block!(formula, resource, version)] }
// 542:       end
// 543:
// 544:       sig {
// 545:         params(
// 546:           formula:           Formula,
// 547:           resource_versions: T::Hash[String, T::Hash[Symbol, T.nilable(String)]],
// 548:         ).returns(T::Hash[String, Symbol])
// 549:       }
// 550:       def update_resources!(formula, resource_versions:)
// 551:         results = {}
// 552:
// 553:         formula.resources.each do |resource|
// 554:           version_data = resource_versions[resource.name]
// 555:           next if version_data.blank?
// 556:
// 557:           current_version = version_data[:current_version]
// 558:           latest_version = version_data[:latest_version]
// 559:
// 560:           if current_version.blank? || latest_version.blank?
// 561:             opoo "Could not determine versions for resource \"#{resource.name}\""
// 562:             results[resource.name] = :version_unknown
// 563:             next
// 564:           end
// 565:
// 566:           if current_version == latest_version
// 567:             results[resource.name] = :up_to_date
// 568:             next
// 569:           end
// 570:
// 571:           is_downgraded = Version.new(current_version) > Version.new(latest_version)
// 572:
// 573:           begin
// 574:             result = update_resource_block!(formula, resource, latest_version)
// 575:             results[resource.name] = if result == :success && is_downgraded
// 576:               :downgraded
// 577:             else
// 578:               result
// 579:             end
// 580:           rescue => e
// 581:             opoo "Failed to update resource \"#{resource.name}\": #{e}"
// 582:             results[resource.name] = :fetch_failed
// 583:           end
// 584:         end
// 585:
// 586:         results
// 587:       end
// 588:
// 589:       private
// 590:
// 591:       sig { params(url: String).returns(T.nilable(String)) }
// 592:       def determine_mirror(url)
// 593:         case url
// 594:         when %r{.*ftp\.gnu\.org/gnu.*}
// 595:           url.sub "ftp.gnu.org/gnu", "ftpmirror.gnu.org"
// 596:         when %r{.*download\.savannah\.gnu\.org/*}
// 597:           url.sub "download.savannah.gnu.org", "download-mirror.savannah.gnu.org"
// 598:         when %r{.*www\.apache\.org/dyn/closer\.lua\?path=.*}
// 599:           url.sub "www.apache.org/dyn/closer.lua?path=", "archive.apache.org/dist/"
// 600:         when %r{.*mirrors\.ocf\.berkeley\.edu/debian.*}
// 601:           url.sub "mirrors.ocf.berkeley.edu/debian", "mirrorservice.org/sites/ftp.debian.org/debian"
// 602:         end
// 603:       end
// 604:
// 605:       sig { params(formula: String, old_mirrors: T::Array[String], new_mirrors: T::Array[String]).void }
// 606:       def check_for_mirrors(formula, old_mirrors, new_mirrors)
// 607:         return if new_mirrors.present? || old_mirrors.empty?
// 608:
// 609:         if args.force?
// 610:           opoo "#{formula}: Removing all mirrors because a `--mirror=` argument was not specified."
// 611:         else
// 612:           odie <<~EOS
// 613:             #{formula}: a `--mirror=` argument for updating the mirror URL(s) was not specified.
// 614:             Use `--force` to remove all mirrors.
// 615:           EOS
// 616:         end
// 617:       end
// 618:
// 619:       sig { params(old_url: String, old_version: String, new_version: String).returns(String) }
// 620:       def update_url(old_url, old_version, new_version)
// 621:         new_url = old_url.gsub(old_version, new_version)
// 622:         new_url.gsub!(old_version.tr(".", "_"), new_version.tr(".", "_")) if old_version.include?(".")
// 623:
// 624:         return new_url if (old_version_parts = old_version.split(".")).length < 2
// 625:         return new_url if (new_version_parts = new_version.split(".")).length != old_version_parts.length
// 626:
// 627:         partial_old_version = old_version_parts[0..-2]&.join(".")
// 628:         partial_new_version = new_version_parts[0..-2]&.join(".")
// 629:         return new_url if partial_old_version.blank? || partial_new_version.blank?
// 630:
// 631:         new_url.gsub(%r{/(v?)#{Regexp.escape(partial_old_version)}/}, "/\\1#{partial_new_version}/")
// 632:       end
// 633:
// 634:       sig {
// 635:         params(formula_or_resource: T.any(Formula, Resource), new_version: T.nilable(String), url: String,
// 636:                specs: String).returns(T::Array[T.untyped])
// 637:       }
// 638:       def fetch_resource_and_forced_version(formula_or_resource, new_version, url, **specs)
// 639:         resource = Resource.new
// 640:         resource.url(url, **specs)
// 641:         resource.owner = if formula_or_resource.is_a?(Formula)
// 642:           Resource.new(formula_or_resource.name)
// 643:         else
// 644:           owner = formula_or_resource.owner
// 645:           raise "Owner of Resource#{formula_or_resource.name} is nil" if owner.nil?
// 646:
// 647:           Resource.new(owner.name)
// 648:         end
// 649:         forced_version = new_version && new_version != resource.version.to_s
// 650:         resource.version(new_version) if forced_version
// 651:         odie "Couldn't identify version, specify it using `--version=`." if resource.version.blank?
// 652:         [resource.fetch, forced_version]
// 653:       end
// 654:
// 655:       sig { params(formula: Formula, contents: T.nilable(String)).returns(Version) }
// 656:       def formula_version(formula, contents = nil)
// 657:         spec = :stable
// 658:         name = formula.name
// 659:         path = formula.path
// 660:         if contents.present?
// 661:           Formulary.from_contents(name, path, contents, spec).version
// 662:         else
// 663:           Formulary::FormulaLoader.new(name, path).get_formula(spec).version
// 664:         end
// 665:       end
// 666:
// 667:       sig {
// 668:         params(formula: Formula, tap_remote_repo: String, state: T.nilable(String),
// 669:                version: T.nilable(String)).void
// 670:       }
// 671:       def check_pull_requests(formula, tap_remote_repo, state: nil, version: nil)
// 672:         tap = formula.tap
// 673:         return if tap.nil?
// 674:
// 675:         # if we haven't already found open requests, try for an exact match across all pull requests
// 676:         GitHub.check_for_duplicate_pull_requests(
// 677:           formula.name, tap_remote_repo,
// 678:           version:,
// 679:           state:,
// 680:           file:         formula.path.relative_path_from(tap.path).to_s,
// 681:           quiet:        args.quiet?,
// 682:           official_tap: tap.official?
// 683:         )
// 684:       end
// 685:
// 686:       sig {
// 687:         params(formula: Formula, tap_remote_repo: String, version: T.nilable(String), url: T.nilable(String),
// 688:                tag: T.nilable(String)).void
// 689:       }
// 690:       def check_new_version(formula, tap_remote_repo, version: nil, url: nil, tag: nil)
// 691:         if version.nil?
// 692:           specs = {}
// 693:           specs[:tag] = tag if tag.present?
// 694:           return if url.blank?
// 695:
// 696:           version = Version.detect(url, **specs).to_s
// 697:           return if version.blank?
// 698:         end
// 699:
// 700:         check_throttle(formula, version)
// 701:         check_pull_requests(formula, tap_remote_repo, version:) unless args.write_only?
// 702:       end
// 703:
// 704:       sig { params(formula: Formula, new_formula_version: Version).returns(T.nilable(T::Array[String])) }
// 705:       def alias_update_pair(formula, new_formula_version)
// 706:         versioned_alias = formula.aliases.grep(/^.*@\d+(\.\d+)?$/).first
// 707:         return if versioned_alias.nil?
// 708:
// 709:         name, old_alias_version = versioned_alias.split("@")
// 710:         return if old_alias_version.blank?
// 711:
// 712:         new_alias_regex = (old_alias_version.split(".").length == 1) ? /^\d+/ : /^\d+\.\d+/
// 713:         new_alias_version, = *new_formula_version.to_s.match(new_alias_regex)
// 714:         return if new_alias_version.blank?
// 715:         return if Version.new(new_alias_version) <= Version.new(old_alias_version)
// 716:
// 717:         [versioned_alias, "#{name}@#{new_alias_version}"]
// 718:       end
// 719:
// 720:       sig { returns(T.nilable(T::Hash[String, T::Hash[Symbol, T.nilable(String)]])) }
// 721:       def parse_resource_versions_arg
// 722:         return if (resource_versions = args.resource_versions).blank?
// 723:
// 724:         require "json"
// 725:         resource_data = JSON.parse(resource_versions)
// 726:         resource_data.to_h do |r|
// 727:           [r["name"], { current_version: r["current_version"], latest_version: r["latest_version"] }]
// 728:         end
// 729:       rescue JSON::ParserError => e
// 730:         opoo "Failed to parse --resource-versions JSON: #{e.message}"
// 731:         nil
// 732:       end
// 733:
// 734:       # TODO: Add support for resources using `tag` and/or `revision` instead of
// 735:       # `url`+`sha256`, resource URLs with options, and resources inside `on_os`
// 736:       # or `on_arch` blocks.
// 737:       sig {
// 738:         params(
// 739:           formula:     Formula,
// 740:           resource:    Resource,
// 741:           new_version: String,
// 742:         ).returns(Symbol)
// 743:       }
// 744:       def update_resource_block!(formula, resource, new_version)
// 745:         ohai "Updating resource \"#{resource.name}\" from #{resource.version} to #{new_version}"
// 746:
// 747:         old_url = T.must(resource.url)
// 748:         new_url = update_url(old_url, resource.version.to_s, new_version)
// 749:
// 750:         if new_url == old_url
// 751:           opoo <<~EOS
// 752:             You need to bump resource "#{resource.name}" manually since the new URL
// 753:             and old URL are both:
// 754:               #{new_url}
// 755:           EOS
// 756:           return :url_unchanged
// 757:         end
// 758:
// 759:         new_mirrors = resource.mirrors.map do |mirror|
// 760:           update_url(mirror, resource.version.to_s, new_version)
// 761:         end
// 762:         resource_path, forced_version = fetch_resource_and_forced_version(resource, new_version, new_url)
// 763:         Utils::Tar.validate_file(resource_path)
// 764:         new_hash = resource_path.sha256
// 765:
// 766:         resource_name = resource.name.to_s
// 767:         formula_ast = Utils::AST::FormulaAST.new(formula.path.read)
// 768:         formula_ast.replace_resource_stanza_value(resource_name, :url, new_url, old_value: old_url)
// 769:
// 770:         resource.mirrors.each_with_index do |old_mirror, i|
// 771:           next if new_mirrors[i].blank?
// 772:
// 773:           formula_ast.replace_resource_stanza_value(resource_name, :mirror, new_mirrors.fetch(i),
// 774:                                                     old_value: old_mirror)
// 775:         end
// 776:
// 777:         if (old_checksum = resource.checksum&.hexdigest).present?
// 778:           formula_ast.replace_resource_stanza_value(resource_name, :sha256, new_hash, old_value: old_checksum)
// 779:         end
// 780:
// 781:         if forced_version
// 782:           if formula_ast.resource_stanza?(resource_name, :version)
// 783:             formula_ast.replace_resource_stanza_value(resource_name, :version, new_version)
// 784:           else
// 785:             formula_ast.add_stanzas_after(:sha256, [[:version, new_version]],
// 786:                                           parent: formula_ast.resource(resource_name))
// 787:           end
// 788:         end
// 789:
// 790:         formula.path.atomic_write(formula_ast.process)
// 791:
// 792:         :success
// 793:       end
// 794:
// 795:       sig {
// 796:         params(formula: Formula, alias_rename: T.nilable(T::Array[String]),
// 797:                skip_synced_versions: T::Boolean).returns(T::Boolean)
// 798:       }
// 799:       def run_audit(formula, alias_rename, skip_synced_versions: false)
// 800:         audit_args = ["--formula"]
// 801:         audit_args << "--strict" if args.strict?
// 802:         audit_args << "--online" if args.online?
// 803:         audit_args << "--except=synced_versions_formulae" if skip_synced_versions
// 804:         if args.dry_run?
// 805:           if args.no_audit?
// 806:             ohai "Skipping `brew audit`"
// 807:           elsif audit_args.present?
// 808:             ohai "brew audit #{audit_args.join(" ")} #{formula.path.basename}"
// 809:           else
// 810:             ohai "brew audit #{formula.path.basename}"
// 811:           end
// 812:           return true
// 813:         end
// 814:         if alias_rename && (source = alias_rename.first) && (destination = alias_rename.last)
// 815:           FileUtils.mv source, destination
// 816:         end
// 817:         failed_audit = false
// 818:         if args.no_audit?
// 819:           ohai "Skipping `brew audit`"
// 820:         elsif audit_args.present?
// 821:           system HOMEBREW_BREW_FILE.to_s, "audit", *audit_args, formula.full_name
// 822:           failed_audit = !$CHILD_STATUS.success?
// 823:         else
// 824:           system HOMEBREW_BREW_FILE.to_s, "audit", formula.full_name
// 825:           failed_audit = !$CHILD_STATUS.success?
// 826:         end
// 827:         failed_audit
// 828:       end
// 829:     end
// 830:   end
// 831: end
