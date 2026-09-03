module test

import homebrew

fn requirement_spec_class() homebrew.RequirementClass {
	return homebrew.anonymous_requirement_class('requirement-spec-anonymous')
}

fn requirement_spec_true(_ homebrew.Requirement) homebrew.RequirementResult {
	return homebrew.bool_requirement_result(true)
}

fn requirement_spec_false(_ homebrew.Requirement) homebrew.RequirementResult {
	return homebrew.bool_requirement_result(false)
}

fn requirement_spec_path(_ homebrew.Requirement) homebrew.RequirementResult {
	return homebrew.path_requirement_result('/foo/bar/baz')
}

fn requirement_spec_prefix_bin(_ homebrew.Requirement) homebrew.RequirementResult {
	return homebrew.path_requirement_result('/opt/homebrew/bin/foo')
}

fn requirement_spec_prefix_sbin(_ homebrew.Requirement) homebrew.RequirementResult {
	return homebrew.path_requirement_result('/opt/homebrew/sbin/foo')
}

fn requirement_spec_which_sh(_ homebrew.Requirement) homebrew.RequirementResult {
	path := homebrew.requirement_which('sh', ['/bin', '/usr/bin']) or {
		return homebrew.nil_requirement_result()
	}
	return homebrew.path_requirement_result(path)
}

fn requirement_spec_execution() homebrew.RequirementExecution {
	return homebrew.RequirementExecution{
		environment: {
			'PATH': '/usr/bin:/bin'
		}
		prefix: '/opt/homebrew'
		cellar: '/opt/homebrew/Cellar'
		original_paths: ['/bin', '/usr/bin']
	}
}

fn requirement_spec_block_class(identity string, build_env bool,
	block homebrew.RequirementSatisfyBlock) homebrew.RequirementClass {
	mut class := homebrew.anonymous_requirement_class(identity)
	class.satisfy(homebrew.RequirementSatisfierInitialization{
		options_are_hash: true
		has_build_env: true
		build_env: build_env
		has_proc: true
		proc: block
	})
	return class
}

fn requirement_spec_default_block_class(identity string,
	block homebrew.RequirementSatisfyBlock) homebrew.RequirementClass {
	mut class := homebrew.anonymous_requirement_class(identity)
	class.satisfy(homebrew.RequirementSatisfierInitialization{
		options_are_hash: true
		has_proc: true
		proc: block
	})
	return class
}

fn requirement_spec_fixed_class(identity string, value bool) homebrew.RequirementClass {
	mut class := homebrew.anonymous_requirement_class(identity)
	class.satisfy(homebrew.RequirementSatisfierInitialization{
		fixed_value: homebrew.bool_requirement_result(value)
	})
	return class
}

// Translated from Homebrew/brew `test/requirement_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby alias_matcher `alias_matcher :be_a_build_requirement, :be_a_build` at line 8.
pub fn ruby_requirement_spec_l8_d1_be_a_build_requirement(requirement homebrew.Requirement) bool {
	return requirement.build()
}

// Ruby subject `subject(:requirement) { klass.new }` at line 10.
pub fn ruby_requirement_spec_l10_d2_requirement() !homebrew.Requirement {
	return homebrew.new_requirement(requirement_spec_class(), [])
}

// Ruby let `let(:klass) { Class.new(described_class) }` at line 12.
pub fn ruby_requirement_spec_l12_d3_klass() homebrew.RequirementClass {
	return requirement_spec_class()
}

// Ruby it `it "raises an error when instantiated" do` at line 15.
pub fn ruby_requirement_spec_l15_d4_raises() bool {
	if _ := homebrew.new_requirement(homebrew.base_requirement_class(), []) {
		return false
	} else {
		return err.msg() == 'Requirement is declared as abstract; it cannot be instantiated'
	}
}

