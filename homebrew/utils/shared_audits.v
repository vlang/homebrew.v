module utils

import brew_runtime
import net.http
import os
import time

// Translated from Homebrew/brew `utils/shared_audits.rb`.
// The original source is retained below for exact source traceability.
pub const shared_audits_url_type_homepage = 'homepage URL'
pub const shared_audits_self_submission_threshold_multiplier = 3

pub const shared_audits_github_notability_thresholds = {
	'forks':    30
	'watchers': 30
	'stars':    75
}
pub const shared_audits_gitlab_notability_thresholds = {
	'forks': 30
	'stars': 75
}
pub const shared_audits_bitbucket_notability_thresholds = {
	'forks':    30
	'watchers': 75
}
pub const shared_audits_forgejo_notability_thresholds = {
	'forks':    30
	'watchers': 30
	'stars':    75
}

pub struct SharedAuditsHttpResult {
pub:
	stdout  string
	success bool
}

pub type SharedAuditsFetcher = fn([]string) !SharedAuditsHttpResult

pub struct SharedAuditsConfig {
pub:
	fetcher           SharedAuditsFetcher = shared_audits_default_fetch
	today             string
	now_iso           string
	github_event_path string
}

pub enum SharedAuditsPackageKind {
	formula
	cask
}

pub struct SharedAuditsPackage {
pub:
	kind       SharedAuditsPackageKind
	name       string
	version    string
	exceptions map[string]string
}

pub enum SharedAuditsDeprecateDisableKind {
	formula
	cask
}

pub struct SharedAuditsDeprecateDisableSubject {
pub:
	kind                         SharedAuditsDeprecateDisableKind
	deprecated                   bool
	disabled                     bool
	deprecation_reason           string
	deprecation_reason_is_symbol bool
	disable_reason               string
	disable_reason_is_symbol     bool
}

@[heap]
pub struct SharedAuditsState {
pub:
	fetcher           SharedAuditsFetcher = shared_audits_default_fetch
	today             string
	now_iso           string
	github_event_path string
pub mut:
	pull_request_author_computed bool
	pull_request_author_value    string
	has_pull_request_author      bool
	self_submission_cache        map[string]bool
	eol_data_cache               map[string]brew_runtime.Value
	github_repo_data_cache       map[string]brew_runtime.Value
	github_release_data_cache    map[string]brew_runtime.Value
	gitlab_repo_data_cache       map[string]brew_runtime.Value
	gitlab_release_data_cache    map[string]brew_runtime.Value
	forgejo_repo_data_cache      map[string]brew_runtime.Value
	forgejo_release_data_cache   map[string]brew_runtime.Value
}

fn shared_audits_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn shared_audits_default_fetch(arguments []string) !SharedAuditsHttpResult {
	mut url := ''
	for argument in arguments {
		if argument.starts_with('https://') || argument.starts_with('http://') {
			url = argument
		}
	}
	if url == '' {
		return error('SharedAudits request has no URL')
	}
	response := http.get(url)!
	success := if '--fail' in arguments {
		response.status_code >= 200 && response.status_code < 300
	} else {
		true
	}
	return SharedAuditsHttpResult{
		stdout: response.body
		success: success
	}
}

pub fn new_shared_audits_state(config SharedAuditsConfig) &SharedAuditsState {
	now := time.now()
	return &SharedAuditsState{
		fetcher: config.fetcher
		today: if config.today == '' {
			'${now.year:04d}-${now.month:02d}-${now.day:02d}'
		} else {
			config.today
		}
		now_iso: if config.now_iso == '' { now.format_rfc3339() } else { config.now_iso }
		github_event_path: if config.github_event_path == '' {
			os.getenv('GITHUB_EVENT_PATH')
		} else {
			config.github_event_path
		}
		self_submission_cache: map[string]bool{}
		eol_data_cache: map[string]brew_runtime.Value{}
		github_repo_data_cache: map[string]brew_runtime.Value{}
		github_release_data_cache: map[string]brew_runtime.Value{}
		gitlab_repo_data_cache: map[string]brew_runtime.Value{}
		gitlab_release_data_cache: map[string]brew_runtime.Value{}
		forgejo_repo_data_cache: map[string]brew_runtime.Value{}
		forgejo_release_data_cache: map[string]brew_runtime.Value{}
	}
}

fn shared_audits_date_parts(value string) ?[]int {
	if value.len < 10 {
		return none
	}
	date := value[..10]
	parts := date.split('-')
	if parts.len != 3 || parts[0].len != 4 || parts[1].len != 2 || parts[2].len != 2 {
		return none
	}
	parsed := time.parse_iso8601('${date}T00:00:00Z') or { return none }
	return [parsed.year, parsed.month, parsed.day]
}

fn shared_audits_days_in_month(year int, month int) int {
	return match month {
		2 {
			if year % 400 == 0 || (year % 4 == 0 && year % 100 != 0) { 29 } else { 28 }
		}
		4, 6, 9, 11 { 30 }
		else { 31 }
	}
}

pub fn shared_audits_homepage_browsed_recently(browsed ?string, today string) bool {
	browsed_value := browsed or { return false }
	parts := shared_audits_date_parts(browsed_value) or { return false }
	today_parts := shared_audits_date_parts(today) or { return false }
	browsed_date := '${parts[0]:04d}-${parts[1]:02d}-${parts[2]:02d}'
	today_date := '${today_parts[0]:04d}-${today_parts[1]:02d}-${today_parts[2]:02d}'
	next_year := parts[0] + 1
	next_day := if parts[2] > shared_audits_days_in_month(next_year, parts[1]) {
		shared_audits_days_in_month(next_year, parts[1])
	} else {
		parts[2]
	}
	next_year_date := '${next_year:04d}-${parts[1]:02d}-${next_day:02d}'
	return browsed_date <= today_date && next_year_date > today_date
}

pub fn (mut state SharedAuditsState) pull_request_author() ?string {
	if state.pull_request_author_computed {
		return if state.has_pull_request_author { state.pull_request_author_value } else { none }
	}
	state.pull_request_author_computed = true
	if state.github_event_path.trim_space() == '' {
		return none
	}
	contents := os.read_file(state.github_event_path) or { return none }
	parsed := brew_runtime.parse_json_value(contents) or { return none }
	pull_request := parsed.map_data['pull_request'] or { return none }
	user := pull_request.map_data['user'] or { return none }
	login := user.map_data['login'] or { return none }
	if login.type_name != 'String' || login.as_string().trim_space() == '' {
		return none
	}
	state.pull_request_author_value = login.as_string()
	state.has_pull_request_author = true
	return state.pull_request_author_value
}

pub fn shared_audits_self_submission(submitter ?string, repo_owner string) bool {
	value := submitter or { return false }
	if value.trim_space() == '' || repo_owner == '' {
		return false
	}
	return value.to_lower() == repo_owner.to_lower()
}

