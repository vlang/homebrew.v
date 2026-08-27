module test

import brew_runtime

// Translated from Homebrew/brew `test/commands_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:tmpdir) { mktmpdir }` at line 8.
pub fn ruby_commands_spec_l8_d1_tmpdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tmpdir', ...args)
}

// Ruby let `let(:cmd_path) { tmpdir/"cmd" }` at line 9.
pub fn ruby_commands_spec_l9_d2_cmd_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cmd_path', ...args)
}

// Ruby let `let(:dev_cmd_path) { tmpdir/"dev-cmd" }` at line 10.
pub fn ruby_commands_spec_l10_d3_dev_cmd_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dev_cmd_path', ...args)
}

// Ruby let `let(:cmds) do` at line 11.
pub fn ruby_commands_spec_l11_d4_cmds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cmds', ...args)
}

// Ruby specify `specify "::internal_commands" do` at line 44.
pub fn ruby_commands_spec_l44_d5_internal_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::internal_commands', ...args)
}

// Ruby specify `specify "::internal_commands omits commands hidden from the manpage" do` at line 51.
pub fn ruby_commands_spec_l51_d6_internal_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::internal_commands', ...args)
}

// Ruby specify `specify "::internal_developer_commands" do` at line 60.
pub fn ruby_commands_spec_l60_d7_internal_developer_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::internal_developer_commands', ...args)
}

// Ruby specify `specify "::external_commands" do` at line 67.
pub fn ruby_commands_spec_l67_d8_external_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::external_commands', ...args)
}

// Ruby let `let(:internal_commands) { %w[doctor up upgrade] }` at line 90.
pub fn ruby_commands_spec_l90_d9_internal_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('internal_commands', ...args)
}

// Ruby let `let(:all_commands) { %w[doctor external-command up upgrade] }` at line 91.
pub fn ruby_commands_spec_l91_d10_all_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('all_commands', ...args)
}

// Ruby it `it "suggests a command for a typo" do` at line 98.
pub fn ruby_commands_spec_l98_d11_suggests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('suggests', ...args)
}

// Ruby it `it "suggests a command alias for a typo" do` at line 102.
pub fn ruby_commands_spec_l102_d12_suggests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('suggests', ...args)
}

