module cmd

import ruby
import os
import time

// Translated from Homebrew/brew `test/cmd/as-console-user_spec.rb`.
// The original source is retained below for source-by-source auditability.

struct AsConsoleUserSpecFixture {
	root                   string
	library                string
	as_console_user_script string
	macos_user_script      string
}

struct AsConsoleUserShellResult {
pub:
	stdout    string
	stderr    string
	exit_code int
}

fn as_console_user_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-as-console-user-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn as_console_user_spec_as_console_user_source() string {
	return [
		r'source "${HOMEBREW_LIBRARY}/Homebrew/utils/cmd.sh"',
		r'homebrew-as-console-user() {',
		r'  while [[ "$#" -gt 0 ]]',
		r'  do',
		r'    if homebrew-command-help as-console-user "$1"',
		r'    then',
		r'      return $?',
		r'    fi',
		r'    if homebrew-command-common-option "$1"',
		r'    then',
		r'      shift',
		r'      continue',
		r'    fi',
		r'    break',
		r'  done',
		r'  homebrew-command-enable-debug',
		r'  if [[ "$#" -eq 0 ]]',
		r'  then',
		r'    brew help as-console-user',
		r'    return 1',
		r'  fi',
		r'  [[ -n "${HOMEBREW_MACOS}" ]] || odie "\`brew as-console-user\` is only supported on macOS."',
		r'  source "${HOMEBREW_LIBRARY}/Homebrew/utils/macos_user.sh"',
		r'  local console_user',
		r'  console_user="$(homebrew-console-user)" || odie "No supported macOS console user is logged in."',
		r'  local console_home',
		r'  console_home="$(homebrew-user-home "${console_user}")" || odie "Could not determine home directory for console user: ${console_user}"',
		r'  (',
		r'    cd "${console_home}" &>/dev/null || odie "Failed to cd to ${console_home}!"',
		r'    sudo -H -u "${console_user}" /usr/bin/env -i \',
		r'      "HOME=${console_home}" \',
		r'      "USER=${console_user}" \',
		r'      "LOGNAME=${console_user}" \',
		r'      "PWD=${console_home}" \',
		r'      "PATH=/usr/bin:/bin:/usr/sbin:/sbin" \',
		r'      "${HOMEBREW_BREW_FILE}" "$@"',
		r'  )',
		r'}',
	].join('\n') + '\n'
}

fn as_console_user_spec_macos_user_source() string {
	return [
		r'homebrew-console-user() {',
		r'  local console_user',
		r'  console_user="$(stat -f "%Su" /dev/console 2>/dev/null)" || return 1',
		r'  case "${console_user}" in',
		r'    "" | root | loginwindow | _mbsetupuser)',
		r'      return 1',
		r'      ;;',
		r'    *) ;;',
		r'  esac',
		r'  echo "${console_user}"',
		r'}',
		r'homebrew-user-home() {',
		r'  local user_record',
		r'  user_record="$(id -P "$1" 2>/dev/null)" || return 1',
		r'  user_record="${user_record%:*}"',
		r'  user_record="${user_record##*:}"',
		r'  [[ -n "${user_record}" ]] || return 1',
		r'  echo "${user_record}"',
		r'}',
		r'homebrew-package-user() {',
		r'  local homebrew_pkg_user_plist="${HOMEBREW_PKG_USER_PLIST:-/var/tmp/.homebrew_pkg_user.plist}"',
		r'  if [[ ! -L "${homebrew_pkg_user_plist}" && -f "${homebrew_pkg_user_plist}" ]] &&',
		r'     [[ "$(stat -f "%Su %Lp" "${homebrew_pkg_user_plist}" 2>/dev/null)" == "root 600" ]] &&',
		r'     [[ "$(ls -led "${homebrew_pkg_user_plist}" 2>/dev/null | wc -l)" -eq 1 ]]',
		r'  then',
		r'    local homebrew_pkg_user',
		r'    if homebrew_pkg_user="$(defaults read "${homebrew_pkg_user_plist}" HOMEBREW_PKG_USER 2>/dev/null)" &&',
		r'       [[ -n "${homebrew_pkg_user}" ]]',
		r'    then',
		r'      echo "${homebrew_pkg_user}"',
		r'      return',
		r'    fi',
		r'  fi',
		r'  homebrew-console-user',
		r'}',
	].join('\n') + '\n'
}