pub fn (mut state SharedAuditsState) self_submission_for_repo_owner(repo_owner string) bool {
	if repo_owner.trim_space() == '' {
		return false
	}
	submitter := state.pull_request_author() or { return false }
	key := repo_owner.to_lower()
	if key in state.self_submission_cache {
		return state.self_submission_cache[key]
	}
	result := shared_audits_self_submission(submitter, repo_owner)
	state.self_submission_cache[key] = result
	return result
}

pub fn shared_audits_notability_thresholds_for(thresholds map[string]int,
	self_submission bool) map[string]int {
	if !self_submission {
		return thresholds.clone()
	}
	mut adjusted := map[string]int{}
	for key, value in thresholds {
		adjusted[key] = value * shared_audits_self_submission_threshold_multiplier
	}
	return adjusted
}

fn (state &SharedAuditsState) fetch_json(arguments []string) ?brew_runtime.Value {
	result := state.fetcher(arguments) or { return none }
	if !result.success {
		return none
	}
	return brew_runtime.parse_json_value(result.stdout) or { none }
}

pub fn (mut state SharedAuditsState) eol_data(product string, cycle string) brew_runtime.Value {
	key := '${product}/${cycle}'
	if key in state.eol_data_cache {
		return state.eol_data_cache[key]
	}
	data := state.fetch_json([
		'--location',
		'https://endoflife.date/api/v1/products/${product}/releases/${cycle}',
	]) or { shared_audits_nil() }
	state.eol_data_cache[key] = data
	return data
}

fn shared_audits_present(value brew_runtime.Value) bool {
	return value.type_name != 'NilClass'
}

fn shared_audits_truthy(value brew_runtime.Value) bool {
	if value.type_name == 'NilClass' {
		return false
	}
	if value.type_name == 'Bool' {
		return value.bool_data
	}
	return true
}

fn shared_audits_string(metadata brew_runtime.Value, key string) string {
	return (metadata.map_data[key] or { return '' }).as_string()
}

fn shared_audits_int(metadata brew_runtime.Value, key string) int {
	value := metadata.map_data[key] or { return 0 }
	return if value.type_name == 'Integer' { int(value.int_data) } else { value.as_string().int() }
}

fn shared_audits_bool(metadata brew_runtime.Value, key string) bool {
	value := metadata.map_data[key] or { return false }
	return shared_audits_truthy(value)
}

fn (mut state SharedAuditsState) cached_json(mut cache map[string]brew_runtime.Value,
	key string, arguments []string) brew_runtime.Value {
	if key in cache {
		return cache[key]
	}
	data := state.fetch_json(arguments) or { return shared_audits_nil() }
	if shared_audits_present(data) {
		cache[key] = data
	}
	return data
}

pub fn (mut state SharedAuditsState) github_repo_data(user string, repo string) brew_runtime.Value {
	key := '${user}/${repo}'
	return state.cached_json(mut state.github_repo_data_cache, key, [
		'https://api.github.com/repos/${user}/${repo}',
	])
}

pub fn (mut state SharedAuditsState) github_release_data(user string, repo string,
	tag string) brew_runtime.Value {
	id := '${user}/${repo}/${tag}'
	return state.cached_json(mut state.github_release_data_cache, id, [
		'https://api.github.com/repos/${user}/${repo}/releases/tags/${tag}',
	])
}

fn shared_audits_package_exception(subject ?SharedAuditsPackage, key string) (string, string, string, bool) {
	package := subject or { return '', '', '', false }
	if key in package.exceptions {
		return package.exceptions[key], package.name, package.version, true
	}
	return '', package.name, package.version, false
}

pub fn (mut state SharedAuditsState) github_release(user string, repo string, tag string,
	subject ?SharedAuditsPackage) ?string {
	release := state.github_release_data(user, repo, tag)
	if !shared_audits_present(release) {
		return none
	}
	exception, name, version, has_exception := shared_audits_package_exception(subject, 'github_prerelease_allowlist')
	if shared_audits_bool(release, 'prerelease') && exception !in [version, 'all', 'any'] {
		return '${tag} is a GitHub pre-release.'
	}
	if !shared_audits_bool(release, 'prerelease') && has_exception && exception !in [
		version,
		'any',
	] {
		return "${tag} is not a GitHub pre-release but '${name}' is in the GitHub prerelease allowlist."
	}
	if shared_audits_bool(release, 'draft') {
		return '${tag} is a GitHub draft.'
	}
	return none
}

pub fn (mut state SharedAuditsState) gitlab_repo_data(user string, repo string) brew_runtime.Value {
	key := '${user}/${repo}'
	if key in state.gitlab_repo_data_cache {
		return state.gitlab_repo_data_cache[key]
	}
	data := state.fetch_json([
		'https://gitlab.com/api/v4/projects/${user}%2F${repo}',
	]) or { return shared_audits_nil() }
	if shared_audits_string(data, 'message').contains('404 Project Not Found') {
		return shared_audits_nil()
	}
	state.gitlab_repo_data_cache[key] = data
	return data
}

pub fn (mut state SharedAuditsState) forgejo_repo_data(user string, repo string) brew_runtime.Value {
	key := '${user}/${repo}'
	return state.cached_json(mut state.forgejo_repo_data_cache, key, [
		'https://codeberg.org/api/v1/repos/${user}/${repo}',
		'--fail',
	])
}

pub fn (mut state SharedAuditsState) gitlab_release_data(user string, repo string,
	tag string) brew_runtime.Value {
	id := '${user}/${repo}/${tag}'
	return state.cached_json(mut state.gitlab_release_data_cache, id, [
		'https://gitlab.com/api/v4/projects/${user}%2F${repo}/releases/${tag}',
		'--fail',
	])
}

fn shared_audits_parse_time(value string) ?time.Time {
	if value.len == 10 {
		return time.parse_iso8601('${value}T00:00:00Z') or { none }
	}
	return time.parse_iso8601(value) or { none }
}

pub fn (mut state SharedAuditsState) gitlab_release(user string, repo string, tag string,
	subject ?SharedAuditsPackage) ?string {
	release := state.gitlab_release_data(user, repo, tag)
	if !shared_audits_present(release) {
		return none
	}
	released_at := shared_audits_parse_time(shared_audits_string(release, 'released_at')) or {
		return none
	}
	now := shared_audits_parse_time(state.now_iso) or { return none }
	if released_at.unix() <= now.unix() {
		return none
	}
	exception, _, version, _ := shared_audits_package_exception(subject, 'gitlab_prerelease_allowlist')
	if exception in [version, 'all'] {
		return none
	}
	return '${tag} is a GitLab pre-release.'
}

pub fn (mut state SharedAuditsState) forgejo_release_data(user string, repo string,
	tag string) brew_runtime.Value {
	id := '${user}/${repo}/${tag}'
	return state.cached_json(mut state.forgejo_release_data_cache, id, [
		'https://codeberg.org/api/v1/repos/${user}/${repo}/releases/tags/${tag}',
		'--fail',
	])
}

