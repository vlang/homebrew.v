module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/def_mods.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum DefModifierKind {
	abstract_
	override_
	final_
	overridable
}

pub struct DefModifierRequest {
pub:
	owner              brew_runtime.Value
	method_name        brew_runtime.Value
	kind               DefModifierKind
	allow_incompatible brew_runtime.Value
}

pub struct DefModifierResult {
pub:
	method_name brew_runtime.Value
	declaration brew_runtime.Value
}

fn def_modifier_name(kind DefModifierKind) string {
	return match kind {
		.abstract_ { 'abstract' }
		.override_ { 'override' }
		.final_ { 'final' }
		.overridable { 'overridable' }
	}
}

// apply_def_modifier is the standalone form of Methods.declare_* used by these
// public syntax helpers. The owner carries its most recently consumed sig in
// map_data['previous_declaration'], which keeps the Ruby declaration state
// explicit at this vendored module boundary.
pub fn apply_def_modifier(request DefModifierRequest) !DefModifierResult {
	dsl_name := def_modifier_name(request.kind)
	if request.method_name.type_name != 'Symbol' {
		return error('${dsl_name} accepts a Symbol, got ${request.method_name.type_name}')
	}
	previous := request.owner.map_data['previous_declaration'] or {
		return error('You must declare a `sig` before using `${dsl_name}` on the method `${request.method_name.as_string().trim_string_left(':')}`')
	}
	if previous.map_data['block'] or { brew_runtime.object_value('NilClass', 'nil') }.type_name != 'Proc' {
		return error('Cannot call `${dsl_name} ${request.method_name.as_string()}`, because the sig block has already run')
	}
	method_name := request.method_name.as_string().trim_string_left(':')
	previous_method := previous.attribute('method_name') or { '' }.trim_string_left(':')
	previous_owner := previous.map_data['owner'] or { request.owner }
	owner_matches := previous_owner.as_string() == request.owner.as_string() || previous_owner.attribute('attached_object') or { '' } == request.owner.as_string()
	if !owner_matches || previous_method != method_name {
		return error("Can only call `${dsl_name} ${request.method_name.as_string()}` for the previously sig'd method. Expected: ${previous_owner.as_string()}#${previous_method}")
	}
	if previous.attribute(dsl_name) or { 'false' } == 'true' {
		return error('Cannot call `${dsl_name}` twice for the method `${method_name}`')
	}
	mut attributes := previous.attributes.clone()
	attributes[dsl_name] = 'true'
	if request.kind == .override_ {
		attributes['allow_incompatible'] = request.allow_incompatible.as_string()
	}
	return DefModifierResult{
		method_name: request.method_name
		declaration: brew_runtime.Value{
			...previous
			attributes: attributes
		}
	}
}

fn def_modifier_boundary(args []brew_runtime.Value, kind DefModifierKind) brew_runtime.Value {
	if args.len < 2 {
		panic('${def_modifier_name(kind)} requires a receiver and method name')
	}
	allow_incompatible := if kind == .override_ && args.len > 2 {
		args[2]
	} else {
		brew_runtime.bool_value(false)
	}
	return apply_def_modifier(DefModifierRequest{
		owner: args[0]
		method_name: args[1]
		kind: kind
		allow_incompatible: allow_incompatible
	}) or { panic(err.msg()) }.method_name
}

// Ruby method `abstract(method_name)` at line 22.
pub fn ruby_def_mods_l22_d1_abstract(args ...brew_runtime.Value) brew_runtime.Value {
	return def_modifier_boundary(args, .abstract_)
}

// Ruby method `override(method_name, allow_incompatible: false)` at line 34.
pub fn ruby_def_mods_l34_d2_override(args ...brew_runtime.Value) brew_runtime.Value {
	return def_modifier_boundary(args, .override_)
}

// Ruby method `final(method_name)` at line 46.
pub fn ruby_def_mods_l46_d3_final(args ...brew_runtime.Value) brew_runtime.Value {
	return def_modifier_boundary(args, .final_)
}

// Ruby method `overridable(method_name)` at line 58.
pub fn ruby_def_mods_l58_d4_overridable(args ...brew_runtime.Value) brew_runtime.Value {
	return def_modifier_boundary(args, .overridable)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Optional mixin providing `abstract`, `override`, `overridable`, and `final`
// 5: # as method-level DSL keywords. Use with `extend T::DefMods`.
// 6: #
// 7: # These are alternatives to writing modifiers inside a `sig { ... }` block:
// 8: #
// 9: #   sig { void }
// 10: #   abstract def foo; end
// 11: #
// 12: # is equivalent to:
// 13: #
// 14: #   sig { abstract.void }
// 15: #   def foo; end
// 16: #
// 17: # They all return the method name, so that they can be chained with methods
// 18: # like `private`. However, unlike those methods, these methods use the `sig`
// 19: # declaration to discover the most-recently-defined method, instead of needing
// 20: # `*_class_method` variants, like `private_class_method`.
// 21: module T::DefMods
// 22:   def abstract(method_name)
// 23:     Kernel.raise TypeError.new("abstract accepts a Symbol, got #{method_name.class}") unless method_name.is_a?(Symbol)
// 24:
// 25:     begin
// 26:       T::Private::Methods.declare_abstract(T.unsafe(self), method_name)
// 27:     rescue T::Private::Methods::DeclBuilder::BuilderError => e
// 28:       T::Configuration.sig_builder_error_handler(e, Kernel.caller_locations(1, 1)&.first)
// 29:     end
// 30:
// 31:     method_name
// 32:   end
// 33:
// 34:   def override(method_name, allow_incompatible: false)
// 35:     Kernel.raise TypeError.new("override accepts a Symbol, got #{method_name.class}") unless method_name.is_a?(Symbol)
// 36:
// 37:     begin
// 38:       T::Private::Methods.declare_override(T.unsafe(self), method_name, allow_incompatible: allow_incompatible)
// 39:     rescue T::Private::Methods::DeclBuilder::BuilderError => e
// 40:       T::Configuration.sig_builder_error_handler(e, Kernel.caller_locations(1, 1)&.first)
// 41:     end
// 42:
// 43:     method_name
// 44:   end
// 45:
// 46:   def final(method_name)
// 47:     Kernel.raise TypeError.new("final accepts a Symbol, got #{method_name.class}") unless method_name.is_a?(Symbol)
// 48:
// 49:     begin
// 50:       T::Private::Methods.declare_final(T.unsafe(self), method_name)
// 51:     rescue T::Private::Methods::DeclBuilder::BuilderError => e
// 52:       T::Configuration.sig_builder_error_handler(e, Kernel.caller_locations(1, 1)&.first)
// 53:     end
// 54:
// 55:     method_name
// 56:   end
// 57:
// 58:   def overridable(method_name)
// 59:     Kernel.raise TypeError.new("overridable accepts a Symbol, got #{method_name.class}") unless method_name.is_a?(Symbol)
// 60:
// 61:     begin
// 62:       T::Private::Methods.declare_overridable(T.unsafe(self), method_name)
// 63:     rescue T::Private::Methods::DeclBuilder::BuilderError => e
// 64:       T::Configuration.sig_builder_error_handler(e, Kernel.caller_locations(1, 1)&.first)
// 65:     end
// 66:
// 67:     method_name
// 68:   end
// 69: end
