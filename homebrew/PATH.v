module homebrew

import ruby
import os

// Translated from Homebrew/brew `PATH.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PathInput {
pub:
	values []string
}

pub struct BrewPath {
pub mut:
	paths []string
}

pub type PathPredicate = fn(string) bool

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

// Ruby delegate `delegate each: :@paths` at line 12.
pub fn ruby_path_l12_d1_each(path BrewPath) []string {
	return path.to_array()
}

// Ruby method `initialize(*paths)` at line 19.
pub fn ruby_path_l19_d2_initialize(paths ...PathInput) BrewPath {
	return new_brew_path(...paths)
}

// Ruby method `prepend(*paths)` at line 24.
pub fn ruby_path_l24_d3_prepend(mut path BrewPath, paths ...PathInput) BrewPath {
	return path.prepend(...paths)
}

// Ruby method `append(*paths)` at line 30.
pub fn ruby_path_l30_d4_append(mut path BrewPath, paths ...PathInput) BrewPath {
	return path.append(...paths)
}

// Ruby method `insert(index, *paths)` at line 36.
pub fn ruby_path_l36_d5_insert(mut path BrewPath, index int, paths ...PathInput) !BrewPath {
	return path.insert(index, ...paths)
}

// Ruby method `select(&block)` at line 42.
pub fn ruby_path_l42_d6_select(path BrewPath, predicate PathPredicate) BrewPath {
	return path.select_paths(predicate)
}

// Ruby method `reject(&block)` at line 47.
pub fn ruby_path_l47_d7_reject(path BrewPath, predicate PathPredicate) BrewPath {
	return path.reject_paths(predicate)
}

// Ruby method `to_ary` at line 52.
pub fn ruby_path_l52_d8_to_ary(path BrewPath) []string {
	return path.to_array()
}

// Ruby alias `alias to_a to_ary` at line 55.
pub fn ruby_path_l55_d9_to_a(path BrewPath) []string {
	return path.to_array()
}

// Ruby method `to_str` at line 58.
pub fn ruby_path_l58_d10_to_str(path BrewPath) string {
	return path.str()
}

// Ruby method `to_s = to_str` at line 63.
pub fn ruby_path_l63_d11_to_s(path BrewPath) string {
	return path.str()
}

// Ruby method `==(other)` at line 66.
pub fn ruby_path_l66_d12_anonymous(path BrewPath, other ruby.Value) bool {
	return brew_path_equals_value(path, other)
}

// Ruby method `empty?` at line 73.
pub fn ruby_path_l73_d13_empty(path BrewPath) bool {
	return path.paths.len == 0
}

// Ruby method `existing` at line 78.
pub fn ruby_path_l78_d14_existing(path BrewPath) ?BrewPath {
	return path.existing()
}

// Ruby method `parse(paths)` at line 87.
pub fn ruby_path_l87_d15_parse(paths []PathInput) []string {
	return parse_path_inputs(paths)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5:
// 6: # Representation of a `*PATH` environment variable.
// 7: class PATH
// 8:   include Enumerable
// 9:   extend Forwardable
// 10:   extend T::Generic
// 11:
// 12:   delegate each: :@paths
// 13:
// 14:   Elem = type_member(:out) { { fixed: String } }
// 15:   Element = T.type_alias { T.nilable(T.any(Pathname, String, PATH)) }
// 16:   private_constant :Element
// 17:   Elements = T.type_alias { T.any(Element, T::Array[Element]) }
// 18:   sig { params(paths: Elements).void }
// 19:   def initialize(*paths)
// 20:     @paths = T.let(parse(paths), T::Array[String])
// 21:   end
// 22:
// 23:   sig { params(paths: Elements).returns(T.self_type) }
// 24:   def prepend(*paths)
// 25:     @paths = parse(paths + @paths)
// 26:     self
// 27:   end
// 28:
// 29:   sig { params(paths: Elements).returns(T.self_type) }
// 30:   def append(*paths)
// 31:     @paths = parse(@paths + paths)
// 32:     self
// 33:   end
// 34:
// 35:   sig { params(index: Integer, paths: Elements).returns(T.self_type) }
// 36:   def insert(index, *paths)
// 37:     @paths = parse(@paths.insert(index, *paths))
// 38:     self
// 39:   end
// 40:
// 41:   sig { params(block: T.proc.params(arg0: String).returns(BasicObject)).returns(T.self_type) }
// 42:   def select(&block)
// 43:     self.class.new(@paths.select(&block))
// 44:   end
// 45:
// 46:   sig { params(block: T.proc.params(arg0: String).returns(BasicObject)).returns(T.self_type) }
// 47:   def reject(&block)
// 48:     self.class.new(@paths.reject(&block))
// 49:   end
// 50:
// 51:   sig { returns(T::Array[String]) }
// 52:   def to_ary
// 53:     @paths.dup.to_ary
// 54:   end
// 55:   alias to_a to_ary
// 56:
// 57:   sig { returns(String) }
// 58:   def to_str
// 59:     @paths.join(File::PATH_SEPARATOR)
// 60:   end
// 61:
// 62:   sig { returns(String) }
// 63:   def to_s = to_str
// 64:
// 65:   sig { params(other: T.untyped).returns(T::Boolean) }
// 66:   def ==(other)
// 67:     (other.respond_to?(:to_ary) && to_ary == other.to_ary) ||
// 68:       (other.respond_to?(:to_str) && to_str == other.to_str) ||
// 69:       false
// 70:   end
// 71:
// 72:   sig { returns(T::Boolean) }
// 73:   def empty?
// 74:     @paths.empty?
// 75:   end
// 76:
// 77:   sig { returns(T.nilable(T.self_type)) }
// 78:   def existing
// 79:     existing_path = select { File.directory?(it) }
// 80:     # return nil instead of empty PATH, to unset environment variables
// 81:     existing_path unless existing_path.empty?
// 82:   end
// 83:
// 84:   private
// 85:
// 86:   sig { params(paths: T::Array[Elements]).returns(T::Array[String]) }
// 87:   def parse(paths)
// 88:     paths.flatten
// 89:          .compact
// 90:          .flat_map { |p| Pathname(p).to_path.split(File::PATH_SEPARATOR) }
// 91:          .uniq
// 92:   end
// 93: end
