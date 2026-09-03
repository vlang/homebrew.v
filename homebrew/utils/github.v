module utils

import time
import x.json2

// Translated from Homebrew/brew `utils/github.rb`.
// The original source is retained below until every stub has a typed V body.
pub const github_api_url = 'https://api.github.com'
pub const github_max_per_page = 100
pub const github_api_max_items = 5000
pub const github_maximum_open_prs = 15
pub const github_create_gist_scopes = ['gist']
pub const github_create_issue_fork_or_pr_scopes = ['repo']

pub struct GitHubQualifier {
pub:
	key    string
	values []string
}

pub struct GitHubRestRequest {
pub:
	url              string
	data             json2.Any = json2.null
	data_binary_path string
	request_method   string
	scopes           []string
	per_page         int = github_max_per_page
	additional_query string
}

pub struct GitHubGraphqlRequest {
pub:
	query        string
	variables    map[string]json2.Any
	scopes       []string
	raise_errors bool = true
}

pub struct GitHubCurlRequest {
pub:
	url         string
	headers     []string
	output_null bool
	write_out   string
}

pub struct GitHubCurlResponse {
pub:
	success bool
	stdout  string
}

pub type GitHubOpenRest = fn(GitHubRestRequest) !json2.Any

pub type GitHubOpenGraphql = fn(GitHubGraphqlRequest) !json2.Any

pub type GitHubPaginateRest = fn(GitHubRestRequest) ![]json2.Any

pub type GitHubPaginateGraphql = fn(GitHubGraphqlRequest) ![]json2.Any

pub type GitHubCurl = fn(GitHubCurlRequest) !GitHubCurlResponse

pub type GitHubWarning = fn(string)

pub type GitHubVersionUpdate = fn(string)

pub fn github_unavailable_rest(request GitHubRestRequest) !json2.Any {
	return error('GitHub REST transport unavailable for ${request.url}')
}

pub fn github_unavailable_graphql(_ GitHubGraphqlRequest) !json2.Any {
	return error('GitHub GraphQL transport unavailable')
}

pub fn github_unavailable_paginate_rest(request GitHubRestRequest) ![]json2.Any {
	return error('GitHub REST pagination transport unavailable for ${request.url}')
}

pub fn github_unavailable_paginate_graphql(_ GitHubGraphqlRequest) ![]json2.Any {
	return error('GitHub GraphQL pagination transport unavailable')
}

pub fn github_unavailable_curl(request GitHubCurlRequest) !GitHubCurlResponse {
	return error('GitHub curl transport unavailable for ${request.url}')
}

pub fn github_ignore_warning(_ string) {}

pub fn github_ignore_version_update(_ string) {}

pub struct GitHubClient {
pub:
	open_rest        GitHubOpenRest = github_unavailable_rest
	open_graphql     GitHubOpenGraphql = github_unavailable_graphql
	paginate_rest    GitHubPaginateRest = github_unavailable_paginate_rest
	paginate_graphql GitHubPaginateGraphql = github_unavailable_paginate_graphql
	curl             GitHubCurl = github_unavailable_curl
	warn             GitHubWarning = github_ignore_warning
	update_version   GitHubVersionUpdate = github_ignore_version_update
	no_github_api    bool
	credentials_type string = 'none'
	environment      map[string]string
	now              i64
pub mut:
	user_cache      ?json2.Any
	open_pull_cache map[string][]map[string]json2.Any
}

pub struct GitHubWorkflowArray {
pub:
	check_suite      []map[string]json2.Any
	user             string
	repo             string
	pull_request     string
	workflow_id      string
	scopes           []string
	artifact_pattern string
}

pub struct GitHubSponsorship {
pub:
	closest_tier_monthly_amount int
	login                       string
	monthly_amount              int
	name                        string
}

pub struct GitHubPullRequestPattern {
pub:
	name    string
	version string
}

pub struct GitHubDuplicateOptions {
pub:
	file         string
	quiet        bool
	state        string
	version      string
	official_tap bool = true
	strict       bool
}

pub struct GitHubOptionalString {
pub:
	present bool
	value   string
}

fn github_any_map(value json2.Any) !map[string]json2.Any {
	if value is map[string]json2.Any {
		return value.clone()
	}
	return error('expected GitHub object')
}

fn github_any_array(value json2.Any) ![]json2.Any {
	if value is []json2.Any {
		return value.clone()
	}
	return error('expected GitHub array')
}

fn github_map_array(value json2.Any) ![]map[string]json2.Any {
	return github_any_array(value)!.map(github_any_map(it)!)
}

fn github_string(value json2.Any) string {
	if value is json2.Null {
		return ''
	}
	return value.str()
}

fn github_int(value json2.Any) int {
	if value is int {
		return value
	}
	if value is i64 {
		return int(value)
	}
	return github_string(value).int()
}

fn github_bool(value json2.Any) bool {
	if value is bool {
		return value
	}
	return github_string(value) == 'true'
}

fn github_present(value json2.Any) bool {
	if value is json2.Null {
		return false
	}
	if value is string {
		return value.len > 0
	}
	if value is []json2.Any {
		return value.len > 0
	}
	if value is map[string]json2.Any {
		return value.len > 0
	}
	return true
}

fn github_rate_limit_error(err IError) bool {
	return err.msg().starts_with('RateLimitExceededError:')
}

fn github_ip_allowlist_error(err IError) bool {
	message := err.msg()
	return message.contains('Although you appear to have the correct authorization credentials, ') && message.contains('organization has an IP allow list enabled, ') && message.contains('your IP address is not permitted to access this resource')
}

fn github_object_get(object map[string]json2.Any, key string) json2.Any {
	return object[key] or { json2.null }
}

fn github_nested(value json2.Any, keys ...string) json2.Any {
	mut current := value
	for key in keys {
		object := github_any_map(current) or { return json2.null }
		current = github_object_get(object, key)
	}
	return current
}

fn github_strings_any(values []string) json2.Any {
	return json2.Any(values.map(json2.Any(it)))
}

fn github_url_component(value string, path bool) string {
	mut result := ''
	for character in value.bytes() {
		if (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character in [
			`-`,
			`_`,
			`.`,
		] || (path && character == `~`) || (!path && character == `*`) {
			result += character.ascii_str()
		} else if !path && character == ` ` {
			result += '+'
		} else {
			result += '%${character:02X}'
		}
	}
	return result
}

pub fn github_url_to(subroutes ...string) string {
	mut routes := [github_api_url]
	routes << subroutes
	return routes.join('/')
}

pub fn github_search_query_string(main_params []string, qualifiers []GitHubQualifier,
	from string, to string) string {
	mut params := main_params.clone()
	if from != '' && to != '' {
		params << 'created:${from}..${to}'
	} else if from != '' {
		params << 'created:>=${from}'
	} else if to != '' {
		params << 'created:<=${to}'
	}
	for qualifier in qualifiers {
		for value in qualifier.values {
			params << '${qualifier.key.replace('_', '-')}:${value}'
		}
	}
	return 'q=${github_url_component(params.join(' '), false)}&per_page=${github_max_per_page}'
}

pub fn (mut client GitHubClient) issues(repo string, filters []GitHubQualifier) ![]map[string]json2.Any {
	mut query_parts := []string{}
	for filter in filters {
		for value in filter.values {
			query_parts << '${github_url_component(filter.key, false)}=${github_url_component(value, false)}'
		}
	}
	query := query_parts.join('&')
	response := client.open_rest(GitHubRestRequest{
		url: '${github_url_to('repos', repo, 'issues')}?${query}'
	})!
	return github_map_array(response)
}

pub fn (mut client GitHubClient) search(entity string, queries []string,
	qualifiers []GitHubQualifier, from string, to string) !map[string]json2.Any {
	uri := '${github_url_to('search', entity)}?${github_search_query_string(queries, qualifiers, from, to)}'
	return github_any_map(client.open_rest(GitHubRestRequest{ url: uri })!)
}

pub fn (mut client GitHubClient) search_issues(query string, qualifiers []GitHubQualifier,
	from string, to string) ![]map[string]json2.Any {
	json := client.search('issues', [query], qualifiers, from, to)!
	items := json['items'] or { return []map[string]json2.Any{} }
	return github_map_array(items)
}

pub fn (mut client GitHubClient) create_gist(files map[string]string, description string,
	private bool) !string {
	mut file_data := map[string]json2.Any{}
	for filename, content in files {
		file_data[filename] = json2.Any({
			'content': json2.Any(content)
		})
	}
	public_gist := !private
	response := github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('gists')
		data: json2.Any({
			'public':      json2.Any(public_gist)
			'files':       json2.Any(file_data)
			'description': json2.Any(description)
		})
		scopes: github_create_gist_scopes
	})!)!
	return github_string(github_object_get(response, 'html_url'))
}

pub fn (mut client GitHubClient) create_issue(repo string, title string, body string) !string {
	response := github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', repo, 'issues')
		data: json2.Any({
			'title': json2.Any(title)
			'body':  json2.Any(body)
		})
		scopes: github_create_issue_fork_or_pr_scopes
	})!)!
	return github_string(github_object_get(response, 'html_url'))
}

pub fn (mut client GitHubClient) create_issue_comment(repo string, issue string,
	body string) !map[string]json2.Any {
	return github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', repo, 'issues', issue, 'comments')
		data: json2.Any({
			'body': json2.Any(body)
		})
		scopes: github_create_issue_fork_or_pr_scopes
	})!)
}

pub fn (mut client GitHubClient) repository(user string, repo string) !map[string]json2.Any {
	return github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', user, repo)
	})!)
}

pub fn (mut client GitHubClient) issues_for_formula(name string, tap_remote_repo string,
	state string, issue_type string) ![]map[string]json2.Any {
	if tap_remote_repo == '' {
		return []map[string]json2.Any{}
	}
	mut qualifiers := [GitHubQualifier{ key: 'repo', values: [tap_remote_repo] }]
	if state != '' { qualifiers << GitHubQualifier{ key: 'state', values: [state] } }
	if issue_type != '' {
		qualifiers << GitHubQualifier{
			key: 'type'
			values: [
				issue_type,
			]
		}
	}
	qualifiers << GitHubQualifier{ key: 'in', values: ['title'] }
	return client.search_issues(name, qualifiers, '', '')
}

pub fn (mut client GitHubClient) user() !map[string]json2.Any {
	if cached := client.user_cache {
		return github_any_map(cached)
	}
	response := client.open_rest(GitHubRestRequest{ url: github_url_to('user') })!
	client.user_cache = response
	return github_any_map(response)
}

pub fn (mut client GitHubClient) print_pull_requests_matching(query string, only string) !string {
	mut qualifiers := []GitHubQualifier{}
	if only != '' { qualifiers << GitHubQualifier{ key: 'is', values: [only] } }
	qualifiers << GitHubQualifier{ key: 'type', values: ['pr'] }
	qualifiers << GitHubQualifier{ key: 'user', values: ['Homebrew'] }
	prs := client.search_issues(query, qualifiers, '', '')!
	mut open_prs := []string{}
	mut closed_prs := []string{}
	for pr in prs {
		line := '${github_string(github_object_get(pr, 'title'))} (${github_string(github_object_get(pr, 'html_url'))})'
		if github_string(github_object_get(pr, 'state')) == 'open' {
			open_prs << line
		} else {
			closed_prs << line
		}
	}
	mut lines := []string{}
	if open_prs.len > 0 {
		lines << '==> Open pull requests'
		lines << open_prs
	}
	if closed_prs.len > 0 {
		if open_prs.len > 0 { lines << '' }
		lines << '==> Closed pull requests'
		lines << closed_prs[..if closed_prs.len < 20 { closed_prs.len } else { 20 }]
		if closed_prs.len > 20 { lines << '...' }
	}
	if open_prs.len == 0 && closed_prs.len == 0 { lines << 'No pull requests found for "${query}"' }
	return lines.join('\n') + '\n'
}

