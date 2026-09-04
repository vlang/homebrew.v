module test

import ruby
import homebrew
import os
import time

// Translated from Homebrew/brew `test/cache_store_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:sample_db) { described_class.new(:sample) }` at line 7.
pub fn ruby_cache_store_spec_l7_d1_sample_db(cache_root string) homebrew.CacheStoreDatabase {
	return homebrew.new_cache_store_database('sample', cache_root)
}

// Ruby let `let(:type) { :test }` at line 10.
pub fn ruby_cache_store_spec_l10_d2_type() string {
	return 'test'
}

fn cache_store_spec_root() !string {
	root := os.join_path(os.temp_dir(), 'brew-v-cache-store-${os.getpid()}-${time.now().unix_nano()}')
	os.mkdir_all(root)!
	return root
}

fn cache_store_spec_noop(mut _ homebrew.CacheStoreDatabase) !ruby.Value {
	return ruby.Value{ type_name: 'NilClass' }
}

fn cache_store_spec_create_file(database homebrew.CacheStoreDatabase) ! {
	os.mkdir_all(os.dir(database.cache_path()))!
	os.write_file(database.cache_path(), '{}')!
}

// Ruby it `it "creates a new `DatabaseCache` instance" do` at line 12.
pub fn ruby_cache_store_spec_l12_d3_creates() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	mut registry := homebrew.CacheStoreRegistry{}
	_ := homebrew.cache_store_use(mut registry, ruby_cache_store_spec_l10_d2_type(), root, cache_store_spec_noop)!
	return (registry.counts['test'] or { -1 }) == 0 && 'test' !in registry.databases
}

// Ruby let `let(:db) { instance_double(Hash, "db", :[]= => nil) }` at line 23.
pub fn ruby_cache_store_spec_l23_d4_db() map[string]ruby.Value {
	return map[string]ruby.Value{}
}

// Ruby it `it "sets the value in the `CacheStoreDatabase`" do` at line 25.
pub fn ruby_cache_store_spec_l25_d5_sets() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	mut database := ruby_cache_store_spec_l7_d1_sample_db(root)
	cache_store_spec_create_file(database)!
	homebrew.ruby_cache_store_l137_d13_db(mut database, ruby_cache_store_spec_l23_d4_db())
	homebrew.ruby_cache_store_l60_d3_set(mut database, 'foo', ruby.string_value('bar'))
	return database.dirty && (database.values['foo'] or { ruby.Value{} }).repr == 'bar'
}

// Ruby let `let(:db) { instance_double(Hash, "db", :[] => "bar") }` at line 37.
pub fn ruby_cache_store_spec_l37_d6_db() map[string]ruby.Value {
	return {
		'foo': ruby.string_value('bar')
	}
}

// Ruby it `it "gets value in the `CacheStoreDatabase` corresponding to the key" do` at line 39.
pub fn ruby_cache_store_spec_l39_d7_gets() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	mut database := ruby_cache_store_spec_l7_d1_sample_db(root)
	cache_store_spec_create_file(database)!
	homebrew.ruby_cache_store_l137_d13_db(mut database, ruby_cache_store_spec_l37_d6_db())
	value := homebrew.ruby_cache_store_l67_d4_get(mut database, 'foo') or { return false }
	return value.repr == 'bar'
}

// Ruby let `let(:db) { instance_double(Hash, "db", :[] => nil) }` at line 48.
pub fn ruby_cache_store_spec_l48_d8_db() map[string]ruby.Value {
	return map[string]ruby.Value{}
}

// Ruby it `it "does not get value in the `CacheStoreDatabase` corresponding to key" do` at line 54.
pub fn ruby_cache_store_spec_l54_d9_does() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	mut database := ruby_cache_store_spec_l7_d1_sample_db(root)
	return homebrew.ruby_cache_store_l67_d4_get(mut database, 'foo') == none
}

// Ruby it `it "does not call `db[]` if `CacheStoreDatabase.created?` is `false`" do` at line 58.
pub fn ruby_cache_store_spec_l58_d10_does() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	mut database := ruby_cache_store_spec_l7_d1_sample_db(root)
	database.values['foo'] = ruby.string_value('bar')
	return homebrew.ruby_cache_store_l67_d4_get(mut database, 'foo') == none
}

