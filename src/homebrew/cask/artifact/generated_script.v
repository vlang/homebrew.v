module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/generated_script.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.from_args(cask, path, options = nil)` at line 17.
pub fn ruby_generated_script_l17_d1_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_args', ...args)
}

// Ruby method `initialize(cask, path, content:)` at line 24.
pub fn ruby_generated_script_l24_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `install_phase(**_options)` at line 39.
pub fn ruby_generated_script_l39_d3_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `to_args` at line 54.
pub fn ruby_generated_script_l54_d4_to_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_args', ...args)
}

// Ruby method `summarize = @path_string` at line 59.
pub fn ruby_generated_script_l59_d5_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize', ...args)
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
