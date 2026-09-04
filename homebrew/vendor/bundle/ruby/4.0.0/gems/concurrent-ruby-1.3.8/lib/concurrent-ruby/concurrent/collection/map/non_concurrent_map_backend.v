module map

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/map/non_concurrent_map_backend.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MapBackendOptions {
pub:
	initial_capacity ?int
	load_factor      ?f64
}

pub fn validate_map_backend_options(options MapBackendOptions) ! {
	if initial_capacity := options.initial_capacity {
		if initial_capacity < 0 {
			return error(':initial_capacity must be a positive Integer')
		}
	}
	if load_factor := options.load_factor {
		if load_factor <= 0 || load_factor > 1 {
			return error(':load_factor must be a number between 0 and 1')
		}
	}
}

pub struct ConcurrentMapValue {
pub:
	value    ruby.Value
	identity string
	is_nil   bool
}

pub fn concurrent_map_value(value ruby.Value, identity string) ConcurrentMapValue {
	return ConcurrentMapValue{
		value: value
		identity: identity
	}
}

pub fn concurrent_map_nil() ConcurrentMapValue {
	return ConcurrentMapValue{
		value: ruby.object_value('NilClass', 'nil')
		identity: 'nil'
		is_nil: true
	}
}

pub struct MapBackendLookup {
pub:
	present bool
	value   ConcurrentMapValue
}

pub type MapBackendDefaultProc = fn(mut NonConcurrentMapBackend, string) ConcurrentMapValue

pub type MapBackendProducer = fn() ConcurrentMapValue

pub type MapBackendComputer = fn(ConcurrentMapValue) ConcurrentMapValue

pub type MapBackendEachPair = fn(string, ConcurrentMapValue)

fn absent_map_default(mut backend NonConcurrentMapBackend, key string) ConcurrentMapValue {
	_ = backend
	_ = key
	return concurrent_map_nil()
}

@[heap]
pub struct NonConcurrentMapBackend {
mut:
	backend map[string]ConcurrentMapValue
pub:
	default_proc     MapBackendDefaultProc = absent_map_default
	has_default_proc bool
}

pub fn new_non_concurrent_map_backend(options MapBackendOptions) !NonConcurrentMapBackend {
	validate_map_backend_options(options)!
	return NonConcurrentMapBackend{
		backend: map[string]ConcurrentMapValue{}
	}
}

pub fn new_non_concurrent_map_backend_with_default(options MapBackendOptions, default_proc MapBackendDefaultProc) !NonConcurrentMapBackend {
	validate_map_backend_options(options)!
	return NonConcurrentMapBackend{
		backend: map[string]ConcurrentMapValue{}
		default_proc: default_proc
		has_default_proc: true
	}
}

pub fn (mut backend NonConcurrentMapBackend) get(key string) ConcurrentMapValue {
	if value := backend.backend[key] {
		return value
	}
	if backend.has_default_proc {
		return backend.default_proc(mut backend, key)
	}
	return concurrent_map_nil()
}

pub fn (mut backend NonConcurrentMapBackend) set(key string, value ConcurrentMapValue) ConcurrentMapValue {
	backend.backend[key] = value
	return value
}

pub fn (backend &NonConcurrentMapBackend) lookup(key string) MapBackendLookup {
	if value := backend.backend[key] {
		return MapBackendLookup{
			present: true
			value: value
		}
	}
	return MapBackendLookup{
		value: concurrent_map_nil()
	}
}

pub fn (mut backend NonConcurrentMapBackend) compute_if_absent(key string, producer MapBackendProducer) ConcurrentMapValue {
	if value := backend.backend[key] {
		return value
	}
	value := producer()
	backend.backend[key] = value
	return value
}

pub fn (mut backend NonConcurrentMapBackend) replace_pair(key string, old_value ConcurrentMapValue, new_value ConcurrentMapValue) bool {
	if backend.pair(key, old_value) {
		backend.backend[key] = new_value
		return true
	}
	return false
}

pub fn (mut backend NonConcurrentMapBackend) replace_if_exists(key string, new_value ConcurrentMapValue) ConcurrentMapValue {
	if stored_value := backend.backend[key] {
		backend.backend[key] = new_value
		return stored_value
	}
	return concurrent_map_nil()
}

