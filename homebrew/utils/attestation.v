module utils

import brew_runtime

// Translated from Homebrew/brew `utils/attestation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.check_attestation(bottle, quiet: false)` at line 13.
pub fn ruby_attestation_l13_d1_self_check_attestation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check_attestation', ...args)
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
