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
// The original source is retained below until every stub has a typed V body.

// Ruby method `available?` at line 17.
pub fn ruby_tar_l17_d1_available(args ...ruby.Value) ruby.Value {
	mut client := tar_default_client()
	return ruby.bool_value(tar_client_available(mut client))
}

// Ruby method `executable` at line 22.
pub fn ruby_tar_l22_d2_executable(args ...ruby.Value) ruby.Value {
	mut client := tar_default_client()
	if executable := tar_client_executable(mut client) {
		return ruby.object_value('Pathname', executable)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `validate_file(path)` at line 31.
pub fn ruby_tar_l31_d3_validate_file(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Utils::Tar.validate_file requires a path')
	}
	mut client := tar_default_client()
	tar_validate_file(mut client, args[0].as_string()) or {
		return ruby.object_value('SystemExit', err.msg())
	}
	return ruby.object_value('NilClass', 'nil')
}

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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "utils/output"
// 6:
// 7: module Utils
// 8:   # Helper functions for interacting with tar files.
// 9:   module Tar
// 10:     class << self
// 11:       include SystemCommand::Mixin
// 12:       include Utils::Output::Mixin
// 13:
// 14:       TAR_FILE_EXTENSIONS = %w[.tar .tb2 .tbz .tbz2 .tgz .tlz .txz .tZ].freeze
// 15:
// 16:       sig { returns(T::Boolean) }
// 17:       def available?
// 18:         !!executable
// 19:       end
// 20:
// 21:       sig { returns(T.nilable(Pathname)) }
// 22:       def executable
// 23:         return @executable if defined?(@executable)
// 24:
// 25:         gnu_tar_gtar_path = HOMEBREW_PREFIX/"opt/gnu-tar/bin/gtar"
// 26:         gnu_tar_gtar = gnu_tar_gtar_path if gnu_tar_gtar_path.executable?
// 27:         @executable = T.let(which("gtar") || gnu_tar_gtar || which("tar"), T.nilable(Pathname))
// 28:       end
// 29:
// 30:       sig { params(path: T.any(Pathname, String)).void }
// 31:       def validate_file(path)
// 32:         return unless available?
// 33:
// 34:         path = Pathname.new(path)
// 35:         return unless TAR_FILE_EXTENSIONS.include? path.extname
// 36:
// 37:         stdout, _, status = system_command(T.must(executable), args:         ["--list", "--file", path],
// 38:                                                                print_stderr: false).to_a
// 39:         odie "#{path} is not a valid tar file!" if !status.success? || stdout.blank?
// 40:       end
// 41:     end
// 42:   end
// 43: end
