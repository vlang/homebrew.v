module homebrew

import brew_runtime
import os

// Translated from Homebrew/brew `keg_relocate.rb`.
// The original source is retained below until every stub has a typed V body.
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
	relocation.add_replacement_pair('perl', keg_perl_placeholder, brew_runtime.join_path(prefix, 'opt/perl/bin/perl'))
	return relocation
}

fn keg_regular_files(keg Keg) []string {
	return keg.find().filter(brew_runtime.is_file(it) && !brew_runtime.is_link(it))
}

fn keg_file_description(path string) string {
	file_program := brew_runtime.find_executable('file') or { return '' }
	result := brew_runtime.run_command(file_program, ['-b', path])
	return if result.exit_code == 0 { result.output.trim_space() } else { '' }
}

pub fn (keg Keg) mach_o_files() []string {
	mut files := []string{}
	for path in keg_regular_files(keg) {
		if keg_file_description(path).contains('Mach-O') {
			files << path
		}
	}
	return files
}

fn otool_linked_libraries(path string) []string {
	result := brew_runtime.run_command('/usr/bin/otool', ['-L', path])
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
	result := brew_runtime.run_command('/usr/bin/otool', ['-D', path])
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
	result := brew_runtime.run_command('/usr/bin/otool', ['-l', path])
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
	result := brew_runtime.run_command('/usr/bin/install_name_tool', arguments)
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
}

fn codesign_relocated_binary(path string) ! {
	result := brew_runtime.run_command('/usr/bin/codesign', ['--sign', '-', '--force', path])
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

fn keg_text_file(path string) bool {
	description := keg_file_description(path).to_lower()
	return description.contains('text') || description.contains('script') || path.ends_with('.la')
}

pub fn (keg Keg) replace_text_in_files(relocation KegRelocation,
	selected_files []string) ![]string {
	mut candidates := if selected_files.len > 0 {
		selected_files.map(if os.is_abs_path(it) { it } else { keg.join(it) })
	} else {
		keg_regular_files(keg).filter(keg_text_file(it))
	}
	candidates.sort()
	mut changed := []string{}
	for path in candidates {
		if !brew_runtime.is_file(path) || brew_runtime.is_link(path) {
			continue
		}
		contents := brew_runtime.read_file(path) or { continue }
		replaced, modified := relocation.replace_text(contents)
		if !modified {
			continue
		}
		make_keg_file_writable(path)!
		brew_runtime.atomic_write_file(path, replaced)!
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
		mut parts := bytes.bytestr().split('\0')
		mut modified := false
		for index, part in parts {
			if part.contains(old_prefix) {
				replaced := part.replace(old_prefix, new_prefix)
				if replaced.len > part.len {
					return error('Patching failed! Original and patched binary sizes do not match.')
				}
				parts[index] = replaced + '\0'.repeat(part.len - replaced.len)
				modified = true
			}
		}
		if modified {
			patched := parts.join('\0').bytes()
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
	mac_result := brew_runtime.run_command('stat', ['-f', '%i', path])
	if mac_result.exit_code == 0 {
		return mac_result.output.trim_space()
	}
	linux_result := brew_runtime.run_command('stat', ['-c', '%i', path])
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
	return keg.find().filter(os.is_file(it) && !os.is_link(it) && (keg_text_file(it) || os.base(it) == 'orig-prefix.txt'))
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
	for segment in contents.split('\0') {
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

// Ruby method `initialize` at line 22.
pub fn ruby_keg_relocate_l22_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return keg_relocation_value(new_keg_relocation())
}

// Ruby method `freeze` at line 27.
pub fn ruby_keg_relocate_l27_d2_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	return keg_relocation_value(keg_relocation_from_value(args[0] or { keg_relocation_value(new_keg_relocation()) }))
}

// Ruby method `add_replacement_pair(key, old_value, new_value, path: false)` at line 33.
pub fn ruby_keg_relocate_l33_d3_add_replacement_pair(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		return brew_runtime.object_value('ArgumentError', 'replacement pair requires relocation, key, old and new values')
	}
	mut relocation := keg_relocation_from_value(args[0])
	relocation.add_replacement_pair_with_path(args[1].as_string(), args[2].as_string(), args[3].as_string(), args.len > 4 && args[4].bool_data)
	return keg_relocation_value(relocation)
}

// Ruby method `replacement_pair_for(key)` at line 39.
pub fn ruby_keg_relocate_l39_d4_replacement_pair_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('KeyError', 'replacement key is required')
	}
	pair := keg_relocation_from_value(args[0]).replacement_pair_for(args[1].as_string()) or { return brew_runtime.object_value('KeyError', err.msg()) }
	return keg_replacement_pair_value(pair)
}

