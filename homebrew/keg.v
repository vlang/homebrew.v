module homebrew

import ruby
import hash.fnv1a
import os

// Translated from Homebrew/brew `keg.rb`.
pub const keg_link_directories = ['bin', 'etc', 'include', 'lib', 'sbin', 'share', 'var']
pub const keg_keepme_file = '.keepme'

pub struct Keg {
pub:
	path              string
	name              string
	linked_keg_record string
	opt_record        string
	prefix            string
	cellar            string
pub mut:
	require_relocation bool
}

pub struct KegLinkError {
pub:
	keg      Keg
	src      string
	dst      string
	cause    string
	conflict bool
}

fn configured_keg_prefix() string {
	return ruby.environment_value('HOMEBREW_PREFIX')
}

fn configured_keg_cellar(prefix string) string {
	cellar := ruby.environment_value('HOMEBREW_CELLAR')
	return if cellar == '' { ruby.join_path(prefix, 'Cellar') } else { cellar }
}

fn normalized_keg_path(path string) string {
	return ruby.real_path(path).trim_right('/')
}

pub fn new_keg(path string) !Keg {
	mut prefix := configured_keg_prefix()
	mut cellar := configured_keg_cellar(prefix)
	mut stored_path := path.trim_right('/')
	if prefix != '' && stored_path.starts_with('${prefix.trim_right('/')}/opt/') {
		stored_path = normalized_keg_path(stored_path)
	}
	if prefix == '' {
		cellar = os.dir(os.dir(stored_path))
		prefix = os.dir(cellar)
	}
	return new_keg_with_paths(stored_path, cellar, prefix)
}

pub fn new_keg_with_paths(path string, cellar string, prefix string) !Keg {
	stored_path := path.trim_right('/')
	stored_cellar := cellar.trim_right('/')
	real_path := normalized_keg_path(stored_path)
	real_cellar := normalized_keg_path(cellar)
	if normalized_keg_path(os.dir(os.dir(real_path))) != real_cellar {
		return error('${path} is not a valid keg')
	}
	if !ruby.is_dir(stored_path) {
		return error('${path} is not a directory')
	}
	name := os.base(os.dir(stored_path))
	return Keg{
		path: stored_path
		name: name
		linked_keg_record: os.join_path(prefix, 'var', 'homebrew', 'linked', name)
		opt_record: os.join_path(prefix, 'opt', name)
		prefix: prefix
		cellar: stored_cellar
	}
}

pub fn (keg Keg) rack() string {
	return os.dir(keg.path)
}

pub fn (keg Keg) str() string {
	return keg.path
}

pub fn (keg Keg) inspect() string {
	return '#<Keg:${keg.path}>'
}

pub fn (keg Keg) equal(other Keg) bool {
	return keg.path == other.path
}

pub fn (keg Keg) hash_code() u64 {
	return fnv1a.sum64_string(keg.path)
}

pub fn (keg Keg) exists() bool {
	return ruby.path_exists(keg.path)
}

pub fn (keg Keg) directory() bool {
	return ruby.is_dir(keg.path)
}

pub fn (keg Keg) join(parts ...string) string {
	mut path := keg.path
	for part in parts {
		path = ruby.join_path(path, part)
	}
	return path
}

fn keg_walk(path string) []string {
	mut found := []string{}
	entries := ruby.list_dir(path) or { return found }
	for entry in entries {
		child := ruby.join_path(path, entry)
		found << child
		if ruby.is_dir(child) && !ruby.is_link(child) {
			found << keg_walk(child)
		}
	}
	return found
}

pub fn (keg Keg) find() []string {
	return keg_walk(keg.path)
}

pub fn (keg Keg) disk_usage() u64 {
	mut total := u64(0)
	for path in keg.find() {
		if ruby.is_file(path) {
			total += os.file_size(path)
		}
	}
	return total
}

pub fn (keg Keg) file_count() int {
	return keg.find().filter(ruby.is_file(it)).len
}

