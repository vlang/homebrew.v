module aliases

import ruby
import os

// Translated from Homebrew/brew `aliases/alias.rb`.

// AliasConfig makes Ruby's Homebrew path constants explicit for typed callers.
pub struct AliasConfig {
pub:
	aliases_dir string
	prefix      string
	reserved    []string
}

// BrewAlias is the typed equivalent of Homebrew::Aliases::Alias.
pub struct BrewAlias {
pub mut:
	name        string
	command     string
	has_command bool
pub:
	config AliasConfig
}

pub type AliasEditor = fn ([]string) !

pub fn new_brew_alias(name string, command ?string, config AliasConfig) BrewAlias {
	mut normalized_command := ''
	mut has_command := false
	if value := command {
		has_command = true
		normalized_command = if value.starts_with('!') || value.starts_with('%') {
			value[1..]
		} else {
			'brew ${value}'
		}
	}
	return BrewAlias{
		name: name.trim_space()
		command: normalized_command
		has_command: has_command
		config: config
	}
}

pub fn default_alias_config(reserved []string) AliasConfig {
	mut prefix := ruby.environment_value('HOMEBREW_PREFIX').trim_right('/')
	if prefix == '' {
		prefix = '/opt/homebrew'
	}
	mut aliases_dir := ruby.environment_value('HOMEBREW_ALIASES').trim_right('/')
	if aliases_dir == '' {
		aliases_dir = '${prefix}/Library/Aliases'
	}
	return AliasConfig{
		aliases_dir: aliases_dir
		prefix: prefix
		reserved: reserved.clone()
	}
}

pub fn (item BrewAlias) reserved() bool {
	return item.name in item.config.reserved
}

pub fn (item BrewAlias) command_exists() bool {
	for executable in ['brew-${item.name}.rb', 'brew-${item.name}'] {
		path := os.find_abs_path_of_executable(executable) or { continue }
		if os.dir(os.real_path(path)) != os.real_path(item.config.aliases_dir) {
			return true
		}
	}
	return false
}

fn alias_script_name(name string) string {
	mut result := []u8{cap: name.len}
	for character in name.bytes() {
		if (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character == `_` {
			result << character
		} else {
			result << `_`
		}
	}
	return result.bytestr()
}

pub fn (item BrewAlias) script() string {
	return os.join_path(item.config.aliases_dir, alias_script_name(item.name))
}

pub fn (item BrewAlias) symlink() string {
	return os.join_path(item.config.prefix, 'bin', 'brew-${item.name}')
}

pub fn (item BrewAlias) valid_symlink() bool {
	path := item.symlink()
	if !os.is_link(path) {
		return false
	}
	return os.dir(os.real_path(path)) == os.real_path(item.config.aliases_dir)
}

pub fn (item BrewAlias) link() ! {
	path := item.symlink()
	if os.is_link(path) {
		os.rm(path)!
	}
	os.mkdir_all(os.dir(path))!
	os.symlink(item.script(), path)!
}

fn (item BrewAlias) content() string {
	if item.has_command {
		return '#:  * `${item.name}` [args...]\n' + '#:    `brew ${item.name}` is an alias for `${item.command}`\n' + '${item.command} \$*\n'
	}
	return '#:  * `${item.name}` [args...]\n' + '#:    `brew ${item.name}` is an alias for *command*\n\n' + "# This is a Homebrew alias script. It'll be called when the user\n" + '# types `brew ${item.name}`. Any remaining arguments are passed to\n' + '# this script. You can retrieve those with \$*, or only the first\n' + '# one with \$1. Please keep your script on one line.\n\n' + '# TODO: Replace the line below with your script\n' + 'echo "Hello I\'m \'brew "${item.name}"\' and my args are:" \$*\n'
}

// write creates the exact Ruby alias script and repairs its brew-* symlink.
// It returns false when an existing script is intentionally left untouched.
pub fn (item BrewAlias) write(override bool) !bool {
	if item.reserved() {
		return error("'${item.name}' is a reserved command. Sorry.")
	}
	if item.command_exists() {
		return error("'brew ${item.name}' already exists. Sorry.")
	}
	if !override && os.exists(item.script()) {
		return false
	}
	os.mkdir_all(item.config.aliases_dir)!
	bash := os.find_abs_path_of_executable('bash') or { '/bin/bash' }
	os.write_file(item.script(), '#! ${bash}\n# alias: brew ${item.name}\n${item.content()}')!
	os.chmod(item.script(), 0o744)!
	item.link()!
	return true
}

pub fn (item BrewAlias) remove() ! {
	if !os.exists(item.symlink()) || !item.valid_symlink() {
		return error("'brew ${item.name}' is not aliased to anything.")
	}
	os.rm(item.script())!
	os.rm(item.symlink())!
}

pub fn (item BrewAlias) edit(editor AliasEditor) ! {
	item.write(false)!
	editor([item.script()])!
}
