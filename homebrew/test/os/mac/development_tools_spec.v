module mac

import homebrew.extend.os.mac as development_tools

// Translated from Homebrew/brew `test/os/mac/development_tools_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "doesn't call xcrun when Xcode and the CLT are not installed" do` at line 12.
pub fn ruby_development_tools_spec_l12_d1_doesn() bool {
	mut tools := development_tools.new_mac_development_tools()
	missing := tools.locate('missing-tool')
	return missing == none && tools.xcrun_calls.len == 0
}

// Ruby it `it "uses xcrun when developer tools are installed" do` at line 23.
pub fn ruby_development_tools_spec_l23_d2_uses() bool {
	mut tools := &development_tools.MacDevelopmentTools{
		xcode_installed: true
		xcrun_results: {
			'xcode-tool': '/Xcode/usr/bin/xcode-tool\n'
		}
		executable_paths: ['/Xcode/usr/bin/xcode-tool']
		locate_cache: map[string]string{}
		xcrun_calls: []string{}
	}
	path := tools.locate('xcode-tool') or { return false }
	return path == '/Xcode/usr/bin/xcode-tool' && tools.xcrun_calls == [
		'/usr/bin/xcrun -no-cache -find xcode-tool',
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "development_tools"
// 5:
// 6: RSpec.describe DevelopmentTools, :needs_macos do
// 7:   describe ".locate" do
// 8:     before do
// 9:       described_class.remove_instance_variable(:@locate) if described_class.instance_variable_defined?(:@locate)
// 10:     end
// 11:
// 12:     it "doesn't call xcrun when Xcode and the CLT are not installed" do
// 13:       allow(File).to receive(:executable?).and_call_original
// 14:       allow(File).to receive(:executable?).with("/usr/bin/missing-tool").and_return(false)
// 15:       allow(OS::Mac::Xcode).to receive(:installed?).and_return(false)
// 16:       allow(OS::Mac::CLT).to receive(:installed?).and_return(false)
// 17:
// 18:       expect(Utils).not_to receive(:popen_read)
// 19:
// 20:       expect(described_class.locate("missing-tool")).to be_nil
// 21:     end
// 22:
// 23:     it "uses xcrun when developer tools are installed" do
// 24:       allow(File).to receive(:executable?).and_call_original
// 25:       allow(File).to receive(:executable?).with("/usr/bin/xcode-tool").and_return(false)
// 26:       allow(File).to receive(:executable?).with("/Xcode/usr/bin/xcode-tool").and_return(true)
// 27:       allow(OS::Mac::Xcode).to receive(:installed?).and_return(true)
// 28:       allow(OS::Mac::CLT).to receive(:installed?).and_return(false)
// 29:       expect(Utils).to receive(:popen_read)
// 30:         .with("/usr/bin/xcrun", "-no-cache", "-find", "xcode-tool", err: :close)
// 31:         .and_return("/Xcode/usr/bin/xcode-tool\n")
// 32:
// 33:       expect(described_class.locate("xcode-tool")).to eq(Pathname("/Xcode/usr/bin/xcode-tool"))
// 34:     end
// 35:   end
// 36: end
