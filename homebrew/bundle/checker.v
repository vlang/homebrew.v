module bundle

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
