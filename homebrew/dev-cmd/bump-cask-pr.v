module dev_cmd

import ruby
import homebrew
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `dev-cmd/bump-cask-pr.rb`.
pub struct BumpCaskPrCask {
pub:
	token                     string
	contents                  string
	version                   string
	sourcefile_path           string
	tap_present               bool
	tap_name                  string
	tap_remote_repository     string
	tap_official              bool
	tap_git                   bool = true
	allow_bump                bool = true
	too_many_open_prs         bool
	on_system_blocks_exist    bool
	depends_on_arch           []string
	supports_macos            bool = true
	supports_linux            bool
	languages                 []string
	throttle_rate             ?int
	throttle_days             ?int
	last_updated_timestamp    ?i64
	throttle_interval_elapsed ?bool
}

pub struct BumpCaskSystemOption {
pub:
	os   string
	arch string
}

pub struct BumpCaskCheckResult {
pub:
	allowed bool
	error   string
	output  []string
}

pub struct BumpCaskCommandOptions {
pub:
	dry_run   bool
	disabled  bool
	succeeded bool = true
}

pub struct BumpCaskCommandResult {
pub:
	output   []string
	reverted bool
	error    string
}

pub struct BumpCaskPullRequestCheck {
pub:
	version      string
	remote       string
	file         string
	quiet        bool
	official_tap bool
}

pub struct BumpCaskPrRunRequest {
pub:
	cask            BumpCaskPrCask
	new_version     homebrew.BumpVersionParser
	new_hash        ?string
	new_url         ?string
	current_os      string = 'linux'
	newest_macos    string = 'tahoe'
	dry_run         bool
	write_only      bool
	commit          bool
	no_audit        bool
	no_style        bool
	no_fork         bool
	no_browse       bool
	message         string
	audit_succeeded bool = true
	style_succeeded bool = true
	pr_url          string
	now             i64
}

pub struct BumpCaskPrRunResult {
pub:
	contents       string
	branch_name    string
	commit_message string
	audit          BumpCaskCommandResult
	style          BumpCaskCommandResult
	pull_request   string
	browser_url    string
	printed_url    string
	error          string
}

fn bump_cask_version(parser homebrew.BumpVersionParser, arch string) ?homebrew.BumpVersion {
	if arch == 'arm' {
		if value := parser.arm {
			return value
		}
	} else if arch == 'intel' {
		if value := parser.intel {
			return value
		}
	}
	return parser.general
}

fn bump_cask_first_version(parser homebrew.BumpVersionParser) ?homebrew.BumpVersion {
	if value := parser.arm {
		return value
	}
	if value := parser.intel {
		return value
	}
	return parser.general
}

fn bump_cask_compare_versions(left string, right string) int {
	left_parts := left.split(',')
	right_parts := right.split(',')
	count := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. count {
		left_version := homebrew.new_version(if index < left_parts.len {
			left_parts[index]
		} else {
			'0'
		}) or {
			continue
		}
		right_version := homebrew.new_version(if index < right_parts.len {
			right_parts[index]
		} else {
			'0'
		}) or {
			continue
		}
		comparison := left_version.compare_to(right_version)
		if comparison != 0 {
			return comparison
		}
	}
	return 0
}

