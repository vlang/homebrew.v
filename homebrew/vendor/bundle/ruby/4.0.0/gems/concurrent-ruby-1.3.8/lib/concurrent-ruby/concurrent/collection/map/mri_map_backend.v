module map

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/map/mri_map_backend.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct MriMapBackend {
mut:
	backend    NonConcurrentMapBackend
	write_lock &sync.RwMutex = sync.new_rwmutex()
}

pub fn new_mri_map_backend(options MapBackendOptions) !MriMapBackend {
	return MriMapBackend{
		backend: new_non_concurrent_map_backend(options)!
	}
}

pub fn new_mri_map_backend_with_default(options MapBackendOptions, default_proc MapBackendDefaultProc) !MriMapBackend {
	return MriMapBackend{
		backend: new_non_concurrent_map_backend_with_default(options, default_proc)!
	}
}

pub fn (mut backend MriMapBackend) get(key string) ConcurrentMapValue {
	backend.write_lock.rlock()
	if value := backend.backend.backend[key] {
		backend.write_lock.runlock()
		return value
	}
	backend.write_lock.runlock()
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.get(key)
}

pub fn (mut backend MriMapBackend) key(key string) bool {
	backend.write_lock.rlock()
	defer {
		backend.write_lock.runlock()
	}
	return backend.backend.key(key)
}

pub fn (mut backend MriMapBackend) size() int {
	backend.write_lock.rlock()
	defer {
		backend.write_lock.runlock()
	}
	return backend.backend.size()
}

pub fn (mut backend MriMapBackend) set(key string, value ConcurrentMapValue) ConcurrentMapValue {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.set(key, value)
}

pub fn (mut backend MriMapBackend) compute_if_absent(key string, producer MapBackendProducer) ConcurrentMapValue {
	backend.write_lock.rlock()
	if lookup := backend.backend.backend[key] {
		backend.write_lock.runlock()
		return lookup
	}
	backend.write_lock.runlock()
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.compute_if_absent(key, producer)
}

pub fn (mut backend MriMapBackend) get_or_default(key string, default_value ConcurrentMapValue) ConcurrentMapValue {
	backend.write_lock.rlock()
	defer {
		backend.write_lock.runlock()
	}
	return backend.backend.get_or_default(key, default_value)
}

pub fn (mut backend MriMapBackend) dupped_backend() map[string]ConcurrentMapValue {
	backend.write_lock.rlock()
	defer {
		backend.write_lock.runlock()
	}
	return backend.backend.dupped_backend()
}

pub fn (mut backend MriMapBackend) each_pair(each MapBackendEachPair) &MriMapBackend {
	snapshot := backend.dupped_backend()
	for key, value in snapshot {
		each(key, value)
	}
	return backend
}

pub fn (mut backend MriMapBackend) compute_if_present(key string, computer MapBackendComputer) ConcurrentMapValue {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.compute_if_present(key, computer)
}

pub fn (mut backend MriMapBackend) compute(key string, computer MapBackendComputer) ConcurrentMapValue {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.compute(key, computer)
}

pub fn (mut backend MriMapBackend) merge_pair(key string, value ConcurrentMapValue, computer MapBackendComputer) ConcurrentMapValue {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.merge_pair(key, value, computer)
}

pub fn (mut backend MriMapBackend) replace_pair(key string, old_value ConcurrentMapValue, new_value ConcurrentMapValue) bool {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.replace_pair(key, old_value, new_value)
}

pub fn (mut backend MriMapBackend) replace_if_exists(key string, new_value ConcurrentMapValue) ConcurrentMapValue {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.replace_if_exists(key, new_value)
}

pub fn (mut backend MriMapBackend) get_and_set(key string, value ConcurrentMapValue) ConcurrentMapValue {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.get_and_set(key, value)
}

pub fn (mut backend MriMapBackend) delete(key string) ConcurrentMapValue {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.delete(key)
}

pub fn (mut backend MriMapBackend) delete_pair(key string, value ConcurrentMapValue) bool {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	return backend.backend.delete_pair(key, value)
}

pub fn (mut backend MriMapBackend) clear() &MriMapBackend {
	backend.write_lock.lock()
	defer {
		backend.write_lock.unlock()
	}
	backend.backend.clear()
	return backend
}

