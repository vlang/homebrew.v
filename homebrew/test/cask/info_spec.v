module cask

import ruby
import homebrew.cask as cask_info
import homebrew.utils as brew_utils
import os
import time

// Translated from Homebrew/brew `test/cask/info_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn cask_info_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn cask_info_spec_output_options() brew_utils.OutputOptions {
	return brew_utils.OutputOptions{
		tty: brew_utils.TtyState{
			stream_is_tty: true
		}
	}
}

fn cask_info_spec_tap(token string) cask_info.CaskInfoTap {
	return cask_info.CaskInfoTap{
		present: true
		default_remote: 'https://github.com/Homebrew/homebrew-cask'
		relative_cask_path: 'Casks/${token[..1]}/${token}.rb'
		core_cask_tap: true
	}
}

fn cask_info_spec_requirement() cask_info.CaskInfoRequirement {
	return cask_info.CaskInfoRequirement{
		display: 'macOS >= 10.15 (or Linux)'
		kind: 'required'
		satisfied: true
		macos_requirement: true
	}
}

fn cask_info_spec_fixture(token string) cask_info.CaskInfoModel {
	mut fixture := cask_info.CaskInfoModel{
		token: token
		version: '1.2.3'
		homepage: 'https://brew.sh/'
		tap: cask_info_spec_tap(token)
		requirements: [cask_info_spec_requirement()]
		artifacts: [cask_info.CaskInfoArtifact{
			display: 'Caffeine.app (App)'
		}]
		tty: true
	}
	match token {
		'local-transmission' {
			fixture = cask_info.CaskInfoModel{
				...fixture
				version: '2.61'
				names: ['Transmission']
				desc: 'BitTorrent client'
				homepage: 'https://transmissionbt.com/'
				artifacts: [cask_info.CaskInfoArtifact{
					display: 'Transmission.app (App)'
				}]
			}
		}
		'with-depends-on-cask-multiple' {
			fixture = cask_info.CaskInfoModel{
				...fixture
				homepage: 'https://brew.sh/with-depends-on-cask-multiple'
				cask_dependencies: [
					cask_info.CaskInfoDependency{
						name: 'local-caffeine'
					},
					cask_info.CaskInfoDependency{
						name: 'local-transmission-zip'
					},
				]
				recursive_cask_dependencies: [
					cask_info.CaskInfoDependency{
						name: 'local-caffeine'
					},
					cask_info.CaskInfoDependency{
						name: 'local-transmission-zip'
					},
				]
			}
		}
		'with-depends-on-everything' {
			fixture = cask_info.CaskInfoModel{
				...fixture
				homepage: 'https://brew.sh/with-depends-on-everything'
				formula_dependencies: [cask_info.CaskInfoDependency{
					name: 'unar'
				}]
				cask_dependencies: [
					cask_info.CaskInfoDependency{
						name: 'local-caffeine'
					},
					cask_info.CaskInfoDependency{
						name: 'with-depends-on-cask'
					},
				]
				recursive_formula_dependencies: [
					cask_info.CaskInfoDependency{
						name: 'unar'
					},
					cask_info.CaskInfoDependency{
						name: 'nested-formula'
					},
				]
				recursive_cask_dependencies: [
					cask_info.CaskInfoDependency{
						name: 'local-caffeine'
					},
					cask_info.CaskInfoDependency{
						name: 'with-depends-on-cask'
					},
				]
				requirements: [
					cask_info.CaskInfoRequirement{
						display: 'x86_64 architecture'
						kind: 'required'
						satisfied: true
					},
					cask_info.CaskInfoRequirement{
						display: 'arm64 architecture'
						kind: 'required'
					},
					cask_info_spec_requirement(),
				]
			}
		}
		'with-auto-updates' {
			fixture = cask_info.CaskInfoModel{
				...fixture
				names: ['AutoUpdates']
				version: '1.0'
				homepage: 'https://brew.sh/autoupdates'
				auto_updates: true
				artifacts: [cask_info.CaskInfoArtifact{
					display: 'AutoUpdates.app (App)'
				}]
			}
		}
		'with-caveats' {
			fixture = cask_info.CaskInfoModel{
				...fixture
				caveats: '${brew_utils.output_ohai_title('Caveats', cask_info_spec_output_options())}\nHere are some things you might want to know.\n\nCask token: with-caveats\n'
			}
		}
		'with-languages' {
			fixture = cask_info.CaskInfoModel{
				...fixture
				names: ['Caffeine']
				languages: ['zh', 'en-US']
			}
		}
		'with-non-executable-binary' {
			fixture = cask_info.CaskInfoModel{
				...fixture
				homepage: 'https://brew.sh/with-binary'
				requirements: []
				artifacts: [cask_info.CaskInfoArtifact{
					display: 'naked_non_executable (Binary)'
				}]
			}
		}
		else {}
	}
	return fixture
}

