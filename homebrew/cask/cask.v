module cask

import crypto.sha256
import ruby
import homebrew
import homebrew.cask.dsl as dsl_types
import os

// Translated from Homebrew/brew `cask/cask.rb`.
// The original source is retained below until every stub has a typed V body.
const cask_hash_keys_to_skip = ['outdated', 'installed', 'pinned', 'pinned_version', 'versions']
const cask_auto_updates_bad_bundle_versions = ['0', '0.0']

pub type CaskBlock = fn(mut CaskDSL) !

pub struct CaskCoreConfig {
pub:
	token                    string
	sourcefile_path          string
	source                   string
	tap_name                 string
	tap_path                 string
	tap_core                 bool
	tap_official             bool
	tap_git_head             string
	loaded_from_api          bool
	loaded_from_internal_api bool
	api_source               map[string]ruby.Value
	config                   CaskConfig
	has_config               bool
	allow_reassignment       bool
	loader                   ruby.Value
	caskroom_root            string
	pinned_root              string
	system_os                string
	system_arch              string
	valid_tags               []homebrew.BottleTag
}

pub struct CaskCore {
pub mut:
	token                          string
	config                         CaskConfig
	default_config                 CaskConfig
	sourcefile_path                string
	source                         string
	tap_name                       string
	tap_path                       string
	tap_core                       bool
	tap_official                   bool
	loaded_from_api                bool
	loaded_from_internal_api       bool
	api_source                     map[string]ruby.Value
	loader                         ruby.Value
	download                       string
	allow_reassignment             bool
	dsl                            CaskDSL
	block                          CaskBlock = cask_noop_block
	caskroom_root                  string
	pinned_root                    string
	system_os                      string
	system_arch                    string
	valid_tags                     []homebrew.BottleTag
	tap_git_head_value             string
	tap_migration_oldnames         []string
	tap_reverse_renames            []string
	language_variations_available  bool
	api_languages                  []string
	api_language_results           map[string]string
	ruby_source_path_value         string
	ruby_source_checksum_value     string
	installed_file_override        string
	installed_version_override     string
	has_installed_version_override bool
	new_download_sha_value         string
	upgrade_auto_updates_casks     bool
	bundle_short_override          string
	has_bundle_short_override      bool
	bundle_long_override           string
	has_bundle_long_override       bool
	generating_hash                bool
}

pub struct CaskOutdatedOptions {
pub:
	greedy              bool
	greedy_latest       bool
	greedy_auto_updates bool
}

pub struct CaskBundleVersion {
pub:
	short_version string
	version       string
}

fn cask_noop_block(mut dsl CaskDSL) ! {
	_ = dsl
}

fn cask_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn cask_optional_string(value string, type_name string) ruby.Value {
	return if value == '' { cask_nil() } else { ruby.object_value(type_name, value) }
}

fn cask_default_root(environment_key string, fallback string) string {
	configured := ruby.environment_value(environment_key)
	return if configured == '' { fallback } else { configured }
}

fn cask_default_tags() []homebrew.BottleTag {
	return [
		homebrew.new_bottle_tag('golden_gate', 'x86_64'),
		homebrew.new_bottle_tag('golden_gate', 'arm64'),
		homebrew.new_bottle_tag('tahoe', 'x86_64'),
		homebrew.new_bottle_tag('tahoe', 'arm64'),
		homebrew.new_bottle_tag('sequoia', 'x86_64'),
		homebrew.new_bottle_tag('sequoia', 'arm64'),
		homebrew.new_bottle_tag('sonoma', 'x86_64'),
		homebrew.new_bottle_tag('sonoma', 'arm64'),
		homebrew.new_bottle_tag('ventura', 'x86_64'),
		homebrew.new_bottle_tag('ventura', 'arm64'),
		homebrew.new_bottle_tag('monterey', 'x86_64'),
		homebrew.new_bottle_tag('monterey', 'arm64'),
		homebrew.new_bottle_tag('big_sur', 'x86_64'),
		homebrew.new_bottle_tag('big_sur', 'arm64'),
		homebrew.new_bottle_tag('catalina', 'x86_64'),
		homebrew.new_bottle_tag('linux', 'x86_64'),
		homebrew.new_bottle_tag('linux', 'arm64'),
	]
}

fn cask_config_dsl_value(config CaskConfig) ruby.Value {
	appdir := config.directory('appdir') or { '' }
	return ruby.map_value({
		'languages': ruby.string_array_value(config.languages())
		'appdir':    ruby.object_value('Pathname', appdir)
	})
}

pub fn cask_core_value(cask CaskCore) ruby.Value {
	mut api_source := cask_nil()
	if cask.api_source.len > 0 {
		api_source = ruby.map_value(cask.api_source)
	}
	mut values := {
		'token':                          ruby.string_value(cask.token)
		'config':                         cask_config_boundary(cask.config)
		'default_config':                 cask_config_boundary(cask.default_config)
		'config_dsl':                     cask_config_dsl_value(cask.config)
		'sourcefile_path':                cask_optional_string(cask.sourcefile_path, 'Pathname')
		'source':                         cask_optional_string(cask.source, 'String')
		'tap_name':                       cask_optional_string(cask.tap_name, 'String')
		'tap_path':                       cask_optional_string(cask.tap_path, 'Pathname')
		'tap_core':                       ruby.bool_value(cask.tap_core)
		'tap_official':                   ruby.bool_value(cask.tap_official)
		'loaded_from_api':                ruby.bool_value(cask.loaded_from_api)
		'loaded_from_internal_api':       ruby.bool_value(cask.loaded_from_internal_api)
		'api_source':                     api_source
		'loader':                         cask.loader
		'download':                       cask_optional_string(cask.download, 'Pathname')
		'allow_reassignment':             ruby.bool_value(cask.allow_reassignment)
		'dsl':                            cask_dsl_value(cask.dsl)
		'caskroom_path':                  ruby.object_value('Pathname', cask.caskroom_path())
		'caskroom_root':                  ruby.object_value('Pathname', cask.caskroom_root)
		'pinned_root':                    ruby.object_value('Pathname', cask.pinned_root)
		'system_os':                      ruby.Value{ type_name: 'Symbol', repr: cask.system_os }
		'system_arch':                    ruby.Value{ type_name: 'Symbol', repr: cask.system_arch }
		'tap_git_head':                   cask_optional_string(cask.tap_git_head_value, 'String')
		'tap_migration_oldnames':         ruby.string_array_value(cask.tap_migration_oldnames)
		'tap_reverse_renames':            ruby.string_array_value(cask.tap_reverse_renames)
		'language_variations_available':  ruby.bool_value(cask.language_variations_available)
		'api_languages':                  ruby.string_array_value(cask.api_languages)
		'ruby_source_path_value':         cask_optional_string(cask.ruby_source_path_value, 'String')
		'ruby_source_checksum_value':     cask_optional_string(cask.ruby_source_checksum_value, 'String')
		'installed_file_override':        cask_optional_string(cask.installed_file_override, 'Pathname')
		'installed_version_override':     cask_optional_string(cask.installed_version_override, 'String')
		'has_installed_version_override': ruby.bool_value(cask.has_installed_version_override)
		'new_download_sha':               cask_optional_string(cask.new_download_sha_value, 'String')
		'upgrade_auto_updates_casks':     ruby.bool_value(cask.upgrade_auto_updates_casks)
		'bundle_short_override':          cask_optional_string(cask.bundle_short_override, 'String')
		'has_bundle_short_override':      ruby.bool_value(cask.has_bundle_short_override)
		'bundle_long_override':           cask_optional_string(cask.bundle_long_override, 'String')
		'has_bundle_long_override':       ruby.bool_value(cask.has_bundle_long_override)
		'generating_hash':                ruby.bool_value(cask.generating_hash)
	}
	mut language_results := map[string]ruby.Value{}
	for key, value in cask.api_language_results {
		language_results[key] = ruby.string_value(value)
	}
	values['api_language_results'] = ruby.map_value(language_results)
	values['valid_tags'] = ruby.array_value(cask.valid_tags.map(ruby.structured_value('Utils::Bottles::Tag', it.symbol(), {
		'system': it.system
		'arch':   it.arch
	})))
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: cask.token
		map_data: values
	}
}

fn cask_value_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	value := values[key] or { return fallback }
	return value.as_bool() or { fallback }
}

fn cask_value_string(values map[string]ruby.Value, key string) string {
	value := values[key] or { return '' }
	return if value.type_name == 'NilClass' { '' } else { value.as_string() }
}

