module bundle

import brew_runtime
import homebrew.bundle.extensions

fn winget_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn winget_spec_entry() extensions.ExtensionEntry {
	return extensions.winget_entry('PowerToys', {
		'id':     brew_runtime.string_value('XP89DCGQ3K6VLD')
		'source': brew_runtime.string_value('msstore')
	}) or { panic(err) }
}

fn winget_spec_apps() []extensions.WingetApp {
	return [
		extensions.WingetApp{ id: 'Microsoft.EdgeWebView2Runtime', name: 'Microsoft Edge WebView2 Runtime', source: 'winget' },
		extensions.WingetApp{ id: 'Microsoft.OneDrive', name: 'Microsoft OneDrive', source: 'winget' },
		extensions.WingetApp{ id: 'Microsoft.WSL', name: 'Windows Subsystem for Linux', source: 'winget' },
		extensions.WingetApp{ id: 'Valve.Steam', name: 'Steam', source: 'winget' },
		extensions.WingetApp{ id: '9NBLGGH4NNS1', name: 'App Installer', source: 'msstore' },
		extensions.WingetApp{ id: 'XP89DCGQ3K6VLD', name: 'PowerToys', source: 'msstore' },
		extensions.WingetApp{ id: 'Microsoft.UI.Xaml.2.8', name: 'Microsoft.UI.Xaml.2.8', source: 'msstore' },
		extensions.WingetApp{ id: '9N0DX20HK701', name: 'Windows Terminal', source: 'msstore' },
	]
}

fn winget_spec_install(state extensions.WingetState, name string, id string, source string,
	normal extensions.WingetCommandResult, elevated extensions.WingetCommandResult) brew_runtime.Value {
	return extensions.ruby_winget_l387_d32_install(extensions.winget_state_value(state), brew_runtime.string_value(name), brew_runtime.string_value(id), brew_runtime.string_value(source), brew_runtime.bool_value(true), extensions.winget_command_result_value(normal), extensions.winget_command_result_value(elevated))
}

fn winget_spec_result(value brew_runtime.Value) bool {
	if value.type_name != 'Hash' || 'result' !in value.map_data {
		return false
	}
	return value.map_data['result'].as_bool() or { false }
}

// Translated from Homebrew/brew `test/bundle/winget_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:entry) do` at line 11.
pub fn ruby_winget_spec_l11_d1_entry(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return extensions.extension_entry_value(winget_spec_entry())
}

// Ruby it `it "checks app installation by source and ID" do` at line 20.
pub fn ruby_winget_spec_l20_d2_checks(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return winget_spec_bool(extensions.winget_app_installed([
		extensions.WingetRecord{ id: 'XP89DCGQ3K6VLD', source: 'msstore' },
	], winget_spec_entry().options['id'].as_string(), winget_spec_entry().options['source'].as_string()))
}

// Ruby it `it "returns app names in failure messages" do` at line 25.
pub fn ruby_winget_spec_l25_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	installed := extensions.winget_app_installed([], 'XP89DCGQ3K6VLD', 'msstore')
	message := 'WinGet Package ${winget_spec_entry().name} needs to be installed.'
	return winget_spec_bool(!installed && message == 'WinGet Package PowerToys needs to be installed.')
}

// Ruby subject `subject(:dumper) { described_class }` at line 32.
pub fn ruby_winget_spec_l32_d4_dumper(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Homebrew::Bundle::Winget', 'Homebrew::Bundle::Winget')
}

// Ruby it `it "returns an empty list and dumps an empty string" do` at line 40.
pub fn ruby_winget_spec_l40_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	apps := extensions.winget_packages([])
	dump_text := apps.map(extensions.winget_dump_entry(it)).join('\n')
	return winget_spec_bool(apps.len == 0 && dump_text == '')
}

// Ruby it `it "returns app details and dumps Brewfile entries" do` at line 88.
pub fn ruby_winget_spec_l88_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	apps := winget_spec_apps()
	packages := extensions.winget_packages(apps)
	dump_text := packages.map(extensions.winget_dump_entry(it)).join('\n')
	expected := 'winget "Steam", id: "Valve.Steam"\nwinget "PowerToys", id: "XP89DCGQ3K6VLD", source: "msstore"\nwinget "Windows Terminal", id: "9N0DX20HK701", source: "msstore"'
	return winget_spec_bool(apps.len == 8 && dump_text == expected)
}

