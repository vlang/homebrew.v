module cmd

import ruby

// Translated from Homebrew/brew `cmd/fetch.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `run` at line 79.
pub fn ruby_fetch_l79_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Fetch command input is required')
	}
	input := fetch_command_input_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return fetch_result_value(run_fetch_command(input.request))
}

// Ruby method `cask_downloads(cask)` at line 176.
pub fn ruby_fetch_l176_d2_cask_downloads(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Fetch cask input is required')
	}
	input := fetch_cask_downloads_input_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	result := fetch_cask_downloads(input.cask, input.options)
	return ruby.Value{
		type_name: 'Array'
		repr: result.downloads.map(it.url).str()
		array_data: result.downloads.map(fetch_download_value(it))
		attributes: {
			'warnings': result.warnings.join('\x1f')
			'error':    result.error
		}
	}
}

// Ruby method `enqueue_api_formula_bottles?` at line 239.
pub fn ruby_fetch_l239_d3_enqueue_api_formula_bottles(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	input := fetch_command_input_from_value(args[0]) or { return ruby.bool_value(false) }
	result := fetch_enqueue_api_formula_bottles(input.request)
	return ruby.Value{
		type_name: 'Bool'
		repr: result.handled.str()
		bool_data: result.handled
		array_data: result.downloads.map(fetch_download_value(it))
		attributes: {
			'names':  result.names.join('\x1f')
			'stdout': result.stdout
			'events': result.events.join('\x1f')
		}
	}
}

// Ruby method `enqueue_api_cask_downloads?` at line 282.
pub fn ruby_fetch_l282_d4_enqueue_api_cask_downloads(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	input := fetch_command_input_from_value(args[0]) or { return ruby.bool_value(false) }
	result := fetch_enqueue_api_cask_downloads(input.request)
	return ruby.Value{
		type_name: 'Bool'
		repr: result.handled.str()
		bool_data: result.handled
		array_data: result.downloads.map(fetch_download_value(it))
		attributes: {
			'names':  result.names.join('\x1f')
			'stdout': result.stdout
			'events': result.events.join('\x1f')
		}
	}
}

// Ruby method `api_fetchable?` at line 316.
pub fn ruby_fetch_l316_d5_api_fetchable(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	input := fetch_command_input_from_value(args[0]) or { return ruby.bool_value(false) }
	return ruby.bool_value(fetch_api_fetchable(input.request.options))
}

// Ruby method `api_fetch_names(regex:, capture:, named:, aliases:, renames:)` at line 333.
pub fn ruby_fetch_l333_d6_api_fetch_names(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	input := fetch_api_names_input_from_value(args[0]) or {
		return ruby.object_value('NilClass', 'nil')
	}
	names := fetch_api_fetch_names(*input) or { return ruby.object_value('NilClass', 'nil') }
	return ruby.string_array_value(names)
}

// Ruby method `retries` at line 352.
pub fn ruby_fetch_l352_d7_retries(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.int_value(1)
	}
	mut state := fetch_command_state_from_value(args[0]) or { return ruby.int_value(1) }
	return ruby.int_value(fetch_retries(mut state))
}

