module cask_loader

import brew_runtime

// Translated from Homebrew/brew `test/cask/cask_loader/from_tap_loader_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:tap) { CoreCaskTap.instance }` at line 5.
pub fn ruby_from_tap_loader_spec_l5_d1_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby let `let(:cask_name) { "testball" }` at line 6.
pub fn ruby_from_tap_loader_spec_l6_d2_cask_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_name', ...args)
}

// Ruby let `let(:cask_full_name) { "homebrew/cask/#{cask_name}" }` at line 7.
pub fn ruby_from_tap_loader_spec_l7_d3_cask_full_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_full_name', ...args)
}

// Ruby let `let(:cask_path) { tap.cask_dir/"#{cask_name}.rb" }` at line 8.
pub fn ruby_from_tap_loader_spec_l8_d4_cask_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_path', ...args)
}

// Ruby it `it "returns a Cask" do` at line 20.
pub fn ruby_from_tap_loader_spec_l20_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "raises an error if the Cask cannot be found" do` at line 24.
pub fn ruby_from_tap_loader_spec_l24_d6_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby let `let(:cask_path) { tap.cask_dir/cask_name[0]/"#{cask_name}.rb" }` at line 29.
pub fn ruby_from_tap_loader_spec_l29_d7_cask_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_path', ...args)
}

// Ruby it `it "returns a Cask" do` at line 31.
pub fn ruby_from_tap_loader_spec_l31_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::CaskLoader::FromTapLoader do
// 5:   let(:tap) { CoreCaskTap.instance }
// 6:   let(:cask_name) { "testball" }
// 7:   let(:cask_full_name) { "homebrew/cask/#{cask_name}" }
// 8:   let(:cask_path) { tap.cask_dir/"#{cask_name}.rb" }
// 9:
// 10:   describe "#load" do
// 11:     before do
// 12:       cask_path.parent.mkpath
// 13:       cask_path.write <<~RUBY
// 14:         cask '#{cask_name}' do
// 15:           url 'https://brew.sh/'
// 16:         end
// 17:       RUBY
// 18:     end
// 19:
// 20:     it "returns a Cask" do
// 21:       expect(described_class.new(cask_full_name).load(config: nil)).to be_a(Cask::Cask)
// 22:     end
// 23:
// 24:     it "raises an error if the Cask cannot be found" do
// 25:       expect { described_class.new("foo/bar/baz").load(config: nil) }.to raise_error(Cask::CaskUnavailableError)
// 26:     end
// 27:
// 28:     context "with sharded Cask directory", :no_api do
// 29:       let(:cask_path) { tap.cask_dir/cask_name[0]/"#{cask_name}.rb" }
// 30:
// 31:       it "returns a Cask" do
// 32:         expect(described_class.new(cask_full_name).load(config: nil)).to be_a(Cask::Cask)
// 33:       end
// 34:     end
// 35:   end
// 36: end