pub fn (keg Keg) abbreviated_size() string {
	bytes := keg.disk_usage()
	if bytes < 1024 {
		return '${bytes}B'
	}
	if bytes < 1024 * 1024 {
		return '${f64(bytes) / 1024.0:.1f}KB'
	}
	if bytes < 1024 * 1024 * 1024 {
		return '${f64(bytes) / (1024.0 * 1024.0):.1f}MB'
	}
	return '${f64(bytes) / (1024.0 * 1024.0 * 1024.0):.1f}GB'
}

fn same_resolved_path(left string, right string) bool {
	return normalized_keg_path(left) == normalized_keg_path(right)
}

fn relative_keg_path(target string, directory string) string {
	target_parts := normalized_keg_path(target).trim_left('/').split('/')
	directory_parts := normalized_keg_path(directory).trim_left('/').split('/')
	mut common := 0
	for common < target_parts.len && common < directory_parts.len && target_parts[common] == directory_parts[common] {
		common++
	}
	mut parts := []string{cap: directory_parts.len - common + target_parts.len - common}
	for _ in common .. directory_parts.len {
		parts << '..'
	}
	parts << target_parts[common..]
	return if parts.len == 0 { '.' } else { parts.join('/') }
}

pub fn (keg Keg) linked() bool {
	return ruby.is_link(keg.linked_keg_record) && ruby.is_dir(keg.linked_keg_record) && same_resolved_path(keg.path, keg.linked_keg_record)
}

pub fn (keg Keg) optlinked() bool {
	return ruby.is_link(keg.opt_record) && same_resolved_path(keg.path, keg.opt_record)
}

pub fn (keg Keg) remove_linked_keg_record() ! {
	os.rm(keg.linked_keg_record)!
	remove_empty_parent(os.dir(keg.linked_keg_record))
}

pub fn (keg Keg) remove_opt_record() ! {
	os.rm(keg.opt_record)!
	remove_empty_parent(os.dir(keg.opt_record))
}

fn remove_empty_parent(path string) {
	entries := ruby.list_dir(path) or { return }
	if entries.len == 0 {
		os.rmdir(path) or {}
	}
}

pub fn (keg Keg) empty_installation() bool {
	entries := ruby.list_dir(keg.path) or { return true }
	for entry in entries {
		path := ruby.join_path(keg.path, entry)
		if ruby.is_dir(path) {
			children := (ruby.list_dir(path) or { []string{} }).filter(it != '.DS_Store')
			if children.len > 0 {
				return false
			}
			continue
		}
		if is_metafile_copied(entry) || entry in ['.DS_Store', tab_filename] {
			continue
		}
		return false
	}
	return true
}

pub fn keg_for_path(path string, cellar string, prefix string) !Keg {
	if !ruby.path_exists(path) {
		return error('${path} does not exist')
	}
	real_cellar := normalized_keg_path(cellar)
	mut current := normalized_keg_path(path)
	if ruby.is_file(current) {
		current = os.dir(current)
	}
	for current != os.dir(current) {
		if normalized_keg_path(os.dir(os.dir(current))) == real_cellar {
			relative := current[real_cellar.len..].trim_left('/')
			stored_path := ruby.join_path(cellar.trim_right('/'), relative)
			return new_keg_with_paths(stored_path, cellar, prefix)
		}
		current = normalized_keg_path(os.dir(current))
	}
	return error('${path} is not inside a keg')
}

pub fn keg_for(path string) !Keg {
	prefix := configured_keg_prefix()
	return keg_for_path(path, configured_keg_cellar(prefix), prefix)
}

pub fn keg_from_rack_with_paths(rack string, cellar string, prefix string) ?Keg {
	if !ruby.is_dir(rack) {
		return none
	}
	mut kegs := []Keg{}
	for entry in ruby.list_dir(rack) or { return none } {
		path := ruby.join_path(rack, entry)
		if ruby.is_dir(path) {
			if keg := new_keg_with_paths(path, cellar, prefix) {
				kegs << keg
			}
		}
	}
	for keg in kegs {
		if keg.linked() {
			return keg
		}
	}
	for keg in kegs {
		if keg.optlinked() {
			return keg
		}
	}
	if kegs.len == 0 {
		return none
	}
	mut selected := kegs[0]
	for keg in kegs[1..] {
		if keg.compare_scheme_and_version(selected) > 0 {
			selected = keg
		}
	}
	return selected
}

