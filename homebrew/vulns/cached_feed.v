module vulns

import os
import x.json2

// Translated from Homebrew/brew `vulns/cached_feed.rb`.
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

pub type CachedFeedInitialize = fn (json2.Any) !CachedFeed

pub type CachedFeedReadFile = fn (string) !string

pub type CachedFeedWriteFile = fn (string, string) !

pub type CachedFeedRenameFile = fn (string, string) !

pub type CachedFeedRemoveFile = fn (string) !

pub type CachedFeedMakeDirectory = fn (string) !

pub type CachedFeedPathExists = fn (string) bool

pub type CachedFeedModifiedTime = fn (string) !i64

pub type CachedFeedDownload = fn (string) !string

pub type CachedFeedDecompress = fn (string) !string

pub type CachedFeedTemporaryPath = fn (string, string) !string

pub type CachedFeedClock = fn () i64

pub type CachedFeedWarning = fn (string)

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
	initialize fn (json2.Any) !T, read_file CachedFeedReadFile) !T {
	contents := read_file(path)!
	data := json2.decode[json2.Any](contents) or {
		return error('Failed to parse ${cache_filename} at ${path}: ${err.msg()}')
	}
	return initialize(data)
}

pub fn refresh_cached_feed[T](definition CachedFeedDefinition, cache_file string,
	initialize fn (json2.Any) !T, io CachedFeedIo) !T {
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
	initialize fn (json2.Any) !T, io CachedFeedIo) !T {
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
