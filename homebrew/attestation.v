module homebrew

import ruby
import crypto.sha256
import os
import time
import x.json2

// Translated from Homebrew/brew `attestation.rb`.
// The original source is retained below until every stub has a typed V body.
pub const attestation_homebrew_core_repo = 'Homebrew/homebrew-core'
pub const attestation_backfill_repo = 'trailofbits/homebrew-brew-verify'
pub const attestation_max_retries = 5

pub struct AttestationFormula {
pub:
	full_name string
}

pub struct AttestationBottle {
pub:
	name                  string
	cached_download       string
	filename              string
	filename_name         string
	filename_version      string
	tag                   string
	url                   string
	resource_name         string
	resource_checksum     string
	bottle_domain_custom  bool
	default_bottle_domain string = 'https://ghcr.io/v2/homebrew/core'
}

pub struct AttestationRecord {
pub:
	subjects            []string
	verified_timestamps []string
	raw                 map[string]json2.Any
}

pub struct AttestationCommand {
pub:
	executable   string
	args         []string
	environment  map[string]string
	secrets      []string
	print_stderr bool
	chdir        string
}

pub struct AttestationCommandResult {
pub:
	stdout          string
	stderr          string
	exit_status     int
	failed          bool
	failure_message string
}

pub struct AttestationRuntime {
pub mut:
	gh_executable_cache string
	commands            []AttestationCommand
	responses           []AttestationCommandResult
	response_index      int
	ensure_calls        int
	retry_counts        map[string]int
	output              []string
	sleeps              []int
}

pub type AttestationGhEnsurer = fn(mut runtime AttestationRuntime, name string, reason string, latest bool) !string

pub type AttestationCommandRunner = fn(mut runtime AttestationRuntime, command AttestationCommand) !AttestationCommandResult

pub type AttestationSleeper = fn(mut runtime AttestationRuntime, seconds int) !

pub struct AttestationCollaborators {
pub:
	ensure_gh   AttestationGhEnsurer @[required]
	run_command AttestationCommandRunner @[required]
	sleep       AttestationSleeper @[required]
}

fn attestation_real_ensure_gh(mut runtime AttestationRuntime, name string, _ string,
	_ bool) !string {
	runtime.ensure_calls++
	return ruby.find_executable(name)
}

fn attestation_real_command(mut runtime AttestationRuntime,
	command AttestationCommand) !AttestationCommandResult {
	runtime.commands << command
	mut argv := [command.executable]
	argv << command.args
	result := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
		environment: command.environment
		chdir: command.chdir
	})!
	return AttestationCommandResult{
		stdout: result.stdout
		stderr: result.stderr
		exit_status: result.exit_code
		failed: result.exit_code != 0
		failure_message: '${argv.join(' ')} exited with ${result.exit_code}'
	}
}

fn attestation_real_sleep(mut runtime AttestationRuntime, seconds int) ! {
	runtime.sleeps << seconds
	time.sleep(seconds * time.second)
}

pub fn attestation_default_collaborators() AttestationCollaborators {
	return AttestationCollaborators{
		ensure_gh: attestation_real_ensure_gh
		run_command: attestation_real_command
		sleep: attestation_real_sleep
	}
}

pub fn attestation_gh_executable(mut runtime AttestationRuntime,
	collaborators AttestationCollaborators) !string {
	if runtime.gh_executable_cache != '' {
		return runtime.gh_executable_cache
	}
	runtime.gh_executable_cache = collaborators.ensure_gh(mut runtime, 'gh', 'verifying attestations', true)!
	return runtime.gh_executable_cache
}

pub fn attestation_sort_formulae_for_install(formulae []AttestationFormula,
	mut runtime AttestationRuntime, collaborators AttestationCollaborators) ![]AttestationFormula {
	mut gh_index := -1
	for index, formula in formulae {
		if formula.full_name == 'gh' {
			gh_index = index
			break
		}
	}
	if gh_index < 0 {
		attestation_gh_executable(mut runtime, collaborators)!
		return formulae.clone()
	}
	mut sorted := [formulae[gh_index]]
	for formula in formulae {
		if sorted.all(it.full_name != formula.full_name) {
			sorted << formula
		}
	}
	return sorted
}

