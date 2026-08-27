module helper

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/fixtures.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `dylib_path(name)` at line 7.
pub fn ruby_fixtures_l7_d1_dylib_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dylib_path', ...args)
}

// Ruby method `bundle_path(name)` at line 11.
pub fn ruby_fixtures_l11_d2_bundle_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bundle_path', ...args)
}

// Ruby method `cask_path(name)` at line 15.
pub fn ruby_fixtures_l15_d3_cask_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_path', ...args)
}

// Ruby method `tarball_fixture(name)` at line 19.
pub fn ruby_fixtures_l19_d4_tarball_fixture(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tarball_fixture', ...args)
}

// Ruby method `tarball_fixture_sha256(name)` at line 23.
pub fn ruby_fixtures_l23_d5_tarball_fixture_sha256(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tarball_fixture_sha256', ...args)
}

// Ruby method `patch_fixture(name)` at line 27.
pub fn ruby_fixtures_l27_d6_patch_fixture(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_fixture', ...args)
}

// Ruby method `patch_fixture_sha256(name)` at line 31.
pub fn ruby_fixtures_l31_d7_patch_fixture_sha256(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_fixture_sha256', ...args)
}

// Ruby method `fixture(name)` at line 35.
pub fn ruby_fixtures_l35_d8_fixture(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fixture', ...args)
}

// Ruby method `sha256_for_fixture_path(path)` at line 45.
pub fn ruby_fixtures_l45_d9_sha256_for_fixture_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sha256_for_fixture_path', ...args)
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