pub fn (mut backend NonConcurrentMapBackend) compute_if_present(key string, computer MapBackendComputer) ConcurrentMapValue {
	if stored_value := backend.backend[key] {
		return backend.store_computed_value(key, computer(stored_value))
	}
	return concurrent_map_nil()
}

pub fn (mut backend NonConcurrentMapBackend) compute(key string, computer MapBackendComputer) ConcurrentMapValue {
	old_value := backend.lookup(key).value
	return backend.store_computed_value(key, computer(old_value))
}

pub fn (mut backend NonConcurrentMapBackend) merge_pair(key string, value ConcurrentMapValue, computer MapBackendComputer) ConcurrentMapValue {
	if stored_value := backend.backend[key] {
		return backend.store_computed_value(key, computer(stored_value))
	}
	backend.backend[key] = value
	return value
}

pub fn (mut backend NonConcurrentMapBackend) get_and_set(key string, value ConcurrentMapValue) ConcurrentMapValue {
	stored_value := backend.lookup(key).value
	backend.backend[key] = value
	return stored_value
}

pub fn (backend &NonConcurrentMapBackend) key(key string) bool {
	return key in backend.backend
}

pub fn (mut backend NonConcurrentMapBackend) delete(key string) ConcurrentMapValue {
	if stored_value := backend.backend[key] {
		backend.backend.delete(key)
		return stored_value
	}
	return concurrent_map_nil()
}

pub fn (mut backend NonConcurrentMapBackend) delete_pair(key string, value ConcurrentMapValue) bool {
	if backend.pair(key, value) {
		backend.backend.delete(key)
		return true
	}
	return false
}

pub fn (mut backend NonConcurrentMapBackend) clear() &NonConcurrentMapBackend {
	backend.backend.clear()
	return backend
}

pub fn (mut backend NonConcurrentMapBackend) each_pair(each MapBackendEachPair) &NonConcurrentMapBackend {
	snapshot := backend.dupped_backend()
	for key, value in snapshot {
		each(key, value)
	}
	return backend
}

pub fn (backend &NonConcurrentMapBackend) size() int {
	return backend.backend.len
}

pub fn (mut backend NonConcurrentMapBackend) get_or_default(key string, default_value ConcurrentMapValue) ConcurrentMapValue {
	return backend.backend[key] or { default_value }
}

pub fn (mut backend NonConcurrentMapBackend) set_backend() {
	backend.backend = map[string]ConcurrentMapValue{}
}

pub fn (backend &NonConcurrentMapBackend) initialize_copy() NonConcurrentMapBackend {
	return NonConcurrentMapBackend{
		backend: map[string]ConcurrentMapValue{}
		default_proc: backend.default_proc
		has_default_proc: backend.has_default_proc
	}
}

pub fn (backend &NonConcurrentMapBackend) dupped_backend() map[string]ConcurrentMapValue {
	return backend.backend.clone()
}

pub fn (backend &NonConcurrentMapBackend) pair(key string, expected_value ConcurrentMapValue) bool {
	if stored_value := backend.backend[key] {
		return stored_value.identity == expected_value.identity
	}
	return false
}

pub fn (mut backend NonConcurrentMapBackend) store_computed_value(key string, new_value ConcurrentMapValue) ConcurrentMapValue {
	if new_value.is_nil {
		backend.backend.delete(key)
		return concurrent_map_nil()
	}
	backend.backend[key] = new_value
	return new_value
}

fn backend_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn backend_boundary_key(value ruby.Value) string {
	return '${value.type_name}\0${value.repr}'
}

fn backend_boundary_identity(value ruby.Value) string {
	if identity := value.attributes['object_id'] {
		return identity
	}
	return '${value.type_name}\0${value.repr}'
}

fn backend_boundary_same_object(left ruby.Value, right ruby.Value) bool {
	return backend_boundary_identity(left) == backend_boundary_identity(right)
}

@[heap]
struct BoundaryMapState {
mut:
	values map[string]ruby.Value
}

fn backend_boundary_receiver(args []ruby.Value) &BoundaryMapState {
	if args.len == 0 {
		panic('map backend method requires a receiver')
	}
	address := (args[0].attribute('backend_address') or {
		panic('${args[0].type_name} has no translated backend state')
	}).u64()
	return unsafe { &BoundaryMapState(voidptr(address)) }
}

