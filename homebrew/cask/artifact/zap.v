module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/zap.rb`.
pub struct ZapArtifact {
pub:
	rmdir []string
}

pub struct ZapResult {
pub:
	removed []string
	skipped []string
}

fn zap_recursive_rmdir(path string, mut removed []string) !bool {
	if !os.is_dir(path) {
		return false
	}
	children := os.ls(path)!
	for child in children {
		child_path := os.join_path(path, child)
		if child != '.DS_Store' && !os.is_dir(child_path) {
			return false
		}
	}
	for child in children {
		child_path := os.join_path(path, child)
		if child == '.DS_Store' {
			os.rm(child_path)!
			removed << child_path
			continue
		}
		if !zap_recursive_rmdir(child_path, mut removed)! {
			return false
		}
	}
	os.rmdir(path)!
	removed << path
	return true
}

pub fn zap_phase(artifact ZapArtifact) !ZapResult {
	mut removed := []string{}
	mut skipped := []string{}
	for directory in artifact.rmdir {
		if !zap_recursive_rmdir(directory, mut removed)! {
			skipped << directory
		}
	}
	return ZapResult{
		removed: removed
		skipped: skipped
	}
}

pub fn zap_artifact_to_value(artifact ZapArtifact) ruby.Value {
	return ruby.map_value({
		'rmdir': ruby.string_array_value(artifact.rmdir)
	})
}

fn zap_artifact_from_value(value ruby.Value) !ZapArtifact {
	values := value.as_map()!
	rmdir_value := values['rmdir'] or { ruby.string_array_value([]string{}) }
	return ZapArtifact{
		rmdir: rmdir_value.as_string_array()!
	}
}

pub fn zap_result_to_value(result ZapResult) ruby.Value {
	return ruby.map_value({
		'removed': ruby.string_array_value(result.removed)
		'skipped': ruby.string_array_value(result.skipped)
	})
}
