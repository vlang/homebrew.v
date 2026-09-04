module dsl

import ruby
import homebrew.requirements

// Translated from Homebrew/brew `cask/dsl/depends_on.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskDependencyArch {
pub:
	kind string
	bits int = 64
}

pub struct CaskDependsOn {
pub mut:
	arch                        []CaskDependencyArch
	casks                       []string
	formulae                    []string
	macos                       ?requirements.MacOSRequirement
	maximum_macos               ?requirements.MacOSRequirement
	linux                       bool
	loaded_keys                 []string
	macos_required              bool
	macos_bare_set_top_level    bool
	macos_version_set_top_level bool
	maximum_macos_set_top_level bool
	linux_set_top_level         bool
}

fn cask_depends_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn cask_depends_strings(value ruby.Value) []string {
	if value.type_name == 'Array' {
		return value.as_array() or { []ruby.Value{} }.map(it.as_string().trim_left(':'))
	}
	return [value.as_string().trim_left(':')]
}

fn cask_arch_value(arch CaskDependencyArch) ruby.Value {
	return ruby.map_value({
		'type': ruby.Value{ type_name: 'Symbol', repr: arch.kind }
		'bits': ruby.int_value(arch.bits)
	})
}

fn cask_requirement_value(requirement requirements.MacOSRequirement) ruby.Value {
	return ruby.Value{
		type_name: 'MacOSRequirement'
		repr: requirement.inspect()
		map_data: {
			'comparator': ruby.string_value(requirement.comparator)
			'versions':   ruby.string_array_value(requirement.versions.map(it.str()))
			'tags':       ruby.string_array_value(requirement.tags)
		}
		attributes: {
			'version_specified': requirement.version_specified().str()
		}
	}
}

fn cask_requirement_from_value(value ruby.Value) !requirements.MacOSRequirement {
	comparator := (value.map_data['comparator'] or { ruby.string_value('>=') }).as_string()
	versions := (value.map_data['versions'] or { ruby.string_array_value([]) }).as_string_array()!
	if versions.len == 0 {
		return requirements.new_macos_requirement([]string{}, comparator)
	}
	return requirements.new_macos_requirement(versions, comparator)
}

pub fn cask_depends_on_value(depends CaskDependsOn) ruby.Value {
	mut values := {
		'arch':                        ruby.array_value(depends.arch.map(cask_arch_value(it)))
		'cask':                        ruby.string_array_value(depends.casks)
		'formula':                     ruby.string_array_value(depends.formulae)
		'linux':                       if depends.linux {
			ruby.object_value('LinuxRequirement', 'Linux')
		} else {
			cask_depends_nil()
		}
		'loaded_keys':                 ruby.string_array_value(depends.loaded_keys)
		'macos_required':              ruby.bool_value(depends.macos_required)
		'macos_bare_set_top_level':    ruby.bool_value(depends.macos_bare_set_top_level)
		'macos_version_set_top_level': ruby.bool_value(depends.macos_version_set_top_level)
		'maximum_macos_set_top_level': ruby.bool_value(depends.maximum_macos_set_top_level)
		'linux_set_top_level':         ruby.bool_value(depends.linux_set_top_level)
	}
	if requirement := depends.macos {
		values['macos'] = cask_requirement_value(requirement)
	} else {
		values['macos'] = cask_depends_nil()
	}
	if requirement := depends.maximum_macos {
		values['maximum_macos'] = cask_requirement_value(requirement)
	} else {
		values['maximum_macos'] = cask_depends_nil()
	}
	return ruby.Value{
		type_name: 'Cask::DSL::DependsOn'
		repr: values.str()
		map_data: values
	}
}

fn cask_depends_bool(value ruby.Value, key string) bool {
	return (value.map_data[key] or { ruby.bool_value(false) }).as_bool() or { false }
}

