module cask

import ruby
import os

// Translated from Homebrew/brew `cask/pkg.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum PkgPathKind {
	unknown
	file
	directory
	symlink
	character_device
	block_device
}

pub struct PkgBomEntry {
pub:
	path string
	kind PkgPathKind
}

pub struct PkgInfo {
pub:
	volume           string
	install_location string
	paths            []string
}

pub struct PkgCommandInvocation {
pub:
	executable   string
	args         []string
	input        string
	sudo         bool
	sudo_as_root bool
}

@[heap]
pub struct PkgCommand {
pub:
	matches                   map[string][]string
	infos                     map[string]PkgInfo
	boms                      map[string][]PkgBomEntry
	allow_filesystem_mutation bool
pub mut:
	invocations []PkgCommandInvocation
}

@[heap]
pub struct Pkg {
pub:
	package_id string
	command    &PkgCommand
}

pub fn new_pkg_command() &PkgCommand {
	return &PkgCommand{}
}

pub fn new_pkg(package_id string, command &PkgCommand) &Pkg {
	return &Pkg{
		package_id: package_id
		command: command
	}
}

fn pkg_plist_keys(xml string) []string {
	mut keys := []string{}
	mut remaining := xml
	for {
		start := remaining.index('<key>') or { break }
		after_start := remaining[start + 5..]
		end := after_start.index('</key>') or { break }
		keys << after_start[..end]
		remaining = after_start[end + 6..]
	}
	return keys
}

fn pkg_plist_string(xml string, key string) string {
	marker := '<key>${key}</key>'
	key_start := xml.index(marker) or { return '' }
	after_key := xml[key_start + marker.len..]
	string_start := after_key.index('<string>') or { return '' }
	after_start := after_key[string_start + 8..]
	string_end := after_start.index('</string>') or { return '' }
	return after_start[..string_end]
}

pub fn parse_pkg_info_plist(xml string) PkgInfo {
	return PkgInfo{
		volume: pkg_plist_string(xml, 'volume')
		install_location: pkg_plist_string(xml, 'install-location')
		paths: pkg_plist_keys(xml).filter(it !in ['volume', 'install-location', 'paths'])
	}
}

pub fn pkg_all_matching(regexp string, command &PkgCommand) []&Pkg {
	return (command.matches[regexp] or { [] }).map(new_pkg(it.trim_right('\n'), command))
}

fn (mut command PkgCommand) record(executable string, args []string, input string, sudo bool) {
	command.invocations << PkgCommandInvocation{
		executable: executable
		args: args.clone()
		input: input
		sudo: sudo
		sudo_as_root: sudo
	}
}

pub fn (pkg &Pkg) info() PkgInfo {
	return pkg.command.infos[pkg.package_id] or { PkgInfo{} }
}

pub fn (pkg &Pkg) root() string {
	info := pkg.info()
	if info.install_location == '' {
		return os.norm_path(info.volume)
	}
	return os.norm_path(os.join_path(info.volume, info.install_location))
}

pub fn (pkg &Pkg) pkgutil_bom_all() []PkgBomEntry {
	root := pkg.root()
	mut paths := []PkgBomEntry{}
	for entry in pkg.command.boms[pkg.package_id] or { [] } {
		path := if os.is_abs_path(entry.path) { entry.path } else { os.join_path(root, entry.path) }
		if !macos_undeletable(path) {
			paths << PkgBomEntry{
				path: path
				kind: entry.kind
			}
		}
	}
	return paths
}

pub fn pkg_special(path PkgBomEntry) bool {
	return path.kind in [.symlink, .character_device, .block_device] || (path.kind == .unknown && os.is_link(path.path))
}

fn pkg_file(path PkgBomEntry) bool {
	return path.kind == .file || (path.kind == .unknown && os.is_file(path.path))
}

fn pkg_directory(path PkgBomEntry) bool {
	return path.kind == .directory || (path.kind == .unknown && os.is_dir(path.path))
}

pub fn (pkg &Pkg) pkgutil_bom_specials() []string {
	return pkg.pkgutil_bom_all().filter(pkg_special(it)).map(it.path)
}

pub fn (pkg &Pkg) pkgutil_bom_files() []string {
	specials := pkg.pkgutil_bom_specials()
	return pkg.pkgutil_bom_all().filter(pkg_file(it) && it.path !in specials).map(it.path)
}

