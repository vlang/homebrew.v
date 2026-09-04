module artifact

import ruby

// Translated from Homebrew/brew `cask/artifact/qlplugin.rb`.
pub fn reload_quicklook_with_command(runner ArtifactCommandRunner,
	mut result MovedOperationResult) {
	run_refresh_command(ArtifactCommand{
		executable: '/usr/bin/qlmanage'
		args: ['-r']
	}, runner, mut result)
}

pub fn install_qlplugin_with_command(artifact MovedArtifact, options MovedInstallOptions,
	runner ArtifactCommandRunner) MovedOperationResult {
	mut result := move_artifact_with_command(artifact, options, runner)
	if result.success {
		reload_quicklook_with_command(runner, mut result)
	}
	return result
}

pub fn install_qlplugin(artifact MovedArtifact, options MovedInstallOptions) MovedOperationResult {
	return install_qlplugin_with_command(artifact, options, default_artifact_command_runner)
}

pub fn uninstall_qlplugin_with_command(artifact MovedArtifact, options MovedUninstallOptions,
	runner ArtifactCommandRunner) MovedOperationResult {
	mut result := move_back_artifact_with_command(artifact, options, runner)
	if result.success {
		reload_quicklook_with_command(runner, mut result)
	}
	return result
}

pub fn uninstall_qlplugin(artifact MovedArtifact,
	options MovedUninstallOptions) MovedOperationResult {
	return uninstall_qlplugin_with_command(artifact, options, default_artifact_command_runner)
}
