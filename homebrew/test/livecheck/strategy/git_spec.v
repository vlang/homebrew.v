module strategy

import homebrew.livecheck.strategy as git_core

// Translated from Homebrew/brew `test/livecheck/strategy/git_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct GitSpecMatchData {
pub:
	fetched               git_core.GitMatchData
	fetched_default_regex git_core.GitMatchData
	default_result        git_core.GitMatchData
	cached                git_core.GitMatchData
	cached_default        git_core.GitMatchData
}

fn git_spec_normal_content() string {
	return [
		'e0f1758045b8194f77a43050ca433cbe928f27fb\trefs/tags/brew/1.2',
		'5a45d5c9e39da019b2feaf63a1321e2f0336769c\trefs/tags/brew/1.2.1',
		'81426bcda28e391b29770747ecd86bf8324d2441\trefs/tags/brew/1.2.2',
		'50631d8ae8885d6b3a51814f4529c0b2e5d424fa\trefs/tags/brew/1.2.3',
		'cd58e678c52ef269d2ba5153a9dd0f83864ab7b4\trefs/tags/brew/1.2.4^{}',
		'db2b77f42b1c1fa7bb74f13ce798290084aa89f3\trefs/tags/1.2.5',
	].join('\n') + '\n'
}

fn git_spec_regex(name string) git_core.GitRegex {
	return ruby_git_spec_l11_d4_regexes()[name]
}

fn git_spec_no_output_runner(_ git_core.GitCommand) !git_core.GitCommandOutput {
	return git_core.GitCommandOutput{}
}

fn git_spec_stdout_runner(_ git_core.GitCommand) !git_core.GitCommandOutput {
	return git_core.GitCommandOutput{
		stdout: git_spec_normal_content()
		has_stdout: true
	}
}

fn git_spec_stderr_runner(_ git_core.GitCommand) !git_core.GitCommandOutput {
	return git_core.GitCommandOutput{
		stderr: ruby_git_spec_l47_d8_messages().join('\n')
		has_stderr: true
	}
}

fn git_spec_both_runner(command git_core.GitCommand) !git_core.GitCommandOutput {
	mut output := git_spec_stdout_runner(command)!
	return git_core.GitCommandOutput{
		...output
		stderr: ruby_git_spec_l47_d8_messages().join('\n')
		has_stderr: true
	}
}

fn git_spec_content_fetcher(url string) !git_core.GitRemoteData {
	return git_core.git_ls_remote_tags(url, git_spec_stdout_runner)
}

fn git_spec_error_fetcher(url string) !git_core.GitRemoteData {
	return git_core.git_ls_remote_tags(url, git_spec_stderr_runner)
}

fn git_spec_unused_fetcher(_ string) !git_core.GitRemoteData {
	return error('cached content must not fetch')
}

fn git_spec_first_block(_ []string, _ ?git_core.GitRegex) !git_core.GitBlockReturn {
	matches := ruby_git_spec_l40_d7_matches()
	default_matches := matches['default'].clone()
	return git_core.GitBlockReturn{
		kind: .string_value
		value: default_matches[0]
	}
}

fn git_spec_normalize_block(tags []string,
	match_regex ?git_core.GitRegex) !git_core.GitBlockReturn {
	regex_value := match_regex or { return error('strategy regex is required') }
	versions := git_core.git_versions_from_tags(tags, regex_value)!
	return git_core.GitBlockReturn{
		kind: .array
		values: versions.map(git_core.GitBlockItem{
			kind: .string_value
			value: it.replace('-', '.')
		})
	}
}

fn git_spec_literal_block(_ []string, _ ?git_core.GitRegex) !git_core.GitBlockReturn {
	return git_core.GitBlockReturn{
		kind: .string_value
		value: '1.2.3'
	}
}

fn git_spec_nil_block(_ []string, _ ?git_core.GitRegex) !git_core.GitBlockReturn {
	return git_core.GitBlockReturn{ kind: .nil_value }
}

fn git_spec_invalid_block(_ []string, _ ?git_core.GitRegex) !git_core.GitBlockReturn {
	return git_core.GitBlockReturn{ kind: .invalid }
}

