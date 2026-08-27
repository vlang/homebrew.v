module cask

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/cask/caskroom.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `expected_caskroom_group` at line 14.
pub fn ruby_caskroom_l14_d1_expected_caskroom_group(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_caskroom_group', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Cask
// 7:       module Caskroom
// 8:         module ClassMethods
// 9:           # Unlike macOS (which uses the `admin` group), Homebrew on Linux is run
// 10:           # in a variety of distributions, so use the current user's primary group
// 11:           # as the group of the `Caskroom` directory.
// 12:           # This avoids a `sudo` prompt to `chgrp` the directory after creation.
// 13:           sig { returns(String) }
// 14:           def expected_caskroom_group
// 15:             @expected_caskroom_group ||= T.let(
// 16:               begin
// 17:                 Etc.getgrgid(Process.egid)&.name || "root"
// 18:               rescue ArgumentError
// 19:                 "root"
// 20:               end,
// 21:               T.nilable(String),
// 22:             )
// 23:           end
// 24:         end
// 25:       end
// 26:     end
// 27:   end
// 28: end
// 29:
// 30: Cask::Caskroom.singleton_class.prepend(OS::Linux::Cask::Caskroom::ClassMethods)
