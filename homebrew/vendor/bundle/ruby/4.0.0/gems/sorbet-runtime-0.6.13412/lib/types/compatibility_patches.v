module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/compatibility_patches.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CompatibilityInvocation {
pub:
	result          ruby.Value
	method          ruby.Value
	force_signature bool
}

pub struct CompatibilityLetPlan {
pub:
	result              ruby.Value
	name                ruby.Value
	method              ruby.Value
	redefine_outer      bool
	suppress_method_add bool
}

fn compatibility_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn compatibility_method(container ruby.Value, name ruby.Value) ?ruby.Value {
	clean_name := name.as_string().trim_string_left(':')
	if method := container.map_data[clean_name] {
		return method
	}
	if method := container.map_data[':${clean_name}'] {
		return method
	}
	return none
}

pub fn compatibility_observe(recorder ruby.Value, method_name ruby.Value,
	super_result ruby.Value) CompatibilityInvocation {
	klass := recorder.map_data['klass'] or { recorder }
	method := compatibility_method(klass, method_name) or { compatibility_nil_value() }
	return CompatibilityInvocation{
		result: super_result
		method: method
		force_signature: method.type_name != 'NilClass'
	}
}

pub fn compatibility_method_double(object ruby.Value, method_name ruby.Value,
	super_result ruby.Value) CompatibilityInvocation {
	method := compatibility_method(object, method_name) or { compatibility_nil_value() }
	return CompatibilityInvocation{
		result: super_result
		method: method
		force_signature: method.type_name != 'NilClass'
	}
}

pub fn compatibility_let(owner ruby.Value, name ruby.Value,
	super_result ruby.Value, active_declaration ruby.Value) CompatibilityLetPlan {
	method := compatibility_method(owner, name) or { compatibility_nil_value() }
	active := active_declaration.type_name != 'NilClass'
	return CompatibilityLetPlan{
		result: super_result
		name: name
		method: method
		redefine_outer: active && method.type_name != 'NilClass'
		suppress_method_add: true
	}
}

pub fn compatibility_define_method(owner ruby.Value, name ruby.Value,
	method ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: 'UnboundMethod'
		repr: '${owner.as_string()}#${name.as_string().trim_string_left(':')}'
		map_data: {
			'owner':  owner
			'method': method
		}
		attributes: {
			'name':      name.as_string().trim_string_left(':')
			'redefined': 'true'
		}
	}
}

fn compatibility_signature_method(method ruby.Value) ?ruby.Value {
	if signature_method := method.map_data['signature_method'] {
		return signature_method
	}
	return none
}

pub fn compatibility_arity(method ruby.Value, super_arity i64) i64 {
	if super_arity != -1 || method.type_name == 'Proc' {
		return super_arity
	}
	signature_method := compatibility_signature_method(method) or { return super_arity }
	return signature_method.attribute('arity') or { super_arity.str() }.i64()
}

pub fn compatibility_source_location(method ruby.Value,
	super_location ruby.Value) ruby.Value {
	signature_method := compatibility_signature_method(method) or { return super_location }
	return signature_method.map_data['source_location'] or { super_location }
}

pub fn compatibility_parameters(method ruby.Value,
	super_parameters ruby.Value) ruby.Value {
	signature_method := compatibility_signature_method(method) or { return super_parameters }
	return signature_method.map_data['parameters'] or { super_parameters }
}

// Ruby method `observe!(method_name)` at line 29.
pub fn ruby_compatibility_patches_l29_d1_observe(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('RSpec Recorder#observe! requires a receiver and method name')
	}
	super_result := if args.len > 2 { args[2] } else { compatibility_nil_value() }
	return compatibility_observe(args[0], args[1], super_result).result
}

// Ruby method `initialize(object, method_name, proxy)` at line 40.
pub fn ruby_compatibility_patches_l40_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('RSpec MethodDouble#initialize requires a receiver, object, method name, and proxy')
	}
	super_result := if args.len > 4 { args[4] } else { compatibility_nil_value() }
	return compatibility_method_double(args[1], args[2], super_result).result
}

