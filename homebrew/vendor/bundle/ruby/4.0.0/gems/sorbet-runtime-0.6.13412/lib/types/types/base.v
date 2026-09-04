module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/base.rb`.
// The original source is retained below until every stub has a typed V body.
const base_not_implemented_error = 'NotImplementedError'

// BaseTypeKind retains the runtime classes inspected by Base#subtype_of?.
pub enum BaseTypeKind {
	abstract_base
	simple
	anything
	untyped
	no_return
	self_type
	attached_class
	type_variable
	union_type
	intersection_type
	alias_type
	void_type
	custom
}

// BaseSubtypeResult preserves Module#<= returning nil for unrelated plain
// classes. Composite subtype tests treat both no and unrelated as false.
pub enum BaseSubtypeResult {
	no
	yes
	unrelated
}

pub struct BaseOptionalString {
pub:
	present bool
	value   string
}

// BaseType is the typed runtime adapter used while Sorbet's concrete type
// classes are translated independently. members contains union/intersection
// members, or the single resolved member for a type alias.
@[heap]
pub struct BaseType {
pub:
	kind                    BaseTypeKind = .abstract_base
	type_name               string = 'T::Types::Base'
	display_name            string
	members                 []&BaseType
	valid_type_names        []string
	direct_subtype_names    []string
	direct_supertype_names  []string
	include_value_in_errors bool = true
}

pub fn new_base_type() &BaseType {
	return &BaseType{}
}

pub fn new_simple_base_type(name string, direct_supertypes []string) &BaseType {
	return &BaseType{
		kind: .simple
		type_name: 'T::Types::Simple'
		display_name: name
		valid_type_names: [name]
		direct_supertype_names: direct_supertypes.clone()
	}
}

pub fn new_custom_base_type(type_name string, name string, valid_type_names []string,
	direct_subtype_names []string) &BaseType {
	return &BaseType{
		kind: .custom
		type_name: type_name
		display_name: name
		valid_type_names: valid_type_names.clone()
		direct_subtype_names: direct_subtype_names.clone()
	}
}

pub fn new_union_base_type(members []&BaseType) &BaseType {
	return &BaseType{
		kind: .union_type
		type_name: 'T::Types::Union'
		display_name: 'T.any(${base_type_names(members).join(', ')})'
		members: members.clone()
	}
}

pub fn new_intersection_base_type(members []&BaseType) &BaseType {
	return &BaseType{
		kind: .intersection_type
		type_name: 'T::Types::Intersection'
		display_name: 'T.all(${base_type_names(members).join(', ')})'
		members: members.clone()
	}
}

pub fn new_alias_base_type(aliased_type &BaseType) &BaseType {
	return &BaseType{
		kind: .alias_type
		type_name: 'T::Private::Types::TypeAlias'
		display_name: aliased_type.name() or { '' }
		members: [aliased_type]
	}
}

pub fn new_void_base_type() &BaseType {
	return &BaseType{
		kind: .void_type
		type_name: 'T::Private::Types::Void'
		display_name: '<VOID>'
	}
}

pub fn base_anything_type() &BaseType {
	type_value := anything_type_value()
	return &BaseType{
		kind: .anything
		type_name: type_value.type_name
		display_name: new_anything_type().name()
	}
}

pub fn base_no_return_type() &BaseType {
	type_value := no_return_type_value()
	return &BaseType{
		kind: .no_return
		type_name: type_value.type_name
		display_name: new_no_return_type().name()
	}
}

pub fn base_untyped_type() &BaseType {
	type_value := untyped_type_value()
	return &BaseType{
		kind: .untyped
		type_name: type_value.type_name
		display_name: new_untyped_type().name()
	}
}

pub fn base_self_type() &BaseType {
	type_value := self_type_value()
	return &BaseType{
		kind: .self_type
		type_name: type_value.type_name
		display_name: new_self_type().name()
	}
}

pub fn base_attached_class_type() &BaseType {
	type_value := attached_class_type_value()
	return &BaseType{
		kind: .attached_class
		type_name: type_value.type_name
		display_name: new_attached_class_type().name()
	}
}

pub fn base_type_variable(variance string) !&BaseType {
	variable := new_type_variable(variance)!
	type_value := type_variable_value(variable)
	return &BaseType{
		kind: .type_variable
		type_name: type_value.type_name
		display_name: variable.name()
	}
}

fn base_type_names(types []&BaseType) []string {
	mut names := []string{cap: types.len}
	for type_value in types {
		names << type_value.name() or { '' }
	}
	names.sort()
	return names
}

// base_method_added mirrors Base's inheritance hook. V does not permit a
// derived type to override an existing method, so callers expose the attempted
// declaring runtime class explicitly.
pub fn base_method_added(declaring_type string, method_name string) ! {
	if method_name.trim_string_left(':') == 'subtype_of?' && declaring_type != 'T::Types::Base' {
		return error('`subtype_of?` should not be overridden. You probably want to override `subtype_of_single?` instead.')
	}
}

pub fn (type_value &BaseType) recursively_valid(obj ruby.Value) !bool {
	return type_value.valid(obj)
}

pub fn (type_value &BaseType) valid(obj ruby.Value) !bool {
	return match type_value.kind {
		.abstract_base { error(base_not_implemented_error) }
		.anything { new_anything_type().valid(obj) }
		.untyped { new_untyped_type().valid(obj) }
		.no_return { new_no_return_type().valid(obj) }
		.self_type { new_self_type().valid(obj) }
		.attached_class { new_attached_class_type().valid(obj) }
		.type_variable { true }
		.union_type {
			mut valid := false
			for member in type_value.members {
				if member.valid(obj)! {
					valid = true
					break
				}
			}
			valid
		}
		.intersection_type {
			mut valid := true
			for member in type_value.members {
				if !member.valid(obj)! {
					valid = false
					break
				}
			}
			valid
		}
		.alias_type {
			type_value.aliased_type()!.valid(obj)!
		}
		.void_type {
			error('Validation is being done on an `Void`. Please report this bug at https://github.com/sorbet/sorbet/issues')
		}
		.simple, .custom {
			type_value.accepts_object_type(obj)
		}
	}
}

fn (type_value &BaseType) accepts_object_type(obj ruby.Value) bool {
	if obj.type_name in type_value.valid_type_names {
		return true
	}
	ancestors := obj.attributes['ancestors'] or { return false }
	for ancestor in ancestors.split(',') {
		if ancestor.trim_space() in type_value.valid_type_names {
			return true
		}
	}
	return false
}

pub fn (type_value &BaseType) subtype_of_single(other &BaseType) !BaseSubtypeResult {
	return match type_value.kind {
		.abstract_base { error(base_not_implemented_error) }
		.anything {
			if new_anything_type().subtype_of_single(base_type_boundary_value(other)) {
				BaseSubtypeResult.yes
			} else {
				BaseSubtypeResult.no
			}
		}
		.untyped {
			if new_untyped_type().subtype_of_single(base_type_boundary_value(other)) {
				BaseSubtypeResult.yes
			} else {
				BaseSubtypeResult.no
			}
		}
		.no_return {
			if new_no_return_type().subtype_of_single(base_type_boundary_value(other)) {
				BaseSubtypeResult.yes
			} else {
				BaseSubtypeResult.no
			}
		}
		.self_type {
			if new_self_type().subtype_of_single(base_type_boundary_value(other)) {
				BaseSubtypeResult.yes
			} else {
				BaseSubtypeResult.no
			}
		}
		.attached_class {
			if new_attached_class_type().subtype_of_single(base_type_boundary_value(other)) {
				BaseSubtypeResult.yes
			} else {
				BaseSubtypeResult.no
			}
		}
		.type_variable { BaseSubtypeResult.yes }
		.union_type, .intersection_type {
			error("This should never be reached if you're going through `subtype_of?` (and you should be)")
		}
		.alias_type {
			type_value.aliased_type()!.subtype_of_single(other)!
		}
		.void_type {
			error('Validation is being done on an `Void`. Please report this bug at https://github.com/sorbet/sorbet/issues')
		}
		.simple {
			type_value.simple_subtype_of_single(other)
		}
		.custom {
			if type_value.display_name == other.display_name || other.display_name in type_value.direct_subtype_names {
				BaseSubtypeResult.yes
			} else {
				BaseSubtypeResult.no
			}
		}
	}
}

fn (type_value &BaseType) simple_subtype_of_single(other &BaseType) BaseSubtypeResult {
	if other.kind != .simple && other.kind != .custom {
		return .no
	}
	if type_value.display_name == other.display_name || other.display_name in type_value.direct_supertype_names || other.display_name in type_value.direct_subtype_names {
		return .yes
	}
	if type_value.display_name in other.direct_supertype_names {
		return .no
	}
	return .unrelated
}

fn (type_value &BaseType) aliased_type() !&BaseType {
	if type_value.members.len != 1 {
		return error('TypeAlias has no aliased type')
	}
	return type_value.members[0]
}

pub fn (type_value &BaseType) build_type() ! {
	if type_value.kind == .abstract_base {
		return error(base_not_implemented_error)
	}
	if type_value.kind in [.union_type, .intersection_type] {
		for member in type_value.members {
			member.build_type()!
		}
	}
}

pub fn (type_value &BaseType) name() !string {
	if type_value.kind == .abstract_base {
		return error(base_not_implemented_error)
	}
	if type_value.kind == .alias_type {
		return type_value.aliased_type()!.name()
	}
	return type_value.display_name
}

pub fn (type_value &BaseType) subtype_of(other_type &BaseType) !BaseSubtypeResult {
	right := if other_type.kind == .alias_type {
		other_type.aliased_type()!
	} else {
		other_type
	}
	if type_value.kind == .simple && right.kind == .simple {
		return type_value.subtype_of_single(right)
	}
	if right.kind == .anything {
		return .yes
	}
	if type_value.kind == .alias_type {
		return type_value.aliased_type()!.subtype_of(right)
	}
	if type_value.kind == .type_variable || right.kind == .type_variable {
		return .yes
	}
	if type_value.kind == .union_type {
		for member in type_value.members {
			if member.subtype_of(right)! != .yes {
				return .no
			}
		}
		return .yes
	}
	if right.kind == .intersection_type {
		for member in right.members {
			if type_value.subtype_of(member)! != .yes {
				return .no
			}
		}
		return .yes
	}
	if right.kind == .union_type {
		for right_member in right.members {
			if type_value.subtype_of(right_member)! == .yes {
				return .yes
			}
		}
		if type_value.kind == .intersection_type {
			for left_member in type_value.members {
				if left_member.subtype_of(right)! == .yes {
					return .yes
				}
			}
		}
		return .no
	}
	if type_value.kind == .intersection_type {
		for member in type_value.members {
			if member.subtype_of(right)! == .yes {
				return .yes
			}
		}
		return .no
	}
	if type_value.kind == .void_type {
		return if right.kind == .void_type { .yes } else { .no }
	}
	if type_value.kind == .untyped || right.kind == .untyped {
		return .yes
	}
	return type_value.subtype_of_single(right)
}

pub fn (type_value &BaseType) to_s() !string {
	return type_value.name()
}

pub fn (type_value &BaseType) describe_obj(obj ruby.Value) string {
	class_name := base_object_class_name(obj)
	if obj.type_name == 'NilClass' || obj.type_name == 'Bool' || obj.type_name in [
		'TrueClass',
		'FalseClass',
	] {
		return 'type ${class_name}'
	}
	if obj.attributes['unprintable'] or { '' } == 'true' {
		return 'type ${class_name} with unprintable value'
	}
	if base_has_kernel_inspect(obj) {
		hash_value := obj.attributes['hash'] or { i64(obj.repr.hash()).str() }
		return 'type ${class_name} with hash ${hash_value}'
	}
	if type_value.include_value_in_errors {
		return 'type ${class_name} with value ${truncate_middle(base_value_inspect(obj), 30, 30)}'
	}
	return 'type ${class_name}'
}

fn base_object_class_name(obj ruby.Value) string {
	return match obj.type_name {
		'Bool' {
			if obj.bool_data { 'TrueClass' } else { 'FalseClass' }
		}
		else { obj.type_name }
	}
}

fn base_has_kernel_inspect(obj ruby.Value) bool {
	if inspect_owner := obj.attributes['inspect_owner'] {
		return inspect_owner == 'Kernel'
	}
	return obj.type_name !in ['String', 'Integer', 'Float', 'Bool', 'TrueClass', 'FalseClass',
		'NilClass', 'Symbol', 'Array', 'Hash']
}

fn base_value_inspect(obj ruby.Value) string {
	if inspect := obj.attributes['inspect'] {
		return inspect
	}
	return match obj.type_name {
		'String' { '"${base_escape_string(obj.repr)}"' }
		'NilClass' { 'nil' }
		'Bool' { obj.bool_data.str() }
		else { obj.repr }
	}
}

fn base_escape_string(value string) string {
	return value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
}

fn truncate_middle(value string, start_len int, end_len int) string {
	runes := value.runes()
	if runes.len <= start_len + end_len {
		return value
	}
	return runes[..start_len].string() + '...' + runes[runes.len - end_len..].string()
}

pub fn (type_value &BaseType) error_message_for_obj(obj ruby.Value) !BaseOptionalString {
	if type_value.valid(obj)! {
		return BaseOptionalString{}
	}
	return BaseOptionalString{
		present: true
		value: type_value.error_message(obj)!
	}
}

pub fn (type_value &BaseType) error_message_for_obj_recursive(obj ruby.Value) !BaseOptionalString {
	if type_value.recursively_valid(obj)! {
		return BaseOptionalString{}
	}
	return BaseOptionalString{
		present: true
		value: type_value.error_message(obj)!
	}
}

pub fn (type_value &BaseType) error_message(obj ruby.Value) !string {
	return 'Expected type ${type_value.name()!}, got ${type_value.describe_obj(obj)}'
}

pub fn (type_value &BaseType) validate(obj ruby.Value) ! {
	message := type_value.error_message_for_obj(obj)!
	if message.present {
		return error(message.value)
	}
}

pub fn (type_value &BaseType) hash() !int {
	return type_value.name()!.hash()
}

pub fn (type_value &BaseType) equals(other &BaseType) !bool {
	if voidptr(type_value) == voidptr(other) {
		return true
	}
	return type_value.name()! == other.name()!
}

pub fn (type_value &BaseType) eql(other &BaseType) !bool {
	return type_value.equals(other)
}

pub fn base_type_boundary_value(type_value &BaseType) ruby.Value {
	return ruby.structured_value(type_value.type_name, type_value.name() or {
		type_value.display_name
	}, {
		'base_type_address': u64(voidptr(type_value)).str()
	})
}

pub fn base_type_from_value(value ruby.Value) !&BaseType {
	if address := value.attributes['base_type_address'] {
		return unsafe { &BaseType(voidptr(address.u64())) }
	}
	return match value.type_name {
		'T::Types::Base' { new_base_type() }
		'T::Types::Simple' { new_simple_base_type(value.repr, []) }
		'T::Types::Anything' { base_anything_type() }
		'T::Types::Untyped' { base_untyped_type() }
		'T::Types::NoReturn' { base_no_return_type() }
		'T::Types::SelfType' { base_self_type() }
		'T::Types::AttachedClassType' { base_attached_class_type() }
		'T::Types::TypeVariable', 'T::Types::TypeMember', 'T::Types::TypeParameter' {
			base_type_variable(value.attributes['variance'] or { 'invariant' })!
		}
		'T::Private::Types::Void' { new_void_base_type() }
		else { error('${value.type_name} is not a T::Types::Base') }
	}
}

fn base_type_from_args(args []ruby.Value) &BaseType {
	if args.len == 0 {
		panic('Base method requires a receiver')
	}
	return base_type_from_value(args[0]) or { panic(err) }
}

fn base_subtype_boundary_value(result BaseSubtypeResult) ruby.Value {
	return match result {
		.yes { ruby.bool_value(true) }
		.no { ruby.bool_value(false) }
		.unrelated { ruby.object_value('NilClass', 'nil') }
	}
}

fn base_optional_string_value(value BaseOptionalString) ruby.Value {
	if value.present {
		return ruby.string_value(value.value)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.method_added(method_name)` at line 6.
