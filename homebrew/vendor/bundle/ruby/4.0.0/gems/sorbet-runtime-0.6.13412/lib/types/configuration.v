module types

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/configuration.rb`.
// The original source is retained below until every stub has a typed V body.
pub type ConfigurationHandler = fn([]brew_runtime.Value) !brew_runtime.Value

struct ConfigurationHandlerEntry {
	name    string
	handler ConfigurationHandler @[required]
}

@[heap]
pub struct ConfigurationState {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	checking_tests              bool
	final_checks_on_hooks       bool
	include_value_in_errors     bool = true
	default_checked_level       string = 'always'
	handler_values              map[string]brew_runtime.Value
	typed_handlers              []ConfigurationHandlerEntry
	scalar_types_override       ?map[string]bool
	module_name_mangler         brew_runtime.Value
	sensitivity_and_pii_handler brew_runtime.Value
	redaction_handler           brew_runtime.Value
	legacy_t_enum_mode          bool
	sealed_whitelist_set        bool
	sealed_whitelist            []string
}

pub fn new_configuration_state() &ConfigurationState {
	return &ConfigurationState{
		handler_values: map[string]brew_runtime.Value{}
		module_name_mangler: configuration_nil_value()
		sensitivity_and_pii_handler: configuration_nil_value()
		redaction_handler: configuration_nil_value()
	}
}

const configuration_global = new_configuration_state()

fn global_configuration() &ConfigurationState {
	return unsafe { &ConfigurationState(configuration_global) }
}

fn configuration_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn configuration_truthy(value brew_runtime.Value) bool {
	return value.type_name != 'NilClass' && !(value.type_name == 'Bool' && !value.bool_data)
}

fn configuration_handler_index(entries []ConfigurationHandlerEntry, name string) int {
	for index, entry in entries {
		if entry.name == name {
			return index
		}
	}
	return -1
}

pub fn (mut state ConfigurationState) set_typed_handler(name string,
	handler ConfigurationHandler) {
	state.mutex.lock()
	index := configuration_handler_index(state.typed_handlers, name)
	entry := ConfigurationHandlerEntry{
		name: name
		handler: handler
	}
	if index >= 0 {
		state.typed_handlers[index] = entry
	} else {
		state.typed_handlers << entry
	}
	state.mutex.unlock()
}

pub fn (mut state ConfigurationState) set_handler_value(name string,
	value brew_runtime.Value) ! {
	validate_configuration_callable(value)!
	state.mutex.lock()
	if value.type_name == 'NilClass' {
		state.handler_values.delete(name)
	} else {
		state.handler_values[name] = value
	}
	state.mutex.unlock()
}

fn configuration_handler_result(value brew_runtime.Value) brew_runtime.Value {
	return value.map_data['result'] or { configuration_nil_value() }
}

pub fn (mut state ConfigurationState) call_handler(name string,
	arguments []brew_runtime.Value) !brew_runtime.Value {
	state.mutex.lock()
	index := configuration_handler_index(state.typed_handlers, name)
	typed := if index >= 0 {
		state.typed_handlers[index..index + 1].clone()
	} else {
		[]ConfigurationHandlerEntry{}
	}
	descriptor := state.handler_values[name] or { configuration_nil_value() }
	state.mutex.unlock()
	if typed.len == 1 {
		return typed[0].handler(arguments)!
	}
	if descriptor.type_name != 'NilClass' {
		return configuration_handler_result(descriptor)
	}
	return state.call_default_handler(name, arguments)!
}

fn configuration_error_message(value brew_runtime.Value) string {
	return value.attribute('message') or { value.as_string() }
}

fn configuration_location(value brew_runtime.Value) string {
	path := value.attribute('path') or { '<unknown>' }
	line := value.attribute('lineno') or { '0' }
	return '${path}:${line}'
}

fn configuration_options(value brew_runtime.Value) map[string]brew_runtime.Value {
	return if value.type_name == 'Hash' {
		value.map_data.clone()
	} else {
		map[string]brew_runtime.Value{}
	}
}

fn (mut state ConfigurationState) call_default_handler(name string,
	arguments []brew_runtime.Value) !brew_runtime.Value {
	match name {
		'inline_type_error', 'sig_validation_error' {
			if arguments.len == 0 {
				return error('missing type error')
			}
			return error(configuration_error_message(arguments[0]))
		}
		'sig_builder_error' {
			if arguments.len < 2 {
				return error('missing sig builder error context')
			}
			return error('${configuration_location(arguments[1])}: Error interpreting `sig`:\n  ${configuration_error_message(arguments[0])}\n')
		}
		'call_validation_error' {
			options := if arguments.len > 1 {
				configuration_options(arguments[1])
			} else {
				map[string]brew_runtime.Value{}
			}
			message := options['pretty_message'] or { options['message'] or { brew_runtime.string_value('Type validation failed') } }
			return error(message.as_string())
		}
		'log_info', 'soft_assert' {
			message := if arguments.len > 0 { arguments[0].as_string() } else { '' }
			extra := if arguments.len > 1 { arguments[1].as_string() } else { '{}' }
			println('${message}, extra: ${extra}')
			return configuration_nil_value()
		}
		else {
			return configuration_nil_value()
		}
	}
}

pub fn (mut state ConfigurationState) set_include_value(include bool) {
	state.mutex.lock()
	state.include_value_in_errors = include
	state.mutex.unlock()
}

pub fn (mut state ConfigurationState) includes_value() bool {
	state.mutex.lock()
	value := state.include_value_in_errors
	state.mutex.unlock()
	return value
}

pub fn (mut state ConfigurationState) set_checked_level(level string) ! {
	clean := level.trim_string_left(':')
	if clean !in ['never', 'tests', 'always'] {
		return error("Invalid `checked` level '${clean}'. Use one of: ['always', 'tests', 'never'].")
	}
	state.mutex.lock()
	state.default_checked_level = clean
	state.mutex.unlock()
}

pub fn (mut state ConfigurationState) set_scalar_types(values brew_runtime.Value) ! {
	state.mutex.lock()
	defer {
		state.mutex.unlock()
	}
	if values.type_name == 'NilClass' {
		state.scalar_types_override = none
		return
	}
	if values.type_name != 'Array' {
		return error('Provided values must all be class name strings.')
	}
	items := if values.array_data.len > 0 {
		values.array_data.clone()
	} else {
		values.string_array_data.map(brew_runtime.string_value(it))
	}
	if items.any(it.type_name != 'String') {
		return error('Provided values must all be class name strings.')
	}
	mut scalar := map[string]bool{}
	for item in items {
		scalar[item.as_string()] = true
	}
	state.scalar_types_override = scalar.clone()
}

const configuration_default_scalar_types = ['NilClass', 'TrueClass', 'FalseClass', 'Integer', 'Float',
	'String', 'Symbol', 'Time', 'T::Enum']

pub fn (mut state ConfigurationState) scalar_types() map[string]bool {
	state.mutex.lock()
	defer {
		state.mutex.unlock()
	}
	if override := state.scalar_types_override {
		return override.clone()
	}
	mut defaults := map[string]bool{}
	for name in configuration_default_scalar_types {
		defaults[name] = true
	}
	return defaults
}

pub fn validate_configuration_callable(value brew_runtime.Value) ! {
	if value.type_name == 'NilClass' {
		return
	}
	if value.type_name in ['Proc', 'Lambda', 'Method'] {
		return
	}
	if value.attribute('responds_to_call') or { 'false' } == 'true' {
		return
	}
	return error('Provided value must respond to :call')
}

pub fn (mut state ConfigurationState) set_sealed_whitelist(value brew_runtime.Value) ! {
	state.mutex.lock()
	defer {
		state.mutex.unlock()
	}
	if state.sealed_whitelist_set {
		return error('Cannot overwrite sealed_violation_whitelist after setting it')
	}
	if value.type_name != 'Array' {
		return error('sealed_violation_whitelist= accepts an Array of Regexp')
	}
	items := value.array_data
	if items.any(it.type_name != 'Regexp') {
		return error('sealed_violation_whitelist accepts an Array of Regexp')
	}
	state.sealed_whitelist = items.map(it.as_string())
	state.sealed_whitelist_set = true
}

fn configuration_map_bool(values map[string]bool) brew_runtime.Value {
	mut output := map[string]brew_runtime.Value{}
	for key, value in values {
		output[key] = brew_runtime.bool_value(value)
	}
	return brew_runtime.map_value(output)
}

fn configuration_handler_from_args(args []brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return configuration_nil_value()
	}
	return args[args.len - 1]
}

fn configuration_invoke(name string, args []brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	return state.call_handler(name, args) or { panic(err) }
}

// Ruby method `self.enable_checking_for_sigs_marked_checked_tests` at line 16.
pub fn ruby_configuration_l16_d1_self_enable_checking_for_sigs_marked_checked_tests(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	state.checking_tests = true
	state.mutex.unlock()
	return configuration_nil_value()
}

// Ruby method `self.enable_final_checks_on_hooks` at line 35.
pub fn ruby_configuration_l35_d2_self_enable_final_checks_on_hooks(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	state.final_checks_on_hooks = true
	state.mutex.unlock()
	return brew_runtime.bool_value(true)
}

// Ruby method `self.reset_final_checks_on_hooks` at line 41.
pub fn ruby_configuration_l41_d3_self_reset_final_checks_on_hooks(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	state.final_checks_on_hooks = false
	state.mutex.unlock()
	return brew_runtime.bool_value(false)
}

// Ruby method `self.include_value_in_type_errors?` at line 52.
pub fn ruby_configuration_l52_d4_self_include_value_in_type_errors(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	return brew_runtime.bool_value(state.includes_value())
}

// Ruby method `self.exclude_value_in_type_errors` at line 63.
pub fn ruby_configuration_l63_d5_self_exclude_value_in_type_errors(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.set_include_value(false)
	return brew_runtime.bool_value(false)
}

// Ruby method `self.include_value_in_type_errors` at line 69.
pub fn ruby_configuration_l69_d6_self_include_value_in_type_errors(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.set_include_value(true)
	return brew_runtime.bool_value(true)
}

// Ruby method `self.default_checked_level=(default_checked_level)` at line 82.
pub fn ruby_configuration_l82_d7_self_default_checked_level(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('default_checked_level= requires a level')
	}
	mut state := global_configuration()
	state.set_checked_level(args[args.len - 1].as_string()) or { panic(err) }
	return args[args.len - 1]
}

// Ruby method `self.inline_type_error_handler=(value)` at line 111.
pub fn ruby_configuration_l111_d8_self_inline_type_error_handler(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	value := configuration_handler_from_args(args)
	state.set_handler_value('inline_type_error', value) or { panic(err) }
	return value
}

// Ruby method `self.inline_type_error_handler_default(error, opts)` at line 116.
pub fn ruby_configuration_l116_d9_self_inline_type_error_handler_default(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	return state.call_default_handler('inline_type_error', args) or { panic(err) }
}

// Ruby method `self.inline_type_error_handler(error, opts={})` at line 120.
pub fn ruby_configuration_l120_d10_self_inline_type_error_handler(args ...brew_runtime.Value) brew_runtime.Value {
	return configuration_invoke('inline_type_error', args)
}

// Ruby method `self.sig_builder_error_handler=(value)` at line 157.
pub fn ruby_configuration_l157_d11_self_sig_builder_error_handler(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	value := configuration_handler_from_args(args)
	state.set_handler_value('sig_builder_error', value) or { panic(err) }
	return value
}

// Ruby method `self.sig_builder_error_handler_default(error, location)` at line 162.
pub fn ruby_configuration_l162_d12_self_sig_builder_error_handler_default(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	return state.call_default_handler('sig_builder_error', args) or { panic(err) }
}

// Ruby method `self.sig_builder_error_handler(error, location)` at line 166.
pub fn ruby_configuration_l166_d13_self_sig_builder_error_handler(args ...brew_runtime.Value) brew_runtime.Value {
	return configuration_invoke('sig_builder_error', args)
}

// Ruby method `self.sig_validation_error_handler=(value)` at line 208.
pub fn ruby_configuration_l208_d14_self_sig_validation_error_handler(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	value := configuration_handler_from_args(args)
	state.set_handler_value('sig_validation_error', value) or { panic(err) }
	return value
}

// Ruby method `self.sig_validation_error_handler_default(error, opts)` at line 213.
pub fn ruby_configuration_l213_d15_self_sig_validation_error_handler_default(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	return state.call_default_handler('sig_validation_error', args) or { panic(err) }
}

// Ruby method `self.sig_validation_error_handler(error, opts={})` at line 217.
pub fn ruby_configuration_l217_d16_self_sig_validation_error_handler(args ...brew_runtime.Value) brew_runtime.Value {
	return configuration_invoke('sig_validation_error', args)
}

// Ruby method `self.call_validation_error_handler=(value)` at line 255.
pub fn ruby_configuration_l255_d17_self_call_validation_error_handler(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	value := configuration_handler_from_args(args)
	state.set_handler_value('call_validation_error', value) or { panic(err) }
	return value
}

// Ruby method `self.call_validation_error_handler_default(signature, opts)` at line 260.
pub fn ruby_configuration_l260_d18_self_call_validation_error_handler_default(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	return state.call_default_handler('call_validation_error', args) or { panic(err) }
}

// Ruby method `self.call_validation_error_handler(signature, opts={})` at line 264.
pub fn ruby_configuration_l264_d19_self_call_validation_error_handler(args ...brew_runtime.Value) brew_runtime.Value {
	return configuration_invoke('call_validation_error', args)
}

// Ruby method `self.log_info_handler=(value)` at line 288.
pub fn ruby_configuration_l288_d20_self_log_info_handler(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	value := configuration_handler_from_args(args)
	state.set_handler_value('log_info', value) or { panic(err) }
	return value
}

// Ruby method `self.log_info_handler_default(str, extra)` at line 293.
pub fn ruby_configuration_l293_d21_self_log_info_handler_default(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	return state.call_default_handler('log_info', args) or { panic(err) }
}

// Ruby method `self.log_info_handler(str, extra)` at line 297.
pub fn ruby_configuration_l297_d22_self_log_info_handler(args ...brew_runtime.Value) brew_runtime.Value {
	return configuration_invoke('log_info', args)
}

// Ruby method `self.soft_assert_handler=(value)` at line 323.
pub fn ruby_configuration_l323_d23_self_soft_assert_handler(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	value := configuration_handler_from_args(args)
	state.set_handler_value('soft_assert', value) or { panic(err) }
	return value
}

// Ruby method `self.soft_assert_handler_default(str, extra)` at line 328.
pub fn ruby_configuration_l328_d24_self_soft_assert_handler_default(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	return state.call_default_handler('soft_assert', args) or { panic(err) }
}

// Ruby method `self.soft_assert_handler(str, extra)` at line 332.
pub fn ruby_configuration_l332_d25_self_soft_assert_handler(args ...brew_runtime.Value) brew_runtime.Value {
	return configuration_invoke('soft_assert', args)
}

// Ruby method `self.scalar_types=(values)` at line 348.
pub fn ruby_configuration_l348_d26_self_scalar_types(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('scalar_types= requires an Array or nil')
	}
	mut state := global_configuration()
	state.set_scalar_types(args[args.len - 1]) or { panic(err) }
	return args[args.len - 1]
}

// Ruby method `self.scalar_types` at line 373.
pub fn ruby_configuration_l373_d27_self_scalar_types(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	return configuration_map_bool(state.scalar_types())
}

// Ruby method `self.module_name_mangler` at line 385.
pub fn ruby_configuration_l385_d28_self_module_name_mangler(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	handler := state.module_name_mangler
	state.mutex.unlock()
	return if handler.type_name == 'NilClass' {
		brew_runtime.object_value('Proc', 'Module.instance_method(:name)')
	} else {
		handler
	}
}

// Ruby method `self.module_name_mangler=(handler)` at line 395.
pub fn ruby_configuration_l395_d29_self_module_name_mangler(args ...brew_runtime.Value) brew_runtime.Value {
	value := configuration_handler_from_args(args)
	mut state := global_configuration()
	state.mutex.lock()
	state.module_name_mangler = value
	state.mutex.unlock()
	return value
}

// Ruby method `self.normalize_sensitivity_and_pii_handler=(handler)` at line 405.
pub fn ruby_configuration_l405_d30_self_normalize_sensitivity_and_pii_handler(args ...brew_runtime.Value) brew_runtime.Value {
	value := configuration_handler_from_args(args)
	mut state := global_configuration()
	state.mutex.lock()
	state.sensitivity_and_pii_handler = value
	state.mutex.unlock()
	return value
}

// Ruby method `self.normalize_sensitivity_and_pii_handler` at line 409.
pub fn ruby_configuration_l409_d31_self_normalize_sensitivity_and_pii_handler(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	value := state.sensitivity_and_pii_handler
	state.mutex.unlock()
	return value
}

// Ruby method `self.redaction_handler=(handler)` at line 421.
pub fn ruby_configuration_l421_d32_self_redaction_handler(args ...brew_runtime.Value) brew_runtime.Value {
	value := configuration_handler_from_args(args)
	mut state := global_configuration()
	state.mutex.lock()
	state.redaction_handler = value
	state.mutex.unlock()
	return value
}

// Ruby method `self.redaction_handler` at line 425.
pub fn ruby_configuration_l425_d33_self_redaction_handler(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	value := state.redaction_handler
	state.mutex.unlock()
	return value
}

// Ruby method `self.without_ruby_warnings` at line 435.
pub fn ruby_configuration_l435_d34_self_without_ruby_warnings(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return configuration_nil_value()
	}
	block := args[args.len - 1]
	return block.map_data['result'] or { block }
}

// Ruby method `self.enable_legacy_t_enum_migration_mode` at line 450.
pub fn ruby_configuration_l450_d35_self_enable_legacy_t_enum_migration_mode(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	state.legacy_t_enum_mode = true
	state.mutex.unlock()
	return brew_runtime.bool_value(true)
}

// Ruby method `self.disable_legacy_t_enum_migration_mode` at line 454.
pub fn ruby_configuration_l454_d36_self_disable_legacy_t_enum_migration_mode(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	state.legacy_t_enum_mode = false
	state.mutex.unlock()
	return brew_runtime.bool_value(false)
}

// Ruby method `self.legacy_t_enum_migration_mode?` at line 457.
pub fn ruby_configuration_l457_d37_self_legacy_t_enum_migration_mode(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	enabled := state.legacy_t_enum_mode
	state.mutex.unlock()
	return brew_runtime.bool_value(enabled)
}

// Ruby method `self.sealed_violation_whitelist=(sealed_violation_whitelist)` at line 466.
pub fn ruby_configuration_l466_d38_self_sealed_violation_whitelist(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('sealed_violation_whitelist= requires an Array of Regexp')
	}
	mut state := global_configuration()
	state.set_sealed_whitelist(args[args.len - 1]) or { panic(err) }
	return args[args.len - 1]
}

// Ruby method `self.sealed_violation_whitelist` at line 485.
pub fn ruby_configuration_l485_d39_self_sealed_violation_whitelist(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := global_configuration()
	state.mutex.lock()
	set := state.sealed_whitelist_set
	values := state.sealed_whitelist.clone()
	state.mutex.unlock()
	return if set {
		brew_runtime.array_value(values.map(brew_runtime.object_value('Regexp', it)))
	} else {
		configuration_nil_value()
	}
}

// Ruby method `self.validate_lambda_given!(value)` at line 489.
pub fn ruby_configuration_l489_d40_self_validate_lambda_given(args ...brew_runtime.Value) brew_runtime.Value {
	value := configuration_handler_from_args(args)
	validate_configuration_callable(value) or { panic(err) }
	return configuration_nil_value()
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Configuration
// 5:   # Announces to Sorbet that we are currently in a test environment, so it
// 6:   # should treat any sigs which are marked `.checked(:tests)` as if they were
// 7:   # just a normal sig.
// 8:   #
// 9:   # If this method is not called, sigs marked `.checked(:tests)` will not be
// 10:   # checked. In fact, such methods won't even be wrapped--the runtime will put
// 11:   # back the original method.
// 12:   #
// 13:   # Note: Due to the way sigs are evaluated and methods are wrapped, this
// 14:   # method MUST be called before any code calls `sig`. This method raises if
// 15:   # it has been called too late.
// 16:   def self.enable_checking_for_sigs_marked_checked_tests
// 17:     T::Private::RuntimeLevels.enable_checking_in_tests
// 18:   end
// 19:
// 20:   # Announce to Sorbet that we would like the final checks to be enabled when
// 21:   # including and extending modules. Iff this is not called, then the following
// 22:   # example will not raise an error.
// 23:   #
// 24:   # ```ruby
// 25:   # module M
// 26:   #   extend T::Sig
// 27:   #   sig(:final) {void}
// 28:   #   def foo; end
// 29:   # end
// 30:   # class C
// 31:   #   include M
// 32:   #   def foo; end
// 33:   # end
// 34:   # ```
// 35:   def self.enable_final_checks_on_hooks
// 36:     T::Private::Methods.set_final_checks_on_hooks(true)
// 37:   end
// 38:
// 39:   # Undo the effects of a previous call to
// 40:   # `enable_final_checks_on_hooks`.
// 41:   def self.reset_final_checks_on_hooks
// 42:     T::Private::Methods.set_final_checks_on_hooks(false)
// 43:   end
// 44:
// 45:   @include_value_in_type_errors = true
// 46:   # Whether to include values in TypeError messages.
// 47:   #
// 48:   # Including values is useful for debugging, but can potentially leak
// 49:   # sensitive information to logs.
// 50:   #
// 51:   # @return [T::Boolean]
// 52:   def self.include_value_in_type_errors?
// 53:     @include_value_in_type_errors
// 54:   end
// 55:
// 56:   # Configure if type errors excludes the value of the problematic type.
// 57:   #
// 58:   # The default is to include values in type errors:
// 59:   #   TypeError: Expected type Integer, got String with value "foo"
// 60:   #
// 61:   # When values are excluded from type errors:
// 62:   #   TypeError: Expected type Integer, got String
// 63:   def self.exclude_value_in_type_errors
// 64:     @include_value_in_type_errors = false
// 65:   end
// 66:
// 67:   # Opposite of exclude_value_in_type_errors.
// 68:   # (Including values in type errors is the default)
// 69:   def self.include_value_in_type_errors
// 70:     @include_value_in_type_errors = true
// 71:   end
// 72:
// 73:   # Configure the default checked level for a sig with no explicit `.checked`
// 74:   # builder. When unset, the default checked level is `:always`.
// 75:   #
// 76:   # Note: setting this option is potentially dangerous! Sorbet can't check all
// 77:   # code statically. The runtime checks complement the checks that Sorbet does
// 78:   # statically, so that methods don't have to guard themselves from being
// 79:   # called incorrectly by untyped code.
// 80:   #
// 81:   # @param [:never, :tests, :always] default_checked_level
// 82:   def self.default_checked_level=(default_checked_level)
// 83:     T::Private::RuntimeLevels.default_checked_level = default_checked_level
// 84:   end
// 85:
// 86:   @inline_type_error_handler = nil
// 87:   # Set a handler to handle `TypeError`s raised by any in-line type assertions,
// 88:   # including `T.must`, `T.let`, `T.cast`, and `T.assert_type!`.
// 89:   #
// 90:   # By default, any `TypeError`s detected by this gem will be raised. Setting
// 91:   # inline_type_error_handler to an object that implements :call (e.g. proc or
// 92:   # lambda) allows users to customize the behavior when a `TypeError` is
// 93:   # raised on any inline type assertion.
// 94:   #
// 95:   # @param [Lambda, Proc, Object, nil] value Proc that handles the error (pass
// 96:   #   nil to reset to default behavior)
// 97:   #
// 98:   # Parameters passed to value.call:
// 99:   #
// 100:   #  @param [TypeError] error TypeError that was raised
// 101:   #  @param [Hash] opts A hash containing contextual information on the error:
// 102:   #  @option opts [String] :kind One of:
// 103:   #    ['T.cast', 'T.let', 'T.bind', 'T.assert_type!', 'T.must', 'T.absurd']
// 104:   #  @option opts [Object, nil] :type Expected param/return value type
// 105:   #  @option opts [Object] :value Actual param/return value
// 106:   #
// 107:   # @example
// 108:   #   T::Configuration.inline_type_error_handler = lambda do |error, opts|
// 109:   #     puts error.message
// 110:   #   end
// 111:   def self.inline_type_error_handler=(value)
// 112:     validate_lambda_given!(value)
// 113:     @inline_type_error_handler = value
// 114:   end
// 115:
// 116:   private_class_method def self.inline_type_error_handler_default(error, opts)
// 117:     raise error
// 118:   end
// 119:
// 120:   def self.inline_type_error_handler(error, opts={})
// 121:     if @inline_type_error_handler
// 122:       # Backwards compatibility before `inline_type_error_handler` took a second arg
// 123:       if @inline_type_error_handler.arity == 1
// 124:         @inline_type_error_handler.call(error)
// 125:       else
// 126:         @inline_type_error_handler.call(error, opts)
// 127:       end
// 128:     else
// 129:       inline_type_error_handler_default(error, opts)
// 130:     end
// 131:     nil
// 132:   end
// 133:
// 134:   @sig_builder_error_handler = nil
// 135:   # Set a handler to handle errors that occur when the builder methods in the
// 136:   # body of a sig are executed. The sig builder methods are inside a proc so
// 137:   # that they can be lazily evaluated the first time the method being sig'd is
// 138:   # called.
// 139:   #
// 140:   # By default, improper use of the builder methods within the body of a sig
// 141:   # cause an ArgumentError to be raised. Setting sig_builder_error_handler to an
// 142:   # object that implements :call (e.g. proc or lambda) allows users to
// 143:   # customize the behavior when a sig can't be built for some reason.
// 144:   #
// 145:   # @param [Lambda, Proc, Object, nil] value Proc that handles the error (pass
// 146:   #   nil to reset to default behavior)
// 147:   #
// 148:   # Parameters passed to value.call:
// 149:   #
// 150:   #  @param [StandardError] error The error that was raised
// 151:   #  @param [Thread::Backtrace::Location] location Location of the error
// 152:   #
// 153:   # @example
// 154:   #   T::Configuration.sig_builder_error_handler = lambda do |error, location|
// 155:   #     puts error.message
// 156:   #   end
// 157:   def self.sig_builder_error_handler=(value)
// 158:     validate_lambda_given!(value)
// 159:     @sig_builder_error_handler = value
// 160:   end
// 161:
// 162:   private_class_method def self.sig_builder_error_handler_default(error, location)
// 163:     raise ArgumentError.new("#{location.path}:#{location.lineno}: Error interpreting `sig`:\n  #{error.message}\n\n")
// 164:   end
// 165:
// 166:   def self.sig_builder_error_handler(error, location)
// 167:     if @sig_builder_error_handler
// 168:       @sig_builder_error_handler.call(error, location)
// 169:     else
// 170:       sig_builder_error_handler_default(error, location)
// 171:     end
// 172:     nil
// 173:   end
// 174:
// 175:   @sig_validation_error_handler = nil
// 176:   # Set a handler to handle sig validation errors.
// 177:   #
// 178:   # Sig validation errors include things like abstract checks, override checks,
// 179:   # and type compatibility of arguments. They happen after a sig has been
// 180:   # successfully built, but the built sig is incompatible with other sigs in
// 181:   # some way.
// 182:   #
// 183:   # By default, sig validation errors cause an exception to be raised.
// 184:   # Setting sig_validation_error_handler to an object that implements :call
// 185:   # (e.g. proc or lambda) allows users to customize the behavior when a method
// 186:   # signature's build fails.
// 187:   #
// 188:   # @param [Lambda, Proc, Object, nil] value Proc that handles the error (pass
// 189:   #   nil to reset to default behavior)
// 190:   #
// 191:   # Parameters passed to value.call:
// 192:   #
// 193:   #  @param [StandardError] error The error that was raised
// 194:   #  @param [Hash] opts A hash containing contextual information on the error:
// 195:   #  @option opts [Method, UnboundMethod] :method Method on which the signature build failed
// 196:   #  @option opts [T::Private::Methods::Declaration] :declaration Method
// 197:   #    signature declaration struct
// 198:   #  @option opts [T::Private::Methods::Signature, nil] :signature Signature
// 199:   #    that failed (nil if sig build failed before Signature initialization)
// 200:   #  @option opts [T::Private::Methods::Signature, nil] :super_signature Super
// 201:   #    method's signature (nil if method is not an override or super method
// 202:   #    does not have a method signature)
// 203:   #
// 204:   # @example
// 205:   #   T::Configuration.sig_validation_error_handler = lambda do |error, opts|
// 206:   #     puts error.message
// 207:   #   end
// 208:   def self.sig_validation_error_handler=(value)
// 209:     validate_lambda_given!(value)
// 210:     @sig_validation_error_handler = value
// 211:   end
// 212:
// 213:   private_class_method def self.sig_validation_error_handler_default(error, opts)
// 214:     raise error
// 215:   end
// 216:
// 217:   def self.sig_validation_error_handler(error, opts={})
// 218:     if @sig_validation_error_handler
// 219:       @sig_validation_error_handler.call(error, opts)
// 220:     else
// 221:       sig_validation_error_handler_default(error, opts)
// 222:     end
// 223:     nil
// 224:   end
// 225:
// 226:   @call_validation_error_handler = nil
// 227:   # Set a handler for type errors that result from calling a method.
// 228:   #
// 229:   # By default, errors from calling a method cause an exception to be raised.
// 230:   # Setting call_validation_error_handler to an object that implements :call
// 231:   # (e.g. proc or lambda) allows users to customize the behavior when a method
// 232:   # is called with invalid parameters, or returns an invalid value.
// 233:   #
// 234:   # @param [Lambda, Proc, Object, nil] value Proc that handles the error
// 235:   #   report (pass nil to reset to default behavior)
// 236:   #
// 237:   # Parameters passed to value.call:
// 238:   #
// 239:   #  @param [T::Private::Methods::Signature] signature Signature that failed
// 240:   #  @param [Hash] opts A hash containing contextual information on the error:
// 241:   #  @option opts [String] :message Error message
// 242:   #  @option opts [String] :kind One of:
// 243:   #    ['Parameter', 'Block parameter', 'Return value']
// 244:   #  @option opts [Symbol] :name Param or block param name (nil for return
// 245:   #    value)
// 246:   #  @option opts [Object] :type Expected param/return value type
// 247:   #  @option opts [Object] :value Actual param/return value
// 248:   #  @option opts [Thread::Backtrace::Location] :location Location of the
// 249:   #    caller
// 250:   #
// 251:   # @example
// 252:   #   T::Configuration.call_validation_error_handler = lambda do |signature, opts|
// 253:   #     puts opts[:message]
// 254:   #   end
// 255:   def self.call_validation_error_handler=(value)
// 256:     validate_lambda_given!(value)
// 257:     @call_validation_error_handler = value
// 258:   end
// 259:
// 260:   private_class_method def self.call_validation_error_handler_default(signature, opts)
// 261:     raise TypeError.new(opts[:pretty_message])
// 262:   end
// 263:
// 264:   def self.call_validation_error_handler(signature, opts={})
// 265:     if @call_validation_error_handler
// 266:       @call_validation_error_handler.call(signature, opts)
// 267:     else
// 268:       call_validation_error_handler_default(signature, opts)
// 269:     end
// 270:     nil
// 271:   end
// 272:
// 273:   @log_info_handler = nil
// 274:   # Set a handler for logging
// 275:   #
// 276:   # @param [Lambda, Proc, Object, nil] value Proc that handles the error
// 277:   #   report (pass nil to reset to default behavior)
// 278:   #
// 279:   # Parameters passed to value.call:
// 280:   #
// 281:   #  @param [String] str Message to be logged
// 282:   #  @param [Hash] extra A hash containing additional parameters to be passed along to the logger.
// 283:   #
// 284:   # @example
// 285:   #   T::Configuration.log_info_handler = lambda do |str, extra|
// 286:   #     puts "#{str}, context: #{extra}"
// 287:   #   end
// 288:   def self.log_info_handler=(value)
// 289:     validate_lambda_given!(value)
// 290:     @log_info_handler = value
// 291:   end
// 292:
// 293:   private_class_method def self.log_info_handler_default(str, extra)
// 294:     puts "#{str}, extra: #{extra}"
// 295:   end
// 296:
// 297:   def self.log_info_handler(str, extra)
// 298:     if @log_info_handler
// 299:       @log_info_handler.call(str, extra)
// 300:     else
// 301:       log_info_handler_default(str, extra)
// 302:     end
// 303:   end
// 304:
// 305:   @soft_assert_handler = nil
// 306:   # Set a handler for soft assertions
// 307:   #
// 308:   # These generally shouldn't stop execution of the program, but rather inform
// 309:   # some party of the assertion to action on later.
// 310:   #
// 311:   # @param [Lambda, Proc, Object, nil] value Proc that handles the error
// 312:   #   report (pass nil to reset to default behavior)
// 313:   #
// 314:   # Parameters passed to value.call:
// 315:   #
// 316:   #  @param [String] str Assertion message
// 317:   #  @param [Hash] extra A hash containing additional parameters to be passed along to the handler.
// 318:   #
// 319:   # @example
// 320:   #   T::Configuration.soft_assert_handler = lambda do |str, extra|
// 321:   #     puts "#{str}, context: #{extra}"
// 322:   #   end
// 323:   def self.soft_assert_handler=(value)
// 324:     validate_lambda_given!(value)
// 325:     @soft_assert_handler = value
// 326:   end
// 327:
// 328:   private_class_method def self.soft_assert_handler_default(str, extra)
// 329:     puts "#{str}, extra: #{extra}"
// 330:   end
// 331:
// 332:   def self.soft_assert_handler(str, extra)
// 333:     if @soft_assert_handler
// 334:       @soft_assert_handler.call(str, extra)
// 335:     else
// 336:       soft_assert_handler_default(str, extra)
// 337:     end
// 338:   end
// 339:
// 340:   @scalar_types = nil
// 341:   # Set a list of class strings that are to be considered scalar.
// 342:   #   (pass nil to reset to default behavior)
// 343:   #
// 344:   # @param [String] values Class name.
// 345:   #
// 346:   # @example
// 347:   #   T::Configuration.scalar_types = ["NilClass", "TrueClass", "FalseClass", ...]
// 348:   def self.scalar_types=(values)
// 349:     if values.nil?
// 350:       @scalar_types = values
// 351:     else
// 352:       bad_values = values.reject { |v| v.class == String }
// 353:       unless bad_values.empty?
// 354:         raise ArgumentError.new("Provided values must all be class name strings.")
// 355:       end
// 356:
// 357:       @scalar_types = values.each_with_object({}) { |x, acc| acc[x] = true }.freeze
// 358:     end
// 359:   end
// 360:
// 361:   @default_scalar_types = {
// 362:     "NilClass" => true,
// 363:     "TrueClass" => true,
// 364:     "FalseClass" => true,
// 365:     "Integer" => true,
// 366:     "Float" => true,
// 367:     "String" => true,
// 368:     "Symbol" => true,
// 369:     "Time" => true,
// 370:     "T::Enum" => true,
// 371:   }.freeze
// 372:
// 373:   def self.scalar_types
// 374:     @scalar_types || @default_scalar_types
// 375:   end
// 376:
// 377:   # Guard against overrides of `name` or `to_s`
// 378:   MODULE_NAME = Module.instance_method(:name)
// 379:   private_constant :MODULE_NAME
// 380:
// 381:   @default_module_name_mangler = ->(type) { MODULE_NAME.bind_call(type) }
// 382:
// 383:   @module_name_mangler = nil
// 384:
// 385:   def self.module_name_mangler
// 386:     @module_name_mangler || @default_module_name_mangler
// 387:   end
// 388:
// 389:   # Set to override the default behavior for converting types
// 390:   #   to names in generated code. Used by the runtime implementation
// 391:   #   associated with `--sorbet-packages` mode.
// 392:   #
// 393:   # @param [Lambda, Proc, nil] handler Proc that converts a type (Class/Module)
// 394:   #   to a String (pass nil to reset to default behavior)
// 395:   def self.module_name_mangler=(handler)
// 396:     @module_name_mangler = handler
// 397:   end
// 398:
// 399:   @sensitivity_and_pii_handler = nil
// 400:   # Set to a PII handler function. This will be called with the `sensitivity:`
// 401:   # annotations on things that use `T::Props` and can modify them ahead-of-time.
// 402:   #
// 403:   # @param [Lambda, Proc, nil] handler Proc that takes a hash mapping symbols to the
// 404:   # prop values. Pass nil to avoid changing `sensitivity:` annotations.
// 405:   def self.normalize_sensitivity_and_pii_handler=(handler)
// 406:     @sensitivity_and_pii_handler = handler
// 407:   end
// 408:
// 409:   def self.normalize_sensitivity_and_pii_handler
// 410:     @sensitivity_and_pii_handler
// 411:   end
// 412:
// 413:   @redaction_handler = nil
// 414:   # Set to a redaction handling function. This will be called when the
// 415:   # `_redacted` version of a prop reader is used. By default this is set to
// 416:   # `nil` and will raise an exception when the redacted version of a prop is
// 417:   # accessed.
// 418:   #
// 419:   # @param [Lambda, Proc, nil] handler Proc that converts a value into its
// 420:   # redacted version according to the spec passed as the second argument.
// 421:   def self.redaction_handler=(handler)
// 422:     @redaction_handler = handler
// 423:   end
// 424:
// 425:   def self.redaction_handler
// 426:     @redaction_handler
// 427:   end
// 428:
// 429:   # Temporarily disable ruby warnings while executing the given block. This is
// 430:   # useful when doing something that would normally cause a warning to be
// 431:   # emitted in Ruby verbose mode ($VERBOSE = true).
// 432:   #
// 433:   # @yield
// 434:   #
// 435:   def self.without_ruby_warnings
// 436:     if $VERBOSE
// 437:       begin
// 438:         original_verbose = $VERBOSE
// 439:         $VERBOSE = false
// 440:         yield
// 441:       ensure
// 442:         $VERBOSE = original_verbose
// 443:       end
// 444:     else
// 445:       yield
// 446:     end
// 447:   end
// 448:
// 449:   @legacy_t_enum_migration_mode = false
// 450:   def self.enable_legacy_t_enum_migration_mode
// 451:     T::Enum.include(T::Enum::LegacyMigrationMode)
// 452:     @legacy_t_enum_migration_mode = true
// 453:   end
// 454:   def self.disable_legacy_t_enum_migration_mode
// 455:     @legacy_t_enum_migration_mode = false
// 456:   end
// 457:   def self.legacy_t_enum_migration_mode?
// 458:     @legacy_t_enum_migration_mode || false
// 459:   end
// 460:
// 461:   @sealed_violation_whitelist = nil
// 462:   # @param [Array] sealed_violation_whitelist An array of Regexp to validate
// 463:   #   whether inheriting /including a sealed module outside the defining module
// 464:   #   should be allowed. Useful to whitelist benign violations, like shim files
// 465:   #   generated for an autoloader.
// 466:   def self.sealed_violation_whitelist=(sealed_violation_whitelist)
// 467:     if !@sealed_violation_whitelist.nil?
// 468:       raise ArgumentError.new("Cannot overwrite sealed_violation_whitelist after setting it")
// 469:     end
// 470:
// 471:     case sealed_violation_whitelist
// 472:     when Array
// 473:       sealed_violation_whitelist.each do |x|
// 474:         case x
// 475:         when Regexp then nil
// 476:         else raise TypeError.new("sealed_violation_whitelist accepts an Array of Regexp")
// 477:         end
// 478:       end
// 479:     else
// 480:       raise TypeError.new("sealed_violation_whitelist= accepts an Array of Regexp")
// 481:     end
// 482:
// 483:     @sealed_violation_whitelist = sealed_violation_whitelist
// 484:   end
// 485:   def self.sealed_violation_whitelist
// 486:     @sealed_violation_whitelist
// 487:   end
// 488:
// 489:   private_class_method def self.validate_lambda_given!(value)
// 490:     if !value.nil? && !value.respond_to?(:call)
// 491:       raise ArgumentError.new("Provided value must respond to :call")
// 492:     end
// 493:   end
// 494: end