pub fn (mut client GitHubClient) create_fork(repo string, org string) !map[string]json2.Any {
	mut data := map[string]json2.Any{}
	if org != '' {
		data['organization'] = json2.Any(org)
	}
	return github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', repo, 'forks')
		data: json2.Any(data)
		scopes: github_create_issue_fork_or_pr_scopes
	})!)
}

pub fn (mut client GitHubClient) fork_exists(repo string, org string) !bool {
	parts := repo.split('/')
	if parts.len < 2 {
		return error('key not found: 1')
	}
	username := if org != '' {
		org
	} else {
		user_response := github_any_map(client.open_rest(GitHubRestRequest{ url: github_url_to('user') })!)!
		github_string(github_object_get(user_response, 'login'))
	}
	response := github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', username, parts[1])
	})!)!
	return github_string(github_object_get(response, 'message')) != 'Not Found'
}

pub fn (mut client GitHubClient) create_pull_request(repo string, title string, head string,
	base string, body string) !map[string]json2.Any {
	return github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', repo, 'pulls')
		data: json2.Any({
			'title':                 json2.Any(title)
			'head':                  json2.Any(head)
			'base':                  json2.Any(base)
			'body':                  json2.Any(body)
			'maintainer_can_modify': json2.Any(true)
		})
		scopes: github_create_issue_fork_or_pr_scopes
	})!)
}

pub fn (mut client GitHubClient) private_repo(full_name string) !bool {
	response := github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', full_name)
	})!)!
	return if private := response['private'] { github_bool(private) } else { true }
}

pub fn (mut client GitHubClient) repository_approved_reviews(user string, repo string,
	pull_request string, commit string) ![]map[string]json2.Any {
	query := '{ repository(name: "${repo}", owner: "${user}") {\n    pullRequest(number: ${pull_request}) {\n      reviews(states: APPROVED, first: 100) {\n        nodes {\n          author {\n            ... on User { email login name databaseId }\n            ... on Organization { email login name databaseId }\n          }\n          authorAssociation\n          commit { oid }\n        }\n      }\n    }\n  }\n}\n'
	result := client.open_graphql(GitHubGraphqlRequest{
		query: query
		scopes: [
			'user:email',
		]
	})!
	reviews := github_map_array(github_nested(result, 'repository', 'pullRequest', 'reviews', 'nodes'))!
	mut output := []map[string]json2.Any{}
	for review in reviews {
		if commit != '' && commit != github_string(github_nested(json2.Any(review), 'commit', 'oid')) {
			continue
		}
		association := github_string(github_object_get(review, 'authorAssociation'))
		if association !in ['MEMBER', 'OWNER'] {
			continue
		}
		author := github_any_map(github_object_get(review, 'author'))!
		login := github_string(github_object_get(author, 'login'))
		database_id := github_string(github_object_get(author, 'databaseId'))
		email := github_string(github_object_get(author, 'email'))
		name := github_string(github_object_get(author, 'name'))
		output << {
			'email': json2.Any(if email != '' {
				email
			} else {
				'${database_id}+${login}@users.noreply.github.com'
			})
			'name':  json2.Any(if name != '' { name } else { login })
			'login': json2.Any(login)
		}
	}
	return output
}

pub fn (mut client GitHubClient) workflow_dispatch_event(user string, repo string,
	workflow string, ref string, inputs map[string]json2.Any) ! {
	client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', user, repo, 'actions', 'workflows', workflow, 'dispatches')
		data: json2.Any({
			'ref':    json2.Any(ref)
			'inputs': json2.Any(inputs)
		})
		request_method: 'POST'
		scopes: github_create_issue_fork_or_pr_scopes
	})!
}

pub fn (mut client GitHubClient) get_release(user string, repo string,
	tag string) !map[string]json2.Any {
	return github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', user, repo, 'releases', 'tags', tag)
		request_method: 'GET'
	})!)
}

pub fn (mut client GitHubClient) get_latest_release(user string,
	repo string) !map[string]json2.Any {
	return github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', user, repo, 'releases', 'latest')
		request_method: 'GET'
	})!)
}

pub fn (mut client GitHubClient) generate_release_notes(user string, repo string, tag string,
	previous_tag string) !map[string]json2.Any {
	mut data := {
		'tag_name': json2.Any(tag)
	}
	if previous_tag != '' {
		data['previous_tag_name'] = json2.Any(previous_tag)
	}
	return github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', user, repo, 'releases', 'generate-notes')
		data: json2.Any(data)
		request_method: 'POST'
		scopes: github_create_issue_fork_or_pr_scopes
	})!)
}

pub fn (mut client GitHubClient) create_or_update_release(user string, repo string,
	tag string, id string, name string, body string, draft bool) !map[string]json2.Any {
	mut url := github_url_to('repos', user, repo, 'releases')
	method := if id != '' {
		url += '/${id}'
		'PATCH'
	} else {
		'POST'
	}
	mut data := {
		'tag_name': json2.Any(tag)
		'name':     json2.Any(if name != '' { name } else { tag })
		'draft':    json2.Any(draft)
	}
	if body != '' {
		data['body'] = json2.Any(body)
	}
	return github_any_map(client.open_rest(GitHubRestRequest{
		url: url
		data: json2.Any(data)
		request_method: method
		scopes: github_create_issue_fork_or_pr_scopes
	})!)
}

pub fn (mut client GitHubClient) upload_release_asset(user string, repo string, id int,
	local_file string, remote_file string) ! {
	mut url := 'https://uploads.github.com/repos/${user}/${repo}/releases/${id}/assets'
	if remote_file != '' {
		url += '?name=${remote_file}'
	}
	client.open_rest(GitHubRestRequest{
		url: url
		data_binary_path: local_file
		request_method: 'POST'
		scopes: github_create_issue_fork_or_pr_scopes
	})!
}

pub fn (mut client GitHubClient) get_workflow_run(user string, repo string,
	pull_request string, workflow_id string, artifact_pattern string,
	head_sha string) !GitHubWorkflowArray {
	scopes := github_create_issue_fork_or_pr_scopes
	workflow_payload := github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', user, repo, 'actions', 'workflows', workflow_id)
		scopes: scopes
	})!)!
	workflow_number := github_int(github_object_get(workflow_payload, 'id'))
	query := 'query (\$user: String!, \$repo: String!, \$pr: Int!) {\n  repository(owner: \$user, name: \$repo) {\n    pullRequest(number: \$pr) {\n      commits(last: 1) {\n        nodes {\n          commit {\n            oid\n            checkSuites(first: 100) {\n              nodes {\n                status,\n                workflowRun { databaseId, url, workflow { databaseId } }\n              }\n            }\n          }\n        }\n      }\n    }\n  }\n}\n'
	result := client.open_graphql(GitHubGraphqlRequest{
		query: query
		variables: {
			'user': json2.Any(user)
			'repo': json2.Any(repo)
			'pr':   json2.Any(pull_request.int())
		}
		scopes: scopes
	})!
	commit_nodes := github_map_array(github_nested(result, 'repository', 'pullRequest', 'commits', 'nodes'))!
	mut suites := []map[string]json2.Any{}
	if commit_nodes.len > 0 {
		commit := github_any_map(github_object_get(commit_nodes[0], 'commit'))!
		oid := github_string(github_object_get(commit, 'oid'))
		if head_sha != '' && oid.to_lower() != head_sha.to_lower() {
			return error('Pull request #${pull_request} is at ${oid} but expected ${head_sha}.')
		}
		for suite in github_map_array(github_nested(json2.Any(commit), 'checkSuites', 'nodes'))! {
			if github_int(github_nested(json2.Any(suite), 'workflowRun', 'workflow', 'databaseId')) == workflow_number {
				suites << suite
			}
		}
	}
	return GitHubWorkflowArray{
		check_suite: suites
		user: user
		repo: repo
		pull_request: pull_request
		workflow_id: workflow_id
		scopes: scopes
		artifact_pattern: artifact_pattern
	}
}

fn github_wildcard_match(pattern string, value string) bool {
	mut pattern_index := 0
	mut value_index := 0
	mut star := -1
	mut retry := 0
	for value_index < value.len {
		if pattern_index < pattern.len && (pattern[pattern_index] == `?` || pattern[pattern_index] == value[value_index]) {
			pattern_index++
			value_index++
			continue
		}
		if pattern_index < pattern.len && pattern[pattern_index] == `*` {
			star = pattern_index
			pattern_index++
			retry = value_index
			continue
		}
		if star >= 0 {
			pattern_index = star + 1
			retry++
			value_index = retry
			continue
		}
		return false
	}
	for pattern_index < pattern.len && pattern[pattern_index] == `*` {
		pattern_index++
	}
	return pattern_index == pattern.len
}

fn github_artifact_pattern_match(pattern string, value string) bool {
	open := pattern.index('{') or { return github_wildcard_match(pattern, value) }
	close := pattern.index_after('}', open) or { return github_wildcard_match(pattern, value) }
	prefix := pattern[..open]
	suffix := pattern[close + 1..]
	for choice in pattern[open + 1..close].split(',') {
		if github_wildcard_match(prefix + choice + suffix, value) {
			return true
		}
	}
	return false
}

pub fn (mut client GitHubClient) get_artifact_urls(workflow GitHubWorkflowArray) ![]string {
	if workflow.check_suite.len == 0 {
		return error('No matching check suite found for these criteria!\n  Pull request: ${workflow.pull_request}\n  Workflow:     ${workflow.workflow_id}\n')
	}
	last_check := workflow.check_suite.last()
	mut status := github_string(github_object_get(last_check, 'status')).replace_once('_', ' ').to_lower()
	if status != 'completed' {
		url := github_string(github_nested(json2.Any(last_check), 'workflowRun', 'url'))
		return error('The newest workflow run for #${workflow.pull_request} is still ${status}!\n  ${url}\n')
	}
	run_id := github_string(github_nested(json2.Any(last_check), 'workflowRun', 'databaseId'))
	pages := client.paginate_rest(GitHubRestRequest{
		url: github_url_to('repos', workflow.user, workflow.repo, 'actions', 'runs', run_id, 'artifacts')
		per_page: 50
		scopes: workflow.scopes
	})!
	mut artifacts := []map[string]json2.Any{}
	for page in pages {
		page_map := github_any_map(page)!
		page_artifacts := github_map_array(github_object_get(page_map, 'artifacts'))!
		artifacts << page_artifacts
		if page_artifacts.len < 50 {
			break
		}
	}
	mut newest := map[string]map[string]json2.Any{}
	for artifact in artifacts {
		name := github_string(github_object_get(artifact, 'name'))
		if !github_artifact_pattern_match(workflow.artifact_pattern, name) {
			continue
		}
		created := github_string(github_object_get(artifact, 'created_at'))
		if current := newest[name] {
			if github_string(github_object_get(current, 'created_at')) >= created {
				continue
			}
		}
		newest[name] = artifact.clone()
	}
	if newest.len == 0 {
		url := github_string(github_nested(json2.Any(last_check), 'workflowRun', 'url'))
		return error('No artifacts with the pattern `${workflow.artifact_pattern}` were found!\n  ${url}\n')
	}
	mut urls := []string{}
	for _, artifact in newest {
		urls << github_string(github_object_get(artifact, 'archive_download_url'))
	}
	return urls
}

