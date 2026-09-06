module dev_cmd

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
