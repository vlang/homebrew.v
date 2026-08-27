module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/generated_script_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) do` at line 5.
pub fn ruby_generated_script_spec_l5_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:artifact) { cask.artifacts.find { |candidate| candidate.is_a?(described_class) } }` at line 17.
pub fn ruby_generated_script_spec_l17_d2_artifact(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('artifact', ...args)
}

// Ruby let `let(:path) { cask.staged_path/"installer.sh" }` at line 18.
pub fn ruby_generated_script_spec_l18_d3_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby it `it "writes an executable for another artifact to run" do` at line 22.
pub fn ruby_generated_script_spec_l22_d4_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "serialises the script definition" do` at line 28.
pub fn ruby_generated_script_spec_l28_d5_serialises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialises', ...args)
}

// Ruby it `it "rejects paths outside the staged cask", :aggregate_failures do` at line 35.
pub fn ruby_generated_script_spec_l35_d6_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects a symlinked destination" do` at line 49.
pub fn ruby_generated_script_spec_l49_d7_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects symlinked path components" do` at line 56.
pub fn ruby_generated_script_spec_l56_d8_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::GeneratedScript, :cask do
// 5:   let(:cask) do
// 6:     Cask::Cask.new("with-generated-script") do
// 7:       version "1.2.3"
// 8:       sha256 :no_check
// 9:       url "file://#{TEST_FIXTURE_DIR}/cask/container.zip"
// 10:
// 11:       generated_script "installer.sh", content: <<~SH
// 12:         #!/bin/sh
// 13:         echo installed
// 14:       SH
// 15:     end
// 16:   end
// 17:   let(:artifact) { cask.artifacts.find { |candidate| candidate.is_a?(described_class) } }
// 18:   let(:path) { cask.staged_path/"installer.sh" }
// 19:
// 20:   after { FileUtils.rm_rf cask.staged_path }
// 21:
// 22:   it "writes an executable for another artifact to run" do
// 23:     artifact.install_phase
// 24:
// 25:     expect(path).to exist.and be_executable.and have_attributes(read: "#!/bin/sh\necho installed\n")
// 26:   end
// 27:
// 28:   it "serialises the script definition" do
// 29:     expect(artifact.to_args).to eq([
// 30:       "installer.sh",
// 31:       { content: "#!/bin/sh\necho installed\n" },
// 32:     ])
// 33:   end
// 34:
// 35:   it "rejects paths outside the staged cask", :aggregate_failures do
// 36:     ["/tmp/installer.sh", "../installer.sh"].each do |script_path|
// 37:       expect do
// 38:         Cask::Cask.new("with-outside-generated-script") do
// 39:           version "1.2.3"
// 40:           sha256 :no_check
// 41:           url "file://#{TEST_FIXTURE_DIR}/cask/container.zip"
// 42:
// 43:           generated_script script_path, content: "#!/bin/sh\n"
// 44:         end
// 45:       end.to raise_error(Cask::CaskInvalidError, /within the staged cask/)
// 46:     end
// 47:   end
// 48:
// 49:   it "rejects a symlinked destination" do
// 50:     cask.staged_path.mkpath
// 51:     path.make_symlink(mktmpdir/"outside.sh")
// 52:
// 53:     expect { artifact.install_phase }.to raise_error(Cask::CaskInvalidError, /symlink/)
// 54:   end
// 55:
// 56:   it "rejects symlinked path components" do
// 57:     cask.staged_path.mkpath
// 58:     (cask.staged_path/"linked").make_symlink(mktmpdir)
// 59:     linked_artifact = described_class.from_args(cask, "linked/installer.sh", content: "#!/bin/sh\n")
// 60:
// 61:     expect { linked_artifact.install_phase }.to raise_error(Cask::CaskInvalidError, /symlink/)
// 62:   end
// 63: end
