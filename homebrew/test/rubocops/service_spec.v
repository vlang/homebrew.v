module rubocops

import brew_runtime
import homebrew.rubocops as service_core

// Translated from Homebrew/brew `test/rubocops/service_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_service_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::Service', 'FormulaAudit/Service')
}

// Ruby it `it "reports offenses when a service block is missing a required command" do` at line 9.
pub fn ruby_service_spec_l9_d2_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n\n  service do\n    run_type :cron\n    working_dir "/tmp/example"\n  end\nend\n'
	offenses := service_core.audit_service_block(source)
	header_begin := source.index('service do') or { -1 }
	return offenses.len == 1 && offenses[0].kind == 'missing_required_method' && offenses[0].begin_pos == header_begin && offenses[0].end_pos == header_begin + 10 && offenses[0].message == 'Service blocks require `run` or `name` to be defined.'
}

// Ruby it `it "reports no offenses when a service block includes custom names and requires root" do` at line 23.
pub fn ruby_service_spec_l23_d3_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n\n  service do\n    name macos: "custom.mcxl.foo", linux: "custom.foo"\n    require_root true\n  end\nend\n'
	return service_core.audit_service_block(source).len == 0
}

// Ruby it `it "reports offenses when a service block includes more than custom names and no run command" do` at line 36.
pub fn ruby_service_spec_l36_d4_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n\n  service do\n    name macos: "custom.mcxl.foo", linux: "custom.foo"\n    working_dir "/tmp/example"\n  end\nend\n'
	offenses := service_core.audit_service_block(source)
	header_begin := source.index('service do') or { -1 }
	return offenses.len == 1 && offenses[0].kind == 'missing_run' && offenses[0].begin_pos == header_begin && offenses[0].end_pos == header_begin + 10 && offenses[0].message == '`run` must be defined to use methods other than `name` like [:working_dir].'
}

// Ruby it `it "reports offenses when a formula's service block uses cellar paths" do` at line 50.
pub fn ruby_service_spec_l50_d5_reports() bool {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n\n  service do\n    run [bin/"foo", "run", "-config", etc/"foo/config.json"]\n    working_dir libexec\n  end\nend\n'
	offenses := service_core.audit_service_block(source)
	bin_begin := source.index('bin/"foo"') or { -1 }
	libexec_begin := source.index('libexec') or { -1 }
	expected := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n\n  service do\n    run [opt_bin/"foo", "run", "-config", etc/"foo/config.json"]\n    working_dir opt_libexec\n  end\nend\n'
	return offenses.len == 2 && offenses[0].method == 'bin' && offenses[0].begin_pos == bin_begin && offenses[0].end_pos == bin_begin + 3 && offenses[0].message == 'Use `opt_bin` instead of `bin` in service blocks.' && offenses[1].method == 'libexec' && offenses[1].begin_pos == libexec_begin && offenses[1].end_pos == libexec_begin + 7 && offenses[1].message == 'Use `opt_libexec` instead of `libexec` in service blocks.' && service_core.correct_service_block(source) == expected
}

// Ruby it `it "reports no offenses when a service block only uses opt paths" do` at line 76.
pub fn ruby_service_spec_l76_d6_reports() bool {
	source := 'class Bin < Formula\n  url "https://brew.sh/foo-1.0.tgz"\n\n  service do\n    run [opt_bin/"bin", "run", "-config", etc/"bin/config.json"]\n    working_dir opt_libexec\n  end\nend\n'
	return service_core.audit_service_block(source).len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/service"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Service do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports offenses when a service block is missing a required command" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:
// 14:         service do
// 15:         ^^^^^^^^^^ FormulaAudit/Service: Service blocks require `run` or `name` to be defined.
// 16:           run_type :cron
// 17:           working_dir "/tmp/example"
// 18:         end
// 19:       end
// 20:     RUBY
// 21:   end
// 22:
// 23:   it "reports no offenses when a service block includes custom names and requires root" do
// 24:     expect_no_offenses(<<~RUBY)
// 25:       class Foo < Formula
// 26:         url "https://brew.sh/foo-1.0.tgz"
// 27:
// 28:         service do
// 29:           name macos: "custom.mcxl.foo", linux: "custom.foo"
// 30:           require_root true
// 31:         end
// 32:       end
// 33:     RUBY
// 34:   end
// 35:
// 36:   it "reports offenses when a service block includes more than custom names and no run command" do
// 37:     expect_offense(<<~RUBY)
// 38:       class Foo < Formula
// 39:         url "https://brew.sh/foo-1.0.tgz"
// 40:
// 41:         service do
// 42:         ^^^^^^^^^^ FormulaAudit/Service: `run` must be defined to use methods other than `name` like [:working_dir].
// 43:           name macos: "custom.mcxl.foo", linux: "custom.foo"
// 44:           working_dir "/tmp/example"
// 45:         end
// 46:       end
// 47:     RUBY
// 48:   end
// 49:
// 50:   it "reports offenses when a formula's service block uses cellar paths" do
// 51:     expect_offense(<<~RUBY)
// 52:       class Foo < Formula
// 53:         url "https://brew.sh/foo-1.0.tgz"
// 54:
// 55:         service do
// 56:           run [bin/"foo", "run", "-config", etc/"foo/config.json"]
// 57:                ^^^ FormulaAudit/Service: Use `opt_bin` instead of `bin` in service blocks.
// 58:           working_dir libexec
// 59:                       ^^^^^^^ FormulaAudit/Service: Use `opt_libexec` instead of `libexec` in service blocks.
// 60:         end
// 61:       end
// 62:     RUBY
// 63:
// 64:     expect_correction(<<~RUBY)
// 65:       class Foo < Formula
// 66:         url "https://brew.sh/foo-1.0.tgz"
// 67:
// 68:         service do
// 69:           run [opt_bin/"foo", "run", "-config", etc/"foo/config.json"]
// 70:           working_dir opt_libexec
// 71:         end
// 72:       end
// 73:     RUBY
// 74:   end
// 75:
// 76:   it "reports no offenses when a service block only uses opt paths" do
// 77:     expect_no_offenses(<<~RUBY)
// 78:       class Bin < Formula
// 79:         url "https://brew.sh/foo-1.0.tgz"
// 80:
// 81:         service do
// 82:           run [opt_bin/"bin", "run", "-config", etc/"bin/config.json"]
// 83:           working_dir opt_libexec
// 84:         end
// 85:       end
// 86:     RUBY
// 87:   end
// 88: end
