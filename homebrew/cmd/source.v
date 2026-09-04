module cmd

import ruby
import net.http
import x.json2

// Translated from Homebrew/brew `cmd/source.rb`.

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

pub fn source_formula_value(formula SourceFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.name, {
		'name':       formula.name
		'head_url':   formula.head_url
		'stable_url': formula.stable_url
		'homepage':   formula.homepage
	})
}

fn source_formula_from_value(value ruby.Value) SourceFormula {
	return SourceFormula{
		name: value.attributes['name'] or { value.as_string() }
		head_url: value.attributes['head_url'] or { '' }
		stable_url: value.attributes['stable_url'] or { '' }
		homepage: value.attributes['homepage'] or { '' }
	}
}

pub fn source_command_plan_value(plan SourceCommandPlan) ruby.Value {
	return ruby.Value{
		type_name: 'SourceCommandPlan'
		repr: plan.repo_urls.join(' ')
		map_data: {
			'messages':  ruby.string_array_value(plan.messages)
			'warnings':  ruby.string_array_value(plan.warnings)
			'repo_urls': ruby.string_array_value(plan.repo_urls)
		}
	}
}

fn source_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn source_optional_string_value(value ?string) ruby.Value {
	if result := value {
		return ruby.string_value(result)
	}
	return source_nil()
}

fn source_boundary_http_result(value ruby.Value) SourceHttpResult {
	return SourceHttpResult{
		body: value.attributes['body'] or { value.as_string() }
		success: (value.attributes['success'] or { 'true' }) == 'true'
	}
}

fn source_no_http_get(_ string) !SourceHttpResult {
	return SourceHttpResult{}
}
