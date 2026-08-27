module strategy

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy/git.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_writer `attr_writer :processed_urls` at line 37.
pub fn ruby_git_l37_d1_processed_urls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processed_urls=', ...args)
}

// Ruby method `self.preprocess_url(url)` at line 66.
pub fn ruby_git_l66_d2_self_preprocess_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.preprocess_url', ...args)
}

// Ruby method `self.match?(url)` at line 118.
pub fn ruby_git_l118_d3_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.match?', ...args)
}

// Ruby method `self.ls_remote_tags(url)` at line 129.
pub fn ruby_git_l129_d4_self_ls_remote_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ls_remote_tags', ...args)
}

// Ruby method `self.tags_from_content(content)` at line 152.
pub fn ruby_git_l152_d5_self_tags_from_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.tags_from_content', ...args)
}

// Ruby method `self.versions_from_content(content, regex = nil, &block)` at line 170.
pub fn ruby_git_l170_d6_self_versions_from_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.versions_from_content', ...args)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 207.
pub fn ruby_git_l207_d7_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.find_versions', ...args)
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
