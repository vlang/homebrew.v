module test

import brew_runtime

// Translated from Homebrew/brew `test/patching_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:formula_subclass) do` at line 7.
pub fn ruby_patching_spec_l7_d1_formula_subclass(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_subclass', ...args)
}

// Ruby method `self.resource(*, **, &block)` at line 11.
pub fn ruby_patching_spec_l11_d2_self_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.resource', ...args)
}

// Ruby define_singleton_method `define_singleton_method :patch do |*patch_args, **patch_kwargs, &patch_block|` at line 15.
pub fn ruby_patching_spec_l15_d3_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby method `self.patch(*, **, &block)` at line 27.
pub fn ruby_patching_spec_l27_d4_self_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.patch', ...args)
}

// Ruby method `formula(name = "formula_name", path: Formulary.core_path(name), spec: :stable, alias_path: nil, tap: nil,` at line 40.
pub fn ruby_patching_spec_l40_d5_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby matcher `matcher :be_patched do` at line 46.
pub fn ruby_patching_spec_l46_d6_be_patched(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_patched', ...args)
}

// Ruby matcher `matcher :be_patched_with_homebrew_prefix do` at line 57.
pub fn ruby_patching_spec_l57_d7_be_patched_with_homebrew_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_patched_with_homebrew_prefix', ...args)
}

// Ruby matcher `matcher :have_its_resource_patched do` at line 69.
pub fn ruby_patching_spec_l69_d8_have_its_resource_patched(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('have_its_resource_patched', ...args)
}

// Ruby matcher `matcher :be_sequentially_patched do` at line 80.
pub fn ruby_patching_spec_l80_d9_be_sequentially_patched(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_sequentially_patched', ...args)
}

// Ruby matcher `matcher :miss_apply do` at line 92.
pub fn ruby_patching_spec_l92_d10_miss_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('miss_apply', ...args)
}

// Ruby specify `specify "single_patch_dsl" do` at line 102.
pub fn ruby_patching_spec_l102_d11_single_patch_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl', ...args)
}

// Ruby specify `specify "local_patch_dsl_resolves_path_loaded_formulae_from_formula_directory" do` at line 114.
pub fn ruby_patching_spec_l114_d12_local_patch_dsl_resolves_path_loaded_formulae_from_formula_directory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_patch_dsl_resolves_path_loaded_formulae_from_formula_directory',
		...args)
}

// Ruby specify `specify "local_patch_dsl_with_directory" do` at line 125.
pub fn ruby_patching_spec_l125_d13_local_patch_dsl_with_directory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_patch_dsl_with_directory', ...args)
}

// Ruby specify `specify "local_patch_dsl_with_strip" do` at line 137.
pub fn ruby_patching_spec_l137_d14_local_patch_dsl_with_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_patch_dsl_with_strip', ...args)
}

// Ruby specify `specify "local_patch_dsl_with_homebrew_prefix" do` at line 148.
pub fn ruby_patching_spec_l148_d15_local_patch_dsl_with_homebrew_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_patch_dsl_with_homebrew_prefix', ...args)
}

// Ruby specify `specify "local_patch_dsl_resolves_tapped_formulae_from_tap_root" do` at line 159.
pub fn ruby_patching_spec_l159_d16_local_patch_dsl_resolves_tapped_formulae_from_tap_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_patch_dsl_resolves_tapped_formulae_from_tap_root',
		...args)
}

// Ruby specify `specify "local_patch_dsl_missing_file_fail" do` at line 177.
pub fn ruby_patching_spec_l177_d17_local_patch_dsl_missing_file_fail(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_patch_dsl_missing_file_fail', ...args)
}

// Ruby specify `specify "local_patch_dsl_directory_fail" do` at line 189.
pub fn ruby_patching_spec_l189_d18_local_patch_dsl_directory_fail(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_patch_dsl_directory_fail', ...args)
}

// Ruby specify `specify "local_patch_dsl_rejects_symlink_escape" do` at line 201.
pub fn ruby_patching_spec_l201_d19_local_patch_dsl_rejects_symlink_escape(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_patch_dsl_rejects_symlink_escape', ...args)
}

// Ruby specify `specify "single_patch_dsl_for_resource" do` at line 220.
pub fn ruby_patching_spec_l220_d20_single_patch_dsl_for_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl_for_resource', ...args)
}