// Ruby method `let(name, &block)` at line 62.
pub fn ruby_compatibility_patches_l62_d3_let(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('RSpec MemoizedHelpers#let requires a receiver and name')
	}
	super_result := if args.len > 3 { args[3] } else { args[1] }
	active := if args.len > 4 { args[4] } else { compatibility_nil_value() }
	return compatibility_let(args[0], args[1], super_result, active).result
}

// Ruby define_method `define_method(name, method)` at line 85.
pub fn ruby_compatibility_patches_l85_d4_name(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('RSpec compatibility define_method requires an owner, name, and method')
	}
	_ = compatibility_define_method(args[0], args[1], args[2])
	return args[1]
}

// Ruby method `arity` at line 119.
pub fn ruby_compatibility_patches_l119_d5_arity(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MethodExtensions#arity requires a receiver')
	}
	super_arity := if args.len > 1 {
		args[1].as_int() or { panic(err.msg()) }
	} else {
		args[0].attribute('arity') or { '-1' }.i64()
	}
	return ruby.int_value(compatibility_arity(args[0], super_arity))
}

// Ruby method `source_location` at line 126.
pub fn ruby_compatibility_patches_l126_d6_source_location(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MethodExtensions#source_location requires a receiver')
	}
	super_location := if args.len > 1 {
		args[1]
	} else {
		args[0].map_data['source_location'] or { compatibility_nil_value() }
	}
	return compatibility_source_location(args[0], super_location)
}

// Ruby method `parameters` at line 131.
pub fn ruby_compatibility_patches_l131_d7_parameters(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MethodExtensions#parameters requires a receiver')
	}
	super_parameters := if args.len > 1 {
		args[1]
	} else {
		args[0].map_data['parameters'] or { ruby.array_value([]) }
	}
	return compatibility_parameters(args[0], super_parameters)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: ignore
