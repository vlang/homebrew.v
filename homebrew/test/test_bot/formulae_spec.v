module test_bot

import brew_runtime

// Translated from Homebrew/brew `test/test_bot/formulae_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "requires exact matches when either name is tap-qualified", :aggregate_failures do` at line 8.
pub fn ruby_formulae_spec_l8_d1_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires', ...args)
}

// Ruby it `it "writes a warning annotation for the new recursive dependency impact" do` at line 31.
pub fn ruby_formulae_spec_l31_d2_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby method `write_platform_bottle_formula(formula_path, tag, sha256)` at line 105.
pub fn ruby_formulae_spec_l105_d3_write_platform_bottle_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_platform_bottle_formula', ...args)
}

// Ruby method `write_bottle_json(tap_path, tag, sha256, cellar: "any_skip_relocation")` at line 129.
pub fn ruby_formulae_spec_l129_d4_write_bottle_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_bottle_json', ...args)
}

// Ruby method `all_bottle_formula(formula_path)` at line 145.
pub fn ruby_formulae_spec_l145_d5_all_bottle_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('all_bottle_formula', ...args)
}

// Ruby method `formulae_test_bot(tap_path, tmpdir)` at line 157.
pub fn ruby_formulae_spec_l157_d6_formulae_test_bot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae_test_bot', ...args)
}

