module mac

import os

// Translated from Homebrew/brew `extend/os/mac/keg_relocate.rb`.
pub struct MacKegMachFile {
pub:
	path             string
	dylib            bool
	bundle           bool
	executable       bool
	symlink          bool
	directory        bool
	device           u64
	inode            u64
	dylib_id         ?string
	linked_libraries []string
	rpaths           []string
	resolved_rpaths  []string
}

pub struct MacKegRuntimeDependency {
pub:
	full_name         string
	declared_directly bool
}

pub struct MacKegReplacementPair {
pub:
	old string
	new string
}

pub struct MacKegRelocation {
pub mut:
	pairs map[string]MacKegReplacementPair
}

pub enum MacKegChangeKind {
	dylib_id
	install_name
	rpath
	delete_rpath
}

pub struct MacKegChange {
pub:
	kind MacKegChangeKind
	file string
	old  string
	new  string
}

pub struct MacKegRelocationResult {
pub:
	changes      []MacKegChange
	codesigned   []string
	warnings     []string
	super_called bool
}

pub struct MacKegNameResult {
pub:
	name     string
	warnings []string
}

pub struct MacKegRelocationContext {
pub:
	path                      string
	opt_record                string
	lib                       string
	libexec                   string
	prefix                    string
	cellar                    string
	temp                      string
	temp_realpath             string
	name                      string
	formula_available         bool
	formula_preserve_rpath    bool
	relocatable_install_names bool
	files                     []MacKegMachFile
	existing_paths            []string
	successful_operations     []string
	runtime_dependencies      []MacKegRuntimeDependency
	built_on_preferred_perl   string
	preferred_perl_version    string
	openjdk_dependency        ?string
}

pub fn mac_keg_file_linked_libraries(file MacKegMachFile, needle string) []string {
	if !(file.executable || file.dylib || file.bundle) {
		return []
	}
	return file.linked_libraries.filter(it.contains(needle))
}

pub fn mac_keg_change_id(change MacKegChange) string {
	return '${change.kind}:${change.file}:${change.old}:${change.new}'
}

fn mac_keg_change_succeeded(context MacKegRelocationContext, change MacKegChange) bool {
	return mac_keg_change_id(change) in context.successful_operations
}

fn mac_keg_join(left string, right string) string {
	if left == '' {
		return right
	}
	return '${left.trim_string_right('/')}/${right.trim_string_left('/')}'
}

fn mac_keg_relative_path(from_directory string, target_directory string) string {
	from_parts := os.norm_path(from_directory).trim('/').split('/').filter(it != '')
	target_parts := os.norm_path(target_directory).trim('/').split('/').filter(it != '')
	mut common := 0
	for common < from_parts.len && common < target_parts.len && from_parts[common] == target_parts[common] {
		common++
	}
	mut parts := []string{}
	for _ in common .. from_parts.len {
		parts << '..'
	}
	parts << target_parts[common..]
	return if parts.len == 0 { '.' } else { parts.join('/') }
}

fn mac_keg_variable_reference(name string) bool {
	return name.starts_with('@loader_path') || name.starts_with('@executable_path') || name.starts_with('@rpath')
}

pub fn mac_keg_each_linkage_for(file MacKegMachFile, linkage_type string,
	resolve_variable_references bool) []string {
	values := match linkage_type {
		'dynamically_linked_libraries' { file.linked_libraries }
		'rpaths' {
			if resolve_variable_references && file.resolved_rpaths.len > 0 {
				file.resolved_rpaths
			} else {
				file.rpaths
			}
		}
		else { []string{} }
	}
	return values.filter(!mac_keg_variable_reference(it))
}

pub fn mac_keg_relocated_name_for(old_name string,
	relocation MacKegRelocation) ?string {
	cellar := relocation.pairs['cellar'] or { MacKegReplacementPair{} }
	prefix := relocation.pairs['prefix'] or { MacKegReplacementPair{} }
	if cellar.old != '' && old_name.starts_with(cellar.old) {
		return old_name.replace_once(cellar.old, cellar.new)
	}
	if prefix.old != '' && old_name.starts_with(prefix.old) {
		return old_name.replace_once(prefix.old, prefix.new)
	}
	return none
}

pub fn mac_keg_find_dylib_suffix_from(bad_name string) string {
	marker := '.framework/'
	index := bad_name.index(marker) or { return os.base(bad_name) }
	framework_start := bad_name[..index].last_index('/') or { -1 }
	framework_name := bad_name[framework_start + 1..index]
	mut remainder := bad_name[index + marker.len..]
	if remainder.starts_with('Versions/') {
		parts := remainder.split('/')
		if parts.len < 3 {
			return os.base(bad_name)
		}
		remainder = parts[2..].join('/')
	}
	if remainder == framework_name {
		return '${framework_name}.framework/${bad_name[index + marker.len..]}'
	}
	return os.base(bad_name)
}

pub fn mac_keg_find_dylib(context MacKegRelocationContext, bad_name string) ?string {
	if context.lib == '' || context.lib !in context.existing_paths {
		return none
	}
	suffix := '/${mac_keg_find_dylib_suffix_from(bad_name)}'
	for path in context.existing_paths {
		if path.starts_with('${context.lib.trim_string_right('/')}/') && path.ends_with(suffix) {
			return path
		}
	}
	return none
}

