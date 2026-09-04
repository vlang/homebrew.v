module homebrew

import ruby
import hash.fnv1a
import json2
import os

// Translated from Homebrew/brew `keg.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `initialize(keg)` at line 22.
pub fn ruby_keg_l22_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('AlreadyLinkedError#initialize requires a keg') }
	keg := keg_from_boundary(args[0])
	return ruby.object_value('Keg::AlreadyLinkedError', 'Cannot link ${keg.name}\nAnother version is already linked: ${normalized_keg_path(keg.linked_keg_record)}\n')
}

// Ruby attr_reader `attr_reader :keg` at line 33.
pub fn ruby_keg_l33_d2_keg(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('LinkError#keg requires a receiver') }
	return keg_boundary_value(keg_link_error_from_boundary(args[0]).keg)
}

// Ruby attr_reader `attr_reader :src, :dst` at line 36.
pub fn ruby_keg_l36_d3_src(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('LinkError#src requires a receiver') }
	return ruby.string_value(keg_link_error_from_boundary(args[0]).src)
}

// Ruby attr_reader `attr_reader :src, :dst` at line 36.
pub fn ruby_keg_l36_d4_dst(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('LinkError#dst requires a receiver') }
	return ruby.string_value(keg_link_error_from_boundary(args[0]).dst)
}

// Ruby method `initialize(keg, src, dst, cause)` at line 39.
pub fn ruby_keg_l39_d5_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 4 { panic('LinkError#initialize requires keg, src, dst, and cause') }
	return keg_link_error_value(KegLinkError{
		keg: keg_from_boundary(args[0])
		src: args[1].as_string()
		dst: args[2].as_string()
		cause: args[3].as_string()
	})
}

// Ruby method `suggestion` at line 52.
pub fn ruby_keg_l52_d6_suggestion(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ConflictError#suggestion requires a receiver') }
	link_error := keg_link_error_from_boundary(args[0])
	conflict := keg_for_path(link_error.dst, link_error.keg.cellar, link_error.keg.prefix) or {
		return ruby.string_value("already exists. You may want to remove it:\n  rm '${link_error.dst}'\n")
	}
	return ruby.string_value('is a symlink belonging to ${conflict.name}. You can unlink it:\n  brew unlink ${conflict.name}\n')
}

// Ruby method `to_s` at line 64.
pub fn ruby_keg_l64_d7_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ConflictError#to_s requires a receiver') }
	link_error := keg_link_error_from_boundary(args[0])
	suggestion := ruby_keg_l52_d6_suggestion(...args).as_string()
	return ruby.string_value('Could not symlink ${link_error.src}\nTarget ${link_error.dst}\n${suggestion}\nTo force the link and overwrite all conflicting files:\n  brew link --overwrite ${link_error.keg.name}\n\nTo list all files that would be deleted:\n  brew link --overwrite ${link_error.keg.name} --dry-run\n')
}

// Ruby method `to_s` at line 82.
pub fn ruby_keg_l82_d8_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('DirectoryNotWritableError#to_s requires a receiver') }
	link_error := keg_link_error_from_boundary(args[0])
	return ruby.string_value('Could not symlink ${link_error.src}\n${os.dir(link_error.dst)} is not writable.\n')
}

// Ruby method `self.for(path)` at line 115.
pub fn ruby_keg_l115_d9_self_for(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Keg.for requires a path') }
	return keg_boundary_value(keg_for(args[0].as_string()) or { panic(err) })
}

