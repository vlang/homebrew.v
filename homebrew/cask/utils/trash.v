module utils

import ruby
import os
import time

pub struct TrashResult {
pub:
	trashed     []string
	untrashable []string
}

pub struct TrashMove {
pub:
	source    string
	target    string
	info_path string
	info      string
}

fn trash_uri_escape(path string) string {
	mut escaped := ''
	for byte in path.bytes() {
		if byte.is_letter() || byte.is_digit() || byte in [`-`, `_`, `.`, `~`, `/`] {
			escaped += byte.ascii_str()
		} else {
			hex_digits := '0123456789ABCDEF'
			escaped += '%' + hex_digits[int(byte >> 4)].ascii_str() + hex_digits[int(byte & 0x0f)].ascii_str()
		}
	}
	return escaped
}

pub fn home_trash_path(xdg_data_home string, home string) string {
	base := if xdg_data_home != '' { xdg_data_home } else { os.join_path(home, '.local', 'share') }
	return os.join_path(base, 'Trash')
}

pub fn freedesktop_trash_path(path string, files_path string, info_path string,
	deletion_date string) !TrashMove {
	basename := os.file_name(path)
	mut suffix := 0
	for {
		candidate := if suffix == 0 { basename } else { '${basename}.${suffix}' }
		target_path := os.join_path(files_path, candidate)
		target_info_path := os.join_path(info_path, '${candidate}.trashinfo')
		if os.exists(target_path) || os.is_link(target_path) || os.exists(target_info_path) {
			suffix++
			continue
		}
		info := '[Trash Info]\nPath=${trash_uri_escape(path)}\nDeletionDate=${deletion_date}\n'
		os.write_file(target_info_path, info)!
		os.chmod(target_info_path, 0o600)!
		os.mv(path, target_path) or {
			os.rm(target_info_path) or {}
			return err
		}
		return TrashMove{
			source: path
			target: target_path
			info_path: target_info_path
			info: info
		}
	}
	return error('unreachable trash path loop')
}

pub fn freedesktop_trash(paths []string, xdg_data_home string, home string,
	deletion_date string) TrashResult {
	if paths.len == 0 {
		return TrashResult{}
	}
	trash_root := home_trash_path(xdg_data_home, home)
	files_path := os.join_path(trash_root, 'files')
	info_path := os.join_path(trash_root, 'info')
	os.mkdir_all(files_path) or { return TrashResult{ untrashable: paths.clone() } }
	os.mkdir_all(info_path) or { return TrashResult{ untrashable: paths.clone() } }
	mut trashed := []string{}
	mut untrashable := []string{}
	for path in paths {
		freedesktop_trash_path(path, files_path, info_path, deletion_date) or {
			untrashable << path
			continue
		}
		trashed << path
	}
	return TrashResult{ trashed: trashed, untrashable: untrashable }
}

pub fn trash_result_value(result TrashResult) ruby.Value {
	return ruby.array_value([
		ruby.string_array_value(result.trashed),
		ruby.string_array_value(result.untrashable),
	])
}

fn trash_boundary_paths(args []ruby.Value) []string {
	if args.len == 0 {
		return []string{}
	}
	if args[0].type_name == 'Array' {
		return args[0].as_array() or { []ruby.Value{} }.map(it.as_string())
	}
	return args.filter(it.type_name in ['String', 'Pathname']).map(it.as_string())
}

fn trash_boundary_date(args []ruby.Value) string {
	for arg in args {
		if arg.type_name == 'Hash' && 'deletion_date' in arg.map_data {
			return arg.map_data['deletion_date'].as_string()
		}
	}
	return time.now().format_ss()
}

fn trash_boundary_xdg(args []ruby.Value) string {
	for arg in args {
		if arg.type_name == 'Hash' && 'xdg_data_home' in arg.map_data {
			return arg.map_data['xdg_data_home'].as_string()
		}
	}
	return os.getenv('XDG_DATA_HOME')
}

// Translated from Homebrew/brew `cask/utils/trash.rb`.
