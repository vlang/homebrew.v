module cmd

import ruby

// Translated from Homebrew/brew `cmd/fetch.rb`.

const fetch_max_tries = 5

pub struct FetchSystem {
pub:
	os   string
	arch string
}

pub struct FetchDownload {
pub:
	kind        string
	name        string
	url         string
	os          string
	arch        string
	language    string
	require_sha bool
}

pub struct FetchFormula {
pub:
	name                string
	dependencies        []string
	bottle_requested    bool
	bottle_url          string
	bottle_manifest_url string
	bottle_error        string
	source_url          string
	resource_urls       []string
	patch_urls          []string
}

pub struct FetchCaskVariant {
pub:
	os             string
	arch           string
	language       string
	url            string
	sha256         string
	allowed_arches []string
}

pub struct FetchCask {
pub:
	token                  string
	loaded_from_api        bool
	on_system_blocks_exist bool
	variants               []FetchCaskVariant
}

pub struct FetchPackage {
pub:
	kind    string
	formula FetchFormula
	cask    FetchCask
}

pub struct FetchApiFormula {
pub:
	name                  string
	pour_bottle           bool
	bottle_url            string
	manifest_url          string
	incompatible_location bool
}

pub struct FetchApiCask {
pub:
	token  string
	url    string
	sha256 string
}

pub struct FetchCommandOptions {
pub:
	no_install_from_api  bool
	all_platforms        bool
	os                   string
	arch                 string
	generic_os           string
	only_formula_or_cask string
	deps                 bool
	head                 bool
	build_from_source    bool
	build_bottle         bool
	bottle_tag           string
	force_bottle         bool
	force                bool
	retry                bool
	developer            bool
	require_sha          bool
	named                []string
	os_arch_combinations []FetchSystem
}

pub struct FetchCommandContext {
pub:
	packages        []FetchPackage
	formula_catalog []FetchFormula
	api_formulae    []FetchApiFormula
	api_casks       []FetchApiCask
	formula_aliases map[string]string
	formula_renames map[string]string
	cask_renames    map[string]string
}

pub struct FetchCommandRequest {
pub:
	options FetchCommandOptions
	context FetchCommandContext
}

pub struct FetchCaskDownloadsResult {
pub mut:
	downloads []FetchDownload
	warnings  []string
	error     string
}

pub struct FetchApiEnqueueResult {
pub mut:
	handled   bool
	names     []string
	downloads []FetchDownload
	stdout    string
	events    []string
}

pub struct FetchCommandResult {
pub mut:
	downloads     []FetchDownload
	stdout        string
	stderr        string
	warnings      []string
	events        []string
	used_api      bool
	regular_loads int
	fetches       int
	shutdowns     int
	failed        bool
	error         string
}

@[heap]
pub struct FetchCommandInput {
pub:
	request FetchCommandRequest
}

@[heap]
pub struct FetchCaskDownloadsInput {
pub:
	cask    FetchCask
	options FetchCommandOptions
}

@[heap]
pub struct FetchApiNamesInput {
pub:
	requested_names []string
	capture         string
	valid_names     []string
	aliases         map[string]string
	renames         map[string]string
}

pub struct FetchDownloadQueue {
pub:
	retries int
	force   bool
}

@[heap]
pub struct FetchCommandState {
pub:
	options FetchCommandOptions
pub mut:
	retries_initialized bool
	retries_value       int
	queue_initialized   bool
	queue               FetchDownloadQueue
}

pub fn fetch_command_input_boundary(input &FetchCommandInput) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::FetchCmd::Input', '', {
		'fetch_command_input_address': u64(voidptr(input)).str()
	})
}

pub fn fetch_cask_downloads_input_boundary(input &FetchCaskDownloadsInput) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::FetchCmd::CaskDownloadsInput', '', {
		'fetch_cask_downloads_input_address': u64(voidptr(input)).str()
	})
}

pub fn fetch_api_names_input_boundary(input &FetchApiNamesInput) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::FetchCmd::ApiNamesInput', '', {
		'fetch_api_names_input_address': u64(voidptr(input)).str()
	})
}