pub fn keg_from_rack(rack string) ?Keg {
	prefix := configured_keg_prefix()
	return keg_from_rack_with_paths(rack, configured_keg_cellar(prefix), prefix)
}

pub fn installed_tab_for_name_with_paths(name string, cellar string, prefix string) ?Tab {
	rack := ruby.join_path(cellar, name)
	keg := keg_from_rack_with_paths(rack, cellar, prefix) or { return none }
	return keg.tab() or { return none }
}

pub fn installed_tab_for_name(name string) ?Tab {
	prefix := configured_keg_prefix()
	return installed_tab_for_name_with_paths(name, configured_keg_cellar(prefix), prefix)
}

pub fn all_kegs(cellar string, prefix string) []Keg {
	mut kegs := []Keg{}
	for rack_name in ruby.list_dir(cellar) or { return kegs } {
		rack := ruby.join_path(cellar, rack_name)
		if !ruby.is_dir(rack) {
			continue
		}
		for version in ruby.list_dir(rack) or { continue } {
			if keg := new_keg_with_paths(ruby.join_path(rack, version), cellar, prefix) {
				kegs << keg
			}
		}
	}
	return kegs
}

pub fn keg_must_exist_subdirectories(prefix string) []string {
	mut paths := keg_link_directories.filter(it != 'var').map(ruby.join_path(prefix, it))
	paths << ruby.join_path(prefix, 'opt')
	paths << os.join_path(prefix, 'var', 'homebrew', 'linked')
	paths.sort()
	return paths
}

pub fn keg_must_exist_directories(prefix string, cellar string) []string {
	mut paths := keg_must_exist_subdirectories(prefix)
	if cellar !in paths {
		paths << cellar
	}
	paths.sort()
	return paths
}

pub fn (keg Keg) tab() !Tab {
	return tab_for_keg(keg.path)
}

pub fn (keg Keg) runtime_dependencies() ?[]RuntimeDependencyReceipt {
	tab := keg.tab() or { return none }
	return tab.runtime_dependencies()
}

pub fn (keg Keg) aliases() []string {
	tab := keg.tab() or { return []string{} }
	return if tab.has_aliases { tab.aliases.clone() } else { []string{} }
}

pub fn (keg Keg) version() !PkgVersion {
	return parse_pkg_version(os.base(keg.path))
}

pub fn (keg Keg) version_scheme() int {
	tab := keg.tab() or { return 0 }
	return tab.version_scheme()
}

pub fn (keg Keg) compare_scheme_and_version(other Keg) int {
	if keg.version_scheme() != other.version_scheme() {
		return if keg.version_scheme() < other.version_scheme() { -1 } else { 1 }
	}
	left := keg.version() or { return -1 }
	right := other.version() or { return 1 }
	return left.compare_to(right)
}

pub fn (keg Keg) completion_installed(shell string) bool {
	path := match shell.trim_left(':') {
		'bash' { keg.join('etc/bash_completion.d') }
		'fish' { keg.join('share/fish/vendor_completions.d') }
		'zsh' { keg.join('share/zsh/site-functions') }
		'pwsh' { keg.join('share/pwsh/completions') }
		else {
			return false
		}
	}
	entries := ruby.list_dir(path) or { return false }
	if shell.trim_left(':') == 'zsh' {
		return entries.any(it.starts_with('_'))
	}
	return ruby.is_dir(path) && entries.len > 0
}

pub fn (keg Keg) functions_installed(shell string) bool {
	match shell.trim_left(':') {
		'fish' {
			path := keg.join('share/fish/vendor_functions.d')
			return ruby.is_dir(path) && (ruby.list_dir(path) or { []string{} }).len > 0
		}
		'zsh' {
			path := keg.join('share/zsh/site-functions')
			return ruby.is_dir(path) && (ruby.list_dir(path) or { []string{} }).any(!it.starts_with('_'))
		}
		else {
			return false
		}
	}
}

