module cache_store

import ruby

// Translated from Homebrew/brew `cache_store/cache_store.rb`.
// The original source is retained below until every stub has a typed V body.

// CacheStore is the typed base object shared by persistent cache backends. The
// concrete database remains a boundary Value because the Ruby class is generic
// over both its key and value types.
pub struct CacheStore {
	database_value ruby.Value
}

pub fn new_cache_store(database ruby.Value) CacheStore {
	return CacheStore{
		database_value: database
	}
}

// database exposes the protected Ruby reader to translated subclasses.
pub fn (store CacheStore) database() ruby.Value {
	return store.database_value
}

pub fn cache_store_value(store CacheStore) ruby.Value {
	return ruby.Value{
		type_name: 'CacheStore'
		repr: '#<CacheStore>'
		map_data: {
			'database': store.database()
		}
	}
}

pub fn cache_store_from_value(value ruby.Value) !CacheStore {
	if value.type_name != 'CacheStore' {
		return error('expected CacheStore, got ${value.type_name}')
	}
	database := value.map_data['database'] or {
		return error('CacheStore has no `database` value')
	}
	return new_cache_store(database)
}

// Ruby method `initialize(database)` at line 18.
pub fn ruby_cache_store_l18_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len != 1 {
		return ruby.object_value('ArgumentError', 'CacheStore#initialize requires one database')
	}
	return cache_store_value(new_cache_store(args[0]))
}

// Ruby attr_reader `attr_reader :database` at line 25.
pub fn ruby_cache_store_l25_d2_database(args ...ruby.Value) ruby.Value {
	if args.len != 1 {
		return ruby.object_value('ArgumentError', 'CacheStore#database requires a receiver')
	}
	store := cache_store_from_value(args[0]) or {
		return ruby.object_value('TypeError', err.msg())
	}
	return store.database()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: #
// 5: # {CacheStore} provides methods to mutate and fetch data from a persistent
// 6: # storage mechanism.
// 7: #
// 8: class CacheStore
// 9:   extend T::Generic
// 10:   extend T::Helpers
// 11:
// 12:   abstract!
// 13:
// 14:   Key = type_member
// 15:   Value = type_member
// 16:
// 17:   sig { params(database: CacheStoreDatabase[Key, Value]).void }
// 18:   def initialize(database)
// 19:     @database = database
// 20:   end
// 21:
// 22:   protected
// 23:
// 24:   sig { returns(CacheStoreDatabase[Key, Value]) }
// 25:   attr_reader :database
// 26: end
