module homebrew

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
