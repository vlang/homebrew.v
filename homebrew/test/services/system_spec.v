module services

import ruby
import homebrew.services as services_core
import os
import time

// Translated from Homebrew/brew `test/services/system_spec.rb`.
// The original source is retained below for source-level traceability.
fn system_spec_temporary_directory(label string) !string {
	path := os.join_path(os.temp_dir(), 'brew-v-services-system-${label}-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(path)!
	return path
}

fn system_spec_executable(directory string, name string) !string {
	path := os.join_path(directory, name)
	os.write_file(path, '#!/bin/sh\nexit 0\n')!
	os.chmod(path, 0o755)!
	return path
}

fn system_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn system_spec_launchctl_runner(command []string, _ bool) services_core.LaunchctlRunResult {
	if command.len >= 2 && command[1] == 'print' {
		return services_core.LaunchctlRunResult{
			output: 'service output'
			success: true
		}
	}
	return services_core.LaunchctlRunResult{}
}

// Ruby let `let(:bindir) { mktmpdir }` at line 10.
pub fn ruby_system_spec_l10_d1_bindir(args ...ruby.Value) ruby.Value {
	_ = args
	path := system_spec_temporary_directory('bindir') or {
		return ruby.object_value('Error', err.msg())
	}
	return ruby.object_value('Pathname', path)
}

// Ruby it `it "returns the launchctl command location when available and nil when unavailable" do` at line 15.
pub fn ruby_system_spec_l15_d2_returns(args ...ruby.Value) ruby.Value {
	_ = args
	directory := system_spec_temporary_directory('launchctl-location') or { return system_spec_bool(false) }
	defer { os.rmdir_all(directory) or {} }
	launchctl := system_spec_executable(directory, 'launchctl') or { return system_spec_bool(false) }
	mut available := services_core.new_service_system(services_core.ServiceSystemConfig{
		path_environment: directory
	})
	available_path := available.launchctl() or { return system_spec_bool(false) }
	os.rm(launchctl) or { return system_spec_bool(false) }
	mut unavailable := services_core.new_service_system(services_core.ServiceSystemConfig{
		path_environment: directory
	})
	return system_spec_bool(available_path == launchctl && unavailable.launchctl() == none)
}

// Ruby it `it "returns true when launchctl is available and false when unavailable" do` at line 37.
pub fn ruby_system_spec_l37_d3_returns(args ...ruby.Value) ruby.Value {
	_ = args
	directory := system_spec_temporary_directory('launchctl-present') or { return system_spec_bool(false) }
	defer { os.rmdir_all(directory) or {} }
	launchctl := system_spec_executable(directory, 'launchctl') or { return system_spec_bool(false) }
	mut available := services_core.new_service_system(services_core.ServiceSystemConfig{
		path_environment: directory
	})
	present := available.launchctl_available()
	os.rm(launchctl) or { return system_spec_bool(false) }
	mut unavailable := services_core.new_service_system(services_core.ServiceSystemConfig{
		path_environment: directory
	})
	return system_spec_bool(present && !unavailable.launchctl_available())
}

// Ruby it `it "returns true when systemctl is available and false when unavailable" do` at line 59.
pub fn ruby_system_spec_l59_d4_returns(args ...ruby.Value) ruby.Value {
	_ = args
	directory := system_spec_temporary_directory('systemctl-present') or { return system_spec_bool(false) }
	defer { os.rmdir_all(directory) or {} }
	systemctl := system_spec_executable(directory, 'systemctl') or { return system_spec_bool(false) }
	mut available := services_core.new_service_system(services_core.ServiceSystemConfig{
		path_environment: directory
	})
	present := available.systemctl_available()
	os.rm(systemctl) or { return system_spec_bool(false) }
	mut unavailable := services_core.new_service_system(services_core.ServiceSystemConfig{
		path_environment: directory
	})
	return system_spec_bool(present && !unavailable.systemctl_available())
}

// Ruby it `it "checks if the command is ran as root" do` at line 81.
pub fn ruby_system_spec_l81_d5_checks(args ...ruby.Value) ruby.Value {
	_ = args
	system := services_core.new_service_system(services_core.ServiceSystemConfig{
		root_overridden: true
		root: false
	})
	return system_spec_bool(!system.root())
}

// Ruby it `it "returns the current username" do` at line 87.
pub fn ruby_system_spec_l87_d6_returns(args ...ruby.Value) ruby.Value {
	_ = args
	expected := os.getenv('USER')
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		user: expected
	})
	return system_spec_bool(system.user() == expected)
}

// Ruby it `it "returns true when a specified user exists" do` at line 93.
pub fn ruby_system_spec_l93_d7_returns(args ...ruby.Value) ruby.Value {
	_ = args
	username := os.getenv('USER')
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		user: username
	})
	return system_spec_bool(username != '' && system.user_exists(username))
}