fn attestation_failure(kind string, message string) IError {
	return error('${kind}: ${message}')
}

fn attestation_any_string(value json2.Any) string {
	if value is string {
		return value
	}
	return value.str()
}

pub fn parse_attestation_records(contents string) ![]AttestationRecord {
	decoded := json2.decode[json2.Any](contents) or {
		return attestation_failure('InvalidAttestationError', 'attestation verification returned malformed JSON')
	}
	if decoded !is []json2.Any {
		return attestation_failure('InvalidAttestationError', 'attestation verification returned malformed JSON')
	}
	mut records := []AttestationRecord{}
	for raw_entry in decoded.as_array() {
		if raw_entry !is map[string]json2.Any {
			continue
		}
		entry := raw_entry.as_map()
		verification := (entry['verificationResult'] or { json2.Any(map[string]json2.Any{}) }).as_map()
		statement := (verification['statement'] or { json2.Any(map[string]json2.Any{}) }).as_map()
		mut subjects := []string{}
		for subject_value in (statement['subject'] or { json2.Any([]json2.Any{}) }).as_array() {
			subject_map := subject_value.as_map()
			if name := subject_map['name'] {
				subjects << attestation_any_string(name)
			}
		}
		mut timestamps := []string{}
		for timestamp_value in (verification['verifiedTimestamps'] or { json2.Any([]json2.Any{}) }).as_array() {
			timestamp_map := timestamp_value.as_map()
			if timestamp := timestamp_map['timestamp'] {
				timestamps << attestation_any_string(timestamp)
			}
		}
		records << AttestationRecord{
			subjects: subjects
			verified_timestamps: timestamps
			raw: entry.clone()
		}
	}
	return records
}

fn attestation_no_attestations(stderr string) bool {
	return stderr.contains('HTTP 404: Not Found') || stderr.contains(': no attestations found\n') || stderr.contains(': no attestations found\r\n')
}

pub fn check_bottle_attestation(mut runtime AttestationRuntime, bottle AttestationBottle,
	signing_repo string, signing_workflow ?string, requested_subject ?string, credentials string,
	collaborators AttestationCollaborators) !AttestationRecord {
	mut args := ['attestation', 'verify', bottle.cached_download, '--repo', signing_repo, '--format',
		'json']
	if workflow := signing_workflow {
		if workflow.trim_space() != '' {
			args << ['--cert-identity', workflow]
		}
	}
	if credentials.trim_space() == '' {
		return attestation_failure('GhAuthNeeded', 'missing credentials')
	}
	gh := attestation_gh_executable(mut runtime, collaborators)!
	result := collaborators.run_command(mut runtime, AttestationCommand{
		executable: gh
		args: args
		environment: {
			'GH_TOKEN': credentials
			'GH_HOST':  'github.com'
		}
		secrets: [credentials]
		print_stderr: false
		chdir: os.temp_dir()
	}) or {
		return attestation_failure('InvalidAttestationError', 'attestation verification failed: ${err.msg()}')
	}
	if result.failed {
		failure := if result.failure_message != '' { result.failure_message } else { result.stderr }
		if result.exit_status == 1 && result.stderr.contains('unknown command') {
			return attestation_failure('GhIncompatible', 'gh CLI is incompatible with attestations')
		}
		if result.exit_status == 4 || result.stderr.contains('HTTP 401: Bad credentials') {
			return attestation_failure('GhAuthInvalid', 'invalid credentials')
		}
		if attestation_no_attestations(result.stderr) {
			return attestation_failure('MissingAttestationError', 'attestation not found: ${failure}')
		}
		return attestation_failure('InvalidAttestationError', 'attestation verification failed: ${failure}')
	}
	records := parse_attestation_records(result.stdout)!
	requested := requested_subject or { '' }
	subject := if requested.trim_space() == '' { bottle.filename } else { requested }
	for record in records {
		if bottle.tag == 'all' {
			prefix := '${bottle.filename_name}--${bottle.filename_version}'
			if record.subjects.any(it.starts_with(prefix)) {
				return record
			}
		} else if record.subjects.any(it == subject) {
			return record
		}
	}
	return attestation_failure('InvalidAttestationError', 'no attestation matches subject: ${subject}')
}

