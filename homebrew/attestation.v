module homebrew

import ruby
import crypto.sha256
import os
import time
import x.json2

// Translated from Homebrew/brew `attestation.rb`.
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

pub type AttestationGhEnsurer = fn (mut runtime AttestationRuntime, name string, reason string, latest bool) !string

pub type AttestationCommandRunner = fn (mut runtime AttestationRuntime, command AttestationCommand) !AttestationCommandResult

pub type AttestationSleeper = fn (mut runtime AttestationRuntime, seconds int) !

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
			ruby.bool_value(false)
		}).as_bool() or { false }
		default_bottle_domain: (values['default_bottle_domain'] or {
			ruby.string_value('https://ghcr.io/v2/homebrew/core')
		}).as_string()
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