pub fn cask_depends_on_from_value(value ruby.Value) !CaskDependsOn {
	if value.type_name != 'Cask::DSL::DependsOn' {
		return error('expected Cask::DSL::DependsOn, got ${value.type_name}')
	}
	mut result := CaskDependsOn{
		casks: (value.map_data['cask'] or { ruby.string_array_value([]) }).as_string_array()!
		formulae: (value.map_data['formula'] or { ruby.string_array_value([]) }).as_string_array()!
		loaded_keys: (value.map_data['loaded_keys'] or { ruby.string_array_value([]) }).as_string_array()!
		linux: (value.map_data['linux'] or { cask_depends_nil() }).type_name != 'NilClass'
		macos_required: cask_depends_bool(value, 'macos_required')
		macos_bare_set_top_level: cask_depends_bool(value, 'macos_bare_set_top_level')
		macos_version_set_top_level: cask_depends_bool(value, 'macos_version_set_top_level')
		maximum_macos_set_top_level: cask_depends_bool(value, 'maximum_macos_set_top_level')
		linux_set_top_level: cask_depends_bool(value, 'linux_set_top_level')
	}
	for raw in (value.map_data['arch'] or { ruby.array_value([]ruby.Value{}) }).as_array()! {
		result.arch << CaskDependencyArch{
			kind: (raw.map_data['type'] or { ruby.string_value('') }).as_string()
			bits: int((raw.map_data['bits'] or { ruby.int_value(64) }).as_int() or { 64 })
		}
	}
	if raw := value.map_data['macos'] {
		if raw.type_name != 'NilClass' {
			result.macos = cask_requirement_from_value(raw)!
		}
	}
	if raw := value.map_data['maximum_macos'] {
		if raw.type_name != 'NilClass' {
			result.maximum_macos = cask_requirement_from_value(raw)!
		}
	}
	return result
}

fn (mut depends CaskDependsOn) record_macos(requirement requirements.MacOSRequirement,
	set_in_block bool, os_scoped bool) ! {
	if !os_scoped {
		depends.macos_required = true
	}
	if set_in_block {
		return
	}
	if depends.linux_set_top_level {
		return error('`depends_on :linux` cannot be combined with `depends_on macos:`')
	}
	if !requirement.version_specified() {
		if depends.macos_bare_set_top_level {
			return error('`depends_on :macos` cannot be combined with another macOS `depends_on`')
		}
		depends.macos_bare_set_top_level = true
	} else if requirement.comparator == '<=' {
		if depends.maximum_macos_set_top_level {
			return error('`depends_on maximum_macos:` cannot be combined with another macOS `depends_on`')
		}
		depends.maximum_macos_set_top_level = true
	} else {
		if depends.macos_version_set_top_level {
			return error('`depends_on macos:` cannot be combined with another macOS `depends_on`')
		}
		depends.macos_version_set_top_level = true
	}
}

pub fn (mut depends CaskDependsOn) load(pairs map[string]ruby.Value,
	set_in_block bool, os_scoped bool) ! {
	for raw_key, value in pairs {
		key := raw_key.trim_left(':')
		if key !in ['formula', 'cask', 'macos', 'maximum_macos', 'linux', 'arch'] {
			return error("invalid depends_on key: ':${key}'")
		}
		previous_macos := depends.macos
		arguments := cask_depends_strings(value)
		match key {
			'formula' { depends.formulae << arguments }
			'cask' { depends.casks << arguments }
			'macos' {
				requirement := requirements.parse_macos_requirement(arguments, '>=') or {
					return error("invalid 'depends_on macos' value: ${err.msg()}")
				}
				depends.macos = requirement
				depends.record_macos(requirement, set_in_block, os_scoped)!
				if arguments.len == 1 && arguments[0] == 'any' {
					if previous := previous_macos {
						if previous.version_specified() {
							depends.macos = previous
						}
					}
				}
			}
			'maximum_macos' {
				if arguments.len != 1 {
					return error("invalid 'depends_on maximum_macos' value: only a single macOS version is allowed")
				}
				requirement := requirements.parse_macos_requirement(arguments, '<=') or {
					return error("invalid 'depends_on maximum_macos' value: ${err.msg()}")
				}
				if requirement.comparator != '<=' {
					return error("invalid 'depends_on maximum_macos' value: must use the '<=' comparator")
				}
				depends.maximum_macos = requirement
				depends.record_macos(requirement, set_in_block, os_scoped)!
			}
			'linux' {
				if depends.linux {
					return error("Only a single 'depends_on linux' is allowed.")
				}
				if arguments.len == 0 || arguments[0] != 'any' {
					return error("invalid 'depends_on linux' value: ${value.repr}")
				}
				depends.linux = true
				if !set_in_block {
					if depends.macos_required {
						return error('`depends_on :linux` cannot be combined with `depends_on macos:`')
					}
					depends.linux_set_top_level = true
				}
			}
			'arch' {
				for argument in arguments {
					normalized := argument.to_lower().trim_left(':').replace('-', '_')
					kind := match normalized {
						'intel', 'x86_64' { 'intel' }
						'arm64' { 'arm' }
						else {
							return error("invalid 'depends_on arch' values: [:${normalized}]")
						}
					}
					depends.arch << CaskDependencyArch{ kind: kind }
				}
			}
			else {}
		}
		if key !in depends.loaded_keys {
			depends.loaded_keys << key
		}
	}
}

