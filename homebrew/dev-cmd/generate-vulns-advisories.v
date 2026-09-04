module dev_cmd

import ruby
import homebrew.vulns
import os
import time
import x.json2

// Translated from Homebrew/brew `dev-cmd/generate-vulns-advisories.rb`.

pub struct GenerateVulnsVariation {
pub:
	patches []vulns.OsvExportPatch
}

pub struct GenerateVulnsHistoricalFormula {
pub:
	pkg_version        string
	serialized_patches []vulns.OsvExportPatch
}

pub struct GenerateVulnsRevision {
pub:
	revision string
	entry    string
	formula  GenerateVulnsHistoricalFormula
	loadable bool = true
}

pub struct GenerateVulnsFormula {
pub:
	name               string
	pkg_version        string
	patches            []vulns.OsvExportPatch
	variations         []GenerateVulnsVariation
	history            []GenerateVulnsRevision
	formula_load_error bool
}

pub type GenerateVulnsFetch = fn (string) !vulns.OsvExportUpstream

pub struct GenerateVulnsAdvisoriesOptions {
pub:
	directory     string
	dry_run       bool
	verbose       bool
	tap_installed bool = true
	tap_name      string = 'homebrew/core'
	formula_names []string
	formulas      map[string]GenerateVulnsFormula
	now           string
	fetch         GenerateVulnsFetch = generate_vulns_default_fetch
}

pub struct GenerateVulnsAnnotated {
pub:
	formula GenerateVulnsFormula
	patches []vulns.OsvExportPatch
}

pub struct GenerateVulnsAdvisoriesResult {
pub mut:
	annotated_count int
	annotated       []GenerateVulnsAnnotated
	output_lines    []string
	messages        []string
	written_files   []string
}

@[heap]
pub struct GenerateVulnsAdvisoriesCommand {
pub:
	options GenerateVulnsAdvisoriesOptions
pub mut:
	formula_rev_lists   map[string][]GenerateVulnsRevision
	formula_versions    map[string]bool
	revision_list_loads map[string]int
}

@[heap]
pub struct GenerateVulnsAdvisoriesInput {
pub:
	options GenerateVulnsAdvisoriesOptions
}

@[heap]
pub struct GenerateVulnsFormulaInput {
pub:
	formula GenerateVulnsFormula
}

@[heap]
pub struct GenerateVulnsFirstFixedInput {
pub mut:
	command GenerateVulnsAdvisoriesCommand
	formula GenerateVulnsFormula
	vuln_id string
}

fn generate_vulns_default_fetch(_vuln_id string) !vulns.OsvExportUpstream {
	return error('OSV vulnerability unavailable')
}

pub fn new_generate_vulns_advisories_command(options GenerateVulnsAdvisoriesOptions) GenerateVulnsAdvisoriesCommand {
	return GenerateVulnsAdvisoriesCommand{
		options: options
	}
}

fn generate_vulns_resolved_ids(patches []vulns.OsvExportPatch) []string {
	mut ids := []string{}
	for patch in patches {
		for resolve in patch.resolves {
			if resolve.resolve_type != 'security' {
				continue
			}
			id := resolve.id.to_upper()
			if id !in ids {
				ids << id
			}
		}
	}
	return ids
}

fn generate_vulns_patch_key(patch vulns.OsvExportPatch) string {
	return json2.encode(patch)
}

pub fn generate_vulns_all_variation_patches(formula GenerateVulnsFormula) []vulns.OsvExportPatch {
	mut patches := []vulns.OsvExportPatch{}
	mut seen := map[string]bool{}
	for patch in formula.patches {
		key := generate_vulns_patch_key(patch)
		if key !in seen {
			seen[key] = true
			patches << patch
		}
	}
	for variation in formula.variations {
		for patch in variation.patches {
			key := generate_vulns_patch_key(patch)
			if key !in seen {
				seen[key] = true
				patches << patch
			}
		}
	}
	return patches
}

fn generate_vulns_last_fixed(last_fixed string) ?string {
	if last_fixed == '' {
		return none
	}
	return last_fixed
}

pub fn generate_vulns_first_fixed_version(mut command GenerateVulnsAdvisoriesCommand,
	formula GenerateVulnsFormula, vuln_id string) ?string {
	if formula.name !in command.formula_versions {
		command.formula_versions[formula.name] = true
	}
	if formula.name !in command.formula_rev_lists {
		command.formula_rev_lists[formula.name] = formula.history.clone()
		command.revision_list_loads[formula.name] = command.revision_list_loads[formula.name] + 1
	}

	mut last_fixed := ''
	revisions := command.formula_rev_lists[formula.name]
	for item in revisions {
		// `nil` means the revision failed to load; stop rather than guess.
		if !item.loadable {
			return generate_vulns_last_fixed(last_fixed)
		}
		resolved_here := vuln_id.to_upper() in generate_vulns_resolved_ids(item.formula.serialized_patches)
		if !resolved_here {
			return generate_vulns_last_fixed(last_fixed)
		}
		last_fixed = item.formula.pkg_version
	}
	return generate_vulns_last_fixed(last_fixed)
}

fn generate_vulns_now(configured string) string {
	if configured != '' {
		return configured
	}
	return time.now().format_rfc3339()
}

fn generate_vulns_export_formula(formula GenerateVulnsFormula,
	patches []vulns.OsvExportPatch) vulns.OsvExportFormula {
	return vulns.OsvExportFormula{
		name: formula.name
		pkg_version: formula.pkg_version
		serialized_patches: patches.clone()
	}
}

