module cache_store

import ruby

// Translated from Homebrew/brew `cache_store/cache_store.rb`.

// CacheStore is the typed base object shared by persistent cache backends. The
// concrete database remains a boundary Value because the Ruby class is generic
// over both its key and value types.
pub struct CacheStore {
	database_value ruby.Value
}

// database exposes the protected Ruby reader to translated subclasses.
pub fn (store CacheStore) database() ruby.Value {
	return store.database_value
}
