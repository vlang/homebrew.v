module cask

import brew_runtime
import crypto.sha256
import os

// Translated from Homebrew/brew `cask/download.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :cask` at line 20.
pub fn ruby_download_l20_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_download_cask_value(cask_download_from_args(args).cask)
}

// Ruby method `initialize(cask, require_sha: false)` at line 28.
pub fn ruby_download_l28_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return cask_download_error('ArgumentError', 'cask is required')
	}
	download := CaskDownload{ cask: cask_download_cask_from_value(args[0]), require_sha: args.len > 1 && args[1].bool_data }
	return cask_download_value(download)
}

// Ruby method `url` at line 36.
pub fn ruby_download_l36_d3_url(args ...brew_runtime.Value) brew_runtime.Value {
	download := cask_download_from_args(args)
	return if download.cask.url_present {
		brew_runtime.string_value(download.cask.url)
	} else {
		cask_download_nil()
	}
}

// Ruby method `checksum` at line 43.
pub fn ruby_download_l43_d4_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	download := cask_download_from_args(args)
	return if download.cask.checksum_kind == .checksum {
		brew_runtime.string_value(download.cask.sha256)
	} else {
		cask_download_nil()
	}
}

// Ruby method `version` at line 48.
pub fn ruby_download_l48_d5_version(args ...brew_runtime.Value) brew_runtime.Value {
	download := cask_download_from_args(args)
	return if download.cask.version_present {
		brew_runtime.object_value('Version', download.cask.version)
	} else {
		cask_download_nil()
	}
}

// Ruby method `fetch(quiet: nil, verify_download_integrity: true, timeout: nil)` at line 61.
pub fn ruby_download_l61_d6_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	mut download := cask_download_from_args(args)
	path := cask_download_fetch(mut download, CaskDownloadFetchOptions{ quiet: args.len > 1 && args[1].bool_data, verify_integrity: args.len < 3 || args[2].bool_data }) or { return cask_download_error('CaskError', err.msg()) }
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `time_file_size(timeout: nil)` at line 81.
pub fn ruby_download_l81_d7_time_file_size(args ...brew_runtime.Value) brew_runtime.Value {
	download := cask_download_from_args(args)
	result := cask_download_time_file_size(download) or { return cask_download_error('ArgumentError', err.msg()) }
	return brew_runtime.array_value([
		if result.time_present { brew_runtime.int_value(result.unix_time) } else { cask_download_nil() },
		brew_runtime.int_value(result.size),
	])
}

// Ruby method `basename` at line 88.
pub fn ruby_download_l88_d8_basename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', cask_download_basename(cask_download_from_args(args)))
}

// Ruby method `primary_container` at line 93.
pub fn ruby_download_l93_d9_primary_container(args ...brew_runtime.Value) brew_runtime.Value {
	download := cask_download_from_args(args)
	return cask_download_container_value(cask_download_primary_container(download) or { return cask_download_error('RuntimeError', err.msg()) })
}

// Ruby method `extract_primary_container(to:, verbose:, container: nil)` at line 104.
pub fn ruby_download_l104_d10_extract_primary_container(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return cask_download_error('ArgumentError', 'extract_primary_container requires receiver and destination')
	}
	mut download := cask_download_from_args(args)
	cask_download_extract_primary_container(mut download, args[1].as_string(), args.len > 2 && args[2].bool_data) or { return cask_download_error('RuntimeError', err.msg()) }
	return cask_download_nil()
}

// Ruby method `process_rename_operations(target_dir:)` at line 132.
pub fn ruby_download_l132_d11_process_rename_operations(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return cask_download_error('ArgumentError', 'target directory is required')
	}
	cask_download_process_renames(cask_download_from_args(args), args[1].as_string()) or { return cask_download_error('SystemCallError', err.msg()) }
	return cask_download_nil()
}

// Ruby method `staged_path_from_download_queue` at line 144.
pub fn ruby_download_l144_d12_staged_path_from_download_queue(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', cask_download_staged_path(cask_download_from_args(args)))
}

