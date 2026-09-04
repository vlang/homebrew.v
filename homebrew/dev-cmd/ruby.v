module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/ruby.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct RubyCommandOptions {
pub:
	ruby_exec_args []string
	load_path      []string
	require_name   ?string
	code           ?string
	named          []string
}

pub fn build_ruby_command_exec_args(options RubyCommandOptions) []string {
	mut command := options.ruby_exec_args.clone()
	command << ['-I', options.load_path.join(os.path_delimiter), '-rglobal', '-rbrew_irb_helpers']
	if require_name := options.require_name {
		command << '-r${require_name}'
	}
	if code := options.code {
		command << '-e ${code}'
	}
	command << options.named
	return command
}

// Ruby method `run` at line 26.
pub fn ruby_ruby_l26_d1_run(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'Ruby exec args and load path are required')
	}
	ruby_exec_args := args[0].as_string_array() or {
		return ruby.object_value('TypeError', err.msg())
	}
	load_path := args[1].as_string_array() or {
		return ruby.object_value('TypeError', err.msg())
	}
	require_name := if args.len > 2 && args[2].type_name !in ['Nil', 'NilClass', ''] {
		?string(args[2].as_string())
	} else {
		?string(none)
	}
	code := if args.len > 3 && args[3].type_name !in ['Nil', 'NilClass', ''] {
		?string(args[3].as_string())
	} else {
		?string(none)
	}
	named := if args.len > 4 { args[4].as_string_array() or { []string{} } } else { []string{} }
	return ruby.string_array_value(build_ruby_command_exec_args(RubyCommandOptions{
		ruby_exec_args: ruby_exec_args
		load_path: load_path
		require_name: require_name
		code: code
		named: named
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class Ruby < AbstractCommand
// 9:       cmd_args do
// 10:         usage_banner "`ruby` [<options>] (`-e` <text>|<file>)"
// 11:         description <<~EOS
// 12:           Run a Ruby instance with Homebrew's libraries loaded. For example,
// 13:           `brew ruby -e "puts :gcc.f.deps"` or `brew ruby script.rb`.
// 14:
// 15:           Run e.g. `brew ruby -- --version` to pass arbitrary arguments to `ruby`.
// 16:         EOS
// 17:         flag "-r=",
// 18:              description: "Load a library using `require`."
// 19:         flag "-e=",
// 20:              description: "Execute the given text string as a script."
// 21:
// 22:         named_args :file
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         ruby_sys_args = []
// 28:         ruby_sys_args << "-r#{args.r}" if args.r
// 29:         ruby_sys_args << "-e #{args.e}" if args.e
// 30:         ruby_sys_args += args.named
// 31:
// 32:         exec(*HOMEBREW_RUBY_EXEC_ARGS,
// 33:              "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 34:              "-rglobal", "-rbrew_irb_helpers",
// 35:              *ruby_sys_args)
// 36:       end
// 37:     end
// 38:   end
// 39: end
