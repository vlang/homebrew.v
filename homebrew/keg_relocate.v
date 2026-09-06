module homebrew

import ruby
import os

// Translated from Homebrew/brew `keg_relocate.rb`.
pub const keg_prefix_placeholder = '@@HOMEBREW_PREFIX@@'
pub const keg_cellar_placeholder = '@@HOMEBREW_CELLAR@@'
pub const keg_repository_placeholder = '@@HOMEBREW_REPOSITORY@@'
pub const keg_library_placeholder = '@@HOMEBREW_LIBRARY@@'
pub const keg_perl_placeholder = '@@HOMEBREW_PERL@@'
pub const keg_java_placeholder = '@@HOMEBREW_JAVA@@'

pub struct KegReplacementPair {
pub:
	old_value string
	new_value string
	path      bool
}

pub struct KegRelocation {
pub mut:
	replacement_map map[string]KegReplacementPair
}

pub fn new_keg_relocation() KegRelocation {
	return KegRelocation{
		replacement_map: map[string]KegReplacementPair{}
	}
}

pub fn (mut relocation KegRelocation) add_replacement_pair(key string, old_value string,
	new_value string) {
	relocation.add_replacement_pair_with_path(key, old_value, new_value, false)
}

pub fn (mut relocation KegRelocation) add_replacement_pair_with_path(key string, old_value string,
	new_value string, path bool) {
	relocation.replacement_map[key] = KegReplacementPair{
		old_value: old_value
		new_value: new_value
		path: path
	}
}

pub fn (relocation KegRelocation) replacement_pair_for(key string) !KegReplacementPair {
	return relocation.replacement_map[key] or { return error('Missing relocation pair: ${key}') }
}

pub fn (relocation KegRelocation) replace_text(text string) (string, bool) {
	mut pending_replacements := relocation.replacement_map.values()
	mut replacements := []KegReplacementPair{cap: pending_replacements.len}
	// Ruby orders regexp/path pairs before literal pairs. Within each group the
	// reverse sort ensures the most specific/longest value is considered first,
	// and literal placeholders expanded later are not relocated a second time.
	for pending_replacements.len > 0 {
		mut selected := 0
		for index := 1; index < pending_replacements.len; index++ {
			if keg_replacement_sort_rank(pending_replacements[index]) > keg_replacement_sort_rank(pending_replacements[selected]) {
				selected = index
			}
		}
		replacements << pending_replacements[selected]
		pending_replacements.delete(selected)
	}
	mut output := text
	for pair in replacements {
		output = if pair.path {
			keg_replace_path_occurrences(output, pair.old_value, pair.new_value)
		} else {
			output.replace(pair.old_value, pair.new_value)
		}
	}
	return output, output != text
}

fn keg_replacement_sort_rank(pair KegReplacementPair) int {
	return pair.old_value.len + if pair.path { 1_000_000 } else { 0 }
}

fn keg_replace_path_occurrences(text string, old_value string, new_value string) string {
	if old_value == '' {
		return text
	}
	mut output := ''
	mut cursor := 0
	for cursor < text.len {
		relative := text[cursor..].index(old_value) or {
			output += text[cursor..]
			break
		}
		position := cursor + relative
		previous := if position > 0 { text[position - 1] } else { u8(0) }
		previous_is_alnum := (previous >= `a` && previous <= `z`) || (previous >= `A` && previous <= `Z`) || (previous >= `0` && previous <= `9`)
		allowed := position == 0 || !previous_is_alnum || (position >= 2 && text[position - 2..position] in [
			'-F',
			'-I',
			'-L',
		]) || (position >= 8 && text[position - 8..position] == '-isystem')
		output += text[cursor..position]
		if allowed {
			output += new_value
		} else {
			output += old_value
		}
		cursor = position + old_value.len
	}
	return output
}

pub fn prepare_keg_relocation_to_locations(prefix string, cellar string, repository string,
	library string) KegRelocation {
	mut relocation := new_keg_relocation()
	relocation.add_replacement_pair('prefix', keg_prefix_placeholder, prefix)
	relocation.add_replacement_pair('cellar', keg_cellar_placeholder, cellar)
	relocation.add_replacement_pair('repository', keg_repository_placeholder, repository)
	relocation.add_replacement_pair('library', keg_library_placeholder, library)
	relocation.add_replacement_pair('perl', keg_perl_placeholder, ruby.join_path(prefix, 'opt/perl/bin/perl'))
	return relocation
}