// Ruby let `let(:args) { instance_double(Homebrew::Cmd::Info::Args) }` at line 8.
pub fn ruby_info_spec_l8_d1_args(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Homebrew::Cmd::Info::Args', 'instance_double(Homebrew::Cmd::Info::Args)')
}

// Ruby method `uninstalled(string)` at line 12.
pub fn ruby_info_spec_l12_d2_uninstalled(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.string_value(brew_utils.pretty_uninstalled(value, true, cask_info_spec_output_options()))
}

// Ruby method `installed(string)` at line 16.
pub fn ruby_info_spec_l16_d3_installed(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.string_value(brew_utils.pretty_installed(value, cask_info_spec_output_options()))
}

// Ruby method `requirements_section(string)` at line 20.
pub fn ruby_info_spec_l20_d4_requirements_section(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.string_value('${brew_utils.output_ohai_title('Requirements', cask_info_spec_output_options())}\nRequired: ${value}')
}

// Ruby method `mock_cask_installed(cask_name)` at line 27.
pub fn ruby_info_spec_l27_d5_mock_cask_installed(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'local-transmission-zip' }
	fixture := cask_info.CaskInfoModel{
		...cask_info_spec_fixture(name)
		installed: true
		installed_version: '1.0'
	}
	return cask_info.cask_info_value(fixture)
}

// Ruby it `it "displays some nice info about the specified Cask" do` at line 43.
pub fn ruby_info_spec_l43_d6_displays(args ...ruby.Value) ruby.Value {
	output := cask_info.cask_info_get(cask_info_spec_fixture('local-transmission'))
	return cask_info_spec_bool(output.contains('local-transmission') && output.contains('(Transmission): 2.61') && output.contains('BitTorrent client') && output.contains('https://transmissionbt.com/') && output.contains('Not installed') && output.contains('macOS >= 10.15') && output.ends_with('Transmission.app (App)\n'))
}

// Ruby it `it "omits a missing cask name and description" do` at line 60.
pub fn ruby_info_spec_l60_d7_omits(args ...ruby.Value) ruby.Value {
	output := cask_info.cask_info_get(cask_info_spec_fixture('with-depends-on-cask-multiple'))
	return cask_info_spec_bool(!output.contains('==> Name') && !output.contains('==> Description') && output.contains('Required (2): local-caffeine (cask), local-transmission-zip (cask)') && output.contains('Recursive Runtime (2): 0 installed'))
}

// Ruby it `it "prints inline summary information for casks" do` at line 79.
pub fn ruby_info_spec_l79_d8_prints(args ...ruby.Value) ruby.Value {
	output := cask_info.cask_info_get(cask_info_spec_fixture('local-transmission'))
	return cask_info_spec_bool(output.contains('Requirements') && output.contains('Required: ') && output.contains('macOS >= 10.15') && !output.contains('==> Name') && !output.contains('==> Description') && !output.contains('Metadata'))
}

// Ruby it `it "prints cask dependencies if the Cask has any" do` at line 91.
pub fn ruby_info_spec_l91_d9_prints(args ...ruby.Value) ruby.Value {
	mut fixture := cask_info_spec_fixture('with-depends-on-cask-multiple')
	fixture = cask_info.CaskInfoModel{
		...fixture
		cask_dependencies: [
			cask_info.CaskInfoDependency{
				name: 'local-caffeine'
			},
			cask_info.CaskInfoDependency{
				name: 'local-transmission-zip'
				installed: true
			},
		]
		recursive_cask_dependencies: [
			cask_info.CaskInfoDependency{
				name: 'local-caffeine'
			},
			cask_info.CaskInfoDependency{
				name: 'local-transmission-zip'
				installed: true
			},
		]
	}
	output := cask_info.cask_info_get(fixture)
	return cask_info_spec_bool(output.contains('local-transmission-zip (cask)') && output.contains('Recursive Runtime (2): 1 installed'))
}

