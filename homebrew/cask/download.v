module cask

import ruby
import crypto.sha256
import os

// Translated from Homebrew/brew `cask/download.rb`.

pub enum CaskChecksumKind {
	missing
	no_check
	checksum
}

pub enum CaskDownloadDependencyKind {
	formula
	cask
}

pub struct CaskDownloadDependency {
pub:
	kind      CaskDownloadDependencyKind
	installed bool
	optlinked bool
}

pub struct CaskDownloadRename {
pub:
	from string
	to   string
}

pub struct CaskDownloadContainer {
pub:
	path         string
	kind         string
	nested       string
	dependencies []CaskDownloadDependency
}

pub struct CaskDownloadCask {
pub:
	token                  string
	full_token             string
	version                string
	version_present        bool
	url                    string
	url_present            bool
	url_specs              map[string]ruby.Value
	sha256                 string
	checksum_kind          CaskChecksumKind
	tap_present            bool
	tap_official           bool
	on_system_blocks_exist bool
	loaded_from_api        bool
	staged_path            string
	caskroom_path          string
	download               string
	container              CaskDownloadContainer
	renames                []CaskDownloadRename
}

pub struct CaskDownload {
pub mut:
	cask                     CaskDownloadCask
	require_sha              bool
	downloader_path          string
	downloader_basename      string
	downloader_is_curl       bool = true
	resolved_time            i64
	resolved_time_present    bool
	resolved_size            i64
	cache_dir                string
	quarantine_available     bool
	computed_sha256_override string
	quarantined_paths        []string
	propagated_to            []string
	warnings                 []string
}

pub struct CaskDownloadFetchOptions {
pub:
	quiet            bool
	verify_integrity bool = true
}

pub struct CaskDownloadTimeSize {
pub:
	time_present bool
	unix_time    i64
	size         i64
}

pub struct CaskDownloadVerification {
pub:
	warning string
	error   string
}

pub fn cask_download_fetch(mut download CaskDownload, options CaskDownloadFetchOptions) !string {
	if download.require_sha || (download.cask.checksum_kind == .missing && (download.cask.on_system_blocks_exist || download.cask.loaded_from_api)) {
		cask_download_verify_has_sha(download)!
	}
	path := if download.downloader_path != '' {
		download.downloader_path
	} else {
		download.cask.download
	}
	if path == '' || !os.exists(path) {
		return error("Download failed on Cask '${download.cask.token}' with message: downloaded file is missing")
	}
	cask_download_quarantine(mut download, path)
	if options.verify_integrity {
		verification := cask_download_verify(mut download, path)
		if verification.error != '' {
			return error(verification.error)
		}
	}
	return path
}

pub fn cask_download_time_file_size(download CaskDownload) !CaskDownloadTimeSize {
	if !download.downloader_is_curl {
		return error('not supported for this download strategy')
	}
	return CaskDownloadTimeSize{ time_present: download.resolved_time_present, unix_time: download.resolved_time, size: download.resolved_size }
}

pub fn cask_download_basename(download CaskDownload) string {
	if download.downloader_basename != '' {
		return download.downloader_basename
	}
	path := if download.downloader_path != '' {
		download.downloader_path
	} else {
		download.cask.url.all_before('?')
	}
	return os.base(path)
}

pub fn cask_download_primary_container(download CaskDownload) !CaskDownloadContainer {
	if download.cask.container.path != '' {
		return download.cask.container
	}
	path := if download.cask.download != '' {
		download.cask.download
	} else {
		download.downloader_path
	}
	if path == '' {
		return error('unexpected nil primary_container')
	}
	return CaskDownloadContainer{ path: path, kind: download.cask.container.kind }
}

pub fn cask_download_extract_primary_container(mut download CaskDownload, destination string, verbose bool) ! {
	container := cask_download_primary_container(download)!
	os.mkdir_all(destination)!
	if container.nested != '' {
		temporary := os.join_path(os.temp_dir(), 'cask-installer-${os.getpid()}')
		os.rmdir_all(temporary) or {}
		os.mkdir_all(temporary)!
		cask_download_copy(container.path, temporary)!
		nested := os.join_path(temporary, container.nested)
		cask_download_copy(nested, destination)!
		os.rmdir_all(temporary) or {}
	} else {
		cask_download_copy(container.path, destination)!
	}
	if download.quarantine_available { download.propagated_to << destination }
}

pub fn cask_download_process_renames(download CaskDownload, target_dir string) ! {
	for operation in download.cask.renames {
		source := os.join_path(target_dir, operation.from)
		target := os.join_path(target_dir, operation.to)
		os.mkdir_all(os.dir(target))!
		os.mv(source, target)!
	}
}

