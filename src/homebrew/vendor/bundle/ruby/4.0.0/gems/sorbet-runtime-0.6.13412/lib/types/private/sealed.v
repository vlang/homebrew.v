module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/sealed.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `inherited(child)` at line 6.
pub fn ruby_sealed_l6_d1_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inherited', ...args)
}

// Ruby method `sealed_subclasses` at line 13.
pub fn ruby_sealed_l13_d2_sealed_subclasses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sealed_subclasses', ...args)
}

// Ruby method `included(child)` at line 23.
pub fn ruby_sealed_l23_d3_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('included', ...args)
}

// Ruby method `extended(child)` at line 30.
pub fn ruby_sealed_l30_d4_extended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extended', ...args)
}

// Ruby method `sealed_subclasses` at line 37.
pub fn ruby_sealed_l37_d5_sealed_subclasses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sealed_subclasses', ...args)
}

// Ruby method `self.declare(mod, decl_file)` at line 49.
pub fn ruby_sealed_l49_d6_self_declare(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.declare', ...args)
}

// Ruby method `self.sealed_module?(mod)` at line 67.
pub fn ruby_sealed_l67_d7_self_sealed_module(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sealed_module?', ...args)
}

// Ruby method `self.validate_inheritance(caller_loc, parent, child, verb)` at line 71.
pub fn ruby_sealed_l71_d8_self_validate_inheritance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.validate_inheritance', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Sealed
// 5:   module NoInherit
// 6:     def inherited(child)
// 7:       super
// 8:       caller_loc = T::Private::CallerUtils.find_caller { |loc| loc.base_label != 'inherited' }
// 9:       T::Private::Sealed.validate_inheritance(caller_loc, self, child, 'inherited')
// 10:       @sorbet_sealed_module_all_subclasses << child
// 11:     end
// 12:
// 13:     def sealed_subclasses
// 14:       @sorbet_sealed_module_all_subclasses_set ||= # rubocop:disable Naming/MemoizedInstanceVariableName
// 15:         begin
// 16:           Kernel.require 'set'
// 17:           Set.new(@sorbet_sealed_module_all_subclasses).freeze
// 18:         end
// 19:     end
// 20:   end
// 21:
// 22:   module NoIncludeExtend
// 23:     def included(child)
// 24:       super
// 25:       caller_loc = T::Private::CallerUtils.find_caller { |loc| loc.base_label != 'included' }
// 26:       T::Private::Sealed.validate_inheritance(caller_loc, self, child, 'included')
// 27:       @sorbet_sealed_module_all_subclasses << child
// 28:     end
// 29:
// 30:     def extended(child)
// 31:       super
// 32:       caller_loc = T::Private::CallerUtils.find_caller { |loc| loc.base_label != 'extended' }
// 33:       T::Private::Sealed.validate_inheritance(caller_loc, self, child, 'extended')
// 34:       @sorbet_sealed_module_all_subclasses << child
// 35:     end
// 36:
// 37:     def sealed_subclasses
// 38:       # this will freeze the set so that you can never get into a
// 39:       # state where you use the subclasses list and then something
// 40:       # else will add to it
// 41:       @sorbet_sealed_module_all_subclasses_set ||= # rubocop:disable Naming/MemoizedInstanceVariableName
// 42:         begin
// 43:           Kernel.require 'set'
// 44:           Set.new(@sorbet_sealed_module_all_subclasses).freeze
// 45:         end
// 46:     end
// 47:   end
// 48:
// 49:   def self.declare(mod, decl_file)
// 50:     if !mod.is_a?(Module)
// 51:       raise "#{mod} is not a class or module and cannot be declared `sealed!`"
// 52:     end
// 53:     if sealed_module?(mod)
// 54:       raise "#{mod} was already declared `sealed!` and cannot be re-declared `sealed!`"
// 55:     end
// 56:     if T::Private::Final.final_module?(mod)
// 57:       raise "#{mod} was already declared `final!` and cannot be declared `sealed!`"
// 58:     end
// 59:     mod.extend(mod.is_a?(Class) ? NoInherit : NoIncludeExtend)
// 60:     if !decl_file
// 61:       raise "Couldn't determine declaration file for sealed class."
// 62:     end
// 63:     mod.instance_variable_set(:@sorbet_sealed_module_decl_file, decl_file)
// 64:     mod.instance_variable_set(:@sorbet_sealed_module_all_subclasses, [])
// 65:   end
// 66:
// 67:   def self.sealed_module?(mod)
// 68:     mod.instance_variable_defined?(:@sorbet_sealed_module_decl_file)
// 69:   end
// 70:
// 71:   def self.validate_inheritance(caller_loc, parent, child, verb)
// 72:     this_file = caller_loc&.path
// 73:     decl_file = parent.instance_variable_get(:@sorbet_sealed_module_decl_file)
// 74:
// 75:     if !this_file
// 76:       raise "Could not use backtrace to determine file for #{verb} child #{child}"
// 77:     end
// 78:     if !decl_file
// 79:       raise "#{parent} does not seem to be a sealed module (#{verb} by #{child})"
// 80:     end
// 81:
// 82:     if !this_file.start_with?(decl_file)
// 83:       whitelist = T::Configuration.sealed_violation_whitelist
// 84:       if !whitelist.nil? && whitelist.any? { |pattern| this_file =~ pattern }
// 85:         return
// 86:       end
// 87:
// 88:       raise "#{parent} was declared sealed and can only be #{verb} in #{decl_file}, not #{this_file}"
// 89:     end
// 90:   end
// 91: end
