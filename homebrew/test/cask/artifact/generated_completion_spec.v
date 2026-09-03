module artifact

import homebrew.cask.artifact as brew_artifact
import os

// Translated from Homebrew/brew `test/cask/artifact/generated_completion_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn generated_completion_spec_script() string {
	return '#!/bin/sh\necho "\$SHELL completion"\n'
}

fn generated_completion_spec_fixture(staged_path string, prefix string,
	options brew_artifact.GeneratedCompletionOptions) !brew_artifact.GeneratedCompletionArtifact {
	os.mkdir_all(os.join_path(staged_path, 'bin'))!
	executable := os.join_path(staged_path, 'bin/foo')
	os.write_file(executable, generated_completion_spec_script())!
	os.chmod(executable, 0o755)!
	return brew_artifact.new_generated_completion('test-generated-completion', staged_path, [
		'bin/foo',
		'completions',
	], brew_artifact.GeneratedCompletionOptions{
		...options
		prefix: prefix
	})
}

// Ruby let `let(:staged_path) { Pathname(Dir.mktmpdir) }` at line 5.
pub fn ruby_generated_completion_spec_l5_d1_staged_path(root string) !string {
	path := os.join_path(root, 'staged')
	os.mkdir_all(path)!
	return path
}

// Ruby let `let(:cask) do` at line 7.
pub fn ruby_generated_completion_spec_l7_d2_cask(staged_path string,
	prefix string) !brew_artifact.GeneratedCompletionArtifact {
	return generated_completion_spec_fixture(staged_path, prefix, brew_artifact.GeneratedCompletionOptions{})
}

// Ruby let `let(:bash_dir) { cask.config.bash_completion }` at line 16.
pub fn ruby_generated_completion_spec_l16_d3_bash_dir(prefix string) string {
	return os.join_path(prefix, 'etc/bash_completion.d')
}

// Ruby let `let(:zsh_dir) { cask.config.zsh_completion }` at line 17.
pub fn ruby_generated_completion_spec_l17_d4_zsh_dir(prefix string) string {
	return os.join_path(prefix, 'share/zsh/site-functions')
}

// Ruby let `let(:fish_dir) { cask.config.fish_completion }` at line 18.
pub fn ruby_generated_completion_spec_l18_d5_fish_dir(prefix string) string {
	return os.join_path(prefix, 'share/fish/vendor_completions.d')
}

// Ruby let `let(:run_sandboxed_payload) do` at line 19.
pub fn ruby_generated_completion_spec_l19_d6_run_sandboxed_payload(mut artifact brew_artifact.GeneratedCompletionArtifact) bool {
	artifact.install_phase(true)
	return artifact.sandbox_used && artifact.sandbox_runs == 1 && artifact.sandbox_calls == [
		'add_install_hook_rules',
		'run',
	]
}

// Ruby it `it "generates completion scripts for default shells" do` at line 36.
pub fn ruby_generated_completion_spec_l36_d7_generates(root string) !bool {
	staged_path := ruby_generated_completion_spec_l5_d1_staged_path(root)!
	prefix := os.join_path(root, 'prefix')
	mut artifact := ruby_generated_completion_spec_l7_d2_cask(staged_path, prefix)!
	artifact.install_phase(true)
	bash_path := os.join_path(ruby_generated_completion_spec_l16_d3_bash_dir(prefix), 'foo')
	zsh_path := os.join_path(ruby_generated_completion_spec_l17_d4_zsh_dir(prefix), '_foo')
	fish_path := os.join_path(ruby_generated_completion_spec_l18_d5_fish_dir(prefix), 'foo.fish')
	return os.is_file(bash_path) && os.read_file(bash_path)! == 'bash completion\n' && os.is_file(zsh_path) && os.read_file(zsh_path)! == 'zsh completion\n' && os.is_file(fish_path) && os.read_file(fish_path)! == 'fish completion\n'
}

// Ruby it `it "sandboxes completion generation without network access" do` at line 61.
pub fn ruby_generated_completion_spec_l61_d8_sandboxes(root string) !bool {
	staged_path := ruby_generated_completion_spec_l5_d1_staged_path(root)!
	mut artifact := ruby_generated_completion_spec_l7_d2_cask(staged_path, os.join_path(root, 'prefix'))!
	artifact.install_phase(true)
	return artifact.sandbox_used && artifact.sandbox_runs == 1 && !artifact.network_access_allowed && artifact.sandbox_calls == [
		'add_install_hook_rules',
		'run',
	] && artifact.sandbox_home != '' && !os.exists(artifact.sandbox_home)
}

