module private

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/class_utils.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ClassMethodDefinition {
pub:
	module_id      string
	module_name    string
	name           string
	visibility     string
	owner          string
	implementation brew_runtime.Value
	ruby2_keywords bool
}

pub struct ClassModuleInfo {
pub:
	id        string
	name      string
	ancestors []string
}

@[heap]
pub struct ClassUtilsRegistry {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	methods map[string]ClassMethodDefinition
}

pub fn new_class_utils_registry() &ClassUtilsRegistry {
	return &ClassUtilsRegistry{}
}

const class_utils_registry_global = new_class_utils_registry()

fn class_method_key(module_id string, name string) string {
	return '${module_id}\0${name}'
}

pub fn (mut registry ClassUtilsRegistry) define_method(mod ClassModuleInfo, name string,
	visibility string, implementation brew_runtime.Value, has_rest bool,
	has_keywords bool) !ClassMethodDefinition {
	clean_visibility := visibility.trim_string_left(':')
	if clean_visibility !in ['public', 'protected', 'private'] {
		return error('invalid method visibility: ${visibility}')
	}
	definition := ClassMethodDefinition{
		module_id: mod.id
		module_name: mod.name
		name: name.trim_string_left(':')
		visibility: clean_visibility
		owner: mod.id
		implementation: implementation
		ruby2_keywords: has_rest && !has_keywords
	}
	registry.mutex.lock()
	registry.methods[class_method_key(mod.id, definition.name)] = definition
	registry.mutex.unlock()
	return definition
}

pub fn (mut registry ClassUtilsRegistry) visibility_method_name(module_id string,
	module_name string, name string) !string {
	registry.mutex.lock()
	defer {
		registry.mutex.unlock()
	}
	definition := registry.methods[class_method_key(module_id, name.trim_string_left(':'))] or {
		return error("undefined method `${name.trim_string_left(':')}' for class `${module_name}'")
	}
	return definition.visibility
}

pub fn (mut registry ClassUtilsRegistry) replace_method(original ClassMethodDefinition,
	mod ClassModuleInfo, name string, replacement brew_runtime.Value, has_rest bool,
	has_keywords bool) !ClassMethodDefinition {
	clean_name := name.trim_string_left(':')
	visibility := registry.visibility_method_name(mod.id, mod.name, clean_name)!
	if original.owner != mod.id {
		for ancestor in mod.ancestors {
			if ancestor == mod.id {
				break
			}
			if ancestor == original.owner {
				return error("You're trying to replace `${clean_name}` on `${mod.name}`, but that method exists in a prepended module (${ancestor}), which we don't currently support.")
			}
		}
	}
	return registry.define_method(mod, clean_name, visibility, replacement, has_rest, has_keywords)
}

fn global_class_utils_registry() &ClassUtilsRegistry {
	return unsafe { &ClassUtilsRegistry(class_utils_registry_global) }
}

fn class_module_info(value brew_runtime.Value) ClassModuleInfo {
	return ClassModuleInfo{
		id: value.attribute('object_id') or { '${value.type_name}:${value.as_string()}' }
		name: value.as_string()
		ancestors: value.attribute('ancestors') or { '' }.split(',').map(it.trim_space()).filter(it != '')
	}
}

fn class_definition_value(definition ClassMethodDefinition) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'UnboundMethod'
		repr: '${definition.module_name}#${definition.name}'
		map_data: {
			'implementation': definition.implementation
		}
		attributes: {
			'module_id':      definition.module_id
			'module_name':    definition.module_name
			'name':           definition.name
			'visibility':     definition.visibility
			'owner':          definition.owner
			'ruby2_keywords': definition.ruby2_keywords.str()
		}
	}
}

