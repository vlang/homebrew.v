module dev_cmd

import brew_runtime
import crypto.sha256
import json2
import os
import time

// Translated from Homebrew/brew `dev-cmd/contributions.rb`.
// The original source is retained below for source-level traceability.

const contribution_max_search = 100
const contribution_maintainer_threshold = 50
const contribution_lead_repository_threshold = 25
const contribution_max = 500

pub struct ContributionPullRequest {
pub:
	number     int
	repository string
}

pub struct ContributionMaintainerChange {
pub:
	commit        string
	date          string
	readme        string
	parent_readme string
}

pub struct ContributionRepositoryRef {
pub:
	repository     string
	path           string
	ref            string = 'origin/HEAD'
	exists         bool
	tap_available  bool
	deprecated     bool
	git_log        string
	readme         string
	maintainer_log []ContributionMaintainerChange
}

pub struct ContributionRepositoryCounts {
pub:
	repository string
	counts     map[string]int
}

pub struct ContributionUserResult {
pub:
	user string
pub mut:
	repositories []ContributionRepositoryCounts
}

pub struct ContributionGitParseResult {
pub:
	counts   map[string]map[string]int
	authored map[string][]string
	merged   map[string][]string
}

pub struct ContributionScanRequest {
pub:
	organisation             string
	repositories             []string
	repository_refs          []ContributionRepositoryRef
	users                    map[string]string
	from                     string
	to                       string
	github_users             map[string]string
	authored_pull_requests   map[string][]ContributionPullRequest
	approved_pull_requests   map[string][]ContributionPullRequest
	skip_reviews_if_lead_met bool
	progress                 bool
}

pub struct ContributionMaintainerUsers {
pub:
	user_names             map[string]string
	lead_maintainers       map[string]bool
	maintainer_since_dates map[string]string
}

pub struct ContributionReportRequest {
pub:
	results                []ContributionUserResult
	grand_totals           map[string]map[string]int
	user_names             map[string]string
	lead_maintainers       map[string]bool
	maintainer_since_dates map[string]string
	to                     string
}

pub struct ContributionRunRequest {
pub:
	maintainer_report_csv  string
	requested_users        []string
	no_github_api          bool
	csv                    bool
	quarter                int
	quarter_supplied       bool
	from                   string
	to                     string
	verbose                bool
	organisation           string
	team                   string
	users                  map[string]string
	repositories           []string
	organisation_repos     []string
	repository_sources     []ContributionRepositoryRef
	github_users           map[string]string
	github_email_matches   map[string][]string
	authored_pull_requests map[string][]ContributionPullRequest
	approved_pull_requests map[string][]ContributionPullRequest
	current_year           int
	current_date           string
}

pub struct ContributionRunResult {
pub:
	from         string
	to           string
	organisation string
	users        map[string]string
	repositories []string
	results      []ContributionUserResult
	grand_totals map[string]map[string]int
	summaries    []string
	csv          string
	output_name  string
	progress     []string
}

pub struct ContributionRepositoryLocation {
pub:
	path  string
	tap   string
	found bool
}

pub struct ContributionCacheRequest {
pub:
	cache_key string
	to        string
	today     string
	cache_dir string
	results   []string
}

fn contribution_types() []string {
	return ['merged_pr_author', 'merged_pr_merger', 'merged_pr', 'approved_pr_review', 'coauthor']
}

fn contribution_qualifying_types() []string {
	return ['merged_pr', 'approved_pr_review', 'coauthor']
}

fn contribution_primary_repositories() []string {
	return ['Homebrew/brew', 'Homebrew/homebrew-core', 'Homebrew/homebrew-cask']
}

fn contribution_empty_counts() map[string]int {
	mut counts := map[string]int{}
	for kind in contribution_types() {
		counts[kind] = 0
	}
	return counts
}

fn contribution_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

fn contribution_error(message string) brew_runtime.Value {
	return brew_runtime.structured_value('Error', message, {
		'message': message
	})
}

fn contribution_map_string(values map[string]brew_runtime.Value, key string, fallback string) string {
	return (values[key] or { brew_runtime.string_value(fallback) }).as_string()
}

fn contribution_map_bool(values map[string]brew_runtime.Value, key string, fallback bool) bool {
	value := values[key] or { return fallback }
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn contribution_map_int(values map[string]brew_runtime.Value, key string, fallback int) int {
	value := values[key] or { return fallback }
	return if value.type_name == 'Integer' { int(value.int_data) } else { fallback }
}

fn contribution_string_map_from_value(value brew_runtime.Value) map[string]string {
	mut output := map[string]string{}
	for key, item in value.map_data {
		output[key] = item.as_string()
	}
	return output
}

fn contribution_string_array_map_from_value(value brew_runtime.Value) map[string][]string {
	mut output := map[string][]string{}
	for key, item in value.map_data {
		output[key] = item.string_array_data.clone()
	}
	return output
}

fn contribution_bool_map_from_value(value brew_runtime.Value) map[string]bool {
	mut output := map[string]bool{}
	for key, item in value.map_data {
		output[key] = item.bool_data
	}
	return output
}

fn contribution_counts_from_value(value brew_runtime.Value) map[string]int {
	mut output := map[string]int{}
	for key, item in value.map_data {
		output[key] = int(item.int_data)
	}
	return output
}

fn contribution_counts_value(counts map[string]int) brew_runtime.Value {
	mut output := map[string]brew_runtime.Value{}
	for key, count in counts {
		output[key] = brew_runtime.int_value(count)
	}
	return brew_runtime.map_value(output)
}

fn contribution_totals_from_value(value brew_runtime.Value) map[string]map[string]int {
	mut output := map[string]map[string]int{}
	for key, item in value.map_data {
		output[key] = contribution_counts_from_value(item)
	}
	return output
}

fn contribution_totals_value(totals map[string]map[string]int) brew_runtime.Value {
	mut output := map[string]brew_runtime.Value{}
	for key, counts in totals {
		output[key] = contribution_counts_value(counts)
	}
	return brew_runtime.map_value(output)
}

fn contribution_pull_request_value(pull_request ContributionPullRequest) brew_runtime.Value {
	return brew_runtime.map_value({
		'number':     brew_runtime.int_value(pull_request.number)
		'repository': brew_runtime.string_value(pull_request.repository)
	})
}

fn contribution_pull_request_from_value(value brew_runtime.Value) ContributionPullRequest {
	return ContributionPullRequest{
		number: contribution_map_int(value.map_data, 'number', -1)
		repository: contribution_map_string(value.map_data, 'repository', '')
	}
}

fn contribution_pull_request_map_from_value(value brew_runtime.Value) map[string][]ContributionPullRequest {
	mut output := map[string][]ContributionPullRequest{}
	for key, item in value.map_data {
		output[key] = item.array_data.map(contribution_pull_request_from_value(it))
	}
	return output
}

fn contribution_change_value(change ContributionMaintainerChange) brew_runtime.Value {
	return brew_runtime.map_value({
		'commit':        brew_runtime.string_value(change.commit)
		'date':          brew_runtime.string_value(change.date)
		'readme':        brew_runtime.string_value(change.readme)
		'parent_readme': brew_runtime.string_value(change.parent_readme)
	})
}

fn contribution_change_from_value(value brew_runtime.Value) ContributionMaintainerChange {
	return ContributionMaintainerChange{
		commit: contribution_map_string(value.map_data, 'commit', '')
		date: contribution_map_string(value.map_data, 'date', '')
		readme: contribution_map_string(value.map_data, 'readme', '')
		parent_readme: contribution_map_string(value.map_data, 'parent_readme', '')
	}
}

fn contribution_repository_ref_value(reference ContributionRepositoryRef) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'RepositoryRef'
		repr: reference.repository
		map_data: {
			'repository':     brew_runtime.string_value(reference.repository)
			'path':           brew_runtime.string_value(reference.path)
			'ref':            brew_runtime.string_value(reference.ref)
			'exists':         brew_runtime.bool_value(reference.exists)
			'tap_available':  brew_runtime.bool_value(reference.tap_available)
			'deprecated':     brew_runtime.bool_value(reference.deprecated)
			'git_log':        brew_runtime.string_value(reference.git_log)
			'readme':         brew_runtime.string_value(reference.readme)
			'maintainer_log': brew_runtime.array_value(reference.maintainer_log.map(contribution_change_value(it)))
		}
	}
}

fn contribution_repository_ref_from_value(value brew_runtime.Value) ContributionRepositoryRef {
	changes := (value.map_data['maintainer_log'] or { brew_runtime.array_value([]) }).array_data.map(contribution_change_from_value(it))
	return ContributionRepositoryRef{
		repository: contribution_map_string(value.map_data, 'repository', value.repr)
		path: contribution_map_string(value.map_data, 'path', '')
		ref: contribution_map_string(value.map_data, 'ref', 'origin/HEAD')
		exists: contribution_map_bool(value.map_data, 'exists', false)
		tap_available: contribution_map_bool(value.map_data, 'tap_available', false)
		deprecated: contribution_map_bool(value.map_data, 'deprecated', false)
		git_log: contribution_map_string(value.map_data, 'git_log', '')
		readme: contribution_map_string(value.map_data, 'readme', '')
		maintainer_log: changes
	}
}

fn contribution_repository_counts_value(result ContributionRepositoryCounts) brew_runtime.Value {
	return brew_runtime.map_value({
		'repository': brew_runtime.string_value(result.repository)
		'counts':     contribution_counts_value(result.counts)
	})
}

fn contribution_repository_counts_from_value(value brew_runtime.Value) ContributionRepositoryCounts {
	return ContributionRepositoryCounts{
		repository: contribution_map_string(value.map_data, 'repository', '')
		counts: contribution_counts_from_value(value.map_data['counts'] or { brew_runtime.map_value({}) })
	}
}

fn contribution_user_result_value(result ContributionUserResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'user':         brew_runtime.string_value(result.user)
		'repositories': brew_runtime.array_value(result.repositories.map(contribution_repository_counts_value(it)))
	})
}

fn contribution_user_result_from_value(value brew_runtime.Value) ContributionUserResult {
	return ContributionUserResult{
		user: contribution_map_string(value.map_data, 'user', '')
		repositories: (value.map_data['repositories'] or { brew_runtime.array_value([]) }).array_data.map(contribution_repository_counts_from_value(it))
	}
}

fn contribution_results_value(results []ContributionUserResult) brew_runtime.Value {
	return brew_runtime.array_value(results.map(contribution_user_result_value(it)))
}

fn contribution_results_from_value(value brew_runtime.Value) []ContributionUserResult {
	return value.array_data.map(contribution_user_result_from_value(it))
}

fn contribution_contains(values []string, candidate string) bool {
	return candidate in values
}

fn contribution_append_unique(mut values []string, candidate string) {
	if candidate !in values {
		values << candidate
	}
}

fn contribution_local_identity(email string) string {
	mut local := email.all_before('@')
	plus := local.index('+') or { -1 }
	if plus > 0 {
		mut numeric := true
		for character in local[..plus] {
			if character < `0` || character > `9` {
				numeric = false
				break
			}
		}
		if numeric {
			local = local[plus + 1..]
		}
	}
	return local.to_lower()
}

pub fn contribution_github_username_for(user string, public_email_matches []string) ?string {
	if !user.contains('@') {
		return user
	}
	if user.ends_with('@users.noreply.github.com') {
		return contribution_local_identity(user)
	}
	if public_email_matches.len == 1 && public_email_matches[0] != '' {
		return public_email_matches[0]
	}
	return none
}

pub fn contribution_user_for_git_identity(name string, email string, identity_users map[string]string) ?string {
	for identity in [name.trim_space().to_lower(), email.to_lower(),
		contribution_local_identity(email)] {
		if user := identity_users[identity] {
			return user
		}
	}
	return none
}

pub fn contribution_increment(mut counts map[string]int, kind string) {
	count := counts[kind] or { 0 }
	if count < contribution_max {
		counts[kind] = count + 1
	}
}

fn contribution_merge_parts(body string) ?[]string {
	first_line := body.all_before('\n')
	prefix := 'Merge pull request #'
	if !first_line.starts_with(prefix) || !first_line.contains(' from ') {
		return none
	}
	rest := first_line.all_after(prefix)
	id := rest.all_before(' ')
	source := first_line.all_after(' from ')
	if id == '' || !source.contains('/') {
		return none
	}
	return [id, source.all_before('/')]
}

