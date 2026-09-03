module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/struct.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum SorbetStructKind {
	mutable
	immutable
}

pub struct StructSubclassGuard {
pub:
	kind     SorbetStructKind
	base     brew_runtime.Value
	subclass brew_runtime.Value
}

pub fn install_struct_subclass_guard(kind SorbetStructKind, base brew_runtime.Value,
	subclass brew_runtime.Value) !StructSubclassGuard {
	if base.type_name != 'Class' || subclass.type_name != 'Class' {
		return error('T::Struct inherited hooks require class values')
	}
	return StructSubclassGuard{
		kind: kind
		base: base
		subclass: subclass
	}
}

pub fn (guard StructSubclassGuard) reject_subclassing() ! {
	struct_name := if guard.kind == .immutable { 'T::ImmutableStruct' } else { 'T::Struct' }
	return error('${guard.subclass.as_string()} is a subclass of ${struct_name} and cannot be subclassed')
}

fn struct_guard_value(guard StructSubclassGuard) brew_runtime.Value {
	struct_name := if guard.kind == .immutable { 'T::ImmutableStruct' } else { 'T::Struct' }
	return brew_runtime.Value{
		type_name: 'T::Private::ClassUtils::ReplacementMethod'
		repr: 'inherited'
		map_data: {
			'base':     guard.base
			'subclass': guard.subclass
		}
		attributes: {
			'kind':  struct_name
			'error': '${guard.subclass.as_string()} is a subclass of ${struct_name} and cannot be subclassed'
		}
	}
}

fn struct_inherited_boundary(args []brew_runtime.Value, kind SorbetStructKind) brew_runtime.Value {
	if args.len < 2 {
		panic('T::Struct inherited hook requires a base and subclass')
	}
	return struct_guard_value(install_struct_subclass_guard(kind, args[0], args[1]) or {
		panic(err.msg())
	})
}

pub fn initialize_immutable_struct(instance brew_runtime.Value,
	hash map[string]brew_runtime.Value) brew_runtime.Value {
	mut attributes := instance.attributes.clone()
	attributes['frozen'] = 'true'
	attributes['class_name'] = instance.attribute('class_name') or { instance.type_name }
	return brew_runtime.Value{
		...instance
		map_data: hash.clone()
		attributes: attributes
	}
}

fn struct_truthy(value brew_runtime.Value) bool {
	return value.type_name != 'NilClass' && !(value.type_name == 'Bool' && !value.bool_data)
}

fn immutable_rule(hash map[string]brew_runtime.Value) bool {
	for key in [':immutable', 'immutable'] {
		if value := hash[key] {
			return struct_truthy(value)
		}
	}
	return false
}

pub fn immutable_struct_prop(target brew_runtime.Value, name brew_runtime.Value,
	class_or_rules brew_runtime.Value, rules map[string]brew_runtime.Value) !brew_runtime.Value {
	class_is_immutable := class_or_rules.type_name == 'Hash' && immutable_rule(class_or_rules.map_data)
	if !class_is_immutable && !immutable_rule(rules) {
		return error('Cannot use `prop` in ${target.as_string()} because it is an immutable struct. Use `const` instead')
	}
	return brew_runtime.Value{
		type_name: 'T::Props::PropDeclaration'
		repr: name.as_string()
		map_data: {
			'target': target
			'name':   name
			'class':  class_or_rules
			'rules':  brew_runtime.map_value(rules)
		}
		attributes: {
			'immutable': 'true'
		}
	}
}

pub fn immutable_struct_with(instance brew_runtime.Value,
	_changed_props brew_runtime.Value) !brew_runtime.Value {
	class_name := instance.attribute('class_name') or { instance.type_name }
	return error('Cannot use `with` in ${class_name} because it is an immutable struct')
}

// Ruby method `self.inherited(subclass)` at line 11.
pub fn ruby_struct_l11_d1_self_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	_ = struct_inherited_boundary(args, .mutable)
	return brew_runtime.object_value('Symbol', ':inherited')
}

// Ruby method `self.inherited(subclass)` at line 24.
pub fn ruby_struct_l24_d2_self_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	_ = struct_inherited_boundary(args, .immutable)
	return brew_runtime.object_value('Symbol', ':inherited')
}

// Ruby method `initialize(hash={})` at line 36.
pub fn ruby_struct_l36_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('T::ImmutableStruct#initialize requires a receiver')
	}
	hash := if args.len > 1 {
		args[1].as_map() or { panic(err.msg()) }
	} else {
		map[string]brew_runtime.Value{}
	}
	return initialize_immutable_struct(args[0], hash)
}

// Ruby method `self.prop(name, cls, **rules)` at line 44.
pub fn ruby_struct_l44_d4_self_prop(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('T::ImmutableStruct.prop requires a class, name, and type')
	}
	rules := if args.len > 3 {
		args[3].as_map() or { panic(err.msg()) }
	} else {
		map[string]brew_runtime.Value{}
	}
	return immutable_struct_prop(args[0], args[1], args[2], rules) or { panic(err.msg()) }
}

// Ruby method `with(changed_props)` at line 50.
pub fn ruby_struct_l50_d5_with(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('T::ImmutableStruct#with requires a receiver and changed properties')
	}
	return immutable_struct_with(args[0], args[1]) or { panic(err.msg()) }
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: class T::InexactStruct
// 5:   include T::Props
// 6:   include T::Props::Serializable
// 7:   include T::Props::Constructor
// 8: end
// 9:
// 10: class T::Struct < T::InexactStruct
// 11:   def self.inherited(subclass)
// 12:     super(subclass)
// 13:     original_method = subclass.singleton_class.instance_method(:inherited)
// 14:     T::Private::ClassUtils.replace_method(original_method, subclass.singleton_class, :inherited) do |s|
// 15:       super(s)
// 16:       raise "#{self.name} is a subclass of T::Struct and cannot be subclassed"
// 17:     end
// 18:   end
// 19: end
// 20:
// 21: class T::ImmutableStruct < T::InexactStruct
// 22:   extend T::Sig
// 23:
// 24:   def self.inherited(subclass)
// 25:     super(subclass)
// 26:
// 27:     original_method = subclass.singleton_class.instance_method(:inherited)
// 28:     T::Private::ClassUtils.replace_method(original_method, subclass.singleton_class, :inherited) do |s|
// 29:       super(s)
// 30:       raise "#{self.name} is a subclass of T::ImmutableStruct and cannot be subclassed"
// 31:     end
// 32:   end
// 33:
// 34:   # Matches the one in WeakConstructor, but freezes the object
// 35:   sig { params(hash: T::Hash[Symbol, T.untyped]).void.checked(:never) }
// 36:   def initialize(hash={})
// 37:     super
// 38:
// 39:     freeze
// 40:   end
// 41:
// 42:   # Matches the signature in Props, but raises since this is an immutable struct and only const is allowed
// 43:   sig { params(name: Symbol, cls: T.untyped, rules: T.untyped).void }
// 44:   def self.prop(name, cls, **rules)
// 45:     return super if (cls.is_a?(Hash) && cls[:immutable]) || rules[:immutable]
// 46:
// 47:     raise "Cannot use `prop` in #{self.name} because it is an immutable struct. Use `const` instead"
// 48:   end
// 49:
// 50:   def with(changed_props)
// 51:     raise "Cannot use `with` in #{self.class.name} because it is an immutable struct"
// 52:   end
// 53: end
