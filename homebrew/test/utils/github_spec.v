module utils

import homebrew.utils as github_core
import homebrew.utils.github as github_api
import x.json2

// Translated from Homebrew/brew `test/utils/github_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn github_spec_inaccessible_graphql(_ github_core.GitHubGraphqlRequest) !json2.Any {
	return json2.Any({
		'organization': json2.Any({
			'teams': json2.Any({
				'nodes': json2.Any([]json2.Any{})
			})
			'team':  json2.null
		})
	})
}

fn github_spec_commit_main(request github_api.GitHubApiCommitRequest) !json2.Any {
	if request.url != 'https://api.github.com/repos/Homebrew/brew/commits/main' || request.request_method != 'GET' {
		return error('unexpected commit request: ${request}')
	}
	return json2.Any({
		'sha': json2.Any('abc123')
	})
}

fn github_spec_commit_branch(request github_api.GitHubApiCommitRequest) !json2.Any {
	if request.url != 'https://api.github.com/repos/Homebrew/brew/commits/feature%2Ffoo' || request.request_method != 'GET' {
		return error('unexpected commit request: ${request}')
	}
	return json2.Any({
		'sha': json2.Any('def456')
	})
}

fn github_spec_search_rest(request github_core.GitHubRestRequest) !json2.Any {
	expected := 'https://api.github.com/search/issues?q=brew+search+repo%3AHomebrew%2Flegacy-homebrew+author%3AMikeMcQuaid+type%3Aissue+no%3Amilestone&per_page=100'
	if request.url != expected {
		return error('unexpected search URL: ${request.url}')
	}
	return json2.Any({
		'items': json2.Any([
			json2.Any({
				'title': json2.Any('Shall we move more things to taps?')
			}),
		])
	})
}

fn github_spec_comment_rest(request github_core.GitHubRestRequest) !json2.Any {
	if request.url != 'https://api.github.com/repos/Homebrew/homebrew-core/issues/123/comments' || request.scopes != [
		'repo',
	] {
		return error('unexpected comment request: ${request}')
	}
	data := if request.data is map[string]json2.Any {
		request.data
	} else {
		return error('missing comment data')
	}
	if (data['body'] or { json2.null }).str() != 'Comment body' {
		return error('unexpected comment body')
	}
	return json2.Any({
		'html_url': json2.Any('https://github.com/Homebrew/homebrew-core/issues/123#issuecomment-1')
	})
}

fn github_spec_empty_reviews(_ github_core.GitHubGraphqlRequest) !json2.Any {
	return json2.Any({
		'repository': json2.Any({
			'pullRequest': json2.Any({
				'reviews': json2.Any({
					'nodes': json2.Any([]json2.Any{})
				})
			})
		})
	})
}

fn github_spec_workflow_rest(request github_core.GitHubRestRequest) !json2.Any {
	if request.url.contains('/actions/workflows/') {
		return json2.Any({
			'id': json2.Any(1)
		})
	}
	if request.url.ends_with('/pulls/50678') {
		return json2.Any({
			'commits_url': json2.Any('https://api.github.com/pr-commits')
			'commits':     json2.Any(2)
		})
	}
	return error('unexpected workflow REST request: ${request.url}')
}

fn github_spec_uppercase_workflow(_ github_core.GitHubGraphqlRequest) !json2.Any {
	return github_spec_workflow_graphql_payload('abcdef', []json2.Any{})
}

fn github_spec_changed_workflow(_ github_core.GitHubGraphqlRequest) !json2.Any {
	return github_spec_workflow_graphql_payload('actual', []json2.Any{})
}

fn github_spec_artifact_workflow(_ github_core.GitHubGraphqlRequest) !json2.Any {
	suite := json2.Any({
		'status':      json2.Any('COMPLETED')
		'workflowRun': json2.Any({
			'databaseId': json2.Any(99)
			'url':        json2.Any('https://github.com/Homebrew/homebrew-core/actions/runs/99')
			'workflow':   json2.Any({
				'databaseId': json2.Any(1)
			})
		})
	})
	return github_spec_workflow_graphql_payload('abcdef', [suite])
}

fn github_spec_workflow_graphql_payload(oid string, suites []json2.Any) json2.Any {
	return json2.Any({
		'repository': json2.Any({
			'pullRequest': json2.Any({
				'commits': json2.Any({
					'nodes': json2.Any([
						json2.Any({
							'commit': json2.Any({
								'oid':         json2.Any(oid)
								'checkSuites': json2.Any({
									'nodes': json2.Any(suites)
								})
							})
						}),
					])
				})
			})
		})
	})
}