// Ruby specify `specify "single_patch_dsl_with_apply" do` at line 237.
pub fn ruby_patching_spec_l237_d21_single_patch_dsl_with_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl_with_apply', ...args)
}

// Ruby specify `specify "single_patch_dsl_with_sequential_apply" do` at line 250.
pub fn ruby_patching_spec_l250_d22_single_patch_dsl_with_sequential_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl_with_sequential_apply', ...args)
}

// Ruby specify `specify "single_patch_dsl_with_strip" do` at line 263.
pub fn ruby_patching_spec_l263_d23_single_patch_dsl_with_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl_with_strip', ...args)
}

// Ruby specify `specify "single_patch_dsl_with_strip_with_apply" do` at line 275.
pub fn ruby_patching_spec_l275_d24_single_patch_dsl_with_strip_with_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl_with_strip_with_apply', ...args)
}

// Ruby specify `specify "single_patch_dsl_with_incorrect_strip" do` at line 292.
pub fn ruby_patching_spec_l292_d25_single_patch_dsl_with_incorrect_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl_with_incorrect_strip', ...args)
}

// Ruby specify `specify "single_patch_dsl_with_incorrect_strip_with_apply" do` at line 306.
pub fn ruby_patching_spec_l306_d26_single_patch_dsl_with_incorrect_strip_with_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl_with_incorrect_strip_with_apply',
		...args)
}

// Ruby specify `specify "patch_p0_dsl" do` at line 321.
pub fn ruby_patching_spec_l321_d27_patch_p0_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_p0_dsl', ...args)
}

// Ruby specify `specify "patch_p0_dsl_with_apply" do` at line 333.
pub fn ruby_patching_spec_l333_d28_patch_p0_dsl_with_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_p0_dsl_with_apply', ...args)
}

// Ruby specify `specify "patch_string" do` at line 346.
pub fn ruby_patching_spec_l346_d29_patch_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_string', ...args)
}

// Ruby specify `specify "patch_string_with_strip" do` at line 355.
pub fn ruby_patching_spec_l355_d30_patch_string_with_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_string_with_strip', ...args)
}

// Ruby specify `specify "single_patch_dsl_missing_apply_fail" do` at line 364.
pub fn ruby_patching_spec_l364_d31_single_patch_dsl_missing_apply_fail(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl_missing_apply_fail', ...args)
}

// Ruby specify `specify "single_patch_dsl_with_apply_enoent_fail" do` at line 376.
pub fn ruby_patching_spec_l376_d32_single_patch_dsl_with_apply_enoent_fail(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_patch_dsl_with_apply_enoent_fail', ...args)
}