pub fn cask_core_from_value(value ruby.Value) !CaskCore {
	if value.type_name != 'Cask::Cask' {
		return error('expected Cask::Cask, got ${value.type_name}')
	}
	values := value.map_data.clone()
	config_value := values['config'] or { cask_nil() }
	config := if config_value.type_name == 'Cask::Config' {
		cask_config_from_boundary(config_value)
	} else {
		new_cask_config(CaskConfigOptions{})!
	}
	mut tags := []homebrew.BottleTag{}
	for raw in (values['valid_tags'] or { ruby.array_value([]) }).as_array() or { []ruby.Value{} } {
		tags << homebrew.new_bottle_tag(raw.attributes['system'] or { 'linux' }, raw.attributes['arch'] or { 'x86_64' })
	}
	mut core := new_cask_core(CaskCoreConfig{
		token: cask_value_string(values, 'token')
		sourcefile_path: cask_value_string(values, 'sourcefile_path')
		source: cask_value_string(values, 'source')
		tap_name: cask_value_string(values, 'tap_name')
		tap_path: cask_value_string(values, 'tap_path')
		tap_core: cask_value_bool(values, 'tap_core', false)
		tap_official: cask_value_bool(values, 'tap_official', false)
		tap_git_head: cask_value_string(values, 'tap_git_head')
		loaded_from_api: cask_value_bool(values, 'loaded_from_api', false)
		loaded_from_internal_api: cask_value_bool(values, 'loaded_from_internal_api', false)
		api_source: (values['api_source'] or { ruby.map_value({}) }).map_data.clone()
		config: config
		has_config: true
		allow_reassignment: cask_value_bool(values, 'allow_reassignment', false)
		loader: values['loader'] or { cask_nil() }
		caskroom_root: cask_value_string(values, 'caskroom_root')
		pinned_root: cask_value_string(values, 'pinned_root')
		system_os: cask_value_string(values, 'system_os')
		system_arch: cask_value_string(values, 'system_arch')
		valid_tags: tags
	}, cask_noop_block)!
	if raw := values['default_config'] {
		if raw.type_name == 'Cask::Config' {
			core.default_config = cask_config_from_boundary(raw)
		}
	}
	if raw := values['dsl'] {
		core.dsl = cask_dsl_from_value(raw)!
	}
	core.download = cask_value_string(values, 'download')
	core.tap_migration_oldnames = (values['tap_migration_oldnames'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
	core.tap_reverse_renames = (values['tap_reverse_renames'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
	core.language_variations_available = cask_value_bool(values, 'language_variations_available', false)
	core.api_languages = (values['api_languages'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
	for key, result in (values['api_language_results'] or { ruby.map_value({}) }).map_data {
		core.api_language_results[key] = result.as_string()
	}
	core.ruby_source_path_value = cask_value_string(values, 'ruby_source_path_value')
	core.ruby_source_checksum_value = cask_value_string(values, 'ruby_source_checksum_value')
	core.installed_file_override = cask_value_string(values, 'installed_file_override')
	core.installed_version_override = cask_value_string(values, 'installed_version_override')
	core.has_installed_version_override = cask_value_bool(values, 'has_installed_version_override', false)
	core.new_download_sha_value = cask_value_string(values, 'new_download_sha')
	core.upgrade_auto_updates_casks = cask_value_bool(values, 'upgrade_auto_updates_casks', false)
	core.bundle_short_override = cask_value_string(values, 'bundle_short_override')
	core.has_bundle_short_override = cask_value_bool(values, 'has_bundle_short_override', false)
	core.bundle_long_override = cask_value_string(values, 'bundle_long_override')
	core.has_bundle_long_override = cask_value_bool(values, 'has_bundle_long_override', false)
	core.generating_hash = cask_value_bool(values, 'generating_hash', false)
	return core
}

pub fn new_cask_core(options CaskCoreConfig, block CaskBlock) !CaskCore {
	default_config := if options.has_config {
		options.config
	} else {
		new_cask_config(CaskConfigOptions{})!
	}
	mut config := default_config
	caskroom_root := if options.caskroom_root == '' {
		cask_default_root('HOMEBREW_CASKROOM', '/opt/homebrew/Caskroom')
	} else {
		options.caskroom_root
	}
	pinned_root := if options.pinned_root == '' {
		cask_default_root('HOMEBREW_PINNED_CASKS', '/opt/homebrew/var/homebrew/pinned_casks')
	} else {
		options.pinned_root
	}
	config_path := os.join_path(caskroom_root, options.token, '.metadata', 'config.json')
	if os.exists(config_path) {
		contents := os.read_file(config_path)!
		config = cask_config_from_json(contents, true)!
	}
	seed := ruby.Value{
		type_name: 'Cask::Cask'
		repr: options.token
		map_data: {
			'token':              ruby.string_value(options.token)
			'allow_reassignment': ruby.bool_value(options.allow_reassignment)
			'config':             cask_config_dsl_value(config)
			'caskroom_path':      ruby.object_value('Pathname', os.join_path(caskroom_root, options.token))
		}
	}
	mut cask := CaskCore{
		token: options.token
		config: config
		default_config: default_config
		sourcefile_path: options.sourcefile_path
		source: options.source
		tap_name: options.tap_name
		tap_path: options.tap_path
		tap_core: options.tap_core
		tap_official: options.tap_official
		loaded_from_api: options.loaded_from_api
		loaded_from_internal_api: options.loaded_from_internal_api
		api_source: options.api_source.clone()
		loader: options.loader
		allow_reassignment: options.allow_reassignment
		dsl: new_cask_dsl(seed)
		block: block
		caskroom_root: caskroom_root
		pinned_root: pinned_root
		system_os: if options.system_os == '' { 'macos' } else { options.system_os }
		system_arch: if options.system_arch == '' { 'intel' } else { options.system_arch }
		valid_tags: if options.valid_tags.len == 0 {
			cask_default_tags()} else {
			options.valid_tags.clone()}
		tap_git_head_value: options.tap_git_head
	}
	cask.refresh()!
	return cask
}

pub fn (mut cask CaskCore) refresh() ! {
	boundary := cask_core_value(cask)
	mut receiver_values := boundary.map_data.clone()
	receiver_values['config'] = cask_config_dsl_value(cask.config)
	receiver_values['system_os'] = ruby.Value{ type_name: 'Symbol', repr: cask.system_os }
	receiver_values['system_arch'] = ruby.Value{ type_name: 'Symbol', repr: cask.system_arch }
	receiver := ruby.Value{
		...boundary
		map_data: receiver_values
	}
	mut dsl := new_cask_dsl(receiver)
	cask.block(mut dsl)!
	if dsl.language_blocks.len > 0 {
		cask_dsl_evaluate_language(mut dsl)!
	}
	cask.dsl = dsl
}

pub fn (mut cask CaskCore) set_config(config CaskConfig) ! {
	cask.config = config
	cask.refresh()!
}

pub fn (cask CaskCore) old_tokens() []string {
	if cask.tap_name == '' {
		return []string{}
	}
	mut result := cask.tap_migration_oldnames.clone()
	for token in cask.tap_reverse_renames {
		if token !in result {
			result << token
		}
	}
	return result
}

pub fn (cask CaskCore) full_token() string {
	if cask.tap_name == '' || cask.tap_core {
		return cask.token
	}
	return '${cask.tap_name}/${cask.token}'
}

pub fn (cask CaskCore) caskroom_path() string {
	return os.join_path(cask.caskroom_root, cask.token)
}

pub fn (cask CaskCore) metadata_main_container_path() string {
	return os.join_path(cask.caskroom_path(), '.metadata')
}

pub fn (cask CaskCore) version_text() string {
	return if cask.dsl.has_version { cask.dsl.version_value.text } else { '' }
}

pub fn (cask CaskCore) timestamped_versions(root string) [][]string {
	metadata := os.join_path(root, '.metadata')
	mut pairs := [][]string{}
	for version in os.ls(metadata) or { return pairs } {
		version_path := os.join_path(metadata, version)
		if !os.is_dir(version_path) {
			continue
		}
		for timestamp in os.ls(version_path) or { continue } {
			if os.is_dir(os.join_path(version_path, timestamp)) {
				pairs << [version, timestamp]
			}
		}
	}
	pairs.sort_with_compare(fn (left &[]string, right &[]string) int {
		by_timestamp := left[1].compare(right[1])
		if by_timestamp != 0 {
			return by_timestamp
		}
		return left[0].compare(right[0])
	})
	return pairs
}

fn (cask CaskCore) installed_candidates() []string {
	mut names := [cask.token]
	names << cask.old_tokens()
	mut paths := []string{}
	for pair in cask.timestamped_versions(cask.caskroom_path()) {
		casks_dir := os.join_path(cask.metadata_main_container_path(), pair[0], pair[1], 'Casks')
		for name in names {
			for extension in ['rb', 'json'] {
				path := os.join_path(casks_dir, '${name}.${extension}')
				if os.exists(path) {
					paths << path
				}
			}
		}
	}
	return paths
}

pub fn (cask CaskCore) installed_caskfile() string {
	if cask.installed_file_override != '' {
		return cask.installed_file_override
	}
	paths := cask.installed_candidates()
	return if paths.len == 0 { '' } else { paths.last() }
}

pub fn (cask CaskCore) installed_version() string {
	if cask.has_installed_version_override {
		return cask.installed_version_override
	}
	path := cask.installed_caskfile()
	if path == '' {
		return ''
	}
	return os.base(os.dir(os.dir(os.dir(path))))
}

pub fn (cask CaskCore) installed() bool {
	path := cask.installed_caskfile()
	return path != '' && os.exists(path)
}

pub fn (cask CaskCore) pin_path() string {
	return os.join_path(cask.pinned_root, cask.token)
}

fn cask_resolved_link(path string) string {
	target := os.readlink(path) or { return '' }
	return if os.is_abs_path(target) {
		target
	} else {
		os.norm_path(os.join_path(os.dir(path), target))
	}
}

fn cask_relative_path(path string, base string) string {
	path_parts := os.norm_path(path).split('/').filter(it != '')
	base_parts := os.norm_path(base).split('/').filter(it != '')
	mut common := 0
	for common < path_parts.len && common < base_parts.len && path_parts[common] == base_parts[common] {
		common++
	}
	mut parts := []string{len: base_parts.len - common, init: '..'}
	parts << path_parts[common..]
	return if parts.len == 0 { '.' } else { parts.join('/') }
}

pub fn (cask CaskCore) pinned() bool {
	path := cask.pin_path()
	return os.is_link(path) && os.exists(cask_resolved_link(path))
}

pub fn (cask CaskCore) pinnable() bool {
	version := cask.installed_version()
	return version != '' && os.exists(os.join_path(cask.caskroom_path(), version))
}

pub fn (cask CaskCore) pinned_version() string {
	return if cask.pinned() { os.base(cask_resolved_link(cask.pin_path())) } else { '' }
}

pub fn (mut cask CaskCore) pin() ! {
	version := cask.installed_version()
	if version == '' {
		return
	}
	versioned_path := os.join_path(cask.caskroom_path(), version)
	if !os.exists(versioned_path) {
		return
	}
	os.mkdir_all(cask.pinned_root)!
	if cask.pinned() {
		return
	}
	path := cask.pin_path()
	if os.exists(path) || os.is_link(path) {
		os.rm(path)!
	}
	relative := cask_relative_path(versioned_path, os.dir(path))
	os.symlink(relative, path)!
}

pub fn (mut cask CaskCore) unpin() ! {
	path := cask.pin_path()
	if os.is_link(path) {
		os.rm(path)!
	}
	if os.is_dir(cask.pinned_root) && (os.ls(cask.pinned_root) or { []string{} }).len == 0 {
		os.rmdir(cask.pinned_root)!
	}
}

fn cask_artifact_key(artifact ruby.Value) string {
	return artifact.attributes['dsl_key'] or {
		artifact.type_name.all_after_last('::').replace('Block', '').replace_each([
			'AppImage',
			'app_image',
			'Preflight',
			'preflight',
			'Postflight',
			'postflight',
		]).to_lower()
	}
}

fn cask_artifact_installable(artifact ruby.Value) bool {
	key := cask_artifact_key(artifact)
	return key == 'stage_only' || key !in ['uninstall', 'zap']
}

pub fn (cask CaskCore) font() bool {
	return cask.dsl.artifacts.items.all(cask_artifact_key(it) == 'font')
}

pub fn (cask CaskCore) installable_artifact() bool {
	return cask.dsl.artifacts.items.any(cask_artifact_installable(it))
}

pub fn (cask CaskCore) supports_linux() bool {
	depends := cask.dsl.depends_on_value
	if depends.linux_set_top_level || depends.linux {
		return true
	}
	return !depends.macos_required
}

pub fn (cask CaskCore) supports_macos() bool {
	return !(cask.dsl.depends_on_value.linux_set_top_level || cask.dsl.depends_on_value.linux)
}

fn cask_is_flight_block(artifact ruby.Value) bool {
	return cask_artifact_key(artifact) in ['preflight', 'postflight', 'uninstall_preflight',
		'uninstall_postflight'] || artifact.type_name.contains('PreflightBlock') || artifact.type_name.contains('PostflightBlock')
}

pub fn (cask CaskCore) caskfile_only() bool {
	return (cask.dsl.language_blocks.len > 0 && !cask.language_variations_available) || cask.dsl.artifacts.items.any(cask_is_flight_block(it))
}

pub fn (cask CaskCore) uninstall_flight_blocks() bool {
	for artifact in cask.dsl.artifacts.items {
		key := cask_artifact_key(artifact)
		if key in ['uninstall_preflight', 'uninstall_postflight'] || artifact.map_data.keys().any(it in [
			'uninstall_preflight',
			'uninstall_postflight',
		]) {
			return true
		}
	}
	return false
}

pub fn (cask CaskCore) config_path() string {
	return os.join_path(cask.metadata_main_container_path(), 'config.json')
}

pub fn (cask CaskCore) download_sha_path() string {
	return os.join_path(cask.metadata_main_container_path(), 'LATEST_DOWNLOAD_SHA256')
}

pub fn (cask CaskCore) checksumable() bool {
	if !cask.dsl.has_url || cask.dsl.url_value.uri.trim_space() == '' {
		return false
	}
	uri := cask.dsl.url_value.uri.to_lower()
	return uri.starts_with('file://') || uri.starts_with('http://') || uri.starts_with('https://') || uri.starts_with('ftp://')
}

pub fn (mut cask CaskCore) new_download_sha() !string {
	if cask.new_download_sha_value != '' {
		return cask.new_download_sha_value
	}
	mut path := cask.download
	if path == '' && cask.dsl.has_url && cask.dsl.url_value.uri.starts_with('file://') {
		path = cask.dsl.url_value.uri.trim_string_left('file://')
	}
	if path == '' {
		return error('download path is unavailable')
	}
	contents := os.read_bytes(path)!
	cask.new_download_sha_value = sha256.sum256(contents).hex()
	return cask.new_download_sha_value
}

pub fn (mut cask CaskCore) outdated_download_sha() bool {
	if !cask.checksumable() {
		return true
	}
	current := os.read_file(cask.download_sha_path()) or { '' }
	new_sha := cask.new_download_sha() or { return true }
	return current.trim_space() == '' || current != new_sha
}

fn cask_plist_string(contents string, key string) string {
	marker := '<key>${key}</key>'
	start := contents.index(marker) or { return '' }
	rest := contents[start + marker.len..]
	string_start := rest.index('<string>') or { return '' }
	value := rest[string_start + '<string>'.len..]
	string_end := value.index('</string>') or { return '' }
	return value[..string_end]
}

fn (cask CaskCore) single_app_target() string {
	apps := cask.dsl.artifacts.items.filter(cask_artifact_key(it) == 'app')
	if apps.len != 1 {
		return ''
	}
	artifact := apps[0]
	if target := artifact.attributes['target'] {
		return target
	}
	source := artifact.attributes['source'] or { artifact.repr }
	appdir := cask.config.directory('appdir') or { '' }
	return os.join_path(appdir, os.base(source))
}

pub fn (cask CaskCore) installed_app_info_plist() string {
	target := cask.single_app_target()
	if target == '' {
		return ''
	}
	path := os.join_path(target, 'Contents', 'Info.plist')
	return if os.exists(path) && os.is_readable(path) { path } else { '' }
}

pub fn (cask CaskCore) bundle_version() ?CaskBundleVersion {
	if cask.has_bundle_short_override || cask.has_bundle_long_override {
		return CaskBundleVersion{
			short_version: cask.bundle_short_override
			version: cask.bundle_long_override
		}
	}
	path := cask.installed_app_info_plist()
	if path == '' {
		return none
	}
	contents := os.read_file(path) or { return none }
	return CaskBundleVersion{
		short_version: cask_plist_string(contents, 'CFBundleShortVersionString')
		version: cask_plist_string(contents, 'CFBundleVersion')
	}
}

pub fn compare_cask_version_strings(first string, second string) ?int {
	if first.trim_space() == '' || second.trim_space() == '' || first.split('.').len != second.split('.').len {
		return none
	}
	left := homebrew.new_version(first) or { return none }
	right := homebrew.new_version(second) or { return none }
	return left.compare_to(right)
}

pub fn (cask CaskCore) auto_updates_bundle_outdated() bool {
	if !cask.dsl.has_auto_updates || !cask.dsl.auto_updates_value || !cask.dsl.has_version || cask.dsl.version_value.latest() || (cask.installed_app_info_plist() == '' && !cask.has_bundle_short_override && !cask.has_bundle_long_override) {
		return false
	}
	csv := cask.dsl.version_value.csv().map(it.text)
	tap_short := if csv.len > 0 && csv[0] != '' { csv[0] } else { cask.version_text() }
	bundle := cask.bundle_version() or { return false }
	mut installed_short := bundle.short_version
	mut installed_bundle := bundle.version
	if installed_bundle in cask_auto_updates_bad_bundle_versions {
		installed_bundle = ''
	}
	if installed_short in cask_auto_updates_bad_bundle_versions {
		installed_short = ''
	}
	if installed_short == '' && installed_bundle == '' {
		return false
	}
	if installed_short != '' && installed_bundle != '' {
		mut comparisons := []int{}
		for candidate in csv {
			if comparison := compare_cask_version_strings('${installed_short}-${installed_bundle}', candidate) {
				comparisons << comparison
			}
		}
		if 0 in comparisons || (comparisons.len > 0 && -1 !in comparisons) {
			return false
		}
	}
	for installed in [installed_short, installed_bundle] {
		if comparison := compare_cask_version_strings(installed, tap_short) {
			if comparison == 0 {
				return false
			}
		}
	}
	if short_comparison := compare_cask_version_strings(installed_short, tap_short) {
		if short_comparison == -1 {
			return true
		}
		if short_comparison == 1 {
			return false
		}
	}
	mut build_comparisons := []int{}
	for candidate in csv {
		if comparison := compare_cask_version_strings(installed_bundle, candidate) {
			build_comparisons << comparison
		}
	}
	if build_comparisons.len == 0 || 0 in build_comparisons {
		return false
	}
	return -1 in build_comparisons
}

pub fn (mut cask CaskCore) outdated_version(options CaskOutdatedOptions) string {
	if !cask.dsl.has_version {
		return ''
	}
	if cask.dsl.version_value.latest() {
		return if (options.greedy || options.greedy_latest) && cask.outdated_download_sha() {
			cask.installed_version()
		} else {
			''
		}
	}
	installed := cask.installed_version()
	if installed == cask.version_text() {
		return ''
	}
	if cask.dsl.has_auto_updates && cask.dsl.auto_updates_value && !options.greedy && !options.greedy_auto_updates {
		if !cask.upgrade_auto_updates_casks {
			return ''
		}
		return if cask.auto_updates_bundle_outdated() { installed } else { '' }
	}
	return installed
}

pub fn (mut cask CaskCore) outdated(options CaskOutdatedOptions) bool {
	return cask.outdated_version(options) != ''
}

pub fn (mut cask CaskCore) outdated_info(options CaskOutdatedOptions, verbose bool,
	as_json bool) ruby.Value {
	if !verbose && !as_json {
		return ruby.string_value(cask.token)
	}
	installed := cask.outdated_version(options)
	if as_json {
		return ruby.map_value({
			'name':               ruby.string_value(cask.token)
			'installed_versions': ruby.string_array_value([installed])
			'current_version':    cask_optional_string(cask.version_text(), 'Cask::DSL::Version')
			'pinned':             ruby.bool_value(cask.pinned())
			'pinned_version':     cask_optional_string(cask.pinned_version(), 'String')
		})
	}
	pinned := if cask.pinned() { ' [pinned at ${cask.pinned_version()}]' } else { '' }
	return ruby.string_value('${cask.token} (${installed}) != ${cask.version_text()}${pinned}')
}

pub fn (cask CaskCore) ruby_source_path() string {
	if cask.ruby_source_path_value != '' {
		return cask.ruby_source_path_value
	}
	if cask.sourcefile_path == '' || cask.tap_path == '' {
		return ''
	}
	return cask_relative_path(cask.sourcefile_path, cask.tap_path)
}

pub fn (cask CaskCore) ruby_source_checksum() string {
	if cask.ruby_source_checksum_value != '' {
		return cask.ruby_source_checksum_value
	}
	if cask.sourcefile_path == '' {
		return ''
	}
	contents := os.read_bytes(cask.sourcefile_path) or { return '' }
	return sha256.sum256(contents).hex()
}

pub fn (cask CaskCore) languages() []string {
	if cask.api_languages.len > 0 {
		return cask.api_languages.clone()
	}
	mut result := []string{}
	for block in cask.dsl.language_blocks {
		result << block.languages
	}
	return result
}

pub fn (mut cask CaskCore) populate_from_api(source map[string]ruby.Value,
	tap_git_head string) ! {
	if !cask.loaded_from_api {
		return error('Expected cask to be loaded from the API')
	}
	cask.api_languages = (source['languages'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
	variations := (source['language_variations'] or { ruby.array_value([]) }).as_array() or { []ruby.Value{} }
	cask.language_variations_available = variations.len > 0
	for variation in variations {
		languages := (variation.map_data['languages'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
		result := (variation.map_data['value'] or { cask_nil() }).as_string()
		cask.api_language_results[languages.join(',')] = result
	}
	cask.tap_git_head_value = tap_git_head
	cask.ruby_source_path_value = (source['ruby_source_path'] or { cask_nil() }).as_string().replace('nil', '')
	checksum := source['ruby_source_checksum'] or { ruby.map_value({}) }
	cask.ruby_source_checksum_value = (checksum.map_data['sha256'] or { cask_nil() }).as_string().replace('nil', '')
}

fn cask_value_array_strings(values []string) ruby.Value {
	return ruby.array_value(values.map(ruby.string_value(it)))
}

fn cask_artifact_args(artifact ruby.Value) ruby.Value {
	if value := artifact.map_data['to_args'] {
		return value
	}
	key := cask_artifact_key(artifact)
	if key == 'stage_only' {
		return ruby.array_value([ruby.bool_value(true)])
	}
	if key in ['uninstall', 'zap'] && artifact.map_data.len > 0 {
		return ruby.array_value([ruby.map_value(artifact.map_data)])
	}
	source := artifact.attributes['source'] or { artifact.repr }
	return cask_value_array_strings(if source == '' { []string{} } else { [source] })
}

fn cask_artifact_has_uninstall(artifact ruby.Value) bool {
	if (artifact.attributes['uninstall_phase'] or { '' }) == 'true' {
		return true
	}
	return cask_artifact_key(artifact) in ['uninstall', 'app', 'app_image', 'artifact',
		'audio_unit_plugin', 'binary', 'command_wrapper', 'colorpicker', 'dictionary', 'font',
		'generated_script', 'input_method', 'internet_plugin', 'keyboard_layout', 'manpage',
		'prefpane', 'qlplugin', 'mdimporter', 'screen_saver', 'service', 'suite', 'vst_plugin',
		'vst3_plugin', 'zsh_completion', 'fish_completion', 'bash_completion', 'generated_completion']
}

fn cask_artifact_sort_index(artifact ruby.Value) int {
	key := cask_artifact_key(artifact)
	return match key {
		'preflight_steps' { 0 }
		'uninstall_preflight_steps' { 1 }
		'preflight', 'uninstall_preflight' { 2 }
		'uninstall' { 3 }
		'generated_script' { 4 }
		'installer' { 5 }
		'pkg' { 6 }
		'app', 'app_image', 'suite', 'artifact', 'colorpicker', 'prefpane', 'qlplugin', 'mdimporter', 'dictionary', 'font', 'service', 'input_method', 'internet_plugin', 'keyboard_layout', 'audio_unit_plugin', 'vst_plugin', 'vst3_plugin', 'screen_saver' {
			7
		}
		'binary', 'command_wrapper' { 8 }
		'manpage' { 9 }
		'bash_completion', 'fish_completion', 'zsh_completion' { 10 }
		'generated_completion' { 11 }
		'postflight_steps' { 12 }
		'uninstall_postflight_steps' { 13 }
		'postflight', 'uninstall_postflight' { 14 }
		'zap' { 15 }
		else { 16 }
	}
}

pub fn (cask CaskCore) artifacts_list(uninstall_only bool) []ruby.Value {
	mut result := []ruby.Value{}
	mut artifacts := cask.dsl.artifacts.items.clone()
	artifacts.sort_with_compare(fn (left &ruby.Value, right &ruby.Value) int {
		by_order := cask_artifact_sort_index(*left) - cask_artifact_sort_index(*right)
		if by_order != 0 {
			return by_order
		}
		return 0
	})
	for artifact in artifacts {
		key := cask_artifact_key(artifact)
		if cask_is_flight_block(artifact) {
			uninstall := key.starts_with('uninstall_') || artifact.map_data.keys().any(it.starts_with('uninstall_'))
			if uninstall_only && !uninstall {
				continue
			}
			summary := if artifact.map_data.len > 0 { artifact.map_data.keys()[0] } else { key }
			result << ruby.map_value({
				summary: cask_nil()
			})
			continue
		}
		zap := key == 'zap'
		if uninstall_only && !zap && !cask_artifact_has_uninstall(artifact) {
			continue
		}
		mut entry := {
			key: cask_artifact_args(artifact)
		}
		if !uninstall_only && key in ['app', 'app_image', 'artifact', 'audio_unit_plugin', 'binary',
			'colorpicker', 'dictionary', 'font', 'input_method', 'internet_plugin', 'keyboard_layout',
			'mdimporter', 'prefpane', 'qlplugin', 'screen_saver', 'service', 'suite', 'vst_plugin',
			'vst3_plugin'] {
			target := artifact.attributes['target'] or {
				if key == 'app' {
					cask.single_app_target()
				} else {
					''
				}
			}
			if target != '' {
				entry['target'] = ruby.string_value(target)
			}
		}
		result << ruby.map_value(entry)
	}
	return result
}

pub fn (cask CaskCore) rename_list() []ruby.Value {
	return cask.dsl.renames.map(ruby.map_value({
		'from': ruby.string_value(it.from)
		'to':   ruby.string_value(it.to)
	}))
}

fn cask_strip_ansi(value string) string {
	mut result := ''
	mut escape := false
	for character in value.runes() {
		if character == `\e` {
			escape = true
			continue
		}
		if escape {
			if character == `m` {
				escape = false
			}
			continue
		}
		result += character.str()
	}
	return result
}

pub fn (cask CaskCore) caveats_for_api() string {
	text := cask_strip_ansi(cask.dsl.caveats_value.custom.join('\n'))
	return if text.trim_space() == '' { '' } else { text }
}

pub fn (cask CaskCore) url_specs() ruby.Value {
	if !cask.dsl.has_url {
		return cask_nil()
	}
	mut specs := cask.dsl.url_value.options.clone()
	if user_agent := specs['user_agent'] {
		if user_agent.type_name == 'Symbol' && user_agent.as_string().trim_left(':') == 'default' {
			specs.delete('user_agent')
		} else if user_agent.type_name == 'Symbol' {
			specs['user_agent'] = ruby.string_value(':${user_agent.as_string().trim_left(':')}')
		}
	}
	return ruby.map_value(specs)
}

fn cask_map_value(value string) ruby.Value {
	return if value == '' { cask_nil() } else { ruby.string_value(value) }
}

pub fn (mut cask CaskCore) to_h() map[string]ruby.Value {
	bundle := cask.bundle_version()
	short_version := if value := bundle { value.short_version } else { '' }
	long_version := if value := bundle { value.version } else { '' }
	return {
		'token':                           ruby.string_value(cask.token)
		'full_token':                      ruby.string_value(cask.full_token())
		'old_tokens':                      ruby.string_array_value(cask.old_tokens())
		'tap':                             cask_map_value(cask.tap_name)
		'name':                            ruby.string_array_value(cask.dsl.names)
		'desc':                            cask_map_value(if cask.dsl.has_description {
			cask.dsl.description
		} else {
			''
		})
		'homepage':                        cask_map_value(if cask.dsl.has_homepage {
			cask.dsl.homepage
		} else {
			''
		})
		'url':                             if cask.dsl.has_url {
			cask_url_value(cask.dsl.url_value)
		} else {
			cask_nil()
		}
		'url_specs':                       cask.url_specs()
		'version':                         if cask.dsl.has_version {
			dsl_types.cask_version_value(cask.dsl.version_value)
		} else {
			cask_nil()
		}
		'autobump':                        ruby.bool_value(cask.dsl.autobump)
		'no_autobump_message':             cask.dsl.no_autobump_message
		'skip_livecheck':                  ruby.bool_value(cask.dsl.livecheck_strategy == 'skip')
		'installed':                       cask_map_value(cask.installed_version())
		'installed_time':                  cask_nil()
		'bundle_version':                  cask_map_value(long_version)
		'bundle_short_version':            cask_map_value(short_version)
		'pinned':                          ruby.bool_value(cask.pinned())
		'pinned_version':                  cask_map_value(cask.pinned_version())
		'outdated':                        ruby.bool_value(cask.outdated(CaskOutdatedOptions{}))
		'sha256':                          if cask.dsl.has_sha256 {
			cask.dsl.sha256_value
		} else {
			cask_nil()
		}
		'artifacts':                       ruby.array_value(cask.artifacts_list(false))
		'caveats':                         cask_map_value(cask.caveats_for_api())
		'caveats_rosetta':                 cask_nil()
		'depends_on':                      dsl_types.cask_depends_on_value(cask.dsl.depends_on_value)
		'conflicts_with':                  if cask.dsl.has_conflicts_with {
			dsl_types.cask_conflicts_with_value(cask.dsl.conflicts_with_value)
		} else {
			cask_nil()
		}
		'container':                       if cask.dsl.has_container {
			dsl_types.cask_container_value(cask.dsl.container_value)
		} else {
			cask_nil()
		}
		'rename':                          ruby.array_value(cask.rename_list())
		'auto_updates':                    if cask.dsl.has_auto_updates {
			ruby.bool_value(cask.dsl.auto_updates_value)
		} else {
			cask_nil()
		}
		'deprecated':                      ruby.bool_value(cask.dsl.deprecated)
		'deprecation_date':                cask_map_value(cask.dsl.deprecation_date)
		'deprecation_reason':              cask.dsl.deprecation_reason
		'deprecation_replacement_formula': cask_map_value(cask.dsl.deprecation_replacement_formula)
		'deprecation_replacement_cask':    cask_map_value(cask.dsl.deprecation_replacement_cask)
		'deprecate_args':                  if cask.dsl.deprecate_args.len > 0 {
			ruby.map_value(cask.dsl.deprecate_args)
		} else {
			cask_nil()
		}
		'disabled':                        ruby.bool_value(cask.dsl.disabled)
		'disable_date':                    cask_map_value(cask.dsl.disable_date)
		'disable_reason':                  cask.dsl.disable_reason
		'disable_replacement_formula':     cask_map_value(cask.dsl.disable_replacement_formula)
		'disable_replacement_cask':        cask_map_value(cask.dsl.disable_replacement_cask)
		'disable_args':                    if cask.dsl.disable_args.len > 0 {
			ruby.map_value(cask.dsl.disable_args)
		} else {
			cask_nil()
		}
		'tap_git_head':                    cask_map_value(cask.tap_git_head_value)
		'languages':                       ruby.string_array_value(cask.languages())
		'ruby_source_path':                cask_map_value(cask.ruby_source_path())
		'ruby_source_checksum':            ruby.map_value({
			'sha256': cask_map_value(cask.ruby_source_checksum())
		})
	}
}

fn cask_value_string_equal(left ruby.Value, right ruby.Value) bool {
	return left.as_string() == right.as_string()
}

pub fn (mut cask CaskCore) to_h_with_language_variations() !map[string]ruby.Value {
	if cask.dsl.language_blocks.len == 0 {
		return cask.to_h()
	}
	mut default_group := []string{}
	for block in cask.dsl.language_blocks {
		if block.is_default {
			default_group = block.languages.clone()
		}
	}
	if default_group.len == 0 {
		return error('No default language specified.')
	}
	original_config := cask.config
	mut hashes := map[string]map[string]ruby.Value{}
	mut values := map[string]string{}
	for block in cask.dsl.language_blocks {
		mut localised := original_config
		localised.explicit_values = original_config.explicit_values.clone()
		localised.set_languages([block.languages[0]])
		cask.set_config(localised)!
		hashes[block.languages.join('\0')] = cask.to_h()
		values[block.languages.join('\0')] = cask.dsl.language_eval_value
	}
	default_key := default_group.join('\0')
	mut result := hashes[default_key].clone()
	mut variations := []ruby.Value{}
	for block in cask.dsl.language_blocks {
		key := block.languages.join('\0')
		language_hash := hashes[key].clone()
		mut variation := {
			'languages': ruby.string_array_value(block.languages)
			'default':   ruby.bool_value(key == default_key)
			'value':     ruby.string_value(values[key])
		}
		for name, language_value in language_hash {
			if name in cask_hash_keys_to_skip || cask_value_string_equal(language_value, result[name] or { cask_nil() }) {
				continue
			}
			variation[name] = language_value
		}
		variations << ruby.map_value(variation)
	}
	result['language_variations'] = ruby.array_value(variations)
	cask.set_config(original_config)!
	return result
}

pub fn (cask CaskCore) platform_supported(tag homebrew.BottleTag) bool {
	if (tag.linux() && !cask.supports_linux()) || (tag.macos() && !cask.supports_macos()) || cask.version_text() == '' || !cask.dsl.has_sha256 || cask.dsl.sha256_value.as_string() == '' || !cask.dsl.has_url || cask.dsl.url_value.uri == '' || !cask.installable_artifact() {
		return false
	}
	if cask.dsl.depends_on_value.arch.len > 0 {
		mut supported := false
		for requirement in cask.dsl.depends_on_value.arch {
			required := homebrew.new_bottle_tag(tag.system, requirement.kind)
			if required.standardized_arch() == tag.standardized_arch() {
				supported = true
			}
		}
		if !supported {
			return false
		}
	}
	if !tag.macos() {
		return true
	}
	macos := homebrew.macos_version_from_symbol(tag.system) or { return false }
	if requirement := cask.dsl.depends_on_value.macos {
		if !requirement.allows(macos) {
			return false
		}
	}
	if requirement := cask.dsl.depends_on_value.maximum_macos {
		if !requirement.allows(macos) {
			return false
		}
	}
	return true
}

pub fn (mut cask CaskCore) to_hash_with_variations() !map[string]ruby.Value {
	if cask.loaded_from_internal_api {
		return error('Cannot call #to_hash_with_variations on casks loaded from the internal API')
	}
	if cask.loaded_from_api && cask.api_source.len > 0 && ruby.environment_value('HOMEBREW_NO_INSTALL_FROM_API') == '' {
		return cask.api_to_local_hash(cask.api_source)
	}
	mut base := cask.to_h_with_language_variations()!
	mut variations := map[string]ruby.Value{}
	mut supported := []string{}
	original_os := cask.system_os
	original_arch := cask.system_arch
	if cask.dsl.on_system_blocks_exist {
		for tag in cask.valid_tags {
			cask.system_os = tag.system
			cask.system_arch = tag.arch
			cask.refresh() or { continue }
			if cask.platform_supported(tag) {
				supported << tag.symbol()
			}
			current := cask.to_h_with_language_variations()!
			mut variation := map[string]ruby.Value{}
			for key, value in current {
				if key in cask_hash_keys_to_skip || cask_value_string_equal(value, base[key] or { cask_nil() }) {
					continue
				}
				variation[key] = value
			}
			if variation.len > 0 {
				variations[tag.symbol()] = ruby.map_value(variation)
			}
		}
		cask.system_os = original_os
		cask.system_arch = original_arch
		cask.refresh()!
	} else {
		for tag in cask.valid_tags {
			if cask.platform_supported(tag) {
				supported << tag.symbol()
			}
		}
	}
	base['variations'] = ruby.map_value(variations)
	base['supported_platforms'] = ruby.string_array_value(supported)
	return base
}

pub fn (cask CaskCore) to_installed_json_hash() map[string]ruby.Value {
	if !cask.dsl.has_url {
		return map[string]ruby.Value{}
	}
	only_path := cask.dsl.url_value.options['only_path'] or { return map[string]ruby.Value{} }
	if only_path.as_string().trim_space() == '' {
		return map[string]ruby.Value{}
	}
	return {
		'url_specs': ruby.map_value({
			'only_path': only_path
		})
	}
}

pub fn (mut cask CaskCore) api_to_local_hash(source map[string]ruby.Value) map[string]ruby.Value {
	mut result := source.clone()
	result['token'] = ruby.string_value(cask.token)
	result['installed'] = cask_map_value(cask.installed_version())
	result['pinned'] = ruby.bool_value(cask.pinned())
	result['pinned_version'] = cask_map_value(cask.pinned_version())
	result['outdated'] = ruby.bool_value(cask.outdated(CaskOutdatedOptions{}))
	return result
}

fn cask_receiver(args []ruby.Value, method string) !CaskCore {
	if args.len == 0 {
		return error('${method} requires a Cask receiver')
	}
	return cask_core_from_value(args[0])
}

fn cask_error(kind string, message string) ruby.Value {
	return ruby.object_value(kind, message)
}

fn cask_keyword_args(args []ruby.Value) map[string]ruby.Value {
	for index := args.len - 1; index >= 0; index-- {
		if args[index].type_name == 'Hash' {
			return args[index].map_data.clone()
		}
	}
	return map[string]ruby.Value{}
}

fn cask_keyword_bool(args []ruby.Value, key string, fallback bool) bool {
	return cask_value_bool(cask_keyword_args(args), key, fallback)
}

// Ruby attr_reader `attr_reader :token` at line 28.
pub fn ruby_cask_l28_d1_token(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'token') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.string_value(cask.token)
}

// Ruby attr_reader `attr_reader :config` at line 34.
pub fn ruby_cask_l34_d2_config(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'config') or { return cask_error('ArgumentError', err.msg()) }
	return cask_config_boundary(cask.config)
}

// Ruby attr_reader `attr_reader :sourcefile_path` at line 37.
pub fn ruby_cask_l37_d3_sourcefile_path(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'sourcefile_path') or { return cask_error('ArgumentError', err.msg()) }
	return cask_optional_string(cask.sourcefile_path, 'Pathname')
}

// Ruby attr_reader `attr_reader :source` at line 40.
pub fn ruby_cask_l40_d4_source(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'source') or { return cask_error('ArgumentError', err.msg()) }
	return cask_optional_string(cask.source, 'String')
}

// Ruby attr_reader `attr_reader :default_config` at line 43.
pub fn ruby_cask_l43_d5_default_config(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'default_config') or { return cask_error('ArgumentError', err.msg()) }
	return cask_config_boundary(cask.default_config)
}

// Ruby attr_reader `attr_reader :loader` at line 46.
pub fn ruby_cask_l46_d6_loader(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'loader') or { return cask_error('ArgumentError', err.msg()) }
	return cask.loader
}

// Ruby attr_accessor `attr_accessor :download` at line 49.
pub fn ruby_cask_l49_d7_download(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'download') or { return cask_error('ArgumentError', err.msg()) }
	return cask_optional_string(cask.download, 'Pathname')
}

// Ruby attr_accessor `attr_accessor :download` at line 49.
pub fn ruby_cask_l49_d8_download(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'download=') or { return cask_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return cask_error('ArgumentError', 'download= requires a value')
	}
	cask.download = args[1].as_string()
	return cask_core_value(cask)
}

// Ruby attr_accessor `attr_accessor :allow_reassignment` at line 52.
pub fn ruby_cask_l52_d9_allow_reassignment(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'allow_reassignment') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.allow_reassignment)
}

