module cmd

// Translated from Homebrew/brew `cmd/shellenv.rb`.
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
// 9:     class Shellenv < AbstractCommand
// 10:       include ShellCommand
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Valid shells: bash|csh|fish|pwsh|sh|tcsh|zsh
// 15:
// 16:           Print export statements. When run in a shell, this installation of Homebrew will be added to your
// 17:           `$PATH`, `$MANPATH`, and `$INFOPATH`.
// 18:
// 19:           The variables `$HOMEBREW_PREFIX`, `$HOMEBREW_CELLAR` and `$HOMEBREW_REPOSITORY` are also exported to avoid
// 20:           querying them multiple times.
// 21:           To help guarantee idempotence, this command produces no output when Homebrew's `bin` and `sbin` directories
// 22:           are first and second respectively in your `$PATH`. Consider adding evaluation of this command's output to
// 23:           your dotfiles (e.g. `~/.bash_profile` or `~/.zprofile` on macOS and `~/.bashrc` or `~/.zshrc` on Linux)
// 24:           with e.g.:
// 25:             `eval "$(brew shellenv zsh)"` or `eval "$(brew shellenv bash)"`
// 26:
// 27:           The shell should be specified explicitly with a supported shell name parameter but will be detected
// 28:           automatically if not provided (but this may not be correct). Unknown shells will output POSIX exports.
// 29:         EOS
// 30:
// 31:         named_args :shell
// 32:       end
// 33:     end
// 34:   end
// 35: end
