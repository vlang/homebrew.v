module rubocops

import ruby
import os

// Translated from Homebrew/brew `rubocops/shell_command_stub.rb`.
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
