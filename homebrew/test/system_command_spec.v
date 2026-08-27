module test

import brew_runtime

// Translated from Homebrew/brew `test/system_command_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:command) do` at line 8.
pub fn ruby_system_command_spec_l8_d1_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby let `let(:env_args) { ["bash", "-c", 'printf "%s" "${A?}" "${B?}" "${C?}"'] }` at line 19.
pub fn ruby_system_command_spec_l19_d2_env_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('env_args', ...args)
}

// Ruby let `let(:env) { { "A" => "1", "B" => "2", "C" => "3" } }` at line 20.
pub fn ruby_system_command_spec_l20_d3_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('env', ...args)
}

// Ruby let `let(:sudo) { false }` at line 21.
pub fn ruby_system_command_spec_l21_d4_sudo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sudo', ...args)
}

// Ruby let `let(:sudo_as_root) { false }` at line 22.
pub fn ruby_system_command_spec_l22_d5_sudo_as_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sudo_as_root', ...args)
}

// Ruby it `it("run!.stdout") { expect(command.run!.stdout).to eq("123") }` at line 25.
pub fn ruby_system_command_spec_l25_d6_run_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run!.stdout', ...args)
}

// Ruby it `it "includes the given variables explicitly" do` at line 28.
pub fn ruby_system_command_spec_l28_d7_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby let `let(:env) { { "A" => "1", "B" => "2", "C" => nil } }` at line 44.
pub fn ruby_system_command_spec_l44_d8_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('env', ...args)
}

// Ruby it `it "unsets them" do` at line 46.
pub fn ruby_system_command_spec_l46_d9_unsets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unsets', ...args)
}

// Ruby let `let(:sudo) { true }` at line 54.
pub fn ruby_system_command_spec_l54_d10_sudo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sudo', ...args)
}

// Ruby let `let(:sudo_as_root) { false }` at line 55.
pub fn ruby_system_command_spec_l55_d11_sudo_as_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sudo_as_root', ...args)
}

// Ruby it `it "includes the given variables explicitly" do` at line 58.
pub fn ruby_system_command_spec_l58_d12_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby let `let(:sudo) { true }` at line 75.
pub fn ruby_system_command_spec_l75_d13_sudo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sudo', ...args)
}

// Ruby let `let(:sudo_as_root) { true }` at line 76.
pub fn ruby_system_command_spec_l76_d14_sudo_as_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sudo_as_root', ...args)
}

// Ruby it `it "includes the given variables explicitly" do` at line 79.
pub fn ruby_system_command_spec_l79_d15_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby subject `subject(:result) { described_class.run("true") }` at line 98.
pub fn ruby_system_command_spec_l98_d16_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('result', ...args)
}

// Ruby it `it { is_expected.to be_a_success }` at line 100.
pub fn ruby_system_command_spec_l100_d17_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it(:exit_status) { expect(result.exit_status).to eq(0) }` at line 101.
pub fn ruby_system_command_spec_l101_d18_exit_status(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exit_status', ...args)
}

// Ruby let `let(:command) { "false" }` at line 106.
pub fn ruby_system_command_spec_l106_d19_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby it `it "throws an error" do` at line 109.
pub fn ruby_system_command_spec_l109_d20_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby subject `subject(:result) { described_class.run(command) }` at line 118.
pub fn ruby_system_command_spec_l118_d21_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('result', ...args)
}

// Ruby it `it { is_expected.not_to be_a_success }` at line 120.
pub fn ruby_system_command_spec_l120_d22_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it(:exit_status) { expect(result.exit_status).to eq(1) }` at line 121.
pub fn ruby_system_command_spec_l121_d23_exit_status(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exit_status', ...args)
}

// Ruby let `let(:command) { "/bin/ls" }` at line 127.
pub fn ruby_system_command_spec_l127_d24_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby let `let(:path)    { Pathname(Dir.mktmpdir) }` at line 128.
pub fn ruby_system_command_spec_l128_d25_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby subject `subject(:result) { described_class.run(command, args: [path]) }` at line 135.
pub fn ruby_system_command_spec_l135_d26_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('result', ...args)
}

// Ruby it `it { is_expected.to be_a_success }` at line 137.
pub fn ruby_system_command_spec_l137_d27_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it(:stdout) { expect(result.stdout).to eq("somefile\n") }` at line 138.
pub fn ruby_system_command_spec_l138_d28_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stdout', ...args)
}

// Ruby let `let(:command) { "/bin/bash" }` at line 143.
pub fn ruby_system_command_spec_l143_d29_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby let `let(:options) do` at line 144.
pub fn ruby_system_command_spec_l144_d30_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('options', ...args)
}

// Ruby subject `subject(:result) { described_class.run(command, **options) }` at line 153.
pub fn ruby_system_command_spec_l153_d31_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('result', ...args)
}

// Ruby it `it { is_expected.to be_a_success }` at line 155.
pub fn ruby_system_command_spec_l155_d32_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it(:stdout) { expect(result.stdout).to eq([1, 3, 5, nil].join("\n")) }` at line 156.
pub fn ruby_system_command_spec_l156_d33_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stdout', ...args)
}