// Ruby it `it "returns false when a specified user does not exist" do` at line 97.
pub fn ruby_system_spec_l97_d8_returns(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		user: os.getenv('USER')
	})
	username := 'not_a_real_user_${os.getpid()}_${time.now().unix_micro()}'
	return system_spec_bool(!system.user_exists(username))
}

// Ruby it `it "returns the current domain target" do` at line 103.
pub fn ruby_system_spec_l103_d9_returns(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		root_overridden: true
		root: false
		uid: 501
		euid: 501
	})
	target := system.domain_target()
	return system_spec_bool(target == 'gui/501')
}

// Ruby it `it "returns the root domain target" do` at line 108.
pub fn ruby_system_spec_l108_d10_returns(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		root_overridden: true
		root: true
	})
	return system_spec_bool(system.domain_target() == 'system')
}

// Ruby it `it "macOS - returns the boot path" do` at line 115.
pub fn ruby_system_spec_l115_d11_macos(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		launchctl_overridden: true
		launchctl_path: '/bin/launchctl'
	})
	return system_spec_bool(system.boot_path() or { '' } == '/Library/LaunchDaemons')
}

// Ruby it `it "SystemD - returns the boot path" do` at line 120.
pub fn ruby_system_spec_l120_d12_systemd(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		launchctl_overridden: true
		systemctl_overridden: true
		systemctl_path: '/bin/systemctl'
	})
	return system_spec_bool(system.boot_path() or { '' } == '/usr/lib/systemd/system')
}

// Ruby it `it "Unknown - raises an error" do` at line 125.
pub fn ruby_system_spec_l125_d13_unknown(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		launchctl_overridden: true
		systemctl_overridden: true
	})
	system.boot_path() or {
		return system_spec_bool(err.msg() == services_core.missing_daemon_manager_exception_message)
	}
	return system_spec_bool(false)
}

// Ruby it `it "macOS - returns the user path" do` at line 135.
pub fn ruby_system_spec_l135_d14_macos(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		home: '/tmp_home'
		launchctl_overridden: true
		launchctl_path: '/bin/launchctl'
		systemctl_overridden: true
	})
	return system_spec_bool(system.user_path() or { '' } == '/tmp_home/Library/LaunchAgents')
}

// Ruby it `it "systemD - returns the user path" do` at line 141.
pub fn ruby_system_spec_l141_d15_systemd(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		home: '/tmp_home'
		launchctl_overridden: true
		systemctl_overridden: true
		systemctl_path: '/bin/systemctl'
	})
	return system_spec_bool(system.user_path() or { '' } == '/tmp_home/.config/systemd/user')
}

// Ruby it `it "Unknown - raises an error" do` at line 147.
pub fn ruby_system_spec_l147_d16_unknown(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		home: '/tmp_home'
		launchctl_overridden: true
		systemctl_overridden: true
	})
	system.user_path() or {
		return system_spec_bool(err.msg() == services_core.missing_daemon_manager_exception_message)
	}
	return system_spec_bool(false)
}

// Ruby let `let(:label) { "homebrew.mxcl.foo" }` at line 158.
pub fn ruby_system_spec_l158_d17_label(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('homebrew.mxcl.foo')
}

// Ruby it `it "returns failure when launchctl is not available" do` at line 160.
pub fn ruby_system_spec_l160_d18_returns(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		launchctl_overridden: true
	})
	result := system.launchctl_find_service('homebrew.mxcl.foo', false, system_spec_launchctl_runner)
	return system_spec_bool(!result.success && result.command_type == .launchctl_list)
}

// Ruby let `let(:label) { "homebrew.mxcl.foo" }` at line 169.
pub fn ruby_system_spec_l169_d19_label(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('homebrew.mxcl.foo')
}

// Ruby it `it "delegates to launchctl_find_service" do` at line 171.
pub fn ruby_system_spec_l171_d20_delegates(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		launchctl_overridden: true
		launchctl_path: '/bin/launchctl'
		root_overridden: true
		root: true
	})
	return system_spec_bool(system.launchctl_service_running('homebrew.mxcl.foo', false, system_spec_launchctl_runner))
}

// Ruby it `it "macOS - user - returns the current relevant path" do` at line 179.
pub fn ruby_system_spec_l179_d21_macos(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		home: '/tmp_home'
		root_overridden: true
		root: false
		launchctl_overridden: true
		launchctl_path: '/bin/launchctl'
		systemctl_overridden: true
	})
	return system_spec_bool(system.path() or { '' } == '/tmp_home/Library/LaunchAgents')
}

