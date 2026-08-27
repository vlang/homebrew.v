module standalone

import brew_runtime

// Translated from Homebrew/brew `standalone/init.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.from_archdir(feature)` at line 42.
pub fn ruby_init_l42_d1_self_from_archdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_archdir', ...args)
}

// Ruby method `self.from_rubylibdir(feature)` at line 46.
pub fn ruby_init_l46_d2_self_from_rubylibdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_rubylibdir', ...args)
}

// Ruby alias_method `kernel_class.alias_method :require, :no_warning_require` at line 94.
pub fn ruby_init_l94_d3_require(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('require', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: # This file is included before any other files.
// 5: # It intentionally has typing disabled and uses `Homebrew::FastBootRequire`
// 6: # or `require_relative` to load all files
// 7: # (except "rbconfig" which is needed by `Homebrew::FastBootRequire`)
// 8:
// 9: required_ruby_major, required_ruby_minor, = ENV.fetch("HOMEBREW_REQUIRED_RUBY_VERSION", "").split(".").map(&:to_i)
// 10: gems_vendored = if required_ruby_minor.nil?
// 11:   # We're likely here if running RuboCop etc, so just assume we don't need to install gems as we likely already have
// 12:   true
// 13: else
// 14:   ruby_major, ruby_minor, = RUBY_VERSION.split(".").map(&:to_i)
// 15:   raise "Could not parse Ruby requirements" if !ruby_major || !ruby_minor || !required_ruby_major
// 16:
// 17:   if ruby_major < required_ruby_major || (ruby_major == required_ruby_major && ruby_minor < required_ruby_minor)
// 18:     raise "Homebrew must be run under Ruby #{required_ruby_major}.#{required_ruby_minor}! " \
// 19:           "You're running #{RUBY_VERSION}."
// 20:   end
// 21:
// 22:   # This list should match .gitignore
// 23:   vendored_versions = ["4.0"].freeze
// 24:   vendored_versions.include?("#{ruby_major}.#{ruby_minor}")
// 25: end.freeze
// 26:
// 27: if ENV["HOMEBREW_DEVELOPER"]
// 28:   Warning.categories.each do |category|
// 29:     Warning[category] = true
// 30:   end
// 31: end
// 32:
// 33: # Setup Homebrew::FastBootRequire for faster boot requires.
// 34: # Inspired by https://github.com/Shopify/bootsnap/wiki/Bootlib::Require
// 35: require "rbconfig"
// 36:
// 37: module Homebrew
// 38:   module FastBootRequire
// 39:     ARCHDIR    = RbConfig::CONFIG["archdir"].freeze
// 40:     RUBYLIBDIR = RbConfig::CONFIG["rubylibdir"].freeze
// 41:
// 42:     def self.from_archdir(feature)
// 43:       require(File.join(ARCHDIR, feature.to_s))
// 44:     end
// 45:
// 46:     def self.from_rubylibdir(feature)
// 47:       require(File.join(RUBYLIBDIR, "#{feature}.rb"))
// 48:     end
// 49:   end
// 50: end
// 51:
// 52: # We trust base Ruby to provide what we need.
// 53: # Don't look into the user-installed sitedir, which may contain older versions of RubyGems.
// 54: $LOAD_PATH.reject! { |path| path.start_with?(RbConfig::CONFIG["sitedir"]) }
// 55:
// 56: Homebrew::FastBootRequire.from_rubylibdir("pathname")
// 57: dir = __dir__ || raise("__dir__ is not defined")
// 58: HOMEBREW_LIBRARY_PATH = Pathname(dir).parent.realpath.freeze
// 59: HOMEBREW_USING_PORTABLE_RUBY = RbConfig.ruby.include?("/vendor/portable-ruby/").freeze
// 60:
// 61: HOMEBREW_BUNDLER_VERSION = ENV.fetch("HOMEBREW_BUNDLER_VERSION").freeze
// 62: ENV["BUNDLER_VERSION"] = HOMEBREW_BUNDLER_VERSION
// 63:
// 64: require_relative "../utils/gem_setup"
// 65: Homebrew.setup_gem_environment!(setup_path: false)
// 66:
// 67: # Install gems for Rubies we don't vendor for.
// 68: if !gems_vendored && !ENV["HOMEBREW_SKIP_INITIAL_GEM_INSTALL"]
// 69:   Homebrew.install_bundler_gems!(setup_path: false)
// 70:   ENV["HOMEBREW_SKIP_INITIAL_GEM_INSTALL"] = "1"
// 71: end
// 72:
// 73: unless $LOAD_PATH.include?(HOMEBREW_LIBRARY_PATH.to_s)
// 74:   # Insert the path after any existing Homebrew paths (e.g. those inserted by tests and parent processes)
// 75:   last_homebrew_path_idx = $LOAD_PATH.rindex do |path|
// 76:     path.start_with?(HOMEBREW_LIBRARY_PATH.to_s) && !path.include?("vendor/portable-ruby")
// 77:   end || -1
// 78:   $LOAD_PATH.insert(last_homebrew_path_idx + 1, HOMEBREW_LIBRARY_PATH.to_s)
// 79: end
// 80: require_relative "../vendor/bundle/bundler/setup"
// 81: Homebrew::FastBootRequire.from_archdir("portable_ruby_gems") if HOMEBREW_USING_PORTABLE_RUBY
// 82: $LOAD_PATH.unshift "#{HOMEBREW_LIBRARY_PATH}/vendor/bundle/#{RUBY_ENGINE}/#{Gem.ruby_api_version}/gems/" \
// 83:                    "bundler-#{HOMEBREW_BUNDLER_VERSION}/lib"
// 84: $LOAD_PATH.uniq!
// 85:
// 86: # These warnings are nice but often flag problems that are not even our responsibly,
// 87: # including in some cases from other Ruby standard library gems.
// 88: # We strictly only allow one version of Ruby at a time so future compatibility
// 89: # doesn't need to be handled ahead of time.
// 90: if defined?(Gem::BUNDLED_GEMS)
// 91:   [Kernel.singleton_class, Kernel].each do |kernel_class|
// 92:     next unless kernel_class.respond_to?(:no_warning_require, true)
// 93:
// 94:     kernel_class.alias_method :require, :no_warning_require
// 95:   end
// 96: end
