module utils

import brew_runtime

// Translated from Homebrew/brew `test/utils/git_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:file) { "README.md" }` at line 7.
pub fn ruby_git_spec_l7_d1_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file', ...args)
}

// Ruby let `let(:file_hash_one) { @h1[0..6] }` at line 10.
pub fn ruby_git_spec_l10_d2_file_hash_one(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_hash_one', ...args)
}

// Ruby let `let(:file_hash_two) { @h2[0..6] }` at line 11.
pub fn ruby_git_spec_l11_d3_file_hash_two(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_hash_two', ...args)
}

// Ruby let `let(:files) { ["README.md", "LICENSE.txt"] }` at line 12.
pub fn ruby_git_spec_l12_d4_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('files', ...args)
}

// Ruby let `let(:files_hash_one) { [@h3[0..6], ["LICENSE.txt"]] }` at line 13.
pub fn ruby_git_spec_l13_d5_files_hash_one(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('files_hash_one', ...args)
}

// Ruby let `let(:files_hash_two) { [@h2[0..6], ["README.md"]] }` at line 14.
pub fn ruby_git_spec_l14_d6_files_hash_two(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('files_hash_two', ...args)
}

// Ruby let `let(:cherry_pick_commit) { @cherry_pick_commit[0..6] }` at line 15.
pub fn ruby_git_spec_l15_d7_cherry_pick_commit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cherry_pick_commit', ...args)
}

// Ruby it `it "can cherry pick a commit" do` at line 60.
pub fn ruby_git_spec_l60_d8_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "aborts when cherry picking an existing hash" do` at line 64.
pub fn ruby_git_spec_l64_d9_aborts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aborts', ...args)
}

// Ruby it `it "gives last revision commit when before_commit is nil" do` at line 73.
pub fn ruby_git_spec_l73_d10_gives(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gives', ...args)
}

// Ruby it `it "gives revision commit based on before_commit when it is not nil" do` at line 79.
pub fn ruby_git_spec_l79_d11_gives(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gives', ...args)
}

// Ruby it `it "returns file contents when file exists" do` at line 89.
pub fn ruby_git_spec_l89_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns empty when file doesn't exist" do` at line 93.
pub fn ruby_git_spec_l93_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "diffs against the `origin/HEAD` merge-base, ignoring a stale local default branch" do` at line 100.
pub fn ruby_git_spec_l100_d14_diffs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('diffs', ...args)
}

// Ruby it `it "gives last revision commit" do` at line 115.
pub fn ruby_git_spec_l115_d15_gives(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gives', ...args)
}

// Ruby it `it "gives last revision commit" do` at line 123.
pub fn ruby_git_spec_l123_d16_gives(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gives', ...args)
}

// Ruby it `it "returns last revision of file" do` at line 134.
pub fn ruby_git_spec_l134_d17_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns last revision of file based on before_commit" do` at line 141.
pub fn ruby_git_spec_l141_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true if git --version command succeeds" do` at line 150.
pub fn ruby_git_spec_l150_d19_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false if git --version command does not succeed" do` at line 154.
pub fn ruby_git_spec_l154_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil when git is not available" do` at line 161.
pub fn ruby_git_spec_l161_d21_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns path of git when git is available" do` at line 166.
pub fn ruby_git_spec_l166_d22_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns null when git is not available" do` at line 172.
pub fn ruby_git_spec_l172_d23_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns version of git when git is available" do` at line 177.
pub fn ruby_git_spec_l177_d24_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "doesn't fail if git already available" do` at line 183.
pub fn ruby_git_spec_l183_d25_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "can't install brewed git if homebrew/core is unavailable" do` at line 192.
pub fn ruby_git_spec_l192_d26_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "raises error if can't install git" do` at line 197.
pub fn ruby_git_spec_l197_d27_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "keeps using the git shim after the formula install helper" do` at line 207.
pub fn ruby_git_spec_l207_d28_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "returns true when git is not available" do` at line 225.
pub fn ruby_git_spec_l225_d29_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "terminates options before the URL" do` at line 231.
pub fn ruby_git_spec_l231_d30_terminates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('terminates', ...args)
}

