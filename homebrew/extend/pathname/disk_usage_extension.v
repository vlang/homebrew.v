module pathname

import ruby
import homebrew.utils as hb_utils
import os

// Translated from Homebrew/brew `extend/pathname/disk_usage_extension.rb`.

pub struct PathDiskUsage {
pub mut:
	file_count i64
	disk_usage i64
}

pub struct DiskUsagePath {
pub:
	path string
mut:
	file_count ?i64
	disk_usage ?i64
}

pub fn new_disk_usage_path(path string) DiskUsagePath {
	return DiskUsagePath{
		path: path
	}
}

pub fn (mut path DiskUsagePath) disk_usage_bytes() !i64 {
	if cached := path.disk_usage {
		return cached
	}
	usage := pathname_compute_disk_usage(path.path)!
	path.file_count = usage.file_count
	path.disk_usage = usage.disk_usage
	return usage.disk_usage
}

pub fn (mut path DiskUsagePath) count_files() !i64 {
	if cached := path.file_count {
		return cached
	}
	usage := pathname_compute_disk_usage(path.path)!
	path.file_count = usage.file_count
	path.disk_usage = usage.disk_usage
	return usage.file_count
}

pub fn (mut path DiskUsagePath) abbreviated_value() !string {
	usage := pathname_compute_disk_usage(path.path)!
	path.file_count = usage.file_count
	path.disk_usage = usage.disk_usage
	return pathname_format_abv(usage)
}

pub fn pathname_disk_usage(path string) !i64 {
	return pathname_compute_disk_usage(path)!.disk_usage
}

pub fn pathname_file_count(path string) !i64 {
	return pathname_compute_disk_usage(path)!.file_count
}

pub fn pathname_abv(path string) !string {
	return pathname_format_abv(pathname_compute_disk_usage(path)!)
}

fn pathname_format_abv(usage PathDiskUsage) string {
	files := if usage.file_count > 1 {
		'${hb_utils.formatter_number_readable(usage.file_count)} files, '
	} else {
		''
	}
	return files + hb_utils.formatter_disk_usage_readable(f64(usage.disk_usage))
}

pub fn pathname_compute_disk_usage(path string) !PathDiskUsage {
	if os.is_link(path) && !os.exists(path) {
		return PathDiskUsage{
			file_count: 1
		}
	}
	resolved := if os.is_link(path) { pathname_disk_usage_resolved_path(path)! } else { path }
	if !os.is_dir(resolved) {
		information := os.lstat(resolved)!
		return PathDiskUsage{
			file_count: 1
			disk_usage: i64(information.size)
		}
	}
	mut result := PathDiskUsage{}
	mut scanned_files := map[string]bool{}
	pathname_scan_disk_usage(resolved, mut result, mut scanned_files)!
	return result
}

fn pathname_disk_usage_resolved_path(path string) !string {
	target := os.readlink(path)!
	return if os.is_abs_path(target) {
		target
	} else {
		os.norm_path(os.join_path(os.dir(path), target))
	}
}

fn pathname_scan_disk_usage(path string, mut result PathDiskUsage, mut scanned_files map[string]bool) ! {
	information := os.lstat(path)!
	if os.is_dir(path) && !os.is_link(path) {
		result.disk_usage += i64(information.size)
		for child in os.ls(path)! {
			pathname_scan_disk_usage(os.join_path(path, child), mut result, mut scanned_files)!
		}
		return
	}
	if os.base(path) != '.DS_Store' {
		result.file_count++
	}
	identifier := '${information.dev}:${information.inode}'
	if identifier !in scanned_files {
		result.disk_usage += i64(information.size)
		scanned_files[identifier] = true
	}
}
