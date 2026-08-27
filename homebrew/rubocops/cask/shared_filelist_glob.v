module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/shared_filelist_glob.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 11.
pub fn ruby_shared_filelist_glob_l11_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       class SharedFilelistGlob < Base
// 8:         extend AutoCorrector
// 9:
// 10:         sig { params(node: RuboCop::AST::SendNode).void }
// 11:         def on_send(node)
// 12:           return if node.method_name != :zap
// 13:
// 14:           node.each_descendant(:pair).each do |pair|
// 15:             symbols = pair.children.select(&:sym_type?).map(&:value)
// 16:             next unless symbols.include?(:trash)
// 17:
// 18:             pair.each_descendant(:array).each do |array|
// 19:               regex = /\.sfl\d"$/
// 20:               message = "Use a glob (*) instead of a specific version (ie. sfl2) for trashing Shared File List paths"
// 21:
// 22:               array.children.each do |item|
// 23:                 next unless item.source.match?(regex)
// 24:
// 25:                 corrected_item = item.source.sub(/sfl\d"$/, "sfl*\"")
// 26:
// 27:                 add_offense(item,
// 28:                             message:) do |corrector|
// 29:                   corrector.replace(item, corrected_item)
// 30:                 end
// 31:               end
// 32:             end
// 33:           end
// 34:         end
// 35:       end
// 36:     end
// 37:   end
// 38: end