pub fn (mut state SharedAuditsState) forgejo_release(user string, repo string, tag string,
	subject ?SharedAuditsPackage) ?string {
	release := state.forgejo_release_data(user, repo, tag)
	if !shared_audits_present(release) || !shared_audits_bool(release, 'prerelease') {
		return none
	}
	exception, _, version, _ := shared_audits_package_exception(subject, 'forgejo_prerelease_allowlist')
	if exception in [version, 'all'] {
		return none
	}
	return '${tag} is a Forgejo pre-release.'
}

fn shared_audits_age_days(created_at string, today string) ?int {
	created := shared_audits_parse_time(created_at) or { return none }
	today_time := shared_audits_parse_time(today) or { return none }
	return int((today_time.unix() - created.unix()) / 86_400)
}

pub fn (mut state SharedAuditsState) github(user string, repo string,
	self_submission bool) ?string {
	metadata := state.github_repo_data(user, repo)
	if !shared_audits_present(metadata) {
		return none
	}
	if shared_audits_bool(metadata, 'fork') {
		return 'GitHub fork (not canonical repository)'
	}
	thresholds := shared_audits_notability_thresholds_for(shared_audits_github_notability_thresholds, self_submission)
	prefix := if self_submission {
		'Self-submitted GitHub repository not notable enough'
	} else {
		'GitHub repository not notable enough'
	}
	if shared_audits_int(metadata, 'forks_count') < thresholds['forks'] && shared_audits_int(metadata, 'subscribers_count') < thresholds['watchers'] && shared_audits_int(metadata, 'stargazers_count') < thresholds['stars'] {
		return '${prefix} (<${thresholds['forks']} forks, <${thresholds['watchers']} watchers and <${thresholds['stars']} stars)'
	}
	age_days := shared_audits_age_days(shared_audits_string(metadata, 'created_at'), state.today) or {
		return none
	}
	if age_days >= 30 {
		return none
	}
	return 'GitHub repository too new (${age_days} days old, 30 days required)'
}

pub fn (mut state SharedAuditsState) gitlab(user string, repo string,
	self_submission bool) ?string {
	metadata := state.gitlab_repo_data(user, repo)
	if !shared_audits_present(metadata) {
		return none
	}
	if shared_audits_bool(metadata, 'fork') {
		return 'GitLab fork (not canonical repository)'
	}
	thresholds := shared_audits_notability_thresholds_for(shared_audits_gitlab_notability_thresholds, self_submission)
	prefix := if self_submission {
		'Self-submitted GitLab repository not notable enough'
	} else {
		'GitLab repository not notable enough'
	}
	if shared_audits_int(metadata, 'forks_count') < thresholds['forks'] && shared_audits_int(metadata, 'star_count') < thresholds['stars'] {
		return '${prefix} (<${thresholds['forks']} forks and <${thresholds['stars']} stars)'
	}
	age_days := shared_audits_age_days(shared_audits_string(metadata, 'created_at'), state.today) or {
		return none
	}
	if age_days >= 30 {
		return none
	}
	return 'GitLab repository too new (${age_days} days old, 30 days required)'
}

pub fn (mut state SharedAuditsState) bitbucket(user string, repo string,
	self_submission bool) ?string {
	api_url := 'https://api.bitbucket.org/2.0/repositories/${user}/${repo}'
	metadata := state.fetch_json(['--request', 'GET', api_url]) or { return none }
	if shared_audits_string(metadata, 'scm') == 'hg' {
		return 'Uses deprecated Mercurial support in Bitbucket'
	}
	parent := metadata.map_data['parent'] or { shared_audits_nil() }
	if shared_audits_present(parent) {
		return 'Bitbucket fork (not canonical repository)'
	}
	age_days := shared_audits_age_days(shared_audits_string(metadata, 'created_on'), state.today) or {
		return none
	}
	if age_days < 30 {
		return 'Bitbucket repository too new (${age_days} days old, 30 days required)'
	}
	forks := state.fetch_json(['--request', 'GET', '${api_url}/forks']) or { return none }
	watchers := state.fetch_json(['--request', 'GET', '${api_url}/watchers']) or { return none }
	thresholds := shared_audits_notability_thresholds_for(shared_audits_bitbucket_notability_thresholds, self_submission)
	if shared_audits_int(forks, 'size') >= thresholds['forks'] || shared_audits_int(watchers, 'size') >= thresholds['watchers'] {
		return none
	}
	prefix := if self_submission {
		'Self-submitted Bitbucket repository not notable enough'
	} else {
		'Bitbucket repository not notable enough'
	}
	return '${prefix} (<${thresholds['forks']} forks and <${thresholds['watchers']} watchers)'
}

pub fn (mut state SharedAuditsState) forgejo(user string, repo string,
	self_submission bool) ?string {
	metadata := state.forgejo_repo_data(user, repo)
	if !shared_audits_present(metadata) {
		return none
	}
	if shared_audits_bool(metadata, 'fork') {
		return 'Forgejo fork (not canonical repository)'
	}
	thresholds := shared_audits_notability_thresholds_for(shared_audits_forgejo_notability_thresholds, self_submission)
	prefix := if self_submission {
		'Self-submitted Forgejo repository not notable enough'
	} else {
		'Forgejo repository not notable enough'
	}
	if shared_audits_int(metadata, 'forks_count') < thresholds['forks'] && shared_audits_int(metadata, 'watchers_count') < thresholds['watchers'] && shared_audits_int(metadata, 'stars_count') < thresholds['stars'] {
		return '${prefix} (<${thresholds['forks']} forks, <${thresholds['watchers']} watchers and <${thresholds['stars']} stars)'
	}
	age_days := shared_audits_age_days(shared_audits_string(metadata, 'created_at'), state.today) or {
		return none
	}
	if age_days >= 30 {
		return none
	}
	return 'Forgejo repository too new (${age_days} days old, 30 days required)'
}

