module download_strategy

// Translated from Homebrew/brew `download_strategy/fossil_download_strategy.rb`.
// The original source is retained below for line-for-line traceability.

// Ruby method `initialize(url, name, version, **meta)` at line 9.
pub fn new_fossil_download_strategy(source_url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	url := if source_url.starts_with('fossil://') {
		source_url['fossil://'.len..]
	} else {
		source_url
	}
	mut strategy := new_vcs_download_strategy(url, name, version, meta, 'fossil', .fossil)
	strategy.url = url
	return strategy
}

fn (strategy &VCSDownloadStrategy) fossil_tip_info() !string {
	result := vcs_command_checked('fossil', ['info', 'tip', '-R', strategy.cached_location_value], '', strategy.fossil_env(), none)!
	return result.output
}

fn fossil_tip_line(output string) !string {
	for line in output.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with('hash:') || trimmed.starts_with('uuid:') {
			return trimmed
		}
	}
	return error('Could not read the Fossil tip')
}

// Ruby method `source_modified_time` at line 18.
pub fn (strategy &VCSDownloadStrategy) fossil_source_modified_time() !i64 {
	line := fossil_tip_line(strategy.fossil_tip_info()!)!
	fields := line.fields()
	if fields.len < 3 {
		return error('Could not read the Fossil tip timestamp')
	}
	return parse_vcs_timestamp(fields[2..].join(' '))!
}

// Ruby method `source_revision = last_commit.presence` at line 24.
pub fn (strategy &VCSDownloadStrategy) fossil_source_revision() !string {
	return strategy.fossil_last_commit()
}

// Ruby method `last_commit` at line 30.
pub fn (strategy &VCSDownloadStrategy) fossil_last_commit() !string {
	line := fossil_tip_line(strategy.fossil_tip_info()!)!
	fields := line.fields()
	if fields.len < 2 {
		return error('Could not read the Fossil tip hash')
	}
	return fields[1]
}

// Ruby method `repo_valid?` at line 36.
pub fn (strategy &VCSDownloadStrategy) fossil_repo_valid() bool {
	result := vcs_command('fossil', ['branch', '-R', strategy.cached_location_value], '', strategy.fossil_env(), none) or { return false }
	return result.exit_code == 0
}

// Ruby method `env` at line 43.
pub fn (strategy &VCSDownloadStrategy) fossil_env() map[string]string {
	_ = strategy
	return formula_opt_bin_environment('fossil', false)
}

// Ruby method `cache_tag` at line 48.
pub fn (strategy &VCSDownloadStrategy) fossil_cache_tag() string {
	_ = strategy
	return 'fossil'
}

// Ruby method `clone_repo(timeout: nil)` at line 53.
pub fn (mut strategy VCSDownloadStrategy) fossil_clone_repo(deadline ?i64) ! {
	vcs_command_checked('fossil', ['clone', strategy.url, strategy.cached_location_value], '', strategy.fossil_env(), deadline)!
}

// Ruby method `update(timeout: nil)` at line 58.
pub fn (mut strategy VCSDownloadStrategy) fossil_update(deadline ?i64) ! {
	vcs_command_checked('fossil', ['pull', '-R', strategy.cached_location_value], '', strategy.fossil_env(), deadline)!
}

// Source entrypoint translations.
pub fn ruby_fossil_download_strategy_l9_d1_initialize(url string, name string, version string, meta VCSDownloadMeta) VCSDownloadStrategy {
	return new_fossil_download_strategy(url, name, version, meta)
}

pub fn ruby_fossil_download_strategy_l18_d2_source_modified_time(strategy &VCSDownloadStrategy) !i64 {
	return strategy.fossil_source_modified_time()
}

pub fn ruby_fossil_download_strategy_l24_d3_source_revision(strategy &VCSDownloadStrategy) !string {
	return strategy.fossil_source_revision()
}

pub fn ruby_fossil_download_strategy_l30_d4_last_commit(strategy &VCSDownloadStrategy) !string {
	return strategy.fossil_last_commit()
}

pub fn ruby_fossil_download_strategy_l36_d5_repo_valid(strategy &VCSDownloadStrategy) bool {
	return strategy.fossil_repo_valid()
}

pub fn ruby_fossil_download_strategy_l43_d6_env(strategy &VCSDownloadStrategy) map[string]string {
	return strategy.fossil_env()
}

pub fn ruby_fossil_download_strategy_l48_d7_cache_tag(strategy &VCSDownloadStrategy) string {
	return strategy.fossil_cache_tag()
}

pub fn ruby_fossil_download_strategy_l53_d8_clone_repo(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.fossil_clone_repo(deadline)!
}

pub fn ruby_fossil_download_strategy_l58_d9_update(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.fossil_update(deadline)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading a Fossil repository.
// 5: #
// 6: # @api public
// 7: class FossilDownloadStrategy < VCSDownloadStrategy
// 8:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 9:   def initialize(url, name, version, **meta)
// 10:     super
// 11:     @url = T.let(@url.sub(%r{^fossil://}, ""), String)
// 12:   end
// 13:
// 14:   # Returns the most recent modified time for all files in the current working directory after stage.
// 15:   #
// 16:   # @api public
// 17:   sig { override.returns(Time) }
// 18:   def source_modified_time
// 19:     out = silent_command("fossil", args: ["info", "tip", "-R", cached_location]).stdout
// 20:     Time.parse(T.must(out[/^(hash|uuid): +\h+ (.+)$/, 1]))
// 21:   end
// 22:
// 23:   sig { override.returns(T.nilable(String)) }
// 24:   def source_revision = last_commit.presence
// 25:
// 26:   # Return last commit's unique identifier for the repository.
// 27:   #
// 28:   # @api public
// 29:   sig { override.returns(String) }
// 30:   def last_commit
// 31:     out = silent_command("fossil", args: ["info", "tip", "-R", cached_location]).stdout
// 32:     T.must(out[/^(hash|uuid): +(\h+) .+$/, 1])
// 33:   end
// 34:
// 35:   sig { override.returns(T::Boolean) }
// 36:   def repo_valid?
// 37:     silent_command("fossil", args: ["branch", "-R", cached_location]).success?
// 38:   end
// 39:
// 40:   private
// 41:
// 42:   sig { override.returns(T::Hash[String, String]) }
// 43:   def env
// 44:     Utils::Path.formula_opt_bin_env("fossil")
// 45:   end
// 46:
// 47:   sig { override.returns(String) }
// 48:   def cache_tag
// 49:     "fossil"
// 50:   end
// 51:
// 52:   sig { override.params(timeout: T.nilable(Time)).void }
// 53:   def clone_repo(timeout: nil)
// 54:     command! "fossil", args: ["clone", @url, cached_location], timeout: Utils::Timer.remaining(timeout)
// 55:   end
// 56:
// 57:   sig { override.params(timeout: T.nilable(Time)).void }
// 58:   def update(timeout: nil)
// 59:     command! "fossil", args: ["pull", "-R", cached_location], timeout: Utils::Timer.remaining(timeout)
// 60:   end
// 61: end