// Ruby specify `specify "patch_dsl_with_homebrew_prefix" do` at line 391.
pub fn ruby_patching_spec_l391_d33_patch_dsl_with_homebrew_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_dsl_with_homebrew_prefix', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5:
// 6: RSpec.describe "patching", type: :system do
// 7:   let(:formula_subclass) do
// 8:     Class.new(Formula) do
// 9:       extend Test::Helper::Fixtures
// 10:
// 11:       def self.resource(*, **, &block)
// 12:         super do
// 13:           extend Test::Helper::Fixtures
// 14:
// 15:           define_singleton_method :patch do |*patch_args, **patch_kwargs, &patch_block|
// 16:             super(*patch_args, **patch_kwargs) do
// 17:               extend Test::Helper::Fixtures
// 18:
// 19:               instance_eval(&patch_block)
// 20:             end
// 21:           end
// 22:
// 23:           instance_eval(&block) if block
// 24:         end
// 25:       end
// 26:
// 27:       def self.patch(*, **, &block)
// 28:         super do
// 29:           extend Test::Helper::Fixtures
// 30:
// 31:           instance_eval(&block) if block
// 32:         end
// 33:       end
// 34:
// 35:       url "file://#{tarball_fixture("testball-0.1.tbz")}"
// 36:       sha256 tarball_fixture_sha256("testball-0.1.tbz")
// 37:     end
// 38:   end
// 39:
// 40:   def formula(name = "formula_name", path: Formulary.core_path(name), spec: :stable, alias_path: nil, tap: nil,
// 41:               &block)
// 42:     formula_subclass.class_eval(&block)
// 43:     formula_subclass.new(name, path, spec, alias_path:, tap:)
// 44:   end
// 45:
// 46:   matcher :be_patched do
// 47:     match do |formula|
// 48:       formula.brew do
// 49:         formula.patch
// 50:         s = File.read("libexec/NOOP")
// 51:         expect(s).not_to include("NOOP"), "libexec/NOOP was not patched as expected"
// 52:         expect(s).to include("ABCD"), "libexec/NOOP was not patched as expected"
// 53:       end
// 54:     end
// 55:   end
// 56:
// 57:   matcher :be_patched_with_homebrew_prefix do
// 58:     match do |formula|
// 59:       formula.brew do
// 60:         formula.patch
// 61:         s = File.read("libexec/NOOP")
// 62:         expect(s).not_to include("NOOP"), "libexec/NOOP was not patched as expected"
// 63:         expect(s).not_to include("@@HOMEBREW_PREFIX@@"), "libexec/NOOP was not patched as expected"
// 64:         expect(s).to include(HOMEBREW_PREFIX.to_s), "libexec/NOOP was not patched as expected"
// 65:       end
// 66:     end
// 67:   end
// 68:
// 69:   matcher :have_its_resource_patched do
// 70:     match do |formula|
// 71:       formula.brew do
// 72:         formula.resources.first.stage Pathname.pwd/"resource_dir"
// 73:         s = File.read("resource_dir/libexec/NOOP")
// 74:         expect(s).not_to include("NOOP"), "libexec/NOOP was not patched as expected"
// 75:         expect(s).to include("ABCD"), "libexec/NOOP was not patched as expected"
// 76:       end
// 77:     end
// 78:   end
// 79:
// 80:   matcher :be_sequentially_patched do
// 81:     match do |formula|
// 82:       formula.brew do
// 83:         formula.patch
// 84:         s = File.read("libexec/NOOP")
// 85:         expect(s).not_to include("NOOP"), "libexec/NOOP was not patched as expected"
// 86:         expect(s).not_to include("ABCD"), "libexec/NOOP was not patched as expected"
// 87:         expect(s).to include("1234"), "libexec/NOOP was not patched as expected"
// 88:       end
// 89:     end
// 90:   end
// 91:
// 92:   matcher :miss_apply do
// 93:     match do |formula|
// 94:       expect do
// 95:         formula.brew do
// 96:           formula.patch
// 97:         end
// 98:       end.to raise_error(MissingApplyError)
// 99:     end
// 100:   end
// 101:
// 102:   specify "single_patch_dsl" do
// 103:     expect(
// 104:       formula do
// 105:         T.bind(self, T.class_of(Formula))
// 106:         patch do
// 107:           url "file://#{patch_fixture("noop-a")}"
// 108:           sha256 patch_fixture_sha256("noop-a")
// 109:         end
// 110:       end,
// 111:     ).to be_patched
// 112:   end
// 113:
// 114:   specify "local_patch_dsl_resolves_path_loaded_formulae_from_formula_directory" do
// 115:     expect(
// 116:       formula(path: fixture("testball.rb")) do
// 117:         T.bind(self, T.class_of(Formula))
// 118:         patch do
// 119:           file "patches/noop-a.diff"
// 120:         end
// 121:       end,
// 122:     ).to be_patched
// 123:   end
// 124:
// 125:   specify "local_patch_dsl_with_directory" do
// 126:     expect(
// 127:       formula(path: fixture("testball.rb")) do
// 128:         T.bind(self, T.class_of(Formula))
// 129:         patch do
// 130:           file "patches/noop-b.diff"
// 131:           directory "libexec"
// 132:         end
// 133:       end,
// 134:     ).to be_patched
// 135:   end
// 136:
// 137:   specify "local_patch_dsl_with_strip" do
// 138:     expect(
// 139:       formula(path: fixture("testball.rb")) do
// 140:         T.bind(self, T.class_of(Formula))
// 141:         patch :p0 do
// 142:           file "patches/noop-b.diff"
// 143:         end
// 144:       end,
// 145:     ).to be_patched
// 146:   end
// 147:
// 148:   specify "local_patch_dsl_with_homebrew_prefix" do
// 149:     expect(
// 150:       formula(path: fixture("testball.rb")) do
// 151:         T.bind(self, T.class_of(Formula))
// 152:         patch do
// 153:           file "patches/noop-d.diff"
// 154:         end
// 155:       end,
// 156:     ).to be_patched_with_homebrew_prefix
// 157:   end
// 158:
// 159:   specify "local_patch_dsl_resolves_tapped_formulae_from_tap_root" do
// 160:     tap = Tap.fetch("homebrew", "local-patch-test")
// 161:     (tap.path/"Formula").mkpath
// 162:     (tap.path/"patches").mkpath
// 163:     FileUtils.cp patch_fixture("noop-a"), tap.path/"patches/noop-a.diff"
// 164:
// 165:     expect(
// 166:       formula(path: tap.path/"Formula/testball.rb", tap:) do
// 167:         T.bind(self, T.class_of(Formula))
// 168:         patch do
// 169:           file "patches/noop-a.diff"
// 170:         end
// 171:       end,
// 172:     ).to be_patched
// 173:   ensure
// 174:     FileUtils.rm_rf tap.path if tap
// 175:   end
// 176:
// 177:   specify "local_patch_dsl_missing_file_fail" do
// 178:     f = formula(path: fixture("testball.rb")) do
// 179:       T.bind(self, T.class_of(Formula))
// 180:       patch do
// 181:         file "patches/missing.diff"
// 182:       end
// 183:     end
// 184:
// 185:     expect { f.stable.patches.last.contents }
// 186:       .to raise_error(ArgumentError, "Patch file does not exist: patches/missing.diff")
// 187:   end
// 188:
// 189:   specify "local_patch_dsl_directory_fail" do
// 190:     f = formula(path: fixture("testball.rb")) do
// 191:       T.bind(self, T.class_of(Formula))
// 192:       patch do
// 193:         file "patches"
// 194:       end
// 195:     end
// 196:
// 197:     expect { f.stable.patches.last.contents }
// 198:       .to raise_error(ArgumentError, "Patch file must be a file: patches")
// 199:   end
// 200:
// 201:   specify "local_patch_dsl_rejects_symlink_escape" do
// 202:     mktmpdir do |tmpdir|
// 203:       repository = tmpdir/"repository"
// 204:       repository.mkpath
// 205:       FileUtils.cp patch_fixture("noop-a"), tmpdir/"outside.diff"
// 206:       FileUtils.ln_s tmpdir/"outside.diff", repository/"escape.diff"
// 207:
// 208:       f = formula(path: repository/"testball.rb") do
// 209:         T.bind(self, T.class_of(Formula))
// 210:         patch do
// 211:           file "escape.diff"
// 212:         end
// 213:       end
// 214:
// 215:       expect { f.stable.patches.last.contents }
// 216:         .to raise_error(ArgumentError, "Patch file must be within the formula repository.")
// 217:     end
// 218:   end
// 219:
// 220:   specify "single_patch_dsl_for_resource" do
// 221:     expect(
// 222:       formula do
// 223:         T.bind(self, T.class_of(Formula))
// 224:         resource "some_resource" do
// 225:           url "file://#{tarball_fixture("testball-0.1.tbz")}"
// 226:           sha256 tarball_fixture_sha256("testball-0.1.tbz")
// 227:
// 228:           patch do
// 229:             url "file://#{patch_fixture("noop-a")}"
// 230:             sha256 patch_fixture_sha256("noop-a")
// 231:           end
// 232:         end
// 233:       end,
// 234:     ).to have_its_resource_patched
// 235:   end
// 236:
// 237:   specify "single_patch_dsl_with_apply" do
// 238:     expect(
// 239:       formula do
// 240:         T.bind(self, T.class_of(Formula))
// 241:         patch do
// 242:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 243:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 244:           apply "noop-a.diff"
// 245:         end
// 246:       end,
// 247:     ).to be_patched
// 248:   end
// 249:
// 250:   specify "single_patch_dsl_with_sequential_apply" do
// 251:     expect(
// 252:       formula do
// 253:         T.bind(self, T.class_of(Formula))
// 254:         patch do
// 255:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 256:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 257:           apply "noop-a.diff", "noop-c.diff"
// 258:         end
// 259:       end,
// 260:     ).to be_sequentially_patched
// 261:   end
// 262:
// 263:   specify "single_patch_dsl_with_strip" do
// 264:     expect(
// 265:       formula do
// 266:         T.bind(self, T.class_of(Formula))
// 267:         patch :p1 do
// 268:           url "file://#{patch_fixture("noop-a")}"
// 269:           sha256 patch_fixture_sha256("noop-a")
// 270:         end
// 271:       end,
// 272:     ).to be_patched
// 273:   end
// 274:
// 275:   specify "single_patch_dsl_with_strip_with_apply" do
// 276:     external_patch = formula do
// 277:       T.bind(self, T.class_of(Formula))
// 278:       patch :p1 do
// 279:         url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 280:         sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 281:         apply "noop-a.diff"
// 282:       end
// 283:     end.stable.patches.last
// 284:
// 285:     expect(external_patch).to have_attributes(strip: :p1, patch_files: ["noop-a.diff"])
// 286:     external_patch.fetch
// 287:     external_patch.resource.unpack do
// 288:       expect(Pathname.pwd/external_patch.patch_files.fetch(0)).to be_a_file
// 289:     end
// 290:   end
// 291:
// 292:   specify "single_patch_dsl_with_incorrect_strip" do
// 293:     expect do
// 294:       f = formula do
// 295:         T.bind(self, T.class_of(Formula))
// 296:         patch :p0 do
// 297:           url "file://#{patch_fixture("noop-a")}"
// 298:           sha256 patch_fixture_sha256("noop-a")
// 299:         end
// 300:       end
// 301:
// 302:       f.brew { |formula, _staging| formula.patch }
// 303:     end.to raise_error(BuildError)
// 304:   end
// 305:
// 306:   specify "single_patch_dsl_with_incorrect_strip_with_apply" do
// 307:     expect do
// 308:       f = formula do
// 309:         T.bind(self, T.class_of(Formula))
// 310:         patch :p0 do
// 311:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 312:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 313:           apply "noop-a.diff"
// 314:         end
// 315:       end
// 316:
// 317:       f.brew { |formula, _staging| formula.patch }
// 318:     end.to raise_error(BuildError)
// 319:   end
// 320:
// 321:   specify "patch_p0_dsl" do
// 322:     expect(
// 323:       formula do
// 324:         T.bind(self, T.class_of(Formula))
// 325:         patch :p0 do
// 326:           url "file://#{patch_fixture("noop-b")}"
// 327:           sha256 patch_fixture_sha256("noop-b")
// 328:         end
// 329:       end,
// 330:     ).to be_patched
// 331:   end
// 332:
// 333:   specify "patch_p0_dsl_with_apply" do
// 334:     expect(
// 335:       formula do
// 336:         T.bind(self, T.class_of(Formula))
// 337:         patch :p0 do
// 338:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 339:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 340:           apply "noop-b.diff"
// 341:         end
// 342:       end,
// 343:     ).to be_patched
// 344:   end
// 345:
// 346:   specify "patch_string" do
// 347:     expect(
// 348:       formula do
// 349:         T.bind(self, T.class_of(Formula))
// 350:         patch File.read(patch_fixture("noop-a"))
// 351:       end,
// 352:     ).to be_patched
// 353:   end
// 354:
// 355:   specify "patch_string_with_strip" do
// 356:     expect(
// 357:       formula do
// 358:         T.bind(self, T.class_of(Formula))
// 359:         patch :p0, File.read(patch_fixture("noop-b"))
// 360:       end,
// 361:     ).to be_patched
// 362:   end
// 363:
// 364:   specify "single_patch_dsl_missing_apply_fail" do
// 365:     expect(
// 366:       formula do
// 367:         T.bind(self, T.class_of(Formula))
// 368:         patch do
// 369:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 370:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 371:         end
// 372:       end,
// 373:     ).to miss_apply
// 374:   end
// 375:
// 376:   specify "single_patch_dsl_with_apply_enoent_fail" do
// 377:     expect do
// 378:       f = formula do
// 379:         T.bind(self, T.class_of(Formula))
// 380:         patch do
// 381:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 382:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 383:           apply "patches/noop-a.diff"
// 384:         end
// 385:       end
// 386:
// 387:       f.brew { |formula, _staging| formula.patch }
// 388:     end.to raise_error(Errno::ENOENT)
// 389:   end
// 390:
// 391:   specify "patch_dsl_with_homebrew_prefix" do
// 392:     expect(
// 393:       formula do
// 394:         T.bind(self, T.class_of(Formula))
// 395:         patch do
// 396:           url "file://#{patch_fixture("noop-d")}"
// 397:           sha256 patch_fixture_sha256("noop-d")
// 398:         end
// 399:       end,
// 400:     ).to be_patched_with_homebrew_prefix
// 401:   end
// 402: end
