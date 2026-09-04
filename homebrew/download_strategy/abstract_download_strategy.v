module download_strategy

import ruby
import os

// Translated from Homebrew/brew `download_strategy/abstract_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

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
		url:     url
		cache:   cache
		name:    name
		version: version
		meta:    meta
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
		return os.join_path(if base != '' { base } else { os.join_path(os.home_dir(), '.cache') },
			'Homebrew')
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
// Ruby attr_reader `attr_reader :url` at line 18.
pub fn ruby_abstract_download_strategy_l18_d1_url(strategy &AbstractDownloadStrategy) string {
	return strategy.url
}

// Ruby attr_reader `attr_reader :cache` at line 21.
pub fn ruby_abstract_download_strategy_l21_d2_cache(strategy &AbstractDownloadStrategy) string {
	return strategy.cache
}

// Ruby attr_reader `attr_reader :meta` at line 24.
pub fn ruby_abstract_download_strategy_l24_d3_meta(strategy &AbstractDownloadStrategy) DownloadMeta {
	return strategy.meta
}

// Ruby attr_reader `attr_reader :name` at line 27.
pub fn ruby_abstract_download_strategy_l27_d4_name(strategy &AbstractDownloadStrategy) string {
	return strategy.name
}

// Ruby attr_reader `attr_reader :version` at line 30.
pub fn ruby_abstract_download_strategy_l30_d5_version(strategy &AbstractDownloadStrategy) string {
	return strategy.version
}

// Ruby method `initialize(url, name, version, **meta)` at line 35.
pub fn ruby_abstract_download_strategy_l35_d6_initialize(url string, name string, version string, meta DownloadMeta) AbstractDownloadStrategy {
	return new_abstract_download_strategy(url, name, version, meta)
}

// Ruby method `fetch(timeout: nil); end` at line 51.
pub fn ruby_abstract_download_strategy_l51_d7_fetch(mut strategy AbstractDownloadStrategy, timeout ?f64) ! {
	strategy.fetch(timeout)!
}

// Ruby method `fetched_size; end` at line 55.
pub fn ruby_abstract_download_strategy_l55_d8_fetched_size(strategy &AbstractDownloadStrategy) ?i64 {
	return strategy.fetched_size()
}

// Ruby method `total_size; end` at line 59.
pub fn ruby_abstract_download_strategy_l59_d9_total_size(strategy &AbstractDownloadStrategy) ?i64 {
	return strategy.total_size()
}

// Ruby method `cached_location; end` at line 65.
pub fn ruby_abstract_download_strategy_l65_d10_cached_location(strategy &AbstractDownloadStrategy) !string {
	return strategy.cached_location()
}

// Ruby method `quiet!` at line 71.
pub fn ruby_abstract_download_strategy_l71_d11_quiet(mut strategy AbstractDownloadStrategy) {
	strategy.quiet()
}

// Ruby method `quiet?` at line 76.
pub fn ruby_abstract_download_strategy_l76_d12_quiet(strategy &AbstractDownloadStrategy) bool {
	return strategy.is_quiet()
}

// Ruby method `self.expand_deferred_environment_for?(downloader)` at line 81.
pub fn ruby_abstract_download_strategy_l81_d13_self_expand_deferred_environment_for(strategy DownloadStrategy) bool {
	return expand_deferred_environment_for(strategy)
}

// Ruby method `stage(&block)` at line 95.
pub fn ruby_abstract_download_strategy_l95_d14_stage(strategy &AbstractDownloadStrategy, cached_location string, destination string) !string {
	return strategy.stage(cached_location, destination)
}

// Ruby method `chdir(&block)` at line 106.
pub fn ruby_abstract_download_strategy_l106_d15_chdir(strategy &AbstractDownloadStrategy, directory string) !string {
	return strategy.stage_working_directory(directory)
}

// Ruby method `source_modified_time` at line 129.
pub fn ruby_abstract_download_strategy_l129_d16_source_modified_time(strategy &AbstractDownloadStrategy, directory string) !i64 {
	return strategy.source_modified_time(directory)
}

// Ruby method `source_revision; end` at line 137.
pub fn ruby_abstract_download_strategy_l137_d17_source_revision(strategy &AbstractDownloadStrategy) ?string {
	return strategy.source_revision()
}

