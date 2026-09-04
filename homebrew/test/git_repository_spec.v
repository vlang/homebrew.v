module test

import ruby
import homebrew
import os
import time

// Translated from Homebrew/brew `test/git_repository_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct GitRepositorySpecContext {
pub:
	repo_root   string
	remote_path string
	work_path   string
	clone_path  string
	branch_name string
	tag_name    string
}

fn git_repository_spec_run(arguments []string, chdir string) !string {
	mut argv := ['git']
	argv << arguments
	result := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
		chdir: chdir
	})!
	if result.exit_code != 0 {
		return error('git ${arguments.join(' ')} failed: ${result.stderr}${result.stdout}')
	}
	return result.stdout.trim_right('\r\n')
}

fn git_repository_spec_temp_root() !string {
	root := os.join_path(os.temp_dir(), 'brew-v-git-repository-${os.getpid()}-${time.now().unix_nano()}')
	os.mkdir_all(root)!
	return root
}

pub fn new_git_repository_spec_context() !GitRepositorySpecContext {
	root := git_repository_spec_temp_root()!
	branch := 'main'
	remote := os.join_path(root, 'origin.git')
	work := os.join_path(root, 'work')
	clone := os.join_path(root, 'clone')
	git_repository_spec_run(['-c', 'init.defaultBranch=${branch}', 'init', '--bare', remote], root)!
	os.mkdir_all(work)!
	git_repository_spec_run(['-c', 'init.defaultBranch=${branch}', 'init'], work)!
	git_repository_spec_run(['config', 'user.name', 'Brew V'], work)!
	git_repository_spec_run(['config', 'user.email', 'brew-v@example.invalid'], work)!
	os.write_file(os.join_path(work, 'README.md'), 'README')!
	git_repository_spec_run(['add', 'README.md'], work)!
	git_repository_spec_run(['commit', '-m', 'init'], work)!
	git_repository_spec_run(['remote', 'add', 'origin', remote], work)!
	git_repository_spec_run(['push', '-u', 'origin', 'refs/heads/${branch}:refs/heads/${branch}'], work)!
	git_repository_spec_run(['tag', branch], work)!
	git_repository_spec_run(['push', 'origin', 'refs/tags/${branch}'], work)!
	git_repository_spec_run(['symbolic-ref', 'HEAD', 'refs/heads/${branch}'], remote)!
	git_repository_spec_run(['clone', remote, clone], root)!
	git_repository_spec_run(['remote', 'set-head', 'origin', '--auto'], clone)!
	return GitRepositorySpecContext{
		repo_root: root
		remote_path: remote
		work_path: work
		clone_path: clone
		branch_name: branch
		tag_name: branch
	}
}

pub fn (context GitRepositorySpecContext) cleanup() {
	os.rmdir_all(context.repo_root) or {}
}

fn git_repository_spec_unexpected_runner(_ homebrew.GitRepository, arguments []string,
	_ homebrew.GitPopenOptions) !ruby.CapturedCommandResult {
	if arguments.len > 0 && arguments[0] in ['rev-parse', 'symbolic-ref'] {
		return ruby.CapturedCommandResult{
			exit_code: 0
			stdout: 'refs/tags/main\n'
		}
	}
	return ruby.CapturedCommandResult{ exit_code: 1 }
}

// Ruby subject `subject(:git_repo) { described_class.new(clone_path) }` at line 7.
pub fn ruby_git_repository_spec_l7_d1_git_repo(context GitRepositorySpecContext) homebrew.GitRepository {
	return homebrew.new_git_repository(context.clone_path)
}

// Ruby let `let(:branch_name) { "main" }` at line 9.
pub fn ruby_git_repository_spec_l9_d2_branch_name() string {
	return 'main'
}

// Ruby let `let(:tag_name) { branch_name }` at line 10.
pub fn ruby_git_repository_spec_l10_d3_tag_name() string {
	return ruby_git_repository_spec_l9_d2_branch_name()
}

// Ruby let `let(:repo_root) { mktmpdir }` at line 11.
pub fn ruby_git_repository_spec_l11_d4_repo_root() !string {
	return git_repository_spec_temp_root()
}

