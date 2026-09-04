module bundle

import ruby
import homebrew.bundle.extensions

// Translated from Homebrew/brew `bundle/package_type.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PackageTypeContext {
pub:
	definition       extensions.ExtensionDefinition
	upgrade_formulae []string
	skipper          BundleSkipper
}

pub struct PackageTypeEntriesResult {
pub:
	entries  []BundleDslEntry
	warnings []string
}

pub struct PackageTypeCheckResult {
pub:
	errors   []string
	warnings []string
}

fn package_type_nil() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn package_type_error(type_name string, message string) ruby.Value {
	return ruby.structured_value(type_name, message, {
		'message': message
	})
}

pub fn package_type_context_value(context PackageTypeContext) ruby.Value {
	mut skipped := map[string]ruby.Value{}
	for entry_type, names in context.skipper.skipped_entries {
		skipped[entry_type] = ruby.string_array_value(names)
	}
	return ruby.map_value({
		'definition':       extensions.extension_definition_value(context.definition)
		'upgrade_formulae': ruby.string_array_value(context.upgrade_formulae)
		'failed_taps':      ruby.string_array_value(context.skipper.failed_taps)
		'skipped_entries':  ruby.map_value(skipped)
	})
}

pub fn package_type_context_from_value(value ruby.Value) PackageTypeContext {
	fields := value.as_map() or { map[string]ruby.Value{} }
	mut skipped := map[string][]string{}
	for entry_type, names in (fields['skipped_entries'] or { ruby.map_value({}) }).as_map() or {
		map[string]ruby.Value{}
	} {
		skipped[entry_type] = names.as_string_array() or { [] }
	}
	return PackageTypeContext{
		definition: extensions.extension_definition_from_value(fields['definition'] or { value })
		upgrade_formulae: (fields['upgrade_formulae'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
		skipper: BundleSkipper{
			failed_taps: (fields['failed_taps'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
			skipped_entries: skipped
			initialized: true
		}
	}
}

fn package_type_entry_from_value(value ruby.Value) BundleDslEntry {
	if value.attributes.len > 0 {
		return BundleDslEntry{
			entry_type: value.attributes['type'] or { '' }
			name: value.attributes['name'] or { value.repr }
			options: value.map_data.clone()
		}
	}
	fields := value.as_map() or { map[string]ruby.Value{} }
	return BundleDslEntry{
		entry_type: (fields['type'] or { ruby.string_value('') }).as_string()
		name: (fields['name'] or { ruby.string_value(value.repr) }).as_string()
		options: (fields['options'] or { ruby.map_value({}) }).as_map() or { map[string]ruby.Value{} }
	}
}

fn package_type_entries_from_value(value ruby.Value) []BundleDslEntry {
	return value.as_array() or { [] }.map(package_type_entry_from_value(it))
}

fn package_type_entries_value(result PackageTypeEntriesResult) ruby.Value {
	return ruby.Value{
		type_name: 'Array'
		array_data: result.entries.map(bundle_dsl_entry_value(it))
		map_data: {
			'warnings': ruby.string_array_value(result.warnings)
		}
	}
}

fn package_type_check_value(result PackageTypeCheckResult) ruby.Value {
	return ruby.Value{
		type_name: 'Array'
		array_data: result.errors.map(ruby.string_value(it))
		map_data: {
			'warnings': ruby.string_array_value(result.warnings)
		}
	}
}

fn package_type_statuses_from_value(value ruby.Value) map[string]bool {
	fields := value.as_map() or { map[string]ruby.Value{} }
	mut statuses := map[string]bool{}
	for name, status in fields {
		statuses[name] = status.as_bool() or { false }
	}
	return statuses
}

fn package_type_status(statuses map[string]bool, name string, no_upgrade bool) !bool {
	if status := statuses['${name}|${no_upgrade}'] {
		return status
	}
	if status := statuses[name] {
		return status
	}
	return error('NotImplementedError')
}

pub fn package_type_register(mut registry extensions.ExtensionRegistry,
	definition extensions.ExtensionDefinition) {
	registry.package_types = registry.package_types.filter(it.class_name != definition.class_name)
	registry.package_types << definition
}

pub fn package_type_registered(registry extensions.ExtensionRegistry,
	type_name string) ?extensions.ExtensionDefinition {
	requested := type_name.trim_string_left(':')
	for definition in registry.package_types {
		if definition.type_name == requested {
			return definition
		}
	}
	return none
}

pub fn package_type_dump_order(registry extensions.ExtensionRegistry) []extensions.ExtensionDefinition {
	mut core := []extensions.ExtensionDefinition{}
	for type_name in ['tap', 'brew', 'cask'] {
		if definition := package_type_registered(registry, type_name) {
			core << definition
		}
	}
	mut ordered := core.clone()
	for definition in registry.package_types {
		if !ordered.any(it.class_name == definition.class_name) {
			ordered << definition
		}
	}
	return ordered
}

pub fn package_type_failure_reason(context PackageTypeContext, name string,
	no_upgrade bool) string {
	reason := if no_upgrade && name !in context.upgrade_formulae {
		'needs to be installed.'
	} else {
		'needs to be installed or updated.'
	}
	return '${context.definition.check_label} ${name} ${reason}'
}

pub fn package_type_checkable_entries(context PackageTypeContext,
	entries []BundleDslEntry) PackageTypeEntriesResult {
	mut selected := []BundleDslEntry{}
	mut warnings := []string{}
	for entry in entries {
		if entry.entry_type != context.definition.type_name {
			continue
		}
		full_name := if 'full_name' in entry.options {
			entry.options['full_name'].as_string()
		} else {
			''
		}
		id := if 'id' in entry.options { entry.options['id'].as_string() } else { '' }
		skip_result := context.skipper.skip(BundleSkipEntry{
			type_name: entry.entry_type
			name: entry.name
			full_name: full_name
			id: id
		}, false)
		if skip_result.skipped {
			if skip_result.warning != '' {
				warnings << skip_result.warning
			}
			continue
		}
		selected << entry
	}
	return PackageTypeEntriesResult{
		entries: selected
		warnings: warnings
	}
}

pub fn package_type_format_checkable(context PackageTypeContext,
	entries []BundleDslEntry) PackageTypeEntriesResult {
	return package_type_checkable_entries(context, entries)
}

pub fn package_type_exit_early_check(context PackageTypeContext, packages []string,
	no_upgrade bool, statuses map[string]bool) !PackageTypeCheckResult {
	for package in packages {
		if package_type_status(statuses, package, no_upgrade)! {
			continue
		}
		return PackageTypeCheckResult{
			errors: [package_type_failure_reason(context, package, no_upgrade)]
		}
	}
	return PackageTypeCheckResult{}
}

pub fn package_type_full_check(context PackageTypeContext, packages []string, no_upgrade bool,
	statuses map[string]bool) !PackageTypeCheckResult {
	mut errors := []string{}
	for package in packages {
		if !package_type_status(statuses, package, no_upgrade)! {
			errors << package_type_failure_reason(context, package, no_upgrade)
		}
	}
	return PackageTypeCheckResult{
		errors: errors
	}
}

pub fn package_type_find_actionable(context PackageTypeContext, entries []BundleDslEntry,
	exit_on_first_error bool, no_upgrade bool, statuses map[string]bool) !PackageTypeCheckResult {
	formatted := package_type_format_checkable(context, entries)
	packages := formatted.entries.map(it.name)
	mut result := if exit_on_first_error {
		package_type_exit_early_check(context, packages, no_upgrade, statuses)!
	} else {
		package_type_full_check(context, packages, no_upgrade, statuses)!
	}
	result = PackageTypeCheckResult{
		...result
		warnings: formatted.warnings.clone()
	}
	return result
}

// Ruby method `self.inherited(subclass)` at line 14.
pub fn ruby_package_type_l14_d1_self_inherited(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return package_type_error('ArgumentError', 'package type subclass is required')
	}
	definition := extensions.extension_definition_from_value(args[0])
	mut registry := if args.len > 1 {
		extensions.extension_registry_from_value(args[1])
	} else {
		extensions.ExtensionRegistry{}
	}
	if definition.class_name != 'Homebrew::Bundle::Extension' {
		package_type_register(mut registry, definition)
	}
	return extensions.extension_registry_value(registry)
}

// Ruby method `self.type; end` at line 22.
pub fn ruby_package_type_l22_d2_self_type(args ...ruby.Value) ruby.Value {
	_ = args
	return package_type_nil()
}

// Ruby method `self.check_label; end` at line 25.
pub fn ruby_package_type_l25_d3_self_check_label(args ...ruby.Value) ruby.Value {
	_ = args
	return package_type_nil()
}

// Ruby method `self.dump_supported?` at line 28.
pub fn ruby_package_type_l28_d4_self_dump_supported(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(true)
}

// Ruby method `self.install_supported?` at line 33.
pub fn ruby_package_type_l33_d5_self_install_supported(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(true)
}

// Ruby method `self.install_verb(_name = "", _options = {})` at line 38.
pub fn ruby_package_type_l38_d6_self_install_verb(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('Installing')
}

// Ruby method `self.fetchable_name(name, options = {}, no_upgrade: false)` at line 49.
pub fn ruby_package_type_l49_d7_self_fetchable_name(args ...ruby.Value) ruby.Value {
	_ = args
	return package_type_nil()
}

// Ruby method `self.reset!; end` at line 58.
pub fn ruby_package_type_l58_d8_self_reset(args ...ruby.Value) ruby.Value {
	_ = args
	return package_type_nil()
}

// Ruby method `self.preinstall!(name, no_upgrade: false, verbose: false, **options); end` at line 68.
pub fn ruby_package_type_l68_d9_self_preinstall(args ...ruby.Value) ruby.Value {
	_ = args
	return package_type_nil()
}

// Ruby method `self.install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, **options); end` at line 80.
pub fn ruby_package_type_l80_d10_self_install(args ...ruby.Value) ruby.Value {
	_ = args
	return package_type_nil()
}

// Ruby method `self.check(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 90.
pub fn ruby_package_type_l90_d11_self_check(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return package_type_error('ArgumentError', 'context, entries and status collaborator are required')
	}
	context := package_type_context_from_value(args[0])
	entries := package_type_entries_from_value(args[1])
	statuses := package_type_statuses_from_value(args[2])
	exit_on_first_error := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	no_upgrade := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	result := package_type_find_actionable(context, entries, exit_on_first_error, no_upgrade, statuses) or { return package_type_error('NotImplementedError', err.msg()) }
	return package_type_check_value(result)
}

// Ruby method `self.dump; end` at line 95.
pub fn ruby_package_type_l95_d12_self_dump(args ...ruby.Value) ruby.Value {
	_ = args
	return package_type_nil()
}

// Ruby method `self.dump_output(describe: false, no_restart: false)` at line 98.
pub fn ruby_package_type_l98_d13_self_dump_output(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return package_type_nil()
	}
	return args[0]
}

// Ruby method `exit_early_check(packages, no_upgrade:)` at line 106.
pub fn ruby_package_type_l106_d14_exit_early_check(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return package_type_error('ArgumentError', 'context, packages and status collaborator are required')
	}
	context := package_type_context_from_value(args[0])
	packages := args[1].as_string_array() or { [] }
	no_upgrade := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	result := package_type_exit_early_check(context, packages, no_upgrade, package_type_statuses_from_value(args[2])) or {
		return package_type_error('NotImplementedError', err.msg())
	}
	return package_type_check_value(result)
}

