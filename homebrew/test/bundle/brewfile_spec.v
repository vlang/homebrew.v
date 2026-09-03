module bundle

import homebrew.bundle as brew_bundle

// Translated from Homebrew/brew `test/bundle/brewfile_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const brewfile_spec_working_directory = '/workspace'
const brewfile_spec_user_config_home = '/Users/username/.homebrew'
const brewfile_spec_home = '/Users/username'

pub struct BrewfileSpecContext {
pub:
	dash_writes_to_stdout  bool
	env_bundle_file_global string
	env_bundle_file        string
	user_config_home       string = brewfile_spec_user_config_home
	home_directory         string = brewfile_spec_home
	file                   ?string
	global                 bool
	config_dir_exists      bool
	config_brewfile_exists bool
	home_brewfile_exists   bool
	working_directory      string = brewfile_spec_working_directory
}

pub fn brewfile_spec_context() BrewfileSpecContext {
	return BrewfileSpecContext{}
}

pub fn brewfile_spec_path(context BrewfileSpecContext) !string {
	return brew_bundle.resolve_bundle_brewfile_path(brew_bundle.BundleBrewfilePathConfig{
		global: context.global
		file: context.file
		working_directory: context.working_directory
		home_directory: context.home_directory
		env_bundle_file_global: context.env_bundle_file_global
		env_bundle_file: context.env_bundle_file
		user_config_home: context.user_config_home
		user_config_home_exists: context.config_dir_exists
		user_config_brewfile_exists: context.config_brewfile_exists
		home_brewfile_exists: context.home_brewfile_exists
	}, context.dash_writes_to_stdout)!
}

fn brewfile_spec_path_matches(context BrewfileSpecContext, expected string) bool {
	path := brewfile_spec_path(context) or { return false }
	return path == expected
}

// Ruby subject `subject(:path) do` at line 9.
pub fn ruby_brewfile_spec_l9_d1_path(context BrewfileSpecContext) !string {
	return brewfile_spec_path(context)!
}

// Ruby let `let(:dash_writes_to_stdout) { false }` at line 13.
pub fn ruby_brewfile_spec_l13_d2_dash_writes_to_stdout() bool {
	return false
}

// Ruby let `let(:env_bundle_file_global_value) { nil }` at line 14.
pub fn ruby_brewfile_spec_l14_d3_env_bundle_file_global_value() ?string {
	return none
}

// Ruby let `let(:env_bundle_file_value) { nil }` at line 15.
pub fn ruby_brewfile_spec_l15_d4_env_bundle_file_value() ?string {
	return none
}

// Ruby let `let(:env_user_config_home_value) { "/Users/username/.homebrew" }` at line 16.
pub fn ruby_brewfile_spec_l16_d5_env_user_config_home_value() string {
	return brewfile_spec_user_config_home
}

// Ruby let `let(:env_home_value) { "/Users/username" }` at line 17.
pub fn ruby_brewfile_spec_l17_d6_env_home_value() string {
	return brewfile_spec_home
}

// Ruby let `let(:file_value) { nil }` at line 18.
pub fn ruby_brewfile_spec_l18_d7_file_value() ?string {
	return none
}

// Ruby let `let(:has_global) { false }` at line 19.
pub fn ruby_brewfile_spec_l19_d8_has_global() bool {
	return false
}

// Ruby let `let(:config_dir_exist) { false }` at line 20.
pub fn ruby_brewfile_spec_l20_d9_config_dir_exist() bool {
	return false
}

// Ruby let `let(:config_dir_brewfile_exist) { false }` at line 21.
pub fn ruby_brewfile_spec_l21_d10_config_dir_brewfile_exist() bool {
	return false
}

// Ruby let `let(:home_dir_brewfile_exist) { false }` at line 22.
pub fn ruby_brewfile_spec_l22_d11_home_dir_brewfile_exist() bool {
	return false
}

// Ruby let `let(:file_value) { "path/to/Brewfile" }` at line 43.
pub fn ruby_brewfile_spec_l43_d12_file_value() string {
	return 'path/to/Brewfile'
}

// Ruby let `let(:expected_pathname) { Pathname.new(file_value).expand_path(Dir.pwd) }` at line 44.
pub fn ruby_brewfile_spec_l44_d13_expected_pathname() string {
	return '${brewfile_spec_working_directory}/path/to/Brewfile'
}

