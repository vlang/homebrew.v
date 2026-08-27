module dsl

import brew_runtime

// Translated from Homebrew/brew `test/cask/dsl/version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:version) { described_class.new(raw_version) }` at line 5.
pub fn ruby_version_spec_l5_d1_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby let `let(input_name.to_sym) { input_value }` at line 10.
pub fn ruby_version_spec_l10_d2_let_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('let_dynamic', ...args)
}

// Ruby it `it { is_expected.to eq expected_output }` at line 12.
pub fn ruby_version_spec_l12_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:raw_version) { "1.2.3" }` at line 18.
pub fn ruby_version_spec_l18_d4_raw_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raw_version', ...args)
}

// Ruby let `let(:other) { nil }` at line 21.
pub fn ruby_version_spec_l21_d5_other(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('other', ...args)
}

// Ruby it `it { is_expected.to be false }` at line 23.
pub fn ruby_version_spec_l23_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:other) { "1.2.3" }` at line 28.
pub fn ruby_version_spec_l28_d7_other(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('other', ...args)
}

// Ruby it `it { is_expected.to be true }` at line 30.
pub fn ruby_version_spec_l30_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:other) { "1.2.3.4" }` at line 34.
pub fn ruby_version_spec_l34_d9_other(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('other', ...args)
}

// Ruby it `it { is_expected.to be false }` at line 36.
pub fn ruby_version_spec_l36_d10_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:other) { described_class.new("1.2.3") }` at line 42.
pub fn ruby_version_spec_l42_d11_other(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('other', ...args)
}

// Ruby it `it { is_expected.to be true }` at line 44.
pub fn ruby_version_spec_l44_d12_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:other) { described_class.new("1.2.3.4") }` at line 48.
pub fn ruby_version_spec_l48_d13_other(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('other', ...args)
}

// Ruby it `it { is_expected.to be false }` at line 50.
pub fn ruby_version_spec_l50_d14_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it "raises an error when the version contains a slash" do` at line 56.
pub fn ruby_version_spec_l56_d15_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby subject `subject { version == other }` at line 64.
pub fn ruby_version_spec_l64_d16_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subject_dynamic', ...args)
}

// Ruby subject `subject { version.eql?(other) }` at line 70.
pub fn ruby_version_spec_l70_d17_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subject_dynamic', ...args)
}

// Ruby subject `subject { version.public_send(method) }` at line 76.
pub fn ruby_version_spec_l76_d18_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subject_dynamic', ...args)
}

// Ruby subject `subject { version.csv }` at line 144.
pub fn ruby_version_spec_l144_d19_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subject_dynamic', ...args)
}

// Ruby it `it "detects` at line 354.
pub fn ruby_version_spec_l354_d20_detects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detects', ...args)
}

