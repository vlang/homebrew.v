module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/no_overrides.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_cask(cask_block)` at line 18.
pub fn ruby_no_overrides_l18_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_cask', ...args)
}

// Ruby method `on_system_stanzas(on_system)` at line 39.
pub fn ruby_no_overrides_l39_d2_on_system_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_system_stanzas', ...args)
}

// Ruby method `inside_livecheck_defined?(node)` at line 91.
pub fn ruby_no_overrides_l91_d3_inside_livecheck_defined(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inside_livecheck_defined?', ...args)
}

// Ruby method `single_stanza_livecheck_defined?(node)` at line 96.
pub fn ruby_no_overrides_l96_d4_single_stanza_livecheck_defined(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_stanza_livecheck_defined?', ...args)
}

// Ruby method `multi_stanza_livecheck_defined?(node)` at line 101.
pub fn ruby_no_overrides_l101_d5_multi_stanza_livecheck_defined(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('multi_stanza_livecheck_defined?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       class NoOverrides < Base
// 8:         include CaskHelp
// 9:
// 10:         # These stanzas can be overridden by `on_*` blocks, so take them into account.
// 11:         # TODO: Update this list when stanzas in `Cask::DSL` start or stop calling `set_unique_stanza`.
// 12:         OVERRIDABLE_METHODS = [
// 13:           :appcast, :arch, :auto_updates, :container,
// 14:           :desc, :homepage, :os, :sha256, :url, :version
// 15:         ].freeze
// 16:
// 17:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 18:         def on_cask(cask_block)
// 19:           message = "Do not use a top-level `%<stanza>s` stanza as the default. " \
// 20:                     "Add it to an `on_{system}` block instead. " \
// 21:                     "Use `:or_older` or `:or_newer` to specify a range of macOS versions."
// 22:           cask_stanzas = cask_block.toplevel_stanzas
// 23:
// 24:           return if (on_blocks = on_system_methods(cask_stanzas)).none?
// 25:
// 26:           stanzas_in_blocks = on_system_stanzas(on_blocks)
// 27:
// 28:           cask_stanzas.each do |stanza|
// 29:             # Skip if the stanza is not allowed to be overridden.
// 30:             next unless OVERRIDABLE_METHODS.include?(stanza.stanza_name)
// 31:             # Skip if the stanza outside of a block is not also in an `on_*` block.
// 32:             next unless stanzas_in_blocks.include?(stanza.stanza_name)
// 33:
// 34:             add_offense(stanza.source_range, message: format(message, stanza: stanza.stanza_name))
// 35:           end
// 36:         end
// 37:
// 38:         sig { params(on_system: T::Array[RuboCop::Cask::AST::Stanza]).returns(T::Set[Symbol]) }
// 39:         def on_system_stanzas(on_system)
// 40:           message = "Do not use a `depends_on macos:` stanza inside an `on_{system}` block. " \
// 41:                     "Add it once to specify the oldest macOS supported by any version in the cask."
// 42:           names = T.let(Set.new, T::Set[Symbol])
// 43:           method_nodes = on_system.map(&:method_node)
// 44:
// 45:           # Check if multiple `on_{system}` blocks have different `depends_on macos:` versions.
// 46:           # If so, this indicates architecture-specific requirements and is allowed.
// 47:           macos_versions = T.let([], T::Array[String])
// 48:           method_nodes.select(&:block_type?).each do |node|
// 49:             node.child_nodes.each do |child|
// 50:               child.each_node(:send) do |send_node|
// 51:                 next if send_node.method_name != :depends_on
// 52:
// 53:                 macos_pair = send_node.arguments.first.pairs.find { |a| a.key.value == :macos }
// 54:                 macos_versions << macos_pair.value.source if macos_pair
// 55:               end
// 56:             end
// 57:           end
// 58:           # Allow if there are multiple different macOS versions specified
// 59:           allow_macos_depends_in_blocks = macos_versions.size > 1 && macos_versions.uniq.size > 1
// 60:
// 61:           method_nodes.select(&:block_type?).each do |node|
// 62:             node.child_nodes.each do |child|
// 63:               child.each_node(:send) do |send_node|
// 64:                 # Skip (nested) `livecheck` block as its `url` is different
// 65:                 # from a download `url`.
// 66:                 next if send_node.method_name == :livecheck || inside_livecheck_defined?(send_node)
// 67:                 # Skip string interpolations.
// 68:                 if send_node.ancestors.drop_while { |a| !a.begin_type? }.any? { |a| a.dstr_type? || a.regexp_type? }
// 69:                   next
// 70:                 end
// 71:                 next if RuboCop::Cask::Constants::ON_SYSTEM_METHODS.include?(send_node.method_name)
// 72:
// 73:                 if send_node.method_name == :depends_on &&
// 74:                    send_node.arguments.first.pairs.any? { |a| a.key.value == :macos } &&
// 75:                    OnSystemConditionalsHelper::ON_SYSTEM_OPTIONS.map do |m|
// 76:                      :"on_#{m}"
// 77:                    end.include?(T.cast(node, RuboCop::AST::BlockNode).method_name) &&
// 78:                    T.cast(node, RuboCop::AST::BlockNode).method_name != :on_macos && !allow_macos_depends_in_blocks
// 79:                   # Allow `depends_on macos:` in multiple `on_{system}` blocks for architecture-specific requirements
// 80:                   add_offense(send_node.source_range, message:)
// 81:                 end
// 82:
// 83:                 names.add(send_node.method_name)
// 84:               end
// 85:             end
// 86:           end
// 87:           names
// 88:         end
// 89:
// 90:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 91:         def inside_livecheck_defined?(node)
// 92:           single_stanza_livecheck_defined?(node) || multi_stanza_livecheck_defined?(node)
// 93:         end
// 94:
// 95:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 96:         def single_stanza_livecheck_defined?(node)
// 97:           node.parent.block_type? && node.parent.method_name == :livecheck
// 98:         end
// 99:
// 100:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 101:         def multi_stanza_livecheck_defined?(node)
// 102:           grandparent_node = node.parent.parent
// 103:           node.parent.begin_type? && grandparent_node.block_type? && grandparent_node.method_name == :livecheck
// 104:         end
// 105:       end
// 106:     end
// 107:   end
// 108: end