pub fn (mut client GitHubClient) members_by_team(org string, team string) !map[string]string {
	query := '{ organization(login: "${org}") {\n  teams(first: 100) { nodes { ... on Team { name } } }\n  team(slug: "${team}") { members(first: 100) { nodes { ... on User { login name } } } }\n}\n}\n'
	result := client.open_graphql(GitHubGraphqlRequest{
		query: query
		scopes: [
			'read:org',
			'user',
		]
	})!
	teams := github_nested(result, 'organization', 'teams', 'nodes')
	team_value := github_nested(result, 'organization', 'team')
	if !github_present(teams) || !github_present(team_value) {
		return error('Could not access the team ${org}/${team}. Please check that your GitHub account has access to the team and that your token has the required permissions.')
	}
	mut members := map[string]string{}
	for member in github_map_array(github_nested(team_value, 'members', 'nodes'))! {
		members[github_string(github_object_get(member, 'login'))] = github_string(github_object_get(member, 'name'))
	}
	return members
}

pub fn (mut client GitHubClient) sponsorships(user string) ![]GitHubSponsorship {
	query := 'query(\$user: String!, \$after: String) { organization(login: \$user) {\n  sponsorshipsAsMaintainer(first: 100, after: \$after) {\n    pageInfo { hasNextPage endCursor }\n    nodes { tier { monthlyPriceInDollars closestLesserValueTier { monthlyPriceInDollars } } sponsorEntity { ... on Organization { login name } ... on User { login name } } }\n  }\n}\n}\n'
	pages := client.paginate_graphql(GitHubGraphqlRequest{
		query: query
		variables: {
			'user': json2.Any(user)
		}
		scopes: ['user']
		raise_errors: false
	})!
	mut sponsorship_values := []map[string]json2.Any{}
	mut errors := []string{}
	for result in pages {
		if error_values := github_any_map(result) or { map[string]json2.Any{} }['errors'] {
			for entry in github_map_array(error_values) or { []map[string]json2.Any{} } {
				errors << github_string(github_object_get(entry, 'message'))
			}
		}
		current := github_nested(result, 'data', 'organization', 'sponsorshipsAsMaintainer')
		if !github_present(current) {
			continue
		}
		for node in github_any_array(github_nested(current, 'nodes')) or { []json2.Any{} } {
			if node is json2.Null {
				continue
			}
			sponsorship_values << github_any_map(node)!
		}
	}
	if sponsorship_values.len == 0 && errors.len > 0 {
		return error(errors.join('\n'))
	}
	mut output := []GitHubSponsorship{}
	for sponsorship in sponsorship_values {
		sponsor := github_any_map(github_object_get(sponsorship, 'sponsorEntity'))!
		tier_value := github_object_get(sponsorship, 'tier')
		tier := if github_present(tier_value) {
			github_any_map(tier_value)!
		} else {
			map[string]json2.Any{}
		}
		closest_value := github_object_get(tier, 'closestLesserValueTier')
		closest := if github_present(closest_value) {
			github_any_map(closest_value)!
		} else {
			map[string]json2.Any{}
		}
		login := github_string(github_object_get(sponsor, 'login'))
		name := github_string(github_object_get(sponsor, 'name'))
		output << GitHubSponsorship{
			name: if name != '' { name } else { login }
			login: login
			monthly_amount: github_int(github_object_get(tier, 'monthlyPriceInDollars'))
			closest_tier_monthly_amount: github_int(github_object_get(closest, 'monthlyPriceInDollars'))
		}
	}
	return output
}

pub fn (mut client GitHubClient) get_repo_license(user string, repo string,
	ref string) !GitHubOptionalString {
	mut url := github_url_to('repos', user, repo, 'license')
	if ref != '' {
		url += '?ref=${ref}'
	}
	response := client.open_rest(GitHubRestRequest{ url: url }) or {
		if err.msg().starts_with('HTTPNotFoundError:') {
			return GitHubOptionalString{}
		}
		if err.msg().starts_with('AuthenticationFailedError:') && github_ip_allowlist_error(err) {
			return GitHubOptionalString{}
		}
		return err
	}
	object := github_any_map(response)!
	license := object['license'] or { return GitHubOptionalString{} }
	return GitHubOptionalString{
		present: true
		value: github_string(github_nested(license, 'spdx_id'))
	}
}

fn github_word_space(character u8) bool {
	return character in [` `, `\t`, `\n`, `\r`]
}

pub fn (pattern GitHubPullRequestPattern) matches(title string) bool {
	lower_title := title.to_lower()
	lower_name := pattern.name.to_lower()
	mut position := 0
	for {
		index := lower_title.index_after(lower_name, position) or { return false }
		before_ok := index == 0 || github_word_space(lower_title[index - 1])
		after_index := index + lower_name.len
		after_ok := after_index == lower_title.len || lower_title[after_index] in [`:`, `,`] || github_word_space(lower_title[after_index])
		if before_ok && after_ok {
			if pattern.version == '' {
				return true
			}
			mut suffix_start := after_index
			if suffix_start < lower_title.len && lower_title[suffix_start] in [`:`, `,`] { suffix_start++ }
			for suffix_start < lower_title.len && github_word_space(lower_title[suffix_start]) {
				suffix_start++
			}
			lower_version := pattern.version.to_lower()
			mut version_position := suffix_start
			for {
				version_index := lower_title.index_after(lower_version, version_position) or { break }
				version_before := version_index == suffix_start || github_word_space(lower_title[version_index - 1])
				version_after_index := version_index + lower_version.len
				version_after := version_after_index == lower_title.len || lower_title[version_after_index] in [
					`:`,
					`,`,
				] || github_word_space(lower_title[version_after_index])
				if version_before && version_after {
					return true
				}
				version_position = version_index + 1
			}
		}
		position = index + 1
	}
	return false
}

pub fn github_pull_request_title_pattern(name string, version string) GitHubPullRequestPattern {
	return GitHubPullRequestPattern{ name: name, version: version }
}

pub fn (mut client GitHubClient) fetch_pull_requests(name string, tap_remote_repo string,
	state string, version string) ![]map[string]json2.Any {
	if client.no_github_api {
		return []map[string]json2.Any{}
	}
	pattern := github_pull_request_title_pattern(name, version)
	mut query := 'is:pr ${name} ${version}'.trim_space()
	if client.credentials_type == 'none' {
		prs := client.issues_for_formula(query, tap_remote_repo, state, '')!
		return prs.filter(github_string(github_object_get(it, 'html_url')).contains('/pull/') && pattern.matches(github_string(github_object_get(it, 'title'))))
	}
	if state == 'open' && client.environment['GITHUB_REPOSITORY_OWNER'] or { '' } == 'Homebrew' {
		return client.fetch_open_pull_requests(name, tap_remote_repo, version)
	}
	query += ' repo:${tap_remote_repo} in:title'
	if state != '' {
		query += ' state:${state}'
	}
	graphql_query := 'query(\$query: String!, \$after: String) { search(query: \$query, type: ISSUE, first: 100, after: \$after) { nodes { ... on PullRequest { number title url state } } pageInfo { hasNextPage endCursor } } }'
	pages := client.paginate_graphql(GitHubGraphqlRequest{
		query: graphql_query
		variables: {
			'query': json2.Any(query)
		}
	}) or {
		if github_rate_limit_error(err) {
			client.warn(err.msg())
			return []map[string]json2.Any{}
		}
		return err
	}
	mut prs := []map[string]json2.Any{}
	for page in pages {
		for mut pr in github_map_array(github_nested(page, 'search', 'nodes'))! {
			if !pattern.matches(github_string(github_object_get(pr, 'title'))) {
				continue
			}
			pr['html_url'] = github_object_get(pr, 'url')
			pr.delete('url')
			pr['state'] = json2.Any(github_string(github_object_get(pr, 'state')).to_lower())
			prs << pr
		}
	}
	return prs
}

pub fn (mut client GitHubClient) fetch_open_pull_requests(name string, tap_remote_repo string,
	version string) ![]map[string]json2.Any {
	if tap_remote_repo == '' {
		return []map[string]json2.Any{}
	}
	epoch_time := if client.now != 0 { client.now } else { time.now().unix() }
	cache_epoch := epoch_time - epoch_time % 180
	cache_key := '${tap_remote_repo}_${cache_epoch}'
	if cache_key !in client.open_pull_cache {
		parts := tap_remote_repo.split('/')
		if parts.len < 2 {
			return error('invalid repository ${tap_remote_repo}')
		}
		query := 'query(\$owner: String!, \$repo: String!, \$states: [PullRequestState!], \$after: String) { repository(owner: \$owner, name: \$repo) { pullRequests(states: \$states, first: 100, after: \$after) { nodes { number title url } pageInfo { hasNextPage endCursor } } } }'
		pages := client.paginate_graphql(GitHubGraphqlRequest{
			query: query
			variables: {
				'owner':  json2.Any(parts[0])
				'repo':   json2.Any(parts[1])
				'states': github_strings_any(['OPEN'])
			}
		}) or {
			if github_rate_limit_error(err) {
				client.warn(err.msg())
				return []map[string]json2.Any{}
			}
			return err
		}
		mut prs := []map[string]json2.Any{}
		for page in pages {
			prs << github_map_array(github_nested(page, 'repository', 'pullRequests', 'nodes'))!
		}
		client.open_pull_cache[cache_key] = prs
	}
	pattern := github_pull_request_title_pattern(name, version)
	mut output := []map[string]json2.Any{}
	for cached in client.open_pull_cache[cache_key] {
		if !pattern.matches(github_string(github_object_get(cached, 'title'))) {
			continue
		}
		mut pr := cached.clone()
		pr['html_url'] = github_object_get(pr, 'url')
		pr.delete('url')
		output << pr
	}
	return output
}

pub fn (mut client GitHubClient) get_pull_request_changed_files(tap_remote_repo string,
	pull_request string) ![]map[string]json2.Any {
	pages := client.paginate_rest(GitHubRestRequest{
		url: github_url_to('repos', tap_remote_repo, 'pulls', pull_request, 'files')
	})!
	mut files := []map[string]json2.Any{}
	for page in pages {
		files << github_map_array(page)!
	}
	return files
}

pub fn (mut client GitHubClient) check_for_duplicate_pull_requests(name string,
	tap_remote_repo string, options GitHubDuplicateOptions) ! {
	mut prs := client.fetch_pull_requests(name, tap_remote_repo, options.state, options.version)!
	mut duplicates := []map[string]json2.Any{}
	for pr in prs {
		files := client.get_pull_request_changed_files(tap_remote_repo, github_string(github_object_get(pr, 'number')))!
		if files.any(github_string(github_object_get(it, 'filename')) == options.file) { duplicates << pr }
	}
	if duplicates.len == 0 {
		return
	}
	confidence := if options.version != '' { 'are' } else { 'might be' }
	state_prefix := if options.state != '' { '${options.state} ' } else { '' }
	duplicate_lines := duplicates.map('${github_string(github_object_get(it, 'title'))} ${github_string(github_object_get(it, 'html_url'))}').join('\n')
	duplicates_message := 'These ${state_prefix}pull requests ${confidence} duplicates:\n${duplicate_lines}\n'
	error_message := 'Duplicate PRs must not be opened.\nManually open these PRs if you are sure that they are not duplicates (and tell us that in the PR).\n'
	if options.strict || (options.version != '' && options.official_tap) {
		return error('${duplicates_message.trim_string_right('\n')}\n${error_message}')
	}
	warning := if !options.official_tap {
		duplicates_message
	} else if options.quiet {
		error_message
	} else {
		'${duplicates_message.trim_string_right('\n')}\n${error_message}'
	}
	client.warn(warning)
}

pub fn (mut client GitHubClient) pull_request_commits(user string, repo string,
	pull_request string, per_page int) ![]string {
	pr_data := github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', user, repo, 'pulls', pull_request)
	})!)!
	commits_api := github_string(github_object_get(pr_data, 'commits_url'))
	commit_count := github_int(github_object_get(pr_data, 'commits'))
	if commit_count > github_api_max_items {
		return error('Getting ${commit_count} commits would exceed limit of ${github_api_max_items} API items!')
	}
	pages := client.paginate_rest(GitHubRestRequest{ url: commits_api, per_page: per_page })!
	mut commits := []string{}
	for page_index, page in pages {
		result := github_map_array(page)!
		commits << result.map(github_string(github_object_get(it, 'sha')))
		if commits.len == commit_count {
			return commits
		}
		page_number := page_index + 1
		if result.len == 0 || page_number * per_page >= commit_count {
			return error('Expected ${commit_count} commits but actually got ${commits.len}!')
		}
	}
	return commits
}