// Ruby subject `subject(:req) { klass.new(tags) }` at line 22.
pub fn ruby_requirement_spec_l22_d5_req(tags []homebrew.RequirementTag) !homebrew.Requirement {
	return homebrew.new_requirement(requirement_spec_class(), tags)
}

// Ruby let `let(:tags) { ["bar"] }` at line 25.
pub fn ruby_requirement_spec_l25_d6_tags() []homebrew.RequirementTag {
	return [homebrew.string_requirement_tag('bar')]
}

// Ruby it `it(:tags) { expect(req.tags).to eq(tags) }` at line 27.
pub fn ruby_requirement_spec_l27_d7_tags() !bool {
	tags := ruby_requirement_spec_l25_d6_tags()
	return homebrew.requirement_tags_match(ruby_requirement_spec_l22_d5_req(tags)!.tags, tags)
}

// Ruby let `let(:tags) { ["bar", "baz"] }` at line 31.
pub fn ruby_requirement_spec_l31_d8_tags() []homebrew.RequirementTag {
	return [homebrew.string_requirement_tag('bar'), homebrew.string_requirement_tag('baz')]
}

// Ruby it `it(:tags) { expect(req.tags).to eq(tags) }` at line 33.
pub fn ruby_requirement_spec_l33_d9_tags() !bool {
	tags := ruby_requirement_spec_l31_d8_tags()
	return homebrew.requirement_tags_match(ruby_requirement_spec_l22_d5_req(tags)!.tags, tags)
}

// Ruby let `let(:tags) { [:build] }` at line 37.
pub fn ruby_requirement_spec_l37_d10_tags() []homebrew.RequirementTag {
	return [homebrew.symbol_requirement_tag('build')]
}

// Ruby it `it(:tags) { expect(req.tags).to eq(tags) }` at line 39.
pub fn ruby_requirement_spec_l39_d11_tags() !bool {
	tags := ruby_requirement_spec_l37_d10_tags()
	return homebrew.requirement_tags_match(ruby_requirement_spec_l22_d5_req(tags)!.tags, tags)
}

// Ruby let `let(:tags) { [:build, "bar"] }` at line 43.
pub fn ruby_requirement_spec_l43_d12_tags() []homebrew.RequirementTag {
	return [homebrew.symbol_requirement_tag('build'), homebrew.string_requirement_tag('bar')]
}

// Ruby it `it(:tags) { expect(req.tags).to eq(tags) }` at line 45.
pub fn ruby_requirement_spec_l45_d13_tags() !bool {
	tags := ruby_requirement_spec_l43_d12_tags()
	return homebrew.requirement_tags_match(ruby_requirement_spec_l22_d5_req(tags)!.tags, tags)
}

// Ruby let `let(:klass) do` at line 51.
pub fn ruby_requirement_spec_l51_d14_klass() homebrew.RequirementClass {
	mut class := requirement_spec_class()
	class.fatal_dsl(true)
	return class
}

// Ruby it `it { is_expected.to be_fatal }` at line 57.
pub fn ruby_requirement_spec_l57_d15_anonymous() !bool {
	return homebrew.new_requirement(ruby_requirement_spec_l51_d14_klass(), [])!.fatal()
}

// Ruby it `it { is_expected.not_to be_fatal }` at line 61.
pub fn ruby_requirement_spec_l61_d16_anonymous() !bool {
	return !ruby_requirement_spec_l10_d2_requirement()!.fatal()
}

// Ruby let `let(:klass) do` at line 67.
pub fn ruby_requirement_spec_l67_d17_klass() homebrew.RequirementClass {
	return requirement_spec_block_class('satisfy-block-true', false, requirement_spec_true)
}

// Ruby it `it { is_expected.to be_satisfied }` at line 75.
pub fn ruby_requirement_spec_l75_d18_anonymous() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l67_d17_klass(), [])!
	mut execution := requirement_spec_execution()
	return requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
}

