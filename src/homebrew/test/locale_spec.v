module test

import brew_runtime

// Translated from Homebrew/brew `test/locale_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "parses a string in the correct format" do` at line 8.
pub fn ruby_locale_spec_l8_d1_parses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parses', ...args)
}

// Ruby it `it "correctly parses a string with a UN M.49 region code" do` at line 15.
pub fn ruby_locale_spec_l15_d2_correctly(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('correctly', ...args)
}

// Ruby it `it "an empty string" do` at line 20.
pub fn ruby_locale_spec_l20_d3_an(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('an', ...args)
}

// Ruby it `it "a string in a wrong format" do` at line 24.
pub fn ruby_locale_spec_l24_d4_a(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('a', ...args)
}

// Ruby it `it "raises an ArgumentError when all arguments are nil" do` at line 39.
pub fn ruby_locale_spec_l39_d5_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises a ParserError when one of the arguments does not match the locale format" do` at line 43.
pub fn ruby_locale_spec_l43_d6_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby subject `subject(:locale) { described_class.new("zh", "Hans", "CN") }` at line 51.
pub fn ruby_locale_spec_l51_d7_locale(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locale', ...args)
}

// Ruby specify `specify(:aggregate_failures) do` at line 53.
pub fn ruby_locale_spec_l53_d8_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby subject `subject(:locale) { described_class.new("zh", "Hans", "CN") }` at line 64.
pub fn ruby_locale_spec_l64_d9_locale(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locale', ...args)
}

// Ruby specify `specify(:aggregate_failures) do` at line 67.
pub fn ruby_locale_spec_l67_d10_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby specify `specify(:aggregate_failures) do` at line 74.
pub fn ruby_locale_spec_l74_d11_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby it `it "does not raise if 'other' cannot be parsed" do` at line 83.
pub fn ruby_locale_spec_l83_d12_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:locale_groups) { [["zh"], ["zh-TW"]] }` at line 90.
pub fn ruby_locale_spec_l90_d13_locale_groups(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('locale_groups', ...args)
}

// Ruby it `it "finds best matching language code, independent of order" do` at line 92.
pub fn ruby_locale_spec_l92_d14_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "locale"
// 5:
// 6: RSpec.describe Locale do
// 7:   describe "::parse" do
// 8:     it "parses a string in the correct format" do
// 9:       expect(described_class.parse("zh")).to eql(described_class.new("zh", nil, nil))
// 10:       expect(described_class.parse("zh-CN")).to eql(described_class.new("zh", nil, "CN"))
// 11:       expect(described_class.parse("zh-Hans")).to eql(described_class.new("zh", "Hans", nil))
// 12:       expect(described_class.parse("zh-Hans-CN")).to eql(described_class.new("zh", "Hans", "CN"))
// 13:     end
// 14:
// 15:     it "correctly parses a string with a UN M.49 region code" do
// 16:       expect(described_class.parse("es-419")).to eql(described_class.new("es", nil, "419"))
// 17:     end
// 18:
// 19:     describe "raises a ParserError when given" do
// 20:       it "an empty string" do
// 21:         expect { described_class.parse("") }.to raise_error(Locale::ParserError)
// 22:       end
// 23:
// 24:       it "a string in a wrong format" do
// 25:         expect { described_class.parse("zh-CN-Hans") }.to raise_error(Locale::ParserError)
// 26:         expect { described_class.parse("zh_CN_Hans") }.to raise_error(Locale::ParserError)
// 27:         expect { described_class.parse("zhCNHans") }.to raise_error(Locale::ParserError)
// 28:         expect { described_class.parse("zh-CN_Hans") }.to raise_error(Locale::ParserError)
// 29:         expect { described_class.parse("zhCN") }.to raise_error(Locale::ParserError)
// 30:         expect { described_class.parse("zh_Hans") }.to raise_error(Locale::ParserError)
// 31:         expect { described_class.parse("zh-") }.to raise_error(Locale::ParserError)
// 32:         expect { described_class.parse("ZH-CN") }.to raise_error(Locale::ParserError)
// 33:         expect { described_class.parse("zh-cn") }.to raise_error(Locale::ParserError)
// 34:       end
// 35:     end
// 36:   end
// 37:
// 38:   describe "::new" do
// 39:     it "raises an ArgumentError when all arguments are nil" do
// 40:       expect { described_class.new(nil, nil, nil) }.to raise_error(ArgumentError)
// 41:     end
// 42:
// 43:     it "raises a ParserError when one of the arguments does not match the locale format" do
// 44:       expect { described_class.new("ZH", nil, nil) }.to raise_error(Locale::ParserError)
// 45:       expect { described_class.new(nil, "hans", nil) }.to raise_error(Locale::ParserError)
// 46:       expect { described_class.new(nil, nil, "cn") }.to raise_error(Locale::ParserError)
// 47:     end
// 48:   end
// 49:
// 50:   describe "#include?" do
// 51:     subject(:locale) { described_class.new("zh", "Hans", "CN") }
// 52:
// 53:     specify(:aggregate_failures) do
// 54:       expect(locale).to include("zh")
// 55:       expect(locale).to include("zh-CN")
// 56:       expect(locale).to include("CN")
// 57:       expect(locale).to include("Hans-CN")
// 58:       expect(locale).to include("Hans")
// 59:       expect(locale).to include("zh-Hans-CN")
// 60:     end
// 61:   end
// 62:
// 63:   describe "#eql?" do
// 64:     subject(:locale) { described_class.new("zh", "Hans", "CN") }
// 65:
// 66:     context "when all parts match" do
// 67:       specify(:aggregate_failures) do
// 68:         expect(locale).to eql("zh-Hans-CN")
// 69:         expect(locale).to eql(described_class.new("zh", "Hans", "CN"))
// 70:       end
// 71:     end
// 72:
// 73:     context "when only some parts match" do
// 74:       specify(:aggregate_failures) do
// 75:         expect(locale).not_to eql("zh")
// 76:         expect(locale).not_to eql("zh-CN")
// 77:         expect(locale).not_to eql("CN")
// 78:         expect(locale).not_to eql("Hans-CN")
// 79:         expect(locale).not_to eql("Hans")
// 80:       end
// 81:     end
// 82:
// 83:     it "does not raise if 'other' cannot be parsed" do
// 84:       expect { locale.eql?("zh_CN_Hans") }.not_to raise_error
// 85:       expect(locale.eql?("zh_CN_Hans")).to be false
// 86:     end
// 87:   end
// 88:
// 89:   describe "#detect" do
// 90:     let(:locale_groups) { [["zh"], ["zh-TW"]] }
// 91:
// 92:     it "finds best matching language code, independent of order" do
// 93:       expect(described_class.new("zh", nil, "TW").detect(locale_groups)).to eql(["zh-TW"])
// 94:       expect(described_class.new("zh", nil, "TW").detect(locale_groups.reverse)).to eql(["zh-TW"])
// 95:       expect(described_class.new("zh", "Hans", "CN").detect(locale_groups)).to eql(["zh"])
// 96:     end
// 97:   end
// 98: end
