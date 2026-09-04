module dev_cmd

// Translated from Homebrew/brew `extend/os/mac/dev-cmd/tests.rb`.
pub fn mac_dev_tests_os_bundle_args(bundle_args []string) []string {
	mut result := bundle_args.clone()
	result << ['--tag', '~needs_linux', '--tag', '~needs_systemd']
	return result
}

pub fn mac_dev_tests_os_files(files []string) []string {
	return files.filter(!(it.starts_with('test/os/linux/') || it == 'test/os/linux_spec.rb'))
}
