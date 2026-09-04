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
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 94.
pub fn ruby_list_l94_d1_run(args ...ruby.Value) ruby.Value {
	request := if args.len > 0 { list_request_from_value(args[0]) } else { ListCommandRequest{} }
	return list_result_value(run_list_command(request))
}

// Ruby method `warn_about_broken_caskroom_symlinks` at line 272.
pub fn ruby_list_l272_d2_warn_about_broken_caskroom_symlinks(args ...ruby.Value) ruby.Value {
	caskroom := if args.len > 0 { args[0].as_string() } else { '' }
	broken := list_broken_caskroom_symlinks(caskroom)
	return ruby.string_value(if broken.len > 0 {
		'Warning: Broken Caskroom symlinks (`brew cleanup` removes them): ${broken.join(', ')}\n'
	} else {
		''
	})
}

// Ruby method `pinned_formula_entry(name)` at line 281.
pub fn ruby_list_l281_d3_pinned_formula_entry(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', 'nil')
	}
	versions := args.len > 2 && (args[2].as_bool() or { false })
	if entry := list_pinned_formula_entry(args[0].as_string(), args[1].as_string(), versions) {
		return ruby.string_value(entry)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `pinned_cask_entry(token)` at line 289.
pub fn ruby_list_l289_d4_pinned_cask_entry(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', 'nil')
	}
	versions := args.len > 2 && (args[2].as_bool() or { false })
	if entry := list_pinned_cask_entry(args[0].as_string(), args[1].as_string(), versions) {
		return ruby.string_value(entry)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `filtered_list` at line 297.
pub fn ruby_list_l297_d5_filtered_list(args ...ruby.Value) ruby.Value {
	request := if args.len > 0 {
		list_request_from_value(args[0])
	} else {
		ListCommandRequest{ versions: true }
	}
	mut translated := request
	translated.versions = true
	translated.cask = false
	translated.formula = true
	return list_result_value(run_list_command(translated))
}

// Ruby method `list_casks` at line 316.
pub fn ruby_list_l316_d6_list_casks(args ...ruby.Value) ruby.Value {
	request := if args.len > 0 {
		list_request_from_value(args[0])
	} else {
		ListCommandRequest{ cask: true }
	}
	casks := list_existing_casks(request)
	selected := if request.named.len == 0 {
		casks
	} else {
		mut result := ListCommandResult{}
		list_named_casks(request, casks, mut result)
	}
	output := list_casks_output(selected, request.named.len > 0, request.one, request.full_name, request.versions, request.console_width, request.stdout_tty) or {
		return ruby.object_value('CaskNotInstalledError', err.msg())
	}
	return ruby.string_value(output)
}

// Ruby method `initialize(path)` at line 348.
pub fn ruby_list_l348_d7_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'path is required')
	}
	return ruby.string_value(pretty_listing(args[0].as_string()))
}

// Ruby method `print_dir(root, &block)` at line 378.
pub fn ruby_list_l378_d8_print_dir(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'root is required')
	}
	extensions := if args.len > 1 {
		args[1].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return ruby.string_value(list_print_dir(args[0].as_string(), extensions))
}

// Ruby method `print_remaining_files(files, root, other = "")` at line 404.
pub fn ruby_list_l404_d9_print_remaining_files(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'files and root are required')
	}
	files := args[0].as_string_array() or { []string{} }
	other := if args.len > 2 { args[2].as_string() } else { '' }
	return ruby.string_value(list_print_remaining_files(files, args[1].as_string(), other))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "metafiles"
