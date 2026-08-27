module homebrew

import brew_runtime

// Translated from Homebrew/brew `checksum.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :hexdigest` at line 9.
pub fn ruby_checksum_l9_d1_hexdigest(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hexdigest', ...args)
}

// Ruby method `initialize(hexdigest)` at line 12.
pub fn ruby_checksum_l12_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `inspect` at line 17.
pub fn ruby_checksum_l17_d3_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby delegate `delegate [:empty?, :to_s, :length, :[]] => :@hexdigest` at line 21.
pub fn ruby_checksum_l21_d4_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby delegate `delegate [:empty?, :to_s, :length, :[]] => :@hexdigest` at line 21.
pub fn ruby_checksum_l21_d5_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('length', ...args)
}

// Ruby delegate `delegate [:empty?, :to_s, :length, :[]] => :@hexdigest` at line 21.
pub fn ruby_checksum_l21_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]]', ...args)
}

// Ruby method `==(other)` at line 24.
pub fn ruby_checksum_l24_d7_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
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
