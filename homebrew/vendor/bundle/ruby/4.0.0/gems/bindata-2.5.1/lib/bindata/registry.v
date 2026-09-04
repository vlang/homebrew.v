module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/registry.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct RegistryHints {
pub:
	endian        ?IntEndian
	search_prefix []string
}

pub struct Registry {
mut:
	entries          map[string]ruby.Value
	warning_messages []string
	dynamic_classes  bool
}

pub fn new_registry() Registry {
	return Registry{
		entries: map[string]ruby.Value{}
	}
}

pub fn new_registered_classes_registry() Registry {
	// These are the eager registrations performed by int.rb, float.rb and
	// bits.rb before the singleton RegisteredClasses registry is used.
	mut registry := Registry{
		entries: map[string]ruby.Value{}
		dynamic_classes: true
	}
	registry.register('Uint8', integer_class_value(IntegerClass{'Uint8', 8, .little, .unsigned}))
	registry.register('Int8', integer_class_value(IntegerClass{'Int8', 8, .little, .signed}))
	registry.register('FloatLe', floating_point_class_value(FloatingPointClass{'FloatLe', .single, .little}))
	registry.register('FloatBe', floating_point_class_value(FloatingPointClass{'FloatBe', .single, .big}))
	registry.register('DoubleLe', floating_point_class_value(FloatingPointClass{'DoubleLe', .double, .little}))
	registry.register('DoubleBe', floating_point_class_value(FloatingPointClass{'DoubleBe', .double, .big}))
	for name in ['Bit', 'BitLe', 'Sbit', 'SbitLe'] {
		registry.register(name, bitfield_value(bitfield_class_for_name(name) or { panic(err) }))
	}
	return registry
}

fn is_ascii_upper(value u8) bool {
	return value >= `A` && value <= `Z`
}

fn is_ascii_lower(value u8) bool {
	return value >= `a` && value <= `z`
}

fn is_ascii_digit(value u8) bool {
	return value >= `0` && value <= `9`
}

// Convert CamelCase names to the under_score_style used as registry keys.
pub fn underscore_registry_name(name string) string {
	unnested := name.all_after_last('::')
	mut formatted := []u8{cap: unnested.len + 4}
	for index, value in unnested.bytes() {
		if value == `-` {
			formatted << `_`
			continue
		}
		if is_ascii_upper(value) && index > 0 {
			previous := unnested[index - 1]
			next_is_lower := index + 1 < unnested.len && is_ascii_lower(unnested[index + 1])
			if is_ascii_lower(previous) || is_ascii_digit(previous) || (is_ascii_upper(previous) && next_is_lower) {
				formatted << `_`
			}
		}
		formatted << if is_ascii_upper(value) { value + 32 } else { value }
	}
	return formatted.bytestr().to_lower()
}

fn runtime_classes_equal(left ruby.Value, right ruby.Value) bool {
	return left.type_name == right.type_name && left.repr == right.repr && left.attributes == right.attributes
}

pub fn (mut registry Registry) register(name string, class_to_register ruby.Value) {
	formatted_name := underscore_registry_name(name)
	if previous := registry.entries[formatted_name] {
		if !runtime_classes_equal(previous, class_to_register) {
			registry.warning_messages << 'warning: replacing registered class ${previous.repr} with ${class_to_register.repr}'
		}
	}
	registry.entries[formatted_name] = class_to_register
}

pub fn (mut registry Registry) unregister(name string) ?ruby.Value {
	formatted_name := underscore_registry_name(name)
	if previous := registry.entries[formatted_name] {
		registry.entries.delete(formatted_name)
		return previous
	}
	return none
}

pub fn (registry &Registry) warnings() []string {
	return registry.warning_messages.clone()
}

pub fn name_with_registry_prefix(name string, prefix string) string {
	trimmed := if prefix.ends_with('_') { prefix[..prefix.len - 1] } else { prefix }
	return if trimmed.len == 0 { name } else { '${trimmed}_${name}' }
}

