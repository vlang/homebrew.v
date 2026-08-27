module linux

import brew_runtime

// Translated from Homebrew/brew `test/os/linux/diagnostic_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:checks) { described_class.new }` at line 8.
pub fn ruby_diagnostic_spec_l8_d1_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checks', ...args)
}

// Ruby specify `specify "#check_supported_architecture" do` at line 14.
pub fn ruby_diagnostic_spec_l14_d2_check_supported_architecture(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_supported_architecture', ...args)
}

// Ruby specify `specify "#check_glibc_minimum_version" do` at line 21.
pub fn ruby_diagnostic_spec_l21_d3_check_glibc_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_glibc_minimum_version', ...args)
}

// Ruby specify `specify "#check_glibc_next_version" do` at line 28.
pub fn ruby_diagnostic_spec_l28_d4_check_glibc_next_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_glibc_next_version', ...args)
}

// Ruby specify `specify "#check_kernel_minimum_version" do` at line 37.
pub fn ruby_diagnostic_spec_l37_d5_check_kernel_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_kernel_minimum_version', ...args)
}

// Ruby specify `specify "#check_for_installed_developer_tools explains system build tools" do` at line 44.
pub fn ruby_diagnostic_spec_l44_d6_check_for_installed_developer_tools(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_for_installed_developer_tools', ...args)
}

// Ruby it `it "points at brew install gcc" do` at line 56.
pub fn ruby_diagnostic_spec_l56_d7_points(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('points', ...args)
}

// Ruby specify `specify "#fatal_build_from_source_checks" do` at line 61.
pub fn ruby_diagnostic_spec_l61_d8_fatal_build_from_source_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#fatal_build_from_source_checks', ...args)
}

// Ruby specify `specify "#check_linux_sandbox returns nil when Linux sandboxing is disabled" do` at line 65.
pub fn ruby_diagnostic_spec_l65_d9_check_linux_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_linux_sandbox', ...args)
}

// Ruby specify `specify "#check_linux_sandbox returns nil when the Linux sandbox is available" do` at line 73.
pub fn ruby_diagnostic_spec_l73_d10_check_linux_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_linux_sandbox', ...args)
}

// Ruby specify `specify "#check_linux_sandbox returns nil inside Docker outside GitHub Actions" do` at line 82.
pub fn ruby_diagnostic_spec_l82_d11_check_linux_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_linux_sandbox', ...args)
}

// Ruby specify `specify "#check_linux_sandbox describes unsupported Landlock" do` at line 91.
pub fn ruby_diagnostic_spec_l91_d12_check_linux_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_linux_sandbox', ...args)
}

// Ruby specify `specify "#check_linux_sandbox describes missing Fiddle" do` at line 110.
pub fn ruby_diagnostic_spec_l110_d13_check_linux_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_linux_sandbox', ...args)
}

// Ruby specify `specify "#check_linux_sandbox describes unavailable Landlock inside Docker on GitHub Actions" do` at line 129.
pub fn ruby_diagnostic_spec_l129_d14_check_linux_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_linux_sandbox', ...args)
}