fn class_definition_from_value(value brew_runtime.Value) ClassMethodDefinition {
	return ClassMethodDefinition{
		module_id: value.attribute('module_id') or { value.attribute('owner') or { '' } }
		module_name: value.attribute('module_name') or { '' }
		name: value.attribute('name') or { value.as_string() }
		visibility: value.attribute('visibility') or { 'public' }
		owner: value.attribute('owner') or { value.attribute('module_id') or { '' } }
		implementation: value.map_data['implementation'] or { value }
		ruby2_keywords: value.attribute('ruby2_keywords') or { 'false' } == 'true'
	}
}

fn define_method_boundary(args []brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('ClassUtils.def_with_visibility requires module, name, visibility, and method')
	}
	mod := class_module_info(args[0])
	has_rest := if args.len > 4 {
		args[4].attribute('has_rest') or { 'false' } == 'true'
	} else {
		false
	}
	has_keywords := if args.len > 4 {
		args[4].attribute('has_keywords') or { 'false' } == 'true'
	} else {
		false
	}
	mut registry := global_class_utils_registry()
	definition := registry.define_method(mod, args[1].as_string(), args[2].as_string(), args[3], has_rest, has_keywords) or { panic(err.msg()) }
	return class_definition_value(definition)
}

// Ruby method `self.visibility_method_name(mod, name)` at line 13.
pub fn ruby_class_utils_l13_d1_self_visibility_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ClassUtils.visibility_method_name requires module and name')
	}
	mod := class_module_info(args[0])
	mut registry := global_class_utils_registry()
	visibility := registry.visibility_method_name(mod.id, mod.name, args[1].as_string()) or {
		// A boundary module may arrive from reflective code before its methods
		// have crossed the typed registry. Preserve its declared visibility.
		name := args[1].as_string().trim_string_left(':')
		for candidate in ['public', 'protected', 'private'] {
			methods := args[0].attribute('${candidate}_methods') or { '' }.split(',').map(it.trim_space())
			if name in methods {
				return brew_runtime.object_value('Symbol', ':${candidate}')
			}
		}
		panic(err.msg())
	}
	return brew_runtime.object_value('Symbol', ':${visibility}')
}

// Ruby method `self.def_with_visibility(mod, name, visibility, method=nil, &block)` at line 31.
pub fn ruby_class_utils_l31_d2_self_def_with_visibility(args ...brew_runtime.Value) brew_runtime.Value {
	return define_method_boundary(args)
}

// Ruby define_method `define_method(name, method)` at line 41.
pub fn ruby_class_utils_l41_d3_name(args ...brew_runtime.Value) brew_runtime.Value {
	return define_method_boundary(args)
}

// Ruby define_method `define_method(name, &block)` at line 43.
pub fn ruby_class_utils_l43_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return define_method_boundary(args)
}

// Ruby method `self.replace_method(original_method, mod, name, &blk)` at line 67.
pub fn ruby_class_utils_l67_d5_self_replace_method(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('ClassUtils.replace_method requires original method, module, name, and replacement')
	}
	mod := class_module_info(args[1])
	mut registry := global_class_utils_registry()
	definition := registry.replace_method(class_definition_from_value(args[0]), mod, args[2].as_string(), args[3], args[3].attribute('has_rest') or { 'false' } == 'true', args[3].attribute('has_keywords') or { 'false' } == 'true') or { panic(err.msg()) }
	return class_definition_value(definition)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Cut down version of Chalk::Tools::ClassUtils with only :replace_method functionality.
