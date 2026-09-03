module cmd

import homebrew.cmd as migrate_core

// Translated from Homebrew/brew `test/cmd/migrate_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "migrates a renamed Formula", :integration_test, :no_api do` at line 10.
pub fn ruby_migrate_spec_l10_d1_migrates() bool {
	result := migrate_core.run_migrate_command([migrate_core.MigratePackage{
		kind: .formula
		old_name: 'testball1'
		new_name: 'testball2'
		installed: true
	}], migrate_core.MigrateOptions{})
	return result.output == ['Migrating formula testball1 to testball2'] && result.migrated == [
		'testball2',
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/migrate"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Migrate do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "migrates a renamed Formula", :integration_test, :no_api do
// 11:     setup_test_formula "testball1"
// 12:     setup_test_formula "testball2"
// 13:     install_and_rename_coretap_formula "testball1", "testball2"
// 14:
// 15:     expect { brew "migrate", "testball1" }
// 16:       .to output(/Migrating formula testball1 to testball2/).to_stdout
// 17:       .and not_to_output.to_stderr
// 18:       .and be_a_success
// 19:   end
// 20: end