// Ruby specify `specify "#check_for_symlinked_home" do` at line 141.
pub fn ruby_diagnostic_spec_l141_d15_check_for_symlinked_home(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#check_for_symlinked_home', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "diagnostic"
// 5: require "sandbox"
// 6:
// 7: RSpec.describe Homebrew::Diagnostic::Checks do
// 8:   subject(:checks) { described_class.new }
// 9:
// 10:   before do
// 11:     allow(OS::Linux).to receive(:inside_docker?).and_return(false)
// 12:   end
// 13:
// 14:   specify "#check_supported_architecture" do
// 15:     allow(Hardware::CPU).to receive(:type).and_return(:arm64)
// 16:
// 17:     expect(checks.check_supported_architecture&.to_s)
// 18:       .to match(/Your CPU architecture .+ is not supported/)
// 19:   end
// 20:
// 21:   specify "#check_glibc_minimum_version" do
// 22:     allow(OS::Linux::Glibc).to receive(:below_minimum_version?).and_return(true)
// 23:
// 24:     expect(checks.check_glibc_minimum_version&.to_s)
// 25:       .to match(/Your system glibc .+ is too old/)
// 26:   end
// 27:
// 28:   specify "#check_glibc_next_version" do
// 29:     allow(OS).to receive(:const_get).with(:LINUX_GLIBC_NEXT_CI_VERSION).and_return("2.39")
// 30:     allow(OS::Linux::Glibc).to receive_messages(below_ci_version?: false, system_version: Version.new("2.35"))
// 31:     allow(ENV).to receive(:[]).and_return(nil)
// 32:
// 33:     expect(checks.check_glibc_next_version&.to_s)
// 34:       .to match("Your system glibc 2.35 is older than 2.39")
// 35:   end
// 36:
// 37:   specify "#check_kernel_minimum_version" do
// 38:     allow(OS::Linux::Kernel).to receive(:below_minimum_version?).and_return(true)
// 39:
// 40:     expect(checks.check_kernel_minimum_version&.to_s)
// 41:       .to match(/Your Linux kernel .+ is too old/)
// 42:   end
// 43:
// 44:   specify "#check_for_installed_developer_tools explains system build tools" do
// 45:     allow(DevelopmentTools).to receive(:installed?).and_return(false)
// 46:
// 47:     expect(checks.check_for_installed_developer_tools&.to_s)
// 48:       .to include(
// 49:         "No developer tools installed.",
// 50:         "Install a system C compiler and the standard development tools",
// 51:         "https://docs.brew.sh/Homebrew-on-Linux#requirements",
// 52:       )
// 53:   end
// 54:
// 55:   describe ".custom_installation_instructions" do
// 56:     it "points at brew install gcc" do
// 57:       expect(DevelopmentTools.custom_installation_instructions).to include("brew install gcc")
// 58:     end
// 59:   end
// 60:
// 61:   specify "#fatal_build_from_source_checks" do
// 62:     expect(checks.fatal_build_from_source_checks).not_to include("check_linux_sandbox")
// 63:   end
// 64:
// 65:   specify "#check_linux_sandbox returns nil when Linux sandboxing is disabled" do
// 66:     expect(Sandbox).not_to receive(:failure_reason)
// 67:
// 68:     with_env(HOMEBREW_NO_SANDBOX_LINUX: "1") do
// 69:       expect(checks.check_linux_sandbox&.to_s).to be_nil
// 70:     end
// 71:   end
// 72:
// 73:   specify "#check_linux_sandbox returns nil when the Linux sandbox is available" do
// 74:     allow(Sandbox).to receive(:state).and_return(:available)
// 75:     expect(Sandbox).not_to receive(:failure_reason)
// 76:
// 77:     with_env(HOMEBREW_NO_SANDBOX_LINUX: nil) do
// 78:       expect(checks.check_linux_sandbox&.to_s).to be_nil
// 79:     end
// 80:   end
// 81:
// 82:   specify "#check_linux_sandbox returns nil inside Docker outside GitHub Actions" do
// 83:     allow(OS::Linux).to receive(:inside_docker?).and_return(true)
// 84:     expect(Sandbox).not_to receive(:state)
// 85:
// 86:     with_env(GITHUB_ACTIONS: nil, HOMEBREW_NO_SANDBOX_LINUX: nil) do
// 87:       expect(checks.check_linux_sandbox&.to_s).to be_nil
// 88:     end
// 89:   end
// 90:
// 91:   specify "#check_linux_sandbox describes unsupported Landlock" do
// 92:     allow(Sandbox).to receive_messages(
// 93:       state:          :unsupported,
// 94:       failure_reason: "Landlock is not supported by this Linux kernel.",
// 95:     )
// 96:
// 97:     with_env(HOMEBREW_NO_SANDBOX_LINUX: nil) do
// 98:       message = checks.check_linux_sandbox&.to_s
// 99:
// 100:       expect(message)
// 101:         .to include(
// 102:           "Landlock is not supported by this Linux kernel.",
// 103:           "Homebrew's Linux sandbox requires a kernel with Landlock enabled.",
// 104:           "export HOMEBREW_NO_SANDBOX_LINUX=1",
// 105:         )
// 106:       expect(message).to end_with("  export HOMEBREW_NO_SANDBOX_LINUX=1")
// 107:     end
// 108:   end
// 109:
// 110:   specify "#check_linux_sandbox describes missing Fiddle" do
// 111:     allow(Sandbox).to receive_messages(
// 112:       state:          :missing_fiddle,
// 113:       failure_reason: "Landlock requires Ruby's bundled Fiddle library.",
// 114:     )
// 115:
// 116:     with_env(HOMEBREW_NO_SANDBOX_LINUX: nil) do
// 117:       message = checks.check_linux_sandbox&.to_s
// 118:
// 119:       expect(message)
// 120:         .to include(
// 121:           "Landlock requires Ruby's bundled Fiddle library.",
// 122:           "Run Homebrew with its vendored Ruby, which includes Fiddle.",
// 123:           "export HOMEBREW_NO_SANDBOX_LINUX=1",
// 124:         )
// 125:       expect(message).not_to include("kernel with Landlock")
// 126:     end
// 127:   end
// 128:
// 129:   specify "#check_linux_sandbox describes unavailable Landlock inside Docker on GitHub Actions" do
// 130:     allow(OS::Linux).to receive(:inside_docker?).and_return(true)
// 131:     allow(Sandbox).to receive_messages(
// 132:       state:          :disabled,
// 133:       failure_reason: "Landlock is disabled by this Linux kernel.",
// 134:     )
// 135:
// 136:     with_env(GITHUB_ACTIONS: "true", HOMEBREW_NO_SANDBOX_LINUX: nil) do
// 137:       expect(checks.check_linux_sandbox&.to_s).to include("Landlock is disabled by this Linux kernel.")
// 138:     end
// 139:   end
// 140:
// 141:   specify "#check_for_symlinked_home" do
// 142:     allow(File).to receive(:symlink?).with("/home").and_return(true)
// 143:
// 144:     expect(checks.check_for_symlinked_home&.to_s)
// 145:       .to include("Your /home directory is a symlink")
// 146:   end
// 147: end
