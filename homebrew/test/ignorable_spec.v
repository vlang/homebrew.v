module test

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/ignorable_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn ignorable_spec_exception() homebrew.IgnorableException {
	return homebrew.IgnorableException{
		type_name: 'RuntimeError'
		message: 'raised in block'
		backtrace: ['ignorable_spec.rb:8:in `raise_runtime_error`']
	}
}

fn ignorable_spec_program(decision homebrew.IgnorableDecision) homebrew.IgnorableProgram {
	return homebrew.IgnorableProgram{
		exception: ignorable_spec_exception()
		decision: decision
		result: brew_runtime.string_array_value(['before', 'after'])
	}
}

// Ruby method `raise_runtime_error` at line 7.
pub fn ruby_ignorable_spec_l7_d1_raise_runtime_error(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	exception := ignorable_spec_exception()
	return brew_runtime.structured_value(exception.type_name, exception.message, {
		'message':   exception.message
		'backtrace': exception.backtrace.join('\n')
	})
}

// Ruby it `it "resumes execution after the raise site when the handler returns :ignore" do` at line 12.
pub fn ruby_ignorable_spec_l12_d2_resumes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	result := state.hook_raise(ignorable_spec_program(.ignore)) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.as_string_array() or { return brew_runtime.bool_value(false) } == [
		'before',
		'after',
	] && state.steps == ['before', 'after'])
}

// Ruby it `it "extends exceptions passed to the handler with ExceptionMixin" do` at line 23.
pub fn ruby_ignorable_spec_l23_d3_extends(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	state.hook_raise(ignorable_spec_program(.ignore)) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(state.exception_was_marked)
}

// Ruby it `it "raises at the raise site when the handler returns :raise" do` at line 32.
pub fn ruby_ignorable_spec_l32_d4_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	program := homebrew.IgnorableProgram{
		exception: ignorable_spec_exception()
		decision: .raise_exception
		rescued_in_block: true
	}
	result := state.hook_raise(program) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.type_name == 'Symbol' && result.as_string() == 'rescued_in_block')
}

