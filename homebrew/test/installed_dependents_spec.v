module test

import homebrew

// Translated from Homebrew/brew `test/installed_dependents_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn installed_dependents_spec_dependency(name string) homebrew.InstalledDependentDependency {
	return homebrew.InstalledDependentDependency{
		full_name: name
	}
}

fn installed_dependents_spec_keg(name string, version string, optlinked bool) homebrew.InstalledDependentKeg {
	return homebrew.InstalledDependentKeg{
		id: '${name}/${version}'
		name: name
		version: version
		optlinked: optlinked
		formula_resolved: true
		formula_name: name
		formula_tap: 'homebrew/core'
		tab_tap: 'homebrew/core'
	}
}

fn installed_dependents_spec_formula(name string,
	dependencies []homebrew.InstalledDependentDependency, has_dependencies bool,
	reliable bool) homebrew.InstalledDependentFormula {
	return homebrew.InstalledDependentFormula{
		name: name
		tap: 'homebrew/core'
		display_name: name
		runtime_dependencies: dependencies.clone()
		has_runtime_dependencies: has_dependencies
		reliable_tab: reliable
	}
}

fn installed_dependents_spec_is_nil(context homebrew.InstalledDependentsContext) bool {
	_ := homebrew.find_some_installed_dependents(context) or { return true }
	return false
}

fn installed_dependents_spec_matches(context homebrew.InstalledDependentsContext,
	keg_ids []string, dependents []string) bool {
	result := homebrew.find_some_installed_dependents(context) or { return false }
	return result.required_kegs.map(it.id) == keg_ids && result.dependents == dependents
}

// Ruby let! `let!(:keg) { setup_test_keg("foo", "1.0") }` at line 7.
pub fn ruby_installed_dependents_spec_l7_d1_keg() homebrew.InstalledDependentKeg {
	return installed_dependents_spec_keg('foo', '1.0', true)
}

// Ruby let! `let!(:keg_only_keg) do` at line 8.
pub fn ruby_installed_dependents_spec_l8_d2_keg_only_keg() homebrew.InstalledDependentKeg {
	return installed_dependents_spec_keg('foo-keg-only', '1.0', true)
}

// Ruby method `stub_formula(name, version = "1.0", &block)` at line 16.
pub fn ruby_installed_dependents_spec_l16_d3_stub_formula(name string, version string) homebrew.InstalledDependentFormula {
	_ = version
	return installed_dependents_spec_formula(name, [], true, true)
}

// Ruby method `setup_test_keg(name, version, &block)` at line 28.
pub fn ruby_installed_dependents_spec_l28_d4_setup_test_keg(name string, version string) homebrew.InstalledDependentKeg {
	return installed_dependents_spec_keg(name, version, false)
}

// Ruby method `setup_test_keg(name, version, &block)` at line 44.
pub fn ruby_installed_dependents_spec_l44_d5_setup_test_keg(name string, version string) homebrew.InstalledDependentKeg {
	return installed_dependents_spec_keg(name, version, false)
}

// Ruby method `alter_tab(keg)` at line 79.
pub fn ruby_installed_dependents_spec_l79_d6_alter_tab(formula homebrew.InstalledDependentFormula,
	dependencies []homebrew.InstalledDependentDependency, has_dependencies bool,
	reliable bool) homebrew.InstalledDependentFormula {
	return homebrew.InstalledDependentFormula{
		...formula
		runtime_dependencies: dependencies.clone()
		has_runtime_dependencies: has_dependencies
		reliable_tab: reliable
	}
}

// Ruby method `tab_dependencies(keg, deps, homebrew_version: "1.1.6")` at line 87.
pub fn ruby_installed_dependents_spec_l87_d7_tab_dependencies(formula homebrew.InstalledDependentFormula,
	dependencies []homebrew.InstalledDependentDependency, homebrew_version string) homebrew.InstalledDependentFormula {
	current := homebrew.new_version(homebrew_version) or { return formula }
	minimum := homebrew.new_version('1.1.6') or { return formula }
	return ruby_installed_dependents_spec_l79_d6_alter_tab(formula, dependencies, true, current.compare_to(minimum) >= 0)
}

