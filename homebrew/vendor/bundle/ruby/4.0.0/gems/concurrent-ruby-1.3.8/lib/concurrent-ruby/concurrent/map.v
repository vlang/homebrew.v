module concurrent

import ruby
import math
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/map.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ConcurrentMapOptions {
pub:
	initial_capacity int
	load_factor      f64
	load_factor_set  bool
}

pub struct ConcurrentMapEntry {
pub:
	key   ruby.Value
	value ruby.Value
}

pub struct ConcurrentMapLookup {
pub:
	found bool
	value ruby.Value
}

pub type ConcurrentMapDefault = fn(&ConcurrentMap, ruby.Value) !ruby.Value

pub type ConcurrentMapEach = fn(ruby.Value, ruby.Value)

@[heap]
pub struct ConcurrentMap {
pub:
	options     ConcurrentMapOptions
	has_default bool
mut:
	lock         sync.RwMutex
	entries      []ConcurrentMapEntry
	default_proc ConcurrentMapDefault = no_concurrent_map_default
}

fn concurrent_map_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn no_concurrent_map_default(_ &ConcurrentMap, _ ruby.Value) !ruby.Value {
	return error('no default proc')
}

pub fn validate_concurrent_map_options(options ConcurrentMapOptions) ! {
	if options.initial_capacity < 0 {
		return error(':initial_capacity must be a positive Integer')
	}
	if options.load_factor_set && (options.load_factor <= 0 || options.load_factor > 1) {
		return error(':load_factor must be a number between 0 and 1')
	}
}

pub fn new_concurrent_map(options ConcurrentMapOptions) !&ConcurrentMap {
	validate_concurrent_map_options(options)!
	return &ConcurrentMap{
		options: options
	}
}

pub fn new_concurrent_map_with_default(options ConcurrentMapOptions, default_proc ConcurrentMapDefault) !&ConcurrentMap {
	validate_concurrent_map_options(options)!
	return &ConcurrentMap{
		options: options
		has_default: true
		default_proc: default_proc
	}
}

fn concurrent_map_values_equal(left ruby.Value, right ruby.Value) bool {
	if left.type_name in ['Integer', 'Float'] && right.type_name in ['Integer', 'Float'] {
		left_number := left.as_float() or { return false }
		right_number := right.as_float() or { return false }
		if math.is_nan(left_number) || math.is_nan(right_number) {
			return math.is_nan(left_number) && math.is_nan(right_number)
		}
		return left_number == right_number
	}
	if left_identity := left.attributes['identity'] {
		return right.attributes['identity'] == left_identity
	}
	return left.type_name == right.type_name && left.repr == right.repr
}

fn concurrent_map_values_identical(left ruby.Value, right ruby.Value) bool {
	if left_identity := left.attributes['identity'] {
		return right.attributes['identity'] == left_identity
	}
	// Ruby immediate values have value identity. Generic object boundaries can opt in
	// to stable identity through the translated `identity` attribute above.
	if left.type_name in ['NilClass', 'Bool', 'Integer', 'Float', 'Symbol'] {
		return concurrent_map_values_equal(left, right)
	}
	return false
}

fn (cmap &ConcurrentMap) entry_index(key ruby.Value) int {
	for index, entry in cmap.entries {
		if concurrent_map_values_equal(entry.key, key) {
			return index
		}
	}
	return -1
}

pub fn (mut cmap ConcurrentMap) lookup(key ruby.Value) ConcurrentMapLookup {
	cmap.lock.rlock()
	index := cmap.entry_index(key)
	if index < 0 {
		cmap.lock.runlock()
		return ConcurrentMapLookup{
			value: concurrent_map_nil_value()
		}
	}
	value := cmap.entries[index].value
	cmap.lock.runlock()
	return ConcurrentMapLookup{
		found: true
		value: value
	}
}

pub fn (mut cmap ConcurrentMap) get(key ruby.Value) !ruby.Value {
	lookup := cmap.lookup(key)
	if lookup.found {
		return lookup.value
	}
	if cmap.has_default {
		return cmap.default_proc(cmap, key)
	}
	return concurrent_map_nil_value()
}

