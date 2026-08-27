module map

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/map/synchronized_map_backend.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(*args, &block)` at line 11.
pub fn ruby_synchronized_map_backend_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `[](key)` at line 19.
pub fn ruby_synchronized_map_backend_l19_d2_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]', ...args)
}

// Ruby method `[]=(key, value)` at line 23.
pub fn ruby_synchronized_map_backend_l23_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]=', ...args)
}

// Ruby method `compute_if_absent(key)` at line 27.
pub fn ruby_synchronized_map_backend_l27_d4_compute_if_absent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_if_absent', ...args)
}

// Ruby method `compute_if_present(key)` at line 31.
pub fn ruby_synchronized_map_backend_l31_d5_compute_if_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_if_present', ...args)
}

// Ruby method `compute(key)` at line 35.
pub fn ruby_synchronized_map_backend_l35_d6_compute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute', ...args)
}

// Ruby method `merge_pair(key, value)` at line 39.
pub fn ruby_synchronized_map_backend_l39_d7_merge_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge_pair', ...args)
}

// Ruby method `replace_pair(key, old_value, new_value)` at line 43.
pub fn ruby_synchronized_map_backend_l43_d8_replace_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replace_pair', ...args)
}

// Ruby method `replace_if_exists(key, new_value)` at line 47.
pub fn ruby_synchronized_map_backend_l47_d9_replace_if_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replace_if_exists', ...args)
}

// Ruby method `get_and_set(key, value)` at line 51.
pub fn ruby_synchronized_map_backend_l51_d10_get_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_and_set', ...args)
}

// Ruby method `key?(key)` at line 55.
pub fn ruby_synchronized_map_backend_l55_d11_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('key?', ...args)
}

// Ruby method `delete(key)` at line 59.
pub fn ruby_synchronized_map_backend_l59_d12_delete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete', ...args)
}

// Ruby method `delete_pair(key, value)` at line 63.
pub fn ruby_synchronized_map_backend_l63_d13_delete_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete_pair', ...args)
}

// Ruby method `clear` at line 67.
pub fn ruby_synchronized_map_backend_l67_d14_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear', ...args)
}

// Ruby method `size` at line 71.
pub fn ruby_synchronized_map_backend_l71_d15_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('size', ...args)
}

// Ruby method `get_or_default(key, default_value)` at line 75.
pub fn ruby_synchronized_map_backend_l75_d16_get_or_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_or_default', ...args)
}

// Ruby method `dupped_backend` at line 80.
pub fn ruby_synchronized_map_backend_l80_d17_dupped_backend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dupped_backend', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/collection/map/non_concurrent_map_backend'
// 2:
// 3: module Concurrent
// 4:
// 5:   # @!visibility private
// 6:   module Collection
// 7:
// 8:     # @!visibility private
// 9:     class SynchronizedMapBackend < NonConcurrentMapBackend
// 10:
// 11:       def initialize(*args, &block)
// 12:         super
// 13:
// 14:         # WARNING: Mutex is a non-reentrant lock, so the synchronized methods are
// 15:         # not allowed to call each other.
// 16:         @mutex = Mutex.new
// 17:       end
// 18:
// 19:       def [](key)
// 20:         @mutex.synchronize { super }
// 21:       end
// 22:
// 23:       def []=(key, value)
// 24:         @mutex.synchronize { super }
// 25:       end
// 26:
// 27:       def compute_if_absent(key)
// 28:         @mutex.synchronize { super }
// 29:       end
// 30:
// 31:       def compute_if_present(key)
// 32:         @mutex.synchronize { super }
// 33:       end
// 34:
// 35:       def compute(key)
// 36:         @mutex.synchronize { super }
// 37:       end
// 38:
// 39:       def merge_pair(key, value)
// 40:         @mutex.synchronize { super }
// 41:       end
// 42:
// 43:       def replace_pair(key, old_value, new_value)
// 44:         @mutex.synchronize { super }
// 45:       end
// 46:
// 47:       def replace_if_exists(key, new_value)
// 48:         @mutex.synchronize { super }
// 49:       end
// 50:
// 51:       def get_and_set(key, value)
// 52:         @mutex.synchronize { super }
// 53:       end
// 54:
// 55:       def key?(key)
// 56:         @mutex.synchronize { super }
// 57:       end
// 58:
// 59:       def delete(key)
// 60:         @mutex.synchronize { super }
// 61:       end
// 62:
// 63:       def delete_pair(key, value)
// 64:         @mutex.synchronize { super }
// 65:       end
// 66:
// 67:       def clear
// 68:         @mutex.synchronize { super }
// 69:       end
// 70:
// 71:       def size
// 72:         @mutex.synchronize { super }
// 73:       end
// 74:
// 75:       def get_or_default(key, default_value)
// 76:         @mutex.synchronize { super }
// 77:       end
// 78:
// 79:       private
// 80:       def dupped_backend
// 81:         @mutex.synchronize { super }
// 82:       end
// 83:     end
// 84:   end
// 85: end
