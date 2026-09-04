module extend

import ruby
import homebrew.extend as kernel_ext
import os
import time

// Translated from Homebrew/brew `test/extend/kernel_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn kernel_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-kernel-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn kernel_spec_result(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn kernel_spec_quiet_delegate(plan kernel_ext.KernelCommandPlan) !bool {
	return plan.program == 'true' && plan.quiet
}

fn kernel_spec_safe_delegate(plan kernel_ext.KernelCommandPlan) !bool {
	return plan.program == 'true' && !plan.quiet
}

fn kernel_spec_failure_action() !ruby.Value {
	return error('boom')
}

// Ruby let `let(:dir) { mktmpdir }` at line 5.
pub fn ruby_kernel_spec_l5_d1_dir(args ...ruby.Value) ruby.Value {
	root := kernel_spec_root('dir')
	os.mkdir_all(root) or { panic(err) }
	return ruby.object_value('Pathname', root)
}

// Ruby let `let(:shell) { dir/"myshell" }` at line 8.
pub fn ruby_kernel_spec_l8_d2_shell(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby_kernel_spec_l5_d1_dir().as_string()
	}
	return ruby.object_value('Pathname', os.join_path(root, 'myshell'))
}

// Ruby it `it "starts an interactive shell session" do` at line 10.
pub fn ruby_kernel_spec_l10_d3_starts(args ...ruby.Value) ruby.Value {
	root := kernel_spec_root('shell')
	os.mkdir_all(root) or { return kernel_spec_result(false) }
	defer { os.rmdir_all(root) or {} }
	shell := os.join_path(root, 'myshell')
	called := os.join_path(root, 'called')
	os.write_file(shell, '#!/bin/sh\necho called > "${called}"\n') or {
		return kernel_spec_result(false)
	}
	os.chmod(shell, 0o755) or { return kernel_spec_result(false) }
	result := kernel_ext.with_environment({
		'SHELL': kernel_ext.EnvironmentValue{
			value: shell
		}
	}, fn [shell] () !ruby.Value {
		kernel_ext.run_interactive_shell('', '', shell, fn (plan kernel_ext.KernelCommandPlan) !bool {
			return ruby.run_command(plan.program, plan.arguments).exit_code == 0
		})!
		return ruby.bool_value(true)
	}) or { return kernel_spec_result(false) }
	return kernel_spec_result(result.as_bool() or { false } && os.exists(called))
}

// Ruby let `let(:cmd) { dir/"foo" }` at line 26.
pub fn ruby_kernel_spec_l26_d4_cmd(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby_kernel_spec_l5_d1_dir().as_string()
	}
	command := os.join_path(root, 'foo')
	os.write_file(command, '') or { panic(err) }
	return ruby.object_value('Pathname', command)
}

// Ruby it `it "returns the first executable that is found" do` at line 30.
pub fn ruby_kernel_spec_l30_d5_returns(args ...ruby.Value) ruby.Value {
	root := kernel_spec_root('which-executable')
	os.mkdir_all(root) or { return kernel_spec_result(false) }
	defer { os.rmdir_all(root) or {} }
	command := os.join_path(root, 'foo')
	os.write_file(command, '') or { return kernel_spec_result(false) }
	os.chmod(command, 0o744) or { return kernel_spec_result(false) }
	return kernel_spec_result((kernel_ext.which('foo', root) or { '' }) == command)
}

// Ruby it `it "skips non-executables" do` at line 35.
pub fn ruby_kernel_spec_l35_d6_skips(args ...ruby.Value) ruby.Value {
	root := kernel_spec_root('which-non-executable')
	os.mkdir_all(root) or { return kernel_spec_result(false) }
	defer { os.rmdir_all(root) or {} }
	os.write_file(os.join_path(root, 'foo'), '') or { return kernel_spec_result(false) }
	return kernel_spec_result(kernel_ext.which('foo', root) == none)
}

