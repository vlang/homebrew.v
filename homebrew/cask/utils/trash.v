module utils

import brew_runtime
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

pub fn trash_result_value(result TrashResult) brew_runtime.Value {
	return brew_runtime.array_value([
		brew_runtime.string_array_value(result.trashed),
		brew_runtime.string_array_value(result.untrashable),
	])
}

fn trash_boundary_paths(args []brew_runtime.Value) []string {
	if args.len == 0 {
		return []string{}
	}
	if args[0].type_name == 'Array' {
		return args[0].as_array() or { []brew_runtime.Value{} }.map(it.as_string())
	}
	return args.filter(it.type_name in ['String', 'Pathname']).map(it.as_string())
}

fn trash_boundary_date(args []brew_runtime.Value) string {
	for arg in args {
		if arg.type_name == 'Hash' && 'deletion_date' in arg.map_data {
			return arg.map_data['deletion_date'].as_string()
		}
	}
	return time.now().format_ss()
}

fn trash_boundary_xdg(args []brew_runtime.Value) string {
	for arg in args {
		if arg.type_name == 'Hash' && 'xdg_data_home' in arg.map_data {
			return arg.map_data['xdg_data_home'].as_string()
		}
	}
	return os.getenv('XDG_DATA_HOME')
}

// Translated from Homebrew/brew `cask/utils/trash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.trash(*paths, command: nil)` at line 18.
pub fn ruby_trash_l18_d1_self_trash(args ...brew_runtime.Value) brew_runtime.Value {
	return trash_result_value(freedesktop_trash(trash_boundary_paths(args), trash_boundary_xdg(args), os.home_dir(), trash_boundary_date(args)))
}

// Ruby method `self.freedesktop_trash(*paths)` at line 23.
pub fn ruby_trash_l23_d2_self_freedesktop_trash(args ...brew_runtime.Value) brew_runtime.Value {
	return trash_result_value(freedesktop_trash(trash_boundary_paths(args), trash_boundary_xdg(args), os.home_dir(), trash_boundary_date(args)))
}

// Ruby method `self.home_trash_path` at line 43.
pub fn ruby_trash_l43_d3_self_home_trash_path(args ...brew_runtime.Value) brew_runtime.Value {
	xdg := if args.len > 0 { args[0].as_string() } else { os.getenv('XDG_DATA_HOME') }
	home := if args.len > 1 { args[1].as_string() } else { os.home_dir() }
	return brew_runtime.string_value(home_trash_path(xdg, home))
}

// Ruby method `self.trash_path(path, files_path:, info_path:)` at line 49.
pub fn ruby_trash_l49_d4_self_trash_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('trash_path requires path, files_path, and info_path') }
	date := if args.len > 3 { args[3].as_string() } else { time.now().format_ss() }
	move := freedesktop_trash_path(args[0].as_string(), args[1].as_string(), args[2].as_string(), date) or { panic(err) }
	return brew_runtime.map_value({
		'source':    brew_runtime.string_value(move.source)
		'target':    brew_runtime.string_value(move.target)
		'info_path': brew_runtime.string_value(move.info_path)
		'info':      brew_runtime.string_value(move.info)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/utils"
// 5: require "fileutils"
// 6: require "system_command"
// 7: require "uri"
// 8:
// 9: module Cask
// 10:   module Utils
// 11:     module Trash
// 12:       extend SystemCommand::Mixin
// 13:
// 14:       sig {
// 15:         params(paths: Pathname, command: T.nilable(T.class_of(SystemCommand)))
// 16:           .returns([T::Array[String], T::Array[String]])
// 17:       }
// 18:       def self.trash(*paths, command: nil)
// 19:         freedesktop_trash(*paths)
// 20:       end
// 21:
// 22:       sig { params(paths: Pathname).returns([T::Array[String], T::Array[String]]) }
// 23:       def self.freedesktop_trash(*paths)
// 24:         return [[], []] if paths.empty?
// 25:
// 26:         files_path = home_trash_path/"files"
// 27:         info_path = home_trash_path/"info"
// 28:
// 29:         files_path.mkpath
// 30:         info_path.mkpath
// 31:
// 32:         trashed, untrashable = paths.partition do |path|
// 33:           trash_path(path, files_path:, info_path:)
// 34:           true
// 35:         rescue
// 36:           false
// 37:         end
// 38:
// 39:         [trashed.map(&:to_s), untrashable.map(&:to_s)]
// 40:       end
// 41:
// 42:       sig { returns(Pathname) }
// 43:       def self.home_trash_path
// 44:         Pathname.new(ENV["XDG_DATA_HOME"].presence || "#{Dir.home}/.local/share")/"Trash"
// 45:       end
// 46:       private_class_method :home_trash_path
// 47:
// 48:       sig { params(path: Pathname, files_path: Pathname, info_path: Pathname).void }
// 49:       def self.trash_path(path, files_path:, info_path:)
// 50:         basename = path.basename.to_s
// 51:         deletion_date = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
// 52:         suffix = 0
// 53:
// 54:         Kernel.loop do
// 55:           candidate = suffix.zero? ? basename : "#{basename}.#{suffix}"
// 56:           target_path = files_path/candidate
// 57:           target_info_path = info_path/"#{candidate}.trashinfo"
// 58:
// 59:           if target_path.exist? || target_path.symlink?
// 60:             suffix += 1
// 61:             next
// 62:           end
// 63:
// 64:           begin
// 65:             File.open(target_info_path, File::WRONLY | File::CREAT | File::EXCL, 0600) do |file|
// 66:               file.write <<~EOS
// 67:                 [Trash Info]
// 68:                 Path=#{URI::DEFAULT_PARSER.escape(path.to_s)}
// 69:                 DeletionDate=#{deletion_date}
// 70:               EOS
// 71:             end
// 72:           rescue Errno::EEXIST
// 73:             suffix += 1
// 74:             next
// 75:           end
// 76:
// 77:           begin
// 78:             FileUtils.mv(path, target_path)
// 79:           rescue
// 80:             target_info_path.delete if target_info_path.exist?
// 81:             Kernel.raise
// 82:           end
// 83:
// 84:           return
// 85:         end
// 86:       end
// 87:       private_class_method :trash_path
// 88:     end
// 89:   end
// 90: end
// 91:
// 92: require "extend/os/cask/utils/trash"