// Ruby let `let(:remote_path) { repo_root/"origin.git" }` at line 12.
pub fn ruby_git_repository_spec_l12_d5_remote_path(repo_root string) string {
	return os.join_path(repo_root, 'origin.git')
}

// Ruby let `let(:work_path) { repo_root/"work" }` at line 13.
pub fn ruby_git_repository_spec_l13_d6_work_path(repo_root string) string {
	return os.join_path(repo_root, 'work')
}

// Ruby let `let(:clone_path) { repo_root/"clone" }` at line 14.
pub fn ruby_git_repository_spec_l14_d7_clone_path(repo_root string) string {
	return os.join_path(repo_root, 'clone')
}

// Ruby it `it "reads the origin URL when the global Git config is unusable" do` at line 41.
pub fn ruby_git_repository_spec_l41_d8_reads() !bool {
	context := new_git_repository_spec_context()!
	defer { context.cleanup() }
	global_config := os.join_path(context.repo_root, 'global.gitconfig')
	os.write_file(global_config, '[broken\n')!
	previous := os.getenv_opt('GIT_CONFIG_GLOBAL')
	os.setenv('GIT_CONFIG_GLOBAL', global_config, true)
	defer {
		if value := previous {
			os.setenv('GIT_CONFIG_GLOBAL', value, true)
		} else {
			os.unsetenv('GIT_CONFIG_GLOBAL')
		}
	}
	result := ruby_git_repository_spec_l7_d1_git_repo(context).origin_url()!
	return result.present && result.value == context.remote_path
}

// Ruby it `it "reads the origin URL from .git/config without spawning Git" do` at line 51.
pub fn ruby_git_repository_spec_l51_d9_reads() !bool {
	context := new_git_repository_spec_context()!
	defer { context.cleanup() }
	result := ruby_git_repository_spec_l7_d1_git_repo(context).origin_url_from_config()
	return result.present && result.value == context.remote_path
}

// Ruby it `it "falls back to Git when the config has more than one origin URL" do` at line 56.
pub fn ruby_git_repository_spec_l56_d10_falls() !bool {
	context := new_git_repository_spec_context()!
	defer { context.cleanup() }
	other_url := 'https://brew.sh/other.git'
	config_path := os.join_path(context.clone_path, '.git', 'config')
	config := os.read_file(config_path)!
	os.write_file(config_path, '${config}[remote "origin"]\n\turl = ${other_url}\n')!
	result := ruby_git_repository_spec_l7_d1_git_repo(context).origin_url()!
	return result.present && result.value == other_url
}

// Ruby it `it "returns the HEAD commit hash, relative commit time and branch name in one Git invocation" do` at line 65.
pub fn ruby_git_repository_spec_l65_d11_returns() !bool {
	context := new_git_repository_spec_context()!
	defer { context.cleanup() }
	repository := ruby_git_repository_spec_l7_d1_git_repo(context)
	info := repository.head_info()!
	head := repository.head_ref(false)!
	committed := repository.last_committed()!
	if !info.head_present || !head.present || info.head != head.value || !info.last_committed_present || !committed.present || info.last_committed != committed.value || info.branch != context.branch_name {
		return false
	}
	git_repository_spec_run(['checkout', '--quiet', '--detach'], context.clone_path)!
	if repository.head_info()!.branch != 'HEAD' {
		return false
	}
	nonexistent := homebrew.new_git_repository(os.join_path(context.repo_root, 'nonexistent')).head_info()!
	return !nonexistent.head_present && !nonexistent.last_committed_present && !nonexistent.branch_present
}

// Ruby it `it "disambiguates branch_name, origin_branch_name, and default_origin_branch?" do` at line 78.
pub fn ruby_git_repository_spec_l78_d12_disambiguates() !bool {
	context := new_git_repository_spec_context()!
	defer { context.cleanup() }
	repository := ruby_git_repository_spec_l7_d1_git_repo(context)
	branch := repository.branch_name(false)!
	origin := repository.origin_branch_name()!
	if !branch.present || branch.value != context.branch_name || !origin.present || origin.value != context.branch_name || !repository.default_origin_branch()! {
		return false
	}
	git_repository_spec_run(['checkout', '-b', 'feature'], context.clone_path)!
	return !repository.default_origin_branch()!
}

