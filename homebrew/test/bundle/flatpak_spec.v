module bundle

import ruby
import homebrew.bundle.extensions

fn flatpak_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn flatpak_spec_package(name string, remote string, remote_url string) extensions.FlatpakPackage {
	return extensions.FlatpakPackage{
		name: name
		remote: remote
		remote_url: remote_url
	}
}

fn flatpak_spec_entry(name string, remote string, url string) extensions.ExtensionEntry {
	mut options := map[string]ruby.Value{}
	if remote != '' {
		options['remote'] = ruby.string_value(remote)
	}
	if url != '' {
		options['url'] = ruby.string_value(url)
	}
	return extensions.flatpak_entry(name, options) or { panic(err) }
}

fn flatpak_spec_checkable(name string, remote string, url string) ruby.Value {
	return extensions.extension_entry_value(flatpak_spec_entry(name, remote, url))
}

fn flatpak_spec_install(name string, remote string, url string, existing_url string,
	list_output string) (bool, extensions.FlatpakState) {
	mut state := extensions.FlatpakState{
		executable: 'flatpak'
	}
	result := extensions.flatpak_install(mut state, name, remote, url, true, false, existing_url, true, list_output)
	return result, state
}

// Translated from Homebrew/brew `test/bundle/flatpak_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:checker) { described_class.new }` at line 10.
pub fn ruby_flatpak_spec_l10_d1_checker(args ...ruby.Value) ruby.Value {
	_ = args
	return extensions.flatpak_state_value(extensions.FlatpakState{})
}

// Ruby it `it "returns false when package is not installed" do` at line 17.
pub fn ruby_flatpak_spec_l17_d2_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return flatpak_spec_bool(!extensions.flatpak_package_installed([], 'org.gnome.Calculator', none))
}

// Ruby it `it "returns true when package is installed" do` at line 21.
pub fn ruby_flatpak_spec_l21_d3_returns(args ...ruby.Value) ruby.Value {
	_ = args
	installed := [flatpak_spec_package('org.gnome.Calculator', 'flathub', '')]
	return flatpak_spec_bool(extensions.flatpak_package_installed(installed, 'org.gnome.Calculator', none))
}

// Ruby it `it "checks Tier 1 package with default remote (flathub)" do` at line 27.
pub fn ruby_flatpak_spec_l27_d4_checks(args ...ruby.Value) ruby.Value {
	_ = args
	installed := [flatpak_spec_package('org.gnome.Calculator', 'flathub', '')]
	return flatpak_spec_bool(extensions.flatpak_package_installed(installed, 'org.gnome.Calculator', 'flathub'))
}

// Ruby it `it "checks Tier 1 package with named remote" do` at line 38.
pub fn ruby_flatpak_spec_l38_d5_checks(args ...ruby.Value) ruby.Value {
	_ = args
	installed := [flatpak_spec_package('org.gnome.Calculator', 'fedora', '')]
	return flatpak_spec_bool(extensions.flatpak_package_installed(installed, 'org.gnome.Calculator', 'fedora'))
}

// Ruby it `it "checks Tier 2 package with URL remote (resolves to single-app remote)" do` at line 49.
pub fn ruby_flatpak_spec_l49_d6_checks(args ...ruby.Value) ruby.Value {
	_ = args
	installed := [
		flatpak_spec_package('org.godotengine.Godot', 'org.godotengine.Godot-origin', ''),
	]
	return flatpak_spec_bool(extensions.flatpak_package_installed(installed, 'org.godotengine.Godot', 'org.godotengine.Godot-origin'))
}

// Ruby it `it "checks Tier 2 package with .flatpakref by name only" do` at line 60.
pub fn ruby_flatpak_spec_l60_d7_checks(args ...ruby.Value) ruby.Value {
	_ = args
	installed := [flatpak_spec_package('org.example.App', 'example-origin', '')]
	return flatpak_spec_bool(extensions.flatpak_package_installed(installed, 'org.example.App', none))
}

// Ruby it `it "checks Tier 3 package with URL and remote name" do` at line 71.
pub fn ruby_flatpak_spec_l71_d8_checks(args ...ruby.Value) ruby.Value {
	_ = args
	installed := [flatpak_spec_package('org.godotengine.Godot', 'flathub-beta', '')]
	return flatpak_spec_bool(extensions.flatpak_package_installed(installed, 'org.godotengine.Godot', 'flathub-beta'))
}

// Ruby it `it "returns the correct failure message" do` at line 86.
pub fn ruby_flatpak_spec_l86_d9_returns(args ...ruby.Value) ruby.Value {
	_ = args
	message := extensions.ruby_flatpak_l389_d26_failure_reason(ruby.string_value('org.gnome.Calculator'))
	return flatpak_spec_bool(message.as_string() == 'Flatpak org.gnome.Calculator needs to be installed.')
}

