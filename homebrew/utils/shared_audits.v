module utils

import ruby
import net.http
import os
import time

// Translated from Homebrew/brew `utils/shared_audits.rb`.
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

pub type SharedAuditsFetcher = fn ([]string) !SharedAuditsHttpResult

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
	eol_data_cache               map[string]ruby.Value
	github_repo_data_cache       map[string]ruby.Value
	github_release_data_cache    map[string]ruby.Value
	gitlab_repo_data_cache       map[string]ruby.Value
	gitlab_release_data_cache    map[string]ruby.Value
	forgejo_repo_data_cache      map[string]ruby.Value
	forgejo_release_data_cache   map[string]ruby.Value
}

fn shared_audits_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
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
		eol_data_cache: map[string]ruby.Value{}
		github_repo_data_cache: map[string]ruby.Value{}
		github_release_data_cache: map[string]ruby.Value{}
		gitlab_repo_data_cache: map[string]ruby.Value{}
		gitlab_release_data_cache: map[string]ruby.Value{}
		forgejo_repo_data_cache: map[string]ruby.Value{}
		forgejo_release_data_cache: map[string]ruby.Value{}
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
	parsed := ruby.parse_json_value(contents) or { return none }
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

fn (state &SharedAuditsState) fetch_json(arguments []string) ?ruby.Value {
	result := state.fetcher(arguments) or { return none }
	if !result.success {
		return none
	}
	return ruby.parse_json_value(result.stdout) or { none }
}

pub fn (mut state SharedAuditsState) eol_data(product string, cycle string) ruby.Value {
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

fn shared_audits_present(value ruby.Value) bool {
	return value.type_name != 'NilClass'
}

fn shared_audits_truthy(value ruby.Value) bool {
	if value.type_name == 'NilClass' {
		return false
	}
	if value.type_name == 'Bool' {
		return value.bool_data
	}
	return true
}

fn shared_audits_string(metadata ruby.Value, key string) string {
	return (metadata.map_data[key] or { return '' }).as_string()
}

fn shared_audits_int(metadata ruby.Value, key string) int {
	value := metadata.map_data[key] or { return 0 }
	return if value.type_name == 'Integer' { int(value.int_data) } else { value.as_string().int() }
}

fn shared_audits_bool(metadata ruby.Value, key string) bool {
	value := metadata.map_data[key] or { return false }
	return shared_audits_truthy(value)
}

fn (mut state SharedAuditsState) cached_json(mut cache map[string]ruby.Value,
	key string, arguments []string) ruby.Value {
	if key in cache {
		return cache[key]
	}
	data := state.fetch_json(arguments) or { return shared_audits_nil() }
	if shared_audits_present(data) {
		cache[key] = data
	}
	return data
}

pub fn (mut state SharedAuditsState) github_repo_data(user string, repo string) ruby.Value {
	key := '${user}/${repo}'
	return state.cached_json(mut state.github_repo_data_cache, key, [
		'https://api.github.com/repos/${user}/${repo}',
	])
}

pub fn (mut state SharedAuditsState) github_release_data(user string, repo string,
	tag string) ruby.Value {
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

pub fn (mut state SharedAuditsState) gitlab_repo_data(user string, repo string) ruby.Value {
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

pub fn (mut state SharedAuditsState) forgejo_repo_data(user string, repo string) ruby.Value {
	key := '${user}/${repo}'
	return state.cached_json(mut state.forgejo_repo_data_cache, key, [
		'https://codeberg.org/api/v1/repos/${user}/${repo}',
		'--fail',
	])
}

pub fn (mut state SharedAuditsState) gitlab_release_data(user string, repo string,
	tag string) ruby.Value {
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
	tag string) ruby.Value {
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

pub fn shared_audits_state_boundary(state &SharedAuditsState) ruby.Value {
	return ruby.structured_value('SharedAudits::State', '', {
		'shared_audits_state_address': u64(voidptr(state)).str()
	})
}

fn shared_audits_state_and_offset(args []ruby.Value) (&SharedAuditsState, int) {
	if args.len > 0 && 'shared_audits_state_address' in args[0].attributes {
		return unsafe { &SharedAuditsState(voidptr(args[0].attributes['shared_audits_state_address'].u64())) }, 1
	}
	return new_shared_audits_state(SharedAuditsConfig{}), 0
}

pub fn shared_audits_package_value(package SharedAuditsPackage) ruby.Value {
	mut exceptions := map[string]ruby.Value{}
	for key, value in package.exceptions {
		exceptions[key] = ruby.string_value(value)
	}
	return ruby.Value{
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

fn shared_audits_package_from_value(value ruby.Value) ?SharedAuditsPackage {
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

pub fn shared_audits_deprecate_disable_subject_value(subject SharedAuditsDeprecateDisableSubject) ruby.Value {
	return ruby.structured_value('SharedAudits::DeprecateDisableSubject', '', {
		'kind':                         subject.kind.str()
		'deprecated':                   subject.deprecated.str()
		'disabled':                     subject.disabled.str()
		'deprecation_reason':           subject.deprecation_reason
		'deprecation_reason_is_symbol': subject.deprecation_reason_is_symbol.str()
		'disable_reason':               subject.disable_reason
		'disable_reason_is_symbol':     subject.disable_reason_is_symbol.str()
	})
}

fn shared_audits_deprecate_disable_subject_from_value(value ruby.Value) SharedAuditsDeprecateDisableSubject {
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

fn shared_audits_optional_string(value ruby.Value) ?string {
	return if value.type_name == 'NilClass' { none } else { value.as_string() }
}

fn shared_audits_optional_value(value ?string) ruby.Value {
	return ruby.string_value(value or { return shared_audits_nil() })
}
