module extend

import ruby
import crypto.sha256
import os

// Translated from Homebrew/brew `extend/pathname.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.wrap(path) = raise(NotImplementedError)` at line 23.
pub fn ruby_pathname_l23_d1_self_wrap(path string) !BinaryPath {
	return binary_pathname_wrap(path)
}

// Ruby method `self.activate_extensions!` at line 36.
pub fn ruby_pathname_l36_d2_self_activate_extensions() {
	activate_pathname_extensions()
}

// Ruby method `install(*sources)` at line 49.
pub fn ruby_pathname_l49_d3_install(destination string, sources []PathInstallSource) ! {
	pathname_install(destination, sources)!
}

// Ruby method `install_symlink(*sources)` at line 82.
pub fn ruby_pathname_l82_d4_install_symlink(destination string, sources []PathInstallSource) ! {
	pathname_install_symlink(destination, sources)!
}

// Ruby method `append_lines(content, **open_args)` at line 99.
pub fn ruby_pathname_l99_d5_append_lines(path string, content string) ! {
	pathname_append_lines(path, content)!
}

// Ruby method `atomic_write(content)` at line 111.
pub fn ruby_pathname_l111_d6_atomic_write(path string, content string) ! {
	pathname_atomic_write(path, content)!
}

// Ruby method `cp_path_sub(pattern, replacement, &_block)` at line 146.
pub fn ruby_pathname_l146_d7_cp_path_sub(path string, pattern string, replacement string) !string {
	return pathname_cp_path_sub(path, pattern, replacement)
}

// Ruby method `extname` at line 168.
pub fn ruby_pathname_l168_d8_extname(path string) string {
	return pathname_extname(path)
}

// Ruby method `stem` at line 187.
pub fn ruby_pathname_l187_d9_stem(path string) string {
	return pathname_stem(path)
}

// Ruby method `rmdir_if_possible` at line 195.
pub fn ruby_pathname_l195_d10_rmdir_if_possible(path string) bool {
	return pathname_rmdir_if_possible(path)
}

// Ruby method `version` at line 210.
pub fn ruby_pathname_l210_d11_version(path string, parser PathVersionParser) !string {
	return pathname_version(path, parser)
}

// Ruby method `text_executable?` at line 216.
pub fn ruby_pathname_l216_d12_text_executable(path string) !bool {
	return pathname_text_executable(path)
}

// Ruby method `sha256` at line 221.
pub fn ruby_pathname_l221_d13_sha256(path string) !string {
	return pathname_sha256(path)
}

// Ruby method `verify_checksum(expected)` at line 227.
pub fn ruby_pathname_l227_d14_verify_checksum(path string, expected ?string) ! {
	pathname_verify_checksum(path, expected)!
}

// Ruby alias `alias to_str to_s` at line 234.
pub fn ruby_pathname_l234_d15_to_str(path string) string {
	return path
}

// Ruby method `cd(&_block)` at line 244.
pub fn ruby_pathname_l244_d16_cd(path string, action PathAction) ! {
	pathname_cd(path, action)!
}

// Ruby method `subdirs` at line 252.
pub fn ruby_pathname_l252_d17_subdirs(path string) ![]string {
	return pathname_subdirs(path)
}

// Ruby method `resolved_path` at line 257.
pub fn ruby_pathname_l257_d18_resolved_path(path string) !string {
	return pathname_resolved_path(path)
}

// Ruby method `resolved_path_exists?` at line 262.
pub fn ruby_pathname_l262_d19_resolved_path_exists(path string) !bool {
	return pathname_resolved_path_exists(path)
}

// Ruby method `make_relative_symlink(src)` at line 272.
pub fn ruby_pathname_l272_d20_make_relative_symlink(path string, source string) ! {
	pathname_make_relative_symlink(path, source)!
}

// Ruby method `ensure_writable(&_block)` at line 278.
pub fn ruby_pathname_l278_d21_ensure_writable(path string, action PathAction) ! {
	pathname_ensure_writable(path, action)!
}

// Ruby method `install_info` at line 290.
pub fn ruby_pathname_l290_d22_install_info(path string, executable string) !ruby.CommandResult {
	return pathname_install_info(path, executable, false)
}

// Ruby method `uninstall_info` at line 295.
pub fn ruby_pathname_l295_d23_uninstall_info(path string, executable string) !ruby.CommandResult {
	return pathname_install_info(path, executable, true)
}

// Ruby method `write_exec_script(*targets)` at line 303.
pub fn ruby_pathname_l303_d24_write_exec_script(directory string, targets []string) ! {
	pathname_write_exec_script(directory, targets)!
}

// Ruby method `write_env_script(target, args_or_env, env = T.unsafe(nil))` at line 333.
pub fn ruby_pathname_l333_d25_write_env_script(path string, target string, arguments []string, environment []EnvironmentAssignment) ! {
	pathname_write_env_script(path, target, arguments, environment)!
}

// Ruby method `env_script_all_files(dst, env)` at line 360.
pub fn ruby_pathname_l360_d26_env_script_all_files(directory string, destination string, environment []EnvironmentAssignment) ! {
	pathname_env_script_all_files(directory, destination, environment)!
}

