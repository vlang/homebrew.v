module bundle

import ruby

// Translated from Homebrew/brew `bundle/checker.rb`.

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

pub fn checker_state_value(state CheckerState) ruby.Value {
	mut values := {
		'_dsl_set':               ruby.bool_value(state.dsl_set)
		'_formulae_to_start':     ruby.string_array_value(state.formulae_to_start)
		'_package_reset_count':   ruby.int_value(state.package_reset_count)
		'_extension_reset_count': ruby.int_value(state.extension_reset_count)
	}
	for package_type, errors in state.package_errors {
		values['package:${package_type}'] = ruby.string_array_value(errors)
	}
	for index, extension in state.extensions {
		values['extension:${index}:${extension.legacy_check_step}'] = ruby.string_array_value(extension.errors)
	}
	return ruby.map_value(values)
}

pub fn checker_state_from_value(value ruby.Value) CheckerState {
	values := value.as_map() or { return CheckerState{} }
	mut state := CheckerState{
		dsl_set: if '_dsl_set' in values { values['_dsl_set'].as_bool() or { false } } else { true }
		formulae_to_start: if '_formulae_to_start' in values {
			values['_formulae_to_start'].as_string_array() or { [] }
		} else {
			[]
		}
		package_reset_count: if '_package_reset_count' in values {
			int(values['_package_reset_count'].as_int() or { 0 })
		} else {
			0
		}
		extension_reset_count: if '_extension_reset_count' in values {
			int(values['_extension_reset_count'].as_int() or { 0 })
		} else {
			0
		}
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

fn checker_state_from_boundary(args []ruby.Value) CheckerState {
	return if args.len > 0 { checker_state_from_value(args[0]) } else { CheckerState{} }
}

fn checker_options_from_boundary(args []ruby.Value, offset int) CheckerOptions {
	return CheckerOptions{
		exit_on_first_error: if args.len > offset {
			args[offset].as_bool() or { false }
		} else {
			false
		}
		no_upgrade: if args.len > offset + 1 {
			args[offset + 1].as_bool() or { false }
		} else {
			false
		}
		verbose: if args.len > offset + 2 { args[offset + 2].as_bool() or { false } } else { false }
	}
}

fn checker_package_boundary(args []ruby.Value, package_type string) ruby.Value {
	state := checker_state_from_boundary(args)
	return checker_errors_value(checker_package_type_errors(state, package_type) or {
		return ruby.object_value('ArgumentError', err.msg())
	})
}

fn checker_errors_value(errors []string) ruby.Value {
	return ruby.string_array_value(errors)
}

fn checker_result_value(result CheckerResult) ruby.Value {
	return ruby.structured_value('Bundle::Checker::CheckResult', result.work_to_be_done.str(), {
		'work_to_be_done': result.work_to_be_done.str()
		'errors':          result.errors.join('\n')
		'checked_steps':   result.checked_steps.join('\n')
	})
}
