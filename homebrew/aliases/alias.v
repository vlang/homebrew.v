module aliases

import brew_runtime
import os

// Translated from Homebrew/brew `aliases/alias.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub type AliasEditor = fn([]string) !

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
	mut prefix := brew_runtime.environment_value('HOMEBREW_PREFIX').trim_right('/')
	if prefix == '' {
		prefix = '/opt/homebrew'
	}
	mut aliases_dir := brew_runtime.environment_value('HOMEBREW_ALIASES').trim_right('/')
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

// Ruby attr_accessor `attr_accessor :name` at line 13.
pub fn ruby_alias_l13_d1_name(item BrewAlias) string {
	return item.name
}

// Ruby attr_accessor `attr_accessor :name` at line 13.
pub fn ruby_alias_l13_d2_name(mut item BrewAlias, name string) string {
	item.name = name
	return name
}

// Ruby attr_accessor `attr_accessor :command` at line 16.
pub fn ruby_alias_l16_d3_command(item BrewAlias) ?string {
	if item.has_command {
		return item.command
	}
	return none
}

// Ruby attr_accessor `attr_accessor :command` at line 16.
pub fn ruby_alias_l16_d4_command(mut item BrewAlias, command ?string) ?string {
	if value := command {
		item.command = value
		item.has_command = true
		return value
	}
	item.command = ''
	item.has_command = false
	return none
}

// Ruby method `initialize(name, command = nil)` at line 19.
pub fn ruby_alias_l19_d5_initialize(name string, command ?string, config AliasConfig) BrewAlias {
	return new_brew_alias(name, command, config)
}

// Ruby method `reserved?` at line 33.
pub fn ruby_alias_l33_d6_reserved(item BrewAlias) bool {
	return item.reserved()
}

// Ruby method `cmd_exists?` at line 38.
pub fn ruby_alias_l38_d7_cmd_exists(item BrewAlias) bool {
	return item.command_exists()
}

// Ruby method `script` at line 44.
pub fn ruby_alias_l44_d8_script(item BrewAlias) string {
	return item.script()
}

// Ruby method `symlink` at line 49.
pub fn ruby_alias_l49_d9_symlink(item BrewAlias) string {
	return item.symlink()
}

// Ruby method `valid_symlink?` at line 54.
pub fn ruby_alias_l54_d10_valid_symlink(item BrewAlias) bool {
	return item.valid_symlink()
}

// Ruby method `link` at line 61.
pub fn ruby_alias_l61_d11_link(item BrewAlias) ! {
	item.link()!
}

// Ruby method `write(opts = {})` at line 67.
pub fn ruby_alias_l67_d12_write(item BrewAlias, override bool) !bool {
	return item.write(override)
}

// Ruby method `remove` at line 106.
pub fn ruby_alias_l106_d13_remove(item BrewAlias) ! {
	item.remove()!
}

// Ruby method `edit` at line 114.
pub fn ruby_alias_l114_d14_edit(item BrewAlias, editor AliasEditor) ! {
	item.edit(editor)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "fileutils"
// 5: require "utils/output"
// 6:
// 7: module Homebrew
// 8:   module Aliases
// 9:     class Alias
// 10:       include ::Utils::Output::Mixin
// 11:
// 12:       sig { returns(String) }
// 13:       attr_accessor :name
// 14:
// 15:       sig { returns(T.nilable(String)) }
// 16:       attr_accessor :command
// 17:
// 18:       sig { params(name: String, command: T.nilable(String)).void }
// 19:       def initialize(name, command = nil)
// 20:         @name = T.let(name.strip, String)
// 21:         @command = T.let(nil, T.nilable(String))
// 22:         @script = T.let(nil, T.nilable(Pathname))
// 23:         @symlink = T.let(nil, T.nilable(Pathname))
// 24:
// 25:         @command = if command&.start_with?("!", "%")
// 26:           command[1..]
// 27:         elsif command
// 28:           "brew #{command}"
// 29:         end
// 30:       end
// 31:
// 32:       sig { returns(T::Boolean) }
// 33:       def reserved?
// 34:         Aliases.reserved.include? name
// 35:       end
// 36:
// 37:       sig { returns(T::Boolean) }
// 38:       def cmd_exists?
// 39:         path = which("brew-#{name}.rb") || which("brew-#{name}")
// 40:         !path.nil? && path.realpath.parent != HOMEBREW_ALIASES
// 41:       end
// 42:
// 43:       sig { returns(Pathname) }
// 44:       def script
// 45:         @script ||= Pathname.new("#{HOMEBREW_ALIASES}/#{name.gsub(/\W/, "_")}")
// 46:       end
// 47:
// 48:       sig { returns(Pathname) }
// 49:       def symlink
// 50:         @symlink ||= Pathname.new("#{HOMEBREW_PREFIX}/bin/brew-#{name}")
// 51:       end
// 52:
// 53:       sig { returns(T::Boolean) }
// 54:       def valid_symlink?
// 55:         symlink.realpath.parent == HOMEBREW_ALIASES.realpath
// 56:       rescue NameError
// 57:         false
// 58:       end
// 59:
// 60:       sig { void }
// 61:       def link
// 62:         FileUtils.rm symlink if File.symlink? symlink
// 63:         FileUtils.ln_s script, symlink
// 64:       end
// 65:
// 66:       sig { params(opts: T::Hash[Symbol, T::Boolean]).void }
// 67:       def write(opts = {})
// 68:         odie "'#{name}' is a reserved command. Sorry." if reserved?
// 69:         odie "'brew #{name}' already exists. Sorry." if cmd_exists?
// 70:
// 71:         return if !opts[:override] && script.exist?
// 72:
// 73:         content = if command
// 74:           <<~EOS
// 75:             #:  * `#{name}` [args...]
// 76:             #:    `brew #{name}` is an alias for `#{command}`
// 77:             #{command} $*
// 78:           EOS
// 79:         else
// 80:           <<~EOS
// 81:             #:  * `#{name}` [args...]
// 82:             #:    `brew #{name}` is an alias for *command*
// 83:
// 84:             # This is a Homebrew alias script. It'll be called when the user
// 85:             # types `brew #{name}`. Any remaining arguments are passed to
// 86:             # this script. You can retrieve those with $*, or only the first
// 87:             # one with $1. Please keep your script on one line.
// 88:
// 89:             # TODO: Replace the line below with your script
// 90:             echo "Hello I'm 'brew "#{name}"' and my args are:" $*
// 91:           EOS
// 92:         end
// 93:
// 94:         script.open("w") do |f|
// 95:           f.write <<~EOS
// 96:             #! #{`which bash`.chomp}
// 97:             # alias: brew #{name}
// 98:             #{content}
// 99:           EOS
// 100:         end
// 101:         script.chmod 0744
// 102:         link
// 103:       end
// 104:
// 105:       sig { void }
// 106:       def remove
// 107:         odie "'brew #{name}' is not aliased to anything." if !symlink.exist? || !valid_symlink?
// 108:
// 109:         script.unlink
// 110:         symlink.unlink
// 111:       end
// 112:
// 113:       sig { void }
// 114:       def edit
// 115:         write(override: false)
// 116:         exec_editor script.to_s
// 117:       end
// 118:     end
// 119:   end
// 120: end