pub fn cask_download_staged_path(download CaskDownload) string {
	relative := if download.cask.caskroom_path != '' && download.cask.staged_path.starts_with(download.cask.caskroom_path) {
		download.cask.staged_path.trim_string_left(download.cask.caskroom_path).trim_left('/')
	} else {
		os.base(download.cask.staged_path)
	}
	return os.join_path(if download.cache_dir != '' { download.cache_dir } else { os.temp_dir() }, 'var/homebrew/tmp/.caskroom', relative)
}

pub fn cask_download_purge(download CaskDownload) ! {
	marker := '${cask_download_staged_path(download)}.staged'
	if os.exists(marker) || os.is_link(marker) { os.rm(marker)! }
	staged := cask_download_staged_path(download)
	if os.exists(staged) {
		if os.is_dir(staged) { os.rmdir_all(staged)! } else { os.rm(staged)! }
	}
	for parent in [os.dir(staged), os.dir(os.dir(staged))] {
		os.rmdir(parent) or {}
	}
}

pub fn cask_download_should_stage(download CaskDownload, source string, pour bool) bool {
	if !pour || os.exists(download.cask.staged_path) || os.exists('${cask_download_staged_path(download)}.staged') || os.is_link('${cask_download_staged_path(download)}.staged') {
		return false
	}
	container := if download.cask.container.dependencies.len > 0 {
		download.cask.container
	} else {
		CaskDownloadContainer{ path: source }
	}
	for dependency in container.dependencies {
		if dependency.kind == .formula && (!dependency.installed || !dependency.optlinked) {
			return false
		}
		if dependency.kind == .cask && !dependency.installed {
			return false
		}
	}
	return true
}

pub fn cask_download_stage(mut download CaskDownload, source string, pour bool) ! {
	if !cask_download_should_stage(download, source, pour) {
		return
	}
	cask_download_purge(download)!
	if download.cask.download == '' {
		download.cask = CaskDownloadCask{ ...download.cask, download: source, container: CaskDownloadContainer{ ...download.cask.container, path: source } }
	}
	destination := cask_download_staged_path(download)
	cask_download_extract_primary_container(mut download, destination, false) or {
		cask_download_purge(download) or {}
		return err
	}
	cask_download_process_renames(download, destination) or {
		cask_download_purge(download) or {}
		return err
	}
	os.symlink(destination, '${destination}.staged') or {
		cask_download_purge(download) or {}
		return err
	}
}

pub fn cask_downloaded_and_valid(mut download CaskDownload) bool {
	path := if download.downloader_path != '' {
		download.downloader_path
	} else {
		download.cask.download
	}
	if path == '' || !os.exists(path) {
		return false
	}
	verification := cask_download_verify(mut download, path)
	if verification.error != '' {
		return false
	}
	cask_download_quarantine(mut download, path)
	return true
}

pub fn cask_download_verify(mut download CaskDownload, filename string) CaskDownloadVerification {
	if download.cask.checksum_kind == .no_check {
		if download.cask.tap_present && download.cask.tap_official {
			return CaskDownloadVerification{}
		}
		warning := "No checksum defined for cask '${download.cask.token}', skipping verification."
		download.warnings << warning
		return CaskDownloadVerification{ warning: warning }
	}
	actual := if download.computed_sha256_override != '' {
		download.computed_sha256_override
	} else {
		sha256.sum256(os.read_bytes(filename) or { return CaskDownloadVerification{ error: err.msg() } }).hex()
	}
	if download.cask.checksum_kind == .missing || download.cask.sha256 == '' {
		return CaskDownloadVerification{ error: 'sha256 "${actual}"' }
	}
	if actual.to_lower() != download.cask.sha256.to_lower() {
		return CaskDownloadVerification{ error: 'ChecksumMismatchError: expected ${download.cask.sha256.to_lower()}, actual ${actual.to_lower()}' }
	}
	return CaskDownloadVerification{}
}

pub fn cask_download_verify_has_sha(download CaskDownload) !string {
	if download.cask.checksum_kind == .checksum {
		return download.cask.sha256
	}
	if !download.require_sha {
		return error("Cask '${download.cask.token}' does not have a sha256 checksum defined for this platform.\nAdd an appropriate `depends_on` stanza if the cask does not support this platform.")
	}
	return error("Cask '${download.cask.token}' does not have a sha256 checksum defined.\nThis means you have the --require-sha option set, perhaps in your \$HOMEBREW_CASK_OPTS.")
}

pub fn cask_download_quarantine(mut download CaskDownload, path string) {
	if download.quarantine_available { download.quarantined_paths << path }
}

