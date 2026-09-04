module cask

import ruby

// Translated from Homebrew/brew `cask/denylist.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.reason(name)` at line 8.
pub fn ruby_denylist_l8_d1_self_reason(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('Nil', '')
	}
	return if reason := denylist_reason(args[0].as_string()) {
		ruby.string_value(reason)
	} else {
		ruby.object_value('Nil', '')
	}
}

// denylist_reason returns Homebrew's source-defined reason for casks that are
// not accepted in official taps.
pub fn denylist_reason(name string) ?string {
	if name.starts_with('adobe-after') || name.starts_with('adobe-illustrator')
		|| name.starts_with('adobe-indesign') || name.starts_with('adobe-photoshop')
		|| name.starts_with('adobe-premiere') {
		return 'Adobe casks were removed because they are too difficult to maintain.'
	}
	if name == 'pharo' {
		return 'Pharo developers maintain their own tap.'
	}
	return none
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Cask
// 5:   # List of casks which are not allowed in official taps.
// 6:   module Denylist
// 7:     sig { params(name: String).returns(T.nilable(String)) }
// 8:     def self.reason(name)
// 9:       case name
// 10:       when /^adobe-(after|illustrator|indesign|photoshop|premiere)/
// 11:         "Adobe casks were removed because they are too difficult to maintain."
// 12:       when /^pharo$/
// 13:         "Pharo developers maintain their own tap."
// 14:       end
// 15:     end
// 16:   end
// 17: end
