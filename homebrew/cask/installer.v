module cask

import ruby
import crypto.sha256
import homebrew
import homebrew.cask.dsl as dsl_types
import os
import time

pub struct CaskInstallerOptions {
pub mut:
	force                       bool
	adopt                       bool
	skip_cask_deps              bool
	binaries                    bool = true
	verbose                     bool
	zap                         bool
	require_sha                 bool
	upgrade                     bool
	reinstall                   bool
	installed_on_request        bool = true
	verify_download_integrity   bool = true
	quiet                       bool
	defer_fetch                 bool
	default_uninstall_artifacts []ruby.Value
	metadata_timestamp          string
	install_badge               string = '🍺'
	no_emoji                    bool
	current_os                  string = 'macOS'
	current_arch                string = 'arm'
	current_bits                int = 64
	current_macos               string = '15'
	allowed_taps                []string
	forbidden_taps              []string
	forbid_casks                bool
	forbidden_casks             []string
	forbidden_formulae          []string
	forbidden_artifacts         []string
	forbidden_owner             string = 'your system administrator'
	forbidden_owner_contact     string
	conflicting_installed       []string
}

pub struct CaskInstallerDependency {
pub:
	name          string
	full_name     string
	kind          string
	tap           string
	tap_allowed   bool = true
	tap_forbidden bool
	installed     bool
	linked        bool
}

pub struct CaskInstallerDownloadRequest {
pub:
	token                     string
	url                       string
	require_sha               bool
	quiet                     bool
	timeout                   ?f64
	verify_download_integrity bool = true
}

pub struct CaskInstallerArtifactRequest {
pub:
	artifact     ruby.Value
	verbose      bool
	adopt        bool
	auto_updates bool
	force        bool
	clear        bool
	quit         bool = true
	upgrade      bool
	reinstall    bool
	predecessor  string
	successor    string
}

pub struct CaskInstallerQueueEntry {
pub:
	kind string
	name string
	url  string
}

pub type CaskInstallerFetchHook = fn(CaskInstallerDownloadRequest) !string

pub type CaskInstallerExtractHook = fn(string, string, bool) !

pub type CaskInstallerArtifactHook = fn(CaskInstallerArtifactRequest) !

pub type CaskInstallerDependencyHook = fn(CaskInstallerDependency) !

pub type CaskInstallerQueueHook = fn(CaskInstallerQueueEntry) !

pub type CaskInstallerSourceLoader = fn(CaskCore) !CaskCore

pub struct CaskInstallerHooks {
pub:
	fetch                  ?CaskInstallerFetchHook
	extract                ?CaskInstallerExtractHook
	install_artifact       ?CaskInstallerArtifactHook
	uninstall_artifact     ?CaskInstallerArtifactHook
	zap_artifact           ?CaskInstallerArtifactHook
	install_dependency     ?CaskInstallerDependencyHook
	enqueue                ?CaskInstallerQueueHook
	load_source_cask       ?CaskInstallerSourceLoader
	load_installed_cask    ?CaskInstallerSourceLoader
	recover_installed_cask ?CaskInstallerSourceLoader
}

pub struct CaskInstaller {
pub mut:
	cask                                  CaskCore
	options                               CaskInstallerOptions
	hooks                                 CaskInstallerHooks
	dependencies                          []CaskInstallerDependency
	ran_prelude_fetch                     bool
	ran_prelude                           bool
	installed_uninstall_artifacts_missing bool
	metadata_subdir_cache                 string
	source_download_path                  string
	source_downloaded                     bool
	queued_staged_path                    string
	queued_staged_marker                  string
	queue_entries                         []CaskInstallerQueueEntry
	messages                              []string
}

pub fn new_cask_installer(cask CaskCore, options CaskInstallerOptions,
	hooks CaskInstallerHooks) CaskInstaller {
	return CaskInstaller{
		cask: cask
		options: options
		hooks: hooks
	}
}

fn installer_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn installer_artifact_key(value ruby.Value) string {
	return value.attributes['dsl_key'] or {
		value.type_name.all_after_last('::').replace('Block', '').replace_each([
			'AppImage',
			'app_image',
			'Preflight',
			'preflight',
			'Postflight',
			'postflight',
		]).to_lower()
	}
}

fn installer_artifact_has(value ruby.Value, phase string) bool {
	if raw := value.map_data[phase] {
		return raw.type_name != 'Bool' || raw.bool_data
	}
	key := installer_artifact_key(value)
	return match phase {
		'install_phase' {
			key !in ['uninstall', 'uninstall_preflight', 'uninstall_postflight', 'zap']
		}
		'uninstall_phase' { key !in ['installer', 'pkg', 'stage_only', 'zap'] }
		'post_uninstall_phase' { key == 'uninstall' }
		'zap_phase' { key == 'zap' }
		else { false }
	}
}

fn installer_staged_path(cask CaskCore) string {
	if cask.dsl.staged_path_value != '' {
		return cask.dsl.staged_path_value
	}
	return os.join_path(cask.caskroom_path(), cask.version_text())
}

fn installer_metadata_versioned_path(cask CaskCore) string {
	return os.join_path(cask.metadata_main_container_path(), cask.version_text())
}

fn installer_remove(path string) ! {
	if path == '' || (!os.exists(path) && !os.is_link(path)) {
		return
	}
	if os.is_dir(path) && !os.is_link(path) {
		os.rmdir_all(path)!
	} else {
		os.rm(path)!
	}
}

fn installer_rmdir_if_possible(path string) {
	if path != '' && os.is_dir(path) && (os.ls(path) or { return }).len == 0 {
		os.rmdir(path) or {}
	}
}

fn installer_copy_tree(source string, destination string) ! {
	if os.is_file(source) {
		os.mkdir_all(os.dir(destination))!
		os.cp(source, destination)!
		return
	}
	os.mkdir_all(destination)!
	for name in os.ls(source)! {
		from := os.join_path(source, name)
		to := os.join_path(destination, name)
		if os.is_dir(from) && !os.is_link(from) {
			installer_copy_tree(from, to)!
		} else if os.is_link(from) {
			os.symlink(os.readlink(from)!, to)!
		} else {
			os.cp(from, to)!
		}
	}
}

fn installer_json_escape(value string) string {
	return value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
}

fn installer_value_json(value ruby.Value) string {
	return match value.type_name {
		'NilClass' { 'null' }
		'Bool' { value.bool_data.str() }
		'Integer' { value.int_data.str() }
		'Float' { value.float_data.str() }
		'Array' {
			'[${(value.as_array() or { []ruby.Value{} }).map(installer_value_json(it)).join(',')}]'
		}
		'Hash' {
			mut keys := value.map_data.keys()
			keys.sort()
			mut pairs := []string{cap: keys.len}
			for key in keys {
				pairs << '"${installer_json_escape(key)}":${installer_value_json(value.map_data[key])}'
			}
			'{${pairs.join(',')}}'
		}
		else { '"${installer_json_escape(value.as_string())}"' }
	}
}

fn installer_map_json(values map[string]ruby.Value) string {
	return installer_value_json(ruby.map_value(values))
}

pub fn (installer CaskInstaller) caveats() string {
	caveats := dsl_types.ruby_caveats_l51_d5_to_s(dsl_types.cask_caveats_value(installer.cask.dsl.caveats_value)).as_string()
	return if caveats.trim_space() == '' { '' } else { '==> Caveats\n${caveats}\n' }
}

pub fn (installer CaskInstaller) summary() string {
	mut summary := ''
	if !installer.options.no_emoji {
		summary += '${installer.options.install_badge}  '
	}
	action := if installer.options.upgrade { 'upgraded' } else { 'installed' }
	return '${summary}${installer.cask.token} was successfully ${action}!'
}

pub fn (installer CaskInstaller) artifacts() []ruby.Value {
	if installer.options.default_uninstall_artifacts.len > 0 {
		return installer.options.default_uninstall_artifacts.clone()
	}
	return installer.cask.dsl.artifacts.to_array()
}

pub fn (installer CaskInstaller) download_request(quiet bool, timeout ?f64) CaskInstallerDownloadRequest {
	url := if installer.cask.dsl.has_url { installer.cask.dsl.url_value.uri } else { '' }
	return CaskInstallerDownloadRequest{
		token: installer.cask.token
		url: url
		require_sha: installer.options.require_sha && !installer.options.force
		quiet: quiet
		timeout: timeout
		verify_download_integrity: installer.options.verify_download_integrity
	}
}

pub fn (mut installer CaskInstaller) download(quiet bool, timeout ?f64) !string {
	request := installer.download_request(quiet, timeout)
	if request.require_sha && (!installer.cask.dsl.has_sha256 || installer.cask.dsl.sha256_value.as_string() in ['',
		'no_check']) {
		return error('Cask ${installer.cask.token} is missing a sha256 checksum and cannot be installed with `--require-sha`.')
	}
	if installer.cask.download != '' {
		installer.verify_download(installer.cask.download)!
		return installer.cask.download
	}
	if request.url.starts_with('file://') {
		path := request.url.trim_string_left('file://')
		if !os.exists(path) {
			return error("Download failed on Cask '${installer.cask.token}': ${path} does not exist")
		}
		installer.cask.download = path
		installer.verify_download(path)!
		return path
	}
	fetch := installer.hooks.fetch or { return error('download collaborator is required for ${request.url}') }
	path := fetch(request)!
	if path == '' {
		return error("Download failed on Cask '${installer.cask.token}': empty download path")
	}
	installer.cask.download = path
	installer.verify_download(path)!
	return path
}

fn (mut installer CaskInstaller) verify_download(path string) ! {
	if !installer.options.verify_download_integrity {
		return
	}
	if !installer.cask.dsl.has_sha256 {
		installer.messages << "Cannot verify integrity of '${os.base(path)}'."
		return
	}
	expected := installer.cask.dsl.sha256_value.as_string()
	if expected in ['', 'no_check'] {
		return
	}
	actual := sha256.sum256(os.read_bytes(path)!).hex()
	if actual != expected {
		return error('SHA256 mismatch\nExpected: ${expected}\n  Actual: ${actual}')
	}
}

pub fn (mut installer CaskInstaller) primary_container() !string {
	return installer.download(true, none)
}

pub fn (mut installer CaskInstaller) extract_primary_container(destination string) ! {
	download := installer.primary_container()!
	to := if destination == '' { installer_staged_path(installer.cask) } else { destination }
	if os.is_dir(download) {
		installer_copy_tree(download, to)!
		return
	}
	extract := installer.hooks.extract or { return error('unpack collaborator is required for ${download}') }
	extract(download, to, installer.options.verbose)!
}

pub fn (installer CaskInstaller) process_rename_operations(target_dir string) ! {
	root := if target_dir == '' { installer_staged_path(installer.cask) } else { target_dir }
	for rename in installer.cask.dsl.renames {
		matches := os.glob(os.join_path(root, rename.from)) or { return err }
		for source in matches {
			target := os.join_path(root, rename.to)
			os.mkdir_all(os.dir(target))!
			os.mv(source, target)!
		}
	}
}

pub fn (installer CaskInstaller) check_deprecate_disable() !string {
	if installer.cask.dsl.disabled {
		message := if installer.cask.dsl.disable_reason.as_string() == '' {
			'disabled'
		} else {
			installer.cask.dsl.disable_reason.as_string()
		}
		return error('${installer.cask.token} has been ${message}')
	}
	if installer.cask.dsl.deprecated {
		message := if installer.cask.dsl.deprecation_reason.as_string() == '' {
			'deprecated'
		} else {
			installer.cask.dsl.deprecation_reason.as_string()
		}
		return '${installer.cask.token} has been ${message}'
	}
	return ''
}

pub fn (installer CaskInstaller) check_conflicts() ! {
	for token in installer.cask.dsl.conflicts_with_value.conflicts['cask'] {
		if token in installer.options.conflicting_installed {
			return error("Cask '${installer.cask.token}' conflicts with '${token}'.")
		}
	}
}

pub fn (installer CaskInstaller) check_stanza_os_requirements() ! {
	if !installer.cask.supports_macos() {
		return error('${installer.cask.token}: This cask requires Linux.')
	}
}

pub fn (installer CaskInstaller) check_supported_system() ! {
	if installer.cask.loaded_from_api && !installer.cask.installable_artifact() {
		return error('${installer.cask.token}: This cask is not available on ${installer.options.current_os}.')
	}
}

pub fn (installer CaskInstaller) check_macos_requirements() ! {
	current := homebrew.new_macos_version(installer.options.current_macos)!
	if requirement := installer.cask.dsl.depends_on_value.macos {
		if !requirement.satisfied_on(current, installer.options.current_os == 'macOS') {
			return error('${installer.cask.token}: ${requirement.message('cask', installer.options.current_os == 'macOS')}')
		}
	}
	if requirement := installer.cask.dsl.depends_on_value.maximum_macos {
		if !requirement.satisfied_on(current, installer.options.current_os == 'macOS') {
			return error('${installer.cask.token}: ${requirement.message('cask', installer.options.current_os == 'macOS')}')
		}
	}
}

pub fn (installer CaskInstaller) check_arch_requirements() ! {
	architectures := installer.cask.dsl.depends_on_value.arch
	if architectures.len == 0 {
		return
	}
	for arch in architectures {
		if arch.kind == installer.options.current_arch && arch.bits == installer.options.current_bits {
			return
		}
	}
	accepted := architectures.map('{ type: ${it.kind}, bits: ${it.bits} }').join(', ')
	return error('${installer.cask.token}: This cask depends on hardware architecture being one of [${accepted}], but you are running { type: ${installer.options.current_arch}, bits: ${installer.options.current_bits} }.')
}

pub fn (installer CaskInstaller) check_requirements() ! {
	installer.check_stanza_os_requirements()!
	installer.check_supported_system()!
	installer.check_macos_requirements()!
	installer.check_arch_requirements()!
}

