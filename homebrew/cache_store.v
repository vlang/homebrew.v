module homebrew

import ruby
import os
import x.json2

// Translated from Homebrew/brew `cache_store.rb`.
pub struct CacheStoreDatabase {
pub:
	type_name  string
	cache_root string
pub mut:
	values map[string]ruby.Value
	loaded bool
	dirty  bool
}

pub struct CacheStoreRegistry {
pub mut:
	databases map[string]CacheStoreDatabase
	counts    map[string]int
}

pub type CacheStoreUseBlock = fn (mut CacheStoreDatabase) !ruby.Value

pub type CacheStorePredicate = fn (string, ruby.Value) bool

pub fn new_cache_store_database(type_name string, cache_root string) CacheStoreDatabase {
	return CacheStoreDatabase{
		type_name: type_name
		cache_root: cache_root
		values: map[string]ruby.Value{}
	}
}

pub fn cache_store_path(type_name string, cache_root string) string {
	return os.join_path(cache_root, '${type_name}.json')
}

fn cache_store_value_to_json(value ruby.Value) json2.Any {
	if value.type_name == 'Bool' {
		return json2.Any(value.bool_data)
	}
	if value.type_name == 'Integer' {
		return json2.Any(value.int_data)
	}
	if value.type_name == 'Float' {
		return json2.Any(value.float_data)
	}
	if value.type_name == 'Array' {
		mut items := []json2.Any{}
		if value.array_data.len > 0 {
			for item in value.array_data {
				items << cache_store_value_to_json(item)
			}
		} else {
			for item in value.string_array_data {
				items << json2.Any(item)
			}
		}
		return json2.Any(items)
	}
	if value.type_name == 'Hash' {
		mut mapped := map[string]json2.Any{}
		for key, item in value.map_data {
			mapped[key] = cache_store_value_to_json(item)
		}
		return json2.Any(mapped)
	}
	return json2.Any(value.repr)
}

fn cache_store_value_from_json(value json2.Any) ruby.Value {
	if value is string {
		return ruby.string_value(value)
	}
	if value is bool {
		return ruby.bool_value(value)
	}
	if value is i64 {
		return ruby.int_value(value)
	}
	if value is f64 {
		if value == f64(i64(value)) {
			return ruby.int_value(i64(value))
		}
		return ruby.float_value(value)
	}
	if value is []json2.Any {
		mut items := []ruby.Value{}
		for item in value {
			items << cache_store_value_from_json(item)
		}
		return ruby.array_value(items)
	}
	if value is map[string]json2.Any {
		mut mapped := map[string]ruby.Value{}
		for key, item in value {
			mapped[key] = cache_store_value_from_json(item)
		}
		return ruby.map_value(mapped)
	}
	return ruby.Value{ type_name: 'NilClass' }
}

fn (mut database CacheStoreDatabase) load() {
	if database.loaded {
		return
	}
	database.loaded = true
	path := database.cache_path()
	if !os.is_file(path) {
		return
	}
	contents := os.read_file(path) or { return }
	decoded := json2.decode[json2.Any](contents) or { return }
	if decoded is map[string]json2.Any {
		mut values := map[string]ruby.Value{}
		for key, value in decoded {
			values[key] = cache_store_value_from_json(value)
		}
		database.values = values.clone()
	}
}

pub fn (database CacheStoreDatabase) cache_path() string {
	return cache_store_path(database.type_name, database.cache_root)
}

pub fn (database CacheStoreDatabase) created() bool {
	return os.exists(database.cache_path())
}

pub fn (mut database CacheStoreDatabase) set(key string, value ruby.Value) {
	database.load()
	database.dirty = true
	database.values[key] = value
}

pub fn (mut database CacheStoreDatabase) get(key string) ?ruby.Value {
	if !database.created() {
		return none
	}
	database.load()
	return database.values[key]
}

pub fn (mut database CacheStoreDatabase) delete(key string) {
	if !database.created() {
		return
	}
	database.load()
	database.dirty = true
	database.values.delete(key)
}

pub fn (mut database CacheStoreDatabase) clear() {
	if !database.created() {
		return
	}
	database.load()
	database.dirty = true
	database.values.clear()
}

pub fn (mut database CacheStoreDatabase) write_if_dirty() ! {
	if !database.dirty {
		return
	}
	os.mkdir_all(os.dir(database.cache_path()))!
	mut encoded := map[string]json2.Any{}
	for key, value in database.values {
		encoded[key] = cache_store_value_to_json(value)
	}
	ruby.atomic_write_file(database.cache_path(), json2.encode(json2.Any(encoded)))!
}

pub fn (database CacheStoreDatabase) mtime() ?i64 {
	if !database.created() {
		return none
	}
	return os.file_last_mod_unix(database.cache_path())
}

pub fn (mut database CacheStoreDatabase) select(predicate CacheStorePredicate) map[string]ruby.Value {
	database.load()
	mut selected := map[string]ruby.Value{}
	for key, value in database.values {
		if predicate(key, value) {
			selected[key] = value
		}
	}
	return selected
}

pub fn (mut database CacheStoreDatabase) empty() bool {
	database.load()
	return database.values.len == 0
}

pub fn (mut database CacheStoreDatabase) keys() []string {
	database.load()
	return database.values.keys()
}

pub fn cache_store_use(mut registry CacheStoreRegistry, type_name string, cache_root string,
	block CacheStoreUseBlock) !ruby.Value {
	mut database := registry.databases[type_name] or {
		new_cache_store_database(type_name, cache_root)
	}
	registry.counts[type_name] = (registry.counts[type_name] or { 0 }) + 1
	result := block(mut database)!
	count := registry.counts[type_name] or { 0 }
	registry.counts[type_name] = if count > 0 { count - 1 } else { 0 }
	if registry.counts[type_name] == 0 {
		database.write_if_dirty()!
		registry.databases.delete(type_name)
	} else {
		registry.databases[type_name] = database
	}
	return result
}
