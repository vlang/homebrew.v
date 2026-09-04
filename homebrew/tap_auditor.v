module homebrew

import homebrew.extend
import os
import x.json2

// Translated from Homebrew/brew `tap_auditor.rb`.
const tap_auditor_json_patterns = [
	'formula_renames.json',
	'cask_renames.json',
	'tap_migrations.json',
	'synced_versions_formulae.json',
	'disabled_new_usr_local_relocation_formulae.json',
	'audit_exceptions/*.json',
	'style_exceptions/*.json',
]

pub struct TapAuditorFormulaList {
pub:
	items            []string
	valid_collection bool = true
}

pub fn tap_auditor_array_list(items []string) TapAuditorFormulaList {
	return TapAuditorFormulaList{
		items: items.clone()
	}
}

pub fn tap_auditor_hash_list(keys []string) TapAuditorFormulaList {
	return TapAuditorFormulaList{
		items: keys.clone()
	}
}

pub fn tap_auditor_invalid_list() TapAuditorFormulaList {
	return TapAuditorFormulaList{
		valid_collection: false
	}
}

pub struct TapAuditorTap {
pub:
	name                                       string
	path                                       string
	audit_exceptions                           map[string]TapAuditorFormulaList
	style_exceptions                           map[string]TapAuditorFormulaList
	synced_versions_formulae                   [][]string
	disabled_new_usr_local_relocation_formulae []string
	autobump                                   []string
	official                                   bool
	formula_renames                            map[string]string
	cask_renames                               map[string]string
	cask_tokens                                []string
	aliases                                    []string
	formula_names                              []string
}

pub struct TapAuditProblem {
pub:
	message   string
	location  ?string
	corrected bool
}

pub struct TapAuditor {
pub:
	name                                           string
	path                                           string
	formula_names                                  []string
	formula_aliases                                []string
	formula_renames                                map[string]string
	cask_tokens                                    []string
	cask_renames                                   map[string]string
	tap_audit_exceptions                           map[string]TapAuditorFormulaList
	tap_style_exceptions                           map[string]TapAuditorFormulaList
	tap_synced_versions_formulae                   [][]string
	tap_disabled_new_usr_local_relocation_formulae []string
	tap_autobump                                   []string
	tap_official                                   bool
pub mut:
	problems []TapAuditProblem
}

pub fn new_tap_auditor(tap TapAuditorTap, strict ?bool) TapAuditor {
	_ = strict
	return TapAuditor{
		name: tap.name
		path: tap.path
		formula_names: tap.formula_names.map(name_from_full_name(it))
		formula_aliases: tap.aliases.map(name_from_full_name(it))
		formula_renames: tap.formula_renames.clone()
		cask_tokens: tap.cask_tokens.map(name_from_full_name(it))
		cask_renames: tap.cask_renames.clone()
		tap_audit_exceptions: tap.audit_exceptions.clone()
		tap_style_exceptions: tap.style_exceptions.clone()
		tap_synced_versions_formulae: tap.synced_versions_formulae.clone()
		tap_disabled_new_usr_local_relocation_formulae: tap.disabled_new_usr_local_relocation_formulae.clone()
		tap_autobump: tap.autobump.clone()
		tap_official: tap.official
	}
}

pub fn (mut auditor TapAuditor) audit() {
	auditor.audit_json_files()
	auditor.audit_tap_formula_lists()
	auditor.audit_aliases_renames_duplicates()
}

pub fn (mut auditor TapAuditor) audit_json_files() {
	for pattern in tap_auditor_json_patterns {
		full_pattern := os.join_path(auditor.path, pattern)
		mut files := if pattern.contains('*') {
			os.glob(full_pattern) or { []string{} }
		} else if os.is_file(full_pattern) {
			[full_pattern]
		} else {
			[]string{}
		}
		files.sort()
		for file in files {
			contents := os.read_file(file) or { panic(err) }
			json2.decode[json2.Any](contents) or {
				prefix := auditor.path.trim_right(os.path_separator) + os.path_separator
				relative := if file.starts_with(prefix) { file[prefix.len..] } else { file }
				auditor.problem('${relative} contains invalid JSON')
			}
		}
	}
}