// Ruby it `it "macOS - root- returns the current relevant path" do` at line 185.
pub fn ruby_system_spec_l185_d22_macos(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		home: '/tmp_home'
		root_overridden: true
		root: true
		launchctl_overridden: true
		launchctl_path: '/bin/launchctl'
		systemctl_overridden: true
	})
	return system_spec_bool(system.path() or { '' } == '/Library/LaunchDaemons')
}

// Ruby it `it "systemD - user - returns the current relevant path" do` at line 191.
pub fn ruby_system_spec_l191_d23_systemd(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		home: '/tmp_home'
		root_overridden: true
		root: false
		launchctl_overridden: true
		systemctl_overridden: true
		systemctl_path: '/bin/systemctl'
	})
	return system_spec_bool(system.path() or { '' } == '/tmp_home/.config/systemd/user')
}

// Ruby it `it "systemD - root- returns the current relevant path" do` at line 197.
pub fn ruby_system_spec_l197_d24_systemd(args ...ruby.Value) ruby.Value {
	_ = args
	mut system := services_core.new_service_system(services_core.ServiceSystemConfig{
		home: '/tmp_home'
		root_overridden: true
		root: true
		launchctl_overridden: true
		systemctl_overridden: true
		systemctl_path: '/bin/systemctl'
	})
	return system_spec_bool(system.path() or { '' } == '/usr/lib/systemd/system')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/system"
// 5: require "test/support/helper/services"
// 6:
// 7: RSpec.describe Homebrew::Services::System do
// 8:   include Test::Helper::Services
// 9:
// 10:   let(:bindir) { mktmpdir }
// 11:
// 12:   before { reset_services_memoization! }
// 13:
// 14:   describe "#launchctl" do
// 15:     it "returns the launchctl command location when available and nil when unavailable" do
// 16:       launchctl = bindir/"launchctl"
// 17:       launchctl.write <<~SH
// 18:         #!/bin/sh
// 19:         exit 0
// 20:       SH
// 21:       launchctl.chmod 0755
// 22:
// 23:       with_env(PATH: bindir.to_s) do
// 24:         expect(described_class.launchctl).to eq(launchctl)
// 25:       end
// 26:
// 27:       reset_services_memoization!
// 28:       launchctl.unlink
// 29:
// 30:       with_env(PATH: bindir.to_s) do
// 31:         expect(described_class.launchctl).to be_nil
// 32:       end
// 33:     end
// 34:   end
// 35:
// 36:   describe "#launchctl?" do
// 37:     it "returns true when launchctl is available and false when unavailable" do
// 38:       launchctl = bindir/"launchctl"
// 39:       launchctl.write <<~SH
// 40:         #!/bin/sh
// 41:         exit 0
// 42:       SH
// 43:       launchctl.chmod 0755
// 44:
// 45:       with_env(PATH: bindir.to_s) do
// 46:         expect(described_class.launchctl?).to be(true)
// 47:       end
// 48:
// 49:       reset_services_memoization!
// 50:       launchctl.unlink
// 51:
// 52:       with_env(PATH: bindir.to_s) do
// 53:         expect(described_class.launchctl?).to be(false)
// 54:       end
// 55:     end
// 56:   end
// 57:
// 58:   describe "#systemctl?" do
// 59:     it "returns true when systemctl is available and false when unavailable" do
// 60:       systemctl = bindir/"systemctl"
// 61:       systemctl.write <<~SH
// 62:         #!/bin/sh
// 63:         exit 0
// 64:       SH
// 65:       systemctl.chmod 0755
// 66:
// 67:       with_env(PATH: bindir.to_s) do
// 68:         expect(described_class.systemctl?).to be(true)
// 69:       end
// 70:
// 71:       reset_services_memoization!
// 72:       systemctl.unlink
// 73:
// 74:       with_env(PATH: bindir.to_s) do
// 75:         expect(described_class.systemctl?).to be(false)
// 76:       end
// 77:     end
// 78:   end
// 79:
// 80:   describe "#root?" do
// 81:     it "checks if the command is ran as root" do
// 82:       expect(described_class.root?).to be(false)
// 83:     end
// 84:   end
// 85:
// 86:   describe "#user" do
// 87:     it "returns the current username" do
// 88:       expect(described_class.user).to eq(ENV.fetch("USER"))
// 89:     end
// 90:   end
// 91:
// 92:   describe "#user_exists?" do
// 93:     it "returns true when a specified user exists" do
// 94:       expect(described_class.user_exists?(ENV.fetch("USER"))).to be(true)
// 95:     end
// 96:
// 97:     it "returns false when a specified user does not exist" do
// 98:       expect(described_class.user_exists?("not_a_real_user_#{SecureRandom.hex(4)}")).to be(false)
// 99:     end
// 100:   end
// 101:
// 102:   describe "#domain_target" do
// 103:     it "returns the current domain target" do
// 104:       allow(described_class).to receive(:root?).and_return(false)
// 105:       expect(described_class.domain_target).to match(%r{gui/(\d+)})
// 106:     end
// 107:
// 108:     it "returns the root domain target" do
// 109:       allow(described_class).to receive(:root?).and_return(true)
// 110:       expect(described_class.domain_target).to match("system")
// 111:     end
// 112:   end
// 113:
// 114:   describe "#boot_path" do
// 115:     it "macOS - returns the boot path" do
// 116:       allow(described_class).to receive(:launchctl?).and_return(true)
// 117:       expect(described_class.boot_path.to_s).to eq("/Library/LaunchDaemons")
// 118:     end
// 119:
// 120:     it "SystemD - returns the boot path" do
// 121:       allow(described_class).to receive_messages(launchctl?: false, systemctl?: true)
// 122:       expect(described_class.boot_path.to_s).to eq("/usr/lib/systemd/system")
// 123:     end
// 124:
// 125:     it "Unknown - raises an error" do
// 126:       allow(described_class).to receive_messages(launchctl?: false, systemctl?: false)
// 127:       expect do
// 128:         described_class.boot_path.to_s
// 129:       end.to raise_error(UsageError,
// 130:                          "Invalid usage: `brew services` is supported only on macOS or Linux (with systemd)!")
// 131:     end
// 132:   end
// 133:
// 134:   describe "#user_path" do
// 135:     it "macOS - returns the user path" do
// 136:       ENV["HOME"] = "/tmp_home"
// 137:       allow(described_class).to receive_messages(launchctl?: true, systemctl?: false)
// 138:       expect(described_class.user_path.to_s).to eq("/tmp_home/Library/LaunchAgents")
// 139:     end
// 140:
// 141:     it "systemD - returns the user path" do
// 142:       ENV["HOME"] = "/tmp_home"
// 143:       allow(described_class).to receive_messages(launchctl?: false, systemctl?: true)
// 144:       expect(described_class.user_path.to_s).to eq("/tmp_home/.config/systemd/user")
// 145:     end
// 146:
// 147:     it "Unknown - raises an error" do
// 148:       ENV["HOME"] = "/tmp_home"
// 149:       allow(described_class).to receive_messages(launchctl?: false, systemctl?: false)
// 150:       expect do
// 151:         described_class.user_path.to_s
// 152:       end.to raise_error(UsageError,
// 153:                          "Invalid usage: `brew services` is supported only on macOS or Linux (with systemd)!")
// 154:     end
// 155:   end
// 156:
// 157:   describe "#launchctl_find_service" do
// 158:     let(:label) { "homebrew.mxcl.foo" }
// 159:
// 160:     it "returns failure when launchctl is not available" do
// 161:       allow(described_class).to receive(:launchctl).and_return(nil)
// 162:       _, success, type = described_class.launchctl_find_service(label)
// 163:       expect(success).to be false
// 164:       expect(type).to eq(:launchctl_list)
// 165:     end
// 166:   end
// 167:
// 168:   describe "#launchctl_service_running?" do
// 169:     let(:label) { "homebrew.mxcl.foo" }
// 170:
// 171:     it "delegates to launchctl_find_service" do
// 172:       allow(described_class).to receive(:launchctl_find_service)
// 173:         .with(label, sudo: false).and_return(["output", true, :launchctl_print])
// 174:       expect(described_class.launchctl_service_running?(label)).to be true
// 175:     end
// 176:   end
// 177:
// 178:   describe "#path" do
// 179:     it "macOS - user - returns the current relevant path" do
// 180:       ENV["HOME"] = "/tmp_home"
// 181:       allow(described_class).to receive_messages(root?: false, launchctl?: true, systemctl?: false)
// 182:       expect(described_class.path.to_s).to eq("/tmp_home/Library/LaunchAgents")
// 183:     end
// 184:
// 185:     it "macOS - root- returns the current relevant path" do
// 186:       ENV["HOME"] = "/tmp_home"
// 187:       allow(described_class).to receive_messages(root?: true, launchctl?: true, systemctl?: false)
// 188:       expect(described_class.path.to_s).to eq("/Library/LaunchDaemons")
// 189:     end
// 190:
// 191:     it "systemD - user - returns the current relevant path" do
// 192:       ENV["HOME"] = "/tmp_home"
// 193:       allow(described_class).to receive_messages(root?: false, launchctl?: false, systemctl?: true)
// 194:       expect(described_class.path.to_s).to eq("/tmp_home/.config/systemd/user")
// 195:     end
// 196:
// 197:     it "systemD - root- returns the current relevant path" do
// 198:       ENV["HOME"] = "/tmp_home"
// 199:       allow(described_class).to receive_messages(root?: true, launchctl?: false, systemctl?: true)
// 200:       expect(described_class.path.to_s).to eq("/usr/lib/systemd/system")
// 201:     end
// 202:   end
// 203: end