fn github_spec_artifacts(_ github_core.GitHubRestRequest) ![]json2.Any {
	return [json2.Any({
		'artifacts': json2.Any([
			json2.Any({
				'name':                 json2.Any('event_payload')
				'created_at':           json2.Any('2026-01-01T00:00:00Z')
				'archive_download_url': json2.Any('https://api.github.com/repos/Homebrew/homebrew-core/actions/artifacts/4457761305/zip')
			}),
		])
	})]
}

fn github_spec_commits(request github_core.GitHubRestRequest) ![]json2.Any {
	hashes := ['188606a4a9587365d930b02c98ad6857b1d00150', '25a71fe1ea1558415d6496d23834dc70778ddee5']
	if request.per_page == 1 {
		return hashes.map(json2.Any([json2.Any({
			'sha': json2.Any(it)
		})]))
	}
	return [json2.Any(hashes.map(json2.Any({
		'sha': json2.Any(it)
	})))]
}

// Ruby it `it "reports an inaccessible team without assuming the token scope is missing" do` at line 8.
pub fn ruby_github_spec_l8_d1_reports() bool {
	mut client := github_core.GitHubClient{ open_graphql: github_spec_inaccessible_graphql }
	client.members_by_team('Homebrew', 'maintainers') or {
		return err.msg() == 'Could not access the team Homebrew/maintainers. Please check that your GitHub account has access to the team and that your token has the required permissions.'
	}
	return false
}

// Ruby it `it "fetches the main branch commit by default" do` at line 26.
pub fn ruby_github_spec_l26_d2_fetches() !bool {
	commit := github_api.ruby_api_l364_d18_self_commit('Homebrew', 'brew', 'main', github_spec_commit_main)!
	return (commit['sha'] or { json2.null }).str() == 'abc123'
}

// Ruby it `it "fetches a commit for a branch ref with path separators" do` at line 37.
pub fn ruby_github_spec_l37_d3_fetches() !bool {
	commit := github_api.ruby_api_l364_d18_self_commit('Homebrew', 'brew', 'feature/foo', github_spec_commit_branch)!
	return (commit['sha'] or { json2.null }).str() == 'def456'
}

// Ruby it `it "builds a query with the given hash parameters formatted as key:value" do` at line 50.
pub fn ruby_github_spec_l50_d4_builds() bool {
	return github_core.ruby_github_l141_d14_self_search_query_string([], [
		github_core.GitHubQualifier{ key: 'user', values: ['Homebrew'] },
		github_core.GitHubQualifier{ key: 'repo', values: ['brew'] },
	], '', '') == 'q=user%3AHomebrew+repo%3Abrew&per_page=100'
}

// Ruby it `it "adds a variable number of top-level string parameters to the query when provided" do` at line 55.
pub fn ruby_github_spec_l55_d5_adds() bool {
	return github_core.ruby_github_l141_d14_self_search_query_string(['value1', 'value2'], [
		github_core.GitHubQualifier{ key: 'user', values: ['Homebrew'] },
	], '', '') == 'q=value1+value2+user%3AHomebrew&per_page=100'
}

// Ruby it `it "turns array values into multiple key:value parameters" do` at line 60.
pub fn ruby_github_spec_l60_d6_turns() bool {
	return github_core.ruby_github_l141_d14_self_search_query_string([], [
		github_core.GitHubQualifier{ key: 'user', values: ['Homebrew', 'caskroom'] },
	], '', '') == 'q=user%3AHomebrew+user%3Acaskroom&per_page=100'
}

// Ruby it `it "queries GitHub issues with the passed parameters" do` at line 67.
pub fn ruby_github_spec_l67_d7_queries() !bool {
	mut client := github_core.GitHubClient{ open_rest: github_spec_search_rest }
	issues := github_core.ruby_github_l30_d2_self_search_issues(mut client, 'brew search', [
		github_core.GitHubQualifier{ key: 'repo', values: ['Homebrew/legacy-homebrew'] },
		github_core.GitHubQualifier{ key: 'author', values: ['MikeMcQuaid'] },
		github_core.GitHubQualifier{ key: 'type', values: ['issue'] },
		github_core.GitHubQualifier{ key: 'no', values: ['milestone'] },
	], '', '')!
	return issues.len == 1 && (issues[0]['title'] or { json2.null }).str() == 'Shall we move more things to taps?'
}

