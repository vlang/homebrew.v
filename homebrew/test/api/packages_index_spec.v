module api

import ruby
import homebrew.api as package_api
import os
import x.json2

// Translated from Homebrew/brew `test/api/packages_index_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cache_dir) { mktmpdir }` at line 7.
pub fn ruby_packages_index_spec_l7_d1_cache_dir(args ...ruby.Value) ruby.Value {
	return ruby.string_value(packages_spec_root('cache-dir'))
}

// Ruby let `let(:target) { cache_dir/"packages.arm64_test.jws.json" }` at line 8.
pub fn ruby_packages_index_spec_l8_d2_target(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { packages_spec_root('target') }
	return ruby.string_value(os.join_path(root, 'packages.arm64_test.jws.json'))
}

// Ruby let `let(:parsed) do` at line 9.
pub fn ruby_packages_index_spec_l9_d3_parsed(args ...ruby.Value) ruby.Value {
	return packages_spec_parsed()
}

// Ruby let `let(:payload) { JSON.generate(parsed) }` at line 22.
pub fn ruby_packages_index_spec_l22_d4_payload(args ...ruby.Value) ruby.Value {
	parsed := if args.len > 0 { args[0] } else { packages_spec_parsed() }
	return ruby.string_value(json2.encode(ruby.json_any_from_value(parsed)))
}

// Ruby method `write_index!` at line 24.
pub fn ruby_packages_index_spec_l24_d5_write_index(args ...ruby.Value) ruby.Value {
	root := packages_spec_root('write-helper')
	defer { os.rmdir_all(root) or {} }
	_, _, ok := packages_spec_write_index(root)
	return ruby.bool_value(ok)
}

// Ruby method `load_index` at line 29.
pub fn ruby_packages_index_spec_l29_d6_load_index(args ...ruby.Value) ruby.Value {
	root := packages_spec_root('load-helper')
	defer { os.rmdir_all(root) or {} }
	target, payload, ok := packages_spec_write_index(root)
	if !ok {
		return packages_spec_bool(false)
	}
	stat := package_api.packages_source_stat(target) or { return packages_spec_bool(false) }
	return packages_spec_bool(package_api.packages_index_load(target, payload, stat) != none)
}

// Ruby it `it "serves entries and top-level values from a written index" do` at line 33.
pub fn ruby_packages_index_spec_l33_d7_serves(args ...ruby.Value) ruby.Value {
	root := packages_spec_root('serves')
	defer { os.rmdir_all(root) or {} }
	target, payload, ok := packages_spec_write_index(root)
	if !ok {
		return packages_spec_bool(false)
	}
	stat := package_api.packages_source_stat(target) or { return packages_spec_bool(false) }
	index := package_api.packages_index_load(target, payload, stat) or { return packages_spec_bool(false) }
	foo := package_api.packages_index_formula_hash(index, 'foo') or { return packages_spec_bool(false) }
	bar := package_api.packages_index_formula_hash(index, 'bar') or { return packages_spec_bool(false) }
	cask := package_api.packages_index_cask_hash(index, 'foo') or { return packages_spec_bool(false) }
	missing := package_api.packages_index_formula_hash(index, 'missing') or { return packages_spec_bool(false) }
	aliases := package_api.packages_index_top_level_value(index, 'formula_aliases') or {
		return packages_spec_bool(false)
	}
	head := package_api.packages_index_top_level_value(index, 'formula_tap_git_head') or {
		return packages_spec_bool(false)
	}
	section := package_api.packages_index_top_level_value(index, 'formulae') or {
		return packages_spec_bool(false)
	}
	return packages_spec_bool(foo.present && foo.value.map_data['desc'].as_string() == 'Foo formula' && bar.present && bar.value.map_data['desc'].as_string() == 'Bar‑formula' && cask.present && cask.value.map_data['version'].as_string() == '2.0.0' && !missing.present && package_api.packages_index_formula_names(index) == [
		'foo',
		'bar',
	] && package_api.packages_index_cask_name(index, 'foo') && aliases.present && aliases.value.map_data['foo-alias'].as_string() == 'foo' && head.present && head.value.as_string().starts_with('b871900') && !section.present)
}