pub fn mac_keg_loader_name_for(context MacKegRelocationContext, file MacKegMachFile,
	target string) string {
	if !context.relocatable_install_names || !target.starts_with(context.prefix) {
		return target
	}
	suffix := mac_keg_find_dylib_suffix_from(target)
	target_dir := os.norm_path(target[..target.len - suffix.len].trim_string_right('/'))
	relative := mac_keg_relative_path(os.dir(file.path), target_dir)
	return if relative == '.' {
		'@loader_path/${suffix}'
	} else {
		'@loader_path/${relative}/${suffix}'
	}
}

pub fn mac_keg_fixed_name(context MacKegRelocationContext, file MacKegMachFile,
	bad_name string) MacKegNameResult {
	if bad_name.starts_with('@@HOMEBREW_PREFIX@@') {
		return MacKegNameResult{
			name: bad_name.replace_once('@@HOMEBREW_PREFIX@@', context.prefix)
		}
	}
	if bad_name.starts_with('@@HOMEBREW_CELLAR@@') {
		return MacKegNameResult{
			name: bad_name.replace_once('@@HOMEBREW_CELLAR@@', context.cellar)
		}
	}
	if (file.dylib || file.bundle) && mac_keg_join(os.dir(file.path), bad_name) in context.existing_paths {
		return MacKegNameResult{
			name: '@loader_path/${bad_name}'
		}
	}
	lib_name := mac_keg_join(context.lib, bad_name)
	if file.executable && lib_name in context.existing_paths {
		return MacKegNameResult{
			name: lib_name
		}
	}
	libexec_name := mac_keg_join(mac_keg_join(context.libexec, 'lib'), bad_name)
	if file.executable && libexec_name in context.existing_paths {
		return MacKegNameResult{
			name: libexec_name
		}
	}
	if found := mac_keg_find_dylib(context, bad_name) {
		if found in context.existing_paths {
			return MacKegNameResult{
				name: found
			}
		}
	}
	return MacKegNameResult{
		name: bad_name
		warnings: ['Could not fix ${bad_name} in ${file.path}']
	}
}

pub fn mac_keg_formula_preserve_rpath(context MacKegRelocationContext) bool {
	return context.formula_available && context.formula_preserve_rpath
}

pub fn mac_keg_dylib_id_for(context MacKegRelocationContext, file MacKegMachFile) string {
	id := file.dylib_id or { panic('dylib_id_for requires a dylib ID') }
	if id.starts_with('/usr/lib/swift/libswift') || (id.starts_with('@rpath') && mac_keg_formula_preserve_rpath(context)) {
		return id
	}
	relative_directory := mac_keg_relative_path(context.path, os.dir(file.path))
	return os.norm_path(mac_keg_join(mac_keg_join(context.opt_record, relative_directory), os.base(id)))
}

pub fn mac_keg_opt_name_for(context MacKegRelocationContext, filename string) string {
	if !filename.starts_with(context.prefix) || filename.starts_with(context.path) {
		return filename
	}
	remainder := filename[context.cellar.trim_string_right('/').len..].trim_string_left('/')
	parts := remainder.split('/')
	if !filename.starts_with('${context.cellar.trim_string_right('/')}/') || parts.len < 3 {
		return filename
	}
	return filename.replace_once('${context.cellar.trim_string_right('/')}/${parts[0]}/${parts[1]}', '${context.prefix.trim_string_right('/')}/opt/${parts[0]}')
}

pub fn mac_keg_rooted_in_build_directory(context MacKegRelocationContext,
	filename string) bool {
	if context.temp == '/private/tmp' && filename.starts_with('/tmp/') {
		return true
	}
	return (context.temp != '' && filename.starts_with(context.temp)) || (context.temp_realpath != '' && filename.starts_with(context.temp_realpath))
}

pub fn mac_keg_relocation_mach_o_files(context MacKegRelocationContext) []MacKegMachFile {
	mut seen := map[string]bool{}
	mut files := []MacKegMachFile{}
	for file in context.files {
		if file.symlink || file.directory || !(file.dylib || file.bundle || file.executable) {
			continue
		}
		key := '${file.device}:${file.inode}'
		if key in seen {
			continue
		}
		seen[key] = true
		files << file
	}
	return files
}

fn mac_keg_record_change(context MacKegRelocationContext, change MacKegChange,
	mut changes []MacKegChange) bool {
	changes << change
	return mac_keg_change_succeeded(context, change)
}