// Ruby method `replace_text!(text)` at line 44.
pub fn ruby_keg_relocate_l44_d5_replace_text(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	replaced, changed := keg_relocation_from_value(args[0]).replace_text(args[1].as_string())
	return brew_runtime.map_value({
		'changed': brew_runtime.bool_value(changed)
		'text':    brew_runtime.string_value(replaced)
	})
}

// Ruby method `self.path_to_regex(path)` at line 60.
pub fn ruby_keg_relocate_l60_d6_self_path_to_regex(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('Regexp', keg_path_regex_source('', false))
	}
	return brew_runtime.object_value('Regexp', keg_path_regex_source(args[0].as_string(), args.len > 1 && args[1].bool_data))
}

// Ruby method `fix_dynamic_linkage` at line 72.
pub fn ruby_keg_relocate_l72_d7_fix_dynamic_linkage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(relocation_keg_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }).fix_dynamic_linkage() or { return brew_runtime.object_value('SystemCallError', err.msg()) })
}

// Ruby method `relocate_dynamic_linkage(_relocation, skip_protodesc_cold: false); end` at line 89.
pub fn ruby_keg_relocate_l89_d8_relocate_dynamic_linkage(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	mut keg := relocation_keg_from_value(args[0])
	return brew_runtime.string_array_value(keg.relocate_dynamic_linkage(keg_relocation_from_value(args[1])) or { return brew_runtime.object_value('SystemCallError', err.msg()) })
}

// Ruby method `new_usr_local_replacement_pairs` at line 94.
pub fn ruby_keg_relocate_l94_d9_new_usr_local_replacement_pairs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.map_value(keg_replacement_pairs_value(keg_new_usr_local_pairs(relocation_keg_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }).name)))
}

// Ruby method `prepare_relocation_to_placeholders(new_usr_local_relocation: new_usr_local_relocation?)` at line 144.
pub fn ruby_keg_relocate_l144_d10_prepare_relocation_to_placeholders(args ...brew_runtime.Value) brew_runtime.Value {
	keg := relocation_keg_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	repository := if args.len > 1 { args[1].as_string() } else { keg.prefix }
	library := if args.len > 2 { args[2].as_string() } else { os.join_path(repository, 'Library') }
	return keg_relocation_value(prepare_keg_relocation_to_placeholders(keg, repository, library, args.len > 3 && args[3].bool_data))
}

// Ruby method `replace_locations_with_placeholders` at line 173.
pub fn ruby_keg_relocate_l173_d11_replace_locations_with_placeholders(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	mut keg := relocation_keg_from_value(args[0])
	relocation := prepare_keg_relocation_to_placeholders(keg, if args.len > 1 {
		args[1].as_string()
	} else {
		keg.prefix
	}, if args.len > 2 { args[2].as_string() } else { os.join_path(keg.prefix, 'Library') }, args.len > 3 && args[3].bool_data)
	return brew_runtime.string_array_value(keg.replace_text_in_files(relocation, []string{}) or { return brew_runtime.object_value('SystemCallError', err.msg()) })
}

// Ruby method `prepare_relocation_to_locations` at line 180.
pub fn ruby_keg_relocate_l180_d12_prepare_relocation_to_locations(args ...brew_runtime.Value) brew_runtime.Value {
	keg := relocation_keg_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return keg_relocation_value(prepare_keg_relocation_to_locations(keg.prefix, keg.cellar, if args.len > 1 {
		args[1].as_string()
	} else {
		keg.prefix
	}, if args.len > 2 { args[2].as_string() } else { os.join_path(keg.prefix, 'Library') }))
}

// Ruby method `replace_placeholders_with_locations(files, skip_linkage: false)` at line 195.
pub fn ruby_keg_relocate_l195_d13_replace_placeholders_with_locations(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	mut keg := relocation_keg_from_value(args[0])
	files := if args.len > 1 { args[1].as_string_array() or { []string{} } } else { []string{} }
	return brew_runtime.string_array_value(keg.replace_placeholders_with_locations(keg.prefix, keg.cellar, if args.len > 2 {
		args[2].as_string()
	} else {
		keg.prefix
	}, if args.len > 3 { args[3].as_string() } else { os.join_path(keg.prefix, 'Library') }, files, args.len > 4 && args[4].bool_data) or { return brew_runtime.object_value('SystemCallError', err.msg()) })
}

// Ruby method `openjdk_dep_name_if_applicable` at line 202.
pub fn ruby_keg_relocate_l202_d14_openjdk_dep_name_if_applicable(args ...brew_runtime.Value) brew_runtime.Value {
	dependencies := if args.len > 0 {
		args[0].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	if dependency := keg_openjdk_dependency(dependencies) {
		return brew_runtime.string_value(dependency)
	}
	return keg_relocate_nil()
}

// Ruby method `homebrew_created_file?(file)` at line 211.
pub fn ruby_keg_relocate_l211_d15_homebrew_created_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && keg_homebrew_created_file(args[0].as_string()))
}

