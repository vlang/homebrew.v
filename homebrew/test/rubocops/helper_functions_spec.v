module rubocops

import ruby
import homebrew.rubocops.@shared as helper_shared

// Translated from Homebrew/brew `test/rubocops/helper_functions_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "caches descendant send nodes for the current source" do` at line 7.
pub fn ruby_helper_functions_spec_l7_d1_caches(args ...ruby.Value) ruby.Value {
	_ = args
	processed_source := helper_shared.helper_processed_source('class Foo; bar; end') or {
		return ruby.bool_value(false)
	}
	mut context := helper_shared.new_helper_functions_context()
	first := context.descendant_send_nodes(processed_source, processed_source.ast)
	again := context.descendant_send_nodes(processed_source, processed_source.ast)
	other_source := helper_shared.helper_processed_source('class Foo; baz; end') or {
		return ruby.bool_value(false)
	}
	other := context.descendant_send_nodes(other_source, other_source.ast)
	return ruby.bool_value(first.identity == again.identity && first.identity != other.identity)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/helper_functions"
// 5:
// 6: RSpec.describe RuboCop::Cop::HelperFunctions do
// 7:   it "caches descendant send nodes for the current source" do
// 8:     processed_source = RuboCop::ProcessedSource.new("class Foo; bar; end", RuboCop::TargetRuby::DEFAULT_VERSION)
// 9:     node = processed_source.ast
// 10:     raise "Failed to parse source" unless node
// 11:
// 12:     first = described_class.descendant_send_nodes(processed_source, node)
// 13:     again = described_class.descendant_send_nodes(processed_source, node)
// 14:
// 15:     other_source = RuboCop::ProcessedSource.new("class Foo; baz; end", RuboCop::TargetRuby::DEFAULT_VERSION)
// 16:     other_node = other_source.ast
// 17:     raise "Failed to parse source" unless other_node
// 18:
// 19:     expect([first.equal?(again), first.equal?(described_class.descendant_send_nodes(other_source, other_node))])
// 20:       .to eq([true, false])
// 21:   end
// 22: end
