module artifact

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/cask/artifact/relocated.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `add_altname_metadata(file, altname, command:)` at line 14.
pub fn ruby_relocated_l14_d1_add_altname_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Cask
// 7:       module Artifact
// 8:         module Relocated
// 9:           extend T::Helpers
// 10:
// 11:           requires_ancestor { ::Cask::Artifact::Relocated }
// 12:
// 13:           sig { params(file: ::Pathname, altname: ::Pathname, command: T.class_of(SystemCommand)).returns(T.nilable(SystemCommand::Result)) }
// 14:           def add_altname_metadata(file, altname, command:)
// 15:             # no-op on Linux: /usr/bin/xattr for setting extended attributes is not available there.
// 16:           end
// 17:         end
// 18:       end
// 19:     end
// 20:   end
// 21: end
// 22:
// 23: Cask::Artifact::Relocated.prepend(OS::Linux::Cask::Artifact::Relocated)