// Ruby method `replace_text_in_files(relocation, files: nil)` at line 218.
pub fn ruby_keg_relocate_l218_d16_replace_text_in_files(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	keg := relocation_keg_from_value(args[0])
	files := if args.len > 2 { args[2].as_string_array() or { []string{} } } else { []string{} }
	return brew_runtime.string_array_value(keg.replace_text_in_files(keg_relocation_from_value(args[1]), files) or { return brew_runtime.object_value('SystemCallError', err.msg()) })
}

// Ruby method `relocate_build_prefix(keg, old_prefix, new_prefix)` at line 250.
pub fn ruby_keg_relocate_l250_d17_relocate_build_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.string_array_value([])
	}
	return brew_runtime.string_array_value(relocation_keg_from_value(args[0]).relocate_build_prefix(args[1].as_string(), args[2].as_string()) or { return brew_runtime.object_value('RuntimeError', err.msg()) })
}

// Ruby method `detect_cxx_stdlibs(_options = {})` at line 290.
pub fn ruby_keg_relocate_l290_d18_detect_cxx_stdlibs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value([])
}

// Ruby method `recursive_fgrep_args` at line 295.
pub fn ruby_keg_relocate_l295_d19_recursive_fgrep_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('-lr')
}

// Ruby method `egrep_args` at line 301.
pub fn ruby_keg_relocate_l301_d20_egrep_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value([brew_runtime.string_value('grep'), brew_runtime.string_array_value([
		'--files-with-matches',
		'--perl-regexp',
		'--binary-files=text',
	])])
}

// Ruby method `each_unique_file_matching(string, &_block)` at line 313.
pub fn ruby_keg_relocate_l313_d21_each_unique_file_matching(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	return brew_runtime.string_array_value(keg_each_unique_file_matching(relocation_keg_from_value(args[0]), args[1].as_string()))
}

// Ruby method `binary_file?(file)` at line 330.
pub fn ruby_keg_relocate_l330_d22_binary_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && keg_binary_file(args[args.len - 1].as_string()))
}

// Ruby method `lib` at line 340.
pub fn ruby_keg_relocate_l340_d23_lib(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', os.join_path(relocation_keg_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }).path, 'lib'))
}

// Ruby method `libexec` at line 345.
pub fn ruby_keg_relocate_l345_d24_libexec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', os.join_path(relocation_keg_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }).path, 'libexec'))
}

// Ruby method `text_files` at line 350.
pub fn ruby_keg_relocate_l350_d25_text_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(keg_text_files(relocation_keg_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })))
}

// Ruby method `libtool_files` at line 392.
pub fn ruby_keg_relocate_l392_d26_libtool_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(keg_libtool_files(relocation_keg_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })))
}

// Ruby method `symlink_files` at line 404.
pub fn ruby_keg_relocate_l404_d27_symlink_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(keg_symlink_files(relocation_keg_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })))
}

// Ruby method `self.text_matches_in_file(file, string, ignores, linked_libraries, formula_and_runtime_deps_names)` at line 417.
pub fn ruby_keg_relocate_l417_d28_self_text_matches_in_file(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.array_value([])
	}
	ignores := if args.len > 2 { args[2].as_string_array() or { []string{} } } else { []string{} }
	linked := if args.len > 3 { args[3].as_string_array() or { []string{} } } else { []string{} }
	dependencies := if args.len > 4 {
		args[4].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	matches := keg_text_matches_in_file(args[0].as_string(), args[1].as_string(), ignores, linked, dependencies) or { return brew_runtime.object_value('SystemCallError', err.msg()) }
	return brew_runtime.array_value(matches.map(brew_runtime.string_array_value(it)))
}

// Ruby method `self.file_linked_libraries(_file, _string)` at line 458.
pub fn ruby_keg_relocate_l458_d29_self_file_linked_libraries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value([])
}

// Ruby method `new_usr_local_relocation?` at line 465.
pub fn ruby_keg_relocate_l465_d30_new_usr_local_relocation(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 0 { args[0].as_string() } else { '' }
	formula_present := args.len > 1 && args[1].bool_data
	tap_present := args.len > 2 && args[2].bool_data
	disabled := args.len > 3 && args[3].bool_data
	return brew_runtime.bool_value(prefix == '/usr/local' && (!formula_present || !tap_present || !disabled))
}

fn relocation_keg_from_value(value brew_runtime.Value) Keg {
	values := value.map_data.clone()
	path := (values['path'] or { brew_runtime.string_value(value.as_string()) }).as_string()
	cellar := (values['cellar'] or { brew_runtime.string_value(os.dir(os.dir(path))) }).as_string()
	prefix := (values['prefix'] or { brew_runtime.string_value(os.dir(cellar)) }).as_string()
	return Keg{ path: path, name: (values['name'] or { brew_runtime.string_value(os.base(os.dir(path))) }).as_string(), prefix: prefix, cellar: cellar }
}

