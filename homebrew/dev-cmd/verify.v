module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/verify.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct VerifyBottle {
pub:
	filename         string
	attestation_json string
	invalid_error    string
}

pub struct VerifyFormula {
pub:
	name         string
	dependencies []string
	bottles      map[string]VerifyBottle
}

pub struct VerifySystem {
pub:
	os          string
	arch        string
	bottle_tag  string
}

pub struct VerifyOptions {
pub:
	formulae    []VerifyFormula
	catalog     map[string]VerifyFormula
	systems     []VerifySystem
	bottle_tag  string
	deps        bool
	force       bool
	json        bool
}

pub struct VerifyAttempt {
pub:
	formula       string
	os            string
	arch          string
	bottle_tag    string
	filename      string
	cache_cleared bool
	fetched       bool
	valid         bool
	attestation   string
}

pub struct VerifyResult {
pub:
	bucket       []string
	attempts     []VerifyAttempt
	json_results []string
	stdout       []string
	stderr       []string
	json_output  string
	failed       bool
}

pub fn run_verify(options VerifyOptions) VerifyResult {
	mut formulas := map[string]VerifyFormula{}
	for name, formula in options.catalog {
		formulas[name] = formula
	}
	for formula in options.formulae {
		formulas[formula.name] = formula
	}
	mut bucket := []string{}
	for formula in options.formulae {
		if formula.name !in bucket {
			bucket << formula.name
		}
		if options.deps {
			for dependency in formula.dependencies {
				if dependency !in bucket {
					bucket << dependency
				}
			}
		}
	}
	mut attempts := []VerifyAttempt{}
	mut json_results := []string{}
	mut stdout := []string{}
	mut stderr := []string{}
	mut failed := false
	for formula_name in bucket {
		formula := formulas[formula_name] or { continue }
		for simulated in options.systems {
			tag := if options.bottle_tag.len > 0 { options.bottle_tag } else { simulated.bottle_tag }
			bottle := formula.bottles[tag] or {
				stderr << 'Warning: Bottle for tag :${tag} is unavailable.'
				continue
			}
			mut attempt := VerifyAttempt{
				formula: formula.name
				os: simulated.os
				arch: simulated.arch
				bottle_tag: tag
				filename: bottle.filename
				cache_cleared: options.force
				fetched: true
				valid: bottle.invalid_error.len == 0
				attestation: bottle.attestation_json
			}
			if bottle.invalid_error.len > 0 {
				failed = true
				stderr << 'Failed to verify ${bottle.filename} with tag ${tag} due to error:\n\n${bottle.invalid_error}'
			} else {
				stdout << '${bottle.filename} has a valid attestation'
				json_results << bottle.attestation_json
			}
			attempts << attempt
		}
	}
	return VerifyResult{
		bucket: bucket
		attempts: attempts
		json_results: json_results
		stdout: stdout
		stderr: stderr
		json_output: if options.json { '[${json_results.join(',')}]' } else { '' }
		failed: failed
	}
}

@[heap]
pub struct VerifyInput {
pub:
	options VerifyOptions
}

pub fn verify_input_boundary(input &VerifyInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Verify::Input', '', {
		'verify_input_address': u64(voidptr(input)).str()
	})
}

fn verify_input_from_value(value brew_runtime.Value) &VerifyInput {
	address := value.attributes['verify_input_address'] or { panic('invalid Verify input') }
	return unsafe { &VerifyInput(voidptr(address.u64())) }
}

fn verify_attempt_value(attempt VerifyAttempt) brew_runtime.Value {
	return brew_runtime.map_value({
		'formula': brew_runtime.string_value(attempt.formula)
		'os': brew_runtime.string_value(attempt.os)
		'arch': brew_runtime.string_value(attempt.arch)
		'bottle_tag': brew_runtime.object_value('Symbol', attempt.bottle_tag)
		'filename': brew_runtime.string_value(attempt.filename)
		'cache_cleared': brew_runtime.bool_value(attempt.cache_cleared)
		'fetched': brew_runtime.bool_value(attempt.fetched)
		'valid': brew_runtime.bool_value(attempt.valid)
		'attestation': brew_runtime.string_value(attempt.attestation)
	})
}

