module cmd

import ruby
import homebrew.utils
import os

const list_metafile_licenses = ['copying', 'copyright', 'license', 'licence']
const list_metafile_extensions = ['.adoc', '.asc', '.asciidoc', '.creole', '.html', '.markdown',
	'.md', '.mdown', '.mediawiki', '.mkdn', '.org', '.pod', '.rdoc', '.rst', '.rtf', '.textile',
	'.txt', '.wiki']
const list_metafile_basenames = ['about', 'authors', 'changelog', 'changes', 'history', 'news',
	'notes', 'notice', 'readme', 'todo']

fn list_metafile_copied(input string) bool {
	mut file := input.to_lower()
	mut separator := file.len
	for candidate in [file.index('.') or { file.len }, file.index('-') or { file.len }] {
		if candidate < separator {
			separator = candidate
		}
	}
	if file[..separator] in list_metafile_licenses {
		return true
	}
	extension := os.file_ext(file)
	if extension in list_metafile_extensions {
		file = file[..file.len - extension.len]
	}
	return file in list_metafile_basenames
}

fn list_metafile_listed(file string) bool {
	return file !in ['.DS_Store', 'INSTALL_RECEIPT.json'] && !list_metafile_copied(file)
}

// ListFormula and ListCask are the typed command-side projections of the Ruby
// Formula, Keg, Tab and Cask objects used by `brew list`. Paths are retained so
// callers can use either real Homebrew-style fixtures or completely in-memory
// package descriptions.
pub struct ListFormula {
pub:
	name                 string
	full_name            string
	rack                 string
	versions             []string
	tap                  string
	core_tap             bool
	receipt_error        bool
	installed_on_request bool
	poured_from_bottle   bool
	pin_target           string
	mtime                i64
}

pub struct ListArtifact {
pub:
	class_name   string
	english_name string
	summary      string
	display      string
}

pub struct ListCask {
pub:
	token         string
	full_name     string
	caskroom_path string
	versions      []string
	pin_target    string
	installed     bool = true
	artifacts     []ListArtifact
}

pub struct ListCommandRequest {
pub mut:
	formula                 bool
	cask                    bool
	full_name               bool
	versions                bool
	json                    bool
	multiple                bool
	pinned                  bool
	installed_on_request    bool
	no_installed_on_request bool
	installed_as_dependency bool
	poured_from_bottle      bool
	built_from_source       bool
	one                     bool
	long                    bool
	reverse                 bool
	time_sort               bool
	verbose                 bool
	stdout_tty              bool
	console_width           int = 80
	named                   []string
	formulae                []ListFormula
	casks                   []ListCask
	cellar                  string
	caskroom                string
	pinned_kegs             string
	pinned_casks            string
}

pub struct ListCommandResult {
pub mut:
	stdout string
	stderr string
	failed bool
	error  string
}

fn list_bool(value ruby.Value, key string) bool {
	return if item := value.map_data[key] { item.as_bool() or { false } } else { false }
}

fn list_string(value ruby.Value, key string) string {
	return if item := value.map_data[key] {
		item.as_string()
	} else {
		value.attributes[key] or { '' }
	}
}

fn list_strings(value ruby.Value, key string) []string {
	if item := value.map_data[key] {
		return item.as_string_array() or { []string{} }
	}
	raw := value.attributes[key] or { return [] }
	return if raw == '' { [] } else { raw.split('\x1f') }
}

fn list_formula_from_value(value ruby.Value) ListFormula {
	name := value.attributes['name'] or { value.repr.all_after_last('/') }
	return ListFormula{
		name: name
		full_name: value.attributes['full_name'] or { value.repr }
		rack: value.attributes['rack'] or { '' }
		versions: list_strings(value, 'versions')
		tap: value.attributes['tap'] or { '' }
		core_tap: (value.attributes['core_tap'] or { 'false' }) == 'true'
		receipt_error: (value.attributes['receipt_error'] or { 'false' }) == 'true'
		installed_on_request: (value.attributes['installed_on_request'] or { 'false' }) == 'true'
		poured_from_bottle: (value.attributes['poured_from_bottle'] or { 'false' }) == 'true'
		pin_target: value.attributes['pin_target'] or { '' }
		mtime: (value.attributes['mtime'] or { '0' }).i64()
	}
}

