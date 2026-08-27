module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/abstract_artifact_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "includes generated and platform-specific artifacts" do` at line 6.
pub fn ruby_abstract_artifact_spec_l6_d1_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby let `let(:stanza) { :installer }` at line 27.
pub fn ruby_abstract_artifact_spec_l27_d2_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stanza', ...args)
}

// Ruby it `it "accepts a string and uses it as the executable" do` at line 29.
pub fn ruby_abstract_artifact_spec_l29_d3_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts a hash with an executable" do` at line 35.
pub fn ruby_abstract_artifact_spec_l35_d4_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "does not mutate the original arguments in place" do` at line 41.
pub fn ruby_abstract_artifact_spec_l41_d5_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::AbstractArtifact, :cask do
// 5:   describe "#sort_order" do
// 6:     it "includes generated and platform-specific artifacts" do
// 7:       sort_order = Cask::Artifact::App.allocate.sort_order
// 8:
// 9:       expect(sort_order).to include(
// 10:         Cask::Artifact::CommandWrapper,
// 11:         Cask::Artifact::GeneratedScript,
// 12:         Cask::Artifact::PreflightSteps,
// 13:         Cask::Artifact::PostflightSteps,
// 14:         Cask::Artifact::UninstallPreflightSteps,
// 15:         Cask::Artifact::UninstallPostflightSteps,
// 16:       )
// 17:       expect(sort_order.fetch(Cask::Artifact::AppImage)).to eq(sort_order.fetch(Cask::Artifact::App))
// 18:       expect(sort_order.fetch(Cask::Artifact::GeneratedCompletion))
// 19:         .to be_between(
// 20:           sort_order.fetch(Cask::Artifact::ZshCompletion),
// 21:           sort_order.fetch(Cask::Artifact::PostflightSteps),
// 22:         ).exclusive
// 23:     end
// 24:   end
// 25:
// 26:   describe ".read_script_arguments" do
// 27:     let(:stanza) { :installer }
// 28:
// 29:     it "accepts a string and uses it as the executable" do
// 30:       arguments = "something"
// 31:
// 32:       expect(described_class.read_script_arguments(arguments, stanza)).to eq(["something", {}])
// 33:     end
// 34:
// 35:     it "accepts a hash with an executable" do
// 36:       arguments = { executable: "something" }
// 37:
// 38:       expect(described_class.read_script_arguments(arguments, stanza)).to eq(["something", {}])
// 39:     end
// 40:
// 41:     it "does not mutate the original arguments in place" do
// 42:       arguments = { executable: "something" }
// 43:       clone = arguments.dup
// 44:
// 45:       described_class.read_script_arguments(arguments, stanza)
// 46:
// 47:       expect(arguments).to eq(clone)
// 48:     end
// 49:   end
// 50: end