fn shared_audits_word_character(character u8) bool {
	return (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character == `_`
}

fn shared_audits_valid_path_component(value string, allow_dot bool) bool {
	if value == '' {
		return false
	}
	for character in value.bytes() {
		if !shared_audits_word_character(character) && character != `-` && !(allow_dot && character == `.`) {
			return false
		}
	}
	return true
}

fn shared_audits_repository_url_parts(url string, host string) ?(string, string, string) {
	prefix := 'https://${host}/'
	if !url.starts_with(prefix) {
		return none
	}
	rest := url[prefix.len..]
	owner_end := rest.index('/') or { return none }
	owner := rest[..owner_end]
	after_owner := rest[owner_end + 1..]
	repo_end := after_owner.index('/') or { return none }
	repo := after_owner[..repo_end]
	tail := after_owner[repo_end..]
	if !shared_audits_valid_path_component(owner, false) || !shared_audits_valid_path_component(repo, true) {
		return none
	}
	return owner, repo, tail
}

fn shared_audits_archive_tag(value string) ?string {
	if value.ends_with('.tar.gz') {
		tag := value[..value.len - '.tar.gz'.len]
		return if tag == '' { none } else { tag }
	}
	if value.ends_with('.zip') {
		tag := value[..value.len - '.zip'.len]
		return if tag == '' { none } else { tag }
	}
	return none
}

pub fn shared_audits_github_tag_from_url(url string) ?string {
	_, _, tail := shared_audits_repository_url_parts(url, 'github.com') or { return none }
	archive_prefix := '/archive/refs/tags/'
	if tail.starts_with(archive_prefix) {
		return shared_audits_archive_tag(tail[archive_prefix.len..])
	}
	release_prefix := '/releases/download/'
	if tail.starts_with(release_prefix) {
		remainder := tail[release_prefix.len..]
		end := remainder.index('/') or { return none }
		return if end == 0 { none } else { remainder[..end] }
	}
	return none
}

pub fn shared_audits_gitlab_tag_from_url(url string) ?string {
	prefix := 'https://gitlab.com/'
	if !url.starts_with(prefix) {
		return none
	}
	rest := url[prefix.len..]
	marker := '/-/archive/'
	marker_start := rest.index(marker) or { return none }
	components := rest[..marker_start].split('/')
	if components.len < 2 {
		return none
	}
	for component in components {
		if component == '' || !shared_audits_word_character(component[0]) || !shared_audits_valid_path_component(component, true) {
			return none
		}
	}
	remainder := rest[marker_start + marker.len..]
	end := remainder.index('/') or { return none }
	return if end == 0 { none } else { remainder[..end] }
}

pub fn shared_audits_forgejo_tag_from_url(url string) ?string {
	_, _, tail := shared_audits_repository_url_parts(url, 'codeberg.org') or { return none }
	archive_prefix := '/archive/'
	if !tail.starts_with(archive_prefix) {
		return none
	}
	return shared_audits_archive_tag(tail[archive_prefix.len..])
}

pub fn shared_audits_check_deprecate_disable_reason(subject SharedAuditsDeprecateDisableSubject) ?string {
	if !subject.deprecated && !subject.disabled {
		return none
	}
	reason := if subject.deprecated { subject.deprecation_reason } else { subject.disable_reason }
	is_symbol := if subject.deprecated {
		subject.deprecation_reason_is_symbol
	} else {
		subject.disable_reason_is_symbol
	}
	if !is_symbol {
		return none
	}
	reasons := match subject.kind {
		.formula {
			['does_not_build', 'no_license', 'repo_archived', 'repo_removed', 'unmaintained',
				'unreachable', 'unsupported', 'deprecated_upstream', 'versioned_formula',
				'checksum_mismatch']
		}
		.cask {
			['discontinued', 'moved_to_mas', 'no_longer_available', 'no_longer_meets_criteria',
				'unmaintained', 'fails_gatekeeper_check', 'unreachable']
		}
	}
	if reason !in reasons {
		return '${reason} is not a valid deprecate! or disable! reason'
	}
	return none
}

pub fn shared_audits_state_boundary(state &SharedAuditsState) brew_runtime.Value {
	return brew_runtime.structured_value('SharedAudits::State', '', {
		'shared_audits_state_address': u64(voidptr(state)).str()
	})
}

fn shared_audits_state_and_offset(args []brew_runtime.Value) (&SharedAuditsState, int) {
	if args.len > 0 && 'shared_audits_state_address' in args[0].attributes {
		return unsafe { &SharedAuditsState(voidptr(args[0].attributes['shared_audits_state_address'].u64())) }, 1
	}
	return new_shared_audits_state(SharedAuditsConfig{}), 0
}

pub fn shared_audits_package_value(package SharedAuditsPackage) brew_runtime.Value {
	mut exceptions := map[string]brew_runtime.Value{}
	for key, value in package.exceptions {
		exceptions[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.Value{
		type_name: 'SharedAudits::Package'
		repr: package.name
		map_data: exceptions
		attributes: {
			'kind':    package.kind.str()
			'name':    package.name
			'version': package.version
		}
	}
}

fn shared_audits_package_from_value(value brew_runtime.Value) ?SharedAuditsPackage {
	if value.type_name == 'NilClass' {
		return none
	}
	mut exceptions := map[string]string{}
	for key, item in value.map_data {
		exceptions[key] = item.as_string()
	}
	return SharedAuditsPackage{
		kind: if (value.attributes['kind'] or { 'formula' }) == 'cask' { .cask } else { .formula }
		name: value.attributes['name'] or { value.as_string() }
		version: value.attributes['version'] or { '' }
		exceptions: exceptions
	}
}

pub fn shared_audits_deprecate_disable_subject_value(subject SharedAuditsDeprecateDisableSubject) brew_runtime.Value {
	return brew_runtime.structured_value('SharedAudits::DeprecateDisableSubject', '', {
		'kind':                         subject.kind.str()
		'deprecated':                   subject.deprecated.str()
		'disabled':                     subject.disabled.str()
		'deprecation_reason':           subject.deprecation_reason
		'deprecation_reason_is_symbol': subject.deprecation_reason_is_symbol.str()
		'disable_reason':               subject.disable_reason
		'disable_reason_is_symbol':     subject.disable_reason_is_symbol.str()
	})
}

fn shared_audits_deprecate_disable_subject_from_value(value brew_runtime.Value) SharedAuditsDeprecateDisableSubject {
	return SharedAuditsDeprecateDisableSubject{
		kind: if (value.attributes['kind'] or { 'formula' }) == 'cask' { .cask } else { .formula }
		deprecated: (value.attributes['deprecated'] or { 'false' }) == 'true'
		disabled: (value.attributes['disabled'] or { 'false' }) == 'true'
		deprecation_reason: value.attributes['deprecation_reason'] or { '' }
		deprecation_reason_is_symbol: (value.attributes['deprecation_reason_is_symbol'] or {
			'false'
		}) == 'true'
		disable_reason: value.attributes['disable_reason'] or { '' }
		disable_reason_is_symbol: (value.attributes['disable_reason_is_symbol'] or { 'false' }) == 'true'
	}
}

fn shared_audits_optional_string(value brew_runtime.Value) ?string {
	return if value.type_name == 'NilClass' { none } else { value.as_string() }
}

fn shared_audits_optional_value(value ?string) brew_runtime.Value {
	return brew_runtime.string_value(value or { return shared_audits_nil() })
}

// Ruby method `self.homepage_browsed_recently?(browsed)` at line 20.
pub fn ruby_shared_audits_l20_d1_self_homepage_browsed_recently(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	browsed := if args.len > offset { shared_audits_optional_string(args[offset]) } else { none }
	return brew_runtime.bool_value(shared_audits_homepage_browsed_recently(browsed, state.today))
}

// Ruby method `self.pull_request_author` at line 28.
pub fn ruby_shared_audits_l28_d2_self_pull_request_author(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, _ := shared_audits_state_and_offset(args)
	return shared_audits_optional_value(state.pull_request_author())
}

// Ruby method `self.self_submission?(submitter, repo_owner)` at line 41.
pub fn ruby_shared_audits_l41_d3_self_self_submission(args ...brew_runtime.Value) brew_runtime.Value {
	_, offset := shared_audits_state_and_offset(args)
	submitter := if args.len > offset { shared_audits_optional_string(args[offset]) } else { none }
	repo_owner := if args.len > offset + 1 { args[offset + 1].as_string() } else { '' }
	return brew_runtime.bool_value(shared_audits_self_submission(submitter, repo_owner))
}

// Ruby method `self.self_submission_for_repo_owner?(repo_owner)` at line 49.
pub fn ruby_shared_audits_l49_d4_self_self_submission_for_repo_owner(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	repo_owner := if args.len > offset { args[offset].as_string() } else { '' }
	return brew_runtime.bool_value(state.self_submission_for_repo_owner(repo_owner))
}

// Ruby method `self.notability_thresholds_for(thresholds, self_submission)` at line 62.
pub fn ruby_shared_audits_l62_d5_self_notability_thresholds_for(args ...brew_runtime.Value) brew_runtime.Value {
	_, offset := shared_audits_state_and_offset(args)
	mut thresholds := map[string]int{}
	if args.len > offset {
		for key, value in args[offset].map_data {
			thresholds[key] = int(value.int_data)
		}
	}
	self_submission := args.len > offset + 1 && args[offset + 1].bool_data
	adjusted := shared_audits_notability_thresholds_for(thresholds, self_submission)
	mut values := map[string]brew_runtime.Value{}
	for key, value in adjusted {
		values[key] = brew_runtime.int_value(value)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `self.eol_data(product, cycle)` at line 69.
pub fn ruby_shared_audits_l69_d6_self_eol_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	product := if args.len > offset { args[offset].as_string() } else { '' }
	cycle := if args.len > offset + 1 { args[offset + 1].as_string() } else { '' }
	return state.eol_data(product, cycle)
}

// Ruby method `self.github_repo_data(user, repo)` at line 88.
pub fn ruby_shared_audits_l88_d7_self_github_repo_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	return state.github_repo_data(args[offset].as_string(), args[offset + 1].as_string())
}

// Ruby method `self.github_release_data(user, repo, tag)` at line 100.
pub fn ruby_shared_audits_l100_d8_self_github_release_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	return state.github_release_data(args[offset].as_string(), args[offset + 1].as_string(), args[offset + 2].as_string())
}

// Ruby method `self.github_release(user, repo, tag, formula: nil, cask: nil)` at line 120.
pub fn ruby_shared_audits_l120_d9_self_github_release(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	subject := if args.len > offset + 3 {
		shared_audits_package_from_value(args[offset + 3])
	} else {
		none
	}
	return shared_audits_optional_value(state.github_release(args[offset].as_string(), args[offset + 1].as_string(), args[offset + 2].as_string(), subject))
}

// Ruby method `self.gitlab_repo_data(user, repo)` at line 140.
pub fn ruby_shared_audits_l140_d10_self_gitlab_repo_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	return state.gitlab_repo_data(args[offset].as_string(), args[offset + 1].as_string())
}

// Ruby method `self.forgejo_repo_data(user, repo)` at line 151.
pub fn ruby_shared_audits_l151_d11_self_forgejo_repo_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	return state.forgejo_repo_data(args[offset].as_string(), args[offset + 1].as_string())
}

