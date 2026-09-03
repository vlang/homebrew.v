module pathname

import brew_runtime
import os

// Translated from Homebrew/brew `extend/pathname/write_mkpath_extension.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn write_mkpath(path string, content string, offset ?int, mode string) !int {
	if os.exists(path) && offset == none && mode !in ['a', 'a+'] {
		return error('Will not overwrite ${path}')
	}
	os.mkdir_all(os.dir(path))!
	if position := offset {
		mut file := os.open_file(path, 'r+') or { os.create(path)! }
		defer { file.close() }
		return file.write_to(u64(position), content.bytes())
	}
	if mode in ['a', 'a+'] {
		mut file := os.open_append(path)!
		defer { file.close() }
		return file.write_string(content)
	}
	os.write_file(path, content)!
	return content.len
}

// Ruby method `write(content, offset = T.unsafe(nil), external_encoding: T.unsafe(nil), internal_encoding: T.unsafe(nil),` at line 24.
pub fn ruby_write_mkpath_extension_l24_d1_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('WriteMkpathExtension#write requires path and content') }
	offset := if args.len > 2 && args[2].type_name != 'NilClass' {
		?int(int(args[2].as_int() or { panic(err) }))
	} else {
		none
	}
	mode := if args.len > 3 { args[3].as_string() } else { '' }
	return brew_runtime.int_value(write_mkpath(args[0].as_string(), args[1].as_string(), offset, mode) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module WriteMkpathExtension
// 5:   extend T::Helpers
// 6:
// 7:   requires_ancestor { Pathname }
// 8:
// 9:   # Source for `sig`: https://github.com/sorbet/sorbet/blob/b4092efe0a4489c28aff7e1ead6ee8a0179dc8b3/rbi/stdlib/pathname.rbi#L1392-L1411
// 10:   sig {
// 11:     params(
// 12:       content:           Object,
// 13:       offset:            Integer,
// 14:       external_encoding: T.any(String, Encoding),
// 15:       internal_encoding: T.any(String, Encoding),
// 16:       encoding:          T.any(String, Encoding),
// 17:       textmode:          BasicObject,
// 18:       binmode:           BasicObject,
// 19:       autoclose:         BasicObject,
// 20:       mode:              String,
// 21:       perm:              Integer,
// 22:     ).returns(Integer)
// 23:   }
// 24:   def write(content, offset = T.unsafe(nil), external_encoding: T.unsafe(nil), internal_encoding: T.unsafe(nil),
// 25:             encoding: T.unsafe(nil), textmode: T.unsafe(nil), binmode: T.unsafe(nil), autoclose: T.unsafe(nil),
// 26:             mode: T.unsafe(nil), perm: T.unsafe(nil))
// 27:     raise "Will not overwrite #{self}" if exist? && !offset && !mode&.match?(/^a\+?$/)
// 28:
// 29:     dirname.mkpath
// 30:
// 31:     super
// 32:   end
// 33: end
