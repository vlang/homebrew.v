module test

import brew_runtime

// Translated from Homebrew/brew `test/system_command_result_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:result) do` at line 7.
pub fn ruby_system_command_result_spec_l7_d1_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('result', ...args)
}

// Ruby let `let(:output_array) do` at line 12.
pub fn ruby_system_command_result_spec_l12_d2_output_array(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output_array', ...args)
}

// Ruby it `it "can be destructed like `Open3.capture3`" do` at line 22.
pub fn ruby_system_command_result_spec_l22_d3_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "returns the standard output" do` at line 32.
pub fn ruby_system_command_result_spec_l32_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the standard error output" do` at line 38.
pub fn ruby_system_command_result_spec_l38_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the combined standard and standard error output" do` at line 44.
pub fn ruby_system_command_result_spec_l44_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby subject `subject(:result_plist) { result.plist }` at line 50.
pub fn ruby_system_command_result_spec_l50_d7_result_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('result_plist', ...args)
}

// Ruby let `let(:stdout) { "" }` at line 52.
pub fn ruby_system_command_result_spec_l52_d8_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stdout', ...args)
}

// Ruby let `let(:output_array) { [[:stdout, stdout]] }` at line 53.
pub fn ruby_system_command_result_spec_l53_d9_output_array(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output_array', ...args)
}

// Ruby let `let(:garbage) do` at line 54.
pub fn ruby_system_command_result_spec_l54_d10_garbage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('garbage', ...args)
}

// Ruby let `let(:plist) do` at line 65.
pub fn ruby_system_command_result_spec_l65_d11_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('plist', ...args)
}

// Ruby let `let(:stdout) do` at line 114.
pub fn ruby_system_command_result_spec_l114_d12_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stdout', ...args)
}

// Ruby it `it "ignores garbage" do` at line 121.
pub fn ruby_system_command_result_spec_l121_d13_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "warns about garbage" do` at line 130.
pub fn ruby_system_command_result_spec_l130_d14_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby let `let(:stdout) do` at line 138.
pub fn ruby_system_command_result_spec_l138_d15_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stdout', ...args)
}

// Ruby it `it "ignores garbage" do` at line 145.
pub fn ruby_system_command_result_spec_l145_d16_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "warns about garbage" do` at line 154.
pub fn ruby_system_command_result_spec_l154_d17_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby let `let(:stdout) { plist }` at line 162.
pub fn ruby_system_command_result_spec_l162_d18_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stdout', ...args)
}

// Ruby it `it "successfully parses it" do` at line 164.
pub fn ruby_system_command_result_spec_l164_d19_successfully(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('successfully', ...args)
}

// Ruby let `let(:stdout) { "" }` at line 173.
pub fn ruby_system_command_result_spec_l173_d20_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stdout', ...args)
}

