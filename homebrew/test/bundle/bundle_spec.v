module bundle

import brew_runtime

// Translated from Homebrew/brew `test/bundle/bundle_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "omits all stdout output if verbose is false" do` at line 9.
pub fn ruby_bundle_spec_l9_d1_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "emits all stdout output if verbose is true" do` at line 13.
pub fn ruby_bundle_spec_l13_d2_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits all stdout output even if verbose is false" do` at line 19.
pub fn ruby_bundle_spec_l19_d3_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits all stdout output only once if verbose is true" do` at line 26.
pub fn ruby_bundle_spec_l26_d4_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "finds it when present" do` at line 35.
pub fn ruby_bundle_spec_l35_d5_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby subject `subject(:mark_installed!) { described_class.mark_as_installed_on_request!(entries) }` at line 45.
pub fn ruby_bundle_spec_l45_d6_mark_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mark_installed!', ...args)
}

// Ruby let `let(:brewfile_content) { "brew 'myformula'" }` at line 47.
pub fn ruby_bundle_spec_l47_d7_brewfile_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brewfile_content', ...args)
}

// Ruby let `let(:entries) { dsl.entries }` at line 48.
pub fn ruby_bundle_spec_l48_d8_entries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('entries', ...args)
}

// Ruby let `let(:dsl) { Homebrew::Bundle::Dsl.new(Pathname.new("/fake/Brewfile")) }` at line 49.
pub fn ruby_bundle_spec_l49_d9_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dsl', ...args)
}

// Ruby let `let(:tabfile) { Pathname.new("/fake/INSTALL_RECEIPT.json") }` at line 50.
pub fn ruby_bundle_spec_l50_d10_tabfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tabfile', ...args)
}

// Ruby let `let(:tab) { instance_double(Tab, installed_on_request: false, tabfile:) }` at line 59.
pub fn ruby_bundle_spec_l59_d11_tab(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tab', ...args)
}

// Ruby it `it "sets installed_on_request=true and writes" do` at line 66.
pub fn ruby_bundle_spec_l66_d12_sets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sets', ...args)
}

// Ruby let `let(:brewfile_content) { "brew 'notinstalled'" }` at line 74.
pub fn ruby_bundle_spec_l74_d13_brewfile_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brewfile_content', ...args)
}

// Ruby it `it "skips the formula" do` at line 80.
pub fn ruby_bundle_spec_l80_d14_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby let `let(:brewfile_content) { "brew 'alreadymarked'" }` at line 87.
pub fn ruby_bundle_spec_l87_d15_brewfile_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brewfile_content', ...args)
}

// Ruby let `let(:tab) { instance_double(Tab, installed_on_request: true, tabfile:) }` at line 88.
pub fn ruby_bundle_spec_l88_d16_tab(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tab', ...args)
}

// Ruby it `it "skips writing" do` at line 95.
pub fn ruby_bundle_spec_l95_d17_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6:
// 7: RSpec.describe Homebrew::Bundle do
// 8:   context "when the system call succeeds" do
// 9:     it "omits all stdout output if verbose is false" do
// 10:       expect { described_class.system "echo", "foo", verbose: false }.not_to output.to_stdout_from_any_process
// 11:     end
// 12:
// 13:     it "emits all stdout output if verbose is true" do
// 14:       expect { described_class.system "echo", "foo", verbose: true }.to output("foo\n").to_stdout_from_any_process
// 15:     end
// 16:   end
// 17:
// 18:   context "when the system call fails" do
// 19:     it "emits all stdout output even if verbose is false" do
// 20:       expect do
// 21:         described_class.system "/bin/bash", "-c", "echo foo && false",
// 22:                                verbose: false
// 23:       end.to output("foo\n").to_stdout_from_any_process
// 24:     end
// 25:
// 26:     it "emits all stdout output only once if verbose is true" do
// 27:       expect do
// 28:         described_class.system "/bin/bash", "-c", "echo foo && true",
// 29:                                verbose: true
// 30:       end.to output("foo\n").to_stdout_from_any_process
// 31:     end
// 32:   end
// 33:
// 34:   context "when checking for homebrew/cask", :needs_macos do
// 35:     it "finds it when present" do
// 36:       allow(File).to receive(:directory?).with("#{HOMEBREW_PREFIX}/Caskroom").and_return(true)
// 37:       allow(File).to receive(:directory?)
// 38:         .with("#{HOMEBREW_LIBRARY}/Taps/homebrew/homebrew-cask")
// 39:         .and_return(true)
// 40:       expect(described_class.cask_installed?).to be(true)
// 41:     end
// 42:   end
// 43:
// 44:   describe ".mark_as_installed_on_request!", :no_api do
// 45:     subject(:mark_installed!) { described_class.mark_as_installed_on_request!(entries) }
// 46:
// 47:     let(:brewfile_content) { "brew 'myformula'" }
// 48:     let(:entries) { dsl.entries }
// 49:     let(:dsl) { Homebrew::Bundle::Dsl.new(Pathname.new("/fake/Brewfile")) }
// 50:     let(:tabfile) { Pathname.new("/fake/INSTALL_RECEIPT.json") }
// 51:
// 52:     before do
// 53:       allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 54:       allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_content)
// 55:       allow(tabfile).to receive_messages(blank?: false, exist?: true)
// 56:     end
// 57:
// 58:     context "when formula is installed but not marked as installed_on_request" do
// 59:       let(:tab) { instance_double(Tab, installed_on_request: false, tabfile:) }
// 60:
// 61:       before do
// 62:         allow(Formula).to receive(:installed_formula_names).and_return(["myformula"])
// 63:         allow(Tab).to receive(:for_name).with("myformula").and_return(tab)
// 64:       end
// 65:
// 66:       it "sets installed_on_request=true and writes" do
// 67:         expect(tab).to receive(:installed_on_request=).with(true)
// 68:         expect(tab).to receive(:write)
// 69:         mark_installed!
// 70:       end
// 71:     end
// 72:
// 73:     context "when formula is not installed" do
// 74:       let(:brewfile_content) { "brew 'notinstalled'" }
// 75:
// 76:       before do
// 77:         allow(Formula).to receive(:installed_formula_names).and_return([])
// 78:       end
// 79:
// 80:       it "skips the formula" do
// 81:         expect(Tab).not_to receive(:for_name)
// 82:         mark_installed!
// 83:       end
// 84:     end
// 85:
// 86:     context "when formula is already marked as installed_on_request" do
// 87:       let(:brewfile_content) { "brew 'alreadymarked'" }
// 88:       let(:tab) { instance_double(Tab, installed_on_request: true, tabfile:) }
// 89:
// 90:       before do
// 91:         allow(Formula).to receive(:installed_formula_names).and_return(["alreadymarked"])
// 92:         allow(Tab).to receive(:for_name).with("alreadymarked").and_return(tab)
// 93:       end
// 94:
// 95:       it "skips writing" do
// 96:         expect(tab).not_to receive(:installed_on_request=)
// 97:         expect(tab).not_to receive(:write)
// 98:         mark_installed!
// 99:       end
// 100:     end
// 101:   end
// 102: end
