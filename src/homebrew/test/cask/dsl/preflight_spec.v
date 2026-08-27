module dsl

import brew_runtime

// Translated from Homebrew/brew `test/cask/dsl/preflight_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("basic-cask")) }` at line 8.
pub fn ruby_preflight_spec_l8_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:fake_system_command) { class_double(SystemCommand) }` at line 9.
pub fn ruby_preflight_spec_l9_d2_fake_system_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fake_system_command', ...args)
}

// Ruby let `let(:dsl) { described_class.new(cask, fake_system_command) }` at line 10.
pub fn ruby_preflight_spec_l10_d3_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dsl', ...args)
}

// Ruby let `let(:staged) { dsl }` at line 15.
pub fn ruby_preflight_spec_l15_d4_staged(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('staged', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "test/cask/dsl/shared_examples/base"
// 5: require "test/cask/dsl/shared_examples/staged"
// 6:
// 7: RSpec.describe Cask::DSL::Preflight, :cask do
// 8:   let(:cask) { Cask::CaskLoader.load(cask_path("basic-cask")) }
// 9:   let(:fake_system_command) { class_double(SystemCommand) }
// 10:   let(:dsl) { described_class.new(cask, fake_system_command) }
// 11:
// 12:   it_behaves_like Cask::DSL::Base
// 13:
// 14:   it_behaves_like Cask::Staged do
// 15:     let(:staged) { dsl }
// 16:   end
// 17: end
