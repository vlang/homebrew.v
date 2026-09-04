module strategy

import ruby
import homebrew.download_strategy
import net.urllib
import regex

// Translated from Homebrew/brew `livecheck/strategy/git.rb`.
pub const git_priority = 8
pub const git_default_regex = r'\D*(.+)'

pub struct GitState {
pub mut:
	processed_urls map[string]string
}

pub struct GitRegex {
pub:
	pattern          string
	case_insensitive bool
}

pub struct GitCommand {
pub:
	program      string
	arguments    []string
	environment  map[string]string
	print_stdout bool
	print_stderr bool
	debug        bool
	verbose      bool
}

pub struct GitCommandOutput {
pub:
	stdout     string
	has_stdout bool
	stderr     string
	has_stderr bool
}

pub type GitCommandRunner = fn (GitCommand) !GitCommandOutput

pub struct GitRemoteData {
pub:
	content      string
	has_content  bool
	messages     []string
	has_messages bool
	command      GitCommand
}

pub enum GitBlockItemKind {
	string_value
	version_value
	other_value
	nil_value
}

pub struct GitBlockItem {
pub:
	kind  GitBlockItemKind
	value string
}

pub enum GitBlockReturnKind {
	string_value
	version_value
	array
	nil_value
	invalid
}

pub struct GitBlockReturn {
pub:
	kind   GitBlockReturnKind
	value  string
	values []GitBlockItem
}

pub type GitVersionsBlock = fn ([]string, ?GitRegex) !GitBlockReturn

pub struct GitVersionsRequest {
pub:
	content     string
	regex       ?GitRegex
	has_block   bool
	block_arity int
	block       GitVersionsBlock = unsafe { nil }
}

pub struct GitVersionCandidate {
pub:
	is_string bool
	value     string
}

pub struct GitVersionCandidates {
pub:
	present bool
	values  []GitVersionCandidate
}

pub struct GitFindVersionsRequest {
pub:
	url                string
	regex              ?GitRegex
	content            ?string
	has_block          bool
	block_arity        int
	block              GitVersionsBlock = unsafe { nil }
	candidate_override GitVersionCandidates
}

pub struct GitMatchData {
pub:
	matches      map[string]string
	regex        ?GitRegex
	url          string
	cached       bool
	has_cached   bool
	content      string
	has_content  bool
	messages     []string
	has_messages bool
}

pub type GitRemoteFetcher = fn (string) !GitRemoteData

pub fn git_set_processed_urls(mut state GitState, processed_urls map[string]string) {
	state.processed_urls = processed_urls.clone()
}

fn git_url_owner_repo(path string, trim_downloads bool) (string, string) {
	mut normalized := path.trim_string_left('/')
	if trim_downloads {
		normalized = normalized.trim_string_left('downloads/')
	}
	parts := normalized.split('/')
	owner := if parts.len > 0 { parts[0] } else { '' }
	repository := if parts.len > 1 { parts[1] } else { '' }
	return owner, repository
}

pub fn git_preprocess_url(mut state GitState, url string) string {
	if processed := state.processed_urls[url] {
		return processed
	}
	uri := urllib.parse(url) or { return url }
	mut host := uri.host
	mut path := uri.path
	if host == '' || path.trim_space() == '' {
		return url
	}
	if host == 'github.s3.amazonaws.com' {
		host = 'github.com'
	}
	path = path.trim_string_left('/').trim_string_right('.git')
	mut processed_url := ''
	if host == 'github.com' {
		if path.trim_string_right('/').ends_with('/releases/latest') {
			return url
		}
		owner, repository := git_url_owner_repo(path, true)
		processed_url = '${uri.scheme}://${host}/${owner}/${repository}.git'
	} else if host in ['codeberg.org', 'gitea.com', 'opendev.org', 'tildegit.org'] {
		if path.trim_string_right('/').ends_with('/releases/latest') {
			return url
		}
		owner, repository := git_url_owner_repo(path, false)
		processed_url = '${uri.scheme}://${host}/${owner}/${repository}.git'
	} else if host == 'lolg.it' {
		owner, repository := git_url_owner_repo(path, false)
		processed_url = '${uri.scheme}://${host}/${owner}/${repository}.git'
	} else if host == 'git.sr.ht' {
		owner, repository := git_url_owner_repo(path, false)
		processed_url = '${uri.scheme}://${host}/${owner}/${repository}'
	} else if path.contains('/-/archive/') {
		archive_index := url.to_lower().index('/-/archive/') or { return url }
		processed_url = '${url[..archive_index]}.git'
	}
	if processed_url != '' && processed_url != url {
		state.processed_urls[url] = processed_url
		return processed_url
	}
	return url
}

pub fn git_matches(mut state GitState, url string) bool {
	processed := git_preprocess_url(mut state, url)
	detected := download_strategy.detect_from_url(processed)
	return detected in [.git, .github_git]
}

pub fn git_ls_remote_command(url string) GitCommand {
	return GitCommand{
		program: 'git'
		arguments: ['ls-remote', '--tags', '--end-of-options', url]
		environment: {
			'GIT_TERMINAL_PROMPT': '0'
		}
	}
}

pub fn git_ls_remote_tags(url string, runner GitCommandRunner) !GitRemoteData {
	command := git_ls_remote_command(url)
	output := runner(command)!
	stdout_present := output.has_stdout && output.stdout.trim_space() != ''
	stderr_present := output.has_stderr && output.stderr.trim_space() != ''
	mut message_content := output.stderr
	for message_content.ends_with('\n') {
		message_content = message_content[..message_content.len - 1]
	}
	return GitRemoteData{
		content: output.stdout
		has_content: stdout_present
		messages: if stderr_present {
			message_content.split('\n')
		} else {
			[]string{}
		}
		has_messages: stderr_present
		command: command
	}
}