pub fn (installer CaskInstaller) cask_and_formula_dependencies() ![]CaskInstallerDependency {
	for dependency in installer.dependencies {
		if dependency.kind == 'cask' && dependency.name == installer.cask.token {
			return error('Cask ${installer.cask.token} contains a self-referencing dependency')
		}
	}
	return installer.dependencies.clone()
}

pub fn (installer CaskInstaller) missing_cask_and_formula_dependencies() ![]CaskInstallerDependency {
	return installer.cask_and_formula_dependencies()!.filter(!(it.installed && (it.kind != 'formula' || it.linked)))
}

pub fn (mut installer CaskInstaller) satisfy_cask_and_formula_dependencies() ! {
	if !installer.options.installed_on_request {
		return
	}
	dependencies := installer.cask_and_formula_dependencies()!
	if dependencies.len == 0 {
		return
	}
	missing := installer.missing_cask_and_formula_dependencies()!
	if missing.len == 0 {
		installer.messages << 'All dependencies satisfied.'
		return
	}
	installer.messages << 'Installing dependencies: ${missing.map(if it.full_name == '' {
		it.name
	} else {
		it.full_name
	}).join(', ')}'
	install_dependency := installer.hooks.install_dependency or {
		return error('dependency installer collaborator is required')
	}
	for dependency in missing {
		if dependency.kind == 'cask' && installer.options.skip_cask_deps {
			installer.messages << '`--skip-cask-deps` is set; skipping installation of ${dependency.name}.'
			continue
		}
		install_dependency(dependency)!
	}
}

pub fn (mut installer CaskInstaller) metadata_subdir() !string {
	if installer.metadata_subdir_cache != '' {
		return installer.metadata_subdir_cache
	}
	timestamp := if installer.options.metadata_timestamp != '' {
		installer.options.metadata_timestamp
	} else {
		time.now().format_ss_micro().replace(' ', '-')
	}
	path := os.join_path(installer_metadata_versioned_path(installer.cask), timestamp, 'Casks')
	os.mkdir_all(path)!
	installer.metadata_subdir_cache = path
	return path
}

pub fn (mut installer CaskInstaller) save_caskfile() !string {
	if installer.cask.source.trim_space() == '' {
		return ''
	}
	directory := installer.metadata_subdir()!
	mut path := ''
	if installer.cask.uninstall_flight_blocks() {
		path = os.join_path(directory, '${installer.cask.token}.rb')
		os.write_file(path, installer.cask.source)!
	} else {
		path = os.join_path(directory, '${installer.cask.token}.json')
		mut metadata := installer.cask.to_installed_json_hash()
		if installer.cask.artifacts_list(true).len == 0 {
			metadata['artifacts'] = ruby.array_value([]ruby.Value{})
		}
		os.write_file(path, installer_map_json(metadata))!
	}
	return path
}

pub fn (installer CaskInstaller) save_config_file() ! {
	path := installer.cask.config_path()
	os.mkdir_all(os.dir(path))!
	os.write_file(path, installer.cask.config.json())!
}

pub fn (mut installer CaskInstaller) save_download_sha() !string {
	if !installer.cask.checksumable() {
		return ''
	}
	sha := installer.cask.new_download_sha()!
	path := installer.cask.download_sha_path()
	os.mkdir_all(os.dir(path))!
	os.write_file(path, sha)!
	return path
}

pub fn (installer CaskInstaller) backup_path() string {
	staged := installer_staged_path(installer.cask)
	return if staged == '' { '' } else { '${staged}.upgrading' }
}

pub fn (installer CaskInstaller) backup_metadata_path() string {
	metadata := installer_metadata_versioned_path(installer.cask)
	return if metadata == '' { '' } else { '${metadata}.upgrading' }
}

pub fn (installer CaskInstaller) gain_permissions_remove(path string) ! {
	installer_remove(path)!
}

pub fn (installer CaskInstaller) backup() ! {
	backup_path := installer.backup_path()
	backup_metadata := installer.backup_metadata_path()
	staged := installer_staged_path(installer.cask)
	metadata := installer_metadata_versioned_path(installer.cask)
	if os.exists(staged) {
		installer_remove(backup_path)!
		os.mv(staged, backup_path)!
	}
	if os.exists(metadata) {
		installer_remove(backup_metadata)!
		os.mv(metadata, backup_metadata)!
	}
}

pub fn (installer CaskInstaller) restore_backup() !bool {
	backup_path := installer.backup_path()
	backup_metadata := installer.backup_metadata_path()
	if !os.is_dir(backup_path) || !os.is_dir(backup_metadata) {
		return false
	}
	installer_remove(installer_staged_path(installer.cask))!
	installer_remove(installer_metadata_versioned_path(installer.cask))!
	os.mv(backup_path, installer_staged_path(installer.cask))!
	os.mv(backup_metadata, installer_metadata_versioned_path(installer.cask))!
	return true
}

pub fn (installer CaskInstaller) purge_backed_up_versioned_files() ! {
	installer.gain_permissions_remove(installer.backup_path())!
	backup_metadata := installer.backup_metadata_path()
	if os.is_dir(backup_metadata) {
		for child in os.ls(backup_metadata)! {
			installer.gain_permissions_remove(os.join_path(backup_metadata, child))!
		}
		installer_rmdir_if_possible(backup_metadata)
	}
}

pub fn (installer CaskInstaller) remove_broken_caskroom_symlinks() ![]string {
	mut removed := []string{}
	root := installer.cask.caskroom_root
	if !os.is_dir(root) {
		return removed
	}
	for name in os.ls(root)! {
		link := os.join_path(root, name)
		if !os.is_link(link) || os.exists(link) {
			continue
		}
		target := os.readlink(link) or { continue }
		if os.base(target) == os.base(installer.cask.caskroom_path()) {
			os.rm(link)!
			removed << link
		}
	}
	return removed
}

pub fn (installer CaskInstaller) purge_versioned_files() ! {
	installer.gain_permissions_remove(installer_staged_path(installer.cask))!
	metadata := installer_metadata_versioned_path(installer.cask)
	if os.is_dir(metadata) {
		for child in os.ls(metadata)! {
			installer.gain_permissions_remove(os.join_path(metadata, child))!
		}
		installer_rmdir_if_possible(metadata)
	}
	if !installer.options.upgrade {
		installer_rmdir_if_possible(installer.cask.metadata_main_container_path())
		installer_rmdir_if_possible(installer.cask.caskroom_path())
	}
	installer.remove_broken_caskroom_symlinks()!
}

pub fn (installer CaskInstaller) purge_caskroom_path() ! {
	installer.gain_permissions_remove(installer.cask.caskroom_path())!
	installer.remove_broken_caskroom_symlinks()!
}

pub fn (installer CaskInstaller) remove_tabfile() ! {
	path := os.join_path(installer.cask.metadata_main_container_path(), 'INSTALL_RECEIPT.json')
	installer_remove(path)!
	installer_rmdir_if_possible(os.dir(path))
}

pub fn (installer CaskInstaller) remove_config_file() ! {
	path := installer.cask.config_path()
	installer_remove(path)!
	installer_rmdir_if_possible(os.dir(path))
}

pub fn (installer CaskInstaller) remove_download_sha() ! {
	path := installer.cask.download_sha_path()
	installer_remove(path)!
	installer_rmdir_if_possible(os.dir(path))
}

fn installer_policy_contact(options CaskInstallerOptions) string {
	return if options.forbidden_owner_contact.trim_space() == '' {
		''
	} else {
		'\n${options.forbidden_owner_contact}'
	}
}

fn installer_tap_allowed(tap string, options CaskInstallerOptions) bool {
	return options.allowed_taps.len == 0 || tap in options.allowed_taps
}

pub fn (installer CaskInstaller) forbidden_tap_check(cask_only bool) ! {
	if installer.options.allowed_taps.len == 0 && installer.options.forbidden_taps.len == 0 {
		return
	}
	contact := installer_policy_contact(installer.options)
	tap := installer.cask.tap_name
	if tap != '' && (!installer_tap_allowed(tap, installer.options) || tap in installer.options.forbidden_taps) {
		mut reason := 'The installation of ${installer.cask.full_token()} has the tap ${tap}\nbut ${installer.options.forbidden_owner} '
		if !installer_tap_allowed(tap, installer.options) {
			reason += 'has not allowed this tap in `\$HOMEBREW_ALLOWED_TAPS`'
		}
		if !installer_tap_allowed(tap, installer.options) && tap in installer.options.forbidden_taps {
			reason += ' and\n'
		}
		if tap in installer.options.forbidden_taps {
			reason += 'has forbidden this tap in `\$HOMEBREW_FORBIDDEN_TAPS`'
		}
		return error('${reason}.${contact}')
	}
	if cask_only || installer.options.skip_cask_deps {
		return
	}
	for dependency in installer.dependencies {
		if dependency.tap == '' || (dependency.tap_allowed && !dependency.tap_forbidden) {
			continue
		}
		name := if dependency.full_name == '' { dependency.name } else { dependency.full_name }
		mut reason := 'The installation of ${installer.cask.token} has a dependency ${name}\nfrom the ${dependency.tap} tap but ${installer.options.forbidden_owner} '
		if !dependency.tap_allowed {
			reason += 'has not allowed this tap in `\$HOMEBREW_ALLOWED_TAPS`'
		}
		if !dependency.tap_allowed && dependency.tap_forbidden {
			reason += ' and\n'
		}
		if dependency.tap_forbidden {
			reason += 'has forbidden this tap in `\$HOMEBREW_FORBIDDEN_TAPS`'
		}
		return error('${reason}.${contact}')
	}
}

pub fn (installer CaskInstaller) forbidden_cask_and_formula_check(cask_only bool) ! {
	contact := installer_policy_contact(installer.options)
	mut variable := ''
	if installer.options.forbid_casks {
		variable = 'HOMEBREW_FORBID_CASKS'
	} else if installer.cask.token in installer.options.forbidden_casks || installer.cask.full_token() in installer.options.forbidden_casks {
		variable = 'HOMEBREW_FORBIDDEN_CASKS'
	}
	if variable != '' {
		return error('forbidden for installation by ${installer.options.forbidden_owner} in `${variable}`.${contact}')
	}
	if cask_only || installer.options.skip_cask_deps {
		return
	}
	for dependency in installer.dependencies {
		name := if dependency.full_name == '' { dependency.name } else { dependency.full_name }
		if dependency.kind == 'cask' && (dependency.name in installer.options.forbidden_casks || name in installer.options.forbidden_casks) {
			return error('has a dependency ${name} but the\n${name} cask was forbidden for installation by ${installer.options.forbidden_owner} in `HOMEBREW_FORBIDDEN_CASKS`.${contact}')
		}
		if dependency.kind == 'formula' && (dependency.name in installer.options.forbidden_formulae || name in installer.options.forbidden_formulae) {
			return error('has a dependency ${name} but the\n${name} formula was forbidden for installation by ${installer.options.forbidden_owner} in `HOMEBREW_FORBIDDEN_FORMULAE`.${contact}')
		}
	}
}

pub fn (installer CaskInstaller) forbidden_cask_artifacts_check() ! {
	if installer.options.forbidden_artifacts.len == 0 {
		return
	}
	contact := installer_policy_contact(installer.options)
	for value in installer.artifacts() {
		kind := installer_artifact_key(value)
		if kind in installer.options.forbidden_artifacts {
			return error("contains a '${kind}' artifact, which is forbidden for installation by ${installer.options.forbidden_owner} in `HOMEBREW_FORBIDDEN_CASK_ARTIFACTS`.${contact}")
		}
	}
}

pub fn (installer CaskInstaller) source_download_requires_pre_fetch() bool {
	return installer.cask_from_source_api() && installer.cask.languages().len > 0
}

pub fn (installer CaskInstaller) cask_from_source_api() bool {
	return installer.cask.loaded_from_api && installer.cask.caskfile_only()
}

pub fn (mut installer CaskInstaller) source_download() !string {
	if installer.source_download_path != '' {
		return installer.source_download_path
	}
	fetch := installer.hooks.fetch or { return error('source download collaborator is required') }
	installer.source_download_path = fetch(CaskInstallerDownloadRequest{
		token: installer.cask.token
		url: 'source-api://${installer.cask.token}'
		verify_download_integrity: true
	})!
	return installer.source_download_path
}

pub fn (mut installer CaskInstaller) load_cask_from_source_api() ! {
	load := installer.hooks.load_source_cask or { return error('source cask loader collaborator is required') }
	installer.cask = load(installer.cask)!
}

pub fn (mut installer CaskInstaller) check_prelude_requirements() ! {
	warning := installer.check_deprecate_disable()!
	if warning != '' {
		installer.messages << warning
	}
	installer.check_conflicts()!
	installer.check_requirements()!
	installer.forbidden_tap_check(true)!
	installer.forbidden_cask_and_formula_check(true)!
}

pub fn (mut installer CaskInstaller) prelude() ! {
	if installer.ran_prelude {
		return
	}
	if !installer.ran_prelude_fetch {
		installer.check_prelude_requirements()!
	}
	if installer.cask_from_source_api() {
		installer.load_cask_from_source_api()!
	}
	installer.forbidden_tap_check(false)!
	installer.forbidden_cask_and_formula_check(false)!
	installer.forbidden_cask_artifacts_check()!
	installer.ran_prelude = true
}

pub fn (mut installer CaskInstaller) prelude_fetch_download() !string {
	if installer.ran_prelude_fetch {
		return ''
	}
	installer.check_prelude_requirements()!
	installer.ran_prelude_fetch = true
	if !installer.source_download_requires_pre_fetch() {
		return ''
	}
	if installer.source_downloaded {
		return ''
	}
	return installer.source_download()!
}

pub fn (mut installer CaskInstaller) prelude_fetch() ! {
	download := installer.prelude_fetch_download()!
	if download == '' {
		return
	}
	entry := CaskInstallerQueueEntry{
		kind: 'SourceDownload'
		name: installer.cask.token
		url: download
	}
	installer.queue_entries << entry
	enqueue := installer.hooks.enqueue or { return error('download queue collaborator is required') }
	enqueue(entry)!
}