fn is_integer_registry_name(name string) bool {
	digits := if name.starts_with('uint') {
		name[4..]
	} else if name.starts_with('int') {
		name[3..]
	} else {
		return false
	}
	return digits.len > 0 && digits.bytes().all(is_ascii_digit(it))
}

pub fn name_with_registry_endian(name string, endian ?IntEndian) ?string {
	actual := endian or { return none }
	suffix := if actual == .little { 'le' } else { 'be' }
	return if is_integer_registry_name(name) { name + suffix } else { '${name}_${suffix}' }
}

pub fn registry_search_names(name string, hints RegistryHints) []string {
	base := underscore_registry_name(name)
	mut prefixes := ['']
	prefixes << hints.search_prefix
	mut searches := []string{cap: prefixes.len * 2}
	for prefix in prefixes {
		with_prefix := name_with_registry_prefix(base, prefix)
		searches << with_prefix
		if with_endian := name_with_registry_endian(with_prefix, hints.endian) {
			searches << with_endian
		}
	}
	return searches
}

fn camelize_registry_name(name string) string {
	mut result := []u8{cap: name.len}
	mut capitalize := true
	for value in name.bytes() {
		if value == `_` {
			capitalize = true
			continue
		}
		result << if capitalize && is_ascii_lower(value) { value - 32 } else { value }
		capitalize = false
	}
	return result.bytestr()
}

fn integer_dynamic_registry_name(name string) bool {
	if !(name.starts_with('int') || name.starts_with('uint')) || !(name.ends_with('le') || name.ends_with('be')) {
		return false
	}
	endian_index := name.len - 2
	digit_index := if name.starts_with('uint') { 4 } else { 3 }
	digits := name[digit_index..endian_index]
	return digits.len > 0 && digits.bytes().all(is_ascii_digit(it))
}

fn bit_dynamic_registry_name(name string) bool {
	mut base := name
	if base.ends_with('le') {
		base = base[..base.len - 2]
	}
	digit_index := if base.starts_with('sbit') {
		4
	} else if base.starts_with('bit') {
		3
	} else {
		return false
	}
	digits := base[digit_index..]
	return digits.len > 0 && digits.bytes().all(is_ascii_digit(it))
}

pub fn (mut registry Registry) register_dynamic_class(name string) {
	if !registry.dynamic_classes || name in registry.entries {
		return
	}
	class_name := camelize_registry_name(name)
	if integer_dynamic_registry_name(name) {
		if spec := integer_class_for_name(class_name) {
			registry.register(name, integer_class_value(spec))
		}
	} else if bit_dynamic_registry_name(name) {
		if spec := bitfield_class_for_name(class_name) {
			registry.register(name, bitfield_value(spec))
		}
	}
}

pub fn (mut registry Registry) lookup(name string, hints RegistryHints) !ruby.Value {
	for search in registry_search_names(name, hints) {
		registry.register_dynamic_class(search)
		if registered := registry.entries[search] {
			return registered
		}
	}
	missing_endian_hints := RegistryHints{
		...hints
		endian: .big
	}
	for search in registry_search_names(name, missing_endian_hints) {
		registry.register_dynamic_class(search)
		if _ := registry.entries[search] {
			return error('${name}, do you need to specify endian?')
		}
	}
	return error(name)
}

fn registry_value(registry Registry) ruby.Value {
	return ruby.Value{
		type_name: 'BinData::Registry'
		repr: 'BinData::Registry'
		map_data: registry.entries
		string_array_data: registry.warning_messages
		attributes: {
			'dynamic_classes': registry.dynamic_classes.str()
		}
	}
}

fn registry_from_value(value ruby.Value) Registry {
	return Registry{
		entries: value.map_data
		warning_messages: value.string_array_data
		dynamic_classes: (value.attribute('dynamic_classes') or { 'false' }).bool()
	}
}