// Ruby it `it "returns the expected path" do` at line 46.
pub fn ruby_brewfile_spec_l46_d14_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{ file: 'path/to/Brewfile' }, ruby_brewfile_spec_l44_d13_expected_pathname())
}

// Ruby let `let(:env_bundle_file_value) { "/path/to/Brewfile" }` at line 51.
pub fn ruby_brewfile_spec_l51_d15_env_bundle_file_value() string {
	return '/path/to/Brewfile'
}

// Ruby it `it "returns the value specified by `file` path" do` at line 53.
pub fn ruby_brewfile_spec_l53_d16_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		file: 'path/to/Brewfile'
		env_bundle_file: '/path/to/Brewfile'
	}, ruby_brewfile_spec_l44_d13_expected_pathname())
}

// Ruby let `let(:env_bundle_file_value) { "" }` at line 59.
pub fn ruby_brewfile_spec_l59_d17_env_bundle_file_value() string {
	return ''
}

// Ruby it `it "returns the value specified by `file` path" do` at line 61.
pub fn ruby_brewfile_spec_l61_d18_returns() bool {
	return ruby_brewfile_spec_l46_d14_returns()
}

// Ruby let `let(:file_value) { "/tmp/random_file" }` at line 68.
pub fn ruby_brewfile_spec_l68_d19_file_value() string {
	return '/tmp/random_file'
}

// Ruby let `let(:expected_pathname) { Pathname.new(file_value) }` at line 69.
pub fn ruby_brewfile_spec_l69_d20_expected_pathname() string {
	return '/tmp/random_file'
}

// Ruby it `it "returns the expected path" do` at line 71.
pub fn ruby_brewfile_spec_l71_d21_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{ file: '/tmp/random_file' }, '/tmp/random_file')
}

// Ruby let `let(:env_bundle_file_value) { "/path/to/Brewfile" }` at line 76.
pub fn ruby_brewfile_spec_l76_d22_env_bundle_file_value() string {
	return '/path/to/Brewfile'
}

// Ruby it `it "returns the value specified by `file` path" do` at line 78.
pub fn ruby_brewfile_spec_l78_d23_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		file: '/tmp/random_file'
		env_bundle_file: '/path/to/Brewfile'
	}, '/tmp/random_file')
}

// Ruby let `let(:env_bundle_file_value) { "" }` at line 84.
pub fn ruby_brewfile_spec_l84_d24_env_bundle_file_value() string {
	return ''
}

// Ruby it `it "returns the value specified by `file` path" do` at line 86.
pub fn ruby_brewfile_spec_l86_d25_returns() bool {
	return ruby_brewfile_spec_l71_d21_returns()
}

// Ruby let `let(:file_value) { "-" }` at line 93.
pub fn ruby_brewfile_spec_l93_d26_file_value() string {
	return '-'
}

// Ruby let `let(:expected_pathname) { Pathname.new("/dev/stdin") }` at line 94.
pub fn ruby_brewfile_spec_l94_d27_expected_pathname() string {
	return '/dev/stdin'
}

// Ruby it `it "returns stdin by default" do` at line 96.
pub fn ruby_brewfile_spec_l96_d28_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{ file: '-' }, '/dev/stdin')
}

// Ruby let `let(:env_bundle_file_value) { "/path/to/Brewfile" }` at line 101.
pub fn ruby_brewfile_spec_l101_d29_env_bundle_file_value() string {
	return '/path/to/Brewfile'
}

// Ruby it `it "returns the value specified by `file` path" do` at line 103.
pub fn ruby_brewfile_spec_l103_d30_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		file: '-'
		env_bundle_file: '/path/to/Brewfile'
	}, '/dev/stdin')
}

// Ruby let `let(:env_bundle_file_value) { "" }` at line 109.
pub fn ruby_brewfile_spec_l109_d31_env_bundle_file_value() string {
	return ''
}

// Ruby it `it "returns the value specified by `file` path" do` at line 111.
pub fn ruby_brewfile_spec_l111_d32_returns() bool {
	return ruby_brewfile_spec_l96_d28_returns()
}

// Ruby let `let(:expected_pathname) { Pathname.new("/dev/stdout") }` at line 117.
pub fn ruby_brewfile_spec_l117_d33_expected_pathname() string {
	return '/dev/stdout'
}

// Ruby let `let(:dash_writes_to_stdout) { true }` at line 118.
pub fn ruby_brewfile_spec_l118_d34_dash_writes_to_stdout() bool {
	return true
}