fn cask_depends_receiver(args []ruby.Value) ?CaskDependsOn {
	if args.len == 0 {
		return none
	}
	return cask_depends_on_from_value(args[0]) or { return none }
}

fn cask_depends_error(message string) ruby.Value {
	return ruby.object_value('RuntimeError', message)
}

// Ruby attr_reader `attr_reader :arch` at line 33.
pub fn ruby_depends_on_l33_d1_arch(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return cask_depends_nil() }
	return if depends.arch.len == 0 {
		cask_depends_nil()
	} else {
		ruby.array_value(depends.arch.map(cask_arch_value(it)))
	}
}

// Ruby attr_reader `attr_reader :macos` at line 36.
pub fn ruby_depends_on_l36_d2_macos(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return cask_depends_nil() }
	if requirement := depends.macos {
		return cask_requirement_value(requirement)
	}
	return cask_depends_nil()
}

// Ruby attr_reader `attr_reader :maximum_macos` at line 39.
pub fn ruby_depends_on_l39_d3_maximum_macos(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return cask_depends_nil() }
	if requirement := depends.maximum_macos {
		return cask_requirement_value(requirement)
	}
	return cask_depends_nil()
}

// Ruby attr_reader `attr_reader :linux` at line 42.
pub fn ruby_depends_on_l42_d4_linux(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return cask_depends_nil() }
	return if depends.linux {
		ruby.object_value('LinuxRequirement', 'Linux')
	} else {
		cask_depends_nil()
	}
}

// Ruby method `initialize` at line 45.
pub fn ruby_depends_on_l45_d5_initialize(args ...ruby.Value) ruby.Value {
	return cask_depends_on_value(CaskDependsOn{})
}

// Ruby method `cask` at line 61.
pub fn ruby_depends_on_l61_d6_cask(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return ruby.string_array_value([]) }
	return ruby.string_array_value(depends.casks)
}

// Ruby method `formula` at line 66.
pub fn ruby_depends_on_l66_d7_formula(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return ruby.string_array_value([]) }
	return ruby.string_array_value(depends.formulae)
}

// Ruby method `load(pairs, set_in_block: false, os_scoped: false)` at line 77.
pub fn ruby_depends_on_l77_d8_load(args ...ruby.Value) ruby.Value {
	mut depends := cask_depends_receiver(args) or { CaskDependsOn{} }
	if args.len < 2 || args[1].type_name != 'Hash' {
		return cask_depends_error('DependsOn#load requires pairs')
	}
	keywords := if args.len > 2 && args[args.len - 1].type_name == 'Hash' {
		args[args.len - 1].map_data
	} else {
		map[string]ruby.Value{}
	}
	set_in_block := (keywords['set_in_block'] or { ruby.bool_value(false) }).as_bool() or { false }
	os_scoped := (keywords['os_scoped'] or { ruby.bool_value(false) }).as_bool() or { false }
	depends.load(args[1].map_data, set_in_block, os_scoped) or { return cask_depends_error(err.msg()) }
	return cask_depends_on_value(depends)
}

// Ruby method `formula=(*args)` at line 100.
pub fn ruby_depends_on_l100_d9_formula(args ...ruby.Value) ruby.Value {
	mut depends := cask_depends_receiver(args) or { CaskDependsOn{} }
	for value in args[1..] {
		depends.formulae << cask_depends_strings(value)
	}
	return cask_depends_on_value(depends)
}

