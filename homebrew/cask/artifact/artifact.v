module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/artifact.rb`.
pub struct GenericArtifact {
pub:
	cask_token string
	source     string
	target     string
}

pub fn new_generic_artifact(cask_token string, source string, options map[string]string) !GenericArtifact {
	if source.trim_space() == '' {
		return error("Cask '${cask_token}': No source provided for Generic Artifact.")
	}
	if 'target' !in options {
		return error("Cask '${cask_token}': Generic Artifact '${source}' requires a target.")
	}
	return GenericArtifact{
		cask_token: cask_token
		source: source
		target: options['target']
	}
}

pub fn resolve_artifact_target(target string, base_dir ?string) string {
	if os.is_abs_path(target) {
		return target
	}
	if target == '~' {
		return os.home_dir()
	}
	if target.starts_with('~/') {
		return os.join_path(os.home_dir(), target[2..])
	}
	if base := base_dir {
		return os.join_path(base, target)
	}
	return target
}

pub fn generic_artifact_value(artifact GenericArtifact) ruby.Value {
	return ruby.structured_value('Cask::Artifact::Artifact', artifact.source, {
		'cask_token': artifact.cask_token
		'source':     artifact.source
		'target':     artifact.target
	})
}
