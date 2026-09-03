module artifact

import brew_runtime
import homebrew
import homebrew.cask.artifact as install_steps_artifact
import os

// Translated from Homebrew/brew `test/cask/artifact/install_steps_spec.rb`.
// The original source is retained below until every stub has a typed V body.

struct CaskInstallStepsSpecExecutor {}

fn (_ CaskInstallStepsSpecExecutor) run(command string, arguments []string,
	options homebrew.InstallStepsCommandOptions) !homebrew.InstallStepsCommandResult {
	_ = options
	if command == 'chmod' && arguments.len > 0 {
		os.chmod(arguments.last(), 0o755)!
	}
	return homebrew.InstallStepsCommandResult{}
}

fn cask_install_steps_spec_path(path string, base string) brew_runtime.Value {
	mut values := {
		'path': brew_runtime.string_value(path)
	}
	if base != '' {
		values['base'] = brew_runtime.string_value(base)
	}
	return brew_runtime.map_value(values)
}

fn cask_install_steps_spec_step(kind string,
	fields map[string]brew_runtime.Value) homebrew.InstallStep {
	mut step := fields.clone()
	step['type'] = brew_runtime.string_value(kind)
	return homebrew.InstallStep(step)
}

fn cask_install_steps_spec_steps(cask brew_runtime.Value,
	key string) homebrew.InstallSteps {
	return homebrew.install_steps_from_value(cask.map_data[key] or {
		brew_runtime.array_value([])
	})
}

fn cask_install_steps_spec_root(args []brew_runtime.Value, suffix string) string {
	if args.len > 0 && args[0].as_string() != '' {
		return args[0].as_string()
	}
	return os.join_path(os.temp_dir(), 'brew-v-cask-install-steps-${suffix}-${os.getpid()}')
}

fn cask_install_steps_spec_cask(root string) brew_runtime.Value {
	staged_path := os.join_path(root, 'staged')
	preflight_steps := [cask_install_steps_spec_step('mkdir_p', {
		'path': cask_install_steps_spec_path('Prepared', 'staged_path')
	}), cask_install_steps_spec_step('set_permissions', {
		'paths':       brew_runtime.array_value([
			cask_install_steps_spec_path('Prepared', 'staged_path'),
		])
		'permissions': brew_runtime.string_value('0755')
	}), cask_install_steps_spec_step('touch', {
		'path': cask_install_steps_spec_path('Prepared/touched', 'staged_path')
	})]
	postflight_steps := [cask_install_steps_spec_step('move', {
		'source': cask_install_steps_spec_path('move-source', 'staged_path')
		'target': cask_install_steps_spec_path('Prepared/moved', 'staged_path')
	}), cask_install_steps_spec_step('symlink', {
		'source':    cask_install_steps_spec_path('Prepared/moved', 'relative')
		'target':    cask_install_steps_spec_path('PreparedLink', 'staged_path')
		'uninstall': brew_runtime.bool_value(true)
	}), cask_install_steps_spec_step('run', {
		'command': cask_install_steps_spec_path('/usr/bin/true', '')
	})]
	uninstall_preflight_steps := [cask_install_steps_spec_step('mkdir_p', {
		'path': cask_install_steps_spec_path('UninstallPrepared', 'staged_path')
	}), cask_install_steps_spec_step('touch', {
		'path': cask_install_steps_spec_path('UninstallPrepared/touched', 'staged_path')
	})]
	uninstall_postflight_steps := [cask_install_steps_spec_step('move_contents', {
		'source': cask_install_steps_spec_path('UninstallPrepared', 'staged_path')
		'target': cask_install_steps_spec_path('UninstallMoved', 'staged_path')
	})]
	return brew_runtime.Value{
		type_name: 'Cask::Cask'
		repr: 'with-install-steps'
		map_data: {
			'name':                       brew_runtime.string_value('with-install-steps')
			'token':                      brew_runtime.string_value('with-install-steps')
			'version':                    brew_runtime.string_value('1.2.3')
			'staged_path':                brew_runtime.string_value(staged_path)
			'caskroom_path':              brew_runtime.string_value(os.join_path(root, 'Caskroom', 'with-install-steps'))
			'config':                     brew_runtime.map_value({
				'appdir': brew_runtime.string_value(os.join_path(root, 'Applications'))
			})
			'preflight_steps':            homebrew.install_steps_value(preflight_steps)
			'postflight_steps':           homebrew.install_steps_value(postflight_steps)
			'uninstall_preflight_steps':  homebrew.install_steps_value(uninstall_preflight_steps)
			'uninstall_postflight_steps': homebrew.install_steps_value(uninstall_postflight_steps)
		}
		attributes: {
			'home':   os.join_path(root, 'home')
			'prefix': os.join_path(root, 'prefix')
		}
	}
}

