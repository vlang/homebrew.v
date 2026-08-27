module artifact

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/cask/artifact/symlinked.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `create_filesystem_link(command)` at line 16.
pub fn ruby_symlinked_l16_d1_create_filesystem_link(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_filesystem_link', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/macos"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Cask
// 9:       module Artifact
// 10:         module Symlinked
// 11:           extend T::Helpers
// 12:
// 13:           requires_ancestor { ::Cask::Artifact::Symlinked }
// 14:
// 15:           sig { params(command: T.class_of(SystemCommand)).void }
// 16:           def create_filesystem_link(command)
// 17:             ::Cask::Utils.gain_permissions_mkpath(target.dirname, command:)
// 18:
// 19:             command.run! "/bin/ln", args: ["-h", "-f", "-s", "--", source, target],
// 20:                                     sudo: !target.dirname.writable?
// 21:
// 22:             add_altname_metadata(source, target.basename, command:)
// 23:           end
// 24:         end
// 25:       end
// 26:     end
// 27:   end
// 28: end
// 29:
// 30: Cask::Artifact::Symlinked.prepend(OS::Mac::Cask::Artifact::Symlinked)
