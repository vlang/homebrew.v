module mixins

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/mixins/mixins.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct MixinsRegistry {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	class_methods map[string][]ruby.Value
}

pub fn new_mixins_registry() &MixinsRegistry {
	return &MixinsRegistry{}
}

const mixins_registry_global = new_mixins_registry()

fn mixin_id(value ruby.Value) string {
	return value.attribute('object_id') or { '${value.type_name}:${value.as_string()}' }
}

pub fn (mut registry MixinsRegistry) declare(mixin ruby.Value,
	class_methods []ruby.Value) ![]ruby.Value {
	if mixin.type_name == 'Class' {
		return error('Classes cannot be used as mixins, and so mixes_in_class_methods cannot be used on a Class.')
	}
	registry.mutex.lock()
	defer {
		registry.mutex.unlock()
	}
	id := mixin_id(mixin)
	existing := registry.class_methods[id] or { []ruby.Value{} }
	mut combined := existing.clone()
	combined << class_methods
	registry.class_methods[id] = combined.clone()
	return combined
}

pub fn (mut registry MixinsRegistry) included_class_methods(mixin ruby.Value,
	_other ruby.Value) []ruby.Value {
	registry.mutex.lock()
	defer {
		registry.mutex.unlock()
	}
	return (registry.class_methods[mixin_id(mixin)] or { []ruby.Value{} }).clone()
}

fn global_mixins_registry() &MixinsRegistry {
	return unsafe { &MixinsRegistry(mixins_registry_global) }
}

// Ruby method `included(other)` at line 6.
pub fn ruby_mixins_l6_d1_included(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MixesInClassMethods#included requires a mixin and consumer')
	}
	mut registry := global_mixins_registry()
	methods := registry.included_class_methods(args[0], args[1])
	return ruby.Value{
		type_name: 'T::Private::MixesInClassMethods::ExtensionPlan'
		repr: args[1].as_string()
		array_data: methods
		map_data: {
			'consumer': args[1]
		}
	}
}

// Ruby method `self.declare_mixes_in_class_methods(mixin, class_methods)` at line 14.
pub fn ruby_mixins_l14_d2_self_declare_mixes_in_class_methods(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Mixins.declare_mixes_in_class_methods requires a mixin and class methods')
	}
	methods := args[1].as_array() or { panic(err.msg()) }
	mut registry := global_mixins_registry()
	return ruby.array_value(registry.declare(args[0], methods) or { panic(err.msg()) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private
// 5:   module MixesInClassMethods
// 6:     def included(other)
// 7:       mods = Abstract::Data.get(self, :class_methods_mixins)
// 8:       mods.each { |mod| other.extend(mod) }
// 9:       super
// 10:     end
// 11:   end
// 12:
// 13:   module Mixins
// 14:     def self.declare_mixes_in_class_methods(mixin, class_methods)
// 15:       if mixin.is_a?(Class)
// 16:         raise "Classes cannot be used as mixins, and so mixes_in_class_methods cannot be used on a Class."
// 17:       end
// 18:
// 19:       if Abstract::Data.key?(mixin, :class_methods_mixins)
// 20:         class_methods = Abstract::Data.get(mixin, :class_methods_mixins) + class_methods
// 21:       end
// 22:
// 23:       mixin.singleton_class.include(MixesInClassMethods)
// 24:       Abstract::Data.set(mixin, :class_methods_mixins, class_methods)
// 25:     end
// 26:   end
// 27: end
