module utils

import ruby

// Translated from Homebrew/brew `utils/attestation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.check_attestation(bottle, quiet: false)` at line 13.
pub fn ruby_attestation_l13_d1_self_check_attestation(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'bottle is required')
	}
	bottle := AttestationBottle{
		name: args[0].attribute('name') or { args[0].as_string() }
	}
	options := AttestationOptions{
		quiet: if args.len > 1 { args[1].as_bool() or { false } } else { false }
		verify_attestations: if args.len > 3 { args[3].as_bool() or { false } } else { false }
	}
	check := AttestationCheck{
		failure: if args.len > 2 {
			attestation_failure_from_string(args[2].as_string())} else {
			.none}
		context: if args.len > 4 { args[4].as_string() } else { '' }
	}
	result := check_bottle_attestation(bottle, options, fn [check] (_ AttestationBottle) AttestationCheck {
		return check
	}) or { return ruby.object_value('CannotInstallFormulaError', err.msg()) }
	return ruby.structured_value('AttestationCheckResult', bottle.name, {
		'name':                   bottle.name
		'heading':                result.heading
		'no_verify_attestations': result.no_verify_attestations.str()
	})
}

pub struct AttestationBottle {
pub:
	name string
}

pub enum AttestationFailure {
	none
	gh_incompatible
	gh_auth_invalid
	gh_auth_needed
	missing_attestation
	invalid_attestation
}

pub struct AttestationCheck {
pub:
	failure AttestationFailure
	context string
}

pub struct AttestationOptions {
pub:
	quiet               bool
	verify_attestations bool
}

pub struct AttestationCheckResult {
pub:
	heading                string
	no_verify_attestations bool
}

pub type BottleAttestationChecker = fn(bottle AttestationBottle) AttestationCheck

fn attestation_failure_from_string(value string) AttestationFailure {
	return match value {
		'gh_incompatible' { .gh_incompatible }
		'gh_auth_invalid' { .gh_auth_invalid }
		'gh_auth_needed' { .gh_auth_needed }
		'missing_attestation' { .missing_attestation }
		'invalid_attestation' { .invalid_attestation }
		else { .none }
	}
}

fn attestation_error_header(name string) string {
	return 'The bottle for ${name} could not be verified.'
}

pub fn check_bottle_attestation(bottle AttestationBottle, options AttestationOptions,
	checker BottleAttestationChecker) !AttestationCheckResult {
	check := checker(bottle)
	heading := if options.quiet { '' } else { 'Verifying attestation for ${bottle.name}' }
	match check.failure {
		.none {
			return AttestationCheckResult{ heading: heading }
		}
		.gh_incompatible {
			return error('${attestation_error_header(bottle.name)}\n\nThis typically indicates an outdated or incompatible `gh` CLI.\n\nPlease confirm that you are running the latest version of `gh` by performing an upgrade before retrying:\n\n  brew update\n  brew upgrade gh')
		}
		.gh_auth_invalid {
			if options.verify_attestations {
				return error('${attestation_error_header(bottle.name)}\n\nThis typically indicates an invalid GitHub API token.\n\nIf you have `\$HOMEBREW_GITHUB_API_TOKEN` set, check it is correct or unset it and instead run:\n\n  gh auth login')
			}
			return AttestationCheckResult{
				heading: heading
				no_verify_attestations: true
			}
		}
		.gh_auth_needed {
			return error('${attestation_error_header(bottle.name)}\n\nThis typically indicates a missing GitHub API token, which you can resolve either by setting `\$HOMEBREW_GITHUB_API_TOKEN` or by running:\n\n  gh auth login')
		}
		.missing_attestation, .invalid_attestation {
			context := if check.context.trim_space() != '' {
				check.context
			} else {
				check.failure.str()
			}
			return error("The bottle for ${bottle.name} has an invalid build provenance attestation.\n\nThis may indicate that the bottle was not produced by the expected tap, or was maliciously inserted into the expected tap's bottle storage.\n\nAdditional context:\n\n${context}")
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "attestation"
// 5: require "bottle"
// 6: require "utils/output"
// 7:
// 8: module Utils
// 9:   module Attestation
// 10:     extend Utils::Output::Mixin
// 11:
// 12:     sig { params(bottle: Bottle, quiet: T::Boolean).void }
// 13:     def self.check_attestation(bottle, quiet: false)
// 14:       ohai "Verifying attestation for #{bottle.name}" unless quiet
// 15:       begin
// 16:         Homebrew::Attestation.check_core_attestation bottle
// 17:       rescue Homebrew::Attestation::GhIncompatible
// 18:         # A small but significant number of users have developer mode enabled
// 19:         # but *also* haven't upgraded in a long time, meaning that their `gh`
// 20:         # version is too old to perform attestations.
// 21:         raise CannotInstallFormulaError, <<~EOS
// 22:           The bottle for #{bottle.name} could not be verified.
// 23:
// 24:           This typically indicates an outdated or incompatible `gh` CLI.
// 25:
// 26:           Please confirm that you're running the latest version of `gh`
// 27:           by performing an upgrade before retrying:
// 28:
// 29:             brew update
// 30:             brew upgrade gh
// 31:         EOS
// 32:       rescue Homebrew::Attestation::GhAuthInvalid
// 33:         # Only raise an error if we explicitly opted-in to verification.
// 34:         raise CannotInstallFormulaError, <<~EOS if Homebrew::EnvConfig.verify_attestations?
// 35:           The bottle for #{bottle.name} could not be verified.
// 36:
// 37:           This typically indicates an invalid GitHub API token.
// 38:
// 39:           If you have `$HOMEBREW_GITHUB_API_TOKEN` set, check it is correct
// 40:           or unset it and instead run:
// 41:
// 42:             gh auth login
// 43:         EOS
// 44:
// 45:         # If we didn't explicitly opt-in, then quietly opt-out in the case of invalid credentials.
// 46:         # Based on user reports, a significant number of users are running with stale tokens.
// 47:         ENV["HOMEBREW_NO_VERIFY_ATTESTATIONS"] = "1"
// 48:       rescue Homebrew::Attestation::GhAuthNeeded
// 49:         raise CannotInstallFormulaError, <<~EOS
// 50:           The bottle for #{bottle.name} could not be verified.
// 51:
// 52:           This typically indicates a missing GitHub API token, which you
// 53:           can resolve either by setting `$HOMEBREW_GITHUB_API_TOKEN` or
// 54:           by running:
// 55:
// 56:             gh auth login
// 57:         EOS
// 58:       rescue Homebrew::Attestation::MissingAttestationError, Homebrew::Attestation::InvalidAttestationError => e
// 59:         raise CannotInstallFormulaError, <<~EOS
// 60:           The bottle for #{bottle.name} has an invalid build provenance attestation.
// 61:
// 62:           This may indicate that the bottle was not produced by the expected
// 63:           tap, or was maliciously inserted into the expected tap's bottle
// 64:           storage.
// 65:
// 66:           Additional context:
// 67:
// 68:           #{e}
// 69:         EOS
// 70:       end
// 71:     end
// 72:   end
// 73: end
