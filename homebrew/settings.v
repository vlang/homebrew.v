module homebrew

import ruby

// Translated from Homebrew/brew `settings.rb`.

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
		repository: repository
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
	if !ruby.path_exists(ruby.join_path(repository, '.git/config')) {
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
	if !ruby.path_exists(ruby.join_path(repository, '.git/config')) {
		return
	}
	if current := settings.read_from(setting, repository) {
		if current == value {
			return
		}
	}
	result := ruby.run_command('git', ['-C', repository, 'config', '--replace-all',
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
	if !ruby.path_exists(ruby.join_path(repository, '.git/config')) {
		return
	}
	if _ := settings.read_from(setting, repository) {
		result := ruby.run_command('git', ['-C', repository, 'config', '--unset-all',
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
	result := ruby.run_command('git', ['-C', repository, 'config', '--null', '--get-regexp',
		'^homebrew\\.'])
	mut values := map[string]string{}
	for entry in result.output.split('\x00') {
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

fn settings_boundary_repository(args []ruby.Value, index int) string {
	if args.len > index {
		return args[index].as_string()
	}
	return ruby.real_path('.')
}