// Ruby it `it "skips malformed path and doesn't fail" do` at line 39.
pub fn ruby_kernel_spec_l39_d7_skips(args ...ruby.Value) ruby.Value {
	root := kernel_spec_root('which-malformed')
	os.mkdir_all(root) or { return kernel_spec_result(false) }
	defer { os.rmdir_all(root) or {} }
	command := os.join_path(root, 'foo')
	os.write_file(command, '') or { return kernel_spec_result(false) }
	os.chmod(command, 0o744) or { return kernel_spec_result(false) }
	return kernel_spec_result((kernel_ext.which('foo', '~~:${root}') or { '' }) == command)
}

// Ruby specify `specify "#which_editor" do` at line 50.
pub fn ruby_kernel_spec_l50_d8_which_editor(args ...ruby.Value) ruby.Value {
	root := kernel_spec_root('editor')
	os.mkdir_all(root) or { return kernel_spec_result(false) }
	defer { os.rmdir_all(root) or {} }
	editor := os.join_path(root, 'vemate')
	os.write_file(editor, '') or { return kernel_spec_result(false) }
	os.chmod(editor, 0o755) or { return kernel_spec_result(false) }
	result := kernel_ext.with_environment({
		'HOMEBREW_EDITOR': kernel_ext.EnvironmentValue{
			value: 'vemate -w'
		}
		'HOMEBREW_PATH':   kernel_ext.EnvironmentValue{
			value: root
		}
	}, fn () !ruby.Value {
		return ruby.bool_value(kernel_ext.which_editor(false).command == 'vemate -w')
	}) or { return kernel_spec_result(false) }
	return result
}

// Ruby it `it "sets environment variables within the block" do` at line 62.
pub fn ruby_kernel_spec_l62_d9_sets(args ...ruby.Value) ruby.Value {
	if os.getenv('PATH') == '/bin' {
		return kernel_spec_result(false)
	}
	result := kernel_ext.with_environment({
		'PATH': kernel_ext.EnvironmentValue{
			value: '/bin'
		}
	}, fn () !ruby.Value {
		return ruby.bool_value(os.getenv('PATH') == '/bin')
	}) or { return kernel_spec_result(false) }
	return result
}

// Ruby it `it "restores ENV after the block" do` at line 69.
pub fn ruby_kernel_spec_l69_d10_restores(args ...ruby.Value) ruby.Value {
	before := os.getenv('PATH')
	if before == '' || before == '/bin' {
		return kernel_spec_result(false)
	}
	kernel_ext.with_environment({
		'PATH': kernel_ext.EnvironmentValue{
			value: '/bin'
		}
	}, fn () !ruby.Value {
		return ruby.bool_value(os.getenv('PATH') == '/bin')
	}) or { return kernel_spec_result(false) }
	return kernel_spec_result(os.getenv('PATH') == before)
}

// Ruby it `it "restores ENV if an exception is raised" do` at line 78.
pub fn ruby_kernel_spec_l78_d11_restores(args ...ruby.Value) ruby.Value {
	before := os.getenv('PATH')
	if before == '' || before == '/bin' {
		return kernel_spec_result(false)
	}
	_ := kernel_ext.with_environment({
		'PATH': kernel_ext.EnvironmentValue{
			value: '/bin'
		}
	}, kernel_spec_failure_action) or {
		return kernel_spec_result(err.msg() == 'boom' && os.getenv('PATH') == before)
	}
	return kernel_spec_result(false)
}

// Ruby it `it "delegates to Homebrew.quiet_system" do` at line 92.
pub fn ruby_kernel_spec_l92_d12_delegates(args ...ruby.Value) ruby.Value {
	result := kernel_ext.quiet_system(kernel_ext.KernelCommandPlan{
		program: 'true'
	}, kernel_spec_quiet_delegate) or { false }
	return kernel_spec_result(result)
}