fn cask_download_copy(source string, destination string) ! {
	if os.is_dir(source) {
		os.cp_all(source, destination, true)!
	} else {
		os.cp(source, os.join_path(destination, os.base(source)))!
	}
}

fn cask_download_from_args(args []ruby.Value) CaskDownload {
	return cask_download_from_value(args[0] or { ruby.map_value(map[string]ruby.Value{}) })
}

fn cask_download_from_value(value ruby.Value) CaskDownload {
	values := value.map_data.clone()
	return CaskDownload{
		cask: cask_download_cask_from_value(values['cask'] or { value })
		require_sha: (values['require_sha'] or { ruby.bool_value(false) }).bool_data
		downloader_path: (values['downloader_path'] or { ruby.string_value('') }).as_string()
		downloader_basename: (values['downloader_basename'] or { ruby.string_value('') }).as_string()
		downloader_is_curl: (values['downloader_is_curl'] or { ruby.bool_value(true) }).bool_data
		resolved_time: (values['resolved_time'] or { ruby.int_value(0) }).int_data
		resolved_time_present: (values['resolved_time_present'] or { ruby.bool_value(false) }).bool_data
		resolved_size: (values['resolved_size'] or { ruby.int_value(0) }).int_data
		cache_dir: (values['cache_dir'] or { ruby.string_value('') }).as_string()
		quarantine_available: (values['quarantine_available'] or { ruby.bool_value(false) }).bool_data
	}
}

fn cask_download_cask_from_value(value ruby.Value) CaskDownloadCask {
	values := value.map_data.clone()
	checksum_value := values['sha256'] or { cask_download_nil() }
	checksum_kind := if checksum_value.type_name == 'NilClass' {
		CaskChecksumKind.missing
	} else if checksum_value.as_string() in ['no_check', ':no_check'] {
		CaskChecksumKind.no_check
	} else {
		CaskChecksumKind.checksum
	}
	return CaskDownloadCask{
		token: (values['token'] or { ruby.string_value('') }).as_string()
		full_token: (values['full_token'] or { values['token'] or { ruby.string_value('') } }).as_string()
		version: (values['version'] or { ruby.string_value('') }).as_string()
		version_present: (values['version'] or { cask_download_nil() }).type_name != 'NilClass'
		url: (values['url'] or { ruby.string_value('') }).as_string()
		url_present: (values['url'] or { cask_download_nil() }).type_name != 'NilClass'
		sha256: checksum_value.as_string()
		checksum_kind: checksum_kind
		tap_present: (values['tap_present'] or { ruby.bool_value(false) }).bool_data
		tap_official: (values['tap_official'] or { ruby.bool_value(false) }).bool_data
		on_system_blocks_exist: (values['on_system_blocks_exist'] or { ruby.bool_value(false) }).bool_data
		loaded_from_api: (values['loaded_from_api'] or { ruby.bool_value(false) }).bool_data
		staged_path: (values['staged_path'] or { ruby.string_value('') }).as_string()
		caskroom_path: (values['caskroom_path'] or { ruby.string_value('') }).as_string()
		download: (values['download'] or { ruby.string_value('') }).as_string()
	}
}

fn cask_download_value(download CaskDownload) ruby.Value {
	return ruby.map_value({
		'cask':            cask_download_cask_value(download.cask)
		'require_sha':     ruby.bool_value(download.require_sha)
		'downloader_path': ruby.string_value(download.downloader_path)
		'cache_dir':       ruby.string_value(download.cache_dir)
	})
}

fn cask_download_cask_value(cask CaskDownloadCask) ruby.Value {
	return ruby.map_value({
		'token':      ruby.string_value(cask.token)
		'full_token': ruby.string_value(cask.full_token)
		'version':    if cask.version_present {
			ruby.string_value(cask.version)
		} else {
			cask_download_nil()
		}
		'url':        if cask.url_present {
			ruby.string_value(cask.url)
		} else {
			cask_download_nil()
		}
		'sha256':     match cask.checksum_kind {
			.missing { cask_download_nil() }
			.no_check { ruby.object_value('Symbol', ':no_check') }
			.checksum { ruby.string_value(cask.sha256) }
		}
	})
}

fn cask_download_container_value(container CaskDownloadContainer) ruby.Value {
	return ruby.map_value({
		'path':   ruby.string_value(container.path)
		'type':   ruby.string_value(container.kind)
		'nested': ruby.string_value(container.nested)
	})
}

fn cask_download_error(kind string, message string) ruby.Value {
	return ruby.object_value(kind, message)
}

fn cask_download_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}
