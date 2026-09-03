module test

import homebrew
import homebrew.tap as tap_config
import os
import x.json2

// Translated from Homebrew/brew `test/tap_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct TapSpecFiles {
pub:
	path                 string
	formula_file         string
	alias_file           string
	command_file         string
	manpage_file         string
	bash_completion_file string
	zsh_completion_file  string
	fish_completion_file string
}

fn tap_spec_files(path string) TapSpecFiles {
	return TapSpecFiles{
		path: path
		formula_file: os.join_path(path, 'Formula', 'foo.rb')
		alias_file: os.join_path(path, 'Aliases', 'bar')
		command_file: os.join_path(path, 'cmd', 'brew-tap-cmd.rb')
		manpage_file: os.join_path(path, 'manpages', 'brew-tap-cmd.1')
		bash_completion_file: os.join_path(path, 'completions', 'bash', 'brew-tap-cmd')
		zsh_completion_file: os.join_path(path, 'completions', 'zsh', '_brew-tap-cmd')
		fish_completion_file: os.join_path(path, 'completions', 'fish', 'brew-tap-cmd.fish')
	}
}

fn tap_spec_write(path string, contents string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
}

pub fn tap_spec_setup_files(path string) !TapSpecFiles {
	files := tap_spec_files(path)
	tap_spec_write(files.formula_file, 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\nend\n')!
	os.mkdir_all(os.dir(files.alias_file))!
	os.symlink(files.formula_file, files.alias_file)!
	tap_spec_write(os.join_path(path, 'formula_renames.json'), '{ "oldname": "foo" }\n')!
	tap_spec_write(os.join_path(path, 'tap_migrations.json'), '{ "removed-formula": "homebrew/foo" }\n')!
	for directory in ['audit_exceptions', 'style_exceptions'] {
		tap_spec_write(os.join_path(path, directory, 'formula_list.json'), '[ "foo", "bar" ]\n')!
		tap_spec_write(os.join_path(path, directory, 'formula_hash.json'), '{ "foo": "foo1", "bar": "bar1" }\n')!
	}
	for file in [files.command_file, files.manpage_file, files.bash_completion_file,
		files.zsh_completion_file, files.fish_completion_file] {
		tap_spec_write(file, '')!
	}
	os.chmod(files.command_file, 0o755)!
	return files
}

pub fn tap_spec_setup_git_repo(path string, remote string) !homebrew.GitRepository {
	os.mkdir_all(path)!
	for arguments in [['init'], ['remote', 'add', 'origin', remote]] {
		result := os.execute_opt('git -C ${os.quoted_path(path)} ${arguments.join(' ')}')!
		if result.exit_code != 0 {
			return error(result.output)
		}
	}
	return homebrew.new_git_repository(path)
}

fn tap_spec_install_request(tap homebrew.TapReference) homebrew.TapInstallRequest {
	return homebrew.TapInstallRequest{
		tap: tap
		path: '/tmp/taps/${tap.full_name.to_lower()}'
		allowed: true
		readall_valid: true
	}
}

fn tap_spec_redirect_request(tap homebrew.TapReference, redirected string) homebrew.TapRedirectRequest {
	return homebrew.TapRedirectRequest{
		tap: tap
		tap_path: '/tmp/Taps/${tap.full_name.to_lower()}'
		redirected_remote: redirected
		allowed: true
		trust_invalidated: true
	}
}

// Ruby subject `subject(:homebrew_foo_tap) { described_class.fetch("Homebrew", "foo") }` at line 5.
pub fn ruby_tap_spec_l5_d1_homebrew_foo_tap() !homebrew.TapReference {
	return homebrew.new_tap_reference('Homebrew/foo', '')
}

// Ruby let `let(:path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo" }` at line 7.
pub fn ruby_tap_spec_l7_d2_path(tap_directory string) string {
	return os.join_path(tap_directory, 'homebrew', 'homebrew-foo')
}

// Ruby let `let(:formula_file) { path/"Formula/foo.rb" }` at line 8.
pub fn ruby_tap_spec_l8_d3_formula_file(path string) string {
	return os.join_path(path, 'Formula', 'foo.rb')
}

// Ruby let `let(:alias_file) { path/"Aliases/bar" }` at line 9.
pub fn ruby_tap_spec_l9_d4_alias_file(path string) string {
	return os.join_path(path, 'Aliases', 'bar')
}

// Ruby let `let(:cmd_file) { path/"cmd/brew-tap-cmd.rb" }` at line 10.
pub fn ruby_tap_spec_l10_d5_cmd_file(path string) string {
	return os.join_path(path, 'cmd', 'brew-tap-cmd.rb')
}

// Ruby let `let(:manpage_file) { path/"manpages/brew-tap-cmd.1" }` at line 11.
pub fn ruby_tap_spec_l11_d6_manpage_file(path string) string {
	return os.join_path(path, 'manpages', 'brew-tap-cmd.1')
}

// Ruby let `let(:bash_completion_file) { path/"completions/bash/brew-tap-cmd" }` at line 12.
pub fn ruby_tap_spec_l12_d7_bash_completion_file(path string) string {
	return os.join_path(path, 'completions', 'bash', 'brew-tap-cmd')
}

// Ruby let `let(:zsh_completion_file) { path/"completions/zsh/_brew-tap-cmd" }` at line 13.
pub fn ruby_tap_spec_l13_d8_zsh_completion_file(path string) string {
	return os.join_path(path, 'completions', 'zsh', '_brew-tap-cmd')
}

// Ruby let `let(:fish_completion_file) { path/"completions/fish/brew-tap-cmd.fish" }` at line 14.
pub fn ruby_tap_spec_l14_d9_fish_completion_file(path string) string {
	return os.join_path(path, 'completions', 'fish', 'brew-tap-cmd.fish')
}

// Ruby alias_matcher `alias_matcher :have_cask_file, :be_cask_file` at line 18.
pub fn ruby_tap_spec_l18_d10_have_cask_file(file string) bool {
	return homebrew.tap_cask_file(file)
}

// Ruby alias_matcher `alias_matcher :have_formula_file, :be_formula_file` at line 19.
pub fn ruby_tap_spec_l19_d11_have_formula_file(tap homebrew.TapReference, path string,
	file string) !bool {
	return homebrew.tap_formula_file(tap, path, file)
}

// Ruby alias_matcher `alias_matcher :have_custom_remote, :be_custom_remote` at line 20.
pub fn ruby_tap_spec_l20_d12_have_custom_remote(tap homebrew.TapReference) bool {
	return tap.custom_remote()
}

// Ruby method `setup_tap_files` at line 31.
pub fn ruby_tap_spec_l31_d13_setup_tap_files(path string) !TapSpecFiles {
	return tap_spec_setup_files(path)
}

// Ruby method `setup_git_repo` at line 76.
pub fn ruby_tap_spec_l76_d14_setup_git_repo(path string) !homebrew.GitRepository {
	return tap_spec_setup_git_repo(path, 'https://github.com/Homebrew/homebrew-foo')
}

// Ruby method `setup_completion(link:)` at line 85.
pub fn ruby_tap_spec_l85_d15_setup_completion(link bool) bool {
	return link
}

// Ruby specify `specify "::fetch" do` at line 98.
pub fn ruby_tap_spec_l98_d16_fetch() !bool {
	core := homebrew.new_tap_reference('Homebrew/core', '')!
	homebrew_name := homebrew.new_tap_reference('Homebrew/homebrew', '')!
	foo := homebrew.new_tap_reference('Homebrew/foo', '')!
	if core.name != 'homebrew/core' || homebrew_name.name != 'homebrew/core' || foo.name != 'homebrew/foo' {
		return false
	}
	for invalid in ['foo', 'homebrew/homebrew/bar', 'homebrew/homebrew/baz'] {
		if _ := homebrew.new_tap_reference(invalid, '') {
			return false
		}
	}
	return true
}

// Ruby let `let(:tap) { described_class.fetch("Homebrew", "core") }` at line 119.
pub fn ruby_tap_spec_l119_d17_tap() !homebrew.TapReference {
	return homebrew.new_tap_reference('Homebrew/core', '')
}

// Ruby let `let(:path) { tap.path }` at line 120.
pub fn ruby_tap_spec_l120_d18_path(tap_directory string) !string {
	return homebrew.tap_path(homebrew.new_tap_reference('Homebrew/core', '')!, tap_directory)
}

// Ruby let `let(:formula_path) { path/"Formula/formula.rb" }` at line 121.
pub fn ruby_tap_spec_l121_d19_formula_path(path string) string {
	return os.join_path(path, 'Formula', 'formula.rb')
}

// Ruby it `it "returns the Tap for a Formula path" do` at line 123.
pub fn ruby_tap_spec_l123_d20_returns(tap_directory string) !bool {
	tap := homebrew.new_tap_reference('Homebrew/core', '')!
	path := homebrew.tap_path(tap, tap_directory)
	found := homebrew.tap_from_path(os.join_path(path, 'Formula', 'formula.rb'), tap_directory) or {
		return false
	}
	return found.name == tap.name
}

// Ruby it `it "returns the Tap when given its exact path" do` at line 127.
pub fn ruby_tap_spec_l127_d21_returns(tap_directory string) !bool {
	tap := homebrew.new_tap_reference('Homebrew/core', '')!
	found := homebrew.tap_from_path(homebrew.tap_path(tap, tap_directory), tap_directory) or {
		return false
	}
	return found.name == tap.name
}

// Ruby let `let(:tap) { described_class.fetch("str4d.xyz", "rage") }` at line 132.
pub fn ruby_tap_spec_l132_d22_tap() !homebrew.TapReference {
	return homebrew.new_tap_reference('str4d.xyz/rage', '')
}

// Ruby it `it "returns the Tap when given its exact path" do` at line 138.
pub fn ruby_tap_spec_l138_d23_returns(tap_directory string) !bool {
	tap := homebrew.new_tap_reference('str4d.xyz/rage', '')!
	found := homebrew.tap_from_path(homebrew.tap_path(tap, tap_directory), tap_directory) or {
		return false
	}
	return found.name == tap.name
}

// Ruby it `it "returns the references from the environment" do` at line 147.
pub fn ruby_tap_spec_l147_d24_returns() bool {
	return homebrew.tap_list_references('homebrew/allowed', 'HOMEBREW_ALLOWED_TAPS') == [
		'homebrew/allowed',
	]
}

// Ruby it `it "normalises a `user/homebrew-repository` entry to a canonical tap name" do` at line 151.
pub fn ruby_tap_spec_l151_d25_normalises() bool {
	return homebrew.tap_list_references('User/homebrew-Repo', 'HOMEBREW_ALLOWED_TAPS') == [
		'user/repo',
	]
}

// Ruby it `it "preserves a remote URL entry verbatim" do` at line 156.
pub fn ruby_tap_spec_l156_d26_preserves() bool {
	return homebrew.tap_list_references('https://gitlab.com/other/repo', 'HOMEBREW_ALLOWED_TAPS') == [
		'https://gitlab.com/other/repo',
	]
}

// Ruby it `it "warns about and ignores an invalid tap name" do` at line 161.
pub fn ruby_tap_spec_l161_d27_warns() bool {
	return homebrew.tap_list_references('not-a-tap', 'HOMEBREW_ALLOWED_TAPS').len == 0
}

// Ruby it `it "returns the references from the environment" do` at line 170.
pub fn ruby_tap_spec_l170_d28_returns() bool {
	return homebrew.tap_list_references('homebrew/forbidden', 'HOMEBREW_FORBIDDEN_TAPS') == [
		'homebrew/forbidden',
	]
}

// Ruby it `it "recognises scp-like syntax without a `user@`" do` at line 176.
pub fn ruby_tap_spec_l176_d29_recognises() bool {
	return homebrew.tap_remote_reference('ssh_host:/srv/git/homebrew-custom_tap')
}

// Ruby it `it "recognises scp-like syntax with a `user@`" do` at line 180.
pub fn ruby_tap_spec_l180_d30_recognises() bool {
	return homebrew.tap_remote_reference('git@github.com:user/homebrew-repo')
}

// Ruby it `it "treats a `user/repository` tap name as not a remote reference" do` at line 184.
pub fn ruby_tap_spec_l184_d31_treats() bool {
	return !homebrew.tap_remote_reference('user/repo')
}

// Ruby it `it "treats a bare `@`-containing string as not a remote reference" do` at line 188.
pub fn ruby_tap_spec_l188_d32_treats() bool {
	return !homebrew.tap_remote_reference('foo@bar')
}

// Ruby it `it "treats a `host:` with an empty path as not a remote reference" do` at line 192.
pub fn ruby_tap_spec_l192_d33_treats() bool {
	return !homebrew.tap_remote_reference('host:')
}

// Ruby it `it "keeps an explicit port on a GitHub remote rather than turning it into a path" do` at line 198.
pub fn ruby_tap_spec_l198_d34_keeps() bool {
	return (homebrew.normalize_tap_remote('https://github.com:443/Homebrew/homebrew-core') or { return false }) == 'https://github.com:443/homebrew/homebrew-core'
}

// Ruby it `it "ignores a GitHub `.git` suffix, trailing slash and case" do` at line 205.
pub fn ruby_tap_spec_l205_d35_ignores() bool {
	return homebrew.same_tap_remote('https://github.com/Homebrew/homebrew-core.git/', 'https://github.com/homebrew/homebrew-core')
}

// Ruby it `it "ignores a `.git` suffix on GitLab remotes" do` at line 210.
pub fn ruby_tap_spec_l210_d36_ignores() bool {
	return homebrew.same_tap_remote('https://gitlab.com/other/repo.git', 'https://gitlab.com/other/repo')
}

// Ruby it `it "ignores a trailing slash on GitLab remotes" do` at line 215.
pub fn ruby_tap_spec_l215_d37_ignores() bool {
	return homebrew.same_tap_remote('https://gitlab.com/other/repo/', 'https://gitlab.com/other/repo')
}

// Ruby it `it "keeps a `.git` suffix and trailing slash significant on a self-hosted remote" do` at line 220.
pub fn ruby_tap_spec_l220_d38_keeps() bool {
	return !homebrew.same_tap_remote('https://git.example.com/other/repo.git/', 'https://git.example.com/other/repo')
}

// Ruby it `it "still matches non-GitHub remotes case-insensitively" do` at line 225.
pub fn ruby_tap_spec_l225_d39_still() bool {
	return homebrew.same_tap_remote('https://gitlab.com/other/repo', 'https://GitLab.com/Other/Repo')
}

// Ruby it `it "keeps non-GitHub remotes with different paths distinct" do` at line 230.
pub fn ruby_tap_spec_l230_d40_keeps() bool {
	return !homebrew.same_tap_remote('https://gitlab.com/other/repo', 'https://gitlab.com/other/other-repo')
}

// Ruby it `it "treats a GitHub SSH SCP remote the same as HTTPS" do` at line 235.
pub fn ruby_tap_spec_l235_d41_treats() bool {
	return homebrew.same_tap_remote('git@github.com:Homebrew/homebrew-core', 'https://github.com/Homebrew/homebrew-core')
}

// Ruby it `it "treats a GitHub ssh:// remote the same as HTTPS" do` at line 240.
pub fn ruby_tap_spec_l240_d42_treats() bool {
	return homebrew.same_tap_remote('ssh://git@github.com/Homebrew/homebrew-core', 'https://github.com/Homebrew/homebrew-core')
}

// Ruby it `it "treats a GitHub git:// remote the same as HTTPS" do` at line 245.
pub fn ruby_tap_spec_l245_d43_treats() bool {
	return homebrew.same_tap_remote('git://github.com/Homebrew/homebrew-core', 'https://github.com/Homebrew/homebrew-core')
}

// Ruby it `it "treats a GitHub SSH SCP remote with .git suffix the same as HTTPS" do` at line 250.
pub fn ruby_tap_spec_l250_d44_treats() bool {
	return homebrew.same_tap_remote('git@github.com:Homebrew/homebrew-core.git', 'https://github.com/Homebrew/homebrew-core')
}

// Ruby it `it "keeps a different host distinct" do` at line 255.
pub fn ruby_tap_spec_l255_d45_keeps() bool {
	return !homebrew.same_tap_remote('https://evil.example/Homebrew/homebrew-core', 'https://github.com/Homebrew/homebrew-core')
}

// Ruby let `let(:tap) { described_class.fetch("user", "repo") }` at line 262.
pub fn ruby_tap_spec_l262_d46_tap() !homebrew.TapReference {
	return homebrew.new_tap_reference('user/repo', '')
}

// Ruby it `it "matches a default-remote tap by its name" do` at line 264.
pub fn ruby_tap_spec_l264_d47_matches() !bool {
	tap := homebrew.new_tap_reference('user/repo', 'https://github.com/user/homebrew-repo')!
	return tap.matches_reference('user/repo')
}

// Ruby it `it "matches a default-remote tap whose remote has a `.git` suffix" do` at line 268.
pub fn ruby_tap_spec_l268_d48_matches() !bool {
	tap := homebrew.new_tap_reference('user/repo', 'https://github.com/user/homebrew-repo.git')!
	return tap.matches_reference('user/repo')
}

// Ruby it `it "does not match a custom-remote tap by its name" do` at line 272.
pub fn ruby_tap_spec_l272_d49_does() !bool {
	tap := homebrew.new_tap_reference('user/repo', 'https://gitlab.com/other/repo')!
	return !tap.matches_reference('user/repo')
}

// Ruby it `it "matches a custom-remote tap by its remote URL" do` at line 276.
pub fn ruby_tap_spec_l276_d50_matches() !bool {
	tap := homebrew.new_tap_reference('user/repo', 'https://gitlab.com/other/repo')!
	return tap.matches_reference('https://gitlab.com/other/repo')
}

// Ruby it `it "matches a tap by its local path remote" do` at line 281.
pub fn ruby_tap_spec_l281_d51_matches() !bool {
	tap := homebrew.new_tap_reference('user/repo', '/Users/me/homebrew-tap')!
	return tap.matches_reference('/Users/me/homebrew-tap')
}

// Ruby it `it "matches a GitHub SSH-remote tap by its name" do` at line 285.
pub fn ruby_tap_spec_l285_d52_matches() !bool {
	tap := homebrew.new_tap_reference('user/repo', 'git@github.com:user/homebrew-repo')!
	return tap.matches_reference('user/repo')
}

// Ruby it `it "matches a GitHub SSH-remote tap by its HTTPS URL reference" do` at line 289.
pub fn ruby_tap_spec_l289_d53_matches() !bool {
	tap := homebrew.new_tap_reference('user/repo', 'git@github.com:user/homebrew-repo')!
	return tap.matches_reference('https://github.com/user/homebrew-repo')
}

// Ruby it `it "does not allow a name-matched tap fetched from a custom remote" do` at line 298.
pub fn ruby_tap_spec_l298_d54_does() !bool {
	tap := homebrew.new_tap_reference('user/repo', 'https://evil.example/repo')!
	return !tap.allowed_by_references(['user/repo'])
}

// Ruby it `it "does not implicitly allow an official tap fetched from a custom remote" do` at line 302.
pub fn ruby_tap_spec_l302_d55_does() !bool {
	tap := homebrew.new_tap_reference('Homebrew/foo', 'https://evil.example/repo')!
	return !tap.allowed_by_references(['user/repo'])
}

// Ruby it `it "is true for an official tap on its default remote" do` at line 309.
pub fn ruby_tap_spec_l309_d56_is() !bool {
	tap := homebrew.new_tap_reference('Homebrew/foo', 'https://github.com/Homebrew/homebrew-foo')!
	return tap.implicitly_trusted()
}

// Ruby it `it "is false for an official tap on a custom remote" do` at line 314.
pub fn ruby_tap_spec_l314_d57_is() !bool {
	tap := homebrew.new_tap_reference('Homebrew/foo', 'https://evil.example/repo')!
	return !tap.implicitly_trusted()
}

// Ruby it `it "is true for homebrew/core in API mode regardless of remote" do` at line 319.
pub fn ruby_tap_spec_l319_d58_is() bool {
	return homebrew.tap_core_implicitly_trusted('https://evil.example/core', false, 'https://github.com/Homebrew/homebrew-core')
}

// Ruby it `it "is true for a homebrew/core Git checkout whose remote has a `.git` suffix" do` at line 325.
pub fn ruby_tap_spec_l325_d59_is() bool {
	return homebrew.tap_core_implicitly_trusted('https://github.com/Homebrew/homebrew-core.git', true, 'https://github.com/Homebrew/homebrew-core')
}

// Ruby it `it "is false for a homebrew/core Git checkout from a non-official remote" do` at line 332.
pub fn ruby_tap_spec_l332_d60_is() bool {
	return !homebrew.tap_core_implicitly_trusted('https://evil.example/core', true, 'https://github.com/Homebrew/homebrew-core')
}

// Ruby it `it "accepts the configured HOMEBREW_CORE_GIT_REMOTE as official" do` at line 338.
pub fn ruby_tap_spec_l338_d61_accepts() bool {
	return homebrew.tap_core_implicitly_trusted('https://mirror.example/core', true, 'https://mirror.example/core')
}

// Ruby it `it "forbids any locally-named tap fetched from a forbidden remote URL" do` at line 348.
pub fn ruby_tap_spec_l348_d62_forbids() !bool {
	tap := homebrew.new_tap_reference('notevil/tap', 'https://github.com/evil/homebrew-tap')!
	return tap.forbidden_by_references(['https://github.com/evil/homebrew-tap'])
}

// Ruby specify `specify "attributes" do` at line 354.
pub fn ruby_tap_spec_l354_d63_attributes(tap_directory string) !bool {
	tap := homebrew.new_tap_reference('Homebrew/foo', '')!
	path := homebrew.tap_path(tap, tap_directory)
	return tap.user == 'Homebrew' && tap.repository == 'foo' && tap.name == 'homebrew/foo' && path == os.join_path(tap_directory, 'homebrew', 'homebrew-foo') && homebrew.ruby_tap_l515_d36_installed(path) && tap.official() && !homebrew.ruby_tap_l526_d38_core_tap()
}

// Ruby specify `specify "#issues_url" do` at line 364.
pub fn ruby_tap_spec_l364_d64_issues_url() !bool {
	custom := homebrew.new_tap_reference('someone/foo', 'https://github.com/someone/homebrew-foo')!
	official := homebrew.new_tap_reference('Homebrew/foo', '')!
	local := homebrew.new_tap_reference('someone/no-git', '')!
	return homebrew.ruby_tap_l463_d32_issues_url(custom) or { '' } == 'https://github.com/someone/homebrew-foo/issues' && homebrew.ruby_tap_l463_d32_issues_url(official) or { '' } == 'https://github.com/Homebrew/homebrew-foo/issues' && homebrew.ruby_tap_l463_d32_issues_url(homebrew.TapReference{
		...local
		remote: ''
	}) == none
}

// Ruby specify `specify "files" do` at line 382.
pub fn ruby_tap_spec_l382_d65_files(path string) !bool {
	files := tap_spec_setup_files(path)!
	tap := homebrew.new_tap_reference('Homebrew/foo', 'https://github.com/Homebrew/homebrew-foo')!
	formula_files := homebrew.tap_formula_files(tap, path)
	aliases := homebrew.tap_alias_files(path)
	command_files := homebrew.tap_command_files(path)
	table := homebrew.tap_alias_table(tap, aliases)
	formula_names := homebrew.tap_formula_names(tap, formula_files)
	hash := homebrew.tap_hash(tap, path, true, true, false, formula_names, [], formula_files, [], command_files, 'abc123', '1 day ago', 'main')
	return formula_files == [files.formula_file] && homebrew.tap_formula_names(tap, formula_files) == [
		'homebrew/foo/foo',
	] && aliases == [files.alias_file] && table.keys() == ['homebrew/foo/bar'] && table['homebrew/foo/bar'] == 'homebrew/foo/foo' && homebrew.tap_reverse_table(table)['homebrew/foo/foo'] == [
		'homebrew/foo/bar',
	] && homebrew.ruby_tap_l1241_d78_formula_renames(path)['oldname'] == 'foo' && homebrew.ruby_tap_l1263_d80_tap_migrations(path)['removed-formula'] == 'homebrew/foo' && command_files == [
		files.command_file,
	] && hash.name == 'homebrew/foo' && hash.user == 'Homebrew' && hash.repo == 'foo' && hash.repository == 'foo' && hash.path == path && hash.installed && hash.official && hash.trusted && hash.formula_names == formula_names && hash.cask_tokens == [] && hash.formula_files == formula_files && hash.cask_files == [] && hash.command_files == command_files && hash.remote == 'https://github.com/Homebrew/homebrew-foo' && !hash.custom_remote && !hash.private && hash.head == 'abc123' && hash.last_commit == '1 day ago' && hash.branch == 'main' && hash.has_install_details && homebrew.tap_formula_file(tap, path, 'Formula/foo.rb')! && !homebrew.tap_formula_file(tap, path, 'bar.rb')! && !homebrew.tap_formula_file(tap, path, 'Formula/baz.sh')!
}

// Ruby it `it "groups versioned full formulae with their matching full formula" do` at line 434.
pub fn ruby_tap_spec_l434_d66_groups() bool {
	groups := homebrew.tap_prefix_to_versioned_formulae_names(['foo@2.0', 'foo-full', 'foo@2.0-full'])
	return groups['foo'] == ['foo@2.0'] && groups['foo-full'] == ['foo@2.0-full']
}

// Ruby it `it "returns the remote URL", :needs_network do` at line 444.
pub fn ruby_tap_spec_l444_d67_returns(path string) !bool {
	repository := tap_spec_setup_git_repo(path, 'https://github.com/Homebrew/homebrew-foo')!
	remote := repository.origin_url()!
	tap := homebrew.new_tap_reference('Homebrew/foo', remote.value)!
	services_path := '${path}-services'
	services_repository := tap_spec_setup_git_repo(services_path, 'https://github.com/Homebrew/homebrew-test-bot')!
	services_remote := services_repository.origin_url()!
	return remote.present && remote.value == 'https://github.com/Homebrew/homebrew-foo' && !tap.custom_remote() && services_remote.present && !homebrew.tap_private(homebrew.TapPrivateQuery{
		github_value: false
	})
}

// Ruby it `it "returns nil if the Tap is not a Git repository" do` at line 459.
pub fn ruby_tap_spec_l459_d68_returns(path string) !bool {
	remote := homebrew.new_git_repository(path).origin_url()!
	return !remote.present
}

// Ruby it `it "reads the remote from .git/config even when Git is unavailable" do` at line 463.
pub fn ruby_tap_spec_l463_d69_reads(path string) !bool {
	repository := tap_spec_setup_git_repo(path, 'https://github.com/Homebrew/homebrew-foo')!
	remote := repository.origin_url_from_config()
	return remote.present && remote.value == 'https://github.com/Homebrew/homebrew-foo'
}

// Ruby it `it "returns the remote https repository" do` at line 471.
pub fn ruby_tap_spec_l471_d70_returns(path string) !bool {
	repository := tap_spec_setup_git_repo(path, 'https://github.com/Homebrew/homebrew-foo')!
	remote := repository.origin_url()!
	remote_repository := homebrew.ruby_tap_l399_d25_remote_repository(homebrew.new_tap_reference('Homebrew/foo', remote.value)!) or { return false }
	services := homebrew.new_tap_reference('Homebrew/test-bot', 'https://github.com/Homebrew/homebrew-bar')!
	services_repository := homebrew.ruby_tap_l399_d25_remote_repository(services) or { return false }
	return remote.present && remote_repository == 'Homebrew/homebrew-foo' && services_repository == 'Homebrew/homebrew-bar'
}

// Ruby it `it "returns the remote ssh repository" do` at line 485.
pub fn ruby_tap_spec_l485_d71_returns(path string) !bool {
	repository := tap_spec_setup_git_repo(path, 'git@github.com:Homebrew/homebrew-foo')!
	remote := repository.origin_url()!
	remote_repository := homebrew.ruby_tap_l399_d25_remote_repository(homebrew.new_tap_reference('Homebrew/foo', remote.value)!) or { return false }
	services := homebrew.new_tap_reference('Homebrew/test-bot', 'git@github.com:Homebrew/homebrew-bar')!
	services_repository := homebrew.ruby_tap_l399_d25_remote_repository(services) or { return false }
	return remote.present && remote_repository == 'Homebrew/homebrew-foo' && services_repository == 'Homebrew/homebrew-bar'
}

// Ruby it `it "returns nil if the Tap is not a Git repository" do` at line 499.
pub fn ruby_tap_spec_l499_d72_returns(path string) !bool {
	return homebrew.ruby_tap_l399_d25_remote_repository(homebrew.TapReference{ remote: '' }) == none
}

// Ruby it `it "reads the remote repository from .git/config even when Git is unavailable" do` at line 503.
pub fn ruby_tap_spec_l503_d73_reads(path string) !bool {
	return ruby_tap_spec_l471_d70_returns(path)
}

// Ruby subject `subject(:tap) { described_class.fetch("Homebrew", "test-bot") }` at line 511.
pub fn ruby_tap_spec_l511_d74_tap() !homebrew.TapReference {
	return homebrew.new_tap_reference('Homebrew/test-bot', '')
}

// Ruby let `let(:remote) { nil }` at line 513.
pub fn ruby_tap_spec_l513_d75_remote() ?string {
	return none
}

// Ruby it `it "returns true" do` at line 522.
pub fn ruby_tap_spec_l522_d76_returns() !bool {
	tap := homebrew.new_tap_reference('Homebrew/test-bot', '')!
	return homebrew.TapReference{ ...tap, remote: '' }.custom_remote()
}

// Ruby let `let(:remote) { "https://github.com/Homebrew/homebrew-test-bot" }` at line 529.
pub fn ruby_tap_spec_l529_d77_remote() string {
	return 'https://github.com/Homebrew/homebrew-test-bot'
}

// Ruby it `it(:custom_remote?) { expect(tap.custom_remote?).to be false }` at line 531.
pub fn ruby_tap_spec_l531_d78_custom_remote() !bool {
	return !homebrew.new_tap_reference('Homebrew/test-bot', ruby_tap_spec_l529_d77_remote())!.custom_remote()
}

// Ruby let `let(:remote) { "https://github.com/Homebrew/homebrew-test-bot.git" }` at line 535.
pub fn ruby_tap_spec_l535_d79_remote() string {
	return 'https://github.com/Homebrew/homebrew-test-bot.git'
}

// Ruby it `it(:custom_remote?) { expect(tap.custom_remote?).to be false }` at line 537.
pub fn ruby_tap_spec_l537_d80_custom_remote() !bool {
	return !homebrew.new_tap_reference('Homebrew/test-bot', ruby_tap_spec_l535_d79_remote())!.custom_remote()
}

// Ruby let `let(:remote) { "git@github.com:Homebrew/homebrew-test-bot" }` at line 541.
pub fn ruby_tap_spec_l541_d81_remote() string {
	return 'git@github.com:Homebrew/homebrew-test-bot'
}

// Ruby it `it(:custom_remote?) { expect(tap.custom_remote?).to be false }` at line 543.
pub fn ruby_tap_spec_l543_d82_custom_remote() !bool {
	return !homebrew.new_tap_reference('Homebrew/test-bot', ruby_tap_spec_l541_d81_remote())!.custom_remote()
}

// Ruby let `let(:remote) { "https://gitlab.com/Homebrew/homebrew-test-bot" }` at line 547.
pub fn ruby_tap_spec_l547_d83_remote() string {
	return 'https://gitlab.com/Homebrew/homebrew-test-bot'
}

// Ruby it `it(:custom_remote?) { expect(tap.custom_remote?).to be true }` at line 549.
pub fn ruby_tap_spec_l549_d84_custom_remote() !bool {
	return homebrew.new_tap_reference('Homebrew/test-bot', ruby_tap_spec_l547_d83_remote())!.custom_remote()
}

// Ruby it `it "moves default GitHub taps to the redirected name and invalidates old trust", :trust_store do` at line 554.
pub fn ruby_tap_spec_l554_d85_moves() !bool {
	tap := homebrew.new_tap_reference('oldowner/foo', 'https://github.com/oldowner/homebrew-foo')!
	plan := homebrew.tap_update_remote_from_redirect('warning: redirecting to https://github.com/newowner/homebrew-foo\n', tap_spec_redirect_request(tap, 'https://github.com/newowner/homebrew-foo'))!
	return plan.changed && plan.tap.name == 'newowner/foo' && plan.move_repository && plan.invalidate_name == 'oldowner/foo' && plan.set_remote.arguments.last() == 'https://github.com/newowner/homebrew-foo'
}

// Ruby it `it "prints tap redirect and untrust messages", :trust_store do` at line 587.
pub fn ruby_tap_spec_l587_d86_prints() !bool {
	tap := homebrew.new_tap_reference('oldoutput/foo', 'https://github.com/oldoutput/homebrew-foo')!
	plan := homebrew.tap_apply_redirect(tap_spec_redirect_request(tap, 'https://github.com/newoutput/homebrew-foo'), 'https://github.com/newoutput/homebrew-foo')!
	return plan.message == 'Redirected tap oldoutput/foo to tap newoutput/foo' && plan.trust_message == 'Untrusted tap: oldoutput/foo'
}

// Ruby it `it "updates the core cask tap remote from a redirect", :trust_store do` at line 608.
pub fn ruby_tap_spec_l608_d87_updates() !bool {
	tap := homebrew.new_tap_reference('Homebrew/cask', 'https://github.com/caskroom/homebrew-cask')!
	mut request := tap_spec_redirect_request(tap, 'https://github.com/Homebrew/homebrew-cask')
	request = homebrew.TapRedirectRequest{ ...request, quiet: true }
	plan := homebrew.tap_update_remote_from_redirect('warning: redirecting to https://github.com/Homebrew/homebrew-cask\n', request)!
	return plan.set_remote.arguments.last() == 'https://github.com/Homebrew/homebrew-cask'
}

// Ruby it `it "refuses an off-allowlist redirect and preserves the original remote" do` at line 626.
pub fn ruby_tap_spec_l626_d88_refuses() !bool {
	tap := homebrew.new_tap_reference('allowed/foo', 'https://allowed.example/homebrew-foo')!
	request := homebrew.TapRedirectRequest{
		...tap_spec_redirect_request(tap, 'https://attacker.example/homebrew-foo')
		allowed: false
		forbidden_owner: 'the owner'
	}
	homebrew.tap_apply_redirect(request, request.redirected_remote) or {
		return err.msg().contains('HOMEBREW_ALLOWED_TAPS')
	}
	return false
}

// Ruby it `it "refuses a redirect to a forbidden tap and preserves the original remote" do` at line 645.
pub fn ruby_tap_spec_l645_d89_refuses() !bool {
	tap := homebrew.new_tap_reference('oldowner/foo', 'https://github.com/oldowner/homebrew-foo')!
	request := homebrew.TapRedirectRequest{
		...tap_spec_redirect_request(tap, 'https://github.com/attacker/homebrew-foo')
		forbidden: true
		forbidden_owner: 'the owner'
	}
	homebrew.tap_apply_redirect(request, request.redirected_remote) or {
		return err.msg().contains('HOMEBREW_FORBIDDEN_TAPS')
	}
	return false
}

// Ruby it `it "applies a redirect to a tap allowed by name", :trust_store do` at line 664.
pub fn ruby_tap_spec_l664_d90_applies() !bool {
	tap := homebrew.new_tap_reference('oldowner/foo', 'https://github.com/oldowner/homebrew-foo')!
	plan := homebrew.tap_apply_redirect(tap_spec_redirect_request(tap, 'https://github.com/newowner/homebrew-foo'), 'https://github.com/newowner/homebrew-foo')!
	return plan.tap.name == 'newowner/foo' && plan.set_remote.arguments.last() == 'https://github.com/newowner/homebrew-foo'
}

// Ruby it `it "treats a redirect beginning with a dash as a URL, not a git option", :trust_store do` at line 684.
pub fn ruby_tap_spec_l684_d91_treats() !bool {
	tap := homebrew.new_tap_reference('dashy/foo', 'https://github.com/dashy/homebrew-foo')!
	plan := homebrew.tap_apply_redirect(tap_spec_redirect_request(tap, '-u:evil'), '-u:evil')!
	arguments := plan.set_remote.arguments
	return arguments[arguments.len - 2] == '--end-of-options' && arguments.last() == '-u:evil'
}

// Ruby it `it "terminates options before the requested remote" do` at line 703.
pub fn ruby_tap_spec_l703_d92_terminates() bool {
	plan := homebrew.tap_fix_remote_plan(homebrew.TapFixRemoteRequest{
		path: '/tmp/Taps/dashy/homebrew-foo'
		name: 'dashy/foo'
		requested_remote: '-u:evil'
	})
	arguments := plan.set_remote_commands[0].arguments
	return arguments[arguments.len - 2] == '--end-of-options' && arguments.last() == '-u:evil'
}

// Ruby specify `specify "Git variant" do` at line 717.
pub fn ruby_tap_spec_l717_d93_git(path string) !bool {
	repository := tap_spec_setup_git_repo(path, 'https://github.com/Homebrew/homebrew-foo')!
	tap_spec_write(os.join_path(path, 'README'), 'tap\n')!
	for arguments in [['config', 'user.email', 'tap@example.test'],
		['config', 'user.name', 'Tap Spec'], ['add', '--all'], ['commit', '-m', 'init']] {
		result := os.execute_opt('git -C ${os.quoted_path(path)} ${arguments.map(os.quoted_path(it)).join(' ')}')!
		if result.exit_code != 0 {
			return false
		}
	}
	head := repository.head_ref(false)!
	last := repository.last_committed()!
	return head.present && head.value.len == 40 && last.present && last.value.ends_with('ago')
}

// Ruby specify `specify "#private?", :needs_network do` at line 725.
pub fn ruby_tap_spec_l725_d94_private() bool {
	return homebrew.tap_private(homebrew.TapPrivateQuery{ github_value: true })
}

// Ruby it `it "disables terminal prompts for git commands" do` at line 730.
pub fn ruby_tap_spec_l730_d95_disables() bool {
	command := homebrew.tap_git_command(['fetch'], '/tmp/tap')
	return command.environment['GIT_TERMINAL_PROMPT'] == '0'
}

// Ruby it `it "does not run Git hooks" do` at line 740.
pub fn ruby_tap_spec_l740_d96_does() bool {
	command := homebrew.tap_git_command(['clone', '/tmp/source', '/tmp/clone'], '')
	return command.arguments[..3] == ['git', '-c', 'core.hooksPath=${os.path_devnull}']
}

// Ruby it `it "raises an error when the Tap is already tapped" do` at line 758.
pub fn ruby_tap_spec_l758_d97_raises() !bool {
	tap := homebrew.new_tap_reference('Homebrew/foo', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		installed: true
		current_remote: tap.default_remote()
	}
	homebrew.tap_install_plan(request) or { return err.msg().contains('TapAlreadyTappedError') }
	return false
}

// Ruby it `it "raises an error when the Tap is already tapped with the right remote" do` at line 765.
pub fn ruby_tap_spec_l765_d98_raises() !bool {
	tap := homebrew.new_tap_reference('Homebrew/foo', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		installed: true
		clone_target: tap.default_remote()
		current_remote: tap.default_remote()
	}
	homebrew.tap_install_plan(request) or { return err.msg().contains('TapAlreadyTappedError') }
	return false
}

// Ruby it `it "refuses a name-allowed tap cloned from a custom remote (no HOMEBREW_ALLOWED_TAPS bypass)" do` at line 773.
pub fn ruby_tap_spec_l773_d99_refuses() !bool {
	tap := homebrew.new_tap_reference('user/repo', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		clone_target: 'https://evil.example/repo'
		allowed: false
		forbidden_owner: 'the owner'
	}
	homebrew.tap_install_plan(request) or { return err.msg().contains('HOMEBREW_ALLOWED_TAPS') }
	return false
}

// Ruby it `it "raises an error when the remote doesn't match" do` at line 781.
pub fn ruby_tap_spec_l781_d100_raises() !bool {
	tap := homebrew.new_tap_reference('Homebrew/foo', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		installed: true
		clone_target: '${tap.default_remote()}-oops'
		current_remote: tap.default_remote()
	}
	homebrew.tap_install_plan(request) or { return err.msg().contains('TapRemoteMismatchError') }
	return false
}

// Ruby it `it "raises an error when the remote for Homebrew/core doesn't match HOMEBREW_CORE_GIT_REMOTE" do` at line 791.
pub fn ruby_tap_spec_l791_d101_raises() !bool {
	tap := homebrew.new_tap_reference('Homebrew/core', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		core_tap: true
		clone_target: 'https://github.com/Homebrew/homebrew-core-oops'
		configured_core_remote: 'https://github.com/Homebrew/homebrew-core'
	}
	homebrew.tap_install_plan(request) or { return err.msg().contains('TapCoreRemoteMismatchError') }
	return false
}

// Ruby it `it "creates an official tap worktree from the fetched remote HEAD" do` at line 799.
pub fn ruby_tap_spec_l799_d102_creates() !bool {
	tap := homebrew.new_tap_reference('Homebrew/cask', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		core_cask_tap: true
		worktree_source_tap_path: '/tmp/source/Library/Taps/homebrew/homebrew-cask'
		fetched_worktree_head: 'abc123'
	}
	plan := homebrew.tap_install_plan(request)!
	arguments := plan.worktree_fetch.arguments
	return plan.disposition == .worktree && plan.worktree_add.arguments.last() == 'abc123' && arguments[arguments.len - 2..] == [
		'origin',
		'HEAD',
	]
}

// Ruby it `it "creates core and cask taps as worktrees when the brew source repository has them" do` at line 854.
pub fn ruby_tap_spec_l854_d103_creates() !bool {
	for name in ['Homebrew/core', 'Homebrew/cask'] {
		tap := homebrew.new_tap_reference(name, '')!
		request := homebrew.TapInstallRequest{
			...tap_spec_install_request(tap)
			core_tap: tap.repository == 'core'
			core_cask_tap: tap.repository == 'cask'
			worktree_source_tap_path: '/tmp/source/Library/Taps/${tap.full_name.to_lower()}'
		}
		if homebrew.tap_install_plan(request)!.disposition != .worktree {
			return false
		}
	}
	return true
}

// Ruby it `it "creates a tap from another brew worktree when that has the source repository" do` at line 896.
pub fn ruby_tap_spec_l896_d104_creates() !bool {
	tap := homebrew.new_tap_reference('Homebrew/cask', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		core_cask_tap: true
		worktree_source_tap_path: '/tmp/source-worktree/Library/Taps/homebrew/homebrew-cask'
	}
	plan := homebrew.tap_install_plan(request)!
	return plan.worktree_source == '/tmp/source-worktree/Library/Taps/homebrew/homebrew-cask'
}

// Ruby it `it "uses the requested remote for cask taps with an explicit clone target" do` at line 946.
pub fn ruby_tap_spec_l946_d105_uses() !bool {
	tap := homebrew.new_tap_reference('Homebrew/cask', '')!
	requested := 'https://example.com/Homebrew/homebrew-cask'
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		core_cask_tap: true
		clone_target: requested
		force: true
		worktree_source_tap_path: '/tmp/source/Library/Taps/homebrew/homebrew-cask'
	}
	plan := homebrew.tap_install_plan(request)!
	arguments := plan.command.arguments
	return plan.disposition == .clone && arguments.last() == request.path && arguments[arguments.len - 2] == requested
}

