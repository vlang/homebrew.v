module test

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/warnings_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "restores ignored warnings after an exception" do` at line 7.
pub fn ruby_warnings_spec_l7_d1_restores(args ...brew_runtime.Value) brew_runtime.Value {
	base := homebrew.WarningFilter{}
	_ := homebrew.with_ignored_warnings(base, ['ignored warning'], fn (_ homebrew.WarningFilter) ![]string {
		return error('failure')
	}) or { [] }
	return brew_runtime.bool_value(base.emit('ignored warning\n') == 'ignored warning\n')
}

// Ruby it `it "supports nested ignored warnings" do` at line 15.
pub fn ruby_warnings_spec_l15_d2_supports(args ...brew_runtime.Value) brew_runtime.Value {
	base := homebrew.WarningFilter{}
	mut output := homebrew.with_ignored_warnings(base, ['outer warning'], fn (outer homebrew.WarningFilter) ![]string {
		mut scoped_output := []string{}
		emitted_outer := outer.emit('outer warning\n')
		if emitted_outer.len > 0 {
			scoped_output << emitted_outer
		}
		inner_output := homebrew.with_ignored_warnings(outer, ['inner warning'], fn (inner homebrew.WarningFilter) ![]string {
			mut emitted := []string{}
			for warning in ['outer warning\n', 'inner warning\n'] {
				text := inner.emit(warning)
				if text.len > 0 {
					emitted << text
				}
			}
			return emitted
		})!
		scoped_output << inner_output
		for warning in ['outer warning\n', 'inner warning\n'] {
			emitted := outer.emit(warning)
			if emitted.len > 0 {
				scoped_output << emitted
			}
		}
		return scoped_output
	}) or { return brew_runtime.bool_value(false) }
	emitted := base.emit('outer warning\n')
	if emitted.len > 0 {
		output << emitted
	}
	return brew_runtime.bool_value(output.join('') == 'inner warning\nouter warning\n')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "warnings"
// 5:
// 6: RSpec.describe Warnings do
// 7:   it "restores ignored warnings after an exception" do
// 8:     expect do
// 9:       described_class.ignore(/ignored warning/) { raise "failure" }
// 10:     rescue RuntimeError
// 11:       Warning.warn("ignored warning\n")
// 12:     end.to output("ignored warning\n").to_stderr
// 13:   end
// 14:
// 15:   it "supports nested ignored warnings" do
// 16:     expect do
// 17:       described_class.ignore(/outer warning/) do
// 18:         Warning.warn("outer warning\n")
// 19:         described_class.ignore(/inner warning/) do
// 20:           Warning.warn("outer warning\n")
// 21:           Warning.warn("inner warning\n")
// 22:         end
// 23:         Warning.warn("outer warning\n")
// 24:         Warning.warn("inner warning\n")
// 25:       end
// 26:       Warning.warn("outer warning\n")
// 27:     end.to output("inner warning\nouter warning\n").to_stderr
// 28:   end
// 29: end