// 6: require "formula"
// 7: require "cli/parser"
// 8: require "cask/list"
// 9: require "system_command"
// 10: require "tab"
// 11:
// 12: module Homebrew
// 13:   module Cmd
// 14:     class List < AbstractCommand
// 15:       include SystemCommand::Mixin
// 16:
// 17:       cmd_args do
// 18:         description <<~EOS
// 19:           List all installed formulae and casks.
// 20:           If <formula> is provided, summarise the paths within its current keg.
// 21:           If <cask> is provided, list its artifacts.
// 22:         EOS
// 23:         switch "--formula", "--formulae",
// 24:                description: "List only formulae, or treat all named arguments as formulae."
// 25:         switch "--cask", "--casks",
// 26:                description: "List only casks, or treat all named arguments as casks."
// 27:         switch "--full-name",
// 28:                description: "Print formulae with fully-qualified names. Unless `--full-name`, `--versions` " \
// 29:                             "or `--pinned` are passed, other options (i.e. `-1`, `-l`, `-r` and `-t`) are " \
// 30:                             "passed to `ls`(1) which produces the actual output."
// 31:         switch "--versions",
// 32:                description: "Show the version number for installed formulae, or only the specified " \
// 33:                             "formulae if <formula> are provided."
// 34:         switch "--json",
// 35:                description: "Output installed formulae and casks with versions, linked and opt-linked formula " \
// 36:                             "versions and pinned versions as JSON using the fast Bash command path. Requires " \
// 37:                             "`--versions`, no named arguments and `jq`."
// 38:         switch "--multiple",
// 39:                description: "Only show formulae with multiple versions installed. Implies `--versions`."
// 40:         switch "--pinned",
// 41:                description: "List only pinned packages, or only the specified (pinned) packages if <formula> or " \
// 42:                             "<cask> are provided. See also `pin`, `unpin`."
// 43:         switch "--installed-on-request",
// 44:                description: "List the formulae installed on request."
// 45:         switch "--no-installed-on-request",
// 46:                description: "List the formulae not installed on request (i.e. installed as dependencies)."
// 47:         switch "--installed-as-dependency",
// 48:                description: "List the formulae installed as dependencies.",
// 49:                odeprecated: true,
// 50:                replacement: "--no-installed-on-request"
// 51:         switch "--poured-from-bottle",
// 52:                description: "List the formulae installed from a bottle."
// 53:         switch "--built-from-source",
// 54:                description: "List the formulae compiled from source."
// 55:
// 56:         # passed through to ls
// 57:         switch "-1",
// 58:                description: "Force output to be one entry per line. " \
// 59:                             "This is the default when output is not to a terminal."
// 60:         switch "-l",
// 61:                description: "List formulae and/or casks in long format. " \
// 62:                             "Has no effect when a formula or cask name is passed as an argument."
// 63:         switch "-r",
// 64:                description: "Reverse the order of formula and/or cask sorting to list the oldest entries first. " \
// 65:                             "Has no effect when a formula or cask name is passed as an argument."
// 66:         switch "-t",
// 67:                description: "Sort formulae and/or casks by time modified, listing most recently modified first. " \
// 68:                             "Has no effect when a formula or cask name is passed as an argument."
// 69:
// 70:         conflicts "--formula", "--cask"
// 71:         conflicts "--multiple", "--cask"
// 72:         conflicts "--pinned", "--multiple"
// 73:         ["--installed-on-request", "--no-installed-on-request", "--installed-as-dependency",
// 74:          "--poured-from-bottle", "--built-from-source"].each do |flag|
// 75:           conflicts "--cask", flag
// 76:           conflicts "--versions", flag
// 77:           conflicts "--multiple", flag
// 78:           conflicts "--pinned", flag
// 79:           conflicts "-l", flag
// 80:         end
// 81:         ["-1", "-l", "-r", "-t"].each do |flag|
// 82:           conflicts "--versions", flag
// 83:           conflicts "--multiple", flag
// 84:           conflicts "--pinned", flag
// 85:         end
// 86:         ["--versions", "--multiple", "--pinned", "-l", "-r", "-t"].each do |flag|
// 87:           conflicts "--full-name", flag
// 88:         end
// 89:
// 90:         named_args [:installed_formula, :installed_cask]
// 91:       end
// 92:
// 93:       sig { override.void }
// 94:       def run
// 95:         if args.json?
// 96:           raise UsageError, "`brew list --json` requires `--versions`." unless args.versions?
// 97:           raise UsageError, "`brew list --versions --json` does not support named arguments." unless args.no_named?
// 98:
// 99:           raise UsageError, "`brew list --versions --json` is only supported by the fast Bash path with `jq`."
// 100:         end
// 101:
// 102:         installed_as_dependency = args.no_installed_on_request? || args.installed_as_dependency?
// 103:
// 104:         if args.full_name? &&
// 105:            !(args.installed_on_request? || installed_as_dependency ||
// 106:              args.poured_from_bottle? || args.built_from_source?)
// 107:           unless args.cask?
// 108:             full_formula_names = if args.no_named?
// 109:               Formula.racks.map do |rack|
// 110:                 name = rack.basename.to_s
// 111:                 tap = begin
// 112:                   Keg.from_rack(rack)&.tab&.tap
// 113:                 rescue JSON::ParserError, SystemCallError, Tap::InvalidNameError
// 114:                   opoo "Could not identify the tap for #{name} from its installation receipt."
// 115:                   nil
// 116:                 end
// 117:                 (tap.nil? || tap.core_tap?) ? name : "#{tap}/#{name}"
// 118:               end
// 119:             else
// 120:               args.named.to_resolved_formulae.map(&:full_name)
// 121:             end.sort(&Cask::List::TAP_AND_NAME_COMPARISON)
// 122:             full_formula_names = Formatter.columns(full_formula_names) unless args.public_send(:"1?")
// 123:             puts full_formula_names if full_formula_names.present?
// 124:           end
// 125:           if args.cask? || (!args.formula? && args.no_named?)
// 126:             cask_names = if args.no_named?
// 127:               Cask::Caskroom.casks
// 128:             else
// 129:               args.named.to_formulae_and_casks(only: :cask, method: :resolve)
// 130:             end
// 131:             # The cast is because `Keg`` does not define `full_name`
// 132:             full_cask_names = T.cast(cask_names, T::Array[T.any(Formula, Cask::Cask)])
// 133:                                .map(&:full_name).sort(&Cask::List::TAP_AND_NAME_COMPARISON)
// 134:             full_cask_names = Formatter.columns(full_cask_names) unless args.public_send(:"1?")
// 135:             puts full_cask_names if full_cask_names.present?
// 136:           end
// 137:         elsif args.pinned?
// 138:           pinned = if args.no_named?
// 139:             entries = T.let([], T::Array[String])
// 140:             unless args.cask?
// 141:               Formula.racks.each do |rack|
// 142:                 entry = pinned_formula_entry(rack.basename.to_s)
// 143:                 entries << entry if entry
// 144:               end
// 145:             end
// 146:
// 147:             if !args.formula? && Cask::Caskroom.path.directory?
// 148:               Cask::Caskroom.path.children.reject(&:file?).each do |path|
// 149:                 entry = pinned_cask_entry(path.basename.to_s)
// 150:                 entries << entry if entry
// 151:               end
// 152:             end
// 153:             entries
// 154:           else
// 155:             args.named.filter_map do |name|
// 156:               entry = T.let(nil, T.nilable(String))
// 157:               package_found = T.let(false, T::Boolean)
// 158:               package_name = T.let(nil, T.nilable(String))
// 159:
// 160:               unless args.cask?
// 161:                 rack = Formulary.to_rack(name)
// 162:                 if rack.exist?
// 163:                   package_found = true
// 164:                   package_name = rack.basename.to_s
// 165:                   entry ||= pinned_formula_entry(rack.basename.to_s)
// 166:                 end
// 167:               end
// 168:
// 169:               unless args.formula?
// 170:                 token = ::Utils.name_from_full_name(name).to_s
// 171:                 caskroom_path = Cask::Caskroom.path/token
// 172:                 if caskroom_path.exist? || caskroom_path.symlink?
// 173:                   package_found = true
// 174:                   package_name ||= token
// 175:                   entry ||= pinned_cask_entry(token)
// 176:                 end
// 177:               end
// 178:
// 179:               if package_found && entry.nil?
// 180:                 opoo "#{package_name || name} not pinned"
// 181:               elsif !package_found
// 182:                 Homebrew.failed = true
// 183:               end
// 184:               entry
// 185:             end
// 186:           end
// 187:
// 188:           puts pinned.sort(&Cask::List::TAP_AND_NAME_COMPARISON)
// 189:         elsif args.versions? || args.multiple?
// 190:           filtered_list unless args.cask?
// 191:           list_casks if args.cask? || (!args.formula? && !args.multiple? && args.no_named?)
// 192:         elsif args.installed_on_request? ||
// 193:               installed_as_dependency ||
// 194:               args.poured_from_bottle? ||
// 195:               args.built_from_source?
// 196:           flags = []
// 197:           flags << "`--installed-on-request`" if args.installed_on_request?
// 198:           flags << "`--no-installed-on-request`" if installed_as_dependency
// 199:           flags << "`--poured-from-bottle`" if args.poured_from_bottle?
// 200:           flags << "`--built-from-source`" if args.built_from_source?
// 201:
// 202:           raise UsageError, "Cannot use #{flags.join(", ")} with formula arguments." unless args.no_named?
// 203:
// 204:           formulae = if args.t?
// 205:             # See https://ruby-doc.org/3.2/Kernel.html#method-i-test
// 206:             Formula.installed.sort_by { |formula| T.cast(test("M", formula.rack.to_s), Time) }.reverse!
// 207:           elsif args.full_name?
// 208:             Formula.installed.sort { |a, b| Cask::List::TAP_AND_NAME_COMPARISON.call(a.full_name, b.full_name) }
// 209:           else
// 210:             Formula.installed.sort
// 211:           end
// 212:           formulae.reverse! if args.r?
// 213:           formulae.each do |formula|
// 214:             tab = Tab.for_formula(formula)
// 215:
// 216:             statuses = []
// 217:             statuses << "installed on request" if args.installed_on_request? && tab.installed_on_request
// 218:             statuses << "installed as dependency" if installed_as_dependency && !tab.installed_on_request
// 219:             statuses << "poured from bottle" if args.poured_from_bottle? && tab.poured_from_bottle
// 220:             statuses << "built from source" if args.built_from_source? && !tab.poured_from_bottle
// 221:             next if statuses.empty?
// 222:
// 223:             name = args.full_name? ? formula.full_name : formula.name
// 224:             if flags.count > 1
// 225:               puts "#{name}: #{statuses.join(", ")}"
// 226:             else
// 227:               puts name
// 228:             end
// 229:           end
// 230:         elsif args.no_named?
// 231:           ENV["CLICOLOR"] = nil
// 232:
// 233:           ls_args = []
// 234:           ls_args << "-1" if args.public_send(:"1?")
// 235:           ls_args << "-l" if args.l?
// 236:           ls_args << "-r" if args.r?
// 237:           ls_args << "-t" if args.t?
// 238:
// 239:           if !args.cask? && HOMEBREW_CELLAR.exist? && HOMEBREW_CELLAR.children.any?
// 240:             ohai "Formulae" if $stdout.tty? && !args.formula?
// 241:             system_command! "ls", args: [*ls_args, HOMEBREW_CELLAR], print_stdout: true
// 242:             puts if $stdout.tty? && !args.formula?
// 243:           end
// 244:           unless args.formula?
// 245:             if Cask::Caskroom.any_casks_installed?
// 246:               ohai "Casks" if $stdout.tty? && !args.cask?
// 247:               system_command! "ls", args: [*ls_args, Cask::Caskroom.path], print_stdout: true
// 248:             end
// 249:             warn_about_broken_caskroom_symlinks
// 250:           end
// 251:         else
// 252:           kegs, casks = args.named.to_kegs_to_casks
// 253:
// 254:           if args.verbose? || !$stdout.tty?
// 255:             find_args = %w[-not -type d -not -name .DS_Store -print]
// 256:             system_command! "find", args: kegs.map(&:to_s) + find_args, print_stdout: true if kegs.present?
// 257:             system_command! "find", args: casks.map(&:caskroom_path) + find_args, print_stdout: true if casks.present?
// 258:           else
// 259:             kegs.each { |keg| PrettyListing.new keg } if kegs.present?
// 260:             Cask::List.list_casks(*casks, one: args.public_send(:"1?")) if casks.present?
// 261:           end
// 262:         end
// 263:       end
// 264:
// 265:       private
// 266:
// 267:       # A broken symlink in the Caskroom (e.g. a dangling cask rename alias) lists
// 268:       # like an installed cask but cannot load or uninstall, so flag it.
// 269:       # Keep in sync with the broken-symlink warning in `homebrew-list` in
// 270:       # Library/Homebrew/list.sh.
// 271:       sig { void }
// 272:       def warn_about_broken_caskroom_symlinks
// 273:         broken_symlinks = Cask::Caskroom.path.glob("*").select { |child| child.symlink? && !child.exist? }
// 274:         return if broken_symlinks.empty?
// 275:
// 276:         opoo "Broken Caskroom symlinks (`brew cleanup` removes them): " \
// 277:              "#{broken_symlinks.map(&:basename).sort.join(", ")}"
// 278:       end
// 279:
// 280:       sig { params(name: String).returns(T.nilable(String)) }
// 281:       def pinned_formula_entry(name)
// 282:         pin_path = HOMEBREW_PINNED_KEGS/name
// 283:         return unless pin_path.symlink?
// 284:
// 285:         "#{name}#{" #{pin_path.readlink.basename}" if args.versions?}"
// 286:       end
// 287:
// 288:       sig { params(token: String).returns(T.nilable(String)) }
// 289:       def pinned_cask_entry(token)
// 290:         pin_path = HOMEBREW_PINNED_CASKS/token
// 291:         return if !pin_path.symlink? || !pin_path.exist?
// 292:
// 293:         "#{token}#{" #{pin_path.resolved_path.basename}" if args.versions?}"
// 294:       end
// 295:
// 296:       sig { void }
// 297:       def filtered_list
// 298:         names = if args.no_named?
// 299:           Formula.racks
// 300:         else
// 301:           racks = args.named.map { |n| Formulary.to_rack(n) }
// 302:           racks.select do |rack|
// 303:             Homebrew.failed = true unless rack.exist?
// 304:             rack.exist?
// 305:           end
// 306:         end
// 307:         names.sort.each do |d|
// 308:           versions = d.subdirs.map { |pn| pn.basename.to_s }
// 309:           next if args.multiple? && versions.length < 2
// 310:
// 311:           puts "#{d.basename} #{versions * " "}"
// 312:         end
// 313:       end
// 314:
// 315:       sig { void }
// 316:       def list_casks
// 317:         casks = if args.no_named?
// 318:           cask_paths = Cask::Caskroom.path.children.reject(&:file?).map do |path|
// 319:             if path.symlink?
// 320:               real_path = path.realpath
// 321:               real_path.basename.to_s
// 322:             else
// 323:               path.basename.to_s
// 324:             end
// 325:           end.uniq.sort
// 326:           cask_paths.map { |name| Cask::CaskLoader.load(name) }
// 327:         else
// 328:           filtered_args = args.named.dup.delete_if do |n|
// 329:             Homebrew.failed = true unless Cask::Caskroom.path.join(n).exist?
// 330:             !Cask::Caskroom.path.join(n).exist?
// 331:           end
// 332:           # NamedAargs subclasses array
// 333:           T.cast(filtered_args, Homebrew::CLI::NamedArgs).to_formulae_and_casks(only: :cask)
// 334:         end
// 335:         return if casks.blank?
// 336:
// 337:         Cask::List.list_casks(
// 338:           *casks,
// 339:           one:       args.public_send(:"1?"),
// 340:           full_name: args.full_name?,
// 341:           versions:  args.versions?,
// 342:         )
// 343:       end
// 344:     end
// 345:
// 346:     class PrettyListing
// 347:       sig { params(path: T.any(String, Pathname, Keg)).void }
// 348:       def initialize(path)
// 349:         valid_lib_extensions = [".cps", ".dylib", ".pc"]
// 350:         Pathname.new(path).children.sort_by { |p| p.to_s.downcase }.each do |pn|
// 351:           case pn.basename.to_s
// 352:           when "bin", "sbin"
// 353:             pn.find { |pnn| puts pnn unless pnn.directory? }
// 354:           when "lib"
// 355:             print_dir pn do |pnn|
// 356:               # dylibs have multiple symlinks and we don't care about them
// 357:               valid_lib_extensions.include?(pnn.extname) && !pnn.symlink?
// 358:             end
// 359:           when ".brew"
// 360:             next # Ignore .brew
// 361:           else
// 362:             if pn.directory?
// 363:               if pn.symlink?
// 364:                 puts "#{pn} -> #{pn.readlink}"
// 365:               else
// 366:                 print_dir pn
// 367:               end
// 368:             elsif Metafiles.list?(pn.basename.to_s)
// 369:               puts pn
// 370:             end
// 371:           end
// 372:         end
// 373:       end
// 374:
// 375:       private
// 376:
// 377:       sig { params(root: Pathname, block: T.nilable(T.proc.params(arg0: Pathname).returns(T::Boolean))).void }
// 378:       def print_dir(root, &block)
// 379:         dirs = []
// 380:         remaining_root_files = []
// 381:         other = ""
// 382:
// 383:         root.children.sort.each do |pn|
// 384:           if pn.directory?
// 385:             dirs << pn
// 386:           elsif block && yield(pn)
// 387:             puts pn
// 388:             other = "other "
// 389:           elsif pn.basename.to_s != ".DS_Store"
// 390:             remaining_root_files << pn
// 391:           end
// 392:         end
// 393:
// 394:         dirs.each do |d|
// 395:           files = []
// 396:           d.find { |pn| files << pn unless pn.directory? }
// 397:           print_remaining_files files, d
// 398:         end
// 399:
// 400:         print_remaining_files remaining_root_files, root, other
// 401:       end
// 402:
// 403:       sig { params(files: T::Array[Pathname], root: Pathname, other: String).void }
// 404:       def print_remaining_files(files, root, other = "")
// 405:         if files.length == 1
// 406:           puts files
// 407:         elsif files.length > 1
// 408:           puts "#{root}/ (#{files.length} #{other}files)"
// 409:         end
// 410:       end
// 411:     end
// 412:   end
// 413: end
