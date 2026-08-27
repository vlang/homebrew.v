module cask

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/cask/config.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `defaults` at line 20.
pub fn ruby_config_l20_d1_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('defaults', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/linux"
// 5:
// 6: module OS
// 7:   module Linux
// 8:     module Cask
// 9:       module Config
// 10:         module ClassMethods
// 11:           DEFAULT_DIRS = T.let({
// 12:             vst_plugindir:  "~/.vst",
// 13:             vst3_plugindir: "~/.vst3",
// 14:             fontdir:        "#{ENV.fetch("HOMEBREW_XDG_DATA_HOME", "~/.local/share")}/fonts",
// 15:             appdir:         "~/.config/apps",
// 16:             appimagedir:    "~/Applications",
// 17:           }.freeze, T::Hash[Symbol, String])
// 18:
// 19:           sig { returns(T::Hash[Symbol, T.any(LazyObject, String)]) }
// 20:           def defaults
// 21:             {
// 22:               languages: LazyObject.new { Linux.languages },
// 23:             }.merge(DEFAULT_DIRS).freeze
// 24:           end
// 25:         end
// 26:       end
// 27:     end
// 28:   end
// 29: end
// 30:
// 31: Cask::Config.singleton_class.prepend(OS::Linux::Cask::Config::ClassMethods)