pub fn bump_cask_generate_system_options(cask BumpCaskPrCask,
	new_version homebrew.BumpVersionParser, current_os string,
	newest_macos string) []BumpCaskSystemOption {
	current_os_is_macos := current_os in homebrew.macos_symbol_versions()
	macos := if current_os_is_macos { current_os } else { newest_macos }
	mut arches := []string{}
	if new_version.arm != none {
		arches << 'arm'
	}
	if new_version.intel != none {
		arches << 'intel'
	}
	mut systems := []string{}
	if cask.on_system_blocks_exist {
		systems = [macos, 'linux']
		if arches.len == 0 {
			arches = homebrew.on_system_arch_options.clone()
		}
	} else {
		systems = [macos]
		if arches.len == 0 {
			arches = if cask.depends_on_arch.len > 0 {
				cask.depends_on_arch.clone()
			} else {
				['arm']
			}
		}
	}
	if arches.len > 1 && new_version.general == none {
		left := bump_cask_version(new_version, arches[0]) or { homebrew.new_cask_bump_version('0') }
		right := bump_cask_version(new_version, arches[1]) or { homebrew.new_cask_bump_version('0') }
		if bump_cask_compare_versions(left.value, right.value) < 0 {
			first := arches[0]
			arches[0] = arches[1]
			arches[1] = first
		}
	}
	mut result := []BumpCaskSystemOption{}
	for os_name in systems {
		for arch in arches {
			result << BumpCaskSystemOption{
				os: os_name
				arch: arch
			}
		}
	}
	return result
}

fn bump_cask_symbol(value string) ruby.Value {
	return ruby.Value{
		type_name: 'Symbol'
		repr: ':${value.trim_left(':')}'
	}
}

fn bump_cask_stanza_value(value string) ruby.Value {
	return if value in ['latest', 'no_check', ':latest', ':no_check'] {
		bump_cask_symbol(value)
	} else {
		ruby.string_value(value)
	}
}

fn bump_cask_stanza_value_present(ast utils.CaskAst, name string, value ruby.Value,
	within ?string) bool {
	for node in utils.ast_cask_stanzas(ast, name, within) {
		if node.arguments.any(it.value.type_name == value.type_name && it.value.repr == value.repr) {
			return true
		}
		if node.hash_pairs.any(it.value.type_name == value.type_name && it.value.repr == value.repr) {
			return true
		}
	}
	return false
}

pub fn bump_cask_replace_stanza_value(contents string, name string, old_value string,
	new_value string, within ?string) !string {
	if old_value == new_value {
		return contents
	}
	mut ast := utils.CaskAst{
		contents: contents
	}
	old_literal := bump_cask_stanza_value(old_value)
	new_literal := bump_cask_stanza_value(new_value)
	count := utils.ast_cask_replace_value(mut ast, name, old_literal, new_literal, within)
	if count == 0 {
		if bump_cask_stanza_value_present(ast, name, new_literal, within) {
			return contents
		}
		return error("Could not find '${name}' stanza with value ${old_value}!")
	}
	return ast.contents
}

pub fn bump_cask_arch_specific_version_bump(new_version homebrew.BumpVersionParser) bool {
	return new_version.arm != none || new_version.intel != none
}

pub fn bump_cask_default_os(current_os string, newest_macos string) string {
	return if current_os in homebrew.macos_symbol_versions() { current_os } else { newest_macos }
}

pub fn bump_cask_unsupported_nested_arch_stanza(contents string, name string,
	arch string) bool {
	ast := utils.CaskAst{
		contents: contents
	}
	scope := 'on_${arch}'
	return utils.ast_cask_stanza_anywhere(ast, name, scope) && utils.ast_cask_stanzas(ast, name, scope).len == 0
}

pub fn bump_cask_stanza_scope(contents string, name string, arch string) ?string {
	ast := utils.CaskAst{
		contents: contents
	}
	scope := 'on_${arch}'
	return if utils.ast_cask_stanzas(ast, name, scope).len > 0 { scope } else { none }
}

pub fn bump_cask_split_root_version_and_checksum(new_version homebrew.BumpVersionParser,
	contents string) string {
	if !bump_cask_arch_specific_version_bump(new_version) {
		return contents
	}
	mut ast := utils.CaskAst{
		contents: contents
	}
	root_version := utils.ast_cask_first_value(ast, 'version', 'root')
	if root_version.type_name != 'NilClass' && utils.ast_cask_stanzas(ast, 'version', 'on_arm').len == 0 && utils.ast_cask_stanzas(ast, 'version', 'on_intel').len == 0 {
		utils.ast_cask_replace_root_with_arch(mut ast, 'version', root_version)
	}
	root_checksum := utils.ast_cask_first_value(ast, 'sha256', 'root')
	if root_checksum.type_name == 'String' && utils.ast_cask_stanzas(ast, 'sha256', 'on_arm').len == 0 && utils.ast_cask_stanzas(ast, 'sha256', 'on_intel').len == 0 {
		utils.ast_cask_replace_root_with_arch(mut ast, 'sha256', root_checksum)
	}
	return ast.contents
}

