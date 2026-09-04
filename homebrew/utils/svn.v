module utils

import ruby
import os

// Translated from Homebrew/brew `utils/svn.rb`.

pub struct SvnCommandResult {
pub:
	exit_code int
	stdout    string
	stderr    string
}

pub type SvnCommandRunner = fn ([]string) !SvnCommandResult

pub struct SvnClient {
pub:
	shim   string
	runner SvnCommandRunner = svn_run_command
mut:
	version_loaded  bool
	version_present bool
	version_value   string
}

pub struct SvnCertFlags {
pub:
	args    []string
	warning string
}

pub fn svn_default_client() SvnClient {
	return SvnClient{ shim: svn_default_shim() }
}

pub fn svn_client_with_runner(shim string, runner SvnCommandRunner) SvnClient {
	return SvnClient{ shim: shim, runner: runner }
}

pub fn svn_client_available(mut client SvnClient) bool {
	return svn_client_version(mut client) != none
}

pub fn svn_client_version(mut client SvnClient) ?string {
	if client.version_loaded {
		return if client.version_present { client.version_value } else { none }
	}
	client.version_loaded = true
	result := client.runner([client.shim, '--version']) or { return none }
	if result.exit_code != 0 {
		return none
	}
	client.version_value = svn_parse_version(result.stdout)
	client.version_present = client.version_value != ''
	return if client.version_present { client.version_value } else { none }
}

pub fn svn_client_clear_version_cache(mut client SvnClient) {
	client.version_loaded = false
	client.version_present = false
	client.version_value = ''
}

pub fn svn_client_remote_exists(mut client SvnClient, url string) bool {
	if !svn_client_available(mut client) {
		return true
	}
	mut command := ['svn', 'ls', url, '--depth', 'empty']
	result := client.runner(command) or { return false }
	if !result.stderr.contains('certificate verification failed') {
		return result.exit_code == 0
	}
	flags := svn_invalid_cert_flags(svn_client_version(mut client) or { '' })
	eprintln('Warning: ${flags.warning}')
	command << flags.args
	retry := client.runner(command) or { return false }
	return retry.exit_code == 0
}

pub fn svn_invalid_cert_flags(version string) SvnCertFlags {
	mut args := ['--non-interactive', '--trust-server-cert']
	if svn_compare_versions(version, '1.9') >= 0 {
		args << '--trust-server-cert-failures=expired,not-yet-valid'
	}
	return SvnCertFlags{
		args: args
		warning: 'Ignoring Subversion certificate errors!'
	}
}

pub fn svn_parse_version(output string) string {
	marker := 'svn, version '
	start := output.index(marker) or { return '' }
	mut version := ''
	for character in output[start + marker.len..] {
		if (character >= `0` && character <= `9`) || character == `.` {
			version += character.ascii_str()
		} else {
			break
		}
	}
	return version.trim_string_right('.')
}

fn svn_compare_versions(left string, right string) int {
	left_parts := left.split('.').map(it.int())
	right_parts := right.split('.').map(it.int())
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_value := if index < left_parts.len { left_parts[index] } else { 0 }
		right_value := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_value < right_value {
			return -1
		}
		if left_value > right_value {
			return 1
		}
	}
	return 0
}

fn svn_run_command(command []string) !SvnCommandResult {
	result := ruby.run_captured_command(command, ruby.CapturedCommandOptions{
		environment: ruby.environment()
	})!
	return SvnCommandResult{ exit_code: result.exit_code, stdout: result.stdout, stderr: result.stderr }
}

fn svn_default_shim() string {
	shims := os.getenv('HOMEBREW_SHIMS_PATH')
	if shims != '' {
		return os.join_path(shims, 'shared', 'svn')
	}
	return os.find_abs_path_of_executable('svn') or { 'svn' }
}

fn svn_nil_value() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}