pub fn (mut cmap ConcurrentMap) put(key ruby.Value, value ruby.Value) ruby.Value {
	cmap.lock.lock()
	index := cmap.entry_index(key)
	if index >= 0 {
		cmap.entries[index] = ConcurrentMapEntry{
			key: cmap.entries[index].key
			value: value
		}
	} else {
		cmap.entries << ConcurrentMapEntry{
			key: key
			value: value
		}
	}
	cmap.lock.unlock()
	return value
}

pub fn (mut cmap ConcurrentMap) fetch(key ruby.Value, default_value ?ruby.Value) !ruby.Value {
	lookup := cmap.lookup(key)
	if lookup.found {
		return lookup.value
	}
	if value := default_value {
		return value
	}
	return error('key not found')
}

pub fn (mut cmap ConcurrentMap) fetch_or_store(key ruby.Value, default_value ruby.Value) ruby.Value {
	lookup := cmap.lookup(key)
	if lookup.found {
		return lookup.value
	}
	return cmap.put(key, default_value)
}

pub fn (mut cmap ConcurrentMap) put_if_absent(key ruby.Value, value ruby.Value) ConcurrentMapLookup {
	cmap.lock.lock()
	index := cmap.entry_index(key)
	if index >= 0 {
		previous := cmap.entries[index].value
		cmap.lock.unlock()
		return ConcurrentMapLookup{
			found: true
			value: previous
		}
	}
	cmap.entries << ConcurrentMapEntry{
		key: key
		value: value
	}
	cmap.lock.unlock()
	return ConcurrentMapLookup{
		value: concurrent_map_nil_value()
	}
}

pub fn (mut cmap ConcurrentMap) snapshot() []ConcurrentMapEntry {
	cmap.lock.rlock()
	entries := cmap.entries.clone()
	cmap.lock.runlock()
	return entries
}

pub fn (mut cmap ConcurrentMap) contains_value(value ruby.Value) bool {
	return cmap.snapshot().any(concurrent_map_values_identical(it.value, value))
}

pub fn (mut cmap ConcurrentMap) keys() []ruby.Value {
	return cmap.snapshot().map(it.key)
}

pub fn (mut cmap ConcurrentMap) values() []ruby.Value {
	return cmap.snapshot().map(it.value)
}

pub fn (mut cmap ConcurrentMap) each_pair(action ConcurrentMapEach) &ConcurrentMap {
	for entry in cmap.snapshot() {
		action(entry.key, entry.value)
	}
	return cmap
}

pub fn (mut cmap ConcurrentMap) key_for(value ruby.Value) ?ruby.Value {
	for entry in cmap.snapshot() {
		if concurrent_map_values_equal(entry.value, value) {
			return entry.key
		}
	}
	return none
}

pub fn (mut cmap ConcurrentMap) size() int {
	cmap.lock.rlock()
	size := cmap.entries.len
	cmap.lock.runlock()
	return size
}

pub fn (mut cmap ConcurrentMap) copy() &ConcurrentMap {
	mut duplicate := if cmap.has_default {
		new_concurrent_map_with_default(cmap.options, cmap.default_proc) or { panic(err) }
	} else {
		new_concurrent_map(cmap.options) or { panic(err) }
	}
	duplicate.entries = cmap.snapshot()
	return duplicate
}

pub fn (mut cmap ConcurrentMap) populate(entries []ConcurrentMapEntry) &ConcurrentMap {
	for entry in entries {
		cmap.put(entry.key, entry.value)
	}
	return cmap
}

pub fn (mut cmap ConcurrentMap) inspect() string {
	return '#<Concurrent::Map entries=${cmap.size()} default_proc=${cmap.has_default}>'
}