pub fn ruby_base_l6_d1_self_method_added(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Base.method_added requires a method name')
	}
	declaring_type := if args.len > 1 { args[0].type_name } else { 'T::Types::Base' }
	base_method_added(declaring_type, args[args.len - 1].as_string()) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `recursively_valid?(obj)` at line 20.
pub fn ruby_base_l20_d2_recursively_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Base#recursively_valid? requires an object')
	}
	return ruby.bool_value(base_type_from_args(args).recursively_valid(args[1]) or {
		panic(err)
	})
}

// Ruby define_method `define_method(:valid?) do |_obj|` at line 24.
pub fn ruby_base_l24_d3_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Base#valid? requires an object')
	}
	return ruby.bool_value(base_type_from_args(args).valid(args[1]) or { panic(err) })
}

// Ruby method `subtype_of_single?(type)` at line 32.
pub fn ruby_base_l32_d4_subtype_of_single(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Base#subtype_of_single? requires another type')
	}
	receiver := base_type_from_args(args)
	other := base_type_from_value(args[1]) or { panic(err) }
	return base_subtype_boundary_value(receiver.subtype_of_single(other) or { panic(err) })
}

// Ruby define_method `define_method(:build_type) do` at line 38.
pub fn ruby_base_l38_d5_build_type(args ...ruby.Value) ruby.Value {
	base_type_from_args(args).build_type() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby define_method `define_method(:name) do` at line 43.
pub fn ruby_base_l43_d6_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(base_type_from_args(args).name() or { panic(err) })
}