pub fn (mut client GitHubClient) pull_request_labels(user string, repo string,
	pull_request string) ![]string {
	pr_data := github_any_map(client.open_rest(GitHubRestRequest{
		url: github_url_to('repos', user, repo, 'pulls', pull_request)
	})!)!
	return github_map_array(github_object_get(pr_data, 'labels'))!.map(github_string(github_object_get(it, 'name')))
}

pub fn (mut client GitHubClient) multiple_short_commits_exist(user string, repo string,
	commit string) !bool {
	if client.no_github_api {
		return false
	}
	result := client.curl(GitHubCurlRequest{
		url: github_url_to('repos', user, repo, 'commits', commit)
		headers: ['Accept: application/vnd.github.sha']
		output_null: true
		write_out: '%{http_code}'
	})!
	if !result.success || result.stdout == '' {
		return true
	}
	return result.stdout != '200'
}

fn github_etag_commit(output string) string {
	for line in output.split_into_lines() {
		if !line.to_lower().starts_with('etag: "') {
			continue
		}
		start := line.index('"') or { continue }
		end := line.index_after('"', start + 1) or { continue }
		candidate := line[start + 1..end]
		if candidate != '' && candidate.bytes().all((it >= `0` && it <= `9`) || (it >= `a` && it <= `f`) || (it >= `A` && it <= `F`)) {
			return candidate
		}
	}
	return ''
}

pub fn (mut client GitHubClient) last_commit(user string, repo string, ref string,
	length int) !GitHubOptionalString {
	if client.no_github_api {
		return GitHubOptionalString{}
	}
	result := client.curl(GitHubCurlRequest{
		url: github_url_to('repos', user, repo, 'commits', ref)
		headers: ['Accept: application/vnd.github.sha']
	})!
	if !result.success {
		return GitHubOptionalString{}
	}
	mut commit := github_etag_commit(result.stdout)
	if commit == '' {
		return GitHubOptionalString{}
	}
	if length > 0 {
		if commit.len < length {
			return GitHubOptionalString{}
		}
		commit = commit[..length]
		if client.multiple_short_commits_exist(user, repo, commit)! {
			return GitHubOptionalString{}
		}
	}
	client.update_version(commit)
	return GitHubOptionalString{
		present: true
		value: commit
	}
}

pub fn (mut client GitHubClient) too_many_open_prs(tap_present bool, tap_official bool,
	test_bot_autobump bool) !bool {
	if !tap_present || !tap_official || test_bot_autobump {
		return false
	}
	if client.no_github_api {
		return error('Cannot count PRs as `\$HOMEBREW_NO_GITHUB_API` is set!')
	}
	query := 'query(\$after: String) { viewer { login pullRequests(first: 100, states: OPEN, after: \$after) { totalCount nodes { baseRepository { owner { login } } } pageInfo { hasNextPage endCursor } } } }'
	pages := client.paginate_graphql(GitHubGraphqlRequest{ query: query }) or {
		if err.msg().contains('Resource protected by organization SAML enforcement') || err.msg().contains('your IP address is not permitted to access this resource') {
			return false
		}
		return err
	}
	mut homebrew_prs_count := 0
	for page in pages {
		viewer := github_any_map(github_nested(page, 'viewer'))!
		if github_string(github_object_get(viewer, 'login')).to_lower() == 'brewtestbot' {
			return false
		}
		pulls := github_any_map(github_object_get(viewer, 'pullRequests'))!
		if github_int(github_object_get(pulls, 'totalCount')) < github_maximum_open_prs {
			return false
		}
		for node in github_map_array(github_object_get(pulls, 'nodes'))! {
			if github_string(github_nested(json2.Any(node), 'baseRepository', 'owner', 'login')).to_lower() == 'homebrew' {
				homebrew_prs_count++
			}
		}
		if homebrew_prs_count >= github_maximum_open_prs {
			return true
		}
	}
	return false
}

fn github_parse_date(date string) !time.Time {
	return time.parse_iso8601('${date}T00:00:00Z')
}

pub fn (mut client GitHubClient) organisation_repositories(organisation string,
	from string, to string, verbose bool) ![]string {
	from_date := github_parse_date(from)!
	to_date := github_parse_date(to)!
	pages := client.paginate_rest(GitHubRestRequest{
		url: '${github_api_url}/orgs/${organisation}/repos'
		per_page: github_max_per_page
		additional_query: 'type=sources'
	})!
	mut repositories := []map[string]json2.Any{}
	for page in pages {
		repositories << github_map_array(page)!
	}
	mut output := []string{}
	for repository_value in repositories {
		pushed_at := github_parse_date(github_string(github_object_get(repository_value, 'pushed_at'))[..10])!
		created_at := github_parse_date(github_string(github_object_get(repository_value, 'created_at'))[..10])!
		archived_raw := github_string(github_object_get(repository_value, 'archived_at'))
		archived_at := github_parse_date(if archived_raw != '' { archived_raw[..10] } else { from })!
		full_name := github_string(github_object_get(repository_value, 'full_name'))
		not_pushed := pushed_at < from_date
		not_created := created_at > to_date
		archived := archived_at < from_date
		if not_pushed || not_created || archived {
			if verbose {
				mut reasons := []string{}
				if not_pushed { reasons << 'not pushed' }
				if not_created { reasons << 'not created' }
				if archived { reasons << 'archived' }
				warning := 'Repository ${full_name} ${reasons.join(', ')} from ${from} to ${to}. Skipping.'
				client.warn(warning)
			}
			continue
		}
		output << full_name
	}
	return output
}

pub fn (mut client GitHubClient) search_approved_pull_requests_in_user_or_organisation(
	user string, reviewed_by string, from string, to string) ![]map[string]json2.Any {
	qualifiers := [
		GitHubQualifier{ key: 'is', values: ['pr'] },
		GitHubQualifier{ key: 'review', values: ['approved'] },
		GitHubQualifier{ key: 'user', values: [user] },
		GitHubQualifier{ key: 'reviewed_by', values: [reviewed_by] },
	]
	return client.search_issues('', qualifiers, from, to) or {
		if err.msg().starts_with('ValidationFailedError:') {
			client.warn("Couldn't search GitHub for PRs reviewed by ${reviewed_by}. Their profile might be private. Defaulting to 0.")
			return []map[string]json2.Any{}
		}
		return err
	}
}

// Ruby method `self.issues(repo:, **filters)` at line 23.
pub fn ruby_github_l23_d1_self_issues(mut client GitHubClient, repo string,
	filters []GitHubQualifier) ![]map[string]json2.Any {
	return client.issues(repo, filters)
}

// Ruby method `self.search_issues(query, **qualifiers)` at line 30.
pub fn ruby_github_l30_d2_self_search_issues(mut client GitHubClient, query string,
	qualifiers []GitHubQualifier, from string, to string) ![]map[string]json2.Any {
	return client.search_issues(query, qualifiers, from, to)
}

// Ruby method `self.create_gist(files, description, private:)` at line 36.
pub fn ruby_github_l36_d3_self_create_gist(mut client GitHubClient, files map[string]string,
	description string, private bool) !string {
	return client.create_gist(files, description, private)
}

// Ruby method `self.create_issue(repo, title, body)` at line 43.
pub fn ruby_github_l43_d4_self_create_issue(mut client GitHubClient, repo string, title string,
	body string) !string {
	return client.create_issue(repo, title, body)
}

// Ruby method `self.create_issue_comment(repo, issue, body)` at line 50.
pub fn ruby_github_l50_d5_self_create_issue_comment(mut client GitHubClient, repo string,
	issue string, body string) !map[string]json2.Any {
	return client.create_issue_comment(repo, issue, body)
}

// Ruby method `self.repository(user, repo)` at line 56.
pub fn ruby_github_l56_d6_self_repository(mut client GitHubClient, user string,
	repo string) !map[string]json2.Any {
	return client.repository(user, repo)
}

// Ruby method `self.issues_for_formula(name, tap: CoreTap.instance, tap_remote_repo: tap&.full_name, state: nil, type: nil)` at line 69.
pub fn ruby_github_l69_d7_self_issues_for_formula(mut client GitHubClient, name string,
	tap_remote_repo string, state string, issue_type string) ![]map[string]json2.Any {
	return client.issues_for_formula(name, tap_remote_repo, state, issue_type)
}

// Ruby method `self.user` at line 76.
pub fn ruby_github_l76_d8_self_user(mut client GitHubClient) !map[string]json2.Any {
	return client.user()
}

// Ruby method `self.print_pull_requests_matching(query, only = nil)` at line 81.
pub fn ruby_github_l81_d9_self_print_pull_requests_matching(mut client GitHubClient,
	query string, only string) !string {
	return client.print_pull_requests_matching(query, only)
}

// Ruby method `self.create_fork(repo, org: nil)` at line 105.
pub fn ruby_github_l105_d10_self_create_fork(mut client GitHubClient, repo string,
	org string) !map[string]json2.Any {
	return client.create_fork(repo, org)
}

// Ruby method `self.fork_exists?(repo, org: nil)` at line 114.
pub fn ruby_github_l114_d11_self_fork_exists(mut client GitHubClient, repo string,
	org string) !bool {
	return client.fork_exists(repo, org)
}

// Ruby method `self.create_pull_request(repo, title, head, base, body)` at line 126.
pub fn ruby_github_l126_d12_self_create_pull_request(mut client GitHubClient, repo string,
	title string, head string, base string, body string) !map[string]json2.Any {
	return client.create_pull_request(repo, title, head, base, body)
}

// Ruby method `self.private_repo?(full_name)` at line 135.
pub fn ruby_github_l135_d13_self_private_repo(mut client GitHubClient, full_name string) !bool {
	return client.private_repo(full_name)
}

// Ruby method `self.search_query_string(*main_params, **qualifiers)` at line 141.
pub fn ruby_github_l141_d14_self_search_query_string(main_params []string,
	qualifiers []GitHubQualifier, from string, to string) string {
	return github_search_query_string(main_params, qualifiers, from, to)
}

// Ruby method `self.url_to(*subroutes)` at line 163.
pub fn ruby_github_l163_d15_self_url_to(subroutes ...string) string {
	return github_url_to(...subroutes)
}

// Ruby method `self.search(entity, *queries, **qualifiers)` at line 168.
pub fn ruby_github_l168_d16_self_search(mut client GitHubClient, entity string,
	queries []string, qualifiers []GitHubQualifier, from string, to string) !map[string]json2.Any {
	return client.search(entity, queries, qualifiers, from, to)
}

// Ruby method `self.repository_approved_reviews(user, repo, pull_request, commit: nil)` at line 178.
pub fn ruby_github_l178_d17_self_repository_approved_reviews(mut client GitHubClient,
	user string, repo string, pull_request string, commit string) ![]map[string]json2.Any {
	return client.repository_approved_reviews(user, repo, pull_request, commit)
}

// Ruby method `self.workflow_dispatch_event(user, repo, workflow, ref, **inputs)` at line 220.
pub fn ruby_github_l220_d18_self_workflow_dispatch_event(mut client GitHubClient, user string,
	repo string, workflow string, ref string, inputs map[string]json2.Any) ! {
	client.workflow_dispatch_event(user, repo, workflow, ref, inputs)!
}

// Ruby method `self.get_release(user, repo, tag)` at line 228.
pub fn ruby_github_l228_d19_self_get_release(mut client GitHubClient, user string, repo string,
	tag string) !map[string]json2.Any {
	return client.get_release(user, repo, tag)
}

