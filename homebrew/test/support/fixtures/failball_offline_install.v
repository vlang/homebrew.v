module fixtures

import ruby

// Translated from Homebrew/brew `test/support/fixtures/failball_offline_install.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(name = "failball_offline_install", path = Pathname.new(__FILE__).expand_path, spec = :stable,` at line 7.
pub fn ruby_failball_offline_install_l7_d1_initialize(args ...ruby.Value) ruby.Value {
	return fixture_formula_value(fixture_formula_from_args(args, 'FailballOfflineInstall', 'failball_offline_install', true, false))
}

// Ruby method `self.inherited(other)` at line 21.
pub fn ruby_failball_offline_install_l21_d2_self_inherited(args ...ruby.Value) ruby.Value {
	other := if args.len > 0 {
		args[0]
	} else {
		ruby.object_value('Class', 'FailballOfflineInstallSubclass')
	}
	return fixture_inherited_value(other, fixture_formula_from_args([], 'FailballOfflineInstall', 'failball_offline_install', true, false))
}

// Ruby method `install` at line 26.
pub fn ruby_failball_offline_install_l26_d3_install(args ...ruby.Value) ruby.Value {
	return fixture_install_value(fixture_install_plan('failball_offline_install', false))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: class FailballOfflineInstall < Formula
// 5:   Cache = type_template { { fixed: T::Hash[Symbol, T.untyped] } }
// 6:
// 7:   def initialize(name = "failball_offline_install", path = Pathname.new(__FILE__).expand_path, spec = :stable,
// 8:                  alias_path: nil, tap: nil, force_bottle: false)
// 9:     super
// 10:   end
// 11:
// 12:   DSL_PROC = proc do
// 13:     url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 14:     sha256 TESTBALL_SHA256
// 15:     deny_network_access! :build
// 16:   end.freeze
// 17:   private_constant :DSL_PROC
// 18:
// 19:   DSL_PROC.call
// 20:
// 21:   def self.inherited(other)
// 22:     super
// 23:     other.instance_eval(&DSL_PROC)
// 24:   end
// 25:
// 26:   def install
// 27:     system "curl", "example.org"
// 28:
// 29:     prefix.install "bin"
// 30:     prefix.install "libexec"
// 31:     Dir.chdir "doc"
// 32:   end
// 33: end