// Ruby method `self.gitlab_release_data(user, repo, tag)` at line 161.
pub fn ruby_shared_audits_l161_d12_self_gitlab_release_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	return state.gitlab_release_data(args[offset].as_string(), args[offset + 1].as_string(), args[offset + 2].as_string())
}

// Ruby method `self.gitlab_release(user, repo, tag, formula: nil, cask: nil)` at line 179.
pub fn ruby_shared_audits_l179_d13_self_gitlab_release(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	subject := if args.len > offset + 3 {
		shared_audits_package_from_value(args[offset + 3])
	} else {
		none
	}
	return shared_audits_optional_value(state.gitlab_release(args[offset].as_string(), args[offset + 1].as_string(), args[offset + 2].as_string(), subject))
}

// Ruby method `self.forgejo_release_data(user, repo, tag)` at line 196.
pub fn ruby_shared_audits_l196_d14_self_forgejo_release_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	return state.forgejo_release_data(args[offset].as_string(), args[offset + 1].as_string(), args[offset + 2].as_string())
}

// Ruby method `self.forgejo_release(user, repo, tag, formula: nil, cask: nil)` at line 214.
pub fn ruby_shared_audits_l214_d15_self_forgejo_release(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	subject := if args.len > offset + 3 {
		shared_audits_package_from_value(args[offset + 3])
	} else {
		none
	}
	return shared_audits_optional_value(state.forgejo_release(args[offset].as_string(), args[offset + 1].as_string(), args[offset + 2].as_string(), subject))
}

// Ruby method `self.github(user, repo, self_submission: false)` at line 230.
pub fn ruby_shared_audits_l230_d16_self_github(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	self_submission := args.len > offset + 2 && args[offset + 2].bool_data
	return shared_audits_optional_value(state.github(args[offset].as_string(), args[offset + 1].as_string(), self_submission))
}

// Ruby method `self.gitlab(user, repo, self_submission: false)` at line 258.
pub fn ruby_shared_audits_l258_d17_self_gitlab(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	self_submission := args.len > offset + 2 && args[offset + 2].bool_data
	return shared_audits_optional_value(state.gitlab(args[offset].as_string(), args[offset + 1].as_string(), self_submission))
}

// Ruby method `self.bitbucket(user, repo, self_submission: false)` at line 284.
pub fn ruby_shared_audits_l284_d18_self_bitbucket(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	self_submission := args.len > offset + 2 && args[offset + 2].bool_data
	return shared_audits_optional_value(state.bitbucket(args[offset].as_string(), args[offset + 1].as_string(), self_submission))
}

// Ruby method `self.forgejo(user, repo, self_submission: false)` at line 325.
pub fn ruby_shared_audits_l325_d19_self_forgejo(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, offset := shared_audits_state_and_offset(args)
	self_submission := args.len > offset + 2 && args[offset + 2].bool_data
	return shared_audits_optional_value(state.forgejo(args[offset].as_string(), args[offset + 1].as_string(), self_submission))
}

// Ruby method `self.github_tag_from_url(url)` at line 352.
pub fn ruby_shared_audits_l352_d20_self_github_tag_from_url(args ...brew_runtime.Value) brew_runtime.Value {
	return shared_audits_optional_value(shared_audits_github_tag_from_url(args[0].as_string()))
}