// Ruby it `it "does not load an index whose source envelope changed" do` at line 49.
pub fn ruby_packages_index_spec_l49_d8_does(args ...ruby.Value) ruby.Value {
	root := packages_spec_root('source-changed')
	defer { os.rmdir_all(root) or {} }
	target, payload, ok := packages_spec_write_index(root)
	if !ok {
		return packages_spec_bool(false)
	}
	before := os.stat(target) or { return packages_spec_bool(false) }
	os.utime(target, before.atime, before.mtime + 1) or { return packages_spec_bool(false) }
	stat := package_api.packages_source_stat(target) or { return packages_spec_bool(false) }
	return packages_spec_bool(package_api.packages_index_load(target, payload, stat) == none)
}

// Ruby it `it "does not load an index built for a different payload" do` at line 56.
pub fn ruby_packages_index_spec_l56_d9_does(args ...ruby.Value) ruby.Value {
	root := packages_spec_root('different-payload')
	defer { os.rmdir_all(root) or {} }
	target, payload, ok := packages_spec_write_index(root)
	if !ok {
		return packages_spec_bool(false)
	}
	stat := package_api.packages_source_stat(target) or { return packages_spec_bool(false) }
	return packages_spec_bool(package_api.packages_index_load(target, '${payload} ', stat) == none)
}

// Ruby it `it "raises on lookups whose recorded offsets do not match the payload" do` at line 62.
pub fn ruby_packages_index_spec_l62_d10_raises(args ...ruby.Value) ruby.Value {
	root := packages_spec_root('wrong-offset')
	defer { os.rmdir_all(root) or {} }
	target, payload, ok := packages_spec_write_index(root)
	if !ok {
		return packages_spec_bool(false)
	}
	index_path := package_api.packages_index_path_for(target)
	data := ruby.parse_json_value(os.read_file(index_path) or { return packages_spec_bool(false) }) or {
		return packages_spec_bool(false)
	}
	mut root_values := data.map_data.clone()
	mut formulae := (root_values['formulae'] or { return packages_spec_bool(false) }).map_data.clone()
	formulae['foo'] = formulae['bar'] or { return packages_spec_bool(false) }
	root_values['formulae'] = ruby.map_value(formulae)
	packages_spec_write_json(index_path, ruby.map_value(root_values)) or {
		return packages_spec_bool(false)
	}
	stat := package_api.packages_source_stat(target) or { return packages_spec_bool(false) }
	index := package_api.packages_index_load(target, payload, stat) or { return packages_spec_bool(false) }
	package_api.packages_index_formula_hash(index, 'foo') or {
		return packages_spec_bool(err.msg().contains('does not match the payload'))
	}
	return packages_spec_bool(false)
}

// Ruby it `it "raises on lookups remapped to a matching key in another section" do` at line 72.
pub fn ruby_packages_index_spec_l72_d11_raises(args ...ruby.Value) ruby.Value {
	root := packages_spec_root('cross-section')
	defer { os.rmdir_all(root) or {} }
	target, payload, ok := packages_spec_write_index(root)
	if !ok {
		return packages_spec_bool(false)
	}
	index_path := package_api.packages_index_path_for(target)
	data := ruby.parse_json_value(os.read_file(index_path) or { return packages_spec_bool(false) }) or {
		return packages_spec_bool(false)
	}
	mut root_values := data.map_data.clone()
	mut formulae := (root_values['formulae'] or { return packages_spec_bool(false) }).map_data.clone()
	casks := (root_values['casks'] or { return packages_spec_bool(false) }).map_data.clone()
	formulae['foo'] = casks['foo'] or { return packages_spec_bool(false) }
	root_values['formulae'] = ruby.map_value(formulae)
	packages_spec_write_json(index_path, ruby.map_value(root_values)) or {
		return packages_spec_bool(false)
	}
	stat := package_api.packages_source_stat(target) or { return packages_spec_bool(false) }
	index := package_api.packages_index_load(target, payload, stat) or { return packages_spec_bool(false) }
	package_api.packages_index_formula_hash(index, 'foo') or {
		return packages_spec_bool(err.msg().contains('does not match the payload'))
	}
	return packages_spec_bool(false)
}

