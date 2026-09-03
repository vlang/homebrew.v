module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/checker.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.check(global: false, file: nil, exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 37.
pub fn ruby_checker_l37_d1_self_check(args ...brew_runtime.Value) brew_runtime.Value {
	state := checker_state_from_boundary(args)
	options := checker_options_from_boundary(args, 1)
	result := check_bundle_state(state, options) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return checker_result_value(result)
}

// Ruby method `self.apps_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 64.
pub fn ruby_checker_l64_d2_self_apps_to_install(args ...brew_runtime.Value) brew_runtime.Value {
	state := checker_state_from_boundary(args)
	options := checker_options_from_boundary(args, 1)
	return checker_errors_value(checker_extension_errors(state, 'apps_to_install', options) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	})
}

// Ruby method `self.formulae_to_start(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 75.
pub fn ruby_checker_l75_d3_self_formulae_to_start(args ...brew_runtime.Value) brew_runtime.Value {
	state := checker_state_from_boundary(args)
	if !state.dsl_set {
		return brew_runtime.object_value('ArgumentError', 'dsl is unset!')
	}
	return checker_errors_value(state.formulae_to_start.clone())
}

// Ruby method `self.taps_to_tap(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 91.
pub fn ruby_checker_l91_d4_self_taps_to_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return checker_package_boundary(args, 'tap')
}

// Ruby method `self.casks_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 102.
pub fn ruby_checker_l102_d5_self_casks_to_install(args ...brew_runtime.Value) brew_runtime.Value {
	return checker_package_boundary(args, 'cask')
}

// Ruby method `self.formulae_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 113.
pub fn ruby_checker_l113_d6_self_formulae_to_install(args ...brew_runtime.Value) brew_runtime.Value {
	return checker_package_boundary(args, 'brew')
}

// Ruby method `self.registered_extensions_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 124.
pub fn ruby_checker_l124_d7_self_registered_extensions_to_install(args ...brew_runtime.Value) brew_runtime.Value {
	state := checker_state_from_boundary(args)
	options := checker_options_from_boundary(args, 1)
	return checker_errors_value(checker_extension_errors(state, 'registered_extensions_to_install', options) or { return brew_runtime.object_value('ArgumentError', err.msg()) })
}

// Ruby method `self.extension_errors(step, exit_on_first_error:, no_upgrade:, verbose:)` at line 136.
pub fn ruby_checker_l136_d8_self_extension_errors(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'check step is required')
	}
	step := args[0].as_string()
	state := if args.len > 1 { checker_state_from_value(args[1]) } else { CheckerState{} }
	options := checker_options_from_boundary(args, 2)
	return checker_errors_value(checker_extension_errors(state, step, options) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	})
}

// Ruby method `self.reset!` at line 158.
pub fn ruby_checker_l158_d9_self_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := checker_state_from_boundary(args)
	reset_checker_state(mut state)
	return checker_state_value(state)
}

// Ruby method `self.package_type_errors(type, exit_on_first_error:, no_upgrade:, verbose:)` at line 172.
pub fn ruby_checker_l172_d10_self_package_type_errors(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'package type is required')
	}
	package_type := args[0].as_string()
	state := if args.len > 1 { checker_state_from_value(args[1]) } else { CheckerState{} }
	return checker_errors_value(checker_package_type_errors(state, package_type) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	})
}

pub struct CheckerOptions {
pub:
	exit_on_first_error bool
	no_upgrade          bool
	verbose             bool
}

pub struct CheckerExtension {
pub:
	legacy_check_step string
	errors            []string
}

pub struct CheckerState {
pub mut:
	dsl_set               bool
	package_errors        map[string][]string
	extensions            []CheckerExtension
	formulae_to_start     []string
	package_reset_count   int
	extension_reset_count int
}

pub struct CheckerResult {
pub:
	work_to_be_done bool
	errors          []string
	checked_steps   []string
}

pub fn checker_package_type_errors(state CheckerState, package_type string) ![]string {
	if !state.dsl_set {
		return error('dsl is unset!')
	}
	return (state.package_errors[package_type] or { [] }).clone()
}

