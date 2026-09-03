module artifact

import brew_runtime
import os

// Translated from Homebrew/brew `cask/artifact/artifact.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn generic_artifact_value(artifact GenericArtifact) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Artifact::Artifact', artifact.source, {
		'cask_token': artifact.cask_token
		'source':     artifact.source
		'target':     artifact.target
	})
}

// Ruby method `self.english_name` at line 11.
pub fn ruby_artifact_l11_d1_self_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('Generic Artifact')
}

// Ruby method `self.from_args(cask, source, options = nil)` at line 22.
pub fn ruby_artifact_l22_d2_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'Artifact.from_args requires cask and source')
	}
	mut options := map[string]string{}
	if args.len > 2 && args[2].type_name == 'Hash' {
		for key, value in args[2].map_data {
			options[key] = value.as_string()
		}
	}
	artifact := new_generic_artifact(args[0].as_string(), args[1].as_string(), options) or {
		return brew_runtime.object_value('CaskInvalidError', err.msg())
	}
	return generic_artifact_value(artifact)
}

// Ruby method `resolve_target(target, base_dir: nil)` at line 33.
pub fn ruby_artifact_l33_d3_resolve_target(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'Artifact#resolve_target requires a target')
	}
	base_dir := if args.len > 1 && args[1].type_name != 'NilClass' {
		?string(args[1].as_string())
	} else {
		none
	}
	return brew_runtime.string_value(resolve_artifact_target(args[0].as_string(), base_dir))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Generic artifact corresponding to the `artifact` stanza.
// 9:     class Artifact < Moved
// 10:       sig { override.returns(String) }
// 11:       def self.english_name
// 12:         "Generic Artifact"
// 13:       end
// 14:
// 15:       sig {
// 16:         override.params(
// 17:           cask:    Cask,
// 18:           source:  T.any(String, Pathname),
// 19:           options: T.untyped, # required due to https://github.com/sorbet/sorbet/issues/10114
// 20:         ).returns(T.attached_class)
// 21:       }
// 22:       def self.from_args(cask, source, options = nil)
// 23:         raise CaskInvalidError.new(cask.token, "No source provided for #{english_name}.") if source.blank?
// 24:
// 25:         unless options&.key?(:target)
// 26:           raise CaskInvalidError.new(cask.token, "#{english_name} '#{source}' requires a target.")
// 27:         end
// 28:
// 29:         new(cask, source, **options)
// 30:       end
// 31:
// 32:       sig { override.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 33:       def resolve_target(target, base_dir: nil)
// 34:         super
// 35:       end
// 36:     end
// 37:   end
// 38: end
