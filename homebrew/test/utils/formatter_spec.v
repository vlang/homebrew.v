module utils

import ruby
import homebrew.utils as production_utils

fn formatter_spec_first_row(items []string, min_width int) string {
	return production_utils.formatter_columns(items, 80, true, 2, min_width).split_into_lines()[0]
}

// Translated from Homebrew/brew `test/utils/formatter_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "stretches few short items into wide columns that fill the terminal" do` at line 14.
pub fn ruby_formatter_spec_l14_d1_stretches(args ...ruby.Value) ruby.Value {
	first_row := formatter_spec_first_row(['aa', 'bb', 'cc', 'dd'], 0)
	return ruby.bool_value((first_row.index('bb') or { -1 }) > 2)
}

// Ruby it `it "uses tighter columns when min_width fits more columns than the item count" do` at line 20.
pub fn ruby_formatter_spec_l20_d2_uses(args ...ruby.Value) ruby.Value {
	default_first_row := formatter_spec_first_row(['aa', 'bb', 'cc', 'dd'], 0)
	pinned_first_row := formatter_spec_first_row(['aa', 'bb', 'cc', 'dd'], 4)
	return ruby.bool_value((pinned_first_row.index('bb') or { 100 }) < (default_first_row.index('bb') or { -1 }))
}

// Ruby it `it "produces matching column widths for two calls sharing the same min_width" do` at line 27.
pub fn ruby_formatter_spec_l27_d3_produces(args ...ruby.Value) ruby.Value {
	many := []string{len: 20, init: 'item${index + 1}'}
	few := ['a', 'b', 'c']
	shared_min_width := 6
	many_first_row := formatter_spec_first_row(many, shared_min_width)
	few_first_row := formatter_spec_first_row(few, shared_min_width)
	return ruby.bool_value((many_first_row.index('item3') or { -1 }) == (few_first_row.index('b') or { -2 }))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/formatter"
// 5:
// 6: RSpec.describe Formatter do
// 7:   describe "::columns" do
// 8:     before do
// 9:       allow($stdout).to receive(:tty?).and_return(true)
// 10:       allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 11:       allow(Tty).to receive(:width).and_return(80)
// 12:     end
// 13:
// 14:     it "stretches few short items into wide columns that fill the terminal" do
// 15:       first_row = described_class.columns(%w[aa bb cc dd]).lines.fetch(0).chomp
// 16:
// 17:       expect(first_row.index("bb")).to be > 2
// 18:     end
// 19:
// 20:     it "uses tighter columns when min_width fits more columns than the item count" do
// 21:       default_first_row = described_class.columns(%w[aa bb cc dd]).lines.fetch(0).chomp
// 22:       pinned_first_row = described_class.columns(%w[aa bb cc dd], min_width: 4).lines.fetch(0).chomp
// 23:
// 24:       expect(pinned_first_row.index("bb")).to be < default_first_row.index("bb")
// 25:     end
// 26:
// 27:     it "produces matching column widths for two calls sharing the same min_width" do
// 28:       many = (1..20).map { |i| "item#{i}" }
// 29:       few = %w[a b c]
// 30:       shared_min_width = (many + few).map(&:length).max || 0
// 31:
// 32:       many_first_row = described_class.columns(many, min_width: shared_min_width).lines.fetch(0).chomp
// 33:       few_first_row = described_class.columns(few, min_width: shared_min_width).lines.fetch(0).chomp
// 34:
// 35:       expect(many_first_row.index("item3")).to eq(few_first_row.index("b"))
// 36:     end
// 37:   end
// 38: end
