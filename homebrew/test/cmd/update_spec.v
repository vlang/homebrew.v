module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/update_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:update_script) { repository_root/"Library/Homebrew/cmd/update.sh" }` at line 10.
pub fn ruby_update_spec_l10_d1_update_script(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update_script', ...args)
}

// Ruby let `let(:test_root) do` at line 11.
pub fn ruby_update_spec_l11_d2_test_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test_root', ...args)
}

// Ruby let `let(:repository_root) { Pathname(T.must(__dir__)).parent.parent.parent.parent }` at line 15.
pub fn ruby_update_spec_l15_d3_repository_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repository_root', ...args)
}

// Ruby method `run_update_shell(script, env)` at line 23.
pub fn ruby_update_spec_l23_d4_run_update_shell(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run_update_shell', ...args)
}

// Ruby method `setup_update_utils` at line 29.
pub fn ruby_update_spec_l29_d5_setup_update_utils(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_update_utils', ...args)
}

// Ruby it `it "retries a failed conditional API download without the time condition" do` at line 38.
pub fn ruby_update_spec_l38_d6_retries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retries', ...args)
}

// Ruby it `it "passes all arguments through to delegated upgrades" do` at line 77.
pub fn ruby_update_spec_l77_d7_passes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('passes', ...args)
}

// Ruby it `it "passes `--auto-update` through to `update-report`" do` at line 106.
pub fn ruby_update_spec_l106_d8_passes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('passes', ...args)
}

// Ruby it `it "does not query redirected remote metadata for no-op tap updates" do` at line 147.
pub fn ruby_update_spec_l147_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "treats redirected tap SHA API checks as updates" do` at line 252.
pub fn ruby_update_spec_l252_d10_treats(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('treats', ...args)
}

