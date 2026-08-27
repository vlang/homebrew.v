module cmd

// Translated from Homebrew/brew `cmd/exec.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "shell_command"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Exec < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       cmd_args do
// 13:         usage_banner <<~EOS
// 14:           `exec`, `x` [`--formulae=`<formulae>] [`--sandbox=`<path>] [`--deny-network`] [`--`] <command> [<args> ...]
// 15:
// 16:           Run <command> in an environment populated by Homebrew formulae.
// 17:
// 18:           If `--formulae` is passed, Homebrew installs those comma-separated
// 19:           formulae if needed, prepends their executable directories and those of
// 20:           their dependencies to `PATH` and runs <command>. This allows <command>
// 21:           to be a script path such as `./script.sh`.
// 22:
// 23:           If `--formulae` is omitted, Homebrew finds a formula that provides
// 24:           <command>, installs it if needed and runs that executable.
// 25:
// 26:           Example: `brew exec --formulae=jq,yq -- ./script.sh`
// 27:
// 28:           Scripts can also use a shebang on systems with `env -S`:
// 29:           `#!/usr/bin/env -S brew exec --formulae=jq,yq --`
// 30:         EOS
// 31:
// 32:         comma_array "--formulae",
// 33:                     description: "Comma-separated formulae to install and add to `PATH` before running " \
// 34:                                  "<command>."
// 35:         flag "--sandbox=",
// 36:              description: "Run <command> in Homebrew's sandbox, allowing writes to <path> and Homebrew's " \
// 37:                           "temporary and cache directories."
// 38:         switch "--deny-network",
// 39:                description: "Deny network access from inside the sandbox.",
// 40:                depends_on:  "--sandbox="
// 41:
// 42:         named_args min: 1
// 43:       end
// 44:     end
// 45:   end
// 46: end
