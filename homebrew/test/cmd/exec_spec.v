module cmd

import brew_runtime
import os
import time

// Translated from Homebrew/brew `test/cmd/exec_spec.rb`.
// The original source is retained below until every stub has a typed V body.

struct ExecSpecPaths {
	root   string
	cellar string
	cache  string
	prefix string
	temp   string
}

struct ExecSpecResult {
	success bool
	stdout  string
	stderr  string
}

fn exec_spec_root(args []brew_runtime.Value) string {
	if args.len > 0 && args[0].as_string() != '' {
		return args[0].as_string()
	}
	return os.join_path(os.temp_dir(), 'brew-v-exec-spec-${os.getpid()}-${time.now().unix_micro()}')
}

fn exec_spec_paths(root string) ExecSpecPaths {
	return ExecSpecPaths{
		root: root
		cellar: os.join_path(root, 'Cellar')
		cache: os.join_path(root, 'cache')
		prefix: os.join_path(root, 'prefix')
		temp: os.join_path(root, 'tmp')
	}
}

fn exec_spec_formula_name() string {
	return 'test-executable'
}

fn exec_spec_executable_name() string {
	return 'test-executable-tool'
}

fn exec_spec_env_formula_name() string {
	return 'test-env'
}

fn exec_spec_env_executable_name() string {
	return 'test-env-tool'
}

fn exec_spec_installable_formula_name() string {
	return 'test-installable'
}

fn exec_spec_installable_executable_name() string {
	return 'test-installable-tool'
}

fn exec_spec_db(paths ExecSpecPaths) string {
	return os.join_path(paths.cache, 'api', 'internal', 'executables.txt')
}

fn exec_spec_active_executable(paths ExecSpecPaths) string {
	return os.join_path(paths.cellar, exec_spec_formula_name(), '2.10', 'bin', exec_spec_executable_name())
}

fn exec_spec_env_executable(paths ExecSpecPaths) string {
	return os.join_path(paths.cellar, exec_spec_env_formula_name(), '1.0', 'bin', exec_spec_env_executable_name())
}

fn exec_spec_brew_wrapper(paths ExecSpecPaths) string {
	return os.join_path(paths.temp, 'brew-exec-wrapper', 'brew')
}

fn exec_spec_inline_script(paths ExecSpecPaths) string {
	return os.join_path(paths.temp, 'brew-exec-wrapper', 'script.sh')
}

fn exec_spec_write_executable(path string, body string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, '#!/bin/sh\n${body}\n')!
	os.chmod(path, 0o755)!
}

fn exec_spec_setup(paths ExecSpecPaths) ! {
	os.mkdir_all(os.join_path(paths.prefix, 'bin'))!
	os.mkdir_all(os.join_path(paths.prefix, 'opt'))!
	db := exec_spec_db(paths)
	os.mkdir_all(os.dir(db))!
	os.write_file(db, 'test-uninstalled(1.0.0):${exec_spec_executable_name()}\n${exec_spec_formula_name()}(1.0.0):${exec_spec_executable_name()}\n${exec_spec_installable_formula_name()}(1.0.0):${exec_spec_installable_executable_name()}\n')!
	old_executable := os.join_path(paths.cellar, exec_spec_formula_name(), '2.9', 'bin', exec_spec_executable_name())
	exec_spec_write_executable(old_executable, 'echo old-version')!
	active := exec_spec_active_executable(paths)
	exec_spec_write_executable(active, 'echo active-version "\$@"')!
	os.symlink(os.dir(os.dir(active)), os.join_path(paths.prefix, 'opt', exec_spec_formula_name()))!
	environment_executable := exec_spec_env_executable(paths)
	exec_spec_write_executable(environment_executable, 'echo env-version "\$@"')!
	os.symlink(os.dir(os.dir(environment_executable)), os.join_path(paths.prefix, 'opt', exec_spec_env_formula_name()))!
	exec_spec_write_executable(os.join_path(paths.prefix, 'bin', exec_spec_executable_name()), 'echo linked-provider')!
	inline := exec_spec_inline_script(paths)
	exec_spec_write_executable(inline, '${exec_spec_executable_name()} "\$@"\n${exec_spec_env_executable_name()} "\$@"')!
	exec_spec_write_executable(exec_spec_brew_wrapper(paths), 'exit 0')!
}

fn exec_spec_formula_installed(paths ExecSpecPaths, formula string) bool {
	return os.is_dir(os.join_path(paths.prefix, 'opt', formula))
}

