module utils

import ruby
import homebrew.utils as shell_utils
import os

// Translated from Homebrew/brew `test/utils/shell_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns ~/.profile by default" do` at line 8.
pub fn ruby_shell_spec_l8_d1_returns(args ...ruby.Value) ruby.Value {
	home := shell_spec_root('profile-default')
	defer { os.rmdir_all(home) or {} }
	return shell_spec_bool(shell_utils.shell_profile_for('', home, '') == '~/.profile')
}

// Ruby it `it "returns ~/.profile for sh" do` at line 13.
pub fn ruby_shell_spec_l13_d2_returns(args ...ruby.Value) ruby.Value {
	home := shell_spec_root('profile-sh')
	defer { os.rmdir_all(home) or {} }
	return shell_spec_bool(shell_utils.shell_profile_for('sh', home, '') == '~/.profile')
}

// Ruby it `it "returns ~/.profile for Bash" do` at line 18.
pub fn ruby_shell_spec_l18_d3_returns(args ...ruby.Value) ruby.Value {
	home := shell_spec_root('profile-bash')
	defer { os.rmdir_all(home) or {} }
	return shell_spec_bool(shell_utils.shell_profile_for('bash', home, '') == '~/.profile')
}

// Ruby it `it "returns /tmp/.zshrc for Zsh if ZDOTDIR is /tmp" do` at line 23.
pub fn ruby_shell_spec_l23_d4_returns(args ...ruby.Value) ruby.Value {
	return shell_spec_bool(shell_utils.shell_profile_for('zsh', '/home/test', '/tmp') == '/tmp/.zshrc')
}

// Ruby it `it "returns ~/.zshrc for Zsh" do` at line 29.
pub fn ruby_shell_spec_l29_d5_returns(args ...ruby.Value) ruby.Value {
	return shell_spec_bool(shell_utils.shell_profile_for('zsh', '/home/test', '') == '~/.zshrc')
}

// Ruby it `it "returns ~/.kshrc for Ksh" do` at line 35.
pub fn ruby_shell_spec_l35_d6_returns(args ...ruby.Value) ruby.Value {
	return shell_spec_bool(shell_utils.shell_profile_for('ksh', '/home/test', '') == '~/.kshrc')
}

// Ruby it `it "returns ~/.config/powershell/Microsoft.PowerShell_profile.ps1 for PowerShell" do` at line 40.
pub fn ruby_shell_spec_l40_d7_returns(args ...ruby.Value) ruby.Value {
	return shell_spec_bool(shell_utils.shell_profile_for('pwsh', '/home/test', '') == '~/.config/powershell/Microsoft.PowerShell_profile.ps1')
}

// Ruby it `it "supports a raw command name" do` at line 47.
pub fn ruby_shell_spec_l47_d8_supports(args ...ruby.Value) ruby.Value {
	return shell_spec_bool((shell_utils.shell_from_path('bash') or { '' }) == 'bash')
}

// Ruby it `it "supports full paths" do` at line 51.
pub fn ruby_shell_spec_l51_d9_supports(args ...ruby.Value) ruby.Value {
	return shell_spec_bool((shell_utils.shell_from_path('/bin/bash') or { '' }) == 'bash')
}

// Ruby it `it "supports versions" do` at line 55.
pub fn ruby_shell_spec_l55_d10_supports(args ...ruby.Value) ruby.Value {
	return shell_spec_bool((shell_utils.shell_from_path('zsh-5.2') or { '' }) == 'zsh')
}

// Ruby it `it "strips newlines" do` at line 59.
pub fn ruby_shell_spec_l59_d11_strips(args ...ruby.Value) ruby.Value {
	return shell_spec_bool((shell_utils.shell_from_path('zsh-5.2\n') or { '' }) == 'zsh')
}

// Ruby it `it "returns nil when input is invalid" do` at line 63.
pub fn ruby_shell_spec_l63_d12_returns(args ...ruby.Value) ruby.Value {
	return shell_spec_bool(shell_utils.shell_from_path('') == none && shell_utils.shell_from_path('@@@@@@') == none && shell_utils.shell_from_path('invalid_shell-4.2') == none)
}

// Ruby specify `specify "::sh_quote" do` at line 70.
pub fn ruby_shell_spec_l70_d13_sh_quote(args ...ruby.Value) ruby.Value {
	return shell_spec_bool(shell_utils.shell_sh_quote('') == "''" && shell_utils.shell_sh_quote('\\') == '\\\\' && shell_utils.shell_sh_quote('\n') == "'\n'" && shell_utils.shell_sh_quote('\$') == '\\\$' && shell_utils.shell_sh_quote('word') == 'word')
}

