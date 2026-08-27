module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/install_bundler_gems.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 13.
pub fn ruby_install_bundler_gems_l13_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Enforces the use of `Homebrew.install_bundler_gems!` in dev-cmd.
// 8:       class InstallBundlerGems < Base
// 9:         MSG = "Only use `Homebrew.install_bundler_gems!` in dev-cmd."
// 10:         RESTRICT_ON_SEND = [:install_bundler_gems!].freeze
// 11:
// 12:         sig { params(node: RuboCop::AST::Node).void }
// 13:         def on_send(node)
// 14:           file_path = processed_source.file_path
// 15:           return if file_path.match?(%r{/(dev-cmd/.+|standalone/init|startup/bootsnap)\.rb\z})
// 16:
// 17:           add_offense(node)
// 18:         end
// 19:       end
// 20:     end
// 21:   end
// 22: end