fn bump_cask_first_stanza_value(contents string, name string, scope ?string) ?ruby.Value {
	ast := utils.CaskAst{
		contents: contents
	}
	value := utils.ast_cask_first_value(ast, name, scope)
	return if value.type_name == 'NilClass' { none } else { value }
}

fn bump_cask_checksum_value(contents string, os_name string, arch string) ?ruby.Value {
	ast := utils.CaskAst{
		contents: contents
	}
	if scope := bump_cask_stanza_scope(contents, 'sha256', arch) {
		value := utils.ast_cask_first_value(ast, 'sha256', scope)
		if value.type_name != 'NilClass' {
			return value
		}
	}
	for node in utils.ast_cask_top_level_stanzas(ast, 'sha256') {
		if node.arguments.len > 0 {
			return node.arguments[0].value
		}
		key := if os_name == 'linux' {
			if arch == 'arm' { 'arm64_linux' } else { 'x86_64_linux' }
		} else {
			arch
		}
		for pair in node.hash_pairs {
			if pair.key == key {
				return pair.value
			}
		}
	}
	return none
}

fn bump_cask_value_text(value ruby.Value) string {
	return if value.type_name == 'Symbol' { value.repr.trim_left(':') } else { value.as_string() }
}

pub fn bump_cask_parse(contents string) BumpCaskPrCask {
	mut token := ''
	for line in contents.split('\n') {
		trimmed := line.trim_space()
		if trimmed.starts_with('cask ') {
			token = trimmed.all_after('cask ').trim_space().trim('"\'')
			break
		}
	}
	version_value := bump_cask_first_stanza_value(contents, 'version', none) or {
		ruby.string_value('')
	}
	mut arches := []string{}
	if contents.contains('depends_on arch: :x86_64') {
		arches << 'intel'
	}
	if contents.contains('depends_on arch: :arm64') {
		arches << 'arm'
	}
	on_system := contents.contains('\n  os ') || contents.contains('\n  on_macos do') || contents.contains('\n  on_linux do') || contents.contains('\n  on_arm do') || contents.contains('\n  on_intel do')
	return BumpCaskPrCask{
		token: token
		contents: contents
		version: bump_cask_value_text(version_value)
		sourcefile_path: '${token}.rb'
		on_system_blocks_exist: on_system
		depends_on_arch: arches
		supports_macos: !contents.contains('depends_on :linux')
		supports_linux: contents.contains('linux')
	}
}

