module github

import brew_runtime
import homebrew.utils.github as actions

// Translated from Homebrew/brew `test/utils/github/actions_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:message) { "lorem ipsum" }` at line 7.
pub fn ruby_actions_spec_l7_d1_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('lorem ipsum')
}

// Ruby it `it "fails when the type is wrong" do` at line 10.
pub fn ruby_actions_spec_l10_d2_fails(args ...brew_runtime.Value) brew_runtime.Value {
	value := actions.ruby_actions_l65_d5_initialize(brew_runtime.object_value('Symbol', 'fatal'), ruby_actions_spec_l7_d1_message(), brew_runtime.string_value('file.txt'))
	return brew_runtime.bool_value(value.type_name == 'ArgumentError')
}

// Ruby it `it "escapes newlines" do` at line 18.
pub fn ruby_actions_spec_l18_d3_escapes(args ...brew_runtime.Value) brew_runtime.Value {
	annotation := actions.ruby_actions_l65_d5_initialize(brew_runtime.object_value('Symbol', 'warning'), brew_runtime.string_value('lorem\nipsum\n'), brew_runtime.string_value('file.txt'))
	return brew_runtime.bool_value(actions.ruby_actions_l81_d6_to_s(annotation).as_string() == '::warning file=file.txt::lorem%0Aipsum%0A')
}

// Ruby it `it "allows specifying the file" do` at line 27.
pub fn ruby_actions_spec_l27_d4_allows(args ...brew_runtime.Value) brew_runtime.Value {
	annotation := actions.ruby_actions_l65_d5_initialize(brew_runtime.object_value('Symbol', 'warning'), ruby_actions_spec_l7_d1_message(), brew_runtime.string_value('file.txt'))
	return brew_runtime.bool_value(actions.ruby_actions_l81_d6_to_s(annotation).as_string() == '::warning file=file.txt::lorem ipsum')
}

// Ruby it `it "allows specifying the title" do` at line 33.
pub fn ruby_actions_spec_l33_d5_allows(args ...brew_runtime.Value) brew_runtime.Value {
	annotation := actions.ruby_actions_l65_d5_initialize(brew_runtime.object_value('Symbol', 'warning'), ruby_actions_spec_l7_d1_message(), brew_runtime.string_value('file.txt'), brew_runtime.string_value('foo'))
	return brew_runtime.bool_value(actions.ruby_actions_l81_d6_to_s(annotation).as_string() == '::warning file=file.txt,title=foo::lorem ipsum')
}

// Ruby it `it "allows specifying the file and line" do` at line 39.
pub fn ruby_actions_spec_l39_d6_allows(args ...brew_runtime.Value) brew_runtime.Value {
	annotation := actions.ruby_actions_l65_d5_initialize(brew_runtime.object_value('Symbol', 'error'), ruby_actions_spec_l7_d1_message(), brew_runtime.string_value('file.txt'), brew_runtime.object_value('NilClass', 'nil'), brew_runtime.int_value(3))
	return brew_runtime.bool_value(actions.ruby_actions_l81_d6_to_s(annotation).as_string() == '::error file=file.txt,line=3::lorem ipsum')
}

// Ruby it `it "allows specifying the file, line and column" do` at line 45.
pub fn ruby_actions_spec_l45_d7_allows(args ...brew_runtime.Value) brew_runtime.Value {
	annotation := actions.ruby_actions_l65_d5_initialize(brew_runtime.object_value('Symbol', 'error'), ruby_actions_spec_l7_d1_message(), brew_runtime.string_value('file.txt'), brew_runtime.object_value('NilClass', 'nil'), brew_runtime.int_value(3), brew_runtime.object_value('NilClass', 'nil'), brew_runtime.int_value(18))
	return brew_runtime.bool_value(actions.ruby_actions_l81_d6_to_s(annotation).as_string() == '::error file=file.txt,line=3,col=18::lorem ipsum')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/github/actions"
// 5:
// 6: RSpec.describe GitHub::Actions::Annotation do
// 7:   let(:message) { "lorem ipsum" }
// 8:
// 9:   describe "#new" do
// 10:     it "fails when the type is wrong" do
// 11:       expect do
// 12:         described_class.new(:fatal, message, file: "file.txt")
// 13:       end.to raise_error(ArgumentError)
// 14:     end
// 15:   end
// 16:
// 17:   describe "#to_s" do
// 18:     it "escapes newlines" do
// 19:       annotation = described_class.new(:warning, <<~EOS, file: "file.txt")
// 20:         lorem
// 21:         ipsum
// 22:       EOS
// 23:
// 24:       expect(annotation.to_s).to eq "::warning file=file.txt::lorem%0Aipsum%0A"
// 25:     end
// 26:
// 27:     it "allows specifying the file" do
// 28:       annotation = described_class.new(:warning, "lorem ipsum", file: "file.txt")
// 29:
// 30:       expect(annotation.to_s).to eq "::warning file=file.txt::lorem ipsum"
// 31:     end
// 32:
// 33:     it "allows specifying the title" do
// 34:       annotation = described_class.new(:warning, "lorem ipsum", file: "file.txt", title: "foo")
// 35:
// 36:       expect(annotation.to_s).to eq "::warning file=file.txt,title=foo::lorem ipsum"
// 37:     end
// 38:
// 39:     it "allows specifying the file and line" do
// 40:       annotation = described_class.new(:error, "lorem ipsum", file: "file.txt", line: 3)
// 41:
// 42:       expect(annotation.to_s).to eq "::error file=file.txt,line=3::lorem ipsum"
// 43:     end
// 44:
// 45:     it "allows specifying the file, line and column" do
// 46:       annotation = described_class.new(:error, "lorem ipsum", file: "file.txt", line: 3, column: 18)
// 47:
// 48:       expect(annotation.to_s).to eq "::error file=file.txt,line=3,col=18::lorem ipsum"
// 49:     end
// 50:   end
// 51: end