// Ruby it `it "summarises recursive runtime dependencies as all installed when none are missing" do` at line 110.
pub fn ruby_info_spec_l110_d10_summarises(args ...ruby.Value) ruby.Value {
	mut fixture := cask_info_spec_fixture('with-depends-on-cask-multiple')
	fixture = cask_info.CaskInfoModel{
		...fixture
		recursive_cask_dependencies: fixture.recursive_cask_dependencies.map(cask_info.CaskInfoDependency{
			...it
			installed: true
		})
	}
	return cask_info_spec_bool(cask_info.cask_info_get(fixture).contains('Recursive Runtime (2): all installed'))
}

// Ruby it `it "prints cask and formulas dependencies if the Cask has both" do` at line 119.
pub fn ruby_info_spec_l119_d11_prints(args ...ruby.Value) ruby.Value {
	output := cask_info.cask_info_get(cask_info_spec_fixture('with-depends-on-everything'))
	return cask_info_spec_bool(output.contains('Required (3): unar, local-caffeine (cask), with-depends-on-cask (cask)') && output.contains('Recursive Runtime (4): 0 installed') && output.contains('x86_64 architecture') && output.contains('arm64 architecture'))
}

// Ruby it `it "prints auto_updates if the Cask has `auto_updates true`" do` at line 143.
pub fn ruby_info_spec_l143_d12_prints(args ...ruby.Value) ruby.Value {
	output := cask_info.cask_info_get(cask_info_spec_fixture('with-auto-updates'))
	return cask_info_spec_bool(output.contains('(AutoUpdates): 1.0 (auto_updates)'))
}

// Ruby it `it "prints pinned cask metadata" do` at line 159.
pub fn ruby_info_spec_l159_d13_prints(args ...ruby.Value) ruby.Value {
	fixture := cask_info.CaskInfoModel{
		...cask_info_spec_fixture('local-caffeine')
		pinned: true
		pinned_version: '1.2.3'
		pin_time: 1_720_189_863
	}
	output := cask_info.cask_info_get(fixture)
	return cask_info_spec_bool(output.contains('Pinned: 1.2.3 on ') && output.contains(' at '))
}

// Ruby it `it "prints caveats if the Cask provided one" do` at line 171.
pub fn ruby_info_spec_l171_d14_prints(args ...ruby.Value) ruby.Value {
	output := cask_info.cask_info_get(cask_info_spec_fixture('with-caveats'))
	return cask_info_spec_bool(output.contains('Caveats') && output.contains('Here are some things you might want to know.') && output.contains('Cask token: with-caveats'))
}

// Ruby it `it 'does not print "Caveats" section divider if the caveats block has no output' do` at line 197.
pub fn ruby_info_spec_l197_d15_does(args ...ruby.Value) ruby.Value {
	return cask_info_spec_bool(!cask_info.cask_info_get(cask_info_spec_fixture('with-conditional-caveats')).contains('Caveats'))
}

// Ruby it `it "prints languages specified in the Cask" do` at line 213.
pub fn ruby_info_spec_l213_d16_prints(args ...ruby.Value) ruby.Value {
	output := cask_info.cask_info_get(cask_info_spec_fixture('with-languages'))
	return cask_info_spec_bool(output.contains('Languages') && output.contains('zh, en-US'))
}

// Ruby it `it 'does not print "Languages" section divider if the languages block has no output' do` at line 231.
pub fn ruby_info_spec_l231_d17_does(args ...ruby.Value) ruby.Value {
	return cask_info_spec_bool(!cask_info.cask_info_get(cask_info_spec_fixture('without-languages')).contains('Languages'))
}

