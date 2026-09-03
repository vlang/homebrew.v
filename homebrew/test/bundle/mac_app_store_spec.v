module bundle

import brew_runtime
import homebrew.bundle.extensions

// Translated from Homebrew/brew `test/bundle/mac_app_store_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:dumper) { described_class }` at line 10.
pub fn ruby_mac_app_store_spec_l10_d1_dumper(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Homebrew::Bundle::MacAppStore', 'Homebrew::Bundle::MacAppStore')
}

// Ruby specify `specify do` at line 18.
pub fn ruby_mac_app_store_spec_l18_d2_do(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{}
	return brew_runtime.bool_value(extensions.mac_app_store_apps(mut state).len == 0 && extensions.mac_app_store_dump(mut state) == '')
}

// Ruby specify `specify do` at line 31.
pub fn ruby_mac_app_store_spec_l31_d3_do(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ executable: 'mas' }
	return brew_runtime.bool_value(extensions.mac_app_store_apps(mut state).len == 0 && extensions.mac_app_store_dump(mut state) == '')
}

// Ruby it `it "returns list %w[foo bar baz]" do` at line 48.
pub fn ruby_mac_app_store_spec_l48_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ executable: 'mas', list_output: '123 foo (1.0)\n456 bar (2.0)\n789 baz (3.0)' }
	return brew_runtime.bool_value(extensions.mac_app_store_apps(mut state) == [
		extensions.MacAppStoreApp{ id: '123', name: 'foo' },
		extensions.MacAppStoreApp{ id: '456', name: 'bar' },
		extensions.MacAppStoreApp{ id: '789', name: 'baz' },
	])
}

// Ruby it `it "returns list %w[foo bar baz qux]" do` at line 61.
pub fn ruby_mac_app_store_spec_l61_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ executable: 'mas', list_output: '123 foo (1.0)\n456 bar (2.0)\n789 baz (3.0)\n 10 qux (4.0)' }
	return brew_runtime.bool_value(extensions.mac_app_store_apps(mut state).map(it.name) == [
		'foo',
		'bar',
		'baz',
		'qux',
	])
}

// Ruby let `let(:invalid_mas_output) do` at line 67.
pub fn ruby_mac_app_store_spec_l67_d6_invalid_mas_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(mac_app_store_spec_invalid_output())
}

// Ruby let `let(:expected_app_details_array) do` at line 91.
pub fn ruby_mac_app_store_spec_l91_d7_expected_app_details_array(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(mac_app_store_spec_expected_apps().map(brew_runtime.string_array_value([
		it.id,
		it.name,
	])))
}

// Ruby let `let(:expected_mas_dumped_output) do` at line 115.
pub fn ruby_mac_app_store_spec_l115_d8_expected_mas_dumped_output(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ executable: 'mas', list_output: mac_app_store_spec_invalid_output() }
	return brew_runtime.string_value(extensions.mac_app_store_dump(mut state))
}

// Ruby specify `specify do` at line 145.
pub fn ruby_mac_app_store_spec_l145_d9_do(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ executable: 'mas', list_output: mac_app_store_spec_invalid_output() }
	apps := extensions.mac_app_store_apps(mut state)
	dump_text := extensions.mac_app_store_dump(mut state)
	return brew_runtime.bool_value(apps == mac_app_store_spec_expected_apps() && dump_text == mac_app_store_spec_expected_dump())
}

// Ruby let `let(:new_mas_output) do` at line 152.
pub fn ruby_mac_app_store_spec_l152_d10_new_mas_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(mac_app_store_spec_new_output())
}

// Ruby let `let(:expected_app_details_array) do` at line 160.
pub fn ruby_mac_app_store_spec_l160_d11_expected_app_details_array(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(mac_app_store_spec_new_apps().map(brew_runtime.string_array_value([
		it.id,
		it.name,
	])))
}

// Ruby it `it "parses the app names without trailing whitespace" do` at line 174.
pub fn ruby_mac_app_store_spec_l174_d12_parses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(extensions.mac_app_store_parse_apps(mac_app_store_spec_new_output()) == mac_app_store_spec_new_apps())
}

// Ruby it `it "shells out" do` at line 189.
pub fn ruby_mac_app_store_spec_l189_d13_shells(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ executable: 'mas', list_output: '123 foo (1.0)' }
	return brew_runtime.bool_value(extensions.mac_app_store_installed_app_ids(mut state) == [
		'123',
	])
}