// Ruby method `self.get_latest_release(user, repo)` at line 234.
pub fn ruby_github_l234_d20_self_get_latest_release(mut client GitHubClient, user string,
	repo string) !map[string]json2.Any {
	return client.get_latest_release(user, repo)
}

// Ruby method `self.generate_release_notes(user, repo, tag, previous_tag: nil)` at line 240.
pub fn ruby_github_l240_d21_self_generate_release_notes(mut client GitHubClient, user string,
	repo string, tag string, previous_tag string) !map[string]json2.Any {
	return client.generate_release_notes(user, repo, tag, previous_tag)
}

// Ruby method `self.create_or_update_release(user, repo, tag, id: nil, name: nil, body: nil, draft: false)` at line 251.
pub fn ruby_github_l251_d22_self_create_or_update_release(mut client GitHubClient, user string,
	repo string, tag string, id string, name string, body string, draft bool) !map[string]json2.Any {
	return client.create_or_update_release(user, repo, tag, id, name, body, draft)
}

// Ruby method `self.upload_release_asset(user, repo, id, local_file:, remote_file: nil)` at line 271.
pub fn ruby_github_l271_d23_self_upload_release_asset(mut client GitHubClient, user string,
	repo string, id int, local_file string, remote_file string) ! {
	client.upload_release_asset(user, repo, id, local_file, remote_file)!
}

// Ruby method `self.get_workflow_run(user, repo, pull_request, workflow_id: "tests.yml", artifact_pattern: "bottles{,_*}",` at line 287.
pub fn ruby_github_l287_d24_self_get_workflow_run(mut client GitHubClient, user string,
	repo string, pull_request string, workflow_id string, artifact_pattern string,
	head_sha string) !GitHubWorkflowArray {
	return client.get_workflow_run(user, repo, pull_request, workflow_id, artifact_pattern, head_sha)
}

// Ruby method `self.get_artifact_urls(workflow_array)` at line 348.
pub fn ruby_github_l348_d25_self_get_artifact_urls(mut client GitHubClient,
	workflow GitHubWorkflowArray) ![]string {
	return client.get_artifact_urls(workflow)
}

// Ruby method `self.members_by_team(org, team)` at line 394.
pub fn ruby_github_l394_d26_self_members_by_team(mut client GitHubClient, org string,
	team string) !map[string]string {
	return client.members_by_team(org, team)
}

// Ruby method `self.sponsorships(user)` at line 434.
pub fn ruby_github_l434_d27_self_sponsorships(mut client GitHubClient,
	user string) ![]GitHubSponsorship {
	return client.sponsorships(user)
}

// Ruby method `self.get_repo_license(user, repo, ref: nil)` at line 500.
pub fn ruby_github_l500_d28_self_get_repo_license(mut client GitHubClient, user string,
	repo string, ref string) !GitHubOptionalString {
	return client.get_repo_license(user, repo, ref)
}

// Ruby method `self.pull_request_title_regex(name, version = nil)` at line 514.
pub fn ruby_github_l514_d29_self_pull_request_title_regex(name string,
	version string) GitHubPullRequestPattern {
	return github_pull_request_title_pattern(name, version)
}

// Ruby method `self.fetch_pull_requests(name, tap_remote_repo, state: nil, version: nil)` at line 524.
pub fn ruby_github_l524_d30_self_fetch_pull_requests(mut client GitHubClient, name string,
	tap_remote_repo string, state string, version string) ![]map[string]json2.Any {
	return client.fetch_pull_requests(name, tap_remote_repo, state, version)
}

// Ruby method `self.fetch_open_pull_requests(name, tap_remote_repo, version: nil)` at line 587.
pub fn ruby_github_l587_d31_self_fetch_open_pull_requests(mut client GitHubClient, name string,
	tap_remote_repo string, version string) ![]map[string]json2.Any {
	return client.fetch_open_pull_requests(name, tap_remote_repo, version)
}

// Ruby method `self.check_for_duplicate_pull_requests(name, tap_remote_repo, file:, quiet: false, state: nil,` at line 652.
pub fn ruby_github_l652_d32_self_check_for_duplicate_pull_requests(mut client GitHubClient,
	name string, tap_remote_repo string, options GitHubDuplicateOptions) ! {
	client.check_for_duplicate_pull_requests(name, tap_remote_repo, options)!
}

// Ruby method `self.get_pull_request_changed_files(tap_remote_repo, pull_request)` at line 691.
pub fn ruby_github_l691_d33_self_get_pull_request_changed_files(mut client GitHubClient,
	tap_remote_repo string, pull_request string) ![]map[string]json2.Any {
	return client.get_pull_request_changed_files(tap_remote_repo, pull_request)
}

// Ruby method `self.pull_request_commits(user, repo, pull_request, per_page: MAX_PER_PAGE)` at line 703.
pub fn ruby_github_l703_d34_self_pull_request_commits(mut client GitHubClient, user string,
	repo string, pull_request string, per_page int) ![]string {
	return client.pull_request_commits(user, repo, pull_request, per_page)
}

// Ruby method `self.pull_request_labels(user, repo, pull_request)` at line 727.
pub fn ruby_github_l727_d35_self_pull_request_labels(mut client GitHubClient, user string,
	repo string, pull_request string) ![]string {
	return client.pull_request_labels(user, repo, pull_request)
}

// Ruby method `self.last_commit(user, repo, ref, version, length: nil)` at line 736.
pub fn ruby_github_l736_d36_self_last_commit(mut client GitHubClient, user string, repo string,
	ref string, length int) !GitHubOptionalString {
	return client.last_commit(user, repo, ref, length)
}

// Ruby method `self.multiple_short_commits_exist?(user, repo, commit)` at line 769.
pub fn ruby_github_l769_d37_self_multiple_short_commits_exist(mut client GitHubClient,
	user string, repo string, commit string) !bool {
	return client.multiple_short_commits_exist(user, repo, commit)
}

// Ruby method `self.too_many_open_prs?(tap)` at line 793.
pub fn ruby_github_l793_d38_self_too_many_open_prs(mut client GitHubClient, tap_present bool,
	tap_official bool, test_bot_autobump bool) !bool {
	return client.too_many_open_prs(tap_present, tap_official, test_bot_autobump)
}

// Ruby method `self.organisation_repositories(organisation, from, to, verbose)` at line 858.
pub fn ruby_github_l858_d39_self_organisation_repositories(mut client GitHubClient,
	organisation string, from string, to string, verbose bool) ![]string {
	return client.organisation_repositories(organisation, from, to, verbose)
}