// Ruby method `failure_reason(name, no_upgrade:)` at line 116.
pub fn ruby_package_type_l116_d15_failure_reason(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return package_type_error('ArgumentError', 'context and package are required')
	}
	context := package_type_context_from_value(args[0])
	no_upgrade := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	return ruby.string_value(package_type_failure_reason(context, args[1].as_string(), no_upgrade))
}

// Ruby method `full_check(packages, no_upgrade:)` at line 126.
pub fn ruby_package_type_l126_d16_full_check(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return package_type_error('ArgumentError', 'context, packages and status collaborator are required')
	}
	context := package_type_context_from_value(args[0])
	packages := args[1].as_string_array() or { [] }
	no_upgrade := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	result := package_type_full_check(context, packages, no_upgrade, package_type_statuses_from_value(args[2])) or {
		return package_type_error('NotImplementedError', err.msg())
	}
	return package_type_check_value(result)
}

// Ruby method `checkable_entries(all_entries)` at line 132.
pub fn ruby_package_type_l132_d17_checkable_entries(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return package_type_error('ArgumentError', 'context and entries are required')
	}
	return package_type_entries_value(package_type_checkable_entries(package_type_context_from_value(args[0]), package_type_entries_from_value(args[1])))
}

// Ruby method `format_checkable(entries)` at line 143.
pub fn ruby_package_type_l143_d18_format_checkable(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return package_type_error('ArgumentError', 'context and entries are required')
	}
	result := package_type_format_checkable(package_type_context_from_value(args[0]), package_type_entries_from_value(args[1]))
	return ruby.Value{
		type_name: 'Array'
		array_data: result.entries.map(ruby.string_value(it.name))
		map_data: {
			'warnings': ruby.string_array_value(result.warnings)
		}
	}
}

