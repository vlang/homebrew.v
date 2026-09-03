module test

import brew_runtime
import homebrew
import homebrew.extend.os.mac as missing_formula_mac

fn missing_formula_spec_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn missing_formula_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn missing_formula_spec_reason_value(reason homebrew.MissingFormulaReason) brew_runtime.Value {
	if !reason.present {
		return missing_formula_spec_nil()
	}
	return brew_runtime.string_value(reason.text)
}

fn missing_formula_spec_tap(target string) homebrew.MissingFormulaTap {
	return homebrew.MissingFormulaTap{
		name: 'homebrew/foo'
		issues_url: 'https://github.com/Homebrew/homebrew-foo/issues'
		migrations: {
			'migrated-formula': target
		}
	}
}

fn missing_formula_spec_migration_reason(formula string, target string) homebrew.MissingFormulaReason {
	return homebrew.missing_formula_tap_migration_reason(formula, [
		missing_formula_spec_tap(target),
	])
}

fn missing_formula_spec_deleted_reason(formula string, core_tap bool) homebrew.MissingFormulaReason {
	deleted := formula.ends_with('/deleted-formula')
	return homebrew.missing_formula_deleted_reason(homebrew.MissingDeletedFormula{
		name: formula
		tap_name: 'homebrew/foo'
		tap_issues_url: 'https://github.com/Homebrew/homebrew-foo/issues'
		path_exists: false
		tap_path_exists: true
		core_tap: core_tap
		deleted_in_diff: deleted
		commit_hash: if deleted { '0123456789abcdef' } else { '' }
		short_hash: if deleted { '0123456' } else { '' }
		commit_message: if deleted { "delete formula 'deleted-formula'" } else { '' }
		relative_path: 'Formula/${formula.all_after_last('/')}.rb'
		relative_path_string: if deleted {
			'Formula/deleted-formula.rb'} else {
			''}
	})
}

fn missing_formula_spec_cask(name string, installed bool) homebrew.MissingFormulaCask {
	return homebrew.MissingFormulaCask{
		name: name
		available: name == 'local-caffeine'
		installed: installed
		info: '==> local-caffeine: 1.2.3\nhttps://example.com/local-caffeine\n'
	}
}

// Translated from Homebrew/brew `test/missing_formula_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject { described_class.reason("gem") }` at line 8.
pub fn ruby_missing_formula_spec_l8_d1_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return missing_formula_spec_reason_value(homebrew.missing_formula_reason('gem', false, false, homebrew.MissingFormulaContext{}))
}

// Ruby it `it { is_expected.not_to be_nil }` at line 10.
pub fn ruby_missing_formula_spec_l10_d2_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return missing_formula_spec_bool(ruby_missing_formula_spec_l8_d1_subject_dynamic().type_name != 'NilClass')
}

// Ruby matcher `matcher :disallow do |name|` at line 14.
pub fn ruby_missing_formula_spec_l14_d3_disallow(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'gem' }
	return missing_formula_spec_bool(homebrew.missing_formula_disallowed_reason(name).present)
}

// Ruby specify `specify(:aggregate_failures) do` at line 20.
pub fn ruby_missing_formula_spec_l20_d4_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return missing_formula_spec_bool([
		'gem',
		'pip',
		'pil',
		'macruby',
		'lzma',
		'gsutil',
		'gfortran',
		'play',
		'haskell-platform',
		'mysqldump-secure',
		'ngrok',
	].all(homebrew.missing_formula_disallowed_reason(it).present))
}

// Ruby it `it("disallows Xcode", :needs_macos) { is_expected.to disallow("xcode") }` at line 34.
pub fn ruby_missing_formula_spec_l34_d5_disallows(args ...brew_runtime.Value) brew_runtime.Value {
	return missing_formula_spec_bool(missing_formula_mac.mac_missing_formula_disallowed_reason('xcode').present)
}

// Ruby subject `subject(:reason) { described_class.tap_migration_reason(formula) }` at line 38.
pub fn ruby_missing_formula_spec_l38_d6_reason(args ...brew_runtime.Value) brew_runtime.Value {
	formula := if args.len > 0 { args[0].as_string() } else { 'migrated-formula' }
	target := if args.len > 1 { args[1].as_string() } else { 'homebrew/bar' }
	return missing_formula_spec_reason_value(missing_formula_spec_migration_reason(formula, target))
}

