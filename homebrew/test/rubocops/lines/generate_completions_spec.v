module lines

import brew_runtime
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/lines/generate_completions_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 8.
pub fn ruby_generate_completions_spec_l8_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::GenerateCompletionsDSL', 'GenerateCompletionsDSL')
}

fn generate_completion_spec(command string, formula_name string, correction string, message string) bool {
	analysis := line_cops.audit_lines_generate_completions(line_cops.LinesContext{ source: command, tap: 'homebrew-core', formula_name: formula_name })
	return analysis.offenses.len == 1 && analysis.corrected == correction && analysis.offenses[0].message == message
}

fn single_completion_spec(source string, corrected string, offense_count int) bool {
	analysis := line_cops.audit_lines_single_generate_call(line_cops.LinesContext{ source: source, tap: 'homebrew-core', formula_name: 'foo' })
	return analysis.offenses.len == offense_count && analysis.corrected == corrected
}

fn redundant_completion_spec(source string, corrected string, offense_count int) bool {
	analysis := line_cops.audit_lines_redundant_completion_shells(line_cops.LinesContext{ source: source, tap: 'homebrew-core', formula_name: 'foo' })
	return analysis.offenses.len == offense_count && analysis.corrected == corrected
}

// Ruby it `it "reports an offense when writing to a shell completions file directly" do` at line 10.
pub fn ruby_generate_completions_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := '(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "bash")'
	corrected := 'generate_completions_from_executable(bin/"foo", "completions", shells: [:bash])'
	return brew_runtime.bool_value(generate_completion_spec(source, 'foo', corrected, 'Use `${corrected}` instead of `${source}`.'))
}

// Ruby method `install` at line 15.
pub fn ruby_generate_completions_spec_l15_d3_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "bash")')
}

// Ruby method `install` at line 26.
pub fn ruby_generate_completions_spec_l26_d4_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", shells: [:bash])')
}

// Ruby it `it "reports an offense when writing to a shell completions file differing from the formula name" do` at line 33.
pub fn ruby_generate_completions_spec_l33_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := '(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "bash")'
	corrected := 'generate_completions_from_executable(bin/"foo", "completions", base_name: "foo", shells: [:bash])'
	return brew_runtime.bool_value(generate_completion_spec(source, 'foo-cli', corrected, 'Use `${corrected}` instead of `${source}`.'))
}

// Ruby method `install` at line 38.
pub fn ruby_generate_completions_spec_l38_d6_install(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_generate_completions_spec_l15_d3_install()
}

// Ruby method `install` at line 49.
pub fn ruby_generate_completions_spec_l49_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", base_name: "foo", shells: [:bash])')
}

// Ruby it `it "reports an offense when writing to a shell completions file using an arg for the shell parameter" do` at line 56.
pub fn ruby_generate_completions_spec_l56_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := '(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "--shell=bash")'
	corrected := 'generate_completions_from_executable(bin/"foo", "completions", shells: [:bash], shell_parameter_format: :arg)'
	return brew_runtime.bool_value(generate_completion_spec(source, 'foo', corrected, 'Use `${corrected}` instead of `${source}`.'))
}

// Ruby method `install` at line 61.
pub fn ruby_generate_completions_spec_l61_d9_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "--shell=bash")')
}

// Ruby method `install` at line 72.
pub fn ruby_generate_completions_spec_l72_d10_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", shells: [:bash], shell_parameter_format: :arg)')
}

// Ruby it `it "reports an offense when writing to a shell completions file using a custom flag for the shell parameter" do` at line 79.
pub fn ruby_generate_completions_spec_l79_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := '(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "--completion-script-bash")'
	corrected := 'generate_completions_from_executable(bin/"foo", "completions", shells: [:bash], shell_parameter_format: "--completion-script-")'
	return brew_runtime.bool_value(generate_completion_spec(source, 'foo', corrected, 'Use `${corrected}` instead of `${source}`.'))
}

// Ruby method `install` at line 84.
pub fn ruby_generate_completions_spec_l84_d12_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "--completion-script-bash")')
}