// Ruby method `installed_and_up_to_date?(_pkg, no_upgrade: false)` at line 148.
pub fn ruby_package_type_l148_d19_installed_and_up_to_date(args ...ruby.Value) ruby.Value {
	_ = args
	return package_type_error('NotImplementedError', 'NotImplementedError')
}

// Ruby method `find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 160.
pub fn ruby_package_type_l160_d20_find_actionable(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return package_type_error('ArgumentError', 'context, entries and status collaborator are required')
	}
	context := package_type_context_from_value(args[0])
	entries := package_type_entries_from_value(args[1])
	statuses := package_type_statuses_from_value(args[2])
	exit_on_first_error := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	no_upgrade := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	result := package_type_find_actionable(context, entries, exit_on_first_error, no_upgrade, statuses) or { return package_type_error('NotImplementedError', err.msg()) }
	return package_type_check_value(result)
}

// Ruby method `register_package_type(package_type)` at line 173.
pub fn ruby_package_type_l173_d21_register_package_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return package_type_error('ArgumentError', 'package type is required')
	}
	mut registry := if args.len > 1 {
		extensions.extension_registry_from_value(args[1])
	} else {
		extensions.ExtensionRegistry{}
	}
	package_type_register(mut registry, extensions.extension_definition_from_value(args[0]))
	return extensions.extension_registry_value(registry)
}