// Ruby let `let(:migration_target) { "homebrew/bar" }` at line 40.
pub fn ruby_missing_formula_spec_l40_d7_migration_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('homebrew/bar')
}

// Ruby let `let(:formula) { "migrated-formula" }` at line 51.
pub fn ruby_missing_formula_spec_l51_d8_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('migrated-formula')
}

// Ruby it `it { is_expected.not_to be_nil }` at line 53.
pub fn ruby_missing_formula_spec_l53_d9_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return missing_formula_spec_bool(ruby_missing_formula_spec_l38_d6_reason().type_name != 'NilClass')
}

// Ruby let `let(:formula) { "missing-formula" }` at line 57.
pub fn ruby_missing_formula_spec_l57_d10_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('missing-formula')
}

// Ruby it `it { is_expected.to be_nil }` at line 59.
pub fn ruby_missing_formula_spec_l59_d11_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	result := ruby_missing_formula_spec_l38_d6_reason(ruby_missing_formula_spec_l57_d10_formula(), ruby_missing_formula_spec_l40_d7_migration_target())
	return missing_formula_spec_bool(result.type_name == 'NilClass')
}

// Ruby let `let(:formula) { "migrated-formula" }` at line 63.
pub fn ruby_missing_formula_spec_l63_d12_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('migrated-formula')
}

// Ruby let `let(:migration_target) { "renamed-formula" }` at line 64.
pub fn ruby_missing_formula_spec_l64_d13_migration_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('renamed-formula')
}

// Ruby specify `specify(:aggregate_failures) do` at line 66.
pub fn ruby_missing_formula_spec_l66_d14_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	reason := missing_formula_spec_migration_reason('migrated-formula', 'renamed-formula')
	return missing_formula_spec_bool(reason.present && reason.text.contains('brew install renamed-formula') && !reason.text.contains('brew tap'))
}

// Ruby subject `subject { described_class.deleted_reason(formula, silent: true) }` at line 74.
pub fn ruby_missing_formula_spec_l74_d15_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	formula := if args.len > 0 {
		args[0].as_string()
	} else {
		'homebrew/foo/deleted-formula'
	}
	return missing_formula_spec_reason_value(missing_formula_spec_deleted_reason(formula, false))
}

// Ruby let `let(:formula) { "homebrew/foo/deleted-formula" }` at line 94.
pub fn ruby_missing_formula_spec_l94_d16_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('homebrew/foo/deleted-formula')
}

// Ruby it `it { is_expected.not_to be_nil }` at line 96.
pub fn ruby_missing_formula_spec_l96_d17_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	formula := ruby_missing_formula_spec_l94_d16_formula().as_string()
	return missing_formula_spec_bool(missing_formula_spec_deleted_reason(formula, false).present && missing_formula_spec_deleted_reason(formula, true).present)
}

// Ruby let `let(:formula) { "homebrew/foo/missing-formula" }` at line 100.
pub fn ruby_missing_formula_spec_l100_d18_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('homebrew/foo/missing-formula')
}

// Ruby it `it { is_expected.to be_nil }` at line 102.
pub fn ruby_missing_formula_spec_l102_d19_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	formula := ruby_missing_formula_spec_l100_d18_formula().as_string()
	return missing_formula_spec_bool(!missing_formula_spec_deleted_reason(formula, false).present && !missing_formula_spec_deleted_reason(formula, true).present)
}

// Ruby subject `subject(:reason) { described_class.cask_reason(formula, show_info:) }` at line 118.
pub fn ruby_missing_formula_spec_l118_d20_reason(args ...brew_runtime.Value) brew_runtime.Value {
	formula := if args.len > 0 { args[0].as_string() } else { 'local-caffeine' }
	show_info := args.len > 1 && args[1].bool_data
	reason := missing_formula_mac.mac_missing_formula_cask_reason(formula, false, show_info, missing_formula_spec_cask(formula, false))
	return missing_formula_spec_reason_value(reason)
}

