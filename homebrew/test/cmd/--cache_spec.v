module cmd

import ruby
import homebrew.cmd as cmd_core

fn cache_spec_formula(cache string) cmd_core.FormulaCacheEntry {
	return cmd_core.FormulaCacheEntry{
		full_name: 'testball'
		cached_download: '${cache}/downloads/0123456789abcdef--testball-1.0.tar.gz'
	}
}

fn cache_spec_cask(cache string) cmd_core.CaskCacheEntry {
	return cmd_core.CaskCacheEntry{
		token: 'local-caffeine'
		cached_location: '${cache}/downloads/fedcba9876543210--caffeine.zip'
	}
}

// Translated from Homebrew/brew `test/cmd/--cache_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints all cache files for a given Formula" do` at line 10.
pub fn ruby_cache_spec_l10_d1_prints(args ...ruby.Value) ruby.Value {
	cache := if args.len > 0 { args[0].as_string() } else { '/tmp/cache' }
	result := cmd_core.cache_command(cache, [
		cmd_core.CacheEntry(cache_spec_formula(cache)),
	], [], cmd_core.CacheCommandOptions{})
	return ruby.bool_value(result.paths == [
		cache_spec_formula(cache).cached_download,
	])
}

// Ruby it `it "prints the cache files for a given Cask", :cask do` at line 16.
pub fn ruby_cache_spec_l16_d2_prints(args ...ruby.Value) ruby.Value {
	cache := if args.len > 0 { args[0].as_string() } else { '/tmp/cache' }
	result := cmd_core.cache_command(cache, [
		cmd_core.CacheEntry(cache_spec_cask(cache)),
	], [
		cmd_core.CacheOsArch{
			os: 'macos'
		},
	], cmd_core.CacheCommandOptions{})
	return ruby.bool_value(result.paths == [
		cache_spec_cask(cache).cached_location,
	])
}

// Ruby it `it "prints the cache files for a given Formula and Cask", :integration_test, :needs_macos do` at line 22.
pub fn ruby_cache_spec_l22_d3_prints(args ...ruby.Value) ruby.Value {
	cache := if args.len > 0 { args[0].as_string() } else { '/tmp/cache' }
	formula := cache_spec_formula(cache)
	cask := cache_spec_cask(cache)
	result := cmd_core.cache_command(cache, [cmd_core.CacheEntry(formula), cmd_core.CacheEntry(cask)], [cmd_core.CacheOsArch{
		os: 'macos'
	}], cmd_core.CacheCommandOptions{})
	return ruby.bool_value(result.paths == [formula.cached_download, cask.cached_location])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/--cache"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Cache do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "prints all cache files for a given Formula" do
// 11:     expect { described_class.new(["--formula", (TEST_FIXTURE_DIR/"testball.rb").to_s]).run }
// 12:       .to output(%r{#{HOMEBREW_CACHE}/downloads/[\da-f]{64}--testball-}o).to_stdout
// 13:       .and not_to_output.to_stderr
// 14:   end
// 15:
// 16:   it "prints the cache files for a given Cask", :cask do
// 17:     expect { described_class.new(["--cask", cask_path("local-caffeine").to_s]).run }
// 18:       .to output(%r{#{HOMEBREW_CACHE}/downloads/[\da-f]{64}--caffeine\.zip}o).to_stdout
// 19:       .and not_to_output.to_stderr
// 20:   end
// 21:
// 22:   it "prints the cache files for a given Formula and Cask", :integration_test, :needs_macos do
// 23:     expect { brew "--cache", testball, cask_path("local-caffeine") }
// 24:       .to output(
// 25:         %r{
// 26:           #{HOMEBREW_CACHE}/downloads/[\da-f]{64}--testball-.*\n
// 27:           #{HOMEBREW_CACHE}/downloads/[\da-f]{64}--caffeine\.zip
// 28:         }xo,
// 29:       ).to_stdout
// 30:       .and output(/(Treating .* as a formula).*(Treating .* as a cask)/m).to_stderr
// 31:       .and be_a_success
// 32:   end
// 33: end
