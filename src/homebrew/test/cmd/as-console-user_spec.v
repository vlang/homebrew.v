module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/as-console-user_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:as_console_user_script) { HOMEBREW_LIBRARY_PATH/"cmd/as-console-user.sh" }` at line 10.
pub fn ruby_as_console_user_spec_l10_d1_as_console_user_script(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('as_console_user_script', ...args)
}

// Ruby let `let(:repository_root) { HOMEBREW_LIBRARY_PATH.parent.parent }` at line 11.
pub fn ruby_as_console_user_spec_l11_d2_repository_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repository_root', ...args)
}

// Ruby let `let(:test_root) { mktmpdir }` at line 12.
pub fn ruby_as_console_user_spec_l12_d3_test_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test_root', ...args)
}

// Ruby let `let(:macos_user_script) { repository_root/"Library/Homebrew/utils/macos_user.sh" }` at line 13.
pub fn ruby_as_console_user_spec_l13_d4_macos_user_script(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_user_script', ...args)
}

// Ruby let `let(:macos_env) do` at line 15.
pub fn ruby_as_console_user_spec_l15_d5_macos_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_env', ...args)
}

// Ruby method `run_as_console_user_shell(script, env = {})` at line 25.
pub fn ruby_as_console_user_spec_l25_d6_run_as_console_user_shell(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run_as_console_user_shell', ...args)
}

// Ruby it `it "prints help and fails when no command is provided" do` at line 31.
pub fn ruby_as_console_user_spec_l31_d7_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "rejects a root console user" do` at line 47.
pub fn ruby_as_console_user_spec_l47_d8_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects a loginwindow console user" do` at line 63.
pub fn ruby_as_console_user_spec_l63_d9_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects non-macOS systems" do` at line 79.
pub fn ruby_as_console_user_spec_l79_d10_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "uses the package user plist before the console user" do` at line 95.
pub fn ruby_as_console_user_spec_l95_d11_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "honours a root-owned plist that carries extended attributes" do` at line 115.
pub fn ruby_as_console_user_spec_l115_d12_honours(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('honours', ...args)
}

