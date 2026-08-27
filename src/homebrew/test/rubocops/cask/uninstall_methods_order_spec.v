module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/uninstall_methods_order_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "detects and corrects ordering offenses in the uninstall block when each method contains a single item" do` at line 8.
pub fn ruby_uninstall_methods_order_spec_l8_d1_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Ruby it `it "detects and corrects ordering offenses in the uninstall block when methods contain arrays" do` at line 26.
pub fn ruby_uninstall_methods_order_spec_l26_d2_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Ruby it `it "does not report an offense" do` at line 65.
pub fn ruby_uninstall_methods_order_spec_l65_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "ignores on_upgrade when checking method order" do` at line 84.
pub fn ruby_uninstall_methods_order_spec_l84_d4_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "registers offense and autocorrects to remove on_upgrade when 1 other key exists" do` at line 107.
pub fn ruby_uninstall_methods_order_spec_l107_d5_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers offense and autocorrects to remove on_upgrade when between other keys" do` at line 128.
pub fn ruby_uninstall_methods_order_spec_l128_d6_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers offense but does not autocorrect when on_upgrade is the only key" do` at line 151.
pub fn ruby_uninstall_methods_order_spec_l151_d7_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers offense but does not autocorrect" do` at line 163.
pub fn ruby_uninstall_methods_order_spec_l163_d8_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers offense on the value but does not autocorrect" do` at line 176.
pub fn ruby_uninstall_methods_order_spec_l176_d9_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "does not register offense for :signal" do` at line 190.
pub fn ruby_uninstall_methods_order_spec_l190_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not report an offense when a single item is present in the method" do` at line 203.
pub fn ruby_uninstall_methods_order_spec_l203_d11_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not report an offense when the method contains an array" do` at line 213.
pub fn ruby_uninstall_methods_order_spec_l213_d12_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "detects and corrects ordering offenses in the zap block when each method contains a single item" do` at line 230.
pub fn ruby_uninstall_methods_order_spec_l230_d13_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Ruby it `it "detects and corrects ordering offenses in the zap block when methods contain arrays" do` at line 248.
pub fn ruby_uninstall_methods_order_spec_l248_d14_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Ruby it `it "does not report an offense" do` at line 280.
pub fn ruby_uninstall_methods_order_spec_l280_d15_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not report an offense when a single item is present in the method" do` at line 297.
pub fn ruby_uninstall_methods_order_spec_l297_d16_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not report an offense when the method contains an array" do` at line 307.
pub fn ruby_uninstall_methods_order_spec_l307_d17_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "detects offenses and auto-corrects to the correct order" do` at line 324.
pub fn ruby_uninstall_methods_order_spec_l324_d18_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Ruby it `it "does not report an offense" do` at line 379.
pub fn ruby_uninstall_methods_order_spec_l379_d19_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "keeps associated comments when auto-correcting" do` at line 424.
pub fn ruby_uninstall_methods_order_spec_l424_d20_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "detects and corrects offenses within OS-specific blocks" do` at line 444.
pub fn ruby_uninstall_methods_order_spec_l444_d21_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5: RSpec.describe RuboCop::Cop::Cask::UninstallMethodsOrder, :config do
// 6:   context "with uninstall blocks" do
// 7:     context "when methods are incorrectly ordered" do
// 8:       it "detects and corrects ordering offenses in the uninstall block when each method contains a single item" do
// 9:         expect_offense(<<~CASK)
// 10:           cask 'foo' do
// 11:             uninstall quit:      "com.example.foo",
// 12:                       ^^^^ `quit` method out of order
// 13:                       launchctl: "com.example.foo"
// 14:                       ^^^^^^^^^ `launchctl` method out of order
// 15:           end
// 16:         CASK
// 17:
// 18:         expect_correction(<<~CASK)
// 19:           cask 'foo' do
// 20:             uninstall launchctl: "com.example.foo",
// 21:                       quit:      "com.example.foo"
// 22:           end
// 23:         CASK
// 24:       end
// 25:
// 26:       it "detects and corrects ordering offenses in the uninstall block when methods contain arrays" do
// 27:         expect_offense(<<~CASK)
// 28:           cask "foo" do
// 29:             url "https://example.com/foo.zip"
// 30:
// 31:           uninstall delete:  [
// 32:                     ^^^^^^ `delete` method out of order
// 33:                       "/usr/local/bin/foo",
// 34:                       "/usr/local/bin/foobar",
// 35:                     ],
// 36:                     script:  {
// 37:                     ^^^^^^ `script` method out of order
// 38:                       executable: "/usr/local/bin/foo",
// 39:                       sudo:       false,
// 40:                     },
// 41:                     pkgutil: "org.foo.bar"
// 42:                     ^^^^^^^ `pkgutil` method out of order
// 43:           end
// 44:         CASK
// 45:
// 46:         expect_correction(<<~CASK)
// 47:           cask "foo" do
// 48:             url "https://example.com/foo.zip"
// 49:
// 50:           uninstall script:  {
// 51:                       executable: "/usr/local/bin/foo",
// 52:                       sudo:       false,
// 53:                     },
// 54:                     pkgutil: "org.foo.bar",
// 55:                     delete:  [
// 56:                       "/usr/local/bin/foo",
// 57:                       "/usr/local/bin/foobar",
// 58:                     ]
// 59:           end
// 60:         CASK
// 61:       end
// 62:     end
// 63:
// 64:     context "when methods are correctly ordered" do
// 65:       it "does not report an offense" do
// 66:         expect_no_offenses(<<~CASK)
// 67:           cask "foo" do
// 68:             url "https://example.com/foo.zip"
// 69:
// 70:             uninstall script:  {
// 71:                         executable: "/usr/local/bin/foo",
// 72:                         sudo:       false,
// 73:                       },
// 74:                       pkgutil: "org.foo.bar",
// 75:                       delete:  [
// 76:                         "/usr/local/bin/foo",
// 77:                         "/usr/local/bin/foobar",
// 78:                       ]
// 79:           end
// 80:         CASK
// 81:       end
// 82:
// 83:       context "when methods are correctly ordered and on_upgrade is present" do
// 84:         it "ignores on_upgrade when checking method order" do
// 85:           expect_no_offenses(<<~CASK)
// 86:             cask "foo" do
// 87:               url "https://example.com/foo.zip"
// 88:
// 89:               uninstall quit:       "com.example.foo",
// 90:                         signal:     ["TERM", "com.example.foo"],
// 91:                         on_upgrade: :signal,
// 92:                         script:     {
// 93:                           executable: "/usr/local/bin/foo",
// 94:                           sudo:       false,
// 95:                         },
// 96:                         pkgutil:    "org.foo.bar",
// 97:                         delete:     [
// 98:                           "/usr/local/bin/foo",
// 99:                           "/usr/local/bin/foobar",
// 100:                         ]
// 101:             end
// 102:           CASK
// 103:         end
// 104:       end
// 105:
// 106:       context "when on_upgrade is fully useless (no quit: or signal:)" do
// 107:         it "registers offense and autocorrects to remove on_upgrade when 1 other key exists" do
// 108:           expect_offense(<<~CASK)
// 109:             cask "foo" do
// 110:               url "https://example.com/foo.zip"
// 111:
// 112:               uninstall pkgutil:    "org.foo.bar",
// 113:                         on_upgrade: :quit
// 114:                         ^^^^^^^^^^ `on_upgrade` has no effect without matching `uninstall signal:` directive
// 115:             end
// 116:           CASK
// 117:
// 118:           expect_correction(<<~CASK)
// 119:             cask "foo" do
// 120:               url "https://example.com/foo.zip"
// 121:
// 122:               uninstall pkgutil:    "org.foo.bar"
// 123:             end
// 124:           CASK
// 125:         end
// 126:       end
// 127:
// 128:       it "registers offense and autocorrects to remove on_upgrade when between other keys" do
// 129:         expect_offense(<<~CASK)
// 130:           cask "foo" do
// 131:             url "https://example.com/foo.zip"
// 132:
// 133:             uninstall login_item: "FooApp",
// 134:                       on_upgrade: :quit,
// 135:                       ^^^^^^^^^^ `on_upgrade` has no effect without matching `uninstall signal:` directive
// 136:                       pkgutil:    "org.foo.bar"
// 137:           end
// 138:         CASK
// 139:
// 140:         expect_correction(<<~CASK)
// 141:           cask "foo" do
// 142:             url "https://example.com/foo.zip"
// 143:
// 144:             uninstall login_item: "FooApp",
// 145:                       pkgutil:    "org.foo.bar"
// 146:           end
// 147:         CASK
// 148:       end
// 149:     end
// 150:
// 151:     it "registers offense but does not autocorrect when on_upgrade is the only key" do
// 152:       expect_offense(<<~CASK)
// 153:         cask "foo" do
// 154:           url "https://example.com/foo.zip"
// 155:
// 156:           uninstall on_upgrade: :quit
// 157:                     ^^^^^^^^^^ `on_upgrade` has no effect without matching `uninstall signal:` directive
// 158:         end
// 159:       CASK
// 160:     end
// 161:
// 162:     context "when only on_upgrade is present" do
// 163:       it "registers offense but does not autocorrect" do
// 164:         expect_offense(<<~CASK)
// 165:           cask "foo" do
// 166:             url "https://example.com/foo.zip"
// 167:
// 168:             uninstall on_upgrade: :quit
// 169:                       ^^^^^^^^^^ `on_upgrade` has no effect without matching `uninstall signal:` directive
// 170:           end
// 171:         CASK
// 172:       end
// 173:     end
// 174:
// 175:     context "when on_upgrade includes symbols without matching directives" do
// 176:       it "registers offense on the value but does not autocorrect" do
// 177:         expect_offense(<<~CASK)
// 178:           cask "foo" do
// 179:             url "https://example.com/foo.zip"
// 180:
// 181:             uninstall signal:     [["TERM", "com.example.foo"]],
// 182:                       on_upgrade: [:quit, :signal]
// 183:                                   ^^^^^^^^^^^^^^^^ `on_upgrade` lists :quit without matching `uninstall` directives
// 184:           end
// 185:         CASK
// 186:       end
// 187:     end
// 188:
// 189:     context "when on_upgrade matches available directives (signal: only)" do
// 190:       it "does not register offense for :signal" do
// 191:         expect_no_offenses(<<~CASK)
// 192:           cask "foo" do
// 193:             url "https://example.com/foo.zip"
// 194:
// 195:             uninstall signal:     [["TERM", "com.example.app"]],
// 196:                       on_upgrade: :signal
// 197:           end
// 198:         CASK
// 199:       end
// 200:     end
// 201:
// 202:     context "with a single method" do
// 203:       it "does not report an offense when a single item is present in the method" do
// 204:         expect_no_offenses(<<~CASK)
// 205:           cask "foo" do
// 206:             url "https://example.com/foo.zip"
// 207:
// 208:             uninstall delete: "/usr/local/bin/foo"
// 209:           end
// 210:         CASK
// 211:       end
// 212:
// 213:       it "does not report an offense when the method contains an array" do
// 214:         expect_no_offenses(<<~CASK)
// 215:           cask "foo" do
// 216:             url "https://example.com/foo.zip"
// 217:
// 218:             uninstall pkgutil: [
// 219:               "org.foo.bar",
// 220:               "org.foobar.bar",
// 221:             ]
// 222:           end
// 223:         CASK
// 224:       end
// 225:     end
// 226:   end
// 227:
// 228:   context "with zap blocks" do
// 229:     context "when methods are incorrectly ordered" do
// 230:       it "detects and corrects ordering offenses in the zap block when each method contains a single item" do
// 231:         expect_offense(<<~CASK)
// 232:           cask 'foo' do
// 233:             zap rmdir: "/Library/Foo",
// 234:                 ^^^^^ `rmdir` method out of order
// 235:                 trash: "com.example.foo"
// 236:                 ^^^^^ `trash` method out of order
// 237:           end
// 238:         CASK
// 239:
// 240:         expect_correction(<<~CASK)
// 241:           cask 'foo' do
// 242:             zap trash: "com.example.foo",
// 243:                 rmdir: "/Library/Foo"
// 244:           end
// 245:         CASK
// 246:       end
// 247:
// 248:       it "detects and corrects ordering offenses in the zap block when methods contain arrays" do
// 249:         expect_offense(<<~CASK)
// 250:           cask "foo" do
// 251:             url "https://example.com/foo.zip"
// 252:
// 253:             zap delete: [
// 254:                   "~/Library/Application Support/Foo",
// 255:                   "~/Library/Application Support/Bar",
// 256:                 ],
// 257:                 rmdir: "~/Library/Application Support",
// 258:                 ^^^^^ `rmdir` method out of order
// 259:                 trash: "~/Library/Application Support/FooBar"
// 260:                 ^^^^^ `trash` method out of order
// 261:           end
// 262:         CASK
// 263:
// 264:         expect_correction(<<~CASK)
// 265:           cask "foo" do
// 266:             url "https://example.com/foo.zip"
// 267:
// 268:             zap delete: [
// 269:                   "~/Library/Application Support/Foo",
// 270:                   "~/Library/Application Support/Bar",
// 271:                 ],
// 272:                 trash: "~/Library/Application Support/FooBar",
// 273:                 rmdir: "~/Library/Application Support"
// 274:           end
// 275:         CASK
// 276:       end
// 277:     end
// 278:
// 279:     context "when methods are correctly ordered" do
// 280:       it "does not report an offense" do
// 281:         expect_no_offenses(<<~CASK)
// 282:           cask "foo" do
// 283:             url "https://example.com/foo.zip"
// 284:
// 285:             zap delete: [
// 286:                   "~/Library/Application Support/Bar",
// 287:                   "~/Library/Application Support/Foo",
// 288:                 ],
// 289:                 trash:  "~/Library/Application Support/FooBar",
// 290:                 rmdir:  "~/Library/Application Support"
// 291:           end
// 292:         CASK
// 293:       end
// 294:     end
// 295:
// 296:     context "with a single method" do
// 297:       it "does not report an offense when a single item is present in the method" do
// 298:         expect_no_offenses(<<~CASK)
// 299:           cask "foo" do
// 300:             url "https://example.com/foo.zip"
// 301:
// 302:             zap trash:  "~/Library/Application Support/FooBar"
// 303:           end
// 304:         CASK
// 305:       end
// 306:
// 307:       it "does not report an offense when the method contains an array" do
// 308:         expect_no_offenses(<<~CASK)
// 309:           cask "foo" do
// 310:             url "https://example.com/foo.zip"
// 311:
// 312:             zap trash: [
// 313:               "~/Library/Application Support/FooBar",
// 314:               "~/Library/Application Support/FooBarBar",
// 315:             ]
// 316:           end
// 317:         CASK
// 318:       end
// 319:     end
// 320:   end
// 321:
// 322:   context "with both uninstall and zap blocks" do
// 323:     context "when both uninstall and zap methods are incorrectly ordered" do
// 324:       it "detects offenses and auto-corrects to the correct order" do
// 325:         expect_offense(<<~CASK)
// 326:           cask "foo" do
// 327:             url "https://example.com/foo.zip"
// 328:
// 329:             uninstall delete:  [
// 330:                       ^^^^^^ `delete` method out of order
// 331:                         "/usr/local/bin/foo",
// 332:                         "/usr/local/bin/foobar",
// 333:                       ],
// 334:                       script:  {
// 335:                       ^^^^^^ `script` method out of order
// 336:                         executable: "/usr/local/bin/foo",
// 337:                         sudo:       false,
// 338:                       },
// 339:                       pkgutil: "org.foo.bar"
// 340:                       ^^^^^^^ `pkgutil` method out of order
// 341:
// 342:             zap delete: [
// 343:                   "~/Library/Application Support/Bar",
// 344:                   "~/Library/Application Support/Foo",
// 345:                 ],
// 346:                 rmdir:  "~/Library/Application Support",
// 347:                 ^^^^^ `rmdir` method out of order
// 348:                 trash:  "~/Library/Application Support/FooBar"
// 349:                 ^^^^^ `trash` method out of order
// 350:           end
// 351:         CASK
// 352:
// 353:         expect_correction(<<~CASK)
// 354:           cask "foo" do
// 355:             url "https://example.com/foo.zip"
// 356:
// 357:             uninstall script:  {
// 358:                         executable: "/usr/local/bin/foo",
// 359:                         sudo:       false,
// 360:                       },
// 361:                       pkgutil: "org.foo.bar",
// 362:                       delete:  [
// 363:                         "/usr/local/bin/foo",
// 364:                         "/usr/local/bin/foobar",
// 365:                       ]
// 366:
// 367:             zap delete: [
// 368:                   "~/Library/Application Support/Bar",
// 369:                   "~/Library/Application Support/Foo",
// 370:                 ],
// 371:                 trash:  "~/Library/Application Support/FooBar",
// 372:                 rmdir:  "~/Library/Application Support"
// 373:           end
// 374:         CASK
// 375:       end
// 376:     end
// 377:
// 378:     context "when uninstall and zap methods are correctly ordered" do
// 379:       it "does not report an offense" do
// 380:         expect_no_offenses(<<~CASK)
// 381:           cask 'foo' do
// 382:             uninstall early_script: {
// 383:                         executable: "foo.sh",
// 384:                         args:       ["--unattended"],
// 385:                       },
// 386:                       launchctl:    "com.example.foo",
// 387:                       quit:         "com.example.foo",
// 388:                       signal:       ["TERM", "com.example.foo"],
// 389:                       login_item:   "FooApp",
// 390:                       kext:         "com.example.foo",
// 391:                       script:       {
// 392:                         executable: "foo.sh",
// 393:                         args:       ["--unattended"],
// 394:                       },
// 395:                       pkgutil:      "com.example.foo",
// 396:                       delete:       "~/Library/Preferences/com.example.foo",
// 397:                       trash:        "~/Library/Preferences/com.example.foo",
// 398:                       rmdir:        "~/Library/Foo"
// 399:
// 400:             zap early_script: {
// 401:                   executable: "foo.sh",
// 402:                   args:       ["--unattended"],
// 403:                 },
// 404:                 launchctl:    "com.example.foo",
// 405:                 quit:         "com.example.foo",
// 406:                 signal:       ["TERM", "com.example.foo"],
// 407:                 login_item:   "FooApp",
// 408:                 kext:         "com.example.foo",
// 409:                 script:       {
// 410:                   executable: "foo.sh",
// 411:                   args:       ["--unattended"],
// 412:                 },
// 413:                 pkgutil:      "com.example.foo",
// 414:                 delete:       "~/Library/Preferences/com.example.foo",
// 415:                 trash:        "~/Library/Preferences/com.example.foo",
// 416:                 rmdir:        "~/Library/Foo"
// 417:           end
// 418:         CASK
// 419:       end
// 420:     end
// 421:   end
// 422:
// 423:   context "when in-line comments are present" do
// 424:     it "keeps associated comments when auto-correcting" do
// 425:       expect_offense <<~CASK
// 426:         cask 'foo' do
// 427:           uninstall quit:      "com.example.foo", # comment on same line
// 428:                     ^^^^ `quit` method out of order
// 429:                     launchctl: "com.example.foo"
// 430:                     ^^^^^^^^^ `launchctl` method out of order
// 431:         end
// 432:       CASK
// 433:
// 434:       expect_correction <<~CASK
// 435:         cask 'foo' do
// 436:           uninstall launchctl: "com.example.foo",
// 437:                     quit:      "com.example.foo" # comment on same line
// 438:         end
// 439:       CASK
// 440:     end
// 441:   end
// 442:
// 443:   context "when methods are inside an `on_os` block" do
// 444:     it "detects and corrects offenses within OS-specific blocks" do
// 445:       expect_offense <<~CASK
// 446:         cask "foo" do
// 447:           on_catalina do
// 448:             uninstall trash:     "com.example.foo",
// 449:                       ^^^^^ `trash` method out of order
// 450:                       launchctl: "com.example.foo"
// 451:                       ^^^^^^^^^ `launchctl` method out of order
// 452:           end
// 453:           on_ventura do
// 454:             uninstall quit:      "com.example.foo",
// 455:                       ^^^^ `quit` method out of order
// 456:                       launchctl: "com.example.foo"
// 457:                       ^^^^^^^^^ `launchctl` method out of order
// 458:           end
// 459:         end
// 460:       CASK
// 461:
// 462:       expect_correction <<~CASK
// 463:         cask "foo" do
// 464:           on_catalina do
// 465:             uninstall launchctl: "com.example.foo",
// 466:                       trash:     "com.example.foo"
// 467:           end
// 468:           on_ventura do
// 469:             uninstall launchctl: "com.example.foo",
// 470:                       quit:      "com.example.foo"
// 471:           end
// 472:         end
// 473:       CASK
// 474:     end
// 475:   end
// 476: end