pub fn (mut auditor TapAuditor) audit_tap_formula_lists() {
	auditor.check_formula_list_directory('audit_exceptions', auditor.tap_audit_exceptions)
	auditor.check_formula_list_directory('style_exceptions', auditor.tap_style_exceptions)
	auditor.check_renames('formula_renames.json', auditor.formula_renames, auditor.formula_names, auditor.formula_aliases)
	auditor.check_renames('cask_renames.json', auditor.cask_renames, auditor.cask_tokens, []string{})
	if !auditor.tap_official {
		auditor.check_formula_list('.github/autobump.txt', tap_auditor_array_list(auditor.tap_autobump))
	}
	mut synced := []string{}
	for formulae in auditor.tap_synced_versions_formulae {
		synced << formulae
	}
	auditor.check_formula_list('synced_versions_formulae', tap_auditor_array_list(synced))
	auditor.check_formula_list('disabled_new_usr_local_relocation_formulae.json', tap_auditor_array_list(auditor.tap_disabled_new_usr_local_relocation_formulae))
}

pub fn (mut auditor TapAuditor) audit_aliases_renames_duplicates() {
	mut duplicates := []string{}
	for formula_alias in auditor.formula_aliases {
		if formula_alias in auditor.formula_renames {
			duplicates << formula_alias
		}
	}
	if duplicates.len == 0 {
		return
	}
	auditor.problem('The following should either be an alias or a rename, not both: ${extend.array_to_sentence(duplicates, ', ', ' and ', ' and ')}')
}

pub fn (mut auditor TapAuditor) problem(message string) {
	auditor.problems << TapAuditProblem{
		message: message
		location: none
		corrected: false
	}
}

pub fn (mut auditor TapAuditor) check_formula_list(list_file_value string,
	list TapAuditorFormulaList) {
	mut list_file := list_file_value
	if os.file_ext(list_file) == '' {
		list_file += '.json'
	}
	if !list.valid_collection {
		auditor.problem('${list_file} should contain a JSON array\nof formula names or a JSON object mapping formula names to values\n')
		return
	}
	mut invalid_formulae_casks := []string{}
	for formula_or_cask_name in list.items {
		if formula_or_cask_name !in auditor.formula_names && formula_or_cask_name !in auditor.formula_aliases && formula_or_cask_name !in auditor.cask_tokens {
			invalid_formulae_casks << formula_or_cask_name
		}
	}
	if invalid_formulae_casks.len == 0 {
		return
	}
	auditor.problem('${list_file} references\nformulae or casks that are not found in the ${auditor.name} tap.\nInvalid formulae or casks: ${invalid_formulae_casks.join(', ')}\n')
}

pub fn (mut auditor TapAuditor) check_formula_list_directory(directory_name string,
	lists map[string]TapAuditorFormulaList) {
	for list_name, list in lists {
		auditor.check_formula_list('${directory_name}/${list_name}', list)
	}
}

pub fn (mut auditor TapAuditor) check_renames(list_file string,
	renames_hash map[string]string, valid_tokens []string, valid_aliases []string) {
	item_type := if list_file.contains('cask') { 'casks' } else { 'formulae' }
	mut invalid_format_entries := []string{}
	mut invalid_targets := []string{}
	mut chained_rename_suggestions := []string{}
	mut conflicts := []string{}
	for old_name, new_name in renames_hash {
		if old_name.ends_with('.rb') || new_name.ends_with('.rb') {
			invalid_format_entries << '"${old_name}": "${new_name}"'
		}
		if new_name !in valid_tokens && new_name !in valid_aliases && new_name !in renames_hash {
			invalid_targets << new_name
		}
		if new_name in renames_hash {
			mut final_name := new_name
			mut seen := {
				old_name: true
				new_name: true
			}
			for (final_name in renames_hash) {
				next_name := renames_hash[final_name]
				if next_name in seen {
					break
				}
				final_name = next_name
				seen[final_name] = true
			}
			chained_rename_suggestions << '  "${old_name}": "${final_name}" (instead of chained rename)'
		}
		if old_name in valid_tokens {
			conflicts << old_name
		}
	}
	if invalid_format_entries.len > 0 {
		auditor.problem("${list_file} contains entries with '.rb' file extensions.\nRename entries should use formula/cask names only, without '.rb' extensions.\nInvalid entries: ${invalid_format_entries.join(', ')}\n")
	}
	if invalid_targets.len > 0 {
		auditor.problem('${list_file} contains renames to ${item_type} that do not exist in the ${auditor.name} tap.\nInvalid targets: ${invalid_targets.join(', ')}\n')
	}
	if chained_rename_suggestions.len > 0 {
		auditor.problem("${list_file} contains chained renames that should be collapsed.\nChained renames don't work automatically; each old name should point directly to the final target:\n${chained_rename_suggestions.join('\n')}\n")
	}
	if conflicts.len == 0 {
		return
	}
	auditor.problem('${list_file} contains old names that conflict with existing ${item_type} in the ${auditor.name} tap.\nRenames only work after the old ${item_type} are deleted. Conflicting names: ${conflicts.join(', ')}\n')
}