// Ruby it `it "ignores a package user plist not owned by root" do` at line 135.
pub fn ruby_as_console_user_spec_l135_d13_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "ignores a package user plist with loose permissions" do` at line 155.
pub fn ruby_as_console_user_spec_l155_d14_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "ignores a package user plist carrying an ACL" do` at line 175.
pub fn ruby_as_console_user_spec_l175_d15_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "ignores a package user plist that is a symlink" do` at line 195.
pub fn ruby_as_console_user_spec_l195_d16_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "falls back to the console user without a package user plist" do` at line 217.
pub fn ruby_as_console_user_spec_l217_d17_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "rejects package user lookup without a package user or console user" do` at line 229.
pub fn ruby_as_console_user_spec_l229_d18_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "dispatches the nested brew command as the console user" do` at line 241.
pub fn ruby_as_console_user_spec_l241_d19_dispatches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dispatches', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: require "cmd/shared_examples/args_parse"
// 7: require "cmd/as-console-user"
// 8:
// 9: RSpec.describe Homebrew::Cmd::AsConsoleUser do
// 10:   let(:as_console_user_script) { HOMEBREW_LIBRARY_PATH/"cmd/as-console-user.sh" }
// 11:   let(:repository_root) { HOMEBREW_LIBRARY_PATH.parent.parent }
// 12:   let(:test_root) { mktmpdir }
// 13:   let(:macos_user_script) { repository_root/"Library/Homebrew/utils/macos_user.sh" }
// 14:
// 15:   let(:macos_env) do
// 16:     {
// 17:       "HOMEBREW_BREW_FILE" => "brew",
// 18:       "HOMEBREW_LIBRARY"   => (repository_root/"Library").to_s,
// 19:       "HOMEBREW_MACOS"     => "1",
// 20:     }
// 21:   end
// 22:
// 23:   it_behaves_like "parseable arguments"
// 24:
// 25:   def run_as_console_user_shell(script, env = {})
// 26:     Bundler.with_unbundled_env do
// 27:       Open3.capture3(env, "/bin/bash", "-c", script)
// 28:     end
// 29:   end
// 30:
// 31:   it "prints help and fails when no command is provided" do
// 32:     stdout, stderr, status = run_as_console_user_shell(
// 33:       <<~SH,
// 34:         source "#{as_console_user_script}"
// 35:         brew() { printf '%s\\n' "$*" >&2; }
// 36:         homebrew-as-console-user
// 37:       SH
// 38:       "HOMEBREW_BREW_FILE" => "brew",
// 39:       "HOMEBREW_LIBRARY"   => (repository_root/"Library").to_s,
// 40:     )
// 41:
// 42:     expect(status.exitstatus).to eq 1
// 43:     expect(stdout).to be_empty
// 44:     expect(stderr).to eq("help as-console-user\n")
// 45:   end
// 46:
// 47:   it "rejects a root console user" do
// 48:     stdout, stderr, status = run_as_console_user_shell(
// 49:       <<~SH,
// 50:         source "#{as_console_user_script}"
// 51:         odie() { echo "Error: $*" >&2; exit 1; }
// 52:         stat() { printf 'root\\n'; }
// 53:         homebrew-as-console-user install wget
// 54:       SH
// 55:       macos_env,
// 56:     )
// 57:
// 58:     expect(status.exitstatus).to eq 1
// 59:     expect(stdout).to be_empty
// 60:     expect(stderr).to eq("Error: No supported macOS console user is logged in.\n")
// 61:   end
// 62:
// 63:   it "rejects a loginwindow console user" do
// 64:     stdout, stderr, status = run_as_console_user_shell(
// 65:       <<~SH,
// 66:         source "#{as_console_user_script}"
// 67:         odie() { echo "Error: $*" >&2; exit 1; }
// 68:         stat() { printf 'loginwindow\\n'; }
// 69:         homebrew-as-console-user install wget
// 70:       SH
// 71:       macos_env,
// 72:     )
// 73:
// 74:     expect(status.exitstatus).to eq 1
// 75:     expect(stdout).to be_empty
// 76:     expect(stderr).to eq("Error: No supported macOS console user is logged in.\n")
// 77:   end
// 78:
// 79:   it "rejects non-macOS systems" do
// 80:     stdout, stderr, status = run_as_console_user_shell(
// 81:       <<~SH,
// 82:         source "#{as_console_user_script}"
// 83:         odie() { echo "Error: $*" >&2; exit 1; }
// 84:         homebrew-as-console-user install wget
// 85:       SH
// 86:       "HOMEBREW_BREW_FILE" => "brew",
// 87:       "HOMEBREW_LIBRARY"   => (repository_root/"Library").to_s,
// 88:     )
// 89:
// 90:     expect(status.exitstatus).to eq 1
// 91:     expect(stdout).to be_empty
// 92:     expect(stderr).to eq("Error: `brew as-console-user` is only supported on macOS.\n")
// 93:   end
// 94:
// 95:   it "uses the package user plist before the console user" do
// 96:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 97:     homebrew_pkg_user_plist.write "plist"
// 98:
// 99:     stdout, stderr, status = run_as_console_user_shell(
// 100:       <<~SH,
// 101:         source "#{macos_user_script}"
// 102:         defaults() { printf 'munki\\n'; }
// 103:         stat() { printf 'root 600\\n'; }
// 104:         ls() { printf -- '-rw------- 1 root wheel 0 x\\n'; }
// 105:         homebrew-package-user
// 106:       SH
// 107:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 108:     )
// 109:
// 110:     expect(status.success?).to be true
// 111:     expect(stdout).to eq("munki\n")
// 112:     expect(stderr).to be_empty
// 113:   end
// 114:
// 115:   it "honours a root-owned plist that carries extended attributes" do
// 116:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 117:     homebrew_pkg_user_plist.write "plist"
// 118:
// 119:     stdout, stderr, status = run_as_console_user_shell(
// 120:       <<~SH,
// 121:         source "#{macos_user_script}"
// 122:         defaults() { printf 'munki\\n'; }
// 123:         stat() { printf 'root 600\\n'; }
// 124:         ls() { printf -- '-rw-------@ 1 root wheel 0 x\\n'; }
// 125:         homebrew-package-user
// 126:       SH
// 127:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 128:     )
// 129:
// 130:     expect(status.success?).to be true
// 131:     expect(stdout).to eq("munki\n")
// 132:     expect(stderr).to be_empty
// 133:   end
// 134:
// 135:   it "ignores a package user plist not owned by root" do
// 136:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 137:     homebrew_pkg_user_plist.write "plist"
// 138:
// 139:     stdout, stderr, status = run_as_console_user_shell(
// 140:       <<~SH,
// 141:         source "#{macos_user_script}"
// 142:         defaults() { printf 'attacker\\n'; }
// 143:         stat() { case "$*" in *"/dev/console") printf 'root\\n';; *) printf 'attacker 600\\n';; esac; }
// 144:         ls() { printf -- '-rw------- 1 attacker staff 0 x\\n'; }
// 145:         homebrew-package-user
// 146:       SH
// 147:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 148:     )
// 149:
// 150:     expect(status.exitstatus).to eq 1
// 151:     expect(stdout).to be_empty
// 152:     expect(stderr).to be_empty
// 153:   end
// 154:
// 155:   it "ignores a package user plist with loose permissions" do
// 156:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 157:     homebrew_pkg_user_plist.write "plist"
// 158:
// 159:     stdout, stderr, status = run_as_console_user_shell(
// 160:       <<~SH,
// 161:         source "#{macos_user_script}"
// 162:         defaults() { printf 'attacker\\n'; }
// 163:         stat() { case "$*" in *"/dev/console") printf 'root\\n';; *) printf 'root 644\\n';; esac; }
// 164:         ls() { printf -- '-rw-rw-rw- 1 root wheel 0 x\\n'; }
// 165:         homebrew-package-user
// 166:       SH
// 167:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 168:     )
// 169:
// 170:     expect(status.exitstatus).to eq 1
// 171:     expect(stdout).to be_empty
// 172:     expect(stderr).to be_empty
// 173:   end
// 174:
// 175:   it "ignores a package user plist carrying an ACL" do
// 176:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 177:     homebrew_pkg_user_plist.write "plist"
// 178:
// 179:     stdout, stderr, status = run_as_console_user_shell(
// 180:       <<~SH,
// 181:         source "#{macos_user_script}"
// 182:         defaults() { printf 'attacker\\n'; }
// 183:         stat() { case "$*" in *"/dev/console") printf 'root\\n';; *) printf 'root 600\\n';; esac; }
// 184:         ls() { printf -- '-rw-------@ 1 root wheel 0 x\\n 0: group:everyone deny delete\\n'; }
// 185:         homebrew-package-user
// 186:       SH
// 187:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 188:     )
// 189:
// 190:     expect(status.exitstatus).to eq 1
// 191:     expect(stdout).to be_empty
// 192:     expect(stderr).to be_empty
// 193:   end
// 194:
// 195:   it "ignores a package user plist that is a symlink" do
// 196:     homebrew_pkg_user_target = test_root/"target.plist"
// 197:     homebrew_pkg_user_target.write "plist"
// 198:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 199:     FileUtils.ln_s homebrew_pkg_user_target, homebrew_pkg_user_plist
// 200:
// 201:     stdout, stderr, status = run_as_console_user_shell(
// 202:       <<~SH,
// 203:         source "#{macos_user_script}"
// 204:         defaults() { printf 'attacker\\n'; }
// 205:         stat() { case "$*" in *"/dev/console") printf 'root\\n';; *) printf 'root\\n';; esac; }
// 206:         ls() { printf -- '-rw------- 1 root wheel 0 x\\n'; }
// 207:         homebrew-package-user
// 208:       SH
// 209:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 210:     )
// 211:
// 212:     expect(status.exitstatus).to eq 1
// 213:     expect(stdout).to be_empty
// 214:     expect(stderr).to be_empty
// 215:   end
// 216:
// 217:   it "falls back to the console user without a package user plist" do
// 218:     stdout, stderr, status = run_as_console_user_shell <<~SH
// 219:       source "#{macos_user_script}"
// 220:       stat() { printf 'mike\\n'; }
// 221:       homebrew-package-user
// 222:     SH
// 223:
// 224:     expect(status.success?).to be true
// 225:     expect(stdout).to eq("mike\n")
// 226:     expect(stderr).to be_empty
// 227:   end
// 228:
// 229:   it "rejects package user lookup without a package user or console user" do
// 230:     stdout, stderr, status = run_as_console_user_shell <<~SH
// 231:       source "#{macos_user_script}"
// 232:       stat() { printf 'root\\n'; }
// 233:       homebrew-package-user
// 234:     SH
// 235:
// 236:     expect(status.exitstatus).to eq 1
// 237:     expect(stdout).to be_empty
// 238:     expect(stderr).to be_empty
// 239:   end
// 240:
// 241:   it "dispatches the nested brew command as the console user" do
// 242:     args_file = test_root/"sudo-args.txt"
// 243:     console_home = test_root/"console-home"
// 244:     console_home.mkpath
// 245:
// 246:     stdout, stderr, status = run_as_console_user_shell(
// 247:       <<~SH,
// 248:         source "#{as_console_user_script}"
// 249:         odie() { echo "Error: $*" >&2; exit 1; }
// 250:         stat() { printf 'mike\\n'; }
// 251:         id() { printf 'mike:*:501:20::0:0:Mike:#{console_home}:/bin/zsh\\n'; }
// 252:         sudo() {
// 253:           printf 'cwd=%s\\n' "$PWD" > "#{args_file}"
// 254:           printf '%s\\n' "$@" >> "#{args_file}"
// 255:           return 42
// 256:         }
// 257:         homebrew-as-console-user upgrade git --minimum-version=2.50.1
// 258:       SH
// 259:       macos_env.merge("HOMEBREW_BREW_FILE" => "/opt/homebrew/bin/brew"),
// 260:     )
// 261:
// 262:     expect(status.exitstatus).to eq 42
// 263:     expect(stdout).to be_empty
// 264:     expect(stderr).to be_empty
// 265:     expect(args_file.read).to eq <<~EOS
// 266:       cwd=#{console_home}
// 267:       -H
// 268:       -u
// 269:       mike
// 270:       /usr/bin/env
// 271:       -i
// 272:       HOME=#{console_home}
// 273:       USER=mike
// 274:       LOGNAME=mike
// 275:       PWD=#{console_home}
// 276:       PATH=/usr/bin:/bin:/usr/sbin:/sbin
// 277:       /opt/homebrew/bin/brew
// 278:       upgrade
// 279:       git
// 280:       --minimum-version=2.50.1
// 281:     EOS
// 282:   end
// 283: end