// Ruby method `install` at line 95.
pub fn ruby_generate_completions_spec_l95_d13_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", shells: [:bash], shell_parameter_format: "--completion-script-")')
}

// Ruby it `it "reports an offense when writing to a completions file indirectly" do` at line 102.
pub fn ruby_generate_completions_spec_l102_d14_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := '(bash_completion/"foo").write output'
	analysis := line_cops.audit_lines_generate_completions(line_cops.LinesContext{ source: source, formula_name: 'foo' })
	return brew_runtime.bool_value(analysis.offenses.len == 1 && analysis.corrected == source && analysis.offenses[0].message == 'Use `generate_completions_from_executable` DSL instead of `${source}`.')
}

// Ruby method `install` at line 107.
pub fn ruby_generate_completions_spec_l107_d15_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('output = Utils.safe_popen_read(bin/"foo", "completions", "bash")\n(bash_completion/"foo").write output')
}

// Ruby subject `subject(:cop) { described_class.new }` at line 118.
pub fn ruby_generate_completions_spec_l118_d16_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::SingleGenerateCompletionsDSLCall', 'SingleGenerateCompletionsDSLCall')
}

// Ruby it `it "reports an offense when using multiple` at line 120.
pub fn ruby_generate_completions_spec_l120_d17_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'generate_completions_from_executable(bin/"foo", "completions", shells: [:bash])\ngenerate_completions_from_executable(bin/"foo", "completions", shells: [:zsh])\ngenerate_completions_from_executable(bin/"foo", "completions", shells: [:fish])'
	corrected := 'generate_completions_from_executable(bin/"foo", "completions")'
	return brew_runtime.bool_value(single_completion_spec(source, corrected, 3))
}

// Ruby method `install` at line 125.
pub fn ruby_generate_completions_spec_l125_d18_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", shells: [:bash])\ngenerate_completions_from_executable(bin/"foo", "completions", shells: [:zsh])\ngenerate_completions_from_executable(bin/"foo", "completions", shells: [:fish])')
}

// Ruby method `install` at line 140.
pub fn ruby_generate_completions_spec_l140_d19_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions")')
}

// Ruby it `it "does not report an offense when shells are generated dynamically" do` at line 147.
pub fn ruby_generate_completions_spec_l147_d20_does(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'generate_completions_from_executable(bin/"foo", "completions")\n[:zsh, :bash].each do |shell|\n  generate_completions_from_executable(\n    bin/"foo", "completions", shell.to_s, "bar", shells: [shell], base_name: "bar",\n    shell_parameter_format: :none\n  )\nend'
	return brew_runtime.bool_value(single_completion_spec(source, source, 0))
}

// Ruby method `install` at line 152.
pub fn ruby_generate_completions_spec_l152_d21_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions")\n[:zsh, :bash].each do |shell|\n  generate_completions_from_executable(\n    bin/"foo", "completions", shell.to_s, "bar", shells: [shell], base_name: "bar",\n    shell_parameter_format: :none\n  )\nend')
}

// Ruby subject `subject(:cop) { described_class.new }` at line 167.
pub fn ruby_generate_completions_spec_l167_d22_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::RedundantGenerateCompletionsShells', 'RedundantGenerateCompletionsShells')
}

// Ruby it `it "reports an offense and removes `shells:` when all default shells are passed" do` at line 169.
pub fn ruby_generate_completions_spec_l169_d23_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh, :fish])'
	corrected := 'generate_completions_from_executable(bin/"foo", "completions")'
	return brew_runtime.bool_value(redundant_completion_spec(source, corrected, 1))
}

// Ruby method `install` at line 174.
pub fn ruby_generate_completions_spec_l174_d24_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh, :fish])')
}

// Ruby method `install` at line 185.
pub fn ruby_generate_completions_spec_l185_d25_install(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_generate_completions_spec_l140_d19_install()
}