// 3:
// 4: # Work around an interaction bug with sorbet-runtime and rspec-mocks,
// 5: # which occurs when using message expectations (*_any_instance_of,
// 6: # expect, allow) and and_call_original.
// 7: #
// 8: # When a sig is defined, sorbet-runtime will replace the sigged method
// 9: # with a wrapper that, upon first invocation, re-wraps the method with a faster
// 10: # implementation.
// 11: #
// 12: # When expect_any_instance_of is used, rspec stores a reference to the first wrapper,
// 13: # to be restored later.
// 14: #
// 15: # The first wrapper is invoked as part of the test and sorbet-runtime replaces
// 16: # the method definition with the second wrapper.
// 17: #
// 18: # But when mocks are cleaned up, rspec restores back to the first wrapper.
// 19: # Upon subsequent invocations, the first wrapper is called, and sorbet-runtime
// 20: # throws a runtime error, since this is an unexpected state.
// 21: #
// 22: # We work around this by forcing re-wrapping before rspec stores a reference
// 23: # to the method.
// 24: if defined? ::RSpec::Mocks
// 25:   module T
// 26:     module CompatibilityPatches
// 27:       module RSpecCompatibility
// 28:         module RecorderExtensions
// 29:           def observe!(method_name)
// 30:             if @klass.method_defined?(method_name.to_sym)
// 31:               method = @klass.instance_method(method_name.to_sym)
// 32:               T::Private::Methods.maybe_run_sig_block_for_method(method)
// 33:             end
// 34:             super(method_name)
// 35:           end
// 36:         end
// 37:         ::RSpec::Mocks::AnyInstance::Recorder.prepend(RecorderExtensions) if defined?(::RSpec::Mocks::AnyInstance::Recorder)
// 38:
// 39:         module MethodDoubleExtensions
// 40:           def initialize(object, method_name, proxy)
// 41:             if ::Kernel.instance_method(:respond_to?).bind(object).call(method_name, true) # rubocop:disable Performance/BindCall
// 42:               method = ::RSpec::Support.method_handle_for(object, method_name)
// 43:               T::Private::Methods.maybe_run_sig_block_for_method(method)
// 44:             end
// 45:             super(object, method_name, proxy)
// 46:           end
// 47:         end
// 48:         ::RSpec::Mocks::MethodDouble.prepend(MethodDoubleExtensions) if defined?(::RSpec::Mocks::MethodDouble)
// 49:       end
// 50:     end
// 51:   end
// 52: end
// 53:
// 54: # Allow using `sig {...}` on top of a `let`-defined method in an RSpec example group
// 55: if defined? ::RSpec::Core::MemoizedHelpers::ClassMethods
// 56:   module T
// 57:     module CompatibilityPatches
// 58:       module RSpecCompatibility
// 59:         module MemoizedHelpers
// 60:           # `let!`, `subject`, and `subject!` are implemented by dispatching to
// 61:           # `let`, so this should cover those methods too.
// 62:           def let(name, &block)
// 63:             res = T::Private::DeclState.current.without_on_method_added do
// 64:               # Allow the `let`-defined methods to be defined
// 65:               super
// 66:             end
// 67:
// 68:             return res unless T::Private::DeclState.current.active_declaration
// 69:
// 70:             # Force the `sig` to attach to the outer `let`-defined method,
// 71:             # not the one inside the `LetDefinitions` module. Re-running
// 72:             # `define_method` with the method we grab via reflection there
// 73:             # triggers the `method_added`, which allows the active_declaration
// 74:             # to be consumed.
// 75:             #
// 76:             # Unfortunately, this means that the runtime checks are not
// 77:             # memoized (but they never were).
// 78:             #
// 79:             # (An alternative approach of pretending that the `sig` was actually
// 80:             # written inside the `LetDefinitions` module didn't work, because
// 81:             # things like `sig {override}` broke: the `LetDefinitions` module
// 82:             # has no ancestors and thus does not override anything)
// 83:             method = instance_method(name)
// 84:             remove_method(name)
// 85:             define_method(name, method)
// 86:
// 87:             res
// 88:           end
// 89:         end
// 90:         ::RSpec::Core::MemoizedHelpers::ClassMethods.prepend(MemoizedHelpers)
// 91:       end
// 92:     end
// 93:   end
// 94: end
// 95:
// 96: # Work around for sorbet-runtime wrapped methods.
// 97: #
// 98: # When a sig is defined, sorbet-runtime will replace the sigged method
// 99: # with a wrapper. Those wrapper methods look like `foo(*args, &blk)`
// 100: # so that wrappers can handle and pass on all the arguments supplied.
// 101: #
// 102: # However, that creates a problem with runtime reflection on the methods,
// 103: # since when a sigged method is introspected, it will always return its
// 104: # `arity` as `-1`, its `parameters` as `[[:rest, :args], [:block, :blk]]`,
// 105: # and its `source_location` as `[<some_file_in_sorbet>, <some_line_number>]`.
// 106: #
// 107: # This might be a problem for some applications that rely on getting the
// 108: # correct information from these methods.
// 109: #
// 110: # This compatibility module, when prepended to the `Method` class, would fix
// 111: # the return values of `arity`, `parameters` and `source_location`.
// 112: #
// 113: # @example
// 114: #   require 'sorbet-runtime'
// 115: #   ::Method.prepend(T::CompatibilityPatches::MethodExtensions)
// 116: module T
// 117:   module CompatibilityPatches
// 118:     module MethodExtensions
// 119:       def arity
// 120:         arity = super
// 121:         return arity if arity != -1 || self.is_a?(Proc)
// 122:         sig = T::Private::Methods.signature_for_method(self)
// 123:         sig ? sig.method.arity : arity
// 124:       end
// 125:
// 126:       def source_location
// 127:         sig = T::Private::Methods.signature_for_method(self)
// 128:         sig ? sig.method.source_location : super
// 129:       end
// 130:
// 131:       def parameters
// 132:         sig = T::Private::Methods.signature_for_method(self)
// 133:         sig ? sig.method.parameters : super
// 134:       end
// 135:     end
// 136:   end
// 137: end