pub fn git_native_command_runner(command GitCommand) !GitCommandOutput {
	mut environment := ruby.environment()
	for key, value in command.environment {
		environment[key] = value
	}
	mut command_line := [command.program]
	command_line << command.arguments
	result := ruby.run_captured_command(command_line, ruby.CapturedCommandOptions{ environment: environment })!
	return GitCommandOutput{
		stdout: result.stdout
		has_stdout: result.stdout != ''
		stderr: result.stderr
		has_stderr: result.stderr != ''
	}
}

pub fn git_ls_remote_tags_native(url string) !GitRemoteData {
	return git_ls_remote_tags(url, git_native_command_runner)
}

fn git_is_hex(text string) bool {
	if text == '' {
		return false
	}
	for character in text {
		if !character.is_hex_digit() {
			return false
		}
	}
	return true
}

pub fn git_tags_from_content(content string) []string {
	mut tags := []string{}
	for line in content.split_into_lines() {
		whitespace := line.index_any(' \t\r\n')
		if whitespace < 1 || !git_is_hex(line[..whitespace]) {
			continue
		}
		mut remainder := line[whitespace..].trim_left(' \t\r\n')
		if !remainder.starts_with('refs/tags/') {
			continue
		}
		remainder = remainder['refs/tags/'.len..]
		if remainder.ends_with('^{}') {
			remainder = remainder[..remainder.len - 3]
		}
		if remainder != '' && remainder !in tags {
			tags << remainder
		}
	}
	return tags
}

struct GitCapture {
	matched bool
	value   string
}

fn git_capture(text string, match_regex GitRegex) !GitCapture {
	// V's regex parser requires a literal trailing hyphen to appear first in a
	// character class; these rewrites preserve the Ruby patterns' meaning.
	pattern := match_regex.pattern.replace('[.-]', '[-.]').replace('[._-]', '[-._]').replace('[_-]', '[-_]')
	mut expression := regex.regex_opt(pattern)!
	if match_regex.case_insensitive {
		expression.flag |= regex.f_ci
	}
	start, _ := expression.find(text)
	if start < 0 {
		return GitCapture{}
	}
	return GitCapture{
		matched: true
		value: expression.get_group_by_id(text, 0)
	}
}

pub fn git_versions_from_tags(tags []string, match_regex GitRegex) ![]string {
	mut versions := []string{}
	for tag in tags {
		capture := git_capture(tag, match_regex)!
		if capture.matched && capture.value !in versions {
			versions << capture.value
		}
	}
	return versions
}

pub fn git_handle_block_return(value GitBlockReturn) ![]string {
	match value.kind {
		.string_value, .version_value {
			return [value.value]
		}
		.array {
			mut values := []string{}
			for item in value.values {
				if item.kind == .nil_value {
					continue
				}
				if item.value !in values {
					values << item.value
				}
			}
			return values
		}
		.nil_value {
			return []string{}
		}
		.invalid {
			return error('Return value of a strategy block must be a string or array of strings.')
		}
	}
}

pub fn git_versions_from_content(request GitVersionsRequest) ![]string {
	tags := git_tags_from_content(request.content)
	if tags.len == 0 {
		return []string{}
	}
	if request.has_block {
		block_regex := if supplied := request.regex {
			?GitRegex(supplied)
		} else if request.block_arity == 2 {
			?GitRegex(GitRegex{ pattern: git_default_regex })
		} else {
			?GitRegex(none)
		}
		return git_handle_block_return(request.block(tags, block_regex)!)
	}
	match_regex := request.regex or { GitRegex{ pattern: git_default_regex } }
	return git_versions_from_tags(tags, match_regex)
}

pub fn git_match_data_equal(left GitMatchData, right GitMatchData) bool {
	return left.matches == right.matches && left.regex == right.regex && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.messages == right.messages && left.has_messages == right.has_messages
}

pub fn git_find_versions(request GitFindVersionsRequest, fetcher GitRemoteFetcher) !GitMatchData {
	mut data := GitMatchData{
		matches: map[string]string{}
		regex: request.regex
		url: request.url
		cached: request.content != none
		has_cached: request.content != none
	}
	if request.url.trim_space() == '' {
		return data
	}
	mut content := request.content or { '' }
	if !data.has_cached {
		remote := fetcher(request.url)!
		remote_content := if remote.has_content { remote.content } else { '' }
		data = GitMatchData{
			...data
			content: remote_content
			has_content: remote.has_content
			messages: remote.messages.clone()
			has_messages: remote.has_messages
		}
		content = remote_content
	}
	if content.trim_space() == '' {
		return data
	}
	candidates := if request.candidate_override.present {
		request.candidate_override.values.clone()
	} else {
		git_versions_from_content(GitVersionsRequest{
			content: content
			regex: request.regex
			has_block: request.has_block
			block_arity: request.block_arity
			block: request.block
		})!.map(GitVersionCandidate{ is_string: true, value: it })
	}
	mut matches := map[string]string{}
	for candidate in candidates {
		if candidate.is_string {
			matches[candidate.value] = candidate.value
		}
	}
	return GitMatchData{
		...data
		matches: matches
	}
}

pub fn git_native_remote_fetcher(url string) !GitRemoteData {
	return git_ls_remote_tags_native(url)
}
