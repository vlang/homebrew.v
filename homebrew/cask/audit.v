module cask

import ruby
import os

pub struct AuditUrl {
pub:
	value       string
	location    string
	verified    string
	using       string
	user_agent  string
	referer     string
	unversioned bool
}

pub struct AuditArtifact {
pub:
	kind                 string
	source               string
	target               string
	path                 string
	english_name         string
	directives           []string
	allow_untrusted      bool
	manual_install       bool
	target_absolute      bool = true
	quarantined          bool = true
	signing_success      bool = true
	signing_output       string
	architecture_output  string
	architecture_success bool = true
	on_disk_path         string
	minimum_os           string
	main_binary          string
	binary_exists        bool
	binary_executable    bool
	binary_script        bool
}

pub struct AuditLivecheck {
pub:
	defined                   bool
	skip                      bool
	strategy                  string
	url                       string
	url_symbol                bool
	post_form                 bool
	post_json                 bool
	strategy_block_uses_items bool
	page_content              string
	minimum_os                string
	result_available          bool
	latest                    string
	latest_throttled          string
	throttle                  bool
	throttle_days             int
	referenced                bool
	referenced_skip           bool
	referenced_throttle       bool
	referenced_throttle_days  int
}

pub struct AuditTap {
pub:
	name                       string
	user                       string
	official                   bool
	core_cask                  bool
	formula_names              []string
	cask_tokens                []string
	tap_migrations             []string
	path                       string
	default_remote             string
	expected_cask_path         string
	simple_homepage_user_agent bool
	secure_skip_urls           []string
	signing_skip_arches        []string
}

pub struct AuditCask {
pub:
	token                          string
	version                        string
	version_present                bool = true
	version_latest                 bool
	sha256                         string
	sha256_present                 bool = true
	sha256_no_check                bool
	url                            AuditUrl
	url_present                    bool = true
	homepage                       string
	homepage_present               bool = true
	homepage_browsed_days_ago      int = -1
	names                          []string
	description                    string
	languages                      []string
	artifacts                      []AuditArtifact
	installable_artifact           bool
	on_system_installable_artifact bool
	on_system_blocks               bool
	auto_updates                   bool
	deprecated                     bool
	disabled                       bool
	deprecation_reason             string
	tap                            AuditTap
	sourcefile_path                string
	conflicting_casks              []string
	livecheck                      AuditLivecheck
	appdir                         string = '/Applications'
	staged_path                    string
	caveats                        string
	requires_rosetta_invoked       bool
	required_arches                []string
	maximum_macos                  string
	on_system_min_os               string
	depends_on_min_os              string
	bundle_min_os                  string
	sparkle_min_os                 string
}

pub struct AuditCollaborators {
pub:
	download_requested      bool
	download_success        bool = true
	download_error          string
	quarantine_available    bool = true
	current_arch            string = 'arm'
	current_macos           string = '15'
	oldest_allowed_macos    string = '11'
	https_problems          map[string]string
	self_submission_owners  []string
	repository_errors       map[string]string
	repository_archived     map[string]bool
	repository_archived_at  map[string]string
	deprecate_disable_error string
	formula_path            string
	file_exists             map[string]bool
	file_executable         map[string]bool
	plist_executables       map[string]string
	audit_failures          map[string]string
	container_detected      bool = true
	container_dependencies  []string
	linked_dependencies     []string
	valid_dependencies      []string
	nested_container        string
	quarantine_detected     bool
}

pub struct AuditOptions {
pub:
	download bool
	online   ?bool
	strict   ?bool
	signing  ?bool
	new_cask ?bool
	only     []string
	except   []string
}

pub struct AuditError {
pub:
	message   string
	location  string
	corrected bool
}

pub struct CaskAudit {
pub:
	cask      AuditCask
	download  bool
	online    bool
	strict    bool
	signing   bool
	new_cask  bool
	only      []string
	except    []string
	providers AuditCollaborators
pub mut:
	errors              []AuditError
	livecheck_result    string
	artifacts_extracted bool
	operations          []string
}

pub fn new_cask_audit(cask AuditCask, options AuditOptions, providers AuditCollaborators) CaskAudit {
	new_cask := options.new_cask or { false }
	online := options.online or { new_cask }
	strict := options.strict or { new_cask }
	signing := options.signing or { new_cask }
	return CaskAudit{
		cask: cask
		download: options.download || online || signing
		online: online
		strict: strict
		signing: signing
		new_cask: new_cask
		only: options.only.clone()
		except: options.except.clone()
		providers: providers
	}
}

pub fn (audit CaskAudit) errors_present() bool {
	return audit.errors.len > 0
}

pub fn (audit CaskAudit) success() bool {
	return !audit.errors_present()
}

pub fn (mut audit CaskAudit) add(message string, location string, strict_only bool) {
	if strict_only && !audit.strict {
		return
	}
	audit.errors << AuditError{
		message: message
		location: location
	}
}

pub fn (audit CaskAudit) result_text() ?string {
	if audit.errors_present() {
		return 'failed'
	}
	return none
}

pub fn (audit CaskAudit) summary_text() ?string {
	result := audit.result_text() or { return none }
	mut lines := ['audit for ${audit.cask.token}: ${result}']
	for problem in audit.errors {
		lines << ' - ${problem.message}'
	}
	return lines.join('\n')
}

fn audit_version_parts(value string) []int {
	mut parts := []int{}
	for component in value.split('.') {
		mut digits := ''
		for character in component {
			if character >= `0` && character <= `9` {
				digits += character.ascii_str()
			} else {
				break
			}
		}
		parts << if digits == '' { 0 } else { digits.int() }
	}
	return parts
}

fn audit_compare_versions(left string, right string) int {
	a := audit_version_parts(left)
	b := audit_version_parts(right)
	length := if a.len > b.len { a.len } else { b.len }
	for index in 0 .. length {
		av := if index < a.len { a[index] } else { 0 }
		bv := if index < b.len { b[index] } else { 0 }
		if av < bv {
			return -1
		}
		if av > bv {
			return 1
		}
	}
	return 0
}

pub fn normalize_audit_min_os(value string) ?string {
	trimmed := value.trim_space()
	if trimmed == '' {
		return none
	}
	parts := audit_version_parts(trimmed)
	if parts.len == 0 {
		return none
	}
	mut normalized := if parts.len > 1 { '${parts[0]}.${parts[1]}' } else { '${parts[0]}' }
	if normalized == '10.16' {
		normalized = '11'
	}
	return normalized
}

