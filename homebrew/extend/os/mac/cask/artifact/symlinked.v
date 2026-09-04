module artifact

import ruby
import homebrew.cask.artifact as base_artifact
import os

pub struct MacSymlinkCreationResult {
pub:
	command  base_artifact.ArtifactCommand
	altname  string
	metadata bool
}

pub fn mac_create_filesystem_link(source string, target string, target_parent_writable bool,
	runner base_artifact.ArtifactCommandRunner) !MacSymlinkCreationResult {
	os.mkdir_all(os.dir(target))!
	command := base_artifact.ArtifactCommand{
		executable: '/bin/ln'
		args: ['-h', '-f', '-s', '--', source, target]
		sudo: !target_parent_writable
	}
	if !runner(command)! {
		return error('failed to create filesystem link ${target}')
	}
	return MacSymlinkCreationResult{
		command: command
		altname: os.file_name(target)
		metadata: true
	}
}

fn mac_symlink_fixture_runner(command base_artifact.ArtifactCommand) !bool {
	return command.executable == '/bin/ln' && command.args.len == 6
}

// Translated from Homebrew/brew `extend/os/mac/cask/artifact/symlinked.rb`.