pub fn (mut installer CaskInstaller) enqueue_downloads() ! {
	if !installer.ran_prelude_fetch {
		installer.prelude_fetch()!
	}
	if installer.source_download_requires_pre_fetch() {
		installer.load_cask_from_source_api()!
	} else if installer.cask_from_source_api() {
		enqueue := installer.hooks.enqueue or { return error('download queue collaborator is required') }
		entry := CaskInstallerQueueEntry{
			kind: 'SourceDownload'
			name: installer.cask.token
			url: 'source-api://${installer.cask.token}'
		}
		installer.queue_entries << entry
		enqueue(entry)!
	}
	installer.forbidden_tap_check(false)!
	installer.forbidden_cask_and_formula_check(false)!
	installer.forbidden_cask_artifacts_check()!
	enqueue := installer.hooks.enqueue or { return error('download queue collaborator is required') }
	request := installer.download_request(false, none)
	entry := CaskInstallerQueueEntry{
		kind: 'Cask::Download'
		name: installer.cask.token
		url: request.url
	}
	installer.queue_entries << entry
	enqueue(entry)!
}

pub fn (mut installer CaskInstaller) fetch(quiet ?bool, timeout ?f64) ! {
	installer.prelude()!
	if !installer.options.defer_fetch {
		installer.download(quiet or { installer.options.quiet }, timeout)!
	}
	installer.satisfy_cask_and_formula_dependencies()!
}

pub fn (mut installer CaskInstaller) stage() ! {
	os.mkdir_all(installer.cask.caskroom_root)!
	staged := installer_staged_path(installer.cask)
	if installer.options.defer_fetch && os.exists(installer.queued_staged_marker) && !os.exists(staged) {
		os.mkdir_all(os.dir(staged))!
		os.mv(installer.queued_staged_path, staged)!
		installer_remove(installer.queued_staged_marker)!
	} else {
		if installer.options.defer_fetch {
			installer_remove(installer.queued_staged_path)!
			installer_remove(installer.queued_staged_marker)!
		}
		installer.extract_primary_container(staged) or {
			installer.purge_versioned_files() or {}
			return err
		}
		installer.process_rename_operations(staged) or {
			installer.purge_versioned_files() or {}
			return err
		}
	}
	installer.save_caskfile()!
}

pub fn (mut installer CaskInstaller) install_artifacts(predecessor string) ! {
	install := installer.hooks.install_artifact
	uninstall := installer.hooks.uninstall_artifact
	mut installed := []ruby.Value{}
	for artifact in installer.artifacts() {
		if !installer_artifact_has(artifact, 'install_phase') {
			continue
		}
		if installer_artifact_key(artifact) == 'binary' && !installer.options.binaries {
			continue
		}
		operation := install or { return error('artifact install collaborator is required for ${installer_artifact_key(artifact)}') }
		operation(CaskInstallerArtifactRequest{
			artifact: artifact
			verbose: installer.options.verbose
			adopt: installer.options.adopt
			auto_updates: installer.cask.dsl.auto_updates_value
			force: installer.options.force
			predecessor: predecessor
		}) or {
			if rollback := uninstall {
				for index := installed.len - 1; index >= 0; index-- {
					rollback(CaskInstallerArtifactRequest{
						artifact: installed[index]
						verbose: installer.options.verbose
						force: installer.options.force
					}) or {}
				}
			}
			installer.purge_versioned_files() or {}
			return err
		}
		installed.prepend(artifact)
	}
	installer.save_config_file()!
	if installer.cask.version_text() == 'latest' {
		installer.save_download_sha()!
	}
}

pub fn (mut installer CaskInstaller) uninstall_artifacts(clear bool, successor string,
	quit bool) ! {
	uninstall := installer.hooks.uninstall_artifact
	for artifact in installer.artifacts() {
		if !installer_artifact_has(artifact, 'uninstall_phase') && !installer_artifact_has(artifact, 'post_uninstall_phase') {
			continue
		}
		operation := uninstall or { return error('artifact uninstall collaborator is required for ${installer_artifact_key(artifact)}') }
		operation(CaskInstallerArtifactRequest{
			artifact: artifact
			verbose: installer.options.verbose
			force: installer.options.force
			clear: clear
			quit: quit
			upgrade: installer.options.upgrade
			reinstall: installer.options.reinstall
			successor: successor
		})!
	}
}

pub fn (mut installer CaskInstaller) uninstall(successor string) ! {
	installer.load_installed_caskfile()!
	if !installer.options.reinstall && !installer.options.upgrade && installer.installed_uninstall_artifacts_missing && installer.artifacts().len == 0 {
		installer.messages << "No uninstall artifact metadata is available for Cask '${installer.cask.token}'.\nHomebrew will remove its records, but files installed by the Cask may remain."
	}
	installer.uninstall_artifacts(true, successor, true)!
	if !installer.options.reinstall && !installer.options.upgrade {
		installer.remove_tabfile()!
		installer.remove_download_sha()!
		installer.remove_config_file()!
	}
	installer.purge_versioned_files()!
	if installer.options.force {
		installer.purge_caskroom_path()!
	}
}

pub fn (mut installer CaskInstaller) uninstall_existing_cask() ! {
	if !installer.cask.installed() {
		return
	}
	mut nested_options := installer.options
	nested_options.force = true
	nested_options.reinstall = true
	mut nested := new_cask_installer(installer.cask, nested_options, installer.hooks)
	if installer.options.zap {
		nested.zap()!
	} else {
		nested.uninstall(installer.cask.token)!
	}
}

pub fn (mut installer CaskInstaller) start_upgrade(successor string, quit bool) ! {
	installer.uninstall_artifacts(false, successor, quit)!
	installer.backup()!
}

pub fn (mut installer CaskInstaller) revert_upgrade(predecessor string) ! {
	installer.messages << 'Reverting upgrade for Cask ${installer.cask.token}'
	installer.restore_backup()!
	installer.install_artifacts(predecessor)!
}

pub fn (mut installer CaskInstaller) finalize_upgrade() ! {
	installer.messages << 'Purging files for version ${installer.cask.version_text()} of Cask ${installer.cask.token}'
	installer.purge_backed_up_versioned_files()!
	installer.messages << installer.summary()
}

pub fn (mut installer CaskInstaller) zap() ! {
	installer.load_installed_caskfile()!
	installer.uninstall_artifacts(false, '', true)!
	mut found := false
	for artifact in installer.artifacts() {
		if !installer_artifact_has(artifact, 'zap_phase') {
			continue
		}
		found = true
		operation := installer.hooks.zap_artifact or {
			return error('artifact zap collaborator is required')
		}
		operation(CaskInstallerArtifactRequest{
			artifact: artifact
			verbose: installer.options.verbose
			force: installer.options.force
		})!
	}
	if !found {
		installer.messages << "No zap stanza present for Cask '${installer.cask.token}'"
	} else {
		installer.messages << 'Dispatching zap stanza'
	}
	installer.messages << "Removing all staged versions of Cask '${installer.cask.token}'"
	installer.purge_caskroom_path()!
}

pub fn (mut installer CaskInstaller) install() ! {
	predecessor := if installer.options.reinstall && installer.cask.installed() {
		installer.cask.token
	} else {
		''
	}
	installer.prelude()!
	caveats := installer.caveats()
	if caveats != '' {
		installer.messages << caveats
	}
	installer.fetch(none, none)!
	if installer.options.reinstall {
		installer.uninstall_existing_cask()!
	}
	if installer.options.force && os.exists(installer_staged_path(installer.cask)) && os.exists(installer_metadata_versioned_path(installer.cask)) {
		installer.backup()!
	}
	installer.messages << 'Installing Cask ${installer.cask.token}'
	installer.stage() or {
		installer.restore_backup() or {}
		return err
	}
	installer.install_artifacts(predecessor) or {
		installer.restore_backup() or {}
		return err
	}
	installer.purge_backed_up_versioned_files()!
	if !installer.options.quiet {
		installer.messages << installer.summary()
	}
}

pub fn (installer CaskInstaller) installed_uninstall_artifacts_missing(installed_caskfile string,
	installed_json map[string]ruby.Value, tab_uninstall_artifacts []ruby.Value) bool {
	return installed_caskfile.ends_with('.json') && 'artifacts' !in installed_json && tab_uninstall_artifacts.len == 0
}

pub fn (mut installer CaskInstaller) load_installed_caskfile() ! {
	path := installer.cask.installed_caskfile()
	if path != '' && path.ends_with('.json') && os.exists(path) {
		contents := os.read_file(path)!
		installer.installed_uninstall_artifacts_missing = !contents.contains('"artifacts"')
		if load := installer.hooks.load_installed_cask {
			installer.cask = load(installer.cask) or {
				recover := installer.hooks.recover_installed_cask or { return err }
				recover(installer.cask)!
			}
		}
		return
	}
	if recover := installer.hooks.recover_installed_cask {
		installer.cask = recover(installer.cask)!
		return
	}
	if installer.cask_from_source_api() {
		installer.load_cask_from_source_api()!
	}
}

fn installer_options_value(options CaskInstallerOptions) ruby.Value {
	return ruby.map_value({
		'force':                       ruby.bool_value(options.force)
		'adopt':                       ruby.bool_value(options.adopt)
		'skip_cask_deps':              ruby.bool_value(options.skip_cask_deps)
		'binaries':                    ruby.bool_value(options.binaries)
		'verbose':                     ruby.bool_value(options.verbose)
		'zap':                         ruby.bool_value(options.zap)
		'require_sha':                 ruby.bool_value(options.require_sha)
		'upgrade':                     ruby.bool_value(options.upgrade)
		'reinstall':                   ruby.bool_value(options.reinstall)
		'installed_on_request':        ruby.bool_value(options.installed_on_request)
		'verify_download_integrity':   ruby.bool_value(options.verify_download_integrity)
		'quiet':                       ruby.bool_value(options.quiet)
		'defer_fetch':                 ruby.bool_value(options.defer_fetch)
		'default_uninstall_artifacts': ruby.array_value(options.default_uninstall_artifacts)
		'metadata_timestamp':          ruby.string_value(options.metadata_timestamp)
		'install_badge':               ruby.string_value(options.install_badge)
		'no_emoji':                    ruby.bool_value(options.no_emoji)
		'current_os':                  ruby.string_value(options.current_os)
		'current_arch':                ruby.string_value(options.current_arch)
		'current_bits':                ruby.int_value(options.current_bits)
		'current_macos':               ruby.string_value(options.current_macos)
		'allowed_taps':                ruby.string_array_value(options.allowed_taps)
		'forbidden_taps':              ruby.string_array_value(options.forbidden_taps)
		'forbid_casks':                ruby.bool_value(options.forbid_casks)
		'forbidden_casks':             ruby.string_array_value(options.forbidden_casks)
		'forbidden_formulae':          ruby.string_array_value(options.forbidden_formulae)
		'forbidden_artifacts':         ruby.string_array_value(options.forbidden_artifacts)
		'forbidden_owner':             ruby.string_value(options.forbidden_owner)
		'forbidden_owner_contact':     ruby.string_value(options.forbidden_owner_contact)
		'conflicting_installed':       ruby.string_array_value(options.conflicting_installed)
	})
}

fn installer_value_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	raw := values[key] or { return fallback }
	return if raw.type_name == 'Bool' { raw.bool_data } else { fallback }
}

fn installer_value_string(values map[string]ruby.Value, key string, fallback string) string {
	raw := values[key] or { return fallback }
	return if raw.type_name == 'NilClass' { fallback } else { raw.as_string() }
}

fn installer_value_strings(values map[string]ruby.Value, key string) []string {
	return (values[key] or { ruby.string_array_value([]string{}) }).as_string_array() or {
		[]string{}
	}
}

fn installer_options_from_value(value ruby.Value) CaskInstallerOptions {
	values := value.map_data.clone()
	return CaskInstallerOptions{
		force: installer_value_bool(values, 'force', false)
		adopt: installer_value_bool(values, 'adopt', false)
		skip_cask_deps: installer_value_bool(values, 'skip_cask_deps', false)
		binaries: installer_value_bool(values, 'binaries', true)
		verbose: installer_value_bool(values, 'verbose', false)
		zap: installer_value_bool(values, 'zap', false)
		require_sha: installer_value_bool(values, 'require_sha', false)
		upgrade: installer_value_bool(values, 'upgrade', false)
		reinstall: installer_value_bool(values, 'reinstall', false)
		installed_on_request: installer_value_bool(values, 'installed_on_request', true)
		verify_download_integrity: installer_value_bool(values, 'verify_download_integrity', true)
		quiet: installer_value_bool(values, 'quiet', false)
		defer_fetch: installer_value_bool(values, 'defer_fetch', false)
		default_uninstall_artifacts: (values['default_uninstall_artifacts'] or { ruby.array_value([]ruby.Value{}) }).as_array() or { []ruby.Value{} }
		metadata_timestamp: installer_value_string(values, 'metadata_timestamp', '')
		install_badge: installer_value_string(values, 'install_badge', '🍺')
		no_emoji: installer_value_bool(values, 'no_emoji', false)
		current_os: installer_value_string(values, 'current_os', 'macOS')
		current_arch: installer_value_string(values, 'current_arch', 'arm')
		current_bits: int((values['current_bits'] or { ruby.int_value(64) }).int_data)
		current_macos: installer_value_string(values, 'current_macos', '15')
		allowed_taps: installer_value_strings(values, 'allowed_taps')
		forbidden_taps: installer_value_strings(values, 'forbidden_taps')
		forbid_casks: installer_value_bool(values, 'forbid_casks', false)
		forbidden_casks: installer_value_strings(values, 'forbidden_casks')
		forbidden_formulae: installer_value_strings(values, 'forbidden_formulae')
		forbidden_artifacts: installer_value_strings(values, 'forbidden_artifacts')
		forbidden_owner: installer_value_string(values, 'forbidden_owner', 'your system administrator')
		forbidden_owner_contact: installer_value_string(values, 'forbidden_owner_contact', '')
		conflicting_installed: installer_value_strings(values, 'conflicting_installed')
	}
}

