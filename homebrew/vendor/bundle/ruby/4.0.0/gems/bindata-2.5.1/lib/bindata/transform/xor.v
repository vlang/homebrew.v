module transform

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/transform/xor.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct Xor {
pub:
	xor u8
}

pub fn new_xor(xor int) !Xor {
	if xor < 0 || xor > 255 {
		return error('xor must be between 0 and 255')
	}
	return Xor{
		xor: u8(xor)
	}
}

pub fn (transform Xor) transform(data []u8) []u8 {
	return data.map(it ^ transform.xor)
}

pub fn (transform Xor) read(chained_data []u8, n int) []u8 {
	limit := if n < chained_data.len { n } else { chained_data.len }
	return transform.transform(chained_data[..limit])
}

pub fn (transform Xor) write(data []u8) []u8 {
	return transform.transform(data)
}

fn xor_from_receiver(value ruby.Value) Xor {
	key := if value.type_name == 'Integer' {
		int(value.as_int() or { panic(err) })
	} else {
		(value.attribute('xor') or { panic('BinData::Transform::Xor requires an xor value') }).int()
	}
	return new_xor(key) or { panic(err) }
}

// Ruby method `initialize(xor)` at line 5.
pub fn ruby_xor_l5_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('BinData::Transform::Xor#initialize requires xor')
	}
	transform := xor_from_receiver(args[0])
	return ruby.structured_value('BinData::Transform::Xor', 'Xor(${transform.xor})', {
		'xor': transform.xor.str()
	})
}

// Ruby method `read(n)` at line 10.
pub fn ruby_xor_l10_d2_read(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('BinData::Transform::Xor#read requires a receiver and chained data')
	}
	transform := xor_from_receiver(args[0])
	data := args[1].as_string().bytes()
	n := if args.len >= 3 { int(args[2].as_int() or { panic(err) }) } else { data.len }
	return ruby.string_value(transform.read(data, n).bytestr())
}

// Ruby method `write(data)` at line 14.
pub fn ruby_xor_l14_d3_write(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('BinData::Transform::Xor#write requires a receiver and data')
	}
	return ruby.string_value(xor_from_receiver(args[0]).write(args[1].as_string().bytes()).bytestr())
}

// Original Ruby source (line-for-line):
// 1: module BinData
// 2:   module Transform
// 3:     # Transforms the data stream by xoring each byte.
// 4:     class Xor < BinData::IO::Transform
// 5:       def initialize(xor)
// 6:         super()
// 7:         @xor = xor
// 8:       end
// 9:
// 10:       def read(n)
// 11:         chain_read(n).bytes.map { |byte| (byte ^ @xor).chr }.join
// 12:       end
// 13:
// 14:       def write(data)
// 15:         chain_write(data.bytes.map { |byte| (byte ^ @xor).chr }.join)
// 16:       end
// 17:     end
// 18:   end
// 19: end
