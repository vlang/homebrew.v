module utility

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/utility/engine.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cruby?` at line 7.
pub fn ruby_engine_l7_d1_on_cruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cruby?', ...args)
}

// Ruby method `on_jruby?` at line 11.
pub fn ruby_engine_l11_d2_on_jruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_jruby?', ...args)
}

// Ruby method `on_truffleruby?` at line 15.
pub fn ruby_engine_l15_d3_on_truffleruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_truffleruby?', ...args)
}

// Ruby method `on_windows?` at line 19.
pub fn ruby_engine_l19_d4_on_windows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_windows?', ...args)
}

// Ruby method `on_osx?` at line 23.
pub fn ruby_engine_l23_d5_on_osx(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_osx?', ...args)
}

// Ruby method `on_linux?` at line 27.
pub fn ruby_engine_l27_d6_on_linux(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_linux?', ...args)
}

// Ruby method `ruby_version(version = RUBY_VERSION, comparison, major, minor, patch)` at line 31.
pub fn ruby_engine_l31_d7_ruby_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ruby_version', ...args)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:   # @!visibility private
// 3:   module Utility
// 4:
// 5:     # @!visibility private
// 6:     module EngineDetector
// 7:       def on_cruby?
// 8:         RUBY_ENGINE == 'ruby'
// 9:       end
// 10:
// 11:       def on_jruby?
// 12:         RUBY_ENGINE == 'jruby'
// 13:       end
// 14:
// 15:       def on_truffleruby?
// 16:         RUBY_ENGINE == 'truffleruby'
// 17:       end
// 18:
// 19:       def on_windows?
// 20:         !(RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/).nil?
// 21:       end
// 22:
// 23:       def on_osx?
// 24:         !(RbConfig::CONFIG['host_os'] =~ /darwin|mac os/).nil?
// 25:       end
// 26:
// 27:       def on_linux?
// 28:         !(RbConfig::CONFIG['host_os'] =~ /linux/).nil?
// 29:       end
// 30:
// 31:       def ruby_version(version = RUBY_VERSION, comparison, major, minor, patch)
// 32:         result      = (version.split('.').map(&:to_i) <=> [major, minor, patch])
// 33:         comparisons = { :== => [0],
// 34:                         :>= => [1, 0],
// 35:                         :<= => [-1, 0],
// 36:                         :>  => [1],
// 37:                         :<  => [-1] }
// 38:         comparisons.fetch(comparison).include? result
// 39:       end
// 40:     end
// 41:   end
// 42:
// 43:   # @!visibility private
// 44:   extend Utility::EngineDetector
// 45: end
