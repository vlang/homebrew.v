module download_strategy

import os
import time

// Translated from Homebrew/brew `download_strategy/subversion_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(url, name, version, **meta)` at line 9.
pub fn new_subversion_download_strategy(url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	mut strategy := new_vcs_download_strategy(url.replace_once('svn+http://', ''), name, version, meta, if version.to_upper() == 'HEAD' {
		'svn-HEAD'
	} else {
		'svn'
	}, .subversion)
	strategy.url = url.replace_once('svn+http://', '')
	return strategy
}

// Ruby method `fetch(timeout: nil)` at line 18.
pub fn (mut strategy VCSDownloadStrategy) subversion_prepare_fetch(deadline ?i64) ! {
	if !os.is_dir(strategy.cached_location_value) {
		return
	}
	repository_url := strategy.subversion_repo_url() or { '' }
	mut valid := strategy.url.trim_right('/') == repository_url
	if valid {
		result := vcs_command('svn', ['switch', strategy.url, strategy.cached_location_value], '', map[string]string{}, deadline)!
		valid = result.exit_code == 0
	}
	if !valid {
		strategy.base.clear_cache(strategy.cached_location_value)!
	}
}

// Ruby method `source_modified_time` at line 29.
pub fn (strategy &VCSDownloadStrategy) subversion_source_modified_time() !i64 {
	mut result := vcs_command('svn', ['info', '--show-item', 'last-changed-date'], strategy.cached_location_value, map[string]string{}, none)!
	mut value := result.output.trim_space()
	if result.exit_code != 0 || value == '' {
		result = vcs_command_checked('svn', ['info'], strategy.cached_location_value, map[string]string{}, none)!
		for line in result.output.split_into_lines() {
			if line.starts_with('Last Changed Date: ') {
				value = line.all_after('Last Changed Date: ').all_before(' (')
				break
			}
		}
	}
	parsed := time.parse_iso8601(value) or { return error('invalid Subversion timestamp `${value}`') }
	return parsed.unix()
}

// Ruby method `source_revision = last_commit` at line 41.
pub fn (strategy &VCSDownloadStrategy) subversion_source_revision() !string {
	return strategy.subversion_last_commit()
}

// Ruby method `last_commit` at line 47.
pub fn (strategy &VCSDownloadStrategy) subversion_last_commit() !string {
	result := vcs_command_checked('svn', ['info', '--show-item', 'revision'], strategy.cached_location_value, map[string]string{}, none)!
	return result.output.trim_space()
}

// Ruby method `repo_url` at line 54.
pub fn (strategy &VCSDownloadStrategy) subversion_repo_url() !string {
	result := vcs_command_checked('svn', ['info'], strategy.cached_location_value, map[string]string{}, none)!
	for line in result.output.split_into_lines() {
		if line.starts_with('URL: ') {
			return line.all_after('URL: ').trim_space()
		}
	}
	return ''
}

// Ruby method `externals(&_block)` at line 59.
pub struct SVNExternal {
pub:
	name string
	url  string
}

pub fn (strategy &VCSDownloadStrategy) subversion_externals() ![]SVNExternal {
	result := vcs_command_checked('svn', ['propget', 'svn:externals', strategy.url], '', map[string]string{}, none)!
	mut externals := []SVNExternal{}
	for line in result.output.trim_space().split_into_lines() {
		fields := line.fields()
		if fields.len >= 2 {
			externals << SVNExternal{fields[0], fields[1]}
		}
	}
	return externals
}

// Ruby method `fetch_repo(target, url, revision = nil, ignore_externals: false, timeout: nil)` at line 71.
pub fn (strategy &VCSDownloadStrategy) subversion_fetch_arguments(target string, url string, revision string, ignore_externals bool) []string {
	mut args := []string{}
	if !strategy.verbose {
		args << '--quiet'
	}
	if revision != '' {
		strategy.base.ohai('Checking out ${strategy.ref}')
		args << '-r'
		args << revision
	}
	if ignore_externals {
		args << '--ignore-externals'
	}
	if strategy.trust_cert {
		args << '--trust-server-cert'
		args << '--non-interactive'
	}
	if os.is_dir(target) {
		mut update_args := ['update']
		update_args << args
		return update_args
	} else {
		mut checkout_args := ['checkout']
		checkout_args << args
		checkout_args << ['--', url, target]
		return checkout_args
	}
}

