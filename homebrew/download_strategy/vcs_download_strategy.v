module download_strategy

import brew_runtime
import os
import time

// Translated from Homebrew/brew `download_strategy/vcs_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

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

fn vcs_command(program string, arguments []string, directory string, environment map[string]string, deadline ?i64) !brew_runtime.CommandResult {
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
	result := brew_runtime.CommandResult{
		exit_code: process.code
		output: output
	}
	process.close()
	return result
}

fn vcs_command_checked(program string, arguments []string, directory string, environment map[string]string, deadline ?i64) !brew_runtime.CommandResult {
	result := vcs_command(program, arguments, directory, environment, deadline)!
	if result.exit_code != 0 {
		return error('command failed (${result.exit_code}): ${program}: ${result.output.trim_space()}')
	}
	return result
}

// Ruby attr_reader `attr_reader :cached_location` at line 9.
pub fn ruby_vcs_download_strategy_l9_d1_cached_location(strategy &VCSDownloadStrategy) string {
	return strategy.cached_location()
}

// Ruby method `initialize(url, name, version, **meta)` at line 14.
pub fn ruby_vcs_download_strategy_l14_d2_initialize(url string, name string, version string, meta VCSDownloadMeta, cache_tag string) VCSDownloadStrategy {
	return new_vcs_download_strategy(url, name, version, meta, cache_tag, .abstract)
}

// Ruby method `fetch(timeout: nil)` at line 27.
pub fn ruby_vcs_download_strategy_l27_d3_fetch(mut strategy VCSDownloadStrategy, timeout ?f64) ! {
	strategy.fetch(timeout)!
}

// Ruby method `fetch_last_commit` at line 55.
pub fn ruby_vcs_download_strategy_l55_d4_fetch_last_commit(mut strategy VCSDownloadStrategy) !string {
	return strategy.fetch_last_commit()
}

// Ruby method `commit_outdated?(commit)` at line 61.
pub fn ruby_vcs_download_strategy_l61_d5_commit_outdated(mut strategy VCSDownloadStrategy, commit ?string) !bool {
	return strategy.commit_outdated(commit)
}

// Ruby method `head?` at line 67.
pub fn ruby_vcs_download_strategy_l67_d6_head(strategy &VCSDownloadStrategy) bool {
	return strategy.head()
}

// Ruby method `last_commit` at line 76.
pub fn ruby_vcs_download_strategy_l76_d7_last_commit(mut strategy VCSDownloadStrategy) !string {
	return strategy.last_commit()
}

// Ruby method `cache_tag; end` at line 83.
pub fn ruby_vcs_download_strategy_l83_d8_cache_tag(strategy &VCSDownloadStrategy) !string {
	return strategy.cache_tag()
}

// Ruby method `repo_valid?; end` at line 86.
pub fn ruby_vcs_download_strategy_l86_d9_repo_valid(strategy &VCSDownloadStrategy) bool {
	return strategy.repo_valid()
}

// Ruby method `clone_repo(timeout: nil); end` at line 89.
pub fn ruby_vcs_download_strategy_l89_d10_clone_repo(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.clone_repo(deadline)!
}

// Ruby method `update(timeout: nil); end` at line 92.
pub fn ruby_vcs_download_strategy_l92_d11_update(mut strategy VCSDownloadStrategy, deadline ?i64) ! {
	strategy.update(deadline)!
}

// Ruby method `current_revision; end` at line 95.
pub fn ruby_vcs_download_strategy_l95_d12_current_revision(strategy &VCSDownloadStrategy) !string {
	return strategy.current_revision()
}