pub fn (pkg &Pkg) pkgutil_bom_dirs() []string {
	specials := pkg.pkgutil_bom_specials()
	return pkg.pkgutil_bom_all().filter(pkg_directory(it) && it.path !in specials).map(it.path)
}

pub fn pkg_deepest_path_first(paths []string) []string {
	mut sorted := paths.clone()
	sorted.sort_with_compare(fn (left &string, right &string) int {
		left_depth := left.split(os.path_separator).len
		right_depth := right.split(os.path_separator).len
		if left_depth == right_depth {
			return 0
		}
		return if left_depth > right_depth { -1 } else { 1 }
	})
	return sorted
}

fn remove_pkg_directory(path string) {
	if !os.is_dir(path) {
		return
	}
	for name in os.ls(path) or { return } {
		child := os.join_path(path, name)
		if name == '.DS_Store' || (os.is_link(child) && !os.exists(child)) {
			os.rm(child) or {}
		}
	}
	os.rmdir(path) or {}
}

pub fn (pkg &Pkg) rmdir(paths []string) {
	mut command := pkg.command
	command.record('/usr/bin/xargs', ['-0', '--', 'cask/utils/rmdir.sh'], paths.join('\0'), true)
	if command.allow_filesystem_mutation {
		for path in paths {
			remove_pkg_directory(path)
		}
	}
}

pub fn (pkg &Pkg) forget() {
	mut command := pkg.command
	command.record('/usr/sbin/pkgutil', ['--forget', pkg.package_id], '', true)
}

pub fn (pkg &Pkg) uninstall() {
	files := pkg.pkgutil_bom_files()
	if files.len > 0 {
		mut command := pkg.command
		command.record('/usr/bin/xargs', ['-0', '--', '/bin/rm', '--'], files.join('\0'), true)
		if command.allow_filesystem_mutation {
			for path in files {
				os.rm(path) or {}
			}
		}
	}
	specials := pkg.pkgutil_bom_specials()
	if specials.len > 0 {
		mut command := pkg.command
		command.record('/usr/bin/xargs', ['-0', '--', '/bin/rm', '--'], specials.join('\0'), true)
		if command.allow_filesystem_mutation {
			for path in specials {
				os.rm(path) or {}
			}
		}
	}
	directories := pkg.pkgutil_bom_dirs()
	if directories.len > 0 {
		pkg.rmdir(pkg_deepest_path_first(directories))
	}
	root := pkg.root()
	if !macos_undeletable(root) {
		pkg.rmdir([root])
	}
	pkg.forget()
}

fn pkg_info_value(info PkgInfo) ruby.Value {
	return ruby.map_value({
		'volume':           ruby.string_value(info.volume)
		'install-location': ruby.string_value(info.install_location)
		'paths':            ruby.string_array_value(info.paths)
	})
}

fn pkg_command_value(command &PkgCommand) ruby.Value {
	return ruby.structured_value('SystemCommand', '', {
		'pkg_command_address': u64(voidptr(command)).str()
	})
}

fn pkg_command_from_value(value ruby.Value) &PkgCommand {
	address := value.attributes['pkg_command_address'] or { panic('invalid Pkg command') }
	return unsafe { &PkgCommand(voidptr(address.u64())) }
}

pub fn pkg_command_boundary(command &PkgCommand) ruby.Value {
	return pkg_command_value(command)
}

fn pkg_value(pkg &Pkg) ruby.Value {
	return ruby.structured_value('Cask::Pkg', pkg.package_id, {
		'pkg_address': u64(voidptr(pkg)).str()
	})
}

fn pkg_from_value(value ruby.Value) &Pkg {
	address := value.attributes['pkg_address'] or { panic('invalid Cask::Pkg') }
	return unsafe { &Pkg(voidptr(address.u64())) }
}

// Ruby method `self.all_matching(regexp, command)` at line 13.
pub fn ruby_pkg_l13_d1_self_all_matching(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([])
	}
	command := pkg_command_from_value(args[1])
	return ruby.array_value(pkg_all_matching(args[0].as_string(), command).map(pkg_value(it)))
}

// Ruby attr_reader `attr_reader :package_id` at line 20.
pub fn ruby_pkg_l20_d2_package_id(args ...ruby.Value) ruby.Value {
	return ruby.string_value(pkg_from_value(args[0]).package_id)
}

// Ruby method `initialize(package_id, command = SystemCommand)` at line 23.
pub fn ruby_pkg_l23_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'package_id and command are required')
	}
	return pkg_value(new_pkg(args[0].as_string(), pkg_command_from_value(args[1])))
}

