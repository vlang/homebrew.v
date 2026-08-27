module compilers

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/rspec_dynamic_matchers.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gather_constants` at line 12.
pub fn ruby_rspec_dynamic_matchers_l12_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gather_constants', ...args)
}

// Ruby method `decorate` at line 17.
pub fn ruby_rspec_dynamic_matchers_l17_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate', ...args)
}

// Ruby method `missing_matchers` at line 34.
pub fn ruby_rspec_dynamic_matchers_l34_d3_missing_matchers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('missing_matchers', ...args)
}

// Ruby method `used_matchers` at line 39.
pub fn ruby_rspec_dynamic_matchers_l39_d4_used_matchers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('used_matchers', ...args)
}

// Ruby method `declared_dynamic_matchers` at line 52.
pub fn ruby_rspec_dynamic_matchers_l52_d5_declared_dynamic_matchers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('declared_dynamic_matchers', ...args)
}

// Ruby method `matcher_declaration_files` at line 76.
pub fn ruby_rspec_dynamic_matchers_l76_d6_matcher_declaration_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matcher_declaration_files', ...args)
}

// Ruby method `known_rspec_matchers` at line 82.
pub fn ruby_rspec_dynamic_matchers_l82_d7_known_rspec_matchers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('known_rspec_matchers', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rspec/expectations"
// 5:
// 6: module Tapioca
// 7:   module Compilers
// 8:     class RspecDynamicMatchers < Tapioca::Dsl::Compiler
// 9:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 10:
// 11:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 12:       def self.gather_constants
// 13:         [::RSpec::Matchers]
// 14:       end
// 15:
// 16:       sig { override.void }
// 17:       def decorate
// 18:         root.create_path(constant) do |mod|
// 19:           missing_matchers.each do |name|
// 20:             mod.create_method(
// 21:               name,
// 22:               parameters: [
// 23:                 create_rest_param("args", type: "T.untyped"),
// 24:                 create_block_param("block", type: "T.untyped"),
// 25:               ],
// 26:             )
// 27:           end
// 28:         end
// 29:       end
// 30:
// 31:       private
// 32:
// 33:       sig { returns(T::Array[String]) }
// 34:       def missing_matchers
// 35:         (used_matchers + declared_dynamic_matchers - known_rspec_matchers).to_a.sort
// 36:       end
// 37:
// 38:       sig { returns(T::Set[String]) }
// 39:       def used_matchers
// 40:         matchers = T.let(Set.new, T::Set[String])
// 41:
// 42:         Dir[File.join(__dir__, "../../../test/**/*_spec.rb")].each do |file|
// 43:           File.read(file).scan(/\b(?:be|have)_[a-z0-9_]+\b/) do |name|
// 44:             matchers.add(name)
// 45:           end
// 46:         end
// 47:
// 48:         matchers
// 49:       end
// 50:
// 51:       sig { returns(T::Set[String]) }
// 52:       def declared_dynamic_matchers
// 53:         matchers = T.let(Set.new, T::Set[String])
// 54:
// 55:         matcher_declaration_files.each do |file|
// 56:           content = File.read(file)
// 57:
// 58:           content.scan(/\b(?:RSpec::Matchers\.)?define\s+:([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 59:             matchers.add(captures.first)
// 60:           end
// 61:           content.scan(/\b(?:RSpec::Matchers\.)?define_negated_matcher\s+:([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 62:             matchers.add(captures.first)
// 63:           end
// 64:           content.scan(/\b(?:RSpec::Matchers\.)?alias_matcher\s+:([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 65:             matchers.add(captures.first)
// 66:           end
// 67:           content.scan(/\bmatcher\s+:([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 68:             matchers.add(captures.first)
// 69:           end
// 70:         end
// 71:
// 72:         matchers
// 73:       end
// 74:
// 75:       sig { returns(T::Array[String]) }
// 76:       def matcher_declaration_files
// 77:         files = Dir[File.join(__dir__, "../../../test/**/*.rb")]
// 78:         files.select { |file| File.file?(file) }
// 79:       end
// 80:
// 81:       sig { returns(T::Set[String]) }
// 82:       def known_rspec_matchers
// 83:         known = T.let(Set.new, T::Set[String])
// 84:
// 85:         Dir[File.join(__dir__, "../../rbi/gems/rspec-expectations@*.rbi")].each do |file|
// 86:           File.read(file).scan(/^\s*def\s+([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 87:             known.add(captures.first)
// 88:           end
// 89:         end
// 90:
// 91:         known
// 92:       end
// 93:     end
// 94:   end
// 95: end