fn attestation_backfill_subject(bottle AttestationBottle) !string {
	mut source_url := bottle.url
	if bottle.bottle_domain_custom {
		if bottle.resource_checksum == '' {
			return error('${bottle.resource_name} checksum is nil')
		}
		path := '${bottle.name.replace('@', '/').replace('+', 'x')}/blobs/sha256:${bottle.resource_checksum}'
		source_url = '${bottle.default_bottle_domain}/${path}'
	}
	return '${sha256.sum256(source_url.bytes()).hex()}--${bottle.filename}'
}

fn attestation_backfill_timestamp_valid(record AttestationRecord) ! {
	if record.verified_timestamps.len == 0 {
		return attestation_failure('InvalidAttestationError', 'backfill attestation is missing verified timestamp')
	}
	verified := time.parse_iso8601(record.verified_timestamps[0]) or {
		return attestation_failure('InvalidAttestationError', 'backfill attestation is missing verified timestamp')
	}
	cutoff := time.parse_iso8601('2024-03-14T00:00:00Z')!
	if verified > cutoff {
		return attestation_failure('InvalidAttestationError', 'backfill attestation post-dates cutoff')
	}
}

pub fn check_core_bottle_attestation(mut runtime AttestationRuntime, bottle AttestationBottle,
	credentials string, tests_running bool, collaborators AttestationCollaborators) !AttestationRecord {
	key := bottle.filename
	for {
		mut verified := AttestationRecord{}
		mut verification_error := ''
		verified = check_bottle_attestation(mut runtime, bottle, attestation_homebrew_core_repo, none, none, credentials, collaborators) or {
			if err.msg().starts_with('MissingAttestationError:') {
				runtime.output << 'falling back on backfilled attestation for ${bottle.filename}'
				subject := attestation_backfill_subject(bottle) or {
					return err
				}
				backfill := check_bottle_attestation(mut runtime, bottle, attestation_backfill_repo, none, subject, credentials, collaborators) or {
					verification_error = err.msg()
					AttestationRecord{}
				}
				if verification_error == '' {
					attestation_backfill_timestamp_valid(backfill) or {
						verification_error = err.msg()
					}
				}
				backfill
			} else {
				verification_error = err.msg()
				AttestationRecord{}
			}
		}
		if verification_error == '' {
			return verified
		}
		if !verification_error.starts_with('InvalidAttestationError:') {
			return error(verification_error)
		}
		count := runtime.retry_counts[key] or { 0 }
		if count >= attestation_max_retries {
			return error(verification_error)
		}
		sleep_time := int_pow(3, count)
		runtime.output << 'Failed to verify attestation. Retrying in ${sleep_time}s...'
		if !tests_running {
			collaborators.sleep(mut runtime, sleep_time)!
		}
		runtime.retry_counts[key] = count + 1
	}
	return error('InvalidAttestationError: attestation verification failed')
}

fn int_pow(base int, exponent int) int {
	mut result := 1
	for _ in 0 .. exponent {
		result *= base
	}
	return result
}

fn attestation_injected_ensure_gh(mut runtime AttestationRuntime, _ string, _ string,
	_ bool) !string {
	runtime.ensure_calls++
	return '/extremely/fake/gh'
}

fn attestation_injected_command(mut runtime AttestationRuntime,
	command AttestationCommand) !AttestationCommandResult {
	runtime.commands << command
	if runtime.response_index >= runtime.responses.len {
		return error('no injected attestation command response')
	}
	result := runtime.responses[runtime.response_index]
	runtime.response_index++
	return result
}

fn attestation_injected_sleep(mut runtime AttestationRuntime, seconds int) ! {
	runtime.sleeps << seconds
}

pub fn attestation_injected_collaborators() AttestationCollaborators {
	return AttestationCollaborators{
		ensure_gh: attestation_injected_ensure_gh
		run_command: attestation_injected_command
		sleep: attestation_injected_sleep
	}
}