// Ruby it `it "raises an error when run `brew tap --custom-remote` without a custom remote (already installed)" do` at line 981.
pub fn ruby_tap_spec_l981_d106_raises() !bool {
	tap := homebrew.new_tap_reference('Homebrew/foo', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		installed: true
		custom_remote: true
	}
	homebrew.tap_install_plan(request) or { return err.msg().contains('TapNoCustomRemoteError') }
	return false
}

// Ruby it `it "raises an error when run `brew tap --custom-remote` without a custom remote (not installed)" do` at line 991.
pub fn ruby_tap_spec_l991_d107_raises() !bool {
	tap := homebrew.new_tap_reference('Homebrew/bar', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		custom_remote: true
	}
	homebrew.tap_install_plan(request) or { return err.msg().contains('TapNoCustomRemoteError') }
	return false
}

// Ruby specify `specify "Git error" do` at line 1000.
pub fn ruby_tap_spec_l1000_d108_git() !bool {
	tap := homebrew.new_tap_reference('user/repo', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		clone_target: 'file:///not/existed/remote/url'
	}
	plan := homebrew.tap_install_plan(request)!
	requested := request.clone_target or { return false }
	arguments := plan.command.arguments
	return arguments[arguments.len - 2] == requested && plan.cleanup_path_on_error == request.path && plan.cleanup_parent_on_error == os.dir(request.path)
}

