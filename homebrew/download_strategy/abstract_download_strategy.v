module download_strategy

import ruby
import os

// Translated from Homebrew/brew `download_strategy/abstract_download_strategy.rb`.

// DownloadMeta is the typed subset of Ruby's keyword metadata used by the base
// and curl file strategies.
pub struct DownloadMeta {
pub mut:
	cache                       string
	mirrors                     []string
	headers                     []string
	header                      string
	cookies                     map[string]string
	referer                     string
	user                        string
	user_agent                  string
	artifact_domain             string
	artifact_domain_no_fallback bool
	no_insecure_redirect        bool
}

// AbstractDownloadStrategy carries the state initialized by the Ruby abstract
// superclass. Concrete V strategies embed this value explicitly.
pub struct AbstractDownloadStrategy {
pub:
	url     string
	cache   string
	name    string
	version string
pub mut:
	meta        DownloadMeta
	quiet_value bool
}

// new_abstract_download_strategy translates initialize(url, name, version, **meta).
pub fn new_abstract_download_strategy(url string, name string, version string, meta DownloadMeta) AbstractDownloadStrategy {
	cache := if meta.cache != '' { meta.cache } else { default_homebrew_cache() }
	return AbstractDownloadStrategy{
		url: url
		cache: cache
		name: name
		version: version
		meta: meta
	}
}

fn default_homebrew_cache() string {
	if configured := os.getenv_opt('HOMEBREW_CACHE') {
		if configured != '' {
			return configured
		}
	}
	$if macos {
		return os.join_path(os.home_dir(), 'Library/Caches/Homebrew')
	} $else {
		base := os.getenv('XDG_CACHE_HOME')
		return os.join_path(if base != '' { base } else { os.join_path(os.home_dir(), '.cache') }, 'Homebrew')
	}
}

// fetch is the source no-op supplied by the overridable abstract base.
pub fn (mut strategy AbstractDownloadStrategy) fetch(timeout ?f64) ! {
	_ = timeout
}

// fetched_size is nil in the source abstract base.
pub fn (strategy &AbstractDownloadStrategy) fetched_size() ?i64 {
	return none
}

// total_size is nil in the source abstract base.
pub fn (strategy &AbstractDownloadStrategy) total_size() ?i64 {
	return none
}

// cached_location is abstract in Ruby and remains an explicit typed boundary.
pub fn (strategy &AbstractDownloadStrategy) cached_location() !string {
	return error('cached_location must be implemented by a concrete download strategy')
}

// quiet disables any output during downloading.
pub fn (mut strategy AbstractDownloadStrategy) quiet() {
	strategy.quiet_value = true
}

pub fn (strategy &AbstractDownloadStrategy) is_quiet() bool {
	return strategy.quiet_value
}

// expand_deferred_environment_for translates the controlled-strategy class check.
pub fn expand_deferred_environment_for(strategy DownloadStrategy) bool {
	return strategy in [.curl_apache_mirror, .curl, .curl_github_packages, .curl_post, .homebrew_curl,
		.no_unzip_curl, .pypi]
}

// stage extracts a cached file into destination and returns the directory in
// which the source block would run. Archive format detection is the directly
// translated boundary for the still-untranslated UnpackStrategy subsystem.
pub fn (strategy &AbstractDownloadStrategy) stage(cached_location string, destination string) !string {
	os.mkdir_all(destination)!
	name := os.file_name(cached_location).to_lower()
	mut result := ruby.CommandResult{}
	if name.ends_with('.zip') {
		unzip := ruby.find_executable('unzip')!
		result = ruby.run_command(unzip, ['-q', '-o', cached_location, '-d', destination])
	} else if name.ends_with('.tar') || name.ends_with('.tar.gz') || name.ends_with('.tgz')
		|| name.ends_with('.tar.bz2') || name.ends_with('.tbz') || name.ends_with('.tbz2')
		|| name.ends_with('.tar.xz') || name.ends_with('.txz') || name.ends_with('.tar.zst') {
		tar := ruby.find_executable('tar')!
		result = ruby.run_command(tar, ['-xf', cached_location, '-C', destination])
	} else {
		os.cp(cached_location, os.join_path(destination, strategy.basename(cached_location)))!
		return strategy.stage_working_directory(destination)
	}
	if result.exit_code != 0 {
		return error('failed to extract ${cached_location}: ${result.output.trim_space()}')
	}
	return strategy.stage_working_directory(destination)
}

