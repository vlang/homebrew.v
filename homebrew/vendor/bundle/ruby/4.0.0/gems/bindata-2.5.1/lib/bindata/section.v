module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/section.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize_instance` at line 48.
pub fn ruby_section_l48_d1_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_instance', ...args)
}

// Ruby method `clear?` at line 52.
pub fn ruby_section_l52_d2_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear?', ...args)
}

// Ruby method `assign(val)` at line 56.
pub fn ruby_section_l56_d3_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `snapshot` at line 60.
pub fn ruby_section_l60_d4_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('snapshot', ...args)
}

// Ruby method `respond_to_missing?(symbol, include_all = false) # :nodoc:` at line 64.
pub fn ruby_section_l64_d5_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_to_missing?', ...args)
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 68.
pub fn ruby_section_l68_d6_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby method `do_read(io) # :nodoc:` at line 72.
pub fn ruby_section_l72_d7_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read', ...args)
}

// Ruby method `do_write(io) # :nodoc:` at line 78.
pub fn ruby_section_l78_d8_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_write', ...args)
}

// Ruby method `do_num_bytes # :nodoc:` at line 84.
pub fn ruby_section_l84_d9_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 92.
pub fn ruby_section_l92_d10_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sanitize_parameters!', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base'
// 2: require 'bindata/dsl'
// 3:
// 4: module BinData
// 5:   # A Section is a layer on top of a stream that transforms the underlying
// 6:   # data.  This allows BinData to process a stream that has multiple
// 7:   # encodings.  e.g.  Some data data is compressed or encrypted.
// 8:   #
// 9:   #   require 'bindata'
// 10:   #
// 11:   #   class XorTransform < BinData::IO::Transform
// 12:   #      def initialize(xor)
// 13:   #        super()
// 14:   #        @xor = xor
// 15:   #      end
// 16:   #
// 17:   #      def read(n)
// 18:   #        chain_read(n).bytes.map { |byte| (byte ^ @xor).chr }.join
// 19:   #      end
// 20:   #
// 21:   #      def write(data)
// 22:   #        chain_write(data.bytes.map { |byte| (byte ^ @xor).chr }.join)
// 23:   #      end
// 24:   #   end
// 25:   #
// 26:   #   obj = BinData::Section.new(transform: -> { XorTransform.new(0xff) },
// 27:   #                              type: [:string, read_length: 5])
// 28:   #
// 29:   #   obj.read("\x97\x9A\x93\x93\x90") #=> "hello"
// 30:   #
// 31:   #
// 32:   # == Parameters
// 33:   #
// 34:   # Parameters may be provided at initialisation to control the behaviour of
// 35:   # an object.  These params are:
// 36:   #
// 37:   # <tt>:transform</tt>:: A callable that returns a new BinData::IO::Transform.
// 38:   # <tt>:type</tt>::      The single type inside the buffer.  Use a struct if
// 39:   #                       multiple fields are required.
// 40:   class Section < BinData::Base
// 41:     extend DSLMixin
// 42:
// 43:     dsl_parser    :section
// 44:     arg_processor :section
// 45:
// 46:     mandatory_parameters :transform, :type
// 47:
// 48:     def initialize_instance
// 49:       @type = get_parameter(:type).instantiate(nil, self)
// 50:     end
// 51:
// 52:     def clear?
// 53:       @type.clear?
// 54:     end
// 55:
// 56:     def assign(val)
// 57:       @type.assign(val)
// 58:     end
// 59:
// 60:     def snapshot
// 61:       @type.snapshot
// 62:     end
// 63:
// 64:     def respond_to_missing?(symbol, include_all = false) # :nodoc:
// 65:       @type.respond_to?(symbol, include_all) || super
// 66:     end
// 67:
// 68:     def method_missing(symbol, *args, &block) # :nodoc:
// 69:       @type.__send__(symbol, *args, &block)
// 70:     end
// 71:
// 72:     def do_read(io) # :nodoc:
// 73:       io.transform(eval_parameter(:transform)) do |transformed_io, _raw_io|
// 74:         @type.do_read(transformed_io)
// 75:       end
// 76:     end
// 77:
// 78:     def do_write(io) # :nodoc:
// 79:       io.transform(eval_parameter(:transform)) do |transformed_io, _raw_io|
// 80:         @type.do_write(transformed_io)
// 81:       end
// 82:     end
// 83:
// 84:     def do_num_bytes # :nodoc:
// 85:       to_binary_s.size
// 86:     end
// 87:   end
// 88:
// 89:   class SectionArgProcessor < BaseArgProcessor
// 90:     include MultiFieldArgSeparator
// 91:
// 92:     def sanitize_parameters!(obj_class, params)
// 93:       params.merge!(obj_class.dsl_params)
// 94:       params.sanitize_object_prototype(:type)
// 95:     end
// 96:   end
// 97: end
