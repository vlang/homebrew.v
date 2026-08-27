module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/abstract_flight_block.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.dsl_key` at line 11.
pub fn ruby_abstract_flight_block_l11_d1_self_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dsl_key', ...args)
}

// Ruby method `self.uninstall_dsl_key` at line 16.
pub fn ruby_abstract_flight_block_l16_d2_self_uninstall_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.uninstall_dsl_key', ...args)
}

// Ruby attr_reader `attr_reader :directives` at line 21.
pub fn ruby_abstract_flight_block_l21_d3_directives(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('directives', ...args)
}

// Ruby method `initialize(cask, **directives)` at line 24.
pub fn ruby_abstract_flight_block_l24_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `install_phase(**_options)` at line 30.
pub fn ruby_abstract_flight_block_l30_d5_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `uninstall_phase(**_options)` at line 35.
pub fn ruby_abstract_flight_block_l35_d6_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `summarize` at line 40.
pub fn ruby_abstract_flight_block_l40_d7_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize', ...args)
}

// Ruby method `self.class_for_dsl_key(dsl_key)` at line 45.
pub fn ruby_abstract_flight_block_l45_d8_self_class_for_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.class_for_dsl_key', ...args)
}

// Ruby method `abstract_phase(dsl_key)` at line 56.
pub fn ruby_abstract_flight_block_l56_d9_abstract_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('abstract_phase', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_artifact"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Abstract superclass for block artifacts.
// 9:     class AbstractFlightBlock < AbstractArtifact
// 10:       sig { override.returns(Symbol) }
// 11:       def self.dsl_key
// 12:         super.to_s.sub(/_block$/, "").to_sym
// 13:       end
// 14:
// 15:       sig { returns(Symbol) }
// 16:       def self.uninstall_dsl_key
// 17:         :"uninstall_#{dsl_key}"
// 18:       end
// 19:
// 20:       sig { returns(T::Hash[Symbol, DirectivesType]) }
// 21:       attr_reader :directives
// 22:
// 23:       sig { params(cask: Cask, directives: DirectivesType).void }
// 24:       def initialize(cask, **directives)
// 25:         super(cask)
// 26:         @directives = directives
// 27:       end
// 28:
// 29:       sig { params(_options: T.anything).void }
// 30:       def install_phase(**_options)
// 31:         abstract_phase(self.class.dsl_key)
// 32:       end
// 33:
// 34:       sig { params(_options: T.anything).void }
// 35:       def uninstall_phase(**_options)
// 36:         abstract_phase(self.class.uninstall_dsl_key)
// 37:       end
// 38:
// 39:       sig { override.returns(String) }
// 40:       def summarize
// 41:         directives.keys.join(", ")
// 42:       end
// 43:
// 44:       sig { params(dsl_key: Symbol).returns(T::Class[::Cask::DSL::Base]) }
// 45:       def self.class_for_dsl_key(dsl_key)
// 46:         namespace = name.to_s.sub(/::.*::.*$/, "")
// 47:         # The DSL class name is derived dynamically from the flight block's key.
// 48:         # rubocop:disable Sorbet/ConstantsFromStrings
// 49:         const_get("#{namespace}::DSL::#{dsl_key.to_s.split("_").map(&:capitalize).join}")
// 50:         # rubocop:enable Sorbet/ConstantsFromStrings
// 51:       end
// 52:
// 53:       private
// 54:
// 55:       sig { params(dsl_key: Symbol).void }
// 56:       def abstract_phase(dsl_key)
// 57:         return if (block = directives[dsl_key]).nil?
// 58:
// 59:         self.class.class_for_dsl_key(dsl_key).new(cask).instance_eval(&T.cast(block, T.proc.returns(T.anything)))
// 60:       end
// 61:     end
// 62:   end
// 63: end