fn audit_token_errors(token string) []string {
	mut errors := []string{}
	mut uppercase := false
	mut whitespace := false
	mut ascii := true
	for character in token.bytes() {
		if character >= `A` && character <= `Z` {
			uppercase = true
		}
		if character in [` `, `\t`, `\n`, `\r`, `\v`, `\f`] {
			whitespace = true
		}
		if character > 127 {
			ascii = false
		}
	}
	if uppercase { errors << 'uppercase letters' }
	if whitespace { errors << 'whitespace' }
	if !ascii { errors << 'non-ASCII characters' }
	if token.contains('--') { errors << 'double hyphens' }
	if token.starts_with('@') { errors << 'a leading @' }
	if token.ends_with('@') { errors << 'a trailing @' }
	if token.starts_with('-') { errors << 'a leading hyphen' }
	if token.ends_with('-') { errors << 'a trailing hyphen' }
	if token.count('@') > 1 { errors << 'multiple @ symbols' }
	if token.contains('-@') { errors << 'a hyphen followed by an @' }
	if token.contains('@-') { errors << 'an @ followed by a hyphen' }
	return errors
}

fn audit_to_sentence(values []string) string {
	if values.len == 0 {
		return ''
	}
	if values.len == 1 {
		return values[0]
	}
	if values.len == 2 {
		return '${values[0]} or ${values[1]}'
	}
	return '${values[..values.len - 1].join(', ')} or ${values.last()}'
}

fn audit_valid_locale(locale string) bool {
	parts := locale.split('-')
	if parts.len == 0 || parts.len > 3 || parts[0].len != 2 || parts[0] != parts[0].to_lower() {
		return false
	}
	for character in parts[0] {
		if character < `a` || character > `z` {
			return false
		}
	}
	if parts.len > 1 {
		if parts[1].len != 2 || parts[1] != parts[1].to_upper() {
			return false
		}
		for character in parts[1] {
			if character < `A` || character > `Z` {
				return false
			}
		}
	}
	return parts.all(it != '')
}

fn audit_url_host(value string) string {
	without_scheme := if value.contains('://') { value.all_after('://') } else { value }
	return without_scheme.all_before('/').all_before(':').to_lower()
}

pub fn audit_bad_sourceforge_url(value string) bool {
	is_sourceforge := value.contains('sourceforge') && (value.contains('downloads.') || value.contains('.dl.') || value.contains('//sourceforge'))
	if !is_sourceforge {
		return false
	}
	valid_latest := value.starts_with('https://sourceforge.net/projects/') && value.ends_with('/files/latest/download')
	valid_download := value.starts_with('https://downloads.sourceforge.net/') && !value.starts_with('https://downloads.sourceforge.net/project/') && !value.starts_with('https://downloads.sourceforge.net/sourceforge/')
	return !valid_latest && !valid_download
}

// Regex matching remains an injected source collaborator at this boundary; this
// function translates the Ruby `match?`/`none?` decision without changing it.
pub fn audit_bad_url_format(regex_matches bool, valid_format_matches []bool) bool {
	return regex_matches && valid_format_matches.all(!it)
}

pub fn audit_repo_data(cask AuditCask, host string) ?[]string {
	if cask.url_present {
		if pair := audit_repo_data_from_url(cask.url.value, host) {
			return pair
		}
	}
	return audit_repo_data_from_url(cask.homepage, host)
}

fn audit_repo_data_from_url(value string, host string) ?[]string {
	needle := '${host}/'
	if !value.contains(needle) {
		return none
	}
	tail := value.all_after(needle)
	parts := tail.split('/')
	if parts.len < 2 || parts[0] == '' || parts[1] == '' {
		return none
	}
	return [parts[0], parts[1].trim_string_right('.git')]
}

fn (mut audit CaskAudit) audit_untrusted_pkg() {
	if audit.cask.sourcefile_path == '' || audit.cask.tap.user != 'Homebrew' {
		return
	}
	if audit.cask.artifacts.any(it.kind == 'pkg' && it.allow_untrusted) {
		audit.add('allow_untrusted is not permitted in the official homebrew/cask tap', '', false)
	}
}

fn (mut audit CaskAudit) audit_stanza_requires_uninstall() {
	if !audit.cask.artifacts.any(it.kind in ['pkg', 'installer']) {
		return
	}
	if audit.cask.artifacts.any(it.kind == 'uninstall') {
		return
	}
	audit.add('installer and pkg stanzas require an uninstall stanza', '', false)
}

fn (mut audit CaskAudit) audit_single_pre_postflight() {
	if audit.cask.artifacts.filter(it.kind == 'preflight' && 'preflight' in it.directives).len > 1 {
		audit.add('only a single preflight stanza is allowed', '', false)
	}
	if audit.cask.artifacts.filter(it.kind == 'postflight' && 'postflight' in it.directives).len > 1 {
		audit.add('only a single postflight stanza is allowed', '', false)
	}
}

fn (mut audit CaskAudit) audit_single_uninstall_zap() {
	if audit.cask.artifacts.filter(it.kind == 'preflight' && 'uninstall_preflight' in it.directives).len > 1 {
		audit.add('only a single uninstall_preflight stanza is allowed', '', false)
	}
	if audit.cask.artifacts.filter(it.kind == 'postflight' && 'uninstall_postflight' in it.directives).len > 1 {
		audit.add('only a single uninstall_postflight stanza is allowed', '', false)
	}
	if audit.cask.artifacts.filter(it.kind == 'zap').len > 1 {
		audit.add('only a single zap stanza is allowed', '', false)
	}
}

fn (mut audit CaskAudit) audit_required_stanzas() {
	if !audit.cask.version_present { audit.add('a version stanza is required', '', false) }
	if !audit.cask.sha256_present { audit.add('a sha256 stanza is required', '', false) }
	if !audit.cask.url_present { audit.add('a url stanza is required', '', false) }
	if !audit.cask.homepage_present { audit.add('a homepage stanza is required', '', false) }
	if audit.cask.names.len == 0 { audit.add('at least one name stanza is required', '', false) }
	installable := if audit.cask.on_system_blocks {
		audit.cask.on_system_installable_artifact
	} else {
		audit.cask.installable_artifact || audit.cask.artifacts.any(it.kind in ['app', 'binary',
			'pkg', 'installer'])
	}
	if !installable { audit.add('at least one installable artifact stanza is required', '', false) }
}

fn (mut audit CaskAudit) audit_description() {
	if audit.cask.tap.name == 'homebrew/cask' && audit.cask.token.contains('font-') {
		return
	}
	if audit.cask.description.trim_space() == '' {
		audit.add('Cask should have a description. Please add a `desc` stanza.', '', true)
	}
}

fn (mut audit CaskAudit) audit_version_special_characters() {
	if !audit.cask.version_present || audit.cask.version_latest {
		return
	}
	if audit.cask.version.contains(':') || audit.cask.version.contains('/') {
		audit.add('version should not contain colons or slashes', '', false)
	}
}

fn (mut audit CaskAudit) audit_no_string_version_latest() {
	if audit.cask.version_present && audit.cask.version == 'latest' && !audit.cask.version_latest {
		audit.add("you should use version :latest instead of version 'latest'", '', false)
	}
}

