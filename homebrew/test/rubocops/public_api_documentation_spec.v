module rubocops

import brew_runtime
import homebrew.rubocops as public_api_documentation_core

// Translated from Homebrew/brew `test/rubocops/public_api_documentation_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_public_api_documentation_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::Homebrew::PublicApiDocumentation', 'Homebrew/PublicApiDocumentation')
}

// Ruby it `it "reports an offense" do` at line 10.
pub fn ruby_public_api_documentation_spec_l10_d2_reports() bool {
	offenses := public_api_documentation_core.audit_public_api_documentation(public_api_documentation_core.PublicApiDocumentationContext{
		source: '# @api public\nsig { returns(String) }\ndef foo; end\n'
	})
	return offenses.len == 1 && offenses[0].kind == 'missing_description'
}

// Ruby method `foo; end` at line 15.
pub fn ruby_public_api_documentation_spec_l15_d3_foo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def foo; end')
}

// Ruby it `it "reports an offense" do` at line 21.
pub fn ruby_public_api_documentation_spec_l21_d4_reports() bool {
	offenses := public_api_documentation_core.audit_public_api_documentation(public_api_documentation_core.PublicApiDocumentationContext{
		source: '#\n# @api public\nsig { returns(String) }\ndef foo; end\n'
	})
	return offenses.len == 1 && offenses[0].kind == 'missing_description'
}

// Ruby method `foo; end` at line 27.
pub fn ruby_public_api_documentation_spec_l27_d5_foo(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_public_api_documentation_spec_l15_d3_foo(...args)
}

// Ruby it `it "reports an offense" do` at line 33.
pub fn ruby_public_api_documentation_spec_l33_d6_reports() bool {
	offenses := public_api_documentation_core.audit_public_api_documentation(public_api_documentation_core.PublicApiDocumentationContext{
		source: '# @return [String]\n# @api public\nsig { returns(String) }\ndef foo; end\n'
	})
	return offenses.len == 1 && offenses[0].kind == 'missing_description'
}

// Ruby method `foo; end` at line 39.
pub fn ruby_public_api_documentation_spec_l39_d7_foo(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_public_api_documentation_spec_l15_d3_foo(...args)
}

// Ruby it `it "does not report an offense" do` at line 45.
pub fn ruby_public_api_documentation_spec_l45_d8_does() bool {
	source := '# The name of the formula.\n#\n# @api public\nsig { returns(String) }\ndef name; end\n'
	return public_api_documentation_core.audit_public_api_documentation(public_api_documentation_core.PublicApiDocumentationContext{ source: source }).len == 0
}

// Ruby method `name; end` at line 51.
pub fn ruby_public_api_documentation_spec_l51_d9_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def name; end')
}

// Ruby it `it "does not report an offense" do` at line 57.
pub fn ruby_public_api_documentation_spec_l57_d10_does() bool {
	source := "# The directory where the formula's binaries should be installed.\n# This is symlinked into `HOMEBREW_PREFIX` after installation.\n#\n# @api public\nsig { returns(Pathname) }\ndef bin; end\n"
	return public_api_documentation_core.audit_public_api_documentation(public_api_documentation_core.PublicApiDocumentationContext{ source: source }).len == 0
}

// Ruby method `bin; end` at line 64.
pub fn ruby_public_api_documentation_spec_l64_d11_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def bin; end')
}

// Ruby it `it "does not report an offense" do` at line 70.
pub fn ruby_public_api_documentation_spec_l70_d12_does() bool {
	source := '# A private method.\nsig { returns(String) }\ndef foo; end\n'
	return public_api_documentation_core.audit_public_api_documentation(public_api_documentation_core.PublicApiDocumentationContext{ source: source }).len == 0
}

// Ruby method `foo; end` at line 74.
pub fn ruby_public_api_documentation_spec_l74_d13_foo(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_public_api_documentation_spec_l15_d3_foo(...args)
}

// Ruby it `it "does not report an offense" do` at line 80.
pub fn ruby_public_api_documentation_spec_l80_d14_does() bool {
	source := '# The installation prefix.\n#\n# ### Example\n#\n# ```ruby\n# prefix.install "file"\n# ```\n#\n# @api public\nsig { returns(Pathname) }\ndef prefix; end\n'
	return public_api_documentation_core.audit_public_api_documentation(public_api_documentation_core.PublicApiDocumentationContext{ source: source }).len == 0
}

// Ruby method `prefix; end` at line 92.
pub fn ruby_public_api_documentation_spec_l92_d15_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def prefix; end')
}

// Ruby subject `subject(:cop) do` at line 98.
pub fn ruby_public_api_documentation_spec_l98_d16_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Homebrew::PublicApiDocumentation', 'Homebrew/PublicApiDocumentation', {
		'Style/Documentation.Include': '[]'
	})
}

// Ruby it `it "reports an offense" do` at line 104.
pub fn ruby_public_api_documentation_spec_l104_d17_reports() bool {
	source := '# The public method.\n#\n# @api public\ndef foo; end\n'
	offenses := public_api_documentation_core.audit_public_api_documentation(public_api_documentation_core.PublicApiDocumentationContext{
		source: source
		file_path: 'public_api.rb'
		has_file_path: true
		has_documentation_include: true
	})
	return offenses.len == 1 && offenses[0].kind == 'missing_include' && offenses[0].message == '`public_api.rb` contains `@api public` but is missing from `Style/Documentation.Include`.'
}

// Ruby method `foo; end` at line 110.
pub fn ruby_public_api_documentation_spec_l110_d18_foo(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_public_api_documentation_spec_l15_d3_foo(...args)
}