fn registry_hints_from_value(value ruby.Value) RegistryHints {
	if value.type_name != 'Hash' {
		return RegistryHints{}
	}
	hints := value.map_data.clone()
	mut result := RegistryHints{}
	if endian := hints['endian'] {
		if endian.type_name != 'NilClass' {
			result = RegistryHints{
				...result
				endian: if endian.as_string().trim_left(':') == 'little' { .little } else { .big }
			}
		}
	}
	if prefixes := hints['search_prefix'] {
		if prefixes.type_name != 'NilClass' {
			result = RegistryHints{
				...result
				search_prefix: if prefixes.type_name == 'Array' {
					prefixes.as_array() or { panic(err) }.map(it.as_string().trim_left(':'))
				} else {
					[prefixes.as_string().trim_left(':')]
				}
			}
		}
	}
	return result
}

fn nil_registry_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `initialize` at line 21.
pub fn ruby_registry_l21_d1_initialize(args ...ruby.Value) ruby.Value {
	return registry_value(new_registry())
}

// Ruby method `register(name, class_to_register)` at line 25.
pub fn ruby_registry_l25_d2_register(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Registry#register requires a receiver, name and class')
	}
	if args[1].type_name == 'NilClass' || args[2].type_name == 'NilClass' {
		return nil_registry_value()
	}
	mut registry := registry_from_value(args[0])
	registry.register(args[1].as_string().trim_left(':'), args[2])
	return args[2]
}

// Ruby method `unregister(name)` at line 34.
pub fn ruby_registry_l34_d3_unregister(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Registry#unregister requires a receiver and name')
	}
	mut registry := registry_from_value(args[0])
	return registry.unregister(args[1].as_string().trim_left(':')) or { nil_registry_value() }
}

// Ruby method `lookup(name, hints = {})` at line 38.
pub fn ruby_registry_l38_d4_lookup(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Registry#lookup requires a receiver and name')
	}
	mut registry := registry_from_value(args[0])
	hints := if args.len > 2 { registry_hints_from_value(args[2]) } else { RegistryHints{} }
	return registry.lookup(args[1].as_string().trim_left(':'), hints) or { panic(err) }
}

// Ruby method `underscore_name(name)` at line 58.
pub fn ruby_registry_l58_d5_underscore_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Registry#underscore_name requires a receiver and name')
	}
	return ruby.string_value(underscore_registry_name(args[1].as_string().trim_left(':')))
}

// Ruby method `search_names(name, hints)` at line 71.
pub fn ruby_registry_l71_d6_search_names(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Registry#search_names requires a receiver, name and hints')
	}
	return ruby.string_array_value(registry_search_names(args[1].as_string().trim_left(':'), registry_hints_from_value(args[2])))
}

// Ruby method `name_with_prefix(name, prefix)` at line 87.
pub fn ruby_registry_l87_d7_name_with_prefix(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Registry#name_with_prefix requires a receiver, name and prefix')
	}
	return ruby.string_value(name_with_registry_prefix(args[1].as_string(), args[2].as_string().trim_left(':')))
}

// Ruby method `name_with_endian(name, endian)` at line 96.
pub fn ruby_registry_l96_d8_name_with_endian(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Registry#name_with_endian requires a receiver, name and endian')
	}
	if args[2].type_name == 'NilClass' {
		return nil_registry_value()
	}
	endian := if args[2].as_string().trim_left(':') == 'little' {
		IntEndian.little
	} else {
		IntEndian.big
	}
	return ruby.string_value(name_with_registry_endian(args[1].as_string(), endian) or {
		panic('endian suffix is missing')
	})
}

// Ruby method `register_dynamic_class(name)` at line 107.
pub fn ruby_registry_l107_d9_register_dynamic_class(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Registry#register_dynamic_class requires a receiver and name')
	}
	mut registry := registry_from_value(args[0])
	registry.register_dynamic_class(args[1].as_string())
	return nil_registry_value()
}

// Ruby method `warn_if_name_is_already_registered(name, class_to_register)` at line 118.
pub fn ruby_registry_l118_d10_warn_if_name_is_already_registered(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Registry#warning check requires a receiver, name and class')
	}
	registry := registry_from_value(args[0])
	if previous := registry.entries[args[1].as_string()] {
		if !runtime_classes_equal(previous, args[2]) {
			eprintln('warning: replacing registered class ${previous.repr} with ${args[2].repr}')
		}
	}
	return nil_registry_value()
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
