module cask_loader

import ruby
import homebrew.cask as brew_cask
import os
import time

// Translated from Homebrew/brew `test/cask/cask_loader/from_uri_loader_spec.rb`.
// The original source is retained below for exact boundary auditing.

const from_uri_loader_fixture = '/Users/alex/code/3rd/brew/Library/Homebrew/test/support/fixtures/cask/Casks/local-caffeine.rb'

fn from_uri_loader_temp_cache(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-from-uri-loader-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

pub fn from_uri_loader_spec_try_new(reference brew_cask.CaskLoaderReference, forbid_paths bool,
	cache_path string) ?brew_cask.CaskLoader {
	return brew_cask.ruby_cask_loader_l244_d17_self_try_new(reference, brew_cask.CaskLoaderLookupContext{
		forbid_packages_from_paths: forbid_paths
		cache_path: cache_path
	})
}

pub fn from_uri_loader_spec_load(url string, cache_path string,
	evaluation brew_cask.CaskLoaderEvaluation) !brew_cask.CaskLoaderCask {
	lookup := brew_cask.CaskLoaderLookupContext{
		cache_path: cache_path
	}
	mut loader := brew_cask.ruby_cask_loader_l272_d20_initialize(url, lookup)
	return brew_cask.ruby_cask_loader_l282_d21_load(mut loader, brew_cask.CaskLoaderConfig{}, brew_cask.CaskLoaderLoadContext{
		lookup: lookup
		evaluation: evaluation
	})
}

fn from_uri_loader_spec_rejects_scheme(scheme string, cache_path string) bool {
	from_uri_loader_spec_load('${scheme}://brew.sh/foo.rb', cache_path, brew_cask.CaskLoaderEvaluation{}) or {
		return err.msg().contains('UnsupportedInstallationMethod')
			&& err.msg().contains('Non-checksummed download of foo.rb')
	}
	return false
}

// Ruby it `it "returns a loader when given an URI" do` at line 6.
pub fn ruby_from_uri_loader_spec_l6_d1_returns(args ...ruby.Value) ruby.Value {
	cache_path := if args.len > 0 { args[0].as_string() } else { from_uri_loader_temp_cache('uri') }
	loader := from_uri_loader_spec_try_new(brew_cask.CaskLoaderReference{
		kind: .uri
		value: 'https://brew.sh/'
	}, false, cache_path) or { return ruby.bool_value(false) }
	return ruby.bool_value(loader.kind == .uri && loader.url == 'https://brew.sh/')
}

// Ruby it `it "returns a loader when given a string which can be parsed to a URI" do` at line 10.
pub fn ruby_from_uri_loader_spec_l10_d2_returns(args ...ruby.Value) ruby.Value {
	cache_path := if args.len > 0 {
		args[0].as_string()
	} else {
		from_uri_loader_temp_cache('string')
	}
	loader := from_uri_loader_spec_try_new(brew_cask.CaskLoaderReference{
		kind: .text
		value: 'https://brew.sh/'
	}, false, cache_path) or { return ruby.bool_value(false) }
	return ruby.bool_value(loader.kind == .uri && loader.url == 'https://brew.sh/')
}

// Ruby it `it "returns nil when path loading is disabled" do` at line 14.
pub fn ruby_from_uri_loader_spec_l14_d3_returns(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { from_uri_loader_fixture }
	loader := from_uri_loader_spec_try_new(brew_cask.CaskLoaderReference{
		kind: .uri
		value: 'file://${path}'
	}, true, from_uri_loader_temp_cache('forbidden'))
	return ruby.bool_value(loader == none)
}

// Ruby it `it "returns nil when given a string with Cask contents containing a URL" do` at line 19.
pub fn ruby_from_uri_loader_spec_l19_d4_returns(args ...ruby.Value) ruby.Value {
	_ = args
	content := "cask 'token' do\n  url 'https://brew.sh/'\nend\n"
	loader := from_uri_loader_spec_try_new(brew_cask.CaskLoaderReference{
		kind: .text
		value: content
	}, false, from_uri_loader_temp_cache('content'))
	return ruby.bool_value(loader == none)
}

// Ruby it `it "raises an error when given an https URL" do` at line 29.
pub fn ruby_from_uri_loader_spec_l29_d5_raises(args ...ruby.Value) ruby.Value {
	cache_path := if args.len > 0 {
		args[0].as_string()
	} else {
		from_uri_loader_temp_cache('https')
	}
	return ruby.bool_value(from_uri_loader_spec_rejects_scheme('https', cache_path))
}

// Ruby it `it "raises an error when given an ftp URL" do` at line 36.
pub fn ruby_from_uri_loader_spec_l36_d6_raises(args ...ruby.Value) ruby.Value {
	cache_path := if args.len > 0 { args[0].as_string() } else { from_uri_loader_temp_cache('ftp') }
	return ruby.bool_value(from_uri_loader_spec_rejects_scheme('ftp', cache_path))
}

// Ruby it `it "raises an error when given an sftp URL" do` at line 43.
pub fn ruby_from_uri_loader_spec_l43_d7_raises(args ...ruby.Value) ruby.Value {
	cache_path := if args.len > 0 {
		args[0].as_string()
	} else {
		from_uri_loader_temp_cache('sftp')
	}
	return ruby.bool_value(from_uri_loader_spec_rejects_scheme('sftp', cache_path))
}

// Ruby it `it "does not raise an error when given a file URL", :needs_utils_curl do` at line 50.
pub fn ruby_from_uri_loader_spec_l50_d8_does(args ...ruby.Value) ruby.Value {
	cache_path := if args.len > 0 {
		args[0].as_string()
	} else {
		from_uri_loader_temp_cache('file')
	}
	source_path := if args.len > 1 { args[1].as_string() } else { from_uri_loader_fixture }
	loaded := from_uri_loader_spec_load('file://${source_path}', cache_path, brew_cask.CaskLoaderEvaluation{
		valid: true
		cask: brew_cask.CaskLoaderCask{
			token: 'local-caffeine'
		}
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(loaded.token == 'local-caffeine'
		&& loaded.sourcefile_path == os.join_path(cache_path, os.base(source_path))
		&& loaded.source == os.read_file(source_path) or { '' })
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::CaskLoader::FromURILoader do
// 5:   describe "::try_new" do
// 6:     it "returns a loader when given an URI" do
// 7:       expect(described_class.try_new(URI("https://brew.sh/"))).not_to be_nil
// 8:     end
// 9:
// 10:     it "returns a loader when given a string which can be parsed to a URI" do
// 11:       expect(described_class.try_new("https://brew.sh/")).not_to be_nil
// 12:     end
// 13:
// 14:     it "returns nil when path loading is disabled" do
// 15:       ENV["HOMEBREW_FORBID_PACKAGES_FROM_PATHS"] = "1"
// 16:       expect(described_class.try_new(URI("file://#{TEST_FIXTURE_DIR}/cask/Casks/local-caffeine.rb"))).to be_nil
// 17:     end
// 18:
// 19:     it "returns nil when given a string with Cask contents containing a URL" do
// 20:       expect(described_class.try_new(<<~RUBY)).to be_nil
// 21:         cask 'token' do
// 22:           url 'https://brew.sh/'
// 23:         end
// 24:       RUBY
// 25:     end
// 26:   end
// 27:
// 28:   describe "::load" do
// 29:     it "raises an error when given an https URL" do
// 30:       loader = described_class.new("https://brew.sh/foo.rb")
// 31:       expect do
// 32:         loader.load(config: nil)
// 33:       end.to raise_error(UnsupportedInstallationMethod)
// 34:     end
// 35:
// 36:     it "raises an error when given an ftp URL" do
// 37:       loader = described_class.new("ftp://brew.sh/foo.rb")
// 38:       expect do
// 39:         loader.load(config: nil)
// 40:       end.to raise_error(UnsupportedInstallationMethod)
// 41:     end
// 42:
// 43:     it "raises an error when given an sftp URL" do
// 44:       loader = described_class.new("sftp://brew.sh/foo.rb")
// 45:       expect do
// 46:         loader.load(config: nil)
// 47:       end.to raise_error(UnsupportedInstallationMethod)
// 48:     end
// 49:
// 50:     it "does not raise an error when given a file URL", :needs_utils_curl do
// 51:       loader = described_class.new("file://#{TEST_FIXTURE_DIR}/cask/Casks/local-caffeine.rb")
// 52:       expect do
// 53:         loader.load(config: nil)
// 54:       end.not_to raise_error
// 55:     end
// 56:   end
// 57: end
