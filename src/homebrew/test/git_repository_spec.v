module test

import brew_runtime

// Translated from Homebrew/brew `test/git_repository_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:git_repo) { described_class.new(clone_path) }` at line 7.
pub fn ruby_git_repository_spec_l7_d1_git_repo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('git_repo', ...args)
}

// Ruby let `let(:branch_name) { "main" }` at line 9.
pub fn ruby_git_repository_spec_l9_d2_branch_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('branch_name', ...args)
}

// Ruby let `let(:tag_name) { branch_name }` at line 10.
pub fn ruby_git_repository_spec_l10_d3_tag_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tag_name', ...args)
}

// Ruby let `let(:repo_root) { mktmpdir }` at line 11.
pub fn ruby_git_repository_spec_l11_d4_repo_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repo_root', ...args)
}

// Ruby let `let(:remote_path) { repo_root/"origin.git" }` at line 12.
pub fn ruby_git_repository_spec_l12_d5_remote_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remote_path', ...args)
}

// Ruby let `let(:work_path) { repo_root/"work" }` at line 13.
pub fn ruby_git_repository_spec_l13_d6_work_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('work_path', ...args)
}

// Ruby let `let(:clone_path) { repo_root/"clone" }` at line 14.
pub fn ruby_git_repository_spec_l14_d7_clone_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clone_path', ...args)
}

// Ruby it `it "reads the origin URL when the global Git config is unusable" do` at line 41.
pub fn ruby_git_repository_spec_l41_d8_reads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reads', ...args)
}

// Ruby it `it "reads the origin URL from .git/config without spawning Git" do` at line 51.
pub fn ruby_git_repository_spec_l51_d9_reads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reads', ...args)
}

// Ruby it `it "falls back to Git when the config has more than one origin URL" do` at line 56.
pub fn ruby_git_repository_spec_l56_d10_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "returns the HEAD commit hash, relative commit time and branch name in one Git invocation" do` at line 65.
pub fn ruby_git_repository_spec_l65_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "disambiguates branch_name, origin_branch_name, and default_origin_branch?" do` at line 78.
pub fn ruby_git_repository_spec_l78_d12_disambiguates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('disambiguates', ...args)
}

// Ruby it `it "returns HEAD when detached at a tag" do` at line 90.
pub fn ruby_git_repository_spec_l90_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "disambiguates branch_name when refs/stash exists" do` at line 98.
pub fn ruby_git_repository_spec_l98_d14_disambiguates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('disambiguates', ...args)
}

// Ruby it `it "preserves branch names starting with heads/" do` at line 108.
pub fn ruby_git_repository_spec_l108_d15_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "raises on unexpected ref prefixes" do` at line 116.
pub fn ruby_git_repository_spec_l116_d16_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
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