fn keg_regular_files(keg Keg) []string {
	return keg.find().filter(ruby.is_file(it) && !ruby.is_link(it))
}

// Mach-O magic numbers and file types from `ruby-macho`'s `MachO::Headers`. The
// source reaches its `dylib?`/`mach_o_bundle?`/`mach_o_executable?` predicates
// through ruby-macho's header parse, so the same classification is made here by
// reading the header rather than forking `file` once per keg file.
const mach_o_fat_magic = u32(0xcafebabe)
const mach_o_fat_magic_64 = u32(0xcafebabf)
const mach_o_magic = u32(0xfeedface)
const mach_o_cigam = u32(0xcefaedfe)
const mach_o_magic_64 = u32(0xfeedfacf)
const mach_o_cigam_64 = u32(0xcffaedfe)

// Java class files share FAT_MAGIC and encode their version where a fat header
// keeps `nfat_arch`; the lowest such version is 43, so ruby-macho treats a
// header claiming more than 30 slices as a class file instead.
const mach_o_max_fat_arch = u32(30)

const mach_o_filetype_execute = u32(0x2)
const mach_o_filetype_dylib = u32(0x6)
const mach_o_filetype_bundle = u32(0x8)

const mach_o_fat_arch_size = 20
const mach_o_fat_arch_64_size = 32

fn mach_o_read_u32(bytes []u8, offset int, big_endian bool) ?u32 {
	if offset < 0 || offset + 4 > bytes.len {
		return none
	}
	first := u32(bytes[offset])
	second := u32(bytes[offset + 1])
	third := u32(bytes[offset + 2])
	fourth := u32(bytes[offset + 3])
	// V binds `|` tighter than `<<`, so each shifted byte needs its own parentheses.
	return if big_endian {
		(first << 24) | (second << 16) | (third << 8) | fourth
	} else {
		(fourth << 24) | (third << 16) | (second << 8) | first
	}
}

// mach_o_slice_relocatable reports whether the thin Mach-O header at `offset`
// carries one of the file types Keg#mach_o_files selects.
fn mach_o_slice_relocatable(file &os.File, offset u64) bool {
	header := file.read_bytes_at(16, offset)
	magic := mach_o_read_u32(header, 0, true) or { return false }
	big_endian := magic == mach_o_magic || magic == mach_o_magic_64
	if !big_endian && magic != mach_o_cigam && magic != mach_o_cigam_64 {
		return false
	}
	filetype := mach_o_read_u32(header, 12, big_endian) or { return false }
	return filetype in [mach_o_filetype_execute, mach_o_filetype_dylib, mach_o_filetype_bundle]
}

// mach_o_relocatable_file answers the source's
// `dylib? || mach_o_bundle? || mach_o_executable?` for one path. Fat headers are
// always big-endian, and any slice of a matching type makes the whole file one.
fn mach_o_relocatable_file(path string) bool {
	mut file := os.open(path) or { return false }
	defer {
		file.close()
	}
	header := file.read_bytes_at(8, 0)
	magic := mach_o_read_u32(header, 0, true) or { return false }
	if magic != mach_o_fat_magic && magic != mach_o_fat_magic_64 {
		return mach_o_slice_relocatable(file, 0)
	}
	count := mach_o_read_u32(header, 4, true) or { return false }
	if count == 0 || count > mach_o_max_fat_arch {
		return false
	}
	entry_size := if magic == mach_o_fat_magic {
		mach_o_fat_arch_size
	} else {
		mach_o_fat_arch_64_size
	}
	architectures := file.read_bytes_at(entry_size * int(count), 8)
	for index := 0; index < int(count); index++ {
		base := index * entry_size
		slice_offset := if magic == mach_o_fat_magic {
			u64(mach_o_read_u32(architectures, base + 8, true) or { continue })
		} else {
			high := mach_o_read_u32(architectures, base + 8, true) or { continue }
			low := mach_o_read_u32(architectures, base + 12, true) or { continue }
			(u64(high) << 32) | u64(low)
		}
		if mach_o_slice_relocatable(file, slice_offset) {
			return true
		}
	}
	return false
}

