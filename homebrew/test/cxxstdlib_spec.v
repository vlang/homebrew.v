module test

import homebrew

// Translated from Homebrew/brew `test/cxxstdlib_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:clang) { described_class.create(:libstdcxx, :clang) }` at line 8.
pub fn ruby_cxxstdlib_spec_l8_d1_clang() !homebrew.CxxStdlib {
	return homebrew.create_cxxstdlib('libstdcxx', 'clang')
}

// Ruby let `let(:lcxx) { described_class.create(:libcxx, :clang) }` at line 9.
pub fn ruby_cxxstdlib_spec_l9_d2_lcxx() !homebrew.CxxStdlib {
	return homebrew.create_cxxstdlib('libcxx', 'clang')
}

// Ruby specify `specify "formatting" do` at line 12.
pub fn ruby_cxxstdlib_spec_l12_d3_formatting() !bool {
	return ruby_cxxstdlib_spec_l8_d1_clang()!.type_string() == 'libstdc++' && ruby_cxxstdlib_spec_l9_d2_lcxx()!.type_string() == 'libc++'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "cxxstdlib"
// 6:
// 7: RSpec.describe CxxStdlib do
// 8:   let(:clang) { described_class.create(:libstdcxx, :clang) }
// 9:   let(:lcxx) { described_class.create(:libcxx, :clang) }
// 10:
// 11:   describe "#type_string" do
// 12:     specify "formatting" do
// 13:       expect(clang.type_string).to eq("libstdc++")
// 14:       expect(lcxx.type_string).to eq("libc++")
// 15:     end
// 16:   end
// 17: end