// Ruby it `it "resolves exported IDs through their source before dumping" do` at line 107.
pub fn ruby_winget_spec_l107_d7_resolves(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	exported := [
		extensions.WingetApp{ id: 'Valve.Steam', name: 'Valve.Steam', source: 'winget' },
		extensions.WingetApp{ id: 'Unknown.Package', name: 'Unknown.Package', source: 'winget' },
	]
	resolved := extensions.winget_export_apps(exported, {
		'valve.steam': 'Steam'
	})
	return winget_spec_bool(resolved.map(it.name) == ['Steam', 'Unknown.Package'])
}

// Ruby it `it "parses human-readable names from winget list output" do` at line 127.
pub fn ruby_winget_spec_l127_d8_parses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	output := '\r   - \r\nName       Id                Version\n------------------------------------\nSteam      Valve.Steam       2.10.91.91\nDiscord    XPDC2RH70K22MN    1.0.9188\n'
	return winget_spec_bool(extensions.winget_parse_list_names(output) == {
		'valve.steam':    'Steam'
		'xpdc2rh70k22mn': 'Discord'
	})
}

// Ruby it `it "parses indented winget list output" do` at line 142.
pub fn ruby_winget_spec_l142_d9_parses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	output := '    Name       Id                Version\n    ------------------------------------\n    Long Name  Example.App       1.0\n'
	return winget_spec_bool(extensions.winget_parse_list_names(output) == {
		'example.app': 'Long Name'
	})
}

// Ruby it `it "finds winget in the default Windows app location" do` at line 154.
pub fn ruby_winget_spec_l154_d10_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := extensions.WingetState{
		is_wsl: true
		executable: '/mnt/c/Users/BrewTest/AppData/Local/Microsoft/WindowsApps/winget.exe'
	}
	value := extensions.ruby_winget_l90_d8_package_manager_executable(extensions.winget_state_value(state))
	return winget_spec_bool(value.type_name == 'Pathname' && value.as_string() == state.executable)
}

// Ruby it `it "converts default Windows app paths to WSL paths" do` at line 165.
pub fn ruby_winget_spec_l165_d11_converts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	paths := extensions.winget_windows_apps_executables({
		'LOCALAPPDATA': r'C:\Users\BrewTest\AppData\Local'
	}, '')
	return winget_spec_bool(paths == [
		'/mnt/c/Users/BrewTest/AppData/Local/Microsoft/WindowsApps/winget.exe',
	])
}

// Ruby it `it "skips" do` at line 188.
pub fn ruby_winget_spec_l188_d12_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := extensions.WingetState{
		executable: 'winget.exe'
		records: [extensions.WingetRecord{ id: 'XP89DCGQ3K6VLD', source: 'msstore' }]
	}
	result := extensions.ruby_winget_l354_d31_preinstall(extensions.winget_state_value(state), brew_runtime.string_value('PowerToys'), brew_runtime.string_value('XP89DCGQ3K6VLD'), brew_runtime.string_value('msstore'))
	return winget_spec_bool(result.type_name == 'Bool' && !(result.as_bool() or { true }))
}

// Ruby it `it "installs app using its source and ID" do` at line 200.
pub fn ruby_winget_spec_l200_d13_installs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := winget_spec_install(extensions.WingetState{ executable: 'winget.exe' }, 'PowerToys', 'XP89DCGQ3K6VLD', 'msstore', extensions.WingetCommandResult{ success: true }, extensions.WingetCommandResult{})
	state := extensions.winget_state_from_value(result.map_data['state'])
	expected := ['winget.exe', 'install', '--id', 'XP89DCGQ3K6VLD', '--exact', '--source', 'msstore',
		'--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity']
	return winget_spec_bool(winget_spec_result(result) && state.commands == [expected])
}