// Ruby it `it "posts a GitHub issue comment" do` at line 86.
pub fn ruby_github_spec_l86_d8_posts() !bool {
	mut client := github_core.GitHubClient{ open_rest: github_spec_comment_rest }
	response := github_core.ruby_github_l50_d5_self_create_issue_comment(mut client, 'Homebrew/homebrew-core', '123', 'Comment body')!
	return (response['html_url'] or { json2.null }).str() == 'https://github.com/Homebrew/homebrew-core/issues/123#issuecomment-1'
}

// Ruby it `it "can get reviews for a pull request" do` at line 100.
pub fn ruby_github_spec_l100_d9_can() !bool {
	mut client := github_core.GitHubClient{ open_graphql: github_spec_empty_reviews }
	return github_core.ruby_github_l178_d17_self_repository_approved_reviews(mut client, 'Homebrew', 'homebrew-core', '1', 'deadbeef')!.len == 0
}

// Ruby it `it "matches uppercase expected pull request head SHAs" do` at line 107.
pub fn ruby_github_spec_l107_d10_matches() !bool {
	mut client := github_core.GitHubClient{
		open_rest: github_spec_workflow_rest
		open_graphql: github_spec_uppercase_workflow
	}
	workflow := github_core.ruby_github_l287_d24_self_get_workflow_run(mut client, 'Homebrew', 'homebrew-core', '1', 'tests.yml', 'bottles{,_*}', 'ABCDEF')!
	return workflow.check_suite.len == 0
}

// Ruby it `it "fails when the pull request head has changed" do` at line 128.
pub fn ruby_github_spec_l128_d11_fails() bool {
	mut client := github_core.GitHubClient{
		open_rest: github_spec_workflow_rest
		open_graphql: github_spec_changed_workflow
	}
	client.get_workflow_run('Homebrew', 'homebrew-core', '1', 'tests.yml', 'bottles{,_*}', 'expected') or { return err.msg().contains('Pull request #1 is at actual but expected expected') }
	return false
}

// Ruby it `it "fails to find a nonexistent workflow" do` at line 153.
pub fn ruby_github_spec_l153_d12_fails() !bool {
	mut client := github_core.GitHubClient{
		open_rest: github_spec_workflow_rest
		open_graphql: github_spec_uppercase_workflow
	}
	workflow := client.get_workflow_run('Homebrew', 'homebrew-core', '1', 'tests.yml', 'bottles{,_*}', '')!
	client.get_artifact_urls(workflow) or { return err.msg().contains('No matching check suite found') }
	return false
}

// Ruby it `it "fails to find artifacts that don't exist" do` at line 161.
pub fn ruby_github_spec_l161_d13_fails() !bool {
	mut client := github_core.GitHubClient{
		open_rest: github_spec_workflow_rest
		open_graphql: github_spec_artifact_workflow
		paginate_rest: github_spec_artifacts
	}
	workflow := client.get_workflow_run('Homebrew', 'homebrew-core', '252626', 'triage.yml', 'false_artifact', '')!
	client.get_artifact_urls(workflow) or { return err.msg().contains('No artifacts with the pattern') }
	return false
}

// Ruby it `it "gets artifact URLs" do` at line 170.
pub fn ruby_github_spec_l170_d14_gets() !bool {
	mut client := github_core.GitHubClient{
		open_rest: github_spec_workflow_rest
		open_graphql: github_spec_artifact_workflow
		paginate_rest: github_spec_artifacts
	}
	workflow := client.get_workflow_run('Homebrew', 'homebrew-core', '252626', 'triage.yml', 'event_payload', '')!
	return client.get_artifact_urls(workflow)! == [
		'https://api.github.com/repos/Homebrew/homebrew-core/actions/artifacts/4457761305/zip',
	]
}

// Ruby let `let(:hashes) do` at line 180.
pub fn ruby_github_spec_l180_d15_hashes() []string {
	return ['188606a4a9587365d930b02c98ad6857b1d00150', '25a71fe1ea1558415d6496d23834dc70778ddee5']
}

// Ruby it `it "gets commit hashes for a pull request" do` at line 187.
pub fn ruby_github_spec_l187_d16_gets() !bool {
	mut client := github_core.GitHubClient{
		open_rest: github_spec_workflow_rest
		paginate_rest: github_spec_commits
	}
	return client.pull_request_commits('Homebrew', 'legacy-homebrew', '50678', 100)! == ruby_github_spec_l180_d15_hashes()
}