fn (mut audit CaskAudit) audit_sha256_no_check_if_latest() {
	if audit.cask.sha256_present && audit.cask.version_present && audit.cask.version_latest && !audit.cask.sha256_no_check {
		audit.add('you should use sha256 :no_check when version is :latest', '', false)
	}
}

fn (mut audit CaskAudit) audit_sha256_no_check_if_unversioned() {
	if audit.cask.sha256_present && !audit.cask.sha256_no_check && audit.cask.url_present && audit.cask.url.unversioned {
		audit.add('Use `sha256 :no_check` when URL is unversioned.', '', false)
	}
}

fn audit_hex_sha256(value string) bool {
	if value.len != 64 {
		return false
	}
	for character in value.bytes() {
		if !((character >= `0` && character <= `9`) || (character >= `a` && character <= `f`) || (character >= `A` && character <= `F`)) {
			return false
		}
	}
	return true
}

fn (mut audit CaskAudit) audit_sha256_actually_256() {
	if audit.cask.sha256_present && !audit.cask.sha256_no_check && !audit_hex_sha256(audit.cask.sha256) {
		audit.add('sha256 string must be of 64 hexadecimal characters', '', false)
	}
}

fn (mut audit CaskAudit) audit_sha256_invalid() {
	empty_sha256 := 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
	if audit.cask.sha256_present && audit.cask.sha256 == empty_sha256 {
		audit.add('cannot use the sha256 for an empty string: ${empty_sha256}', '', false)
	}
}

fn (mut audit CaskAudit) audit_latest_with_livecheck() {
	if audit.cask.version_latest && audit.cask.livecheck.defined && !audit.cask.livecheck.skip {
		audit.add('Casks with a `livecheck` should not use `version :latest`.', '', false)
	}
}

fn (mut audit CaskAudit) audit_latest_with_auto_updates() {
	if audit.cask.version_latest && audit.cask.auto_updates {
		audit.add('Casks with `version :latest` should not use `auto_updates`.', '', false)
	}
}

fn (mut audit CaskAudit) audit_hosting_with_livecheck() {
	if audit.cask.deprecated || audit.cask.disabled || audit.cask.version_latest || !audit.cask.url_present || audit.cask.livecheck.defined || audit.livecheck_result == 'auto_detected' {
		return
	}
	add_livecheck := 'please add a livecheck. See https://docs.brew.sh/Cask-Cookbook#stanza-livecheck'
	if audit.cask.url.value.contains('sourceforge.net/') {
		if audit.online {
			audit.add('Download is hosted on SourceForge, ${add_livecheck}', audit.cask.url.location, false)
		}
	} else if audit.cask.url.value.contains('dl.devmate.com/') {
		audit.add('Download is hosted on DevMate, ${add_livecheck}', audit.cask.url.location, false)
	} else if audit.cask.url.value.contains('rink.hockeyapp.net/') {
		audit.add('Download is hosted on HockeyApp, ${add_livecheck}', audit.cask.url.location, false)
	}
}

fn (mut audit CaskAudit) audit_download_url_format() {
	if audit.cask.url_present && audit_bad_sourceforge_url(audit.cask.url.value) {
		audit.add('SourceForge URL format incorrect. See https://docs.brew.sh/Cask-Cookbook#sourceforgeosdn-urls', audit.cask.url.location, false)
	}
}

fn (mut audit CaskAudit) audit_download_url_is_osdn() {
	if audit.cask.url_present {
		host := audit_url_host(audit.cask.url.value)
		if host == 'osdn.jp' || host.ends_with('.osdn.jp') {
			audit.add('OSDN download urls are disabled.', audit.cask.url.location, true)
		}
	}
}

fn (mut audit CaskAudit) audit_unnecessary_verified() {
	if audit.new_cask && audit.cask.url_present && audit.cask.url.verified.trim_space() != '' {
		audit.add('the `verified` parameter has been deprecated; use the `url` stanza without it', '', false)
	}
}

fn (mut audit CaskAudit) audit_generic_artifacts() {
	for artifact in audit.cask.artifacts {
		if artifact.kind != 'generic' || artifact.target_absolute {
			continue
		}
		name := if artifact.english_name == '' { 'artifact' } else { artifact.english_name }
		audit.add('target must be absolute path for ${name} ${artifact.source}', '', false)
	}
}

fn (mut audit CaskAudit) audit_languages() {
	for language in audit.cask.languages {
		if !audit_valid_locale(language) { audit.add("Locale '${language}' is invalid.", '', false) }
	}
}

fn (mut audit CaskAudit) audit_token() {
	errors := audit_token_errors(audit.cask.token)
	if errors.len > 0 {
		audit.add("Cask token '${audit.cask.token}' must not contain ${audit_to_sentence(errors)}.", '', false)
	}
}

fn (mut audit CaskAudit) audit_token_conflicts() {
	if audit.cask.token in audit.cask.tap.formula_names {
		audit.add('cask token conflicts with an existing homebrew/core formula: ${audit.core_formula_url()}', '', false)
	}
}

fn (mut audit CaskAudit) audit_token_bad_words() {
	if !audit.new_cask {
		return
	}
	token := audit.cask.token
	if token.ends_with('.app') { audit.add('cask token contains .app', '', false) }
	for designation in ['alpha', 'beta', 'rc', 'release-candidate'] {
		if token.ends_with('-${designation}') && audit.cask.tap.official {
			audit.add("cask token contains version designation '${designation}'", '', false)
			break
		}
	}
	if token.ends_with('launcher') { audit.add('cask token mentions launcher', '', true) }
	if token.ends_with('desktop') { audit.add('cask token mentions desktop', '', true) }
	if ['mac', 'osx', 'macos'].any(token.ends_with(it)) {
		audit.add('cask token mentions platform', '', true)
	}
	if ['x86', '32_bit', 'x86_64', '64_bit'].any(token.ends_with(it)) {
		audit.add('cask token mentions architecture', '', true)
	}
	frameworks := ['cocoa', 'qt', 'gtk', 'wx', 'java']
	if token !in frameworks && frameworks.any(token.ends_with(it)) {
		audit.add('cask token mentions framework', '', true)
	}
}

fn (mut audit CaskAudit) audit_download_fetch() {
	if !audit.download || !audit.cask.url_present {
		return
	}
	if !audit.providers.download_success {
		message := if audit.providers.download_error == '' {
			'download failed'
		} else {
			audit.providers.download_error
		}
		audit.add('download not possible: ${message}', audit.cask.url.location, false)
	}
}

