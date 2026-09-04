module helper

import ruby

// Translated from Homebrew/brew `test/support/helper/cask.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `stub_cask_loader(cask, ref = cask.token, call_original: false)` at line 14.
pub fn ruby_cask_l14_d1_stub_cask_loader(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'Cask' {
		panic('stub_cask_loader requires a Cask')
	}
	ref := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_string()
	} else {
		args[0].attribute('token') or { args[0].as_string() }
	}
	call_original := args.len > 2 && (args[2].as_bool() or { false })
	return ruby.Value{
		type_name: 'CaskLoaderStub'
		repr: ref
		map_data: {
			'cask': args[0]
		}
		attributes: {
			'ref':           ref
			'call_original': call_original.str()
			'loader':        'CaskLoader::FromInstanceLoader'
		}
	}
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