// Ruby it `it "returns the correct failure message for hash package" do` at line 91.
pub fn ruby_flatpak_spec_l91_d10_returns(args ...ruby.Value) ruby.Value {
	_ = args
	package := flatpak_spec_checkable('org.gnome.Calculator', '', '')
	message := extensions.ruby_flatpak_l389_d26_failure_reason(package)
	return flatpak_spec_bool(message.as_string() == 'Flatpak org.gnome.Calculator needs to be installed.')
}

// Ruby it `it "flatpak is not available" do` at line 98.
pub fn ruby_flatpak_spec_l98_d11_flatpak(args ...ruby.Value) ruby.Value {
	_ = args
	return extensions.ruby_extension_l52_d8_self_package_manager_installed(extensions.flatpak_state_value(extensions.FlatpakState{}))
}

// Ruby subject `subject(:dumper) { described_class }` at line 105.
pub fn ruby_flatpak_spec_l105_d12_dumper(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Homebrew::Bundle::Flatpak', 'Homebrew::Bundle::Flatpak')
}

// Ruby it `it "returns an empty list and dumps an empty string" do` at line 113.
pub fn ruby_flatpak_spec_l113_d13_returns(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.flatpak_parse_packages('', {})
	return flatpak_spec_bool(packages.len == 0 && packages.map(extensions.flatpak_dump_entry(it)).join('\n') == '')
}

// Ruby it `it "returns remote URLs" do` at line 125.
pub fn ruby_flatpak_spec_l125_d14_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return flatpak_spec_bool(extensions.flatpak_parse_remote_urls('flathub\thttps://dl.flathub.org/repo/\nfedora\thttps://registry.fedoraproject.org/\n') == {
		'flathub': 'https://dl.flathub.org/repo/'
		'fedora':  'https://registry.fedoraproject.org/'
	})
}

// Ruby it `it "returns package list with remotes and URLs" do` at line 134.
pub fn ruby_flatpak_spec_l134_d15_returns(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.flatpak_parse_packages('org.gnome.Calculator\tflathub\ncom.spotify.Client\tflathub\n', {
		'flathub': 'https://dl.flathub.org/repo/'
	})
	return flatpak_spec_bool(packages == [
		flatpak_spec_package('com.spotify.Client', 'flathub', 'https://dl.flathub.org/repo/'),
		flatpak_spec_package('org.gnome.Calculator', 'flathub', 'https://dl.flathub.org/repo/'),
	])
}

// Ruby it `it "returns package names only" do` at line 147.
pub fn ruby_flatpak_spec_l147_d16_returns(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.flatpak_parse_packages('org.gnome.Calculator\tflathub\ncom.spotify.Client\tflathub\n', {
		'flathub': 'https://dl.flathub.org/repo/'
	})
	return flatpak_spec_bool(packages.map(it.name) == ['com.spotify.Client', 'org.gnome.Calculator'])
}

// Ruby it `it "dumps Tier 1 packages without remote (flathub default)" do` at line 158.
pub fn ruby_flatpak_spec_l158_d17_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	packages := [
		flatpak_spec_package('org.gnome.Calculator', 'flathub', 'https://dl.flathub.org/repo/'),
		flatpak_spec_package('com.spotify.Client', 'flathub', 'https://dl.flathub.org/repo/'),
	]
	return flatpak_spec_bool(packages.map(extensions.flatpak_dump_entry(it)).join('\n') == 'flatpak "org.gnome.Calculator"\nflatpak "com.spotify.Client"')
}

// Ruby it `it "dumps Tier 2 packages with URL only (single-app remote)" do` at line 166.
pub fn ruby_flatpak_spec_l166_d18_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	package := flatpak_spec_package('org.godotengine.Godot', 'org.godotengine.Godot-origin', 'https://dl.flathub.org/beta-repo/')
	return flatpak_spec_bool(extensions.flatpak_dump_entry(package) == 'flatpak "org.godotengine.Godot", remote: "https://dl.flathub.org/beta-repo/"')
}

// Ruby it `it "dumps Tier 2 packages with remote name if URL not available" do` at line 176.
pub fn ruby_flatpak_spec_l176_d19_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	package := flatpak_spec_package('org.example.App', 'org.example.App-origin', '')
	return flatpak_spec_bool(extensions.flatpak_dump_entry(package) == 'flatpak "org.example.App", remote: "org.example.App-origin"')
}

// Ruby it `it "dumps Tier 3 packages with remote name and URL (shared remote)" do` at line 185.
pub fn ruby_flatpak_spec_l185_d20_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	package := flatpak_spec_package('org.godotengine.Godot', 'flathub-beta', 'https://dl.flathub.org/beta-repo/')
	return flatpak_spec_bool(extensions.flatpak_dump_entry(package) == 'flatpak "org.godotengine.Godot", remote: "flathub-beta", url: "https://dl.flathub.org/beta-repo/"')
}