// Ruby method `subtype_of?(t2)` at line 52.
pub fn ruby_base_l52_d7_subtype_of(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Base#subtype_of? requires another type')
	}
	receiver := base_type_from_args(args)
	other := base_type_from_value(args[1]) or { panic(err) }
	return base_subtype_boundary_value(receiver.subtype_of(other) or { panic(err) })
}

// Ruby method `to_s` at line 132.
pub fn ruby_base_l132_d8_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(base_type_from_args(args).to_s() or { panic(err) })
}

// Ruby method `describe_obj(obj)` at line 136.
pub fn ruby_base_l136_d9_describe_obj(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Base#describe_obj requires an object')
	}
	return ruby.string_value(base_type_from_args(args).describe_obj(args[1]))
}

// Ruby method `error_message_for_obj(obj)` at line 158.
pub fn ruby_base_l158_d10_error_message_for_obj(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Base#error_message_for_obj requires an object')
	}
	return base_optional_string_value(base_type_from_args(args).error_message_for_obj(args[1]) or {
		panic(err)
	})
}

// Ruby method `error_message_for_obj_recursive(obj)` at line 166.
pub fn ruby_base_l166_d11_error_message_for_obj_recursive(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Base#error_message_for_obj_recursive requires an object')
	}
	return base_optional_string_value(base_type_from_args(args).error_message_for_obj_recursive(args[1]) or {
		panic(err)
	})
}

