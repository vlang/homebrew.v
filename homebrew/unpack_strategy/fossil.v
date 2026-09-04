module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/fossil.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 13.
pub fn ruby_fossil_l13_d1_self_extensions() []string {
	return fossil_extensions()
}

// Ruby method `self.can_extract?(path)` at line 18.
pub fn ruby_fossil_l18_d2_self_can_extract(path string) bool {
	return fossil_can_extract(path)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 29.
pub fn ruby_fossil_l29_d3_extract_to_dir(strategy Strategy, unpack_dir string, basename string, verbose bool) ! {
	fossil_extract_to_dir(strategy, unpack_dir, basename, verbose)!
}

pub fn fossil_extensions() []string {
	return []
}

pub fn fossil_can_extract(path string) bool {
	if !file_starts_with(path, [u8(`S`), `Q`, `L`, `i`, `t`, `e`, ` `, `f`, `o`, `r`, `m`, `a`,
		`t`, ` `, `3`, 0]) {
		return false
	}
	sqlite := command_path('sqlite3') or { return false }
	query := "select count(*) from sqlite_master where type = 'view' and name = 'artifact'"
	result := ruby.run_command(sqlite, [path, query])
	return result.exit_code == 0 && result.output.trim_space().int() == 1
}

pub fn fossil_extract_to_dir(strategy Strategy, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	mut args := ['open', strategy.path]
	if strategy.ref_type != '' && strategy.ref != '' { args << strategy.ref }
	checked_command_in_directory(command_path('fossil')!, args, unpack_dir)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking Fossil repositories.
// 8:   class Fossil
// 9:     include UnpackStrategy
// 10:     extend SystemCommand::Mixin
// 11:
// 12:     sig { override.returns(T::Array[String]) }
// 13:     def self.extensions
// 14:       []
// 15:     end
// 16:
// 17:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 18:     def self.can_extract?(path)
// 19:       return false unless path.magic_number.match?(/\ASQLite format 3\000/n)
// 20:
// 21:       # Fossil database is made up of artifacts, so the `artifact` table must exist.
// 22:       query = "select count(*) from sqlite_master where type = 'view' and name = 'artifact'"
// 23:       system_command("sqlite3", args: [path, query]).stdout.to_i == 1
// 24:     end
// 25:
// 26:     private
// 27:
// 28:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 29:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 30:       args = if @ref_type && @ref
// 31:         [@ref]
// 32:       else
// 33:         []
// 34:       end
// 35:
// 36:       system_command! "fossil",
// 37:                       args:    ["open", path, *args],
// 38:                       chdir:   unpack_dir,
// 39:                       env:     Utils::Path.formula_opt_bin_env("fossil"),
// 40:                       verbose:
// 41:     end
// 42:   end
// 43: end