fn cask_info_spec_installed_api(internal bool) bool {
	root := os.join_path(os.temp_dir(), 'brew-v-cask-info-${os.getpid()}-${time.now().unix_micro()}')
	version_path := os.join_path(root, '2.61')
	os.mkdir_all(version_path) or { return false }
	tabfile := os.join_path(root, 'receipt.json')
	os.write_file(tabfile, '{}') or {
		os.rmdir_all(root) or {}
		return false
	}
	defer {
		os.rmdir_all(root) or {}
	}
	fixture := cask_info.CaskInfoModel{
		...cask_info_spec_fixture('local-transmission')
		installed: true
		installed_version: '2.61'
		caskroom_path: root
		tab: cask_info.CaskInfoTab{
			loaded_from_api: true
			loaded_from_internal_api: internal
			tabfile: tabfile
			time: 1_720_189_863
		}
	}
	output := cask_info.cask_info_get(fixture)
	expected_api := if internal { 'internal formulae.brew.sh API' } else { 'formulae.brew.sh API' }
	return output.contains('Installed (as dependency)') && output.contains('${version_path} (0B)') && output.contains('Installed using the ${expected_api} on ')
}

// Ruby it `it "prints install information for an installed Cask loaded from the API" do` at line 247.
pub fn ruby_info_spec_l247_d18_prints(args ...ruby.Value) ruby.Value {
	return cask_info_spec_bool(cask_info_spec_installed_api(false))
}

// Ruby it `it "prints install information for an installed Cask loaded from the internal API" do` at line 282.
pub fn ruby_info_spec_l282_d19_prints(args ...ruby.Value) ruby.Value {
	return cask_info_spec_bool(cask_info_spec_installed_api(true))
}

