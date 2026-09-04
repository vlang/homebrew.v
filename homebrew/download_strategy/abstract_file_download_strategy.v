module download_strategy

import crypto.sha256
import net.urllib
import os

// Translated from Homebrew/brew `download_strategy/abstract_file_download_strategy.rb`.

// AbstractFileDownloadStrategy translates the single-file cache state layered
// over AbstractDownloadStrategy.
pub struct AbstractFileDownloadStrategy {
pub mut:
	base                      AbstractDownloadStrategy
	cached_location_value     string
	resolved_url_value        string
	resolved_basename_value   string
	has_resolved_url_basename bool
}

pub fn new_abstract_file_download_strategy(url string, name string, version string, meta DownloadMeta) AbstractFileDownloadStrategy {
	return AbstractFileDownloadStrategy{
		base: new_abstract_download_strategy(url, name, version, meta)
	}
}

// temporary_path stores a download only while it is incomplete.
pub fn (mut strategy AbstractFileDownloadStrategy) temporary_path() string {
	return '${strategy.cached_location()}.incomplete'
}

// symlink_location includes the resource name, version and URL extension.
pub fn (strategy &AbstractFileDownloadStrategy) symlink_location() string {
	extension := path_extension(parse_basename(strategy.base.url, true))
	return os.join_path(strategy.base.cache, safe_filename('${strategy.base.name}--${strategy.base.version}${extension}'))
}

// cached_location returns an already cached matching digest when exactly one
// exists, or computes the source cache filename from the resolved basename.
pub fn (mut strategy AbstractFileDownloadStrategy) cached_location() string {
	if strategy.cached_location_value != '' {
		return strategy.cached_location_value
	}
	_, basename := strategy.resolved_url_and_basename()
	return strategy.cached_location_with_basename(basename)
}

pub fn (mut strategy AbstractFileDownloadStrategy) cached_location_with_basename(resolved_basename string) string {
	if strategy.cached_location_value != '' {
		return strategy.cached_location_value
	}
	digest := sha256.sum256(strategy.base.url.bytes()).hex()
	downloads_directory := os.join_path(strategy.base.cache, 'downloads')
	mut matches := []string{}
	if os.is_dir(downloads_directory) {
		for entry in os.ls(downloads_directory) or { [] } {
			if entry.starts_with('${digest}--') && !entry.ends_with('.incomplete') {
				matches << os.join_path(downloads_directory, entry)
			}
		}
	}
	strategy.cached_location_value = if matches.len == 1 {
		matches[0]
	} else {
		os.join_path(downloads_directory, '${digest}--${safe_filename(resolved_basename)}')
	}
	return strategy.cached_location_value
}

pub fn (mut strategy AbstractFileDownloadStrategy) fetched_size() ?i64 {
	temporary := strategy.temporary_path()
	if os.is_file(temporary) {
		return i64(os.file_size(temporary))
	}
	cached := strategy.cached_location()
	if os.is_file(cached) {
		return i64(os.file_size(cached))
	}
	return none
}

// basename strips the digest prefix Homebrew adds to downloads.
pub fn (mut strategy AbstractFileDownloadStrategy) basename() string {
	name := os.file_name(strategy.cached_location())
	if name.len > 66 && name[64..66] == '--' && is_lower_hex(name[..64]) {
		return name[66..]
	}
	return name
}

// create_symlink_to_cached_download atomically replaces the readable cache
// alias with a relative symlink to the digest-addressed download.
pub fn (strategy &AbstractFileDownloadStrategy) create_symlink_to_cached_download(target_cached_location string) ! {
	location := strategy.symlink_location()
	os.mkdir_all(os.dir(location))!
	if os.exists(location) || os.is_link(location) {
		remove_path(location)!
	}
	parent_prefix := os.dir(location).trim_right(os.path_separator) + os.path_separator
	target := if target_cached_location.starts_with(parent_prefix) {
		target_cached_location[parent_prefix.len..]
	} else {
		target_cached_location
	}
	os.symlink(target, location)!
}