// Ruby it `it "warns and continues generating other shells" do` at line 94.
pub fn ruby_generated_completion_spec_l94_d9_warns(root string) !bool {
	staged_path := ruby_generated_completion_spec_l5_d1_staged_path(root)!
	prefix := os.join_path(root, 'prefix')
	mut artifact := ruby_generated_completion_spec_l7_d2_cask(staged_path, prefix)!
	executable := os.join_path(staged_path, 'bin/foo')
	os.write_file(executable, '#!/bin/sh\n[ "\$SHELL" = bash ] && exit 1\necho "\$SHELL completion"\n')!
	artifact.install_phase(true)
	return artifact.warnings.any(it.contains('Failed to generate bash completions')) && os.is_file(os.join_path(ruby_generated_completion_spec_l17_d4_zsh_dir(prefix), '_foo'))
}

// Ruby it `it "removes generated completion scripts" do` at line 123.
pub fn ruby_generated_completion_spec_l123_d10_removes(root string) !bool {
	staged_path := ruby_generated_completion_spec_l5_d1_staged_path(root)!
	prefix := os.join_path(root, 'prefix')
	mut artifact := ruby_generated_completion_spec_l7_d2_cask(staged_path, prefix)!
	artifact.install_phase(false)
	paths := [
		os.join_path(ruby_generated_completion_spec_l16_d3_bash_dir(prefix), 'foo'),
		os.join_path(ruby_generated_completion_spec_l17_d4_zsh_dir(prefix), '_foo'),
		os.join_path(ruby_generated_completion_spec_l18_d5_fish_dir(prefix), 'foo.fish'),
	]
	if paths.any(!os.exists(it)) {
		return false
	}
	artifact.uninstall_phase()
	return paths.all(!os.exists(it))
}

// Ruby let `let(:cask) do` at line 142.
pub fn ruby_generated_completion_spec_l142_d11_cask(staged_path string,
	prefix string) !brew_artifact.GeneratedCompletionArtifact {
	return generated_completion_spec_fixture(staged_path, prefix, brew_artifact.GeneratedCompletionOptions{
		base_name: 'bar'
		base_name_set: true
		shell_parameter_format: 'arg'
		shells: ['zsh']
		shells_set: true
	})
}

// Ruby it `it "generates only for the specified shell with the correct format" do` at line 152.
pub fn ruby_generated_completion_spec_l152_d12_generates(root string) !bool {
	staged_path := ruby_generated_completion_spec_l5_d1_staged_path(root)!
	prefix := os.join_path(root, 'prefix')
	mut artifact := ruby_generated_completion_spec_l142_d11_cask(staged_path, prefix)!
	artifact.install_phase(true)
	if artifact.last_completions.len != 1 || artifact.last_completions[0].parameter.arguments != [
		'--shell=zsh',
	] {
		return false
	}
	return os.is_file(os.join_path(ruby_generated_completion_spec_l17_d4_zsh_dir(prefix), '_bar')) && !os.exists(os.join_path(ruby_generated_completion_spec_l16_d3_bash_dir(prefix), 'bar')) && !os.exists(os.join_path(ruby_generated_completion_spec_l18_d5_fish_dir(prefix), 'bar.fish'))
}

// Ruby let `let(:cask) do` at line 179.
pub fn ruby_generated_completion_spec_l179_d13_cask(staged_path string,
	prefix string) !brew_artifact.GeneratedCompletionArtifact {
	return generated_completion_spec_fixture(staged_path, prefix, brew_artifact.GeneratedCompletionOptions{
		shells: ['bash', 'zsh', 'fish', 'pwsh']
		shells_set: true
	})
}