// Ruby it `it "shows requirements" do` at line 317.
pub fn ruby_info_spec_l317_d20_shows(args ...ruby.Value) ruby.Value {
	output := cask_info.cask_info_get(cask_info_spec_fixture('with-non-executable-binary'))
	return cask_info_spec_bool(!output.contains('Requirements') && output.contains('naked_non_executable (Binary)'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils"
// 5: require "cask/info"
// 6:
// 7: RSpec.describe Cask::Info, :cask do
// 8:   let(:args) { instance_double(Homebrew::Cmd::Info::Args) }
// 9:
// 10:   include Utils::Output::Mixin
// 11:
// 12:   def uninstalled(string)
// 13:     "#{Tty.bold}#{string} #{Formatter.error("✘")}#{Tty.reset}"
// 14:   end
// 15:
// 16:   def installed(string)
// 17:     "#{Tty.bold}#{string} #{Formatter.success("✔")}#{Tty.reset}"
// 18:   end
// 19:
// 20:   def requirements_section(string)
// 21:     <<~EOS.chomp
// 22:       #{ohai_title "Requirements"}
// 23:       Required: #{string}
// 24:     EOS
// 25:   end
// 26:
// 27:   def mock_cask_installed(cask_name)
// 28:     cask = Cask::CaskLoader.load(cask_name)
// 29:     allow(cask).to receive(:installed?).and_return(true)
// 30:     allow(Cask::CaskLoader).to receive(:load).and_call_original
// 31:     allow(Cask::CaskLoader).to receive(:load).with(cask_name).and_return(cask)
// 32:     allow(Cask::Info).to receive(:installation_info).and_wrap_original do |method, arg, **kwargs|
// 33:       (arg.token == cask_name) ? "Installed" : method.call(arg, **kwargs)
// 34:     end
// 35:     (Cask::Caskroom.path/cask_name).mkpath
// 36:   end
// 37:
// 38:   before do
// 39:     # Prevent unnecessary network requests in `Utils::Analytics.cask_output`
// 40:     ENV["HOMEBREW_NO_ANALYTICS"] = "1"
// 41:   end
// 42:
// 43:   it "displays some nice info about the specified Cask" do
// 44:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 45:
// 46:     expect do
// 47:       described_class.info(Cask::CaskLoader.load("local-transmission"), args:)
// 48:     end.to output(<<~EOS).to_stdout
// 49:       #{oh1_title uninstalled("local-transmission")} (Transmission): 2.61
// 50:       BitTorrent client
// 51:       https://transmissionbt.com/
// 52:       Not installed
// 53:       From: https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/l/local-transmission.rb
// 54:       #{requirements_section(installed("macOS >= 10.15"))}
// 55:       ==> Artifacts
// 56:       Transmission.app (App)
// 57:     EOS
// 58:   end
// 59:
// 60:   it "omits a missing cask name and description" do
// 61:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 62:
// 63:     expect do
// 64:       described_class.info(Cask::CaskLoader.load("with-depends-on-cask-multiple"), args:)
// 65:     end.to output(<<~EOS).to_stdout
// 66:       #{oh1_title uninstalled("with-depends-on-cask-multiple")}: 1.2.3
// 67:       #{Formatter.url("https://brew.sh/with-depends-on-cask-multiple")}
// 68:       Not installed
// 69:       From: #{Formatter.url("https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/w/with-depends-on-cask-multiple.rb")}
// 70:       #{ohai_title "Dependencies"}
// 71:       Required (2): local-caffeine (cask), local-transmission-zip (cask)
// 72:       Recursive Runtime (2): 0 installed #{Formatter.success("✔")}, 2 missing #{Formatter.error("✘")}
// 73:       #{requirements_section(installed("macOS >= 10.15"))}
// 74:       #{ohai_title "Artifacts"}
// 75:       Caffeine.app (App)
// 76:     EOS
// 77:   end
// 78:
// 79:   it "prints inline summary information for casks" do
// 80:     cask = Cask::CaskLoader.load("local-transmission")
// 81:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 82:     allow(cask).to receive_messages(supports_linux?: false)
// 83:
// 84:     expect { described_class.info(cask, args:) }
// 85:       .to output(/Requirements\nRequired: .*macOS >= 10\.15.*✔/).to_stdout
// 86:     expect { described_class.info(cask, args:) }.to not_to_output(/==> Name/).to_stdout
// 87:     expect { described_class.info(cask, args:) }.to not_to_output(/==> Description/).to_stdout
// 88:     expect { described_class.info(cask, args:) }.to not_to_output(/Metadata/).to_stdout
// 89:   end
// 90:
// 91:   it "prints cask dependencies if the Cask has any" do
// 92:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 93:     mock_cask_installed("local-transmission-zip")
// 94:     expect do
// 95:       described_class.info(Cask::CaskLoader.load("with-depends-on-cask-multiple"), args:)
// 96:     end.to output(<<~EOS).to_stdout
// 97:       #{oh1_title uninstalled("with-depends-on-cask-multiple")}: 1.2.3
// 98:       #{Formatter.url("https://brew.sh/with-depends-on-cask-multiple")}
// 99:       Not installed
// 100:       From: #{Formatter.url("https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/w/with-depends-on-cask-multiple.rb")}
// 101:       #{ohai_title "Dependencies"}
// 102:       Required (2): local-caffeine (cask), #{installed("local-transmission-zip (cask)")}
// 103:       Recursive Runtime (2): 1 installed #{Formatter.success("✔")}, 1 missing #{Formatter.error("✘")}
// 104:       #{requirements_section(installed("macOS >= 10.15"))}
// 105:       #{ohai_title "Artifacts"}
// 106:       Caffeine.app (App)
// 107:     EOS
// 108:   end
// 109:
// 110:   it "summarises recursive runtime dependencies as all installed when none are missing" do
// 111:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 112:     mock_cask_installed("local-caffeine")
// 113:     mock_cask_installed("local-transmission-zip")
// 114:     expect do
// 115:       described_class.info(Cask::CaskLoader.load("with-depends-on-cask-multiple"), args:)
// 116:     end.to output(/Recursive Runtime \(2\): all installed #{Formatter.success("✔")}/).to_stdout
// 117:   end
// 118:
// 119:   it "prints cask and formulas dependencies if the Cask has both" do
// 120:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 121:     arch_requirements = if Hardware::CPU.arm?
// 122:       "x86_64 architecture, #{installed("arm64 architecture")}"
// 123:     else
// 124:       "#{installed("x86_64 architecture")}, arm64 architecture"
// 125:     end
// 126:
// 127:     expect do
// 128:       described_class.info(Cask::CaskLoader.load("with-depends-on-everything"), args:)
// 129:     end.to output(<<~EOS).to_stdout
// 130:       #{oh1_title uninstalled("with-depends-on-everything")}: 1.2.3
// 131:       #{Formatter.url("https://brew.sh/with-depends-on-everything")}
// 132:       Not installed
// 133:       From: #{Formatter.url("https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/w/with-depends-on-everything.rb")}
// 134:       #{ohai_title "Dependencies"}
// 135:       Required (3): unar, local-caffeine (cask), with-depends-on-cask (cask)
// 136:       Recursive Runtime (4): 0 installed #{Formatter.success("✔")}, 4 missing #{Formatter.error("✘")}
// 137:       #{requirements_section("#{arch_requirements}, #{installed("macOS >= 10.15")}")}
// 138:       #{ohai_title "Artifacts"}
// 139:       Caffeine.app (App)
// 140:     EOS
// 141:   end
// 142:
// 143:   it "prints auto_updates if the Cask has `auto_updates true`" do
// 144:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 145:
// 146:     expect do
// 147:       described_class.info(Cask::CaskLoader.load("with-auto-updates"), args:)
// 148:     end.to output(<<~EOS).to_stdout
// 149:       #{oh1_title uninstalled("with-auto-updates")} (AutoUpdates): 1.0 (auto_updates)
// 150:       https://brew.sh/autoupdates
// 151:       Not installed
// 152:       From: https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/w/with-auto-updates.rb
// 153:       #{requirements_section(installed("macOS >= 10.15"))}
// 154:       ==> Artifacts
// 155:       AutoUpdates.app (App)
// 156:     EOS
// 157:   end
// 158:
// 159:   it "prints pinned cask metadata" do
// 160:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 161:     cask = Cask::CaskLoader.load("local-caffeine")
// 162:     InstallHelper.stub_cask_installation(cask)
// 163:     cask.pin
// 164:
// 165:     expect { described_class.info(cask, args:) }
// 166:       .to output(/Pinned: 1\.2\.3 on \d{4}-\d{2}-\d{2} at \d{2}:\d{2}:\d{2}/).to_stdout
// 167:
// 168:     cask.unpin
// 169:   end
// 170:
// 171:   it "prints caveats if the Cask provided one" do
// 172:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 173:
// 174:     expect do
// 175:       described_class.info(Cask::CaskLoader.load("with-caveats"), args:)
// 176:     end.to output(<<~EOS).to_stdout
// 177:       #{oh1_title uninstalled("with-caveats")}: 1.2.3
// 178:       https://brew.sh/
// 179:       Not installed
// 180:       From: https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/w/with-caveats.rb
// 181:       #{requirements_section(installed("macOS >= 10.15"))}
// 182:       ==> Artifacts
// 183:       Caffeine.app (App)
// 184:       ==> Caveats
// 185:       Here are some things you might want to know.
// 186:
// 187:       Cask token: with-caveats
// 188:
// 189:       Custom text via puts followed by DSL-generated text:
// 190:       To use with-caveats, you may need to add the /custom/path/bin directory
// 191:       to your PATH environment variable, e.g. (for Bash shell):
// 192:         export PATH=/custom/path/bin:"$PATH"
// 193:
// 194:     EOS
// 195:   end
// 196:
// 197:   it 'does not print "Caveats" section divider if the caveats block has no output' do
// 198:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 199:
// 200:     expect do
// 201:       described_class.info(Cask::CaskLoader.load("with-conditional-caveats"), args:)
// 202:     end.to output(<<~EOS).to_stdout
// 203:       #{oh1_title uninstalled("with-conditional-caveats")}: 1.2.3
// 204:       https://brew.sh/
// 205:       Not installed
// 206:       From: https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/w/with-conditional-caveats.rb
// 207:       #{requirements_section(installed("macOS >= 10.15"))}
// 208:       ==> Artifacts
// 209:       Caffeine.app (App)
// 210:     EOS
// 211:   end
// 212:
// 213:   it "prints languages specified in the Cask" do
// 214:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 215:
// 216:     expect do
// 217:       described_class.info(Cask::CaskLoader.load("with-languages"), args:)
// 218:     end.to output(<<~EOS).to_stdout
// 219:       #{oh1_title uninstalled("with-languages")} (Caffeine): 1.2.3
// 220:       https://brew.sh/
// 221:       Not installed
// 222:       From: https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/w/with-languages.rb
// 223:       #{requirements_section(installed("macOS >= 10.15"))}
// 224:       ==> Languages
// 225:       zh, en-US
// 226:       ==> Artifacts
// 227:       Caffeine.app (App)
// 228:     EOS
// 229:   end
// 230:
// 231:   it 'does not print "Languages" section divider if the languages block has no output' do
// 232:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 233:
// 234:     expect do
// 235:       described_class.info(Cask::CaskLoader.load("without-languages"), args:)
// 236:     end.to output(<<~EOS).to_stdout
// 237:       #{oh1_title uninstalled("without-languages")}: 1.2.3
// 238:       https://brew.sh/
// 239:       Not installed
// 240:       From: https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/w/without-languages.rb
// 241:       #{requirements_section(installed("macOS >= 10.15"))}
// 242:       ==> Artifacts
// 243:       Caffeine.app (App)
// 244:     EOS
// 245:   end
// 246:
// 247:   it "prints install information for an installed Cask loaded from the API" do
// 248:     mktmpdir do |caskroom|
// 249:       FileUtils.mkdir caskroom/"2.61"
// 250:
// 251:       cask = Cask::CaskLoader.load("local-transmission")
// 252:       time = 1_720_189_863
// 253:       tab = Cask::Tab.new(
// 254:         loaded_from_api:      true,
// 255:         installed_on_request: false,
// 256:         tabfile:              TEST_FIXTURE_DIR/"cask_receipt.json",
// 257:         time:,
// 258:       )
// 259:       allow(cask).to receive(:installed?).and_return(true)
// 260:       expect(cask).to receive(:caskroom_path).and_return(caskroom)
// 261:       expect(cask).to receive(:installed_version).and_return("2.61")
// 262:       allow(Cask::Tab).to receive(:for_cask).with(cask).and_return(tab)
// 263:       allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 264:
// 265:       expect do
// 266:         described_class.info(cask, args:)
// 267:       end.to output(<<~EOS).to_stdout
// 268:         ==> #{installed("local-transmission")} (Transmission): 2.61
// 269:         BitTorrent client
// 270:         https://transmissionbt.com/
// 271:         Installed (as dependency)
// 272:         #{caskroom}/2.61 (0B)
// 273:           Installed using the formulae.brew.sh API on #{Time.at(time).strftime("%Y-%m-%d at %H:%M:%S")}
// 274:         From: https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/l/local-transmission.rb
// 275:         #{requirements_section(installed("macOS >= 10.15"))}
// 276:         ==> Artifacts
// 277:         Transmission.app (App)
// 278:       EOS
// 279:     end
// 280:   end
// 281:
// 282:   it "prints install information for an installed Cask loaded from the internal API" do
// 283:     mktmpdir do |caskroom|
// 284:       FileUtils.mkdir caskroom/"2.61"
// 285:
// 286:       cask = Cask::CaskLoader.load("local-transmission")
// 287:       time = 1_720_189_863
// 288:       tab = Cask::Tab.new(
// 289:         loaded_from_api:          true,
// 290:         loaded_from_internal_api: true,
// 291:         tabfile:                  TEST_FIXTURE_DIR/"cask_receipt.json",
// 292:         time:,
// 293:       )
// 294:       allow(cask).to receive(:installed?).and_return(true)
// 295:       expect(cask).to receive(:caskroom_path).and_return(caskroom)
// 296:       expect(cask).to receive(:installed_version).and_return("2.61")
// 297:       allow(Cask::Tab).to receive(:for_cask).with(cask).and_return(tab)
// 298:       allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 299:
// 300:       expect do
// 301:         described_class.info(cask, args:)
// 302:       end.to output(<<~EOS).to_stdout
// 303:         ==> #{installed("local-transmission")} (Transmission): 2.61
// 304:         BitTorrent client
// 305:         https://transmissionbt.com/
// 306:         Installed (as dependency)
// 307:         #{caskroom}/2.61 (0B)
// 308:           Installed using the internal formulae.brew.sh API on #{Time.at(time).strftime("%Y-%m-%d at %H:%M:%S")}
// 309:         From: https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/l/local-transmission.rb
// 310:         #{requirements_section(installed("macOS >= 10.15"))}
// 311:         ==> Artifacts
// 312:         Transmission.app (App)
// 313:       EOS
// 314:     end
// 315:   end
// 316:
// 317:   it "shows requirements" do
// 318:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 319:
// 320:     expect do
// 321:       described_class.info(Cask::CaskLoader.load("with-non-executable-binary"), args:)
// 322:     end.to output(<<~EOS).to_stdout
// 323:       #{oh1_title uninstalled("with-non-executable-binary")}: 1.2.3
// 324:       https://brew.sh/with-binary
// 325:       Not installed
// 326:       From: https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/w/with-non-executable-binary.rb
// 327:       ==> Artifacts
// 328:       naked_non_executable (Binary)
// 329:     EOS
// 330:   end
// 331: end