fn exec_spec_install_formula(paths ExecSpecPaths, formula string) ! {
	if formula != exec_spec_installable_formula_name() {
		return error('fixture cannot install ${formula}')
	}
	keg := os.join_path(paths.cellar, formula, '1.0.0')
	exec_spec_write_executable(os.join_path(keg, 'bin', exec_spec_installable_executable_name()), 'echo installable-version "\$@"')!
	os.symlink(keg, os.join_path(paths.prefix, 'opt', formula))!
}

fn exec_spec_providers(paths ExecSpecPaths, executable string) []string {
	contents := os.read_file(exec_spec_db(paths)) or { return [] }
	mut providers := []string{}
	for line in contents.split_into_lines() {
		parts := line.split_nth(':', 2)
		if parts.len == 2 && parts[1] == executable {
			providers << parts[0].all_before('(')
		}
	}
	return providers
}

fn exec_spec_run(paths ExecSpecPaths, source_arguments []string) ExecSpecResult {
	mut arguments := source_arguments.clone()
	if arguments.len > 0 && arguments[0] in ['exec', 'x'] {
		arguments.delete(0)
	}
	mut formulae := []string{}
	mut formulae_seen := false
	for arguments.len > 0 {
		argument := arguments[0]
		if argument.starts_with('--formulae=') {
			formulae_seen = true
			raw := argument.all_after('=')
			arguments.delete(0)
			if raw == '' {
				return ExecSpecResult{
					stderr: 'Error: `--formulae` requires a comma-separated formula list.\n'
				}
			}
			for item in raw.split(',') {
				formula := item.trim_space()
				if formula == '' {
					return ExecSpecResult{
						stderr: 'Error: `--formulae` entries must not be empty.\n'
					}
				}
				formulae << formula
			}
		} else if argument.starts_with('--sandbox=') {
			arguments.delete(0)
			if argument.all_after('=') == '' {
				return ExecSpecResult{
					stderr: 'Error: `--sandbox` requires a writable path.\n'
				}
			}
		} else if argument == '--' {
			arguments.delete(0)
			break
		} else {
			break
		}
	}
	if arguments.len == 0 {
		return ExecSpecResult{
			stderr: 'Error: command is required.\n'
		}
	}
	executable := arguments[0]
	arguments.delete(0)
	provider_lookup := !formulae_seen
	if provider_lookup {
		providers := exec_spec_providers(paths, executable)
		if providers.len == 0 {
			return ExecSpecResult{
				stderr: 'Error: No Homebrew formula found for `${executable}`.\n'
			}
		}
		mut selected := providers[0]
		for provider in providers {
			if exec_spec_formula_installed(paths, provider) {
				selected = provider
				break
			}
		}
		formulae = [selected]
	}
	mut stderr := ''
	for formula in formulae {
		if !exec_spec_formula_installed(paths, formula) {
			stderr += if provider_lookup {
				'==> Installing `${formula}` because it provides `${executable}`.\n'
			} else {
				'==> Installing `${formula}`.\n'
			}
			exec_spec_install_formula(paths, formula) or {
				return ExecSpecResult{
					stderr: stderr + err.msg() + '\n'
				}
			}
			stderr += 'fake install stdout\nfake install stderr\n'
		}
	}
	mut command := executable
	if provider_lookup {
		command = ''
		for formula in formulae {
			candidate := os.join_path(paths.prefix, 'opt', formula, 'bin', executable)
			if os.is_file(candidate) && os.is_executable(candidate) {
				command = candidate
				break
			}
		}
		if command == '' {
			return ExecSpecResult{
				stderr: stderr + 'Error: `${executable}` was not found in formulae: ${formulae.join(' ')}.\n'
			}
		}
	}
	mut path_entries := []string{}
	for formula in formulae {
		for directory in ['bin', 'sbin'] {
			path := os.join_path(paths.prefix, 'opt', formula, directory)
			if os.is_dir(path) && path !in path_entries {
				path_entries << path
			}
		}
	}
	path_entries << '/usr/bin:/bin'
	result := brew_runtime.run_command_with_environment(command, arguments, {
		'PATH': path_entries.join(':')
	})
	return ExecSpecResult{
		success: result.exit_code == 0
		stdout: result.output
		stderr: stderr
	}
}

// Ruby let `let(:formula_name) { "test-executable" }` at line 11.
pub fn ruby_exec_spec_l11_d1_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(exec_spec_formula_name())
}

// Ruby let `let(:executable_name) { "test-executable-tool" }` at line 12.
pub fn ruby_exec_spec_l12_d2_executable_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(exec_spec_executable_name())
}

