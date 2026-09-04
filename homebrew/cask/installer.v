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

pub type CaskInstallerFetchHook = fn (CaskInstallerDownloadRequest) !string

pub type CaskInstallerExtractHook = fn (string, string, bool) !

pub type CaskInstallerArtifactHook = fn (CaskInstallerArtifactRequest) !

pub type CaskInstallerDependencyHook = fn (CaskInstallerDependency) !

pub type CaskInstallerQueueHook = fn (CaskInstallerQueueEntry) !

pub type CaskInstallerSourceLoader = fn (CaskCore) !CaskCore

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
