module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/generic.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum GenericVariableKind {
	type_member
	type_template
}

pub struct GenericVariable {
pub:
	kind     GenericVariableKind
	variance string
}

// new_generic_variable mirrors TypeVariable's runtime variance validation. Bounds
// supplied by the Ruby block are deliberately erased by T::Generic at runtime.
pub fn new_generic_variable(kind GenericVariableKind, variance brew_runtime.Value) !GenericVariable {
	if variance.type_name == 'Hash' {
		return error('Pass bounds using a block. Got: ${variance.as_string()}')
	}
	normalized := variance.as_string().trim_string_left(':')
	if normalized !in ['in', 'out', 'invariant'] {
		return error('invalid variance ${variance.as_string()}')
	}
	return GenericVariable{
		kind: kind
		variance: normalized
	}
}

fn generic_variable_value(variable GenericVariable) brew_runtime.Value {
	type_name := match variable.kind {
		.type_member { 'T::Types::TypeMember' }
		.type_template { 'T::Types::TypeTemplate' }
	}
	return brew_runtime.structured_value(type_name, 'T.untyped', {
		'variance': variable.variance
	})
}

fn generic_variance(args []brew_runtime.Value) brew_runtime.Value {
	if args.len > 1 {
		return args[1]
	}
	return brew_runtime.object_value('Symbol', ':invariant')
}

// Ruby method `[](*types)` at line 11.
pub fn ruby_generic_l11_d1_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('T::Generic#[] requires a receiver')
	}
	return args[0]
}

// Ruby method `type_member(variance=:invariant, &blk)` at line 15.
pub fn ruby_generic_l15_d2_type_member(args ...brew_runtime.Value) brew_runtime.Value {
	return generic_variable_value(new_generic_variable(.type_member, generic_variance(args)) or {
		panic(err.msg())
	})
}

// Ruby method `type_template(variance=:invariant, &blk)` at line 19.
pub fn ruby_generic_l19_d3_type_template(args ...brew_runtime.Value) brew_runtime.Value {
	return generic_variable_value(new_generic_variable(.type_template, generic_variance(args)) or {
		panic(err.msg())
	})
}

// Ruby method `has_attached_class!(variance=:invariant, &blk); end` at line 23.
pub fn ruby_generic_l23_d4_has_attached_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Use as a mixin with extend (`extend T::Generic`).
// 5: module T::Generic
// 6:   include T::Helpers
// 7:   include Kernel
// 8:
// 9:   ### Class/Module Helpers ###
// 10:
// 11:   def [](*types)
// 12:     self
// 13:   end
// 14:
// 15:   def type_member(variance=:invariant, &blk)
// 16:     T::Types::TypeMember.new(variance)
// 17:   end
// 18:
// 19:   def type_template(variance=:invariant, &blk)
// 20:     T::Types::TypeTemplate.new(variance)
// 21:   end
// 22:
// 23:   def has_attached_class!(variance=:invariant, &blk); end
// 24: end
