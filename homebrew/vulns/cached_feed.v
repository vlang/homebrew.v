module vulns

import os
import x.json2

// Translated from Homebrew/brew `vulns/cached_feed.rb`.
// The original source is retained below until every stub has a typed V body.
pub const cached_feed_default_max_age = i64(86_400)

pub struct CachedFeedDefinition {
pub:
	data_url       string
	cache_filename string
}

pub struct CachedFeed {
	data json2.Any
}

pub fn (feed CachedFeed) value() json2.Any {
	return feed.data
}

pub type CachedFeedInitialize = fn(json2.Any) !CachedFeed

pub type CachedFeedReadFile = fn(string) !string

pub type CachedFeedWriteFile = fn(string, string) !

pub type CachedFeedRenameFile = fn(string, string) !

pub type CachedFeedRemoveFile = fn(string) !

pub type CachedFeedMakeDirectory = fn(string) !

pub type CachedFeedPathExists = fn(string) bool

pub type CachedFeedModifiedTime = fn(string) !i64

pub type CachedFeedDownload = fn(string) !string

pub type CachedFeedDecompress = fn(string) !string

pub type CachedFeedTemporaryPath = fn(string, string) !string

pub type CachedFeedClock = fn() i64

pub type CachedFeedWarning = fn(string)

pub struct CachedFeedIo {
pub:
	read_file      CachedFeedReadFile @[required]
	write_file     CachedFeedWriteFile @[required]
	rename_file    CachedFeedRenameFile @[required]
	remove_file    CachedFeedRemoveFile @[required]
	make_directory CachedFeedMakeDirectory @[required]
	path_exists    CachedFeedPathExists @[required]
	modified_time  CachedFeedModifiedTime @[required]
	download       CachedFeedDownload @[required]
	decompress     CachedFeedDecompress @[required]
	temporary_path CachedFeedTemporaryPath @[required]
	now            CachedFeedClock @[required]
	warn           CachedFeedWarning @[required]
}

pub fn cached_feed_identity_decompress(contents string) !string {
	return contents
}

pub fn new_cached_feed(data json2.Any) !CachedFeed {
	return CachedFeed{
		data: data
	}
}

pub fn cached_feed_cache_path(cache_directory string, cache_filename string) string {
	return os.join_path(cache_directory, cache_filename)
}

pub fn cached_feed_as_hash(value json2.Any) ?map[string]json2.Any {
	if value is map[string]json2.Any {
		return value.clone()
	}
	return none
}

pub fn cached_feed_from_file[T](path string, cache_filename string,
	initialize fn(json2.Any) !T, read_file CachedFeedReadFile) !T {
	contents := read_file(path)!
	data := json2.decode[json2.Any](contents) or {
		return error('Failed to parse ${cache_filename} at ${path}: ${err.msg()}')
	}
	return initialize(data)
}

pub fn refresh_cached_feed[T](definition CachedFeedDefinition, cache_file string,
	initialize fn(json2.Any) !T, io CachedFeedIo) !T {
	io.make_directory(os.dir(cache_file))!
	temporary_file := io.temporary_path(cache_file, definition.cache_filename)!
	downloaded := io.download(definition.data_url) or {
		io.remove_file(temporary_file) or {}
		return err
	}
	contents := io.decompress(downloaded) or {
		io.remove_file(temporary_file) or {}
		return err
	}
	io.write_file(temporary_file, contents) or {
		io.remove_file(temporary_file) or {}
		return err
	}
	loaded := cached_feed_from_file[T](temporary_file, definition.cache_filename, initialize, io.read_file) or {
		io.remove_file(temporary_file) or {}
		return err
	}
	io.rename_file(temporary_file, cache_file) or {
		io.remove_file(temporary_file) or {}
		return err
	}
	return loaded
}

pub fn load_cached_feed[T](definition CachedFeedDefinition, cache_directory string, max_age i64,
	initialize fn(json2.Any) !T, io CachedFeedIo) !T {
	cache_file := cached_feed_cache_path(cache_directory, definition.cache_filename)
	if io.path_exists(cache_file) {
		modified := io.modified_time(cache_file)!
		if io.now() - modified <= max_age {
			return cached_feed_from_file[T](cache_file, definition.cache_filename, initialize, io.read_file)
		}
	}
	return refresh_cached_feed[T](definition, cache_file, initialize, io) or {
		if !io.path_exists(cache_file) {
			return err
		}
		modified := io.modified_time(cache_file) or { 0 }
		message := err.msg().split_into_lines()[0].trim_space()
		io.warn('Failed to refresh ${definition.cache_filename} (${message}); using cached copy from ${modified}.')
		return cached_feed_from_file[T](cache_file, definition.cache_filename, initialize, io.read_file)
	}
}

// Ruby method `self.data_url; end` at line 24.
pub fn ruby_cached_feed_l24_d1_self_data_url(definition CachedFeedDefinition) string {
	return definition.data_url
}

// Ruby method `self.cache_filename; end` at line 27.
pub fn ruby_cached_feed_l27_d2_self_cache_filename(definition CachedFeedDefinition) string {
	return definition.cache_filename
}

