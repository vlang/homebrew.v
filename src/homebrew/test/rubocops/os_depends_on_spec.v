module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/os_depends_on_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "autocorrects cask macOS comparison strings" do` at line 7.
pub fn ruby_os_depends_on_spec_l7_d1_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "autocorrects redundant bare macOS requirements" do` at line 24.
pub fn ruby_os_depends_on_spec_l24_d2_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "ignores non-symbol dependency hash keys" do` at line 36.
pub fn ruby_os_depends_on_spec_l36_d3_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "reports conflicting macOS-only and Linux-only requirements" do` at line 46.
pub fn ruby_os_depends_on_spec_l46_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "allows scoped macOS requirements" do` at line 55.
pub fn ruby_os_depends_on_spec_l55_d5_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "autocorrects missing bare macOS dependencies for macOS-only cask stanzas" do` at line 65.
pub fn ruby_os_depends_on_spec_l65_d6_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "autocorrects missing bare macOS dependencies using cask stanza order" do` at line 92.
pub fn ruby_os_depends_on_spec_l92_d7_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "autocorrects missing bare macOS dependencies before macOS-only cask stanzas" do` at line 139.
pub fn ruby_os_depends_on_spec_l139_d8_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "autocorrects missing bare macOS dependencies for artifacts in architecture blocks" do` at line 160.
pub fn ruby_os_depends_on_spec_l160_d9_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "autocorrects missing bare Linux dependencies for Linux-only cask stanzas" do` at line 183.
pub fn ruby_os_depends_on_spec_l183_d10_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "autocorrects missing bare Linux dependencies using cask stanza order" do` at line 210.
pub fn ruby_os_depends_on_spec_l210_d11_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "autocorrects missing bare Linux dependencies before Linux-only cask stanzas" do` at line 257.
pub fn ruby_os_depends_on_spec_l257_d12_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "autocorrects missing bare Linux dependencies for artifacts in architecture blocks" do` at line 278.
pub fn ruby_os_depends_on_spec_l278_d13_autocorrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrects', ...args)
}

// Ruby it `it "requires OS scoping for architecture artifacts in cross-platform casks" do` at line 301.
pub fn ruby_os_depends_on_spec_l301_d14_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires', ...args)
}

// Ruby it `it "requires OS scoping for top-level artifacts in cross-platform casks" do` at line 318.
pub fn ruby_os_depends_on_spec_l318_d15_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires', ...args)
}

// Ruby it `it "requires OS scoping for artifacts in on_system blocks" do` at line 333.
pub fn ruby_os_depends_on_spec_l333_d16_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires', ...args)
}

// Ruby it `it "does not autocorrect conflicting OS-specific architecture artifacts" do` at line 346.
pub fn ruby_os_depends_on_spec_l346_d17_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "accepts casks without macOS-only or Linux-only stanzas" do` at line 364.
pub fn ruby_os_depends_on_spec_l364_d18_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts casks with explicit OS dependencies" do` at line 377.
pub fn ruby_os_depends_on_spec_l377_d19_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts casks with explicit OS dependencies in nested blocks" do` at line 392.
pub fn ruby_os_depends_on_spec_l392_d20_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/os_depends_on"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::OSDependsOn, :config do
// 7:   it "autocorrects cask macOS comparison strings" do
// 8:     expect_offense(<<~RUBY)
// 9:       depends_on macos: ">= :catalina"
// 10:                         ^^^^^^^^^^^^^^ Use `depends_on macos: :catalina`.
// 11:       depends_on macos: "<= :sonoma"
// 12:                         ^^^^^^^^^^^^ Use `depends_on maximum_macos: :sonoma`.
// 13:       depends_on maximum_macos: "<= :tahoe"
// 14:                                 ^^^^^^^^^^^ Use `depends_on maximum_macos: :tahoe`.
// 15:     RUBY
// 16:
// 17:     expect_correction(<<~RUBY)
// 18:       depends_on macos: :catalina
// 19:       depends_on maximum_macos: :sonoma
// 20:       depends_on maximum_macos: :tahoe
// 21:     RUBY
// 22:   end
// 23:
// 24:   it "autocorrects redundant bare macOS requirements" do
// 25:     expect_offense(<<~RUBY)
// 26:       depends_on :macos
// 27:       ^^^^^^^^^^^^^^^^^ Remove redundant `depends_on :macos`.
// 28:       depends_on macos: :catalina
// 29:     RUBY
// 30:
// 31:     expect_correction(<<~RUBY)
// 32:       depends_on macos: :catalina
// 33:     RUBY
// 34:   end
// 35:
// 36:   it "ignores non-symbol dependency hash keys" do
// 37:     expect_no_offenses(<<~RUBY)
// 38:       depends_on GawkRequirement => :build
// 39:       depends_on MakeRequirement => :build
// 40:       depends_on "linux-headers@4.4" => :build
// 41:       depends_on :linux
// 42:       depends_on LinuxKernelRequirement
// 43:     RUBY
// 44:   end
// 45:
// 46:   it "reports conflicting macOS-only and Linux-only requirements" do
// 47:     expect_offense(<<~RUBY)
// 48:       depends_on macos: :catalina
// 49:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^ `depends_on` cannot be macOS-only and Linux-only.
// 50:       depends_on :linux
// 51:       ^^^^^^^^^^^^^^^^^ `depends_on` cannot be macOS-only and Linux-only.
// 52:     RUBY
// 53:   end
// 54:
// 55:   it "allows scoped macOS requirements" do
// 56:     expect_no_offenses(<<~RUBY)
// 57:       on_macos do
// 58:         depends_on macos: :catalina
// 59:       end
// 60:
// 61:       depends_on :linux
// 62:     RUBY
// 63:   end
// 64:
// 65:   it "autocorrects missing bare macOS dependencies for macOS-only cask stanzas" do
// 66:     expect_offense(<<~RUBY)
// 67:       cask "basic" do
// 68:         version "1.0"
// 69:         sha256 "abc"
// 70:         url "https://example.com/basic.zip"
// 71:         homepage "https://example.com"
// 72:
// 73:         app "Basic.app"
// 74:         ^^^^^^^^^^^^^^^ Add `depends_on :macos` for macOS-only casks.
// 75:       end
// 76:     RUBY
// 77:
// 78:     expect_correction(<<~RUBY)
// 79:       cask "basic" do
// 80:         version "1.0"
// 81:         sha256 "abc"
// 82:         url "https://example.com/basic.zip"
// 83:         homepage "https://example.com"
// 84:
// 85:         depends_on :macos
// 86:
// 87:         app "Basic.app"
// 88:       end
// 89:     RUBY
// 90:   end
// 91:
// 92:   it "autocorrects missing bare macOS dependencies using cask stanza order" do
// 93:     expect_offense(<<~RUBY)
// 94:       cask "ordered" do
// 95:         version "1.0"
// 96:         sha256 "abc"
// 97:         url "https://example.com/ordered.zip"
// 98:         name "Ordered"
// 99:         desc "Ordered"
// 100:         homepage "https://example.com"
// 101:
// 102:         livecheck do
// 103:           skip "example"
// 104:         end
// 105:
// 106:         auto_updates true
// 107:         conflicts_with cask: "old-ordered"
// 108:         container nested: "Ordered"
// 109:
// 110:         app "Ordered.app"
// 111:         ^^^^^^^^^^^^^^^^^ Add `depends_on :macos` for macOS-only casks.
// 112:       end
// 113:     RUBY
// 114:
// 115:     expect_correction(<<~RUBY)
// 116:       cask "ordered" do
// 117:         version "1.0"
// 118:         sha256 "abc"
// 119:         url "https://example.com/ordered.zip"
// 120:         name "Ordered"
// 121:         desc "Ordered"
// 122:         homepage "https://example.com"
// 123:
// 124:         livecheck do
// 125:           skip "example"
// 126:         end
// 127:
// 128:         auto_updates true
// 129:         conflicts_with cask: "old-ordered"
// 130:         depends_on :macos
// 131:
// 132:         container nested: "Ordered"
// 133:
// 134:         app "Ordered.app"
// 135:       end
// 136:     RUBY
// 137:   end
// 138:
// 139:   it "autocorrects missing bare macOS dependencies before macOS-only cask stanzas" do
// 140:     expect_offense(<<~RUBY)
// 141:       cask "basic" do
// 142:         version "1.0"
// 143:
// 144:         installer manual: "Basic.app"
// 145:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `depends_on :macos` for macOS-only casks.
// 146:       end
// 147:     RUBY
// 148:
// 149:     expect_correction(<<~RUBY)
// 150:       cask "basic" do
// 151:         version "1.0"
// 152:
// 153:         depends_on :macos
// 154:
// 155:         installer manual: "Basic.app"
// 156:       end
// 157:     RUBY
// 158:   end
// 159:
// 160:   it "autocorrects missing bare macOS dependencies for artifacts in architecture blocks" do
// 161:     expect_offense(<<~RUBY)
// 162:       cask "basic" do
// 163:         on_intel do
// 164:           version "1.0"
// 165:           app "Basic.app"
// 166:           ^^^^^^^^^^^^^^^ Add `depends_on :macos` for macOS-only casks.
// 167:         end
// 168:       end
// 169:     RUBY
// 170:
// 171:     expect_correction(<<~RUBY)
// 172:       cask "basic" do
// 173:         on_intel do
// 174:           version "1.0"
// 175:           app "Basic.app"
// 176:         end
// 177:
// 178:         depends_on :macos
// 179:       end
// 180:     RUBY
// 181:   end
// 182:
// 183:   it "autocorrects missing bare Linux dependencies for Linux-only cask stanzas" do
// 184:     expect_offense(<<~RUBY)
// 185:       cask "basic" do
// 186:         version "1.0"
// 187:         sha256 "abc"
// 188:         url "https://example.com/basic.zip"
// 189:         homepage "https://example.com"
// 190:
// 191:         app_image "Basic.AppImage"
// 192:         ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `depends_on :linux` for Linux-only casks.
// 193:       end
// 194:     RUBY
// 195:
// 196:     expect_correction(<<~RUBY)
// 197:       cask "basic" do
// 198:         version "1.0"
// 199:         sha256 "abc"
// 200:         url "https://example.com/basic.zip"
// 201:         homepage "https://example.com"
// 202:
// 203:         depends_on :linux
// 204:
// 205:         app_image "Basic.AppImage"
// 206:       end
// 207:     RUBY
// 208:   end
// 209:
// 210:   it "autocorrects missing bare Linux dependencies using cask stanza order" do
// 211:     expect_offense(<<~RUBY)
// 212:       cask "ordered" do
// 213:         version "1.0"
// 214:         sha256 "abc"
// 215:         url "https://example.com/ordered.zip"
// 216:         name "Ordered"
// 217:         desc "Ordered"
// 218:         homepage "https://example.com"
// 219:
// 220:         livecheck do
// 221:           skip "example"
// 222:         end
// 223:
// 224:         auto_updates true
// 225:         conflicts_with cask: "old-ordered"
// 226:         container nested: "Ordered"
// 227:
// 228:         app_image "Ordered.AppImage"
// 229:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `depends_on :linux` for Linux-only casks.
// 230:       end
// 231:     RUBY
// 232:
// 233:     expect_correction(<<~RUBY)
// 234:       cask "ordered" do
// 235:         version "1.0"
// 236:         sha256 "abc"
// 237:         url "https://example.com/ordered.zip"
// 238:         name "Ordered"
// 239:         desc "Ordered"
// 240:         homepage "https://example.com"
// 241:
// 242:         livecheck do
// 243:           skip "example"
// 244:         end
// 245:
// 246:         auto_updates true
// 247:         conflicts_with cask: "old-ordered"
// 248:         depends_on :linux
// 249:
// 250:         container nested: "Ordered"
// 251:
// 252:         app_image "Ordered.AppImage"
// 253:       end
// 254:     RUBY
// 255:   end
// 256:
// 257:   it "autocorrects missing bare Linux dependencies before Linux-only cask stanzas" do
// 258:     expect_offense(<<~RUBY)
// 259:       cask "basic" do
// 260:         version "1.0"
// 261:
// 262:         app_image "Basic.AppImage"
// 263:         ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `depends_on :linux` for Linux-only casks.
// 264:       end
// 265:     RUBY
// 266:
// 267:     expect_correction(<<~RUBY)
// 268:       cask "basic" do
// 269:         version "1.0"
// 270:
// 271:         depends_on :linux
// 272:
// 273:         app_image "Basic.AppImage"
// 274:       end
// 275:     RUBY
// 276:   end
// 277:
// 278:   it "autocorrects missing bare Linux dependencies for artifacts in architecture blocks" do
// 279:     expect_offense(<<~RUBY)
// 280:       cask "basic" do
// 281:         on_arm do
// 282:           version "1.0"
// 283:           app_image "Basic.AppImage"
// 284:           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `depends_on :linux` for Linux-only casks.
// 285:         end
// 286:       end
// 287:     RUBY
// 288:
// 289:     expect_correction(<<~RUBY)
// 290:       cask "basic" do
// 291:         on_arm do
// 292:           version "1.0"
// 293:           app_image "Basic.AppImage"
// 294:         end
// 295:
// 296:         depends_on :linux
// 297:       end
// 298:     RUBY
// 299:   end
// 300:
// 301:   it "requires OS scoping for architecture artifacts in cross-platform casks" do
// 302:     expect_offense(<<~RUBY)
// 303:       cask "dual-os-arch" do
// 304:         on_intel do
// 305:           app "Foo.app"
// 306:           ^^^^^^^^^^^^^ Move this macOS-only stanza into an `on_macos` block for cross-platform casks.
// 307:         end
// 308:
// 309:         on_linux do
// 310:           app_image "Foo.AppImage"
// 311:         end
// 312:       end
// 313:     RUBY
// 314:
// 315:     expect_no_corrections
// 316:   end
// 317:
// 318:   it "requires OS scoping for top-level artifacts in cross-platform casks" do
// 319:     expect_offense(<<~RUBY)
// 320:       cask "toplevel-cross-platform" do
// 321:         app "Foo.app"
// 322:         ^^^^^^^^^^^^^ Move this macOS-only stanza into an `on_macos` block for cross-platform casks.
// 323:
// 324:         on_linux do
// 325:           binary "foo"
// 326:         end
// 327:       end
// 328:     RUBY
// 329:
// 330:     expect_no_corrections
// 331:   end
// 332:
// 333:   it "requires OS scoping for artifacts in on_system blocks" do
// 334:     expect_offense(<<~RUBY)
// 335:       cask "on-system-artifact" do
// 336:         on_system :linux, macos: :sonoma_or_older do
// 337:           app_image "Foo.AppImage"
// 338:           ^^^^^^^^^^^^^^^^^^^^^^^^ Move this Linux-only stanza into an `on_linux` block for cross-platform casks.
// 339:         end
// 340:       end
// 341:     RUBY
// 342:
// 343:     expect_no_corrections
// 344:   end
// 345:
// 346:   it "does not autocorrect conflicting OS-specific architecture artifacts" do
// 347:     expect_offense(<<~RUBY)
// 348:       cask "conflicting-arch-artifacts" do
// 349:         on_arm do
// 350:           app_image "Foo.AppImage"
// 351:           ^^^^^^^^^^^^^^^^^^^^^^^^ Move this Linux-only stanza into an `on_linux` block for cross-platform casks.
// 352:         end
// 353:
// 354:         on_intel do
// 355:           app "Foo.app"
// 356:           ^^^^^^^^^^^^^ Move this macOS-only stanza into an `on_macos` block for cross-platform casks.
// 357:         end
// 358:       end
// 359:     RUBY
// 360:
// 361:     expect_no_corrections
// 362:   end
// 363:
// 364:   it "accepts casks without macOS-only or Linux-only stanzas" do
// 365:     expect_no_offenses(<<~RUBY)
// 366:       cask "basic" do
// 367:         version "1.0"
// 368:         sha256 "abc"
// 369:         url "https://example.com/basic.tar.gz"
// 370:         homepage "https://example.com"
// 371:
// 372:         binary "basic"
// 373:       end
// 374:     RUBY
// 375:   end
// 376:
// 377:   it "accepts casks with explicit OS dependencies" do
// 378:     expect_no_offenses(<<~RUBY)
// 379:       cask "basic" do
// 380:         version "1.0"
// 381:         sha256 "abc"
// 382:         url "https://example.com/basic.zip"
// 383:         homepage "https://example.com"
// 384:
// 385:         depends_on macos: :catalina
// 386:
// 387:         app "Basic.app"
// 388:       end
// 389:     RUBY
// 390:   end
// 391:
// 392:   it "accepts casks with explicit OS dependencies in nested blocks" do
// 393:     expect_no_offenses(<<~RUBY)
// 394:       cask "basic" do
// 395:         version "1.0"
// 396:         sha256 "abc"
// 397:         url "https://example.com/basic.zip"
// 398:         homepage "https://example.com"
// 399:
// 400:         on_arm do
// 401:           depends_on macos: :big_sur
// 402:         end
// 403:
// 404:         on_intel do
// 405:           depends_on :macos
// 406:         end
// 407:
// 408:         app "Basic.app"
// 409:       end
// 410:     RUBY
// 411:   end
// 412: end
