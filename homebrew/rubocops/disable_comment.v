module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/disable_comment.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_new_investigation` at line 11.
pub fn ruby_disable_comment_l11_d1_on_new_investigation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_new_investigation', ...args)
}

// Ruby method `disable_comment?(comment)` at line 25.
pub fn ruby_disable_comment_l25_d2_disable_comment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('disable_comment?', ...args)
}

// Ruby method `comment?(line)` at line 30.
pub fn ruby_disable_comment_l30_d3_comment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comment?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     # Checks if rubocop disable comments have a clarifying comment preceding them.
// 7:     class DisableComment < Base
// 8:       MSG = "Add a clarifying comment to the RuboCop disable comment"
// 9:
// 10:       sig { void }
// 11:       def on_new_investigation
// 12:         super
// 13:
// 14:         processed_source.comments.each do |comment|
// 15:           next unless disable_comment?(comment)
// 16:           next if comment?(processed_source[comment.loc.line - 2])
// 17:
// 18:           add_offense(comment)
// 19:         end
// 20:       end
// 21:
// 22:       private
// 23:
// 24:       sig { params(comment: Parser::Source::Comment).returns(T::Boolean) }
// 25:       def disable_comment?(comment)
// 26:         comment.text.start_with? "# rubocop:disable"
// 27:       end
// 28:
// 29:       sig { params(line: String).returns(T::Boolean) }
// 30:       def comment?(line)
// 31:         line.strip.start_with?("#") && line.strip.delete_prefix("#") != ""
// 32:       end
// 33:     end
// 34:   end
// 35: end