// Ruby it `it "propagates unrescued exceptions when the handler returns :raise" do` at line 41.
pub fn ruby_ignorable_spec_l41_d5_propagates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	state.hook_raise(ignorable_spec_program(.raise_exception)) or {
		return brew_runtime.bool_value(err.msg() == 'raised in block')
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "preserves the exception's backtrace when the handler returns :raise" do` at line 47.
pub fn ruby_ignorable_spec_l47_d6_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	state.hook_raise(ignorable_spec_program(.raise_exception)) or {
		return brew_runtime.bool_value(state.propagated_backtrace == state.yielded_backtrace)
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "runs the block's ensure blocks when the handler raises" do` at line 61.
pub fn ruby_ignorable_spec_l61_d7_runs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	program := homebrew.IgnorableProgram{
		exception: ignorable_spec_exception()
		decision: .handler_exception
		ensure_block: true
	}
	state.hook_raise(program) or {
		return brew_runtime.bool_value(err.msg() == 'raised in block' && state.ensure_ran)
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "does not consult the handler for exceptions not raised from Ruby code" do` at line 73.
pub fn ruby_ignorable_spec_l73_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	exception := homebrew.IgnorableException{
		type_name: 'ArgumentError'
		message: 'raised in block'
		backtrace: ['ignorable_spec.rb:75:in `Integer`']
		external: true
	}
	program := homebrew.IgnorableProgram{
		exception: exception
		decision: .ignore
	}
	state.hook_raise(program) or {
		return brew_runtime.bool_value(err.msg() == 'raised in block' && state.handler_calls == 0)
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "does not consult the handler for ScriptError" do` at line 79.
pub fn ruby_ignorable_spec_l79_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	exception := homebrew.IgnorableException{
		type_name: 'NotImplementedError'
		message: 'raised in block'
		backtrace: ['ignorable_spec.rb:81']
		script_error: true
	}
	program := homebrew.IgnorableProgram{
		exception: exception
		decision: .ignore
	}
	state.hook_raise(program) or {
		return brew_runtime.bool_value(err.msg() == 'raised in block' && state.handler_calls == 0)
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "restores the original raise afterwards" do` at line 85.
pub fn ruby_ignorable_spec_l85_d10_restores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	result := state.hook_raise(homebrew.IgnorableProgram{
		decision: .raise_exception
		result: brew_runtime.object_value('Symbol', 'noop')
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.as_string() == 'noop' && !state.hook_installed)
}

// Ruby it `it "restores the original raise when an exception propagates" do` at line 90.
pub fn ruby_ignorable_spec_l90_d11_restores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := homebrew.new_ignorable_state()
	state.hook_raise(ignorable_spec_program(.raise_exception)) or {
		return brew_runtime.bool_value(!state.hook_installed)
	}
	return brew_runtime.bool_value(false)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "ignorable"
// 5:
// 6: RSpec.describe Ignorable do
// 7:   def raise_runtime_error
// 8:     raise "raised in block"
// 9:   end
// 10:
// 11:   describe "::hook_raise" do
// 12:     it "resumes execution after the raise site when the handler returns :ignore" do
// 13:       steps = []
// 14:       result = described_class.hook_raise(on_ignorable: ->(_e) { :ignore }) do
// 15:         steps << :before
// 16:         raise_runtime_error
// 17:         steps << :after
// 18:         steps
// 19:       end
// 20:       expect(result).to eq([:before, :after])
// 21:     end
// 22:
// 23:     it "extends exceptions passed to the handler with ExceptionMixin" do
// 24:       exception = nil
// 25:       described_class.hook_raise(on_ignorable: lambda { |e|
// 26:         exception = e
// 27:         :ignore
// 28:       }) { raise_runtime_error }
// 29:       expect(exception).to be_a(described_class::ExceptionMixin)
// 30:     end
// 31:
// 32:     it "raises at the raise site when the handler returns :raise" do
// 33:       result = described_class.hook_raise(on_ignorable: ->(_e) { :raise }) do
// 34:         raise_runtime_error
// 35:       rescue RuntimeError
// 36:         :rescued_in_block
// 37:       end
// 38:       expect(result).to eq(:rescued_in_block)
// 39:     end
// 40:
// 41:     it "propagates unrescued exceptions when the handler returns :raise" do
// 42:       expect do
// 43:         described_class.hook_raise(on_ignorable: ->(_e) { :raise }) { raise_runtime_error }
// 44:       end.to raise_error(RuntimeError, "raised in block")
// 45:     end
// 46:
// 47:     it "preserves the exception's backtrace when the handler returns :raise" do
// 48:       yielded_backtrace = nil
// 49:       exception = nil
// 50:       begin
// 51:         described_class.hook_raise(on_ignorable: lambda { |e|
// 52:           yielded_backtrace = e.backtrace.dup
// 53:           :raise
// 54:         }) { raise_runtime_error }
// 55:       rescue RuntimeError => e
// 56:         exception = e
// 57:       end
// 58:       expect(exception.backtrace).to eq(yielded_backtrace)
// 59:     end
// 60:
// 61:     it "runs the block's ensure blocks when the handler raises" do
// 62:       ensured = false
// 63:       expect do
// 64:         described_class.hook_raise(on_ignorable: ->(e) { raise e }) do
// 65:           raise_runtime_error
// 66:         ensure
// 67:           ensured = true
// 68:         end
// 69:       end.to raise_error(RuntimeError, "raised in block")
// 70:       expect(ensured).to be(true)
// 71:     end
// 72:
// 73:     it "does not consult the handler for exceptions not raised from Ruby code" do
// 74:       expect do
// 75:         described_class.hook_raise(on_ignorable: ->(_e) { :ignore }) { Integer("nope") }
// 76:       end.to raise_error(ArgumentError)
// 77:     end
// 78:
// 79:     it "does not consult the handler for ScriptError" do
// 80:       expect do
// 81:         described_class.hook_raise(on_ignorable: ->(_e) { :ignore }) { raise NotImplementedError }
// 82:       end.to raise_error(NotImplementedError)
// 83:     end
// 84:
// 85:     it "restores the original raise afterwards" do
// 86:       described_class.hook_raise(on_ignorable: ->(_e) { :raise }) { :noop }
// 87:       expect(Object.instance_method(:raise).owner).to eq(Kernel)
// 88:     end
// 89:
// 90:     it "restores the original raise when an exception propagates" do
// 91:       begin
// 92:         described_class.hook_raise(on_ignorable: ->(_e) { :raise }) { raise_runtime_error }
// 93:       rescue RuntimeError
// 94:         nil
// 95:       end
// 96:       expect(Object.instance_method(:fail).owner).to eq(Kernel)
// 97:     end
// 98:   end
// 99: end
