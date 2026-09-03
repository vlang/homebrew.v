module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/pretty_printable.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PrettyProp {
pub:
	name                  string
	value                 brew_runtime.Value
	has_custom_inspection bool
	custom_inspection     string
	custom_returns_nil    bool
	sensitivity           []string
}

pub struct PrettyObject {
pub:
	class_name string
	props      []PrettyProp
	extra      string
}

fn inspect_prop_value(value brew_runtime.Value, multiline bool, indent string) string {
	return match value.type_name {
		'NilClass' { 'nil' }
		'String' {
			'"${value.as_string().replace('\\', '\\\\').replace('"', '\\"')}"'
		}
		'Array' {
			items := value.array_data.map(inspect_prop_value(it, multiline, '${indent} '))
			if multiline && items.len > 1 {
				'[\n${indent} ${items.join(',\n\${indent} ')},\n${indent}]'
			} else {
				'[${items.join(', ')}]'
			}
		}
		'Hash' {
			mut pairs := []string{}
			mut keys := value.map_data.keys()
			keys.sort()
			for key in keys {
				pairs << '${key}=>${inspect_prop_value(value.map_data[key], multiline, '\${indent} ')}'
			}
			'{${pairs.join(', ')}}'
		}
		else { value.as_string() }
	}
}

fn inspect_pretty_prop(prop PrettyProp, multiline bool, indent string) string {
	if prop.has_custom_inspection {
		return if prop.custom_returns_nil { 'nil' } else { prop.custom_inspection }
	}
	if prop.sensitivity.len > 0 && prop.value.type_name != 'NilClass' {
		return '<REDACTED ${prop.sensitivity.join(', ')}>'
	}
	return inspect_prop_value(prop.value, multiline, indent)
}

// pretty_print_object keeps the source's sorted property order, custom inspect
// precedence, sensitivity redaction, and decorator-supplied class/extra text.
pub fn pretty_print_object(object PrettyObject, multiline bool) string {
	mut props := object.props.clone()
	props.sort_with_compare(fn (left &PrettyProp, right &PrettyProp) int {
		return left.name.compare(right.name)
	})
	if !multiline || props.len == 0 {
		mut fields := props.map('${it.name}=${inspect_pretty_prop(it, false, '')}')
		if object.extra != '' {
			fields << object.extra
		}
		suffix := if fields.len == 0 { '' } else { ' ${fields.join(' ')}' }
		return '<${object.class_name}${suffix}>'
	}
	mut fields := props.map(' ${it.name}=${inspect_pretty_prop(it, true, ' ')}')
	if object.extra != '' {
		fields << ' ${object.extra}'
	}
	return '<${object.class_name}\n${fields.join('\n')}>'
}

pub fn pretty_print_valid_rule_key(super_valid bool, key string) bool {
	return super_valid || key.trim_left(':') == 'inspect'
}

fn pretty_object_from_value(value brew_runtime.Value) PrettyObject {
	mut props := []PrettyProp{}
	for name, prop_value in value.map_data {
		custom := prop_value.attribute('inspect') or { '' }
		props << PrettyProp{
			name: name
			value: prop_value
			has_custom_inspection: 'inspect' in prop_value.attributes
			custom_inspection: custom
			custom_returns_nil: prop_value.attribute('inspect_nil') or { 'false' } == 'true'
			sensitivity: (prop_value.attribute('sensitivity') or { '' }).split(',').filter(it.len > 0)
		}
	}
	return PrettyObject{
		class_name: value.attribute('class_name') or { value.type_name }
		props: props
		extra: value.attribute('pretty_print_extra') or { '' }
	}
}

// Ruby method `pretty_print(pp)` at line 9.
pub fn ruby_pretty_printable_l9_d1_pretty_print(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('PrettyPrintable#pretty_print requires a receiver')
	}
	multiline := if args.len > 1 {
		args[1].attribute('multiline') or { 'false' } == 'true'
	} else {
		false
	}
	return brew_runtime.string_value(pretty_print_object(pretty_object_from_value(args[0]), multiline))
}

// Ruby method `inspect` at line 36.
pub fn ruby_pretty_printable_l36_d2_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('PrettyPrintable#inspect requires a receiver')
	}
	return brew_runtime.string_value(pretty_print_object(pretty_object_from_value(args[0]), false))
}

