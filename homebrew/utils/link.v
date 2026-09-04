module utils

import os

// Translated from Homebrew/brew `utils/link.rb`.
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