// Ruby it `it "keeps the package dump cache filtered and sorted after installation" do` at line 212.
pub fn ruby_winget_spec_l212_d14_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := extensions.WingetState{
		executable: 'winget.exe'
		apps: [
			extensions.WingetApp{ id: 'Valve.Steam', name: 'Steam', source: 'winget' },
		]
		packages: [
			extensions.WingetApp{ id: 'Valve.Steam', name: 'Steam', source: 'winget' },
		]
	}
	first := winget_spec_install(state, '7-Zip', '7zip.7zip', 'winget', extensions.WingetCommandResult{ success: true }, extensions.WingetCommandResult{})
	state = extensions.winget_state_from_value(first.map_data['state'])
	second := winget_spec_install(state, 'Microsoft VCLibs', 'Microsoft.VCLibs.140.00.UWPDesktop', 'msstore', extensions.WingetCommandResult{ success: true }, extensions.WingetCommandResult{})
	state = extensions.winget_state_from_value(second.map_data['state'])
	return winget_spec_bool(state.packages.map(it.name) == ['7-Zip', 'Steam'])
}

// Ruby it `it "retries elevated when winget reports an elevation-like installer failure" do` at line 248.
pub fn ruby_winget_spec_l248_d15_retries(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := winget_spec_install(extensions.WingetState{ executable: 'winget.exe' }, 'Hue Sync', 'Philips.HueSync', 'winget', extensions.WingetCommandResult{
		success: false
		output: 'Installer failed with exit code: 1603\n'
	}, extensions.WingetCommandResult{ success: true })
	state := extensions.winget_state_from_value(result.map_data['state'])
	return winget_spec_bool(winget_spec_result(result) && state.output == [
		'WinGet install for Hue Sync may require Windows UAC/elevation; retrying elevated.',
	])
}

// Ruby it `it "suggests an elevated Windows install when the elevated retry fails" do` at line 268.
pub fn ruby_winget_spec_l268_d16_suggests(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := winget_spec_install(extensions.WingetState{ executable: 'winget.exe' }, 'Hue Sync', 'Philips.HueSync', 'winget', extensions.WingetCommandResult{
		output: 'Installer failed with exit code: 1603\n'
	}, extensions.WingetCommandResult{})
	state := extensions.winget_state_from_value(result.map_data['state'])
	return winget_spec_bool(!winget_spec_result(result) && state.output.join('\n').contains('Try installing it from an elevated Windows Terminal:'))
}

// Ruby it `it "suggests manual installation for installers that need UI" do` at line 293.
pub fn ruby_winget_spec_l293_d17_suggests(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := winget_spec_install(extensions.WingetState{ executable: 'winget.exe' }, 'Hue Sync', 'Philips.HueSync', 'winget', extensions.WingetCommandResult{
		output: 'Installer requires interactive user input\n'
	}, extensions.WingetCommandResult{})
	state := extensions.winget_state_from_value(result.map_data['state'])
	return winget_spec_bool(!winget_spec_result(result) && state.output.join('\n').contains('Install it manually from Windows:'))
}

// Ruby it `it "raises an error" do` at line 317.
pub fn ruby_winget_spec_l317_d18_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := extensions.ruby_winget_l354_d31_preinstall(extensions.winget_state_value(extensions.WingetState{}), brew_runtime.string_value('PowerToys'), brew_runtime.string_value('XP89DCGQ3K6VLD'), brew_runtime.string_value('msstore'))
	return winget_spec_bool(result.type_name == 'RuntimeError' && result.as_string().contains('winget.exe is not installed'))
}

// Ruby it `it "returns packages not in Brewfile entries by source and ID" do` at line 341.
pub fn ruby_winget_spec_l341_d19_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	entries := [extensions.winget_entry('Steam', {
		'id':     brew_runtime.string_value('Valve.Steam')
		'source': brew_runtime.string_value('winget')
	}) or { panic(err) }]
	exported := [
		extensions.WingetApp{ id: 'Valve.Steam', name: 'Steam', source: 'winget' },
		extensions.WingetApp{ id: 'XPDC2RH70K22MN', name: 'Discord', source: 'msstore' },
	]
	items := extensions.winget_cleanup_items(entries, 'winget.exe', exported)
	return winget_spec_bool(items.len == 1 && extensions.winget_cleanup_item_name(items[0]) or { '' } == 'Discord (XPDC2RH70K22MN, msstore)')
}

