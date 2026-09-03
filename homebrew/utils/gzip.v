module utils

import compress.gzip as vgzip
import encoding.binary
import os

// Translated from Homebrew/brew `utils/gzip.rb`.
// The original source is retained below until every stub has a typed V body.

// Apple's gzip also uses zlib so use the same buffer size here.
// https://github.com/apple-oss-distributions/file_cmds/blob/file_cmds-400/gzip/gzip.c#L147
pub const gzip_buffer_size = 64 * 1024

@[params]
pub struct GzipOptions {
pub:
	mtime     ?i64
	orig_name ?string
	output    ?string
}

@[params]
pub struct GzipCompressOptions {
pub:
	reproducible bool = true
	mtime        ?i64
}

fn gzip_source_date_epoch() i64 {
	value := os.getenv('SOURCE_DATE_EPOCH')
	return if value == '' { i64(0) } else { value.i64() }
}

fn gzip_effective_mtime(value i64) i64 {
	// There are two problems if `mtime` is less than or equal to 0:
	//
	// 1. Ideally, we would just set mtime = 0 if SOURCE_DATE_EPOCH is absent, but Ruby's
	//    Zlib::GzipWriter does not properly handle the case of setting mtime = 0:
	//    https://bugs.ruby-lang.org/issues/16285
	//
	//    This was fixed in https://github.com/ruby/zlib/pull/10. This workaround
	//    won't be needed once we are using zlib gem version 1.1.0 or newer.
	//
	// 2. If mtime is less than 0, gzip may fail to cast a negative number to an unsigned int
	//    https://github.com/Homebrew/homebrew-core/pull/246155#issuecomment-3345772366
	return if value <= 0 { i64(1) } else { value }
}

fn gzip_stream_without_metadata(path string) ![]u8 {
	gzip := os.find_abs_path_of_executable('gzip')!
	mut process := os.new_process(gzip)
	process.set_args(['-n', '-c', '--', path])
	process.set_redirect_stdio()
	process.run()
	stream := process.stdout_slurp()
	message := process.stderr_slurp()
	process.wait()
	exit_code := process.code
	process.close()
	if exit_code != 0 {
		return error('gzip failed (${exit_code}): ${message.trim_space()}')
	}
	return stream.bytes()
}

fn gzip_bytes_with_options(base []u8, mtime i64, orig_name string) ![]u8 {
	if base.len < 18 {
		return error('invalid generated gzip stream')
	}
	name := orig_name.bytes()
	mut output := []u8{cap: base.len + name.len + 1}
	output << [u8(0x1f), 0x8b, 0x08, 0x08]
	output << binary.little_endian_get_u32(u32(gzip_effective_mtime(mtime)))
	output << u8(0)
	output << u8(3)
	output << name
	output << u8(0)
	output << base[10..]
	return output
}

pub fn gzip_compress_with_options(path string, options GzipOptions) !string {
	mtime := options.mtime or { gzip_source_date_epoch() }
	orig_name := options.orig_name or { os.file_name(path) }
	output := options.output or { '${path}.gz' }
	base := gzip_stream_without_metadata(path)!
	compressed := gzip_bytes_with_options(base, mtime, orig_name)!
	os.write_file_array(output, compressed)!
	os.rm(path) or {}
	return output
}

fn gzip_compress_with_system(path string) !string {
	gzip := os.find_abs_path_of_executable('gzip')!
	mut process := os.new_process(gzip)
	process.set_args(['--', path])
	process.set_redirect_stdio_merged()
	process.run()
	message := process.stdout_slurp()
	process.wait()
	exit_code := process.code
	process.close()
	if exit_code != 0 {
		return error('gzip failed (${exit_code}): ${message.trim_space()}')
	}
	return '${path}.gz'
}

pub fn gzip_compress(paths []string, options GzipCompressOptions) ![]string {
	mut results := []string{cap: paths.len}
	mtime := options.mtime or { gzip_source_date_epoch() }
	for path in paths {
		if options.reproducible {
			results << gzip_compress_with_options(path, mtime: mtime)!
		} else {
			results << gzip_compress_with_system(path)!
		}
	}
	return results
}

pub fn gzip_read(path string) ![]u8 {
	return vgzip.decompress(os.read_bytes(path)!)
}