fn verify_result_value(result VerifyResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'bucket': brew_runtime.string_array_value(result.bucket)
		'attempts': brew_runtime.array_value(result.attempts.map(verify_attempt_value(it)))
		'json_results': brew_runtime.string_array_value(result.json_results)
		'stdout': brew_runtime.string_array_value(result.stdout)
		'stderr': brew_runtime.string_array_value(result.stderr)
		'json_output': brew_runtime.string_value(result.json_output)
		'failed': brew_runtime.bool_value(result.failed)
	})
}

// Ruby method `run` at line 40.
pub fn ruby_verify_l40_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return verify_result_value(run_verify(verify_input_from_value(args[0]).options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "attestation"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Verify < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Verify the build provenance of bottles using GitHub's attestation tools.
// 13:           This is done by first fetching the given bottles and then verifying
// 14:           their provenance.
// 15:
// 16:           Note that this command depends on the GitHub CLI. Run `brew install gh`.
// 17:         EOS
// 18:         flag   "--os=",
// 19:                description: "Download for the given operating system. " \
// 20:                             "(Pass `all` to download for all operating systems.)"
// 21:         flag   "--arch=",
// 22:                description: "Download for the given CPU architecture. " \
// 23:                             "(Pass `all` to download for all architectures.)"
// 24:         flag   "--bottle-tag=",
// 25:                description: "Download a bottle for given tag."
// 26:         switch "--deps",
// 27:                description: "Also download dependencies for any listed <formula>."
// 28:         switch "-f", "--force",
// 29:                description: "Remove a previously cached version and re-fetch."
// 30:         switch "-j", "--json",
// 31:                description: "Return JSON for the attestation data for each bottle."
// 32:
// 33:         conflicts "--os", "--bottle-tag"
// 34:         conflicts "--arch", "--bottle-tag"
// 35:
// 36:         named_args [:formula], min: 1
// 37:       end
// 38:
// 39:       sig { override.void }
// 40:       def run
// 41:         bucket = if args.deps?
// 42:           args.named.to_formulae.flat_map do |formula|
// 43:             [formula, *formula.recursive_dependencies.map(&:to_formula)]
// 44:           end
// 45:         else
// 46:           args.named.to_formulae
// 47:         end.uniq
// 48:
// 49:         os_arch_combinations = args.os_arch_combinations
// 50:         json_results = []
// 51:         bucket.each do |formula|
// 52:           os_arch_combinations.each do |os, arch|
// 53:             SimulateSystem.with(os:, arch:) do
// 54:               bottle_tag = Utils::Bottles::Tag.from_arg(args.bottle_tag&.to_sym, os:, arch:)
// 55:
// 56:               bottle = formula.bottle_for_tag(bottle_tag)
// 57:
// 58:               if bottle
// 59:                 bottle.clear_cache if args.force?
// 60:                 bottle.fetch
// 61:                 begin
// 62:                   attestation = Homebrew::Attestation.check_core_attestation bottle
// 63:                   oh1 "#{bottle.filename} has a valid attestation"
// 64:                   json_results.push(attestation)
// 65:                 rescue Homebrew::Attestation::InvalidAttestationError => e
// 66:                   ofail <<~ERR
// 67:                     Failed to verify #{bottle.filename} with tag #{bottle_tag} due to error:
// 68:
// 69:                     #{e}
// 70:                   ERR
// 71:                 end
// 72:               else
// 73:                 opoo "Bottle for tag #{bottle_tag.to_sym.inspect} is unavailable."
// 74:               end
// 75:             end
// 76:           end
// 77:         end
// 78:
// 79:         puts json_results.to_json if args.json?
// 80:       end
// 81:     end
// 82:   end
// 83: end