// Ruby method `write_jar_script(target_jar, script_name, java_opts = "", java_version: nil)` at line 384.
pub fn ruby_pathname_l384_d27_write_jar_script(directory string, target_jar string, script_name string, java_options string, java_version string, java_home JavaHomeResolver) !int {
	return pathname_write_jar_script(directory, target_jar, script_name, java_options, java_version, java_home)
}

// Ruby method `install_metafiles(from = Pathname.pwd)` at line 394.
pub fn ruby_pathname_l394_d28_install_metafiles(destination string, source string, predicate MetafilePredicate) ! {
	pathname_install_metafiles(destination, source, predicate)!
}

// Ruby method `ds_store?` at line 414.
pub fn ruby_pathname_l414_d29_ds_store(path string) bool {
	return pathname_ds_store(path)
}

// Ruby method `binary_executable?` at line 419.
pub fn ruby_pathname_l419_d30_binary_executable(path string) bool {
	_ = path
	return false
}

// Ruby method `mach_o_bundle?` at line 424.
pub fn ruby_pathname_l424_d31_mach_o_bundle(path string) bool {
	_ = path
	return false
}

// Ruby method `dylib?` at line 429.
pub fn ruby_pathname_l429_d32_dylib(path string) bool {
	_ = path
	return false
}

// Ruby method `arch_compatible?(_wanted_arch)` at line 434.
pub fn ruby_pathname_l434_d33_arch_compatible(path string, wanted_arch string) bool {
	_ = path
	_ = wanted_arch
	return true
}

// Ruby method `rpaths` at line 439.
pub fn ruby_pathname_l439_d34_rpaths(path string) []string {
	_ = path
	return []
}

// Ruby method `magic_number` at line 444.
pub fn ruby_pathname_l444_d35_magic_number(path string) !string {
	return pathname_magic_number(path)
}

// Ruby method `file_type` at line 456.
pub fn ruby_pathname_l456_d36_file_type(path string) !string {
	return pathname_file_type(path)
}

// Ruby method `zipinfo` at line 463.
pub fn ruby_pathname_l463_d37_zipinfo(path string) ![]string {
	return pathname_zipinfo(path)
}

// Ruby method `install_p(src, new_basename, &_block)` at line 479.
pub fn ruby_pathname_l479_d38_install_p(destination string, source string, new_basename string) ! {
	pathname_install_p(destination, source, new_basename)!
}

// Ruby method `install_symlink_p(src, new_basename)` at line 502.
pub fn ruby_pathname_l502_d39_install_symlink_p(destination string, source string, new_basename string) ! {
	pathname_install_symlink_p(destination, source, new_basename)!
}

// Ruby method `which_install_info` at line 511.
pub fn ruby_pathname_l511_d40_which_install_info(texinfo_candidate string) ?string {
	return pathname_which_install_info(texinfo_candidate)
}

pub enum BinaryPathKind {
	unknown
	mach_o
	elf
}

pub struct BinaryPath {
pub:
	path string
	kind BinaryPathKind
}

pub struct PathInstallSource {
pub:
	path         string
	new_basename string
}

pub struct EnvironmentAssignment {
pub:
	key   string
	value string
}

pub type BinaryPathResolver = fn(string) !BinaryPath

pub type PathTransform = fn(string, string) !string

pub type PathAction = fn(string) !

pub type PathVersionParser = fn(string) !string

pub type JavaHomeResolver = fn(string) !string

pub type MetafilePredicate = fn(string) bool

pub fn binary_pathname_wrap(path string) !BinaryPath {
	return error('BinaryPathname.wrap is not implemented for ${path}')
}

pub fn binary_pathname_wrap_with(path string, resolver BinaryPathResolver) !BinaryPath {
	return resolver(path)
}

// V extensions are statically linked, so activation is intentionally a no-op.
pub fn activate_pathname_extensions() {}

pub fn pathname_install(destination string, sources []PathInstallSource) ! {
	for source in sources {
		basename := if source.new_basename != '' {
			source.new_basename
		} else {
			os.base(source.path)
		}
		pathname_install_p(destination, source.path, basename)!
	}
}

pub fn pathname_install_symlink(destination string, sources []PathInstallSource) ! {
	for source in sources {
		basename := if source.new_basename != '' {
			source.new_basename
		} else {
			os.base(source.path)
		}
		pathname_install_symlink_p(destination, source.path, basename)!
	}
}

pub fn pathname_append_lines(path string, content string) ! {
	if !os.exists(path) {
		return error("Cannot append file that doesn't exist: ${path}")
	}
	mut file := os.open_append(path)!
	defer {
		file.close()
	}
	file.write_string(if content.ends_with('\n') { content } else { '${content}\n' })!
}

pub fn pathname_atomic_write(path string, content string) ! {
	old_mode := if os.exists(path) { ?int(int(os.stat(path)!.get_mode().bitmask())) } else { none }
	ruby.atomic_write_file(path, content)!
	if mode := old_mode {
		os.chmod(path, mode) or {}
	}
}

pub fn pathname_cp_path_sub(path string, pattern string, replacement string) !string {
	return pathname_cp_path_sub_with(path, pattern, replacement, passthrough_path_transform)
}

