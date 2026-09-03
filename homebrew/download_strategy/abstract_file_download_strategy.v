module download_strategy

import crypto.sha256
import net.urllib
import os

// Translated from Homebrew/brew `download_strategy/abstract_file_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

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
	return os.join_path(strategy.base.cache,
		safe_filename('${strategy.base.name}--${strategy.base.version}${extension}'))
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
// Ruby method `temporary_path` at line 12.
pub fn ruby_abstract_file_download_strategy_l12_d1_temporary_path(mut strategy AbstractFileDownloadStrategy) string {
	return strategy.temporary_path()
}

// Ruby method `symlink_location` at line 21.
pub fn ruby_abstract_file_download_strategy_l21_d2_symlink_location(strategy &AbstractFileDownloadStrategy) string {
	return strategy.symlink_location()
}

// Ruby method `cached_location` at line 33.
pub fn ruby_abstract_file_download_strategy_l33_d3_cached_location(mut strategy AbstractFileDownloadStrategy) string {
	return strategy.cached_location()
}

// Ruby method `fetched_size` at line 51.
pub fn ruby_abstract_file_download_strategy_l51_d4_fetched_size(mut strategy AbstractFileDownloadStrategy) ?i64 {
	return strategy.fetched_size()
}

// Ruby method `basename` at line 56.
pub fn ruby_abstract_file_download_strategy_l56_d5_basename(mut strategy AbstractFileDownloadStrategy) string {
	return strategy.basename()
}

// Ruby method `create_symlink_to_cached_download(target_cached_location)` at line 61.
pub fn ruby_abstract_file_download_strategy_l61_d6_create_symlink_to_cached_download(strategy &AbstractFileDownloadStrategy, target_cached_location string) ! {
	strategy.create_symlink_to_cached_download(target_cached_location)!
}

// Ruby method `parse_basename(url, search_query: true)` at line 67.
pub fn ruby_abstract_file_download_strategy_l67_d7_parse_basename(raw_url string, search_query bool) string {
	return parse_basename(raw_url, search_query)
}

// Ruby method `resolved_basename` at line 117.
pub fn ruby_abstract_file_download_strategy_l117_d8_resolved_basename(mut strategy AbstractFileDownloadStrategy) string {
	return strategy.resolved_basename()
}