pub fn mac_keg_relocate_dynamic_linkage(context MacKegRelocationContext,
	relocation MacKegRelocation, _skip_protodesc_cold bool) MacKegRelocationResult {
	mut changes := []MacKegChange{}
	mut signed := []string{}
	for file in mac_keg_relocation_mach_o_files(context) {
		mut changed := false
		if file.dylib {
			if id := file.dylib_id {
				if relocated := mac_keg_relocated_name_for(id, relocation) {
					change := MacKegChange{
						kind: .dylib_id
						file: file.path
						old: id
						new: relocated
					}
					changed = mac_keg_record_change(context, change, mut changes) || changed
				}
			}
		}
		for old_name in mac_keg_each_linkage_for(file, 'dynamically_linked_libraries', false) {
			if relocated := mac_keg_relocated_name_for(old_name, relocation) {
				change := MacKegChange{
					kind: .install_name
					file: file.path
					old: old_name
					new: relocated
				}
				changed = mac_keg_record_change(context, change, mut changes) || changed
			}
		}
		for old_name in mac_keg_each_linkage_for(file, 'rpaths', false) {
			if relocated := mac_keg_relocated_name_for(old_name, relocation) {
				change := MacKegChange{
					kind: .rpath
					file: file.path
					old: old_name
					new: relocated
				}
				changed = mac_keg_record_change(context, change, mut changes) || changed
			}
		}
		if changed {
			signed << file.path
		}
	}
	return MacKegRelocationResult{
		changes: changes
		codesigned: signed
	}
}

pub fn mac_keg_fix_dynamic_linkage(context MacKegRelocationContext) MacKegRelocationResult {
	mut changes := []MacKegChange{}
	mut signed := []string{}
	mut warnings := []string{}
	for file in mac_keg_relocation_mach_o_files(context) {
		mut changed := false
		if file.dylib {
			id := file.dylib_id or { '' }
			if id != '' {
				change := MacKegChange{
					kind: .dylib_id
					file: file.path
					old: id
					new: mac_keg_dylib_id_for(context, file)
				}
				changed = mac_keg_record_change(context, change, mut changes) || changed
			}
		}
		for bad_name in mac_keg_each_linkage_for(file, 'dynamically_linked_libraries', false) {
			fixed := if bad_name.starts_with('/') && !mac_keg_rooted_in_build_directory(context, bad_name) {
				MacKegNameResult{
					name: bad_name
				}
			} else {
				mac_keg_fixed_name(context, file, bad_name)
			}
			warnings << fixed.warnings
			loader_name := mac_keg_loader_name_for(context, file, fixed.name)
			if loader_name != bad_name {
				change := MacKegChange{
					kind: .install_name
					file: file.path
					old: bad_name
					new: loader_name
				}
				changed = mac_keg_record_change(context, change, mut changes) || changed
			}
		}
		for bad_name in mac_keg_each_linkage_for(file, 'rpaths', false) {
			new_name := mac_keg_opt_name_for(context, bad_name)
			loader_name := mac_keg_loader_name_for(context, file, new_name)
			if loader_name != bad_name {
				change := MacKegChange{
					kind: .rpath
					file: file.path
					old: bad_name
					new: loader_name
				}
				changed = mac_keg_record_change(context, change, mut changes) || changed
			}
		}
		for bad_name in mac_keg_each_linkage_for(file, 'rpaths', true) {
			if !mac_keg_rooted_in_build_directory(context, bad_name) && file.rpaths.filter(it == bad_name).len == 1 {
				continue
			}
			change := MacKegChange{
				kind: .delete_rpath
				file: file.path
				old: bad_name
			}
			changed = mac_keg_record_change(context, change, mut changes) || changed
		}
		if changed {
			signed << file.path
		}
	}
	return MacKegRelocationResult{
		changes: changes
		codesigned: signed
		warnings: warnings
		super_called: true
	}
}

fn mac_keg_numeric_perl_version(version string) bool {
	parts := version.split('.')
	return parts.len == 2 && parts.all(it != '' && it.bytes().all(it.is_digit()))
}

pub fn mac_keg_prepare_relocation_to_locations(context MacKegRelocationContext,
	base MacKegRelocation) MacKegRelocation {
	mut relocation := MacKegRelocation{
		pairs: base.pairs.clone()
	}
	brewed_perl := context.runtime_dependencies.any(it.full_name == 'perl' && it.declared_directly)
	mut perl_path := ''
	if brewed_perl || context.name == 'perl' {
		perl_path = mac_keg_join(context.prefix, 'opt/perl/bin/perl')
	} else if mac_keg_numeric_perl_version(context.built_on_preferred_perl) {
		built_perl := '/usr/bin/perl${context.built_on_preferred_perl}'
		if built_perl in context.existing_paths {
			perl_path = built_perl
		}
	}
	if perl_path == '' {
		perl_path = '/usr/bin/perl${context.preferred_perl_version}'
	}
	relocation.pairs['perl'] = MacKegReplacementPair{
		old: '@@HOMEBREW_PERL@@'
		new: perl_path
	}
	if openjdk := context.openjdk_dependency {
		relocation.pairs['java'] = MacKegReplacementPair{
			old: '@@HOMEBREW_JAVA@@'
			new: mac_keg_join(context.prefix, 'opt/${openjdk}/libexec/openjdk.jdk/Contents/Home')
		}
	}
	return relocation
}

pub fn mac_keg_recursive_fgrep_args() string {
	return '-lrO'
}

pub fn mac_keg_egrep_args() []string {
	return ['egrep', '--files-with-matches']
}
