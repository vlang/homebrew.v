module homebrew

import brew_runtime

// Translated from Homebrew/brew `install_renamed.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `install_p(src, new_basename, &_block)` at line 10.
pub fn ruby_install_renamed_l10_d1_install_p(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_p', ...args)
}

// Ruby method `cp_path_sub(pattern, replacement, &_block)` at line 25.
pub fn ruby_install_renamed_l25_d2_cp_path_sub(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cp_path_sub', ...args)
}

// Ruby method `+(other)` at line 32.
pub fn ruby_install_renamed_l32_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('+', ...args)
}

// Ruby method `/(other)` at line 37.
pub fn ruby_install_renamed_l37_d4_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('/', ...args)
}

// Ruby method `append_default_if_different(src, dst)` at line 44.
pub fn ruby_install_renamed_l44_d5_append_default_if_different(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('append_default_if_different', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Helper module for installing default files.
// 5: module InstallRenamed
// 6:   sig {
// 7:     params(src: T.any(String, Pathname), new_basename: String,
// 8:            _block: T.nilable(T.proc.params(src: Pathname, dst: Pathname).returns(T.nilable(Pathname)))).void
// 9:   }
// 10:   def install_p(src, new_basename, &_block)
// 11:     super do |src, dst|
// 12:       if src.directory?
// 13:         dst.install(src.children)
// 14:         next
// 15:       else
// 16:         append_default_if_different(src, dst)
// 17:       end
// 18:     end
// 19:   end
// 20:
// 21:   sig {
// 22:     params(pattern: T.any(Pathname, String, Regexp), replacement: T.any(Pathname, String),
// 23:            _block: T.nilable(T.proc.params(src: Pathname, dst: Pathname).returns(Pathname))).void
// 24:   }
// 25:   def cp_path_sub(pattern, replacement, &_block)
// 26:     super do |src, dst|
// 27:       append_default_if_different(src, dst)
// 28:     end
// 29:   end
// 30:
// 31:   sig { params(other: T.any(String, Pathname)).returns(Pathname) }
// 32:   def +(other)
// 33:     super.extend(InstallRenamed)
// 34:   end
// 35:
// 36:   sig { params(other: T.any(String, Pathname)).returns(Pathname) }
// 37:   def /(other)
// 38:     super.extend(InstallRenamed)
// 39:   end
// 40:
// 41:   private
// 42:
// 43:   sig { params(src: Pathname, dst: Pathname).returns(Pathname) }
// 44:   def append_default_if_different(src, dst)
// 45:     return dst if !dst.file? || FileUtils.identical?(src, dst)
// 46:
// 47:     # Bottle installs restore config from `<keg>/.bottle/etc` through this
// 48:     # helper. If the live config still matches an older bottled default, replace
// 49:     # it so untouched configs advance on upgrade. Modified configs still receive
// 50:     # the new default as `*.default`.
// 51:     # Resolve via realpath so the ascend walks the Cellar path, not `opt_prefix`.
// 52:     # For symlink sources, resolve only the parent directory so broken symlinks
// 53:     # are still handled without requiring the target to exist.
// 54:     src = if src.symlink?
// 55:       src.dirname.realpath/src.basename
// 56:     else
// 57:       src.realpath
// 58:     end
// 59:     src.ascend do |path|
// 60:       next if path.basename.to_s != ".bottle" || path.parent.parent.parent != HOMEBREW_CELLAR
// 61:
// 62:       path.parent.parent.subdirs.each do |prefix|
// 63:         next if prefix == path.parent
// 64:
// 65:         default_file = prefix/".bottle"/src.relative_path_from(path)
// 66:         return dst if default_file.file? && FileUtils.identical?(dst, default_file)
// 67:       end
// 68:
// 69:       break
// 70:     end
// 71:
// 72:     Pathname.new("#{dst}.default")
// 73:   end
// 74: end