// Ruby method `resolved_url_and_basename` at line 123.
pub fn ruby_abstract_file_download_strategy_l123_d9_resolved_url_and_basename(mut strategy AbstractFileDownloadStrategy) (string, string) {
	return strategy.resolved_url_and_basename()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # @abstract Abstract superclass for all download strategies downloading a single file.
// 5: class AbstractFileDownloadStrategy < AbstractDownloadStrategy
// 6:   abstract!
// 7:
// 8:   # Path for storing an incomplete download while the download is still in progress.
// 9:   #
// 10:   # @api public
// 11:   sig { returns(Pathname) }
// 12:   def temporary_path
// 13:     @temporary_path ||= T.let(Pathname.new("#{cached_location}.incomplete"), T.nilable(Pathname))
// 14:   end
// 15:
// 16:   # Path of the symlink (whose name includes the resource name, version and extension)
// 17:   # pointing to {#cached_location}.
// 18:   #
// 19:   # @api public
// 20:   sig { returns(Pathname) }
// 21:   def symlink_location
// 22:     return T.must(@symlink_location) if defined?(@symlink_location)
// 23:
// 24:     ext = Pathname(parse_basename(url)).extname
// 25:     @symlink_location = T.let(@cache/Utils.safe_filename("#{name}--#{version}#{ext}"), T.nilable(Pathname))
// 26:     T.must(@symlink_location)
// 27:   end
// 28:
// 29:   # Path for storing the completed download.
// 30:   #
// 31:   # @api public
// 32:   sig { override.returns(Pathname) }
// 33:   def cached_location
// 34:     return @cached_location if @cached_location
// 35:
// 36:     url_sha256 = Digest::SHA256.hexdigest(url)
// 37:     downloads = Pathname.glob(HOMEBREW_CACHE/"downloads/#{url_sha256}--*")
// 38:                         .reject { |path| path.extname.end_with?(".incomplete") }
// 39:
// 40:     @cached_location = T.let(
// 41:       if downloads.one?
// 42:         downloads.fetch(0)
// 43:       else
// 44:         HOMEBREW_CACHE/"downloads/#{url_sha256}--#{Utils.safe_filename(resolved_basename)}"
// 45:       end, T.nilable(Pathname)
// 46:     )
// 47:     T.must(@cached_location)
// 48:   end
// 49:
// 50:   sig { override.returns(T.nilable(Integer)) }
// 51:   def fetched_size
// 52:     File.size?(temporary_path) || File.size?(cached_location)
// 53:   end
// 54:
// 55:   sig { returns(Pathname) }
// 56:   def basename
// 57:     cached_location.basename.sub(/^[\da-f]{64}--/, "")
// 58:   end
// 59:
// 60:   sig { params(target_cached_location: Pathname).void }
// 61:   def create_symlink_to_cached_download(target_cached_location)
// 62:     symlink_location.dirname.mkpath
// 63:     FileUtils.ln_s target_cached_location.relative_path_from(symlink_location.dirname), symlink_location, force: true
// 64:   end
// 65:
// 66:   sig { params(url: String, search_query: T::Boolean).returns(String) }
// 67:   def parse_basename(url, search_query: true)
// 68:     components = { path: T.let([], T::Array[String]), query: T.let([], T::Array[String]) }
// 69:
// 70:     file_url = T.let(false, T::Boolean)
// 71:     if url.match?(URI::RFC2396_PARSER.make_regexp)
// 72:       uri = URI(url)
// 73:       file_url = uri.scheme == "file"
// 74:
// 75:       if (uri_query = uri.query.presence)
// 76:         URI.decode_www_form(uri_query).each do |key, param|
// 77:           components[:query] << param if search_query
// 78:
// 79:           next if key != "response-content-disposition"
// 80:
// 81:           query_basename = param[/attachment;\s*filename=(["']?)(.+)\1/i, 2]
// 82:           return File.basename(query_basename) if query_basename
// 83:         end
// 84:       end
// 85:
// 86:       if (uri_path = uri.path.presence)
// 87:         components[:path] = uri_path.split("/").filter_map do |part|
// 88:           URI::RFC2396_PARSER.unescape(part).presence
// 89:         end
// 90:       end
// 91:     else
// 92:       components[:path] = [url]
// 93:     end
// 94:
// 95:     # We need a Pathname because we've monkeypatched extname to support double
// 96:     # extensions (e.g. tar.gz).
// 97:     # Given a URL like https://example.com/download.php?file=foo-1.0.tar.gz
// 98:     # the basename we want is "foo-1.0.tar.gz", not "download.php".
// 99:     # Skipped for file:// URLs since their paths can contain ancestor
// 100:     # directories with dots (e.g. "github.com") that aren't real extensions.
// 101:     unless file_url
// 102:       [*components[:path], *components[:query]].reverse_each do |path|
// 103:         path = Pathname(path)
// 104:         return path.basename.to_s if path.extname.present?
// 105:       end
// 106:     end
// 107:
// 108:     filename = components[:path].last
// 109:     return "" if filename.blank?
// 110:
// 111:     File.basename(filename)
// 112:   end
// 113:
// 114:   private
// 115:
// 116:   sig { returns(String) }
// 117:   def resolved_basename
// 118:     _, resolved_basename = resolved_url_and_basename
// 119:     resolved_basename
// 120:   end
// 121:
// 122:   sig { returns([String, String]) }
// 123:   def resolved_url_and_basename
// 124:     return T.must(@resolved_url_and_basename) if defined?(@resolved_url_and_basename)
// 125:
// 126:     T.must(@resolved_url_and_basename = T.let([url, parse_basename(url)], T.nilable([String, String])))
// 127:   end
// 128: end
