module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/patches_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_patches_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby method `expect_offense_hash(message:, severity:, line:, column:, source:)` at line 9.
pub fn ruby_patches_spec_l9_d2_expect_offense_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expect_offense_hash', ...args)
}

// Ruby it `it "reports no offenses if there is no legacy patch" do` at line 14.
pub fn ruby_patches_spec_l14_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if `def patches` is present" do` at line 22.
pub fn ruby_patches_spec_l22_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `patches` at line 27.
pub fn ruby_patches_spec_l27_d5_patches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patches', ...args)
}

// Ruby it `it "reports an offense for various patch URLs" do` at line 35.
pub fn ruby_patches_spec_l35_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `patches` at line 48.
pub fn ruby_patches_spec_l48_d7_patches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patches', ...args)
}

// Ruby it `it "reports an offense with nested `def patches`" do` at line 88.
pub fn ruby_patches_spec_l88_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `patches` at line 93.
pub fn ruby_patches_spec_l93_d9_patches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patches', ...args)
}

// Ruby it `it "reports no offenses for valid inline patches" do` at line 130.
pub fn ruby_patches_spec_l130_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses for valid nested inline patches" do` at line 141.
pub fn ruby_patches_spec_l141_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when DATA is found with no __END__" do` at line 154.
pub fn ruby_patches_spec_l154_d12_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when __END__ is found with no DATA" do` at line 164.
pub fn ruby_patches_spec_l164_d13_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for various patch URLs" do` at line 177.
pub fn ruby_patches_spec_l177_d14_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses for local file patches" do` at line 231.
pub fn ruby_patches_spec_l231_d15_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "corrects Bitbucket patch URLs to use API format" do` at line 244.
pub fn ruby_patches_spec_l244_d16_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Ruby it `it "corrects HTTP MacPorts Trac URLs to HTTPS" do` at line 267.
pub fn ruby_patches_spec_l267_d17_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Ruby it `it "corrects HTTP Debian bug URLs to HTTPS" do` at line 290.
pub fn ruby_patches_spec_l290_d18_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Ruby it `it "corrects GitHub commit URLs from .diff to .patch" do` at line 313.
pub fn ruby_patches_spec_l313_d19_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Ruby it `it "corrects GitLab commit URLs from .patch to .diff" do` at line 336.
pub fn ruby_patches_spec_l336_d20_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Ruby it `it "corrects GitHub patch URLs to add full_index parameter" do` at line 359.
pub fn ruby_patches_spec_l359_d21_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Ruby it `it "corrects GitHub URLs with 'diff' in the path" do` at line 382.
pub fn ruby_patches_spec_l382_d22_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Ruby it `it "corrects GitLab URLs with 'patch' in the path" do` at line 405.
pub fn ruby_patches_spec_l405_d23_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Ruby it `it "corrects GitHub URLs without sha256 field (e.g. with on_linux block)" do` at line 428.
pub fn ruby_patches_spec_l428_d24_corrects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corrects', ...args)
}

// Ruby it `it "reports no offenses for CVE ids, GHSA ids, OSV ids and issue URLs" do` at line 457.
pub fn ruby_patches_spec_l457_d25_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects non-canonical CVE identifiers" do` at line 470.
pub fn ruby_patches_spec_l470_d26_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for unrecognised identifiers" do` at line 495.
pub fn ruby_patches_spec_l495_d27_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for non-string arguments" do` at line 509.
pub fn ruby_patches_spec_l509_d28_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses for valid types" do` at line 525.
pub fn ruby_patches_spec_l525_d29_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for invalid types" do` at line 538.
pub fn ruby_patches_spec_l538_d30_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/patches"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Patches do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   def expect_offense_hash(message:, severity:, line:, column:, source:)
// 10:     [{ message:, severity:, line:, column:, source: }]
// 11:   end
// 12:
// 13:   context "when auditing legacy patches" do
// 14:     it "reports no offenses if there is no legacy patch" do
// 15:       expect_no_offenses(<<~RUBY)
// 16:         class Foo < Formula
// 17:           url 'https://brew.sh/foo-1.0.tgz'
// 18:         end
// 19:       RUBY
// 20:     end
// 21:
// 22:     it "reports an offense if `def patches` is present" do
// 23:       expect_offense(<<~RUBY)
// 24:         class Foo < Formula
// 25:           homepage "ftp://brew.sh/foo"
// 26:           url "https://brew.sh/foo-1.0.tgz"
// 27:           def patches
// 28:           ^^^^^^^^^^^ FormulaAudit/Patches: Use the `patch` DSL instead of defining a `patches` method
// 29:             DATA
// 30:           end
// 31:         end
// 32:       RUBY
// 33:     end
// 34:
// 35:     it "reports an offense for various patch URLs" do
// 36:       patch_urls = [
// 37:         "https://raw.github.com/mogaal/sendemail",
// 38:         "https://mirrors.ustc.edu.cn/macports/trunk/",
// 39:         "https://patch-diff.githubusercontent.com/raw/foo/foo-bar/pull/100.patch",
// 40:         "https://github.com/dlang/dub/commit/2c916b1a7999a050ac4970c3415ff8f91cd487aa.patch",
// 41:         "https://bitbucket.org/multicoreware/x265_git/commits/b354c009a60bcd6d7fc04014e200a1ee9c45c167/raw",
// 42:       ]
// 43:       patch_urls.each do |patch_url|
// 44:         source = <<~RUBY
// 45:           class Foo < Formula
// 46:             homepage "ftp://brew.sh/foo"
// 47:             url "https://brew.sh/foo-1.0.tgz"
// 48:             def patches
// 49:               "#{patch_url}"
// 50:             end
// 51:           end
// 52:         RUBY
// 53:
// 54:         expected_offense = if patch_url.include?("/raw.github.com/")
// 55:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 4, source:)
// 56:             FormulaAudit/Patches: GitHub/Gist patches should specify a revision: #{patch_url}
// 57:           EOS
// 58:         elsif patch_url.include?("macports/trunk")
// 59:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 4, source:)
// 60:             FormulaAudit/Patches: MacPorts patches should specify a revision instead of trunk: #{patch_url}
// 61:           EOS
// 62:         elsif patch_url.match?(%r{
// 63:           https?://patch-diff\.githubusercontent\.com/raw/(.+)/(.+)/pull/(.+)\.(?:diff|patch)
// 64:         }x)
// 65:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 4, source:)
// 66:             FormulaAudit/Patches: Use a commit hash URL rather than patch-diff: #{patch_url}
// 67:           EOS
// 68:         elsif patch_url.match?(%r{https?://github\.com/.+/.+/(?:commit|pull)/[a-fA-F0-9]*.(?:patch|diff)})
// 69:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 4, source:)
// 70:             FormulaAudit/Patches: GitHub patches should use the full_index parameter: #{patch_url}?full_index=1
// 71:           EOS
// 72:         elsif patch_url.start_with?("https://bitbucket.org/")
// 73:           commit = "b354c009a60bcd6d7fc04014e200a1ee9c45c167"
// 74:           fixed_url = "https://api.bitbucket.org/2.0/repositories/multicoreware/x265_git/diff/#{commit}"
// 75:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 4, source:)
// 76:             FormulaAudit/Patches: Bitbucket patches should use the API URL: #{fixed_url}
// 77:           EOS
// 78:         end
// 79:         expected_offense.zip([inspect_source(source).last]).each do |expected, actual|
// 80:           expect(actual.message).to eq(expected[:message])
// 81:           expect(actual.severity).to eq(expected[:severity])
// 82:           expect(actual.line).to eq(expected[:line])
// 83:           expect(actual.column).to eq(expected[:column])
// 84:         end
// 85:       end
// 86:     end
// 87:
// 88:     it "reports an offense with nested `def patches`" do
// 89:       source = <<~RUBY
// 90:         class Foo < Formula
// 91:           homepage "ftp://brew.sh/foo"
// 92:           url "https://brew.sh/foo-1.0.tgz"
// 93:           def patches
// 94:             files = %w[patch-domain_resolver.c patch-colormask.c patch-trafshow.c patch-trafshow.1 patch-configure]
// 95:             {
// 96:               :p0 =>
// 97:               files.collect{|p| "http://trac.macports.org/export/68507/trunk/dports/net/trafshow/files/\#{p}"}
// 98:             }
// 99:           end
// 100:         end
// 101:       RUBY
// 102:
// 103:       expected_offenses = [
// 104:         {
// 105:           message:  "FormulaAudit/Patches: Use the `patch` DSL instead of defining a `patches` method",
// 106:           severity: :convention,
// 107:           line:     4,
// 108:           column:   2,
// 109:           source:,
// 110:         }, {
// 111:           message:  "FormulaAudit/Patches: Patches from MacPorts Trac should be https://, not http: " \
// 112:                     "http://trac.macports.org/export/68507/trunk/dports/net/trafshow/files/",
// 113:           severity: :convention,
// 114:           line:     8,
// 115:           column:   25,
// 116:           source:,
// 117:         }
// 118:       ]
// 119:
// 120:       expected_offenses.zip(inspect_source(source)).each do |expected, actual|
// 121:         expect(actual.message).to eq(expected[:message])
// 122:         expect(actual.severity).to eq(expected[:severity])
// 123:         expect(actual.line).to eq(expected[:line])
// 124:         expect(actual.column).to eq(expected[:column])
// 125:       end
// 126:     end
// 127:   end
// 128:
// 129:   context "when auditing inline patches" do
// 130:     it "reports no offenses for valid inline patches" do
// 131:       expect_no_offenses(<<~RUBY)
// 132:         class Foo < Formula
// 133:           url 'https://brew.sh/foo-1.0.tgz'
// 134:           patch :DATA
// 135:         end
// 136:         __END__
// 137:         patch content here
// 138:       RUBY
// 139:     end
// 140:
// 141:     it "reports no offenses for valid nested inline patches" do
// 142:       expect_no_offenses(<<~RUBY)
// 143:         class Foo < Formula
// 144:           url 'https://brew.sh/foo-1.0.tgz'
// 145:           stable do
// 146:             patch :DATA
// 147:           end
// 148:         end
// 149:         __END__
// 150:         patch content here
// 151:       RUBY
// 152:     end
// 153:
// 154:     it "reports an offense when DATA is found with no __END__" do
// 155:       expect_offense(<<~RUBY)
// 156:         class Foo < Formula
// 157:           url 'https://brew.sh/foo-1.0.tgz'
// 158:           patch :DATA
// 159:           ^^^^^^^^^^^ FormulaAudit/Patches: Patch is missing `__END__`
// 160:         end
// 161:       RUBY
// 162:     end
// 163:
// 164:     it "reports an offense when __END__ is found with no DATA" do
// 165:       expect_offense(<<~RUBY)
// 166:         class Foo < Formula
// 167:           url 'https://brew.sh/foo-1.0.tgz'
// 168:         end
// 169:         __END__
// 170:         ^^^^^^^ FormulaAudit/Patches: Patch is missing `patch :DATA`
// 171:         patch content here
// 172:       RUBY
// 173:     end
// 174:   end
// 175:
// 176:   context "when auditing external patches" do
// 177:     it "reports an offense for various patch URLs" do
// 178:       patch_urls = [
// 179:         "https://raw.github.com/mogaal/sendemail",
// 180:         "https://mirrors.ustc.edu.cn/macports/trunk/",
// 181:         "https://patch-diff.githubusercontent.com/raw/foo/foo-bar/pull/100.patch",
// 182:         "https://github.com/uber/h3/pull/362.patch?full_index=1",
// 183:         "https://gitlab.gnome.org/GNOME/gitg/-/merge_requests/142.diff",
// 184:       ]
// 185:       patch_urls.each do |patch_url|
// 186:         source = <<~RUBY
// 187:           class Foo < Formula
// 188:             homepage "ftp://brew.sh/foo"
// 189:             url "https://brew.sh/foo-1.0.tgz"
// 190:             patch do
// 191:               url "#{patch_url}"
// 192:               sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 193:             end
// 194:           end
// 195:         RUBY
// 196:
// 197:         expected_offense = if patch_url.include?("/raw.github.com/")
// 198:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 8, source:)
// 199:             FormulaAudit/Patches: GitHub/Gist patches should specify a revision: #{patch_url}
// 200:           EOS
// 201:         elsif patch_url.include?("macports/trunk")
// 202:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 8, source:)
// 203:             FormulaAudit/Patches: MacPorts patches should specify a revision instead of trunk: #{patch_url}
// 204:           EOS
// 205:         elsif patch_url.match?(%r{https://github.com/[^/]*/[^/]*/pull})
// 206:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 8, source:)
// 207:             FormulaAudit/Patches: Use a commit hash URL rather than an unstable pull request URL: #{patch_url}
// 208:           EOS
// 209:         elsif patch_url.match?(%r{.*gitlab.*/merge_request.*})
// 210:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 8, source:)
// 211:             FormulaAudit/Patches: Use a commit hash URL rather than an unstable merge request URL: #{patch_url}
// 212:           EOS
// 213:         elsif patch_url.match?(%r{
// 214:           https?://patch-diff\.githubusercontent\.com/raw/(.+)/(.+)/pull/(.+)\.(?:diff|patch)
// 215:         }x)
// 216:           expect_offense_hash(message: <<~EOS.chomp, severity: :convention, line: 5, column: 8, source:)
// 217:             FormulaAudit/Patches: Use a commit hash URL rather than patch-diff: #{patch_url}
// 218:           EOS
// 219:         end
// 220:         expected_offense.zip([inspect_source(source).last]).each do |expected, actual|
// 221:           expect(actual.message).to eq(expected[:message])
// 222:           expect(actual.severity).to eq(expected[:severity])
// 223:           expect(actual.line).to eq(expected[:line])
// 224:           expect(actual.column).to eq(expected[:column])
// 225:         end
// 226:       end
// 227:     end
// 228:   end
// 229:
// 230:   context "when auditing local file patches" do
// 231:     it "reports no offenses for local file patches" do
// 232:       expect_no_offenses(<<~RUBY)
// 233:         class Foo < Formula
// 234:           url "https://brew.sh/foo-1.0.tgz"
// 235:           patch do
// 236:             file "Patches/foo.diff"
// 237:           end
// 238:         end
// 239:       RUBY
// 240:     end
// 241:   end
// 242:
// 243:   context "when auditing external patches with corrector" do
// 244:     it "corrects Bitbucket patch URLs to use API format" do
// 245:       expect_offense(<<~RUBY)
// 246:         class Foo < Formula
// 247:           url "https://brew.sh/foo-1.0.tgz"
// 248:           patch do
// 249:             url "https://bitbucket.org/multicoreware/x265_git/commits/b354c009a60bcd6d7fc04014e200a1ee9c45c167/raw"
// 250:                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Patches: Bitbucket patches should use the API URL: https://api.bitbucket.org/2.0/repositories/multicoreware/x265_git/diff/b354c009a60bcd6d7fc04014e200a1ee9c45c167
// 251:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 252:           end
// 253:         end
// 254:       RUBY
// 255:
// 256:       expect_correction(<<~RUBY)
// 257:         class Foo < Formula
// 258:           url "https://brew.sh/foo-1.0.tgz"
// 259:           patch do
// 260:             url "https://api.bitbucket.org/2.0/repositories/multicoreware/x265_git/diff/b354c009a60bcd6d7fc04014e200a1ee9c45c167"
// 261:             sha256 ""
// 262:           end
// 263:         end
// 264:       RUBY
// 265:     end
// 266:
// 267:     it "corrects HTTP MacPorts Trac URLs to HTTPS" do
// 268:       expect_offense(<<~RUBY)
// 269:         class Foo < Formula
// 270:           url "https://brew.sh/foo-1.0.tgz"
// 271:           patch do
// 272:             url "http://trac.macports.org/export/102865/trunk/dports/mail/uudeview/files/inews.c.patch"
// 273:                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Patches: Patches from MacPorts Trac should be https://, not http: http://trac.macports.org/export/102865/trunk/dports/mail/uudeview/files/inews.c.patch
// 274:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 275:           end
// 276:         end
// 277:       RUBY
// 278:
// 279:       expect_correction(<<~RUBY)
// 280:         class Foo < Formula
// 281:           url "https://brew.sh/foo-1.0.tgz"
// 282:           patch do
// 283:             url "https://trac.macports.org/export/102865/trunk/dports/mail/uudeview/files/inews.c.patch"
// 284:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 285:           end
// 286:         end
// 287:       RUBY
// 288:     end
// 289:
// 290:     it "corrects HTTP Debian bug URLs to HTTPS" do
// 291:       expect_offense(<<~RUBY)
// 292:         class Foo < Formula
// 293:           url "https://brew.sh/foo-1.0.tgz"
// 294:           patch do
// 295:             url "http://bugs.debian.org/cgi-bin/bugreport.cgi?msg=5;filename=patch-libunac1.txt;att=1;bug=623340"
// 296:                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Patches: Patches from Debian should be https://, not http: http://bugs.debian.org/cgi-bin/bugreport.cgi?msg=5;filename=patch-libunac1.txt;att=1;bug=623340
// 297:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 298:           end
// 299:         end
// 300:       RUBY
// 301:
// 302:       expect_correction(<<~RUBY)
// 303:         class Foo < Formula
// 304:           url "https://brew.sh/foo-1.0.tgz"
// 305:           patch do
// 306:             url "https://bugs.debian.org/cgi-bin/bugreport.cgi?msg=5;filename=patch-libunac1.txt;att=1;bug=623340"
// 307:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 308:           end
// 309:         end
// 310:       RUBY
// 311:     end
// 312:
// 313:     it "corrects GitHub commit URLs from .diff to .patch" do
// 314:       expect_offense(<<~RUBY)
// 315:         class Foo < Formula
// 316:           url "https://brew.sh/foo-1.0.tgz"
// 317:           patch do
// 318:             url "https://github.com/michaeldv/pit/commit/f64978d.diff"
// 319:                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Patches: GitHub patches should end with .patch, not .diff: https://github.com/michaeldv/pit/commit/f64978d.diff
// 320:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 321:           end
// 322:         end
// 323:       RUBY
// 324:
// 325:       expect_correction(<<~RUBY)
// 326:         class Foo < Formula
// 327:           url "https://brew.sh/foo-1.0.tgz"
// 328:           patch do
// 329:             url "https://github.com/michaeldv/pit/commit/f64978d.patch?full_index=1"
// 330:             sha256 ""
// 331:           end
// 332:         end
// 333:       RUBY
// 334:     end
// 335:
// 336:     it "corrects GitLab commit URLs from .patch to .diff" do
// 337:       expect_offense(<<~RUBY)
// 338:         class Foo < Formula
// 339:           url "https://brew.sh/foo-1.0.tgz"
// 340:           patch do
// 341:             url "https://gitlab.com/inkscape/lib2geom/-/commit/0b8b4c26b4a.patch"
// 342:                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Patches: GitLab patches should end with .diff, not .patch: https://gitlab.com/inkscape/lib2geom/-/commit/0b8b4c26b4a.patch
// 343:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 344:           end
// 345:         end
// 346:       RUBY
// 347:
// 348:       expect_correction(<<~RUBY)
// 349:         class Foo < Formula
// 350:           url "https://brew.sh/foo-1.0.tgz"
// 351:           patch do
// 352:             url "https://gitlab.com/inkscape/lib2geom/-/commit/0b8b4c26b4a.diff"
// 353:             sha256 ""
// 354:           end
// 355:         end
// 356:       RUBY
// 357:     end
// 358:
// 359:     it "corrects GitHub patch URLs to add full_index parameter" do
// 360:       expect_offense(<<~RUBY)
// 361:         class Foo < Formula
// 362:           url "https://brew.sh/foo-1.0.tgz"
// 363:           patch do
// 364:             url "https://github.com/foo/bar/commit/abc123.patch"
// 365:                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Patches: GitHub patches should use the full_index parameter: https://github.com/foo/bar/commit/abc123.patch?full_index=1
// 366:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 367:           end
// 368:         end
// 369:       RUBY
// 370:
// 371:       expect_correction(<<~RUBY)
// 372:         class Foo < Formula
// 373:           url "https://brew.sh/foo-1.0.tgz"
// 374:           patch do
// 375:             url "https://github.com/foo/bar/commit/abc123.patch?full_index=1"
// 376:             sha256 ""
// 377:           end
// 378:         end
// 379:       RUBY
// 380:     end
// 381:
// 382:     it "corrects GitHub URLs with 'diff' in the path" do
// 383:       expect_offense(<<~RUBY)
// 384:         class Foo < Formula
// 385:           url "https://brew.sh/foo-1.0.tgz"
// 386:           patch do
// 387:             url "https://github.com/diff-tool/diff-utils/commit/abc123.diff"
// 388:                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Patches: GitHub patches should end with .patch, not .diff: https://github.com/diff-tool/diff-utils/commit/abc123.diff
// 389:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 390:           end
// 391:         end
// 392:       RUBY
// 393:
// 394:       expect_correction(<<~RUBY)
// 395:         class Foo < Formula
// 396:           url "https://brew.sh/foo-1.0.tgz"
// 397:           patch do
// 398:             url "https://github.com/diff-tool/diff-utils/commit/abc123.patch?full_index=1"
// 399:             sha256 ""
// 400:           end
// 401:         end
// 402:       RUBY
// 403:     end
// 404:
// 405:     it "corrects GitLab URLs with 'patch' in the path" do
// 406:       expect_offense(<<~RUBY)
// 407:         class Foo < Formula
// 408:           url "https://brew.sh/foo-1.0.tgz"
// 409:           patch do
// 410:             url "https://gitlab.com/patch-tool/patch-utils/-/commit/abc123.patch"
// 411:                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Patches: GitLab patches should end with .diff, not .patch: https://gitlab.com/patch-tool/patch-utils/-/commit/abc123.patch
// 412:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 413:           end
// 414:         end
// 415:       RUBY
// 416:
// 417:       expect_correction(<<~RUBY)
// 418:         class Foo < Formula
// 419:           url "https://brew.sh/foo-1.0.tgz"
// 420:           patch do
// 421:             url "https://gitlab.com/patch-tool/patch-utils/-/commit/abc123.diff"
// 422:             sha256 ""
// 423:           end
// 424:         end
// 425:       RUBY
// 426:     end
// 427:
// 428:     it "corrects GitHub URLs without sha256 field (e.g. with on_linux block)" do
// 429:       expect_offense(<<~RUBY)
// 430:         class Foo < Formula
// 431:           url "https://brew.sh/foo-1.0.tgz"
// 432:           patch :p2 do
// 433:             on_linux do
// 434:               url "https://github.com/foo/bar/commit/abc123.diff"
// 435:                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Patches: GitHub patches should end with .patch, not .diff: https://github.com/foo/bar/commit/abc123.diff
// 436:               directory "gl"
// 437:             end
// 438:           end
// 439:         end
// 440:       RUBY
// 441:
// 442:       expect_correction(<<~RUBY)
// 443:         class Foo < Formula
// 444:           url "https://brew.sh/foo-1.0.tgz"
// 445:           patch :p2 do
// 446:             on_linux do
// 447:               url "https://github.com/foo/bar/commit/abc123.patch?full_index=1"
// 448:               directory "gl"
// 449:             end
// 450:           end
// 451:         end
// 452:       RUBY
// 453:     end
// 454:   end
// 455:
// 456:   context "when auditing patch resolves" do
// 457:     it "reports no offenses for CVE ids, GHSA ids, OSV ids and issue URLs" do
// 458:       expect_no_offenses(<<~RUBY)
// 459:         class Foo < Formula
// 460:           url "https://brew.sh/foo-1.0.tgz"
// 461:           patch do
// 462:             url "https://brew.sh/foo.diff"
// 463:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 464:             resolves "CVE-2024-1234", "GHSA-xr7r-f8xq-vfvv", "OSV-2023-298", "https://github.com/foo/bar/issues/1"
// 465:           end
// 466:         end
// 467:       RUBY
// 468:     end
// 469:
// 470:     it "reports and corrects non-canonical CVE identifiers" do
// 471:       expect_offense(<<~RUBY)
// 472:         class Foo < Formula
// 473:           url "https://brew.sh/foo-1.0.tgz"
// 474:           patch do
// 475:             url "https://brew.sh/foo.diff"
// 476:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 477:             resolves "cve-2024-1234"
// 478:                      ^^^^^^^^^^^^^^^ FormulaAudit/Patches: `resolves` should use the canonical CVE format: CVE-2024-1234
// 479:           end
// 480:         end
// 481:       RUBY
// 482:
// 483:       expect_correction(<<~RUBY)
// 484:         class Foo < Formula
// 485:           url "https://brew.sh/foo-1.0.tgz"
// 486:           patch do
// 487:             url "https://brew.sh/foo.diff"
// 488:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 489:             resolves "CVE-2024-1234"
// 490:           end
// 491:         end
// 492:       RUBY
// 493:     end
// 494:
// 495:     it "reports an offense for unrecognised identifiers" do
// 496:       expect_offense(<<~RUBY)
// 497:         class Foo < Formula
// 498:           url "https://brew.sh/foo-1.0.tgz"
// 499:           patch do
// 500:             url "https://brew.sh/foo.diff"
// 501:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 502:             resolves "issue-123"
// 503:                      ^^^^^^^^^^^ FormulaAudit/Patches: `resolves` should be a CVE/GHSA/OSV identifier or issue URL, got: "issue-123"
// 504:           end
// 505:         end
// 506:       RUBY
// 507:     end
// 508:
// 509:     it "reports an offense for non-string arguments" do
// 510:       expect_offense(<<~RUBY)
// 511:         class Foo < Formula
// 512:           url "https://brew.sh/foo-1.0.tgz"
// 513:           patch do
// 514:             url "https://brew.sh/foo.diff"
// 515:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 516:             resolves :CVE_2024_1234
// 517:                      ^^^^^^^^^^^^^^ FormulaAudit/Patches: `resolves` should be passed identifier strings (CVE/GHSA/OSV id or issue URL)
// 518:           end
// 519:         end
// 520:       RUBY
// 521:     end
// 522:   end
// 523:
// 524:   context "when auditing patch type" do
// 525:     it "reports no offenses for valid types" do
// 526:       expect_no_offenses(<<~RUBY)
// 527:         class Foo < Formula
// 528:           url "https://brew.sh/foo-1.0.tgz"
// 529:           patch do
// 530:             url "https://brew.sh/foo.diff"
// 531:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 532:             type :backport
// 533:           end
// 534:         end
// 535:       RUBY
// 536:     end
// 537:
// 538:     it "reports an offense for invalid types" do
// 539:       expect_offense(<<~RUBY)
// 540:         class Foo < Formula
// 541:           url "https://brew.sh/foo-1.0.tgz"
// 542:           patch do
// 543:             url "https://brew.sh/foo.diff"
// 544:             sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 545:             type :hotfix
// 546:                  ^^^^^^^ FormulaAudit/Patches: Patch `type` should be one of: :unofficial, :backport, :cherry_pick
// 547:           end
// 548:         end
// 549:       RUBY
// 550:     end
// 551:   end
// 552: end
