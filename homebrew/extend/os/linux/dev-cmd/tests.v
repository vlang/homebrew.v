module dev_cmd

import homebrew.dev_tests

// Translated from Homebrew/brew `extend/os/linux/dev-cmd/tests.rb`.
pub struct LinuxDevTestsEnvironment {
pub:
	sandbox_linux     bool
	sandbox_available bool
	github_actions    bool
	failure_reason    string = 'The Linux sandbox is unavailable.'
}

pub fn linux_dev_tests_check_test_environment(environment LinuxDevTestsEnvironment) !bool {
	return dev_tests.check_linux_environment(dev_tests.LinuxEnvironment{
		sandbox_linux: environment.sandbox_linux
		sandbox_available: environment.sandbox_available
		github_actions: environment.github_actions
		failure_reason: environment.failure_reason
	})
}

pub fn linux_dev_tests_non_macos_bundle_args(bundle_args []string, ci bool,
	online bool) []string {
	mut result := bundle_args.clone()
	if ci {
		result << ['--tag', '~needs_homebrew_core']
	}
	if !online {
		result << ['--tag', '~needs_svnadmin', '--tag', '~needs_svn']
	}
	result << ['--tag', '~needs_macos', '--tag', '~cask']
	return result
}

pub fn linux_dev_tests_non_macos_files(files []string) []string {
	return files.filter(!(it.starts_with('test/os/mac/') || it == 'test/os/mac_spec.rb' || it.starts_with('test/cask/') || it == 'test/cask_spec.rb'))
}
