module homebrew

import brew_runtime

// Translated from Homebrew/brew `PATH.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby delegate `delegate each: :@paths` at line 12.
pub fn ruby_path_l12_d1_each(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each', ...args)
}

// Ruby method `initialize(*paths)` at line 19.
pub fn ruby_path_l19_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `prepend(*paths)` at line 24.
pub fn ruby_path_l24_d3_prepend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prepend', ...args)
}

// Ruby method `append(*paths)` at line 30.
pub fn ruby_path_l30_d4_append(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('append', ...args)
}

// Ruby method `insert(index, *paths)` at line 36.
pub fn ruby_path_l36_d5_insert(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('insert', ...args)
}

// Ruby method `select(&block)` at line 42.
pub fn ruby_path_l42_d6_select(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('select', ...args)
}

// Ruby method `reject(&block)` at line 47.
pub fn ruby_path_l47_d7_reject(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reject', ...args)
}

// Ruby method `to_ary` at line 52.
pub fn ruby_path_l52_d8_to_ary(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_ary', ...args)
}

// Ruby alias `alias to_a to_ary` at line 55.
pub fn ruby_path_l55_d9_to_a(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_a', ...args)
}

// Ruby method `to_str` at line 58.
pub fn ruby_path_l58_d10_to_str(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_str', ...args)
}

// Ruby method `to_s = to_str` at line 63.
pub fn ruby_path_l63_d11_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `==(other)` at line 66.
pub fn ruby_path_l66_d12_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby method `empty?` at line 73.
pub fn ruby_path_l73_d13_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty?', ...args)
}

// Ruby method `existing` at line 78.
pub fn ruby_path_l78_d14_existing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('existing', ...args)
}

// Ruby method `parse(paths)` at line 87.
pub fn ruby_path_l87_d15_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse', ...args)
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
