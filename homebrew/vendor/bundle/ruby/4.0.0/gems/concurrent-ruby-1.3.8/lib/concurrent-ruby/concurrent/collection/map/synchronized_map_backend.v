module map

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/map/synchronized_map_backend.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct SynchronizedMapBackend {
mut:
	backend NonConcurrentMapBackend
	mutex   &sync.Mutex = sync.new_mutex()
}

pub fn new_synchronized_map_backend(options MapBackendOptions) !SynchronizedMapBackend {
	return SynchronizedMapBackend{
		backend: new_non_concurrent_map_backend(options)!
	}
}

pub fn new_synchronized_map_backend_with_default(options MapBackendOptions, default_proc MapBackendDefaultProc) !SynchronizedMapBackend {
	return SynchronizedMapBackend{
		backend: new_non_concurrent_map_backend_with_default(options, default_proc)!
	}
}

pub fn (mut backend SynchronizedMapBackend) get(key string) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.get(key)
}

pub fn (mut backend SynchronizedMapBackend) set(key string, value ConcurrentMapValue) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.set(key, value)
}

pub fn (mut backend SynchronizedMapBackend) compute_if_absent(key string, producer MapBackendProducer) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.compute_if_absent(key, producer)
}

pub fn (mut backend SynchronizedMapBackend) compute_if_present(key string, computer MapBackendComputer) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.compute_if_present(key, computer)
}

pub fn (mut backend SynchronizedMapBackend) compute(key string, computer MapBackendComputer) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.compute(key, computer)
}

pub fn (mut backend SynchronizedMapBackend) merge_pair(key string, value ConcurrentMapValue, computer MapBackendComputer) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.merge_pair(key, value, computer)
}

pub fn (mut backend SynchronizedMapBackend) replace_pair(key string, old_value ConcurrentMapValue, new_value ConcurrentMapValue) bool {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.replace_pair(key, old_value, new_value)
}

pub fn (mut backend SynchronizedMapBackend) replace_if_exists(key string, new_value ConcurrentMapValue) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.replace_if_exists(key, new_value)
}

pub fn (mut backend SynchronizedMapBackend) get_and_set(key string, value ConcurrentMapValue) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.get_and_set(key, value)
}

pub fn (mut backend SynchronizedMapBackend) key(key string) bool {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.key(key)
}

pub fn (mut backend SynchronizedMapBackend) delete(key string) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.delete(key)
}

pub fn (mut backend SynchronizedMapBackend) delete_pair(key string, value ConcurrentMapValue) bool {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.delete_pair(key, value)
}

pub fn (mut backend SynchronizedMapBackend) clear() &SynchronizedMapBackend {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	backend.backend.clear()
	return backend
}

pub fn (mut backend SynchronizedMapBackend) size() int {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.size()
}

pub fn (mut backend SynchronizedMapBackend) get_or_default(key string, default_value ConcurrentMapValue) ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.get_or_default(key, default_value)
}

pub fn (mut backend SynchronizedMapBackend) dupped_backend() map[string]ConcurrentMapValue {
	backend.mutex.lock()
	defer {
		backend.mutex.unlock()
	}
	return backend.backend.dupped_backend()
}

pub fn (mut backend SynchronizedMapBackend) each_pair(each MapBackendEachPair) &SynchronizedMapBackend {
	// The Ruby implementation locks only while duplicating the backend, then
	// invokes user code outside the non-reentrant mutex.
	snapshot := backend.dupped_backend()
	for key, value in snapshot {
		each(key, value)
	}
	return backend
}

// Ruby method `initialize(*args, &block)` at line 11.
pub fn ruby_synchronized_map_backend_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	options := if args.len > 0 && args[0].type_name == 'Hash' {
		map_options_from_boundary(args[0])
	} else {
		MapBackendOptions{}
	}
	validate_map_backend_options(options) or { panic(err) }
	return backend_boundary_new('Concurrent::Collection::SynchronizedMapBackend', options)
}

// Ruby method `[](key)` at line 19.
pub fn ruby_synchronized_map_backend_l19_d2_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l21_d2_anonymous(...args)
}

// Ruby method `[]=(key, value)` at line 23.
pub fn ruby_synchronized_map_backend_l23_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l25_d3_anonymous(...args)
}

// Ruby method `compute_if_absent(key)` at line 27.
pub fn ruby_synchronized_map_backend_l27_d4_compute_if_absent(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l29_d4_compute_if_absent(...args)
}

// Ruby method `compute_if_present(key)` at line 31.
pub fn ruby_synchronized_map_backend_l31_d5_compute_if_present(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l53_d7_compute_if_present(...args)
}

// Ruby method `compute(key)` at line 35.
pub fn ruby_synchronized_map_backend_l35_d6_compute(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l59_d8_compute(...args)
}

// Ruby method `merge_pair(key, value)` at line 39.
pub fn ruby_synchronized_map_backend_l39_d7_merge_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l63_d9_merge_pair(...args)
}

// Ruby method `replace_pair(key, old_value, new_value)` at line 43.
pub fn ruby_synchronized_map_backend_l43_d8_replace_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l37_d5_replace_pair(...args)
}

// Ruby method `replace_if_exists(key, new_value)` at line 47.
pub fn ruby_synchronized_map_backend_l47_d9_replace_if_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l46_d6_replace_if_exists(...args)
}

// Ruby method `get_and_set(key, value)` at line 51.
pub fn ruby_synchronized_map_backend_l51_d10_get_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l71_d10_get_and_set(...args)
}

// Ruby method `key?(key)` at line 55.
pub fn ruby_synchronized_map_backend_l55_d11_key(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l77_d11_key(...args)
}

// Ruby method `delete(key)` at line 59.
pub fn ruby_synchronized_map_backend_l59_d12_delete(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l81_d12_delete(...args)
}

// Ruby method `delete_pair(key, value)` at line 63.
pub fn ruby_synchronized_map_backend_l63_d13_delete_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l85_d13_delete_pair(...args)
}

// Ruby method `clear` at line 67.
pub fn ruby_synchronized_map_backend_l67_d14_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l94_d14_clear(...args)
}

// Ruby method `size` at line 71.
pub fn ruby_synchronized_map_backend_l71_d15_size(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l106_d16_size(...args)
}

// Ruby method `get_or_default(key, default_value)` at line 75.
pub fn ruby_synchronized_map_backend_l75_d16_get_or_default(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l110_d17_get_or_default(...args)
}

// Ruby method `dupped_backend` at line 80.
pub fn ruby_synchronized_map_backend_l80_d17_dupped_backend(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l130_d20_dupped_backend(...args)
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
