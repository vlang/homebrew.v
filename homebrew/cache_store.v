module homebrew

import brew_runtime
import os
import x.json2

// Translated from Homebrew/brew `cache_store.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CacheStoreDatabase {
pub:
	type_name  string
	cache_root string
pub mut:
	values map[string]brew_runtime.Value
	loaded bool
	dirty  bool
}

pub struct CacheStoreRegistry {
pub mut:
	databases map[string]CacheStoreDatabase
	counts    map[string]int
}

pub type CacheStoreUseBlock = fn(mut CacheStoreDatabase) !brew_runtime.Value

pub type CacheStorePredicate = fn(string, brew_runtime.Value) bool

pub fn new_cache_store_database(type_name string, cache_root string) CacheStoreDatabase {
	return CacheStoreDatabase{
		type_name: type_name
		cache_root: cache_root
		values: map[string]brew_runtime.Value{}
	}
}

pub fn cache_store_path(type_name string, cache_root string) string {
	return os.join_path(cache_root, '${type_name}.json')
}

fn cache_store_value_to_json(value brew_runtime.Value) json2.Any {
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

fn cache_store_value_from_json(value json2.Any) brew_runtime.Value {
	if value is string {
		return brew_runtime.string_value(value)
	}
	if value is bool {
		return brew_runtime.bool_value(value)
	}
	if value is i64 {
		return brew_runtime.int_value(value)
	}
	if value is f64 {
		if value == f64(i64(value)) {
			return brew_runtime.int_value(i64(value))
		}
		return brew_runtime.float_value(value)
	}
	if value is []json2.Any {
		mut items := []brew_runtime.Value{}
		for item in value {
			items << cache_store_value_from_json(item)
		}
		return brew_runtime.array_value(items)
	}
	if value is map[string]json2.Any {
		mut mapped := map[string]brew_runtime.Value{}
		for key, item in value {
			mapped[key] = cache_store_value_from_json(item)
		}
		return brew_runtime.map_value(mapped)
	}
	return brew_runtime.Value{ type_name: 'NilClass' }
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
		mut values := map[string]brew_runtime.Value{}
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

pub fn (mut database CacheStoreDatabase) set(key string, value brew_runtime.Value) {
	database.load()
	database.dirty = true
	database.values[key] = value
}

pub fn (mut database CacheStoreDatabase) get(key string) ?brew_runtime.Value {
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
	brew_runtime.atomic_write_file(database.cache_path(), json2.encode(json2.Any(encoded)))!
}

pub fn (database CacheStoreDatabase) mtime() ?i64 {
	if !database.created() {
		return none
	}
	return os.file_last_mod_unix(database.cache_path())
}

pub fn (mut database CacheStoreDatabase) select(predicate CacheStorePredicate) map[string]brew_runtime.Value {
	database.load()
	mut selected := map[string]brew_runtime.Value{}
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
	block CacheStoreUseBlock) !brew_runtime.Value {
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

// Ruby method `self.use(type, &_blk)` at line 26.
pub fn ruby_cache_store_l26_d1_self_use(mut registry CacheStoreRegistry, type_name string,
	cache_root string, block CacheStoreUseBlock) !brew_runtime.Value {
	return cache_store_use(mut registry, type_name, cache_root, block)
}

// Ruby method `initialize(type)` at line 53.
pub fn ruby_cache_store_l53_d2_initialize(type_name string,
	cache_root string) CacheStoreDatabase {
	return new_cache_store_database(type_name, cache_root)
}

// Ruby method `set(key, value)` at line 60.
pub fn ruby_cache_store_l60_d3_set(mut database CacheStoreDatabase, key string,
	value brew_runtime.Value) {
	database.set(key, value)
}

// Ruby method `get(key)` at line 67.
pub fn ruby_cache_store_l67_d4_get(mut database CacheStoreDatabase,
	key string) ?brew_runtime.Value {
	return database.get(key)
}

// Ruby method `delete(key)` at line 75.
pub fn ruby_cache_store_l75_d5_delete(mut database CacheStoreDatabase, key string) {
	database.delete(key)
}

// Ruby method `clear!` at line 84.
pub fn ruby_cache_store_l84_d6_clear(mut database CacheStoreDatabase) {
	database.clear()
}

// Ruby method `write_if_dirty!` at line 93.
pub fn ruby_cache_store_l93_d7_write_if_dirty(mut database CacheStoreDatabase) ! {
	database.write_if_dirty()!
}

// Ruby method `created?` at line 102.
pub fn ruby_cache_store_l102_d8_created(database CacheStoreDatabase) bool {
	return database.created()
}

// Ruby method `mtime` at line 108.
pub fn ruby_cache_store_l108_d9_mtime(database CacheStoreDatabase) ?i64 {
	return database.mtime()
}

// Ruby method `select(&block)` at line 118.
pub fn ruby_cache_store_l118_d10_select(mut database CacheStoreDatabase,
	predicate CacheStorePredicate) map[string]brew_runtime.Value {
	return database.select(predicate)
}

// Ruby method `empty?` at line 124.
pub fn ruby_cache_store_l124_d11_empty(mut database CacheStoreDatabase) bool {
	return database.empty()
}

// Ruby method `each_key(&block)` at line 132.
pub fn ruby_cache_store_l132_d12_each_key(mut database CacheStoreDatabase) []string {
	return database.keys()
}

// Ruby attr_writer `attr_writer :db` at line 137.
pub fn ruby_cache_store_l137_d13_db(mut database CacheStoreDatabase,
	values ?map[string]brew_runtime.Value) {
	if assigned := values {
		database.values = assigned.clone()
		database.loaded = true
	} else {
		database.values = map[string]brew_runtime.Value{}
		database.loaded = false
	}
}

// Ruby method `db` at line 145.
pub fn ruby_cache_store_l145_d14_db(mut database CacheStoreDatabase) map[string]brew_runtime.Value {
	database.load()
	return database.values.clone()
}

// Ruby method `cache_path` at line 161.
pub fn ruby_cache_store_l161_d15_cache_path(database CacheStoreDatabase) string {
	return database.cache_path()
}

// Ruby method `dirty!` at line 167.
pub fn ruby_cache_store_l167_d16_dirty(mut database CacheStoreDatabase) {
	database.dirty = true
}

// Ruby method `dirty?` at line 173.
pub fn ruby_cache_store_l173_d17_dirty(database CacheStoreDatabase) bool {
	return database.dirty
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5:
// 6: #
// 7: # {CacheStoreDatabase} acts as an interface to a persistent storage mechanism
// 8: # residing in the `HOMEBREW_CACHE`.
// 9: #
// 10: class CacheStoreDatabase
// 11:   extend T::Generic
// 12:
// 13:   Key = type_member
// 14:   Value = type_member
// 15:
// 16:   # Yields the cache store database.
// 17:   # Closes the database after use if it has been loaded.
// 18:   sig {
// 19:     type_parameters(:U)
// 20:       .params(
// 21:         type: Symbol,
// 22:         _blk: T.proc.params(arg0: CacheStoreDatabase[T.anything, T.anything]).returns(T.type_parameter(:U)),
// 23:       )
// 24:       .returns(T.type_parameter(:U))
// 25:   }
// 26:   def self.use(type, &_blk)
// 27:     @db_type_reference_hash ||= T.let({}, T.nilable(T::Hash[T.untyped, T.untyped]))
// 28:     @db_type_reference_hash[type] ||= {}
// 29:     type_ref = @db_type_reference_hash[type]
// 30:
// 31:     type_ref[:count] ||= 0
// 32:     type_ref[:count]  += 1
// 33:
// 34:     type_ref[:db] ||= CacheStoreDatabase.new(type)
// 35:
// 36:     return_value = yield(type_ref[:db])
// 37:     if type_ref[:count].positive?
// 38:       type_ref[:count] -= 1
// 39:     else
// 40:       type_ref[:count] = 0
// 41:     end
// 42:
// 43:     if type_ref[:count].zero?
// 44:       type_ref[:db].write_if_dirty!
// 45:       type_ref.delete(:db)
// 46:     end
// 47:
// 48:     return_value
// 49:   end
// 50:
// 51:   # Creates a CacheStoreDatabase.
// 52:   sig { params(type: Symbol).void }
// 53:   def initialize(type)
// 54:     @type = type
// 55:     @dirty = T.let(false, T.nilable(T::Boolean))
// 56:   end
// 57:
// 58:   # Sets a value in the underlying database (and creates it if necessary).
// 59:   sig { params(key: Key, value: Value).void }
// 60:   def set(key, value)
// 61:     dirty!
// 62:     db[key] = value
// 63:   end
// 64:
// 65:   # Gets a value from the underlying database (if it already exists).
// 66:   sig { params(key: Key).returns(T.nilable(Value)) }
// 67:   def get(key)
// 68:     return unless created?
// 69:
// 70:     db[key]
// 71:   end
// 72:
// 73:   # Deletes a value from the underlying database (if it already exists).
// 74:   sig { params(key: Key).void }
// 75:   def delete(key)
// 76:     return unless created?
// 77:
// 78:     dirty!
// 79:     db.delete(key)
// 80:   end
// 81:
// 82:   # Deletes all content from the underlying database (if it already exists).
// 83:   sig { void }
// 84:   def clear!
// 85:     return unless created?
// 86:
// 87:     dirty!
// 88:     db.clear
// 89:   end
// 90:
// 91:   # Closes the underlying database (if it is created and open).
// 92:   sig { void }
// 93:   def write_if_dirty!
// 94:     return unless dirty?
// 95:
// 96:     cache_path.dirname.mkpath
// 97:     cache_path.atomic_write(JSON.dump(@db))
// 98:   end
// 99:
// 100:   # Returns `true` if the cache file has been created for the given `@type`.
// 101:   sig { returns(T::Boolean) }
// 102:   def created?
// 103:     cache_path.exist?
// 104:   end
// 105:
// 106:   # Returns the modification time of the cache file (if it already exists).
// 107:   sig { returns(T.nilable(Time)) }
// 108:   def mtime
// 109:     return unless created?
// 110:
// 111:     cache_path.mtime
// 112:   end
// 113:
// 114:   # Performs a `select` on the underlying database.
// 115:   sig {
// 116:     overridable.params(block: T.proc.params(arg0: Key, arg1: Value).returns(BasicObject)).returns(T::Hash[Key, Value])
// 117:   }
// 118:   def select(&block)
// 119:     db.select(&block)
// 120:   end
// 121:
// 122:   # Returns `true` if the cache is empty.
// 123:   sig { returns(T::Boolean) }
// 124:   def empty?
// 125:     db.empty?
// 126:   end
// 127:
// 128:   # Performs a `each_key` on the underlying database.
// 129:   sig {
// 130:     params(block: T.proc.params(arg0: Key).returns(BasicObject)).returns(T::Hash[Key, Value])
// 131:   }
// 132:   def each_key(&block)
// 133:     db.each_key(&block)
// 134:   end
// 135:
// 136:   sig { params(db: T.nilable(T::Hash[Key, Value])).void }
// 137:   attr_writer :db
// 138:
// 139:   private
// 140:
// 141:   # Lazily loaded database in read/write mode. If this method is called, a
// 142:   # database file will be created in the `HOMEBREW_CACHE` with a name
// 143:   # corresponding to the `@type` instance variable.
// 144:   sig { returns(T::Hash[Key, Value]) }
// 145:   def db
// 146:     @db ||= T.let({}, T.nilable(T::Hash[Key, Value]))
// 147:     return @db if !@db.empty? || !created?
// 148:
// 149:     begin
// 150:       result = JSON.parse(cache_path.read)
// 151:       @db = result if result.is_a?(Hash)
// 152:     rescue JSON::ParserError
// 153:       # Ignore parse errors
// 154:     end
// 155:     @db
// 156:   end
// 157:
// 158:   # The path where the database resides in the `HOMEBREW_CACHE` for the given
// 159:   # `@type`.
// 160:   sig { returns(Pathname) }
// 161:   def cache_path
// 162:     HOMEBREW_CACHE/"#{@type}.json"
// 163:   end
// 164:
// 165:   # Sets that the cache needs to be written to disk.
// 166:   sig { void }
// 167:   def dirty!
// 168:     @dirty = true
// 169:   end
// 170:
// 171:   # Returns `true` if the cache needs to be written to disk.
// 172:   sig { returns(T::Boolean) }
// 173:   def dirty?
// 174:     !!@dirty
// 175:   end
// 176: end
// 177: require "cache_store/cache_store"
