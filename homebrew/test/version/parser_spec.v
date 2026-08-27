module version

import brew_runtime

// Translated from Homebrew/brew `test/version/parser_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify "::new" do` at line 7.
pub fn ruby_parser_spec_l7_d1_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::new', ...args)
}

// Ruby specify `specify "::new" do` at line 13.
pub fn ruby_parser_spec_l13_d2_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::new', ...args)
}

// Ruby specify `specify "::process_spec" do` at line 18.
pub fn ruby_parser_spec_l18_d3_process_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::process_spec', ...args)
}

// Ruby specify `specify "::new" do` at line 26.
pub fn ruby_parser_spec_l26_d4_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::new', ...args)
}

// Ruby specify `specify "::process_spec" do` at line 30.
pub fn ruby_parser_spec_l30_d5_process_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::process_spec', ...args)
}

// Ruby specify `specify "::new" do` at line 49.
pub fn ruby_parser_spec_l49_d6_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::new', ...args)
}

// Ruby it `it "works with SourceForge URLs with /download suffix" do` at line 54.
pub fn ruby_parser_spec_l54_d7_works(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('works', ...args)
}

// Ruby it `it "works with URLs without file extension" do` at line 62.
pub fn ruby_parser_spec_l62_d8_works(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('works', ...args)
}

// Ruby it `it "works with URLs with file extension" do` at line 66.
pub fn ruby_parser_spec_l66_d9_works(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('works', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "version/parser"
// 5:
// 6: RSpec.describe Version::Parser do
// 7:   specify "::new" do
// 8:     expect { described_class.new }
// 9:       .to raise_error("Version::Parser is declared as abstract; it cannot be instantiated")
// 10:   end
// 11:
// 12:   describe Version::RegexParser do
// 13:     specify "::new" do
// 14:       expect { described_class.new(/[._-](\d+(?:\.\d+)+)/) }
// 15:         .to raise_error("Version::RegexParser is declared as abstract; it cannot be instantiated")
// 16:     end
// 17:
// 18:     specify "::process_spec" do
// 19:       expect { described_class.process_spec(Pathname(TEST_TMPDIR)) }
// 20:         .to raise_error(NotImplementedError,
// 21:                         "Version::RegexParser.process_spec must be implemented for #{TEST_TMPDIR}")
// 22:     end
// 23:   end
// 24:
// 25:   describe Version::UrlParser do
// 26:     specify "::new" do
// 27:       expect { described_class.new(/[._-](\d+(?:\.\d+)+)/) }.not_to raise_error
// 28:     end
// 29:
// 30:     specify "::process_spec" do
// 31:       expect(described_class.process_spec(Pathname("#{TEST_TMPDIR}/testdir-0.1.test")))
// 32:         .to eq("#{TEST_TMPDIR}/testdir-0.1.test")
// 33:
// 34:       expect(described_class.process_spec(Pathname("https://sourceforge.net/foo_bar-1.21.tar.gz/download")))
// 35:         .to eq("https://sourceforge.net/foo_bar-1.21.tar.gz/download")
// 36:
// 37:       expect(described_class.process_spec(Pathname("https://sf.net/foo_bar-1.21.tar.gz/download")))
// 38:         .to eq("https://sf.net/foo_bar-1.21.tar.gz/download")
// 39:
// 40:       expect(described_class.process_spec(Pathname("https://brew.sh/testball-0.1")))
// 41:         .to eq("https://brew.sh/testball-0.1")
// 42:
// 43:       expect(described_class.process_spec(Pathname("https://brew.sh/testball-0.1.tgz")))
// 44:         .to eq("https://brew.sh/testball-0.1.tgz")
// 45:     end
// 46:   end
// 47:
// 48:   describe Version::StemParser do
// 49:     specify "::new" do
// 50:       expect { described_class.new(/[._-](\d+(?:\.\d+)+)/) }.not_to raise_error
// 51:     end
// 52:
// 53:     describe "::process_spec" do
// 54:       it "works with SourceForge URLs with /download suffix" do
// 55:         expect(described_class.process_spec(Pathname("https://sourceforge.net/foo_bar-1.21.tar.gz/download")))
// 56:           .to eq("foo_bar-1.21")
// 57:
// 58:         expect(described_class.process_spec(Pathname("https://sf.net/foo_bar-1.21.tar.gz/download")))
// 59:           .to eq("foo_bar-1.21")
// 60:       end
// 61:
// 62:       it "works with URLs without file extension" do
// 63:         expect(described_class.process_spec(Pathname("https://brew.sh/testball-0.1"))).to eq("testball-0.1")
// 64:       end
// 65:
// 66:       it "works with URLs with file extension" do
// 67:         expect(described_class.process_spec(Pathname("https://brew.sh/testball-0.1.tgz"))).to eq("testball-0.1")
// 68:       end
// 69:     end
// 70:   end
// 71: end
