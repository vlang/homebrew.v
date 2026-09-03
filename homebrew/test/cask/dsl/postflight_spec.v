module dsl

import brew_runtime

// Translated from Homebrew/brew `test/cask/dsl/postflight_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("basic-cask")) }` at line 8.
pub fn ruby_postflight_spec_l8_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	path := if args.len > 0 { args[0].as_string() } else { 'basic-cask.rb' }
	return brew_runtime.structured_value('Cask::Cask', 'basic-cask', {
		'token': 'basic-cask'
		'path':  path
	})
}

// Ruby let `let(:fake_system_command) { class_double(SystemCommand) }` at line 9.
pub fn ruby_postflight_spec_l9_d2_fake_system_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Class', 'SystemCommand')
}

// Ruby let `let(:dsl) { described_class.new(cask, fake_system_command) }` at line 10.
pub fn ruby_postflight_spec_l10_d3_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 0 { args[0] } else { ruby_postflight_spec_l8_d1_cask() }
	command := if args.len > 1 { args[1] } else { ruby_postflight_spec_l9_d2_fake_system_command() }
	return brew_runtime.structured_value('Cask::DSL::Postflight', cask.as_string(), {
		'cask':           cask.as_string()
		'system_command': command.as_string()
		'staged':         'true'
	})
}

// Ruby let `let(:staged) { dsl }` at line 15.
pub fn ruby_postflight_spec_l15_d4_staged(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[0] } else { ruby_postflight_spec_l10_d3_dsl() }
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "test/cask/dsl/shared_examples/base"
// 5: require "test/cask/dsl/shared_examples/staged"
// 6:
// 7: RSpec.describe Cask::DSL::Postflight, :cask do
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