fn (mut audit CaskAudit) audit_livecheck_unneeded_long_version() {
	if !audit.cask.version_present || !audit.cask.url_present || audit.cask.livecheck.strategy != 'sparkle' {
		return
	}
	parts := audit.cask.version.split(',')
	if parts.len < 2 || audit.cask.url.value.contains(parts[1]) {
		return
	}
	if parts.len > 2 && parts[2] != '' && audit.cask.url.value.contains(parts[2]) {
		return
	}
	audit.add('Download does not require additional version components. Use `&:short_version` in the livecheck', audit.cask.url.location, true)
}

fn audit_extractable_artifacts(cask AuditCask, include_manual_installers bool) []AuditArtifact {
	return cask.artifacts.filter(it.kind in ['pkg', 'app', 'binary'] || (include_manual_installers && it.kind == 'installer' && it.manual_install && (it.path.to_lower().ends_with('.app') || it.path.to_lower().ends_with('.pkg'))))
}

pub fn (mut audit CaskAudit) extract_artifacts(include_manual_installers bool) []AuditArtifact {
	if !audit.online || !audit.download {
		return []AuditArtifact{}
	}
	artifacts := audit_extractable_artifacts(audit.cask, include_manual_installers)
	if audit.artifacts_extracted {
		return artifacts
	}
	if artifacts.len == 0 {
		return []AuditArtifact{}
	}
	audit.operations << 'download_and_extract'
	if !audit.providers.download_success {
		return []AuditArtifact{}
	}
	if !audit.providers.container_detected {
		return []AuditArtifact{}
	}
	mut installers := []string{}
	for dependency in audit.providers.container_dependencies {
		if dependency !in audit.providers.linked_dependencies {
			installers << dependency
		}
	}
	if installers.len > 0 {
		audit.operations << 'perform_preinstall_checks_once'
		audit.operations << 'fetch_formulae:${installers.join(',')}'
		for dependency in installers {
			if dependency in audit.providers.valid_dependencies {
				audit.operations << 'install:${dependency}'
				audit.operations << 'finish:${dependency}'
			}
		}
	}
	audit.operations << 'extract_nestedly'
	if audit.providers.nested_container != '' {
		audit.operations << 'chmod_nested:${audit.providers.nested_container}'
		audit.operations << 'extract_nested:${audit.providers.nested_container}'
	}
	if audit.providers.quarantine_available && audit.providers.quarantine_detected {
		audit.operations << 'propagate_quarantine'
	}
	audit.operations << 'process_rename_operations'
	audit.artifacts_extracted = true
	return artifacts
}

fn (mut audit CaskAudit) audit_signing_check() {
	if !audit.download || !audit.cask.url_present {
		return
	}
	if !audit.cask.tap.official && !audit.signing {
		return
	}
	if audit.cask.deprecated && audit.cask.deprecation_reason != 'fails_gatekeeper_check' {
		return
	}
	if !audit.providers.quarantine_available {
		return
	}
	arch := if audit.providers.current_arch == '' { 'arm' } else { audit.providers.current_arch }
	skiplisted := arch in audit.cask.tap.signing_skip_arches || 'all' in audit.cask.tap.signing_skip_arches
	artifacts := audit.extract_artifacts(true)
	is_container := artifacts.any(it.kind in ['app', 'pkg'] || (it.kind == 'installer' && (it.path.to_lower().ends_with('.app') || it.path.to_lower().ends_with('.pkg'))))
	mut any_failure := false
	for artifact in artifacts {
		if artifact.kind == 'binary' && is_container {
			continue
		}
		if !artifact.quarantined {
			continue
		}
		if artifact.kind == 'binary' && artifact.binary_script {
			continue
		}
		if artifact.kind !in ['pkg', 'app', 'installer', 'binary'] {
			audit.add('Unknown artifact type: ${artifact.kind}', audit.cask.url.location, false)
			continue
		}
		if artifact.signing_success {
			continue
		}
		any_failure = true
		if (audit.cask.deprecated && audit.cask.deprecation_reason == 'fails_gatekeeper_check') || skiplisted {
			continue
		}
		mut message := 'Signature verification failed:\n${artifact.signing_output}\n'
		if audit.cask.tap.official {
			message += 'The homebrew/cask tap requires all casks to be signed and notarized by Apple.\nPlease contact the upstream developer and ask them to sign and notarize their software.\n'
		}
		audit.add(message, '', false)
	}
	if any_failure {
		return
	}
	if skiplisted {
		audit.add('Cask is in the signing audit skiplist, but does not need to be skipped!', '', false)
	}
	if audit.cask.deprecated && audit.cask.deprecation_reason == 'fails_gatekeeper_check' {
		audit.add('Cask is deprecated because it failed Gatekeeper checks but all artifacts now pass!\nRemove the deprecate/disable stanza or update the deprecate/disable reason.\n', '', false)
	}
}

fn audit_relative_artifact_source(cask AuditCask, artifact AuditArtifact) string {
	mut source := if artifact.kind in ['pkg', 'installer'] {
		artifact.path
	} else {
		artifact.source
	}
	app_prefix := cask.appdir.trim_string_right('/') + '/'
	if source.starts_with(app_prefix) {
		return source.trim_string_left(app_prefix)
	}
	if source.starts_with('/') && cask.staged_path != '' && source.starts_with(cask.staged_path) {
		source = source.trim_string_left(cask.staged_path).trim_string_left('/')
	}
	return source
}

fn (mut audit CaskAudit) audit_artifact_case_check() {
	if !audit.cask.url_present || !audit.online {
		return
	}
	for artifact in audit.extract_artifacts(true) {
		source := audit_relative_artifact_source(audit.cask, artifact)
		on_disk := artifact.on_disk_path
		if on_disk != '' && source.split('/').len == on_disk.split('/').len && source != on_disk && source.to_lower() == on_disk.to_lower() {
			audit.add('Artifact ${source} does not match the case of the extracted ${on_disk}; this fails on case-sensitive filesystems.', audit.cask.url.location, false)
		}
	}
}

fn (mut audit CaskAudit) audit_rosetta_check() {
	if !audit.cask.url_present || !audit.online || audit.providers.current_arch != 'arm' || audit_compare_versions(audit.providers.current_macos, '11') < 0 || (audit.cask.maximum_macos != '' && audit_compare_versions(audit.cask.maximum_macos, '11') < 0) {
		return
	}
	artifacts := audit.extract_artifacts(false)
	is_container := artifacts.any(it.kind in ['app', 'pkg'])
	mentions := audit.cask.requires_rosetta_invoked || audit.cask.caveats.contains('requires Rosetta 2')
	requires_intel := 'intel' in audit.cask.required_arches
	mut tested := 0
	mut any_requires := false
	for artifact in artifacts {
		if artifact.kind !in ['app', 'binary'] || (artifact.kind == 'binary' && is_container) {
			continue
		}
		tested++
		if !artifact.architecture_success {
			continue
		}
		archs := artifact.architecture_output
		if !archs.contains('arm64') && !archs.contains('x86_64') {
			audit.add('Artifacts architecture is no longer supported by macOS!', audit.cask.url.location, false)
			continue
		}
		if !archs.contains('arm64') && archs.contains('x86_64') {
			any_requires = true
		}
	}
	if tested == 0 {
		return
	}
	if any_requires && !mentions && !requires_intel {
		audit.add('At least one artifact requires Rosetta 2 but this is not indicated by the caveats!', audit.cask.url.location, false)
	} else if !any_requires && mentions {
		audit.add('No artifacts require Rosetta 2 but the caveats say otherwise!', audit.cask.url.location, false)
	}
}