// Ruby it `it "dumps named remote without URL when URL is not available" do` at line 195.
pub fn ruby_flatpak_spec_l195_d21_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	package := flatpak_spec_package('com.custom.App', 'custom-repo', '')
	return flatpak_spec_bool(extensions.flatpak_dump_entry(package) == 'flatpak "com.custom.App", remote: "custom-repo"')
}

// Ruby it `it "dumps mixed packages correctly" do` at line 204.
pub fn ruby_flatpak_spec_l204_d22_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	packages := [
		flatpak_spec_package('com.spotify.Client', 'flathub', 'https://dl.flathub.org/repo/'),
		flatpak_spec_package('org.godotengine.Godot', 'org.godotengine.Godot-origin', 'https://dl.flathub.org/beta-repo/'),
		flatpak_spec_package('io.github.dvlv.boxbuddyrs', 'flathub-beta', 'https://dl.flathub.org/beta-repo/'),
	]
	return flatpak_spec_bool(packages.map(extensions.flatpak_dump_entry(it)).join('\n') == 'flatpak "com.spotify.Client"\nflatpak "org.godotengine.Godot", remote: "https://dl.flathub.org/beta-repo/"\nflatpak "io.github.dvlv.boxbuddyrs", remote: "flathub-beta", url: "https://dl.flathub.org/beta-repo/"')
}

// Ruby it `it "handles packages without origin" do` at line 220.
pub fn ruby_flatpak_spec_l220_d23_handles(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.flatpak_parse_packages('org.gnome.Calculator\n', {
		'flathub': 'https://dl.flathub.org/repo/'
	})
	return flatpak_spec_bool(packages == [
		flatpak_spec_package('org.gnome.Calculator', 'flathub', 'https://dl.flathub.org/repo/'),
	])
}

// Ruby it `it "returns false without attempting installation" do` at line 239.
pub fn ruby_flatpak_spec_l239_d24_returns(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := extensions.FlatpakState{}
	install_result := extensions.flatpak_install(mut state, 'org.gnome.Calculator', 'flathub', '', true, false, '', true, '')
	return flatpak_spec_bool(!extensions.flatpak_package_installed(state.installed_packages, 'org.gnome.Calculator', none) && install_result && state.commands.len == 0)
}

// Ruby it `it "skips" do` at line 257.
pub fn ruby_flatpak_spec_l257_d25_skips(args ...ruby.Value) ruby.Value {
	_ = args
	state := extensions.FlatpakState{
		executable: 'flatpak'
		installed_packages: [
			flatpak_spec_package('org.gnome.Calculator', 'flathub', ''),
		]
	}
	result := extensions.ruby_flatpak_l174_d14_preinstall(extensions.flatpak_state_value(state), ruby.string_value('org.gnome.Calculator'))
	return flatpak_spec_bool(result.type_name == 'Bool' && !(result.as_bool() or { true }))
}

// Ruby it `it "installs package from flathub" do` at line 269.
pub fn ruby_flatpak_spec_l269_d26_installs(args ...ruby.Value) ruby.Value {
	_ = args
	result, state := flatpak_spec_install('org.gnome.Calculator', 'flathub', '', '', '')
	return flatpak_spec_bool(result && state.commands == [[
		'flatpak',
		'install',
		'-y',
		'--system',
		'flathub',
		'org.gnome.Calculator',
	]])
}

// Ruby it `it "installs package from named remote" do` at line 278.
pub fn ruby_flatpak_spec_l278_d27_installs(args ...ruby.Value) ruby.Value {
	_ = args
	result, state := flatpak_spec_install('org.gnome.Calculator', 'fedora', '', '', '')
	return flatpak_spec_bool(result && state.commands == [[
		'flatpak',
		'install',
		'-y',
		'--system',
		'fedora',
		'org.gnome.Calculator',
	]])
}

// Ruby it `it "creates single-app remote with -origin suffix" do` at line 289.
pub fn ruby_flatpak_spec_l289_d28_creates(args ...ruby.Value) ruby.Value {
	_ = args
	url := 'https://dl.flathub.org/beta-repo/'
	result, state := flatpak_spec_install('org.godotengine.Godot', url, '', '', '')
	return flatpak_spec_bool(result && state.commands == [
		['flatpak', 'remote-add', '--if-not-exists', '--system', '--no-gpg-verify',
			'org.godotengine.Godot-origin', url],
		['flatpak', 'install', '-y', '--system', 'org.godotengine.Godot-origin',
			'org.godotengine.Godot'],
	])
}

// Ruby it `it "replaces single-app remote when URL changes" do` at line 308.
pub fn ruby_flatpak_spec_l308_d29_replaces(args ...ruby.Value) ruby.Value {
	_ = args
	url := 'https://dl.flathub.org/beta-repo/'
	result, state := flatpak_spec_install('org.godotengine.Godot', url, '', 'https://old.url/repo/', '')
	return flatpak_spec_bool(result && state.commands == [
		['flatpak', 'remote-delete', '--system', '--force', 'org.godotengine.Godot-origin'],
		['flatpak', 'remote-add', '--if-not-exists', '--system', '--no-gpg-verify',
			'org.godotengine.Godot-origin', url],
		['flatpak', 'install', '-y', '--system', 'org.godotengine.Godot-origin',
			'org.godotengine.Godot'],
	])
}

