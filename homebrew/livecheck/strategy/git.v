module strategy

import ruby
import homebrew.download_strategy
import net.urllib
import regex

// Translated from Homebrew/brew `livecheck/strategy/git.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type GitCommandRunner = fn(GitCommand) !GitCommandOutput

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

pub type GitVersionsBlock = fn([]string, ?GitRegex) !GitBlockReturn

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

pub type GitRemoteFetcher = fn(string) !GitRemoteData

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
			message_content.split('\n')} else {
			[]string{}}
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

// Ruby attr_writer `attr_writer :processed_urls` at line 37.
pub fn ruby_git_l37_d1_processed_urls(mut state GitState, processed_urls map[string]string) {
	git_set_processed_urls(mut state, processed_urls)
}

// Ruby method `self.preprocess_url(url)` at line 66.
pub fn ruby_git_l66_d2_self_preprocess_url(mut state GitState, url string) string {
	return git_preprocess_url(mut state, url)
}

// Ruby method `self.match?(url)` at line 118.
pub fn ruby_git_l118_d3_self_match(mut state GitState, url string) bool {
	return git_matches(mut state, url)
}

// Ruby method `self.ls_remote_tags(url)` at line 129.
pub fn ruby_git_l129_d4_self_ls_remote_tags(url string, runner GitCommandRunner) !GitRemoteData {
	return git_ls_remote_tags(url, runner)
}

// Ruby method `self.tags_from_content(content)` at line 152.
pub fn ruby_git_l152_d5_self_tags_from_content(content string) []string {
	return git_tags_from_content(content)
}