fn contribution_coauthors(body string) [][]string {
	mut output := [][]string{}
	for line in body.split_into_lines() {
		trimmed := line.trim_space()
		prefix := 'co-authored-by:'
		if !trimmed.to_lower().starts_with(prefix) || !trimmed.contains('<') || !trimmed.contains('>') {
			continue
		}
		name := trimmed[prefix.len..].all_before('<').trim_space()
		email := trimmed.all_after('<').all_before('>').trim_space()
		output << [name, email]
	}
	return output
}

pub fn contribution_parse_git_log(output string, users map[string]string) ContributionGitParseResult {
	mut counts := map[string]map[string]int{}
	mut identity_users := map[string]string{}
	for user, name in users {
		counts[user] = contribution_empty_counts()
		identity_users[user.to_lower()] = user
		identity_users[name.to_lower()] = user
		identity_users[contribution_local_identity(user)] = user
	}
	mut records := [][]string{}
	for raw_record in output.split('\x1e') {
		fields := raw_record.trim_space().split_nth('\x1f', 5)
		if fields.len == 5 {
			records << fields
		}
	}
	mut identities := map[string][]string{}
	for fields in records {
		identities[fields[0]] = [fields[2], fields[3]]
	}
	for fields in records {
		parents := fields[1].fields()
		merge := contribution_merge_parts(fields[4]) or { continue }
		if parents.len < 2 {
			continue
		}
		user := identity_users[merge[1].to_lower()] or { continue }
		source_identity := identities[parents[1]] or { continue }
		for identity in [source_identity[0].trim_space().to_lower(), source_identity[1].to_lower(),
			contribution_local_identity(source_identity[1])] {
			if identity !in identity_users {
				identity_users[identity] = user
			}
		}
	}
	mut commit_authors := map[string]string{}
	for fields in records {
		if user := contribution_user_for_git_identity(fields[2], fields[3], identity_users) {
			commit_authors[fields[0]] = user
		}
	}
	mut authored := map[string][]string{}
	mut merged := map[string][]string{}
	for user, _ in users {
		authored[user] = []string{}
		merged[user] = []string{}
	}
	for fields in records {
		mut coauthor_users := []string{}
		for identity in contribution_coauthors(fields[4]) {
			if user := contribution_user_for_git_identity(identity[0], identity[1], identity_users) {
				contribution_append_unique(mut coauthor_users, user)
			}
		}
		for user in coauthor_users {
			mut user_counts := counts[user].clone()
			contribution_increment(mut user_counts, 'coauthor')
			counts[user] = user_counts.clone()
		}
		parents := fields[1].fields()
		merge := contribution_merge_parts(fields[4]) or { continue }
		if parents.len < 2 {
			continue
		}
		merger := contribution_user_for_git_identity(fields[2], fields[3], identity_users) or { '' }
		mut author := identity_users[merge[1].to_lower()] or { '' }
		if author == '' {
			author = commit_authors[parents[1]] or { '' }
		}
		if author != '' {
			mut user_counts := counts[author].clone()
			contribution_increment(mut user_counts, 'merged_pr_author')
			counts[author] = user_counts.clone()
			mut ids := authored[author].clone()
			contribution_append_unique(mut ids, merge[0])
			authored[author] = ids
		}
		if merger != '' {
			mut user_counts := counts[merger].clone()
			contribution_increment(mut user_counts, 'merged_pr_merger')
			counts[merger] = user_counts.clone()
		}
		mut qualifying_users := []string{}
		if author != '' {
			qualifying_users << author
		}
		if merger != '' {
			contribution_append_unique(mut qualifying_users, merger)
		}
		for user in qualifying_users {
			mut user_counts := counts[user].clone()
			contribution_increment(mut user_counts, 'merged_pr')
			counts[user] = user_counts.clone()
			mut ids := merged[user].clone()
			contribution_append_unique(mut ids, merge[0])
			merged[user] = ids
		}
	}
	return ContributionGitParseResult{
		counts: counts
		authored: authored
		merged: merged
	}
}

pub fn contribution_add_merged_pull_request_id(pull_request ContributionPullRequest, mut authored []string, mut merged []string) {
	if pull_request.number < 0 {
		return
	}
	id := pull_request.number.str()
	contribution_append_unique(mut authored, id)
	contribution_append_unique(mut merged, id)
}

pub fn contribution_update_merged_pull_request_counts(mut counts map[string]int, authored []string, merged []string) {
	if authored.len > 0 {
		counts['merged_pr_author'] = if authored.len < contribution_max {
			authored.len
		} else {
			contribution_max
		}
	}
	if merged.len > 0 {
		counts['merged_pr'] = if merged.len < contribution_max {
			merged.len
		} else {
			contribution_max
		}
	}
}

pub fn contribution_count(contributions map[string]int) int {
	mut count := 0
	for _, value in contributions {
		count += value
	}
	return count
}

fn contribution_qualifying_count(counts map[string]int) int {
	mut qualifying := 0
	for kind in contribution_qualifying_types() {
		qualifying += counts[kind] or { 0 }
	}
	return qualifying
}

pub fn contribution_total(results []ContributionRepositoryCounts) map[string]int {
	mut totals := map[string]int{}
	for result in results {
		for kind, count in result.counts {
			totals[kind] = (totals[kind] or { 0 }) + count
		}
	}
	return totals
}

pub fn contribution_lead_activity_met(repositories []ContributionRepositoryCounts) bool {
	mut active := 0
	for repository in repositories {
		if contribution_qualifying_count(repository.counts) >= contribution_lead_repository_threshold {
			active++
		}
	}
	return active >= 2
}

fn contribution_result_index(results []ContributionUserResult, user string) int {
	for index, result in results {
		if result.user == user {
			return index
		}
	}
	return -1
}

fn contribution_repository_index(results []ContributionRepositoryCounts, repository string) int {
	for index, result in results {
		if result.repository == repository {
			return index
		}
	}
	return -1
}

fn contribution_tracker_key(user string, repository string) string {
	return '${user}\x00${repository}'
}

pub fn contribution_scan(request ContributionScanRequest) []ContributionUserResult {
	mut results := []ContributionUserResult{}
	mut users := request.users.keys()
	users.sort()
	for user in users {
		mut repositories := []ContributionRepositoryCounts{}
		for repository in request.repositories {
			repositories << ContributionRepositoryCounts{ repository: repository, counts: contribution_empty_counts() }
		}
		results << ContributionUserResult{ user: user, repositories: repositories }
	}
	mut authored_ids := map[string][]string{}
	mut merged_ids := map[string][]string{}
	for reference in request.repository_refs {
		parsed := contribution_parse_git_log(reference.git_log, request.users)
		for user in users {
			result_index := contribution_result_index(results, user)
			repository_index := contribution_repository_index(results[result_index].repositories, reference.repository)
			if repository_index < 0 {
				continue
			}
			mut user_result := results[result_index]
			user_result.repositories[repository_index] = ContributionRepositoryCounts{
				repository: reference.repository
				counts: (parsed.counts[user] or { contribution_empty_counts() }).clone()
			}
			results[result_index] = user_result
			key := contribution_tracker_key(user, reference.repository)
			authored_ids[key] = (parsed.authored[user] or { []string{} }).clone()
			merged_ids[key] = (parsed.merged[user] or { []string{} }).clone()
		}
	}
	for user in users {
		pull_requests := request.authored_pull_requests[user] or { []ContributionPullRequest{} }
		result_index := contribution_result_index(results, user)
		if pull_requests.len >= contribution_max_search && request.repositories.len > 0 {
			mut user_result := results[result_index]
			mut first := user_result.repositories[0]
			mut first_counts := first.counts.clone()
			first_counts['merged_pr_author_hit_cap'] = 1
			first = ContributionRepositoryCounts{ repository: first.repository, counts: first_counts }
			user_result.repositories[0] = first
			results[result_index] = user_result
		}
		for pull_request in pull_requests {
			if pull_request.repository !in request.repositories {
				continue
			}
			key := contribution_tracker_key(user, pull_request.repository)
			mut authored := authored_ids[key].clone()
			mut merged := merged_ids[key].clone()
			contribution_add_merged_pull_request_id(pull_request, mut authored, mut merged)
			authored_ids[key] = authored
			merged_ids[key] = merged
		}
		mut user_result := results[result_index]
		for repository_index, repository_result in user_result.repositories {
			key := contribution_tracker_key(user, repository_result.repository)
			mut counts := repository_result.counts.clone()
			contribution_update_merged_pull_request_counts(mut counts, authored_ids[key] or { []string{} }, merged_ids[key] or { []string{} })
			user_result.repositories[repository_index] = ContributionRepositoryCounts{
				repository: repository_result.repository
				counts: counts
			}
		}
		results[result_index] = user_result
	}
	for user in users {
		result_index := contribution_result_index(results, user)
		if request.skip_reviews_if_lead_met && contribution_lead_activity_met(results[result_index].repositories) {
			continue
		}
		reviews := request.approved_pull_requests[user] or { []ContributionPullRequest{} }
		if reviews.len >= contribution_max_search && request.repositories.len > 0 {
			mut user_result := results[result_index]
			mut first := user_result.repositories[0]
			mut counts := first.counts.clone()
			counts['approved_pr_review_hit_cap'] = 1
			user_result.repositories[0] = ContributionRepositoryCounts{ repository: first.repository, counts: counts }
			results[result_index] = user_result
		}
		for review in reviews {
			if review.repository !in request.repositories {
				continue
			}
			mut user_result := results[result_index]
			repository_index := contribution_repository_index(user_result.repositories, review.repository)
			if repository_index < 0 {
				continue
			}
			mut repository_result := user_result.repositories[repository_index]
			mut counts := repository_result.counts.clone()
			contribution_increment(mut counts, 'approved_pr_review')
			user_result.repositories[repository_index] = ContributionRepositoryCounts{
				repository: repository_result.repository
				counts: counts
			}
			results[result_index] = user_result
		}
	}
	return results
}

pub fn contribution_readme_mentions(readme string, user string, name string) bool {
	return readme.contains('https://github.com/${user}') || readme.contains(name)
}

pub fn contribution_maintainer_since(reference ContributionRepositoryRef, user string, name string) ?string {
	mut candidates := reference.maintainer_log.clone()
	candidates.sort_with_compare(fn (a &ContributionMaintainerChange, b &ContributionMaintainerChange) int {
		return a.date.compare(b.date)
	})
	for candidate in candidates {
		if candidate.date != '' && contribution_readme_mentions(candidate.readme, user, name)
			&& !contribution_readme_mentions(candidate.parent_readme, user, name) {
			return candidate.date
		}
	}
	return none
}

fn contribution_markdown_maintainers(readme string) (map[string]string, map[string]bool) {
	mut names := map[string]string{}
	mut leads := map[string]bool{}
	for line in readme.split_into_lines() {
		lead := line.starts_with("Homebrew's [Lead Maintainers]")
		if !lead && !line.starts_with("Homebrew's other Maintainers")
			&& !line.starts_with("Homebrew's maintainers are") {
			continue
		}
		mut remainder := line
		for remainder.contains('](https://github.com/') {
			close := remainder.index('](https://github.com/') or { break }
			open := remainder[..close].last_index('[') or { break }
			name := remainder[open + 1..close]
			user_start := close + '](https://github.com/'.len
			user_end_relative := remainder[user_start..].index(')') or { break }
			user := remainder[user_start..user_start + user_end_relative]
			if user != '' {
				names[user] = name
				if lead {
					leads[user.to_lower()] = true
				}
			}
			remainder = remainder[user_start + user_end_relative + 1..]
		}
	}
	return names, leads
}