// Ruby method `uninstall` at line 29.
pub fn ruby_pkg_l29_d4_uninstall(args ...ruby.Value) ruby.Value {
	pkg_from_value(args[0]).uninstall()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `forget` at line 63.
pub fn ruby_pkg_l63_d5_forget(args ...ruby.Value) ruby.Value {
	pkg_from_value(args[0]).forget()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `pkgutil_bom_files` at line 74.
pub fn ruby_pkg_l74_d6_pkgutil_bom_files(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(pkg_from_value(args[0]).pkgutil_bom_files())
}

// Ruby method `pkgutil_bom_specials` at line 80.
pub fn ruby_pkg_l80_d7_pkgutil_bom_specials(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(pkg_from_value(args[0]).pkgutil_bom_specials())
}

// Ruby method `pkgutil_bom_dirs` at line 85.
pub fn ruby_pkg_l85_d8_pkgutil_bom_dirs(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(pkg_from_value(args[0]).pkgutil_bom_dirs())
}

// Ruby method `pkgutil_bom_all` at line 91.
pub fn ruby_pkg_l91_d9_pkgutil_bom_all(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(pkg_from_value(args[0]).pkgutil_bom_all().map(it.path))
}

// Ruby method `root` at line 103.
pub fn ruby_pkg_l103_d10_root(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', pkg_from_value(args[0]).root())
}

// Ruby method `info` at line 108.
pub fn ruby_pkg_l108_d11_info(args ...ruby.Value) ruby.Value {
	return pkg_info_value(pkg_from_value(args[0]).info())
}

// Ruby method `special?(path)` at line 115.
pub fn ruby_pkg_l115_d12_special(args ...ruby.Value) ruby.Value {
	kind := if args.len > 2 {
		match args[2].as_string() {
			'symlink' { PkgPathKind.symlink }
			'character_device' { PkgPathKind.character_device }
			'block_device' { PkgPathKind.block_device }
			else { PkgPathKind.unknown }
		}
	} else {
		PkgPathKind.unknown
	}
	return ruby.bool_value(pkg_special(PkgBomEntry{
		path: args[1].as_string()
		kind: kind
	}))
}

// Ruby method `rmdir(path)` at line 125.
pub fn ruby_pkg_l125_d13_rmdir(args ...ruby.Value) ruby.Value {
	paths := if args[1].type_name == 'Array' {
		args[1].as_string_array() or { [] }
	} else {
		[args[1].as_string()]
	}
	pkg_from_value(args[0]).rmdir(paths)
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `deepest_path_first(paths)` at line 136.
pub fn ruby_pkg_l136_d14_deepest_path_first(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(pkg_deepest_path_first(args[1].as_string_array() or { [] }))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/macos"
// 5: require "utils/output"
// 6:
// 7: module Cask
// 8:   # Helper class for uninstalling `.pkg` installers.
// 9:   class Pkg
// 10:     include ::Utils::Output::Mixin
// 11:
// 12:     sig { params(regexp: String, command: T.class_of(SystemCommand)).returns(T::Array[Pkg]) }
// 13:     def self.all_matching(regexp, command)
// 14:       command.run("/usr/sbin/pkgutil", args: ["--pkgs=#{regexp}"]).stdout.split("\n").map do |package_id|
// 15:         new(package_id.chomp, command)
// 16:       end
// 17:     end
// 18:
// 19:     sig { returns(String) }
// 20:     attr_reader :package_id
// 21:
// 22:     sig { params(package_id: String, command: T.class_of(SystemCommand)).void }
// 23:     def initialize(package_id, command = SystemCommand)
// 24:       @package_id = package_id
// 25:       @command = command
// 26:     end
// 27:
// 28:     sig { void }
// 29:     def uninstall
// 30:       unless pkgutil_bom_files.empty?
// 31:         odebug "Deleting pkg files"
// 32:         @command.run!(
// 33:           "/usr/bin/xargs",
// 34:           args:         ["-0", "--", "/bin/rm", "--"],
// 35:           input:        pkgutil_bom_files.join("\0"),
// 36:           sudo:         true,
// 37:           sudo_as_root: true,
// 38:         )
// 39:       end
// 40:
// 41:       unless pkgutil_bom_specials.empty?
// 42:         odebug "Deleting pkg symlinks and special files"
// 43:         @command.run!(
// 44:           "/usr/bin/xargs",
// 45:           args:         ["-0", "--", "/bin/rm", "--"],
// 46:           input:        pkgutil_bom_specials.join("\0"),
// 47:           sudo:         true,
// 48:           sudo_as_root: true,
// 49:         )
// 50:       end
// 51:
// 52:       unless pkgutil_bom_dirs.empty?
// 53:         odebug "Deleting pkg directories"
// 54:         rmdir(deepest_path_first(pkgutil_bom_dirs))
// 55:       end
// 56:
// 57:       rmdir(root) unless MacOS.undeletable?(root)
// 58:
// 59:       forget
// 60:     end
// 61:
// 62:     sig { void }
// 63:     def forget
// 64:       odebug "Unregistering pkg receipt (aka forgetting)"
// 65:       @command.run!(
// 66:         "/usr/sbin/pkgutil",
// 67:         args:         ["--forget", package_id],
// 68:         sudo:         true,
// 69:         sudo_as_root: true,
// 70:       )
// 71:     end
// 72:
// 73:     sig { returns(T::Array[Pathname]) }
// 74:     def pkgutil_bom_files
// 75:       @pkgutil_bom_files ||= T.let(pkgutil_bom_all.select(&:file?) - pkgutil_bom_specials,
// 76:                                    T.nilable(T::Array[Pathname]))
// 77:     end
// 78:
// 79:     sig { returns(T::Array[Pathname]) }
// 80:     def pkgutil_bom_specials
// 81:       @pkgutil_bom_specials ||= T.let(pkgutil_bom_all.select { special?(it) }, T.nilable(T::Array[Pathname]))
// 82:     end
// 83:
// 84:     sig { returns(T::Array[Pathname]) }
// 85:     def pkgutil_bom_dirs
// 86:       @pkgutil_bom_dirs ||= T.let(pkgutil_bom_all.select(&:directory?) - pkgutil_bom_specials,
// 87:                                   T.nilable(T::Array[Pathname]))
// 88:     end
// 89:
// 90:     sig { returns(T::Array[Pathname]) }
// 91:     def pkgutil_bom_all
// 92:       @pkgutil_bom_all ||= T.let(
// 93:         @command.run!("/usr/sbin/pkgutil", args: ["--files", package_id])
// 94:                 .stdout
// 95:                 .split("\n")
// 96:                 .map { |path| root.join(path) }
// 97:                 .reject { |path| MacOS.undeletable?(path) },
// 98:         T.nilable(T::Array[Pathname]),
// 99:       )
// 100:     end
// 101:
// 102:     sig { returns(Pathname) }
// 103:     def root
// 104:       @root ||= T.let(Pathname.new(info.fetch("volume")).join(info.fetch("install-location")), T.nilable(Pathname))
// 105:     end
// 106:
// 107:     sig { returns(T.untyped) }
// 108:     def info
// 109:       @info ||= T.let(@command.run!("/usr/sbin/pkgutil", args: ["--pkg-info-plist", package_id]).plist, T.untyped)
// 110:     end
// 111:
// 112:     private
// 113:
// 114:     sig { params(path: Pathname).returns(T::Boolean) }
// 115:     def special?(path)
// 116:       path.symlink? || path.chardev? || path.blockdev?
// 117:     end
// 118:
// 119:     # Helper script to delete empty directories after deleting `.DS_Store` files and broken symlinks.
// 120:     # Needed in order to execute all file operations with `sudo`.
// 121:     RMDIR_SH = T.let((HOMEBREW_LIBRARY_PATH/"cask/utils/rmdir.sh").freeze, Pathname)
// 122:     private_constant :RMDIR_SH
// 123:
// 124:     sig { params(path: T.any(Pathname, T::Array[Pathname])).void }
// 125:     def rmdir(path)
// 126:       @command.run!(
// 127:         "/usr/bin/xargs",
// 128:         args:         ["-0", "--", RMDIR_SH.to_s],
// 129:         input:        Array(path).join("\0"),
// 130:         sudo:         true,
// 131:         sudo_as_root: true,
// 132:       )
// 133:     end
// 134:
// 135:     sig { params(paths: T::Array[Pathname]).returns(T::Array[Pathname]) }
// 136:     def deepest_path_first(paths)
// 137:       paths.sort_by { |path| -path.to_s.split(File::SEPARATOR).count }
// 138:     end
// 139:   end
// 140: end
