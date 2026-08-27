module test

import brew_runtime

// Translated from Homebrew/brew `test/bash_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby matcher `matcher :have_valid_bash_syntax do` at line 7.
pub fn ruby_bash_spec_l7_d1_have_valid_bash_syntax(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('have_valid_bash_syntax', ...args)
}

// Ruby subject `subject(:brew) { HOMEBREW_LIBRARY_PATH.parent.parent/"bin/brew" }` at line 22.
pub fn ruby_bash_spec_l22_d2_brew(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brew', ...args)
}

// Ruby it `it { is_expected.to have_valid_bash_syntax }` at line 24.
pub fn ruby_bash_spec_l24_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it "uses the macOS locale charmap rather than the locale name", :needs_macos do` at line 28.
pub fn ruby_bash_spec_l28_d4_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "restores filtered Linux locale variables and removes their copies" do` at line 51.
pub fn ruby_bash_spec_l51_d5_restores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('restores', ...args)
}

// Ruby it `it "writes the cache when the current user owns the Git directory" do` at line 81.
pub fn ruby_bash_spec_l81_d6_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "does not mutate the cache when the current user does not own the Git directory" do` at line 107.
pub fn ruby_bash_spec_l107_d7_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "has valid Bash syntax" do` at line 141.
pub fn ruby_bash_spec_l141_d8_has(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('has', ...args)
}

// Ruby subject `subject { HOMEBREW_LIBRARY_PATH.parent.parent/"completions/bash/brew" }` at line 152.
pub fn ruby_bash_spec_l152_d9_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subject_dynamic', ...args)
}

// Ruby it `it { is_expected.to have_valid_bash_syntax }` at line 154.
pub fn ruby_bash_spec_l154_d10_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it "has valid Bash syntax" do` at line 158.
pub fn ruby_bash_spec_l158_d11_has(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('has', ...args)
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