// Ruby method `pretty_inspect` at line 43.
pub fn ruby_pretty_printable_l43_d3_pretty_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('PrettyPrintable#pretty_inspect requires a receiver')
	}
	return brew_runtime.string_value('${pretty_print_object(pretty_object_from_value(args[0]), true)}\n')
}

// Ruby method `valid_rule_key?(key)` at line 53.
pub fn ruby_pretty_printable_l53_d4_valid_rule_key(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('PrettyPrintable#valid_rule_key? requires a key')
	}
	return brew_runtime.bool_value(pretty_print_valid_rule_key(args[0].attribute('super_valid') or {
		'false'
	} == 'true', args[1].as_string()))
}

// Ruby method `inspect_class_with_decoration(instance)` at line 60.
pub fn ruby_pretty_printable_l60_d5_inspect_class_with_decoration(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('inspect_class_with_decoration requires an instance')
	}
	return brew_runtime.string_value(args[1].attribute('class_name') or { args[1].type_name })
}

// Ruby method `pretty_print_extra(instance, pp); end` at line 67.
pub fn ruby_pretty_printable_l67_d6_pretty_print_extra(args ...brew_runtime.Value) brew_runtime.Value {
	return props_nil_value()
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3: require 'pp'
// 4:
// 5: module T::Props::PrettyPrintable
// 6:   include T::Props::Plugin
// 7:
// 8:   # Override the PP gem with something that's similar, but gives us a hook to do redaction and customization
// 9:   def pretty_print(pp)
// 10:     klass = T.unsafe(T.cast(self, Object).class).decorator
// 11:     multiline = pp.is_a?(PP)
// 12:     pp.group(1, "<#{klass.inspect_class_with_decoration(self)}", ">") do
// 13:       klass.all_props.sort.each do |prop|
// 14:         pp.breakable
// 15:         rules = klass.prop_rules(prop)
// 16:         val = klass.get(self, prop, rules)
// 17:         pp.text("#{prop}=")
// 18:         if (custom_inspect = rules[:inspect])
// 19:           inspected = if T::Utils.arity(custom_inspect) == 1
// 20:             custom_inspect.call(val)
// 21:           else
// 22:             custom_inspect.call(val, {multiline: multiline})
// 23:           end
// 24:           pp.text(inspected.nil? ? "nil" : inspected)
// 25:         elsif (sensitivity = rules[:sensitivity]) && !sensitivity.empty? && !val.nil?
// 26:           pp.text("<REDACTED #{sensitivity.join(', ')}>")
// 27:         else
// 28:           val.pretty_print(pp)
// 29:         end
// 30:       end
// 31:       klass.pretty_print_extra(self, pp)
// 32:     end
// 33:   end
// 34:
// 35:   # Return a string representation of this object and all of its props in a single line
// 36:   def inspect
// 37:     string = +""
// 38:     PP.singleline_pp(self, string)
// 39:     string
// 40:   end
// 41:
// 42:   # Return a pretty string representation of this object and all of its props
// 43:   def pretty_inspect
// 44:     string = +""
// 45:     PP.pp(self, string)
// 46:     string
// 47:   end
// 48:
// 49:   module DecoratorMethods
// 50:     extend T::Sig
// 51:
// 52:     sig { params(key: Symbol).returns(T::Boolean).checked(:never) }
// 53:     def valid_rule_key?(key)
// 54:       super || key == :inspect
// 55:     end
// 56:
// 57:     # Overridable method to specify how the first part of a `pretty_print`d object's class should look like
// 58:     # NOTE: This is just to support Stripe's `PrettyPrintableModel` case, and not recommended to be overridden
// 59:     sig { params(instance: T::Props::PrettyPrintable).returns(String).checked(:never) }
// 60:     def inspect_class_with_decoration(instance)
// 61:       T.unsafe(instance).class.to_s
// 62:     end
// 63:
// 64:     # Overridable method to add anything that is not a prop
// 65:     # NOTE: This is to support cases like Serializable's `@_extra_props`, and Stripe's `PrettyPrintableModel#@_deleted`
// 66:     sig { params(instance: T::Props::PrettyPrintable, pp: T.any(PrettyPrint, PP::SingleLine)).void.checked(:never) }
// 67:     def pretty_print_extra(instance, pp); end
// 68:   end
// 69: end
