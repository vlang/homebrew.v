module homebrew

// Translated from Homebrew/brew `github_runner.rb`.
pub type GitHubRunnerSpec = LinuxRunnerSpec | MacOSRunnerSpec

pub struct GitHubRunner {
pub:
	platform      string
	arch          string
	spec          GitHubRunnerSpec
	macos_version string
pub mut:
	active bool
}

pub fn new_github_runner(platform string, arch string, spec GitHubRunnerSpec,
	macos_version string) GitHubRunner {
	return GitHubRunner{
		platform: platform
		arch: arch
		spec: spec
		macos_version: macos_version
	}
}

pub fn (runner GitHubRunner) macos() bool {
	return runner.platform == 'macos'
}

pub fn (runner GitHubRunner) linux() bool {
	return runner.platform == 'linux'
}

pub fn (runner GitHubRunner) x86_64() bool {
	return runner.arch == 'x86_64'
}

pub fn (runner GitHubRunner) arm64() bool {
	return runner.arch == 'arm64'
}