pub fn checker_extension_errors(state CheckerState, step string,
	options CheckerOptions) ![]string {
	if !state.dsl_set {
		return error('dsl is unset!')
	}
	mut errors := []string{}
	for extension in state.extensions {
		if extension.legacy_check_step != step || extension.errors.len == 0 {
			continue
		}
		if options.exit_on_first_error {
			return extension.errors.clone()
		}
		errors << extension.errors
	}
	return errors
}

pub fn check_bundle_state(state CheckerState, options CheckerOptions) !CheckerResult {
	if !state.dsl_set {
		return error('dsl is unset!')
	}
	mut errors := []string{}
	mut checked_steps := []string{}
	for step in ['taps_to_tap', 'casks_to_install', 'registered_extensions_to_install',
		'apps_to_install', 'formulae_to_install', 'formulae_to_start'] {
		checked_steps << step
		check_errors := checker_step_errors(state, step, options)!
		if check_errors.len == 0 {
			continue
		}
		errors << check_errors
		if options.exit_on_first_error {
			break
		}
	}
	return CheckerResult{
		work_to_be_done: errors.len > 0
		errors: errors
		checked_steps: checked_steps
	}
}

fn checker_step_errors(state CheckerState, step string, options CheckerOptions) ![]string {
	return match step {
		'taps_to_tap' { checker_package_type_errors(state, 'tap')! }
		'casks_to_install' { checker_package_type_errors(state, 'cask')! }
		'registered_extensions_to_install' {
			checker_extension_errors(state, 'registered_extensions_to_install', options)!
		}
		'apps_to_install' { checker_extension_errors(state, 'apps_to_install', options)! }
		'formulae_to_install' { checker_package_type_errors(state, 'brew')! }
		'formulae_to_start' { state.formulae_to_start.clone() }
		else { []string{} }
	}
}

pub fn reset_checker_state(mut state CheckerState) {
	state.dsl_set = false
	state.package_errors = map[string][]string{}
	state.extensions = []
	state.formulae_to_start = []
	state.package_reset_count++
	state.extension_reset_count++
}

pub fn checker_state_value(state CheckerState) brew_runtime.Value {
	mut values := {
		'_dsl_set':               brew_runtime.bool_value(state.dsl_set)
		'_formulae_to_start':     brew_runtime.string_array_value(state.formulae_to_start)
		'_package_reset_count':   brew_runtime.int_value(state.package_reset_count)
		'_extension_reset_count': brew_runtime.int_value(state.extension_reset_count)
	}
	for package_type, errors in state.package_errors {
		values['package:${package_type}'] = brew_runtime.string_array_value(errors)
	}
	for index, extension in state.extensions {
		values['extension:${index}:${extension.legacy_check_step}'] = brew_runtime.string_array_value(extension.errors)
	}
	return brew_runtime.map_value(values)
}

pub fn checker_state_from_value(value brew_runtime.Value) CheckerState {
	values := value.as_map() or { return CheckerState{} }
	mut state := CheckerState{
		dsl_set: if '_dsl_set' in values { values['_dsl_set'].as_bool() or { false } } else { true }
		formulae_to_start: if '_formulae_to_start' in values {
			values['_formulae_to_start'].as_string_array() or { [] }} else {
			[]}
		package_reset_count: if '_package_reset_count' in values {
			int(values['_package_reset_count'].as_int() or { 0 })} else {
			0}
		extension_reset_count: if '_extension_reset_count' in values {
			int(values['_extension_reset_count'].as_int() or { 0 })} else {
			0}
	}
	for key, errors_value in values {
		if key.starts_with('package:') {
			state.package_errors[key.all_after('package:')] = errors_value.as_string_array() or { [] }
		} else if key.starts_with('extension:') {
			state.extensions << CheckerExtension{
				legacy_check_step: key.all_after_last(':')
				errors: errors_value.as_string_array() or { [] }
			}
		}
	}
	return state
}

fn checker_state_from_boundary(args []brew_runtime.Value) CheckerState {
	return if args.len > 0 { checker_state_from_value(args[0]) } else { CheckerState{} }
}