// Ruby it `it "returns result" do` at line 195.
pub fn ruby_mac_app_store_spec_l195_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{
		executable: 'mas'
		installed_app_ids: [
			'123',
			'456',
		]
		installed_ids_loaded: true
		outdated_app_ids: ['456']
		outdated_ids_loaded: true
	}
	return brew_runtime.bool_value(extensions.mac_app_store_app_id_installed_and_up_to_date(mut state, 123, false) && !extensions.mac_app_store_app_id_installed_and_up_to_date(mut state, 456, false))
}

// Ruby it `it "tries to install mas" do` at line 208.
pub fn ruby_mac_app_store_spec_l208_d15_tries(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ brew_file: '/brew', manager_install_succeeds: true }
	_ := extensions.mac_app_store_preinstall(mut state, 'foo', 123, false, false) or {
		return brew_runtime.bool_value(state.commands == [['/brew', 'install', 'mas']] && err.msg().contains('mas installation failed'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "does not shell out" do` at line 215.
pub fn ruby_mac_app_store_spec_l215_d16_does(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{}
	return brew_runtime.bool_value(extensions.mac_app_store_outdated_app_ids(mut state).len == 0)
}

// Ruby it `it "returns app ids" do` at line 229.
pub fn ruby_mac_app_store_spec_l229_d17_returns(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ executable: 'mas', outdated_output: 'foo 123' }
	return brew_runtime.bool_value(extensions.mac_app_store_outdated_app_ids(mut state) == [
		'foo',
	])
}

// Ruby it `it "skips" do` at line 241.
pub fn ruby_mac_app_store_spec_l241_d18_skips(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{
		executable: 'mas'
		installed_app_ids: [
			'123',
		]
		installed_ids_loaded: true
		outdated_ids_loaded: true
	}
	result := extensions.mac_app_store_preinstall(mut state, 'foo', 123, false, false) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!result && state.commands.len == 0)
}

// Ruby it `it "upgrades" do` at line 252.
pub fn ruby_mac_app_store_spec_l252_d19_upgrades(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{
		executable: 'mas'
		installed_app_ids: [
			'123',
		]
		installed_ids_loaded: true
		outdated_app_ids: ['123']
		outdated_ids_loaded: true
		upgrade_succeeds: true
	}
	preinstall := extensions.mac_app_store_preinstall(mut state, 'foo', 123, false, false) or { return brew_runtime.bool_value(false) }
	installed := extensions.mac_app_store_install(mut state, 'foo', 123, true, false) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(preinstall && installed && state.commands == [
		['mas', 'upgrade', '123'],
	])
}

// Ruby it `it "installs app" do` at line 265.
pub fn ruby_mac_app_store_spec_l265_d20_installs(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ executable: 'mas', installed_ids_loaded: true, install_succeeds: true }
	preinstall := extensions.mac_app_store_preinstall(mut state, 'foo', 123, false, false) or { return brew_runtime.bool_value(false) }
	installed := extensions.mac_app_store_install(mut state, 'foo', 123, true, false) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(preinstall && installed && state.commands == [
		['mas', 'install', '123'],
	])
}

// Ruby it `it "falls back to `mas get` when `mas install` fails" do` at line 272.
pub fn ruby_mac_app_store_spec_l272_d21_falls(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extensions.MacAppStoreState{ executable: 'mas', installed_ids_loaded: true, get_succeeds: true }
	preinstall := extensions.mac_app_store_preinstall(mut state, 'foo', 123, false, false) or { return brew_runtime.bool_value(false) }
	installed := extensions.mac_app_store_install(mut state, 'foo', 123, true, false) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(preinstall && installed && state.commands == [
		['mas', 'install', '123'],
		['mas', 'get', '123'],
	])
}

// Ruby it `it "returns apps not in Brewfile entries by ID" do` at line 294.
pub fn ruby_mac_app_store_spec_l294_d22_returns(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_spec_cleanup_state()
	entry := extensions.mac_app_store_entry('renamed foo', {
		'id': brew_runtime.int_value(123)
	}) or { return brew_runtime.bool_value(false) }
	items := extensions.mac_app_store_cleanup_items(mut state, [entry])
	if items.len != 1 {
		return brew_runtime.bool_value(false)
	}
	name := extensions.mac_app_store_cleanup_item_name(items[0]) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(name == 'bar (456)')
}

// Ruby it `it "uninstalls apps by ID" do` at line 301.
pub fn ruby_mac_app_store_spec_l301_d23_uninstalls(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_spec_cleanup_state()
	entry := extensions.mac_app_store_entry('foo', {
		'id': brew_runtime.int_value(123)
	}) or { return brew_runtime.bool_value(false) }
	items := extensions.mac_app_store_cleanup_items(mut state, [entry])
	extensions.mac_app_store_cleanup(mut state, items) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(state.commands == [['mas', 'uninstall', '456']] && state.output == [
		'Uninstalled 1 Mac App Store app',
	])
}

fn mac_app_store_spec_invalid_output() string {
	return '497799835 Xcode (9.2)\n425424353 The Unarchiver (4.0.0)\n08981434 iMovie (10.1.8)\n409201541 Pages (7.1)\n123456789 123AppNameWithNumbers (1.0)\n409203825 Numbers (5.1)\n944924917 Pastebin It! (1.0)\n123456789 My (cool) app (1.0)\n987654321 an-app-i-use (2.1)\n123457867 App name with many spaces (1.0)\n893489734 my,comma,app (2.2)\n832423434 another_app_name (1.0)\n543213432 My App? (1.0)\n688963445 app;with;semicolons (1.0)\n123345384 my 😊 app (2.0)\n896732467 你好 (1.1)\n634324555 مرحبا (1.0)\n234324325 áéíóú (1.0)\n310633997 non>‎<printing>⁣<characters (1.0)\n'
}

fn mac_app_store_spec_expected_apps() []extensions.MacAppStoreApp {
	return [extensions.MacAppStoreApp{ id: '497799835', name: 'Xcode' },
		extensions.MacAppStoreApp{ id: '425424353', name: 'The Unarchiver' },
		extensions.MacAppStoreApp{ id: '08981434', name: 'iMovie' },
		extensions.MacAppStoreApp{ id: '409201541', name: 'Pages' },
		extensions.MacAppStoreApp{ id: '123456789', name: '123AppNameWithNumbers' },
		extensions.MacAppStoreApp{ id: '409203825', name: 'Numbers' },
		extensions.MacAppStoreApp{ id: '944924917', name: 'Pastebin It!' },
		extensions.MacAppStoreApp{ id: '123456789', name: 'My (cool) app' },
		extensions.MacAppStoreApp{ id: '987654321', name: 'an-app-i-use' },
		extensions.MacAppStoreApp{ id: '123457867', name: 'App name with many spaces' },
		extensions.MacAppStoreApp{ id: '893489734', name: 'my,comma,app' },
		extensions.MacAppStoreApp{ id: '832423434', name: 'another_app_name' },
		extensions.MacAppStoreApp{ id: '543213432', name: 'My App?' },
		extensions.MacAppStoreApp{ id: '688963445', name: 'app;with;semicolons' },
		extensions.MacAppStoreApp{ id: '123345384', name: 'my 😊 app' },
		extensions.MacAppStoreApp{ id: '896732467', name: '你好' },
		extensions.MacAppStoreApp{ id: '634324555', name: 'مرحبا' },
		extensions.MacAppStoreApp{ id: '234324325', name: 'áéíóú' },
		extensions.MacAppStoreApp{ id: '310633997', name: 'non><printing><characters' }]
}

fn mac_app_store_spec_expected_dump() string {
	mut state := extensions.MacAppStoreState{ executable: 'mas', apps: mac_app_store_spec_expected_apps(), apps_loaded: true }
	return extensions.mac_app_store_dump(mut state)
}

fn mac_app_store_spec_new_output() string {
	return '1440147259  AdGuard for Safari  (1.9.13)\n497799835   Xcode               (12.5)\n425424353   The Unarchiver      (4.3.1)\n'
}

fn mac_app_store_spec_new_apps() []extensions.MacAppStoreApp {
	return [extensions.MacAppStoreApp{ id: '1440147259', name: 'AdGuard for Safari' },
		extensions.MacAppStoreApp{ id: '497799835', name: 'Xcode' },
		extensions.MacAppStoreApp{ id: '425424353', name: 'The Unarchiver' }]
}

fn mac_app_store_spec_cleanup_state() extensions.MacAppStoreState {
	return extensions.MacAppStoreState{
		executable: 'mas'
		packages: [
			extensions.MacAppStoreApp{ id: '123', name: 'foo' },
			extensions.MacAppStoreApp{ id: '456', name: 'bar' },
			extensions.MacAppStoreApp{ id: '0', name: 'testflight' },
		]
		packages_loaded: true
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions/mac_app_store"
// 7:
// 8: RSpec.describe Homebrew::Bundle::MacAppStore do
// 9:   describe "dumping" do
// 10:     subject(:dumper) { described_class }
// 11:
// 12:     context "when mas is not installed" do
// 13:       before do
// 14:         described_class.reset!
// 15:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 16:       end
// 17:
// 18:       specify do
// 19:         expect(dumper.apps).to be_empty
// 20:         expect(dumper.dump).to eql("")
// 21:       end
// 22:     end
// 23:
// 24:     context "when there is no apps" do
// 25:       before do
// 26:         described_class.reset!
// 27:         allow(described_class).to receive_messages(package_manager_executable: Pathname.new("mas"),
// 28:                                                    "`":                        "")
// 29:       end
// 30:
// 31:       specify do
// 32:         expect(dumper.apps).to be_empty
// 33:         expect(dumper.dump).to eql("")
// 34:       end
// 35:     end
// 36:
// 37:     context "when apps `foo`, `bar` and `baz` are installed" do
// 38:       before do
// 39:         described_class.reset!
// 40:         allow(described_class).to receive_messages(
// 41:           package_manager_executable: Pathname.new("mas"),
// 42:           "`":                        "123 foo (1.0)\n" \
// 43:                                       "456 bar (2.0)\n" \
// 44:                                       "789 baz (3.0)",
// 45:         )
// 46:       end
// 47:
// 48:       it "returns list %w[foo bar baz]" do
// 49:         expect(dumper.apps).to eql([["123", "foo"], ["456", "bar"], ["789", "baz"]])
// 50:       end
// 51:     end
// 52:
// 53:     context "when apps `foo`, `bar`, `baz` and `qux` are installed including right-justified IDs" do
// 54:       before do
// 55:         described_class.reset!
// 56:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("mas"))
// 57:         allow(described_class).to receive(:`).and_return("123 foo (1.0)\n456 bar (2.0)\n789 baz (3.0)")
// 58:         allow(described_class).to receive(:`).and_return("123 foo (1.0)\n456 bar (2.0)\n789 baz (3.0)\n 10 qux (4.0)")
// 59:       end
// 60:
// 61:       it "returns list %w[foo bar baz qux]" do
// 62:         expect(dumper.apps).to eql([["123", "foo"], ["456", "bar"], ["789", "baz"], ["10", "qux"]])
// 63:       end
// 64:     end
// 65:
// 66:     context "with invalid app details" do
// 67:       let(:invalid_mas_output) do
// 68:         <<~HEREDOC
// 69:           497799835 Xcode (9.2)
// 70:           425424353 The Unarchiver (4.0.0)
// 71:           08981434 iMovie (10.1.8)
// 72:           409201541 Pages (7.1)
// 73:           123456789 123AppNameWithNumbers (1.0)
// 74:           409203825 Numbers (5.1)
// 75:           944924917 Pastebin It! (1.0)
// 76:           123456789 My (cool) app (1.0)
// 77:           987654321 an-app-i-use (2.1)
// 78:           123457867 App name with many spaces (1.0)
// 79:           893489734 my,comma,app (2.2)
// 80:           832423434 another_app_name (1.0)
// 81:           543213432 My App? (1.0)
// 82:           688963445 app;with;semicolons (1.0)
// 83:           123345384 my 😊 app (2.0)
// 84:           896732467 你好 (1.1)
// 85:           634324555 مرحبا (1.0)
// 86:           234324325 áéíóú (1.0)
// 87:           310633997 non>‎<printing>⁣<characters (1.0)
// 88:         HEREDOC
// 89:       end
// 90:
// 91:       let(:expected_app_details_array) do
// 92:         [
// 93:           ["497799835", "Xcode"],
// 94:           ["425424353", "The Unarchiver"],
// 95:           ["08981434", "iMovie"],
// 96:           ["409201541", "Pages"],
// 97:           ["123456789", "123AppNameWithNumbers"],
// 98:           ["409203825", "Numbers"],
// 99:           ["944924917", "Pastebin It!"],
// 100:           ["123456789", "My (cool) app"],
// 101:           ["987654321", "an-app-i-use"],
// 102:           ["123457867", "App name with many spaces"],
// 103:           ["893489734", "my,comma,app"],
// 104:           ["832423434", "another_app_name"],
// 105:           ["543213432", "My App?"],
// 106:           ["688963445", "app;with;semicolons"],
// 107:           ["123345384", "my 😊 app"],
// 108:           ["896732467", "你好"],
// 109:           ["634324555", "مرحبا"],
// 110:           ["234324325", "áéíóú"],
// 111:           ["310633997", "non><printing><characters"],
// 112:         ]
// 113:       end
// 114:
// 115:       let(:expected_mas_dumped_output) do
// 116:         <<~HEREDOC
// 117:           mas "123AppNameWithNumbers", id: 123456789
// 118:           mas "an-app-i-use", id: 987654321
// 119:           mas "another_app_name", id: 832423434
// 120:           mas "App name with many spaces", id: 123457867
// 121:           mas "app;with;semicolons", id: 688963445
// 122:           mas "iMovie", id: 08981434
// 123:           mas "My (cool) app", id: 123456789
// 124:           mas "My App?", id: 543213432
// 125:           mas "my 😊 app", id: 123345384
// 126:           mas "my,comma,app", id: 893489734
// 127:           mas "non><printing><characters", id: 310633997
// 128:           mas "Numbers", id: 409203825
// 129:           mas "Pages", id: 409201541
// 130:           mas "Pastebin It!", id: 944924917
// 131:           mas "The Unarchiver", id: 425424353
// 132:           mas "Xcode", id: 497799835
// 133:           mas "áéíóú", id: 234324325
// 134:           mas "مرحبا", id: 634324555
// 135:           mas "你好", id: 896732467
// 136:         HEREDOC
// 137:       end
// 138:
// 139:       before do
// 140:         described_class.reset!
// 141:         allow(described_class).to receive_messages(package_manager_executable: Pathname.new("mas"),
// 142:                                                    "`":                        invalid_mas_output)
// 143:       end
// 144:
// 145:       specify do
// 146:         expect(dumper.apps).to eql(expected_app_details_array)
// 147:         expect(dumper.dump).to eq(expected_mas_dumped_output.strip)
// 148:       end
// 149:     end
// 150:
// 151:     context "with the new format after mas-cli/mas#339" do
// 152:       let(:new_mas_output) do
// 153:         <<~HEREDOC
// 154:           1440147259  AdGuard for Safari  (1.9.13)
// 155:           497799835   Xcode               (12.5)
// 156:           425424353   The Unarchiver      (4.3.1)
// 157:         HEREDOC
// 158:       end
// 159:
// 160:       let(:expected_app_details_array) do
// 161:         [
// 162:           ["1440147259", "AdGuard for Safari"],
// 163:           ["497799835", "Xcode"],
// 164:           ["425424353", "The Unarchiver"],
// 165:         ]
// 166:       end
// 167:
// 168:       before do
// 169:         described_class.reset!
// 170:         allow(described_class).to receive_messages(package_manager_executable: Pathname.new("mas"),
// 171:                                                    "`":                        new_mas_output)
// 172:       end
// 173:
// 174:       it "parses the app names without trailing whitespace" do
// 175:         expect(dumper.apps).to eql(expected_app_details_array)
// 176:       end
// 177:     end
// 178:   end
// 179:
// 180:   describe "installing" do
// 181:     before do
// 182:       stub_formula_loader formula("mas") {
// 183:         T.bind(self, T.class_of(Formula))
// 184:         url "mas-1.0"
// 185:       }
// 186:     end
// 187:
// 188:     describe ".installed_app_ids" do
// 189:       it "shells out" do
// 190:         expect { described_class.installed_app_ids }.not_to raise_error
// 191:       end
// 192:     end
// 193:
// 194:     describe ".app_id_installed_and_up_to_date?" do
// 195:       it "returns result" do
// 196:         allow(described_class).to receive_messages(installed_app_ids: [123, 456],
// 197:                                                    outdated_app_ids:  [456])
// 198:         expect(described_class.app_id_installed_and_up_to_date?(123)).to be(true)
// 199:         expect(described_class.app_id_installed_and_up_to_date?(456)).to be(false)
// 200:       end
// 201:     end
// 202:
// 203:     context "when mas is not installed" do
// 204:       before do
// 205:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 206:       end
// 207:
// 208:       it "tries to install mas" do
// 209:         expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "install", "mas",
// 210:                                                           verbose: false).and_return(true)
// 211:         expect { described_class.preinstall!("foo", 123) }.to raise_error(RuntimeError)
// 212:       end
// 213:
// 214:       describe ".outdated_app_ids" do
// 215:         it "does not shell out" do
// 216:           expect(described_class).not_to receive(:`)
// 217:           described_class.reset!
// 218:           described_class.outdated_app_ids
// 219:         end
// 220:       end
// 221:     end
// 222:
// 223:     context "when mas is installed" do
// 224:       before do
// 225:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("mas"))
// 226:       end
// 227:
// 228:       describe ".outdated_app_ids" do
// 229:         it "returns app ids" do
// 230:           expect(described_class).to receive(:`).and_return("foo 123")
// 231:           described_class.reset!
// 232:           described_class.outdated_app_ids
// 233:         end
// 234:       end
// 235:
// 236:       context "when app is installed" do
// 237:         before do
// 238:           allow(described_class).to receive(:installed_app_ids).and_return([123])
// 239:         end
// 240:
// 241:         it "skips" do
// 242:           expect(Homebrew::Bundle).not_to receive(:system)
// 243:           expect(described_class.preinstall!("foo", 123)).to be(false)
// 244:         end
// 245:       end
// 246:
// 247:       context "when app is outdated" do
// 248:         before do
// 249:           allow(described_class).to receive_messages(installed_app_ids: [123], outdated_app_ids: [123])
// 250:         end
// 251:
// 252:         it "upgrades" do
// 253:           expect(Homebrew::Bundle).to receive(:system).with(Pathname("mas"), "upgrade", "123", verbose: false)
// 254:                                                       .and_return(true)
// 255:           expect(described_class.preinstall!("foo", 123)).to be(true)
// 256:           expect(described_class.install!("foo", 123)).to be(true)
// 257:         end
// 258:       end
// 259:
// 260:       context "when app is not installed" do
// 261:         before do
// 262:           allow(described_class).to receive(:installed_app_ids).and_return([])
// 263:         end
// 264:
// 265:         it "installs app" do
// 266:           expect(Homebrew::Bundle).to receive(:system).with(Pathname("mas"), "install", "123", verbose: false)
// 267:                                                       .and_return(true)
// 268:           expect(described_class.preinstall!("foo", 123)).to be(true)
// 269:           expect(described_class.install!("foo", 123)).to be(true)
// 270:         end
// 271:
// 272:         it "falls back to `mas get` when `mas install` fails" do
// 273:           expect(Homebrew::Bundle).to receive(:system).with(Pathname("mas"), "install", "123", verbose: false)
// 274:                                                       .and_return(false)
// 275:           expect(Homebrew::Bundle).to receive(:system).with(Pathname("mas"), "get", "123", verbose: false)
// 276:                                                       .and_return(true)
// 277:           expect(described_class.preinstall!("foo", 123)).to be(true)
// 278:           expect(described_class.install!("foo", 123)).to be(true)
// 279:         end
// 280:       end
// 281:     end
// 282:   end
// 283:
// 284:   describe "cleanup" do
// 285:     before do
// 286:       described_class.reset!
// 287:       allow(described_class).to receive_messages(package_manager_executable: Pathname.new("mas"), packages: [
// 288:         Homebrew::Bundle::MacAppStore::App.new(id: "123", name: "foo"),
// 289:         Homebrew::Bundle::MacAppStore::App.new(id: "456", name: "bar"),
// 290:         Homebrew::Bundle::MacAppStore::App.new(id: "0", name: "testflight"),
// 291:       ])
// 292:     end
// 293:
// 294:     it "returns apps not in Brewfile entries by ID" do
// 295:       entries = [Homebrew::Bundle::Dsl::Entry.new(:mas, "renamed foo", id: 123)]
// 296:       items = described_class.cleanup_items(entries)
// 297:
// 298:       expect(items.map { |item| described_class.cleanup_item_name(item) }).to eql(["bar (456)"])
// 299:     end
// 300:
// 301:     it "uninstalls apps by ID" do
// 302:       items = described_class.cleanup_items([Homebrew::Bundle::Dsl::Entry.new(:mas, "foo", id: 123)])
// 303:       expect(Homebrew::Bundle).to receive(:system).with(Pathname("mas"), "uninstall", "456", verbose: false)
// 304:                                                   .and_return(true)
// 305:
// 306:       expect { described_class.cleanup!(items) }.to output(/Uninstalled 1 Mac App Store app/).to_stdout
// 307:     end
// 308:   end
// 309: end