// Ruby it `it "does not detect` at line 364.
pub fn ruby_version_spec_l364_d21_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::DSL::Version, :cask do
// 5:   let(:version) { described_class.new(raw_version) }
// 6:
// 7:   shared_examples "expectations hash" do |input_name, expectations|
// 8:     test_each(expectations) do |(input_value, expected_output)|
// 9:       context "when #{input_name} is #{input_value.inspect}" do
// 10:         let(input_name.to_sym) { input_value }
// 11:
// 12:         it { is_expected.to eq expected_output }
// 13:       end
// 14:     end
// 15:   end
// 16:
// 17:   shared_examples "version equality" do
// 18:     let(:raw_version) { "1.2.3" }
// 19:
// 20:     context "when other is nil" do
// 21:       let(:other) { nil }
// 22:
// 23:       it { is_expected.to be false }
// 24:     end
// 25:
// 26:     context "when other is a String" do
// 27:       context "when other == self.raw_version" do
// 28:         let(:other) { "1.2.3" }
// 29:
// 30:         it { is_expected.to be true }
// 31:       end
// 32:
// 33:       context "when other != self.raw_version" do
// 34:         let(:other) { "1.2.3.4" }
// 35:
// 36:         it { is_expected.to be false }
// 37:       end
// 38:     end
// 39:
// 40:     context "when other is a #{described_class}" do
// 41:       context "when other.raw_version == self.raw_version" do
// 42:         let(:other) { described_class.new("1.2.3") }
// 43:
// 44:         it { is_expected.to be true }
// 45:       end
// 46:
// 47:       context "when other.raw_version != self.raw_version" do
// 48:         let(:other) { described_class.new("1.2.3.4") }
// 49:
// 50:         it { is_expected.to be false }
// 51:       end
// 52:     end
// 53:   end
// 54:
// 55:   describe "#initialize" do
// 56:     it "raises an error when the version contains a slash" do
// 57:       expect do
// 58:         described_class.new("0.1,../../directory/traversal")
// 59:       end.to raise_error(TypeError, %r{invalid characters: /})
// 60:     end
// 61:   end
// 62:
// 63:   describe "#==" do
// 64:     subject { version == other }
// 65:
// 66:     include_examples "version equality"
// 67:   end
// 68:
// 69:   describe "#eql?" do
// 70:     subject { version.eql?(other) }
// 71:
// 72:     include_examples "version equality"
// 73:   end
// 74:
// 75:   shared_examples "version expectations hash" do |method, hash|
// 76:     subject { version.public_send(method) }
// 77:
// 78:     include_examples "expectations hash", :raw_version,
// 79:                      { :latest  => "latest",
// 80:                        "latest" => "latest",
// 81:                        ""       => "",
// 82:                        nil      => "" }.merge(hash)
// 83:   end
// 84:
// 85:   describe "#latest?" do
// 86:     include_examples "version expectations hash", :latest?,
// 87:                      :latest  => true,
// 88:                      "latest" => true,
// 89:                      ""       => false,
// 90:                      nil      => false,
// 91:                      "1.2.3"  => false
// 92:   end
// 93:
// 94:   describe "string manipulation helpers" do
// 95:     describe "#major" do
// 96:       include_examples "version expectations hash", :major,
// 97:                        "1"           => "1",
// 98:                        "1.2"         => "1",
// 99:                        "1.2.3"       => "1",
// 100:                        "1.2.3-4,5:6" => "1"
// 101:     end
// 102:
// 103:     describe "#minor" do
// 104:       include_examples "version expectations hash", :minor,
// 105:                        "1"           => "",
// 106:                        "1.2"         => "2",
// 107:                        "1.2.3"       => "2",
// 108:                        "1.2.3-4,5:6" => "2"
// 109:     end
// 110:
// 111:     describe "#patch" do
// 112:       include_examples "version expectations hash", :patch,
// 113:                        "1"           => "",
// 114:                        "1.2"         => "",
// 115:                        "1.2.3"       => "3",
// 116:                        "1.2.3-4,5:6" => "3-4"
// 117:     end
// 118:
// 119:     describe "#major_minor" do
// 120:       include_examples "version expectations hash", :major_minor,
// 121:                        "1"           => "1",
// 122:                        "1.2"         => "1.2",
// 123:                        "1.2.3"       => "1.2",
// 124:                        "1.2.3-4,5:6" => "1.2"
// 125:     end
// 126:
// 127:     describe "#major_minor_patch" do
// 128:       include_examples "version expectations hash", :major_minor_patch,
// 129:                        "1"           => "1",
// 130:                        "1.2"         => "1.2",
// 131:                        "1.2.3"       => "1.2.3",
// 132:                        "1.2.3-4,5:6" => "1.2.3-4"
// 133:     end
// 134:
// 135:     describe "#minor_patch" do
// 136:       include_examples "version expectations hash", :minor_patch,
// 137:                        "1"           => "",
// 138:                        "1.2"         => "2",
// 139:                        "1.2.3"       => "2.3",
// 140:                        "1.2.3-4,5:6" => "2.3-4"
// 141:     end
// 142:
// 143:     describe "#csv" do
// 144:       subject { version.csv }
// 145:
// 146:       include_examples "expectations hash", :raw_version,
// 147:                        :latest     => ["latest"],
// 148:                        "latest"    => ["latest"],
// 149:                        ""          => [],
// 150:                        nil         => [],
// 151:                        "1.2.3"     => ["1.2.3"],
// 152:                        "1.2.3,"    => ["1.2.3"],
// 153:                        ",abc"      => ["", "abc"],
// 154:                        "1.2.3,abc" => ["1.2.3", "abc"]
// 155:     end
// 156:
// 157:     describe "#before_comma" do
// 158:       include_examples "version expectations hash", :before_comma,
// 159:                        "1.2.3"     => "1.2.3",
// 160:                        "1.2.3,"    => "1.2.3",
// 161:                        ",abc"      => "",
// 162:                        "1.2.3,abc" => "1.2.3"
// 163:     end
// 164:
// 165:     describe "#after_comma" do
// 166:       include_examples "version expectations hash", :after_comma,
// 167:                        "1.2.3"     => "",
// 168:                        "1.2.3,"    => "",
// 169:                        ",abc"      => "abc",
// 170:                        "1.2.3,abc" => "abc"
// 171:     end
// 172:
// 173:     describe "#dots_to_hyphens" do
// 174:       include_examples "version expectations hash", :dots_to_hyphens,
// 175:                        "1.2.3_4-5" => "1-2-3_4-5"
// 176:     end
// 177:
// 178:     describe "#dots_to_underscores" do
// 179:       include_examples "version expectations hash", :dots_to_underscores,
// 180:                        "1.2.3_4-5" => "1_2_3_4-5"
// 181:     end
// 182:
// 183:     describe "#hyphens_to_dots" do
// 184:       include_examples "version expectations hash", :hyphens_to_dots,
// 185:                        "1.2.3_4-5" => "1.2.3_4.5"
// 186:     end
// 187:
// 188:     describe "#hyphens_to_underscores" do
// 189:       include_examples "version expectations hash", :hyphens_to_underscores,
// 190:                        "1.2.3_4-5" => "1.2.3_4_5"
// 191:     end
// 192:
// 193:     describe "#underscores_to_dots" do
// 194:       include_examples "version expectations hash", :underscores_to_dots,
// 195:                        "1.2.3_4-5" => "1.2.3.4-5"
// 196:     end
// 197:
// 198:     describe "#underscores_to_hyphens" do
// 199:       include_examples "version expectations hash", :underscores_to_hyphens,
// 200:                        "1.2.3_4-5" => "1.2.3-4-5"
// 201:     end
// 202:
// 203:     describe "#no_dots" do
// 204:       include_examples "version expectations hash", :no_dots,
// 205:                        "1.2.3_4-5" => "123_4-5"
// 206:     end
// 207:
// 208:     describe "#no_hyphens" do
// 209:       include_examples "version expectations hash", :no_hyphens,
// 210:                        "1.2.3_4-5" => "1.2.3_45"
// 211:     end
// 212:
// 213:     describe "#no_underscores" do
// 214:       include_examples "version expectations hash", :no_underscores,
// 215:                        "1.2.3_4-5" => "1.2.34-5"
// 216:     end
// 217:
// 218:     describe "#no_dividers" do
// 219:       include_examples "version expectations hash", :no_dividers,
// 220:                        "1.2.3_4-5" => "12345"
// 221:     end
// 222:   end
// 223:
// 224:   describe "#unstable?" do
// 225:     test_each([
// 226:       "0.0.11-beta.7",
// 227:       "0.0.23b-alpha",
// 228:       "0.1-beta",
// 229:       "0.1.0-beta.6",
// 230:       "0.10.0b",
// 231:       "0.2.0-alpha",
// 232:       "0.2.0-beta",
// 233:       "0.2.4-beta.9",
// 234:       "0.2.588-dev",
// 235:       "0.3-beta",
// 236:       "0.3.0-SNAPSHOT-624369f",
// 237:       "0.4.1-alpha",
// 238:       "0.4.9-alpha",
// 239:       "0.5.3,beta",
// 240:       "0.6-alpha1,a",
// 241:       "0.7.1b2",
// 242:       "0.7a19",
// 243:       "0.8.0b8",
// 244:       "0.8b3",
// 245:       "0.9.10-alpha",
// 246:       "0.9.3b",
// 247:       "08b2",
// 248:       "1.0-b9",
// 249:       "1.0-beta",
// 250:       "1.0-beta-7.0",
// 251:       "1.0-beta.3",
// 252:       "1.0.0-alpha.5",
// 253:       "1.0.0-alpha5",
// 254:       "1.0.0-beta-2.2,20160421",
// 255:       "1.0.0-beta.16",
// 256:       "1.0.0-rc",
// 257:       "1.0.6b1",
// 258:       "1.0.beta-43",
// 259:       "1.004,alpha",
// 260:       "1.0b10",
// 261:       "1.0b12",
// 262:       "1.1-alpha-20181201a",
// 263:       "1.1.16-beta-rc2",
// 264:       "1.1.58.BETA",
// 265:       "1.10.1,b87:8941241e",
// 266:       "1.13.0-beta.7",
// 267:       "1.13beta8",
// 268:       "1.15.0.b20190302001",
// 269:       "1.16.2-Beta",
// 270:       "1.1b23",
// 271:       "1.2.0,b200",
// 272:       "1.2.1pre1",
// 273:       "1.2.2-beta.2845",
// 274:       "1.20.0-beta.3",
// 275:       "1.2b24",
// 276:       "1.3.0,b102",
// 277:       "1.3.7a",
// 278:       "1.36.0-beta0",
// 279:       "1.4.3a",
// 280:       "1.6.0_65-b14-468",
// 281:       "1.6.4-beta0-4e46f007",
// 282:       "1.7,b566",
// 283:       "1.7b5",
// 284:       "1.9.3a",
// 285:       "1.9.3b8",
// 286:       "17.03.1-beta",
// 287:       "18.0-Leia_rc4",
// 288:       "18.2-rc-3",
// 289:       "1875Beta",
// 290:       "19.3.2,b4188-155116",
// 291:       "2.0-rc.22",
// 292:       "2.0.0-beta.2",
// 293:       "2.0.0-beta14",
// 294:       "2.0.0-dev.11,1902221558.a6b3c4a8",
// 295:       "2.0.12,b1807-50472cde",
// 296:       "2.0b",
// 297:       "2.0b2",
// 298:       "2.0b3-2020",
// 299:       "2.0b5",
// 300:       "2.1.1-dev.3",
// 301:       "2.12.12beta3",
// 302:       "2.12b1",
// 303:       "2.2-Beta",
// 304:       "2.2.0-RC1",
// 305:       "2.2b2",
// 306:       "2.3.0-beta1u1",
// 307:       "2.3.1,rc4",
// 308:       "2.3b19",
// 309:       "2.4.0-beta2",
// 310:       "2.4.6-beta3u2",
// 311:       "2.6.1-dev_2019-02-09_14-04_git-master-c1f194a",
// 312:       "2.7.4a1",
// 313:       "2.79b",
// 314:       "2.99pre5",
// 315:       "2019.1-Beta2",
// 316:       "2019.1-b112",
// 317:       "2019.1-beta1",
// 318:       "2019a",
// 319:       "26.1-rc1-1",
// 320:       "3.0.0-beta.5",
// 321:       "3.0.0-beta19",
// 322:       "3.0.0-canary.8",
// 323:       "3.0.0-preview-27122-01",
// 324:       "3.0.0-rc.14",
// 325:       "3.0.1-beta.19",
// 326:       "3.0.100-preview-010184",
// 327:       "3.0.6a",
// 328:       "3.00b5",
// 329:       "3.1.0-beta.1",
// 330:       "3.1.0_b15007",
// 331:       "3.2.8beta1",
// 332:       "3.21-beta",
// 333:       "3.7.9beta03,5210",
// 334:       "3b19",
// 335:       "4.0.0a",
// 336:       "4.2.0-preview",
// 337:       "4.3-beta5",
// 338:       "4.3b3",
// 339:       "4.99beta",
// 340:       "5.0.0-RC7",
// 341:       "5.5.0-beta-9",
// 342:       "6.0.0-beta3,20181228T124823",
// 343:       "6.0.0_BETA3,127054",
// 344:       "6.1.1b176",
// 345:       "6.2.0-preview.4",
// 346:       "6.2.0.0.beta1",
// 347:       "6.3.9_b16229",
// 348:       "6.44b",
// 349:       "7.0.6-7A69",
// 350:       "7.3.BETA-3",
// 351:       "8.5a8",
// 352:       "8u202,b08:1961070e4c9b4e26a04e7f5a083f551e",
// 353:     ]) do |unstable_version|
// 354:       it "detects #{unstable_version.inspect} as unstable" do
// 355:         expect(described_class.new(unstable_version)).to be_unstable
// 356:       end
// 357:     end
// 358:
// 359:     test_each([
// 360:       "0.20.1,63d9b84e-bbcf-4a00-9427-0bb3f713c769",
// 361:       "1.5.4,13:53d8a307-a8ae-4f9b-9a59-a1adb8c67012",
// 362:       "b226",
// 363:     ]) do |stable_version|
// 364:       it "does not detect #{stable_version.inspect} as unstable" do
// 365:         expect(described_class.new(stable_version)).not_to be_unstable
// 366:       end
// 367:     end
// 368:   end
// 369: end