// stage_working_directory translates the private chdir selection performed
// after extraction.
pub fn (strategy &AbstractDownloadStrategy) stage_working_directory(directory string) !string {
	mut entries := os.ls(directory)!
	entries.sort()
	if entries.len == 0 {
		return error('Empty archive')
	}
	if entries.len == 1 {
		candidate := os.join_path(directory, entries[0])
		if os.is_dir(candidate) {
			return candidate
		}
	}
	return directory
}

// source_modified_time returns the latest mtime among staged non-directory
// entries and deliberately ignores dangling symlinks.
pub fn (strategy &AbstractDownloadStrategy) source_modified_time(directory string) !i64 {
	_ = strategy
	return collect_latest_modified_time(directory)
}

fn collect_latest_modified_time(directory string) !i64 {
	mut latest := i64(0)
	for entry in os.ls(directory)! {
		path := os.join_path(directory, entry)
		if os.is_dir(path) {
			modified := collect_latest_modified_time(path)!
			if modified > latest {
				latest = modified
			}
		} else if os.exists(path) {
			modified := os.file_last_mod_unix(path)
			if modified > latest {
				latest = modified
			}
		}
	}
	return latest
}

// source_revision is nil for file strategies in the source base.
pub fn (strategy &AbstractDownloadStrategy) source_revision() ?string {
	return none
}

// clear_cache removes precisely the concrete strategy's cached location.
pub fn (strategy &AbstractDownloadStrategy) clear_cache(cached_location string) ! {
	remove_path(cached_location)!
}

fn remove_path(path string) ! {
	if os.is_dir(path) && !os.is_link(path) {
		os.rmdir_all(path)!
	} else if os.exists(path) || os.is_link(path) {
		os.rm(path)!
	}
}

pub fn (strategy &AbstractDownloadStrategy) basename(cached_location string) string {
	_ = strategy
	name := os.file_name(cached_location)
	// AbstractFileDownloadStrategy overrides this in Ruby. Composition in V
	// performs the same dispatch here for digest-addressed file downloads.
	if name.len > 66 && name[64..66] == '--' && is_lower_hex(name[..64]) {
		return name[66..]
	}
	return name
}

pub fn (strategy &AbstractDownloadStrategy) ohai(title string, details ...string) {
	if strategy.is_quiet() {
		return
	}
	println('==> ${title}')
	for detail in details {
		println(detail)
	}
}

pub fn (strategy &AbstractDownloadStrategy) puts(messages ...string) {
	if !strategy.is_quiet() {
		for message in messages {
			println(message)
		}
	}
}

pub fn (strategy &AbstractDownloadStrategy) silent_command(program string, arguments []string) ruby.CommandResult {
	_ = strategy
	return ruby.run_command(program, arguments)
}

pub fn (strategy &AbstractDownloadStrategy) command(program string, arguments []string) !ruby.CommandResult {
	result := strategy.silent_command(program, arguments)
	if result.exit_code != 0 {
		return error('command failed (${result.exit_code}): ${program}: ${result.output.trim_space()}')
	}
	return result
}

pub fn (strategy &AbstractDownloadStrategy) command_output_options() bool {
	return strategy.is_quiet()
}

pub fn (strategy &AbstractDownloadStrategy) env() map[string]string {
	_ = strategy
	return map[string]string{}
}

// Source entrypoint translations.