// 5: # Extracted to a separate namespace so the type system can be used standalone.
// 6: #
// 7: # Note: the functionality to "restore" a method was removed, because it is no
// 8: # longer being used by sorbet-runtime. Restoring a method requires care--if you
// 9: # need to reintroduce this functionality, consult the git history for how to do
// 10: # it safely.
// 11: module T::Private::ClassUtils
// 12:   # `name` must be an instance method (for class methods, pass in mod.singleton_class)
// 13:   def self.visibility_method_name(mod, name)
// 14:     if mod.public_method_defined?(name)
// 15:       :public
// 16:     elsif mod.protected_method_defined?(name)
// 17:       :protected
// 18:     elsif mod.private_method_defined?(name)
// 19:       :private
// 20:     else
// 21:       # Raises a NameError formatted like the Ruby VM would (the exact text formatting
// 22:       # of these errors changed across Ruby VM versions, in ways that would sometimes
// 23:       # cause tests to fail if they were dependent on hard coding errors).
// 24:       mod.method(name)
// 25:       # This is just to prove to Sorbet that this method raises.
// 26:       # This line should be unreachable in practice due to the above call.
// 27:       raise NameError.new("undefined method `#{name}' for class `#{mod}'")
// 28:     end
// 29:   end
// 30:
// 31:   def self.def_with_visibility(mod, name, visibility, method=nil, &block)
// 32:     mod.module_exec do
// 33:       # Start a visibility (public/protected/private) region, so that
// 34:       # all of the method redefinitions happen with the right visibility
// 35:       # from the beginning. This ensures that any other code that is
// 36:       # triggered by `method_added`, sees the redefined method with the
// 37:       # right visibility.
// 38:       send(visibility)
// 39:
// 40:       if method
// 41:         define_method(name, method)
// 42:       else
// 43:         define_method(name, &block)
// 44:       end
// 45:
// 46:       if block && block.arity < 0 && respond_to?(:ruby2_keywords, true)
// 47:         # Fetch .parameters once: each call builds a fresh array.
// 48:         parameters = instance_method(name).parameters
// 49:         has_rest = parameters.any? { |kind, _| kind == :rest }
// 50:         has_keywords = parameters.any? { |kind, _| kind == :keyrest || kind == :keyreq || kind == :key }
// 51:         ruby2_keywords(name) if has_rest && !has_keywords
// 52:       end
// 53:     end
// 54:   end
// 55:
// 56:   # Replaces a method, either by overwriting it (if it is defined directly on
// 57:   # `mod`) or by overriding it (if it is defined by one of mod's ancestors).
// 58:   #
// 59:   # Takes the `original_method` as a parameter, so it does not return anything.
// 60:   #
// 61:   # Can also avoid `T.let` pinning errors by letting the caller pre-compute the
// 62:   # `original_method`, so it knows that it will always be defined (because it
// 63:   # doesn't know that the block will always run once)
// 64:   #
// 65:   # Does not share code with `replace_method_with_handle`, for performance (do
// 66:   # not want to increase the call stack, as this is a very sensitive code path).
// 67:   def self.replace_method(original_method, mod, name, &blk)
// 68:     original_visibility = visibility_method_name(mod, name)
// 69:     original_owner = original_method.owner
// 70:
// 71:     # In the common case the method is owned by `mod` itself, in which case the loop below
// 72:     # would always `break` before the raise could match (`mod` precedes any non-prepended
// 73:     # ancestor in its own ancestor chain), so skip computing `mod.ancestors` entirely.
// 74:     if original_owner != mod
// 75:       mod.ancestors.each do |ancestor|
// 76:         break if ancestor == mod
// 77:         if ancestor == original_owner
// 78:           # If we get here, that means the method we're trying to replace exists on a *prepended*
// 79:           # mixin, which means in order to supersede it, we'd need to create a method on a new
// 80:           # module that we'd prepend before `ancestor`. The problem with that approach is there'd
// 81:           # be no way to remove that new module after prepending it, so we'd be left with these
// 82:           # empty anonymous modules in the ancestor chain after calling `restore`.
// 83:           #
// 84:           # That's not necessarily a deal breaker, but for now, we're keeping it as unsupported.
// 85:           raise "You're trying to replace `#{name}` on `#{mod}`, but that method exists in a " \
// 86:                 "prepended module (#{ancestor}), which we don't currently support."
// 87:         end
// 88:       end
// 89:     end
// 90:
// 91:     T::Configuration.without_ruby_warnings do
// 92:       T::Private::DeclState.current.without_on_method_added do
// 93:         def_with_visibility(mod, name, original_visibility, &blk)
// 94:       end
// 95:     end
// 96:
// 97:     nil
// 98:   end
// 99: end
