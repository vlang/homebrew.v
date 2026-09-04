module download_strategy

import ruby
import os
import time

// Translated from Homebrew/brew `download_strategy/vcs_download_strategy.rb`.

// VCSRefType is the ordered set of source reference keywords accepted by
// Homebrew. `unspecified` represents the absence of all four Ruby hash keys.
pub enum VCSRefType {
	unspecified
	tag
	branch
	revisions
	revision
}

// VCSBackend identifies the concrete subclass whose private operations are
// dispatched by the translated abstract strategy.
pub enum VCSBackend {
	abstract
	git
	subversion
	cvs
	mercurial
	bazaar
	fossil
}

// VCSDownloadMeta is the source VCS keyword metadata. It is deliberately
// separate from file-download metadata because Ruby's `revisions` value is a
// map and has no meaning for curl strategies.
pub struct VCSDownloadMeta {
pub mut:
	cache       string
	tag         string
	branch      string
	revisions   map[string]string
	revision    string
	only_path   string
	module_name string
	trust_cert  bool
	verbose     bool
}

// VCSDownloadStrategy carries the state shared by all concrete source-control
// downloaders. Concrete V types contain one of these and expose their source
// methods without relying on Ruby-style runtime inheritance.
pub struct VCSDownloadStrategy {
pub mut:
	base                  AbstractDownloadStrategy
	backend               VCSBackend
	url                   string
	cached_location_value string
	ref_type              VCSRefType
	ref                   string
	revisions             map[string]string
	revision              string
	only_path             string
	module_name           string
	trust_cert            bool
	verbose               bool
	version_commit        string
	last_commit_cache     string
}

// new_vcs_download_strategy translates the abstract initializer. The concrete
// cache tag is passed explicitly because V has no constructor-time virtual
// dispatch.
pub fn new_vcs_download_strategy(url string, name string, version string, meta VCSDownloadMeta, cache_tag string, backend VCSBackend) VCSDownloadStrategy {
	ref_type, ref, revisions := extract_vcs_ref(meta)
	base := new_abstract_download_strategy(url, name, version, DownloadMeta{
		cache: meta.cache
	})
	return VCSDownloadStrategy{
		base: base
		backend: backend
		url: url
		cached_location_value: os.join_path(base.cache, safe_filename('${name}--${cache_tag}'))
		ref_type: ref_type
		ref: ref
		revisions: revisions
		revision: meta.revision
		only_path: meta.only_path
		module_name: meta.module_name
		trust_cert: meta.trust_cert
		verbose: meta.verbose
	}
}

pub fn (strategy &VCSDownloadStrategy) cached_location() string {
	return strategy.cached_location_value
}

pub fn (mut strategy VCSDownloadStrategy) quiet() {
	strategy.base.quiet()
}

pub fn (strategy &VCSDownloadStrategy) is_quiet() bool {
	return strategy.base.is_quiet()
}

// fetch downloads a new repository or updates a valid cached one. A timeout is
// converted once to a deadline so every command shares the caller's budget.
pub fn (mut strategy VCSDownloadStrategy) fetch(timeout ?f64) ! {
	deadline := vcs_deadline(timeout)
	if strategy.backend == .subversion {
		strategy.subversion_prepare_fetch(deadline)!
	}
	strategy.base.ohai('Cloning ${strategy.url}')
	if os.exists(strategy.cached_location_value) && strategy.repo_valid() {
		strategy.base.puts('Updating ${strategy.cached_location_value}')
		strategy.update(deadline)!
	} else if os.exists(strategy.cached_location_value) {
		strategy.base.puts('Removing invalid repository from cache')
		strategy.base.clear_cache(strategy.cached_location_value)!
		strategy.clone_repo(deadline)!
	} else {
		strategy.clone_repo(deadline)!
	}
	if strategy.head() {
		strategy.version_commit = strategy.last_commit()!
	}
	if strategy.ref_type != .tag || strategy.revision == '' {
		return
	}
	actual_revision := strategy.current_revision()!
	if actual_revision == '' || actual_revision == strategy.revision {
		return
	}
	return error('${strategy.ref} tag should be ${strategy.revision}\nbut is actually ${actual_revision}')
}

pub fn (mut strategy VCSDownloadStrategy) fetch_last_commit() !string {
	strategy.fetch(none)!
	return strategy.last_commit()!
}

pub fn (mut strategy VCSDownloadStrategy) commit_outdated(commit ?string) !bool {
	if strategy.last_commit_cache == '' {
		strategy.last_commit_cache = strategy.fetch_last_commit()!
	}
	if value := commit {
		return value != strategy.last_commit_cache
	}
	return true
}

