module tapioca

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/utils.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.named_object_for(klass)` at line 8.
pub fn ruby_utils_l8_d1_self_named_object_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.named_object_for', ...args)
}

// Ruby method `self.methods_from_file(mod, file_name, class_methods: false)` at line 24.
pub fn ruby_utils_l24_d2_self_methods_from_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.methods_from_file', ...args)
}

// Ruby method `self.named_objects_with_module(mod)` at line 34.
pub fn ruby_utils_l34_d3_self_named_objects_with_module(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.named_objects_with_module', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Tapioca
// 6:     module Utils
// 7:       sig { params(klass: T::Class[T.anything]).returns(T::Module[T.anything]) }
// 8:       def self.named_object_for(klass)
// 9:         return klass if klass.name
// 10:
// 11:         attached_object = klass.attached_object
// 12:         case attached_object
// 13:         when Module then attached_object
// 14:         else raise "Unsupported attached object for: #{klass}"
// 15:         end
// 16:       end
// 17:
// 18:       # @param class_methods [Boolean] whether to get class methods or instance methods
// 19:       # @return the `module` methods that are defined in the given file
// 20:       sig {
// 21:         params(mod: T::Module[T.anything], file_name: String,
// 22:                class_methods: T::Boolean).returns(T::Array[T.any(Method, UnboundMethod)])
// 23:       }
// 24:       def self.methods_from_file(mod, file_name, class_methods: false)
// 25:         methods = if class_methods
// 26:           mod.methods(false).map { mod.method(it) }
// 27:         else
// 28:           mod.instance_methods(false).map { mod.instance_method(it) }
// 29:         end
// 30:         methods.select { it.source_location&.first&.end_with?(file_name) }
// 31:       end
// 32:
// 33:       sig { params(mod: T::Module[T.anything]).returns(T::Array[T::Module[T.anything]]) }
// 34:       def self.named_objects_with_module(mod)
// 35:         ObjectSpace.each_object(mod).map do |obj|
// 36:           case obj
// 37:           when Class then named_object_for(obj)
// 38:           when Module then obj
// 39:           else raise "Unsupported object: #{obj}"
// 40:           end
// 41:         end.uniq
// 42:       end
// 43:     end
// 44:   end
// 45: end
