module abstract

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/abstract/validate.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct AbstractValidationMethod {
pub:
	name              string
	owner             string
	source_location   string
	mode              string
	effective_mode    string
	visibility        string
	signature_owner   string
	has_signature     bool
	override_error    string
	concrete_ancestor bool
}

pub struct AbstractValidationModule {
pub:
	name                    string
	abstract_type           string
	allows_abstract_methods bool
	is_singleton_class      bool
	methods                 []AbstractValidationMethod
}

pub fn describe_abstract_method(method AbstractValidationMethod, show_owner bool) string {
	location := if method.source_location == '' {
		'<unknown location>'
	} else {
		method.source_location
	}
	owner := if show_owner { ' declared in ${method.owner}' } else { '' }
	return '    * `${method.name}`${owner} at ${location}'
}

fn validation_methods_named(mod AbstractValidationModule, names []string) []AbstractValidationMethod {
	return mod.methods.filter(it.name in names)
}

pub fn validate_interface_all_abstract(mod AbstractValidationModule, method_names []string) ! {
	violations := validation_methods_named(mod, method_names).filter(it.mode.trim_string_left(':') != 'abstract').map(describe_abstract_method(it, false))
	if violations.len > 0 {
		return error('`${mod.name}` is declared as an interface, but the following methods are not declared with `abstract`:\n${violations.join('\n')}')
	}
}

pub fn validate_interface_all_public(mod AbstractValidationModule, method_names []string) ! {
	violations := validation_methods_named(mod, method_names).filter(it.visibility != 'public').map(describe_abstract_method(it, false))
	if violations.len > 0 {
		return error('All methods on an interface must be public. If you intend to have non-public methods, declare your class/module using `abstract!` instead of `interface!`. The following methods on `${mod.name}` are not public: \n${violations.join('\n')}')
	}
}

pub fn validate_interface(mod AbstractValidationModule) ! {
	names := mod.methods.map(it.name)
	validate_interface_all_abstract(mod, names)!
	validate_interface_all_public(mod, names)!
}

pub fn validate_abstract_module(mod AbstractValidationModule) ! {
	if mod.abstract_type.trim_string_left(':') == 'interface' {
		validate_interface(mod)!
	}
}

pub fn validate_abstract_subclass(mod AbstractValidationModule) ! {
	mut unimplemented := []string{}
	for method in mod.methods.filter(it.mode.trim_string_left(':') == 'abstract') {
		effective_mode := if method.effective_mode == '' {
			method.mode
		} else {
			method.effective_mode
		}
		if effective_mode.trim_string_left(':') == 'abstract' && !method.concrete_ancestor {
			if !mod.allows_abstract_methods {
				unimplemented << describe_abstract_method(method, true)
			}
			continue
		}
		if method.has_signature && method.signature_owner == mod.name {
			continue
		}
		if !method.has_signature && method.mode.trim_string_left(':') != 'abstract' {
			continue
		}
		if method.mode.trim_string_left(':') == 'abstract' && !method.has_signature {
			return error('Method being abstract must imply it has a signature')
		}
		if method.override_error != '' {
			return error(method.override_error)
		}
	}
	if unimplemented.len > 0 {
		method_type := if mod.is_singleton_class { 'class' } else { 'instance' }
		return error('Missing implementation for abstract ${method_type} method(s) in ${mod.name}:\n${unimplemented.join('\n')}\nIf ${mod.name} is meant to be an abstract class/module, you can call `abstract!` or `interface!`. Otherwise, you must implement the method(s).')
	}
}

fn abstract_validation_method_from_value(value brew_runtime.Value) AbstractValidationMethod {
	return AbstractValidationMethod{
		name: value.attribute('name') or { value.as_string() }
		owner: value.attribute('owner') or { '' }
		source_location: value.attribute('source_location') or { '' }
		mode: value.attribute('mode') or { '' }
		effective_mode: value.attribute('effective_mode') or { value.attribute('mode') or { '' } }
		visibility: value.attribute('visibility') or { 'public' }
		signature_owner: value.attribute('signature_owner') or { '' }
		has_signature: value.attribute('has_signature') or { 'false' } == 'true'
		override_error: value.attribute('override_error') or { '' }
		concrete_ancestor: value.attribute('concrete_ancestor') or { 'false' } == 'true'
	}
}