// Ruby method `clear_cache` at line 144.
pub fn ruby_abstract_download_strategy_l144_d18_clear_cache(strategy &AbstractDownloadStrategy, cached_location string) ! {
	strategy.clear_cache(cached_location)!
}

// Ruby method `basename` at line 149.
pub fn ruby_abstract_download_strategy_l149_d19_basename(strategy &AbstractDownloadStrategy, cached_location string) string {
	return strategy.basename(cached_location)
}

// Ruby method `ohai(title, *sput)` at line 154.
pub fn ruby_abstract_download_strategy_l154_d20_ohai(strategy &AbstractDownloadStrategy, title string, details ...string) {
	strategy.ohai(title, ...details)
}

// Ruby method `puts(*args)` at line 161.
pub fn ruby_abstract_download_strategy_l161_d21_puts(strategy &AbstractDownloadStrategy, messages ...string) {
	strategy.puts(...messages)
}

// Ruby method `silent_command(*args, **options)` at line 166.
pub fn ruby_abstract_download_strategy_l166_d22_silent_command(strategy &AbstractDownloadStrategy, program string, arguments []string) ruby.CommandResult {
	return strategy.silent_command(program, arguments)
}

// Ruby method `command!(*args, **options)` at line 171.
pub fn ruby_abstract_download_strategy_l171_d23_command(strategy &AbstractDownloadStrategy, program string, arguments []string) !ruby.CommandResult {
	return strategy.command(program, arguments)
}

// Ruby method `command_output_options` at line 181.
pub fn ruby_abstract_download_strategy_l181_d24_command_output_options(strategy &AbstractDownloadStrategy) bool {
	return strategy.command_output_options()
}