// Ruby it `it(:stderr) { expect(result.stderr).to eq([2, 4, 6, nil].join("\n")) }` at line 157.
pub fn ruby_system_command_spec_l157_d34_stderr(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stderr', ...args)
}

// Ruby it `it "echoes only STDERR" do` at line 162.
pub fn ruby_system_command_spec_l162_d35_echoes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('echoes', ...args)
}

// Ruby it `it "echoes both STDOUT and STDERR" do` at line 177.
pub fn ruby_system_command_spec_l177_d36_echoes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('echoes', ...args)
}

// Ruby it `it "echoes only STDERR output" do` at line 191.
pub fn ruby_system_command_spec_l191_d37_echoes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('echoes', ...args)
}

// Ruby let `let(:options) do` at line 200.
pub fn ruby_system_command_spec_l200_d38_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('options', ...args)
}

// Ruby it `it "echoes the command and all output to STDERR" do` at line 207.
pub fn ruby_system_command_spec_l207_d39_echoes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('echoes', ...args)
}

// Ruby it `it "echoes nothing" do` at line 224.
pub fn ruby_system_command_spec_l224_d40_echoes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('echoes', ...args)
}

// Ruby it `it "echoes only STDOUT" do` at line 238.
pub fn ruby_system_command_spec_l238_d41_echoes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('echoes', ...args)
}

// Ruby let `let(:command) { "/bin/bash" }` at line 250.
pub fn ruby_system_command_spec_l250_d42_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby let `let(:options) do` at line 251.
pub fn ruby_system_command_spec_l251_d43_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('options', ...args)
}

// Ruby it `it "returns without deadlocking", timeout: 30 do` at line 258.
pub fn ruby_system_command_spec_l258_d44_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "raises an ArgumentError" do` at line 264.
pub fn ruby_system_command_spec_l264_d45_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "looks for executables in a custom PATH" do` at line 270.
pub fn ruby_system_command_spec_l270_d46_looks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('looks', ...args)
}