// Ruby it `it "returns stdout" do` at line 120.
pub fn ruby_brewfile_spec_l120_d35_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		file: '-'
		dash_writes_to_stdout: true
	}, '/dev/stdout')
}

// Ruby let `let(:env_bundle_file_value) { "/path/to/Brewfile" }` at line 125.
pub fn ruby_brewfile_spec_l125_d36_env_bundle_file_value() string {
	return '/path/to/Brewfile'
}

// Ruby it `it "returns the value specified by `file` path" do` at line 127.
pub fn ruby_brewfile_spec_l127_d37_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		file: '-'
		dash_writes_to_stdout: true
		env_bundle_file: '/path/to/Brewfile'
	}, '/dev/stdout')
}

// Ruby let `let(:env_bundle_file_value) { "" }` at line 133.
pub fn ruby_brewfile_spec_l133_d38_env_bundle_file_value() string {
	return ''
}

// Ruby it `it "returns the value specified by `file` path" do` at line 135.
pub fn ruby_brewfile_spec_l135_d39_returns() bool {
	return ruby_brewfile_spec_l120_d35_returns()
}

// Ruby let `let(:has_global) { true }` at line 143.
pub fn ruby_brewfile_spec_l143_d40_has_global() bool {
	return true
}

// Ruby let `let(:expected_pathname) { Pathname.new("#{Dir.home}/.Brewfile") }` at line 144.
pub fn ruby_brewfile_spec_l144_d41_expected_pathname() string {
	return '${brewfile_spec_home}/.Brewfile'
}

// Ruby it `it "returns the expected path" do` at line 146.
pub fn ruby_brewfile_spec_l146_d42_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{ global: true }, ruby_brewfile_spec_l144_d41_expected_pathname())
}

// Ruby let `let(:env_bundle_file_global_value) { "/path/to/Brewfile" }` at line 151.
pub fn ruby_brewfile_spec_l151_d43_env_bundle_file_global_value() string {
	return '/path/to/Brewfile'
}

// Ruby let `let(:expected_pathname) { Pathname.new(env_bundle_file_global_value) }` at line 152.
pub fn ruby_brewfile_spec_l152_d44_expected_pathname() string {
	return '/path/to/Brewfile'
}

// Ruby it `it "returns the value specified by the environment variable" do` at line 154.
pub fn ruby_brewfile_spec_l154_d45_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		global: true
		env_bundle_file_global: '/path/to/Brewfile'
	}, '/path/to/Brewfile')
}

// Ruby let `let(:env_bundle_file_value) { "/path/to/Brewfile" }` at line 160.
pub fn ruby_brewfile_spec_l160_d46_env_bundle_file_value() string {
	return '/path/to/Brewfile'
}

// Ruby it `it "returns the value specified by the variable" do` at line 162.
pub fn ruby_brewfile_spec_l162_d47_returns() bool {
	brewfile_spec_path(BrewfileSpecContext{
		global: true
		env_bundle_file: '/path/to/Brewfile'
	}) or {
		return err.msg() == "'HOMEBREW_BUNDLE_FILE' cannot be specified with '--global'"
	}
	return false
}

// Ruby let `let(:env_bundle_file_value) { "" }` at line 168.
pub fn ruby_brewfile_spec_l168_d48_env_bundle_file_value() string {
	return ''
}

// Ruby it `it "returns the value specified by `file` path" do` at line 170.
pub fn ruby_brewfile_spec_l170_d49_returns() bool {
	return ruby_brewfile_spec_l146_d42_returns()
}

// Ruby let `let(:config_dir_brewfile_exist) { true }` at line 176.
pub fn ruby_brewfile_spec_l176_d50_config_dir_brewfile_exist() bool {
	return true
}

// Ruby let `let(:config_dir_exist) { true }` at line 177.
pub fn ruby_brewfile_spec_l177_d51_config_dir_exist() bool {
	return true
}

// Ruby let `let(:home_dir_brewfile_exist) { true }` at line 178.
pub fn ruby_brewfile_spec_l178_d52_home_dir_brewfile_exist() bool {
	return true
}

// Ruby let `let(:expected_pathname) { Pathname.new("#{env_user_config_home_value}/Brewfile") }` at line 179.
pub fn ruby_brewfile_spec_l179_d53_expected_pathname() string {
	return '${brewfile_spec_user_config_home}/Brewfile'
}