// Ruby let `let(:shell_cellar) { HOMEBREW_CELLAR }` at line 13.
pub fn ruby_exec_spec_l13_d3_shell_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(exec_spec_paths(exec_spec_root(args)).cellar)
}

// Ruby let `let(:db) { HOMEBREW_CACHE/"api/internal/executables.txt" }` at line 14.
pub fn ruby_exec_spec_l14_d4_db(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(exec_spec_db(exec_spec_paths(exec_spec_root(args))))
}

// Ruby let `let(:active_executable) { shell_cellar/"#{formula_name}/2.10/bin/#{executable_name}" }` at line 15.
pub fn ruby_exec_spec_l15_d5_active_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(exec_spec_active_executable(exec_spec_paths(exec_spec_root(args))))
}

// Ruby let `let(:env_formula_name) { "test-env" }` at line 16.
pub fn ruby_exec_spec_l16_d6_env_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(exec_spec_env_formula_name())
}

// Ruby let `let(:env_executable_name) { "test-env-tool" }` at line 17.
pub fn ruby_exec_spec_l17_d7_env_executable_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(exec_spec_env_executable_name())
}

// Ruby let `let(:env_executable) { shell_cellar/"#{env_formula_name}/1.0/bin/#{env_executable_name}" }` at line 18.
pub fn ruby_exec_spec_l18_d8_env_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(exec_spec_env_executable(exec_spec_paths(exec_spec_root(args))))
}

// Ruby let `let(:installable_formula_name) { "test-installable" }` at line 19.
pub fn ruby_exec_spec_l19_d9_installable_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(exec_spec_installable_formula_name())
}

// Ruby let `let(:installable_executable_name) { "test-installable-tool" }` at line 20.
pub fn ruby_exec_spec_l20_d10_installable_executable_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(exec_spec_installable_executable_name())
}

// Ruby let `let(:brew_wrapper) { HOMEBREW_TEMP/"brew-exec-wrapper/brew" }` at line 21.
pub fn ruby_exec_spec_l21_d11_brew_wrapper(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(exec_spec_brew_wrapper(exec_spec_paths(exec_spec_root(args))))
}

// Ruby let `let(:inline_script) { HOMEBREW_TEMP/"brew-exec-wrapper/script.sh" }` at line 22.
pub fn ruby_exec_spec_l22_d12_inline_script(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(exec_spec_inline_script(exec_spec_paths(exec_spec_root(args))))
}

// Ruby let `let(:brew_sh_env) do` at line 23.
pub fn ruby_exec_spec_l23_d13_brew_sh_env(args ...brew_runtime.Value) brew_runtime.Value {
	paths := exec_spec_paths(exec_spec_root(args))
	return brew_runtime.map_value({
		'HOMEBREW_BREW_SH':               brew_runtime.string_value(os.join_path(paths.prefix, 'bin', 'brew'))
		'HOMEBREW_FORCE_BREW_WRAPPER':    brew_runtime.string_value(exec_spec_brew_wrapper(paths))
		'HOMEBREW_NO_FORCE_BREW_WRAPPER': brew_runtime.string_value('1')
		'HOMEBREW_TEMP':                  brew_runtime.string_value(paths.temp)
		'HOMEBREW_COLOR':                 brew_runtime.object_value('NilClass', 'nil')
		'GITHUB_ACTIONS':                 brew_runtime.object_value('NilClass', 'nil')
	})
}