// Ruby it `it "delegates to Homebrew.safe_system" do` at line 99.
pub fn ruby_kernel_spec_l99_d13_delegates(args ...ruby.Value) ruby.Value {
	kernel_ext.safe_system(kernel_ext.KernelCommandPlan{
		program: 'true'
	}, kernel_spec_safe_delegate) or { return kernel_spec_result(false) }
	return kernel_spec_result(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Kernel do
// 5:   let(:dir) { mktmpdir }
// 6:
// 7:   describe "#interactive_shell" do
// 8:     let(:shell) { dir/"myshell" }
// 9:
// 10:     it "starts an interactive shell session" do
// 11:       File.write shell, <<~SH
// 12:         #!/bin/sh
// 13:         echo called > "#{dir}/called"
// 14:       SH
// 15:
// 16:       FileUtils.chmod 0755, shell
// 17:
// 18:       ENV["SHELL"] = shell
// 19:
// 20:       expect { interactive_shell }.not_to raise_error
// 21:       expect(dir/"called").to exist
// 22:     end
// 23:   end
// 24:
// 25:   describe "#which" do
// 26:     let(:cmd) { dir/"foo" }
// 27:
// 28:     before { FileUtils.touch cmd }
// 29:
// 30:     it "returns the first executable that is found" do
// 31:       cmd.chmod 0744
// 32:       expect(which(File.basename(cmd), File.dirname(cmd))).to eq(cmd)
// 33:     end
// 34:
// 35:     it "skips non-executables" do
// 36:       expect(which(File.basename(cmd), File.dirname(cmd))).to be_nil
// 37:     end
// 38:
// 39:     it "skips malformed path and doesn't fail" do
// 40:       # 'which' should not fail if a path is malformed
// 41:       # see https://github.com/Homebrew/legacy-homebrew/issues/32789 for an example
// 42:       cmd.chmod 0744
// 43:
// 44:       # ~~ will fail because ~foo resolves to foo's home and there is no '~' user
// 45:       path = ["~~", File.dirname(cmd)].join(File::PATH_SEPARATOR)
// 46:       expect(which(File.basename(cmd), path)).to eq(cmd)
// 47:     end
// 48:   end
// 49:
// 50:   specify "#which_editor" do
// 51:     ENV["HOMEBREW_EDITOR"] = "vemate -w"
// 52:     ENV["HOMEBREW_PATH"] = dir
// 53:
// 54:     editor = "#{dir}/vemate"
// 55:     FileUtils.touch editor
// 56:     FileUtils.chmod 0755, editor
// 57:
// 58:     expect(which_editor).to eq("vemate -w")
// 59:   end
// 60:
// 61:   describe "#with_env" do
// 62:     it "sets environment variables within the block" do
// 63:       expect(ENV.fetch("PATH")).not_to eq("/bin")
// 64:       with_env(PATH: "/bin") do
// 65:         expect(ENV.fetch("PATH", nil)).to eq("/bin")
// 66:       end
// 67:     end
// 68:
// 69:     it "restores ENV after the block" do
// 70:       with_env(PATH: "/bin") do
// 71:         expect(ENV.fetch("PATH", nil)).to eq("/bin")
// 72:       end
// 73:       path = ENV.fetch("PATH", nil)
// 74:       expect(path).not_to be_nil
// 75:       expect(path).not_to eq("/bin")
// 76:     end
// 77:
// 78:     it "restores ENV if an exception is raised" do
// 79:       expect do
// 80:         with_env(PATH: "/bin") do
// 81:           raise StandardError, "boom"
// 82:         end
// 83:       end.to raise_error(StandardError)
// 84:
// 85:       path = ENV.fetch("PATH", nil)
// 86:       expect(path).not_to be_nil
// 87:       expect(path).not_to eq("/bin")
// 88:     end
// 89:   end
// 90:
// 91:   describe "#quiet_system" do
// 92:     it "delegates to Homebrew.quiet_system" do
// 93:       expect(Homebrew).to receive(:quiet_system).with("true", nil).and_return(true)
// 94:       expect(quiet_system("true")).to be true
// 95:     end
// 96:   end
// 97:
// 98:   describe "#safe_system" do
// 99:     it "delegates to Homebrew.safe_system" do
// 100:       expect(Homebrew).to receive(:safe_system).with("true", nil)
// 101:       safe_system("true")
// 102:     end
// 103:   end
// 104: end
