module homebrew

import brew_runtime

// Translated from Homebrew/brew `dependents_message.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :reqs` at line 10.
pub fn ruby_dependents_message_l10_d1_reqs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reqs', ...args)
}

// Ruby attr_reader `attr_reader :deps, :named_args` at line 13.
pub fn ruby_dependents_message_l13_d2_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deps', ...args)
}

// Ruby attr_reader `attr_reader :deps, :named_args` at line 13.
pub fn ruby_dependents_message_l13_d3_named_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('named_args', ...args)
}

// Ruby method `initialize(requireds, dependents, named_args: [])` at line 16.
pub fn ruby_dependents_message_l16_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `output` at line 23.
pub fn ruby_dependents_message_l23_d5_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output', ...args)
}

// Ruby method `sample_command` at line 35.
pub fn ruby_dependents_message_l35_d6_sample_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sample_command', ...args)
}

// Ruby method `are_required_by_deps` at line 40.
pub fn ruby_dependents_message_l40_d7_are_required_by_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('are_required_by_deps', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: class DependentsMessage
// 7:   include ::Utils::Output::Mixin
// 8:
// 9:   sig { returns(T::Array[T.any(String, Keg)]) }
// 10:   attr_reader :reqs
// 11:
// 12:   sig { returns(T::Array[String]) }
// 13:   attr_reader :deps, :named_args
// 14:
// 15:   sig { params(requireds: T::Array[T.any(String, Keg)], dependents: T::Array[String], named_args: T::Array[String]).void }
// 16:   def initialize(requireds, dependents, named_args: [])
// 17:     @reqs = requireds
// 18:     @deps = dependents
// 19:     @named_args = named_args
// 20:   end
// 21:
// 22:   sig { void }
// 23:   def output
// 24:     ofail <<~EOS
// 25:       Refusing to uninstall #{reqs.to_sentence}
// 26:       because #{reqs.one? ? "it" : "they"} #{are_required_by_deps}.
// 27:       You can override this and force removal with:
// 28:         #{sample_command}
// 29:     EOS
// 30:   end
// 31:
// 32:   protected
// 33:
// 34:   sig { returns(String) }
// 35:   def sample_command
// 36:     "brew uninstall --ignore-dependencies #{named_args.join(" ")}"
// 37:   end
// 38:
// 39:   sig { returns(String) }
// 40:   def are_required_by_deps
// 41:     "#{reqs.one? ? "is" : "are"} required by #{deps.to_sentence}, " \
// 42:       "which #{deps.one? ? "is" : "are"} currently installed"
// 43:   end
// 44: end
