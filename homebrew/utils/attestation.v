module utils

// Translated from Homebrew/brew `utils/attestation.rb`.

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

pub type BottleAttestationChecker = fn (bottle AttestationBottle) AttestationCheck

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
