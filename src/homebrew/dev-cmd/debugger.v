module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/debugger.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 21.
pub fn ruby_debugger_l21_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module DevCmd
// 6:     class Debugger < AbstractCommand
// 7:       cmd_args do
// 8:         description <<~EOS
// 9:           Run the specified Homebrew command in debug mode.
// 10:
// 11:           To pass flags to the command, use `--` to separate them from the `brew` flags.
// 12:           For example: `brew debugger -- list --formula`.
// 13:         EOS
// 14:         switch "-O", "--open",
// 15:                description: "Start remote debugging over a Unix socket."
// 16:
// 17:         named_args :command, min: 1
// 18:       end
// 19:
// 20:       sig { override.void }
// 21:       def run
// 22:         raise UsageError, "Debugger is only supported with portable Ruby!" unless HOMEBREW_USING_PORTABLE_RUBY
// 23:
// 24:         unless Commands.valid_ruby_cmd?(T.must(args.named.first))
// 25:           raise UsageError, "`#{args.named.first}` is not a valid Ruby command!"
// 26:         end
// 27:
// 28:         brew_rb = (HOMEBREW_LIBRARY_PATH/"brew.rb").resolved_path
// 29:         debugger_method = if args.open?
// 30:           "open"
// 31:         else
// 32:           "start"
// 33:         end
// 34:
// 35:         env = {}
// 36:         env[:RUBY_DEBUG_FORK_MODE] = "parent"
// 37:         env[:RUBY_DEBUG_NONSTOP] = "1" unless ENV["HOMEBREW_RDBG"]
// 38:
// 39:         with_env(**env) do
// 40:           system(*HOMEBREW_RUBY_EXEC_ARGS,
// 41:                  "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 42:                  "-rdebug/#{debugger_method}",
// 43:                  brew_rb, *args.named)
// 44:         end
// 45:       end
// 46:     end
// 47:   end
// 48: end