// Ruby it `it "raises an error if the Tap is not available" do` at line 1013.
pub fn ruby_tap_spec_l1013_d109_raises() !bool {
	tap := homebrew.new_tap_reference('Homebrew/bar', '')!
	homebrew.tap_uninstall_plan(tap, '/tmp/tap', false, false, none, [], []) or {
		return err.msg().contains('TapUnavailableError')
	}
	return false
}

// Ruby it `it "removes Git worktree metadata for worktree-installed taps" do` at line 1018.
pub fn ruby_tap_spec_l1018_d110_removes() !bool {
	tap := homebrew.new_tap_reference('Homebrew/cask', '')!
	plan := homebrew.tap_uninstall_plan(tap, '/tmp/tap', true, false, '/tmp/source-tap', [], [])!
	command := plan.worktree_remove_command or { return false }
	return command.arguments == ['git', '-C', '/tmp/source-tap', 'worktree', 'remove', '--force',
		'/tmp/tap']
}

// Ruby specify `specify "#install and` at line 1039.
pub fn ruby_tap_spec_l1039_d111_install() !bool {
	tap := homebrew.new_tap_reference('Homebrew/bar', '')!
	request := homebrew.TapInstallRequest{
		...tap_spec_install_request(tap)
		clone_target: '/tmp/homebrew-foo/.git'
	}
	install := homebrew.tap_install_plan(request)!
	uninstall := homebrew.tap_uninstall_plan(tap, request.path, true, false, none, [], [])!
	return install.link_completions && install.rebuild_commands && uninstall.unlink_manpages && uninstall.unlink_completions && uninstall.rebuild_commands
}

// Ruby specify `specify "#link_completions_and_manpages when completions are enabled for non-official tap" do` at line 1066.
pub fn ruby_tap_spec_l1066_d112_link_completions_and_manpages() !bool {
	tap := homebrew.new_tap_reference('NotHomebrew/baz', '')!
	plan := homebrew.tap_link_plan(tap, true)
	return plan.link_manpages && plan.link_completions && !plan.unlink_completions
}

// Ruby specify `specify "#link_completions_and_manpages when completions are disabled for non-official tap" do` at line 1089.
pub fn ruby_tap_spec_l1089_d113_link_completions_and_manpages() !bool {
	tap := homebrew.new_tap_reference('NotHomebrew/baz', '')!
	plan := homebrew.tap_link_plan(tap, false)
	return plan.link_manpages && !plan.link_completions && plan.unlink_completions
}

// Ruby specify `specify "#link_completions_and_manpages when completions are enabled for official tap" do` at line 1109.
pub fn ruby_tap_spec_l1109_d114_link_completions_and_manpages() !bool {
	tap := homebrew.new_tap_reference('Homebrew/baz', '')!
	plan := homebrew.tap_link_plan(tap, false)
	return plan.link_manpages && plan.link_completions && !plan.unlink_completions
}

// Ruby specify `specify "#config" do` at line 1130.
pub fn ruby_tap_spec_l1130_d115_config() bool {
	mut config := tap_config.new_tap_config(tap_config.TapConfigTap{
		name: 'homebrew/foo'
		path: '/tmp/homebrew/foo'
		git: true
	})
	if config.get('foo', true) != none {
		return false
	}
	config.set('foo', true, true)
	if config.get('foo', true) or { false } != true {
		return false
	}
	config.delete('foo', true)
	return config.get('foo', true) == none
}

// Ruby it `it "returns an enumerator if no block is passed" do` at line 1141.
pub fn ruby_tap_spec_l1141_d116_returns() bool {
	return homebrew.ruby_tap_l1423_d96_self_each([], false, false).enumerator
}

// Ruby it `it "includes the core tap with the api" do` at line 1153.
pub fn ruby_tap_spec_l1153_d117_includes() !bool {
	taps := homebrew.ruby_tap_l1423_d96_self_each([], false, true).taps
	return taps.any(it.name == 'homebrew/core')
}

// Ruby it `it "omits the core tap without the api", :no_api do` at line 1157.
pub fn ruby_tap_spec_l1157_d118_omits() !bool {
	taps := homebrew.ruby_tap_l1423_d96_self_each([], true, true).taps
	return !taps.any(it.name == 'homebrew/core')
}

// Ruby it `it "includes only installed taps" do` at line 1164.
pub fn ruby_tap_spec_l1164_d119_includes() !bool {
	core := homebrew.new_tap_reference('Homebrew/core', '')!
	foo := homebrew.new_tap_reference('Homebrew/foo', '')!
	installed := [core, foo]
	return installed.map(it.name) == ['homebrew/core', 'homebrew/foo']
}

// Ruby it `it "includes the core and cask taps by default", :needs_macos do` at line 1171.
pub fn ruby_tap_spec_l1171_d120_includes() !bool {
	foo := homebrew.new_tap_reference('Homebrew/foo', '')!
	third := homebrew.new_tap_reference('third-party/tap', '')!
	names := homebrew.ruby_tap_l1410_d94_self_all([foo, third]).map(it.name)
	return ['homebrew/core', 'homebrew/cask', 'homebrew/foo', 'third-party/tap'].all(it in names)
}

// Ruby it `it "includes the core and cask taps by default", :needs_linux do` at line 1180.
pub fn ruby_tap_spec_l1180_d121_includes() !bool {
	foo := homebrew.new_tap_reference('Homebrew/foo', '')!
	names := homebrew.ruby_tap_l1410_d94_self_all([foo]).map(it.name)
	return ['homebrew/core', 'homebrew/cask', 'homebrew/foo'].all(it in names)
}

// Ruby it `it "returns the formula_renames hash" do` at line 1191.
pub fn ruby_tap_spec_l1191_d122_returns(path string) bool {
	return homebrew.ruby_tap_l1241_d78_formula_renames(path) == {
		'oldname': 'foo'
	}
}

// Ruby it `it "returns the tap_migrations hash" do` at line 1200.
pub fn ruby_tap_spec_l1200_d123_returns(path string) bool {
	return homebrew.ruby_tap_l1263_d80_tap_migrations(path) == {
		'removed-formula': 'homebrew/foo'
	}
}

// Ruby it `it "returns the expected hash" do` at line 1224.
pub fn ruby_tap_spec_l1224_d124_returns() bool {
	reverse := homebrew.tap_reverse_migration_renames({
		'adobe-air-sdk':    'homebrew/cask'
		'app-engine-go-32': 'homebrew/cask/google-cloud-sdk'
		'app-engine-go-64': 'homebrew/cask/google-cloud-sdk'
		'gimp':             'homebrew/cask'
		'horndis':          'homebrew/cask'
		'inkscape':         'homebrew/cask'
		'schismtracker':    'homebrew/cask/schism-tracker'
	})
	return reverse == {
		'homebrew/cask/google-cloud-sdk': ['app-engine-go-32', 'app-engine-go-64']
		'homebrew/cask/schism-tracker':   ['schismtracker']
	}
}

// Ruby let `let(:cask_tap) { CoreCaskTap.instance }` at line 1233.
pub fn ruby_tap_spec_l1233_d125_cask_tap() !homebrew.TapReference {
	return homebrew.new_tap_reference('Homebrew/cask', '')
}

// Ruby let `let(:core_tap) { CoreTap.instance }` at line 1234.
pub fn ruby_tap_spec_l1234_d126_core_tap() !homebrew.TapReference {
	return homebrew.new_tap_reference('Homebrew/core', '')
}

// Ruby it `it "returns expected renames", :no_api do` at line 1236.
pub fn ruby_tap_spec_l1236_d127_returns() !bool {
	reverse := homebrew.tap_reverse_migration_renames({
		'app-engine-go-32': 'homebrew/cask/google-cloud-sdk'
		'app-engine-go-64': 'homebrew/cask/google-cloud-sdk'
		'schismtracker':    'homebrew/cask/schism-tracker'
	})
	cask := homebrew.new_tap_reference('Homebrew/cask', '')!
	core := homebrew.new_tap_reference('Homebrew/core', '')!
	return homebrew.tap_migration_oldnames([reverse], cask, 'gimp') == [] && homebrew.tap_migration_oldnames([
		reverse,
	], core, 'schism-tracker') == [] && homebrew.tap_migration_oldnames([reverse], cask, 'schism-tracker') == [
		'schismtracker',
	] && homebrew.tap_migration_oldnames([reverse], cask, 'google-cloud-sdk') == [
		'app-engine-go-32',
		'app-engine-go-64',
	]
}

// Ruby it `it "returns the audit_exceptions hash" do` at line 1250.
pub fn ruby_tap_spec_l1250_d128_returns(path string) bool {
	exceptions := homebrew.ruby_tap_l1341_d85_audit_exceptions(path)
	list := exceptions['formula_list'] or { return false }
	hash := exceptions['formula_hash'] or { return false }
	return list is []json2.Any && list.as_array().map(it.str()) == ['foo', 'bar'] && hash is map[string]json2.Any && hash.as_map()['foo'] or { return false }.str() == 'foo1'
}

// Ruby it `it "returns the style_exceptions hash" do` at line 1262.
pub fn ruby_tap_spec_l1262_d129_returns(path string) bool {
	exceptions := homebrew.ruby_tap_l1348_d86_style_exceptions(path)
	list := exceptions['formula_list'] or { return false }
	hash := exceptions['formula_hash'] or { return false }
	return list is []json2.Any && list.as_array().map(it.str()) == ['foo', 'bar'] && hash is map[string]json2.Any && hash.as_map()['bar'] or { return false }.str() == 'bar1'
}

// Ruby it `it "matches files from Formula/" do` at line 1274.
pub fn ruby_tap_spec_l1274_d130_matches(path string) !bool {
	os.mkdir_all(os.join_path(path, 'Formula'))!
	tap := homebrew.new_tap_reference('hard/core', '')!
	for file in ['kvazaar.rb', 'Casks/kvazaar.rb', 'Casks/k/kvazaar.rb', 'Formula/kvazaar.sh',
		'HomebrewFormula/kvazaar.rb', 'HomebrewFormula/k/kvazaar.rb'] {
		if homebrew.tap_formula_file(tap, path, file)! {
			return false
		}
	}
	return homebrew.tap_formula_file(tap, path, 'Formula/kvazaar.rb')! && homebrew.tap_formula_file(tap, path, 'Formula/k/kvazaar.rb')!
}

// Ruby it `it "matches files from HomebrewFormula/" do` at line 1299.
pub fn ruby_tap_spec_l1299_d131_matches(path string) !bool {
	os.mkdir_all(os.join_path(path, 'HomebrewFormula'))!
	tap := homebrew.new_tap_reference('hard/core', '')!
	for file in ['kvazaar.rb', 'Casks/kvazaar.rb', 'Casks/k/kvazaar.rb', 'Formula/kvazaar.rb',
		'Formula/k/kvazaar.rb', 'HomebrewFormula/kvazaar.sh'] {
		if homebrew.tap_formula_file(tap, path, file)! {
			return false
		}
	}
	return homebrew.tap_formula_file(tap, path, 'HomebrewFormula/kvazaar.rb')! && homebrew.tap_formula_file(tap, path, 'HomebrewFormula/k/kvazaar.rb')!
}

// Ruby it `it "matches files from the top-level directory" do` at line 1324.
pub fn ruby_tap_spec_l1324_d132_matches(path string) !bool {
	os.mkdir_all(path)!
	tap := homebrew.new_tap_reference('hard/core', '')!
	for file in ['kvazaar.sh', 'Casks/kvazaar.rb', 'Casks/k/kvazaar.rb', 'Formula/kvazaar.rb',
		'Formula/k/kvazaar.rb', 'HomebrewFormula/kvazaar.rb', 'HomebrewFormula/k/kvazaar.rb'] {
		if homebrew.tap_formula_file(tap, path, file)! {
			return false
		}
	}
	return homebrew.tap_formula_file(tap, path, 'kvazaar.rb')!
}

// Ruby it `it "matches files from Casks/" do` at line 1347.
pub fn ruby_tap_spec_l1347_d133_matches() bool {
	for file in ['kvazaar.rb', 'Casks/kvazaar.sh', 'Formula/kvazaar.rb', 'Formula/k/kvazaar.rb',
		'HomebrewFormula/kvazaar.rb', 'HomebrewFormula/k/kvazaar.rb'] {
		if homebrew.tap_cask_file(file) {
			return false
		}
	}
	return homebrew.tap_cask_file('Casks/kvazaar.rb') && homebrew.tap_cask_file('Casks/k/kvazaar.rb')
}

// Ruby subject `subject(:core_tap) { described_class.instance }` at line 1372.
pub fn ruby_tap_spec_l1372_d134_core_tap() !homebrew.TapReference {
	return homebrew.new_tap_reference('Homebrew/core', '')
}

// Ruby specify `specify "attributes" do` at line 1374.
pub fn ruby_tap_spec_l1374_d135_attributes(path string) !bool {
	tap := homebrew.new_tap_reference('Homebrew/core', '')!
	return tap.user == 'Homebrew' && tap.repository == 'core' && tap.name == 'homebrew/core' && homebrew.tap_command_files(path) == [] && homebrew.ruby_tap_l515_d36_installed(path) && tap.official() && tap_config.ruby_core_tap_l64_d7_core_tap()
}

// Ruby specify `specify "forbidden operations", :no_api do` at line 1384.
pub fn ruby_tap_spec_l1384_d136_forbidden() bool {
	tap_config.core_tap_uninstall(true) or {
		return err.msg() == 'Tap#uninstall is not available for CoreTap'
	}
	return false
}

// Ruby specify `specify "#autobump reads public formula API metadata" do` at line 1388.
pub fn ruby_tap_spec_l1388_d137_autobump() bool {
	return homebrew.tap_autobump_for_tap(true, false, {
		'autobumped': homebrew.TapPackageMetadata{ autobump: true }
		'disabled':   homebrew.TapPackageMetadata{ autobump: true, disabled: true }
		'skipped':    homebrew.TapPackageMetadata{ autobump: true, skip_livecheck: true }
	}, {
		'wrong-api': homebrew.TapPackageMetadata{ autobump: true }
	}, '/not/present') == ['autobumped']
}

