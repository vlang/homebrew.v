module test

import brew_runtime

// Translated from Homebrew/brew `test/keg_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:dst) { HOMEBREW_PREFIX/"bin"/"helloworld" }` at line 8.
pub fn ruby_keg_spec_l8_d1_dst(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dst', ...args)
}

// Ruby let `let(:nonexistent) { Pathname.new("/some/nonexistent/path") }` at line 9.
pub fn ruby_keg_spec_l9_d2_nonexistent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nonexistent', ...args)
}

// Ruby let! `let!(:keg) { setup_test_keg("foo", "1.0") }` at line 10.
pub fn ruby_keg_spec_l10_d3_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg', ...args)
}

// Ruby let `let(:kegs) { [] }` at line 11.
pub fn ruby_keg_spec_l11_d4_kegs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('kegs', ...args)
}

// Ruby method `setup_test_keg(name, version)` at line 15.
pub fn ruby_keg_spec_l15_d5_setup_test_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_test_keg', ...args)
}

// Ruby specify `specify "::all" do` at line 38.
pub fn ruby_keg_spec_l38_d6_all(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::all', ...args)
}

// Ruby specify `specify "#empty_installation?" do` at line 42.
pub fn ruby_keg_spec_l42_d7_empty_installation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#empty_installation?', ...args)
}

// Ruby specify `specify "#oldname_opt_records" do` at line 59.
pub fn ruby_keg_spec_l59_d8_oldname_opt_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#oldname_opt_records', ...args)
}

// Ruby specify `specify "#remove_oldname_opt_records" do` at line 66.
pub fn ruby_keg_spec_l66_d9_remove_oldname_opt_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#remove_oldname_opt_records', ...args)
}

// Ruby it `it "links a Keg" do` at line 78.
pub fn ruby_keg_spec_l78_d10_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Ruby let `let(:options) { { dry_run: true } }` at line 86.
pub fn ruby_keg_spec_l86_d11_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('options', ...args)
}

// Ruby it `it "only prints what would be done" do` at line 88.
pub fn ruby_keg_spec_l88_d12_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby it `it "fails when already linked" do` at line 101.
pub fn ruby_keg_spec_l101_d13_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "fails when files exist" do` at line 107.
pub fn ruby_keg_spec_l107_d14_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "ignores broken symlinks at target" do` at line 113.
pub fn ruby_keg_spec_l113_d15_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby let `let(:options) { { overwrite: true } }` at line 121.
pub fn ruby_keg_spec_l121_d16_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('options', ...args)
}

// Ruby it `it "overwrite existing files" do` at line 123.
pub fn ruby_keg_spec_l123_d17_overwrite(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('overwrite', ...args)
}

// Ruby it `it "overwrites broken symlinks" do` at line 129.
pub fn ruby_keg_spec_l129_d18_overwrites(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('overwrites', ...args)
}

// Ruby it `it "still supports dryrun" do` at line 135.
pub fn ruby_keg_spec_l135_d19_still(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('still', ...args)
}

// Ruby it `it "also creates an opt link" do` at line 150.
pub fn ruby_keg_spec_l150_d20_also(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('also', ...args)
}

// Ruby specify `specify "pkgconfig directory is created" do` at line 156.
pub fn ruby_keg_spec_l156_d21_pkgconfig(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkgconfig', ...args)
}

// Ruby specify `specify "cmake directory is created" do` at line 163.
pub fn ruby_keg_spec_l163_d22_cmake(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cmake', ...args)
}

// Ruby specify `specify "lib/cps directory is created" do` at line 170.
pub fn ruby_keg_spec_l170_d23_lib_cps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lib/cps', ...args)
}

// Ruby specify `specify "share/cps directory is created" do` at line 177.
pub fn ruby_keg_spec_l177_d24_share_cps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('share/cps', ...args)
}

// Ruby specify `specify "share/pwsh directory is created" do` at line 184.
pub fn ruby_keg_spec_l184_d25_share_pwsh(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('share/pwsh', ...args)
}

// Ruby specify `specify "symlinks are linked directly" do` at line 192.
pub fn ruby_keg_spec_l192_d26_symlinks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symlinks', ...args)
}

// Ruby it `it "unlinks a Keg" do` at line 205.
pub fn ruby_keg_spec_l205_d27_unlinks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlinks', ...args)
}

// Ruby it `it "prunes empty top-level directories" do` at line 212.
pub fn ruby_keg_spec_l212_d28_prunes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prunes', ...args)
}

