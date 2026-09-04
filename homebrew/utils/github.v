module utils

import time
import x.json2

// Translated from Homebrew/brew `utils/github.rb`.
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

pub type GitHubOpenRest = fn (GitHubRestRequest) !json2.Any

pub type GitHubOpenGraphql = fn (GitHubGraphqlRequest) !json2.Any

pub type GitHubPaginateRest = fn (GitHubRestRequest) ![]json2.Any

pub type GitHubPaginateGraphql = fn (GitHubGraphqlRequest) ![]json2.Any

pub type GitHubCurl = fn (GitHubCurlRequest) !GitHubCurlResponse

pub type GitHubWarning = fn (string)

pub type GitHubVersionUpdate = fn (string)

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