// Ruby attr_accessor `attr_accessor :allow_reassignment` at line 52.
pub fn ruby_cask_l52_d10_allow_reassignment(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'allow_reassignment=') or { return cask_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return cask_error('ArgumentError', 'allow_reassignment= requires a value')
	}
	cask.allow_reassignment = args[1].as_bool() or { false }
	return cask_core_value(cask)
}

// Ruby method `self.all(eval_all: false)` at line 55.
pub fn ruby_cask_l55_d11_self_all(args ...ruby.Value) ruby.Value {
	options := cask_keyword_args(args)
	eval_all := cask_value_bool(options, 'eval_all', false)
	trust_configured := cask_value_bool(options, 'tap_trust_configured', false)
	if !eval_all && !trust_configured {
		return cask_error('ArgumentError', 'Cask::Cask#all cannot be used without `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1`')
	}
	require_trust := cask_value_bool(options, 'require_tap_trust', false)
	entries := (options['entries'] or { ruby.array_value([]) }).as_array() or { []ruby.Value{} }
	mut loaded := []ruby.Value{}
	for entry in entries {
		trusted := cask_value_bool(entry.map_data, 'trusted', false)
		if require_trust && !trusted {
			continue
		}
		if !cask_value_bool(entry.map_data, 'readable', true) || !cask_value_bool(entry.map_data, 'valid', true) {
			continue
		}
		if cask_value := entry.map_data['cask'] {
			loaded << cask_value
		}
	}
	return ruby.array_value(loaded)
}