pub fn pathname_cp_path_sub_with(path string, pattern string, replacement string, transform PathTransform) !string {
	if !os.exists(path) && !os.is_link(path) {
		return error('${path} does not exist')
	}
	mut destination := replace_first(path, pattern, replacement)
	if path == destination {
		return error('${path} is the same file as ${destination}')
	}
	if os.is_dir(path) {
		os.mkdir_all(destination)!
		return destination
	}
	os.mkdir_all(os.dir(destination))!
	destination = transform(path, destination)!
	os.cp(path, destination)!
	return destination
}

fn passthrough_path_transform(source string, destination string) !string {
	_ = source
	return destination
}

fn replace_first(value string, pattern string, replacement string) string {
	if pattern == '' {
		return replacement + value
	}
	index := value.index(pattern) or { return value }
	return value[..index] + replacement + value[index + pattern.len..]
}

pub fn pathname_extname(path string) string {
	basename := os.base(path)
	if bottle_extension := pathname_bottle_extension(basename) {
		return bottle_extension
	}
	lower := basename.to_lower()
	for archive in ['tar', 'cpio', 'pax'] {
		for compression in ['gz', 'bz2', 'lz', 'xz', 'zst', 'z'] {
			extension := '.${archive}.${compression}'
			if lower.ends_with(extension) {
				return basename[basename.len - extension.len..]
			}
		}
	}
	if pathname_has_terminal_version_number(basename) && !lower.ends_with('.7z') {
		return ''
	}
	index := basename.last_index('.') or { return '' }
	if index <= 0 {
		return ''
	}
	return basename[index..]
}

fn pathname_bottle_extension(basename string) ?string {
	lower := basename.to_lower()
	if !lower.ends_with('.tar.gz') {
		return none
	}
	bottle_index := lower.last_index('.bottle.') or { return none }
	prefix := lower[..bottle_index]
	tag_index := prefix.last_index('.') or { return none }
	tag := prefix[tag_index + 1..]
	if tag == '' || !tag.bytes().all(it.is_alnum() || it == `_`) {
		return none
	}
	after_bottle := lower[bottle_index + '.bottle.'.len..]
	rebuild := if after_bottle == 'tar.gz' {
		''
	} else if after_bottle.ends_with('.tar.gz') {
		after_bottle[..after_bottle.len - '.tar.gz'.len]
	} else {
		return none
	}
	if rebuild != '' && !rebuild.bytes().all(it.is_digit()) {
		return none
	}
	return basename[tag_index..]
}

fn pathname_has_terminal_version_number(basename string) bool {
	last_dot := basename.last_index('.') or { return false }
	if last_dot == 0 || last_dot + 1 >= basename.len || !basename[last_dot - 1].is_digit() || !basename[last_dot + 1].is_digit() {
		return false
	}
	return !basename[last_dot + 1..].contains('.')
}

pub fn pathname_stem(path string) string {
	basename := os.base(path)
	extension := pathname_extname(path)
	return if extension == '' { basename } else { basename[..basename.len - extension.len] }
}

pub fn pathname_rmdir_if_possible(path string) bool {
	os.rmdir(path) or {
		ds_store := os.join_path(path, '.DS_Store')
		entries := os.ls(path) or { return false }
		if os.exists(ds_store) && entries.len == 1 {
			os.rm(ds_store) or { return false }
			os.rmdir(path) or { return false }
			return true
		}
		return false
	}
	return true
}

pub fn pathname_version(path string, parser PathVersionParser) !string {
	return parser(os.base(path))
}

pub fn pathname_text_executable(path string) !bool {
	mut file := os.open(path)!
	defer {
		file.close()
	}
	mut buffer := []u8{len: 1024}
	read := file.read(mut buffer) or { return err }
	text := buffer[..read].bytestr()
	if !text.starts_with('#!') {
		return false
	}
	return text[2..].trim_left(' \t\r\n') != ''
}

pub fn pathname_sha256(path string) !string {
	return sha256.sum256(os.read_bytes(path)!).hex()
}

pub fn pathname_verify_checksum(path string, expected ?string) ! {
	wanted := expected or { return error('ChecksumMissingError') }
	if wanted.trim_space() == '' {
		return error('ChecksumMissingError')
	}
	actual := pathname_sha256(path)!.to_lower()
	if actual != wanted.to_lower() {
		return error('ChecksumMismatchError: ${path}: expected ${wanted.to_lower()}, actual ${actual}')
	}
}

pub fn pathname_cd(path string, action PathAction) ! {
	original := os.getwd()
	os.chdir(path)!
	defer {
		os.chdir(original) or {}
	}
	action(path)!
}

pub fn pathname_subdirs(path string) ![]string {
	mut directories := []string{}
	for child in os.ls(path)! {
		candidate := os.join_path(path, child)
		if os.is_dir(candidate) {
			directories << candidate
		}
	}
	return directories
}

pub fn pathname_resolved_path(path string) !string {
	if !os.is_link(path) {
		return path
	}
	target := os.readlink(path)!
	return if os.is_abs_path(target) {
		target
	} else {
		os.norm_path(os.join_path(os.dir(path), target))
	}
}

pub fn pathname_resolved_path_exists(path string) !bool {
	target := os.readlink(path)!
	if target.contains('\0') {
		return false
	}
	resolved := if os.is_abs_path(target) { target } else { os.join_path(os.dir(path), target) }
	return os.exists(resolved)
}

pub fn pathname_make_relative_symlink(path string, source string) ! {
	os.mkdir_all(os.dir(path))!
	os.symlink(pathname_relative_path(source, os.dir(path)), path)!
}