// Ruby method `staged_path_from_download_queue_marker` at line 149.
pub fn ruby_download_l149_d13_staged_path_from_download_queue_marker(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', '${cask_download_staged_path(cask_download_from_args(args))}.staged')
}

// Ruby method `purge_staged_from_download_queue(command: SystemCommand)` at line 154.
pub fn ruby_download_l154_d14_purge_staged_from_download_queue(args ...brew_runtime.Value) brew_runtime.Value {
	cask_download_purge(cask_download_from_args(args)) or { return cask_download_error('SystemCallError', err.msg()) }
	return cask_download_nil()
}

// Ruby method `stage_from_download_queue?(download, pour:)` at line 166.
pub fn ruby_download_l166_d15_stage_from_download_queue(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(cask_download_should_stage(cask_download_from_args(args), args[1].as_string(), args.len > 2 && args[2].bool_data))
}

// Ruby method `stage_from_download_queue(download, pour:)` at line 182.
pub fn ruby_download_l182_d16_stage_from_download_queue(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return cask_download_error('ArgumentError', 'download path is required')
	}
	mut download := cask_download_from_args(args)
	cask_download_stage(mut download, args[1].as_string(), args.len > 2 && args[2].bool_data) or { return cask_download_error('RuntimeError', err.msg()) }
	return cask_download_value(download)
}

// Ruby method `downloaded_and_valid?` at line 207.
pub fn ruby_download_l207_d17_downloaded_and_valid(args ...brew_runtime.Value) brew_runtime.Value {
	mut download := cask_download_from_args(args)
	return brew_runtime.bool_value(cask_downloaded_and_valid(mut download))
}

// Ruby method `verify_download_integrity(filename)` at line 215.
pub fn ruby_download_l215_d18_verify_download_integrity(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return cask_download_error('ArgumentError', 'filename is required')
	}
	mut download := cask_download_from_args(args)
	result := cask_download_verify(mut download, args[1].as_string())
	return brew_runtime.map_value({
		'warning': brew_runtime.string_value(result.warning)
		'error':   brew_runtime.string_value(result.error)
	})
}

// Ruby method `download_queue_name = "#{cask.token} (#{version})"` at line 225.
pub fn ruby_download_l225_d19_download_queue_name(args ...brew_runtime.Value) brew_runtime.Value {
	download := cask_download_from_args(args)
	return brew_runtime.string_value('${download.cask.token} (${if download.cask.version_present {
		download.cask.version
	} else {
		''
	}})')
}

// Ruby method `download_queue_type = "Cask"` at line 228.
pub fn ruby_download_l228_d20_download_queue_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('Cask')
}

// Ruby method `download_name = cask.token` at line 231.
pub fn ruby_download_l231_d21_download_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(cask_download_from_args(args).cask.token)
}

// Ruby method `verify_has_sha` at line 236.
pub fn ruby_download_l236_d22_verify_has_sha(args ...brew_runtime.Value) brew_runtime.Value {
	download := cask_download_from_args(args)
	return brew_runtime.string_value(cask_download_verify_has_sha(download) or { return cask_download_error('CaskError', err.msg()) })
}

// Ruby method `quarantine(path)` at line 253.
pub fn ruby_download_l253_d23_quarantine(args ...brew_runtime.Value) brew_runtime.Value {
	mut download := cask_download_from_args(args)
	if args.len > 1 { cask_download_quarantine(mut download, args[1].as_string()) }
	return cask_download_value(download)
}

// Ruby method `official_cask_tap?` at line 260.
pub fn ruby_download_l260_d24_official_cask_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cask_download_from_args(args).cask.tap_present && cask_download_from_args(args).cask.tap_official)
}

// Ruby method `no_checksum_defined?` at line 268.
pub fn ruby_download_l268_d25_no_checksum_defined(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cask_download_from_args(args).cask.checksum_kind == .no_check)
}

// Ruby method `silence_checksum_missing_error?` at line 273.
pub fn ruby_download_l273_d26_silence_checksum_missing_error(args ...brew_runtime.Value) brew_runtime.Value {
	download := cask_download_from_args(args)
	return brew_runtime.bool_value(download.cask.checksum_kind == .no_check && download.cask.tap_present && download.cask.tap_official)
}

