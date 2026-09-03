module homebrew

import brew_runtime

// Translated from Homebrew/brew `embedded_patch.rb`.
// The original source is retained below.

// EmbeddedPatch contains the concrete state and behavior shared by embedded
// string and DATA patches. Ruby inheritance is represented by composition in V.
pub struct EmbeddedPatch {
pub:
	strip         string
	has_directory bool
	directory     string
	owner         ?string
}

pub struct EmbeddedPatchSource {
pub:
	patch    EmbeddedPatch
	filename string
	contents string
}

// new_embedded_patch translates EmbeddedPatch#initialize.
pub fn new_embedded_patch(strip string) EmbeddedPatch {
	return EmbeddedPatch{
		strip: strip
	}
}

// with_directory translates the directory writer while retaining V value
// semantics. An empty directory has the same effect as Ruby's presence check.
pub fn (patch EmbeddedPatch) with_directory(directory string) EmbeddedPatch {
	return EmbeddedPatch{
		strip: patch.strip
		has_directory: true
		directory: directory
		owner: patch.owner
	}
}

pub fn (patch EmbeddedPatch) without_directory() EmbeddedPatch {
	return EmbeddedPatch{
		strip: patch.strip
		owner: patch.owner
	}
}

pub fn (patch EmbeddedPatch) with_owner(owner ?string) EmbeddedPatch {
	return EmbeddedPatch{
		strip: patch.strip
		has_directory: patch.has_directory
		directory: patch.directory
		owner: owner
	}
}

pub fn (patch EmbeddedPatch) external() bool {
	return false
}

// target_directory translates Pathname.pwd followed by the optional directory.
pub fn (patch EmbeddedPatch) target_directory(current_directory string) string {
	if patch.has_directory && patch.directory != '' {
		return brew_runtime.join_path(current_directory, patch.directory)
	}
	return current_directory
}

// apply translates EmbeddedPatch#apply. V passes the abstract filename and
// contents explicitly because the translated descendants use composition.
pub fn (patch EmbeddedPatch) apply(filename string, contents string, current_directory string, homebrew_prefix string) ! {
	_ = filename
	apply_patch_text(contents, patch.strip, patch.target_directory(current_directory), homebrew_prefix)!
}

pub fn (patch EmbeddedPatch) inspect(class_name ...string) string {
	name := if class_name.len == 0 { 'EmbeddedPatch' } else { class_name[0] }
	return '#<${name}: :${patch.strip}>'
}

// Ruby attr_writer `attr_writer :owner` at line 15.
pub fn ruby_embedded_patch_l15_d1_owner(patch EmbeddedPatch, owner ?string) EmbeddedPatch {
	return patch.with_owner(owner)
}

// Ruby attr_reader `attr_reader :strip` at line 18.
pub fn ruby_embedded_patch_l18_d2_strip(patch EmbeddedPatch) string {
	return patch.strip
}

// Ruby attr_accessor `attr_accessor :directory` at line 21.
pub fn ruby_embedded_patch_l21_d3_directory(patch EmbeddedPatch) ?string {
	if patch.has_directory {
		return patch.directory
	}
	return none
}

// Ruby attr_accessor `attr_accessor :directory` at line 21.
pub fn ruby_embedded_patch_l21_d4_directory(patch EmbeddedPatch, directory string) EmbeddedPatch {
	return patch.with_directory(directory)
}

// Ruby method `initialize(strip)` at line 24.
pub fn ruby_embedded_patch_l24_d5_initialize(strip string) EmbeddedPatch {
	return new_embedded_patch(strip)
}

// Ruby method `external?` at line 31.
pub fn ruby_embedded_patch_l31_d6_external(patch EmbeddedPatch) bool {
	return patch.external()
}

// Ruby method `filename; end` at line 36.
pub fn ruby_embedded_patch_l36_d7_filename(source EmbeddedPatchSource) string {
	return source.filename
}

// Ruby method `contents; end` at line 39.
pub fn ruby_embedded_patch_l39_d8_contents(source EmbeddedPatchSource) string {
	return source.contents
}

// Ruby method `apply` at line 42.
pub fn ruby_embedded_patch_l42_d9_apply(patch EmbeddedPatch, filename string, contents string, current_directory string, homebrew_prefix string) ! {
	patch.apply(filename, contents, current_directory, homebrew_prefix)!
}

// Ruby method `inspect` at line 57.
pub fn ruby_embedded_patch_l57_d10_inspect(patch EmbeddedPatch) string {
	return patch.inspect()
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
