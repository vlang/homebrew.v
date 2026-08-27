module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/move_to_extend_os.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby def_node_matcher `def_node_matcher :os_mac?, <<~PATTERN` at line 12.
pub fn ruby_move_to_extend_os_l12_d1_os_mac(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_mac?', ...args)
}

// Ruby def_node_matcher `def_node_matcher :os_linux?, <<~PATTERN` at line 16.
pub fn ruby_move_to_extend_os_l16_d2_os_linux(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_linux?', ...args)
}

// Ruby method `extend_offense_message(extend_os, os_method)` at line 21.
pub fn ruby_move_to_extend_os_l21_d3_extend_offense_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extend_offense_message', ...args)
}

// Ruby method `on_send(node)` at line 27.
pub fn ruby_move_to_extend_os_l27_d4_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # This cop ensures that platform specific code ends up in `extend/os`, and
// 8:       # that `extend/os` doesn't contain incorrect or redundant OS checks.
// 9:       class MoveToExtendOS < Base
// 10:         NON_EXTEND_OS_MSG = "Move `OS.linux?` and `OS.mac?` calls to `extend/os`."
// 11:
// 12:         def_node_matcher :os_mac?, <<~PATTERN
// 13:           (send (const nil? :OS) :mac?)
// 14:         PATTERN
// 15:
// 16:         def_node_matcher :os_linux?, <<~PATTERN
// 17:           (send (const nil? :OS) :linux?)
// 18:         PATTERN
// 19:
// 20:         sig { params(extend_os: String, os_method: String).returns(String) }
// 21:         def extend_offense_message(extend_os, os_method)
// 22:           "Don't use `OS.#{os_method}?` in `extend/os/#{extend_os}`, it is " \
// 23:             "always `#{(extend_os == os_method) ? "true" : "false"}`."
// 24:         end
// 25:
// 26:         sig { params(node: RuboCop::AST::Node).void }
// 27:         def on_send(node)
// 28:           file_path = processed_source.file_path
// 29:           # The OS loader, requirements and tests need direct host checks; this
// 30:           # cop is for portable production code that should live under `extend/os`.
// 31:           return if file_path.match?(%r{(?:\A|/)Library/Homebrew/(?:requirements|test)/}) ||
// 32:                     file_path.match?(%r{(?:\A|/)Library/Homebrew/os\.rb\z})
// 33:
// 34:           if file_path.include?("extend/os/mac/")
// 35:             add_offense(node, message: extend_offense_message("mac", "mac")) if os_mac?(node)
// 36:             add_offense(node, message: extend_offense_message("mac", "linux")) if os_linux?(node)
// 37:           elsif file_path.include?("extend/os/linux/")
// 38:             add_offense(node, message: extend_offense_message("linux", "mac")) if os_mac?(node)
// 39:             add_offense(node, message: extend_offense_message("linux", "linux")) if os_linux?(node)
// 40:           elsif !file_path.include?("extend/os/") && (os_mac?(node) || os_linux?(node))
// 41:             add_offense(node, message: NON_EXTEND_OS_MSG)
// 42:           end
// 43:         end
// 44:       end
// 45:     end
// 46:   end
// 47: end