// Ruby method `download_queue` at line 357.
pub fn ruby_fetch_l357_d8_download_queue(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Fetch command state is required')
	}
	mut state := fetch_command_state_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	queue := fetch_download_queue(mut state)
	return ruby.structured_value('Homebrew::DownloadQueue', '', {
		'retries': queue.retries.str()
		'force':   queue.force.str()
		'address': u64(voidptr(queue)).str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "fetch"
// 7: require "api/cask_download"
// 8: require "api/formula_bottle"
// 9: require "cask/config"
// 10: require "cask/download"
// 11: require "download_queue"
// 12:
// 13: module Homebrew
// 14:   module Cmd
// 15:     class FetchCmd < AbstractCommand
// 16:       include Fetch
// 17:
// 18:       FETCH_MAX_TRIES = 5
// 19:
// 20:       cmd_args do
// 21:         description <<~EOS
// 22:           Download a bottle (if available) or source packages for <formula>e
// 23:           and binaries for <cask>s. For files, also print SHA-256 checksums.
// 24:         EOS
// 25:         flag   "--os=",
// 26:                description: "Download for the given operating system. " \
// 27:                             "(Pass `all` to download for all operating systems.)"
// 28:         flag   "--arch=",
// 29:                description: "Download for the given CPU architecture. " \
// 30:                             "(Pass `all` to download for all architectures.)"
// 31:         switch "--all-platforms",
// 32:                description: "Download for every supported operating system and architecture, plus each " \
// 33:                             "language for <cask>s, fetching each distinct URL once."
// 34:         flag   "--bottle-tag=",
// 35:                description: "Download a bottle for given tag."
// 36:         switch "--HEAD",
// 37:                description: "Fetch HEAD version instead of stable version."
// 38:         switch "-f", "--force",
// 39:                description: "Remove a previously cached version and re-fetch."
// 40:         switch "-v", "--verbose",
// 41:                description: "Do a verbose VCS checkout, if the URL represents a VCS. This is useful for " \
// 42:                             "seeing if an existing VCS cache has been updated."
// 43:         switch "--retry",
// 44:                description: "Retry if downloading fails or re-download if the checksum of a previously cached " \
// 45:                             "version no longer matches. Tries at most #{FETCH_MAX_TRIES} times with " \
// 46:                             "exponential backoff."
// 47:         switch "--deps",
// 48:                description: "Also download dependencies for any listed <formula>."
// 49:         switch "-s", "--build-from-source",
// 50:                description: "Download source packages rather than a bottle."
// 51:         switch "--build-bottle",
// 52:                description: "Download source packages (for eventual bottling) rather than a bottle."
// 53:         switch "--force-bottle",
// 54:                description: "Download a bottle if it exists for the current or newest version of macOS, " \
// 55:                             "even if it would not be used during installation."
// 56:         switch "--formula", "--formulae",
// 57:                description: "Treat all named arguments as formulae."
// 58:         switch "--cask", "--casks",
// 59:                description: "Treat all named arguments as casks."
// 60:
// 61:         conflicts "--build-from-source", "--build-bottle", "--force-bottle", "--bottle-tag"
// 62:         conflicts "--cask", "--HEAD"
// 63:         conflicts "--cask", "--deps"
// 64:         conflicts "--cask", "-s"
// 65:         conflicts "--cask", "--build-bottle"
// 66:         conflicts "--cask", "--force-bottle"
// 67:         conflicts "--cask", "--bottle-tag"
// 68:         conflicts "--formula", "--cask"
// 69:         conflicts "--os", "--bottle-tag"
// 70:         conflicts "--arch", "--bottle-tag"
// 71:         conflicts "--all-platforms", "--os"
// 72:         conflicts "--all-platforms", "--arch"
// 73:         conflicts "--all-platforms", "--bottle-tag"
// 74:
// 75:         named_args [:formula, :cask], min: 1
// 76:       end
// 77:
// 78:       sig { override.void }
// 79:       def run
// 80:         Formulary.enable_factory_cache!
// 81:
// 82:         if enqueue_api_formula_bottles? || enqueue_api_cask_downloads?
// 83:           download_queue.fetch
// 84:           return
// 85:         end
// 86:
// 87:         bucket = if args.deps?
// 88:           args.named.to_formulae_and_casks.flat_map do |formula_or_cask|
// 89:             case formula_or_cask
// 90:             when Formula
// 91:               formula = formula_or_cask
// 92:               [formula, *formula.recursive_dependencies.map(&:to_formula)]
// 93:             else
// 94:               formula_or_cask
// 95:             end
// 96:           end
// 97:         else
// 98:           args.named.to_formulae_and_casks
// 99:         end.uniq
// 100:
// 101:         os_arch_combinations = args.os_arch_combinations
// 102:
// 103:         puts "Fetching: #{bucket * ", "}" if bucket.size > 1
// 104:         bucket.each do |formula_or_cask|
// 105:           case formula_or_cask
// 106:           when Formula
// 107:             formula = formula_or_cask
// 108:             ref = formula.reloadable_ref
// 109:
// 110:             os_arch_combinations.each do |os, arch|
// 111:               SimulateSystem.with(os:, arch:) do
// 112:                 formula = Formulary.factory(ref, args.HEAD? ? :head : :stable)
// 113:
// 114:                 formula.print_tap_action verb: "Fetching"
// 115:
// 116:                 fetched_bottle = false
// 117:                 if fetch_bottle?(
// 118:                   formula,
// 119:                   force_bottle:               args.force_bottle?,
// 120:                   bottle_tag:                 args.bottle_tag&.to_sym,
// 121:                   build_from_source_formulae: args.build_from_source_formulae,
// 122:                   os:                         args.os&.to_sym,
// 123:                   arch:                       args.arch&.to_sym,
// 124:                 )
// 125:                   begin
// 126:                     formula.clear_cache if args.force?
// 127:
// 128:                     bottle_tag = Utils::Bottles::Tag.from_arg(args.bottle_tag&.to_sym, os:, arch:)
// 129:
// 130:                     bottle = formula.bottle_for_tag(bottle_tag)
// 131:
// 132:                     if bottle.nil?
// 133:                       opoo "Bottle for tag #{bottle_tag.to_sym.inspect} is unavailable."
// 134:                       next
// 135:                     end
// 136:
// 137:                     if (manifest_resource = bottle.github_packages_manifest_resource)
// 138:                       download_queue.enqueue(manifest_resource)
// 139:                     end
// 140:                     download_queue.enqueue(bottle)
// 141:                   rescue Interrupt
// 142:                     raise
// 143:                   rescue => e
// 144:                     raise if Homebrew::EnvConfig.developer?
// 145:
// 146:                     fetched_bottle = false
// 147:                     onoe e.message
// 148:                     opoo "Bottle fetch failed, fetching the source instead."
// 149:                   else
// 150:                     fetched_bottle = true
// 151:                   end
// 152:                 end
// 153:
// 154:                 next if fetched_bottle
// 155:
// 156:                 if (resource = formula.resource)
// 157:                   download_queue.enqueue(resource)
// 158:                 end
// 159:
// 160:                 formula.enqueue_resources_and_patches(download_queue:)
// 161:               end
// 162:             end
// 163:           when Cask::Cask
// 164:             cask_downloads(formula_or_cask).each { |download| download_queue.enqueue(download) }
// 165:           else
// 166:             odie "Invalid formula or cask: #{formula_or_cask}"
// 167:           end
// 168:         end
// 169:
// 170:         download_queue.fetch
// 171:       ensure
// 172:         download_queue.shutdown
// 173:       end
// 174:
// 175:       sig { params(cask: Cask::Cask).returns(T::Array[Cask::Download]) }
// 176:       def cask_downloads(cask)
// 177:         ref = cask.reloadable_ref
// 178:
// 179:         if args.all_platforms? && cask.loaded_from_api?
// 180:           opoo "Cask #{cask} was loaded from the API; cannot fetch all operating system and " \
// 181:                "architecture variants. Set `HOMEBREW_NO_INSTALL_FROM_API=1` to fetch them all."
// 182:         end
// 183:
// 184:         # With `--all-platforms`, a cask without `on_system` blocks resolves
// 185:         # identically everywhere, so one combination covers the whole matrix.
// 186:         cask_combinations = args.os_arch_combinations
// 187:         cask_combinations = cask_combinations.first(1) if args.all_platforms? && !cask.on_system_blocks_exist?
// 188:
// 189:         downloads = T.let([], T::Array[Cask::Download])
// 190:         enqueued_urls = Set.new
// 191:
// 192:         cask_combinations.each do |os, arch|
// 193:           SimulateSystem.with(os:, arch:) do
// 194:             loaded_cask = begin
// 195:               Cask::CaskLoader.load(ref)
// 196:             rescue Cask::CaskInvalidError, Cask::CaskUnreadableError
// 197:               raise unless cask.on_system_blocks_exist?
// 198:             end
// 199:             if loaded_cask.nil? || loaded_cask.depends_on.arch&.none? { |dep_arch| dep_arch[:type] == arch }
// 200:               opoo "Cask #{cask} is not supported on os #{os} and arch #{arch}"
// 201:               next
// 202:             end
// 203:
// 204:             languages = (loaded_cask.languages if args.all_platforms?)
// 205:             languages = [nil] if languages.blank?
// 206:
// 207:             languages.each do |language|
// 208:               localized_cask = loaded_cask
// 209:               if language
// 210:                 # Reload per language: `Cask::Download` reads `sha256`/`url`
// 211:                 # lazily, so each download needs its own cask instance.
// 212:                 localized_cask = Cask::CaskLoader.load(ref)
// 213:                 localized_cask.config = localized_cask.config.merge(
// 214:                   Cask::Config.new(explicit: { languages: [language] }),
// 215:                 )
// 216:               end
// 217:
// 218:               if localized_cask.url.nil? || localized_cask.sha256.nil?
// 219:                 opoo "Cask #{cask} is not supported on os #{os} and arch #{arch}"
// 220:                 next
// 221:               end
// 222:
// 223:               next unless enqueued_urls.add?(localized_cask.url.to_s)
// 224:
// 225:               downloads << Cask::Download.new(
// 226:                 localized_cask,
// 227:                 require_sha: Homebrew::EnvConfig.cask_opts_require_sha?,
// 228:               )
// 229:             end
// 230:           end
// 231:         end
// 232:
// 233:         downloads
// 234:       end
// 235:
// 236:       private
// 237:
// 238:       sig { returns(T::Boolean) }
// 239:       def enqueue_api_formula_bottles?
// 240:         return false unless api_fetchable?
// 241:         return false if args.only_formula_or_cask == :cask
// 242:         return false if args.deps? || args.HEAD?
// 243:         return false if args.build_from_source? || args.build_bottle?
// 244:         return false if args.bottle_tag.present?
// 245:
// 246:         names = api_fetch_names(
// 247:           regex:   HOMEBREW_DEFAULT_TAP_FORMULA_REGEX,
// 248:           capture: :name,
// 249:           named:   ->(name) { Homebrew::API::Internal.formula_name?(name) },
// 250:           aliases: Homebrew::API::Internal.formula_aliases,
// 251:           renames: Homebrew::API::Internal.formula_renames,
// 252:         )
// 253:         return false if names.nil?
// 254:
// 255:         bottles = T.let([], T::Array[[String, Bottle]])
// 256:         bottle_tag = Utils::Bottles.tag
// 257:         names.each do |name|
// 258:           formula_struct = Homebrew::API::Internal.formula_struct(name)
// 259:           return false if formula_struct.pour_bottle?
// 260:
// 261:           bottle = Homebrew::API::FormulaBottle.bottle(name:, formula_struct:, bottle_tag:)
// 262:           return false if bottle.nil?
// 263:           return false if !args.force_bottle? && !bottle.compatible_locations?
// 264:
// 265:           bottles << [name, bottle]
// 266:         end
// 267:
// 268:         puts "Fetching: #{names * ", "}" if names.size > 1
// 269:         bottles.each do |name, bottle|
// 270:           ohai "Fetching #{name} from #{CoreTap.instance}"
// 271:           bottle.clear_cache if args.force?
// 272:
// 273:           if (manifest_resource = bottle.github_packages_manifest_resource)
// 274:             download_queue.enqueue(manifest_resource)
// 275:           end
// 276:           download_queue.enqueue(bottle)
// 277:         end
// 278:         true
// 279:       end
// 280:
// 281:       sig { returns(T::Boolean) }
// 282:       def enqueue_api_cask_downloads?
// 283:         return false unless api_fetchable?
// 284:         return false if args.only_formula_or_cask != :cask
// 285:
// 286:         tokens = api_fetch_names(
// 287:           regex:   HOMEBREW_DEFAULT_TAP_CASK_REGEX,
// 288:           capture: :token,
// 289:           named:   ->(token) { Homebrew::API::Internal.cask_name?(token) },
// 290:           aliases: {},
// 291:           renames: Homebrew::API::Internal.cask_renames,
// 292:         )
// 293:         return false if tokens.nil?
// 294:
// 295:         downloads = T.let([], T::Array[[String, Cask::Download]])
// 296:         tokens.each do |token|
// 297:           download = Homebrew::API::CaskDownload.download(
// 298:             token:,
// 299:             cask_struct: Homebrew::API::Internal.cask_struct(token),
// 300:             require_sha: Homebrew::EnvConfig.cask_opts_require_sha?,
// 301:           )
// 302:           return false if download.nil?
// 303:
// 304:           downloads << [token, download]
// 305:         end
// 306:
// 307:         puts "Fetching: #{tokens * ", "}" if tokens.size > 1
// 308:         downloads.each do |token, download|
// 309:           ohai "Fetching #{token} from #{CoreCaskTap.instance}"
// 310:           download_queue.enqueue(download)
// 311:         end
// 312:         true
// 313:       end
// 314:
// 315:       sig { returns(T::Boolean) }
// 316:       def api_fetchable?
// 317:         return false if Homebrew::EnvConfig.no_install_from_api?
// 318:         return false if args.all_platforms? || args.os.present? || args.arch.present?
// 319:         return false if ENV["HOMEBREW_TEST_GENERIC_OS"].present?
// 320:
// 321:         true
// 322:       end
// 323:
// 324:       sig {
// 325:         params(
// 326:           regex:   Regexp,
// 327:           capture: Symbol,
// 328:           named:   T.proc.params(name: String).returns(T::Boolean),
// 329:           aliases: T::Hash[String, String],
// 330:           renames: T::Hash[String, String],
// 331:         ).returns(T.nilable(T::Array[String]))
// 332:       }
// 333:       def api_fetch_names(regex:, capture:, named:, aliases:, renames:)
// 334:         requested_names = args.named.downcased_unique_named
// 335:         names = T.let(requested_names.filter_map do |requested_name|
// 336:           name = requested_name[regex, capture]
// 337:           next if name.blank?
// 338:
// 339:           name = name.downcase
// 340:           name = aliases.fetch(name, name)
// 341:           name = renames.fetch(name, name)
// 342:           next unless named.call(name)
// 343:
// 344:           name
// 345:         end, T::Array[String])
// 346:         return if names.length != requested_names.length
// 347:
// 348:         names
// 349:       end
// 350:
// 351:       sig { returns(Integer) }
// 352:       def retries
// 353:         @retries ||= T.let(args.retry? ? FETCH_MAX_TRIES : 1, T.nilable(Integer))
// 354:       end
// 355:
// 356:       sig { returns(DownloadQueue) }
// 357:       def download_queue
// 358:         @download_queue ||= T.let(begin
// 359:           DownloadQueue.new(retries:, force: args.force?)
// 360:         end, T.nilable(DownloadQueue))
// 361:       end
// 362:     end
// 363:   end
// 364: end