// Ruby method `self.compress_with_options(path, mtime: ENV["SOURCE_DATE_EPOCH"].to_i, orig_name: File.basename(path),` at line 23.
pub fn ruby_gzip_l23_d1_self_compress_with_options(path string, options GzipOptions) !string {
	return gzip_compress_with_options(path, options)
}

// Ruby method `self.compress(*paths, reproducible: true, mtime: ENV["SOURCE_DATE_EPOCH"].to_i)` at line 71.
pub fn ruby_gzip_l71_d2_self_compress(paths []string, options GzipCompressOptions) ![]string {
	return gzip_compress(paths, options)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module Utils
// 7:   # Helper functions for creating gzip files.
// 8:   module Gzip
// 9:     extend ::Utils::Output::Mixin
// 10:
// 11:     # Apple's gzip also uses zlib so use the same buffer size here.
// 12:     # https://github.com/apple-oss-distributions/file_cmds/blob/file_cmds-400/gzip/gzip.c#L147
// 13:     GZIP_BUFFER_SIZE = T.let(64 * 1024, Integer)
// 14:
// 15:     sig {
// 16:       params(
// 17:         path:      T.any(String, Pathname),
// 18:         mtime:     T.any(Integer, Time),
// 19:         orig_name: String,
// 20:         output:    T.any(String, Pathname),
// 21:       ).returns(Pathname)
// 22:     }
// 23:     def self.compress_with_options(path, mtime: ENV["SOURCE_DATE_EPOCH"].to_i, orig_name: File.basename(path),
// 24:                                    output: "#{path}.gz")
// 25:       # There are two problems if `mtime` is less than or equal to 0:
// 26:       #
// 27:       # 1. Ideally, we would just set mtime = 0 if SOURCE_DATE_EPOCH is absent, but Ruby's
// 28:       #    Zlib::GzipWriter does not properly handle the case of setting mtime = 0:
// 29:       #    https://bugs.ruby-lang.org/issues/16285
// 30:       #
// 31:       #    This was fixed in https://github.com/ruby/zlib/pull/10. This workaround
// 32:       #    won't be needed once we are using zlib gem version 1.1.0 or newer.
// 33:       #
// 34:       # 2. If mtime is less than 0, gzip may fail to cast a negative number to an unsigned int
// 35:       #    https://github.com/Homebrew/homebrew-core/pull/246155#issuecomment-3345772366
// 36:       if mtime.to_i <= 0
// 37:         odebug "Setting `mtime = 1` to avoid zlib gem bug and unsigned integer cast when `mtime <= 0`."
// 38:         mtime = 1
// 39:       end
// 40:
// 41:       File.open(path, "rb") do |fp|
// 42:         odebug "Creating gzip file at #{output}"
// 43:         gz = Zlib::GzipWriter.open(output)
// 44:         gz.mtime = mtime
// 45:         gz.orig_name = orig_name
// 46:         gz.write(fp.read(GZIP_BUFFER_SIZE)) until fp.eof?
// 47:       ensure
// 48:         # GzipWriter should be closed in case of error as well
// 49:         gz.close
// 50:       end
// 51:
// 52:       FileUtils.rm_f path
// 53:       Pathname.new(output)
// 54:     end
// 55:
// 56:     # Compress one or more files with `gzip`, reproducibly by default.
// 57:     #
// 58:     # Unlike the system `gzip`, this avoids recording the build-time modification
// 59:     # time so that the output is deterministic (see {https://docs.brew.sh/Reproducible-Builds}).
// 60:     # Each file is compressed in place, placing the result next to the original
// 61:     # with a `.gz` suffix, and the resulting paths are returned.
// 62:     #
// 63:     # @api public
// 64:     sig {
// 65:       params(
// 66:         paths:        T.any(String, Pathname),
// 67:         reproducible: T::Boolean,
// 68:         mtime:        T.any(Integer, Time),
// 69:       ).returns(T::Array[Pathname])
// 70:     }
// 71:     def self.compress(*paths, reproducible: true, mtime: ENV["SOURCE_DATE_EPOCH"].to_i)
// 72:       if reproducible
// 73:         paths.map do |path|
// 74:           compress_with_options(path, mtime:)
// 75:         end
// 76:       else
// 77:         paths.map do |path|
// 78:           safe_system "gzip", path
// 79:           Pathname.new("#{path}.gz")
// 80:         end
// 81:       end
// 82:     end
// 83:   end
// 84: end