// Ruby specify `specify "#autobump reads public cask API metadata" do` at line 1400.
pub fn ruby_tap_spec_l1400_d138_autobump() bool {
	return homebrew.tap_autobump_for_tap(false, true, {
		'wrong-api': homebrew.TapPackageMetadata{ autobump: true }
	}, {
		'autobumped': homebrew.TapPackageMetadata{ autobump: true }
		'disabled':   homebrew.TapPackageMetadata{ autobump: true, disabled: true }
		'skipped':    homebrew.TapPackageMetadata{ autobump: true, skip_livecheck: true }
	}, '/not/present') == ['autobumped']
}

// Ruby specify `specify "files", :no_api do` at line 1414.
pub fn ruby_tap_spec_l1414_d139_files(path string) !bool {
	tap := homebrew.new_tap_reference('Homebrew/core', '')!
	formula_file := os.join_path(path, 'Formula', 'foo.rb')
	tap_spec_write(formula_file, 'class Foo < Formula\nend\n')!
	for file in ['formula_renames.json', 'tap_migrations.json', 'audit_exceptions/formula_list.json',
		'style_exceptions/formula_hash.json'] {
		tap_spec_write(os.join_path(path, file), '{ "foo": "foo1", "bar": "bar1" }')!
	}
	alias_file := os.join_path(path, 'Aliases', 'bar')
	os.mkdir_all(os.dir(alias_file))!
	os.symlink(formula_file, alias_file)!
	formula_files := homebrew.tap_formula_files(tap, path)
	alias_files := homebrew.tap_alias_files(path)
	table := tap_config.core_tap_alias_table(alias_files)
	return formula_files == [formula_file] && tap_config.core_tap_formula_names(formula_files) == [
		'foo',
	] && alias_files == [alias_file] && table == {
		'bar': 'foo'
	} && homebrew.tap_reverse_table(table) == {
		'foo': ['bar']
	} && homebrew.tap_read_string_map(os.join_path(path, 'formula_renames.json')) == {
		'foo': 'foo1'
		'bar': 'bar1'
	}
}

// Ruby specify `specify do` at line 1455.
pub fn ruby_tap_spec_l1455_d140_do(tap_directory string) !bool {
	core := homebrew.new_tap_reference('Homebrew/core', '')!
	dashes := homebrew.new_tap_reference('my/tap-with-dashes', '')!
	symbol := homebrew.new_tap_reference('my/tap-with-@-symbol', '')!
	return homebrew.tap_repository_var_suffix(core, tap_directory) == '_HOMEBREW_HOMEBREW_CORE' && homebrew.tap_repository_var_suffix(dashes, tap_directory) == '_MY_HOMEBREW_TAP_WITH_DASHES' && homebrew.tap_repository_var_suffix(symbol, tap_directory) == '_MY_HOMEBREW_TAP_WITH___SYMBOL'
}

// Ruby it `it "returns the tap and formula name when given a full name" do` at line 1467.
pub fn ruby_tap_spec_l1467_d141_returns() bool {
	tap, name := homebrew.tap_with_formula_name('homebrew/core/gcc') or { return false }
	return tap.name == 'homebrew/core' && name == 'gcc'
}

// Ruby it `it "returns nil when given a relative path" do` at line 1471.
pub fn ruby_tap_spec_l1471_d142_returns() bool {
	return homebrew.tap_with_formula_name('./Formula/gcc.rb') == none
}

// Ruby it `it "returns the tap and cask token when given a full token" do` at line 1477.
pub fn ruby_tap_spec_l1477_d143_returns() bool {
	tap, token := homebrew.tap_with_cask_token('homebrew/cask/alfred') or { return false }
	return tap.name == 'homebrew/cask' && token == 'alfred'
}

// Ruby it `it "returns nil when given a relative path" do` at line 1481.
pub fn ruby_tap_spec_l1481_d144_returns() bool {
	return homebrew.tap_with_cask_token('./Casks/alfred.rb') == none
}

pub struct TapSpecBoundary {
pub:
	line   int
	passed bool
}