pub fn bump_cask_replace_version_and_checksum(cask BumpCaskPrCask, new_hash ?string,
	new_version homebrew.BumpVersionParser, original_contents string, current_os string,
	newest_macos string) !string {
	if cask.sourcefile_path == '' {
		return error('unexpected nil cask.sourcefile_path')
	}
	mut contents := bump_cask_split_root_version_and_checksum(new_version, original_contents)
	for system in bump_cask_generate_system_options(cask, new_version, current_os, newest_macos) {
		if system.os == 'linux' && !cask.supports_linux {
			continue
		}
		if system.os != 'linux' && !cask.supports_macos {
			continue
		}
		if cask.depends_on_arch.len > 0 && system.arch !in cask.depends_on_arch && !cask.on_system_blocks_exist {
			continue
		}
		if bump_cask_unsupported_nested_arch_stanza(contents, 'version', system.arch) || bump_cask_unsupported_nested_arch_stanza(contents, 'sha256', system.arch) {
			continue
		}
		bump_version := bump_cask_version(new_version, system.arch) or { continue }
		version_scope := bump_cask_stanza_scope(contents, 'version', system.arch)
		old_version_value := bump_cask_first_stanza_value(contents, 'version', version_scope) or {
			continue
		}
		old_version := bump_cask_value_text(old_version_value)
		contents = bump_cask_replace_stanza_value(contents, 'version', old_version, bump_version.value, version_scope)!
		old_hash_value := bump_cask_checksum_value(contents, system.os, system.arch) or {
			return error('${cask.token}: No checksum is defined for :${system.os}_${system.arch}. Add `depends_on arch:` or an operating system `depends_on` to declare unsupported platforms.')
		}
		old_hash := bump_cask_value_text(old_hash_value)
		if supplied := new_hash {
			if supplied != 'no_check' && old_hash == supplied {
				continue
			}
		}
		checksum_scope := bump_cask_stanza_scope(contents, 'sha256', system.arch)
		if bump_version.latest || (new_hash or { '' }) == 'no_check' {
			if old_hash != 'no_check' {
				contents = bump_cask_replace_stanza_value(contents, 'sha256', old_hash, 'no_check', checksum_scope)!
			}
		} else if old_hash == 'no_check' {
			if supplied := new_hash {
				if !bump_cask_arch_specific_version_bump(new_version) || checksum_scope != none {
					contents = bump_cask_replace_stanza_value(contents, 'sha256', 'no_check', supplied, checksum_scope)!
				}
			}
		} else if supplied := new_hash {
			if cask.languages.len == 0 && (!cask.on_system_blocks_exist || checksum_scope != none || bump_cask_arch_specific_version_bump(new_version)) {
				contents = bump_cask_replace_stanza_value(contents, 'sha256', old_hash, supplied, checksum_scope)!
			}
		}
	}
	return contents
}

pub fn bump_cask_shortened_version(version string, cask_version string) string {
	return if version.all_before(',') == cask_version.all_before(',') {
		version
	} else {
		version.all_before(',')
	}
}

pub fn bump_cask_check_throttle(cask BumpCaskPrCask,
	new_version homebrew.BumpVersionParser, now i64) BumpCaskCheckResult {
	if !cask.tap_present || (cask.throttle_rate == none && cask.throttle_days == none) {
		return BumpCaskCheckResult{
			allowed: true
		}
	}
	version := bump_cask_first_version(new_version) or {
		return BumpCaskCheckResult{
			allowed: true
		}
	}
	mut package := livecheck.LivecheckPackage{
		kind: 'cask'
		name: cask.token
		version: cask.version
		tap_git: true
		last_updated_timestamp: cask.last_updated_timestamp
	}
	if elapsed := cask.throttle_interval_elapsed {
		if elapsed {
			package.last_updated_timestamp = now - i64(2 * 24 * 60 * 60)
		} else {
			package.last_updated_timestamp = now
		}
	}
	if livecheck.livecheck_throttle_allows_bump(package, version.value, cask.throttle_rate, cask.throttle_days, now) {
		return BumpCaskCheckResult{
			allowed: true
		}
	}
	mut items := []string{}
	if rate := cask.throttle_rate {
		items << '${rate} releases on multiples of ${rate}'
	}
	if days := cask.throttle_days {
		items << '${days} ${if days == 1 { 'day' } else { 'days' }}'
	}
	message := '${cask.token} should only be updated every ${items.join(' or ')}'
	return BumpCaskCheckResult{
		error: message
		output: ['Error: ${message}\n']
	}
}

