module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/generated_script.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.from_args(cask, path, options = nil)` at line 17.
pub fn ruby_generated_script_l17_d1_self_from_args(cask_token string, staged_path string,
	path string, content string) !GeneratedScriptArtifact {
	return new_generated_script(cask_token, staged_path, path, content)
}

// Ruby method `initialize(cask, path, content:)` at line 24.
pub fn ruby_generated_script_l24_d2_initialize(cask_token string, staged_path string,
	path string, content string) !GeneratedScriptArtifact {
	return new_generated_script(cask_token, staged_path, path, content)
}

// Ruby method `install_phase(**_options)` at line 39.
pub fn ruby_generated_script_l39_d3_install_phase(artifact GeneratedScriptArtifact) ! {
	install_generated_script(artifact)!
}

// Ruby method `to_args` at line 54.
pub fn ruby_generated_script_l54_d4_to_args(artifact GeneratedScriptArtifact) ruby.Value {
	return generated_script_to_args(artifact)
}

// Ruby method `summarize = @path_string` at line 59.
pub fn ruby_generated_script_l59_d5_summarize(artifact GeneratedScriptArtifact) string {
	return artifact.path_string
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_artifact"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `generated_script` stanza.
// 9:     class GeneratedScript < AbstractArtifact
// 10:       sig {
// 11:         params(
// 12:           cask:    Cask,
// 13:           path:    T.any(String, Pathname),
// 14:           options: T.untyped,
// 15:         ).returns(T.attached_class)
// 16:       }
// 17:       def self.from_args(cask, path, options = nil)
// 18:         options ||= {}
// 19:         options.assert_valid_keys(:content)
// 20:         new(cask, path, **options)
// 21:       end
// 22:
// 23:       sig { params(cask: Cask, path: T.any(String, Pathname), content: String).void }
// 24:       def initialize(cask, path, content:)
// 25:         raise CaskInvalidError.new(cask, "'generated_script' requires content") if content.blank?
// 26:
// 27:         super(cask)
// 28:         path = Pathname(path)
// 29:         if path.absolute? || path.each_filename.any?("..")
// 30:           raise CaskInvalidError.new(cask, "'generated_script' requires a path within the staged cask")
// 31:         end
// 32:
// 33:         @path = T.let(cask.staged_path/path, Pathname)
// 34:         @path_string = T.let(path.to_s, String)
// 35:         @content = content
// 36:       end
// 37:
// 38:       sig { params(_options: T.anything).void }
// 39:       def install_phase(**_options)
// 40:         @path.ascend do |path|
// 41:           break if path == cask.staged_path
// 42:
// 43:           raise CaskInvalidError.new(cask, "'generated_script' path contains a symlink") if path.symlink?
// 44:         end
// 45:
// 46:         @path.dirname.mkpath
// 47:         File.open(@path, File::WRONLY | File::CREAT | File::TRUNC | File::NOFOLLOW) do |file|
// 48:           file.write(@content)
// 49:           file.chmod(0755)
// 50:         end
// 51:       end
// 52:
// 53:       sig { override.returns(T::Array[T.anything]) }
// 54:       def to_args
// 55:         [@path_string, { content: @content }]
// 56:       end
// 57:
// 58:       sig { override.returns(String) }
// 59:       def summarize = @path_string
// 60:     end
// 61:   end
// 62: end
