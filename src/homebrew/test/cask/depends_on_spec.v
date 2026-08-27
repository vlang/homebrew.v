module cask

import brew_runtime

// Translated from Homebrew/brew `test/cask/depends_on_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:install) do` at line 9.
pub fn ruby_depends_on_spec_l9_d1_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-cask")) }` at line 13.
pub fn ruby_depends_on_spec_l13_d2_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:dependency) { Cask::CaskLoader.load(cask.depends_on.cask.first) }` at line 16.
pub fn ruby_depends_on_spec_l16_d3_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependency', ...args)
}

// Ruby it `it "installs the dependency of a Cask and the Cask itself" do` at line 18.
pub fn ruby_depends_on_spec_l18_d4_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installs', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-cask-cyclic")) }` at line 25.
pub fn ruby_depends_on_spec_l25_d5_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it {` at line 27.
pub fn ruby_depends_on_spec_l27_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-array")) }` at line 39.
pub fn ruby_depends_on_spec_l39_d7_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "does not raise an error" do` at line 41.
pub fn ruby_depends_on_spec_l41_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-comparison")) }` at line 47.
pub fn ruby_depends_on_spec_l47_d9_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "does not raise an error" do` at line 49.
pub fn ruby_depends_on_spec_l49_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-symbol")) }` at line 55.
pub fn ruby_depends_on_spec_l55_d11_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "does not raise an error" do` at line 57.
pub fn ruby_depends_on_spec_l57_d12_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-failure")) }` at line 63.
pub fn ruby_depends_on_spec_l63_d13_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "raises an error" do` at line 65.
pub fn ruby_depends_on_spec_l65_d14_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-arch")) }` at line 74.
pub fn ruby_depends_on_spec_l74_d15_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "does not raise an error" do` at line 76.
pub fn ruby_depends_on_spec_l76_d16_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: # TODO: this test should be named after the corresponding class, once
// 5: #       that class is abstracted from installer.rb
// 6: # rubocop:disable RSpec/DescribeClass
// 7: RSpec.describe "Satisfy Dependencies and Requirements", :cask do
// 8:   # rubocop:enable RSpec/DescribeClass
// 9:   subject(:install) do
// 10:     Cask::Installer.new(cask).install
// 11:   end
// 12:
// 13:   let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-cask")) }
// 14:
// 15:   describe "depends_on cask" do
// 16:     let(:dependency) { Cask::CaskLoader.load(cask.depends_on.cask.first) }
// 17:
// 18:     it "installs the dependency of a Cask and the Cask itself" do
// 19:       expect { install }.not_to raise_error
// 20:       expect(cask).to be_installed
// 21:       expect(dependency).to be_installed
// 22:     end
// 23:
// 24:     context "when depends_on cask is cyclic" do
// 25:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-cask-cyclic")) }
// 26:
// 27:       it {
// 28:         expect { install }.to raise_error(
// 29:           Cask::CaskCyclicDependencyError,
// 30:           "Cask 'with-depends-on-cask-cyclic' includes cyclic dependencies " \
// 31:           "on other Casks: with-depends-on-cask-cyclic-helper",
// 32:         )
// 33:       }
// 34:     end
// 35:   end
// 36:
// 37:   describe "depends_on macos" do
// 38:     context "with an array" do
// 39:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-array")) }
// 40:
// 41:       it "does not raise an error" do
// 42:         expect { install }.not_to raise_error
// 43:       end
// 44:     end
// 45:
// 46:     context "with a comparison" do
// 47:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-comparison")) }
// 48:
// 49:       it "does not raise an error" do
// 50:         expect { install }.not_to raise_error
// 51:       end
// 52:     end
// 53:
// 54:     context "with a symbol" do
// 55:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-symbol")) }
// 56:
// 57:       it "does not raise an error" do
// 58:         expect { install }.not_to raise_error
// 59:       end
// 60:     end
// 61:
// 62:     context "when not satisfied" do
// 63:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-failure")) }
// 64:
// 65:       it "raises an error" do
// 66:         allow(OS::Mac).to receive(:version).and_return(MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED))
// 67:         expect { install }.to raise_error(Cask::CaskError)
// 68:       end
// 69:     end
// 70:   end
// 71:
// 72:   describe "depends_on arch" do
// 73:     context "when satisfied" do
// 74:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-arch")) }
// 75:
// 76:       it "does not raise an error" do
// 77:         expect { install }.not_to raise_error
// 78:       end
// 79:     end
// 80:   end
// 81: end
