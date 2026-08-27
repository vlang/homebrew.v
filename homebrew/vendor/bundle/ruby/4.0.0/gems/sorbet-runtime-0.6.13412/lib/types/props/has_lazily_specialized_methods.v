module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/has_lazily_specialized_methods.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 21.
pub fn ruby_has_lazily_specialized_methods_l21_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `self.disable_lazy_evaluation!` at line 34.
pub fn ruby_has_lazily_specialized_methods_l34_d2_self_disable_lazy_evaluation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.disable_lazy_evaluation!', ...args)
}

// Ruby method `self.lazy_evaluation_enabled?` at line 39.
pub fn ruby_has_lazily_specialized_methods_l39_d3_self_lazy_evaluation_enabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.lazy_evaluation_enabled?', ...args)
}

// Ruby method `lazily_defined_methods` at line 47.
pub fn ruby_has_lazily_specialized_methods_l47_d4_lazily_defined_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lazily_defined_methods', ...args)
}

// Ruby method `lazily_defined_vm_methods` at line 52.
pub fn ruby_has_lazily_specialized_methods_l52_d5_lazily_defined_vm_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lazily_defined_vm_methods', ...args)
}

// Ruby method `eval_lazily_defined_method!(name)` at line 57.
pub fn ruby_has_lazily_specialized_methods_l57_d6_eval_lazily_defined_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eval_lazily_defined_method!', ...args)
}

// Ruby method `eval_lazily_defined_vm_method!(name)` at line 82.
pub fn ruby_has_lazily_specialized_methods_l82_d7_eval_lazily_defined_vm_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eval_lazily_defined_vm_method!', ...args)
}

// Ruby method `enqueue_lazy_method_definition!(name, &blk)` at line 99.
pub fn ruby_has_lazily_specialized_methods_l99_d8_enqueue_lazy_method_definition(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enqueue_lazy_method_definition!', ...args)
}

// Ruby alias_method `cls.send(:alias_method, name, name)` at line 117.
pub fn ruby_has_lazily_specialized_methods_l117_d9_alias_method_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('alias_method_dynamic', ...args)
}

// Ruby define_method `cls.send(:define_method, name) do |*args|` at line 119.
pub fn ruby_has_lazily_specialized_methods_l119_d10_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `enqueue_lazy_vm_method_definition!(name, &blk)` at line 130.
pub fn ruby_has_lazily_specialized_methods_l130_d11_enqueue_lazy_vm_method_definition(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enqueue_lazy_vm_method_definition!', ...args)
}

// Ruby define_method `cls.send(:define_method, name) do |*args|` at line 140.
pub fn ruby_has_lazily_specialized_methods_l140_d12_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `eagerly_define_lazy_methods!` at line 151.
pub fn ruby_has_lazily_specialized_methods_l151_d13_eagerly_define_lazy_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eagerly_define_lazy_methods!', ...args)
}

