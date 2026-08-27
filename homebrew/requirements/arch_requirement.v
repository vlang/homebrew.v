module requirements

import brew_runtime

// Translated from Homebrew/brew `requirements/arch_requirement.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :arch` at line 15.
pub fn ruby_arch_requirement_l15_d1_arch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arch', ...args)
}

// Ruby method `initialize(tags)` at line 18.
pub fn ruby_arch_requirement_l18_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `message` at line 32.
pub fn ruby_arch_requirement_l32_d3_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('message', ...args)
}

// Ruby method `inspect` at line 37.
pub fn ruby_arch_requirement_l37_d4_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby method `display_s` at line 42.
pub fn ruby_arch_requirement_l42_d5_display_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('display_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirement"
// 5:
// 6: # A requirement on a specific architecture.
// 7: class ArchRequirement < Requirement
// 8:   Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 9:
// 10:   fatal true
// 11:
// 12:   @arch = T.let(nil, T.nilable(Symbol))
// 13:
// 14:   sig { returns(T.nilable(Symbol)) }
// 15:   attr_reader :arch
// 16:
// 17:   sig { params(tags: T::Array[Symbol]).void }
// 18:   def initialize(tags)
// 19:     @arch = T.let(tags.shift, T.nilable(Symbol))
// 20:     super
// 21:   end
// 22:
// 23:   satisfy(build_env: false) do
// 24:     case @arch
// 25:     when :x86_64 then Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
// 26:     when :arm64 then Hardware::CPU.arm64?
// 27:     when :arm, :intel, :ppc then Hardware::CPU.type == @arch
// 28:     end
// 29:   end
// 30:
// 31:   sig { returns(String) }
// 32:   def message
// 33:     "The #{@arch} architecture is required for this software."
// 34:   end
// 35:
// 36:   sig { returns(String) }
// 37:   def inspect
// 38:     "#<#{self.class.name}: arch=#{@arch.to_s.inspect} #{tags.inspect}>"
// 39:   end
// 40:
// 41:   sig { returns(String) }
// 42:   def display_s
// 43:     "#{@arch} architecture"
// 44:   end
// 45: end
