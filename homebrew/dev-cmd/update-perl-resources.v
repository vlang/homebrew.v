module dev_cmd

import ruby
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

pub fn update_perl_resources_input_boundary(input &UpdatePerlResourcesInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::UpdatePerlResources::Input', '', {
		'update_perl_resources_input_address': u64(voidptr(input)).str()
	})
}

fn update_perl_resources_input_from_value(value ruby.Value) &UpdatePerlResourcesInput {
	address := value.attributes['update_perl_resources_input_address'] or {
		panic('invalid UpdatePerlResources input')
	}
	return unsafe { &UpdatePerlResourcesInput(voidptr(address.u64())) }
}

fn cpan_update_result_value(result utils.CpanUpdateResult) ruby.Value {
	return ruby.map_value({
		'resource_section': ruby.string_value(result.resource_section)
		'updated_source':   ruby.string_value(result.updated_source)
		'messages':         ruby.string_array_value(result.messages)
		'errors':           ruby.string_array_value(result.errors)
		'updated_count':    ruby.int_value(result.updated_count)
		'failed':           ruby.bool_value(result.failed)
	})
}

fn update_perl_resources_result_value(result UpdatePerlResourcesResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups': ruby.string_array_value(result.bundler_groups)
		'updates':        ruby.array_value(result.updates.map(cpan_update_result_value(it)))
		'stdout':         ruby.string_array_value(result.stdout)
		'stderr':         ruby.string_array_value(result.stderr)
		'failed':         ruby.bool_value(result.failed)
	})
}
