module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/generated_script.rb`.
pub struct GeneratedScriptArtifact {
pub:
	cask_token  string
	staged_path string
	path        string
	path_string string
	content     string
}

pub fn new_generated_script(cask_token string, staged_path string, path string,
	content string) !GeneratedScriptArtifact {
	if content.trim_space() == '' {
		return error("'generated_script' requires content")
	}
	if os.is_abs_path(path) || path.split('/').contains('..') {
		return error("'generated_script' requires a path within the staged cask")
	}
	return GeneratedScriptArtifact{
		cask_token: cask_token
		staged_path: staged_path
		path: os.join_path(staged_path, path)
		path_string: path
		content: content
	}
}

pub fn install_generated_script(artifact GeneratedScriptArtifact) ! {
	mut path := artifact.path
	for path != artifact.staged_path {
		if os.is_link(path) {
			return error("'generated_script' path contains a symlink")
		}
		parent := os.dir(path)
		if parent == path {
			break
		}
		path = parent
	}
	os.mkdir_all(os.dir(artifact.path))!
	if os.is_link(artifact.path) {
		return error("'generated_script' path contains a symlink")
	}
	os.write_file(artifact.path, artifact.content)!
	os.chmod(artifact.path, 0o755)!
}

pub fn generated_script_to_args(artifact GeneratedScriptArtifact) ruby.Value {
	return ruby.array_value([
		ruby.string_value(artifact.path_string),
		ruby.map_value({
			'content': ruby.string_value(artifact.content)
		}),
	])
}