// Ruby let `let(:formula) { "local-caffeine" }` at line 121.
pub fn ruby_missing_formula_spec_l121_d21_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('local-caffeine')
}

// Ruby let `let(:show_info) { false }` at line 122.
pub fn ruby_missing_formula_spec_l122_d22_show_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

// Ruby specify `specify(:aggregate_failures) do` at line 124.
pub fn ruby_missing_formula_spec_l124_d23_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	reason := ruby_missing_formula_spec_l118_d20_reason().as_string()
	return missing_formula_spec_bool(reason.contains('Found a cask named "local-caffeine" instead.') && reason.contains('Try\n  brew install --cask local-caffeine'))
}

// Ruby let `let(:formula) { "local-caffeine" }` at line 131.
pub fn ruby_missing_formula_spec_l131_d24_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('local-caffeine')
}

// Ruby let `let(:show_info) { true }` at line 132.
pub fn ruby_missing_formula_spec_l132_d25_show_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby it `it { is_expected.to match(/Found a cask named "local-caffeine" instead.\n\n==> local-caffeine: 1.2.3\n/) }` at line 134.
pub fn ruby_missing_formula_spec_l134_d26_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	reason := ruby_missing_formula_spec_l118_d20_reason(ruby_missing_formula_spec_l131_d24_formula(), ruby_missing_formula_spec_l132_d25_show_info()).as_string()
	return missing_formula_spec_bool(reason.contains('Found a cask named "local-caffeine" instead.\n\n==> local-caffeine: 1.2.3\n'))
}

// Ruby let `let(:formula) { "missing-formula" }` at line 138.
pub fn ruby_missing_formula_spec_l138_d27_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('missing-formula')
}

// Ruby let `let(:show_info) { false }` at line 139.
pub fn ruby_missing_formula_spec_l139_d28_show_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

// Ruby it `it { is_expected.to be_nil }` at line 141.
pub fn ruby_missing_formula_spec_l141_d29_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	result := ruby_missing_formula_spec_l118_d20_reason(ruby_missing_formula_spec_l138_d27_formula(), ruby_missing_formula_spec_l139_d28_show_info())
	return missing_formula_spec_bool(result.type_name == 'NilClass')
}

// Ruby subject `subject(:reason) { described_class.suggest_command(name, command) }` at line 146.
pub fn ruby_missing_formula_spec_l146_d30_reason(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'local-caffeine' }
	command := if args.len > 1 { args[1].as_string() } else { 'install' }
	installed := args.len > 2 && args[2].bool_data
	return missing_formula_spec_reason_value(missing_formula_mac.mac_missing_formula_suggest_command(name, command, missing_formula_spec_cask(name, installed)))
}

// Ruby let `let(:name) { "local-caffeine" }` at line 149.
pub fn ruby_missing_formula_spec_l149_d31_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('local-caffeine')
}

// Ruby let `let(:command) { "install" }` at line 150.
pub fn ruby_missing_formula_spec_l150_d32_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('install')
}

// Ruby specify `specify(:aggregate_failures) do` at line 152.
pub fn ruby_missing_formula_spec_l152_d33_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	reason := ruby_missing_formula_spec_l146_d30_reason().as_string()
	return missing_formula_spec_bool(reason.contains('Found a cask named "local-caffeine" instead.') && reason.contains('Try\n  brew install --cask local-caffeine'))
}

// Ruby let `let(:name) { "local-caffeine" }` at line 159.
pub fn ruby_missing_formula_spec_l159_d34_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('local-caffeine')
}

// Ruby let `let(:command) { "uninstall" }` at line 160.
pub fn ruby_missing_formula_spec_l160_d35_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('uninstall')
}

// Ruby it `it { is_expected.to be_nil }` at line 162.
pub fn ruby_missing_formula_spec_l162_d36_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return missing_formula_spec_bool(ruby_missing_formula_spec_l146_d30_reason(ruby_missing_formula_spec_l159_d34_name(), ruby_missing_formula_spec_l160_d35_command()).type_name == 'NilClass')
}

