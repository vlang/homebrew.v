module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/casts.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CastFailure {
pub:
	message     string
	kind        string
	value       brew_runtime.Value
	expected    brew_runtime.Value
	caller_path string
}

pub type CastErrorHandler = fn(CastFailure)

fn cast_type_name(type_value brew_runtime.Value) string {
	return type_value.attribute('name') or {
		type_value.attribute('raw_type') or { type_value.as_string() }
	}
}

fn cast_value_matches(value brew_runtime.Value, type_value brew_runtime.Value,
	recursive bool) bool {
	if type_value.type_name in ['T::Types::Anything', 'T::Types::Untyped'] {
		return true
	}
	if type_value.type_name == 'T::Private::Types::TypeAlias' {
		aliased := type_value.map_data['aliased_type'] or { return true }
		return cast_value_matches(value, aliased, recursive)
	}
	if type_value.type_name in ['T::Types::Union', 'T::Private::Types::SimplePairUnion'] {
		return type_value.array_data.any(cast_value_matches(value, it, recursive))
	}
	if recursive && type_value.type_name.starts_with('T::Types::Typed') && value.type_name in [
		'Array',
		'Set',
	] {
		element_type := type_value.map_data['type'] or { return false }
		return value.array_data.all(cast_value_matches(it, element_type, true))
	}
	expected := if type_value.type_name in ['Class', 'Module'] {
		type_value.as_string()
	} else {
		type_value.attribute('raw_type') or { type_value.as_string() }
	}
	if value.type_name == expected {
		return true
	}
	ancestors := value.attribute('ancestors') or { return false }
	return ancestors.split(',').map(it.trim_space()).any(it == expected)
}

pub fn cast_value(value brew_runtime.Value, type_value brew_runtime.Value, cast_method string,
	recursive bool, caller_path string, handler CastErrorHandler) brew_runtime.Value {
	if cast_value_matches(value, type_value, recursive) {
		return value
	}
	error_message := 'Expected type ${cast_type_name(type_value)}, got type ${value.type_name}'
	message := '${cast_method}: ${error_message}\nCaller: ${caller_path}'
	handler(CastFailure{
		message: message
		kind: cast_method
		value: value
		expected: type_value
		caller_path: caller_path
	})
	return value
}

fn cast_noop_handler(_ CastFailure) {}

fn cast_from_boundary(args []brew_runtime.Value, recursive bool) brew_runtime.Value {
	if args.len < 3 {
		panic('Casts.cast requires value, type, and cast method')
	}
	caller_path := if args.len > 3 { args[3].as_string() } else { '<unknown>:0' }
	return cast_value(args[0], args[1], args[2].as_string(), recursive, caller_path, cast_noop_handler)
}

// Ruby method `self.cast(value, type, cast_method)` at line 6.
pub fn ruby_casts_l6_d1_self_cast(args ...brew_runtime.Value) brew_runtime.Value {
	return cast_from_boundary(args, false)
}

// Ruby method `self.cast_recursive(value, type, cast_method)` at line 49.
pub fn ruby_casts_l49_d2_self_cast_recursive(args ...brew_runtime.Value) brew_runtime.Value {
	return cast_from_boundary(args, true)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private
// 5:   module Casts
// 6:     def self.cast(value, type, cast_method)
// 7:       begin
// 8:         # Every caller (T.cast/let/bind/assert_type! in _types.rb) inlines the
// 9:         # value check for the two dominant shapes -- a Module literal and the
// 10:         # SimplePairUnion that `T.nilable(SomeModule)` produces -- and only
// 11:         # falls through to here when that check already failed. So skip
// 12:         # straight to coercing: re-checking `value.is_a?(type)` /
// 13:         # `type.valid?(value)` here would always be false.
// 14:         case type
// 15:         when ::Module
// 16:           coerced_type = T::Types::Simple::Private::Pool.type_for_module(type)
// 17:         when T::Types::Base
// 18:           # Mirrors the T::Types::Base branch of coerce_and_check_module_types,
// 19:           # kept inline to avoid its call frame for every already-coerced type.
// 20:           coerced_type =
// 21:             case type
// 22:             when T::Private::Types::TypeAlias
// 23:               type.aliased_type
// 24:             else
// 25:               type
// 26:             end
// 27:         else
// 28:           coerced_type = T::Utils::Private.coerce_and_check_module_types(type, value, true)
// 29:           return value unless coerced_type
// 30:         end
// 31:
// 32:         error = coerced_type.error_message_for_obj(value)
// 33:         return value unless error
// 34:
// 35:         caller_loc = T.must(caller_locations(2..2)).first
// 36:
// 37:         suffix = "Caller: #{T.must(caller_loc).path}:#{T.must(caller_loc).lineno}"
// 38:
// 39:         raise TypeError.new("#{cast_method}: #{error}\n#{suffix}")
// 40:       rescue TypeError => e # raise into rescue to ensure e.backtrace is populated
// 41:         T::Configuration.inline_type_error_handler(e, {kind: cast_method, value: value, type: type})
// 42:         value
// 43:       end
// 44:     end
// 45:
// 46:     # there's a lot of shared logic with the above one, but factoring
// 47:     # it out like this makes it easier to hopefully one day delete
// 48:     # this one
// 49:     def self.cast_recursive(value, type, cast_method)
// 50:       begin
// 51:         error = T::Utils.coerce(type).error_message_for_obj_recursive(value)
// 52:         return value unless error
// 53:
// 54:         caller_loc = T.must(caller_locations(2..2)).first
// 55:
// 56:         suffix = "Caller: #{T.must(caller_loc).path}:#{T.must(caller_loc).lineno}"
// 57:
// 58:         raise TypeError.new("#{cast_method}: #{error}\n#{suffix}")
// 59:       rescue TypeError => e # raise into rescue to ensure e.backtrace is populated
// 60:         T::Configuration.inline_type_error_handler(e, {kind: cast_method, value: value, type: type})
// 61:         value
// 62:       end
// 63:     end
// 64:   end
// 65: end