fn (mut audit CaskAudit) audit_livecheck_version_check() string {
	if audit.livecheck_result != '' {
		return audit.livecheck_result
	}
	if !audit.online || !audit.cask.version_present {
		return ''
	}
	if audit.cask.livecheck.referenced_skip || audit.cask.livecheck.skip || audit.cask.deprecated || audit.cask.disabled || audit.cask.version_latest || audit.cask.url.unversioned {
		audit.livecheck_result = 'skip'
		return 'skip'
	}
	mut latest := ''
	if audit.cask.livecheck.result_available {
		throttled := audit.cask.livecheck.throttle || audit.cask.livecheck.throttle_days > 0 || audit.cask.livecheck.referenced_throttle || audit.cask.livecheck.referenced_throttle_days > 0
		latest = if throttled {
			audit.cask.livecheck.latest_throttled
		} else {
			audit.cask.livecheck.latest
		}
	}
	if latest != '' && audit.cask.version == latest {
		audit.livecheck_result = 'auto_detected'
		return 'auto_detected'
	}
	audit.add("Version '${audit.cask.version}' differs from '${latest}' retrieved by livecheck.", '', false)
	audit.livecheck_result = 'false'
	return 'false'
}

fn audit_max_os(left string, right string) string {
	if left == '' {
		return right
	}
	if right == '' {
		return left
	}
	return if audit_compare_versions(left, right) >= 0 { left } else { right }
}

fn (mut audit CaskAudit) audit_min_os_check() {
	if !audit.online {
		return
	}
	bundle := normalize_audit_min_os(audit.cask.bundle_min_os) or { '' }
	sparkle := normalize_audit_min_os(audit.cask.sparkle_min_os) or { '' }
	app_min := audit_max_os(bundle, sparkle)
	if app_min == '' || audit_compare_versions(app_min, audit.providers.oldest_allowed_macos) <= 0 {
		return
	}
	cask_min := audit_max_os(audit.cask.on_system_min_os, audit.cask.depends_on_min_os)
	if cask_min == app_min {
		return
	}
	if audit.providers.current_arch == 'arm' && audit.cask.on_system_blocks && cask_min != '' && audit_compare_versions(app_min, '11') < 0 && audit_compare_versions(app_min, cask_min) < 0 {
		return
	}
	mut definition := 'no minimum macOS version'
	if cask_min != '' && audit_compare_versions(cask_min, audit.providers.oldest_allowed_macos) > 0 {
		kind := if audit_compare_versions(audit.cask.on_system_min_os, audit.cask.depends_on_min_os) > 0 {
			'an on_system block'
		} else {
			'a depends_on stanza'
		}
		definition = '${kind} with a minimum macOS version of :${cask_min.replace('.', '_')}'
	}
	source := if audit_compare_versions(bundle, sparkle) > 0 { 'Artifact' } else { 'Upstream' }
	audit.add('${source} defined :${app_min.replace('.', '_')} as the minimum macOS version but the cask declared ${definition}', '', false)
}

fn audit_repo_key(host string, pair []string) string {
	return '${host}:${pair[0]}/${pair[1]}'
}

fn (mut audit CaskAudit) audit_prerelease(host string, label string) {
	if !audit.cask.url_present || !audit.online {
		return
	}
	pair := audit_repo_data(audit.cask, host) or { return }
	key := audit_repo_key(host, pair)
	if problem := audit.providers.repository_errors[key] {
		audit.add(problem, audit.cask.url.location, false)
	}
	_ = label
}

fn (mut audit CaskAudit) audit_repository_archived(host string, label string) {
	if audit.cask.deprecated || audit.cask.disabled || !audit.cask.url_present || !audit.online {
		return
	}
	pair := audit_repo_data(audit.cask, host) or { return }
	key := audit_repo_key(host, pair)
	if !audit.providers.repository_archived[key] {
		return
	}
	if host == 'codeberg.org' {
		audit.add('Forgejo repository is archived since ${audit.providers.repository_archived_at[key]}', audit.cask.url.location, false)
	} else {
		audit.add('${label} repo is archived', audit.cask.url.location, false)
	}
}

fn (mut audit CaskAudit) audit_repository(host string, label string) {
	if !audit.new_cask || !audit.cask.url_present {
		return
	}
	pair := audit_repo_data(audit.cask, host) or { return }
	key := audit_repo_key(host, pair)
	if problem := audit.providers.repository_errors[key] {
		audit.add(problem, audit.cask.url.location, false)
	}
	_ = label
}

fn (mut audit CaskAudit) audit_conflicts_with_check() {
	if !audit.cask.tap.official {
		return
	}
	for token in audit.cask.conflicting_casks {
		if token !in audit.cask.tap.cask_tokens {
			audit.add('cask conflicts with non-existing cask `${token}`', '', false)
		}
	}
}

fn (mut audit CaskAudit) audit_denylist_check() {
	if !audit.cask.tap.official {
		return
	}
	if reason := denylist_reason(audit.cask.token) {
		audit.add('${audit.cask.token} is not allowed: ${reason}', '', false)
	}
}

fn (mut audit CaskAudit) audit_reverse_migration() {
	if audit.new_cask && audit.cask.tap.official && audit.cask.token in audit.cask.tap.tap_migrations {
		audit.add('${audit.cask.token} is listed in tap_migrations.json', '', false)
	}
}

fn (mut audit CaskAudit) validate_https(value string, url_type string, location string) {
	problem := audit.providers.https_problems[value] or { '' }
	exception := value in audit.cask.tap.secure_skip_urls
	if problem != '' {
		if !exception { audit.add(problem, location, false) }
	} else if exception {
		audit.add('${value} is in the secure connection audit skiplist but does not need to be skipped', location, false)
	}
	_ = url_type
}

fn (mut audit CaskAudit) audit_homepage_https_availability() {
	if !audit.online || !audit.cask.homepage_present || (audit.cask.homepage_browsed_days_ago >= 0 && audit.cask.homepage_browsed_days_ago < 365) {
		return
	}
	audit.validate_https(audit.cask.homepage, 'homepage', '')
}

fn (mut audit CaskAudit) audit_url_https_availability() {
	if !audit.online || !audit.cask.url_present || audit.cask.url.using != '' {
		return
	}
	audit.validate_https(audit.cask.url.value, 'binary URL', audit.cask.url.location)
}

