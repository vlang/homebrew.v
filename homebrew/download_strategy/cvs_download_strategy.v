module download_strategy

import os

// Translated from Homebrew/brew `download_strategy/cvs_download_strategy.rb`.
// The original source is retained below for line-for-line traceability.

// Ruby method `initialize(url, name, version, **meta)` at line 9.
pub fn new_cvs_download_strategy(source_url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	mut url := source_url
	if url.starts_with('cvs://') {
		url = url['cvs://'.len..]
	}
	mut module_name := meta.module_name
	if module_name == '' {
		last_slash := url.last_index('/') or { -1 }
		last_colon := url.last_index(':') or { -1 }
		if last_colon > last_slash {
			module_name, url = cvs_split_url(url)
		} else {
			module_name = name
		}
	}
	mut strategy := new_vcs_download_strategy(url, name, version, meta, 'cvs', .cvs)
	strategy.url = url
	strategy.module_name = module_name
	return strategy
}

// Ruby method `source_modified_time` at line 30. CVS administrative
// directories are pruned because CVS sets their mtimes at checkout time.
pub fn (strategy &VCSDownloadStrategy) cvs_source_modified_time() !i64 {
	return cvs_latest_source_mtime(strategy.cached_location_value)
}

fn cvs_latest_source_mtime(directory string) !i64 {
	mut latest := i64(0)
	for entry in os.ls(directory)! {
		path := os.join_path(directory, entry)
		if os.is_dir(path) && !os.is_link(path) {
			if entry == 'CVS' {
				continue
			}
			modified := cvs_latest_source_mtime(path)!
			if modified > latest {
				latest = modified
			}
		} else if os.is_file(path) {
			modified := os.file_last_mod_unix(path)
			if modified > latest {
				latest = modified
			}
		}
	}
	return latest
}

// Ruby method `env` at line 47.
pub fn (strategy &VCSDownloadStrategy) cvs_env() map[string]string {
	_ = strategy
	return formula_opt_bin_environment('cvs', true)
}

// Ruby method `cache_tag` at line 52.
pub fn (strategy &VCSDownloadStrategy) cvs_cache_tag() string {
	_ = strategy
	return 'cvs'
}

// Ruby method `repo_valid?` at line 57.
pub fn (strategy &VCSDownloadStrategy) cvs_repo_valid() bool {
	return os.is_dir(os.join_path(strategy.cached_location_value, 'CVS'))
}

// Ruby method `quiet_flag` at line 62.
pub fn (strategy &VCSDownloadStrategy) cvs_quiet_flag() ?string {
	if !strategy.verbose {
		return '-Q'
	}
	return none
}

fn (strategy &VCSDownloadStrategy) cvs_command_args(arguments []string) []string {
	mut result := []string{}
	if quiet_flag := strategy.cvs_quiet_flag() {
		result << quiet_flag
	}
	result << arguments
	return result
}

// Ruby method `clone_repo(timeout: nil)` at line 67.
pub fn (mut strategy VCSDownloadStrategy) cvs_clone_repo(deadline ?i64) ! {
	if strategy.url.contains('pserver') {
		vcs_command_checked('cvs', strategy.cvs_command_args(['-d', strategy.url, 'login']), '', strategy.cvs_env(), deadline)!
	}
	parent := os.dir(strategy.cached_location_value)
	os.mkdir_all(parent)!
	vcs_command_checked('cvs', strategy.cvs_command_args(['-d', strategy.url, 'checkout', '-d',
		os.file_name(strategy.cached_location_value), strategy.module_name]), parent, strategy.cvs_env(), deadline)!
}

// Ruby method `update(timeout: nil)` at line 81.
pub fn (mut strategy VCSDownloadStrategy) cvs_update(deadline ?i64) ! {
	vcs_command_checked('cvs', strategy.cvs_command_args(['update']), strategy.cached_location_value, strategy.cvs_env(), deadline)!
}

// Ruby method `split_url(in_url)` at line 89.
pub fn cvs_split_url(in_url string) (string, string) {
	colon := in_url.last_index(':') or { return '', in_url }
	return in_url[colon + 1..], in_url[..colon]
}

// Source entrypoint translations.
pub fn ruby_cvs_download_strategy_l9_d1_initialize(url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	return new_cvs_download_strategy(url, name, version, meta)
}

pub fn ruby_cvs_download_strategy_l30_d2_source_modified_time(strategy &VCSDownloadStrategy) !i64 {
	return strategy.cvs_source_modified_time()
}

