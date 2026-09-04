module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/helpers.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum HelperDeclarationKind {
	abstract_
	interface_
	final_
	sealed_
	mixes_in_class_methods
	requires_ancestor
}

pub struct HelperDeclaration {
pub:
	kind             HelperDeclarationKind
	target           ruby.Value
	declaration_file string
	modules          []ruby.Value
	super_result     ruby.Value
}

fn helpers_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn declare_helper(kind HelperDeclarationKind, target ruby.Value,
	declaration_file string, modules []ruby.Value) !HelperDeclaration {
	is_module := target.type_name in ['Class', 'Module']
	is_abstract := target.attribute('abstract') or { 'false' } == 'true'
	is_final := target.attribute('final') or { 'false' } == 'true'
	is_sealed := target.attribute('sealed') or { 'false' } == 'true'
	if kind in [.abstract_, .interface_] {
		if !is_module {
			return error('${target.as_string()} is not a class or module and cannot be declared abstract')
		}
		if is_abstract {
			return error('${target.as_string()} is already declared as abstract')
		}
		if is_final {
			return error('${target.as_string()} was already declared as final and cannot be declared as abstract')
		}
		if kind == .interface_ && target.type_name == 'Class' {
			return error("Classes can't be interfaces. Use `abstract!` instead of `interface!`.")
		}
		if target.type_name == 'Class' && target.attribute('owns_new') or { 'false' } == 'true' {
			return error('You must call `abstract!` *before* defining a `new` method')
		}
	}
	if kind == .final_ {
		if !is_module {
			return error('${target.as_string()} is not a class or module and cannot be declared as final with `final!`')
		}
		if is_final {
			return error('${target.as_string()} was already declared as final and cannot be re-declared as final')
		}
		if is_abstract {
			return error('${target.as_string()} was already declared as abstract and cannot be declared as final')
		}
		if is_sealed {
			return error('${target.as_string()} was already declared as sealed and cannot be declared as final')
		}
	}
	if kind == .sealed_ {
		if !is_module {
			return error('${target.as_string()} is not a class or module and cannot be declared `sealed!`')
		}
		if is_sealed {
			return error('${target.as_string()} was already declared `sealed!` and cannot be re-declared `sealed!`')
		}
		if is_final {
			return error('${target.as_string()} was already declared `final!` and cannot be declared `sealed!`')
		}
		if declaration_file == '' {
			return error("Couldn't determine declaration file for sealed class.")
		}
	}
	if kind == .mixes_in_class_methods {
		if target.type_name == 'Class' {
			return error('Classes cannot be used as mixins, and so mixes_in_class_methods cannot be used on a Class.')
		}
		for mod in modules {
			if mod.type_name != 'Module' {
				return error('mixes_in_class_methods expects modules, got ${mod.type_name}')
			}
		}
	}
	super_result := target.map_data['abstract_super'] or { helpers_nil_value() }
	if kind == .abstract_ && super_result.type_name == 'Exception' {
		return error(super_result.as_string())
	}
	return HelperDeclaration{
		kind: kind
		target: target
		declaration_file: declaration_file
		modules: modules.clone()
		super_result: super_result
	}
}

fn helper_boundary(args []ruby.Value, kind HelperDeclarationKind) ruby.Value {
	if args.len == 0 {
		panic('T::Helpers method requires a receiver')
	}
	declaration_file := if kind == .sealed_ && args.len > 1 {
		args[1].as_string()
	} else {
		''
	}
	modules := if kind == .mixes_in_class_methods && args.len > 1 {
		args[1..].clone()
	} else {
		[]ruby.Value{}
	}
	declare_helper(kind, args[0], declaration_file, modules) or { panic(err.msg()) }
	return helpers_nil_value()
}

// Ruby method `abstract!` at line 11.
pub fn ruby_helpers_l11_d1_abstract(args ...ruby.Value) ruby.Value {
	return helper_boundary(args, .abstract_)
}

// Ruby method `interface!` at line 22.
pub fn ruby_helpers_l22_d2_interface(args ...ruby.Value) ruby.Value {
	return helper_boundary(args, .interface_)
}

// Ruby method `final!` at line 26.
pub fn ruby_helpers_l26_d3_final(args ...ruby.Value) ruby.Value {
	return helper_boundary(args, .final_)
}

// Ruby method `sealed!` at line 30.
pub fn ruby_helpers_l30_d4_sealed(args ...ruby.Value) ruby.Value {
	return helper_boundary(args, .sealed_)
}

// Ruby method `mixes_in_class_methods(mod, *mods)` at line 43.
pub fn ruby_helpers_l43_d5_mixes_in_class_methods(args ...ruby.Value) ruby.Value {
	return helper_boundary(args, .mixes_in_class_methods)
}

// Ruby method `requires_ancestor(&block); end` at line 62.
pub fn ruby_helpers_l62_d6_requires_ancestor(args ...ruby.Value) ruby.Value {
	if args.len > 0 {
		// The Ruby runtime intentionally leaves this check as a static-only TODO.
		_ = declare_helper(.requires_ancestor, args[0], '', []) or { panic(err.msg()) }
	}
	return helpers_nil_value()
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Use as a mixin with extend (`extend T::Helpers`).
// 5: # Docs at https://sorbet.org/docs/
// 6: module T::Helpers
// 7:   Private = T::Private
// 8:
// 9:   ### Class/Module Helpers ###
// 10:
// 11:   def abstract!
// 12:     if defined?(super)
// 13:       # This is to play nicely with Rails' AbstractController::Base,
// 14:       # which also defines an `abstract!` method.
// 15:       # https://api.rubyonrails.org/classes/AbstractController/Base.html#method-c-abstract-21
// 16:       super
// 17:     end
// 18:
// 19:     Private::Abstract::Declare.declare_abstract(self, type: :abstract)
// 20:   end
// 21:
// 22:   def interface!
// 23:     Private::Abstract::Declare.declare_abstract(self, type: :interface)
// 24:   end
// 25:
// 26:   def final!
// 27:     Private::Final.declare(self)
// 28:   end
// 29:
// 30:   def sealed!
// 31:     Private::Sealed.declare(self, Kernel.caller(1..1)&.first&.split(':')&.first)
// 32:   end
// 33:
// 34:   # Causes a mixin to also mix in class methods from the named module.
// 35:   #
// 36:   # Nearly equivalent to
// 37:   #
// 38:   #  def self.included(other)
// 39:   #    other.extend(mod)
// 40:   #  end
// 41:   #
// 42:   # Except that it is statically analyzed by sorbet.
// 43:   def mixes_in_class_methods(mod, *mods)
// 44:     Private::Mixins.declare_mixes_in_class_methods(self, [mod].concat(mods))
// 45:   end
// 46:
// 47:   # Specify an inclusion or inheritance requirement for `self`.
// 48:   #
// 49:   # Example:
// 50:   #
// 51:   #   module MyHelper
// 52:   #     extend T::Helpers
// 53:   #
// 54:   #     requires_ancestor { Kernel }
// 55:   #   end
// 56:   #
// 57:   #   class MyClass < BasicObject # error: `MyClass` must include `Kernel` (required by `MyHelper`)
// 58:   #     include MyHelper
// 59:   #   end
// 60:   #
// 61:   # TODO: implement the checks in sorbet-runtime.
// 62:   def requires_ancestor(&block); end
// 63: end
