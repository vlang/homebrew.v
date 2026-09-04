module dev_cmd

import ruby
import crypto.sha256
import json2
import os
import time

// Translated from Homebrew/brew `dev-cmd/contributions.rb`.

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

fn contribution_nil() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn contribution_error(message string) ruby.Value {
	return ruby.structured_value('Error', message, {
		'message': message
	})
}

fn contribution_map_string(values map[string]ruby.Value, key string, fallback string) string {
	return (values[key] or { ruby.string_value(fallback) }).as_string()
}

fn contribution_map_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	value := values[key] or { return fallback }
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn contribution_map_int(values map[string]ruby.Value, key string, fallback int) int {
	value := values[key] or { return fallback }
	return if value.type_name == 'Integer' { int(value.int_data) } else { fallback }
}

fn contribution_string_map_from_value(value ruby.Value) map[string]string {
	mut output := map[string]string{}
	for key, item in value.map_data {
		output[key] = item.as_string()
	}
	return output
}

fn contribution_string_array_map_from_value(value ruby.Value) map[string][]string {
	mut output := map[string][]string{}
	for key, item in value.map_data {
		output[key] = item.string_array_data.clone()
	}
	return output
}

fn contribution_bool_map_from_value(value ruby.Value) map[string]bool {
	mut output := map[string]bool{}
	for key, item in value.map_data {
		output[key] = item.bool_data
	}
	return output
}

fn contribution_counts_from_value(value ruby.Value) map[string]int {
	mut output := map[string]int{}
	for key, item in value.map_data {
		output[key] = int(item.int_data)
	}
	return output
}

fn contribution_counts_value(counts map[string]int) ruby.Value {
	mut output := map[string]ruby.Value{}
	for key, count in counts {
		output[key] = ruby.int_value(count)
	}
	return ruby.map_value(output)
}

fn contribution_totals_from_value(value ruby.Value) map[string]map[string]int {
	mut output := map[string]map[string]int{}
	for key, item in value.map_data {
		output[key] = contribution_counts_from_value(item)
	}
	return output
}

fn contribution_totals_value(totals map[string]map[string]int) ruby.Value {
	mut output := map[string]ruby.Value{}
	for key, counts in totals {
		output[key] = contribution_counts_value(counts)
	}
	return ruby.map_value(output)
}

fn contribution_pull_request_value(pull_request ContributionPullRequest) ruby.Value {
	return ruby.map_value({
		'number':     ruby.int_value(pull_request.number)
		'repository': ruby.string_value(pull_request.repository)
	})
}

fn contribution_pull_request_from_value(value ruby.Value) ContributionPullRequest {
	return ContributionPullRequest{
		number: contribution_map_int(value.map_data, 'number', -1)
		repository: contribution_map_string(value.map_data, 'repository', '')
	}
}

fn contribution_pull_request_map_from_value(value ruby.Value) map[string][]ContributionPullRequest {
	mut output := map[string][]ContributionPullRequest{}
	for key, item in value.map_data {
		output[key] = item.array_data.map(contribution_pull_request_from_value(it))
	}
	return output
}

fn contribution_change_value(change ContributionMaintainerChange) ruby.Value {
	return ruby.map_value({
		'commit':        ruby.string_value(change.commit)
		'date':          ruby.string_value(change.date)
		'readme':        ruby.string_value(change.readme)
		'parent_readme': ruby.string_value(change.parent_readme)
	})
}

fn contribution_change_from_value(value ruby.Value) ContributionMaintainerChange {
	return ContributionMaintainerChange{
		commit: contribution_map_string(value.map_data, 'commit', '')
		date: contribution_map_string(value.map_data, 'date', '')
		readme: contribution_map_string(value.map_data, 'readme', '')
		parent_readme: contribution_map_string(value.map_data, 'parent_readme', '')
	}
}

fn contribution_repository_ref_value(reference ContributionRepositoryRef) ruby.Value {
	return ruby.Value{
		type_name: 'RepositoryRef'
		repr: reference.repository
		map_data: {
			'repository':     ruby.string_value(reference.repository)
			'path':           ruby.string_value(reference.path)
			'ref':            ruby.string_value(reference.ref)
			'exists':         ruby.bool_value(reference.exists)
			'tap_available':  ruby.bool_value(reference.tap_available)
			'deprecated':     ruby.bool_value(reference.deprecated)
			'git_log':        ruby.string_value(reference.git_log)
			'readme':         ruby.string_value(reference.readme)
			'maintainer_log': ruby.array_value(reference.maintainer_log.map(contribution_change_value(it)))
		}
	}
}

