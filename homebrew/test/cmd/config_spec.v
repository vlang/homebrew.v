module cmd

import homebrew
import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/config_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn config_spec_command_probe(command homebrew.SystemConfigCommand) !homebrew.SystemConfigCommandResult {
	if command.executable == 'curl' {
		return homebrew.SystemConfigCommandResult{
			stdout: 'curl 8.14.1 (test)\n'
		}
	}
	if command.executable == 'uname' {
		return homebrew.SystemConfigCommandResult{
			stdout: if command.arguments == ['-m'] {
				'x86_64\n'} else {
				'Linux test 6.16 x86_64\n'}
		}
	}
	if command.arguments.contains('reg') {
		return homebrew.SystemConfigCommandResult{
			stdout: 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\n    ProductName    REG_SZ    Windows 10 Pro\n    DisplayVersion    REG_SZ    25H2\n    CurrentBuildNumber    REG_SZ    26200\n    UBR    REG_DWORD    0x2109\n'
		}
	}
	if command.arguments.contains('ver') {
		return homebrew.SystemConfigCommandResult{
			stdout: '\r\nMicrosoft Windows [Version 10.0.26200.8457]\r\n'
		}
	}
	return error('unexpected command: ${command.executable} ${command.arguments}')
}

fn config_spec_context(environment []homebrew.SystemConfigEnvVariable,
	host homebrew.SystemConfigHost) homebrew.SystemConfigContext {
	return homebrew.SystemConfigContext{
		homebrew_version: '5.0.0-test'
		homebrew_prefix: '/home/linuxbrew/.linuxbrew'
		homebrew_repository: '/home/linuxbrew/.linuxbrew/Homebrew'
		default_repository: '/home/linuxbrew/.linuxbrew/Homebrew'
		homebrew_cellar: '/home/linuxbrew/.linuxbrew/Cellar'
		default_cellar: '/home/linuxbrew/.linuxbrew/Cellar'
		ruby_version: '3.4.5'
		ruby_path: '/home/linuxbrew/.linuxbrew/Library/Homebrew/vendor/portable-ruby/current/bin/ruby'
		development_tools_installed: true
		clang_version: '18.1.8'
		clang_build_version: '1801.8'
		repository: homebrew.SystemConfigRepository{
			path: '/home/linuxbrew/.linuxbrew/Homebrew'
			origin: 'https://github.com/Homebrew/brew'
			head: homebrew.SystemConfigGitHead{
				head: '0123456789abcdef'
				last_commit: '2 hours ago'
				branch: 'main'
			}
		}
		hardware: homebrew.SystemConfigHardware{
			known: true
			cores_as_words: '8'
			bits: 64
			family: 'zen4'
		}
		git: homebrew.SystemConfigTool{
			available: true
			version: '2.51.0'
			path: '/usr/bin/git'
		}
		curl: homebrew.SystemConfigTool{
			available: true
			version: '8.14.1'
			path: '/usr/bin/curl'
			executable: 'curl'
		}
		core_tap: homebrew.SystemConfigTap{
			kind: .core
			installed: false
			json_modified_utc: '29 Aug 12:00 UTC'
		}
		core_cask_tap: homebrew.SystemConfigTap{
			kind: .core_cask
			installed: false
		}
		environment: environment
		host: host
	}
}

fn config_spec_linux_host(wsl bool, landlock ?int) homebrew.SystemConfigHost {
	return homebrew.SystemConfigHost{
		platform: .linux
		os_version: 'Ubuntu 24.04.3 LTS'
		wsl: wsl
		wsl_version: if wsl { '2' } else { '' }
		windows_cmd: '/tmp/cmd.exe'
		windows_cmd_executable: wsl
		landlock_abi: landlock
		host_glibc: '2.39'
		host_libstdcxx: '14.2.0'
		host_gcc_path: '/usr/bin/gcc'
		host_gcc_version: '13.3.0'
		host_ruby_version: '3.2.3'
		linked_formulae: [
			homebrew.SystemConfigLinkedFormula{ name: 'glibc', version: '2.39' },
			homebrew.SystemConfigLinkedFormula{ name: 'gcc', version: '14.2.0' },
		]
	}
}

fn render_delayed_config_section(section homebrew.SystemConfigSection) !string {
	return match section {
		.homebrew_config { 'first\n' }
		.host_software_config { 'second\n' }
		else { '' }
	}
}

fn config_spec_command_output() !string {
	state := homebrew.new_system_config(config_spec_context([], config_spec_linux_host(false, 6)))
	return homebrew.system_config_dump_verbose(state, config_spec_command_probe)
}

// Ruby let `let(:windows_cmd) do` at line 8.
pub fn ruby_config_spec_l8_d1_windows_cmd() string {
	return '/tmp/cmd.exe'
}