// Ruby it `it "does not raise a `SystemCallError` when the executable does not exist" do` at line 284.
pub fn ruby_system_command_spec_l284_d47_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "uses `Process.spawn` rather than `fork` when no privilege change is required" do` at line 290.
pub fn ruby_system_command_spec_l290_d48_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it 'does not format `stderr` when it starts with \r' do` at line 297.
pub fn ruby_system_command_spec_l297_d49_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:executable) { mktmpdir/"App Uninstaller" }` at line 311.
pub fn ruby_system_command_spec_l311_d50_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('executable', ...args)
}

// Ruby it `it "does not interpret the executable as a shell line" do` at line 322.
pub fn ruby_system_command_spec_l322_d51_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not leak the secrets" do` at line 328.
pub fn ruby_system_command_spec_l328_d52_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not leak the secrets set by environment" do` at line 339.
pub fn ruby_system_command_spec_l339_d53_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not leak the secrets" do` at line 352.
pub fn ruby_system_command_spec_l352_d54_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not leak the secrets set by environment" do` at line 363.
pub fn ruby_system_command_spec_l363_d55_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "is not interrupted" do` at line 376.
pub fn ruby_system_command_spec_l376_d56_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: RSpec.describe SystemCommand do
// 7:   describe "#initialize" do
// 8:     subject(:command) do
// 9:       described_class.new(
// 10:         "env",
// 11:         args:         env_args,
// 12:         env:,
// 13:         must_succeed: true,
// 14:         sudo:,
// 15:         sudo_as_root:,
// 16:       )
// 17:     end
// 18:
// 19:     let(:env_args) { ["bash", "-c", 'printf "%s" "${A?}" "${B?}" "${C?}"'] }
// 20:     let(:env) { { "A" => "1", "B" => "2", "C" => "3" } }
// 21:     let(:sudo) { false }
// 22:     let(:sudo_as_root) { false }
// 23:
// 24:     context "when given some environment variables" do
// 25:       it("run!.stdout") { expect(command.run!.stdout).to eq("123") }
// 26:
// 27:       describe "the resulting command line" do
// 28:         it "includes the given variables explicitly" do
// 29:           expect(command)
// 30:             .to receive(:exec3)
// 31:             .with(
// 32:               an_instance_of(Hash), "/usr/bin/env", "A=1", "B=2", "C=3",
// 33:               "env", *env_args,
// 34:               pgroup: true
// 35:             )
// 36:             .and_call_original
// 37:
// 38:           command.run!
// 39:         end
// 40:       end
// 41:     end
// 42:
// 43:     context "when given an environment variable which is set to nil" do
// 44:       let(:env) { { "A" => "1", "B" => "2", "C" => nil } }
// 45:
// 46:       it "unsets them" do
// 47:         expect do
// 48:           command.run!
// 49:         end.to raise_error(/C: parameter (null or )?not set/)
// 50:       end
// 51:     end
// 52:
// 53:     context "when given some environment variables and sudo: true, sudo_as_root: false" do
// 54:       let(:sudo) { true }
// 55:       let(:sudo_as_root) { false }
// 56:
// 57:       describe "the resulting command line" do
// 58:         it "includes the given variables explicitly" do
// 59:           expect(command)
// 60:             .to receive(:exec3)
// 61:             .with(
// 62:               an_instance_of(Hash), "/usr/bin/sudo", "-E",
// 63:               "A=1", "B=2", "C=3", "--", "env", *env_args, pgroup: nil
// 64:             )
// 65:             .and_wrap_original do |original_exec3, *_, &block|
// 66:               original_exec3.call({}, "true", &block)
// 67:             end
// 68:
// 69:           command.run!
// 70:         end
// 71:       end
// 72:     end
// 73:
// 74:     context "when given some environment variables and sudo: true, sudo_as_root: true" do
// 75:       let(:sudo) { true }
// 76:       let(:sudo_as_root) { true }
// 77:
// 78:       describe "the resulting command line" do
// 79:         it "includes the given variables explicitly" do
// 80:           expect(command)
// 81:             .to receive(:exec3)
// 82:             .with(
// 83:               an_instance_of(Hash), "/usr/bin/sudo", "-u", "root",
// 84:               "-E", "A=1", "B=2", "C=3", "--", "env", *env_args, pgroup: nil
// 85:             )
// 86:             .and_wrap_original do |original_exec3, *_, &block|
// 87:               original_exec3.call({}, "true", &block)
// 88:             end
// 89:
// 90:           command.run!
// 91:         end
// 92:       end
// 93:     end
// 94:   end
// 95:
// 96:   context "when the exit code is 0" do
// 97:     describe "its result" do
// 98:       subject(:result) { described_class.run("true") }
// 99:
// 100:       it { is_expected.to be_a_success }
// 101:       it(:exit_status) { expect(result.exit_status).to eq(0) }
// 102:     end
// 103:   end
// 104:
// 105:   context "when the exit code is 1" do
// 106:     let(:command) { "false" }
// 107:
// 108:     context "with a command that must succeed" do
// 109:       it "throws an error" do
// 110:         expect do
// 111:           described_class.run!(command)
// 112:         end.to raise_error(ErrorDuringExecution)
// 113:       end
// 114:     end
// 115:
// 116:     context "with a command that does not have to succeed" do
// 117:       describe "its result" do
// 118:         subject(:result) { described_class.run(command) }
// 119:
// 120:         it { is_expected.not_to be_a_success }
// 121:         it(:exit_status) { expect(result.exit_status).to eq(1) }
// 122:       end
// 123:     end
// 124:   end
// 125:
// 126:   context "when given a pathname" do
// 127:     let(:command) { "/bin/ls" }
// 128:     let(:path)    { Pathname(Dir.mktmpdir) }
// 129:
// 130:     before do
// 131:       FileUtils.touch(path.join("somefile"))
// 132:     end
// 133:
// 134:     describe "its result" do
// 135:       subject(:result) { described_class.run(command, args: [path]) }
// 136:
// 137:       it { is_expected.to be_a_success }
// 138:       it(:stdout) { expect(result.stdout).to eq("somefile\n") }
// 139:     end
// 140:   end
// 141:
// 142:   context "with both STDOUT and STDERR output from upstream" do
// 143:     let(:command) { "/bin/bash" }
// 144:     let(:options) do
// 145:       { args: [
// 146:         "-c",
// 147:         "for i in $(seq 1 2 5); do echo $i; echo $(($i + 1)) >&2; done",
// 148:       ] }
// 149:     end
// 150:
// 151:     shared_examples "it returns '1 2 3 4 5 6'" do
// 152:       describe "its result" do
// 153:         subject(:result) { described_class.run(command, **options) }
// 154:
// 155:         it { is_expected.to be_a_success }
// 156:         it(:stdout) { expect(result.stdout).to eq([1, 3, 5, nil].join("\n")) }
// 157:         it(:stderr) { expect(result.stderr).to eq([2, 4, 6, nil].join("\n")) }
// 158:       end
// 159:     end
// 160:
// 161:     context "with default options" do
// 162:       it "echoes only STDERR" do
// 163:         expected = [2, 4, 6].map { |i| "#{i}\n" }.join
// 164:         expect do
// 165:           described_class.run(command, **options)
// 166:         end.to output(expected).to_stderr
// 167:       end
// 168:
// 169:       include_examples("it returns '1 2 3 4 5 6'")
// 170:     end
// 171:
// 172:     context "with `print_stdout: true`" do
// 173:       before do
// 174:         options.merge!(print_stdout: true)
// 175:       end
// 176:
// 177:       it "echoes both STDOUT and STDERR" do
// 178:         expect { described_class.run(command, **options) }
// 179:           .to output("1\n3\n5\n").to_stdout
// 180:           .and output("2\n4\n6\n").to_stderr
// 181:       end
// 182:
// 183:       include_examples("it returns '1 2 3 4 5 6'")
// 184:     end
// 185:
// 186:     context "with `print_stdout: :debug`" do
// 187:       before do
// 188:         options.merge!(print_stdout: :debug)
// 189:       end
// 190:
// 191:       it "echoes only STDERR output" do
// 192:         expect { described_class.run(command, **options) }
// 193:           .to output("2\n4\n6\n").to_stderr
// 194:           .and not_to_output.to_stdout
// 195:       end
// 196:
// 197:       context "when `verbose?` and `debug?` are true" do
// 198:         include Context
// 199:
// 200:         let(:options) do
// 201:           { args: [
// 202:             "-c",
// 203:             "for i in $(seq 1 2 5); do echo $i; sleep 0.1; echo $(($i + 1)) >&2; sleep 0.1; done",
// 204:           ] }
// 205:         end
// 206:
// 207:         it "echoes the command and all output to STDERR" do
// 208:           with_context(verbose: true, debug: true) do
// 209:             expect { described_class.run(command, **options) }
// 210:               .to output(/\A.*#{Regexp.escape(command)}.*\n1\n2\n3\n4\n5\n6\n\Z/).to_stderr
// 211:               .and not_to_output.to_stdout
// 212:           end
// 213:         end
// 214:       end
// 215:
// 216:       include_examples("it returns '1 2 3 4 5 6'")
// 217:     end
// 218:
// 219:     context "with `print_stderr: false`" do
// 220:       before do
// 221:         options.merge!(print_stderr: false)
// 222:       end
// 223:
// 224:       it "echoes nothing" do
// 225:         expect do
// 226:           described_class.run(command, **options)
// 227:         end.not_to output.to_stdout
// 228:       end
// 229:
// 230:       include_examples("it returns '1 2 3 4 5 6'")
// 231:     end
// 232:
// 233:     context "with `print_stdout: true` and `print_stderr: false`" do
// 234:       before do
// 235:         options.merge!(print_stdout: true, print_stderr: false)
// 236:       end
// 237:
// 238:       it "echoes only STDOUT" do
// 239:         expected = [1, 3, 5].map { |i| "#{i}\n" }.join
// 240:         expect do
// 241:           described_class.run(command, **options)
// 242:         end.to output(expected).to_stdout
// 243:       end
// 244:
// 245:       include_examples("it returns '1 2 3 4 5 6'")
// 246:     end
// 247:   end
// 248:
// 249:   context "with a very long STDERR output" do
// 250:     let(:command) { "/bin/bash" }
// 251:     let(:options) do
// 252:       { args: [
// 253:         "-c",
// 254:         "for i in $(seq 1 2 100000); do echo $i; echo $(($i + 1)) >&2; done",
// 255:       ] }
// 256:     end
// 257:
// 258:     it "returns without deadlocking", timeout: 30 do
// 259:       expect(described_class.run(command, **options)).to be_a_success
// 260:     end
// 261:   end
// 262:
// 263:   context "when given an invalid variable name" do
// 264:     it "raises an ArgumentError" do
// 265:       expect { described_class.run("true", env: { "1ABC" => true }) }
// 266:         .to raise_error(ArgumentError, /variable name/)
// 267:     end
// 268:   end
// 269:
// 270:   it "looks for executables in a custom PATH" do
// 271:     mktmpdir do |path|
// 272:       (path/"tool").write <<~SH
// 273:         #!/bin/sh
// 274:         echo Hello, world!
// 275:       SH
// 276:
// 277:       FileUtils.chmod "+x", path/"tool"
// 278:
// 279:       expect(described_class.run("tool", env: { "PATH" => path.to_s }).stdout).to include "Hello, world!"
// 280:     end
// 281:   end
// 282:
// 283:   describe "#run" do
// 284:     it "does not raise a `SystemCallError` when the executable does not exist" do
// 285:       expect do
// 286:         described_class.run("non_existent_executable")
// 287:       end.not_to raise_error
// 288:     end
// 289:
// 290:     it "uses `Process.spawn` rather than `fork` when no privilege change is required" do
// 291:       command = described_class.new("true")
// 292:       expect(command).not_to receive(:fork)
// 293:       expect(Process).to receive(:spawn).and_call_original
// 294:       command.run!
// 295:     end
// 296:
// 297:     it 'does not format `stderr` when it starts with \r' do
// 298:       expect do
// 299:         Class.new.extend(SystemCommand::Mixin).system_command \
// 300:           "bash",
// 301:           args: [
// 302:             "-c",
// 303:             'printf "\r%s" "###################                                                       27.6%" 1>&2',
// 304:           ]
// 305:       end.to output(
// 306:         "\r###################                                                       27.6%",
// 307:       ).to_stderr
// 308:     end
// 309:
// 310:     context "when given an executable with spaces and no arguments" do
// 311:       let(:executable) { mktmpdir/"App Uninstaller" }
// 312:
// 313:       before do
// 314:         executable.write <<~SH
// 315:           #!/usr/bin/env bash
// 316:           true
// 317:         SH
// 318:
// 319:         FileUtils.chmod "+x", executable
// 320:       end
// 321:
// 322:       it "does not interpret the executable as a shell line" do
// 323:         expect(Class.new.extend(SystemCommand::Mixin).system_command(executable)).to be_a_success
// 324:       end
// 325:     end
// 326:
// 327:     context "when given arguments with secrets" do
// 328:       it "does not leak the secrets" do
// 329:         redacted_msg = /#{Regexp.escape("username:******")}/
// 330:         expect do
// 331:           described_class.run! "curl",
// 332:                                args:    %w[--user username:hunter2],
// 333:                                verbose: true,
// 334:                                debug:   true,
// 335:                                secrets: %w[hunter2]
// 336:         end.to raise_error(ErrorDuringExecution, redacted_msg).and output(redacted_msg).to_stderr
// 337:       end
// 338:
// 339:       it "does not leak the secrets set by environment" do
// 340:         redacted_msg = /#{Regexp.escape("username:******")}/
// 341:         expect do
// 342:           ENV["PASSWORD"] = "hunter2"
// 343:           described_class.run! "curl",
// 344:                                args:    %w[--user username:hunter2],
// 345:                                debug:   true,
// 346:                                verbose: true
// 347:         end.to raise_error(ErrorDuringExecution, redacted_msg).and output(redacted_msg).to_stderr
// 348:       end
// 349:     end
// 350:
// 351:     context "when running a process that prints secrets" do
// 352:       it "does not leak the secrets" do
// 353:         redacted_msg = /#{Regexp.escape("username:******")}/
// 354:         expect do
// 355:           described_class.run! "echo",
// 356:                                args:         %w[username:hunter2],
// 357:                                verbose:      true,
// 358:                                print_stdout: true,
// 359:                                secrets:      %w[hunter2]
// 360:         end.to output(redacted_msg).to_stdout
// 361:       end
// 362:
// 363:       it "does not leak the secrets set by environment" do
// 364:         redacted_msg = /#{Regexp.escape("username:******")}/
// 365:         expect do
// 366:           ENV["PASSWORD"] = "hunter2"
// 367:           described_class.run! "echo",
// 368:                                args:         %w[username:hunter2],
// 369:                                print_stdout: true,
// 370:                                verbose:      true
// 371:         end.to output(redacted_msg).to_stdout
// 372:       end
// 373:     end
// 374:
// 375:     context "when a `SIGINT` handler is set in the parent process" do
// 376:       it "is not interrupted" do
// 377:         start_time = Time.now
// 378:
// 379:         pid = fork do
// 380:           trap("INT") do
// 381:             # Ignore SIGINT.
// 382:           end
// 383:
// 384:           described_class.run! "sleep", args: [1]
// 385:
// 386:           exit!
// 387:         end
// 388:
// 389:         sleep 0.1
// 390:         Process.kill("INT", pid)
// 391:
// 392:         Process.waitpid(pid)
// 393:
// 394:         expect(Time.now - start_time).to be >= 1
// 395:       end
// 396:     end
// 397:   end
// 398: end