pub fn (keg Keg) plist_installed() bool {
	return (ruby.list_dir(keg.path) or { []string{} }).any(it.ends_with('.plist'))
}

pub fn (keg Keg) apps() []string {
	base := if keg.optlinked() { keg.opt_record } else { keg.path }
	mut apps := []string{}
	for directory in [base, ruby.join_path(base, 'libexec')] {
		for entry in ruby.list_dir(directory) or { continue } {
			if entry.ends_with('.app') {
				apps << ruby.join_path(directory, entry)
			}
		}
	}
	return apps
}

pub fn (keg Keg) elisp_installed() bool {
	directory := os.join_path(keg.path, 'share', 'emacs', 'site-lisp', keg.name)
	return (ruby.list_dir(directory) or { []string{} }).any(it.ends_with('.el') || it.ends_with('.elc'))
}

pub fn (keg Keg) oldname_opt_records() []string {
	directory := os.dir(keg.opt_record)
	mut records := []string{}
	for entry in ruby.list_dir(directory) or { return records } {
		record := ruby.join_path(directory, entry)
		if record != keg.opt_record && ruby.is_link(record) && normalized_keg_path(os.dir(normalized_keg_path(record))) == normalized_keg_path(keg.rack()) {
			records << record
		}
	}
	return records
}

fn remove_existing_link_target(path string) ! {
	if ruby.is_link(path) || ruby.is_file(path) {
		os.rm(path)!
	} else if ruby.is_dir(path) {
		os.rmdir(path)!
	}
}

pub fn make_relative_keg_symlink(dst string, src string, dry_run bool, overwrite bool) !bool {
	if ruby.path_exists(dst) || ruby.is_link(dst) {
		if ruby.is_link(dst) && ruby.path_exists(dst) && same_resolved_path(dst, src) {
			return false
		}
		if !overwrite && !ruby.is_link(dst) {
			return error('Target ${dst} already exists')
		}
		if !dry_run {
			remove_existing_link_target(dst)!
		}
	}
	if dry_run {
		println(dst)
		return false
	}
	os.mkdir_all(os.dir(dst))!
	relative := relative_keg_path(src, os.dir(dst))
	os.symlink(relative, dst)!
	return true
}

pub fn (keg Keg) optlink(dry_run bool, overwrite bool) ! {
	make_relative_keg_symlink(keg.opt_record, keg.path, dry_run, true)!
	for alias in keg.aliases() {
		make_relative_keg_symlink(ruby.join_path(os.dir(keg.opt_record), alias), keg.path, dry_run, true)!
	}
	for record in keg.oldname_opt_records() {
		make_relative_keg_symlink(record, keg.path, dry_run, true)!
	}
}

fn (keg Keg) link_tree(src_root string, dry_run bool, overwrite bool) !int {
	mut count := 0
	for src in keg_walk(src_root) {
		relative := relative_keg_path(src, keg.path)
		dst := ruby.join_path(keg.prefix, relative)
		if ruby.is_dir(src) && !ruby.is_link(src) {
			if !dry_run {
				os.mkdir_all(dst)!
			}
			continue
		}
		if make_relative_keg_symlink(dst, src, dry_run, overwrite)! {
			count++
		}
	}
	return count
}

pub fn (keg Keg) link(dry_run bool, overwrite bool) !int {
	if ruby.is_dir(keg.linked_keg_record) {
		return error('Cannot link ${keg.name}\nAnother version is already linked: ${normalized_keg_path(keg.linked_keg_record)}')
	}
	if !dry_run {
		keg.optlink(false, overwrite)!
	}
	mut count := 0
	for directory in keg_link_directories {
		source := keg.join(directory)
		if ruby.path_exists(source) {
			count += keg.link_tree(source, dry_run, overwrite)!
		}
	}
	if !dry_run {
		make_relative_keg_symlink(keg.linked_keg_record, keg.path, false, overwrite)!
	}
	return count
}

