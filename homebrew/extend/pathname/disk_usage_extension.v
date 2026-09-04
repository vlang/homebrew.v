module pathname

import ruby
import homebrew.utils as hb_utils
import os

// Translated from Homebrew/brew `extend/pathname/disk_usage_extension.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `disk_usage` at line 12.
pub fn ruby_disk_usage_extension_l12_d1_disk_usage(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('DiskUsageExtension#disk_usage requires a path')
	}
	return ruby.int_value(pathname_disk_usage(args[0].as_string()) or { panic(err) })
}

// Ruby method `file_count` at line 21.
pub fn ruby_disk_usage_extension_l21_d2_file_count(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('DiskUsageExtension#file_count requires a path')
	}
	return ruby.int_value(pathname_file_count(args[0].as_string()) or { panic(err) })
}

// Ruby method `abv` at line 30.
pub fn ruby_disk_usage_extension_l30_d3_abv(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('DiskUsageExtension#abv requires a path')
	}
	return ruby.string_value(pathname_abv(args[0].as_string()) or { panic(err) })
}

// Ruby method `compute_disk_usage` at line 41.
pub fn ruby_disk_usage_extension_l41_d4_compute_disk_usage(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('DiskUsageExtension#compute_disk_usage requires a path')
	}
	usage := pathname_compute_disk_usage(args[0].as_string()) or { panic(err) }
	return ruby.array_value([
		ruby.int_value(usage.file_count),
		ruby.int_value(usage.disk_usage),
	])
}

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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/formatter"
// 5:
// 6: module DiskUsageExtension
// 7:   extend T::Helpers
// 8:
// 9:   requires_ancestor { Pathname }
// 10:
// 11:   sig { returns(Integer) }
// 12:   def disk_usage
// 13:     @disk_usage ||= T.let(nil, T.nilable(Integer))
// 14:     return @disk_usage unless @disk_usage.nil?
// 15:
// 16:     @file_count, @disk_usage = compute_disk_usage
// 17:     @disk_usage
// 18:   end
// 19:
// 20:   sig { returns(Integer) }
// 21:   def file_count
// 22:     @file_count ||= T.let(nil, T.nilable(Integer))
// 23:     return @file_count unless @file_count.nil?
// 24:
// 25:     @file_count, @disk_usage = compute_disk_usage
// 26:     @file_count
// 27:   end
// 28:
// 29:   sig { returns(String) }
// 30:   def abv
// 31:     out = +""
// 32:     @file_count, @disk_usage = compute_disk_usage
// 33:     out << "#{Formatter.number_readable(@file_count)} files, " if @file_count > 1
// 34:     out << Formatter.disk_usage_readable(@disk_usage).to_s
// 35:     out.freeze
// 36:   end
// 37:
// 38:   private
// 39:
// 40:   sig { returns([Integer, Integer]) }
// 41:   def compute_disk_usage
// 42:     if symlink? && !exist?
// 43:       file_count = 1
// 44:       disk_usage = 0
// 45:       return [file_count, disk_usage]
// 46:     end
// 47:
// 48:     path = if symlink?
// 49:       resolved_path
// 50:     else
// 51:       self
// 52:     end
// 53:
// 54:     if path.directory?
// 55:       scanned_files = Set.new
// 56:       file_count = 0
// 57:       disk_usage = 0
// 58:       path.find do |f|
// 59:         if f.directory?
// 60:           disk_usage += f.lstat.size
// 61:         else
// 62:           file_count += 1 if f.basename.to_s != ".DS_Store"
// 63:           # use Pathname#lstat instead of Pathname#stat to get info of symlink itself.
// 64:           stat = f.lstat
// 65:           file_id = [stat.dev, stat.ino]
// 66:           # count hardlinks only once.
// 67:           unless scanned_files.include?(file_id)
// 68:             disk_usage += stat.size
// 69:             scanned_files.add(file_id)
// 70:           end
// 71:         end
// 72:       end
// 73:     else
// 74:       file_count = 1
// 75:       disk_usage = path.lstat.size
// 76:     end
// 77:
// 78:     [file_count, disk_usage]
// 79:   end
// 80: end