fn backend_boundary_new(type_name string, options MapBackendOptions) ruby.Value {
	state := &BoundaryMapState{
		values: map[string]ruby.Value{}
	}
	return ruby.Value{
		type_name: type_name
		repr: '#<${type_name}>'
		attributes: {
			'initial_capacity': (options.initial_capacity or { 0 }).str()
			'load_factor':      (options.load_factor or { 0.0 }).str()
			'backend_address':  u64(voidptr(state)).str()
		}
	}
}

fn map_options_from_boundary(value ruby.Value) MapBackendOptions {
	initial_capacity := if item := value.map_data['initial_capacity'] {
		?int(item.as_int() or { panic(err) })
	} else {
		none
	}
	load_factor := if item := value.map_data['load_factor'] {
		?f64(item.as_float() or { panic(err) })
	} else {
		none
	}
	return MapBackendOptions{
		initial_capacity: initial_capacity
		load_factor: load_factor
	}
}

// Ruby method `initialize(options = nil, &default_proc)` at line 15.
pub fn ruby_non_concurrent_map_backend_l15_d1_initialize(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 && args[0].type_name == 'Hash' {
		map_options_from_boundary(args[0])
	} else {
		MapBackendOptions{}
	}
	validate_map_backend_options(options) or { panic(err) }
	return backend_boundary_new('Concurrent::Collection::NonConcurrentMapBackend', options)
}

// Ruby method `[](key)` at line 21.
pub fn ruby_non_concurrent_map_backend_l21_d2_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('map [] requires a receiver and key')
	}
	backend := backend_boundary_receiver(args)
	return backend.values[backend_boundary_key(args[1])] or { backend_nil_value() }
}

// Ruby method `[]=(key, value)` at line 25.
pub fn ruby_non_concurrent_map_backend_l25_d3_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('map []= requires a receiver, key and value')
	}
	mut backend := backend_boundary_receiver(args)
	backend.values[backend_boundary_key(args[1])] = args[2]
	return args[2]
}

// Ruby method `compute_if_absent(key)` at line 29.
pub fn ruby_non_concurrent_map_backend_l29_d4_compute_if_absent(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('compute_if_absent requires a receiver, key and yielded value')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	if stored_value := backend.values[key] {
		return stored_value
	}
	backend.values[key] = args[2]
	return args[2]
}

// Ruby method `replace_pair(key, old_value, new_value)` at line 37.
pub fn ruby_non_concurrent_map_backend_l37_d5_replace_pair(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('replace_pair requires a receiver, key, old value and new value')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	if stored_value := backend.values[key] {
		if backend_boundary_same_object(args[2], stored_value) {
			backend.values[key] = args[3]
			return ruby.bool_value(true)
		}
	}
	return ruby.bool_value(false)
}

// Ruby method `replace_if_exists(key, new_value)` at line 46.
pub fn ruby_non_concurrent_map_backend_l46_d6_replace_if_exists(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('replace_if_exists requires a receiver, key and new value')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	if stored_value := backend.values[key] {
		backend.values[key] = args[2]
		return stored_value
	}
	return backend_nil_value()
}

// Ruby method `compute_if_present(key)` at line 53.
pub fn ruby_non_concurrent_map_backend_l53_d7_compute_if_present(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('compute_if_present requires a receiver, key and yielded value')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	if key !in backend.values {
		return backend_nil_value()
	}
	if args[2].type_name == 'NilClass' {
		backend.values.delete(key)
		return backend_nil_value()
	}
	backend.values[key] = args[2]
	return args[2]
}

// Ruby method `compute(key)` at line 59.
pub fn ruby_non_concurrent_map_backend_l59_d8_compute(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('compute requires a receiver, key and yielded value')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	if args[2].type_name == 'NilClass' {
		backend.values.delete(key)
		return backend_nil_value()
	}
	backend.values[key] = args[2]
	return args[2]
}

// Ruby method `merge_pair(key, value)` at line 63.
pub fn ruby_non_concurrent_map_backend_l63_d9_merge_pair(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('merge_pair requires a receiver, key and value')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	if key !in backend.values {
		backend.values[key] = args[2]
		return args[2]
	}
	if args.len < 4 {
		panic('merge_pair for an existing key requires the yielded value')
	}
	if args[3].type_name == 'NilClass' {
		backend.values.delete(key)
		return backend_nil_value()
	}
	backend.values[key] = args[3]
	return args[3]
}