pub fn (keg Keg) unlink(dry_run bool) !int {
	mut count := 0
	for directory in keg_link_directories {
		source_root := keg.join(directory)
		for src in keg_walk(source_root) {
			dst := ruby.join_path(keg.prefix, relative_keg_path(src, keg.path))
			if ruby.is_link(dst) && same_resolved_path(src, dst) {
				if dry_run {
					println(dst)
				} else {
					os.rm(dst)!
				}
				count++
			}
		}
	}
	if !dry_run && keg.linked() {
		keg.remove_linked_keg_record()!
	}
	return count
}

pub fn (keg Keg) remove_oldname_opt_records() ! {
	for record in keg.oldname_opt_records() {
		if same_resolved_path(record, keg.path) {
			os.rm(record)!
			remove_empty_parent(os.dir(record))
		}
	}
}

pub fn remove_keg_alias_symlink(alias_symlink string, alias_match_path string) ! {
	if ruby.is_link(alias_symlink) {
		if !ruby.path_exists(alias_symlink) || (ruby.path_exists(alias_match_path) && same_resolved_path(alias_symlink, alias_match_path)) {
			os.rm(alias_symlink)!
		}
	} else if ruby.path_exists(alias_symlink) {
		remove_existing_link_target(alias_symlink)!
	}
}

pub fn (keg Keg) remove_old_aliases() ! {
	opt_directory := os.dir(keg.opt_record)
	linked_directory := os.dir(keg.linked_keg_record)
	aliases := keg.aliases()
	for alias in aliases {
		if alias.contains('@') {
			continue
		}
		remove_keg_alias_symlink(ruby.join_path(opt_directory, alias), keg.opt_record)!
		remove_keg_alias_symlink(ruby.join_path(linked_directory, alias), keg.linked_keg_record)!
	}
	for entry in ruby.list_dir(opt_directory) or { []string{} } {
		if !entry.starts_with('${keg.name}@') || entry in aliases {
			continue
		}
		remove_keg_alias_symlink(ruby.join_path(opt_directory, entry), keg.rack())!
		remove_keg_alias_symlink(ruby.join_path(linked_directory, entry), keg.rack())!
	}
}

pub fn (keg Keg) uninstall() ! {
	was_optlinked := keg.optlinked()
	was_linked := keg.linked()
	oldname_records := keg.oldname_opt_records()
	os.rmdir_all(keg.path)!
	remove_empty_parent(keg.rack())
	if was_optlinked {
		keg.remove_opt_record()!
	}
	if was_linked {
		keg.remove_linked_keg_record()!
	}
	keg.remove_old_aliases()!
	for record in oldname_records {
		if ruby.is_link(record) {
			os.rm(record)!
		}
	}
}

pub fn (keg Keg) keepme_refs() []string {
	keepme := keg.join(keg_keepme_file)
	content := ruby.read_file(keepme) or { return []string{} }
	return content.split_into_lines().map(it.trim_space()).filter(it != '' && ruby.path_exists(it))
}

pub fn (keg Keg) delete_pyc_files() ! {
	mut cache_directories := []string{}
	for path in keg.find() {
		if path.ends_with('.pyc') || path.ends_with('.pyo') {
			os.rm(path)!
		} else if os.base(path) == '__pycache__' && ruby.is_dir(path) {
			cache_directories << path
		}
	}
	cache_directories.sort(a.len > b.len)
	for directory in cache_directories {
		os.rmdir_all(directory)!
	}
}

fn pod2man_parts(line string) []string {
	mut parts := []string{}
	mut current := ''
	mut quoted := false
	for character in line {
		if character == `"` {
			quoted = !quoted
			current += character.ascii_str()
		} else if character.is_space() && !quoted {
			if current != '' {
				parts << current
				current = ''
			}
		} else {
			current += character.ascii_str()
		}
	}
	if current != '' {
		parts << current
	}
	return parts
}

fn normalized_man_section(value string) string {
	mut result := value
	for digit in 1 .. 10 {
		result = result.replace('${digit}pm', '${digit}').replace('${digit}p', '${digit}')
	}
	return result
}

