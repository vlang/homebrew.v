module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/search.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `ignore_cask?(cask)` at line 9.
pub fn ruby_search_l9_d1_ignore_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignore_cask?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Search
// 7:       module ClassMethods
// 8:         sig { params(cask: ::Cask::Cask).returns(T::Boolean) }
// 9:         def ignore_cask?(cask)
// 10:           !cask.supports_linux?
// 11:         end
// 12:       end
// 13:     end
// 14:   end
// 15: end
// 16:
// 17: Homebrew::Search.singleton_class.prepend(OS::Linux::Search::ClassMethods)
