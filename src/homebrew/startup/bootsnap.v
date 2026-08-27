module startup

import brew_runtime

// Translated from Homebrew/brew `startup/bootsnap.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.key` at line 6.
pub fn ruby_bootsnap_l6_d1_self_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.key', ...args)
}

// Ruby method `self.cache_dir` at line 19.
pub fn ruby_bootsnap_l19_d2_self_cache_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cache_dir', ...args)
}

// Ruby method `self.ignore_directories` at line 26.
pub fn ruby_bootsnap_l26_d3_self_ignore_directories(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ignore_directories', ...args)
}

// Ruby method `self.enabled?` at line 36.
pub fn ruby_bootsnap_l36_d4_self_enabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.enabled?', ...args)
}

// Ruby method `self.load!(compile_cache: true)` at line 40.
pub fn ruby_bootsnap_l40_d5_self_load(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.load!', ...args)
}

// Ruby method `self.reset!` at line 63.
pub fn ruby_bootsnap_l63_d6_self_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.reset!', ...args)
}

// Ruby method `self.prewarm!` at line 76.
pub fn ruby_bootsnap_l76_d7_self_prewarm(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.prewarm!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Bootsnap
// 6:     def self.key
// 7:       @key ||= begin
// 8:         require "digest/sha2"
// 9:
// 10:         checksum = Digest::SHA256.new
// 11:         checksum << RUBY_VERSION
// 12:         checksum << RUBY_PLATFORM
// 13:         checksum << Dir.children(File.join(Gem.paths.path, "gems")).join(",")
// 14:
// 15:         checksum.hexdigest
// 16:       end
// 17:     end
// 18:
// 19:     private_class_method def self.cache_dir
// 20:       cache = ENV.fetch("HOMEBREW_CACHE", nil) || ENV.fetch("HOMEBREW_DEFAULT_CACHE", nil)
// 21:       raise "Needs `$HOMEBREW_CACHE` or `$HOMEBREW_DEFAULT_CACHE`!" if cache.nil? || cache.empty?
// 22:
// 23:       File.join(cache, "bootsnap", key)
// 24:     end
// 25:
// 26:     private_class_method def self.ignore_directories
// 27:       # We never do `require "vendor/bundle/ruby/..."` or `require "vendor/portable-ruby/..."`,
// 28:       # so let's slim the cache a bit by excluding them.
// 29:       # Note that gems within `bundle/ruby` will still be cached - these are when directory walking down from above.
// 30:       [
// 31:         (HOMEBREW_LIBRARY_PATH/"vendor/bundle/ruby").to_s,
// 32:         (HOMEBREW_LIBRARY_PATH/"vendor/portable-ruby").to_s,
// 33:       ]
// 34:     end
// 35:
// 36:     private_class_method def self.enabled?
// 37:       !ENV["HOMEBREW_BOOTSNAP_GEM_PATH"].to_s.empty? && ENV["HOMEBREW_NO_BOOTSNAP"].nil?
// 38:     end
// 39:
// 40:     def self.load!(compile_cache: true)
// 41:       return unless enabled?
// 42:
// 43:       begin
// 44:         require ENV.fetch("HOMEBREW_BOOTSNAP_GEM_PATH")
// 45:       rescue LoadError
// 46:         return
// 47:       end
// 48:
// 49:       ::Bootsnap.setup(
// 50:         cache_dir:,
// 51:         ignore_directories:,
// 52:         # In development environments the bootsnap compilation cache is
// 53:         # generated on the fly when source files are loaded.
// 54:         # https://github.com/Shopify/bootsnap?tab=readme-ov-file#precompilation
// 55:         development_mode:   true,
// 56:         load_path_cache:    true,
// 57:         # Ruby refuses InstructionSequence#to_binary while Coverage is active.
// 58:         compile_cache_iseq: compile_cache && ENV["HOMEBREW_TESTS_COVERAGE"].nil?,
// 59:         compile_cache_yaml: compile_cache,
// 60:       )
// 61:     end
// 62:
// 63:     def self.reset!
// 64:       return unless enabled?
// 65:
// 66:       ::Bootsnap.unload_cache!
// 67:       @key = nil
// 68:
// 69:       # The compile cache doesn't get unloaded so we don't need to load it again!
// 70:       load!(compile_cache: false)
// 71:     end
// 72:
// 73:     # Compile caches for the load graphs of common commands in a detached
// 74:     # background process, so the next `brew` command doesn't pay the cost of
// 75:     # compiling caches for Ruby files changed by e.g. `brew update`.
// 76:     def self.prewarm!
// 77:       return unless enabled?
// 78:       return if ENV["HOMEBREW_TESTS"]
// 79:
// 80:       pid = Process.spawn(
// 81:         *HOMEBREW_RUBY_EXEC_ARGS,
// 82:         "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 83:         "-rglobal", "-rcmd/install", "-rcmd/fetch", "-rcmd/upgrade",
// 84:         "-e", "",
// 85:         in: File::NULL, out: File::NULL, err: File::NULL, pgroup: true
// 86:       )
// 87:       Process.detach(pid)
// 88:     rescue SystemCallError
// 89:       nil
// 90:     end
// 91:   end
// 92: end
// 93:
// 94: Homebrew::Bootsnap.load!
