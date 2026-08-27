module aliases

import brew_runtime

// Translated from Homebrew/brew `aliases/alias.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :name` at line 13.
pub fn ruby_alias_l13_d1_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_accessor `attr_accessor :name` at line 13.
pub fn ruby_alias_l13_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name=', ...args)
}

// Ruby attr_accessor `attr_accessor :command` at line 16.
pub fn ruby_alias_l16_d3_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command', ...args)
}

// Ruby attr_accessor `attr_accessor :command` at line 16.
pub fn ruby_alias_l16_d4_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command=', ...args)
}

// Ruby method `initialize(name, command = nil)` at line 19.
pub fn ruby_alias_l19_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `reserved?` at line 33.
pub fn ruby_alias_l33_d6_reserved(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reserved?', ...args)
}

// Ruby method `cmd_exists?` at line 38.
pub fn ruby_alias_l38_d7_cmd_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cmd_exists?', ...args)
}

// Ruby method `script` at line 44.
pub fn ruby_alias_l44_d8_script(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('script', ...args)
}

// Ruby method `symlink` at line 49.
pub fn ruby_alias_l49_d9_symlink(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symlink', ...args)
}

// Ruby method `valid_symlink?` at line 54.
pub fn ruby_alias_l54_d10_valid_symlink(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_symlink?', ...args)
}

// Ruby method `link` at line 61.
pub fn ruby_alias_l61_d11_link(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('link', ...args)
}

// Ruby method `write(opts = {})` at line 67.
pub fn ruby_alias_l67_d12_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write', ...args)
}

// Ruby method `remove` at line 106.
pub fn ruby_alias_l106_d13_remove(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remove', ...args)
}

// Ruby method `edit` at line 114.
pub fn ruby_alias_l114_d14_edit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('edit', ...args)
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
