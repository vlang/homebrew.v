module homebrew

import ruby
import os

// Translated from Homebrew/brew `PATH.rb`.
pub struct PathInput {
pub:
	values []string
}

pub struct BrewPath {
pub mut:
	paths []string
}

pub type PathPredicate = fn (string) bool

pub fn path_input(value string) PathInput {
	return PathInput{ values: [value] }
}

pub fn path_array_input(values []string) PathInput {
	return PathInput{ values: values.clone() }
}

pub fn path_path_input(path BrewPath) PathInput {
	return PathInput{ values: path.paths.clone() }
}

pub fn parse_path_inputs(inputs []PathInput) []string {
	mut parsed := []string{}
	for input in inputs {
		for value in input.values {
			mut components := value.split(os.path_delimiter)
			for components.len > 0 && components.last() == '' {
				components.delete_last()
			}
			for component in components {
				if component !in parsed {
					parsed << component
				}
			}
		}
	}
	return parsed
}

pub fn new_brew_path(inputs ...PathInput) BrewPath {
	return BrewPath{ paths: parse_path_inputs(inputs) }
}

pub fn (path BrewPath) to_array() []string {
	return path.paths.clone()
}

pub fn (path BrewPath) str() string {
	return path.paths.join(os.path_delimiter)
}

pub fn (path BrewPath) contains(value string) bool {
	return value in path.paths
}

pub fn (mut path BrewPath) prepend(inputs ...PathInput) BrewPath {
	mut combined := inputs.clone()
	combined << path_path_input(path)
	path.paths = parse_path_inputs(combined)
	return path
}

pub fn (mut path BrewPath) append(inputs ...PathInput) BrewPath {
	mut combined := [path_path_input(path)]
	combined << inputs
	path.paths = parse_path_inputs(combined)
	return path
}

pub fn (mut path BrewPath) insert(index int, inputs ...PathInput) !BrewPath {
	mut position := if index < 0 { path.paths.len + index + 1 } else { index }
	if position < 0 {
		return error('index ${index} too small for array; minimum: ${-path.paths.len - 1}')
	}
	if position > path.paths.len {
		position = path.paths.len
	}
	mut inserted := []string{cap: path.paths.len + inputs.len}
	inserted << path.paths[..position]
	for input in inputs {
		inserted << input.values
	}
	inserted << path.paths[position..]
	mut values := inserted.clone()
	path.paths = parse_path_inputs([path_array_input(values)])
	return path
}

pub fn (path BrewPath) select_paths(predicate PathPredicate) BrewPath {
	return new_brew_path(path_array_input(path.paths.filter(predicate(it))))
}

pub fn (path BrewPath) reject_paths(predicate PathPredicate) BrewPath {
	return new_brew_path(path_array_input(path.paths.filter(!predicate(it))))
}

pub fn (path BrewPath) existing_with(predicate PathPredicate) ?BrewPath {
	existing := path.select_paths(predicate)
	if existing.paths.len == 0 {
		return none
	}
	return existing
}

pub fn (path BrewPath) existing() ?BrewPath {
	return path.existing_with(os.is_dir)
}

pub fn brew_path_value(path BrewPath) ruby.Value {
	return ruby.structured_value('PATH', path.str(), {
		'paths': path.paths.join(os.path_delimiter)
	})
}

pub fn brew_path_equals_value(path BrewPath, other ruby.Value) bool {
	if other.type_name == 'Array' {
		return path.paths == (other.as_string_array() or { return false })
	}
	if other.type_name == 'PATH' {
		return path.str() == (other.attributes['paths'] or { other.as_string() })
	}
	if other.type_name in ['String', 'Pathname'] {
		return path.str() == other.as_string()
	}
	return false
}