fn (mut audit CaskAudit) audit_livecheck_https_availability() {
	livecheck := audit.cask.livecheck
	if !audit.online || !livecheck.defined || livecheck.url == '' || livecheck.url_symbol || livecheck.post_form || livecheck.post_json {
		return
	}
	if livecheck.url.starts_with('https:') && audit.audit_livecheck_version_check() != 'false' {
		return
	}
	audit.validate_https(livecheck.url, 'livecheck URL', '')
}

fn (mut audit CaskAudit) audit_cask_path_check() {
	if !audit.cask.tap.core_cask {
		return
	}
	expected := audit.cask.tap.expected_cask_path
	if !audit.cask.sourcefile_path.ends_with(expected) {
		audit.add("Cask should be located in '${expected}'", '', false)
	}
}

fn (mut audit CaskAudit) audit_deprecate_disable() {
	if audit.providers.deprecate_disable_error != '' {
		audit.add(audit.providers.deprecate_disable_error, '', false)
	}
}

pub fn (audit CaskAudit) cask_sparkle_minimum_os() ?string {
	if !audit.online || !audit.cask.livecheck.defined || audit.cask.livecheck.strategy != 'sparkle' || audit.cask.livecheck.strategy_block_uses_items {
		return none
	}
	value := if audit.cask.livecheck.minimum_os != '' {
		audit.cask.livecheck.minimum_os
	} else {
		audit.cask.sparkle_min_os
	}
	return normalize_audit_min_os(value)
}

pub fn (audit CaskAudit) cask_bundle_minimum_os() ?string {
	if !audit.online {
		return none
	}
	if value := normalize_audit_min_os(audit.cask.bundle_min_os) {
		return value
	}
	mut detected := ''
	for artifact in audit_extractable_artifacts(audit.cask, false) {
		if artifact.kind == 'installer' {
			continue
		}
		detected = audit_max_os(detected, artifact.minimum_os)
		if detected != '' {
			break
		}
	}
	return normalize_audit_min_os(detected)
}

pub fn (audit CaskAudit) plist_main_binary(path string) ?string {
	if !audit.online {
		return none
	}
	plist_path := os.join_path(path, 'Contents', 'Info.plist')
	if !audit.providers.file_exists[plist_path] {
		return none
	}
	binary := audit.providers.plist_executables[plist_path] or { return none }
	if binary == '' {
		return none
	}
	binary_path := os.join_path(path, 'Contents', 'MacOS', binary)
	if audit.providers.file_exists[binary_path] && audit.providers.file_executable[binary_path] {
		return binary_path
	}
	return none
}

pub fn (audit CaskAudit) self_submission(repo_owner string) bool {
	return repo_owner != '' && repo_owner in audit.providers.self_submission_owners
}

pub fn (audit CaskAudit) core_formula_url() string {
	formula_path := audit.providers.formula_path.trim_string_left(audit.cask.tap.path)
	return '${audit.cask.tap.default_remote}/blob/HEAD${formula_path}'
}

const cask_audit_names = [
	'untrusted_pkg',
	'stanza_requires_uninstall',
	'single_pre_postflight',
	'single_uninstall_zap',
	'required_stanzas',
	'description',
	'version_special_characters',
	'no_string_version_latest',
	'sha256_no_check_if_latest',
	'sha256_no_check_if_unversioned',
	'sha256_actually_256',
	'sha256_invalid',
	'latest_with_livecheck',
	'latest_with_auto_updates',
	'hosting_with_livecheck',
	'download_url_format',
	'download_url_is_osdn',
	'unnecessary_verified',
	'generic_artifacts',
	'languages',
	'token',
	'token_conflicts',
	'token_bad_words',
	'download',
	'livecheck_unneeded_long_version',
	'signing',
	'artifact_case',
	'rosetta',
	'livecheck_version',
	'min_os',
	'github_prerelease_version',
	'gitlab_prerelease_version',
	'forgejo_prerelease_version',
	'github_repository_archived',
	'gitlab_repository_archived',
	'forgejo_repository_archived',
	'github_repository',
	'gitlab_repository',
	'bitbucket_repository',
	'forgejo_repository',
	'conflicts_with',
	'denylist',
	'reverse_migration',
	'homepage_https_availability',
	'url_https_availability',
	'livecheck_https_availability',
	'cask_path',
	'deprecate_disable',
]

pub fn (mut audit CaskAudit) run_one(name string) {
	match name {
		'untrusted_pkg' { audit.audit_untrusted_pkg() }
		'stanza_requires_uninstall' { audit.audit_stanza_requires_uninstall() }
		'single_pre_postflight' { audit.audit_single_pre_postflight() }
		'single_uninstall_zap' { audit.audit_single_uninstall_zap() }
		'required_stanzas' { audit.audit_required_stanzas() }
		'description' { audit.audit_description() }
		'version_special_characters' { audit.audit_version_special_characters() }
		'no_string_version_latest' { audit.audit_no_string_version_latest() }
		'sha256_no_check_if_latest' { audit.audit_sha256_no_check_if_latest() }
		'sha256_no_check_if_unversioned' { audit.audit_sha256_no_check_if_unversioned() }
		'sha256_actually_256' { audit.audit_sha256_actually_256() }
		'sha256_invalid' { audit.audit_sha256_invalid() }
		'latest_with_livecheck' { audit.audit_latest_with_livecheck() }
		'latest_with_auto_updates' { audit.audit_latest_with_auto_updates() }
		'hosting_with_livecheck' { audit.audit_hosting_with_livecheck() }
		'download_url_format' { audit.audit_download_url_format() }
		'download_url_is_osdn' { audit.audit_download_url_is_osdn() }
		'unnecessary_verified' { audit.audit_unnecessary_verified() }
		'generic_artifacts' { audit.audit_generic_artifacts() }
		'languages' { audit.audit_languages() }
		'token' { audit.audit_token() }
		'token_conflicts' { audit.audit_token_conflicts() }
		'token_bad_words' { audit.audit_token_bad_words() }
		'download' { audit.audit_download_fetch() }
		'livecheck_unneeded_long_version' { audit.audit_livecheck_unneeded_long_version() }
		'signing' { audit.audit_signing_check() }
		'artifact_case' { audit.audit_artifact_case_check() }
		'rosetta' { audit.audit_rosetta_check() }
		'livecheck_version' { audit.audit_livecheck_version_check() }
		'min_os' { audit.audit_min_os_check() }
		'github_prerelease_version' { audit.audit_prerelease('github.com', 'GitHub') }
		'gitlab_prerelease_version' { audit.audit_prerelease('gitlab.com', 'GitLab') }
		'forgejo_prerelease_version' { audit.audit_prerelease('codeberg.org', 'Forgejo') }
		'github_repository_archived' { audit.audit_repository_archived('github.com', 'GitHub') }
		'gitlab_repository_archived' { audit.audit_repository_archived('gitlab.com', 'GitLab') }
		'forgejo_repository_archived' { audit.audit_repository_archived('codeberg.org', 'Forgejo') }
		'github_repository' { audit.audit_repository('github.com', 'GitHub') }
		'gitlab_repository' { audit.audit_repository('gitlab.com', 'GitLab') }
		'bitbucket_repository' { audit.audit_repository('bitbucket.org', 'Bitbucket') }
		'forgejo_repository' { audit.audit_repository('codeberg.org', 'Forgejo') }
		'conflicts_with' { audit.audit_conflicts_with_check() }
		'denylist' { audit.audit_denylist_check() }
		'reverse_migration' { audit.audit_reverse_migration() }
		'homepage_https_availability' { audit.audit_homepage_https_availability() }
		'url_https_availability' { audit.audit_url_https_availability() }
		'livecheck_https_availability' { audit.audit_livecheck_https_availability() }
		'cask_path' { audit.audit_cask_path_check() }
		'deprecate_disable' { audit.audit_deprecate_disable() }
		else {}
	}
}

