module transform

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/transform/zstd.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ZstdTransform {
mut:
	stream CompressionTransform
}

pub fn new_zstd_transform(read_length int) !ZstdTransform {
	return ZstdTransform{
		stream: new_compression_transform(read_length, .zstd)!
	}
}

pub fn (mut transform ZstdTransform) read(chained_data []u8, n int) ![]u8 {
	return transform.stream.read(chained_data, n)
}

pub fn (mut transform ZstdTransform) write(data []u8) []u8 {
	return transform.stream.write(data)
}

pub fn (transform &ZstdTransform) after_read_transform() ! {
	transform.stream.after_read_transform()!
}

pub fn (transform &ZstdTransform) after_write_transform() ![]u8 {
	return transform.stream.after_write_transform()
}

// Ruby method `initialize(read_length)` at line 11.
pub fn ruby_zstd_l11_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('BinData::Transform::Zstd#initialize requires read_length')
	}
	read_length := int(args[0].as_int() or { panic(err) })
	_ = new_zstd_transform(read_length) or { panic(err) }
	return initialized_transform_value('BinData::Transform::Zstd', read_length)
}

// Ruby method `read(n)` at line 16.
pub fn ruby_zstd_l16_d2_read(args ...ruby.Value) ruby.Value {
	return translated_read(.zstd, args)
}

// Ruby method `write(data)` at line 21.
pub fn ruby_zstd_l21_d3_write(args ...ruby.Value) ruby.Value {
	return translated_write(args)
}

// Ruby method `after_read_transform` at line 26.
pub fn ruby_zstd_l26_d4_after_read_transform(args ...ruby.Value) ruby.Value {
	return translated_after_read(args)
}

// Ruby method `after_write_transform` at line 30.
pub fn ruby_zstd_l30_d5_after_write_transform(args ...ruby.Value) ruby.Value {
	return translated_after_write(.zstd, args)
}

// Original Ruby source (line-for-line):
// 1: require 'zstd-ruby'
// 2:
// 3: module BinData
// 4:   module Transform
// 5:     # Transforms a zstd compressed data stream.
// 6:     #
// 7:     #     gem install zstd-ruby
// 8:     class Zstd < BinData::IO::Transform
// 9:       transform_changes_stream_length!
// 10:
// 11:       def initialize(read_length)
// 12:         super()
// 13:         @length = read_length
// 14:       end
// 15:
// 16:       def read(n)
// 17:         @read ||= ::Zstd::decompress(chain_read(@length))
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
// 31:         chain_write(::Zstd::compress(@write))
// 32:       end
// 33:     end
// 34:   end
// 35: end
