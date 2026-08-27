module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/alignment.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `clear?; true; end` at line 16.
pub fn ruby_alignment_l16_d1_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear?', ...args)
}

// Ruby method `assign(val); end` at line 17.
pub fn ruby_alignment_l17_d2_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `snapshot; nil; end` at line 18.
pub fn ruby_alignment_l18_d3_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('snapshot', ...args)
}

// Ruby method `do_num_bytes; 0; end` at line 19.
pub fn ruby_alignment_l19_d4_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Ruby method `do_read(io)` at line 21.
pub fn ruby_alignment_l21_d5_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read', ...args)
}

// Ruby method `do_write(io)` at line 25.
pub fn ruby_alignment_l25_d6_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_write', ...args)
}

// Ruby method `initialize(io)` at line 45.
pub fn ruby_alignment_l45_d7_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `binary_string(str)` at line 49.
pub fn ruby_alignment_l49_d8_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('binary_string', ...args)
}

// Ruby method `readbytes(n)` at line 53.
pub fn ruby_alignment_l53_d9_readbytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('readbytes', ...args)
}

// Ruby method `writebytes(str)` at line 58.
pub fn ruby_alignment_l58_d10_writebytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writebytes', ...args)
}

// Ruby method `bit_aligned?` at line 63.
pub fn ruby_alignment_l63_d11_bit_aligned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bit_aligned?', ...args)
}

// Ruby method `do_read(io)` at line 67.
pub fn ruby_alignment_l67_d12_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read', ...args)
}

// Ruby method `do_num_bytes` at line 71.
pub fn ruby_alignment_l71_d13_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Ruby method `do_write(io)` at line 75.
pub fn ruby_alignment_l75_d14_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_write', ...args)
}

// Ruby method `BasePrimitive.bit_aligned` at line 80.
pub fn ruby_alignment_l80_d15_baseprimitive_bit_aligned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('BasePrimitive.bit_aligned', ...args)
}

// Ruby method `Primitive.bit_aligned` at line 84.
pub fn ruby_alignment_l84_d16_primitive_bit_aligned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('Primitive.bit_aligned', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2:
// 3: module BinData
// 4:   # Resets the stream alignment to the next byte.  This is
// 5:   # only useful when using bit-based primitives.
// 6:   #
// 7:   #    class MyRec < BinData::Record
// 8:   #      bit4 :a
// 9:   #      resume_byte_alignment
// 10:   #      bit4 :b
// 11:   #    end
// 12:   #
// 13:   #    MyRec.read("\x12\x34") #=> {"a" => 1, "b" => 3}
// 14:   #
// 15:   class ResumeByteAlignment < BinData::Base
// 16:     def clear?; true; end
// 17:     def assign(val); end
// 18:     def snapshot; nil; end
// 19:     def do_num_bytes; 0; end
// 20:
// 21:     def do_read(io)
// 22:       io.readbytes(0)
// 23:     end
// 24:
// 25:     def do_write(io)
// 26:       io.writebytes("")
// 27:     end
// 28:   end
// 29:
// 30:   # A monkey patch to force byte-aligned primitives to
// 31:   # become bit-aligned.  This allows them to be used at
// 32:   # non byte based boundaries.
// 33:   #
// 34:   #     class BitString < BinData::String
// 35:   #       bit_aligned
// 36:   #     end
// 37:   #
// 38:   #     class MyRecord < BinData::Record
// 39:   #       bit4       :preamble
// 40:   #       bit_string :str, length: 2
// 41:   #     end
// 42:   #
// 43:   module BitAligned
// 44:     class BitAlignedIO
// 45:       def initialize(io)
// 46:         @io = io
// 47:       end
// 48:
// 49:       def binary_string(str)
// 50:         str.to_s.dup.force_encoding(Encoding::BINARY)
// 51:       end
// 52:
// 53:       def readbytes(n)
// 54:         n.times.inject(binary_string("")) do |bytes, _|
// 55:           bytes + @io.readbits(8, :big).chr
// 56:         end
// 57:       end
// 58:       def writebytes(str)
// 59:         str.each_byte { |v| @io.writebits(v, 8, :big) }
// 60:       end
// 61:     end
// 62:
// 63:     def bit_aligned?
// 64:       true
// 65:     end
// 66:
// 67:     def do_read(io)
// 68:       super(BitAlignedIO.new(io))
// 69:     end
// 70:
// 71:     def do_num_bytes
// 72:       super.to_f
// 73:     end
// 74:
// 75:     def do_write(io)
// 76:       super(BitAlignedIO.new(io))
// 77:     end
// 78:   end
// 79:
// 80:   def BasePrimitive.bit_aligned
// 81:     include BitAligned
// 82:   end
// 83:
// 84:   def Primitive.bit_aligned
// 85:     fail "'bit_aligned' is not supported for BinData::Primitives"
// 86:   end
// 87: end