// Ruby method `self.search_approved_pull_requests_in_user_or_organisation(user, reviewed_by, from:, to:)` at line 898.
pub fn ruby_github_l898_d40_self_search_approved_pull_requests_in_user_or_organisation(
	mut client GitHubClient, user string, reviewed_by string, from string,
	to string) ![]map[string]json2.Any {
	return client.search_approved_pull_requests_in_user_or_organisation(user, reviewed_by, from, to)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "uri"
// 5: require "utils/github/actions"
// 6: require "utils/github/api"
// 7: require "utils/output"
// 8:
// 9: require "system_command"
// 10:
// 11: # A module that interfaces with GitHub, code like PAT scopes, credential handling and API errors.
// 12: #
// 13: # @api internal
// 14: module GitHub
// 15:   extend SystemCommand::Mixin
// 16:   extend Utils::Output::Mixin
// 17:
// 18:   MAX_PER_PAGE = 100
// 19:
// 20:   WorkflowArray = T.type_alias { [T::Array[T::Hash[String, T.untyped]], String, String, String, String, T::Array[String], String] }
// 21:
// 22:   sig { params(repo: String, filters: T.untyped).returns(T::Array[T::Hash[String, T.untyped]]) }
// 23:   def self.issues(repo:, **filters)
// 24:     uri = url_to("repos", repo, "issues")
// 25:     uri.query = URI.encode_www_form(filters)
// 26:     API.open_rest(uri)
// 27:   end
// 28:
// 29:   sig { params(query: String, qualifiers: T.untyped).returns(T::Array[T::Hash[String, T.untyped]]) }
// 30:   def self.search_issues(query, **qualifiers)
// 31:     json = search("issues", query, **qualifiers)
// 32:     json.fetch("items", [])
// 33:   end
// 34:
// 35:   sig { params(files: T::Hash[String, { content: String }], description: String, private: T::Boolean).returns(String) }
// 36:   def self.create_gist(files, description, private:)
// 37:     url = "#{API_URL}/gists"
// 38:     data = { "public" => !private, "files" => files, "description" => description }
// 39:     API.open_rest(url, data:, scopes: CREATE_GIST_SCOPES)["html_url"]
// 40:   end
// 41:
// 42:   sig { params(repo: String, title: String, body: String).returns(String) }
// 43:   def self.create_issue(repo, title, body)
// 44:     url = "#{API_URL}/repos/#{repo}/issues"
// 45:     data = { "title" => title, "body" => body }
// 46:     API.open_rest(url, data:, scopes: CREATE_ISSUE_FORK_OR_PR_SCOPES)["html_url"]
// 47:   end
// 48:
// 49:   sig { params(repo: String, issue: T.any(String, Integer), body: String).returns(T::Hash[String, T.untyped]) }
// 50:   def self.create_issue_comment(repo, issue, body)
// 51:     url = "#{API_URL}/repos/#{repo}/issues/#{issue}/comments"
// 52:     API.open_rest(url, data: { body: }, scopes: CREATE_ISSUE_FORK_OR_PR_SCOPES)
// 53:   end
// 54:
// 55:   sig { params(user: String, repo: String).returns(T::Hash[String, T.untyped]) }
// 56:   def self.repository(user, repo)
// 57:     API.open_rest(url_to("repos", user, repo))
// 58:   end
// 59:
// 60:   sig {
// 61:     params(
// 62:       name:            String,
// 63:       tap:             T.nilable(Tap),
// 64:       tap_remote_repo: T.nilable(String),
// 65:       state:           T.nilable(String),
// 66:       type:            T.nilable(String),
// 67:     ).returns(T::Array[T::Hash[String, T.untyped]])
// 68:   }
// 69:   def self.issues_for_formula(name, tap: CoreTap.instance, tap_remote_repo: tap&.full_name, state: nil, type: nil)
// 70:     return [] unless tap_remote_repo
// 71:
// 72:     search_issues(name, repo: tap_remote_repo, state:, type:, in: "title")
// 73:   end
// 74:
// 75:   sig { returns(T::Hash[String, T.untyped]) }
// 76:   def self.user
// 77:     @user ||= T.let(API.open_rest("#{API_URL}/user"), T.nilable(T::Hash[String, T.untyped]))
// 78:   end
// 79:
// 80:   sig { params(query: String, only: T.nilable(T.any(Symbol, String))).void }
// 81:   def self.print_pull_requests_matching(query, only = nil)
// 82:     open_or_closed_prs = search_issues(query, is: only, type: "pr", user: "Homebrew")
// 83:
// 84:     open_prs, closed_prs = open_or_closed_prs.partition { |pr| pr["state"] == "open" }
// 85:                                              .map { |prs| prs.map { |pr| "#{pr["title"]} (#{pr["html_url"]})" } }
// 86:
// 87:     if open_prs.present?
// 88:       ohai "Open pull requests"
// 89:       open_prs.each { |pr| puts pr }
// 90:     end
// 91:
// 92:     if closed_prs.present?
// 93:       puts if open_prs.present?
// 94:
// 95:       ohai "Closed pull requests"
// 96:       closed_prs.take(20).each { |pr| puts pr }
// 97:
// 98:       puts "..." if closed_prs.count > 20
// 99:     end
// 100:
// 101:     puts "No pull requests found for #{query.inspect}" if open_prs.blank? && closed_prs.blank?
// 102:   end
// 103:
// 104:   sig { params(repo: String, org: T.nilable(String)).returns(T::Hash[String, T.untyped]) }
// 105:   def self.create_fork(repo, org: nil)
// 106:     url = "#{API_URL}/repos/#{repo}/forks"
// 107:     data = {}
// 108:     data[:organization] = org if org
// 109:     scopes = CREATE_ISSUE_FORK_OR_PR_SCOPES
// 110:     API.open_rest(url, data:, scopes:)
// 111:   end
// 112:
// 113:   sig { params(repo: String, org: T.nilable(String)).returns(T::Boolean) }
// 114:   def self.fork_exists?(repo, org: nil)
// 115:     reponame = repo.split("/").fetch(1)
// 116:
// 117:     username = org || API.open_rest(url_to("user")) { |json| json["login"] }
// 118:     json = API.open_rest(url_to("repos", username, reponame))
// 119:
// 120:     return false if json["message"] == "Not Found"
// 121:
// 122:     true
// 123:   end
// 124:
// 125:   sig { params(repo: String, title: String, head: String, base: String, body: String).returns(T::Hash[String, T.untyped]) }
// 126:   def self.create_pull_request(repo, title, head, base, body)
// 127:     url = "#{API_URL}/repos/#{repo}/pulls"
// 128:     data = { title:, head:, base:, body:, maintainer_can_modify: true }
// 129:     scopes = CREATE_ISSUE_FORK_OR_PR_SCOPES
// 130:     API.open_rest(url, data:, scopes:)
// 131:   end
// 132:
// 133:   # We default to private if we aren't sure or if the GitHub API is disabled.
// 134:   sig { params(full_name: String).returns(T::Boolean) }
// 135:   def self.private_repo?(full_name)
// 136:     uri = url_to "repos", full_name
// 137:     API.open_rest(uri) { |json| json.fetch("private", true) }
// 138:   end
// 139:
// 140:   sig { params(main_params: String, qualifiers: T.untyped).returns(String) }
// 141:   def self.search_query_string(*main_params, **qualifiers)
// 142:     params = T.let(main_params.to_a, T::Array[T.nilable(String)])
// 143:
// 144:     from = qualifiers.fetch(:from, nil)
// 145:     to = qualifiers.fetch(:to, nil)
// 146:
// 147:     params << if from && to
// 148:       "created:#{from}..#{to}"
// 149:     elsif from
// 150:       "created:>=#{from}"
// 151:     elsif to
// 152:       "created:<=#{to}"
// 153:     end
// 154:
// 155:     params += qualifiers.except(:args, :from, :to).flat_map do |key, value|
// 156:       Array(value).map { |v| "#{key.to_s.tr("_", "-")}:#{v}" }
// 157:     end
// 158:
// 159:     "q=#{URI.encode_www_form_component(params.compact.join(" "))}&per_page=#{MAX_PER_PAGE}"
// 160:   end
// 161:
// 162:   sig { params(subroutes: T.any(String, Integer)).returns(URI::Generic) }
// 163:   def self.url_to(*subroutes)
// 164:     URI.parse([API_URL, *subroutes].join("/"))
// 165:   end
// 166:
// 167:   sig { params(entity: String, queries: String, qualifiers: T.untyped).returns(T::Hash[String, T.untyped]) }
// 168:   def self.search(entity, *queries, **qualifiers)
// 169:     uri = url_to "search", entity
// 170:     uri.query = search_query_string(*queries, **qualifiers)
// 171:     API.open_rest(uri)
// 172:   end
// 173:
// 174:   sig {
// 175:     params(user: String, repo: String, pull_request: T.any(String, Integer), commit: T.nilable(String))
// 176:       .returns(T::Array[T::Hash[String, T.untyped]])
// 177:   }
// 178:   def self.repository_approved_reviews(user, repo, pull_request, commit: nil)
// 179:     query = <<~EOS
// 180:       { repository(name: "#{repo}", owner: "#{user}") {
// 181:           pullRequest(number: #{pull_request}) {
// 182:             reviews(states: APPROVED, first: 100) {
// 183:               nodes {
// 184:                 author {
// 185:                   ... on User { email login name databaseId }
// 186:                   ... on Organization { email login name databaseId }
// 187:                 }
// 188:                 authorAssociation
// 189:                 commit { oid }
// 190:               }
// 191:             }
// 192:           }
// 193:         }
// 194:       }
// 195:     EOS
// 196:
// 197:     result = API.open_graphql(query, scopes: ["user:email"])
// 198:     reviews = result["repository"]["pullRequest"]["reviews"]["nodes"]
// 199:
// 200:     valid_associations = %w[MEMBER OWNER]
// 201:     reviews.filter_map do |r|
// 202:       next if commit.present? && commit != r["commit"]["oid"]
// 203:       next unless valid_associations.include? r["authorAssociation"]
// 204:
// 205:       email = r["author"]["email"].presence ||
// 206:               "#{r["author"]["databaseId"]}+#{r["author"]["login"]}@users.noreply.github.com"
// 207:
// 208:       name = r["author"]["name"].presence ||
// 209:              r["author"]["login"]
// 210:
// 211:       {
// 212:         "email" => email,
// 213:         "name"  => name,
// 214:         "login" => r["author"]["login"],
// 215:       }
// 216:     end
// 217:   end
// 218:
// 219:   sig { params(user: String, repo: String, workflow: String, ref: String, inputs: T.untyped).void }
// 220:   def self.workflow_dispatch_event(user, repo, workflow, ref, **inputs)
// 221:     url = "#{API_URL}/repos/#{user}/#{repo}/actions/workflows/#{workflow}/dispatches"
// 222:     API.open_rest(url, data:           { ref:, inputs: },
// 223:                        request_method: :POST,
// 224:                        scopes:         CREATE_ISSUE_FORK_OR_PR_SCOPES)
// 225:   end
// 226:
// 227:   sig { params(user: String, repo: String, tag: String).returns(T::Hash[String, T.untyped]) }
// 228:   def self.get_release(user, repo, tag)
// 229:     url = "#{API_URL}/repos/#{user}/#{repo}/releases/tags/#{tag}"
// 230:     API.open_rest(url, request_method: :GET)
// 231:   end
// 232:
// 233:   sig { params(user: String, repo: String).returns(T::Hash[String, T.untyped]) }
// 234:   def self.get_latest_release(user, repo)
// 235:     url = "#{API_URL}/repos/#{user}/#{repo}/releases/latest"
// 236:     API.open_rest(url, request_method: :GET)
// 237:   end
// 238:
// 239:   sig { params(user: String, repo: String, tag: String, previous_tag: T.nilable(String)).returns(T::Hash[String, T.untyped]) }
// 240:   def self.generate_release_notes(user, repo, tag, previous_tag: nil)
// 241:     url = "#{API_URL}/repos/#{user}/#{repo}/releases/generate-notes"
// 242:     data = { tag_name: tag }
// 243:     data[:previous_tag_name] = previous_tag if previous_tag.present?
// 244:     API.open_rest(url, data:, request_method: :POST, scopes: CREATE_ISSUE_FORK_OR_PR_SCOPES)
// 245:   end
// 246:
// 247:   sig {
// 248:     params(user: String, repo: String, tag: String, id: T.nilable(String), name: T.nilable(String),
// 249:            body: T.nilable(String), draft: T::Boolean).returns(T::Hash[String, T.untyped])
// 250:   }
// 251:   def self.create_or_update_release(user, repo, tag, id: nil, name: nil, body: nil, draft: false)
// 252:     url = "#{API_URL}/repos/#{user}/#{repo}/releases"
// 253:     method = if id
// 254:       url += "/#{id}"
// 255:       :PATCH
// 256:     else
// 257:       :POST
// 258:     end
// 259:     data = {
// 260:       tag_name: tag,
// 261:       name:     name || tag,
// 262:       draft:,
// 263:     }
// 264:     data[:body] = body if body.present?
// 265:     API.open_rest(url, data:, request_method: method, scopes: CREATE_ISSUE_FORK_OR_PR_SCOPES)
// 266:   end
// 267:
// 268:   sig {
// 269:     params(user: String, repo: String, id: Integer, local_file: String, remote_file: T.nilable(String)).void
// 270:   }
// 271:   def self.upload_release_asset(user, repo, id, local_file:, remote_file: nil)
// 272:     url = "https://uploads.github.com/repos/#{user}/#{repo}/releases/#{id}/assets"
// 273:     url += "?name=#{remote_file}" if remote_file
// 274:     API.open_rest(url, data_binary_path: local_file, request_method: :POST, scopes: CREATE_ISSUE_FORK_OR_PR_SCOPES)
// 275:   end
// 276:
// 277:   sig {
// 278:     params(
// 279:       user:             String,
// 280:       repo:             String,
// 281:       pull_request:     String,
// 282:       workflow_id:      String,
// 283:       artifact_pattern: String,
// 284:       head_sha:         T.nilable(String),
// 285:     ).returns(WorkflowArray)
// 286:   }
// 287:   def self.get_workflow_run(user, repo, pull_request, workflow_id: "tests.yml", artifact_pattern: "bottles{,_*}",
// 288:                             head_sha: nil)
// 289:     scopes = CREATE_ISSUE_FORK_OR_PR_SCOPES
// 290:
// 291:     # GraphQL unfortunately has no way to get the workflow yml name, so we need an extra REST call.
// 292:     workflow_api_url = "#{API_URL}/repos/#{user}/#{repo}/actions/workflows/#{workflow_id}"
// 293:     workflow_payload = API.open_rest(workflow_api_url, scopes:)
// 294:     workflow_id_num = workflow_payload["id"]
// 295:
// 296:     query = <<~EOS
// 297:       query ($user: String!, $repo: String!, $pr: Int!) {
// 298:         repository(owner: $user, name: $repo) {
// 299:           pullRequest(number: $pr) {
// 300:             commits(last: 1) {
// 301:               nodes {
// 302:                 commit {
// 303:                   oid
// 304:                   checkSuites(first: 100) {
// 305:                     nodes {
// 306:                       status,
// 307:                       workflowRun {
// 308:                         databaseId,
// 309:                         url,
// 310:                         workflow {
// 311:                           databaseId
// 312:                         }
// 313:                       }
// 314:                     }
// 315:                   }
// 316:                 }
// 317:               }
// 318:             }
// 319:           }
// 320:         }
// 321:       }
// 322:     EOS
// 323:     variables = {
// 324:       user:,
// 325:       repo:,
// 326:       pr:   pull_request.to_i,
// 327:     }
// 328:     result = API.open_graphql(query, variables:, scopes:)
// 329:
// 330:     commit_node = result["repository"]["pullRequest"]["commits"]["nodes"].first
// 331:     check_suite = if commit_node.present?
// 332:       commit = commit_node["commit"]
// 333:       if head_sha.present? && commit["oid"].downcase != head_sha.downcase
// 334:         raise API::Error, "Pull request ##{pull_request} is at #{commit["oid"]} but expected #{head_sha}."
// 335:       end
// 336:
// 337:       commit["checkSuites"]["nodes"].select do |suite|
// 338:         suite.dig("workflowRun", "workflow", "databaseId") == workflow_id_num
// 339:       end
// 340:     else
// 341:       []
// 342:     end
// 343:
// 344:     [check_suite, user, repo, pull_request, workflow_id, scopes, artifact_pattern]
// 345:   end
// 346:
// 347:   sig { params(workflow_array: WorkflowArray).returns(T::Array[String]) }
// 348:   def self.get_artifact_urls(workflow_array)
// 349:     check_suite, user, repo, pr, workflow_id, scopes, artifact_pattern = *workflow_array
// 350:     if check_suite.empty?
// 351:       raise API::Error, <<~EOS
// 352:         No matching check suite found for these criteria!
// 353:           Pull request: #{pr}
// 354:           Workflow:     #{workflow_id}
// 355:       EOS
// 356:     end
// 357:
// 358:     last_check = check_suite.fetch(-1)
// 359:     status = last_check["status"].sub("_", " ").downcase
// 360:     if status != "completed"
// 361:       raise API::Error, <<~EOS
// 362:         The newest workflow run for ##{pr} is still #{status}!
// 363:           #{Formatter.url last_check["workflowRun"]["url"]}
// 364:       EOS
// 365:     end
// 366:
// 367:     run_id = last_check["workflowRun"]["databaseId"]
// 368:     artifacts = []
// 369:     per_page = 50
// 370:     API.paginate_rest("#{API_URL}/repos/#{user}/#{repo}/actions/runs/#{run_id}/artifacts",
// 371:                       per_page:, scopes:) do |result|
// 372:       result = result["artifacts"]
// 373:       artifacts.concat(result)
// 374:       break if result.length < per_page
// 375:     end
// 376:
// 377:     matching_artifacts =
// 378:       artifacts
// 379:       .group_by { |art| art["name"] }
// 380:       .select { |name| File.fnmatch?(artifact_pattern, name, File::FNM_EXTGLOB) }
// 381:       .map { |_, arts| arts.max_by { |art| art["created_at"] } }
// 382:
// 383:     if matching_artifacts.empty?
// 384:       raise API::Error, <<~EOS
// 385:         No artifacts with the pattern `#{artifact_pattern}` were found!
// 386:           #{Formatter.url last_check["workflowRun"]["url"]}
// 387:       EOS
// 388:     end
// 389:
// 390:     matching_artifacts.map { |art| art["archive_download_url"] }
// 391:   end
// 392:
// 393:   sig { params(org: String, team: String).returns(T::Hash[String, String]) }
// 394:   def self.members_by_team(org, team)
// 395:     query = <<~EOS
// 396:         { organization(login: "#{org}") {
// 397:           teams(first: 100) {
// 398:             nodes {
// 399:               ... on Team { name }
// 400:             }
// 401:           }
// 402:           team(slug: "#{team}") {
// 403:             members(first: 100) {
// 404:               nodes {
// 405:                 ... on User { login name }
// 406:               }
// 407:             }
// 408:           }
// 409:         }
// 410:       }
// 411:     EOS
// 412:     result = API.open_graphql(query, scopes: ["read:org", "user"])
// 413:
// 414:     if result.dig("organization", "teams", "nodes").blank? || result.dig("organization", "team").blank?
// 415:       raise API::Error, "Could not access the team #{org}/#{team}. " \
// 416:                         "Please check that your GitHub account has access to the team and that your token has the " \
// 417:                         "required permissions."
// 418:     end
// 419:
// 420:     result["organization"]["team"]["members"]["nodes"].to_h { |member| [member["login"], member["name"]] }
// 421:   end
// 422:
// 423:   sig {
// 424:     params(user: String)
// 425:       .returns(
// 426:         T::Array[{
// 427:           closest_tier_monthly_amount: Integer,
// 428:           login:                       String,
// 429:           monthly_amount:              Integer,
// 430:           name:                        String,
// 431:         }],
// 432:       )
// 433:   }
// 434:   def self.sponsorships(user)
// 435:     query = <<~EOS
// 436:         query($user: String!, $after: String) { organization(login: $user) {
// 437:           sponsorshipsAsMaintainer(first: 100, after: $after) {
// 438:             pageInfo {
// 439:               hasNextPage
// 440:               endCursor
// 441:             }
// 442:             nodes {
// 443:               tier {
// 444:                 monthlyPriceInDollars
// 445:                 closestLesserValueTier {
// 446:                   monthlyPriceInDollars
// 447:                 }
// 448:               }
// 449:               sponsorEntity {
// 450:                 ... on Organization { login name }
// 451:                 ... on User { login name }
// 452:               }
// 453:             }
// 454:           }
// 455:         }
// 456:       }
// 457:     EOS
// 458:
// 459:     sponsorships = T.let([], T::Array[T::Hash[String, T.untyped]])
// 460:     errors = T.let([], T::Array[T::Hash[String, T.untyped]])
// 461:
// 462:     API.paginate_graphql(query, variables: { user: }, scopes: ["user"], raise_errors: false) do |result|
// 463:       # Some organisations do not permit themselves to be queried through the
// 464:       # API like this and raise an error so handle these errors later.
// 465:       # This has been reported to GitHub.
// 466:       errors += result["errors"] if result["errors"].present?
// 467:
// 468:       current_sponsorships = result.dig("data", "organization", "sponsorshipsAsMaintainer")
// 469:       # if `current_sponsorships` is blank, then there should be errors to report.
// 470:       next { "hasNextPage" => false } if current_sponsorships.blank?
// 471:
// 472:       # The organisations mentioned above will show up as nil nodes.
// 473:       if (nodes = current_sponsorships["nodes"].compact.presence)
// 474:         sponsorships += nodes
// 475:       end
// 476:
// 477:       current_sponsorships.fetch("pageInfo")
// 478:     end
// 479:
// 480:     # Only raise errors if we didn't get any sponsorships.
// 481:     raise API::Error, errors.map { |e| e["message"] }.join("\n") if sponsorships.blank? && errors.present?
// 482:
// 483:     sponsorships.map do |sponsorship|
// 484:       sponsor = sponsorship["sponsorEntity"]
// 485:       tier = sponsorship["tier"].presence || {}
// 486:       monthly_amount = tier["monthlyPriceInDollars"].presence || 0
// 487:       closest_tier = tier["closestLesserValueTier"].presence || {}
// 488:       closest_tier_monthly_amount = closest_tier["monthlyPriceInDollars"].presence || 0
// 489:
// 490:       {
// 491:         name:                        sponsor["name"].presence || sponsor["login"],
// 492:         login:                       sponsor["login"],
// 493:         monthly_amount:,
// 494:         closest_tier_monthly_amount:,
// 495:       }
// 496:     end
// 497:   end
// 498:
// 499:   sig { params(user: String, repo: String, ref: T.nilable(String)).returns(T.nilable(String)) }
// 500:   def self.get_repo_license(user, repo, ref: nil)
// 501:     url = "#{API_URL}/repos/#{user}/#{repo}/license"
// 502:     url += "?ref=#{ref}" if ref.present?
// 503:     response = API.open_rest(url)
// 504:     return unless response.key?("license")
// 505:
// 506:     response["license"]["spdx_id"]
// 507:   rescue API::HTTPNotFoundError
// 508:     nil
// 509:   rescue API::AuthenticationFailedError => e
// 510:     raise unless e.message.match?(API::GITHUB_IP_ALLOWLIST_ERROR)
// 511:   end
// 512:
// 513:   sig { params(name: String, version: T.nilable(String)).returns(Regexp) }
// 514:   def self.pull_request_title_regex(name, version = nil)
// 515:     return /(^|\s)#{Regexp.quote(name)}(:|,|\s|$)/i if version.blank?
// 516:
// 517:     /(^|\s)#{Regexp.quote(name)}(:|,|\s)(.*\s)?#{Regexp.quote(version)}(:|,|\s|$)/i
// 518:   end
// 519:
// 520:   sig {
// 521:     params(name: String, tap_remote_repo: String, state: T.nilable(String), version: T.nilable(String))
// 522:       .returns(T::Array[T::Hash[String, T.untyped]])
// 523:   }
// 524:   def self.fetch_pull_requests(name, tap_remote_repo, state: nil, version: nil)
// 525:     return [] if Homebrew::EnvConfig.no_github_api?
// 526:
// 527:     regex = pull_request_title_regex(name, version)
// 528:     query = "is:pr #{name} #{version}".strip
// 529:
// 530:     # Unauthenticated users cannot use GraphQL so use search REST API instead.
// 531:     # Limit for this is 30/minute so is usually OK unless you're spamming bump PRs (e.g. CI).
// 532:     if API.credentials_type == :none
// 533:       return issues_for_formula(query, tap_remote_repo:, state:).select do |pr|
// 534:         pr["html_url"].include?("/pull/") && regex.match?(pr["title"])
// 535:       end
// 536:     elsif state == "open" && ENV["GITHUB_REPOSITORY_OWNER"] == "Homebrew"
// 537:       # Try use PR API, which might be cheaper on rate limits in some cases.
// 538:       # The rate limit of the search API under GraphQL is unclear as it
// 539:       # costs the same as any other query according to /rate_limit.
// 540:       # The PR API is also not very scalable so limit to Homebrew CI.
// 541:       return fetch_open_pull_requests(name, tap_remote_repo, version:)
// 542:     end
// 543:
// 544:     query += " repo:#{tap_remote_repo} in:title"
// 545:     query += " state:#{state}" if state.present?
// 546:     graphql_query = <<~EOS
// 547:       query($query: String!, $after: String) {
// 548:         search(query: $query, type: ISSUE, first: 100, after: $after) {
// 549:           nodes {
// 550:             ... on PullRequest {
// 551:               number
// 552:               title
// 553:               url
// 554:               state
// 555:             }
// 556:           }
// 557:           pageInfo {
// 558:             hasNextPage
// 559:             endCursor
// 560:           }
// 561:         }
// 562:       }
// 563:     EOS
// 564:     variables = { query: }
// 565:
// 566:     pull_requests = []
// 567:     API.paginate_graphql(graphql_query, variables:) do |result|
// 568:       data = result["search"]
// 569:       pull_requests.concat(data["nodes"].select { |pr| regex.match?(pr["title"]) })
// 570:       data["pageInfo"]
// 571:     end
// 572:     pull_requests.map! do |pr|
// 573:       pr.merge({
// 574:         "html_url" => pr.delete("url"),
// 575:         "state"    => pr.fetch("state").downcase,
// 576:       })
// 577:     end
// 578:   rescue API::RateLimitExceededError => e
// 579:     opoo e.message
// 580:     pull_requests || []
// 581:   end
// 582:
// 583:   sig {
// 584:     params(name: String, tap_remote_repo: String, version: T.nilable(String))
// 585:       .returns(T::Array[T::Hash[String, String]])
// 586:   }
// 587:   def self.fetch_open_pull_requests(name, tap_remote_repo, version: nil)
// 588:     return [] if tap_remote_repo.blank?
// 589:
// 590:     # Bust the cache every three minutes.
// 591:     cache_expiry = 3 * 60
// 592:     cache_epoch = Time.now - (Time.now.to_i % cache_expiry)
// 593:     cache_key = "#{tap_remote_repo}_#{cache_epoch.to_i}"
// 594:
// 595:     @open_pull_requests ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
// 596:     @open_pull_requests[cache_key] ||= begin
// 597:       query = <<~EOS
// 598:         query($owner: String!, $repo: String!, $states: [PullRequestState!], $after: String) {
// 599:           repository(owner: $owner, name: $repo) {
// 600:             pullRequests(states: $states, first: 100, after: $after) {
// 601:               nodes {
// 602:                 number
// 603:                 title
// 604:                 url
// 605:               }
// 606:               pageInfo {
// 607:                 hasNextPage
// 608:                 endCursor
// 609:               }
// 610:             }
// 611:           }
// 612:         }
// 613:       EOS
// 614:       owner, repo = tap_remote_repo.split("/")
// 615:       variables = { owner:, repo:, states: ["OPEN"] }
// 616:
// 617:       pull_requests = []
// 618:       API.paginate_graphql(query, variables:) do |result|
// 619:         data = result.dig("repository", "pullRequests")
// 620:         pull_requests.concat(data["nodes"])
// 621:         data["pageInfo"]
// 622:       end
// 623:       pull_requests
// 624:     end
// 625:
// 626:     regex = pull_request_title_regex(name, version)
// 627:     @open_pull_requests[cache_key].select { |pr| regex.match?(pr["title"]) }
// 628:                                   .map { |pr| pr.merge("html_url" => pr.delete("url")) }
// 629:   rescue API::RateLimitExceededError => e
// 630:     opoo e.message
// 631:     pull_requests || []
// 632:   end
// 633:
// 634:   # Check for duplicate pull requests that modify the same file.
// 635:   #
// 636:   # Exits the process on duplicates if `strict` or both `version` and
// 637:   # `official_tap`, otherwise warns.
// 638:   #
// 639:   # @api internal
// 640:   sig {
// 641:     params(
// 642:       name:            String,
// 643:       tap_remote_repo: String,
// 644:       file:            String,
// 645:       quiet:           T::Boolean,
// 646:       state:           T.nilable(String),
// 647:       version:         T.nilable(String),
// 648:       official_tap:    T::Boolean,
// 649:       strict:          T::Boolean,
// 650:     ).void
// 651:   }
// 652:   def self.check_for_duplicate_pull_requests(name, tap_remote_repo, file:, quiet: false, state: nil,
// 653:                                              version: nil, official_tap: true, strict: false)
// 654:     pull_requests = fetch_pull_requests(name, tap_remote_repo, state:, version:)
// 655:
// 656:     pull_requests.select! do |pr|
// 657:       get_pull_request_changed_files(
// 658:         tap_remote_repo, pr["number"]
// 659:       ).any? { |f| f["filename"] == file }
// 660:     end
// 661:     return if pull_requests.blank?
// 662:
// 663:     confidence = version ? "are" : "might be"
// 664:     duplicates_message = <<~EOS
// 665:       These #{"#{state} " if state}pull requests #{confidence} duplicates:
// 666:       #{pull_requests.map { |pr| "#{pr["title"]} #{pr["html_url"]}" }.join("\n")}
// 667:     EOS
// 668:     error_message = <<~EOS
// 669:       Duplicate PRs must not be opened.
// 670:       Manually open these PRs if you are sure that they are not duplicates (and tell us that in the PR).
// 671:     EOS
// 672:
// 673:     if strict || (version && official_tap)
// 674:       odie <<~EOS
// 675:         #{duplicates_message.chomp}
// 676:         #{error_message}
// 677:       EOS
// 678:     elsif !official_tap
// 679:       opoo duplicates_message
// 680:     elsif quiet
// 681:       opoo error_message
// 682:     else
// 683:       opoo <<~EOS
// 684:         #{duplicates_message.chomp}
// 685:         #{error_message}
// 686:       EOS
// 687:     end
// 688:   end
// 689:
// 690:   sig { params(tap_remote_repo: String, pull_request: T.any(String, Integer)).returns(T::Array[T.untyped]) }
// 691:   def self.get_pull_request_changed_files(tap_remote_repo, pull_request)
// 692:     files = []
// 693:     API.paginate_rest(url_to("repos", tap_remote_repo, "pulls", pull_request, "files")) do |result|
// 694:       files.concat(result)
// 695:     end
// 696:     files
// 697:   end
// 698:
// 699:   sig {
// 700:     params(user: String, repo: String, pull_request: T.any(String, Integer), per_page: Integer)
// 701:       .returns(T::Array[String])
// 702:   }
// 703:   def self.pull_request_commits(user, repo, pull_request, per_page: MAX_PER_PAGE)
// 704:     pr_data = API.open_rest(url_to("repos", user, repo, "pulls", pull_request))
// 705:     commits_api = pr_data["commits_url"]
// 706:     commit_count = pr_data["commits"]
// 707:     commits = []
// 708:
// 709:     if commit_count > API_MAX_ITEMS
// 710:       raise API::Error, "Getting #{commit_count} commits would exceed limit of #{API_MAX_ITEMS} API items!"
// 711:     end
// 712:
// 713:     API.paginate_rest(commits_api, per_page:) do |result, page|
// 714:       commits.concat(result.map { |c| c["sha"] })
// 715:
// 716:       return commits if commits.length == commit_count
// 717:
// 718:       if result.empty? || page * per_page >= commit_count
// 719:         raise API::Error, "Expected #{commit_count} commits but actually got #{commits.length}!"
// 720:       end
// 721:     end
// 722:
// 723:     commits
// 724:   end
// 725:
// 726:   sig { params(user: String, repo: String, pull_request: T.any(String, Integer)).returns(T::Array[String]) }
// 727:   def self.pull_request_labels(user, repo, pull_request)
// 728:     pr_data = API.open_rest(url_to("repos", user, repo, "pulls", pull_request))
// 729:     pr_data["labels"].map { |label| label["name"] }
// 730:   end
// 731:
// 732:   sig {
// 733:     params(user: String, repo: String, ref: String, version: Version,
// 734:            length: T.nilable(Integer)).returns(T.nilable(String))
// 735:   }
// 736:   def self.last_commit(user, repo, ref, version, length: nil)
// 737:     return if Homebrew::EnvConfig.no_github_api?
// 738:
// 739:     require "utils/curl"
// 740:     result = Utils::Curl.curl_output(
// 741:       "--silent", "--head", "--location",
// 742:       "--header", "Accept: application/vnd.github.sha",
// 743:       url_to("repos", user, repo, "commits", ref).to_s
// 744:     )
// 745:
// 746:     return unless result.status.success?
// 747:
// 748:     commit = result.stdout[/^ETag: "(\h+)"/i, 1]
// 749:     return if commit.blank?
// 750:
// 751:     if length
// 752:       return if commit.length < length
// 753:
// 754:       commit = commit[0, length]
// 755:       odie "commit does not exist" unless commit
// 756:
// 757:       # We return nil if the following fails as we currently don't have a way to
// 758:       # determine the reason for the failure. This means we can't distinguish a
// 759:       # GitHub API rate limit from a non-unique short commit where the latter
// 760:       # needs (n+1) or more characters to match `git rev-parse --short=n`.
// 761:       return if multiple_short_commits_exist?(user, repo, commit)
// 762:     end
// 763:
// 764:     version.update_commit(commit)
// 765:     commit
// 766:   end
// 767:
// 768:   sig { params(user: String, repo: String, commit: String).returns(T::Boolean) }
// 769:   def self.multiple_short_commits_exist?(user, repo, commit)
// 770:     return false if Homebrew::EnvConfig.no_github_api?
// 771:
// 772:     require "utils/curl"
// 773:     result = Utils::Curl.curl_output(
// 774:       "--silent", "--head", "--location",
// 775:       "--header", "Accept: application/vnd.github.sha",
// 776:       "--output", File::NULL,
// 777:       # This is a Curl format token, not a Ruby one.
// 778:       # rubocop:disable Style/FormatStringToken
// 779:       "--write-out", "%{http_code}",
// 780:       # rubocop:enable Style/FormatStringToken
// 781:       url_to("repos", user, repo, "commits", commit).to_s
// 782:     )
// 783:
// 784:     return true unless result.status.success?
// 785:     return true if (output = result.stdout).blank?
// 786:
// 787:     output != "200"
// 788:   end
// 789:
// 790:   MAXIMUM_OPEN_PRS = 15
// 791:
// 792:   sig { params(tap: T.nilable(Tap)).returns(T::Boolean) }
// 793:   def self.too_many_open_prs?(tap)
// 794:     # We don't enforce unofficial taps.
// 795:     return false if tap.nil? || !tap.official?
// 796:
// 797:     # BrewTestBot can open as many PRs as it wants.
// 798:     return false if ENV["HOMEBREW_TEST_BOT_AUTOBUMP"].present?
// 799:
// 800:     odie "Cannot count PRs as `$HOMEBREW_NO_GITHUB_API` is set!" if Homebrew::EnvConfig.no_github_api?
// 801:
// 802:     query = <<~EOS
// 803:       query($after: String) {
// 804:         viewer {
// 805:           login
// 806:           pullRequests(first: 100, states: OPEN, after: $after) {
// 807:             totalCount
// 808:             nodes {
// 809:               baseRepository {
// 810:                 owner {
// 811:                   login
// 812:                 }
// 813:               }
// 814:             }
// 815:             pageInfo {
// 816:               hasNextPage
// 817:               endCursor
// 818:             }
// 819:           }
// 820:         }
// 821:       }
// 822:     EOS
// 823:     puts
// 824:
// 825:     homebrew_prs_count = 0
// 826:
// 827:     begin
// 828:       API.paginate_graphql(query) do |result|
// 829:         data = result.fetch("viewer")
// 830:         github_user = data.fetch("login")
// 831:
// 832:         # BrewTestBot can open as many PRs as it wants.
// 833:         return false if github_user.casecmp?("brewtestbot")
// 834:
// 835:         pull_requests = data.fetch("pullRequests")
// 836:         return false if pull_requests.fetch("totalCount") < MAXIMUM_OPEN_PRS
// 837:
// 838:         homebrew_prs_count += pull_requests.fetch("nodes").count do |node|
// 839:           node.dig("baseRepository", "owner", "login").casecmp?("homebrew")
// 840:         end
// 841:         return true if homebrew_prs_count >= MAXIMUM_OPEN_PRS
// 842:
// 843:         pull_requests.fetch("pageInfo")
// 844:       end
// 845:     rescue => e
// 846:       # Ignore SAML access errors (https://github.com/Homebrew/brew/issues/18610) and related
// 847:       # IP allow list errors (https://github.com/orgs/Homebrew/discussions/6263)
// 848:       return false if e.message.include?("Resource protected by organization SAML enforcement") ||
// 849:                       e.message.include?("your IP address is not permitted to access this resource")
// 850:
// 851:       raise
// 852:     end
// 853:
// 854:     false
// 855:   end
// 856:
// 857:   sig { params(organisation: String, from: String, to: String, verbose: T::Boolean).returns(T::Array[String]) }
// 858:   def self.organisation_repositories(organisation, from, to, verbose)
// 859:     from_date = Date.parse(from)
// 860:     to_date = Date.parse(to)
// 861:
// 862:     rest_api_url = "#{GitHub::API_URL}/orgs/#{organisation}/repos"
// 863:     params = "type=sources"
// 864:     repositories = []
// 865:     GitHub::API.paginate_rest(rest_api_url, per_page: MAX_PER_PAGE, additional_query_params: params) do |result|
// 866:       repositories.concat(result)
// 867:     end
// 868:     repositories.filter_map do |repository|
// 869:       pushed_at = Date.parse(repository.fetch("pushed_at"))
// 870:       created_at = Date.parse(repository.fetch("created_at"))
// 871:       archived_at = Date.parse(repository.fetch("archived_at", from))
// 872:       full_name = repository.fetch("full_name")
// 873:
// 874:       not_pushed = pushed_at < from_date
// 875:       not_created = created_at > to_date
// 876:       archived = archived_at < from_date
// 877:
// 878:       if not_pushed || not_created || archived
// 879:         if verbose
// 880:           reasons = []
// 881:           reasons << "not pushed" if not_pushed
// 882:           reasons << "not created" if not_created
// 883:           reasons << "archived" if archived
// 884:           opoo "Repository #{full_name} #{reasons.join(", ")} from #{from_date} to #{to_date}. Skipping."
// 885:         end
// 886:
// 887:         next
// 888:       end
// 889:
// 890:       full_name
// 891:     end
// 892:   end
// 893:
// 894:   sig {
// 895:     params(user: String, reviewed_by: String, from: T.nilable(String), to: T.nilable(String))
// 896:       .returns(T::Array[T::Hash[String, T.untyped]])
// 897:   }
// 898:   def self.search_approved_pull_requests_in_user_or_organisation(user, reviewed_by, from:, to:)
// 899:     search_issues("", is: "pr", review: "approved", user:, reviewed_by:, from:, to:)
// 900:   rescue GitHub::API::ValidationFailedError
// 901:     opoo "Couldn't search GitHub for PRs reviewed by #{reviewed_by}. Their profile might be private. Defaulting to 0."
// 902:     []
// 903:   end
// 904: end