fn checker_options_from_boundary(args []brew_runtime.Value, offset int) CheckerOptions {
	return CheckerOptions{
		exit_on_first_error: if args.len > offset {
			args[offset].as_bool() or { false }} else {
			false}
		no_upgrade: if args.len > offset + 1 {
			args[offset + 1].as_bool() or { false }} else {
			false}
		verbose: if args.len > offset + 2 { args[offset + 2].as_bool() or { false } } else { false }
	}
}

fn checker_package_boundary(args []brew_runtime.Value, package_type string) brew_runtime.Value {
	state := checker_state_from_boundary(args)
	return checker_errors_value(checker_package_type_errors(state, package_type) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	})
}

fn checker_errors_value(errors []string) brew_runtime.Value {
	return brew_runtime.string_array_value(errors)
}

fn checker_result_value(result CheckerResult) brew_runtime.Value {
	return brew_runtime.structured_value('Bundle::Checker::CheckResult', result.work_to_be_done.str(), {
		'work_to_be_done': result.work_to_be_done.str()
		'errors':          result.errors.join('\n')
		'checked_steps':   result.checked_steps.join('\n')
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/dsl"
// 5: require "bundle/extensions"
// 6: require "bundle/package_types"
// 7: require "bundle/brew_services"
// 8:
// 9: module Homebrew
// 10:   module Bundle
// 11:     module Checker
// 12:       class CheckResult < T::Struct
// 13:         const :work_to_be_done, T::Boolean
// 14:         const :errors, T::Array[String]
// 15:       end
// 16:
// 17:       CheckStep = T.type_alias { Symbol }
// 18:
// 19:       CORE_CHECKS = [
// 20:         :taps_to_tap,
// 21:         :casks_to_install,
// 22:         :registered_extensions_to_install,
// 23:         :apps_to_install,
// 24:         :formulae_to_install,
// 25:         :formulae_to_start,
// 26:       ].freeze
// 27:
// 28:       sig {
// 29:         params(
// 30:           global:              T::Boolean,
// 31:           file:                T.nilable(String),
// 32:           exit_on_first_error: T::Boolean,
// 33:           no_upgrade:          T::Boolean,
// 34:           verbose:             T::Boolean,
// 35:         ).returns(CheckResult)
// 36:       }
// 37:       def self.check(global: false, file: nil, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 38:         require "bundle/brewfile"
// 39:         @dsl = T.let(@dsl, T.nilable(Homebrew::Bundle::Dsl))
// 40:         @dsl ||= Brewfile.read(global:, file:)
// 41:
// 42:         errors = T.let([], T::Array[String])
// 43:         enumerator = exit_on_first_error ? :find : :map
// 44:
// 45:         work_to_be_done = CORE_CHECKS.public_send(enumerator) do |check_step|
// 46:           check_errors = public_send(check_step, exit_on_first_error:, no_upgrade:, verbose:)
// 47:           any_errors = check_errors.any?
// 48:           errors.concat(check_errors) if any_errors
// 49:           any_errors
// 50:         end
// 51:
// 52:         work_to_be_done = Array(work_to_be_done).flatten.any?
// 53:
// 54:         CheckResult.new(work_to_be_done:, errors:)
// 55:       end
// 56:
// 57:       sig {
// 58:         params(
// 59:           exit_on_first_error: T::Boolean,
// 60:           no_upgrade:          T::Boolean,
// 61:           verbose:             T::Boolean,
// 62:         ).returns(T::Array[String])
// 63:       }
// 64:       def self.apps_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 65:         extension_errors(:apps_to_install, exit_on_first_error:, no_upgrade:, verbose:)
// 66:       end
// 67:
// 68:       sig {
// 69:         params(
// 70:           exit_on_first_error: T::Boolean,
// 71:           no_upgrade:          T::Boolean,
// 72:           verbose:             T::Boolean,
// 73:         ).returns(T::Array[String])
// 74:       }
// 75:       def self.formulae_to_start(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 76:         raise ArgumentError, "dsl is unset!" unless @dsl
// 77:
// 78:         Homebrew::Bundle::Brew::Services.new.find_actionable(
// 79:           @dsl.entries,
// 80:           exit_on_first_error:, no_upgrade:, verbose:,
// 81:         )
// 82:       end
// 83:
// 84:       sig {
// 85:         params(
// 86:           exit_on_first_error: T::Boolean,
// 87:           no_upgrade:          T::Boolean,
// 88:           verbose:             T::Boolean,
// 89:         ).returns(T::Array[String])
// 90:       }
// 91:       def self.taps_to_tap(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 92:         package_type_errors(:tap, exit_on_first_error:, no_upgrade:, verbose:)
// 93:       end
// 94:
// 95:       sig {
// 96:         params(
// 97:           exit_on_first_error: T::Boolean,
// 98:           no_upgrade:          T::Boolean,
// 99:           verbose:             T::Boolean,
// 100:         ).returns(T::Array[String])
// 101:       }
// 102:       def self.casks_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 103:         package_type_errors(:cask, exit_on_first_error:, no_upgrade:, verbose:)
// 104:       end
// 105:
// 106:       sig {
// 107:         params(
// 108:           exit_on_first_error: T::Boolean,
// 109:           no_upgrade:          T::Boolean,
// 110:           verbose:             T::Boolean,
// 111:         ).returns(T::Array[String])
// 112:       }
// 113:       def self.formulae_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 114:         package_type_errors(:brew, exit_on_first_error:, no_upgrade:, verbose:)
// 115:       end
// 116:
// 117:       sig {
// 118:         params(
// 119:           exit_on_first_error: T::Boolean,
// 120:           no_upgrade:          T::Boolean,
// 121:           verbose:             T::Boolean,
// 122:         ).returns(T::Array[String])
// 123:       }
// 124:       def self.registered_extensions_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 125:         extension_errors(:registered_extensions_to_install, exit_on_first_error:, no_upgrade:, verbose:)
// 126:       end
// 127:
// 128:       sig {
// 129:         params(
// 130:           step:                Symbol,
// 131:           exit_on_first_error: T::Boolean,
// 132:           no_upgrade:          T::Boolean,
// 133:           verbose:             T::Boolean,
// 134:         ).returns(T::Array[String])
// 135:       }
// 136:       def self.extension_errors(step, exit_on_first_error:, no_upgrade:, verbose:)
// 137:         raise ArgumentError, "dsl is unset!" unless @dsl
// 138:
// 139:         matching_extensions = Homebrew::Bundle.extensions.select { |extension| extension.legacy_check_step == step }
// 140:         errors = T.let([], T::Array[String])
// 141:
// 142:         matching_extensions.each do |extension|
// 143:           check_errors = extension.check(
// 144:             @dsl.entries,
// 145:             exit_on_first_error:, no_upgrade:, verbose:,
// 146:           )
// 147:           next if check_errors.empty?
// 148:
// 149:           return check_errors if exit_on_first_error
// 150:
// 151:           errors.concat(check_errors)
// 152:         end
// 153:
// 154:         errors
// 155:       end
// 156:
// 157:       sig { void }
// 158:       def self.reset!
// 159:         @dsl = T.let(nil, T.nilable(Homebrew::Bundle::Dsl))
// 160:         Homebrew::Bundle.package_types.each(&:reset!)
// 161:         Homebrew::Bundle.extensions.each(&:reset!)
// 162:       end
// 163:
// 164:       sig {
// 165:         params(
// 166:           type:                Symbol,
// 167:           exit_on_first_error: T::Boolean,
// 168:           no_upgrade:          T::Boolean,
// 169:           verbose:             T::Boolean,
// 170:         ).returns(T::Array[String])
// 171:       }
// 172:       def self.package_type_errors(type, exit_on_first_error:, no_upgrade:, verbose:)
// 173:         raise ArgumentError, "dsl is unset!" unless @dsl
// 174:
// 175:         package_type = Homebrew::Bundle.package_type(type)
// 176:         return [] if package_type.nil?
// 177:
// 178:         package_type.check(@dsl.entries, exit_on_first_error:, no_upgrade:, verbose:)
// 179:       end
// 180:     end
// 181:   end
// 182: end
