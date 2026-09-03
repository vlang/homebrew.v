module test

import brew_runtime
import os
import time

// Translated from Homebrew/brew `test/bash_spec.rb`.
// The original source is retained below until every stub has a typed V body.

const bash_spec_revision = '0123456789abcdef0123456789abcdef01234567'

fn bash_spec_repository(args []brew_runtime.Value) string {
	if args.len > 0 && args[0].as_string() != '' {
		return args[0].as_string()
	}
	if configured := os.getenv_opt('HOMEBREW_BASH_SPEC_REPOSITORY') {
		return configured
	}
	return os.real_path(os.join_path(@VMODROOT, '..', '3rd', 'brew'))
}

fn bash_spec_environment(overrides map[string]string, unset_names []string) map[string]string {
	mut environment := brew_runtime.environment()
	for name in unset_names {
		environment.delete(name)
	}
	for name, value in overrides {
		environment[name] = value
	}
	return environment
}

fn bash_spec_run_script(script string, arguments []string, overrides map[string]string,
	unset_names []string) !brew_runtime.CapturedCommandResult {
	mut command := ['/bin/bash', '-c', script, 'bash']
	command << arguments
	return brew_runtime.run_captured_command(command, brew_runtime.CapturedCommandOptions{
		environment: bash_spec_environment(overrides, unset_names)
	})
}

pub fn bash_spec_check_syntax(path string) !brew_runtime.CapturedCommandResult {
	return brew_runtime.run_captured_command(['/bin/bash', '-n', path], brew_runtime.CapturedCommandOptions{
		environment: brew_runtime.environment()
	})
}

pub fn bash_spec_syntax_failure_message(path string,
	result brew_runtime.CapturedCommandResult) string {
	return 'expected that ${path} is a valid Bash file:\n${result.stderr}'
}

fn bash_spec_valid_syntax(path string) bool {
	result := bash_spec_check_syntax(path) or { return false }
	return result.stdout == '' && result.exit_code == 0
}

fn bash_spec_temp_directory(label string) !string {
	path := os.join_path(os.temp_dir(), 'brew-v-bash-spec-${label}-${os.getpid()}-${time.now().unix_nano()}')
	os.mkdir(path)!
	return path
}

fn bash_spec_all_files(root string) []string {
	mut files := []string{}
	mut remaining := [root]
	for remaining.len > 0 {
		directory := remaining.pop()
		entries := os.ls(directory) or { continue }
		for entry in entries {
			path := os.join_path(directory, entry)
			if os.is_dir(path) && !os.is_link(path) {
				remaining << path
			} else {
				files << path
			}
		}
	}
	files.sort()
	return files
}

// Ruby matcher `matcher :have_valid_bash_syntax do` at line 7.
pub fn ruby_bash_spec_l7_d1_have_valid_bash_syntax(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(bash_spec_valid_syntax(args[0].as_string()))
}

// Ruby subject `subject(:brew) { HOMEBREW_LIBRARY_PATH.parent.parent/"bin/brew" }` at line 22.
pub fn ruby_bash_spec_l22_d2_brew(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', os.join_path(bash_spec_repository(args), 'bin', 'brew'))
}

// Ruby it `it { is_expected.to have_valid_bash_syntax }` at line 24.
pub fn ruby_bash_spec_l24_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	brew := if args.len > 0 { args[0] } else { ruby_bash_spec_l22_d2_brew() }
	return ruby_bash_spec_l7_d1_have_valid_bash_syntax(brew)
}