// Ruby it `it "returns nil" do` at line 175.
pub fn ruby_system_command_result_spec_l175_d21_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: RSpec.describe SystemCommand::Result do
// 7:   subject(:result) do
// 8:     described_class.new([], output_array, instance_double(Process::Status, exitstatus: 0, success?: true),
// 9:                         secrets: [])
// 10:   end
// 11:
// 12:   let(:output_array) do
// 13:     [
// 14:       [:stdout, "output\n"],
// 15:       [:stderr, "error\n"],
// 16:     ]
// 17:   end
// 18:
// 19:   RSpec::Matchers.alias_matcher :a_string_containing, :include
// 20:
// 21:   describe "#to_ary" do
// 22:     it "can be destructed like `Open3.capture3`" do
// 23:       out, err, status = result
// 24:
// 25:       expect(out).to eq "output\n"
// 26:       expect(err).to eq "error\n"
// 27:       expect(status).to be_a_success
// 28:     end
// 29:   end
// 30:
// 31:   describe "#stdout" do
// 32:     it "returns the standard output" do
// 33:       expect(result.stdout).to eq "output\n"
// 34:     end
// 35:   end
// 36:
// 37:   describe "#stderr" do
// 38:     it "returns the standard error output" do
// 39:       expect(result.stderr).to eq "error\n"
// 40:     end
// 41:   end
// 42:
// 43:   describe "#merged_output" do
// 44:     it "returns the combined standard and standard error output" do
// 45:       expect(result.merged_output).to eq "output\nerror\n"
// 46:     end
// 47:   end
// 48:
// 49:   describe "#plist" do
// 50:     subject(:result_plist) { result.plist }
// 51:
// 52:     let(:stdout) { "" }
// 53:     let(:output_array) { [[:stdout, stdout]] }
// 54:     let(:garbage) do
// 55:       <<~EOS
// 56:         Hello there! I am in no way XML am I?!?!
// 57:
// 58:           That's a little silly... you were expecting XML here!
// 59:
// 60:         What is a parser to do?
// 61:
// 62:         Hopefully <not> explode!
// 63:       EOS
// 64:     end
// 65:     let(:plist) do
// 66:       <<~XML
// 67:         <?xml version="1.0" encoding="UTF-8"?>
// 68:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 69:         <plist version="1.0">
// 70:         <dict>
// 71:           <key>system-entities</key>
// 72:           <array>
// 73:             <dict>
// 74:               <key>content-hint</key>
// 75:               <string>Apple_partition_map</string>
// 76:               <key>dev-entry</key>
// 77:               <string>/dev/disk3s1</string>
// 78:               <key>potentially-mountable</key>
// 79:               <false/>
// 80:               <key>unmapped-content-hint</key>
// 81:               <string>Apple_partition_map</string>
// 82:             </dict>
// 83:             <dict>
// 84:               <key>content-hint</key>
// 85:               <string>Apple_partition_scheme</string>
// 86:               <key>dev-entry</key>
// 87:               <string>/dev/disk3</string>
// 88:               <key>potentially-mountable</key>
// 89:               <false/>
// 90:               <key>unmapped-content-hint</key>
// 91:               <string>Apple_partition_scheme</string>
// 92:             </dict>
// 93:             <dict>
// 94:               <key>content-hint</key>
// 95:               <string>Apple_HFS</string>
// 96:               <key>dev-entry</key>
// 97:               <string>/dev/disk3s2</string>
// 98:               <key>mount-point</key>
// 99:               <string>/private/tmp/dmg.BhfS2g</string>
// 100:               <key>potentially-mountable</key>
// 101:               <true/>
// 102:               <key>unmapped-content-hint</key>
// 103:               <string>Apple_HFS</string>
// 104:               <key>volume-kind</key>
// 105:               <string>hfs</string>
// 106:             </dict>
// 107:           </array>
// 108:         </dict>
// 109:         </plist>
// 110:       XML
// 111:     end
// 112:
// 113:     context "when stdout contains garbage before XML" do
// 114:       let(:stdout) do
// 115:         <<~EOS
// 116:           #{garbage}
// 117:           #{plist}
// 118:         EOS
// 119:       end
// 120:
// 121:       it "ignores garbage" do
// 122:         expect(result_plist["system-entities"].length).to eq(3)
// 123:       end
// 124:
// 125:       context "when verbose" do
// 126:         before do
// 127:           allow(Context).to receive(:current).and_return(Context::ContextStruct.new(verbose: true))
// 128:         end
// 129:
// 130:         it "warns about garbage" do
// 131:           expect { result_plist }
// 132:             .to output(a_string_containing(garbage)).to_stderr
// 133:         end
// 134:       end
// 135:     end
// 136:
// 137:     context "when stdout contains garbage after XML" do
// 138:       let(:stdout) do
// 139:         <<~EOS
// 140:           #{plist}
// 141:           #{garbage}
// 142:         EOS
// 143:       end
// 144:
// 145:       it "ignores garbage" do
// 146:         expect(result_plist["system-entities"].length).to eq(3)
// 147:       end
// 148:
// 149:       context "when verbose" do
// 150:         before do
// 151:           allow(Context).to receive(:current).and_return(Context::ContextStruct.new(verbose: true))
// 152:         end
// 153:
// 154:         it "warns about garbage" do
// 155:           expect { result_plist }
// 156:             .to output(a_string_containing(garbage)).to_stderr
// 157:         end
// 158:       end
// 159:     end
// 160:
// 161:     context "when there's a hdiutil stdout" do
// 162:       let(:stdout) { plist }
// 163:
// 164:       it "successfully parses it" do
// 165:         expect(result_plist.keys).to eq(["system-entities"])
// 166:         expect(result_plist["system-entities"].length).to eq(3)
// 167:         expect(result_plist["system-entities"].map { |e| e["dev-entry"] })
// 168:           .to eq(["/dev/disk3s1", "/dev/disk3", "/dev/disk3s2"])
// 169:       end
// 170:     end
// 171:
// 172:     context "when the stdout of the command is empty" do
// 173:       let(:stdout) { "" }
// 174:
// 175:       it "returns nil" do
// 176:         expect(result_plist).to be_nil
// 177:       end
// 178:     end
// 179:   end
// 180: end