// Ruby method `tap(&blk)` at line 83.
pub fn ruby_cask_l83_d12_tap(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'tap') or { return cask_error('ArgumentError', err.msg()) }
	if args.len > 1 {
		return cask_core_value(cask)
	}
	if cask.tap_name == '' {
		return cask_nil()
	}
	return ruby.structured_value('Tap', cask.tap_name, {
		'name':          cask.tap_name
		'path':          cask.tap_path
		'core_cask_tap': cask.tap_core.str()
	})
}

// Ruby method `initialize(token, sourcefile_path: nil, source: nil, tap: nil, loaded_from_api: false,` at line 104.
pub fn ruby_cask_l104_d13_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return cask_error('ArgumentError', 'initialize requires a token')
	}
	options := cask_keyword_args(args)
	config_value := options['config'] or { cask_nil() }
	config := if config_value.type_name == 'Cask::Config' {
		cask_config_from_boundary(config_value)
	} else {
		new_cask_config(CaskConfigOptions{}) or { return cask_error('CaskError', err.msg()) }
	}
	cask := new_cask_core(CaskCoreConfig{
		token: args[0].as_string()
		sourcefile_path: cask_value_string(options, 'sourcefile_path')
		source: cask_value_string(options, 'source')
		tap_name: cask_value_string(options, 'tap')
		loaded_from_api: cask_value_bool(options, 'loaded_from_api', false)
		loaded_from_internal_api: cask_value_bool(options, 'loaded_from_internal_api', false)
		api_source: (options['api_source'] or { ruby.map_value({}) }).map_data.clone()
		config: config
		has_config: config_value.type_name == 'Cask::Config'
		allow_reassignment: cask_value_bool(options, 'allow_reassignment', false)
		loader: options['loader'] or { cask_nil() }
		caskroom_root: cask_value_string(options, 'caskroom_root')
		pinned_root: cask_value_string(options, 'pinned_root')
	}, cask_noop_block) or { return cask_error('CaskInvalidError', err.msg()) }
	return cask_core_value(cask)
}

// Ruby method `loaded_from_api? = @loaded_from_api` at line 136.
pub fn ruby_cask_l136_d14_loaded_from_api(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'loaded_from_api?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.loaded_from_api)
}

// Ruby method `loaded_from_internal_api? = @loaded_from_internal_api` at line 139.
pub fn ruby_cask_l139_d15_loaded_from_internal_api(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'loaded_from_internal_api?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.loaded_from_internal_api)
}

// Ruby method `reloadable_ref` at line 142.
pub fn ruby_cask_l142_d16_reloadable_ref(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'reloadable_ref') or { return cask_error('ArgumentError', err.msg()) }
	if cask.loaded_from_api {
		return ruby.string_value(cask.full_token())
	}
	if cask.sourcefile_path == '' {
		return cask_error('RuntimeError', 'unexpected nil cask sourcefile_path')
	}
	return ruby.object_value('Pathname', cask.sourcefile_path)
}

// Ruby attr_reader `attr_reader :api_source` at line 149.
pub fn ruby_cask_l149_d17_api_source(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'api_source') or { return cask_error('ArgumentError', err.msg()) }
	return if cask.api_source.len == 0 {
		cask_nil()
	} else {
		ruby.map_value(cask.api_source)
	}
}

// Ruby method `old_tokens` at line 153.
pub fn ruby_cask_l153_d18_old_tokens(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'old_tokens') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.string_array_value(cask.old_tokens())
}

// Ruby method `config=(config)` at line 166.
pub fn ruby_cask_l166_d19_config(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'config=') or { return cask_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return cask_error('ArgumentError', 'config= requires a value')
	}
	config := cask_config_from_boundary(args[1])
	cask.set_config(config) or { return cask_error('CaskInvalidError', err.msg()) }
	return cask_core_value(cask)
}

// Ruby method `refresh` at line 173.
pub fn ruby_cask_l173_d20_refresh(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'refresh') or { return cask_error('ArgumentError', err.msg()) }
	cask.refresh() or { return cask_error('CaskInvalidError', err.msg()) }
	return cask_core_value(cask)
}