// parse_basename reproduces the source path/query and Content-Disposition
// selection, including the file:// ancestor-dot special case.
pub fn parse_basename(raw_url string, search_query bool) string {
	mut path_components := []string{}
	mut query_components := []string{}
	mut file_url := false
	parsed := urllib.parse(raw_url) or { return os.file_name(raw_url) }
	file_url = parsed.scheme == 'file'
	if parsed.raw_query != '' {
		for field in parsed.raw_query.split('&') {
			key_and_value := field.split_nth('=', 2)
			key := urllib.query_unescape(key_and_value[0]) or { key_and_value[0] }
			value := if key_and_value.len == 2 {
				urllib.query_unescape(key_and_value[1]) or { key_and_value[1] }
			} else {
				''
			}
			if search_query {
				query_components << value
			}
			if key == 'response-content-disposition' {
				if filename := content_disposition_filename(value) {
					return os.file_name(filename)
				}
			}
		}
	}
	if parsed.path != '' {
		for component in parsed.path.split('/') {
			if component != '' {
				path_components << component
			}
		}
	}
	if !file_url {
		mut all_components := path_components.clone()
		all_components << query_components
		for index := all_components.len - 1; index >= 0; index-- {
			candidate := os.file_name(all_components[index])
			if path_extension(candidate) != '' {
				return candidate
			}
		}
	}
	if path_components.len == 0 {
		return ''
	}
	return os.file_name(path_components.last())
}

fn content_disposition_filename(value string) ?string {
	lower := value.to_lower()
	attachment_index := lower.index('attachment;') or { return none }
	filename_offset := lower[attachment_index..].index('filename=') or { return none }
	start := attachment_index + filename_offset + 'filename='.len
	if start >= value.len {
		return none
	}
	mut filename := value[start..].trim_space()
	if filename.len >= 2 && ((filename[0] == `"` && filename[filename.len - 1] == `"`)
		|| (filename[0] == `'` && filename[filename.len - 1] == `'`)) {
		filename = filename[1..filename.len - 1]
	}
	if filename == '' {
		return none
	}
	return filename
}

fn path_extension(path string) string {
	name := os.file_name(path)
	lower_name := name.to_lower()
	if bottle_marker := lower_name.last_index('.bottle.') {
		prefix := lower_name[..bottle_marker]
		if tag_start := prefix.last_index('.') {
			bottle_extension := name[tag_start..]
			if lower_name.ends_with('.tar.gz') {
				return bottle_extension
			}
		}
	}
	for archive in ['tar', 'cpio', 'pax'] {
		for compression in ['gz', 'bz2', 'lz', 'xz', 'zst', 'z'] {
			extension := '.${archive}.${compression}'
			if lower_name.ends_with(extension) {
				return name[name.len - extension.len..]
			}
		}
	}
	index := name.last_index('.') or { return '' }
	if index <= 0 {
		return ''
	}
	if lower_name.ends_with('.7z') {
		return name[index..]
	}
	if index + 1 < name.len && name[index + 1].is_digit() {
		mut version_start := index - 1
		for version_start >= 0 && name[version_start].is_digit() {
			version_start--
		}
		if version_start < 0 || (!name[version_start].is_alnum() && name[version_start] != `_`) {
			return ''
		}
	}
	if name[index + 1..].contains('.') {
		return ''
	}
	return name[index..]
}

fn safe_filename(value string) string {
	mut output := []u8{cap: value.len}
	for character in value.bytes() {
		if character >= 32 && character != 127 && character != `/` && character != `\\` {
			output << character
		}
	}
	return output.bytestr()
}

fn is_lower_hex(value string) bool {
	for character in value {
		if !character.is_digit() && character !in [`a`, `b`, `c`, `d`, `e`, `f`] {
			return false
		}
	}
	return true
}

pub fn (mut strategy AbstractFileDownloadStrategy) resolved_basename() string {
	_, basename := strategy.resolved_url_and_basename()
	return basename
}

pub fn (mut strategy AbstractFileDownloadStrategy) resolved_url_and_basename() (string, string) {
	if !strategy.has_resolved_url_basename {
		strategy.resolved_url_value = strategy.base.url
		strategy.resolved_basename_value = parse_basename(strategy.base.url, true)
		strategy.has_resolved_url_basename = true
	}
	return strategy.resolved_url_value, strategy.resolved_basename_value
}

// Source entrypoint translations.