// Ruby it `it "returns HEAD when detached at a tag" do` at line 90.
pub fn ruby_git_repository_spec_l90_d13_returns() !bool {
	context := new_git_repository_spec_context()!
	defer { context.cleanup() }
	git_repository_spec_run(['checkout', 'refs/tags/${context.tag_name}'], context.clone_path)!
	branch := ruby_git_repository_spec_l7_d1_git_repo(context).branch_name(false)!
	return branch.present && branch.value == 'HEAD'
}

// Ruby it `it "disambiguates branch_name when refs/stash exists" do` at line 98.
pub fn ruby_git_repository_spec_l98_d14_disambiguates() !bool {
	context := new_git_repository_spec_context()!
	defer { context.cleanup() }
	git_repository_spec_run(['checkout', '-b', 'stash'], context.clone_path)!
	os.write_file(os.join_path(context.clone_path, 'README.md'), 'README stash')!
	git_repository_spec_run(['stash', '--include-untracked'], context.clone_path)!
	branch := ruby_git_repository_spec_l7_d1_git_repo(context).branch_name(false)!
	return branch.present && branch.value == 'stash'
}

// Ruby it `it "preserves branch names starting with heads/" do` at line 108.
pub fn ruby_git_repository_spec_l108_d15_preserves() !bool {
	context := new_git_repository_spec_context()!
	defer { context.cleanup() }
	git_repository_spec_run(['checkout', '-b', 'heads/feature'], context.clone_path)!
	branch := ruby_git_repository_spec_l7_d1_git_repo(context).branch_name(false)!
	return branch.present && branch.value == 'heads/feature'
}