// Ruby it `it "normalizes shells to symbols" do` at line 189.
pub fn ruby_generated_completion_spec_l189_d14_normalizes(artifact brew_artifact.GeneratedCompletionArtifact) bool {
	return artifact.shells == ['bash', 'zsh', 'fish', 'pwsh']
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::GeneratedCompletion, :cask do
// 5:   let(:staged_path) { Pathname(Dir.mktmpdir) }
// 6:
// 7:   let(:cask) do
// 8:     Cask::Cask.new("test-generated-completion") do
// 9:       version "1.0"
// 10:       sha256 :no_check
// 11:       url "file:///dev/null"
// 12:       generate_completions_from_executable "bin/foo", "completions"
// 13:     end
// 14:   end
// 15:
// 16:   let(:bash_dir) { cask.config.bash_completion }
// 17:   let(:zsh_dir) { cask.config.zsh_completion }
// 18:   let(:fish_dir) { cask.config.fish_completion }
// 19:   let(:run_sandboxed_payload) do
// 20:     proc { |args| Utils.safe_fork { exec(*args.map(&:to_s)) } }
// 21:   end
// 22:
// 23:   before do
// 24:     allow(Sandbox).to receive(:with_preserved_brew_file).and_yield
// 25:     allow(cask).to receive(:staged_path).and_return(staged_path)
// 26:     (staged_path/"bin").mkpath
// 27:     (staged_path/"bin/foo").write("#!/bin/sh\necho \"$SHELL completion\"")
// 28:     (staged_path/"bin/foo").chmod(0755)
// 29:   end
// 30:
// 31:   after do
// 32:     FileUtils.rm_rf(staged_path)
// 33:   end
// 34:
// 35:   describe "#install_phase" do
// 36:     it "generates completion scripts for default shells" do
// 37:       artifact = cask.artifacts.grep(described_class).first
// 38:
// 39:       allow(Sandbox).to receive(:available?).and_return(true)
// 40:       allow(Sandbox).to receive(:new) do
// 41:         instance_double(Sandbox).tap do |sandbox|
// 42:           allow(sandbox).to receive(:allow_read)
// 43:           allow(sandbox).to receive(:add_install_hook_rules)
// 44:           allow(sandbox).to receive(:allow_write_path)
// 45:           allow(sandbox).to receive(:run) do |*args|
// 46:             run_sandboxed_payload.call(args)
// 47:           end
// 48:         end
// 49:       end
// 50:
// 51:       artifact.install_phase
// 52:
// 53:       expect(bash_dir/"foo").to be_a_file
// 54:       expect((bash_dir/"foo").read).to eq("bash completion\n")
// 55:       expect(zsh_dir/"_foo").to be_a_file
// 56:       expect((zsh_dir/"_foo").read).to eq("zsh completion\n")
// 57:       expect(fish_dir/"foo.fish").to be_a_file
// 58:       expect((fish_dir/"foo.fish").read).to eq("fish completion\n")
// 59:     end
// 60:
// 61:     it "sandboxes completion generation without network access" do
// 62:       artifact = cask.artifacts.grep(described_class).first
// 63:       sandboxes = []
// 64:       calls = []
// 65:       homes = []
// 66:
// 67:       allow(Sandbox).to receive(:available?).and_return(true)
// 68:       allow(Sandbox).to receive(:new) do
// 69:         instance_double(Sandbox).tap do |sandbox|
// 70:           allow(sandbox).to receive(:allow_read)
// 71:           expect(sandbox).to receive(:allow_read).with(path: staged_path, type: :subpath)
// 72:           expect(sandbox).to receive(:add_install_hook_rules).with(network_access_allowed: false) do
// 73:             calls << :add_install_hook_rules
// 74:           end
// 75:           allow(sandbox).to receive(:allow_write_path)
// 76:           allow(sandbox).to receive(:run) do |*args|
// 77:             calls << :run
// 78:             homes << Pathname(args.grep(/^HOME=/).first.delete_prefix("HOME="))
// 79:             run_sandboxed_payload.call(args)
// 80:           end
// 81:           sandboxes << sandbox
// 82:         end
// 83:       end
// 84:
// 85:       artifact.install_phase
// 86:
// 87:       expect(sandboxes.length).to eq(1)
// 88:       expect(calls).to eq([:add_install_hook_rules, :run])
// 89:       expect(homes.uniq.length).to eq(1)
// 90:       expect(homes).to all(satisfy { |home| !home.exist? })
// 91:     end
// 92:
// 93:     context "when generation fails for one shell" do
// 94:       it "warns and continues generating other shells" do
// 95:         artifact = cask.artifacts.grep(described_class).first
// 96:         (staged_path/"bin/foo").write <<~SH
// 97:           #!/bin/sh
// 98:           [ "$SHELL" = bash ] && exit 1
// 99:           echo "$SHELL completion"
// 100:         SH
// 101:
// 102:         allow(Sandbox).to receive(:available?).and_return(true)
// 103:         allow(Sandbox).to receive(:new) do
// 104:           instance_double(Sandbox).tap do |sandbox|
// 105:             allow(sandbox).to receive(:allow_read)
// 106:             allow(sandbox).to receive(:add_install_hook_rules)
// 107:             allow(sandbox).to receive(:allow_write_path)
// 108:             allow(sandbox).to receive(:run) do |*args|
// 109:               run_sandboxed_payload.call(args)
// 110:             end
// 111:           end
// 112:         end
// 113:
// 114:         expect { artifact.install_phase }
// 115:           .to output(/Failed to generate bash completions/).to_stderr
// 116:
// 117:         expect(zsh_dir/"_foo").to be_a_file
// 118:       end
// 119:     end
// 120:   end
// 121:
// 122:   describe "#uninstall_phase" do
// 123:     it "removes generated completion scripts" do
// 124:       artifact = cask.artifacts.grep(described_class).first
// 125:
// 126:       bash_dir.mkpath
// 127:       zsh_dir.mkpath
// 128:       fish_dir.mkpath
// 129:       (bash_dir/"foo").write("bash")
// 130:       (zsh_dir/"_foo").write("zsh")
// 131:       (fish_dir/"foo.fish").write("fish")
// 132:
// 133:       artifact.uninstall_phase(command: NeverSudoSystemCommand)
// 134:
// 135:       expect(bash_dir/"foo").not_to exist
// 136:       expect(zsh_dir/"_foo").not_to exist
// 137:       expect(fish_dir/"foo.fish").not_to exist
// 138:     end
// 139:   end
// 140:
// 141:   context "with specific shells and format" do
// 142:     let(:cask) do
// 143:       Cask::Cask.new("test-generated-completion") do
// 144:         version "1.0"
// 145:         sha256 :no_check
// 146:         url "file:///dev/null"
// 147:         generate_completions_from_executable "bin/foo", "completions",
// 148:                                              shells: [:zsh], shell_parameter_format: :arg, base_name: "bar"
// 149:       end
// 150:     end
// 151:
// 152:     it "generates only for the specified shell with the correct format" do
// 153:       artifact = cask.artifacts.grep(described_class).first
// 154:       captured_payload = T.let({}, T::Hash[String, T.untyped])
// 155:
// 156:       allow(Sandbox).to receive(:available?).and_return(true)
// 157:       allow(Sandbox).to receive(:new) do
// 158:         instance_double(Sandbox).tap do |sandbox|
// 159:           allow(sandbox).to receive(:allow_read)
// 160:           allow(sandbox).to receive(:add_install_hook_rules)
// 161:           allow(sandbox).to receive(:allow_write_path)
// 162:           allow(sandbox).to receive(:run) do |*args|
// 163:             captured_payload = JSON.parse(Pathname(args.last).read)
// 164:             run_sandboxed_payload.call(args)
// 165:           end
// 166:         end
// 167:       end
// 168:
// 169:       artifact.install_phase
// 170:
// 171:       expect(captured_payload.fetch("completions").fetch(0).fetch("shell_parameter")).to eq("--shell=zsh")
// 172:       expect(zsh_dir/"_bar").to be_a_file
// 173:       expect(bash_dir/"bar").not_to exist
// 174:       expect(fish_dir/"bar.fish").not_to exist
// 175:     end
// 176:   end
// 177:
// 178:   context "with string shells" do
// 179:     let(:cask) do
// 180:       Cask::Cask.new("test-generated-completion") do
// 181:         version "1.0"
// 182:         sha256 :no_check
// 183:         url "file:///dev/null"
// 184:         generate_completions_from_executable "bin/foo", "completions",
// 185:                                              shells: %w[bash zsh fish pwsh]
// 186:       end
// 187:     end
// 188:
// 189:     it "normalizes shells to symbols" do
// 190:       artifact = cask.artifacts.grep(described_class).first
// 191:
// 192:       expect(artifact.shells).to eq([:bash, :zsh, :fish, :pwsh])
// 193:     end
// 194:   end
// 195: end
