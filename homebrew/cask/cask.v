module cask

import crypto.sha256
import ruby
import homebrew
import homebrew.cask.dsl as dsl_types
import os

// Translated from Homebrew/brew `cask/cask.rb`.
const cask_hash_keys_to_skip = ['outdated', 'installed', 'pinned', 'pinned_version', 'versions']
const cask_auto_updates_bad_bundle_versions = ['0', '0.0']

pub type CaskBlock = fn (mut CaskDSL) !

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
			cask_default_tags()
		} else {
			options.valid_tags.clone()
		}
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
		hashes[block.languages.join('\x00')] = cask.to_h()
		values[block.languages.join('\x00')] = cask.dsl.language_eval_value
	}
	default_key := default_group.join('\x00')
	mut result := hashes[default_key].clone()
	mut variations := []ruby.Value{}
	for block in cask.dsl.language_blocks {
		key := block.languages.join('\x00')
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
