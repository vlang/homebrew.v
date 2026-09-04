module map

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/map/truffleruby_map_backend.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct TruffleRubyMapBackend {
pub:
	initial_capacity ?int
	load_factor      ?f64
}

pub fn new_truffleruby_map_backend(options MapBackendOptions) TruffleRubyMapBackend {
	return TruffleRubyMapBackend{
		initial_capacity: options.initial_capacity
		load_factor: options.load_factor
	}
}

// Ruby method `initialize(options = nil)` at line 8.
pub fn ruby_truffleruby_map_backend_l8_d1_initialize(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 && args[0].type_name == 'Hash' {
		map_options_from_boundary(args[0])
	} else {
		MapBackendOptions{}
	}
	backend := new_truffleruby_map_backend(options)
	mut attributes := map[string]string{}
	if initial_capacity := backend.initial_capacity {
		attributes['initial_capacity'] = initial_capacity.str()
	}
	if load_factor := backend.load_factor {
		attributes['load_factor'] = load_factor.str()
	}
	return ruby.structured_value('Concurrent::Collection::TruffleRubyMapBackend', '#<Concurrent::Collection::TruffleRubyMapBackend>', attributes)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:
// 3:   # @!visibility private
// 4:   module Collection
// 5:
// 6:     # @!visibility private
// 7:     class TruffleRubyMapBackend < TruffleRuby::ConcurrentMap
// 8:       def initialize(options = nil)
// 9:         options ||= {}
// 10:         super(initial_capacity: options[:initial_capacity], load_factor: options[:load_factor])
// 11:       end
// 12:     end
// 13:   end
// 14: end
