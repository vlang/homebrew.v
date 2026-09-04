module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/update-python-resources.rb`.

pub struct UpdatePythonResourcesFormula {
pub:
	name         string
	tap_official bool
}

pub struct UpdatePythonResourcesOptions {
pub:
	formulae                     []UpdatePythonResourcesFormula
	version                      string
	version_provided             bool
	package_name                 string
	package_name_provided        bool
	extra_packages               []string
	extra_packages_provided      bool
	exclude_packages             []string
	exclude_packages_provided    bool
	install_dependencies         bool
	print_only                   bool
	quiet                        bool
	silent                       bool
	verbose                      bool
	ignore_errors                bool
	ignore_non_pypi_packages     bool
	ignore_main_package_cooldown bool
}

pub struct UpdatePythonResourcesRequest {
pub:
	formula                      UpdatePythonResourcesFormula
	version                      string
	version_provided             bool
	package_name                 string
	package_name_provided        bool
	extra_packages               []string
	extra_packages_provided      bool
	exclude_packages             []string
	exclude_packages_provided    bool
	install_dependencies         bool
	print_only                   bool
	quiet                        bool
	verbose                      bool
	ignore_errors                bool
	ignore_non_pypi_packages     bool
	ignore_main_package_cooldown bool
}

pub struct UpdatePythonResourcesOutcome {
pub:
	updated bool
	printed bool
	stdout  string
	stderr  string
	failed  bool
}

pub type UpdatePythonResourcesUpdater = fn (UpdatePythonResourcesRequest) !UpdatePythonResourcesOutcome

pub struct UpdatePythonResourcesResult {
pub:
	bundler_groups   []string
	requests         []UpdatePythonResourcesRequest
	outcomes         []UpdatePythonResourcesOutcome
	updated_formulae []string
	printed_formulae []string
	stdout           string
	stderr           string
	failed           bool
}

pub fn run_update_python_resources(options UpdatePythonResourcesOptions,
	updater UpdatePythonResourcesUpdater) !UpdatePythonResourcesResult {
	if options.formulae.len == 0 {
		return error('at least 1 named argument is required')
	}

	mut requests := []UpdatePythonResourcesRequest{cap: options.formulae.len}
	mut outcomes := []UpdatePythonResourcesOutcome{cap: options.formulae.len}
	mut updated_formulae := []string{}
	mut printed_formulae := []string{}
	mut stdout := ''
	mut stderr := ''
	mut failed := false
	for formula in options.formulae {
		// These options may only be used on third-party taps.
		request := UpdatePythonResourcesRequest{
			formula: formula
			version: options.version
			version_provided: options.version_provided
			package_name: options.package_name
			package_name_provided: options.package_name_provided
			extra_packages: options.extra_packages.clone()
			extra_packages_provided: options.extra_packages_provided
			exclude_packages: options.exclude_packages.clone()
			exclude_packages_provided: options.exclude_packages_provided
			install_dependencies: options.install_dependencies
			print_only: options.print_only
			quiet: options.quiet || options.silent
			verbose: options.verbose
			ignore_errors: if formula.tap_official { false } else { options.ignore_errors }
			ignore_non_pypi_packages: options.ignore_non_pypi_packages
			ignore_main_package_cooldown: if formula.tap_official {
				false
			} else {
				options.ignore_main_package_cooldown
			}
		}
		requests << request
		outcome := updater(request)!
		outcomes << outcome
		if outcome.updated {
			updated_formulae << formula.name
		}
		if outcome.printed {
			printed_formulae << formula.name
		}
		stdout += outcome.stdout
		stderr += outcome.stderr
		failed = failed || outcome.failed
	}
	return UpdatePythonResourcesResult{
		bundler_groups: ['ast']
		requests: requests
		outcomes: outcomes
		updated_formulae: updated_formulae
		printed_formulae: printed_formulae
		stdout: stdout
		stderr: stderr
		failed: failed
	}
}

@[heap]
pub struct UpdatePythonResourcesInput {
pub:
	options UpdatePythonResourcesOptions
	updater UpdatePythonResourcesUpdater @[required]
}

pub fn update_python_resources_input_boundary(input &UpdatePythonResourcesInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::UpdatePythonResources::Input', '', {
		'update_python_resources_input_address': u64(voidptr(input)).str()
	})
}

fn update_python_resources_input_from_value(value ruby.Value) &UpdatePythonResourcesInput {
	address := value.attributes['update_python_resources_input_address'] or {
		panic('invalid UpdatePythonResources input')
	}
	return unsafe { &UpdatePythonResourcesInput(voidptr(address.u64())) }
}

fn update_python_resources_request_value(request UpdatePythonResourcesRequest) ruby.Value {
	return ruby.map_value({
		'formula':                      ruby.string_value(request.formula.name)
		'tap_official':                 ruby.bool_value(request.formula.tap_official)
		'version':                      ruby.string_value(request.version)
		'version_provided':             ruby.bool_value(request.version_provided)
		'package_name':                 ruby.string_value(request.package_name)
		'package_name_provided':        ruby.bool_value(request.package_name_provided)
		'extra_packages':               ruby.string_array_value(request.extra_packages)
		'extra_packages_provided':      ruby.bool_value(request.extra_packages_provided)
		'exclude_packages':             ruby.string_array_value(request.exclude_packages)
		'exclude_packages_provided':    ruby.bool_value(request.exclude_packages_provided)
		'install_dependencies':         ruby.bool_value(request.install_dependencies)
		'print_only':                   ruby.bool_value(request.print_only)
		'quiet':                        ruby.bool_value(request.quiet)
		'verbose':                      ruby.bool_value(request.verbose)
		'ignore_errors':                ruby.bool_value(request.ignore_errors)
		'ignore_non_pypi_packages':     ruby.bool_value(request.ignore_non_pypi_packages)
		'ignore_main_package_cooldown': ruby.bool_value(request.ignore_main_package_cooldown)
	})
}

fn update_python_resources_outcome_value(outcome UpdatePythonResourcesOutcome) ruby.Value {
	return ruby.map_value({
		'updated': ruby.bool_value(outcome.updated)
		'printed': ruby.bool_value(outcome.printed)
		'stdout':  ruby.string_value(outcome.stdout)
		'stderr':  ruby.string_value(outcome.stderr)
		'failed':  ruby.bool_value(outcome.failed)
	})
}

fn update_python_resources_result_value(result UpdatePythonResourcesResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups':   ruby.string_array_value(result.bundler_groups)
		'requests':         ruby.array_value(result.requests.map(update_python_resources_request_value(it)))
		'outcomes':         ruby.array_value(result.outcomes.map(update_python_resources_outcome_value(it)))
		'updated_formulae': ruby.string_array_value(result.updated_formulae)
		'printed_formulae': ruby.string_array_value(result.printed_formulae)
		'stdout':           ruby.string_value(result.stdout)
		'stderr':           ruby.string_value(result.stderr)
		'failed':           ruby.bool_value(result.failed)
	})
}
