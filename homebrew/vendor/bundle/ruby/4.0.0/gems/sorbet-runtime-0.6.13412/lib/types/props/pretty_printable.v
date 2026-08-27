module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/pretty_printable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `pretty_print(pp)` at line 9.
pub fn ruby_pretty_printable_l9_d1_pretty_print(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_print', ...args)
}

// Ruby method `inspect` at line 36.
pub fn ruby_pretty_printable_l36_d2_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby method `pretty_inspect` at line 43.
pub fn ruby_pretty_printable_l43_d3_pretty_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_inspect', ...args)
}

// Ruby method `valid_rule_key?(key)` at line 53.
pub fn ruby_pretty_printable_l53_d4_valid_rule_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_rule_key?', ...args)
}

// Ruby method `inspect_class_with_decoration(instance)` at line 60.
pub fn ruby_pretty_printable_l60_d5_inspect_class_with_decoration(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect_class_with_decoration', ...args)
}

// Ruby method `pretty_print_extra(instance, pp); end` at line 67.
pub fn ruby_pretty_printable_l67_d6_pretty_print_extra(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_print_extra', ...args)
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