// Ruby method `cask=(*args)` at line 105.
pub fn ruby_depends_on_l105_d10_cask(args ...ruby.Value) ruby.Value {
	mut depends := cask_depends_receiver(args) or { CaskDependsOn{} }
	for value in args[1..] {
		depends.casks << cask_depends_strings(value)
	}
	return cask_depends_on_value(depends)
}

// Ruby method `macos=(*args, set_in_block: false)` at line 110.
pub fn ruby_depends_on_l110_d11_macos(args ...ruby.Value) ruby.Value {
	mut depends := cask_depends_receiver(args) or { CaskDependsOn{} }
	values := args[1..].filter(it.type_name != 'Hash')
	requirement := requirements.parse_macos_requirement(values.map(it.as_string().trim_left(':')), '>=') or { return cask_depends_error(err.msg()) }
	depends.macos = requirement
	return cask_depends_on_value(depends)
}

// Ruby method `maximum_macos=(*args, set_in_block: false)` at line 117.
pub fn ruby_depends_on_l117_d12_maximum_macos(args ...ruby.Value) ruby.Value {
	mut depends := cask_depends_receiver(args) or { CaskDependsOn{} }
	values := args[1..].filter(it.type_name != 'Hash')
	if values.len != 1 {
		return cask_depends_error("invalid 'depends_on maximum_macos' value: only a single macOS version is allowed")
	}
	requirement := requirements.parse_macos_requirement(values.map(it.as_string().trim_left(':')), '<=') or { return cask_depends_error(err.msg()) }
	if requirement.comparator != '<=' {
		return cask_depends_error("invalid 'depends_on maximum_macos' value: must use the '<=' comparator")
	}
	depends.maximum_macos = requirement
	return cask_depends_on_value(depends)
}

// Ruby method `linux=(*args)` at line 133.
pub fn ruby_depends_on_l133_d13_linux(args ...ruby.Value) ruby.Value {
	mut depends := cask_depends_receiver(args) or { CaskDependsOn{} }
	if depends.linux {
		return cask_depends_error("Only a single 'depends_on linux' is allowed.")
	}
	if args.len < 2 || args[1].as_string().trim_left(':') != 'any' {
		return cask_depends_error("invalid 'depends_on linux' value")
	}
	depends.linux = true
	return cask_depends_on_value(depends)
}

// Ruby method `arch=(*args)` at line 141.
pub fn ruby_depends_on_l141_d14_arch(args ...ruby.Value) ruby.Value {
	mut depends := cask_depends_receiver(args) or { CaskDependsOn{} }
	depends.load({
		'arch': ruby.array_value(args[1..])
	}, false, false) or { return cask_depends_error(err.msg()) }
	return cask_depends_on_value(depends)
}

// Ruby method `empty? = T.let(__getobj__, T::Hash[Symbol, T.untyped]).empty?` at line 153.
pub fn ruby_depends_on_l153_d15_empty(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return cask_depends_error('empty? requires a DependsOn receiver') }
	return ruby.bool_value(depends.loaded_keys.len == 0)
}

// Ruby method `present? = !empty?` at line 156.
pub fn ruby_depends_on_l156_d16_present(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return cask_depends_error('present? requires a DependsOn receiver') }
	return ruby.bool_value(depends.loaded_keys.len > 0)
}

// Ruby method `requires_macos? = @macos_required` at line 159.
pub fn ruby_depends_on_l159_d17_requires_macos(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return cask_depends_error('requires_macos? requires a DependsOn receiver') }
	return ruby.bool_value(depends.macos_required)
}

// Ruby method `requires_linux? = @linux_set_top_level` at line 162.
pub fn ruby_depends_on_l162_d18_requires_linux(args ...ruby.Value) ruby.Value {
	depends := cask_depends_receiver(args) or { return cask_depends_error('requires_linux? requires a DependsOn receiver') }
	return ruby.bool_value(depends.linux_set_top_level)
}