// Ruby method `package_types` at line 180.
pub fn ruby_package_type_l180_d22_package_types(args ...ruby.Value) ruby.Value {
	registry := if args.len > 0 {
		extensions.extension_registry_from_value(args[0])
	} else {
		extensions.ExtensionRegistry{}
	}
	return extensions.extension_definitions_value(registry.package_types)
}

// Ruby method `package_type(type)` at line 186.
pub fn ruby_package_type_l186_d23_package_type(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return package_type_nil()
	}
	registry := extensions.extension_registry_from_value(args[0])
	if definition := package_type_registered(registry, args[1].as_string()) {
		return extensions.extension_definition_value(definition)
	}
	return package_type_nil()
}

// Ruby method `dump_package_types` at line 192.
pub fn ruby_package_type_l192_d24_dump_package_types(args ...ruby.Value) ruby.Value {
	registry := if args.len > 0 {
		extensions.extension_registry_from_value(args[0])
	} else {
		extensions.ExtensionRegistry{}
	}
	return extensions.extension_definitions_value(package_type_dump_order(registry))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/dsl"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     class PackageType
// 9:       extend T::Helpers
// 10:
// 11:       abstract!
// 12:
// 13:       sig { params(subclass: T.class_of(Homebrew::Bundle::PackageType)).void }
// 14:       def self.inherited(subclass)
// 15:         super
// 16:         return if subclass.name == "Homebrew::Bundle::Extension"
// 17:
// 18:         Homebrew::Bundle.register_package_type(subclass)
// 19:       end
// 20:
// 21:       sig { abstract.returns(Symbol) }
// 22:       def self.type; end
// 23:
// 24:       sig { abstract.returns(String) }
// 25:       def self.check_label; end
// 26:
// 27:       sig { returns(T::Boolean) }
// 28:       def self.dump_supported?
// 29:         true
// 30:       end
// 31:
// 32:       sig { returns(T::Boolean) }
// 33:       def self.install_supported?
// 34:         true
// 35:       end
// 36:
// 37:       sig { overridable.params(_name: String, _options: Homebrew::Bundle::EntryOptions).returns(String) }
// 38:       def self.install_verb(_name = "", _options = {})
// 39:         "Installing"
// 40:       end
// 41:
// 42:       sig {
// 43:         params(
// 44:           name:       String,
// 45:           options:    Homebrew::Bundle::EntryOptions,
// 46:           no_upgrade: T::Boolean,
// 47:         ).returns(T.nilable(String))
// 48:       }
// 49:       def self.fetchable_name(name, options = {}, no_upgrade: false)
// 50:         _ = name
// 51:         _ = options
// 52:         _ = no_upgrade
// 53:
// 54:         nil
// 55:       end
// 56:
// 57:       sig { abstract.void }
// 58:       def self.reset!; end
// 59:
// 60:       sig {
// 61:         abstract.params(
// 62:           name:       String,
// 63:           no_upgrade: T::Boolean,
// 64:           verbose:    T::Boolean,
// 65:           options:    Homebrew::Bundle::EntryOption,
// 66:         ).returns(T::Boolean)
// 67:       }
// 68:       def self.preinstall!(name, no_upgrade: false, verbose: false, **options); end
// 69:
// 70:       sig {
// 71:         abstract.params(
// 72:           name:       String,
// 73:           preinstall: T::Boolean,
// 74:           no_upgrade: T::Boolean,
// 75:           verbose:    T::Boolean,
// 76:           force:      T::Boolean,
// 77:           options:    Homebrew::Bundle::EntryOption,
// 78:         ).returns(T::Boolean)
// 79:       }
// 80:       def self.install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, **options); end
// 81:
// 82:       sig {
// 83:         params(
// 84:           entries:             T::Array[Dsl::Entry],
// 85:           exit_on_first_error: T::Boolean,
// 86:           no_upgrade:          T::Boolean,
// 87:           verbose:             T::Boolean,
// 88:         ).returns(T::Array[String])
// 89:       }
// 90:       def self.check(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 91:         new.find_actionable(entries, exit_on_first_error:, no_upgrade:, verbose:)
// 92:       end
// 93:
// 94:       sig { abstract.returns(String) }
// 95:       def self.dump; end
// 96:
// 97:       sig { params(describe: T::Boolean, no_restart: T::Boolean).returns(String) }
// 98:       def self.dump_output(describe: false, no_restart: false)
// 99:         _ = describe
// 100:         _ = no_restart
// 101:
// 102:         dump
// 103:       end
// 104:
// 105:       sig { params(packages: T::Array[Object], no_upgrade: T::Boolean).returns(T::Array[String]) }
// 106:       def exit_early_check(packages, no_upgrade:)
// 107:         packages.each do |pkg|
// 108:           next if installed_and_up_to_date?(pkg, no_upgrade:)
// 109:
// 110:           return [failure_reason(pkg, no_upgrade:)]
// 111:         end
// 112:         []
// 113:       end
// 114:
// 115:       sig { overridable.params(name: Object, no_upgrade: T::Boolean).returns(String) }
// 116:       def failure_reason(name, no_upgrade:)
// 117:         reason = if no_upgrade && Bundle.upgrade_formulae.exclude?(name)
// 118:           "needs to be installed."
// 119:         else
// 120:           "needs to be installed or updated."
// 121:         end
// 122:         "#{self.class.check_label} #{name} #{reason}"
// 123:       end
// 124:
// 125:       sig { params(packages: T::Array[Object], no_upgrade: T::Boolean).returns(T::Array[String]) }
// 126:       def full_check(packages, no_upgrade:)
// 127:         packages.reject { |pkg| installed_and_up_to_date?(pkg, no_upgrade:) }
// 128:                 .map { |pkg| failure_reason(pkg, no_upgrade:) }
// 129:       end
// 130:
// 131:       sig { params(all_entries: T::Array[Dsl::Entry]).returns(T::Array[Dsl::Entry]) }
// 132:       def checkable_entries(all_entries)
// 133:         require "bundle/skipper"
// 134:         all_entries.filter_map do |entry|
// 135:           next if entry.type != self.class.type
// 136:           next if Bundle::Skipper.skip?(entry)
// 137:
// 138:           entry
// 139:         end
// 140:       end
// 141:
// 142:       sig { params(entries: T::Array[Dsl::Entry]).returns(T::Array[Object]) }
// 143:       def format_checkable(entries)
// 144:         checkable_entries(entries).map(&:name)
// 145:       end
// 146:
// 147:       sig { params(_pkg: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 148:       def installed_and_up_to_date?(_pkg, no_upgrade: false)
// 149:         raise NotImplementedError
// 150:       end
// 151:
// 152:       sig {
// 153:         params(
// 154:           entries:             T::Array[Dsl::Entry],
// 155:           exit_on_first_error: T::Boolean,
// 156:           no_upgrade:          T::Boolean,
// 157:           verbose:             T::Boolean,
// 158:         ).returns(T::Array[String])
// 159:       }
// 160:       def find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 161:         requested = format_checkable(entries)
// 162:
// 163:         if exit_on_first_error
// 164:           exit_early_check(requested, no_upgrade:)
// 165:         else
// 166:           full_check(requested, no_upgrade:)
// 167:         end
// 168:       end
// 169:     end
// 170:
// 171:     class << self
// 172:       sig { params(package_type: T.class_of(PackageType)).void }
// 173:       def register_package_type(package_type)
// 174:         @package_types ||= T.let([], T.nilable(T::Array[T.class_of(PackageType)]))
// 175:         @package_types.reject! { |registered| registered.name == package_type.name }
// 176:         @package_types << package_type
// 177:       end
// 178:
// 179:       sig { returns(T::Array[T.class_of(PackageType)]) }
// 180:       def package_types
// 181:         @package_types ||= T.let([], T.nilable(T::Array[T.class_of(PackageType)]))
// 182:         @package_types
// 183:       end
// 184:
// 185:       sig { params(type: T.any(Symbol, String)).returns(T.nilable(T.class_of(PackageType))) }
// 186:       def package_type(type)
// 187:         requested_type = type.to_sym
// 188:         package_types.find { |registered| registered.type == requested_type }
// 189:       end
// 190:
// 191:       sig { returns(T::Array[T.class_of(PackageType)]) }
// 192:       def dump_package_types
// 193:         core_package_types = [:tap, :brew, :cask].filter_map { |type| package_type(type) }
// 194:         (core_package_types + (package_types - core_package_types)).uniq
// 195:       end
// 196:     end
// 197:   end
// 198: end
