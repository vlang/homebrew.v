module transform

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/transform/zlib.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ZlibTransform {
mut:
	stream CompressionTransform
}

pub fn new_zlib_transform(read_length int) !ZlibTransform {
	return ZlibTransform{
		stream: new_compression_transform(read_length, .zlib)!
	}
}

pub fn (mut transform ZlibTransform) read(chained_data []u8, n int) ![]u8 {
	return transform.stream.read(chained_data, n)
}

pub fn (mut transform ZlibTransform) write(data []u8) []u8 {
	return transform.stream.write(data)
}

pub fn (transform &ZlibTransform) after_read_transform() ! {
	transform.stream.after_read_transform()!
}

pub fn (transform &ZlibTransform) after_write_transform() ![]u8 {
	return transform.stream.after_write_transform()
}

// Ruby method `initialize(read_length)` at line 9.
pub fn ruby_zlib_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('BinData::Transform::Zlib#initialize requires read_length')
	}
	read_length := int(args[0].as_int() or { panic(err) })
	_ = new_zlib_transform(read_length) or { panic(err) }
	return initialized_transform_value('BinData::Transform::Zlib', read_length)
}

// Ruby method `read(n)` at line 14.
pub fn ruby_zlib_l14_d2_read(args ...brew_runtime.Value) brew_runtime.Value {
	return translated_read(.zlib, args)
}

// Ruby method `write(data)` at line 19.
pub fn ruby_zlib_l19_d3_write(args ...brew_runtime.Value) brew_runtime.Value {
	return translated_write(args)
}

// Ruby method `after_read_transform` at line 24.
pub fn ruby_zlib_l24_d4_after_read_transform(args ...brew_runtime.Value) brew_runtime.Value {
	return translated_after_read(args)
}

// Ruby method `after_write_transform` at line 28.
pub fn ruby_zlib_l28_d5_after_write_transform(args ...brew_runtime.Value) brew_runtime.Value {
	return translated_after_write(.zlib, args)
}

// Original Ruby source (line-for-line):
// 1: require 'zlib'
// 2:
// 3: module BinData
// 4:   module Transform
// 5:     # Transforms a zlib compressed data stream.
// 6:     class Zlib < BinData::IO::Transform
// 7:       transform_changes_stream_length!
// 8:
// 9:       def initialize(read_length)
// 10:         super()
// 11:         @length = read_length
// 12:       end
// 13:
// 14:       def read(n)
// 15:         @read ||= ::Zlib::Inflate.inflate(chain_read(@length))
// 16:         @read.slice!(0...n)
// 17:       end
// 18:
// 19:       def write(data)
// 20:         @write ||= create_empty_binary_string
// 21:         @write << data
// 22:       end
// 23:
// 24:       def after_read_transform
// 25:         raise IOError, "didn't read all data" unless @read.empty?
// 26:       end
// 27:
// 28:       def after_write_transform
// 29:         chain_write(::Zlib::Deflate.deflate(@write))
// 30:       end
// 31:     end
// 32:   end
// 33: end