pub fn contribution_maintainer_report_users(repository_refs []ContributionRepositoryRef, requested_users []string,
	email_matches map[string][]string) !ContributionMaintainerUsers {
	mut brew_reference := ContributionRepositoryRef{}
	mut found := false
	for reference in repository_refs {
		if reference.repository == 'Homebrew/brew' {
			brew_reference = reference
			found = true
			break
		}
	}
	if !found || brew_reference.readme == '' {
		return error("Could not find Homebrew/brew's README at the end of the reporting quarter.")
	}
	mut user_names, lead_maintainers := contribution_markdown_maintainers(brew_reference.readme)
	if user_names.len == 0 {
		return error("Could not read the maintainers from Homebrew/brew's README.")
	}
	if requested_users.len > 0 {
		mut selected := map[string]string{}
		for requested in requested_users {
			resolved := contribution_github_username_for(requested, email_matches[requested] or { []string{} }) or {
				return error('Could not resolve GitHub username for: ${requested}.')
			}
			mut canonical := ''
			for user, _ in user_names {
				if user.to_lower() == resolved.to_lower() {
					canonical = user
					break
				}
			}
			if canonical == '' {
				return error('Not listed as Maintainer at the end of the reporting quarter: ${requested}.')
			}
			selected[canonical] = user_names[canonical]
		}
		user_names = selected.clone()
	}
	mut since_dates := map[string]string{}
	for user, name in user_names {
		since_dates[user] = contribution_maintainer_since(brew_reference, user, name) or { '' }
	}
	return ContributionMaintainerUsers{
		user_names: user_names
		lead_maintainers: lead_maintainers
		maintainer_since_dates: since_dates
	}
}

pub fn contribution_prepare_repositories(repositories []string, sources []ContributionRepositoryRef,
	required bool) ![]ContributionRepositoryRef {
	mut prepared := []ContributionRepositoryRef{}
	for repository in repositories {
		mut matched := false
		for source in sources {
			if source.repository != repository {
				continue
			}
			matched = true
			if source.deprecated {
				break
			}
			if source.exists || source.tap_available {
				prepared << ContributionRepositoryRef{
					...source
					exists: true
				}
			} else if required {
				return error('Could not find a local Git repository for ${repository}.')
			}
			break
		}
		if !matched && required {
			return error('Could not find a local Git repository for ${repository}.')
		}
	}
	return prepared
}

pub fn contribution_repository_path_and_tap(repository string, brew_repository string, taps_root string,
	deprecated_official_taps []string) ContributionRepositoryLocation {
	if repository == 'Homebrew/brew' {
		return ContributionRepositoryLocation{ path: brew_repository, found: true }
	}
	if !repository.contains('/homebrew-') {
		return ContributionRepositoryLocation{}
	}
	parts := repository.split('/')
	if parts.len != 2 {
		return ContributionRepositoryLocation{}
	}
	tap_repository := parts[1].all_after('homebrew-')
	tap_name := '${parts[0]}/${tap_repository}'
	if parts[0] == 'Homebrew' && tap_repository in deprecated_official_taps {
		return ContributionRepositoryLocation{}
	}
	return ContributionRepositoryLocation{
		path: os.join_path(taps_root, parts[0].to_lower(), 'homebrew-${tap_repository}')
		tap: tap_name
		found: true
	}
}

pub fn contribution_time_period(from string, to string) string {
	if from != '' && to != '' {
		return 'between ${from} and ${to}'
	}
	if from != '' {
		return 'after ${from}'
	}
	if to != '' {
		return 'before ${to}'
	}
	return 'in all time'
}

pub fn contribution_reporting_quarter_dates(quarter int, current_year int) ![]string {
	return match quarter {
		1 { ['${current_year - 1}-12-01', '${current_year}-03-01'] }
		2 { ['${current_year}-03-01', '${current_year}-06-01'] }
		3 { ['${current_year}-06-01', '${current_year}-09-01'] }
		4 { ['${current_year}-09-01', '${current_year}-12-01'] }
		else { error('quarter must be between 1 and 4') }
	}
}

fn contribution_csv_field(value string) string {
	if value.contains_any(',"\n\r') {
		return '"${value.replace('"', '""')}"'
	}
	return value
}

fn contribution_csv_row(values []string) string {
	return values.map(contribution_csv_field(it)).join(',') + '\n'
}

pub fn contribution_grand_total_row(user string, grand_total map[string]int) []string {
	mut row := [user, 'all']
	for kind in contribution_types() {
		row << (grand_total[kind] or { 0 }).str()
	}
	row << contribution_qualifying_count(grand_total).str()
	return row
}

pub fn contribution_generate_csv(totals map[string]map[string]int) string {
	mut users := totals.keys()
	users.sort_with_compare(fn [totals] (a &string, b &string) int {
		a_count := contribution_qualifying_count(totals[*a])
		b_count := contribution_qualifying_count(totals[*b])
		if a_count == b_count {
			return a.compare(*b)
		}
		return b_count - a_count
	})
	mut output := contribution_csv_row(['username', 'repo', 'authored', 'merged', 'PRs', 'reviews',
		'coauthored', 'total'])
	for user in users {
		output += contribution_csv_row(contribution_grand_total_row(user, totals[user]))
	}
	return output
}

fn contribution_days_between(from string, to string) int {
	from_time := time.parse_iso8601(from) or { return 0 }
	to_time := time.parse_iso8601(to) or { return 0 }
	days := int((to_time.unix() - from_time.unix()) / 86_400)
	return if days > 0 { days } else { 0 }
}

fn contribution_repository_short_name(repository string) string {
	return repository.all_after('Homebrew/').trim_string_left('homebrew-')
}

fn contribution_report_sort(mut users []string, totals map[string]map[string]int) {
	for index in 1 .. users.len {
		mut cursor := index
		for cursor > 0 {
			left := users[cursor - 1]
			right := users[cursor]
			left_total := contribution_qualifying_count(totals[left])
			right_total := contribution_qualifying_count(totals[right])
			if right_total < left_total || (right_total == left_total && right.to_lower() >= left.to_lower()) {
				break
			}
			users[cursor - 1] = right
			users[cursor] = left
			cursor--
		}
	}
}

pub fn contribution_generate_maintainer_report_csv(request ContributionReportRequest) string {
	mut header := ['username', 'name', 'since', 'tenure days']
	for repository in contribution_primary_repositories() {
		name := contribution_repository_short_name(repository)
		header << '${name} authored'
		header << '${name} merged'
		header << '${name} PRs'
		header << '${name} reviews'
		header << '${name} coauthored'
		header << '${name} total'
	}
	header << 'total'
	header << 'maintainer met'
	header << 'lead met'
	header << 'capped'
	header << 'role'
	header << 'new role'
	mut output := contribution_csv_row(header)
	mut users := request.user_names.keys()
	contribution_report_sort(mut users, request.grand_totals)
	for user in users {
		user_result_index := contribution_result_index(request.results, user)
		if user_result_index < 0 {
			continue
		}
		user_result := request.results[user_result_index]
		grand_total := request.grand_totals[user].clone()
		qualifying_total := contribution_qualifying_count(grand_total)
		maintainer_met := qualifying_total >= contribution_maintainer_threshold
		since := request.maintainer_since_dates[user] or { '' }
		lead := request.lead_maintainers[user.to_lower()] or { false }
		lead_met := contribution_lead_activity_met(user_result.repositories)
		three_year_tenure := since != '' && contribution_days_between(since, request.to) >= 3 * 365
		new_role := if lead_met && (lead || three_year_tenure) {
			'Lead Maintainer'
		} else if maintainer_met {
			'Maintainer'
		} else {
			'None'
		}
		mut capped := (grand_total['merged_pr_author_hit_cap'] or { 0 }) > 0
			|| (grand_total['approved_pr_review_hit_cap'] or { 0 }) > 0
		for repository in user_result.repositories {
			if (repository.counts['approved_pr_review'] or { 0 }) >= contribution_max_search {
				capped = true
			}
			for kind, count in repository.counts {
				if kind != 'approved_pr_review' && count >= contribution_max {
					capped = true
				}
			}
		}
		mut row := [user, request.user_names[user], since]
		row << if since == '' { '' } else { contribution_days_between(since, request.to).str() }
		for repository in contribution_primary_repositories() {
			index := contribution_repository_index(user_result.repositories, repository)
			counts := if index >= 0 {
				user_result.repositories[index].counts
			} else {
				contribution_empty_counts()
			}
			for kind in contribution_types() {
				row << (counts[kind] or { 0 }).str()
			}
			row << contribution_qualifying_count(counts).str()
		}
		row << qualifying_total.str()
		row << maintainer_met.str()
		row << lead_met.str()
		row << capped.str()
		row << if lead { 'Lead Maintainer' } else { 'Maintainer' }
		row << new_role
		output += contribution_csv_row(row)
	}
	return output
}

pub fn contribution_github_search_with_rate_limit(request ContributionCacheRequest) ![]string {
	cacheable := request.to != '' && request.today != '' && request.to <= request.today
	if !cacheable {
		return request.results.clone()
	}
	digest := sha256.sum256('1\x00${request.cache_key}'.bytes()).hex()
	cache_path := os.join_path(request.cache_dir, 'contributions--${digest}.json')
	if os.is_file(cache_path) {
		contents := os.read_file(cache_path) or { '' }
		if cached := json2.decode[[]string](contents) {
			return cached
		}
		os.rm(cache_path) or {}
	}
	os.mkdir_all(request.cache_dir)!
	temporary := '${cache_path}.tmp-${os.getpid()}'
	os.write_file(temporary, json2.encode(request.results))!
	os.mv(temporary, cache_path)!
	return request.results.clone()
}

fn contribution_default_date(request ContributionRunRequest) string {
	if request.current_date != '' {
		return request.current_date
	}
	return time.now().format_ss()[..10]
}

fn contribution_previous_year(date string) string {
	if date.len >= 4 {
		year := date[..4].int() - 1
		return '${year}${date[4..]}'
	}
	return date
}

fn contribution_next_day(date string) string {
	parsed := time.parse_iso8601(date) or { return date }
	return parsed.add_days(1).format_ss()[..10]
}

pub fn run_contributions(request ContributionRunRequest) !ContributionRunResult {
	if request.no_github_api {
		return error('Cannot get contributions as `\$HOMEBREW_NO_GITHUB_API` is set!')
	}
	for user in request.requested_users {
		if user == '' {
			return error('`--user` must not contain empty values.')
		}
	}
	mut year := request.current_year
	if year == 0 {
		year = time.now().year
	}
	mut from := request.from
	mut to := request.to
	if request.maintainer_report_csv != '' {
		parts := request.maintainer_report_csv.split('-')
		if parts.len != 2 || parts[0].len != 4 || parts[0].int() < 1 || parts[1].int() < 1
			|| parts[1].int() > 4 {
			return error('`--maintainer-report-csv` must be in YEAR-QUARTER format.')
		}
		dates := contribution_reporting_quarter_dates(parts[1].int(), parts[0].int())!
		from, to = dates[0], dates[1]
	} else if request.quarter_supplied {
		dates := contribution_reporting_quarter_dates(request.quarter, year) or {
			return error('Value for `--quarter` must be between 1 and 4.')
		}
		if from == '' {
			from = dates[0]
		}
		if to == '' {
			to = dates[1]
		}
	}
	today := contribution_default_date(request)
	if from == '' {
		from = contribution_previous_year(today)
	}
	if to == '' {
		to = contribution_next_day(today)
	}
	mut organisation := request.organisation
	mut repositories := request.repositories.clone()
	if request.maintainer_report_csv != '' {
		organisation = 'Homebrew'
		repositories = contribution_primary_repositories()
	} else if repositories == ['primary'] || repositories.len == 0 {
		repositories = contribution_primary_repositories()
	} else if organisation != '' && request.organisation_repos.len > 0 {
		repositories = request.organisation_repos.clone()
	}
	if repositories.len == 0 {
		return error('No repositories to scan.')
	}
	mut repository_organisation := ''
	for repository in repositories {
		owner := repository.all_before('/')
		if repository_organisation == '' {
			repository_organisation = owner
		} else if owner != repository_organisation {
			return error('All repositories must be under the same user or organisation!')
		}
	}
	if organisation == '' {
		organisation = repository_organisation
	}
	prepared := contribution_prepare_repositories(repositories, request.repository_sources, request.maintainer_report_csv != '')!
	mut users := request.users.clone()
	if users.len == 0 {
		for user in request.requested_users {
			users[user] = user
		}
	}
	mut leads := map[string]bool{}
	mut since := map[string]string{}
	if request.maintainer_report_csv != '' {
		maintainers := contribution_maintainer_report_users(prepared, request.requested_users, request.github_email_matches)!
		users = maintainers.user_names.clone()
		leads = maintainers.lead_maintainers.clone()
		since = maintainers.maintainer_since_dates.clone()
	}
	results := contribution_scan(ContributionScanRequest{
		organisation: organisation
		repositories: repositories
		repository_refs: prepared
		users: users
		from: from
		to: to
		github_users: request.github_users
		authored_pull_requests: request.authored_pull_requests
		approved_pull_requests: request.approved_pull_requests
		skip_reviews_if_lead_met: request.maintainer_report_csv != ''
		progress: request.verbose || request.maintainer_report_csv != ''
	})
	mut totals := map[string]map[string]int{}
	for result in results {
		totals[result.user] = contribution_total(result.repositories)
	}
	mut summaries := []string{}
	mut usernames := users.keys()
	usernames.sort()
	for user in usernames {
		qualifying := contribution_qualifying_count(totals[user])
		summaries << '${user} contributed ${qualifying} times (total) ${contribution_time_period(from, to)}.'
	}
	mut csv := ''
	mut output_name := ''
	if request.maintainer_report_csv != '' {
		csv = contribution_generate_maintainer_report_csv(ContributionReportRequest{
			results: results
			grand_totals: totals
			user_names: users
			lead_maintainers: leads
			maintainer_since_dates: since
			to: to
		})
		output_name = 'brew-contributions-${from}-to-${to}'
		if request.requested_users.len > 0 {
			mut selected := users.keys().map(it.to_lower())
			selected.sort()
			output_name += '-${selected.join('-')}'
		}
		output_name += '.csv'
	} else if request.csv {
		csv = contribution_generate_csv(totals)
	}
	mut progress := []string{}
	if request.verbose {
		progress << 'Date range is ${contribution_time_period(from, to)}.'
	}
	return ContributionRunResult{
		from: from
		to: to
		organisation: organisation
		users: users
		repositories: repositories
		results: results
		grand_totals: totals
		summaries: summaries
		csv: csv
		output_name: output_name
		progress: progress
	}
}

