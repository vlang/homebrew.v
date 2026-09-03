module test

import homebrew

// Translated from Homebrew/brew `test/deprecate_disable_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:deprecate_date) { Date.parse("2020-01-01") }` at line 7.
pub fn ruby_deprecate_disable_spec_l7_d1_deprecate_date() string {
	return '2020-01-01'
}

// Ruby let `let(:disable_date) { deprecate_date >> DeprecateDisable::REMOVE_DISABLED_TIME_WINDOW }` at line 8.
pub fn ruby_deprecate_disable_spec_l8_d2_disable_date() string {
	return '2021-01-01'
}

// Ruby let `let(:deprecated_formula) do` at line 9.
pub fn ruby_deprecate_disable_spec_l9_d3_deprecated_formula() homebrew.DeprecateDisableSubject {
	return homebrew.DeprecateDisableSubject{
		kind: .formula
		deprecated: true
		deprecation_reason: 'does_not_build'
	}
}

// Ruby let `let(:deprecated_formula_with_date) do` at line 14.
pub fn ruby_deprecate_disable_spec_l14_d4_deprecated_formula_with_date() homebrew.DeprecateDisableSubject {
	return homebrew.DeprecateDisableSubject{
		...ruby_deprecate_disable_spec_l9_d3_deprecated_formula()
		deprecation_date: ruby_deprecate_disable_spec_l7_d1_deprecate_date()
	}
}

// Ruby let `let(:disabled_formula) do` at line 19.
pub fn ruby_deprecate_disable_spec_l19_d5_disabled_formula() homebrew.DeprecateDisableSubject {
	return homebrew.DeprecateDisableSubject{
		kind: .formula
		disabled: true
		disable_reason: 'is broken'
	}
}

// Ruby let `let(:disabled_formula_with_date) do` at line 25.
pub fn ruby_deprecate_disable_spec_l25_d6_disabled_formula_with_date() homebrew.DeprecateDisableSubject {
	return homebrew.DeprecateDisableSubject{
		kind: .formula
		disabled: true
		disable_reason: 'does_not_build'
		disable_date: ruby_deprecate_disable_spec_l8_d2_disable_date()
	}
}

// Ruby let `let(:deprecated_cask) do` at line 31.
pub fn ruby_deprecate_disable_spec_l31_d7_deprecated_cask() homebrew.DeprecateDisableSubject {
	return homebrew.DeprecateDisableSubject{
		kind: .cask
		deprecated: true
		deprecation_reason: 'discontinued'
	}
}

// Ruby let `let(:disabled_cask) do` at line 36.
pub fn ruby_deprecate_disable_spec_l36_d8_disabled_cask() homebrew.DeprecateDisableSubject {
	return homebrew.DeprecateDisableSubject{
		kind: .cask
		disabled: true
	}
}

// Ruby let `let(:deprecated_formula_with_replacement) do` at line 42.
pub fn ruby_deprecate_disable_spec_l42_d9_deprecated_formula_with_replacement() homebrew.DeprecateDisableSubject {
	return ruby_deprecate_disable_spec_l9_d3_deprecated_formula()
}

// Ruby let `let(:disabled_formula_with_replacement) do` at line 46.
pub fn ruby_deprecate_disable_spec_l46_d10_disabled_formula_with_replacement() homebrew.DeprecateDisableSubject {
	return ruby_deprecate_disable_spec_l19_d5_disabled_formula()
}

// Ruby let `let(:deprecated_cask_with_replacement) do` at line 50.
pub fn ruby_deprecate_disable_spec_l50_d11_deprecated_cask_with_replacement() homebrew.DeprecateDisableSubject {
	return ruby_deprecate_disable_spec_l31_d7_deprecated_cask()
}

// Ruby let `let(:disabled_cask_with_replacement) do` at line 54.
pub fn ruby_deprecate_disable_spec_l54_d12_disabled_cask_with_replacement() homebrew.DeprecateDisableSubject {
	return ruby_deprecate_disable_spec_l36_d8_disabled_cask()
}