// Ruby method `determine_url` at line 278.
pub fn ruby_download_l278_d27_determine_url(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_download_l36_d3_url(...args)
}

// Ruby method `cache` at line 283.
pub fn ruby_download_l283_d28_cache(args ...brew_runtime.Value) brew_runtime.Value {
	download := cask_download_from_args(args)
	return brew_runtime.object_value('Pathname', download.cache_dir)
}

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
	url_specs              map[string]brew_runtime.Value
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

fn cask_download_from_args(args []brew_runtime.Value) CaskDownload {
	return cask_download_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
}

fn cask_download_from_value(value brew_runtime.Value) CaskDownload {
	values := value.map_data.clone()
	return CaskDownload{
		cask: cask_download_cask_from_value(values['cask'] or { value })
		require_sha: (values['require_sha'] or { brew_runtime.bool_value(false) }).bool_data
		downloader_path: (values['downloader_path'] or { brew_runtime.string_value('') }).as_string()
		downloader_basename: (values['downloader_basename'] or { brew_runtime.string_value('') }).as_string()
		downloader_is_curl: (values['downloader_is_curl'] or { brew_runtime.bool_value(true) }).bool_data
		resolved_time: (values['resolved_time'] or { brew_runtime.int_value(0) }).int_data
		resolved_time_present: (values['resolved_time_present'] or { brew_runtime.bool_value(false) }).bool_data
		resolved_size: (values['resolved_size'] or { brew_runtime.int_value(0) }).int_data
		cache_dir: (values['cache_dir'] or { brew_runtime.string_value('') }).as_string()
		quarantine_available: (values['quarantine_available'] or { brew_runtime.bool_value(false) }).bool_data
	}
}

fn cask_download_cask_from_value(value brew_runtime.Value) CaskDownloadCask {
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
		token: (values['token'] or { brew_runtime.string_value('') }).as_string()
		full_token: (values['full_token'] or { values['token'] or { brew_runtime.string_value('') } }).as_string()
		version: (values['version'] or { brew_runtime.string_value('') }).as_string()
		version_present: (values['version'] or { cask_download_nil() }).type_name != 'NilClass'
		url: (values['url'] or { brew_runtime.string_value('') }).as_string()
		url_present: (values['url'] or { cask_download_nil() }).type_name != 'NilClass'
		sha256: checksum_value.as_string()
		checksum_kind: checksum_kind
		tap_present: (values['tap_present'] or { brew_runtime.bool_value(false) }).bool_data
		tap_official: (values['tap_official'] or { brew_runtime.bool_value(false) }).bool_data
		on_system_blocks_exist: (values['on_system_blocks_exist'] or { brew_runtime.bool_value(false) }).bool_data
		loaded_from_api: (values['loaded_from_api'] or { brew_runtime.bool_value(false) }).bool_data
		staged_path: (values['staged_path'] or { brew_runtime.string_value('') }).as_string()
		caskroom_path: (values['caskroom_path'] or { brew_runtime.string_value('') }).as_string()
		download: (values['download'] or { brew_runtime.string_value('') }).as_string()
	}
}

fn cask_download_value(download CaskDownload) brew_runtime.Value {
	return brew_runtime.map_value({
		'cask':            cask_download_cask_value(download.cask)
		'require_sha':     brew_runtime.bool_value(download.require_sha)
		'downloader_path': brew_runtime.string_value(download.downloader_path)
		'cache_dir':       brew_runtime.string_value(download.cache_dir)
	})
}

fn cask_download_cask_value(cask CaskDownloadCask) brew_runtime.Value {
	return brew_runtime.map_value({
		'token':      brew_runtime.string_value(cask.token)
		'full_token': brew_runtime.string_value(cask.full_token)
		'version':    if cask.version_present {
			brew_runtime.string_value(cask.version)
		} else {
			cask_download_nil()
		}
		'url':        if cask.url_present {
			brew_runtime.string_value(cask.url)
		} else {
			cask_download_nil()
		}
		'sha256':     match cask.checksum_kind {
			.missing { cask_download_nil() }
			.no_check { brew_runtime.object_value('Symbol', ':no_check') }
			.checksum { brew_runtime.string_value(cask.sha256) }
		}
	})
}