// Ruby specify `specify "::csh_quote" do` at line 78.
pub fn ruby_shell_spec_l78_d14_csh_quote(args ...ruby.Value) ruby.Value {
	return shell_spec_bool(shell_utils.shell_csh_quote('') == "''" && shell_utils.shell_csh_quote('\\') == '\\\\' && shell_utils.shell_csh_quote('\n') == "'\\\n'" && shell_utils.shell_csh_quote('\$') == '\\\$' && shell_utils.shell_csh_quote('word') == 'word')
}

// Ruby let `let(:path) { "/my/path" }` at line 88.
pub fn ruby_shell_spec_l88_d15_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value('/my/path')
}

// Ruby it `it "supports tcsh" do` at line 90.
pub fn ruby_shell_spec_l90_d16_supports(args ...ruby.Value) ruby.Value {
	profile := '~/.tcshrc'
	command := shell_utils.shell_prepend_path_in_profile('/my/path', 'tcsh', profile) or { '' }
	return shell_spec_bool(command == "echo 'setenv PATH /my/path:\$PATH' >> ${profile}")
}

// Ruby it `it "supports Bash" do` at line 96.
pub fn ruby_shell_spec_l96_d17_supports(args ...ruby.Value) ruby.Value {
	profile := '~/.profile'
	command := shell_utils.shell_prepend_path_in_profile('/my/path', 'bash', profile) or { '' }
	return shell_spec_bool(command == 'echo \'export PATH="/my/path:\$PATH"\' >> ${profile}')
}

// Ruby it `it "supports fish" do` at line 102.
pub fn ruby_shell_spec_l102_d18_supports(args ...ruby.Value) ruby.Value {
	return shell_spec_bool((shell_utils.shell_prepend_path_in_profile('/my/path', 'fish', '~/.config/fish/config.fish') or {
		''
	}) == 'fish_add_path /my/path')
}

// Ruby it `it "supports mksh" do` at line 111.
pub fn ruby_shell_spec_l111_d19_supports(args ...ruby.Value) ruby.Value {
	profile := '~/.kshrc'
	command := shell_utils.shell_set_variable_in_profile('HOMEBREW_FOO', 'bar', 'mksh', profile) or {
		''
	}
	return shell_spec_bool(command == "echo 'export HOMEBREW_FOO=bar' >> ${profile}")
}

// Ruby let `let(:home) { HOMEBREW_TEMP }` at line 119.
pub fn ruby_shell_spec_l119_d20_home(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.temp_dir())
}

// Ruby let `let(:notice) { "" }` at line 120.
pub fn ruby_shell_spec_l120_d21_notice(args ...ruby.Value) ruby.Value {
	return ruby.string_value('')
}

// Ruby let `let(:prompt) { "test" }` at line 121.
pub fn ruby_shell_spec_l121_d22_prompt(args ...ruby.Value) ruby.Value {
	return ruby.string_value('test')
}

// Ruby let `let(:path) { "/some/path" }` at line 122.
pub fn ruby_shell_spec_l122_d23_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value('/some/path')
}

// Ruby it `it "returns zsh-specific prompt configuration" do` at line 124.
pub fn ruby_shell_spec_l124_d24_returns(args ...ruby.Value) ruby.Value {
	root := shell_spec_root('zsh-prompt')
	defer { os.rmdir_all(root) or {} }
	library := os.join_path(root, 'Library', 'Homebrew')
	source := os.join_path(library, 'utils', 'zsh', 'brew-sh-prompt-zshrc.zsh')
	os.mkdir_all(os.dir(source)) or { return shell_spec_bool(false) }
	os.write_file(source, '# prompt\n') or { return shell_spec_bool(false) }
	home := os.join_path(root, 'home')
	os.mkdir_all(home) or { return shell_spec_bool(false) }
	plan := shell_utils.shell_prompt_plan('test', shell_utils.ShellPromptOptions{
		preferred_path: '/bin/zsh'
		home: home
		path: '/some/path'
		temporary: root
		library_path: library
	}) or { return shell_spec_bool(false) }
	zdotdir := os.join_path(root, 'brew-zsh-prompt-${os.geteuid()}')
	return shell_spec_bool(plan.command == 'BREW_PROMPT_PATH="/some/path" BREW_PROMPT_TYPE="test" ZDOTDIR="${zdotdir}" /bin/zsh' && os.is_file(os.join_path(zdotdir, '.zshrc')) && os.is_link(os.join_path(zdotdir, '.zshenv')))
}

// Ruby it `it "returns bash-specific prompt configuration" do` at line 133.
pub fn ruby_shell_spec_l133_d25_returns(args ...ruby.Value) ruby.Value {
	library := '/brew/Library/Homebrew'
	plan := shell_utils.shell_prompt_plan('test', shell_utils.ShellPromptOptions{
		preferred_path: '/bin/bash'
		path: '/some/path'
		library_path: library
	}) or { return shell_spec_bool(false) }
	return shell_spec_bool(plan.command == 'BREW_PROMPT_PATH="/some/path" BREW_PROMPT_TYPE="test" /bin/bash --rcfile "${library}/utils/bash/brew-sh-prompt-bashrc.bash"')
}

