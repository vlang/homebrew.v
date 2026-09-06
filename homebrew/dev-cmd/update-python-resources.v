module dev_cmd

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
