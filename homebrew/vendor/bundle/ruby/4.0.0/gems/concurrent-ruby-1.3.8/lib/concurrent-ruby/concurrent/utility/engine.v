module utility

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/utility/engine.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn on_cruby() bool {
	return false
}

pub fn on_jruby() bool {
	return false
}

pub fn on_truffleruby() bool {
	return false
}

pub fn on_windows() bool {
	return $if windows { true } $else { false }
}

pub fn on_osx() bool {
	return $if macos { true } $else { false }
}

pub fn on_linux() bool {
	return $if linux { true } $else { false }
}

fn version_components(version string) [3]int {
	parts := version.split('.')
	mut components := [3]int{}
	for index in 0 .. 3 {
		if index < parts.len {
			components[index] = parts[index].int()
		}
	}
	return components
}

pub fn version_matches(version string, comparison string, major int, minor int, patch int) !bool {
	actual := version_components(version)
	expected := [major, minor, patch]!
	mut result := 0
	for index in 0 .. 3 {
		if actual[index] < expected[index] {
			result = -1
			break
		}
		if actual[index] > expected[index] {
			result = 1
			break
		}
	}
	return match comparison {
		'==' { result == 0 }
		'>=' { result >= 0 }
		'<=' { result <= 0 }
		'>' { result > 0 }
		'<' { result < 0 }
		else {
			return error('unknown Ruby version comparison: ${comparison}')
		}
	}
}

// Ruby method `on_cruby?` at line 7.
pub fn ruby_engine_l7_d1_on_cruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(on_cruby())
}

// Ruby method `on_jruby?` at line 11.
pub fn ruby_engine_l11_d2_on_jruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(on_jruby())
}

// Ruby method `on_truffleruby?` at line 15.
pub fn ruby_engine_l15_d3_on_truffleruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(on_truffleruby())
}

// Ruby method `on_windows?` at line 19.
pub fn ruby_engine_l19_d4_on_windows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(on_windows())
}

// Ruby method `on_osx?` at line 23.
pub fn ruby_engine_l23_d5_on_osx(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(on_osx())
}

// Ruby method `on_linux?` at line 27.
pub fn ruby_engine_l27_d6_on_linux(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(on_linux())
}

// Ruby method `ruby_version(version = RUBY_VERSION, comparison, major, minor, patch)` at line 31.
pub fn ruby_engine_l31_d7_ruby_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('ruby_version requires comparison, major, minor, and patch')
	}
	version_offset := if args.len >= 5 { 1 } else { 0 }
	version := if version_offset == 1 { args[0].as_string() } else { '4.0.0' }
	comparison := args[version_offset].as_string()
	major := int(args[version_offset + 1].as_int() or { panic(err) })
	minor := int(args[version_offset + 2].as_int() or { panic(err) })
	patch := int(args[version_offset + 3].as_int() or { panic(err) })
	return brew_runtime.bool_value(version_matches(version, comparison, major, minor, patch) or { panic(err) })
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
