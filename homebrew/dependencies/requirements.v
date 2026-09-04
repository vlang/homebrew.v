module dependencies

import homebrew

// Translated from Homebrew/brew `dependencies/requirements.rb`.
pub struct Requirements {
pub mut:
	items []homebrew.Requirement
}

pub fn new_requirements(initial ...homebrew.Requirement) Requirements {
	mut requirements := Requirements{}
	for requirement in initial {
		requirements.add(requirement)
	}
	return requirements
}

// add translates Requirements#<<. Requirement subclasses that mix in
// Comparable replace weaker instances of their own class; the base typed
// Requirement has equality but no ordering, so its Set behavior is exact here.
pub fn (mut requirements Requirements) add(other homebrew.Requirement) Requirements {
	for requirement in requirements.items {
		if requirement.equals(other) {
			return requirements
		}
	}
	requirements.items << other
	return requirements
}

pub fn (requirements Requirements) count() int {
	return requirements.items.len
}

pub fn (requirements Requirements) inspect() string {
	return '#<Requirements: {${requirements.items.map(it.inspect()).join(', ')}}>'
}
