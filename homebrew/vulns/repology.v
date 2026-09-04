module vulns

import net.urllib
import x.json2

// Translated from Homebrew/brew `vulns/repology.rb`.
pub const repology_data_url = 'https://raw.githubusercontent.com/Homebrew/advisory-database/main/data/repology.json'
pub const repology_cache_filename = 'repology.json'
pub const repology_default_max_age = i64(7 * 86_400)
pub const repology_api_base = 'https://repology.org/api/v1'

pub type RepologyDistroMap = map[string][]string

pub struct RepologyDatabase {
	formula_values map[string]json2.Any
	meta_values    map[string]json2.Any
}

pub struct RepologyEntry {
pub:
	repo    string
	srcname string
	binname string
	status  string
}

pub struct RepologyContribution {
pub:
	preferred bool
	distros   RepologyDistroMap
}

pub type RepologyFetch = fn (string) ![]RepologyEntry

pub type RepologyHttpGet = fn (string) !string

pub type RepologyReadFile = fn (string) !string

pub type RepologyWriteFile = fn (string, string) !

pub type RepologyRenameFile = fn (string, string) !

pub type RepologyRemoveFile = fn (string) !

pub type RepologyMakeDirectory = fn (string) !

pub type RepologyPathExists = fn (string) bool

pub type RepologyModifiedTime = fn (string) !i64

pub type RepologyFeedFetch = fn (string) !string

pub type RepologyClock = fn () i64

pub type RepologyWarning = fn (string)

pub struct RepologyIo {
pub:
	read_file      RepologyReadFile @[required]
	write_file     RepologyWriteFile @[required]
	rename_file    RepologyRenameFile @[required]
	remove_file    RepologyRemoveFile @[required]
	make_directory RepologyMakeDirectory @[required]
	path_exists    RepologyPathExists @[required]
	modified_time  RepologyModifiedTime @[required]
	fetch          RepologyFeedFetch @[required]
	now            RepologyClock @[required]
	warn           RepologyWarning @[required]
}

fn repology_string(value json2.Any) string {
	if value is string {
		return value
	}
	return ''
}

fn repology_entry_from_json(value json2.Any) ?RepologyEntry {
	if value !is map[string]json2.Any {
		return none
	}
	entry := value.as_map()
	return RepologyEntry{
		repo: if current := entry['repo'] { repology_string(current) } else { '' }
		srcname: if current := entry['srcname'] { repology_string(current) } else { '' }
		binname: if current := entry['binname'] { repology_string(current) } else { '' }
		status: if current := entry['status'] { repology_string(current) } else { '' }
	}
}

fn repology_entry_json(entry RepologyEntry) json2.Any {
	mut values := {
		'repo': json2.Any(entry.repo)
	}
	if entry.srcname != '' {
		values['srcname'] = json2.Any(entry.srcname)
	}
	if entry.binname != '' {
		values['binname'] = json2.Any(entry.binname)
	}
	if entry.status != '' {
		values['status'] = json2.Any(entry.status)
	}
	return json2.Any(values)
}

pub fn new_repology_database(data json2.Any) !RepologyDatabase {
	if data !is map[string]json2.Any {
		return error('Repology index is not a JSON object')
	}
	top := data.as_map()
	formulae_value := top['formulae'] or { return error("Repology index missing 'formulae' key") }
	if formulae_value !is map[string]json2.Any {
		return error("Repology index missing 'formulae' key")
	}
	mut meta := map[string]json2.Any{}
	if meta_value := top['meta'] {
		if meta_value is map[string]json2.Any {
			meta = meta_value.clone()
		}
	}
	return RepologyDatabase{
		formula_values: formulae_value.as_map().clone()
		meta_values: meta
	}
}

pub fn parse_repology_database(contents string) !RepologyDatabase {
	data := json2.decode[json2.Any](contents) or {
		return error('Failed to parse ${repology_cache_filename}: ${err.msg()}')
	}
	return new_repology_database(data)
}

pub fn repology_from_file(path string, read_file RepologyReadFile) !RepologyDatabase {
	contents := read_file(path)!
	data := json2.decode[json2.Any](contents) or {
		return error('Failed to parse ${repology_cache_filename} at ${path}: ${err.msg()}')
	}
	return new_repology_database(data)
}

pub fn (database RepologyDatabase) meta() map[string]json2.Any {
	return database.meta_values.clone()
}

pub fn (database RepologyDatabase) formulae() []string {
	mut names := database.formula_values.keys()
	names.sort()
	return names
}

