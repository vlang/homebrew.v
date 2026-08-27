module utils

import brew_runtime

// Translated from Homebrew/brew `test/utils/github_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports an inaccessible team without assuming the token scope is missing" do` at line 8.
pub fn ruby_github_spec_l8_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "fetches the main branch commit by default" do` at line 26.
pub fn ruby_github_spec_l26_d2_fetches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetches', ...args)
}

// Ruby it `it "fetches a commit for a branch ref with path separators" do` at line 37.
pub fn ruby_github_spec_l37_d3_fetches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetches', ...args)
}

// Ruby it `it "builds a query with the given hash parameters formatted as key:value" do` at line 50.
pub fn ruby_github_spec_l50_d4_builds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('builds', ...args)
}

// Ruby it `it "adds a variable number of top-level string parameters to the query when provided" do` at line 55.
pub fn ruby_github_spec_l55_d5_adds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('adds', ...args)
}

// Ruby it `it "turns array values into multiple key:value parameters" do` at line 60.
pub fn ruby_github_spec_l60_d6_turns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('turns', ...args)
}

// Ruby it `it "queries GitHub issues with the passed parameters" do` at line 67.
pub fn ruby_github_spec_l67_d7_queries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('queries', ...args)
}

// Ruby it `it "posts a GitHub issue comment" do` at line 86.
pub fn ruby_github_spec_l86_d8_posts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('posts', ...args)
}

// Ruby it `it "can get reviews for a pull request" do` at line 100.
pub fn ruby_github_spec_l100_d9_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "matches uppercase expected pull request head SHAs" do` at line 107.
pub fn ruby_github_spec_l107_d10_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "fails when the pull request head has changed" do` at line 128.
pub fn ruby_github_spec_l128_d11_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "fails to find a nonexistent workflow" do` at line 153.
pub fn ruby_github_spec_l153_d12_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "fails to find artifacts that don't exist" do` at line 161.
pub fn ruby_github_spec_l161_d13_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "gets artifact URLs" do` at line 170.
pub fn ruby_github_spec_l170_d14_gets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gets', ...args)
}

// Ruby let `let(:hashes) do` at line 180.
pub fn ruby_github_spec_l180_d15_hashes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hashes', ...args)
}

// Ruby it `it "gets commit hashes for a pull request" do` at line 187.
pub fn ruby_github_spec_l187_d16_gets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gets', ...args)
}

// Ruby it `it "gets commit hashes for a paginated pull request API response" do` at line 191.
pub fn ruby_github_spec_l191_d17_gets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gets', ...args)
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