// Ruby method `env` at line 190.
pub fn ruby_abstract_download_strategy_l190_d25_env(strategy &AbstractDownloadStrategy) map[string]string {
	return strategy.env()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # @abstract Abstract superclass for all download strategies.
// 5: class AbstractDownloadStrategy
// 6:   extend T::Helpers
// 7:   include FileUtils
// 8:   include Context
// 9:   include SystemCommand::Mixin
// 10:   include Utils::Output::Mixin
// 11:
// 12:   abstract!
// 13:
// 14:   # The download URL.
// 15:   #
// 16:   # @api public
// 17:   sig { returns(String) }
// 18:   attr_reader :url
// 19:
// 20:   sig { returns(Pathname) }
// 21:   attr_reader :cache
// 22:
// 23:   sig { returns(T::Hash[Symbol, T.untyped]) }
// 24:   attr_reader :meta
// 25:
// 26:   sig { returns(String) }
// 27:   attr_reader :name
// 28:
// 29:   sig { returns(T.nilable(T.any(String, Version))) }
// 30:   attr_reader :version
// 31:
// 32:   private :meta, :name, :version
// 33:
// 34:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 35:   def initialize(url, name, version, **meta)
// 36:     @cached_location = T.let(nil, T.nilable(Pathname))
// 37:     @ref_type = T.let(nil, T.nilable(Symbol))
// 38:     @ref = T.let(nil, T.untyped)
// 39:     @url = url
// 40:     @name = name
// 41:     @version = version
// 42:     @cache = T.let(meta.fetch(:cache, HOMEBREW_CACHE), Pathname)
// 43:     @meta = meta
// 44:     @quiet = T.let(false, T.nilable(T::Boolean))
// 45:   end
// 46:
// 47:   # Download and cache the resource at {#cached_location}.
// 48:   #
// 49:   # @api public
// 50:   sig { overridable.params(timeout: T.nilable(T.any(Float, Integer))).void }
// 51:   def fetch(timeout: nil); end
// 52:
// 53:   # Total bytes downloaded if available.
// 54:   sig { overridable.returns(T.nilable(Integer)) }
// 55:   def fetched_size; end
// 56:
// 57:   # Total download size if available.
// 58:   sig { overridable.returns(T.nilable(Integer)) }
// 59:   def total_size; end
// 60:
// 61:   # Location of the cached download.
// 62:   #
// 63:   # @api public
// 64:   sig { abstract.returns(Pathname) }
// 65:   def cached_location; end
// 66:
// 67:   # Disable any output during downloading.
// 68:   #
// 69:   # @api public
// 70:   sig { void }
// 71:   def quiet!
// 72:     @quiet = T.let(true, T.nilable(T::Boolean))
// 73:   end
// 74:
// 75:   sig { returns(T::Boolean) }
// 76:   def quiet?
// 77:     Context.current.quiet? || @quiet || false
// 78:   end
// 79:
// 80:   sig { params(downloader: AbstractDownloadStrategy).returns(T::Boolean) }
// 81:   def self.expand_deferred_environment_for?(downloader)
// 82:     HOMEBREW_CONTROLLED_STRATEGIES.include?(downloader.class)
// 83:   end
// 84:
// 85:   # Unpack {#cached_location} into the current working directory.
// 86:   #
// 87:   # Additionally, if a block is given, the working directory was previously empty
// 88:   # and a single directory is extracted from the archive, the block will be called
// 89:   # with the working directory changed to that directory. Otherwise this method
// 90:   # will return, or the block will be called, without changing the current working
// 91:   # directory.
// 92:   #
// 93:   # @api public
// 94:   sig { overridable.params(block: T.nilable(T.proc.void)).void }
// 95:   def stage(&block)
// 96:     UnpackStrategy.detect(cached_location,
// 97:                           prioritize_extension: true,
// 98:                           ref_type: @ref_type, ref: @ref)
// 99:                   .extract_nestedly(basename:,
// 100:                                     prioritize_extension: true,
// 101:                                     verbose:              verbose? && !quiet?)
// 102:     chdir(&block) if block
// 103:   end
// 104:
// 105:   sig { params(block: T.proc.void).void }
// 106:   def chdir(&block)
// 107:     entries = Dir["*"]
// 108:     raise "Empty archive" if entries.empty?
// 109:
// 110:     if entries.length != 1
// 111:       yield
// 112:       return
// 113:     end
// 114:
// 115:     if File.directory? entries.fetch(0)
// 116:       # chdir yields the directory name as an argument, which is unused in our case
// 117:       # However, sorbet requires us to pass a block with matching arity, so we use T.unsafe here
// 118:       Dir.chdir(entries.fetch(0), &T.unsafe(block))
// 119:     else
// 120:       yield
// 121:     end
// 122:   end
// 123:   private :chdir
// 124:
// 125:   # Returns the most recent modified time for all files in the current working directory after stage.
// 126:   #
// 127:   # @api public
// 128:   sig { overridable.returns(Time) }
// 129:   def source_modified_time
// 130:     Pathname.pwd.to_enum(:find).select(&:file?).map(&:mtime).max
// 131:   end
// 132:
// 133:   # Return the checked out source revision for version control downloads.
// 134:   #
// 135:   # @api public
// 136:   sig { overridable.returns(T.nilable(String)) }
// 137:   def source_revision; end
// 138:
// 139:   # Remove {#cached_location} and any other files associated with the resource
// 140:   # from the cache.
// 141:   #
// 142:   # @api public
// 143:   sig { overridable.void }
// 144:   def clear_cache
// 145:     rm_rf(cached_location)
// 146:   end
// 147:
// 148:   sig { returns(Pathname) }
// 149:   def basename
// 150:     cached_location.basename
// 151:   end
// 152:
// 153:   sig { override.params(title: T.any(String, Exception), sput: T.anything).void }
// 154:   def ohai(title, *sput)
// 155:     super unless quiet?
// 156:   end
// 157:
// 158:   private
// 159:
// 160:   sig { params(args: T.anything).void }
// 161:   def puts(*args)
// 162:     super unless quiet?
// 163:   end
// 164:
// 165:   sig { params(args: String, options: T.untyped).returns(SystemCommand::Result) }
// 166:   def silent_command(*args, **options)
// 167:     system_command(*args, print_stderr: false, env:, **options)
// 168:   end
// 169:
// 170:   sig { params(args: String, options: T.untyped).returns(SystemCommand::Result) }
// 171:   def command!(*args, **options)
// 172:     system_command!(
// 173:       *args,
// 174:       env: env.merge(options.fetch(:env, {})),
// 175:       **command_output_options,
// 176:       **options,
// 177:     )
// 178:   end
// 179:
// 180:   sig { returns(T::Hash[Symbol, T::Boolean]) }
// 181:   def command_output_options
// 182:     {
// 183:       print_stdout: !quiet?,
// 184:       print_stderr: !quiet?,
// 185:       verbose:      verbose? && !quiet?,
// 186:     }
// 187:   end
// 188:
// 189:   sig { overridable.returns(T::Hash[String, String]) }
// 190:   def env
// 191:     {}
// 192:   end
// 193: end
