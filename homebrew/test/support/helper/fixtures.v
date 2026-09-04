module helper

import ruby
import crypto.sha256
import os

// Translated from Homebrew/brew `test/support/helper/fixtures.rb`.
// The original source is retained below for exact boundary auditing.

pub const fixtures_root = '/Users/alex/code/3rd/brew/Library/Homebrew/test/support/fixtures'

pub fn fixture_path(name string, root string) string {
	return os.join_path(if root != '' { root } else { fixtures_root }, name)
}

pub fn fixture_sha256(path string) !string {
	return sha256.sum256(os.read_bytes(path)!).hex()
}

fn fixture_name_arg(args []ruby.Value) string {
	return if args.len > 0 { args[0].as_string() } else { '' }
}

fn fixture_root_arg(args []ruby.Value) string {
	return if args.len > 1 { args[1].as_string() } else { fixtures_root }
}

// Ruby method `dylib_path(name)` at line 7.
pub fn ruby_fixtures_l7_d1_dylib_path(args ...ruby.Value) ruby.Value {
	path := fixture_path(os.join_path('mach', '${fixture_name_arg(args)}.dylib'), fixture_root_arg(args))
	return ruby.structured_value('MachOPathname', path, {
		'path': path
	})
}

// Ruby method `bundle_path(name)` at line 11.
pub fn ruby_fixtures_l11_d2_bundle_path(args ...ruby.Value) ruby.Value {
	path := fixture_path(os.join_path('mach', '${fixture_name_arg(args)}.bundle'), fixture_root_arg(args))
	return ruby.structured_value('MachOPathname', path, {
		'path': path
	})
}

// Ruby method `cask_path(name)` at line 15.
pub fn ruby_fixtures_l15_d3_cask_path(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', fixture_path(os.join_path('cask', 'Casks', '${fixture_name_arg(args)}.rb'), fixture_root_arg(args)))
}

// Ruby method `tarball_fixture(name)` at line 19.
pub fn ruby_fixtures_l19_d4_tarball_fixture(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', fixture_path(os.join_path('tarballs', fixture_name_arg(args)), fixture_root_arg(args)))
}

// Ruby method `tarball_fixture_sha256(name)` at line 23.
pub fn ruby_fixtures_l23_d5_tarball_fixture_sha256(args ...ruby.Value) ruby.Value {
	path := fixture_path(os.join_path('tarballs', fixture_name_arg(args)), fixture_root_arg(args))
	return ruby.string_value(fixture_sha256(path) or {
		return ruby.object_value('FileError', err.msg())
	})
}

// Ruby method `patch_fixture(name)` at line 27.
pub fn ruby_fixtures_l27_d6_patch_fixture(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', fixture_path(os.join_path('patches', '${fixture_name_arg(args)}.diff'), fixture_root_arg(args)))
}

// Ruby method `patch_fixture_sha256(name)` at line 31.
pub fn ruby_fixtures_l31_d7_patch_fixture_sha256(args ...ruby.Value) ruby.Value {
	path := fixture_path(os.join_path('patches', '${fixture_name_arg(args)}.diff'), fixture_root_arg(args))
	return ruby.string_value(fixture_sha256(path) or {
		return ruby.object_value('FileError', err.msg())
	})
}

// Ruby method `fixture(name)` at line 35.
pub fn ruby_fixtures_l35_d8_fixture(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', fixture_path(fixture_name_arg(args), fixture_root_arg(args)))
}

// Ruby method `sha256_for_fixture_path(path)` at line 45.
pub fn ruby_fixtures_l45_d9_sha256_for_fixture_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'fixture path is required')
	}
	return ruby.string_value(fixture_sha256(args[0].as_string()) or {
		return ruby.object_value('FileError', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: module Test
// 5:   module Helper
// 6:     module Fixtures
// 7:       def dylib_path(name)
// 8:         MachOPathname.wrap("#{TEST_FIXTURE_DIR}/mach/#{name}.dylib")
// 9:       end
// 10:
// 11:       def bundle_path(name)
// 12:         MachOPathname.wrap("#{TEST_FIXTURE_DIR}/mach/#{name}.bundle")
// 13:       end
// 14:
// 15:       def cask_path(name)
// 16:         fixture("cask/Casks/#{name}.rb")
// 17:       end
// 18:
// 19:       def tarball_fixture(name)
// 20:         fixture("tarballs/#{name}")
// 21:       end
// 22:
// 23:       def tarball_fixture_sha256(name)
// 24:         sha256_for_fixture_path(tarball_fixture(name))
// 25:       end
// 26:
// 27:       def patch_fixture(name)
// 28:         fixture("patches/#{name}.diff")
// 29:       end
// 30:
// 31:       def patch_fixture_sha256(name)
// 32:         sha256_for_fixture_path(patch_fixture(name))
// 33:       end
// 34:
// 35:       def fixture(name)
// 36:         TEST_FIXTURE_DIR/name
// 37:       end
// 38:
// 39:       private
// 40:
// 41:       # Intentionally wanting to cache this globally as fixtures are immutable.
// 42:       # rubocop:disable Style/ClassVars
// 43:       @@fixture_sha256 = {}
// 44:       # rubocop:enable Style/ClassVars
// 45:       def sha256_for_fixture_path(path)
// 46:         @@fixture_sha256[path] ||= Digest::SHA256.file(path).hexdigest
// 47:       end
// 48:     end
// 49:   end
// 50: end