// Ruby method `self.default_max_age = 86_400` at line 30.
pub fn ruby_cached_feed_l30_d3_self_default_max_age() i64 {
	return cached_feed_default_max_age
}

// Ruby method `initialize(data); end` at line 33.
pub fn ruby_cached_feed_l33_d4_initialize(data json2.Any) !CachedFeed {
	return new_cached_feed(data)
}

// Ruby method `self.load(cache: HOMEBREW_CACHE/"vulns", max_age: default_max_age)` at line 36.
pub fn ruby_cached_feed_l36_d5_self_load(definition CachedFeedDefinition,
	cache_directory string, max_age i64, initialize CachedFeedInitialize,
	io CachedFeedIo) !CachedFeed {
	return load_cached_feed[CachedFeed](definition, cache_directory, max_age, initialize, io)
}

// Ruby method `self.refresh(cache_file)` at line 53.
pub fn ruby_cached_feed_l53_d6_self_refresh(definition CachedFeedDefinition, cache_file string,
	initialize CachedFeedInitialize, io CachedFeedIo) !CachedFeed {
	return refresh_cached_feed[CachedFeed](definition, cache_file, initialize, io)
}

// Ruby method `self.from_file(path)` at line 66.
pub fn ruby_cached_feed_l66_d7_self_from_file(definition CachedFeedDefinition, path string,
	initialize CachedFeedInitialize, read_file CachedFeedReadFile) !CachedFeed {
	return cached_feed_from_file[CachedFeed](path, definition.cache_filename, initialize, read_file)
}

// Ruby method `as_hash(value)` at line 73.
pub fn ruby_cached_feed_l73_d8_as_hash(value json2.Any) ?map[string]json2.Any {
	return cached_feed_as_hash(value)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "tempfile"
// 6: require "utils/curl"
// 7:
// 8: module Homebrew
// 9:   module Vulns
// 10:     # Base class for read-only loaders of a single upstream JSON feed cached
// 11:     # under `HOMEBREW_CACHE/vulns/`. Subclasses implement {.data_url},
// 12:     # {.cache_filename} and `#initialize(data)` (which validates the parsed
// 13:     # payload) and may override {.default_max_age}. {.load} handles freshness,
// 14:     # atomic refresh and stale-cache fallback uniformly.
// 15:     class CachedFeed
// 16:       extend T::Helpers
// 17:       extend Utils::Output::Mixin
// 18:
// 19:       abstract!
// 20:
// 21:       class Error < RuntimeError; end
// 22:
// 23:       sig { abstract.returns(String) }
// 24:       def self.data_url; end
// 25:
// 26:       sig { abstract.returns(String) }
// 27:       def self.cache_filename; end
// 28:
// 29:       sig { overridable.returns(Integer) }
// 30:       def self.default_max_age = 86_400
// 31:
// 32:       sig { overridable.params(data: T.anything).void }
// 33:       def initialize(data); end
// 34:
// 35:       sig { params(cache: Pathname, max_age: Integer).returns(T.attached_class) }
// 36:       def self.load(cache: HOMEBREW_CACHE/"vulns", max_age: default_max_age)
// 37:         cache_file = cache/cache_filename
// 38:         return from_file(cache_file) if cache_file.exist? && (Time.now - cache_file.mtime) <= max_age
// 39:
// 40:         refresh(cache_file)
// 41:       rescue ErrorDuringExecution, Error => e
// 42:         raise unless cache_file.exist?
// 43:
// 44:         opoo "Failed to refresh #{cache_filename} (#{e.message.lines.first&.strip}); " \
// 45:              "using cached copy from #{cache_file.mtime}."
// 46:         from_file(cache_file)
// 47:       end
// 48:
// 49:       # Download to a per-process sibling temp file and validate before
// 50:       # atomically replacing the cache so a failed, truncated or concurrent
// 51:       # fetch cannot corrupt the stale copy.
// 52:       sig { params(cache_file: Pathname).returns(T.attached_class) }
// 53:       def self.refresh(cache_file)
// 54:         cache_file.dirname.mkpath
// 55:         Tempfile.create([cache_filename, ".download"], cache_file.dirname.to_s) do |tmp|
// 56:           tmp.close
// 57:           path = Pathname(tmp.path)
// 58:           Utils::Curl.curl_download("--fail", "--silent", data_url, to: path)
// 59:           loaded = from_file(path)
// 60:           File.rename(path, cache_file)
// 61:           return loaded
// 62:         end
// 63:       end
// 64:
// 65:       sig { params(path: Pathname).returns(T.attached_class) }
// 66:       def self.from_file(path)
// 67:         new(JSON.parse(path.read))
// 68:       rescue JSON::ParserError => e
// 69:         raise Error, "Failed to parse #{cache_filename} at #{path}: #{e.message}"
// 70:       end
// 71:
// 72:       sig { params(value: T.anything).returns(T.nilable(T::Hash[String, T.untyped])) }
// 73:       def as_hash(value)
// 74:         case value
// 75:         when Hash then value
// 76:         end
// 77:       end
// 78:     end
// 79:   end
// 80: end
