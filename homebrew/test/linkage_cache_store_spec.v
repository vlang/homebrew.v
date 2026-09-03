module test

import brew_runtime
import homebrew as cache_core

// Translated from Homebrew/brew `test/linkage_cache_store_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:linkage_cache) { described_class.new(keg_name, database) }` at line 7.
pub fn ruby_linkage_cache_store_spec_l7_d1_linkage_cache(args ...brew_runtime.Value) brew_runtime.Value {
	keg_name := if args.len > 0 { args[0].as_string() } else { 'keg_name' }
	return brew_runtime.structured_value('LinkageCacheStore', keg_name, {
		'keg_path': keg_name
	})
}

// Ruby let `let(:keg_name) { "keg_name" }` at line 9.
pub fn ruby_linkage_cache_store_spec_l9_d2_keg_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('keg_name')
}

// Ruby let `let(:database) { instance_double(CacheStoreDatabase, "database") }` at line 10.
pub fn ruby_linkage_cache_store_spec_l10_d3_database(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('CacheStoreDatabase', 'database')
}

// Ruby it `it "returns `true`" do` at line 14.
pub fn ruby_linkage_cache_store_spec_l14_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	store := cache_core.new_linkage_cache_store('keg_name')
	database := cache_core.LinkageCacheDatabase{
		entries: {
			'keg_name': map[string]brew_runtime.Value{}
		}
	}
	return brew_runtime.bool_value(cache_core.linkage_keg_exists(store, database))
}

// Ruby it `it "returns `false`" do` at line 21.
pub fn ruby_linkage_cache_store_spec_l21_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(!cache_core.linkage_keg_exists(cache_core.new_linkage_cache_store('keg_name'), cache_core.LinkageCacheDatabase{}))
}

// Ruby it `it "sets the cache for the `keg_name`" do` at line 30.
pub fn ruby_linkage_cache_store_spec_l30_d6_sets(args ...brew_runtime.Value) brew_runtime.Value {
	store := cache_core.new_linkage_cache_store('keg_name')
	mut database := cache_core.LinkageCacheDatabase{}
	cache_core.linkage_update(mut database, store, {
		'keg_files_dylibs': brew_runtime.map_value({
			'key': brew_runtime.string_array_value(['value'])
		})
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(database.sets == ['keg_name'] && 'keg_name' in database.entries)
}

// Ruby it `it "raises a `TypeError` if a `value` is not a `Hash`" do` at line 37.
pub fn ruby_linkage_cache_store_spec_l37_d7_raises(args ...brew_runtime.Value) brew_runtime.Value {
	mut database := cache_core.LinkageCacheDatabase{}
	cache_core.linkage_update(mut database, cache_core.new_linkage_cache_store('keg_name'), {
		'a_value': brew_runtime.string_array_value(['value'])
	}) or { return brew_runtime.bool_value(err.msg().contains("Can't update types")) }
	return brew_runtime.bool_value(false)
}

// Ruby it `it "calls `delete` on the `database` with `keg_name` as parameter" do` at line 44.
pub fn ruby_linkage_cache_store_spec_l44_d8_calls(args ...brew_runtime.Value) brew_runtime.Value {
	store := cache_core.new_linkage_cache_store('keg_name')
	mut database := cache_core.LinkageCacheDatabase{
		entries: {
			'keg_name': map[string]brew_runtime.Value{}
		}
	}
	cache_core.linkage_delete(mut database, store)
	return brew_runtime.bool_value(database.deletes == ['keg_name'] && 'keg_name' !in database.entries)
}

// Ruby it `it "returns a `Hash` of values" do` at line 52.
pub fn ruby_linkage_cache_store_spec_l52_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	value := cache_core.linkage_fetch(cache_core.LinkageCacheDatabase{}, cache_core.new_linkage_cache_store('keg_name'), 'keg_files_dylibs') or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(value.type_name == 'Hash')
}

// Ruby it `it "raises a `TypeError` if the `type` is not supported" do` at line 59.
pub fn ruby_linkage_cache_store_spec_l59_d10_raises(args ...brew_runtime.Value) brew_runtime.Value {
	cache_core.linkage_fetch(cache_core.LinkageCacheDatabase{}, cache_core.new_linkage_cache_store('keg_name'), 'bad_type') or {
		return brew_runtime.bool_value(err.msg().contains("Can't fetch types"))
	}
	return brew_runtime.bool_value(false)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "linkage_cache_store"
// 5:
// 6: RSpec.describe LinkageCacheStore do
// 7:   subject(:linkage_cache) { described_class.new(keg_name, database) }
// 8:
// 9:   let(:keg_name) { "keg_name" }
// 10:   let(:database) { instance_double(CacheStoreDatabase, "database") }
// 11:
// 12:   describe "#keg_exists?" do
// 13:     context "when `keg_name` exists in cache" do
// 14:       it "returns `true`" do
// 15:         expect(database).to receive(:get).with(keg_name).and_return("")
// 16:         expect(linkage_cache.keg_exists?).to be(true)
// 17:       end
// 18:     end
// 19:
// 20:     context "when `keg_name` does not exist in cache" do
// 21:       it "returns `false`" do
// 22:         expect(database).to receive(:get).with(keg_name).and_return(nil)
// 23:         expect(linkage_cache.keg_exists?).to be(false)
// 24:       end
// 25:     end
// 26:   end
// 27:
// 28:   describe "#update!" do
// 29:     context "when a `value` is a `Hash`" do
// 30:       it "sets the cache for the `keg_name`" do
// 31:         expect(database).to receive(:set).with(keg_name, anything)
// 32:         linkage_cache.update!(keg_files_dylibs: { key: ["value"] })
// 33:       end
// 34:     end
// 35:
// 36:     context "when a `value` is not a `Hash`" do
// 37:       it "raises a `TypeError` if a `value` is not a `Hash`" do
// 38:         expect { linkage_cache.update!(a_value: ["value"]) }.to raise_error(TypeError)
// 39:       end
// 40:     end
// 41:   end
// 42:
// 43:   describe "#delete!" do
// 44:     it "calls `delete` on the `database` with `keg_name` as parameter" do
// 45:       expect(database).to receive(:delete).with(keg_name)
// 46:       linkage_cache.delete!
// 47:     end
// 48:   end
// 49:
// 50:   describe "#fetch" do
// 51:     context "when `HASH_LINKAGE_TYPES.include?(type)`" do
// 52:       it "returns a `Hash` of values" do
// 53:         expect(database).to receive(:get).with(keg_name).and_return(nil)
// 54:         expect(linkage_cache.fetch(:keg_files_dylibs)).to be_an_instance_of(Hash)
// 55:       end
// 56:     end
// 57:
// 58:     context "when `type` is not in `HASH_LINKAGE_TYPES`" do
// 59:       it "raises a `TypeError` if the `type` is not supported" do
// 60:         expect { linkage_cache.fetch(:bad_type) }.to raise_error(TypeError)
// 61:       end
// 62:     end
// 63:   end
// 64: end