// Ruby specify `specify(:aggregate_failures) do` at line 169.
pub fn ruby_missing_formula_spec_l169_d37_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	reason := ruby_missing_formula_spec_l146_d30_reason(ruby_missing_formula_spec_l159_d34_name(), ruby_missing_formula_spec_l160_d35_command(), brew_runtime.bool_value(true)).as_string()
	return missing_formula_spec_bool(reason.contains('Found a cask named "local-caffeine" instead.') && reason.contains('Try\n  brew uninstall --cask local-caffeine'))
}

// Ruby let `let(:name) { "local-caffeine" }` at line 177.
pub fn ruby_missing_formula_spec_l177_d38_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('local-caffeine')
}

// Ruby let `let(:command) { "info" }` at line 178.
pub fn ruby_missing_formula_spec_l178_d39_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('info')
}

// Ruby specify `specify(:aggregate_failures) do` at line 180.
pub fn ruby_missing_formula_spec_l180_d40_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	reason := ruby_missing_formula_spec_l146_d30_reason(ruby_missing_formula_spec_l177_d38_name(), ruby_missing_formula_spec_l178_d39_command()).as_string()
	return missing_formula_spec_bool(reason.contains('Found a cask named "local-caffeine" instead.') && reason.contains('local-caffeine: 1.2.3'))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "missing_formula"