fn list_artifact_from_value(value ruby.Value) ListArtifact {
	return ListArtifact{
		class_name: value.attributes['class_name'] or { value.type_name }
		english_name: value.attributes['english_name'] or { value.type_name }
		summary: value.attributes['summary'] or { '' }
		display: value.attributes['display'] or { value.repr }
	}
}

fn list_cask_from_value(value ruby.Value) ListCask {
	artifact_values := (value.map_data['artifacts'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	return ListCask{
		token: value.attributes['token'] or { value.repr.all_after_last('/') }
		full_name: value.attributes['full_name'] or { value.repr }
		caskroom_path: value.attributes['caskroom_path'] or { '' }
		versions: list_strings(value, 'versions')
		pin_target: value.attributes['pin_target'] or { '' }
		installed: (value.attributes['installed'] or { 'true' }) == 'true'
		artifacts: artifact_values.map(list_artifact_from_value(it))
	}
}

fn list_request_from_value(value ruby.Value) ListCommandRequest {
	formula_values := (value.map_data['formulae'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	cask_values := (value.map_data['casks'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	width := if item := value.map_data['console_width'] { int(item.as_int() or { 80 }) } else { 80 }
	return ListCommandRequest{
		formula: list_bool(value, 'formula')
		cask: list_bool(value, 'cask')
		full_name: list_bool(value, 'full_name')
		versions: list_bool(value, 'versions')
		json: list_bool(value, 'json')
		multiple: list_bool(value, 'multiple')
		pinned: list_bool(value, 'pinned')
		installed_on_request: list_bool(value, 'installed_on_request')
		no_installed_on_request: list_bool(value, 'no_installed_on_request')
		installed_as_dependency: list_bool(value, 'installed_as_dependency')
		poured_from_bottle: list_bool(value, 'poured_from_bottle')
		built_from_source: list_bool(value, 'built_from_source')
		one: list_bool(value, 'one')
		long: list_bool(value, 'long')
		reverse: list_bool(value, 'reverse')
		time_sort: list_bool(value, 'time_sort')
		verbose: list_bool(value, 'verbose')
		stdout_tty: list_bool(value, 'stdout_tty')
		console_width: width
		named: list_strings(value, 'named')
		formulae: formula_values.map(list_formula_from_value(it))
		casks: cask_values.map(list_cask_from_value(it))
		cellar: list_string(value, 'cellar')
		caskroom: list_string(value, 'caskroom')
		pinned_kegs: list_string(value, 'pinned_kegs')
		pinned_casks: list_string(value, 'pinned_casks')
	}
}

fn list_result_value(result ListCommandResult) ruby.Value {
	return ruby.Value{
		type_name: if result.error == '' { 'ListCommandResult' } else { 'UsageError' }
		repr: if result.error == '' { result.stdout } else { result.error }
		bool_data: result.failed
		attributes: {
			'stdout': result.stdout
			'stderr': result.stderr
			'failed': result.failed.str()
			'error':  result.error
		}
	}
}

fn list_tap_and_name_compare(left &string, right &string) int {
	left_tapped := left.contains('/')
	right_tapped := right.contains('/')
	if left_tapped && !right_tapped {
		return 1
	}
	if !left_tapped && right_tapped {
		return -1
	}
	return left.compare(right)
}

pub fn list_sort_tap_and_name(values []string) []string {
	mut sorted := values.clone()
	sorted.sort_with_compare(list_tap_and_name_compare)
	return sorted
}

fn list_line(line string) string {
	return if line == '' { '' } else { '${line}\n' }
}

fn list_warning(mut result ListCommandResult, message string) {
	result.stderr += 'Warning: ${message}\n'
}

fn list_formula_versions(formula ListFormula) []string {
	if formula.versions.len > 0 {
		return formula.versions.clone()
	}
	if formula.rack == '' || !os.is_dir(formula.rack) {
		return []
	}
	mut versions := []string{}
	for child in os.ls(formula.rack) or { []string{} } {
		if os.is_dir(os.join_path(formula.rack, child)) {
			versions << child
		}
	}
	return versions
}

fn list_resolved_pin_target(pin_path string) string {
	if !os.is_link(pin_path) || !os.exists(pin_path) {
		return ''
	}
	return os.base(os.real_path(pin_path))
}

pub fn list_pinned_formula_entry(name string, pin_path string, versions bool) ?string {
	if !os.is_link(pin_path) {
		return none
	}
	if !versions {
		return name
	}
	target := os.readlink(pin_path) or { return name }
	return '${name} ${os.base(target)}'
}

pub fn list_pinned_cask_entry(token string, pin_path string, versions bool) ?string {
	if !os.is_link(pin_path) || !os.exists(pin_path) {
		return none
	}
	if !versions {
		return token
	}
	return '${token} ${list_resolved_pin_target(pin_path)}'
}

fn list_formula_pin_entry(formula ListFormula, request ListCommandRequest) ?string {
	if formula.pin_target != '' {
		return if request.versions {
			'${formula.name} ${os.base(formula.pin_target)}'
		} else {
			formula.name
		}
	}
	if request.pinned_kegs == '' {
		return none
	}
	return list_pinned_formula_entry(formula.name, os.join_path(request.pinned_kegs, formula.name), request.versions)
}

fn list_cask_pin_entry(cask ListCask, request ListCommandRequest) ?string {
	if cask.pin_target != '' {
		return if request.versions {
			'${cask.token} ${os.base(cask.pin_target)}'
		} else {
			cask.token
		}
	}
	if request.pinned_casks == '' {
		return none
	}
	return list_pinned_cask_entry(cask.token, os.join_path(request.pinned_casks, cask.token), request.versions)
}

fn list_named_formula(name string, formulae []ListFormula) ?ListFormula {
	short := name.all_after_last('/')
	for formula in formulae {
		if formula.name == short || formula.full_name == name {
			return formula
		}
	}
	return none
}

fn list_named_cask(name string, casks []ListCask) ?ListCask {
	short := name.all_after_last('/')
	for cask in casks {
		if cask.token == short || cask.full_name == name {
			return cask
		}
	}
	return none
}

fn list_cask_versioned(cask ListCask) string {
	return if cask.versions.len > 0 { '${cask.token} ${cask.versions.last()}' } else { cask.token }
}

fn list_cask_artifacts(cask ListCask) string {
	mut classes := map[string][]ListArtifact{}
	mut names := map[string]string{}
	for artifact in cask.artifacts {
		if artifact.class_name in ['Uninstall', 'Zap', 'Cask::Artifact::Uninstall',
			'Cask::Artifact::Zap'] {
			continue
		}
		classes[artifact.class_name] << artifact
		names[artifact.class_name] = artifact.english_name
	}
	mut keys := classes.keys()
	keys.sort_with_compare(fn [names] (left &string, right &string) int {
		return (names[*left] or { *left }).compare(names[*right] or { *right })
	})
	mut output := ''
	for key in keys {
		output += list_line('==> ${names[key] or { key }}')
		for artifact in classes[key] {
			output += list_line(if artifact.summary != '' {
				artifact.summary
			} else {
				artifact.display
			})
		}
	}
	return output
}

pub fn list_casks_output(casks []ListCask, explicit bool, one bool, full_name bool,
	versions bool, width int, tty bool) !string {
	for cask in casks {
		if !cask.installed {
			return error('CaskNotInstalledError: ${cask.token}')
		}
	}
	if casks.len == 0 {
		return ''
	}
	if one {
		return '${casks.map(it.token).join('\n')}\n'
	}
	if full_name {
		return '${list_sort_tap_and_name(casks.map(it.full_name)).join('\n')}\n'
	}
	if versions {
		return '${casks.map(list_cask_versioned(it)).join('\n')}\n'
	}
	if explicit {
		return casks.map(list_cask_artifacts(it)).join('')
	}
	return utils.formatter_columns(casks.map(it.token), width, tty, 2, 0)
}

fn list_recursive_files(root string) []string {
	if !os.is_dir(root) {
		return []
	}
	mut files := []string{}
	for path in os.walk_ext(root, '', hidden: true) {
		if !os.is_dir(path) && os.base(path) != '.DS_Store' {
			files << path
		}
	}
	files.sort()
	return files
}

pub fn list_print_remaining_files(files []string, root string, other string) string {
	if files.len == 1 {
		return '${files[0]}\n'
	}
	if files.len > 1 {
		return '${root}/ (${files.len} ${other}files)\n'
	}
	return ''
}

pub fn list_print_dir(root string, valid_extensions []string) string {
	mut dirs := []string{}
	mut remaining := []string{}
	mut other := ''
	mut output := ''
	mut children := os.ls(root) or { return '' }
	children.sort()
	for child in children {
		path := os.join_path(root, child)
		if os.is_dir(path) {
			dirs << path
		} else if valid_extensions.len > 0 && os.file_ext(path) in valid_extensions && !os.is_link(path) {
			output += list_line(path)
			other = 'other '
		} else if child != '.DS_Store' {
			remaining << path
		}
	}
	for directory in dirs {
		output += list_print_remaining_files(list_recursive_files(directory), directory, '')
	}
	output += list_print_remaining_files(remaining, root, other)
	return output
}

pub fn pretty_listing(path string) string {
	if !os.is_dir(path) {
		return ''
	}
	valid_lib_extensions := ['.cps', '.dylib', '.pc']
	mut children := os.ls(path) or { return '' }
	children.sort_with_compare(fn (left &string, right &string) int {
		return left.to_lower().compare(right.to_lower())
	})
	mut output := ''
	for child in children {
		pn := os.join_path(path, child)
		match child {
			'bin', 'sbin' {
				for file in list_recursive_files(pn) {
					output += list_line(file)
				}
			}
			'lib' {
				output += list_print_dir(pn, valid_lib_extensions)
			}
			'.brew' {}
			else {
				if os.is_dir(pn) {
					if os.is_link(pn) {
						target := os.readlink(pn) or { '' }
						output += list_line('${pn} -> ${target}')
					} else {
						output += list_print_dir(pn, [])
					}
				} else if list_metafile_listed(child) {
					output += list_line(pn)
				}
			}
		}
	}
	return output
}

fn list_existing_formulae(request ListCommandRequest) []ListFormula {
	if request.formulae.len > 0 {
		return request.formulae.clone()
	}
	if request.cellar == '' || !os.is_dir(request.cellar) {
		return []
	}
	mut formulae := []ListFormula{}
	for name in os.ls(request.cellar) or { []string{} } {
		rack := os.join_path(request.cellar, name)
		if os.is_dir(rack) {
			formulae << ListFormula{ name: name, full_name: name, rack: rack }
		}
	}
	return formulae
}

fn list_existing_casks(request ListCommandRequest) []ListCask {
	if request.casks.len > 0 {
		return request.casks.clone()
	}
	if request.caskroom == '' || !os.is_dir(request.caskroom) {
		return []
	}
	mut names := []string{}
	for entry in os.ls(request.caskroom) or { []string{} } {
		path := os.join_path(request.caskroom, entry)
		if os.is_file(path) && !os.is_link(path) {
			continue
		}
		name := if os.is_link(path) && os.exists(path) {
			os.base(os.real_path(path))
		} else {
			entry
		}
		if name !in names {
			names << name
		}
	}
	names.sort()
	return names.map(ListCask{
		token: it
		full_name: it
		caskroom_path: os.join_path(request.caskroom, it)
		versions: if os.is_dir(os.join_path(request.caskroom, it)) {
			mut found := os.ls(os.join_path(request.caskroom, it)) or { []string{} }
			found.sort()
			found
		} else {
			[]string{}
		}
	})
}

fn list_broken_caskroom_symlinks(caskroom string) []string {
	if caskroom == '' || !os.is_dir(caskroom) {
		return []
	}
	mut broken := []string{}
	for entry in os.ls(caskroom) or { []string{} } {
		path := os.join_path(caskroom, entry)
		if os.is_link(path) && !os.exists(path) {
			broken << entry
		}
	}
	broken.sort()
	return broken
}

fn list_bare_cask_names(caskroom string, casks []ListCask) []string {
	mut names := []string{}
	if caskroom != '' && os.is_dir(caskroom) {
		for entry in os.ls(caskroom) or { []string{} } {
			path := os.join_path(caskroom, entry)
			if !os.is_file(path) || os.is_link(path) {
				names << entry
			}
		}
	} else {
		names = casks.map(it.token)
	}
	names.sort()
	return names
}

fn list_named_casks(request ListCommandRequest, all_casks []ListCask, mut result ListCommandResult) []ListCask {
	mut selected := []ListCask{}
	for name in request.named {
		if cask := list_named_cask(name, all_casks) {
			selected << cask
		} else if request.caskroom != '' && os.exists(os.join_path(request.caskroom, name)) {
			selected << ListCask{
				token: name.all_after_last('/')
				full_name: name
				caskroom_path: os.join_path(request.caskroom, name)
			}
		} else {
			result.failed = true
		}
	}
	return selected
}

pub fn run_list_command(request ListCommandRequest) ListCommandResult {
	mut result := ListCommandResult{}
	if request.json {
		if !request.versions {
			result.error = '`brew list --json` requires `--versions`.'
			return result
		}
		if request.named.len > 0 {
			result.error = '`brew list --versions --json` does not support named arguments.'
			return result
		}
		result.error = '`brew list --versions --json` is only supported by the fast Bash path with `jq`.'
		return result
	}

	formulae := list_existing_formulae(request)
	casks := list_existing_casks(request)
	installed_as_dependency := request.no_installed_on_request || request.installed_as_dependency
	if request.full_name && !(request.installed_on_request || installed_as_dependency || request.poured_from_bottle || request.built_from_source) {
		if !request.cask {
			mut names := []string{}
			if request.named.len == 0 {
				for formula in formulae {
					if formula.receipt_error {
						list_warning(mut result, 'Could not identify the tap for ${formula.name} from its installation receipt.')
					}
					name := if formula.receipt_error || formula.tap == '' || formula.core_tap {
						formula.name
					} else {
						'${formula.tap}/${formula.name}'
					}
					names << name
				}
			} else {
				for name in request.named {
					if formula := list_named_formula(name, formulae) {
						names << formula.full_name
					}
				}
			}
			names = list_sort_tap_and_name(names)
			result.stdout += if request.one {
				if names.len > 0 { '${names.join('\n')}\n' } else { '' }
			} else {
				utils.formatter_columns(names, request.console_width, request.stdout_tty, 2, 0)
			}
		}
		if request.cask || (!request.formula && request.named.len == 0) {
			selected := if request.named.len == 0 {
				casks
			} else {
				list_named_casks(request, casks, mut result)
			}
			names := list_sort_tap_and_name(selected.map(it.full_name))
			result.stdout += if request.one {
				if names.len > 0 { '${names.join('\n')}\n' } else { '' }
			} else {
				utils.formatter_columns(names, request.console_width, request.stdout_tty, 2, 0)
			}
		}
		return result
	}

	if request.pinned {
		mut entries := []string{}
		if request.named.len == 0 {
			if !request.cask {
				for formula in formulae {
					if entry := list_formula_pin_entry(formula, request) {
						entries << entry
					}
				}
			}
			if !request.formula {
				for cask in casks {
					if entry := list_cask_pin_entry(cask, request) {
						entries << entry
					}
				}
			}
		} else {
			for name in request.named {
				mut found := false
				mut package_name := ''
				mut entry := ?string(none)
				if !request.cask {
					if formula := list_named_formula(name, formulae) {
						found = true
						package_name = formula.name
						entry = list_formula_pin_entry(formula, request)
					}
				}
				if !request.formula {
					if cask := list_named_cask(name, casks) {
						found = true
						if package_name == '' {
							package_name = cask.token
						}
						if entry == none {
							entry = list_cask_pin_entry(cask, request)
						}
					}
				}
				if value := entry {
					entries << value
				} else if found {
					list_warning(mut result, '${if package_name != '' { package_name } else { name }} not pinned')
				} else {
					result.failed = true
				}
			}
		}
		entries = list_sort_tap_and_name(entries)
		if entries.len > 0 {
			result.stdout = '${entries.join('\n')}\n'
		}
		return result
	}

	if request.versions || request.multiple {
		if !request.cask {
			mut selected := formulae.clone()
			if request.named.len > 0 {
				selected = []
				for name in request.named {
					if formula := list_named_formula(name, formulae) {
						selected << formula
					} else {
						result.failed = true
					}
				}
			}
			selected.sort_with_compare(fn (left &ListFormula, right &ListFormula) int {
				return left.rack.compare(right.rack)
			})
			for formula in selected {
				versions := list_formula_versions(formula)
				if request.multiple && versions.len < 2 {
					continue
				}
				result.stdout += list_line('${formula.name} ${versions.join(' ')}')
			}
		}
		if request.cask || (!request.formula && !request.multiple && request.named.len == 0) {
			selected := if request.named.len == 0 {
				casks
			} else {
				list_named_casks(request, casks, mut result)
			}
			result.stdout += list_casks_output(selected, request.named.len > 0, request.one, request.full_name, request.versions, request.console_width, request.stdout_tty) or {
				result.error = err.msg()
				''
			}
		}
		return result
	}

	if request.installed_on_request || installed_as_dependency || request.poured_from_bottle || request.built_from_source {
		mut flags := []string{}
		if request.installed_on_request { flags << '`--installed-on-request`' }
		if installed_as_dependency { flags << '`--no-installed-on-request`' }
		if request.poured_from_bottle { flags << '`--poured-from-bottle`' }
		if request.built_from_source { flags << '`--built-from-source`' }
		if request.named.len > 0 {
			result.error = 'Cannot use ${flags.join(', ')} with formula arguments.'
			return result
		}
		mut sorted := formulae.clone()
		if request.time_sort {
			sorted.sort_with_compare(fn (left &ListFormula, right &ListFormula) int {
				return if left.mtime > right.mtime {
					-1
				} else if left.mtime < right.mtime { 1 } else { 0 }
			})
		} else if request.full_name {
			sorted.sort_with_compare(fn (left &ListFormula, right &ListFormula) int {
				return list_tap_and_name_compare(&left.full_name, &right.full_name)
			})
		} else {
			sorted.sort_with_compare(fn (left &ListFormula, right &ListFormula) int {
				return left.name.compare(right.name)
			})
		}
		if request.reverse {
			sorted.reverse_in_place()
		}
		for formula in sorted {
			mut statuses := []string{}
			if request.installed_on_request && formula.installed_on_request {
				statuses << 'installed on request'
			}
			if installed_as_dependency && !formula.installed_on_request {
				statuses << 'installed as dependency'
			}
			if request.poured_from_bottle && formula.poured_from_bottle { statuses << 'poured from bottle' }
			if request.built_from_source && !formula.poured_from_bottle { statuses << 'built from source' }
			if statuses.len == 0 {
				continue
			}
			name := if request.full_name { formula.full_name } else { formula.name }
			result.stdout += list_line(if flags.len > 1 {
				'${name}: ${statuses.join(', ')}'
			} else {
				name
			})
		}
		return result
	}

	if request.named.len == 0 {
		if !request.cask && formulae.len > 0 {
			if request.stdout_tty && !request.formula {
				result.stdout += list_line('==> Formulae')
			}
			mut names := formulae.map(it.name)
			names.sort()
			if request.reverse { names.reverse_in_place() }
			if names.len > 0 {
				result.stdout += '${names.join('\n')}\n'
			}
			if request.stdout_tty && !request.formula {
				result.stdout += '\n'
			}
		}
		if !request.formula {
			mut names := list_bare_cask_names(request.caskroom, casks)
			if names.len > 0 {
				if request.stdout_tty && !request.cask {
					result.stdout += list_line('==> Casks')
				}
				if request.reverse { names.reverse_in_place() }
				if names.len > 0 {
					result.stdout += '${names.join('\n')}\n'
				}
			}
			broken := list_broken_caskroom_symlinks(request.caskroom)
			if broken.len > 0 {
				list_warning(mut result, 'Broken Caskroom symlinks (`brew cleanup` removes them): ${broken.join(', ')}')
			}
		}
		return result
	}

	mut selected_formulae := []ListFormula{}
	mut selected_casks := []ListCask{}
	for name in request.named {
		if !request.cask {
			if formula := list_named_formula(name, formulae) { selected_formulae << formula }
		}
		if !request.formula {
			if cask := list_named_cask(name, casks) { selected_casks << cask }
		}
	}
	if request.verbose || !request.stdout_tty {
		for formula in selected_formulae {
			result.stdout += '${list_recursive_files(formula.rack).join('\n')}\n'
		}
		for cask in selected_casks {
			result.stdout += '${list_recursive_files(cask.caskroom_path).join('\n')}\n'
		}
	} else {
		for formula in selected_formulae {
			result.stdout += pretty_listing(formula.rack)
		}
		result.stdout += list_casks_output(selected_casks, true, request.one, false, false, request.console_width, request.stdout_tty) or {
			result.error = err.msg()
			''
		}
	}
	return result
}

// Translated from Homebrew/brew `cmd/list.rb`.
