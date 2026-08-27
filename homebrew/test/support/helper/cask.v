module helper

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/cask.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `stub_cask_loader(cask, ref = cask.token, call_original: false)` at line 14.
pub fn ruby_cask_l14_d1_stub_cask_loader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stub_cask_loader', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/cask_loader"
// 5:
// 6: module Test
// 7:   module Helper
// 8:     module Cask
// 9:       extend T::Helpers
// 10:
// 11:       requires_ancestor { RSpec::Mocks::ExampleMethods }
// 12:
// 13:       sig { params(cask: ::Cask::Cask, ref: T.nilable(String), call_original: T::Boolean).void }
// 14:       def stub_cask_loader(cask, ref = cask.token, call_original: false)
// 15:         allow(::Cask::CaskLoader).to receive(:for).and_call_original if call_original
// 16:
// 17:         loader = ::Cask::CaskLoader::FromInstanceLoader.new(cask)
// 18:         allow(::Cask::CaskLoader).to receive(:for).with(ref, any_args).and_return(loader)
// 19:       end
// 20:     end
// 21:   end
// 22: end
