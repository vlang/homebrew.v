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

pub type ResourceAuditorHttpChecker = fn (string, map[string]string, bool) !string

pub type ResourceAuditorHttpMirrorChecker = fn (string, bool) !ResourceAuditorHttpDetails

pub type ResourceAuditorRemoteChecker = fn (string) bool

pub type ResourceAuditorBranchDetector = fn (string) ?string

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
