module artifact

import ruby

// Translated from Homebrew/brew `cask/artifact/keyboard_layout.rb`.
fn run_refresh_command(command ArtifactCommand, runner ArtifactCommandRunner,
	mut result MovedOperationResult) {
	result.commands << command
	succeeded := runner(command) or {
		result.success = false
		result.error = err.msg()
		return
	}
	if !succeeded {
		result.success = false
		result.error = 'Command failed: ${command.executable}'
	}
}

pub fn delete_keyboard_layout_cache_with_command(runner ArtifactCommandRunner,
	mut result MovedOperationResult) {
	run_refresh_command(ArtifactCommand{
		executable: '/bin/rm'
		args: ['-f', '--', '/System/Library/Caches/com.apple.IntlDataCache.le*']
		sudo: true
		sudo_as_root: true
	}, runner, mut result)
}

pub fn install_keyboard_layout_with_command(artifact MovedArtifact,
	options MovedInstallOptions, runner ArtifactCommandRunner) MovedOperationResult {
	mut result := move_artifact_with_command(artifact, options, runner)
	if result.success {
		delete_keyboard_layout_cache_with_command(runner, mut result)
	}
	return result
}

pub fn install_keyboard_layout(artifact MovedArtifact,
	options MovedInstallOptions) MovedOperationResult {
	return install_keyboard_layout_with_command(artifact, options, default_artifact_command_runner)
}

pub fn uninstall_keyboard_layout_with_command(artifact MovedArtifact,
	options MovedUninstallOptions, runner ArtifactCommandRunner) MovedOperationResult {
	mut result := move_back_artifact_with_command(artifact, options, runner)
	if result.success {
		delete_keyboard_layout_cache_with_command(runner, mut result)
	}
	return result
}

pub fn uninstall_keyboard_layout(artifact MovedArtifact,
	options MovedUninstallOptions) MovedOperationResult {
	return uninstall_keyboard_layout_with_command(artifact, options, default_artifact_command_runner)
}
