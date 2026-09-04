module cask

import ruby
import os

// Translated from Homebrew/brew `cask/pkg.rb`.
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
	command.record('/usr/bin/xargs', ['-0', '--', 'cask/utils/rmdir.sh'], paths.join('\x00'), true)
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
		command.record('/usr/bin/xargs', ['-0', '--', '/bin/rm', '--'], files.join('\x00'), true)
		if command.allow_filesystem_mutation {
			for path in files {
				os.rm(path) or {}
			}
		}
	}
	specials := pkg.pkgutil_bom_specials()
	if specials.len > 0 {
		mut command := pkg.command
		command.record('/usr/bin/xargs', ['-0', '--', '/bin/rm', '--'], specials.join('\x00'), true)
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