// Ruby it `it "does not load an index whose top-level spans do not tile the payload" do` at line 82.
pub fn ruby_packages_index_spec_l82_d12_does(args ...ruby.Value) ruby.Value {
	root := packages_spec_root('top-level-span')
	defer { os.rmdir_all(root) or {} }
	target, payload, ok := packages_spec_write_index(root)
	if !ok {
		return packages_spec_bool(false)
	}
	index_path := package_api.packages_index_path_for(target)
	data := ruby.parse_json_value(os.read_file(index_path) or { return packages_spec_bool(false) }) or {
		return packages_spec_bool(false)
	}
	mut root_values := data.map_data.clone()
	mut top_level := (root_values['top_level'] or { return packages_spec_bool(false) }).map_data.clone()
	mut formula_location := (top_level['formulae'] or { return packages_spec_bool(false) }).as_array() or {
		return packages_spec_bool(false)
	}
	formula_location[1] = ruby.int_value(i64(payload.len) - formula_location[0].int_data - 1)
	top_level['formulae'] = ruby.array_value(formula_location)
	root_values['top_level'] = ruby.map_value(top_level)
	packages_spec_write_json(index_path, ruby.map_value(root_values)) or {
		return packages_spec_bool(false)
	}
	stat := package_api.packages_source_stat(target) or { return packages_spec_bool(false) }
	return packages_spec_bool(package_api.packages_index_load(target, payload, stat) == none)
}

fn packages_spec_parsed() ruby.Value {
	return ruby.map_value({
		'formulae':             ruby.map_value({
			'foo': ruby.map_value({
				'desc':           ruby.string_value('Foo formula')
				'stable_version': ruby.string_value('1.0.0')
			})
			'bar': ruby.map_value({
				'desc':           ruby.string_value('Bar‑formula')
				'stable_version': ruby.string_value('0.4.0')
			})
		})
		'casks':                ruby.map_value({
			'foo': ruby.map_value({
				'desc':    ruby.string_value('Foo cask')
				'version': ruby.string_value('2.0.0')
			})
		})
		'formula_aliases':      ruby.map_value({
			'foo-alias': ruby.string_value('foo')
		})
		'formula_tap_git_head': ruby.string_value('b871900717ccbb3508ca93fa56e128940b9bd371')
	})
}

fn packages_spec_write_index(root string) (string, string, bool) {
	target := os.join_path(root, 'packages.arm64_test.jws.json')
	os.write_file(target, '{}') or { return target, '', false }
	parsed := packages_spec_parsed()
	payload := json2.encode(ruby.json_any_from_value(parsed))
	stat := package_api.packages_source_stat(target) or { return target, payload, false }
	package_api.packages_index_write(target, payload, parsed, stat, false) or {
		return target, payload, false
	}
	return target, payload, os.is_file(package_api.packages_index_path_for(target))
}

fn packages_spec_write_json(path string, value ruby.Value) ! {
	os.write_file(path, json2.encode(ruby.json_any_from_value(value)))!
}

