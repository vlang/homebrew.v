module ast

import brew_runtime

// Translated from Homebrew/brew `test/utils/ast/ast_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:compound_license) do` at line 8.
pub fn ruby_ast_spec_l8_d1_compound_license(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compound_license', ...args)
}

// Ruby it `it "accepts existing stanza text" do` at line 18.
pub fn ruby_ast_spec_l18_d2_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts a number as the stanza value" do` at line 25.
pub fn ruby_ast_spec_l25_d3_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts a symbol as the stanza value" do` at line 29.
pub fn ruby_ast_spec_l29_d4_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts a string as the stanza value" do` at line 33.
pub fn ruby_ast_spec_l33_d5_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "adds indent to stanza text if specified" do` at line 37.
pub fn ruby_ast_spec_l37_d6_adds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('adds', ...args)
}

// Ruby it `it "does not add indent if already indented" do` at line 43.
pub fn ruby_ast_spec_l43_d7_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/ast"
// 5:
// 6: RSpec.describe Utils::AST do
// 7:   describe ".stanza_text" do
// 8:     let(:compound_license) do
// 9:       <<-RUBY
// 10:   license all_of: [
// 11:     :public_domain,
// 12:     "MIT",
// 13:     "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
// 14:   ]
// 15:       RUBY
// 16:     end
// 17:
// 18:     it "accepts existing stanza text" do
// 19:       expect(described_class.stanza_text(:revision, "revision 1")).to eq("revision 1")
// 20:       expect(described_class.stanza_text(:license, "license :public_domain")).to eq("license :public_domain")
// 21:       expect(described_class.stanza_text(:license, 'license "MIT"')).to eq('license "MIT"')
// 22:       expect(described_class.stanza_text(:license, compound_license)).to eq(compound_license)
// 23:     end
// 24:
// 25:     it "accepts a number as the stanza value" do
// 26:       expect(described_class.stanza_text(:revision, 1)).to eq("revision 1")
// 27:     end
// 28:
// 29:     it "accepts a symbol as the stanza value" do
// 30:       expect(described_class.stanza_text(:license, :public_domain)).to eq("license :public_domain")
// 31:     end
// 32:
// 33:     it "accepts a string as the stanza value" do
// 34:       expect(described_class.stanza_text(:license, "MIT")).to eq('license "MIT"')
// 35:     end
// 36:
// 37:     it "adds indent to stanza text if specified" do
// 38:       expect(described_class.stanza_text(:revision, "revision 1", indent: 2)).to eq("  revision 1")
// 39:       expect(described_class.stanza_text(:license, 'license "MIT"', indent: 2)).to eq('  license "MIT"')
// 40:       expect(described_class.stanza_text(:license, compound_license, indent: 2)).to eq(compound_license)
// 41:     end
// 42:
// 43:     it "does not add indent if already indented" do
// 44:       expect(described_class.stanza_text(:revision, "  revision 1", indent: 2)).to eq("  revision 1")
// 45:       expect(
// 46:         described_class.stanza_text(:license, compound_license, indent: 2),
// 47:       ).to eq(compound_license)
// 48:     end
// 49:   end
// 50: end
