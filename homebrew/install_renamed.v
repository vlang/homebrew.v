module homebrew

import ruby
import homebrew.extend
import os

// Translated from Homebrew/brew `install_renamed.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `install_p(src, new_basename, &_block)` at line 10.
pub fn ruby_install_renamed_l10_d1_install_p(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('InstallRenamed#install_p requires destination, source, and basename')
	}
	cellar := if args.len > 3 { args[3].as_string() } else { '' }
	install_renamed_install_p(args[0].as_string(), args[1].as_string(), args[2].as_string(), cellar) or {
		panic(err)
	}
	return ruby.bool_value(true)
}

// Ruby method `cp_path_sub(pattern, replacement, &_block)` at line 25.
pub fn ruby_install_renamed_l25_d2_cp_path_sub(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('InstallRenamed#cp_path_sub requires path, pattern, and replacement')
	}
	cellar := if args.len > 3 { args[3].as_string() } else { '' }
	return ruby.string_value(install_renamed_cp_path_sub(args[0].as_string(), args[1].as_string(), args[2].as_string(), cellar) or { panic(err) })
}

// Ruby method `+(other)` at line 32.
pub fn ruby_install_renamed_l32_d3_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('InstallRenamed#+ requires a path and other value')
	}
	return ruby.string_value(install_renamed_add(args[0].as_string(), args[1].as_string()))
}

// Ruby method `/(other)` at line 37.
pub fn ruby_install_renamed_l37_d4_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('InstallRenamed#/ requires a path and other value')
	}
	return ruby.string_value(install_renamed_join(args[0].as_string(), args[1].as_string()))
}

// Ruby method `append_default_if_different(src, dst)` at line 44.
pub fn ruby_install_renamed_l44_d5_append_default_if_different(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('InstallRenamed#append_default_if_different requires source and destination')
	}
	cellar := if args.len > 2 { args[2].as_string() } else { '' }
	return ruby.string_value(install_renamed_append_default_if_different(args[0].as_string(), args[1].as_string(), cellar) or { panic(err) })
}

pub fn install_renamed_install_p(destination string, source string, new_basename string, cellar string) ! {
	target := os.join_path(destination, new_basename)
	if os.is_dir(source) && !os.is_link(source) && os.is_dir(target) && !os.is_link(target) {
		mut children := os.ls(source)!
		children.sort()
		for child in children {
			install_renamed_install_p(target, os.join_path(source, child), child, cellar)!
		}
		if os.ls(source)!.len == 0 {
			os.rmdir(source) or {}
		}
		return
	}
	selected := install_renamed_append_default_if_different(source, target, cellar)!
	extend.pathname_install_p(os.dir(selected), source, os.base(selected))!
}

pub fn install_renamed_cp_path_sub(path string, pattern string, replacement string, cellar string) !string {
	if !os.exists(path) && !os.is_link(path) {
		return error('${path} does not exist')
	}
	destination := path.replace_once(pattern, replacement)
	if destination == path {
		return error('${path} is the same file as ${destination}')
	}
	selected := install_renamed_append_default_if_different(path, destination, cellar)!
	os.mkdir_all(os.dir(selected))!
	if os.is_dir(path) && !os.is_link(path) {
		os.cp_all(path, selected, true)!
	} else {
		os.cp(path, selected)!
	}
	return selected
}

pub fn install_renamed_add(path string, other string) string {
	return path + other
}

pub fn install_renamed_join(path string, other string) string {
	return os.join_path(path, other)
}

pub fn install_renamed_append_default_if_different(source string, destination string, cellar string) !string {
	if !os.is_file(destination) || install_renamed_identical(source, destination) {
		return destination
	}
	resolved_source := if os.is_link(source) {
		os.join_path(os.real_path(os.dir(source)), os.base(source))
	} else {
		os.real_path(source)
	}
	if cellar != '' {
		mut ancestor := resolved_source
		for {
			if os.base(ancestor) == '.bottle' && os.norm_path(os.dir(os.dir(os.dir(ancestor)))) == os.norm_path(cellar) {
				formula_directory := os.dir(os.dir(ancestor))
				relative_source := install_renamed_relative_path(resolved_source, ancestor)
				for version in os.ls(formula_directory) or { []string{} } {
					prefix := os.join_path(formula_directory, version)
					if os.norm_path(prefix) == os.norm_path(os.dir(ancestor)) {
						continue
					}
					default_file := os.join_path(prefix, '.bottle', relative_source)
					if os.is_file(default_file) && install_renamed_identical(destination, default_file) {
						return destination
					}
				}
				break
			}
			parent := os.dir(ancestor)
			if parent == ancestor || ancestor == '' {
				break
			}
			ancestor = parent
		}
	}
	return '${destination}.default'
}

fn install_renamed_identical(first string, second string) bool {
	if !os.is_file(first) || !os.is_file(second) || os.file_size(first) != os.file_size(second) {
		return false
	}
	return os.read_bytes(first) or { return false } == os.read_bytes(second) or { return false }
}

fn install_renamed_relative_path(path string, base string) string {
	clean_path := os.norm_path(path)
	clean_base := os.norm_path(base)
	prefix := if clean_base.ends_with(os.path_separator) {
		clean_base
	} else {
		clean_base + os.path_separator
	}
	return if clean_path.starts_with(prefix) {
		clean_path[prefix.len..]
	} else {
		os.base(clean_path)
	}
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