// Ruby it `it "uses the macOS locale charmap rather than the locale name", :needs_macos do` at line 28.
pub fn ruby_bash_spec_l28_d4_uses(args ...brew_runtime.Value) brew_runtime.Value {
	os_script := os.join_path(bash_spec_repository(args), 'Library', 'Homebrew', 'utils', 'os.sh')
	script := [
		r'source "$1"',
		'HOMEBREW_MACOS=1',
		'locale() {',
		r'  [[ "${LC_CTYPE:-${LANG:-}}" == "UTF-8" ]] && printf "UTF-8" || printf "US-ASCII"',
		'}',
		'setup-locale',
		r'printf "%s" "${LC_ALL-unset}"',
	].join('\n')
	invalid := bash_spec_run_script(script, [os_script], {
		'LANG': 'C.utf8'
	}, ['LC_CTYPE', 'LC_ALL']) or { return brew_runtime.bool_value(false) }
	valid := bash_spec_run_script(script, [os_script], {
		'LC_CTYPE': 'UTF-8'
	}, ['LANG', 'LC_ALL']) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(invalid.stdout == 'en_US.UTF-8' && invalid.stderr == ''
		&& invalid.exit_code == 0 && valid.stdout == 'unset' && valid.stderr == ''
		&& valid.exit_code == 0)
}

// Ruby it `it "restores filtered Linux locale variables and removes their copies" do` at line 51.
pub fn ruby_bash_spec_l51_d5_restores(args ...brew_runtime.Value) brew_runtime.Value {
	os_script := os.join_path(bash_spec_repository(args), 'Library', 'Homebrew', 'utils', 'os.sh')
	script := [
		r'source "$1"',
		'HOMEBREW_MACOS=',
		'HOMEBREW_LANG=C',
		'HOMEBREW_LC_CTYPE=C',
		'HOMEBREW_LC_ALL=C.UTF-8',
		'locale() {',
		r'  if [[ "$1" == "charmap" ]]',
		'  then',
		r'    [[ "${LC_ALL:-}" == "C.UTF-8" ]] && printf "UTF-8" || printf "US-ASCII"',
		'  else',
		r'    printf "locale -a called\n" >&2',
		r'    printf "C.UTF-8\n"',
		'  fi',
		'}',
		'setup-locale',
		r'printf "%s\n" "${LANG-unset}" "${LC_CTYPE-unset}" "${LC_ALL-unset}" "${HOMEBREW_LANG-unset}" "${HOMEBREW_LC_CTYPE-unset}" "${HOMEBREW_LC_ALL-unset}"',
	].join('\n')
	result := bash_spec_run_script(script, [os_script], map[string]string{}, ['LANG', 'LC_CTYPE',
		'LC_ALL']) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.stdout == 'C\nC\nC.UTF-8\nunset\nunset\nunset\n'
		&& result.stderr == '' && result.exit_code == 0)
}

// Ruby it `it "writes the cache when the current user owns the Git directory" do` at line 81.
pub fn ruby_bash_spec_l81_d6_writes(args ...brew_runtime.Value) brew_runtime.Value {
	repository := bash_spec_temp_directory('git-cache-owned') or {
		return brew_runtime.bool_value(false)
	}
	defer {
		os.rmdir_all(repository) or {}
	}
	refs := os.join_path(repository, '.git', 'refs', 'heads')
	os.mkdir_all(refs) or { return brew_runtime.bool_value(false) }
	os.write_file(os.join_path(repository, '.git', 'HEAD'), 'ref: refs/heads/main\n') or {
		return brew_runtime.bool_value(false)
	}
	os.write_file(os.join_path(refs, 'main'), '${bash_spec_revision}\n') or {
		return brew_runtime.bool_value(false)
	}
	git_script := os.join_path(bash_spec_repository(args), 'Library', 'Homebrew', 'utils', 'git.sh')
	script := [
		r'source "$1"',
		'git() {',
		r'  [[ "$*" == *"describe --tags"* ]] && printf "1.2.3"',
		'}',
		'HOMEBREW_VERSION=',
		'set-homebrew-version-from-git',
		r'printf "%s" "${HOMEBREW_VERSION}"',
	].join('\n')
	result := bash_spec_run_script(script, [git_script], {
		'HOMEBREW_GIT':        'git'
		'HOMEBREW_REPOSITORY': repository
	}, []string{}) or { return brew_runtime.bool_value(false) }
	cache_file := os.join_path(repository, '.git', 'describe-cache', bash_spec_revision)
	cache := os.read_file(cache_file) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.stdout == '1.2.3' && result.stderr == ''
		&& result.exit_code == 0 && cache == '1.2.3\n')
}

