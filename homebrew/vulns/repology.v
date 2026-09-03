module vulns

import net.urllib
import x.json2

// Translated from Homebrew/brew `vulns/repology.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type RepologyFetch = fn(string) ![]RepologyEntry

pub type RepologyHttpGet = fn(string) !string

pub type RepologyReadFile = fn(string) !string

pub type RepologyWriteFile = fn(string, string) !

pub type RepologyRenameFile = fn(string, string) !

pub type RepologyRemoveFile = fn(string) !

pub type RepologyMakeDirectory = fn(string) !

pub type RepologyPathExists = fn(string) bool

pub type RepologyModifiedTime = fn(string) !i64

pub type RepologyFeedFetch = fn(string) !string

pub type RepologyClock = fn() i64

pub type RepologyWarning = fn(string)

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

// Ruby method `self.data_url = DATA_URL` at line 22.
pub fn ruby_repology_l22_d1_self_data_url() string {
	return repology_data_url
}

// Ruby method `self.cache_filename = "repology.json"` at line 25.
pub fn ruby_repology_l25_d2_self_cache_filename() string {
	return repology_cache_filename
}

// Ruby method `self.default_max_age = 7 * 86_400` at line 28.
pub fn ruby_repology_l28_d3_self_default_max_age() i64 {
	return repology_default_max_age
}

// Ruby method `self.base_name(name) = name.sub(/@.+\z/, "")` at line 33.
pub fn ruby_repology_l33_d4_self_base_name(name string) string {
	return repology_base_name(name)
}

// Ruby method `initialize(data)` at line 36.
pub fn ruby_repology_l36_d5_initialize(data json2.Any) !RepologyDatabase {
	return new_repology_database(data)
}

// Ruby attr_reader `attr_reader :meta` at line 46.
pub fn ruby_repology_l46_d6_meta(database RepologyDatabase) map[string]json2.Any {
	return database.meta()
}

// Ruby method `formulae` at line 49.
pub fn ruby_repology_l49_d7_formulae(database RepologyDatabase) []string {
	return database.formulae()
}

// Ruby method `distro_packages_for(formula_name)` at line 58.
pub fn ruby_repology_l58_d8_distro_packages_for(database RepologyDatabase,
	formula_name string) RepologyDistroMap {
	return database.distro_packages_for(formula_name)
}

// Ruby method `self.lookup(formula_name)` at line 112.
pub fn ruby_repology_l112_d9_self_lookup(formula_name string,
	projects map[string][]RepologyEntry) RepologyDistroMap {
	return lookup_repology_projects(formula_name, projects)
}

// Ruby method `self.resolve_contributions(contributions)` at line 140.
pub fn ruby_repology_l140_d10_self_resolve_contributions(
	contributions []RepologyContribution) ?RepologyDistroMap {
	return repology_resolve_contributions(contributions)
}

// Ruby method `self.homebrew_entries(entries)` at line 146.
pub fn ruby_repology_l146_d11_self_homebrew_entries(entries []RepologyEntry) map[string]bool {
	return repology_homebrew_entries(entries)
}

// Ruby method `self.name_candidates(formula_name)` at line 161.
pub fn ruby_repology_l161_d12_self_name_candidates(formula_name string) []string {
	return repology_name_candidates(formula_name)
}

// Ruby method `self.fetch_project(project)` at line 177.
pub fn ruby_repology_l177_d13_self_fetch_project(project string,
	http_get RepologyHttpGet) ![]RepologyEntry {
	return fetch_repology_project(project, http_get)
}

