module utils

import ruby
import os

// Translated from Homebrew/brew `utils/link.rb`.
// The original source is retained below until every stub has a typed V body.
fn link_relative_path(target string, base string) string {
	target_parts := os.norm_path(os.abs_path(target)).split('/').filter(it != '')
	base_parts := os.norm_path(os.abs_path(base)).split('/').filter(it != '')
	mut common := 0
	for common < target_parts.len && common < base_parts.len && target_parts[common] == base_parts[common] {
		common++
	}
	mut relative := []string{}
	for _ in common .. base_parts.len {
		relative << '..'
	}
	relative << target_parts[common..]
	return if relative.len == 0 { '.' } else { relative.join('/') }
}

fn link_resolved_path(path string) !string {
	target := os.readlink(path)!
	return os.norm_path(if os.is_abs_path(target) {
		target
	} else {
		os.join_path(os.dir(path), target)
	})
}

fn link_source_paths(root string, link_dir bool) ![]string {
	if !os.exists(root) && !os.is_link(root) {
		return []
	}
	if link_dir {
		return [root]
	}
	mut paths := []string{}
	mut entries := os.ls(root)!
	entries.sort()
	for entry in entries {
		path := os.join_path(root, entry)
		if os.is_dir(path) && !os.is_link(path) {
			paths << link_source_paths(path, false)!
		} else if !os.is_dir(path) {
			paths << path
		}
	}
	return paths
}

fn link_destination(source string, source_root string, destination_root string,
	link_dir bool) string {
	if link_dir {
		return destination_root
	}
	relative := source[source_root.len + 1..]
	return os.join_path(destination_root, relative)
}

pub fn link_src_dst_dirs(source_root string, destination_root string, command string,
	link_dir bool) ![]string {
	mut conflicts := []string{}
	for source in link_source_paths(source_root, link_dir)! {
		destination := link_destination(source, source_root, destination_root, link_dir)
		if os.is_link(destination) {
			resolved := link_resolved_path(destination) or { '' }
			if resolved == os.norm_path(os.abs_path(source)) {
				continue
			}
			os.rm(destination)!
		}
		if os.exists(destination) {
			conflicts << destination
			continue
		}
		os.mkdir_all(os.dir(destination))!
		os.symlink(link_relative_path(source, os.dir(destination)), destination)!
	}
	return conflicts
}

pub fn unlink_src_dst_dirs(source_root string, destination_root string, unlink_dir bool) ! {
	for source in link_source_paths(source_root, unlink_dir)! {
		destination := link_destination(source, source_root, destination_root, unlink_dir)
		if os.is_link(destination) {
			resolved := link_resolved_path(destination) or { '' }
			if resolved == os.norm_path(os.abs_path(source)) {
				os.rm(destination)!
			}
		}
		os.rmdir(os.dir(destination)) or {}
	}
}

pub fn link_manpages(path string, prefix string, command string) ![]string {
	return link_src_dst_dirs(os.join_path(path, 'manpages'), os.join_path(prefix, 'share', 'man', 'man1'), command, false)
}

pub fn unlink_manpages(path string, prefix string) ! {
	unlink_src_dst_dirs(os.join_path(path, 'manpages'), os.join_path(prefix, 'share', 'man', 'man1'), false)!
}

pub fn link_completions(path string, prefix string, command string) ![]string {
	mut conflicts := []string{}
	for mapping in [
		['bash', os.join_path(prefix, 'etc', 'bash_completion.d')],
		['zsh', os.join_path(prefix, 'share', 'zsh', 'site-functions')],
		['fish', os.join_path(prefix, 'share', 'fish', 'vendor_completions.d')],
	] {
		conflicts << link_src_dst_dirs(os.join_path(path, 'completions', mapping[0]), mapping[1], command, false)!
	}
	return conflicts
}

pub fn unlink_completions(path string, prefix string) ! {
	for mapping in [
		['bash', os.join_path(prefix, 'etc', 'bash_completion.d')],
		['zsh', os.join_path(prefix, 'share', 'zsh', 'site-functions')],
		['fish', os.join_path(prefix, 'share', 'fish', 'vendor_completions.d')],
	] {
		unlink_src_dst_dirs(os.join_path(path, 'completions', mapping[0]), mapping[1], false)!
	}
}

pub fn link_docs(path string, prefix string, command string) ![]string {
	return link_src_dst_dirs(os.join_path(path, 'docs'), os.join_path(prefix, 'share', 'doc', 'homebrew'), command, true)
}

// Ruby method `self.link_src_dst_dirs(src_dir, dst_dir, command, link_dir: false)` at line 12.
pub fn ruby_link_l12_d1_self_link_src_dst_dirs(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('link_src_dst_dirs requires source, destination, and command')
	}
	link_dir := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	conflicts := link_src_dst_dirs(args[0].as_string(), args[1].as_string(), args[2].as_string(), link_dir) or { panic(err) }
	return ruby.string_array_value(conflicts)
}