// Ruby let `let(:db) { instance_double(Hash, "db", :[] => { foo: "bar" }) }` at line 67.
pub fn ruby_cache_store_spec_l67_d11_db() map[string]ruby.Value {
	return {
		'foo': ruby.map_value({
			'foo': ruby.string_value('bar')
		})
	}
}

// Ruby it `it "deletes value in the `CacheStoreDatabase` corresponding to the key" do` at line 73.
pub fn ruby_cache_store_spec_l73_d12_deletes() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	mut database := ruby_cache_store_spec_l7_d1_sample_db(root)
	cache_store_spec_create_file(database)!
	homebrew.ruby_cache_store_l137_d13_db(mut database, ruby_cache_store_spec_l67_d11_db())
	homebrew.ruby_cache_store_l75_d5_delete(mut database, 'foo')
	return 'foo' !in database.values && database.dirty
}

// Ruby let `let(:db) { instance_double(Hash, "db", delete: nil) }` at line 80.
pub fn ruby_cache_store_spec_l80_d13_db() map[string]ruby.Value {
	return map[string]ruby.Value{}
}

// Ruby it `it "does not call `db.delete` if `CacheStoreDatabase.created?` is `false`" do` at line 86.
pub fn ruby_cache_store_spec_l86_d14_does() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	mut database := ruby_cache_store_spec_l7_d1_sample_db(root)
	homebrew.ruby_cache_store_l75_d5_delete(mut database, 'foo')
	return !database.dirty
}

// Ruby it `it "does not raise an error when `close` is called on the database" do` at line 95.
pub fn ruby_cache_store_spec_l95_d15_does() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	mut database := ruby_cache_store_spec_l7_d1_sample_db(root)
	homebrew.ruby_cache_store_l93_d7_write_if_dirty(mut database)!
	return true
}

// Ruby it `it "does not raise an error when `close` is called on the database" do` at line 105.
pub fn ruby_cache_store_spec_l105_d16_does() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	mut database := ruby_cache_store_spec_l7_d1_sample_db(root)
	homebrew.ruby_cache_store_l137_d13_db(mut database, none)
	homebrew.ruby_cache_store_l93_d7_write_if_dirty(mut database)!
	return true
}

// Ruby let `let(:cache_path) { Pathname("path/to/homebrew/cache/sample.json") }` at line 112.
pub fn ruby_cache_store_spec_l112_d17_cache_path() string {
	return 'path/to/homebrew/cache/sample.json'
}

// Ruby it `it "returns `true`" do` at line 123.
pub fn ruby_cache_store_spec_l123_d18_returns() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	database := ruby_cache_store_spec_l7_d1_sample_db(root)
	cache_store_spec_create_file(database)!
	return homebrew.ruby_cache_store_l102_d8_created(database)
}