fn installer_dependency_value(dependency CaskInstallerDependency) ruby.Value {
	return ruby.map_value({
		'name':          ruby.string_value(dependency.name)
		'full_name':     ruby.string_value(dependency.full_name)
		'kind':          ruby.string_value(dependency.kind)
		'tap':           ruby.string_value(dependency.tap)
		'tap_allowed':   ruby.bool_value(dependency.tap_allowed)
		'tap_forbidden': ruby.bool_value(dependency.tap_forbidden)
		'installed':     ruby.bool_value(dependency.installed)
		'linked':        ruby.bool_value(dependency.linked)
	})
}

fn installer_dependency_from_value(value ruby.Value) CaskInstallerDependency {
	values := value.map_data.clone()
	return CaskInstallerDependency{
		name: installer_value_string(values, 'name', '')
		full_name: installer_value_string(values, 'full_name', '')
		kind: installer_value_string(values, 'kind', 'cask')
		tap: installer_value_string(values, 'tap', '')
		tap_allowed: installer_value_bool(values, 'tap_allowed', true)
		tap_forbidden: installer_value_bool(values, 'tap_forbidden', false)
		installed: installer_value_bool(values, 'installed', false)
		linked: installer_value_bool(values, 'linked', false)
	}
}

pub fn cask_installer_value(installer CaskInstaller) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Installer'
		repr: installer.cask.token
		map_data: {
			'cask':                                  cask_core_value(installer.cask)
			'options':                               installer_options_value(installer.options)
			'dependencies':                          ruby.array_value(installer.dependencies.map(installer_dependency_value(it)))
			'ran_prelude_fetch':                     ruby.bool_value(installer.ran_prelude_fetch)
			'ran_prelude':                           ruby.bool_value(installer.ran_prelude)
			'installed_uninstall_artifacts_missing': ruby.bool_value(installer.installed_uninstall_artifacts_missing)
			'metadata_subdir':                       ruby.string_value(installer.metadata_subdir_cache)
			'source_download_path':                  ruby.string_value(installer.source_download_path)
			'source_downloaded':                     ruby.bool_value(installer.source_downloaded)
			'queued_staged_path':                    ruby.string_value(installer.queued_staged_path)
			'queued_staged_marker':                  ruby.string_value(installer.queued_staged_marker)
			'queue_entries':                         ruby.array_value(installer.queue_entries.map(ruby.structured_value('Homebrew::DownloadQueue::Entry', it.name, {
				'kind': it.kind
				'name': it.name
				'url':  it.url
			})))
			'messages':                              ruby.string_array_value(installer.messages)
		}
	}
}

pub fn cask_installer_from_value(value ruby.Value) !CaskInstaller {
	if value.type_name != 'Cask::Installer' {
		return error('expected Cask::Installer, got ${value.type_name}')
	}
	values := value.map_data.clone()
	cask := cask_core_from_value(values['cask'] or { return error('Cask::Installer has no cask') })!
	mut installer := new_cask_installer(cask, installer_options_from_value(values['options'] or {
		ruby.map_value({})
	}), CaskInstallerHooks{})
	raw_dependencies := (values['dependencies'] or {
		ruby.array_value([]ruby.Value{})
	}).as_array() or { []ruby.Value{} }
	installer.dependencies = raw_dependencies.map(installer_dependency_from_value(it))
	installer.ran_prelude_fetch = installer_value_bool(values, 'ran_prelude_fetch', false)
	installer.ran_prelude = installer_value_bool(values, 'ran_prelude', false)
	installer.installed_uninstall_artifacts_missing = installer_value_bool(values, 'installed_uninstall_artifacts_missing', false)
	installer.metadata_subdir_cache = installer_value_string(values, 'metadata_subdir', '')
	installer.source_download_path = installer_value_string(values, 'source_download_path', '')
	installer.source_downloaded = installer_value_bool(values, 'source_downloaded', false)
	installer.queued_staged_path = installer_value_string(values, 'queued_staged_path', '')
	installer.queued_staged_marker = installer_value_string(values, 'queued_staged_marker', '')
	for raw in (values['queue_entries'] or { ruby.array_value([]ruby.Value{}) }).as_array() or { []ruby.Value{} } {
		installer.queue_entries << CaskInstallerQueueEntry{
			kind: raw.attributes['kind'] or { '' }
			name: raw.attributes['name'] or { raw.as_string() }
			url: raw.attributes['url'] or { '' }
		}
	}
	installer.messages = installer_value_strings(values, 'messages')
	return installer
}

fn installer_receiver(args []ruby.Value, method string) !CaskInstaller {
	if args.len == 0 {
		return error('${method} requires a Cask::Installer receiver')
	}
	return cask_installer_from_value(args[0])
}

fn installer_error(err IError) ruby.Value {
	return ruby.object_value('Cask::CaskError', err.msg())
}

// Translated from Homebrew/brew `cask/installer.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :cask` at line 26.
pub fn ruby_installer_l26_d1_cask(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'cask') or { return installer_error(err) }
	return cask_core_value(installer.cask)
}

// Ruby method `initialize(cask, command: SystemCommand, force: false, adopt: false,` at line 38.
pub fn ruby_installer_l38_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'initialize requires a Cask')
	}
	cask := cask_core_from_value(args[0]) or { return installer_error(err) }
	options := if args.len > 1 {
		installer_options_from_value(args[1])
	} else {
		CaskInstallerOptions{}
	}
	return cask_installer_value(new_cask_installer(cask, options, CaskInstallerHooks{}))
}

// Ruby method `adopt? = @adopt` at line 72.
pub fn ruby_installer_l72_d3_adopt(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'adopt?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.adopt)
}

// Ruby method `binaries? = @binaries` at line 75.
pub fn ruby_installer_l75_d4_binaries(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'binaries?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.binaries)
}

// Ruby method `force? = @force` at line 78.
pub fn ruby_installer_l78_d5_force(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'force?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.force)
}

// Ruby method `installed_on_request? = @installed_on_request` at line 81.
pub fn ruby_installer_l81_d6_installed_on_request(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'installed_on_request?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.installed_on_request)
}

// Ruby method `quiet? = @quiet` at line 84.
pub fn ruby_installer_l84_d7_quiet(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'quiet?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.quiet)
}

// Ruby method `reinstall? = @reinstall` at line 87.
pub fn ruby_installer_l87_d8_reinstall(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'reinstall?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.reinstall)
}

// Ruby method `require_sha? = @require_sha` at line 90.
pub fn ruby_installer_l90_d9_require_sha(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'require_sha?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.require_sha)
}

// Ruby method `skip_cask_deps? = @skip_cask_deps` at line 93.
pub fn ruby_installer_l93_d10_skip_cask_deps(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'skip_cask_deps?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.skip_cask_deps)
}

// Ruby method `upgrade? = @upgrade` at line 96.
pub fn ruby_installer_l96_d11_upgrade(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'upgrade?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.upgrade)
}

// Ruby method `verbose? = @verbose` at line 99.
pub fn ruby_installer_l99_d12_verbose(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'verbose?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.verbose)
}

// Ruby method `zap? = @zap` at line 102.
pub fn ruby_installer_l102_d13_zap(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'zap?') or { return installer_error(err) }
	return ruby.bool_value(installer.options.zap)
}

// Ruby method `self.caveats(cask)` at line 105.
pub fn ruby_installer_l105_d14_self_caveats(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'caveats requires a Cask')
	}
	cask := cask_core_from_value(args[0]) or { return installer_error(err) }
	text := new_cask_installer(cask, CaskInstallerOptions{}, CaskInstallerHooks{}).caveats()
	return if text == '' { installer_nil() } else { ruby.string_value(text) }
}

// Ruby method `fetch(quiet: nil, timeout: nil)` at line 120.
pub fn ruby_installer_l120_d15_fetch(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'fetch') or { return installer_error(err) }
	options := if args.len > 1 { args[1].map_data.clone() } else { map[string]ruby.Value{} }
	quiet := if raw := options['quiet'] { ?bool(raw.bool_data) } else { none }
	timeout := if raw := options['timeout'] { ?f64(raw.as_float() or { 0.0 }) } else { none }
	installer.fetch(quiet, timeout) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `stage` at line 131.
pub fn ruby_installer_l131_d16_stage(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'stage') or { return installer_error(err) }
	installer.stage() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `install` at line 155.
pub fn ruby_installer_l155_d17_install(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'install') or { return installer_error(err) }
	installer.install() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `check_deprecate_disable` at line 199.
pub fn ruby_installer_l199_d18_check_deprecate_disable(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'check_deprecate_disable') or { return installer_error(err) }
	message := installer.check_deprecate_disable() or { return installer_error(err) }
	return if message == '' { installer_nil() } else { ruby.string_value(message) }
}

// Ruby method `check_conflicts` at line 216.
pub fn ruby_installer_l216_d19_check_conflicts(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'check_conflicts') or { return installer_error(err) }
	installer.check_conflicts() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `uninstall_existing_cask` at line 240.
pub fn ruby_installer_l240_d20_uninstall_existing_cask(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'uninstall_existing_cask') or { return installer_error(err) }
	installer.uninstall_existing_cask() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `summary` at line 249.
pub fn ruby_installer_l249_d21_summary(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'summary') or { return installer_error(err) }
	return ruby.string_value(installer.summary())
}

// Ruby method `downloader` at line 257.
pub fn ruby_installer_l257_d22_downloader(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'downloader') or { return installer_error(err) }
	request := installer.download_request(false, none)
	return ruby.structured_value('Cask::Download', installer.cask.token, {
		'token':       installer.cask.token
		'url':         request.url
		'require_sha': request.require_sha.str()
	})
}

// Ruby method `download(quiet: nil, timeout: nil)` at line 272.
pub fn ruby_installer_l272_d23_download(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'download') or { return installer_error(err) }
	options := if args.len > 1 { args[1].map_data.clone() } else { map[string]ruby.Value{} }
	quiet := installer_value_bool(options, 'quiet', false)
	timeout := if raw := options['timeout'] { ?f64(raw.as_float() or { 0.0 }) } else { none }
	return ruby.object_value('Pathname', installer.download(quiet, timeout) or {
		return installer_error(err)
	})
}

// Ruby method `primary_container` at line 279.
pub fn ruby_installer_l279_d24_primary_container(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'primary_container') or { return installer_error(err) }
	return ruby.object_value('UnpackStrategy', installer.primary_container() or {
		return installer_error(err)
	})
}

// Ruby method `artifacts` at line 286.
pub fn ruby_installer_l286_d25_artifacts(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'artifacts') or { return installer_error(err) }
	return ruby.array_value(installer.artifacts())
}

// Ruby method `extract_primary_container(to: @cask.staged_path)` at line 291.
pub fn ruby_installer_l291_d26_extract_primary_container(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'extract_primary_container') or { return installer_error(err) }
	destination := if args.len > 1 { args[1].as_string() } else { '' }
	installer.extract_primary_container(destination) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `process_rename_operations(target_dir: nil)` at line 296.
pub fn ruby_installer_l296_d27_process_rename_operations(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'process_rename_operations') or { return installer_error(err) }
	target := if args.len > 1 { args[1].as_string() } else { '' }
	installer.process_rename_operations(target) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `install_artifacts(predecessor: nil)` at line 301.
pub fn ruby_installer_l301_d28_install_artifacts(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'install_artifacts') or { return installer_error(err) }
	predecessor := if args.len > 1 { args[1].as_string() } else { '' }
	installer.install_artifacts(predecessor) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `check_requirements` at line 359.
pub fn ruby_installer_l359_d29_check_requirements(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'check_requirements') or { return installer_error(err) }
	installer.check_requirements() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `check_stanza_os_requirements` at line 367.
pub fn ruby_installer_l367_d30_check_stanza_os_requirements(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'check_stanza_os_requirements') or { return installer_error(err) }
	installer.check_stanza_os_requirements() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `check_supported_system` at line 374.
pub fn ruby_installer_l374_d31_check_supported_system(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'check_supported_system') or { return installer_error(err) }
	installer.check_supported_system() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `check_macos_requirements` at line 385.
pub fn ruby_installer_l385_d32_check_macos_requirements(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'check_macos_requirements') or { return installer_error(err) }
	installer.check_macos_requirements() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `check_arch_requirements` at line 393.
pub fn ruby_installer_l393_d33_check_arch_requirements(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'check_arch_requirements') or { return installer_error(err) }
	installer.check_arch_requirements() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `cask_and_formula_dependencies` at line 410.
pub fn ruby_installer_l410_d34_cask_and_formula_dependencies(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'cask_and_formula_dependencies') or { return installer_error(err) }
	dependencies := installer.cask_and_formula_dependencies() or { return installer_error(err) }
	return ruby.array_value(dependencies.map(installer_dependency_value(it)))
}

// Ruby method `missing_cask_and_formula_dependencies` at line 429.
pub fn ruby_installer_l429_d35_missing_cask_and_formula_dependencies(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'missing_cask_and_formula_dependencies') or { return installer_error(err) }
	dependencies := installer.missing_cask_and_formula_dependencies() or { return installer_error(err) }
	return ruby.array_value(dependencies.map(installer_dependency_value(it)))
}

// Ruby method `satisfy_cask_and_formula_dependencies` at line 441.
pub fn ruby_installer_l441_d36_satisfy_cask_and_formula_dependencies(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'satisfy_cask_and_formula_dependencies') or { return installer_error(err) }
	installer.satisfy_cask_and_formula_dependencies() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `caveats` at line 500.
pub fn ruby_installer_l500_d37_caveats(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'caveats') or { return installer_error(err) }
	text := installer.caveats()
	return if text == '' { installer_nil() } else { ruby.string_value(text) }
}

// Ruby method `metadata_subdir` at line 505.
pub fn ruby_installer_l505_d38_metadata_subdir(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'metadata_subdir') or { return installer_error(err) }
	return ruby.object_value('Pathname', installer.metadata_subdir() or {
		return installer_error(err)
	})
}

