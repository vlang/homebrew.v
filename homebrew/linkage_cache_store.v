module homebrew

import brew_runtime

const linkage_cache_types = ['keg_files_dylibs']

pub struct LinkageCacheStore {
pub:
	keg_path string
}

pub struct LinkageCacheDatabase {
pub mut:
	entries map[string]map[string]brew_runtime.Value
	sets    []string
	deletes []string
}

// Translated from Homebrew/brew `linkage_cache_store.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(keg_path, database)` at line 15.
pub fn ruby_linkage_cache_store_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	keg_path := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.structured_value('LinkageCacheStore', keg_path, {
		'keg_path': keg_path
		'database': if args.len > 1 { args[1].as_string() } else { 'database' }
	})
}

// Ruby method `keg_exists?` at line 22.
pub fn ruby_linkage_cache_store_l22_d2_keg_exists(args ...brew_runtime.Value) brew_runtime.Value {
	keg_path := if args.len > 0 { args[0].as_string() } else { '' }
	database := if args.len > 1 {
		args[1].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	return brew_runtime.bool_value(keg_path in database)
}

// Ruby method `update!(hash_values)` at line 31.
pub fn ruby_linkage_cache_store_l31_d3_update(args ...brew_runtime.Value) brew_runtime.Value {
	keg_path := if args.len > 0 { args[0].as_string() } else { '' }
	values := if args.len > 1 {
		args[1].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	validate_linkage_cache_values(values) or { return brew_runtime.object_value('TypeError', err.msg()) }
	return brew_runtime.map_value({
		keg_path: brew_runtime.map_value(values)
	})
}

// Ruby method `fetch(type)` at line 46.
pub fn ruby_linkage_cache_store_l46_d4_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	type_name := if args.len > 0 { args[0].as_string() } else { '' }
	if type_name !in linkage_cache_types {
		return brew_runtime.object_value('TypeError', "Can't fetch types that are not defined for the linkage store\n")
	}
	if args.len < 2 || args[1].type_name == 'NilClass' {
		return brew_runtime.map_value({})
	}
	keg_cache := args[1].as_map() or { return brew_runtime.map_value({}) }
	return keg_cache[type_name] or { brew_runtime.object_value('NilClass', 'nil') }
}

// Ruby method `delete!` at line 60.
pub fn ruby_linkage_cache_store_l60_d5_delete(args ...brew_runtime.Value) brew_runtime.Value {
	keg_path := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.structured_value('CacheStoreDelete', keg_path, {
		'key': keg_path
	})
}

// Ruby method `fetch_hash_values(type)` at line 70.
pub fn ruby_linkage_cache_store_l70_d6_fetch_hash_values(args ...brew_runtime.Value) brew_runtime.Value {
	type_name := if args.len > 0 { args[0].as_string() } else { '' }
	if args.len < 2 || args[1].type_name == 'NilClass' {
		return brew_runtime.map_value({})
	}
	cache := args[1].as_map() or { return brew_runtime.map_value({}) }
	return cache[type_name] or { brew_runtime.object_value('NilClass', 'nil') }
}

pub fn new_linkage_cache_store(keg_path string) LinkageCacheStore {
	return LinkageCacheStore{ keg_path: keg_path }
}

pub fn linkage_keg_exists(store LinkageCacheStore, database LinkageCacheDatabase) bool {
	return store.keg_path in database.entries
}

pub fn linkage_update(mut database LinkageCacheDatabase, store LinkageCacheStore,
	values map[string]brew_runtime.Value) ! {
	validate_linkage_cache_values(values)!
	database.entries[store.keg_path] = values.clone()
	database.sets << store.keg_path
}

pub fn linkage_fetch(database LinkageCacheDatabase, store LinkageCacheStore,
	type_name string) !brew_runtime.Value {
	if type_name !in linkage_cache_types {
		return error("Can't fetch types that are not defined for the linkage store\n")
	}
	if store.keg_path !in database.entries {
		return brew_runtime.map_value({})
	}
	return linkage_fetch_hash_values(database, store, type_name)
}

pub fn linkage_delete(mut database LinkageCacheDatabase, store LinkageCacheStore) {
	database.entries.delete(store.keg_path)
	database.deletes << store.keg_path
}

pub fn linkage_fetch_hash_values(database LinkageCacheDatabase, store LinkageCacheStore,
	type_name string) brew_runtime.Value {
	if store.keg_path !in database.entries {
		return brew_runtime.map_value({})
	}
	return database.entries[store.keg_path][type_name] or {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

fn validate_linkage_cache_values(values map[string]brew_runtime.Value) ! {
	for type_name in values.keys() {
		if type_name !in linkage_cache_types {
			return error("Can't update types that are not defined for the linkage store\n")
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cache_store"
// 5:
// 6: #
// 7: # {LinkageCacheStore} provides methods to fetch and mutate linkage-specific data used
// 8: # by the `brew linkage` command.
// 9: #
// 10: class LinkageCacheStore < CacheStore
// 11:   Key = type_member { { fixed: String } }
// 12:   Value = type_member { { fixed: T::Hash[T.any(String, Symbol), T.anything] } }
// 13:
// 14:   sig { params(keg_path: String, database: CacheStoreDatabase[String, T::Hash[T.any(String, Symbol), T.anything]]).void }
// 15:   def initialize(keg_path, database)
// 16:     @keg_path = keg_path
// 17:     super(database)
// 18:   end
// 19:
// 20:   # Returns `true` if the database has any value for the current `keg_path`.
// 21:   sig { returns(T::Boolean) }
// 22:   def keg_exists?
// 23:     !database.get(@keg_path).nil?
// 24:   end
// 25:
// 26:   # Inserts dylib-related information into the cache if it does not exist or
// 27:   # updates data into the linkage cache if it does exist.
// 28:   #
// 29:   # @param hash_values hash containing KVPs of { :type => Hash }
// 30:   sig { params(hash_values: T::Hash[Symbol, T.anything]).void }
// 31:   def update!(hash_values)
// 32:     hash_values.each_key do |type|
// 33:       next if HASH_LINKAGE_TYPES.include?(type)
// 34:
// 35:       raise TypeError, <<~EOS
// 36:         Can't update types that are not defined for the linkage store
// 37:       EOS
// 38:     end
// 39:
// 40:     database.set @keg_path, hash_values
// 41:   end
// 42:
// 43:   # @param type the type to fetch from the {LinkageCacheStore}
// 44:   # @raise  [TypeError] error if the type is not in `HASH_LINKAGE_TYPES`
// 45:   sig { params(type: Symbol).returns(T.untyped) }
// 46:   def fetch(type)
// 47:     unless HASH_LINKAGE_TYPES.include?(type)
// 48:       raise TypeError, <<~EOS
// 49:         Can't fetch types that are not defined for the linkage store
// 50:       EOS
// 51:     end
// 52:
// 53:     return {} unless keg_exists?
// 54:
// 55:     fetch_hash_values(type)
// 56:   end
// 57:
// 58:   # Delete the keg from the {LinkageCacheStore}.
// 59:   sig { void }
// 60:   def delete!
// 61:     database.delete(@keg_path)
// 62:   end
// 63:
// 64:   private
// 65:
// 66:   HASH_LINKAGE_TYPES = [:keg_files_dylibs].freeze
// 67:   private_constant :HASH_LINKAGE_TYPES
// 68:
// 69:   sig { params(type: Symbol).returns(T.untyped) }
// 70:   def fetch_hash_values(type)
// 71:     keg_cache = database.get(@keg_path)
// 72:     return {} unless keg_cache
// 73:
// 74:     keg_cache[type.to_s]
// 75:   end
// 76: end
