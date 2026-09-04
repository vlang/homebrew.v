module homebrew

import ruby
import homebrew.extend

// Translated from Homebrew/brew `dependents_message.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct DependentsMessage {
pub:
	reqs       []string
	deps       []string
	named_args []string
}

pub fn new_dependents_message(requireds []string, dependents []string,
	named_args []string) DependentsMessage {
	return DependentsMessage{
		reqs: requireds.clone()
		deps: dependents.clone()
		named_args: named_args.clone()
	}
}

pub fn (message DependentsMessage) sample_command() string {
	return 'brew uninstall --ignore-dependencies ${message.named_args.join(' ')}'
}

pub fn (message DependentsMessage) are_required_by_deps() string {
	required_verb := if message.reqs.len == 1 { 'is' } else { 'are' }
	dependent_verb := if message.deps.len == 1 { 'is' } else { 'are' }
	dependents := extend.array_to_sentence(message.deps, ', ', ' and ', ' and ')
	return '${required_verb} required by ${dependents}, which ${dependent_verb} currently installed'
}

pub fn (message DependentsMessage) output() string {
	requireds := extend.array_to_sentence(message.reqs, ', ', ' and ', ' and ')
	pronoun := if message.reqs.len == 1 { 'it' } else { 'they' }
	return 'Error: Refusing to uninstall ${requireds}\nbecause ${pronoun} ${message.are_required_by_deps()}.\nYou can override this and force removal with:\n  ${message.sample_command()}\n'
}

pub fn dependents_message_value(message DependentsMessage) ruby.Value {
	return ruby.Value{
		type_name: 'DependentsMessage'
		repr: message.output()
		map_data: {
			'reqs':       ruby.string_array_value(message.reqs)
			'deps':       ruby.string_array_value(message.deps)
			'named_args': ruby.string_array_value(message.named_args)
		}
	}
}

fn dependents_message_from_value(value ruby.Value) !DependentsMessage {
	if value.type_name != 'DependentsMessage' && value.type_name != 'Hash' {
		return error('expected DependentsMessage, got ${value.type_name}')
	}
	return new_dependents_message(
		(value.map_data['reqs'] or { ruby.string_array_value([]) }).as_string_array()!,
		(value.map_data['deps'] or { ruby.string_array_value([]) }).as_string_array()!,
		(value.map_data['named_args'] or { ruby.string_array_value([]) }).as_string_array()!,
	)
}

fn dependents_message_receiver(args []ruby.Value) ?DependentsMessage {
	if args.len == 0 {
		return none
	}
	return dependents_message_from_value(args[0]) or { return none }
}

// Ruby attr_reader `attr_reader :reqs` at line 10.
pub fn ruby_dependents_message_l10_d1_reqs(args ...ruby.Value) ruby.Value {
	message := dependents_message_receiver(args) or { return ruby.string_array_value([]) }
	return ruby.string_array_value(message.reqs)
}

// Ruby attr_reader `attr_reader :deps, :named_args` at line 13.
pub fn ruby_dependents_message_l13_d2_deps(args ...ruby.Value) ruby.Value {
	message := dependents_message_receiver(args) or { return ruby.string_array_value([]) }
	return ruby.string_array_value(message.deps)
}

// Ruby attr_reader `attr_reader :deps, :named_args` at line 13.
pub fn ruby_dependents_message_l13_d3_named_args(args ...ruby.Value) ruby.Value {
	message := dependents_message_receiver(args) or { return ruby.string_array_value([]) }
	return ruby.string_array_value(message.named_args)
}

// Ruby method `initialize(requireds, dependents, named_args: [])` at line 16.
pub fn ruby_dependents_message_l16_d4_initialize(args ...ruby.Value) ruby.Value {
	requireds := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	dependents := if args.len > 1 {
		args[1].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	named_args := if args.len > 2 {
		args[2].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return dependents_message_value(new_dependents_message(requireds, dependents, named_args))
}

// Ruby method `output` at line 23.
pub fn ruby_dependents_message_l23_d5_output(args ...ruby.Value) ruby.Value {
	message := dependents_message_receiver(args) or { return ruby.string_value('') }
	return ruby.string_value(message.output())
}

// Ruby method `sample_command` at line 35.
pub fn ruby_dependents_message_l35_d6_sample_command(args ...ruby.Value) ruby.Value {
	message := dependents_message_receiver(args) or { return ruby.string_value('') }
	return ruby.string_value(message.sample_command())
}

// Ruby method `are_required_by_deps` at line 40.
pub fn ruby_dependents_message_l40_d7_are_required_by_deps(args ...ruby.Value) ruby.Value {
	message := dependents_message_receiver(args) or { return ruby.string_value('') }
	return ruby.string_value(message.are_required_by_deps())
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