pub fn (mut audit CaskAudit) run() {
	for name in cask_audit_names {
		if audit.only.len > 0 && name !in audit.only {
			continue
		}
		if name in audit.except {
			continue
		}
		if failure := audit.providers.audit_failures[name] {
			audit.add('exception while auditing ${audit.cask.token}: ${failure}', '', false)
			return
		}
		audit.run_one(name)
	}
}

fn audit_nil_value() ruby.Value {
	return ruby.object_value('Nil', '')
}

fn audit_cask_boundary(cask AuditCask) ruby.Value {
	return ruby.map_value({
		'token':            ruby.string_value(cask.token)
		'version':          ruby.string_value(cask.version)
		'version_present':  ruby.bool_value(cask.version_present)
		'version_latest':   ruby.bool_value(cask.version_latest)
		'sha256':           ruby.string_value(cask.sha256)
		'sha256_present':   ruby.bool_value(cask.sha256_present)
		'sha256_no_check':  ruby.bool_value(cask.sha256_no_check)
		'url':              ruby.string_value(cask.url.value)
		'url_present':      ruby.bool_value(cask.url_present)
		'homepage':         ruby.string_value(cask.homepage)
		'homepage_present': ruby.bool_value(cask.homepage_present)
		'names':            ruby.string_array_value(cask.names)
		'description':      ruby.string_value(cask.description)
		'languages':        ruby.string_array_value(cask.languages)
		'auto_updates':     ruby.bool_value(cask.auto_updates)
		'deprecated':       ruby.bool_value(cask.deprecated)
		'disabled':         ruby.bool_value(cask.disabled)
	})
}

fn audit_map_string(values map[string]ruby.Value, key string, fallback string) string {
	return if value := values[key] { value.as_string() } else { fallback }
}

fn audit_map_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	return if value := values[key] { value.as_bool() or { fallback } } else { fallback }
}

fn audit_map_strings(values map[string]ruby.Value, key string) []string {
	return if value := values[key] { value.as_string_array() or { []string{} } } else { []string{} }
}

fn audit_cask_from_value(value ruby.Value) AuditCask {
	values := value.as_map() or {
		return AuditCask{
			token: value.as_string()
			url_present: false
			homepage_present: false
			version_present: false
			sha256_present: false
		}
	}
	url_value := audit_map_string(values, 'url', '')
	return AuditCask{
		token: audit_map_string(values, 'token', '')
		version: audit_map_string(values, 'version', '')
		version_present: audit_map_bool(values, 'version_present', values['version'] != ruby.Value{})
		version_latest: audit_map_bool(values, 'version_latest', false)
		sha256: audit_map_string(values, 'sha256', '')
		sha256_present: audit_map_bool(values, 'sha256_present', values['sha256'] != ruby.Value{})
		sha256_no_check: audit_map_bool(values, 'sha256_no_check', false)
		url: AuditUrl{
			value: url_value
			location: audit_map_string(values, 'url_location', '')
			verified: audit_map_string(values, 'verified', '')
			unversioned: audit_map_bool(values, 'url_unversioned', false)
		}
		url_present: audit_map_bool(values, 'url_present', url_value != '')
		homepage: audit_map_string(values, 'homepage', '')
		homepage_present: audit_map_bool(values, 'homepage_present', values['homepage'] != ruby.Value{})
		names: audit_map_strings(values, 'names')
		description: audit_map_string(values, 'description', '')
		languages: audit_map_strings(values, 'languages')
		auto_updates: audit_map_bool(values, 'auto_updates', false)
		deprecated: audit_map_bool(values, 'deprecated', false)
		disabled: audit_map_bool(values, 'disabled', false)
		installable_artifact: audit_map_bool(values, 'installable_artifact', false)
		tap: AuditTap{
			name: audit_map_string(values, 'tap_name', '')
			user: audit_map_string(values, 'tap_user', '')
			official: audit_map_bool(values, 'tap_official', false)
			formula_names: audit_map_strings(values, 'formula_names')
			cask_tokens: audit_map_strings(values, 'cask_tokens')
			tap_migrations: audit_map_strings(values, 'tap_migrations')
		}
	}
}

fn audit_options_from_value(value ruby.Value) AuditOptions {
	values := value.as_map() or { return AuditOptions{} }
	mut online := ?bool(none)
	mut strict := ?bool(none)
	mut signing := ?bool(none)
	mut new_cask := ?bool(none)
	if item := values['online'] {
		online = item.as_bool() or { false }
	}
	if item := values['strict'] {
		strict = item.as_bool() or { false }
	}
	if item := values['signing'] {
		signing = item.as_bool() or { false }
	}
	if item := values['new_cask'] {
		new_cask = item.as_bool() or { false }
	}
	return AuditOptions{
		download: audit_map_bool(values, 'download', false)
		online: online
		strict: strict
		signing: signing
		new_cask: new_cask
		only: audit_map_strings(values, 'only')
		except: audit_map_strings(values, 'except')
	}
}

fn audit_boundary_value(audit CaskAudit) ruby.Value {
	return ruby.map_value({
		'cask':             audit_cask_boundary(audit.cask)
		'download':         ruby.bool_value(audit.download)
		'online':           ruby.bool_value(audit.online)
		'strict':           ruby.bool_value(audit.strict)
		'signing':          ruby.bool_value(audit.signing)
		'new_cask':         ruby.bool_value(audit.new_cask)
		'only':             ruby.string_array_value(audit.only)
		'except':           ruby.string_array_value(audit.except)
		'errors':           ruby.array_value(audit.errors.map(ruby.map_value({
			'message':   ruby.string_value(it.message)
			'location':  ruby.string_value(it.location)
			'corrected': ruby.bool_value(it.corrected)
		})))
		'livecheck_result': ruby.string_value(audit.livecheck_result)
		'operations':       ruby.string_array_value(audit.operations)
	})
}

