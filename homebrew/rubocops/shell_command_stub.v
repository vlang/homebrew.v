module rubocops

import ruby
import os

// Translated from Homebrew/brew `rubocops/shell_command_stub.rb`.
// The original source is retained below until every stub has a typed V body.
pub const shell_command_stub_message = 'Shell command stubs must have a `.sh` counterpart.'

pub struct ShellCommandStubOffense {
pub:
	begin_pos int
	end_pos   int
	message   string
	sh_path   string
}

fn shell_command_counterpart(file_path string) string {
	directory := os.dir(file_path)
	base := os.file_name(file_path)
	stem := if base.ends_with('.rb') { base[..base.len - 3] } else { base }
	return os.join_path(directory, '${stem}.sh')
}

pub fn audit_shell_command_stub_with_exists(source string, file_path string,
	counterpart_exists bool) ?ShellCommandStubOffense {
	needle := 'include ShellCommand'
	begin_pos := source.index(needle) or { return none }
	if counterpart_exists {
		return none
	}
	return ShellCommandStubOffense{
		begin_pos: begin_pos
		end_pos: begin_pos + needle.len
		message: shell_command_stub_message
		sh_path: shell_command_counterpart(file_path)
	}
}

pub fn audit_shell_command_stub(source string, file_path string) ?ShellCommandStubOffense {
	sh_path := shell_command_counterpart(file_path)
	return audit_shell_command_stub_with_exists(source, file_path, os.exists(sh_path))
}

// Ruby method `on_send(node)` at line 12.
pub fn ruby_shell_command_stub_l12_d1_on_send(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	file_path := if args.len > 1 { args[1].as_string() } else { '/tmp/command.rb' }
	offense := audit_shell_command_stub(source, file_path) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos': offense.begin_pos.str()
		'end_pos':   offense.end_pos.str()
		'message':   offense.message
		'sh_path':   offense.sh_path
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       class ShellCommandStub < Base
// 8:         MSG = "Shell command stubs must have a `.sh` counterpart."
// 9:         RESTRICT_ON_SEND = [:include].freeze
// 10:
// 11:         sig { params(node: AST::SendNode).void }
// 12:         def on_send(node)
// 13:           return if node.first_argument&.const_name != "ShellCommand"
// 14:
// 15:           stub_path = Pathname.new(processed_source.file_path)
// 16:           sh_cmd_path = Pathname.new("#{stub_path.dirname}/#{stub_path.basename(".rb")}.sh")
// 17:           return if sh_cmd_path.exist?
// 18:
// 19:           add_offense(node)
// 20:         end
// 21:       end
// 22:     end
// 23:   end
// 24: end