// Ruby method `extract_ref(specs)` at line 98.
pub fn ruby_vcs_download_strategy_l98_d13_extract_ref(meta VCSDownloadMeta) (VCSRefType, string, map[string]string) {
	return extract_vcs_ref(meta)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # @abstract Abstract superclass for all download strategies downloading from a version control system.
// 5: class VCSDownloadStrategy < AbstractDownloadStrategy
// 6:   abstract!
// 7:
// 8:   sig { override.returns(Pathname) }
// 9:   attr_reader :cached_location
// 10:
// 11:   REF_TYPES = [:tag, :branch, :revisions, :revision].freeze
// 12:
// 13:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 14:   def initialize(url, name, version, **meta)
// 15:     super
// 16:     extracted_ref = extract_ref(meta)
// 17:     @ref_type = T.let(extracted_ref.fetch(0), T.nilable(Symbol))
// 18:     @ref = T.let(extracted_ref.fetch(1), T.untyped)
// 19:     @revision = T.let(meta[:revision], T.nilable(String))
// 20:     @cached_location = T.let(@cache/Utils.safe_filename("#{name}--#{cache_tag}"), Pathname)
// 21:   end
// 22:
// 23:   # Download and cache the repository at {#cached_location}.
// 24:   #
// 25:   # @api public
// 26:   sig { override.params(timeout: T.nilable(T.any(Float, Integer))).void }
// 27:   def fetch(timeout: nil)
// 28:     end_time = Time.now + timeout if timeout
// 29:
// 30:     ohai "Cloning #{url}"
// 31:
// 32:     if cached_location.exist? && repo_valid?
// 33:       puts "Updating #{cached_location}"
// 34:       update(timeout: end_time)
// 35:     elsif cached_location.exist?
// 36:       puts "Removing invalid repository from cache"
// 37:       clear_cache
// 38:       clone_repo(timeout: end_time)
// 39:     else
// 40:       clone_repo(timeout: end_time)
// 41:     end
// 42:
// 43:     v = version
// 44:     v.update_commit(last_commit) if v.is_a?(Version) && head?
// 45:
// 46:     return if @ref_type != :tag || @revision.blank? || current_revision.blank? || current_revision == @revision
// 47:
// 48:     raise <<~EOS
// 49:       #{@ref} tag should be #{@revision}
// 50:       but is actually #{current_revision}
// 51:     EOS
// 52:   end
// 53:
// 54:   sig { returns(String) }
// 55:   def fetch_last_commit
// 56:     fetch
// 57:     last_commit
// 58:   end
// 59:
// 60:   sig { overridable.params(commit: T.nilable(String)).returns(T::Boolean) }
// 61:   def commit_outdated?(commit)
// 62:     @last_commit ||= T.let(fetch_last_commit, T.nilable(String))
// 63:     commit != @last_commit
// 64:   end
// 65:
// 66:   sig { returns(T::Boolean) }
// 67:   def head?
// 68:     v = version
// 69:     v.is_a?(Version) ? v.head? : false
// 70:   end
// 71:
// 72:   # Return the most recent modified timestamp.
// 73:   #
// 74:   # @api public
// 75:   sig { overridable.returns(String) }
// 76:   def last_commit
// 77:     source_modified_time.to_i.to_s
// 78:   end
// 79:
// 80:   private
// 81:
// 82:   sig { abstract.returns(String) }
// 83:   def cache_tag; end
// 84:
// 85:   sig { abstract.returns(T::Boolean) }
// 86:   def repo_valid?; end
// 87:
// 88:   sig { abstract.params(timeout: T.nilable(Time)).void }
// 89:   def clone_repo(timeout: nil); end
// 90:
// 91:   sig { abstract.params(timeout: T.nilable(Time)).void }
// 92:   def update(timeout: nil); end
// 93:
// 94:   sig { overridable.returns(T.nilable(String)) }
// 95:   def current_revision; end
// 96:
// 97:   sig { params(specs: T::Hash[T.nilable(Symbol), T.untyped]).returns([T.nilable(Symbol), T.untyped]) }
// 98:   def extract_ref(specs)
// 99:     key = REF_TYPES.find { |type| specs.key?(type) }
// 100:     [key, specs[key]]
// 101:   end
// 102: end