pub fn bump_cask_check_pull_requests(cask BumpCaskPrCask,
	new_version homebrew.BumpVersionParser, quiet bool) ![]BumpCaskPullRequestCheck {
	if !cask.tap_present {
		return error('unexpected nil cask.tap')
	}
	if cask.tap_remote_repository == '' {
		return error('${cask.tap_name} tap does not have a remote repository!')
	}
	if cask.sourcefile_path == '' {
		return error('unexpected nil cask.sourcefile_path')
	}
	mut checks := [BumpCaskPullRequestCheck{
		remote: cask.tap_remote_repository
		file: cask.sourcefile_path
		quiet: quiet
		official_tap: cask.tap_official
	}]
	for version in [new_version.general, new_version.arm, new_version.intel] {
		if parsed := version {
			checks << BumpCaskPullRequestCheck{
				version: bump_cask_shortened_version(parsed.value, cask.version)
				remote: cask.tap_remote_repository
				file: cask.sourcefile_path
				quiet: quiet
				official_tap: cask.tap_official
			}
		}
	}
	return checks
}

pub fn bump_cask_run_audit(cask BumpCaskPrCask, old_contents string,
	options BumpCaskCommandOptions, exceptions []string) BumpCaskCommandResult {
	if options.dry_run {
		return BumpCaskCommandResult{
			output: [if options.disabled {
				'Skipping `brew audit`'
			} else {
				'brew audit --cask --online ${cask.token}'
			}]
		}
	}
	if options.disabled {
		return BumpCaskCommandResult{
			output: ['Skipping `brew audit`']
		}
	}
	if options.succeeded {
		return BumpCaskCommandResult{
			output: [
				'audit --cask --online ${cask.token} --except=${exceptions.join(',')}',
			]
		}
	}
	return BumpCaskCommandResult{
		output: [
			'audit --cask --online ${cask.token} --except=${exceptions.join(',')}',
		]
		reverted: old_contents != ''
		error: '`brew audit` failed!'
	}
}

pub fn bump_cask_run_style(cask BumpCaskPrCask, old_contents string,
	options BumpCaskCommandOptions) BumpCaskCommandResult {
	if cask.sourcefile_path == '' {
		return BumpCaskCommandResult{
			error: 'unexpected nil cask.sourcefile_path'
		}
	}
	basename := cask.sourcefile_path.all_after_last('/')
	if options.dry_run {
		return BumpCaskCommandResult{
			output: [if options.disabled {
				'Skipping `brew style --fix`'
			} else {
				'brew style --fix ${basename}'
			}]
		}
	}
	if options.disabled {
		return BumpCaskCommandResult{
			output: ['Skipping `brew style --fix`']
		}
	}
	if options.succeeded {
		return BumpCaskCommandResult{
			output: ['style --fix ${cask.sourcefile_path}']
		}
	}
	return BumpCaskCommandResult{
		output: ['style --fix ${cask.sourcefile_path}']
		reverted: old_contents != ''
		error: '`brew style --fix` failed!'
	}
}

