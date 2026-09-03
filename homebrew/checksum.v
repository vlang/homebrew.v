module homebrew

import brew_runtime

// Translated from Homebrew/brew `checksum.rb`.
// The original source is retained below until every stub has a typed V body.

// Checksum is the translated value object used for formula and cask digests.
pub struct Checksum {
pub:
	hexdigest string
}

// new_checksum translates Checksum#initialize by normalising the digest to
// lowercase at construction time.
pub fn new_checksum(hexdigest string) Checksum {
	return Checksum{
		hexdigest: hexdigest.to_lower()
	}
}

// inspect translates Checksum#inspect.
pub fn (checksum Checksum) inspect() string {
	return '#<Checksum ${checksum.hexdigest}>'
}

// str translates the delegated String#to_s operation.
pub fn (checksum Checksum) str() string {
	return checksum.hexdigest
}

// is_empty translates the delegated String#empty? operation.
pub fn (checksum Checksum) is_empty() bool {
	return checksum.hexdigest == ''
}

// length translates the delegated String#length operation. Homebrew checksums
// are ASCII hexadecimal strings, so byte length and Ruby character length agree.
pub fn (checksum Checksum) length() int {
	return checksum.hexdigest.len
}

// character_at translates the integer form of delegated String#[].
pub fn (checksum Checksum) character_at(index int) !string {
	mut normalized_index := index
	if normalized_index < 0 {
		normalized_index += checksum.hexdigest.len
	}
	if normalized_index < 0 || normalized_index >= checksum.hexdigest.len {
		return error('checksum index ${index} is out of bounds')
	}
	return checksum.hexdigest[normalized_index].ascii_str()
}

// equals_string translates the String branch of Checksum#==.
pub fn (checksum Checksum) equals_string(other string) bool {
	return checksum.hexdigest == other.to_lower()
}

// equals translates the Checksum branch of Checksum#==.
pub fn (checksum Checksum) equals(other Checksum) bool {
	return checksum.hexdigest == other.hexdigest
}

fn checksum_from_boundary(arguments []brew_runtime.Value, method string) Checksum {
	if arguments.len == 0 {
		panic('Checksum#${method} requires a receiver')
	}
	return new_checksum(arguments[0].as_string())
}

// Ruby attr_reader `attr_reader :hexdigest` at line 9.
pub fn ruby_checksum_l9_d1_hexdigest(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(checksum_from_boundary(args, 'hexdigest').hexdigest)
}

// Ruby method `initialize(hexdigest)` at line 12.
pub fn ruby_checksum_l12_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Checksum#initialize requires a digest')
	}
	return brew_runtime.object_value('Checksum', new_checksum(args[0].as_string()).hexdigest)
}

// Ruby method `inspect` at line 17.
pub fn ruby_checksum_l17_d3_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(checksum_from_boundary(args, 'inspect').inspect())
}

// Ruby delegate `delegate [:empty?, :to_s, :length, :[]] => :@hexdigest` at line 21.
pub fn ruby_checksum_l21_d4_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(checksum_from_boundary(args, 'empty?').is_empty())
}

// Ruby delegate `delegate [:empty?, :to_s, :length, :[]] => :@hexdigest` at line 21.
pub fn ruby_checksum_l21_d5_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(checksum_from_boundary(args, 'to_s').str())
}

// Ruby delegate `delegate [:empty?, :to_s, :length, :[]] => :@hexdigest` at line 21.
pub fn ruby_checksum_l21_d6_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(checksum_from_boundary(args, 'length').length())
}

// Ruby delegate `delegate [:empty?, :to_s, :length, :[]] => :@hexdigest` at line 21.
pub fn ruby_checksum_l21_d7_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Checksum#[] requires a receiver and index')
	}
	index := args[1].as_int() or { panic(err) }
	return brew_runtime.string_value(checksum_from_boundary(args, '[]').character_at(int(index)) or {
		return brew_runtime.object_value('NilClass', '')
	})
}

// Ruby method `==(other)` at line 24.
pub fn ruby_checksum_l24_d8_equals(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Checksum#== requires a receiver and another value')
	}
	receiver := checksum_from_boundary(args, '==')
	other := args[1]
	equal := match other.type_name {
		'String' { receiver.equals_string(other.as_string()) }
		'Checksum' { receiver.equals(new_checksum(other.as_string())) }
		else { false }
	}
	return brew_runtime.bool_value(equal)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A formula's checksum.
// 5: class Checksum
// 6:   extend Forwardable
// 7:
// 8:   sig { returns(String) }
// 9:   attr_reader :hexdigest
// 10:
// 11:   sig { params(hexdigest: String).void }
// 12:   def initialize(hexdigest)
// 13:     @hexdigest = T.let(hexdigest.downcase, String)
// 14:   end
// 15:
// 16:   sig { returns(String) }
// 17:   def inspect
// 18:     "#<Checksum #{hexdigest}>"
// 19:   end
// 20:
// 21:   delegate [:empty?, :to_s, :length, :[]] => :@hexdigest
// 22:
// 23:   sig { params(other: T.anything).returns(T::Boolean) }
// 24:   def ==(other)
// 25:     case other
// 26:     when String
// 27:       to_s == other.downcase
// 28:     when Checksum
// 29:       hexdigest == other.hexdigest
// 30:     else
// 31:       false
// 32:     end
// 33:   end
// 34: end
