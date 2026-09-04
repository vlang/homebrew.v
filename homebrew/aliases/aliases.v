module aliases

import os

// Translated from Homebrew/brew `aliases/aliases.rb`.
pub struct AliasEntry {
pub:
	name    string
	command string
}

pub fn reserved_commands(internal []string, developer []string, command_aliases []string) []string {
	mut reserved := []string{cap: internal.len + developer.len + command_aliases.len + 2}
	reserved << internal
	reserved << developer
	reserved << command_aliases
	reserved << ['alias', 'unalias']
	return reserved
}

pub fn init_aliases(config AliasConfig) ! {
	os.mkdir_all(config.aliases_dir)!
}

pub fn add_alias(config AliasConfig, name string, command string) ! {
	item := new_brew_alias(name, command, config)
	if os.exists(item.script()) {
		return error("alias 'brew ${name}' already exists!")
	}
	item.write(false)!
}

pub fn remove_alias(config AliasConfig, name string) ! {
	new_brew_alias(name, none, config).remove()!
}

fn alias_name_from_metadata(meta string, path string) string {
	prefix := 'alias: brew '
	if start := meta.index(prefix) {
		remaining := meta[start + prefix.len..]
		return remaining.fields()[0] or { os.base(path) }
	}
	return os.base(path)
}

pub fn alias_entries(config AliasConfig, only []string) ![]AliasEntry {
	mut entries := []AliasEntry{}
	mut names := os.ls(config.aliases_dir) or {
		if os.is_dir(config.aliases_dir) {
			return err
		}
		return entries
	}
	names.sort()
	for basename in names {
		path := os.join_path(config.aliases_dir, basename)
		if path.ends_with('~') || os.is_dir(path) {
			continue
		}
		lines := os.read_lines(path)!
		if lines.len < 2 {
			return error('invalid alias script: ${path}')
		}
		name := alias_name_from_metadata(lines[1], path)
		if only.len > 0 && name !in only {
			continue
		}
		commands := lines[2..].filter(!it.starts_with('#') && it.trim_space() != '')
		if commands.len == 0 {
			return error('alias ${name} has no command')
		}
		mut command := commands[0]
		if command.ends_with(' \$*') {
			command = command[..command.len - 3]
		}
		if command.starts_with('brew ') {
			command = command[5..]
		} else {
			command = '!${command}'
		}
		entries << AliasEntry{
			name: name
			command: command
		}
	}
	return entries
}

pub fn show_aliases(config AliasConfig, only []string) ![]string {
	entries := alias_entries(config, only)!
	mut output := []string{cap: entries.len}
	for entry in entries {
		output << "brew alias ${entry.name}='${entry.command}'"
		item := new_brew_alias(entry.name, entry.command, config)
		if !os.exists(item.symlink()) {
			item.link()!
		}
	}
	return output
}

pub fn edit_alias(config AliasConfig, name string, command ?string, editor AliasEditor) ! {
	if value := command {
		new_brew_alias(name, value, config).write(false)!
	}
	new_brew_alias(name, command, config).edit(editor)!
}

pub fn edit_all_aliases(config AliasConfig, editor AliasEditor) ! {
	mut paths := os.ls(config.aliases_dir) or { []string{} }
	paths.sort()
	editor(paths.map(os.join_path(config.aliases_dir, it)))!
}

// Ruby method `self.reserved` at line 15.
pub fn ruby_aliases_l15_self_reserved(internal []string, developer []string,
	command_aliases []string) []string {
	return reserved_commands(internal, developer, command_aliases)
}

// Ruby method `self.init` at line 26.
pub fn ruby_aliases_l26_self_init(config AliasConfig) ! {
	init_aliases(config)!
}

// Ruby method `self.add(name, command)` at line 31.
pub fn ruby_aliases_l31_self_add(config AliasConfig, name string, command string) ! {
	add_alias(config, name, command)!
}

// Ruby method `self.remove(name)` at line 38.
pub fn ruby_aliases_l38_self_remove(config AliasConfig, name string) ! {
	remove_alias(config, name)!
}

// Ruby method `self.each(only, &block)` at line 43.
pub fn ruby_aliases_l43_self_each(config AliasConfig, only []string) ![]AliasEntry {
	return alias_entries(config, only)
}

// Ruby method `self.show(*aliases)` at line 68.
pub fn ruby_aliases_l68_self_show(config AliasConfig, names []string) ![]string {
	return show_aliases(config, names)
}

// Ruby method `self.edit(name, command = nil)` at line 77.
pub fn ruby_aliases_l77_self_edit(config AliasConfig, name string, command ?string,
	editor AliasEditor) ! {
	edit_alias(config, name, command, editor)!
}

// Ruby method `self.edit_all` at line 83.
pub fn ruby_aliases_l83_self_edit_all(config AliasConfig, editor AliasEditor) ! {
	edit_all_aliases(config, editor)!
}