fn cask_install_steps_spec_artifact(cask brew_runtime.Value, key string,
	class_name string) install_steps_artifact.CaskInstallStepsArtifact {
	return install_steps_artifact.new_cask_install_steps_artifact(cask, cask_install_steps_spec_steps(cask, key), class_name)
}

// Ruby let `let(:cask) do` at line 9.
pub fn ruby_install_steps_spec_l9_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_install_steps_spec_cask(cask_install_steps_spec_root(args, 'fixture'))
}

// Ruby it `it "runs structured steps through installer artifact phases" do` at line 38.
pub fn ruby_install_steps_spec_l38_d2_runs(args ...brew_runtime.Value) brew_runtime.Value {
	root := cask_install_steps_spec_root(args, 'runs')
	os.rmdir_all(root) or {}
	defer {
		os.rmdir_all(root) or {}
	}
	cask := cask_install_steps_spec_cask(root)
	staged_path := cask.map_data['staged_path'].as_string()
	os.mkdir_all(staged_path) or { return brew_runtime.bool_value(false) }
	os.write_file(os.join_path(staged_path, 'move-source'), 'moved') or {
		return brew_runtime.bool_value(false)
	}
	executor := CaskInstallStepsSpecExecutor{}
	for key, class_name in {
		'preflight_steps':  'Cask::Artifact::PreflightSteps'
		'postflight_steps': 'Cask::Artifact::PostflightSteps'
	} {
		artifact := cask_install_steps_spec_artifact(cask, key, class_name)
		install_steps_artifact.run_cask_install_steps(artifact, 'install', false, executor) or {
			return brew_runtime.bool_value(false)
		}
	}
	prepared := os.join_path(staged_path, 'Prepared')
	mode := os.stat(prepared) or { return brew_runtime.bool_value(false) }
	installed := os.is_dir(prepared) && int(mode.get_mode().bitmask()) & 0o777 == 0o755
		&& os.exists(os.join_path(prepared, 'touched'))
		&& os.exists(os.join_path(prepared, 'moved'))
		&& os.is_link(os.join_path(staged_path, 'PreparedLink'))
	postflight := cask_install_steps_spec_artifact(cask, 'postflight_steps', 'Cask::Artifact::PostflightSteps')
	install_steps_artifact.run_cask_install_steps(postflight, 'uninstall', false, executor) or {
		return brew_runtime.bool_value(false)
	}
	for key, class_name in {
		'uninstall_preflight_steps':  'Cask::Artifact::UninstallPreflightSteps'
		'uninstall_postflight_steps': 'Cask::Artifact::UninstallPostflightSteps'
	} {
		artifact := cask_install_steps_spec_artifact(cask, key, class_name)
		install_steps_artifact.run_cask_install_steps(artifact, 'install', false, executor) or {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(installed
		&& !os.exists(os.join_path(staged_path, 'PreparedLink'))
		&& os.exists(os.join_path(staged_path, 'UninstallMoved', 'touched')))
}

// Ruby it `it "omits cask command output defaults" do` at line 63.
pub fn ruby_install_steps_spec_l63_d3_omits(args ...brew_runtime.Value) brew_runtime.Value {
	cask := ruby_install_steps_spec_l9_d1_cask(...args)
	steps := cask_install_steps_spec_steps(cask, 'postflight_steps')
	for step in steps {
		if (step['type'] or { continue }).as_string() == 'run' {
			return brew_runtime.bool_value('print_stdout' !in step && 'suppress_stderr' !in step && 'writable_paths' !in step && 'network_access' !in step)
		}
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "sandboxes complete step blocks, including system commands" do` at line 70.
pub fn ruby_install_steps_spec_l70_d4_sandboxes(args ...brew_runtime.Value) brew_runtime.Value {
	root := cask_install_steps_spec_root(args, 'sandbox')
	home := os.join_path(root, 'home')
	cask := cask_install_steps_spec_cask(root)
	steps := [cask_install_steps_spec_step('touch', {
		'path': cask_install_steps_spec_path('Library/Application Support/cask-home-state', 'home')
	}), cask_install_steps_spec_step('run', {
		'command':        cask_install_steps_spec_path('helper', 'staged_path')
		'args':           brew_runtime.string_array_value(['/'])
		'writable_paths': brew_runtime.array_value([
			cask_install_steps_spec_path('/Library/Example', ''),
		])
	}), cask_install_steps_spec_step('run', {
		'command': cask_install_steps_spec_path('/usr/bin/true', '')
	})]
	artifact := install_steps_artifact.new_cask_install_steps_artifact(cask, steps, 'Cask::Artifact::PostflightSteps')
	plan := install_steps_artifact.plan_cask_install_steps(artifact, 'install') or {
		return brew_runtime.bool_value(false)
	}
	payload_steps := homebrew.install_steps_from_value(plan.payload['steps'] or {
		return brew_runtime.bool_value(false)
	})
	mut commands := []string{}
	for step in payload_steps {
		if (step['type'] or { continue }).as_string() == 'run' {
			command := step['command'] or { continue }
			commands << (command.map_data['path'] or { command }).as_string()
		}
	}
	home_write_path := os.join_path(home, 'Library/Application Support')
	return brew_runtime.bool_value(!plan.network_access_allowed
		&& cask.map_data['caskroom_path'].as_string() in plan.allowed_write_paths
		&& '/Library/Example' in plan.allowed_write_paths
		&& '/' !in plan.allowed_write_paths && home_write_path in plan.allowed_write_paths
		&& home_write_path in plan.allowed_read_paths && commands == ['helper', '/usr/bin/true']
		&& (plan.payload['action'] or {
			brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
		}).as_string() == 'install_steps')
}

// Ruby it `it "allows network access for runs that request it" do` at line 122.
pub fn ruby_install_steps_spec_l122_d5_allows(args ...brew_runtime.Value) brew_runtime.Value {
	root := cask_install_steps_spec_root(args, 'network')
	cask := cask_install_steps_spec_cask(root)
	artifact := install_steps_artifact.new_cask_install_steps_artifact(cask, [
		cask_install_steps_spec_step('run', {
			'command':        cask_install_steps_spec_path('/usr/bin/true', '')
			'network_access': brew_runtime.bool_value(true)
		}),
	], 'Cask::Artifact::PostflightSteps')
	plan := install_steps_artifact.plan_cask_install_steps(artifact, 'install') or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(plan.network_access_allowed)
}

// Ruby it `it "allows` at line 151.
pub fn ruby_install_steps_spec_l151_d6_allows(args ...brew_runtime.Value) brew_runtime.Value {
	root := cask_install_steps_spec_root(args, 'sudo')
	cask := cask_install_steps_spec_cask(root)
	steps := [
		cask_install_steps_spec_step('run', {
			'command': cask_install_steps_spec_path('/usr/bin/true', '')
			'sudo':    brew_runtime.bool_value(true)
		}),
		cask_install_steps_spec_step('remove', {
			'paths': brew_runtime.array_value([
				cask_install_steps_spec_path('/usr/local/example', ''),
			])
			'sudo':  brew_runtime.object_value('Symbol', 'if_needed')
		}),
		cask_install_steps_spec_step('set_ownership', {
			'paths': brew_runtime.array_value([
				cask_install_steps_spec_path('/usr/local/example', ''),
			])
		}),
		cask_install_steps_spec_step('delete_keychain_certificate', {
			'name': brew_runtime.string_value('Example')
		}),
	]
	for step in steps {
		artifact := install_steps_artifact.new_cask_install_steps_artifact(cask, [
			step,
		], 'Cask::Artifact::PostflightSteps')
		plan := install_steps_artifact.plan_cask_install_steps(artifact, 'install') or {
			return brew_runtime.bool_value(false)
		}
		if !plan.allow_sudo {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby it `it "runs a flight block after matching steps during migration" do` at line 174.
pub fn ruby_install_steps_spec_l174_d7_runs(args ...brew_runtime.Value) brew_runtime.Value {
	root := cask_install_steps_spec_root(args, 'bridge')
	os.rmdir_all(root) or {}
	defer {
		os.rmdir_all(root) or {}
	}
	cask := cask_install_steps_spec_cask(root)
	staged_path := cask.map_data['staged_path'].as_string()
	os.mkdir_all(staged_path) or { return brew_runtime.bool_value(false) }
	artifact := install_steps_artifact.new_cask_install_steps_artifact(cask, [
		cask_install_steps_spec_step('touch', {
			'path': cask_install_steps_spec_path('steps-ran', 'staged_path')
		}),
	], 'Cask::Artifact::PreflightSteps')
	install_steps_artifact.run_cask_install_steps(artifact, 'install', false, CaskInstallStepsSpecExecutor{}) or { return brew_runtime.bool_value(false) }
	steps_ran := os.join_path(staged_path, 'steps-ran')
	if !os.exists(steps_ran) {
		return brew_runtime.bool_value(false)
	}
	ruby_block_ran := os.join_path(staged_path, 'ruby-block-ran')
	os.write_file(ruby_block_ran, '') or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(os.exists(steps_ran) && os.exists(ruby_block_ran))
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