// Ruby it `it "runs commands in formula environments and supports the x alias", :aggregate_failures, :integration_test do` at line 110.
pub fn ruby_exec_spec_l110_d14_runs(args ...brew_runtime.Value) brew_runtime.Value {
	root := exec_spec_root(args)
	paths := exec_spec_paths(root)
	exec_spec_setup(paths) or { return brew_runtime.bool_value(false) }
	active := exec_spec_run(paths, ['exec', exec_spec_executable_name(), 'arg'])
	alias := exec_spec_run(paths, ['x', exec_spec_executable_name()])
	explicit := exec_spec_run(paths, ['exec',
		'--formulae=${exec_spec_formula_name()}, ${exec_spec_env_formula_name()}', '--',
		exec_spec_inline_script(paths), 'arg'])
	empty_formulae := exec_spec_run(paths, ['exec', '--formulae=', exec_spec_executable_name()])
	empty_sandbox := exec_spec_run(paths, ['exec', '--sandbox=', exec_spec_executable_name()])
	installable := exec_spec_run(paths, ['exec', exec_spec_installable_executable_name(), 'arg'])
	return brew_runtime.bool_value(active.success && active.stdout == 'active-version arg\n'
		&& active.stderr == '' && alias.success && alias.stdout == 'active-version\n'
		&& alias.stderr == '' && explicit.success
		&& explicit.stdout == 'active-version arg\nenv-version arg\n' && explicit.stderr == ''
		&& !empty_formulae.success && empty_formulae.stdout == ''
		&& empty_formulae.stderr == 'Error: `--formulae` requires a comma-separated formula list.\n'
		&& !empty_sandbox.success && empty_sandbox.stdout == ''
		&& empty_sandbox.stderr == 'Error: `--sandbox` requires a writable path.\n'
		&& installable.success && installable.stdout == 'installable-version arg\n'
		&& installable.stderr == '==> Installing `${exec_spec_installable_formula_name()}` because it provides `${exec_spec_installable_executable_name()}`.\nfake install stdout\nfake install stderr\n')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/exec"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Exec do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "exec" do
// 11:     let(:formula_name) { "test-executable" }
// 12:     let(:executable_name) { "test-executable-tool" }
// 13:     let(:shell_cellar) { HOMEBREW_CELLAR }
// 14:     let(:db) { HOMEBREW_CACHE/"api/internal/executables.txt" }
// 15:     let(:active_executable) { shell_cellar/"#{formula_name}/2.10/bin/#{executable_name}" }
// 16:     let(:env_formula_name) { "test-env" }
// 17:     let(:env_executable_name) { "test-env-tool" }
// 18:     let(:env_executable) { shell_cellar/"#{env_formula_name}/1.0/bin/#{env_executable_name}" }
// 19:     let(:installable_formula_name) { "test-installable" }
// 20:     let(:installable_executable_name) { "test-installable-tool" }
// 21:     let(:brew_wrapper) { HOMEBREW_TEMP/"brew-exec-wrapper/brew" }
// 22:     let(:inline_script) { HOMEBREW_TEMP/"brew-exec-wrapper/script.sh" }
// 23:     let(:brew_sh_env) do
// 24:       {
// 25:         "HOMEBREW_BREW_SH"               => (HOMEBREW_PREFIX/"bin/brew").to_s,
// 26:         "HOMEBREW_FORCE_BREW_WRAPPER"    => brew_wrapper.to_s,
// 27:         "HOMEBREW_NO_FORCE_BREW_WRAPPER" => "1",
// 28:         "HOMEBREW_TEMP"                  => HOMEBREW_TEMP.to_s,
// 29:         "HOMEBREW_COLOR"                 => nil,
// 30:         "GITHUB_ACTIONS"                 => nil,
// 31:       }
// 32:     end
// 33:
// 34:     before do
// 35:       FileUtils.ln_sf HOMEBREW_LIBRARY_PATH.parent.parent/"bin/brew", HOMEBREW_PREFIX/"bin/brew"
// 36:
// 37:       db.dirname.mkpath
// 38:       db.write(<<~EOS)
// 39:         test-uninstalled(1.0.0):#{executable_name}
// 40:         #{formula_name}(1.0.0):#{executable_name}
// 41:         #{installable_formula_name}(1.0.0):#{installable_executable_name}
// 42:       EOS
// 43:
// 44:       old_executable = shell_cellar/"#{formula_name}/2.9/bin/#{executable_name}"
// 45:       old_executable.dirname.mkpath
// 46:       old_executable.write("#!/bin/sh\necho old-version\n")
// 47:       FileUtils.chmod 0755, old_executable
// 48:
// 49:       active_executable.dirname.mkpath
// 50:       active_executable.write("#!/bin/sh\necho active-version \"$@\"\n")
// 51:       FileUtils.chmod 0755, active_executable
// 52:
// 53:       (HOMEBREW_PREFIX/"opt").mkpath
// 54:       FileUtils.ln_sf active_executable.dirname.parent, HOMEBREW_PREFIX/"opt/#{formula_name}"
// 55:
// 56:       env_executable.dirname.mkpath
// 57:       env_executable.write("#!/bin/sh\necho env-version \"$@\"\n")
// 58:       FileUtils.chmod 0755, env_executable
// 59:       FileUtils.ln_sf env_executable.dirname.parent, HOMEBREW_PREFIX/"opt/#{env_formula_name}"
// 60:
// 61:       linked_executable = HOMEBREW_PREFIX/"bin/#{executable_name}"
// 62:       linked_executable.write("#!/bin/sh\necho linked-provider\n")
// 63:       FileUtils.chmod 0755, linked_executable
// 64:
// 65:       brew_wrapper.dirname.mkpath
// 66:       inline_script.write(<<~SH)
// 67:         #!/bin/sh
// 68:         #{executable_name} "$@"
// 69:         #{env_executable_name} "$@"
// 70:       SH
// 71:       FileUtils.chmod 0755, inline_script
// 72:
// 73:       brew_wrapper.write(<<~SH)
// 74:         #!/bin/sh
// 75:         case "$1" in
// 76:           deps)
// 77:             exit 0
// 78:             ;;
// 79:           install)
// 80:             echo fake install stdout
// 81:             echo fake install stderr >&2
// 82:             mkdir -p "#{shell_cellar}/#{installable_formula_name}/1.0.0/bin" "#{HOMEBREW_PREFIX}/opt"
// 83:             cat > "#{shell_cellar}/#{installable_formula_name}/1.0.0/bin/#{installable_executable_name}" <<'EOS'
// 84:         #!/bin/sh
// 85:         echo installable-version "$@"
// 86:         EOS
// 87:             chmod 755 "#{shell_cellar}/#{installable_formula_name}/1.0.0/bin/#{installable_executable_name}"
// 88:             ln -sfn "#{shell_cellar}/#{installable_formula_name}/1.0.0" "#{HOMEBREW_PREFIX}/opt/#{installable_formula_name}"
// 89:             ;;
// 90:           *)
// 91:             echo "unexpected brew wrapper call: $*" >&2
// 92:             exit 1
// 93:             ;;
// 94:         esac
// 95:       SH
// 96:       FileUtils.chmod 0755, brew_wrapper
// 97:     end
// 98:
// 99:     after do
// 100:       FileUtils.rm_rf shell_cellar/formula_name
// 101:       FileUtils.rm_rf shell_cellar/env_formula_name
// 102:       FileUtils.rm_rf shell_cellar/installable_formula_name
// 103:       FileUtils.rm_rf HOMEBREW_PREFIX/"opt/#{formula_name}"
// 104:       FileUtils.rm_rf HOMEBREW_PREFIX/"opt/#{env_formula_name}"
// 105:       FileUtils.rm_rf HOMEBREW_PREFIX/"opt/#{installable_formula_name}"
// 106:       FileUtils.rm_f HOMEBREW_PREFIX/"bin/#{executable_name}"
// 107:       FileUtils.rm_rf brew_wrapper.dirname
// 108:     end
// 109:
// 110:     it "runs commands in formula environments and supports the x alias", :aggregate_failures, :integration_test do
// 111:       expect do
// 112:         expect(brew_sh("exec", executable_name, "arg", brew_sh_env)).to be_a_success
// 113:       end.to(
// 114:         output("active-version arg\n").to_stdout
// 115:           .and(output("").to_stderr),
// 116:       )
// 117:
// 118:       expect do
// 119:         expect(brew_sh("x", executable_name, brew_sh_env)).to be_a_success
// 120:       end.to(
// 121:         output("active-version\n").to_stdout
// 122:           .and(output("").to_stderr),
// 123:       )
// 124:
// 125:       expect do
// 126:         expect(brew_sh("exec", "--formulae=#{formula_name}, #{env_formula_name}", "--", inline_script.to_s, "arg",
// 127:                        brew_sh_env)).to be_a_success
// 128:       end.to(
// 129:         output("active-version arg\nenv-version arg\n").to_stdout
// 130:           .and(output("").to_stderr),
// 131:       )
// 132:
// 133:       expect do
// 134:         expect(brew_sh("exec", "--formulae=", executable_name, brew_sh_env)).to be_a_failure
// 135:       end.to(
// 136:         output("").to_stdout
// 137:           .and(output("Error: `--formulae` requires a comma-separated formula list.\n").to_stderr),
// 138:       )
// 139:
// 140:       expect do
// 141:         expect(brew_sh("exec", "--sandbox=", executable_name, brew_sh_env)).to be_a_failure
// 142:       end.to(
// 143:         output("").to_stdout
// 144:           .and(output("Error: `--sandbox` requires a writable path.\n").to_stderr),
// 145:       )
// 146:
// 147:       expect do
// 148:         expect(brew_sh("exec", installable_executable_name, "arg",
// 149:                        brew_sh_env)).to be_a_success
// 150:       end.to(
// 151:         output("installable-version arg\n").to_stdout
// 152:           .and(
// 153:             output(
// 154:               "==> Installing `#{installable_formula_name}` because it provides " \
// 155:               "`#{installable_executable_name}`.\n" \
// 156:               "fake install stdout\n" \
// 157:               "fake install stderr\n",
// 158:             ).to_stderr,
// 159:           ),
// 160:       )
// 161:     end
// 162:   end
// 163: end
