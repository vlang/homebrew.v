module pathname

import brew_runtime

// Translated from Homebrew/brew `extend/pathname/disk_usage_extension.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `disk_usage` at line 12.
pub fn ruby_disk_usage_extension_l12_d1_disk_usage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('disk_usage', ...args)
}

// Ruby method `file_count` at line 21.
pub fn ruby_disk_usage_extension_l21_d2_file_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_count', ...args)
}

// Ruby method `abv` at line 30.
pub fn ruby_disk_usage_extension_l30_d3_abv(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('abv', ...args)
}

// Ruby method `compute_disk_usage` at line 41.
pub fn ruby_disk_usage_extension_l41_d4_compute_disk_usage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_disk_usage', ...args)
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
