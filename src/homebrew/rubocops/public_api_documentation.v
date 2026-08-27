module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/public_api_documentation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_new_investigation` at line 34.
pub fn ruby_public_api_documentation_l34_d1_on_new_investigation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_new_investigation', ...args)
}

// Ruby method `api_public_comment?(comment)` at line 64.
pub fn ruby_public_api_documentation_l64_d2_api_public_comment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_public_comment?', ...args)
}

// Ruby method `descriptive_comment_preceding?(comment)` at line 69.
pub fn ruby_public_api_documentation_l69_d3_descriptive_comment_preceding(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('descriptive_comment_preceding?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Ensures that methods/attributes annotated with `@api public` have
// 8:       # proper YARD documentation beyond just the annotation itself.
// 9:       # A bare `# @api public` with no preceding description is not sufficient
// 10:       # for public API methods.
// 11:       #
// 12:       # ### Example
// 13:       #
// 14:       # ```ruby
// 15:       # # bad
// 16:       # # @api public
// 17:       # sig { returns(String) }
// 18:       # def foo; end
// 19:       #
// 20:       # # good
// 21:       # # The name of this object.
// 22:       # #
// 23:       # # @api public
// 24:       # sig { returns(String) }
// 25:       # def foo; end
// 26:       # ```
// 27:       class PublicApiDocumentation < Base
// 28:         MSG = "`@api public` methods must have a descriptive YARD comment, not just the annotation."
// 29:         MISSING_INCLUDE_MSG = "`%<file>s` contains `@api public` but is missing from `Style/Documentation.Include`."
// 30:         EXTRA_INCLUDE_MSG = "`%<file>s` is included in `Style/Documentation.Include` but does not contain " \
// 31:                             "`@api public`."
// 32:
// 33:         sig { void }
// 34:         def on_new_investigation
// 35:           super
// 36:
// 37:           comments = processed_source.comments
// 38:           comments.each do |comment|
// 39:             next unless api_public_comment?(comment)
// 40:
// 41:             add_offense(comment) unless descriptive_comment_preceding?(comment)
// 42:           end
// 43:
// 44:           documentation_include = config.dig("Style/Documentation", "Include")
// 45:           file_path = processed_source.file_path
// 46:           return if documentation_include.nil? || file_path.nil?
// 47:
// 48:           api_public_comments = comments.select { |comment| api_public_comment?(comment) }
// 49:           relative_path = file_path.sub(%r{.*/Library/Homebrew/}, "")
// 50:           included = Array(documentation_include).include?(relative_path)
// 51:           if api_public_comments.any? && !included
// 52:             add_offense(api_public_comments.first, message: format(MISSING_INCLUDE_MSG, file: relative_path))
// 53:           elsif api_public_comments.empty? && included
// 54:             add_offense(
// 55:               processed_source.ast || processed_source.buffer.source_range,
// 56:               message: format(EXTRA_INCLUDE_MSG, file: relative_path),
// 57:             )
// 58:           end
// 59:         end
// 60:
// 61:         private
// 62:
// 63:         sig { params(comment: Parser::Source::Comment).returns(T::Boolean) }
// 64:         def api_public_comment?(comment)
// 65:           ["# @api public", "@api public"].include?(comment.text.strip)
// 66:         end
// 67:
// 68:         sig { params(comment: Parser::Source::Comment).returns(T::Boolean) }
// 69:         def descriptive_comment_preceding?(comment)
// 70:           lines = processed_source.lines
// 71:           line_idx = comment.loc.line - 2 # 0-indexed, line before the @api public comment
// 72:
// 73:           while line_idx >= 0
// 74:             line = lines[line_idx]&.strip
// 75:             break if line.nil? || !line.start_with?("#")
// 76:
// 77:             content = line.delete_prefix("#").strip
// 78:             # Skip blank comment lines and YARD tags
// 79:             if content.empty? || content.start_with?("@")
// 80:               line_idx -= 1
// 81:               next
// 82:             end
// 83:
// 84:             return true
// 85:           end
// 86:
// 87:           false
// 88:         end
// 89:       end
// 90:     end
// 91:   end
// 92: end