// Ruby it `it "returns :deprecated if the formula is deprecated" do` at line 88.
pub fn ruby_deprecate_disable_spec_l88_d13_returns() bool {
	return homebrew.deprecate_disable_type(ruby_deprecate_disable_spec_l9_d3_deprecated_formula()) == 'deprecated'
}

// Ruby it `it "returns :disabled if the formula is disabled" do` at line 92.
pub fn ruby_deprecate_disable_spec_l92_d14_returns() bool {
	return homebrew.deprecate_disable_type(ruby_deprecate_disable_spec_l19_d5_disabled_formula()) == 'disabled'
}

// Ruby it `it "returns :deprecated if the cask is deprecated" do` at line 96.
pub fn ruby_deprecate_disable_spec_l96_d15_returns() bool {
	return homebrew.deprecate_disable_type(ruby_deprecate_disable_spec_l31_d7_deprecated_cask()) == 'deprecated'
}

// Ruby it `it "returns :disabled if the cask is disabled" do` at line 100.
pub fn ruby_deprecate_disable_spec_l100_d16_returns() bool {
	return homebrew.deprecate_disable_type(ruby_deprecate_disable_spec_l36_d8_disabled_cask()) == 'disabled'
}

// Ruby it `it "returns a deprecation message with a preset formula reason" do` at line 106.
pub fn ruby_deprecate_disable_spec_l106_d17_returns() bool {
	return homebrew.deprecate_disable_message(ruby_deprecate_disable_spec_l9_d3_deprecated_formula(), '2020-01-01') or { '' } == 'deprecated because it does not build!'
}

// Ruby it `it "returns a deprecation message with disable date" do` at line 111.
pub fn ruby_deprecate_disable_spec_l111_d18_returns() bool {
	return homebrew.deprecate_disable_message(ruby_deprecate_disable_spec_l14_d4_deprecated_formula_with_date(), '2020-01-02') or { '' } == 'deprecated because it does not build! It will be disabled on 2021-01-01.'
}

// Ruby it `it "returns a disable message with a custom reason" do` at line 117.
pub fn ruby_deprecate_disable_spec_l117_d19_returns() bool {
	return homebrew.deprecate_disable_message(ruby_deprecate_disable_spec_l19_d5_disabled_formula(), '2020-01-01') or { '' } == 'disabled because it is broken!'
}

// Ruby it `it "returns a disable message with disable date" do` at line 122.
pub fn ruby_deprecate_disable_spec_l122_d20_returns() bool {
	return homebrew.deprecate_disable_message(ruby_deprecate_disable_spec_l25_d6_disabled_formula_with_date(), '2021-01-02') or { '' } == 'disabled because it does not build! It was disabled on 2021-01-01.'
}

// Ruby it `it "returns a deprecation message with a preset cask reason" do` at line 127.
pub fn ruby_deprecate_disable_spec_l127_d21_returns() bool {
	return homebrew.deprecate_disable_message(ruby_deprecate_disable_spec_l31_d7_deprecated_cask(), '2020-01-01') or { '' } == 'deprecated because it is discontinued upstream!'
}

// Ruby it `it "returns a deprecation message with no reason" do` at line 132.
pub fn ruby_deprecate_disable_spec_l132_d22_returns() bool {
	return homebrew.deprecate_disable_message(ruby_deprecate_disable_spec_l36_d8_disabled_cask(), '2020-01-01') or { '' } == 'disabled!'
}

// Ruby it `it "returns a replacement formula message for a deprecated formula" do` at line 137.
pub fn ruby_deprecate_disable_spec_l137_d23_returns() bool {
	subject := homebrew.DeprecateDisableSubject{
		...ruby_deprecate_disable_spec_l42_d9_deprecated_formula_with_replacement()
		deprecation_formula: 'foo'
	}
	return (homebrew.deprecate_disable_message(subject, '2020-01-01') or { '' }) == 'deprecated because it does not build!\nReplacement:\n  brew install --formula foo\n'
}

