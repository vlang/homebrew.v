module homebrew

import brew_runtime

// Translated from Homebrew/brew `embedded_patch.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_writer `attr_writer :owner` at line 15.
pub fn ruby_embedded_patch_l15_d1_owner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('owner=', ...args)
}

// Ruby attr_reader `attr_reader :strip` at line 18.
pub fn ruby_embedded_patch_l18_d2_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip', ...args)
}

// Ruby attr_accessor `attr_accessor :directory` at line 21.
pub fn ruby_embedded_patch_l21_d3_directory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('directory', ...args)
}

// Ruby attr_accessor `attr_accessor :directory` at line 21.
pub fn ruby_embedded_patch_l21_d4_directory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('directory=', ...args)
}

// Ruby method `initialize(strip)` at line 24.
pub fn ruby_embedded_patch_l24_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `external?` at line 31.
pub fn ruby_embedded_patch_l31_d6_external(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('external?', ...args)
}

// Ruby method `filename; end` at line 36.
pub fn ruby_embedded_patch_l36_d7_filename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('filename', ...args)
}

// Ruby method `contents; end` at line 39.
pub fn ruby_embedded_patch_l39_d8_contents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('contents', ...args)
}

// Ruby method `apply` at line 42.
pub fn ruby_embedded_patch_l42_d9_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('apply', ...args)
}

// Ruby method `inspect` at line 57.
pub fn ruby_embedded_patch_l57_d10_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "resource"
// 5: require "utils/output"
// 6:
// 7: # An abstract class representing a patch embedded into a formula.
// 8: class EmbeddedPatch
// 9:   include Utils::Output::Mixin
// 10:   extend T::Helpers
// 11:
// 12:   abstract!
// 13:
// 14:   sig { params(owner: T.nilable(Resource::Owner)).returns(T.nilable(Resource::Owner)) }
// 15:   attr_writer :owner
// 16:
// 17:   sig { returns(T.any(String, Symbol)) }
// 18:   attr_reader :strip
// 19:
// 20:   sig { returns(T.nilable(T.any(String, Pathname))) }
// 21:   attr_accessor :directory
// 22:
// 23:   sig { params(strip: T.any(String, Symbol)).void }
// 24:   def initialize(strip)
// 25:     @strip = strip
// 26:     @owner = T.let(nil, T.nilable(Resource::Owner))
// 27:     @directory = T.let(nil, T.nilable(T.any(String, Pathname)))
// 28:   end
// 29:
// 30:   sig { returns(T::Boolean) }
// 31:   def external?
// 32:     false
// 33:   end
// 34:
// 35:   sig { abstract.returns(String) }
// 36:   def filename; end
// 37:
// 38:   sig { abstract.returns(String) }
// 39:   def contents; end
// 40:
// 41:   sig { void }
// 42:   def apply
// 43:     data = contents.gsub("@@HOMEBREW_PREFIX@@", HOMEBREW_PREFIX)
// 44:     args = %W[-g 0 -f -#{strip}]
// 45:     dir = Pathname.pwd
// 46:     if (subdirectory = directory.presence)
// 47:       dir /= subdirectory
// 48:     end
// 49:     ohai "Applying #{filename}"
// 50:     Patch.ensure_targets_within!(data, strip:, base: dir)
// 51:     dir.cd do
// 52:       Utils.safe_popen_write("patch", *args) { |p| p.write(data) }
// 53:     end
// 54:   end
// 55:
// 56:   sig { returns(String) }
// 57:   def inspect
// 58:     "#<#{self.class.name}: #{strip.inspect}>"
// 59:   end
// 60: end
