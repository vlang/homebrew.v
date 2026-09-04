module homebrew

import ruby
import homebrew.download_strategy
import homebrew.utils
import os

pub enum ResourceAuditorOwnerKind {
	formula
	cask
}

pub struct ResourceAuditorOwner {
pub:
	kind            ResourceAuditorOwnerKind
	name            string
	core_formula    bool
	bottle_defined  bool
	bottle_root_url string
}

pub struct ResourceAuditorResource {
pub mut:
	name         string
	has_name     bool
	version      Version
	has_version  bool
	checksum     Checksum
	has_checksum bool
	url          string
	has_url      bool
	mirrors      []string
	using        download_strategy.DownloadStrategy
	has_using    bool
	specs        map[string]string
	owner        ResourceAuditorOwner
	has_owner    bool
}

pub struct ResourceAuditorHttpDetails {
pub:
	status_code string
	final_url   string
	file_hash   string
}

pub type ResourceAuditorHttpChecker = fn(string, map[string]string, bool) !string

pub type ResourceAuditorHttpMirrorChecker = fn(string, bool) !ResourceAuditorHttpDetails

pub type ResourceAuditorRemoteChecker = fn(string) bool

pub type ResourceAuditorBranchDetector = fn(string) ?string

pub struct ResourceAuditorConfig {
pub:
	online                         bool
	strict                         bool
	only                           []string
	only_set                       bool
	except                         []string
	core_tap                       bool
	use_homebrew_curl              bool
	curl_recursive_dependencies    []string
	curl_formula_available         bool = true
	simulating_or_running_on_macos ?bool
	curl_installed                 ?bool
	curl_retries                   int = -1
	http_checker                   ResourceAuditorHttpChecker = resource_auditor_default_http_checker
	http_mirror_checker            ResourceAuditorHttpMirrorChecker = resource_auditor_default_http_mirror_checker
	git_remote_exists              ResourceAuditorRemoteChecker = resource_auditor_default_git_remote_exists
	svn_available                  ?bool
	svn_remote_exists              ResourceAuditorRemoteChecker = resource_auditor_default_svn_remote_exists
	branch_detector                ResourceAuditorBranchDetector = resource_auditor_default_branch_detector
}

@[heap]
pub struct ResourceAuditor {
pub:
	name                           string
	has_name                       bool
	version                        Version
	has_version                    bool
	checksum                       Checksum
	has_checksum                   bool
	url                            string
	has_url                        bool
	mirrors                        []string
	using                          download_strategy.DownloadStrategy
	has_using                      bool
	specs                          map[string]string
	owner                          ResourceAuditorOwner
	has_owner                      bool
	spec_name                      string
	online                         bool
	strict                         bool
	only                           []string
	only_set                       bool
	except                         []string
	core_tap                       bool
	use_homebrew_curl              bool
	curl_deps                      []string
	simulating_or_running_on_macos bool
	curl_installed                 bool
	curl_retries                   int
	http_checker                   ResourceAuditorHttpChecker = resource_auditor_default_http_checker
	http_mirror_checker            ResourceAuditorHttpMirrorChecker = resource_auditor_default_http_mirror_checker
	git_remote_exists              ResourceAuditorRemoteChecker = resource_auditor_default_git_remote_exists
	svn_available                  bool
	svn_remote_exists              ResourceAuditorRemoteChecker = resource_auditor_default_svn_remote_exists
	branch_detector                ResourceAuditorBranchDetector = resource_auditor_default_branch_detector
pub mut:
	problems []string
}

pub fn resource_auditor_resource(resource &Resource, owner ResourceAuditorOwner) ResourceAuditorResource {
	version := resource.version() or { null_version() }
	return ResourceAuditorResource{
		name: resource.name
		has_name: resource.has_name
		version: version
		has_version: !version.is_null()
		checksum: resource.checksum
		has_checksum: resource.has_checksum
		url: resource.url() or { '' }
		has_url: resource.has_url
		mirrors: resource.mirrors.clone()
		using: resource.strategy_value
		has_using: resource.has_url && resource.using() != none
		specs: resource.specs()
		owner: owner
		has_owner: true
	}
}

pub fn resource_auditor_curl_dependencies(recursive_dependencies []string, formula_available bool) []string {
	if !formula_available {
		return []string{}
	}
	mut dependencies := ['curl']
	for dependency in recursive_dependencies {
		if dependency !in dependencies {
			dependencies << dependency
		}
	}
	return dependencies
}

fn resource_auditor_running_on_macos() bool {
	$if macos {
		return true
	} $else {
		return false
	}
}

fn resource_auditor_curl_installed() bool {
	mut cellar := os.getenv('HOMEBREW_CELLAR')
	if cellar == '' && os.getenv('HOMEBREW_PREFIX') != '' {
		cellar = os.join_path(os.getenv('HOMEBREW_PREFIX'), 'Cellar')
	}
	return cellar != '' && utils.path_formula_any_version_installed(cellar, ['curl'])
}

fn resource_auditor_curl_retries() int {
	value := os.getenv('HOMEBREW_CURL_RETRIES')
	return if value == '' { 3 } else { value.int() }
}

fn resource_auditor_svn_available() bool {
	if _ := os.find_abs_path_of_executable('svn') {
		return true
	}
	return false
}

