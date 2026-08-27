module test

import brew_runtime

// Translated from Homebrew/brew `test/style_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:dir) { mktmpdir }` at line 22.
pub fn ruby_style_spec_l22_d1_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dir', ...args)
}

// Ruby it `it "returns offenses when RuboCop reports offenses" do` at line 24.
pub fn ruby_style_spec_l24_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:dir) { mktmpdir }` at line 41.
pub fn ruby_style_spec_l41_d3_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dir', ...args)
}

// Ruby it `it "returns true (success) for conforming file with only audit-level violations" do` at line 43.
pub fn ruby_style_spec_l43_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:actionlint_result) do` at line 55.
pub fn ruby_style_spec_l55_d5_actionlint_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('actionlint_result', ...args)
}

// Ruby it `it "uses a tap's actionlint config when present" do` at line 65.
pub fn ruby_style_spec_l65_d6_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "falls back to HOMEBREW_REPOSITORY config when no tap config exists" do` at line 88.
pub fn ruby_style_spec_l88_d7_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "falls back to HOMEBREW_REPOSITORY config when files span multiple taps" do` at line 108.
pub fn ruby_style_spec_l108_d8_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "uses a matching system shellcheck" do` at line 136.
pub fn ruby_style_spec_l136_d9_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "uses a matching system actionlint" do` at line 150.
pub fn ruby_style_spec_l150_d10_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "passes a matching system shfmt to the shfmt wrapper" do` at line 165.
pub fn ruby_style_spec_l165_d11_passes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('passes', ...args)
}

// Ruby it `it "runs shellcheck in parallel chunks and merges their JSON results" do` at line 188.
pub fn ruby_style_spec_l188_d12_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Ruby let `let(:dir) { mktmpdir }` at line 219.
pub fn ruby_style_spec_l219_d13_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dir', ...args)
}

// Ruby let `let(:ruby_file) { dir/"test.rb" }` at line 220.
pub fn ruby_style_spec_l220_d14_ruby_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ruby_file', ...args)
}

// Ruby it `it "passes --disable-uncorrectable when --todo is enabled" do` at line 229.
pub fn ruby_style_spec_l229_d15_passes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('passes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "style"
// 5:
// 6: RSpec.describe Homebrew::Style do
// 7:   around do |example|
// 8:     FileUtils.ln_s HOMEBREW_LIBRARY_PATH, HOMEBREW_LIBRARY/"Homebrew"
// 9:     FileUtils.ln_s HOMEBREW_LIBRARY_PATH.parent/".rubocop.yml", HOMEBREW_LIBRARY/".rubocop.yml"
// 10:
// 11:     example.run
// 12:   ensure
// 13:     FileUtils.rm_f HOMEBREW_LIBRARY/"Homebrew"
// 14:     FileUtils.rm_f HOMEBREW_LIBRARY/".rubocop.yml"
// 15:   end
// 16:
// 17:   before do
// 18:     allow(Homebrew).to receive(:install_bundler_gems!)
// 19:   end
// 20:
// 21:   describe ".check_style_json" do
// 22:     let(:dir) { mktmpdir }
// 23:
// 24:     it "returns offenses when RuboCop reports offenses" do
// 25:       formula = dir/"my-formula.rb"
// 26:
// 27:       formula.write <<~RUBY
// 28:         class MyFormula < Formula
// 29:
// 30:         end
// 31:       RUBY
// 32:
// 33:       style_offenses = described_class.check_style_json([formula])
// 34:
// 35:       expect(style_offenses.for_path(formula.realpath).map(&:message))
// 36:         .to include("Extra empty line detected at class body beginning.")
// 37:     end
// 38:   end
// 39:
// 40:   describe ".check_style_and_print" do
// 41:     let(:dir) { mktmpdir }
// 42:
// 43:     it "returns true (success) for conforming file with only audit-level violations" do
// 44:       # This file is known to use non-rocket hashes and other things that trigger audit,
// 45:       # but not regular, cop violations
// 46:       target_file = HOMEBREW_LIBRARY_PATH/"utils.rb"
// 47:
// 48:       style_result = described_class.check_style_and_print([target_file])
// 49:
// 50:       expect(style_result).to be true
// 51:     end
// 52:   end
// 53:
// 54:   describe ".run_actionlint!" do
// 55:     let(:actionlint_result) do
// 56:       instance_double(SystemCommand::Result, success?: true, stdout: "", stderr: "")
// 57:     end
// 58:
// 59:     before do
// 60:       allow(described_class).to receive_messages(actionlint: "actionlint", shellcheck: "shellcheck")
// 61:       allow(Tty).to receive(:color?).and_return(false)
// 62:       allow(described_class).to receive(:system_command).and_return(actionlint_result)
// 63:     end
// 64:
// 65:     it "uses a tap's actionlint config when present" do
// 66:       tap_path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo"
// 67:       workflows_dir = tap_path/".github/workflows"
// 68:       workflows_dir.mkpath
// 69:       workflow = workflows_dir/"ci.yml"
// 70:       workflow.write "name: CI"
// 71:
// 72:       tap_config = tap_path/".github/actionlint.yaml"
// 73:       tap_config.write "self-hosted-runner:\n  labels: []\n"
// 74:
// 75:       expect(described_class).to receive(:system_command).with(
// 76:         "actionlint",
// 77:         args:         ["-shellcheck", "shellcheck",
// 78:                        "-config-file", tap_config,
// 79:                        "-ignore", "image: string; options: string",
// 80:                        "-ignore", "label .* is unknown",
// 81:                        workflow],
// 82:         print_stderr: false,
// 83:       ).and_return(actionlint_result)
// 84:
// 85:       described_class.run_actionlint!([workflow])
// 86:     end
// 87:
// 88:     it "falls back to HOMEBREW_REPOSITORY config when no tap config exists" do
// 89:       tap_path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo"
// 90:       workflows_dir = tap_path/".github/workflows"
// 91:       workflows_dir.mkpath
// 92:       workflow = workflows_dir/"ci.yml"
// 93:       workflow.write "name: CI"
// 94:
// 95:       expect(described_class).to receive(:system_command).with(
// 96:         "actionlint",
// 97:         args:         ["-shellcheck", "shellcheck",
// 98:                        "-config-file", HOMEBREW_REPOSITORY/".github/actionlint.yaml",
// 99:                        "-ignore", "image: string; options: string",
// 100:                        "-ignore", "label .* is unknown",
// 101:                        workflow],
// 102:         print_stderr: false,
// 103:       ).and_return(actionlint_result)
// 104:
// 105:       described_class.run_actionlint!([workflow])
// 106:     end
// 107:
// 108:     it "falls back to HOMEBREW_REPOSITORY config when files span multiple taps" do
// 109:       tap1_path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo"
// 110:       (tap1_path/".github/workflows").mkpath
// 111:       (tap1_path/".github/actionlint.yaml").write "self-hosted-runner:\n  labels: []\n"
// 112:       workflow1 = tap1_path/".github/workflows/ci.yml"
// 113:       workflow1.write "name: CI"
// 114:
// 115:       tap2_path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-bar"
// 116:       (tap2_path/".github/workflows").mkpath
// 117:       (tap2_path/".github/actionlint.yaml").write "self-hosted-runner:\n  labels: []\n"
// 118:       workflow2 = tap2_path/".github/workflows/ci.yml"
// 119:       workflow2.write "name: CI"
// 120:
// 121:       expect(described_class).to receive(:system_command).with(
// 122:         "actionlint",
// 123:         args:         ["-shellcheck", "shellcheck",
// 124:                        "-config-file", HOMEBREW_REPOSITORY/".github/actionlint.yaml",
// 125:                        "-ignore", "image: string; options: string",
// 126:                        "-ignore", "label .* is unknown",
// 127:                        workflow1, workflow2],
// 128:         print_stderr: false,
// 129:       ).and_return(actionlint_result)
// 130:
// 131:       described_class.run_actionlint!([workflow1, workflow2])
// 132:     end
// 133:   end
// 134:
// 135:   describe ".shellcheck" do
// 136:     it "uses a matching system shellcheck" do
// 137:       formula = instance_double(Formula)
// 138:
// 139:       allow(Formula).to receive(:[]).with("shellcheck").and_return(formula)
// 140:       allow(formula).to receive(:ensure_installed!).with(latest:     true,
// 141:                                                          reason:     "shell style checks",
// 142:                                                          executable: "shellcheck")
// 143:                                                    .and_return(Pathname.new("/usr/bin/shellcheck"))
// 144:
// 145:       expect(described_class.shellcheck).to eq(Pathname.new("/usr/bin/shellcheck"))
// 146:     end
// 147:   end
// 148:
// 149:   describe ".actionlint" do
// 150:     it "uses a matching system actionlint" do
// 151:       formula = instance_double(Formula)
// 152:
// 153:       allow(Formula).to receive(:[]).with("actionlint").and_return(formula)
// 154:       allow(formula).to receive(:ensure_installed!).with(latest:       true,
// 155:                                                          reason:       "GitHub Actions checks",
// 156:                                                          executable:   "actionlint",
// 157:                                                          version_args: ["-version"])
// 158:                                                    .and_return(Pathname.new("/usr/bin/actionlint"))
// 159:
// 160:       expect(described_class.actionlint).to eq(Pathname.new("/usr/bin/actionlint"))
// 161:     end
// 162:   end
// 163:
// 164:   describe ".run_shfmt!" do
// 165:     it "passes a matching system shfmt to the shfmt wrapper" do
// 166:       shell_file = Pathname.new("/tmp/test.sh")
// 167:       formula = instance_double(Formula)
// 168:
// 169:       allow(Formula).to receive(:[]).with("shfmt").and_return(formula)
// 170:       allow(formula).to receive(:ensure_installed!).with(latest:     true,
// 171:                                                          reason:     "formatting shell scripts",
// 172:                                                          executable: "shfmt")
// 173:                                                    .and_return(Pathname.new("/usr/bin/shfmt"))
// 174:
// 175:       shfmt_result = instance_double(SystemCommand::Result, success?: true, stdout: "", stderr: "")
// 176:       expect(described_class).to receive(:system_command).with(
// 177:         HOMEBREW_LIBRARY/"Homebrew/utils/shfmt.sh",
// 178:         args:         ["--language-dialect", "bash", "--indent", "2", "--case-indent", "--", shell_file],
// 179:         env:          { "HOMEBREW_SHFMT" => "/usr/bin/shfmt" },
// 180:         print_stderr: false,
// 181:       ).and_return(shfmt_result)
// 182:
// 183:       expect(described_class.run_shfmt!([shell_file])).to be true
// 184:     end
// 185:   end
// 186:
// 187:   describe ".run_shellcheck" do
// 188:     it "runs shellcheck in parallel chunks and merges their JSON results" do
// 189:       dir = mktmpdir
// 190:       log = dir/"shellcheck-args.log"
// 191:       fake_shellcheck = dir/"shellcheck"
// 192:       fake_shellcheck.write <<~SCRIPT
// 193:         #!/bin/bash
// 194:         echo "$*" >> "#{log}"
// 195:         echo "[]"
// 196:       SCRIPT
// 197:       fake_shellcheck.chmod 0755
// 198:
// 199:       files = (1..3).map do |i|
// 200:         file = dir/"script#{i}.sh"
// 201:         file.write "#!/bin/bash\n"
// 202:         file
// 203:       end
// 204:
// 205:       allow(Hardware::CPU).to receive(:cores).and_return(2)
// 206:
// 207:       offenses = described_class.run_shellcheck(files, :json, shellcheck_path: fake_shellcheck)
// 208:
// 209:       expect(offenses).to eq []
// 210:       chunks = log.read.lines
// 211:       expect(chunks.length).to eq 2
// 212:       first_chunk = chunks.find { |chunk| chunk.include?("script1.sh") }
// 213:       expect(first_chunk).to include("script2.sh")
// 214:       expect(first_chunk).not_to include("script3.sh")
// 215:     end
// 216:   end
// 217:
// 218:   describe ".run_rubocop" do
// 219:     let(:dir) { mktmpdir }
// 220:     let(:ruby_file) { dir/"test.rb" }
// 221:
// 222:     before do
// 223:       ruby_file.write <<~RUBY
// 224:         class Test
// 225:         end
// 226:       RUBY
// 227:     end
// 228:
// 229:     it "passes --disable-uncorrectable when --todo is enabled" do
// 230:       result = double(status: double(exitstatus: 0), stdout: '{"files":[]}')
// 231:
// 232:       expect(described_class).to receive(:system_command) do |_cmd, args:, **|
// 233:         expect(args).to include("--disable-uncorrectable")
// 234:         result
// 235:       end
// 236:
// 237:       described_class.run_rubocop([ruby_file], :json, fix: true, todo: true)
// 238:     end
// 239:   end
// 240: end