pub fn fetch_command_state_boundary(state &FetchCommandState) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::FetchCmd::State', '', {
		'fetch_command_state_address': u64(voidptr(state)).str()
	})
}

fn fetch_command_input_from_value(value ruby.Value) !&FetchCommandInput {
	address := value.attributes['fetch_command_input_address'] or {
		return error('invalid Fetch command input')
	}
	return unsafe { &FetchCommandInput(voidptr(address.u64())) }
}

fn fetch_cask_downloads_input_from_value(value ruby.Value) !&FetchCaskDownloadsInput {
	address := value.attributes['fetch_cask_downloads_input_address'] or {
		return error('invalid Fetch cask downloads input')
	}
	return unsafe { &FetchCaskDownloadsInput(voidptr(address.u64())) }
}

fn fetch_api_names_input_from_value(value ruby.Value) !&FetchApiNamesInput {
	address := value.attributes['fetch_api_names_input_address'] or {
		return error('invalid Fetch API names input')
	}
	return unsafe { &FetchApiNamesInput(voidptr(address.u64())) }
}

fn fetch_command_state_from_value(value ruby.Value) !&FetchCommandState {
	address := value.attributes['fetch_command_state_address'] or {
		return error('invalid Fetch command state')
	}
	return unsafe { &FetchCommandState(voidptr(address.u64())) }
}

fn fetch_unique_lower(values []string) []string {
	mut result := []string{}
	mut seen := map[string]bool{}
	for value in values {
		lower := value.to_lower()
		if lower !in seen {
			seen[lower] = true
			result << lower
		}
	}
	return result
}

fn fetch_valid_tap_name(value string) bool {
	if value == '' {
		return false
	}
	for character in value.bytes() {
		if !((character >= `a` && character <= `z`) || (character >= `0` && character <= `9`)
			|| character in [`_`, `+`, `-`, `.`, `@`]) {
			return false
		}
	}
	return true
}

fn fetch_default_tap_capture(requested string, capture string) ?string {
	parts := requested.split('/')
	mut name := ''
	if parts.len == 1 {
		name = parts[0]
	} else if parts.len == 3 && parts[0] == 'homebrew' {
		repository := if capture == 'token' { 'cask' } else { 'core' }
		if parts[1] != repository && parts[1] != 'homebrew-${repository}' {
			return none
		}
		name = parts[2]
	} else {
		return none
	}
	if !fetch_valid_tap_name(name) {
		return none
	}
	return name
}

pub fn fetch_api_fetch_names(input FetchApiNamesInput) ?[]string {
	requested_names := fetch_unique_lower(input.requested_names)
	mut names := []string{}
	for requested_name in requested_names {
		mut name := fetch_default_tap_capture(requested_name, input.capture) or { continue }
		name = input.aliases[name] or { name }
		name = input.renames[name] or { name }
		if name !in input.valid_names {
			continue
		}
		names << name
	}
	if names.len != requested_names.len {
		return none
	}
	return names
}

pub fn fetch_api_fetchable(options FetchCommandOptions) bool {
	return !options.no_install_from_api && !options.all_platforms && options.os == ''
		&& options.arch == '' && options.generic_os == ''
}

fn fetch_api_formula(context FetchCommandContext, name string) ?FetchApiFormula {
	for formula in context.api_formulae {
		if formula.name == name {
			return formula
		}
	}
	return none
}

fn fetch_api_cask(context FetchCommandContext, token string) ?FetchApiCask {
	for cask in context.api_casks {
		if cask.token == token {
			return cask
		}
	}
	return none
}