// Ruby method `get_and_set(key, value)` at line 71.
pub fn ruby_non_concurrent_map_backend_l71_d10_get_and_set(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('get_and_set requires a receiver, key and value')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	stored_value := backend.values[key] or { backend_nil_value() }
	backend.values[key] = args[2]
	return stored_value
}

// Ruby method `key?(key)` at line 77.
pub fn ruby_non_concurrent_map_backend_l77_d11_key(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('key? requires a receiver and key')
	}
	backend := backend_boundary_receiver(args)
	return ruby.bool_value(backend_boundary_key(args[1]) in backend.values)
}

// Ruby method `delete(key)` at line 81.
pub fn ruby_non_concurrent_map_backend_l81_d12_delete(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('delete requires a receiver and key')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	stored_value := backend.values[key] or { return backend_nil_value() }
	backend.values.delete(key)
	return stored_value
}

// Ruby method `delete_pair(key, value)` at line 85.
pub fn ruby_non_concurrent_map_backend_l85_d13_delete_pair(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('delete_pair requires a receiver, key and value')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	if stored_value := backend.values[key] {
		if backend_boundary_same_object(args[2], stored_value) {
			backend.values.delete(key)
			return ruby.bool_value(true)
		}
	}
	return ruby.bool_value(false)
}

// Ruby method `clear` at line 94.
pub fn ruby_non_concurrent_map_backend_l94_d14_clear(args ...ruby.Value) ruby.Value {
	mut backend := backend_boundary_receiver(args)
	backend.values.clear()
	return args[0]
}

// Ruby method `each_pair` at line 99.
pub fn ruby_non_concurrent_map_backend_l99_d15_each_pair(args ...ruby.Value) ruby.Value {
	_ = backend_boundary_receiver(args).values.clone()
	return args[0]
}

// Ruby method `size` at line 106.
pub fn ruby_non_concurrent_map_backend_l106_d16_size(args ...ruby.Value) ruby.Value {
	return ruby.int_value(backend_boundary_receiver(args).values.len)
}

// Ruby method `get_or_default(key, default_value)` at line 110.
pub fn ruby_non_concurrent_map_backend_l110_d17_get_or_default(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('get_or_default requires a receiver, key and default value')
	}
	backend := backend_boundary_receiver(args)
	return backend.values[backend_boundary_key(args[1])] or { args[2] }
}

// Ruby method `set_backend(default_proc)` at line 116.
pub fn ruby_non_concurrent_map_backend_l116_d18_set_backend(args ...ruby.Value) ruby.Value {
	return backend_boundary_new('Concurrent::Collection::NonConcurrentMapBackend', MapBackendOptions{})
}

// Ruby method `initialize_copy(other)` at line 124.
pub fn ruby_non_concurrent_map_backend_l124_d19_initialize_copy(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('initialize_copy requires the copied backend')
	}
	return backend_boundary_new(args[0].type_name, MapBackendOptions{})
}

// Ruby method `dupped_backend` at line 130.
pub fn ruby_non_concurrent_map_backend_l130_d20_dupped_backend(args ...ruby.Value) ruby.Value {
	return ruby.map_value(backend_boundary_receiver(args).values.clone())
}

// Ruby method `pair?(key, expected_value)` at line 134.
pub fn ruby_non_concurrent_map_backend_l134_d21_pair(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('pair? requires a receiver, key and expected value')
	}
	backend := backend_boundary_receiver(args)
	if stored_value := backend.values[backend_boundary_key(args[1])] {
		return ruby.bool_value(backend_boundary_same_object(args[2], stored_value))
	}
	return ruby.bool_value(false)
}

