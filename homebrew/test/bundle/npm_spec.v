module bundle

import ruby
import homebrew.bundle.extensions

// Translated from Homebrew/brew `test/bundle/npm_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn npm_spec_packages() []string {
	return ['vercel', 'typescript', 'prettier']
}

fn npm_spec_case(line int) bool {
	packages := npm_spec_packages()
	match line {
		19 {
			mut state := extensions.new_npm_state()
			listed := state.discover_packages()
			return listed.len == 0 && extensions.npm_dump(listed) == ''
		}
		31 {
			return extensions.npm_parse_package_list('{"dependencies":{"npm":{"version":"11.11.0"},"vercel":{"version":"39.0.0"},"typescript":{"version":"5.7.3"}}}') == packages[..2]
		}
		45 {
			mut state := extensions.new_npm_state()
			state.executable = '/opt/homebrew/bin/npm'
			state.executable_exists = true
			state.original_path = '/usr/bin:/bin'
			state.list_output = '{"dependencies":{"eslint":{"version":"10.4.0"}}}'
			return state.discover_packages() == ['eslint'] && state.last_environment['PATH'].starts_with('/opt/homebrew/bin:')
		}
		59 {
			return extensions.npm_parse_package_list('{"dependencies":{"npm":{"version":"11.11.0"}}}').len == 0
		}
		71 {
			return extensions.npm_parse_package_list('not json').len == 0
		}
		77 {
			return extensions.npm_parse_package_list('').len == 0
		}
		83 {
			return extensions.npm_dump(packages[..2]) == 'npm "vercel"\nnpm "typescript"'
		}
		100 {
			entries := [extensions.ExtensionEntry{
				entry_type: 'npm'
				name: 'vercel'
			}]
			return extensions.npm_cleanup_items(entries, '/opt/homebrew/bin/npm', packages) == packages[1..]
		}
		105 {
			entries := packages.map(extensions.ExtensionEntry{
				entry_type: 'npm'
				name: it
			})
			return extensions.npm_cleanup_items(entries, '/opt/homebrew/bin/npm', packages).len == 0
		}
		114 {
			return extensions.npm_cleanup_items([extensions.ExtensionEntry{
				entry_type: 'npm'
				name: 'vercel'
			}], '', packages).len == 0
		}
		128 {
			if _ := extensions.npm_preinstall('', [], 'vercel') {
				return false
			}
			return true
		}
		147 {
			return !(extensions.npm_preinstall('npm', ['vercel'], 'vercel') or { return false })
		}
		161 {
			mut state := extensions.new_npm_state()
			state.executable = '/opt/homebrew/bin/npm'
			state.executable_exists = true
			state.cache_dir = '/homebrew/cache'
			state.packages_loaded = true
			state.installed_packages_loaded = true
			preinstall := extensions.npm_preinstall(state.executable, state.installed_packages, 'vercel') or { return false }
			installed := state.install('vercel', true, false, true) or { return false }
			return preinstall && installed && state.commands == [[
				'/opt/homebrew/bin/npm',
				'install',
				'--min-release-age=1',
				'--cache=/homebrew/cache/npm_cache',
				'--ignore-scripts',
				'-g',
				'vercel',
			]]
		}
		else {
			return false
		}
	}
}

// Ruby subject `subject(:dumper) { described_class }` at line 11.
pub fn ruby_npm_spec_l11_d1_dumper(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Homebrew::Bundle::Npm', 'Homebrew::Bundle::Npm')
}

// Ruby specify `specify do` at line 19.
pub fn ruby_npm_spec_l19_d2_do(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(19))
}

// Ruby it `it "returns package list" do` at line 31.
pub fn ruby_npm_spec_l31_d3_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(31))
}

// Ruby it `it "adds npm's directory to PATH when listing packages" do` at line 45.
pub fn ruby_npm_spec_l45_d4_adds(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(45))
}

// Ruby it `it "excludes npm itself from the package list" do` at line 59.
pub fn ruby_npm_spec_l59_d5_excludes(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(59))
}