fn concurrent_map_options_from_value(value ruby.Value) ConcurrentMapOptions {
	if value.type_name != 'Hash' {
		return ConcurrentMapOptions{}
	}
	options := value.as_map() or { return ConcurrentMapOptions{} }
	return ConcurrentMapOptions{
		initial_capacity: if 'initial_capacity' in options {
			int(options['initial_capacity'].as_int() or { -1 })} else {
			0}
		load_factor: if 'load_factor' in options {
			options['load_factor'].as_float() or { -1 }} else {
			0}
		load_factor_set: 'load_factor' in options
	}
}

fn concurrent_map_boundary_value(cmap &ConcurrentMap) ruby.Value {
	return ruby.structured_value('Concurrent::Map', '#<Concurrent::Map>', {
		'concurrent_map_address': u64(voidptr(cmap)).str()
	})
}

fn concurrent_map_boundary_receiver(args []ruby.Value) &ConcurrentMap {
	if args.len == 0 {
		panic('Concurrent::Map method requires a receiver')
	}
	address := (args[0].attribute('concurrent_map_address') or {
		panic('${args[0].type_name} has no translated Concurrent::Map state')
	}).u64()
	return unsafe { &ConcurrentMap(voidptr(address)) }
}

fn concurrent_map_entries_value(entries []ConcurrentMapEntry) ruby.Value {
	mut values := []ruby.Value{cap: entries.len}
	for entry in entries {
		values << ruby.array_value([entry.key, entry.value])
	}
	return ruby.array_value(values)
}

fn concurrent_map_entries_from_value(value ruby.Value) []ConcurrentMapEntry {
	if value.type_name == 'Hash' {
		values := value.as_map() or { panic(err) }
		mut entries := []ConcurrentMapEntry{cap: values.len}
		for key, entry_value in values {
			entries << ConcurrentMapEntry{
				key: ruby.string_value(key)
				value: entry_value
			}
		}
		return entries
	}
	return (value.as_array() or { panic(err) }).map(fn (pair ruby.Value) ConcurrentMapEntry {
		values := pair.as_array() or { panic(err) }
		if values.len < 2 {
			panic('map pair requires key and value')
		}
		return ConcurrentMapEntry{
			key: values[0]
			value: values[1]
		}
	})
}

// Ruby method `initialize(options = nil, &default_proc)` at line 133.
pub fn ruby_map_l133_d1_initialize(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 {
		concurrent_map_options_from_value(args[0])
	} else {
		ConcurrentMapOptions{}
	}
	return concurrent_map_boundary_value(new_concurrent_map(options) or { panic(err) })
}

// Ruby method `[](key)` at line 147.
pub fn ruby_map_l147_d2_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Concurrent::Map#[] requires a key')
	}
	mut cmap := concurrent_map_boundary_receiver(args)
	return cmap.get(args[1]) or { panic(err) }
}

// Ruby alias_method `alias_method :get, :[]` at line 162.
pub fn ruby_map_l162_d3_get(args ...ruby.Value) ruby.Value {
	return ruby_map_l147_d2_anonymous(...args)
}

// Ruby alias_method `alias_method :put, :[]=` at line 163.
pub fn ruby_map_l163_d4_put(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Concurrent::Map#put requires a key and value')
	}
	mut cmap := concurrent_map_boundary_receiver(args)
	return cmap.put(args[1], args[2])
}

// Ruby method `fetch(key, default_value = NULL)` at line 183.
pub fn ruby_map_l183_d5_fetch(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Concurrent::Map#fetch requires a key')
	}
	mut cmap := concurrent_map_boundary_receiver(args)
	default_value := if args.len > 2 { ?ruby.Value(args[2]) } else { none }
	return cmap.fetch(args[1], default_value) or { panic('KeyError: ${err}') }
}

// Ruby method `fetch_or_store(key, default_value = NULL)` at line 205.
pub fn ruby_map_l205_d6_fetch_or_store(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('KeyError: key not found')
	}
	mut cmap := concurrent_map_boundary_receiver(args)
	return cmap.fetch_or_store(args[1], args[2])
}

