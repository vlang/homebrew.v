module dsl

import ruby
import homebrew.unpack_strategy

// Translated from Homebrew/brew `cask/dsl/container.rb`.
pub struct CaskContainer {
pub mut:
	nested     string
	has_nested bool
	kind       string
	has_kind   bool
}

fn cask_container_nil() ruby.Value {
	return ruby.Value{
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

pub fn cask_container_value(container CaskContainer) ruby.Value {
	mut values := map[string]ruby.Value{}
	if container.has_nested {
		values['nested'] = ruby.string_value(container.nested)
	}
	if container.has_kind {
		values['type'] = ruby.Value{
			type_name: 'Symbol'
			repr: container.kind
		}
	}
	return ruby.Value{
		type_name: 'Cask::DSL::Container'
		repr: cask_container_inspect(container)
		map_data: values
	}
}

pub fn cask_container_from_value(value ruby.Value) !CaskContainer {
	if value.type_name != 'Cask::DSL::Container' && value.type_name != 'Hash' {
		return error('expected Cask::DSL::Container, got ${value.type_name}')
	}
	nested := if raw := value.map_data['nested'] { ?string(raw.as_string()) } else { none }
	kind := if raw := value.map_data['type'] { ?string(raw.as_string()) } else { none }
	return new_cask_container(nested, kind)
}

pub fn cask_container_pairs(container CaskContainer) map[string]ruby.Value {
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

fn cask_container_from_args(args []ruby.Value) ?CaskContainer {
	if args.len == 0 {
		return none
	}
	return cask_container_from_value(args[0]) or { return none }
}
