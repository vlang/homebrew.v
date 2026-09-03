module cmd

import brew_runtime
import net.http
import x.json2

// Translated from Homebrew/brew `cmd/source.rb`.
// The original source is retained below until every stub has a typed V body.

pub const source_homebrew_repository = 'https://github.com/Homebrew/brew'

pub struct SourceFormula {
pub:
	name       string
	head_url   string
	stable_url string
	homepage   string
}

pub struct SourceHttpResult {
pub:
	body    string
	success bool
}

pub type SourceHttpGetter = fn (string) !SourceHttpResult

pub struct SourceCommandPlan {
pub:
	messages  []string
	warnings  []string
	repo_urls []string
}

fn source_default_http_get(url string) !SourceHttpResult {
	response := http.get(url)!
	return SourceHttpResult{
		body: response.body
		success: response.status_code >= 200 && response.status_code < 300
	}
}

fn source_is_repo_character(character u8) bool {
	return character.is_alnum() || character == `_` || character == `.` || character == `-`
}

fn source_valid_repo_component(component string) bool {
	return component != '' && component.bytes().all(source_is_repo_character(it))
}

fn source_host_remainder(url string, host string) ?string {
	mut match_index := -1
	mut prefix_length := 0
	for prefix in ['https://${host}/', 'http://${host}/'] {
		if index := url.index(prefix) {
			if match_index < 0 || index < match_index {
				match_index = index
				prefix_length = prefix.len
			}
		}
	}
	if match_index < 0 {
		return none
	}
	return url[match_index + prefix_length..]
}

fn source_component_prefix(value string) string {
	mut length := 0
	for character in value.bytes() {
		if !source_is_repo_character(character) {
			break
		}
		length++
	}
	return value[..length]
}

fn source_two_component_repo_url(url string, host string, canonical_host string,
	first_prefix string) ?string {
	remainder := source_host_remainder(url, host) or { return none }
	if !remainder.starts_with(first_prefix) {
		return none
	}
	without_prefix := remainder[first_prefix.len..]
	slash := without_prefix.index('/') or { return none }
	first := without_prefix[..slash]
	second := source_component_prefix(without_prefix[slash + 1..]).trim_string_right('.git')
	if !source_valid_repo_component(first) || !source_valid_repo_component(second) {
		return none
	}
	return 'https://${canonical_host}/${first_prefix}${first}/${second}'
}

pub fn source_github_repo_url(url string) ?string {
	return source_two_component_repo_url(url, 'github.com', 'github.com', '')
}

pub fn source_gitlab_repo_url(url string) ?string {
	remainder := source_host_remainder(url, 'gitlab.com') or { return none }
	mut terminator_index := -1
	for terminator in ['/-/', '.git', '/archive/'] {
		if index := remainder.index(terminator) {
			if terminator_index < 0 || index < terminator_index {
				terminator_index = index
			}
		}
	}
	if terminator_index <= 0 {
		return none
	}
	path := remainder[..terminator_index]
	components := path.split('/')
	if components.any(!source_valid_repo_component(it)) {
		return none
	}
	return 'https://gitlab.com/${path}'
}

pub fn source_bitbucket_repo_url(url string) ?string {
	return source_two_component_repo_url(url, 'bitbucket.org', 'bitbucket.org', '')
}

pub fn source_codeberg_repo_url(url string) ?string {
	return source_two_component_repo_url(url, 'codeberg.org', 'codeberg.org', '')
}

pub fn source_sourcehut_repo_url(url string) ?string {
	if source_host_remainder(url, 'git.sr.ht') != none {
		return source_two_component_repo_url(url, 'git.sr.ht', 'sr.ht', '~')
	}
	return source_two_component_repo_url(url, 'sr.ht', 'sr.ht', '~')
}

fn source_pypi_package_name(url string) ?string {
	mut remainder := ''
	for prefix in [
		'https://files.pythonhosted.org/packages/',
		'http://files.pythonhosted.org/packages/',
	] {
		if url.starts_with(prefix) {
			remainder = url[prefix.len..]
			break
		}
	}
	if remainder == '' {
		return none
	}
	parts := remainder.split('/')
	if parts.len < 2 || parts.any(it == '') {
		return none
	}
	filename := parts.last()
	mut stem := ''
	if tar_index := filename.last_index('.tar.') {
		extension := filename[tar_index + '.tar.'.len..]
		if extension != '' && extension.bytes().all(it.is_alnum() && !it.is_capital()) {
			stem = filename[..tar_index]
		}
	}
	if stem == '' {
		dot := filename.last_index('.') or { return none }
		extension := filename[dot + 1..]
		if extension == '' || !extension.bytes().all(it.is_alnum() && !it.is_capital()) {
			return none
		}
		stem = filename[..dot]
	}
	hyphen := stem.last_index('-') or { return none }
	if hyphen <= 0 || hyphen + 1 >= stem.len {
		return none
	}
	return stem[..hyphen]
}