fn contribution_repository_ref_from_value(value ruby.Value) ContributionRepositoryRef {
	changes := (value.map_data['maintainer_log'] or { ruby.array_value([]) }).array_data.map(contribution_change_from_value(it))
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

fn contribution_repository_counts_value(result ContributionRepositoryCounts) ruby.Value {
	return ruby.map_value({
		'repository': ruby.string_value(result.repository)
		'counts':     contribution_counts_value(result.counts)
	})
}

fn contribution_repository_counts_from_value(value ruby.Value) ContributionRepositoryCounts {
	return ContributionRepositoryCounts{
		repository: contribution_map_string(value.map_data, 'repository', '')
		counts: contribution_counts_from_value(value.map_data['counts'] or { ruby.map_value({}) })
	}
}

fn contribution_user_result_value(result ContributionUserResult) ruby.Value {
	return ruby.map_value({
		'user':         ruby.string_value(result.user)
		'repositories': ruby.array_value(result.repositories.map(contribution_repository_counts_value(it)))
	})
}

fn contribution_user_result_from_value(value ruby.Value) ContributionUserResult {
	return ContributionUserResult{
		user: contribution_map_string(value.map_data, 'user', '')
		repositories: (value.map_data['repositories'] or { ruby.array_value([]) }).array_data.map(contribution_repository_counts_from_value(it))
	}
}

fn contribution_results_value(results []ContributionUserResult) ruby.Value {
	return ruby.array_value(results.map(contribution_user_result_value(it)))
}

fn contribution_results_from_value(value ruby.Value) []ContributionUserResult {
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

fn contribution_run_request_from_value(value ruby.Value) ContributionRunRequest {
	values := value.map_data.clone()
	return ContributionRunRequest{
		maintainer_report_csv: contribution_map_string(values, 'maintainer_report_csv', '')
		requested_users: (values['requested_users'] or { ruby.string_array_value([]) }).string_array_data.clone()
		no_github_api: contribution_map_bool(values, 'no_github_api', false)
		csv: contribution_map_bool(values, 'csv', false)
		quarter: contribution_map_int(values, 'quarter', 0)
		quarter_supplied: contribution_map_bool(values, 'quarter_supplied', false)
		from: contribution_map_string(values, 'from', '')
		to: contribution_map_string(values, 'to', '')
		verbose: contribution_map_bool(values, 'verbose', false)
		organisation: contribution_map_string(values, 'organisation', '')
		team: contribution_map_string(values, 'team', '')
		users: contribution_string_map_from_value(values['users'] or { ruby.map_value({}) })
		repositories: (values['repositories'] or { ruby.string_array_value([]) }).string_array_data.clone()
		organisation_repos: (values['organisation_repos'] or { ruby.string_array_value([]) }).string_array_data.clone()
		repository_sources: (values['repository_sources'] or { ruby.array_value([]) }).array_data.map(contribution_repository_ref_from_value(it))
		github_users: contribution_string_map_from_value(values['github_users'] or { ruby.map_value({}) })
		github_email_matches: contribution_string_array_map_from_value(values['github_email_matches'] or { ruby.map_value({}) })
		authored_pull_requests: contribution_pull_request_map_from_value(values['authored_pull_requests'] or { ruby.map_value({}) })
		approved_pull_requests: contribution_pull_request_map_from_value(values['approved_pull_requests'] or { ruby.map_value({}) })
		current_year: contribution_map_int(values, 'current_year', 0)
		current_date: contribution_map_string(values, 'current_date', '')
	}
}

fn contribution_run_result_value(result ContributionRunResult) ruby.Value {
	mut users := map[string]ruby.Value{}
	for user, name in result.users {
		users[user] = ruby.string_value(name)
	}
	return ruby.map_value({
		'from':         ruby.string_value(result.from)
		'to':           ruby.string_value(result.to)
		'organisation': ruby.string_value(result.organisation)
		'users':        ruby.map_value(users)
		'repositories': ruby.string_array_value(result.repositories)
		'results':      contribution_results_value(result.results)
		'grand_totals': contribution_totals_value(result.grand_totals)
		'summaries':    ruby.string_array_value(result.summaries)
		'csv':          ruby.string_value(result.csv)
		'output_name':  ruby.string_value(result.output_name)
		'progress':     ruby.string_array_value(result.progress)
	})
}