// Ruby it `it "handles invalid JSON" do` at line 71.
pub fn ruby_npm_spec_l71_d6_handles(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(71))
}

// Ruby it `it "handles empty output" do` at line 77.
pub fn ruby_npm_spec_l77_d7_handles(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(77))
}

// Ruby it `it "dumps package list" do` at line 83.
pub fn ruby_npm_spec_l83_d8_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(83))
}

// Ruby it `it "returns packages not in Brewfile entries" do` at line 100.
pub fn ruby_npm_spec_l100_d9_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(100))
}

// Ruby it `it "returns empty when all packages are in Brewfile" do` at line 105.
pub fn ruby_npm_spec_l105_d10_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(105))
}

// Ruby it `it "returns frozen empty array when npm is not installed" do` at line 114.
pub fn ruby_npm_spec_l114_d11_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(114))
}

// Ruby it `it "tries to install node" do` at line 128.
pub fn ruby_npm_spec_l128_d12_tries(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(128))
}

// Ruby it `it "skips" do` at line 147.
pub fn ruby_npm_spec_l147_d13_skips(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(147))
}

// Ruby it `it "installs package" do` at line 161.
pub fn ruby_npm_spec_l161_d14_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(npm_spec_case(161))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions/npm"
// 7: require "language/node"
// 8:
// 9: RSpec.describe Homebrew::Bundle::Npm do
// 10:   describe "dumping" do
// 11:     subject(:dumper) { described_class }
// 12:
// 13:     context "when npm is not installed" do
// 14:       before do
// 15:         described_class.reset!
// 16:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 17:       end
// 18:
// 19:       specify do
// 20:         expect(dumper.packages).to be_empty
// 21:         expect(dumper.dump).to eql("")
// 22:       end
// 23:     end
// 24:
// 25:     context "when npm is installed" do
// 26:       before do
// 27:         described_class.reset!
// 28:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("npm"))
// 29:       end
// 30:
// 31:       it "returns package list" do
// 32:         allow(described_class).to receive(:`).with("npm list -g --depth=0 --json 2>/dev/null").and_return(<<~JSON)
// 33:           {
// 34:             "dependencies": {
// 35:               "npm": { "version": "11.11.0" },
// 36:               "vercel": { "version": "39.0.0" },
// 37:               "typescript": { "version": "5.7.3" }
// 38:             }
// 39:           }
// 40:         JSON
// 41:
// 42:         expect(dumper.packages).to eql(%w[vercel typescript])
// 43:       end
// 44:
// 45:       it "adds npm's directory to PATH when listing packages" do
// 46:         npm = mktmpdir/"bin/npm"
// 47:         npm.dirname.mkpath
// 48:         npm.write("")
// 49:
// 50:         allow(described_class).to receive(:package_manager_executable).and_return(npm)
// 51:         expect(described_class).to receive(:`).with("#{npm} list -g --depth=0 --json 2>/dev/null") do
// 52:           expect(ENV.fetch("PATH", "")).to start_with("#{npm.dirname}:")
// 53:           '{"dependencies":{"eslint":{"version":"10.4.0"}}}'
// 54:         end
// 55:
// 56:         expect(dumper.packages).to eql(["eslint"])
// 57:       end
// 58:
// 59:       it "excludes npm itself from the package list" do
// 60:         allow(described_class).to receive(:`).with("npm list -g --depth=0 --json 2>/dev/null").and_return(<<~JSON)
// 61:           {
// 62:             "dependencies": {
// 63:               "npm": { "version": "11.11.0" }
// 64:             }
// 65:           }
// 66:         JSON
// 67:
// 68:         expect(dumper.packages).to be_empty
// 69:       end
// 70:
// 71:       it "handles invalid JSON" do
// 72:         allow(described_class).to receive(:`).with("npm list -g --depth=0 --json 2>/dev/null").and_return("not json")
// 73:
// 74:         expect(dumper.packages).to be_empty
// 75:       end
// 76:
// 77:       it "handles empty output" do
// 78:         allow(described_class).to receive(:`).with("npm list -g --depth=0 --json 2>/dev/null").and_return("")
// 79:
// 80:         expect(dumper.packages).to be_empty
// 81:       end
// 82:
// 83:       it "dumps package list" do
// 84:         allow(dumper).to receive(:packages).and_return(["vercel", "typescript"])
// 85:         expect(dumper.dump).to eql("npm \"vercel\"\nnpm \"typescript\"")
// 86:       end
// 87:     end
// 88:   end
// 89:
// 90:   describe "cleanup" do
// 91:     before do
// 92:       described_class.reset!
// 93:       allow(described_class).to receive_messages(
// 94:         package_manager_executable: Pathname.new("/opt/homebrew/bin/npm"),
// 95:         packages:                   %w[vercel typescript prettier],
// 96:         installed_packages:         %w[vercel typescript prettier],
// 97:       )
// 98:     end
// 99:
// 100:     it "returns packages not in Brewfile entries" do
// 101:       entries = [Homebrew::Bundle::Dsl::Entry.new(:npm, "vercel")]
// 102:       expect(described_class.cleanup_items(entries)).to eql(%w[typescript prettier])
// 103:     end
// 104:
// 105:     it "returns empty when all packages are in Brewfile" do
// 106:       entries = [
// 107:         Homebrew::Bundle::Dsl::Entry.new(:npm, "vercel"),
// 108:         Homebrew::Bundle::Dsl::Entry.new(:npm, "typescript"),
// 109:         Homebrew::Bundle::Dsl::Entry.new(:npm, "prettier"),
// 110:       ]
// 111:       expect(described_class.cleanup_items(entries)).to eql([])
// 112:     end
// 113:
// 114:     it "returns frozen empty array when npm is not installed" do
// 115:       allow(described_class).to receive(:package_manager_installed?).and_return(false)
// 116:       entries = [Homebrew::Bundle::Dsl::Entry.new(:npm, "vercel")]
// 117:       expect(described_class.cleanup_items(entries)).to eql([])
// 118:     end
// 119:   end
// 120:
// 121:   describe "installing" do
// 122:     context "when npm is not installed" do
// 123:       before do
// 124:         described_class.reset!
// 125:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 126:       end
// 127:
// 128:       it "tries to install node" do
// 129:         expect(Homebrew::Bundle).to \
// 130:           receive(:system).with(HOMEBREW_BREW_FILE, "install", "--formula", "node", verbose: false)
// 131:                           .and_return(true)
// 132:         expect { described_class.preinstall!("vercel") }.to raise_error(RuntimeError)
// 133:       end
// 134:     end
// 135:
// 136:     context "when npm is installed" do
// 137:       before do
// 138:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("npm"))
// 139:       end
// 140:
// 141:       context "when package is installed" do
// 142:         before do
// 143:           allow(described_class).to receive(:installed_packages)
// 144:             .and_return(["vercel"])
// 145:         end
// 146:
// 147:         it "skips" do
// 148:           expect(Homebrew::Bundle).not_to receive(:system)
// 149:           expect(described_class.preinstall!("vercel")).to be(false)
// 150:         end
// 151:       end
// 152:
// 153:       context "when package is not installed" do
// 154:         before do
// 155:           allow(described_class).to receive_messages(
// 156:             package_manager_executable: Pathname.new("/opt/homebrew/bin/npm"),
// 157:             installed_packages:         [],
// 158:           )
// 159:         end
// 160:
// 161:         it "installs package" do
// 162:           expect(Homebrew::Bundle).to receive(:system)
// 163:             .with(
// 164:               "/opt/homebrew/bin/npm",
// 165:               "install",
// 166:               "--min-release-age=1",
// 167:               "--cache=#{HOMEBREW_CACHE}/npm_cache",
// 168:               "--ignore-scripts",
// 169:               "-g",
// 170:               "vercel",
// 171:               verbose: false,
// 172:             )
// 173:             .and_return(true)
// 174:           expect(described_class.preinstall!("vercel")).to be(true)
// 175:           expect(described_class.install!("vercel")).to be(true)
// 176:         end
// 177:       end
// 178:     end
// 179:   end
// 180: end