fn as_console_user_spec_new_fixture(label string) !AsConsoleUserSpecFixture {
	root := as_console_user_spec_root(label)
	library := os.join_path(root, 'Library')
	homebrew := os.join_path(library, 'Homebrew')
	cmd_dir := os.join_path(homebrew, 'cmd')
	utils_dir := os.join_path(homebrew, 'utils')
	os.mkdir_all(cmd_dir)!
	os.mkdir_all(utils_dir)!
	as_console_user_script := os.join_path(cmd_dir, 'as-console-user.sh')
	macos_user_script := os.join_path(utils_dir, 'macos_user.sh')
	os.write_file(as_console_user_script, as_console_user_spec_as_console_user_source())!
	os.write_file(macos_user_script, as_console_user_spec_macos_user_source())!
	os.write_file(os.join_path(utils_dir, 'cmd.sh'), [
		r'homebrew-command-help() { return 1; }',
		r'homebrew-command-common-option() { return 1; }',
		r'homebrew-command-enable-debug() { :; }',
	].join('\n') + '\n')!
	return AsConsoleUserSpecFixture{
		root: root
		library: library
		as_console_user_script: as_console_user_script
		macos_user_script: macos_user_script
	}
}

pub fn as_console_user_spec_run_shell(script string, environment map[string]string) !AsConsoleUserShellResult {
	root := as_console_user_spec_root('shell')
	os.mkdir_all(root)!
	defer { os.rmdir_all(root) or {} }
	script_path := os.join_path(root, 'input.sh')
	stdout_path := os.join_path(root, 'stdout')
	stderr_path := os.join_path(root, 'stderr')
	os.write_file(script_path, script)!
	mut command := ['/usr/bin/env', '-i', 'PATH=/usr/bin:/bin']
	mut keys := environment.keys()
	keys.sort()
	for key in keys {
		command << '${key}=${environment[key]}'
	}
	command << '/bin/bash'
	command << script_path
	result := os.execute(command.map(os.quoted_path(it)).join(' ') + ' > ' + os.quoted_path(stdout_path) + ' 2> ' + os.quoted_path(stderr_path))
	return AsConsoleUserShellResult{
		stdout: os.read_file(stdout_path) or { '' }
		stderr: os.read_file(stderr_path) or { '' }
		exit_code: result.exit_code
	}
}

fn as_console_user_spec_macos_env(fixture AsConsoleUserSpecFixture) map[string]string {
	return {
		'HOMEBREW_BREW_FILE': 'brew'
		'HOMEBREW_LIBRARY':   fixture.library
		'HOMEBREW_MACOS':     '1'
	}
}

fn as_console_user_spec_result_value(result AsConsoleUserShellResult) ruby.Value {
	return ruby.map_value({
		'stdout':     ruby.string_value(result.stdout)
		'stderr':     ruby.string_value(result.stderr)
		'exitstatus': ruby.int_value(i64(result.exit_code))
		'success':    ruby.bool_value(result.exit_code == 0)
	})
}

fn as_console_user_spec_package_case(label string, defaults_user string, stat_function string,
	ls_function string, symlink bool) !AsConsoleUserShellResult {
	fixture := as_console_user_spec_new_fixture(label)!
	defer { os.rmdir_all(fixture.root) or {} }
	plist := os.join_path(fixture.root, '.homebrew_pkg_user.plist')
	if symlink {
		target := os.join_path(fixture.root, 'target.plist')
		os.write_file(target, 'plist')!
		os.symlink(target, plist)!
	} else {
		os.write_file(plist, 'plist')!
	}
	script := [
		'source ' + os.quoted_path(fixture.macos_user_script),
		'defaults() { printf "${defaults_user}\\n"; }',
		stat_function,
		ls_function,
		r'homebrew-package-user',
	].join('\n') + '\n'
	return as_console_user_spec_run_shell(script, {
		'HOMEBREW_PKG_USER_PLIST': plist
	})
}

