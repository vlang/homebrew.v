module fixtures

import ruby

// Translated from Homebrew/brew `test/support/fixtures/failball.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(name = "failball", path = Pathname.new(__FILE__).expand_path, spec = :stable,` at line 7.
pub fn ruby_failball_l7_d1_initialize(args ...ruby.Value) ruby.Value {
	return fixture_formula_value(fixture_formula_from_args(args, 'Failball', 'failball', false, false))
}

// Ruby method `self.inherited(other)` at line 20.
pub fn ruby_failball_l20_d2_self_inherited(args ...ruby.Value) ruby.Value {
	other := if args.len > 0 {
		args[0]
	} else {
		ruby.object_value('Class', 'FailballSubclass')
	}
	return fixture_inherited_value(other, fixture_formula_from_args([], 'Failball', 'failball', false, false))
}

// Ruby method `install` at line 25.
pub fn ruby_failball_l25_d3_install(args ...ruby.Value) ruby.Value {
	fail_build := if args.len > 0 {
		args[0].bool_data
	} else {
		ruby.environment_value('FAILBALL_BUILD_ERROR') != ''
	}
	return fixture_install_value(fixture_install_plan('failball', fail_build))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: class Failball < Formula
// 5:   Cache = type_template { { fixed: T::Hash[Symbol, T.untyped] } }
// 6:
// 7:   def initialize(name = "failball", path = Pathname.new(__FILE__).expand_path, spec = :stable,
// 8:                  alias_path: nil, tap: nil, force_bottle: false)
// 9:     super
// 10:   end
// 11:
// 12:   DSL_PROC = proc do
// 13:     url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 14:     sha256 TESTBALL_SHA256
// 15:   end.freeze
// 16:   private_constant :DSL_PROC
// 17:
// 18:   DSL_PROC.call
// 19:
// 20:   def self.inherited(other)
// 21:     super
// 22:     other.instance_eval(&DSL_PROC)
// 23:   end
// 24:
// 25:   def install
// 26:     prefix.install "bin"
// 27:     prefix.install "libexec"
// 28:
// 29:     # This should get marshalled into a BuildError.
// 30:     system "/usr/bin/false" if ENV["FAILBALL_BUILD_ERROR"]
// 31:
// 32:     # This should get marshalled into a RuntimeError.
// 33:     raise "Something that isn't a build error happened!"
// 34:   end
// 35: end