// Ruby it `it "returns a replacement cask message for a deprecated formula" do` at line 144.
pub fn ruby_deprecate_disable_spec_l144_d24_returns() bool {
	subject := homebrew.DeprecateDisableSubject{
		...ruby_deprecate_disable_spec_l42_d9_deprecated_formula_with_replacement()
		deprecation_cask: 'foo'
	}
	return (homebrew.deprecate_disable_message(subject, '2020-01-01') or { '' }) == 'deprecated because it does not build!\nReplacement:\n  brew install --cask foo\n'
}

// Ruby it `it "returns a replacement formula message for a disabled formula" do` at line 151.
pub fn ruby_deprecate_disable_spec_l151_d25_returns() bool {
	subject := homebrew.DeprecateDisableSubject{
		...ruby_deprecate_disable_spec_l46_d10_disabled_formula_with_replacement()
		disable_formula: 'bar'
	}
	return (homebrew.deprecate_disable_message(subject, '2020-01-01') or { '' }) == 'disabled because it is broken!\nReplacement:\n  brew install --formula bar\n'
}

// Ruby it `it "returns a replacement cask message for a disabled formula" do` at line 158.
pub fn ruby_deprecate_disable_spec_l158_d26_returns() bool {
	subject := homebrew.DeprecateDisableSubject{
		...ruby_deprecate_disable_spec_l46_d10_disabled_formula_with_replacement()
		disable_cask: 'bar'
	}
	return (homebrew.deprecate_disable_message(subject, '2020-01-01') or { '' }) == 'disabled because it is broken!\nReplacement:\n  brew install --cask bar\n'
}

// Ruby it `it "returns a replacement formula message for a deprecated cask" do` at line 165.
pub fn ruby_deprecate_disable_spec_l165_d27_returns() bool {
	subject := homebrew.DeprecateDisableSubject{
		...ruby_deprecate_disable_spec_l50_d11_deprecated_cask_with_replacement()
		deprecation_formula: 'baz'
	}
	return (homebrew.deprecate_disable_message(subject, '2020-01-01') or { '' }) == 'deprecated because it is discontinued upstream!\nReplacement:\n  brew install --formula baz\n'
}

// Ruby it `it "returns a replacement cask message for a deprecated cask" do` at line 172.
pub fn ruby_deprecate_disable_spec_l172_d28_returns() bool {
	subject := homebrew.DeprecateDisableSubject{
		...ruby_deprecate_disable_spec_l50_d11_deprecated_cask_with_replacement()
		deprecation_cask: 'baz'
	}
	return (homebrew.deprecate_disable_message(subject, '2020-01-01') or { '' }) == 'deprecated because it is discontinued upstream!\nReplacement:\n  brew install --cask baz\n'
}

// Ruby it `it "returns a replacement formula message for a disabled cask" do` at line 179.
pub fn ruby_deprecate_disable_spec_l179_d29_returns() bool {
	subject := homebrew.DeprecateDisableSubject{
		...ruby_deprecate_disable_spec_l54_d12_disabled_cask_with_replacement()
		disable_formula: 'qux'
	}
	return (homebrew.deprecate_disable_message(subject, '2020-01-01') or { '' }) == 'disabled!\nReplacement:\n  brew install --formula qux\n'
}

// Ruby it `it "returns a replacement cask message for a disabled cask" do` at line 186.
pub fn ruby_deprecate_disable_spec_l186_d30_returns() bool {
	subject := homebrew.DeprecateDisableSubject{
		...ruby_deprecate_disable_spec_l54_d12_disabled_cask_with_replacement()
		disable_cask: 'qux'
	}
	return (homebrew.deprecate_disable_message(subject, '2020-01-01') or { '' }) == 'disabled!\nReplacement:\n  brew install --cask qux\n'
}

// Ruby it `it "returns the original string if it isn't a formula preset reason" do` at line 195.
pub fn ruby_deprecate_disable_spec_l195_d31_returns() bool {
	reason := homebrew.deprecate_disable_reason_from_string('discontinued', .formula) or {
		return false
	}
	return reason.value == 'discontinued' && !reason.is_symbol
}

