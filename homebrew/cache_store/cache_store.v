module cache_store

import ruby

// Translated from Homebrew/brew `cache_store/cache_store.rb`.

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
