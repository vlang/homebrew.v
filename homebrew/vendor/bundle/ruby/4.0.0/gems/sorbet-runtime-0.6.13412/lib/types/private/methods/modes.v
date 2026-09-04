module methods

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/methods/modes.rb`.
// The original source is retained below until every stub has a typed V body.
pub const method_modes = ['standard', 'abstract', 'overridable', 'override', 'overridable_override',
	'untyped']
pub const overridable_modes = ['override', 'overridable', 'overridable_override', 'untyped',
	'abstract']
pub const override_modes = ['override', 'overridable_override']
pub const non_override_modes = ['standard', 'abstract', 'overridable', 'untyped']

// Ruby method `self.standard` at line 5.
pub fn ruby_modes_l5_d1_self_standard(args ...ruby.Value) ruby.Value {
	return ruby.string_value('standard')
}

// Ruby method `self.abstract` at line 8.
pub fn ruby_modes_l8_d2_self_abstract(args ...ruby.Value) ruby.Value {
	return ruby.string_value('abstract')
}

// Ruby method `self.overridable` at line 11.
pub fn ruby_modes_l11_d3_self_overridable(args ...ruby.Value) ruby.Value {
	return ruby.string_value('overridable')
}

// Ruby method `self.override` at line 14.
pub fn ruby_modes_l14_d4_self_override(args ...ruby.Value) ruby.Value {
	return ruby.string_value('override')
}

// Ruby method `self.overridable_override` at line 17.
pub fn ruby_modes_l17_d5_self_overridable_override(args ...ruby.Value) ruby.Value {
	return ruby.string_value('overridable_override')
}

// Ruby method `self.untyped` at line 20.
pub fn ruby_modes_l20_d6_self_untyped(args ...ruby.Value) ruby.Value {
	return ruby.string_value('untyped')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Methods::Modes
// 5:   def self.standard
// 6:     'standard'
// 7:   end
// 8:   def self.abstract
// 9:     'abstract'
// 10:   end
// 11:   def self.overridable
// 12:     'overridable'
// 13:   end
// 14:   def self.override
// 15:     'override'
// 16:   end
// 17:   def self.overridable_override
// 18:     'overridable_override'
// 19:   end
// 20:   def self.untyped
// 21:     'untyped'
// 22:   end
// 23:   MODES = [self.standard, self.abstract, self.overridable, self.override, self.overridable_override, self.untyped].freeze
// 24:
// 25:   OVERRIDABLE_MODES = [self.override, self.overridable, self.overridable_override, self.untyped, self.abstract].freeze
// 26:   OVERRIDE_MODES = [self.override, self.overridable_override].freeze
// 27:   NON_OVERRIDE_MODES = MODES - OVERRIDE_MODES
// 28: end
