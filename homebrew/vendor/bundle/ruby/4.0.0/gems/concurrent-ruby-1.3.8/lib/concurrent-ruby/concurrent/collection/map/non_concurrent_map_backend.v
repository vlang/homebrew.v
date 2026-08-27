module map

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/map/non_concurrent_map_backend.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(options = nil, &default_proc)` at line 15.
pub fn ruby_non_concurrent_map_backend_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `[](key)` at line 21.
pub fn ruby_non_concurrent_map_backend_l21_d2_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]', ...args)
}

// Ruby method `[]=(key, value)` at line 25.
pub fn ruby_non_concurrent_map_backend_l25_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]=', ...args)
}

// Ruby method `compute_if_absent(key)` at line 29.
pub fn ruby_non_concurrent_map_backend_l29_d4_compute_if_absent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_if_absent', ...args)
}

// Ruby method `replace_pair(key, old_value, new_value)` at line 37.
pub fn ruby_non_concurrent_map_backend_l37_d5_replace_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replace_pair', ...args)
}

// Ruby method `replace_if_exists(key, new_value)` at line 46.
pub fn ruby_non_concurrent_map_backend_l46_d6_replace_if_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replace_if_exists', ...args)
}

// Ruby method `compute_if_present(key)` at line 53.
pub fn ruby_non_concurrent_map_backend_l53_d7_compute_if_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_if_present', ...args)
}

// Ruby method `compute(key)` at line 59.
pub fn ruby_non_concurrent_map_backend_l59_d8_compute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute', ...args)
}

// Ruby method `merge_pair(key, value)` at line 63.
pub fn ruby_non_concurrent_map_backend_l63_d9_merge_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge_pair', ...args)
}

// Ruby method `get_and_set(key, value)` at line 71.
pub fn ruby_non_concurrent_map_backend_l71_d10_get_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_and_set', ...args)
}

// Ruby method `key?(key)` at line 77.
pub fn ruby_non_concurrent_map_backend_l77_d11_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('key?', ...args)
}

// Ruby method `delete(key)` at line 81.
pub fn ruby_non_concurrent_map_backend_l81_d12_delete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete', ...args)
}

// Ruby method `delete_pair(key, value)` at line 85.
pub fn ruby_non_concurrent_map_backend_l85_d13_delete_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete_pair', ...args)
}

// Ruby method `clear` at line 94.
pub fn ruby_non_concurrent_map_backend_l94_d14_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear', ...args)
}

// Ruby method `each_pair` at line 99.
pub fn ruby_non_concurrent_map_backend_l99_d15_each_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_pair', ...args)
}

// Ruby method `size` at line 106.
pub fn ruby_non_concurrent_map_backend_l106_d16_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('size', ...args)
}

// Ruby method `get_or_default(key, default_value)` at line 110.
pub fn ruby_non_concurrent_map_backend_l110_d17_get_or_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_or_default', ...args)
}

// Ruby method `set_backend(default_proc)` at line 116.
pub fn ruby_non_concurrent_map_backend_l116_d18_set_backend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_backend', ...args)
}

// Ruby method `initialize_copy(other)` at line 124.
pub fn ruby_non_concurrent_map_backend_l124_d19_initialize_copy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_copy', ...args)
}

// Ruby method `dupped_backend` at line 130.
pub fn ruby_non_concurrent_map_backend_l130_d20_dupped_backend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dupped_backend', ...args)
}

// Ruby method `pair?(key, expected_value)` at line 134.
pub fn ruby_non_concurrent_map_backend_l134_d21_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pair?', ...args)
}

// Ruby method `store_computed_value(key, new_value)` at line 138.
pub fn ruby_non_concurrent_map_backend_l138_d22_store_computed_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('store_computed_value', ...args)
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
