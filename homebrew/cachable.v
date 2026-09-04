module homebrew

import ruby

// Translated from Homebrew/brew `cachable.rb`.

pub struct CachableCache[K, V] {
pub mut:
	entries map[K]V
}

// Cachable is the typed V equivalent of the generic Ruby mixin. The cache is
// allocated once so repeated calls return the same mutable cache object.
pub struct Cachable[K, V] {
mut:
	stored_cache &CachableCache[K, V] = unsafe { nil }
}

pub fn new_cachable[K, V]() Cachable[K, V] {
	return Cachable[K, V]{
		stored_cache: &CachableCache[K, V]{
			entries: map[K]V{}
		}
	}
}

pub fn (cachable Cachable[K, V]) cache() &CachableCache[K, V] {
	return cachable.stored_cache
}

pub fn (mut cachable Cachable[K, V]) clear_cache() {
	mut cache := cachable.cache()
	cache.entries.clear()
}

fn cachable_boundary_value(cachable Cachable[string, string]) ruby.Value {
	cache := cachable.cache()
	return ruby.structured_value('Cachable', cache.entries.str(), cache.entries)
}

fn cachable_from_boundary(value ruby.Value) Cachable[string, string] {
	if value.type_name != 'Cachable' {
		return new_cachable[string, string]()
	}
	mut cachable := new_cachable[string, string]()
	mut cache := cachable.cache()
	cache.entries = value.attributes.clone()
	return cachable
}
