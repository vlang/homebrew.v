module linux

import brew_runtime

// Translated from Homebrew/brew `test/os/linux/libstdcxx_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns false when system version matches CI version" do` at line 8.
pub fn ruby_libstdcxx_spec_l8_d1_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true when system version cannot be detected" do` at line 13.
pub fn ruby_libstdcxx_spec_l13_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:tmpdir) { mktmpdir }` at line 20.
pub fn ruby_libstdcxx_spec_l20_d3_tmpdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tmpdir', ...args)
}

// Ruby let `let(:libstdcxx) { tmpdir/OS::Linux::Libstdcxx::SONAME }` at line 21.
pub fn ruby_libstdcxx_spec_l21_d4_libstdcxx(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('libstdcxx', ...args)
}

// Ruby let `let(:soversion) { Version.new(OS::Linux::Libstdcxx::SOVERSION.to_s) }` at line 22.
pub fn ruby_libstdcxx_spec_l22_d5_soversion(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('soversion', ...args)
}

// Ruby it `it "returns NULL when unable to find system path" do` at line 34.
pub fn ruby_libstdcxx_spec_l34_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns full version from filename" do` at line 39.
pub fn ruby_libstdcxx_spec_l39_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns major version when non-standard libstdc++ filename without full version" do` at line 47.
pub fn ruby_libstdcxx_spec_l47_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns major version when non-standard libstdc++ filename with unexpected realpath" do` at line 52.
pub fn ruby_libstdcxx_spec_l52_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/linux/libstdcxx"
// 5:
// 6: RSpec.describe OS::Linux::Libstdcxx do
// 7:   describe "::below_ci_version?" do
// 8:     it "returns false when system version matches CI version" do
// 9:       allow(described_class).to receive(:system_version).and_return(Version.new(OS::LINUX_LIBSTDCXX_CI_VERSION))
// 10:       expect(described_class.below_ci_version?).to be false
// 11:     end
// 12:
// 13:     it "returns true when system version cannot be detected" do
// 14:       allow(described_class).to receive(:system_version).and_return(Version::NULL)
// 15:       expect(described_class.below_ci_version?).to be true
// 16:     end
// 17:   end
// 18:
// 19:   describe "::system_version" do
// 20:     let(:tmpdir) { mktmpdir }
// 21:     let(:libstdcxx) { tmpdir/OS::Linux::Libstdcxx::SONAME }
// 22:     let(:soversion) { Version.new(OS::Linux::Libstdcxx::SOVERSION.to_s) }
// 23:
// 24:     before do
// 25:       tmpdir.mkpath
// 26:       described_class.system_version = nil
// 27:       allow(described_class).to receive(:system_path).and_return(libstdcxx)
// 28:     end
// 29:
// 30:     after do
// 31:       FileUtils.rm_rf(tmpdir)
// 32:     end
// 33:
// 34:     it "returns NULL when unable to find system path" do
// 35:       allow(described_class).to receive(:system_path).and_return(nil)
// 36:       expect(described_class.system_version).to be Version::NULL
// 37:     end
// 38:
// 39:     it "returns full version from filename" do
// 40:       full_version = Version.new("#{soversion}.0.999")
// 41:       libstdcxx_real = libstdcxx.sub_ext(".#{full_version}")
// 42:       FileUtils.touch libstdcxx_real
// 43:       FileUtils.ln_s libstdcxx_real, libstdcxx
// 44:       expect(described_class.system_version).to eq full_version
// 45:     end
// 46:
// 47:     it "returns major version when non-standard libstdc++ filename without full version" do
// 48:       FileUtils.touch libstdcxx
// 49:       expect(described_class.system_version).to eq soversion
// 50:     end
// 51:
// 52:     it "returns major version when non-standard libstdc++ filename with unexpected realpath" do
// 53:       libstdcxx_real = tmpdir/"libstdc++.so.real"
// 54:       FileUtils.touch libstdcxx_real
// 55:       FileUtils.ln_s libstdcxx_real, libstdcxx
// 56:       expect(described_class.system_version).to eq soversion
// 57:     end
// 58:   end
// 59: end
