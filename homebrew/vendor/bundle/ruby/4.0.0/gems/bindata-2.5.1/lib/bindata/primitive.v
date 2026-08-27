module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/primitive.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize_instance` at line 71.
pub fn ruby_primitive_l71_d1_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_instance', ...args)
}

// Ruby method `respond_to?(symbol, include_private = false) # :nodoc:` at line 76.
pub fn ruby_primitive_l76_d2_respond_to(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_to?', ...args)
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 80.
pub fn ruby_primitive_l80_d3_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby method `assign(val)` at line 88.
pub fn ruby_primitive_l88_d4_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `debug_name_of(child) # :nodoc:` at line 94.
pub fn ruby_primitive_l94_d5_debug_name_of(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('debug_name_of', ...args)
}

// Ruby method `do_write(io)` at line 98.
pub fn ruby_primitive_l98_d6_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_write', ...args)
}

// Ruby method `do_num_bytes` at line 103.
pub fn ruby_primitive_l103_d7_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Ruby method `sensible_default` at line 111.
pub fn ruby_primitive_l111_d8_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sensible_default', ...args)
}

// Ruby method `read_and_return_value(io)` at line 115.
pub fn ruby_primitive_l115_d9_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_and_return_value', ...args)
}

// Ruby method `get` at line 125.
pub fn ruby_primitive_l125_d10_get(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get', ...args)
}

// Ruby method `set(v)` at line 130.
pub fn ruby_primitive_l130_d11_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set', ...args)
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 139.
pub fn ruby_primitive_l139_d12_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sanitize_parameters!', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2: require 'bindata/dsl'
// 3: require 'bindata/struct'
// 4:
// 5: module BinData
// 6:   # A Primitive is a declarative way to define a new BinData data type.
// 7:   # The data type must contain a primitive value only, i.e numbers or strings.
// 8:   # For new data types that contain multiple values see BinData::Record.
// 9:   #
// 10:   # To define a new data type, set fields as if for Record and add a
// 11:   # #get and #set method to extract / convert the data between the fields
// 12:   # and the #value of the object.
// 13:   #
// 14:   #    require 'bindata'
// 15:   #
// 16:   #    class PascalString < BinData::Primitive
// 17:   #      uint8  :len,  value: -> { data.length }
// 18:   #      string :data, read_length: :len
// 19:   #
// 20:   #      def get
// 21:   #        self.data
// 22:   #      end
// 23:   #
// 24:   #      def set(v)
// 25:   #        self.data = v
// 26:   #      end
// 27:   #    end
// 28:   #
// 29:   #    ps = PascalString.new(initial_value: "hello")
// 30:   #    ps.to_binary_s #=> "\005hello"
// 31:   #    ps.read("\003abcde")
// 32:   #    ps #=> "abc"
// 33:   #
// 34:   #    # Unsigned 24 bit big endian integer
// 35:   #    class Uint24be < BinData::Primitive
// 36:   #      uint8 :byte1
// 37:   #      uint8 :byte2
// 38:   #      uint8 :byte3
// 39:   #
// 40:   #      def get
// 41:   #        (self.byte1 << 16) | (self.byte2 << 8) | self.byte3
// 42:   #      end
// 43:   #
// 44:   #      def set(v)
// 45:   #        v = 0 if v < 0
// 46:   #        v = 0xffffff if v > 0xffffff
// 47:   #
// 48:   #        self.byte1 = (v >> 16) & 0xff
// 49:   #        self.byte2 = (v >>  8) & 0xff
// 50:   #        self.byte3 =  v        & 0xff
// 51:   #      end
// 52:   #    end
// 53:   #
// 54:   #    u24 = Uint24be.new
// 55:   #    u24.read("\x12\x34\x56")
// 56:   #    "0x%x" % u24 #=> 0x123456
// 57:   #
// 58:   # == Parameters
// 59:   #
// 60:   # Primitive objects accept all the parameters that BinData::BasePrimitive do.
// 61:   #
// 62:   class Primitive < BasePrimitive
// 63:     extend DSLMixin
// 64:
// 65:     unregister_self
// 66:     dsl_parser    :primitive
// 67:     arg_processor :primitive
// 68:
// 69:     mandatory_parameter :struct_params
// 70:
// 71:     def initialize_instance
// 72:       super
// 73:       @struct = BinData::Struct.new(get_parameter(:struct_params), self)
// 74:     end
// 75:
// 76:     def respond_to?(symbol, include_private = false) # :nodoc:
// 77:       @struct.respond_to?(symbol, include_private) || super
// 78:     end
// 79:
// 80:     def method_missing(symbol, *args, &block) # :nodoc:
// 81:       if @struct.respond_to?(symbol)
// 82:         @struct.__send__(symbol, *args, &block)
// 83:       else
// 84:         super
// 85:       end
// 86:     end
// 87:
// 88:     def assign(val)
// 89:       super(val)
// 90:       set(_value)
// 91:       @value = get
// 92:     end
// 93:
// 94:     def debug_name_of(child) # :nodoc:
// 95:       debug_name + "-internal-"
// 96:     end
// 97:
// 98:     def do_write(io)
// 99:       set(_value)
// 100:       @struct.do_write(io)
// 101:     end
// 102:
// 103:     def do_num_bytes
// 104:       set(_value)
// 105:       @struct.do_num_bytes
// 106:     end
// 107:
// 108:     #---------------
// 109:     private
// 110:
// 111:     def sensible_default
// 112:       get
// 113:     end
// 114:
// 115:     def read_and_return_value(io)
// 116:       @struct.do_read(io)
// 117:       get
// 118:     end
// 119:
// 120:     ###########################################################################
// 121:     # To be implemented by subclasses
// 122:
// 123:     # Extracts the value for this data object from the fields of the
// 124:     # internal struct.
// 125:     def get
// 126:       raise NotImplementedError
// 127:     end
// 128:
// 129:     # Sets the fields of the internal struct to represent +v+.
// 130:     def set(v)
// 131:       raise NotImplementedError
// 132:     end
// 133:
// 134:     # To be implemented by subclasses
// 135:     ###########################################################################
// 136:   end
// 137:
// 138:   class PrimitiveArgProcessor < BaseArgProcessor
// 139:     def sanitize_parameters!(obj_class, params)
// 140:       params[:struct_params] = params.create_sanitized_params(obj_class.dsl_params, BinData::Struct)
// 141:     end
// 142:   end
// 143: end