// Ruby it `it "returns the expected path" do` at line 181.
pub fn ruby_brewfile_spec_l181_d54_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		global: true
		config_dir_exists: true
		config_brewfile_exists: true
		home_brewfile_exists: true
	}, ruby_brewfile_spec_l179_d53_expected_pathname())
}

// Ruby let `let(:config_dir_exist) { true }` at line 187.
pub fn ruby_brewfile_spec_l187_d55_config_dir_exist() bool {
	return true
}

// Ruby let `let(:expected_pathname) { Pathname.new("#{env_user_config_home_value}/Brewfile") }` at line 188.
pub fn ruby_brewfile_spec_l188_d56_expected_pathname() string {
	return '${brewfile_spec_user_config_home}/Brewfile'
}

// Ruby it `it "returns the expected path" do` at line 190.
pub fn ruby_brewfile_spec_l190_d57_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		global: true
		config_dir_exists: true
	}, ruby_brewfile_spec_l188_d56_expected_pathname())
}

// Ruby let `let(:config_dir_exist) { true }` at line 196.
pub fn ruby_brewfile_spec_l196_d58_config_dir_exist() bool {
	return true
}

// Ruby let `let(:home_dir_brewfile_exist) { true }` at line 197.
pub fn ruby_brewfile_spec_l197_d59_home_dir_brewfile_exist() bool {
	return true
}

// Ruby let `let(:expected_pathname) { Pathname.new("#{env_home_value}/.Brewfile") }` at line 198.
pub fn ruby_brewfile_spec_l198_d60_expected_pathname() string {
	return '${brewfile_spec_home}/.Brewfile'
}

// Ruby it `it "returns the expected path" do` at line 200.
pub fn ruby_brewfile_spec_l200_d61_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		global: true
		config_dir_exists: true
		home_brewfile_exists: true
	}, ruby_brewfile_spec_l198_d60_expected_pathname())
}

// Ruby let `let(:env_bundle_file_value) { "/path/to/Brewfile" }` at line 207.
pub fn ruby_brewfile_spec_l207_d62_env_bundle_file_value() string {
	return '/path/to/Brewfile'
}

// Ruby it `it "returns the expected path" do` at line 209.
pub fn ruby_brewfile_spec_l209_d63_returns() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{
		env_bundle_file: '/path/to/Brewfile'
	}, '/path/to/Brewfile')
}

// Ruby let `let(:env_bundle_file_value) { "" }` at line 214.
pub fn ruby_brewfile_spec_l214_d64_env_bundle_file_value() string {
	return ''
}

// Ruby it `it "defaults to `${PWD}/Brewfile`" do` at line 216.
pub fn ruby_brewfile_spec_l216_d65_defaults() bool {
	return brewfile_spec_path_matches(BrewfileSpecContext{}, '${brewfile_spec_working_directory}/Brewfile')
}

// Ruby let `let(:env_bundle_file_value) { nil }` at line 222.
pub fn ruby_brewfile_spec_l222_d66_env_bundle_file_value() ?string {
	return none
}

