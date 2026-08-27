module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/ruby.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 26.
pub fn ruby_ruby_l26_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
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
