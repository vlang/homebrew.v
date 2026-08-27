module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/registry.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 21.
pub fn ruby_registry_l21_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `register(name, class_to_register)` at line 25.
pub fn ruby_registry_l25_d2_register(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('register', ...args)
}

// Ruby method `unregister(name)` at line 34.
pub fn ruby_registry_l34_d3_unregister(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unregister', ...args)
}

// Ruby method `lookup(name, hints = {})` at line 38.
pub fn ruby_registry_l38_d4_lookup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lookup', ...args)
}

// Ruby method `underscore_name(name)` at line 58.
pub fn ruby_registry_l58_d5_underscore_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('underscore_name', ...args)
}

// Ruby method `search_names(name, hints)` at line 71.
pub fn ruby_registry_l71_d6_search_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('search_names', ...args)
}

// Ruby method `name_with_prefix(name, prefix)` at line 87.
pub fn ruby_registry_l87_d7_name_with_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name_with_prefix', ...args)
}

// Ruby method `name_with_endian(name, endian)` at line 96.
pub fn ruby_registry_l96_d8_name_with_endian(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name_with_endian', ...args)
}

// Ruby method `register_dynamic_class(name)` at line 107.
pub fn ruby_registry_l107_d9_register_dynamic_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('register_dynamic_class', ...args)
}

// Ruby method `warn_if_name_is_already_registered(name, class_to_register)` at line 118.
pub fn ruby_registry_l118_d10_warn_if_name_is_already_registered(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warn_if_name_is_already_registered', ...args)
}

// Original Ruby source (line-for-line):
// 1: module BinData
// 2:   # Raised when #lookup fails.
// 3:   class UnRegisteredTypeError < StandardError; end
// 4:
// 5:   # This registry contains a register of name -> class mappings.
// 6:   #
// 7:   # Numerics (integers and floating point numbers) have an endian property as
// 8:   # part of their name (e.g. int32be, float_le).
// 9:   #
// 10:   # Classes can be looked up based on their full name or an abbreviated +name+
// 11:   # with +hints+.
// 12:   #
// 13:   # There are two hints supported, :endian and :search_prefix.
// 14:   #
// 15:   #   #lookup("int32", { endian: :big }) will return Int32Be.
// 16:   #
// 17:   #   #lookup("my_type", { search_prefix: :ns }) will return NsMyType.
// 18:   #
// 19:   # Names are stored in under_score_style, not camelCase.
// 20:   class Registry
// 21:     def initialize
// 22:       @registry = {}
// 23:     end
// 24:
// 25:     def register(name, class_to_register)
// 26:       return if name.nil? || class_to_register.nil?
// 27:
// 28:       formatted_name = underscore_name(name)
// 29:       warn_if_name_is_already_registered(formatted_name, class_to_register)
// 30:
// 31:       @registry[formatted_name] = class_to_register
// 32:     end
// 33:
// 34:     def unregister(name)
// 35:       @registry.delete(underscore_name(name))
// 36:     end
// 37:
// 38:     def lookup(name, hints = {})
// 39:       search_names(name, hints).each do |search|
// 40:         register_dynamic_class(search)
// 41:         if @registry.has_key?(search)
// 42:           return @registry[search]
// 43:         end
// 44:       end
// 45:
// 46:       # give the user a hint if the endian keyword is missing
// 47:       search_names(name, hints.merge(endian: :big)).each do |search|
// 48:         register_dynamic_class(search)
// 49:         if @registry.has_key?(search)
// 50:           raise(UnRegisteredTypeError, "#{name}, do you need to specify endian?")
// 51:         end
// 52:       end
// 53:
// 54:       raise(UnRegisteredTypeError, name)
// 55:     end
// 56:
// 57:     # Convert CamelCase +name+ to underscore style.
// 58:     def underscore_name(name)
// 59:       name
// 60:         .to_s
// 61:         .sub(/.*::/, "")
// 62:         .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
// 63:         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
// 64:         .tr('-', '_')
// 65:         .downcase
// 66:     end
// 67:
// 68:     #---------------
// 69:     private
// 70:
// 71:     def search_names(name, hints)
// 72:       base = underscore_name(name)
// 73:       searches = []
// 74:
// 75:       search_prefix = [""] + Array(hints[:search_prefix])
// 76:       search_prefix.each do |prefix|
// 77:         nwp = name_with_prefix(base, prefix)
// 78:         nwe = name_with_endian(nwp, hints[:endian])
// 79:
// 80:         searches << nwp
// 81:         searches << nwe if nwe
// 82:       end
// 83:
// 84:       searches
// 85:     end
// 86:
// 87:     def name_with_prefix(name, prefix)
// 88:       prefix = prefix.to_s.chomp('_')
// 89:       if prefix == ""
// 90:         name
// 91:       else
// 92:         "#{prefix}_#{name}"
// 93:       end
// 94:     end
// 95:
// 96:     def name_with_endian(name, endian)
// 97:       return nil if endian.nil?
// 98:
// 99:       suffix = (endian == :little) ? 'le' : 'be'
// 100:       if /^u?int\d+$/.match?(name)
// 101:         name + suffix
// 102:       else
// 103:         name + '_' + suffix
// 104:       end
// 105:     end
// 106:
// 107:     def register_dynamic_class(name)
// 108:       if /^u?int\d+(le|be)$/.match?(name) || /^s?bit\d+(le)?$/.match?(name)
// 109:         class_name = name.gsub(/(?:^|_)(.)/) { $1.upcase }
// 110:         begin
// 111:           # call const_get for side effect of creating class
// 112:           BinData.const_get(class_name)
// 113:         rescue NameError
// 114:         end
// 115:       end
// 116:     end
// 117:
// 118:     def warn_if_name_is_already_registered(name, class_to_register)
// 119:       prev_class = @registry[name]
// 120:       if prev_class && prev_class != class_to_register
// 121:         Kernel.warn "warning: replacing registered class #{prev_class} " \
// 122:                     "with #{class_to_register}"
// 123:       end
// 124:     end
// 125:   end
// 126:
// 127:   # A singleton registry of all registered classes.
// 128:   RegisteredClasses = Registry.new
// 129: end