// Ruby let `let(:klass) do` at line 79.
pub fn ruby_requirement_spec_l79_d19_klass() homebrew.RequirementClass {
	return requirement_spec_block_class('satisfy-block-false', false, requirement_spec_false)
}

// Ruby it `it { is_expected.not_to be_satisfied }` at line 87.
pub fn ruby_requirement_spec_l87_d20_anonymous() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l79_d19_klass(), [])!
	mut execution := requirement_spec_execution()
	return !requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
}

// Ruby let `let(:klass) do` at line 91.
pub fn ruby_requirement_spec_l91_d21_klass() homebrew.RequirementClass {
	return requirement_spec_fixed_class('satisfy-fixed-true', true)
}

// Ruby it `it { is_expected.to be_satisfied }` at line 97.
pub fn ruby_requirement_spec_l97_d22_anonymous() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l91_d21_klass(), [])!
	mut execution := requirement_spec_execution()
	return requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
}

// Ruby let `let(:klass) do` at line 101.
pub fn ruby_requirement_spec_l101_d23_klass() homebrew.RequirementClass {
	return requirement_spec_fixed_class('satisfy-fixed-false', false)
}

// Ruby it `it { is_expected.not_to be_satisfied }` at line 107.
pub fn ruby_requirement_spec_l107_d24_anonymous() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l101_d23_klass(), [])!
	mut execution := requirement_spec_execution()
	return !requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
}

// Ruby let `let(:klass) do` at line 111.
pub fn ruby_requirement_spec_l111_d25_klass() homebrew.RequirementClass {
	return requirement_spec_default_block_class('satisfy-default-build-environment', requirement_spec_true)
}

// Ruby it `it "sets up build environment" do` at line 119.
pub fn ruby_requirement_spec_l119_d26_sets() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l111_d25_klass(), [])!
	mut execution := requirement_spec_execution()
	requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
	return execution.build_environment_calls == 1
}

// Ruby let `let(:klass) do` at line 126.
pub fn ruby_requirement_spec_l126_d27_klass() homebrew.RequirementClass {
	return requirement_spec_block_class('satisfy-no-build-environment', false, requirement_spec_true)
}

// Ruby it `it "skips setting up build environment" do` at line 134.
pub fn ruby_requirement_spec_l134_d28_skips() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l126_d27_klass(), [])!
	mut execution := requirement_spec_execution()
	requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
	return execution.build_environment_calls == 0
}

// Ruby let `let(:klass) do` at line 141.
pub fn ruby_requirement_spec_l141_d29_klass() homebrew.RequirementClass {
	return requirement_spec_default_block_class('satisfy-path', requirement_spec_path)
}

// Ruby it `it "infers path from` at line 149.
pub fn ruby_requirement_spec_l149_d30_infers() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l141_d29_klass(), [])!
	mut execution := requirement_spec_execution()
	requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
	requirement.modify_build_environment(mut execution, homebrew.RequirementEvaluationOptions{})
	return execution.prepended_paths == ['/foo/bar']
}

// Ruby let `let(:klass) do` at line 159.
pub fn ruby_requirement_spec_l159_d31_klass() homebrew.RequirementClass {
	return requirement_spec_default_block_class('satisfy-prefix-bin', requirement_spec_prefix_bin)
}

// Ruby it `it "does not prepend the parent to PATH" do` at line 167.
pub fn ruby_requirement_spec_l167_d32_does() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l159_d31_klass(), [])!
	mut execution := requirement_spec_execution()
	requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
	requirement.modify_build_environment(mut execution, homebrew.RequirementEvaluationOptions{})
	return execution.prepended_paths.len == 0
}

// Ruby let `let(:klass) do` at line 177.
pub fn ruby_requirement_spec_l177_d33_klass() homebrew.RequirementClass {
	return requirement_spec_default_block_class('satisfy-prefix-sbin', requirement_spec_prefix_sbin)
}