// Ruby subject `subject(:cop) do` at line 116.
pub fn ruby_public_api_documentation_spec_l116_d19_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Homebrew::PublicApiDocumentation', 'Homebrew/PublicApiDocumentation', {
		'Style/Documentation.Include': '["stale.rb"]'
	})
}

// Ruby it `it "reports an offense" do` at line 122.
pub fn ruby_public_api_documentation_spec_l122_d20_reports() bool {
	source := 'class Stale\nend\n'
	offenses := public_api_documentation_core.audit_public_api_documentation(public_api_documentation_core.PublicApiDocumentationContext{
		source: source
		file_path: 'stale.rb'
		has_file_path: true
		documentation_include: ['stale.rb']
		has_documentation_include: true
	})
	return offenses.len == 1 && offenses[0].kind == 'extra_include' && offenses[0].begin_pos == 0 && offenses[0].end_pos == 'class Stale\nend'.len && offenses[0].message == '`stale.rb` is included in `Style/Documentation.Include` but does not contain `@api public`.'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/public_api_documentation"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::PublicApiDocumentation do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when a method has a bare `@api public` with no description" do
// 10:     it "reports an offense" do
// 11:       expect_offense(<<~RUBY)
// 12:         # @api public
// 13:         ^^^^^^^^^^^^^ Homebrew/PublicApiDocumentation: `@api public` methods must have a descriptive YARD comment, not just the annotation.
// 14:         sig { returns(String) }
// 15:         def foo; end
// 16:       RUBY
// 17:     end
// 18:   end
// 19:
// 20:   context "when `@api public` is preceded only by blank comment lines" do
// 21:     it "reports an offense" do
// 22:       expect_offense(<<~RUBY)
// 23:         #
// 24:         # @api public
// 25:         ^^^^^^^^^^^^^ Homebrew/PublicApiDocumentation: `@api public` methods must have a descriptive YARD comment, not just the annotation.
// 26:         sig { returns(String) }
// 27:         def foo; end
// 28:       RUBY
// 29:     end
// 30:   end
// 31:
// 32:   context "when `@api public` is preceded only by other YARD tags" do
// 33:     it "reports an offense" do
// 34:       expect_offense(<<~RUBY)
// 35:         # @return [String]
// 36:         # @api public
// 37:         ^^^^^^^^^^^^^ Homebrew/PublicApiDocumentation: `@api public` methods must have a descriptive YARD comment, not just the annotation.
// 38:         sig { returns(String) }
// 39:         def foo; end
// 40:       RUBY
// 41:     end
// 42:   end
// 43:
// 44:   context "when a method has a descriptive comment before `@api public`" do
// 45:     it "does not report an offense" do
// 46:       expect_no_offenses(<<~RUBY)
// 47:         # The name of the formula.
// 48:         #
// 49:         # @api public
// 50:         sig { returns(String) }
// 51:         def name; end
// 52:       RUBY
// 53:     end
// 54:   end
// 55:
// 56:   context "when a method has a multi-line description before `@api public`" do
// 57:     it "does not report an offense" do
// 58:       expect_no_offenses(<<~RUBY)
// 59:         # The directory where the formula's binaries should be installed.
// 60:         # This is symlinked into `HOMEBREW_PREFIX` after installation.
// 61:         #
// 62:         # @api public
// 63:         sig { returns(Pathname) }
// 64:         def bin; end
// 65:       RUBY
// 66:     end
// 67:   end
// 68:
// 69:   context "when there is no `@api public` annotation" do
// 70:     it "does not report an offense" do
// 71:       expect_no_offenses(<<~RUBY)
// 72:         # A private method.
// 73:         sig { returns(String) }
// 74:         def foo; end
// 75:       RUBY
// 76:     end
// 77:   end
// 78:
// 79:   context "when `@api public` has a description with examples" do
// 80:     it "does not report an offense" do
// 81:       expect_no_offenses(<<~RUBY)
// 82:         # The installation prefix.
// 83:         #
// 84:         # ### Example
// 85:         #
// 86:         # ```ruby
// 87:         # prefix.install "file"
// 88:         # ```
// 89:         #
// 90:         # @api public
// 91:         sig { returns(Pathname) }
// 92:         def prefix; end
// 93:       RUBY
// 94:     end
// 95:   end
// 96:
// 97:   context "when a public API file is missing from `Style/Documentation.Include`" do
// 98:     subject(:cop) do
// 99:       described_class.new(
// 100:         RuboCop::Config.new("Style/Documentation" => { "Include" => [] }),
// 101:       )
// 102:     end
// 103:
// 104:     it "reports an offense" do
// 105:       expect_offense(<<~RUBY, "public_api.rb")
// 106:         # The public method.
// 107:         #
// 108:         # @api public
// 109:         ^^^^^^^^^^^^^ `public_api.rb` contains `@api public` but is missing from `Style/Documentation.Include`.
// 110:         def foo; end
// 111:       RUBY
// 112:     end
// 113:   end
// 114:
// 115:   context "when a documented API file has no public API annotations" do
// 116:     subject(:cop) do
// 117:       described_class.new(
// 118:         RuboCop::Config.new("Style/Documentation" => { "Include" => ["stale.rb"] }),
// 119:       )
// 120:     end
// 121:
// 122:     it "reports an offense" do
// 123:       expect_offense(<<~RUBY, "stale.rb")
// 124:         class Stale
// 125:         ^^^^^^^^^^^ `stale.rb` is included in `Style/Documentation.Include` but does not contain `@api public`.
// 126:         end
// 127:       RUBY
// 128:     end
// 129:   end
// 130: end