pub fn run_generate_vulns_advisories(mut command GenerateVulnsAdvisoriesCommand) !GenerateVulnsAdvisoriesResult {
	options := command.options
	if !options.tap_installed {
		return error(options.tap_name)
	}

	mut annotated := []GenerateVulnsAnnotated{}
	for name in options.formula_names {
		formula := options.formulas[name] or {
			return error("Error loading formula '${name}'.")
		}
		if formula.formula_load_error {
			return error("Error loading formula '${name}'.")
		}
		patches := generate_vulns_all_variation_patches(formula)
		if generate_vulns_resolved_ids(patches).len > 0 {
			annotated << GenerateVulnsAnnotated{
				formula: formula
				patches: patches
			}
		}
	}

	mut result := GenerateVulnsAdvisoriesResult{
		annotated_count: annotated.len
		annotated: annotated.clone()
		messages: ['${annotated.len} formulae with security `resolves` annotations']
	}
	if options.dry_run {
		for item in annotated {
			for vuln_id in generate_vulns_resolved_ids(item.patches) {
				result.output_lines << '${vulns.osv_export_id_prefix}-${item.formula.name}-${vuln_id}'
			}
		}
		return result
	}

	os.mkdir_all(options.directory)!
	mut upstream_cache := map[string]vulns.OsvExportUpstream{}
	mut failed := map[string]bool{}
	now := generate_vulns_now(options.now)
	for item in annotated {
		formula := generate_vulns_export_formula(item.formula, item.patches)
		for vuln_id in generate_vulns_resolved_ids(item.patches) {
			if vuln_id !in upstream_cache && vuln_id !in failed {
				upstream_cache[vuln_id] = options.fetch(vuln_id) or {
					failed[vuln_id] = true
					vulns.OsvExportUpstream{}
				}
			}
			path := os.join_path(options.directory, '${vulns.osv_export_id_prefix}-${item.formula.name}-${vuln_id}.json')
			existing := os.is_file(path)
			if failed[vuln_id] && existing {
				continue
			}

			mut fixed := formula.pkg_version
			if !existing {
				if first_fixed := generate_vulns_first_fixed_version(mut command, item.formula, vuln_id) {
					fixed = first_fixed
				}
			}
			upstream := if failed[vuln_id] { none } else { upstream_cache[vuln_id] }
			record := vulns.osv_export_record_for(formula, vuln_id, item.patches, fixed, upstream, now)
			merged := vulns.osv_export_merge_existing(path, record) or { continue }
			os.write_file(path, '${json2.encode(merged, prettify: true)}\n')!
			result.written_files << path
		}
	}
	if options.verbose {
		for path in result.written_files {
			result.output_lines << '  wrote ${path}'
		}
	}
	result.messages << '${result.written_files.len} records written to ${options.directory}'
	return result
}

pub fn generate_vulns_advisories_input_boundary(input &GenerateVulnsAdvisoriesInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateVulnsAdvisories::Input', '', {
		'generate_vulns_advisories_input_address': u64(voidptr(input)).str()
	})
}

fn generate_vulns_advisories_input_from_value(value ruby.Value) &GenerateVulnsAdvisoriesInput {
	address := value.attributes['generate_vulns_advisories_input_address'] or {
		panic('invalid GenerateVulnsAdvisories input')
	}
	return unsafe { &GenerateVulnsAdvisoriesInput(voidptr(address.u64())) }
}

pub fn generate_vulns_formula_input_boundary(input &GenerateVulnsFormulaInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateVulnsAdvisories::FormulaInput', '', {
		'generate_vulns_formula_input_address': u64(voidptr(input)).str()
	})
}

fn generate_vulns_formula_input_from_value(value ruby.Value) &GenerateVulnsFormulaInput {
	address := value.attributes['generate_vulns_formula_input_address'] or {
		panic('invalid GenerateVulnsAdvisories formula input')
	}
	return unsafe { &GenerateVulnsFormulaInput(voidptr(address.u64())) }
}

pub fn generate_vulns_first_fixed_input_boundary(input &GenerateVulnsFirstFixedInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateVulnsAdvisories::FirstFixedInput', '', {
		'generate_vulns_first_fixed_input_address': u64(voidptr(input)).str()
	})
}

fn generate_vulns_first_fixed_input_from_value(value ruby.Value) &GenerateVulnsFirstFixedInput {
	address := value.attributes['generate_vulns_first_fixed_input_address'] or {
		panic('invalid GenerateVulnsAdvisories first-fixed input')
	}
	return unsafe { &GenerateVulnsFirstFixedInput(voidptr(address.u64())) }
}

fn generate_vulns_patch_value(patch vulns.OsvExportPatch) ruby.Value {
	mut resolves := []ruby.Value{}
	for resolve in patch.resolves {
		resolves << ruby.map_value({
			'type': ruby.string_value(resolve.resolve_type)
			'id':   ruby.string_value(resolve.id)
		})
	}
	return ruby.map_value({
		'type':     ruby.string_value(patch.patch_type)
		'url':      ruby.string_value(patch.url)
		'file':     ruby.string_value(patch.file)
		'apply':    ruby.string_array_value(patch.apply)
		'resolves': ruby.array_value(resolves)
	})
}

fn generate_vulns_result_value(result GenerateVulnsAdvisoriesResult) ruby.Value {
	return ruby.map_value({
		'annotated_count': ruby.int_value(result.annotated_count)
		'output_lines':    ruby.string_array_value(result.output_lines)
		'messages':        ruby.string_array_value(result.messages)
		'written_files':   ruby.string_array_value(result.written_files)
	})
}