// Ruby method `put_if_absent(key, value)` at line 215.
pub fn ruby_map_l215_d7_put_if_absent(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Concurrent::Map#put_if_absent requires a key and value')
	}
	mut cmap := concurrent_map_boundary_receiver(args)
	lookup := cmap.put_if_absent(args[1], args[2])
	return if lookup.found { lookup.value } else { concurrent_map_nil_value() }
}

// Ruby method `value?(value)` at line 227.
pub fn ruby_map_l227_d8_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Concurrent::Map#value? requires a value')
	}
	mut cmap := concurrent_map_boundary_receiver(args)
	return ruby.bool_value(cmap.contains_value(args[1]))
}

// Ruby method `keys` at line 236.
pub fn ruby_map_l236_d9_keys(args ...ruby.Value) ruby.Value {
	mut cmap := concurrent_map_boundary_receiver(args)
	return ruby.array_value(cmap.keys())
}

// Ruby method `values` at line 244.
pub fn ruby_map_l244_d10_values(args ...ruby.Value) ruby.Value {
	mut cmap := concurrent_map_boundary_receiver(args)
	return ruby.array_value(cmap.values())
}

// Ruby method `each_key` at line 255.
pub fn ruby_map_l255_d11_each_key(args ...ruby.Value) ruby.Value {
	return ruby_map_l236_d9_keys(...args)
}

// Ruby method `each_value` at line 264.
pub fn ruby_map_l264_d12_each_value(args ...ruby.Value) ruby.Value {
	return ruby_map_l244_d10_values(...args)
}

// Ruby method `each_pair` at line 274.
pub fn ruby_map_l274_d13_each_pair(args ...ruby.Value) ruby.Value {
	mut cmap := concurrent_map_boundary_receiver(args)
	return concurrent_map_entries_value(cmap.snapshot())
}

// Ruby alias_method `alias_method :each, :each_pair unless method_defined?(:each)` at line 279.
pub fn ruby_map_l279_d14_each(args ...ruby.Value) ruby.Value {
	return ruby_map_l274_d13_each_pair(...args)
}

// Ruby method `key(value)` at line 284.
pub fn ruby_map_l284_d15_key(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Concurrent::Map#key requires a value')
	}
	mut cmap := concurrent_map_boundary_receiver(args)
	return cmap.key_for(args[1]) or { concurrent_map_nil_value() }
}

// Ruby method `empty?` at line 291.
pub fn ruby_map_l291_d16_empty(args ...ruby.Value) ruby.Value {
	mut cmap := concurrent_map_boundary_receiver(args)
	return ruby.bool_value(cmap.size() == 0)
}

// Ruby method `size` at line 298.
pub fn ruby_map_l298_d17_size(args ...ruby.Value) ruby.Value {
	mut cmap := concurrent_map_boundary_receiver(args)
	return ruby.int_value(cmap.size())
}

// Ruby method `marshal_dump` at line 305.
pub fn ruby_map_l305_d18_marshal_dump(args ...ruby.Value) ruby.Value {
	mut cmap := concurrent_map_boundary_receiver(args)
	if cmap.has_default {
		panic("TypeError: can't dump hash with default proc")
	}
	return concurrent_map_entries_value(cmap.snapshot())
}

// Ruby method `marshal_load(hash)` at line 313.
pub fn ruby_map_l313_d19_marshal_load(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Concurrent::Map#marshal_load requires entries')
	}
	mut cmap := concurrent_map_boundary_receiver(args)
	cmap.lock.lock()
	cmap.entries.clear()
	cmap.lock.unlock()
	cmap.populate(concurrent_map_entries_from_value(args[1]))
	return args[0]
}

// Ruby method `inspect` at line 321.
pub fn ruby_map_l321_d20_inspect(args ...ruby.Value) ruby.Value {
	mut cmap := concurrent_map_boundary_receiver(args)
	return ruby.string_value(cmap.inspect())
}

// Ruby method `raise_fetch_no_key` at line 327.
pub fn ruby_map_l327_d21_raise_fetch_no_key(args ...ruby.Value) ruby.Value {
	panic('KeyError: key not found')
}

