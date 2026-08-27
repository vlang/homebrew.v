module elf

import brew_runtime

// Translated from Homebrew/brew `os/linux/elf/os.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.expand_elf_dst(str, ref, repl)` at line 11.
pub fn ruby_os_l11_d1_self_expand_elf_dst(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.expand_elf_dst', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     # Helper functions for working with ELF objects.
// 7:     #
// 8:     # @api private
// 9:     module Elf
// 10:       sig { params(str: String, ref: String, repl: T.any(String, ::Pathname)).returns(String) }
// 11:       def self.expand_elf_dst(str, ref, repl)
// 12:         # ELF gABI rules for DSTs:
// 13:         #   - Longest possible sequence using the rules (greedy).
// 14:         #   - Must start with a $ (enforced by caller).
// 15:         #   - Must follow $ with one underscore or ASCII [A-Za-z] (caller
// 16:         #     follows these rules for REF) or '{' (start curly quoted name).
// 17:         #   - Must follow first two characters with zero or more [A-Za-z0-9_]
// 18:         #     (enforced by caller) or '}' (end curly quoted name).
// 19:         # (from https://github.com/bminor/glibc/blob/41903cb6f460d62ba6dd2f4883116e2a624ee6f8/elf/dl-load.c#L182-L228)
// 20:
// 21:         # In addition to capturing a token, also attempt to capture opening/closing braces and check that they are not
// 22:         # mismatched before expanding.
// 23:         str.gsub(/\$({?)([a-zA-Z_][a-zA-Z0-9_]*)(}?)/) do |orig_str|
// 24:           has_opening_brace = ::Regexp.last_match(1).present?
// 25:           matched_text = ::Regexp.last_match(2)
// 26:           has_closing_brace = ::Regexp.last_match(3).present?
// 27:           if (matched_text == ref) && (has_opening_brace == has_closing_brace)
// 28:             repl
// 29:           else
// 30:             orig_str
// 31:           end
// 32:         end
// 33:       end
// 34:     end
// 35:   end
// 36: end
