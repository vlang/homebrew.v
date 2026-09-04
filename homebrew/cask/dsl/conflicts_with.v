module dsl

import ruby

// Translated from Homebrew/brew `cask/dsl/conflicts_with.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskConflictsWith {
pub mut:
	conflicts map[string][]string
}

pub fn new_cask_conflicts_with(options map[string]ruby.Value) !CaskConflictsWith {
	for key in options.keys() {
		if key.trim_left(':') != 'cask' {
			return error('Unknown key: :${key.trim_left(':')}')
		}
	}
	mut conflicts := map[string][]string{}
	if value := options['cask'] {
		mut entries := if value.type_name == 'Array' {
			value.as_array()!.map(it.as_string())
		} else {
			[value.as_string()]
		}
		mut unique := []string{}
		for entry in entries {
			if entry !in unique {
				unique << entry
			}
		}
		conflicts['cask'] = unique
	}
	return CaskConflictsWith{
		conflicts: conflicts
	}
}

pub fn (mut conflicts CaskConflictsWith) merge(other CaskConflictsWith) {
	for key, values in other.conflicts {
		mut combined := conflicts.conflicts[key] or { []string{} }
		for value in values {
			if value !in combined {
				combined << value
			}
		}
		conflicts.conflicts[key] = combined
	}
}

pub fn cask_conflicts_with_value(conflicts CaskConflictsWith) ruby.Value {
	mut values := map[string]ruby.Value{}
	for key, entries in conflicts.conflicts {
		values[key] = ruby.string_array_value(entries)
	}
	return ruby.Value{
		type_name: 'Cask::DSL::ConflictsWith'
		repr: conflicts.conflicts.str()
		map_data: values
	}
}

pub fn cask_conflicts_with_from_value(value ruby.Value) !CaskConflictsWith {
	if value.type_name != 'Cask::DSL::ConflictsWith' && value.type_name != 'Hash' {
		return error('expected Cask::DSL::ConflictsWith, got ${value.type_name}')
	}
	return new_cask_conflicts_with(value.map_data)
}

fn cask_conflicts_receiver(args []ruby.Value) ?CaskConflictsWith {
	if args.len == 0 {
		return none
	}
	return cask_conflicts_with_from_value(args[0]) or { return none }
}

// Ruby method `initialize(**options)` at line 15.
pub fn ruby_conflicts_with_l15_d1_initialize(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 && args[args.len - 1].type_name == 'Hash' {
		args[args.len - 1].map_data.clone()
	} else {
		map[string]ruby.Value{}
	}
	conflicts := new_cask_conflicts_with(options) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return cask_conflicts_with_value(conflicts)
}

// Ruby method `merge!(other)` at line 25.
pub fn ruby_conflicts_with_l25_d2_merge(args ...ruby.Value) ruby.Value {
	mut conflicts := cask_conflicts_receiver(args) or {
		return ruby.object_value('ArgumentError', 'ConflictsWith#merge! requires a receiver')
	}
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'ConflictsWith#merge! requires another value')
	}
	other := cask_conflicts_with_from_value(args[1]) or {
		return ruby.object_value('TypeError', err.msg())
	}
	conflicts.merge(other)
	return cask_conflicts_with_value(conflicts)
}

// Ruby method `to_h` at line 31.
pub fn ruby_conflicts_with_l31_d3_to_h(args ...ruby.Value) ruby.Value {
	conflicts := cask_conflicts_receiver(args) or { return ruby.map_value({}) }
	return ruby.map_value(cask_conflicts_with_value(conflicts).map_data)
}

// Ruby method `to_json(generator)` at line 36.
pub fn ruby_conflicts_with_l36_d4_to_json(args ...ruby.Value) ruby.Value {
	conflicts := cask_conflicts_receiver(args) or { return ruby.string_value('{}') }
	mut parts := []string{}
	for key, values in conflicts.conflicts {
		parts << '"${key}":[${values.map('"\${it}"').join(',')}]'
	}
	parts.sort()
	return ruby.string_value('{${parts.join(',')}}')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "delegate"
// 5: require "extend/hash/keys"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   class DSL
// 10:     # Class corresponding to the `conflicts_with` stanza.
// 11:     class ConflictsWith < SimpleDelegator
// 12:       VALID_KEYS = [:cask].freeze
// 13:
// 14:       sig { params(options: T.anything).void }
// 15:       def initialize(**options)
// 16:         options.assert_valid_keys(*VALID_KEYS)
// 17:
// 18:         conflicts = options.transform_values { |v| Set.new(Kernel.Array(v)) }
// 19:         conflicts.default = Set.new
// 20:
// 21:         super(conflicts)
// 22:       end
// 23:
// 24:       sig { params(other: ConflictsWith).returns(T.self_type) }
// 25:       def merge!(other)
// 26:         other.to_h.each { |key, values| __getobj__[key] |= Set.new(values) }
// 27:         self
// 28:       end
// 29:
// 30:       sig { returns(T::Hash[Symbol, T::Array[String]]) }
// 31:       def to_h
// 32:         __getobj__.transform_values(&:to_a)
// 33:       end
// 34:
// 35:       sig { params(generator: T.anything).returns(String) }
// 36:       def to_json(generator)
// 37:         to_h.to_json(generator)
// 38:       end
// 39:     end
// 40:   end
// 41: end
