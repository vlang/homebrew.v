module fixtures

import ruby

// Translated from Homebrew/brew `test/support/fixtures/testball_bottle_cellar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(name = "testball_bottle", path = Pathname.new(__FILE__).expand_path, spec = :stable,` at line 7.
pub fn ruby_testball_bottle_cellar_l7_d1_initialize(args ...ruby.Value) ruby.Value {
	return fixture_formula_value(fixture_formula_from_args(args, 'TestballBottleCellar', 'testball_bottle', false, true))
}

// Ruby method `self.inherited(other)` at line 25.
pub fn ruby_testball_bottle_cellar_l25_d2_self_inherited(args ...ruby.Value) ruby.Value {
	other := if args.len > 0 {
		args[0]
	} else {
		ruby.object_value('Class', 'TestballBottleCellarSubclass')
	}
	return fixture_inherited_value(other, fixture_formula_from_args([], 'TestballBottleCellar', 'testball_bottle', false, true))
}

// Ruby method `install` at line 30.
pub fn ruby_testball_bottle_cellar_l30_d3_install(args ...ruby.Value) ruby.Value {
	return fixture_install_value(fixture_install_plan('testball_bottle_cellar', false))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: class TestballBottleCellar < Formula
// 5:   Cache = type_template { { fixed: T::Hash[Symbol, T.untyped] } }
// 6:
// 7:   def initialize(name = "testball_bottle", path = Pathname.new(__FILE__).expand_path, spec = :stable,
// 8:                  alias_path: nil, tap: nil, force_bottle: false)
// 9:     super
// 10:   end
// 11:
// 12:   DSL_PROC = proc do
// 13:     url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 14:     sha256 TESTBALL_SHA256
// 15:
// 16:     bottle do
// 17:       root_url "file://#{TEST_FIXTURE_DIR}/bottles"
// 18:       sha256 cellar: :any_skip_relocation, Utils::Bottles.tag.to_sym => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 19:     end
// 20:   end.freeze
// 21:   private_constant :DSL_PROC
// 22:
// 23:   DSL_PROC.call
// 24:
// 25:   def self.inherited(other)
// 26:     super
// 27:     other.instance_eval(&DSL_PROC)
// 28:   end
// 29:
// 30:   def install
// 31:     prefix.install "bin"
// 32:     prefix.install "libexec"
// 33:   end
// 34: end