pub fn (strategy &VCSDownloadStrategy) subversion_fetch_repo(target string, url string, revision string, ignore_externals bool, deadline ?i64) ! {
	arguments := strategy.subversion_fetch_arguments(target, url, revision, ignore_externals)
	if os.is_dir(target) {
		vcs_command_checked('svn', arguments, target, map[string]string{}, deadline)!
	} else {
		vcs_command_checked('svn', arguments, '', map[string]string{}, deadline)!
	}
}

// Ruby method `cache_tag` at line 96.
pub fn (strategy &VCSDownloadStrategy) subversion_cache_tag() string {
	return if strategy.head() { 'svn-HEAD' } else { 'svn' }
}

// Ruby method `repo_valid?` at line 101.
pub fn (strategy &VCSDownloadStrategy) subversion_repo_valid() bool {
	return os.is_dir(os.join_path(strategy.cached_location_value, '.svn'))
}

// Ruby method `clone_repo(timeout: nil)` at line 106.
pub fn (mut strategy VCSDownloadStrategy) subversion_clone_repo(deadline ?i64) ! {
	match strategy.ref_type {
		.revision {
			strategy.subversion_fetch_repo(strategy.cached_location_value, strategy.url, strategy.ref, false, deadline)!
		}
		.revisions {
			strategy.subversion_fetch_repo(strategy.cached_location_value, strategy.url, strategy.revisions['trunk'], true, deadline)!
			for external in strategy.subversion_externals()! {
				strategy.subversion_fetch_repo(os.join_path(strategy.cached_location_value, external.name), external.url, strategy.revisions[external.name], true, deadline)!
			}
		}
		else {
			strategy.subversion_fetch_repo(strategy.cached_location_value, strategy.url, '', false, deadline)!
		}
	}
}

// Ruby alias `alias update clone_repo` at line 123.
pub fn (mut strategy VCSDownloadStrategy) subversion_update(deadline ?i64) ! {
	strategy.subversion_clone_repo(deadline)!
}

// Source entrypoint translations.
pub fn ruby_subversion_download_strategy_l9_d1_initialize(url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	return new_subversion_download_strategy(url, name, version, meta)
}

pub fn ruby_subversion_download_strategy_l18_d2_fetch(mut strategy VCSDownloadStrategy, timeout ?f64) ! {
	strategy.fetch(timeout)!
}

pub fn ruby_subversion_download_strategy_l29_d3_source_modified_time(strategy &VCSDownloadStrategy) !i64 {
	return strategy.subversion_source_modified_time()
}

pub fn ruby_subversion_download_strategy_l41_d4_source_revision(strategy &VCSDownloadStrategy) !string {
	return strategy.subversion_source_revision()
}

pub fn ruby_subversion_download_strategy_l47_d5_last_commit(strategy &VCSDownloadStrategy) !string {
	return strategy.subversion_last_commit()
}

pub fn ruby_subversion_download_strategy_l54_d6_repo_url(strategy &VCSDownloadStrategy) !string {
	return strategy.subversion_repo_url()
}

pub fn ruby_subversion_download_strategy_l59_d7_externals(strategy &VCSDownloadStrategy) ![]SVNExternal {
	return strategy.subversion_externals()
}

pub fn ruby_subversion_download_strategy_l71_d8_fetch_repo(strategy &VCSDownloadStrategy, target string, url string, revision string, ignore_externals bool, deadline ?i64) ! {
	strategy.subversion_fetch_repo(target, url, revision, ignore_externals, deadline)!
}

pub fn ruby_subversion_download_strategy_l96_d9_cache_tag(strategy &VCSDownloadStrategy) string {
	return strategy.subversion_cache_tag()
}

pub fn ruby_subversion_download_strategy_l101_d10_repo_valid(strategy &VCSDownloadStrategy) bool {
	return strategy.subversion_repo_valid()
}

pub fn ruby_subversion_download_strategy_l106_d11_clone_repo(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.subversion_clone_repo(deadline)!
}