// Ruby method `record_os_requirement(key, set_in_block:, os_scoped:)` at line 165.
pub fn ruby_depends_on_l165_d19_record_os_requirement(args ...ruby.Value) ruby.Value {
	mut depends := cask_depends_receiver(args) or { CaskDependsOn{} }
	if args.len < 2 {
		return cask_depends_error('record_os_requirement requires key')
	}
	key := args[1].as_string().trim_left(':')
	keywords := if args.len > 2 && args[args.len - 1].type_name == 'Hash' {
		args[args.len - 1].map_data
	} else {
		map[string]ruby.Value{}
	}
	set_in_block := (keywords['set_in_block'] or { ruby.bool_value(false) }).as_bool() or { false }
	os_scoped := (keywords['os_scoped'] or { ruby.bool_value(false) }).as_bool() or { false }
	if key == 'macos' {
		if requirement := depends.macos {
			depends.record_macos(requirement, set_in_block, os_scoped) or { return cask_depends_error(err.msg()) }
		}
	}
	if key == 'maximum_macos' {
		if requirement := depends.maximum_macos {
			depends.record_macos(requirement, set_in_block, os_scoped) or { return cask_depends_error(err.msg()) }
		}
	}
	if key == 'linux' && !set_in_block {
		if depends.macos_required {
			return cask_depends_error('`depends_on :linux` cannot be combined with `depends_on macos:`')
		}
		depends.linux_set_top_level = true
	}
	return cask_depends_on_value(depends)
}

