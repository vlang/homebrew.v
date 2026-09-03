module dependencies

import homebrew

// Translated from Homebrew/brew `dependencies/requirements.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `initialize(*args)` at line 11.
pub fn ruby_requirements_l11_d1_initialize(args ...homebrew.Requirement) Requirements {
	return new_requirements(...args)
}

// Ruby method `<<(other)` at line 16.
pub fn ruby_requirements_l16_d2_anonymous(mut requirements Requirements,
	other homebrew.Requirement) Requirements {
	return requirements.add(other)
}

// Ruby method `inspect` at line 31.
pub fn ruby_requirements_l31_d3_inspect(requirements Requirements) string {
	return requirements.inspect()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A collection of requirements.
// 5: class Requirements < SimpleDelegator
// 6:   extend T::Generic
// 7:
// 8:   Elem = type_member(:out) { { fixed: Requirement } }
// 9:
// 10:   sig { params(args: Requirement).void }
// 11:   def initialize(*args)
// 12:     super(Set.new(args))
// 13:   end
// 14:
// 15:   sig { params(other: Requirement).returns(Requirements) }
// 16:   def <<(other)
// 17:     if other.is_a?(Comparable)
// 18:       __getobj__.grep(other.class) do |req|
// 19:         return self if req > other
// 20:
// 21:         __getobj__.delete(req)
// 22:       end
// 23:     end
// 24:     # see https://sorbet.org/docs/faq#how-can-i-fix-type-errors-that-arise-from-super
// 25:     T.bind(self, T.untyped)
// 26:     super
// 27:     self
// 28:   end
// 29:
// 30:   sig { returns(String) }
// 31:   def inspect
// 32:     "#<#{self.class.name}: {#{__getobj__.to_a.join(", ")}}>"
// 33:   end
// 34: end
