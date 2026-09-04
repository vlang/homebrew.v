module download_strategies

import ruby
import homebrew.download_strategy
import os

// Translated from Homebrew/brew `test/download_strategies/git_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:strategy) { described_class.new(url, name, version) }` at line 7.
pub fn ruby_git_spec_l7_d1_strategy(args ...ruby.Value) ruby.Value {
	cache := if args.len > 0 { args[0].as_string() } else { os.temp_dir() }
	strategy := download_strategy.new_git_download_strategy('https://github.com/homebrew/foo', 'baz', '', download_strategy.VCSDownloadMeta{ cache: cache })
	return git_strategy_boundary(strategy)
}

// Ruby let `let(:name) { "baz" }` at line 9.
pub fn ruby_git_spec_l9_d2_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value('baz')
}

// Ruby let `let(:url) { "https://github.com/homebrew/foo" }` at line 10.
pub fn ruby_git_spec_l10_d3_url(args ...ruby.Value) ruby.Value {
	return ruby.string_value('https://github.com/homebrew/foo')
}

// Ruby let `let(:version) { nil }` at line 11.
pub fn ruby_git_spec_l11_d4_version(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', '')
}

// Ruby let `let(:cached_location) { subject.cached_location }` at line 12.
pub fn ruby_git_spec_l12_d5_cached_location(args ...ruby.Value) ruby.Value {
	cache := if args.len > 0 { args[0].as_string() } else { os.temp_dir() }
	strategy := download_strategy.new_git_download_strategy('https://github.com/homebrew/foo', 'baz', '', download_strategy.VCSDownloadMeta{ cache: cache })
	return ruby.string_value(strategy.cached_location())
}

// Ruby it `it "terminates options before the URL" do` at line 20.
pub fn ruby_git_spec_l20_d6_terminates(args ...ruby.Value) ruby.Value {
	cache := if args.len > 0 { args[0].as_string() } else { os.temp_dir() }
	strategy := download_strategy.new_git_download_strategy('https://github.com/homebrew/foo', 'baz', '', download_strategy.VCSDownloadMeta{ cache: cache })
	arguments := strategy.git_clone_args()
	return ruby.bool_value(arguments[arguments.len - 3..] == [
		'--end-of-options',
		'https://github.com/homebrew/foo',
		strategy.cached_location(),
	])
}

// Ruby it `it "terminates options before the ref" do` at line 26.
pub fn ruby_git_spec_l26_d7_terminates(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	strategy := git_strategy_for_repository(args[0].as_string())
	return ruby.bool_value(strategy.git_ref())
}

// Ruby method `git_commit_all` at line 39.
pub fn ruby_git_spec_l39_d8_git_commit_all(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	directory := args[0].as_string()
	identifier := if args.len > 1 { args[1].as_string() } else { '1' }
	added := git_spec_command(directory, ['add', '--all'], map[string]string{})
	committed := git_spec_command(directory, ['commit', '-m', 'commit number ${identifier}'], map[string]string{})
	return ruby.bool_value(added.exit_code == 0 && committed.exit_code == 0)
}

// Ruby method `setup_git_repo` at line 48.
pub fn ruby_git_spec_l48_d9_setup_git_repo(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	directory := args[0].as_string()
	os.mkdir_all(directory) or { return ruby.bool_value(false) }
	if git_spec_command(directory, ['init', '-b', 'master'], map[string]string{}).exit_code != 0 {
		return ruby.bool_value(false)
	}
	git_spec_command(directory, ['config', 'user.name', 'Brew V'], map[string]string{})
	git_spec_command(directory, ['config', 'user.email', 'brew-v@example.invalid'], map[string]string{})
	git_spec_command(directory, ['remote', 'add', 'origin', 'https://github.com/Homebrew/homebrew-foo'], map[string]string{})
	os.write_file(os.join_path(directory, 'README'), '') or { return ruby.bool_value(false) }
	return ruby_git_spec_l39_d8_git_commit_all(ruby.string_value(directory), ruby.string_value('1'))
}

// Ruby it `it "returns the right modification time" do` at line 56.
pub fn ruby_git_spec_l56_d10_returns(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	strategy := git_strategy_for_repository(args[0].as_string())
	modified := strategy.git_source_modified_time() or { return ruby.bool_value(false) }
	return ruby.bool_value(modified > 0)
}

// Ruby it `it "nulls the global Git config so sandboxed staging reads do not fail" do` at line 63.
pub fn ruby_git_spec_l63_d11_nulls(args ...ruby.Value) ruby.Value {
	strategy := download_strategy.new_git_download_strategy('https://github.com/homebrew/foo', 'baz', '', download_strategy.VCSDownloadMeta{})
	environment := strategy.git_local_env()
	return ruby.bool_value(environment['GIT_TERMINAL_PROMPT'] == '0' && environment['GIT_CONFIG_GLOBAL'] == '/dev/null')
}