// Ruby method `record_macos_requirement(requirement, set_in_block:, os_scoped:)` at line 186.
pub fn ruby_depends_on_l186_d20_record_macos_requirement(args ...ruby.Value) ruby.Value {
	mut depends := cask_depends_receiver(args) or { CaskDependsOn{} }
	if args.len < 2 {
		return cask_depends_error('record_macos_requirement requires requirement')
	}
	requirement := cask_requirement_from_value(args[1]) or { return cask_depends_error(err.msg()) }
	keywords := if args.len > 2 && args[args.len - 1].type_name == 'Hash' {
		args[args.len - 1].map_data
	} else {
		map[string]ruby.Value{}
	}
	depends.record_macos(requirement, (keywords['set_in_block'] or { ruby.bool_value(false) }).as_bool() or { false }, (keywords['os_scoped'] or { ruby.bool_value(false) }).as_bool() or { false }) or { return cask_depends_error(err.msg()) }
	return cask_depends_on_value(depends)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "delegate"
// 5:
// 6: require "requirements/macos_requirement"
// 7: require "requirements/linux_requirement"
// 8: require "utils/output"
// 9:
// 10: module Cask
// 11:   class DSL
// 12:     # Class corresponding to the `depends_on` stanza.
// 13:     class DependsOn < SimpleDelegator
// 14:       include ::Utils::Output::Mixin
// 15:
// 16:       VALID_KEYS = T.let(Set.new([
// 17:         :formula,
// 18:         :cask,
// 19:         :macos,
// 20:         :maximum_macos,
// 21:         :linux,
// 22:         :arch,
// 23:       ]).freeze, T::Set[Symbol])
// 24:
// 25:       VALID_ARCHES = T.let({
// 26:         intel:  { type: :intel, bits: 64 },
// 27:         # specific
// 28:         x86_64: { type: :intel, bits: 64 },
// 29:         arm64:  { type: :arm, bits: 64 },
// 30:       }.freeze, T::Hash[Symbol, T::Hash[Symbol, T.any(Symbol, Integer)]])
// 31:
// 32:       sig { returns(T.nilable(T::Array[T::Hash[Symbol, T.any(Symbol, Integer)]])) }
// 33:       attr_reader :arch
// 34:
// 35:       sig { returns(T.nilable(MacOSRequirement)) }
// 36:       attr_reader :macos
// 37:
// 38:       sig { returns(T.nilable(MacOSRequirement)) }
// 39:       attr_reader :maximum_macos
// 40:
// 41:       sig { returns(T.nilable(LinuxRequirement)) }
// 42:       attr_reader :linux
// 43:
// 44:       sig { void }
// 45:       def initialize
// 46:         super({})
// 47:         @arch = T.let(nil, T.nilable(T::Array[T::Hash[Symbol, T.any(Symbol, Integer)]]))
// 48:         @cask = T.let(nil, T.nilable(T::Array[String]))
// 49:         @formula = T.let(nil, T.nilable(T::Array[String]))
// 50:         @macos = T.let(nil, T.nilable(MacOSRequirement))
// 51:         @maximum_macos = T.let(nil, T.nilable(MacOSRequirement))
// 52:         @linux = T.let(nil, T.nilable(LinuxRequirement))
// 53:         @macos_required = T.let(false, T::Boolean)
// 54:         @macos_bare_set_top_level = T.let(false, T::Boolean)
// 55:         @macos_version_set_top_level = T.let(false, T::Boolean)
// 56:         @maximum_macos_set_top_level = T.let(false, T::Boolean)
// 57:         @linux_set_top_level = T.let(false, T::Boolean)
// 58:       end
// 59:
// 60:       sig { returns(T::Array[String]) }
// 61:       def cask
// 62:         @cask ||= []
// 63:       end
// 64:
// 65:       sig { returns(T::Array[String]) }
// 66:       def formula
// 67:         @formula ||= []
// 68:       end
// 69:
// 70:       sig {
// 71:         params(
// 72:           pairs:        T::Hash[Symbol, T.any(String, Symbol, T::Array[T.any(String, Symbol)])],
// 73:           set_in_block: T::Boolean,
// 74:           os_scoped:    T::Boolean,
// 75:         ).void
// 76:       }
// 77:       def load(pairs, set_in_block: false, os_scoped: false)
// 78:         pairs.each do |key, value|
// 79:           raise "invalid depends_on key: '#{key.inspect}'" unless VALID_KEYS.include?(key)
// 80:
// 81:           previous_macos = @macos if key == :macos
// 82:           case key
// 83:           when :macos, :maximum_macos
// 84:             send(:"#{key}=", *value, set_in_block:)
// 85:           else
// 86:             send(:"#{key}=", *value)
// 87:           end
// 88:           __getobj__[key] = public_send(key)
// 89:           record_os_requirement(key, set_in_block:, os_scoped:)
// 90:           next if key != :macos
// 91:           next if value != :any
// 92:           next unless previous_macos&.version_specified?
// 93:
// 94:           @macos = previous_macos
// 95:           __getobj__[key] = previous_macos
// 96:         end
// 97:       end
// 98:
// 99:       sig { params(args: String).void }
// 100:       def formula=(*args)
// 101:         formula.concat(args)
// 102:       end
// 103:
// 104:       sig { params(args: String).void }
// 105:       def cask=(*args)
// 106:         cask.concat(args)
// 107:       end
// 108:
// 109:       sig { params(args: T.any(String, Symbol), set_in_block: T::Boolean).void }
// 110:       def macos=(*args, set_in_block: false)
// 111:         @macos = MacOSRequirement.parse(args, comparator: ">=")
// 112:       rescue MacOSVersion::Error, TypeError => e
// 113:         raise "invalid 'depends_on macos' value: #{e}"
// 114:       end
// 115:
// 116:       sig { params(args: T.any(String, Symbol), set_in_block: T::Boolean).void }
// 117:       def maximum_macos=(*args, set_in_block: false)
// 118:         raise "invalid 'depends_on maximum_macos' value: only a single macOS version is allowed" if args.count != 1
// 119:
// 120:         maximum_macos = begin
// 121:           MacOSRequirement.parse(args, comparator: "<=")
// 122:         rescue MacOSVersion::Error, TypeError => e
// 123:           raise "invalid 'depends_on maximum_macos' value: #{e}"
// 124:         end
// 125:         if maximum_macos.comparator != "<="
// 126:           raise "invalid 'depends_on maximum_macos' value: must use the '<=' comparator"
// 127:         end
// 128:
// 129:         @maximum_macos = maximum_macos
// 130:       end
// 131:
// 132:       sig { params(args: T.any(String, Symbol)).void }
// 133:       def linux=(*args)
// 134:         raise "Only a single 'depends_on linux' is allowed." if @linux
// 135:         raise "invalid 'depends_on linux' value: #{args.first.inspect}" if args.first != :any
// 136:
// 137:         @linux = LinuxRequirement.new
// 138:       end
// 139:
// 140:       sig { params(args: Symbol).void }
// 141:       def arch=(*args)
// 142:         @arch ||= []
// 143:         arches = args.map do |elt|
// 144:           elt.to_s.downcase.sub(/^:/, "").tr("-", "_").to_sym
// 145:         end
// 146:         invalid_arches = arches - VALID_ARCHES.keys
// 147:         raise "invalid 'depends_on arch' values: #{invalid_arches.inspect}" unless invalid_arches.empty?
// 148:
// 149:         @arch.concat(arches.map { |arch| VALID_ARCHES.fetch(arch) })
// 150:       end
// 151:
// 152:       sig { returns(T::Boolean) }
// 153:       def empty? = T.let(__getobj__, T::Hash[Symbol, T.untyped]).empty?
// 154:
// 155:       sig { returns(T::Boolean) }
// 156:       def present? = !empty?
// 157:
// 158:       sig { returns(T::Boolean) }
// 159:       def requires_macos? = @macos_required
// 160:
// 161:       sig { returns(T::Boolean) }
// 162:       def requires_linux? = @linux_set_top_level
// 163:
// 164:       sig { params(key: Symbol, set_in_block: T::Boolean, os_scoped: T::Boolean).void }
// 165:       def record_os_requirement(key, set_in_block:, os_scoped:)
// 166:         case key
// 167:         when :macos
// 168:           macos = @macos
// 169:           raise "invalid 'depends_on macos' value" unless macos
// 170:
// 171:           record_macos_requirement(macos, set_in_block:, os_scoped:)
// 172:         when :maximum_macos
// 173:           maximum_macos = @maximum_macos
// 174:           raise "invalid 'depends_on maximum_macos' value" unless maximum_macos
// 175:
// 176:           record_macos_requirement(maximum_macos, set_in_block:, os_scoped:)
// 177:         when :linux
// 178:           return if set_in_block
// 179:           raise "`depends_on :linux` cannot be combined with `depends_on macos:`" if requires_macos?
// 180:
// 181:           @linux_set_top_level = true
// 182:         end
// 183:       end
// 184:
// 185:       sig { params(requirement: MacOSRequirement, set_in_block: T::Boolean, os_scoped: T::Boolean).void }
// 186:       def record_macos_requirement(requirement, set_in_block:, os_scoped:)
// 187:         # `on_arm`/`on_intel` blocks are evaluated on every OS, so a macOS
// 188:         # dependency inside one applies everywhere; only an OS block scopes a
// 189:         # dependency to macOS alone.
// 190:         @macos_required = true unless os_scoped
// 191:
// 192:         return if set_in_block
// 193:
// 194:         raise "`depends_on :linux` cannot be combined with `depends_on macos:`" if requires_linux?
// 195:
// 196:         if !requirement.version_specified?
// 197:           raise "`depends_on :macos` cannot be combined with another macOS `depends_on`" if @macos_bare_set_top_level
// 198:
// 199:           if @macos_version_set_top_level || @maximum_macos_set_top_level
// 200:             odeprecated "`depends_on :macos` with `depends_on macos:`"
// 201:           end
// 202:
// 203:           @macos_bare_set_top_level = true
// 204:         elsif requirement.comparator == "<="
// 205:           odeprecated "`depends_on :macos` with `depends_on maximum_macos:`" if @macos_bare_set_top_level
// 206:
// 207:           if @maximum_macos_set_top_level
// 208:             raise "`depends_on maximum_macos:` cannot be combined with another macOS `depends_on`"
// 209:           end
// 210:
// 211:           @maximum_macos_set_top_level = true
// 212:         else
// 213:           odeprecated "`depends_on :macos` with `depends_on macos:`" if @macos_bare_set_top_level
// 214:
// 215:           if @macos_version_set_top_level
// 216:             raise "`depends_on macos:` cannot be combined with another macOS `depends_on`"
// 217:           end
// 218:
// 219:           @macos_version_set_top_level = true
// 220:         end
// 221:       end
// 222:     end
// 223:   end
// 224: end