// Ruby it `it "writes a warning annotation for a platform-specific bottle replacing an all bottle" do` at line 168.
pub fn ruby_formulae_spec_l168_d7_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "does not write a warning annotation when local JSON already has an all bottle" do` at line 196.
pub fn ruby_formulae_spec_l196_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not write a warning annotation for a single platform-specific bottle" do` at line 217.
pub fn ruby_formulae_spec_l217_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "writes a warning annotation when matching checksums have different cellars" do` at line 236.
pub fn ruby_formulae_spec_l236_d10_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "does not write a warning annotation when platform bottles can become an all bottle" do` at line 257.
pub fn ruby_formulae_spec_l257_d11_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "returns false (not nil) when tap is nil" do` at line 279.
pub fn ruby_formulae_spec_l279_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false (not nil) when testing portable ruby" do` at line 300.
pub fn ruby_formulae_spec_l300_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "restores bottled config with InstallRenamed handling" do` at line 322.
pub fn ruby_formulae_spec_l322_d14_restores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('restores', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot"
// 5:
// 6: RSpec.describe Homebrew::TestBot::Formulae do
// 7:   describe "#dependency_name_match?" do
// 8:     it "requires exact matches when either name is tap-qualified", :aggregate_failures do
// 9:       Dir.mktmpdir do |tmpdir|
// 10:         output_paths = {
// 11:           bottle:                     Pathname.new("#{tmpdir}/bottle.txt"),
// 12:           linkage:                    Pathname.new("#{tmpdir}/linkage.txt"),
// 13:           skipped_or_failed_formulae: Pathname.new("#{tmpdir}/skipped.txt"),
// 14:         }
// 15:         formulae = described_class.new(
// 16:           tap: nil, git: "git", dry_run: true, fail_fast: false, verbose: false,
// 17:           output_paths:
// 18:         )
// 19:
// 20:         expect(formulae.dependency_name_match?(Dependency.new("foo"), "foo")).to be(true)
// 21:         expect(formulae.dependency_name_match?(Dependency.new("homebrew/core/foo"), "homebrew/core/foo"))
// 22:           .to be(true)
// 23:         expect(formulae.dependency_name_match?(Dependency.new("homebrew/core/foo"), "foo")).to be(false)
// 24:         expect(formulae.dependency_name_match?(Dependency.new("homebrew/core/foo"), "user/tap/foo"))
// 25:           .to be(false)
// 26:       end
// 27:     end
// 28:   end
// 29:
// 30:   describe "#annotate_added_dependencies" do
// 31:     it "writes a warning annotation for the new recursive dependency impact" do
// 32:       formula = formula("foo") do
// 33:         T.bind(self, T.class_of(Formula))
// 34:         url "foo-1.0"
// 35:         depends_on "existing"
// 36:         depends_on "bar"
// 37:       end
// 38:       existing = formula("existing") do
// 39:         T.bind(self, T.class_of(Formula))
// 40:         url "existing-1.0"
// 41:       end
// 42:       bar = formula("bar") do
// 43:         T.bind(self, T.class_of(Formula))
// 44:         url "bar-1.0"
// 45:         depends_on "not-runtime" => :build
// 46:         depends_on "existing"
// 47:         depends_on "baz"
// 48:       end
// 49:       baz = formula("baz") do
// 50:         T.bind(self, T.class_of(Formula))
// 51:         url "baz-1.0"
// 52:         depends_on "not-runtime" => :test
// 53:         depends_on "recommended" => :recommended
// 54:       end
// 55:       recommended = formula("recommended") do
// 56:         T.bind(self, T.class_of(Formula))
// 57:         url "recommended-1.0"
// 58:         depends_on "not-runtime" => :optional
// 59:       end
// 60:       not_runtime = formula("not-runtime") do
// 61:         T.bind(self, T.class_of(Formula))
// 62:         url "not-runtime-1.0"
// 63:         depends_on "other"
// 64:       end
// 65:       other = formula("other") do
// 66:         T.bind(self, T.class_of(Formula))
// 67:         url "other-1.0"
// 68:       end
// 69:
// 70:       [existing, bar, baz, recommended, not_runtime, other].each { |f| stub_formula_loader f }
// 71:       [[bar, 1_000_000], [baz, 500_000], [recommended, 400_000]].each do |f, size|
// 72:         allow(f).to receive(:bottle_for_tag)
// 73:           .and_return(instance_double(Bottle, fetch_tab: nil, installed_size: size))
// 74:       end
// 75:       allow(Utils).to receive(:safe_popen_read).and_return <<~DIFF
// 76:         @@ -2,0 +7,1 @@
// 77:         +  depends_on "bar"
// 78:       DIFF
// 79:
// 80:       Dir.mktmpdir do |tmpdir|
// 81:         output_paths = {
// 82:           bottle:                     Pathname.new("#{tmpdir}/bottle.txt"),
// 83:           linkage:                    Pathname.new("#{tmpdir}/linkage.txt"),
// 84:           skipped_or_failed_formulae: Pathname.new("#{tmpdir}/skipped.txt"),
// 85:         }
// 86:         formulae = described_class.new(
// 87:           tap: nil, git: "git", dry_run: true, fail_fast: false, verbose: false,
// 88:           output_paths:
// 89:         )
// 90:
// 91:         with_env(GITHUB_ACTIONS: "true") do
// 92:           expect { formulae.annotate_added_dependencies(formula) }
// 93:             .to output(
// 94:               "::warning file=#{formula.path.relative_path_from(CoreTap.instance.path)},line=7," \
// 95:               "title=foo: new dependency impact::Adding `bar` adds 3 new recursive dependencies " \
// 96:               "on #{Utils::Bottles.tag} (1.9MB).\n",
// 97:             ).to_stdout
// 98:         end
// 99:       end
// 100:     end
// 101:   end
// 102:
// 103:   describe "#annotate_missing_all_bottle" do
// 104:     sig { params(formula_path: Pathname, tag: Utils::Bottles::Tag, sha256: String).void }
// 105:     def write_platform_bottle_formula(formula_path, tag, sha256)
// 106:       formula_path.dirname.mkpath
// 107:       formula_path.write <<~RUBY
// 108:         class Foo < Formula
// 109:           desc "Foo"
// 110:           homepage "https://example.com"
// 111:           url "foo-1.0"
// 112:           sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 113:
// 114:           bottle do
// 115:             sha256 cellar: :any_skip_relocation, #{tag.to_sym}: "#{sha256}"
// 116:           end
// 117:         end
// 118:       RUBY
// 119:     end
// 120:
// 121:     sig {
// 122:       params(
// 123:         tap_path: Pathname,
// 124:         tag:      T.any(String, Utils::Bottles::Tag),
// 125:         sha256:   String,
// 126:         cellar:   String,
// 127:       ).void
// 128:     }
// 129:     def write_bottle_json(tap_path, tag, sha256, cellar: "any_skip_relocation")
// 130:       (tap_path/"foo--1.0.#{tag}.bottle.json").write JSON.generate(
// 131:         "foo" => {
// 132:           "bottle" => {
// 133:             "cellar" => cellar,
// 134:             "tags"   => {
// 135:               tag.to_s => {
// 136:                 "sha256" => sha256,
// 137:               },
// 138:             },
// 139:           },
// 140:         },
// 141:       )
// 142:     end
// 143:
// 144:     sig { params(formula_path: Pathname).returns(Formula) }
// 145:     def all_bottle_formula(formula_path)
// 146:       formula("foo", path: formula_path) do
// 147:         T.bind(self, T.class_of(Formula))
// 148:         url "foo-1.0"
// 149:         bottle do
// 150:           sha256 cellar: :any_skip_relocation,
// 151:                  all:    "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
// 152:         end
// 153:       end
// 154:     end
// 155:
// 156:     sig { params(tap_path: Pathname, tmpdir: String).returns(Homebrew::TestBot::Formulae) }
// 157:     def formulae_test_bot(tap_path, tmpdir)
// 158:       described_class.new(
// 159:         tap: instance_double(Tap, path: tap_path), git: "git", dry_run: true, fail_fast: false, verbose: false,
// 160:         output_paths: {
// 161:           bottle:                     Pathname.new("#{tmpdir}/bottle.txt"),
// 162:           linkage:                    Pathname.new("#{tmpdir}/linkage.txt"),
// 163:           skipped_or_failed_formulae: Pathname.new("#{tmpdir}/skipped.txt"),
// 164:         }
// 165:       )
// 166:     end
// 167:
// 168:     it "writes a warning annotation for a platform-specific bottle replacing an all bottle" do
// 169:       Dir.mktmpdir do |tmpdir|
// 170:         tag = Utils::Bottles.tag
// 171:         sha256 = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 172:         other_tag = (tag.to_s == "arm64_tahoe") ? "tahoe" : "arm64_tahoe"
// 173:         other_sha256 = "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
// 174:         tap_path = Pathname(tmpdir)
// 175:         formula_path = tap_path/"Formula/foo.rb"
// 176:         write_platform_bottle_formula(formula_path, tag, sha256)
// 177:         write_bottle_json(tap_path, tag, sha256)
// 178:         write_bottle_json(tap_path, other_tag, other_sha256)
// 179:
// 180:         old_formula = all_bottle_formula(formula_path)
// 181:         formulae = formulae_test_bot(tap_path, tmpdir)
// 182:
// 183:         with_env(GITHUB_ACTIONS: "true", GITHUB_WORKSPACE: tap_path.to_s) do
// 184:           expect { formulae.annotate_missing_all_bottle(old_formula, bottle_dir: tap_path) }
// 185:             .to output(
// 186:               "::warning file=Formula/foo.rb,line=8,title=foo: missing :all bottle::" \
// 187:               "This formula had an `:all` bottle but the #{tag} test-bot bottle is platform-specific " \
// 188:               "(cellar `any_skip_relocation`, sha256 `#{sha256}`). " \
// 189:               "If the final bottle merge cannot create a new `:all` bottle, expect publishing without one anyway; " \
// 190:               "this is for information only and should not block merge.\n",
// 191:             ).to_stdout
// 192:         end
// 193:       end
// 194:     end
// 195:
// 196:     it "does not write a warning annotation when local JSON already has an all bottle" do
// 197:       Dir.mktmpdir do |tmpdir|
// 198:         tag = Utils::Bottles.tag
// 199:         sha256 = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 200:         all_sha256 = "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
// 201:         tap_path = Pathname(tmpdir)
// 202:         formula_path = tap_path/"Formula/foo.rb"
// 203:         write_platform_bottle_formula(formula_path, tag, sha256)
// 204:         write_bottle_json(tap_path, tag, sha256)
// 205:         write_bottle_json(tap_path, "all", all_sha256)
// 206:
// 207:         old_formula = all_bottle_formula(formula_path)
// 208:         formulae = formulae_test_bot(tap_path, tmpdir)
// 209:
// 210:         with_env(GITHUB_ACTIONS: "true", GITHUB_WORKSPACE: tap_path.to_s) do
// 211:           expect { formulae.annotate_missing_all_bottle(old_formula, bottle_dir: tap_path) }
// 212:             .not_to output.to_stdout
// 213:         end
// 214:       end
// 215:     end
// 216:
// 217:     it "does not write a warning annotation for a single platform-specific bottle" do
// 218:       Dir.mktmpdir do |tmpdir|
// 219:         tag = Utils::Bottles.tag
// 220:         sha256 = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 221:         tap_path = Pathname(tmpdir)
// 222:         formula_path = tap_path/"Formula/foo.rb"
// 223:         write_platform_bottle_formula(formula_path, tag, sha256)
// 224:         write_bottle_json(tap_path, tag, sha256)
// 225:
// 226:         old_formula = all_bottle_formula(formula_path)
// 227:         formulae = formulae_test_bot(tap_path, tmpdir)
// 228:
// 229:         with_env(GITHUB_ACTIONS: "true", GITHUB_WORKSPACE: tap_path.to_s) do
// 230:           expect { formulae.annotate_missing_all_bottle(old_formula, bottle_dir: tap_path) }
// 231:             .not_to output.to_stdout
// 232:         end
// 233:       end
// 234:     end
// 235:
// 236:     it "writes a warning annotation when matching checksums have different cellars" do
// 237:       Dir.mktmpdir do |tmpdir|
// 238:         tag = Utils::Bottles.tag
// 239:         other_tag = (tag.to_s == "arm64_tahoe") ? "tahoe" : "arm64_tahoe"
// 240:         sha256 = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 241:         tap_path = Pathname(tmpdir)
// 242:         formula_path = tap_path/"Formula/foo.rb"
// 243:         write_platform_bottle_formula(formula_path, tag, sha256)
// 244:         write_bottle_json(tap_path, tag, sha256)
// 245:         write_bottle_json(tap_path, other_tag, sha256, cellar: "any")
// 246:
// 247:         old_formula = all_bottle_formula(formula_path)
// 248:         formulae = formulae_test_bot(tap_path, tmpdir)
// 249:
// 250:         with_env(GITHUB_ACTIONS: "true", GITHUB_WORKSPACE: tap_path.to_s) do
// 251:           expect { formulae.annotate_missing_all_bottle(old_formula, bottle_dir: tap_path) }
// 252:             .to output(/title=foo: missing :all bottle::.*sha256 `#{sha256}`/).to_stdout
// 253:         end
// 254:       end
// 255:     end
// 256:
// 257:     it "does not write a warning annotation when platform bottles can become an all bottle" do
// 258:       Dir.mktmpdir do |tmpdir|
// 259:         tag = Utils::Bottles.tag
// 260:         other_tag = (tag.to_s == "arm64_tahoe") ? "tahoe" : "arm64_tahoe"
// 261:         sha256 = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 262:         tap_path = Pathname(tmpdir)
// 263:         formula_path = tap_path/"Formula/foo.rb"
// 264:         write_platform_bottle_formula(formula_path, tag, sha256)
// 265:         [tag.to_s, other_tag].each { |bottle_tag| write_bottle_json(tap_path, bottle_tag, sha256) }
// 266:
// 267:         old_formula = all_bottle_formula(formula_path)
// 268:         formulae = formulae_test_bot(tap_path, tmpdir)
// 269:
// 270:         with_env(GITHUB_ACTIONS: "true", GITHUB_WORKSPACE: tap_path.to_s) do
// 271:           expect { formulae.annotate_missing_all_bottle(old_formula, bottle_dir: tap_path) }
// 272:             .not_to output.to_stdout
// 273:         end
// 274:       end
// 275:     end
// 276:   end
// 277:
// 278:   describe "#testing_portable_ruby?" do
// 279:     it "returns false (not nil) when tap is nil" do
// 280:       # Regression test: without `!!`, tap&.core_tap? returns nil when tap is nil,
// 281:       # and `nil && ...` evaluates to nil, violating the T::Boolean return type.
// 282:       Dir.mktmpdir do |tmpdir|
// 283:         output_paths = {
// 284:           bottle:                     Pathname.new("#{tmpdir}/bottle.txt"),
// 285:           linkage:                    Pathname.new("#{tmpdir}/linkage.txt"),
// 286:           skipped_or_failed_formulae: Pathname.new("#{tmpdir}/skipped.txt"),
// 287:         }
// 288:         formulae = described_class.new(
// 289:           tap: nil, git: "git", dry_run: true, fail_fast: false, verbose: false,
// 290:           output_paths:
// 291:         )
// 292:
// 293:         result = formulae.testing_portable_ruby?
// 294:         expect(result).to be(false)
// 295:       end
// 296:     end
// 297:   end
// 298:
// 299:   describe "#verify_local_bottles" do
// 300:     it "returns false (not nil) when testing portable ruby" do
// 301:       # Regression test: the early return for portable ruby must be `return false`,
// 302:       # not bare `return` (which returns nil), to satisfy the T::Boolean return type.
// 303:       Dir.mktmpdir do |tmpdir|
// 304:         output_paths = {
// 305:           bottle:                     Pathname.new("#{tmpdir}/bottle.txt"),
// 306:           linkage:                    Pathname.new("#{tmpdir}/linkage.txt"),
// 307:           skipped_or_failed_formulae: Pathname.new("#{tmpdir}/skipped.txt"),
// 308:         }
// 309:         formulae = described_class.new(
// 310:           tap: CoreTap.instance, git: "git", dry_run: true, fail_fast: false, verbose: false,
// 311:           output_paths:
// 312:         )
// 313:         formulae.testing_formulae = ["portable-ruby"]
// 314:
// 315:         result = formulae.verify_local_bottles
// 316:         expect(result).to be(false)
// 317:       end
// 318:     end
// 319:   end
// 320:
// 321:   describe "#cleanup_bottle_etc_var" do
// 322:     it "restores bottled config with InstallRenamed handling" do
// 323:       Dir.mktmpdir do |tmpdir|
// 324:         formula_class = Class.new(Formula)
// 325:         formula_class.url "foo-2.0"
// 326:         formula_class.version "2.0"
// 327:         f = formula_class.new("test-bot-config", Formulary.core_path("test-bot-config"), :stable)
// 328:         config_file = HOMEBREW_PREFIX/"etc/test-bot-config.conf"
// 329:         default_config_file = Pathname.new("#{config_file}.default")
// 330:         old_default_file = f.rack/"1.0/.bottle/etc/test-bot-config.conf"
// 331:         new_default_file = f.bottle_prefix/"etc/test-bot-config.conf"
// 332:
// 333:         begin
// 334:           FileUtils.rm_rf f.rack
// 335:           FileUtils.rm_f config_file
// 336:           FileUtils.rm_f default_config_file
// 337:
// 338:           old_default_file.dirname.mkpath
// 339:           old_default_file.write "old\n"
// 340:           new_default_file.dirname.mkpath
// 341:           new_default_file.write "new\n"
// 342:           config_file.dirname.mkpath
// 343:           config_file.write "old\n"
// 344:
// 345:           described_class.new(
// 346:             tap: nil, git: "git", dry_run: true, fail_fast: false, verbose: false,
// 347:             output_paths: {
// 348:               bottle:                     Pathname.new("#{tmpdir}/bottle.txt"),
// 349:               linkage:                    Pathname.new("#{tmpdir}/linkage.txt"),
// 350:               skipped_or_failed_formulae: Pathname.new("#{tmpdir}/skipped.txt"),
// 351:             }
// 352:           ).cleanup_bottle_etc_var(f)
// 353:
// 354:           expect([config_file.read, default_config_file.exist?]).to eq(["new\n", false])
// 355:         ensure
// 356:           FileUtils.rm_rf f.rack
// 357:           FileUtils.rm_f config_file
// 358:           FileUtils.rm_f default_config_file
// 359:         end
// 360:       end
// 361:     end
// 362:   end
// 363: end