// Ruby method `unreliable_tab_dependencies(keg, deps)` at line 95.
pub fn ruby_installed_dependents_spec_l95_d8_unreliable_tab_dependencies(formula homebrew.InstalledDependentFormula,
	dependencies []homebrew.InstalledDependentDependency) homebrew.InstalledDependentFormula {
	return ruby_installed_dependents_spec_l87_d7_tab_dependencies(formula, dependencies, '1.1.5')
}

// Ruby specify `specify "a dependency with no Tap in Tab" do` at line 101.
pub fn ruby_installed_dependents_spec_l101_d9_a() bool {
	foo := ruby_installed_dependents_spec_l7_d1_keg()
	baz := installed_dependents_spec_keg('baz', '1.0', true)
	dependent := installed_dependents_spec_formula('bar', [], false, true)
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [foo, baz]
		installed_formulae: [dependent]
	})
}

// Ruby specify `specify "no dependencies anywhere" do` at line 121.
pub fn ruby_installed_dependents_spec_l121_d10_no() bool {
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_formulae: [
			installed_dependents_spec_formula('bar', [], false, true),
		]
	})
}

// Ruby specify `specify "nil tab does not fall back to formula definitions" do` at line 127.
pub fn ruby_installed_dependents_spec_l127_d11_nil() bool {
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_formulae: [
			installed_dependents_spec_formula('bar', [], false, true),
		]
	})
}

// Ruby specify `specify "uninstalling dependent and dependency" do` at line 137.
pub fn ruby_installed_dependents_spec_l137_d12_uninstalling() bool {
	foo := ruby_installed_dependents_spec_l7_d1_keg()
	bar := installed_dependents_spec_keg('bar', '1.0', true)
	dependent := installed_dependents_spec_formula('bar', [
		installed_dependents_spec_dependency('foo'),
	], true, true)
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [foo, bar]
		installed_formulae: [dependent]
	})
}

// Ruby specify `specify "renamed dependency with nil tab" do` at line 145.
pub fn ruby_installed_dependents_spec_l145_d13_renamed() bool {
	renamed := homebrew.InstalledDependentKeg{
		...ruby_installed_dependents_spec_l7_d1_keg()
		id: 'foo-old/1.0'
		name: 'foo-old'
		formula_name: 'foo'
	}
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [renamed]
		installed_formulae: [
			installed_dependents_spec_formula('bar', [], false, true),
		]
	})
}

// Ruby specify `specify "renamed dependency with tab data" do` at line 161.
pub fn ruby_installed_dependents_spec_l161_d14_renamed() bool {
	renamed := homebrew.InstalledDependentKeg{
		...ruby_installed_dependents_spec_l7_d1_keg()
		id: 'foo-old/1.0'
		name: 'foo-old'
		formula_name: 'foo'
	}
	dependent := installed_dependents_spec_formula('bar', [
		installed_dependents_spec_dependency('foo'),
	], true, true)
	return installed_dependents_spec_matches(homebrew.InstalledDependentsContext{
		kegs: [renamed]
		installed_formulae: [dependent]
	}, ['foo-old/1.0'], ['bar'])
}

// Ruby specify `specify "empty dependencies in Tab" do` at line 176.
pub fn ruby_installed_dependents_spec_l176_d15_empty() bool {
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_formulae: [installed_dependents_spec_formula('bar', [], true, true)]
	})
}

// Ruby specify `specify "same name but different version in Tab" do` at line 182.
pub fn ruby_installed_dependents_spec_l182_d16_same() bool {
	dependent := installed_dependents_spec_formula('bar', [
		installed_dependents_spec_dependency('foo'),
	], true, true)
	return installed_dependents_spec_matches(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_formulae: [dependent]
	}, ['foo/1.0'], ['bar'])
}

// Ruby specify `specify "different name and same version in Tab" do` at line 188.
pub fn ruby_installed_dependents_spec_l188_d17_different() bool {
	dependent := installed_dependents_spec_formula('bar', [
		installed_dependents_spec_dependency('baz'),
	], true, true)
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_formulae: [dependent]
	})
}

