module transform

import ruby
import compress.brotli
import compress.zlib
import compress.zstd
import os
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/transform/brotli.rb`.
// The original source is retained below until every stub has a typed V body.
enum CompressionCodec {
	brotli
	lz4
	xz
	zlib
	zstd
}

struct CompressionTransform {
pub:
	read_length int
	codec       CompressionCodec
mut:
	read_buffer  []u8
	read_started bool
	write_buffer []u8
}

fn new_compression_transform(read_length int, codec CompressionCodec) !CompressionTransform {
	if read_length < 0 {
		return error('read length must not be negative')
	}
	return CompressionTransform{
		read_length: read_length
		codec: codec
	}
}

fn codec_compress(codec CompressionCodec, data []u8) ![]u8 {
	return match codec {
		.brotli { brotli.compress(data)! }
		.lz4 { run_compression_command('lz4', data, false)! }
		.xz { run_compression_command('xz', data, false)! }
		.zlib { zlib.compress(data)! }
		.zstd { zstd.compress(data)! }
	}
}

fn codec_decompress(codec CompressionCodec, data []u8) ![]u8 {
	return match codec {
		.brotli { brotli.decompress(data)! }
		.lz4 { run_compression_command('lz4', data, true)! }
		.xz { run_compression_command('xz', data, true)! }
		.zlib { zlib.decompress(data)! }
		.zstd {
			decoded := zstd.decompress(data) or {
				// V's zstd wrapper rejects valid empty frames because their advertised
				// content size is zero. zstd-ruby returns an empty string for them.
				empty_frame := zstd.compress([]u8{})!
				if data == empty_frame {
					return []u8{}
				}
				return err
			}
			decoded
		}
	}
}

fn run_compression_command(codec string, data []u8, decompress bool) ![]u8 {
	executable := os.find_abs_path_of_executable(codec) or {
		return error('${codec} executable is required for BinData compression transforms')
	}
	work_dir := os.join_path(os.temp_dir(), 'brew-v-bindata-${codec}-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(work_dir)!
	defer {
		os.rmdir_all(work_dir) or {}
	}
	if codec == 'lz4' {
		input := os.join_path(work_dir, if decompress { 'payload.lz4' } else { 'payload' })
		output := os.join_path(work_dir, if decompress { 'payload.decoded' } else { 'payload.lz4' })
		os.write_file_array(input, data)!
		mode := if decompress { '-d' } else { '-z' }
		result := os.execute('${os.quoted_path(executable)} -q -f ${mode} ${os.quoted_path(input)} ${os.quoted_path(output)}')
		if result.exit_code != 0 {
			return error('lz4 ${if decompress { 'decompression' } else { 'compression' }} failed: ${result.output.trim_space()}')
		}
		return os.read_bytes(output)
	}
	input := os.join_path(work_dir, if decompress { 'payload.xz' } else { 'payload' })
	output := os.join_path(work_dir, if decompress { 'payload' } else { 'payload.xz' })
	os.write_file_array(input, data)!
	mode := if decompress { '--decompress' } else { '--compress' }
	result := os.execute('${os.quoted_path(executable)} --format=xz ${mode} --keep --force ${os.quoted_path(input)}')
	if result.exit_code != 0 {
		return error('xz ${if decompress { 'decompression' } else { 'compression' }} failed: ${result.output.trim_space()}')
	}
	return os.read_bytes(output)
}

fn (mut transform CompressionTransform) read(chained_data []u8, n int) ![]u8 {
	if n < 0 {
		return error('read length must not be negative')
	}
	if !transform.read_started {
		if chained_data.len < transform.read_length {
			return error('not enough compressed data: wanted ${transform.read_length}, got ${chained_data.len}')
		}
		transform.read_buffer = codec_decompress(transform.codec, chained_data[..transform.read_length])!
		transform.read_started = true
	}
	count := if n < transform.read_buffer.len { n } else { transform.read_buffer.len }
	result := transform.read_buffer[..count].clone()
	transform.read_buffer.delete_many(0, count)
	return result
}

fn (mut transform CompressionTransform) write(data []u8) []u8 {
	transform.write_buffer << data
	return transform.write_buffer.clone()
}

fn (transform &CompressionTransform) after_read_transform() ! {
	if !transform.read_started || transform.read_buffer.len != 0 {
		return error("didn't read all data")
	}
}

fn (transform &CompressionTransform) after_write_transform() ![]u8 {
	return codec_compress(transform.codec, transform.write_buffer)
}

fn transform_read_length(receiver ruby.Value) !int {
	if receiver.type_name == 'Integer' {
		return int(receiver.as_int()!)
	}
	return receiver.attribute('read_length')!.int()
}

fn initialized_transform_value(type_name string, read_length int) ruby.Value {
	return ruby.structured_value(type_name, '${type_name}(${read_length})', {
		'read_length': read_length.str()
		'write':       ''
	})
}

fn translated_read(codec CompressionCodec, args []ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('compression transform read requires a receiver, chained data, and length')
	}
	mut transform := new_compression_transform(transform_read_length(args[0]) or { panic(err) }, codec) or { panic(err) }
	data := transform.read(args[1].as_string().bytes(), int(args[2].as_int() or { panic(err) })) or {
		panic(err)
	}
	return ruby.string_value(data.bytestr())
}

fn translated_write(args []ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('compression transform write requires a receiver and data')
	}
	existing := if args[0].type_name == 'String' {
		args[0].as_string()
	} else {
		args[0].attribute('write') or { '' }
	}
	return ruby.string_value(existing + args[1].as_string())
}

fn translated_after_read(args []ruby.Value) ruby.Value {
	if args.len < 2 || args[1].as_string().len != 0 {
		panic("didn't read all data")
	}
	return ruby.object_value('NilClass', 'nil')
}

fn translated_after_write(codec CompressionCodec, args []ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('compression transform finalization requires buffered data')
	}
	data := if args.len >= 2 { args[1].as_string() } else { args[0].as_string() }
	compressed := codec_compress(codec, data.bytes()) or { panic(err) }
	return ruby.string_value(compressed.bytestr())
}

pub struct BrotliTransform {
mut:
	stream CompressionTransform
}

pub fn new_brotli_transform(read_length int) !BrotliTransform {
	return BrotliTransform{
		stream: new_compression_transform(read_length, .brotli)!
	}
}

pub fn (mut transform BrotliTransform) read(chained_data []u8, n int) ![]u8 {
	return transform.stream.read(chained_data, n)
}

pub fn (mut transform BrotliTransform) write(data []u8) []u8 {
	return transform.stream.write(data)
}

pub fn (transform &BrotliTransform) after_read_transform() ! {
	transform.stream.after_read_transform()!
}

pub fn (transform &BrotliTransform) after_write_transform() ![]u8 {
	return transform.stream.after_write_transform()
}

// Ruby method `initialize(read_length)` at line 11.
pub fn ruby_brotli_l11_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('BinData::Transform::Brotli#initialize requires read_length')
	}
	read_length := int(args[0].as_int() or { panic(err) })
	_ = new_brotli_transform(read_length) or { panic(err) }
	return initialized_transform_value('BinData::Transform::Brotli', read_length)
}

// Ruby method `read(n)` at line 16.
pub fn ruby_brotli_l16_d2_read(args ...ruby.Value) ruby.Value {
	return translated_read(.brotli, args)
}

// Ruby method `write(data)` at line 21.
pub fn ruby_brotli_l21_d3_write(args ...ruby.Value) ruby.Value {
	return translated_write(args)
}

// Ruby method `after_read_transform` at line 26.
pub fn ruby_brotli_l26_d4_after_read_transform(args ...ruby.Value) ruby.Value {
	return translated_after_read(args)
}

// Ruby method `after_write_transform` at line 30.
pub fn ruby_brotli_l30_d5_after_write_transform(args ...ruby.Value) ruby.Value {
	return translated_after_write(.brotli, args)
}

// Original Ruby source (line-for-line):
// 1: require 'brotli'
// 2:
// 3: module BinData
// 4:   module Transform
// 5:     # Transforms a brotli compressed data stream.
// 6:     #
// 7:     #     gem install brotli
// 8:     class Brotli < BinData::IO::Transform
// 9:       transform_changes_stream_length!
// 10:
// 11:       def initialize(read_length)
// 12:         super()
// 13:         @length = read_length
// 14:       end
// 15:
// 16:       def read(n)
// 17:         @read ||= ::Brotli::inflate(chain_read(@length))
// 18:         @read.slice!(0...n)
// 19:       end
// 20:
// 21:       def write(data)
// 22:         @write ||= create_empty_binary_string
// 23:         @write << data
// 24:       end
// 25:
// 26:       def after_read_transform
// 27:         raise IOError, "didn't read all data" unless @read.empty?
// 28:       end
// 29:
// 30:       def after_write_transform
// 31:         chain_write(::Brotli::deflate(@write))
// 32:       end
// 33:     end
// 34:   end
// 35: end
