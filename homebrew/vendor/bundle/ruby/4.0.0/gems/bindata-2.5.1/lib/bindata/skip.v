module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/skip.rb`.
// The original source is retained below until every stub has a typed V body.
pub type SkipValidatorFn = fn(mut IORead) !

pub struct FastSearch {
pub:
	pattern string
	offset  int
}

@[heap]
pub struct SkipObject {
mut:
	base               &BaseObject
	cached_skip_length int
	has_cached_length  bool
	validator          SkipValidatorFn = unsafe { nil }
	has_validator      bool
	fast_search        ?FastSearch
}

@[heap]
pub struct SkipReadaheadIO {
mut:
	chain &IOChain
	mark  int
}

const skip_search_size = 100_000

fn skip_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_bindata_skip(parameters map[string]brew_runtime.Value) &SkipObject {
	return &SkipObject{
		base: new_base_object('BinData::Skip', normalized_base_parameters(parameters))
	}
}

pub fn (mut object SkipObject) set_validator(callback SkipValidatorFn, fast_search ?FastSearch) {
	object.validator = callback
	object.has_validator = true
	object.fast_search = fast_search
}

fn skip_object_value(object &SkipObject) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::Skip'
		repr: ''
		map_data: object.base.parameters
		attributes: {
			'skip_object_address': u64(voidptr(object)).str()
		}
	}
}

pub fn skip_boundary_value(object &SkipObject) brew_runtime.Value {
	return skip_object_value(object)
}

fn skip_object_from_value(value brew_runtime.Value) &SkipObject {
	if address := value.attributes['skip_object_address'] {
		return unsafe { &SkipObject(voidptr(address.u64())) }
	}
	mut base := base_object_from_value(value)
	return &SkipObject{
		base: base
	}
}

fn skip_abs_offset(object &SkipObject) int {
	return (object.base.parent.attributes['abs_offset'] or { object.base.parent.attributes['rel_offset'] or { '0' } }).int()
}

pub fn (object &SkipObject) skip_length() int {
	if length := object.base.parameters['length'] {
		return int(length.as_int() or { panic('length must evaluate to an integer') })
	}
	if offset := object.base.parameters['to_abs_offset'] {
		return int(offset.as_int() or { panic('to_abs_offset must evaluate to an integer') }) - skip_abs_offset(object)
	}
	return if object.has_cached_length { object.cached_skip_length } else { 0 }
}

pub fn (object &SkipObject) binary_string() !string {
	length := object.skip_length()
	if length < 0 {
		return error('${object.base.type_name} attempted to seek backwards by ${-length} bytes')
	}
	return '\0'.repeat(length)
}

pub fn (mut object SkipObject) read(mut reader IORead) !string {
	if 'until_valid' in object.base.parameters {
		return object.read_until_valid(mut reader)!
	}
	length := object.skip_length()
	if length < 0 {
		return error('${object.base.type_name} attempted to seek backwards by ${-length} bytes')
	}
	reader.skipbytes(length)!
	return ''
}

fn seek_skip_position(mut reader IORead, position int) ! {
	reader.seek_to_abs_offset(position)!
}

fn find_fast_search(mut reader IORead, search FastSearch) !int {
	mut buffer := []u8{}
	mut position := search.offset
	reader.skipbytes(search.offset)!
	for {
		data := reader.io.read(skip_search_size)!
		if data.len == 0 {
			return error('no match')
		}
		buffer << data
		index := buffer.bytestr().index(search.pattern) or { -1 }
		if index >= 0 {
			return position + index - search.offset
		}
		keep := if search.pattern.len > 0 { search.pattern.len - 1 } else { 0 }
		searched_size := if buffer.len > keep { buffer.len - keep } else { 0 }
		if searched_size > 0 {
			buffer.delete_many(0, searched_size)
			position += searched_size
		}
	}
	return error('no match')
}

fn (mut object SkipObject) read_until_valid(mut reader IORead) !string {
	if !object.has_validator {
		return error('until_valid requires a translated validator')
	}
	if !reader.io.seekable() {
		return error('readahead is not supported on unseekable streams')
	}
	start := reader.io.offset()
	mut position := 0
	for {
		seek_skip_position(mut reader, start + position)!
		object.validator(mut reader) or {
			position++
			if search := object.fast_search {
				seek_skip_position(mut reader, start + position)!
				position += find_fast_search(mut reader, search)!
			}
			continue
		}
		break
	}
	seek_skip_position(mut reader, start + position)!
	object.cached_skip_length = position
	object.has_cached_length = true
	return ''
}

pub fn new_skip_readahead(chain &IOChain) !&SkipReadaheadIO {
	if !chain.seekable() {
		return error('readahead is not supported on unseekable streams')
	}
	return &SkipReadaheadIO{
		chain: chain
		mark: chain.offset()
	}
}

pub fn (mut io SkipReadaheadIO) rollback() ! {
	io.chain.seek_abs(io.mark)!
}

fn skip_readahead_value(io &SkipReadaheadIO) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::Skip::ReadaheadIO'
		repr: 'BinData::Skip::ReadaheadIO'
		attributes: {
			'skip_readahead_address': u64(voidptr(io)).str()
		}
	}
}

fn skip_readahead_from_value(value brew_runtime.Value) &SkipReadaheadIO {
	address := value.attributes['skip_readahead_address'] or { panic('expected ReadaheadIO') }
	return unsafe { &SkipReadaheadIO(voidptr(address.u64())) }
}

fn fast_search_value(search FastSearch) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::Skip::FastSearch'
		repr: '${search.pattern}@${search.offset}'
		map_data: {
			'pattern': brew_runtime.string_value(search.pattern)
			'offset':  brew_runtime.int_value(search.offset)
		}
	}
}

fn fast_search_from_value(value brew_runtime.Value) FastSearch {
	return FastSearch{
		pattern: value.map_data['pattern'].as_string()
		offset: int(value.map_data['offset'].int_data)
	}
}

fn fast_search_for_value(value brew_runtime.Value) ?FastSearch {
	pattern := value.attributes['asserted_binary_s'] or { return none }
	return FastSearch{
		pattern: pattern
		offset: (value.attributes['rel_offset'] or { '0' }).int()
	}
}

fn sanitize_skip_parameters(object_class brew_runtime.Value, values map[string]brew_runtime.Value) !map[string]brew_runtime.Value {
	mut result := normalized_base_parameters(values)
	for key, value in object_class.map_data {
		result[key] = value
	}
	mut count := 0
	for key in ['length', 'to_abs_offset', 'until_valid'] {
		if key in result { count++ }
	}
	if count == 0 {
		return error('${object_class.repr} requires :length, :to_abs_offset or :until_valid')
	}
	if count > 1 {
		return error(':length, :to_abs_offset and :until_valid are mutually exclusive')
	}
	for key in ['length', 'to_abs_offset'] {
		if value := result[key] {
			if !sanitize_value_converts_to_integer(value) {
				return error("parameter '${key}' must evaluate to an integer")
			}
		}
	}
	return result
}

// Ruby method `initialize_shared_instance` at line 56.
pub fn ruby_skip_l56_d1_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Skip#initialize_shared_instance requires receiver') }
	return args[0]
}

// Ruby method `value_to_binary_string(_)` at line 66.
pub fn ruby_skip_l66_d2_value_to_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(skip_object_from_value(args[0]).binary_string() or { panic(err) })
}

// Ruby method `read_and_return_value(io)` at line 76.
pub fn ruby_skip_l76_d3_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Skip#read_and_return_value requires IO') }
	mut object := skip_object_from_value(args[0])
	mut reader := io_read_from_value(args[1])
	return brew_runtime.string_value(object.read(mut reader) or { panic(err) })
}

// Ruby method `sensible_default` at line 87.
pub fn ruby_skip_l87_d4_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('')
}

// Ruby method `skip_length` at line 93.
pub fn ruby_skip_l93_d5_skip_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(skip_object_from_value(args[0]).skip_length())
}

// Ruby method `skip_length` at line 100.
pub fn ruby_skip_l100_d6_skip_length(args ...brew_runtime.Value) brew_runtime.Value {
	object := skip_object_from_value(args[0])
	offset := object.base.parameters['to_abs_offset'] or { panic('missing to_abs_offset') }
	return brew_runtime.int_value(offset.int_data - skip_abs_offset(object))
}

// Ruby method `skip_length` at line 107.
pub fn ruby_skip_l107_d7_skip_length(args ...brew_runtime.Value) brew_runtime.Value {
	object := skip_object_from_value(args[0])
	return brew_runtime.int_value(if object.has_cached_length {
		object.cached_skip_length
	} else {
		0
	})
}

// Ruby method `read_and_return_value(io)` at line 111.
pub fn ruby_skip_l111_d8_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_skip_l76_d3_read_and_return_value(...args)
}

// Ruby method `seek_to_pos(pos, io)` at line 137.
pub fn ruby_skip_l137_d9_seek_to_pos(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('seek_to_pos requires position and IO') }
	position := int(args[1].int_data)
	if args[2].type_name == 'BinData::IO::Read' {
		mut reader := io_read_from_value(args[2])
		reader.seek_to_abs_offset(position) or { panic(err) }
	} else {
		mut io := skip_readahead_from_value(args[2])
		io.rollback() or { panic(err) }
		io.chain.skip(position) or { panic(err) }
	}
	return skip_nil_value()
}

// Ruby method `fast_search_for(obj)` at line 145.
pub fn ruby_skip_l145_d10_fast_search_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('fast_search_for requires object') }
	if search := fast_search_for_value(args[1]) {
		return fast_search_value(search)
	}
	return skip_nil_value()
}

// Ruby method `fast_search_for_obj(obj)` at line 155.
pub fn ruby_skip_l155_d11_fast_search_for_obj(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('fast_search_for_obj requires object') }
	if args[1].type_name == 'BinData::Struct' {
		for _, field in args[1].map_data {
			if search := fast_search_for_value(field) {
				return fast_search_value(search)
			}
		}
	} else if search := fast_search_for_value(args[1]) {
		return fast_search_value(search)
	}
	return skip_nil_value()
}

// Ruby method `next_search_index(io, fs)` at line 170.
pub fn ruby_skip_l170_d12_next_search_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('next_search_index requires IO and FastSearch') }
	mut reader := io_read_from_value(args[1])
	return brew_runtime.int_value(find_fast_search(mut reader, fast_search_from_value(args[2])) or { panic(err) })
}

// Ruby method `before_transform` at line 194.
pub fn ruby_skip_l194_d13_before_transform(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ReadaheadIO#before_transform requires receiver') }
	if args[0].type_name == 'BinData::IO::Read' {
		return skip_readahead_value(new_skip_readahead(io_read_from_value(args[0]).io) or { panic(err) })
	}
	mut io := skip_readahead_from_value(args[0])
	if !io.chain.seekable() { panic('readahead is not supported on unseekable streams') }
	io.mark = io.chain.offset()
	return skip_nil_value()
}

// Ruby method `rollback` at line 202.
pub fn ruby_skip_l202_d14_rollback(args ...brew_runtime.Value) brew_runtime.Value {
	mut io := skip_readahead_from_value(args[0])
	io.rollback() or { panic(err) }
	return skip_nil_value()
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 210.
pub fn ruby_skip_l210_d15_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('SkipArgProcessor#sanitize_parameters! requires class and params') }
	object_class := args[args.len - 2]
	params := args.last()
	if params.type_name == 'BinData::SanitizedParameters' {
		mut parameters := sanitized_parameters_from_value(params)
		parameters.values = sanitize_skip_parameters(object_class, parameters.values) or { panic(err) }
		if 'until_valid' in parameters.values {
			parameters.sanitize_object_prototype('until_valid') or { panic(err) }
		}
		return sanitized_parameters_boundary_value(parameters)
	}
	return brew_runtime.map_value(sanitize_skip_parameters(object_class, params.as_map() or { panic(err) }) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2: require 'bindata/dsl'
// 3:
// 4: module BinData
// 5:   # Skip will skip over bytes from the input stream.  If the stream is not
// 6:   # seekable, then the bytes are consumed and discarded.
// 7:   #
// 8:   # When writing, skip will write the appropriate number of zero bytes.
// 9:   #
// 10:   #   require 'bindata'
// 11:   #
// 12:   #   class A < BinData::Record
// 13:   #     skip length: 5
// 14:   #     string :a, read_length: 5
// 15:   #   end
// 16:   #
// 17:   #   obj = A.read("abcdefghij")
// 18:   #   obj.a #=> "fghij"
// 19:   #
// 20:   #
// 21:   #   class B < BinData::Record
// 22:   #     skip do
// 23:   #       string read_length: 2, assert: 'ef'
// 24:   #     end
// 25:   #     string :s, read_length: 5
// 26:   #   end
// 27:   #
// 28:   #   obj = B.read("abcdefghij")
// 29:   #   obj.s #=> "efghi"
// 30:   #
// 31:   #
// 32:   # == Parameters
// 33:   #
// 34:   # Skip objects accept all the params that BinData::BasePrimitive
// 35:   # does, as well as the following:
// 36:   #
// 37:   # <tt>:length</tt>::        The number of bytes to skip.
// 38:   # <tt>:to_abs_offset</tt>:: Skips to the given absolute offset.
// 39:   # <tt>:until_valid</tt>::   Skips until a given byte pattern is matched.
// 40:   #                           This parameter contains a type that will raise
// 41:   #                           a BinData::ValidityError unless an acceptable byte
// 42:   #                           sequence is found.  The type is represented by a
// 43:   #                           Symbol, or if the type is to have params
// 44:   #                           passed to it, then it should be provided as
// 45:   #                           <tt>[type_symbol, hash_params]</tt>.
// 46:   #
// 47:   class Skip < BinData::BasePrimitive
// 48:     extend DSLMixin
// 49:
// 50:     dsl_parser    :skip
// 51:     arg_processor :skip
// 52:
// 53:     optional_parameters :length, :to_abs_offset, :until_valid
// 54:     mutually_exclusive_parameters :length, :to_abs_offset, :until_valid
// 55:
// 56:     def initialize_shared_instance
// 57:       extend SkipLengthPlugin      if has_parameter?(:length)
// 58:       extend SkipToAbsOffsetPlugin if has_parameter?(:to_abs_offset)
// 59:       extend SkipUntilValidPlugin  if has_parameter?(:until_valid)
// 60:       super
// 61:     end
// 62:
// 63:     #---------------
// 64:     private
// 65:
// 66:     def value_to_binary_string(_)
// 67:       len = skip_length
// 68:       if len.negative?
// 69:         raise ArgumentError,
// 70:               "#{debug_name} attempted to seek backwards by #{len.abs} bytes"
// 71:       end
// 72:
// 73:       "\000" * skip_length
// 74:     end
// 75:
// 76:     def read_and_return_value(io)
// 77:       len = skip_length
// 78:       if len.negative?
// 79:         raise ArgumentError,
// 80:               "#{debug_name} attempted to seek backwards by #{len.abs} bytes"
// 81:       end
// 82:
// 83:       io.skipbytes(len)
// 84:       ""
// 85:     end
// 86:
// 87:     def sensible_default
// 88:       ""
// 89:     end
// 90:
// 91:     # Logic for the :length parameter
// 92:     module SkipLengthPlugin
// 93:       def skip_length
// 94:         eval_parameter(:length)
// 95:       end
// 96:     end
// 97:
// 98:     # Logic for the :to_abs_offset parameter
// 99:     module SkipToAbsOffsetPlugin
// 100:       def skip_length
// 101:         eval_parameter(:to_abs_offset) - abs_offset
// 102:       end
// 103:     end
// 104:
// 105:     # Logic for the :until_valid parameter
// 106:     module SkipUntilValidPlugin
// 107:       def skip_length
// 108:         @skip_length ||= 0
// 109:       end
// 110:
// 111:       def read_and_return_value(io)
// 112:         prototype = get_parameter(:until_valid)
// 113:         validator = prototype.instantiate(nil, self)
// 114:         fs = fast_search_for_obj(validator)
// 115:
// 116:         io.transform(ReadaheadIO.new) do |transformed_io, raw_io|
// 117:           pos = 0
// 118:           loop do
// 119:             seek_to_pos(pos, raw_io)
// 120:             validator.clear
// 121:             validator.do_read(transformed_io)
// 122:             break
// 123:           rescue ValidityError
// 124:             pos += 1
// 125:
// 126:             if fs
// 127:               seek_to_pos(pos, raw_io)
// 128:               pos += next_search_index(raw_io, fs)
// 129:             end
// 130:           end
// 131:
// 132:           seek_to_pos(pos, raw_io)
// 133:           @skip_length = pos
// 134:         end
// 135:       end
// 136:
// 137:       def seek_to_pos(pos, io)
// 138:         io.rollback
// 139:         io.skip(pos)
// 140:       end
// 141:
// 142:       # A fast search has a pattern string at a specific offset.
// 143:       FastSearch = ::Struct.new('FastSearch', :pattern, :offset)
// 144:
// 145:       def fast_search_for(obj)
// 146:         if obj.respond_to?(:asserted_binary_s)
// 147:           FastSearch.new(obj.asserted_binary_s, obj.rel_offset)
// 148:         else
// 149:           nil
// 150:         end
// 151:       end
// 152:
// 153:       # If a search object has an +asserted_value+ field then we
// 154:       # perform a faster search for a valid object.
// 155:       def fast_search_for_obj(obj)
// 156:         if BinData::Struct === obj
// 157:           obj.each_pair(true) do |_, field|
// 158:             fs = fast_search_for(field)
// 159:             return fs if fs
// 160:           end
// 161:         elsif BinData::BasePrimitive === obj
// 162:           return fast_search_for(obj)
// 163:         end
// 164:
// 165:         nil
// 166:       end
// 167:
// 168:       SEARCH_SIZE = 100_000
// 169:
// 170:       def next_search_index(io, fs)
// 171:         buffer = binary_string("")
// 172:
// 173:         # start searching at fast_search offset
// 174:         pos = fs.offset
// 175:         io.skip(fs.offset)
// 176:
// 177:         loop do
// 178:           data = io.read(SEARCH_SIZE)
// 179:           raise EOFError, "no match" if data.nil?
// 180:
// 181:           buffer << data
// 182:           index = buffer.index(fs.pattern)
// 183:           if index
// 184:             return pos + index - fs.offset
// 185:           end
// 186:
// 187:           # advance buffer
// 188:           searched = buffer.slice!(0..-fs.pattern.size)
// 189:           pos += searched.size
// 190:         end
// 191:       end
// 192:
// 193:       class ReadaheadIO < BinData::IO::Transform
// 194:         def before_transform
// 195:           if !seekable?
// 196:             raise IOError, "readahead is not supported on unseekable streams"
// 197:           end
// 198:
// 199:           @mark = offset
// 200:         end
// 201:
// 202:         def rollback
// 203:           seek_abs(@mark)
// 204:         end
// 205:       end
// 206:     end
// 207:   end
// 208:
// 209:   class SkipArgProcessor < BaseArgProcessor
// 210:     def sanitize_parameters!(obj_class, params)
// 211:       params.merge!(obj_class.dsl_params)
// 212:
// 213:       unless params.has_at_least_one_of?(:length, :to_abs_offset, :until_valid)
// 214:         raise ArgumentError,
// 215:               "#{obj_class} requires :length, :to_abs_offset or :until_valid"
// 216:       end
// 217:
// 218:       params.must_be_integer(:to_abs_offset, :length)
// 219:       params.sanitize_object_prototype(:until_valid)
// 220:     end
// 221:   end
// 222: end