// Ruby it `it "returns true when git remote exists", :needs_network do` at line 239.
pub fn ruby_git_spec_l239_d31_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false when git remote does not exist" do` at line 253.
pub fn ruby_git_spec_l253_d32_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/git"
// 5:
// 6: RSpec.describe Utils::Git do
// 7:   let(:file) { "README.md" }
// 8:   # Allow instance variables here for a simpler `before do` block.
// 9:   # rubocop:disable RSpec/InstanceVariable
// 10:   let(:file_hash_one) { @h1[0..6] }
// 11:   let(:file_hash_two) { @h2[0..6] }
// 12:   let(:files) { ["README.md", "LICENSE.txt"] }
// 13:   let(:files_hash_one) { [@h3[0..6], ["LICENSE.txt"]] }
// 14:   let(:files_hash_two) { [@h2[0..6], ["README.md"]] }
// 15:   let(:cherry_pick_commit) { @cherry_pick_commit[0..6] }
// 16:
// 17:   around do |example|
// 18:     described_class.clear_available_cache
// 19:     example.run
// 20:   ensure
// 21:     described_class.clear_available_cache
// 22:   end
// 23:
// 24:   before do
// 25:     git = HOMEBREW_SHIMS_PATH/"shared/git"
// 26:
// 27:     HOMEBREW_CACHE.cd do
// 28:       system git, "init"
// 29:
// 30:       File.write("README.md", "README")
// 31:       system git, "add", HOMEBREW_CACHE/"README.md"
// 32:       system git, "commit", "-m", "File added"
// 33:       @h1 = `git rev-parse HEAD`
// 34:
// 35:       File.write("README.md", "# README")
// 36:       system git, "add", HOMEBREW_CACHE/"README.md"
// 37:       system git, "commit", "-m", "written to File"
// 38:       @h2 = `git rev-parse HEAD`
// 39:
// 40:       File.write("LICENSE.txt", "LICENCE")
// 41:       system git, "add", HOMEBREW_CACHE/"LICENSE.txt"
// 42:       system git, "commit", "-m", "File added"
// 43:       @h3 = `git rev-parse HEAD`
// 44:
// 45:       File.write("LICENSE.txt", "LICENSE")
// 46:       system git, "add", HOMEBREW_CACHE/"LICENSE.txt"
// 47:       system git, "commit", "-m", "written to File"
// 48:
// 49:       File.write("LICENSE.txt", "test")
// 50:       system git, "add", HOMEBREW_CACHE/"LICENSE.txt"
// 51:       system git, "commit", "-m", "written to File"
// 52:       @cherry_pick_commit = `git rev-parse HEAD`
// 53:       system git, "reset", "--hard", "HEAD^"
// 54:     end
// 55:   end
// 56:
// 57:   # rubocop:enable RSpec/InstanceVariable
// 58:
// 59:   describe "#cherry_pick!" do
// 60:     it "can cherry pick a commit" do
// 61:       expect(described_class.cherry_pick!(HOMEBREW_CACHE, cherry_pick_commit)).to be_truthy
// 62:     end
// 63:
// 64:     it "aborts when cherry picking an existing hash" do
// 65:       ENV["GIT_MERGE_VERBOSITY"] = "5" # Consistent output across git versions
// 66:       expect do
// 67:         described_class.cherry_pick!(HOMEBREW_CACHE, file_hash_one)
// 68:       end.to raise_error(ErrorDuringExecution, /Merge conflict in README.md/)
// 69:     end
// 70:   end
// 71:
// 72:   describe "#last_revision_commit_of_file" do
// 73:     it "gives last revision commit when before_commit is nil" do
// 74:       expect(
// 75:         described_class.last_revision_commit_of_file(HOMEBREW_CACHE, file),
// 76:       ).to eq(file_hash_one)
// 77:     end
// 78:
// 79:     it "gives revision commit based on before_commit when it is not nil" do
// 80:       expect(
// 81:         described_class.last_revision_commit_of_file(HOMEBREW_CACHE,
// 82:                                                      file,
// 83:                                                      before_commit: file_hash_two),
// 84:       ).to eq(file_hash_two)
// 85:     end
// 86:   end
// 87:
// 88:   describe "#file_at_commit" do
// 89:     it "returns file contents when file exists" do
// 90:       expect(described_class.file_at_commit(HOMEBREW_CACHE, file, file_hash_one)).to eq("README")
// 91:     end
// 92:
// 93:     it "returns empty when file doesn't exist" do
// 94:       expect(described_class.file_at_commit(HOMEBREW_CACHE, "foo.txt", file_hash_one)).to eq("")
// 95:       expect(described_class.file_at_commit(HOMEBREW_CACHE, "LICENSE.txt", file_hash_one)).to eq("")
// 96:     end
// 97:   end
// 98:
// 99:   describe "::changed_files" do
// 100:     it "diffs against the `origin/HEAD` merge-base, ignoring a stale local default branch" do
// 101:       git = HOMEBREW_SHIMS_PATH/"shared/git"
// 102:       HOMEBREW_CACHE.cd do
// 103:         system git, "checkout", "--quiet", "-b", "feature"
// 104:         system git, "update-ref", "refs/remotes/origin/HEAD", "HEAD" # up-to-date upstream
// 105:         system git, "branch", "--force", "main", "HEAD~2" # stale local default branch
// 106:         File.write("README.md", "changed")
// 107:       end
// 108:
// 109:       expect(described_class.changed_files(HOMEBREW_CACHE)).to eq(["README.md"])
// 110:     end
// 111:   end
// 112:
// 113:   describe "#last_revision_commit_of_files" do
// 114:     context "when before_commit is nil" do
// 115:       it "gives last revision commit" do
// 116:         expect(
// 117:           described_class.last_revision_commit_of_files(HOMEBREW_CACHE, files),
// 118:         ).to eq(files_hash_one)
// 119:       end
// 120:     end
// 121:
// 122:     context "when before_commit is not nil" do
// 123:       it "gives last revision commit" do
// 124:         expect(
// 125:           described_class.last_revision_commit_of_files(HOMEBREW_CACHE,
// 126:                                                         files,
// 127:                                                         before_commit: file_hash_two),
// 128:         ).to eq(files_hash_two)
// 129:       end
// 130:     end
// 131:   end
// 132:
// 133:   describe "#last_revision_of_file" do
// 134:     it "returns last revision of file" do
// 135:       expect(
// 136:         described_class.last_revision_of_file(HOMEBREW_CACHE,
// 137:                                               HOMEBREW_CACHE/file),
// 138:       ).to eq("README")
// 139:     end
// 140:
// 141:     it "returns last revision of file based on before_commit" do
// 142:       expect(
// 143:         described_class.last_revision_of_file(HOMEBREW_CACHE, HOMEBREW_CACHE/file,
// 144:                                               before_commit: "0..3"),
// 145:       ).to eq("# README")
// 146:     end
// 147:   end
// 148:
// 149:   describe "::available?" do
// 150:     it "returns true if git --version command succeeds" do
// 151:       expect(described_class).to be_available
// 152:     end
// 153:
// 154:     it "returns false if git --version command does not succeed" do
// 155:       stub_const("HOMEBREW_SHIMS_PATH", HOMEBREW_PREFIX/"bin/shim")
// 156:       expect(described_class).not_to be_available
// 157:     end
// 158:   end
// 159:
// 160:   describe "::path" do
// 161:     it "returns nil when git is not available" do
// 162:       stub_const("HOMEBREW_SHIMS_PATH", HOMEBREW_PREFIX/"bin/shim")
// 163:       expect(described_class.path).to be_nil
// 164:     end
// 165:
// 166:     it "returns path of git when git is available" do
// 167:       expect(described_class.path).to end_with("git")
// 168:     end
// 169:   end
// 170:
// 171:   describe "::version" do
// 172:     it "returns null when git is not available" do
// 173:       stub_const("HOMEBREW_SHIMS_PATH", HOMEBREW_PREFIX/"bin/shim")
// 174:       expect(described_class.version).to be Version::NULL
// 175:     end
// 176:
// 177:     it "returns version of git when git is available" do
// 178:       expect(described_class.version).to be > Version::NULL
// 179:     end
// 180:   end
// 181:
// 182:   describe "::ensure_installed!" do
// 183:     it "doesn't fail if git already available" do
// 184:       expect { described_class.ensure_installed! }.not_to raise_error
// 185:     end
// 186:
// 187:     context "when git is not already available" do
// 188:       before do
// 189:         stub_const("HOMEBREW_SHIMS_PATH", HOMEBREW_PREFIX/"bin/shim")
// 190:       end
// 191:
// 192:       it "can't install brewed git if homebrew/core is unavailable" do
// 193:         allow_any_instance_of(Pathname).to receive(:directory?).and_return(false)
// 194:         expect { described_class.ensure_installed! }.to raise_error("Git is unavailable")
// 195:       end
// 196:
// 197:       it "raises error if can't install git" do
// 198:         allow(CoreTap.instance).to receive(:installed?).and_return(true)
// 199:         formula_double = instance_double(Formula)
// 200:         allow(Formula).to receive(:[]).with("git").and_return(formula_double)
// 201:         allow(formula_double).to receive(:ensure_installed!).with(executable: "git").and_raise(RuntimeError)
// 202:
// 203:         expect { described_class.ensure_installed! }.to raise_error("Git is unavailable")
// 204:       end
// 205:
// 206:       unless ENV["HOMEBREW_TEST_GENERIC_OS"]
// 207:         it "keeps using the git shim after the formula install helper" do
// 208:           expect(described_class).to receive(:available?).and_return(false)
// 209:           allow(CoreTap.instance).to receive(:installed?).and_return(true)
// 210:           formula_double = instance_double(Formula)
// 211:           allow(Formula).to receive(:[]).with("git").and_return(formula_double)
// 212:           allow(formula_double).to receive(:ensure_installed!).with(executable: "git")
// 213:                                                               .and_return(Pathname.new("/usr/bin/git"))
// 214:           expect(described_class).to receive(:available?).and_return(true)
// 215:
// 216:           described_class.ensure_installed!
// 217:
// 218:           expect(described_class.git).to eq(HOMEBREW_SHIMS_PATH/"shared/git")
// 219:         end
// 220:       end
// 221:     end
// 222:   end
// 223:
// 224:   describe "::remote_exists?" do
// 225:     it "returns true when git is not available" do
// 226:       stub_const("HOMEBREW_SHIMS_PATH", HOMEBREW_PREFIX/"bin/shim")
// 227:       expect(described_class).to be_remote_exists("blah")
// 228:     end
// 229:
// 230:     context "when git is available" do
// 231:       it "terminates options before the URL" do
// 232:         expect(described_class).to receive(:quiet_system)
// 233:           .with("git", "ls-remote", "--end-of-options", "-u:evil")
// 234:           .and_return(false)
// 235:
// 236:         described_class.remote_exists?("-u:evil")
// 237:       end
// 238:
// 239:       it "returns true when git remote exists", :needs_network do
// 240:         git = HOMEBREW_SHIMS_PATH/"shared/git"
// 241:         url = "https://github.com/Homebrew/homebrew.github.io"
// 242:         repo = HOMEBREW_CACHE/"hey"
// 243:         repo.mkpath
// 244:
// 245:         repo.cd do
// 246:           system git, "init"
// 247:           system git, "remote", "add", "origin", url
// 248:         end
// 249:
// 250:         expect(described_class).to be_remote_exists(url)
// 251:       end
// 252:
// 253:       it "returns false when git remote does not exist" do
// 254:         expect(described_class).not_to be_remote_exists("blah")
// 255:       end
// 256:     end
// 257:   end
// 258: end