// Ruby it `it "returns `false`" do` at line 133.
pub fn ruby_cache_store_spec_l133_d19_returns() !bool {
	root := cache_store_spec_root()!
	defer { os.rmdir_all(root) or {} }
	database := ruby_cache_store_spec_l7_d1_sample_db(root)
	return !homebrew.ruby_cache_store_l102_d8_created(database)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cache_store"
// 5:
// 6: RSpec.describe CacheStoreDatabase do
// 7:   subject(:sample_db) { described_class.new(:sample) }
// 8:
// 9:   describe "self.use" do
// 10:     let(:type) { :test }
// 11:
// 12:     it "creates a new `DatabaseCache` instance" do
// 13:       cache_store = instance_double(described_class, "cache_store", write_if_dirty!: nil)
// 14:       expect(described_class).to receive(:new).with(type).and_return(cache_store)
// 15:       expect(cache_store).to receive(:write_if_dirty!)
// 16:       described_class.use(type) do |_db|
// 17:         # do nothing
// 18:       end
// 19:     end
// 20:   end
// 21:
// 22:   describe "#set" do
// 23:     let(:db) { instance_double(Hash, "db", :[]= => nil) }
// 24:
// 25:     it "sets the value in the `CacheStoreDatabase`" do
// 26:       allow(File).to receive(:write)
// 27:       allow(sample_db).to receive_messages(created?: true, db:)
// 28:
// 29:       expect(db).to receive(:has_key?).with(:foo).and_return(false)
// 30:       expect(db).not_to have_key(:foo)
// 31:       sample_db.set(:foo, "bar")
// 32:     end
// 33:   end
// 34:
// 35:   describe "#get" do
// 36:     context "with a database created" do
// 37:       let(:db) { instance_double(Hash, "db", :[] => "bar") }
// 38:
// 39:       it "gets value in the `CacheStoreDatabase` corresponding to the key" do
// 40:         expect(db).to receive(:has_key?).with(:foo).and_return(true)
// 41:         allow(sample_db).to receive_messages(created?: true, db:)
// 42:         expect(db).to have_key(:foo)
// 43:         expect(sample_db.get(:foo)).to eq("bar")
// 44:       end
// 45:     end
// 46:
// 47:     context "without a database created" do
// 48:       let(:db) { instance_double(Hash, "db", :[] => nil) }
// 49:
// 50:       before do
// 51:         allow(sample_db).to receive_messages(created?: false, db:)
// 52:       end
// 53:
// 54:       it "does not get value in the `CacheStoreDatabase` corresponding to key" do
// 55:         expect(sample_db.get(:foo)).not_to be("bar")
// 56:       end
// 57:
// 58:       it "does not call `db[]` if `CacheStoreDatabase.created?` is `false`" do
// 59:         expect(db).not_to receive(:[])
// 60:         sample_db.get(:foo)
// 61:       end
// 62:     end
// 63:   end
// 64:
// 65:   describe "#delete" do
// 66:     context "with a database created" do
// 67:       let(:db) { instance_double(Hash, "db", :[] => { foo: "bar" }) }
// 68:
// 69:       before do
// 70:         allow(sample_db).to receive_messages(created?: true, db:)
// 71:       end
// 72:
// 73:       it "deletes value in the `CacheStoreDatabase` corresponding to the key" do
// 74:         expect(db).to receive(:delete).with(:foo)
// 75:         sample_db.delete(:foo)
// 76:       end
// 77:     end
// 78:
// 79:     context "without a database created" do
// 80:       let(:db) { instance_double(Hash, "db", delete: nil) }
// 81:
// 82:       before do
// 83:         allow(sample_db).to receive_messages(created?: false, db:)
// 84:       end
// 85:
// 86:       it "does not call `db.delete` if `CacheStoreDatabase.created?` is `false`" do
// 87:         expect(db).not_to receive(:delete)
// 88:         sample_db.delete(:foo)
// 89:       end
// 90:     end
// 91:   end
// 92:
// 93:   describe "#write_if_dirty!" do
// 94:     context "with an open database" do
// 95:       it "does not raise an error when `close` is called on the database" do
// 96:         expect { sample_db.write_if_dirty! }.not_to raise_error
// 97:       end
// 98:     end
// 99:
// 100:     context "without an open database" do
// 101:       before do
// 102:         sample_db.db = nil
// 103:       end
// 104:
// 105:       it "does not raise an error when `close` is called on the database" do
// 106:         expect { sample_db.write_if_dirty! }.not_to raise_error
// 107:       end
// 108:     end
// 109:   end
// 110:
// 111:   describe "#created?" do
// 112:     let(:cache_path) { Pathname("path/to/homebrew/cache/sample.json") }
// 113:
// 114:     before do
// 115:       allow(sample_db).to receive(:cache_path).and_return(cache_path)
// 116:     end
// 117:
// 118:     context "when `cache_path.exist?` returns `true`" do
// 119:       before do
// 120:         allow(cache_path).to receive(:exist?).and_return(true)
// 121:       end
// 122:
// 123:       it "returns `true`" do
// 124:         expect(sample_db.created?).to be(true)
// 125:       end
// 126:     end
// 127:
// 128:     context "when `cache_path.exist?` returns `false`" do
// 129:       before do
// 130:         allow(cache_path).to receive(:exist?).and_return(false)
// 131:       end
// 132:
// 133:       it "returns `false`" do
// 134:         expect(sample_db.created?).to be(false)
// 135:       end
// 136:     end
// 137:   end
// 138: end
