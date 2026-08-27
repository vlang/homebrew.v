module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/source.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 25.
pub fn ruby_source_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `url_to_repo(url)` at line 49.
pub fn ruby_source_l49_d2_url_to_repo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url_to_repo', ...args)
}

// Ruby method `github_repo_url(url)` at line 60.
pub fn ruby_source_l60_d3_github_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('github_repo_url', ...args)
}

// Ruby method `gitlab_repo_url(url)` at line 76.
pub fn ruby_source_l76_d4_gitlab_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gitlab_repo_url', ...args)
}

// Ruby method `bitbucket_repo_url(url)` at line 90.
pub fn ruby_source_l90_d5_bitbucket_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bitbucket_repo_url', ...args)
}

// Ruby method `codeberg_repo_url(url)` at line 106.
pub fn ruby_source_l106_d6_codeberg_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('codeberg_repo_url', ...args)
}

// Ruby method `sourcehut_repo_url(url)` at line 122.
pub fn ruby_source_l122_d7_sourcehut_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sourcehut_repo_url', ...args)
}

// Ruby method `pypi_repo_url(url)` at line 138.
pub fn ruby_source_l138_d8_pypi_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pypi_repo_url', ...args)
}

// Ruby method `npm_repo_url(url)` at line 168.
pub fn ruby_source_l168_d9_npm_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('npm_repo_url', ...args)
}