// Ruby it `it "does not mutate the cache when the current user does not own the Git directory" do` at line 107.
pub fn ruby_bash_spec_l107_d7_does(args ...brew_runtime.Value) brew_runtime.Value {
	if os.geteuid() == 0 {
		return brew_runtime.bool_value(true)
	}
	repository := bash_spec_temp_directory('git-cache-unowned') or {
		return brew_runtime.bool_value(false)
	}
	git_directory := os.join_path(repository, '.git')
	defer {
		if os.is_link(git_directory) {
			os.rm(git_directory) or {}
		}
		os.rmdir_all(repository) or {}
	}
	os.symlink('/', git_directory) or { return brew_runtime.bool_value(false) }
	operations := os.join_path(repository, 'operations')
	git_script := os.join_path(bash_spec_repository(args), 'Library', 'Homebrew', 'utils', 'git.sh')
	script := [
		r'source "$1"',
		r'operations="$2"',
		'git() {',
		r'  case "$*" in',
		r'    *"rev-parse HEAD") printf "0123456789abcdef0123456789abcdef01234567" ;;',
		r'    *"describe --tags"*) printf "1.2.3" ;;',
		'    *) return 1 ;;',
		'  esac',
		'}',
		r'rm() { printf "rm\n" >>"${operations}"; }',
		r'mkdir() { printf "mkdir\n" >>"${operations}"; }',
		'HOMEBREW_VERSION=',
		'set-homebrew-version-from-git',
		r'printf "%s" "${HOMEBREW_VERSION}"',
	].join('\n')
	result := bash_spec_run_script(script, [git_script, operations], {
		'HOMEBREW_GIT':        'git'
		'HOMEBREW_REPOSITORY': repository
	}, []string{}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.stdout == '1.2.3' && result.stderr == ''
		&& result.exit_code == 0 && !os.exists(operations))
}