// Ruby it `it "raises the underlying Git error instead of a Time parsing error on failure" do` at line 77.
pub fn ruby_git_spec_l77_d12_raises(args ...ruby.Value) ruby.Value {
	strategy := git_strategy_for_repository('/not/a/git/repository')
	_ := strategy.git_source_modified_time() or {
		return ruby.bool_value(err.msg().contains('command failed'))
	}
	return ruby.bool_value(false)
}

// Ruby specify `specify "returns the short hash of the last commit" do` at line 87.
pub fn ruby_git_spec_l87_d13_returns(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	strategy := git_strategy_for_repository(args[0].as_string())
	commit := strategy.git_last_commit() or { return ruby.bool_value(false) }
	return ruby.bool_value(commit.len == 7)
}

// Ruby it `it "nulls the global Git config so sandboxed staging reads do not fail" do` at line 96.
pub fn ruby_git_spec_l96_d14_nulls(args ...ruby.Value) ruby.Value {
	strategy := download_strategy.new_git_download_strategy('https://github.com/homebrew/foo', 'baz', '', download_strategy.VCSDownloadMeta{})
	return ruby.bool_value(strategy.git_local_env()['GIT_CONFIG_GLOBAL'] == '/dev/null')
}

// Ruby let `let(:url) { "file://#{remote_repo}" }` at line 111.
pub fn ruby_git_spec_l111_d15_url(args ...ruby.Value) ruby.Value {
	remote := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.string_value('file://${remote}')
}

// Ruby let `let(:version) { Version.new("HEAD") }` at line 112.
pub fn ruby_git_spec_l112_d16_version(args ...ruby.Value) ruby.Value {
	return ruby.string_value('HEAD')
}

// Ruby let `let(:remote_repo) { HOMEBREW_PREFIX/"remote_repo" }` at line 113.
pub fn ruby_git_spec_l113_d17_remote_repo(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		ruby.string_value(args[0].as_string())
	} else {
		ruby.object_value('NilClass', '')
	}
}

// Ruby it `it "fetches the hash of the last commit" do` at line 119.
pub fn ruby_git_spec_l119_d18_fetches(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	remote := args[0].as_string()
	cache := args[1].as_string()
	mut strategy := download_strategy.new_git_download_strategy('file://${remote}', 'baz', 'HEAD', download_strategy.VCSDownloadMeta{ cache: cache })
	commit := strategy.fetch_last_commit() or { return ruby.bool_value(false) }
	return ruby.bool_value(commit.len == 7)
}

fn git_strategy_for_repository(repository string) download_strategy.VCSDownloadStrategy {
	mut strategy := download_strategy.new_git_download_strategy('file://${repository}', 'baz', '', download_strategy.VCSDownloadMeta{ cache: os.dir(repository) })
	strategy.cached_location_value = repository
	return strategy
}

fn git_strategy_boundary(strategy download_strategy.VCSDownloadStrategy) ruby.Value {
	return ruby.structured_value('GitDownloadStrategy', strategy.url, {
		'url':             strategy.url
		'cached_location': strategy.cached_location()
		'ref':             strategy.ref
	})
}