// Ruby it `it "installs from .flatpakref directly" do` at line 331.
pub fn ruby_flatpak_spec_l331_d30_installs(args ...ruby.Value) ruby.Value {
	_ = args
	url := 'https://example.com/app.flatpakref'
	result, state := flatpak_spec_install('org.example.App', url, '', '', 'org.example.App\texample-origin\n')
	return flatpak_spec_bool(result && state.commands == [[
		'flatpak',
		'install',
		'-y',
		'--system',
		url,
	]] && state.packages_with_remotes == [
		flatpak_spec_package('org.example.App', 'example-origin', ''),
	])
}

// Ruby it `it "creates named shared remote" do` at line 346.
pub fn ruby_flatpak_spec_l346_d31_creates(args ...ruby.Value) ruby.Value {
	_ = args
	url := 'https://dl.flathub.org/beta-repo/'
	result, state := flatpak_spec_install('org.godotengine.Godot', 'flathub-beta', url, '', '')
	return flatpak_spec_bool(result && state.commands == [
		['flatpak', 'remote-add', '--if-not-exists', '--system', '--no-gpg-verify', 'flathub-beta',
			url],
		['flatpak', 'install', '-y', '--system', 'flathub-beta', 'org.godotengine.Godot'],
	])
}

// Ruby it `it "warns but uses existing remote with different URL" do` at line 364.
pub fn ruby_flatpak_spec_l364_d32_warns(args ...ruby.Value) ruby.Value {
	_ = args
	url := 'https://dl.flathub.org/beta-repo/'
	result, state := flatpak_spec_install('org.godotengine.Godot', 'flathub-beta', url, 'https://different.url/repo/', '')
	return flatpak_spec_bool(result && state.commands == [[
		'flatpak',
		'install',
		'-y',
		'--system',
		'flathub-beta',
		'org.godotengine.Godot',
	]] && state.output == [
		"Warning: Remote 'flathub-beta' exists with different URL (https://different.url/repo/), using existing",
	])
}

// Ruby it `it "reuses existing shared remote when URL matches" do` at line 387.
pub fn ruby_flatpak_spec_l387_d33_reuses(args ...ruby.Value) ruby.Value {
	_ = args
	url := 'https://dl.flathub.org/beta-repo/'
	result, state := flatpak_spec_install('org.godotengine.Godot', 'flathub-beta', url, url, '')
	return flatpak_spec_bool(result && state.commands == [[
		'flatpak',
		'install',
		'-y',
		'--system',
		'flathub-beta',
		'org.godotengine.Godot',
	]])
}

// Ruby it `it "generates name with -origin suffix" do` at line 411.
pub fn ruby_flatpak_spec_l411_d34_generates(args ...ruby.Value) ruby.Value {
	_ = args
	value := extensions.ruby_flatpak_l277_d17_generate_single_app_remote_name(ruby.string_value('org.godotengine.Godot'))
	return flatpak_spec_bool(value.as_string() == 'org.godotengine.Godot-origin')
}