pub fn keg_relocation_keg_value(keg Keg) brew_runtime.Value {
	return brew_runtime.map_value({
		'path':   brew_runtime.string_value(keg.path)
		'name':   brew_runtime.string_value(keg.name)
		'prefix': brew_runtime.string_value(keg.prefix)
		'cellar': brew_runtime.string_value(keg.cellar)
	})
}

fn keg_relocation_from_value(value brew_runtime.Value) KegRelocation {
	mut relocation := new_keg_relocation()
	if value.type_name != 'Hash' {
		return relocation
	}
	for key, entry in value.map_data {
		if entry.type_name != 'Hash' {
			continue
		}
		values := entry.map_data.clone()
		relocation.add_replacement_pair_with_path(key, (values['old'] or { brew_runtime.string_value('') }).as_string(), (values['new'] or { brew_runtime.string_value('') }).as_string(), (values['path'] or { brew_runtime.bool_value(false) }).bool_data)
	}
	return relocation
}

pub fn keg_relocation_value(relocation KegRelocation) brew_runtime.Value {
	return brew_runtime.map_value(keg_replacement_pairs_value(relocation.replacement_map))
}

fn keg_replacement_pairs_value(pairs map[string]KegReplacementPair) map[string]brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	for key, pair in pairs {
		values[key] = keg_replacement_pair_value(pair)
	}
	return values
}

fn keg_replacement_pair_value(pair KegReplacementPair) brew_runtime.Value {
	return brew_runtime.map_value({
		'old':  brew_runtime.string_value(pair.old_value)
		'new':  brew_runtime.string_value(pair.new_value)
		'path': brew_runtime.bool_value(pair.path)
	})
}

