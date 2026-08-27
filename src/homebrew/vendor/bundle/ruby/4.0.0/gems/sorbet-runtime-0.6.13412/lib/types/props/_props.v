module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/_props.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `props` at line 23.
pub fn ruby_props_l23_d1_props(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('props', ...args)
}

// Ruby method `plugins` at line 26.
pub fn ruby_props_l26_d2_plugins(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('plugins', ...args)
}

// Ruby method `decorator_class` at line 30.
pub fn ruby_props_l30_d3_decorator_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorator_class', ...args)
}

// Ruby method `decorator` at line 34.
pub fn ruby_props_l34_d4_decorator(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorator', ...args)
}

// Ruby method `reload_decorator!` at line 37.
pub fn ruby_props_l37_d5_reload_decorator(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reload_decorator!', ...args)
}

// Ruby method `prop(name, cls, **rules)` at line 113.
pub fn ruby_props_l113_d6_prop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prop', ...args)
}

// Ruby method `validate_prop_value(prop, val)` at line 125.
pub fn ruby_props_l125_d7_validate_prop_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validate_prop_value', ...args)
}

// Ruby method `plugin(mod)` at line 130.
pub fn ruby_props_l130_d8_plugin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('plugin', ...args)
}

// Ruby method `const(name, cls, **rules)` at line 136.
pub fn ruby_props_l136_d9_const(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('const', ...args)
}

// Ruby method `included(child)` at line 145.
pub fn ruby_props_l145_d10_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('included', ...args)
}

// Ruby method `prepended(child)` at line 150.
pub fn ruby_props_l150_d11_prepended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prepended', ...args)
}

// Ruby method `extended(child)` at line 155.
pub fn ruby_props_l155_d12_extended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extended', ...args)
}