// Ruby method `self.from_rack(rack)` at line 130.
pub fn ruby_keg_l130_d10_self_from_rack(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Keg.from_rack requires a rack') }
	if keg := keg_from_rack(args[0].as_string()) {
		return keg_boundary_value(keg)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.all` at line 138.
pub fn ruby_keg_l138_d11_self_all(args ...ruby.Value) ruby.Value {
	prefix := configured_keg_prefix()
	return keg_array_value(all_kegs(configured_keg_cellar(prefix), prefix))
}

// Ruby method `self.keg_link_directories` at line 143.
pub fn ruby_keg_l143_d12_self_keg_link_directories(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(keg_link_directories)
}

// Ruby method `self.must_exist_subdirectories` at line 150.
pub fn ruby_keg_l150_d13_self_must_exist_subdirectories(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(keg_must_exist_subdirectories(configured_keg_prefix()))
}

// Ruby method `self.must_exist_directories` at line 160.
pub fn ruby_keg_l160_d14_self_must_exist_directories(args ...ruby.Value) ruby.Value {
	prefix := configured_keg_prefix()
	return ruby.string_array_value(keg_must_exist_directories(prefix, configured_keg_cellar(prefix)))
}

// Ruby method `self.must_be_writable_directories` at line 169.
pub fn ruby_keg_l169_d15_self_must_be_writable_directories(args ...ruby.Value) ruby.Value {
	prefix := configured_keg_prefix()
	mut paths := keg_must_exist_directories(prefix, configured_keg_cellar(prefix))
	for relative in ['etc/bash_completion.d', 'lib/cps', 'lib/pkgconfig', 'share/aclocal', 'share/doc',
		'share/info', 'share/locale', 'share/man', 'share/cps', 'share/zsh',
		'share/zsh/site-functions', 'share/pwsh', 'share/pwsh/completions', 'var/log'] {
		path := ruby.join_path(prefix, relative)
		if path !in paths { paths << path }
	}
	paths.sort()
	return ruby.string_array_value(paths)
}

// Ruby attr_reader `attr_reader :name` at line 189.
pub fn ruby_keg_l189_d16_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(keg_receiver(args, 'name').name)
}

// Ruby attr_reader `attr_reader :path, :linked_keg_record, :opt_record` at line 192.
pub fn ruby_keg_l192_d17_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(keg_receiver(args, 'path').path)
}

// Ruby attr_reader `attr_reader :path, :linked_keg_record, :opt_record` at line 192.
pub fn ruby_keg_l192_d18_linked_keg_record(args ...ruby.Value) ruby.Value {
	return ruby.string_value(keg_receiver(args, 'linked_keg_record').linked_keg_record)
}

// Ruby attr_reader `attr_reader :path, :linked_keg_record, :opt_record` at line 192.
pub fn ruby_keg_l192_d19_opt_record(args ...ruby.Value) ruby.Value {
	return ruby.string_value(keg_receiver(args, 'opt_record').opt_record)
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d20_to_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(keg_receiver(args, 'to_path').path)
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d21_hash(args ...ruby.Value) ruby.Value {
	return ruby.int_value(i64(keg_receiver(args, 'hash').hash_code()))
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d22_abv(args ...ruby.Value) ruby.Value {
	return ruby.string_value(keg_receiver(args, 'abv').abbreviated_size())
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d23_disk_usage(args ...ruby.Value) ruby.Value {
	return ruby.int_value(i64(keg_receiver(args, 'disk_usage').disk_usage()))
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d24_file_count(args ...ruby.Value) ruby.Value {
	return ruby.int_value(keg_receiver(args, 'file_count').file_count())
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d25_directory(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(keg_receiver(args, 'directory?').directory())
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d26_exist(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(keg_receiver(args, 'exist?').exists())
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d27_join(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Keg#join requires a path') }
	return ruby.string_value(keg_receiver(args, 'join').join(...args[1..].map(it.as_string())))
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d28_rename(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Keg#rename requires a destination') }
	keg := keg_receiver(args, 'rename')
	os.rename(keg.path, args[1].as_string()) or { panic(err) }
	return ruby.string_value(args[1].as_string())
}

// Ruby def_delegators `def_delegators :path, :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/, :join, :rename, :find` at line 198.
pub fn ruby_keg_l198_d29_find(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(keg_receiver(args, 'find').find())
}

// Ruby method `initialize(path)` at line 203.
pub fn ruby_keg_l203_d30_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Keg#initialize requires a path') }
	return keg_boundary_value(new_keg(args[0].as_string()) or { panic(err) })
}

// Ruby method `rack` at line 217.
pub fn ruby_keg_l217_d31_rack(args ...ruby.Value) ruby.Value {
	return ruby.string_value(keg_receiver(args, 'rack').rack())
}

// Ruby method `to_s = path.to_s` at line 222.
pub fn ruby_keg_l222_d32_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(keg_receiver(args, 'to_s').str())
}

// Ruby method `inspect` at line 225.
pub fn ruby_keg_l225_d33_inspect(args ...ruby.Value) ruby.Value {
	return ruby.string_value(keg_receiver(args, 'inspect').inspect())
}

// Ruby method `==(other)` at line 230.
pub fn ruby_keg_l230_d34_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'Keg' {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(keg_from_boundary(args[0]).equal(keg_from_boundary(args[1])))
}

// Ruby alias `alias eql? ==` at line 238.
pub fn ruby_keg_l238_d35_eql(args ...ruby.Value) ruby.Value {
	return ruby_keg_l230_d34_anonymous(...args)
}

// Ruby method `empty_installation?` at line 241.
pub fn ruby_keg_l241_d36_empty_installation(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(keg_receiver(args, 'empty_installation?').empty_installation())
}

// Ruby method `require_relocation? = @require_relocation` at line 258.
pub fn ruby_keg_l258_d37_require_relocation(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(keg_receiver(args, 'require_relocation?').require_relocation)
}

// Ruby method `require_relocation!` at line 261.
pub fn ruby_keg_l261_d38_require_relocation(args ...ruby.Value) ruby.Value {
	mut keg := keg_receiver(args, 'require_relocation!')
	keg.require_relocation = true
	return keg_boundary_value(keg)
}

// Ruby method `linked?` at line 266.
pub fn ruby_keg_l266_d39_linked(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(keg_receiver(args, 'linked?').linked())
}

// Ruby method `remove_linked_keg_record` at line 273.
pub fn ruby_keg_l273_d40_remove_linked_keg_record(args ...ruby.Value) ruby.Value {
	keg_receiver(args, 'remove_linked_keg_record').remove_linked_keg_record() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `optlinked?` at line 279.
pub fn ruby_keg_l279_d41_optlinked(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(keg_receiver(args, 'optlinked?').optlinked())
}

// Ruby method `remove_old_aliases` at line 284.
pub fn ruby_keg_l284_d42_remove_old_aliases(args ...ruby.Value) ruby.Value {
	keg_receiver(args, 'remove_old_aliases').remove_old_aliases() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `remove_opt_record` at line 318.
pub fn ruby_keg_l318_d43_remove_opt_record(args ...ruby.Value) ruby.Value {
	keg_receiver(args, 'remove_opt_record').remove_opt_record() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `uninstall(raise_failures: false)` at line 324.
pub fn ruby_keg_l324_d44_uninstall(args ...ruby.Value) ruby.Value {
	keg_receiver(args, 'uninstall').uninstall() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `ignore_interrupts_and_uninstall!` at line 349.
pub fn ruby_keg_l349_d45_ignore_interrupts_and_uninstall(args ...ruby.Value) ruby.Value {
	return ruby_keg_l324_d44_uninstall(...args)
}

// Ruby method `unlink(verbose: false, dry_run: false)` at line 356.
pub fn ruby_keg_l356_d46_unlink(args ...ruby.Value) ruby.Value {
	count := keg_receiver(args, 'unlink').unlink(keg_bool_argument(args, 2)) or { panic(err) }
	return ruby.int_value(count)
}

// Ruby method `lock(&_block)` at line 396.
pub fn ruby_keg_l396_d47_lock(keg Keg, action LockFileAction) !ruby.Value {
	mut primary := new_lock_file('formula', os.join_path(keg.cellar, keg.name), '')
	primary.lock()!
	defer {
		primary.unlock(false) or {}
	}
	mut oldname_locks := []LockFile{}
	for record in keg.oldname_opt_records() {
		mut oldname_lock := new_lock_file('formula', os.join_path(keg.cellar, os.base(record)), '')
		oldname_lock.lock() or {
			for mut acquired in oldname_locks {
				acquired.unlock(false) or {}
			}
			return err
		}
		oldname_locks << oldname_lock
	}
	defer {
		for mut oldname_lock in oldname_locks {
			oldname_lock.unlock(false) or {}
		}
	}
	return action()
}

// Ruby method `completion_installed?(shell)` at line 409.
pub fn ruby_keg_l409_d48_completion_installed(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Keg#completion_installed? requires a shell') }
	return ruby.bool_value(keg_receiver(args, 'completion_installed?').completion_installed(args[1].as_string()))
}

// Ruby method `functions_installed?(shell)` at line 422.
pub fn ruby_keg_l422_d49_functions_installed(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Keg#functions_installed? requires a shell') }
	return ruby.bool_value(keg_receiver(args, 'functions_installed?').functions_installed(args[1].as_string()))
}

// Ruby method `plist_installed?` at line 438.
pub fn ruby_keg_l438_d50_plist_installed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(keg_receiver(args, 'plist_installed?').plist_installed())
}

// Ruby method `apps` at line 443.
pub fn ruby_keg_l443_d51_apps(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(keg_receiver(args, 'apps').apps())
}

// Ruby method `elisp_installed?` at line 449.
pub fn ruby_keg_l449_d52_elisp_installed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(keg_receiver(args, 'elisp_installed?').elisp_installed())
}

// Ruby method `version` at line 456.
pub fn ruby_keg_l456_d53_version(args ...ruby.Value) ruby.Value {
	version := keg_receiver(args, 'version').version() or { panic(err) }
	return ruby.object_value('PkgVersion', version.to_s())
}

// Ruby method `version_scheme` at line 461.
pub fn ruby_keg_l461_d54_version_scheme(args ...ruby.Value) ruby.Value {
	return ruby.int_value(keg_receiver(args, 'version_scheme').version_scheme())
}

// Ruby method `scheme_and_version` at line 468.
pub fn ruby_keg_l468_d55_scheme_and_version(args ...ruby.Value) ruby.Value {
	keg := keg_receiver(args, 'scheme_and_version')
	version := keg.version() or { panic(err) }
	return ruby.structured_value('Array', '[${keg.version_scheme()}, ${version.to_s()}]', {
		'version_scheme': keg.version_scheme().str()
		'version':        version.to_s()
	})
}

// Ruby method `to_formula` at line 473.
pub fn ruby_keg_l473_d56_to_formula(args ...ruby.Value) ruby.Value {
	formula := formulary_from_keg_default(keg_receiver(args, 'to_formula')) or { panic(err) }
	return formula_boundary_value(formula)
}

// Ruby method `oldname_opt_records` at line 478.
pub fn ruby_keg_l478_d57_oldname_opt_records(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(keg_receiver(args, 'oldname_opt_records').oldname_opt_records())
}

// Ruby method `link(verbose: false, dry_run: false, overwrite: false)` at line 491.
pub fn ruby_keg_l491_d58_link(args ...ruby.Value) ruby.Value {
	count := keg_receiver(args, 'link').link(keg_bool_argument(args, 2), keg_bool_argument(args, 3)) or {
		panic(err)
	}
	return ruby.int_value(count)
}

// Ruby method `prepare_debug_symbols; end` at line 583.
pub fn ruby_keg_l583_d59_prepare_debug_symbols(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `consistent_reproducible_symlink_permissions!; end` at line 586.
pub fn ruby_keg_l586_d60_consistent_reproducible_symlink_permissions(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `remove_oldname_opt_records` at line 589.
pub fn ruby_keg_l589_d61_remove_oldname_opt_records(args ...ruby.Value) ruby.Value {
	keg_receiver(args, 'remove_oldname_opt_records').remove_oldname_opt_records() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `tab` at line 600.
pub fn ruby_keg_l600_d62_tab(args ...ruby.Value) ruby.Value {
	return tab_boundary_value(keg_receiver(args, 'tab').tab() or { panic(err) })
}

// Ruby method `runtime_dependencies` at line 605.
pub fn ruby_keg_l605_d63_runtime_dependencies(args ...ruby.Value) ruby.Value {
	if dependencies := keg_receiver(args, 'runtime_dependencies').runtime_dependencies() {
		return ruby.object_value('Array', json2.encode(dependencies))
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `aliases` at line 611.
pub fn ruby_keg_l611_d64_aliases(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(keg_receiver(args, 'aliases').aliases())
}

// Ruby method `optlink(verbose: false, dry_run: false, overwrite: false)` at line 616.
pub fn ruby_keg_l616_d65_optlink(args ...ruby.Value) ruby.Value {
	keg_receiver(args, 'optlink').optlink(keg_bool_argument(args, 2), keg_bool_argument(args, 3)) or {
		panic(err)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `delete_pyc_files!` at line 632.
pub fn ruby_keg_l632_d66_delete_pyc_files(args ...ruby.Value) ruby.Value {
	keg_receiver(args, 'delete_pyc_files!').delete_pyc_files() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `normalize_pod2man_outputs!` at line 638.
pub fn ruby_keg_l638_d67_normalize_pod2man_outputs(args ...ruby.Value) ruby.Value {
	keg_receiver(args, 'normalize_pod2man_outputs!').normalize_pod2man_outputs() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `keepme_refs` at line 689.
pub fn ruby_keg_l689_d68_keepme_refs(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(keg_receiver(args, 'keepme_refs').keepme_refs())
}

// Ruby method `binary_executable_or_library_files` at line 697.
pub fn ruby_keg_l697_d69_binary_executable_or_library_files(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value([]string{})
}

// Ruby method `codesign_patched_binary(file); end` at line 702.
pub fn ruby_keg_l702_d70_codesign_patched_binary(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `resolve_any_conflicts(dst, dry_run: false, verbose: false, overwrite: false)` at line 714.
pub fn ruby_keg_l714_d71_resolve_any_conflicts(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Keg#resolve_any_conflicts requires a destination') }
	dst := args[1].as_string()
	if !ruby.is_link(dst) {
		return ruby.object_value('NilClass', 'nil')
	}
	if !ruby.path_exists(dst) {
		if !keg_bool_argument(args, 2) { os.rm(dst) or { panic(err) } }
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.bool_value(false)
}

// Ruby method `make_relative_symlink(dst, src, verbose: false, dry_run: false, overwrite: false)` at line 746.
pub fn ruby_keg_l746_d72_make_relative_symlink(args ...ruby.Value) ruby.Value {
	if args.len < 3 { panic('Keg#make_relative_symlink requires dst and src') }
	created := make_relative_keg_symlink(args[1].as_string(), args[2].as_string(), keg_bool_argument(args, 4), keg_bool_argument(args, 5)) or { panic(err) }
	return ruby.bool_value(created)
}

// Ruby method `remove_alias_symlink(alias_symlink, alias_match_path)` at line 784.
pub fn ruby_keg_l784_d73_remove_alias_symlink(args ...ruby.Value) ruby.Value {
	if args.len < 3 { panic('Keg#remove_alias_symlink requires alias and match paths') }
	remove_keg_alias_symlink(args[1].as_string(), args[2].as_string()) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `link_dir(relative_dir, verbose: false, dry_run: false, overwrite: false, &_block)` at line 804.
pub fn ruby_keg_l804_d74_link_dir(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Keg#link_dir requires a relative directory') }
	keg := keg_receiver(args, 'link_dir')
	count := keg.link_tree(keg.join(args[1].as_string()), keg_bool_argument(args, 3), keg_bool_argument(args, 4)) or { panic(err) }
	return ruby.int_value(count)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cachable"
// 5: require "keg_relocate"
// 6: require "language/python"
// 7: require "lock_file"
// 8: require "pkg_version"
// 9: require "utils/output"
// 10:
// 11: # Installation prefix of a formula.
// 12: class Keg
// 13:   extend T::Generic
// 14:   extend Cachable
// 15:   include Utils::Output::Mixin
// 16:
// 17:   Cache = type_template { { fixed: T::Hash[Symbol, T.untyped] } }
// 18:
// 19:   # Error for when a keg is already linked.
// 20:   class AlreadyLinkedError < RuntimeError
// 21:     sig { params(keg: Keg).void }
// 22:     def initialize(keg)
// 23:       super <<~EOS
// 24:         Cannot link #{keg.name}
// 25:         Another version is already linked: #{keg.linked_keg_record.resolved_path}
// 26:       EOS
// 27:     end
// 28:   end
// 29:
// 30:   # Error for when a keg cannot be linked.
// 31:   class LinkError < RuntimeError
// 32:     sig { returns(Keg) }
// 33:     attr_reader :keg
// 34:
// 35:     sig { returns(Pathname) }
// 36:     attr_reader :src, :dst
// 37:
// 38:     sig { params(keg: Keg, src: Pathname, dst: Pathname, cause: Exception).void }
// 39:     def initialize(keg, src, dst, cause)
// 40:       @src = src
// 41:       @dst = dst
// 42:       @keg = keg
// 43:       @cause = cause
// 44:       super(cause.message)
// 45:       set_backtrace(cause.backtrace)
// 46:     end
// 47:   end
// 48:
// 49:   # Error for when a file already exists or belongs to another keg.
// 50:   class ConflictError < LinkError
// 51:     sig { returns(String) }
// 52:     def suggestion
// 53:       conflict = Keg.for(dst)
// 54:     rescue NotAKegError, Errno::ENOENT
// 55:       "already exists. You may want to remove it:\n  rm '#{dst}'\n"
// 56:     else
// 57:       <<~EOS
// 58:         is a symlink belonging to #{conflict.name}. You can unlink it:
// 59:           brew unlink #{conflict.name}
// 60:       EOS
// 61:     end
// 62:
// 63:     sig { returns(String) }
// 64:     def to_s
// 65:       s = []
// 66:       s << "Could not symlink #{src}"
// 67:       s << "Target #{dst}" << suggestion
// 68:       s << <<~EOS
// 69:         To force the link and overwrite all conflicting files:
// 70:           brew link --overwrite #{keg.name}
// 71:
// 72:         To list all files that would be deleted:
// 73:           brew link --overwrite #{keg.name} --dry-run
// 74:       EOS
// 75:       s.join("\n")
// 76:     end
// 77:   end
// 78:
// 79:   # Error for when a directory is not writable.
// 80:   class DirectoryNotWritableError < LinkError
// 81:     sig { returns(String) }
// 82:     def to_s
// 83:       <<~EOS
// 84:         Could not symlink #{src}
// 85:         #{dst.dirname} is not writable.
// 86:       EOS
// 87:     end
// 88:   end
// 89:
// 90:   # Locale-specific directories have the form `language[_territory][.codeset][@modifier]`
// 91:   LOCALEDIR_RX = %r{(locale|man)/([a-z]{2}|C|POSIX)(_[A-Z]{2})?(\.[a-zA-Z\-0-9]+(@.+)?)?}
// 92:   INFOFILE_RX = %r{info/([^.].*?\.info(\.gz)?|dir)$}
// 93:
// 94:   # These paths relative to the keg's share directory should always be real
// 95:   # directories in the prefix, never symlinks.
// 96:   SHARE_PATHS = %w[
// 97:     aclocal cps doc info java locale man
// 98:     man/man1 man/man2 man/man3 man/man4
// 99:     man/man5 man/man6 man/man7 man/man8
// 100:     man/cat1 man/cat2 man/cat3 man/cat4
// 101:     man/cat5 man/cat6 man/cat7 man/cat8
// 102:     applications gnome gnome/help icons
// 103:     mime mime/packages mime-info pixmaps
// 104:     postgresql sounds
// 105:   ].freeze
// 106:
// 107:   ELISP_EXTENSIONS = %w[.el .elc].freeze
// 108:   PYC_EXTENSIONS = %w[.pyc .pyo].freeze
// 109:   LIBTOOL_EXTENSIONS = %w[.la .lai].freeze
// 110:
// 111:   KEEPME_FILE = ".keepme"
// 112:
// 113:   # @param path if this is a file in a keg, returns the containing {Keg} object.
// 114:   sig { params(path: Pathname).returns(Keg) }
// 115:   def self.for(path)
// 116:     original_path = path
// 117:     raise Errno::ENOENT, original_path.to_s unless original_path.exist?
// 118:
// 119:     if (path = original_path.realpath)
// 120:       until path.root?
// 121:         return Keg.new(path) if path.parent.parent == HOMEBREW_CELLAR.realpath
// 122:
// 123:         path = path.parent.realpath # realpath() prevents root? failing
// 124:       end
// 125:     end
// 126:     raise NotAKegError, "#{original_path} is not inside a keg"
// 127:   end
// 128:
// 129:   sig { params(rack: Pathname).returns(T.nilable(Keg)) }
// 130:   def self.from_rack(rack)
// 131:     return unless rack.directory?
// 132:
// 133:     kegs = rack.subdirs.map { |d| new(d) }
// 134:     kegs.find(&:linked?) || kegs.find(&:optlinked?) || kegs.max_by(&:scheme_and_version)
// 135:   end
// 136:
// 137:   sig { returns(T::Array[Keg]) }
// 138:   def self.all
// 139:     Formula.racks.flat_map(&:subdirs).map { |d| new(d) }
// 140:   end
// 141:
// 142:   sig { returns(T::Array[String]) }
// 143:   def self.keg_link_directories
// 144:     @keg_link_directories ||= T.let(%w[
// 145:       bin etc include lib sbin share var
// 146:     ].freeze, T.nilable(T::Array[String]))
// 147:   end
// 148:
// 149:   sig { returns(T::Array[Pathname]) }
// 150:   def self.must_exist_subdirectories
// 151:     @must_exist_subdirectories ||= T.let((keg_link_directories - %w[var] + %w[
// 152:       opt
// 153:       var/homebrew/linked
// 154:     ]).map { |dir| HOMEBREW_PREFIX/dir }.sort.uniq.freeze, T.nilable(T::Array[Pathname]))
// 155:   end
// 156:
// 157:   # Keep relatively in sync with
// 158:   # {https://github.com/Homebrew/install/blob/HEAD/install.sh}
// 159:   sig { returns(T::Array[Pathname]) }
// 160:   def self.must_exist_directories
// 161:     @must_exist_directories ||= T.let((must_exist_subdirectories + [
// 162:       HOMEBREW_CELLAR,
// 163:     ].sort.uniq).freeze, T.nilable(T::Array[Pathname]))
// 164:   end
// 165:
// 166:   # Keep relatively in sync with
// 167:   # {https://github.com/Homebrew/install/blob/HEAD/install.sh}
// 168:   sig { returns(T::Array[Pathname]) }
// 169:   def self.must_be_writable_directories
// 170:     @must_be_writable_directories ||= T.let((%w[
// 171:       etc/bash_completion.d lib/cps lib/pkgconfig
// 172:       share/aclocal share/doc share/info share/locale share/man
// 173:       share/man/man1 share/man/man2 share/man/man3 share/man/man4
// 174:       share/man/man5 share/man/man6 share/man/man7 share/man/man8
// 175:       share/cps share/zsh share/zsh/site-functions
// 176:       share/pwsh share/pwsh/completions
// 177:       var/log
// 178:     ].map { |dir| HOMEBREW_PREFIX/dir } + must_exist_subdirectories + [
// 179:       HOMEBREW_CACHE,
// 180:       HOMEBREW_CELLAR,
// 181:       HOMEBREW_LOCKS,
// 182:       HOMEBREW_LOGS,
// 183:       HOMEBREW_REPOSITORY,
// 184:       Language::Python.homebrew_site_packages,
// 185:     ]).sort.uniq.freeze, T.nilable(T::Array[Pathname]))
// 186:   end
// 187:
// 188:   sig { returns(String) }
// 189:   attr_reader :name
// 190:
// 191:   sig { returns(Pathname) }
// 192:   attr_reader :path, :linked_keg_record, :opt_record
// 193:
// 194:   protected :path
// 195:
// 196:   extend Forwardable
// 197:
// 198:   def_delegators :path,
// 199:                  :to_path, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/,
// 200:                  :join, :rename, :find
// 201:
// 202:   sig { params(path: Pathname).void }
// 203:   def initialize(path)
// 204:     path = path.resolved_path if path.to_s.start_with?("#{HOMEBREW_PREFIX}/opt/")
// 205:     raise "#{path} is not a valid keg" if path.parent.parent.realpath != HOMEBREW_CELLAR.realpath
// 206:     raise "#{path} is not a directory" unless path.directory?
// 207:
// 208:     @path = path
// 209:     @name = T.let(path.parent.basename.to_s, String)
// 210:     @linked_keg_record = T.let(HOMEBREW_LINKED_KEGS/name, Pathname)
// 211:     @opt_record = T.let(HOMEBREW_PREFIX/"opt/#{name}", Pathname)
// 212:     @oldname_opt_records = T.let([], T::Array[Pathname])
// 213:     @require_relocation = T.let(false, T::Boolean)
// 214:   end
// 215:
// 216:   sig { returns(Pathname) }
// 217:   def rack
// 218:     path.parent
// 219:   end
// 220:
// 221:   sig { returns(String) }
// 222:   def to_s = path.to_s
// 223:
// 224:   sig { returns(String) }
// 225:   def inspect
// 226:     "#<#{self.class.name}:#{path}>"
// 227:   end
// 228:
// 229:   sig { params(other: T.anything).returns(T::Boolean) }
// 230:   def ==(other)
// 231:     case other
// 232:     when Keg
// 233:       instance_of?(other.class) && path == other.path
// 234:     else
// 235:       false
// 236:     end
// 237:   end
// 238:   alias eql? ==
// 239:
// 240:   sig { returns(T::Boolean) }
// 241:   def empty_installation?
// 242:     Pathname.glob("#{path}/*") do |file|
// 243:       return false if file.directory? && !file.children.reject(&:ds_store?).empty?
// 244:
// 245:       basename = file.basename.to_s
// 246:
// 247:       require "metafiles"
// 248:       next if Metafiles.copy?(basename)
// 249:       next if %w[.DS_Store INSTALL_RECEIPT.json].include?(basename)
// 250:
// 251:       return false
// 252:     end
// 253:
// 254:     true
// 255:   end
// 256:
// 257:   sig { returns(T::Boolean) }
// 258:   def require_relocation? = @require_relocation
// 259:
// 260:   sig { void }
// 261:   def require_relocation!
// 262:     @require_relocation = true
// 263:   end
// 264:
// 265:   sig { returns(T::Boolean) }
// 266:   def linked?
// 267:     linked_keg_record.symlink? &&
// 268:       linked_keg_record.directory? &&
// 269:       path == linked_keg_record.resolved_path
// 270:   end
// 271:
// 272:   sig { void }
// 273:   def remove_linked_keg_record
// 274:     linked_keg_record.unlink
// 275:     linked_keg_record.parent.rmdir_if_possible
// 276:   end
// 277:
// 278:   sig { returns(T::Boolean) }
// 279:   def optlinked?
// 280:     opt_record.symlink? && path == opt_record.resolved_path
// 281:   end
// 282:
// 283:   sig { void }
// 284:   def remove_old_aliases
// 285:     opt = opt_record.parent
// 286:     linkedkegs = linked_keg_record.parent
// 287:
// 288:     tap = begin
// 289:       to_formula.tap
// 290:     rescue
// 291:       # If the formula can't be found, just ignore aliases for now.
// 292:       nil
// 293:     end
// 294:
// 295:     if tap
// 296:       bad_tap_opt = opt/tap.user
// 297:       FileUtils.rm_rf bad_tap_opt if !bad_tap_opt.symlink? && bad_tap_opt.directory?
// 298:     end
// 299:
// 300:     aliases.each do |a|
// 301:       # versioned aliases are handled below
// 302:       next if a.match?(/.+@./)
// 303:
// 304:       remove_alias_symlink(opt/a, opt_record)
// 305:       remove_alias_symlink(linkedkegs/a, linked_keg_record)
// 306:     end
// 307:
// 308:     Pathname.glob("#{opt_record}@*").each do |a|
// 309:       a = a.basename.to_s
// 310:       next if aliases.include?(a)
// 311:
// 312:       remove_alias_symlink(opt/a, rack)
// 313:       remove_alias_symlink(linkedkegs/a, rack)
// 314:     end
// 315:   end
// 316:
// 317:   sig { void }
// 318:   def remove_opt_record
// 319:     opt_record.unlink
// 320:     opt_record.parent.rmdir_if_possible
// 321:   end
// 322:
// 323:   sig { params(raise_failures: T::Boolean).void }
// 324:   def uninstall(raise_failures: false)
// 325:     CacheStoreDatabase.use(:linkage) do |db|
// 326:       break unless db.created?
// 327:
// 328:       LinkageCacheStore.new(path.to_s,
// 329:                             T.cast(db,
// 330:                                    CacheStoreDatabase[String, T::Hash[T.any(String, Symbol), T.anything]])).delete!
// 331:     end
// 332:
// 333:     FileUtils.rm_r(path)
// 334:     path.parent.rmdir_if_possible
// 335:     remove_opt_record if optlinked?
// 336:     remove_linked_keg_record if linked?
// 337:     remove_old_aliases
// 338:     remove_oldname_opt_records
// 339:   rescue Errno::EACCES, Errno::ENOTEMPTY
// 340:     raise if raise_failures
// 341:
// 342:     odie <<~EOS
// 343:       Could not remove #{name} keg! Do so manually:
// 344:         sudo rm -rf #{path}
// 345:     EOS
// 346:   end
// 347:
// 348:   sig { void }
// 349:   def ignore_interrupts_and_uninstall!
// 350:     ignore_interrupts do
// 351:       uninstall
// 352:     end
// 353:   end
// 354:
// 355:   sig { params(verbose: T::Boolean, dry_run: T::Boolean).returns(Integer) }
// 356:   def unlink(verbose: false, dry_run: false)
// 357:     ObserverPathnameExtension.reset_counts!
// 358:
// 359:     dirs = []
// 360:
// 361:     keg_directories = self.class.keg_link_directories.map { |d| path/d }.select(&:exist?)
// 362:
// 363:     keg_directories.each do |dir|
// 364:       dir.find do |src|
// 365:         dst = HOMEBREW_PREFIX + src.relative_path_from(path)
// 366:         dst.extend(ObserverPathnameExtension)
// 367:
// 368:         dirs << dst if dst.directory? && !dst.symlink?
// 369:
// 370:         # check whether the file to be unlinked is from the current keg first
// 371:         next unless dst.symlink?
// 372:         next if src != dst.resolved_path
// 373:
// 374:         if dry_run
// 375:           puts dst
// 376:           Find.prune if src.directory?
// 377:           next
// 378:         end
// 379:
// 380:         dst.uninstall_info if dst.to_s.match?(INFOFILE_RX)
// 381:         dst.unlink
// 382:         Find.prune if src.directory?
// 383:       end
// 384:     end
// 385:
// 386:     unless dry_run
// 387:       remove_old_aliases
// 388:       remove_linked_keg_record if linked?
// 389:       (dirs - self.class.must_exist_subdirectories).reverse_each(&:rmdir_if_possible)
// 390:     end
// 391:
// 392:     ObserverPathnameExtension.n
// 393:   end
// 394:
// 395:   sig { params(_block: T.proc.void).void }
// 396:   def lock(&_block)
// 397:     FormulaLock.new(name).with_lock do
// 398:       oldname_locks = oldname_opt_records.map do |record|
// 399:         FormulaLock.new(record.basename.to_s)
// 400:       end
// 401:       oldname_locks.each(&:lock)
// 402:       yield
// 403:     ensure
// 404:       oldname_locks&.each(&:unlock)
// 405:     end
// 406:   end
// 407:
// 408:   sig { params(shell: Symbol).returns(T::Boolean) }
// 409:   def completion_installed?(shell)
// 410:     dir = case shell
// 411:     when :bash then path/"etc/bash_completion.d"
// 412:     when :fish then path/"share/fish/vendor_completions.d"
// 413:     when :zsh
// 414:       dir = path/"share/zsh/site-functions"
// 415:       dir if dir.directory? && dir.children.any? { |f| f.basename.to_s.start_with?("_") }
// 416:     when :pwsh then path/"share/pwsh/completions"
// 417:     end
// 418:     !dir.nil? && dir.directory? && !dir.children.empty?
// 419:   end
// 420:
// 421:   sig { params(shell: Symbol).returns(T::Boolean) }
// 422:   def functions_installed?(shell)
// 423:     case shell
// 424:     when :fish
// 425:       dir = path/"share/fish/vendor_functions.d"
// 426:       dir.directory? && !dir.children.empty?
// 427:     when :zsh
// 428:       # Check for non completion functions (i.e. files not started with an underscore),
// 429:       # since those can be checked separately
// 430:       dir = path/"share/zsh/site-functions"
// 431:       dir.directory? && dir.children.any? { |f| !f.basename.to_s.start_with?("_") }
// 432:     else
// 433:       false
// 434:     end
// 435:   end
// 436:
// 437:   sig { returns(T::Boolean) }
// 438:   def plist_installed?
// 439:     !Dir["#{path}/*.plist"].empty?
// 440:   end
// 441:
// 442:   sig { returns(T::Array[Pathname]) }
// 443:   def apps
// 444:     app_prefix = optlinked? ? opt_record : path
// 445:     Pathname.glob("#{app_prefix}/{,libexec/}*.app")
// 446:   end
// 447:
// 448:   sig { returns(T::Boolean) }
// 449:   def elisp_installed?
// 450:     return false unless (path/"share/emacs/site-lisp"/name).exist?
// 451:
// 452:     (path/"share/emacs/site-lisp"/name).children.any? { |f| ELISP_EXTENSIONS.include? f.extname }
// 453:   end
// 454:
// 455:   sig { returns(PkgVersion) }
// 456:   def version
// 457:     PkgVersion.parse(path.basename.to_s)
// 458:   end
// 459:
// 460:   sig { returns(Integer) }
// 461:   def version_scheme
// 462:     @version_scheme ||= T.let(tab.version_scheme, T.nilable(Integer))
// 463:   end
// 464:
// 465:   # For ordering kegs by version with `.sort_by`, `.max_by`, etc.
// 466:   # @see Formula.version_scheme
// 467:   sig { returns([Integer, PkgVersion]) }
// 468:   def scheme_and_version
// 469:     [version_scheme, version]
// 470:   end
// 471:
// 472:   sig { returns(Formula) }
// 473:   def to_formula
// 474:     Formulary.from_keg(self)
// 475:   end
// 476:
// 477:   sig { returns(T::Array[Pathname]) }
// 478:   def oldname_opt_records
// 479:     return @oldname_opt_records unless @oldname_opt_records.empty?
// 480:
// 481:     @oldname_opt_records = if (opt_dir = HOMEBREW_PREFIX/"opt").directory?
// 482:       opt_dir.subdirs.select do |dir|
// 483:         dir.symlink? && dir != opt_record && path.parent == dir.resolved_path.parent
// 484:       end
// 485:     else
// 486:       []
// 487:     end
// 488:   end
// 489:
// 490:   sig { params(verbose: T::Boolean, dry_run: T::Boolean, overwrite: T::Boolean).returns(Integer) }
// 491:   def link(verbose: false, dry_run: false, overwrite: false)
// 492:     raise AlreadyLinkedError, self if linked_keg_record.directory?
// 493:
// 494:     ObserverPathnameExtension.reset_counts!
// 495:
// 496:     optlink(verbose:, dry_run:, overwrite:) unless dry_run
// 497:
// 498:     # yeah indeed, you have to force anything you need in the main tree into
// 499:     # these dirs REMEMBER that *NOT* everything needs to be in the main tree
// 500:     link_dir("etc", verbose:, dry_run:, overwrite:) { :mkpath }
// 501:     link_dir("bin", verbose:, dry_run:, overwrite:) { :skip_dir }
// 502:     link_dir("sbin", verbose:, dry_run:, overwrite:) { :skip_dir }
// 503:     link_dir("include", verbose:, dry_run:, overwrite:) do |relative_path|
// 504:       case relative_path.to_s
// 505:       when /^postgresql@\d+/
// 506:         :mkpath
// 507:       else
// 508:         :link
// 509:       end
// 510:     end
// 511:
// 512:     link_dir("share", verbose:, dry_run:, overwrite:) do |relative_path|
// 513:       case relative_path.to_s
// 514:       when INFOFILE_RX then :info
// 515:       when "locale/locale.alias",
// 516:            %r{^icons/.*/icon-theme\.cache$}
// 517:         :skip_file
// 518:       when LOCALEDIR_RX,
// 519:            %r{^icons/}, # all icons subfolders should also mkpath
// 520:            /^zsh/,
// 521:            /^fish/,
// 522:            /^pwsh/,
// 523:            %r{^lua/}, #  Lua, Lua51, Lua53 all need the same handling.
// 524:            %r{^guile/},
// 525:            /^postgresql@\d+/,
// 526:            /^pypy/,
// 527:            *SHARE_PATHS
// 528:         :mkpath
// 529:       else
// 530:         :link
// 531:       end
// 532:     end
// 533:
// 534:     link_dir("lib", verbose:, dry_run:, overwrite:) do |relative_path|
// 535:       case relative_path.to_s
// 536:       when "charset.alias"
// 537:         :skip_file
// 538:       when "cps",       # Common Package Specification database gets explicitly created
// 539:            "pkgconfig", # pkg-config database gets explicitly created
// 540:            "cmake",     # cmake database gets explicitly created
// 541:            "dtrace",    # lib/language folders also get explicitly created
// 542:            /^gdk-pixbuf/,
// 543:            "ghc",
// 544:            /^gio/,
// 545:            /^lua/,
// 546:            /^mecab/,
// 547:            /^node/,
// 548:            /^ocaml/,
// 549:            /^perl5/,
// 550:            "php",
// 551:            /^postgresql@\d+/,
// 552:            /^pypy/,
// 553:            /^python[23]\.\d+/,
// 554:            /^R/,
// 555:            /^ruby/
// 556:         :mkpath
// 557:       else
// 558:         # Everything else is symlinked to the Cellar
// 559:         :link
// 560:       end
// 561:     end
// 562:
// 563:     link_dir("Frameworks", verbose:, dry_run:, overwrite:) do |relative_path|
// 564:       # Frameworks contain symlinks pointing into a subdir, so we have to use
// 565:       # the :link strategy. However, for Foo.framework and
// 566:       # Foo.framework/Versions we have to use :mkpath so that multiple formulae
// 567:       # can link their versions into it and `brew [un]link` works.
// 568:       if relative_path.to_s.match?(%r{[^/]*\.framework(/Versions)?$})
// 569:         :mkpath
// 570:       else
// 571:         :link
// 572:       end
// 573:     end
// 574:     make_relative_symlink(linked_keg_record, path, verbose:, dry_run:, overwrite:) unless dry_run
// 575:   rescue LinkError
// 576:     unlink(verbose:)
// 577:     raise
// 578:   else
// 579:     ObserverPathnameExtension.n
// 580:   end
// 581:
// 582:   sig { void }
// 583:   def prepare_debug_symbols; end
// 584:
// 585:   sig { void }
// 586:   def consistent_reproducible_symlink_permissions!; end
// 587:
// 588:   sig { void }
// 589:   def remove_oldname_opt_records
// 590:     oldname_opt_records.reject! do |record|
// 591:       return false if record.resolved_path != path
// 592:
// 593:       record.unlink
// 594:       record.parent.rmdir_if_possible
// 595:       true
// 596:     end
// 597:   end
// 598:
// 599:   sig { returns(Tab) }
// 600:   def tab
// 601:     Tab.for_keg(self)
// 602:   end
// 603:
// 604:   sig { returns(T.nilable(T::Array[T.untyped])) }
// 605:   def runtime_dependencies
// 606:     Keg.cache[:runtime_dependencies] ||= {}
// 607:     Keg.cache[:runtime_dependencies][path] ||= tab.runtime_dependencies
// 608:   end
// 609:
// 610:   sig { returns(T::Array[String]) }
// 611:   def aliases
// 612:     tab.aliases || []
// 613:   end
// 614:
// 615:   sig { params(verbose: T::Boolean, dry_run: T::Boolean, overwrite: T::Boolean).void }
// 616:   def optlink(verbose: false, dry_run: false, overwrite: false)
// 617:     opt_record.delete if opt_record.symlink? || opt_record.exist?
// 618:     make_relative_symlink(opt_record, path, verbose:, dry_run:, overwrite:)
// 619:     aliases.each do |a|
// 620:       alias_opt_record = opt_record.parent/a
// 621:       alias_opt_record.delete if alias_opt_record.symlink? || alias_opt_record.exist?
// 622:       make_relative_symlink(alias_opt_record, path, verbose:, dry_run:, overwrite:)
// 623:     end
// 624:
// 625:     oldname_opt_records.each do |record|
// 626:       record.delete
// 627:       make_relative_symlink(record, path, verbose:, dry_run:, overwrite:)
// 628:     end
// 629:   end
// 630:
// 631:   sig { void }
// 632:   def delete_pyc_files!
// 633:     path.find { |pn| pn.delete if PYC_EXTENSIONS.include?(pn.extname) }
// 634:     path.find { |pn| FileUtils.rm_rf pn if pn.basename.to_s == "__pycache__" }
// 635:   end
// 636:
// 637:   sig { void }
// 638:   def normalize_pod2man_outputs!
// 639:     # Only process uncompressed manpages, which end in a digit
// 640:     manpages = Dir[path/"share/man/*/*.[1-9]{,p,pm}"]
// 641:     generated_regex = /^\.\\"\s*Automatically generated by .*\n/
// 642:     manpages.each do |f|
// 643:       manpage = Pathname.new(f)
// 644:       next unless manpage.file?
// 645:
// 646:       content = manpage.read
// 647:       unless content.valid_encoding?
// 648:         # Occasionally, a manpage might not be encoded as UTF-8. ISO-8859-1 is a
// 649:         # common alternative that's worth trying in this case.
// 650:         content = File.read(manpage, encoding: "ISO-8859-1")
// 651:
// 652:         # If the encoding is still invalid, we can't do anything about it.
// 653:         next unless content.valid_encoding?
// 654:       end
// 655:
// 656:       content = content.gsub(generated_regex, "")
// 657:       content = content.lines.map do |line|
// 658:         if line.start_with?(".TH")
// 659:           # Split the line by spaces, but preserve quoted strings
// 660:           parts = line.split(/\s(?=(?:[^"]|"[^"]*")*$)/)
// 661:           next line if parts.length != 6
// 662:
// 663:           # pod2man embeds the perl version used into the 5th field of the footer
// 664:           parts[4]&.gsub!(/^"perl v.*"$/, "\"\"")
// 665:           # man extension remove in man files
// 666:           parts[2]&.gsub!(/([1-9])(?:pm|p)?/, "\\1")
// 667:
// 668:           "#{parts.join(" ")}\n"
// 669:         elsif line.start_with?(".IX")
// 670:           # Split the line by spaces, but preserve quoted strings
// 671:           parts = line.split(/\s(?=(?:[^"]|"[^"]*")*$)/)
// 672:           next line if parts.length != 3
// 673:           next line if parts[1] != "Title"
// 674:
// 675:           # man extension remove in man files
// 676:           parts[2]&.gsub!(/([1-9])(?:pm|p)?/, "\\1")
// 677:
// 678:           "#{parts.join(" ")}\n"
// 679:         else
// 680:           line
// 681:         end
// 682:       end.join
// 683:
// 684:       manpage.atomic_write(content)
// 685:     end
// 686:   end
// 687:
// 688:   sig { returns(T::Array[String]) }
// 689:   def keepme_refs
// 690:     keepme = path/KEEPME_FILE
// 691:     return [] if !keepme.exist? || !keepme.readable?
// 692:
// 693:     keepme.readlines.select { |ref| File.exist?(ref.strip) }
// 694:   end
// 695:
// 696:   sig { returns(T::Array[Pathname]) }
// 697:   def binary_executable_or_library_files
// 698:     []
// 699:   end
// 700:
// 701:   sig { params(file: String).void }
// 702:   def codesign_patched_binary(file); end
// 703:
// 704:   private
// 705:
// 706:   sig {
// 707:     params(
// 708:       dst:       Pathname,
// 709:       dry_run:   T::Boolean,
// 710:       verbose:   T::Boolean,
// 711:       overwrite: T::Boolean,
// 712:     ).returns(T.nilable(TrueClass))
// 713:   }
// 714:   def resolve_any_conflicts(dst, dry_run: false, verbose: false, overwrite: false)
// 715:     return unless dst.symlink?
// 716:
// 717:     src = dst.resolved_path
// 718:
// 719:     # `src` itself may be a symlink, so check lstat to ensure we are dealing with
// 720:     # a directory and not a symlink pointing to a directory (which needs to be
// 721:     # treated as a file). In other words, we only want to resolve one symlink.
// 722:
// 723:     begin
// 724:       stat = src.lstat
// 725:     rescue Errno::ENOENT
// 726:       # dst is a broken symlink, so remove it.
// 727:       dst.unlink unless dry_run
// 728:       return
// 729:     end
// 730:
// 731:     return unless stat.directory?
// 732:
// 733:     begin
// 734:       keg = Keg.for(src)
// 735:     rescue NotAKegError
// 736:       puts "Won't resolve conflicts for symlink #{dst} as it doesn't resolve into the Cellar." if verbose
// 737:       return
// 738:     end
// 739:
// 740:     dst.unlink unless dry_run
// 741:     keg.link_dir(src, dry_run: false, verbose: false, overwrite: false) { :mkpath }
// 742:     true
// 743:   end
// 744:
// 745:   sig { params(dst: Pathname, src: Pathname, verbose: T::Boolean, dry_run: T::Boolean, overwrite: T::Boolean).void }
// 746:   def make_relative_symlink(dst, src, verbose: false, dry_run: false, overwrite: false)
// 747:     if dst.symlink? && src == dst.resolved_path
// 748:       puts "Skipping; link already exists: #{dst}" if verbose
// 749:       return
// 750:     end
// 751:
// 752:     # cf. git-clean -n: list files to delete, don't really link or delete
// 753:     if dry_run && overwrite
// 754:       if dst.symlink?
// 755:         puts "#{dst} -> #{dst.resolved_path}"
// 756:       elsif dst.exist?
// 757:         puts dst
// 758:       end
// 759:       return
// 760:     end
// 761:
// 762:     # list all link targets
// 763:     if dry_run
// 764:       puts dst
// 765:       return
// 766:     end
// 767:
// 768:     dst.delete if overwrite && (dst.exist? || dst.symlink?)
// 769:     dst.make_relative_symlink(src)
// 770:   rescue Errno::EEXIST => e
// 771:     raise ConflictError.new(self, src.relative_path_from(path), dst, e) if dst.exist?
// 772:
// 773:     if dst.symlink?
// 774:       dst.unlink
// 775:       retry
// 776:     end
// 777:   rescue Errno::EACCES => e
// 778:     raise DirectoryNotWritableError.new(self, src.relative_path_from(path), dst, e)
// 779:   rescue SystemCallError => e
// 780:     raise LinkError.new(self, src.relative_path_from(path), dst, e)
// 781:   end
// 782:
// 783:   sig { params(alias_symlink: Pathname, alias_match_path: Pathname).void }
// 784:   def remove_alias_symlink(alias_symlink, alias_match_path)
// 785:     if alias_symlink.symlink? && alias_symlink.exist?
// 786:       alias_symlink.delete if alias_match_path.exist? && alias_symlink.realpath == alias_match_path.realpath
// 787:     elsif alias_symlink.symlink? || alias_symlink.exist?
// 788:       alias_symlink.delete
// 789:     end
// 790:   end
// 791:
// 792:   protected
// 793:
// 794:   # symlinks the contents of path+relative_dir recursively into #{HOMEBREW_PREFIX}/relative_dir
// 795:   sig {
// 796:     params(
// 797:       relative_dir: T.any(String, Pathname),
// 798:       verbose:      T::Boolean,
// 799:       dry_run:      T::Boolean,
// 800:       overwrite:    T::Boolean,
// 801:       _block:       T.proc.params(relative_path: Pathname).returns(T.nilable(Symbol)),
// 802:     ).void
// 803:   }
// 804:   def link_dir(relative_dir, verbose: false, dry_run: false, overwrite: false, &_block)
// 805:     root = path/relative_dir
// 806:     return unless root.exist?
// 807:
// 808:     root.find do |src|
// 809:       next if src == root
// 810:
// 811:       dst = HOMEBREW_PREFIX + src.relative_path_from(path)
// 812:       dst.extend ObserverPathnameExtension
// 813:
// 814:       if src.symlink? || src.file?
// 815:         Find.prune if File.basename(src) == ".DS_Store"
// 816:         Find.prune if src.resolved_path == dst
// 817:         # Don't link pyc or pyo files because Python overwrites these
// 818:         # cached object files and next time brew wants to link, the
// 819:         # file is in the way.
// 820:         Find.prune if PYC_EXTENSIONS.include?(src.extname) && src.to_s.include?("/site-packages/")
// 821:
// 822:         case yield src.relative_path_from(root)
// 823:         when :skip_file, nil
// 824:           Find.prune
// 825:         when :info
// 826:           next if File.basename(src) == "dir" # skip historical local 'dir' files
// 827:
// 828:           make_relative_symlink(dst, src, verbose:, dry_run:, overwrite:)
// 829:           dst.install_info
// 830:         else
// 831:           make_relative_symlink dst, src, verbose:, dry_run:, overwrite:
// 832:         end
// 833:       elsif src.directory?
// 834:         # if the dst dir already exists, then great! walk the rest of the tree tho
// 835:         next if dst.directory? && !dst.symlink?
// 836:
// 837:         # no need to put .app bundles in the path, the user can just use
// 838:         # spotlight, or the open command and actual mac apps use an equivalent
// 839:         Find.prune if src.extname == ".app"
// 840:
// 841:         case yield src.relative_path_from(root)
// 842:         when :skip_dir
// 843:           Find.prune
// 844:         when :mkpath
// 845:           dst.mkpath unless resolve_any_conflicts(dst, verbose:, dry_run:, overwrite:)
// 846:         else
// 847:           unless resolve_any_conflicts(dst, verbose:, dry_run:, overwrite:)
// 848:             make_relative_symlink(dst, src, verbose:, dry_run:, overwrite:)
// 849:             Find.prune
// 850:           end
// 851:         end
// 852:       end
// 853:     end
// 854:   end
// 855: end
// 856:
// 857: require "extend/os/keg"