fn cask_download_container_value(container CaskDownloadContainer) brew_runtime.Value {
	return brew_runtime.map_value({
		'path':   brew_runtime.string_value(container.path)
		'type':   brew_runtime.string_value(container.kind)
		'nested': brew_runtime.string_value(container.nested)
	})
}

fn cask_download_error(kind string, message string) brew_runtime.Value {
	return brew_runtime.object_value(kind, message)
}

fn cask_download_nil() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "downloadable"
// 5: require "fileutils"
// 6: require "unpack_strategy"
// 7: require "cask/cache"
// 8: require "cask/caskroom"
// 9: require "cask/quarantine"
// 10: require "cask/utils"
// 11:
// 12: module Cask
// 13:   # A download corresponding to a {Cask}.
// 14:   class Download
// 15:     include Downloadable
// 16:
// 17:     include Context
// 18:
// 19:     sig { returns(::Cask::Cask) }
// 20:     attr_reader :cask
// 21:
// 22:     sig {
// 23:       params(
// 24:         cask:        ::Cask::Cask,
// 25:         require_sha: T::Boolean,
// 26:       ).void
// 27:     }
// 28:     def initialize(cask, require_sha: false)
// 29:       super()
// 30:
// 31:       @cask = cask
// 32:       @require_sha = require_sha
// 33:     end
// 34:
// 35:     sig { override.returns(T.nilable(::URL)) }
// 36:     def url
// 37:       return if (cask_url = cask.url).nil?
// 38:
// 39:       @url ||= ::URL.new(cask_url.to_s, cask_url.specs)
// 40:     end
// 41:
// 42:     sig { override.returns(T.nilable(::Checksum)) }
// 43:     def checksum
// 44:       @checksum ||= cask.sha256 if cask.sha256 != :no_check
// 45:     end
// 46:
// 47:     sig { override.returns(T.nilable(Version)) }
// 48:     def version
// 49:       return if cask.version.nil?
// 50:
// 51:       @version ||= Version.new(cask.version)
// 52:     end
// 53:
// 54:     sig {
// 55:       override
// 56:         .params(quiet:                     T.nilable(T::Boolean),
// 57:                 verify_download_integrity: T::Boolean,
// 58:                 timeout:                   T.nilable(T.any(Integer, Float)))
// 59:         .returns(Pathname)
// 60:     }
// 61:     def fetch(quiet: nil, verify_download_integrity: true, timeout: nil)
// 62:       verify_has_sha if @require_sha ||
// 63:                         (@cask.sha256.nil? && (@cask.on_system_blocks_exist? || @cask.loaded_from_api?))
// 64:       downloader.quiet! if quiet
// 65:
// 66:       begin
// 67:         super(verify_download_integrity: false, timeout:)
// 68:       rescue DownloadError => e
// 69:         error = CaskError.new("Download failed on Cask '#{cask}' with message: #{e.cause}")
// 70:         error.set_backtrace e.backtrace
// 71:         raise error
// 72:       end
// 73:
// 74:       downloaded_path = cached_download
// 75:       quarantine(downloaded_path)
// 76:       self.verify_download_integrity(downloaded_path) if verify_download_integrity
// 77:       downloaded_path
// 78:     end
// 79:
// 80:     sig { params(timeout: T.nilable(T.any(Float, Integer))).returns([T.nilable(Time), Integer]) }
// 81:     def time_file_size(timeout: nil)
// 82:       raise ArgumentError, "not supported for this download strategy" unless downloader.is_a?(CurlDownloadStrategy)
// 83:
// 84:       T.cast(downloader, CurlDownloadStrategy).resolved_time_file_size(timeout:)
// 85:     end
// 86:
// 87:     sig { returns(Pathname) }
// 88:     def basename
// 89:       downloader.basename
// 90:     end
// 91:
// 92:     sig { returns(UnpackStrategy) }
// 93:     def primary_container
// 94:       @primary_container ||= T.let(
// 95:         begin
// 96:           downloaded_path = cask.download || fetch(quiet: true)
// 97:           UnpackStrategy.detect(downloaded_path, type: cask.container&.type, merge_xattrs: true)
// 98:         end,
// 99:         T.nilable(UnpackStrategy),
// 100:       )
// 101:     end
// 102:
// 103:     sig { params(to: Pathname, verbose: T::Boolean, container: T.nilable(UnpackStrategy)).void }
// 104:     def extract_primary_container(to:, verbose:, container: nil)
// 105:       odebug "Extracting primary container"
// 106:
// 107:       container ||= primary_container
// 108:       raise "unexpected nil primary_container" unless container
// 109:
// 110:       odebug "Using container class #{container.class} for #{container.path}"
// 111:
// 112:       if (nested_container = cask.container&.nested)
// 113:         Dir.mktmpdir("cask-installer", HOMEBREW_TEMP) do |tmpdir|
// 114:           tmpdir = Pathname(tmpdir)
// 115:           container.extract(to: tmpdir, basename:, verbose:)
// 116:
// 117:           FileUtils.chmod_R "+rw", tmpdir/nested_container, force: true, verbose: verbose
// 118:
// 119:           UnpackStrategy.detect(tmpdir/nested_container, merge_xattrs: true)
// 120:                         .extract_nestedly(to:, verbose:)
// 121:         end
// 122:       else
// 123:         container.extract_nestedly(to:, basename:, verbose:)
// 124:       end
// 125:
// 126:       return unless Quarantine.available?
// 127:
// 128:       Quarantine.propagate(from: container.path, to:)
// 129:     end
// 130:
// 131:     sig { params(target_dir: Pathname).void }
// 132:     def process_rename_operations(target_dir:)
// 133:       return if cask.rename.empty?
// 134:
// 135:       odebug "Processing rename operations in #{target_dir}"
// 136:
// 137:       cask.rename.each do |rename_operation|
// 138:         odebug "Renaming #{rename_operation.from} to #{rename_operation.to}"
// 139:         rename_operation.perform_rename(target_dir)
// 140:       end
// 141:     end
// 142:
// 143:     sig { returns(Pathname) }
// 144:     def staged_path_from_download_queue
// 145:       HOMEBREW_PREFIX/"var/homebrew/tmp/.caskroom"/cask.staged_path.relative_path_from(Caskroom.path)
// 146:     end
// 147:
// 148:     sig { returns(Pathname) }
// 149:     def staged_path_from_download_queue_marker
// 150:       Pathname("#{staged_path_from_download_queue}.staged")
// 151:     end
// 152:
// 153:     sig { params(command: T.class_of(SystemCommand)).void }
// 154:     def purge_staged_from_download_queue(command: SystemCommand)
// 155:       staged_marker = staged_path_from_download_queue_marker
// 156:       Utils.gain_permissions_remove(staged_marker, command:) if staged_marker.symlink? || staged_marker.exist?
// 157:
// 158:       staged_path = staged_path_from_download_queue
// 159:       Utils.gain_permissions_remove(staged_path, command:) if staged_path.exist?
// 160:
// 161:       staged_path.parent.rmdir_if_possible
// 162:       staged_path.parent.parent.rmdir_if_possible
// 163:     end
// 164:
// 165:     sig { override.params(download: Pathname, pour: T::Boolean).returns(T::Boolean) }
// 166:     def stage_from_download_queue?(download, pour:)
// 167:       return false unless pour
// 168:       return false if cask.staged_path.exist? || staged_path_from_download_queue_marker.exist?
// 169:
// 170:       UnpackStrategy.detect(download, type:         cask.container&.type,
// 171:                                       merge_xattrs: true).dependencies.all? do |dependency|
// 172:         case dependency
// 173:         when Formula
// 174:           dependency.any_version_installed? && dependency.optlinked?
// 175:         when Cask
// 176:           dependency.installed?
// 177:         end
// 178:       end
// 179:     end
// 180:
// 181:     sig { override.params(download: Pathname, pour: T::Boolean).void }
// 182:     def stage_from_download_queue(download, pour:)
// 183:       return unless stage_from_download_queue?(download, pour:)
// 184:
// 185:       purge_staged_from_download_queue
// 186:       cask.download ||= download
// 187:       extract_primary_container(
// 188:         to:        staged_path_from_download_queue,
// 189:         verbose:   false,
// 190:         container: UnpackStrategy.detect(
// 191:           download,
// 192:           type:         cask.container&.type,
// 193:           merge_xattrs: true,
// 194:         ),
// 195:       )
// 196:       process_rename_operations(target_dir: staged_path_from_download_queue)
// 197:       FileUtils.ln_s(staged_path_from_download_queue, staged_path_from_download_queue_marker)
// 198:     # Catch any exception type here to clean up partial queued extractions.
// 199:     rescue Exception # rubocop:disable Lint/RescueException
// 200:       ignore_interrupts do
// 201:         purge_staged_from_download_queue
// 202:       end
// 203:       raise
// 204:     end
// 205:
// 206:     sig { override.returns(T::Boolean) }
// 207:     def downloaded_and_valid?
// 208:       return false unless super
// 209:
// 210:       quarantine(cached_download)
// 211:       true
// 212:     end
// 213:
// 214:     sig { override.params(filename: Pathname).void }
// 215:     def verify_download_integrity(filename)
// 216:       if no_checksum_defined? && !official_cask_tap?
// 217:         opoo "No checksum defined for cask '#{@cask}', skipping verification."
// 218:         return
// 219:       end
// 220:
// 221:       super
// 222:     end
// 223:
// 224:     sig { override.returns(String) }
// 225:     def download_queue_name = "#{cask.token} (#{version})"
// 226:
// 227:     sig { override.returns(String) }
// 228:     def download_queue_type = "Cask"
// 229:
// 230:     sig { override.returns(String) }
// 231:     def download_name = cask.token
// 232:
// 233:     private
// 234:
// 235:     sig { void }
// 236:     def verify_has_sha
// 237:       return if @cask.sha256.is_a?(Checksum)
// 238:
// 239:       unless @require_sha
// 240:         raise CaskError, <<~EOS
// 241:           Cask '#{@cask}' does not have a sha256 checksum defined for this platform.
// 242:           Add an appropriate `depends_on` stanza if the cask does not support this platform.
// 243:         EOS
// 244:       end
// 245:
// 246:       raise CaskError, <<~EOS
// 247:         Cask '#{@cask}' does not have a sha256 checksum defined.
// 248:         This means you have the #{Formatter.identifier("--require-sha")} option set, perhaps in your `$HOMEBREW_CASK_OPTS`.
// 249:       EOS
// 250:     end
// 251:
// 252:     sig { params(path: Pathname).void }
// 253:     def quarantine(path)
// 254:       return unless Quarantine.available?
// 255:
// 256:       Quarantine.cask!(cask: @cask, download_path: path)
// 257:     end
// 258:
// 259:     sig { returns(T::Boolean) }
// 260:     def official_cask_tap?
// 261:       tap = @cask.tap
// 262:       return false if tap.blank?
// 263:
// 264:       tap.official?
// 265:     end
// 266:
// 267:     sig { returns(T::Boolean) }
// 268:     def no_checksum_defined?
// 269:       @cask.sha256 == :no_check
// 270:     end
// 271:
// 272:     sig { override.returns(T::Boolean) }
// 273:     def silence_checksum_missing_error?
// 274:       no_checksum_defined? && official_cask_tap?
// 275:     end
// 276:
// 277:     sig { override.returns(T.nilable(::URL)) }
// 278:     def determine_url
// 279:       url
// 280:     end
// 281:
// 282:     sig { override.returns(Pathname) }
// 283:     def cache
// 284:       Cache.path
// 285:     end
// 286:   end
// 287: end