pub fn ruby_subversion_download_strategy_l123_d12_update(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.subversion_update(deadline)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading a Subversion repository.
// 5: #
// 6: # @api public
// 7: class SubversionDownloadStrategy < VCSDownloadStrategy
// 8:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 9:   def initialize(url, name, version, **meta)
// 10:     super
// 11:     @url = @url.sub("svn+http://", "")
// 12:   end
// 13:
// 14:   # Download and cache the repository at {#cached_location}.
// 15:   #
// 16:   # @api public
// 17:   sig { override.params(timeout: T.nilable(T.any(Float, Integer))).void }
// 18:   def fetch(timeout: nil)
// 19:     if @url.chomp("/") != repo_url || !silent_command("svn", args: ["switch", @url, cached_location]).success?
// 20:       clear_cache
// 21:     end
// 22:     super
// 23:   end
// 24:
// 25:   # Returns the most recent modified time for all files in the current working directory after stage.
// 26:   #
// 27:   # @api public
// 28:   sig { override.returns(Time) }
// 29:   def source_modified_time
// 30:     require "utils/svn"
// 31:
// 32:     time = if Version.new(T.must(Utils::Svn.version)) >= Version.new("1.9")
// 33:       silent_command("svn", args: ["info", "--show-item", "last-changed-date"], chdir: cached_location).stdout
// 34:     else
// 35:       silent_command("svn", args: ["info"], chdir: cached_location).stdout[/^Last Changed Date: (.+)$/, 1]
// 36:     end
// 37:     Time.parse T.must(time)
// 38:   end
// 39:
// 40:   sig { override.returns(T.nilable(String)) }
// 41:   def source_revision = last_commit
// 42:
// 43:   # Return last commit's unique identifier for the repository.
// 44:   #
// 45:   # @api public
// 46:   sig { override.returns(String) }
// 47:   def last_commit
// 48:     silent_command("svn", args: ["info", "--show-item", "revision"], chdir: cached_location).stdout.strip
// 49:   end
// 50:
// 51:   private
// 52:
// 53:   sig { returns(T.nilable(String)) }
// 54:   def repo_url
// 55:     silent_command("svn", args: ["info"], chdir: cached_location).stdout.strip[/^URL: (.+)$/, 1]
// 56:   end
// 57:
// 58:   sig { params(_block: T.proc.params(arg0: String, arg1: String).void).void }
// 59:   def externals(&_block)
// 60:     out = silent_command("svn", args: ["propget", "svn:externals", @url]).stdout
// 61:     out.chomp.split("\n").each do |line|
// 62:       name, url = line.split(/\s+/)
// 63:       yield T.must(name), T.must(url)
// 64:     end
// 65:   end
// 66:
// 67:   sig {
// 68:     params(target: Pathname, url: String, revision: T.nilable(String), ignore_externals: T::Boolean,
// 69:            timeout: T.nilable(Time)).void
// 70:   }
// 71:   def fetch_repo(target, url, revision = nil, ignore_externals: false, timeout: nil)
// 72:     # Use "svn update" when the repository already exists locally.
// 73:     # This saves on bandwidth and will have a similar effect to verifying the
// 74:     # cache as it will make any changes to get the right revision.
// 75:     args = []
// 76:     args << "--quiet" unless verbose?
// 77:
// 78:     if revision
// 79:       ohai "Checking out #{@ref}"
// 80:       args << "-r" << revision
// 81:     end
// 82:
// 83:     args << "--ignore-externals" if ignore_externals
// 84:
// 85:     require "utils/svn"
// 86:     args.concat Utils::Svn.invalid_cert_flags if meta[:trust_cert] == true
// 87:
// 88:     if target.directory?
// 89:       command! "svn", args: ["update", *args], chdir: target.to_s, timeout: Utils::Timer.remaining(timeout)
// 90:     else
// 91:       command! "svn", args: ["checkout", *args, "--", url, target], timeout: Utils::Timer.remaining(timeout)
// 92:     end
// 93:   end
// 94:
// 95:   sig { override.returns(String) }
// 96:   def cache_tag
// 97:     head? ? "svn-HEAD" : "svn"
// 98:   end
// 99:
// 100:   sig { override.returns(T::Boolean) }
// 101:   def repo_valid?
// 102:     (cached_location/".svn").directory?
// 103:   end
// 104:
// 105:   sig { override.params(timeout: T.nilable(Time)).void }
// 106:   def clone_repo(timeout: nil)
// 107:     case @ref_type
// 108:     when :revision
// 109:       fetch_repo cached_location, @url, @ref, timeout:
// 110:     when :revisions
// 111:       # nil is OK for main_revision, as fetch_repo will then get latest
// 112:       main_revision = @ref[:trunk]
// 113:       fetch_repo(cached_location, @url, main_revision, ignore_externals: true, timeout:)
// 114:
// 115:       externals do |external_name, external_url|
// 116:         fetch_repo cached_location/external_name, external_url, @ref[external_name], ignore_externals: true,
// 117:                                                                                      timeout:
// 118:       end
// 119:     else
// 120:       fetch_repo cached_location, @url, timeout:
// 121:     end
// 122:   end
// 123:   alias update clone_repo
// 124: end
