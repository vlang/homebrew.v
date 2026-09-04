module homebrew

import ruby

const linkage_cache_types = ['keg_files_dylibs']

pub struct LinkageCacheStore {
pub:
	keg_path string
}

pub struct LinkageCacheDatabase {
pub mut:
	entries map[string]map[string]ruby.Value
	sets    []string
	deletes []string
}

// Translated from Homebrew/brew `linkage_cache_store.rb`.

pub fn new_linkage_cache_store(keg_path string) LinkageCacheStore {
	return LinkageCacheStore{ keg_path: keg_path }
}

pub fn linkage_keg_exists(store LinkageCacheStore, database LinkageCacheDatabase) bool {
	return store.keg_path in database.entries
}

pub fn linkage_update(mut database LinkageCacheDatabase, store LinkageCacheStore,
	values map[string]ruby.Value) ! {
	validate_linkage_cache_values(values)!
	database.entries[store.keg_path] = values.clone()
	database.sets << store.keg_path
}

pub fn linkage_fetch(database LinkageCacheDatabase, store LinkageCacheStore,
	type_name string) !ruby.Value {
	if type_name !in linkage_cache_types {
		return error("Can't fetch types that are not defined for the linkage store\n")
	}
	if store.keg_path !in database.entries {
		return ruby.map_value({})
	}
	return linkage_fetch_hash_values(database, store, type_name)
}

pub fn linkage_delete(mut database LinkageCacheDatabase, store LinkageCacheStore) {
	database.entries.delete(store.keg_path)
	database.deletes << store.keg_path
}

pub fn linkage_fetch_hash_values(database LinkageCacheDatabase, store LinkageCacheStore,
	type_name string) ruby.Value {
	if store.keg_path !in database.entries {
		return ruby.map_value({})
	}
	return database.entries[store.keg_path][type_name] or {
		ruby.object_value('NilClass', 'nil')
	}
}

fn validate_linkage_cache_values(values map[string]ruby.Value) ! {
	for type_name in values.keys() {
		if type_name !in linkage_cache_types {
			return error("Can't update types that are not defined for the linkage store\n")
		}
	}
}
