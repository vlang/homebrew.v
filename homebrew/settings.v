module homebrew

import brew_runtime

// Translated from Homebrew/brew `settings.rb`.
// The original source is retained below until every stub has a typed V body.

// Settings binds the source's default repository and owns the per-repository
// cache supplied by Cachable.
pub struct Settings {
pub:
	repository string
pub mut:
	settings_cache Cachable[string, map[string]string]
}

pub fn new_settings(repository string) Settings {
	return Settings{
		repository:     repository
		settings_cache: new_cachable[string, map[string]string]()
	}
}

pub fn (mut settings Settings) clear_cache() {
	settings.settings_cache.clear_cache()
}

pub fn (mut settings Settings) read(setting string) ?string {
	return settings.read_from(setting, settings.repository)
}

pub fn (mut settings Settings) read_from(setting string, repository string) ?string {
	if !brew_runtime.path_exists(brew_runtime.join_path(repository, '.git/config')) {
		return none
	}
	value := settings.all(repository)[setting] or { return none }
	if value.trim_space() == '' {
		return none
	}
	return value
}

pub fn (mut settings Settings) write(setting string, value string) ! {
	settings.write_to(setting, value, settings.repository)!
}

pub fn (mut settings Settings) write_bool(setting string, value bool) ! {
	settings.write(setting, value.str())!
}

pub fn (mut settings Settings) write_to(setting string, value string, repository string) ! {
	if !brew_runtime.path_exists(brew_runtime.join_path(repository, '.git/config')) {
		return
	}
	if current := settings.read_from(setting, repository) {
		if current == value {
			return
		}
	}
	result := brew_runtime.run_command('git', ['-C', repository, 'config', '--replace-all',
		'homebrew.${setting}', value])
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
	mut cache := settings.settings_cache.cache()
	cache.entries.delete(repository)
}

pub fn (mut settings Settings) write_bool_to(setting string, value bool, repository string) ! {
	settings.write_to(setting, value.str(), repository)!
}

pub fn (mut settings Settings) delete(setting string) ! {
	settings.delete_from(setting, settings.repository)!
}

pub fn (mut settings Settings) delete_from(setting string, repository string) ! {
	if !brew_runtime.path_exists(brew_runtime.join_path(repository, '.git/config')) {
		return
	}
	if _ := settings.read_from(setting, repository) {
		result := brew_runtime.run_command('git', ['-C', repository, 'config', '--unset-all',
			'homebrew.${setting}'])
		if result.exit_code != 0 {
			return error(result.output.trim_space())
		}
		mut cache := settings.settings_cache.cache()
		cache.entries.delete(repository)
	}
}

fn (mut settings Settings) all(repository string) map[string]string {
	mut cache := settings.settings_cache.cache()
	if cached := cache.entries[repository] {
		return cached
	}
	result := brew_runtime.run_command('git', ['-C', repository, 'config', '--null', '--get-regexp',
		'^homebrew\\.'])
	mut values := map[string]string{}
	for entry in result.output.split('\0') {
		if entry == '' {
			continue
		}
		newline := entry.index('\n') or {
			key := entry.trim_string_left('homebrew.')
			values[key] = ''
			continue
		}
		key := entry[..newline].trim_string_left('homebrew.')
		values[key] = entry[newline + 1..]
	}
	cache.entries[repository] = values.clone()
	return values
}

fn settings_boundary_repository(args []brew_runtime.Value, index int) string {
	if args.len > index {
		return args[index].as_string()
	}
	return brew_runtime.real_path('.')
}

// Ruby method `self.read(setting, repo: HOMEBREW_REPOSITORY)` at line 19.
pub fn ruby_settings_l19_d1_self_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Settings.read requires a setting')
	}
	repository := settings_boundary_repository(args, 1)
	mut settings := new_settings(repository)
	if value := settings.read(args[0].as_string()) {
		return brew_runtime.string_value(value)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.write(setting, value, repo: HOMEBREW_REPOSITORY)` at line 30.
pub fn ruby_settings_l30_d2_self_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Settings.write requires a setting and value')
	}
	repository := settings_boundary_repository(args, 2)
	mut settings := new_settings(repository)
	settings.write(args[0].as_string(), args[1].as_string()) or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.delete(setting, repo: HOMEBREW_REPOSITORY)` at line 42.
pub fn ruby_settings_l42_d3_self_delete(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Settings.delete requires a setting')
	}
	repository := settings_boundary_repository(args, 1)
	mut settings := new_settings(repository)
	settings.delete(args[0].as_string()) or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `self.all(repo)` at line 54.
pub fn ruby_settings_l54_d4_self_all(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Settings.all requires a repository')
	}
	repository := args[0].as_string()
	mut settings := new_settings(repository)
	values := settings.all(repository)
	return brew_runtime.structured_value('Hash', values.str(), values)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cachable"
// 5: require "utils/popen"
// 6:
// 7: module Homebrew
// 8:   # Helper functions for reading and writing settings.
// 9:   module Settings
// 10:     extend T::Generic
// 11:     extend Cachable
// 12:
// 13:     Cache = type_template { { fixed: T::Hash[Pathname, T::Hash[String, String]] } }
// 14:
// 15:     sig {
// 16:       params(setting: T.any(String, Symbol), repo: Pathname)
// 17:         .returns(T.nilable(String))
// 18:     }
// 19:     def self.read(setting, repo: HOMEBREW_REPOSITORY)
// 20:       return unless (repo/".git/config").exist?
// 21:
// 22:       value = all(repo)[setting.to_s]
// 23:
// 24:       return if value.nil? || value.strip.empty?
// 25:
// 26:       value
// 27:     end
// 28:
// 29:     sig { params(setting: T.any(String, Symbol), value: T.any(String, T::Boolean), repo: Pathname).void }
// 30:     def self.write(setting, value, repo: HOMEBREW_REPOSITORY)
// 31:       return unless (repo/".git/config").exist?
// 32:
// 33:       value = value.to_s
// 34:
// 35:       return if read(setting, repo:) == value
// 36:
// 37:       Kernel.system("git", "-C", repo.to_s, "config", "--replace-all", "homebrew.#{setting}", value, exception: true)
// 38:       cache.delete(repo)
// 39:     end
// 40:
// 41:     sig { params(setting: T.any(String, Symbol), repo: Pathname).void }
// 42:     def self.delete(setting, repo: HOMEBREW_REPOSITORY)
// 43:       return unless (repo/".git/config").exist?
// 44:
// 45:       return if read(setting, repo:).nil?
// 46:
// 47:       Kernel.system("git", "-C", repo.to_s, "config", "--unset-all", "homebrew.#{setting}", exception: true)
// 48:       cache.delete(repo)
// 49:     end
// 50:
// 51:     # All `homebrew.*` settings in `repo`, cached so that repeated reads cost
// 52:     # one `git config` invocation per repository instead of one per setting.
// 53:     sig { params(repo: Pathname).returns(T::Hash[String, String]) }
// 54:     private_class_method def self.all(repo)
// 55:       cache[repo] ||= Utils.popen_read(
// 56:         "git", "-C", repo.to_s, "config", "--null", "--get-regexp", "^homebrew\\."
// 57:       ).split("\0").to_h do |entry|
// 58:         keyvalue = entry.split("\n", 2)
// 59:         [keyvalue.fetch(0).delete_prefix("homebrew."), keyvalue.fetch(1, "")]
// 60:       end
// 61:     end
// 62:   end
// 63: end
