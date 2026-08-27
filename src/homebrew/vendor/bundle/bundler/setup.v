module bundler

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/bundler/setup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `gem(*)` at line 5.
pub fn ruby_setup_l5_d1_gem(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gem', ...args)
}

// Ruby method `self.ruby_api_version` at line 12.
pub fn ruby_setup_l12_d2_self_ruby_api_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ruby_api_version', ...args)
}

// Ruby method `self.extension_api_version` at line 16.
pub fn ruby_setup_l16_d3_self_extension_api_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extension_api_version', ...args)
}

// Ruby define_method `k.send(:define_method, :require, k.instance_method(:gem_original_require))` at line 32.
pub fn ruby_setup_l32_d4_require(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('require', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'rbconfig'
// 2: module Kernel
// 3:   remove_method(:gem) if private_method_defined?(:gem)
// 4:
// 5:   def gem(*)
// 6:   end
// 7:
// 8:   private :gem
// 9: end
// 10: unless defined?(Gem)
// 11:   module Gem
// 12:     def self.ruby_api_version
// 13:       RbConfig::CONFIG["ruby_version"]
// 14:     end
// 15:
// 16:     def self.extension_api_version
// 17:       if 'no' == RbConfig::CONFIG['ENABLE_SHARED']
// 18:         "#{ruby_api_version}-static"
// 19:       else
// 20:         ruby_api_version
// 21:       end
// 22:     end
// 23:   end
// 24: end
// 25: if Gem.respond_to?(:discover_gems_on_require=)
// 26:   Gem.discover_gems_on_require = false
// 27: else
// 28:   [::Kernel.singleton_class, ::Kernel].each do |k|
// 29:     if k.private_method_defined?(:gem_original_require)
// 30:       private_require = k.private_method_defined?(:require)
// 31:       k.send(:remove_method, :require)
// 32:       k.send(:define_method, :require, k.instance_method(:gem_original_require))
// 33:       k.send(:private, :require) if private_require
// 34:     end
// 35:   end
// 36: end
// 37: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/ast-2.4.3/lib")
// 38: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/base64-0.3.0/lib")
// 39: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/benchmark-0.5.0/lib")
// 40: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/extensions/arm64-darwin-20/#{Gem.extension_api_version}/bigdecimal-4.1.2")
// 41: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/bigdecimal-4.1.2/lib")
// 42: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/bindata-2.5.1/lib")
// 43: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby")
// 44: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/csv-3.3.6/lib")
// 45: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/diff-lcs-1.6.2/lib")
// 46: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/drb-2.2.3/lib")
// 47: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/elftools-1.3.1/lib")
// 48: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/erubi-1.13.1/lib")
// 49: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/hana-1.3.7/lib")
// 50: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/extensions/arm64-darwin-20/#{Gem.extension_api_version}/json-2.21.2")
// 51: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/json-2.21.2/lib")
// 52: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/regexp_parser-2.12.0/lib")
// 53: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/simpleidn-0.2.3/lib")
// 54: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/json_schemer-2.5.0/lib")
// 55: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rexml-3.4.4/lib")
// 56: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/kramdown-2.5.2/lib")
// 57: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/language_server-protocol-3.17.0.6/lib")
// 58: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/lint_roller-1.1.0/lib")
// 59: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/logger-1.7.0/lib")
// 60: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/extensions/arm64-darwin-20/#{Gem.extension_api_version}/prism-1.9.0")
// 61: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/prism-1.9.0/lib")
// 62: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/minitest-6.0.6/lib")
// 63: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/netrc-0.11.0/lib")
// 64: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/ostruct-0.6.3/lib")
// 65: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/parallel-2.1.0/lib")
// 66: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/parallel_tests-5.7.0/lib")
// 67: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/extensions/arm64-darwin-20/#{Gem.extension_api_version}/racc-1.8.1")
// 68: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/racc-1.8.1/lib")
// 69: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/parser-3.3.12.0/lib")
// 70: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/patchelf-1.6.2/lib")
// 71: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/plist-3.7.2/lib")
// 72: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rainbow-3.1.1/lib")
// 73: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/tsort-0.2.0/lib")
// 74: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/extensions/arm64-darwin-20/#{Gem.extension_api_version}/rbs-4.1.3")
// 75: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rbs-4.1.3/lib")
// 76: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rbi-0.4.3/lib")
// 77: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/require-hooks-0.4.1/lib")
// 78: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rspec-support-3.13.7/lib")
// 79: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rspec-core-3.13.6/lib")
// 80: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rspec-expectations-3.13.5/lib")
// 81: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rspec-mocks-3.13.8/lib")
// 82: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rspec-3.13.2/lib")
// 83: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rspec-github-3.0.0/lib")
// 84: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rspec-retry-0.6.2/lib")
// 85: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/sorbet-runtime-0.6.13412/lib")
// 86: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rspec-sorbet-1.9.2/lib")
// 87: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rspec_junit_formatter-0.6.0/lib")
// 88: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rubocop-ast-1.50.0/lib")
// 89: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/ruby-progressbar-1.13.0/lib")
// 90: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/unicode-emoji-4.2.0/lib")
// 91: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/unicode-display_width-3.2.0/lib")
// 92: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rubocop-1.89.0/lib")
// 93: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rubocop-md-2.0.4/lib")
// 94: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rubocop-performance-1.26.1/lib")
// 95: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rubocop-rspec-3.10.2/lib")
// 96: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rubocop-sorbet-0.14.0/lib")
// 97: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/ruby-lsp-0.26.10/lib")
// 98: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/ruby-macho-6.0.0/lib")
// 99: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/extensions/arm64-darwin-20/#{Gem.extension_api_version}/ruby-prof-2.0.5")
// 100: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/ruby-prof-2.0.5/lib")
// 101: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/rubydex-0.3.0-arm64-darwin/lib")
// 102: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/simplecov-1.0.3/lib")
// 103: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/simplecov-cobertura-4.0.0/lib")
// 104: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/sorbet-static-0.6.13412-universal-darwin/lib")
// 105: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/sorbet-0.6.13412/lib")
// 106: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/sorbet-static-and-runtime-0.6.13412/lib")
// 107: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/thor-1.5.0/lib")
// 108: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/spoom-1.8.7/lib")
// 109: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/extensions/arm64-darwin-20/#{Gem.extension_api_version}/stackprof-0.2.28")
// 110: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/stackprof-0.2.28/lib")
// 111: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/tapioca-0.19.2/lib")
// 112: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/test-prof-1.6.3/lib")
// 113: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/extensions/arm64-darwin-20/#{Gem.extension_api_version}/vernier-1.10.1")
// 114: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/vernier-1.10.1/lib")
// 115: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/yard-0.9.45/lib")
// 116: $:.unshift File.expand_path("#{__dir__}/../#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/yard-sorbet-0.9.0/lib")