// Ruby specify `specify "same name and version in Tab" do` at line 195.
pub fn ruby_installed_dependents_spec_l195_d18_same() bool {
	dependent := installed_dependents_spec_formula('bar', [
		installed_dependents_spec_dependency('foo'),
	], true, true)
	return installed_dependents_spec_matches(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_formulae: [dependent]
	}, ['foo/1.0'], ['bar'])
}

// Ruby specify `specify "old tab version returns nil dependencies and does not block" do` at line 201.
pub fn ruby_installed_dependents_spec_l201_d19_old() bool {
	base := installed_dependents_spec_formula('bar', [], true, true)
	dependent := ruby_installed_dependents_spec_l95_d8_unreliable_tab_dependencies(base, [
		installed_dependents_spec_dependency('baz'),
	])
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_formulae: [dependent]
	})
}

// Ruby specify `specify "non-opt-linked" do` at line 211.
pub fn ruby_installed_dependents_spec_l211_d20_non_opt_linked() bool {
	foo := installed_dependents_spec_keg('foo', '1.0', false)
	dependent := installed_dependents_spec_formula('bar', [
		installed_dependents_spec_dependency('foo'),
	], true, true)
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [foo]
		installed_formulae: [dependent]
	})
}

// Ruby specify `specify "keg-only" do` at line 218.
pub fn ruby_installed_dependents_spec_l218_d21_keg_only() bool {
	dependent := installed_dependents_spec_formula('bar', [
		installed_dependents_spec_dependency('foo-keg-only'),
	], true, true)
	return installed_dependents_spec_matches(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l8_d2_keg_only_keg()]
		installed_formulae: [dependent]
	}, ['foo-keg-only/1.0'], ['bar'])
}

// Ruby method `stub_cask_name(name, version, dependency)` at line 224.
pub fn ruby_installed_dependents_spec_l224_d22_stub_cask_name(name string, version string,
	dependency string) homebrew.InstalledDependentCask {
	_ = version
	return homebrew.InstalledDependentCask{
		token: name
		display_name: name
		runtime_dependencies: [installed_dependents_spec_dependency(dependency)]
	}
}

// Ruby method `setup_test_cask(name, version, dependency)` at line 238.
pub fn ruby_installed_dependents_spec_l238_d23_setup_test_cask(name string, version string,
	dependency string) homebrew.InstalledDependentCask {
	return ruby_installed_dependents_spec_l224_d22_stub_cask_name(name, version, dependency)
}

// Ruby specify `specify "stale tab without dependency does not block uninstall" do` at line 252.
pub fn ruby_installed_dependents_spec_l252_d24_stale() bool {
	dependent := installed_dependents_spec_formula('bar', [
		installed_dependents_spec_dependency('baz'),
	], true, true)
	return installed_dependents_spec_is_nil(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_formulae: [dependent]
	})
}

// Ruby specify `specify "tab with dependency blocks uninstall" do` at line 264.
pub fn ruby_installed_dependents_spec_l264_d25_tab() bool {
	dependent := installed_dependents_spec_formula('bar', [
		installed_dependents_spec_dependency('foo'),
	], true, true)
	return installed_dependents_spec_matches(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_formulae: [dependent]
	}, ['foo/1.0'], ['bar'])
}

