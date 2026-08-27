module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/sandbox-exec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 27.
pub fn ruby_sandbox_exec_l27_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "sandbox"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class SandboxExec < AbstractCommand
// 10:       cmd_args do
// 11:         usage_banner <<~EOS
// 12:           `sandbox-exec` [`--deny-network`] <writable-path> [`--`] <command> [<args> ...]
// 13:
// 14:           Run <command> in Homebrew's sandbox, allowing writes to <writable-path> and
// 15:           Homebrew's temporary and cache directories.
// 16:
// 17:           Example: `brew sandbox-exec . -- make test`
// 18:         EOS
// 19:
// 20:         switch "--deny-network",
// 21:                description: "Deny network access from inside the sandbox."
// 22:
// 23:         named_args min: 2
// 24:       end
// 25:
// 26:       sig { override.void }
// 27:       def run
// 28:         writable_path = args.named.first
// 29:         raise UsageError, "`sandbox-exec` requires a writable path." unless writable_path
// 30:
// 31:         Sandbox.run_command(
// 32:           *args.named.drop(1),
// 33:           writable_path:,
// 34:           deny_network:  args.deny_network?,
// 35:         )
// 36:       end
// 37:     end
// 38:   end
// 39: end