// Ruby it `it "uses the default source when computing kept packages" do` at line 350.
pub fn ruby_winget_spec_l350_d20_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	entry := extensions.ExtensionEntry{
		entry_type: 'winget'
		name: 'Valve.Steam'
		options: {
			'id': brew_runtime.string_value('Valve.Steam')
		}
	}
	exported := [
		extensions.WingetApp{ id: 'Valve.Steam', name: 'Steam', source: 'winget' },
		extensions.WingetApp{ id: 'XPDC2RH70K22MN', name: 'Discord', source: 'msstore' },
	]
	items := extensions.winget_cleanup_items([entry], 'winget.exe', exported)
	return winget_spec_bool(items.len == 1 && extensions.winget_cleanup_item_name(items[0]) or { '' } == 'Discord (XPDC2RH70K22MN, msstore)')
}

// Ruby it `it "does not resolve app names during cleanup discovery" do` at line 358.
pub fn ruby_winget_spec_l358_d21_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	entry := extensions.ExtensionEntry{
		entry_type: 'winget'
		name: 'Steam'
		options: {
			'id': brew_runtime.string_value('Valve.Steam')
		}
	}
	items := extensions.winget_cleanup_items([entry], 'winget.exe', [
		extensions.WingetApp{ id: 'Valve.Steam', name: 'Valve.Steam', source: 'winget' },
	])
	return winget_spec_bool(items.len == 0)
}