// Ruby specify `specify "identify dependent casks" do` at line 273.
pub fn ruby_installed_dependents_spec_l273_d26_identify() bool {
	cask := ruby_installed_dependents_spec_l238_d23_setup_test_cask('qux', '1.0.0', 'foo')
	return installed_dependents_spec_matches(homebrew.InstalledDependentsContext{
		kegs: [ruby_installed_dependents_spec_l7_d1_keg()]
		installed_casks: [cask]
	}, ['foo/1.0'], ['qux'])
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "installed_dependents"
// 5:
// 6: RSpec.describe InstalledDependents do
// 7:   let!(:keg) { setup_test_keg("foo", "1.0") }
// 8:   let!(:keg_only_keg) do
// 9:     setup_test_keg("foo-keg-only", "1.0") do
// 10:       keg_only "a good reason"
// 11:     end
// 12:   end
// 13:
// 14:   include FileUtils
// 15:
// 16:   def stub_formula(name, version = "1.0", &block)
// 17:     f = formula(name) do
// 18:       T.bind(self, T.class_of(Formula))
// 19:       url "#{name}-#{version}"
// 20:
// 21:       instance_eval(&block) if block
// 22:     end
// 23:     stub_formula_loader f
// 24:     stub_formula_loader f, "homebrew/core/#{f}"
// 25:     f
// 26:   end
// 27:
// 28:   def setup_test_keg(name, version, &block)
// 29:     stub_formula("gcc")
// 30:     stub_formula("glibc")
// 31:     stub_formula(name, version, &block)
// 32:
// 33:     path = HOMEBREW_CELLAR/name/version
// 34:     (path/"bin").mkpath
// 35:
// 36:     %w[hiworld helloworld goodbye_cruel_world].each do |file|
// 37:       touch path/"bin"/file
// 38:     end
// 39:
// 40:     Keg.new(path)
// 41:   end
// 42:
// 43:   describe "::find_some_installed_dependents" do
// 44:     def setup_test_keg(name, version, &block)
// 45:       keg = super
// 46:       tab = Tab.new(
// 47:         homebrew_version:         HOMEBREW_VERSION,
// 48:         installed_on_request:     false,
// 49:         loaded_from_api:          false,
// 50:         loaded_from_internal_api: false,
// 51:         source:                   {
// 52:           "path"         => nil,
// 53:           "tap"          => "homebrew/core",
// 54:           "tap_git_head" => nil,
// 55:           "spec"         => "stable",
// 56:           "versions"     => {
// 57:             "stable"                => version,
// 58:             "head"                  => nil,
// 59:             "version_scheme"        => 0,
// 60:             "compatibility_version" => nil,
// 61:           },
// 62:         },
// 63:         built_on:                 {},
// 64:       )
// 65:       tab.tabfile = keg/AbstractTab::FILENAME
// 66:       tab.stdlib = :libcxx
// 67:       tab.compiler = DevelopmentTools.default_compiler
// 68:       tab.aliases = []
// 69:       tab.runtime_dependencies = []
// 70:       tab.write
// 71:       keg
// 72:     end
// 73:
// 74:     before do
// 75:       keg.link
// 76:       keg_only_keg.optlink
// 77:     end
// 78:
// 79:     def alter_tab(keg)
// 80:       tab = keg.tab
// 81:       yield tab
// 82:       tab.write
// 83:     end
// 84:
// 85:     # 1.1.6 is the earliest version of Homebrew that generates correct runtime
// 86:     # dependency lists in {Tab}s.
// 87:     def tab_dependencies(keg, deps, homebrew_version: "1.1.6")
// 88:       alter_tab(keg) do |tab|
// 89:         tab.homebrew_version = homebrew_version
// 90:         tab.tabfile = keg/AbstractTab::FILENAME
// 91:         tab.runtime_dependencies = deps
// 92:       end
// 93:     end
// 94:
// 95:     def unreliable_tab_dependencies(keg, deps)
// 96:       # 1.1.5 is (hopefully!) the last version of Homebrew that generates
// 97:       # incorrect runtime dependency lists in {Tab}s.
// 98:       tab_dependencies(keg, deps, homebrew_version: "1.1.5")
// 99:     end
// 100:
// 101:     specify "a dependency with no Tap in Tab" do
// 102:       tap_dep = setup_test_keg("baz", "1.0")
// 103:       dependent = setup_test_keg("bar", "1.0") do
// 104:         depends_on "foo"
// 105:         depends_on "baz"
// 106:       end
// 107:
// 108:       # allow tap_dep to be linked too
// 109:       FileUtils.rm_r tap_dep/"bin"
// 110:       tap_dep.link
// 111:
// 112:       alter_tab(keg) { |t| t.source["tap"] = nil }
// 113:
// 114:       # nil tab means no known dependencies — don't fall back to formula definitions
// 115:       tab_dependencies dependent, nil
// 116:
// 117:       result = described_class.find_some_installed_dependents([keg, tap_dep])
// 118:       expect(result).to be_nil
// 119:     end
// 120:
// 121:     specify "no dependencies anywhere" do
// 122:       dependent = setup_test_keg("bar", "1.0")
// 123:       tab_dependencies dependent, nil
// 124:       expect(described_class.find_some_installed_dependents([keg])).to be_nil
// 125:     end
// 126:
// 127:     specify "nil tab does not fall back to formula definitions" do
// 128:       dependent = setup_test_keg("bar", "1.0") do
// 129:         depends_on "foo"
// 130:       end
// 131:       # Tab has nil runtime_dependencies — should not fall back to the
// 132:       # formula definition's depends_on, so uninstalling foo is allowed.
// 133:       tab_dependencies dependent, nil
// 134:       expect(described_class.find_some_installed_dependents([keg])).to be_nil
// 135:     end
// 136:
// 137:     specify "uninstalling dependent and dependency" do
// 138:       dependent = setup_test_keg("bar", "1.0") do
// 139:         depends_on "foo"
// 140:       end
// 141:       tab_dependencies dependent, nil
// 142:       expect(described_class.find_some_installed_dependents([keg, dependent])).to be_nil
// 143:     end
// 144:
// 145:     specify "renamed dependency with nil tab" do
// 146:       dependent = setup_test_keg("bar", "1.0") do
// 147:         depends_on "foo"
// 148:       end
// 149:       # nil tab — no known dependencies, even though formula DSL says depends_on "foo"
// 150:       tab_dependencies dependent, nil
// 151:
// 152:       stub_formula_loader Formula["foo"], "homebrew/core/foo-old"
// 153:       renamed_path = HOMEBREW_CELLAR/"foo-old"
// 154:       (HOMEBREW_CELLAR/"foo").rename(renamed_path)
// 155:       renamed_keg = Keg.new(renamed_path/keg.version.to_s)
// 156:
// 157:       result = described_class.find_some_installed_dependents([renamed_keg])
// 158:       expect(result).to be_nil
// 159:     end
// 160:
// 161:     specify "renamed dependency with tab data" do
// 162:       dependent = setup_test_keg("bar", "1.0") do
// 163:         depends_on "foo"
// 164:       end
// 165:       tab_dependencies dependent, [{ "full_name" => "foo", "version" => "1.0" }]
// 166:
// 167:       stub_formula_loader Formula["foo"], "homebrew/core/foo-old"
// 168:       renamed_path = HOMEBREW_CELLAR/"foo-old"
// 169:       (HOMEBREW_CELLAR/"foo").rename(renamed_path)
// 170:       renamed_keg = Keg.new(renamed_path/keg.version.to_s)
// 171:
// 172:       result = described_class.find_some_installed_dependents([renamed_keg])
// 173:       expect(result).to eq([[renamed_keg], ["bar"]])
// 174:     end
// 175:
// 176:     specify "empty dependencies in Tab" do
// 177:       dependent = setup_test_keg("bar", "1.0")
// 178:       tab_dependencies dependent, []
// 179:       expect(described_class.find_some_installed_dependents([keg])).to be_nil
// 180:     end
// 181:
// 182:     specify "same name but different version in Tab" do
// 183:       dependent = setup_test_keg("bar", "1.0")
// 184:       tab_dependencies dependent, [{ "full_name" => keg.name, "version" => "1.1" }]
// 185:       expect(described_class.find_some_installed_dependents([keg])).to eq([[keg], ["bar"]])
// 186:     end
// 187:
// 188:     specify "different name and same version in Tab" do
// 189:       stub_formula("baz")
// 190:       dependent = setup_test_keg("bar", "1.0")
// 191:       tab_dependencies dependent, [{ "full_name" => "baz", "version" => keg.version.to_s }]
// 192:       expect(described_class.find_some_installed_dependents([keg])).to be_nil
// 193:     end
// 194:
// 195:     specify "same name and version in Tab" do
// 196:       dependent = setup_test_keg("bar", "1.0")
// 197:       tab_dependencies dependent, [{ "full_name" => keg.name, "version" => keg.version.to_s }]
// 198:       expect(described_class.find_some_installed_dependents([keg])).to eq([[keg], ["bar"]])
// 199:     end
// 200:
// 201:     specify "old tab version returns nil dependencies and does not block" do
// 202:       dependent = setup_test_keg("bar", "1.0") do
// 203:         depends_on "foo"
// 204:       end
// 205:       # Tab from Homebrew < 1.1.6 is unreliable; runtime_dependencies returns nil.
// 206:       # With tab-only trust, nil means no known deps — uninstall is allowed.
// 207:       unreliable_tab_dependencies dependent, [{ "full_name" => "baz", "version" => "1.0" }]
// 208:       expect(described_class.find_some_installed_dependents([keg])).to be_nil
// 209:     end
// 210:
// 211:     specify "non-opt-linked" do
// 212:       keg.remove_opt_record
// 213:       dependent = setup_test_keg("bar", "1.0")
// 214:       tab_dependencies dependent, [{ "full_name" => keg.name, "version" => keg.version.to_s }]
// 215:       expect(described_class.find_some_installed_dependents([keg])).to be_nil
// 216:     end
// 217:
// 218:     specify "keg-only" do
// 219:       dependent = setup_test_keg("bar", "1.0")
// 220:       tab_dependencies dependent, [{ "full_name" => keg_only_keg.name, "version" => "1.1" }] # different version
// 221:       expect(described_class.find_some_installed_dependents([keg_only_keg])).to eq([[keg_only_keg], ["bar"]])
// 222:     end
// 223:
// 224:     def stub_cask_name(name, version, dependency)
// 225:       c = Cask::CaskLoader.load(<<-RUBY)
// 226:         cask "#{name}" do
// 227:           version "#{version}"
// 228:
// 229:           url "c-1"
// 230:           depends_on formula: "#{dependency}"
// 231:         end
// 232:       RUBY
// 233:
// 234:       stub_cask_loader c
// 235:       c
// 236:     end
// 237:
// 238:     def setup_test_cask(name, version, dependency)
// 239:       c = stub_cask_name(name, version, dependency)
// 240:       Cask::Caskroom.path.join(name, c.version).mkpath
// 241:       Cask::Caskroom.path.join(name, ".metadata", c.version, "0", "Casks").tap(&:mkpath)
// 242:                     .join("#{name}.rb").open("w") do |caskfile|
// 243:                       caskfile.puts <<~RUBY
// 244:                         cask "#{name}" do
// 245:                           version "#{version}"
// 246:                         end
// 247:                       RUBY
// 248:                     end
// 249:       c
// 250:     end
// 251:
// 252:     specify "stale tab without dependency does not block uninstall" do
// 253:       # Formula definition says bar depends on foo, but the tab only
// 254:       # records baz — foo should not block uninstall because we trust
// 255:       # the tab over the formula definition.
// 256:       stub_formula("baz")
// 257:       dependent = setup_test_keg("bar", "1.0") do
// 258:         depends_on "foo"
// 259:       end
// 260:       tab_dependencies dependent, [{ "full_name" => "baz", "version" => "1.0" }]
// 261:       expect(described_class.find_some_installed_dependents([keg])).to be_nil
// 262:     end
// 263:
// 264:     specify "tab with dependency blocks uninstall" do
// 265:       # Tab records that bar depends on foo — foo should block uninstall.
// 266:       dependent = setup_test_keg("bar", "1.0") do
// 267:         depends_on "foo"
// 268:       end
// 269:       tab_dependencies dependent, [{ "full_name" => "foo", "version" => "1.0" }]
// 270:       expect(described_class.find_some_installed_dependents([keg])).to eq([[keg], ["bar"]])
// 271:     end
// 272:
// 273:     specify "identify dependent casks" do
// 274:       setup_test_cask("qux", "1.0.0", "foo")
// 275:       dependents = described_class.find_some_installed_dependents([keg]).last
// 276:       expect(dependents.include?("qux")).to be(true)
// 277:     end
// 278:   end
// 279: end
