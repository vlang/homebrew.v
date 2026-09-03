module aliases

import os

// Translated from Homebrew/brew `aliases/aliases.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "aliases/alias"
// 5: require "utils/output"
// 6:
// 7: module Homebrew
// 8:   module Aliases
// 9:     extend Utils::Output::Mixin
// 10:
// 11:     # Lazily computed to avoid a load-time cycle: `Commands.internal_commands`
// 12:     # requires every `cmd/*.rb`, including `cmd/alias.rb`, which itself
// 13:     # requires this file.
// 14:     sig { returns(T::Array[String]) }
// 15:     def self.reserved
// 16:       @reserved ||= T.let(
// 17:         (Commands.internal_commands +
// 18:          Commands.internal_developer_commands +
// 19:          Commands.internal_commands_aliases +
// 20:          %w[alias unalias]).freeze,
// 21:         T.nilable(T::Array[String]),
// 22:       )
// 23:     end
// 24:
// 25:     sig { void }
// 26:     def self.init
// 27:       FileUtils.mkdir_p HOMEBREW_ALIASES
// 28:     end
// 29:
// 30:     sig { params(name: String, command: String).void }
// 31:     def self.add(name, command)
// 32:       new_alias = Alias.new(name, command)
// 33:       odie "alias 'brew #{name}' already exists!" if new_alias.script.exist?
// 34:       new_alias.write
// 35:     end
// 36:
// 37:     sig { params(name: String).void }
// 38:     def self.remove(name)
// 39:       Alias.new(name).remove
// 40:     end
// 41:
// 42:     sig { params(only: T::Array[String], block: T.proc.params(name: String, command: String).void).void }
// 43:     def self.each(only, &block)
// 44:       Dir["#{HOMEBREW_ALIASES}/*"].each do |path|
// 45:         next if path.end_with? "~" # skip Emacs-like backup files
// 46:         next if File.directory?(path)
// 47:
// 48:         _shebang, meta, *lines = File.readlines(path)
// 49:         name = T.must(meta)[/alias: brew (\S+)/, 1] || File.basename(path)
// 50:         next if !only.empty? && only.exclude?(name)
// 51:
// 52:         lines.reject! { |line| line.start_with?("#") || line =~ /^\s*$/ }
// 53:         first_line = lines.fetch(0)
// 54:         command = first_line.chomp
// 55:         command.sub!(/ \$\*$/, "")
// 56:
// 57:         if command.start_with? "brew "
// 58:           command.sub!(/^brew /, "")
// 59:         else
// 60:           command = "!#{command}"
// 61:         end
// 62:
// 63:         yield name, command if block.present?
// 64:       end
// 65:     end
// 66:
// 67:     sig { params(aliases: String).void }
// 68:     def self.show(*aliases)
// 69:       each([*aliases]) do |name, command|
// 70:         puts "brew alias #{name}='#{command}'"
// 71:         existing_alias = Alias.new(name, command)
// 72:         existing_alias.link unless existing_alias.symlink.exist?
// 73:       end
// 74:     end
// 75:
// 76:     sig { params(name: String, command: T.nilable(String)).void }
// 77:     def self.edit(name, command = nil)
// 78:       Alias.new(name, command).write unless command.nil?
// 79:       Alias.new(name, command).edit
// 80:     end
// 81:
// 82:     sig { void }
// 83:     def self.edit_all
// 84:       exec_editor(*Dir[HOMEBREW_ALIASES])
// 85:     end
// 86:   end
// 87: end