pub fn (keg Keg) mach_o_files() []string {
	mut files := []string{}
	mut seen_inodes := map[string]bool{}
	for path in keg_regular_files(keg) {
		if !mach_o_relocatable_file(path) {
			continue
		}
		// Hardlinks share a device and inode. The source keeps only the first name
		// of each so that a binary is never relocated more than once.
		if information := os.stat(path) {
			key := '${information.dev}:${information.inode}'
			if key in seen_inodes {
				continue
			}
			seen_inodes[key] = true
		}
		files << path
	}
	return files
}

fn otool_linked_libraries(path string) []string {
	result := ruby.run_command('/usr/bin/otool', ['-L', path])
	if result.exit_code != 0 {
		return []string{}
	}
	mut libraries := []string{}
	for line in result.output.split_into_lines()[1..] {
		trimmed := line.trim_space()
		if index := trimmed.index(' (') {
			libraries << trimmed[..index]
		}
	}
	return libraries
}

fn otool_dylib_id(path string) ?string {
	result := ruby.run_command('/usr/bin/otool', ['-D', path])
	if result.exit_code != 0 {
		return none
	}
	lines := result.output.split_into_lines().map(it.trim_space()).filter(it != '')
	if lines.len < 2 {
		return none
	}
	return lines[1]
}

fn otool_rpaths(path string) []string {
	result := ruby.run_command('/usr/bin/otool', ['-l', path])
	if result.exit_code != 0 {
		return []string{}
	}
	lines := result.output.split_into_lines()
	mut rpaths := []string{}
	mut in_rpath := false
	for line in lines {
		trimmed := line.trim_space()
		if trimmed == 'cmd LC_RPATH' {
			in_rpath = true
			continue
		}
		if in_rpath && trimmed.starts_with('path ') {
			value := trimmed.all_after('path ')
			if index := value.index(' (offset') {
				rpaths << value[..index]
			}
			in_rpath = false
		}
	}
	return rpaths
}

fn relocated_keg_name(old_name string, relocation KegRelocation) ?string {
	for key in ['cellar', 'prefix', 'repository', 'library', 'perl', 'java'] {
		pair := relocation.replacement_map[key] or { continue }
		if old_name.starts_with(pair.old_value) {
			return old_name.replace_once(pair.old_value, pair.new_value)
		}
	}
	return none
}

fn make_keg_file_writable(path string) ! {
	information := os.inode(path)
	if !information.owner.write {
		os.chmod(path, int(information.bitmask() | u32(0o200)))!
	}
}

fn run_install_name_tool(arguments []string) ! {
	result := ruby.run_command('/usr/bin/install_name_tool', arguments)
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
}

fn codesign_relocated_binary(path string) ! {
	result := ruby.run_command('/usr/bin/codesign', ['--sign', '-', '--force', path])
	if result.exit_code != 0 {
		return error('Failed applying an ad-hoc signature to ${path}: ${result.output.trim_space()}')
	}
}

// relocate_dynamic_linkage translates the macOS Keg relocation loop using the
// platform tools that back ruby-macho's mutations in the source implementation.
pub fn (mut keg Keg) relocate_dynamic_linkage(relocation KegRelocation) ![]string {
	mut changed := []string{}
	for path in keg.mach_o_files() {
		make_keg_file_writable(path)!
		mut modified := false
		if dylib_id := otool_dylib_id(path) {
			if replacement := relocated_keg_name(dylib_id, relocation) {
				if replacement != dylib_id {
					run_install_name_tool(['-id', replacement, path])!
					modified = true
				}
			}
		}
		for old_name in otool_linked_libraries(path) {
			if replacement := relocated_keg_name(old_name, relocation) {
				if replacement != old_name {
					run_install_name_tool(['-change', old_name, replacement, path])!
					modified = true
				}
			}
		}
		for old_name in otool_rpaths(path) {
			if replacement := relocated_keg_name(old_name, relocation) {
				if replacement != old_name {
					run_install_name_tool(['-rpath', old_name, replacement, path])!
					modified = true
				}
			}
		}
		if modified {
			codesign_relocated_binary(path)!
			changed << path
		}
	}
	return changed
}

// The source classifies a keg's files with a single
// `xargs -0 file --no-dereference --print0` pass. Batching the same way keeps
// `file`'s own classification while spawning one process per chunk instead of
// one per file; chunking keeps the argument vector clear of `ARG_MAX`.
const keg_file_description_batch = 512