// Ruby it `it "raises on unexpected ref prefixes" do` at line 116.
pub fn ruby_git_repository_spec_l116_d16_raises() !bool {
	root := git_repository_spec_temp_root()!
	defer { os.rmdir_all(root) or {} }
	os.mkdir_all(os.join_path(root, '.git'))!
	repository := homebrew.new_git_repository(root)
	homebrew.branch_name_with_runner(repository, false, git_repository_spec_unexpected_runner) or {
		if !err.msg().contains('Unexpected HEAD ref') {
			return false
		}
		_ := homebrew.origin_branch_name_with_runner(repository, git_repository_spec_unexpected_runner) or {
			return err.msg().contains('Unexpected origin/HEAD ref')
		}
		return false
	}
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "git_repository"
// 5:
// 6: RSpec.describe GitRepository do
// 7:   subject(:git_repo) { described_class.new(clone_path) }
// 8:
// 9:   let(:branch_name) { "main" }
// 10:   let(:tag_name) { branch_name }
// 11:   let(:repo_root) { mktmpdir }
// 12:   let(:remote_path) { repo_root/"origin.git" }
// 13:   let(:work_path) { repo_root/"work" }
// 14:   let(:clone_path) { repo_root/"clone" }
// 15:
// 16:   before do
// 17:     safe_system Utils::Git.git, "-c", "init.defaultBranch=#{branch_name}", "init", "--bare", remote_path
// 18:
// 19:     work_path.mkpath
// 20:     work_path.cd do
// 21:       safe_system Utils::Git.git, "-c", "init.defaultBranch=#{branch_name}", "init"
// 22:       Pathname("README.md").write("README")
// 23:       safe_system Utils::Git.git, "add", "README.md"
// 24:       safe_system Utils::Git.git, "commit", "-m", "init"
// 25:       safe_system Utils::Git.git, "remote", "add", "origin", remote_path
// 26:       safe_system Utils::Git.git, "push", "-u", "origin", "refs/heads/#{branch_name}:refs/heads/#{branch_name}"
// 27:       safe_system Utils::Git.git, "tag", tag_name
// 28:       safe_system Utils::Git.git, "push", "origin", "refs/tags/#{tag_name}"
// 29:     end
// 30:
// 31:     remote_path.cd do
// 32:       safe_system Utils::Git.git, "symbolic-ref", "HEAD", "refs/heads/#{branch_name}"
// 33:     end
// 34:
// 35:     safe_system Utils::Git.git, "clone", remote_path, clone_path
// 36:     clone_path.cd do
// 37:       safe_system Utils::Git.git, "remote", "set-head", "origin", "--auto"
// 38:     end
// 39:   end
// 40:
// 41:   it "reads the origin URL when the global Git config is unusable" do
// 42:     global_config = repo_root/"global.gitconfig"
// 43:     global_config.write("[broken\n")
// 44:
// 45:     with_env(GIT_CONFIG_GLOBAL: global_config.to_s) do
// 46:       expect(git_repo.origin_url).to eq(remote_path.to_s)
// 47:     end
// 48:   end
// 49:
// 50:   describe "#origin_url" do
// 51:     it "reads the origin URL from .git/config without spawning Git" do
// 52:       allow(git_repo).to receive(:popen_git).and_raise("Git should not be spawned")
// 53:       expect(git_repo.origin_url).to eq(remote_path.to_s)
// 54:     end
// 55:
// 56:     it "falls back to Git when the config has more than one origin URL" do
// 57:       other_url = "https://brew.sh/other.git"
// 58:       config = clone_path/".git/config"
// 59:       config.write(%Q(#{config.read}[remote "origin"]\n\turl = #{other_url}\n))
// 60:       expect(git_repo.origin_url).to eq(other_url)
// 61:     end
// 62:   end
// 63:
// 64:   describe "#head_info" do
// 65:     it "returns the HEAD commit hash, relative commit time and branch name in one Git invocation" do
// 66:       expect(git_repo.head_info).to eq([git_repo.head_ref, git_repo.last_committed, branch_name])
// 67:
// 68:       clone_path.cd do
// 69:         safe_system Utils::Git.git, "checkout", "--quiet", "--detach"
// 70:       end
// 71:       expect(git_repo.head_info[2]).to eq("HEAD")
// 72:
// 73:       expect(described_class.new(repo_root/"nonexistent").head_info).to eq([nil, nil, nil])
// 74:     end
// 75:   end
// 76:
// 77:   describe "when the origin has a branch and tag with the same name" do
// 78:     it "disambiguates branch_name, origin_branch_name, and default_origin_branch?" do
// 79:       expect(git_repo.branch_name).to eq(branch_name)
// 80:       expect(git_repo.origin_branch_name).to eq(branch_name)
// 81:       expect(git_repo.default_origin_branch?).to be true
// 82:
// 83:       clone_path.cd do
// 84:         safe_system Utils::Git.git, "checkout", "-b", "feature"
// 85:       end
// 86:
// 87:       expect(git_repo.default_origin_branch?).to be false
// 88:     end
// 89:
// 90:     it "returns HEAD when detached at a tag" do
// 91:       clone_path.cd do
// 92:         safe_system Utils::Git.git, "checkout", "refs/tags/#{tag_name}"
// 93:       end
// 94:
// 95:       expect(git_repo.branch_name).to eq("HEAD")
// 96:     end
// 97:
// 98:     it "disambiguates branch_name when refs/stash exists" do
// 99:       clone_path.cd do
// 100:         safe_system Utils::Git.git, "checkout", "-b", "stash"
// 101:         Pathname("README.md").write("README stash")
// 102:         safe_system Utils::Git.git, "stash", "--include-untracked"
// 103:       end
// 104:
// 105:       expect(git_repo.branch_name).to eq("stash")
// 106:     end
// 107:
// 108:     it "preserves branch names starting with heads/" do
// 109:       clone_path.cd do
// 110:         safe_system Utils::Git.git, "checkout", "-b", "heads/feature"
// 111:       end
// 112:
// 113:       expect(git_repo.branch_name).to eq("heads/feature")
// 114:     end
// 115:
// 116:     it "raises on unexpected ref prefixes" do
// 117:       allow(git_repo).to receive(:popen_git)
// 118:         .with("rev-parse", "--symbolic-full-name", "HEAD", safe: false)
// 119:         .and_return("refs/tags/#{tag_name}")
// 120:       allow(git_repo).to receive(:popen_git)
// 121:         .with("symbolic-ref", "-q", "refs/remotes/origin/HEAD")
// 122:         .and_return("refs/tags/#{tag_name}")
// 123:
// 124:       expect { git_repo.branch_name }.to raise_error(RuntimeError, /Unexpected HEAD ref/)
// 125:       expect { git_repo.origin_branch_name }.to raise_error(RuntimeError, %r{Unexpected origin/HEAD ref})
// 126:     end
// 127:   end
// 128: end