// Ruby method `inherited(child)` at line 160.
pub fn ruby_props_l160_d13_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inherited', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # A mixin for defining typed properties (attributes).
// 5: # To get serialization methods (to/from JSON-style hashes), add T::Props::Serializable.
// 6: # To get a constructor based on these properties, inherit from T::Struct.
// 7: module T::Props
// 8:   extend T::Helpers
// 9:
// 10:   #####
// 11:   # CAUTION: This mixin is used in hundreds of classes; we want to keep its surface area as narrow
// 12:   # as possible and avoid polluting (and possibly conflicting with) the classes that use it.
// 13:   #
// 14:   # It currently has *zero* instance methods; let's try to keep it that way.
// 15:   # For ClassMethods (below), try to add things to T::Props::Decorator instead unless you are sure
// 16:   # it needs to be exposed here.
// 17:   #####
// 18:
// 19:   module ClassMethods
// 20:     extend T::Sig
// 21:     extend T::Helpers
// 22:
// 23:     def props
// 24:       decorator.props
// 25:     end
// 26:     def plugins
// 27:       @plugins ||= []
// 28:     end
// 29:
// 30:     def decorator_class
// 31:       Decorator
// 32:     end
// 33:
// 34:     def decorator
// 35:       @decorator ||= decorator_class.new(self)
// 36:     end
// 37:     def reload_decorator!
// 38:       @decorator = decorator_class.new(self)
// 39:     end
// 40:
// 41:     # Define a new property. See {file:README.md} for some concrete
// 42:     #  examples.
// 43:     #
// 44:     # Defining a property defines a method with the same name as the
// 45:     # property, that returns the current value, and a `prop=` method
// 46:     # to set its value. Properties will be inherited by subclasses of
// 47:     # a document class.
// 48:     #
// 49:     # @param name [Symbol] The name of this property
// 50:     # @param cls [Class,T::Types::Base] The type of this
// 51:     #   property. If the type is itself a `Document` subclass, this
// 52:     #   property will be recursively serialized/deserialized.
// 53:     # @param rules [Hash] Options to control this property's behavior.
// 54:     # @option rules [T::Boolean,Symbol] :optional If `true`, this property
// 55:     #   is never required to be set before an instance is serialized.
// 56:     #   If `:on_load` (default), when this property is missing or nil, a
// 57:     #   new model cannot be saved, and an existing model can only be
// 58:     #   saved if the property was already missing when it was loaded.
// 59:     #   If `false`, when the property is missing/nil after deserialization, it
// 60:     #   will be set to the default value (as defined by the `default` or
// 61:     #   `factory` option) or will raise if they are not present.
// 62:     #   Deprecated: For `Model`s, if `:optional` is set to the special value
// 63:     #   `:existing`, the property can be saved as nil even if it was
// 64:     #   deserialized with a non-nil value. (Deprecated because there should
// 65:     #   never be a need for this behavior; the new behavior of non-optional
// 66:     #   properties should be sufficient.)
// 67:     # @option rules [Array] :enum An array of legal values; The
// 68:     #  property is required to take on one of those values.
// 69:     # @option rules [T::Boolean] :dont_store If true, this property will
// 70:     #   not be saved on the hash resulting from
// 71:     #   {T::Props::Serializable#serialize}
// 72:     # @option rules [Object] :ifunset A value to be returned if this
// 73:     #   property is requested but has never been set (is set to
// 74:     #   `nil`). It is applied at property-access time, and never saved
// 75:     #   back onto the object or into the database.
// 76:     #
// 77:     #   ``:ifunset`` is considered **DEPRECATED** and should not be used
// 78:     #    in new code, in favor of just setting a default value.
// 79:     # @option rules [Model, Symbol, Proc] :foreign A model class that this
// 80:     #  property is a reference to. Passing `:foreign` will define a
// 81:     #  `:"#{name}_"` method, that will load and return the
// 82:     #  corresponding foreign model.
// 83:     #
// 84:     #  A symbol can be passed to avoid load-order dependencies; It
// 85:     #  will be lazily resolved relative to the enclosing module of the
// 86:     #  defining class.
// 87:     #
// 88:     #  A callable (proc or method) can be passed to dynamically specify the
// 89:     #  foreign model. This will be passed the object instance so that other
// 90:     #  properties of the object can be used to determine the relevant model
// 91:     #  class. It should return a string/symbol class name or the foreign model
// 92:     #  class directly.
// 93:     #
// 94:     # @option rules [Object] :default A default value that will be set
// 95:     #   by `#initialize` if none is provided in the initialization
// 96:     #   hash. This will not affect objects loaded by {.from_hash}.
// 97:     # @option rules [Proc] :factory A `Proc` that will be called to
// 98:     #   generate an initial value for this prop on `#initialize`, if
// 99:     #   none is provided.
// 100:     # @option rules [T::Boolean] :immutable If true, this prop cannot be
// 101:     #   modified after an instance is created or loaded from a hash.
// 102:     # @option rules [T::Boolean] :override It is an error to redeclare a
// 103:     #   `prop` that has already been declared (including on a
// 104:     #   superclass), unless `:override` is set to `true`.
// 105:     # @option rules [Symbol, Array] :redaction A redaction directive that may
// 106:     #   be passed to Chalk::Tools::RedactionUtils.redact_with_directive to
// 107:     #   sanitize this parameter for display. Will define a
// 108:     #   `:"#{name}_redacted"` method, which will return the value in sanitized
// 109:     #   form.
// 110:     #
// 111:     # @return [void]
// 112:     sig { params(name: Symbol, cls: T.untyped, rules: T.untyped).void }
// 113:     def prop(name, cls, **rules)
// 114:       cls = T::Utils.coerce(cls) if !cls.is_a?(Module)
// 115:       decorator.prop_defined(name, cls, rules)
// 116:     end
// 117:
// 118:     # Validates the value of the specified prop. This method allows the caller to
// 119:     #  validate a value for a prop without having to set the data on the instance.
// 120:     #  Throws if invalid.
// 121:     #
// 122:     # @param prop [Symbol]
// 123:     # @param val [Object]
// 124:     # @return [void]
// 125:     def validate_prop_value(prop, val)
// 126:       decorator.validate_prop_value(prop, val)
// 127:     end
// 128:
// 129:     # Needs to be documented
// 130:     def plugin(mod)
// 131:       decorator.plugin(mod)
// 132:     end
// 133:
// 134:     # Shorthand helper to define a `prop` with `immutable => true`
// 135:     sig { params(name: Symbol, cls: T.untyped, rules: T.untyped).void }
// 136:     def const(name, cls, **rules)
// 137:       if rules.key?(:immutable)
// 138:         Kernel.raise ArgumentError.new("Cannot pass 'immutable' argument when using 'const' keyword to define a prop")
// 139:       end
// 140:
// 141:       rules[:immutable] = true
// 142:       self.prop(name, cls, **rules)
// 143:     end
// 144:
// 145:     def included(child)
// 146:       decorator.model_inherited(child)
// 147:       super
// 148:     end
// 149:
// 150:     def prepended(child)
// 151:       decorator.model_inherited(child)
// 152:       super
// 153:     end
// 154:
// 155:     def extended(child)
// 156:       decorator.model_inherited(child.singleton_class)
// 157:       super
// 158:     end
// 159:
// 160:     def inherited(child)
// 161:       decorator.model_inherited(child)
// 162:       super
// 163:     end
// 164:   end
// 165:   mixes_in_class_methods(ClassMethods)
// 166: end