// Ruby method `initialize(options = nil, &default_proc)` at line 12.
pub fn ruby_mri_map_backend_l12_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	options := if args.len > 0 && args[0].type_name == 'Hash' {
		map_options_from_boundary(args[0])
	} else {
		MapBackendOptions{}
	}
	validate_map_backend_options(options) or { panic(err) }
	return backend_boundary_new('Concurrent::Collection::MriMapBackend', options)
}

// Ruby method `[]=(key, value)` at line 17.
pub fn ruby_mri_map_backend_l17_d2_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l25_d3_anonymous(...args)
}

// Ruby method `compute_if_absent(key)` at line 21.
pub fn ruby_mri_map_backend_l21_d3_compute_if_absent(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l29_d4_compute_if_absent(...args)
}

// Ruby method `compute_if_present(key)` at line 29.
pub fn ruby_mri_map_backend_l29_d4_compute_if_present(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l53_d7_compute_if_present(...args)
}

// Ruby method `compute(key)` at line 33.
pub fn ruby_mri_map_backend_l33_d5_compute(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l59_d8_compute(...args)
}

// Ruby method `merge_pair(key, value)` at line 37.
pub fn ruby_mri_map_backend_l37_d6_merge_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l63_d9_merge_pair(...args)
}

// Ruby method `replace_pair(key, old_value, new_value)` at line 41.
pub fn ruby_mri_map_backend_l41_d7_replace_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l37_d5_replace_pair(...args)
}

// Ruby method `replace_if_exists(key, new_value)` at line 45.
pub fn ruby_mri_map_backend_l45_d8_replace_if_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l46_d6_replace_if_exists(...args)
}

// Ruby method `get_and_set(key, value)` at line 49.
pub fn ruby_mri_map_backend_l49_d9_get_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l71_d10_get_and_set(...args)
}

// Ruby method `delete(key)` at line 53.
pub fn ruby_mri_map_backend_l53_d10_delete(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l81_d12_delete(...args)
}

// Ruby method `delete_pair(key, value)` at line 57.
pub fn ruby_mri_map_backend_l57_d11_delete_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l85_d13_delete_pair(...args)
}

// Ruby method `clear` at line 61.
pub fn ruby_mri_map_backend_l61_d12_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_non_concurrent_map_backend_l94_d14_clear(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'concurrent/collection/map/non_concurrent_map_backend'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!visibility private
// 7:   module Collection
// 8:
// 9:     # @!visibility private
// 10:     class MriMapBackend < NonConcurrentMapBackend
// 11:
// 12:       def initialize(options = nil, &default_proc)
// 13:         super(options, &default_proc)
// 14:         @write_lock = Mutex.new
// 15:       end
// 16:
// 17:       def []=(key, value)
// 18:         @write_lock.synchronize { super }
// 19:       end
// 20:
// 21:       def compute_if_absent(key)
// 22:         if NULL != (stored_value = @backend.fetch(key, NULL)) # fast non-blocking path for the most likely case
// 23:           stored_value
// 24:         else
// 25:           @write_lock.synchronize { super }
// 26:         end
// 27:       end
// 28:
// 29:       def compute_if_present(key)
// 30:         @write_lock.synchronize { super }
// 31:       end
// 32:
// 33:       def compute(key)
// 34:         @write_lock.synchronize { super }
// 35:       end
// 36:
// 37:       def merge_pair(key, value)
// 38:         @write_lock.synchronize { super }
// 39:       end
// 40:
// 41:       def replace_pair(key, old_value, new_value)
// 42:         @write_lock.synchronize { super }
// 43:       end
// 44:
// 45:       def replace_if_exists(key, new_value)
// 46:         @write_lock.synchronize { super }
// 47:       end
// 48:
// 49:       def get_and_set(key, value)
// 50:         @write_lock.synchronize { super }
// 51:       end
// 52:
// 53:       def delete(key)
// 54:         @write_lock.synchronize { super }
// 55:       end
// 56:
// 57:       def delete_pair(key, value)
// 58:         @write_lock.synchronize { super }
// 59:       end
// 60:
// 61:       def clear
// 62:         @write_lock.synchronize { super }
// 63:       end
// 64:     end
// 65:   end
// 66: end
