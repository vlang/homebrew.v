module dsl

import ruby
import homebrew.requirements

// Translated from Homebrew/brew `cask/dsl/depends_on.rb`.
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