// Ruby method `self.distil(entries)` at line 190.
pub fn ruby_repology_l190_d14_self_distil(entries []RepologyEntry) RepologyDistroMap {
	return repology_distil(entries)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/repology"
// 5: require "vulns/cached_feed"
// 6:
// 7: module Homebrew
// 8:   module Vulns
// 9:     # Reader for the Repology-derived formula → distro-package index published
// 10:     # by Homebrew/advisory-database (`data/repology.json`, built by that
// 11:     # repository's `RepologyIndex` via `rake repology:build`).
// 12:     #
// 13:     # The index maps each formula name to its source-package names in
// 14:     # OSV.dev-covered distro ecosystems so {Vulns::Match} can query those
// 15:     # ecosystems' advisories. {.lookup} provides a live single-project API
// 16:     # fallback for formulae the published index doesn't yet cover.
// 17:     class Repology < CachedFeed
// 18:       DATA_URL = "https://raw.githubusercontent.com/Homebrew/advisory-database/" \
// 19:                  "main/data/repology.json"
// 20:
// 21:       sig { override.returns(String) }
// 22:       def self.data_url = DATA_URL
// 23:
// 24:       sig { override.returns(String) }
// 25:       def self.cache_filename = "repology.json"
// 26:
// 27:       sig { override.returns(Integer) }
// 28:       def self.default_max_age = 7 * 86_400
// 29:
// 30:       DistroMap = T.type_alias { T::Hash[String, T::Array[String]] }
// 31:
// 32:       sig { params(name: String).returns(String) }
// 33:       def self.base_name(name) = name.sub(/@.+\z/, "")
// 34:
// 35:       sig { override.params(data: T.anything).void }
// 36:       def initialize(data)
// 37:         super
// 38:         raise Error, "Repology index is not a JSON object" unless (top = as_hash(data))
// 39:         raise Error, "Repology index missing 'formulae' key" unless (formulae = as_hash(top["formulae"]))
// 40:
// 41:         @formulae = T.let(formulae, T::Hash[String, T.untyped])
// 42:         @meta = T.let(as_hash(top["meta"]) || {}, T::Hash[String, T.untyped])
// 43:       end
// 44:
// 45:       sig { returns(T::Hash[String, T.untyped]) }
// 46:       attr_reader :meta
// 47:
// 48:       sig { returns(T::Array[String]) }
// 49:       def formulae
// 50:         @formulae.keys
// 51:       end
// 52:
// 53:       # Returns `{osv_ecosystem => [srcname, ...]}` for `formula_name`, or an
// 54:       # empty hash if the index has no entry. The index is keyed on the
// 55:       # Homebrew formula name as Repology records it, so `@`-versioned
// 56:       # variants (`postgresql@16`) are looked up under their base name too.
// 57:       sig { params(formula_name: String).returns(DistroMap) }
// 58:       def distro_packages_for(formula_name)
// 59:         entry = @formulae[formula_name] || @formulae[self.class.base_name(formula_name)]
// 60:         return {} unless entry.is_a?(Hash)
// 61:
// 62:         entry.filter_map do |eco, names|
// 63:           next unless eco.is_a?(String)
// 64:
// 65:           list = Array(names).grep(String)
// 66:           [eco, list.freeze] if list.any?
// 67:         end.to_h.freeze
// 68:       end
// 69:
// 70:       # Repology repo-name prefix => `{ecosystem:, name_field:}`. Kept in step
// 71:       # with `RepologyIndex::OSV_DISTROS` in Homebrew/advisory-database; only
// 72:       # the fields {.distil} needs are duplicated here.
// 73:       OSV_DISTROS = T.let(
// 74:         {
// 75:           "debian_"             => { ecosystem: "Debian" },
// 76:           "ubuntu_"             => { ecosystem: "Ubuntu" },
// 77:           "alpine_"             => { ecosystem: "Alpine" },
// 78:           "opensuse_leap_"      => { ecosystem: "openSUSE" },
// 79:           "opensuse_tumbleweed" => { ecosystem: "openSUSE" },
// 80:           "rocky_"              => { ecosystem: "Rocky Linux" },
// 81:           "almalinux_"          => { ecosystem: "AlmaLinux" },
// 82:           "mageia_"             => { ecosystem: "Mageia" },
// 83:           "openeuler_"          => { ecosystem: "openEuler" },
// 84:           "ubi_"                => { ecosystem: "Red Hat" },
// 85:           "freebsd"             => { ecosystem: "FreeBSD", name_field: "binname" },
// 86:         }.freeze,
// 87:         T::Hash[String, { ecosystem: String, name_field: T.nilable(String) }],
// 88:       )
// 89:       private_constant :OSV_DISTROS
// 90:
// 91:       # Kept in step with `RepologyIndex::PREFERRED_STATUSES`.
// 92:       PREFERRED_STATUSES = %w[newest outdated devel unique noscheme].freeze
// 93:       private_constant :PREFERRED_STATUSES
// 94:
// 95:       # Live single-project fallback for a formula the published index does
// 96:       # not cover: a new formula in a homebrew-core PR before the next nightly
// 97:       # index build, or one the index put in `meta.ambiguous_projects`.
// 98:       #
// 99:       # Fetches each project in {.name_candidates}, keeps those whose Homebrew
// 100:       # entries include `formula_name` (or its `@`-stripped base), then applies
// 101:       # the same preferred-status resolution as `RepologyIndex#resolve` across
// 102:       # the survivors. Unlike the index builder, a project that also lists
// 103:       # sibling formulae with a different base (`wget` + `wget2`, `sqlite` +
// 104:       # `sqlite-analyzer`, `ffmpeg` + a third-party `ffmpeg-full`) is *not*
// 105:       # rejected: the distro srcnames for the sibling flow through as extra
// 106:       # low-confidence distro queries whose upstream-CVE range check will not
// 107:       # match this formula's identity, so the cost is uncomparable noise rather
// 108:       # than a wrong `:affected`/`:fixed` claim. This cannot detect collisions
// 109:       # with projects outside {.name_candidates} (e.g. `allegro4`), which only
// 110:       # the full crawl sees.
// 111:       sig { params(formula_name: String).returns(DistroMap) }
// 112:       def self.lookup(formula_name)
// 113:         base = base_name(formula_name)
// 114:         exact = []
// 115:         by_base = []
// 116:         name_candidates(formula_name).each do |candidate|
// 117:           entries = fetch_project(candidate)
// 118:           next if entries.empty?
// 119:
// 120:           brew = homebrew_entries(entries)
// 121:           distros = distil(entries)
// 122:           next if distros.empty?
// 123:
// 124:           # A project listing both the exact and base names contributes to both
// 125:           # pools, matching the producer's per-key contributions.
// 126:           exact << { preferred: brew.fetch(formula_name), distros: } if brew.key?(formula_name)
// 127:           by_base << { preferred: brew.fetch(base), distros: } if base != formula_name && brew.key?(base)
// 128:         end
// 129:
// 130:         # Resolve the exact-name pool first, mirroring
// 131:         # `#distro_packages_for`'s `@formulae[name] || @formulae[base]`
// 132:         # precedence over the producer's per-key resolved index.
// 133:         resolve_contributions(exact) || resolve_contributions(by_base) || {}
// 134:       end
// 135:
// 136:       sig {
// 137:         params(contributions: T::Array[{ preferred: T::Boolean, distros: DistroMap }])
// 138:           .returns(T.nilable(DistroMap))
// 139:       }
// 140:       def self.resolve_contributions(contributions)
// 141:         chosen = contributions.one? ? contributions : contributions.select { |c| c.fetch(:preferred) }
// 142:         chosen.fetch(0).fetch(:distros) if chosen.one?
// 143:       end
// 144:
// 145:       sig { params(entries: T::Array[T::Hash[String, T.untyped]]).returns(T::Hash[String, T::Boolean]) }
// 146:       def self.homebrew_entries(entries)
// 147:         result = {}
// 148:         entries.each do |e|
// 149:           next if e["repo"] != "homebrew"
// 150:
// 151:           name = (e["srcname"] || e["binname"]).to_s
// 152:           next if name.empty?
// 153:
// 154:           result[name] ||= false
// 155:           result[name] = true if PREFERRED_STATUSES.include?(e["status"])
// 156:         end
// 157:         result
// 158:       end
// 159:
// 160:       sig { params(formula_name: String).returns(T::Array[String]) }
// 161:       def self.name_candidates(formula_name)
// 162:         base = base_name(formula_name)
// 163:         [
// 164:           formula_name,
// 165:           base,
// 166:           base.delete_prefix("lib"),
// 167:           base.delete_prefix("gnu-"),
// 168:           base.delete_suffix("2"),
// 169:         ].uniq.reject(&:empty?)
// 170:       end
// 171:
// 172:       # Fetch one Repology project. A nonexistent project returns HTTP 200 with
// 173:       # `[]`, so an empty array is the only "try next candidate" signal;
// 174:       # transport failures, HTTP errors, malformed JSON and unexpected shapes
// 175:       # all raise so callers don't mistake an outage for "no packages".
// 176:       sig { params(project: String).returns(T::Array[T::Hash[String, T.untyped]]) }
// 177:       def self.fetch_project(project)
// 178:         result = ::Repology.single_package_query(project, repository: ::Repology::HOMEBREW_CORE)
// 179:         raise Error, "Repology API request for #{project.inspect} failed" if result.nil?
// 180:
// 181:         entries = result.fetch(project)
// 182:         if !entries.is_a?(Array) || !entries.all?(Hash)
// 183:           raise Error, "Repology API returned unexpected shape for #{project.inspect}"
// 184:         end
// 185:
// 186:         entries
// 187:       end
// 188:
// 189:       sig { params(entries: T::Array[T::Hash[String, T.untyped]]).returns(DistroMap) }
// 190:       def self.distil(entries)
// 191:         result = Hash.new { |h, k| h[k] = [] }
// 192:         entries.each do |entry|
// 193:           repo = entry["repo"]
// 194:           next unless repo.is_a?(String)
// 195:
// 196:           distro = OSV_DISTROS.find { |prefix, _| repo.start_with?(prefix) }&.last
// 197:           next unless distro
// 198:           next if entry["status"] == "legacy"
// 199:
// 200:           name = entry[distro[:name_field] || "srcname"] || entry["binname"]
// 201:           next unless name.is_a?(String)
// 202:
// 203:           result[distro.fetch(:ecosystem)] << name
// 204:         end
// 205:         result.transform_values! { |names| names.uniq.sort.freeze }
// 206:         result.default = nil
// 207:         result.sort.to_h.freeze
// 208:       end
// 209:     end
// 210:   end
// 211: end