fn contribution_run_request_from_value(value brew_runtime.Value) ContributionRunRequest {
	values := value.map_data.clone()
	return ContributionRunRequest{
		maintainer_report_csv: contribution_map_string(values, 'maintainer_report_csv', '')
		requested_users: (values['requested_users'] or { brew_runtime.string_array_value([]) }).string_array_data.clone()
		no_github_api: contribution_map_bool(values, 'no_github_api', false)
		csv: contribution_map_bool(values, 'csv', false)
		quarter: contribution_map_int(values, 'quarter', 0)
		quarter_supplied: contribution_map_bool(values, 'quarter_supplied', false)
		from: contribution_map_string(values, 'from', '')
		to: contribution_map_string(values, 'to', '')
		verbose: contribution_map_bool(values, 'verbose', false)
		organisation: contribution_map_string(values, 'organisation', '')
		team: contribution_map_string(values, 'team', '')
		users: contribution_string_map_from_value(values['users'] or { brew_runtime.map_value({}) })
		repositories: (values['repositories'] or { brew_runtime.string_array_value([]) }).string_array_data.clone()
		organisation_repos: (values['organisation_repos'] or { brew_runtime.string_array_value([]) }).string_array_data.clone()
		repository_sources: (values['repository_sources'] or { brew_runtime.array_value([]) }).array_data.map(contribution_repository_ref_from_value(it))
		github_users: contribution_string_map_from_value(values['github_users'] or { brew_runtime.map_value({}) })
		github_email_matches: contribution_string_array_map_from_value(values['github_email_matches'] or { brew_runtime.map_value({}) })
		authored_pull_requests: contribution_pull_request_map_from_value(values['authored_pull_requests'] or { brew_runtime.map_value({}) })
		approved_pull_requests: contribution_pull_request_map_from_value(values['approved_pull_requests'] or { brew_runtime.map_value({}) })
		current_year: contribution_map_int(values, 'current_year', 0)
		current_date: contribution_map_string(values, 'current_date', '')
	}
}

fn contribution_run_result_value(result ContributionRunResult) brew_runtime.Value {
	mut users := map[string]brew_runtime.Value{}
	for user, name in result.users {
		users[user] = brew_runtime.string_value(name)
	}
	return brew_runtime.map_value({
		'from':         brew_runtime.string_value(result.from)
		'to':           brew_runtime.string_value(result.to)
		'organisation': brew_runtime.string_value(result.organisation)
		'users':        brew_runtime.map_value(users)
		'repositories': brew_runtime.string_array_value(result.repositories)
		'results':      contribution_results_value(result.results)
		'grand_totals': contribution_totals_value(result.grand_totals)
		'summaries':    brew_runtime.string_array_value(result.summaries)
		'csv':          brew_runtime.string_value(result.csv)
		'output_name':  brew_runtime.string_value(result.output_name)
		'progress':     brew_runtime.string_array_value(result.progress)
	})
}

// Ruby method `run` at line 98.
pub fn ruby_contributions_l98_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return contribution_error('missing contributions request')
	}
	result := run_contributions(contribution_run_request_from_value(args[0])) or {
		return contribution_error(err.msg())
	}
	return contribution_run_result_value(result)
}

// Ruby method `maintainer_report_users(repository_refs, to)` at line 241.
pub fn ruby_contributions_l241_d2_maintainer_report_users(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return contribution_error('missing repository references')
	}
	references := args[0].array_data.map(contribution_repository_ref_from_value(it))
	requested := if args.len > 2 { args[2].string_array_data.clone() } else { []string{} }
	matches := if args.len > 3 {
		contribution_string_array_map_from_value(args[3])
	} else {
		map[string][]string{}
	}
	result := contribution_maintainer_report_users(references, requested, matches) or {
		return contribution_error(err.msg())
	}
	mut names := map[string]brew_runtime.Value{}
	mut leads := map[string]brew_runtime.Value{}
	mut since := map[string]brew_runtime.Value{}
	for user, name in result.user_names {
		names[user] = brew_runtime.string_value(name)
	}
	for user, lead in result.lead_maintainers {
		leads[user] = brew_runtime.bool_value(lead)
	}
	for user, date in result.maintainer_since_dates {
		since[user] = if date == '' { contribution_nil() } else { brew_runtime.string_value(date) }
	}
	return brew_runtime.array_value([brew_runtime.map_value(names), brew_runtime.map_value(leads),
		brew_runtime.map_value(since)])
}

// Ruby method `maintainer_since(repository_path, ref, user, name)` at line 298.
pub fn ruby_contributions_l298_d3_maintainer_since(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		return contribution_nil()
	}
	date := contribution_maintainer_since(contribution_repository_ref_from_value(args[0]), args[2].as_string(), args[3].as_string()) or { return contribution_nil() }
	return brew_runtime.string_value(date)
}

// Ruby method `scan_contributions(organisation, repositories, repository_refs, users, from:, to:,` at line 335.
pub fn ruby_contributions_l335_d4_scan_contributions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return contribution_results_value([])
	}
	values := args[0].map_data.clone()
	request := ContributionScanRequest{
		organisation: contribution_map_string(values, 'organisation', '')
		repositories: (values['repositories'] or { brew_runtime.string_array_value([]) }).string_array_data.clone()
		repository_refs: (values['repository_refs'] or { brew_runtime.array_value([]) }).array_data.map(contribution_repository_ref_from_value(it))
		users: contribution_string_map_from_value(values['users'] or { brew_runtime.map_value({}) })
		from: contribution_map_string(values, 'from', '')
		to: contribution_map_string(values, 'to', '')
		github_users: contribution_string_map_from_value(values['github_users'] or { brew_runtime.map_value({}) })
		authored_pull_requests: contribution_pull_request_map_from_value(values['authored_pull_requests'] or { brew_runtime.map_value({}) })
		approved_pull_requests: contribution_pull_request_map_from_value(values['approved_pull_requests'] or { brew_runtime.map_value({}) })
		skip_reviews_if_lead_met: contribution_map_bool(values, 'skip_reviews_if_lead_met', false)
		progress: contribution_map_bool(values, 'progress', false)
	}
	return contribution_results_value(contribution_scan(request))
}

// Ruby method `github_username_for(user, to:)` at line 471.
pub fn ruby_contributions_l471_d5_github_username_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return contribution_nil()
	}
	matches := if args.len > 2 { args[2].string_array_data } else { []string{} }
	username := contribution_github_username_for(args[0].as_string(), matches) or {
		return contribution_nil()
	}
	return brew_runtime.string_value(username)
}

// Ruby method `github_search_with_rate_limit(cache_key, to:, &block)` at line 498.
pub fn ruby_contributions_l498_d6_github_search_with_rate_limit(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return contribution_error('missing cache request')
	}
	values := args[0].map_data.clone()
	results := contribution_github_search_with_rate_limit(ContributionCacheRequest{
		cache_key: contribution_map_string(values, 'cache_key', '')
		to: contribution_map_string(values, 'to', '')
		today: contribution_map_string(values, 'today', '')
		cache_dir: contribution_map_string(values, 'cache_dir', '')
		results: (values['results'] or { brew_runtime.string_array_value([]) }).string_array_data.clone()
	}) or { return contribution_error(err.msg()) }
	return brew_runtime.string_array_value(results)
}

// Ruby method `parse_git_log(output, users, authored_pull_requests: nil, merged_pull_requests: nil)` at line 532.
pub fn ruby_contributions_l532_d7_parse_git_log(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return contribution_totals_value({})
	}
	result := contribution_parse_git_log(args[0].as_string(), contribution_string_map_from_value(args[1]))
	mut authored := map[string]brew_runtime.Value{}
	mut merged := map[string]brew_runtime.Value{}
	for user, ids in result.authored {
		authored[user] = brew_runtime.string_array_value(ids)
	}
	for user, ids in result.merged {
		merged[user] = brew_runtime.string_array_value(ids)
	}
	return brew_runtime.map_value({
		'counts':   contribution_totals_value(result.counts)
		'authored': brew_runtime.map_value(authored)
		'merged':   brew_runtime.map_value(merged)
	})
}

// Ruby method `generate_maintainer_report_csv(results, grand_totals, user_names, lead_maintainers, maintainer_since_dates,` at line 620.
pub fn ruby_contributions_l620_d8_generate_maintainer_report_csv(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	values := args[0].map_data.clone()
	request := ContributionReportRequest{
		results: contribution_results_from_value(values['results'] or { brew_runtime.array_value([]) })
		grand_totals: contribution_totals_from_value(values['grand_totals'] or { brew_runtime.map_value({}) })
		user_names: contribution_string_map_from_value(values['user_names'] or { brew_runtime.map_value({}) })
		lead_maintainers: contribution_bool_map_from_value(values['lead_maintainers'] or { brew_runtime.map_value({}) })
		maintainer_since_dates: contribution_string_map_from_value(values['maintainer_since_dates'] or { brew_runtime.map_value({}) })
		to: contribution_map_string(values, 'to', '')
	}
	return brew_runtime.string_value(contribution_generate_maintainer_report_csv(request))
}

// Ruby method `prepare_contribution_repositories(repositories, required:)` at line 693.
pub fn ruby_contributions_l693_d9_prepare_contribution_repositories(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.array_value([])
	}
	repositories := args[0].string_array_data
	sources := args[1].array_data.map(contribution_repository_ref_from_value(it))
	required := args.len > 2 && args[2].bool_data
	prepared := contribution_prepare_repositories(repositories, sources, required) or {
		return contribution_error(err.msg())
	}
	return brew_runtime.array_value(prepared.map(contribution_repository_ref_value(it)))
}

// Ruby method `readme_mentions?(readme, user, name)` at line 723.
pub fn ruby_contributions_l723_d10_readme_mentions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(contribution_readme_mentions(args[0].as_string(), args[1].as_string(), args[2].as_string()))
}

// Ruby method `add_merged_pull_request_id(pull_request, authored_pull_requests, merged_pull_requests)` at line 735.
pub fn ruby_contributions_l735_d11_add_merged_pull_request_id(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return contribution_nil()
	}
	mut authored := args[1].string_array_data.clone()
	mut merged := args[2].string_array_data.clone()
	contribution_add_merged_pull_request_id(contribution_pull_request_from_value(args[0]), mut authored, mut merged)
	return brew_runtime.map_value({
		'authored': brew_runtime.string_array_value(authored)
		'merged':   brew_runtime.string_array_value(merged)
	})
}