pub fn repology_base_name(name string) string {
	index := name.index('@') or { return name }
	if index + 1 >= name.len {
		return name
	}
	return name[..index]
}

fn repology_string_list(value json2.Any) []string {
	if value is []json2.Any {
		mut result := []string{}
		for item in value {
			if item is string {
				result << item
			}
		}
		return result
	}
	if value is string {
		return [value]
	}
	return []string{}
}

pub fn (database RepologyDatabase) distro_packages_for(formula_name string) RepologyDistroMap {
	entry := database.formula_values[formula_name] or {
		database.formula_values[repology_base_name(formula_name)] or {
			return RepologyDistroMap{}
		}
	}
	if entry !is map[string]json2.Any {
		return RepologyDistroMap{}
	}
	mut result := RepologyDistroMap{}
	for ecosystem, raw_names in entry.as_map() {
		names := repology_string_list(raw_names)
		if names.len > 0 {
			result[ecosystem] = names
		}
	}
	return result
}

pub fn repology_name_candidates(formula_name string) []string {
	base := repology_base_name(formula_name)
	mut candidates := []string{}
	for candidate in [formula_name, base, base.trim_string_left('lib'),
		base.trim_string_left('gnu-'), base.trim_string_right('2')] {
		if candidate != '' && candidate !in candidates {
			candidates << candidate
		}
	}
	return candidates
}

pub fn repology_homebrew_entries(entries []RepologyEntry) map[string]bool {
	preferred_statuses := ['newest', 'outdated', 'devel', 'unique', 'noscheme']
	mut result := map[string]bool{}
	for entry in entries {
		if entry.repo != 'homebrew' {
			continue
		}
		name := if entry.srcname != '' { entry.srcname } else { entry.binname }
		if name == '' {
			continue
		}
		if name !in result {
			result[name] = false
		}
		if entry.status in preferred_statuses {
			result[name] = true
		}
	}
	return result
}

pub fn repology_distil(entries []RepologyEntry) RepologyDistroMap {
	prefixes := {
		'debian_':             'Debian'
		'ubuntu_':             'Ubuntu'
		'alpine_':             'Alpine'
		'opensuse_leap_':      'openSUSE'
		'opensuse_tumbleweed': 'openSUSE'
		'rocky_':              'Rocky Linux'
		'almalinux_':          'AlmaLinux'
		'mageia_':             'Mageia'
		'openeuler_':          'openEuler'
		'ubi_':                'Red Hat'
		'freebsd':             'FreeBSD'
	}
	mut collected := map[string][]string{}
	for entry in entries {
		mut ecosystem := ''
		for prefix, name in prefixes {
			if entry.repo.starts_with(prefix) {
				ecosystem = name
				break
			}
		}
		if ecosystem == '' || entry.status == 'legacy' {
			continue
		}
		name := if ecosystem == 'FreeBSD' && entry.binname != '' {
			entry.binname
		} else if entry.srcname != '' {
			entry.srcname
		} else {
			entry.binname
		}
		if name == '' {
			continue
		}
		mut names := collected[ecosystem] or { []string{} }
		if name !in names {
			names << name
		}
		collected[ecosystem] = names
	}
	mut result := RepologyDistroMap{}
	mut ecosystems := collected.keys()
	ecosystems.sort()
	for ecosystem in ecosystems {
		mut names := collected[ecosystem].clone()
		names.sort()
		result[ecosystem] = names
	}
	return result
}

pub fn repology_resolve_contributions(contributions []RepologyContribution) ?RepologyDistroMap {
	mut chosen := contributions.clone()
	if chosen.len != 1 {
		chosen = contributions.filter(it.preferred)
	}
	if chosen.len == 1 {
		return chosen[0].distros.clone()
	}
	return none
}

pub fn lookup_repology(formula_name string, fetch RepologyFetch) !RepologyDistroMap {
	base := repology_base_name(formula_name)
	mut exact := []RepologyContribution{}
	mut by_base := []RepologyContribution{}
	for candidate in repology_name_candidates(formula_name) {
		entries := fetch(candidate)!
		if entries.len == 0 {
			continue
		}
		brew := repology_homebrew_entries(entries)
		distros := repology_distil(entries)
		if distros.len == 0 {
			continue
		}
		if preferred := brew[formula_name] {
			exact << RepologyContribution{ preferred: preferred, distros: distros.clone() }
		}
		if base != formula_name {
			if preferred := brew[base] {
				by_base << RepologyContribution{ preferred: preferred, distros: distros.clone() }
			}
		}
	}
	if resolved := repology_resolve_contributions(exact) {
		return resolved
	}
	if resolved := repology_resolve_contributions(by_base) {
		return resolved
	}
	return RepologyDistroMap{}
}

