module test

import brew_runtime

// Translated from Homebrew/brew `test/sandbox_landlock_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:landlock) { described_class.new(sandbox.profile) }` at line 8.
pub fn ruby_sandbox_landlock_spec_l8_d1_landlock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('landlock', ...args)
}

// Ruby let `let(:sandbox) { Sandbox.new }` at line 10.
pub fn ruby_sandbox_landlock_spec_l10_d2_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sandbox', ...args)
}

// Ruby it `it "declares its weaker write-isolation contract" do` at line 20.
pub fn ruby_sandbox_landlock_spec_l20_d3_declares(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('declares', ...args)
}

// Ruby it `it "reports the supported Landlock ABI" do` at line 24.
pub fn ruby_sandbox_landlock_spec_l24_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "returns false for a kernel without Landlock support" do` at line 33.
pub fn ruby_sandbox_landlock_spec_l33_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false when Landlock is disabled by the kernel configuration" do` at line 42.
pub fn ruby_sandbox_landlock_spec_l42_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false when Linux sandboxing is disabled" do` at line 51.
pub fn ruby_sandbox_landlock_spec_l51_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false when Fiddle is unavailable" do` at line 58.
pub fn ruby_sandbox_landlock_spec_l58_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "is available for an ABI without truncate restrictions" do` at line 66.
pub fn ruby_sandbox_landlock_spec_l66_d9_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "returns false for an ABI that always denies cross-directory renames" do` at line 72.
pub fn ruby_sandbox_landlock_spec_l72_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "reports the kernel ABI even when Linux sandboxing is disabled" do` at line 83.
pub fn ruby_sandbox_landlock_spec_l83_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "returns nil for a kernel without Landlock support" do` at line 90.
pub fn ruby_sandbox_landlock_spec_l90_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil when Fiddle function setup fails" do` at line 96.
pub fn ruby_sandbox_landlock_spec_l96_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:writable_dir) { mktmpdir }` at line 105.
pub fn ruby_sandbox_landlock_spec_l105_d14_writable_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writable_dir', ...args)
}

// Ruby let `let(:tmpdir) { mktmpdir }` at line 106.
pub fn ruby_sandbox_landlock_spec_l106_d15_tmpdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tmpdir', ...args)
}

// Ruby it `it "rejects an ABI without cross-directory rename restrictions" do` at line 118.
pub fn ruby_sandbox_landlock_spec_l118_d16_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "restricts writes and network access using the supported ABI" do` at line 127.
pub fn ruby_sandbox_landlock_spec_l127_d17_restricts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('restricts', ...args)
}