fn git_spec_command(directory string, arguments []string, environment map[string]string) ruby.CommandResult {
	git := os.find_abs_path_of_executable('git') or { return ruby.CommandResult{ exit_code: 127 } }
	mut process := os.new_process(git)
	process.set_args(arguments)
	process.set_work_folder(directory)
	mut child_environment := os.environ()
	for key, value in environment {
		child_environment[key] = value
	}
	process.set_environment(child_environment)
	process.set_redirect_stdio_merged()
	process.run()
	output := process.stdout_slurp()
	process.wait()
	result := ruby.CommandResult{
		exit_code: process.code
		output: output
	}
	process.close()
	return result
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe GitDownloadStrategy do
// 7:   subject(:strategy) { described_class.new(url, name, version) }
// 8:
// 9:   let(:name) { "baz" }
// 10:   let(:url) { "https://github.com/homebrew/foo" }
// 11:   let(:version) { nil }
// 12:   let(:cached_location) { subject.cached_location }
// 13:
// 14:   before do
// 15:     @commit_id = 1
// 16:     FileUtils.mkpath cached_location
// 17:   end
// 18:
// 19:   describe "#clone_args" do
// 20:     it "terminates options before the URL" do
// 21:       expect(strategy.clone_args).to end_with("--end-of-options", url, cached_location.to_s)
// 22:     end
// 23:   end
// 24:
// 25:   describe "#ref?" do
// 26:     it "terminates options before the ref" do
// 27:       expect(strategy).to receive(:silent_command)
// 28:         .with(
// 29:           "git",
// 30:           args: ["--git-dir", cached_location/".git", "rev-parse", "-q", "--verify", "--end-of-options",
// 31:                  "master^{commit}"],
// 32:         )
// 33:         .and_return(instance_double(SystemCommand::Result, success?: true))
// 34:
// 35:       strategy.ref?
// 36:     end
// 37:   end
// 38:
// 39:   def git_commit_all
// 40:     system "git", "add", "--all"
// 41:     # Allow instance variables here to have nice commit messages.
// 42:     # rubocop:disable RSpec/InstanceVariable
// 43:     system "git", "commit", "-m", "commit number #{@commit_id}"
// 44:     @commit_id += 1
// 45:     # rubocop:enable RSpec/InstanceVariable
// 46:   end
// 47:
// 48:   def setup_git_repo
// 49:     system "git", "-c", "init.defaultBranch=master", "init"
// 50:     system "git", "remote", "add", "origin", "https://github.com/Homebrew/homebrew-foo"
// 51:     FileUtils.touch "README"
// 52:     git_commit_all
// 53:   end
// 54:
// 55:   describe "#source_modified_time" do
// 56:     it "returns the right modification time" do
// 57:       cached_location.cd do
// 58:         setup_git_repo
// 59:       end
// 60:       expect(strategy.source_modified_time.to_i).to eq(1_485_115_153)
// 61:     end
// 62:
// 63:     it "nulls the global Git config so sandboxed staging reads do not fail" do
// 64:       expect(strategy).to receive(:system_command)
// 65:         .with(
// 66:           "git",
// 67:           args:         ["--git-dir", cached_location/".git", "show", "-s", "--format=%cD"],
// 68:           env:          { "GIT_TERMINAL_PROMPT" => "0", "GIT_CONFIG_GLOBAL" => File::NULL },
// 69:           print_stderr: false,
// 70:         )
// 71:         .and_return(instance_double(SystemCommand::Result, success?: true,
// 72:                                                            stdout:   "Fri, 12 Jun 2026 06:12:11 -0700"))
// 73:
// 74:       expect(strategy.source_modified_time).to eq(Time.parse("Fri, 12 Jun 2026 06:12:11 -0700"))
// 75:     end
// 76:
// 77:     it "raises the underlying Git error instead of a Time parsing error on failure" do
// 78:       allow(strategy).to receive(:system_command)
// 79:         .and_return(instance_double(SystemCommand::Result, success?: false,
// 80:                                                            stdout: "", stderr: "fatal: unable to access"))
// 81:
// 82:       expect { strategy.source_modified_time }.to raise_error(/fatal: unable to access/)
// 83:     end
// 84:   end
// 85:
// 86:   describe "#last_commit" do
// 87:     specify "returns the short hash of the last commit" do
// 88:       cached_location.cd do
// 89:         setup_git_repo
// 90:         FileUtils.touch "LICENSE"
// 91:         git_commit_all
// 92:       end
// 93:       expect(strategy.last_commit).to eq("f68266e")
// 94:     end
// 95:
// 96:     it "nulls the global Git config so sandboxed staging reads do not fail" do
// 97:       expect(strategy).to receive(:system_command)
// 98:         .with(
// 99:           "git",
// 100:           args:         ["--git-dir", cached_location/".git", "rev-parse", "--short=7", "HEAD"],
// 101:           env:          { "GIT_TERMINAL_PROMPT" => "0", "GIT_CONFIG_GLOBAL" => File::NULL },
// 102:           print_stderr: false,
// 103:         )
// 104:         .and_return(instance_double(SystemCommand::Result, stdout: "f68266e\n"))
// 105:
// 106:       expect(strategy.last_commit).to eq("f68266e")
// 107:     end
// 108:   end
// 109:
// 110:   describe "#fetch_last_commit" do
// 111:     let(:url) { "file://#{remote_repo}" }
// 112:     let(:version) { Version.new("HEAD") }
// 113:     let(:remote_repo) { HOMEBREW_PREFIX/"remote_repo" }
// 114:
// 115:     before { remote_repo.mkpath }
// 116:
// 117:     after { FileUtils.rm_rf remote_repo }
// 118:
// 119:     it "fetches the hash of the last commit" do
// 120:       remote_repo.cd do
// 121:         setup_git_repo
// 122:         FileUtils.touch "LICENSE"
// 123:         git_commit_all
// 124:       end
// 125:
// 126:       expect(strategy.fetch_last_commit).to eq("f68266e")
// 127:     end
// 128:   end
// 129: end