// Ruby method `update_merged_pull_request_counts(counts, authored_pull_requests, merged_pull_requests)` at line 751.
pub fn ruby_contributions_l751_d12_update_merged_pull_request_counts(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return contribution_counts_value({})
	}
	mut counts := contribution_counts_from_value(args[0])
	contribution_update_merged_pull_request_counts(mut counts, args[1].string_array_data, args[2].string_array_data)
	return contribution_counts_value(counts)
}

// Ruby method `user_for_git_identity(name, email, identity_users)` at line 763.
pub fn ruby_contributions_l763_d13_user_for_git_identity(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return contribution_nil()
	}
	user := contribution_user_for_git_identity(args[0].as_string(), args[1].as_string(), contribution_string_map_from_value(args[2])) or { return contribution_nil() }
	return brew_runtime.string_value(user)
}

// Ruby method `increment_contribution_count(counts, type)` at line 770.
pub fn ruby_contributions_l770_d14_increment_contribution_count(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return contribution_counts_value({})
	}
	mut counts := contribution_counts_from_value(args[0])
	contribution_increment(mut counts, args[1].as_string())
	return contribution_counts_value(counts)
}

// Ruby method `repository_path_and_tap(repository)` at line 776.
pub fn ruby_contributions_l776_d15_repository_path_and_tap(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([contribution_nil(), contribution_nil()])
	}
	location := contribution_repository_path_and_tap(args[0].as_string(), if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}, if args.len > 2 { args[2].as_string() } else { '' }, if args.len > 3 {
		args[3].string_array_data
	} else {
		[]string{}
	})
	if !location.found {
		return brew_runtime.array_value([contribution_nil(), contribution_nil()])
	}
	return brew_runtime.array_value([brew_runtime.string_value(location.path),
		if location.tap == '' { contribution_nil() } else { brew_runtime.string_value(location.tap) }])
}

// Ruby method `time_period(from:, to:)` at line 788.
pub fn ruby_contributions_l788_d16_time_period(args ...brew_runtime.Value) brew_runtime.Value {
	from := if args.len > 0 && args[0].type_name != 'NilClass' { args[0].as_string() } else { '' }
	to := if args.len > 1 && args[1].type_name != 'NilClass' { args[1].as_string() } else { '' }
	return brew_runtime.string_value(contribution_time_period(from, to))
}

// Ruby method `generate_csv(totals)` at line 801.
pub fn ruby_contributions_l801_d17_generate_csv(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value(contribution_generate_csv({}))
	}
	return brew_runtime.string_value(contribution_generate_csv(contribution_totals_from_value(args[0])))
}

// Ruby method `grand_total_row(user, grand_total)` at line 815.
pub fn ruby_contributions_l815_d18_grand_total_row(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	return brew_runtime.string_array_value(contribution_grand_total_row(args[0].as_string(), contribution_counts_from_value(args[1])))
}

// Ruby method `total(results)` at line 822.
pub fn ruby_contributions_l822_d19_total(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return contribution_counts_value({})
	}
	repositories := args[0].array_data.map(contribution_repository_counts_from_value(it))
	return contribution_counts_value(contribution_total(repositories))
}

// Ruby method `contribution_count(contributions)` at line 836.
pub fn ruby_contributions_l836_d20_contribution_count(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.int_value(0)
	}
	return brew_runtime.int_value(contribution_count(contribution_counts_from_value(args[0])))
}

// Ruby method `lead_activity_met?(repositories)` at line 841.
pub fn ruby_contributions_l841_d21_lead_activity_met(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	repositories := args[0].array_data.map(contribution_repository_counts_from_value(it))
	return brew_runtime.bool_value(contribution_lead_activity_met(repositories))
}

// Ruby method `reporting_quarter_dates(quarter, current_year = Date.today.year)` at line 848.
pub fn ruby_contributions_l848_d22_reporting_quarter_dates(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return contribution_error('missing quarter')
	}
	year := if args.len > 1 { int(args[1].int_data) } else { time.now().year }
	dates := contribution_reporting_quarter_dates(int(args[0].int_data), year) or {
		return contribution_error(err.msg())
	}
	return brew_runtime.string_array_value(dates)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "digest"
