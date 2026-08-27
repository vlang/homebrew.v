module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/pkg_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-installable")) }` at line 5.
pub fn ruby_pkg_spec_l5_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:fake_system_command) { class_double(SystemCommand) }` at line 6.
pub fn ruby_pkg_spec_l6_d2_fake_system_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fake_system_command', ...args)
}

// Ruby it `it "runs the system installer on the specified pkgs" do` at line 13.
pub fn ruby_pkg_spec_l13_d3_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-choices")) }` at line 35.
pub fn ruby_pkg_spec_l35_d4_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "passes the choice changes xml to the system installer" do` at line 37.
pub fn ruby_pkg_spec_l37_d5_passes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('passes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Pkg, :cask do
// 5:   let(:cask) { Cask::CaskLoader.load(cask_path("with-installable")) }
// 6:   let(:fake_system_command) { class_double(SystemCommand) }
// 7:
// 8:   before do
// 9:     InstallHelper.install_without_artifacts(cask)
// 10:   end
// 11:
// 12:   describe "install_phase" do
// 13:     it "runs the system installer on the specified pkgs" do
// 14:       pkg = cask.artifacts.find { |a| a.is_a?(described_class) }
// 15:
// 16:       current_user = User.current&.to_s
// 17:       expect(fake_system_command).to receive(:run!).with(
// 18:         "/usr/sbin/installer",
// 19:         args:         ["-pkg", cask.staged_path.join("MyFancyPkg", "Fancy.pkg"), "-target", "/"],
// 20:         sudo:         true,
// 21:         sudo_as_root: true,
// 22:         print_stdout: true,
// 23:         env:          {
// 24:           "LOGNAME"  => an_instance_of(String).and(eq(current_user)),
// 25:           "USER"     => an_instance_of(String).and(eq(current_user)),
// 26:           "USERNAME" => an_instance_of(String).and(eq(current_user)),
// 27:         },
// 28:       )
// 29:
// 30:       pkg.install_phase(command: fake_system_command)
// 31:     end
// 32:   end
// 33:
// 34:   describe "choices" do
// 35:     let(:cask) { Cask::CaskLoader.load(cask_path("with-choices")) }
// 36:
// 37:     it "passes the choice changes xml to the system installer" do
// 38:       pkg = cask.artifacts.find { |a| a.is_a?(described_class) }
// 39:
// 40:       file = instance_double(Tempfile, path: Pathname.new("/tmp/choices.xml"))
// 41:
// 42:       expect(file).to receive(:write).with <<~XML
// 43:         <?xml version="1.0" encoding="UTF-8"?>
// 44:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 45:         <plist version="1.0">
// 46:         <array>
// 47:         \t<dict>
// 48:         \t\t<key>attributeSetting</key>
// 49:         \t\t<integer>1</integer>
// 50:         \t\t<key>choiceAttribute</key>
// 51:         \t\t<string>selected</string>
// 52:         \t\t<key>choiceIdentifier</key>
// 53:         \t\t<string>choice1</string>
// 54:         \t</dict>
// 55:         </array>
// 56:         </plist>
// 57:       XML
// 58:
// 59:       expect(file).to receive(:close)
// 60:       expect(file).to receive(:unlink)
// 61:       expect(Tempfile).to receive(:open).and_yield(file)
// 62:
// 63:       current_user = User.current&.to_s
// 64:       expect(fake_system_command).to receive(:run!).with(
// 65:         "/usr/sbin/installer",
// 66:         args:         [
// 67:           "-pkg", cask.staged_path.join("MyFancyPkg", "Fancy.pkg"),
// 68:           "-target", "/", "-applyChoiceChangesXML",
// 69:           cask.staged_path.join("/tmp/choices.xml")
// 70:         ],
// 71:         sudo:         true,
// 72:         sudo_as_root: true,
// 73:         print_stdout: true,
// 74:         env:          {
// 75:           "LOGNAME"  => an_instance_of(String).and(eq(current_user)),
// 76:           "USER"     => an_instance_of(String).and(eq(current_user)),
// 77:           "USERNAME" => an_instance_of(String).and(eq(current_user)),
// 78:         },
// 79:       )
// 80:
// 81:       pkg.install_phase(command: fake_system_command)
// 82:     end
// 83:   end
// 84: end
