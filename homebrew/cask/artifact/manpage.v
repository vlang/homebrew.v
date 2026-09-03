module artifact

import os

// Translated from Homebrew/brew `cask/artifact/manpage.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ManpageArtifact {
pub:
	cask_token  string
	staged_path string
	manpagedir  string
	source      string
	source_name string
	section     string
	symlinked   SymlinkedArtifact
}

fn manpage_section(source string) ?string {
	name := if source.ends_with('.gz') { source[..source.len - 3] } else { source }
	section := name.all_after_last('.')
	if section in ['1', '2', '3', '4', '5', '6', '7', '8', 'n', 'l'] {
		return section
	}
	return none
}

pub fn resolve_manpage_target(manpagedir string, section string, target string) string {
	return os.join_path(manpagedir, 'man${section}', target)
}

pub fn new_manpage_artifact(cask_token string, staged_path string, manpagedir string,
	source string, section string) ManpageArtifact {
	source_path := if os.is_abs_path(source) { source } else { os.join_path(staged_path, source) }
	source_name := os.file_name(source)
	target := resolve_manpage_target(manpagedir, section, source_name)
	return ManpageArtifact{
		cask_token: cask_token
		staged_path: staged_path
		manpagedir: manpagedir
		source: source_path
		source_name: source_name
		section: section
		symlinked: SymlinkedArtifact{
			source: source_path
			target: target
			english_name: 'Manpage'
			printable_target: target
		}
	}
}

pub fn manpage_from_args(cask_token string, staged_path string, manpagedir string,
	source string) !ManpageArtifact {
	section := manpage_section(source) or {
		return error("'${source}' is not a valid man page name")
	}
	return new_manpage_artifact(cask_token, staged_path, manpagedir, source, section)
}

pub fn install_manpage(artifact ManpageArtifact) !SymlinkedOperationResult {
	result := install_symlinked_artifact(artifact.symlinked, SymlinkedInstallOptions{})
	if !result.success {
		return error(result.error)
	}
	return result
}

// Ruby attr_reader `attr_reader :section` at line 11.
pub fn ruby_manpage_l11_d1_section(artifact ManpageArtifact) string {
	return artifact.section
}

// Ruby method `self.from_args(cask, source, _target_hash = nil)` at line 20.
pub fn ruby_manpage_l20_d2_self_from_args(cask_token string, staged_path string,
	manpagedir string, source string) !ManpageArtifact {
	return manpage_from_args(cask_token, staged_path, manpagedir, source)
}

// Ruby method `initialize(cask, source, section)` at line 29.
pub fn ruby_manpage_l29_d3_initialize(cask_token string, staged_path string,
	manpagedir string, source string, section string) ManpageArtifact {
	return new_manpage_artifact(cask_token, staged_path, manpagedir, source, section)
}

// Ruby method `resolve_target(target, base_dir: nil)` at line 36.
pub fn ruby_manpage_l36_d4_resolve_target(artifact ManpageArtifact, target string) string {
	return resolve_manpage_target(artifact.manpagedir, artifact.section, target)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/symlinked"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `manpage` stanza.
// 9:     class Manpage < Symlinked
// 10:       sig { returns(String) }
// 11:       attr_reader :section
// 12:
// 13:       sig {
// 14:         override.params(
// 15:           cask:         Cask,
// 16:           source:       T.any(String, Pathname),
// 17:           _target_hash: T.anything,
// 18:         ).returns(T.attached_class)
// 19:       }
// 20:       def self.from_args(cask, source, _target_hash = nil)
// 21:         section = source.to_s[/\.([1-8]|n|l)(?:\.gz)?$/, 1]
// 22:
// 23:         raise CaskInvalidError, "'#{source}' is not a valid man page name" unless section
// 24:
// 25:         new(cask, source, section)
// 26:       end
// 27:
// 28:       sig { params(cask: Cask, source: T.any(String, Pathname), section: String).void }
// 29:       def initialize(cask, source, section)
// 30:         @section = section
// 31:
// 32:         super(cask, source)
// 33:       end
// 34:
// 35:       sig { override.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 36:       def resolve_target(target, base_dir: nil)
// 37:         config.manpagedir.join("man#{section}", target)
// 38:       end
// 39:     end
// 40:   end
// 41: end