// Ruby it `it "reports an offense regardless of the order of the default shells" do` at line 192.
pub fn ruby_generate_completions_spec_l192_d26_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'generate_completions_from_executable(bin/"foo", "completions", shells: [:fish, :bash, :zsh])'
	corrected := 'generate_completions_from_executable(bin/"foo", "completions")'
	return brew_runtime.bool_value(redundant_completion_spec(source, corrected, 1))
}

// Ruby method `install` at line 197.
pub fn ruby_generate_completions_spec_l197_d27_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", shells: [:fish, :bash, :zsh])')
}

// Ruby method `install` at line 208.
pub fn ruby_generate_completions_spec_l208_d28_install(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_generate_completions_spec_l140_d19_install()
}

// Ruby it `it "removes only `shells:` and keeps other keyword arguments" do` at line 215.
pub fn ruby_generate_completions_spec_l215_d29_removes(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh, :fish], base_name: "bar")'
	corrected := 'generate_completions_from_executable(bin/"foo", "completions", base_name: "bar")'
	return brew_runtime.bool_value(redundant_completion_spec(source, corrected, 1))
}

// Ruby method `install` at line 220.
pub fn ruby_generate_completions_spec_l220_d30_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh, :fish], base_name: "bar")')
}

// Ruby method `install` at line 231.
pub fn ruby_generate_completions_spec_l231_d31_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", base_name: "bar")')
}

// Ruby it `it "does not report an offense when only some default shells are passed" do` at line 238.
pub fn ruby_generate_completions_spec_l238_d32_does(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh])'
	return brew_runtime.bool_value(redundant_completion_spec(source, source, 0))
}

// Ruby method `install` at line 243.
pub fn ruby_generate_completions_spec_l243_d33_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh])')
}

// Ruby it `it "does not report an offense when a non-default shell is included" do` at line 250.
pub fn ruby_generate_completions_spec_l250_d34_does(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh, :fish, :pwsh])'
	return brew_runtime.bool_value(redundant_completion_spec(source, source, 0))
}

// Ruby method `install` at line 255.
pub fn ruby_generate_completions_spec_l255_d35_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh, :fish, :pwsh])')
}

// Ruby it `it "treats `:pwsh` as a default when `shell_parameter_format` is `:cobra`" do` at line 262.
pub fn ruby_generate_completions_spec_l262_d36_treats(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'generate_completions_from_executable(bin/"foo", shells: [:bash, :zsh, :fish, :pwsh], shell_parameter_format: :cobra)'
	corrected := 'generate_completions_from_executable(bin/"foo", shell_parameter_format: :cobra)'
	return brew_runtime.bool_value(redundant_completion_spec(source, corrected, 1))
}

// Ruby method `install` at line 267.
pub fn ruby_generate_completions_spec_l267_d37_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", shells: [:bash, :zsh, :fish, :pwsh], shell_parameter_format: :cobra)')
}

// Ruby method `install` at line 278.
pub fn ruby_generate_completions_spec_l278_d38_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", shell_parameter_format: :cobra)')
}

// Ruby it `it "does not report an offense when `:cobra` is used without its `:pwsh` default" do` at line 285.
pub fn ruby_generate_completions_spec_l285_d39_does(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'generate_completions_from_executable(bin/"foo", shells: [:bash, :zsh, :fish], shell_parameter_format: :cobra)'
	return brew_runtime.bool_value(redundant_completion_spec(source, source, 0))
}

// Ruby method `install` at line 290.
pub fn ruby_generate_completions_spec_l290_d40_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('generate_completions_from_executable(bin/"foo", shells: [:bash, :zsh, :fish], shell_parameter_format: :cobra)')
}

// Ruby it `it "does not report an offense when `shell_parameter_format` is not a literal" do` at line 297.
pub fn ruby_generate_completions_spec_l297_d41_does(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'format = :cobra\ngenerate_completions_from_executable(bin/"foo", shells: [:bash, :zsh, :fish], shell_parameter_format: format)'
	return brew_runtime.bool_value(redundant_completion_spec(source, source, 0))
}

