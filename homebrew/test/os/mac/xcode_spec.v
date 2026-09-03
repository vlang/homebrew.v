module mac

import homebrew.os.mac as xcode

// Translated from Homebrew/brew `test/os/mac/xcode_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "loads Plist when version.plist exists" do` at line 8.
pub fn ruby_xcode_spec_l8_d1_loads() bool {
	plist := '<?xml version="1.0" encoding="UTF-8"?>\n<plist version="1.0"><dict><key>CFBundleShortVersionString</key><string>26.3</string></dict></plist>'
	return xcode.xcode_detect_version(true, false, plist, []string{}, '') == '26.3'
}

// Ruby it `it "recommends Software Update on prerelease macOS" do` at line 29.
pub fn ruby_xcode_spec_l29_d2_recommends() bool {
	reinstall := xcode.clt_reinstall_instructions('show you any updates', '26.3')
	return xcode.clt_update_instructions('27', reinstall).contains('Update them from Software Update in System Settings.')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/xcode"
// 5:
// 6: RSpec.describe OS::Mac::Xcode, :needs_macos do
// 7:   describe ".detect_version" do
// 8:     it "loads Plist when version.plist exists" do
// 9:       contents = mktmpdir/"Contents"
// 10:       contents.mkpath
// 11:       (contents/"version.plist").write <<~XML
// 12:         <?xml version="1.0" encoding="UTF-8"?>
// 13:         <plist version="1.0">
// 14:           <dict>
// 15:             <key>CFBundleShortVersionString</key>
// 16:             <string>26.3</string>
// 17:           </dict>
// 18:         </plist>
// 19:       XML
// 20:       allow(described_class).to receive_messages(installed?: true, prefix: contents/"Developer")
// 21:       allow(OS::Mac::CLT).to receive(:installed?).and_return(false)
// 22:
// 23:       expect(described_class.detect_version).to eq("26.3")
// 24:     end
// 25:   end
// 26:
// 27:   describe OS::Mac::CLT do
// 28:     describe ".update_instructions" do
// 29:       it "recommends Software Update on prerelease macOS" do
// 30:         allow(OS::Mac).to receive(:version).and_return(MacOSVersion.new(HOMEBREW_MACOS_NEWEST_UNSUPPORTED))
// 31:
// 32:         expect(described_class.update_instructions).to include("Update them from Software Update in System Settings.")
// 33:       end
// 34:     end
// 35:   end
// 36: end