// Ruby method `self.gh_executable` at line 67.
pub fn ruby_attestation_l67_d1_self_gh_executable(args ...ruby.Value) ruby.Value {
	if args.len > 0 && args[0].as_string() != '' {
		return ruby.object_value('Pathname', args[0].as_string())
	}
	mut runtime := AttestationRuntime{}
	path := attestation_gh_executable(mut runtime, attestation_default_collaborators()) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.object_value('Pathname', path)
}

// Ruby method `self.sort_formulae_for_install(formulae)` at line 88.
pub fn ruby_attestation_l88_d2_self_sort_formulae_for_install(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'formulae are required')
	}
	formulae := attestation_formulae_from_value(args[0])
	mut runtime := AttestationRuntime{
		gh_executable_cache: if args.len > 1 { args[1].as_string() } else { '' }
	}
	sorted := attestation_sort_formulae_for_install(formulae, mut runtime, attestation_injected_collaborators()) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return attestation_formulae_value(sorted)
}

// Ruby method `self.check_attestation(bottle, signing_repo, signing_workflow = nil, subject = nil)` at line 115.
pub fn ruby_attestation_l115_d3_self_check_attestation(args ...ruby.Value) ruby.Value {
	if args.len < 6 {
		return ruby.object_value('ArgumentError', 'bottle, repository, options, credentials, and command result are required')
	}
	bottle := attestation_bottle_from_value(args[0])
	workflow := attestation_optional_string(args[2])
	subject := attestation_optional_string(args[3])
	mut runtime := AttestationRuntime{
		gh_executable_cache: if args.len > 6 { args[6].as_string() } else { '/extremely/fake/gh' }
		responses: [attestation_command_result_from_value(args[5])]
	}
	record := check_bottle_attestation(mut runtime, bottle, args[1].as_string(), workflow, subject, args[4].as_string(), attestation_injected_collaborators()) or {
		return attestation_error_value(err.msg())
	}
	return attestation_record_value(record)
}

// Ruby method `self.check_core_attestation(bottle)` at line 203.
pub fn ruby_attestation_l203_d4_self_check_core_attestation(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'bottle, credentials, and command results are required')
	}
	mut runtime := AttestationRuntime{
		gh_executable_cache: if args.len > 4 { args[4].as_string() } else { '/extremely/fake/gh' }
		responses: attestation_command_results_from_value(args[2])
	}
	record := check_core_bottle_attestation(mut runtime, attestation_bottle_from_value(args[0]), args[1].as_string(), if args.len > 3 {
		args[3].as_bool() or { true }
	} else {
		true
	}, attestation_injected_collaborators()) or {
		return attestation_error_value(err.msg())
	}
	return attestation_record_value(record)
}

pub fn attestation_formulae_value(formulae []AttestationFormula) ruby.Value {
	return ruby.array_value(formulae.map(ruby.structured_value('Formula', it.full_name, {
		'full_name': it.full_name
	})))
}

pub fn attestation_formulae_from_value(value ruby.Value) []AttestationFormula {
	values := value.as_array() or { return [] }
	return values.map(AttestationFormula{
		full_name: it.attributes['full_name'] or { it.as_string() }
	})
}

pub fn attestation_bottle_value(bottle AttestationBottle) ruby.Value {
	return ruby.map_value({
		'name':                  ruby.string_value(bottle.name)
		'cached_download':       ruby.string_value(bottle.cached_download)
		'filename':              ruby.string_value(bottle.filename)
		'filename_name':         ruby.string_value(bottle.filename_name)
		'filename_version':      ruby.string_value(bottle.filename_version)
		'tag':                   ruby.object_value('Symbol', bottle.tag)
		'url':                   ruby.string_value(bottle.url)
		'resource_name':         ruby.string_value(bottle.resource_name)
		'resource_checksum':     ruby.string_value(bottle.resource_checksum)
		'bottle_domain_custom':  ruby.bool_value(bottle.bottle_domain_custom)
		'default_bottle_domain': ruby.string_value(bottle.default_bottle_domain)
	})
}

