module dev_cmd

// Translated from Homebrew/brew `dev-cmd/verify.rb`.

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
	os         string
	arch       string
	bottle_tag string
}

pub struct VerifyOptions {
pub:
	formulae   []VerifyFormula
	catalog    map[string]VerifyFormula
	systems    []VerifySystem
	bottle_tag string
	deps       bool
	force      bool
	json       bool
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
			tag := if options.bottle_tag.len > 0 {
				options.bottle_tag
			} else {
				simulated.bottle_tag
			}
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