// Ruby method `eagerly_define_lazy_vm_methods!` at line 165.
pub fn ruby_has_lazily_specialized_methods_l165_d14_eagerly_define_lazy_vm_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eagerly_define_lazy_vm_methods!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props
// 5:
// 6:   # Helper for generating methods that replace themselves with a specialized
// 7:   # version on first use. The main use case is when we want to generate a
// 8:   # method using the full set of props on a class; we can't do that during
// 9:   # prop definition because we have no way of knowing whether we are defining
// 10:   # the last prop.
// 11:   #
// 12:   # See go/M8yrvzX2 (Stripe-internal) for discussion of security considerations.
// 13:   # In outline, while `class_eval` is a bit scary, we believe that as long as
// 14:   # all inputs are defined in version control (and this is enforced by calling
// 15:   # `disable_lazy_evaluation!` appropriately), risk isn't significantly higher
// 16:   # than with build-time codegen.
// 17:   module HasLazilySpecializedMethods
// 18:     extend T::Sig
// 19:
// 20:     class SourceEvaluationDisabled < RuntimeError
// 21:       def initialize
// 22:         super("Evaluation of lazily-defined methods is disabled")
// 23:       end
// 24:     end
// 25:
// 26:     # Disable any future evaluation of lazily-defined methods.
// 27:     #
// 28:     # This is intended to be called after startup but before interacting with
// 29:     # the outside world, to limit attack surface for our `class_eval` use.
// 30:     #
// 31:     # Note it does _not_ prevent explicit calls to `eagerly_define_lazy_methods!`
// 32:     # from working.
// 33:     sig { void }
// 34:     def self.disable_lazy_evaluation!
// 35:       @lazy_evaluation_disabled ||= true
// 36:     end
// 37:
// 38:     sig { returns(T::Boolean) }
// 39:     def self.lazy_evaluation_enabled?
// 40:       !@lazy_evaluation_disabled
// 41:     end
// 42:
// 43:     module DecoratorMethods
// 44:       extend T::Sig
// 45:
// 46:       sig { returns(T::Hash[Symbol, T.proc.returns(String)]).checked(:never) }
// 47:       private def lazily_defined_methods
// 48:         @lazily_defined_methods ||= {}
// 49:       end
// 50:
// 51:       sig { returns(T::Hash[Symbol, T.untyped]).checked(:never) }
// 52:       private def lazily_defined_vm_methods
// 53:         @lazily_defined_vm_methods ||= {}
// 54:       end
// 55:
// 56:       sig { params(name: Symbol).void }
// 57:       private def eval_lazily_defined_method!(name)
// 58:         if !HasLazilySpecializedMethods.lazy_evaluation_enabled?
// 59:           raise SourceEvaluationDisabled.new
// 60:         end
// 61:
// 62:         blk = lazily_defined_methods[name]
// 63:         # A concurrent first call can have already evaluated and removed
// 64:         # this entry; the specialized method is installed, so the
// 65:         # placeholder's retry dispatch will reach it directly.
// 66:         return if blk.nil?
// 67:
// 68:         source = blk.call
// 69:
// 70:         cls = decorated_class
// 71:         T::Configuration.without_ruby_warnings do
// 72:           cls.class_eval(source.to_s)
// 73:         end
// 74:         cls.send(:private, name)
// 75:         # Removing the entry records that no placeholder is installed, so a
// 76:         # later prop addition (possible, if unusual: props added after first
// 77:         # use) re-enqueues a fresh placeholder instead of being skipped.
// 78:         lazily_defined_methods.delete(name)
// 79:       end
// 80:
// 81:       sig { params(name: Symbol).void }
// 82:       private def eval_lazily_defined_vm_method!(name)
// 83:         if !HasLazilySpecializedMethods.lazy_evaluation_enabled?
// 84:           raise SourceEvaluationDisabled.new
// 85:         end
// 86:
// 87:         blk = lazily_defined_vm_methods[name]
// 88:         # See eval_lazily_defined_method!.
// 89:         return if blk.nil?
// 90:
// 91:         blk.call
// 92:
// 93:         cls = decorated_class
// 94:         cls.send(:private, name)
// 95:         lazily_defined_vm_methods.delete(name)
// 96:       end
// 97:
// 98:       sig { params(name: Symbol, blk: T.proc.returns(String)).void }
// 99:       private def enqueue_lazy_method_definition!(name, &blk)
// 100:         methods = lazily_defined_methods
// 101:         if methods.key?(name)
// 102:           # The placeholder installed below is already in place (every prop
// 103:           # addition lands here, so this is hit from the second prop of a
// 104:           # class onward, and again for every prop re-added to a subclass).
// 105:           # It reads the generator from the hash at call time, so updating
// 106:           # the entry suffices; skipping the re-install avoids 2-4 method
// 107:           # table writes (and their cache invalidations) per addition.
// 108:           methods[name] = blk
// 109:           return
// 110:         end
// 111:         methods[name] = blk
// 112:
// 113:         cls = decorated_class
// 114:         if cls.method_defined?(name) || cls.private_method_defined?(name)
// 115:           # Ruby does not emit "method redefined" warnings for aliased methods
// 116:           # (more robust than undef_method that would create a small window in which the method doesn't exist)
// 117:           cls.send(:alias_method, name, name)
// 118:         end
// 119:         cls.send(:define_method, name) do |*args|
// 120:           self.class.decorator.send(:eval_lazily_defined_method!, name)
// 121:           send(name, *args)
// 122:         end
// 123:         if cls.respond_to?(:ruby2_keywords, true)
// 124:           cls.send(:ruby2_keywords, name)
// 125:         end
// 126:         cls.send(:private, name)
// 127:       end
// 128:
// 129:       sig { params(name: Symbol, blk: T.untyped).void }
// 130:       private def enqueue_lazy_vm_method_definition!(name, &blk)
// 131:         methods = lazily_defined_vm_methods
// 132:         if methods.key?(name)
// 133:           # See enqueue_lazy_method_definition!.
// 134:           methods[name] = blk
// 135:           return
// 136:         end
// 137:         methods[name] = blk
// 138:
// 139:         cls = decorated_class
// 140:         cls.send(:define_method, name) do |*args|
// 141:           self.class.decorator.send(:eval_lazily_defined_vm_method!, name)
// 142:           send(name, *args)
// 143:         end
// 144:         if cls.respond_to?(:ruby2_keywords, true)
// 145:           cls.send(:ruby2_keywords, name)
// 146:         end
// 147:         cls.send(:private, name)
// 148:       end
// 149:
// 150:       sig { void }
// 151:       def eagerly_define_lazy_methods!
// 152:         return if lazily_defined_methods.empty?
// 153:
// 154:         # rubocop:disable Style/StringConcatenation
// 155:         source = "# frozen_string_literal: true\n" + lazily_defined_methods.values.map(&:call).map(&:to_s).join("\n\n")
// 156:         # rubocop:enable Style/StringConcatenation
// 157:
// 158:         cls = decorated_class
// 159:         cls.class_eval(source)
// 160:         lazily_defined_methods.each_key { |name| cls.send(:private, name) }
// 161:         lazily_defined_methods.clear
// 162:       end
// 163:
// 164:       sig { void }
// 165:       def eagerly_define_lazy_vm_methods!
// 166:         return if lazily_defined_vm_methods.empty?
// 167:
// 168:         lazily_defined_vm_methods.values.map(&:call)
// 169:
// 170:         cls = decorated_class
// 171:         lazily_defined_vm_methods.each_key { |name| cls.send(:private, name) }
// 172:         lazily_defined_vm_methods.clear
// 173:       end
// 174:     end
// 175:   end
// 176: end
