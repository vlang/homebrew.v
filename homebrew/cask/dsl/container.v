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