fn packages_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn packages_spec_root(name string) string {
	root := os.join_path(os.temp_dir(), 'brew-v-packages-index-${name}')
	os.rmdir_all(root) or {}
	os.mkdir_all(root) or { panic(err) }
	return root
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5:
// 6: RSpec.describe Homebrew::API::PackagesIndex do
// 7:   let(:cache_dir) { mktmpdir }
// 8:   let(:target) { cache_dir/"packages.arm64_test.jws.json" }
// 9:   let(:parsed) do
// 10:     {
// 11:       "formulae"             => {
// 12:         "foo" => { "desc" => "Foo formula", "stable_version" => "1.0.0" },
// 13:         "bar" => { "desc" => "Bar‑formula", "stable_version" => "0.4.0" },
// 14:       },
// 15:       "casks"                => {
// 16:         "foo" => { "desc" => "Foo cask", "version" => "2.0.0" },
// 17:       },
// 18:       "formula_aliases"      => { "foo-alias" => "foo" },
// 19:       "formula_tap_git_head" => "b871900717ccbb3508ca93fa56e128940b9bd371",
// 20:     }
// 21:   end
// 22:   let(:payload) { JSON.generate(parsed) }
// 23:
// 24:   def write_index!
// 25:     target.write("{}")
// 26:     described_class.write!(target, payload:, parsed:, source_stat: target.stat)
// 27:   end
// 28:
// 29:   def load_index
// 30:     described_class.load(target, payload:, source_stat: target.stat)
// 31:   end
// 32:
// 33:   it "serves entries and top-level values from a written index" do
// 34:     write_index!
// 35:     index = load_index
// 36:
// 37:     expect(index).not_to be_nil
// 38:     expect(index.formula_hash("foo")).to eq parsed.dig("formulae", "foo")
// 39:     expect(index.formula_hash("bar")).to eq parsed.dig("formulae", "bar")
// 40:     expect(index.cask_hash("foo")).to eq parsed.dig("casks", "foo")
// 41:     expect(index.formula_hash("missing")).to be_nil
// 42:     expect(index.formula_names).to eq %w[foo bar]
// 43:     expect(index.cask_name?("foo")).to be true
// 44:     expect(index.top_level_value("formula_aliases")).to eq parsed["formula_aliases"]
// 45:     expect(index.top_level_value("formula_tap_git_head")).to eq parsed["formula_tap_git_head"]
// 46:     expect(index.top_level_value("formulae")).to be_nil
// 47:   end
// 48:
// 49:   it "does not load an index whose source envelope changed" do
// 50:     write_index!
// 51:     FileUtils.touch target, mtime: target.stat.mtime + 1
// 52:
// 53:     expect(load_index).to be_nil
// 54:   end
// 55:
// 56:   it "does not load an index built for a different payload" do
// 57:     write_index!
// 58:
// 59:     expect(described_class.load(target, payload: "#{payload} ", source_stat: target.stat)).to be_nil
// 60:   end
// 61:
// 62:   it "raises on lookups whose recorded offsets do not match the payload" do
// 63:     write_index!
// 64:     index_path = described_class.path_for(target)
// 65:     data = JSON.parse(index_path.read)
// 66:     data["formulae"]["foo"] = data["formulae"]["bar"]
// 67:     index_path.write(JSON.generate(data))
// 68:
// 69:     expect { load_index.formula_hash("foo") }.to raise_error(Homebrew::API::PackagesIndex::Invalid)
// 70:   end
// 71:
// 72:   it "raises on lookups remapped to a matching key in another section" do
// 73:     write_index!
// 74:     index_path = described_class.path_for(target)
// 75:     data = JSON.parse(index_path.read)
// 76:     data["formulae"]["foo"] = data["casks"]["foo"]
// 77:     index_path.write(JSON.generate(data))
// 78:
// 79:     expect { load_index.formula_hash("foo") }.to raise_error(Homebrew::API::PackagesIndex::Invalid)
// 80:   end
// 81:
// 82:   it "does not load an index whose top-level spans do not tile the payload" do
// 83:     write_index!
// 84:     index_path = described_class.path_for(target)
// 85:     data = JSON.parse(index_path.read)
// 86:     data["top_level"]["formulae"][1] = data["payload_bytesize"] - data["top_level"]["formulae"][0] - 1
// 87:     index_path.write(JSON.generate(data))
// 88:
// 89:     expect(load_index).to be_nil
// 90:   end
// 91: end
