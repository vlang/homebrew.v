module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/disable_comment.rb`.
// The original source is retained below until every stub has a typed V body.
pub const disable_comment_message = 'Add a clarifying comment to the RuboCop disable comment'

pub struct DisableCommentSourceComment {
pub:
	text      string
	line      int
	begin_pos int
	end_pos   int
}

pub struct DisableCommentOffense {
pub:
	comment   DisableCommentSourceComment
	message   string
	begin_pos int
	end_pos   int
}

fn disable_comment_start(line string) ?int {
	mut quote := u8(0)
	mut escaped := false
	for index, character in line.bytes() {
		if escaped {
			escaped = false
			continue
		}
		if quote != 0 {
			if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
			continue
		}
		if character == `#` {
			return index
		}
	}
	return none
}

pub fn disable_comment_text(text string) bool {
	return text.starts_with('# rubocop:disable')
}

pub fn disable_comment_clarifying_line(line string) bool {
	trimmed := line.trim_space()
	return trimmed.starts_with('#') && trimmed[1..] != ''
}

pub fn disable_comment_source_comments(source string) []DisableCommentSourceComment {
	mut comments := []DisableCommentSourceComment{}
	mut offset := 0
	for line_index, line in source.split('\n') {
		comment_start := disable_comment_start(line) or {
			offset += line.len + 1
			continue
		}
		comments << DisableCommentSourceComment{
			text: source[offset + comment_start..offset + line.len]
			line: line_index + 1
			begin_pos: offset + comment_start
			end_pos: offset + line.len
		}
		offset += line.len + 1
	}
	return comments
}

pub fn audit_disable_comments(source string) []DisableCommentOffense {
	lines := source.split('\n')
	mut offenses := []DisableCommentOffense{}
	for comment in disable_comment_source_comments(source) {
		if !disable_comment_text(comment.text) {
			continue
		}
		preceding_line := if comment.line > 1 { lines[comment.line - 2] } else { '' }
		if disable_comment_clarifying_line(preceding_line) {
			continue
		}
		offenses << DisableCommentOffense{
			comment: comment
			message: disable_comment_message
			begin_pos: comment.begin_pos
			end_pos: comment.end_pos
		}
	}
	return offenses
}

fn disable_comment_offense_value(offense DisableCommentOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'text':      offense.comment.text
		'line':      offense.comment.line.str()
		'begin_pos': offense.begin_pos.str()
		'end_pos':   offense.end_pos.str()
		'message':   offense.message
	})
}

// Ruby method `on_new_investigation` at line 11.
pub fn ruby_disable_comment_l11_d1_on_new_investigation(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_disable_comments(source).map(disable_comment_offense_value(it)))
}

// Ruby method `disable_comment?(comment)` at line 25.
pub fn ruby_disable_comment_l25_d2_disable_comment(args ...ruby.Value) ruby.Value {
	text := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(disable_comment_text(text))
}

// Ruby method `comment?(line)` at line 30.
pub fn ruby_disable_comment_l30_d3_comment(args ...ruby.Value) ruby.Value {
	line := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(disable_comment_clarifying_line(line))
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