pub fn (strategy &VCSDownloadStrategy) head() bool {
	return strategy.base.version.to_upper() == 'HEAD'
}

pub fn (mut strategy VCSDownloadStrategy) last_commit() !string {
	if strategy.last_commit_cache != '' {
		return strategy.last_commit_cache
	}
	value := match strategy.backend {
		.git { strategy.git_last_commit()! }
		.subversion { strategy.subversion_last_commit()! }
		.mercurial { strategy.mercurial_last_commit()! }
		.bazaar { strategy.bazaar_last_commit()! }
		.fossil { strategy.fossil_last_commit()! }
		else { strategy.source_modified_time()!.str() }
	}
	strategy.last_commit_cache = value
	return value
}

pub fn (strategy &VCSDownloadStrategy) cache_tag() !string {
	return match strategy.backend {
		.git { strategy.git_cache_tag() }
		.subversion { strategy.subversion_cache_tag() }
		.cvs { 'cvs' }
		.mercurial { 'hg' }
		.bazaar { 'bzr' }
		.fossil { 'fossil' }
		.abstract { error('cache_tag must be implemented by a concrete VCS strategy') }
	}
}

pub fn (strategy &VCSDownloadStrategy) repo_valid() bool {
	return match strategy.backend {
		.git { strategy.git_repo_valid() }
		.subversion { strategy.subversion_repo_valid() }
		.cvs { strategy.cvs_repo_valid() }
		.mercurial { strategy.mercurial_repo_valid() }
		.bazaar { strategy.bazaar_repo_valid() }
		.fossil { strategy.fossil_repo_valid() }
		.abstract { false }
	}
}

pub fn (mut strategy VCSDownloadStrategy) clone_repo(deadline ?i64) ! {
	match strategy.backend {
		.git { strategy.git_clone_repo(deadline)! }
		.subversion { strategy.subversion_clone_repo(deadline)! }
		.cvs { strategy.cvs_clone_repo(deadline)! }
		.mercurial { strategy.mercurial_clone_repo(deadline)! }
		.bazaar { strategy.bazaar_clone_repo(deadline)! }
		.fossil { strategy.fossil_clone_repo(deadline)! }
		.abstract {
			return error('clone_repo must be implemented by a concrete VCS strategy')
		}
	}
}

pub fn (mut strategy VCSDownloadStrategy) update(deadline ?i64) ! {
	strategy.last_commit_cache = ''
	match strategy.backend {
		.git { strategy.git_update(deadline)! }
		.subversion { strategy.subversion_clone_repo(deadline)! }
		.cvs { strategy.cvs_update(deadline)! }
		.mercurial { strategy.mercurial_update(deadline)! }
		.bazaar { strategy.bazaar_update(deadline)! }
		.fossil { strategy.fossil_update(deadline)! }
		.abstract {
			return error('update must be implemented by a concrete VCS strategy')
		}
	}
}

pub fn (strategy &VCSDownloadStrategy) current_revision() !string {
	return match strategy.backend {
		.git { strategy.git_current_revision()! }
		.mercurial { strategy.mercurial_current_revision()! }
		else { '' }
	}
}

pub fn (strategy &VCSDownloadStrategy) source_modified_time() !i64 {
	return match strategy.backend {
		.git { strategy.git_source_modified_time()! }
		.subversion { strategy.subversion_source_modified_time()! }
		.cvs { strategy.cvs_source_modified_time()! }
		.mercurial { strategy.mercurial_source_modified_time()! }
		.bazaar { strategy.bazaar_source_modified_time()! }
		.fossil { strategy.fossil_source_modified_time()! }
		.abstract { strategy.base.source_modified_time(strategy.cached_location_value)! }
	}
}

pub fn (strategy &VCSDownloadStrategy) source_revision() !string {
	return match strategy.backend {
		.git, .mercurial { strategy.current_revision()! }
		.subversion {
			mut copy := *strategy
			copy.last_commit()!
		}
		.bazaar, .fossil {
			mut copy := *strategy
			copy.last_commit()!
		}
		else { '' }
	}
}

pub fn extract_vcs_ref(meta VCSDownloadMeta) (VCSRefType, string, map[string]string) {
	if meta.tag != '' {
		return VCSRefType.tag, meta.tag, map[string]string{}
	}
	if meta.branch != '' {
		return VCSRefType.branch, meta.branch, map[string]string{}
	}
	if meta.revisions.len > 0 {
		return VCSRefType.revisions, '', meta.revisions.clone()
	}
	if meta.revision != '' {
		return VCSRefType.revision, meta.revision, map[string]string{}
	}
	return VCSRefType.unspecified, '', map[string]string{}
}