pub fn attestation_bottle_from_value(value ruby.Value) AttestationBottle {
	values := value.as_map() or { return AttestationBottle{} }
	return AttestationBottle{
		name: (values['name'] or { ruby.string_value('') }).as_string()
		cached_download: (values['cached_download'] or { ruby.string_value('') }).as_string()
		filename: (values['filename'] or { ruby.string_value('') }).as_string()
		filename_name: (values['filename_name'] or { ruby.string_value('') }).as_string()
		filename_version: (values['filename_version'] or { ruby.string_value('') }).as_string()
		tag: (values['tag'] or { ruby.string_value('') }).as_string()
		url: (values['url'] or { ruby.string_value('') }).as_string()
		resource_name: (values['resource_name'] or { ruby.string_value('') }).as_string()
		resource_checksum: (values['resource_checksum'] or { ruby.string_value('') }).as_string()
		bottle_domain_custom: (values['bottle_domain_custom'] or {
			ruby.bool_value(false)}).as_bool() or { false }
		default_bottle_domain: (values['default_bottle_domain'] or {
			ruby.string_value('https://ghcr.io/v2/homebrew/core')}).as_string()
	}
}

pub fn attestation_command_result_value(result AttestationCommandResult) ruby.Value {
	return ruby.map_value({
		'stdout':          ruby.string_value(result.stdout)
		'stderr':          ruby.string_value(result.stderr)
		'exit_status':     ruby.int_value(result.exit_status)
		'failed':          ruby.bool_value(result.failed)
		'failure_message': ruby.string_value(result.failure_message)
	})
}

pub fn attestation_command_result_from_value(value ruby.Value) AttestationCommandResult {
	values := value.as_map() or { return AttestationCommandResult{} }
	return AttestationCommandResult{
		stdout: (values['stdout'] or { ruby.string_value('') }).as_string()
		stderr: (values['stderr'] or { ruby.string_value('') }).as_string()
		exit_status: int((values['exit_status'] or { ruby.int_value(0) }).as_int() or { 0 })
		failed: (values['failed'] or { ruby.bool_value(false) }).as_bool() or { false }
		failure_message: (values['failure_message'] or { ruby.string_value('') }).as_string()
	}
}

pub fn attestation_command_results_value(results []AttestationCommandResult) ruby.Value {
	return ruby.array_value(results.map(attestation_command_result_value(it)))
}

pub fn attestation_command_results_from_value(value ruby.Value) []AttestationCommandResult {
	values := value.as_array() or { return [] }
	return values.map(attestation_command_result_from_value(it))
}

pub fn attestation_record_value(record AttestationRecord) ruby.Value {
	return ruby.map_value({
		'subjects':            ruby.string_array_value(record.subjects)
		'verified_timestamps': ruby.string_array_value(record.verified_timestamps)
		'raw_json':            ruby.string_value(json2.encode(record.raw))
	})
}

fn attestation_optional_string(value ruby.Value) ?string {
	if value.type_name == 'NilClass' || value.as_string() == '' {
		return none
	}
	return value.as_string()
}

