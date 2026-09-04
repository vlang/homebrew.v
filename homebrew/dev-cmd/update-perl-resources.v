module dev_cmd

import ruby
import homebrew.utils

// Translated from Homebrew/brew `dev-cmd/update-perl-resources.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `run` at line 26.
pub fn ruby_update_perl_resources_l26_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	input := update_perl_resources_input_from_value(args[0])
	payload := input.metadata_payload
	result := run_update_perl_resources(input.options, fn [payload] (_ string) !string {
		if payload.len == 0 {
			return error('MetaCPAN response was not supplied')
		}
		return payload
	}) or { return ruby.object_value('Error', err.msg()) }
	return update_perl_resources_result_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "utils/cpan"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class UpdatePerlResources < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Update versions for CPAN resource blocks in <formula>.
// 13:         EOS
// 14:         switch "-p", "--print-only",
// 15:                description: "Print the updated resource blocks instead of changing <formula>."
// 16:         switch "-s", "--silent",
// 17:                description: "Suppress any output.",
// 18:                odeprecated: true
// 19:         switch "--ignore-errors",
// 20:                description: "Continue processing even if some resources can't be resolved."
// 21:
// 22:         named_args :formula, min: 1, without_api: true
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         Homebrew.install_bundler_gems!(groups: ["ast"])
// 28:
// 29:         args.named.to_formulae.each do |formula|
// 30:           CPAN.update_perl_resources! formula,
// 31:                                       print_only:    args.print_only?,
// 32:                                       quiet:         args.quiet? || args.silent?,
// 33:                                       verbose:       args.verbose?,
// 34:                                       ignore_errors: args.ignore_errors?
// 35:         end
// 36:       end
// 37:     end
// 38:   end
// 39: end
