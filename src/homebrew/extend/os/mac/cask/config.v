module cask

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/cask/config.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `defaults` at line 12.
pub fn ruby_config_l12_d1_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('defaults', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Cask
// 9:       module Config
// 10:         module ClassMethods
// 11:           T::Sig::WithoutRuntime.sig { returns(::Cask::Config::ConfigHash) }
// 12:           def defaults
// 13:             {
// 14:               languages: LazyObject.new { Mac.languages },
// 15:             }.merge(::Cask::Config::DEFAULT_DIRS).freeze
// 16:           end
// 17:         end
// 18:       end
// 19:     end
// 20:   end
// 21: end
// 22:
// 23: Cask::Config.singleton_class.prepend(OS::Mac::Cask::Config::ClassMethods)
