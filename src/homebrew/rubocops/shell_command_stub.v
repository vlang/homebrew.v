module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/shell_command_stub.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 12.
pub fn ruby_shell_command_stub_l12_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
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