pub fn new_resource_auditor(resource ResourceAuditorResource, spec_name string,
	config ResourceAuditorConfig) &ResourceAuditor {
	return &ResourceAuditor{
		name: resource.name
		has_name: resource.has_name
		version: resource.version
		has_version: resource.has_version
		checksum: resource.checksum
		has_checksum: resource.has_checksum
		url: resource.url
		has_url: resource.has_url
		mirrors: resource.mirrors.clone()
		using: resource.using
		has_using: resource.has_using
		specs: resource.specs.clone()
		owner: resource.owner
		has_owner: resource.has_owner
		spec_name: spec_name
		online: config.online
		strict: config.strict
		only: config.only.clone()
		only_set: config.only_set || config.only.len > 0
		except: config.except.clone()
		core_tap: config.core_tap
		use_homebrew_curl: config.use_homebrew_curl
		curl_deps: resource_auditor_curl_dependencies(config.curl_recursive_dependencies, config.curl_formula_available)
		simulating_or_running_on_macos: config.simulating_or_running_on_macos or {
			resource_auditor_running_on_macos()
		}
		curl_installed: config.curl_installed or { resource_auditor_curl_installed() }
		curl_retries: if config.curl_retries >= 0 {
			config.curl_retries
		} else {
			resource_auditor_curl_retries()
		}
		http_checker: config.http_checker
		http_mirror_checker: config.http_mirror_checker
		git_remote_exists: config.git_remote_exists
		svn_available: config.svn_available or { resource_auditor_svn_available() }
		svn_remote_exists: config.svn_remote_exists
		branch_detector: config.branch_detector
	}
}

pub fn (auditor &ResourceAuditor) resource_name() ?string {
	return if auditor.has_name { auditor.name } else { none }
}

pub fn (auditor &ResourceAuditor) resource_version() ?Version {
	return if auditor.has_version { auditor.version } else { none }
}

pub fn (auditor &ResourceAuditor) resource_checksum() ?Checksum {
	return if auditor.has_checksum { auditor.checksum } else { none }
}

pub fn (auditor &ResourceAuditor) resource_url() ?string {
	return if auditor.has_url { auditor.url } else { none }
}

pub fn (auditor &ResourceAuditor) resource_using() ?download_strategy.DownloadStrategy {
	return if auditor.has_using { auditor.using } else { none }
}

pub fn (auditor &ResourceAuditor) resource_owner() ?ResourceAuditorOwner {
	return if auditor.has_owner { auditor.owner } else { none }
}

fn resource_auditor_audit_names() []string {
	return ['version', 'download_strategy', 'checksum',
		'resource_name_matches_pypi_package_name_in_url', 'urls', 'curl_dep_http_mirror',
		'head_branch']
}

pub fn (mut auditor ResourceAuditor) audit() ! {
	for name in resource_auditor_audit_names() {
		if auditor.only_set && name !in auditor.only {
			continue
		}
		if name in auditor.except {
			continue
		}
		match name {
			'version' { auditor.audit_version()! }
			'download_strategy' { auditor.audit_download_strategy()! }
			'checksum' { auditor.audit_checksum() }
			'resource_name_matches_pypi_package_name_in_url' {
				auditor.audit_resource_name_matches_pypi_package_name_in_url()!
			}
			'urls' { auditor.audit_urls()! }
			'curl_dep_http_mirror' { auditor.audit_curl_dep_http_mirror()! }
			'head_branch' { auditor.audit_head_branch()! }
			else {}
		}
	}
}

fn resource_auditor_valid_oci_tag(value string) bool {
	if value.len == 0 || value.len > 128 {
		return false
	}
	for index, character in value {
		if index == 0 {
			if !resource_auditor_ascii_alphanumeric(character) && character != `_` {
				return false
			}
		} else if !resource_auditor_ascii_alphanumeric(character) && character !in [`_`, `.`, `-`] {
			return false
		}
	}
	return true
}