// Ruby it `it "does not prepend the parent to PATH" do` at line 185.
pub fn ruby_requirement_spec_l185_d34_does() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l177_d33_klass(), [])!
	mut execution := requirement_spec_execution()
	requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
	requirement.modify_build_environment(mut execution, homebrew.RequirementEvaluationOptions{})
	return execution.prepended_paths.len == 0
}

// Ruby let `let(:klass) do` at line 195.
pub fn ruby_requirement_spec_l195_d35_klass() homebrew.RequirementClass {
	return requirement_spec_block_class('satisfy-which-sh', false, requirement_spec_which_sh)
}

// Ruby it `it "does not raise an error" do` at line 203.
pub fn ruby_requirement_spec_l203_d36_does() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l195_d35_klass(), [])!
	mut execution := requirement_spec_execution()
	requirement.satisfied(mut execution, homebrew.RequirementEvaluationOptions{})
	return true
}

// Ruby subject `subject { klass.new([:build]) }` at line 211.
pub fn ruby_requirement_spec_l211_d37_subject_dynamic() !homebrew.Requirement {
	return homebrew.new_requirement(requirement_spec_class(), [
		homebrew.symbol_requirement_tag('build'),
	])
}

// Ruby it `it { is_expected.to be_a_build_requirement }` at line 213.
pub fn ruby_requirement_spec_l213_d38_anonymous() !bool {
	return ruby_requirement_spec_l211_d37_subject_dynamic()!.build()
}

// Ruby it `it { is_expected.not_to be_a_build_requirement }` at line 217.
pub fn ruby_requirement_spec_l217_d39_anonymous() !bool {
	return !ruby_requirement_spec_l10_d2_requirement()!.build()
}

// Ruby let `let(:const) { :FooRequirement }` at line 222.
pub fn ruby_requirement_spec_l222_d40_const() string {
	return 'FooRequirement'
}

// Ruby let `let(:klass) { self.class.const_get(const) }` at line 225.
pub fn ruby_requirement_spec_l225_d41_klass() homebrew.RequirementClass {
	return homebrew.new_requirement_class(ruby_requirement_spec_l222_d40_const())
}

// Ruby it `it(:name) { expect(requirement.name).to eq("foo") }` at line 232.
pub fn ruby_requirement_spec_l232_d42_name() !bool {
	return homebrew.new_requirement(ruby_requirement_spec_l225_d41_klass(), [])!.name == 'foo'
}

// Ruby it `it(:option_names) { expect(requirement.option_names).to eq(["foo"]) }` at line 233.
pub fn ruby_requirement_spec_l233_d43_option_names() !bool {
	return homebrew.new_requirement(ruby_requirement_spec_l225_d41_klass(), [])!.option_names() == [
		'foo',
	]
}

// Ruby let `let(:klass) { Class.new(described_class) }` at line 238.
pub fn ruby_requirement_spec_l238_d44_klass() homebrew.RequirementClass {
	return requirement_spec_class()
}

// Ruby it `it "returns nil" do` at line 240.
pub fn ruby_requirement_spec_l240_d45_returns() !bool {
	mut requirement := homebrew.new_requirement(ruby_requirement_spec_l238_d44_klass(), [])!
	mut execution := requirement_spec_execution()
	requirement.modify_build_environment(mut execution, homebrew.RequirementEvaluationOptions{})
	return true
}

// Ruby subject `subject(:requirement) { klass.new }` at line 247.
pub fn ruby_requirement_spec_l247_d46_requirement() !homebrew.Requirement {
	return homebrew.new_requirement(requirement_spec_class(), [])
}

// Ruby it `it "returns true if the names and tags are equal" do` at line 249.
pub fn ruby_requirement_spec_l249_d47_returns() !bool {
	requirement := ruby_requirement_spec_l247_d46_requirement()!
	other := homebrew.new_requirement(requirement_spec_class(), [])!
	return requirement.equals(other) && requirement.equals(other)
}

