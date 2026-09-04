module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/update-license-data.rb`.

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

pub fn update_license_data_input_boundary(input &UpdateLicenseDataInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::UpdateLicenseData::Input', '', {
		'update_license_data_input_address': u64(voidptr(input)).str()
	})
}

fn update_license_data_input_from_value(value ruby.Value) &UpdateLicenseDataInput {
	address := value.attributes['update_license_data_input_address'] or {
		panic('invalid UpdateLicenseData input')
	}
	return unsafe { &UpdateLicenseDataInput(voidptr(address.u64())) }
}

fn update_license_data_result_value(result UpdateLicenseDataResult) ruby.Value {
	return ruby.map_value({
		'download_latest': ruby.bool_value(result.download_latest)
		'diff_command':    ruby.string_array_value(result.diff_command)
		'stdout':          ruby.string_value(result.stdout)
		'stderr':          ruby.string_value(result.stderr)
		'failed':          ruby.bool_value(result.failed)
	})
}
