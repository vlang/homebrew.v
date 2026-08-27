module download_strategy

import brew_runtime

// Translated from Homebrew/brew `download_strategy/abstract_file_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `temporary_path` at line 12.
pub fn ruby_abstract_file_download_strategy_l12_d1_temporary_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('temporary_path', ...args)
}

// Ruby method `symlink_location` at line 21.
pub fn ruby_abstract_file_download_strategy_l21_d2_symlink_location(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symlink_location', ...args)
}

// Ruby method `cached_location` at line 33.
pub fn ruby_abstract_file_download_strategy_l33_d3_cached_location(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cached_location', ...args)
}

// Ruby method `fetched_size` at line 51.
pub fn ruby_abstract_file_download_strategy_l51_d4_fetched_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetched_size', ...args)
}

// Ruby method `basename` at line 56.
pub fn ruby_abstract_file_download_strategy_l56_d5_basename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('basename', ...args)
}

// Ruby method `create_symlink_to_cached_download(target_cached_location)` at line 61.
pub fn ruby_abstract_file_download_strategy_l61_d6_create_symlink_to_cached_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_symlink_to_cached_download', ...args)
}

// Ruby method `parse_basename(url, search_query: true)` at line 67.
pub fn ruby_abstract_file_download_strategy_l67_d7_parse_basename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_basename', ...args)
}

// Ruby method `resolved_basename` at line 117.
pub fn ruby_abstract_file_download_strategy_l117_d8_resolved_basename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolved_basename', ...args)
}

// Ruby method `resolved_url_and_basename` at line 123.
pub fn ruby_abstract_file_download_strategy_l123_d9_resolved_url_and_basename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolved_url_and_basename', ...args)
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
