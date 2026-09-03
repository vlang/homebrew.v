module extend

import brew_runtime
import homebrew.extend.blank

// Translated from Homebrew/brew `test/extend/blank_spec.rb`.
// The original source is retained below for exact boundary auditing.

fn blank_spec_empty_true_instance() brew_runtime.Value {
	return brew_runtime.structured_value('EmptyTrue', '#<EmptyTrue>', {
		'empty_result': '0'
	})
}

fn blank_spec_empty_false_instance() brew_runtime.Value {
	return brew_runtime.structured_value('EmptyFalse', '#<EmptyFalse>', {
		'empty_result': 'false'
	})
}

pub fn blank_spec_blank_values() []brew_runtime.Value {
	return [
		blank_spec_empty_true_instance(),
		brew_runtime.object_value('NilClass', 'nil'),
		brew_runtime.bool_value(false),
		brew_runtime.string_value(''),
		brew_runtime.string_value('   '),
		brew_runtime.string_value('  \n\t  \r '),
		brew_runtime.string_value('　'),
		brew_runtime.string_value(' '),
		brew_runtime.array_value([]),
		brew_runtime.map_value({}),
	]
}

pub fn blank_spec_present_values() []brew_runtime.Value {
	return [
		blank_spec_empty_false_instance(),
		brew_runtime.object_value('Object', '#<Object>'),
		brew_runtime.bool_value(true),
		brew_runtime.int_value(0),
		brew_runtime.int_value(1),
		brew_runtime.string_value('a'),
		brew_runtime.array_value([brew_runtime.object_value('NilClass', 'nil')]),
		brew_runtime.map_value({
			'nil': brew_runtime.int_value(0)
		}),
		brew_runtime.object_value('Time', 'now'),
	]
}

fn blank_spec_presence_matches(original brew_runtime.Value, present brew_runtime.Value) bool {
	return present.type_name == original.type_name && present.repr == original.repr
		&& present.array_data.len == original.array_data.len
		&& present.map_data.len == original.map_data.len
}

// Ruby let `let(:empty_true) do` at line 7.
pub fn ruby_blank_spec_l7_d1_empty_true(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Class', 'EmptyTrue')
}

// Ruby method `empty?` at line 11.
pub fn ruby_blank_spec_l11_d2_empty(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.int_value(0)
}

// Ruby let `let(:empty_false) do` at line 17.
pub fn ruby_blank_spec_l17_d3_empty_false(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Class', 'EmptyFalse')
}

// Ruby method `empty?` at line 19.
pub fn ruby_blank_spec_l19_d4_empty(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(false)
}

// Ruby let `let(:blank) { [empty_true.new, nil, false, "", "   ", "  \n\t  \r ", "　", "\u00a0", [], {}] }` at line 24.
pub fn ruby_blank_spec_l24_d5_blank(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.array_value(blank_spec_blank_values())
}

// Ruby let `let(:present) { [empty_false.new, described_class.new, true, 0, 1, "a", [nil], { nil => 0 }, Time.now] }` at line 25.
pub fn ruby_blank_spec_l25_d6_present(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.array_value(blank_spec_present_values())
}

// Ruby it `it "checks if an object is blank" do` at line 28.
pub fn ruby_blank_spec_l28_d7_checks(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(blank_spec_blank_values().all(blank.value_is_blank(it))
		&& blank_spec_present_values().all(!blank.value_is_blank(it)))
}

// Ruby it `it "checks if an object is blank with bundled string encodings" do` at line 33.
pub fn ruby_blank_spec_l33_d8_checks(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	whitespace := [' ', '\t', '\n', '\r', ' ', '　', ' ', ' ']
	return brew_runtime.bool_value(whitespace.all(blank.value_is_blank(brew_runtime.string_value(it)))
		&& !blank.value_is_blank(brew_runtime.string_value('a')))
}

// Ruby it `it "checks if an object is present" do` at line 42.
pub fn ruby_blank_spec_l42_d9_checks(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(blank_spec_blank_values().all(!blank.value_is_present(it))
		&& blank_spec_present_values().all(blank.value_is_present(it)))
}

// Ruby it `it "returns the object if present, or nil" do` at line 49.
pub fn ruby_blank_spec_l49_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	for value in blank_spec_blank_values() {
		if blank.value_presence(value).type_name != 'NilClass' {
			return brew_runtime.bool_value(false)
		}
	}
	for value in blank_spec_present_values() {
		if !blank_spec_presence_matches(value, blank.value_presence(value)) {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/blank"
// 5:
// 6: RSpec.describe Object do
// 7:   let(:empty_true) do
// 8:     Class.new(Object) do
// 9:       # This API is intentionally non-ideal for testing.
// 10:       # rubocop:disable Naming/PredicateMethod
// 11:       def empty?
// 12:         0
// 13:       end
// 14:       # rubocop:enable Naming/PredicateMethod
// 15:     end
// 16:   end
// 17:   let(:empty_false) do
// 18:     Class.new(Object) do
// 19:       def empty?
// 20:         false
// 21:       end
// 22:     end
// 23:   end
// 24:   let(:blank) { [empty_true.new, nil, false, "", "   ", "  \n\t  \r ", "　", "\u00a0", [], {}] }
// 25:   let(:present) { [empty_false.new, described_class.new, true, 0, 1, "a", [nil], { nil => 0 }, Time.now] }
// 26:
// 27:   describe ".blank?" do
// 28:     it "checks if an object is blank" do
// 29:       blank.each { |v| expect(v.blank?).to be true }
// 30:       present.each { |v| expect(v.blank?).to be false }
// 31:     end
// 32:
// 33:     it "checks if an object is blank with bundled string encodings" do
// 34:       Encoding.list.reject(&:dummy?).each do |encoding|
// 35:         expect(" ".encode(encoding).blank?).to be true
// 36:         expect("a".encode(encoding).blank?).to be false
// 37:       end
// 38:     end
// 39:   end
// 40:
// 41:   describe ".present?" do
// 42:     it "checks if an object is present" do
// 43:       blank.each { |v| expect(v.present?).to be false }
// 44:       present.each { |v| expect(v.present?).to be true }
// 45:     end
// 46:   end
// 47:
// 48:   describe ".presence" do
// 49:     it "returns the object if present, or nil" do
// 50:       blank.each { |v| expect(v.presence).to be_nil }
// 51:       present.each { |v| expect(v.presence).to be v }
// 52:     end
// 53:   end
// 54: end