pub fn fetch_enqueue_api_formula_bottles(request FetchCommandRequest) FetchApiEnqueueResult {
	options := request.options
	if !fetch_api_fetchable(options) || options.only_formula_or_cask == 'cask' || options.deps
		|| options.head || options.build_from_source || options.build_bottle
		|| options.bottle_tag != '' {
		return FetchApiEnqueueResult{}
	}
	valid_names := request.context.api_formulae.map(it.name)
	names := fetch_api_fetch_names(FetchApiNamesInput{
		requested_names: options.named
		capture: 'name'
		valid_names: valid_names
		aliases: request.context.formula_aliases
		renames: request.context.formula_renames
	}) or { return FetchApiEnqueueResult{} }
	mut downloads := []FetchDownload{}
	for name in names {
		formula := fetch_api_formula(request.context, name) or { return FetchApiEnqueueResult{} }
		if formula.pour_bottle || formula.bottle_url == ''
			|| (!options.force_bottle && formula.incompatible_location) {
			return FetchApiEnqueueResult{}
		}
		if formula.manifest_url != '' {
			downloads << FetchDownload{
				kind: 'bottle_manifest'
				name: name
				url: formula.manifest_url
			}
		}
		downloads << FetchDownload{
			kind: 'bottle'
			name: name
			url: formula.bottle_url
		}
	}
	mut events := []string{}
	mut cleared := map[string]bool{}
	for download in downloads {
		if options.force && download.name !in cleared {
			events << 'clear_cache:${download.name}'
			cleared[download.name] = true
		}
		events << 'enqueue:${download.kind}:${download.url}'
	}
	return FetchApiEnqueueResult{
		handled: true
		names: names
		downloads: downloads
		stdout: if names.len > 1 { 'Fetching: ${names.join(', ')}\n' } else { '' }
		events: events
	}
}

pub fn fetch_enqueue_api_cask_downloads(request FetchCommandRequest) FetchApiEnqueueResult {
	options := request.options
	if !fetch_api_fetchable(options) || options.only_formula_or_cask != 'cask' {
		return FetchApiEnqueueResult{}
	}
	valid_tokens := request.context.api_casks.map(it.token)
	tokens := fetch_api_fetch_names(FetchApiNamesInput{
		requested_names: options.named
		capture: 'token'
		valid_names: valid_tokens
		renames: request.context.cask_renames
	}) or { return FetchApiEnqueueResult{} }
	mut downloads := []FetchDownload{}
	for token in tokens {
		cask := fetch_api_cask(request.context, token) or { return FetchApiEnqueueResult{} }
		if cask.url == '' {
			return FetchApiEnqueueResult{}
		}
		downloads << FetchDownload{
			kind: 'cask'
			name: token
			url: cask.url
			require_sha: options.require_sha
		}
	}
	return FetchApiEnqueueResult{
		handled: true
		names: tokens
		downloads: downloads
		stdout: if tokens.len > 1 { 'Fetching: ${tokens.join(', ')}\n' } else { '' }
		events: downloads.map('enqueue:${it.kind}:${it.url}')
	}
}

fn fetch_variant_languages(variants []FetchCaskVariant, all_platforms bool) []string {
	if !all_platforms {
		return ['']
	}
	mut languages := []string{}
	for variant in variants {
		if variant.language != '' && variant.language !in languages {
			languages << variant.language
		}
	}
	return if languages.len == 0 { [''] } else { languages }
}

fn fetch_variant_for_language(variants []FetchCaskVariant, language string) ?FetchCaskVariant {
	for variant in variants {
		if variant.language == language {
			return variant
		}
	}
	if language == '' && variants.len > 0 {
		return variants[0]
	}
	return none
}