// 6: require "json"
// 7: require "system_command"
// 8: require "tap"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class Contributions < AbstractCommand
// 13:       include SystemCommand::Mixin
// 14:
// 15:       PRIMARY_REPOS = %w[
// 16:         Homebrew/brew
// 17:         Homebrew/homebrew-core
// 18:         Homebrew/homebrew-cask
// 19:       ].freeze
// 20:       CONTRIBUTION_TYPES = T.let({
// 21:         merged_pr_author:   "merged PRs authored",
// 22:         merged_pr_merger:   "PRs merged",
// 23:         merged_pr:          "qualifying merged PRs",
// 24:         approved_pr_review: "approved-review search matches",
// 25:         coauthor:           "co-authored commits",
// 26:       }.freeze, T::Hash[Symbol, String])
// 27:       MAX_PR_SEARCH = 100
// 28:       # https://docs.brew.sh/Homebrew-Governance#maintainer
// 29:       MAINTAINER_ACTIVITY_THRESHOLD = 50
// 30:       # https://docs.brew.sh/Homebrew-Governance#lead-maintainer
// 31:       LEAD_REPOSITORY_ACTIVITY_THRESHOLD = 25
// 32:       MAX_CONTRIBUTIONS = T.let(MAINTAINER_ACTIVITY_THRESHOLD * 10, Integer)
// 33:       QUALIFYING_CONTRIBUTION_TYPES = [:merged_pr, :approved_pr_review, :coauthor].freeze
// 34:
// 35:       cmd_args do
// 36:         usage_banner "`contributions` [`--user=`] [`--repositories=`] [`--quarter=`] [`--from=`] [`--to=`] " \
// 37:                      "[`--csv`] [`--maintainer-report-csv=`]"
// 38:         description <<~EOS
// 39:           Summarise contributions to Homebrew repositories.
// 40:         EOS
// 41:         comma_array "--user=",
// 42:                     description: "Specify a comma-separated list of GitHub usernames or email addresses to find " \
// 43:                                  "contributions from. Omitting this flag searches Homebrew maintainers and " \
// 44:                                  "requires access to the `Homebrew/maintainers` team. " \
// 45:                                  "With `--maintainer-report-csv`, only matching quarter-end Maintainers are included."
// 46:         comma_array "--repositories",
// 47:                     description: "Specify a comma-separated list of repositories to search. " \
// 48:                                  "All repositories must be under the same user or organisation. " \
// 49:                                  "Omitting this flag, or specifying `--repositories=primary`, searches only the " \
// 50:                                  "main repositories: `Homebrew/brew`, `Homebrew/homebrew-core`, " \
// 51:                                  "`Homebrew/homebrew-cask`."
// 52:         flag   "--organisation=", "--organization=", "--org=",
// 53:                description: "Specify the organisation to populate sources repositories from. " \
// 54:                             "Omitting this flag searches the Homebrew primary repositories."
// 55:         flag   "--team=",
// 56:                description: "Specify the team to populate users from. " \
// 57:                             "The first part of the team name will be used as the organisation."
// 58:         flag   "--quarter=",
// 59:                description: "Homebrew contributions quarter to search (1-4). " \
// 60:                             "Omitting this flag searches the past year. " \
// 61:                             "If `--from` or `--to` are set, they take precedence."
// 62:         flag   "--from=",
// 63:                description: "Date (ISO 8601 format) to start searching contributions. " \
// 64:                             "Omitting this flag searches the past year."
// 65:         flag   "--to=",
// 66:                description: "Date (ISO 8601 format) to stop searching contributions."
// 67:         switch "--csv",
// 68:                description: "Print a CSV of contributions across repositories over the time period."
// 69:         flag   "--maintainer-report-csv=",
// 70:                description: "Print a CSV of Maintainer and Lead Maintainer activity criteria using fetched Git " \
// 71:                             "histories and GitHub's existing approved-review search for the Homebrew " \
// 72:                             "governance quarter, for example " \
// 73:                             "`--maintainer-report-csv=2026-2`. " \
// 74:                             "Also write it in the current directory as `brew-contributions-FROM-to-TO.csv`, or " \
// 75:                             "`brew-contributions-FROM-to-TO-USER.csv` when filtered with `--user`. " \
// 76:                             "Only Maintainers listed at the end of that quarter are included. " \
// 77:                             "The `new role` value must show a downgrade for two consecutive " \
// 78:                             "quarters before a downgrade is applied. " \
// 79:                             "Review searches return at most 100 results and other counts are capped at 500 per " \
// 80:                             "repository and contribution type. Repository-scoped follow-up searches ensure " \
// 81:                             "role activity checks remain accurate when a count is capped. Completed-period " \
// 82:                             "GitHub searches are cached in Homebrew's cache and removed by normal cache pruning. " \
// 83:                             "`YEAR-1` is December of the previous year through February, `YEAR-2` is March " \
// 84:                             "through May, `YEAR-3` is June through August and `YEAR-4` is September through " \
// 85:                             "November."
// 86:         conflicts "--organisation", "--repositories"
// 87:         conflicts "--organisation", "--team"
// 88:         conflicts "--user", "--team"
// 89:         conflicts "--maintainer-report-csv", "--repositories"
// 90:         conflicts "--maintainer-report-csv", "--organisation"
// 91:         conflicts "--maintainer-report-csv", "--team"
// 92:         conflicts "--maintainer-report-csv", "--quarter"
// 93:         conflicts "--maintainer-report-csv", "--from"
// 94:         conflicts "--maintainer-report-csv", "--to"
// 95:       end
// 96:
// 97:       sig { override.void }
// 98:       def run
// 99:         maintainer_report_csv = args.maintainer_report_csv
// 100:         requested_users = args.user || []
// 101:         odie "`--user` must not contain empty values." if requested_users.compact.length != requested_users.length
// 102:
// 103:         odie "Cannot get contributions as `$HOMEBREW_NO_GITHUB_API` is set!" if Homebrew::EnvConfig.no_github_api?
// 104:         Homebrew.install_bundler_gems!(groups: ["contributions"]) if args.csv? || maintainer_report_csv
// 105:
// 106:         if maintainer_report_csv
// 107:           odie "`--maintainer-report-csv` must be in YEAR-QUARTER format." unless maintainer_report_csv.match?(
// 108:             /\A\d{4}-[1-4]\z/,
// 109:           )
// 110:           quarter_parts = maintainer_report_csv.split("-")
// 111:           from, to = reporting_quarter_dates(quarter_parts.fetch(1).to_i, quarter_parts.fetch(0).to_i)
// 112:           $stderr.puts "Maintainer report dates: #{from}-to-#{to}"
// 113:         else
// 114:           quarter = args.quarter.presence.to_i
// 115:           odie "Value for `--quarter` must be between 1 and 4." if args.quarter.present? && !quarter.between?(1, 4)
// 116:           quarter_dates = reporting_quarter_dates(quarter) unless quarter.zero?
// 117:           from = args.from.presence || quarter_dates&.first || Date.today.prev_year.iso8601
// 118:           to = args.to.presence || quarter_dates&.last || (Date.today + 1).iso8601
// 119:           puts "Date range is #{time_period(from:, to:)}." if args.verbose?
// 120:         end
// 121:
// 122:         require "utils/github"
// 123:
// 124:         organisation = T.let(nil, T.nilable(String))
// 125:         users = if maintainer_report_csv
// 126:           []
// 127:         elsif (team = args.team.presence)
// 128:           team_sections = team.split("/")
// 129:           organisation = team_sections.first.presence
// 130:           team_name = team_sections.last.presence
// 131:           if team_sections.length != 2 || organisation.nil? || team_name.nil?
// 132:             odie "Team must be in the format `organisation/team`!"
// 133:           end
// 134:
// 135:           puts "Getting members for #{organisation}/#{team_name}..." if args.verbose?
// 136:           GitHub.members_by_team(organisation, team_name).keys
// 137:         elsif requested_users.present?
// 138:           requested_users
// 139:         else
// 140:           puts "Getting members for Homebrew/maintainers..." if args.verbose?
// 141:           GitHub.members_by_team("Homebrew", "maintainers").keys
// 142:         end
// 143:         user_names = users.to_h { |user| [user, user] }
// 144:
// 145:         repositories = if maintainer_report_csv
// 146:           organisation = "Homebrew"
// 147:           PRIMARY_REPOS
// 148:         elsif (org = organisation.presence) || (org = args.organisation.presence)
// 149:           organisation = org
// 150:           puts "Getting repositories for #{organisation}..." if args.verbose?
// 151:           GitHub.organisation_repositories(organisation, from, to, args.verbose?)
// 152:         elsif (repos = args.repositories.presence) && repos.length == 1 && (first_repository = repos.first)
// 153:           case first_repository
// 154:           when "primary"
// 155:             PRIMARY_REPOS
// 156:           else
// 157:             Array(first_repository)
// 158:           end
// 159:         elsif (repos = args.repositories.presence)
// 160:           organisations = repos.map { |repository| repository.split("/").first }.uniq
// 161:           odie "All repositories must be under the same user or organisation!" if organisations.length > 1
// 162:
// 163:           repos
// 164:         else
// 165:           PRIMARY_REPOS
// 166:         end
// 167:         organisation ||= repositories.fetch(0).split("/").fetch(0)
// 168:         repository_refs = prepare_contribution_repositories(repositories, required: maintainer_report_csv.present?)
// 169:
// 170:         lead_maintainers = T.let({}, T::Hash[String, T::Boolean])
// 171:         maintainer_since_dates = T.let({}, T::Hash[String, T.nilable(String)])
// 172:         if maintainer_report_csv
// 173:           user_names, lead_maintainers, maintainer_since_dates = maintainer_report_users(repository_refs, to)
// 174:         end
// 175:
// 176:         results = scan_contributions(
// 177:           organisation, repositories, repository_refs, user_names, from:, to:,
// 178:           skip_reviews_if_lead_met: maintainer_report_csv.present?,
// 179:           progress:                 maintainer_report_csv.present? || args.verbose?
// 180:         )
// 181:         grand_totals = results.transform_values { |user_results| total(user_results) }
// 182:
// 183:         if maintainer_report_csv
// 184:           csv = generate_maintainer_report_csv(
// 185:             results, grand_totals, user_names, lead_maintainers, maintainer_since_dates, to
// 186:           )
// 187:           filename = "brew-contributions-#{from}-to-#{to}"
// 188:           filename += "-#{user_names.keys.map(&:downcase).sort.join("-")}" if requested_users.present?
// 189:           File.write("#{filename}.csv", csv)
// 190:           puts csv
// 191:           return
// 192:         end
// 193:
// 194:         user_names.each_key do |username|
// 195:           grand_total = grand_totals.fetch(username)
// 196:           greater_than_total = T.let(grand_total.fetch(:merged_pr_author_hit_cap, 0).positive?, T::Boolean)
// 197:           contributions = CONTRIBUTION_TYPES.keys.filter_map do |type|
// 198:             type_count = grand_total[type]
// 199:             next if type_count.nil? || type_count.zero?
// 200:
// 201:             count_prefix = ""
// 202:             if ([:merged_pr_author, :merged_pr].include?(type) && grand_total.fetch(:merged_pr_author_hit_cap,
// 203:                                                                                     0).positive?) ||
// 204:                (type == :approved_pr_review && type_count >= MAX_PR_SEARCH) || type_count >= MAX_CONTRIBUTIONS
// 205:               greater_than_total ||= true
// 206:               count_prefix = ">="
// 207:             end
// 208:
// 209:             pretty_type = CONTRIBUTION_TYPES.fetch(type)
// 210:             "#{count_prefix}#{Utils.pluralize("time", type_count, include_count: true)} (#{pretty_type})"
// 211:           end
// 212:           qualifying_total = contribution_count(
// 213:             grand_total.slice(*QUALIFYING_CONTRIBUTION_TYPES),
// 214:           )
// 215:           total = Utils.pluralize("time", qualifying_total, include_count: true)
// 216:           total_prefix = ">=" if greater_than_total
// 217:           contributions << "#{total_prefix}#{total} (total)"
// 218:
// 219:           contributions_string = [
// 220:             "#{username} contributed",
// 221:             *contributions.to_sentence,
// 222:             "#{time_period(from:, to:)}.",
// 223:           ].join(" ")
// 224:           if args.csv?
// 225:             $stderr.puts contributions_string
// 226:           else
// 227:             puts contributions_string
// 228:           end
// 229:         end
// 230:
// 231:         return unless args.csv?
// 232:
// 233:         $stderr.puts
// 234:         puts generate_csv(grand_totals)
// 235:       end
// 236:
// 237:       sig {
// 238:         params(repository_refs: T::Hash[String, [Pathname, String]], to: String)
// 239:           .returns([T::Hash[String, String], T::Hash[String, T::Boolean], T::Hash[String, T.nilable(String)]])
// 240:       }
// 241:       def maintainer_report_users(repository_refs, to)
// 242:         brew_path, brew_ref = repository_refs.fetch("Homebrew/brew")
// 243:         require "utils/git"
// 244:         quarter_end_ref = Utils.safe_popen_read(
// 245:           Utils::Git.git, "-C", brew_path, "rev-list", "-1", "--before=#{to}", brew_ref, "--", "README.md"
// 246:         ).strip
// 247:         odie "Could not find Homebrew/brew's README at the end of the reporting quarter." if quarter_end_ref.empty?
// 248:
// 249:         user_names = T.let({}, T::Hash[String, String])
// 250:         lead_maintainers = T.let({}, T::Hash[String, T::Boolean])
// 251:         Utils.safe_popen_read(Utils::Git.git, "-C", brew_path, "show", "#{quarter_end_ref}:README.md")
// 252:              .dup.force_encoding(Encoding::UTF_8).each_line do |line|
// 253:           lead = line.start_with?("Homebrew's [Lead Maintainers]")
// 254:           next if !lead &&
// 255:                   !line.start_with?("Homebrew's other Maintainers") &&
// 256:                   !line.start_with?("Homebrew's maintainers are")
// 257:
// 258:           line.scan(%r{\[([^\]]+)\]\(https://github\.com/([A-Za-z\d-]+)\)}).each do |match|
// 259:             next unless match.is_a?(Array)
// 260:
// 261:             name = match.fetch(0)
// 262:             user = match.fetch(1)
// 263:             user_names[user] = name
// 264:             lead_maintainers[user.downcase] = true if lead
// 265:           end
// 266:         end
// 267:         odie "Could not read the maintainers from Homebrew/brew's README." if user_names.empty?
// 268:
// 269:         if (users = args.user.presence)
// 270:           requested_usernames = users.to_h do |user|
// 271:             [user, github_username_for(user, to:)&.downcase]
// 272:           end
// 273:           unresolved_users = requested_usernames.filter_map { |user, username| user if username.nil? }
// 274:           odie "Could not resolve GitHub usernames for: #{unresolved_users.to_sentence}." if unresolved_users.present?
// 275:
// 276:           maintainer_usernames = user_names.keys.map(&:downcase)
// 277:           non_maintainers = requested_usernames.filter_map do |user, username|
// 278:             user if username && maintainer_usernames.exclude?(username)
// 279:           end
// 280:           unless non_maintainers.empty?
// 281:             odie "Not listed as #{Utils.pluralize("Maintainer", non_maintainers.length)} at the end of the " \
// 282:                  "reporting quarter: #{non_maintainers.to_sentence}."
// 283:           end
// 284:
// 285:           selected_usernames = requested_usernames.values.compact
// 286:           user_names.select! { |user| selected_usernames.include?(user.downcase) }
// 287:         end
// 288:
// 289:         maintainer_count = Utils.pluralize("maintainer", user_names.length, include_count: true)
// 290:         $stderr.puts "Scanning contributions for #{maintainer_count}..."
// 291:         maintainer_since_dates = user_names.to_h do |user, name|
// 292:           [user, maintainer_since(brew_path, quarter_end_ref, user, name)]
// 293:         end
// 294:         [user_names, lead_maintainers, maintainer_since_dates]
// 295:       end
// 296:
// 297:       sig { params(repository_path: Pathname, ref: String, user: String, name: String).returns(T.nilable(String)) }
// 298:       def maintainer_since(repository_path, ref, user, name)
// 299:         require "utils/git"
// 300:
// 301:         candidates = ["https://github.com/#{user}", name].flat_map do |identity|
// 302:           Utils.safe_popen_read(
// 303:             Utils::Git.git, "-C", repository_path, "log", ref, "--fixed-strings",
// 304:             "-S#{identity}", "--format=%H%x1f%cs", "--", "README.md"
// 305:           ).lines(chomp: true)
// 306:         end
// 307:         candidates.uniq!
// 308:         candidates.sort_by! { |candidate| candidate.split("\x1f", 2).fetch(1) }
// 309:         candidates.each do |candidate|
// 310:           commit, date = candidate.split("\x1f", 2)
// 311:           next if date.nil?
// 312:
// 313:           readme = Utils.safe_popen_read(Utils::Git.git, "-C", repository_path, "show", "#{commit}:README.md")
// 314:           parent_readme = system_command(Utils::Git.git,
// 315:                                          args:         ["-C", repository_path, "show", "#{commit}^:README.md"],
// 316:                                          print_stderr: false).stdout
// 317:           return date if readme_mentions?(readme, user, name) && !readme_mentions?(parent_readme, user, name)
// 318:         end
// 319:
// 320:         nil
// 321:       end
// 322:
// 323:       sig {
// 324:         params(
// 325:           organisation:             String,
// 326:           repositories:             T::Array[String],
// 327:           repository_refs:          T::Hash[String, [Pathname, String]],
// 328:           users:                    T::Hash[String, String],
// 329:           from:                     String,
// 330:           to:                       String,
// 331:           skip_reviews_if_lead_met: T::Boolean,
// 332:           progress:                 T::Boolean,
// 333:         ).returns(T::Hash[String, T::Hash[String, T::Hash[Symbol, Integer]]])
// 334:       }
// 335:       def scan_contributions(organisation, repositories, repository_refs, users, from:, to:,
// 336:                              skip_reviews_if_lead_met:, progress:)
// 337:         results = users.to_h do |user, _|
// 338:           user_results = repositories.to_h do |repository|
// 339:             [repository, CONTRIBUTION_TYPES.keys.to_h { |type| [type, 0] }]
// 340:           end
// 341:           [user, user_results]
// 342:         end
// 343:
// 344:         require "utils/github"
// 345:         github_users = users.keys.to_h { |user| [user, github_username_for(user, to:)] }
// 346:         git_authored_pull_requests = users.keys.to_h do |user|
// 347:           [user, repositories.to_h { |repository| [repository, Set.new] }]
// 348:         end
// 349:         git_merged_pull_requests = users.keys.to_h do |user|
// 350:           [user, repositories.to_h { |repository| [repository, Set.new] }]
// 351:         end
// 352:         repository_refs.each do |repository, (repository_path, ref)|
// 353:           require "utils/git"
// 354:           output = Utils.safe_popen_read(
// 355:             Utils::Git.git, "-C", repository_path, "log", ref, "--since=#{from}", "--before=#{to}",
// 356:             "--format=%H%x1f%P%x1f%an%x1f%ae%x1f%B%x1e"
// 357:           )
// 358:           authored_pull_requests = users.keys.to_h { |user| [user, Set.new] }
// 359:           merged_pull_requests = users.keys.to_h { |user| [user, Set.new] }
// 360:           parse_git_log(output, users, authored_pull_requests:, merged_pull_requests:).each do |user, counts|
// 361:             results.fetch(user)[repository] = counts
// 362:             git_authored_pull_requests.fetch(user)[repository] = authored_pull_requests.fetch(user)
// 363:             git_merged_pull_requests.fetch(user)[repository] = merged_pull_requests.fetch(user)
// 364:           end
// 365:         end
// 366:
// 367:         merged_range = "#{from}..#{Date.iso8601(to).prev_day.iso8601}"
// 368:         users.each_key do |user|
// 369:           github_user = github_users.fetch(user)
// 370:           next if github_user.nil?
// 371:
// 372:           cache_key = ["merged-at", organisation, github_user, merged_range].join("\0")
// 373:           merged_pull_requests = github_search_with_rate_limit(cache_key, to:) do
// 374:             GitHub.search_issues("", is: "merged", user: organisation, author: github_user, merged: merged_range)
// 375:           rescue GitHub::API::ValidationFailedError
// 376:             opoo "Couldn't search GitHub for PRs authored by #{github_user}. Their profile might be private. " \
// 377:                  "Defaulting to 0."
// 378:             []
// 379:           end
// 380:           capped_merged_pull_requests = merged_pull_requests.length >= MAX_PR_SEARCH
// 381:           if capped_merged_pull_requests
// 382:             results.fetch(user).fetch(repositories.fetch(0))[:merged_pr_author_hit_cap] =
// 383:               1
// 384:           end
// 385:           merged_pull_requests.each do |pull_request|
// 386:             repository = pull_request.fetch("repository_url").delete_prefix("#{GitHub::API_URL}/repos/")
// 387:             next unless repositories.include?(repository)
// 388:
// 389:             authored_pull_requests = git_authored_pull_requests.fetch(user).fetch(repository)
// 390:             merged_pull_request_ids = git_merged_pull_requests.fetch(user).fetch(repository)
// 391:             add_merged_pull_request_id(pull_request, authored_pull_requests, merged_pull_request_ids)
// 392:           end
// 393:           repositories.each do |repository|
// 394:             counts = results.fetch(user).fetch(repository)
// 395:             authored_pull_requests = git_authored_pull_requests.fetch(user).fetch(repository)
// 396:             merged_pull_request_ids = git_merged_pull_requests.fetch(user).fetch(repository)
// 397:             update_merged_pull_request_counts(counts, authored_pull_requests, merged_pull_request_ids)
// 398:           end
// 399:           next unless skip_reviews_if_lead_met
// 400:           next unless capped_merged_pull_requests
// 401:           next if lead_activity_met?(results.fetch(user))
// 402:
// 403:           repositories.each do |repository|
// 404:             break if lead_activity_met?(results.fetch(user))
// 405:
// 406:             repository_counts = results.fetch(user).fetch(repository)
// 407:             repository_total = contribution_count(repository_counts.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 408:             qualifying_total = contribution_count(total(results.fetch(user)).slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 409:             next if repository_total >= LEAD_REPOSITORY_ACTIVITY_THRESHOLD &&
// 410:                     qualifying_total >= MAINTAINER_ACTIVITY_THRESHOLD
// 411:
// 412:             $stderr.puts "Querying merged-PR search for #{user} in #{repository}..." if progress
// 413:             cache_key = ["merged-at", repository, github_user, merged_range].join("\0")
// 414:             repository_pull_requests = github_search_with_rate_limit(cache_key, to:) do
// 415:               GitHub.search_issues("", is: "merged", repo: repository, author: github_user, merged: merged_range)
// 416:             end
// 417:             authored_pull_requests = git_authored_pull_requests.fetch(user).fetch(repository)
// 418:             merged_pull_request_ids = git_merged_pull_requests.fetch(user).fetch(repository)
// 419:             repository_pull_requests.each do |pull_request|
// 420:               add_merged_pull_request_id(pull_request, authored_pull_requests, merged_pull_request_ids)
// 421:             end
// 422:             update_merged_pull_request_counts(repository_counts, authored_pull_requests, merged_pull_request_ids)
// 423:           end
// 424:         end
// 425:
// 426:         review_users = github_users.filter_map { |user, github_user| [user, github_user] if github_user }
// 427:         review_users.reject! { |user, _| lead_activity_met?(results.fetch(user)) } if skip_reviews_if_lead_met
// 428:         review_users.each_with_index do |(user, github_user), index|
// 429:           if progress
// 430:             $stderr.puts "Querying approved-review search for #{user} (#{index + 1}/#{review_users.length})..."
// 431:           end
// 432:           cache_key = ["approved", organisation, github_user, from, to].join("\0")
// 433:           approved_reviews = github_search_with_rate_limit(cache_key, to:) do
// 434:             GitHub.search_approved_pull_requests_in_user_or_organisation(organisation, github_user, from:, to:)
// 435:           end
// 436:           capped_reviews = approved_reviews.length >= MAX_PR_SEARCH
// 437:           results.fetch(user).fetch(repositories.fetch(0))[:approved_pr_review_hit_cap] = 1 if capped_reviews
// 438:           approved_reviews.each do |pull_request|
// 439:             repository = pull_request.fetch("repository_url").delete_prefix("#{GitHub::API_URL}/repos/")
// 440:             next unless repositories.include?(repository)
// 441:
// 442:             increment_contribution_count(results.fetch(user).fetch(repository), :approved_pr_review)
// 443:           end
// 444:           next unless skip_reviews_if_lead_met
// 445:           next unless capped_reviews
// 446:           next if lead_activity_met?(results.fetch(user))
// 447:
// 448:           repositories.each do |repository|
// 449:             break if lead_activity_met?(results.fetch(user))
// 450:
// 451:             repository_counts = results.fetch(user).fetch(repository)
// 452:             repository_total = contribution_count(repository_counts.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 453:             qualifying_total = contribution_count(total(results.fetch(user)).slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 454:             next if repository_total >= LEAD_REPOSITORY_ACTIVITY_THRESHOLD &&
// 455:                     qualifying_total >= MAINTAINER_ACTIVITY_THRESHOLD
// 456:
// 457:             $stderr.puts "Querying approved-review search for #{user} in #{repository}..." if progress
// 458:             cache_key = ["approved", repository, github_user, from, to].join("\0")
// 459:             repository_reviews = github_search_with_rate_limit(cache_key, to:) do
// 460:               GitHub.search_issues("", is: "pr", review: "approved", repo: repository, reviewed_by: github_user,
// 461:                                    from:, to:)
// 462:             end
// 463:             repository_counts[:approved_pr_review] = repository_reviews.length
// 464:           end
// 465:         end
// 466:
// 467:         results
// 468:       end
// 469:
// 470:       sig { params(user: String, to: String).returns(T.nilable(String)) }
// 471:       def github_username_for(user, to:)
// 472:         return user unless user.include?("@")
// 473:         if user.end_with?("@users.noreply.github.com")
// 474:           return user.delete_suffix("@users.noreply.github.com").sub(/\A\d+\+/,
// 475:                                                                      "")
// 476:         end
// 477:
// 478:         cache_key = ["public-email", user].join("\0")
// 479:         matches = github_search_with_rate_limit(cache_key, to:) do
// 480:           GitHub.search("users", "\"#{user}\" in:email").fetch("items", [])
// 481:         end
// 482:         if matches.one?
// 483:           login = matches.fetch(0)["login"]
// 484:           return login if login.is_a?(String)
// 485:         end
// 486:
// 487:         opoo "Could not find a unique public GitHub account for #{user}; skipping GitHub PR searches."
// 488:         nil
// 489:       rescue GitHub::API::ValidationFailedError
// 490:         opoo "Could not search for a public GitHub account for #{user}; skipping GitHub PR searches."
// 491:         nil
// 492:       end
// 493:
// 494:       sig {
// 495:         params(cache_key: String, to: String, block: T.proc.returns(T::Array[T::Hash[String, T.untyped]]))
// 496:           .returns(T::Array[T::Hash[String, T.untyped]])
// 497:       }
// 498:       def github_search_with_rate_limit(cache_key, to:, &block)
// 499:         cache_path = if Date.iso8601(to) <= Date.today
// 500:           HOMEBREW_CACHE/"contributions--#{Digest::SHA256.hexdigest("1\0#{cache_key}")}.json"
// 501:         end
// 502:         if cache_path&.file?
// 503:           begin
// 504:             cached_results = JSON.parse(cache_path.read)
// 505:             return cached_results if cached_results.is_a?(Array)
// 506:           rescue JSON::ParserError, Errno::ENOENT
// 507:             nil
// 508:           end
// 509:           cache_path.unlink if cache_path.exist?
// 510:         end
// 511:
// 512:         results = yield
// 513:         if cache_path
// 514:           HOMEBREW_CACHE.mkpath
// 515:           cache_path.atomic_write(JSON.generate(results))
// 516:         end
// 517:         results
// 518:       rescue GitHub::API::RateLimitExceededError => e
// 519:         GitHub::API.sleep_for_rate_limit(e)
// 520:         retry
// 521:       end
// 522:
// 523:       sig {
// 524:         params(
// 525:           output:                 String,
// 526:           users:                  T::Hash[String, String],
// 527:           authored_pull_requests: T.nilable(T::Hash[String, T::Set[String]]),
// 528:           merged_pull_requests:   T.nilable(T::Hash[String, T::Set[String]]),
// 529:         )
// 530:           .returns(T::Hash[String, T::Hash[Symbol, Integer]])
// 531:       }
// 532:       def parse_git_log(output, users, authored_pull_requests: nil, merged_pull_requests: nil)
// 533:         counts = users.to_h do |user, _|
// 534:           [user, CONTRIBUTION_TYPES.keys.to_h { |type| [type, 0] }]
// 535:         end
// 536:         identity_users = T.let({}, T::Hash[String, String])
// 537:         users.each do |user, name|
// 538:           identity_users[user.downcase] = user
// 539:           identity_users[name.downcase] = user
// 540:           identity_users[user.split("@").first.to_s.sub(/\A\d+\+/, "").downcase] = user
// 541:         end
// 542:         records = output.split("\x1e").filter_map do |record|
// 543:           fields = record.strip.split("\x1f", 5)
// 544:           fields if fields.length == 5
// 545:         end
// 546:         record_identities = records.to_h do |fields|
// 547:           [fields.fetch(0), [fields.fetch(2), fields.fetch(3)]]
// 548:         end
// 549:         records.each do |fields|
// 550:           parents = fields.fetch(1).split
// 551:           source_owner = fields.fetch(4)[%r{\AMerge pull request #\d+ from ([^/\s]+)/}, 1]
// 552:           next if parents.length < 2 || source_owner.nil?
// 553:
// 554:           user = identity_users[source_owner.downcase]
// 555:           source_identity = record_identities[parents.fetch(1)]
// 556:           next if user.nil? || source_identity.nil?
// 557:
// 558:           name, email = source_identity
// 559:           identity_users[name.strip.downcase] ||= user
// 560:           identity_users[email.downcase] ||= user
// 561:           identity_users[email.split("@").first.to_s.sub(/\A\d+\+/, "").downcase] ||= user
// 562:         end
// 563:         commit_authors = T.let(records.to_h do |fields|
// 564:           sha = fields.fetch(0)
// 565:           author_name = fields.fetch(2)
// 566:           author_email = fields.fetch(3)
// 567:           [sha, user_for_git_identity(author_name, author_email, identity_users)]
// 568:         end, T::Hash[String, T.nilable(String)])
// 569:
// 570:         records.each do |fields|
// 571:           parents_string = fields.fetch(1)
// 572:           author_name = fields.fetch(2)
// 573:           author_email = fields.fetch(3)
// 574:           body = fields.fetch(4)
// 575:           coauthors = body.scan(/^Co-authored-by:\s*(.*?)\s*<([^>]+)>/i).filter_map do |match|
// 576:             next unless match.is_a?(Array)
// 577:
// 578:             user_for_git_identity(match.fetch(0), match.fetch(1), identity_users)
// 579:           end
// 580:           coauthors.uniq.each do |user|
// 581:             increment_contribution_count(counts.fetch(user), :coauthor)
// 582:           end
// 583:
// 584:           parents = parents_string.split
// 585:           pull_request = body.match(%r{\AMerge pull request #(\d+) from ([^/\s]+)/})
// 586:           next if parents.length < 2 || pull_request.nil?
// 587:
// 588:           merger = user_for_git_identity(author_name, author_email, identity_users)
// 589:           pull_request_id = pull_request[1]
// 590:           source_owner = pull_request[2]
// 591:           next if pull_request_id.nil? || source_owner.nil?
// 592:
// 593:           author = identity_users[source_owner.downcase] || commit_authors[parents.fetch(1)]
// 594:           if author
// 595:             increment_contribution_count(counts.fetch(author), :merged_pr_author)
// 596:             authored_pull_requests&.fetch(author)&.add(pull_request_id)
// 597:           end
// 598:           increment_contribution_count(counts.fetch(merger), :merged_pr_merger) if merger
// 599:           [author, merger].compact.uniq.each do |user|
// 600:             increment_contribution_count(counts.fetch(user), :merged_pr)
// 601:             merged_pull_requests&.fetch(user)&.add(pull_request_id)
// 602:           end
// 603:         end
// 604:
// 605:         counts
// 606:       end
// 607:
// 608:       private
// 609:
// 610:       sig {
// 611:         params(
// 612:           results:                T::Hash[String, T::Hash[String, T::Hash[Symbol, Integer]]],
// 613:           grand_totals:           T::Hash[String, T::Hash[Symbol, Integer]],
// 614:           user_names:             T::Hash[String, String],
// 615:           lead_maintainers:       T::Hash[String, T::Boolean],
// 616:           maintainer_since_dates: T::Hash[String, T.nilable(String)],
// 617:           to:                     String,
// 618:         ).returns(String)
// 619:       }
// 620:       def generate_maintainer_report_csv(results, grand_totals, user_names, lead_maintainers, maintainer_since_dates,
// 621:                                          to)
// 622:         require "csv"
// 623:
// 624:         rows = results.sort_by do |user, _|
// 625:           qualifying_total = contribution_count(grand_totals.fetch(user).slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 626:           [-qualifying_total, user.downcase]
// 627:         end
// 628:         rows.map! do |user, user_repositories|
// 629:           grand_total = grand_totals.fetch(user)
// 630:           repository_qualifying_totals = user_repositories.transform_values do |counts|
// 631:             contribution_count(counts.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 632:           end
// 633:           qualifying_total = contribution_count(grand_total.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 634:           maintainer_activity_met = qualifying_total >= MAINTAINER_ACTIVITY_THRESHOLD
// 635:           maintainer_since = maintainer_since_dates.fetch(user)
// 636:           maintainer_since_date = Date.iso8601(maintainer_since) if maintainer_since
// 637:           period_end = Date.iso8601(to)
// 638:           lead_maintainer = lead_maintainers.key?(user.downcase)
// 639:           lead_activity_met = lead_activity_met?(user_repositories)
// 640:           new_role = if lead_activity_met &&
// 641:                         (lead_maintainer ||
// 642:                          (maintainer_since_date && maintainer_since_date <= period_end.prev_year(3)))
// 643:             "Lead Maintainer"
// 644:           elsif maintainer_activity_met
// 645:             "Maintainer"
// 646:           else
// 647:             "None"
// 648:           end
// 649:
// 650:           capped = grand_total.fetch(:merged_pr_author_hit_cap, 0).positive? ||
// 651:                    grand_total.fetch(:approved_pr_review_hit_cap, 0).positive?
// 652:           capped ||= user_repositories.any? do |_, counts|
// 653:             counts.fetch(:approved_pr_review) >= MAX_PR_SEARCH ||
// 654:               counts.except(:approved_pr_review).values.any? do |count|
// 655:                 count >= MAX_CONTRIBUTIONS
// 656:               end
// 657:           end
// 658:
// 659:           [
// 660:             user,
// 661:             user_names.fetch(user),
// 662:             maintainer_since,
// 663:             maintainer_since_date ? [(period_end - maintainer_since_date).to_i, 0].max : nil,
// 664:             *PRIMARY_REPOS.flat_map do |repository|
// 665:               counts = user_repositories.fetch(repository)
// 666:               [*counts.values_at(*CONTRIBUTION_TYPES.keys), repository_qualifying_totals.fetch(repository)]
// 667:             end,
// 668:             qualifying_total,
// 669:             maintainer_activity_met,
// 670:             lead_activity_met,
// 671:             capped,
// 672:             lead_maintainer ? "Lead Maintainer" : "Maintainer",
// 673:             new_role,
// 674:           ]
// 675:         end
// 676:         CSV.generate do |csv|
// 677:           csv << [
// 678:             "username", "name", "since", "tenure days",
// 679:             *PRIMARY_REPOS.flat_map do |repository|
// 680:               repository = repository.delete_prefix("Homebrew/").delete_prefix("homebrew-")
// 681:               [
// 682:                 "#{repository} authored", "#{repository} merged", "#{repository} PRs",
// 683:                 "#{repository} reviews", "#{repository} coauthored", "#{repository} total"
// 684:               ]
// 685:             end,
// 686:             "total", "maintainer met", "lead met", "capped", "role", "new role"
// 687:           ]
// 688:           rows.each { |row| csv << row }
// 689:         end
// 690:       end
// 691:
// 692:       sig { params(repositories: T::Array[String], required: T::Boolean).returns(T::Hash[String, [Pathname, String]]) }
// 693:       def prepare_contribution_repositories(repositories, required:)
// 694:         require "utils/git"
// 695:
// 696:         repository_refs = T.let({}, T::Hash[String, [Pathname, String]])
// 697:         repositories.each do |repository|
// 698:           repository_path, tap = repository_path_and_tap(repository)
// 699:           if repository_path && tap && !repository_path.exist?
// 700:             opoo "Repository #{repository} not yet tapped! Tapping it now..."
// 701:             tap.install(force: true)
// 702:           end
// 703:           unless repository_path&.exist?
// 704:             odie "Could not find a local Git repository for #{repository}." if required
// 705:             next
// 706:           end
// 707:
// 708:           $stderr.puts "Fetching latest commits for #{repository}..."
// 709:           system_command!(Utils::Git.git,
// 710:                           args:         ["-C", repository_path, "fetch", "--quiet", "--force", "origin",
// 711:                                          "+refs/heads/*:refs/remotes/origin/*"],
// 712:                           print_stderr: false)
// 713:           system_command!(Utils::Git.git,
// 714:                           args:         ["-C", repository_path, "remote", "set-head", "origin", "--auto"],
// 715:                           print_stderr: false)
// 716:
// 717:           repository_refs[repository] = [repository_path, "origin/HEAD"]
// 718:         end
// 719:         repository_refs
// 720:       end
// 721:
// 722:       sig { params(readme: String, user: String, name: String).returns(T::Boolean) }
// 723:       def readme_mentions?(readme, user, name)
// 724:         readme = readme.dup.force_encoding(Encoding::UTF_8)
// 725:         readme.include?("https://github.com/#{user}") || readme.include?(name)
// 726:       end
// 727:
// 728:       sig {
// 729:         params(
// 730:           pull_request:           T::Hash[String, T.untyped],
// 731:           authored_pull_requests: T::Set[String],
// 732:           merged_pull_requests:   T::Set[String],
// 733:         ).void
// 734:       }
// 735:       def add_merged_pull_request_id(pull_request, authored_pull_requests, merged_pull_requests)
// 736:         number = pull_request["number"]
// 737:         return unless number.is_a?(Integer)
// 738:
// 739:         pull_request_id = number.to_s
// 740:         authored_pull_requests << pull_request_id
// 741:         merged_pull_requests << pull_request_id
// 742:       end
// 743:
// 744:       sig {
// 745:         params(
// 746:           counts:                 T::Hash[Symbol, Integer],
// 747:           authored_pull_requests: T::Set[String],
// 748:           merged_pull_requests:   T::Set[String],
// 749:         ).void
// 750:       }
// 751:       def update_merged_pull_request_counts(counts, authored_pull_requests, merged_pull_requests)
// 752:         unless authored_pull_requests.empty?
// 753:           counts[:merged_pr_author] = [authored_pull_requests.length, MAX_CONTRIBUTIONS].min
// 754:         end
// 755:         return if merged_pull_requests.empty?
// 756:
// 757:         counts[:merged_pr] = [merged_pull_requests.length, MAX_CONTRIBUTIONS].min
// 758:       end
// 759:
// 760:       sig {
// 761:         params(name: String, email: String, identity_users: T::Hash[String, String]).returns(T.nilable(String))
// 762:       }
// 763:       def user_for_git_identity(name, email, identity_users)
// 764:         identity_users[name.strip.downcase] ||
// 765:           identity_users[email.downcase] ||
// 766:           identity_users[email.split("@").first.to_s.sub(/\A\d+\+/, "").downcase]
// 767:       end
// 768:
// 769:       sig { params(counts: T::Hash[Symbol, Integer], type: Symbol).void }
// 770:       def increment_contribution_count(counts, type)
// 771:         count = counts.fetch(type)
// 772:         counts[type] = count + 1 if count < MAX_CONTRIBUTIONS
// 773:       end
// 774:
// 775:       sig { params(repository: String).returns([T.nilable(Pathname), T.nilable(Tap)]) }
// 776:       def repository_path_and_tap(repository)
// 777:         return [HOMEBREW_REPOSITORY, nil] if repository == "Homebrew/brew"
// 778:         return [nil, nil] if repository.exclude?("/homebrew-")
// 779:
// 780:         require "tap"
// 781:         tap = Tap.fetch(repository)
// 782:         return [nil, nil] if tap.user == "Homebrew" && DEPRECATED_OFFICIAL_TAPS.include?(tap.repository)
// 783:
// 784:         [tap.path, tap]
// 785:       end
// 786:
// 787:       sig { params(from: T.nilable(String), to: T.nilable(String)).returns(String) }
// 788:       def time_period(from:, to:)
// 789:         if from && to
// 790:           "between #{from} and #{to}"
// 791:         elsif from
// 792:           "after #{from}"
// 793:         elsif to
// 794:           "before #{to}"
// 795:         else
// 796:           "in all time"
// 797:         end
// 798:       end
// 799:
// 800:       sig { params(totals: T::Hash[String, T::Hash[Symbol, Integer]]).returns(String) }
// 801:       def generate_csv(totals)
// 802:         require "csv"
// 803:
// 804:         CSV.generate do |csv|
// 805:           csv << %w[username repo authored merged PRs reviews coauthored total]
// 806:
// 807:           totals.sort_by { |_, counts| -contribution_count(counts.slice(*QUALIFYING_CONTRIBUTION_TYPES)) }
// 808:                 .each do |user, total|
// 809:             csv << grand_total_row(user, total)
// 810:           end
// 811:         end
// 812:       end
// 813:
// 814:       sig { params(user: String, grand_total: T::Hash[Symbol, Integer]).returns(T::Array[T.any(String, T.nilable(Integer))]) }
// 815:       def grand_total_row(user, grand_total)
// 816:         grand_totals = grand_total.slice(*CONTRIBUTION_TYPES.keys).values
// 817:         qualifying_total = contribution_count(grand_total.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 818:         [user, "all", *grand_totals, qualifying_total]
// 819:       end
// 820:
// 821:       sig { params(results: T::Hash[String, T::Hash[Symbol, Integer]]).returns(T::Hash[Symbol, Integer]) }
// 822:       def total(results)
// 823:         totals = {}
// 824:
// 825:         results.each_value do |counts|
// 826:           counts.each do |kind, count|
// 827:             totals[kind] ||= 0
// 828:             totals[kind] += count
// 829:           end
// 830:         end
// 831:
// 832:         totals
// 833:       end
// 834:
// 835:       sig { params(contributions: T::Hash[Symbol, Integer]).returns(Integer) }
// 836:       def contribution_count(contributions)
// 837:         contributions.values.sum
// 838:       end
// 839:
// 840:       sig { params(repositories: T::Hash[String, T::Hash[Symbol, Integer]]).returns(T::Boolean) }
// 841:       def lead_activity_met?(repositories)
// 842:         repositories.count do |_, counts|
// 843:           contribution_count(counts.slice(*QUALIFYING_CONTRIBUTION_TYPES)) >= LEAD_REPOSITORY_ACTIVITY_THRESHOLD
// 844:         end >= 2
// 845:       end
// 846:
// 847:       sig { params(quarter: Integer, current_year: Integer).returns([String, String]) }
// 848:       def reporting_quarter_dates(quarter, current_year = Date.today.year)
// 849:         # These aren't standard quarterly dates. We've chosen our own so that we
// 850:         # can use recent maintainer activity stats as part of checking
// 851:         # eligibility for expensed attendance at the AGM in February each year.
// 852:         last_year = current_year - 1
// 853:         dates = {
// 854:           1 => [Date.new(last_year, 12, 1).iso8601, Date.new(current_year, 3, 1).iso8601],
// 855:           2 => [Date.new(current_year, 3, 1).iso8601, Date.new(current_year,  6, 1).iso8601],
// 856:           3 => [Date.new(current_year, 6, 1).iso8601, Date.new(current_year,  9, 1).iso8601],
// 857:           4 => [Date.new(current_year, 9, 1).iso8601, Date.new(current_year, 12, 1).iso8601],
// 858:         }
// 859:         dates.fetch(quarter)
// 860:       end
// 861:     end
// 862:   end
// 863: end