// Ruby it `it "returns generic shell prompt configuration" do` at line 142.
pub fn ruby_shell_spec_l142_d26_returns(args ...ruby.Value) ruby.Value {
	plan := shell_utils.shell_prompt_plan('test', shell_utils.ShellPromptOptions{
		preferred_path: '/bin/dash'
		path: '/some/path'
	}) or { return shell_spec_bool(false) }
	return shell_spec_bool(plan.command == 'PS1="\\[\\033[1;32m\\]test \\[\\033[1;31m\\]\\w \\[\\033[1;34m\\]\$\\[\\033[0m\\] " /bin/dash')
}

// Ruby it `it "outputs notice when provided" do` at line 149.
pub fn ruby_shell_spec_l149_d27_outputs(args ...ruby.Value) ruby.Value {
	plan := shell_utils.shell_prompt_plan('test', shell_utils.ShellPromptOptions{
		preferred_path: '/bin/bash'
		path: '/some/path'
		library_path: '/brew/Library/Homebrew'
		notice: 'Test Notice'
	}) or { return shell_spec_bool(false) }
	return shell_spec_bool(plan.notice == 'Test Notice')
}

fn shell_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn shell_spec_root(name string) string {
	root := os.join_path(os.temp_dir(), 'brew-v-shell-spec-${name}')
	os.rmdir_all(root) or {}
	os.mkdir_all(root) or { panic(err) }
	return root
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/shell"
// 5:
// 6: RSpec.describe Utils::Shell do
// 7:   describe "::profile" do
// 8:     it "returns ~/.profile by default" do
// 9:       ENV["SHELL"] = "/bin/another_shell"
// 10:       expect(described_class.profile).to eq("~/.profile")
// 11:     end
// 12:
// 13:     it "returns ~/.profile for sh" do
// 14:       ENV["SHELL"] = "/bin/sh"
// 15:       expect(described_class.profile).to eq("~/.profile")
// 16:     end
// 17:
// 18:     it "returns ~/.profile for Bash" do
// 19:       ENV["SHELL"] = "/bin/bash"
// 20:       expect(described_class.profile).to eq("~/.profile")
// 21:     end
// 22:
// 23:     it "returns /tmp/.zshrc for Zsh if ZDOTDIR is /tmp" do
// 24:       ENV["SHELL"] = "/bin/zsh"
// 25:       ENV["HOMEBREW_ZDOTDIR"] = "/tmp"
// 26:       expect(described_class.profile).to eq("/tmp/.zshrc")
// 27:     end
// 28:
// 29:     it "returns ~/.zshrc for Zsh" do
// 30:       ENV["SHELL"] = "/bin/zsh"
// 31:       ENV["HOMEBREW_ZDOTDIR"] = nil
// 32:       expect(described_class.profile).to eq("~/.zshrc")
// 33:     end
// 34:
// 35:     it "returns ~/.kshrc for Ksh" do
// 36:       ENV["SHELL"] = "/bin/ksh"
// 37:       expect(described_class.profile).to eq("~/.kshrc")
// 38:     end
// 39:
// 40:     it "returns ~/.config/powershell/Microsoft.PowerShell_profile.ps1 for PowerShell" do
// 41:       ENV["SHELL"] = "/usr/bin/pwsh"
// 42:       expect(described_class.profile).to eq("~/.config/powershell/Microsoft.PowerShell_profile.ps1")
// 43:     end
// 44:   end
// 45:
// 46:   describe "::from_path" do
// 47:     it "supports a raw command name" do
// 48:       expect(described_class.from_path("bash")).to eq(:bash)
// 49:     end
// 50:
// 51:     it "supports full paths" do
// 52:       expect(described_class.from_path("/bin/bash")).to eq(:bash)
// 53:     end
// 54:
// 55:     it "supports versions" do
// 56:       expect(described_class.from_path("zsh-5.2")).to eq(:zsh)
// 57:     end
// 58:
// 59:     it "strips newlines" do
// 60:       expect(described_class.from_path("zsh-5.2\n")).to eq(:zsh)
// 61:     end
// 62:
// 63:     it "returns nil when input is invalid" do
// 64:       expect(described_class.from_path("")).to be_nil
// 65:       expect(described_class.from_path("@@@@@@")).to be_nil
// 66:       expect(described_class.from_path("invalid_shell-4.2")).to be_nil
// 67:     end
// 68:   end
// 69:
// 70:   specify "::sh_quote" do
// 71:     expect(described_class.sh_quote("")).to eq("''")
// 72:     expect(described_class.sh_quote("\\")).to eq("\\\\")
// 73:     expect(described_class.sh_quote("\n")).to eq("'\n'")
// 74:     expect(described_class.sh_quote("$")).to eq("\\$")
// 75:     expect(described_class.sh_quote("word")).to eq("word")
// 76:   end
// 77:
// 78:   specify "::csh_quote" do
// 79:     expect(described_class.csh_quote("")).to eq("''")
// 80:     expect(described_class.csh_quote("\\")).to eq("\\\\")
// 81:     # NOTE: This test is different than for `sh`.
// 82:     expect(described_class.csh_quote("\n")).to eq("'\\\n'")
// 83:     expect(described_class.csh_quote("$")).to eq("\\$")
// 84:     expect(described_class.csh_quote("word")).to eq("word")
// 85:   end
// 86:
// 87:   describe "::prepend_path_in_profile" do
// 88:     let(:path) { "/my/path" }
// 89:
// 90:     it "supports tcsh" do
// 91:       ENV["SHELL"] = "/bin/tcsh"
// 92:       expect(described_class.prepend_path_in_profile(path))
// 93:         .to eq("echo 'setenv PATH #{path}:$PATH' >> #{described_class.profile}")
// 94:     end
// 95:
// 96:     it "supports Bash" do
// 97:       ENV["SHELL"] = "/bin/bash"
// 98:       expect(described_class.prepend_path_in_profile(path))
// 99:         .to eq("echo 'export PATH=\"#{path}:$PATH\"' >> #{described_class.profile}")
// 100:     end
// 101:
// 102:     it "supports fish" do
// 103:       ENV["SHELL"] = "/usr/local/bin/fish"
// 104:       ENV["fish_user_paths"] = "/some/path"
// 105:       expect(described_class.prepend_path_in_profile(path))
// 106:         .to eq("fish_add_path #{path}")
// 107:     end
// 108:   end
// 109:
// 110:   describe "::set_variable_in_profile" do
// 111:     it "supports mksh" do
// 112:       ENV["SHELL"] = "/bin/mksh"
// 113:       expect(described_class.set_variable_in_profile("HOMEBREW_FOO", "bar"))
// 114:         .to eq("echo 'export HOMEBREW_FOO=bar' >> #{described_class.profile}")
// 115:     end
// 116:   end
// 117:
// 118:   describe "::shell_with_prompt" do
// 119:     let(:home) { HOMEBREW_TEMP }
// 120:     let(:notice) { "" }
// 121:     let(:prompt) { "test" }
// 122:     let(:path) { "/some/path" }
// 123:
// 124:     it "returns zsh-specific prompt configuration" do
// 125:       preferred_path = "/bin/zsh"
// 126:       ENV["SHELL"] = preferred_path
// 127:       ENV["PATH"] = path
// 128:       zdotdir = "#{HOMEBREW_TEMP}/brew-zsh-prompt-#{Process.euid}"
// 129:       expect(described_class.shell_with_prompt(prompt, preferred_path:, notice:, home:)).to eq \
// 130:         "BREW_PROMPT_PATH=\"#{path}\" BREW_PROMPT_TYPE=\"#{prompt}\" ZDOTDIR=\"#{zdotdir}\" #{preferred_path}"
// 131:     end
// 132:
// 133:     it "returns bash-specific prompt configuration" do
// 134:       preferred_path = "/bin/bash"
// 135:       ENV["SHELL"] = "/bin/bash"
// 136:       ENV["PATH"] = path
// 137:       rcfile = "#{HOMEBREW_LIBRARY_PATH}/utils/bash/brew-sh-prompt-bashrc.bash"
// 138:       expect(described_class.shell_with_prompt(prompt, preferred_path:, notice:, home:)).to eq \
// 139:         "BREW_PROMPT_PATH=\"#{path}\" BREW_PROMPT_TYPE=\"#{prompt}\" #{preferred_path} --rcfile \"#{rcfile}\""
// 140:     end
// 141:
// 142:     it "returns generic shell prompt configuration" do
// 143:       preferred_path = "/bin/dash"
// 144:       ENV["SHELL"] = preferred_path
// 145:       expect(described_class.shell_with_prompt(prompt, preferred_path:, notice:, home:)).to eq \
// 146:         "PS1=\"\\[\\033[1;32m\\]#{prompt} \\[\\033[1;31m\\]\\w \\[\\033[1;34m\\]$\\[\\033[0m\\] \" #{preferred_path}"
// 147:     end
// 148:
// 149:     it "outputs notice when provided" do
// 150:       notice = "Test Notice"
// 151:       expect { described_class.shell_with_prompt("test", preferred_path: "/bin/bash", notice: notice) }
// 152:         .to output("#{notice}\n").to_stdout
// 153:     end
// 154:   end
// 155: end