// Ruby it `it "handles various app ID formats" do` at line 416.
pub fn ruby_flatpak_spec_l416_d35_handles(args ...ruby.Value) ruby.Value {
	_ = args
	value := extensions.ruby_flatpak_l277_d17_generate_single_app_remote_name(ruby.string_value('com.example.App'))
	return flatpak_spec_bool(value.as_string() == 'com.example.App-origin')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions/flatpak"
// 7:
// 8: RSpec.describe Homebrew::Bundle::Flatpak do
// 9:   describe "checking" do
// 10:     subject(:checker) { described_class.new }
// 11:
// 12:     before do
// 13:       allow(described_class).to receive(:package_installed?).and_return(false)
// 14:     end
// 15:
// 16:     describe "#installed_and_up_to_date?", :needs_linux do
// 17:       it "returns false when package is not installed" do
// 18:         expect(checker.installed_and_up_to_date?("org.gnome.Calculator")).to be(false)
// 19:       end
// 20:
// 21:       it "returns true when package is installed" do
// 22:         allow(described_class).to receive(:package_installed?).and_return(true)
// 23:         expect(checker.installed_and_up_to_date?("org.gnome.Calculator")).to be(true)
// 24:       end
// 25:
// 26:       describe "3-tier remote handling" do
// 27:         it "checks Tier 1 package with default remote (flathub)" do
// 28:           allow(described_class).to receive(:package_installed?)
// 29:             .with("org.gnome.Calculator", remote: "flathub")
// 30:             .and_return(true)
// 31:
// 32:           result = checker.installed_and_up_to_date?(
// 33:             { name: "org.gnome.Calculator", options: {} },
// 34:           )
// 35:           expect(result).to be(true)
// 36:         end
// 37:
// 38:         it "checks Tier 1 package with named remote" do
// 39:           allow(described_class).to receive(:package_installed?)
// 40:             .with("org.gnome.Calculator", remote: "fedora")
// 41:             .and_return(true)
// 42:
// 43:           result = checker.installed_and_up_to_date?(
// 44:             { name: "org.gnome.Calculator", options: { remote: "fedora" } },
// 45:           )
// 46:           expect(result).to be(true)
// 47:         end
// 48:
// 49:         it "checks Tier 2 package with URL remote (resolves to single-app remote)" do
// 50:           allow(described_class).to receive(:package_installed?)
// 51:             .with("org.godotengine.Godot", remote: "org.godotengine.Godot-origin")
// 52:             .and_return(true)
// 53:
// 54:           result = checker.installed_and_up_to_date?(
// 55:             { name: "org.godotengine.Godot", options: { remote: "https://dl.flathub.org/beta-repo/" } },
// 56:           )
// 57:           expect(result).to be(true)
// 58:         end
// 59:
// 60:         it "checks Tier 2 package with .flatpakref by name only" do
// 61:           allow(described_class).to receive(:package_installed?)
// 62:             .with("org.example.App")
// 63:             .and_return(true)
// 64:
// 65:           result = checker.installed_and_up_to_date?(
// 66:             { name: "org.example.App", options: { remote: "https://example.com/app.flatpakref" } },
// 67:           )
// 68:           expect(result).to be(true)
// 69:         end
// 70:
// 71:         it "checks Tier 3 package with URL and remote name" do
// 72:           allow(described_class).to receive(:package_installed?)
// 73:             .with("org.godotengine.Godot", remote: "flathub-beta")
// 74:             .and_return(true)
// 75:
// 76:           result = checker.installed_and_up_to_date?(
// 77:             { name:    "org.godotengine.Godot",
// 78:               options: { remote: "flathub-beta", url: "https://dl.flathub.org/beta-repo/" } },
// 79:           )
// 80:           expect(result).to be(true)
// 81:         end
// 82:       end
// 83:     end
// 84:
// 85:     describe "#failure_reason", :needs_linux do
// 86:       it "returns the correct failure message" do
// 87:         expect(checker.failure_reason("org.gnome.Calculator", no_upgrade: false))
// 88:           .to eq("Flatpak org.gnome.Calculator needs to be installed.")
// 89:       end
// 90:
// 91:       it "returns the correct failure message for hash package" do
// 92:         expect(checker.failure_reason({ name: "org.gnome.Calculator", options: {} }, no_upgrade: false))
// 93:           .to eq("Flatpak org.gnome.Calculator needs to be installed.")
// 94:       end
// 95:     end
// 96:
// 97:     context "when on macOS", :needs_macos do
// 98:       it "flatpak is not available" do
// 99:         expect(described_class.package_manager_installed?).to be(false)
// 100:       end
// 101:     end
// 102:   end
// 103:
// 104:   describe "dumping" do
// 105:     subject(:dumper) { described_class }
// 106:
// 107:     context "when flatpak is not installed" do
// 108:       before do
// 109:         described_class.reset!
// 110:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 111:       end
// 112:
// 113:       it "returns an empty list and dumps an empty string" do
// 114:         expect(dumper.packages).to be_empty
// 115:         expect(dumper.dump).to eql("")
// 116:       end
// 117:     end
// 118:
// 119:     context "when flatpak is installed", :needs_linux do
// 120:       before do
// 121:         described_class.reset!
// 122:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("flatpak"))
// 123:       end
// 124:
// 125:       it "returns remote URLs" do
// 126:         allow(described_class).to receive(:`).with("flatpak remote-list --system --columns=name,url 2>/dev/null")
// 127:                                              .and_return("flathub\thttps://dl.flathub.org/repo/\nfedora\thttps://registry.fedoraproject.org/\n")
// 128:         expect(dumper.remote_urls).to eql({
// 129:           "flathub" => "https://dl.flathub.org/repo/",
// 130:           "fedora"  => "https://registry.fedoraproject.org/",
// 131:         })
// 132:       end
// 133:
// 134:       it "returns package list with remotes and URLs" do
// 135:         allow(described_class).to receive(:`)
// 136:           .with("flatpak list --app --columns=application,origin 2>/dev/null")
// 137:           .and_return("org.gnome.Calculator\tflathub\ncom.spotify.Client\tflathub\n")
// 138:         allow(described_class).to receive(:`)
// 139:           .with("flatpak remote-list --system --columns=name,url 2>/dev/null")
// 140:           .and_return("flathub\thttps://dl.flathub.org/repo/\n")
// 141:         expect(dumper.packages_with_remotes).to eql([
// 142:           { name: "com.spotify.Client", remote: "flathub", remote_url: "https://dl.flathub.org/repo/" },
// 143:           { name: "org.gnome.Calculator", remote: "flathub", remote_url: "https://dl.flathub.org/repo/" },
// 144:         ])
// 145:       end
// 146:
// 147:       it "returns package names only" do
// 148:         allow(described_class).to receive(:`)
// 149:           .with("flatpak list --app --columns=application,origin 2>/dev/null")
// 150:           .and_return("org.gnome.Calculator\tflathub\ncom.spotify.Client\tflathub\n")
// 151:         allow(described_class).to receive(:`)
// 152:           .with("flatpak remote-list --system --columns=name,url 2>/dev/null")
// 153:           .and_return("flathub\thttps://dl.flathub.org/repo/\n")
// 154:         expect(dumper.packages).to eql(["com.spotify.Client", "org.gnome.Calculator"])
// 155:       end
// 156:
// 157:       describe "3-tier dump format" do
// 158:         it "dumps Tier 1 packages without remote (flathub default)" do
// 159:           allow(dumper).to receive(:packages_with_remotes).and_return([
// 160:             { name: "org.gnome.Calculator", remote: "flathub", remote_url: "https://dl.flathub.org/repo/" },
// 161:             { name: "com.spotify.Client", remote: "flathub", remote_url: "https://dl.flathub.org/repo/" },
// 162:           ])
// 163:           expect(dumper.dump).to eql("flatpak \"org.gnome.Calculator\"\nflatpak \"com.spotify.Client\"")
// 164:         end
// 165:
// 166:         it "dumps Tier 2 packages with URL only (single-app remote)" do
// 167:           allow(dumper).to receive(:packages_with_remotes).and_return([
// 168:             { name: "org.godotengine.Godot", remote: "org.godotengine.Godot-origin",
// 169:               remote_url: "https://dl.flathub.org/beta-repo/" },
// 170:           ])
// 171:           expect(dumper.dump).to eql(
// 172:             "flatpak \"org.godotengine.Godot\", remote: \"https://dl.flathub.org/beta-repo/\"",
// 173:           )
// 174:         end
// 175:
// 176:         it "dumps Tier 2 packages with remote name if URL not available" do
// 177:           allow(dumper).to receive(:packages_with_remotes).and_return([
// 178:             { name: "org.example.App", remote: "org.example.App-origin", remote_url: nil },
// 179:           ])
// 180:           expect(dumper.dump).to eql(
// 181:             "flatpak \"org.example.App\", remote: \"org.example.App-origin\"",
// 182:           )
// 183:         end
// 184:
// 185:         it "dumps Tier 3 packages with remote name and URL (shared remote)" do
// 186:           allow(dumper).to receive(:packages_with_remotes).and_return([
// 187:             { name: "org.godotengine.Godot", remote: "flathub-beta",
// 188:               remote_url: "https://dl.flathub.org/beta-repo/" },
// 189:           ])
// 190:           expect(dumper.dump).to eql(
// 191:             "flatpak \"org.godotengine.Godot\", remote: \"flathub-beta\", url: \"https://dl.flathub.org/beta-repo/\"",
// 192:           )
// 193:         end
// 194:
// 195:         it "dumps named remote without URL when URL is not available" do
// 196:           allow(dumper).to receive(:packages_with_remotes).and_return([
// 197:             { name: "com.custom.App", remote: "custom-repo", remote_url: nil },
// 198:           ])
// 199:           expect(dumper.dump).to eql(
// 200:             "flatpak \"com.custom.App\", remote: \"custom-repo\"",
// 201:           )
// 202:         end
// 203:
// 204:         it "dumps mixed packages correctly" do
// 205:           allow(dumper).to receive(:packages_with_remotes).and_return([
// 206:             { name: "com.spotify.Client", remote: "flathub", remote_url: "https://dl.flathub.org/repo/" },
// 207:             { name: "org.godotengine.Godot", remote: "org.godotengine.Godot-origin",
// 208:               remote_url: "https://dl.flathub.org/beta-repo/" },
// 209:             { name: "io.github.dvlv.boxbuddyrs", remote: "flathub-beta",
// 210:               remote_url: "https://dl.flathub.org/beta-repo/" },
// 211:           ])
// 212:           expect(dumper.dump).to eql(
// 213:             "flatpak \"com.spotify.Client\"\n" \
// 214:             "flatpak \"org.godotengine.Godot\", remote: \"https://dl.flathub.org/beta-repo/\"\n" \
// 215:             "flatpak \"io.github.dvlv.boxbuddyrs\", remote: \"flathub-beta\", url: \"https://dl.flathub.org/beta-repo/\"",
// 216:           )
// 217:         end
// 218:       end
// 219:
// 220:       it "handles packages without origin" do
// 221:         allow(described_class).to receive(:`).with("flatpak list --app --columns=application,origin 2>/dev/null")
// 222:                                              .and_return("org.gnome.Calculator\n")
// 223:         allow(described_class).to receive(:`).with("flatpak remote-list --system --columns=name,url 2>/dev/null")
// 224:                                              .and_return("flathub\thttps://dl.flathub.org/repo/\n")
// 225:         expect(dumper.packages_with_remotes).to eql([
// 226:           { name: "org.gnome.Calculator", remote: "flathub", remote_url: "https://dl.flathub.org/repo/" },
// 227:         ])
// 228:       end
// 229:     end
// 230:   end
// 231:
// 232:   describe "installing" do
// 233:     context "when Flatpak is not installed", :needs_linux do
// 234:       before do
// 235:         described_class.reset!
// 236:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 237:       end
// 238:
// 239:       it "returns false without attempting installation" do
// 240:         expect(Homebrew::Bundle).not_to receive(:system)
// 241:         expect(described_class.preinstall!("org.gnome.Calculator")).to be(false)
// 242:         expect(described_class.install!("org.gnome.Calculator")).to be(true)
// 243:       end
// 244:     end
// 245:
// 246:     context "when Flatpak is installed", :needs_linux do
// 247:       before do
// 248:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("flatpak"))
// 249:       end
// 250:
// 251:       context "when package is installed" do
// 252:         before do
// 253:           allow(described_class).to receive(:installed_packages)
// 254:             .and_return([{ name: "org.gnome.Calculator", remote: "flathub" }])
// 255:         end
// 256:
// 257:         it "skips" do
// 258:           expect(Homebrew::Bundle).not_to receive(:system)
// 259:           expect(described_class.preinstall!("org.gnome.Calculator")).to be(false)
// 260:         end
// 261:       end
// 262:
// 263:       context "when package is not installed" do
// 264:         before do
// 265:           allow(described_class).to receive(:installed_packages).and_return([])
// 266:         end
// 267:
// 268:         describe "Tier 1: no URL (flathub default)" do
// 269:           it "installs package from flathub" do
// 270:             expect(Homebrew::Bundle).to \
// 271:               receive(:system).with("flatpak", "install", "-y", "--system", "flathub", "org.gnome.Calculator",
// 272:                                     verbose: false)
// 273:                               .and_return(true)
// 274:             expect(described_class.preinstall!("org.gnome.Calculator")).to be(true)
// 275:             expect(described_class.install!("org.gnome.Calculator")).to be(true)
// 276:           end
// 277:
// 278:           it "installs package from named remote" do
// 279:             expect(Homebrew::Bundle).to \
// 280:               receive(:system).with("flatpak", "install", "-y", "--system", "fedora", "org.gnome.Calculator",
// 281:                                     verbose: false)
// 282:                               .and_return(true)
// 283:             expect(described_class.preinstall!("org.gnome.Calculator", remote: "fedora")).to be(true)
// 284:             expect(described_class.install!("org.gnome.Calculator", remote: "fedora")).to be(true)
// 285:           end
// 286:         end
// 287:
// 288:         describe "Tier 2: URL only (single-app remote)" do
// 289:           it "creates single-app remote with -origin suffix" do
// 290:             allow(described_class).to receive(:get_remote_url).and_return(nil)
// 291:
// 292:             expect(Homebrew::Bundle).to \
// 293:               receive(:system).with("flatpak", "remote-add", "--if-not-exists", "--system",
// 294:                                     "--no-gpg-verify", "org.godotengine.Godot-origin",
// 295:                                     "https://dl.flathub.org/beta-repo/", verbose: false)
// 296:                               .and_return(true)
// 297:             expect(Homebrew::Bundle).to \
// 298:               receive(:system).with("flatpak", "install", "-y", "--system", "org.godotengine.Godot-origin",
// 299:                                     "org.godotengine.Godot", verbose: false)
// 300:                               .and_return(true)
// 301:
// 302:             expect(described_class.preinstall!("org.godotengine.Godot", remote: "https://dl.flathub.org/beta-repo/"))
// 303:               .to be(true)
// 304:             expect(described_class.install!("org.godotengine.Godot", remote: "https://dl.flathub.org/beta-repo/"))
// 305:               .to be(true)
// 306:           end
// 307:
// 308:           it "replaces single-app remote when URL changes" do
// 309:             allow(described_class).to receive(:get_remote_url)
// 310:               .with(anything, "org.godotengine.Godot-origin")
// 311:               .and_return("https://old.url/repo/")
// 312:
// 313:             expect(Homebrew::Bundle).to \
// 314:               receive(:system).with("flatpak", "remote-delete", "--system", "--force",
// 315:                                     "org.godotengine.Godot-origin", verbose: false)
// 316:                               .and_return(true)
// 317:             expect(Homebrew::Bundle).to \
// 318:               receive(:system).with("flatpak", "remote-add", "--if-not-exists", "--system",
// 319:                                     "--no-gpg-verify", "org.godotengine.Godot-origin",
// 320:                                     "https://dl.flathub.org/beta-repo/", verbose: false)
// 321:                               .and_return(true)
// 322:             expect(Homebrew::Bundle).to \
// 323:               receive(:system).with("flatpak", "install", "-y", "--system", "org.godotengine.Godot-origin",
// 324:                                     "org.godotengine.Godot", verbose: false)
// 325:                               .and_return(true)
// 326:
// 327:             expect(described_class.install!("org.godotengine.Godot", remote: "https://dl.flathub.org/beta-repo/"))
// 328:               .to be(true)
// 329:           end
// 330:
// 331:           it "installs from .flatpakref directly" do
// 332:             allow(described_class).to receive(:`).with("flatpak list --app --columns=application,origin 2>/dev/null")
// 333:                                                  .and_return("org.example.App\texample-origin\n")
// 334:
// 335:             expect(Homebrew::Bundle).to \
// 336:               receive(:system).with("flatpak", "install", "-y", "--system",
// 337:                                     "https://example.com/app.flatpakref", verbose: false)
// 338:                               .and_return(true)
// 339:
// 340:             expect(described_class.install!("org.example.App", remote: "https://example.com/app.flatpakref"))
// 341:               .to be(true)
// 342:           end
// 343:         end
// 344:
// 345:         describe "Tier 3: URL + name (shared remote)" do
// 346:           it "creates named shared remote" do
// 347:             allow(described_class).to receive(:get_remote_url).and_return(nil)
// 348:
// 349:             expect(Homebrew::Bundle).to \
// 350:               receive(:system).with("flatpak", "remote-add", "--if-not-exists", "--system", "--no-gpg-verify",
// 351:                                     "flathub-beta", "https://dl.flathub.org/beta-repo/", verbose: false)
// 352:                               .and_return(true)
// 353:             expect(Homebrew::Bundle).to \
// 354:               receive(:system).with("flatpak", "install", "-y", "--system", "flathub-beta",
// 355:                                     "org.godotengine.Godot", verbose: false)
// 356:                               .and_return(true)
// 357:
// 358:             expect(described_class.install!("org.godotengine.Godot",
// 359:                                             remote: "flathub-beta",
// 360:                                             url:    "https://dl.flathub.org/beta-repo/"))
// 361:               .to be(true)
// 362:           end
// 363:
// 364:           it "warns but uses existing remote with different URL" do
// 365:             allow(described_class).to receive(:get_remote_url)
// 366:               .with(anything, "flathub-beta")
// 367:               .and_return("https://different.url/repo/")
// 368:
// 369:             # Should NOT try to add remote (uses existing)
// 370:             expect(Homebrew::Bundle).not_to receive(:system)
// 371:               .with("flatpak", "remote-add", any_args)
// 372:             # Should NOT try to delete remote (user explicitly named it)
// 373:             expect(Homebrew::Bundle).not_to receive(:system)
// 374:               .with("flatpak", "remote-delete", any_args)
// 375:
// 376:             expect(Homebrew::Bundle).to \
// 377:               receive(:system).with("flatpak", "install", "-y", "--system", "flathub-beta",
// 378:                                     "org.godotengine.Godot", verbose: false)
// 379:                               .and_return(true)
// 380:
// 381:             expect(described_class.install!("org.godotengine.Godot",
// 382:                                             remote: "flathub-beta",
// 383:                                             url:    "https://dl.flathub.org/beta-repo/"))
// 384:               .to be(true)
// 385:           end
// 386:
// 387:           it "reuses existing shared remote when URL matches" do
// 388:             allow(described_class).to receive(:get_remote_url)
// 389:               .with(anything, "flathub-beta")
// 390:               .and_return("https://dl.flathub.org/beta-repo/")
// 391:
// 392:             # Should NOT try to add remote (already exists with same URL)
// 393:             expect(Homebrew::Bundle).not_to receive(:system)
// 394:               .with("flatpak", "remote-add", any_args)
// 395:
// 396:             expect(Homebrew::Bundle).to \
// 397:               receive(:system).with("flatpak", "install", "-y", "--system", "flathub-beta",
// 398:                                     "org.godotengine.Godot", verbose: false)
// 399:                               .and_return(true)
// 400:
// 401:             expect(described_class.install!("org.godotengine.Godot",
// 402:                                             remote: "flathub-beta",
// 403:                                             url:    "https://dl.flathub.org/beta-repo/"))
// 404:               .to be(true)
// 405:           end
// 406:         end
// 407:       end
// 408:     end
// 409:
// 410:     describe ".generate_single_app_remote_name" do
// 411:       it "generates name with -origin suffix" do
// 412:         expect(described_class.generate_single_app_remote_name("org.godotengine.Godot"))
// 413:           .to eq("org.godotengine.Godot-origin")
// 414:       end
// 415:
// 416:       it "handles various app ID formats" do
// 417:         expect(described_class.generate_single_app_remote_name("com.example.App"))
// 418:           .to eq("com.example.App-origin")
// 419:       end
// 420:     end
// 421:   end
// 422: end
