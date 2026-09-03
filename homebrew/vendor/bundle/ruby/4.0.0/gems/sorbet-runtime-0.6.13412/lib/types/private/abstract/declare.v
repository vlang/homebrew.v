module abstract

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/abstract/declare.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct AbstractDeclaration {
pub:
	mod             brew_runtime.Value
	abstract_type   string
	is_final        bool
	has_own_new     bool
	is_class        bool
	singleton_class brew_runtime.Value
}

pub fn declare_abstract(declaration AbstractDeclaration) ! {
	mut data := global_abstract_data()
	if data.has_key(declaration.mod, 'abstract_type') {
		return error('${declaration.mod.as_string()} is already declared as abstract')
	}
	if declaration.is_final {
		return error('${declaration.mod.as_string()} was already declared as final and cannot be declared as abstract')
	}
	if declaration.is_class && declaration.abstract_type.trim_string_left(':') == 'interface' {
		return error("Classes can't be interfaces. Use `abstract!` instead of `interface!`.")
	}
	if declaration.is_class && declaration.has_own_new {
		return error('You must call `abstract!` *before* defining a `new` method')
	}
	data.set(declaration.mod, 'can_have_abstract_methods', brew_runtime.bool_value(true))
	data.set(declaration.singleton_class, 'can_have_abstract_methods', brew_runtime.bool_value(true))
	data.set(declaration.mod, 'abstract_type', brew_runtime.object_value('Symbol', ':${declaration.abstract_type.trim_string_left(':')}'))
	data.set(declaration.mod, 'abstract_hooks', brew_runtime.bool_value(true))
}

pub fn construct_abstract(module_name string, result brew_runtime.Value,
	is_exact_instance bool) !brew_runtime.Value {
	if is_exact_instance {
		return error('${module_name} is declared as abstract; it cannot be instantiated')
	}
	return result
}

fn abstract_declaration_from_args(args []brew_runtime.Value) AbstractDeclaration {
	if args.len < 2 {
		panic('Abstract::Declare.declare_abstract requires a module and type')
	}
	mod := args[0]
	singleton := brew_runtime.structured_value('Class', '#<Class:${mod.as_string()}>', {
		'object_id': '${abstract_object_id(mod)}:singleton'
	})
	return AbstractDeclaration{
		mod: mod
		abstract_type: args[1].as_string()
		is_final: mod.attribute('final') or { 'false' } == 'true'
		has_own_new: mod.attribute('owns_new') or { 'false' } == 'true'
		is_class: mod.type_name == 'Class'
		singleton_class: singleton
	}
}

// Ruby method `self.declare_abstract(mod, type:)` at line 8.
pub fn ruby_declare_l8_d1_self_declare_abstract(args ...brew_runtime.Value) brew_runtime.Value {
	declare_abstract(abstract_declaration_from_args(args)) or { panic(err.msg()) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby define_singleton_method `mod.send(:define_singleton_method, :new) do |*args, &blk|` at line 36.
pub fn ruby_declare_l36_d2_new(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('abstract new wrapper requires a module and constructed result')
	}
	exact := if args.len > 2 {
		args[2].as_bool() or { false }
	} else {
		args[1].type_name == args[0].as_string()
	}
	return construct_abstract(args[0].as_string(), args[1], exact) or { panic(err.msg()) }
}

// Ruby alias_method `mod.singleton_class.send(:alias_method, :new, :new)` at line 46.
pub fn ruby_declare_l46_d3_new(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return args[0]
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Abstract::Declare
// 5:   Abstract = T::Private::Abstract
// 6:   AbstractUtils = T::AbstractUtils
// 7:
// 8:   def self.declare_abstract(mod, type:)
// 9:     if AbstractUtils.abstract_module?(mod)
// 10:       raise "#{mod} is already declared as abstract"
// 11:     end
// 12:     if T::Private::Final.final_module?(mod)
// 13:       raise "#{mod} was already declared as final and cannot be declared as abstract"
// 14:     end
// 15:
// 16:     Abstract::Data.set(mod, :can_have_abstract_methods, true)
// 17:     Abstract::Data.set(mod.singleton_class, :can_have_abstract_methods, true)
// 18:     Abstract::Data.set(mod, :abstract_type, type)
// 19:
// 20:     mod.extend(Abstract::Hooks)
// 21:
// 22:     if mod.is_a?(Class)
// 23:       if type == :interface
// 24:         # Since `interface!` is just `abstract!` with some extra validation, we could technically
// 25:         # allow this, but it's unclear there are good use cases, and it might be confusing.
// 26:         raise "Classes can't be interfaces. Use `abstract!` instead of `interface!`."
// 27:       end
// 28:
// 29:       if Object.instance_method(:method).bind_call(mod, :new).owner == mod
// 30:         raise "You must call `abstract!` *before* defining a `new` method"
// 31:       end
// 32:
// 33:       # Don't need to silence warnings via without_ruby_warnings when calling
// 34:       # define_method because of the guard above
// 35:
// 36:       mod.send(:define_singleton_method, :new) do |*args, &blk|
// 37:         result = super(*args, &blk)
// 38:         if result.instance_of?(mod)
// 39:           raise "#{mod} is declared as abstract; it cannot be instantiated"
// 40:         end
// 41:         result
// 42:       end
// 43:
// 44:       # Ruby doesn not emit "method redefined" warnings for aliased methods
// 45:       # (more robust than undef_method that would create a small window in which the method doesn't exist)
// 46:       mod.singleton_class.send(:alias_method, :new, :new)
// 47:
// 48:       if mod.singleton_class.respond_to?(:ruby2_keywords, true)
// 49:         mod.singleton_class.send(:ruby2_keywords, :new)
// 50:       end
// 51:     end
// 52:   end
// 53: end