// Ruby it `it "defaults to `${PWD}/Brewfile`" do` at line 224.
pub fn ruby_brewfile_spec_l224_d67_defaults() bool {
	return ruby_brewfile_spec_l216_d65_defaults()
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/brewfile"
// 6:
// 7: RSpec.describe Homebrew::Bundle::Brewfile do
// 8:   describe "path" do
// 9:     subject(:path) do
// 10:       described_class.path(dash_writes_to_stdout:, global: has_global, file: file_value)
// 11:     end
// 12:
// 13:     let(:dash_writes_to_stdout) { false }
// 14:     let(:env_bundle_file_global_value) { nil }
// 15:     let(:env_bundle_file_value) { nil }
// 16:     let(:env_user_config_home_value) { "/Users/username/.homebrew" }
// 17:     let(:env_home_value) { "/Users/username" }
// 18:     let(:file_value) { nil }
// 19:     let(:has_global) { false }
// 20:     let(:config_dir_exist) { false }
// 21:     let(:config_dir_brewfile_exist) { false }
// 22:     let(:home_dir_brewfile_exist) { false }
// 23:
// 24:     before do
// 25:       allow(ENV).to receive(:fetch).and_return(nil)
// 26:       allow(ENV).to receive(:fetch).with("HOMEBREW_BUNDLE_FILE_GLOBAL", any_args)
// 27:                                    .and_return(env_bundle_file_global_value)
// 28:       allow(ENV).to receive(:fetch).with("HOMEBREW_BUNDLE_FILE", any_args)
// 29:                                    .and_return(env_bundle_file_value)
// 30:
// 31:       allow(ENV).to receive(:fetch).with("HOMEBREW_USER_CONFIG_HOME", any_args)
// 32:                                    .and_return(env_user_config_home_value)
// 33:       allow(File).to receive(:exist?).with("/Users/username/.homebrew/Brewfile")
// 34:                                      .and_return(config_dir_brewfile_exist)
// 35:       allow(File).to receive(:exist?).with("/Users/username/.Brewfile")
// 36:                                      .and_return(home_dir_brewfile_exist)
// 37:       allow(Dir).to receive(:home).and_return(env_home_value)
// 38:       allow(Dir).to receive(:exist?).with("/Users/username/.homebrew")
// 39:                                     .and_return(config_dir_exist)
// 40:     end
// 41:
// 42:     context "when `file` is specified with a relative path" do
// 43:       let(:file_value) { "path/to/Brewfile" }
// 44:       let(:expected_pathname) { Pathname.new(file_value).expand_path(Dir.pwd) }
// 45:
// 46:       it "returns the expected path" do
// 47:         expect(path).to eq(expected_pathname)
// 48:       end
// 49:
// 50:       context "with a configured HOMEBREW_BUNDLE_FILE" do
// 51:         let(:env_bundle_file_value) { "/path/to/Brewfile" }
// 52:
// 53:         it "returns the value specified by `file` path" do
// 54:           expect(path).to eq(expected_pathname)
// 55:         end
// 56:       end
// 57:
// 58:       context "with an empty HOMEBREW_BUNDLE_FILE" do
// 59:         let(:env_bundle_file_value) { "" }
// 60:
// 61:         it "returns the value specified by `file` path" do
// 62:           expect(path).to eq(expected_pathname)
// 63:         end
// 64:       end
// 65:     end
// 66:
// 67:     context "when `file` is specified with an absolute path" do
// 68:       let(:file_value) { "/tmp/random_file" }
// 69:       let(:expected_pathname) { Pathname.new(file_value) }
// 70:
// 71:       it "returns the expected path" do
// 72:         expect(path).to eq(expected_pathname)
// 73:       end
// 74:
// 75:       context "with a configured HOMEBREW_BUNDLE_FILE" do
// 76:         let(:env_bundle_file_value) { "/path/to/Brewfile" }
// 77:
// 78:         it "returns the value specified by `file` path" do
// 79:           expect(path).to eq(expected_pathname)
// 80:         end
// 81:       end
// 82:
// 83:       context "with an empty HOMEBREW_BUNDLE_FILE" do
// 84:         let(:env_bundle_file_value) { "" }
// 85:
// 86:         it "returns the value specified by `file` path" do
// 87:           expect(path).to eq(expected_pathname)
// 88:         end
// 89:       end
// 90:     end
// 91:
// 92:     context "when `file` is specified with `-`" do
// 93:       let(:file_value) { "-" }
// 94:       let(:expected_pathname) { Pathname.new("/dev/stdin") }
// 95:
// 96:       it "returns stdin by default" do
// 97:         expect(path).to eq(expected_pathname)
// 98:       end
// 99:
// 100:       context "with a configured HOMEBREW_BUNDLE_FILE" do
// 101:         let(:env_bundle_file_value) { "/path/to/Brewfile" }
// 102:
// 103:         it "returns the value specified by `file` path" do
// 104:           expect(path).to eq(expected_pathname)
// 105:         end
// 106:       end
// 107:
// 108:       context "with an empty HOMEBREW_BUNDLE_FILE" do
// 109:         let(:env_bundle_file_value) { "" }
// 110:
// 111:         it "returns the value specified by `file` path" do
// 112:           expect(path).to eq(expected_pathname)
// 113:         end
// 114:       end
// 115:
// 116:       context "when `dash_writes_to_stdout` is true" do
// 117:         let(:expected_pathname) { Pathname.new("/dev/stdout") }
// 118:         let(:dash_writes_to_stdout) { true }
// 119:
// 120:         it "returns stdout" do
// 121:           expect(path).to eq(expected_pathname)
// 122:         end
// 123:
// 124:         context "with a configured HOMEBREW_BUNDLE_FILE" do
// 125:           let(:env_bundle_file_value) { "/path/to/Brewfile" }
// 126:
// 127:           it "returns the value specified by `file` path" do
// 128:             expect(path).to eq(expected_pathname)
// 129:           end
// 130:         end
// 131:
// 132:         context "with an empty HOMEBREW_BUNDLE_FILE" do
// 133:           let(:env_bundle_file_value) { "" }
// 134:
// 135:           it "returns the value specified by `file` path" do
// 136:             expect(path).to eq(expected_pathname)
// 137:           end
// 138:         end
// 139:       end
// 140:     end
// 141:
// 142:     context "when `global` is true" do
// 143:       let(:has_global) { true }
// 144:       let(:expected_pathname) { Pathname.new("#{Dir.home}/.Brewfile") }
// 145:
// 146:       it "returns the expected path" do
// 147:         expect(path).to eq(expected_pathname)
// 148:       end
// 149:
// 150:       context "when HOMEBREW_BUNDLE_FILE_GLOBAL is set" do
// 151:         let(:env_bundle_file_global_value) { "/path/to/Brewfile" }
// 152:         let(:expected_pathname) { Pathname.new(env_bundle_file_global_value) }
// 153:
// 154:         it "returns the value specified by the environment variable" do
// 155:           expect(path).to eq(expected_pathname)
// 156:         end
// 157:       end
// 158:
// 159:       context "when HOMEBREW_BUNDLE_FILE is set" do
// 160:         let(:env_bundle_file_value) { "/path/to/Brewfile" }
// 161:
// 162:         it "returns the value specified by the variable" do
// 163:           expect { path }.to raise_error(RuntimeError)
// 164:         end
// 165:       end
// 166:
// 167:       context "when HOMEBREW_BUNDLE_FILE is `` (empty)" do
// 168:         let(:env_bundle_file_value) { "" }
// 169:
// 170:         it "returns the value specified by `file` path" do
// 171:           expect(path).to eq(expected_pathname)
// 172:         end
// 173:       end
// 174:
// 175:       context "when HOMEBREW_USER_CONFIG_HOME/Brewfile exists" do
// 176:         let(:config_dir_brewfile_exist) { true }
// 177:         let(:config_dir_exist) { true }
// 178:         let(:home_dir_brewfile_exist) { true }
// 179:         let(:expected_pathname) { Pathname.new("#{env_user_config_home_value}/Brewfile") }
// 180:
// 181:         it "returns the expected path" do
// 182:           expect(path).to eq(expected_pathname)
// 183:         end
// 184:       end
// 185:
// 186:       context "when empty HOMEBREW_USER_CONFIG_HOME exists, and .Brewfile does not" do
// 187:         let(:config_dir_exist) { true }
// 188:         let(:expected_pathname) { Pathname.new("#{env_user_config_home_value}/Brewfile") }
// 189:
// 190:         it "returns the expected path" do
// 191:           expect(path).to eq(expected_pathname)
// 192:         end
// 193:       end
// 194:
// 195:       context "when empty HOMEBREW_USER_CONFIG_HOME and .Brewfile exist" do
// 196:         let(:config_dir_exist) { true }
// 197:         let(:home_dir_brewfile_exist) { true }
// 198:         let(:expected_pathname) { Pathname.new("#{env_home_value}/.Brewfile") }
// 199:
// 200:         it "returns the expected path" do
// 201:           expect(path).to eq(expected_pathname)
// 202:         end
// 203:       end
// 204:     end
// 205:
// 206:     context "when HOMEBREW_BUNDLE_FILE has a value" do
// 207:       let(:env_bundle_file_value) { "/path/to/Brewfile" }
// 208:
// 209:       it "returns the expected path" do
// 210:         expect(path).to eq(Pathname.new(env_bundle_file_value))
// 211:       end
// 212:
// 213:       describe "that is `` (empty)" do
// 214:         let(:env_bundle_file_value) { "" }
// 215:
// 216:         it "defaults to `${PWD}/Brewfile`" do
// 217:           expect(path).to eq(Pathname.new("Brewfile").expand_path(Dir.pwd))
// 218:         end
// 219:       end
// 220:
// 221:       describe "that is `nil`" do
// 222:         let(:env_bundle_file_value) { nil }
// 223:
// 224:         it "defaults to `${PWD}/Brewfile`" do
// 225:           expect(path).to eq(Pathname.new("Brewfile").expand_path(Dir.pwd))
// 226:         end
// 227:       end
// 228:     end
// 229:   end
// 230: end