fn vcs_deadline(timeout ?f64) ?i64 {
	if seconds := timeout {
		return time.now().unix_milli() + i64(seconds * 1000.0)
	}
	return none
}

// formula_opt_bin_environment translates Utils::Path.formula_opt_bin_env.
// CVS deliberately uses its source-specific `/usr/bin`-first path.
fn formula_opt_bin_environment(formula string, system_first bool) map[string]string {
	mut prefix := os.getenv('HOMEBREW_PREFIX')
	if prefix == '' {
		$if macos {
			prefix = '/opt/homebrew'
		} $else {
			prefix = '/home/linuxbrew/.linuxbrew'
		}
	}
	formula_bin := os.join_path(prefix, 'opt', formula, 'bin')
	current_path := os.getenv('PATH')
	path := if system_first {
		['/usr/bin', formula_bin].join(os.path_delimiter)
	} else if current_path == '' {
		formula_bin
	} else {
		[formula_bin, current_path].join(os.path_delimiter)
	}
	return {
		'PATH': path
	}
}

fn homebrew_temp_directory() string {
	configured := os.getenv('HOMEBREW_TEMP')
	return if configured != '' { configured } else { os.temp_dir() }
}

// parse_vcs_timestamp implements Ruby Time.parse for the ISO-like timestamp
// forms emitted by Mercurial, Bazaar and Fossil.
fn parse_vcs_timestamp(raw string) !i64 {
	for line in raw.split_into_lines() {
		value := line.trim_space()
		for index := 0; index + 10 <= value.len; index++ {
			date := value[index..index + 10]
			if date[4] != `-` || date[7] != `-` || !date[..4].bytes().all(it.is_digit()) || !date[5..7].bytes().all(it.is_digit()) || !date[8..10].bytes().all(it.is_digit()) {
				continue
			}
			fields := value[index..].fields()
			if fields.len < 2 {
				continue
			}
			mut clock := fields[1]
			if clock.len == 5 {
				clock += ':00'
			}
			mut zone := if fields.len >= 3 { fields[2].trim('()') } else { 'Z' }
			if zone in ['UTC', 'GMT'] {
				zone = 'Z'
			} else if zone.len == 5 && zone[0] in [`+`, `-`] {
				zone = '${zone[..3]}:${zone[3..]}'
			} else if !(zone == 'Z' || (zone.len == 6 && zone[0] in [`+`, `-`])) {
				zone = 'Z'
			}
			parsed := time.parse_iso8601('${fields[0]}T${clock}${zone}') or { continue }
			return parsed.unix()
		}
	}
	return error('invalid VCS timestamp `${raw.trim_space()}`')
}

fn vcs_executable(program string, environment map[string]string) !string {
	if env_path := environment['PATH'] {
		for directory in env_path.split(os.path_delimiter) {
			candidate := os.join_path(directory, program)
			if os.is_executable(candidate) {
				return candidate
			}
		}
	}
	if path := os.find_abs_path_of_executable(program) {
		return path
	}
	return error('${program} is required for this download strategy')
}

fn vcs_command(program string, arguments []string, directory string, environment map[string]string, deadline ?i64) !ruby.CommandResult {
	executable := vcs_executable(program, environment)!
	mut process := os.new_process(executable)
	process.set_args(arguments)
	if directory != '' {
		process.set_work_folder(directory)
	}
	if environment.len > 0 {
		mut child_environment := os.environ()
		for key, value in environment {
			child_environment[key] = value
		}
		process.set_environment(child_environment)
	}
	process.set_redirect_stdio_merged()
	process.run()
	mut output := ''
	for process.is_alive() {
		output += process.stdout_read()
		if end_time := deadline {
			if time.now().unix_milli() >= end_time {
				process.signal_kill()
				process.wait()
				output += process.stdout_slurp()
				process.close()
				return error('${program} timed out')
			}
		}
		time.sleep(5 * time.millisecond)
	}
	process.wait()
	output += process.stdout_slurp()
	result := ruby.CommandResult{
		exit_code: process.code
		output: output
	}
	process.close()
	return result
}

fn vcs_command_checked(program string, arguments []string, directory string, environment map[string]string, deadline ?i64) !ruby.CommandResult {
	result := vcs_command(program, arguments, directory, environment, deadline)!
	if result.exit_code != 0 {
		return error('command failed (${result.exit_code}): ${program}: ${result.output.trim_space()}')
	}
	return result
}
