module extend

import ruby

// Translated from Homebrew/brew `extend/array.rb`.
// The original source is retained below until every stub has a typed V body.

pub fn array_second[T](values []T) ?T {
	return if values.len > 1 { values[1] } else { none }
}

pub fn array_third[T](values []T) ?T {
	return if values.len > 2 { values[2] } else { none }
}

pub fn array_fourth[T](values []T) ?T {
	return if values.len > 3 { values[3] } else { none }
}

pub fn array_fifth[T](values []T) ?T {
	return if values.len > 4 { values[4] } else { none }
}

pub fn array_to_sentence(values []string, words_connector string, two_words_connector string, last_word_connector string) string {
	return match values.len {
		0 { '' }
		1 { values[0] }
		2 { '${values[0]}${two_words_connector}${values[1]}' }
		else { '${values[..values.len - 1].join(words_connector)}${last_word_connector}${values.last()}' }
	}
}

fn boundary_array_element(args []ruby.Value, index int, method string) ruby.Value {
	if args.len == 0 {
		panic('Array#${method} requires a receiver')
	}
	values := args[0].as_string_array() or { panic(err) }
	return if index < values.len {
		ruby.string_value(values[index])
	} else {
		ruby.object_value('NilClass', '')
	}
}

// Ruby method `second = self[1]` at line 12.
pub fn ruby_array_l12_d1_second(args ...ruby.Value) ruby.Value {
	return boundary_array_element(args, 1, 'second')
}

// Ruby method `third = self[2]` at line 21.
pub fn ruby_array_l21_d2_third(args ...ruby.Value) ruby.Value {
	return boundary_array_element(args, 2, 'third')
}

// Ruby method `fourth = self[3]` at line 30.
pub fn ruby_array_l30_d3_fourth(args ...ruby.Value) ruby.Value {
	return boundary_array_element(args, 3, 'fourth')
}

// Ruby method `fifth = self[4]` at line 39.
pub fn ruby_array_l39_d4_fifth(args ...ruby.Value) ruby.Value {
	return boundary_array_element(args, 4, 'fifth')
}

// Ruby method `to_sentence(words_connector: ", ", two_words_connector: " and ", last_word_connector: " and ")` at line 93.
pub fn ruby_array_l93_d5_to_sentence(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Array#to_sentence requires a receiver')
	}
	values := args[0].as_string_array() or { panic(err) }
	words := if args.len > 1 { args[1].as_string() } else { ', ' }
	two_words := if args.len > 2 { args[2].as_string() } else { ' and ' }
	last_word := if args.len > 3 { args[3].as_string() } else { ' and ' }
	return ruby.string_value(array_to_sentence(values, words, two_words, last_word))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Array
// 5:   # Equal to `self[1]`.
// 6:   #
// 7:   # ### Example
// 8:   #
// 9:   # ```ruby
// 10:   # %w( a b c d e ).second # => "b"
// 11:   # ```
// 12:   def second = self[1]
// 13:
// 14:   # Equal to `self[2]`.
// 15:   #
// 16:   # ### Example
// 17:   #
// 18:   # ```ruby
// 19:   # %w( a b c d e ).third # => "c"
// 20:   # ```
// 21:   def third = self[2]
// 22:
// 23:   # Equal to `self[3]`.
// 24:   #
// 25:   # ### Example
// 26:   #
// 27:   # ```ruby
// 28:   # %w( a b c d e ).fourth # => "d"
// 29:   # ```
// 30:   def fourth = self[3]
// 31:
// 32:   # Equal to `self[4]`.
// 33:   #
// 34:   # ### Example
// 35:   #
// 36:   # ```ruby
// 37:   # %w( a b c d e ).fifth # => "e"
// 38:   # ```
// 39:   def fifth = self[4]
// 40:
// 41:   # Converts the array to a comma-separated sentence where the last element is
// 42:   # joined by the connector word.
// 43:   #
// 44:   # ### Examples
// 45:   #
// 46:   # ```ruby
// 47:   # [].to_sentence                      # => ""
// 48:   # ['one'].to_sentence                 # => "one"
// 49:   # ['one', 'two'].to_sentence          # => "one and two"
// 50:   # ['one', 'two', 'three'].to_sentence # => "one, two and three"
// 51:   # ['one', 'two'].to_sentence(two_words_connector: '-')
// 52:   # # => "one-two"
// 53:   # ```
// 54:   #
// 55:   # ```
// 56:   # ['one', 'two', 'three'].to_sentence(words_connector: ' or ', last_word_connector: ' or at least ')
// 57:   # # => "one or two or at least three"
// 58:   # ```
// 59:   #
// 60:   # @see https://github.com/rails/rails/blob/v7.0.4.2/activesupport/lib/active_support/core_ext/array/conversions.rb#L8-L84
// 61:   #   ActiveSupport Array#to_sentence monkey-patch
// 62:   #
// 63:   #
// 64:   # Copyright (c) David Heinemeier Hansson
// 65:   #
// 66:   # Permission is hereby granted, free of charge, to any person obtaining
// 67:   # a copy of this software and associated documentation files (the
// 68:   # "Software"), to deal in the Software without restriction, including
// 69:   # without limitation the rights to use, copy, modify, merge, publish,
// 70:   # distribute, sublicense and/or sell copies of the Software and to
// 71:   # permit persons to whom the Software is furnished to do so, subject to
// 72:   # the following conditions:
// 73:   #
// 74:   # The above copyright notice and this permission notice shall be
// 75:   # included in all copies or substantial portions of the Software.
// 76:   #
// 77:   # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// 78:   # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// 79:   # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// 80:   # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// 81:   # LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// 82:   # OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// 83:   # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// 84:   #
// 85:   #
// 86:   # @param [String] words_connector The sign or word used to join all but the last
// 87:   #   element in arrays with three or more elements (default: `", "`).
// 88:   # @param [String] last_word_connector The sign or word used to join the last element
// 89:   #   in arrays with three or more elements (default: `" and "`).
// 90:   # @param [String] two_words_connector The sign or word used to join the elements
// 91:   #   in arrays with two elements (default: `" and "`).
// 92:   sig { params(words_connector: String, two_words_connector: String, last_word_connector: String).returns(String) }
// 93:   def to_sentence(words_connector: ", ", two_words_connector: " and ", last_word_connector: " and ")
// 94:     case length
// 95:     when 0
// 96:       +""
// 97:     when 1
// 98:       # This is not typesafe, if the array contains a BasicObject
// 99:       +T.unsafe(self[0]).to_s
// 100:     when 2
// 101:       "#{self[0]}#{two_words_connector}#{self[1]}"
// 102:     else
// 103:       "#{T.must(self[0...-1]).join(words_connector)}#{last_word_connector}#{self[-1]}"
// 104:     end
// 105:   end
// 106: end
