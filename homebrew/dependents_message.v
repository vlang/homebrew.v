module homebrew

import ruby
import homebrew.extend

// Translated from Homebrew/brew `dependents_message.rb`.
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