// Ruby it `it "prints information about the current Homebrew configuration", :integration_test do` at line 17.
pub fn ruby_config_spec_l17_d2_prints() bool {
	output := brew_cmd.config_command_output(config_spec_command_output) or { return false }
	return output.contains('HOMEBREW_VERSION: 5.0.0-test')
}

// Ruby it `it "prints HOMEBREW_CASK_OPTS_REQUIRE_SHA in env config output when set" do` at line 24.
pub fn ruby_config_spec_l24_d3_prints() bool {
	state := homebrew.new_system_config(config_spec_context([
		homebrew.SystemConfigEnvVariable{
			name: 'HOMEBREW_CASK_OPTS_REQUIRE_SHA'
			value: '1'
			directly_set: true
		},
	], homebrew.SystemConfigHost{}))
	return homebrew.system_config_homebrew_environment(state).contains('HOMEBREW_CASK_OPTS_REQUIRE_SHA: 1')
}

// Ruby it `it "prints only environment variables with non-default values" do` at line 37.
pub fn ruby_config_spec_l37_d4_prints() bool {
	state := homebrew.new_system_config(config_spec_context([
		homebrew.SystemConfigEnvVariable{
			name: 'HOMEBREW_API_AUTO_UPDATE_SECS'
			value: '450'
			default_value: '450'
			directly_set: true
		},
		homebrew.SystemConfigEnvVariable{
			name: 'HOMEBREW_BUNDLE_DESCRIBE'
			value: 'false'
			boolean_mode: .falsy_values
			default_bool: true
			directly_set: true
		},
		homebrew.SystemConfigEnvVariable{
			name: 'HOMEBREW_CURL_RETRIES'
			value: '4'
			default_value: '3'
			directly_set: true
		},
		homebrew.SystemConfigEnvVariable{
			name: 'HOMEBREW_REQUIRE_TAP_TRUST'
			value: '1'
			boolean_mode: .set
			default_bool: true
			directly_set: true
		},
		homebrew.SystemConfigEnvVariable{
			name: 'HOMEBREW_EDITOR'
			value: 'vim'
			directly_set: false
		},
	], homebrew.SystemConfigHost{}))
	output := homebrew.system_config_homebrew_environment(state)
	return output.contains('HOMEBREW_BUNDLE_DESCRIBE: false\n') && output.contains('HOMEBREW_CURL_RETRIES: 4\n') && !output.contains('HOMEBREW_API_AUTO_UPDATE_SECS') && !output.contains('HOMEBREW_REQUIRE_TAP_TRUST') && !output.contains('HOMEBREW_EDITOR')
}

// Ruby it `it "reads the Windows version on WSL", :needs_linux do` at line 59.
pub fn ruby_config_spec_l59_d5_reads() bool {
	state := homebrew.new_system_config(config_spec_context([], config_spec_linux_host(true, 6)))
	return homebrew.system_config_windows_version(state, config_spec_command_probe) or { return false } == 'Windows 11 Pro (25H2) [26200.8457]'
}

// Ruby it `it "prints the Windows version in config output on WSL", :needs_linux do` at line 76.
pub fn ruby_config_spec_l76_d6_prints() bool {
	state := homebrew.new_system_config(config_spec_context([], config_spec_linux_host(true, 6)))
	output := homebrew.system_config_dump_verbose(state, config_spec_command_probe) or { return false }
	return output.contains('Windows: Windows 11 Pro (25H2) [26200.8457]\n')
}

// Ruby it `it "prints the Landlock ABI in config output", :needs_linux do` at line 95.
pub fn ruby_config_spec_l95_d7_prints() bool {
	state := homebrew.new_system_config(config_spec_context([], config_spec_linux_host(false, 6)))
	output := homebrew.system_config_dump_verbose(state, config_spec_command_probe) or { return false }
	return output.contains('Landlock ABI: 6\n')
}

// Ruby it `it "prints config sections in order" do` at line 112.
pub fn ruby_config_spec_l112_d8_prints() bool {
	output := homebrew.render_system_config_sections_ordered([
		.homebrew_config,
		.host_software_config,
	], render_delayed_config_section) or { return false }
	return output == 'first\nsecond\n'
}

// Ruby it `it "does not print HOMEBREW_EVAL_ALL unless it is directly set" do` at line 127.
pub fn ruby_config_spec_l127_d9_does() bool {
	state := homebrew.new_system_config(config_spec_context([
		homebrew.SystemConfigEnvVariable{
			name: 'HOMEBREW_REQUIRE_TAP_TRUST'
			value: '1'
			boolean_mode: .set
			default_bool: true
			directly_set: true
		},
		homebrew.SystemConfigEnvVariable{
			name: 'HOMEBREW_EVAL_ALL'
			value: '1'
			boolean_mode: .falsy_values
			directly_set: false
		},
	], homebrew.SystemConfigHost{}))
	return !homebrew.system_config_homebrew_environment(state).contains('HOMEBREW_EVAL_ALL')
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
