module utils

import compress.gzip as vgzip
import encoding.binary
import os

// Translated from Homebrew/brew `utils/gzip.rb`.

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
