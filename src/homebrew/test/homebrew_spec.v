module test

import brew_runtime

// Translated from Homebrew/brew `test/homebrew_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "wraps matching methods with timing" do` at line 18.
pub fn ruby_homebrew_spec_l18_d1_wraps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wraps', ...args)
}

// Ruby method `check_something` at line 20.
pub fn ruby_homebrew_spec_l20_d2_check_something(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_something', ...args)
}

// Ruby it `it "does not recurse when a prepended module calls super" do` at line 31.
pub fn ruby_homebrew_spec_l31_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby method `check_example` at line 33.
pub fn ruby_homebrew_spec_l33_d4_check_example(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_example', ...args)
}

// Ruby method `check_example` at line 39.
pub fn ruby_homebrew_spec_l39_d5_check_example(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_example', ...args)
}

// Ruby it `it "only wraps methods matching the pattern" do` at line 51.
pub fn ruby_homebrew_spec_l51_d6_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby method `check_matched` at line 53.
pub fn ruby_homebrew_spec_l53_d7_check_matched(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_matched', ...args)
}

// Ruby method `other_method` at line 57.
pub fn ruby_homebrew_spec_l57_d8_other_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('other_method', ...args)
}

// Ruby it `it "returns true for a successful command" do` at line 74.
pub fn ruby_homebrew_spec_l74_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for a failing command" do` at line 78.
pub fn ruby_homebrew_spec_l78_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "does not raise for a successful command" do` at line 84.
pub fn ruby_homebrew_spec_l84_d11_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "raises for a failing command" do` at line 88.
pub fn ruby_homebrew_spec_l88_d12_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "homebrew"
// 5:
// 6: # $times is the global used by inject_dump_stats! for recording method timings
// 7: # rubocop:disable Style/GlobalVars
// 8: RSpec.describe Homebrew do
// 9:   describe ".inject_dump_stats!" do
// 10:     before do
// 11:       $times = {}
// 12:     end
// 13:
// 14:     after do
// 15:       $times = nil
// 16:     end
// 17:
// 18:     it "wraps matching methods with timing" do
// 19:       klass = Class.new do
// 20:         def check_something
// 21:           "result"
// 22:         end
// 23:       end
// 24:
// 25:       described_class.inject_dump_stats!(klass, /^check_/)
// 26:
// 27:       expect(klass.new.check_something).to eq("result")
// 28:       expect($times).to have_key(:check_something)
// 29:     end
// 30:
// 31:     it "does not recurse when a prepended module calls super" do
// 32:       klass = Class.new do
// 33:         def check_example
// 34:           "base"
// 35:         end
// 36:       end
// 37:
// 38:       mod = Module.new do
// 39:         def check_example
// 40:           "#{super}_extended"
// 41:         end
// 42:       end
// 43:
// 44:       klass.prepend(mod)
// 45:       described_class.inject_dump_stats!(klass, /^check_/)
// 46:
// 47:       expect(klass.new.check_example).to eq("base_extended")
// 48:       expect($times).to have_key(:check_example)
// 49:     end
// 50:
// 51:     it "only wraps methods matching the pattern" do
// 52:       klass = Class.new do
// 53:         def check_matched
// 54:           "matched"
// 55:         end
// 56:
// 57:         def other_method
// 58:           "other"
// 59:         end
// 60:       end
// 61:
// 62:       described_class.inject_dump_stats!(klass, /^check_/)
// 63:
// 64:       instance = klass.new
// 65:       instance.check_matched
// 66:       instance.other_method
// 67:
// 68:       expect($times).to have_key(:check_matched)
// 69:       expect($times).not_to have_key(:other_method)
// 70:     end
// 71:   end
// 72:
// 73:   describe ".quiet_system" do
// 74:     it "returns true for a successful command" do
// 75:       expect(described_class.quiet_system("true")).to be true
// 76:     end
// 77:
// 78:     it "returns false for a failing command" do
// 79:       expect(described_class.quiet_system("false")).to be false
// 80:     end
// 81:   end
// 82:
// 83:   describe ".safe_system" do
// 84:     it "does not raise for a successful command" do
// 85:       expect { described_class.safe_system("true") }.not_to raise_error
// 86:     end
// 87:
// 88:     it "raises for a failing command" do
// 89:       expect { described_class.safe_system("false") }.to raise_error(ErrorDuringExecution)
// 90:     end
// 91:   end
// 92: end
// 93: # rubocop:enable Style/GlobalVars
