module download_strategy

import os

// Translated from Homebrew/brew `download_strategy/mercurial_download_strategy.rb`.
// The original source is retained below for line-for-line traceability.

// Ruby method `initialize(url, name, version, **meta)` at line 9.
pub fn new_mercurial_download_strategy(source_url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	url := if source_url.starts_with('hg://') { source_url['hg://'.len..] } else { source_url }
	mut strategy := new_vcs_download_strategy(url, name, version, meta, 'hg', .mercurial)
	strategy.url = url
	return strategy
}

// Ruby method `source_modified_time` at line 18.
pub fn (strategy &VCSDownloadStrategy) mercurial_source_modified_time() !i64 {
	result := vcs_command_checked('hg', ['tip', '--template', '{date|isodate}', '-R',
		strategy.cached_location_value], '', strategy.mercurial_env(), none)!
	return parse_vcs_timestamp(result.output)!
}

// Ruby method `source_revision = current_revision.presence` at line 23.
pub fn (strategy &VCSDownloadStrategy) mercurial_source_revision() !string {
	return strategy.mercurial_current_revision()
}

// Ruby method `last_commit` at line 29.
pub fn (strategy &VCSDownloadStrategy) mercurial_last_commit() !string {
	result := vcs_command_checked('hg', ['parent', '--template', '{node|short}', '-R',
		strategy.cached_location_value], '', strategy.mercurial_env(), none)!
	return result.output.trim_space()
}

// Ruby method `env` at line 36.
pub fn (strategy &VCSDownloadStrategy) mercurial_env() map[string]string {
	_ = strategy
	return formula_opt_bin_environment('mercurial', false)
}

// Ruby method `cache_tag` at line 41.
pub fn (strategy &VCSDownloadStrategy) mercurial_cache_tag() string {
	_ = strategy
	return 'hg'
}

// Ruby method `repo_valid?` at line 46.
pub fn (strategy &VCSDownloadStrategy) mercurial_repo_valid() bool {
	return os.is_dir(os.join_path(strategy.cached_location_value, '.hg'))
}

// Ruby method `clone_repo(timeout: nil)` at line 51.
pub fn (mut strategy VCSDownloadStrategy) mercurial_clone_repo(deadline ?i64) ! {
	mut arguments := ['clone']
	match strategy.ref_type {
		.branch {
			arguments << '--branch'
			arguments << strategy.ref
		}
		.revision, .tag {
			arguments << '--rev'
			arguments << strategy.ref
		}
		else {}
	}
	arguments << strategy.url
	arguments << strategy.cached_location_value
	vcs_command_checked('hg', arguments, '', strategy.mercurial_env(), deadline)!
}

// Ruby method `update(timeout: nil)` at line 66.
pub fn (mut strategy VCSDownloadStrategy) mercurial_update(deadline ?i64) ! {
	mut pull_arguments := ['--cwd', strategy.cached_location_value, 'pull']
	match strategy.ref_type {
		.branch {
			pull_arguments << '--branch'
			pull_arguments << strategy.ref
		}
		.revision, .tag {
			pull_arguments << '--rev'
			pull_arguments << strategy.ref
		}
		else {}
	}
	vcs_command_checked('hg', pull_arguments, '', strategy.mercurial_env(), deadline)!
	mut update_ref := 'default'
	if strategy.ref_type != .unspecified && strategy.ref != '' {
		strategy.base.ohai('Checking out ${strategy.ref_type} ${strategy.ref}')
		update_ref = strategy.ref
	}
	vcs_command_checked('hg', ['--cwd', strategy.cached_location_value, 'update', '--clean',
		update_ref], '', strategy.mercurial_env(), deadline)!
}

// Ruby method `current_revision` at line 90.
pub fn (strategy &VCSDownloadStrategy) mercurial_current_revision() !string {
	result := vcs_command_checked('hg', ['--cwd', strategy.cached_location_value, 'identify', '--id'], '', strategy.mercurial_env(), none)!
	return result.output.trim_space()
}

// Source entrypoint translations.
pub fn ruby_mercurial_download_strategy_l9_d1_initialize(url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	return new_mercurial_download_strategy(url, name, version, meta)
}

pub fn ruby_mercurial_download_strategy_l18_d2_source_modified_time(strategy &VCSDownloadStrategy) !i64 {
	return strategy.mercurial_source_modified_time()
}

pub fn ruby_mercurial_download_strategy_l23_d3_source_revision(strategy &VCSDownloadStrategy) !string {
	return strategy.mercurial_source_revision()
}