pub fn ruby_cvs_download_strategy_l47_d3_env(strategy &VCSDownloadStrategy) map[string]string {
	return strategy.cvs_env()
}

pub fn ruby_cvs_download_strategy_l52_d4_cache_tag(strategy &VCSDownloadStrategy) string {
	return strategy.cvs_cache_tag()
}

pub fn ruby_cvs_download_strategy_l57_d5_repo_valid(strategy &VCSDownloadStrategy) bool {
	return strategy.cvs_repo_valid()
}

pub fn ruby_cvs_download_strategy_l62_d6_quiet_flag(strategy &VCSDownloadStrategy) ?string {
	return strategy.cvs_quiet_flag()
}

pub fn ruby_cvs_download_strategy_l67_d7_clone_repo(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.cvs_clone_repo(deadline)!
}

pub fn ruby_cvs_download_strategy_l81_d8_update(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.cvs_update(deadline)!
}

pub fn ruby_cvs_download_strategy_l89_d9_split_url(in_url string) (string, string) {
	return cvs_split_url(in_url)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading a CVS repository.
// 5: #
// 6: # @api public
// 7: class CVSDownloadStrategy < VCSDownloadStrategy
// 8:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 9:   def initialize(url, name, version, **meta)
// 10:     super
// 11:     @url = T.let(@url.sub(%r{^cvs://}, ""), String)
// 12:
// 13:     @module = T.let(
// 14:       if meta.key?(:module)
// 15:         meta.fetch(:module)
// 16:       elsif !@url.match?(%r{:[^/]+$})
// 17:         name
// 18:       else
// 19:         mod, url = split_url(@url)
// 20:         @url = T.let(url, String)
// 21:         mod
// 22:       end, String
// 23:     )
// 24:   end
// 25:
// 26:   # Returns the most recent modified time for all files in the current working directory after stage.
// 27:   #
// 28:   # @api public
// 29:   sig { override.returns(Time) }
// 30:   def source_modified_time
// 31:     # Filter CVS's files because the timestamp for each of them is the moment
// 32:     # of clone.
// 33:     max_mtime = Time.at(0)
// 34:     cached_location.find do |f|
// 35:       Find.prune if f.directory? && f.basename.to_s == "CVS"
// 36:       next unless f.file?
// 37:
// 38:       mtime = f.mtime
// 39:       max_mtime = mtime if mtime > max_mtime
// 40:     end
// 41:     max_mtime
// 42:   end
// 43:
// 44:   private
// 45:
// 46:   sig { override.returns(T::Hash[String, String]) }
// 47:   def env
// 48:     { "PATH" => PATH.new("/usr/bin", Utils::Path.formula_opt_bin_path("cvs")).to_s }
// 49:   end
// 50:
// 51:   sig { override.returns(String) }
// 52:   def cache_tag
// 53:     "cvs"
// 54:   end
// 55:
// 56:   sig { override.returns(T::Boolean) }
// 57:   def repo_valid?
// 58:     (cached_location/"CVS").directory?
// 59:   end
// 60:
// 61:   sig { returns(T.nilable(String)) }
// 62:   def quiet_flag
// 63:     "-Q" unless verbose?
// 64:   end
// 65:
// 66:   sig { override.params(timeout: T.nilable(Time)).void }
// 67:   def clone_repo(timeout: nil)
// 68:     # Login is only needed (and allowed) with pserver; skip for anoncvs.
// 69:     if @url.include? "pserver"
// 70:       command! "cvs", args:    [*quiet_flag, "-d", @url, "login"],
// 71:                       timeout: Utils::Timer.remaining(timeout)
// 72:     end
// 73:
// 74:     command! "cvs",
// 75:              args:    [*quiet_flag, "-d", @url, "checkout", "-d", basename.to_s, @module],
// 76:              chdir:   cached_location.dirname,
// 77:              timeout: Utils::Timer.remaining(timeout)
// 78:   end
// 79:
// 80:   sig { override.params(timeout: T.nilable(Time)).void }
// 81:   def update(timeout: nil)
// 82:     command! "cvs",
// 83:              args:    [*quiet_flag, "update"],
// 84:              chdir:   cached_location,
// 85:              timeout: Utils::Timer.remaining(timeout)
// 86:   end
// 87:
// 88:   sig { params(in_url: String).returns([String, String]) }
// 89:   def split_url(in_url)
// 90:     parts = in_url.split(":")
// 91:     mod = T.must(parts.pop)
// 92:     url = parts.join(":")
// 93:     [mod, url]
// 94:   end
// 95: end