// Ruby method `initialize_copy(other)` at line 331.
pub fn ruby_map_l331_d22_initialize_copy(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Concurrent::Map#initialize_copy requires a source map')
	}
	mut source := concurrent_map_boundary_receiver(if args.len > 1 { args[1..] } else { args })
	return concurrent_map_boundary_value(source.copy())
}

// Ruby method `populate_from(hash)` at line 336.
pub fn ruby_map_l336_d23_populate_from(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Concurrent::Map#populate_from requires entries')
	}
	mut cmap := concurrent_map_boundary_receiver(args)
	cmap.populate(concurrent_map_entries_from_value(args[1]))
	return args[0]
}

// Ruby method `validate_options_hash!(options)` at line 341.
pub fn ruby_map_l341_d24_validate_options_hash(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[args.len - 1].type_name != 'Hash' {
		panic('Concurrent::Map#validate_options_hash! requires a Hash')
	}
	validate_concurrent_map_options(concurrent_map_options_from_value(args[args.len - 1])) or {
		panic('ArgumentError: ${err}')
	}
	return concurrent_map_nil_value()
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'concurrent/constants'
// 3: require 'concurrent/utility/engine'
// 4:
// 5: module Concurrent
// 6:   # @!visibility private
// 7:   module Collection
// 8:
// 9:     # @!visibility private
// 10:     MapImplementation = case
// 11:                         when Concurrent.on_jruby?
// 12:                           require 'concurrent/utility/native_extension_loader'
// 13:                           # noinspection RubyResolve
// 14:                           JRubyMapBackend
// 15:                         when Concurrent.on_cruby?
// 16:                           require 'concurrent/collection/map/mri_map_backend'
// 17:                           MriMapBackend
// 18:                         when Concurrent.on_truffleruby?
// 19:                           if defined?(::TruffleRuby::ConcurrentMap)
// 20:                             require 'concurrent/collection/map/truffleruby_map_backend'
// 21:                             TruffleRubyMapBackend
// 22:                           else
// 23:                             require 'concurrent/collection/map/synchronized_map_backend'
// 24:                             SynchronizedMapBackend
// 25:                           end
// 26:                         else
// 27:                           warn 'Concurrent::Map: unsupported Ruby engine, using a fully synchronized Concurrent::Map implementation'
// 28:                           require 'concurrent/collection/map/synchronized_map_backend'
// 29:                           SynchronizedMapBackend
// 30:                         end
// 31:   end
// 32:
// 33:   # `Concurrent::Map` is a hash-like object and should have much better performance
// 34:   # characteristics, especially under high concurrency, than `Concurrent::Hash`.
// 35:   # However, `Concurrent::Map `is not strictly semantically equivalent to a ruby `Hash`
// 36:   # -- for instance, it does not necessarily retain ordering by insertion time as `Hash`
// 37:   # does. For most uses it should do fine though, and we recommend you consider
// 38:   # `Concurrent::Map` instead of `Concurrent::Hash` for your concurrency-safe hash needs.
// 39:   class Map < Collection::MapImplementation
// 40:
// 41:     # @!macro map.atomic_method
// 42:     #   This method is atomic.
// 43:
// 44:     # @!macro map.atomic_method_with_block
// 45:     #   This method is atomic.
// 46:     #   @note Atomic methods taking a block do not allow the `self` instance
// 47:     #     to be used within the block. Doing so will cause a deadlock.
// 48:
// 49:     # @!method []=(key, value)
// 50:     #   Set a value with key
// 51:     #   @param [Object] key
// 52:     #   @param [Object] value
// 53:     #   @return [Object] the new value
// 54:
// 55:     # @!method compute_if_absent(key)
// 56:     #   Compute and store new value for key if the key is absent.
// 57:     #   @param [Object] key
// 58:     #   @yield new value
// 59:     #   @yieldreturn [Object] new value
// 60:     #   @return [Object] new value or current value
// 61:     #   @!macro map.atomic_method_with_block
// 62:
// 63:     # @!method compute_if_present(key)
// 64:     #   Compute and store new value for key if the key is present.
// 65:     #   @param [Object] key
// 66:     #   @yield new value
// 67:     #   @yieldparam old_value [Object]
// 68:     #   @yieldreturn [Object, nil] new value, when nil the key is removed
// 69:     #   @return [Object, nil] new value or nil
// 70:     #   @!macro map.atomic_method_with_block
// 71:
// 72:     # @!method compute(key)
// 73:     #   Compute and store new value for key.
// 74:     #   @param [Object] key
// 75:     #   @yield compute new value from old one
// 76:     #   @yieldparam old_value [Object, nil] old_value, or nil when key is absent
// 77:     #   @yieldreturn [Object, nil] new value, when nil the key is removed
// 78:     #   @return [Object, nil] new value or nil
// 79:     #   @!macro map.atomic_method_with_block
// 80:
// 81:     # @!method merge_pair(key, value)
// 82:     #   If the key is absent, the value is stored, otherwise new value is
// 83:     #   computed with a block.
// 84:     #   @param [Object] key
// 85:     #   @param [Object] value
// 86:     #   @yield compute new value from old one
// 87:     #   @yieldparam old_value [Object] old value
// 88:     #   @yieldreturn [Object, nil] new value, when nil the key is removed
// 89:     #   @return [Object, nil] new value or nil
// 90:     #   @!macro map.atomic_method_with_block
// 91:
// 92:     # @!method replace_pair(key, old_value, new_value)
// 93:     #   Replaces old_value with new_value if key exists and current value
// 94:     #   matches old_value
// 95:     #   @param [Object] key
// 96:     #   @param [Object] old_value
// 97:     #   @param [Object] new_value
// 98:     #   @return [true, false] true if replaced
// 99:     #   @!macro map.atomic_method
// 100:
// 101:     # @!method replace_if_exists(key, new_value)
// 102:     #   Replaces current value with new_value if key exists
// 103:     #   @param [Object] key
// 104:     #   @param [Object] new_value
// 105:     #   @return [Object, nil] old value or nil
// 106:     #   @!macro map.atomic_method
// 107:
// 108:     # @!method get_and_set(key, value)
// 109:     #   Get the current value under key and set new value.
// 110:     #   @param [Object] key
// 111:     #   @param [Object] value
// 112:     #   @return [Object, nil] old value or nil when the key was absent
// 113:     #   @!macro map.atomic_method
// 114:
// 115:     # @!method delete(key)
// 116:     #   Delete key and its value.
// 117:     #   @param [Object] key
// 118:     #   @return [Object, nil] old value or nil when the key was absent
// 119:     #   @!macro map.atomic_method
// 120:
// 121:     # @!method delete_pair(key, value)
// 122:     #   Delete pair and its value if current value equals the provided value.
// 123:     #   @param [Object] key
// 124:     #   @param [Object] value
// 125:     #   @return [true, false] true if deleted
// 126:     #   @!macro map.atomic_method
// 127:
// 128:     # NonConcurrentMapBackend handles default_proc natively
// 129:     unless defined?(Collection::NonConcurrentMapBackend) and self < Collection::NonConcurrentMapBackend
// 130:
// 131:       # @param [Hash, nil] options options to set the :initial_capacity or :load_factor. Ignored on some Rubies.
// 132:       # @param [Proc] default_proc Optional block to compute the default value if the key is not set, like `Hash#default_proc`
// 133:       def initialize(options = nil, &default_proc)
// 134:         if options.kind_of?(::Hash)
// 135:           validate_options_hash!(options)
// 136:         else
// 137:           options = nil
// 138:         end
// 139:
// 140:         super(options)
// 141:         @default_proc = default_proc
// 142:       end
// 143:
// 144:       # Get a value with key
// 145:       # @param [Object] key
// 146:       # @return [Object] the value
// 147:       def [](key)
// 148:         if value = super # non-falsy value is an existing mapping, return it right away
// 149:           value
// 150:           # re-check is done with get_or_default(key, NULL) instead of a simple !key?(key) in order to avoid a race condition, whereby by the time the current thread gets to the key?(key) call
// 151:           # a key => value mapping might have already been created by a different thread (key?(key) would then return true, this elsif branch wouldn't be taken and an incorrect +nil+ value
// 152:           # would be returned)
// 153:           # note: nil == value check is not technically necessary
// 154:         elsif @default_proc && nil == value && NULL == (value = get_or_default(key, NULL))
// 155:           @default_proc.call(self, key)
// 156:         else
// 157:           value
// 158:         end
// 159:       end
// 160:     end
// 161:
// 162:     alias_method :get, :[]
// 163:     alias_method :put, :[]=
// 164:
// 165:     # Get a value with key, or default_value when key is absent,
// 166:     # or fail when no default_value is given.
// 167:     # @param [Object] key
// 168:     # @param [Object] default_value
// 169:     # @yield default value for a key
// 170:     # @yieldparam key [Object]
// 171:     # @yieldreturn [Object] default value
// 172:     # @return [Object] the value or default value
// 173:     # @raise [KeyError] when key is missing and no default_value is provided
// 174:     # @!macro map_method_not_atomic
// 175:     #   @note The "fetch-then-act" methods of `Map` are not atomic. `Map` is intended
// 176:     #     to be use as a concurrency primitive with strong happens-before
// 177:     #     guarantees. It is not intended to be used as a high-level abstraction
// 178:     #     supporting complex operations. All read and write operations are
// 179:     #     thread safe, but no guarantees are made regarding race conditions
// 180:     #     between the fetch operation and yielding to the block. Additionally,
// 181:     #     this method does not support recursion. This is due to internal
// 182:     #     constraints that are very unlikely to change in the near future.
// 183:     def fetch(key, default_value = NULL)
// 184:       if NULL != (value = get_or_default(key, NULL))
// 185:         value
// 186:       elsif block_given?
// 187:         yield key
// 188:       elsif NULL != default_value
// 189:         default_value
// 190:       else
// 191:         raise_fetch_no_key
// 192:       end
// 193:     end
// 194:
// 195:     # Fetch value with key, or store default value when key is absent,
// 196:     # or fail when no default_value is given. This is a two step operation,
// 197:     # therefore not atomic. The store can overwrite other concurrently
// 198:     # stored value.
// 199:     # @param [Object] key
// 200:     # @param [Object] default_value
// 201:     # @yield default value for a key
// 202:     # @yieldparam key [Object]
// 203:     # @yieldreturn [Object] default value
// 204:     # @return [Object] the value or default value
// 205:     def fetch_or_store(key, default_value = NULL)
// 206:       fetch(key) do
// 207:         put(key, block_given? ? yield(key) : (NULL == default_value ? raise_fetch_no_key : default_value))
// 208:       end
// 209:     end
// 210:
// 211:     # Insert value into map with key if key is absent in one atomic step.
// 212:     # @param [Object] key
// 213:     # @param [Object] value
// 214:     # @return [Object, nil] the previous value when key was present or nil when there was no key
// 215:     def put_if_absent(key, value)
// 216:       computed = false
// 217:       result   = compute_if_absent(key) do
// 218:         computed = true
// 219:         value
// 220:       end
// 221:       computed ? nil : result
// 222:     end unless method_defined?(:put_if_absent)
// 223:
// 224:     # Is the value stored in the map. Iterates over all values.
// 225:     # @param [Object] value
// 226:     # @return [true, false]
// 227:     def value?(value)
// 228:       each_value do |v|
// 229:         return true if value.equal?(v)
// 230:       end
// 231:       false
// 232:     end
// 233:
// 234:     # All keys
// 235:     # @return [::Array<Object>] keys
// 236:     def keys
// 237:       arr = []
// 238:       each_pair { |k, v| arr << k }
// 239:       arr
// 240:     end unless method_defined?(:keys)
// 241:
// 242:     # All values
// 243:     # @return [::Array<Object>] values
// 244:     def values
// 245:       arr = []
// 246:       each_pair { |k, v| arr << v }
// 247:       arr
// 248:     end unless method_defined?(:values)
// 249:
// 250:     # Iterates over each key.
// 251:     # @yield for each key in the map
// 252:     # @yieldparam key [Object]
// 253:     # @return [self]
// 254:     # @!macro map.atomic_method_with_block
// 255:     def each_key
// 256:       each_pair { |k, v| yield k }
// 257:     end unless method_defined?(:each_key)
// 258:
// 259:     # Iterates over each value.
// 260:     # @yield for each value in the map
// 261:     # @yieldparam value [Object]
// 262:     # @return [self]
// 263:     # @!macro map.atomic_method_with_block
// 264:     def each_value
// 265:       each_pair { |k, v| yield v }
// 266:     end unless method_defined?(:each_value)
// 267:
// 268:     # Iterates over each key value pair.
// 269:     # @yield for each key value pair in the map
// 270:     # @yieldparam key [Object]
// 271:     # @yieldparam value [Object]
// 272:     # @return [self]
// 273:     # @!macro map.atomic_method_with_block
// 274:     def each_pair
// 275:       return enum_for :each_pair unless block_given?
// 276:       super
// 277:     end
// 278:
// 279:     alias_method :each, :each_pair unless method_defined?(:each)
// 280:
// 281:     # Find key of a value.
// 282:     # @param [Object] value
// 283:     # @return [Object, nil] key or nil when not found
// 284:     def key(value)
// 285:       each_pair { |k, v| return k if v == value }
// 286:       nil
// 287:     end unless method_defined?(:key)
// 288:
// 289:     # Is map empty?
// 290:     # @return [true, false]
// 291:     def empty?
// 292:       each_pair { |k, v| return false }
// 293:       true
// 294:     end unless method_defined?(:empty?)
// 295:
// 296:     # The size of map.
// 297:     # @return [Integer] size
// 298:     def size
// 299:       count = 0
// 300:       each_pair { |k, v| count += 1 }
// 301:       count
// 302:     end unless method_defined?(:size)
// 303:
// 304:     # @!visibility private
// 305:     def marshal_dump
// 306:       raise TypeError, "can't dump hash with default proc" if @default_proc
// 307:       h = {}
// 308:       each_pair { |k, v| h[k] = v }
// 309:       h
// 310:     end
// 311:
// 312:     # @!visibility private
// 313:     def marshal_load(hash)
// 314:       initialize
// 315:       populate_from(hash)
// 316:     end
// 317:
// 318:     undef :freeze
// 319:
// 320:     # @!visibility private
// 321:     def inspect
// 322:       format '%s entries=%d default_proc=%s>', to_s[0..-2], size.to_s, @default_proc.inspect
// 323:     end
// 324:
// 325:     private
// 326:
// 327:     def raise_fetch_no_key
// 328:       raise KeyError, 'key not found'
// 329:     end
// 330:
// 331:     def initialize_copy(other)
// 332:       super
// 333:       populate_from(other)
// 334:     end
// 335:
// 336:     def populate_from(hash)
// 337:       hash.each_pair { |k, v| self[k] = v }
// 338:       self
// 339:     end
// 340:
// 341:     def validate_options_hash!(options)
// 342:       if (initial_capacity = options[:initial_capacity]) && (!initial_capacity.kind_of?(Integer) || initial_capacity < 0)
// 343:         raise ArgumentError, ":initial_capacity must be a positive Integer"
// 344:       end
// 345:       if (load_factor = options[:load_factor]) && (!load_factor.kind_of?(Numeric) || load_factor <= 0 || load_factor > 1)
// 346:         raise ArgumentError, ":load_factor must be a number between 0 and 1"
// 347:       end
// 348:     end
// 349:   end
// 350: end