fn git_spec_brew_block(tags []string, _ ?git_core.GitRegex) !git_core.GitBlockReturn {
	versions := git_core.git_versions_from_tags(tags, git_spec_regex('brew'))!
	return git_core.GitBlockReturn{
		kind: .array
		values: versions.map(git_core.GitBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn git_spec_matches(values []string) map[string]string {
	mut matches := map[string]string{}
	for value in values {
		matches[value] = value
	}
	return matches
}

// Ruby subject `subject(:git) { described_class }` at line 7.
pub fn ruby_git_spec_l7_d1_git() string {
	return 'Git'
}

// Ruby let `let(:git_url) { "https://github.com/Homebrew/brew.git" }` at line 9.
pub fn ruby_git_spec_l9_d2_git_url() string {
	return 'https://github.com/Homebrew/brew.git'
}

// Ruby let `let(:non_git_url) { "https://brew.sh/test" }` at line 10.
pub fn ruby_git_spec_l10_d3_non_git_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:regexes) do` at line 11.
pub fn ruby_git_spec_l11_d4_regexes() map[string]git_core.GitRegex {
	return {
		'standard': git_core.GitRegex{ pattern: r'^v?(\d+(?:\.\d+)+)$', case_insensitive: true }
		'hyphens':  git_core.GitRegex{ pattern: r'^v?(\d+(?:[.-]\d+)+)$', case_insensitive: true }
		'brew':     git_core.GitRegex{ pattern: r'^brew/v?(\d+(?:\.\d+)+)$', case_insensitive: true }
	}
}

// Ruby let `let(:content) do` at line 18.
pub fn ruby_git_spec_l18_d5_content() map[string]string {
	normal := git_spec_normal_content()
	return {
		'normal':  normal
		'hyphens': normal.replace('.', '-')
	}
}

// Ruby let `let(:tags) do` at line 34.
pub fn ruby_git_spec_l34_d6_tags() map[string][]string {
	return {
		'normal':  ['brew/1.2', 'brew/1.2.1', 'brew/1.2.2', 'brew/1.2.3', 'brew/1.2.4', '1.2.5']
		'hyphens': ['brew/1-2', 'brew/1-2-1', 'brew/1-2-2', 'brew/1-2-3', 'brew/1-2-4', '1-2-5']
	}
}

// Ruby let `let(:matches) do` at line 40.
pub fn ruby_git_spec_l40_d7_matches() map[string][]string {
	return {
		'default':        ['1.2', '1.2.1', '1.2.2', '1.2.3', '1.2.4', '1.2.5']
		'standard_regex': ['1.2.5']
		'brew_regex':     ['1.2', '1.2.1', '1.2.2', '1.2.3', '1.2.4']
	}
}

// Ruby let `let(:messages) do` at line 47.
pub fn ruby_git_spec_l47_d8_messages() []string {
	return [
		'remote: Support for password authentication was removed on August 13, 2021.',
		"fatal: Authentication failed for '${ruby_git_spec_l9_d2_git_url()}'",
	]
}

// Ruby let `let(:github_git_url_with_extension) { "https://github.com/Homebrew/brew.git" }` at line 61.
pub fn ruby_git_spec_l61_d9_github_git_url_with_extension() string {
	return ruby_git_spec_l9_d2_git_url()
}

// Ruby it `it "returns a cached value if provided URL has already been processed" do` at line 63.
pub fn ruby_git_spec_l63_d10_returns() bool {
	mut state := git_core.GitState{}
	git_core.ruby_git_l37_d1_processed_urls(mut state, {
		ruby_git_spec_l10_d3_non_git_url(): 'CACHED'
	})
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, ruby_git_spec_l10_d3_non_git_url()) == 'CACHED'
}

// Ruby it `it "returns the unmodified URL for an unparsable URL" do` at line 71.
pub fn ruby_git_spec_l71_d11_returns() bool {
	mut state := git_core.GitState{}
	url := ':something:cvs:@cvs.brew.sh:/cvs'
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, url) == url
}

// Ruby it `it "returns the unmodified URL for a URL without a host" do` at line 76.
pub fn ruby_git_spec_l76_d12_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, '/test/') == '/test/'
}

// Ruby it `it "returns the unmodified URL for a URL without a path" do` at line 80.
pub fn ruby_git_spec_l80_d13_returns() bool {
	mut state := git_core.GitState{}
	url := 'https://example.com'
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, url) == url
}

// Ruby it `it "returns the unmodified URL for a URL without a host or path" do` at line 85.
pub fn ruby_git_spec_l85_d14_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, '') == ''
}

// Ruby it `it "returns the unmodified URL for a GitHub URL ending in .git" do` at line 89.
pub fn ruby_git_spec_l89_d15_returns() bool {
	mut state := git_core.GitState{}
	url := ruby_git_spec_l61_d9_github_git_url_with_extension()
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, url) == url
}

// Ruby it `it "returns the Git repository URL for a GitHub URL not ending in .git" do` at line 94.
pub fn ruby_git_spec_l94_d16_returns() bool {
	mut state := git_core.GitState{}
	url := 'https://github.com/Homebrew/brew'
	expected := ruby_git_spec_l61_d9_github_git_url_with_extension()
	first := git_core.ruby_git_l66_d2_self_preprocess_url(mut state, url)
	second := git_core.ruby_git_l66_d2_self_preprocess_url(mut state, url)
	return first == expected && second == expected && state.processed_urls[url] == expected
}

// Ruby it `it "returns the unmodified URL for a GitHub /releases/latest URL" do` at line 104.
pub fn ruby_git_spec_l104_d17_returns() bool {
	mut state := git_core.GitState{}
	url := 'https://github.com/Homebrew/brew/releases/latest'
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, url) == url
}

// Ruby it `it "returns the Git repository URL for a GitHub AWS URL" do` at line 109.
pub fn ruby_git_spec_l109_d18_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://github.s3.amazonaws.com/downloads/Homebrew/brew/1.0.0.tar.gz') == ruby_git_spec_l61_d9_github_git_url_with_extension()
}

// Ruby it `it "returns the Git repository URL for a github.com/downloads/... URL" do` at line 114.
pub fn ruby_git_spec_l114_d19_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://github.com/downloads/Homebrew/brew/1.0.0.tar.gz') == ruby_git_spec_l61_d9_github_git_url_with_extension()
}

// Ruby it `it "returns the Git repository URL for a GitHub tag archive URL" do` at line 119.
pub fn ruby_git_spec_l119_d20_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://github.com/Homebrew/brew/archive/1.0.0.tar.gz') == ruby_git_spec_l61_d9_github_git_url_with_extension()
}

// Ruby it `it "returns the Git repository URL for a GitHub release archive URL" do` at line 124.
pub fn ruby_git_spec_l124_d21_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://github.com/Homebrew/brew/releases/download/1.0.0/brew-1.0.0.tar.gz') == ruby_git_spec_l61_d9_github_git_url_with_extension()
}

// Ruby it `it "returns the Git repository URL for a gitlab.com archive URL" do` at line 129.
pub fn ruby_git_spec_l129_d22_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://gitlab.com/Homebrew/brew/-/archive/1.0.0/brew-1.0.0.tar.gz') == 'https://gitlab.com/Homebrew/brew.git'
}

// Ruby it `it "returns the Git repository URL for a self-hosted GitLab archive URL" do` at line 134.
pub fn ruby_git_spec_l134_d23_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://brew.sh/Homebrew/brew/-/archive/1.0.0/brew-1.0.0.tar.gz') == 'https://brew.sh/Homebrew/brew.git'
}

// Ruby it `it "returns the Git repository URL for a Codeberg archive URL" do` at line 139.
pub fn ruby_git_spec_l139_d24_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://codeberg.org/Homebrew/brew/archive/brew-1.0.0.tar.gz') == 'https://codeberg.org/Homebrew/brew.git'
}

// Ruby it `it "returns the Git repository URL for a Gitea archive URL" do` at line 144.
pub fn ruby_git_spec_l144_d25_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://gitea.com/Homebrew/brew/archive/brew-1.0.0.tar.gz') == 'https://gitea.com/Homebrew/brew.git'
}

// Ruby it `it "returns the unmodified URL for a Gitea /releases/latest URL" do` at line 149.
pub fn ruby_git_spec_l149_d26_returns() bool {
	mut state := git_core.GitState{}
	url := 'https://gitea.com/Homebrew/brew/releases/latest'
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, url) == url
}

// Ruby it `it "returns the Git repository URL for an Opendev archive URL" do` at line 154.
pub fn ruby_git_spec_l154_d27_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://opendev.org/Homebrew/brew/archive/brew-1.0.0.tar.gz') == 'https://opendev.org/Homebrew/brew.git'
}

// Ruby it `it "returns the Git repository URL for a tildegit archive URL" do` at line 159.
pub fn ruby_git_spec_l159_d28_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://tildegit.org/Homebrew/brew/archive/brew-1.0.0.tar.gz') == 'https://tildegit.org/Homebrew/brew.git'
}

// Ruby it `it "returns the Git repository URL for a LOL Git archive URL" do` at line 164.
pub fn ruby_git_spec_l164_d29_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://lolg.it/Homebrew/brew/archive/brew-1.0.0.tar.gz') == 'https://lolg.it/Homebrew/brew.git'
}

// Ruby it `it "returns the Git repository URL for a sourcehut archive URL" do` at line 169.
pub fn ruby_git_spec_l169_d30_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l66_d2_self_preprocess_url(mut state, 'https://git.sr.ht/~Homebrew/brew/archive/1.0.0.tar.gz') == 'https://git.sr.ht/~Homebrew/brew'
}

// Ruby it `it "returns true for a Git repository URL" do` at line 176.
pub fn ruby_git_spec_l176_d31_returns() bool {
	mut state := git_core.GitState{}
	return git_core.ruby_git_l118_d3_self_match(mut state, ruby_git_spec_l9_d2_git_url())
}

// Ruby it `it "returns false for a non-Git URL" do` at line 180.
pub fn ruby_git_spec_l180_d32_returns() bool {
	mut state := git_core.GitState{}
	return !git_core.ruby_git_l118_d3_self_match(mut state, ruby_git_spec_l10_d3_non_git_url())
}

// Ruby it `it "terminates options before the URL" do` at line 186.
pub fn ruby_git_spec_l186_d33_terminates() bool {
	result := git_core.ruby_git_l129_d4_self_ls_remote_tags('-u:evil', git_spec_no_output_runner) or {
		return false
	}
	return result.command.program == 'git' && result.command.arguments == ['ls-remote', '--tags',
		'--end-of-options', '-u:evil'] && result.command.environment == {
		'GIT_TERMINAL_PROMPT': '0'
	} && !result.command.print_stdout && !result.command.print_stderr && !result.command.debug && !result.command.verbose
}

// Ruby it `it "returns the Git tags for the provided remote URL", :needs_network do` at line 202.
pub fn ruby_git_spec_l202_d34_returns() bool {
	result := git_core.ruby_git_l129_d4_self_ls_remote_tags(ruby_git_spec_l9_d2_git_url(), git_spec_stdout_runner) or { return false }
	return result.has_content || result.has_messages
}

// Ruby it `it "returns a hash containing fetched content from `stdout`" do` at line 206.
pub fn ruby_git_spec_l206_d35_returns() bool {
	result := git_core.ruby_git_l129_d4_self_ls_remote_tags(ruby_git_spec_l9_d2_git_url(), git_spec_stdout_runner) or { return false }
	return result.has_content && result.content == ruby_git_spec_l18_d5_content()['normal'] && !result.has_messages
}

// Ruby it `it "returns a hash containing error messages from `stderr`" do` at line 212.
pub fn ruby_git_spec_l212_d36_returns() bool {
	result := git_core.ruby_git_l129_d4_self_ls_remote_tags(ruby_git_spec_l9_d2_git_url(), git_spec_stderr_runner) or { return false }
	return !result.has_content && result.has_messages && result.messages == ruby_git_spec_l47_d8_messages()
}

// Ruby it `it "returns a hash containing fetched content and error messages when both `stdout` and `stderr` are present" do` at line 218.
pub fn ruby_git_spec_l218_d37_returns() bool {
	result := git_core.ruby_git_l129_d4_self_ls_remote_tags(ruby_git_spec_l9_d2_git_url(), git_spec_both_runner) or { return false }
	return result.has_content && result.content == ruby_git_spec_l18_d5_content()['normal'] && result.has_messages && result.messages == ruby_git_spec_l47_d8_messages()
}

// Ruby it `it "returns a blank hash if neither `stdout` nor `stderr` are present" do` at line 224.
pub fn ruby_git_spec_l224_d38_returns() bool {
	result := git_core.ruby_git_l129_d4_self_ls_remote_tags(ruby_git_spec_l9_d2_git_url(), git_spec_no_output_runner) or { return false }
	return !result.has_content && !result.has_messages
}

// Ruby it `it "returns an empty array if content string doesn't contain parseable text" do` at line 231.
pub fn ruby_git_spec_l231_d39_returns() bool {
	return git_core.ruby_git_l152_d5_self_tags_from_content('').len == 0
}

// Ruby it `it "returns an array of tag strings when given content" do` at line 235.
pub fn ruby_git_spec_l235_d40_returns() bool {
	return git_core.ruby_git_l152_d5_self_tags_from_content(ruby_git_spec_l18_d5_content()['normal']) == ruby_git_spec_l34_d6_tags()['normal']
}

// Ruby it `it "returns an empty array if content contains no tags" do` at line 241.
pub fn ruby_git_spec_l241_d41_returns() bool {
	result := git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{}) or {
		return false
	}
	return result.len == 0
}

// Ruby it `it "returns an array of version strings when given content" do` at line 245.
pub fn ruby_git_spec_l245_d42_returns() bool {
	content := ruby_git_spec_l18_d5_content()['normal']
	default_result := git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{
		content: content
	}) or { return false }
	standard_result := git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{
		content: content
		regex: git_spec_regex('standard')
	}) or { return false }
	brew_result := git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{
		content: content
		regex: git_spec_regex('brew')
	}) or { return false }
	matches := ruby_git_spec_l40_d7_matches()
	return default_result == matches['default'] && standard_result == matches['standard_regex'] && brew_result == matches['brew_regex']
}

// Ruby it `it "returns an array of version strings when given content and a block" do` at line 251.
pub fn ruby_git_spec_l251_d43_returns() bool {
	content := ruby_git_spec_l18_d5_content()
	matches := ruby_git_spec_l40_d7_matches()
	first := git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{
		content: content['normal']
		has_block: true
		block_arity: 0
		block: git_spec_first_block
	}) or { return false }
	default_regex := git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{
		content: content['hyphens']
		has_block: true
		block_arity: 2
		block: git_spec_normalize_block
	}) or { return false }
	explicit_regex := git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{
		content: content['hyphens']
		regex: git_spec_regex('hyphens')
		has_block: true
		block_arity: 2
		block: git_spec_normalize_block
	}) or { return false }
	literal := git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{
		content: content['hyphens']
		has_block: true
		block_arity: 0
		block: git_spec_literal_block
	}) or { return false }
	default_matches := matches['default']
	standard_matches := matches['standard_regex']
	return first.len == 1 && first[0] == default_matches[0] && default_regex == default_matches && explicit_regex == standard_matches && literal == [
		'1.2.3',
	]
}

// Ruby it `it "allows a nil return from a block" do` at line 272.
pub fn ruby_git_spec_l272_d44_allows() bool {
	result := git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{
		content: ruby_git_spec_l18_d5_content()['normal']
		has_block: true
		block: git_spec_nil_block
	}) or { return false }
	return result.len == 0
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 276.
pub fn ruby_git_spec_l276_d45_errors() bool {
	git_core.ruby_git_l170_d6_self_versions_from_content(git_core.GitVersionsRequest{
		content: ruby_git_spec_l18_d5_content()['normal']
		has_block: true
		block: git_spec_invalid_block
	}) or {
		return err.msg() == 'Return value of a strategy block must be a string or array of strings.'
	}
	return false
}

// Ruby let `let(:match_data) do` at line 283.
pub fn ruby_git_spec_l283_d46_match_data() GitSpecMatchData {
	url := ruby_git_spec_l9_d2_git_url()
	content := ruby_git_spec_l18_d5_content()['normal']
	base := git_core.GitMatchData{
		matches: git_spec_matches(ruby_git_spec_l40_d7_matches()['brew_regex'])
		regex: git_spec_regex('brew')
		url: url
	}
	default_result := git_core.GitMatchData{
		...base
		matches: map[string]string{}
	}
	return GitSpecMatchData{
		fetched: git_core.GitMatchData{
			...base
			content: content
			has_content: true
		}
		fetched_default_regex: git_core.GitMatchData{
			matches: git_spec_matches(ruby_git_spec_l40_d7_matches()['default'])
			url: url
			content: content
			has_content: true
		}
		default_result: default_result
		cached: git_core.GitMatchData{
			...base
			cached: true
			has_cached: true
		}
		cached_default: git_core.GitMatchData{
			...default_result
			cached: true
			has_cached: true
		}
	}
}

// Ruby it `it "finds versions in fetched content" do` at line 305.
pub fn ruby_git_spec_l305_d47_finds() bool {
	fixture := ruby_git_spec_l283_d46_match_data()
	with_regex := git_core.ruby_git_l207_d7_self_find_versions(git_core.GitFindVersionsRequest{
		url: ruby_git_spec_l9_d2_git_url()
		regex: git_spec_regex('brew')
	}, git_spec_content_fetcher) or { return false }
	with_default := git_core.ruby_git_l207_d7_self_find_versions(git_core.GitFindVersionsRequest{
		url: ruby_git_spec_l9_d2_git_url()
	}, git_spec_content_fetcher) or { return false }
	return git_core.git_match_data_equal(with_regex, fixture.fetched) && git_core.git_match_data_equal(with_default, fixture.fetched_default_regex)
}

// Ruby it `it "returns match_data with error messages from ls_remote_tags" do` at line 313.
pub fn ruby_git_spec_l313_d48_returns() bool {
	expected := git_core.GitMatchData{
		...ruby_git_spec_l283_d46_match_data().default_result
		messages: ruby_git_spec_l47_d8_messages()
		has_messages: true
	}
	actual := git_core.ruby_git_l207_d7_self_find_versions(git_core.GitFindVersionsRequest{
		url: ruby_git_spec_l9_d2_git_url()
		regex: git_spec_regex('brew')
	}, git_spec_error_fetcher) or { return false }
	return git_core.git_match_data_equal(actual, expected)
}

// Ruby it `it "finds versions in provided content" do` at line 321.
pub fn ruby_git_spec_l321_d49_finds() bool {
	fixture := ruby_git_spec_l283_d46_match_data().cached
	content := ruby_git_spec_l18_d5_content()['normal']
	direct := git_core.ruby_git_l207_d7_self_find_versions(git_core.GitFindVersionsRequest{
		url: ruby_git_spec_l9_d2_git_url()
		regex: git_spec_regex('brew')
		content: content
	}, git_spec_unused_fetcher) or { return false }
	block_result := git_core.ruby_git_l207_d7_self_find_versions(git_core.GitFindVersionsRequest{
		url: ruby_git_spec_l9_d2_git_url()
		content: content
		has_block: true
		block_arity: 1
		block: git_spec_brew_block
	}, git_spec_unused_fetcher) or { return false }
	expected_block := git_core.GitMatchData{
		...fixture
		regex: none
	}
	return git_core.git_match_data_equal(direct, fixture) && git_core.git_match_data_equal(block_result, expected_block)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 333.
pub fn ruby_git_spec_l333_d50_returns() bool {
	expected := git_core.GitMatchData{
		...ruby_git_spec_l283_d46_match_data().cached_default
		url: ''
	}
	actual := git_core.ruby_git_l207_d7_self_find_versions(git_core.GitFindVersionsRequest{
		url: ''
		regex: git_spec_regex('brew')
		content: ruby_git_spec_l18_d5_content()['normal']
	}, git_spec_unused_fetcher) or { return false }
	return git_core.git_match_data_equal(actual, expected)
}

// Ruby it `it "returns default match_data when content doesn't contain tags" do` at line 338.
pub fn ruby_git_spec_l338_d51_returns() bool {
	actual := git_core.ruby_git_l207_d7_self_find_versions(git_core.GitFindVersionsRequest{
		url: ruby_git_spec_l9_d2_git_url()
		regex: git_spec_regex('brew')
		content: 'abc'
	}, git_spec_unused_fetcher) or { return false }
	return git_core.git_match_data_equal(actual, ruby_git_spec_l283_d46_match_data().cached_default)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 343.
pub fn ruby_git_spec_l343_d52_returns() bool {
	actual := git_core.ruby_git_l207_d7_self_find_versions(git_core.GitFindVersionsRequest{
		url: ruby_git_spec_l9_d2_git_url()
		regex: git_spec_regex('brew')
		content: ''
	}, git_spec_unused_fetcher) or { return false }
	return git_core.git_match_data_equal(actual, ruby_git_spec_l283_d46_match_data().cached_default)
}

// Ruby it `it "omits non-string tag values" do` at line 348.
pub fn ruby_git_spec_l348_d53_omits() bool {
	mut candidates := [git_core.GitVersionCandidate{}]
	for value in ruby_git_spec_l40_d7_matches()['brew_regex'] {
		candidates << git_core.GitVersionCandidate{ is_string: true, value: value }
	}
	candidates << git_core.GitVersionCandidate{}
	actual := git_core.ruby_git_l207_d7_self_find_versions(git_core.GitFindVersionsRequest{
		url: ruby_git_spec_l9_d2_git_url()
		regex: git_spec_regex('brew')
		content: ruby_git_spec_l18_d5_content()['normal']
		candidate_override: git_core.GitVersionCandidates{
			present: true
			values: candidates
		}
	}, git_spec_unused_fetcher) or { return false }
	return git_core.git_match_data_equal(actual, ruby_git_spec_l283_d46_match_data().cached)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Git do
// 7:   subject(:git) { described_class }
// 8:
// 9:   let(:git_url) { "https://github.com/Homebrew/brew.git" }
// 10:   let(:non_git_url) { "https://brew.sh/test" }
// 11:   let(:regexes) do
// 12:     {
// 13:       standard: /^v?(\d+(?:\.\d+)+)$/i,
// 14:       hyphens:  /^v?(\d+(?:[.-]\d+)+)$/i,
// 15:       brew:     %r{^brew/v?(\d+(?:\.\d+)+)$}i,
// 16:     }
// 17:   end
// 18:   let(:content) do
// 19:     normal = <<~EOS
// 20:       e0f1758045b8194f77a43050ca433cbe928f27fb\trefs/tags/brew/1.2
// 21:       5a45d5c9e39da019b2feaf63a1321e2f0336769c\trefs/tags/brew/1.2.1
// 22:       81426bcda28e391b29770747ecd86bf8324d2441\trefs/tags/brew/1.2.2
// 23:       50631d8ae8885d6b3a51814f4529c0b2e5d424fa\trefs/tags/brew/1.2.3
// 24:       cd58e678c52ef269d2ba5153a9dd0f83864ab7b4\trefs/tags/brew/1.2.4^{}
// 25:       db2b77f42b1c1fa7bb74f13ce798290084aa89f3\trefs/tags/1.2.5
// 26:     EOS
// 27:     hyphens = normal.tr(".", "-")
// 28:
// 29:     {
// 30:       normal:,
// 31:       hyphens:,
// 32:     }
// 33:   end
// 34:   let(:tags) do
// 35:     {
// 36:       normal:  ["brew/1.2", "brew/1.2.1", "brew/1.2.2", "brew/1.2.3", "brew/1.2.4", "1.2.5"],
// 37:       hyphens: ["brew/1-2", "brew/1-2-1", "brew/1-2-2", "brew/1-2-3", "brew/1-2-4", "1-2-5"],
// 38:     }
// 39:   end
// 40:   let(:matches) do
// 41:     {
// 42:       default:        ["1.2", "1.2.1", "1.2.2", "1.2.3", "1.2.4", "1.2.5"],
// 43:       standard_regex: ["1.2.5"],
// 44:       brew_regex:     ["1.2", "1.2.1", "1.2.2", "1.2.3", "1.2.4"],
// 45:     }
// 46:   end
// 47:   let(:messages) do
// 48:     [
// 49:       "remote: Support for password authentication was removed on August 13, 2021.",
// 50:       "fatal: Authentication failed for '#{git_url}'",
// 51:     ]
// 52:   end
// 53:
// 54:   describe "::preprocess_url" do
// 55:     before do
// 56:       # Clear the processed URL cache before each test, to ensure that we're
// 57:       # properly testing the method's processing logic.
// 58:       git.processed_urls = {}
// 59:     end
// 60:
// 61:     let(:github_git_url_with_extension) { "https://github.com/Homebrew/brew.git" }
// 62:
// 63:     it "returns a cached value if provided URL has already been processed" do
// 64:       # This uses an unrealistic value to make sure that we are receiving a
// 65:       # cached value from `@processed_urls` and not a newly-processed URL.
// 66:       cached_value = "CACHED"
// 67:       git.processed_urls = { non_git_url => cached_value }
// 68:       expect(git.preprocess_url(non_git_url)).to eq(cached_value)
// 69:     end
// 70:
// 71:     it "returns the unmodified URL for an unparsable URL" do
// 72:       expect(git.preprocess_url(":something:cvs:@cvs.brew.sh:/cvs"))
// 73:         .to eq(":something:cvs:@cvs.brew.sh:/cvs")
// 74:     end
// 75:
// 76:     it "returns the unmodified URL for a URL without a host" do
// 77:       expect(git.preprocess_url("/test/")).to eq("/test/")
// 78:     end
// 79:
// 80:     it "returns the unmodified URL for a URL without a path" do
// 81:       expect(git.preprocess_url("https://example.com"))
// 82:         .to eq("https://example.com")
// 83:     end
// 84:
// 85:     it "returns the unmodified URL for a URL without a host or path" do
// 86:       expect(git.preprocess_url("")).to eq("")
// 87:     end
// 88:
// 89:     it "returns the unmodified URL for a GitHub URL ending in .git" do
// 90:       expect(git.preprocess_url(github_git_url_with_extension))
// 91:         .to eq(github_git_url_with_extension)
// 92:     end
// 93:
// 94:     it "returns the Git repository URL for a GitHub URL not ending in .git" do
// 95:       # We run a test twice to exercise the `processed_url` early return.
// 96:       # It doesn't matter which test we do this with, as long as the URL is
// 97:       # modified and stored in `@processed_urls`.
// 98:       2.times do
// 99:         expect(git.preprocess_url("https://github.com/Homebrew/brew"))
// 100:           .to eq(github_git_url_with_extension)
// 101:       end
// 102:     end
// 103:
// 104:     it "returns the unmodified URL for a GitHub /releases/latest URL" do
// 105:       expect(git.preprocess_url("https://github.com/Homebrew/brew/releases/latest"))
// 106:         .to eq("https://github.com/Homebrew/brew/releases/latest")
// 107:     end
// 108:
// 109:     it "returns the Git repository URL for a GitHub AWS URL" do
// 110:       expect(git.preprocess_url("https://github.s3.amazonaws.com/downloads/Homebrew/brew/1.0.0.tar.gz"))
// 111:         .to eq(github_git_url_with_extension)
// 112:     end
// 113:
// 114:     it "returns the Git repository URL for a github.com/downloads/... URL" do
// 115:       expect(git.preprocess_url("https://github.com/downloads/Homebrew/brew/1.0.0.tar.gz"))
// 116:         .to eq(github_git_url_with_extension)
// 117:     end
// 118:
// 119:     it "returns the Git repository URL for a GitHub tag archive URL" do
// 120:       expect(git.preprocess_url("https://github.com/Homebrew/brew/archive/1.0.0.tar.gz"))
// 121:         .to eq(github_git_url_with_extension)
// 122:     end
// 123:
// 124:     it "returns the Git repository URL for a GitHub release archive URL" do
// 125:       expect(git.preprocess_url("https://github.com/Homebrew/brew/releases/download/1.0.0/brew-1.0.0.tar.gz"))
// 126:         .to eq(github_git_url_with_extension)
// 127:     end
// 128:
// 129:     it "returns the Git repository URL for a gitlab.com archive URL" do
// 130:       expect(git.preprocess_url("https://gitlab.com/Homebrew/brew/-/archive/1.0.0/brew-1.0.0.tar.gz"))
// 131:         .to eq("https://gitlab.com/Homebrew/brew.git")
// 132:     end
// 133:
// 134:     it "returns the Git repository URL for a self-hosted GitLab archive URL" do
// 135:       expect(git.preprocess_url("https://brew.sh/Homebrew/brew/-/archive/1.0.0/brew-1.0.0.tar.gz"))
// 136:         .to eq("https://brew.sh/Homebrew/brew.git")
// 137:     end
// 138:
// 139:     it "returns the Git repository URL for a Codeberg archive URL" do
// 140:       expect(git.preprocess_url("https://codeberg.org/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
// 141:         .to eq("https://codeberg.org/Homebrew/brew.git")
// 142:     end
// 143:
// 144:     it "returns the Git repository URL for a Gitea archive URL" do
// 145:       expect(git.preprocess_url("https://gitea.com/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
// 146:         .to eq("https://gitea.com/Homebrew/brew.git")
// 147:     end
// 148:
// 149:     it "returns the unmodified URL for a Gitea /releases/latest URL" do
// 150:       expect(git.preprocess_url("https://gitea.com/Homebrew/brew/releases/latest"))
// 151:         .to eq("https://gitea.com/Homebrew/brew/releases/latest")
// 152:     end
// 153:
// 154:     it "returns the Git repository URL for an Opendev archive URL" do
// 155:       expect(git.preprocess_url("https://opendev.org/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
// 156:         .to eq("https://opendev.org/Homebrew/brew.git")
// 157:     end
// 158:
// 159:     it "returns the Git repository URL for a tildegit archive URL" do
// 160:       expect(git.preprocess_url("https://tildegit.org/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
// 161:         .to eq("https://tildegit.org/Homebrew/brew.git")
// 162:     end
// 163:
// 164:     it "returns the Git repository URL for a LOL Git archive URL" do
// 165:       expect(git.preprocess_url("https://lolg.it/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
// 166:         .to eq("https://lolg.it/Homebrew/brew.git")
// 167:     end
// 168:
// 169:     it "returns the Git repository URL for a sourcehut archive URL" do
// 170:       expect(git.preprocess_url("https://git.sr.ht/~Homebrew/brew/archive/1.0.0.tar.gz"))
// 171:         .to eq("https://git.sr.ht/~Homebrew/brew")
// 172:     end
// 173:   end
// 174:
// 175:   describe "::match?" do
// 176:     it "returns true for a Git repository URL" do
// 177:       expect(git.match?(git_url)).to be true
// 178:     end
// 179:
// 180:     it "returns false for a non-Git URL" do
// 181:       expect(git.match?(non_git_url)).to be false
// 182:     end
// 183:   end
// 184:
// 185:   describe "::ls_remote_tags" do
// 186:     it "terminates options before the URL" do
// 187:       expect(git).to receive(:system_command)
// 188:         .with(
// 189:           "git",
// 190:           args:         ["ls-remote", "--tags", "--end-of-options", "-u:evil"],
// 191:           env:          { "GIT_TERMINAL_PROMPT" => "0" },
// 192:           print_stdout: false,
// 193:           print_stderr: false,
// 194:           debug:        false,
// 195:           verbose:      false,
// 196:         )
// 197:         .and_return([nil, nil, nil])
// 198:
// 199:       git.ls_remote_tags("-u:evil")
// 200:     end
// 201:
// 202:     it "returns the Git tags for the provided remote URL", :needs_network do
// 203:       expect(git.ls_remote_tags(git_url)).not_to be_empty
// 204:     end
// 205:
// 206:     it "returns a hash containing fetched content from `stdout`" do
// 207:       allow(git).to receive(:system_command)
// 208:         .and_return([content[:normal], nil, nil])
// 209:       expect(git.ls_remote_tags(git_url)).to eq({ content: content[:normal] })
// 210:     end
// 211:
// 212:     it "returns a hash containing error messages from `stderr`" do
// 213:       allow(git).to receive(:system_command)
// 214:         .and_return([nil, messages.join("\n"), nil])
// 215:       expect(git.ls_remote_tags(git_url)).to eq({ messages: })
// 216:     end
// 217:
// 218:     it "returns a hash containing fetched content and error messages when both `stdout` and `stderr` are present" do
// 219:       allow(git).to receive(:system_command)
// 220:         .and_return([content[:normal], messages.join("\n"), nil])
// 221:       expect(git.ls_remote_tags(git_url)).to eq({ content: content[:normal], messages: })
// 222:     end
// 223:
// 224:     it "returns a blank hash if neither `stdout` nor `stderr` are present" do
// 225:       allow(git).to receive(:system_command).and_return([nil, nil, nil])
// 226:       expect(git.ls_remote_tags(git_url)).to eq({})
// 227:     end
// 228:   end
// 229:
// 230:   describe "::tags_from_content" do
// 231:     it "returns an empty array if content string doesn't contain parseable text" do
// 232:       expect(git.tags_from_content("")).to eq([])
// 233:     end
// 234:
// 235:     it "returns an array of tag strings when given content" do
// 236:       expect(git.tags_from_content(content[:normal])).to eq(tags[:normal])
// 237:     end
// 238:   end
// 239:
// 240:   describe "::versions_from_content" do
// 241:     it "returns an empty array if content contains no tags" do
// 242:       expect(git.versions_from_content("")).to eq([])
// 243:     end
// 244:
// 245:     it "returns an array of version strings when given content" do
// 246:       expect(git.versions_from_content(content[:normal])).to eq(matches[:default])
// 247:       expect(git.versions_from_content(content[:normal], regexes[:standard])).to eq(matches[:standard_regex])
// 248:       expect(git.versions_from_content(content[:normal], regexes[:brew])).to eq(matches[:brew_regex])
// 249:     end
// 250:
// 251:     it "returns an array of version strings when given content and a block" do
// 252:       # Returning a string from block, default strategy regex
// 253:       expect(git.versions_from_content(content[:normal]) { matches[:default].first }).to eq([matches[:default].first])
// 254:
// 255:       # Returning an array of strings from block, default strategy regex
// 256:       expect(
// 257:         git.versions_from_content(content[:hyphens]) do |tags, regex|
// 258:           tags.map { |tag| tag[regex, 1]&.tr("-", ".") }
// 259:         end,
// 260:       ).to eq(matches[:default])
// 261:
// 262:       # Returning an array of strings from block, explicit regex
// 263:       expect(
// 264:         git.versions_from_content(content[:hyphens], regexes[:hyphens]) do |tags, regex|
// 265:           tags.map { |tag| tag[regex, 1]&.tr("-", ".") }
// 266:         end,
// 267:       ).to eq(matches[:standard_regex])
// 268:
// 269:       expect(git.versions_from_content(content[:hyphens]) { "1.2.3" }).to eq(["1.2.3"])
// 270:     end
// 271:
// 272:     it "allows a nil return from a block" do
// 273:       expect(git.versions_from_content(content[:normal]) { next }).to eq([])
// 274:     end
// 275:
// 276:     it "errors on an invalid return type from a block" do
// 277:       expect { git.versions_from_content(content[:normal]) { 123 } }
// 278:         .to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 279:     end
// 280:   end
// 281:
// 282:   describe "::find_versions" do
// 283:     let(:match_data) do
// 284:       base = {
// 285:         matches: matches[:brew_regex].to_h { |v| [v, Version.new(v)] },
// 286:         regex:   regexes[:brew],
// 287:         url:     git_url,
// 288:       }
// 289:       default = base.merge(matches: {})
// 290:
// 291:       {
// 292:         fetched:               base.merge({ content: content[:normal] }),
// 293:         fetched_default_regex: {
// 294:           matches: matches[:default].to_h { |v| [v, Version.new(v)] },
// 295:           regex:   nil,
// 296:           url:     git_url,
// 297:           content: content[:normal],
// 298:         },
// 299:         default:,
// 300:         cached:                base.merge({ cached: true }),
// 301:         cached_default:        default.merge({ cached: true }),
// 302:       }
// 303:     end
// 304:
// 305:     it "finds versions in fetched content" do
// 306:       allow(git).to receive(:ls_remote_tags).and_return({ content: content[:normal] })
// 307:
// 308:       expect(git.find_versions(url: git_url, regex: regexes[:brew]))
// 309:         .to eq(match_data[:fetched])
// 310:       expect(git.find_versions(url: git_url)).to eq(match_data[:fetched_default_regex])
// 311:     end
// 312:
// 313:     it "returns match_data with error messages from ls_remote_tags" do
// 314:       error_hash = { messages: }
// 315:       allow(git).to receive(:ls_remote_tags).and_return(error_hash)
// 316:
// 317:       expect(git.find_versions(url: git_url, regex: regexes[:brew]))
// 318:         .to eq(match_data[:default].merge(error_hash))
// 319:     end
// 320:
// 321:     it "finds versions in provided content" do
// 322:       expect(git.find_versions(url: git_url, regex: regexes[:brew], content: content[:normal]))
// 323:         .to eq(match_data[:cached])
// 324:
// 325:       # A regex should be passed into a `strategy` block (instead of using a
// 326:       # regex literal within the `strategy` block) but we're using this
// 327:       # approach for the sake of testing.
// 328:       expect(git.find_versions(url: git_url, content: content[:normal]) do |tags|
// 329:         tags.map { |tag| tag[%r{^brew/v?(\d+(?:\.\d+)+)$}i, 1] }
// 330:       end).to eq(match_data[:cached].merge({ regex: nil }))
// 331:     end
// 332:
// 333:     it "returns default match_data when url is blank" do
// 334:       expect(git.find_versions(url: "", regex: regexes[:brew], content: content[:normal]))
// 335:         .to eq(match_data[:cached_default].merge({ url: "" }))
// 336:     end
// 337:
// 338:     it "returns default match_data when content doesn't contain tags" do
// 339:       expect(git.find_versions(url: git_url, regex: regexes[:brew], content: "abc"))
// 340:         .to eq(match_data[:cached_default])
// 341:     end
// 342:
// 343:     it "returns default match_data when content is blank" do
// 344:       expect(git.find_versions(url: git_url, regex: regexes[:brew], content: ""))
// 345:         .to eq(match_data[:cached_default])
// 346:     end
// 347:
// 348:     it "omits non-string tag values" do
// 349:       # This overrides the `versions_from_content` return value to also include
// 350:       # non-string values. This shouldn't happen under normal circumstances
// 351:       # but this allows us to test this safeguard.
// 352:       allow(git).to receive(:versions_from_content).and_return([1, *matches[:brew_regex], nil])
// 353:
// 354:       expect(git.find_versions(url: git_url, regex: regexes[:brew], content: content[:normal]))
// 355:         .to eq(match_data[:cached])
// 356:     end
// 357:   end
// 358: end
