module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/binary.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `link(force: false, adopt: false, command: SystemCommand, **_options)` at line 18.
pub fn ruby_binary_l18_d1_link(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'Binary#link requires a source')
	}
	result := link_executable_artifact(args[0].as_string()) or {
		return brew_runtime.object_value('CaskError', err.msg())
	}
	return executable_artifact_link_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/symlinked"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `binary` stanza.
// 9:     class Binary < Symlinked
// 10:       sig {
// 11:         override.params(
// 12:           force:    T::Boolean,
// 13:           adopt:    T::Boolean,
// 14:           command:  T.class_of(SystemCommand),
// 15:           _options: T.anything,
// 16:         ).void
// 17:       }
// 18:       def link(force: false, adopt: false, command: SystemCommand, **_options)
// 19:         super
// 20:         return if source.executable?
// 21:
// 22:         if source.writable?
// 23:           FileUtils.chmod "+x", source
// 24:         else
// 25:           command.run!("chmod", args: ["+x", source], sudo: true)
// 26:         end
// 27:       end
// 28:     end
// 29:   end
// 30: end
