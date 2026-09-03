module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/name.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn register_name_optional_parameters(parameters []string) []string {
	mut result := parameters.clone()
	if 'name' !in result {
		result << 'name'
	}
	return result
}

pub fn register_named_instance(mut registry Registry, parameters map[string]brew_runtime.Value, instance brew_runtime.Value) bool {
	if name := parameters['name'] {
		if name.type_name != 'NilClass' {
			registry.register(name.as_string().trim_left(':'), instance)
			return true
		}
	}
	return false
}

// Ruby method `self.included(base) # :nodoc:` at line 16.
pub fn ruby_name_l16_d1_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('RegisterNamePlugin.included requires a base class')
	}
	base := args.last()
	return ruby_params_l27_d6_optional_parameter(base, brew_runtime.object_value('Symbol', ':name'))
}

// Ruby method `initialize_shared_instance` at line 21.
pub fn ruby_name_l21_d2_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('RegisterNamePlugin#initialize_shared_instance requires a receiver')
	}
	// The optional second argument carries the singleton registry through the
	// generic boundary. Typed callers use `register_named_instance` directly.
	if args.len > 1 {
		mut registry := registry_from_value(args[1])
		register_named_instance(mut registry, args[0].map_data, args[0])
	}
	return ruby_framework_l18_d2_initialize_shared_instance(args[0])
}

// Original Ruby source (line-for-line):
// 1: module BinData
// 2:   # == Parameters
// 3:   #
// 4:   # Parameters may be provided at initialisation to control the behaviour of
// 5:   # an object.  These parameters are:
// 6:   #
// 7:   # <tt>:name</tt>:: The name that this object can be referred to may be
// 8:   #                  set explicitly.  This is only useful when dynamically
// 9:   #                  generating types.
// 10:   #                  <code><pre>
// 11:   #                    BinData::Struct.new(name: :my_struct, fields: ...)
// 12:   #                    array = BinData::Array.new(type: :my_struct)
// 13:   #                  </pre></code>
// 14:   module RegisterNamePlugin
// 15:
// 16:     def self.included(base) # :nodoc:
// 17:       # The registered name may be provided explicitly.
// 18:       base.optional_parameter :name
// 19:     end
// 20:
// 21:     def initialize_shared_instance
// 22:       if has_parameter?(:name)
// 23:         RegisteredClasses.register(get_parameter(:name), self)
// 24:       end
// 25:       super
// 26:     end
// 27:   end
// 28: end
