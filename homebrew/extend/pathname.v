module extend

import ruby
import crypto.sha256
import os

// Translated from Homebrew/brew `extend/pathname.rb`.

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

pub type BinaryPathResolver = fn (string) !BinaryPath

pub type PathTransform = fn (string, string) !string

pub type PathAction = fn (string) !

pub type PathVersionParser = fn (string) !string

pub type JavaHomeResolver = fn (string) !string

pub type MetafilePredicate = fn (string) bool

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
	if target.contains('\x00') {
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