pub fn fetch_cask_downloads(cask FetchCask, options FetchCommandOptions) FetchCaskDownloadsResult {
	mut result := FetchCaskDownloadsResult{}
	if options.all_platforms && cask.loaded_from_api {
		result.warnings << 'Cask ${cask.token} was loaded from the API; cannot fetch all operating system and architecture variants. Set `HOMEBREW_NO_INSTALL_FROM_API=1` to fetch them all.'
	}
	mut combinations := options.os_arch_combinations.clone()
	if options.all_platforms && !cask.on_system_blocks_exist && combinations.len > 1 {
		combinations = combinations[..1].clone()
	}
	mut enqueued_urls := map[string]bool{}
	for combination in combinations {
		mut matching := []FetchCaskVariant{}
		for variant in cask.variants {
			if variant.os == combination.os && variant.arch == combination.arch {
				matching << variant
			}
		}
		if matching.len == 0 {
			if !cask.on_system_blocks_exist {
				result.error = 'Cask ${cask.token} could not be loaded on os ${combination.os} and arch ${combination.arch}'
				return result
			}
			result.warnings << 'Cask ${cask.token} is not supported on os ${combination.os} and arch ${combination.arch}'
			continue
		}
		if matching[0].allowed_arches.len > 0 && combination.arch !in matching[0].allowed_arches {
			result.warnings << 'Cask ${cask.token} is not supported on os ${combination.os} and arch ${combination.arch}'
			continue
		}
		languages := fetch_variant_languages(matching, options.all_platforms)
		for language in languages {
			variant := fetch_variant_for_language(matching, language) or { continue }
			if variant.url == '' || variant.sha256 == '' {
				result.warnings << 'Cask ${cask.token} is not supported on os ${combination.os} and arch ${combination.arch}'
				continue
			}
			if variant.url in enqueued_urls {
				continue
			}
			enqueued_urls[variant.url] = true
			result.downloads << FetchDownload{
				kind: 'cask'
				name: cask.token
				url: variant.url
				os: combination.os
				arch: combination.arch
				language: language
				require_sha: options.require_sha
			}
		}
	}
	return result
}

fn fetch_formula_from_catalog(context FetchCommandContext, name string) ?FetchFormula {
	for formula in context.formula_catalog {
		if formula.name == name {
			return formula
		}
	}
	return none
}

fn fetch_bucket(request FetchCommandRequest) []FetchPackage {
	mut bucket := []FetchPackage{}
	for package in request.context.packages {
		bucket << package
		if request.options.deps && package.kind == 'formula' {
			for dependency in package.formula.dependencies {
				formula := fetch_formula_from_catalog(request.context, dependency) or { continue }
				bucket << FetchPackage{
					kind: 'formula'
					formula: formula
				}
			}
		}
	}
	mut unique := []FetchPackage{}
	mut seen := map[string]bool{}
	for package in bucket {
		name := if package.kind == 'formula' { package.formula.name } else { package.cask.token }
		key := '${package.kind}:${name}'
		if key !in seen {
			seen[key] = true
			unique << package
		}
	}
	return unique
}

fn fetch_append_download(mut result FetchCommandResult, download FetchDownload) {
	result.downloads << download
	result.events << 'enqueue:${download.kind}:${download.url}'
}

fn fetch_finish(mut result FetchCommandResult) FetchCommandResult {
	result.events << 'shutdown'
	result.shutdowns++
	return result
}