// Ruby it `it "returns the original string if it isn't a cask preset reason" do` at line 199.
pub fn ruby_deprecate_disable_spec_l199_d32_returns() bool {
	reason := homebrew.deprecate_disable_reason_from_string('does_not_build', .cask) or {
		return false
	}
	return reason.value == 'does_not_build' && !reason.is_symbol
}

// Ruby it `it "returns a symbol if the original string is a formula preset reason" do` at line 203.
pub fn ruby_deprecate_disable_spec_l203_d33_returns() bool {
	reason := homebrew.deprecate_disable_reason_from_string('does_not_build', .formula) or {
		return false
	}
	return reason.value == 'does_not_build' && reason.is_symbol
}

// Ruby it `it "returns a symbol if the original string is a cask preset reason" do` at line 208.
pub fn ruby_deprecate_disable_spec_l208_d34_returns() bool {
	reason := homebrew.deprecate_disable_reason_from_string('discontinued', .cask) or {
		return false
	}
	return reason.value == 'discontinued' && reason.is_symbol
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "deprecate_disable"
// 5:
// 6: RSpec.describe DeprecateDisable do
// 7:   let(:deprecate_date) { Date.parse("2020-01-01") }
// 8:   let(:disable_date) { deprecate_date >> DeprecateDisable::REMOVE_DISABLED_TIME_WINDOW }
// 9:   let(:deprecated_formula) do
// 10:     instance_double(Formula, deprecated?: true, disabled?: false, deprecation_reason: :does_not_build,
// 11:                     deprecation_replacement_formula: nil, deprecation_replacement_cask: nil,
// 12:                     deprecation_date: nil, disable_date: nil)
// 13:   end
// 14:   let(:deprecated_formula_with_date) do
// 15:     instance_double(Formula, deprecated?: true, disabled?: false, deprecation_reason: :does_not_build,
// 16:                     deprecation_replacement_formula: nil, deprecation_replacement_cask: nil,
// 17:                     deprecation_date: deprecate_date, disable_date: nil)
// 18:   end
// 19:   let(:disabled_formula) do
// 20:     instance_double(Formula, deprecated?: false, disabled?: true, disable_reason: "is broken",
// 21:                     deprecation_replacement_formula: nil, deprecation_replacement_cask: nil,
// 22:                     disable_replacement_formula: nil, disable_replacement_cask: nil,
// 23:                     deprecation_date: nil, disable_date: nil)
// 24:   end
// 25:   let(:disabled_formula_with_date) do
// 26:     instance_double(Formula, deprecated?: false, disabled?: true, disable_reason: :does_not_build,
// 27:                     deprecation_replacement_formula: nil, deprecation_replacement_cask: nil,
// 28:                     disable_replacement_formula: nil, disable_replacement_cask: nil,
// 29:                     deprecation_date: nil, disable_date: disable_date)
// 30:   end
// 31:   let(:deprecated_cask) do
// 32:     instance_double(Cask::Cask, deprecated?: true, disabled?: false, deprecation_reason: :discontinued,
// 33:                     deprecation_replacement_formula: nil, deprecation_replacement_cask: nil,
// 34:                     deprecation_date: nil, disable_date: nil)
// 35:   end
// 36:   let(:disabled_cask) do
// 37:     instance_double(Cask::Cask, deprecated?: false, disabled?: true, disable_reason: nil,
// 38:                     deprecation_replacement_formula: nil, deprecation_replacement_cask: nil,
// 39:                     disable_replacement_formula: nil, disable_replacement_cask: nil,
// 40:                     deprecation_date: nil, disable_date: nil)
// 41:   end
// 42:   let(:deprecated_formula_with_replacement) do
// 43:     instance_double(Formula, deprecated?: true, disabled?: false, deprecation_reason: :does_not_build,
// 44:                     deprecation_date: nil, disable_date: nil)
// 45:   end
// 46:   let(:disabled_formula_with_replacement) do
// 47:     instance_double(Formula, deprecated?: false, disabled?: true, disable_reason: "is broken",
// 48:                     deprecation_date: nil, disable_date: nil)
// 49:   end
// 50:   let(:deprecated_cask_with_replacement) do
// 51:     instance_double(Cask::Cask, deprecated?: true, disabled?: false, deprecation_reason: :discontinued,
// 52:                     deprecation_date: nil, disable_date: nil)
// 53:   end
// 54:   let(:disabled_cask_with_replacement) do
// 55:     instance_double(Cask::Cask, deprecated?: false, disabled?: true, disable_reason: nil,
// 56:                     deprecation_date: nil, disable_date: nil)
// 57:   end
// 58:
// 59:   before do
// 60:     formulae = [
// 61:       deprecated_formula,
// 62:       deprecated_formula_with_date,
// 63:       disabled_formula,
// 64:       disabled_formula_with_date,
// 65:       deprecated_formula_with_replacement,
// 66:       disabled_formula_with_replacement,
// 67:     ]
// 68:
// 69:     casks = [
// 70:       deprecated_cask,
// 71:       disabled_cask,
// 72:       deprecated_cask_with_replacement,
// 73:       disabled_cask_with_replacement,
// 74:     ]
// 75:
// 76:     formulae.each do |f|
// 77:       allow(f).to receive(:is_a?).with(Formula).and_return(true)
// 78:       allow(f).to receive(:is_a?).with(Cask::Cask).and_return(false)
// 79:     end
// 80:
// 81:     casks.each do |c|
// 82:       allow(c).to receive(:is_a?).with(Formula).and_return(false)
// 83:       allow(c).to receive(:is_a?).with(Cask::Cask).and_return(true)
// 84:     end
// 85:   end
// 86:
// 87:   describe "::type" do
// 88:     it "returns :deprecated if the formula is deprecated" do
// 89:       expect(described_class.type(deprecated_formula)).to eq :deprecated
// 90:     end
// 91:
// 92:     it "returns :disabled if the formula is disabled" do
// 93:       expect(described_class.type(disabled_formula)).to eq :disabled
// 94:     end
// 95:
// 96:     it "returns :deprecated if the cask is deprecated" do
// 97:       expect(described_class.type(deprecated_cask)).to eq :deprecated
// 98:     end
// 99:
// 100:     it "returns :disabled if the cask is disabled" do
// 101:       expect(described_class.type(disabled_cask)).to eq :disabled
// 102:     end
// 103:   end
// 104:
// 105:   describe "::message" do
// 106:     it "returns a deprecation message with a preset formula reason" do
// 107:       expect(described_class.message(deprecated_formula))
// 108:         .to eq "deprecated because it does not build!"
// 109:     end
// 110:
// 111:     it "returns a deprecation message with disable date" do
// 112:       allow(Date).to receive(:today).and_return(deprecate_date + 1)
// 113:       expect(described_class.message(deprecated_formula_with_date))
// 114:         .to eq "deprecated because it does not build! It will be disabled on #{disable_date}."
// 115:     end
// 116:
// 117:     it "returns a disable message with a custom reason" do
// 118:       expect(described_class.message(disabled_formula))
// 119:         .to eq "disabled because it is broken!"
// 120:     end
// 121:
// 122:     it "returns a disable message with disable date" do
// 123:       expect(described_class.message(disabled_formula_with_date))
// 124:         .to eq "disabled because it does not build! It was disabled on #{disable_date}."
// 125:     end
// 126:
// 127:     it "returns a deprecation message with a preset cask reason" do
// 128:       expect(described_class.message(deprecated_cask))
// 129:         .to eq "deprecated because it is discontinued upstream!"
// 130:     end
// 131:
// 132:     it "returns a deprecation message with no reason" do
// 133:       expect(described_class.message(disabled_cask))
// 134:         .to eq "disabled!"
// 135:     end
// 136:
// 137:     it "returns a replacement formula message for a deprecated formula" do
// 138:       allow(deprecated_formula_with_replacement).to receive_messages(deprecation_replacement_formula: "foo",
// 139:                                                                      deprecation_replacement_cask:    nil)
// 140:       expect(described_class.message(deprecated_formula_with_replacement))
// 141:         .to eq "deprecated because it does not build!\nReplacement:\n  brew install --formula foo\n"
// 142:     end
// 143:
// 144:     it "returns a replacement cask message for a deprecated formula" do
// 145:       allow(deprecated_formula_with_replacement).to receive_messages(deprecation_replacement_formula: nil,
// 146:                                                                      deprecation_replacement_cask:    "foo")
// 147:       expect(described_class.message(deprecated_formula_with_replacement))
// 148:         .to eq "deprecated because it does not build!\nReplacement:\n  brew install --cask foo\n"
// 149:     end
// 150:
// 151:     it "returns a replacement formula message for a disabled formula" do
// 152:       allow(disabled_formula_with_replacement).to receive_messages(disable_replacement_formula: "bar",
// 153:                                                                    disable_replacement_cask:    nil)
// 154:       expect(described_class.message(disabled_formula_with_replacement))
// 155:         .to eq "disabled because it is broken!\nReplacement:\n  brew install --formula bar\n"
// 156:     end
// 157:
// 158:     it "returns a replacement cask message for a disabled formula" do
// 159:       allow(disabled_formula_with_replacement).to receive_messages(disable_replacement_formula: nil,
// 160:                                                                    disable_replacement_cask:    "bar")
// 161:       expect(described_class.message(disabled_formula_with_replacement))
// 162:         .to eq "disabled because it is broken!\nReplacement:\n  brew install --cask bar\n"
// 163:     end
// 164:
// 165:     it "returns a replacement formula message for a deprecated cask" do
// 166:       allow(deprecated_cask_with_replacement).to receive_messages(deprecation_replacement_formula: "baz",
// 167:                                                                   deprecation_replacement_cask:    nil)
// 168:       expect(described_class.message(deprecated_cask_with_replacement))
// 169:         .to eq "deprecated because it is discontinued upstream!\nReplacement:\n  brew install --formula baz\n"
// 170:     end
// 171:
// 172:     it "returns a replacement cask message for a deprecated cask" do
// 173:       allow(deprecated_cask_with_replacement).to receive_messages(deprecation_replacement_formula: nil,
// 174:                                                                   deprecation_replacement_cask:    "baz")
// 175:       expect(described_class.message(deprecated_cask_with_replacement))
// 176:         .to eq "deprecated because it is discontinued upstream!\nReplacement:\n  brew install --cask baz\n"
// 177:     end
// 178:
// 179:     it "returns a replacement formula message for a disabled cask" do
// 180:       allow(disabled_cask_with_replacement).to receive_messages(disable_replacement_formula: "qux",
// 181:                                                                 disable_replacement_cask:    nil)
// 182:       expect(described_class.message(disabled_cask_with_replacement))
// 183:         .to eq "disabled!\nReplacement:\n  brew install --formula qux\n"
// 184:     end
// 185:
// 186:     it "returns a replacement cask message for a disabled cask" do
// 187:       allow(disabled_cask_with_replacement).to receive_messages(disable_replacement_formula: nil,
// 188:                                                                 disable_replacement_cask:    "qux")
// 189:       expect(described_class.message(disabled_cask_with_replacement))
// 190:         .to eq "disabled!\nReplacement:\n  brew install --cask qux\n"
// 191:     end
// 192:   end
// 193:
// 194:   describe "::to_reason_string_or_symbol" do
// 195:     it "returns the original string if it isn't a formula preset reason" do
// 196:       expect(described_class.to_reason_string_or_symbol("discontinued", type: :formula)).to eq "discontinued"
// 197:     end
// 198:
// 199:     it "returns the original string if it isn't a cask preset reason" do
// 200:       expect(described_class.to_reason_string_or_symbol("does_not_build", type: :cask)).to eq "does_not_build"
// 201:     end
// 202:
// 203:     it "returns a symbol if the original string is a formula preset reason" do
// 204:       expect(described_class.to_reason_string_or_symbol("does_not_build", type: :formula))
// 205:         .to eq :does_not_build
// 206:     end
// 207:
// 208:     it "returns a symbol if the original string is a cask preset reason" do
// 209:       expect(described_class.to_reason_string_or_symbol("discontinued", type: :cask))
// 210:         .to eq :discontinued
// 211:     end
// 212:   end
// 213: end
