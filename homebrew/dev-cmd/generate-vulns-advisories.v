module dev_cmd

import ruby
import homebrew.vulns
import os
import time
import x.json2

// Translated from Homebrew/brew `dev-cmd/generate-vulns-advisories.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `run` at line 29.
pub fn ruby_generate_vulns_advisories_l29_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	input := generate_vulns_advisories_input_from_value(args[0])
	mut command := new_generate_vulns_advisories_command(input.options)
	result := run_generate_vulns_advisories(mut command) or {
		error_type := if !input.options.tap_installed { 'TapUnavailableError' } else { 'Error' }
		return ruby.object_value(error_type, err.msg())
	}
	return generate_vulns_result_value(result)
}

// Ruby method `all_variation_patches(formula)` at line 75.
pub fn ruby_generate_vulns_advisories_l75_d2_all_variation_patches(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'formula input is required')
	}
	input := generate_vulns_formula_input_from_value(args[0])
	patches := generate_vulns_all_variation_patches(input.formula)
	return ruby.array_value(patches.map(generate_vulns_patch_value(it)))
}

// Ruby method `first_fixed_version(formula, vuln_id)` at line 103.
pub fn ruby_generate_vulns_advisories_l103_d3_first_fixed_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'first-fixed input is required')
	}
	mut input := generate_vulns_first_fixed_input_from_value(args[0])
	if fixed := generate_vulns_first_fixed_version(mut input.command, input.formula, input.vuln_id) {
		return ruby.string_value(fixed)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "formula_versions"
// 7: require "vulns/osv_export"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class GenerateVulnsAdvisories < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Generate OSV-schema advisory records for the `Homebrew` ecosystem from
// 15:           `homebrew/core` formula patch `resolves` annotations, for
// 16:           <https://github.com/Homebrew/advisory-database>.
// 17:
// 18:           Records are written to <directory>.
// 19:         EOS
// 20:         switch "-n", "--dry-run",
// 21:                description: "List the records that would be generated without writing files or querying OSV.dev."
// 22:
// 23:         named_args :directory, number: 1
// 24:
// 25:         hide_from_man_page!
// 26:       end
// 27:
// 28:       sig { override.void }
// 29:       def run
// 30:         tap = CoreTap.instance
// 31:         raise TapUnavailableError, tap.name unless tap.installed?
// 32:
// 33:         dir = args.named.first
// 34:
// 35:         Formulary.enable_factory_cache!
// 36:         Homebrew.with_no_api_env do
// 37:           latest_macos = MacOSVersion.new((HOMEBREW_MACOS_NEWEST_UNSUPPORTED.to_i - 1).to_s).to_sym
// 38:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 39:             annotated = tap.formula_names.filter_map do |name|
// 40:               formula = Formulary.factory(name)
// 41:               patches = all_variation_patches(formula)
// 42:               [formula, patches] if Homebrew::Vulns::Scanner.resolved_ids(patches).any?
// 43:             rescue
// 44:               onoe "Error loading formula '#{name}'."
// 45:               raise
// 46:             end
// 47:             ohai "#{annotated.size} formulae with security `resolves` annotations"
// 48:
// 49:             if args.dry_run?
// 50:               annotated.each do |formula, patches|
// 51:                 Homebrew::Vulns::Scanner.resolved_ids(patches).each do |vuln_id|
// 52:                   puts "#{Homebrew::Vulns::OsvExport::ID_PREFIX}-#{formula.name}-#{vuln_id}"
// 53:                 end
// 54:               end
// 55:               next
// 56:             end
// 57:
// 58:             written = Homebrew::Vulns::OsvExport.run(
// 59:               annotated, T.must(dir),
// 60:               first_fixed: ->(formula, vuln_id) { first_fixed_version(formula, vuln_id) }
// 61:             )
// 62:             written.each { |p| puts "  wrote #{p}" } if args.verbose?
// 63:             ohai "#{written.size} records written to #{dir}"
// 64:           end
// 65:         end
// 66:       end
// 67:
// 68:       # `Formula#serialized_patches` reflects the currently simulated OS and
// 69:       # architecture; a `patch` inside e.g. `on_linux` is invisible under
// 70:       # `SimulateSystem.with(os: :sequoia)`. Collect the union of the base
// 71:       # `patches` array and every OS/arch variation from
// 72:       # `Formula#to_hash_with_variations` so platform-gated `resolves`
// 73:       # annotations are exported.
// 74:       sig { params(formula: Formula).returns(T::Array[T::Hash[String, T.untyped]]) }
// 75:       def all_variation_patches(formula)
// 76:         hash = formula.to_hash_with_variations
// 77:         base = hash.fetch("patches")
// 78:         variation_patches = hash.fetch("variations").values.filter_map { |v| v["patches"] }
// 79:         (base + variation_patches.flatten(1)).uniq
// 80:       end
// 81:
// 82:       # Walk homebrew-core git history (newest first) via {FormulaVersions} and
// 83:       # return the `pkg_version` at the oldest revision where `vuln_id` still
// 84:       # appears in the formula's resolved patch ids: the version at which the
// 85:       # fix first shipped. Revisions that fail to load (older DSL) end the walk
// 86:       # early. Only invoked for records with no existing file, so the cost is
// 87:       # bounded to newly annotated (formula, CVE) pairs.
// 88:       #
// 89:       # Because `resolved_ids` includes CVEs inferred from patch URLs and
// 90:       # `apply` file paths, this finds the true fix version when the CVE is
// 91:       # named there. When a `resolves` line was added to a patch that had
// 92:       # already shipped without a CVE reference, it finds when `resolves` was
// 93:       # added (too recent); those cases are hand-corrected in the advisory
// 94:       # repository, which {Homebrew::Vulns::OsvExport.run} then preserves.
// 95:       #
// 96:       # Historical revisions are loaded under the enclosing {SimulateSystem}
// 97:       # (latest macOS/ARM) only; a `resolves` that lives inside e.g. `on_linux`
// 98:       # is invisible here and falls through to the current `pkg_version`.
// 99:       # {FormulaVersions} caches by revision alone, so per-variation historical
// 100:       # loading would need separate instances; deferred until a variation-only
// 101:       # security annotation actually exists in core.
// 102:       sig { params(formula: Formula, vuln_id: String).returns(T.nilable(String)) }
// 103:       def first_fixed_version(formula, vuln_id)
// 104:         # `FormulaVersions#rev_list` shells out to path-filtered `git rev-list`
// 105:         # over the whole homebrew-core history and dominates runtime; cache it
// 106:         # (and the instance, for its per-revision formula memoisation) per
// 107:         # formula so subsequent CVEs for the same formula reuse both.
// 108:         @formula_versions ||= T.let({}, T.nilable(T::Hash[String, FormulaVersions]))
// 109:         @formula_rev_lists ||= T.let({}, T.nilable(T::Hash[String, T::Array[[String, String]]]))
// 110:         fv = @formula_versions[formula.name] ||= FormulaVersions.new(formula)
// 111:         revs = @formula_rev_lists[formula.name] ||=
// 112:           [].tap { |a| fv.rev_list("HEAD") { |rev, entry| a << [rev, entry] } }
// 113:
// 114:         last_fixed = T.let(nil, T.nilable(String))
// 115:         revs.each do |rev, entry|
// 116:           resolved_here = fv.formula_at_revision(rev, entry) do |old|
// 117:             Homebrew::Vulns::Scanner.resolved_ids(old.serialized_patches).include?(vuln_id)
// 118:           end
// 119:           # `nil` means the revision failed to load; stop rather than guess.
// 120:           return last_fixed if resolved_here.nil?
// 121:           return last_fixed unless resolved_here
// 122:
// 123:           last_fixed = fv.formula_at_revision(rev, entry) { |old| old.pkg_version.to_s }
// 124:         end
// 125:         last_fixed
// 126:       end
// 127:     end
// 128:   end
// 129: end
