module bundle

import brew_runtime

// Translated from Homebrew/brew `test/bundle/dumper_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:dumper) { described_class }` at line 10.
pub fn ruby_dumper_spec_l10_d1_dumper(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dumper', ...args)
}

// Ruby it `it "generates output" do` at line 50.
pub fn ruby_dumper_spec_l50_d2_generates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generates', ...args)
}

// Ruby it `it "dumps tap trust entries not represented by dumped formulae" do` at line 57.
pub fn ruby_dumper_spec_l57_d3_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dumps', ...args)
}

// Ruby it `it "determines the brewfile correctly" do` at line 94.
pub fn ruby_dumper_spec_l94_d4_determines(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('determines', ...args)
}

// Ruby it `it "preserves the legacy extension dump order" do` at line 98.
pub fn ruby_dumper_spec_l98_d5_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dumper"
// 6: require "bundle/brew_services"
// 7: require "cask"
// 8:
// 9: RSpec.describe Homebrew::Bundle::Dumper do
// 10:   subject(:dumper) { described_class }
// 11:
// 12:   before do
// 13:     ENV["HOMEBREW_BUNDLE_FILE"] = ""
// 14:
// 15:     allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 16:     allow(Homebrew::Bundle::MacAppStore).to receive(:package_manager_executable).and_return(nil)
// 17:     allow(Homebrew::Bundle::Winget).to receive(:package_manager_executable).and_return(nil)
// 18:     allow(Homebrew::Bundle::VscodeExtension).to receive(:package_manager_executable).and_return(nil)
// 19:     Homebrew::Bundle::Brew.reset!
// 20:     Homebrew::Bundle::Tap.reset!
// 21:     Homebrew::Bundle::Cask.reset!
// 22:     Homebrew::Bundle::MacAppStore.reset!
// 23:     Homebrew::Bundle::Winget.reset!
// 24:     Homebrew::Bundle::VscodeExtension.reset!
// 25:     Homebrew::Bundle::Go.reset!
// 26:     Homebrew::Bundle::Cargo.reset!
// 27:     Homebrew::Bundle::Uv.reset!
// 28:     Homebrew::Bundle::Brew::Services.reset!
// 29:
// 30:     chrome     = instance_double(Cask::Cask,
// 31:                                  full_name: "google-chrome",
// 32:                                  to_s:      "google-chrome",
// 33:                                  config:    nil)
// 34:     java       = instance_double(Cask::Cask,
// 35:                                  full_name: "java",
// 36:                                  to_s:      "java",
// 37:                                  config:    nil)
// 38:     iterm2beta = instance_double(Cask::Cask,
// 39:                                  full_name: "homebrew/cask-versions/iterm2-beta",
// 40:                                  to_s:      "iterm2-beta",
// 41:                                  config:    nil)
// 42:
// 43:     allow(Cask::Caskroom).to receive(:casks).and_return([chrome, java, iterm2beta])
// 44:     allow(Homebrew::Bundle::Go).to receive_messages(package_manager_executable: nil, "`": "")
// 45:     allow(Homebrew::Bundle::Cargo).to receive_messages(package_manager_executable: nil, "`": "")
// 46:     allow(Homebrew::Bundle::Uv).to receive_messages(package_manager_executable: nil, "`": "")
// 47:     allow(Tap).to receive(:select).and_return([])
// 48:   end
// 49:
// 50:   it "generates output" do
// 51:     expect(dumper.build_brewfile(
// 52:              describe: false, no_restart: false, formulae: true, taps: true, casks: true,
// 53:              extension_types: { mas: true, vscode: true, cargo: true, flatpak: false, go: true, uv: true }
// 54:            )).to eql("cask \"google-chrome\"\ncask \"java\"\ncask \"homebrew/cask-versions/iterm2-beta\"\n")
// 55:   end
// 56:
// 57:   it "dumps tap trust entries not represented by dumped formulae" do
// 58:     tap = instance_double(Tap, name: "thirdparty/tap", custom_remote?: false, remote: nil)
// 59:     allow(tap).to receive(:matches_reference?) { |reference| reference == "thirdparty/tap" }
// 60:     allow(Tap).to receive(:select).and_return([tap])
// 61:     allow(Homebrew::Bundle::Brew).to receive(:formulae).and_return([
// 62:       {
// 63:         args:                  [],
// 64:         full_name:             "thirdparty/tap/requested",
// 65:         installed_on_request?: true,
// 66:         link?:                 nil,
// 67:       },
// 68:       {
// 69:         args:                  [],
// 70:         full_name:             "thirdparty/tap/dependency",
// 71:         installed_on_request?: false,
// 72:         link?:                 nil,
// 73:       },
// 74:     ])
// 75:     allow(Homebrew::Bundle::Brew::Services).to receive(:started?).and_return(false)
// 76:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:tap).and_return([])
// 77:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:formula)
// 78:                                                        .and_return(%w[
// 79:                                                          thirdparty/tap/dependency
// 80:                                                          thirdparty/tap/requested
// 81:                                                        ])
// 82:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:cask).and_return([])
// 83:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:command).and_return([])
// 84:
// 85:     expect(dumper.build_brewfile(
// 86:              describe: false, no_restart: false, formulae: true, taps: true, casks: false,
// 87:              extension_types: {}
// 88:            )).to eql(<<~BREWFILE)
// 89:              tap "thirdparty/tap", trusted: { formulae: ["dependency"] }
// 90:              brew "thirdparty/tap/requested", trusted: true
// 91:            BREWFILE
// 92:   end
// 93:
// 94:   it "determines the brewfile correctly" do
// 95:     expect(dumper.brewfile_path).to eql(Pathname.new(Dir.pwd).join("Brewfile"))
// 96:   end
// 97:
// 98:   it "preserves the legacy extension dump order" do
// 99:     allow(Homebrew::Bundle::Winget).to receive(:dump)
// 100:       .and_return('winget "PowerToys", id: "XP89DCGQ3K6VLD", source: "msstore"')
// 101:     allow(Homebrew::Bundle::Go).to receive(:dump).and_return('go "github.com/charmbracelet/crush"')
// 102:     allow(Homebrew::Bundle::Cargo).to receive(:dump).and_return('cargo "ripgrep"')
// 103:     allow(Homebrew::Bundle::Uv).to receive(:dump).and_return('uv "mkdocs"')
// 104:     allow(Homebrew::Bundle::Flatpak).to receive(:dump).and_return('flatpak "org.gnome.Calculator"')
// 105:
// 106:     expect(dumper.build_brewfile(
// 107:              describe: false, no_restart: false, formulae: false, taps: false, casks: false,
// 108:              extension_types: { mas: false, winget: true, vscode: false, cargo: true, flatpak: true, go: true,
// 109:                                 uv: true }
// 110:            )).to eql(<<~BREWFILE)
// 111:              go "github.com/charmbracelet/crush"
// 112:              cargo "ripgrep"
// 113:              uv "mkdocs"
// 114:              flatpak "org.gnome.Calculator"
// 115:              winget "PowerToys", id: "XP89DCGQ3K6VLD", source: "msstore"
// 116:            BREWFILE
// 117:   end
// 118: end