// Ruby method `self.unlink_src_dst_dirs(src_dir, dst_dir, unlink_dir: false)` at line 47.
pub fn ruby_link_l47_d2_self_unlink_src_dst_dirs(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('unlink_src_dst_dirs requires source and destination')
	}
	unlink_dir := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	unlink_src_dst_dirs(args[0].as_string(), args[1].as_string(), unlink_dir) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.link_manpages(path, command)` at line 62.
pub fn ruby_link_l62_d3_self_link_manpages(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('link_manpages requires path, command, and prefix')
	}
	return ruby.string_array_value(link_manpages(args[0].as_string(), args[2].as_string(), args[1].as_string()) or { panic(err) })
}

// Ruby method `self.unlink_manpages(path)` at line 67.
pub fn ruby_link_l67_d4_self_unlink_manpages(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('unlink_manpages requires path and prefix')
	}
	unlink_manpages(args[0].as_string(), args[1].as_string()) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.link_completions(path, command)` at line 72.
pub fn ruby_link_l72_d5_self_link_completions(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('link_completions requires path, command, and prefix')
	}
	return ruby.string_array_value(link_completions(args[0].as_string(), args[2].as_string(), args[1].as_string()) or { panic(err) })
}

// Ruby method `self.unlink_completions(path)` at line 79.
pub fn ruby_link_l79_d6_self_unlink_completions(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('unlink_completions requires path and prefix')
	}
	unlink_completions(args[0].as_string(), args[1].as_string()) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.link_docs(path, command)` at line 86.
pub fn ruby_link_l86_d7_self_link_docs(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('link_docs requires path, command, and prefix')
	}
	return ruby.string_array_value(link_docs(args[0].as_string(), args[2].as_string(), args[1].as_string()) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module Utils
// 7:   # Helper functions for creating symlinks.
// 8:   module Link
// 9:     extend Utils::Output::Mixin
// 10:
// 11:     sig { params(src_dir: Pathname, dst_dir: Pathname, command: String, link_dir: T::Boolean).void }
// 12:     def self.link_src_dst_dirs(src_dir, dst_dir, command, link_dir: false)
// 13:       return unless src_dir.exist?
// 14:
// 15:       conflicts = []
// 16:       src_paths = link_dir ? [src_dir] : src_dir.find
// 17:       src_paths.each do |src|
// 18:         next if src.directory? && !link_dir
// 19:
// 20:         dst = dst_dir/src.relative_path_from(src_dir)
// 21:         if dst.symlink?
// 22:           next if src == dst.resolved_path
// 23:
// 24:           dst.unlink
// 25:         end
// 26:         if dst.exist?
// 27:           conflicts << dst
// 28:           next
// 29:         end
// 30:         dst_dir.parent.mkpath
// 31:         dst.make_relative_symlink(src)
// 32:       end
// 33:
// 34:       return if conflicts.empty?
// 35:
// 36:       onoe <<~EOS
// 37:         Could not link:
// 38:         #{conflicts.join("\n")}
// 39:
// 40:         Please delete these paths and run:
// 41:           #{command}
// 42:       EOS
// 43:     end
// 44:     private_class_method :link_src_dst_dirs
// 45:
// 46:     sig { params(src_dir: Pathname, dst_dir: Pathname, unlink_dir: T::Boolean).void }
// 47:     def self.unlink_src_dst_dirs(src_dir, dst_dir, unlink_dir: false)
// 48:       return unless src_dir.exist?
// 49:
// 50:       src_paths = unlink_dir ? [src_dir] : src_dir.find
// 51:       src_paths.each do |src|
// 52:         next if src.directory? && !unlink_dir
// 53:
// 54:         dst = dst_dir/src.relative_path_from(src_dir)
// 55:         dst.delete if dst.symlink? && src == dst.resolved_path
// 56:         dst.parent.rmdir_if_possible
// 57:       end
// 58:     end
// 59:     private_class_method :unlink_src_dst_dirs
// 60:
// 61:     sig { params(path: Pathname, command: String).void }
// 62:     def self.link_manpages(path, command)
// 63:       link_src_dst_dirs(path/"manpages", HOMEBREW_PREFIX/"share/man/man1", command)
// 64:     end
// 65:
// 66:     sig { params(path: Pathname).void }
// 67:     def self.unlink_manpages(path)
// 68:       unlink_src_dst_dirs(path/"manpages", HOMEBREW_PREFIX/"share/man/man1")
// 69:     end
// 70:
// 71:     sig { params(path: Pathname, command: String).void }
// 72:     def self.link_completions(path, command)
// 73:       link_src_dst_dirs(path/"completions/bash", HOMEBREW_PREFIX/"etc/bash_completion.d", command)
// 74:       link_src_dst_dirs(path/"completions/zsh", HOMEBREW_PREFIX/"share/zsh/site-functions", command)
// 75:       link_src_dst_dirs(path/"completions/fish", HOMEBREW_PREFIX/"share/fish/vendor_completions.d", command)
// 76:     end
// 77:
// 78:     sig { params(path: Pathname).void }
// 79:     def self.unlink_completions(path)
// 80:       unlink_src_dst_dirs(path/"completions/bash", HOMEBREW_PREFIX/"etc/bash_completion.d")
// 81:       unlink_src_dst_dirs(path/"completions/zsh", HOMEBREW_PREFIX/"share/zsh/site-functions")
// 82:       unlink_src_dst_dirs(path/"completions/fish", HOMEBREW_PREFIX/"share/fish/vendor_completions.d")
// 83:     end
// 84:
// 85:     sig { params(path: Pathname, command: String).void }
// 86:     def self.link_docs(path, command)
// 87:       link_src_dst_dirs(path/"docs", HOMEBREW_PREFIX/"share/doc/homebrew", command, link_dir: true)
// 88:     end
// 89:   end
// 90: end
