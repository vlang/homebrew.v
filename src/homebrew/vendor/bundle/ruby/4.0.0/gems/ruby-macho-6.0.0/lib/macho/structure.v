module macho

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/structure.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(*args)` at line 75.
pub fn ruby_structure_l75_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_h` at line 82.
pub fn ruby_structure_l82_d2_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby attr_reader `attr_reader :min_args` at line 92.
pub fn ruby_structure_l92_d3_min_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('min_args', ...args)
}

// Ruby method `new_from_bin(endianness, bin)` at line 98.
pub fn ruby_structure_l98_d4_new_from_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_from_bin', ...args)
}

// Ruby method `format` at line 104.
pub fn ruby_structure_l104_d5_format(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('format', ...args)
}

// Ruby method `bytesize` at line 108.
pub fn ruby_structure_l108_d6_bytesize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bytesize', ...args)
}

// Ruby method `inherited(subclass) # rubocop:disable Lint/MissingSuper` at line 116.
pub fn ruby_structure_l116_d7_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inherited', ...args)
}

// Ruby method `field(name, type, **options)` at line 144.
pub fn ruby_structure_l144_d8_field(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('field', ...args)
}

// Ruby method `def_class_reader(name, type, idx)` at line 196.
pub fn ruby_structure_l196_d9_def_class_reader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('def_class_reader', ...args)
}

// Ruby define_method `define_method(name) do` at line 199.
pub fn ruby_structure_l199_d10_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby define_method `define_method(name) do` at line 206.
pub fn ruby_structure_l206_d11_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby define_method `define_method(name) do` at line 213.
pub fn ruby_structure_l213_d12_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `def_mask_reader(name, idx, mask)` at line 227.
pub fn ruby_structure_l227_d13_def_mask_reader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('def_mask_reader', ...args)
}

// Ruby define_method `define_method(name) do` at line 228.
pub fn ruby_structure_l228_d14_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `def_unpack_reader(name, idx, unpack)` at line 241.
pub fn ruby_structure_l241_d15_def_unpack_reader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('def_unpack_reader', ...args)
}

// Ruby define_method `define_method(name) do` at line 242.
pub fn ruby_structure_l242_d16_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `def_default_reader(name, idx, default)` at line 255.
pub fn ruby_structure_l255_d17_def_default_reader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('def_default_reader', ...args)
}

// Ruby define_method `define_method(name) do` at line 256.
pub fn ruby_structure_l256_d18_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `def_reader(name, idx)` at line 268.
pub fn ruby_structure_l268_d19_def_reader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('def_reader', ...args)
}

// Ruby define_method `define_method(name) do` at line 269.
pub fn ruby_structure_l269_d20_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `def_to_s(name)` at line 277.
pub fn ruby_structure_l277_d21_def_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('def_to_s', ...args)
}