pub fn ruby_mercurial_download_strategy_l29_d4_last_commit(strategy &VCSDownloadStrategy) !string {
	return strategy.mercurial_last_commit()
}

pub fn ruby_mercurial_download_strategy_l36_d5_env(strategy &VCSDownloadStrategy) map[string]string {
	return strategy.mercurial_env()
}

pub fn ruby_mercurial_download_strategy_l41_d6_cache_tag(strategy &VCSDownloadStrategy) string {
	return strategy.mercurial_cache_tag()
}

pub fn ruby_mercurial_download_strategy_l46_d7_repo_valid(strategy &VCSDownloadStrategy) bool {
	return strategy.mercurial_repo_valid()
}

pub fn ruby_mercurial_download_strategy_l51_d8_clone_repo(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.mercurial_clone_repo(deadline)!
}

pub fn ruby_mercurial_download_strategy_l66_d9_update(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.mercurial_update(deadline)!
}

pub fn ruby_mercurial_download_strategy_l90_d10_current_revision(strategy &VCSDownloadStrategy) !string {
	return strategy.mercurial_current_revision()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading a Mercurial repository.
// 5: #
// 6: # @api public
// 7: class MercurialDownloadStrategy < VCSDownloadStrategy
// 8:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 9:   def initialize(url, name, version, **meta)
// 10:     super
// 11:     @url = T.let(@url.sub(%r{^hg://}, ""), String)
// 12:   end
// 13:
// 14:   # Returns the most recent modified time for all files in the current working directory after stage.
// 15:   #
// 16:   # @api public
// 17:   sig { override.returns(Time) }
// 18:   def source_modified_time
// 19:     Time.parse(silent_command("hg", args: ["tip", "--template", "{date|isodate}", "-R", cached_location]).stdout)
// 20:   end
// 21:
// 22:   sig { override.returns(T.nilable(String)) }
// 23:   def source_revision = current_revision.presence
// 24:
// 25:   # Return last commit's unique identifier for the repository.
// 26:   #
// 27:   # @api public
// 28:   sig { override.returns(String) }
// 29:   def last_commit
// 30:     silent_command("hg", args: ["parent", "--template", "{node|short}", "-R", cached_location]).stdout.chomp
// 31:   end
// 32:
// 33:   private
// 34:
// 35:   sig { override.returns(T::Hash[String, String]) }
// 36:   def env
// 37:     Utils::Path.formula_opt_bin_env("mercurial")
// 38:   end
// 39:
// 40:   sig { override.returns(String) }
// 41:   def cache_tag
// 42:     "hg"
// 43:   end
// 44:
// 45:   sig { override.returns(T::Boolean) }
// 46:   def repo_valid?
// 47:     (cached_location/".hg").directory?
// 48:   end
// 49:
// 50:   sig { override.params(timeout: T.nilable(Time)).void }
// 51:   def clone_repo(timeout: nil)
// 52:     clone_args = %w[clone]
// 53:
// 54:     case @ref_type
// 55:     when :branch
// 56:       clone_args << "--branch" << @ref
// 57:     when :revision, :tag
// 58:       clone_args << "--rev" << @ref
// 59:     end
// 60:
// 61:     clone_args << @url << cached_location.to_s
// 62:     command! "hg", args: clone_args, timeout: Utils::Timer.remaining(timeout)
// 63:   end
// 64:
// 65:   sig { override.params(timeout: T.nilable(Time)).void }
// 66:   def update(timeout: nil)
// 67:     pull_args = %w[pull]
// 68:
// 69:     case @ref_type
// 70:     when :branch
// 71:       pull_args << "--branch" << @ref
// 72:     when :revision, :tag
// 73:       pull_args << "--rev" << @ref
// 74:     end
// 75:
// 76:     command! "hg", args: ["--cwd", cached_location, *pull_args], timeout: Utils::Timer.remaining(timeout)
// 77:
// 78:     update_args = %w[update --clean]
// 79:     update_args << if @ref_type && @ref
// 80:       ohai "Checking out #{@ref_type} #{@ref}"
// 81:       @ref
// 82:     else
// 83:       "default"
// 84:     end
// 85:
// 86:     command! "hg", args: ["--cwd", cached_location, *update_args], timeout: Utils::Timer.remaining(timeout)
// 87:   end
// 88:
// 89:   sig { override.returns(String) }
// 90:   def current_revision
// 91:     silent_command("hg", args: ["--cwd", cached_location, "identify", "--id"]).stdout.strip
// 92:   end
// 93: end
