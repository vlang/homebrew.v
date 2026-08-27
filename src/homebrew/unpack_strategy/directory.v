module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `unpack_strategy/directory.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_directory_l10_d1_self_extensions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extensions', ...args)
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_directory_l15_d2_self_can_extract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.can_extract?', ...args)
}

// Ruby method `initialize(path, ref_type: nil, ref: nil, merge_xattrs: false, move: false)` at line 28.
pub fn ruby_directory_l28_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 36.
pub fn ruby_directory_l36_d4_extract_to_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extract_to_dir', ...args)
}

// Ruby method `move_to_dir(unpack_dir, verbose:)` at line 49.
pub fn ruby_directory_l49_d5_move_to_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('move_to_dir', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking directories.
// 6:   class Directory
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       []
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.directory?
// 17:     end
// 18:
// 19:     sig {
// 20:       params(
// 21:         path:         T.any(String, Pathname),
// 22:         ref_type:     T.nilable(Symbol),
// 23:         ref:          T.nilable(String),
// 24:         merge_xattrs: T::Boolean,
// 25:         move:         T::Boolean,
// 26:       ).void
// 27:     }
// 28:     def initialize(path, ref_type: nil, ref: nil, merge_xattrs: false, move: false)
// 29:       super(path, ref_type:, ref:, merge_xattrs:)
// 30:       @move = move
// 31:     end
// 32:
// 33:     private
// 34:
// 35:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 36:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 37:       move_to_dir(unpack_dir, verbose:) if @move
// 38:       path_children = path.children
// 39:       return if path_children.empty?
// 40:
// 41:       system_command!("cp", args: ["-pR", *path_children, unpack_dir], verbose:)
// 42:     end
// 43:
// 44:     # Move all files from source `path` to target `unpack_dir`. Any existing
// 45:     # subdirectories are not modified and only the contents are moved.
// 46:     #
// 47:     # @raise [RuntimeError] on unsupported `mv` operation, e.g. overwriting a file with a directory
// 48:     sig { params(unpack_dir: Pathname, verbose: T::Boolean).void }
// 49:     def move_to_dir(unpack_dir, verbose:)
// 50:       path.find do |src|
// 51:         next if src == path
// 52:
// 53:         dst = unpack_dir/src.relative_path_from(path)
// 54:         if dst.exist?
// 55:           dst_real_dir = dst.directory? && !dst.symlink?
// 56:           src_real_dir = src.directory? && !src.symlink?
// 57:           # Avoid moving a directory over an existing non-directory and vice versa.
// 58:           # This outputs the same error message as GNU mv which is more readable than macOS mv.
// 59:           raise "mv: cannot overwrite non-directory '#{dst}' with directory '#{src}'" if src_real_dir && !dst_real_dir
// 60:           raise "mv: cannot overwrite directory '#{dst}' with non-directory '#{src}'" if !src_real_dir && dst_real_dir
// 61:           # Defer writing over existing directories. Handle this later on to copy attributes
// 62:           next if dst_real_dir
// 63:
// 64:           FileUtils.rm(dst, verbose:)
// 65:         end
// 66:
// 67:         FileUtils.mv(src, dst, verbose:)
// 68:         Find.prune
// 69:       end
// 70:     end
// 71:   end
// 72: end