pub fn bump_cask_run(request BumpCaskPrRunRequest) BumpCaskPrRunResult {
	mut result := BumpCaskPrRunResult{
		contents: request.cask.contents
		branch_name: 'bump-${request.cask.token}'
	}
	if !request.cask.tap_present {
		return BumpCaskPrRunResult{
			...result
			error: 'This cask is not in a tap!'
		}
	}
	if !request.cask.tap_git {
		return BumpCaskPrRunResult{
			...result
			error: "This cask's tap is not a Git repository!"
		}
	}
	if !request.cask.allow_bump {
		return BumpCaskPrRunResult{
			...result
			error: 'Whoops, the ${request.cask.token} cask has its version update\npull requests automatically opened by BrewTestBot every ~3 hours!'
		}
	}
	if !request.write_only && request.cask.too_many_open_prs {
		return BumpCaskPrRunResult{
			...result
			error: 'You have too many PRs open: close or merge some first!'
		}
	}
	if request.new_version.is_blank() && request.new_url == none && request.new_hash == none {
		return BumpCaskPrRunResult{
			...result
			error: 'No `--version`, `--url` or `--sha256` argument specified!'
		}
	}
	throttle := bump_cask_check_throttle(request.cask, request.new_version, request.now)
	if !throttle.allowed {
		return BumpCaskPrRunResult{
			...result
			error: throttle.error
		}
	}
	if !request.write_only {
		bump_cask_check_pull_requests(request.cask, request.new_version, false) or {
			return BumpCaskPrRunResult{
				...result
				error: err.msg()
			}
		}
	}
	mut contents := request.cask.contents
	mut commit_message := ''
	if url := request.new_url {
		if url.trim_space() == '' || !url.contains('://') {
			return BumpCaskPrRunResult{
				...result
				error: if url.trim_space() == '' {
					'`--url` must not be empty.'
				} else {
					'`--url` is not valid.'
				}
			}
		}
		mut ast := utils.CaskAst{
			contents: contents
		}
		utils.ast_cask_replace_first(mut ast, 'url', ruby.string_value(url))
		contents = ast.contents
		commit_message = '${request.cask.token}: update URL'
	}
	if !request.new_version.is_blank() {
		branch_version := bump_cask_first_version(request.new_version) or {
			return BumpCaskPrRunResult{
				...result
				error: 'Unable to update cask'
			}
		}
		commit_version := bump_cask_shortened_version(branch_version.value, request.cask.version)
		result = BumpCaskPrRunResult{
			...result
			branch_name: 'bump-${request.cask.token}-${branch_version.value.replace(',', '-').replace(':', '-')}'
		}
		if commit_message == '' {
			commit_message = '${request.cask.token} ${commit_version}'
		}
		if request.new_version.arm != none && request.new_version.intel == none {
			result = BumpCaskPrRunResult{
				...result
				branch_name: '${result.branch_name}-arm-only'
			}
			commit_message += ' (arm only)'
		} else if request.new_version.intel != none && request.new_version.arm == none {
			result = BumpCaskPrRunResult{
				...result
				branch_name: '${result.branch_name}-intel-only'
			}
			commit_message += ' (intel only)'
		}
		before_contents := contents
		contents = bump_cask_replace_version_and_checksum(request.cask, request.new_hash, request.new_version, contents, request.current_os, request.newest_macos) or {
			return BumpCaskPrRunResult{
				...result
				error: err.msg()
			}
		}
		if contents == before_contents {
			return BumpCaskPrRunResult{
				...result
				error: 'Unable to update cask'
			}
		}
	}
	if commit_message == '' && request.new_hash != none {
		commit_message = '${request.cask.token}: update checksum'
	}
	if commit_message == '' {
		return BumpCaskPrRunResult{
			...result
			error: 'Expected to have a commit message'
		}
	}
	audit := bump_cask_run_audit(request.cask, request.cask.contents, BumpCaskCommandOptions{
		dry_run: request.dry_run
		disabled: request.no_audit
		succeeded: request.audit_succeeded
	}, [])
	if audit.error != '' {
		return BumpCaskPrRunResult{
			...result
			contents: request.cask.contents
			commit_message: commit_message
			audit: audit
			error: audit.error
		}
	}
	style := bump_cask_run_style(request.cask, request.cask.contents, BumpCaskCommandOptions{
		dry_run: request.dry_run
		disabled: request.no_style
		succeeded: request.style_succeeded
	})
	if style.error != '' {
		return BumpCaskPrRunResult{
			...result
			contents: request.cask.contents
			commit_message: commit_message
			audit: audit
			style: style
			error: style.error
		}
	}
	if request.write_only && !request.commit {
		return BumpCaskPrRunResult{
			...result
			contents: contents
			commit_message: commit_message
			audit: audit
			style: style
		}
	}
	return BumpCaskPrRunResult{
		...result
		contents: contents
		commit_message: commit_message
		audit: audit
		style: style
		pull_request: request.pr_url
		browser_url: if request.pr_url != '' && !request.no_browse { request.pr_url } else { '' }
		printed_url: if request.pr_url != '' && request.no_browse { request.pr_url } else { '' }
	}
}
