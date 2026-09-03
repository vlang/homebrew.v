module dsl

import brew_runtime
import homebrew.unpack_strategy

// Translated from Homebrew/brew `cask/dsl/container.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskContainer {
pub mut:
	nested     string
	has_nested bool
	kind       string
	has_kind   bool
}

fn cask_container_nil() brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

pub fn new_cask_container(nested ?string, kind ?string) !CaskContainer {
	mut container := CaskContainer{}
	if value := nested {
		container.nested = value
		container.has_nested = true
	}
	if value := kind {
		normalized := value.trim_left(':')
		if unpack_strategy.from_type(normalized) == none {
			return error('invalid container type: :${normalized}')
		}
		container.kind = normalized
		container.has_kind = true
	}
	return container
}

pub fn cask_container_value(container CaskContainer) brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	if container.has_nested {
		values['nested'] = brew_runtime.string_value(container.nested)
	}
	if container.has_kind {
		values['type'] = brew_runtime.Value{
			type_name: 'Symbol'
			repr: container.kind
		}
	}
	return brew_runtime.Value{
		type_name: 'Cask::DSL::Container'
		repr: cask_container_inspect(container)
		map_data: values
	}
}

pub fn cask_container_from_value(value brew_runtime.Value) !CaskContainer {
	if value.type_name != 'Cask::DSL::Container' && value.type_name != 'Hash' {
		return error('expected Cask::DSL::Container, got ${value.type_name}')
	}
	nested := if raw := value.map_data['nested'] { ?string(raw.as_string()) } else { none }
	kind := if raw := value.map_data['type'] { ?string(raw.as_string()) } else { none }
	return new_cask_container(nested, kind)
}

pub fn cask_container_pairs(container CaskContainer) map[string]brew_runtime.Value {
	return cask_container_value(container).map_data.clone()
}

fn cask_container_inspect(container CaskContainer) string {
	mut pairs := []string{}
	if container.has_nested {
		pairs << ':nested=>"${container.nested}"'
	}
	if container.has_kind {
		pairs << ':type=>:${container.kind}'
	}
	return '{${pairs.join(', ')}}'
}

fn cask_container_from_args(args []brew_runtime.Value) ?CaskContainer {
	if args.len == 0 {
		return none
	}
	return cask_container_from_value(args[0]) or { return none }
}

// Ruby attr_accessor `attr_accessor :nested` at line 11.
pub fn ruby_container_l11_d1_nested(args ...brew_runtime.Value) brew_runtime.Value {
	container := cask_container_from_args(args) or { return cask_container_nil() }
	return if container.has_nested {
		brew_runtime.string_value(container.nested)
	} else {
		cask_container_nil()
	}
}

// Ruby attr_accessor `attr_accessor :nested` at line 11.
pub fn ruby_container_l11_d2_nested(args ...brew_runtime.Value) brew_runtime.Value {
	mut container := cask_container_from_args(args) or { return cask_container_nil() }
	if args.len < 2 || args[1].type_name == 'NilClass' {
		container.nested = ''
		container.has_nested = false
	} else {
		container.nested = args[1].as_string()
		container.has_nested = true
	}
	return cask_container_value(container)
}

// Ruby attr_accessor `attr_accessor :type` at line 14.
pub fn ruby_container_l14_d3_type(args ...brew_runtime.Value) brew_runtime.Value {
	container := cask_container_from_args(args) or { return cask_container_nil() }
	return if container.has_kind {
		brew_runtime.Value{ type_name: 'Symbol', repr: container.kind }
	} else {
		cask_container_nil()
	}
}

// Ruby attr_accessor `attr_accessor :type` at line 14.
pub fn ruby_container_l14_d4_type(args ...brew_runtime.Value) brew_runtime.Value {
	mut container := cask_container_from_args(args) or { return cask_container_nil() }
	if args.len < 2 || args[1].type_name == 'NilClass' {
		container.kind = ''
		container.has_kind = false
		return cask_container_value(container)
	}
	updated := new_cask_container(if container.has_nested {
		?string(container.nested)
	} else {
		none
	}, args[1].as_string()) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return cask_container_value(updated)
}

// Ruby method `initialize(nested: nil, type: nil)` at line 17.
pub fn ruby_container_l17_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	keywords := if args.len > 0 && args[args.len - 1].type_name == 'Hash' {
		args[args.len - 1].map_data
	} else {
		map[string]brew_runtime.Value{}
	}
	nested := if raw := keywords['nested'] {
		if raw.type_name == 'NilClass' { ?string(none) } else { ?string(raw.as_string()) }
	} else {
		none
	}
	kind := if raw := keywords['type'] {
		if raw.type_name == 'NilClass' { ?string(none) } else { ?string(raw.as_string()) }
	} else {
		none
	}
	container := new_cask_container(nested, kind) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return cask_container_value(container)
}

// Ruby method `pairs` at line 28.
pub fn ruby_container_l28_d6_pairs(args ...brew_runtime.Value) brew_runtime.Value {
	container := cask_container_from_args(args) or { return brew_runtime.map_value({}) }
	return brew_runtime.map_value(cask_container_pairs(container))
}

// Ruby method `to_yaml` at line 33.
pub fn ruby_container_l33_d7_to_yaml(args ...brew_runtime.Value) brew_runtime.Value {
	container := cask_container_from_args(args) or { return brew_runtime.string_value('--- {}\n') }
	mut lines := ['---']
	if container.has_nested {
		lines << ':nested: ${container.nested}'
	}
	if container.has_kind {
		lines << ':type: :${container.kind}'
	}
	return brew_runtime.string_value('${lines.join('\n')}\n')
}

// Ruby method `to_s = pairs.inspect` at line 38.
pub fn ruby_container_l38_d8_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	container := cask_container_from_args(args) or { return brew_runtime.string_value('{}') }
	return brew_runtime.string_value(cask_container_inspect(container))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "unpack_strategy"
// 5:
// 6: module Cask
// 7:   class DSL
// 8:     # Class corresponding to the `container` stanza.
// 9:     class Container
// 10:       sig { returns(T.nilable(String)) }
// 11:       attr_accessor :nested
// 12:
// 13:       sig { returns(T.nilable(Symbol)) }
// 14:       attr_accessor :type
// 15:
// 16:       sig { params(nested: T.nilable(String), type: T.nilable(Symbol)).void }
// 17:       def initialize(nested: nil, type: nil)
// 18:         @nested = nested
// 19:         @type = type
// 20:
// 21:         return if type.nil?
// 22:         return unless UnpackStrategy.from_type(type).nil?
// 23:
// 24:         raise "invalid container type: #{type.inspect}"
// 25:       end
// 26:
// 27:       sig { returns(T::Hash[Symbol, T.nilable(T.any(String, Symbol))]) }
// 28:       def pairs
// 29:         instance_variables.to_h { |ivar| [ivar[1..].to_sym, instance_variable_get(ivar)] }.compact
// 30:       end
// 31:
// 32:       sig { returns(String) }
// 33:       def to_yaml
// 34:         pairs.to_yaml
// 35:       end
// 36:
// 37:       sig { returns(String) }
// 38:       def to_s = pairs.inspect
// 39:     end
// 40:   end
// 41: end