// Ruby it `it "has valid Bash syntax" do` at line 141.
pub fn ruby_bash_spec_l141_d8_has(args ...brew_runtime.Value) brew_runtime.Value {
	library := os.join_path(bash_spec_repository(args), 'Library', 'Homebrew')
	mut paths := os.walk_ext(library, '.sh', os.WalkParams{})
	paths.sort()
	for path in paths {
		relative_path := path.all_after('${library}${os.path_separator}')
		if relative_path.starts_with('shims/') || relative_path.starts_with('test/')
			|| relative_path.starts_with('vendor/') {
			continue
		}
		if !bash_spec_valid_syntax(path) {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby subject `subject { HOMEBREW_LIBRARY_PATH.parent.parent/"completions/bash/brew" }` at line 152.
pub fn ruby_bash_spec_l152_d9_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', os.join_path(bash_spec_repository(args), 'completions', 'bash', 'brew'))
}

// Ruby it `it { is_expected.to have_valid_bash_syntax }` at line 154.
pub fn ruby_bash_spec_l154_d10_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	completion := if args.len > 0 { args[0] } else { ruby_bash_spec_l152_d9_subject_dynamic() }
	return ruby_bash_spec_l7_d1_have_valid_bash_syntax(completion)
}

// Ruby it `it "has valid Bash syntax" do` at line 158.
pub fn ruby_bash_spec_l158_d11_has(args ...brew_runtime.Value) brew_runtime.Value {
	shims := os.join_path(bash_spec_repository(args), 'Library', 'Homebrew', 'shims')
	for path in bash_spec_all_files(shims) {
		if os.is_link(path) || !os.is_executable(path) || os.file_name(path) == 'cc' {
			continue
		}
		contents := os.read_file(path) or { return brew_runtime.bool_value(false) }
		if contents.len < 12 || contents[..12] != '#!/bin/bash\n' {
			continue
		}
		if !bash_spec_valid_syntax(path) {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: RSpec.describe "Bash" do
// 7:   matcher :have_valid_bash_syntax do
// 8:     match do |file|
// 9:       stdout, stderr, status = Open3.capture3("/bin/bash", "-n", file)
// 10:
// 11:       @actual = [file, stderr]
// 12:
// 13:       stdout.empty? && status.success?
// 14:     end
// 15:
// 16:     failure_message do |(file, stderr)|
// 17:       "expected that #{file} is a valid Bash file:\n#{stderr}"
// 18:     end
// 19:   end
// 20:
// 21:   describe "brew" do
// 22:     subject(:brew) { HOMEBREW_LIBRARY_PATH.parent.parent/"bin/brew" }
// 23:
// 24:     it { is_expected.to have_valid_bash_syntax }
// 25:   end
// 26:
// 27:   describe "setup-locale" do
// 28:     it "uses the macOS locale charmap rather than the locale name", :needs_macos do
// 29:       setup_locale = [
// 30:         "/bin/bash", "-c", <<~BASH, "bash", (HOMEBREW_LIBRARY_PATH/"utils/os.sh").to_s
// 31:           source "$1"
// 32:           locale() {
// 33:             [[ "${LC_CTYPE:-${LANG:-}}" == "UTF-8" ]] && printf "UTF-8" || printf "US-ASCII"
// 34:           }
// 35:           setup-locale
// 36:           printf "%s" "${LC_ALL-unset}"
// 37:         BASH
// 38:       ]
// 39:       invalid_stdout, invalid_stderr, invalid_status = Open3.capture3(
// 40:         { "LANG" => "C.utf8", "LC_CTYPE" => nil, "LC_ALL" => nil }, *setup_locale
// 41:       )
// 42:       valid_stdout, valid_stderr, valid_status = Open3.capture3(
// 43:         { "LANG" => nil, "LC_CTYPE" => "UTF-8", "LC_ALL" => nil }, *setup_locale
// 44:       )
// 45:
// 46:       expect([invalid_stdout, invalid_stderr, invalid_status.success?,
// 47:               valid_stdout, valid_stderr, valid_status.success?])
// 48:         .to eq(["en_US.UTF-8", "", true, "unset", "", true])
// 49:     end
// 50:
// 51:     it "restores filtered Linux locale variables and removes their copies" do
// 52:       stdout, stderr, status = Open3.capture3(
// 53:         { "LANG" => nil, "LC_CTYPE" => nil, "LC_ALL" => nil },
// 54:         "/bin/bash", "-c", <<~'BASH', "bash", (HOMEBREW_LIBRARY_PATH/"utils/os.sh").to_s
// 55:           source "$1"
// 56:           HOMEBREW_MACOS=
// 57:           HOMEBREW_LANG=C
// 58:           HOMEBREW_LC_CTYPE=C
// 59:           HOMEBREW_LC_ALL=C.UTF-8
// 60:           locale() {
// 61:             if [[ "$1" == "charmap" ]]
// 62:             then
// 63:               [[ "${LC_ALL:-}" == "C.UTF-8" ]] && printf "UTF-8" || printf "US-ASCII"
// 64:             else
// 65:               printf "locale -a called\n" >&2
// 66:               printf "C.UTF-8\n"
// 67:             fi
// 68:           }
// 69:           setup-locale
// 70:           printf "%s\n" "${LANG-unset}" "${LC_CTYPE-unset}" "${LC_ALL-unset}" \
// 71:             "${HOMEBREW_LANG-unset}" "${HOMEBREW_LC_CTYPE-unset}" "${HOMEBREW_LC_ALL-unset}"
// 72:         BASH
// 73:       )
// 74:
// 75:       expect([stdout, stderr, status.success?])
// 76:         .to eq(["C\nC\nC.UTF-8\nunset\nunset\nunset\n", "", true])
// 77:     end
// 78:   end
// 79:
// 80:   describe "set-homebrew-version-from-git" do
// 81:     it "writes the cache when the current user owns the Git directory" do
// 82:       Dir.mktmpdir("brew-git-cache-") do |tmpdir|
// 83:         repository = Pathname(tmpdir)
// 84:         revision = "0123456789abcdef0123456789abcdef01234567"
// 85:         (repository/".git/refs/heads").mkpath
// 86:         (repository/".git/HEAD").write "ref: refs/heads/main\n"
// 87:         (repository/".git/refs/heads/main").write "#{revision}\n"
// 88:
// 89:         stdout, stderr, status = Open3.capture3(
// 90:           { "HOMEBREW_GIT" => "git", "HOMEBREW_REPOSITORY" => repository.to_s },
// 91:           "/bin/bash", "-c", <<~BASH, "bash", (HOMEBREW_LIBRARY_PATH/"utils/git.sh").to_s
// 92:             source "$1"
// 93:             git() {
// 94:               [[ "$*" == *"describe --tags"* ]] && printf "1.2.3"
// 95:             }
// 96:             HOMEBREW_VERSION=
// 97:             set-homebrew-version-from-git
// 98:             printf "%s" "${HOMEBREW_VERSION}"
// 99:           BASH
// 100:         )
// 101:
// 102:         cache_file = repository/".git/describe-cache"/revision
// 103:         expect([stdout, stderr, status.success?, cache_file.read]).to eq(["1.2.3", "", true, "1.2.3\n"])
// 104:       end
// 105:     end
// 106:
// 107:     it "does not mutate the cache when the current user does not own the Git directory" do
// 108:       skip "User is root so the root directory is owned by the current user." if Process.euid.zero?
// 109:
// 110:       Dir.mktmpdir("brew-git-cache-") do |tmpdir|
// 111:         repository = Pathname(tmpdir)
// 112:         (repository/".git").make_symlink "/"
// 113:         operations = repository/"operations"
// 114:
// 115:         stdout, stderr, status = Open3.capture3(
// 116:           { "HOMEBREW_GIT" => "git", "HOMEBREW_REPOSITORY" => repository.to_s },
// 117:           "/bin/bash", "-c", <<~'BASH', "bash", (HOMEBREW_LIBRARY_PATH/"utils/git.sh").to_s, operations.to_s
// 118:             source "$1"
// 119:             operations="$2"
// 120:             git() {
// 121:               case "$*" in
// 122:                 *"rev-parse HEAD") printf "0123456789abcdef0123456789abcdef01234567" ;;
// 123:                 *"describe --tags"*) printf "1.2.3" ;;
// 124:                 *) return 1 ;;
// 125:               esac
// 126:             }
// 127:             rm() { printf "rm\n" >>"${operations}"; }
// 128:             mkdir() { printf "mkdir\n" >>"${operations}"; }
// 129:             HOMEBREW_VERSION=
// 130:             set-homebrew-version-from-git
// 131:             printf "%s" "${HOMEBREW_VERSION}"
// 132:           BASH
// 133:         )
// 134:
// 135:         expect([stdout, stderr, status.success?, operations.exist?]).to eq(["1.2.3", "", true, false])
// 136:       end
// 137:     end
// 138:   end
// 139:
// 140:   describe "every `.sh` file" do
// 141:     it "has valid Bash syntax" do
// 142:       Pathname.glob("#{HOMEBREW_LIBRARY_PATH}/**/*.sh").each do |path|
// 143:         relative_path = path.relative_path_from(HOMEBREW_LIBRARY_PATH)
// 144:         next if relative_path.to_s.start_with?("shims/", "test/", "vendor/")
// 145:
// 146:         expect(path).to have_valid_bash_syntax
// 147:       end
// 148:     end
// 149:   end
// 150:
// 151:   describe "Bash completion" do
// 152:     subject { HOMEBREW_LIBRARY_PATH.parent.parent/"completions/bash/brew" }
// 153:
// 154:     it { is_expected.to have_valid_bash_syntax }
// 155:   end
// 156:
// 157:   describe "every shim script" do
// 158:     it "has valid Bash syntax" do
// 159:       # These have no file extension, but can be identified by their shebang.
// 160:       (HOMEBREW_LIBRARY_PATH/"shims").find do |path|
// 161:         next if path.directory?
// 162:         next if path.symlink?
// 163:         next unless path.executable?
// 164:         next if path.basename.to_s == "cc" # `bash -n` tries to parse the Ruby part
// 165:         next if path.read(12) != "#!/bin/bash\n"
// 166:
// 167:         expect(path).to have_valid_bash_syntax
// 168:       end
// 169:     end
// 170:   end
// 171: end
