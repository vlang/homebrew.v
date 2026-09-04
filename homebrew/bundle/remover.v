module bundle

import ruby
import os

// Translated from Homebrew/brew `bundle/remover.rb`.

pub enum BundlePackageKind {
	formula
	cask
}

pub struct BundlePackage {
pub:
	kind      BundlePackageKind
	name      string
	full_name string
	aliases   []string
	oldnames  []string
	desc      string
}

pub struct BundleRemoveResult {
pub:
	path    string
	content string
	removed []string
	warning string
}

pub fn find_bundle_formula_or_cask(name string, packages []BundlePackage,
	raise_error bool) !BundlePackage {
	for package in packages {
		if name == package.name || name == package.full_name || name in package.aliases || name in package.oldnames {
			return package
		}
	}
	if raise_error {
		return error('No available formula or cask with the name "${name}".')
	}
	return BundlePackage{}
}

pub fn possible_bundle_names(formula_name string, packages []BundlePackage,
	raise_error bool) ![]string {
	package := find_bundle_formula_or_cask(formula_name, packages, raise_error)!
	if package.name == '' || package.kind != .formula {
		return []
	}
	mut names := [formula_name, package.name, package.full_name]
	names << package.aliases
	names << package.oldnames
	mut unique := []string{}
	for name in names {
		if name != '' && name !in unique {
			unique << name
		}
	}
	return unique
}

pub fn remove_bundle_description_comment(mut lines []string, package_name string,
	packages []BundlePackage) {
	if lines.len == 0 {
		return
	}
	trimmed := lines.last().trim_space()
	if !trimmed.starts_with('# ') {
		return
	}
	comment := trimmed[2..]
	package := find_bundle_formula_or_cask(package_name, packages, false) or { return }
	if package.name != '' && package.desc == comment {
		lines.delete_last()
	}
}

fn bundle_line_entry(line string) ?(string, string) {
	trimmed := line.trim_space()
	quote := trimmed.index_u8(`"`)
	if quote < 0 {
		return none
	}
	after := trimmed[quote + 1..]
	end := after.index_u8(`"`)
	if end < 0 {
		return none
	}
	entry_type := trimmed[..quote].trim_space().trim_right('(').trim_space()
	if entry_type == '' {
		return none
	}
	return entry_type, after[..end]
}

pub fn remove_bundle_entries(file string, items []string, requested_type string,
	packages []BundlePackage) !BundleRemoveResult {
	content := if os.exists(file) { os.read_file(file)! } else { '' }
	mut candidates := []string{}
	for item in items {
		if requested_type == 'brew' {
			candidates << possible_bundle_names(item, packages, true)!
		} else {
			candidates << item
		}
	}
	mut unique_candidates := []string{}
	for candidate in candidates {
		if candidate !in unique_candidates {
			unique_candidates << candidate
		}
	}
	mut new_lines := []string{}
	mut removed := []string{}
	for line in content.split_into_lines() {
		entry_type, name := bundle_line_entry(line) or {
			new_lines << line
			continue
		}
		type_matches := requested_type == 'none' || requested_type == '' || requested_type == entry_type
		if type_matches && name in unique_candidates {
			remove_bundle_description_comment(mut new_lines, name, packages)
			removed << name
			continue
		}
		new_lines << line
	}
	new_content := '${new_lines.join('\n')}\n'
	mut warning := ''
	if content.trim_right('\n') == new_content.trim_right('\n') && requested_type in ['', 'none'] {
		for item in items {
			if (possible_bundle_names(item, packages, false) or { [] }).len > 1 {
				warning = 'No matching entries found in Brewfile. Try again with `--formula` to match formula aliases and old formula names.'
				break
			}
		}
	}
	ruby.atomic_write_file(file, new_content)!
	return BundleRemoveResult{
		path: file
		content: new_content
		removed: removed
		warning: warning
	}
}

fn bundle_package_from_value(value ruby.Value) BundlePackage {
	kind := if (value.attribute('kind') or { 'formula' }) == 'cask' {
		BundlePackageKind.cask
	} else {
		BundlePackageKind.formula
	}
	return BundlePackage{
		kind: kind
		name: value.attribute('name') or { value.as_string() }
		full_name: value.attribute('full_name') or { value.as_string() }
		aliases: (value.attribute('aliases') or { '' }).split(',').filter(it != '')
		oldnames: (value.attribute('oldnames') or { '' }).split(',').filter(it != '')
		desc: value.attribute('desc') or { '' }
	}
}

fn bundle_packages_from_value(value ruby.Value) []BundlePackage {
	return value.as_array() or { [] }.map(bundle_package_from_value(it))
}

fn bundle_package_value(package BundlePackage) ruby.Value {
	return ruby.structured_value(if package.kind == .formula { 'Formula' } else { 'Cask' }, package.full_name, {
		'kind':      package.kind.str()
		'name':      package.name
		'full_name': package.full_name
		'aliases':   package.aliases.join(',')
		'oldnames':  package.oldnames.join(',')
		'desc':      package.desc
	})
}

fn bundle_remove_result_value(result BundleRemoveResult) ruby.Value {
	return ruby.structured_value('Bundle::Remover::Result', result.path, {
		'path':    result.path
		'content': result.content
		'removed': result.removed.join(',')
		'warning': result.warning
	})
}