// Ruby method `self.gitlab_tag_from_url(url)` at line 358.
pub fn ruby_shared_audits_l358_d21_self_gitlab_tag_from_url(args ...brew_runtime.Value) brew_runtime.Value {
	return shared_audits_optional_value(shared_audits_gitlab_tag_from_url(args[0].as_string()))
}

// Ruby method `self.forgejo_tag_from_url(url)` at line 363.
pub fn ruby_shared_audits_l363_d22_self_forgejo_tag_from_url(args ...brew_runtime.Value) brew_runtime.Value {
	return shared_audits_optional_value(shared_audits_forgejo_tag_from_url(args[0].as_string()))
}

// Ruby method `self.check_deprecate_disable_reason(formula_or_cask)` at line 368.
pub fn ruby_shared_audits_l368_d23_self_check_deprecate_disable_reason(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return shared_audits_nil()
	}
	subject := shared_audits_deprecate_disable_subject_from_value(args[0])
	return shared_audits_optional_value(shared_audits_check_deprecate_disable_reason(subject))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/curl"
// 5: require "utils/github/api"
// 6:
// 7: # Auditing functions for rules common to both casks and formulae.
// 8: module SharedAudits
// 9:   URL_TYPE_HOMEPAGE = "homepage URL"
// 10:   SELF_SUBMISSION_THRESHOLD_MULTIPLIER = 3
// 11:   GITHUB_NOTABILITY_THRESHOLDS = T.let({ forks: 30, watchers: 30, stars: 75 }.freeze, T::Hash[Symbol, Integer])
// 12:   GITLAB_NOTABILITY_THRESHOLDS = T.let({ forks: 30, stars: 75 }.freeze, T::Hash[Symbol, Integer])
// 13:   BITBUCKET_NOTABILITY_THRESHOLDS = T.let({ forks: 30, watchers: 75 }.freeze, T::Hash[Symbol, Integer])
// 14:   FORGEJO_NOTABILITY_THRESHOLDS = T.let({ forks: 30, watchers: 30, stars: 75 }.freeze, T::Hash[Symbol, Integer])
// 15:   @pull_request_author = T.let(nil, T.nilable(String))
// 16:   @pull_request_author_computed = T.let(false, T::Boolean)
// 17:   @self_submission_cache = T.let({}, T::Hash[String, T::Boolean])
// 18:
// 19:   sig { params(browsed: T.nilable(Date)).returns(T::Boolean) }
// 20:   def self.homepage_browsed_recently?(browsed)
// 21:     return false unless browsed
// 22:
// 23:     today = Date.today
// 24:     browsed <= today && browsed.next_year > today
// 25:   end
// 26:
// 27:   sig { returns(T.nilable(String)) }
// 28:   def self.pull_request_author
// 29:     return @pull_request_author if @pull_request_author_computed
// 30:
// 31:     @pull_request_author_computed = true
// 32:     github_event_path = ENV.fetch("GITHUB_EVENT_PATH", nil)
// 33:     return @pull_request_author = nil if github_event_path.blank?
// 34:
// 35:     @pull_request_author = JSON.parse(File.read(github_event_path)).dig("pull_request", "user", "login")
// 36:   rescue Errno::ENOENT, JSON::ParserError
// 37:     @pull_request_author = nil
// 38:   end
// 39:
// 40:   sig { params(submitter: T.nilable(String), repo_owner: String).returns(T::Boolean) }
// 41:   def self.self_submission?(submitter, repo_owner)
// 42:     return false if submitter.blank?
// 43:     return false if repo_owner.empty?
// 44:
// 45:     submitter.casecmp?(repo_owner)
// 46:   end
// 47:
// 48:   sig { params(repo_owner: String).returns(T::Boolean) }
// 49:   def self.self_submission_for_repo_owner?(repo_owner)
// 50:     return false if repo_owner.blank?
// 51:
// 52:     submitter = pull_request_author
// 53:     return false if submitter.blank?
// 54:
// 55:     key = repo_owner.downcase
// 56:     return @self_submission_cache.fetch(key) if @self_submission_cache.key?(key)
// 57:
// 58:     @self_submission_cache[key] = self_submission?(submitter, repo_owner)
// 59:   end
// 60:
// 61:   sig { params(thresholds: T::Hash[Symbol, Integer], self_submission: T::Boolean).returns(T::Hash[Symbol, Integer]) }
// 62:   def self.notability_thresholds_for(thresholds, self_submission)
// 63:     return thresholds unless self_submission
// 64:
// 65:     thresholds.transform_values { |value| value * SELF_SUBMISSION_THRESHOLD_MULTIPLIER }
// 66:   end
// 67:
// 68:   sig { params(product: String, cycle: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 69:   def self.eol_data(product, cycle)
// 70:     @eol_data ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
// 71:     key = "#{product}/#{cycle}"
// 72:     return @eol_data[key] if @eol_data.key?(key)
// 73:
// 74:     result = Utils::Curl.curl_output(
// 75:       "--location",
// 76:       "https://endoflife.date/api/v1/products/#{product}/releases/#{cycle}",
// 77:     )
// 78:     return unless result.status.success?
// 79:
// 80:     @eol_data[key] = begin
// 81:       JSON.parse(result.stdout)
// 82:     rescue JSON::ParserError
// 83:       nil
// 84:     end
// 85:   end
// 86:
// 87:   sig { params(user: String, repo: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 88:   def self.github_repo_data(user, repo)
// 89:     @github_repo_data ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
// 90:     @github_repo_data["#{user}/#{repo}"] ||= GitHub.repository(user, repo)
// 91:
// 92:     @github_repo_data["#{user}/#{repo}"]
// 93:   rescue GitHub::API::HTTPNotFoundError
// 94:     nil
// 95:   rescue GitHub::API::AuthenticationFailedError => e
// 96:     raise unless e.message.match?(GitHub::API::GITHUB_IP_ALLOWLIST_ERROR)
// 97:   end
// 98:
// 99:   sig { params(user: String, repo: String, tag: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 100:   private_class_method def self.github_release_data(user, repo, tag)
// 101:     id = "#{user}/#{repo}/#{tag}"
// 102:     url = "#{GitHub::API_URL}/repos/#{user}/#{repo}/releases/tags/#{tag}"
// 103:     @github_release_data ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
// 104:     @github_release_data[id] ||= GitHub::API.open_rest(url)
// 105:
// 106:     @github_release_data[id]
// 107:   rescue GitHub::API::HTTPNotFoundError
// 108:     nil
// 109:   rescue GitHub::API::AuthenticationFailedError => e
// 110:     raise unless e.message.match?(GitHub::API::GITHUB_IP_ALLOWLIST_ERROR)
// 111:   end
// 112:
// 113:   sig {
// 114:     params(
// 115:       user: String, repo: String, tag: String, formula: T.nilable(Formula), cask: T.nilable(Cask::Cask),
// 116:     ).returns(
// 117:       T.nilable(String),
// 118:     )
// 119:   }
// 120:   def self.github_release(user, repo, tag, formula: nil, cask: nil)
// 121:     release = github_release_data(user, repo, tag)
// 122:     return unless release
// 123:
// 124:     exception, name, version = if formula
// 125:       [formula.tap&.audit_exception(:github_prerelease_allowlist, formula.name), formula.name, formula.version]
// 126:     elsif cask
// 127:       [cask.tap&.audit_exception(:github_prerelease_allowlist, cask.token), cask.token, cask.version]
// 128:     end
// 129:
// 130:     return "#{tag} is a GitHub pre-release." if release["prerelease"] && [version, "all", "any"].exclude?(exception)
// 131:
// 132:     if !release["prerelease"] && exception && [version, "any"].exclude?(exception)
// 133:       return "#{tag} is not a GitHub pre-release but '#{name}' is in the GitHub prerelease allowlist."
// 134:     end
// 135:
// 136:     "#{tag} is a GitHub draft." if release["draft"]
// 137:   end
// 138:
// 139:   sig { params(user: String, repo: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 140:   def self.gitlab_repo_data(user, repo)
// 141:     @gitlab_repo_data ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
// 142:     @gitlab_repo_data["#{user}/#{repo}"] ||= begin
// 143:       result = Utils::Curl.curl_output("https://gitlab.com/api/v4/projects/#{user}%2F#{repo}")
// 144:       json = JSON.parse(result.stdout) if result.status.success?
// 145:       json = nil if json&.dig("message")&.include?("404 Project Not Found")
// 146:       json
// 147:     end
// 148:   end
// 149:
// 150:   sig { params(user: String, repo: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 151:   def self.forgejo_repo_data(user, repo)
// 152:     @forgejo_repo_data ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
// 153:     @forgejo_repo_data["#{user}/#{repo}"] ||= begin
// 154:       result = Utils::Curl.curl_output("https://codeberg.org/api/v1/repos/#{user}/#{repo}", "--fail")
// 155:
// 156:       JSON.parse(result.stdout) if result.status.success?
// 157:     end
// 158:   end
// 159:
// 160:   sig { params(user: String, repo: String, tag: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 161:   private_class_method def self.gitlab_release_data(user, repo, tag)
// 162:     id = "#{user}/#{repo}/#{tag}"
// 163:     @gitlab_release_data ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
// 164:     @gitlab_release_data[id] ||= begin
// 165:       result = Utils::Curl.curl_output(
// 166:         "https://gitlab.com/api/v4/projects/#{user}%2F#{repo}/releases/#{tag}", "--fail"
// 167:       )
// 168:       JSON.parse(result.stdout) if result.status.success?
// 169:     end
// 170:   end
// 171:
// 172:   sig {
// 173:     params(
// 174:       user: String, repo: String, tag: String, formula: T.nilable(Formula), cask: T.nilable(Cask::Cask),
// 175:     ).returns(
// 176:       T.nilable(String),
// 177:     )
// 178:   }
// 179:   def self.gitlab_release(user, repo, tag, formula: nil, cask: nil)
// 180:     release = gitlab_release_data(user, repo, tag)
// 181:     return unless release
// 182:
// 183:     return if DateTime.parse(release["released_at"]) <= DateTime.now
// 184:
// 185:     exception, version = if formula
// 186:       [formula.tap&.audit_exception(:gitlab_prerelease_allowlist, formula.name), formula.version]
// 187:     elsif cask
// 188:       [cask.tap&.audit_exception(:gitlab_prerelease_allowlist, cask.token), cask.version]
// 189:     end
// 190:     return if [version, "all"].include?(exception)
// 191:
// 192:     "#{tag} is a GitLab pre-release."
// 193:   end
// 194:
// 195:   sig { params(user: String, repo: String, tag: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 196:   private_class_method def self.forgejo_release_data(user, repo, tag)
// 197:     id = "#{user}/#{repo}/#{tag}"
// 198:     @forgejo_release_data ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
// 199:     @forgejo_release_data[id] ||= begin
// 200:       result = Utils::Curl.curl_output(
// 201:         "https://codeberg.org/api/v1/repos/#{user}/#{repo}/releases/tags/#{tag}", "--fail"
// 202:       )
// 203:       JSON.parse(result.stdout) if result.status.success?
// 204:     end
// 205:   end
// 206:
// 207:   sig {
// 208:     params(
// 209:       user: String, repo: String, tag: String, formula: T.nilable(Formula), cask: T.nilable(Cask::Cask),
// 210:     ).returns(
// 211:       T.nilable(String),
// 212:     )
// 213:   }
// 214:   def self.forgejo_release(user, repo, tag, formula: nil, cask: nil)
// 215:     release = forgejo_release_data(user, repo, tag)
// 216:     return unless release
// 217:     return unless release["prerelease"]
// 218:
// 219:     exception, version = if formula
// 220:       [formula.tap&.audit_exception(:forgejo_prerelease_allowlist, formula.name), formula.version]
// 221:     elsif cask
// 222:       [cask.tap&.audit_exception(:forgejo_prerelease_allowlist, cask.token), cask.version]
// 223:     end
// 224:     return if [version, "all"].include?(exception)
// 225:
// 226:     "#{tag} is a Forgejo pre-release."
// 227:   end
// 228:
// 229:   sig { params(user: String, repo: String, self_submission: T::Boolean).returns(T.nilable(String)) }
// 230:   def self.github(user, repo, self_submission: false)
// 231:     metadata = github_repo_data(user, repo)
// 232:
// 233:     return if metadata.nil?
// 234:
// 235:     return "GitHub fork (not canonical repository)" if metadata["fork"]
// 236:
// 237:     notability_thresholds = notability_thresholds_for(GITHUB_NOTABILITY_THRESHOLDS, self_submission)
// 238:     notability_prefix = if self_submission
// 239:       "Self-submitted GitHub repository not notable enough"
// 240:     else
// 241:       "GitHub repository not notable enough"
// 242:     end
// 243:     if (metadata["forks_count"] < notability_thresholds.fetch(:forks)) &&
// 244:        (metadata["subscribers_count"] < notability_thresholds.fetch(:watchers)) &&
// 245:        (metadata["stargazers_count"] < notability_thresholds.fetch(:stars))
// 246:       return "#{notability_prefix} (<#{notability_thresholds.fetch(:forks)} forks, " \
// 247:              "<#{notability_thresholds.fetch(:watchers)} watchers and " \
// 248:              "<#{notability_thresholds.fetch(:stars)} stars)"
// 249:     end
// 250:
// 251:     age_days = (Date.today - Date.parse(metadata["created_at"])).to_i
// 252:     return if age_days >= 30
// 253:
// 254:     "GitHub repository too new (#{age_days} days old, 30 days required)"
// 255:   end
// 256:
// 257:   sig { params(user: String, repo: String, self_submission: T::Boolean).returns(T.nilable(String)) }
// 258:   def self.gitlab(user, repo, self_submission: false)
// 259:     metadata = gitlab_repo_data(user, repo)
// 260:
// 261:     return if metadata.nil?
// 262:
// 263:     return "GitLab fork (not canonical repository)" if metadata["fork"]
// 264:
// 265:     notability_thresholds = notability_thresholds_for(GITLAB_NOTABILITY_THRESHOLDS, self_submission)
// 266:     notability_prefix = if self_submission
// 267:       "Self-submitted GitLab repository not notable enough"
// 268:     else
// 269:       "GitLab repository not notable enough"
// 270:     end
// 271:     if (metadata["forks_count"] < notability_thresholds.fetch(:forks)) &&
// 272:        (metadata["star_count"] < notability_thresholds.fetch(:stars))
// 273:       return "#{notability_prefix} (<#{notability_thresholds.fetch(:forks)} forks and " \
// 274:              "<#{notability_thresholds.fetch(:stars)} stars)"
// 275:     end
// 276:
// 277:     age_days = (Date.today - Date.parse(metadata["created_at"])).to_i
// 278:     return if age_days >= 30
// 279:
// 280:     "GitLab repository too new (#{age_days} days old, 30 days required)"
// 281:   end
// 282:
// 283:   sig { params(user: String, repo: String, self_submission: T::Boolean).returns(T.nilable(String)) }
// 284:   def self.bitbucket(user, repo, self_submission: false)
// 285:     api_url = "https://api.bitbucket.org/2.0/repositories/#{user}/#{repo}"
// 286:     result = Utils::Curl.curl_output("--request", "GET", api_url)
// 287:     return unless result.status.success?
// 288:
// 289:     metadata = JSON.parse(result.stdout)
// 290:     return if metadata.nil?
// 291:
// 292:     return "Uses deprecated Mercurial support in Bitbucket" if metadata["scm"] == "hg"
// 293:
// 294:     return "Bitbucket fork (not canonical repository)" unless metadata["parent"].nil?
// 295:
// 296:     age_days = (Date.today - Date.parse(metadata["created_on"])).to_i
// 297:     return "Bitbucket repository too new (#{age_days} days old, 30 days required)" if age_days < 30
// 298:
// 299:     forks_result = Utils::Curl.curl_output("--request", "GET", "#{api_url}/forks")
// 300:     return unless forks_result.status.success?
// 301:
// 302:     watcher_result = Utils::Curl.curl_output("--request", "GET", "#{api_url}/watchers")
// 303:     return unless watcher_result.status.success?
// 304:
// 305:     forks_metadata = JSON.parse(forks_result.stdout)
// 306:     return if forks_metadata.nil?
// 307:
// 308:     watcher_metadata = JSON.parse(watcher_result.stdout)
// 309:     return if watcher_metadata.nil?
// 310:
// 311:     notability_thresholds = notability_thresholds_for(BITBUCKET_NOTABILITY_THRESHOLDS, self_submission)
// 312:     return if forks_metadata["size"] >= notability_thresholds.fetch(:forks) ||
// 313:               watcher_metadata["size"] >= notability_thresholds.fetch(:watchers)
// 314:
// 315:     notability_prefix = if self_submission
// 316:       "Self-submitted Bitbucket repository not notable enough"
// 317:     else
// 318:       "Bitbucket repository not notable enough"
// 319:     end
// 320:     "#{notability_prefix} (<#{notability_thresholds.fetch(:forks)} forks and " \
// 321:       "<#{notability_thresholds.fetch(:watchers)} watchers)"
// 322:   end
// 323:
// 324:   sig { params(user: String, repo: String, self_submission: T::Boolean).returns(T.nilable(String)) }
// 325:   def self.forgejo(user, repo, self_submission: false)
// 326:     metadata = forgejo_repo_data(user, repo)
// 327:     return if metadata.nil?
// 328:
// 329:     return "Forgejo fork (not canonical repository)" if metadata["fork"]
// 330:
// 331:     notability_thresholds = notability_thresholds_for(FORGEJO_NOTABILITY_THRESHOLDS, self_submission)
// 332:     notability_prefix = if self_submission
// 333:       "Self-submitted Forgejo repository not notable enough"
// 334:     else
// 335:       "Forgejo repository not notable enough"
// 336:     end
// 337:     if (metadata["forks_count"] < notability_thresholds.fetch(:forks)) &&
// 338:        (metadata["watchers_count"] < notability_thresholds.fetch(:watchers)) &&
// 339:        (metadata["stars_count"] < notability_thresholds.fetch(:stars))
// 340:       return "#{notability_prefix} (<#{notability_thresholds.fetch(:forks)} forks, " \
// 341:              "<#{notability_thresholds.fetch(:watchers)} watchers and " \
// 342:              "<#{notability_thresholds.fetch(:stars)} stars)"
// 343:     end
// 344:
// 345:     age_days = (Date.today - Date.parse(metadata["created_at"])).to_i
// 346:     return if age_days >= 30
// 347:
// 348:     "Forgejo repository too new (#{age_days} days old, 30 days required)"
// 349:   end
// 350:
// 351:   sig { params(url: String).returns(T.nilable(String)) }
// 352:   def self.github_tag_from_url(url)
// 353:     tag = url[%r{^https://github\.com/[\w-]+/[\w.-]+/archive/refs/tags/(.+)\.(tar\.gz|zip)$}, 1]
// 354:     tag || url[%r{^https://github\.com/[\w-]+/[\w.-]+/releases/download/([^/]+)/}, 1]
// 355:   end
// 356:
// 357:   sig { params(url: String).returns(T.nilable(String)) }
// 358:   def self.gitlab_tag_from_url(url)
// 359:     url[%r{^https://gitlab\.com/(?:\w[\w.-]*/){2,}-/archive/([^/]+)/}, 1]
// 360:   end
// 361:
// 362:   sig { params(url: String).returns(T.nilable(String)) }
// 363:   def self.forgejo_tag_from_url(url)
// 364:     url[%r{^https://codeberg\.org/[\w-]+/[\w.-]+/archive/(.+)\.(tar\.gz|zip)$}, 1]
// 365:   end
// 366:
// 367:   sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(T.nilable(String)) }
// 368:   def self.check_deprecate_disable_reason(formula_or_cask)
// 369:     return if !formula_or_cask.deprecated? && !formula_or_cask.disabled?
// 370:
// 371:     reason = formula_or_cask.deprecated? ? formula_or_cask.deprecation_reason : formula_or_cask.disable_reason
// 372:     return unless reason.is_a?(Symbol)
// 373:
// 374:     reasons = if formula_or_cask.is_a?(Formula)
// 375:       DeprecateDisable::FORMULA_DEPRECATE_DISABLE_REASONS
// 376:     else
// 377:       DeprecateDisable::CASK_DEPRECATE_DISABLE_REASONS
// 378:     end
// 379:
// 380:     "#{reason} is not a valid deprecate! or disable! reason" unless reasons.include?(reason)
// 381:   end
// 382: end