// Ruby method `extract_repo_url(formula)` at line 194.
pub fn ruby_source_l194_d10_extract_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extract_repo_url', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "utils/curl"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Source < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Open a <formula>'s source repository in a browser, or open
// 14:           Homebrew's own repository if no argument is provided.
// 15:
// 16:           The repository URL is determined from the formula's head URL,
// 17:           stable URL, or homepage. Supports GitHub, GitLab, Bitbucket, Codeberg and
// 18:           SourceHut repositories.
// 19:         EOS
// 20:
// 21:         named_args :formula
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         if args.no_named?
// 27:           exec_browser "https://github.com/Homebrew/brew"
// 28:           return
// 29:         end
// 30:
// 31:         formulae = args.named.to_formulae
// 32:         repo_urls = formulae.filter_map do |formula|
// 33:           repo_url = extract_repo_url(formula)
// 34:           if repo_url
// 35:             puts "Opening repository for #{formula.name}"
// 36:             repo_url
// 37:           else
// 38:             opoo "Could not determine repository URL for #{formula.name}"
// 39:             nil
// 40:           end
// 41:         end
// 42:
// 43:         return if repo_urls.empty?
// 44:
// 45:         exec_browser(*repo_urls)
// 46:       end
// 47:
// 48:       sig { params(url: String).returns(T.nilable(String)) }
// 49:       def url_to_repo(url)
// 50:         github_repo_url(url) ||
// 51:           gitlab_repo_url(url) ||
// 52:           bitbucket_repo_url(url) ||
// 53:           codeberg_repo_url(url) ||
// 54:           sourcehut_repo_url(url) ||
// 55:           pypi_repo_url(url) ||
// 56:           npm_repo_url(url)
// 57:       end
// 58:
// 59:       sig { params(url: String).returns(T.nilable(String)) }
// 60:       def github_repo_url(url)
// 61:         regex = %r{
// 62:           https?://github\.com/
// 63:           (?<user>[\w.-]+)/
// 64:           (?<repo>[\w.-]+)
// 65:           (?:/.*)?
// 66:         }x
// 67:         match = url.match(regex)
// 68:         return unless match
// 69:
// 70:         user = match[:user]
// 71:         repo = match[:repo]&.delete_suffix(".git")
// 72:         "https://github.com/#{user}/#{repo}"
// 73:       end
// 74:
// 75:       sig { params(url: String).returns(T.nilable(String)) }
// 76:       def gitlab_repo_url(url)
// 77:         regex = %r{
// 78:           https?://gitlab\.com/
// 79:           (?<path>(?:[\w.-]+/)*?[\w.-]+)
// 80:           (?:/-/|\.git|/archive/)
// 81:         }x
// 82:         match = url.match(regex)
// 83:         return unless match
// 84:
// 85:         path = match[:path]&.delete_suffix(".git")
// 86:         "https://gitlab.com/#{path}"
// 87:       end
// 88:
// 89:       sig { params(url: String).returns(T.nilable(String)) }
// 90:       def bitbucket_repo_url(url)
// 91:         regex = %r{
// 92:           https?://bitbucket\.org/
// 93:           (?<user>[\w.-]+)/
// 94:           (?<repo>[\w.-]+)
// 95:           (?:/.*)?
// 96:         }x
// 97:         match = url.match(regex)
// 98:         return unless match
// 99:
// 100:         user = match[:user]
// 101:         repo = match[:repo]&.delete_suffix(".git")
// 102:         "https://bitbucket.org/#{user}/#{repo}"
// 103:       end
// 104:
// 105:       sig { params(url: String).returns(T.nilable(String)) }
// 106:       def codeberg_repo_url(url)
// 107:         regex = %r{
// 108:           https?://codeberg\.org/
// 109:           (?<user>[\w.-]+)/
// 110:           (?<repo>[\w.-]+)
// 111:           (?:/.*)?
// 112:         }x
// 113:         match = url.match(regex)
// 114:         return unless match
// 115:
// 116:         user = match[:user]
// 117:         repo = match[:repo]&.delete_suffix(".git")
// 118:         "https://codeberg.org/#{user}/#{repo}"
// 119:       end
// 120:
// 121:       sig { params(url: String).returns(T.nilable(String)) }
// 122:       def sourcehut_repo_url(url)
// 123:         regex = %r{
// 124:           https?://(?:git\.)?sr\.ht/
// 125:           ~(?<user>[\w.-]+)/
// 126:           (?<repo>[\w.-]+)
// 127:           (?:/.*)?
// 128:         }x
// 129:         match = url.match(regex)
// 130:         return unless match
// 131:
// 132:         user = match[:user]
// 133:         repo = match[:repo]&.delete_suffix(".git")
// 134:         "https://sr.ht/~#{user}/#{repo}"
// 135:       end
// 136:
// 137:       sig { params(url: String).returns(T.nilable(String)) }
// 138:       def pypi_repo_url(url)
// 139:         regex = %r{
// 140:           https?://files\.pythonhosted\.org
// 141:           /packages
// 142:           (?:/[^/]+)+
// 143:           /(?<package_name>.+)-
// 144:           .*?
// 145:           (?:\.tar\.[a-z0-9]+|\.[a-z0-9]+)
// 146:         }x
// 147:         match = url.match(regex)
// 148:         return unless match
// 149:
// 150:         package_name = match[:package_name]
// 151:         return unless package_name
// 152:
// 153:         api_url = "https://pypi.org/pypi/#{package_name.gsub(/%20|_/, "-")}/json"
// 154:         curl_args = Utils::Curl.curl_args(show_error: false, retries: 2)
// 155:         stdout, _, status = Utils::Curl.curl_output(*curl_args, api_url)
// 156:
// 157:         return unless status.success?
// 158:
// 159:         project_urls = JSON.parse(stdout).dig("info", "project_urls")&.transform_keys(&:downcase)
// 160:
// 161:         project_urls["repository"] || project_urls["source"] ||
// 162:           url_to_repo(project_urls.fetch("homepage", "")) # Homepages often link to source repositories
// 163:       rescue JSON::ParserError
// 164:         nil
// 165:       end
// 166:
// 167:       sig { params(url: String).returns(T.nilable(String)) }
// 168:       def npm_repo_url(url)
// 169:         regex = %r{
// 170:           https?://registry\.npmjs\.org/
// 171:           (?<package_name>(?:@[\w.-]+/)?[\w.-]+)/
// 172:           (?:/.*)?
// 173:         }x
// 174:         match = url.match(regex)
// 175:         return unless match
// 176:
// 177:         package_name = match[:package_name]
// 178:         return unless package_name
// 179:
// 180:         api_url = "https://registry.npmjs.org/#{URI.encode_uri_component(package_name)}/latest"
// 181:         curl_args = Utils::Curl.curl_args(show_error: false, retries: 2)
// 182:         stdout, _, status = Utils::Curl.curl_output(*curl_args, api_url)
// 183:         return unless status.success?
// 184:
// 185:         url = JSON.parse(stdout).dig("repository", "url")
// 186:         url&.delete_prefix("git+")
// 187:       rescue JSON::ParserError
// 188:         nil
// 189:       end
// 190:
// 191:       private
// 192:
// 193:       sig { params(formula: Formula).returns(T.nilable(String)) }
// 194:       def extract_repo_url(formula)
// 195:         urls_to_check = [
// 196:           formula.head&.url,
// 197:           formula.stable&.url,
// 198:           formula.homepage,
// 199:         ]
// 200:
// 201:         urls_to_check.each do |url|
// 202:           next if url.nil?
// 203:
// 204:           repo_url = url_to_repo(url)
// 205:           return repo_url if repo_url
// 206:         end
// 207:
// 208:         nil
// 209:       end
// 210:     end
// 211:   end
// 212: end