// Ruby method `self.versions_from_content(content, regex = nil, &block)` at line 170.
pub fn ruby_git_l170_d6_self_versions_from_content(request GitVersionsRequest) ![]string {
	return git_versions_from_content(request)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 207.
pub fn ruby_git_l207_d7_self_find_versions(request GitFindVersionsRequest,
	remote_fetcher GitRemoteFetcher) !GitMatchData {
	return git_find_versions(request, remote_fetcher)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategic"
// 5: require "system_command"
// 6: require "uri"
// 7:
// 8: module Homebrew
// 9:   module Livecheck
// 10:     module Strategy
// 11:       # The {Git} strategy identifies versions of software in a Git repository
// 12:       # by checking the tags using `git ls-remote --tags`.
// 13:       #
// 14:       # Livecheck has historically prioritized the {Git} strategy over others
// 15:       # and this behavior was continued when the priority setup was created.
// 16:       # This is partly related to Livecheck checking formula URLs in order of
// 17:       # `head`, `stable` and then `homepage`. The higher priority here may
// 18:       # be removed (or altered) in the future if we reevaluate this particular
// 19:       # behavior.
// 20:       #
// 21:       # This strategy does not have a default regex. Instead, it simply removes
// 22:       # any non-digit text from the start of tags and parses the rest as a
// 23:       # {Version}. This works for some simple situations but even one unusual
// 24:       # tag can cause a bad result. It's better to provide a regex in a
// 25:       # `livecheck` block, so `livecheck` only matches what we really want.
// 26:       #
// 27:       # @api public
// 28:       class Git
// 29:         extend Strategic
// 30:         extend SystemCommand::Mixin
// 31:
// 32:         # Used to cache processed URLs, to avoid duplicating effort.
// 33:         @processed_urls = T.let({}, T::Hash[String, String])
// 34:
// 35:         class << self
// 36:           sig { params(processed_urls: T::Hash[String, String]).void }
// 37:           attr_writer :processed_urls
// 38:         end
// 39:
// 40:         # The priority of the strategy on an informal scale of 1 to 10 (from
// 41:         # lowest to highest).
// 42:         PRIORITY = 8
// 43:
// 44:         # The regex used to extract tags from `git ls-remote --tags` output.
// 45:         TAG_REGEX = %r{^\h+\s+refs/tags/(.+?)(?:\^{})?$}
// 46:
// 47:         # The default regex used to naively identify versions from tags when a
// 48:         # regex isn't provided.
// 49:         DEFAULT_REGEX = /\D*(.+)/
// 50:
// 51:         GITEA_INSTANCES = %w[
// 52:           codeberg.org
// 53:           gitea.com
// 54:           opendev.org
// 55:           tildegit.org
// 56:         ].freeze
// 57:         private_constant :GITEA_INSTANCES
// 58:
// 59:         GOGS_INSTANCES = %w[
// 60:           lolg.it
// 61:         ].freeze
// 62:         private_constant :GOGS_INSTANCES
// 63:
// 64:         # Processes and returns the URL used by livecheck.
// 65:         sig { params(url: String).returns(String) }
// 66:         def self.preprocess_url(url)
// 67:           processed_url = @processed_urls[url]
// 68:           return processed_url if processed_url
// 69:
// 70:           begin
// 71:             uri = URI.parse(url)
// 72:           rescue URI::InvalidURIError
// 73:             return url
// 74:           end
// 75:
// 76:           host = uri.host
// 77:           path = uri.path
// 78:           return url if host.nil? || path.blank?
// 79:
// 80:           host = "github.com" if host == "github.s3.amazonaws.com"
// 81:           path = path.delete_prefix("/").delete_suffix(".git")
// 82:           scheme = uri.scheme
// 83:
// 84:           if host == "github.com"
// 85:             return url if path.match? %r{/releases/latest/?$}
// 86:
// 87:             owner, repo = path.delete_prefix("downloads/").split("/")
// 88:             processed_url = "#{scheme}://#{host}/#{owner}/#{repo}.git"
// 89:           elsif GITEA_INSTANCES.include?(host)
// 90:             return url if path.match? %r{/releases/latest/?$}
// 91:
// 92:             owner, repo = path.split("/")
// 93:             processed_url = "#{scheme}://#{host}/#{owner}/#{repo}.git"
// 94:           elsif GOGS_INSTANCES.include?(host)
// 95:             owner, repo = path.split("/")
// 96:             processed_url = "#{scheme}://#{host}/#{owner}/#{repo}.git"
// 97:           # sourcehut
// 98:           elsif host == "git.sr.ht"
// 99:             owner, repo = path.split("/")
// 100:             processed_url = "#{scheme}://#{host}/#{owner}/#{repo}"
// 101:           # GitLab (gitlab.com or self-hosted)
// 102:           elsif path.include?("/-/archive/")
// 103:             processed_url = url.sub(%r{/-/archive/.*$}i, ".git")
// 104:           end
// 105:
// 106:           if processed_url && (processed_url != url)
// 107:             @processed_urls[url] = processed_url
// 108:           else
// 109:             url
// 110:           end
// 111:         end
// 112:
// 113:         # Whether the strategy can be applied to the provided URL.
// 114:         #
// 115:         # @param url [String] the URL to match against
// 116:         # @return [Boolean]
// 117:         sig { override.params(url: String).returns(T::Boolean) }
// 118:         def self.match?(url)
// 119:           url = preprocess_url(url)
// 120:           (DownloadStrategyDetector.detect(url) <= GitDownloadStrategy) == true
// 121:         end
// 122:
// 123:         # Runs `git ls-remote --tags` with the provided URL and returns a hash
// 124:         # containing the `stdout` content or any errors from `stderr`.
// 125:         #
// 126:         # @param url [String] the URL of the Git repository to check
// 127:         # @return [Hash]
// 128:         sig { params(url: String).returns(T::Hash[Symbol, T.any(String, T::Array[String])]) }
// 129:         def self.ls_remote_tags(url)
// 130:           stdout, stderr, _status = system_command(
// 131:             "git",
// 132:             args:         ["ls-remote", "--tags", "--end-of-options", url],
// 133:             env:          { "GIT_TERMINAL_PROMPT" => "0" },
// 134:             print_stdout: false,
// 135:             print_stderr: false,
// 136:             debug:        false,
// 137:             verbose:      false,
// 138:           ).to_a
// 139:
// 140:           data = {}
// 141:           data[:content] = stdout.clone if stdout.present?
// 142:           data[:messages] = stderr.split("\n") if stderr.present?
// 143:
// 144:           data
// 145:         end
// 146:
// 147:         # Parse tags from `git ls-remote --tags` output.
// 148:         #
// 149:         # @param content [String] Git output to parse for tags
// 150:         # @return [Array]
// 151:         sig { params(content: String).returns(T::Array[String]) }
// 152:         def self.tags_from_content(content)
// 153:           content.scan(TAG_REGEX).flatten.uniq
// 154:         end
// 155:
// 156:         # Identify versions from `git ls-remote --tags` output using a provided
// 157:         # regex or the `DEFAULT_REGEX`. The regex is expected to use a capture
// 158:         # group around the version text.
// 159:         #
// 160:         # @param content [String] the content to check
// 161:         # @param regex [Regexp, nil] a regex for matching versions in content
// 162:         # @return [Array]
// 163:         sig {
// 164:           params(
// 165:             content: String,
// 166:             regex:   T.nilable(Regexp),
// 167:             block:   T.nilable(Proc),
// 168:           ).returns(T::Array[String])
// 169:         }
// 170:         def self.versions_from_content(content, regex = nil, &block)
// 171:           tags = tags_from_content(content)
// 172:           return [] if tags.empty?
// 173:
// 174:           if block
// 175:             block_return_value = if regex.present?
// 176:               yield(tags, regex)
// 177:             elsif block.arity == 2
// 178:               yield(tags, DEFAULT_REGEX)
// 179:             else
// 180:               yield(tags)
// 181:             end
// 182:             return Strategy.handle_block_return(block_return_value)
// 183:           end
// 184:
// 185:           match_regex = regex || DEFAULT_REGEX
// 186:           tags.filter_map { |tag| tag[match_regex, 1] }.uniq
// 187:         end
// 188:
// 189:         # Checks the Git tags for new versions. When a regex isn't provided,
// 190:         # this strategy simply removes non-digits from the start of tag
// 191:         # strings and parses the remaining text as a {Version}.
// 192:         #
// 193:         # @param url [String] the URL of the Git repository to check
// 194:         # @param regex [Regexp, nil] a regex for matching versions in content
// 195:         # @param content [String, nil] content to check instead of fetching
// 196:         # @param options [Options] options to modify behavior
// 197:         # @return [Hash]
// 198:         sig {
// 199:           override.params(
// 200:             url:     String,
// 201:             regex:   T.nilable(Regexp),
// 202:             content: T.nilable(String),
// 203:             options: Options,
// 204:             block:   T.nilable(Proc),
// 205:           ).returns(T::Hash[Symbol, T.anything])
// 206:         }
// 207:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 208:           match_data = { matches: {}, regex:, url: }
// 209:           match_data[:cached] = true if content
// 210:           return match_data if url.blank?
// 211:
// 212:           unless match_data[:cached]
// 213:             match_data.merge!(ls_remote_tags(url))
// 214:             content = match_data[:content]
// 215:           end
// 216:           return match_data if content.blank?
// 217:
// 218:           versions_from_content(content, regex, &block).each do |match_text|
// 219:             next unless match_text.is_a?(String)
// 220:
// 221:             match_data[:matches][match_text] = Version.new(match_text)
// 222:           end
// 223:
// 224:           match_data
// 225:         end
// 226:       end
// 227:     end
// 228:   end
// 229: end
