module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/appimage.rb`.
pub struct ExecutableArtifactLinkResult {
pub:
	source             string
	already_executable bool
	chmod_applied      bool
	sudo_required      bool
	command_arguments  []string
}

pub fn resolve_appimage_target(appimagedir string, target string) string {
	return os.join_path(appimagedir, target)
}

// link_executable_artifact performs the post-link executable repair shared by
// AppImage and Binary. Non-writable sources return the exact sudo chmod plan so
// callers can execute it through their SystemCommand boundary.
pub fn link_executable_artifact(source string) !ExecutableArtifactLinkResult {
	if !os.exists(source) {
		return error('artifact source does not exist: ${source}')
	}
	if os.is_executable(source) {
		return ExecutableArtifactLinkResult{
			source: source
			already_executable: true
		}
	}
	if !os.is_writable(source) {
		return ExecutableArtifactLinkResult{
			source: source
			sudo_required: true
			command_arguments: ['+x', source]
		}
	}
	mode := int(os.stat(source)!.get_mode().bitmask())
	os.chmod(source, mode | 0o111)!
	return ExecutableArtifactLinkResult{
		source: source
		chmod_applied: true
		command_arguments: ['+x', source]
	}
}

fn executable_artifact_link_value(result ExecutableArtifactLinkResult) ruby.Value {
	return ruby.Value{
		type_name: 'ExecutableArtifactLinkResult'
		repr: result.source
		attributes: {
			'source':             result.source
			'already_executable': result.already_executable.str()
			'chmod_applied':      result.chmod_applied.str()
			'sudo_required':      result.sudo_required.str()
		}
		map_data: {
			'command_arguments': ruby.string_array_value(result.command_arguments)
		}
	}
}