fn resource_auditor_ascii_alphanumeric(character rune) bool {
	return (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`)
}

fn resource_auditor_github_package_component(value string) bool {
	return value != '' && value.runes().all(resource_auditor_ascii_alphanumeric(it) || it in [
		`_`,
		`-`,
	])
}

fn resource_auditor_github_packages_url(value string) bool {
	remainder := if value.starts_with('https://ghcr.io/v2/') {
		value['https://ghcr.io/v2/'.len..]
	} else if value.starts_with('docker://ghcr.io/') {
		value['docker://ghcr.io/'.len..]
	} else {
		return false
	}
	parts := remainder.split('/')
	return parts.len >= 2 && resource_auditor_github_package_component(parts[0]) && resource_auditor_github_package_component(parts[1])
}

pub fn (mut auditor ResourceAuditor) audit_version() ! {
	if !auditor.has_version {
		auditor.problem('Missing version')
		return
	}
	if auditor.has_owner && auditor.owner.kind == .formula && !resource_auditor_valid_oci_tag(auditor.version.to_s()) && (auditor.owner.core_formula || (auditor.owner.bottle_defined && resource_auditor_github_packages_url(auditor.owner.bottle_root_url))) {
		auditor.problem('`version ${auditor.version.to_s()}` does not match ^[a-zA-Z0-9_][a-zA-Z0-9._-]{0,127}\$')
		return
	}
	if !auditor.version.detected_from_url() {
		url := auditor.url_required()!
		detected := detect_version(url, auditor.specs['tag'] or { '' })
		if detected.to_s() == auditor.version.to_s() {
			auditor.problem('`version ${auditor.version.to_s()}` is redundant with version scanned from URL')
		}
	}
}

fn resource_auditor_git_strategy(strategy download_strategy.DownloadStrategy) bool {
	return strategy in [.git, .github_git]
}

fn resource_auditor_curl_strategy(strategy download_strategy.DownloadStrategy) bool {
	return strategy in [.curl_github_packages, .curl_apache_mirror, .pypi, .curl, .no_unzip_curl,
		.homebrew_curl, .curl_post]
}

pub fn (mut auditor ResourceAuditor) audit_download_strategy() ! {
	url := auditor.url_required()!
	url_strategy := download_strategy.detect_from_url(url)
	if ((auditor.has_using && auditor.using == .git) || resource_auditor_git_strategy(url_strategy)) && auditor.specs['tag'] or { '' } != '' && auditor.specs['revision'] or { '' } == '' {
		auditor.problem('Git should specify `revision:` when a `tag:` is specified.')
	}
	if !auditor.has_using {
		return
	}
	if auditor.using == .cvs {
		module_name := auditor.specs['module'] or { '' }
		if auditor.has_name && module_name == auditor.name {
			auditor.problem('Redundant `module:` value in URL')
		}
		last_colon := url.last_index(':') or { -1 }
		last_slash := url.last_index('/') or { -1 }
		if last_colon > last_slash && last_colon + 1 < url.len {
			appended_module := url[last_colon + 1..]
			if auditor.has_name && appended_module == auditor.name {
				auditor.problem('Redundant CVS module appended to URL')
			} else {
				auditor.problem('Specify CVS module as `module: "${appended_module}"` instead of appending it to the URL')
			}
		}
	}
	using_strategy := download_strategy.detect('', auditor.using)
	if url_strategy == using_strategy {
		auditor.problem('Redundant `using:` value in URL')
	}
}

pub fn (mut auditor ResourceAuditor) audit_checksum() {
	if auditor.spec_name == 'head' {
		return
	}
	strategy := download_strategy.detect(auditor.url, if auditor.has_using {
		auditor.using
	} else {
		none
	})
	if resource_auditor_curl_strategy(strategy) && (!auditor.has_checksum || auditor.checksum.is_empty()) {
		auditor.problem('Checksum is missing')
	}
}

fn resource_auditor_url_path(url string) string {
	scheme_index := url.index('://') or { -3 }
	start := scheme_index + 3
	remainder := if start >= 3 && start <= url.len { url[start..] } else { url }
	slash := remainder.index('/') or { return '' }
	mut path := remainder[slash..]
	if query := path.index('?') {
		path = path[..query]
	}
	if fragment := path.index('#') {
		path = path[..fragment]
	}
	return path
}

fn resource_auditor_pypi_name(url string) ?string {
	path := resource_auditor_url_path(url)
	if path == '' {
		return none
	}
	filename := os.file_name(path)
	if url.ends_with('.whl') {
		hyphen := filename.index('-') or { return filename.replace('_', '-').replace('.', '-') }
		return filename[..hyphen].replace('_', '-').replace('.', '-')
	}
	for component in path.split('/').reverse() {
		hyphen := component.last_index('-') or { continue }
		if hyphen > 0 {
			return component[..hyphen].replace('_', '-').replace('.', '-')
		}
	}
	return ''
}

pub fn (mut auditor ResourceAuditor) audit_resource_name_matches_pypi_package_name_in_url() ! {
	url := auditor.url_required()!
	if !url.starts_with('http://files.pythonhosted.org/packages/') && !url.starts_with('https://files.pythonhosted.org/packages/') {
		return
	}
	owner := auditor.owner_required()!
	if auditor.has_name && auditor.name == owner.name {
		return
	}
	pypi_name := resource_auditor_pypi_name(url) or { return }
	if auditor.name.to_lower() == pypi_name.to_lower() {
		return
	}
	auditor.problem("`resource` name should be '${pypi_name}' to match the PyPI package name")
}

pub fn (mut auditor ResourceAuditor) audit_urls() ! {
	mut urls := [auditor.url]
	urls << auditor.mirrors
	curl_dependency := auditor.is_curl_dependency()!
	owner := auditor.owner_required()!
	if auditor.simulating_or_running_on_macos && auditor.spec_name == 'stable' && owner.name != 'ca-certificates' && curl_dependency && !urls.any(it.starts_with('http://')) {
		auditor.problem('Should always include at least one HTTP mirror')
	}
	if !auditor.online {
		return
	}
	for url in urls {
		if !auditor.strict && url in auditor.mirrors {
			continue
		}
		strategy := download_strategy.detect(url, if auditor.has_using {
			auditor.using
		} else {
			none
		})
		if resource_auditor_curl_strategy(strategy) && !url.starts_with('file') {
			if strategy == .homebrew_curl && !auditor.curl_installed {
				return error('HomebrewCurlDownloadStrategyError: ${url}')
			}
			if (url.starts_with('http://ftp.gnu.org/') || url.starts_with('https://ftp.gnu.org/')) && url.len > 'https://ftp.gnu.org/'.len {
				continue
			}
			if !curl_dependency {
				content_problem := auditor.http_checker(url, auditor.specs, auditor.use_homebrew_curl)!
				if content_problem != '' {
					auditor.problem(content_problem)
				}
			}
		} else if resource_auditor_git_strategy(strategy) {
			mut remote_exists := false
			mut attempts := 0
			for !remote_exists && attempts < auditor.curl_retries {
				remote_exists = auditor.git_remote_exists(url)
				attempts++
			}
			if !remote_exists {
				auditor.problem('The URL ${url} is not a valid Git URL')
			}
		} else if strategy == .subversion && auditor.svn_available && !auditor.svn_remote_exists(url) {
			auditor.problem('The URL ${url} is not a valid SVN URL')
		}
	}
}

pub fn (mut auditor ResourceAuditor) audit_curl_dep_http_mirror() ! {
	if !auditor.online || auditor.spec_name != 'stable' {
		return
	}
	owner := auditor.owner_required()!
	if !auditor.has_name || auditor.name != owner.name || !auditor.is_curl_dependency()! {
		return
	}
	if !auditor.has_checksum {
		return
	}
	http_mirrors := auditor.mirrors.filter(it.starts_with('http://'))
	if http_mirrors.len == 0 {
		return
	}
	for mirror in http_mirrors {
		details := auditor.http_mirror_checker(mirror, auditor.use_homebrew_curl)!
		if utils.curl_http_status_ok(details.status_code) && !details.final_url.starts_with('https://') && details.file_hash == auditor.checksum.hexdigest {
			return
		}
	}
	auditor.problem('`curl` dependencies must have a working HTTP mirror that serves the expected checksum over plain HTTP.')
}

pub fn (mut auditor ResourceAuditor) audit_head_branch() ! {
	if !auditor.online || auditor.spec_name != 'head' || auditor.specs['tag'] or { '' } != '' || auditor.specs['revision'] or { '' } != '' {
		return
	}
	owner := auditor.owner_required()!
	if !auditor.has_name || auditor.name != owner.name || !auditor.url.ends_with('.git') || !auditor.git_remote_exists(auditor.url) {
		return
	}
	detected_branch := auditor.branch_detector(auditor.url) or { '' }
	branch := auditor.specs['branch'] or { '' }
	if branch == '' {
		auditor.problem('Git `head` URL must specify a branch name')
		return
	}
	if auditor.core_tap && branch != detected_branch {
		auditor.problem('To use a non-default HEAD branch, add the formula to `head_non_default_branch_allowlist.json`.')
	}
}

pub fn (mut auditor ResourceAuditor) problem(text string) {
	auditor.problems << text
}

pub fn (auditor &ResourceAuditor) is_curl_dependency() !bool {
	owner := auditor.owner_required()!
	return owner.name in auditor.curl_deps
}

pub fn (auditor &ResourceAuditor) owner_required() !ResourceAuditorOwner {
	if !auditor.has_owner {
		return error('ResourceAuditor owner is nil')
	}
	return auditor.owner
}

pub fn (auditor &ResourceAuditor) url_required() !string {
	if !auditor.has_url {
		return error('ResourceAuditor URL is nil')
	}
	return auditor.url
}

fn resource_auditor_curl_runner(program string, arguments []string, environment map[string]string,
	timeout ?f64) !utils.CurlCommandResult {
	_ = timeout
	result := ruby.run_command_with_environment(program, arguments, environment)
	return utils.CurlCommandResult{
		stdout: result.output
		exit_status: result.exit_code
		arguments: arguments.clone()
	}
}

fn resource_auditor_default_curl_fetch(request utils.CurlFetchRequest) !utils.CurlHttpDetails {
	mut runtime := utils.CurlRuntime{
		shim_path: if os.getenv('HOMEBREW_CURL_PATH') != '' {
			os.getenv('HOMEBREW_CURL_PATH')
		} else {
			'curl'
		}
		brewed_path: if os.getenv('HOMEBREW_PREFIX') != '' {
			os.join_path(os.getenv('HOMEBREW_PREFIX'), 'opt/curl/bin/curl')
		} else {
			'curl'
		}
		runner: resource_auditor_curl_runner
	}
	return utils.curl_http_content_headers_and_checksum(mut runtime, request)
}

fn resource_auditor_default_http_checker(url string, specs map[string]string,
	use_homebrew_curl bool) !string {
	_ = specs
	_ = use_homebrew_curl
	return utils.curl_check_http_content(utils.CurlCheckRequest{
		url: url
		url_type: 'source URL'
	}, resource_auditor_default_curl_fetch)
}

fn resource_auditor_default_http_mirror_checker(url string,
	use_homebrew_curl bool) !ResourceAuditorHttpDetails {
	details := resource_auditor_default_curl_fetch(utils.CurlFetchRequest{
		url: url
		hash_needed: true
		use_homebrew_curl: use_homebrew_curl
		specs: {
			'proto_redir': ruby.string_value('=http')
		}
	})!
	return ResourceAuditorHttpDetails{
		status_code: details.status_code
		final_url: details.final_url
		file_hash: details.file_hash
	}
}

fn resource_auditor_default_git_remote_exists(url string) bool {
	git := os.find_abs_path_of_executable('git') or { return true }
	return ruby.run_command(git, ['ls-remote', '--end-of-options', url]).exit_code == 0
}

fn resource_auditor_default_svn_remote_exists(url string) bool {
	svn := os.find_abs_path_of_executable('svn') or { return true }
	return ruby.run_command(svn, ['ls', url, '--depth', 'empty']).exit_code == 0
}

fn resource_auditor_default_branch_detector(url string) ?string {
	git := os.find_abs_path_of_executable('git') or { return none }
	result := ruby.run_command(git, ['ls-remote', '--symref', '--end-of-options', url, 'HEAD'])
	if result.exit_code != 0 {
		return none
	}
	marker := 'ref: refs/heads/'
	start := result.output.index(marker) or { return none }
	rest := result.output[start + marker.len..]
	boundary := rest.index_any(' \t\r\n')
	end := if boundary >= 0 { boundary } else { rest.len }
	return rest[..end]
}

fn resource_auditor_resource_value(resource &ResourceAuditorResource) ruby.Value {
	return ruby.structured_value('Resource', resource.name, {
		'resource_auditor_resource_address': u64(voidptr(resource)).str()
	})
}

pub fn resource_auditor_resource_boundary(resource &ResourceAuditorResource) ruby.Value {
	return resource_auditor_resource_value(resource)
}

fn resource_auditor_resource_from_value(value ruby.Value) ResourceAuditorResource {
	address := value.attributes['resource_auditor_resource_address'] or {
		panic('ResourceAuditor#initialize requires a translated Resource receiver')
	}
	return unsafe { *&ResourceAuditorResource(voidptr(address.u64())) }
}

fn resource_auditor_value(auditor &ResourceAuditor) ruby.Value {
	return ruby.structured_value('Homebrew::ResourceAuditor', '#<Homebrew::ResourceAuditor>', {
		'resource_auditor_address': u64(voidptr(auditor)).str()
	})
}

pub fn resource_auditor_boundary(auditor &ResourceAuditor) ruby.Value {
	return resource_auditor_value(auditor)
}

fn resource_auditor_from_args(args []ruby.Value, method string) &ResourceAuditor {
	if args.len == 0 || args[0].type_name != 'Homebrew::ResourceAuditor' {
		panic('ResourceAuditor#${method} requires a translated receiver')
	}
	address := args[0].attributes['resource_auditor_address'] or {
		panic('ResourceAuditor receiver has no translated state')
	}
	return unsafe { &ResourceAuditor(voidptr(address.u64())) }
}

fn resource_auditor_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Translated from Homebrew/brew `resource_auditor.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :name` at line 13.
pub fn ruby_resource_auditor_l13_d1_name(args ...ruby.Value) ruby.Value {
	auditor := resource_auditor_from_args(args, 'name')
	return if auditor.has_name {
		ruby.string_value(auditor.name)
	} else {
		resource_auditor_nil()
	}
}

// Ruby attr_reader `attr_reader :version` at line 16.
pub fn ruby_resource_auditor_l16_d2_version(args ...ruby.Value) ruby.Value {
	auditor := resource_auditor_from_args(args, 'version')
	return if auditor.has_version {
		ruby.object_value('Version', auditor.version.to_s())
	} else {
		resource_auditor_nil()
	}
}

// Ruby attr_reader `attr_reader :checksum` at line 19.
pub fn ruby_resource_auditor_l19_d3_checksum(args ...ruby.Value) ruby.Value {
	auditor := resource_auditor_from_args(args, 'checksum')
	return if auditor.has_checksum {
		ruby.object_value('Checksum', auditor.checksum.hexdigest)
	} else {
		resource_auditor_nil()
	}
}

// Ruby attr_reader `attr_reader :url` at line 22.
pub fn ruby_resource_auditor_l22_d4_url(args ...ruby.Value) ruby.Value {
	auditor := resource_auditor_from_args(args, 'url')
	return if auditor.has_url {
		ruby.string_value(auditor.url)
	} else {
		resource_auditor_nil()
	}
}

// Ruby attr_reader `attr_reader :mirrors` at line 25.
pub fn ruby_resource_auditor_l25_d5_mirrors(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(resource_auditor_from_args(args, 'mirrors').mirrors)
}

// Ruby attr_reader `attr_reader :using` at line 28.
pub fn ruby_resource_auditor_l28_d6_using(args ...ruby.Value) ruby.Value {
	auditor := resource_auditor_from_args(args, 'using')
	return if auditor.has_using {
		ruby.object_value('Class<AbstractDownloadStrategy>', auditor.using.class_name())
	} else {
		resource_auditor_nil()
	}
}

// Ruby attr_reader `attr_reader :specs` at line 31.
pub fn ruby_resource_auditor_l31_d7_specs(args ...ruby.Value) ruby.Value {
	auditor := resource_auditor_from_args(args, 'specs')
	mut values := map[string]ruby.Value{}
	for key, value in auditor.specs {
		values[key] = ruby.string_value(value)
	}
	return ruby.map_value(values)
}

// Ruby attr_reader `attr_reader :owner` at line 34.
pub fn ruby_resource_auditor_l34_d8_owner(args ...ruby.Value) ruby.Value {
	auditor := resource_auditor_from_args(args, 'owner')
	return if auditor.has_owner {
		ruby.structured_value(if auditor.owner.kind == .formula {
			'Formula'
		} else {
			'Cask::Cask'
		}, auditor.owner.name, {
			'name': auditor.owner.name
		})
	} else {
		resource_auditor_nil()
	}
}

// Ruby attr_reader `attr_reader :spec_name` at line 37.
pub fn ruby_resource_auditor_l37_d9_spec_name(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', resource_auditor_from_args(args, 'spec_name').spec_name)
}

// Ruby attr_reader `attr_reader :problems` at line 40.
pub fn ruby_resource_auditor_l40_d10_problems(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(resource_auditor_from_args(args, 'problems').problems)
}

// Ruby method `initialize(resource, spec_name, online: nil, strict: nil, only: nil, except: nil, core_tap: nil,` at line 54.
pub fn ruby_resource_auditor_l54_d11_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ResourceAuditor#initialize requires a resource and spec name')
	}
	resource := resource_auditor_resource_from_value(args[0])
	config := ResourceAuditorConfig{
		online: args.len > 2 && args[2].bool_data
		strict: args.len > 3 && args[3].bool_data
		only: if args.len > 4 && args[4].type_name != 'NilClass' {
			args[4].as_string_array() or { panic(err) }
		} else {
			[]string{}
		}
		only_set: args.len > 4 && args[4].type_name != 'NilClass'
		except: if args.len > 5 && args[5].type_name != 'NilClass' {
			args[5].as_string_array() or { panic(err) }
		} else {
			[]string{}
		}
		core_tap: args.len > 6 && args[6].bool_data
		use_homebrew_curl: args.len > 7 && args[7].bool_data
		curl_recursive_dependencies: if args.len > 8 {
			args[8].as_string_array() or { panic(err) }
		} else {
			[]string{}
		}
		curl_formula_available: true
	}
	return resource_auditor_value(new_resource_auditor(resource, args[1].as_string(), config))
}

// Ruby method `audit` at line 75.
pub fn ruby_resource_auditor_l75_d12_audit(args ...ruby.Value) ruby.Value {
	mut auditor := resource_auditor_from_args(args, 'audit')
	auditor.audit() or { panic(err) }
	return resource_auditor_value(auditor)
}

// Ruby method `audit_version` at line 91.
pub fn ruby_resource_auditor_l91_d13_audit_version(args ...ruby.Value) ruby.Value {
	mut auditor := resource_auditor_from_args(args, 'audit_version')
	auditor.audit_version() or { panic(err) }
	return resource_auditor_nil()
}

// Ruby method `audit_download_strategy` at line 109.
pub fn ruby_resource_auditor_l109_d14_audit_download_strategy(args ...ruby.Value) ruby.Value {
	mut auditor := resource_auditor_from_args(args, 'audit_download_strategy')
	auditor.audit_download_strategy() or { panic(err) }
	return resource_auditor_nil()
}

// Ruby method `audit_checksum` at line 140.
pub fn ruby_resource_auditor_l140_d15_audit_checksum(args ...ruby.Value) ruby.Value {
	mut auditor := resource_auditor_from_args(args, 'audit_checksum')
	auditor.audit_checksum()
	return resource_auditor_nil()
}

// Ruby method `self.curl_deps` at line 151.
pub fn ruby_resource_auditor_l151_d16_self_curl_deps(args ...ruby.Value) ruby.Value {
	recursive := if args.len > 0 { args[0].as_string_array() or { panic(err) } } else { []string{} }
	available := args.len < 2 || args[1].bool_data
	return ruby.string_array_value(resource_auditor_curl_dependencies(recursive, available))
}

// Ruby method `audit_resource_name_matches_pypi_package_name_in_url` at line 160.
pub fn ruby_resource_auditor_l160_d17_audit_resource_name_matches_pypi_package_name_in_url(args ...ruby.Value) ruby.Value {
	mut auditor := resource_auditor_from_args(args, 'audit_resource_name_matches_pypi_package_name_in_url')
	auditor.audit_resource_name_matches_pypi_package_name_in_url() or { panic(err) }
	return resource_auditor_nil()
}

// Ruby method `audit_urls` at line 183.
pub fn ruby_resource_auditor_l183_d18_audit_urls(args ...ruby.Value) ruby.Value {
	mut auditor := resource_auditor_from_args(args, 'audit_urls')
	auditor.audit_urls() or { panic(err) }
	return resource_auditor_nil()
}

// Ruby method `audit_curl_dep_http_mirror` at line 238.
pub fn ruby_resource_auditor_l238_d19_audit_curl_dep_http_mirror(args ...ruby.Value) ruby.Value {
	mut auditor := resource_auditor_from_args(args, 'audit_curl_dep_http_mirror')
	auditor.audit_curl_dep_http_mirror() or { panic(err) }
	return resource_auditor_nil()
}

// Ruby method `audit_head_branch` at line 274.
pub fn ruby_resource_auditor_l274_d20_audit_head_branch(args ...ruby.Value) ruby.Value {
	mut auditor := resource_auditor_from_args(args, 'audit_head_branch')
	auditor.audit_head_branch() or { panic(err) }
	return resource_auditor_nil()
}

// Ruby method `problem(text)` at line 299.
pub fn ruby_resource_auditor_l299_d21_problem(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ResourceAuditor#problem requires text')
	}
	mut auditor := resource_auditor_from_args(args, 'problem')
	auditor.problem(args[1].as_string())
	return resource_auditor_nil()
}

// Ruby method `curl_dep?` at line 306.
pub fn ruby_resource_auditor_l306_d22_curl_dep(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(resource_auditor_from_args(args, 'curl_dep?').is_curl_dependency() or { panic(err) })
}

// Ruby method `owner!` at line 311.
pub fn ruby_resource_auditor_l311_d23_owner(args ...ruby.Value) ruby.Value {
	owner := resource_auditor_from_args(args, 'owner!').owner_required() or { panic(err) }
	return ruby.structured_value(if owner.kind == .formula {
		'Formula'
	} else {
		'Cask::Cask'
	}, owner.name, {
		'name': owner.name
	})
}

// Ruby method `url!` at line 316.
pub fn ruby_resource_auditor_l316_d24_url(args ...ruby.Value) ruby.Value {
	return ruby.string_value(resource_auditor_from_args(args, 'url!').url_required() or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5: require "utils/svn"
// 6:
// 7: module Homebrew
// 8:   # Auditor for checking common violations in {Resource}s.
// 9:   class ResourceAuditor
// 10:     include Utils::Curl
// 11:
// 12:     sig { returns(T.nilable(String)) }
// 13:     attr_reader :name
// 14:
// 15:     sig { returns(T.nilable(Version)) }
// 16:     attr_reader :version
// 17:
// 18:     sig { returns(T.nilable(Checksum)) }
// 19:     attr_reader :checksum
// 20:
// 21:     sig { returns(T.nilable(String)) }
// 22:     attr_reader :url
// 23:
// 24:     sig { returns(T::Array[String]) }
// 25:     attr_reader :mirrors
// 26:
// 27:     sig { returns(T.nilable(T.any(T::Class[AbstractDownloadStrategy], Symbol))) }
// 28:     attr_reader :using
// 29:
// 30:     sig { returns(T::Hash[Symbol, T.untyped]) }
// 31:     attr_reader :specs
// 32:
// 33:     sig { returns(T.nilable(Resource::Owner)) }
// 34:     attr_reader :owner
// 35:
// 36:     sig { returns(Symbol) }
// 37:     attr_reader :spec_name
// 38:
// 39:     sig { returns(T::Array[String]) }
// 40:     attr_reader :problems
// 41:
// 42:     sig {
// 43:       params(
// 44:         resource:          T.any(Resource, SoftwareSpec),
// 45:         spec_name:         Symbol,
// 46:         online:            T.nilable(T::Boolean),
// 47:         strict:            T.nilable(T::Boolean),
// 48:         only:              T.nilable(T::Array[String]),
// 49:         except:            T.nilable(T::Array[String]),
// 50:         core_tap:          T.nilable(T::Boolean),
// 51:         use_homebrew_curl: T::Boolean,
// 52:       ).void
// 53:     }
// 54:     def initialize(resource, spec_name, online: nil, strict: nil, only: nil, except: nil, core_tap: nil,
// 55:                    use_homebrew_curl: false)
// 56:       @name     = T.let(resource.name, T.nilable(String))
// 57:       @version  = T.let(resource.version, T.nilable(Version))
// 58:       @checksum = T.let(resource.checksum, T.nilable(Checksum))
// 59:       @url      = T.let(resource.url&.to_s, T.nilable(String))
// 60:       @mirrors  = T.let(resource.mirrors, T::Array[String])
// 61:       @using    = T.let(resource.using, T.nilable(T.any(T::Class[AbstractDownloadStrategy], Symbol)))
// 62:       @specs    = T.let(resource.specs, T::Hash[Symbol, T.untyped])
// 63:       @owner    = T.let(resource.owner, T.nilable(T.any(Cask::Cask, Resource::Owner)))
// 64:       @spec_name = spec_name
// 65:       @online    = online
// 66:       @strict    = strict
// 67:       @only      = only
// 68:       @except    = except
// 69:       @core_tap  = core_tap
// 70:       @use_homebrew_curl = use_homebrew_curl
// 71:       @problems = T.let([], T::Array[String])
// 72:     end
// 73:
// 74:     sig { returns(ResourceAuditor) }
// 75:     def audit
// 76:       only_audits = @only
// 77:       except_audits = @except
// 78:
// 79:       methods.map(&:to_s).grep(/^audit_/).each do |audit_method_name|
// 80:         name = audit_method_name.delete_prefix("audit_")
// 81:         next if only_audits&.exclude?(name)
// 82:         next if except_audits&.include?(name)
// 83:
// 84:         send(audit_method_name)
// 85:       end
// 86:
// 87:       self
// 88:     end
// 89:
// 90:     sig { void }
// 91:     def audit_version
// 92:       if (version_text = version).nil?
// 93:         problem "Missing version"
// 94:       elsif (formula_owner = owner).is_a?(::Formula) &&
// 95:             !version_text.to_s.match?(GitHubPackages::VALID_OCI_TAG_REGEX) &&
// 96:             (formula_owner.core_formula? ||
// 97:             (formula_owner.bottle_defined? &&
// 98:               GitHubPackages::URL_REGEX.match?(formula_owner.bottle_specification.root_url)))
// 99:         problem "`version #{version}` does not match #{GitHubPackages::VALID_OCI_TAG_REGEX.source}"
// 100:       elsif !version_text.detected_from_url?
// 101:         version_url = Version.detect(url!, **specs)
// 102:         if version_url.to_s == version_text.to_s && version.instance_of?(Version)
// 103:           problem "`version #{version_text}` is redundant with version scanned from URL"
// 104:         end
// 105:       end
// 106:     end
// 107:
// 108:     sig { void }
// 109:     def audit_download_strategy
// 110:       url_strategy = DownloadStrategyDetector.detect(url!)
// 111:
// 112:       if (using == :git || url_strategy == GitDownloadStrategy) && specs[:tag] && !specs[:revision]
// 113:         problem "Git should specify `revision:` when a `tag:` is specified."
// 114:       end
// 115:
// 116:       return unless using
// 117:
// 118:       if using == :cvs
// 119:         mod = specs[:module]
// 120:
// 121:         problem "Redundant `module:` value in URL" if mod == name
// 122:
// 123:         if url!.match?(%r{:[^/]+$})
// 124:           mod = url!.split(":").last
// 125:
// 126:           if mod == name
// 127:             problem "Redundant CVS module appended to URL"
// 128:           else
// 129:             problem "Specify CVS module as `module: \"#{mod}\"` instead of appending it to the URL"
// 130:           end
// 131:         end
// 132:       end
// 133:
// 134:       return if url_strategy != DownloadStrategyDetector.detect("", using)
// 135:
// 136:       problem "Redundant `using:` value in URL"
// 137:     end
// 138:
// 139:     sig { void }
// 140:     def audit_checksum
// 141:       return if spec_name == :head
// 142:       # This condition is non-invertible.
// 143:       # rubocop:disable Style/InvertibleUnlessCondition
// 144:       return unless DownloadStrategyDetector.detect(url.to_s, using) <= CurlDownloadStrategy
// 145:       # rubocop:enable Style/InvertibleUnlessCondition
// 146:
// 147:       problem "Checksum is missing" if checksum.blank?
// 148:     end
// 149:
// 150:     sig { returns(T::Array[String]) }
// 151:     def self.curl_deps
// 152:       @curl_deps ||= T.let(begin
// 153:         ["curl"] + ::Formula["curl"].recursive_dependencies.map(&:name).uniq
// 154:       rescue FormulaUnavailableError
// 155:         []
// 156:       end, T.nilable(T::Array[String]))
// 157:     end
// 158:
// 159:     sig { void }
// 160:     def audit_resource_name_matches_pypi_package_name_in_url
// 161:       return unless url!.match?(%r{^https?://files\.pythonhosted\.org/packages/})
// 162:       # Skip the top-level package name as we only care about `resource "foo"` blocks.
// 163:       return if name == owner!.name
// 164:
// 165:       if url!.end_with? ".whl"
// 166:         path = URI(url!).path
// 167:         return unless path.present?
// 168:
// 169:         pypi_package_name, = File.basename(path).split("-", 2)
// 170:       else
// 171:         url =~ %r{/(?<package_name>[^/]+)-}
// 172:         pypi_package_name = Regexp.last_match(:package_name).to_s
// 173:       end
// 174:
// 175:       T.must(pypi_package_name).gsub!(/[_.]/, "-")
// 176:
// 177:       return if name.to_s.casecmp(pypi_package_name.to_s)&.zero?
// 178:
// 179:       problem "`resource` name should be '#{pypi_package_name}' to match the PyPI package name"
// 180:     end
// 181:
// 182:     sig { void }
// 183:     def audit_urls
// 184:       urls = [url.to_s] + mirrors
// 185:
// 186:       curl_dep = curl_dep?
// 187:       # Ideally `ca-certificates` would not be excluded here, but sourcing a HTTP mirror was tricky.
// 188:       # Instead, we have logic elsewhere to pass `--insecure` to curl when downloading the certs.
// 189:       # TODO: try remove the OS/env conditional
// 190:       if Homebrew::SimulateSystem.simulating_or_running_on_macos? && spec_name == :stable &&
// 191:          owner!.name != "ca-certificates" && curl_dep && !urls.find { |u| u.start_with?("http://") }
// 192:         problem "Should always include at least one HTTP mirror"
// 193:       end
// 194:
// 195:       return unless @online
// 196:
// 197:       urls.each do |url|
// 198:         next if !@strict && mirrors.include?(url)
// 199:
// 200:         strategy = DownloadStrategyDetector.detect(url, using)
// 201:         if strategy <= CurlDownloadStrategy && !url.start_with?("file")
// 202:
// 203:           raise HomebrewCurlDownloadStrategyError, url if
// 204:             strategy <= HomebrewCurlDownloadStrategy && !Utils::Path.formula_any_version_installed?("curl")
// 205:
// 206:           # Skip ftp.gnu.org audit, upstream has asked us to reduce load.
// 207:           # See issue: https://github.com/Homebrew/brew/issues/20456
// 208:           next if url.match?(%r{^https?://ftp\.gnu\.org/.+})
// 209:
// 210:           # Skip https audit for curl dependencies
// 211:           if !curl_dep && (http_content_problem = curl_check_http_content(
// 212:             url,
// 213:             "source URL",
// 214:             specs:,
// 215:             use_homebrew_curl: @use_homebrew_curl,
// 216:           ))
// 217:             problem http_content_problem
// 218:           end
// 219:         elsif strategy <= GitDownloadStrategy
// 220:           attempts = 0
// 221:           remote_exists = T.let(false, T::Boolean)
// 222:           while !remote_exists && attempts < Homebrew::EnvConfig.curl_retries.to_i
// 223:             remote_exists = Utils::Git.remote_exists?(url)
// 224:             attempts += 1
// 225:           end
// 226:           problem "The URL #{url} is not a valid Git URL" unless remote_exists
// 227:         elsif strategy <= SubversionDownloadStrategy
// 228:           next unless Utils::Svn.available?
// 229:
// 230:           problem "The URL #{url} is not a valid SVN URL" unless Utils::Svn.remote_exists? url
// 231:         end
// 232:       end
// 233:     end
// 234:
// 235:     # `curl` dependencies must be fetchable before `ca-certificates`, so at least
// 236:     # one mirror must serve the expected file over plain HTTP.
// 237:     sig { void }
// 238:     def audit_curl_dep_http_mirror
// 239:       return unless @online
// 240:       return if spec_name != :stable
// 241:       # Only audit the formula's own source, not its `resource` blocks.
// 242:       return if name != owner!.name
// 243:       return unless curl_dep?
// 244:
// 245:       checksum = self.checksum
// 246:       return if checksum.nil?
// 247:
// 248:       http_mirrors = mirrors.select { |mirror| mirror.start_with?("http://") }
// 249:       return if http_mirrors.empty?
// 250:
// 251:       working_mirror = http_mirrors.find do |mirror|
// 252:         details = curl_http_content_headers_and_checksum(
// 253:           mirror,
// 254:           hash_needed:       true,
// 255:           use_homebrew_curl: @use_homebrew_curl,
// 256:           # Fail rather than follow an HTTPS redirect, so a successful request
// 257:           # with a matching checksum proves the bytes came over plain HTTP.
// 258:           specs:             { proto_redir: "=http" },
// 259:         )
// 260:
// 261:         # Reject an explicit HTTPS `final_url` as defence-in-depth; a relative or
// 262:         # HTTP `Location` from an HTTP-to-HTTP redirect is fine.
// 263:         http_status_ok?(details[:status_code]) &&
// 264:           !details[:final_url].to_s.start_with?("https://") &&
// 265:           details[:file_hash] == checksum.hexdigest
// 266:       end
// 267:       return if working_mirror
// 268:
// 269:       problem "`curl` dependencies must have a working HTTP mirror that serves " \
// 270:               "the expected checksum over plain HTTP."
// 271:     end
// 272:
// 273:     sig { void }
// 274:     def audit_head_branch
// 275:       return unless @online
// 276:       return if spec_name != :head
// 277:       return if specs[:tag].present?
// 278:       return if specs[:revision].present?
// 279:       # Skip `resource` URLs as they use SHAs instead of branch specifiers.
// 280:       return if name != owner!.name
// 281:       return unless url.to_s.end_with?(".git")
// 282:       return unless Utils::Git.remote_exists?(url.to_s)
// 283:
// 284:       detected_branch = Utils.popen_read("git", "ls-remote", "--symref", "--end-of-options", url.to_s, "HEAD")
// 285:                              .match(%r{ref: refs/heads/(.*?)\s+HEAD})&.to_a&.second
// 286:
// 287:       if specs[:branch].blank?
// 288:         problem "Git `head` URL must specify a branch name"
// 289:         return
// 290:       end
// 291:
// 292:       return unless @core_tap
// 293:       return if specs[:branch] == detected_branch
// 294:
// 295:       problem "To use a non-default HEAD branch, add the formula to `head_non_default_branch_allowlist.json`."
// 296:     end
// 297:
// 298:     sig { params(text: String).void }
// 299:     def problem(text)
// 300:       @problems << text
// 301:     end
// 302:
// 303:     private
// 304:
// 305:     sig { returns(T::Boolean) }
// 306:     def curl_dep?
// 307:       self.class.curl_deps.include?(owner!.name)
// 308:     end
// 309:
// 310:     sig { returns(Resource::Owner) }
// 311:     def owner!
// 312:       owner || raise("ResourceAuditor owner is nil")
// 313:     end
// 314:
// 315:     sig { returns(String) }
// 316:     def url!
// 317:       url || raise("ResourceAuditor URL is nil")
// 318:     end
// 319:   end
// 320: end
