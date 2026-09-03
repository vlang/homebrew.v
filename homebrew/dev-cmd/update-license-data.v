module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/update-license-data.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct UpdateLicenseDataOptions {
pub:
	repository   string
	data_path    string
	diff_success bool
}

pub struct UpdateLicenseDataResult {
pub:
	download_latest bool
	diff_command    []string
	stdout          string
	stderr          string
	failed          bool
}

pub fn run_update_license_data(options UpdateLicenseDataOptions) UpdateLicenseDataResult {
	command := ['git', '-C', options.repository, 'diff', '--exit-code', options.data_path]
	if options.diff_success {
		return UpdateLicenseDataResult{
			download_latest: true
			diff_command: command
			stderr: 'No changes to SPDX license data.\n'
			failed: true
		}
	}
	return UpdateLicenseDataResult{
		download_latest: true
		diff_command: command
		stdout: 'SPDX license data updated.\n'
	}
}

@[heap]
pub struct UpdateLicenseDataInput {
pub:
	options UpdateLicenseDataOptions
}

pub fn update_license_data_input_boundary(input &UpdateLicenseDataInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::UpdateLicenseData::Input', '', {
		'update_license_data_input_address': u64(voidptr(input)).str()
	})
}

fn update_license_data_input_from_value(value brew_runtime.Value) &UpdateLicenseDataInput {
	address := value.attributes['update_license_data_input_address'] or {
		panic('invalid UpdateLicenseData input')
	}
	return unsafe { &UpdateLicenseDataInput(voidptr(address.u64())) }
}

fn update_license_data_result_value(result UpdateLicenseDataResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'download_latest': brew_runtime.bool_value(result.download_latest)
		'diff_command': brew_runtime.string_array_value(result.diff_command)
		'stdout': brew_runtime.string_value(result.stdout)
		'stderr': brew_runtime.string_value(result.stderr)
		'failed': brew_runtime.bool_value(result.failed)
	})
}

// Ruby method `run` at line 24.
pub fn ruby_update_license_data_l24_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return update_license_data_result_value(run_update_license_data(update_license_data_input_from_value(args[0]).options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "utils/spdx"
// 6: require "system_command"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class UpdateLicenseData < AbstractCommand
// 11:       include SystemCommand::Mixin
// 12:
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Update SPDX license data in the Homebrew repository.
// 16:         EOS
// 17:
// 18:         named_args :none
// 19:
// 20:         hide_from_man_page!
// 21:       end
// 22:
// 23:       sig { override.void }
// 24:       def run
// 25:         SPDX.download_latest_license_data!
// 26:         diff = system_command "git", args: [
// 27:           "-C", HOMEBREW_REPOSITORY, "diff", "--exit-code", SPDX::DATA_PATH
// 28:         ]
// 29:         if diff.status.success?
// 30:           ofail "No changes to SPDX license data."
// 31:         else
// 32:           puts "SPDX license data updated."
// 33:         end
// 34:       end
// 35:     end
// 36:   end
// 37: end