fn as_console_user_spec_bool(result AsConsoleUserShellResult, expected_stdout string,
	expected_stderr string, expected_exit int) ruby.Value {
	return ruby.bool_value(result.stdout == expected_stdout && result.stderr == expected_stderr
		&& result.exit_code == expected_exit)
}

// Ruby let `let(:as_console_user_script) { HOMEBREW_LIBRARY_PATH/"cmd/as-console-user.sh" }` at line 10.
pub fn ruby_as_console_user_spec_l10_d1_as_console_user_script(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { os.getwd() }
	return ruby.object_value('Pathname', os.join_path(root, 'Library', 'Homebrew', 'cmd', 'as-console-user.sh'))
}

// Ruby let `let(:repository_root) { HOMEBREW_LIBRARY_PATH.parent.parent }` at line 11.
pub fn ruby_as_console_user_spec_l11_d2_repository_root(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { os.getwd() }
	return ruby.object_value('Pathname', root)
}

// Ruby let `let(:test_root) { mktmpdir }` at line 12.
pub fn ruby_as_console_user_spec_l12_d3_test_root(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { as_console_user_spec_root('test-root') }
	os.mkdir_all(root) or {
		return ruby.object_value('SystemCallError', err.msg())
	}
	return ruby.object_value('Pathname', root)
}

// Ruby let `let(:macos_user_script) { repository_root/"Library/Homebrew/utils/macos_user.sh" }` at line 13.
pub fn ruby_as_console_user_spec_l13_d4_macos_user_script(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { os.getwd() }
	return ruby.object_value('Pathname', os.join_path(root, 'Library', 'Homebrew', 'utils', 'macos_user.sh'))
}

// Ruby let `let(:macos_env) do` at line 15.
pub fn ruby_as_console_user_spec_l15_d5_macos_env(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { os.getwd() }
	return ruby.map_value({
		'HOMEBREW_BREW_FILE': ruby.string_value('brew')
		'HOMEBREW_LIBRARY':   ruby.string_value(os.join_path(root, 'Library'))
		'HOMEBREW_MACOS':     ruby.string_value('1')
	})
}

// Ruby method `run_as_console_user_shell(script, env = {})` at line 25.
pub fn ruby_as_console_user_spec_l25_d6_run_as_console_user_shell(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'script is required')
	}
	mut environment := map[string]string{}
	if args.len > 1 {
		values := args[1].as_map() or {
			return ruby.object_value('ArgumentError', 'environment must be a Hash')
		}
		for key, value in values {
			environment[key] = value.as_string()
		}
	}
	result := as_console_user_spec_run_shell(args[0].as_string(), environment) or {
		return ruby.object_value('SystemCallError', err.msg())
	}
	return as_console_user_spec_result_value(result)
}

// Ruby it `it "prints help and fails when no command is provided" do` at line 31.
pub fn ruby_as_console_user_spec_l31_d7_prints(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := as_console_user_spec_new_fixture('help') or {
		return ruby.bool_value(false)
	}
	defer { os.rmdir_all(fixture.root) or {} }
	result := as_console_user_spec_run_shell([
		'source ' + os.quoted_path(fixture.as_console_user_script),
		r'brew() { printf "%s\n" "$*" >&2; }',
		r'homebrew-as-console-user',
	].join('\n') + '\n', {
		'HOMEBREW_BREW_FILE': 'brew'
		'HOMEBREW_LIBRARY':   fixture.library
	}) or { return ruby.bool_value(false) }
	return as_console_user_spec_bool(result, '', 'help as-console-user\n', 1)
}

// Ruby it `it "rejects a root console user" do` at line 47.
pub fn ruby_as_console_user_spec_l47_d8_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	return as_console_user_spec_console_rejection('root')
}

// Ruby it `it "rejects a loginwindow console user" do` at line 63.
pub fn ruby_as_console_user_spec_l63_d9_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	return as_console_user_spec_console_rejection('loginwindow')
}