fn attestation_error_value(message string) ruby.Value {
	if separator := message.index(': ') {
		return ruby.object_value(message[..separator], message[separator + 2..])
	}
	return ruby.object_value('RuntimeError', message)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "date"
// 5: require "json"
// 6: require "utils/popen"
// 7: require "utils/github/api"
// 8: require "exceptions"
// 9: require "system_command"
// 10: require "utils/output"
// 11:
// 12: module Homebrew
// 13:   module Attestation
// 14:     extend SystemCommand::Mixin
// 15:     extend Utils::Output::Mixin
// 16:
// 17:     # @api private
// 18:     HOMEBREW_CORE_REPO = "Homebrew/homebrew-core"
// 19:
// 20:     # @api private
// 21:     BACKFILL_REPO = "trailofbits/homebrew-brew-verify"
// 22:
// 23:     # No backfill attestations after this date are considered valid.
// 24:     #
// 25:     # This date is shortly after the backfill operation for homebrew-core
// 26:     # completed, as can be seen here: <https://github.com/trailofbits/homebrew-brew-verify/attestations>.
// 27:     #
// 28:     # In effect, this means that, even if an attacker is able to compromise the backfill
// 29:     # signing workflow, they will be unable to convince a verifier to accept their newer,
// 30:     # malicious backfilled signatures.
// 31:     #
// 32:     # @api private
// 33:     BACKFILL_CUTOFF = DateTime.new(2024, 3, 14).freeze
// 34:
// 35:     # Raised when the attestation was not found.
// 36:     #
// 37:     # @api private
// 38:     class MissingAttestationError < RuntimeError; end
// 39:
// 40:     # Raised when attestation verification fails.
// 41:     #
// 42:     # @api private
// 43:     class InvalidAttestationError < RuntimeError; end
// 44:
// 45:     # Raised if attestation verification cannot continue due to missing
// 46:     # credentials.
// 47:     #
// 48:     # @api private
// 49:     class GhAuthNeeded < RuntimeError; end
// 50:
// 51:     # Raised if attestation verification cannot continue due to invalid
// 52:     # credentials.
// 53:     #
// 54:     # @api private
// 55:     class GhAuthInvalid < RuntimeError; end
// 56:
// 57:     # Raised if attestation verification cannot continue due to `gh`
// 58:     # being incompatible with attestations, typically because it's too old.
// 59:     #
// 60:     # @api private
// 61:     class GhIncompatible < RuntimeError; end
// 62:
// 63:     # Returns a path to a suitable `gh` executable for attestation verification.
// 64:     #
// 65:     # @api private
// 66:     sig { returns(Pathname) }
// 67:     def self.gh_executable
// 68:       @gh_executable ||= T.let(nil, T.nilable(Pathname))
// 69:       return @gh_executable if @gh_executable
// 70:
// 71:       # NOTE: We set HOMEBREW_NO_VERIFY_ATTESTATIONS when installing `gh` itself,
// 72:       #       to prevent a cycle during bootstrapping. This can eventually be resolved
// 73:       #       by vendoring a pure-Ruby Sigstore verifier client.
// 74:       @gh_executable = with_env(HOMEBREW_NO_VERIFY_ATTESTATIONS: "1") do
// 75:         ensure_executable!("gh", reason: "verifying attestations", latest: true)
// 76:       end
// 77:     end
// 78:
// 79:     # Prioritize installing `gh` first if it's in the formula list
// 80:     # or check for the existence of the `gh` executable elsewhere.
// 81:     #
// 82:     # This ensures that a valid version of `gh` is installed before
// 83:     # we use it to check the attestations of any other formulae we
// 84:     # want to install.
// 85:     #
// 86:     # @api private
// 87:     sig { params(formulae: T::Array[Formula]).returns(T::Array[Formula]) }
// 88:     def self.sort_formulae_for_install(formulae)
// 89:       if (gh = formulae.find { |f| f.full_name == "gh" })
// 90:         [gh] | formulae
// 91:       else
// 92:         Homebrew::Attestation.gh_executable
// 93:         formulae
// 94:       end
// 95:     end
// 96:
// 97:     # Verifies the given bottle against a cryptographic attestation of build provenance.
// 98:     #
// 99:     # The provenance is verified as originating from `signing_repository`, which is a `String`
// 100:     # that should be formatted as a GitHub `owner/repository`.
// 101:     #
// 102:     # Callers may additionally pass in `signing_workflow`, which will scope the attestation
// 103:     # down to an exact GitHub Actions workflow, in
// 104:     # `https://github/OWNER/REPO/.github/workflows/WORKFLOW.yml@REF` format.
// 105:     #
// 106:     # @return [Hash] the JSON-decoded response.
// 107:     # @raise [GhAuthNeeded] on any authentication failures
// 108:     # @raise [InvalidAttestationError] on any verification failures
// 109:     #
// 110:     # @api private
// 111:     sig {
// 112:       params(bottle: Bottle, signing_repo: String,
// 113:              signing_workflow: T.nilable(String), subject: T.nilable(String)).returns(T::Hash[String, T.untyped])
// 114:     }
// 115:     def self.check_attestation(bottle, signing_repo, signing_workflow = nil, subject = nil)
// 116:       cmd = ["attestation", "verify", bottle.cached_download, "--repo", signing_repo, "--format",
// 117:              "json"]
// 118:
// 119:       cmd += ["--cert-identity", signing_workflow] if signing_workflow.present?
// 120:
// 121:       # Fail early if we have no credentials. The command below invariably
// 122:       # fails without them, so this saves us an unnecessary subshell.
// 123:       credentials = GitHub::API.credentials
// 124:       raise GhAuthNeeded, "missing credentials" if credentials.blank?
// 125:
// 126:       begin
// 127:         result = system_command!(gh_executable, args: cmd,
// 128:                                  env: { "GH_TOKEN" => credentials, "GH_HOST" => "github.com" },
// 129:                                  secrets: [credentials], print_stderr: false, chdir: HOMEBREW_TEMP)
// 130:       rescue ErrorDuringExecution => e
// 131:         if e.exitstatus == 1 && e.stderr.include?("unknown command")
// 132:           raise GhIncompatible, "gh CLI is incompatible with attestations"
// 133:         end
// 134:
// 135:         # Even if we have credentials, they may be invalid or malformed.
// 136:         if e.exitstatus == 4 || e.stderr.include?("HTTP 401: Bad credentials")
// 137:           raise GhAuthInvalid, "invalid credentials"
// 138:         end
// 139:
// 140:         # The API used to return 404 but now can return 200 with an empty array.
// 141:         # We match the no attestation case precisely as there are similarly worded errors.
// 142:         if e.stderr.include?("HTTP 404: Not Found") || e.stderr.match?(/: no attestations found\R/)
// 143:           raise MissingAttestationError, "attestation not found: #{e}"
// 144:         end
// 145:
// 146:         raise InvalidAttestationError, "attestation verification failed: #{e}"
// 147:       end
// 148:
// 149:       begin
// 150:         attestations = JSON.parse(result.stdout)
// 151:       rescue JSON::ParserError
// 152:         raise InvalidAttestationError, "attestation verification returned malformed JSON"
// 153:       end
// 154:
// 155:       # `gh attestation verify` returns a JSON array of one or more results,
// 156:       # for all attestations that match the input's digest. We want to additionally
// 157:       # filter these down to just the attestation whose subject(s) contain the bottle's name.
// 158:       # As of 2024-12-04 GitHub's Artifact Attestation feature can put multiple subjects
// 159:       # in a single attestation, so we check every subject in each attestation
// 160:       # and select the first attestation with a matching subject.
// 161:       # In particular, this happens with v2.0.0 and later of the
// 162:       # `actions/attest` action.
// 163:       subject = bottle.filename.to_s if subject.blank?
// 164:
// 165:       attestation = if bottle.tag.to_sym == :all
// 166:         # :all-tagged bottles are created by `brew bottle --merge`, and are not directly
// 167:         # bound to their own filename (since they're created by deduplicating other filenames).
// 168:         # To verify these, we parse each attestation subject and look for one with a matching
// 169:         # formula (name, version), but not an exact tag match.
// 170:         # This is sound insofar as the signature has already been verified. However,
// 171:         # longer term, we should also directly attest to `:all`-tagged bottles.
// 172:         attestations.find do |a|
// 173:           candidate_subjects = a.dig("verificationResult", "statement", "subject")
// 174:           candidate_subjects.any? do |candidate|
// 175:             candidate["name"].start_with? "#{bottle.filename.name}--#{bottle.filename.version}"
// 176:           end
// 177:         end
// 178:       else
// 179:         attestations.find do |a|
// 180:           candidate_subjects = a.dig("verificationResult", "statement", "subject")
// 181:           candidate_subjects.any? { |candidate| candidate["name"] == subject }
// 182:         end
// 183:       end
// 184:
// 185:       raise InvalidAttestationError, "no attestation matches subject: #{subject}" if attestation.blank?
// 186:
// 187:       attestation
// 188:     end
// 189:
// 190:     ATTESTATION_MAX_RETRIES = 5
// 191:
// 192:     # Verifies the given bottle against a cryptographic attestation of build provenance
// 193:     # from homebrew-core's CI, falling back on a "backfill" attestation for older bottles.
// 194:     #
// 195:     # This is a specialization of `check_attestation` for homebrew-core.
// 196:     #
// 197:     # @return [Hash] the JSON-decoded response
// 198:     # @raise [GhAuthNeeded] on any authentication failures
// 199:     # @raise [InvalidAttestationError] on any verification failures
// 200:     #
// 201:     # @api private
// 202:     sig { params(bottle: Bottle).returns(T::Hash[String, T.untyped]) }
// 203:     def self.check_core_attestation(bottle)
// 204:       begin
// 205:         # Ideally, we would also constrain the signing workflow here, but homebrew-core
// 206:         # currently uses multiple signing workflows to produce bottles
// 207:         # (e.g. `dispatch-build-bottle.yml`, `dispatch-rebottle.yml`, etc.).
// 208:         #
// 209:         # We could check each of these (1) explicitly (slow), (2) by generating a pattern
// 210:         # to pass into `--cert-identity-regex` (requires us to build up a Go-style regex),
// 211:         # or (3) by checking the resulting JSON for the expected signing workflow.
// 212:         #
// 213:         # Long term, we should probably either do (3) *or* switch to a single reusable
// 214:         # workflow, which would then be our sole identity. However, GitHub's
// 215:         # attestations currently do not include reusable workflow state by default.
// 216:         attestation = check_attestation bottle, HOMEBREW_CORE_REPO
// 217:         return attestation
// 218:       rescue MissingAttestationError
// 219:         odebug "falling back on backfilled attestation for #{bottle.filename}"
// 220:
// 221:         # Our backfilled attestation is a little unique: the subject is not just the bottle
// 222:         # filename, but also has the bottle's hosted URL hash prepended to it.
// 223:         # This was originally unintentional, but has a virtuous side effect of further
// 224:         # limiting domain separation on the backfilled signatures (by committing them to
// 225:         # their original bottle URLs).
// 226:         url_sha256 = if EnvConfig.bottle_domain_custom?
// 227:           # If our bottle is coming from a mirror, we need to recompute the expected
// 228:           # non-mirror URL to make the hash match.
// 229:           checksum = bottle.resource.checksum
// 230:           odie "#{bottle.resource.name} checksum is nil" if checksum.nil?
// 231:           path, = Utils::Bottles.path_resolved_basename HOMEBREW_BOTTLE_DEFAULT_DOMAIN, bottle.name,
// 232:                                                         checksum, bottle.filename
// 233:           url = "#{HOMEBREW_BOTTLE_DEFAULT_DOMAIN}/#{path}"
// 234:
// 235:           Digest::SHA256.hexdigest(url)
// 236:         else
// 237:           Digest::SHA256.hexdigest(bottle.url)
// 238:         end
// 239:         subject = "#{url_sha256}--#{bottle.filename}"
// 240:
// 241:         # We don't pass in a signing workflow for backfill signatures because
// 242:         # some backfilled bottle signatures were signed from the 'backfill'
// 243:         # branch, and others from 'main' of trailofbits/homebrew-brew-verify
// 244:         # so the signing workflow is slightly different which causes some bottles to incorrectly
// 245:         # fail when checking their attestation. This shouldn't meaningfully affect security
// 246:         # because if somehow someone could generate false backfill attestations
// 247:         # from a different workflow we will still catch it because the
// 248:         # attestation would have been generated after our cutoff date.
// 249:         backfill_attestation = check_attestation bottle, BACKFILL_REPO, nil, subject
// 250:         timestamp = backfill_attestation.dig("verificationResult", "verifiedTimestamps",
// 251:                                              0, "timestamp")
// 252:
// 253:         raise InvalidAttestationError, "backfill attestation is missing verified timestamp" if timestamp.nil?
// 254:
// 255:         if DateTime.parse(timestamp) > BACKFILL_CUTOFF
// 256:           raise InvalidAttestationError, "backfill attestation post-dates cutoff"
// 257:         end
// 258:       end
// 259:
// 260:       backfill_attestation
// 261:     rescue InvalidAttestationError
// 262:       @attestation_retry_count ||= T.let(Hash.new(0), T.nilable(T::Hash[Bottle, Integer]))
// 263:       raise if @attestation_retry_count[bottle] >= ATTESTATION_MAX_RETRIES
// 264:
// 265:       sleep_time = 3 ** @attestation_retry_count[bottle]
// 266:       opoo "Failed to verify attestation. Retrying in #{sleep_time}s..."
// 267:       sleep sleep_time if ENV["HOMEBREW_TESTS"].blank?
// 268:       @attestation_retry_count[bottle] += 1
// 269:       retry
// 270:     end
// 271:   end
// 272: end