pub fn pathname_ensure_writable(path string, action PathAction) ! {
	mut saved_mode := ?int(none)
	if !os.is_writable(path) {
		mode := int(os.stat(path)!.get_mode().bitmask())
		saved_mode = mode
		os.chmod(path, mode | 0o600)!
	}
	defer {
		if mode := saved_mode {
			os.chmod(path, mode) or {}
		}
	}
	action(path)!
}

pub fn pathname_install_info(path string, executable string, uninstall bool) !ruby.CommandResult {
	if executable == '' {
		return error('install-info is not available')
	}
	mut arguments := []string{}
	if uninstall {
		arguments << '--delete'
	}
	arguments << ['--quiet', path, os.join_path(os.dir(path), 'dir')]
	return ruby.run_command(executable, arguments)
}

pub fn pathname_write_exec_script(directory string, targets []string) ! {
	if targets.len == 0 {
		return
	}
	os.mkdir_all(directory)!
	for target in targets {
		os.write_file(os.join_path(directory, os.base(target)), '#!/bin/bash\nexec "${target}" "\$@"\n')!
	}
}

pub fn pathname_write_env_script(path string, target string, arguments []string, environment []EnvironmentAssignment) ! {
	mut env_export := ''
	for entry in environment {
		env_export += '${entry.key}="${entry.value}" '
	}
	os.mkdir_all(os.dir(path))!
	os.write_file(path, '#!/bin/bash\n${env_export}exec "${target}" ${arguments.join(' ')} "\$@"\n')!
	os.chmod(path, 0o555)!
}

pub fn pathname_env_script_all_files(directory string, destination string, environment []EnvironmentAssignment) ! {
	os.mkdir_all(destination)!
	mut children := os.ls(directory)!
	children.sort()
	for child in children {
		file := os.join_path(directory, child)
		if os.is_dir(file) {
			continue
		}
		new_file := os.join_path(destination, child)
		if os.exists(new_file) || os.is_link(new_file) {
			return error('EEXIST: ${new_file}')
		}
		pathname_install_p(destination, file, child)!
		pathname_write_env_script(file, new_file, [], environment)!
	}
}

pub fn pathname_write_jar_script(directory string, target_jar string, script_name string, java_options string, java_version string, java_home JavaHomeResolver) !int {
	os.mkdir_all(directory)!
	home := java_home(java_version)!
	content := '#!/bin/bash\nexport JAVA_HOME="${home}"\nexec "\${JAVA_HOME}/bin/java" ${java_options} -jar "${target_jar}" "\$@"\n'
	os.write_file(os.join_path(directory, script_name), content)!
	return content.len
}

pub fn pathname_install_metafiles(destination string, source string, predicate MetafilePredicate) ! {
	for child in os.ls(source)! {
		path := os.join_path(source, child)
		if os.is_dir(path) || os.file_size(path) == 0 || !predicate(child) {
			continue
		}
		filename := pathname_resolved_path(path)!
		if !os.exists(filename) {
			continue
		}
		os.chmod(filename, 0o644)!
		pathname_install(destination, [PathInstallSource{
			path: filename
		}])!
	}
}

pub fn pathname_ds_store(path string) bool {
	return os.base(path) == '.DS_Store'
}

pub fn pathname_magic_number(path string) !string {
	if os.is_dir(path) {
		return ''
	}
	mut file := os.open(path)!
	defer {
		file.close()
	}
	mut buffer := []u8{len: 262}
	read := file.read(mut buffer) or { return err }
	return buffer[..read].bytestr()
}

pub fn pathname_file_type(path string) !string {
	executable := ruby.find_executable('file')!
	result := ruby.run_command(executable, ['-b', path])
	return result.output.trim_right('\r\n')
}

pub fn pathname_zipinfo(path string) ![]string {
	executable := ruby.find_executable('zipinfo')!
	result := ruby.run_command(executable, ['-1', path])
	return result.output.split_into_lines()
}

pub fn pathname_install_p(destination string, source string, new_basename string) ! {
	pathname_install_p_with(destination, source, new_basename, passthrough_path_transform)!
}

pub fn pathname_install_p_with(destination string, source string, new_basename string, transform PathTransform) ! {
	if !os.is_link(source) && !os.exists(source) {
		return error('ENOENT: ${source}')
	}
	mut target := os.join_path(destination, new_basename)
	target = transform(source, target)!
	if target == '' {
		return
	}
	os.mkdir_all(destination)!
	if os.exists(target) || os.is_link(target) {
		pathname_remove(target)!
	}
	os.mv(source, target) or {
		if os.is_link(source) {
			mv := ruby.find_executable('mv')!
			result := ruby.run_command(mv, [source, target])
			if result.exit_code != 0 {
				return error(result.output.trim_space())
			}
		} else if os.is_dir(source) {
			os.cp_all(source, target, true)!
			os.rmdir_all(source)!
		} else {
			os.cp(source, target)!
			os.rm(source)!
		}
	}
}

