module homebrew

import brew_runtime

// Translated from Homebrew/brew `local_patch.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :file` at line 9.
pub fn ruby_local_patch_l9_d1_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file', ...args)
}

// Ruby attr_reader `attr_reader :owner` at line 12.
pub fn ruby_local_patch_l12_d2_owner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('owner', ...args)
}

// Ruby method `self.valid_path?(path_string)` at line 15.
pub fn ruby_local_patch_l15_d3_self_valid_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.valid_path?', ...args)
}

// Ruby attr_reader `attr_reader :type` at line 25.
pub fn ruby_local_patch_l25_d4_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `initialize(strip, file, directory = nil, resolves: [], type: nil)` at line 36.
pub fn ruby_local_patch_l36_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `resolves` at line 45.
pub fn ruby_local_patch_l45_d6_resolves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolves', ...args)
}

// Ruby method `filename = file.to_s.delete_prefix("Patches/")` at line 50.
pub fn ruby_local_patch_l50_d7_filename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('filename', ...args)
}

// Ruby method `contents` at line 53.
pub fn ruby_local_patch_l53_d8_contents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('contents', ...args)
}

// Ruby method `inspect` at line 86.
pub fn ruby_local_patch_l86_d9_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby method `api_source_repository_path(path)` at line 93.
pub fn ruby_local_patch_l93_d10_api_source_repository_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_source_repository_path', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "embedded_patch"
// 5:
// 6: # A patch file stored locally within a formula repository.
// 7: class LocalPatch < EmbeddedPatch
// 8:   sig { returns(T.any(String, Pathname)) }
// 9:   attr_reader :file
// 10:
// 11:   sig { returns(T.nilable(Resource::Owner)) }
// 12:   attr_reader :owner
// 13:
// 14:   sig { params(path_string: String).returns(T::Boolean) }
// 15:   def self.valid_path?(path_string)
// 16:     path = Pathname(path_string).cleanpath
// 17:     path_string.present? &&
// 18:       !path_string.end_with?("/") &&
// 19:       !path.absolute? &&
// 20:       %w[. ..].exclude?(path.to_s) &&
// 21:       !path.to_s.start_with?("../")
// 22:   end
// 23:
// 24:   sig { returns(T.nilable(Symbol)) }
// 25:   attr_reader :type
// 26:
// 27:   sig {
// 28:     params(
// 29:       strip:     T.any(String, Symbol),
// 30:       file:      T.any(String, Pathname),
// 31:       directory: T.nilable(T.any(String, Pathname)),
// 32:       resolves:  T::Array[String],
// 33:       type:      T.nilable(Symbol),
// 34:     ).void
// 35:   }
// 36:   def initialize(strip, file, directory = nil, resolves: [], type: nil)
// 37:     super(strip)
// 38:     @file = file
// 39:     self.directory = directory
// 40:     @resolves = T.let(resolves.dup, T::Array[String])
// 41:     @type = type
// 42:   end
// 43:
// 44:   sig { returns(T::Array[String]) }
// 45:   def resolves
// 46:     (@resolves + Patch.extract_cves(file.to_s)).uniq
// 47:   end
// 48:
// 49:   sig { override.returns(String) }
// 50:   def filename = file.to_s.delete_prefix("Patches/")
// 51:
// 52:   sig { override.returns(String) }
// 53:   def contents
// 54:     owner = self.owner
// 55:     raise ArgumentError, "LocalPatch#contents called before owner was set!" unless owner
// 56:
// 57:     formula = T.cast(owner, SoftwareSpec).owner
// 58:     raise ArgumentError, "LocalPatch#contents requires a formula owner!" unless formula.is_a?(::Formula)
// 59:
// 60:     formula_path = formula.specified_path || formula.path
// 61:     api_repository_path = api_source_repository_path(formula_path)
// 62:     repository_path = api_repository_path || formula.tap&.path || formula_path.dirname
// 63:     file_path = repository_path/Pathname(file)
// 64:     repository_realpath = repository_path.realpath
// 65:     file_realpath = begin
// 66:       file_path.realpath
// 67:     rescue Errno::ENOENT
// 68:       raise ArgumentError, "Patch file does not exist: #{file}"
// 69:     end
// 70:     if file_realpath.ascend.none?(repository_realpath) &&
// 71:        !(api_repository_path &&
// 72:          begin
// 73:            file_path.expand_path.ascend.any?(api_repository_path.expand_path) &&
// 74:              file_realpath.ascend.any?((HOMEBREW_CACHE/"downloads").realpath)
// 75:          rescue Errno::ENOENT
// 76:            false
// 77:          end)
// 78:       raise ArgumentError, "Patch file must be within the formula repository."
// 79:     end
// 80:     raise ArgumentError, "Patch file must be a file: #{file}" unless file_realpath.file?
// 81:
// 82:     file_realpath.read
// 83:   end
// 84:
// 85:   sig { override.returns(String) }
// 86:   def inspect
// 87:     "#<#{self.class.name}: #{strip.inspect} #{file.inspect}>"
// 88:   end
// 89:
// 90:   private
// 91:
// 92:   sig { params(path: Pathname).returns(T.nilable(Pathname)) }
// 93:   def api_source_repository_path(path)
// 94:     source_root = if defined?(Homebrew::API::HOMEBREW_CACHE_API_SOURCE)
// 95:       Homebrew::API::HOMEBREW_CACHE_API_SOURCE
// 96:     else
// 97:       HOMEBREW_CACHE/"api-source"
// 98:     end.expand_path
// 99:     relative_path = path.expand_path.relative_path_from(source_root)
// 100:     return if relative_path.to_s.start_with?("../")
// 101:
// 102:     path_parts = relative_path.each_filename.to_a.first(3)
// 103:     return if path_parts.length < 3
// 104:
// 105:     source_root/path_parts.fetch(0)/path_parts.fetch(1)/path_parts.fetch(2)
// 106:   rescue ArgumentError
// 107:     nil
// 108:   end
// 109: end