// 5:
// 6: RSpec.describe Homebrew::MissingFormula do
// 7:   describe "::reason" do
// 8:     subject { described_class.reason("gem") }
// 9:
// 10:     it { is_expected.not_to be_nil }
// 11:   end
// 12:
// 13:   describe "::disallowed_reason" do
// 14:     matcher :disallow do |name|
// 15:       match do |expected|
// 16:         expected.disallowed_reason(name)
// 17:       end
// 18:     end
// 19:
// 20:     specify(:aggregate_failures) do
// 21:       expect(described_class).to disallow("gem")
// 22:       expect(described_class).to disallow("pip")
// 23:       expect(described_class).to disallow("pil")
// 24:       expect(described_class).to disallow("macruby")
// 25:       expect(described_class).to disallow("lzma")
// 26:       expect(described_class).to disallow("gsutil")
// 27:       expect(described_class).to disallow("gfortran")
// 28:       expect(described_class).to disallow("play")
// 29:       expect(described_class).to disallow("haskell-platform")
// 30:       expect(described_class).to disallow("mysqldump-secure")
// 31:       expect(described_class).to disallow("ngrok")
// 32:     end
// 33:
// 34:     it("disallows Xcode", :needs_macos) { is_expected.to disallow("xcode") }
// 35:   end
// 36:
// 37:   describe "::tap_migration_reason" do
// 38:     subject(:reason) { described_class.tap_migration_reason(formula) }
// 39:
// 40:     let(:migration_target) { "homebrew/bar" }
// 41:
// 42:     before do
// 43:       tap_path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo"
// 44:       tap_path.mkpath
// 45:       (tap_path/"tap_migrations.json").write <<~JSON
// 46:         { "migrated-formula": "#{migration_target}" }
// 47:       JSON
// 48:     end
// 49:
// 50:     context "with a migrated formula" do
// 51:       let(:formula) { "migrated-formula" }
// 52:
// 53:       it { is_expected.not_to be_nil }
// 54:     end
// 55:
// 56:     context "with a missing formula" do
// 57:       let(:formula) { "missing-formula" }
// 58:
// 59:       it { is_expected.to be_nil }
// 60:     end
// 61:
// 62:     context "with a same-tap renamed formula" do
// 63:       let(:formula) { "migrated-formula" }
// 64:       let(:migration_target) { "renamed-formula" }
// 65:
// 66:       specify(:aggregate_failures) do
// 67:         expect(reason).to include("brew install renamed-formula")
// 68:         expect(reason).not_to include("brew tap")
// 69:       end
// 70:     end
// 71:   end
// 72:
// 73:   describe "::deleted_reason" do
// 74:     subject { described_class.deleted_reason(formula, silent: true) }
// 75:
// 76:     before do
// 77:       tap_path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo"
// 78:       (tap_path/"Formula").mkpath
// 79:       (tap_path/"Formula/deleted-formula.rb").write "placeholder"
// 80:       ENV.delete "GIT_AUTHOR_DATE"
// 81:       ENV.delete "GIT_COMMITTER_DATE"
// 82:
// 83:       tap_path.cd do
// 84:         system "git", "init"
// 85:         system "git", "add", "--all"
// 86:         system "git", "commit", "-m", "initial state"
// 87:         system "git", "rm", "Formula/deleted-formula.rb"
// 88:         system "git", "commit", "-m", "delete formula 'deleted-formula'"
// 89:       end
// 90:     end
// 91:
// 92:     shared_examples "it detects deleted formulae" do
// 93:       context "with a deleted formula" do
// 94:         let(:formula) { "homebrew/foo/deleted-formula" }
// 95:
// 96:         it { is_expected.not_to be_nil }
// 97:       end
// 98:
// 99:       context "with a formula that never existed" do
// 100:         let(:formula) { "homebrew/foo/missing-formula" }
// 101:
// 102:         it { is_expected.to be_nil }
// 103:       end
// 104:     end
// 105:
// 106:     include_examples "it detects deleted formulae"
// 107:
// 108:     describe "on the core tap" do
// 109:       before do
// 110:         allow_any_instance_of(Tap).to receive(:core_tap?).and_return(true)
// 111:       end
// 112:
// 113:       include_examples "it detects deleted formulae"
// 114:     end
// 115:   end
// 116:
// 117:   describe "::cask_reason", :cask do
// 118:     subject(:reason) { described_class.cask_reason(formula, show_info:) }
// 119:
// 120:     context "with a formula name that is a cask and show_info: false" do
// 121:       let(:formula) { "local-caffeine" }
// 122:       let(:show_info) { false }
// 123:
// 124:       specify(:aggregate_failures) do
// 125:         expect(reason).to match(/Found a cask named "local-caffeine" instead./)
// 126:         expect(reason).to match(/Try\n  brew install --cask local-caffeine/)
// 127:       end
// 128:     end
// 129:
// 130:     context "with a formula name that is a cask and show_info: true" do
// 131:       let(:formula) { "local-caffeine" }
// 132:       let(:show_info) { true }
// 133:
// 134:       it { is_expected.to match(/Found a cask named "local-caffeine" instead.\n\n==> local-caffeine: 1.2.3\n/) }
// 135:     end
// 136:
// 137:     context "with a formula name that is not a cask" do
// 138:       let(:formula) { "missing-formula" }
// 139:       let(:show_info) { false }
// 140:
// 141:       it { is_expected.to be_nil }
// 142:     end
// 143:   end
// 144:
// 145:   describe "::suggest_command", :cask do
// 146:     subject(:reason) { described_class.suggest_command(name, command) }
// 147:
// 148:     context "when installing" do
// 149:       let(:name) { "local-caffeine" }
// 150:       let(:command) { "install" }
// 151:
// 152:       specify(:aggregate_failures) do
// 153:         expect(reason).to match(/Found a cask named "local-caffeine" instead./)
// 154:         expect(reason).to match(/Try\n  brew install --cask local-caffeine/)
// 155:       end
// 156:     end
// 157:
// 158:     context "when uninstalling" do
// 159:       let(:name) { "local-caffeine" }
// 160:       let(:command) { "uninstall" }
// 161:
// 162:       it { is_expected.to be_nil }
// 163:
// 164:       context "with described cask installed" do
// 165:         before do
// 166:           allow(Cask::Caskroom).to receive(:casks).and_return(["local-caffeine"])
// 167:         end
// 168:
// 169:         specify(:aggregate_failures) do
// 170:           expect(reason).to match(/Found a cask named "local-caffeine" instead./)
// 171:           expect(reason).to match(/Try\n  brew uninstall --cask local-caffeine/)
// 172:         end
// 173:       end
// 174:     end
// 175:
// 176:     context "when getting info" do
// 177:       let(:name) { "local-caffeine" }
// 178:       let(:command) { "info" }
// 179:
// 180:       specify(:aggregate_failures) do
// 181:         expect(reason).to match(/Found a cask named "local-caffeine" instead./)
// 182:         expect(reason).to match(/local-caffeine: 1.2.3/)
// 183:       end
// 184:     end
// 185:   end
// 186: end
