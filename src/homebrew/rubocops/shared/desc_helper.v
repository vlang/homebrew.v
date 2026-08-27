module shared

import brew_runtime

// Translated from Homebrew/brew `rubocops/shared/desc_helper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_desc(type, name, desc_call)` at line 21.
pub fn ruby_desc_helper_l21_d1_audit_desc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_desc', ...args)
}

// Ruby method `desc_problem(message)` at line 89.
pub fn ruby_desc_helper_l89_d2_desc_problem(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('desc_problem', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/helper_functions"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     # This module performs common checks the `desc` field in both formulae and casks.
// 9:     module DescHelper
// 10:       include HelperFunctions
// 11:
// 12:       MAX_DESC_LENGTH = 80
// 13:
// 14:       VALID_LOWERCASE_WORDS = %w[
// 15:         iOS
// 16:         iPhone
// 17:         macOS
// 18:       ].freeze
// 19:
// 20:       sig { params(type: Symbol, name: T.nilable(String), desc_call: T.nilable(RuboCop::AST::Node)).void }
// 21:       def audit_desc(type, name, desc_call)
// 22:         # Check if a desc is present.
// 23:         if desc_call.nil?
// 24:           problem "#{type.to_s.capitalize} should have a `desc` (description)."
// 25:           return
// 26:         end
// 27:
// 28:         @offensive_node = T.let(desc_call, T.nilable(RuboCop::AST::Node))
// 29:         @name = T.let(name, T.nilable(String))
// 30:
// 31:         desc = T.cast(desc_call, RuboCop::AST::SendNode).first_argument
// 32:
// 33:         # Check if the desc is empty.
// 34:         desc_length = string_content(desc).length
// 35:         if desc_length.zero?
// 36:           problem "The `desc` (description) should not be an empty string."
// 37:           return
// 38:         end
// 39:
// 40:         # Check the desc for leading whitespace.
// 41:         desc_problem "Description shouldn't have leading spaces." if regex_match_group(desc, /^\s+/)
// 42:
// 43:         # Check the desc for trailing whitespace.
// 44:         desc_problem "Description shouldn't have trailing spaces." if regex_match_group(desc, /\s+$/)
// 45:
// 46:         # Check if "command-line" is spelled incorrectly in the desc.
// 47:         if (match = regex_match_group(desc, /(command ?line)/i))
// 48:           c = match.to_s[0]
// 49:           desc_problem "Description should use \"#{c}ommand-line\" instead of \"#{match}\"."
// 50:         end
// 51:
// 52:         # Check if the desc starts with an article.
// 53:         desc_problem "Description shouldn't start with an article." if regex_match_group(desc, /^(the|an?)(?=\s)/i)
// 54:
// 55:         # Check if invalid lowercase words are at the start of a desc.
// 56:         if !VALID_LOWERCASE_WORDS.include?(string_content(desc).split.first) && regex_match_group(desc, /^[a-z]/)
// 57:           desc_problem "Description should start with a capital letter."
// 58:         end
// 59:
// 60:         # Check if the desc starts with the formula's or cask's name.
// 61:         name_regex = T.must(name).delete("-").chars.join('[\s\-]?')
// 62:         if regex_match_group(desc, /^#{name_regex}\b/i)
// 63:           desc_problem "Description shouldn't start with the #{type} name."
// 64:         end
// 65:
// 66:         if type == :cask &&
// 67:            (match = regex_match_group(desc, /\b(macOS|Mac( ?OS( ?X)?)?|OS ?X)(?! virtual machines?)\b/i)) &&
// 68:            match[1] != "MAC"
// 69:           add_offense(@offensive_source_range, message: "Description shouldn't contain the platform.")
// 70:         end
// 71:
// 72:         # Check if a full stop is used at the end of a desc (apart from in the case of "etc.").
// 73:         if regex_match_group(desc, /\.$/) && !string_content(desc).end_with?("etc.")
// 74:           desc_problem "Description shouldn't end with a full stop."
// 75:         end
// 76:
// 77:         # Check if the desc contains Unicode emojis or symbols (Unicode Other Symbols category).
// 78:         desc_problem "Description shouldn't contain Unicode emojis or symbols." if regex_match_group(desc, /\p{So}/)
// 79:
// 80:         # Check if the desc length exceeds maximum length.
// 81:         return if desc_length <= MAX_DESC_LENGTH
// 82:
// 83:         problem "Description is too long. It should be less than #{MAX_DESC_LENGTH} characters. " \
// 84:                 "The current length is #{desc_length}."
// 85:       end
// 86:
// 87:       # Auto correct desc problems. `regex_match_group` must be called before this to populate @offense_source_range.
// 88:       sig { params(message: String).void }
// 89:       def desc_problem(message)
// 90:         add_offense(@offensive_source_range, message:) do |corrector|
// 91:           match_data = T.must(@offensive_node).source.match(/\A(?<quote>["'])(?<correction>.*)(?:\k<quote>)\Z/)
// 92:           correction = match_data[:correction]
// 93:           quote = match_data[:quote]
// 94:
// 95:           next if correction.nil?
// 96:
// 97:           correction.gsub!(/^\s+/, "")
// 98:           correction.gsub!(/\s+$/, "")
// 99:
// 100:           correction.sub!(/^(the|an?)\s+/i, "")
// 101:
// 102:           first_word = correction.split.first
// 103:           unless VALID_LOWERCASE_WORDS.include?(first_word)
// 104:             first_char = first_word.to_s[0]
// 105:             correction[0] = first_char.upcase if first_char
// 106:           end
// 107:
// 108:           correction.gsub!(/(ommand ?line)/i, "ommand-line")
// 109:           correction.gsub!(/(^|[^a-z])#{@name}([^a-z]|$)/i, "\\1\\2")
// 110:           correction.gsub!(/\s?\p{So}/, "")
// 111:           correction.gsub!(/^\s+/, "")
// 112:           correction.gsub!(/\s+$/, "")
// 113:           correction.gsub!(/\.$/, "")
// 114:
// 115:           next if correction == match_data[:correction]
// 116:
// 117:           corrector.replace(@offensive_node&.source_range, "#{quote}#{correction}#{quote}")
// 118:         end
// 119:       end
// 120:     end
// 121:   end
// 122: end
