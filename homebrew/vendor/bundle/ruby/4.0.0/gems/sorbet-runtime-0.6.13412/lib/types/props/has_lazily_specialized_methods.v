module props

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/has_lazily_specialized_methods.rb`.
// The original source is retained below until every stub has a typed V body.
pub const source_evaluation_disabled_message = 'Evaluation of lazily-defined methods is disabled'

pub type LazySourceGenerator = fn() string

pub type LazyVmGenerator = fn() !

struct LazySourceDefinition {
pub:
	name      string
	generator LazySourceGenerator @[required]
}

struct LazyVmDefinition {
pub:
	name      string
	generator LazyVmGenerator @[required]
}

@[heap]
pub struct LazyEvaluationConfiguration {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	disabled bool
}

fn new_lazy_evaluation_configuration() &LazyEvaluationConfiguration {
	return &LazyEvaluationConfiguration{}
}

const lazy_evaluation_configuration_global = new_lazy_evaluation_configuration()

fn global_lazy_evaluation_configuration() &LazyEvaluationConfiguration {
	return unsafe { &LazyEvaluationConfiguration(lazy_evaluation_configuration_global) }
}

pub fn disable_lazy_evaluation() {
	mut configuration := global_lazy_evaluation_configuration()
	configuration.mutex.lock()
	configuration.disabled = true
	configuration.mutex.unlock()
}

pub fn lazy_evaluation_enabled() bool {
	mut configuration := global_lazy_evaluation_configuration()
	configuration.mutex.lock()
	enabled := !configuration.disabled
	configuration.mutex.unlock()
	return enabled
}

@[heap]
pub struct LazySpecializedMethods {
	mutex &sync.Mutex = sync.new_mutex()
pub:
	decorated_class string
mut:
	source_definitions []LazySourceDefinition
	vm_definitions     []LazyVmDefinition
	installed_sources  map[string]string
	private_methods    []string
	known_methods      []string
	placeholder_writes map[string]int
	alias_writes       map[string]int
	ruby2_keywords     []string
}

pub fn new_lazy_specialized_methods(decorated_class string, known_methods []string) &LazySpecializedMethods {
	return &LazySpecializedMethods{
		decorated_class: decorated_class
		known_methods: known_methods.clone()
		installed_sources: map[string]string{}
		placeholder_writes: map[string]int{}
		alias_writes: map[string]int{}
	}
}

fn source_definition_index(definitions []LazySourceDefinition, name string) int {
	for index, definition in definitions {
		if definition.name == name {
			return index
		}
	}
	return -1
}

fn vm_definition_index(definitions []LazyVmDefinition, name string) int {
	for index, definition in definitions {
		if definition.name == name {
			return index
		}
	}
	return -1
}

fn lazy_append_unique(mut values []string, value string) {
	if value !in values {
		values << value
	}
}

pub fn (mut methods LazySpecializedMethods) enqueue_source(name string,
	generator LazySourceGenerator, supports_ruby2_keywords bool) bool {
	clean_name := name.trim_string_left(':')
	methods.mutex.lock()
	defer {
		methods.mutex.unlock()
	}
	index := source_definition_index(methods.source_definitions, clean_name)
	definition := LazySourceDefinition{
		name: clean_name
		generator: generator
	}
	if index >= 0 {
		methods.source_definitions[index] = definition
		return false
	}
	methods.source_definitions << definition
	if clean_name in methods.known_methods || clean_name in methods.private_methods {
		methods.alias_writes[clean_name] = methods.alias_writes[clean_name] + 1
	}
	methods.placeholder_writes[clean_name] = methods.placeholder_writes[clean_name] + 1
	if supports_ruby2_keywords {
		lazy_append_unique(mut methods.ruby2_keywords, clean_name)
	}
	lazy_append_unique(mut methods.private_methods, clean_name)
	return true
}

pub fn (mut methods LazySpecializedMethods) enqueue_vm(name string, generator LazyVmGenerator,
	supports_ruby2_keywords bool) bool {
	clean_name := name.trim_string_left(':')
	methods.mutex.lock()
	defer {
		methods.mutex.unlock()
	}
	index := vm_definition_index(methods.vm_definitions, clean_name)
	definition := LazyVmDefinition{
		name: clean_name
		generator: generator
	}
	if index >= 0 {
		methods.vm_definitions[index] = definition
		return false
	}
	methods.vm_definitions << definition
	methods.placeholder_writes[clean_name] = methods.placeholder_writes[clean_name] + 1
	if supports_ruby2_keywords {
		lazy_append_unique(mut methods.ruby2_keywords, clean_name)
	}
	lazy_append_unique(mut methods.private_methods, clean_name)
	return true
}

pub fn (mut methods LazySpecializedMethods) eval_source(name string) !string {
	if !lazy_evaluation_enabled() {
		return error(source_evaluation_disabled_message)
	}
	clean_name := name.trim_string_left(':')
	methods.mutex.lock()
	index := source_definition_index(methods.source_definitions, clean_name)
	if index < 0 {
		methods.mutex.unlock()
		return ''
	}
	definition := methods.source_definitions[index]
	methods.source_definitions.delete(index)
	methods.mutex.unlock()
	source := definition.generator()
	methods.mutex.lock()
	methods.installed_sources[clean_name] = source
	lazy_append_unique(mut methods.private_methods, clean_name)
	methods.mutex.unlock()
	return source
}

pub fn (mut methods LazySpecializedMethods) eval_vm(name string) !bool {
	if !lazy_evaluation_enabled() {
		return error(source_evaluation_disabled_message)
	}
	clean_name := name.trim_string_left(':')
	methods.mutex.lock()
	index := vm_definition_index(methods.vm_definitions, clean_name)
	if index < 0 {
		methods.mutex.unlock()
		return false
	}
	definition := methods.vm_definitions[index]
	methods.vm_definitions.delete(index)
	methods.mutex.unlock()
	definition.generator()!
	methods.mutex.lock()
	lazy_append_unique(mut methods.private_methods, clean_name)
	methods.mutex.unlock()
	return true
}

pub fn (mut methods LazySpecializedMethods) eagerly_define_sources() string {
	methods.mutex.lock()
	definitions := methods.source_definitions.clone()
	methods.source_definitions.clear()
	methods.mutex.unlock()
	if definitions.len == 0 {
		return ''
	}
	mut generated := []string{cap: definitions.len}
	for definition in definitions {
		source := definition.generator()
		generated << source
		methods.mutex.lock()
		methods.installed_sources[definition.name] = source
		lazy_append_unique(mut methods.private_methods, definition.name)
		methods.mutex.unlock()
	}
	return '# frozen_string_literal: true\n' + generated.join('\n\n')
}

pub fn (mut methods LazySpecializedMethods) eagerly_define_vm_methods() !int {
	methods.mutex.lock()
	definitions := methods.vm_definitions.clone()
	methods.vm_definitions.clear()
	methods.mutex.unlock()
	for definition in definitions {
		definition.generator()!
		methods.mutex.lock()
		lazy_append_unique(mut methods.private_methods, definition.name)
		methods.mutex.unlock()
	}
	return definitions.len
}

pub fn (mut methods LazySpecializedMethods) source_names() []string {
	methods.mutex.lock()
	names := methods.source_definitions.map(it.name)
	methods.mutex.unlock()
	return names
}

pub fn (mut methods LazySpecializedMethods) vm_names() []string {
	methods.mutex.lock()
	names := methods.vm_definitions.map(it.name)
	methods.mutex.unlock()
	return names
}

fn lazy_methods_value(methods &LazySpecializedMethods) brew_runtime.Value {
	return brew_runtime.structured_value('T::Props::Decorator', methods.decorated_class, {
		'lazy_methods_address': u64(voidptr(methods)).str()
		'decorated_class':      methods.decorated_class
	})
}

fn lazy_methods_from_value(value brew_runtime.Value) &LazySpecializedMethods {
	address := value.attribute('lazy_methods_address') or {
		panic('invalid lazy-specialized-methods receiver')
	}
	return unsafe { &LazySpecializedMethods(voidptr(address.u64())) }
}

fn lazy_name(value brew_runtime.Value) string {
	return value.as_string().trim_string_left(':')
}

fn boundary_source_generator(value brew_runtime.Value) string {
	return value.map_data['result'] or { value }.as_string()
}

fn boundary_vm_generator() ! {}

fn lazy_names_value(names []string, kind string) brew_runtime.Value {
	mut entries := map[string]brew_runtime.Value{}
	for name in names {
		entries[name] = brew_runtime.object_value(kind, name)
	}
	return brew_runtime.map_value(entries)
}

// Ruby method `initialize` at line 21.
pub fn ruby_has_lazily_specialized_methods_l21_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('T::Props::SourceEvaluationDisabled', source_evaluation_disabled_message, {
		'message': source_evaluation_disabled_message
	})
}

// Ruby method `self.disable_lazy_evaluation!` at line 34.
pub fn ruby_has_lazily_specialized_methods_l34_d2_self_disable_lazy_evaluation(args ...brew_runtime.Value) brew_runtime.Value {
	disable_lazy_evaluation()
	return brew_runtime.bool_value(true)
}

// Ruby method `self.lazy_evaluation_enabled?` at line 39.
pub fn ruby_has_lazily_specialized_methods_l39_d3_self_lazy_evaluation_enabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(lazy_evaluation_enabled())
}

// Ruby method `lazily_defined_methods` at line 47.
pub fn ruby_has_lazily_specialized_methods_l47_d4_lazily_defined_methods(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('lazily_defined_methods requires a decorator receiver')
	}
	mut methods := lazy_methods_from_value(args[0])
	return lazy_names_value(methods.source_names(), 'Proc')
}

// Ruby method `lazily_defined_vm_methods` at line 52.
pub fn ruby_has_lazily_specialized_methods_l52_d5_lazily_defined_vm_methods(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('lazily_defined_vm_methods requires a decorator receiver')
	}
	mut methods := lazy_methods_from_value(args[0])
	return lazy_names_value(methods.vm_names(), 'Proc')
}

// Ruby method `eval_lazily_defined_method!(name)` at line 57.
pub fn ruby_has_lazily_specialized_methods_l57_d6_eval_lazily_defined_method(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('eval_lazily_defined_method! requires a receiver and method name')
	}
	mut methods := lazy_methods_from_value(args[0])
	methods.eval_source(lazy_name(args[1])) or { panic(err) }
	return props_nil_value()
}

// Ruby method `eval_lazily_defined_vm_method!(name)` at line 82.
pub fn ruby_has_lazily_specialized_methods_l82_d7_eval_lazily_defined_vm_method(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('eval_lazily_defined_vm_method! requires a receiver and method name')
	}
	mut methods := lazy_methods_from_value(args[0])
	methods.eval_vm(lazy_name(args[1])) or { panic(err) }
	return props_nil_value()
}

// Ruby method `enqueue_lazy_method_definition!(name, &blk)` at line 99.
pub fn ruby_has_lazily_specialized_methods_l99_d8_enqueue_lazy_method_definition(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('enqueue_lazy_method_definition! requires a receiver, method name, and generator')
	}
	mut methods := lazy_methods_from_value(args[0])
	source := boundary_source_generator(args[2])
	methods.enqueue_source(lazy_name(args[1]), fn [source] () string {
		return source
	}, args[0].attributes['ruby2_keywords'] or { 'false' } == 'true')
	return props_nil_value()
}

// Ruby alias_method `cls.send(:alias_method, name, name)` at line 117.
pub fn ruby_has_lazily_specialized_methods_l117_d9_alias_method_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('alias_method requires a receiver and method name')
	}
	return args[1]
}

// Ruby define_method `cls.send(:define_method, name) do |*args|` at line 119.
pub fn ruby_has_lazily_specialized_methods_l119_d10_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('lazy source placeholder requires a receiver and method name')
	}
	ruby_has_lazily_specialized_methods_l57_d6_eval_lazily_defined_method(args[0], args[1])
	return brew_runtime.array_value(args[2..])
}

// Ruby method `enqueue_lazy_vm_method_definition!(name, &blk)` at line 130.
pub fn ruby_has_lazily_specialized_methods_l130_d11_enqueue_lazy_vm_method_definition(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('enqueue_lazy_vm_method_definition! requires a receiver, method name, and generator')
	}
	mut methods := lazy_methods_from_value(args[0])
	methods.enqueue_vm(lazy_name(args[1]), boundary_vm_generator, args[0].attributes['ruby2_keywords'] or {
		'false'
	} == 'true')
	return props_nil_value()
}

// Ruby define_method `cls.send(:define_method, name) do |*args|` at line 140.
pub fn ruby_has_lazily_specialized_methods_l140_d12_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('lazy VM placeholder requires a receiver and method name')
	}
	ruby_has_lazily_specialized_methods_l82_d7_eval_lazily_defined_vm_method(args[0], args[1])
	return brew_runtime.array_value(args[2..])
}

// Ruby method `eagerly_define_lazy_methods!` at line 151.
pub fn ruby_has_lazily_specialized_methods_l151_d13_eagerly_define_lazy_methods(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('eagerly_define_lazy_methods! requires a decorator receiver')
	}
	mut methods := lazy_methods_from_value(args[0])
	methods.eagerly_define_sources()
	return props_nil_value()
}

// Ruby method `eagerly_define_lazy_vm_methods!` at line 165.
pub fn ruby_has_lazily_specialized_methods_l165_d14_eagerly_define_lazy_vm_methods(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('eagerly_define_lazy_vm_methods! requires a decorator receiver')
	}
	mut methods := lazy_methods_from_value(args[0])
	methods.eagerly_define_vm_methods() or { panic(err) }
	return props_nil_value()
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
