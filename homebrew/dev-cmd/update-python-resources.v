module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/update-python-resources.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `run` at line 44.
pub fn ruby_update_python_resources_l44_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	input := update_python_resources_input_from_value(args[0])
	return update_python_resources_result_value(run_update_python_resources(input.options, input.updater) or {
		error_type := if input.options.formulae.len == 0 {
			'Homebrew::CLI::MinNamedArgumentsError'
		} else {
			'FatalError'
		}
		return ruby.object_value(error_type, err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class UpdatePythonResources < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Update versions for PyPI resource blocks in <formula>.
// 12:         EOS
// 13:         switch "-p", "--print-only",
// 14:                description: "Print the updated resource blocks instead of changing <formula>."
// 15:         switch "-s", "--silent",
// 16:                description: "Suppress any output.",
// 17:                odeprecated: true
// 18:         switch "--ignore-errors",
// 19:                description: "Record all discovered resources, even those that can't be resolved successfully. " \
// 20:                             "This option is ignored for homebrew/core formulae."
// 21:         switch "--ignore-non-pypi-packages",
// 22:                description: "Don't fail if <formula> is not a PyPI package."
// 23:         switch "--ignore-main-package-cooldown",
// 24:                description: "Bypass the release cooldown for <formula>'s own package when resolving " \
// 25:                             "resources. Its dependencies still respect the cooldown. This option is " \
// 26:                             "ignored for official taps."
// 27:         switch "--install-dependencies",
// 28:                description: "Install missing dependencies required to update resources."
// 29:         flag   "--version=",
// 30:                description: "Use the specified <version> when finding resources for <formula>. " \
// 31:                             "If no version is specified, the current version for <formula> will be used."
// 32:         flag   "--package-name=",
// 33:                description: "Use the specified <package-name> when finding resources for <formula>. " \
// 34:                             "If no package name is specified, it will be inferred from the formula's stable URL."
// 35:         comma_array "--extra-packages",
// 36:                     description: "Include these additional packages when finding resources."
// 37:         comma_array "--exclude-packages",
// 38:                     description: "Exclude these packages when finding resources."
// 39:
// 40:         named_args :formula, min: 1, without_api: true
// 41:       end
// 42:
// 43:       sig { override.void }
// 44:       def run
// 45:         Homebrew.install_bundler_gems!(groups: ["ast"])
// 46:         require "utils/pypi"
// 47:
// 48:         args.named.to_formulae.each do |formula|
// 49:           # These options may only be used on third-party taps.
// 50:           if formula.tap&.official?
// 51:             ignore_errors = false
// 52:             ignore_main_package_cooldown = false
// 53:           else
// 54:             ignore_errors = args.ignore_errors?
// 55:             ignore_main_package_cooldown = args.ignore_main_package_cooldown?
// 56:           end
// 57:           PyPI.update_python_resources! formula,
// 58:                                         version:                      args.version,
// 59:                                         package_name:                 args.package_name,
// 60:                                         extra_packages:               args.extra_packages,
// 61:                                         exclude_packages:             args.exclude_packages,
// 62:                                         install_dependencies:         args.install_dependencies?,
// 63:                                         print_only:                   args.print_only?,
// 64:                                         quiet:                        args.quiet? || args.silent?,
// 65:                                         verbose:                      args.verbose?,
// 66:                                         ignore_errors:                ignore_errors,
// 67:                                         ignore_non_pypi_packages:     args.ignore_non_pypi_packages?,
// 68:                                         ignore_main_package_cooldown: ignore_main_package_cooldown
// 69:         end
// 70:       end
// 71:     end
// 72:   end
// 73: end
