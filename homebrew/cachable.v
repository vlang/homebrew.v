module homebrew

import ruby

// Translated from Homebrew/brew `cachable.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `cache` at line 10.
pub fn ruby_cachable_l10_d1_cache(args ...ruby.Value) ruby.Value {
	mut cachable := if args.len > 0 {
		cachable_from_boundary(args[0])
	} else {
		new_cachable[string, string]()
	}
	cache := cachable.cache()
	return ruby.structured_value('Hash', cache.entries.str(), cache.entries)
}

// Ruby method `clear_cache` at line 15.
pub fn ruby_cachable_l15_d2_clear_cache(args ...ruby.Value) ruby.Value {
	mut cachable := if args.len > 0 {
		cachable_from_boundary(args[0])
	} else {
		new_cachable[string, string]()
	}
	cachable.clear_cache()
	return cachable_boundary_value(cachable)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Cachable
// 5:   extend T::Generic
// 6:
// 7:   # Sorbet type members are mutable by design and cannot be frozen.
// 8:   Cache = type_member { { upper: T::Hash[T.anything, T.anything] } }
// 9:   sig { returns(Cache) }
// 10:   def cache
// 11:     @cache ||= T.let(T.cast({}, Cache), T.nilable(Cache))
// 12:   end
// 13:
// 14:   sig { void }
// 15:   def clear_cache
// 16:     cache.clear
// 17:   end
// 18: end