fn repology_project_entry(projects map[string][]RepologyEntry, project string) ![]RepologyEntry {
	return (projects[project] or { []RepologyEntry{} }).clone()
}

pub fn lookup_repology_projects(formula_name string,
	projects map[string][]RepologyEntry) RepologyDistroMap {
	// This is the deterministic/offline form of the live lookup used by retained specs.
	base := repology_base_name(formula_name)
	mut exact := []RepologyContribution{}
	mut by_base := []RepologyContribution{}
	for candidate in repology_name_candidates(formula_name) {
		entries := repology_project_entry(projects, candidate) or { continue }
		if entries.len == 0 {
			continue
		}
		brew := repology_homebrew_entries(entries)
		distros := repology_distil(entries)
		if distros.len == 0 {
			continue
		}
		if preferred := brew[formula_name] {
			exact << RepologyContribution{ preferred: preferred, distros: distros.clone() }
		}
		if base != formula_name {
			if preferred := brew[base] {
				by_base << RepologyContribution{ preferred: preferred, distros: distros.clone() }
			}
		}
	}
	return repology_resolve_contributions(exact) or {
		repology_resolve_contributions(by_base) or { RepologyDistroMap{} }
	}
}

pub fn repology_single_package_query(project string, http_get RepologyHttpGet) !json2.Any {
	encoded := urllib.query_escape(project).replace('+', '%20')
	url := '${repology_api_base}/project/${encoded}'
	contents := http_get(url) or {
		return error('Repology API request for "${project}" failed: ${err.msg()}')
	}
	data := json2.decode[json2.Any](contents) or {
		return error('Repology API request for "${project}" failed: ${err.msg()}')
	}
	return json2.Any({
		project: data
	})
}

pub fn fetch_repology_project(project string, http_get RepologyHttpGet) ![]RepologyEntry {
	result := repology_single_package_query(project, http_get)!
	if result !is map[string]json2.Any {
		return error('Repology API returned unexpected shape for "${project}"')
	}
	entries_value := result.as_map()[project] or {
		return error('Repology API returned unexpected shape for "${project}"')
	}
	if entries_value !is []json2.Any {
		return error('Repology API returned unexpected shape for "${project}"')
	}
	mut entries := []RepologyEntry{}
	for raw_entry in entries_value as []json2.Any {
		entry := repology_entry_from_json(raw_entry) or {
			return error('Repology API returned unexpected shape for "${project}"')
		}
		entries << entry
	}
	return entries
}

fn repology_cache_path(cache_directory string) string {
	separator := if cache_directory == '' || cache_directory.ends_with('/') { '' } else { '/' }
	return '${cache_directory}${separator}${repology_cache_filename}'
}

pub fn refresh_repology(cache_file string, io RepologyIo) !RepologyDatabase {
	contents := io.fetch(repology_data_url)!
	slash := cache_file.last_index('/') or { -1 }
	parent := if slash >= 0 { cache_file[..slash] } else { '' }
	if parent != '' {
		io.make_directory(parent)!
	}
	temporary_file := '${cache_file}.download-${io.now()}'
	io.write_file(temporary_file, contents)!
	loaded := parse_repology_database(contents) or {
		io.remove_file(temporary_file) or {}
		return err
	}
	io.rename_file(temporary_file, cache_file) or {
		io.remove_file(temporary_file) or {}
		return err
	}
	return loaded
}

pub fn load_repology(cache_directory string, max_age i64, io RepologyIo) !RepologyDatabase {
	cache_file := repology_cache_path(cache_directory)
	exists := io.path_exists(cache_file)
	if exists {
		modified := io.modified_time(cache_file)!
		if io.now() - modified <= max_age {
			return repology_from_file(cache_file, io.read_file)
		}
	}
	return refresh_repology(cache_file, io) or {
		if !exists {
			return err
		}
		modified := io.modified_time(cache_file) or { 0 }
		message := err.msg().split_into_lines()[0]
		io.warn('Failed to refresh ${repology_cache_filename} (${message}); using cached copy from ${modified}.')
		return repology_from_file(cache_file, io.read_file)
	}
}