// Ruby method `save_caskfile` at line 518.
pub fn ruby_installer_l518_d39_save_caskfile(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'save_caskfile') or { return installer_error(err) }
	installer.save_caskfile() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `save_config_file` at line 535.
pub fn ruby_installer_l535_d40_save_config_file(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'save_config_file') or { return installer_error(err) }
	installer.save_config_file() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `save_download_sha` at line 540.
pub fn ruby_installer_l540_d41_save_download_sha(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'save_download_sha') or { return installer_error(err) }
	installer.save_download_sha() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `uninstall(successor: nil)` at line 547.
pub fn ruby_installer_l547_d42_uninstall(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'uninstall') or { return installer_error(err) }
	successor := if args.len > 1 { args[1].as_string() } else { '' }
	installer.uninstall(successor) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `remove_tabfile` at line 567.
pub fn ruby_installer_l567_d43_remove_tabfile(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'remove_tabfile') or { return installer_error(err) }
	installer.remove_tabfile() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `remove_config_file` at line 574.
pub fn ruby_installer_l574_d44_remove_config_file(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'remove_config_file') or { return installer_error(err) }
	installer.remove_config_file() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `remove_download_sha` at line 580.
pub fn ruby_installer_l580_d45_remove_download_sha(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'remove_download_sha') or { return installer_error(err) }
	installer.remove_download_sha() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `start_upgrade(successor:, quit: true)` at line 586.
pub fn ruby_installer_l586_d46_start_upgrade(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'start_upgrade') or { return installer_error(err) }
	options := if args.len > 1 { args[1].map_data.clone() } else { map[string]ruby.Value{} }
	installer.start_upgrade(installer_value_string(options, 'successor', ''), installer_value_bool(options, 'quit', true)) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `backup` at line 592.
pub fn ruby_installer_l592_d47_backup(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'backup') or { return installer_error(err) }
	installer.backup() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `restore_backup` at line 606.
pub fn ruby_installer_l606_d48_restore_backup(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'restore_backup') or { return installer_error(err) }
	installer.restore_backup() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `revert_upgrade(predecessor:)` at line 623.
pub fn ruby_installer_l623_d49_revert_upgrade(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'revert_upgrade') or { return installer_error(err) }
	predecessor := if args.len > 1 { args[1].as_string() } else { '' }
	installer.revert_upgrade(predecessor) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `finalize_upgrade` at line 630.
pub fn ruby_installer_l630_d50_finalize_upgrade(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'finalize_upgrade') or { return installer_error(err) }
	installer.finalize_upgrade() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `uninstall_artifacts(clear: false, successor: nil, quit: true)` at line 639.
pub fn ruby_installer_l639_d51_uninstall_artifacts(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'uninstall_artifacts') or { return installer_error(err) }
	options := if args.len > 1 { args[1].map_data.clone() } else { map[string]ruby.Value{} }
	installer.uninstall_artifacts(installer_value_bool(options, 'clear', false), installer_value_string(options, 'successor', ''), installer_value_bool(options, 'quit', true)) or {
		return installer_error(err)
	}
	return installer_nil()
}

// Ruby method `zap` at line 692.
pub fn ruby_installer_l692_d52_zap(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'zap') or { return installer_error(err) }
	installer.zap() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `backup_path` at line 708.
pub fn ruby_installer_l708_d53_backup_path(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'backup_path') or { return installer_error(err) }
	path := installer.backup_path()
	return if path == '' { installer_nil() } else { ruby.object_value('Pathname', path) }
}

// Ruby method `backup_metadata_path` at line 715.
pub fn ruby_installer_l715_d54_backup_metadata_path(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'backup_metadata_path') or { return installer_error(err) }
	path := installer.backup_metadata_path()
	return if path == '' { installer_nil() } else { ruby.object_value('Pathname', path) }
}

// Ruby method `gain_permissions_remove(path)` at line 722.
pub fn ruby_installer_l722_d55_gain_permissions_remove(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'gain_permissions_remove') or { return installer_error(err) }
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'gain_permissions_remove requires a path')
	}
	installer.gain_permissions_remove(args[1].as_string()) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `purge_backed_up_versioned_files` at line 727.
pub fn ruby_installer_l727_d56_purge_backed_up_versioned_files(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'purge_backed_up_versioned_files') or { return installer_error(err) }
	installer.purge_backed_up_versioned_files() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `purge_versioned_files` at line 742.
pub fn ruby_installer_l742_d57_purge_versioned_files(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'purge_versioned_files') or { return installer_error(err) }
	installer.purge_versioned_files() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `purge_caskroom_path` at line 765.
pub fn ruby_installer_l765_d58_purge_caskroom_path(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'purge_caskroom_path') or { return installer_error(err) }
	installer.purge_caskroom_path() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `forbidden_tap_check(cask_only: false)` at line 772.
pub fn ruby_installer_l772_d59_forbidden_tap_check(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'forbidden_tap_check') or { return installer_error(err) }
	cask_only := args.len > 1 && installer_value_bool(args[1].map_data, 'cask_only', false)
	installer.forbidden_tap_check(cask_only) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `forbidden_cask_and_formula_check(cask_only: false)` at line 814.
pub fn ruby_installer_l814_d60_forbidden_cask_and_formula_check(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'forbidden_cask_and_formula_check') or {
		return installer_error(err)
	}
	cask_only := args.len > 1 && installer_value_bool(args[1].map_data, 'cask_only', false)
	installer.forbidden_cask_and_formula_check(cask_only) or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `forbidden_cask_artifacts_check` at line 872.
pub fn ruby_installer_l872_d61_forbidden_cask_artifacts_check(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'forbidden_cask_artifacts_check') or {
		return installer_error(err)
	}
	installer.forbidden_cask_artifacts_check() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `prelude` at line 899.
pub fn ruby_installer_l899_d62_prelude(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'prelude') or { return installer_error(err) }
	installer.prelude() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `source_download_requires_pre_fetch?` at line 912.
pub fn ruby_installer_l912_d63_source_download_requires_pre_fetch(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'source_download_requires_pre_fetch?') or {
		return installer_error(err)
	}
	return ruby.bool_value(installer.source_download_requires_pre_fetch())
}

// Ruby method `prelude_fetch(download_queue: @download_queue)` at line 917.
pub fn ruby_installer_l917_d64_prelude_fetch(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'prelude_fetch') or { return installer_error(err) }
	installer.prelude_fetch() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `prelude_fetch_download` at line 924.
pub fn ruby_installer_l924_d65_prelude_fetch_download(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'prelude_fetch_download') or {
		return installer_error(err)
	}
	download := installer.prelude_fetch_download() or { return installer_error(err) }
	return if download == '' {
		installer_nil()
	} else {
		ruby.object_value('Homebrew::API::SourceDownload', download)
	}
}

// Ruby method `enqueue_downloads` at line 941.
pub fn ruby_installer_l941_d66_enqueue_downloads(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'enqueue_downloads') or { return installer_error(err) }
	installer.enqueue_downloads() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `load_installed_caskfile!` at line 960.
pub fn ruby_installer_l960_d67_load_installed_caskfile(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'load_installed_caskfile!') or {
		return installer_error(err)
	}
	installer.load_installed_caskfile() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `remove_broken_caskroom_symlinks` at line 1030.
pub fn ruby_installer_l1030_d68_remove_broken_caskroom_symlinks(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'remove_broken_caskroom_symlinks') or {
		return installer_error(err)
	}
	installer.remove_broken_caskroom_symlinks() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `installed_uninstall_artifacts_missing?(installed_caskfile)` at line 1042.
pub fn ruby_installer_l1042_d69_installed_uninstall_artifacts_missing(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'installed_uninstall_artifacts_missing?') or {
		return installer_error(err)
	}
	path := if args.len > 1 { args[1].as_string() } else { '' }
	installed_json := if args.len > 2 {
		args[2].map_data.clone()
	} else {
		map[string]ruby.Value{}
	}
	tab_artifacts := if args.len > 3 {
		args[3].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	return ruby.bool_value(installer.installed_uninstall_artifacts_missing(path, installed_json, tab_artifacts))
}

// Ruby method `check_prelude_requirements` at line 1052.
pub fn ruby_installer_l1052_d70_check_prelude_requirements(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'check_prelude_requirements') or {
		return installer_error(err)
	}
	installer.check_prelude_requirements() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `source_download` at line 1063.
pub fn ruby_installer_l1063_d71_source_download(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'source_download') or { return installer_error(err) }
	return ruby.object_value('Homebrew::API::SourceDownload', installer.source_download() or {
		return installer_error(err)
	})
}

// Ruby method `load_cask_from_source_api!` at line 1068.
pub fn ruby_installer_l1068_d72_load_cask_from_source_api(args ...ruby.Value) ruby.Value {
	mut installer := installer_receiver(args, 'load_cask_from_source_api!') or {
		return installer_error(err)
	}
	installer.load_cask_from_source_api() or { return installer_error(err) }
	return installer_nil()
}