fn abstract_validation_module_from_value(value brew_runtime.Value) AbstractValidationModule {
	methods_value := value.map_data['methods'] or { brew_runtime.array_value(value.array_data) }
	return AbstractValidationModule{
		name: value.as_string()
		abstract_type: value.attribute('abstract_type') or { '' }
		allows_abstract_methods: value.attribute('can_have_abstract_methods') or { 'false' } == 'true'
		is_singleton_class: value.attribute('singleton_class') or { 'false' } == 'true'
		methods: (methods_value.as_array() or { []brew_runtime.Value{} }).map(abstract_validation_method_from_value(it))
	}
}

fn abstract_validation_names(args []brew_runtime.Value, mod AbstractValidationModule) []string {
	if args.len < 2 {
		return mod.methods.map(it.name)
	}
	return args[1].as_string_array() or { args[1].as_array() or { []brew_runtime.Value{} }.map(it.as_string()) }
}

// Ruby method `self.validate_abstract_module(mod)` at line 10.
pub fn ruby_validate_l10_d1_self_validate_abstract_module(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Validate.validate_abstract_module requires a module')
	}
	validate_abstract_module(abstract_validation_module_from_value(args[0])) or { panic(err.msg()) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.validate_subclass(mod)` at line 17.
pub fn ruby_validate_l17_d2_self_validate_subclass(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Validate.validate_subclass requires a module')
	}
	validate_abstract_subclass(abstract_validation_module_from_value(args[0])) or {
		panic(err.msg())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.validate_interface_all_abstract(mod, method_names)` at line 79.
pub fn ruby_validate_l79_d3_self_validate_interface_all_abstract(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Validate.validate_interface_all_abstract requires a module')
	}
	mod := abstract_validation_module_from_value(args[0])
	validate_interface_all_abstract(mod, abstract_validation_names(args, mod)) or { panic(err.msg()) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.validate_interface(mod)` at line 93.
pub fn ruby_validate_l93_d4_self_validate_interface(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Validate.validate_interface requires a module')
	}
	validate_interface(abstract_validation_module_from_value(args[0])) or { panic(err.msg()) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.validate_interface_all_public(mod, method_names)` at line 99.
pub fn ruby_validate_l99_d5_self_validate_interface_all_public(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Validate.validate_interface_all_public requires a module')
	}
	mod := abstract_validation_module_from_value(args[0])
	validate_interface_all_public(mod, abstract_validation_names(args, mod)) or { panic(err.msg()) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.describe_method(method, show_owner: true)` at line 113.
pub fn ruby_validate_l113_d6_self_describe_method(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Validate.describe_method requires a method')
	}
	show_owner := if args.len > 1 { args[1].as_bool() or { true } } else { true }
	return brew_runtime.string_value(describe_abstract_method(abstract_validation_method_from_value(args[0]), show_owner))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Abstract::Validate
// 5:   Abstract = T::Private::Abstract
// 6:   AbstractUtils = T::AbstractUtils
// 7:   Methods = T::Private::Methods
// 8:   SignatureValidation = T::Private::Methods::SignatureValidation
// 9:
// 10:   def self.validate_abstract_module(mod)
// 11:     type = Abstract::Data.get(mod, :abstract_type)
// 12:     validate_interface(mod) if :interface == type
// 13:   end
// 14:
// 15:   # Validates a class/module with an abstract class/module as an ancestor. This must be called
// 16:   # after all methods on `mod` have been defined.
// 17:   def self.validate_subclass(mod)
// 18:     can_have_abstract_methods = !T::Private::Abstract::Data.get(mod, :can_have_abstract_methods)
// 19:     unimplemented_methods = []
// 20:
// 21:     T::AbstractUtils.declared_abstract_methods_for(mod).each do |abstract_method|
// 22:       implementation_method = mod.instance_method(abstract_method.name)
// 23:       if AbstractUtils.abstract_method?(implementation_method)
// 24:         # Note that when we end up here, implementation_method might not be the same as
// 25:         # abstract_method; the latter could've been overridden by another abstract method. In either
// 26:         # case, if we have a concrete definition in an ancestor, that will end up as the effective
// 27:         # implementation (see CallValidation.wrap_method_if_needed), so that's what we'll validate
// 28:         # against.
// 29:         implementation_method = T.unsafe(nil)
// 30:         mod.ancestors.each do |ancestor|
// 31:           if ancestor.instance_methods.include?(abstract_method.name)
// 32:             method = ancestor.instance_method(abstract_method.name)
// 33:             T::Private::Methods.maybe_run_sig_block_for_method(method)
// 34:             if !T::AbstractUtils.abstract_method?(method)
// 35:               implementation_method = method
// 36:               break
// 37:             end
// 38:           end
// 39:         end
// 40:         if !implementation_method
// 41:           # There's no implementation
// 42:           if can_have_abstract_methods
// 43:             unimplemented_methods << describe_method(abstract_method)
// 44:           end
// 45:           next # Nothing to validate
// 46:         end
// 47:       end
// 48:
// 49:       implementation_signature = Methods.signature_for_method(implementation_method)
// 50:       # When a signature exists and the method is defined directly on `mod`, we skip the validation
// 51:       # here, because it will have already been done when the method was defined (by
// 52:       # T::Private::Methods._on_method_added).
// 53:       next if implementation_signature&.owner == mod
// 54:
// 55:       # We validate the remaining cases here: (a) methods defined directly on `mod` without a
// 56:       # signature and (b) methods from ancestors (note that these ancestors can come before or
// 57:       # after the abstract module in the inheritance chain -- the former coming from
// 58:       # walking `mod.ancestors` above).
// 59:       abstract_signature = Methods.signature_for_method(abstract_method) || raise("Method being abstract must imply it has a signature")
// 60:       # We allow implementation methods to be defined without a signature.
// 61:       # In that case, get its untyped signature.
// 62:       implementation_signature ||= Methods::Signature.new_untyped(
// 63:         method: implementation_method,
// 64:         mode: Methods::Modes.override
// 65:       )
// 66:       SignatureValidation.validate_override_shape(implementation_signature, abstract_signature)
// 67:       SignatureValidation.validate_override_types(implementation_signature, abstract_signature)
// 68:     end
// 69:
// 70:     method_type = mod.singleton_class? ? "class" : "instance"
// 71:     if !unimplemented_methods.empty?
// 72:       raise "Missing implementation for abstract #{method_type} method(s) in #{mod}:\n" \
// 73:             "#{unimplemented_methods.join("\n")}\n" \
// 74:             "If #{mod} is meant to be an abstract class/module, you can call " \
// 75:             "`abstract!` or `interface!`. Otherwise, you must implement the method(s)."
// 76:     end
// 77:   end
// 78:
// 79:   private_class_method def self.validate_interface_all_abstract(mod, method_names)
// 80:     violations = method_names.map do |method_name|
// 81:       method = mod.instance_method(method_name)
// 82:       if !AbstractUtils.abstract_method?(method)
// 83:         describe_method(method, show_owner: false)
// 84:       end
// 85:     end.compact
// 86:
// 87:     if !violations.empty?
// 88:       raise "`#{mod}` is declared as an interface, but the following methods are not declared " \
// 89:             "with `abstract`:\n#{violations.join("\n")}"
// 90:     end
// 91:   end
// 92:
// 93:   private_class_method def self.validate_interface(mod)
// 94:     interface_methods = T::Utils.methods_excluding_object(mod)
// 95:     validate_interface_all_abstract(mod, interface_methods)
// 96:     validate_interface_all_public(mod, interface_methods)
// 97:   end
// 98:
// 99:   private_class_method def self.validate_interface_all_public(mod, method_names)
// 100:     violations = method_names.map do |method_name|
// 101:       if !mod.public_method_defined?(method_name)
// 102:         describe_method(mod.instance_method(method_name), show_owner: false)
// 103:       end
// 104:     end.compact
// 105:
// 106:     if !violations.empty?
// 107:       raise "All methods on an interface must be public. If you intend to have non-public " \
// 108:             "methods, declare your class/module using `abstract!` instead of `interface!`. " \
// 109:             "The following methods on `#{mod}` are not public: \n#{violations.join("\n")}"
// 110:     end
// 111:   end
// 112:
// 113:   private_class_method def self.describe_method(method, show_owner: true)
// 114:     loc = if (source_loc = method.source_location)
// 115:       source_loc.join(':')
// 116:     else
// 117:       "<unknown location>"
// 118:     end
// 119:
// 120:     owner = if show_owner
// 121:       " declared in #{method.owner}"
// 122:     else
// 123:       ""
// 124:     end
// 125:
// 126:     "    * `#{method.name}`#{owner} at #{loc}"
// 127:   end
// 128: end