// Ruby it `it "handles reads, directory listings, and execution outside denied hierarchies" do` at line 171.
pub fn ruby_sandbox_landlock_spec_l171_d18_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "skips readable paths removed after command setup" do` at line 213.
pub fn ruby_sandbox_landlock_spec_l213_d19_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "allows pseudo-terminal device access" do` at line 231.
pub fn ruby_sandbox_landlock_spec_l231_d20_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "allows standard device and POSIX IPC paths" do` at line 249.
pub fn ruby_sandbox_landlock_spec_l249_d21_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "skips unavailable device and IPC paths" do` at line 278.
pub fn ruby_sandbox_landlock_spec_l278_d22_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "warns when applying incomplete network denial" do` at line 310.
pub fn ruby_sandbox_landlock_spec_l310_d23_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby it `it "does not warn before applying network denial" do` at line 318.
pub fn ruby_sandbox_landlock_spec_l318_d24_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not warn without network denial" do` at line 324.
pub fn ruby_sandbox_landlock_spec_l324_d25_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "uses the supported network access rights" do` at line 330.
pub fn ruby_sandbox_landlock_spec_l330_d26_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "does not warn without network denial" do` at line 348.
pub fn ruby_sandbox_landlock_spec_l348_d27_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "warns that network access cannot be restricted" do` at line 354.
pub fn ruby_sandbox_landlock_spec_l354_d28_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warns', ...args)
}

// Ruby it `it "omits unsupported access rights from device path rules" do` at line 362.
pub fn ruby_sandbox_landlock_spec_l362_d29_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "handles only the supported filesystem access rights" do` at line 373.
pub fn ruby_sandbox_landlock_spec_l373_d30_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "prepares missing writable directories and removes them after running" do` at line 385.
pub fn ruby_sandbox_landlock_spec_l385_d31_prepares(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prepares', ...args)
}

// Ruby it `it "rejects regex path filters" do` at line 397.
pub fn ruby_sandbox_landlock_spec_l397_d32_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "allows reading paths outside denied hierarchies" do` at line 404.
pub fn ruby_sandbox_landlock_spec_l404_d33_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "does not allow a symlink alias into a denied hierarchy" do` at line 415.
pub fn ruby_sandbox_landlock_spec_l415_d34_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "skips dangling symlinks" do` at line 426.
pub fn ruby_sandbox_landlock_spec_l426_d35_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "sandbox"
// 5: require "extend/os/linux/sandbox/landlock"
// 6:
// 7: RSpec.describe Sandbox::Landlock do
// 8:   subject(:landlock) { described_class.new(sandbox.profile) }
// 9:
// 10:   let(:sandbox) { Sandbox.new }
// 11:
// 12:   around do |example|
// 13:     described_class.reset_state!
// 14:     example.run
// 15:   ensure
// 16:     described_class.reset_state!
// 17:   end
// 18:
// 19:   describe "::available?" do
// 20:     it "declares its weaker write-isolation contract" do
// 21:       expect(described_class.full_write_isolation?).to be(false)
// 22:     end
// 23:
// 24:     it "reports the supported Landlock ABI" do
// 25:       allow(described_class).to receive(:landlock_create_ruleset).with(nil, 0, 1).and_return(4)
// 26:
// 27:       expect(described_class).to be_available
// 28:       expect(described_class.state).to eq(:available)
// 29:       expect(described_class.abi_version).to eq(4)
// 30:       expect(described_class.failure_reason).to be_nil
// 31:     end
// 32:
// 33:     it "returns false for a kernel without Landlock support" do
// 34:       allow(described_class).to receive(:landlock_create_ruleset).with(nil, 0, 1).and_return(-1)
// 35:       allow(described_class).to receive(:last_error).and_return(Errno::ENOSYS::Errno)
// 36:
// 37:       expect(described_class).not_to be_available
// 38:       expect(described_class.state).to eq(:unsupported)
// 39:       expect(described_class.failure_reason).to include("not supported by this Linux kernel")
// 40:     end
// 41:
// 42:     it "returns false when Landlock is disabled by the kernel configuration" do
// 43:       allow(described_class).to receive(:landlock_create_ruleset).with(nil, 0, 1).and_return(-1)
// 44:       allow(described_class).to receive(:last_error).and_return(Errno::EOPNOTSUPP::Errno)
// 45:
// 46:       expect(described_class).not_to be_available
// 47:       expect(described_class.state).to eq(:disabled)
// 48:       expect(described_class.failure_reason).to include("disabled by this Linux kernel")
// 49:     end
// 50:
// 51:     it "returns false when Linux sandboxing is disabled" do
// 52:       allow(Homebrew::EnvConfig).to receive(:sandbox_linux?).and_return(false)
// 53:
// 54:       expect(described_class).not_to be_available
// 55:       expect(described_class.state).to eq(:config_disabled)
// 56:     end
// 57:
// 58:     it "returns false when Fiddle is unavailable" do
// 59:       allow(described_class).to receive(:require).with("fiddle").and_raise(LoadError)
// 60:
// 61:       expect(described_class).not_to be_available
// 62:       expect(described_class.state).to eq(:missing_fiddle)
// 63:       expect(described_class.failure_reason).to include("Fiddle")
// 64:     end
// 65:
// 66:     it "is available for an ABI without truncate restrictions" do
// 67:       allow(described_class).to receive(:landlock_create_ruleset).with(nil, 0, 1).and_return(2)
// 68:
// 69:       expect(described_class).to be_available
// 70:     end
// 71:
// 72:     it "returns false for an ABI that always denies cross-directory renames" do
// 73:       allow(described_class).to receive(:landlock_create_ruleset).with(nil, 0, 1).and_return(1)
// 74:
// 75:       expect(described_class).not_to be_available
// 76:       expect(described_class.state).to eq(:unsupported_abi)
// 77:       expect(described_class.abi_version).to eq(1)
// 78:       expect(described_class.failure_reason).to eq("Landlock ABI 2 or later is required; found ABI 1.")
// 79:     end
// 80:   end
// 81:
// 82:   describe "::kernel_abi_version" do
// 83:     it "reports the kernel ABI even when Linux sandboxing is disabled" do
// 84:       allow(Homebrew::EnvConfig).to receive(:sandbox_linux?).and_return(false)
// 85:       allow(described_class).to receive(:landlock_create_ruleset).with(nil, 0, 1).and_return(6)
// 86:
// 87:       expect(described_class.kernel_abi_version).to eq(6)
// 88:     end
// 89:
// 90:     it "returns nil for a kernel without Landlock support" do
// 91:       allow(described_class).to receive(:landlock_create_ruleset).with(nil, 0, 1).and_return(-1)
// 92:
// 93:       expect(described_class.kernel_abi_version).to be_nil
// 94:     end
// 95:
// 96:     it "returns nil when Fiddle function setup fails" do
// 97:       require "fiddle"
// 98:       allow(described_class).to receive(:landlock_create_ruleset).and_raise(Fiddle::DLError)
// 99:
// 100:       expect(described_class.kernel_abi_version).to be_nil
// 101:     end
// 102:   end
// 103:
// 104:   describe "#apply!" do
// 105:     let(:writable_dir) { mktmpdir }
// 106:     let(:tmpdir) { mktmpdir }
// 107:
// 108:     before do
// 109:       allow(File).to receive(:exist?).and_call_original
// 110:       allow(File).to receive(:exist?).with("/dev/full").and_return(false)
// 111:       allow(File).to receive(:exist?).with("/dev/mqueue").and_return(false)
// 112:       allow(File).to receive(:exist?).with("/dev/ptmx").and_return(true)
// 113:       allow(File).to receive(:exist?).with("/dev/pts").and_return(true)
// 114:       allow(File).to receive(:exist?).with("/dev/shm").and_return(false)
// 115:       allow(File).to receive(:exist?).with("/dev/tty").and_return(false)
// 116:     end
// 117:
// 118:     it "rejects an ABI without cross-directory rename restrictions" do
// 119:       allow(described_class).to receive_messages(abi_version:    1,
// 120:                                                  failure_reason: "Landlock ABI 2 or later is required; found ABI 1.")
// 121:       expect(described_class).not_to receive(:landlock_create_ruleset)
// 122:
// 123:       expect { landlock.apply! }
// 124:         .to raise_error(RuntimeError, "Landlock ABI 2 or later is required; found ABI 1.")
// 125:     end
// 126:
// 127:     it "restricts writes and network access using the supported ABI" do
// 128:       sandbox.allow_write_path writable_dir
// 129:       sandbox.deny_all_network
// 130:       landlock.command(["true"], tmpdir.to_s)
// 131:
// 132:       allow(described_class).to receive(:abi_version).and_return(10)
// 133:       expect(described_class).to receive(:landlock_create_ruleset) do |attributes, size, flags|
// 134:         expect(attributes.unpack("Q3")).to eq([131_058, 15, 1])
// 135:         expect(size).to eq(24)
// 136:         expect(flags).to eq(0)
// 137:         17
// 138:       end
// 139:       allow(landlock).to receive(:open_path).with(writable_dir.to_s).and_return(18)
// 140:       expect(landlock).to receive(:open_path).with(File::NULL).and_return(19)
// 141:       allow(landlock).to receive(:open_path).with(tmpdir.to_s).and_return(20)
// 142:       expect(landlock).to receive(:open_path).with("#{tmpdir}/socket").and_return(21)
// 143:       expect(landlock).to receive(:open_path).with("/dev/ptmx").and_return(22)
// 144:       expect(landlock).to receive(:open_path).with("/dev/pts").and_return(23)
// 145:       path_rules = []
// 146:       expect(described_class).to receive(:landlock_add_rule).exactly(6).times do |ruleset_fd, type, attributes, flags|
// 147:         expect(ruleset_fd).to eq(17)
// 148:         expect(type).to eq(1)
// 149:         expect(attributes.bytesize).to eq(12)
// 150:         path_rules << attributes.unpack("Ql")
// 151:         expect(flags).to eq(0)
// 152:         0
// 153:       end
// 154:       expect(described_class).to receive(:set_no_new_privileges).and_return(0)
// 155:       expect(described_class).to receive(:landlock_restrict_self).with(17, 0).and_return(0)
// 156:       expect(landlock).to receive(:close_file_descriptor).with(22).ordered
// 157:       expect(landlock).to receive(:close_file_descriptor).with(23).ordered
// 158:       expect(landlock).to receive(:close_file_descriptor).with(21).ordered
// 159:       expect(landlock).to receive(:close_file_descriptor).with(18).ordered
// 160:       expect(landlock).to receive(:close_file_descriptor).with(19).ordered
// 161:       expect(landlock).to receive(:close_file_descriptor).with(20).ordered
// 162:       expect(landlock).to receive(:close_file_descriptor).with(17).ordered
// 163:
// 164:       landlock.apply!
// 165:
// 166:       expect(path_rules).to eq([
// 167:         [32_770, 22], [32_770, 23], [65_536, 21], [32_754, 18], [16_386, 19], [32_754, 20]
// 168:       ])
// 169:     end
// 170:
// 171:     it "handles reads, directory listings, and execution outside denied hierarchies" do
// 172:       readable_dir = mktmpdir
// 173:       readable_file = readable_dir/"file"
// 174:       readable_file.write("content")
// 175:       denied_dir = mktmpdir
// 176:       sandbox.deny_read_path denied_dir
// 177:       allow(landlock).to receive(:readable_paths).with([denied_dir])
// 178:                                                  .and_return([readable_dir.to_s, readable_file.to_s])
// 179:       landlock.command(["true"], tmpdir.to_s)
// 180:
// 181:       allow(described_class).to receive(:abi_version).and_return(10)
// 182:       expect(described_class).to receive(:landlock_create_ruleset) do |attributes, size, flags|
// 183:         expect(attributes.unpack("Q")).to eq([65_535])
// 184:         expect(size).to eq(8)
// 185:         expect(flags).to eq(0)
// 186:         17
// 187:       end
// 188:       expect(landlock).to receive(:open_path).with(readable_dir.to_s).and_return(18)
// 189:       expect(landlock).to receive(:open_path).with(readable_file.to_s).and_return(19)
// 190:       expect(landlock).to receive(:open_path).with(File::NULL).and_return(20)
// 191:       expect(landlock).to receive(:open_path).with(tmpdir.to_s).and_return(21)
// 192:       expect(landlock).to receive(:open_path).with("/dev/ptmx").and_return(22)
// 193:       expect(landlock).to receive(:open_path).with("/dev/pts").and_return(23)
// 194:       path_rules = []
// 195:       expect(described_class).to receive(:landlock_add_rule).exactly(6).times do |ruleset_fd, type, attributes, flags|
// 196:         expect(ruleset_fd).to eq(17)
// 197:         expect(type).to eq(1)
// 198:         path_rules << attributes.unpack("Ql")
// 199:         expect(flags).to eq(0)
// 200:         0
// 201:       end
// 202:       expect(described_class).to receive(:set_no_new_privileges).and_return(0)
// 203:       expect(described_class).to receive(:landlock_restrict_self).with(17, 0).and_return(0)
// 204:       allow(landlock).to receive(:close_file_descriptor)
// 205:
// 206:       landlock.apply!
// 207:
// 208:       expect(path_rules).to eq([
// 209:         [32_774, 22], [32_774, 23], [13, 18], [5, 19], [16_386, 20], [32_754, 21]
// 210:       ])
// 211:     end
// 212:
// 213:     it "skips readable paths removed after command setup" do
// 214:       readable_dir = mktmpdir
// 215:       denied_dir = mktmpdir
// 216:       sandbox.deny_read_path denied_dir
// 217:       allow(landlock).to receive(:readable_paths).with([denied_dir]).and_return([readable_dir.to_s])
// 218:       landlock.command(["true"], tmpdir.to_s)
// 219:       readable_dir.rmdir
// 220:
// 221:       allow(described_class).to receive_messages(abi_version: 10, landlock_create_ruleset: 17,
// 222:                                                  landlock_add_rule: 0, set_no_new_privileges: 0,
// 223:                                                  landlock_restrict_self: 0)
// 224:       allow(landlock).to receive(:open_path).and_return(18)
// 225:       expect(landlock).to receive(:open_path).with(readable_dir.to_s).and_raise(Errno::ENOENT)
// 226:       allow(landlock).to receive(:close_file_descriptor)
// 227:
// 228:       expect { landlock.apply! }.not_to raise_error
// 229:     end
// 230:
// 231:     it "allows pseudo-terminal device access" do
// 232:       landlock.command(["true"], tmpdir.to_s)
// 233:
// 234:       allow(described_class).to receive_messages(abi_version: 10, landlock_create_ruleset: 17,
// 235:                                                  landlock_add_rule: 0, set_no_new_privileges: 0,
// 236:                                                  landlock_restrict_self: 0)
// 237:       allow(landlock).to receive(:open_path).and_return(18)
// 238:       allow(landlock).to receive(:close_file_descriptor)
// 239:       expect(landlock).to receive(:open_path).with("/dev/ptmx").and_return(19)
// 240:       expect(landlock).to receive(:open_path).with("/dev/pts").and_return(20)
// 241:       expect(described_class).to receive(:landlock_add_rule)
// 242:         .with(17, 1, [32_770, 19].pack("Ql"), 0).and_return(0)
// 243:       expect(described_class).to receive(:landlock_add_rule)
// 244:         .with(17, 1, [32_770, 20].pack("Ql"), 0).and_return(0)
// 245:
// 246:       landlock.apply!
// 247:     end
// 248:
// 249:     it "allows standard device and POSIX IPC paths" do
// 250:       denied_dir = mktmpdir
// 251:       sandbox.deny_read_path denied_dir
// 252:       allow(landlock).to receive(:readable_paths).with([denied_dir]).and_return([])
// 253:       landlock.command(["true"], tmpdir.to_s)
// 254:
// 255:       allow(File).to receive(:exist?).with("/dev/full").and_return(true)
// 256:       allow(File).to receive(:exist?).with("/dev/mqueue").and_return(true)
// 257:       allow(File).to receive(:exist?).with("/dev/shm").and_return(true)
// 258:       allow(File).to receive(:exist?).with("/dev/tty").and_return(true)
// 259:       allow(described_class).to receive_messages(abi_version: 10, landlock_create_ruleset: 17,
// 260:                                                  landlock_add_rule: 0, set_no_new_privileges: 0,
// 261:                                                  landlock_restrict_self: 0)
// 262:       allow(landlock).to receive(:open_path).and_return(18)
// 263:       allow(landlock).to receive(:close_file_descriptor)
// 264:       {
// 265:         "/dev/full"   => [16_386, 19],
// 266:         "/dev/mqueue" => [32_758, 20],
// 267:         "/dev/shm"    => [32_754, 21],
// 268:         "/dev/tty"    => [32_774, 22],
// 269:       }.each do |path, (access, file_descriptor)|
// 270:         expect(landlock).to receive(:open_path).with(path).and_return(file_descriptor)
// 271:         expect(described_class).to receive(:landlock_add_rule)
// 272:           .with(17, 1, [access, file_descriptor].pack("Ql"), 0).and_return(0)
// 273:       end
// 274:
// 275:       landlock.apply!
// 276:     end
// 277:
// 278:     it "skips unavailable device and IPC paths" do
// 279:       landlock.command(["true"], tmpdir.to_s)
// 280:
// 281:       allow(File).to receive(:exist?).with("/dev/full").and_return(false)
// 282:       allow(File).to receive(:exist?).with("/dev/mqueue").and_return(false)
// 283:       allow(File).to receive(:exist?).with("/dev/ptmx").and_return(false)
// 284:       allow(File).to receive(:exist?).with("/dev/pts").and_return(false)
// 285:       allow(File).to receive(:exist?).with("/dev/shm").and_return(false)
// 286:       allow(File).to receive(:exist?).with("/dev/tty").and_return(false)
// 287:       allow(described_class).to receive_messages(abi_version: 10, landlock_create_ruleset: 17,
// 288:                                                  landlock_add_rule: 0, set_no_new_privileges: 0,
// 289:                                                  landlock_restrict_self: 0)
// 290:       allow(landlock).to receive(:open_path).and_return(18)
// 291:       allow(landlock).to receive(:close_file_descriptor)
// 292:       expect(landlock).not_to receive(:open_path).with("/dev/full")
// 293:       expect(landlock).not_to receive(:open_path).with("/dev/mqueue")
// 294:       expect(landlock).not_to receive(:open_path).with("/dev/ptmx")
// 295:       expect(landlock).not_to receive(:open_path).with("/dev/pts")
// 296:       expect(landlock).not_to receive(:open_path).with("/dev/shm")
// 297:       expect(landlock).not_to receive(:open_path).with("/dev/tty")
// 298:
// 299:       landlock.apply!
// 300:     end
// 301:
// 302:     context "with an older ABI" do
// 303:       before do
// 304:         allow(landlock).to receive(:open_path).and_return(18)
// 305:         allow(described_class).to receive_messages(abi_version: 7, landlock_create_ruleset: 17, landlock_add_rule: 0,
// 306:                                                    set_no_new_privileges: 0, landlock_restrict_self: 0)
// 307:         allow(landlock).to receive(:close_file_descriptor)
// 308:       end
// 309:
// 310:       it "warns when applying incomplete network denial" do
// 311:         sandbox.deny_all_network
// 312:         landlock.command(["true"], tmpdir.to_s)
// 313:
// 314:         expect { landlock.apply! }
// 315:           .to output(/Landlock ABI 10 or later is required to deny all network access; found ABI 7/).to_stderr
// 316:       end
// 317:
// 318:       it "does not warn before applying network denial" do
// 319:         sandbox.deny_all_network
// 320:
// 321:         expect { landlock.command(["true"], tmpdir.to_s) }.not_to output.to_stderr
// 322:       end
// 323:
// 324:       it "does not warn without network denial" do
// 325:         landlock.command(["true"], tmpdir.to_s)
// 326:
// 327:         expect { landlock.apply! }.not_to output.to_stderr
// 328:       end
// 329:
// 330:       it "uses the supported network access rights" do
// 331:         sandbox.deny_all_network
// 332:         landlock.command(["true"], tmpdir.to_s)
// 333:
// 334:         attributes, = landlock.ruleset_attributes(7)
// 335:
// 336:         expect(attributes.unpack("Q3")).to eq([65_522, 3, 1])
// 337:       end
// 338:     end
// 339:
// 340:     context "with the oldest supported ABI" do
// 341:       before do
// 342:         allow(landlock).to receive(:open_path).and_return(18)
// 343:         allow(described_class).to receive_messages(abi_version: 2, landlock_create_ruleset: 17, landlock_add_rule: 0,
// 344:                                                    set_no_new_privileges: 0, landlock_restrict_self: 0)
// 345:         allow(landlock).to receive(:close_file_descriptor)
// 346:       end
// 347:
// 348:       it "does not warn without network denial" do
// 349:         landlock.command(["true"], tmpdir.to_s)
// 350:
// 351:         expect { landlock.apply! }.not_to output.to_stderr
// 352:       end
// 353:
// 354:       it "warns that network access cannot be restricted" do
// 355:         sandbox.deny_all_network
// 356:         landlock.command(["true"], tmpdir.to_s)
// 357:
// 358:         expect { landlock.apply! }
// 359:           .to output(/found ABI 2\. This kernel cannot restrict network access/).to_stderr
// 360:       end
// 361:
// 362:       it "omits unsupported access rights from device path rules" do
// 363:         allow(File).to receive(:exist?).with("/dev/full").and_return(true)
// 364:         landlock.command(["true"], tmpdir.to_s)
// 365:
// 366:         expect(landlock).to receive(:open_path).with("/dev/full").and_return(19)
// 367:         expect(described_class).to receive(:landlock_add_rule)
// 368:           .with(17, 1, [2, 19].pack("Ql"), 0).and_return(0)
// 369:
// 370:         landlock.apply!
// 371:       end
// 372:
// 373:       it "handles only the supported filesystem access rights" do
// 374:         sandbox.deny_all_network
// 375:         landlock.command(["true"], tmpdir.to_s)
// 376:
// 377:         attributes, = landlock.ruleset_attributes(2)
// 378:
// 379:         expect(attributes.unpack("Q*")).to eq([16_370])
// 380:       end
// 381:     end
// 382:   end
// 383:
// 384:   describe "#command" do
// 385:     it "prepares missing writable directories and removes them after running" do
// 386:       writable_dir = mktmpdir/"created"
// 387:       sandbox.allow_write_path writable_dir
// 388:
// 389:       expect(landlock.command(["true"], mktmpdir.to_s)).to eq(["true"])
// 390:       expect(writable_dir).to be_a_directory
// 391:
// 392:       landlock.run { nil }
// 393:
// 394:       expect(writable_dir).not_to exist
// 395:     end
// 396:
// 397:     it "rejects regex path filters" do
// 398:       sandbox.allow_write path: "^/tmp/homebrew-[^/]+$", type: :regex
// 399:
// 400:       expect { landlock.command(["true"], mktmpdir.to_s) }
// 401:         .to raise_error(ArgumentError, /Linux sandbox does not support regex path filters/)
// 402:     end
// 403:
// 404:     it "allows reading paths outside denied hierarchies" do
// 405:       root = mktmpdir
// 406:       readable_dir = root/"readable"
// 407:       denied_dir = root/"denied"
// 408:       readable_dir.mkpath
// 409:       denied_dir.mkpath
// 410:       allow(landlock).to receive(:root_path).and_return(root)
// 411:
// 412:       expect(landlock.readable_paths([denied_dir])).to eq([readable_dir.to_s])
// 413:     end
// 414:
// 415:     it "does not allow a symlink alias into a denied hierarchy" do
// 416:       root = mktmpdir
// 417:       denied_dir = root/"denied"
// 418:       denied_dir.mkpath
// 419:       alias_path = root/"alias"
// 420:       alias_path.make_symlink(denied_dir)
// 421:       allow(landlock).to receive(:root_path).and_return(root)
// 422:
// 423:       expect(landlock.readable_paths([denied_dir])).to be_empty
// 424:     end
// 425:
// 426:     it "skips dangling symlinks" do
// 427:       root = mktmpdir
// 428:       denied_dir = root/"denied"
// 429:       denied_dir.mkpath
// 430:       dangling_path = root/"dangling"
// 431:       dangling_path.make_symlink(root/"missing")
// 432:       allow(landlock).to receive(:root_path).and_return(root)
// 433:
// 434:       expect(landlock.readable_paths([denied_dir])).to be_empty
// 435:     end
// 436:   end
// 437: end