// Ruby it `it "rejects non-macOS systems" do` at line 79.
pub fn ruby_as_console_user_spec_l79_d10_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := as_console_user_spec_new_fixture('non-macos') or {
		return ruby.bool_value(false)
	}
	defer { os.rmdir_all(fixture.root) or {} }
	result := as_console_user_spec_run_shell([
		'source ' + os.quoted_path(fixture.as_console_user_script),
		r'odie() { echo "Error: $*" >&2; exit 1; }',
		r'homebrew-as-console-user install wget',
	].join('\n') + '\n', {
		'HOMEBREW_BREW_FILE': 'brew'
		'HOMEBREW_LIBRARY':   fixture.library
	}) or { return ruby.bool_value(false) }
	return as_console_user_spec_bool(result, '', 'Error: `brew as-console-user` is only supported on macOS.\n', 1)
}

// Ruby it `it "uses the package user plist before the console user" do` at line 95.
pub fn ruby_as_console_user_spec_l95_d11_uses(args ...ruby.Value) ruby.Value {
	_ = args
	result := as_console_user_spec_package_case('package-first', 'munki', r'stat() { printf "root 600\n"; }', r'ls() { printf -- "-rw------- 1 root wheel 0 x\n"; }', false) or { return ruby.bool_value(false) }
	return as_console_user_spec_bool(result, 'munki\n', '', 0)
}

// Ruby it `it "honours a root-owned plist that carries extended attributes" do` at line 115.
pub fn ruby_as_console_user_spec_l115_d12_honours(args ...ruby.Value) ruby.Value {
	_ = args
	result := as_console_user_spec_package_case('extended-attributes', 'munki', r'stat() { printf "root 600\n"; }', r'ls() { printf -- "-rw-------@ 1 root wheel 0 x\n"; }', false) or {
		return ruby.bool_value(false)
	}
	return as_console_user_spec_bool(result, 'munki\n', '', 0)
}

// Ruby it `it "ignores a package user plist not owned by root" do` at line 135.
pub fn ruby_as_console_user_spec_l135_d13_ignores(args ...ruby.Value) ruby.Value {
	_ = args
	result := as_console_user_spec_package_case('wrong-owner', 'attacker', r'stat() { case "$*" in *"/dev/console") printf "root\n";; *) printf "attacker 600\n";; esac; }', r'ls() { printf -- "-rw------- 1 attacker staff 0 x\n"; }', false) or {
		return ruby.bool_value(false)
	}
	return as_console_user_spec_bool(result, '', '', 1)
}

// Ruby it `it "ignores a package user plist with loose permissions" do` at line 155.
pub fn ruby_as_console_user_spec_l155_d14_ignores(args ...ruby.Value) ruby.Value {
	_ = args
	result := as_console_user_spec_package_case('loose-mode', 'attacker', r'stat() { case "$*" in *"/dev/console") printf "root\n";; *) printf "root 644\n";; esac; }', r'ls() { printf -- "-rw-rw-rw- 1 root wheel 0 x\n"; }', false) or {
		return ruby.bool_value(false)
	}
	return as_console_user_spec_bool(result, '', '', 1)
}

// Ruby it `it "ignores a package user plist carrying an ACL" do` at line 175.
pub fn ruby_as_console_user_spec_l175_d15_ignores(args ...ruby.Value) ruby.Value {
	_ = args
	result := as_console_user_spec_package_case('acl', 'attacker', r'stat() { case "$*" in *"/dev/console") printf "root\n";; *) printf "root 600\n";; esac; }', r'ls() { printf -- "-rw-------@ 1 root wheel 0 x\n 0: group:everyone deny delete\n"; }', false) or { return ruby.bool_value(false) }
	return as_console_user_spec_bool(result, '', '', 1)
}

// Ruby it `it "ignores a package user plist that is a symlink" do` at line 195.
pub fn ruby_as_console_user_spec_l195_d16_ignores(args ...ruby.Value) ruby.Value {
	_ = args
	result := as_console_user_spec_package_case('symlink', 'attacker', r'stat() { case "$*" in *"/dev/console") printf "root\n";; *) printf "root\n";; esac; }', r'ls() { printf -- "-rw------- 1 root wheel 0 x\n"; }', true) or {
		return ruby.bool_value(false)
	}
	return as_console_user_spec_bool(result, '', '', 1)
}