// Ruby method `refresh_for_tag(tag, &_block)` at line 190.
pub fn ruby_cask_l190_d21_refresh_for_tag(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'refresh_for_tag') or { return cask_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return cask_error('ArgumentError', 'refresh_for_tag requires a tag')
	}
	cask.system_os = args[1].attributes['system'] or { args[1].map_data['system'] or { ruby.string_value('') }.as_string() }
	cask.system_arch = args[1].attributes['arch'] or { args[1].map_data['arch'] or { ruby.string_value('') }.as_string() }
	cask.refresh() or {
		if cask.dsl.on_system_blocks_exist {
			return cask_nil()
		}
		return cask_error('CaskInvalidError', err.msg())
	}
	return if args.len > 2 {
		args[2]
	} else if cask.dsl.has_url { cask_url_value(cask.dsl.url_value) } else { cask_nil() }
}

// Ruby def_delegators `def_delegators :@dsl, *(::Cask::DSL::DSL_METHODS - [:language])` at line 201.
pub fn ruby_cask_l201_d22_cask(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.object_value('Class', 'Cask') }
}

// Ruby def_delegators `def_delegators :@dsl, *(::Cask::DSL::DSL_METHODS - [:language])` at line 201.
pub fn ruby_cask_l201_d23_dsl(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'DSL') or { return ruby.object_value('Class', 'Cask::DSL') }
	return cask_dsl_value(cask.dsl)
}

// Ruby def_delegators `def_delegators :@dsl, *(::Cask::DSL::DSL_METHODS - [:language])` at line 201.
pub fn ruby_cask_l201_d24_dsl_methods(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['name', 'desc', 'homepage', 'url', 'container', 'rename',
		'version', 'sha256', 'arch', 'os', 'depends_on', 'conflicts_with', 'caveats', 'auto_updates'])
}

// Ruby method `language(*args, default: false, &block)` at line 210.
pub fn ruby_cask_l210_d25_language(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'language') or { return cask_error('ArgumentError', err.msg()) }
	if args.len == 1 {
		if cask.api_language_results.len > 0 {
			for language in cask.config.languages() {
				for key, result in cask.api_language_results {
					if language in key.split(',') {
						return ruby.string_value(result)
					}
				}
			}
		}
		result := cask_dsl_evaluate_language(mut cask.dsl) or { return cask_error('CaskInvalidError', err.msg()) }
		return cask_map_value(result)
	}
	mut forwarded := [cask_dsl_value(cask.dsl)]
	forwarded << args[1..]
	return ruby_dsl_l360_d28_language(...forwarded)
}

// Ruby method `caveats_object = dsl!.caveats_object` at line 217.
pub fn ruby_cask_l217_d26_caveats_object(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'caveats_object') or { return cask_error('ArgumentError', err.msg()) }
	return dsl_types.cask_caveats_value(cask.dsl.caveats_value)
}

// Ruby method `timestamped_versions(caskroom_path: self.caskroom_path)` at line 220.
pub fn ruby_cask_l220_d27_timestamped_versions(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'timestamped_versions') or { return cask_error('ArgumentError', err.msg()) }
	root := if args.len > 1 { args[1].as_string() } else { cask.caskroom_path() }
	return ruby.array_value(cask.timestamped_versions(root).map(ruby.string_array_value(it)))
}

// Ruby method `full_token` at line 233.
pub fn ruby_cask_l233_d28_full_token(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'full_token') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.string_value(cask.full_token())
}

// Ruby method `full_name = full_token` at line 244.
pub fn ruby_cask_l244_d29_full_name(args ...ruby.Value) ruby.Value {
	return ruby_cask_l233_d28_full_token(...args)
}

// Ruby method `installed?` at line 247.
pub fn ruby_cask_l247_d30_installed(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'installed?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.installed())
}

// Ruby method `any_version_installed? = installed?` at line 252.
pub fn ruby_cask_l252_d31_any_version_installed(args ...ruby.Value) ruby.Value {
	return ruby_cask_l247_d30_installed(...args)
}

// Ruby method `font?` at line 255.
pub fn ruby_cask_l255_d32_font(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'font?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.font())
}

// Ruby method `installable_artifact?` at line 260.
pub fn ruby_cask_l260_d33_installable_artifact(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'installable_artifact?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.installable_artifact())
}

// Ruby method `supports_linux?` at line 267.
pub fn ruby_cask_l267_d34_supports_linux(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'supports_linux?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.supports_linux())
}

// Ruby method `supports_macos?` at line 274.
pub fn ruby_cask_l274_d35_supports_macos(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'supports_macos?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.supports_macos())
}

// Ruby method `caskfile_only?` at line 281.
pub fn ruby_cask_l281_d36_caskfile_only(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'caskfile_only?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.caskfile_only())
}

// Ruby method `uninstall_flight_blocks?` at line 286.
pub fn ruby_cask_l286_d37_uninstall_flight_blocks(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'uninstall_flight_blocks?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.uninstall_flight_blocks())
}

// Ruby method `install_time` at line 298.
pub fn ruby_cask_l298_d38_install_time(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'install_time') or { return cask_error('ArgumentError', err.msg()) }
	file := cask.installed_caskfile()
	return if file == '' {
		cask_nil()
	} else {
		ruby.object_value('Time', os.base(os.dir(os.dir(file))))
	}
}

// Ruby method `installed_caskfile` at line 305.
pub fn ruby_cask_l305_d39_installed_caskfile(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'installed_caskfile') or { return cask_error('ArgumentError', err.msg()) }
	return cask_optional_string(cask.installed_caskfile(), 'Pathname')
}

// Ruby method `installed_version` at line 310.
pub fn ruby_cask_l310_d40_installed_version(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'installed_version') or { return cask_error('ArgumentError', err.msg()) }
	return cask_map_value(cask.installed_version())
}

// Ruby method `pin` at line 316.
pub fn ruby_cask_l316_d41_pin(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'pin') or { return cask_error('ArgumentError', err.msg()) }
	cask.pin() or { return cask_error('CaskError', err.msg()) }
	return cask_nil()
}

// Ruby method `unpin` at line 330.
pub fn ruby_cask_l330_d42_unpin(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'unpin') or { return cask_error('ArgumentError', err.msg()) }
	cask.unpin() or { return cask_error('CaskError', err.msg()) }
	return cask_nil()
}

// Ruby method `pinned?` at line 336.
pub fn ruby_cask_l336_d43_pinned(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'pinned?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.pinned())
}

// Ruby method `pinnable?` at line 341.
pub fn ruby_cask_l341_d44_pinnable(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'pinnable?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.pinnable())
}

// Ruby method `pinned_version` at line 348.
pub fn ruby_cask_l348_d45_pinned_version(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'pinned_version') or { return cask_error('ArgumentError', err.msg()) }
	return cask_map_value(cask.pinned_version())
}

// Ruby method `pin_path` at line 353.
pub fn ruby_cask_l353_d46_pin_path(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'pin_path') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.object_value('Pathname', cask.pin_path())
}

// Ruby method `bundle_short_version` at line 358.
pub fn ruby_cask_l358_d47_bundle_short_version(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'bundle_short_version') or { return cask_error('ArgumentError', err.msg()) }
	bundle := cask.bundle_version() or { return cask_nil() }
	return cask_map_value(bundle.short_version)
}

// Ruby method `bundle_long_version` at line 363.
pub fn ruby_cask_l363_d48_bundle_long_version(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'bundle_long_version') or { return cask_error('ArgumentError', err.msg()) }
	bundle := cask.bundle_version() or { return cask_nil() }
	return cask_map_value(bundle.version)
}

// Ruby method `tab` at line 368.
pub fn ruby_cask_l368_d49_tab(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'tab') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.Value{
		type_name: 'Cask::Tab'
		repr: 'Installed'
		map_data: {
			'source':              ruby.map_value({
				'path':         ruby.string_value(cask.sourcefile_path)
				'tap':          ruby.string_value(cask.tap_name)
				'tap_git_head': ruby.string_value(cask.tap_git_head_value)
				'version':      ruby.string_value(cask.version_text())
			})
			'uninstall_artifacts': ruby.array_value(cask.artifacts_list(true))
		}
	}
}

// Ruby method `config_path` at line 373.
pub fn ruby_cask_l373_d50_config_path(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'config_path') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.object_value('Pathname', cask.config_path())
}

// Ruby method `checksumable?` at line 378.
pub fn ruby_cask_l378_d51_checksumable(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'checksumable?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.checksumable())
}

// Ruby method `download_sha_path` at line 385.
pub fn ruby_cask_l385_d52_download_sha_path(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'download_sha_path') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.object_value('Pathname', cask.download_sha_path())
}

// Ruby method `new_download_sha` at line 390.
pub fn ruby_cask_l390_d53_new_download_sha(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'new_download_sha') or { return cask_error('ArgumentError', err.msg()) }
	value := cask.new_download_sha() or { return cask_error('CaskError', err.msg()) }
	return ruby.string_value(value)
}

// Ruby method `outdated_download_sha?` at line 403.
pub fn ruby_cask_l403_d54_outdated_download_sha(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'outdated_download_sha?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.outdated_download_sha())
}

// Ruby method `caskroom_path` at line 411.
pub fn ruby_cask_l411_d55_caskroom_path(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'caskroom_path') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.object_value('Pathname', cask.caskroom_path())
}

// Ruby method `outdated?(greedy: false, greedy_latest: false, greedy_auto_updates: false)` at line 422.
pub fn ruby_cask_l422_d56_outdated(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'outdated?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.outdated(CaskOutdatedOptions{
		greedy: cask_keyword_bool(args, 'greedy', false)
		greedy_latest: cask_keyword_bool(args, 'greedy_latest', false)
		greedy_auto_updates: cask_keyword_bool(args, 'greedy_auto_updates', false)
	}))
}

// Ruby method `outdated_version(greedy: false, greedy_latest: false, greedy_auto_updates: false)` at line 431.
pub fn ruby_cask_l431_d57_outdated_version(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'outdated_version') or { return cask_error('ArgumentError', err.msg()) }
	return cask_map_value(cask.outdated_version(CaskOutdatedOptions{
		greedy: cask_keyword_bool(args, 'greedy', false)
		greedy_latest: cask_keyword_bool(args, 'greedy_latest', false)
		greedy_auto_updates: cask_keyword_bool(args, 'greedy_auto_updates', false)
	}))
}

// Ruby method `outdated_info(greedy, verbose, json, greedy_latest, greedy_auto_updates)` at line 463.
pub fn ruby_cask_l463_d58_outdated_info(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'outdated_info') or { return cask_error('ArgumentError', err.msg()) }
	return cask.outdated_info(CaskOutdatedOptions{
		greedy: if args.len > 1 { args[1].as_bool() or { false } } else { false }
		greedy_latest: if args.len > 4 { args[4].as_bool() or { false } } else { false }
		greedy_auto_updates: if args.len > 5 { args[5].as_bool() or { false } } else { false }
	}, if args.len > 2 { args[2].as_bool() or { false } } else { false }, if args.len > 3 {
		args[3].as_bool() or { false }
	} else {
		false
	})
}

// Ruby method `ruby_source_path` at line 485.
pub fn ruby_cask_l485_d59_ruby_source_path(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'ruby_source_path') or { return cask_error('ArgumentError', err.msg()) }
	return cask_map_value(cask.ruby_source_path())
}

// Ruby method `ruby_source_checksum` at line 495.
pub fn ruby_cask_l495_d60_ruby_source_checksum(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'ruby_source_checksum') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.map_value({
		'sha256': cask_map_value(cask.ruby_source_checksum())
	})
}

// Ruby method `languages` at line 508.
pub fn ruby_cask_l508_d61_languages(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'languages') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.string_array_value(cask.languages())
}

// Ruby method `tap_git_head` at line 513.
pub fn ruby_cask_l513_d62_tap_git_head(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'tap_git_head') or { return cask_error('ArgumentError', err.msg()) }
	return cask_map_value(cask.tap_git_head_value)
}

// Ruby method `populate_from_api!(cask_struct, tap_git_head:)` at line 520.
pub fn ruby_cask_l520_d63_populate_from_api(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'populate_from_api!') or { return cask_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return cask_error('ArgumentError', 'populate_from_api! requires a cask struct')
	}
	source := args[1].map_data.clone()
	head := cask_value_string(cask_keyword_args(args), 'tap_git_head')
	cask.populate_from_api(source, head) or { return cask_error('ArgumentError', err.msg()) }
	return cask_core_value(cask)
}

// Ruby method `to_s = token` at line 535.
pub fn ruby_cask_l535_d64_to_s(args ...ruby.Value) ruby.Value {
	return ruby_cask_l28_d1_token(...args)
}

// Ruby method `inspect` at line 538.
pub fn ruby_cask_l538_d65_inspect(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'inspect') or { return cask_error('ArgumentError', err.msg()) }
	path := if cask.sourcefile_path == '' { '' } else { ' ${cask.sourcefile_path}' }
	return ruby.string_value('#<Cask ${cask.token}${path}>')
}

// Ruby method `hash` at line 543.
pub fn ruby_cask_l543_d66_hash(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'hash') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.int_value(i64(cask.token.hash()))
}

// Ruby method `eql?(other)` at line 548.
pub fn ruby_cask_l548_d67_eql(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'eql?') or { return cask_error('ArgumentError', err.msg()) }
	if args.len < 2 || args[1].type_name != 'Cask::Cask' {
		return ruby.bool_value(false)
	}
	other := cask_core_from_value(args[1]) or { return ruby.bool_value(false) }
	return ruby.bool_value(cask.token == other.token)
}

// Ruby alias `alias == eql?` at line 551.
pub fn ruby_cask_l551_d68_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_cask_l548_d67_eql(...args)
}

// Ruby method `to_h` at line 554.
pub fn ruby_cask_l554_d69_to_h(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'to_h') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.map_value(cask.to_h())
}

// Ruby method `to_hash_with_variations` at line 611.
pub fn ruby_cask_l611_d70_to_hash_with_variations(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'to_hash_with_variations') or { return cask_error('ArgumentError', err.msg()) }
	result := cask.to_hash_with_variations() or { return cask_error('UsageError', err.msg()) }
	return ruby.map_value(result)
}