pub fn run_fetch_command(request FetchCommandRequest) FetchCommandResult {
	mut result := FetchCommandResult{}
	formula_api := fetch_enqueue_api_formula_bottles(request)
	if formula_api.handled {
		result.used_api = true
		result.stdout += formula_api.stdout
		result.downloads = formula_api.downloads.clone()
		result.events << formula_api.events
		result.events << 'fetch'
		result.fetches++
		return fetch_finish(mut result)
	}
	cask_api := fetch_enqueue_api_cask_downloads(request)
	if cask_api.handled {
		result.used_api = true
		result.stdout += cask_api.stdout
		result.downloads = cask_api.downloads.clone()
		result.events << cask_api.events
		result.events << 'fetch'
		result.fetches++
		return fetch_finish(mut result)
	}
	bucket := fetch_bucket(request)
	if bucket.len > 1 {
		names := bucket.map(if it.kind == 'formula' { it.formula.name } else { it.cask.token })
		result.stdout += 'Fetching: ${names.join(', ')}\n'
	}
	for package in bucket {
		if package.kind == 'formula' {
			formula := package.formula
			for system in request.options.os_arch_combinations {
				result.regular_loads++
				result.events << 'fetching:${formula.name}:${system.os}:${system.arch}'
				if formula.bottle_requested {
					if request.options.force {
						result.events << 'clear_cache:${formula.name}'
					}
					if formula.bottle_error != '' {
						if request.options.developer {
							result.failed = true
							result.error = formula.bottle_error
							return fetch_finish(mut result)
						}
						result.stderr += '${formula.bottle_error}\n'
						result.warnings << 'Bottle fetch failed, fetching the source instead.'
					} else if formula.bottle_url == '' {
						result.warnings << 'Bottle for tag ${system.arch}_${system.os} is unavailable.'
						continue
					} else {
						if formula.bottle_manifest_url != '' {
							fetch_append_download(mut result, FetchDownload{
								kind: 'bottle_manifest'
								name: formula.name
								url: formula.bottle_manifest_url
								os: system.os
								arch: system.arch
							})
						}
						fetch_append_download(mut result, FetchDownload{
							kind: 'bottle'
							name: formula.name
							url: formula.bottle_url
							os: system.os
							arch: system.arch
						})
						continue
					}
				}
				if formula.source_url != '' {
					fetch_append_download(mut result, FetchDownload{
						kind: 'source'
						name: formula.name
						url: formula.source_url
						os: system.os
						arch: system.arch
					})
				}
				for resource_url in formula.resource_urls {
					fetch_append_download(mut result, FetchDownload{
						kind: 'resource'
						name: formula.name
						url: resource_url
						os: system.os
						arch: system.arch
					})
				}
				for patch_url in formula.patch_urls {
					fetch_append_download(mut result, FetchDownload{
						kind: 'patch'
						name: formula.name
						url: patch_url
						os: system.os
						arch: system.arch
					})
				}
			}
		} else if package.kind == 'cask' {
			result.regular_loads++
			cask_result := fetch_cask_downloads(package.cask, request.options)
			result.warnings << cask_result.warnings
			if cask_result.error != '' {
				result.failed = true
				result.error = cask_result.error
				return fetch_finish(mut result)
			}
			for download in cask_result.downloads {
				fetch_append_download(mut result, download)
			}
		} else {
			result.failed = true
			result.error = 'Invalid formula or cask'
			return fetch_finish(mut result)
		}
	}
	result.events << 'fetch'
	result.fetches++
	return fetch_finish(mut result)
}

pub fn fetch_retries(mut state FetchCommandState) int {
	if !state.retries_initialized {
		state.retries_value = if state.options.retry { fetch_max_tries } else { 1 }
		state.retries_initialized = true
	}
	return state.retries_value
}

pub fn fetch_download_queue(mut state FetchCommandState) &FetchDownloadQueue {
	if !state.queue_initialized {
		state.queue = FetchDownloadQueue{
			retries: fetch_retries(mut state)
			force: state.options.force
		}
		state.queue_initialized = true
	}
	return &state.queue
}

fn fetch_download_value(download FetchDownload) ruby.Value {
	return ruby.structured_value('FetchDownload', download.url, {
		'kind':        download.kind
		'name':        download.name
		'url':         download.url
		'os':          download.os
		'arch':        download.arch
		'language':    download.language
		'require_sha': download.require_sha.str()
	})
}

fn fetch_result_value(result FetchCommandResult) ruby.Value {
	return ruby.Value{
		type_name: 'FetchCommandResult'
		repr: result.stdout
		map_data: {
			'downloads':     ruby.array_value(result.downloads.map(fetch_download_value(it)))
			'stdout':        ruby.string_value(result.stdout)
			'stderr':        ruby.string_value(result.stderr)
			'warnings':      ruby.string_array_value(result.warnings)
			'events':        ruby.string_array_value(result.events)
			'used_api':      ruby.bool_value(result.used_api)
			'regular_loads': ruby.int_value(result.regular_loads)
			'fetches':       ruby.int_value(result.fetches)
			'shutdowns':     ruby.int_value(result.shutdowns)
			'failed':        ruby.bool_value(result.failed)
			'error':         ruby.string_value(result.error)
		}
	}
}
