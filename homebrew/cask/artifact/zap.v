module artifact

import brew_runtime
import os

// Translated from Homebrew/brew `cask/artifact/zap.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn zap_artifact_to_value(artifact ZapArtifact) brew_runtime.Value {
	return brew_runtime.map_value({
		'rmdir': brew_runtime.string_array_value(artifact.rmdir)
	})
}

fn zap_artifact_from_value(value brew_runtime.Value) !ZapArtifact {
	values := value.as_map()!
	rmdir_value := values['rmdir'] or { brew_runtime.string_array_value([]string{}) }
	return ZapArtifact{
		rmdir: rmdir_value.as_string_array()!
	}
}

pub fn zap_result_to_value(result ZapResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'removed': brew_runtime.string_array_value(result.removed)
		'skipped': brew_runtime.string_array_value(result.skipped)
	})
}

// Ruby method `zap_phase(**options)` at line 11.
pub fn ruby_zap_l11_d1_zap_phase(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'Zap artifact is required')
	}
	artifact := zap_artifact_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := zap_phase(artifact) or { return brew_runtime.object_value('CaskError', err.msg()) }
	return zap_result_to_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_uninstall"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `zap` stanza.
// 9:     class Zap < AbstractUninstall
// 10:       sig { params(options: T.anything).void }
// 11:       def zap_phase(**options)
// 12:         dispatch_uninstall_directives(**options)
// 13:       end
// 14:     end
// 15:   end
// 16: end