// Ruby method `install` at line 302.
pub fn ruby_generate_completions_spec_l302_d42_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('format = :cobra\ngenerate_completions_from_executable(bin/"foo", shells: [:bash, :zsh, :fish], shell_parameter_format: format)')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit do
// 7:   describe RuboCop::Cop::FormulaAudit::GenerateCompletionsDSL do
// 8:     subject(:cop) { described_class.new }
// 9:
// 10:     it "reports an offense when writing to a shell completions file directly" do
// 11:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 12:         class Foo < Formula
// 13:           name "foo"
// 14:
// 15:           def install
// 16:             (bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "bash")
// 17:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/GenerateCompletionsDSL: Use `generate_completions_from_executable(bin/"foo", "completions", shells: [:bash])` instead of `(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "bash")`.
// 18:           end
// 19:         end
// 20:       RUBY
// 21:
// 22:       expect_correction(<<~RUBY)
// 23:         class Foo < Formula
// 24:           name "foo"
// 25:
// 26:           def install
// 27:             generate_completions_from_executable(bin/"foo", "completions", shells: [:bash])
// 28:           end
// 29:         end
// 30:       RUBY
// 31:     end
// 32:
// 33:     it "reports an offense when writing to a shell completions file differing from the formula name" do
// 34:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo-cli.rb")
// 35:         class FooCli < Formula
// 36:           name "foo-cli"
// 37:
// 38:           def install
// 39:             (bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "bash")
// 40:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/GenerateCompletionsDSL: Use `generate_completions_from_executable(bin/"foo", "completions", base_name: "foo", shells: [:bash])` instead of `(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "bash")`.
// 41:           end
// 42:         end
// 43:       RUBY
// 44:
// 45:       expect_correction(<<~RUBY)
// 46:         class FooCli < Formula
// 47:           name "foo-cli"
// 48:
// 49:           def install
// 50:             generate_completions_from_executable(bin/"foo", "completions", base_name: "foo", shells: [:bash])
// 51:           end
// 52:         end
// 53:       RUBY
// 54:     end
// 55:
// 56:     it "reports an offense when writing to a shell completions file using an arg for the shell parameter" do
// 57:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 58:         class Foo < Formula
// 59:           name "foo"
// 60:
// 61:           def install
// 62:             (bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "--shell=bash")
// 63:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/GenerateCompletionsDSL: Use `generate_completions_from_executable(bin/"foo", "completions", shells: [:bash], shell_parameter_format: :arg)` instead of `(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "--shell=bash")`.
// 64:           end
// 65:         end
// 66:       RUBY
// 67:
// 68:       expect_correction(<<~RUBY)
// 69:         class Foo < Formula
// 70:           name "foo"
// 71:
// 72:           def install
// 73:             generate_completions_from_executable(bin/"foo", "completions", shells: [:bash], shell_parameter_format: :arg)
// 74:           end
// 75:         end
// 76:       RUBY
// 77:     end
// 78:
// 79:     it "reports an offense when writing to a shell completions file using a custom flag for the shell parameter" do
// 80:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 81:         class Foo < Formula
// 82:           name "foo"
// 83:
// 84:           def install
// 85:             (bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "--completion-script-bash")
// 86:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/GenerateCompletionsDSL: Use `generate_completions_from_executable(bin/"foo", "completions", shells: [:bash], shell_parameter_format: "--completion-script-")` instead of `(bash_completion/"foo").write Utils.safe_popen_read(bin/"foo", "completions", "--completion-script-bash")`.
// 87:           end
// 88:         end
// 89:       RUBY
// 90:
// 91:       expect_correction(<<~RUBY)
// 92:         class Foo < Formula
// 93:           name "foo"
// 94:
// 95:           def install
// 96:             generate_completions_from_executable(bin/"foo", "completions", shells: [:bash], shell_parameter_format: "--completion-script-")
// 97:           end
// 98:         end
// 99:       RUBY
// 100:     end
// 101:
// 102:     it "reports an offense when writing to a completions file indirectly" do
// 103:       expect_offense(<<~RUBY)
// 104:         class Foo < Formula
// 105:           name "foo"
// 106:
// 107:           def install
// 108:             output = Utils.safe_popen_read(bin/"foo", "completions", "bash")
// 109:             (bash_completion/"foo").write output
// 110:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/GenerateCompletionsDSL: Use `generate_completions_from_executable` DSL instead of `(bash_completion/"foo").write output`.
// 111:           end
// 112:         end
// 113:       RUBY
// 114:     end
// 115:   end
// 116:
// 117:   describe RuboCop::Cop::FormulaAudit::SingleGenerateCompletionsDSLCall do
// 118:     subject(:cop) { described_class.new }
// 119:
// 120:     it "reports an offense when using multiple #generate_completions_from_executable calls for different shells" do
// 121:       expect_offense(<<~RUBY)
// 122:         class Foo < Formula
// 123:           name "foo"
// 124:
// 125:           def install
// 126:             generate_completions_from_executable(bin/"foo", "completions", shells: [:bash])
// 127:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/SingleGenerateCompletionsDSLCall: Use a single `generate_completions_from_executable` call combining all specified shells.
// 128:             generate_completions_from_executable(bin/"foo", "completions", shells: [:zsh])
// 129:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/SingleGenerateCompletionsDSLCall: Use a single `generate_completions_from_executable` call combining all specified shells.
// 130:             generate_completions_from_executable(bin/"foo", "completions", shells: [:fish])
// 131:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/SingleGenerateCompletionsDSLCall: Use `generate_completions_from_executable(bin/"foo", "completions")` instead of `generate_completions_from_executable(bin/"foo", "completions", shells: [:fish])`.
// 132:           end
// 133:         end
// 134:       RUBY
// 135:
// 136:       expect_correction(<<~RUBY)
// 137:         class Foo < Formula
// 138:           name "foo"
// 139:
// 140:           def install
// 141:             generate_completions_from_executable(bin/"foo", "completions")
// 142:           end
// 143:         end
// 144:       RUBY
// 145:     end
// 146:
// 147:     it "does not report an offense when shells are generated dynamically" do
// 148:       expect_no_offenses(<<~RUBY)
// 149:         class Foo < Formula
// 150:           name "foo"
// 151:
// 152:           def install
// 153:             generate_completions_from_executable(bin/"foo", "completions")
// 154:             [:zsh, :bash].each do |shell|
// 155:               generate_completions_from_executable(
// 156:                 bin/"foo", "completions", shell.to_s, "bar", shells: [shell], base_name: "bar",
// 157:                 shell_parameter_format: :none
// 158:               )
// 159:             end
// 160:           end
// 161:         end
// 162:       RUBY
// 163:     end
// 164:   end
// 165:
// 166:   describe RuboCop::Cop::FormulaAudit::RedundantGenerateCompletionsShells do
// 167:     subject(:cop) { described_class.new }
// 168:
// 169:     it "reports an offense and removes `shells:` when all default shells are passed" do
// 170:       expect_offense(<<~RUBY)
// 171:         class Foo < Formula
// 172:           name "foo"
// 173:
// 174:           def install
// 175:             generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh, :fish])
// 176:                                                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/RedundantGenerateCompletionsShells: Passing the default shells to `generate_completions_from_executable` is redundant
// 177:           end
// 178:         end
// 179:       RUBY
// 180:
// 181:       expect_correction(<<~RUBY)
// 182:         class Foo < Formula
// 183:           name "foo"
// 184:
// 185:           def install
// 186:             generate_completions_from_executable(bin/"foo", "completions")
// 187:           end
// 188:         end
// 189:       RUBY
// 190:     end
// 191:
// 192:     it "reports an offense regardless of the order of the default shells" do
// 193:       expect_offense(<<~RUBY)
// 194:         class Foo < Formula
// 195:           name "foo"
// 196:
// 197:           def install
// 198:             generate_completions_from_executable(bin/"foo", "completions", shells: [:fish, :bash, :zsh])
// 199:                                                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/RedundantGenerateCompletionsShells: Passing the default shells to `generate_completions_from_executable` is redundant
// 200:           end
// 201:         end
// 202:       RUBY
// 203:
// 204:       expect_correction(<<~RUBY)
// 205:         class Foo < Formula
// 206:           name "foo"
// 207:
// 208:           def install
// 209:             generate_completions_from_executable(bin/"foo", "completions")
// 210:           end
// 211:         end
// 212:       RUBY
// 213:     end
// 214:
// 215:     it "removes only `shells:` and keeps other keyword arguments" do
// 216:       expect_offense(<<~RUBY)
// 217:         class Foo < Formula
// 218:           name "foo"
// 219:
// 220:           def install
// 221:             generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh, :fish], base_name: "bar")
// 222:                                                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/RedundantGenerateCompletionsShells: Passing the default shells to `generate_completions_from_executable` is redundant
// 223:           end
// 224:         end
// 225:       RUBY
// 226:
// 227:       expect_correction(<<~RUBY)
// 228:         class Foo < Formula
// 229:           name "foo"
// 230:
// 231:           def install
// 232:             generate_completions_from_executable(bin/"foo", "completions", base_name: "bar")
// 233:           end
// 234:         end
// 235:       RUBY
// 236:     end
// 237:
// 238:     it "does not report an offense when only some default shells are passed" do
// 239:       expect_no_offenses(<<~RUBY)
// 240:         class Foo < Formula
// 241:           name "foo"
// 242:
// 243:           def install
// 244:             generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh])
// 245:           end
// 246:         end
// 247:       RUBY
// 248:     end
// 249:
// 250:     it "does not report an offense when a non-default shell is included" do
// 251:       expect_no_offenses(<<~RUBY)
// 252:         class Foo < Formula
// 253:           name "foo"
// 254:
// 255:           def install
// 256:             generate_completions_from_executable(bin/"foo", "completions", shells: [:bash, :zsh, :fish, :pwsh])
// 257:           end
// 258:         end
// 259:       RUBY
// 260:     end
// 261:
// 262:     it "treats `:pwsh` as a default when `shell_parameter_format` is `:cobra`" do
// 263:       expect_offense(<<~RUBY)
// 264:         class Foo < Formula
// 265:           name "foo"
// 266:
// 267:           def install
// 268:             generate_completions_from_executable(bin/"foo", shells: [:bash, :zsh, :fish, :pwsh], shell_parameter_format: :cobra)
// 269:                                                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/RedundantGenerateCompletionsShells: Passing the default shells to `generate_completions_from_executable` is redundant
// 270:           end
// 271:         end
// 272:       RUBY
// 273:
// 274:       expect_correction(<<~RUBY)
// 275:         class Foo < Formula
// 276:           name "foo"
// 277:
// 278:           def install
// 279:             generate_completions_from_executable(bin/"foo", shell_parameter_format: :cobra)
// 280:           end
// 281:         end
// 282:       RUBY
// 283:     end
// 284:
// 285:     it "does not report an offense when `:cobra` is used without its `:pwsh` default" do
// 286:       expect_no_offenses(<<~RUBY)
// 287:         class Foo < Formula
// 288:           name "foo"
// 289:
// 290:           def install
// 291:             generate_completions_from_executable(bin/"foo", shells: [:bash, :zsh, :fish], shell_parameter_format: :cobra)
// 292:           end
// 293:         end
// 294:       RUBY
// 295:     end
// 296:
// 297:     it "does not report an offense when `shell_parameter_format` is not a literal" do
// 298:       expect_no_offenses(<<~RUBY)
// 299:         class Foo < Formula
// 300:           name "foo"
// 301:
// 302:           def install
// 303:             format = :cobra
// 304:             generate_completions_from_executable(bin/"foo", shells: [:bash, :zsh, :fish], shell_parameter_format: format)
// 305:           end
// 306:         end
// 307:       RUBY
// 308:     end
// 309:   end
// 310: end
