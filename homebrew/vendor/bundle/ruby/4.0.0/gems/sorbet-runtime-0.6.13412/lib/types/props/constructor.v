module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/constructor.rb`.
// The original source is retained below until every stub has a typed V body.

// construct_required_props_without_defaults mirrors Constructor's deliberate
// setter call for every property. A failed setter on an absent key is reported
// as the source's missing-required-property ArgumentError.
pub fn construct_required_props_without_defaults(mut instance PropInstance,
	definitions []PropDefinition, hash map[string]brew_runtime.Value) !int {
	mut result := 0
	for definition in definitions {
		if definition.has_default || definition.has_factory {
			continue
		}
		present := definition.name in hash
		value := hash[definition.name] or { props_nil_value() }
		set_prop_value(mut instance, definition, value) or {
			if !present {
				return error('Missing required prop `${definition.name}` for class `${instance.class_name}`')
			}
			return err
		}
		if props_truthy(value) || present {
			result++
		}
	}
	return result
}

pub fn strict_construct(class_name string, definitions []PropDefinition,
	hash map[string]brew_runtime.Value) !PropInstance {
	mut instance := PropInstance{
		class_name: class_name
		values: map[string]brew_runtime.Value{}
	}
	matched := construct_props_with_defaults(mut instance, definitions, hash)! + construct_required_props_without_defaults(mut instance, definitions, hash)!
	if matched < hash.len {
		known := definitions.map(it.name)
		mut unknown := []string{}
		for key in hash.keys() {
			if key !in known {
				unknown << key
			}
		}
		unknown.sort()
		return error('${class_name}: Unrecognized properties: ${unknown.join(', ')}')
	}
	return instance
}

// Ruby method `construct_props_without_defaults(instance, hash)` at line 19.
pub fn ruby_constructor_l19_d1_construct_props_without_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('construct_props_without_defaults requires decorator, instance, and hash')
	}
	mut instance := prop_instance_from_value(args[1])
	count := construct_required_props_without_defaults(mut instance, prop_definitions_from_value(args[0]), args[2].as_map() or { panic(err) }) or { panic(err) }
	return brew_runtime.int_value(count)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props::Constructor
// 5:   include T::Props::WeakConstructor
// 6: end
// 7:
// 8: module T::Props::Constructor::DecoratorMethods
// 9:   extend T::Sig
// 10:
// 11:   # Set values for all props that have no defaults. Override what `WeakConstructor`
// 12:   # does in order to raise errors on nils instead of ignoring them.
// 13:   #
// 14:   # @return [Integer] A count of props that we successfully initialized (which
// 15:   # we'll use to check for any unrecognized input.)
// 16:   #
// 17:   # checked(:never) - O(runtime object construction)
// 18:   sig { params(instance: T::Props::Constructor, hash: T::Hash[Symbol, T.untyped]).returns(Integer).checked(:never) }
// 19:   def construct_props_without_defaults(instance, hash)
// 20:     # Use `each_pair` rather than `count` because, as of Ruby 2.6, the latter delegates to Enumerator
// 21:     # and therefore allocates for each entry.
// 22:     result = 0
// 23:     props_without_defaults&.each_pair do |p, bound_setter|
// 24:       begin
// 25:         val = hash[p]
// 26:         bound_setter.call(instance, val)
// 27:         if val || hash.key?(p)
// 28:           result += 1
// 29:         end
// 30:       rescue TypeError, T::Props::InvalidValueError
// 31:         if !hash.key?(p)
// 32:           raise ArgumentError.new("Missing required prop `#{p}` for class `#{instance.class.name}`")
// 33:         else
// 34:           raise
// 35:         end
// 36:       end
// 37:     end
// 38:     result
// 39:   end
// 40: end
