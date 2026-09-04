module dev_cmd

import ruby
import homebrew
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `dev-cmd/bump-cask-pr.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn bump_cask_bool(value ruby.Value, fallback bool) bool {
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn bump_cask_optional_string(values map[string]ruby.Value, key string) ?string {
	value := values[key] or { return none }
	if value.type_name in ['Nil', 'NilClass'] {
		return none
	}
	return value.as_string()
}

fn bump_cask_optional_int(values map[string]ruby.Value, key string) ?int {
	value := values[key] or { return none }
	if value.type_name in ['Nil', 'NilClass'] {
		return none
	}
	return int(value.int_data)
}

fn bump_cask_optional_i64(values map[string]ruby.Value, key string) ?i64 {
	value := values[key] or { return none }
	if value.type_name in ['Nil', 'NilClass'] {
		return none
	}
	return value.int_data
}

fn bump_cask_optional_bool(values map[string]ruby.Value, key string) ?bool {
	value := values[key] or { return none }
	if value.type_name in ['Nil', 'NilClass'] {
		return none
	}
	return bump_cask_bool(value, false)
}

pub fn bump_cask_pr_cask_value(cask BumpCaskPrCask) ruby.Value {
	mut values := {
		'token':                  ruby.string_value(cask.token)
		'contents':               ruby.string_value(cask.contents)
		'version':                ruby.string_value(cask.version)
		'sourcefile_path':        ruby.string_value(cask.sourcefile_path)
		'tap_present':            ruby.bool_value(cask.tap_present)
		'tap_name':               ruby.string_value(cask.tap_name)
		'tap_remote_repository':  ruby.string_value(cask.tap_remote_repository)
		'tap_official':           ruby.bool_value(cask.tap_official)
		'tap_git':                ruby.bool_value(cask.tap_git)
		'allow_bump':             ruby.bool_value(cask.allow_bump)
		'too_many_open_prs':      ruby.bool_value(cask.too_many_open_prs)
		'on_system_blocks_exist': ruby.bool_value(cask.on_system_blocks_exist)
		'depends_on_arch':        ruby.string_array_value(cask.depends_on_arch)
		'supports_macos':         ruby.bool_value(cask.supports_macos)
		'supports_linux':         ruby.bool_value(cask.supports_linux)
		'languages':              ruby.string_array_value(cask.languages)
	}
	if value := cask.throttle_rate {
		values['throttle_rate'] = ruby.int_value(value)
	}
	if value := cask.throttle_days {
		values['throttle_days'] = ruby.int_value(value)
	}
	if value := cask.last_updated_timestamp {
		values['last_updated_timestamp'] = ruby.int_value(value)
	}
	if value := cask.throttle_interval_elapsed {
		values['throttle_interval_elapsed'] = ruby.bool_value(value)
	}
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: cask.token
		map_data: values.clone()
	}
}

pub fn bump_cask_pr_cask_from_value(value ruby.Value) !BumpCaskPrCask {
	if value.type_name !in ['Cask::Cask', 'BumpCaskPrCask', 'Hash'] {
		return error('expected Cask::Cask, got ${value.type_name}')
	}
	values := value.map_data.clone()
	contents := (values['contents'] or { ruby.string_value('') }).as_string()
	parsed := bump_cask_parse(contents)
	return BumpCaskPrCask{
		token: (values['token'] or { ruby.string_value(parsed.token) }).as_string()
		contents: contents
		version: (values['version'] or { ruby.string_value(parsed.version) }).as_string()
		sourcefile_path: (values['sourcefile_path'] or { ruby.string_value(parsed.sourcefile_path) }).as_string()
		tap_present: bump_cask_bool(values['tap_present'] or { ruby.bool_value(false) }, false)
		tap_name: (values['tap_name'] or { ruby.string_value('') }).as_string()
		tap_remote_repository: (values['tap_remote_repository'] or { ruby.string_value('') }).as_string()
		tap_official: bump_cask_bool(values['tap_official'] or { ruby.bool_value(false) }, false)
		tap_git: bump_cask_bool(values['tap_git'] or { ruby.bool_value(true) }, true)
		allow_bump: bump_cask_bool(values['allow_bump'] or { ruby.bool_value(true) }, true)
		too_many_open_prs: bump_cask_bool(values['too_many_open_prs'] or { ruby.bool_value(false) }, false)
		on_system_blocks_exist: bump_cask_bool(values['on_system_blocks_exist'] or { ruby.bool_value(parsed.on_system_blocks_exist) }, parsed.on_system_blocks_exist)
		depends_on_arch: (values['depends_on_arch'] or { ruby.string_array_value(parsed.depends_on_arch) }).as_string_array() or { parsed.depends_on_arch }
		supports_macos: bump_cask_bool(values['supports_macos'] or { ruby.bool_value(parsed.supports_macos) }, parsed.supports_macos)
		supports_linux: bump_cask_bool(values['supports_linux'] or { ruby.bool_value(parsed.supports_linux) }, parsed.supports_linux)
		languages: (values['languages'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		throttle_rate: bump_cask_optional_int(values, 'throttle_rate')
		throttle_days: bump_cask_optional_int(values, 'throttle_days')
		last_updated_timestamp: bump_cask_optional_i64(values, 'last_updated_timestamp')
		throttle_interval_elapsed: bump_cask_optional_bool(values, 'throttle_interval_elapsed')
	}
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
				'Skipping `brew audit`'} else {
				'brew audit --cask --online ${cask.token}'}]
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
				'Skipping `brew style --fix`'} else {
				'brew style --fix ${basename}'}]
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

fn bump_cask_system_options_value(options []BumpCaskSystemOption) ruby.Value {
	return ruby.array_value(options.map(ruby.array_value([
		bump_cask_symbol(it.os),
		bump_cask_symbol(it.arch),
	])))
}

fn bump_cask_check_result_value(result BumpCaskCheckResult) ruby.Value {
	return ruby.map_value({
		'allowed': ruby.bool_value(result.allowed)
		'error':   ruby.string_value(result.error)
		'output':  ruby.string_array_value(result.output)
	})
}

fn bump_cask_command_options_from_value(value ruby.Value) BumpCaskCommandOptions {
	values := value.map_data.clone()
	return BumpCaskCommandOptions{
		dry_run: bump_cask_bool(values['dry_run'] or { ruby.bool_value(false) }, false)
		disabled: bump_cask_bool(values['disabled'] or { ruby.bool_value(false) }, false)
		succeeded: bump_cask_bool(values['succeeded'] or { ruby.bool_value(true) }, true)
	}
}

fn bump_cask_command_result_value(result BumpCaskCommandResult) ruby.Value {
	return ruby.map_value({
		'output':   ruby.string_array_value(result.output)
		'reverted': ruby.bool_value(result.reverted)
		'error':    ruby.string_value(result.error)
	})
}

fn bump_cask_pull_request_checks_value(checks []BumpCaskPullRequestCheck) ruby.Value {
	return ruby.array_value(checks.map(ruby.map_value({
		'version':      ruby.string_value(it.version)
		'remote':       ruby.string_value(it.remote)
		'file':         ruby.string_value(it.file)
		'quiet':        ruby.bool_value(it.quiet)
		'official_tap': ruby.bool_value(it.official_tap)
	})))
}

fn bump_cask_run_result_value(result BumpCaskPrRunResult) ruby.Value {
	return ruby.map_value({
		'contents':       ruby.string_value(result.contents)
		'branch_name':    ruby.string_value(result.branch_name)
		'commit_message': ruby.string_value(result.commit_message)
		'audit':          bump_cask_command_result_value(result.audit)
		'style':          bump_cask_command_result_value(result.style)
		'pull_request':   ruby.string_value(result.pull_request)
		'browser_url':    ruby.string_value(result.browser_url)
		'printed_url':    ruby.string_value(result.printed_url)
		'error':          ruby.string_value(result.error)
	})
}

fn bump_cask_run_request_from_args(args []ruby.Value) !BumpCaskPrRunRequest {
	if args.len == 0 {
		return error('run request is required')
	}
	values := if args[0].type_name == 'Hash' {
		args[0].map_data.clone()
	} else {
		map[string]ruby.Value{}
	}
	cask_value := if args[0].type_name == 'Hash' {
		values['cask'] or { return error('run request cask is required') }
	} else {
		args[0]
	}
	parser_value := if args[0].type_name == 'Hash' {
		values['new_version'] or { homebrew.bump_version_parser_value(homebrew.BumpVersionParser{}) }
	} else if args.len > 1 {
		args[1]
	} else {
		homebrew.bump_version_parser_value(homebrew.BumpVersionParser{})
	}
	cask := bump_cask_pr_cask_from_value(cask_value)!
	parser := homebrew.bump_version_parser_from_value(parser_value)!
	return BumpCaskPrRunRequest{
		cask: cask
		new_version: parser
		new_hash: bump_cask_optional_string(values, 'new_hash')
		new_url: bump_cask_optional_string(values, 'new_url')
		current_os: (values['current_os'] or { ruby.string_value('linux') }).as_string().trim_left(':')
		newest_macos: (values['newest_macos'] or { ruby.string_value('tahoe') }).as_string().trim_left(':')
		dry_run: bump_cask_bool(values['dry_run'] or { ruby.bool_value(false) }, false)
		write_only: bump_cask_bool(values['write_only'] or { ruby.bool_value(false) }, false)
		commit: bump_cask_bool(values['commit'] or { ruby.bool_value(false) }, false)
		no_audit: bump_cask_bool(values['no_audit'] or { ruby.bool_value(false) }, false)
		no_style: bump_cask_bool(values['no_style'] or { ruby.bool_value(false) }, false)
		no_fork: bump_cask_bool(values['no_fork'] or { ruby.bool_value(false) }, false)
		no_browse: bump_cask_bool(values['no_browse'] or { ruby.bool_value(false) }, false)
		message: (values['message'] or { ruby.string_value('') }).as_string()
		audit_succeeded: bump_cask_bool(values['audit_succeeded'] or { ruby.bool_value(true) }, true)
		style_succeeded: bump_cask_bool(values['style_succeeded'] or { ruby.bool_value(true) }, true)
		pr_url: (values['pr_url'] or { ruby.string_value('') }).as_string()
		now: (values['now'] or { ruby.int_value(0) }).int_data
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

// Ruby method `run` at line 62.
pub fn ruby_bump_cask_pr_l62_d1_run(args ...ruby.Value) ruby.Value {
	request := bump_cask_run_request_from_args(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return bump_cask_run_result_value(bump_cask_run(request))
}

// Ruby method `generate_system_options(cask, new_version)` at line 220.
pub fn ruby_bump_cask_pr_l220_d2_generate_system_options(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'cask and new version are required')
	}
	cask := bump_cask_pr_cask_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	parser := homebrew.bump_version_parser_from_value(args[1]) or { return ruby.object_value('ArgumentError', err.msg()) }
	current_os := if args.len > 2 { args[2].as_string().trim_left(':') } else { 'linux' }
	newest_macos := if args.len > 3 { args[3].as_string().trim_left(':') } else { 'tahoe' }
	return bump_cask_system_options_value(bump_cask_generate_system_options(cask, parser, current_os, newest_macos))
}

// Ruby method `replace_version_and_checksum(cask, new_hash, new_version, contents)` at line 284.
pub fn ruby_bump_cask_pr_l284_d3_replace_version_and_checksum(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		return ruby.object_value('ArgumentError', 'cask, hash, version, and contents are required')
	}
	cask := bump_cask_pr_cask_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	parser := homebrew.bump_version_parser_from_value(args[2]) or { return ruby.object_value('ArgumentError', err.msg()) }
	hash := if args[1].type_name in ['Nil', 'NilClass'] {
		?string(none)
	} else {
		?string(args[1].as_string().trim_left(':'))
	}
	result := bump_cask_replace_version_and_checksum(cask, hash, parser, args[3].as_string(), if args.len > 4 {
		args[4].as_string().trim_left(':')
	} else {
		'linux'
	}, if args.len > 5 { args[5].as_string().trim_left(':') } else { 'tahoe' }) or {
		return ruby.object_value('Cask::CaskError', err.msg())
	}
	return ruby.string_value(result)
}

// Ruby method `replace_cask_stanza_value(contents, name, old_value, new_value, within: nil)` at line 384.
pub fn ruby_bump_cask_pr_l384_d4_replace_cask_stanza_value(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		return ruby.object_value('ArgumentError', 'contents, name, old value, and new value are required')
	}
	within := if args.len > 4 && args[4].type_name !in ['Nil', 'NilClass'] {
		?string(args[4].as_string().trim_left(':'))
	} else {
		none
	}
	result := bump_cask_replace_stanza_value(args[0].as_string(), args[1].as_string().trim_left(':'), args[2].as_string().trim_left(':'), args[3].as_string().trim_left(':'), within) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.string_value(result)
}

// Ruby method `check_throttle(cask, new_version:)` at line 402.
pub fn ruby_bump_cask_pr_l402_d5_check_throttle(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'cask and new version are required')
	}
	cask := bump_cask_pr_cask_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	parser := homebrew.bump_version_parser_from_value(args[1]) or { return ruby.object_value('ArgumentError', err.msg()) }
	result := bump_cask_check_throttle(cask, parser, if args.len > 2 { args[2].int_data } else { 0 })
	return bump_cask_check_result_value(result)
}

// Ruby method `shortened_version(version, cask:)` at line 424.
pub fn ruby_bump_cask_pr_l424_d6_shortened_version(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'version and cask are required')
	}
	cask := bump_cask_pr_cask_from_value(args[1]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_value(bump_cask_shortened_version(args[0].as_string(), cask.version))
}

// Ruby method `split_root_version_and_checksum(new_version, contents)` at line 438.
pub fn ruby_bump_cask_pr_l438_d7_split_root_version_and_checksum(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'version and contents are required')
	}
	parser := homebrew.bump_version_parser_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_value(bump_cask_split_root_version_and_checksum(parser, args[1].as_string()))
}

// Ruby method `arch_specific_version_bump?(new_version)` at line 463.
pub fn ruby_bump_cask_pr_l463_d8_arch_specific_version_bump(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'version is required')
	}
	parser := homebrew.bump_version_parser_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.bool_value(bump_cask_arch_specific_version_bump(parser))
}

// Ruby method `default_cask_os` at line 468.
pub fn ruby_bump_cask_pr_l468_d9_default_cask_os(args ...ruby.Value) ruby.Value {
	current_os := if args.len > 0 { args[0].as_string().trim_left(':') } else { 'linux' }
	newest_macos := if args.len > 1 { args[1].as_string().trim_left(':') } else { 'tahoe' }
	return bump_cask_symbol(bump_cask_default_os(current_os, newest_macos))
}

// Ruby method `unsupported_nested_arch_stanza?(contents, name, arch)` at line 476.
pub fn ruby_bump_cask_pr_l476_d10_unsupported_nested_arch_stanza(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'contents, name, and arch are required')
	}
	return ruby.bool_value(bump_cask_unsupported_nested_arch_stanza(args[0].as_string(), args[1].as_string().trim_left(':'), args[2].as_string().trim_left(':')))
}

// Ruby method `cask_stanza_scope(contents, name, arch)` at line 484.
pub fn ruby_bump_cask_pr_l484_d11_cask_stanza_scope(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'contents, name, and arch are required')
	}
	if scope := bump_cask_stanza_scope(args[0].as_string(), args[1].as_string().trim_left(':'), args[2].as_string().trim_left(':')) {
		return bump_cask_symbol(scope)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `check_pull_requests(cask, new_version:)` at line 492.
pub fn ruby_bump_cask_pr_l492_d12_check_pull_requests(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'cask and new version are required')
	}
	cask := bump_cask_pr_cask_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	parser := homebrew.bump_version_parser_from_value(args[1]) or { return ruby.object_value('ArgumentError', err.msg()) }
	checks := bump_cask_check_pull_requests(cask, parser, if args.len > 2 {
		bump_cask_bool(args[2], false)
	} else {
		false
	}) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return bump_cask_pull_request_checks_value(checks)
}

// Ruby method `run_cask_audit(cask, old_contents, audit_exceptions = [])` at line 520.
pub fn ruby_bump_cask_pr_l520_d13_run_cask_audit(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'cask and old contents are required')
	}
	cask := bump_cask_pr_cask_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	exceptions := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	options := if args.len > 3 {
		bump_cask_command_options_from_value(args[3])
	} else {
		BumpCaskCommandOptions{}
	}
	return bump_cask_command_result_value(bump_cask_run_audit(cask, args[1].as_string(), options, exceptions))
}

// Ruby method `run_cask_style(cask, old_contents)` at line 547.
pub fn ruby_bump_cask_pr_l547_d14_run_cask_style(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'cask and old contents are required')
	}
	cask := bump_cask_pr_cask_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	options := if args.len > 2 {
		bump_cask_command_options_from_value(args[2])
	} else {
		BumpCaskCommandOptions{}
	}
	return bump_cask_command_result_value(bump_cask_run_style(cask, args[1].as_string(), options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "bump"
// 6: require "bump_version_parser"
// 7: require "cask"
// 8: require "cask/download"
// 9: require "livecheck/livecheck"
// 10: require "livecheck/livecheck_version"
// 11: require "utils/tar"
// 12:
// 13: module Homebrew
// 14:   module DevCmd
// 15:     class BumpCaskPr < AbstractCommand
// 16:       cmd_args do
// 17:         description <<~EOS
// 18:           Create a pull request to update <cask> with a new version.
// 19:
// 20:           A best effort to determine the <SHA-256> will be made if the value is not
// 21:           supplied by the user.
// 22:         EOS
// 23:         switch "-n", "--dry-run",
// 24:                description: "Print what would be done rather than doing it."
// 25:         switch "--write-only",
// 26:                description: "Make the expected file modifications without taking any Git actions."
// 27:         switch "--commit",
// 28:                depends_on:  "--write-only",
// 29:                description: "When passed with `--write-only`, generate a new commit after writing changes " \
// 30:                             "to the cask file."
// 31:         switch "--no-audit",
// 32:                description: "Don't run `brew audit` before opening the PR."
// 33:         switch "--no-style",
// 34:                description: "Don't run `brew style --fix` before opening the PR."
// 35:         switch "--no-browse",
// 36:                description: "Print the pull request URL instead of opening in a browser."
// 37:         switch "--no-fork",
// 38:                description: "Don't try to fork the repository."
// 39:         flag   "--version=",
// 40:                description: "Specify the new <version> for the cask."
// 41:         flag   "--version-arm=",
// 42:                description: "Specify the new cask <version> for the ARM architecture."
// 43:         flag   "--version-intel=",
// 44:                description: "Specify the new cask <version> for the Intel architecture."
// 45:         flag   "--message=",
// 46:                description: "Prepend <message> to the default pull request message."
// 47:         flag   "--url=",
// 48:                description: "Specify the <URL> for the new download."
// 49:         flag   "--sha256=",
// 50:                description: "Specify the <SHA-256> checksum of the new download."
// 51:         flag   "--fork-org=",
// 52:                description: "Use the specified GitHub organization for forking."
// 53:
// 54:         conflicts "--dry-run", "--write"
// 55:         conflicts "--version", "--version-arm"
// 56:         conflicts "--version", "--version-intel"
// 57:
// 58:         named_args :cask, number: 1, without_api: true
// 59:       end
// 60:
// 61:       sig { override.void }
// 62:       def run
// 63:         # This will be run by `brew audit` or `brew style` later so run it first to
// 64:         # not start spamming during normal output.
// 65:         gem_groups = ["ast"]
// 66:         gem_groups << "style" if !args.no_audit? || !args.no_style?
// 67:         gem_groups << "audit" unless args.no_audit?
// 68:         Homebrew.install_bundler_gems!(groups: gem_groups)
// 69:         require "utils/ast"
// 70:
// 71:         # As this command is simplifying user-run commands then let's just use a
// 72:         # user path, too.
// 73:         ENV["PATH"] = PATH.new(ORIGINAL_PATHS).to_s
// 74:
// 75:         # Use the user's browser, too.
// 76:         ENV["BROWSER"] = EnvConfig.browser
// 77:
// 78:         @cask_retried = T.let(false, T.nilable(T::Boolean))
// 79:         cask = begin
// 80:           args.named.to_casks.fetch(0)
// 81:         rescue Cask::CaskUnavailableError
// 82:           raise if @cask_retried
// 83:
// 84:           CoreCaskTap.instance.install(force: true)
// 85:           @cask_retried = true
// 86:           retry
// 87:         end
// 88:
// 89:         tap = cask.tap
// 90:         odie "This cask is not in a tap!" if tap.nil?
// 91:
// 92:         odie "This cask's tap is not a Git repository!" unless tap.git?
// 93:
// 94:         odie <<~EOS unless tap.allow_bump?(cask.token)
// 95:           Whoops, the #{cask.token} cask has its version update
// 96:           pull requests automatically opened by BrewTestBot every ~3 hours!
// 97:           We'd still love your contributions, though, so try another one
// 98:           that is excluded from autobump list (i.e. it has 'no_autobump!'
// 99:           method or 'livecheck' block with 'skip'.)
// 100:         EOS
// 101:
// 102:         if !args.write_only? && GitHub.too_many_open_prs?(cask.tap)
// 103:           odie "You have too many PRs open: close or merge some first!"
// 104:         end
// 105:
// 106:         new_version = BumpVersionParser.new(
// 107:           general: args.version,
// 108:           intel:   args.version_intel,
// 109:           arm:     args.version_arm,
// 110:         )
// 111:
// 112:         new_hash = unless (new_hash = args.sha256).nil?
// 113:           raise UsageError, "`--sha256` must not be empty." if new_hash.blank?
// 114:
// 115:           ["no_check", ":no_check"].include?(new_hash) ? :no_check : new_hash
// 116:         end
// 117:
// 118:         new_base_url = unless (new_base_url = args.url).nil?
// 119:           raise UsageError, "`--url` must not be empty." if new_base_url.blank?
// 120:
// 121:           begin
// 122:             URI(new_base_url)
// 123:           rescue URI::InvalidURIError
// 124:             raise UsageError, "`--url` is not valid."
// 125:           end
// 126:         end
// 127:
// 128:         if new_version.blank? && new_base_url.nil? && new_hash.nil?
// 129:           raise UsageError, "No `--version`, `--url` or `--sha256` argument specified!"
// 130:         end
// 131:
// 132:         check_throttle(cask, new_version:)
// 133:         check_pull_requests(cask, new_version:) unless args.write_only?
// 134:
// 135:         branch_name = "bump-#{cask.token}"
// 136:         commit_message = nil
// 137:
// 138:         sourcefile_path = cask.sourcefile_path
// 139:         raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 140:
// 141:         old_contents = sourcefile_path.read
// 142:         new_contents = old_contents
// 143:
// 144:         if new_base_url
// 145:           commit_message ||= "#{cask.token}: update URL"
// 146:
// 147:           cask_ast = Utils::AST::CaskAST.new(new_contents)
// 148:           cask_ast.replace_first_stanza_value(:url, new_base_url.to_s)
// 149:           new_contents = cask_ast.process
// 150:         end
// 151:
// 152:         if new_version.present?
// 153:           # For simplicity, our naming defers to the arm version if multiple architectures are specified
// 154:           branch_version = new_version.arm || new_version.intel || new_version.general
// 155:           if branch_version.is_a?(Cask::DSL::Version)
// 156:             commit_version = shortened_version(branch_version, cask:)
// 157:             branch_name = "bump-#{cask.token}-#{branch_version.tr(",:", "-")}"
// 158:             commit_message ||= "#{cask.token} #{commit_version}"
// 159:
// 160:             # Append an arch-only suffix to the branch name and parenthetical to
// 161:             # the commit title if the cask is multi-arch but only one arch is
// 162:             # being updated
// 163:             if new_version.arm && !new_version.intel
// 164:               branch_name += "-arm-only"
// 165:               commit_message += " (arm only)"
// 166:             elsif new_version.intel && !new_version.arm
// 167:               branch_name += "-intel-only"
// 168:               commit_message += " (intel only)"
// 169:             end
// 170:           end
// 171:
// 172:           before_contents = new_contents
// 173:           new_contents = replace_version_and_checksum(cask, new_hash, new_version, new_contents)
// 174:           raise "Unable to update cask" if new_contents == before_contents
// 175:         end
// 176:
// 177:         commit_message ||= "#{cask.token}: update checksum" if new_hash
// 178:
// 179:         # We should have already thrown UsageError above if there's nothing to update
// 180:         raise "Expected to have a commit message" if commit_message.nil?
// 181:
// 182:         sourcefile_path.atomic_write(new_contents) unless args.dry_run?
// 183:
// 184:         audit_exceptions = []
// 185:         audit_exceptions << ["min_os", "rosetta", "signing"] if ENV["HOMEBREW_TEST_BOT_AUTOBUMP"].present?
// 186:         run_cask_audit(cask, old_contents, audit_exceptions)
// 187:         run_cask_style(cask, old_contents)
// 188:
// 189:         return if args.write_only? && !args.commit?
// 190:
// 191:         url = Homebrew::Bump.create_pr(
// 192:           Homebrew::Bump::BumpInfo.new(
// 193:             package_tap: cask.tap,
// 194:             branch_name:,
// 195:             pr_title:    commit_message,
// 196:             pr_message:  Homebrew::Bump.pr_message("bump-cask-pr", user_message: args.message),
// 197:             commits:     [
// 198:               Homebrew::Bump::Commit.new(
// 199:                 sourcefile_path:,
// 200:                 old_contents:,
// 201:                 commit_message:,
// 202:               ),
// 203:             ],
// 204:           ),
// 205:           dry_run:  args.dry_run?,
// 206:           no_fork:  args.no_fork? || args.write_only?,
// 207:           fork_org: args.fork_org,
// 208:           commit:   args.commit?,
// 209:         )
// 210:         return if url.blank?
// 211:
// 212:         if args.no_browse?
// 213:           puts url
// 214:         else
// 215:           exec_browser url
// 216:         end
// 217:       end
// 218:
// 219:       sig { params(cask: Cask::Cask, new_version: BumpVersionParser).returns(T::Array[[Symbol, Symbol]]) }
// 220:       def generate_system_options(cask, new_version)
// 221:         current_os = Homebrew::SimulateSystem.current_os
// 222:         current_os_is_macos = MacOSVersion::SYMBOLS.include?(current_os)
// 223:         newest_macos = MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 224:
// 225:         # NOTE: We substitute the newest macOS (e.g. `:sequoia`) in place of
// 226:         # `:macos` values (when used), as a generic `:macos` value won't apply
// 227:         # to on_system blocks referencing macOS versions.
// 228:         os_values = []
// 229:
// 230:         arch_values = []
// 231:         if new_version.arm || new_version.intel
// 232:           arch_values << :arm if new_version.arm
// 233:           arch_values << :intel if new_version.intel
// 234:         end
// 235:
// 236:         if cask.on_system_blocks_exist?
// 237:           OnSystem::BASE_OS_OPTIONS.each do |os|
// 238:             os_values << if os == :macos
// 239:               (current_os_is_macos ? current_os : newest_macos)
// 240:             else
// 241:               os
// 242:             end
// 243:           end
// 244:
// 245:           # `depends_on arch:` may be scoped to an `on_os` block, so arch
// 246:           # filtering is deferred to `replace_version_and_checksum`.
// 247:           arch_values = OnSystem::ARCH_OPTIONS.dup if arch_values.empty?
// 248:         else
// 249:           # Architecture is only relevant if on_system blocks are present or
// 250:           # the cask uses `depends_on arch`, otherwise we default to ARM for
// 251:           # consistency.
// 252:           os_values << (current_os_is_macos ? current_os : newest_macos)
// 253:           if arch_values.empty?
// 254:             depends_on_archs = cask.depends_on.arch&.filter_map { |arch| arch[:type] }&.uniq
// 255:             arch_values = depends_on_archs.presence || [:arm]
// 256:           end
// 257:         end
// 258:
// 259:         if arch_values.length > 1 && !new_version.general
// 260:           # We sort arch values in descending order by version to mitigate the
// 261:           # issue where updating multiple arch-specific versions can lead to
// 262:           # incorrect version changes in the cask (e.g. ARM is version 1.2.3,
// 263:           # Intel is updated to 1.2.3, ARM is updated to 1.2.4 and this
// 264:           # incorrectly replaces the 1.2.3 version for both archs). This is
// 265:           # something that should be handled by better version replacement logic
// 266:           # but this is a workaround for now.
// 267:           arch_values = arch_values.sort_by do |type|
// 268:             new_version_value = Version.new(new_version.public_send(type) || "0")
// 269:             Livecheck::LivecheckVersion.create(cask, new_version_value)
// 270:           end.reverse
// 271:         end
// 272:
// 273:         os_values.product(arch_values)
// 274:       end
// 275:
// 276:       sig {
// 277:         params(
// 278:           cask:        Cask::Cask,
// 279:           new_hash:    T.nilable(T.any(String, Symbol)),
// 280:           new_version: BumpVersionParser,
// 281:           contents:    String,
// 282:         ).returns(String)
// 283:       }
// 284:       def replace_version_and_checksum(cask, new_hash, new_version, contents)
// 285:         cask_sourcefile_path = cask.sourcefile_path
// 286:         raise "unexpected nil cask.sourcefile_path" unless cask_sourcefile_path
// 287:
// 288:         contents = split_root_version_and_checksum(new_version, contents)
// 289:
// 290:         old_cask = Homebrew::SimulateSystem.with(os: default_cask_os, arch: :arm) do
// 291:           Cask::CaskLoader.load(cask_sourcefile_path)
// 292:         end
// 293:         generate_system_options(cask, new_version).each do |os, arch|
// 294:           tag = Utils::Bottles::Tag.new(system: os, arch:)
// 295:           old_cask.refresh_for_tag(tag) do
// 296:             next if tag.macos? && !old_cask.supports_macos?
// 297:             next if tag.linux? && !old_cask.supports_linux?
// 298:
// 299:             # Skip archs excluded by the cask's `depends_on arch:`.
// 300:             reloaded_archs = old_cask.depends_on.arch&.filter_map { |a| a[:type] }&.uniq
// 301:             next if reloaded_archs.present? && reloaded_archs.exclude?(arch)
// 302:
// 303:             old_version = old_cask.version
// 304:             next unless old_version
// 305:
// 306:             next if unsupported_nested_arch_stanza?(contents, :version, arch) ||
// 307:                     unsupported_nested_arch_stanza?(contents, :sha256, arch)
// 308:
// 309:             bump_version = new_version.public_send(arch) || new_version.general
// 310:             next unless bump_version
// 311:
// 312:             version_scope = cask_stanza_scope(contents, :version, arch)
// 313:             contents = replace_cask_stanza_value(
// 314:               contents, :version,
// 315:               old_version.latest? ? :latest : old_version.to_s,
// 316:               bump_version.latest? ? :latest : bump_version.to_s,
// 317:               within: version_scope
// 318:             )
// 319:
// 320:             tmp_cask = Cask::CaskLoader::FromContentLoader.new(contents)
// 321:                                                           .load(config: nil)
// 322:             old_hash = tmp_cask.sha256
// 323:             if old_hash.nil?
// 324:               raise Cask::CaskError, "#{cask}: No checksum is defined for #{tag.to_sym.inspect}. " \
// 325:                                      "Add `depends_on arch:` or an operating system `depends_on` to " \
// 326:                                      "declare unsupported platforms."
// 327:             end
// 328:             next if new_hash.is_a?(String) && old_hash.to_s == new_hash
// 329:
// 330:             checksum_scope = cask_stanza_scope(contents, :sha256, arch)
// 331:             if tmp_cask.version.latest? || new_hash == :no_check
// 332:               opoo "Ignoring specified `--sha256=` argument." if new_hash.is_a?(String)
// 333:               if old_hash != :no_check
// 334:                 contents = replace_cask_stanza_value(contents, :sha256, old_hash.to_s, :no_check,
// 335:                                                      within: checksum_scope)
// 336:               end
// 337:             elsif old_hash == :no_check && new_hash != :no_check
// 338:               if new_hash.is_a?(String) && (!arch_specific_version_bump?(new_version) || checksum_scope)
// 339:                 contents = replace_cask_stanza_value(contents, :sha256, :no_check, new_hash, within: checksum_scope)
// 340:               end
// 341:             elsif new_hash && cask.languages.empty? &&
// 342:                   (!cask.on_system_blocks_exist? || checksum_scope || arch_specific_version_bump?(new_version))
// 343:               contents = replace_cask_stanza_value(contents, :sha256, old_hash.to_s, new_hash.to_s,
// 344:                                                    within: checksum_scope)
// 345:             elsif old_hash != :no_check
// 346:               opoo "Multiple checksum replacements required; ignoring specified `--sha256` argument." if new_hash
// 347:               languages = if cask.languages.empty?
// 348:                 [nil]
// 349:               else
// 350:                 cask.languages
// 351:               end
// 352:               languages.each do |language|
// 353:                 new_cask        = Cask::CaskLoader.load(contents)
// 354:                 next unless new_cask.url
// 355:
// 356:                 new_cask.config = if language.blank?
// 357:                   tmp_cask.config
// 358:                 else
// 359:                   tmp_cask.config.merge(Cask::Config.new(explicit: { languages: [language] }))
// 360:                 end
// 361:                 download = Cask::Download.new(new_cask).fetch(verify_download_integrity: false)
// 362:                 Utils::Tar.validate_file(download)
// 363:
// 364:                 if new_cask.sha256.to_s != download.sha256
// 365:                   contents = replace_cask_stanza_value(contents, :sha256, new_cask.sha256.to_s, download.sha256,
// 366:                                                        within: checksum_scope)
// 367:                 end
// 368:               end
// 369:             end
// 370:           end
// 371:         end
// 372:         contents
// 373:       end
// 374:
// 375:       sig {
// 376:         params(
// 377:           contents:  String,
// 378:           name:      Symbol,
// 379:           old_value: T.any(Numeric, String, Symbol),
// 380:           new_value: T.any(Numeric, String, Symbol),
// 381:           within:    T.nilable(Symbol),
// 382:         ).returns(String)
// 383:       }
// 384:       def replace_cask_stanza_value(contents, name, old_value, new_value, within: nil)
// 385:         return contents if old_value == new_value
// 386:
// 387:         cask_ast = Utils::AST::CaskAST.new(contents)
// 388:         replacement_count = cask_ast.replace_stanza_value(name, old_value, new_value, within:)
// 389:         if replacement_count.zero?
// 390:           # Treat an already-applied replacement as a successful no-op so the
// 391:           # per-(os, arch) loop in `replace_version_and_checksum` can yield the
// 392:           # same general version more than once without raising.
// 393:           return contents if cask_ast.replace_stanza_value(name, new_value, new_value, within:).positive?
// 394:
// 395:           raise "Could not find '#{name}' stanza with value #{old_value.inspect}!"
// 396:         end
// 397:
// 398:         cask_ast.process
// 399:       end
// 400:
// 401:       sig { params(cask: Cask::Cask, new_version: BumpVersionParser).void }
// 402:       def check_throttle(cask, new_version:)
// 403:         return unless cask.tap
// 404:
// 405:         throttle_rate = cask.livecheck.throttle
// 406:         throttle_days = cask.livecheck.throttle_days
// 407:         return if throttle_rate.nil? && throttle_days.nil?
// 408:
// 409:         version = new_version.arm || new_version.intel || new_version.general
// 410:         return unless version.is_a?(Cask::DSL::Version)
// 411:
// 412:         return if Livecheck.throttle_allows_bump?(cask, version.to_s, throttle_rate:, throttle_days:)
// 413:
// 414:         throttle_items = []
// 415:         throttle_items << "#{throttle_rate} releases on multiples of #{throttle_rate}" if throttle_rate
// 416:         throttle_items << "#{throttle_days} #{Utils.pluralize("day", throttle_days)}" if throttle_days
// 417:
// 418:         odie "#{cask.token} should only be updated every #{throttle_items.join(" or ")}"
// 419:       end
// 420:
// 421:       private
// 422:
// 423:       sig { params(version: Cask::DSL::Version, cask: Cask::Cask).returns(Cask::DSL::Version) }
// 424:       def shortened_version(version, cask:)
// 425:         if version.before_comma == cask.version.before_comma
// 426:           version
// 427:         else
// 428:           version.before_comma
// 429:         end
// 430:       end
// 431:
// 432:       sig {
// 433:         params(
// 434:           new_version: BumpVersionParser,
// 435:           contents:    String,
// 436:         ).returns(String)
// 437:       }
// 438:       def split_root_version_and_checksum(new_version, contents)
// 439:         return contents unless arch_specific_version_bump?(new_version)
// 440:
// 441:         cask_ast = Utils::AST::CaskAST.new(contents)
// 442:         root_version = cask_ast.first_stanza_value(:version, within: :root)
// 443:         if root_version &&
// 444:            !cask_ast.stanza_anywhere?(:version, within: :on_arm) &&
// 445:            !cask_ast.stanza_anywhere?(:version, within: :on_intel)
// 446:           cask_ast.replace_root_stanza_with_arch_blocks(:version, root_version)
// 447:           contents = cask_ast.process
// 448:         end
// 449:
// 450:         cask_ast = Utils::AST::CaskAST.new(contents)
// 451:         root_sha256 = cask_ast.first_stanza_value(:sha256, within: :root)
// 452:         if root_sha256.is_a?(String) &&
// 453:            !cask_ast.stanza_anywhere?(:sha256, within: :on_arm) &&
// 454:            !cask_ast.stanza_anywhere?(:sha256, within: :on_intel)
// 455:           cask_ast.replace_root_stanza_with_arch_blocks(:sha256, root_sha256)
// 456:           contents = cask_ast.process
// 457:         end
// 458:
// 459:         contents
// 460:       end
// 461:
// 462:       sig { params(new_version: BumpVersionParser).returns(T::Boolean) }
// 463:       def arch_specific_version_bump?(new_version)
// 464:         new_version.arm.present? || new_version.intel.present?
// 465:       end
// 466:
// 467:       sig { returns(Symbol) }
// 468:       def default_cask_os
// 469:         current_os = Homebrew::SimulateSystem.current_os
// 470:         return current_os if MacOSVersion::SYMBOLS.include?(current_os)
// 471:
// 472:         MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 473:       end
// 474:
// 475:       sig { params(contents: String, name: Symbol, arch: Symbol).returns(T::Boolean) }
// 476:       def unsupported_nested_arch_stanza?(contents, name, arch)
// 477:         cask_ast = Utils::AST::CaskAST.new(contents)
// 478:         scope = :"on_#{arch}"
// 479:
// 480:         cask_ast.stanza_anywhere?(name, within: scope) && !cask_ast.stanza?(name, within: scope)
// 481:       end
// 482:
// 483:       sig { params(contents: String, name: Symbol, arch: Symbol).returns(T.nilable(Symbol)) }
// 484:       def cask_stanza_scope(contents, name, arch)
// 485:         scope = :"on_#{arch}"
// 486:         return scope if Utils::AST::CaskAST.new(contents).stanza?(name, within: scope)
// 487:
// 488:         nil
// 489:       end
// 490:
// 491:       sig { params(cask: Cask::Cask, new_version: BumpVersionParser).void }
// 492:       def check_pull_requests(cask, new_version:)
// 493:         tap = cask.tap
// 494:         raise "unexpected nil cask.tap" unless tap
// 495:
// 496:         tap_remote_repo = tap.remote_repository
// 497:         odie "#{tap.name} tap does not have a remote repository!" unless tap_remote_repo
// 498:
// 499:         sourcefile_path = cask.sourcefile_path
// 500:         raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 501:
// 502:         file = sourcefile_path.relative_path_from(tap.path).to_s
// 503:         quiet = args.quiet?
// 504:         official_tap = tap.official?
// 505:         GitHub.check_for_duplicate_pull_requests(cask.token, tap_remote_repo,
// 506:                                                  state: "open", file:, quiet:, official_tap:)
// 507:
// 508:         # if we haven't already found open requests, try for an exact match across all pull requests
// 509:         new_version.instance_variables.each do |version_type|
// 510:           version_type_version = new_version.instance_variable_get(version_type)
// 511:           next if version_type_version.blank?
// 512:
// 513:           version = shortened_version(version_type_version, cask:)
// 514:           GitHub.check_for_duplicate_pull_requests(cask.token, tap_remote_repo, version:,
// 515:                                                    file:, quiet:, official_tap:)
// 516:         end
// 517:       end
// 518:
// 519:       sig { params(cask: Cask::Cask, old_contents: String, audit_exceptions: T::Array[String]).void }
// 520:       def run_cask_audit(cask, old_contents, audit_exceptions = [])
// 521:         if args.dry_run?
// 522:           if args.no_audit?
// 523:             ohai "Skipping `brew audit`"
// 524:           else
// 525:             ohai "brew audit --cask --online #{cask.full_name}"
// 526:           end
// 527:           return
// 528:         end
// 529:         failed_audit = false
// 530:         if args.no_audit?
// 531:           ohai "Skipping `brew audit`"
// 532:         else
// 533:           system HOMEBREW_BREW_FILE.to_s, "audit", "--cask", "--online", cask.full_name,
// 534:                  "--except=#{audit_exceptions.join(",")}"
// 535:           failed_audit = !$CHILD_STATUS.success?
// 536:         end
// 537:         return unless failed_audit
// 538:
// 539:         sourcefile_path = cask.sourcefile_path
// 540:         raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 541:
// 542:         sourcefile_path.atomic_write(old_contents)
// 543:         odie "`brew audit` failed!"
// 544:       end
// 545:
// 546:       sig { params(cask: Cask::Cask, old_contents: String).void }
// 547:       def run_cask_style(cask, old_contents)
// 548:         sourcefile_path = cask.sourcefile_path
// 549:         raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 550:
// 551:         if args.dry_run?
// 552:           if args.no_style?
// 553:             ohai "Skipping `brew style --fix`"
// 554:           else
// 555:             ohai "brew style --fix #{sourcefile_path.basename}"
// 556:           end
// 557:           return
// 558:         end
// 559:         failed_style = false
// 560:         if args.no_style?
// 561:           ohai "Skipping `brew style --fix`"
// 562:         else
// 563:           system HOMEBREW_BREW_FILE.to_s, "style", "--fix", sourcefile_path.to_s
// 564:           failed_style = !$CHILD_STATUS.success?
// 565:         end
// 566:         return unless failed_style
// 567:
// 568:         sourcefile_path.atomic_write(old_contents)
// 569:         odie "`brew style --fix` failed!"
// 570:       end
// 571:     end
// 572:   end
// 573: end
