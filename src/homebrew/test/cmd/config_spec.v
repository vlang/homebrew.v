module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/config_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:windows_cmd) do` at line 8.
pub fn ruby_config_spec_l8_d1_windows_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('windows_cmd', ...args)
}

// Ruby it `it "prints information about the current Homebrew configuration", :integration_test do` at line 17.
pub fn ruby_config_spec_l17_d2_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "prints HOMEBREW_CASK_OPTS_REQUIRE_SHA in env config output when set" do` at line 24.
pub fn ruby_config_spec_l24_d3_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "prints only environment variables with non-default values" do` at line 37.
pub fn ruby_config_spec_l37_d4_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "reads the Windows version on WSL", :needs_linux do` at line 59.
pub fn ruby_config_spec_l59_d5_reads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reads', ...args)
}

// Ruby it `it "prints the Windows version in config output on WSL", :needs_linux do` at line 76.
pub fn ruby_config_spec_l76_d6_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "prints the Landlock ABI in config output", :needs_linux do` at line 95.
pub fn ruby_config_spec_l95_d7_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "prints config sections in order" do` at line 112.
pub fn ruby_config_spec_l112_d8_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "does not print HOMEBREW_EVAL_ALL unless it is directly set" do` at line 127.
pub fn ruby_config_spec_l127_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/config"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Config do
// 8:   let(:windows_cmd) do
// 9:     cmd = mktmpdir/"cmd.exe"
// 10:     cmd.write("")
// 11:     cmd.chmod(0755)
// 12:     cmd
// 13:   end
// 14:
// 15:   it_behaves_like "parseable arguments"
// 16:
// 17:   it "prints information about the current Homebrew configuration", :integration_test do
// 18:     expect { brew "config" }
// 19:       .to output(/HOMEBREW_VERSION: #{Regexp.escape HOMEBREW_VERSION}/o).to_stdout
// 20:       .and not_to_output.to_stderr
// 21:       .and be_a_success
// 22:   end
// 23:
// 24:   it "prints HOMEBREW_CASK_OPTS_REQUIRE_SHA in env config output when set" do
// 25:     Homebrew.raise_deprecation_exceptions = false
// 26:     ENV["HOMEBREW_USER_SET_VARS"] = "HOMEBREW_CASK_OPTS_REQUIRE_SHA"
// 27:     ENV["HOMEBREW_CASK_OPTS_REQUIRE_SHA"] = "1"
// 28:     output = StringIO.new
// 29:
// 30:     SystemConfig.homebrew_env_config(output)
// 31:
// 32:     expect(output.string).to include("HOMEBREW_CASK_OPTS_REQUIRE_SHA: 1")
// 33:   ensure
// 34:     Homebrew.raise_deprecation_exceptions = true
// 35:   end
// 36:
// 37:   it "prints only environment variables with non-default values" do
// 38:     Homebrew::EnvConfig::ENVS.each_key { |env| ENV.delete(env.to_s) }
// 39:     ENV["HOMEBREW_USER_SET_VARS"] = "HOMEBREW_API_AUTO_UPDATE_SECS HOMEBREW_BUNDLE_DESCRIBE " \
// 40:                                     "HOMEBREW_CURL_RETRIES HOMEBREW_REQUIRE_TAP_TRUST"
// 41:     ENV["HOMEBREW_API_AUTO_UPDATE_SECS"] = "450"
// 42:     ENV["HOMEBREW_BUNDLE_DESCRIBE"] = "false"
// 43:     ENV["HOMEBREW_CURL_RETRIES"] = "4"
// 44:     ENV["HOMEBREW_REQUIRE_TAP_TRUST"] = "1"
// 45:     ENV["HOMEBREW_EDITOR"] = "vim"
// 46:     output = StringIO.new
// 47:
// 48:     SystemConfig.homebrew_env_config(output)
// 49:
// 50:     env_config = output.string.lines.select do |line|
// 51:       Homebrew::EnvConfig::ENVS.key?(line.partition(":").first.to_sym)
// 52:     end
// 53:     expect(env_config).to eq([
// 54:       "HOMEBREW_BUNDLE_DESCRIBE: false\n",
// 55:       "HOMEBREW_CURL_RETRIES: 4\n",
// 56:     ])
// 57:   end
// 58:
// 59:   it "reads the Windows version on WSL", :needs_linux do
// 60:     allow(OS).to receive(:wsl?).and_return(true)
// 61:     stub_const("ORIGINAL_PATHS", [windows_cmd.dirname])
// 62:     allow(Utils).to receive(:popen_read)
// 63:       .with(windows_cmd, "/d", "/c", "reg", "query", "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
// 64:             err: :close)
// 65:       .and_return(<<~EOS)
// 66:         HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion
// 67:             ProductName    REG_SZ    Windows 10 Pro
// 68:             DisplayVersion    REG_SZ    25H2
// 69:             CurrentBuildNumber    REG_SZ    26200
// 70:             UBR    REG_DWORD    0x2109
// 71:       EOS
// 72:
// 73:     expect(SystemConfig.windows_version).to eq("Windows 11 Pro (25H2) [26200.8457]")
// 74:   end
// 75:
// 76:   it "prints the Windows version in config output on WSL", :needs_linux do
// 77:     output = StringIO.new
// 78:
// 79:     allow(OS).to receive(:wsl?).and_return(true)
// 80:     allow(OS::Linux).to receive_messages(os_version: "Ubuntu 24.04.3 LTS", wsl_version: Version.new("2"))
// 81:     allow(SystemConfig).to receive_messages(
// 82:       homebrew_config:      nil,
// 83:       core_tap_config:      nil,
// 84:       homebrew_env_config:  nil,
// 85:       hardware:             nil,
// 86:       host_software_config: nil,
// 87:       windows_version:      "Windows 11 Pro (25H2) [26200.8457]",
// 88:     )
// 89:
// 90:     SystemConfig.dump_verbose_config(output)
// 91:
// 92:     expect(output.string).to include("Windows: Windows 11 Pro (25H2) [26200.8457]\n")
// 93:   end
// 94:
// 95:   it "prints the Landlock ABI in config output", :needs_linux do
// 96:     output = StringIO.new
// 97:
// 98:     allow(Sandbox::Landlock).to receive(:kernel_abi_version).and_return(6)
// 99:     allow(SystemConfig).to receive_messages(
// 100:       homebrew_config:      nil,
// 101:       core_tap_config:      nil,
// 102:       homebrew_env_config:  nil,
// 103:       hardware:             nil,
// 104:       host_software_config: nil,
// 105:     )
// 106:
// 107:     SystemConfig.dump_verbose_config(output)
// 108:
// 109:     expect(output.string).to include("Landlock ABI: 6\n")
// 110:   end
// 111:
// 112:   it "prints config sections in order" do
// 113:     output = StringIO.new
// 114:
// 115:     allow(SystemConfig).to receive(:config_sections).and_return([:homebrew_config, :host_software_config])
// 116:     allow(SystemConfig).to receive(:homebrew_config) do |io|
// 117:       sleep(0.01)
// 118:       io.puts "first"
// 119:     end
// 120:     allow(SystemConfig).to receive(:host_software_config) { |io| io.puts "second" }
// 121:
// 122:     SystemConfig.dump_verbose_config(output)
// 123:
// 124:     expect(output.string).to eq("first\nsecond\n")
// 125:   end
// 126:
// 127:   it "does not print HOMEBREW_EVAL_ALL unless it is directly set" do
// 128:     output = StringIO.new
// 129:
// 130:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1", HOMEBREW_EVAL_ALL: nil) do
// 131:       SystemConfig.homebrew_env_config(output)
// 132:     end
// 133:
// 134:     expect(output.string).not_to include("HOMEBREW_EVAL_ALL")
// 135:   end
// 136: end
