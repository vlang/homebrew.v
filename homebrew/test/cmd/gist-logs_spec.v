module cmd

import ruby
import homebrew.cmd as production_cmd

// Translated from Homebrew/brew `test/cmd/gist-logs_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:glue) { "\n[...snip...]\n" }` at line 11.
pub fn ruby_gist_logs_spec_l11_d1_glue(args ...ruby.Value) ruby.Value {
	return ruby.string_value(production_cmd.gist_logs_glue)
}

// Ruby it `it "truncates long text to approximate size" do` at line 13.
pub fn ruby_gist_logs_spec_l13_d2_truncates(args ...ruby.Value) ruby.Value {
	text := if args.len > 0 { args[0].as_string() } else { 'x'.repeat(40) }
	max_bytes := if args.len > 1 { int(args[1].as_int() or { 20 }) } else { 20 }
	result := production_cmd.truncate_text_to_approximate_size(text, max_bytes, 0.5) or {
		return ruby.bool_value(false)
	}
	front_and_back := result.starts_with('x') && result.ends_with('x')
	return ruby.bool_value(result.len == max_bytes
		&& result.contains(production_cmd.gist_logs_glue)
		&& front_and_back)
}

// Ruby it `it "respects front_weight: 0.0" do` at line 22.
pub fn ruby_gist_logs_spec_l22_d3_respects(args ...ruby.Value) ruby.Value {
	text := if args.len > 0 { args[0].as_string() } else { 'x'.repeat(40) }
	max_bytes := if args.len > 1 { int(args[1].as_int() or { 20 }) } else { 20 }
	result := production_cmd.truncate_text_to_approximate_size(text, max_bytes, 0.0) or {
		return ruby.bool_value(false)
	}
	expected := production_cmd.gist_logs_glue + 'x'.repeat(max_bytes - production_cmd.gist_logs_glue.len)
	return ruby.bool_value(result == expected)
}

// Ruby it `it "respects front_weight: 1.0" do` at line 30.
pub fn ruby_gist_logs_spec_l30_d4_respects(args ...ruby.Value) ruby.Value {
	text := if args.len > 0 { args[0].as_string() } else { 'x'.repeat(40) }
	max_bytes := if args.len > 1 { int(args[1].as_int() or { 20 }) } else { 20 }
	result := production_cmd.truncate_text_to_approximate_size(text, max_bytes, 1.0) or {
		return ruby.bool_value(false)
	}
	expected := 'x'.repeat(max_bytes - production_cmd.gist_logs_glue.len) + production_cmd.gist_logs_glue
	return ruby.bool_value(result == expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/gist-logs"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::GistLogs do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe ".truncate_text_to_approximate_size" do
// 11:     let(:glue) { "\n[...snip...]\n" } # hard-coded copy from truncate_text_to_approximate_size
// 12:
// 13:     it "truncates long text to approximate size" do
// 14:       n = 20
// 15:       long_s = "x" * 40
// 16:
// 17:       s = described_class.truncate_text_to_approximate_size(long_s, n)
// 18:       expect(s.length).to eq(n)
// 19:       expect(s).to match(/^x+#{Regexp.escape(glue)}x+$/)
// 20:     end
// 21:
// 22:     it "respects front_weight: 0.0" do
// 23:       n = 20
// 24:       long_s = "x" * 40
// 25:
// 26:       s = described_class.truncate_text_to_approximate_size(long_s, n, front_weight: 0.0)
// 27:       expect(s).to eq(glue + ("x" * (n - glue.length)))
// 28:     end
// 29:
// 30:     it "respects front_weight: 1.0" do
// 31:       n = 20
// 32:       long_s = "x" * 40
// 33:
// 34:       s = described_class.truncate_text_to_approximate_size(long_s, n, front_weight: 1.0)
// 35:       expect(s).to eq(("x" * (n - glue.length)) + glue)
// 36:     end
// 37:   end
// 38: end