// Ruby method `to_h_with_language_variations` at line 664.
pub fn ruby_cask_l664_d71_to_h_with_language_variations(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'to_h_with_language_variations') or { return cask_error('ArgumentError', err.msg()) }
	result := cask.to_h_with_language_variations() or { return cask_error('CaskInvalidError', err.msg()) }
	return ruby.map_value(result)
}

// Ruby method `to_installed_json_hash` at line 700.
pub fn ruby_cask_l700_d72_to_installed_json_hash(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'to_installed_json_hash') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.map_value(cask.to_installed_json_hash())
}

// Ruby method `artifacts_list(uninstall_only: false)` at line 708.
pub fn ruby_cask_l708_d73_artifacts_list(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'artifacts_list') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.array_value(cask.artifacts_list(cask_keyword_bool(args, 'uninstall_only', false)))
}

// Ruby method `rename_list(uninstall_only: false)` at line 734.
pub fn ruby_cask_l734_d74_rename_list(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'rename_list') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.array_value(cask.rename_list())
}

// Ruby method `platform_supported?(bottle_tag)` at line 743.
pub fn ruby_cask_l743_d75_platform_supported(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'platform_supported?') or { return cask_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return cask_error('ArgumentError', 'platform_supported? requires a bottle tag')
	}
	tag := homebrew.new_bottle_tag(args[1].attributes['system'] or { cask_value_string(args[1].map_data, 'system') }, args[1].attributes['arch'] or { cask_value_string(args[1].map_data, 'arch') })
	return ruby.bool_value(cask.platform_supported(tag))
}

// Ruby method `caveats_for_api` at line 767.
pub fn ruby_cask_l767_d76_caveats_for_api(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'caveats_for_api') or { return cask_error('ArgumentError', err.msg()) }
	return cask_map_value(cask.caveats_for_api())
}

// Ruby method `bundle_version` at line 773.
pub fn ruby_cask_l773_d77_bundle_version(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'bundle_version') or { return cask_error('ArgumentError', err.msg()) }
	bundle := cask.bundle_version() or { return cask_nil() }
	return ruby.Value{
		type_name: 'Homebrew::BundleVersion'
		repr: bundle.version
		map_data: {
			'short_version': cask_map_value(bundle.short_version)
			'version':       cask_map_value(bundle.version)
		}
	}
}

// Ruby method `dsl!` at line 784.
pub fn ruby_cask_l784_d78_dsl(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'dsl!') or { return cask_error('RuntimeError', err.msg()) }
	return cask_dsl_value(cask.dsl)
}

// Ruby method `single_app_artifact` at line 789.
pub fn ruby_cask_l789_d79_single_app_artifact(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'single_app_artifact') or { return cask_error('ArgumentError', err.msg()) }
	apps := cask.dsl.artifacts.items.filter(cask_artifact_key(it) == 'app')
	return if apps.len == 1 { apps[0] } else { cask_nil() }
}

// Ruby method `installed_app_info_plist` at line 797.
pub fn ruby_cask_l797_d80_installed_app_info_plist(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'installed_app_info_plist') or { return cask_error('ArgumentError', err.msg()) }
	return cask_optional_string(cask.installed_app_info_plist(), 'Pathname')
}

// Ruby method `compare_version_strings(first, second)` at line 805.
pub fn ruby_cask_l805_d81_compare_version_strings(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return cask_nil()
	}
	comparison := compare_cask_version_strings(args[1].as_string(), args[2].as_string()) or { return cask_nil() }
	return ruby.int_value(comparison)
}

// Ruby method `auto_updates_bundle_outdated?` at line 815.
pub fn ruby_cask_l815_d82_auto_updates_bundle_outdated(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'auto_updates_bundle_outdated?') or { return cask_error('ArgumentError', err.msg()) }
	return ruby.bool_value(cask.auto_updates_bundle_outdated())
}

// Ruby method `api_to_local_hash(hash)` at line 859.
pub fn ruby_cask_l859_d83_api_to_local_hash(args ...ruby.Value) ruby.Value {
	mut cask := cask_receiver(args, 'api_to_local_hash') or { return cask_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return cask_error('ArgumentError', 'api_to_local_hash requires a hash')
	}
	return ruby.map_value(cask.api_to_local_hash(args[1].map_data))
}