// Ruby define_method `define_method(:to_s) do` at line 278.
pub fn ruby_structure_l278_d22_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # A general purpose pseudo-structure. Described in detail in machostructure-dsl-docs.md.
// 5:   # @abstract
// 6:   class MachOStructure
// 7:     # Constants used for parsing MachOStructure fields
// 8:     module Fields
// 9:       # 1. All fields with empty strings and zeros aren't used
// 10:       #    to calculate the format and sizeof variables.
// 11:       # 2. All fields with nil should provide those values manually
// 12:       #    via the :size parameter.
// 13:
// 14:       # association of field types to byte size
// 15:       # @api private
// 16:       BYTE_SIZE = {
// 17:         # Binary slices
// 18:         :string => nil,
// 19:         :null_padded_string => nil,
// 20:         :int32 => 4,
// 21:         :uint32 => 4,
// 22:         :uint64 => 8,
// 23:         # Classes
// 24:         :view => 0,
// 25:         :lcstr => 4,
// 26:         :two_level_hints_table => 0,
// 27:         :tool_entries => 4,
// 28:       }.freeze
// 29:
// 30:       # association of field types with ruby format codes
// 31:       # Binary format codes can be found here:
// 32:       # https://docs.ruby-lang.org/en/2.6.0/String.html#method-i-unpack
// 33:       #
// 34:       # The equals sign is used to manually change endianness using
// 35:       # the Utils#specialize_format() method.
// 36:       # @api private
// 37:       FORMAT_CODE = {
// 38:         # Binary slices
// 39:         :string => "a",
// 40:         :null_padded_string => "Z",
// 41:         :int32 => "l=",
// 42:         :uint32 => "L=",
// 43:         :uint64 => "Q=",
// 44:         # Classes
// 45:         :view => "",
// 46:         :lcstr => "L=",
// 47:         :two_level_hints_table => "",
// 48:         :tool_entries => "L=",
// 49:       }.freeze
// 50:
// 51:       # A list of classes that must get initialized
// 52:       # To add a new class append it here and add the init method to the def_class_reader method
// 53:       # @api private
// 54:       CLASSES_TO_INIT = %i[lcstr tool_entries two_level_hints_table].freeze
// 55:
// 56:       # A list of fields that don't require arguments in the initializer
// 57:       # Used to calculate MachOStructure#min_args
// 58:       # @api private
// 59:       NO_ARG_REQUIRED = %i[two_level_hints_table].freeze
// 60:     end
// 61:
// 62:     # map of field names to indices
// 63:     @field_idxs = {}
// 64:
// 65:     # array of fields sizes
// 66:     @size_list = []
// 67:
// 68:     # array of field format codes
// 69:     @fmt_list = []
// 70:
// 71:     # minimum number of required arguments
// 72:     @min_args = 0
// 73:
// 74:     # @param args [Array[Value]] list of field parameters
// 75:     def initialize(*args)
// 76:       raise ArgumentError, "Invalid number of arguments" if args.size < self.class.min_args
// 77:
// 78:       @values = args
// 79:     end
// 80:
// 81:     # @return [Hash] a hash representation of this {MachOStructure}.
// 82:     def to_h
// 83:       {
// 84:         "structure" => {
// 85:           "format" => self.class.format,
// 86:           "bytesize" => self.class.bytesize,
// 87:         },
// 88:       }
// 89:     end
// 90:
// 91:     class << self
// 92:       attr_reader :min_args
// 93:
// 94:       # @param endianness [Symbol] either `:big` or `:little`
// 95:       # @param bin [String] the string to be unpacked into the new structure
// 96:       # @return [MachO::MachOStructure] the resulting structure
// 97:       # @api private
// 98:       def new_from_bin(endianness, bin)
// 99:         format = Utils.specialize_format(self.format, endianness)
// 100:
// 101:         new(*bin.unpack(format))
// 102:       end
// 103:
// 104:       def format
// 105:         @format ||= @fmt_list.join
// 106:       end
// 107:
// 108:       def bytesize
// 109:         @bytesize ||= @size_list.sum
// 110:       end
// 111:
// 112:       private
// 113:
// 114:       # @param subclass [Class] subclass type
// 115:       # @api private
// 116:       def inherited(subclass) # rubocop:disable Lint/MissingSuper
// 117:         # Clone all class instance variables
// 118:         field_idxs = @field_idxs.dup
// 119:         size_list = @size_list.dup
// 120:         fmt_list = @fmt_list.dup
// 121:         min_args = @min_args.dup
// 122:
// 123:         # Add those values to the inheriting class
// 124:         subclass.class_eval do
// 125:           @field_idxs = field_idxs
// 126:           @size_list = size_list
// 127:           @fmt_list = fmt_list
// 128:           @min_args = min_args
// 129:         end
// 130:       end
// 131:
// 132:       # @param name [Symbol] name of internal field
// 133:       # @param type [Symbol] type of field in terms of binary size
// 134:       # @param options [Hash] set of additional options
// 135:       # Expected options
// 136:       #   :size [Integer] size in bytes
// 137:       #   :mask [Integer] bitmask
// 138:       #   :unpack [String] string format
// 139:       #   :default [Value] default value
// 140:       #   :to_s [Boolean] flag for generating #to_s
// 141:       #   :endian [Symbol] optionally specify :big or :little endian
// 142:       #   :padding [Symbol] optionally specify :null padding
// 143:       # @api private
// 144:       def field(name, type, **options)
// 145:         raise ArgumentError, "Invalid field type #{type}" unless Fields::FORMAT_CODE.key?(type)
// 146:
// 147:         # Get field idx for size_list and fmt_list
// 148:         idx = if @field_idxs.key?(name)
// 149:           @field_idxs[name]
// 150:         else
// 151:           @min_args += 1 unless options.key?(:default) || Fields::NO_ARG_REQUIRED.include?(type)
// 152:           @field_idxs[name] = @field_idxs.size
// 153:           @size_list << nil
// 154:           @fmt_list << nil
// 155:           @field_idxs.size - 1
// 156:         end
// 157:
// 158:         # Update string type if padding is specified
// 159:         type = :null_padded_string if type == :string && options[:padding] == :null
// 160:
// 161:         # Add to size_list and fmt_list
// 162:         @size_list[idx] = Fields::BYTE_SIZE[type] || options[:size]
// 163:         @fmt_list[idx] = if options[:endian]
// 164:           Utils.specialize_format(Fields::FORMAT_CODE[type], options[:endian])
// 165:         else
// 166:           Fields::FORMAT_CODE[type]
// 167:         end
// 168:         @fmt_list[idx] += options[:size].to_s if options.key?(:size)
// 169:
// 170:         # Generate methods
// 171:         if Fields::CLASSES_TO_INIT.include?(type)
// 172:           def_class_reader(name, type, idx)
// 173:         elsif options.key?(:mask)
// 174:           def_mask_reader(name, idx, options[:mask])
// 175:         elsif options.key?(:unpack)
// 176:           def_unpack_reader(name, idx, options[:unpack])
// 177:         elsif options.key?(:default)
// 178:           def_default_reader(name, idx, options[:default])
// 179:         else
// 180:           def_reader(name, idx)
// 181:         end
// 182:
// 183:         def_to_s(name) if options[:to_s]
// 184:       end
// 185:
// 186:       #
// 187:       # Method Generators
// 188:       #
// 189:
// 190:       # Generates a reader method for classes that need to be initialized.
// 191:       # These classes are defined in the Fields::CLASSES_TO_INIT array.
// 192:       # @param name [Symbol] name of internal field
// 193:       # @param type [Symbol] type of field in terms of binary size
// 194:       # @param idx [Integer] the index of the field value in the @values array
// 195:       # @api private
// 196:       def def_class_reader(name, type, idx)
// 197:         case type
// 198:         when :lcstr
// 199:           define_method(name) do
// 200:             instance_variable_defined?("@#{name}") ||
// 201:               instance_variable_set("@#{name}", LoadCommands::LoadCommand::LCStr.new(self, @values[idx]))
// 202:
// 203:             instance_variable_get("@#{name}")
// 204:           end
// 205:         when :two_level_hints_table
// 206:           define_method(name) do
// 207:             instance_variable_defined?("@#{name}") ||
// 208:               instance_variable_set("@#{name}", LoadCommands::TwolevelHintsCommand::TwolevelHintsTable.new(view, htoffset, nhints))
// 209:
// 210:             instance_variable_get("@#{name}")
// 211:           end
// 212:         when :tool_entries
// 213:           define_method(name) do
// 214:             instance_variable_defined?("@#{name}") ||
// 215:               instance_variable_set("@#{name}", LoadCommands::BuildVersionCommand::ToolEntries.new(view, @values[idx]))
// 216:
// 217:             instance_variable_get("@#{name}")
// 218:           end
// 219:         end
// 220:       end
// 221:
// 222:       # Generates a reader method for fields that need to be bitmasked.
// 223:       # @param name [Symbol] name of internal field
// 224:       # @param idx [Integer] the index of the field value in the @values array
// 225:       # @param mask [Integer] the bitmask
// 226:       # @api private
// 227:       def def_mask_reader(name, idx, mask)
// 228:         define_method(name) do
// 229:           instance_variable_defined?("@#{name}") ||
// 230:             instance_variable_set("@#{name}", @values[idx] & ~mask)
// 231:
// 232:           instance_variable_get("@#{name}")
// 233:         end
// 234:       end
// 235:
// 236:       # Generates a reader method for fields that need further unpacking.
// 237:       # @param name [Symbol] name of internal field
// 238:       # @param idx [Integer] the index of the field value in the @values array
// 239:       # @param unpack [String] the format code used for further binary unpacking
// 240:       # @api private
// 241:       def def_unpack_reader(name, idx, unpack)
// 242:         define_method(name) do
// 243:           instance_variable_defined?("@#{name}") ||
// 244:             instance_variable_set("@#{name}", @values[idx].unpack(unpack))
// 245:
// 246:           instance_variable_get("@#{name}")
// 247:         end
// 248:       end
// 249:
// 250:       # Generates a reader method for fields that have default values.
// 251:       # @param name [Symbol] name of internal field
// 252:       # @param idx [Integer] the index of the field value in the @values array
// 253:       # @param default [Value] the default value
// 254:       # @api private
// 255:       def def_default_reader(name, idx, default)
// 256:         define_method(name) do
// 257:           instance_variable_defined?("@#{name}") ||
// 258:             instance_variable_set("@#{name}", @values.size > idx ? @values[idx] : default)
// 259:
// 260:           instance_variable_get("@#{name}")
// 261:         end
// 262:       end
// 263:
// 264:       # Generates an attr_reader like method for a field.
// 265:       # @param name [Symbol] name of internal field
// 266:       # @param idx [Integer] the index of the field value in the @values array
// 267:       # @api private
// 268:       def def_reader(name, idx)
// 269:         define_method(name) do
// 270:           @values[idx]
// 271:         end
// 272:       end
// 273:
// 274:       # Generates the to_s method based on the named field.
// 275:       # @param name [Symbol] name of the field
// 276:       # @api private
// 277:       def def_to_s(name)
// 278:         define_method(:to_s) do
// 279:           send(name).to_s
// 280:         end
// 281:       end
// 282:     end
// 283:   end
// 284: end