// Ruby it `it "returns false if names differ" do` at line 256.
pub fn ruby_requirement_spec_l256_d48_returns() !bool {
	requirement := ruby_requirement_spec_l247_d46_requirement()!
	mut other := homebrew.new_requirement(requirement_spec_class(), [])!
	other.name = 'foo'
	return !requirement.equals(other) && !requirement.equals(other)
}

// Ruby it `it "returns false if tags differ" do` at line 263.
pub fn ruby_requirement_spec_l263_d49_returns() !bool {
	requirement := ruby_requirement_spec_l247_d46_requirement()!
	other := homebrew.new_requirement(requirement_spec_class(), [
		homebrew.symbol_requirement_tag('optional'),
	])!
	return !requirement.equals(other) && !requirement.equals(other)
}

// Ruby subject `subject(:requirement) { klass.new }` at line 272.
pub fn ruby_requirement_spec_l272_d50_requirement() !homebrew.Requirement {
	return homebrew.new_requirement(requirement_spec_class(), [])
}

// Ruby it `it "is equal if names and tags are equal" do` at line 274.
pub fn ruby_requirement_spec_l274_d51_is() !bool {
	requirement := ruby_requirement_spec_l272_d50_requirement()!
	other := homebrew.new_requirement(requirement_spec_class(), [])!
	return requirement.hash_value() == other.hash_value()
}

// Ruby it `it "differs if names differ" do` at line 279.
pub fn ruby_requirement_spec_l279_d52_differs() !bool {
	requirement := ruby_requirement_spec_l272_d50_requirement()!
	mut other := homebrew.new_requirement(requirement_spec_class(), [])!
	other.name = 'foo'
	return requirement.hash_value() != other.hash_value()
}