// Ruby method `url_specs` at line 869.
pub fn ruby_cask_l869_d84_url_specs(args ...ruby.Value) ruby.Value {
	cask := cask_receiver(args, 'url_specs') or { return cask_error('ArgumentError', err.msg()) }
	return cask.url_specs()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle_version"
// 5: require "cask/cask_loader"
// 6: require "cask/config"
// 7: require "cask/dsl"
// 8: require "cask/metadata"
// 9: require "cask/tab"
// 10: require "utils/output"
// 11: require "api_hashable"
// 12: require "trust"
// 13:
// 14: module Cask
// 15:   # An instance of a cask.
// 16:   class Cask
// 17:     extend Forwardable
// 18:     extend APIHashable
// 19:     extend ::Utils::Output::Mixin
// 20:     include Metadata
// 21:
// 22:     # The unique identifier for this {Cask}, used to refer to it in commands
// 23:     # and tap paths.
// 24:     # e.g. `firefox`
// 25:     #
// 26:     # @api public
// 27:     sig { returns(String) }
// 28:     attr_reader :token
// 29:
// 30:     # The configuration of this {Cask}.
// 31:     #
// 32:     # @api internal
// 33:     sig { returns(Config) }
// 34:     attr_reader :config
// 35:
// 36:     sig { returns(T.nilable(Pathname)) }
// 37:     attr_reader :sourcefile_path
// 38:
// 39:     sig { returns(T.nilable(String)) }
// 40:     attr_reader :source
// 41:
// 42:     sig { returns(Config) }
// 43:     attr_reader :default_config
// 44:
// 45:     sig { returns(T.nilable(CaskLoader::ILoader)) }
// 46:     attr_reader :loader
// 47:
// 48:     sig { returns(T.nilable(Pathname)) }
// 49:     attr_accessor :download
// 50:
// 51:     sig { returns(T::Boolean) }
// 52:     attr_accessor :allow_reassignment
// 53:
// 54:     sig { params(eval_all: T::Boolean).returns(T::Array[Cask]) }
// 55:     def self.all(eval_all: false)
// 56:       if !eval_all && !Homebrew::EnvConfig.tap_trust_configured?
// 57:         raise ArgumentError,
// 58:               "Cask::Cask#all cannot be used without `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 59:               "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1`"
// 60:       end
// 61:
// 62:       # Load core casks from tokens so they load from the API when the core cask is not tapped.
// 63:       tokens_and_files = CoreCaskTap.instance.cask_tokens
// 64:       tokens_and_files += Tap.reject(&:core_cask_tap?).flat_map(&:cask_files)
// 65:                              .then { |files| Homebrew::Trust.trusted_cask_files(files) }
// 66:       tokens_and_files.filter_map do |token_or_file|
// 67:         CaskLoader.load(token_or_file)
// 68:       rescue CaskUnreadableError, CaskInvalidError => e
// 69:         # Don't let one broken cask break commands. But do complain.
// 70:         opoo e.message
// 71:
// 72:         nil
// 73:       end
// 74:     end
// 75:
// 76:     # This collides with Kernel#tap, complicating the type signature.
// 77:     # Overload sigs are not supported by Sorbet, otherwise we would use:
// 78:     #   sig { params(blk: T.proc.params(arg0: Cask).void).returns(T.self_type) }
// 79:     #   sig { params(blk: NilClass).returns(T.nilable(Tap)) }
// 80:     # Using a union type would require casts or type guards at call sites,
// 81:     # so T.untyped is used as the return type instead.
// 82:     sig { params(blk: T.nilable(T.proc.params(arg0: Cask).void)).returns(T.untyped) }
// 83:     def tap(&blk)
// 84:       return super if block_given? # Kernel#tap
// 85:
// 86:       @tap
// 87:     end
// 88:
// 89:     sig {
// 90:       params(
// 91:         token:                    String,
// 92:         sourcefile_path:          T.nilable(Pathname),
// 93:         source:                   T.nilable(String),
// 94:         tap:                      T.nilable(Tap),
// 95:         loaded_from_api:          T::Boolean,
// 96:         loaded_from_internal_api: T::Boolean,
// 97:         api_source:               T.nilable(T::Hash[String, T.untyped]),
// 98:         config:                   T.nilable(Config),
// 99:         allow_reassignment:       T::Boolean,
// 100:         loader:                   T.nilable(CaskLoader::ILoader),
// 101:         block:                    T.nilable(T.proc.bind(DSL).void),
// 102:       ).void
// 103:     }
// 104:     def initialize(token, sourcefile_path: nil, source: nil, tap: nil, loaded_from_api: false,
// 105:                    loaded_from_internal_api: false, api_source: nil, config: nil, allow_reassignment: false,
// 106:                    loader: nil, &block)
// 107:       @token = token
// 108:       @sourcefile_path = sourcefile_path
// 109:       @source = source
// 110:       @tap = tap
// 111:       @allow_reassignment = allow_reassignment
// 112:       @loaded_from_api = loaded_from_api
// 113:       @loaded_from_internal_api = loaded_from_internal_api
// 114:       @api_source = api_source
// 115:       @language_variations_available = T.let(false, T::Boolean)
// 116:       @language_evaluator = T.let(nil, T.nilable(T.proc.params(languages: T::Array[String]).returns(T.nilable(String))))
// 117:       @loader = loader
// 118:       # Sorbet has trouble with bound procs assigned to instance variables:
// 119:       # https://github.com/sorbet/sorbet/issues/6843
// 120:       @block = T.let(block, T.untyped)
// 121:
// 122:       @default_config = T.let(config || Config.new, Config)
// 123:
// 124:       @config = T.let(
// 125:         if config_path.exist?
// 126:           Config.from_json(File.read(config_path), ignore_invalid_keys: true)
// 127:         else
// 128:           @default_config
// 129:         end,
// 130:         Config,
// 131:       )
// 132:       refresh
// 133:     end
// 134:
// 135:     sig { returns(T::Boolean) }
// 136:     def loaded_from_api? = @loaded_from_api
// 137:
// 138:     sig { returns(T::Boolean) }
// 139:     def loaded_from_internal_api? = @loaded_from_internal_api
// 140:
// 141:     sig { returns(T.any(String, Pathname)) }
// 142:     def reloadable_ref
// 143:       return full_name if loaded_from_api?
// 144:
// 145:       sourcefile_path || raise("unexpected nil cask sourcefile_path")
// 146:     end
// 147:
// 148:     sig { returns(T.nilable(T::Hash[String, T.untyped])) }
// 149:     attr_reader :api_source
// 150:
// 151:     # An old name for the cask.
// 152:     sig { returns(T::Array[String]) }
// 153:     def old_tokens
// 154:       @old_tokens ||= T.let(
// 155:         if (t = tap)
// 156:           Tap.tap_migration_oldnames(t, token) +
// 157:             t.cask_reverse_renames.fetch(token, [])
// 158:         else
// 159:           []
// 160:         end,
// 161:         T.nilable(T::Array[String]),
// 162:       )
// 163:     end
// 164:
// 165:     sig { params(config: Config).void }
// 166:     def config=(config)
// 167:       @config = config
// 168:
// 169:       refresh
// 170:     end
// 171:
// 172:     sig { void }
// 173:     def refresh
// 174:       @dsl = T.let(DSL.new(self), T.nilable(DSL))
// 175:       return unless @block
// 176:
// 177:       dsl!.instance_eval(&@block)
// 178:       dsl!.language_eval
// 179:     rescue NoMethodError => e
// 180:       raise CaskInvalidError.new(token, e.message), e.backtrace
// 181:     end
// 182:
// 183:     # Refresh the cask as evaluated on `tag` and yield. Returns `nil` instead of
// 184:     # raising when the cask has `on_system` blocks that omit the tag.
// 185:     sig {
// 186:       type_parameters(:U)
// 187:         .params(tag: ::Utils::Bottles::Tag, _block: T.proc.returns(T.type_parameter(:U)))
// 188:         .returns(T.nilable(T.type_parameter(:U)))
// 189:     }
// 190:     def refresh_for_tag(tag, &_block)
// 191:       Homebrew::SimulateSystem.with(os: tag.system, arch: tag.arch) do
// 192:         refresh
// 193:         yield
// 194:       end
// 195:     rescue CaskInvalidError, CaskUnreadableError
// 196:       raise unless on_system_blocks_exist?
// 197:
// 198:       nil
// 199:     end
// 200:
// 201:     def_delegators :@dsl, *(::Cask::DSL::DSL_METHODS - [:language])
// 202:
// 203:     sig {
// 204:       params(
// 205:         args:    String,
// 206:         default: T::Boolean,
// 207:         block:   T.nilable(T.proc.returns(String)),
// 208:       ).returns(T.nilable(String))
// 209:     }
// 210:     def language(*args, default: false, &block)
// 211:       return @language_evaluator.call(config.languages) if args.empty? && block.nil? && @language_evaluator
// 212:
// 213:       dsl!.language(*args, default:, &block)
// 214:     end
// 215:
// 216:     sig { returns(DSL::Caveats) }
// 217:     def caveats_object = dsl!.caveats_object
// 218:
// 219:     sig { params(caskroom_path: Pathname).returns(T::Array[[String, String]]) }
// 220:     def timestamped_versions(caskroom_path: self.caskroom_path)
// 221:       pattern = metadata_timestamped_path(version: "*", timestamp: "*", caskroom_path:).to_s
// 222:       relative_paths = Pathname.glob(pattern)
// 223:                                .map { |p| p.relative_path_from(p.parent.parent) }
// 224:       # Sorbet is unaware that Pathname is sortable: https://github.com/sorbet/sorbet/issues/6844
// 225:       T.unsafe(relative_paths).sort_by(&:basename) # sort by timestamp
// 226:        .map { |p| p.split.map(&:to_s) }
// 227:     end
// 228:
// 229:     # The fully-qualified token of this {Cask}.
// 230:     #
// 231:     # @api internal
// 232:     sig { returns(String) }
// 233:     def full_token
// 234:       return token if (t = tap).nil?
// 235:       return token if t.core_cask_tap?
// 236:
// 237:       "#{t.name}/#{token}"
// 238:     end
// 239:
// 240:     # Alias for {#full_token}.
// 241:     #
// 242:     # @api internal
// 243:     sig { returns(String) }
// 244:     def full_name = full_token
// 245:
// 246:     sig { returns(T::Boolean) }
// 247:     def installed?
// 248:       installed_caskfile&.exist? || false
// 249:     end
// 250:
// 251:     sig { returns(T::Boolean) }
// 252:     def any_version_installed? = installed?
// 253:
// 254:     sig { returns(T::Boolean) }
// 255:     def font?
// 256:       artifacts.all?(Artifact::Font)
// 257:     end
// 258:
// 259:     sig { returns(T::Boolean) }
// 260:     def installable_artifact?
// 261:       artifacts.any? do |artifact|
// 262:         artifact.respond_to?(:install_phase) || artifact.is_a?(Artifact::StageOnly)
// 263:       end
// 264:     end
// 265:
// 266:     sig { returns(T::Boolean) }
// 267:     def supports_linux?
// 268:       return true if depends_on.requires_linux?
// 269:
// 270:       !depends_on.requires_macos?
// 271:     end
// 272:
// 273:     sig { returns(T::Boolean) }
// 274:     def supports_macos?
// 275:       !depends_on.requires_linux?
// 276:     end
// 277:
// 278:     # The caskfile is needed during installation when there are legacy
// 279:     # `*flight` blocks or language variations missing from API data.
// 280:     sig { returns(T::Boolean) }
// 281:     def caskfile_only?
// 282:       (languages.any? && !@language_variations_available) || artifacts.any?(Artifact::AbstractFlightBlock)
// 283:     end
// 284:
// 285:     sig { returns(T::Boolean) }
// 286:     def uninstall_flight_blocks?
// 287:       artifacts.any? do |artifact|
// 288:         case artifact
// 289:         when Artifact::PreflightBlock
// 290:           artifact.directives.key?(:uninstall_preflight)
// 291:         when Artifact::PostflightBlock
// 292:           artifact.directives.key?(:uninstall_postflight)
// 293:         end
// 294:       end
// 295:     end
// 296:
// 297:     sig { returns(T.nilable(Time)) }
// 298:     def install_time
// 299:       # <caskroom_path>/.metadata/<version>/<timestamp>/Casks/<token>.{rb,json} -> <timestamp>
// 300:       caskfile = installed_caskfile
// 301:       Time.strptime(caskfile.dirname.dirname.basename.to_s, Metadata::TIMESTAMP_FORMAT) if caskfile
// 302:     end
// 303:
// 304:     sig { returns(T.nilable(Pathname)) }
// 305:     def installed_caskfile
// 306:       Caskroom.cask_installed_caskfile(token, old_tokens:)
// 307:     end
// 308:
// 309:     sig { returns(T.nilable(String)) }
// 310:     def installed_version
// 311:       # <caskroom_path>/.metadata/<version>/<timestamp>/Casks/<token>.{rb,json} -> <version>
// 312:       Caskroom.cask_installed_version(token, old_tokens:)
// 313:     end
// 314:
// 315:     sig { void }
// 316:     def pin
// 317:       return unless (installed_version = self.installed_version)
// 318:
// 319:       versioned_path = caskroom_path/installed_version
// 320:       return unless versioned_path.exist?
// 321:
// 322:       HOMEBREW_PINNED_CASKS.mkpath
// 323:       return if pinned?
// 324:
// 325:       pin_path.unlink if pin_path.file? || pin_path.symlink?
// 326:       pin_path.make_relative_symlink(versioned_path)
// 327:     end
// 328:
// 329:     sig { void }
// 330:     def unpin
// 331:       pin_path.unlink if pin_path.symlink?
// 332:       HOMEBREW_PINNED_CASKS.rmdir_if_possible
// 333:     end
// 334:
// 335:     sig { returns(T::Boolean) }
// 336:     def pinned?
// 337:       pin_path.symlink? && pin_path.exist?
// 338:     end
// 339:
// 340:     sig { returns(T::Boolean) }
// 341:     def pinnable?
// 342:       return false unless (installed_version = self.installed_version)
// 343:
// 344:       (caskroom_path/installed_version).exist?
// 345:     end
// 346:
// 347:     sig { returns(T.nilable(String)) }
// 348:     def pinned_version
// 349:       pin_path.resolved_path.basename.to_s if pinned?
// 350:     end
// 351:
// 352:     sig { returns(Pathname) }
// 353:     def pin_path
// 354:       HOMEBREW_PINNED_CASKS/token
// 355:     end
// 356:
// 357:     sig { returns(T.nilable(String)) }
// 358:     def bundle_short_version
// 359:       bundle_version&.short_version
// 360:     end
// 361:
// 362:     sig { returns(T.nilable(String)) }
// 363:     def bundle_long_version
// 364:       bundle_version&.version
// 365:     end
// 366:
// 367:     sig { returns(Tab) }
// 368:     def tab
// 369:       Tab.for_cask(self)
// 370:     end
// 371:
// 372:     sig { returns(Pathname) }
// 373:     def config_path
// 374:       metadata_main_container_path/"config.json"
// 375:     end
// 376:
// 377:     sig { returns(T::Boolean) }
// 378:     def checksumable?
// 379:       return false if (url = self.url).nil? || url.to_s.blank?
// 380:
// 381:       DownloadStrategyDetector.detect(url.to_s, url.using) <= AbstractFileDownloadStrategy || false
// 382:     end
// 383:
// 384:     sig { returns(Pathname) }
// 385:     def download_sha_path
// 386:       metadata_main_container_path/"LATEST_DOWNLOAD_SHA256"
// 387:     end
// 388:
// 389:     sig { returns(String) }
// 390:     def new_download_sha
// 391:       require "cask/installer"
// 392:
// 393:       # Call checksumable? before hashing
// 394:       @new_download_sha ||= T.let(
// 395:         Installer.new(self, verify_download_integrity: false)
// 396:                  .download(quiet: true)
// 397:                  .instance_eval { |x| Digest::SHA256.file(x).hexdigest },
// 398:         T.nilable(String),
// 399:       )
// 400:     end
// 401:
// 402:     sig { returns(T::Boolean) }
// 403:     def outdated_download_sha?
// 404:       return true unless checksumable?
// 405:
// 406:       current_download_sha = download_sha_path.read if download_sha_path.exist?
// 407:       current_download_sha.blank? || current_download_sha != new_download_sha
// 408:     end
// 409:
// 410:     sig { returns(Pathname) }
// 411:     def caskroom_path
// 412:       @caskroom_path ||= T.let(Caskroom.path.join(token), T.nilable(Pathname))
// 413:     end
// 414:
// 415:     # Check if the installed cask is outdated.
// 416:     #
// 417:     # @api internal
// 418:     sig {
// 419:       params(greedy: T::Boolean, greedy_latest: T.nilable(T::Boolean), greedy_auto_updates: T.nilable(T::Boolean))
// 420:         .returns(T::Boolean)
// 421:     }
// 422:     def outdated?(greedy: false, greedy_latest: false, greedy_auto_updates: false)
// 423:       !outdated_version(greedy:, greedy_latest:,
// 424:                         greedy_auto_updates:).nil?
// 425:     end
// 426:
// 427:     sig {
// 428:       params(greedy: T::Boolean, greedy_latest: T.nilable(T::Boolean), greedy_auto_updates: T.nilable(T::Boolean))
// 429:         .returns(T.nilable(String))
// 430:     }
// 431:     def outdated_version(greedy: false, greedy_latest: false, greedy_auto_updates: false)
// 432:       # special case: tap version is not available
// 433:       return if version.nil?
// 434:
// 435:       if version.latest?
// 436:         return installed_version if (greedy || greedy_latest) && outdated_download_sha?
// 437:
// 438:         return
// 439:       end
// 440:
// 441:       return if installed_version == version
// 442:
// 443:       if auto_updates && !greedy && !greedy_auto_updates
// 444:         return unless Homebrew::EnvConfig.upgrade_auto_updates_casks?
// 445:
// 446:         return installed_version if auto_updates_bundle_outdated?
// 447:
// 448:         return
// 449:       end
// 450:
// 451:       installed_version
// 452:     end
// 453:
// 454:     sig {
// 455:       params(
// 456:         greedy:              T::Boolean,
// 457:         verbose:             T::Boolean,
// 458:         json:                T::Boolean,
// 459:         greedy_latest:       T::Boolean,
// 460:         greedy_auto_updates: T::Boolean,
// 461:       ).returns(T.any(String, T::Hash[Symbol, T.untyped]))
// 462:     }
// 463:     def outdated_info(greedy, verbose, json, greedy_latest, greedy_auto_updates)
// 464:       return token if !verbose && !json
// 465:
// 466:       installed_version = outdated_version(greedy:, greedy_latest:,
// 467:                                            greedy_auto_updates:).to_s
// 468:
// 469:       if json
// 470:         {
// 471:           name:               token,
// 472:           installed_versions: [installed_version],
// 473:           current_version:    version,
// 474:           pinned:             pinned?,
// 475:           pinned_version:,
// 476:         }
// 477:       else
// 478:         pinned = " [pinned at #{pinned_version}]" if pinned?
// 479:
// 480:         "#{token} (#{installed_version}) != #{version}#{pinned}"
// 481:       end
// 482:     end
// 483:
// 484:     sig { returns(T.nilable(String)) }
// 485:     def ruby_source_path
// 486:       return @ruby_source_path if defined?(@ruby_source_path)
// 487:
// 488:       return unless (sfp = sourcefile_path)
// 489:       return unless (t = tap)
// 490:
// 491:       @ruby_source_path = T.let(sfp.relative_path_from(t.path).to_s, T.nilable(String))
// 492:     end
// 493:
// 494:     sig { returns(T::Hash[Symbol, T.nilable(String)]) }
// 495:     def ruby_source_checksum
// 496:       @ruby_source_checksum ||= T.let(
// 497:         begin
// 498:           sfp = sourcefile_path
// 499:           {
// 500:             sha256: sfp ? Digest::SHA256.file(sfp).hexdigest : nil,
// 501:           }.freeze
// 502:         end,
// 503:         T.nilable(T::Hash[Symbol, T.nilable(String)]),
// 504:       )
// 505:     end
// 506:
// 507:     sig { returns(T::Array[String]) }
// 508:     def languages
// 509:       @languages ||= T.let(dsl!.languages, T.nilable(T::Array[String]))
// 510:     end
// 511:
// 512:     sig { returns(T.nilable(String)) }
// 513:     def tap_git_head
// 514:       @tap_git_head ||= T.let(tap&.git_head, T.nilable(String))
// 515:     rescue TapUnavailableError
// 516:       nil
// 517:     end
// 518:
// 519:     sig { params(cask_struct: Homebrew::API::CaskStruct, tap_git_head: T.nilable(String)).void }
// 520:     def populate_from_api!(cask_struct, tap_git_head:)
// 521:       raise ArgumentError, "Expected cask to be loaded from the API" unless loaded_from_api?
// 522:
// 523:       @languages = cask_struct.languages
// 524:       @language_variations_available = cask_struct.language_variations.any?
// 525:       @language_evaluator = ->(languages) { cask_struct.language(languages) }
// 526:       @tap_git_head = tap_git_head
// 527:       @ruby_source_path = cask_struct.ruby_source_path
// 528:       @ruby_source_checksum = cask_struct.ruby_source_checksum
// 529:     end
// 530:
// 531:     # The string representation of this {Cask}, returning its {#token}.
// 532:     #
// 533:     # @api public
// 534:     sig { returns(String) }
// 535:     def to_s = token
// 536:
// 537:     sig { returns(String) }
// 538:     def inspect
// 539:       "#<Cask #{token}#{sourcefile_path&.to_s&.prepend(" ")}>"
// 540:     end
// 541:
// 542:     sig { returns(Integer) }
// 543:     def hash
// 544:       token.hash
// 545:     end
// 546:
// 547:     sig { params(other: T.untyped).returns(T::Boolean) }
// 548:     def eql?(other)
// 549:       instance_of?(other.class) && token == other.token
// 550:     end
// 551:     alias == eql?
// 552:
// 553:     sig { returns(T::Hash[String, T.untyped]) }
// 554:     def to_h
// 555:       {
// 556:         "token"                           => token,
// 557:         "full_token"                      => full_name,
// 558:         "old_tokens"                      => old_tokens,
// 559:         "tap"                             => tap&.name,
// 560:         "name"                            => name,
// 561:         "desc"                            => desc,
// 562:         "homepage"                        => homepage,
// 563:         "url"                             => url,
// 564:         "url_specs"                       => url_specs,
// 565:         "version"                         => version,
// 566:         "autobump"                        => autobump?,
// 567:         "no_autobump_message"             => no_autobump_message,
// 568:         "skip_livecheck"                  => livecheck.skip?,
// 569:         "installed"                       => installed_version,
// 570:         "installed_time"                  => install_time&.to_i,
// 571:         "bundle_version"                  => bundle_long_version,
// 572:         "bundle_short_version"            => bundle_short_version,
// 573:         "pinned"                          => pinned?,
// 574:         "pinned_version"                  => pinned_version,
// 575:         "outdated"                        => outdated?,
// 576:         "sha256"                          => sha256,
// 577:         "artifacts"                       => artifacts_list,
// 578:         "caveats"                         => caveats_for_api,
// 579:         "caveats_rosetta"                 => caveats_object.invoked?(:requires_rosetta) || nil,
// 580:         "depends_on"                      => depends_on,
// 581:         "conflicts_with"                  => conflicts_with,
// 582:         "container"                       => container&.pairs,
// 583:         "rename"                          => rename_list,
// 584:         "auto_updates"                    => auto_updates,
// 585:         "deprecated"                      => deprecated?,
// 586:         "deprecation_date"                => deprecation_date,
// 587:         "deprecation_reason"              => deprecation_reason,
// 588:         "deprecation_replacement_formula" => deprecation_replacement_formula,
// 589:         "deprecation_replacement_cask"    => deprecation_replacement_cask,
// 590:         "deprecate_args"                  => deprecate_args,
// 591:         "disabled"                        => disabled?,
// 592:         "disable_date"                    => disable_date,
// 593:         "disable_reason"                  => disable_reason,
// 594:         "disable_replacement_formula"     => disable_replacement_formula,
// 595:         "disable_replacement_cask"        => disable_replacement_cask,
// 596:         "disable_args"                    => disable_args,
// 597:         "tap_git_head"                    => tap_git_head,
// 598:         "languages"                       => languages,
// 599:         "ruby_source_path"                => ruby_source_path,
// 600:         "ruby_source_checksum"            => ruby_source_checksum,
// 601:       }
// 602:     end
// 603:
// 604:     HASH_KEYS_TO_SKIP = %w[outdated installed pinned pinned_version versions].freeze
// 605:     private_constant :HASH_KEYS_TO_SKIP
// 606:
// 607:     AUTO_UPDATES_BAD_BUNDLE_VERSIONS = %w[0 0.0].freeze
// 608:     private_constant :AUTO_UPDATES_BAD_BUNDLE_VERSIONS
// 609:
// 610:     sig { returns(T::Hash[String, T.untyped]) }
// 611:     def to_hash_with_variations
// 612:       if loaded_from_internal_api?
// 613:         raise UsageError, "Cannot call #to_hash_with_variations on casks loaded from the internal API"
// 614:       end
// 615:
// 616:       if loaded_from_api? && (json_cask = api_source) && !Homebrew::EnvConfig.no_install_from_api?
// 617:         return api_to_local_hash(json_cask.dup)
// 618:       end
// 619:
// 620:       hash = to_h_with_language_variations
// 621:       variations = {}
// 622:       supported_platforms = []
// 623:       on_system_blocks_exist = dsl!.on_system_blocks_exist?
// 624:
// 625:       if on_system_blocks_exist
// 626:         begin
// 627:           OnSystem::VALID_OS_ARCH_TAGS.each do |bottle_tag|
// 628:             macos_requirements = [depends_on.macos, depends_on.maximum_macos].compact
// 629:             next if bottle_tag.macos? &&
// 630:                     macos_requirements.present? &&
// 631:                     !dsl!.depends_on_set_in_block? &&
// 632:                     macos_requirements.any? do |requirement|
// 633:                       # Avoid recursive equality between cached version-comparison keys across casks.
// 634:                       !requirement.allows?(MacOSVersion.from_symbol(bottle_tag.system))
// 635:                     end
// 636:
// 637:             refresh_for_tag(bottle_tag) do
// 638:               supported_platforms << bottle_tag.to_sym if platform_supported?(bottle_tag)
// 639:
// 640:               to_h_with_language_variations.each do |key, value|
// 641:                 next if HASH_KEYS_TO_SKIP.include? key
// 642:                 next if value.to_s == hash[key].to_s
// 643:
// 644:                 variations[bottle_tag.to_sym] ||= {}
// 645:                 variations[bottle_tag.to_sym][key] = value
// 646:               end
// 647:             end
// 648:           end
// 649:         ensure
// 650:           refresh
// 651:         end
// 652:       else
// 653:         supported_platforms = OnSystem::VALID_OS_ARCH_TAGS.filter_map do |bottle_tag|
// 654:           bottle_tag.to_sym if platform_supported?(bottle_tag)
// 655:         end
// 656:       end
// 657:
// 658:       hash["variations"] = variations
// 659:       hash["supported_platforms"] = supported_platforms
// 660:       hash
// 661:     end
// 662:
// 663:     sig { returns(T::Hash[String, T.untyped]) }
// 664:     def to_h_with_language_variations
// 665:       language_groups = dsl!.language_groups
// 666:       return to_h if language_groups.empty?
// 667:
// 668:       default_language_group = dsl!.default_language_group
// 669:       raise CaskInvalidError.new(self, "No default language specified.") if default_language_group.nil?
// 670:
// 671:       original_config = config
// 672:       language_hashes = language_groups.to_h do |languages|
// 673:         localised_config = original_config.dup
// 674:         localised_config.explicit = original_config.explicit.dup
// 675:         localised_config.languages = [languages.fetch(0)]
// 676:         self.config = localised_config
// 677:         [languages, [to_h, dsl!.language_eval]]
// 678:       end
// 679:       hash = language_hashes.fetch(default_language_group).first
// 680:       hash["language_variations"] = language_hashes.map do |languages, (language_hash, value)|
// 681:         variation = {
// 682:           "languages" => languages,
// 683:           "default"   => languages == default_language_group,
// 684:           "value"     => value,
// 685:         }
// 686:         language_hash.each do |key, language_value|
// 687:           next if HASH_KEYS_TO_SKIP.include? key
// 688:           next if language_value.to_s == hash[key].to_s
// 689:
// 690:           variation[key] = language_value
// 691:         end
// 692:         variation
// 693:       end
// 694:       hash
// 695:     ensure
// 696:       self.config = original_config if original_config
// 697:     end
// 698:
// 699:     sig { returns(T::Hash[String, T.untyped]) }
// 700:     def to_installed_json_hash
// 701:       cask_url = url
// 702:       return {} if cask_url.nil? || cask_url.only_path.blank?
// 703:
// 704:       { "url_specs" => { "only_path" => cask_url.only_path } }
// 705:     end
// 706:
// 707:     sig { params(uninstall_only: T::Boolean).returns(T::Array[T::Hash[Symbol, T.untyped]]) }
// 708:     def artifacts_list(uninstall_only: false)
// 709:       artifacts.filter_map do |artifact|
// 710:         case artifact
// 711:         when Artifact::AbstractFlightBlock
// 712:           uninstall_flight_block = artifact.directives.key?(:uninstall_preflight) ||
// 713:                                    artifact.directives.key?(:uninstall_postflight)
// 714:           next if uninstall_only && !uninstall_flight_block
// 715:
// 716:           # Only indicate whether this block is used as we don't load it from the API
// 717:           { artifact.summarize.to_sym => nil }
// 718:         else
// 719:           zap_artifact = artifact.is_a?(Artifact::Zap)
// 720:           uninstall_artifact = artifact.respond_to?(:uninstall_phase) || artifact.respond_to?(:post_uninstall_phase)
// 721:           next if uninstall_only && !zap_artifact && !uninstall_artifact
// 722:
// 723:           entry = T.let(
// 724:             { artifact.class.dsl_key => artifact.to_args },
// 725:             T::Hash[Symbol, T.any(String, T::Array[T.anything])],
// 726:           )
// 727:           entry[:target] = artifact.target.to_s if !uninstall_only && artifact.is_a?(Artifact::Relocated)
// 728:           entry
// 729:         end
// 730:       end
// 731:     end
// 732:
// 733:     sig { params(uninstall_only: T::Boolean).returns(T::Array[T::Hash[Symbol, T.untyped]]) }
// 734:     def rename_list(uninstall_only: false)
// 735:       rename.filter_map do |rename|
// 736:         { from: rename.from, to: rename.to }
// 737:       end
// 738:     end
// 739:
// 740:     private
// 741:
// 742:     sig { params(bottle_tag: ::Utils::Bottles::Tag).returns(T::Boolean) }
// 743:     def platform_supported?(bottle_tag)
// 744:       return false if bottle_tag.linux? && !supports_linux?
// 745:       return false if bottle_tag.macos? && !supports_macos?
// 746:       return false if version.blank? || sha256.blank? || url.blank?
// 747:       return false unless installable_artifact?
// 748:
// 749:       arch_supported = depends_on.arch&.any? do |arch|
// 750:         required_arch = ::Utils::Bottles::Tag.new(system: bottle_tag.system, arch: arch[:type]).standardized_arch
// 751:         required_arch == bottle_tag.standardized_arch
// 752:       end
// 753:       return false if arch_supported == false
// 754:
// 755:       return true unless bottle_tag.macos?
// 756:
// 757:       [depends_on.macos, depends_on.maximum_macos].compact.all? do |requirement|
// 758:         requirement.allows?(bottle_tag.to_macos_version)
// 759:       end
// 760:     end
// 761:
// 762:     # Returns caveats text for API serialization, excluding conditional
// 763:     # built-in caveats that depend on the current machine's state.
// 764:     # These are stored as separate boolean fields (e.g. caveats_rosetta)
// 765:     # and evaluated at install time instead.
// 766:     sig { returns(T.nilable(String)) }
// 767:     def caveats_for_api
// 768:       Tty.strip_ansi(caveats_object.to_s_without_conditional)
// 769:          .presence
// 770:     end
// 771:
// 772:     sig { returns(T.nilable(Homebrew::BundleVersion)) }
// 773:     def bundle_version
// 774:       @bundle_version ||= T.let(
// 775:         if (bundle = artifacts.find { |a| a.is_a?(Artifact::App) }&.target) &&
// 776:            (plist = Pathname("#{bundle}/Contents/Info.plist")) && plist.exist? && plist.readable?
// 777:           Homebrew::BundleVersion.from_info_plist(plist)
// 778:         end,
// 779:         T.nilable(Homebrew::BundleVersion),
// 780:       )
// 781:     end
// 782:
// 783:     sig { returns(DSL) }
// 784:     def dsl!
// 785:       @dsl || raise("unexpected nil @dsl")
// 786:     end
// 787:
// 788:     sig { returns(T.nilable(Artifact::App)) }
// 789:     def single_app_artifact
// 790:       app_artifacts = artifacts.grep(Artifact::App)
// 791:       return unless app_artifacts.one?
// 792:
// 793:       app_artifacts.first
// 794:     end
// 795:
// 796:     sig { returns(T.nilable(Pathname)) }
// 797:     def installed_app_info_plist
// 798:       return unless (app_artifact = single_app_artifact)
// 799:
// 800:       info_plist = app_artifact.target/"Contents/Info.plist"
// 801:       info_plist if info_plist.exist? && info_plist.readable?
// 802:     end
// 803:
// 804:     sig { params(first: T.nilable(String), second: T.nilable(String)).returns(T.nilable(Integer)) }
// 805:     def compare_version_strings(first, second)
// 806:       return if first.blank? || second.blank?
// 807:       return if first.split(".").size != second.split(".").size
// 808:
// 809:       Version.new(first) <=> Version.new(second)
// 810:     rescue
// 811:       nil
// 812:     end
// 813:
// 814:     sig { returns(T::Boolean) }
// 815:     def auto_updates_bundle_outdated?
// 816:       return false if !auto_updates || version.latest?
// 817:       return false unless installed_app_info_plist
// 818:
// 819:       tap_short_version = version.csv.first.to_s.presence || version.to_s
// 820:
// 821:       begin
// 822:         installed_short_version = bundle_short_version
// 823:         installed_bundle_version = bundle_long_version
// 824:       rescue ErrorDuringExecution
// 825:         return false
// 826:       end
// 827:       installed_bundle_version = nil if AUTO_UPDATES_BAD_BUNDLE_VERSIONS.include?(installed_bundle_version)
// 828:       installed_short_version = nil if AUTO_UPDATES_BAD_BUNDLE_VERSIONS.include?(installed_short_version)
// 829:       return false if installed_short_version.nil? && installed_bundle_version.nil?
// 830:
// 831:       # Some apps split a cask version like 2.61-2057 across the short
// 832:       # version and bundle version fields.
// 833:       if installed_short_version && installed_bundle_version
// 834:         combined_version_comparisons = version.csv.filter_map do |candidate|
// 835:           compare_version_strings("#{installed_short_version}-#{installed_bundle_version}", candidate.to_s)
// 836:         end
// 837:         return false if combined_version_comparisons.include?(0)
// 838:         return false if combined_version_comparisons.present? && combined_version_comparisons.exclude?(-1)
// 839:       end
// 840:
// 841:       return false if [installed_short_version, installed_bundle_version].any? do |installed_plist_version|
// 842:         compare_version_strings(installed_plist_version, tap_short_version)&.zero?
// 843:       end
// 844:
// 845:       short_comparison = compare_version_strings(installed_short_version, tap_short_version)
// 846:       return true if short_comparison == -1
// 847:       return false if short_comparison == 1
// 848:
// 849:       build_comparisons = version.csv.filter_map do |candidate|
// 850:         compare_version_strings(installed_bundle_version, candidate.to_s)
// 851:       end
// 852:       return false if build_comparisons.empty?
// 853:       return false if build_comparisons.include?(0)
// 854:
// 855:       build_comparisons.include?(-1)
// 856:     end
// 857:
// 858:     sig { params(hash: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
// 859:     def api_to_local_hash(hash)
// 860:       hash["token"] = token
// 861:       hash["installed"] = installed_version
// 862:       hash["pinned"] = pinned?
// 863:       hash["pinned_version"] = pinned_version
// 864:       hash["outdated"] = outdated?
// 865:       hash
// 866:     end
// 867:
// 868:     sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
// 869:     def url_specs
// 870:       url&.specs.dup.tap do |url_specs|
// 871:         case url_specs&.dig(:user_agent)
// 872:         when :default
// 873:           url_specs.delete(:user_agent)
// 874:         when Symbol
// 875:           url_specs[:user_agent] = ":#{url_specs[:user_agent]}"
// 876:         end
// 877:       end
// 878:     end
// 879:   end
// 880: end