fn audit_from_value(value ruby.Value) CaskAudit {
	values := value.as_map() or {
		return new_cask_audit(audit_cask_from_value(value), AuditOptions{}, AuditCollaborators{})
	}
	cask_value := values['cask'] or { value }
	mut audit := new_cask_audit(audit_cask_from_value(cask_value), audit_options_from_value(value), AuditCollaborators{})
	if error_values := values['errors'] {
		for error_value in error_values.as_array() or { []ruby.Value{} } {
			error_map := error_value.as_map() or { continue }
			audit.errors << AuditError{
				message: audit_map_string(error_map, 'message', '')
				location: audit_map_string(error_map, 'location', '')
			}
		}
	}
	audit.livecheck_result = audit_map_string(values, 'livecheck_result', '')
	return audit
}

fn audit_from_args(args []ruby.Value) CaskAudit {
	if args.len > 0 && args[0].type_name == 'Hash' {
		values := args[0].as_map() or { map[string]ruby.Value{} }
		if 'cask' in values {
			return audit_from_value(args[0])
		}
	}
	cask := if args.len > 0 { audit_cask_from_value(args[0]) } else { AuditCask{} }
	options := if args.len > 1 { audit_options_from_value(args[1]) } else { AuditOptions{} }
	return new_cask_audit(cask, options, AuditCollaborators{})
}

fn audit_method_boundary(name string, args []ruby.Value) ruby.Value {
	mut audit := audit_from_args(args)
	match name {
		'cask' {
			return audit_cask_boundary(audit.cask)
		}
		'download' {
			return ruby.bool_value(audit.download)
		}
		'livecheck_result=' {
			audit.livecheck_result = if args.len > 1 { args[1].as_string() } else { '' }
			return audit_boundary_value(audit)
		}
		'initialize' {
			return audit_boundary_value(audit)
		}
		'new_cask?' {
			return ruby.bool_value(audit.new_cask)
		}
		'online?' {
			return ruby.bool_value(audit.online)
		}
		'signing?' {
			return ruby.bool_value(audit.signing)
		}
		'strict?' {
			return ruby.bool_value(audit.strict)
		}
		'run!' {
			audit.run()
			return audit_boundary_value(audit)
		}
		'errors' {
			return ruby.array_value(audit.errors.map(ruby.string_value(it.message)))
		}
		'errors?' {
			return ruby.bool_value(audit.errors_present())
		}
		'success?' {
			return ruby.bool_value(audit.success())
		}
		'add_error' {
			message := if args.len > 1 { args[1].as_string() } else { '' }
			location := if args.len > 2 { args[2].as_string() } else { '' }
			strict_only := if args.len > 3 { args[3].as_bool() or { false } } else { false }
			audit.add(message, location, strict_only)
			return audit_boundary_value(audit)
		}
		'result' {
			return if value := audit.result_text() {
				ruby.string_value(value)
			} else {
				audit_nil_value()
			}
		}
		'summary' {
			return if value := audit.summary_text() {
				ruby.string_value(value)
			} else {
				audit_nil_value()
			}
		}
		'extract_artifacts' {
			manual := if args.len > 1 { args[1].as_bool() or { false } } else { false }
			return ruby.string_array_value(audit.extract_artifacts(manual).map(it.source))
		}
		'normalize_min_os' {
			value := if args.len > 0 { args.last().as_string() } else { '' }
			return if normalized := normalize_audit_min_os(value) {
				ruby.string_value(normalized)
			} else {
				audit_nil_value()
			}
		}
		'audit_livecheck_version' {
			return ruby.string_value(audit.audit_livecheck_version_check())
		}
		'cask_sparkle_min_os' {
			return if value := audit.cask_sparkle_minimum_os() {
				ruby.string_value(value)
			} else {
				audit_nil_value()
			}
		}
		'cask_bundle_min_os' {
			return if value := audit.cask_bundle_minimum_os() {
				ruby.string_value(value)
			} else {
				audit_nil_value()
			}
		}
		'get_plist_main_binary' {
			path := if args.len > 1 { args[1].as_string() } else { '' }
			return if value := audit.plist_main_binary(path) {
				ruby.string_value(value)
			} else {
				audit_nil_value()
			}
		}
		'validate_url_for_https_availability' {
			value := if args.len > 1 { args[1].as_string() } else { '' }
			kind := if args.len > 2 { args[2].as_string() } else { '' }
			location := if args.len > 3 { args[3].as_string() } else { '' }
			audit.validate_https(value, kind, location)
			return audit_boundary_value(audit)
		}
		'get_repo_data' {
			host := if args.len > 1 { args[1].as_string() } else { 'github.com' }
			return if pair := audit_repo_data(audit.cask, host) {
				ruby.string_array_value(pair)
			} else {
				audit_nil_value()
			}
		}
		'self_submission?' {
			owner := if args.len > 1 { args[1].as_string() } else { '' }
			return ruby.bool_value(audit.self_submission(owner))
		}
		'bad_url_format?' {
			regex_matches := if args.len > 1 {
				args[1].as_bool() or { false }
			} else {
				audit.cask.url.value.contains('sourceforge')
			}
			mut valid_matches := []bool{}
			if args.len > 2 {
				for value in args[2].as_array() or { []ruby.Value{} } {
					valid_matches << (value.as_bool() or { false })
				}
			}
			return ruby.bool_value(audit_bad_url_format(regex_matches, valid_matches))
		}
		'bad_sourceforge_url?' {
			return ruby.bool_value(audit_bad_sourceforge_url(audit.cask.url.value))
		}
		'bad_osdn_url?' {
			host := audit_url_host(audit.cask.url.value)
			return ruby.bool_value(host == 'osdn.jp' || host.ends_with('.osdn.jp'))
		}
		'domain' {
			return ruby.string_value(audit_url_host(audit.cask.url.value))
		}
		'verified_present?' {
			return ruby.bool_value(audit.cask.url.verified.trim_space() != '')
		}
		'core_tap' {
			return ruby.structured_value('Tap', audit.cask.tap.name, {
				'name': audit.cask.tap.name
			})
		}
		'core_formula_names' {
			return ruby.string_array_value(audit.cask.tap.formula_names)
		}
		'core_cask_tap' {
			return ruby.structured_value('Tap', audit.cask.tap.name, {
				'name': audit.cask.tap.name
			})
		}
		'core_cask_tokens' {
			return ruby.string_array_value(audit.cask.tap.cask_tokens)
		}
		'core_formula_url' {
			return ruby.string_value(audit.core_formula_url())
		}
		else {
			audit.run_one(name.trim_string_left('audit_'))
			return audit_boundary_value(audit)
		}
	}
}

// Translated from Homebrew/brew `cask/audit.rb`.