// Ruby it `it "falls back to the console user without a package user plist" do` at line 217.
pub fn ruby_as_console_user_spec_l217_d17_falls(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := as_console_user_spec_new_fixture('fallback') or {
		return ruby.bool_value(false)
	}
	defer { os.rmdir_all(fixture.root) or {} }
	result := as_console_user_spec_run_shell([
		'source ' + os.quoted_path(fixture.macos_user_script),
		r'stat() { printf "mike\n"; }',
		r'homebrew-package-user',
	].join('\n') + '\n', {
		'HOMEBREW_PKG_USER_PLIST': os.join_path(fixture.root, 'missing.plist')
	}) or { return ruby.bool_value(false) }
	return as_console_user_spec_bool(result, 'mike\n', '', 0)
}

// Ruby it `it "rejects package user lookup without a package user or console user" do` at line 229.
pub fn ruby_as_console_user_spec_l229_d18_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := as_console_user_spec_new_fixture('no-user') or {
		return ruby.bool_value(false)
	}
	defer { os.rmdir_all(fixture.root) or {} }
	result := as_console_user_spec_run_shell([
		'source ' + os.quoted_path(fixture.macos_user_script),
		r'stat() { printf "root\n"; }',
		r'homebrew-package-user',
	].join('\n') + '\n', {
		'HOMEBREW_PKG_USER_PLIST': os.join_path(fixture.root, 'missing.plist')
	}) or { return ruby.bool_value(false) }
	return as_console_user_spec_bool(result, '', '', 1)
}

// Ruby it `it "dispatches the nested brew command as the console user" do` at line 241.
pub fn ruby_as_console_user_spec_l241_d19_dispatches(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := as_console_user_spec_new_fixture('dispatch') or {
		return ruby.bool_value(false)
	}
	defer { os.rmdir_all(fixture.root) or {} }
	args_file := os.join_path(fixture.root, 'sudo-args.txt')
	console_home := os.join_path(fixture.root, 'console-home')
	os.mkdir_all(console_home) or { return ruby.bool_value(false) }
	script := [
		'source ' + os.quoted_path(fixture.as_console_user_script),
		r'odie() { echo "Error: $*" >&2; exit 1; }',
		r'stat() { printf "mike\n"; }',
		'id() { printf "mike:*:501:20::0:0:Mike:${console_home}:/bin/zsh\\n"; }',
		r'sudo() {',
		r'  printf "cwd=%s\n" "$PWD" > ' + os.quoted_path(args_file),
		r'  printf "%s\n" "$@" >> ' + os.quoted_path(args_file),
		r'  return 42',
		r'}',
		r'homebrew-as-console-user upgrade git --minimum-version=2.50.1',
	].join('\n') + '\n'
	mut environment := as_console_user_spec_macos_env(fixture)
	environment['HOMEBREW_BREW_FILE'] = '/opt/homebrew/bin/brew'
	result := as_console_user_spec_run_shell(script, environment) or {
		return ruby.bool_value(false)
	}
	expected := [
		'cwd=${console_home}',
		'-H',
		'-u',
		'mike',
		'/usr/bin/env',
		'-i',
		'HOME=${console_home}',
		'USER=mike',
		'LOGNAME=mike',
		'PWD=${console_home}',
		'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
		'/opt/homebrew/bin/brew',
		'upgrade',
		'git',
		'--minimum-version=2.50.1',
	].join('\n') + '\n'
	contents := os.read_file(args_file) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.exit_code == 42 && result.stdout == ''
		&& result.stderr == '' && contents == expected)
}