// Ruby it `it "differs if tags differ" do` at line 285.
pub fn ruby_requirement_spec_l285_d53_differs() !bool {
	requirement := ruby_requirement_spec_l272_d50_requirement()!
	other := homebrew.new_requirement(requirement_spec_class(), [
		homebrew.symbol_requirement_tag('optional'),
	])!
	return requirement.hash_value() != other.hash_value()
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/ENV"
// 5: require "requirement"
// 6:
// 7: RSpec.describe Requirement do
// 8:   alias_matcher :be_a_build_requirement, :be_a_build
// 9:
// 10:   subject(:requirement) { klass.new }
// 11:
// 12:   let(:klass) { Class.new(described_class) }
// 13:
// 14:   describe "base class" do
// 15:     it "raises an error when instantiated" do
// 16:       expect { described_class.new }
// 17:         .to raise_error(RuntimeError, "Requirement is declared as abstract; it cannot be instantiated")
// 18:     end
// 19:   end
// 20:
// 21:   describe "#tags" do
// 22:     subject(:req) { klass.new(tags) }
// 23:
// 24:     context "with a single tag" do
// 25:       let(:tags) { ["bar"] }
// 26:
// 27:       it(:tags) { expect(req.tags).to eq(tags) }
// 28:     end
// 29:
// 30:     context "with multiple tags" do
// 31:       let(:tags) { ["bar", "baz"] }
// 32:
// 33:       it(:tags) { expect(req.tags).to eq(tags) }
// 34:     end
// 35:
// 36:     context "with symbol tags" do
// 37:       let(:tags) { [:build] }
// 38:
// 39:       it(:tags) { expect(req.tags).to eq(tags) }
// 40:     end
// 41:
// 42:     context "with symbol and string tags" do
// 43:       let(:tags) { [:build, "bar"] }
// 44:
// 45:       it(:tags) { expect(req.tags).to eq(tags) }
// 46:     end
// 47:   end
// 48:
// 49:   describe "#fatal?" do
// 50:     describe "#fatal true is specified" do
// 51:       let(:klass) do
// 52:         Class.new(described_class) do
// 53:           fatal true
// 54:         end
// 55:       end
// 56:
// 57:       it { is_expected.to be_fatal }
// 58:     end
// 59:
// 60:     describe "#fatal is omitted" do
// 61:       it { is_expected.not_to be_fatal }
// 62:     end
// 63:   end
// 64:
// 65:   describe "#satisfied?" do
// 66:     describe "#satisfy with block and build_env returns true" do
// 67:       let(:klass) do
// 68:         Class.new(described_class) do
// 69:           satisfy(build_env: false) do
// 70:             true
// 71:           end
// 72:         end
// 73:       end
// 74:
// 75:       it { is_expected.to be_satisfied }
// 76:     end
// 77:
// 78:     describe "#satisfy with block and build_env returns false" do
// 79:       let(:klass) do
// 80:         Class.new(described_class) do
// 81:           satisfy(build_env: false) do
// 82:             false
// 83:           end
// 84:         end
// 85:       end
// 86:
// 87:       it { is_expected.not_to be_satisfied }
// 88:     end
// 89:
// 90:     describe "#satisfy returns true" do
// 91:       let(:klass) do
// 92:         Class.new(described_class) do
// 93:           satisfy true
// 94:         end
// 95:       end
// 96:
// 97:       it { is_expected.to be_satisfied }
// 98:     end
// 99:
// 100:     describe "#satisfy returns false" do
// 101:       let(:klass) do
// 102:         Class.new(described_class) do
// 103:           satisfy false
// 104:         end
// 105:       end
// 106:
// 107:       it { is_expected.not_to be_satisfied }
// 108:     end
// 109:
// 110:     describe "#satisfy with block returning true and without :build_env" do
// 111:       let(:klass) do
// 112:         Class.new(described_class) do
// 113:           satisfy do
// 114:             true
// 115:           end
// 116:         end
// 117:       end
// 118:
// 119:       it "sets up build environment" do
// 120:         expect(ENV).to receive(:with_build_environment).and_call_original
// 121:         requirement.satisfied?
// 122:       end
// 123:     end
// 124:
// 125:     describe "#satisfy with block returning true and :build_env set to false" do
// 126:       let(:klass) do
// 127:         Class.new(described_class) do
// 128:           satisfy(build_env: false) do
// 129:             true
// 130:           end
// 131:         end
// 132:       end
// 133:
// 134:       it "skips setting up build environment" do
// 135:         expect(ENV).not_to receive(:with_build_environment)
// 136:         requirement.satisfied?
// 137:       end
// 138:     end
// 139:
// 140:     describe "#satisfy with block returning path and without :build_env" do
// 141:       let(:klass) do
// 142:         Class.new(described_class) do
// 143:           satisfy do
// 144:             Pathname.new("/foo/bar/baz")
// 145:           end
// 146:         end
// 147:       end
// 148:
// 149:       it "infers path from #satisfy result" do
// 150:         without_partial_double_verification do
// 151:           expect(ENV).to receive(:prepend_path).with("PATH", Pathname.new("/foo/bar"))
// 152:         end
// 153:         requirement.satisfied?
// 154:         requirement.modify_build_environment
// 155:       end
// 156:     end
// 157:
// 158:     describe "#satisfy with block returning path under HOMEBREW_PREFIX/bin" do
// 159:       let(:klass) do
// 160:         Class.new(described_class) do
// 161:           satisfy do
// 162:             HOMEBREW_PREFIX/"bin/foo"
// 163:           end
// 164:         end
// 165:       end
// 166:
// 167:       it "does not prepend the parent to PATH" do
// 168:         without_partial_double_verification do
// 169:           expect(ENV).not_to receive(:prepend_path)
// 170:         end
// 171:         requirement.satisfied?
// 172:         requirement.modify_build_environment
// 173:       end
// 174:     end
// 175:
// 176:     describe "#satisfy with block returning path under HOMEBREW_PREFIX/sbin" do
// 177:       let(:klass) do
// 178:         Class.new(described_class) do
// 179:           satisfy do
// 180:             HOMEBREW_PREFIX/"sbin/foo"
// 181:           end
// 182:         end
// 183:       end
// 184:
// 185:       it "does not prepend the parent to PATH" do
// 186:         without_partial_double_verification do
// 187:           expect(ENV).not_to receive(:prepend_path)
// 188:         end
// 189:         requirement.satisfied?
// 190:         requirement.modify_build_environment
// 191:       end
// 192:     end
// 193:
// 194:     describe "#satisfy with block calling #which and :build_env set to false" do
// 195:       let(:klass) do
// 196:         Class.new(described_class) do
// 197:           satisfy(build_env: false) do
// 198:             which("sh")
// 199:           end
// 200:         end
// 201:       end
// 202:
// 203:       it "does not raise an error" do
// 204:         expect { requirement.satisfied? }.not_to raise_error
// 205:       end
// 206:     end
// 207:   end
// 208:
// 209:   describe "#build?" do
// 210:     context "when the :build tag is specified" do
// 211:       subject { klass.new([:build]) }
// 212:
// 213:       it { is_expected.to be_a_build_requirement }
// 214:     end
// 215:
// 216:     describe "#build omitted" do
// 217:       it { is_expected.not_to be_a_build_requirement }
// 218:     end
// 219:   end
// 220:
// 221:   describe "#name and #option_names" do
// 222:     let(:const) { :FooRequirement }
// 223:     # The stubbed requirement class is resolved by name at runtime.
// 224:     # rubocop:disable Sorbet/ConstantsFromStrings
// 225:     let(:klass) { self.class.const_get(const) }
// 226:     # rubocop:enable Sorbet/ConstantsFromStrings
// 227:
// 228:     before do
// 229:       stub_const const.to_s, Class.new(described_class)
// 230:     end
// 231:
// 232:     it(:name) { expect(requirement.name).to eq("foo") }
// 233:     it(:option_names) { expect(requirement.option_names).to eq(["foo"]) }
// 234:   end
// 235:
// 236:   describe "#modify_build_environment" do
// 237:     context "without env proc" do
// 238:       let(:klass) { Class.new(described_class) }
// 239:
// 240:       it "returns nil" do
// 241:         expect { requirement.modify_build_environment }.not_to raise_error
// 242:       end
// 243:     end
// 244:   end
// 245:
// 246:   describe "#eql? and #==" do
// 247:     subject(:requirement) { klass.new }
// 248:
// 249:     it "returns true if the names and tags are equal" do
// 250:       other = klass.new
// 251:
// 252:       expect(requirement).to eql(other)
// 253:       expect(requirement).to eq(other)
// 254:     end
// 255:
// 256:     it "returns false if names differ" do
// 257:       other = klass.new
// 258:       allow(other).to receive(:name).and_return("foo")
// 259:       expect(requirement).not_to eql(other)
// 260:       expect(requirement).not_to eq(other)
// 261:     end
// 262:
// 263:     it "returns false if tags differ" do
// 264:       other = klass.new([:optional])
// 265:
// 266:       expect(requirement).not_to eql(other)
// 267:       expect(requirement).not_to eq(other)
// 268:     end
// 269:   end
// 270:
// 271:   describe "#hash" do
// 272:     subject(:requirement) { klass.new }
// 273:
// 274:     it "is equal if names and tags are equal" do
// 275:       other = klass.new
// 276:       expect(requirement.hash).to eq(other.hash)
// 277:     end
// 278:
// 279:     it "differs if names differ" do
// 280:       other = klass.new
// 281:       allow(other).to receive(:name).and_return("foo")
// 282:       expect(requirement.hash).not_to eq(other.hash)
// 283:     end
// 284:
// 285:     it "differs if tags differ" do
// 286:       other = klass.new([:optional])
// 287:       expect(requirement.hash).not_to eq(other.hash)
// 288:     end
// 289:   end
// 290: end
