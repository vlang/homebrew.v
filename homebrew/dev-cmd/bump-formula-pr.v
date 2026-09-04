module dev_cmd

import crypto.sha256
import ruby
import homebrew
import homebrew.extend.file as atomic_file
import homebrew.utils
import os

// Translated from Homebrew/brew `dev-cmd/bump-formula-pr.rb`.

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

fn bump_formula_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn bump_formula_bool(value ruby.Value, fallback bool) bool {
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn bump_formula_map_string(values map[string]ruby.Value, key string,
	fallback string) string {
	return (values[key] or { ruby.string_value(fallback) }).as_string()
}

fn bump_formula_map_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	return bump_formula_bool(values[key] or { ruby.bool_value(fallback) }, fallback)
}

fn bump_formula_optional_int(values map[string]ruby.Value, key string) ?int {
	value := values[key] or { return none }
	if value.type_name in ['Nil', 'NilClass'] {
		return none
	}
	return int(value.int_data)
}

fn bump_formula_string_map_value(values map[string]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

pub fn bump_formula_resource_value(resource BumpFormulaResource) ruby.Value {
	return ruby.Value{
		type_name: 'Resource'
		repr: resource.name
		map_data: {
			'name':             ruby.string_value(resource.name)
			'version':          ruby.string_value(resource.version)
			'url':              ruby.string_value(resource.url)
			'mirrors':          ruby.string_array_value(resource.mirrors)
			'checksum':         ruby.string_value(resource.checksum)
			'owner_name':       ruby.string_value(resource.owner_name)
			'livecheck_parent': ruby.bool_value(resource.livecheck_parent)
			'fetch_path':       ruby.string_value(resource.fetch_path)
			'fetched_version':  ruby.string_value(resource.fetched_version)
			'fetched_sha256':   ruby.string_value(resource.fetched_sha256)
			'fetch_error':      ruby.string_value(resource.fetch_error)
		}
	}
}

fn bump_formula_resource_from_value(value ruby.Value) !BumpFormulaResource {
	if value.type_name !in ['Resource', 'Hash'] {
		return error('expected Resource, got ${value.type_name}')
	}
	values := value.map_data.clone()
	return BumpFormulaResource{
		name: bump_formula_map_string(values, 'name', value.repr)
		version: bump_formula_map_string(values, 'version', '')
		url: bump_formula_map_string(values, 'url', '')
		mirrors: (values['mirrors'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		checksum: bump_formula_map_string(values, 'checksum', '')
		owner_name: bump_formula_map_string(values, 'owner_name', '')
		livecheck_parent: bump_formula_map_bool(values, 'livecheck_parent', false)
		fetch_path: bump_formula_map_string(values, 'fetch_path', '')
		fetched_version: bump_formula_map_string(values, 'fetched_version', '')
		fetched_sha256: bump_formula_map_string(values, 'fetched_sha256', '')
		fetch_error: bump_formula_map_string(values, 'fetch_error', '')
	}
}

pub fn bump_formula_value(formula BumpFormula) ruby.Value {
	mut resources := []ruby.Value{}
	for resource in formula.resources {
		resources << bump_formula_resource_value(resource)
	}
	mut values := {
		'name':                  ruby.string_value(formula.name)
		'full_name':             ruby.string_value(formula.full_name)
		'path':                  ruby.string_value(formula.path)
		'contents':              ruby.string_value(formula.contents)
		'version':               ruby.string_value(formula.version)
		'url':                   ruby.string_value(formula.url)
		'tag':                   ruby.string_value(formula.tag)
		'revision':              ruby.string_value(formula.revision)
		'checksum':              ruby.string_value(formula.checksum)
		'mirrors':               ruby.string_array_value(formula.mirrors)
		'aliases':               ruby.string_array_value(formula.aliases)
		'resources':             ruby.array_value(resources)
		'tap_present':           ruby.bool_value(formula.tap_present)
		'tap_git':               ruby.bool_value(formula.tap_git)
		'tap_name':              ruby.string_value(formula.tap_name)
		'tap_path':              ruby.string_value(formula.tap_path)
		'tap_remote_repository': ruby.string_value(formula.tap_remote_repository)
		'tap_official':          ruby.bool_value(formula.tap_official)
		'allow_bump':            ruby.bool_value(formula.allow_bump)
		'disabled':              ruby.bool_value(formula.disabled)
		'does_not_build':        ruby.bool_value(formula.does_not_build)
		'too_many_open_prs':     ruby.bool_value(formula.too_many_open_prs)
		'throttle_allows_bump':  ruby.bool_value(formula.throttle_allows_bump)
		'download_path':         ruby.string_value(formula.download_path)
		'download_sha256':       ruby.string_value(formula.download_sha256)
		'fetched_version':       ruby.string_value(formula.fetched_version)
		'fetched_revision':      ruby.string_value(formula.fetched_revision)
	}
	if rate := formula.throttle_rate {
		values['throttle_rate'] = ruby.int_value(rate)
	}
	if days := formula.throttle_days {
		values['throttle_days'] = ruby.int_value(days)
	}
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.name
		map_data: values
	}
}

fn bump_formula_from_value(value ruby.Value) !BumpFormula {
	if value.type_name !in ['Formula', 'Hash'] {
		return error('expected Formula, got ${value.type_name}')
	}
	values := value.map_data.clone()
	mut resources := []BumpFormulaResource{}
	for entry in (values['resources'] or { ruby.array_value([]) }).as_array() or { [] } {
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
		mirrors: (values['mirrors'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		aliases: (values['aliases'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
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

fn bump_formula_options_from_value(value ruby.Value) BumpFormulaOptions {
	values := value.map_data.clone()
	return BumpFormulaOptions{
		version: bump_formula_map_string(values, 'version', '')
		url: bump_formula_map_string(values, 'url', '')
		sha256: bump_formula_map_string(values, 'sha256', '')
		tag: bump_formula_map_string(values, 'tag', '')
		revision: bump_formula_map_string(values, 'revision', '')
		mirrors: (values['mirrors'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
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
	parsed := ruby.parse_json_value(contents)!
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
	utils.ast_formula_replace_resource_value(mut ast, resource.name, 'url', ruby.string_value(new_url), ruby.string_value(resource.url))
	for index, old_mirror in resource.mirrors {
		new_mirror := bump_formula_update_url(old_mirror, resource.version, new_version)
		utils.ast_formula_replace_resource_value(mut ast, resource.name, 'mirror', ruby.string_value(new_mirror), ruby.string_value(old_mirror))
	}
	if resource.checksum != '' {
		utils.ast_formula_replace_resource_value(mut ast, resource.name, 'sha256', ruby.string_value(fetched.sha256), ruby.string_value(resource.checksum))
	}
	if fetched.forced_version {
		if utils.ast_formula_resource_stanza_exists(ast, resource.name, 'version') {
			utils.ast_formula_replace_resource_value(mut ast, resource.name, 'version', ruby.string_value(new_version), none)
		} else {
			parent := utils.ast_formula_resource(ast, resource.name)
			utils.ast_formula_add_stanzas_after(mut ast, 'sha256', [utils.AstStanzaPair{
				name: 'version'
				value: ruby.string_value(new_version)
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
		utils.ast_formula_replace_stable_value(mut ast, 'url', ruby.string_value(new_url))
		utils.ast_formula_replace_stable_value(mut ast, 'sha256', ruby.string_value(new_hash))
	} else if new_tag != '' {
		utils.ast_formula_replace_stable_hash(mut ast, 'url', 'tag', ruby.string_value(new_tag))
		utils.ast_formula_replace_stable_hash(mut ast, 'url', 'revision', ruby.string_value(new_revision))
	} else if new_url != '' {
		utils.ast_formula_replace_stable_value(mut ast, 'url', ruby.string_value(new_url))
		utils.ast_formula_replace_stable_hash(mut ast, 'url', 'revision', ruby.string_value(new_revision))
	} else {
		utils.ast_formula_replace_stable_hash(mut ast, 'url', 'revision', ruby.string_value(new_revision))
	}
	mut additions := []utils.AstStanzaPair{}
	for mirror in new_mirrors {
		additions << utils.AstStanzaPair{
			name: 'mirror'
			value: ruby.string_value(mirror)
		}
	}
	if forced_version && options.version != '0' {
		if bump_formula_stable_has(ast, 'version') {
			utils.ast_formula_replace_stable_value(mut ast, 'version', ruby.string_value(options.version))
		} else {
			additions << utils.AstStanzaPair{
				name: 'version'
				value: ruby.string_value(options.version)
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

fn bump_formula_check_value(result BumpFormulaCheckResult) ruby.Value {
	return ruby.map_value({
		'allowed': ruby.bool_value(result.allowed)
		'error':   ruby.string_value(result.error)
		'output':  ruby.string_array_value(result.output)
	})
}

fn bump_formula_fetch_value(result BumpFormulaFetchResult) ruby.Value {
	return ruby.map_value({
		'path':           ruby.string_value(result.path)
		'version':        ruby.string_value(result.version)
		'sha256':         ruby.string_value(result.sha256)
		'forced_version': ruby.bool_value(result.forced_version)
	})
}

fn bump_formula_pull_request_value(check BumpFormulaPullRequestCheck) ruby.Value {
	return ruby.Value{
		type_name: 'GitHub::PullRequestCheck'
		repr: '${check.formula} ${check.version}'.trim_space()
		map_data: {
			'formula':      ruby.string_value(check.formula)
			'remote':       ruby.string_value(check.remote)
			'version':      ruby.string_value(check.version)
			'state':        ruby.string_value(check.state)
			'file':         ruby.string_value(check.file)
			'quiet':        ruby.bool_value(check.quiet)
			'official_tap': ruby.bool_value(check.official_tap)
		}
	}
}

fn bump_formula_updates_value(updates BumpFormulaResourceUpdates) ruby.Value {
	return ruby.map_value({
		'contents': ruby.string_value(updates.contents)
		'statuses': bump_formula_string_map_value(updates.statuses)
		'warnings': ruby.string_array_value(updates.warnings)
	})
}

fn bump_formula_resource_versions_from_value(value ruby.Value) !map[string]BumpFormulaResourceVersion {
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

fn bump_formula_resource_versions_value(versions map[string]BumpFormulaResourceVersion) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, version in versions {
		values[name] = ruby.map_value({
			'current_version': ruby.string_value(version.current_version)
			'latest_version':  ruby.string_value(version.latest_version)
		})
	}
	return ruby.map_value(values)
}

fn bump_formula_audit_value(result BumpFormulaAuditResult) ruby.Value {
	return ruby.map_value({
		'failed':  ruby.bool_value(result.failed)
		'command': ruby.string_array_value(result.command)
		'output':  ruby.string_array_value(result.output)
		'moved':   ruby.bool_value(result.moved)
		'error':   ruby.string_value(result.error)
	})
}

fn bump_formula_run_result_value(result BumpFormulaRunResult) ruby.Value {
	mut values := {
		'contents':          ruby.string_value(result.contents)
		'version':           ruby.string_value(result.version)
		'branch_name':       ruby.string_value(result.branch_name)
		'commit_message':    ruby.string_value(result.commit_message)
		'additional_files':  ruby.string_array_value(result.additional_files)
		'resource_statuses': bump_formula_string_map_value(result.resource_statuses)
		'audit':             bump_formula_audit_value(result.audit)
		'pull_request':      ruby.string_value(result.pull_request)
		'browser_url':       ruby.string_value(result.browser_url)
		'printed_url':       ruby.string_value(result.printed_url)
		'output':            ruby.string_array_value(result.output)
		'error':             ruby.string_value(result.error)
	}
	if check := result.pull_request_check {
		values['pull_request_check'] = bump_formula_pull_request_value(check)
	} else {
		values['pull_request_check'] = bump_formula_nil()
	}
	return ruby.Value{
		type_name: 'Homebrew::DevCmd::BumpFormulaPr::Result'
		repr: result.commit_message
		map_data: values
	}
}