fn as_console_user_spec_console_rejection(console_user string) ruby.Value {
	fixture := as_console_user_spec_new_fixture('reject-${console_user}') or {
		return ruby.bool_value(false)
	}
	defer { os.rmdir_all(fixture.root) or {} }
	result := as_console_user_spec_run_shell([
		'source ' + os.quoted_path(fixture.as_console_user_script),
		r'odie() { echo "Error: $*" >&2; exit 1; }',
		'stat() { printf "${console_user}\\n"; }',
		r'homebrew-as-console-user install wget',
	].join('\n') + '\n', as_console_user_spec_macos_env(fixture)) or {
		return ruby.bool_value(false)
	}
	return as_console_user_spec_bool(result, '', 'Error: No supported macOS console user is logged in.\n', 1)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: require "cmd/shared_examples/args_parse"
// 7: require "cmd/as-console-user"
// 8:
// 9: RSpec.describe Homebrew::Cmd::AsConsoleUser do
// 10:   let(:as_console_user_script) { HOMEBREW_LIBRARY_PATH/"cmd/as-console-user.sh" }
// 11:   let(:repository_root) { HOMEBREW_LIBRARY_PATH.parent.parent }
// 12:   let(:test_root) { mktmpdir }
// 13:   let(:macos_user_script) { repository_root/"Library/Homebrew/utils/macos_user.sh" }
// 14:
// 15:   let(:macos_env) do
// 16:     {
// 17:       "HOMEBREW_BREW_FILE" => "brew",
// 18:       "HOMEBREW_LIBRARY"   => (repository_root/"Library").to_s,
// 19:       "HOMEBREW_MACOS"     => "1",
// 20:     }
// 21:   end
// 22:
// 23:   it_behaves_like "parseable arguments"
// 24:
// 25:   def run_as_console_user_shell(script, env = {})
// 26:     Bundler.with_unbundled_env do
// 27:       Open3.capture3(env, "/bin/bash", "-c", script)
// 28:     end
// 29:   end
// 30:
// 31:   it "prints help and fails when no command is provided" do
// 32:     stdout, stderr, status = run_as_console_user_shell(
// 33:       <<~SH,
// 34:         source "#{as_console_user_script}"
// 35:         brew() { printf '%s\\n' "$*" >&2; }
// 36:         homebrew-as-console-user
// 37:       SH
// 38:       "HOMEBREW_BREW_FILE" => "brew",
// 39:       "HOMEBREW_LIBRARY"   => (repository_root/"Library").to_s,
// 40:     )
// 41:
// 42:     expect(status.exitstatus).to eq 1
// 43:     expect(stdout).to be_empty
// 44:     expect(stderr).to eq("help as-console-user\n")
// 45:   end
// 46:
// 47:   it "rejects a root console user" do
// 48:     stdout, stderr, status = run_as_console_user_shell(
// 49:       <<~SH,
// 50:         source "#{as_console_user_script}"
// 51:         odie() { echo "Error: $*" >&2; exit 1; }
// 52:         stat() { printf 'root\\n'; }
// 53:         homebrew-as-console-user install wget
// 54:       SH
// 55:       macos_env,
// 56:     )
// 57:
// 58:     expect(status.exitstatus).to eq 1
// 59:     expect(stdout).to be_empty
// 60:     expect(stderr).to eq("Error: No supported macOS console user is logged in.\n")
// 61:   end
// 62:
// 63:   it "rejects a loginwindow console user" do
// 64:     stdout, stderr, status = run_as_console_user_shell(
// 65:       <<~SH,
// 66:         source "#{as_console_user_script}"
// 67:         odie() { echo "Error: $*" >&2; exit 1; }
// 68:         stat() { printf 'loginwindow\\n'; }
// 69:         homebrew-as-console-user install wget
// 70:       SH
// 71:       macos_env,
// 72:     )
// 73:
// 74:     expect(status.exitstatus).to eq 1
// 75:     expect(stdout).to be_empty
// 76:     expect(stderr).to eq("Error: No supported macOS console user is logged in.\n")
// 77:   end
// 78:
// 79:   it "rejects non-macOS systems" do
// 80:     stdout, stderr, status = run_as_console_user_shell(
// 81:       <<~SH,
// 82:         source "#{as_console_user_script}"
// 83:         odie() { echo "Error: $*" >&2; exit 1; }
// 84:         homebrew-as-console-user install wget
// 85:       SH
// 86:       "HOMEBREW_BREW_FILE" => "brew",
// 87:       "HOMEBREW_LIBRARY"   => (repository_root/"Library").to_s,
// 88:     )
// 89:
// 90:     expect(status.exitstatus).to eq 1
// 91:     expect(stdout).to be_empty
// 92:     expect(stderr).to eq("Error: `brew as-console-user` is only supported on macOS.\n")
// 93:   end
// 94:
// 95:   it "uses the package user plist before the console user" do
// 96:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 97:     homebrew_pkg_user_plist.write "plist"
// 98:
// 99:     stdout, stderr, status = run_as_console_user_shell(
// 100:       <<~SH,
// 101:         source "#{macos_user_script}"
// 102:         defaults() { printf 'munki\\n'; }
// 103:         stat() { printf 'root 600\\n'; }
// 104:         ls() { printf -- '-rw------- 1 root wheel 0 x\\n'; }
// 105:         homebrew-package-user
// 106:       SH
// 107:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 108:     )
// 109:
// 110:     expect(status.success?).to be true
// 111:     expect(stdout).to eq("munki\n")
// 112:     expect(stderr).to be_empty
// 113:   end
// 114:
// 115:   it "honours a root-owned plist that carries extended attributes" do
// 116:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 117:     homebrew_pkg_user_plist.write "plist"
// 118:
// 119:     stdout, stderr, status = run_as_console_user_shell(
// 120:       <<~SH,
// 121:         source "#{macos_user_script}"
// 122:         defaults() { printf 'munki\\n'; }
// 123:         stat() { printf 'root 600\\n'; }
// 124:         ls() { printf -- '-rw-------@ 1 root wheel 0 x\\n'; }
// 125:         homebrew-package-user
// 126:       SH
// 127:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 128:     )
// 129:
// 130:     expect(status.success?).to be true
// 131:     expect(stdout).to eq("munki\n")
// 132:     expect(stderr).to be_empty
// 133:   end
// 134:
// 135:   it "ignores a package user plist not owned by root" do
// 136:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 137:     homebrew_pkg_user_plist.write "plist"
// 138:
// 139:     stdout, stderr, status = run_as_console_user_shell(
// 140:       <<~SH,
// 141:         source "#{macos_user_script}"
// 142:         defaults() { printf 'attacker\\n'; }
// 143:         stat() { case "$*" in *"/dev/console") printf 'root\\n';; *) printf 'attacker 600\\n';; esac; }
// 144:         ls() { printf -- '-rw------- 1 attacker staff 0 x\\n'; }
// 145:         homebrew-package-user
// 146:       SH
// 147:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 148:     )
// 149:
// 150:     expect(status.exitstatus).to eq 1
// 151:     expect(stdout).to be_empty
// 152:     expect(stderr).to be_empty
// 153:   end
// 154:
// 155:   it "ignores a package user plist with loose permissions" do
// 156:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 157:     homebrew_pkg_user_plist.write "plist"
// 158:
// 159:     stdout, stderr, status = run_as_console_user_shell(
// 160:       <<~SH,
// 161:         source "#{macos_user_script}"
// 162:         defaults() { printf 'attacker\\n'; }
// 163:         stat() { case "$*" in *"/dev/console") printf 'root\\n';; *) printf 'root 644\\n';; esac; }
// 164:         ls() { printf -- '-rw-rw-rw- 1 root wheel 0 x\\n'; }
// 165:         homebrew-package-user
// 166:       SH
// 167:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 168:     )
// 169:
// 170:     expect(status.exitstatus).to eq 1
// 171:     expect(stdout).to be_empty
// 172:     expect(stderr).to be_empty
// 173:   end
// 174:
// 175:   it "ignores a package user plist carrying an ACL" do
// 176:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 177:     homebrew_pkg_user_plist.write "plist"
// 178:
// 179:     stdout, stderr, status = run_as_console_user_shell(
// 180:       <<~SH,
// 181:         source "#{macos_user_script}"
// 182:         defaults() { printf 'attacker\\n'; }
// 183:         stat() { case "$*" in *"/dev/console") printf 'root\\n';; *) printf 'root 600\\n';; esac; }
// 184:         ls() { printf -- '-rw-------@ 1 root wheel 0 x\\n 0: group:everyone deny delete\\n'; }
// 185:         homebrew-package-user
// 186:       SH
// 187:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 188:     )
// 189:
// 190:     expect(status.exitstatus).to eq 1
// 191:     expect(stdout).to be_empty
// 192:     expect(stderr).to be_empty
// 193:   end
// 194:
// 195:   it "ignores a package user plist that is a symlink" do
// 196:     homebrew_pkg_user_target = test_root/"target.plist"
// 197:     homebrew_pkg_user_target.write "plist"
// 198:     homebrew_pkg_user_plist = test_root/".homebrew_pkg_user.plist"
// 199:     FileUtils.ln_s homebrew_pkg_user_target, homebrew_pkg_user_plist
// 200:
// 201:     stdout, stderr, status = run_as_console_user_shell(
// 202:       <<~SH,
// 203:         source "#{macos_user_script}"
// 204:         defaults() { printf 'attacker\\n'; }
// 205:         stat() { case "$*" in *"/dev/console") printf 'root\\n';; *) printf 'root\\n';; esac; }
// 206:         ls() { printf -- '-rw------- 1 root wheel 0 x\\n'; }
// 207:         homebrew-package-user
// 208:       SH
// 209:       "HOMEBREW_PKG_USER_PLIST" => homebrew_pkg_user_plist.to_s,
// 210:     )
// 211:
// 212:     expect(status.exitstatus).to eq 1
// 213:     expect(stdout).to be_empty
// 214:     expect(stderr).to be_empty
// 215:   end
// 216:
// 217:   it "falls back to the console user without a package user plist" do
// 218:     stdout, stderr, status = run_as_console_user_shell <<~SH
// 219:       source "#{macos_user_script}"
// 220:       stat() { printf 'mike\\n'; }
// 221:       homebrew-package-user
// 222:     SH
// 223:
// 224:     expect(status.success?).to be true
// 225:     expect(stdout).to eq("mike\n")
// 226:     expect(stderr).to be_empty
// 227:   end
// 228:
// 229:   it "rejects package user lookup without a package user or console user" do
// 230:     stdout, stderr, status = run_as_console_user_shell <<~SH
// 231:       source "#{macos_user_script}"
// 232:       stat() { printf 'root\\n'; }
// 233:       homebrew-package-user
// 234:     SH
// 235:
// 236:     expect(status.exitstatus).to eq 1
// 237:     expect(stdout).to be_empty
// 238:     expect(stderr).to be_empty
// 239:   end
// 240:
// 241:   it "dispatches the nested brew command as the console user" do
// 242:     args_file = test_root/"sudo-args.txt"
// 243:     console_home = test_root/"console-home"
// 244:     console_home.mkpath
// 245:
// 246:     stdout, stderr, status = run_as_console_user_shell(
// 247:       <<~SH,
// 248:         source "#{as_console_user_script}"
// 249:         odie() { echo "Error: $*" >&2; exit 1; }
// 250:         stat() { printf 'mike\\n'; }
// 251:         id() { printf 'mike:*:501:20::0:0:Mike:#{console_home}:/bin/zsh\\n'; }
// 252:         sudo() {
// 253:           printf 'cwd=%s\\n' "$PWD" > "#{args_file}"
// 254:           printf '%s\\n' "$@" >> "#{args_file}"
// 255:           return 42
// 256:         }
// 257:         homebrew-as-console-user upgrade git --minimum-version=2.50.1
// 258:       SH
// 259:       macos_env.merge("HOMEBREW_BREW_FILE" => "/opt/homebrew/bin/brew"),
// 260:     )
// 261:
// 262:     expect(status.exitstatus).to eq 42
// 263:     expect(stdout).to be_empty
// 264:     expect(stderr).to be_empty
// 265:     expect(args_file.read).to eq <<~EOS
// 266:       cwd=#{console_home}
// 267:       -H
// 268:       -u
// 269:       mike
// 270:       /usr/bin/env
// 271:       -i
// 272:       HOME=#{console_home}
// 273:       USER=mike
// 274:       LOGNAME=mike
// 275:       PWD=#{console_home}
// 276:       PATH=/usr/bin:/bin:/usr/sbin:/sbin
// 277:       /opt/homebrew/bin/brew
// 278:       upgrade
// 279:       git
// 280:       --minimum-version=2.50.1
// 281:     EOS
// 282:   end
// 283: end
