module download_strategies

import ruby
import homebrew.download_strategy
import os
import time

// Translated from Homebrew/brew `test/download_strategies/abstract_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:strategy) { Class.new(described_class).new(url, name, version, **specs) }` at line 7.
pub fn ruby_abstract_spec_l7_d1_strategy(args ...ruby.Value) ruby.Value {
	url := if args.len > 0 { args[0].as_string() } else { 'https://example.com/foo.tar.gz' }
	name := if args.len > 1 { args[1].as_string() } else { 'foo' }
	version := if args.len > 2 && args[2].type_name != 'NilClass' {
		args[2].as_string()
	} else {
		''
	}
	strategy := download_strategy.new_abstract_download_strategy(url, name, version, download_strategy.DownloadMeta{})
	return ruby.structured_value('AbstractDownloadStrategy', strategy.url, {
		'url':     strategy.url
		'name':    strategy.name
		'version': strategy.version
		'cache':   strategy.cache
	})
}

// Ruby let `let(:specs) { {} }` at line 9.
pub fn ruby_abstract_spec_l9_d2_specs(args ...ruby.Value) ruby.Value {
	return ruby.map_value(map[string]ruby.Value{})
}

// Ruby let `let(:name) { "foo" }` at line 10.
pub fn ruby_abstract_spec_l10_d3_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value('foo')
}

// Ruby let `let(:url) { "https://example.com/foo.tar.gz" }` at line 11.
pub fn ruby_abstract_spec_l11_d4_url(args ...ruby.Value) ruby.Value {
	return ruby.string_value('https://example.com/foo.tar.gz')
}

// Ruby let `let(:version) { nil }` at line 12.
pub fn ruby_abstract_spec_l12_d5_version(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby specify `specify "#source_modified_time" do` at line 14.
pub fn ruby_abstract_spec_l14_d6_source_modified_time(args ...ruby.Value) ruby.Value {
	owned := args.len == 0
	root := if owned {
		os.join_path(os.temp_dir(), 'brew-v-abstract-mtime-${os.getpid()}-${time.now().unix_micro()}')
	} else {
		args[0].as_string()
	}
	if owned {
		os.mkdir_all(root) or { return ruby.bool_value(false) }
		os.write_file(os.join_path(root, 'foo'), '') or { return ruby.bool_value(false) }
		os.write_file(os.join_path(root, 'bar'), '') or { return ruby.bool_value(false) }
		os.utime(os.join_path(root, 'foo'), 90, 90) or { return ruby.bool_value(false) }
		os.utime(os.join_path(root, 'bar'), 10, 10) or { return ruby.bool_value(false) }
		os.symlink('not-exist', os.join_path(root, 'baz')) or {
			return ruby.bool_value(false)
		}
	}
	strategy := download_strategy.new_abstract_download_strategy('https://example.com/foo.tar.gz', 'foo', '', download_strategy.DownloadMeta{})
	modified := strategy.source_modified_time(root) or {
		if owned {
			os.rmdir_all(root) or {}
		}
		return ruby.bool_value(false)
	}
	expected := if args.len > 1 { args[1].as_int() or { i64(0) } } else { i64(90) }
	if owned {
		os.rmdir_all(root) or {}
	}
	return ruby.bool_value(modified == expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe AbstractDownloadStrategy do
// 7:   subject(:strategy) { Class.new(described_class).new(url, name, version, **specs) }
// 8:
// 9:   let(:specs) { {} }
// 10:   let(:name) { "foo" }
// 11:   let(:url) { "https://example.com/foo.tar.gz" }
// 12:   let(:version) { nil }
// 13:
// 14:   specify "#source_modified_time" do
// 15:     mktmpdir("mtime").cd do
// 16:       FileUtils.touch "foo", mtime: Time.now - 10
// 17:       FileUtils.touch "bar", mtime: Time.now - 100
// 18:       FileUtils.ln_s "not-exist", "baz"
// 19:       expect(strategy.source_modified_time).to eq(File.mtime("foo"))
// 20:     end
// 21:   end
// 22: end