fn source_npm_package_name(url string) ?string {
	mut remainder := ''
	for prefix in ['https://registry.npmjs.org/', 'http://registry.npmjs.org/'] {
		if url.starts_with(prefix) {
			remainder = url[prefix.len..]
			break
		}
	}
	if remainder == '' {
		return none
	}
	parts := remainder.split('/')
	if remainder.starts_with('@') {
		if parts.len < 3 || !source_valid_repo_component(parts[0][1..])
			|| !source_valid_repo_component(parts[1]) {
			return none
		}
		return '${parts[0]}/${parts[1]}'
	}
	if parts.len < 2 || !source_valid_repo_component(parts[0]) {
		return none
	}
	return parts[0]
}

fn source_encode_uri_component(value string) string {
	mut encoded := ''
	for character in value.bytes() {
		if character.is_alnum() || character in [`-`, `_`, `.`, `~`] {
			encoded += character.ascii_str()
		} else {
			encoded += '%${character:02X}'
		}
	}
	return encoded
}

fn source_json_object(contents string) ?map[string]json2.Any {
	decoded := json2.decode[json2.Any](contents) or { return none }
	if decoded is map[string]json2.Any {
		return decoded.clone()
	}
	return none
}

fn source_pypi_project_url(contents string, fetcher SourceHttpGetter) ?string {
	document := source_json_object(contents) or { return none }
	info_value := document['info'] or { return none }
	if info_value !is map[string]json2.Any {
		return none
	}
	info := info_value as map[string]json2.Any
	project_urls_value := info['project_urls'] or { return none }
	if project_urls_value !is map[string]json2.Any {
		return none
	}
	mut project_urls := map[string]string{}
	for key, value in project_urls_value as map[string]json2.Any {
		if value is string {
			project_urls[key.to_lower()] = value
		}
	}
	if repository := project_urls['repository'] {
		return repository
	}
	if source := project_urls['source'] {
		return source
	}
	homepage := project_urls['homepage'] or { return none }
	return source_url_to_repo(homepage, fetcher)
}

fn source_npm_project_url(contents string) ?string {
	document := source_json_object(contents) or { return none }
	repository_value := document['repository'] or { return none }
	if repository_value !is map[string]json2.Any {
		return none
	}
	repository := repository_value as map[string]json2.Any
	url_value := repository['url'] or { return none }
	if url_value !is string {
		return none
	}
	repository_url := url_value as string
	return repository_url.trim_string_left('git+')
}

pub fn source_pypi_repo_url(url string, fetcher SourceHttpGetter) ?string {
	package_name := source_pypi_package_name(url) or { return none }
	api_name := package_name.replace('%20', '-').replace('_', '-')
	result := fetcher('https://pypi.org/pypi/${api_name}/json') or { return none }
	if !result.success {
		return none
	}
	return source_pypi_project_url(result.body, fetcher)
}

pub fn source_npm_repo_url(url string, fetcher SourceHttpGetter) ?string {
	package_name := source_npm_package_name(url) or { return none }
	api_url := 'https://registry.npmjs.org/${source_encode_uri_component(package_name)}/latest'
	result := fetcher(api_url) or { return none }
	if !result.success {
		return none
	}
	return source_npm_project_url(result.body)
}

pub fn source_url_to_repo(url string, fetcher SourceHttpGetter) ?string {
	if repo_url := source_github_repo_url(url) {
		return repo_url
	}
	if repo_url := source_gitlab_repo_url(url) {
		return repo_url
	}
	if repo_url := source_bitbucket_repo_url(url) {
		return repo_url
	}
	if repo_url := source_codeberg_repo_url(url) {
		return repo_url
	}
	if repo_url := source_sourcehut_repo_url(url) {
		return repo_url
	}
	if repo_url := source_pypi_repo_url(url, fetcher) {
		return repo_url
	}
	return source_npm_repo_url(url, fetcher)
}

pub fn source_extract_repo_url(formula SourceFormula, fetcher SourceHttpGetter) ?string {
	for url in [formula.head_url, formula.stable_url, formula.homepage] {
		if url == '' {
			continue
		}
		if repo_url := source_url_to_repo(url, fetcher) {
			return repo_url
		}
	}
	return none
}

pub fn plan_source_command(formulae []SourceFormula, fetcher SourceHttpGetter) SourceCommandPlan {
	if formulae.len == 0 {
		return SourceCommandPlan{
			repo_urls: [source_homebrew_repository]
		}
	}
	mut messages := []string{}
	mut warnings := []string{}
	mut repo_urls := []string{}
	for formula in formulae {
		if repo_url := source_extract_repo_url(formula, fetcher) {
			messages << 'Opening repository for ${formula.name}'
			repo_urls << repo_url
		} else {
			warnings << 'Could not determine repository URL for ${formula.name}'
		}
	}
	return SourceCommandPlan{
		messages: messages
		warnings: warnings
		repo_urls: repo_urls
	}
}