fn keg_file_descriptions(paths []string) map[string]string {
	mut descriptions := map[string]string{}
	if paths.len == 0 {
		return descriptions
	}
	file_program := ruby.find_executable('file') or { return descriptions }
	for start := 0; start < paths.len; start += keg_file_description_batch {
		end := if start + keg_file_description_batch < paths.len {
			start + keg_file_description_batch
		} else {
			paths.len
		}
		mut arguments := ['--no-dereference', '--print0']
		arguments << paths[start..end]
		result := ruby.run_command(file_program, arguments)
		if result.exit_code != 0 {
			continue
		}
		// `file --print0` emits `path\0: description`, and prints extra lines for
		// some files that carry no separator and are skipped.
		for line in result.output.split_into_lines() {
			path, description := line.split_once('\0') or { continue }
			descriptions[path] = description.trim_left(': ').trim_space()
		}
	}
	return descriptions
}

fn keg_text_description(description string, path string) bool {
	lowered := description.to_lower()
	return lowered.contains('text') || lowered.contains('script') || path.ends_with('.la')
}

fn keg_text_files_among(paths []string) []string {
	descriptions := keg_file_descriptions(paths)
	return paths.filter(keg_text_description(descriptions[it] or { '' }, it))
}

pub fn (keg Keg) replace_text_in_files(relocation KegRelocation,
	selected_files []string) ![]string {
	mut candidates := if selected_files.len > 0 {
		selected_files.map(if os.is_abs_path(it) { it } else { keg.join(it) })
	} else {
		keg_text_files_among(keg_regular_files(keg))
	}
	candidates.sort()
	mut changed := []string{}
	for path in candidates {
		if !ruby.is_file(path) || ruby.is_link(path) {
			continue
		}
		contents := ruby.read_file(path) or { continue }
		replaced, modified := relocation.replace_text(contents)
		if !modified {
			continue
		}
		make_keg_file_writable(path)!
		ruby.atomic_write_file(path, replaced)!
		changed << path
	}
	return changed
}

pub fn (mut keg Keg) replace_placeholders_with_locations(prefix string, cellar string,
	repository string, library string, files []string, skip_linkage bool) ![]string {
	relocation := prepare_keg_relocation_to_locations(prefix, cellar, repository, library)
	mut changed := []string{}
	if !skip_linkage {
		changed << keg.relocate_dynamic_linkage(relocation)!
	}
	changed << keg.replace_text_in_files(relocation, files)!
	return changed
}

pub fn keg_path_regex_source(path string, already_regex bool) string {
	mut escaped := path
	if !already_regex {
		for character in ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '^', '\$', '|'] {
			escaped = escaped.replace(character, '\\${character}')
		}
	}
	return '(?:(?<=-F|-I|-L|-isystem)|(?<![a-zA-Z0-9]))${escaped}'
}

pub fn (keg Keg) fix_dynamic_linkage() ![]string {
	mut changed := []string{}
	for file in keg_symlink_files(keg) {
		link := os.readlink(file) or { continue }
		if !os.is_abs_path(link) || (!link.starts_with(keg.cellar) && !link.starts_with(keg.prefix)) {
			continue
		}
		relative := keg_relative_path(link, os.dir(file))
		os.rm(file)!
		os.symlink(relative, file)!
		changed << file
	}
	return changed
}

pub fn keg_new_usr_local_pairs(name string) map[string]KegReplacementPair {
	return {
		'prefix':       KegReplacementPair{ old_value: '/usr/local/opt', new_value: '${keg_prefix_placeholder}/opt', path: true }
		'caskroom':     KegReplacementPair{ old_value: '/usr/local/Caskroom', new_value: '${keg_prefix_placeholder}/Caskroom', path: true }
		'etc_name':     KegReplacementPair{ old_value: '/usr/local/etc/${name}', new_value: '${keg_prefix_placeholder}/etc/${name}', path: true }
		'var_homebrew': KegReplacementPair{ old_value: '/usr/local/var/homebrew', new_value: '${keg_prefix_placeholder}/var/homebrew', path: true }
		'var_www':      KegReplacementPair{ old_value: '/usr/local/var/www', new_value: '${keg_prefix_placeholder}/var/www', path: true }
		'var_name':     KegReplacementPair{ old_value: '/usr/local/var/${name}', new_value: '${keg_prefix_placeholder}/var/${name}', path: true }
		'var_log_name': KegReplacementPair{ old_value: '/usr/local/var/log/${name}', new_value: '${keg_prefix_placeholder}/var/log/${name}', path: true }
		'var_lib_name': KegReplacementPair{ old_value: '/usr/local/var/lib/${name}', new_value: '${keg_prefix_placeholder}/var/lib/${name}', path: true }
		'var_run_name': KegReplacementPair{ old_value: '/usr/local/var/run/${name}', new_value: '${keg_prefix_placeholder}/var/run/${name}', path: true }
		'var_db_name':  KegReplacementPair{ old_value: '/usr/local/var/db/${name}', new_value: '${keg_prefix_placeholder}/var/db/${name}', path: true }
		'share_name':   KegReplacementPair{ old_value: '/usr/local/share/${name}', new_value: '${keg_prefix_placeholder}/share/${name}', path: true }
	}
}

