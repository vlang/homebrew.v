module dev_cmd

import homebrew.utils

// Translated from Homebrew/brew `dev-cmd/update-perl-resources.rb`.

pub struct UpdatePerlResourcesOptions {
pub:
	formulae      []utils.CpanFormula
	print_only    bool
	quiet         bool
	silent        bool
	verbose       bool
	ignore_errors bool
}

pub struct UpdatePerlResourcesResult {
pub:
	bundler_groups []string
	updates        []utils.CpanUpdateResult
	stdout         []string
	stderr         []string
	failed         bool
}

pub fn run_update_perl_resources(options UpdatePerlResourcesOptions, fetch utils.CpanMetadataFetch) !UpdatePerlResourcesResult {
	if options.formulae.len == 0 {
		return error('at least one formula is required')
	}
	quiet := options.quiet || options.silent
	mut updates := []utils.CpanUpdateResult{cap: options.formulae.len}
	mut stdout := []string{}
	mut stderr := []string{}
	mut failed := false
	for formula in options.formulae {
		update := utils.update_perl_resources(formula, utils.CpanUpdateOptions{
			print_only: options.print_only
			quiet: quiet
			verbose: options.verbose
			ignore_errors: options.ignore_errors
		}, fetch)!
		updates << update
		if options.print_only {
			stdout << update.resource_section
		} else {
			stdout << update.messages
		}
		stderr << update.errors
		failed = failed || update.failed
	}
	return UpdatePerlResourcesResult{
		bundler_groups: ['ast']
		updates: updates
		stdout: stdout
		stderr: stderr
		failed: failed
	}
}

@[heap]
pub struct UpdatePerlResourcesInput {
pub:
	options          UpdatePerlResourcesOptions
	metadata_payload string
}