pub fn source_formula_value(formula SourceFormula) brew_runtime.Value {
	return brew_runtime.structured_value('Formula', formula.name, {
		'name':       formula.name
		'head_url':   formula.head_url
		'stable_url': formula.stable_url
		'homepage':   formula.homepage
	})
}

fn source_formula_from_value(value brew_runtime.Value) SourceFormula {
	return SourceFormula{
		name: value.attributes['name'] or { value.as_string() }
		head_url: value.attributes['head_url'] or { '' }
		stable_url: value.attributes['stable_url'] or { '' }
		homepage: value.attributes['homepage'] or { '' }
	}
}

pub fn source_command_plan_value(plan SourceCommandPlan) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'SourceCommandPlan'
		repr: plan.repo_urls.join(' ')
		map_data: {
			'messages':  brew_runtime.string_array_value(plan.messages)
			'warnings':  brew_runtime.string_array_value(plan.warnings)
			'repo_urls': brew_runtime.string_array_value(plan.repo_urls)
		}
	}
}

fn source_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn source_optional_string_value(value ?string) brew_runtime.Value {
	if result := value {
		return brew_runtime.string_value(result)
	}
	return source_nil()
}

fn source_boundary_http_result(value brew_runtime.Value) SourceHttpResult {
	return SourceHttpResult{
		body: value.attributes['body'] or { value.as_string() }
		success: (value.attributes['success'] or { 'true' }) == 'true'
	}
}

fn source_no_http_get(_ string) !SourceHttpResult {
	return SourceHttpResult{}
}

// Ruby method `run` at line 25.
pub fn ruby_source_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	formulae := if args.len == 0 {
		[]brew_runtime.Value{}
	} else if args[0].type_name == 'Array' {
		args[0].as_array() or { []brew_runtime.Value{} }
	} else {
		args
	}
	return source_command_plan_value(plan_source_command(formulae.map(source_formula_from_value(it)), source_default_http_get))
}

// Ruby method `url_to_repo(url)` at line 49.
pub fn ruby_source_l49_d2_url_to_repo(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return source_nil()
	}
	return source_optional_string_value(source_url_to_repo(args[0].as_string(), source_default_http_get))
}

// Ruby method `github_repo_url(url)` at line 60.
pub fn ruby_source_l60_d3_github_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return source_nil()
	}
	return source_optional_string_value(source_github_repo_url(args[0].as_string()))
}

// Ruby method `gitlab_repo_url(url)` at line 76.
pub fn ruby_source_l76_d4_gitlab_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return source_nil()
	}
	return source_optional_string_value(source_gitlab_repo_url(args[0].as_string()))
}

// Ruby method `bitbucket_repo_url(url)` at line 90.
pub fn ruby_source_l90_d5_bitbucket_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return source_nil()
	}
	return source_optional_string_value(source_bitbucket_repo_url(args[0].as_string()))
}

// Ruby method `codeberg_repo_url(url)` at line 106.
pub fn ruby_source_l106_d6_codeberg_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return source_nil()
	}
	return source_optional_string_value(source_codeberg_repo_url(args[0].as_string()))
}

// Ruby method `sourcehut_repo_url(url)` at line 122.
pub fn ruby_source_l122_d7_sourcehut_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return source_nil()
	}
	return source_optional_string_value(source_sourcehut_repo_url(args[0].as_string()))
}

// Ruby method `pypi_repo_url(url)` at line 138.
pub fn ruby_source_l138_d8_pypi_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return source_nil()
	}
	if args.len > 1 {
		if source_pypi_package_name(args[0].as_string()) == none {
			return source_nil()
		}
		response := source_boundary_http_result(args[1])
		if !response.success {
			return source_nil()
		}
		return source_optional_string_value(source_pypi_project_url(response.body, source_no_http_get))
	}
	return source_optional_string_value(source_pypi_repo_url(args[0].as_string(), source_default_http_get))
}

// Ruby method `npm_repo_url(url)` at line 168.
pub fn ruby_source_l168_d9_npm_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return source_nil()
	}
	if args.len > 1 {
		if source_npm_package_name(args[0].as_string()) == none {
			return source_nil()
		}
		response := source_boundary_http_result(args[1])
		if !response.success {
			return source_nil()
		}
		return source_optional_string_value(source_npm_project_url(response.body))
	}
	return source_optional_string_value(source_npm_repo_url(args[0].as_string(), source_default_http_get))
}

// Ruby method `extract_repo_url(formula)` at line 194.
pub fn ruby_source_l194_d10_extract_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return source_nil()
	}
	return source_optional_string_value(source_extract_repo_url(source_formula_from_value(args[0]), source_default_http_get))
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
