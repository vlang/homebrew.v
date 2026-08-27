module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/no_fileutils_rmrf.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :any_receiver_rm_r_f?, <<~PATTERN` at line 14.
pub fn ruby_no_fileutils_rmrf_l14_d1_any_receiver_rm_r_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('any_receiver_rm_r_f?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :no_receiver_rm_r_f?, <<~PATTERN` at line 21.
pub fn ruby_no_fileutils_rmrf_l21_d2_no_receiver_rm_r_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_receiver_rm_r_f?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :no_receiver_rmtree?, <<~PATTERN` at line 25.
pub fn ruby_no_fileutils_rmrf_l25_d3_no_receiver_rmtree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_receiver_rmtree?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :any_receiver_rmtree?, <<~PATTERN` at line 29.
pub fn ruby_no_fileutils_rmrf_l29_d4_any_receiver_rmtree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('any_receiver_rmtree?', ...args)
}

// Ruby method `on_send(node)` at line 34.
pub fn ruby_no_fileutils_rmrf_l34_d5_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `neither_rm_rf_nor_rmtree?(node)` at line 56.
pub fn ruby_no_fileutils_rmrf_l56_d6_neither_rm_rf_nor_rmtree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('neither_rm_rf_nor_rmtree?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # This cop checks for the use of `FileUtils.rm_f`, `FileUtils.rm_rf`, or `{FileUtils,instance}.rmtree`
// 8:       # and recommends the safer versions.
// 9:       class NoFileutilsRmrf < Base
// 10:         extend AutoCorrector
// 11:
// 12:         MSG = "Use `rm` or `rm_r` instead of `rm_rf`, `rm_f`, or `rmtree`."
// 13:
// 14:         def_node_matcher :any_receiver_rm_r_f?, <<~PATTERN
// 15:           (send
// 16:             {(const {nil? cbase} :FileUtils) (self)}
// 17:             {:rm_rf :rm_f}
// 18:             ...)
// 19:         PATTERN
// 20:
// 21:         def_node_matcher :no_receiver_rm_r_f?, <<~PATTERN
// 22:           (send nil? {:rm_rf :rm_f} ...)
// 23:         PATTERN
// 24:
// 25:         def_node_matcher :no_receiver_rmtree?, <<~PATTERN
// 26:           (send nil? :rmtree ...)
// 27:         PATTERN
// 28:
// 29:         def_node_matcher :any_receiver_rmtree?, <<~PATTERN
// 30:           (send !nil? :rmtree ...)
// 31:         PATTERN
// 32:
// 33:         sig { params(node: RuboCop::AST::SendNode).void }
// 34:         def on_send(node)
// 35:           return if neither_rm_rf_nor_rmtree?(node)
// 36:
// 37:           add_offense(node) do |corrector|
// 38:             class_name = "FileUtils." if any_receiver_rm_r_f?(node) || any_receiver_rmtree?(node)
// 39:             new_method = if node.method?(:rm_rf) || node.method?(:rmtree)
// 40:               "rm_r"
// 41:             else
// 42:               "rm"
// 43:             end
// 44:
// 45:             args = if any_receiver_rmtree?(node)
// 46:               node.receiver&.source || node.arguments.first&.source
// 47:             else
// 48:               node.arguments.first.source
// 49:             end
// 50:             args = "(#{args})" unless args.start_with?("(")
// 51:             corrector.replace(node.loc.expression, "#{class_name}#{new_method}#{args}")
// 52:           end
// 53:         end
// 54:
// 55:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 56:         def neither_rm_rf_nor_rmtree?(node)
// 57:           !any_receiver_rm_r_f?(node) && !no_receiver_rm_r_f?(node) &&
// 58:             !any_receiver_rmtree?(node) && !no_receiver_rmtree?(node)
// 59:         end
// 60:       end
// 61:     end
// 62:   end
// 63: end