fn keg_relocate_nil() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: class Keg
// 7:   extend Utils::Output::Mixin
// 8:
// 9:   PREFIX_PLACEHOLDER = "@@HOMEBREW_PREFIX@@"
// 10:   CELLAR_PLACEHOLDER = "@@HOMEBREW_CELLAR@@"
// 11:   REPOSITORY_PLACEHOLDER = "@@HOMEBREW_REPOSITORY@@"
// 12:   LIBRARY_PLACEHOLDER = "@@HOMEBREW_LIBRARY@@"
// 13:   PERL_PLACEHOLDER = "@@HOMEBREW_PERL@@"
// 14:   JAVA_PLACEHOLDER = "@@HOMEBREW_JAVA@@"
// 15:   NULL_BYTE = "\x00"
// 16:   NULL_BYTE_STRING = "\\x00"
// 17:
// 18:   class Relocation
// 19:     RELOCATABLE_PATH_REGEX_PREFIX = /(?:(?<=-F|-I|-L|-isystem)|(?<![a-zA-Z0-9]))/
// 20:
// 21:     sig { void }
// 22:     def initialize
// 23:       @replacement_map = T.let({}, T::Hash[Symbol, [T.any(String, Regexp), String]])
// 24:     end
// 25:
// 26:     sig { returns(Relocation) }
// 27:     def freeze
// 28:       @replacement_map.freeze
// 29:       super
// 30:     end
// 31:
// 32:     sig { params(key: Symbol, old_value: T.any(String, Regexp), new_value: String, path: T::Boolean).void }
// 33:     def add_replacement_pair(key, old_value, new_value, path: false)
// 34:       old_value = self.class.path_to_regex(old_value) if path
// 35:       @replacement_map[key] = [old_value, new_value]
// 36:     end
// 37:
// 38:     sig { params(key: Symbol).returns([T.any(String, Regexp), String]) }
// 39:     def replacement_pair_for(key)
// 40:       @replacement_map.fetch(key)
// 41:     end
// 42:
// 43:     sig { params(text: String).returns(T::Boolean) }
// 44:     def replace_text!(text)
// 45:       replacements = @replacement_map.values.to_h
// 46:
// 47:       sorted_keys = replacements.keys.sort_by do |key|
// 48:         key.is_a?(String) ? key.length : 999
// 49:       end.reverse
// 50:
// 51:       any_changed = T.let(nil, T.nilable(String))
// 52:       sorted_keys.each do |key|
// 53:         changed = text.gsub!(key, replacements.fetch(key))
// 54:         any_changed ||= changed
// 55:       end
// 56:       !any_changed.nil?
// 57:     end
// 58:
// 59:     sig { params(path: T.any(String, Regexp)).returns(Regexp) }
// 60:     def self.path_to_regex(path)
// 61:       path = case path
// 62:       when String
// 63:         Regexp.escape(path)
// 64:       when Regexp
// 65:         path.source
// 66:       end
// 67:       Regexp.new(RELOCATABLE_PATH_REGEX_PREFIX.source + path)
// 68:     end
// 69:   end
// 70:
// 71:   sig { void }
// 72:   def fix_dynamic_linkage
// 73:     symlink_files.each do |file|
// 74:       link = file.readlink
// 75:       # Don't fix relative symlinks
// 76:       next unless link.absolute?
// 77:
// 78:       link_starts_cellar = link.to_s.start_with?(HOMEBREW_CELLAR.to_s)
// 79:       link_starts_prefix = link.to_s.start_with?(HOMEBREW_PREFIX.to_s)
// 80:       next if !link_starts_cellar && !link_starts_prefix
// 81:
// 82:       new_src = link.relative_path_from(file.parent)
// 83:       file.unlink
// 84:       FileUtils.ln_s(new_src, file)
// 85:     end
// 86:   end
// 87:
// 88:   sig { params(_relocation: Relocation, skip_protodesc_cold: T::Boolean).void }
// 89:   def relocate_dynamic_linkage(_relocation, skip_protodesc_cold: false); end
// 90:
// 91:   JAVA_REGEX = %r{#{HOMEBREW_PREFIX}/opt/openjdk(@\d+(\.\d+)*)?/libexec(/openjdk\.jdk/Contents/Home)?}
// 92:
// 93:   sig { returns(T::Hash[Symbol, T::Hash[Symbol, String]]) }
// 94:   def new_usr_local_replacement_pairs
// 95:     {
// 96:       prefix:       {
// 97:         old: "/usr/local/opt",
// 98:         new: "#{PREFIX_PLACEHOLDER}/opt",
// 99:       },
// 100:       caskroom:     {
// 101:         old: "/usr/local/Caskroom",
// 102:         new: "#{PREFIX_PLACEHOLDER}/Caskroom",
// 103:       },
// 104:       etc_name:     {
// 105:         old: "/usr/local/etc/#{name}",
// 106:         new: "#{PREFIX_PLACEHOLDER}/etc/#{name}",
// 107:       },
// 108:       var_homebrew: {
// 109:         old: "/usr/local/var/homebrew",
// 110:         new: "#{PREFIX_PLACEHOLDER}/var/homebrew",
// 111:       },
// 112:       var_www:      {
// 113:         old: "/usr/local/var/www",
// 114:         new: "#{PREFIX_PLACEHOLDER}/var/www",
// 115:       },
// 116:       var_name:     {
// 117:         old: "/usr/local/var/#{name}",
// 118:         new: "#{PREFIX_PLACEHOLDER}/var/#{name}",
// 119:       },
// 120:       var_log_name: {
// 121:         old: "/usr/local/var/log/#{name}",
// 122:         new: "#{PREFIX_PLACEHOLDER}/var/log/#{name}",
// 123:       },
// 124:       var_lib_name: {
// 125:         old: "/usr/local/var/lib/#{name}",
// 126:         new: "#{PREFIX_PLACEHOLDER}/var/lib/#{name}",
// 127:       },
// 128:       var_run_name: {
// 129:         old: "/usr/local/var/run/#{name}",
// 130:         new: "#{PREFIX_PLACEHOLDER}/var/run/#{name}",
// 131:       },
// 132:       var_db_name:  {
// 133:         old: "/usr/local/var/db/#{name}",
// 134:         new: "#{PREFIX_PLACEHOLDER}/var/db/#{name}",
// 135:       },
// 136:       share_name:   {
// 137:         old: "/usr/local/share/#{name}",
// 138:         new: "#{PREFIX_PLACEHOLDER}/share/#{name}",
// 139:       },
// 140:     }
// 141:   end
// 142:
// 143:   sig { params(new_usr_local_relocation: T::Boolean).returns(Relocation) }
// 144:   def prepare_relocation_to_placeholders(new_usr_local_relocation: new_usr_local_relocation?)
// 145:     relocation = Relocation.new
// 146:
// 147:     # Use selective HOMEBREW_PREFIX replacement when HOMEBREW_PREFIX=/usr/local
// 148:     # This avoids overzealous replacement of system paths when a script refers to e.g. /usr/local/bin
// 149:     if new_usr_local_relocation
// 150:       new_usr_local_replacement_pairs.each do |key, value|
// 151:         relocation.add_replacement_pair(key, value.fetch(:old), value.fetch(:new), path: true)
// 152:       end
// 153:     else
// 154:       relocation.add_replacement_pair(:prefix, HOMEBREW_PREFIX.to_s, PREFIX_PLACEHOLDER, path: true)
// 155:     end
// 156:
// 157:     relocation.add_replacement_pair(:cellar, HOMEBREW_CELLAR.to_s, CELLAR_PLACEHOLDER, path: true)
// 158:     # when HOMEBREW_PREFIX == HOMEBREW_REPOSITORY we should use HOMEBREW_PREFIX for all relocations to avoid
// 159:     # being unable to differentiate between them.
// 160:     if HOMEBREW_PREFIX != HOMEBREW_REPOSITORY
// 161:       relocation.add_replacement_pair(:repository, HOMEBREW_REPOSITORY.to_s, REPOSITORY_PLACEHOLDER, path: true)
// 162:     end
// 163:     relocation.add_replacement_pair(:library, HOMEBREW_LIBRARY.to_s, LIBRARY_PLACEHOLDER, path: true)
// 164:     relocation.add_replacement_pair(:perl,
// 165:                                     %r{\A#![ \t]*(?:/usr/bin/perl\d\.\d+|#{HOMEBREW_PREFIX}/opt/perl/bin/perl)( |$)}o,
// 166:                                     "#!#{PERL_PLACEHOLDER}\\1")
// 167:     relocation.add_replacement_pair(:java, JAVA_REGEX, JAVA_PLACEHOLDER)
// 168:
// 169:     relocation
// 170:   end
// 171:
// 172:   sig { returns(T::Array[Pathname]) }
// 173:   def replace_locations_with_placeholders
// 174:     relocation = prepare_relocation_to_placeholders.freeze
// 175:     relocate_dynamic_linkage(relocation, skip_protodesc_cold: true)
// 176:     replace_text_in_files(relocation)
// 177:   end
// 178:
// 179:   sig { returns(Relocation) }
// 180:   def prepare_relocation_to_locations
// 181:     relocation = Relocation.new
// 182:     relocation.add_replacement_pair(:prefix, PREFIX_PLACEHOLDER, HOMEBREW_PREFIX.to_s)
// 183:     relocation.add_replacement_pair(:cellar, CELLAR_PLACEHOLDER, HOMEBREW_CELLAR.to_s)
// 184:     relocation.add_replacement_pair(:repository, REPOSITORY_PLACEHOLDER, HOMEBREW_REPOSITORY.to_s)
// 185:     relocation.add_replacement_pair(:library, LIBRARY_PLACEHOLDER, HOMEBREW_LIBRARY.to_s)
// 186:     relocation.add_replacement_pair(:perl, PERL_PLACEHOLDER, "#{HOMEBREW_PREFIX}/opt/perl/bin/perl")
// 187:     if (openjdk = openjdk_dep_name_if_applicable)
// 188:       relocation.add_replacement_pair(:java, JAVA_PLACEHOLDER, "#{HOMEBREW_PREFIX}/opt/#{openjdk}/libexec")
// 189:     end
// 190:
// 191:     relocation
// 192:   end
// 193:
// 194:   sig { params(files: T.nilable(T::Array[Pathname]), skip_linkage: T::Boolean).void }
// 195:   def replace_placeholders_with_locations(files, skip_linkage: false)
// 196:     relocation = prepare_relocation_to_locations.freeze
// 197:     relocate_dynamic_linkage(relocation) unless skip_linkage
// 198:     replace_text_in_files(relocation, files:)
// 199:   end
// 200:
// 201:   sig { returns(T.nilable(String)) }
// 202:   def openjdk_dep_name_if_applicable
// 203:     deps = runtime_dependencies
// 204:     return if deps.blank?
// 205:
// 206:     dep_names = deps.map { |d| d["full_name"] }
// 207:     dep_names.find { |d| d.match? Version.formula_optionally_versioned_regex(:openjdk) }
// 208:   end
// 209:
// 210:   sig { params(file: Pathname).returns(T::Boolean) }
// 211:   def homebrew_created_file?(file)
// 212:     return false unless file.basename.to_s.start_with?("homebrew.")
// 213:
// 214:     %w[.plist .service .timer].include?(file.extname)
// 215:   end
// 216:
// 217:   sig { params(relocation: Relocation, files: T.nilable(T::Array[Pathname])).returns(T::Array[Pathname]) }
// 218:   def replace_text_in_files(relocation, files: nil)
// 219:     files ||= text_files | libtool_files
// 220:
// 221:     changed_files = T.let([], T::Array[Pathname])
// 222:     files.map { path.join(it) }.group_by { |f| f.stat.ino }.each_value do |first, *rest|
// 223:       first = T.must(first)
// 224:       s = first.open("rb", &:read)
// 225:
// 226:       # Use full prefix replacement for Homebrew-created files when using selective relocation
// 227:       file_relocation = if new_usr_local_relocation? && homebrew_created_file?(first)
// 228:         prepare_relocation_to_placeholders(new_usr_local_relocation: false)
// 229:       else
// 230:         relocation
// 231:       end
// 232:       next unless file_relocation.replace_text!(s)
// 233:
// 234:       changed_files += [first, *rest].map { |file| file.relative_path_from(path) }
// 235:
// 236:       begin
// 237:         first.atomic_write(s)
// 238:       rescue SystemCallError
// 239:         first.ensure_writable do
// 240:           first.open("wb") { |f| f.write(s) }
// 241:         end
// 242:       else
// 243:         rest.each { |file| FileUtils.ln(first, file, force: true) }
// 244:       end
// 245:     end
// 246:     changed_files
// 247:   end
// 248:
// 249:   sig { params(keg: Keg, old_prefix: T.any(String, Pathname), new_prefix: T.any(String, Pathname)).void }
// 250:   def relocate_build_prefix(keg, old_prefix, new_prefix)
// 251:     each_unique_file_matching(old_prefix) do |file|
// 252:       # Skip files which are not binary, as they do not need null padding.
// 253:       next unless keg.binary_file?(file)
// 254:
// 255:       # Skip sharballs, which appear to break if patched.
// 256:       next if file.text_executable?
// 257:
// 258:       # Split binary by null characters into array and substitute new prefix for old prefix.
// 259:       # Null padding is added if the new string is too short.
// 260:       file.ensure_writable do
// 261:         binary = File.binread file
// 262:         odebug "Replacing build prefix in: #{file}"
// 263:         binary_strings = binary.split(/#{NULL_BYTE}/o, -1)
// 264:         match_indices = binary_strings.each_index.select { |i| binary_strings.fetch(i).include?(old_prefix.to_s) }
// 265:
// 266:         # Only perform substitution on strings which match prefix regex.
// 267:         match_indices.each do |i|
// 268:           s = binary_strings.fetch(i)
// 269:           binary_strings[i] = s.gsub(old_prefix.to_s, new_prefix.to_s)
// 270:                                .ljust(s.size, NULL_BYTE)
// 271:         end
// 272:
// 273:         # Rejoin strings by null bytes.
// 274:         patched_binary = binary_strings.join(NULL_BYTE)
// 275:         if patched_binary.size != binary.size
// 276:           raise <<~EOS
// 277:             Patching failed!  Original and patched binary sizes do not match.
// 278:             Original size: #{binary.size}
// 279:             Patched size: #{patched_binary.size}
// 280:           EOS
// 281:         end
// 282:
// 283:         file.atomic_write patched_binary
// 284:       end
// 285:       codesign_patched_binary(file.to_s)
// 286:     end
// 287:   end
// 288:
// 289:   sig { params(_options: T::Hash[Symbol, T::Boolean]).returns(T::Array[Symbol]) }
// 290:   def detect_cxx_stdlibs(_options = {})
// 291:     []
// 292:   end
// 293:
// 294:   sig { returns(String) }
// 295:   def recursive_fgrep_args
// 296:     # for GNU grep; overridden for BSD grep on OS X
// 297:     "-lr"
// 298:   end
// 299:
// 300:   sig { returns([String, T::Array[String]]) }
// 301:   def egrep_args
// 302:     grep_bin = "grep"
// 303:     grep_args = [
// 304:       "--files-with-matches",
// 305:       "--perl-regexp",
// 306:       "--binary-files=text",
// 307:     ]
// 308:
// 309:     [grep_bin, grep_args]
// 310:   end
// 311:
// 312:   sig { params(string: T.any(String, Pathname), _block: T.proc.params(arg0: Pathname).void).void }
// 313:   def each_unique_file_matching(string, &_block)
// 314:     Utils.popen_read("fgrep", recursive_fgrep_args, string, to_s) do |io|
// 315:       hardlinks = Set.new
// 316:
// 317:       until io.eof?
// 318:         file = Pathname.new(io.readline.chomp)
// 319:         # Don't return symbolic links.
// 320:         next if file.symlink?
// 321:
// 322:         # To avoid returning hardlinks, only return files with unique inodes.
// 323:         # Hardlinks will have the same inode as the file they point to.
// 324:         yield file if hardlinks.add? file.stat.ino
// 325:       end
// 326:     end
// 327:   end
// 328:
// 329:   sig { params(file: Pathname).returns(T::Boolean) }
// 330:   def binary_file?(file)
// 331:     grep_bin, grep_args = egrep_args
// 332:
// 333:     # We need to pass NULL_BYTE_STRING, the literal string "\x00", to grep
// 334:     # rather than NULL_BYTE, a literal null byte, because grep will internally
// 335:     # convert the literal string "\x00" to a null byte.
// 336:     Utils.popen_read(grep_bin, *grep_args, NULL_BYTE_STRING, file).present?
// 337:   end
// 338:
// 339:   sig { returns(Pathname) }
// 340:   def lib
// 341:     path/"lib"
// 342:   end
// 343:
// 344:   sig { returns(Pathname) }
// 345:   def libexec
// 346:     path/"libexec"
// 347:   end
// 348:
// 349:   sig { returns(T::Array[Pathname]) }
// 350:   def text_files
// 351:     text_files = []
// 352:     return text_files if !which("file") || !which("xargs")
// 353:
// 354:     files = Set.new path.find.reject { |pn|
// 355:       next true if pn.symlink?
// 356:       next true if pn.directory?
// 357:       next false if pn.basename.to_s == "orig-prefix.txt" # for python virtualenvs
// 358:       next true if pn == self/".brew/#{name}.rb"
// 359:
// 360:       require "metafiles"
// 361:       next true if Metafiles::EXTENSIONS.include?(pn.extname)
// 362:
// 363:       if pn.text_executable?
// 364:         text_files << pn
// 365:         next true
// 366:       end
// 367:       false
// 368:     }
// 369:     output, _status = Open3.capture2("xargs -0 file --no-dereference --print0",
// 370:                                      stdin_data: files.to_a.join("\0"))
// 371:     # `file` output sometimes contains data from the file, which may include
// 372:     # invalid UTF-8 entities, so tell Ruby this is just a bytestring
// 373:     output.force_encoding(Encoding::ASCII_8BIT)
// 374:     output.each_line do |line|
// 375:       path, info = line.split("\0", 2)
// 376:       # `file` sometimes prints more than one line of output per file;
// 377:       # subsequent lines do not contain a null-byte separator, so `info`
// 378:       # will be `nil` for those lines
// 379:       next unless info
// 380:       next unless info.include?("text")
// 381:
// 382:       path = Pathname.new(path)
// 383:       next unless files.include?(path)
// 384:
// 385:       text_files << path
// 386:     end
// 387:
// 388:     text_files
// 389:   end
// 390:
// 391:   sig { returns(T::Array[Pathname]) }
// 392:   def libtool_files
// 393:     libtool_files = []
// 394:
// 395:     path.find do |pn|
// 396:       next if pn.symlink? || pn.directory? || Keg::LIBTOOL_EXTENSIONS.exclude?(pn.extname)
// 397:
// 398:       libtool_files << pn
// 399:     end
// 400:     libtool_files
// 401:   end
// 402:
// 403:   sig { returns(T::Array[Pathname]) }
// 404:   def symlink_files
// 405:     symlink_files = []
// 406:     path.find do |pn|
// 407:       symlink_files << pn if pn.symlink?
// 408:     end
// 409:
// 410:     symlink_files
// 411:   end
// 412:
// 413:   sig {
// 414:     params(file: Pathname, string: String, ignores: T::Array[Regexp], linked_libraries: T::Array[String],
// 415:            formula_and_runtime_deps_names: T.nilable(T::Array[String])).returns(T::Array[[String, String]])
// 416:   }
// 417:   def self.text_matches_in_file(file, string, ignores, linked_libraries, formula_and_runtime_deps_names)
// 418:     text_matches = []
// 419:     path_regex = Relocation.path_to_regex(string)
// 420:     Utils.popen_read("strings", "-t", "x", "-", file.to_s) do |io|
// 421:       until io.eof?
// 422:         str = io.readline.chomp
// 423:         next if ignores.any? { |i| str.match?(i) }
// 424:         next unless str.match? path_regex
// 425:
// 426:         offset, match = str.split(" ", 2)
// 427:         odie "Failed to parse strings output: #{str.inspect}" unless match
// 428:
// 429:         # Some binaries contain strings with lists of files
// 430:         # e.g. `/usr/local/lib/foo:/usr/local/share/foo:/usr/lib/foo`
// 431:         # Each item in the list should be checked separately
// 432:         match.split(":").each do |sub_match|
// 433:           # Not all items in the list may be matches
// 434:           next unless sub_match.match? path_regex
// 435:           next if linked_libraries.include? sub_match # Don't bother reporting a string if it was found by otool
// 436:
// 437:           # Do not report matches to files that do not exist.
// 438:           next unless File.exist? sub_match
// 439:
// 440:           # Do not report matches to build dependencies.
// 441:           if formula_and_runtime_deps_names.present?
// 442:             begin
// 443:               keg_name = Keg.for(Pathname.new(sub_match)).name
// 444:               next unless formula_and_runtime_deps_names.include? keg_name
// 445:             rescue NotAKegError
// 446:               nil
// 447:             end
// 448:           end
// 449:
// 450:           text_matches << [match, offset] unless text_matches.any? { |text| text.last == offset }
// 451:         end
// 452:       end
// 453:     end
// 454:     text_matches
// 455:   end
// 456:
// 457:   sig { params(_file: Pathname, _string: String).returns(T::Array[String]) }
// 458:   def self.file_linked_libraries(_file, _string)
// 459:     []
// 460:   end
// 461:
// 462:   private
// 463:
// 464:   sig { returns(T::Boolean) }
// 465:   def new_usr_local_relocation?
// 466:     return false if HOMEBREW_PREFIX.to_s != "/usr/local"
// 467:
// 468:     formula = begin
// 469:       Formula[name]
// 470:     rescue FormulaUnavailableError
// 471:       nil
// 472:     end
// 473:     return true unless formula
// 474:
// 475:     tap = formula.tap
// 476:     return true unless tap
// 477:
// 478:     tap.disabled_new_usr_local_relocation_formulae.exclude?(name)
// 479:   end
// 480: end
// 481:
// 482: require "extend/os/keg_relocate"