pub fn tap_spec_all_boundaries(root string) ![]TapSpecBoundary {
	os.mkdir_all(root)!
	defer {
		os.rmdir_all(root) or {}
	}
	mut boundaries := []TapSpecBoundary{}
	tap_directory := os.join_path(root, 'Taps')
	os.mkdir_all(tap_directory)!
	foo := ruby_tap_spec_l5_d1_homebrew_foo_tap()!
	path := ruby_tap_spec_l7_d2_path(tap_directory)
	boundaries << TapSpecBoundary{ line: 5, passed: foo.name == 'homebrew/foo' }
	boundaries << TapSpecBoundary{ line: 7, passed: path.ends_with('homebrew/homebrew-foo') }
	boundaries << TapSpecBoundary{ line: 8, passed: ruby_tap_spec_l8_d3_formula_file(path).ends_with('Formula/foo.rb') }
	boundaries << TapSpecBoundary{ line: 9, passed: ruby_tap_spec_l9_d4_alias_file(path).ends_with('Aliases/bar') }
	boundaries << TapSpecBoundary{ line: 10, passed: ruby_tap_spec_l10_d5_cmd_file(path).ends_with('cmd/brew-tap-cmd.rb') }
	boundaries << TapSpecBoundary{ line: 11, passed: ruby_tap_spec_l11_d6_manpage_file(path).ends_with('manpages/brew-tap-cmd.1') }
	boundaries << TapSpecBoundary{ line: 12, passed: ruby_tap_spec_l12_d7_bash_completion_file(path).ends_with('bash/brew-tap-cmd') }
	boundaries << TapSpecBoundary{ line: 13, passed: ruby_tap_spec_l13_d8_zsh_completion_file(path).ends_with('zsh/_brew-tap-cmd') }
	boundaries << TapSpecBoundary{ line: 14, passed: ruby_tap_spec_l14_d9_fish_completion_file(path).ends_with('fish/brew-tap-cmd.fish') }
	boundaries << TapSpecBoundary{ line: 18, passed: ruby_tap_spec_l18_d10_have_cask_file('Casks/a.rb') }
	formula_root := os.join_path(root, 'formula-matcher')
	os.mkdir_all(os.join_path(formula_root, 'Formula'))!
	boundaries << TapSpecBoundary{ line: 19, passed: ruby_tap_spec_l19_d11_have_formula_file(foo, formula_root, 'Formula/a.rb')! }
	boundaries << TapSpecBoundary{ line: 20, passed: !ruby_tap_spec_l20_d12_have_custom_remote(foo) }
	fixture := os.join_path(root, 'fixture')
	boundaries << TapSpecBoundary{ line: 31, passed: ruby_tap_spec_l31_d13_setup_tap_files(fixture)!.formula_file.ends_with('foo.rb') }
	git_helper := os.join_path(root, 'git-helper')
	boundaries << TapSpecBoundary{ line: 76, passed: ruby_tap_spec_l76_d14_setup_git_repo(git_helper)!.is_git_repository() }
	boundaries << TapSpecBoundary{ line: 85, passed: ruby_tap_spec_l85_d15_setup_completion(true) }
	boundaries << TapSpecBoundary{ line: 98, passed: ruby_tap_spec_l98_d16_fetch()! }
	boundaries << TapSpecBoundary{ line: 119, passed: ruby_tap_spec_l119_d17_tap()!.name == 'homebrew/core' }
	boundaries << TapSpecBoundary{ line: 120, passed: ruby_tap_spec_l120_d18_path(tap_directory)!.contains('homebrew-core') }
	boundaries << TapSpecBoundary{ line: 121, passed: ruby_tap_spec_l121_d19_formula_path('/tap').ends_with('Formula/formula.rb') }
	boundaries << TapSpecBoundary{ line: 123, passed: ruby_tap_spec_l123_d20_returns(tap_directory)! }
	boundaries << TapSpecBoundary{ line: 127, passed: ruby_tap_spec_l127_d21_returns(tap_directory)! }
	boundaries << TapSpecBoundary{ line: 132, passed: ruby_tap_spec_l132_d22_tap()!.name == 'str4d.xyz/rage' }
	boundaries << TapSpecBoundary{ line: 138, passed: ruby_tap_spec_l138_d23_returns(tap_directory)! }
	boundaries << TapSpecBoundary{ line: 147, passed: ruby_tap_spec_l147_d24_returns() }
	boundaries << TapSpecBoundary{ line: 151, passed: ruby_tap_spec_l151_d25_normalises() }
	boundaries << TapSpecBoundary{ line: 156, passed: ruby_tap_spec_l156_d26_preserves() }
	boundaries << TapSpecBoundary{ line: 161, passed: ruby_tap_spec_l161_d27_warns() }
	boundaries << TapSpecBoundary{ line: 170, passed: ruby_tap_spec_l170_d28_returns() }
	boundaries << TapSpecBoundary{ line: 176, passed: ruby_tap_spec_l176_d29_recognises() }
	boundaries << TapSpecBoundary{ line: 180, passed: ruby_tap_spec_l180_d30_recognises() }
	boundaries << TapSpecBoundary{ line: 184, passed: ruby_tap_spec_l184_d31_treats() }
	boundaries << TapSpecBoundary{ line: 188, passed: ruby_tap_spec_l188_d32_treats() }
	boundaries << TapSpecBoundary{ line: 192, passed: ruby_tap_spec_l192_d33_treats() }
	boundaries << TapSpecBoundary{ line: 198, passed: ruby_tap_spec_l198_d34_keeps() }
	boundaries << TapSpecBoundary{ line: 205, passed: ruby_tap_spec_l205_d35_ignores() }
	boundaries << TapSpecBoundary{ line: 210, passed: ruby_tap_spec_l210_d36_ignores() }
	boundaries << TapSpecBoundary{ line: 215, passed: ruby_tap_spec_l215_d37_ignores() }
	boundaries << TapSpecBoundary{ line: 220, passed: ruby_tap_spec_l220_d38_keeps() }
	boundaries << TapSpecBoundary{ line: 225, passed: ruby_tap_spec_l225_d39_still() }
	boundaries << TapSpecBoundary{ line: 230, passed: ruby_tap_spec_l230_d40_keeps() }
	boundaries << TapSpecBoundary{ line: 235, passed: ruby_tap_spec_l235_d41_treats() }
	boundaries << TapSpecBoundary{ line: 240, passed: ruby_tap_spec_l240_d42_treats() }
	boundaries << TapSpecBoundary{ line: 245, passed: ruby_tap_spec_l245_d43_treats() }
	boundaries << TapSpecBoundary{ line: 250, passed: ruby_tap_spec_l250_d44_treats() }
	boundaries << TapSpecBoundary{ line: 255, passed: ruby_tap_spec_l255_d45_keeps() }
	boundaries << TapSpecBoundary{ line: 262, passed: ruby_tap_spec_l262_d46_tap()!.name == 'user/repo' }
	boundaries << TapSpecBoundary{ line: 264, passed: ruby_tap_spec_l264_d47_matches()! }
	boundaries << TapSpecBoundary{ line: 268, passed: ruby_tap_spec_l268_d48_matches()! }
	boundaries << TapSpecBoundary{ line: 272, passed: ruby_tap_spec_l272_d49_does()! }
	boundaries << TapSpecBoundary{ line: 276, passed: ruby_tap_spec_l276_d50_matches()! }
	boundaries << TapSpecBoundary{ line: 281, passed: ruby_tap_spec_l281_d51_matches()! }
	boundaries << TapSpecBoundary{ line: 285, passed: ruby_tap_spec_l285_d52_matches()! }
	boundaries << TapSpecBoundary{ line: 289, passed: ruby_tap_spec_l289_d53_matches()! }
	boundaries << TapSpecBoundary{ line: 298, passed: ruby_tap_spec_l298_d54_does()! }
	boundaries << TapSpecBoundary{ line: 302, passed: ruby_tap_spec_l302_d55_does()! }
	boundaries << TapSpecBoundary{ line: 309, passed: ruby_tap_spec_l309_d56_is()! }
	boundaries << TapSpecBoundary{ line: 314, passed: ruby_tap_spec_l314_d57_is()! }
	boundaries << TapSpecBoundary{ line: 319, passed: ruby_tap_spec_l319_d58_is() }
	boundaries << TapSpecBoundary{ line: 325, passed: ruby_tap_spec_l325_d59_is() }
	boundaries << TapSpecBoundary{ line: 332, passed: ruby_tap_spec_l332_d60_is() }
	boundaries << TapSpecBoundary{ line: 338, passed: ruby_tap_spec_l338_d61_accepts() }
	boundaries << TapSpecBoundary{ line: 348, passed: ruby_tap_spec_l348_d62_forbids()! }
	os.mkdir_all(os.join_path(tap_directory, 'homebrew', 'homebrew-foo'))!
	boundaries << TapSpecBoundary{ line: 354, passed: ruby_tap_spec_l354_d63_attributes(tap_directory)! }
	boundaries << TapSpecBoundary{ line: 364, passed: ruby_tap_spec_l364_d64_issues_url()! }
	boundaries << TapSpecBoundary{ line: 382, passed: ruby_tap_spec_l382_d65_files(os.join_path(root, 'files'))! }
	boundaries << TapSpecBoundary{ line: 434, passed: ruby_tap_spec_l434_d66_groups() }
	boundaries << TapSpecBoundary{ line: 444, passed: ruby_tap_spec_l444_d67_returns(os.join_path(root, 'remote'))! }
	boundaries << TapSpecBoundary{ line: 459, passed: ruby_tap_spec_l459_d68_returns(os.join_path(root, 'not-git'))! }
	boundaries << TapSpecBoundary{ line: 463, passed: ruby_tap_spec_l463_d69_reads(os.join_path(root, 'config'))! }
	boundaries << TapSpecBoundary{ line: 471, passed: ruby_tap_spec_l471_d70_returns(os.join_path(root, 'https'))! }
	boundaries << TapSpecBoundary{ line: 485, passed: ruby_tap_spec_l485_d71_returns(os.join_path(root, 'ssh'))! }
	boundaries << TapSpecBoundary{ line: 499, passed: ruby_tap_spec_l499_d72_returns(os.join_path(root, 'none'))! }
	boundaries << TapSpecBoundary{ line: 503, passed: ruby_tap_spec_l503_d73_reads(os.join_path(root, 'config2'))! }
	boundaries << TapSpecBoundary{ line: 511, passed: ruby_tap_spec_l511_d74_tap()!.name == 'homebrew/test-bot' }
	boundaries << TapSpecBoundary{ line: 513, passed: ruby_tap_spec_l513_d75_remote() == none }
	boundaries << TapSpecBoundary{ line: 522, passed: ruby_tap_spec_l522_d76_returns()! }
	boundaries << TapSpecBoundary{ line: 529, passed: ruby_tap_spec_l529_d77_remote().contains('github.com') }
	boundaries << TapSpecBoundary{ line: 531, passed: ruby_tap_spec_l531_d78_custom_remote()! }
	boundaries << TapSpecBoundary{ line: 535, passed: ruby_tap_spec_l535_d79_remote().ends_with('.git') }
	boundaries << TapSpecBoundary{ line: 537, passed: ruby_tap_spec_l537_d80_custom_remote()! }
	boundaries << TapSpecBoundary{ line: 541, passed: ruby_tap_spec_l541_d81_remote().starts_with('git@') }
	boundaries << TapSpecBoundary{ line: 543, passed: ruby_tap_spec_l543_d82_custom_remote()! }
	boundaries << TapSpecBoundary{ line: 547, passed: ruby_tap_spec_l547_d83_remote().contains('gitlab.com') }
	boundaries << TapSpecBoundary{ line: 549, passed: ruby_tap_spec_l549_d84_custom_remote()! }
	boundaries << TapSpecBoundary{ line: 554, passed: ruby_tap_spec_l554_d85_moves()! }
	boundaries << TapSpecBoundary{ line: 587, passed: ruby_tap_spec_l587_d86_prints()! }
	boundaries << TapSpecBoundary{ line: 608, passed: ruby_tap_spec_l608_d87_updates()! }
	boundaries << TapSpecBoundary{ line: 626, passed: ruby_tap_spec_l626_d88_refuses()! }
	boundaries << TapSpecBoundary{ line: 645, passed: ruby_tap_spec_l645_d89_refuses()! }
	boundaries << TapSpecBoundary{ line: 664, passed: ruby_tap_spec_l664_d90_applies()! }
	boundaries << TapSpecBoundary{ line: 684, passed: ruby_tap_spec_l684_d91_treats()! }
	boundaries << TapSpecBoundary{ line: 703, passed: ruby_tap_spec_l703_d92_terminates() }
	boundaries << TapSpecBoundary{ line: 717, passed: ruby_tap_spec_l717_d93_git(os.join_path(root, 'git-variant'))! }
	boundaries << TapSpecBoundary{ line: 725, passed: ruby_tap_spec_l725_d94_private() }
	boundaries << TapSpecBoundary{ line: 730, passed: ruby_tap_spec_l730_d95_disables() }
	boundaries << TapSpecBoundary{ line: 740, passed: ruby_tap_spec_l740_d96_does() }
	boundaries << TapSpecBoundary{ line: 758, passed: ruby_tap_spec_l758_d97_raises()! }
	boundaries << TapSpecBoundary{ line: 765, passed: ruby_tap_spec_l765_d98_raises()! }
	boundaries << TapSpecBoundary{ line: 773, passed: ruby_tap_spec_l773_d99_refuses()! }
	boundaries << TapSpecBoundary{ line: 781, passed: ruby_tap_spec_l781_d100_raises()! }
	boundaries << TapSpecBoundary{ line: 791, passed: ruby_tap_spec_l791_d101_raises()! }
	boundaries << TapSpecBoundary{ line: 799, passed: ruby_tap_spec_l799_d102_creates()! }
	boundaries << TapSpecBoundary{ line: 854, passed: ruby_tap_spec_l854_d103_creates()! }
	boundaries << TapSpecBoundary{ line: 896, passed: ruby_tap_spec_l896_d104_creates()! }
	boundaries << TapSpecBoundary{ line: 946, passed: ruby_tap_spec_l946_d105_uses()! }
	boundaries << TapSpecBoundary{ line: 981, passed: ruby_tap_spec_l981_d106_raises()! }
	boundaries << TapSpecBoundary{ line: 991, passed: ruby_tap_spec_l991_d107_raises()! }
	boundaries << TapSpecBoundary{ line: 1000, passed: ruby_tap_spec_l1000_d108_git()! }
	boundaries << TapSpecBoundary{ line: 1013, passed: ruby_tap_spec_l1013_d109_raises()! }
	boundaries << TapSpecBoundary{ line: 1018, passed: ruby_tap_spec_l1018_d110_removes()! }
	boundaries << TapSpecBoundary{ line: 1039, passed: ruby_tap_spec_l1039_d111_install()! }
	boundaries << TapSpecBoundary{ line: 1066, passed: ruby_tap_spec_l1066_d112_link_completions_and_manpages()! }
	boundaries << TapSpecBoundary{ line: 1089, passed: ruby_tap_spec_l1089_d113_link_completions_and_manpages()! }
	boundaries << TapSpecBoundary{ line: 1109, passed: ruby_tap_spec_l1109_d114_link_completions_and_manpages()! }
	boundaries << TapSpecBoundary{ line: 1130, passed: ruby_tap_spec_l1130_d115_config() }
	boundaries << TapSpecBoundary{ line: 1141, passed: ruby_tap_spec_l1141_d116_returns() }
	boundaries << TapSpecBoundary{ line: 1153, passed: ruby_tap_spec_l1153_d117_includes()! }
	boundaries << TapSpecBoundary{ line: 1157, passed: ruby_tap_spec_l1157_d118_omits()! }
	boundaries << TapSpecBoundary{ line: 1164, passed: ruby_tap_spec_l1164_d119_includes()! }
	boundaries << TapSpecBoundary{ line: 1171, passed: ruby_tap_spec_l1171_d120_includes()! }
	boundaries << TapSpecBoundary{ line: 1180, passed: ruby_tap_spec_l1180_d121_includes()! }
	boundaries << TapSpecBoundary{ line: 1191, passed: ruby_tap_spec_l1191_d122_returns(fixture) }
	boundaries << TapSpecBoundary{ line: 1200, passed: ruby_tap_spec_l1200_d123_returns(fixture) }
	boundaries << TapSpecBoundary{ line: 1224, passed: ruby_tap_spec_l1224_d124_returns() }
	boundaries << TapSpecBoundary{ line: 1233, passed: ruby_tap_spec_l1233_d125_cask_tap()!.name == 'homebrew/cask' }
	boundaries << TapSpecBoundary{ line: 1234, passed: ruby_tap_spec_l1234_d126_core_tap()!.name == 'homebrew/core' }
	boundaries << TapSpecBoundary{ line: 1236, passed: ruby_tap_spec_l1236_d127_returns()! }
	boundaries << TapSpecBoundary{ line: 1250, passed: ruby_tap_spec_l1250_d128_returns(fixture) }
	boundaries << TapSpecBoundary{ line: 1262, passed: ruby_tap_spec_l1262_d129_returns(fixture) }
	boundaries << TapSpecBoundary{ line: 1274, passed: ruby_tap_spec_l1274_d130_matches(os.join_path(root, 'formula-dir'))! }
	boundaries << TapSpecBoundary{ line: 1299, passed: ruby_tap_spec_l1299_d131_matches(os.join_path(root, 'homebrew-formula-dir'))! }
	boundaries << TapSpecBoundary{ line: 1324, passed: ruby_tap_spec_l1324_d132_matches(os.join_path(root, 'top-formula-dir'))! }
	boundaries << TapSpecBoundary{ line: 1347, passed: ruby_tap_spec_l1347_d133_matches() }
	boundaries << TapSpecBoundary{ line: 1372, passed: ruby_tap_spec_l1372_d134_core_tap()!.name == 'homebrew/core' }
	core_path := os.join_path(root, 'core-attributes')
	os.mkdir_all(core_path)!
	boundaries << TapSpecBoundary{ line: 1374, passed: ruby_tap_spec_l1374_d135_attributes(core_path)! }
	boundaries << TapSpecBoundary{ line: 1384, passed: ruby_tap_spec_l1384_d136_forbidden() }
	boundaries << TapSpecBoundary{ line: 1388, passed: ruby_tap_spec_l1388_d137_autobump() }
	boundaries << TapSpecBoundary{ line: 1400, passed: ruby_tap_spec_l1400_d138_autobump() }
	boundaries << TapSpecBoundary{ line: 1414, passed: ruby_tap_spec_l1414_d139_files(os.join_path(root, 'core-files'))! }
	boundaries << TapSpecBoundary{ line: 1455, passed: ruby_tap_spec_l1455_d140_do(tap_directory)! }
	boundaries << TapSpecBoundary{ line: 1467, passed: ruby_tap_spec_l1467_d141_returns() }
	boundaries << TapSpecBoundary{ line: 1471, passed: ruby_tap_spec_l1471_d142_returns() }
	boundaries << TapSpecBoundary{ line: 1477, passed: ruby_tap_spec_l1477_d143_returns() }
	boundaries << TapSpecBoundary{ line: 1481, passed: ruby_tap_spec_l1481_d144_returns() }
	return boundaries
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Tap do
// 5:   subject(:homebrew_foo_tap) { described_class.fetch("Homebrew", "foo") }
// 6:
// 7:   let(:path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo" }
// 8:   let(:formula_file) { path/"Formula/foo.rb" }
// 9:   let(:alias_file) { path/"Aliases/bar" }
// 10:   let(:cmd_file) { path/"cmd/brew-tap-cmd.rb" }
// 11:   let(:manpage_file) { path/"manpages/brew-tap-cmd.1" }
// 12:   let(:bash_completion_file) { path/"completions/bash/brew-tap-cmd" }
// 13:   let(:zsh_completion_file) { path/"completions/zsh/_brew-tap-cmd" }
// 14:   let(:fish_completion_file) { path/"completions/fish/brew-tap-cmd.fish" }
// 15:
// 16:   include FileUtils
// 17:
// 18:   alias_matcher :have_cask_file, :be_cask_file
// 19:   alias_matcher :have_formula_file, :be_formula_file
// 20:   alias_matcher :have_custom_remote, :be_custom_remote
// 21:
// 22:   before do
// 23:     path.mkpath
// 24:     (path/"audit_exceptions").mkpath
// 25:     (path/"style_exceptions").mkpath
// 26:
// 27:     # requiring utils/output in tap.rb should be enough but it's not for no apparent reason.
// 28:     $stderr.extend(Utils::Output::Mixin)
// 29:   end
// 30:
// 31:   def setup_tap_files
// 32:     formula_file.dirname.mkpath
// 33:     formula_file.write <<~RUBY
// 34:       class Foo < Formula
// 35:         url "https://brew.sh/foo-1.0.tar.gz"
// 36:       end
// 37:     RUBY
// 38:
// 39:     alias_file.parent.mkpath
// 40:     ln_s formula_file, alias_file
// 41:
// 42:     (path/"formula_renames.json").write <<~JSON
// 43:       { "oldname": "foo" }
// 44:     JSON
// 45:
// 46:     (path/"tap_migrations.json").write <<~JSON
// 47:       { "removed-formula": "homebrew/foo" }
// 48:     JSON
// 49:
// 50:     %w[audit_exceptions style_exceptions].each do |exceptions_directory|
// 51:       (path/exceptions_directory).mkpath
// 52:
// 53:       (path/"#{exceptions_directory}/formula_list.json").write <<~JSON
// 54:         [ "foo", "bar" ]
// 55:       JSON
// 56:
// 57:       (path/"#{exceptions_directory}/formula_hash.json").write <<~JSON
// 58:         { "foo": "foo1", "bar": "bar1" }
// 59:       JSON
// 60:     end
// 61:
// 62:     [
// 63:       cmd_file,
// 64:       manpage_file,
// 65:       bash_completion_file,
// 66:       zsh_completion_file,
// 67:       fish_completion_file,
// 68:     ].each do |f|
// 69:       f.parent.mkpath
// 70:       touch f
// 71:     end
// 72:
// 73:     chmod 0755, cmd_file
// 74:   end
// 75:
// 76:   def setup_git_repo
// 77:     path.cd do
// 78:       system "git", "init"
// 79:       system "git", "remote", "add", "origin", "https://github.com/Homebrew/homebrew-foo"
// 80:       system "git", "add", "--all"
// 81:       system "git", "commit", "-m", "init"
// 82:     end
// 83:   end
// 84:
// 85:   def setup_completion(link:)
// 86:     allow(Commands).to receive(:rebuild_commands_completion_list)
// 87:     allow(CacheStoreDatabase).to receive(:use).and_call_original
// 88:     allow(CacheStoreDatabase).to receive(:use).with(:descriptions)
// 89:     allow(CacheStoreDatabase).to receive(:use).with(:cask_descriptions)
// 90:
// 91:     HOMEBREW_REPOSITORY.cd do
// 92:       system "git", "init"
// 93:       system "git", "config", "--replace-all", "homebrew.linkcompletions", link.to_s
// 94:       system "git", "config", "--replace-all", "homebrew.completionsmessageshown", "true"
// 95:     end
// 96:   end
// 97:
// 98:   specify "::fetch" do
// 99:     expect(described_class.fetch("Homebrew", "core")).to be_a(CoreTap)
// 100:     expect(described_class.fetch("Homebrew", "homebrew")).to be_a(CoreTap)
// 101:     tap = described_class.fetch("Homebrew", "foo")
// 102:     expect(tap).to be_a(described_class)
// 103:     expect(tap.name).to eq("homebrew/foo")
// 104:
// 105:     expect do
// 106:       described_class.fetch("foo")
// 107:     end.to raise_error(Tap::InvalidNameError, /Invalid tap name/)
// 108:
// 109:     expect do
// 110:       described_class.fetch("homebrew/homebrew/bar")
// 111:     end.to raise_error(Tap::InvalidNameError, /Invalid tap name/)
// 112:
// 113:     expect do
// 114:       described_class.fetch("homebrew", "homebrew/baz")
// 115:     end.to raise_error(Tap::InvalidNameError, /Invalid tap name/)
// 116:   end
// 117:
// 118:   describe "::from_path" do
// 119:     let(:tap) { described_class.fetch("Homebrew", "core") }
// 120:     let(:path) { tap.path }
// 121:     let(:formula_path) { path/"Formula/formula.rb" }
// 122:
// 123:     it "returns the Tap for a Formula path" do
// 124:       expect(described_class.from_path(formula_path)).to eq tap
// 125:     end
// 126:
// 127:     it "returns the Tap when given its exact path" do
// 128:       expect(described_class.from_path(path)).to eq tap
// 129:     end
// 130:
// 131:     context "when path contains a dot" do
// 132:       let(:tap) { described_class.fetch("str4d.xyz", "rage") }
// 133:
// 134:       after do
// 135:         tap.uninstall
// 136:       end
// 137:
// 138:       it "returns the Tap when given its exact path" do
// 139:         expect(described_class.from_path(path)).to eq tap
// 140:       end
// 141:     end
// 142:   end
// 143:
// 144:   describe "::allowed_taps" do
// 145:     before { allow(Homebrew::EnvConfig).to receive(:allowed_taps).and_return("homebrew/allowed") }
// 146:
// 147:     it "returns the references from the environment" do
// 148:       expect(described_class.allowed_taps).to contain_exactly("homebrew/allowed")
// 149:     end
// 150:
// 151:     it "normalises a `user/homebrew-repository` entry to a canonical tap name" do
// 152:       allow(Homebrew::EnvConfig).to receive(:allowed_taps).and_return("User/homebrew-Repo")
// 153:       expect(described_class.allowed_taps).to contain_exactly("user/repo")
// 154:     end
// 155:
// 156:     it "preserves a remote URL entry verbatim" do
// 157:       allow(Homebrew::EnvConfig).to receive(:allowed_taps).and_return("https://gitlab.com/other/repo")
// 158:       expect(described_class.allowed_taps).to contain_exactly("https://gitlab.com/other/repo")
// 159:     end
// 160:
// 161:     it "warns about and ignores an invalid tap name" do
// 162:       allow(Homebrew::EnvConfig).to receive(:allowed_taps).and_return("not-a-tap")
// 163:       expect { expect(described_class.allowed_taps).to be_empty }.to output(/Invalid tap name/).to_stderr
// 164:     end
// 165:   end
// 166:
// 167:   describe "::forbidden_taps" do
// 168:     before { allow(Homebrew::EnvConfig).to receive(:forbidden_taps).and_return("homebrew/forbidden") }
// 169:
// 170:     it "returns the references from the environment" do
// 171:       expect(described_class.forbidden_taps).to contain_exactly("homebrew/forbidden")
// 172:     end
// 173:   end
// 174:
// 175:   describe "::remote_reference?" do
// 176:     it "recognises scp-like syntax without a `user@`" do
// 177:       expect(described_class.remote_reference?("ssh_host:/srv/git/homebrew-custom_tap")).to be true
// 178:     end
// 179:
// 180:     it "recognises scp-like syntax with a `user@`" do
// 181:       expect(described_class.remote_reference?("git@github.com:user/homebrew-repo")).to be true
// 182:     end
// 183:
// 184:     it "treats a `user/repository` tap name as not a remote reference" do
// 185:       expect(described_class.remote_reference?("user/repo")).to be false
// 186:     end
// 187:
// 188:     it "treats a bare `@`-containing string as not a remote reference" do
// 189:       expect(described_class.remote_reference?("foo@bar")).to be false
// 190:     end
// 191:
// 192:     it "treats a `host:` with an empty path as not a remote reference" do
// 193:       expect(described_class.remote_reference?("host:")).to be false
// 194:     end
// 195:   end
// 196:
// 197:   describe "::normalize_remote" do
// 198:     it "keeps an explicit port on a GitHub remote rather than turning it into a path" do
// 199:       expect(described_class.normalize_remote("https://github.com:443/Homebrew/homebrew-core"))
// 200:         .to eq("https://github.com:443/homebrew/homebrew-core")
// 201:     end
// 202:   end
// 203:
// 204:   describe "::same_remote?" do
// 205:     it "ignores a GitHub `.git` suffix, trailing slash and case" do
// 206:       expect(described_class.same_remote?("https://github.com/Homebrew/homebrew-core.git/",
// 207:                                           "https://github.com/homebrew/homebrew-core")).to be true
// 208:     end
// 209:
// 210:     it "ignores a `.git` suffix on GitLab remotes" do
// 211:       expect(described_class.same_remote?("https://gitlab.com/other/repo.git",
// 212:                                           "https://gitlab.com/other/repo")).to be true
// 213:     end
// 214:
// 215:     it "ignores a trailing slash on GitLab remotes" do
// 216:       expect(described_class.same_remote?("https://gitlab.com/other/repo/",
// 217:                                           "https://gitlab.com/other/repo")).to be true
// 218:     end
// 219:
// 220:     it "keeps a `.git` suffix and trailing slash significant on a self-hosted remote" do
// 221:       expect(described_class.same_remote?("https://git.example.com/other/repo.git/",
// 222:                                           "https://git.example.com/other/repo")).to be false
// 223:     end
// 224:
// 225:     it "still matches non-GitHub remotes case-insensitively" do
// 226:       expect(described_class.same_remote?("https://gitlab.com/other/repo",
// 227:                                           "https://GitLab.com/Other/Repo")).to be true
// 228:     end
// 229:
// 230:     it "keeps non-GitHub remotes with different paths distinct" do
// 231:       expect(described_class.same_remote?("https://gitlab.com/other/repo",
// 232:                                           "https://gitlab.com/other/other-repo")).to be false
// 233:     end
// 234:
// 235:     it "treats a GitHub SSH SCP remote the same as HTTPS" do
// 236:       expect(described_class.same_remote?("git@github.com:Homebrew/homebrew-core",
// 237:                                           "https://github.com/Homebrew/homebrew-core")).to be true
// 238:     end
// 239:
// 240:     it "treats a GitHub ssh:// remote the same as HTTPS" do
// 241:       expect(described_class.same_remote?("ssh://git@github.com/Homebrew/homebrew-core",
// 242:                                           "https://github.com/Homebrew/homebrew-core")).to be true
// 243:     end
// 244:
// 245:     it "treats a GitHub git:// remote the same as HTTPS" do
// 246:       expect(described_class.same_remote?("git://github.com/Homebrew/homebrew-core",
// 247:                                           "https://github.com/Homebrew/homebrew-core")).to be true
// 248:     end
// 249:
// 250:     it "treats a GitHub SSH SCP remote with .git suffix the same as HTTPS" do
// 251:       expect(described_class.same_remote?("git@github.com:Homebrew/homebrew-core.git",
// 252:                                           "https://github.com/Homebrew/homebrew-core")).to be true
// 253:     end
// 254:
// 255:     it "keeps a different host distinct" do
// 256:       expect(described_class.same_remote?("https://evil.example/Homebrew/homebrew-core",
// 257:                                           "https://github.com/Homebrew/homebrew-core")).to be false
// 258:     end
// 259:   end
// 260:
// 261:   describe "#matches_reference?" do
// 262:     let(:tap) { described_class.fetch("user", "repo") }
// 263:
// 264:     it "matches a default-remote tap by its name" do
// 265:       expect(tap.matches_reference?("user/repo", remote: "https://github.com/user/homebrew-repo")).to be true
// 266:     end
// 267:
// 268:     it "matches a default-remote tap whose remote has a `.git` suffix" do
// 269:       expect(tap.matches_reference?("user/repo", remote: "https://github.com/user/homebrew-repo.git")).to be true
// 270:     end
// 271:
// 272:     it "does not match a custom-remote tap by its name" do
// 273:       expect(tap.matches_reference?("user/repo", remote: "https://gitlab.com/other/repo")).to be false
// 274:     end
// 275:
// 276:     it "matches a custom-remote tap by its remote URL" do
// 277:       expect(tap.matches_reference?("https://gitlab.com/other/repo", remote: "https://gitlab.com/other/repo"))
// 278:         .to be true
// 279:     end
// 280:
// 281:     it "matches a tap by its local path remote" do
// 282:       expect(tap.matches_reference?("/Users/me/homebrew-tap", remote: "/Users/me/homebrew-tap")).to be true
// 283:     end
// 284:
// 285:     it "matches a GitHub SSH-remote tap by its name" do
// 286:       expect(tap.matches_reference?("user/repo", remote: "git@github.com:user/homebrew-repo")).to be true
// 287:     end
// 288:
// 289:     it "matches a GitHub SSH-remote tap by its HTTPS URL reference" do
// 290:       expect(tap.matches_reference?("https://github.com/user/homebrew-repo",
// 291:                                     remote: "git@github.com:user/homebrew-repo")).to be true
// 292:     end
// 293:   end
// 294:
// 295:   describe "#allowed_by_env?" do
// 296:     before { allow(Homebrew::EnvConfig).to receive(:allowed_taps).and_return("user/repo") }
// 297:
// 298:     it "does not allow a name-matched tap fetched from a custom remote" do
// 299:       expect(described_class.fetch("user", "repo").allowed_by_env?(remote: "https://evil.example/repo")).to be false
// 300:     end
// 301:
// 302:     it "does not implicitly allow an official tap fetched from a custom remote" do
// 303:       expect(described_class.fetch("Homebrew",
// 304:                                    "foo").allowed_by_env?(remote: "https://evil.example/repo")).to be false
// 305:     end
// 306:   end
// 307:
// 308:   describe "#implicitly_trusted?" do
// 309:     it "is true for an official tap on its default remote" do
// 310:       expect(described_class.fetch("Homebrew", "foo")
// 311:         .implicitly_trusted?(remote: "https://github.com/Homebrew/homebrew-foo")).to be true
// 312:     end
// 313:
// 314:     it "is false for an official tap on a custom remote" do
// 315:       expect(described_class.fetch("Homebrew", "foo").implicitly_trusted?(remote: "https://evil.example/repo"))
// 316:         .to be false
// 317:     end
// 318:
// 319:     it "is true for homebrew/core in API mode regardless of remote" do
// 320:       with_env(HOMEBREW_NO_INSTALL_FROM_API: nil) do
// 321:         expect(CoreTap.instance.implicitly_trusted?(remote: "https://evil.example/core")).to be true
// 322:       end
// 323:     end
// 324:
// 325:     it "is true for a homebrew/core Git checkout whose remote has a `.git` suffix" do
// 326:       with_env(HOMEBREW_NO_INSTALL_FROM_API: "1") do
// 327:         expect(CoreTap.instance.implicitly_trusted?(remote: "https://github.com/Homebrew/homebrew-core.git"))
// 328:           .to be true
// 329:       end
// 330:     end
// 331:
// 332:     it "is false for a homebrew/core Git checkout from a non-official remote" do
// 333:       with_env(HOMEBREW_NO_INSTALL_FROM_API: "1") do
// 334:         expect(CoreTap.instance.implicitly_trusted?(remote: "https://evil.example/core")).to be false
// 335:       end
// 336:     end
// 337:
// 338:     it "accepts the configured HOMEBREW_CORE_GIT_REMOTE as official" do
// 339:       with_env(HOMEBREW_NO_INSTALL_FROM_API: "1", HOMEBREW_CORE_GIT_REMOTE: "https://mirror.example/core") do
// 340:         expect(CoreTap.instance.implicitly_trusted?(remote: "https://mirror.example/core")).to be true
// 341:       end
// 342:     end
// 343:   end
// 344:
// 345:   describe "#forbidden_by_env?" do
// 346:     before { allow(Homebrew::EnvConfig).to receive(:forbidden_taps).and_return("https://github.com/evil/homebrew-tap") }
// 347:
// 348:     it "forbids any locally-named tap fetched from a forbidden remote URL" do
// 349:       expect(described_class.fetch("notevil", "tap").forbidden_by_env?(remote: "https://github.com/evil/homebrew-tap"))
// 350:         .to be true
// 351:     end
// 352:   end
// 353:
// 354:   specify "attributes" do
// 355:     expect(homebrew_foo_tap.user).to eq("Homebrew")
// 356:     expect(homebrew_foo_tap.repository).to eq("foo")
// 357:     expect(homebrew_foo_tap.name).to eq("homebrew/foo")
// 358:     expect(homebrew_foo_tap.path).to eq(path)
// 359:     expect(homebrew_foo_tap).to be_installed
// 360:     expect(homebrew_foo_tap).to be_official
// 361:     expect(homebrew_foo_tap).not_to be_a_core_tap
// 362:   end
// 363:
// 364:   specify "#issues_url" do
// 365:     t = described_class.fetch("someone", "foo")
// 366:     path = HOMEBREW_TAP_DIRECTORY/"someone/homebrew-foo"
// 367:     path.mkpath
// 368:     cd path do
// 369:       system "git", "init"
// 370:       system "git", "remote", "add", "origin",
// 371:              "https://github.com/someone/homebrew-foo"
// 372:     end
// 373:     expect(t.issues_url).to eq("https://github.com/someone/homebrew-foo/issues")
// 374:     expect(homebrew_foo_tap.issues_url).to eq("https://github.com/Homebrew/homebrew-foo/issues")
// 375:
// 376:     (HOMEBREW_TAP_DIRECTORY/"someone/homebrew-no-git").mkpath
// 377:     expect(described_class.fetch("someone", "no-git").issues_url).to be_nil
// 378:   ensure
// 379:     FileUtils.rm_rf(path.parent)
// 380:   end
// 381:
// 382:   specify "files" do
// 383:     setup_tap_files
// 384:
// 385:     allow(Homebrew::Trust).to receive(:trusted_tap?).with(homebrew_foo_tap).and_return(true)
// 386:     allow(homebrew_foo_tap).to receive_messages(
// 387:       cask_tokens:     [],
// 388:       remote:          "https://github.com/Homebrew/homebrew-foo",
// 389:       custom_remote?:  false,
// 390:       private?:        false,
// 391:       git_head:        "abc123",
// 392:       git_last_commit: "1 day ago",
// 393:       git_branch:      "main",
// 394:     )
// 395:
// 396:     expect(homebrew_foo_tap.formula_files).to eq([formula_file])
// 397:     expect(homebrew_foo_tap.formula_names).to eq(["homebrew/foo/foo"])
// 398:     expect(homebrew_foo_tap.alias_files).to eq([alias_file])
// 399:     expect(homebrew_foo_tap.aliases).to eq(["homebrew/foo/bar"])
// 400:     expect(homebrew_foo_tap.alias_table).to eq("homebrew/foo/bar" => "homebrew/foo/foo")
// 401:     expect(homebrew_foo_tap.alias_reverse_table).to eq("homebrew/foo/foo" => ["homebrew/foo/bar"])
// 402:     expect(homebrew_foo_tap.formula_renames).to eq("oldname" => "foo")
// 403:     expect(homebrew_foo_tap.tap_migrations).to eq("removed-formula" => "homebrew/foo")
// 404:     expect(homebrew_foo_tap.command_files).to eq([cmd_file])
// 405:     expect(homebrew_foo_tap.to_hash).to eq(
// 406:       {
// 407:         "name"          => "homebrew/foo",
// 408:         "user"          => "Homebrew",
// 409:         "repo"          => "foo",
// 410:         "repository"    => "foo",
// 411:         "path"          => path.to_s,
// 412:         "installed"     => true,
// 413:         "official"      => true,
// 414:         "trusted"       => true,
// 415:         "formula_names" => ["homebrew/foo/foo"],
// 416:         "cask_tokens"   => [],
// 417:         "formula_files" => [formula_file.to_s],
// 418:         "cask_files"    => [],
// 419:         "command_files" => [cmd_file.to_s],
// 420:         "remote"        => "https://github.com/Homebrew/homebrew-foo",
// 421:         "custom_remote" => false,
// 422:         "private"       => false,
// 423:         "HEAD"          => "abc123",
// 424:         "last_commit"   => "1 day ago",
// 425:         "branch"        => "main",
// 426:       },
// 427:     )
// 428:     expect(homebrew_foo_tap).to have_formula_file("Formula/foo.rb")
// 429:     expect(homebrew_foo_tap).not_to have_formula_file("bar.rb")
// 430:     expect(homebrew_foo_tap).not_to have_formula_file("Formula/baz.sh")
// 431:   end
// 432:
// 433:   describe "#prefix_to_versioned_formulae_names" do
// 434:     it "groups versioned full formulae with their matching full formula" do
// 435:       homebrew_foo_tap.clear_cache
// 436:       allow(homebrew_foo_tap).to receive(:formula_names).and_return(["foo@2.0", "foo-full", "foo@2.0-full"])
// 437:
// 438:       expect(homebrew_foo_tap.prefix_to_versioned_formulae_names)
// 439:         .to include("foo" => ["foo@2.0"], "foo-full" => ["foo@2.0-full"])
// 440:     end
// 441:   end
// 442:
// 443:   describe "#remote" do
// 444:     it "returns the remote URL", :needs_network do
// 445:       setup_git_repo
// 446:
// 447:       expect(homebrew_foo_tap.remote).to eq("https://github.com/Homebrew/homebrew-foo")
// 448:       expect(homebrew_foo_tap).not_to have_custom_remote
// 449:
// 450:       services_tap = described_class.fetch("Homebrew", "test-bot")
// 451:       services_tap.path.mkpath
// 452:       services_tap.path.cd do
// 453:         system "git", "init"
// 454:         system "git", "remote", "add", "origin", "https://github.com/Homebrew/homebrew-test-bot"
// 455:       end
// 456:       expect(services_tap).not_to be_private
// 457:     end
// 458:
// 459:     it "returns nil if the Tap is not a Git repository" do
// 460:       expect(homebrew_foo_tap.remote).to be_nil
// 461:     end
// 462:
// 463:     it "reads the remote from .git/config even when Git is unavailable" do
// 464:       setup_git_repo
// 465:       allow(Utils::Git).to receive(:available?).and_return(false)
// 466:       expect(homebrew_foo_tap.remote).to eq("https://github.com/Homebrew/homebrew-foo")
// 467:     end
// 468:   end
// 469:
// 470:   describe "#remote_repo" do
// 471:     it "returns the remote https repository" do
// 472:       setup_git_repo
// 473:
// 474:       expect(homebrew_foo_tap.remote_repository).to eq("Homebrew/homebrew-foo")
// 475:
// 476:       services_tap = described_class.fetch("Homebrew", "test-bot")
// 477:       services_tap.path.mkpath
// 478:       services_tap.path.cd do
// 479:         system "git", "init"
// 480:         system "git", "remote", "add", "origin", "https://github.com/Homebrew/homebrew-bar"
// 481:       end
// 482:       expect(services_tap.remote_repository).to eq("Homebrew/homebrew-bar")
// 483:     end
// 484:
// 485:     it "returns the remote ssh repository" do
// 486:       setup_git_repo
// 487:
// 488:       expect(homebrew_foo_tap.remote_repository).to eq("Homebrew/homebrew-foo")
// 489:
// 490:       services_tap = described_class.fetch("Homebrew", "test-bot")
// 491:       services_tap.path.mkpath
// 492:       services_tap.path.cd do
// 493:         system "git", "init"
// 494:         system "git", "remote", "add", "origin", "git@github.com:Homebrew/homebrew-bar"
// 495:       end
// 496:       expect(services_tap.remote_repository).to eq("Homebrew/homebrew-bar")
// 497:     end
// 498:
// 499:     it "returns nil if the Tap is not a Git repository" do
// 500:       expect(homebrew_foo_tap.remote_repository).to be_nil
// 501:     end
// 502:
// 503:     it "reads the remote repository from .git/config even when Git is unavailable" do
// 504:       setup_git_repo
// 505:       allow(Utils::Git).to receive(:available?).and_return(false)
// 506:       expect(homebrew_foo_tap.remote_repository).to eq("Homebrew/homebrew-foo")
// 507:     end
// 508:   end
// 509:
// 510:   describe "#custom_remote?" do
// 511:     subject(:tap) { described_class.fetch("Homebrew", "test-bot") }
// 512:
// 513:     let(:remote) { nil }
// 514:
// 515:     before do
// 516:       tap.path.mkpath
// 517:       system "git", "-C", tap.path, "init"
// 518:       system "git", "-C", tap.path, "remote", "add", "origin", remote if remote
// 519:     end
// 520:
// 521:     context "if no remote is available" do
// 522:       it "returns true" do
// 523:         expect(tap.remote).to be_nil
// 524:         expect(tap.custom_remote?).to be true
// 525:       end
// 526:     end
// 527:
// 528:     context "when using the default remote" do
// 529:       let(:remote) { "https://github.com/Homebrew/homebrew-test-bot" }
// 530:
// 531:       it(:custom_remote?) { expect(tap.custom_remote?).to be false }
// 532:     end
// 533:
// 534:     context "when the default remote has a `.git` suffix" do
// 535:       let(:remote) { "https://github.com/Homebrew/homebrew-test-bot.git" }
// 536:
// 537:       it(:custom_remote?) { expect(tap.custom_remote?).to be false }
// 538:     end
// 539:
// 540:     context "when using the SSH SCP remote for the same repository" do
// 541:       let(:remote) { "git@github.com:Homebrew/homebrew-test-bot" }
// 542:
// 543:       it(:custom_remote?) { expect(tap.custom_remote?).to be false }
// 544:     end
// 545:
// 546:     context "when using a truly non-default remote" do
// 547:       let(:remote) { "https://gitlab.com/Homebrew/homebrew-test-bot" }
// 548:
// 549:       it(:custom_remote?) { expect(tap.custom_remote?).to be true }
// 550:     end
// 551:   end
// 552:
// 553:   describe "#update_remote_from_git_redirect!" do
// 554:     it "moves default GitHub taps to the redirected name and invalidates old trust", :trust_store do
// 555:       require "trust"
// 556:
// 557:       tap = described_class.fetch("oldowner", "foo")
// 558:       old_path = tap.path
// 559:       new_path = described_class.fetch("newowner", "foo").path
// 560:       tap.path.mkpath
// 561:       system "git", "-C", tap.path.to_s, "init"
// 562:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://github.com/oldowner/homebrew-foo"
// 563:       Homebrew::Trust.trust!(:tap, "oldowner/foo")
// 564:       Homebrew::Trust.trust!(:tap, "https://github.com/oldowner/homebrew-foo")
// 565:       Homebrew::Trust.trust!(:formula, "oldowner/foo/bar")
// 566:
// 567:       tap.update_remote_from_git_redirect!(
// 568:         "warning: redirecting to https://github.com/newowner/homebrew-foo\n",
// 569:         quiet: true,
// 570:       )
// 571:
// 572:       expect(tap.name).to eq("newowner/foo")
// 573:       expect(tap.path).to eq(new_path)
// 574:       expect(new_path).to be_a_directory
// 575:       expect(old_path).not_to exist
// 576:       expect(Utils.popen_read("git", "-C", tap.path, "config", "remote.origin.url").chomp)
// 577:         .to eq("https://github.com/newowner/homebrew-foo")
// 578:       expect(Homebrew::Trust.trusted_entries(:tap)).to be_empty
// 579:       expect(Homebrew::Trust.trusted_entries(:formula)).to be_empty
// 580:     ensure
// 581:       Homebrew::Trust.clear!(:tap)
// 582:       Homebrew::Trust.clear!(:formula)
// 583:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"oldowner"
// 584:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"newowner"
// 585:     end
// 586:
// 587:     it "prints tap redirect and untrust messages", :trust_store do
// 588:       require "trust"
// 589:
// 590:       tap = described_class.fetch("oldoutput", "foo")
// 591:       tap.path.mkpath
// 592:       system "git", "-C", tap.path.to_s, "init"
// 593:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://github.com/oldoutput/homebrew-foo"
// 594:       Homebrew::Trust.trust!(:tap, "oldoutput/foo")
// 595:
// 596:       expect($stderr).to receive(:ohai).with("Redirected tap oldoutput/foo to tap newoutput/foo")
// 597:       expect($stderr).to receive(:puts).with("Untrusted tap: oldoutput/foo")
// 598:
// 599:       tap.update_remote_from_git_redirect!(
// 600:         "warning: redirecting to https://github.com/newoutput/homebrew-foo\n",
// 601:       )
// 602:     ensure
// 603:       Homebrew::Trust.clear!(:tap)
// 604:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"oldoutput"
// 605:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"newoutput"
// 606:     end
// 607:
// 608:     it "updates the core cask tap remote from a redirect", :trust_store do
// 609:       tap = CoreCaskTap.instance
// 610:       tap.path.mkpath
// 611:       system "git", "-C", tap.path.to_s, "init"
// 612:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://github.com/caskroom/homebrew-cask"
// 613:
// 614:       tap.update_remote_from_git_redirect!(
// 615:         "warning: redirecting to https://github.com/Homebrew/homebrew-cask\n",
// 616:         quiet: true,
// 617:       )
// 618:
// 619:       expect(Utils.popen_read("git", "-C", tap.path, "config", "remote.origin.url").chomp)
// 620:         .to eq("https://github.com/Homebrew/homebrew-cask")
// 621:     ensure
// 622:       CoreCaskTap.instance.clear_cache
// 623:       FileUtils.rm_rf CoreCaskTap.instance.path
// 624:     end
// 625:
// 626:     it "refuses an off-allowlist redirect and preserves the original remote" do
// 627:       allow(Homebrew::EnvConfig).to receive(:allowed_taps).and_return("https://allowed.example/homebrew-foo")
// 628:       tap = described_class.fetch("allowed", "foo")
// 629:       tap.path.mkpath
// 630:       system "git", "-C", tap.path.to_s, "init"
// 631:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://allowed.example/homebrew-foo"
// 632:
// 633:       expect do
// 634:         tap.update_remote_from_git_redirect!(
// 635:           "warning: redirecting to https://attacker.example/homebrew-foo\n",
// 636:           quiet: true,
// 637:         )
// 638:       end.to raise_error(TapRedirectNotAllowedError)
// 639:       expect(Utils.popen_read("git", "-C", tap.path, "config", "remote.origin.url").chomp)
// 640:         .to eq("https://allowed.example/homebrew-foo")
// 641:     ensure
// 642:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"allowed"
// 643:     end
// 644:
// 645:     it "refuses a redirect to a forbidden tap and preserves the original remote" do
// 646:       allow(Homebrew::EnvConfig).to receive(:forbidden_taps).and_return("attacker/foo")
// 647:       tap = described_class.fetch("oldowner", "foo")
// 648:       tap.path.mkpath
// 649:       system "git", "-C", tap.path.to_s, "init"
// 650:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://github.com/oldowner/homebrew-foo"
// 651:
// 652:       expect do
// 653:         tap.update_remote_from_git_redirect!(
// 654:           "warning: redirecting to https://github.com/attacker/homebrew-foo\n",
// 655:           quiet: true,
// 656:         )
// 657:       end.to raise_error(TapRedirectNotAllowedError)
// 658:       expect(Utils.popen_read("git", "-C", tap.path, "config", "remote.origin.url").chomp)
// 659:         .to eq("https://github.com/oldowner/homebrew-foo")
// 660:     ensure
// 661:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"oldowner"
// 662:     end
// 663:
// 664:     it "applies a redirect to a tap allowed by name", :trust_store do
// 665:       allow(Homebrew::EnvConfig).to receive(:allowed_taps).and_return("newowner/foo")
// 666:       tap = described_class.fetch("oldowner", "foo")
// 667:       tap.path.mkpath
// 668:       system "git", "-C", tap.path.to_s, "init"
// 669:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://github.com/oldowner/homebrew-foo"
// 670:
// 671:       tap.update_remote_from_git_redirect!(
// 672:         "warning: redirecting to https://github.com/newowner/homebrew-foo\n",
// 673:         quiet: true,
// 674:       )
// 675:
// 676:       expect(tap.name).to eq("newowner/foo")
// 677:       expect(Utils.popen_read("git", "-C", tap.path, "config", "remote.origin.url").chomp)
// 678:         .to eq("https://github.com/newowner/homebrew-foo")
// 679:     ensure
// 680:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"oldowner"
// 681:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"newowner"
// 682:     end
// 683:
// 684:     it "treats a redirect beginning with a dash as a URL, not a git option", :trust_store do
// 685:       tap = described_class.fetch("dashy", "foo")
// 686:       tap.path.mkpath
// 687:       system "git", "-C", tap.path.to_s, "init"
// 688:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://github.com/dashy/homebrew-foo"
// 689:
// 690:       tap.update_remote_from_git_redirect!(
// 691:         "warning: redirecting to -u:evil\n",
// 692:         quiet: true,
// 693:       )
// 694:
// 695:       expect(Utils.popen_read("git", "-C", tap.path, "config", "remote.origin.url").chomp)
// 696:         .to eq("-u:evil")
// 697:     ensure
// 698:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"dashy"
// 699:     end
// 700:   end
// 701:
// 702:   describe "#fix_remote_configuration" do
// 703:     it "terminates options before the requested remote" do
// 704:       tap = described_class.fetch("dashy", "foo")
// 705:       tap.path.mkpath
// 706:       allow(tap).to receive(:remote)
// 707:       allow(tap).to receive(:safe_system)
// 708:       expect(tap).to receive(:safe_system)
// 709:         .with("git", "remote", "set-url", "origin", "--end-of-options", "-u:evil")
// 710:
// 711:       tap.fix_remote_configuration(requested_remote: "-u:evil")
// 712:     ensure
// 713:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"dashy"
// 714:     end
// 715:   end
// 716:
// 717:   specify "Git variant" do
// 718:     touch path/"README"
// 719:     setup_git_repo
// 720:
// 721:     expect(homebrew_foo_tap.git_head).to eq("0453e16c8e3fac73104da50927a86221ca0740c2")
// 722:     expect(homebrew_foo_tap.git_last_commit).to match(/\A\d+ .+ ago\Z/)
// 723:   end
// 724:
// 725:   specify "#private?", :needs_network do
// 726:     expect(homebrew_foo_tap).to be_private
// 727:   end
// 728:
// 729:   describe "#install" do
// 730:     it "disables terminal prompts for git commands" do
// 731:       require "system_command"
// 732:
// 733:       expect(SystemCommand).to receive(:run!)
// 734:         .with("git", args: ["-c", "core.hooksPath=#{File::NULL}", "fetch"], chdir: path,
// 735:               env: { "GIT_TERMINAL_PROMPT" => "0" }, print_stderr: true)
// 736:
// 737:       homebrew_foo_tap.git_command!(%w[fetch], chdir: path)
// 738:     end
// 739:
// 740:     it "does not run Git hooks" do
// 741:       setup_tap_files
// 742:       setup_git_repo
// 743:
// 744:       hook_ran_path = HOMEBREW_CACHE/"hook-ran"
// 745:       hooks_path = HOMEBREW_CACHE/"hooks"
// 746:       hooks_path.mkpath
// 747:       (hooks_path/"post-checkout").write("#!/bin/sh\ntouch #{hook_ran_path}\n")
// 748:       (hooks_path/"post-checkout").chmod(0755)
// 749:       gitconfig_path = HOMEBREW_CACHE/"gitconfig"
// 750:       gitconfig_path.write("[core]\n\thooksPath = #{hooks_path}\n")
// 751:       ENV["GIT_CONFIG_GLOBAL"] = gitconfig_path.to_s
// 752:
// 753:       clone_path = HOMEBREW_CACHE/"hooks-test-clone"
// 754:       homebrew_foo_tap.git_command!(["clone", path.to_s, clone_path.to_s])
// 755:       expect(hook_ran_path).not_to exist
// 756:     end
// 757:
// 758:     it "raises an error when the Tap is already tapped" do
// 759:       setup_git_repo
// 760:       already_tapped_tap = described_class.fetch("Homebrew", "foo")
// 761:       expect(already_tapped_tap).to be_installed
// 762:       expect { already_tapped_tap.install }.to raise_error(TapAlreadyTappedError)
// 763:     end
// 764:
// 765:     it "raises an error when the Tap is already tapped with the right remote" do
// 766:       setup_git_repo
// 767:       already_tapped_tap = described_class.fetch("Homebrew", "foo")
// 768:       expect(already_tapped_tap).to be_installed
// 769:       right_remote = homebrew_foo_tap.remote
// 770:       expect { already_tapped_tap.install clone_target: right_remote }.to raise_error(TapAlreadyTappedError)
// 771:     end
// 772:
// 773:     it "refuses a name-allowed tap cloned from a custom remote (no HOMEBREW_ALLOWED_TAPS bypass)" do
// 774:       allow(Homebrew::EnvConfig).to receive(:allowed_taps).and_return("user/repo")
// 775:       tap = described_class.fetch("user", "repo")
// 776:
// 777:       expect { tap.install clone_target: "https://evil.example/repo" }.to raise_error(SystemExit)
// 778:       expect(tap).not_to be_installed
// 779:     end
// 780:
// 781:     it "raises an error when the remote doesn't match" do
// 782:       setup_git_repo
// 783:       already_tapped_tap = described_class.fetch("Homebrew", "foo")
// 784:       expect(already_tapped_tap).to be_installed
// 785:       wrong_remote = "#{homebrew_foo_tap.remote}-oops"
// 786:       expect do
// 787:         already_tapped_tap.install clone_target: wrong_remote
// 788:       end.to raise_error(TapRemoteMismatchError)
// 789:     end
// 790:
// 791:     it "raises an error when the remote for Homebrew/core doesn't match HOMEBREW_CORE_GIT_REMOTE" do
// 792:       core_tap = described_class.fetch("Homebrew", "core")
// 793:       wrong_remote = "#{Homebrew::EnvConfig.core_git_remote}-oops"
// 794:       expect do
// 795:         core_tap.install clone_target: wrong_remote
// 796:       end.to raise_error(TapCoreRemoteMismatchError)
// 797:     end
// 798:
// 799:     it "creates an official tap worktree from the fetched remote HEAD" do
// 800:       tap = CoreCaskTap.instance
// 801:       source_repository = HOMEBREW_PREFIX.parent/"source-repository"
// 802:       source_tap = source_repository/"Library/Taps/#{tap.full_name.downcase}"
// 803:       remote = HOMEBREW_PREFIX.parent/"tap-remote"
// 804:       publisher = HOMEBREW_PREFIX.parent/"tap-publisher"
// 805:
// 806:       allow(Commands).to receive(:rebuild_commands_completion_list)
// 807:       allow(CacheStoreDatabase).to receive(:use).and_call_original
// 808:       allow(CacheStoreDatabase).to receive(:use).with(:descriptions)
// 809:       allow(CacheStoreDatabase).to receive(:use).with(:cask_descriptions)
// 810:       allow(tap).to receive_messages(command_files: [], formula_files: [], cask_files: [],
// 811:                                      formula_names: [], cask_tokens: [], link_completions_and_manpages: nil)
// 812:
// 813:       FileUtils.rm_rf tap.path
// 814:       remote.mkpath
// 815:       system "git", "-C", remote, "init", "--bare"
// 816:       system "git", "-C", remote, "symbolic-ref", "HEAD", "refs/heads/main"
// 817:       system "git", "clone", remote, publisher
// 818:       (publisher/"README.md").write "source\n"
// 819:       system "git", "-C", publisher, "add", "README.md"
// 820:       system "git", "-C", publisher, "commit", "-m", "source"
// 821:       system "git", "-C", publisher, "push", "origin", "main"
// 822:       source_tap.parent.mkpath
// 823:       system "git", "clone", remote, source_tap
// 824:       (publisher/"README.md").write "remote\n"
// 825:       system "git", "-C", publisher, "commit", "-am", "remote"
// 826:       system "git", "-C", publisher, "push"
// 827:       system "git", "-C", source_tap, "fetch", "origin"
// 828:       (source_tap/"README.md").write "local\n"
// 829:
// 830:       FileUtils.mkdir_p (HOMEBREW_REPOSITORY/".git").dirname
// 831:       (HOMEBREW_REPOSITORY/".git")
// 832:         .write "gitdir: #{source_repository}/.git/worktrees/#{HOMEBREW_REPOSITORY.basename}\n"
// 833:       remote_head = Utils.popen_read("git", "-C", publisher, "rev-parse", "HEAD").chomp
// 834:       source_head = Utils.popen_read("git", "-C", source_tap, "rev-parse", "HEAD").chomp
// 835:       source_branch = Utils.popen_read("git", "-C", source_tap, "branch", "--show-current").chomp
// 836:       source_status = Utils.popen_read("git", "-C", source_tap, "status", "--short")
// 837:
// 838:       tap.install quiet: true
// 839:
// 840:       expect([
// 841:         Utils.popen_read("git", "-C", tap.path, "rev-parse", "HEAD").chomp,
// 842:         Utils.popen_read("git", "-C", source_tap, "rev-parse", "HEAD").chomp,
// 843:         Utils.popen_read("git", "-C", source_tap, "branch", "--show-current").chomp,
// 844:         Utils.popen_read("git", "-C", source_tap, "status", "--short"),
// 845:         (source_tap/"README.md").read,
// 846:       ]).to eq([remote_head, source_head, source_branch, source_status, "local\n"])
// 847:     ensure
// 848:       FileUtils.rm_rf source_repository
// 849:       FileUtils.rm_rf remote
// 850:       FileUtils.rm_rf publisher
// 851:       FileUtils.rm_rf CoreCaskTap.instance.path
// 852:     end
// 853:
// 854:     it "creates core and cask taps as worktrees when the brew source repository has them" do
// 855:       source_repository = HOMEBREW_PREFIX.parent/"source-repository"
// 856:       worktree_git_dir = HOMEBREW_REPOSITORY/".git"
// 857:
// 858:       allow(Commands).to receive(:rebuild_commands_completion_list)
// 859:       allow(CacheStoreDatabase).to receive(:use).and_call_original
// 860:       allow(CacheStoreDatabase).to receive(:use).with(:descriptions)
// 861:       allow(CacheStoreDatabase).to receive(:use).with(:cask_descriptions)
// 862:
// 863:       [CoreTap.instance, CoreCaskTap.instance].each do |tap|
// 864:         source_tap = source_repository/"Library/Taps/#{tap.full_name.downcase}"
// 865:
// 866:         FileUtils.rm_rf tap.path
// 867:         source_tap.mkpath
// 868:         source_tap.cd do
// 869:           system "git", "init"
// 870:           FileUtils.touch "README.md"
// 871:           system "git", "add", "--all"
// 872:           system "git", "commit", "-m", "init"
// 873:         end
// 874:         FileUtils.mkdir_p worktree_git_dir.dirname
// 875:         worktree_git_dir.write "gitdir: #{source_repository}/.git/worktrees/#{HOMEBREW_REPOSITORY.basename}\n"
// 876:
// 877:         allow(tap).to receive_messages(command_files: [], formula_files: [], cask_files: [],
// 878:                                        formula_names: [], cask_tokens: [], link_completions_and_manpages: nil)
// 879:         expect(tap).to receive(:safe_system)
// 880:           .with("git", "-c", "core.hooksPath=#{File::NULL}", "-C", source_tap,
// 881:                 "worktree", "add", "--detach", tap.path, "HEAD")
// 882:           .and_wrap_original do
// 883:             tap.path.mkpath
// 884:             (tap.path/".git").write "gitdir: #{source_tap}/.git/worktrees/#{tap.full_repository.downcase}\n"
// 885:           end
// 886:
// 887:         tap.install
// 888:       end
// 889:     ensure
// 890:       FileUtils.rm_rf source_repository
// 891:       FileUtils.rm_rf CoreTap.instance.path
// 892:       FileUtils.rm_rf CoreCaskTap.instance.path
// 893:       (CoreTap.instance.path/"Formula").mkpath
// 894:     end
// 895:
// 896:     it "creates a tap from another brew worktree when that has the source repository" do
// 897:       tap = CoreCaskTap.instance
// 898:       source_repository = HOMEBREW_PREFIX.parent/"source-repository"
// 899:       source_worktree = HOMEBREW_PREFIX.parent/"source-worktree"
// 900:       source_tap = source_worktree/"Library/Taps/#{tap.full_name.downcase}"
// 901:
// 902:       allow(Commands).to receive(:rebuild_commands_completion_list)
// 903:       allow(CacheStoreDatabase).to receive(:use).and_call_original
// 904:       allow(CacheStoreDatabase).to receive(:use).with(:descriptions)
// 905:       allow(CacheStoreDatabase).to receive(:use).with(:cask_descriptions)
// 906:
// 907:       FileUtils.rm_rf tap.path
// 908:       source_tap.mkpath
// 909:       source_tap.cd do
// 910:         system "git", "init"
// 911:         FileUtils.touch "README.md"
// 912:         system "git", "add", "--all"
// 913:         system "git", "commit", "-m", "init"
// 914:       end
// 915:       FileUtils.mkdir_p (HOMEBREW_REPOSITORY/".git").dirname
// 916:       (HOMEBREW_REPOSITORY/".git")
// 917:         .write "gitdir: #{source_repository}/.git/worktrees/#{HOMEBREW_REPOSITORY.basename}\n"
// 918:
// 919:       allow(Utils).to receive(:popen_read).and_call_original
// 920:       allow(Utils).to receive(:popen_read)
// 921:         .with("git", "-C", HOMEBREW_REPOSITORY, "worktree", "list", "--porcelain")
// 922:         .and_return("worktree #{source_worktree}\n")
// 923:       allow(Utils::Git).to receive(:ensure_installed!)
// 924:       expect(SystemCommand).to receive(:run)
// 925:         .with("git", args: ["-c", "core.hooksPath=#{File::NULL}", "-C", source_tap,
// 926:                             "fetch", "origin", "HEAD"],
// 927:                      env: { "GIT_TERMINAL_PROMPT" => "0" }, print_stderr: false)
// 928:         .and_call_original
// 929:       allow(tap).to receive_messages(command_files: [], formula_files: [], cask_files: [],
// 930:                                      formula_names: [], cask_tokens: [], link_completions_and_manpages: nil)
// 931:       expect(tap).to receive(:safe_system)
// 932:         .with("git", "-c", "core.hooksPath=#{File::NULL}", "-C", source_tap,
// 933:               "worktree", "add", "--detach", tap.path, "HEAD")
// 934:         .and_wrap_original do
// 935:           tap.path.mkpath
// 936:           (tap.path/".git").write "gitdir: #{source_tap}/.git/worktrees/#{tap.full_repository.downcase}\n"
// 937:         end
// 938:
// 939:       tap.install
// 940:     ensure
// 941:       FileUtils.rm_rf source_repository
// 942:       FileUtils.rm_rf source_worktree
// 943:       FileUtils.rm_rf CoreCaskTap.instance.path
// 944:     end
// 945:
// 946:     it "uses the requested remote for cask taps with an explicit clone target" do
// 947:       tap = CoreCaskTap.instance
// 948:       requested_remote = "https://example.com/Homebrew/homebrew-cask"
// 949:       source_repository = HOMEBREW_PREFIX.parent/"source-repository"
// 950:       source_tap = source_repository/"Library/Taps/#{tap.full_name.downcase}"
// 951:
// 952:       allow(Commands).to receive(:rebuild_commands_completion_list)
// 953:       allow(CacheStoreDatabase).to receive(:use).and_call_original
// 954:       allow(CacheStoreDatabase).to receive(:use).with(:descriptions)
// 955:       allow(CacheStoreDatabase).to receive(:use).with(:cask_descriptions)
// 956:
// 957:       FileUtils.rm_rf tap.path
// 958:       source_tap.mkpath
// 959:       (source_tap/".git").mkpath
// 960:       FileUtils.mkdir_p (HOMEBREW_REPOSITORY/".git").dirname
// 961:       (HOMEBREW_REPOSITORY/".git")
// 962:         .write "gitdir: #{source_repository}/.git/worktrees/#{HOMEBREW_REPOSITORY.basename}\n"
// 963:
// 964:       allow(tap).to receive_messages(command_files: [], formula_files: [], cask_files: [],
// 965:                                      formula_names: [], cask_tokens: [], link_completions_and_manpages: nil)
// 966:       expect(tap).to receive(:git_command!)
// 967:         .with(["clone", "--origin=origin", "--template=", "--config", "core.fsmonitor=false",
// 968:                "--end-of-options", requested_remote, tap.path.to_s])
// 969:         .and_wrap_original do
// 970:           tap.path.mkpath
// 971:           (tap.path/".git").mkpath
// 972:           double(stderr: "")
// 973:         end
// 974:
// 975:       tap.install clone_target: requested_remote, force: true
// 976:     ensure
// 977:       FileUtils.rm_rf source_repository
// 978:       FileUtils.rm_rf CoreCaskTap.instance.path
// 979:     end
// 980:
// 981:     it "raises an error when run `brew tap --custom-remote` without a custom remote (already installed)" do
// 982:       setup_git_repo
// 983:       already_tapped_tap = described_class.fetch("Homebrew", "foo")
// 984:       expect(already_tapped_tap).to be_installed
// 985:
// 986:       expect do
// 987:         already_tapped_tap.install clone_target: nil, custom_remote: true
// 988:       end.to raise_error(TapNoCustomRemoteError)
// 989:     end
// 990:
// 991:     it "raises an error when run `brew tap --custom-remote` without a custom remote (not installed)" do
// 992:       not_tapped_tap = described_class.fetch("Homebrew", "bar")
// 993:       expect(not_tapped_tap).not_to be_installed
// 994:
// 995:       expect do
// 996:         not_tapped_tap.install clone_target: nil, custom_remote: true
// 997:       end.to raise_error(TapNoCustomRemoteError)
// 998:     end
// 999:
// 1000:     specify "Git error" do
// 1001:       tap = described_class.fetch("user", "repo")
// 1002:
// 1003:       expect do
// 1004:         tap.install clone_target: "file:///not/existed/remote/url"
// 1005:       end.to raise_error(ErrorDuringExecution)
// 1006:
// 1007:       expect(tap).not_to be_installed
// 1008:       expect(HOMEBREW_TAP_DIRECTORY/"user").not_to exist
// 1009:     end
// 1010:   end
// 1011:
// 1012:   describe "#uninstall" do
// 1013:     it "raises an error if the Tap is not available" do
// 1014:       tap = described_class.fetch("Homebrew", "bar")
// 1015:       expect { tap.uninstall }.to raise_error(TapUnavailableError)
// 1016:     end
// 1017:
// 1018:     it "removes Git worktree metadata for worktree-installed taps" do
// 1019:       tap = CoreCaskTap.instance
// 1020:       source_tap = HOMEBREW_PREFIX.parent/"source-tap"
// 1021:
// 1022:       FileUtils.rm_rf tap.path
// 1023:       source_tap.mkpath
// 1024:       (source_tap/".git").mkpath
// 1025:       tap.path.mkpath
// 1026:       (tap.path/".git").write "gitdir: #{source_tap}/.git/worktrees/#{tap.full_repository.downcase}\n"
// 1027:
// 1028:       allow(tap).to receive_messages(contents: [], formula_names: [], cask_tokens: [])
// 1029:       expect(tap).to receive(:safe_system)
// 1030:         .with("git", "-C", source_tap, "worktree", "remove", "--force", tap.path)
// 1031:
// 1032:       tap.uninstall
// 1033:     ensure
// 1034:       FileUtils.rm_rf source_tap
// 1035:       FileUtils.rm_rf CoreCaskTap.instance.path
// 1036:     end
// 1037:   end
// 1038:
// 1039:   specify "#install and #uninstall" do
// 1040:     setup_tap_files
// 1041:     setup_git_repo
// 1042:     setup_completion link: true
// 1043:
// 1044:     tap = described_class.fetch("Homebrew", "bar")
// 1045:
// 1046:     tap.install clone_target: homebrew_foo_tap.path/".git"
// 1047:
// 1048:     expect(tap).to be_installed
// 1049:     expect(HOMEBREW_PREFIX/"share/man/man1/brew-tap-cmd.1").to be_a_file
// 1050:     expect(HOMEBREW_PREFIX/"etc/bash_completion.d/brew-tap-cmd").to be_a_file
// 1051:     expect(HOMEBREW_PREFIX/"share/zsh/site-functions/_brew-tap-cmd").to be_a_file
// 1052:     expect(HOMEBREW_PREFIX/"share/fish/vendor_completions.d/brew-tap-cmd.fish").to be_a_file
// 1053:     tap.uninstall
// 1054:
// 1055:     expect(tap).not_to be_installed
// 1056:     expect(HOMEBREW_PREFIX/"share/man/man1/brew-tap-cmd.1").not_to exist
// 1057:     expect(HOMEBREW_PREFIX/"share/man/man1").not_to exist
// 1058:     expect(HOMEBREW_PREFIX/"etc/bash_completion.d/brew-tap-cmd").not_to exist
// 1059:     expect(HOMEBREW_PREFIX/"share/zsh/site-functions/_brew-tap-cmd").not_to exist
// 1060:     expect(HOMEBREW_PREFIX/"share/fish/vendor_completions.d/brew-tap-cmd.fish").not_to exist
// 1061:   ensure
// 1062:     FileUtils.rm_r(HOMEBREW_PREFIX/"etc") if (HOMEBREW_PREFIX/"etc").exist?
// 1063:     FileUtils.rm_r(HOMEBREW_PREFIX/"share") if (HOMEBREW_PREFIX/"share").exist?
// 1064:   end
// 1065:
// 1066:   specify "#link_completions_and_manpages when completions are enabled for non-official tap" do
// 1067:     tap = T.let(nil, T.untyped)
// 1068:     setup_tap_files
// 1069:     setup_git_repo
// 1070:     setup_completion link: true
// 1071:     tap = described_class.fetch("NotHomebrew", "baz")
// 1072:     tap.install clone_target: homebrew_foo_tap.path/".git"
// 1073:     (HOMEBREW_PREFIX/"share/man/man1/brew-tap-cmd.1").delete
// 1074:     (HOMEBREW_PREFIX/"etc/bash_completion.d/brew-tap-cmd").delete
// 1075:     (HOMEBREW_PREFIX/"share/zsh/site-functions/_brew-tap-cmd").delete
// 1076:     (HOMEBREW_PREFIX/"share/fish/vendor_completions.d/brew-tap-cmd.fish").delete
// 1077:     tap.link_completions_and_manpages
// 1078:     expect(HOMEBREW_PREFIX/"share/man/man1/brew-tap-cmd.1").to be_a_file
// 1079:     expect(HOMEBREW_PREFIX/"etc/bash_completion.d/brew-tap-cmd").to be_a_file
// 1080:     expect(HOMEBREW_PREFIX/"share/zsh/site-functions/_brew-tap-cmd").to be_a_file
// 1081:     expect(HOMEBREW_PREFIX/"share/fish/vendor_completions.d/brew-tap-cmd.fish").to be_a_file
// 1082:     tap.uninstall
// 1083:   ensure
// 1084:     tap.uninstall if tap&.installed?
// 1085:     FileUtils.rm_r(HOMEBREW_PREFIX/"etc") if (HOMEBREW_PREFIX/"etc").exist?
// 1086:     FileUtils.rm_r(HOMEBREW_PREFIX/"share") if (HOMEBREW_PREFIX/"share").exist?
// 1087:   end
// 1088:
// 1089:   specify "#link_completions_and_manpages when completions are disabled for non-official tap" do
// 1090:     tap = T.let(nil, T.untyped)
// 1091:     setup_tap_files
// 1092:     setup_git_repo
// 1093:     setup_completion link: false
// 1094:     tap = described_class.fetch("NotHomebrew", "baz")
// 1095:     tap.install clone_target: homebrew_foo_tap.path/".git"
// 1096:     (HOMEBREW_PREFIX/"share/man/man1/brew-tap-cmd.1").delete
// 1097:     tap.link_completions_and_manpages
// 1098:     expect(HOMEBREW_PREFIX/"share/man/man1/brew-tap-cmd.1").to be_a_file
// 1099:     expect(HOMEBREW_PREFIX/"etc/bash_completion.d/brew-tap-cmd").not_to be_a_file
// 1100:     expect(HOMEBREW_PREFIX/"share/zsh/site-functions/_brew-tap-cmd").not_to be_a_file
// 1101:     expect(HOMEBREW_PREFIX/"share/fish/vendor_completions.d/brew-tap-cmd.fish").not_to be_a_file
// 1102:     tap.uninstall
// 1103:   ensure
// 1104:     tap.uninstall if tap&.installed?
// 1105:     FileUtils.rm_r(HOMEBREW_PREFIX/"etc") if (HOMEBREW_PREFIX/"etc").exist?
// 1106:     FileUtils.rm_r(HOMEBREW_PREFIX/"share") if (HOMEBREW_PREFIX/"share").exist?
// 1107:   end
// 1108:
// 1109:   specify "#link_completions_and_manpages when completions are enabled for official tap" do
// 1110:     setup_tap_files
// 1111:     setup_git_repo
// 1112:     setup_completion link: false
// 1113:     tap = described_class.fetch("Homebrew", "baz")
// 1114:     tap.install clone_target: homebrew_foo_tap.path/".git"
// 1115:     (HOMEBREW_PREFIX/"share/man/man1/brew-tap-cmd.1").delete
// 1116:     (HOMEBREW_PREFIX/"etc/bash_completion.d/brew-tap-cmd").delete
// 1117:     (HOMEBREW_PREFIX/"share/zsh/site-functions/_brew-tap-cmd").delete
// 1118:     (HOMEBREW_PREFIX/"share/fish/vendor_completions.d/brew-tap-cmd.fish").delete
// 1119:     tap.link_completions_and_manpages
// 1120:     expect(HOMEBREW_PREFIX/"share/man/man1/brew-tap-cmd.1").to be_a_file
// 1121:     expect(HOMEBREW_PREFIX/"etc/bash_completion.d/brew-tap-cmd").to be_a_file
// 1122:     expect(HOMEBREW_PREFIX/"share/zsh/site-functions/_brew-tap-cmd").to be_a_file
// 1123:     expect(HOMEBREW_PREFIX/"share/fish/vendor_completions.d/brew-tap-cmd.fish").to be_a_file
// 1124:     tap.uninstall
// 1125:   ensure
// 1126:     FileUtils.rm_r(HOMEBREW_PREFIX/"etc") if (HOMEBREW_PREFIX/"etc").exist?
// 1127:     FileUtils.rm_r(HOMEBREW_PREFIX/"share") if (HOMEBREW_PREFIX/"share").exist?
// 1128:   end
// 1129:
// 1130:   specify "#config" do
// 1131:     setup_git_repo
// 1132:
// 1133:     expect(homebrew_foo_tap.config[:foo]).to be_nil
// 1134:     homebrew_foo_tap.config[:foo] = true
// 1135:     expect(homebrew_foo_tap.config[:foo]).to be true
// 1136:     homebrew_foo_tap.config.delete(:foo)
// 1137:     expect(homebrew_foo_tap.config[:foo]).to be_nil
// 1138:   end
// 1139:
// 1140:   describe ".each" do
// 1141:     it "returns an enumerator if no block is passed" do
// 1142:       expect(described_class.each).to be_an_instance_of(Enumerator)
// 1143:     end
// 1144:
// 1145:     context "when the core tap is not installed" do
// 1146:       around do |example|
// 1147:         FileUtils.rm_rf CoreTap.instance.path
// 1148:         example.run
// 1149:       ensure
// 1150:         (CoreTap.instance.path/"Formula").mkpath
// 1151:       end
// 1152:
// 1153:       it "includes the core tap with the api" do
// 1154:         expect(described_class.to_a).to include(CoreTap.instance)
// 1155:       end
// 1156:
// 1157:       it "omits the core tap without the api", :no_api do
// 1158:         expect(described_class.to_a).not_to include(CoreTap.instance)
// 1159:       end
// 1160:     end
// 1161:   end
// 1162:
// 1163:   describe ".installed" do
// 1164:     it "includes only installed taps" do
// 1165:       expect(described_class.installed)
// 1166:         .to contain_exactly(CoreTap.instance, described_class.fetch("homebrew/foo"))
// 1167:     end
// 1168:   end
// 1169:
// 1170:   describe ".all" do
// 1171:     it "includes the core and cask taps by default", :needs_macos do
// 1172:       expect(described_class.all).to contain_exactly(
// 1173:         CoreTap.instance,
// 1174:         CoreCaskTap.instance,
// 1175:         described_class.fetch("homebrew/foo"),
// 1176:         described_class.fetch("third-party/tap"),
// 1177:       )
// 1178:     end
// 1179:
// 1180:     it "includes the core and cask taps by default", :needs_linux do
// 1181:       expect(described_class.all).to contain_exactly(
// 1182:         CoreTap.instance,
// 1183:         CoreCaskTap.instance,
// 1184:         described_class.fetch("homebrew/foo"),
// 1185:       )
// 1186:     end
// 1187:   end
// 1188:
// 1189:   describe "Formula Lists" do
// 1190:     describe "#formula_renames" do
// 1191:       it "returns the formula_renames hash" do
// 1192:         setup_tap_files
// 1193:
// 1194:         expected_result = { "oldname" => "foo" }
// 1195:         expect(homebrew_foo_tap.formula_renames).to eq expected_result
// 1196:       end
// 1197:     end
// 1198:
// 1199:     describe "#tap_migrations" do
// 1200:       it "returns the tap_migrations hash" do
// 1201:         setup_tap_files
// 1202:
// 1203:         expected_result = { "removed-formula" => "homebrew/foo" }
// 1204:         expect(homebrew_foo_tap.tap_migrations).to eq expected_result
// 1205:       end
// 1206:     end
// 1207:
// 1208:     describe "tap migration renames" do
// 1209:       before do
// 1210:         (path/"tap_migrations.json").write <<~JSON
// 1211:           {
// 1212:             "adobe-air-sdk": "homebrew/cask",
// 1213:             "app-engine-go-32": "homebrew/cask/google-cloud-sdk",
// 1214:             "app-engine-go-64": "homebrew/cask/google-cloud-sdk",
// 1215:             "gimp": "homebrew/cask",
// 1216:             "horndis": "homebrew/cask",
// 1217:             "inkscape": "homebrew/cask",
// 1218:             "schismtracker": "homebrew/cask/schism-tracker"
// 1219:           }
// 1220:         JSON
// 1221:       end
// 1222:
// 1223:       describe "#reverse_tap_migration_renames" do
// 1224:         it "returns the expected hash" do
// 1225:           expect(homebrew_foo_tap.reverse_tap_migrations_renames).to eq({
// 1226:             "homebrew/cask/google-cloud-sdk" => %w[app-engine-go-32 app-engine-go-64],
// 1227:             "homebrew/cask/schism-tracker"   => %w[schismtracker],
// 1228:           })
// 1229:         end
// 1230:       end
// 1231:
// 1232:       describe ".tap_migration_oldnames" do
// 1233:         let(:cask_tap) { CoreCaskTap.instance }
// 1234:         let(:core_tap) { CoreTap.instance }
// 1235:
// 1236:         it "returns expected renames", :no_api do
// 1237:           [
// 1238:             [cask_tap, "gimp", []],
// 1239:             [core_tap, "schism-tracker", []],
// 1240:             [cask_tap, "schism-tracker", %w[schismtracker]],
// 1241:             [cask_tap, "google-cloud-sdk", %w[app-engine-go-32 app-engine-go-64]],
// 1242:           ].each do |tap, name, result|
// 1243:             expect(described_class.tap_migration_oldnames(tap, name)).to eq(result)
// 1244:           end
// 1245:         end
// 1246:       end
// 1247:     end
// 1248:
// 1249:     describe "#audit_exceptions" do
// 1250:       it "returns the audit_exceptions hash" do
// 1251:         setup_tap_files
// 1252:
// 1253:         expected_result = {
// 1254:           formula_list: ["foo", "bar"],
// 1255:           formula_hash: { "foo" => "foo1", "bar" => "bar1" },
// 1256:         }
// 1257:         expect(homebrew_foo_tap.audit_exceptions).to eq expected_result
// 1258:       end
// 1259:     end
// 1260:
// 1261:     describe "#style_exceptions" do
// 1262:       it "returns the style_exceptions hash" do
// 1263:         setup_tap_files
// 1264:
// 1265:         expected_result = {
// 1266:           formula_list: ["foo", "bar"],
// 1267:           formula_hash: { "foo" => "foo1", "bar" => "bar1" },
// 1268:         }
// 1269:         expect(homebrew_foo_tap.style_exceptions).to eq expected_result
// 1270:       end
// 1271:     end
// 1272:
// 1273:     describe "#formula_file?" do
// 1274:       it "matches files from Formula/" do
// 1275:         tap = described_class.fetch("hard/core")
// 1276:         FileUtils.mkdir_p(tap.path/"Formula")
// 1277:
// 1278:         %w[
// 1279:           kvazaar.rb
// 1280:           Casks/kvazaar.rb
// 1281:           Casks/k/kvazaar.rb
// 1282:           Formula/kvazaar.sh
// 1283:           HomebrewFormula/kvazaar.rb
// 1284:           HomebrewFormula/k/kvazaar.rb
// 1285:         ].each do |relative_path|
// 1286:           expect(tap).not_to have_formula_file(relative_path)
// 1287:         end
// 1288:
// 1289:         %w[
// 1290:           Formula/kvazaar.rb
// 1291:           Formula/k/kvazaar.rb
// 1292:         ].each do |relative_path|
// 1293:           expect(tap).to have_formula_file(relative_path)
// 1294:         end
// 1295:       ensure
// 1296:         FileUtils.rm_rf(tap.path.parent) if tap
// 1297:       end
// 1298:
// 1299:       it "matches files from HomebrewFormula/" do
// 1300:         tap = described_class.fetch("hard/core")
// 1301:         FileUtils.mkdir_p(tap.path/"HomebrewFormula")
// 1302:
// 1303:         %w[
// 1304:           kvazaar.rb
// 1305:           Casks/kvazaar.rb
// 1306:           Casks/k/kvazaar.rb
// 1307:           Formula/kvazaar.rb
// 1308:           Formula/k/kvazaar.rb
// 1309:           HomebrewFormula/kvazaar.sh
// 1310:         ].each do |relative_path|
// 1311:           expect(tap).not_to have_formula_file(relative_path)
// 1312:         end
// 1313:
// 1314:         %w[
// 1315:           HomebrewFormula/kvazaar.rb
// 1316:           HomebrewFormula/k/kvazaar.rb
// 1317:         ].each do |relative_path|
// 1318:           expect(tap).to have_formula_file(relative_path)
// 1319:         end
// 1320:       ensure
// 1321:         FileUtils.rm_rf(tap.path.parent) if tap
// 1322:       end
// 1323:
// 1324:       it "matches files from the top-level directory" do
// 1325:         tap = described_class.fetch("hard/core")
// 1326:         FileUtils.mkdir_p(tap.path)
// 1327:
// 1328:         %w[
// 1329:           kvazaar.sh
// 1330:           Casks/kvazaar.rb
// 1331:           Casks/k/kvazaar.rb
// 1332:           Formula/kvazaar.rb
// 1333:           Formula/k/kvazaar.rb
// 1334:           HomebrewFormula/kvazaar.rb
// 1335:           HomebrewFormula/k/kvazaar.rb
// 1336:         ].each do |relative_path|
// 1337:           expect(tap).not_to have_formula_file(relative_path)
// 1338:         end
// 1339:
// 1340:         expect(tap).to have_formula_file("kvazaar.rb")
// 1341:       ensure
// 1342:         FileUtils.rm_rf(tap.path.parent) if tap
// 1343:       end
// 1344:     end
// 1345:
// 1346:     describe "#cask_file?" do
// 1347:       it "matches files from Casks/" do
// 1348:         tap = described_class.fetch("hard/core")
// 1349:
// 1350:         %w[
// 1351:           kvazaar.rb
// 1352:           Casks/kvazaar.sh
// 1353:           Formula/kvazaar.rb
// 1354:           Formula/k/kvazaar.rb
// 1355:           HomebrewFormula/kvazaar.rb
// 1356:           HomebrewFormula/k/kvazaar.rb
// 1357:         ].each do |relative_path|
// 1358:           expect(tap).not_to have_cask_file(relative_path)
// 1359:         end
// 1360:
// 1361:         %w[
// 1362:           Casks/kvazaar.rb
// 1363:           Casks/k/kvazaar.rb
// 1364:         ].each do |relative_path|
// 1365:           expect(tap).to have_cask_file(relative_path)
// 1366:         end
// 1367:       end
// 1368:     end
// 1369:   end
// 1370:
// 1371:   describe CoreTap do
// 1372:     subject(:core_tap) { described_class.instance }
// 1373:
// 1374:     specify "attributes" do
// 1375:       expect(core_tap.user).to eq("Homebrew")
// 1376:       expect(core_tap.repository).to eq("core")
// 1377:       expect(core_tap.name).to eq("homebrew/core")
// 1378:       expect(core_tap.command_files).to eq([])
// 1379:       expect(core_tap).to be_installed
// 1380:       expect(core_tap).to be_official
// 1381:       expect(core_tap).to be_a_core_tap
// 1382:     end
// 1383:
// 1384:     specify "forbidden operations", :no_api do
// 1385:       expect { core_tap.uninstall }.to raise_error(RuntimeError)
// 1386:     end
// 1387:
// 1388:     specify "#autobump reads public formula API metadata" do
// 1389:       core_tap.remove_instance_variable(:@autobump) if core_tap.instance_variable_defined?(:@autobump)
// 1390:       expect(Homebrew::API::Internal).not_to receive(:formula_hashes)
// 1391:       allow(Homebrew::API::Formula).to receive(:all_formulae).and_return({
// 1392:         "autobumped" => { "autobump" => true, "skip_livecheck" => false },
// 1393:         "disabled"   => { "autobump" => true, "disabled" => true },
// 1394:         "skipped"    => { "autobump" => true, "skip_livecheck" => true },
// 1395:       })
// 1396:
// 1397:       expect(core_tap.autobump).to eq(["autobumped"])
// 1398:     end
// 1399:
// 1400:     specify "#autobump reads public cask API metadata" do
// 1401:       cask_tap = CoreCaskTap.instance
// 1402:       cask_tap.remove_instance_variable(:@autobump) if cask_tap.instance_variable_defined?(:@autobump)
// 1403:       expect(Homebrew::API::Formula).not_to receive(:all_formulae)
// 1404:       expect(Homebrew::API::Internal).not_to receive(:cask_hashes)
// 1405:       allow(Homebrew::API::Cask).to receive(:all_casks).and_return({
// 1406:         "autobumped" => { "autobump" => true, "skip_livecheck" => false },
// 1407:         "disabled"   => { "autobump" => true, "disabled" => true },
// 1408:         "skipped"    => { "autobump" => true, "skip_livecheck" => true },
// 1409:       })
// 1410:
// 1411:       expect(cask_tap.autobump).to eq(["autobumped"])
// 1412:     end
// 1413:
// 1414:     specify "files", :no_api do
// 1415:       path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-core"
// 1416:       formula_file = core_tap.formula_dir/"foo.rb"
// 1417:       core_tap.formula_dir.mkpath
// 1418:       formula_file.write <<~RUBY
// 1419:         class Foo < Formula
// 1420:           url "https://brew.sh/foo-1.0.tar.gz"
// 1421:         end
// 1422:       RUBY
// 1423:
// 1424:       formula_list_file_json = '{ "foo": "foo1", "bar": "bar1" }'
// 1425:       formula_list_file_contents = { "foo" => "foo1", "bar" => "bar1" }
// 1426:       %w[
// 1427:         formula_renames.json
// 1428:         tap_migrations.json
// 1429:         audit_exceptions/formula_list.json
// 1430:         style_exceptions/formula_hash.json
// 1431:       ].each do |file|
// 1432:         (path/file).dirname.mkpath
// 1433:         (path/file).write formula_list_file_json
// 1434:       end
// 1435:
// 1436:       alias_file = core_tap.alias_dir/"bar"
// 1437:       alias_file.parent.mkpath
// 1438:       ln_s formula_file, alias_file
// 1439:
// 1440:       expect(core_tap.formula_files).to eq([formula_file])
// 1441:       expect(core_tap.formula_names).to eq(["foo"])
// 1442:       expect(core_tap.alias_files).to eq([alias_file])
// 1443:       expect(core_tap.aliases).to eq(["bar"])
// 1444:       expect(core_tap.alias_table).to eq("bar" => "foo")
// 1445:       expect(core_tap.alias_reverse_table).to eq("foo" => ["bar"])
// 1446:
// 1447:       expect(core_tap.formula_renames).to eq formula_list_file_contents
// 1448:       expect(core_tap.tap_migrations).to eq formula_list_file_contents
// 1449:       expect(core_tap.audit_exceptions).to eq({ formula_list: formula_list_file_contents })
// 1450:       expect(core_tap.style_exceptions).to eq({ formula_hash: formula_list_file_contents })
// 1451:     end
// 1452:   end
// 1453:
// 1454:   describe "#repository_var_suffix" do
// 1455:     specify do
// 1456:       expect(CoreTap.instance.repository_var_suffix).to eq "_HOMEBREW_HOMEBREW_CORE"
// 1457:       expect(
// 1458:         described_class.fetch("my", "tap-with-dashes").repository_var_suffix,
// 1459:       ).to eq "_MY_HOMEBREW_TAP_WITH_DASHES"
// 1460:       expect(
// 1461:         described_class.fetch("my", "tap-with-@-symbol").repository_var_suffix,
// 1462:       ).to eq "_MY_HOMEBREW_TAP_WITH___SYMBOL"
// 1463:     end
// 1464:   end
// 1465:
// 1466:   describe "::with_formula_name" do
// 1467:     it "returns the tap and formula name when given a full name" do
// 1468:       expect(described_class.with_formula_name("homebrew/core/gcc")).to eq [CoreTap.instance, "gcc"]
// 1469:     end
// 1470:
// 1471:     it "returns nil when given a relative path" do
// 1472:       expect(described_class.with_formula_name("./Formula/gcc.rb")).to be_nil
// 1473:     end
// 1474:   end
// 1475:
// 1476:   describe "::with_cask_token" do
// 1477:     it "returns the tap and cask token when given a full token" do
// 1478:       expect(described_class.with_cask_token("homebrew/cask/alfred")).to eq [CoreCaskTap.instance, "alfred"]
// 1479:     end
// 1480:
// 1481:     it "returns nil when given a relative path" do
// 1482:       expect(described_class.with_cask_token("./Casks/alfred.rb")).to be_nil
// 1483:     end
// 1484:   end
// 1485: end