// Ruby method `store_computed_value(key, new_value)` at line 138.
pub fn ruby_non_concurrent_map_backend_l138_d22_store_computed_value(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('store_computed_value requires a receiver, key and new value')
	}
	mut backend := backend_boundary_receiver(args)
	key := backend_boundary_key(args[1])
	if args[2].type_name == 'NilClass' {
		backend.values.delete(key)
		return backend_nil_value()
	}
	backend.values[key] = args[2]
	return args[2]
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/constants'
// 2:
// 3: module Concurrent
// 4:
// 5:   # @!visibility private
// 6:   module Collection
// 7:
// 8:     # @!visibility private
// 9:     class NonConcurrentMapBackend
// 10:
// 11:       # WARNING: all public methods of the class must operate on the @backend
// 12:       # directly without calling each other. This is important because of the
// 13:       # SynchronizedMapBackend which uses a non-reentrant mutex for performance
// 14:       # reasons.
// 15:       def initialize(options = nil, &default_proc)
// 16:         validate_options_hash!(options) if options.kind_of?(::Hash)
// 17:         set_backend(default_proc)
// 18:         @default_proc = default_proc
// 19:       end
// 20:
// 21:       def [](key)
// 22:         @backend[key]
// 23:       end
// 24:
// 25:       def []=(key, value)
// 26:         @backend[key] = value
// 27:       end
// 28:
// 29:       def compute_if_absent(key)
// 30:         if NULL != (stored_value = @backend.fetch(key, NULL))
// 31:           stored_value
// 32:         else
// 33:           @backend[key] = yield
// 34:         end
// 35:       end
// 36:
// 37:       def replace_pair(key, old_value, new_value)
// 38:         if pair?(key, old_value)
// 39:           @backend[key] = new_value
// 40:           true
// 41:         else
// 42:           false
// 43:         end
// 44:       end
// 45:
// 46:       def replace_if_exists(key, new_value)
// 47:         if NULL != (stored_value = @backend.fetch(key, NULL))
// 48:           @backend[key] = new_value
// 49:           stored_value
// 50:         end
// 51:       end
// 52:
// 53:       def compute_if_present(key)
// 54:         if NULL != (stored_value = @backend.fetch(key, NULL))
// 55:           store_computed_value(key, yield(stored_value))
// 56:         end
// 57:       end
// 58:
// 59:       def compute(key)
// 60:         store_computed_value(key, yield(get_or_default(key, nil)))
// 61:       end
// 62:
// 63:       def merge_pair(key, value)
// 64:         if NULL == (stored_value = @backend.fetch(key, NULL))
// 65:           @backend[key] = value
// 66:         else
// 67:           store_computed_value(key, yield(stored_value))
// 68:         end
// 69:       end
// 70:
// 71:       def get_and_set(key, value)
// 72:         stored_value = get_or_default(key, nil)
// 73:         @backend[key] = value
// 74:         stored_value
// 75:       end
// 76:
// 77:       def key?(key)
// 78:         @backend.key?(key)
// 79:       end
// 80:
// 81:       def delete(key)
// 82:         @backend.delete(key)
// 83:       end
// 84:
// 85:       def delete_pair(key, value)
// 86:         if pair?(key, value)
// 87:           @backend.delete(key)
// 88:           true
// 89:         else
// 90:           false
// 91:         end
// 92:       end
// 93:
// 94:       def clear
// 95:         @backend.clear
// 96:         self
// 97:       end
// 98:
// 99:       def each_pair
// 100:         dupped_backend.each_pair do |k, v|
// 101:           yield k, v
// 102:         end
// 103:         self
// 104:       end
// 105:
// 106:       def size
// 107:         @backend.size
// 108:       end
// 109:
// 110:       def get_or_default(key, default_value)
// 111:         @backend.fetch(key, default_value)
// 112:       end
// 113:
// 114:       private
// 115:
// 116:       def set_backend(default_proc)
// 117:         if default_proc
// 118:           @backend = ::Hash.new { |_h, key| default_proc.call(self, key) }
// 119:         else
// 120:           @backend = {}
// 121:         end
// 122:       end
// 123:
// 124:       def initialize_copy(other)
// 125:         super
// 126:         set_backend(@default_proc)
// 127:         self
// 128:       end
// 129:
// 130:       def dupped_backend
// 131:         @backend.dup
// 132:       end
// 133:
// 134:       def pair?(key, expected_value)
// 135:         NULL != (stored_value = @backend.fetch(key, NULL)) && expected_value.equal?(stored_value)
// 136:       end
// 137:
// 138:       def store_computed_value(key, new_value)
// 139:         if new_value.nil?
// 140:           @backend.delete(key)
// 141:           nil
// 142:         else
// 143:           @backend[key] = new_value
// 144:         end
// 145:       end
// 146:     end
// 147:   end
// 148: end