// Ruby it `it "falls back to external command suggestions" do` at line 106.
pub fn ruby_commands_spec_l106_d13_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "does not suggest a command without a close match" do` at line 110.
pub fn ruby_commands_spec_l110_d14_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "omits internal command aliases" do` at line 116.
pub fn ruby_commands_spec_l116_d15_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "omits commands hidden from the manpage" do` at line 128.
pub fn ruby_commands_spec_l128_d16_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "omits internal command aliases from the cached command list" do` at line 146.
pub fn ruby_commands_spec_l146_d17_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "omits commands hidden from the manpage from the cached command list" do` at line 158.
pub fn ruby_commands_spec_l158_d18_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "does not load external command files" do` at line 174.
pub fn ruby_commands_spec_l174_d19_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby specify `specify "returns the path for an internal command" do` at line 187.
pub fn ruby_commands_spec_l187_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby specify `specify "returns the path for an internal developer-command" do` at line 193.
pub fn ruby_commands_spec_l193_d21_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "commands"
// 5:
// 6: # These shared contexts starting with `when` don't make sense.
// 7: RSpec.shared_context "custom internal commands" do # rubocop:disable RSpec/ContextWording
// 8:   let(:tmpdir) { mktmpdir }
// 9:   let(:cmd_path) { tmpdir/"cmd" }
// 10:   let(:dev_cmd_path) { tmpdir/"dev-cmd" }
// 11:   let(:cmds) do
// 12:     [
// 13:       # internal commands
// 14:       cmd_path/"rbcmd.rb",
// 15:       cmd_path/"shcmd.sh",
// 16:
// 17:       # internal developer-commands
// 18:       dev_cmd_path/"rbdevcmd.rb",
// 19:       dev_cmd_path/"shdevcmd.sh",
// 20:     ]
// 21:   end
// 22:
// 23:   before do
// 24:     stub_const("Commands::HOMEBREW_CMD_PATH", cmd_path)
// 25:     stub_const("Commands::HOMEBREW_DEV_CMD_PATH", dev_cmd_path)
// 26:   end
// 27:
// 28:   around do |example|
// 29:     cmd_path.mkpath
// 30:     dev_cmd_path.mkpath
// 31:     cmds.each do |f|
// 32:       FileUtils.touch f
// 33:     end
// 34:
// 35:     example.run
// 36:   ensure
// 37:     FileUtils.rm_f cmds
// 38:   end
// 39: end
// 40:
// 41: RSpec.describe Commands do
// 42:   include_context "custom internal commands"
// 43:
// 44:   specify "::internal_commands" do
// 45:     cmds = described_class.internal_commands
// 46:     expect(cmds).to include("rbcmd"), "Ruby commands files should be recognized"
// 47:     expect(cmds).to include("shcmd"), "Shell commands files should be recognized"
// 48:     expect(cmds).not_to include("rbdevcmd"), "Dev commands shouldn't be included"
// 49:   end
// 50:
// 51:   specify "::internal_commands omits commands hidden from the manpage" do
// 52:     hidden_parser = instance_double(Homebrew::CLI::Parser, hide_from_man_page: true)
// 53:     allow(Homebrew::CLI::Parser).to receive(:from_cmd_path).and_call_original
// 54:     allow(Homebrew::CLI::Parser).to receive(:from_cmd_path).with(Commands::HOMEBREW_CMD_PATH/"rbcmd.rb")
// 55:                                                            .and_return(hidden_parser)
// 56:
// 57:     expect(described_class.internal_commands).not_to include("rbcmd")
// 58:   end
// 59:
// 60:   specify "::internal_developer_commands" do
// 61:     cmds = described_class.internal_developer_commands
// 62:     expect(cmds).to include("rbdevcmd"), "Ruby commands files should be recognized"
// 63:     expect(cmds).to include("shdevcmd"), "Shell commands files should be recognized"
// 64:     expect(cmds).not_to include("rbcmd"), "Non-dev commands shouldn't be included"
// 65:   end
// 66:
// 67:   specify "::external_commands" do
// 68:     mktmpdir do |dir|
// 69:       %w[t0.rb brew-t1 brew-t2.rb brew-t3.py].each do |file|
// 70:         path = "#{dir}/#{file}"
// 71:         FileUtils.touch path
// 72:         FileUtils.chmod 0755, path
// 73:       end
// 74:
// 75:       FileUtils.touch "#{dir}/brew-t4"
// 76:
// 77:       allow(described_class).to receive(:tap_cmd_directories).and_return([dir])
// 78:
// 79:       cmds = described_class.external_commands
// 80:
// 81:       expect(cmds).to include("t0"), "Executable v2 Ruby files should be included"
// 82:       expect(cmds).to include("t1"), "Executable files should be included"
// 83:       expect(cmds).to include("t2"), "Executable Ruby files should be included"
// 84:       expect(cmds).to include("t3"), "Executable files with a Ruby extension should be included"
// 85:       expect(cmds).not_to include("t4"), "Non-executable files shouldn't be included"
// 86:     end
// 87:   end
// 88:
// 89:   describe "::suggestion_message" do
// 90:     let(:internal_commands) { %w[doctor up upgrade] }
// 91:     let(:all_commands) { %w[doctor external-command up upgrade] }
// 92:
// 93:     before do
// 94:       allow(described_class).to receive(:commands).with(external: false, aliases: true).and_return(internal_commands)
// 95:       allow(described_class).to receive(:commands).with(aliases: true).and_return(all_commands)
// 96:     end
// 97:
// 98:     it "suggests a command for a typo" do
// 99:       expect(described_class.suggestion_message("upgrde")).to eq("\nDid you mean upgrade?")
// 100:     end
// 101:
// 102:     it "suggests a command alias for a typo" do
// 103:       expect(described_class.suggestion_message("upp")).to eq("\nDid you mean up?")
// 104:     end
// 105:
// 106:     it "falls back to external command suggestions" do
// 107:       expect(described_class.suggestion_message("external-comand")).to eq("\nDid you mean external-command?")
// 108:     end
// 109:
// 110:     it "does not suggest a command without a close match" do
// 111:       expect(described_class.suggestion_message("zzzzzz")).to be_empty
// 112:     end
// 113:   end
// 114:
// 115:   describe "::rebuild_internal_commands_completion_list" do
// 116:     it "omits internal command aliases" do
// 117:       mktmpdir do |repository|
// 118:         stub_const("HOMEBREW_REPOSITORY", repository)
// 119:         (repository/"completions").mkpath
// 120:
// 121:         described_class.rebuild_internal_commands_completion_list
// 122:
// 123:         commands = (repository/"completions/internal_commands_list.txt").read.lines(chomp: true)
// 124:         expect(commands & described_class.internal_commands_aliases).to be_empty
// 125:       end
// 126:     end
// 127:
// 128:     it "omits commands hidden from the manpage" do
// 129:       mktmpdir do |repository|
// 130:         stub_const("HOMEBREW_REPOSITORY", repository)
// 131:         (repository/"completions").mkpath
// 132:         hidden_parser = instance_double(Homebrew::CLI::Parser, hide_from_man_page: true)
// 133:         allow(Homebrew::CLI::Parser).to receive(:from_cmd_path).and_call_original
// 134:         allow(Homebrew::CLI::Parser).to receive(:from_cmd_path).with(Commands::HOMEBREW_CMD_PATH/"rbcmd.rb")
// 135:                                                                .and_return(hidden_parser)
// 136:
// 137:         described_class.rebuild_internal_commands_completion_list
// 138:
// 139:         commands = (repository/"completions/internal_commands_list.txt").read.lines(chomp: true)
// 140:         expect(commands).not_to include("rbcmd")
// 141:       end
// 142:     end
// 143:   end
// 144:
// 145:   describe "::rebuild_commands_completion_list" do
// 146:     it "omits internal command aliases from the cached command list" do
// 147:       mktmpdir do |cache|
// 148:         stub_const("HOMEBREW_CACHE", cache)
// 149:         allow(described_class).to receive(:external_commands).and_return(["external"])
// 150:
// 151:         described_class.rebuild_commands_completion_list
// 152:
// 153:         commands = (cache/"all_commands_list.txt").read.lines(chomp: true)
// 154:         expect(commands & described_class.internal_commands_aliases).to be_empty
// 155:       end
// 156:     end
// 157:
// 158:     it "omits commands hidden from the manpage from the cached command list" do
// 159:       mktmpdir do |cache|
// 160:         stub_const("HOMEBREW_CACHE", cache)
// 161:         allow(described_class).to receive(:external_commands).and_return(["external"])
// 162:         hidden_parser = instance_double(Homebrew::CLI::Parser, hide_from_man_page: true)
// 163:         allow(Homebrew::CLI::Parser).to receive(:from_cmd_path).and_call_original
// 164:         allow(Homebrew::CLI::Parser).to receive(:from_cmd_path).with(Commands::HOMEBREW_CMD_PATH/"rbcmd.rb")
// 165:                                                                .and_return(hidden_parser)
// 166:
// 167:         described_class.rebuild_commands_completion_list
// 168:
// 169:         commands = (cache/"all_commands_list.txt").read.lines(chomp: true)
// 170:         expect(commands).not_to include("rbcmd")
// 171:       end
// 172:     end
// 173:
// 174:     it "does not load external command files" do
// 175:       mktmpdir do |cache|
// 176:         stub_const("HOMEBREW_CACHE", cache)
// 177:         allow(described_class).to receive(:external_commands).and_return(["external"])
// 178:
// 179:         expect(described_class).not_to receive(:external_ruby_v2_cmd_path)
// 180:
// 181:         described_class.rebuild_commands_completion_list
// 182:       end
// 183:     end
// 184:   end
// 185:
// 186:   describe "::path" do
// 187:     specify "returns the path for an internal command" do
// 188:       expect(described_class.path("rbcmd")).to eq(Commands::HOMEBREW_CMD_PATH/"rbcmd.rb")
// 189:       expect(described_class.path("shcmd")).to eq(Commands::HOMEBREW_CMD_PATH/"shcmd.sh")
// 190:       expect(described_class.path("idontexist1234")).to be_nil
// 191:     end
// 192:
// 193:     specify "returns the path for an internal developer-command" do
// 194:       expect(described_class.path("rbdevcmd")).to eq(Commands::HOMEBREW_DEV_CMD_PATH/"rbdevcmd.rb")
// 195:       expect(described_class.path("shdevcmd")).to eq(Commands::HOMEBREW_DEV_CMD_PATH/"shdevcmd.sh")
// 196:     end
// 197:   end
// 198: end
