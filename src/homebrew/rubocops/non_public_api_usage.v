module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/non_public_api_usage.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 40.
pub fn ruby_non_public_api_usage_l40_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `internal_methods` at line 51.
pub fn ruby_non_public_api_usage_l51_d2_internal_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('internal_methods', ...args)
}

// Ruby method `private_methods` at line 59.
pub fn ruby_non_public_api_usage_l59_d3_private_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('private_methods', ...args)
}

// Ruby method `load_methods_for_level(level)` at line 67.
pub fn ruby_non_public_api_usage_l67_d4_load_methods_for_level(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('load_methods_for_level', ...args)
}

// Ruby method `check_method_calls(body_node, methods, msg)` at line 84.
pub fn ruby_non_public_api_usage_l84_d5_check_method_calls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_method_calls', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/api_annotation_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # Ensures that formulae in official taps (homebrew-core, homebrew-cask)
// 11:       # only use methods that are part of the public API (`@api public`) and
// 12:       # do not call methods marked as `@api private` or `@api internal`.
// 13:       #
// 14:       # The lists of internal/private methods are derived dynamically from
// 15:       # `@api` annotations in the source files rather than hardcoded, so
// 16:       # they stay in sync automatically.
// 17:       #
// 18:       # ### Example
// 19:       #
// 20:       # ```ruby
// 21:       # # bad - `tap` is @api internal
// 22:       # class Foo < Formula
// 23:       #   def install
// 24:       #     puts tap
// 25:       #   end
// 26:       # end
// 27:       #
// 28:       # # good - `bin` is @api public
// 29:       # class Foo < Formula
// 30:       #   def install
// 31:       #     bin.install "foo"
// 32:       #   end
// 33:       # end
// 34:       # ```
// 35:       class NonPublicApiUsage < FormulaCop
// 36:         INTERNAL_MSG = "Do not use `%<method>s` in official tap formulae; it is an internal API (`@api internal`)."
// 37:         PRIVATE_MSG = "Do not use `%<method>s` in official tap formulae; it is a private API (`@api private`)."
// 38:
// 39:         sig { override.params(formula_nodes: FormulaNodes).void }
// 40:         def audit_formula(formula_nodes)
// 41:           return if ApiAnnotationHelper::OFFICIAL_TAPS.none?(formula_tap)
// 42:           return if (body_node = formula_nodes.body_node).nil?
// 43:
// 44:           check_method_calls(body_node, internal_methods, INTERNAL_MSG)
// 45:           check_method_calls(body_node, private_methods, PRIVATE_MSG)
// 46:         end
// 47:
// 48:         private
// 49:
// 50:         sig { returns(T::Set[String]) }
// 51:         def internal_methods
// 52:           @internal_methods ||= T.let(
// 53:             load_methods_for_level("internal"),
// 54:             T.nilable(T::Set[String]),
// 55:           )
// 56:         end
// 57:
// 58:         sig { returns(T::Set[String]) }
// 59:         def private_methods
// 60:           @private_methods ||= T.let(
// 61:             load_methods_for_level("private"),
// 62:             T.nilable(T::Set[String]),
// 63:           )
// 64:         end
// 65:
// 66:         sig { params(level: String).returns(T::Set[String]) }
// 67:         def load_methods_for_level(level)
// 68:           methods = T.let(Set.new, T::Set[String])
// 69:           ApiAnnotationHelper::API_SOURCE_FILES.each do |source_file|
// 70:             methods.merge(ApiAnnotationHelper.methods_with_api_level(
// 71:                             File.join(ApiAnnotationHelper.homebrew_dir, source_file), level
// 72:                           ))
// 73:           end
// 74:           methods
// 75:         end
// 76:
// 77:         sig {
// 78:           params(
// 79:             body_node: RuboCop::AST::Node,
// 80:             methods:   T::Set[String],
// 81:             msg:       String,
// 82:           ).void
// 83:         }
// 84:         def check_method_calls(body_node, methods, msg)
// 85:           methods.each do |method_name|
// 86:             find_every_method_call_by_name(body_node, method_name.to_sym).each do |node|
// 87:               # Only flag implicit receiver calls (i.e. `tap` not `foo.tap`)
// 88:               # to reduce false positives from local variables or other objects.
// 89:               next if node.receiver && !node.receiver.self_type?
// 90:
// 91:               @offensive_node = node
// 92:               problem format(msg, method: method_name)
// 93:             end
// 94:           end
// 95:         end
// 96:       end
// 97:     end
// 98:   end
// 99: end
