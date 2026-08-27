module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/null_section.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `null?` at line 13.
pub fn ruby_null_section_l13_d1_null(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('null?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/sections/section'
// 4:
// 5: module ELFTools
// 6:   module Sections
// 7:     # Class of null section.
// 8:     # Null section is for specific the end
// 9:     # of linked list (+sh_link+) between sections.
// 10:     class NullSection < Section
// 11:       # Is this a null section?
// 12:       # @return [Boolean] Yes it is.
// 13:       def null?
// 14:         true
// 15:       end
// 16:     end
// 17:   end
// 18: end