pub fn prepare_keg_relocation_to_placeholders(keg Keg, repository string, library string,
	new_usr_local bool) KegRelocation {
	mut relocation := new_keg_relocation()
	if new_usr_local {
		for key, pair in keg_new_usr_local_pairs(keg.name) {
			relocation.add_replacement_pair_with_path(key, pair.old_value, pair.new_value, true)
		}
	} else {
		relocation.add_replacement_pair_with_path('prefix', keg.prefix, keg_prefix_placeholder, true)
	}
	relocation.add_replacement_pair_with_path('cellar', keg.cellar, keg_cellar_placeholder, true)
	if keg.prefix != repository {
		relocation.add_replacement_pair_with_path('repository', repository, keg_repository_placeholder, true)
	}
	relocation.add_replacement_pair_with_path('library', library, keg_library_placeholder, true)
	relocation.add_replacement_pair('perl', '${keg.prefix}/opt/perl/bin/perl', keg_perl_placeholder)
	relocation.add_replacement_pair('java', '${keg.prefix}/opt/openjdk/libexec', keg_java_placeholder)
	return relocation
}

pub fn keg_openjdk_dependency(dependencies []string) ?string {
	for dependency in dependencies {
		if dependency == 'openjdk' || dependency.starts_with('openjdk@') {
			return dependency
		}
	}
	return none
}

pub fn keg_homebrew_created_file(path string) bool {
	return os.base(path).starts_with('homebrew.') && os.file_ext(path) in ['.plist', '.service',
		'.timer']
}

pub fn (keg Keg) relocate_build_prefix(old_prefix string, new_prefix string) ![]string {
	mut changed := []string{}
	for file in keg_each_unique_file_matching(keg, old_prefix) {
		if !keg_binary_file(file) {
			continue
		}
		bytes := os.read_bytes(file)!
		mut parts := bytes.bytestr().split('\x00')
		mut modified := false
		for index, part in parts {
			if part.contains(old_prefix) {
				replaced := part.replace(old_prefix, new_prefix)
				if replaced.len > part.len {
					return error('Patching failed! Original and patched binary sizes do not match.')
				}
				parts[index] = replaced + '\x00'.repeat(part.len - replaced.len)
				modified = true
			}
		}
		if modified {
			patched := parts.join('\x00').bytes()
			if patched.len != bytes.len {
				return error('Patching failed! Original and patched binary sizes do not match.')
			}
			os.write_file_array(file, patched)!
			changed << file
		}
	}
	return changed
}

pub fn keg_each_unique_file_matching(keg Keg, needle string) []string {
	mut files := []string{}
	mut inodes := map[string]bool{}
	for file in keg.find() {
		if !os.is_file(file) || os.is_link(file) {
			continue
		}
		bytes := os.read_bytes(file) or { continue }
		if !bytes.bytestr().contains(needle) {
			continue
		}
		inode := keg_file_inode(file)
		if inode !in inodes {
			inodes[inode] = true
			files << file
		}
	}
	return files
}

fn keg_file_inode(path string) string {
	mac_result := ruby.run_command('stat', ['-f', '%i', path])
	if mac_result.exit_code == 0 {
		return mac_result.output.trim_space()
	}
	linux_result := ruby.run_command('stat', ['-c', '%i', path])
	return if linux_result.exit_code == 0 {
		linux_result.output.trim_space()
	} else {
		os.real_path(path)
	}
}

