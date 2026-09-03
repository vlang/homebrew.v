module rubocops

import brew_runtime
import homebrew.rubocops as files_core

// Translated from Homebrew/brew `test/rubocops/files_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_files_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::Files', 'FormulaAudit/Files')
}

// Ruby it `it "reports an offense when the permissions are invalid" do` at line 10.
pub fn ruby_files_spec_l10_d2_reports() bool {
	problems := files_core.audit_file_permission_mode('/tmp/test_formula.rb', 0)
	return problems.len == 2 && problems[0].wanted == 'a+r' && problems[0].message == 'Incorrect file permissions (000): chmod a+r /tmp/test_formula.rb'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/files"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Files do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing files" do
// 10:     it "reports an offense when the permissions are invalid" do
// 11:       filename = Formulary.core_path("test_formula")
// 12:       File.open(filename, "w") do |file|
// 13:         FileUtils.chmod "-rwx", filename
// 14:
// 15:         expect_offense(<<~RUBY, file)
// 16:           class Foo < Formula
// 17:           ^^^^^^^^^^^^^^^^^^^ FormulaAudit/Files: Incorrect file permissions (000): chmod a+r #{filename}
// 18:             url "https://brew.sh/foo-1.0.tgz"
// 19:           end
// 20:         RUBY
// 21:       end
// 22:     end
// 23:   end
// 24: end