// Ruby it `it "gets commit hashes for a paginated pull request API response" do` at line 191.
pub fn ruby_github_spec_l191_d17_gets() !bool {
	mut client := github_core.GitHubClient{
		open_rest: github_spec_workflow_rest
		paginate_rest: github_spec_commits
	}
	return client.pull_request_commits('Homebrew', 'legacy-homebrew', '50678', 1)! == ruby_github_spec_l180_d15_hashes()
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/github"
// 5:
// 6: RSpec.describe GitHub do
// 7:   describe "::members_by_team" do
// 8:     it "reports an inaccessible team without assuming the token scope is missing" do
// 9:       allow(GitHub::API).to receive(:open_graphql).and_return({
// 10:         "organization" => {
// 11:           "teams" => { "nodes" => [] },
// 12:           "team"  => nil,
// 13:         },
// 14:       })
// 15:
// 16:       expect { described_class.members_by_team("Homebrew", "maintainers") }
// 17:         .to raise_error(
// 18:           GitHub::API::Error,
// 19:           "Could not access the team Homebrew/maintainers. Please check that your GitHub account has access to the " \
// 20:           "team and that your token has the required permissions.",
// 21:         )
// 22:     end
// 23:   end
// 24:
// 25:   describe "::API.commit" do
// 26:     it "fetches the main branch commit by default" do
// 27:       commit = { "sha" => "abc123" }
// 28:
// 29:       expect(GitHub::API).to receive(:open_rest).with(
// 30:         "https://api.github.com/repos/Homebrew/brew/commits/main",
// 31:         request_method: :GET,
// 32:       ).and_return(commit)
// 33:
// 34:       expect(GitHub::API.commit("Homebrew", "brew")).to eq(commit)
// 35:     end
// 36:
// 37:     it "fetches a commit for a branch ref with path separators" do
// 38:       commit = { "sha" => "def456" }
// 39:
// 40:       expect(GitHub::API).to receive(:open_rest).with(
// 41:         "https://api.github.com/repos/Homebrew/brew/commits/feature%2Ffoo",
// 42:         request_method: :GET,
// 43:       ).and_return(commit)
// 44:
// 45:       expect(GitHub::API.commit("Homebrew", "brew", branch: "feature/foo")).to eq(commit)
// 46:     end
// 47:   end
// 48:
// 49:   describe "::search_query_string" do
// 50:     it "builds a query with the given hash parameters formatted as key:value" do
// 51:       query = described_class.search_query_string(user: "Homebrew", repo: "brew")
// 52:       expect(query).to eq("q=user%3AHomebrew+repo%3Abrew&per_page=100")
// 53:     end
// 54:
// 55:     it "adds a variable number of top-level string parameters to the query when provided" do
// 56:       query = described_class.search_query_string("value1", "value2", user: "Homebrew")
// 57:       expect(query).to eq("q=value1+value2+user%3AHomebrew&per_page=100")
// 58:     end
// 59:
// 60:     it "turns array values into multiple key:value parameters" do
// 61:       query = described_class.search_query_string(user: ["Homebrew", "caskroom"])
// 62:       expect(query).to eq("q=user%3AHomebrew+user%3Acaskroom&per_page=100")
// 63:     end
// 64:   end
// 65:
// 66:   describe "::search_issues" do
// 67:     it "queries GitHub issues with the passed parameters" do
// 68:       issue = { "title" => "Shall we move more things to taps?" }
// 69:
// 70:       expect(GitHub::API).to receive(:open_rest) do |uri|
// 71:         expect(uri.to_s).to eq("https://api.github.com/search/issues?" \
// 72:                                "q=brew+search+repo%3AHomebrew%2Flegacy-homebrew+" \
// 73:                                "author%3AMikeMcQuaid+type%3Aissue+no%3Amilestone&per_page=100")
// 74:         { "items" => [issue] }
// 75:       end
// 76:
// 77:       expect(described_class.search_issues("brew search",
// 78:                                            repo:   "Homebrew/legacy-homebrew",
// 79:                                            author: "MikeMcQuaid",
// 80:                                            type:   "issue",
// 81:                                            no:     "milestone")).to eq([issue])
// 82:     end
// 83:   end
// 84:
// 85:   describe "::create_issue_comment" do
// 86:     it "posts a GitHub issue comment" do
// 87:       response = { "html_url" => "https://github.com/Homebrew/homebrew-core/issues/123#issuecomment-1" }
// 88:
// 89:       expect(GitHub::API).to receive(:open_rest).with(
// 90:         "https://api.github.com/repos/Homebrew/homebrew-core/issues/123/comments",
// 91:         data:   { body: "Comment body" },
// 92:         scopes: GitHub::CREATE_ISSUE_FORK_OR_PR_SCOPES,
// 93:       ).and_return(response)
// 94:
// 95:       expect(described_class.create_issue_comment("Homebrew/homebrew-core", 123, "Comment body")).to eq(response)
// 96:     end
// 97:   end
// 98:
// 99:   describe "::repository_approved_reviews", :needs_network do
// 100:     it "can get reviews for a pull request" do
// 101:       reviews = described_class.repository_approved_reviews("Homebrew", "homebrew-core", 1, commit: "deadbeef")
// 102:       expect(reviews).to eq([])
// 103:     end
// 104:   end
// 105:
// 106:   describe "::get_workflow_run" do
// 107:     it "matches uppercase expected pull request head SHAs" do
// 108:       allow(GitHub::API).to receive_messages(open_rest: { "id" => 1 }, open_graphql: {
// 109:         "repository" => {
// 110:           "pullRequest" => {
// 111:             "commits" => {
// 112:               "nodes" => [
// 113:                 {
// 114:                   "commit" => {
// 115:                     "oid"         => "abcdef",
// 116:                     "checkSuites" => { "nodes" => [] },
// 117:                   },
// 118:                 },
// 119:               ],
// 120:             },
// 121:           },
// 122:         },
// 123:       })
// 124:
// 125:       expect(described_class.get_workflow_run("Homebrew", "homebrew-core", "1", head_sha: "ABCDEF").first).to eq([])
// 126:     end
// 127:
// 128:     it "fails when the pull request head has changed" do
// 129:       allow(GitHub::API).to receive_messages(open_rest: { "id" => 1 }, open_graphql: {
// 130:         "repository" => {
// 131:           "pullRequest" => {
// 132:             "commits" => {
// 133:               "nodes" => [
// 134:                 {
// 135:                   "commit" => {
// 136:                     "oid"         => "actual",
// 137:                     "checkSuites" => { "nodes" => [] },
// 138:                   },
// 139:                 },
// 140:               ],
// 141:             },
// 142:           },
// 143:         },
// 144:       })
// 145:
// 146:       expect do
// 147:         described_class.get_workflow_run("Homebrew", "homebrew-core", "1", head_sha: "expected")
// 148:       end.to raise_error(GitHub::API::Error, /Pull request #1 is at actual but expected expected/)
// 149:     end
// 150:   end
// 151:
// 152:   describe "::get_artifact_urls", :needs_network do
// 153:     it "fails to find a nonexistent workflow" do
// 154:       expect do
// 155:         described_class.get_artifact_urls(
// 156:           described_class.get_workflow_run("Homebrew", "homebrew-core", "1"),
// 157:         )
// 158:       end.to raise_error(/No matching check suite found/)
// 159:     end
// 160:
// 161:     it "fails to find artifacts that don't exist" do
// 162:       expect do
// 163:         described_class.get_artifact_urls(
// 164:           described_class.get_workflow_run("Homebrew", "homebrew-core", "252626",
// 165:                                            workflow_id: "triage.yml", artifact_pattern: "false_artifact"),
// 166:         )
// 167:       end.to raise_error(/No artifacts with the pattern .+ were found/)
// 168:     end
// 169:
// 170:     it "gets artifact URLs" do
// 171:       urls = described_class.get_artifact_urls(
// 172:         described_class.get_workflow_run("Homebrew", "homebrew-core", "252626",
// 173:                                          workflow_id: "triage.yml", artifact_pattern: "event_payload"),
// 174:       )
// 175:       expect(urls).to eq(["https://api.github.com/repos/Homebrew/homebrew-core/actions/artifacts/4457761305/zip"])
// 176:     end
// 177:   end
// 178:
// 179:   describe "::pull_request_commits", :needs_network do
// 180:     let(:hashes) do
// 181:       %w[
// 182:         188606a4a9587365d930b02c98ad6857b1d00150
// 183:         25a71fe1ea1558415d6496d23834dc70778ddee5
// 184:       ]
// 185:     end
// 186:
// 187:     it "gets commit hashes for a pull request" do
// 188:       expect(described_class.pull_request_commits("Homebrew", "legacy-homebrew", 50678)).to eq(hashes)
// 189:     end
// 190:
// 191:     it "gets commit hashes for a paginated pull request API response" do
// 192:       expect(described_class.pull_request_commits("Homebrew", "legacy-homebrew", 50678, per_page: 1)).to eq(hashes)
// 193:     end
// 194:   end
// 195: end
