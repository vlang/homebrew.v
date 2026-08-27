module cask

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/cask/config.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gather_constants = [Cask::Config]` at line 18.
pub fn ruby_config_l18_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gather_constants', ...args)
}

// Ruby method `decorate` at line 21.
pub fn ruby_config_l21_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../../global"
// 5: require "cask/config"
// 6:
// 7: module Tapioca
// 8:   module Compilers
// 9:     class CaskConfig < Tapioca::Dsl::Compiler
// 10:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 11:
// 12:       # Dirs defined in `OS::Linux::Cask::Config::ClassMethods::DEFAULT_DIRS`
// 13:       # that aren't visible to `Cask::Config.defaults` when this compiler is
// 14:       # run on macOS, but still need accessor methods generated in the RBI.
// 15:       LINUX_ONLY_DIRS = [:appimagedir].freeze
// 16:
// 17:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 18:       def self.gather_constants = [Cask::Config]
// 19:
// 20:       sig { override.void }
// 21:       def decorate
// 22:         keys = Cask::Config.defaults.keys | LINUX_ONLY_DIRS
// 23:
// 24:         root.create_module("Cask") do |mod|
// 25:           mod.create_class("Config") do |klass|
// 26:             keys.each do |key|
// 27:               return_type = if key == :languages
// 28:                 # :languages is a `LazyObject`, so it lazily evaluates to an
// 29:                 # array of strings when a method is called on it.
// 30:                 "T::Array[String]"
// 31:               elsif key.end_with?("?")
// 32:                 "T::Boolean"
// 33:               else
// 34:                 "String"
// 35:               end
// 36:
// 37:               klass.create_method(key.to_s, return_type:, class_method: false)
// 38:             end
// 39:           end
// 40:         end
// 41:       end
// 42:     end
// 43:   end
// 44: end
