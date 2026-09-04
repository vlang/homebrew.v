module private

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/final.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum FinalTargetKind {
	value
	module_
	class_
}

pub struct FinalTarget {
pub:
	id          string
	name        string
	kind        FinalTargetKind
	is_abstract bool
	is_sealed   bool
}

@[heap]
pub struct FinalRegistry {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	modules map[string]bool
}

pub fn new_final_registry() &FinalRegistry {
	return &FinalRegistry{}
}

const final_registry_global = new_final_registry()

pub fn (mut registry FinalRegistry) mark_as_final_module(id string) {
	registry.mutex.lock()
	registry.modules[id] = true
	registry.mutex.unlock()
}

pub fn (mut registry FinalRegistry) final_module(id string) bool {
	registry.mutex.lock()
	defer {
		registry.mutex.unlock()
	}
	return registry.modules[id] or { false }
}

pub fn (mut registry FinalRegistry) declare(target FinalTarget) ! {
	if target.kind == .value {
		return error('${target.name} is not a class or module and cannot be declared as final with `final!`')
	}
	if registry.final_module(target.id) {
		return error('${target.name} was already declared as final and cannot be re-declared as final')
	}
	if target.is_abstract {
		return error('${target.name} was already declared as abstract and cannot be declared as final')
	}
	if target.is_sealed {
		return error('${target.name} was already declared as sealed and cannot be declared as final')
	}
	registry.mark_as_final_module(target.id)
	registry.mark_as_final_module('${target.id}:singleton')
}

pub fn final_inherited(target_name string) ! {
	return error('${target_name} was declared as final and cannot be inherited')
}

pub fn final_included(target_name string) ! {
	return error('${target_name} was declared as final and cannot be included')
}

pub fn final_extended(target_name string) ! {
	return error('${target_name} was declared as final and cannot be extended')
}

fn final_registry() &FinalRegistry {
	return unsafe { &FinalRegistry(final_registry_global) }
}

fn final_target_from_value(value ruby.Value) FinalTarget {
	id := value.attribute('object_id') or { '${value.type_name}:${value.as_string()}' }
	kind := if value.type_name == 'Class' {
		FinalTargetKind.class_
	} else if value.type_name == 'Module' {
		FinalTargetKind.module_
	} else {
		FinalTargetKind.value
	}
	return FinalTarget{
		id: id
		name: value.as_string()
		kind: kind
		is_abstract: value.attribute('abstract') or { 'false' } == 'true'
		is_sealed: value.attribute('sealed') or { 'false' } == 'true'
	}
}

fn final_receiver_name(args []ruby.Value) string {
	if args.len == 0 {
		panic('final hook requires a receiver')
	}
	return args[0].as_string()
}

// Ruby method `inherited(arg)` at line 6.
pub fn ruby_final_l6_d1_inherited(args ...ruby.Value) ruby.Value {
	final_inherited(final_receiver_name(args)) or { panic(err.msg()) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `included(arg)` at line 13.
pub fn ruby_final_l13_d2_included(args ...ruby.Value) ruby.Value {
	final_included(final_receiver_name(args)) or { panic(err.msg()) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `extended(arg)` at line 18.
pub fn ruby_final_l18_d3_extended(args ...ruby.Value) ruby.Value {
	final_extended(final_receiver_name(args)) or { panic(err.msg()) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.declare(mod)` at line 24.
pub fn ruby_final_l24_d4_self_declare(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Final.declare requires a module')
	}
	mut registry := final_registry()
	registry.declare(final_target_from_value(args[0])) or { panic(err.msg()) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.final_module?(mod)` at line 43.
pub fn ruby_final_l43_d5_self_final_module(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	mut registry := final_registry()
	return ruby.bool_value(registry.final_module(final_target_from_value(args[0]).id))
}

// Ruby method `self.mark_as_final_module(mod)` at line 47.
pub fn ruby_final_l47_d6_self_mark_as_final_module(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Final.mark_as_final_module requires a module')
	}
	mut registry := final_registry()
	registry.mark_as_final_module(final_target_from_value(args[0]).id)
	return ruby.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Final
// 5:   module NoInherit
// 6:     def inherited(arg)
// 7:       super(arg)
// 8:       Kernel.raise "#{self} was declared as final and cannot be inherited"
// 9:     end
// 10:   end
// 11:
// 12:   module NoIncludeExtend
// 13:     def included(arg)
// 14:       super(arg)
// 15:       Kernel.raise "#{self} was declared as final and cannot be included"
// 16:     end
// 17:
// 18:     def extended(arg)
// 19:       super(arg)
// 20:       Kernel.raise "#{self} was declared as final and cannot be extended"
// 21:     end
// 22:   end
// 23:
// 24:   def self.declare(mod)
// 25:     if !mod.is_a?(Module)
// 26:       raise "#{mod} is not a class or module and cannot be declared as final with `final!`"
// 27:     end
// 28:     if final_module?(mod)
// 29:       raise "#{mod} was already declared as final and cannot be re-declared as final"
// 30:     end
// 31:     if T::AbstractUtils.abstract_module?(mod)
// 32:       raise "#{mod} was already declared as abstract and cannot be declared as final"
// 33:     end
// 34:     if T::Private::Sealed.sealed_module?(mod)
// 35:       raise "#{mod} was already declared as sealed and cannot be declared as final"
// 36:     end
// 37:     mod.extend(mod.is_a?(Class) ? NoInherit : NoIncludeExtend)
// 38:     mark_as_final_module(mod)
// 39:     mark_as_final_module(mod.singleton_class)
// 40:     T::Private::Methods.install_hooks(mod)
// 41:   end
// 42:
// 43:   def self.final_module?(mod)
// 44:     mod.instance_variable_defined?(:@sorbet_final_module)
// 45:   end
// 46:
// 47:   private_class_method def self.mark_as_final_module(mod)
// 48:     mod.instance_variable_set(:@sorbet_final_module, true)
// 49:   end
// 50: end