fn keg_relative_path(path string, base string) string {
	path_parts := os.norm_path(path).split(os.path_separator)
	base_parts := os.norm_path(base).split(os.path_separator)
	mut common := 0
	for common < path_parts.len && common < base_parts.len && path_parts[common] == base_parts[common] {
		common++
	}
	mut relative_parts := []string{}
	for _ in common .. base_parts.len {
		relative_parts << '..'
	}
	relative_parts << path_parts[common..]
	return if relative_parts.len == 0 { '.' } else { relative_parts.join(os.path_separator) }
}

pub fn keg_binary_file(file string) bool {
	return (os.read_bytes(file) or { return false }).contains(u8(0))
}

pub fn keg_text_files(keg Keg) []string {
	candidates := keg.find().filter(os.is_file(it) && !os.is_link(it))
	descriptions := keg_file_descriptions(candidates)
	return candidates.filter(keg_text_description(descriptions[it] or { '' }, it)
		|| os.base(it) == 'orig-prefix.txt')
}

pub fn keg_libtool_files(keg Keg) []string {
	return keg.find().filter(os.is_file(it) && !os.is_link(it) && os.file_ext(it) in [
		'.la',
		'.lai',
	])
}

pub fn keg_symlink_files(keg Keg) []string {
	return keg.find().filter(os.is_link(it))
}

pub fn keg_text_matches_in_file(file string, needle string, ignores []string,
	linked_libraries []string, dependency_names []string) ![][]string {
	contents := os.read_bytes(file)!.bytestr()
	mut matches := [][]string{}
	mut offset := 0
	for segment in contents.split('\x00') {
		mut line_offset := offset
		for line in segment.split_into_lines() {
			if ignores.any(line.contains(it)) {
				line_offset += line.len + 1
				continue
			}
			for candidate in line.split(':') {
				if !keg_replace_path_occurrences(candidate, needle, '__MATCH__').contains('__MATCH__') || candidate in linked_libraries || !os.exists(candidate) {
					continue
				}
				if dependency_names.len > 0 && !dependency_names.any(candidate.contains('/${it}/')) {
					continue
				}
				hex_offset := line_offset.hex()
				if !matches.any(it[1] == hex_offset) {
					matches << [line, hex_offset]
				}
			}
			line_offset += line.len + 1
		}
		offset += segment.len + 1
	}
	return matches
}

fn relocation_keg_from_value(value ruby.Value) Keg {
	values := value.map_data.clone()
	path := (values['path'] or { ruby.string_value(value.as_string()) }).as_string()
	cellar := (values['cellar'] or { ruby.string_value(os.dir(os.dir(path))) }).as_string()
	prefix := (values['prefix'] or { ruby.string_value(os.dir(cellar)) }).as_string()
	return Keg{ path: path, name: (values['name'] or { ruby.string_value(os.base(os.dir(path))) }).as_string(), prefix: prefix, cellar: cellar }
}

pub fn keg_relocation_keg_value(keg Keg) ruby.Value {
	return ruby.map_value({
		'path':   ruby.string_value(keg.path)
		'name':   ruby.string_value(keg.name)
		'prefix': ruby.string_value(keg.prefix)
		'cellar': ruby.string_value(keg.cellar)
	})
}

fn keg_relocation_from_value(value ruby.Value) KegRelocation {
	mut relocation := new_keg_relocation()
	if value.type_name != 'Hash' {
		return relocation
	}
	for key, entry in value.map_data {
		if entry.type_name != 'Hash' {
			continue
		}
		values := entry.map_data.clone()
		relocation.add_replacement_pair_with_path(key, (values['old'] or { ruby.string_value('') }).as_string(), (values['new'] or { ruby.string_value('') }).as_string(), (values['path'] or { ruby.bool_value(false) }).bool_data)
	}
	return relocation
}

pub fn keg_relocation_value(relocation KegRelocation) ruby.Value {
	return ruby.map_value(keg_replacement_pairs_value(relocation.replacement_map))
}

fn keg_replacement_pairs_value(pairs map[string]KegReplacementPair) map[string]ruby.Value {
	mut values := map[string]ruby.Value{}
	for key, pair in pairs {
		values[key] = keg_replacement_pair_value(pair)
	}
	return values
}

fn keg_replacement_pair_value(pair KegReplacementPair) ruby.Value {
	return ruby.map_value({
		'old':  ruby.string_value(pair.old_value)
		'new':  ruby.string_value(pair.new_value)
		'path': ruby.bool_value(pair.path)
	})
}

fn keg_relocate_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}