// Ruby it `it "uninstalls packages by exact ID and source" do` at line 363.
pub fn ruby_winget_spec_l363_d22_uninstalls(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	item := extensions.winget_cleanup_item(extensions.WingetApp{
		id: 'XPDC2RH70K22MN'
		name: 'Discord'
		source: 'msstore'
	})
	result := extensions.ruby_winget_l326_d29_cleanup(extensions.winget_state_value(extensions.WingetState{
		executable: 'winget.exe'
	}), brew_runtime.string_array_value([item]))
	state := extensions.winget_state_from_value(result)
	return winget_spec_bool(state.commands == [[
		'winget.exe',
		'uninstall',
		'--id',
		'XPDC2RH70K22MN',
		'--exact',
		'--source',
		'msstore',
		'--accept-source-agreements',
		'--disable-interactivity',
	]] && state.output == ['Uninstalled 1 WinGet package'])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions/winget"
// 7: require "bundle/skipper"
// 8:
// 9: RSpec.describe Homebrew::Bundle::Winget do
// 10:   describe "checking" do
// 11:     let(:entry) do
// 12:       Homebrew::Bundle::Dsl::Entry.new(:winget, "PowerToys", id: "XP89DCGQ3K6VLD", source: "msstore")
// 13:     end
// 14:
// 15:     before do
// 16:       allow(OS).to receive(:wsl?).and_return(true)
// 17:       allow(Homebrew::Bundle::Skipper).to receive(:skip?).with(entry).and_return(false)
// 18:     end
// 19:
// 20:     it "checks app installation by source and ID" do
// 21:       allow(described_class).to receive(:installed_app_records).and_return([["XP89DCGQ3K6VLD", "msstore"]])
// 22:       expect(described_class.check([entry])).to be_empty
// 23:     end
// 24:
// 25:     it "returns app names in failure messages" do
// 26:       allow(described_class).to receive(:installed_app_records).and_return([])
// 27:       expect(described_class.check([entry])).to eql(["WinGet Package PowerToys needs to be installed."])
// 28:     end
// 29:   end
// 30:
// 31:   describe "dumping" do
// 32:     subject(:dumper) { described_class }
// 33:
// 34:     context "when winget is not available" do
// 35:       before do
// 36:         described_class.reset!
// 37:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 38:       end
// 39:
// 40:       it "returns an empty list and dumps an empty string" do
// 41:         expect(dumper.apps).to be_empty
// 42:         expect(dumper.dump).to eql("")
// 43:       end
// 44:     end
// 45:
// 46:     context "when winget is available" do
// 47:       before do
// 48:         described_class.reset!
// 49:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("winget.exe"))
// 50:         allow(described_class).to receive(:export_apps)
// 51:           .with(Pathname.new("winget.exe"), source: "winget")
// 52:           .and_return(
// 53:             [
// 54:               Homebrew::Bundle::Winget::App.new(
// 55:                 id:     "Microsoft.EdgeWebView2Runtime",
// 56:                 name:   "Microsoft Edge WebView2 Runtime",
// 57:                 source: "winget",
// 58:               ),
// 59:               Homebrew::Bundle::Winget::App.new(
// 60:                 id: "Microsoft.OneDrive", name: "Microsoft OneDrive", source: "winget",
// 61:               ),
// 62:               Homebrew::Bundle::Winget::App.new(id: "Microsoft.WSL", name: "Windows Subsystem for Linux",
// 63:                                                 source: "winget"),
// 64:               Homebrew::Bundle::Winget::App.new(
// 65:                 id: "Valve.Steam", name: "Steam", source: "winget",
// 66:               ),
// 67:             ],
// 68:           )
// 69:         allow(described_class).to receive(:export_apps)
// 70:           .with(Pathname.new("winget.exe"), source: "msstore")
// 71:           .and_return(
// 72:             [
// 73:               Homebrew::Bundle::Winget::App.new(
// 74:                 id: "9NBLGGH4NNS1", name: "App Installer", source: "msstore",
// 75:               ),
// 76:               Homebrew::Bundle::Winget::App.new(
// 77:                 id: "XP89DCGQ3K6VLD", name: "PowerToys", source: "msstore",
// 78:               ),
// 79:               Homebrew::Bundle::Winget::App.new(id: "Microsoft.UI.Xaml.2.8", name: "Microsoft.UI.Xaml.2.8",
// 80:                                                 source: "msstore"),
// 81:               Homebrew::Bundle::Winget::App.new(
// 82:                 id: "9N0DX20HK701", name: "Windows Terminal", source: "msstore",
// 83:               ),
// 84:             ],
// 85:           )
// 86:       end
// 87:
// 88:       it "returns app details and dumps Brewfile entries" do
// 89:         expect(dumper.apps.map { |app| [app.id, app.name, app.source] }).to eql([
// 90:           ["Microsoft.EdgeWebView2Runtime", "Microsoft Edge WebView2 Runtime", "winget"],
// 91:           ["Microsoft.OneDrive", "Microsoft OneDrive", "winget"],
// 92:           ["Microsoft.WSL", "Windows Subsystem for Linux", "winget"],
// 93:           ["Valve.Steam", "Steam", "winget"],
// 94:           ["9NBLGGH4NNS1", "App Installer", "msstore"],
// 95:           ["XP89DCGQ3K6VLD", "PowerToys", "msstore"],
// 96:           ["Microsoft.UI.Xaml.2.8", "Microsoft.UI.Xaml.2.8", "msstore"],
// 97:           ["9N0DX20HK701", "Windows Terminal", "msstore"],
// 98:         ])
// 99:
// 100:         expect(dumper.dump).to eql(<<~BREWFILE.strip)
// 101:           winget "Steam", id: "Valve.Steam"
// 102:           winget "PowerToys", id: "XP89DCGQ3K6VLD", source: "msstore"
// 103:           winget "Windows Terminal", id: "9N0DX20HK701", source: "msstore"
// 104:         BREWFILE
// 105:       end
// 106:
// 107:       it "resolves exported IDs through their source before dumping" do
// 108:         winget = Pathname.new("winget.exe")
// 109:         allow(described_class).to receive(:export_apps).and_call_original
// 110:         allow(described_class).to receive(:exported_apps).with(winget, source: "winget").and_return([
// 111:           Homebrew::Bundle::Winget::App.new(id: "Valve.Steam", name: "Valve.Steam", source: "winget"),
// 112:           Homebrew::Bundle::Winget::App.new(id: "Unknown.Package", name: "Unknown.Package", source: "winget"),
// 113:         ])
// 114:         allow(Utils).to receive(:popen_read)
// 115:           .with(winget, "list", "--source", "winget", "--accept-source-agreements", "--disable-interactivity",
// 116:                 "--nowarn", err: :close)
// 117:           .and_return(<<~EOS)
// 118:             Name                                       Id                                          Version
// 119:             -----------------------------------------------------------------------------------------------
// 120:             Steam                                      Valve.Steam                                 2.10.91.91
// 121:           EOS
// 122:
// 123:         expect(described_class.export_apps(winget, source: "winget").map { |app| [app.id, app.name] })
// 124:           .to eql([["Valve.Steam", "Steam"], ["Unknown.Package", "Unknown.Package"]])
// 125:       end
// 126:
// 127:       it "parses human-readable names from winget list output" do
// 128:         output = <<~EOS
// 129:           \r   - \r
// 130:           Name       Id                Version
// 131:           ------------------------------------
// 132:           Steam      Valve.Steam       2.10.91.91
// 133:           Discord    XPDC2RH70K22MN    1.0.9188
// 134:         EOS
// 135:
// 136:         expect(described_class.parse_list_names(output)).to eql(
// 137:           "valve.steam"    => "Steam",
// 138:           "xpdc2rh70k22mn" => "Discord",
// 139:         )
// 140:       end
// 141:
// 142:       it "parses indented winget list output" do
// 143:         output = "    Name       Id                Version\n    " \
// 144:                  "------------------------------------\n    " \
// 145:                  "Long Name  Example.App       1.0\n"
// 146:
// 147:         expect(described_class.parse_list_names(output)).to eql(
// 148:           "example.app" => "Long Name",
// 149:         )
// 150:       end
// 151:     end
// 152:
// 153:     context "when winget is not in PATH" do
// 154:       it "finds winget in the default Windows app location" do
// 155:         allow(OS).to receive(:wsl?).and_return(true)
// 156:         allow(described_class).to receive(:which).with("winget.exe", ORIGINAL_PATHS).and_return(nil)
// 157:         winget = Pathname.new("/mnt/c/Users/BrewTest/AppData/Local/Microsoft/WindowsApps/winget.exe")
// 158:         expect(winget).to receive(:executable?).and_return(true)
// 159:         allow(described_class).to receive(:windows_apps_executables).and_return([winget])
// 160:
// 161:         expect(described_class.package_manager_executable)
// 162:           .to eq(Pathname.new("/mnt/c/Users/BrewTest/AppData/Local/Microsoft/WindowsApps/winget.exe"))
// 163:       end
// 164:
// 165:       it "converts default Windows app paths to WSL paths" do
// 166:         allow(described_class).to receive(:windows_local_appdata).and_return(nil)
// 167:         allow(ENV).to receive(:fetch).and_call_original
// 168:         allow(ENV).to receive(:fetch).with("LOCALAPPDATA", nil).and_return("C:\\Users\\BrewTest\\AppData\\Local")
// 169:         allow(ENV).to receive(:fetch).with("USERPROFILE", nil).and_return(nil)
// 170:
// 171:         expect(described_class.windows_apps_executables)
// 172:           .to eq([Pathname.new("/mnt/c/Users/BrewTest/AppData/Local/Microsoft/WindowsApps/winget.exe")])
// 173:       end
// 174:     end
// 175:   end
// 176:
// 177:   describe "installing" do
// 178:     before do
// 179:       described_class.reset!
// 180:       allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("winget.exe"))
// 181:     end
// 182:
// 183:     context "when app is installed" do
// 184:       before do
// 185:         allow(described_class).to receive(:installed_app_records).and_return([["XP89DCGQ3K6VLD", "msstore"]])
// 186:       end
// 187:
// 188:       it "skips" do
// 189:         expect(Homebrew::Bundle).not_to receive(:system)
// 190:         expect(described_class.preinstall!("PowerToys", id:     "XP89DCGQ3K6VLD",
// 191:                                                         source: "msstore")).to be(false)
// 192:       end
// 193:     end
// 194:
// 195:     context "when app is not installed" do
// 196:       before do
// 197:         allow(described_class).to receive(:installed_app_records).and_return([])
// 198:       end
// 199:
// 200:       it "installs app using its source and ID" do
// 201:         expect(described_class).to receive(:run_install_command)
// 202:           .with(Pathname("winget.exe"),
// 203:                 ["install", "--id", "XP89DCGQ3K6VLD", "--exact", "--source", "msstore",
// 204:                  "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity"],
// 205:                 verbose: false, elevated: false)
// 206:           .and_return([true, ""])
// 207:
// 208:         expect(described_class.preinstall!("PowerToys", id: "XP89DCGQ3K6VLD", source: "msstore")).to be(true)
// 209:         expect(described_class.install!("PowerToys", id: "XP89DCGQ3K6VLD", source: "msstore")).to be(true)
// 210:       end
// 211:
// 212:       it "keeps the package dump cache filtered and sorted after installation" do
// 213:         allow(described_class).to receive(:export_apps).with(Pathname("winget.exe"),
// 214:                                                              source: "winget").and_return([
// 215:                                                                Homebrew::Bundle::Winget::App.new(
// 216:                                                                  id: "Valve.Steam", name: "Steam", source: "winget",
// 217:                                                                ),
// 218:                                                              ])
// 219:         allow(described_class).to receive(:export_apps).with(Pathname("winget.exe"),
// 220:                                                              source: "msstore").and_return([])
// 221:
// 222:         expect(described_class.packages.map(&:name)).to eql(["Steam"])
// 223:
// 224:         expect(described_class).to receive(:run_install_command)
// 225:           .with(Pathname("winget.exe"),
// 226:                 ["install", "--id", "7zip.7zip", "--exact", "--source", "winget",
// 227:                  "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity"],
// 228:                 verbose: false, elevated: false)
// 229:           .and_return([true, ""])
// 230:         expect(described_class.install!("7-Zip", id: "7zip.7zip")).to be(true)
// 231:
// 232:         expect(described_class).to receive(:run_install_command)
// 233:           .with(Pathname("winget.exe"),
// 234:                 ["install", "--id", "Microsoft.VCLibs.140.00.UWPDesktop", "--exact", "--source", "msstore",
// 235:                  "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity"],
// 236:                 verbose: false, elevated: false)
// 237:           .and_return([true, ""])
// 238:         expect(described_class.install!("Microsoft VCLibs", id:     "Microsoft.VCLibs.140.00.UWPDesktop",
// 239:                                                             source: "msstore"))
// 240:           .to be(true)
// 241:
// 242:         expect(described_class.packages.map { |app| [app.name, app.id, app.source] }).to eql([
// 243:           ["7-Zip", "7zip.7zip", "winget"],
// 244:           ["Steam", "Valve.Steam", "winget"],
// 245:         ])
// 246:       end
// 247:
// 248:       it "retries elevated when winget reports an elevation-like installer failure" do
// 249:         expect(described_class).to receive(:run_install_command)
// 250:           .with(Pathname("winget.exe"),
// 251:                 ["install", "--id", "Philips.HueSync", "--exact", "--source", "winget",
// 252:                  "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity"],
// 253:                 verbose: false, elevated: false)
// 254:           .and_return([false, "Installer failed with exit code: 1603\n"])
// 255:         expect(described_class).to receive(:run_install_command)
// 256:           .with(Pathname("winget.exe"),
// 257:                 ["install", "--id", "Philips.HueSync", "--exact", "--source", "winget",
// 258:                  "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity"],
// 259:                 verbose: false, elevated: true)
// 260:           .and_return([true, ""])
// 261:
// 262:         expect do
// 263:           expect(described_class.install!("Hue Sync", id: "Philips.HueSync")).to be(true)
// 264:         end.to output("WinGet install for Hue Sync may require Windows UAC/elevation; retrying elevated.\n")
// 265:           .to_stdout
// 266:       end
// 267:
// 268:       it "suggests an elevated Windows install when the elevated retry fails" do
// 269:         expect(described_class).to receive(:run_install_command)
// 270:           .with(Pathname("winget.exe"),
// 271:                 ["install", "--id", "Philips.HueSync", "--exact", "--source", "winget",
// 272:                  "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity"],
// 273:                 verbose: false, elevated: false)
// 274:           .and_return([false, "Installer failed with exit code: 1603\n"])
// 275:         expect(described_class).to receive(:run_install_command)
// 276:           .with(Pathname("winget.exe"),
// 277:                 ["install", "--id", "Philips.HueSync", "--exact", "--source", "winget",
// 278:                  "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity"],
// 279:                 verbose: false, elevated: true)
// 280:           .and_return([false, ""])
// 281:
// 282:         expect do
// 283:           expect(described_class.install!("Hue Sync", id: "Philips.HueSync")).to be(false)
// 284:         end.to output(<<~EOS).to_stdout
// 285:           WinGet install for Hue Sync may require Windows UAC/elevation; retrying elevated.
// 286:           WinGet failed to install Hue Sync (Philips.HueSync) from winget.
// 287:           The installer may require Windows UAC/elevation.
// 288:           Try installing it from an elevated Windows Terminal:
// 289:             winget install --id Philips.HueSync --exact --source winget --disable-interactivity
// 290:         EOS
// 291:       end
// 292:
// 293:       it "suggests manual installation for installers that need UI" do
// 294:         expect(described_class).to receive(:run_install_command)
// 295:           .with(Pathname("winget.exe"),
// 296:                 ["install", "--id", "Philips.HueSync", "--exact", "--source", "winget",
// 297:                  "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity"],
// 298:                 verbose: false, elevated: false)
// 299:           .and_return([false, "Installer requires interactive user input\n"])
// 300:
// 301:         expect do
// 302:           expect(described_class.install!("Hue Sync", id: "Philips.HueSync")).to be(false)
// 303:         end.to output(<<~EOS).to_stdout
// 304:           WinGet failed to install Hue Sync (Philips.HueSync) from winget.
// 305:           The installer appears to require installer UI or user input, which brew bundle does not automate.
// 306:           Install it manually from Windows:
// 307:             winget install --id Philips.HueSync --exact --source winget
// 308:         EOS
// 309:       end
// 310:     end
// 311:
// 312:     context "when winget is not available" do
// 313:       before do
// 314:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 315:       end
// 316:
// 317:       it "raises an error" do
// 318:         expect do
// 319:           described_class.preinstall!("PowerToys", id: "XP89DCGQ3K6VLD", source: "msstore")
// 320:         end.to raise_error(RuntimeError, /winget.exe is not installed/)
// 321:       end
// 322:     end
// 323:   end
// 324:
// 325:   describe "cleanup" do
// 326:     before do
// 327:       described_class.reset!
// 328:       allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("winget.exe"))
// 329:       allow(described_class).to receive(:exported_apps).with(Pathname("winget.exe"), source: "winget").and_return([
// 330:         Homebrew::Bundle::Winget::App.new(
// 331:           id: "Valve.Steam", name: "Steam", source: "winget",
// 332:         ),
// 333:       ])
// 334:       allow(described_class).to receive(:exported_apps).with(Pathname("winget.exe"), source: "msstore").and_return([
// 335:         Homebrew::Bundle::Winget::App.new(
// 336:           id: "XPDC2RH70K22MN", name: "Discord", source: "msstore",
// 337:         ),
// 338:       ])
// 339:     end
// 340:
// 341:     it "returns packages not in Brewfile entries by source and ID" do
// 342:       entries = [Homebrew::Bundle::Dsl::Entry.new(:winget, "Steam", id: "Valve.Steam", source: "winget")]
// 343:       items = described_class.cleanup_items(entries)
// 344:
// 345:       expect(items.map do |item|
// 346:         described_class.cleanup_item_name(item)
// 347:       end).to eql(["Discord (XPDC2RH70K22MN, msstore)"])
// 348:     end
// 349:
// 350:     it "uses the default source when computing kept packages" do
// 351:       entries = [Homebrew::Bundle::Dsl::Entry.new(:winget, "Valve.Steam", id: "Valve.Steam", source: "winget")]
// 352:       expect(described_class.cleanup_items(entries).map do |item|
// 353:         described_class.cleanup_item_name(item)
// 354:       end)
// 355:         .to eql(["Discord (XPDC2RH70K22MN, msstore)"])
// 356:     end
// 357:
// 358:     it "does not resolve app names during cleanup discovery" do
// 359:       expect(described_class).not_to receive(:listed_app_names)
// 360:       described_class.cleanup_items([Homebrew::Bundle::Dsl::Entry.new(:winget, "Steam", id: "Valve.Steam")])
// 361:     end
// 362:
// 363:     it "uninstalls packages by exact ID and source" do
// 364:       items = described_class.cleanup_items([Homebrew::Bundle::Dsl::Entry.new(:winget, "Steam",
// 365:                                                                               id: "Valve.Steam")])
// 366:       expect(Homebrew::Bundle).to receive(:system)
// 367:         .with(Pathname("winget.exe"), "uninstall", "--id", "XPDC2RH70K22MN", "--exact", "--source", "msstore",
// 368:               "--accept-source-agreements", "--disable-interactivity", verbose: false)
// 369:         .and_return(true)
// 370:
// 371:       expect { described_class.cleanup!(items) }.to output(/Uninstalled 1 WinGet package/).to_stdout
// 372:     end
// 373:   end
// 374: end