fn is_uncompressed_manpage(path string) bool {
	extension := os.file_ext(path).trim_left('.')
	return extension.len > 0 && extension[0] >= `1` && extension[0] <= `9` && extension[1..] in ['',
		'p', 'pm']
}

pub fn (keg Keg) normalize_pod2man_outputs() ! {
	man_root := keg.join('share/man')
	for manpage in keg_walk(man_root) {
		if !ruby.is_file(manpage) || !is_uncompressed_manpage(manpage) {
			continue
		}
		content := ruby.read_file(manpage)!
		mut lines := content.split_into_lines()
		if lines.len > 0 && lines[0].starts_with('.\\"') && lines[0].contains('Automatically generated by ') {
			lines.delete(0)
		}
		for index, line in lines {
			mut parts := pod2man_parts(line)
			if line.starts_with('.TH') && parts.len == 6 {
				if parts[4].starts_with('"perl v') && parts[4].ends_with('"') {
					parts[4] = '""'
				}
				parts[2] = normalized_man_section(parts[2])
				lines[index] = parts.join(' ')
			} else if line.starts_with('.IX') && parts.len == 3 && parts[1] == 'Title' {
				parts[2] = normalized_man_section(parts[2])
				lines[index] = parts.join(' ')
			}
		}
		ending := if content.ends_with('\n') { '\n' } else { '' }
		os.write_file(manpage, lines.join('\n') + ending)!
	}
}

fn keg_link_error_value(link_error KegLinkError) ruby.Value {
	return ruby.structured_value(if link_error.conflict {
		'Keg::ConflictError'
	} else {
		'Keg::LinkError'
	}, link_error.cause, {
		'keg':    link_error.keg.path
		'prefix': link_error.keg.prefix
		'cellar': link_error.keg.cellar
		'src':    link_error.src
		'dst':    link_error.dst
		'cause':  link_error.cause
	})
}

fn keg_link_error_from_boundary(value ruby.Value) KegLinkError {
	path := value.attribute('keg') or { panic('Keg link error has no keg') }
	prefix := value.attribute('prefix') or { configured_keg_prefix() }
	cellar := value.attribute('cellar') or { configured_keg_cellar(prefix) }
	return KegLinkError{
		keg: new_keg_with_paths(path, cellar, prefix) or { panic(err) }
		src: value.attribute('src') or { '' }
		dst: value.attribute('dst') or { '' }
		cause: value.attribute('cause') or { value.as_string() }
		conflict: value.type_name == 'Keg::ConflictError'
	}
}

fn keg_boundary_value(keg Keg) ruby.Value {
	return ruby.structured_value('Keg', keg.path, {
		'path':               keg.path
		'prefix':             keg.prefix
		'cellar':             keg.cellar
		'name':               keg.name
		'linked_keg_record':  keg.linked_keg_record
		'opt_record':         keg.opt_record
		'require_relocation': keg.require_relocation.str()
	})
}

fn keg_from_boundary(value ruby.Value) Keg {
	if value.type_name != 'Keg' {
		panic('expected Keg, got ${value.type_name}')
	}
	path := value.attribute('path') or { value.as_string() }
	prefix := value.attribute('prefix') or { configured_keg_prefix() }
	cellar := value.attribute('cellar') or { configured_keg_cellar(prefix) }
	mut keg := new_keg_with_paths(path, cellar, prefix) or { panic(err) }
	keg.require_relocation = (value.attribute('require_relocation') or { 'false' }) == 'true'
	return keg
}

fn keg_receiver(args []ruby.Value, method string) Keg {
	if args.len == 0 {
		panic('Keg#${method} requires a receiver')
	}
	return keg_from_boundary(args[0])
}

fn keg_array_value(kegs []Keg) ruby.Value {
	return ruby.array_value(kegs.map(keg_boundary_value(it)))
}

fn keg_bool_argument(args []ruby.Value, index int) bool {
	return index < args.len && args[index].type_name == 'Boolean' && (args[index].as_bool() or {
		false
	})
}