pub fn pathname_install_symlink_p(destination string, source string, new_basename string) ! {
	os.mkdir_all(destination)!
	destination_directory := os.real_path(destination)
	mut expanded_source := if os.is_abs_path(source) {
		source
	} else {
		os.join_path(destination_directory, source)
	}
	if os.exists(os.dir(expanded_source)) {
		expanded_source = os.join_path(os.real_path(os.dir(expanded_source)), os.base(expanded_source))
	}
	target := os.join_path(destination_directory, new_basename)
	if os.exists(target) || os.is_link(target) {
		pathname_remove(target)!
	}
	os.symlink(pathname_relative_path(expanded_source, destination_directory), target)!
}

pub fn pathname_which_install_info(texinfo_candidate string) ?string {
	if os.is_executable('/usr/bin/install-info') {
		return '/usr/bin/install-info'
	}
	if texinfo_candidate != '' && os.is_executable(texinfo_candidate) {
		return texinfo_candidate
	}
	return none
}

fn pathname_remove(path string) ! {
	if os.is_dir(path) && !os.is_link(path) {
		os.rmdir_all(path)!
	} else {
		os.rm(path)!
	}
}

fn pathname_relative_path(target string, base string) string {
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "extend/pathname/disk_usage_extension"
// 6: require "extend/pathname/eager_initialize_extension"
// 7: require "extend/pathname/observer_pathname_extension"
// 8: require "extend/pathname/write_mkpath_extension"
// 9: require "utils/output"
// 10:
// 11: # Stubs needed to keep Sorbet happy.
// 12: # rubocop:disable Style/OneClassPerFile
// 13:
// 14: # {Pathname} extension for dealing with Mach-O files.
// 15: module MachOShim; end
// 16:
// 17: # {Pathname} extension for dealing with ELF files.
// 18: module ELFShim; end
// 19:
// 20: # @api private
// 21: module BinaryPathname
// 22:   sig { params(path: T.any(Pathname, String, MachOShim, ELFShim)).returns(T.any(MachOShim, ELFShim)) }
// 23:   def self.wrap(path) = raise(NotImplementedError)
// 24: end
// 25:
// 26: # Homebrew extends Ruby's `Pathname` to make our code more readable.
// 27: # @see https://ruby-doc.org/stdlib-2.6.3/libdoc/pathname/rdoc/Pathname.html Ruby's Pathname API
// 28: # TODO: move all of these to other modules e.g. Utils.
// 29: class Pathname
// 30:   include SystemCommand::Mixin
// 31:   include DiskUsageExtension
// 32:   include Utils::Output::Mixin
// 33:   prepend EagerInitializeExtension
// 34:
// 35:   sig { void }
// 36:   def self.activate_extensions!
// 37:     Pathname.prepend(WriteMkpathExtension)
// 38:   end
// 39:
// 40:   # Moves a file from the original location to the {Pathname}'s.
// 41:   #
// 42:   # @api public
// 43:   sig {
// 44:     params(sources: T.any(
// 45:       Resource, Resource::Partial, String, Pathname,
// 46:       T::Array[T.any(String, Pathname)], T::Hash[T.any(String, Pathname), String]
// 47:     )).void
// 48:   }
// 49:   def install(*sources)
// 50:     sources.each do |src|
// 51:       case src
// 52:       when Resource
// 53:         src.stage(self)
// 54:       when Resource::Partial
// 55:         src.resource.stage { install(*src.files) }
// 56:       when Array
// 57:         if src.empty?
// 58:           opoo "Tried to install empty array to #{self}"
// 59:           break
// 60:         end
// 61:         src.each { |s| install_p(s, File.basename(s)) }
// 62:       when Hash
// 63:         if src.empty?
// 64:           opoo "Tried to install empty hash to #{self}"
// 65:           break
// 66:         end
// 67:         src.each { |s, new_basename| install_p(s, new_basename) }
// 68:       else
// 69:         install_p(src, File.basename(src))
// 70:       end
// 71:     end
// 72:   end
// 73:
// 74:   # Creates symlinks to sources in this folder.
// 75:   #
// 76:   # @api public
// 77:   sig {
// 78:     params(
// 79:       sources: T.any(String, Pathname, T::Array[T.any(String, Pathname)], T::Hash[T.any(String, Pathname), String]),
// 80:     ).void
// 81:   }
// 82:   def install_symlink(*sources)
// 83:     sources.each do |src|
// 84:       case src
// 85:       when Array
// 86:         src.each { |s| install_symlink_p(s, File.basename(s)) }
// 87:       when Hash
// 88:         src.each { |s, new_basename| install_symlink_p(s, new_basename) }
// 89:       else
// 90:         install_symlink_p(src, File.basename(src))
// 91:       end
// 92:     end
// 93:   end
// 94:
// 95:   # Only appends to a file that is already created.
// 96:   #
// 97:   # @api public
// 98:   sig { params(content: String, open_args: T.untyped).void }
// 99:   def append_lines(content, **open_args)
// 100:     raise "Cannot append file that doesn't exist: #{self}" unless exist?
// 101:
// 102:     T.unsafe(self).open("a", **open_args) { |f| f.puts(content) }
// 103:   end
// 104:
// 105:   # Write to a file atomically.
// 106:   #
// 107:   # NOTE: This always overwrites.
// 108:   #
// 109:   # @api public
// 110:   sig { params(content: String).void }
// 111:   def atomic_write(content)
// 112:     require "extend/file/atomic"
// 113:
// 114:     old_stat = stat if exist?
// 115:     File.atomic_write(self) do |file|
// 116:       file.write(content)
// 117:     end
// 118:
// 119:     return unless old_stat
// 120:
// 121:     # Try to restore original file's permissions separately
// 122:     # atomic_write does it itself, but it actually erases
// 123:     # them if chown fails
// 124:     begin
// 125:       # Set correct permissions on new file
// 126:       chown(old_stat.uid, nil)
// 127:       chown(nil, old_stat.gid)
// 128:     rescue Errno::EPERM, Errno::EACCES
// 129:       # Changing file ownership failed, moving on.
// 130:       nil
// 131:     end
// 132:
// 133:     begin
// 134:       # This operation will affect filesystem ACL's
// 135:       chmod(old_stat.mode)
// 136:     rescue Errno::EPERM, Errno::EACCES
// 137:       # Changing file permissions failed, moving on.
// 138:       nil
// 139:     end
// 140:   end
// 141:
// 142:   sig {
// 143:     params(pattern: T.any(Pathname, String, Regexp), replacement: T.any(Pathname, String),
// 144:            _block: T.nilable(T.proc.params(src: Pathname, dst: Pathname).returns(Pathname))).void
// 145:   }
// 146:   def cp_path_sub(pattern, replacement, &_block)
// 147:     raise "#{self} does not exist" unless exist?
// 148:
// 149:     pattern = pattern.to_s if pattern.is_a?(Pathname)
// 150:     replacement = replacement.to_s if replacement.is_a?(Pathname)
// 151:     dst = sub(pattern, replacement)
// 152:
// 153:     raise "#{self} is the same file as #{dst}" if self == dst
// 154:
// 155:     if directory?
// 156:       dst.mkpath
// 157:     else
// 158:       dst.dirname.mkpath
// 159:       dst = yield(self, dst) if block_given?
// 160:       FileUtils.cp(self, dst)
// 161:     end
// 162:   end
// 163:
// 164:   # Extended to support common double extensions.
// 165:   #
// 166:   # @api public
// 167:   sig { returns(String) }
// 168:   def extname
// 169:     basename = File.basename(self)
// 170:
// 171:     bottle_ext, = HOMEBREW_BOTTLES_EXTNAME_REGEX.match(basename).to_a
// 172:     return bottle_ext if bottle_ext
// 173:
// 174:     archive_ext = basename[/(\.(tar|cpio|pax)\.(gz|bz2|lz|xz|zst|Z))\Z/, 1]
// 175:     return archive_ext if archive_ext
// 176:
// 177:     # Don't treat version numbers as extname.
// 178:     return "" if basename.match?(/\b\d+\.\d+[^.]*\Z/) && !basename.end_with?(".7z")
// 179:
// 180:     File.extname(basename)
// 181:   end
// 182:
// 183:   # For filetypes we support, returns basename without extension.
// 184:   #
// 185:   # @api public
// 186:   sig { returns(String) }
// 187:   def stem
// 188:     File.basename(self, extname)
// 189:   end
// 190:
// 191:   # I don't trust the children.length == 0 check particularly, not to mention
// 192:   # it is slow to enumerate the whole directory just to see if it is empty,
// 193:   # instead rely on good ol' libc and the filesystem
// 194:   sig { returns(T::Boolean) }
// 195:   def rmdir_if_possible
// 196:     rmdir
// 197:     true
// 198:   rescue Errno::ENOTEMPTY
// 199:     if (ds_store = join(".DS_Store")).exist? && children.length == 1
// 200:       ds_store.unlink
// 201:       retry
// 202:     else
// 203:       false
// 204:     end
// 205:   rescue Errno::EACCES, Errno::ENOENT, Errno::EBUSY, Errno::EPERM
// 206:     false
// 207:   end
// 208:
// 209:   sig { returns(Version) }
// 210:   def version
// 211:     require "version"
// 212:     Version.parse(basename)
// 213:   end
// 214:
// 215:   sig { returns(T::Boolean) }
// 216:   def text_executable?
// 217:     /\A#!\s*\S+/.match?(open("r") { |f| f.read(1024) })
// 218:   end
// 219:
// 220:   sig { returns(String) }
// 221:   def sha256
// 222:     require "digest/sha2"
// 223:     Digest::SHA256.file(self).hexdigest
// 224:   end
// 225:
// 226:   sig { params(expected: T.nilable(Checksum)).void }
// 227:   def verify_checksum(expected)
// 228:     raise ChecksumMissingError if expected.blank?
// 229:
// 230:     actual = Checksum.new(sha256.downcase)
// 231:     raise ChecksumMismatchError.new(self, expected, actual) if expected != actual
// 232:   end
// 233:
// 234:   alias to_str to_s
// 235:
// 236:   # Change to this directory, optionally executing the given block.
// 237:   #
// 238:   # @api public
// 239:   sig {
// 240:     type_parameters(:U).params(
// 241:       _block: T.proc.params(path: Pathname).returns(T.type_parameter(:U)),
// 242:     ).returns(T.type_parameter(:U))
// 243:   }
// 244:   def cd(&_block)
// 245:     Dir.chdir(self) { yield self }
// 246:   end
// 247:
// 248:   # Get all sub-directories of this directory.
// 249:   #
// 250:   # @api public
// 251:   sig { returns(T::Array[Pathname]) }
// 252:   def subdirs
// 253:     children.select(&:directory?)
// 254:   end
// 255:
// 256:   sig { returns(Pathname) }
// 257:   def resolved_path
// 258:     symlink? ? dirname.join(readlink) : self
// 259:   end
// 260:
// 261:   sig { returns(T::Boolean) }
// 262:   def resolved_path_exists?
// 263:     link = readlink
// 264:   rescue ArgumentError
// 265:     # The link target contains NUL bytes
// 266:     false
// 267:   else
// 268:     dirname.join(link).exist?
// 269:   end
// 270:
// 271:   sig { params(src: Pathname).void }
// 272:   def make_relative_symlink(src)
// 273:     dirname.mkpath
// 274:     File.symlink(src.relative_path_from(dirname), self)
// 275:   end
// 276:
// 277:   sig { params(_block: T.proc.void).void }
// 278:   def ensure_writable(&_block)
// 279:     saved_perms = nil
// 280:     unless writable?
// 281:       saved_perms = stat.mode
// 282:       FileUtils.chmod "u+rw", to_path
// 283:     end
// 284:     yield
// 285:   ensure
// 286:     chmod saved_perms if saved_perms
// 287:   end
// 288:
// 289:   sig { void }
// 290:   def install_info
// 291:     quiet_system(which_install_info, "--quiet", to_s, "#{dirname}/dir")
// 292:   end
// 293:
// 294:   sig { void }
// 295:   def uninstall_info
// 296:     quiet_system(which_install_info, "--delete", "--quiet", to_s, "#{dirname}/dir")
// 297:   end
// 298:
// 299:   # Writes an exec script in this folder for each target pathname.
// 300:   #
// 301:   # @api public
// 302:   sig { params(targets: T.any(T::Array[T.any(String, Pathname)], String, Pathname)).void }
// 303:   def write_exec_script(*targets)
// 304:     targets.flatten!
// 305:     if targets.empty?
// 306:       opoo "Tried to write exec scripts to #{self} for an empty list of targets"
// 307:       return
// 308:     end
// 309:     mkpath
// 310:     targets.each do |target|
// 311:       target = Pathname.new(target) # allow pathnames or strings
// 312:       join(target.basename).write <<~SH
// 313:         #!/bin/bash
// 314:         exec "#{target}" "$@"
// 315:       SH
// 316:     end
// 317:   end
// 318:
// 319:   # Writes an exec script that sets environment variables.
// 320:   #
// 321:   # @api public
// 322:   sig {
// 323:     params(
// 324:       target:      T.any(Pathname, String),
// 325:       args_or_env: T.any(
// 326:         String, Pathname,
// 327:         T::Array[T.any(String, Pathname)],
// 328:         T::Hash[T.any(String, Symbol), T.any(String, Pathname)]
// 329:       ),
// 330:       env:         T::Hash[T.any(String, Symbol), T.any(String, Pathname)],
// 331:     ).void
// 332:   }
// 333:   def write_env_script(target, args_or_env, env = T.unsafe(nil))
// 334:     args = if env.nil?
// 335:       env = args_or_env if args_or_env.is_a?(Hash)
// 336:
// 337:       nil
// 338:     elsif args_or_env.is_a?(Array)
// 339:       args_or_env.join(" ")
// 340:     else
// 341:       T.cast(args_or_env, T.nilable(T.any(String, Pathname)))
// 342:     end
// 343:
// 344:     env_export = +""
// 345:     env.each { |key, value| env_export << "#{key}=\"#{value}\" " }
// 346:
// 347:     dirname.mkpath
// 348:
// 349:     write <<~SH
// 350:       #!/bin/bash
// 351:       #{env_export}exec "#{target}" #{args} "$@"
// 352:     SH
// 353:     chmod 0555
// 354:   end
// 355:
// 356:   # Writes a wrapper env script and moves all files to the dst.
// 357:   #
// 358:   # @api public
// 359:   sig { params(dst: Pathname, env: T::Hash[T.any(String, Symbol), T.any(String, Pathname)]).void }
// 360:   def env_script_all_files(dst, env)
// 361:     dst.mkpath
// 362:     Pathname.glob("#{self}/*") do |file|
// 363:       next if file.directory?
// 364:
// 365:       new_file = dst.join(file.basename)
// 366:       raise Errno::EEXIST, new_file.to_s if new_file.exist?
// 367:
// 368:       dst.install(file)
// 369:       file.write_env_script(new_file, env)
// 370:     end
// 371:   end
// 372:
// 373:   # Writes an exec script that invokes a Java jar.
// 374:   #
// 375:   # @api public
// 376:   sig {
// 377:     params(
// 378:       target_jar:   T.any(String, Pathname),
// 379:       script_name:  T.any(String, Pathname),
// 380:       java_opts:    String,
// 381:       java_version: T.nilable(String),
// 382:     ).returns(Integer)
// 383:   }
// 384:   def write_jar_script(target_jar, script_name, java_opts = "", java_version: nil)
// 385:     mkpath
// 386:     (self/script_name).write <<~EOS
// 387:       #!/bin/bash
// 388:       export JAVA_HOME="#{Language::Java.overridable_java_home_env(java_version)[:JAVA_HOME]}"
// 389:       exec "${JAVA_HOME}/bin/java" #{java_opts} -jar "#{target_jar}" "$@"
// 390:     EOS
// 391:   end
// 392:
// 393:   sig { params(from: T.any(String, Pathname)).void }
// 394:   def install_metafiles(from = Pathname.pwd)
// 395:     require "metafiles"
// 396:
// 397:     Pathname(from).children.each do |p|
// 398:       next if p.directory?
// 399:       next if File.empty?(p)
// 400:       next unless Metafiles.copy?(p.basename.to_s)
// 401:
// 402:       # Some software symlinks these files (see help2man.rb)
// 403:       filename = p.resolved_path
// 404:       # Some software links metafiles together, so by the time we iterate to one of them
// 405:       # we may have already moved it. libxml2's COPYING and Copyright are affected by this.
// 406:       next unless filename.exist?
// 407:
// 408:       filename.chmod 0644
// 409:       install(filename)
// 410:     end
// 411:   end
// 412:
// 413:   sig { returns(T::Boolean) }
// 414:   def ds_store?
// 415:     basename.to_s == ".DS_Store"
// 416:   end
// 417:
// 418:   sig { returns(T::Boolean) }
// 419:   def binary_executable?
// 420:     false
// 421:   end
// 422:
// 423:   sig { returns(T::Boolean) }
// 424:   def mach_o_bundle?
// 425:     false
// 426:   end
// 427:
// 428:   sig { returns(T::Boolean) }
// 429:   def dylib?
// 430:     false
// 431:   end
// 432:
// 433:   sig { params(_wanted_arch: Symbol).returns(T::Boolean) }
// 434:   def arch_compatible?(_wanted_arch)
// 435:     true
// 436:   end
// 437:
// 438:   sig { returns(T::Array[String]) }
// 439:   def rpaths
// 440:     []
// 441:   end
// 442:
// 443:   sig { returns(String) }
// 444:   def magic_number
// 445:     @magic_number ||= T.let(nil, T.nilable(String))
// 446:     @magic_number ||= if directory?
// 447:       ""
// 448:     else
// 449:       # Length of the longest regex (currently Tar).
// 450:       max_magic_number_length = 262
// 451:       binread(max_magic_number_length) || ""
// 452:     end
// 453:   end
// 454:
// 455:   sig { returns(String) }
// 456:   def file_type
// 457:     @file_type ||= T.let(nil, T.nilable(String))
// 458:     @file_type ||= system_command("file", args: ["-b", self], print_stderr: false)
// 459:                    .stdout.chomp
// 460:   end
// 461:
// 462:   sig { returns(T::Array[String]) }
// 463:   def zipinfo
// 464:     @zipinfo ||= T.let(
// 465:       system_command("zipinfo", args: ["-1", self], print_stderr: false)
// 466:       .stdout
// 467:       .encode(Encoding::UTF_8, invalid: :replace)
// 468:       .split("\n"),
// 469:       T.nilable(T::Array[String]),
// 470:     )
// 471:   end
// 472:
// 473:   private
// 474:
// 475:   sig {
// 476:     params(src: T.any(String, Pathname), new_basename: T.any(String, Pathname),
// 477:            _block: T.nilable(T.proc.params(src: Pathname, dst: Pathname).returns(T.nilable(Pathname)))).void
// 478:   }
// 479:   def install_p(src, new_basename, &_block)
// 480:     src = Pathname(src)
// 481:     raise Errno::ENOENT, src.to_s if !src.symlink? && !src.exist?
// 482:
// 483:     dst = join(new_basename)
// 484:     dst = yield(src, dst) if block_given?
// 485:     return unless dst
// 486:
// 487:     mkpath
// 488:
// 489:     # Use `FileUtils.mv` over `File.rename` to handle filesystem boundaries. If `src`
// 490:     # is a symlink and its target is moved first, `FileUtils.mv` will fail
// 491:     # (https://bugs.ruby-lang.org/issues/7707).
// 492:     #
// 493:     # In that case, use the system `mv` command.
// 494:     if src.symlink?
// 495:       raise unless Kernel.system "mv", src.to_s, dst.to_s
// 496:     else
// 497:       FileUtils.mv src, dst
// 498:     end
// 499:   end
// 500:
// 501:   sig { params(src: T.any(String, Pathname), new_basename: T.any(String, Pathname)).void }
// 502:   def install_symlink_p(src, new_basename)
// 503:     mkpath
// 504:     dstdir = realpath
// 505:     src = Pathname(src).expand_path(dstdir)
// 506:     src = src.dirname.realpath/src.basename if src.dirname.exist?
// 507:     FileUtils.ln_sf(src.relative_path_from(dstdir), dstdir/new_basename)
// 508:   end
// 509:
// 510:   sig { returns(T.nilable(String)) }
// 511:   def which_install_info
// 512:     @which_install_info ||= T.let(nil, T.nilable(String))
// 513:     @which_install_info ||=
// 514:       if File.executable?("/usr/bin/install-info")
// 515:         "/usr/bin/install-info"
// 516:       elsif (texinfo_formula = Formula["texinfo"]).any_version_installed?
// 517:         (texinfo_formula.opt_bin/"install-info").to_s
// 518:       end
// 519:   end
// 520: end
// 521: # rubocop:enable Style/OneClassPerFile
// 522: #
// 523: require "extend/os/pathname"