// Ruby it `it "ignores .DS_Store when pruning empty directories" do` at line 222.
pub fn ruby_keg_spec_l222_d29_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "doesn't remove opt link" do` at line 234.
pub fn ruby_keg_spec_l234_d30_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "preverves broken symlinks pointing outside the Keg" do` at line 240.
pub fn ruby_keg_spec_l240_d31_preverves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preverves', ...args)
}

// Ruby it `it "preverves broken symlinks pointing into the Keg" do` at line 248.
pub fn ruby_keg_spec_l248_d32_preverves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preverves', ...args)
}

// Ruby it `it "preverves symlinks pointing outside the Keg" do` at line 255.
pub fn ruby_keg_spec_l255_d33_preverves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preverves', ...args)
}

// Ruby it `it "preserves real files" do` at line 263.
pub fn ruby_keg_spec_l263_d34_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "ignores nonexistent file" do` at line 271.
pub fn ruby_keg_spec_l271_d35_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "doesn't remove links to symlinks" do` at line 277.
pub fn ruby_keg_spec_l277_d36_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "removes broken symlinks that conflict with directories" do` at line 295.
pub fn ruby_keg_spec_l295_d37_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Ruby it `it "creates an opt link" do` at line 312.
pub fn ruby_keg_spec_l312_d38_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "doesn't fail if already opt-linked" do` at line 324.
pub fn ruby_keg_spec_l324_d39_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "replaces an existing directory" do` at line 330.
pub fn ruby_keg_spec_l330_d40_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replaces', ...args)
}

// Ruby it `it "replaces an existing file" do` at line 336.
pub fn ruby_keg_spec_l336_d41_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replaces', ...args)
}

// Ruby it `it "identifies Homebrew service files" do` at line 345.
pub fn ruby_keg_spec_l345_d42_identifies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('identifies', ...args)
}

// Ruby specify `specify "#link and` at line 367.
pub fn ruby_keg_spec_l367_d43_link(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#link', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "keg"
// 5: require "stringio"
// 6:
// 7: RSpec.describe Keg do
// 8:   let(:dst) { HOMEBREW_PREFIX/"bin"/"helloworld" }
// 9:   let(:nonexistent) { Pathname.new("/some/nonexistent/path") }
// 10:   let!(:keg) { setup_test_keg("foo", "1.0") }
// 11:   let(:kegs) { [] }
// 12:
// 13:   include FileUtils
// 14:
// 15:   def setup_test_keg(name, version)
// 16:     path = HOMEBREW_CELLAR/name/version
// 17:     (path/"bin").mkpath
// 18:
// 19:     %w[hiworld helloworld goodbye_cruel_world].each do |file|
// 20:       touch path/"bin"/file
// 21:     end
// 22:
// 23:     keg = Keg.new(path)
// 24:     kegs << keg
// 25:     keg
// 26:   end
// 27:
// 28:   before do
// 29:     (HOMEBREW_PREFIX/"bin").mkpath
// 30:     (HOMEBREW_PREFIX/"lib").mkpath
// 31:   end
// 32:
// 33:   after do
// 34:     kegs.each(&:unlink)
// 35:     rmtree HOMEBREW_PREFIX/"lib"
// 36:   end
// 37:
// 38:   specify "::all" do
// 39:     expect(described_class.all).to eq([keg])
// 40:   end
// 41:
// 42:   specify "#empty_installation?" do
// 43:     %w[.DS_Store INSTALL_RECEIPT.json LICENSE.txt].each do |file|
// 44:       touch keg/file
// 45:     end
// 46:
// 47:     expect(keg).to exist
// 48:     expect(keg).to be_a_directory
// 49:     expect(keg).not_to be_an_empty_installation
// 50:
// 51:     FileUtils.rm_r(keg/"bin")
// 52:     expect(keg).to be_an_empty_installation
// 53:
// 54:     (keg/"bin").mkpath
// 55:     touch keg.join("bin", "todo")
// 56:     expect(keg).not_to be_an_empty_installation
// 57:   end
// 58:
// 59:   specify "#oldname_opt_records" do
// 60:     expect(keg.oldname_opt_records).to be_empty
// 61:     oldname_opt_record = HOMEBREW_PREFIX/"opt/oldfoo"
// 62:     oldname_opt_record.make_relative_symlink(HOMEBREW_CELLAR/"foo/1.0")
// 63:     expect(keg.oldname_opt_records).to eq([oldname_opt_record])
// 64:   end
// 65:
// 66:   specify "#remove_oldname_opt_records" do
// 67:     oldname_opt_record = HOMEBREW_PREFIX/"opt/oldfoo"
// 68:     oldname_opt_record.make_relative_symlink(HOMEBREW_CELLAR/"foo/2.0")
// 69:     keg.remove_oldname_opt_records
// 70:     expect(oldname_opt_record).to be_a_symlink
// 71:     oldname_opt_record.unlink
// 72:     oldname_opt_record.make_relative_symlink(HOMEBREW_CELLAR/"foo/1.0")
// 73:     keg.remove_oldname_opt_records
// 74:     expect(oldname_opt_record).not_to be_a_symlink
// 75:   end
// 76:
// 77:   describe "#link" do
// 78:     it "links a Keg" do
// 79:       expect(keg.link).to eq(3)
// 80:       (HOMEBREW_PREFIX/"bin").children.each do |c|
// 81:         expect(c.readlink).to be_relative
// 82:       end
// 83:     end
// 84:
// 85:     context "with dry run set to true" do
// 86:       let(:options) { { dry_run: true } }
// 87:
// 88:       it "only prints what would be done" do
// 89:         expect do
// 90:           expect(keg.link(**options)).to eq(0)
// 91:         end.to output(<<~EOF).to_stdout
// 92:           #{HOMEBREW_PREFIX}/bin/goodbye_cruel_world
// 93:           #{HOMEBREW_PREFIX}/bin/helloworld
// 94:           #{HOMEBREW_PREFIX}/bin/hiworld
// 95:         EOF
// 96:
// 97:         expect(keg).not_to be_linked
// 98:       end
// 99:     end
// 100:
// 101:     it "fails when already linked" do
// 102:       keg.link
// 103:
// 104:       expect { keg.link }.to raise_error(Keg::AlreadyLinkedError)
// 105:     end
// 106:
// 107:     it "fails when files exist" do
// 108:       touch dst
// 109:
// 110:       expect { keg.link }.to raise_error(Keg::ConflictError)
// 111:     end
// 112:
// 113:     it "ignores broken symlinks at target" do
// 114:       src = keg/"bin"/"helloworld"
// 115:       dst.make_symlink(nonexistent)
// 116:       keg.link
// 117:       expect(dst.readlink).to eq(src.relative_path_from(dst.dirname))
// 118:     end
// 119:
// 120:     context "with overwrite set to true" do
// 121:       let(:options) { { overwrite: true } }
// 122:
// 123:       it "overwrite existing files" do
// 124:         touch dst
// 125:         expect(keg.link(**options)).to eq(3)
// 126:         expect(keg).to be_linked
// 127:       end
// 128:
// 129:       it "overwrites broken symlinks" do
// 130:         dst.make_symlink "nowhere"
// 131:         expect(keg.link(**options)).to eq(3)
// 132:         expect(keg).to be_linked
// 133:       end
// 134:
// 135:       it "still supports dryrun" do
// 136:         touch dst
// 137:
// 138:         options[:dry_run] = true
// 139:
// 140:         expect do
// 141:           expect(keg.link(**options)).to eq(0)
// 142:         end.to output(<<~EOF).to_stdout
// 143:           #{dst}
// 144:         EOF
// 145:
// 146:         expect(keg).not_to be_linked
// 147:       end
// 148:     end
// 149:
// 150:     it "also creates an opt link" do
// 151:       expect(keg).not_to be_optlinked
// 152:       keg.link
// 153:       expect(keg).to be_optlinked
// 154:     end
// 155:
// 156:     specify "pkgconfig directory is created" do
// 157:       link = HOMEBREW_PREFIX/"lib"/"pkgconfig"
// 158:       (keg/"lib"/"pkgconfig").mkpath
// 159:       keg.link
// 160:       expect(link.lstat).to be_a_directory
// 161:     end
// 162:
// 163:     specify "cmake directory is created" do
// 164:       link = HOMEBREW_PREFIX/"lib"/"cmake"
// 165:       (keg/"lib"/"cmake").mkpath
// 166:       keg.link
// 167:       expect(link.lstat).to be_a_directory
// 168:     end
// 169:
// 170:     specify "lib/cps directory is created" do
// 171:       link = HOMEBREW_PREFIX/"lib"/"cps"
// 172:       (keg/"lib"/"cps").mkpath
// 173:       keg.link
// 174:       expect(link.lstat).to be_a_directory
// 175:     end
// 176:
// 177:     specify "share/cps directory is created" do
// 178:       link = HOMEBREW_PREFIX/"share"/"cps"
// 179:       (keg/"share"/"cps").mkpath
// 180:       keg.link
// 181:       expect(link.lstat).to be_a_directory
// 182:     end
// 183:
// 184:     specify "share/pwsh directory is created" do
// 185:       link = HOMEBREW_PREFIX/"share"/"pwsh"
// 186:       (keg/"share"/"pwsh"/"completions").mkpath
// 187:       FileUtils.touch keg/"share"/"pwsh"/"completions"/"_test.ps1"
// 188:       keg.link
// 189:       expect(link.lstat).to be_a_directory
// 190:     end
// 191:
// 192:     specify "symlinks are linked directly" do
// 193:       link = HOMEBREW_PREFIX/"lib"/"pkgconfig"
// 194:
// 195:       (keg/"lib"/"example").mkpath
// 196:       (keg/"lib"/"pkgconfig").make_symlink "example"
// 197:       keg.link
// 198:
// 199:       expect(link.resolved_path).to be_a_symlink
// 200:       expect(link.lstat).to be_a_symlink
// 201:     end
// 202:   end
// 203:
// 204:   describe "#unlink" do
// 205:     it "unlinks a Keg" do
// 206:       keg.link
// 207:       expect(dst).to be_a_symlink
// 208:       expect(keg.unlink).to eq(3)
// 209:       expect(dst).not_to be_a_symlink
// 210:     end
// 211:
// 212:     it "prunes empty top-level directories" do
// 213:       mkpath HOMEBREW_PREFIX/"lib/foo/bar"
// 214:       mkpath keg/"lib/foo/bar"
// 215:       touch keg/"lib/foo/bar/file1"
// 216:
// 217:       keg.unlink
// 218:
// 219:       expect(HOMEBREW_PREFIX/"lib/foo").not_to be_a_directory
// 220:     end
// 221:
// 222:     it "ignores .DS_Store when pruning empty directories" do
// 223:       mkpath HOMEBREW_PREFIX/"lib/foo/bar"
// 224:       touch HOMEBREW_PREFIX/"lib/foo/.DS_Store"
// 225:       mkpath keg/"lib/foo/bar"
// 226:       touch keg/"lib/foo/bar/file1"
// 227:
// 228:       keg.unlink
// 229:
// 230:       expect(HOMEBREW_PREFIX/"lib/foo").not_to be_a_directory
// 231:       expect(HOMEBREW_PREFIX/"lib/foo/.DS_Store").not_to exist
// 232:     end
// 233:
// 234:     it "doesn't remove opt link" do
// 235:       keg.link
// 236:       keg.unlink
// 237:       expect(keg).to be_optlinked
// 238:     end
// 239:
// 240:     it "preverves broken symlinks pointing outside the Keg" do
// 241:       keg.link
// 242:       dst.delete
// 243:       dst.make_symlink(nonexistent)
// 244:       keg.unlink
// 245:       expect(dst).to be_a_symlink
// 246:     end
// 247:
// 248:     it "preverves broken symlinks pointing into the Keg" do
// 249:       keg.link
// 250:       dst.resolved_path.delete
// 251:       keg.unlink
// 252:       expect(dst).to be_a_symlink
// 253:     end
// 254:
// 255:     it "preverves symlinks pointing outside the Keg" do
// 256:       keg.link
// 257:       dst.delete
// 258:       dst.make_symlink(Pathname.new("/bin/sh"))
// 259:       keg.unlink
// 260:       expect(dst).to be_a_symlink
// 261:     end
// 262:
// 263:     it "preserves real files" do
// 264:       keg.link
// 265:       dst.delete
// 266:       touch dst
// 267:       keg.unlink
// 268:       expect(dst).to be_a_file
// 269:     end
// 270:
// 271:     it "ignores nonexistent file" do
// 272:       keg.link
// 273:       dst.delete
// 274:       expect(keg.unlink).to eq(2)
// 275:     end
// 276:
// 277:     it "doesn't remove links to symlinks" do
// 278:       a = HOMEBREW_CELLAR/"a"/"1.0"
// 279:       b = HOMEBREW_CELLAR/"b"/"1.0"
// 280:
// 281:       (a/"lib"/"example").mkpath
// 282:       (a/"lib"/"example2").make_symlink "example"
// 283:       (b/"lib"/"example2").mkpath
// 284:
// 285:       a = described_class.new(a)
// 286:       b = described_class.new(b)
// 287:       a.link
// 288:
// 289:       lib = HOMEBREW_PREFIX/"lib"
// 290:       expect(lib.children.length).to eq(2)
// 291:       expect { b.link }.to raise_error(Keg::ConflictError)
// 292:       expect(lib.children.length).to eq(2)
// 293:     end
// 294:
// 295:     it "removes broken symlinks that conflict with directories" do
// 296:       a = HOMEBREW_CELLAR/"a"/"1.0"
// 297:       (a/"lib"/"foo").mkpath
// 298:
// 299:       keg = described_class.new(a)
// 300:
// 301:       link = HOMEBREW_PREFIX/"lib"/"foo"
// 302:       link.parent.mkpath
// 303:       link.make_symlink(nonexistent)
// 304:
// 305:       keg.link
// 306:
// 307:       expect(link).to be_a_directory
// 308:     end
// 309:   end
// 310:
// 311:   describe "#optlink" do
// 312:     it "creates an opt link" do
// 313:       oldname_opt_record = HOMEBREW_PREFIX/"opt/oldfoo"
// 314:       oldname_opt_record.make_relative_symlink(HOMEBREW_CELLAR/"foo/1.0")
// 315:       keg_record = HOMEBREW_CELLAR/"foo"/"2.0"
// 316:       (keg_record/"bin").mkpath
// 317:       keg = described_class.new(keg_record)
// 318:       keg.optlink
// 319:       expect(keg_record).to eq(oldname_opt_record.resolved_path)
// 320:       keg.uninstall
// 321:       expect(oldname_opt_record).not_to be_a_symlink
// 322:     end
// 323:
// 324:     it "doesn't fail if already opt-linked" do
// 325:       keg.opt_record.make_relative_symlink Pathname.new(keg)
// 326:       keg.optlink
// 327:       expect(keg).to be_optlinked
// 328:     end
// 329:
// 330:     it "replaces an existing directory" do
// 331:       keg.opt_record.mkpath
// 332:       keg.optlink
// 333:       expect(keg).to be_optlinked
// 334:     end
// 335:
// 336:     it "replaces an existing file" do
// 337:       keg.opt_record.parent.mkpath
// 338:       keg.opt_record.write("foo")
// 339:       keg.optlink
// 340:       expect(keg).to be_optlinked
// 341:     end
// 342:   end
// 343:
// 344:   describe "#homebrew_created_file?" do
// 345:     it "identifies Homebrew service files" do
// 346:       plist_file = instance_double(Pathname, extname: ".plist", basename: Pathname.new("homebrew.foo.plist"))
// 347:       service_file = instance_double(Pathname, extname: ".service", basename: Pathname.new("homebrew.foo.service"))
// 348:       timer_file = instance_double(Pathname, extname: ".timer", basename: Pathname.new("homebrew.foo.timer"))
// 349:       regular_file = instance_double(Pathname, extname: ".txt", basename: Pathname.new("readme.txt"))
// 350:       non_homebrew_plist = instance_double(Pathname, extname:  ".plist",
// 351:                                                      basename: Pathname.new("com.example.foo.plist"))
// 352:
// 353:       allow(plist_file.basename).to receive(:to_s).and_return("homebrew.foo.plist")
// 354:       allow(service_file.basename).to receive(:to_s).and_return("homebrew.foo.service")
// 355:       allow(timer_file.basename).to receive(:to_s).and_return("homebrew.foo.timer")
// 356:       allow(regular_file.basename).to receive(:to_s).and_return("readme.txt")
// 357:       allow(non_homebrew_plist.basename).to receive(:to_s).and_return("com.example.foo.plist")
// 358:
// 359:       expect(keg.homebrew_created_file?(plist_file)).to be true
// 360:       expect(keg.homebrew_created_file?(service_file)).to be true
// 361:       expect(keg.homebrew_created_file?(timer_file)).to be true
// 362:       expect(keg.homebrew_created_file?(regular_file)).to be false
// 363:       expect(keg.homebrew_created_file?(non_homebrew_plist)).to be false
// 364:     end
// 365:   end
// 366:
// 367:   specify "#link and #unlink" do
// 368:     expect(keg).not_to be_linked
// 369:     keg.link
// 370:     expect(keg).to be_linked
// 371:     keg.unlink
// 372:     expect(keg).not_to be_linked
// 373:   end
// 374: end