// Ruby it `it "queries redirected remote metadata only for taps" do` at line 366.
pub fn ruby_update_spec_l366_d11_queries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('queries', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: require "cmd/shared_examples/args_parse"
// 7: require "cmd/update"
// 8:
// 9: RSpec.describe Homebrew::Cmd::Update do
// 10:   let(:update_script) { repository_root/"Library/Homebrew/cmd/update.sh" }
// 11:   let(:test_root) do
// 12:     (repository_root/"tmp").mkpath
// 13:     Pathname(Dir.mktmpdir("brew-update-", repository_root/"tmp"))
// 14:   end
// 15:   let(:repository_root) { Pathname(T.must(__dir__)).parent.parent.parent.parent }
// 16:
// 17:   after do
// 18:     FileUtils.rm_rf test_root
// 19:   end
// 20:
// 21:   it_behaves_like "parseable arguments"
// 22:
// 23:   def run_update_shell(script, env)
// 24:     Bundler.with_unbundled_env do
// 25:       Open3.capture3(env, "/bin/bash", "-c", script)
// 26:     end
// 27:   end
// 28:
// 29:   def setup_update_utils
// 30:     (test_root/"Library/Homebrew/utils").mkpath
// 31:     FileUtils.ln_s repository_root/"Library/Homebrew/utils.sh", test_root/"Library/Homebrew/utils.sh"
// 32:     %w[api cmd executables formatter lock tty].each do |name|
// 33:       FileUtils.ln_s repository_root/"Library/Homebrew/utils/#{name}.sh",
// 34:                      test_root/"Library/Homebrew/utils/#{name}.sh"
// 35:     end
// 36:   end
// 37:
// 38:   it "retries a failed conditional API download without the time condition" do
// 39:     cache_path = test_root/"cache/api/formula.jws.json"
// 40:     requests_file = test_root/"requests.txt"
// 41:     update_failed_file = test_root/"update_failed.txt"
// 42:     setup_update_utils
// 43:     cache_path.dirname.mkpath
// 44:     cache_path.write "cached"
// 45:
// 46:     _stdout, stderr, status = run_update_shell(
// 47:       <<~SH,
// 48:         source "#{update_script}"
// 49:         curl() {
// 50:           if [[ "$*" == *"--time-cond"* ]]
// 51:           then
// 52:             echo conditional >> "#{requests_file}"
// 53:             return 56
// 54:           fi
// 55:
// 56:           echo unconditional >> "#{requests_file}"
// 57:           printf fresh > "#{cache_path}"
// 58:         }
// 59:         fetch_api_file formula.jws.json "#{update_failed_file}"
// 60:       SH
// 61:       {
// 62:         "HOMEBREW_API_DEFAULT_DOMAIN" => "https://formulae.example/api",
// 63:         "HOMEBREW_API_DOMAIN"         => nil,
// 64:         "HOMEBREW_CACHE"              => (test_root/"cache").to_s,
// 65:         "HOMEBREW_CURL_SPEED_LIMIT"   => "100",
// 66:         "HOMEBREW_CURL_SPEED_TIME"    => "5",
// 67:         "HOMEBREW_LIBRARY"            => (test_root/"Library").to_s,
// 68:         "HOMEBREW_USER_AGENT_CURL"    => "Homebrew/test",
// 69:       },
// 70:     )
// 71:
// 72:     expect([status.success?, stderr, requests_file.read, cache_path.read, update_failed_file.exist?]).to eq(
// 73:       [true, "", "conditional\nunconditional\n", "fresh", false],
// 74:     )
// 75:   end
// 76:
// 77:   it "passes all arguments through to delegated upgrades" do
// 78:     args_file = test_root/"brew-args.txt"
// 79:     brew_wrapper = test_root/"brew-wrapper"
// 80:     setup_update_utils
// 81:     brew_wrapper.write <<~SH
// 82:       #!/bin/bash
// 83:       printf '%s\n' "$@" > "#{args_file}"
// 84:     SH
// 85:     brew_wrapper.chmod 0755
// 86:
// 87:     _stdout, stderr, status = run_update_shell(
// 88:       <<~SH,
// 89:         source "#{update_script}"
// 90:         opoo() { echo "Warning: $*" >&2; }
// 91:         homebrew-update testball --auto-update --merge
// 92:       SH
// 93:       {
// 94:         "HOMEBREW_BREW_FILE" => brew_wrapper.to_s,
// 95:         "HOMEBREW_LIBRARY"   => (test_root/"Library").to_s,
// 96:       },
// 97:     )
// 98:
// 99:     expect(status.success?).to be true
// 100:     expect(stderr).to eq(
// 101:       "Warning: Use `brew upgrade testball --auto-update --merge` to upgrade formulae; running it instead.\n",
// 102:     )
// 103:     expect(args_file.read).to eq("upgrade\ntestball\n--auto-update\n--merge\n")
// 104:   end
// 105:
// 106:   it "passes `--auto-update` through to `update-report`" do
// 107:     args_file = test_root/"brew-args.txt"
// 108:     setup_update_utils
// 109:     (test_root/"cache").mkpath
// 110:     (test_root/"repository").mkpath
// 111:
// 112:     _stdout, stderr, status = run_update_shell(
// 113:       <<~SH,
// 114:         source "#{update_script}"
// 115:         brew() { printf '%s\n' "$@" > "#{args_file}"; }
// 116:         fetch_api_file() { :; }
// 117:         git_init_if_necessary() { :; }
// 118:         git() {
// 119:           [[ "$1" == "--version" ]] && return 0
// 120:           return 1
// 121:         }
// 122:         lock() { :; }
// 123:         odie() { echo "Error: $*" >&2; exit 1; }
// 124:         ohai() { :; }
// 125:         onoe() { echo "Error: $*" >&2; }
// 126:         safe_cd() { cd "$1" >/dev/null || exit 1; }
// 127:         setup_ca_certificates() { :; }
// 128:         setup_curl() { :; }
// 129:         setup_git() { :; }
// 130:         homebrew-update --auto-update
// 131:       SH
// 132:       {
// 133:         "HOMEBREW_CACHE"               => (test_root/"cache").to_s,
// 134:         "HOMEBREW_CELLAR"              => (test_root/"cellar").to_s,
// 135:         "HOMEBREW_LIBRARY"             => (test_root/"Library").to_s,
// 136:         "HOMEBREW_NO_INSTALL_FROM_API" => "1",
// 137:         "HOMEBREW_PREFIX"              => (test_root/"prefix").to_s,
// 138:         "HOMEBREW_REPOSITORY"          => (test_root/"repository").to_s,
// 139:       },
// 140:     )
// 141:
// 142:     expect(status.success?).to be true
// 143:     expect(stderr).to be_empty
// 144:     expect(args_file.read).to eq("update-report\n--auto-update\n")
// 145:   end
// 146:
// 147:   it "does not query redirected remote metadata for no-op tap updates" do
// 148:     args_file = test_root/"brew-args.txt"
// 149:     fetches_file = test_root/"fetches.txt"
// 150:     metadata_queries_file = test_root/"metadata-queries.txt"
// 151:     repository = test_root/"repository"
// 152:     tap_path = test_root/"Library/Taps/old/homebrew-foo"
// 153:     setup_update_utils
// 154:     (repository/".git").mkpath
// 155:     (tap_path/".git").mkpath
// 156:     (test_root/"cache").mkpath
// 157:     (test_root/"cache/all_commands_list.txt").write ""
// 158:
// 159:     _stdout, stderr, status = run_update_shell(
// 160:       <<~SH,
// 161:         source "#{update_script}"
// 162:         brew() { printf '%s\\n' "$@" > "#{args_file}"; return 1; }
// 163:         fetch_api_file() { :; }
// 164:         git_init_if_necessary() { :; }
// 165:         git() {
// 166:           case "$*" in
// 167:             "--version") return 0 ;;
// 168:             "config --local --get remote.origin.url" | "config remote.origin.url")
// 169:               if [[ "$PWD" == "#{tap_path}" ]]
// 170:               then
// 171:                 echo "https://github.com/old/homebrew-foo"
// 172:               else
// 173:                 echo "https://github.com/Homebrew/brew"
// 174:               fi
// 175:               return 0
// 176:               ;;
// 177:             "symbolic-ref refs/remotes/origin/HEAD")
// 178:               echo "refs/remotes/origin/main"
// 179:               return 0
// 180:               ;;
// 181:             "rev-parse refs/remotes/origin/main" | "rev-parse -q --verify refs/remotes/origin/main" | "rev-parse -q --verify HEAD")
// 182:               echo abc
// 183:               return 0
// 184:               ;;
// 185:             "tag --list")
// 186:               echo "4.0.0"
// 187:               return 0
// 188:               ;;
// 189:             fetch*)
// 190:               echo "$PWD" >> "#{fetches_file}"
// 191:               return 0
// 192:               ;;
// 193:           esac
// 194:           printf 'unexpected git %s\\n' "$*" >&2
// 195:           return 1
// 196:         }
// 197:         curl() {
// 198:           local url
// 199:           for url in "$@"; do :; done
// 200:
// 201:           case "${url}" in
// 202:             "https://api.github.com/repos/Homebrew/brew/tags" | "https://api.github.com/repos/old/homebrew-foo/commits/main")
// 203:               printf '304 %s' "${url}"
// 204:               ;;
// 205:             "https://api.github.com/repos/Homebrew/brew" | "https://api.github.com/repos/old/homebrew-foo")
// 206:               echo "${url}" >> "#{metadata_queries_file}"
// 207:               printf 'unexpected metadata query\\n' >&2
// 208:               return 1
// 209:               ;;
// 210:             *)
// 211:               printf 'unexpected curl %s\\n' "${url}" >&2
// 212:               return 1
// 213:               ;;
// 214:           esac
// 215:         }
// 216:         lock() { :; }
// 217:         odie() { echo "Error: $*" >&2; exit 1; }
// 218:         ohai() { :; }
// 219:         onoe() { echo "Error: $*" >&2; }
// 220:         safe_cd() { cd "$1" &>/dev/null || exit 1; }
// 221:         setup_ca_certificates() { :; }
// 222:         setup_curl() { :; }
// 223:         setup_git() { :; }
// 224:         homebrew-update --auto-update
// 225:       SH
// 226:       {
// 227:         "HOMEBREW_BREW_DEFAULT_GIT_REMOTE" => "https://github.com/Homebrew/brew",
// 228:         "HOMEBREW_BREW_GIT_REMOTE"         => "https://github.com/Homebrew/brew",
// 229:         "HOMEBREW_CACHE"                   => (test_root/"cache").to_s,
// 230:         "HOMEBREW_CASK_REPOSITORY"         => (test_root/"cask").to_s,
// 231:         "HOMEBREW_CELLAR"                  => (test_root/"cellar").to_s,
// 232:         "HOMEBREW_CORE_DEFAULT_GIT_REMOTE" => "https://github.com/Homebrew/homebrew-core",
// 233:         "HOMEBREW_CORE_GIT_REMOTE"         => "https://github.com/Homebrew/homebrew-core",
// 234:         "HOMEBREW_CORE_REPOSITORY"         => (test_root/"core").to_s,
// 235:         "HOMEBREW_DEV_CMD_RUN"             => nil,
// 236:         "HOMEBREW_LIBRARY"                 => (test_root/"Library").to_s,
// 237:         "HOMEBREW_NO_ENV_HINTS"            => "1",
// 238:         "HOMEBREW_NO_INSTALL_FROM_API"     => "1",
// 239:         "HOMEBREW_PREFIX"                  => (test_root/"prefix").to_s,
// 240:         "HOMEBREW_REPOSITORY"              => repository.to_s,
// 241:         "HOMEBREW_USER_AGENT_CURL"         => "Homebrew/test",
// 242:       },
// 243:     )
// 244:
// 245:     expect(status.success?).to be true
// 246:     expect(stderr).to be_empty
// 247:     expect(args_file).not_to exist
// 248:     expect(fetches_file).not_to exist
// 249:     expect(metadata_queries_file).not_to exist
// 250:   end
// 251:
// 252:   it "treats redirected tap SHA API checks as updates" do
// 253:     args_file = test_root/"brew-args.txt"
// 254:     fetches_file = test_root/"fetches.txt"
// 255:     metadata_queries_file = test_root/"metadata-queries.txt"
// 256:     repository = test_root/"repository"
// 257:     tap_path = test_root/"Library/Taps/old/homebrew-foo"
// 258:     setup_update_utils
// 259:     (repository/".git").mkpath
// 260:     (tap_path/".git").mkpath
// 261:     (test_root/"cache").mkpath
// 262:     (test_root/"cache/all_commands_list.txt").write ""
// 263:
// 264:     _stdout, stderr, status = run_update_shell(
// 265:       <<~SH,
// 266:         source "#{update_script}"
// 267:         brew() { printf '%s\\n' "$@" > "#{args_file}"; }
// 268:         fetch_api_file() { :; }
// 269:         git_init_if_necessary() { :; }
// 270:         git() {
// 271:           case "$*" in
// 272:             "--version") return 0 ;;
// 273:             "config --local --get remote.origin.url" | "config remote.origin.url")
// 274:               if [[ "$PWD" == "#{tap_path}" ]]
// 275:               then
// 276:                 echo "https://github.com/old/homebrew-foo"
// 277:               else
// 278:                 echo "https://github.com/Homebrew/brew"
// 279:               fi
// 280:               return 0
// 281:               ;;
// 282:             "symbolic-ref refs/remotes/origin/HEAD")
// 283:               echo "refs/remotes/origin/main"
// 284:               return 0
// 285:               ;;
// 286:             "rev-parse refs/remotes/origin/main" | "rev-parse -q --verify refs/remotes/origin/main" | "rev-parse -q --verify HEAD")
// 287:               echo abc
// 288:               return 0
// 289:               ;;
// 290:             "tag --list")
// 291:               echo "4.0.0"
// 292:               return 0
// 293:               ;;
// 294:             "fetch --tags --force -q origin refs/heads/main:refs/remotes/origin/main")
// 295:               echo "$PWD" >> "#{fetches_file}"
// 296:               return 0
// 297:               ;;
// 298:           esac
// 299:           printf 'unexpected git %s\\n' "$*" >&2
// 300:           return 1
// 301:         }
// 302:         curl() {
// 303:           local url
// 304:           for url in "$@"; do :; done
// 305:
// 306:           case "${url}" in
// 307:             "https://api.github.com/repos/Homebrew/brew/tags")
// 308:               printf '304 %s' "${url}"
// 309:               ;;
// 310:             "https://api.github.com/repos/old/homebrew-foo/commits/main")
// 311:               printf '304 https://api.github.com/repositories/456/commits/main'
// 312:               ;;
// 313:             "https://api.github.com/repos/Homebrew/brew")
// 314:               printf 'unexpected brew metadata query\\n' >&2
// 315:               return 1
// 316:               ;;
// 317:             "https://api.github.com/repos/old/homebrew-foo")
// 318:               echo "${url}" >> "#{metadata_queries_file}"
// 319:               printf '{\\n  "clone_url": "https://github.com/new/homebrew-foo.git",\\n  "html_url": "https://github.com/new/homebrew-foo"\\n}\\n'
// 320:               ;;
// 321:             *)
// 322:               printf 'unexpected curl %s\\n' "${url}" >&2
// 323:               return 1
// 324:               ;;
// 325:           esac
// 326:         }
// 327:         lock() { :; }
// 328:         odie() { echo "Error: $*" >&2; exit 1; }
// 329:         ohai() { :; }
// 330:         onoe() { echo "Error: $*" >&2; }
// 331:         safe_cd() { cd "$1" &>/dev/null || exit 1; }
// 332:         setup_ca_certificates() { :; }
// 333:         setup_curl() { :; }
// 334:         setup_git() { :; }
// 335:         homebrew-update --auto-update
// 336:       SH
// 337:       {
// 338:         "HOMEBREW_BREW_DEFAULT_GIT_REMOTE" => "https://github.com/Homebrew/brew",
// 339:         "HOMEBREW_BREW_GIT_REMOTE"         => "https://github.com/Homebrew/brew",
// 340:         "HOMEBREW_CACHE"                   => (test_root/"cache").to_s,
// 341:         "HOMEBREW_CASK_REPOSITORY"         => (test_root/"cask").to_s,
// 342:         "HOMEBREW_CELLAR"                  => (test_root/"cellar").to_s,
// 343:         "HOMEBREW_CORE_DEFAULT_GIT_REMOTE" => "https://github.com/Homebrew/homebrew-core",
// 344:         "HOMEBREW_CORE_GIT_REMOTE"         => "https://github.com/Homebrew/homebrew-core",
// 345:         "HOMEBREW_CORE_REPOSITORY"         => (test_root/"core").to_s,
// 346:         "HOMEBREW_DEV_CMD_RUN"             => nil,
// 347:         "HOMEBREW_LIBRARY"                 => (test_root/"Library").to_s,
// 348:         "HOMEBREW_NO_ENV_HINTS"            => "1",
// 349:         "HOMEBREW_NO_INSTALL_FROM_API"     => "1",
// 350:         "HOMEBREW_PREFIX"                  => (test_root/"prefix").to_s,
// 351:         "HOMEBREW_REPOSITORY"              => repository.to_s,
// 352:         "HOMEBREW_USER_AGENT_CURL"         => "Homebrew/test",
// 353:       },
// 354:     )
// 355:
// 356:     expect(status.success?).to be true
// 357:     expect(stderr).to be_empty
// 358:     expect(args_file.read).to eq("update-report\n--auto-update\n")
// 359:     expect(fetches_file.read).to eq("#{tap_path}\n")
// 360:     expect((repository/".git/REDIRECTED_REMOTES").read).to eq(
// 361:       "#{tap_path}\thttps://github.com/new/homebrew-foo.git\n",
// 362:     )
// 363:     expect(metadata_queries_file.read).to eq("https://api.github.com/repos/old/homebrew-foo\n")
// 364:   end
// 365:
// 366:   it "queries redirected remote metadata only for taps" do
// 367:     args_file = test_root/"brew-args.txt"
// 368:     metadata_queries_file = test_root/"metadata-queries.txt"
// 369:     repository = test_root/"repository"
// 370:     tap_path = test_root/"Library/Taps/old/homebrew-foo"
// 371:     setup_update_utils
// 372:     (repository/".git").mkpath
// 373:     (tap_path/".git").mkpath
// 374:     (test_root/"cache").mkpath
// 375:     (test_root/"cache/all_commands_list.txt").write ""
// 376:
// 377:     _stdout, stderr, status = run_update_shell(
// 378:       <<~SH,
// 379:         source "#{update_script}"
// 380:         brew() { printf '%s\\n' "$@" > "#{args_file}"; }
// 381:         fetch_api_file() { :; }
// 382:         git_init_if_necessary() { :; }
// 383:         git() {
// 384:           case "$*" in
// 385:             "--version") return 0 ;;
// 386:             "config --local --get remote.origin.url" | "config remote.origin.url")
// 387:               if [[ "$PWD" == "#{tap_path}" ]]
// 388:               then
// 389:                 echo "https://github.com/old/homebrew-foo"
// 390:               else
// 391:                 echo "https://github.com/Homebrew/brew"
// 392:               fi
// 393:               return 0
// 394:               ;;
// 395:             "symbolic-ref refs/remotes/origin/HEAD")
// 396:               echo "refs/remotes/origin/main"
// 397:               return 0
// 398:               ;;
// 399:             "rev-parse refs/remotes/origin/main" | "rev-parse -q --verify refs/remotes/origin/main" | "rev-parse -q --verify HEAD" | "rev-parse -q --verify main")
// 400:               echo abc
// 401:               return 0
// 402:               ;;
// 403:             "merge-base --is-ancestor abc abc")
// 404:               return 0
// 405:               ;;
// 406:             "tag --list")
// 407:               echo "4.0.0"
// 408:               return 0
// 409:               ;;
// 410:             "fetch --tags --force -q origin refs/heads/main:refs/remotes/origin/main")
// 411:               return 0
// 412:               ;;
// 413:           esac
// 414:           printf 'unexpected git %s\\n' "$*" >&2
// 415:           return 1
// 416:         }
// 417:         curl() {
// 418:           local url
// 419:           for url in "$@"; do :; done
// 420:
// 421:           case "${url}" in
// 422:             "https://api.github.com/repos/Homebrew/brew/tags")
// 423:               printf 'unexpected brew API query\\n' >&2
// 424:               return 1
// 425:               ;;
// 426:             "https://api.github.com/repos/old/homebrew-foo/commits/main")
// 427:               printf '304 https://api.github.com/repositories/456/commits/main'
// 428:               ;;
// 429:             "https://api.github.com/repos/Homebrew/brew" | "https://api.github.com/repos/old/homebrew-foo")
// 430:               echo "${url}" >> "#{metadata_queries_file}"
// 431:               printf '{\\n  "clone_url": "https://github.com/new/homebrew-foo.git",\\n  "html_url": "https://github.com/new/homebrew-foo"\\n}\\n'
// 432:               ;;
// 433:             *)
// 434:               printf 'unexpected curl %s\\n' "${url}" >&2
// 435:               return 1
// 436:               ;;
// 437:           esac
// 438:         }
// 439:         lock() { :; }
// 440:         odie() { echo "Error: $*" >&2; exit 1; }
// 441:         ohai() { :; }
// 442:         onoe() { echo "Error: $*" >&2; }
// 443:         safe_cd() { cd "$1" &>/dev/null || exit 1; }
// 444:         setup_ca_certificates() { :; }
// 445:         setup_curl() { :; }
// 446:         setup_git() { :; }
// 447:         homebrew-update --auto-update --force --simulate-from-current-branch
// 448:       SH
// 449:       {
// 450:         "HOMEBREW_BREW_DEFAULT_GIT_REMOTE" => "https://github.com/Homebrew/brew",
// 451:         "HOMEBREW_BREW_GIT_REMOTE"         => "https://github.com/Homebrew/brew",
// 452:         "HOMEBREW_CACHE"                   => (test_root/"cache").to_s,
// 453:         "HOMEBREW_CASK_REPOSITORY"         => (test_root/"cask").to_s,
// 454:         "HOMEBREW_CELLAR"                  => (test_root/"cellar").to_s,
// 455:         "HOMEBREW_CORE_DEFAULT_GIT_REMOTE" => "https://github.com/Homebrew/homebrew-core",
// 456:         "HOMEBREW_CORE_GIT_REMOTE"         => "https://github.com/Homebrew/homebrew-core",
// 457:         "HOMEBREW_CORE_REPOSITORY"         => (test_root/"core").to_s,
// 458:         "HOMEBREW_DEVELOPER"               => "1",
// 459:         "HOMEBREW_LIBRARY"                 => (test_root/"Library").to_s,
// 460:         "HOMEBREW_NO_ENV_HINTS"            => "1",
// 461:         "HOMEBREW_NO_INSTALL_FROM_API"     => "1",
// 462:         "HOMEBREW_PREFIX"                  => (test_root/"prefix").to_s,
// 463:         "HOMEBREW_REPOSITORY"              => repository.to_s,
// 464:         "HOMEBREW_USER_AGENT_CURL"         => "Homebrew/test",
// 465:       },
// 466:     )
// 467:
// 468:     expect(status.success?).to be true
// 469:     expect(stderr).to be_empty
// 470:     expect(args_file.read).to eq("update-report\n--force\n--simulate-from-current-branch\n")
// 471:     expect((repository/".git/REDIRECTED_REMOTES").read).to eq(
// 472:       "#{tap_path}\thttps://github.com/new/homebrew-foo.git\n",
// 473:     )
// 474:     expect(metadata_queries_file.read).to eq("https://api.github.com/repos/old/homebrew-foo\n")
// 475:   end
// 476: end