// Ruby method `error_message(obj)` at line 174.
pub fn ruby_base_l174_d12_error_message(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Base#error_message requires an object')
	}
	return ruby.string_value(base_type_from_args(args).error_message(args[1]) or {
		panic(err)
	})
}

// Ruby method `validate!(obj)` at line 178.
pub fn ruby_base_l178_d13_validate(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Base#validate! requires an object')
	}
	base_type_from_args(args).validate(args[1]) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `hash` at line 185.
pub fn ruby_base_l185_d14_hash(args ...ruby.Value) ruby.Value {
	return ruby.int_value(i64(base_type_from_args(args).hash() or { panic(err) }))
}

// Ruby method `==(other)` at line 191.
pub fn ruby_base_l191_d15_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	other := base_type_from_value(args[1]) or { return ruby.bool_value(false) }
	return ruby.bool_value(base_type_from_args(args).equals(other) or { panic(err) })
}

// Ruby alias_method `alias_method :eql?, :==` at line 203.
pub fn ruby_base_l203_d16_eql(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	other := base_type_from_value(args[1]) or { return ruby.bool_value(false) }
	return ruby.bool_value(base_type_from_args(args).eql(other) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class Base
// 6:     def self.method_added(method_name)
// 7:       super(method_name)
// 8:       # What is now `subtype_of_single?` used to be named `subtype_of?`. Make sure people don't
// 9:       # override the wrong thing.
// 10:       #
// 11:       # NB: Outside of T::Types, we would enforce this by using `sig` and not declaring the method
// 12:       # as overridable, but doing so here would result in a dependency cycle.
// 13:       if method_name == :subtype_of? && self != T::Types::Base
// 14:         raise "`subtype_of?` should not be overridden. You probably want to override " \
// 15:               "`subtype_of_single?` instead."
// 16:       end
// 17:     end
// 18:
// 19:     # this will be redefined in certain subclasses
// 20:     def recursively_valid?(obj)
// 21:       valid?(obj)
// 22:     end
// 23:
// 24:     define_method(:valid?) do |_obj|
// 25:       raise NotImplementedError
// 26:     end
// 27:
// 28:     # @return [T::Boolean] This method must be implemented to return whether the subclass is a subtype
// 29:     # of `type`. This should only be called by `subtype_of?`, which guarantees that `type` will be
// 30:     # a "single" type, by which we mean it won't be a Union or an Intersection (c.f.
// 31:     # `isSubTypeSingle` in sorbet).
// 32:     private def subtype_of_single?(type)
// 33:       raise NotImplementedError
// 34:     end
// 35:
// 36:     # Force any lazy initialization that this type might need to do
// 37:     # It's unusual to call this directly; you probably want to call it indirectly via `T::Utils.run_all_sig_blocks`.
// 38:     define_method(:build_type) do
// 39:       raise NotImplementedError
// 40:     end
// 41:
// 42:     # Equality is based on name, so be sure the name reflects all relevant state when implementing.
// 43:     define_method(:name) do
// 44:       raise NotImplementedError
// 45:     end
// 46:
// 47:     # Mirrors ruby_typer::core::Types::isSubType
// 48:     # See https://git.corp.stripe.com/stripe-internal/ruby-typer/blob/9fc8ed998c04ac0b96592ae6bb3493b8a925c5c1/core/types/subtyping.cc#L912-L950
// 49:     #
// 50:     # This method cannot be overridden (see `method_added` above).
// 51:     # Subclasses only need to implement `subtype_of_single?`).
// 52:     def subtype_of?(t2)
// 53:       t1 = self
// 54:
// 55:       # Fast path over the isSubType mirror below: the dominant pair during
// 56:       # override validation is two plain Simples, which match none of the
// 57:       # branches in the walk. instance_of? (never
// 58:       # is_a?) so that any hypothetical Simple subclass takes the full walk,
// 59:       # and the raw subtype_of_single? result is returned unmodified
// 60:       # (Module#<= yields nil for unrelated modules, which callers observe).
// 61:       if t1.instance_of?(T::Types::Simple) && t2.instance_of?(T::Types::Simple)
// 62:         return subtype_of_single?(t2)
// 63:       end
// 64:
// 65:       if t2.is_a?(T::Private::Types::TypeAlias)
// 66:         t2 = t2.aliased_type
// 67:       end
// 68:
// 69:       if t2.is_a?(T::Types::Anything)
// 70:         return true
// 71:       end
// 72:
// 73:       if t1.is_a?(T::Private::Types::TypeAlias)
// 74:         return t1.aliased_type.subtype_of?(t2)
// 75:       end
// 76:
// 77:       if t1.is_a?(T::Types::TypeVariable) || t2.is_a?(T::Types::TypeVariable)
// 78:         # Generics are erased at runtime. Let's treat them like `T.untyped` for
// 79:         # the purpose of things like override checking.
// 80:         return true
// 81:       end
// 82:
// 83:       # pairs to cover: 1  (_, _)
// 84:       #                 2  (_, And)
// 85:       #                 3  (_, Or)
// 86:       #                 4  (And, _)
// 87:       #                 5  (And, And)
// 88:       #                 6  (And, Or)
// 89:       #                 7  (Or, _)
// 90:       #                 8  (Or, And)
// 91:       #                 9  (Or, Or)
// 92:
// 93:       # Note: order of cases here matters!
// 94:       if t1.is_a?(T::Types::Union) # 7, 8, 9
// 95:         # this will be incorrect if/when we have Type members
// 96:         return t1.types.all? { |t1_member| t1_member.subtype_of?(t2) }
// 97:       end
// 98:
// 99:       if t2.is_a?(T::Types::Intersection) # 2, 5
// 100:         # this will be incorrect if/when we have Type members
// 101:         return t2.types.all? { |t2_member| t1.subtype_of?(t2_member) }
// 102:       end
// 103:
// 104:       if t2.is_a?(T::Types::Union)
// 105:         if t1.is_a?(T::Types::Intersection) # 6
// 106:           # dropping either of parts eagerly make subtype test be too strict.
// 107:           # we have to try both cases, when we normally try only one
// 108:           return t2.types.any? { |t2_member| t1.subtype_of?(t2_member) } ||
// 109:               t1.types.any? { |t1_member| t1_member.subtype_of?(t2) }
// 110:         end
// 111:         return t2.types.any? { |t2_member| t1.subtype_of?(t2_member) } # 3
// 112:       end
// 113:
// 114:       if t1.is_a?(T::Types::Intersection) # 4
// 115:         # this will be incorrect if/when we have Type members
// 116:         return t1.types.any? { |t1_member| t1_member.subtype_of?(t2) }
// 117:       end
// 118:
// 119:       # 1; Start with some special cases
// 120:       if t1.is_a?(T::Private::Types::Void)
// 121:         return t2.is_a?(T::Private::Types::Void)
// 122:       end
// 123:
// 124:       if t1.is_a?(T::Types::Untyped) || t2.is_a?(T::Types::Untyped)
// 125:         return true
// 126:       end
// 127:
// 128:       # Rest of (1)
// 129:       subtype_of_single?(t2)
// 130:     end
// 131:
// 132:     def to_s
// 133:       name
// 134:     end
// 135:
// 136:     def describe_obj(obj)
// 137:       # Would be redundant to print class and value in these common cases.
// 138:       case obj
// 139:       when nil, true, false
// 140:         return "type #{obj.class}"
// 141:       end
// 142:
// 143:       # In rare cases, obj.inspect may fail, or be undefined, so rescue.
// 144:       begin
// 145:         # Default inspect behavior of, eg; `#<Object:0x0...>` is ugly; just print the hash instead, which is more concise/readable.
// 146:         if obj.method(:inspect).owner == Kernel
// 147:           "type #{obj.class} with hash #{obj.hash}"
// 148:         elsif T::Configuration.include_value_in_type_errors?
// 149:           "type #{obj.class} with value #{T::Utils.string_truncate_middle(obj.inspect, 30, 30)}"
// 150:         else
// 151:           "type #{obj.class}"
// 152:         end
// 153:       rescue StandardError, SystemStackError
// 154:         "type #{obj.class} with unprintable value"
// 155:       end
// 156:     end
// 157:
// 158:     def error_message_for_obj(obj)
// 159:       if valid?(obj)
// 160:         nil
// 161:       else
// 162:         error_message(obj)
// 163:       end
// 164:     end
// 165:
// 166:     def error_message_for_obj_recursive(obj)
// 167:       if recursively_valid?(obj)
// 168:         nil
// 169:       else
// 170:         error_message(obj)
// 171:       end
// 172:     end
// 173:
// 174:     private def error_message(obj)
// 175:       "Expected type #{self.name}, got #{describe_obj(obj)}"
// 176:     end
// 177:
// 178:     def validate!(obj)
// 179:       err = error_message_for_obj(obj)
// 180:       raise TypeError.new(err) if err
// 181:     end
// 182:
// 183:     ### Equality methods (necessary for deduping types with `uniq`)
// 184:
// 185:     def hash
// 186:       name.hash
// 187:     end
// 188:
// 189:     # Type equivalence, defined by serializing the type to a string (with
// 190:     # `#name`) and comparing the resulting strings for equality.
// 191:     def ==(other)
// 192:       case other
// 193:       when T::Types::Base
// 194:         # Performance fast path: pooled and memoized type instances (e.g. the
// 195:         # results of repeated T.nilable(X) calls) are the same object, so they
// 196:         # can compare equal without computing and comparing their names.
// 197:         other.equal?(self) || other.name == self.name
// 198:       else
// 199:         false
// 200:       end
// 201:     end
// 202:
// 203:     alias_method :eql?, :==
// 204:   end
// 205: end
