module extend

import ruby
import homebrew.extend as array_ext

// Translated from Homebrew/brew `test/extend/array_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify do` at line 8.
pub fn ruby_array_spec_l8_d1_do(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(array_ext.array_to_sentence([], ', ', ' and ', ' and ') == ''
		&& array_ext.array_to_sentence(['one'], ', ', ' and ', ' and ') == 'one'
		&& array_ext.array_to_sentence(['one', 'two'], ', ', ' and ', ' and ') == 'one and two'
		&& array_ext.array_to_sentence(['one', 'two', 'three'], ', ', ' and ', ' and ') == 'one, two and three'
		&& array_ext.array_to_sentence(['1'], ', ', ' and ', ' and ') == '1'
		&& array_ext.array_to_sentence(['', 'one', '', 'two', 'three'], ', ', ' and ', ' and ') == ', one, , two and three')
}

// Ruby it `it "converts an array to a sentence with a custom connector" do` at line 21.
pub fn ruby_array_spec_l21_d2_converts(args ...ruby.Value) ruby.Value {
	values := ['one', 'two', 'three']
	return ruby.bool_value(array_ext.array_to_sentence(values, ' ', ' and ', ' and ') == 'one two and three'
		&& array_ext.array_to_sentence(values, ' & ', ' and ', ' and ') == 'one & two and three')
}

// Ruby it `it "converts an array to a sentence with a custom last word connector" do` at line 26.
pub fn ruby_array_spec_l26_d3_converts(args ...ruby.Value) ruby.Value {
	values := ['one', 'two', 'three']
	return ruby.bool_value(array_ext.array_to_sentence(values, ', ', ' and ', ', and also ') == 'one, two, and also three'
		&& array_ext.array_to_sentence(values, ', ', ' and ', ' ') == 'one, two three'
		&& array_ext.array_to_sentence(values, ', ', ' and ', ' and ') == 'one, two and three')
}

// Ruby it `it "converts an array to a sentence with a custom two word connector" do` at line 33.
pub fn ruby_array_spec_l33_d4_converts(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(array_ext.array_to_sentence(['one', 'two'], ', ', ' ', ' and ') == 'one two')
}

// Ruby it `it "creates a new string" do` at line 37.
pub fn ruby_array_spec_l37_d5_creates(args ...ruby.Value) ruby.Value {
	elements := ['one']
	result := array_ext.array_to_sentence(elements, ', ', ' and ', ' and ')
	return ruby.bool_value(result == elements[0] && result.len == elements[0].len)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/array"
// 5:
// 6: RSpec.describe Array do
// 7:   describe ".to_sentence" do
// 8:     specify do
// 9:       expect([].to_sentence).to eq("")
// 10:       expect(["one"].to_sentence).to eq("one")
// 11:       expect(["one", "two"].to_sentence).to eq("one and two")
// 12:       expect(["one", "two", "three"].to_sentence).to eq("one, two and three")
// 13:       expect([1].to_sentence).to eq("1")
// 14:       expect([nil, "one", "", "two", "three"].to_sentence).to eq(", one, , two and three")
// 15:       expect([""].to_sentence).not_to be_frozen
// 16:       expect(["one"].to_sentence).not_to be_frozen
// 17:       expect(["one", "two"].to_sentence).not_to be_frozen
// 18:       expect(["one", "two", "three"].to_sentence).not_to be_frozen
// 19:     end
// 20:
// 21:     it "converts an array to a sentence with a custom connector" do
// 22:       expect(["one", "two", "three"].to_sentence(words_connector: " ")).to eq("one two and three")
// 23:       expect(["one", "two", "three"].to_sentence(words_connector: " & ")).to eq("one & two and three")
// 24:     end
// 25:
// 26:     it "converts an array to a sentence with a custom last word connector" do
// 27:       expect(["one", "two", "three"].to_sentence(last_word_connector: ", and also "))
// 28:         .to eq("one, two, and also three")
// 29:       expect(["one", "two", "three"].to_sentence(last_word_connector: " ")).to eq("one, two three")
// 30:       expect(["one", "two", "three"].to_sentence(last_word_connector: " and ")).to eq("one, two and three")
// 31:     end
// 32:
// 33:     it "converts an array to a sentence with a custom two word connector" do
// 34:       expect(["one", "two"].to_sentence(two_words_connector: " ")).to eq("one two")
// 35:     end
// 36:
// 37:     it "creates a new string" do
// 38:       elements = ["one"]
// 39:       expect(elements.to_sentence.object_id).not_to eq(elements[0].object_id)
// 40:     end
// 41:   end
// 42: end
