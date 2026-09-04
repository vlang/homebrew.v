module utils

import ruby
import os

const tar_file_extensions = ['.tar', '.tb2', '.tbz', '.tbz2', '.tgz', '.tlz', '.txz', '.tZ']

pub struct TarExecutableCandidates {
pub:
	path_gtar               string
	gnu_tar_gtar            string
	gnu_tar_gtar_executable bool
	path_tar                string
}

pub struct TarCommandResult {
pub:
	stdout    string
	stderr    string
	exit_code int
}

pub type TarCommandRunner = fn (string, []string) TarCommandResult

pub struct TarClient {
pub mut:
	candidates TarExecutableCandidates
	runner     TarCommandRunner = tar_run_command
mut:
	executable_loaded  bool
	executable_present bool
	executable_path    string
}

// Translated from Homebrew/brew `utils/tar.rb`.

pub fn tar_executable(candidates TarExecutableCandidates) ?string {
	if candidates.path_gtar != '' {
		return candidates.path_gtar
	}
	if candidates.gnu_tar_gtar_executable && candidates.gnu_tar_gtar != '' {
		return candidates.gnu_tar_gtar
	}
	if candidates.path_tar != '' {
		return candidates.path_tar
	}
	return none
}

pub fn tar_default_candidates() TarExecutableCandidates {
	prefix := ruby.environment_value('HOMEBREW_PREFIX').trim_right('/')
	gnu_tar_gtar := if prefix == '' { '' } else { os.join_path(prefix, 'opt/gnu-tar/bin/gtar') }
	return TarExecutableCandidates{
		path_gtar: ruby.find_executable('gtar') or { '' }
		gnu_tar_gtar: gnu_tar_gtar
		gnu_tar_gtar_executable: gnu_tar_gtar != '' && os.is_file(gnu_tar_gtar) && os.is_executable(gnu_tar_gtar)
		path_tar: ruby.find_executable('tar') or { '' }
	}
}

pub fn tar_default_client() TarClient {
	return TarClient{
		candidates: tar_default_candidates()
	}
}

pub fn tar_client_with(candidates TarExecutableCandidates, runner TarCommandRunner) TarClient {
	return TarClient{
		candidates: candidates
		runner: runner
	}
}

pub fn tar_client_executable(mut client TarClient) ?string {
	if client.executable_loaded {
		return if client.executable_present { client.executable_path } else { none }
	}
	client.executable_loaded = true
	client.executable_path = tar_executable(client.candidates) or { '' }
	client.executable_present = client.executable_path != ''
	return if client.executable_present { client.executable_path } else { none }
}

pub fn tar_client_available(mut client TarClient) bool {
	return tar_client_executable(mut client) != none
}

pub fn tar_client_clear_executable_cache(mut client TarClient) {
	client.executable_loaded = false
	client.executable_present = false
	client.executable_path = ''
}

pub fn tar_file_extension(path string) string {
	name := os.file_name(path)
	index := name.last_index('.') or { return '' }
	if index == 0 {
		return ''
	}
	return name[index..]
}

pub fn tar_validate_file(mut client TarClient, path string) ! {
	executable := tar_client_executable(mut client) or { return }
	if tar_file_extension(path) !in tar_file_extensions {
		return
	}
	result := client.runner(executable, ['--list', '--file', path])
	if result.exit_code != 0 || result.stdout.trim_space() == '' {
		return error('${path} is not a valid tar file!')
	}
}

fn tar_run_command(executable string, arguments []string) TarCommandResult {
	result := ruby.run_command(executable, arguments)
	return TarCommandResult{
		stdout: result.output
		exit_code: result.exit_code
	}
}
