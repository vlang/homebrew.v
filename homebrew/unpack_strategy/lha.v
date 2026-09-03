module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/lha.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_lha_l10_d1_self_extensions() []string {
	return lha_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_lha_l15_d2_self_can_extract(path string) bool {
	return lha_can_extract(path)
}

// Ruby method `dependencies` at line 20.
pub fn ruby_lha_l20_d3_dependencies() []string {
	return lha_dependencies()
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 27.
pub fn ruby_lha_l27_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	lha_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn lha_extensions() []string {
	return ['.lha', '.lzh']
}

pub fn lha_can_extract(path string) bool {
	bytes := read_file_prefix(path, 8) or { return false }
	if bytes.len < 7 || bytes[2] != `-` || bytes[6] != `-` { return false }
	method := bytes[3..6].bytestr()
	return method in ['lh0', 'lh1', 'lz4', 'lz5', 'lzs', 'lh ', 'lhd', 'lh2', 'lh3', 'lh4', 'lh5']
}

pub fn lha_dependencies() []string {
	return ['lha']
}

pub fn lha_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	lha := command_path('lha')!
	members := archive_listing(lha, ['lq', path])!
	validate_archive_members(members)!
	checked_command(lha, ['xq2w=${unpack_dir}', path])!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking LHa archives.
// 6:   class Lha
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".lha", ".lzh"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\A..-(lh0|lh1|lz4|lz5|lzs|lh\\40|lhd|lh2|lh3|lh4|lh5)-/n)
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Formula]) }
// 20:     def dependencies
// 21:       @dependencies ||= T.let([Formula["lha"]], T.nilable(T::Array[Formula]))
// 22:     end
// 23:
// 24:     private
// 25:
// 26:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 27:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 28:       system_command! "lha",
// 29:                       args:    ["xq2w=#{unpack_dir}", path],
// 30:                       env:     Utils::Path.formula_opt_bin_env("lha"),
// 31:                       verbose:
// 32:     end
// 33:   end
// 34: end
