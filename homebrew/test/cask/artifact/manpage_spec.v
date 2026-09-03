module artifact

import homebrew.cask.artifact as brew_artifact
import os

// Translated from Homebrew/brew `test/cask/artifact/manpage_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ManpageSpecCask {
pub:
	token       string
	staged_path string
	manpagedir  string
	artifacts   []brew_artifact.ManpageArtifact
}

fn load_manpage_spec_cask(token string, staged_path string,
	manpagedir string) !ManpageSpecCask {
	mut artifacts := []brew_artifact.ManpageArtifact{}
	if token == 'invalid-manpage-no-section' {
		artifacts << brew_artifact.manpage_from_args(token, staged_path, manpagedir, 'manpage')!
	} else if token == 'with-autodetected-manpage-section' {
		artifacts << brew_artifact.manpage_from_args(token, staged_path, manpagedir, 'manpage.1')!
		artifacts << brew_artifact.manpage_from_args(token, staged_path, manpagedir, 'gzpage.1.gz')!
	}
	return ManpageSpecCask{
		token: token
		staged_path: staged_path
		manpagedir: manpagedir
		artifacts: artifacts
	}
}

// Ruby let `let(:cask_token) { "basic-cask" }` at line 5.
pub fn ruby_manpage_spec_l5_d1_cask_token() string {
	return 'basic-cask'
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_token) }` at line 6.
pub fn ruby_manpage_spec_l6_d2_cask(token string, staged_path string,
	manpagedir string) !ManpageSpecCask {
	return load_manpage_spec_cask(token, staged_path, manpagedir)
}

// Ruby let `let(:cask_token) { "invalid-manpage-no-section" }` at line 9.
pub fn ruby_manpage_spec_l9_d3_cask_token() string {
	return 'invalid-manpage-no-section'
}

// Ruby it `it "fails to load a cask without section", :no_api do` at line 11.
pub fn ruby_manpage_spec_l11_d4_fails(staged_path string, manpagedir string) bool {
	_ := load_manpage_spec_cask(ruby_manpage_spec_l9_d3_cask_token(), staged_path, manpagedir) or { return err.msg().contains('is not a valid man page name') }
	return false
}

// Ruby let `let(:install_phase) do` at line 17.
pub fn ruby_manpage_spec_l17_d5_install_phase(cask ManpageSpecCask) ! {
	for artifact in cask.artifacts {
		brew_artifact.install_manpage(artifact)!
	}
}

// Ruby let `let(:source_path) { cask.staged_path.join("manpage.1") }` at line 25.
pub fn ruby_manpage_spec_l25_d6_source_path(cask ManpageSpecCask) string {
	return os.join_path(cask.staged_path, 'manpage.1')
}

// Ruby let `let(:target_path) { cask.config.manpagedir.join("man1/manpage.1") }` at line 26.
pub fn ruby_manpage_spec_l26_d7_target_path(cask ManpageSpecCask) string {
	return os.join_path(cask.manpagedir, 'man1', 'manpage.1')
}

// Ruby let `let(:gz_source_path) { cask.staged_path.join("gzpage.1.gz") }` at line 27.
pub fn ruby_manpage_spec_l27_d8_gz_source_path(cask ManpageSpecCask) string {
	return os.join_path(cask.staged_path, 'gzpage.1.gz')
}

// Ruby let `let(:gz_target_path) { cask.config.manpagedir.join("man1/gzpage.1.gz") }` at line 28.
pub fn ruby_manpage_spec_l28_d9_gz_target_path(cask ManpageSpecCask) string {
	return os.join_path(cask.manpagedir, 'man1', 'gzpage.1.gz')
}

// Ruby let `let(:cask_token) { "with-autodetected-manpage-section" }` at line 35.
pub fn ruby_manpage_spec_l35_d10_cask_token() string {
	return 'with-autodetected-manpage-section'
}

// Ruby it `it "links the manpage to the proper directory" do` at line 37.
pub fn ruby_manpage_spec_l37_d11_links(cask ManpageSpecCask) !bool {
	ruby_manpage_spec_l17_d5_install_phase(cask)!
	return os.real_path(ruby_manpage_spec_l26_d7_target_path(cask)) == os.real_path(ruby_manpage_spec_l25_d6_source_path(cask)) && os.real_path(ruby_manpage_spec_l28_d9_gz_target_path(cask)) == os.real_path(ruby_manpage_spec_l27_d8_gz_source_path(cask))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Manpage, :cask do
// 5:   let(:cask_token) { "basic-cask" }
// 6:   let(:cask) { Cask::CaskLoader.load(cask_token) }
// 7:
// 8:   context "without section" do
// 9:     let(:cask_token) { "invalid-manpage-no-section" }
// 10:
// 11:     it "fails to load a cask without section", :no_api do
// 12:       expect { cask }.to raise_error(Cask::CaskInvalidError, /is not a valid man page name/)
// 13:     end
// 14:   end
// 15:
// 16:   context "with install" do
// 17:     let(:install_phase) do
// 18:       lambda do
// 19:         cask.artifacts.grep(described_class).each do |artifact|
// 20:           artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 21:         end
// 22:       end
// 23:     end
// 24:
// 25:     let(:source_path) { cask.staged_path.join("manpage.1") }
// 26:     let(:target_path) { cask.config.manpagedir.join("man1/manpage.1") }
// 27:     let(:gz_source_path) { cask.staged_path.join("gzpage.1.gz") }
// 28:     let(:gz_target_path) { cask.config.manpagedir.join("man1/gzpage.1.gz") }
// 29:
// 30:     before do
// 31:       InstallHelper.install_without_artifacts(cask)
// 32:     end
// 33:
// 34:     context "with autodetected section" do
// 35:       let(:cask_token) { "with-autodetected-manpage-section" }
// 36:
// 37:       it "links the manpage to the proper directory" do
// 38:         install_phase.call
// 39:
// 40:         expect(File).to be_identical target_path, source_path
// 41:         expect(File).to be_identical gz_target_path, gz_source_path
// 42:       end
// 43:     end
// 44:   end
// 45: end
