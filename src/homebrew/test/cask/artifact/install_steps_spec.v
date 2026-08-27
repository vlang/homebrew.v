module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/install_steps_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) do` at line 9.
pub fn ruby_install_steps_spec_l9_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "runs structured steps through installer artifact phases" do` at line 38.
pub fn ruby_install_steps_spec_l38_d2_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Ruby it `it "omits cask command output defaults" do` at line 63.
pub fn ruby_install_steps_spec_l63_d3_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "sandboxes complete step blocks, including system commands" do` at line 70.
pub fn ruby_install_steps_spec_l70_d4_sandboxes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sandboxes', ...args)
}

// Ruby it `it "allows network access for runs that request it" do` at line 122.
pub fn ruby_install_steps_spec_l122_d5_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "allows` at line 151.
pub fn ruby_install_steps_spec_l151_d6_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "runs a flight block after matching steps during migration" do` at line 174.
pub fn ruby_install_steps_spec_l174_d7_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::AbstractInstallSteps, :cask do
// 5:   before do
// 6:     allow(Sandbox).to receive(:available?).and_return(false)
// 7:   end
// 8:
// 9:   let(:cask) do
// 10:     Cask::Cask.new("with-install-steps") do
// 11:       version "1.2.3"
// 12:       sha256 :no_check
// 13:       url "file://#{TEST_FIXTURE_DIR}/cask/container.zip"
// 14:
// 15:       preflight_steps do
// 16:         mkdir_p "Prepared"
// 17:         set_permissions "Prepared", "0755"
// 18:         touch "Prepared/touched"
// 19:       end
// 20:
// 21:       postflight_steps do
// 22:         move "move-source", "Prepared/moved"
// 23:         symlink "Prepared/moved", "PreparedLink", source_base: :relative, remove_on_uninstall: true
// 24:         run "/usr/bin/true"
// 25:       end
// 26:
// 27:       uninstall_preflight_steps do
// 28:         mkdir_p "UninstallPrepared"
// 29:         touch "UninstallPrepared/touched"
// 30:       end
// 31:
// 32:       uninstall_postflight_steps do
// 33:         move_contents "UninstallPrepared", "UninstallMoved"
// 34:       end
// 35:     end
// 36:   end
// 37:
// 38:   it "runs structured steps through installer artifact phases" do
// 39:     cask.staged_path.mkpath
// 40:     cask.config_path.dirname.mkpath
// 41:     (cask.staged_path/"move-source").write "moved"
// 42:
// 43:     installer = Cask::Installer.new(cask, command: NeverSudoSystemCommand)
// 44:     previous_umask = File.umask(077)
// 45:     begin
// 46:       installer.install_artifacts
// 47:     ensure
// 48:       File.umask(previous_umask)
// 49:     end
// 50:
// 51:     expect(cask.staged_path/"Prepared").to be_a_directory
// 52:     expect((cask.staged_path/"Prepared").stat.mode & 0777).to eq(0755)
// 53:     expect(cask.staged_path/"Prepared/touched").to exist
// 54:     expect(cask.staged_path/"Prepared/moved").to exist
// 55:     expect(cask.staged_path/"PreparedLink").to be_a_symlink
// 56:
// 57:     installer.uninstall_artifacts
// 58:
// 59:     expect(cask.staged_path/"PreparedLink").not_to exist
// 60:     expect(cask.staged_path/"UninstallMoved/touched").to exist
// 61:   end
// 62:
// 63:   it "omits cask command output defaults" do
// 64:     artifact = cask.artifacts.find { |candidate| candidate.is_a?(Cask::Artifact::PostflightSteps) }
// 65:     run_step = artifact.steps.find { |step| step["type"] == "run" }
// 66:
// 67:     expect(run_step).not_to include("print_stdout", "suppress_stderr", "writable_paths", "network_access")
// 68:   end
// 69:
// 70:   it "sandboxes complete step blocks, including system commands" do
// 71:     original_home = mktmpdir
// 72:     ENV["HOME"] = original_home.to_s
// 73:     cask = Cask::Cask.new("with-sandboxed-install-steps") do
// 74:       version "1.2.3"
// 75:       sha256 :no_check
// 76:       url "file://#{TEST_FIXTURE_DIR}/cask/container.zip"
// 77:
// 78:       postflight_steps do
// 79:         touch "Library/Application Support/cask-home-state", base: :home
// 80:         run "helper", args: ["/"], base: :staged_path,
// 81:                       writable_paths: ["/Library/Example"]
// 82:         run "/usr/bin/true"
// 83:       end
// 84:     end
// 85:     sandbox = instance_double(Sandbox).as_null_object
// 86:     cask.staged_path.mkpath
// 87:     cask.config_path.dirname.mkpath
// 88:     (cask.staged_path/"helper").write <<~SH
// 89:       #!/bin/sh
// 90:       touch "#{cask.staged_path}/sandbox-ran"
// 91:     SH
// 92:     (cask.staged_path/"helper").chmod 0755
// 93:
// 94:     allow(Sandbox).to receive_messages(available?: true, new: sandbox)
// 95:     allow(sandbox).to receive(:allow_write_path)
// 96:     expect(Sandbox).to receive(:with_preserved_brew_file).and_yield
// 97:     expect(sandbox).to receive(:add_install_hook_rules).with(network_access_allowed: false)
// 98:     expect(sandbox).to receive(:allow_write_path).with(cask.caskroom_path)
// 99:     expect(sandbox).to receive(:allow_write_path).with(Pathname("/Library/Example"))
// 100:     expect(sandbox).not_to receive(:allow_write_path).with(Pathname("/"))
// 101:     expect(sandbox).to receive(:allow_write_path).with(original_home/"Library/Application Support")
// 102:     expect(sandbox).to receive(:allow_read)
// 103:       .with(path: original_home/"Library/Application Support", type: :subpath)
// 104:     expect(sandbox).to receive(:run).once do |*args|
// 105:       expect(args).to include(HOMEBREW_LIBRARY_PATH/"cask_artifact.rb")
// 106:
// 107:       payload = JSON.parse(Pathname(args.last).read)
// 108:       expect(payload.fetch("action")).to eq("install_steps")
// 109:       expect(payload.fetch("steps").filter_map do |step|
// 110:         step.dig("command", "path") if step["type"] == "run"
// 111:       end)
// 112:         .to eq(%w[helper /usr/bin/true])
// 113:       Utils.safe_fork { exec(*args.map(&:to_s)) }
// 114:     end
// 115:
// 116:     Cask::Installer.new(cask, command: NeverSudoSystemCommand).install_artifacts
// 117:
// 118:     expect(cask.staged_path/"sandbox-ran").to exist
// 119:     expect(original_home/"Library/Application Support/cask-home-state").to exist
// 120:   end
// 121:
// 122:   it "allows network access for runs that request it" do
// 123:     cask = Cask::Cask.new("with-networked-install-step") do
// 124:       version "1.2.3"
// 125:       sha256 :no_check
// 126:       url "file://#{TEST_FIXTURE_DIR}/cask/container.zip"
// 127:
// 128:       postflight_steps do
// 129:         run "/usr/bin/true", network_access: true
// 130:       end
// 131:     end
// 132:     sandbox = instance_double(Sandbox).as_null_object
// 133:     cask.staged_path.mkpath
// 134:     cask.config_path.dirname.mkpath
// 135:
// 136:     allow(Sandbox).to receive_messages(available?: true, new: sandbox)
// 137:     allow(Sandbox).to receive(:with_preserved_brew_file).and_yield
// 138:     expect(sandbox).to receive(:add_install_hook_rules).with(network_access_allowed: true)
// 139:     expect(sandbox).to receive(:run)
// 140:
// 141:     Cask::Installer.new(cask, command: NeverSudoSystemCommand).install_artifacts
// 142:   end
// 143:
// 144:   context "when install steps may require sudo" do
// 145:     {
// 146:       "an explicitly privileged command" => proc { run "/usr/bin/true", sudo: true },
// 147:       "a conditionally privileged step"  => proc { remove "/usr/local/example", sudo: :if_needed },
// 148:       "an ownership step"                => proc { set_ownership "/usr/local/example" },
// 149:       "a keychain certificate step"      => proc { delete_keychain_certificates "Example" },
// 150:     }.each do |description, step|
// 151:       it "allows #{description} to run sudo outside the sandbox" do
// 152:         cask = Cask::Cask.new("with-sandboxed-sudo-install-steps") do
// 153:           version "1.2.3"
// 154:           sha256 :no_check
// 155:           url "file://#{TEST_FIXTURE_DIR}/cask/container.zip"
// 156:
// 157:           postflight_steps(&step)
// 158:         end
// 159:         sandbox = instance_double(Sandbox).as_null_object
// 160:         cask.staged_path.mkpath
// 161:         cask.config_path.dirname.mkpath
// 162:
// 163:         allow(Sandbox).to receive_messages(available?: true, new: sandbox)
// 164:         allow(sandbox).to receive(:allow_write_path)
// 165:         allow(Sandbox).to receive(:with_preserved_brew_file).and_yield
// 166:         expect(sandbox).to receive(:allow_process_exec).with("/usr/bin/sudo", no_sandbox: true)
// 167:         expect(sandbox).to receive(:run)
// 168:
// 169:         Cask::Installer.new(cask, command: NeverSudoSystemCommand).install_artifacts
// 170:       end
// 171:     end
// 172:   end
// 173:
// 174:   it "runs a flight block after matching steps during migration" do
// 175:     cask = Cask::Cask.new("with-install-steps-bridge") do
// 176:       version "1.2.3"
// 177:       sha256 :no_check
// 178:       url "file://#{TEST_FIXTURE_DIR}/cask/container.zip"
// 179:
// 180:       preflight_steps do
// 181:         touch "steps-ran"
// 182:       end
// 183:
// 184:       preflight do
// 185:         raise "preflight steps did not run first" unless (staged_path/"steps-ran").exist?
// 186:
// 187:         FileUtils.touch staged_path/"ruby-block-ran"
// 188:       end
// 189:     end
// 190:
// 191:     cask.staged_path.mkpath
// 192:     cask.config_path.dirname.mkpath
// 193:
// 194:     Cask::Installer.new(cask, command: NeverSudoSystemCommand).install_artifacts
// 195:
// 196:     expect(cask.staged_path/"ruby-block-ran").to exist
// 197:     expect(cask.staged_path/"steps-ran").to exist
// 198:   end
// 199: end
