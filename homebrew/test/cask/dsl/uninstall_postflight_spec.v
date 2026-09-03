module dsl

import brew_runtime

// Translated from Homebrew/brew `test/cask/dsl/uninstall_postflight_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("basic-cask")) }` at line 7.
pub fn ruby_uninstall_postflight_spec_l7_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	path := if args.len > 0 { args[0].as_string() } else { 'basic-cask.rb' }
	return brew_runtime.structured_value('Cask::Cask', 'basic-cask', {
		'token': 'basic-cask'
		'path':  path
	})
}

// Ruby let `let(:dsl) { described_class.new(cask, class_double(SystemCommand)) }` at line 8.
pub fn ruby_uninstall_postflight_spec_l8_d2_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 0 { args[0] } else { ruby_uninstall_postflight_spec_l7_d1_cask() }
	return brew_runtime.structured_value('Cask::DSL::UninstallPostflight', cask.as_string(), {
		'cask':           cask.as_string()
		'system_command': 'SystemCommand'
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "test/cask/dsl/shared_examples/base"
// 5:
// 6: RSpec.describe Cask::DSL::UninstallPostflight, :cask do
// 7:   let(:cask) { Cask::CaskLoader.load(cask_path("basic-cask")) }
// 8:   let(:dsl) { described_class.new(cask, class_double(SystemCommand)) }
// 9:
// 10:   it_behaves_like Cask::DSL::Base
// 11: end