// Ruby method `cask_from_source_api?` at line 1073.
pub fn ruby_installer_l1073_d73_cask_from_source_api(args ...ruby.Value) ruby.Value {
	installer := installer_receiver(args, 'cask_from_source_api?') or { return installer_error(err) }
	return ruby.bool_value(installer.cask_from_source_api())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula_installer"
// 5: require "unpack_strategy"
// 6: require "utils/topological_hash"
// 7: require "utils/analytics"
// 8: require "utils/output"
// 9:
// 10: require "api/cask_download"
// 11: require "cask/config"
// 12: require "cask/dsl"
// 13: require "cask/download"
// 14: require "cask/migrator"
// 15: require "cask/quarantine"
// 16: require "cask/tab"
// 17: require "trust"
// 18:
// 19: module Cask
// 20:   # Installer for a {Cask}.
// 21:   class Installer
// 22:     extend ::Utils::Output::Mixin
// 23:     include ::Utils::Output::Mixin
// 24:
// 25:     sig { returns(::Cask::Cask) }
// 26:     attr_reader :cask
// 27:
// 28:     sig {
// 29:       params(
// 30:         cask: ::Cask::Cask, command: T.class_of(SystemCommand), force: T::Boolean, adopt: T::Boolean,
// 31:         skip_cask_deps: T::Boolean, binaries: T::Boolean, verbose: T::Boolean, zap: T::Boolean,
// 32:         require_sha: T::Boolean, upgrade: T::Boolean, reinstall: T::Boolean,
// 33:         installed_on_request: T::Boolean, verify_download_integrity: T::Boolean,
// 34:         quiet: T::Boolean, download_queue: Homebrew::DownloadQueue, defer_fetch: T::Boolean,
// 35:         default_uninstall_artifacts: T.nilable(ArtifactSet)
// 36:       ).void
// 37:     }
// 38:     def initialize(cask, command: SystemCommand, force: false, adopt: false,
// 39:                    skip_cask_deps: false, binaries: true, verbose: false,
// 40:                    zap: false, require_sha: false, upgrade: false, reinstall: false,
// 41:                    installed_on_request: true,
// 42:                    verify_download_integrity: true, quiet: false,
// 43:                    download_queue: Homebrew.default_download_queue, defer_fetch: false,
// 44:                    default_uninstall_artifacts: nil)
// 45:       @cask = cask
// 46:       @command = command
// 47:       @force = force
// 48:       @adopt = adopt
// 49:       @skip_cask_deps = skip_cask_deps
// 50:       @binaries = binaries
// 51:       @verbose = verbose
// 52:       @zap = zap
// 53:       @require_sha = require_sha
// 54:       @reinstall = reinstall
// 55:       @upgrade = upgrade
// 56:       @installed_on_request = installed_on_request
// 57:       @verify_download_integrity = verify_download_integrity
// 58:       @quiet = quiet
// 59:       @download_queue = download_queue
// 60:       @defer_fetch = defer_fetch
// 61:       @source_download = T.let(nil, T.nilable(Homebrew::API::SourceDownload))
// 62:       # Restricts what `#uninstall` removes, for artifacts that are shared with a cask
// 63:       # which must be kept installed.
// 64:       @default_uninstall_artifacts = default_uninstall_artifacts
// 65:       @ran_prelude_fetch = T.let(false, T::Boolean)
// 66:       @ran_prelude = T.let(false, T::Boolean)
// 67:       @cask_and_formula_dependencies = T.let(nil, T.nilable(T::Array[T.any(Formula, ::Cask::Cask)]))
// 68:       @installed_uninstall_artifacts_missing = T.let(false, T::Boolean)
// 69:     end
// 70:
// 71:     sig { returns(T::Boolean) }
// 72:     def adopt? = @adopt
// 73:
// 74:     sig { returns(T::Boolean) }
// 75:     def binaries? = @binaries
// 76:
// 77:     sig { returns(T::Boolean) }
// 78:     def force? = @force
// 79:
// 80:     sig { returns(T::Boolean) }
// 81:     def installed_on_request? = @installed_on_request
// 82:
// 83:     sig { returns(T::Boolean) }
// 84:     def quiet? = @quiet
// 85:
// 86:     sig { returns(T::Boolean) }
// 87:     def reinstall? = @reinstall
// 88:
// 89:     sig { returns(T::Boolean) }
// 90:     def require_sha? = @require_sha
// 91:
// 92:     sig { returns(T::Boolean) }
// 93:     def skip_cask_deps? = @skip_cask_deps
// 94:
// 95:     sig { returns(T::Boolean) }
// 96:     def upgrade? = @upgrade
// 97:
// 98:     sig { returns(T::Boolean) }
// 99:     def verbose? = @verbose
// 100:
// 101:     sig { returns(T::Boolean) }
// 102:     def zap? = @zap
// 103:
// 104:     sig { params(cask: ::Cask::Cask).returns(T.nilable(String)) }
// 105:     def self.caveats(cask)
// 106:       odebug "Printing caveats"
// 107:
// 108:       caveats = cask.caveats
// 109:       return if caveats.empty?
// 110:
// 111:       Homebrew.messages.record_caveats(cask.token, caveats)
// 112:
// 113:       <<~EOS
// 114:         #{ohai_title "Caveats"}
// 115:         #{caveats}
// 116:       EOS
// 117:     end
// 118:
// 119:     sig { params(quiet: T.nilable(T::Boolean), timeout: T.nilable(T.any(Integer, Float))).void }
// 120:     def fetch(quiet: nil, timeout: nil)
// 121:       odebug "Cask::Installer#fetch"
// 122:
// 123:       prelude
// 124:
// 125:       download(quiet:, timeout:) unless @defer_fetch
// 126:
// 127:       satisfy_cask_and_formula_dependencies
// 128:     end
// 129:
// 130:     sig { void }
// 131:     def stage
// 132:       odebug "Cask::Installer#stage"
// 133:
// 134:       Caskroom.ensure_caskroom_exists
// 135:
// 136:       queued_staged_path = downloader.staged_path_from_download_queue
// 137:       queued_staged_marker = downloader.staged_path_from_download_queue_marker
// 138:       if @defer_fetch && queued_staged_marker.exist? && !@cask.staged_path.exist?
// 139:         @cask.staged_path.dirname.mkpath
// 140:         FileUtils.mv(queued_staged_path, @cask.staged_path)
// 141:         downloader.purge_staged_from_download_queue(command: @command)
// 142:       else
// 143:         downloader.purge_staged_from_download_queue(command: @command) if @defer_fetch
// 144:         extract_primary_container
// 145:         process_rename_operations
// 146:       end
// 147:       save_caskfile
// 148:     rescue => e
// 149:       downloader.purge_staged_from_download_queue(command: @command) if @defer_fetch
// 150:       purge_versioned_files
// 151:       raise e
// 152:     end
// 153:
// 154:     sig { void }
// 155:     def install
// 156:       start_time = Time.now
// 157:       odebug "Cask::Installer#install"
// 158:
// 159:       Migrator.migrate_if_needed(@cask)
// 160:
// 161:       old_config = @cask.config
// 162:       predecessor = @cask if reinstall? && @cask.installed?
// 163:
// 164:       prelude
// 165:
// 166:       print caveats
// 167:       fetch
// 168:       uninstall_existing_cask if reinstall?
// 169:
// 170:       backup if force? && @cask.staged_path.exist? && @cask.metadata_versioned_path.exist?
// 171:
// 172:       oh1 "Installing Cask #{Formatter.identifier(@cask)}"
// 173:       stage
// 174:
// 175:       @cask.config = @cask.default_config.merge(old_config)
// 176:
// 177:       install_artifacts(predecessor:)
// 178:
// 179:       tab = Tab.create(@cask)
// 180:       tab.installed_on_request = installed_on_request?
// 181:       tab.write
// 182:
// 183:       if (tap = @cask.tap) && tap.should_report_analytics?
// 184:         ::Utils::Analytics.report_package_event(:cask_install, package_name: @cask.token, tap_name: tap.name,
// 185: on_request: true)
// 186:       end
// 187:
// 188:       purge_backed_up_versioned_files
// 189:
// 190:       puts summary
// 191:       end_time = Time.now
// 192:       Homebrew.messages.package_installed(@cask.token, end_time - start_time)
// 193:     rescue
// 194:       restore_backup
// 195:       raise
// 196:     end
// 197:
// 198:     sig { void }
// 199:     def check_deprecate_disable
// 200:       deprecate_disable_type = DeprecateDisable.type(@cask)
// 201:       return if deprecate_disable_type.nil?
// 202:
// 203:       message = DeprecateDisable.message(@cask).to_s
// 204:       message_full = "#{@cask.token} has been #{message}"
// 205:
// 206:       case deprecate_disable_type
// 207:       when :deprecated
// 208:         opoo message_full
// 209:       when :disabled
// 210:         GitHub::Actions.puts_annotation_if_env_set!(:error, message)
// 211:         raise CaskCannotBeInstalledError.new(@cask, message)
// 212:       end
// 213:     end
// 214:
// 215:     sig { void }
// 216:     def check_conflicts
// 217:       return unless @cask.conflicts_with
// 218:
// 219:       @cask.conflicts_with[:cask].each do |conflicting_cask|
// 220:         if (conflicting_cask_tap_with_token = Tap.with_cask_token(conflicting_cask))
// 221:           conflicting_cask_tap, = conflicting_cask_tap_with_token
// 222:           next unless conflicting_cask_tap.installed?
// 223:         end
// 224:
// 225:         if (installed_caskfile = Caskroom.cask_installed_caskfile(conflicting_cask))
// 226:           raise CaskConflictError.new(
// 227:             @cask,
// 228:             ::Cask::Cask.new(CaskLoader.token_from_path(installed_caskfile)),
// 229:           )
// 230:         end
// 231:
// 232:         conflicting_cask = CaskLoader.load(conflicting_cask)
// 233:         raise CaskConflictError.new(@cask, conflicting_cask) if conflicting_cask.installed?
// 234:       rescue CaskUnavailableError, Homebrew::UntrustedTapError
// 235:         next # Ignore conflicting Casks that are unavailable or untrusted.
// 236:       end
// 237:     end
// 238:
// 239:     sig { void }
// 240:     def uninstall_existing_cask
// 241:       return unless @cask.installed?
// 242:
// 243:       # Always force uninstallation, ignore method parameter
// 244:       cask_installer = Installer.new(@cask, verbose: verbose?, force: true, upgrade: upgrade?, reinstall: true)
// 245:       zap? ? cask_installer.zap : cask_installer.uninstall(successor: @cask)
// 246:     end
// 247:
// 248:     sig { returns(String) }
// 249:     def summary
// 250:       s = +""
// 251:       s << "#{Homebrew::EnvConfig.install_badge}  " unless Homebrew::EnvConfig.no_emoji?
// 252:       s << "#{@cask} was successfully #{upgrade? ? "upgraded" : "installed"}!"
// 253:       s.freeze
// 254:     end
// 255:
// 256:     sig { returns(Download) }
// 257:     def downloader
// 258:       @downloader ||= T.let(
// 259:         (if @cask.loaded_from_internal_api? && !@cask.caskfile_only?
// 260:            Homebrew::API::CaskDownload.download(
// 261:              token:       @cask.token,
// 262:              cask_struct: Homebrew::API::Internal.cask_struct(@cask.token),
// 263:              languages:   @cask.config.languages,
// 264:              require_sha: require_sha? && !force?,
// 265:            )
// 266:         end) || Download.new(@cask, require_sha: require_sha? && !force?),
// 267:         T.nilable(Download),
// 268:       )
// 269:     end
// 270:
// 271:     sig { params(quiet: T.nilable(T::Boolean), timeout: T.nilable(T.any(Integer, Float))).returns(Pathname) }
// 272:     def download(quiet: nil, timeout: nil)
// 273:       # Store cask download path in cask to prevent multiple downloads in a row when checking if it's outdated
// 274:       @cask.download ||= downloader.fetch(quiet:, verify_download_integrity: @verify_download_integrity,
// 275:                                           timeout:)
// 276:     end
// 277:
// 278:     sig { returns(UnpackStrategy) }
// 279:     def primary_container
// 280:       download(quiet: true) if @cask.download.nil?
// 281:
// 282:       downloader.primary_container
// 283:     end
// 284:
// 285:     sig { returns(ArtifactSet) }
// 286:     def artifacts
// 287:       @default_uninstall_artifacts || @cask.artifacts
// 288:     end
// 289:
// 290:     sig { params(to: Pathname).void }
// 291:     def extract_primary_container(to: @cask.staged_path)
// 292:       downloader.extract_primary_container(to:, verbose: verbose?)
// 293:     end
// 294:
// 295:     sig { params(target_dir: T.nilable(Pathname)).void }
// 296:     def process_rename_operations(target_dir: nil)
// 297:       downloader.process_rename_operations(target_dir: target_dir || @cask.staged_path)
// 298:     end
// 299:
// 300:     sig { params(predecessor: T.nilable(Cask)).void }
// 301:     def install_artifacts(predecessor: nil)
// 302:       already_installed_artifacts = []
// 303:
// 304:       odebug "Installing artifacts"
// 305:
// 306:       artifacts.each do |artifact|
// 307:         next unless artifact.respond_to?(:install_phase)
// 308:
// 309:         odebug "Installing artifact of class #{artifact.class}"
// 310:
// 311:         next if artifact.is_a?(Artifact::Binary) && !binaries?
// 312:
// 313:         artifact = T.cast(
// 314:           artifact,
// 315:           T.any(
// 316:             Artifact::AbstractFlightBlock,
// 317:             Artifact::GeneratedCompletion,
// 318:             Artifact::Installer,
// 319:             Artifact::KeyboardLayout,
// 320:             Artifact::Mdimporter,
// 321:             Artifact::Moved,
// 322:             Artifact::PostflightSteps,
// 323:             Artifact::PreflightSteps,
// 324:             Artifact::Pkg,
// 325:             Artifact::Qlplugin,
// 326:             Artifact::Symlinked,
// 327:           ),
// 328:         )
// 329:
// 330:         artifact.install_phase(
// 331:           command: @command, verbose: verbose?, adopt: adopt?, auto_updates: @cask.auto_updates,
// 332:           force: force?, predecessor:
// 333:         )
// 334:         already_installed_artifacts.unshift(artifact)
// 335:       end
// 336:
// 337:       save_config_file
// 338:       save_download_sha if @cask.version.latest?
// 339:     rescue => e
// 340:       begin
// 341:         already_installed_artifacts&.each do |artifact|
// 342:           if artifact.respond_to?(:uninstall_phase)
// 343:             odebug "Reverting installation of artifact of class #{artifact.class}"
// 344:             artifact.uninstall_phase(command: @command, verbose: verbose?, force: force?)
// 345:           end
// 346:
// 347:           next unless artifact.respond_to?(:post_uninstall_phase)
// 348:
// 349:           odebug "Reverting installation of artifact of class #{artifact.class}"
// 350:           artifact.post_uninstall_phase(command: @command, verbose: verbose?, force: force?)
// 351:         end
// 352:       ensure
// 353:         purge_versioned_files
// 354:         raise e
// 355:       end
// 356:     end
// 357:
// 358:     sig { void }
// 359:     def check_requirements
// 360:       check_stanza_os_requirements
// 361:       check_supported_system
// 362:       check_macos_requirements
// 363:       check_arch_requirements
// 364:     end
// 365:
// 366:     sig { void }
// 367:     def check_stanza_os_requirements
// 368:       return if @cask.supports_macos?
// 369:
// 370:       raise CaskError, "#{@cask}: This cask requires Linux."
// 371:     end
// 372:
// 373:     sig { void }
// 374:     def check_supported_system
// 375:       # API data without an installable artifact means this system is unsupported.
// 376:       # Source loads keep working for unaudited casks, e.g. naked containers.
// 377:       return unless @cask.loaded_from_api?
// 378:       return if @cask.installable_artifact?
// 379:
// 380:       os_name = Homebrew::SimulateSystem.simulating_or_running_on_macos? ? "macOS" : "Linux"
// 381:       raise CaskError, "#{@cask}: This cask is not available on #{os_name}."
// 382:     end
// 383:
// 384:     sig { void }
// 385:     def check_macos_requirements
// 386:       macos_requirement = [@cask.depends_on.macos, @cask.depends_on.maximum_macos].compact.find { !it.satisfied? }
// 387:       return unless macos_requirement
// 388:
// 389:       raise CaskError, "#{@cask}: #{macos_requirement.message(type: :cask)}"
// 390:     end
// 391:
// 392:     sig { void }
// 393:     def check_arch_requirements
// 394:       return if @cask.depends_on.arch.nil?
// 395:
// 396:       @current_arch = T.let(@current_arch, T.nilable(T::Hash[Symbol, T.untyped]))
// 397:       @current_arch ||= { type: Hardware::CPU.type, bits: Hardware::CPU.bits }
// 398:       return if @cask.depends_on.arch.any? do |arch|
// 399:         arch[:type] == @current_arch[:type] &&
// 400:         Array(arch[:bits]).include?(@current_arch[:bits])
// 401:       end
// 402:
// 403:       raise CaskError,
// 404:             "#{@cask}: This cask depends on hardware architecture being one of " \
// 405:             "[#{@cask.depends_on.arch.join(", ")}], " \
// 406:             "but you are running #{@current_arch}."
// 407:     end
// 408:
// 409:     sig { returns(T::Array[T.any(Formula, ::Cask::Cask)]) }
// 410:     def cask_and_formula_dependencies
// 411:       return @cask_and_formula_dependencies if @cask_and_formula_dependencies
// 412:
// 413:       graph = ::Utils::TopologicalHash.graph_package_dependencies(@cask)
// 414:
// 415:       raise CaskSelfReferencingDependencyError, @cask.token if graph.fetch(@cask).include?(@cask)
// 416:
// 417:       pc = primary_container
// 418:       raise "unexpected nil primary_container" unless pc
// 419:
// 420:       ::Utils::TopologicalHash.graph_package_dependencies(pc.dependencies, graph)
// 421:
// 422:       @cask_and_formula_dependencies = graph.tsort_with_cycles do |cycles|
// 423:         cyclic_dependencies = cycles.sort_by(&:count).fetch(-1) - [@cask]
// 424:         raise CaskCyclicDependencyError.new(@cask.token, cyclic_dependencies.to_sentence)
// 425:       end - [@cask]
// 426:     end
// 427:
// 428:     sig { returns(T::Array[T.any(Formula, ::Cask::Cask)]) }
// 429:     def missing_cask_and_formula_dependencies
// 430:       cask_and_formula_dependencies.reject do |cask_or_formula|
// 431:         case cask_or_formula
// 432:         when Formula
// 433:           cask_or_formula.any_version_installed? && cask_or_formula.optlinked?
// 434:         when Cask
// 435:           cask_or_formula.installed?
// 436:         end
// 437:       end
// 438:     end
// 439:
// 440:     sig { void }
// 441:     def satisfy_cask_and_formula_dependencies
// 442:       return unless installed_on_request?
// 443:
// 444:       formulae_and_casks = cask_and_formula_dependencies
// 445:
// 446:       return if formulae_and_casks.empty?
// 447:
// 448:       missing_formulae_and_casks = missing_cask_and_formula_dependencies
// 449:
// 450:       if missing_formulae_and_casks.empty?
// 451:         puts "All dependencies satisfied."
// 452:         return
// 453:       end
// 454:
// 455:       ohai "Installing dependencies: #{missing_formulae_and_casks.join(", ")}"
// 456:       cask_installers = T.let([], T::Array[Installer])
// 457:       formula_installers = T.let([], T::Array[FormulaInstaller])
// 458:
// 459:       missing_formulae_and_casks.each do |cask_or_formula|
// 460:         if cask_or_formula.is_a?(Cask)
// 461:           if skip_cask_deps?
// 462:             opoo "`--skip-cask-deps` is set; skipping installation of #{cask_or_formula}."
// 463:             next
// 464:           end
// 465:
// 466:           cask_installers << Installer.new(
// 467:             cask_or_formula,
// 468:             adopt:                adopt?,
// 469:             binaries:             binaries?,
// 470:             force:                false,
// 471:             installed_on_request: false,
// 472:             quiet:                quiet?,
// 473:             require_sha:          require_sha?,
// 474:             verbose:              verbose?,
// 475:           )
// 476:         else
// 477:           formula_installers << FormulaInstaller.new(
// 478:             cask_or_formula,
// 479:             **{
// 480:               show_header:          true,
// 481:               installed_on_request: false,
// 482:               verbose:              verbose?,
// 483:             }.compact,
// 484:           )
// 485:         end
// 486:       end
// 487:
// 488:       cask_installers.each(&:install)
// 489:       return if formula_installers.blank?
// 490:
// 491:       Homebrew::Install.perform_preinstall_checks_once
// 492:       valid_formula_installers = Homebrew::Install.fetch_formulae(formula_installers)
// 493:       valid_formula_installers.each do |formula_installer|
// 494:         formula_installer.install
// 495:         formula_installer.finish
// 496:       end
// 497:     end
// 498:
// 499:     sig { returns(T.nilable(String)) }
// 500:     def caveats
// 501:       self.class.caveats(@cask)
// 502:     end
// 503:
// 504:     sig { returns(Pathname) }
// 505:     def metadata_subdir
// 506:       @metadata_subdir ||= T.let(
// 507:         begin
// 508:           msd = @cask.metadata_subdir("Casks", timestamp: :now, create: true)
// 509:           raise "unexpected nil metadata_subdir" unless msd
// 510:
// 511:           msd
// 512:         end,
// 513:         T.nilable(Pathname),
// 514:       )
// 515:     end
// 516:
// 517:     sig { void }
// 518:     def save_caskfile
// 519:       old_savedir = @cask.metadata_timestamped_path
// 520:
// 521:       return if @cask.source.blank?
// 522:
// 523:       if @cask.uninstall_flight_blocks?
// 524:         (metadata_subdir/"#{@cask.token}.rb").write @cask.source.to_s
// 525:       else
// 526:         installed_json = @cask.to_installed_json_hash
// 527:         installed_json["artifacts"] = [] if @cask.artifacts_list(uninstall_only: true).empty?
// 528:         (metadata_subdir/"#{@cask.token}.json").write JSON.pretty_generate(installed_json)
// 529:       end
// 530:
// 531:       FileUtils.rm_r(old_savedir) if old_savedir
// 532:     end
// 533:
// 534:     sig { void }
// 535:     def save_config_file
// 536:       @cask.config_path.atomic_write(@cask.config.to_json)
// 537:     end
// 538:
// 539:     sig { void }
// 540:     def save_download_sha
// 541:       return unless @cask.checksumable?
// 542:
// 543:       @cask.download_sha_path.atomic_write(@cask.new_download_sha)
// 544:     end
// 545:
// 546:     sig { params(successor: T.nilable(Cask)).void }
// 547:     def uninstall(successor: nil)
// 548:       load_installed_caskfile!
// 549:       oh1 "Uninstalling Cask #{Formatter.identifier(@cask)}"
// 550:       if !reinstall? && !upgrade? && @installed_uninstall_artifacts_missing && artifacts.empty?
// 551:         opoo <<~EOS
// 552:           No uninstall artifact metadata is available for Cask '#{@cask}'.
// 553:           Homebrew will remove its records, but files installed by the Cask may remain.
// 554:         EOS
// 555:       end
// 556:       uninstall_artifacts(clear: true, successor:)
// 557:       if !reinstall? && !upgrade?
// 558:         remove_tabfile
// 559:         remove_download_sha
// 560:         remove_config_file
// 561:       end
// 562:       purge_versioned_files
// 563:       purge_caskroom_path if force?
// 564:     end
// 565:
// 566:     sig { void }
// 567:     def remove_tabfile
// 568:       tabfile = @cask.tab.tabfile
// 569:       FileUtils.rm_f tabfile if tabfile
// 570:       @cask.config_path.parent.rmdir_if_possible
// 571:     end
// 572:
// 573:     sig { void }
// 574:     def remove_config_file
// 575:       FileUtils.rm_f @cask.config_path
// 576:       @cask.config_path.parent.rmdir_if_possible
// 577:     end
// 578:
// 579:     sig { void }
// 580:     def remove_download_sha
// 581:       FileUtils.rm_f @cask.download_sha_path
// 582:       @cask.download_sha_path.parent.rmdir_if_possible
// 583:     end
// 584:
// 585:     sig { params(successor: T.nilable(Cask), quit: T::Boolean).void }
// 586:     def start_upgrade(successor:, quit: true)
// 587:       uninstall_artifacts(successor:, quit:)
// 588:       backup
// 589:     end
// 590:
// 591:     sig { void }
// 592:     def backup
// 593:       bp = backup_path
// 594:       raise "unexpected nil backup_path" unless bp
// 595:
// 596:       bmp = backup_metadata_path
// 597:       raise "unexpected nil backup_metadata_path" unless bmp
// 598:
// 599:       # The staged files may already be gone (e.g. an out-of-band cask update);
// 600:       # skip the rename rather than raising and aborting the upgrade.
// 601:       @cask.staged_path.rename bp.to_s if @cask.staged_path.exist?
// 602:       @cask.metadata_versioned_path.rename bmp.to_s if @cask.metadata_versioned_path.exist?
// 603:     end
// 604:
// 605:     sig { void }
// 606:     def restore_backup
// 607:       bp = backup_path
// 608:       return unless bp
// 609:
// 610:       bmp = backup_metadata_path
// 611:       return unless bmp
// 612:
// 613:       return if !bp.directory? || !bmp.directory?
// 614:
// 615:       FileUtils.rm_r(@cask.staged_path) if @cask.staged_path.exist?
// 616:       FileUtils.rm_r(@cask.metadata_versioned_path) if @cask.metadata_versioned_path.exist?
// 617:
// 618:       bp.rename @cask.staged_path.to_s
// 619:       bmp.rename @cask.metadata_versioned_path.to_s
// 620:     end
// 621:
// 622:     sig { params(predecessor: Cask).void }
// 623:     def revert_upgrade(predecessor:)
// 624:       opoo "Reverting upgrade for Cask #{@cask}"
// 625:       restore_backup
// 626:       install_artifacts(predecessor:)
// 627:     end
// 628:
// 629:     sig { void }
// 630:     def finalize_upgrade
// 631:       ohai "Purging files for version #{@cask.version} of Cask #{@cask}"
// 632:
// 633:       purge_backed_up_versioned_files
// 634:
// 635:       puts summary
// 636:     end
// 637:
// 638:     sig { params(clear: T::Boolean, successor: T.nilable(Cask), quit: T::Boolean).void }
// 639:     def uninstall_artifacts(clear: false, successor: nil, quit: true)
// 640:       odebug "Uninstalling artifacts"
// 641:       odebug "#{::Utils.pluralize("artifact", artifacts.length, include_count: true)} defined", artifacts
// 642:
// 643:       artifacts.each do |artifact|
// 644:         if artifact.respond_to?(:uninstall_phase)
// 645:           artifact = T.cast(
// 646:             artifact,
// 647:             T.any(
// 648:               Artifact::AbstractFlightBlock,
// 649:               Artifact::GeneratedCompletion,
// 650:               Artifact::KeyboardLayout,
// 651:               Artifact::Moved,
// 652:               Artifact::PostflightSteps,
// 653:               Artifact::PreflightSteps,
// 654:               Artifact::Qlplugin,
// 655:               Artifact::Symlinked,
// 656:               Artifact::Uninstall,
// 657:               Artifact::UninstallPostflightSteps,
// 658:               Artifact::UninstallPreflightSteps,
// 659:             ),
// 660:           )
// 661:
// 662:           odebug "Uninstalling artifact of class #{artifact.class}"
// 663:           uninstall_options = {
// 664:             command:   @command,
// 665:             verbose:   verbose?,
// 666:             skip:      clear,
// 667:             force:     force?,
// 668:             successor:,
// 669:             upgrade:   upgrade?,
// 670:             reinstall: reinstall?,
// 671:           }
// 672:           uninstall_options[:quit] = quit if artifact.is_a?(Artifact::Uninstall)
// 673:           artifact.uninstall_phase(**uninstall_options)
// 674:         end
// 675:
// 676:         next unless artifact.respond_to?(:post_uninstall_phase)
// 677:
// 678:         artifact = T.cast(artifact, Artifact::Uninstall)
// 679:
// 680:         odebug "Post-uninstalling artifact of class #{artifact.class}"
// 681:         artifact.post_uninstall_phase(
// 682:           command:   @command,
// 683:           verbose:   verbose?,
// 684:           skip:      clear,
// 685:           force:     force?,
// 686:           successor:,
// 687:         )
// 688:       end
// 689:     end
// 690:
// 691:     sig { void }
// 692:     def zap
// 693:       load_installed_caskfile!
// 694:       uninstall_artifacts
// 695:       if (zap_stanzas = @cask.artifacts.grep(Artifact::Zap)).empty?
// 696:         opoo "No zap stanza present for Cask '#{@cask}'"
// 697:       else
// 698:         ohai "Dispatching zap stanza"
// 699:         zap_stanzas.each do |stanza|
// 700:           stanza.zap_phase(command: @command, verbose: verbose?, force: force?)
// 701:         end
// 702:       end
// 703:       ohai "Removing all staged versions of Cask '#{@cask}'"
// 704:       purge_caskroom_path
// 705:     end
// 706:
// 707:     sig { returns(T.nilable(Pathname)) }
// 708:     def backup_path
// 709:       return if @cask.staged_path.nil?
// 710:
// 711:       Pathname("#{@cask.staged_path}.upgrading")
// 712:     end
// 713:
// 714:     sig { returns(T.nilable(Pathname)) }
// 715:     def backup_metadata_path
// 716:       return if @cask.metadata_versioned_path.nil?
// 717:
// 718:       Pathname("#{@cask.metadata_versioned_path}.upgrading")
// 719:     end
// 720:
// 721:     sig { params(path: Pathname).void }
// 722:     def gain_permissions_remove(path)
// 723:       Utils.gain_permissions_remove(path, command: @command)
// 724:     end
// 725:
// 726:     sig { void }
// 727:     def purge_backed_up_versioned_files
// 728:       # versioned staged distribution
// 729:       gain_permissions_remove(T.must(backup_path)) if backup_path&.exist?
// 730:
// 731:       # Cask metadata
// 732:       bmp = backup_metadata_path
// 733:       return unless bmp&.directory?
// 734:
// 735:       bmp.children.each do |subdir|
// 736:         gain_permissions_remove(subdir)
// 737:       end
// 738:       bmp.rmdir_if_possible
// 739:     end
// 740:
// 741:     sig { void }
// 742:     def purge_versioned_files
// 743:       ohai "Purging files for version #{@cask.version} of Cask #{@cask}"
// 744:
// 745:       # versioned staged distribution
// 746:       gain_permissions_remove(@cask.staged_path) if @cask.staged_path&.exist?
// 747:
// 748:       # Cask metadata
// 749:       if @cask.metadata_versioned_path.directory?
// 750:         @cask.metadata_versioned_path.children.each do |subdir|
// 751:           gain_permissions_remove(subdir)
// 752:         end
// 753:
// 754:         @cask.metadata_versioned_path.rmdir_if_possible
// 755:       end
// 756:       @cask.metadata_main_container_path.rmdir_if_possible unless upgrade?
// 757:
// 758:       # toplevel staged distribution
// 759:       @cask.caskroom_path.rmdir_if_possible unless upgrade?
// 760:
// 761:       remove_broken_caskroom_symlinks
// 762:     end
// 763:
// 764:     sig { void }
// 765:     def purge_caskroom_path
// 766:       odebug "Purging all staged versions of Cask #{@cask}"
// 767:       gain_permissions_remove(@cask.caskroom_path)
// 768:       remove_broken_caskroom_symlinks
// 769:     end
// 770:
// 771:     sig { params(cask_only: T::Boolean).void }
// 772:     def forbidden_tap_check(cask_only: false)
// 773:       return if Tap.allowed_taps.blank? && Tap.forbidden_taps.blank?
// 774:
// 775:       owner = Homebrew::EnvConfig.forbidden_owner
// 776:       owner_contact = if (contact = Homebrew::EnvConfig.forbidden_owner_contact.presence)
// 777:         "\n#{contact}"
// 778:       end
// 779:
// 780:       # Check the cask itself before its dependencies, since dependency resolution
// 781:       # for casks triggers a download via `primary_container`.
// 782:       cask_tap = @cask.tap
// 783:       if cask_tap.present? && (!cask_tap.allowed_by_env? || cask_tap.forbidden_by_env?)
// 784:         cask_error_message = "The installation of #{@cask.full_name} has the tap #{cask_tap}\n" \
// 785:                              "but #{owner} "
// 786:         cask_error_message << "has not allowed this tap in `$HOMEBREW_ALLOWED_TAPS`" unless cask_tap.allowed_by_env?
// 787:         cask_error_message << " and\n" if !cask_tap.allowed_by_env? && cask_tap.forbidden_by_env?
// 788:         cask_error_message << "has forbidden this tap in `$HOMEBREW_FORBIDDEN_TAPS`" if cask_tap.forbidden_by_env?
// 789:         cask_error_message << ".#{owner_contact}"
// 790:
// 791:         raise CaskCannotBeInstalledError.new(@cask, cask_error_message)
// 792:       end
// 793:
// 794:       return if cask_only
// 795:       return if skip_cask_deps?
// 796:
// 797:       cask_and_formula_dependencies.each do |cask_or_formula|
// 798:         dep_tap = cask_or_formula.tap
// 799:         next if dep_tap.blank? || (dep_tap.allowed_by_env? && !dep_tap.forbidden_by_env?)
// 800:
// 801:         dep_full_name = cask_or_formula.full_name
// 802:         error_message = "The installation of #{@cask} has a dependency #{dep_full_name}\n" \
// 803:                         "from the #{dep_tap} tap but #{owner} "
// 804:         error_message << "has not allowed this tap in `$HOMEBREW_ALLOWED_TAPS`" unless dep_tap.allowed_by_env?
// 805:         error_message << " and\n" if !dep_tap.allowed_by_env? && dep_tap.forbidden_by_env?
// 806:         error_message << "has forbidden this tap in `$HOMEBREW_FORBIDDEN_TAPS`" if dep_tap.forbidden_by_env?
// 807:         error_message << ".#{owner_contact}"
// 808:
// 809:         raise CaskCannotBeInstalledError.new(@cask, error_message)
// 810:       end
// 811:     end
// 812:
// 813:     sig { params(cask_only: T::Boolean).void }
// 814:     def forbidden_cask_and_formula_check(cask_only: false)
// 815:       forbid_casks = Homebrew::EnvConfig.forbid_casks?
// 816:       forbidden_formulae = Set.new(Homebrew::EnvConfig.forbidden_formulae.to_s.split)
// 817:       forbidden_casks = Set.new(Homebrew::EnvConfig.forbidden_casks.to_s.split)
// 818:       return if !forbid_casks && forbidden_formulae.blank? && forbidden_casks.blank?
// 819:
// 820:       owner = Homebrew::EnvConfig.forbidden_owner
// 821:       owner_contact = if (contact = Homebrew::EnvConfig.forbidden_owner_contact.presence)
// 822:         "\n#{contact}"
// 823:       end
// 824:
// 825:       cask_variable = if forbid_casks
// 826:         "HOMEBREW_FORBID_CASKS"
// 827:       elsif forbidden_casks.include?(@cask.token) || forbidden_casks.include?(@cask.full_name)
// 828:         "HOMEBREW_FORBIDDEN_CASKS"
// 829:       end
// 830:
// 831:       if cask_variable
// 832:         raise CaskCannotBeInstalledError.new(@cask, <<~EOS
// 833:           forbidden for installation by #{owner} in `#{cask_variable}`.#{owner_contact}
// 834:         EOS
// 835:         )
// 836:       end
// 837:
// 838:       return if cask_only
// 839:       return if skip_cask_deps?
// 840:
// 841:       cask_and_formula_dependencies.each do |dep_cask_or_formula|
// 842:         dep_name, dep_type, variable = if dep_cask_or_formula.is_a?(Cask) && forbidden_casks.present?
// 843:           dep_cask = dep_cask_or_formula
// 844:           env_variable = "HOMEBREW_FORBIDDEN_CASKS"
// 845:           dep_cask_name = if forbidden_casks.include?(dep_cask.token)
// 846:             dep_cask.token
// 847:           elsif forbidden_casks.include?(dep_cask.full_name)
// 848:             dep_cask.full_name
// 849:           end
// 850:           [dep_cask_name, "cask", env_variable]
// 851:         elsif dep_cask_or_formula.is_a?(Formula) && forbidden_formulae.present?
// 852:           dep_formula = dep_cask_or_formula
// 853:           formula_name = if forbidden_formulae.include?(dep_formula.name)
// 854:             dep_formula.name
// 855:           elsif dep_formula.tap.present? &&
// 856:                 forbidden_formulae.include?(dep_formula.full_name)
// 857:             dep_formula.full_name
// 858:           end
// 859:           [formula_name, "formula", "HOMEBREW_FORBIDDEN_FORMULAE"]
// 860:         end
// 861:         next if dep_name.blank?
// 862:
// 863:         raise CaskCannotBeInstalledError.new(@cask, <<~EOS
// 864:           has a dependency #{dep_name} but the
// 865:           #{dep_name} #{dep_type} was forbidden for installation by #{owner} in `#{variable}`.#{owner_contact}
// 866:         EOS
// 867:         )
// 868:       end
// 869:     end
// 870:
// 871:     sig { void }
// 872:     def forbidden_cask_artifacts_check
// 873:       forbidden_artifacts = Set.new(Homebrew::EnvConfig.forbidden_cask_artifacts.to_s.split)
// 874:       return if forbidden_artifacts.blank?
// 875:
// 876:       owner = Homebrew::EnvConfig.forbidden_owner
// 877:       owner_contact = if (contact = Homebrew::EnvConfig.forbidden_owner_contact.presence)
// 878:         "\n#{contact}"
// 879:       end
// 880:
// 881:       artifacts.each do |artifact|
// 882:         # Get the artifact class name (e.g., "Pkg", "Installer", "App")
// 883:         artifact_name = artifact.class.name
// 884:         next if artifact_name.nil?
// 885:
// 886:         artifact_type = artifact_name.split("::").last&.downcase
// 887:         next if artifact_type.nil?
// 888:
// 889:         next unless forbidden_artifacts.include?(artifact_type)
// 890:
// 891:         raise CaskCannotBeInstalledError.new(@cask, <<~EOS
// 892:           contains a '#{artifact_type}' artifact, which is forbidden for installation by #{owner} in `HOMEBREW_FORBIDDEN_CASK_ARTIFACTS`.#{owner_contact}
// 893:         EOS
// 894:         )
// 895:       end
// 896:     end
// 897:
// 898:     sig { void }
// 899:     def prelude
// 900:       return if @ran_prelude
// 901:
// 902:       check_prelude_requirements unless @ran_prelude_fetch
// 903:       load_cask_from_source_api! if cask_from_source_api?
// 904:       forbidden_tap_check
// 905:       forbidden_cask_and_formula_check
// 906:       forbidden_cask_artifacts_check
// 907:
// 908:       @ran_prelude = true
// 909:     end
// 910:
// 911:     sig { returns(T::Boolean) }
// 912:     def source_download_requires_pre_fetch?
// 913:       cask_from_source_api? && @cask.languages.any?
// 914:     end
// 915:
// 916:     sig { params(download_queue: Homebrew::DownloadQueue).void }
// 917:     def prelude_fetch(download_queue: @download_queue)
// 918:       return unless (download = prelude_fetch_download)
// 919:
// 920:       download_queue.enqueue(download)
// 921:     end
// 922:
// 923:     sig { returns(T.nilable(Homebrew::API::SourceDownload)) }
// 924:     def prelude_fetch_download
// 925:       return if @ran_prelude_fetch
// 926:
// 927:       check_prelude_requirements
// 928:       @ran_prelude_fetch = true
// 929:       return unless source_download_requires_pre_fetch?
// 930:
// 931:       if source_download.downloaded?
// 932:         source_download.verify_download_integrity(source_download.cached_download)
// 933:         source_download.downloader.create_symlink_to_cached_download(source_download.cached_download)
// 934:         return
// 935:       end
// 936:
// 937:       source_download
// 938:     end
// 939:
// 940:     sig { void }
// 941:     def enqueue_downloads
// 942:       download_queue = @download_queue
// 943:       prelude_fetch(download_queue:) unless @ran_prelude_fetch
// 944:
// 945:       if source_download_requires_pre_fetch?
// 946:         load_cask_from_source_api!
// 947:       elsif cask_from_source_api?
// 948:         Homebrew::API::Cask.source_download(@cask, download_queue:, enqueue: true)
// 949:       end
// 950:
// 951:       forbidden_tap_check
// 952:       forbidden_cask_and_formula_check
// 953:       forbidden_cask_artifacts_check
// 954:
// 955:       download_queue.enqueue(downloader)
// 956:     end
// 957:
// 958:     # load the same cask file that was used for installation, if possible
// 959:     sig { void }
// 960:     def load_installed_caskfile!
// 961:       Migrator.migrate_if_needed(@cask)
// 962:
// 963:       installed_caskfile = @cask.installed_caskfile
// 964:       @installed_uninstall_artifacts_missing = installed_caskfile.is_a?(Pathname) &&
// 965:                                                installed_uninstall_artifacts_missing?(installed_caskfile)
// 966:
// 967:       if installed_caskfile&.exist?
// 968:         tab = CaskLoader.load_installed_tab(@cask)
// 969:         tap = tab.tap
// 970:         tap ||= @cask.tap
// 971:         if installed_caskfile.extname == ".rb" &&
// 972:            Homebrew::EnvConfig.require_tap_trust? &&
// 973:            tap &&
// 974:            !Homebrew::Trust.trusted?(:cask, "#{tap.name}/#{@cask.token}")
// 975:           opoo "Skipping loading untrusted Cask #{tap.name}/#{@cask.token}; uninstalling recorded artifacts only."
// 976:
// 977:           dsl = DSL.new(@cask)
// 978:           default_uninstall_artifact_keys = DSL::ACTIVATABLE_ARTIFACT_CLASSES.filter_map do |klass|
// 979:             next if [Artifact::Uninstall, Artifact::Zap].include?(klass)
// 980:             next if !klass.method_defined?(:uninstall_phase) && !klass.method_defined?(:post_uninstall_phase)
// 981:
// 982:             klass.dsl_key
// 983:           end.to_set
// 984:           Array(tab.uninstall_artifacts).each do |artifact_entry|
// 985:             next unless artifact_entry.is_a?(Hash)
// 986:
// 987:             artifact_entry.each do |raw_key, raw_args|
// 988:               dsl_key = raw_key.to_sym
// 989:               next unless default_uninstall_artifact_keys.include?(dsl_key)
// 990:
// 991:               args = Array(raw_args)
// 992:               if args.last.is_a?(Hash)
// 993:                 dsl.public_send(
// 994:                   dsl_key,
// 995:                   *args[...-1],
// 996:                   **T.cast(args.last, T::Hash[T.any(Symbol, String), T.anything]).transform_keys(&:to_sym),
// 997:                 )
// 998:               else
// 999:                 dsl.public_send(dsl_key, *args)
// 1000:               end
// 1001:             end
// 1002:           end
// 1003:           @default_uninstall_artifacts ||= dsl.artifacts
// 1004:           return
// 1005:         end
// 1006:
// 1007:         begin
// 1008:           @cask = CaskLoader.load_from_installed_caskfile(installed_caskfile)
// 1009:           return
// 1010:         rescue CaskInvalidError, CaskUnavailableError, MethodDeprecatedError
// 1011:           # could be caused by trying to load outdated or deleted caskfile
// 1012:         end
// 1013:
// 1014:         recovered_cask = CaskLoader.recover_from_installed_caskfile(installed_caskfile, tab:, fallback_cask: @cask)
// 1015:         if recovered_cask
// 1016:           @cask = recovered_cask
// 1017:           return
// 1018:         end
// 1019:       end
// 1020:
// 1021:       load_cask_from_source_api! if cask_from_source_api?
// 1022:       # otherwise we default to the current cask
// 1023:     end
// 1024:
// 1025:     private
// 1026:
// 1027:     # Remove Caskroom symlinks (e.g. from cask renames) that removing this cask's
// 1028:     # directory has broken, whatever the symlink is named.
// 1029:     sig { void }
// 1030:     def remove_broken_caskroom_symlinks
// 1031:       return unless Caskroom.path.directory?
// 1032:
// 1033:       Caskroom.path.children.each do |link|
// 1034:         next if !link.symlink? || link.exist?
// 1035:         next if link.readlink.basename != @cask.caskroom_path.basename
// 1036:
// 1037:         FileUtils.rm link
// 1038:       end
// 1039:     end
// 1040:
// 1041:     sig { params(installed_caskfile: Pathname).returns(T::Boolean) }
// 1042:     def installed_uninstall_artifacts_missing?(installed_caskfile)
// 1043:       return false unless CaskLoader.installed_json_caskfile?(installed_caskfile)
// 1044:
// 1045:       installed_json = CaskLoader.load_installed_json(installed_caskfile)
// 1046:       return false if installed_json.nil? || installed_json.key?("artifacts")
// 1047:
// 1048:       CaskLoader.load_installed_tab(@cask).uninstall_artifacts.blank?
// 1049:     end
// 1050:
// 1051:     sig { void }
// 1052:     def check_prelude_requirements
// 1053:       check_deprecate_disable
// 1054:       check_conflicts
// 1055:       check_requirements
// 1056:       # Run the cask-self forbidden checks before loading the caskfile from the
// 1057:       # Source API so a forbidden cask never triggers a network fetch.
// 1058:       forbidden_tap_check(cask_only: true)
// 1059:       forbidden_cask_and_formula_check(cask_only: true)
// 1060:     end
// 1061:
// 1062:     sig { returns(Homebrew::API::SourceDownload) }
// 1063:     def source_download
// 1064:       @source_download ||= Homebrew::API::Cask.source_download_for(@cask)
// 1065:     end
// 1066:
// 1067:     sig { void }
// 1068:     def load_cask_from_source_api!
// 1069:       @cask = Homebrew::API::Cask.source_download_cask(@cask)
// 1070:     end
// 1071:
// 1072:     sig { returns(T::Boolean) }
// 1073:     def cask_from_source_api?
// 1074:       @cask.loaded_from_api? && @cask.caskfile_only?
// 1075:     end
// 1076:   end
// 1077: end
// 1078:
// 1079: require "extend/os/cask/installer"
