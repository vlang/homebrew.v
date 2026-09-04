module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/disable_comment.rb`.
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
