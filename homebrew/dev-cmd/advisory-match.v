module dev_cmd

import homebrew.vulns
import os
import x.json2

// Translated from Homebrew/brew `dev-cmd/advisory-match.rb`.
pub struct AdvisoryMatchArgs {
pub:
	all        bool
	index      bool
	json       bool
	output     ?string
	repology   ?string
	no_history bool
	verbose    bool
	named      []string
}

pub type AdvisoryFormulaLoader = fn (string) !vulns.MatchFormula

pub struct AdvisoryFormulaEnumeration {
pub:
	formulae []vulns.MatchFormula
	errors   []string
}

pub struct AdvisoryLocalRepology {
pub:
	configured bool
	database   vulns.RepologyDatabase
}

pub struct AdvisoryRunInput {
pub:
	args               AdvisoryMatchArgs
	named_formulae     []vulns.MatchFormula
	core_formula_names []string
	core_tap_name      string = 'homebrew/core'
	core_tap_installed bool = true
	matcher            vulns.MatchMatcher
	query_batch        vulns.MatchQueryBatch @[required]
	fetch              vulns.MatchVulnerabilityFetch @[required]
	formula_loader     AdvisoryFormulaLoader @[required]
	now                string
}

pub struct AdvisoryRunResult {
pub:
	stdout                string
	stderr                string
	failed                bool
	factory_cache_enabled bool
	simulated_arch        string
	written               int
	unchanged             int
	skipped_generated     int
	emitted               int
}

pub enum AdvisoryEmitterKind {
	base
	directory
	json_output
	count
}

@[heap]
pub struct AdvisoryEmitter {
pub:
	kind    AdvisoryEmitterKind
	dir     string
	verbose bool
pub mut:
	records           []vulns.MatchBrewRecord
	written           int
	unchanged         int
	skipped_generated int
	count             int
	messages          []string
}

pub struct AdvisoryIndexResult {
pub:
	json   string
	errors []string
}

fn advisory_stdout(chunks []string) string {
	if chunks.len == 0 {
		return ''
	}
	return '${chunks.join('\n')}\n'
}

pub fn parse_advisory_match_args(argv []string) !AdvisoryMatchArgs {
	mut all := false
	mut index := false
	mut json_output := false
	mut output := ?string(none)
	mut repology := ?string(none)
	mut no_history := false
	mut verbose := false
	mut named := []string{}
	mut position := 0
	for position < argv.len {
		argument := argv[position]
		match argument {
			'--all' {
				all = true
			}
			'--index' {
				index = true
			}
			'--json' {
				json_output = true
			}
			'--no-history' {
				no_history = true
			}
			'--verbose', '-v' {
				verbose = true
			}
			'--output', '--repology' {
				if position + 1 >= argv.len {
					return error('${argument} requires a value')
				}
				position++
				if argument == '--output' {
					output = argv[position]
				} else {
					repology = argv[position]
				}
			}
			else {
				if argument.starts_with('--output=') {
					output = argument.all_after('=')
				} else if argument.starts_with('--repology=') {
					repology = argument.all_after('=')
				} else if argument.starts_with('-') {
					return error('unknown option: ${argument}')
				} else {
					named << argument
				}
			}
		}
		position++
	}
	if (all && index) || (all && json_output) || (index && json_output) || (index && output != none) {
		return error('options are mutually exclusive')
	}
	return AdvisoryMatchArgs{
		all: all
		index: index
		json: json_output
		output: output
		repology: repology
		no_history: no_history
		verbose: verbose
		named: named
	}
}

fn advisory_read_file(path string) !string {
	return os.read_file(path)
}

pub fn advisory_local_repology(path ?string) !AdvisoryLocalRepology {
	configured := path or {
		return AdvisoryLocalRepology{
			database: vulns.new_repology_database(json2.Any({
				'meta':     json2.Any(map[string]json2.Any{})
				'formulae': json2.Any(map[string]json2.Any{})
			}))!
		}
	}
	return AdvisoryLocalRepology{
		configured: true
		database: vulns.repology_from_file(configured, advisory_read_file)!
	}
}

pub fn advisory_each_formula(args AdvisoryMatchArgs, named_formulae []vulns.MatchFormula,
	core_formula_names []string, core_tap_name string, core_tap_installed bool,
	loader AdvisoryFormulaLoader) !AdvisoryFormulaEnumeration {
	if !args.all {
		return AdvisoryFormulaEnumeration{
			formulae: named_formulae.clone()
		}
	}
	if args.named.len > 0 {
		return error('`--all` does not take named arguments')
	}
	if !core_tap_installed {
		return error('Tap unavailable: ${core_tap_name}')
	}
	mut formulae := []vulns.MatchFormula{}
	mut errors := []string{}
	for name in core_formula_names {
		formulae << loader(name) or {
			errors << "Error loading formula '${name}': ${err.msg()}"
			continue
		}
	}
	return AdvisoryFormulaEnumeration{
		formulae: formulae
		errors: errors
	}
}

pub fn advisory_text_mode(args AdvisoryMatchArgs) bool {
	return !args.json && args.output == none
}

fn advisory_severity(hit vulns.MatchHit) (int, string) {
	mut best_level := 0
	mut best_display := 'UNKNOWN'
	for entry in hit.vulnerability.severity_entries {
		severity := vulns.cvss_severity(entry.score) or { continue }
		level := match severity {
			.critical { 4 }
			.high { 3 }
			.medium { 2 }
			.low { 1 }
		}
		if level > best_level {
			best_level = level
			best_display = severity.symbol().to_upper()
		}
	}
	return best_level, best_display
}

fn advisory_summary(summary ?string) string {
	value := summary or { return '' }
	runes := value.runes()
	return if runes.len <= 60 { value } else { runes[..60].string() }
}

pub fn advisory_report(formula vulns.MatchFormula, hits []vulns.MatchHit) []string {
	mut lines := ['${formula.name} ${formula.pkg_version}']
	if hits.len == 0 {
		lines << '  No advisories matched.'
		return lines
	}
	mut sorted := hits.clone()
	sorted.sort_with_compare(fn (left &vulns.MatchHit, right &vulns.MatchHit) int {
		left_level, _ := advisory_severity(*left)
		right_level, _ := advisory_severity(*right)
		if left_level != right_level {
			return right_level - left_level
		}
		return left.canonical_id().compare(right.canonical_id())
	})
	for hit in sorted {
		_, severity_display := advisory_severity(hit)
		status := vulns.match_range_status(hit)
		state := if current := status {
			match current.status.state {
				.affected {
					if fixed := current.status.fixed_in {
						'AFFECTED, upstream fix ${fixed}'
					} else {
						'AFFECTED'
					}
				}
				.fixed { 'fixed (upstream ${current.status.fixed_in or { '?' }})' }
				.not_applicable { 'not applicable' }
			}
		} else {
			'uncomparable'
		}
		resource := if name := hit.resource() { ' (resource: ${name})' } else { '' }
		summary := advisory_summary(hit.vulnerability.summary)
		summary_suffix := if summary == '' { '' } else { ' — ${summary}' }
		lines << '  ${hit.canonical_id()} [${hit.strategy()}, ${vulns.match_confidence(hit, status != none)}] ${severity_display} ${state}${resource}${summary_suffix}'
	}
	return lines
}

fn advisory_canonical(value json2.Any, ignore_modified bool) string {
	if value is map[string]json2.Any {
		mut keys := value.keys()
		keys.sort()
		mut parts := []string{}
		for key in keys {
			if ignore_modified && key == 'modified' {
				continue
			}
			parts << '${json2.encode(key)}:${advisory_canonical(value[key] or { continue }, false)}'
		}
		return '{${parts.join(',')}}'
	}
	if value is []json2.Any {
		return '[${value.map(advisory_canonical(it, false)).join(',')}]'
	}
	return json2.encode(value)
}

pub fn advisory_existing_source(path string) ?string {
	contents := os.read_file(path) or { return none }
	data := json2.decode[json2.Any](contents) or { return none }
	if data !is map[string]json2.Any {
		return none
	}
	database := data.as_map()['database_specific'] or { return none }
	if database !is map[string]json2.Any {
		return none
	}
	source := database.as_map()['source'] or { return none }
	if source is string {
		return source
	}
	return none
}

pub fn advisory_merge_existing(path string,
	record vulns.MatchBrewRecord) ?vulns.MatchBrewRecord {
	if !os.is_file(path) {
		return record
	}
	contents := os.read_file(path) or { return record }
	existing := json2.decode[vulns.MatchBrewRecord](contents) or { return record }
	mut affected := record.affected.clone()
	for index in 0 .. affected.len {
		if index < existing.affected.len {
			affected[index] = vulns.MatchAffectedEntry{
				...affected[index]
				ranges: existing.affected[index].ranges.clone()
			}
		}
	}
	published := if existing.published != '' {
		existing.published
	} else if existing.modified != '' {
		existing.modified
	} else {
		record.published
	}
	merged := vulns.MatchBrewRecord{
		...record
		published: published
		affected: affected
	}
	existing_value := json2.decode[json2.Any](contents) or { return merged }
	merged_value := json2.decode[json2.Any](json2.encode(merged)) or { return merged }
	if advisory_canonical(existing_value, true) == advisory_canonical(merged_value, true) {
		return none
	}
	return merged
}

pub fn new_advisory_emitter(kind AdvisoryEmitterKind, dir string,
	verbose bool) !&AdvisoryEmitter {
	if kind == .directory {
		os.mkdir_all(dir)!
	}
	return &AdvisoryEmitter{
		kind: kind
		dir: dir
		verbose: verbose
	}
}

pub fn (mut emitter AdvisoryEmitter) append(record vulns.MatchBrewRecord) ! {
	match emitter.kind {
		.base {}
		.directory {
			path := os.join_path(emitter.dir, '${record.id}.json')
			if os.is_file(path) {
				if source := advisory_existing_source(path) {
					if source == 'generated' {
						emitter.skipped_generated++
						return
					}
				}
			}
			merged := advisory_merge_existing(path, record) or {
				emitter.unchanged++
				return
			}
			os.write_file(path, '${json2.encode(merged, prettify: true)}\n')!
			if emitter.verbose {
				emitter.messages << '  wrote ${path}'
			}
			emitter.written++
		}
		.json_output { emitter.records << record }
		.count { emitter.count++ }
	}
}

pub fn (emitter AdvisoryEmitter) finish() string {
	return match emitter.kind {
		.base { '' }
		.directory {
			'${emitter.written} records written to ${emitter.dir} (${emitter.unchanged} unchanged, ${emitter.skipped_generated} generated left as-is)'
		}
		.json_output {
			if emitter.records.len == 0 {
				'[]'
			} else {
				json2.encode(emitter.records,
					prettify: true
				)
			}
		}
		.count { '${emitter.count} candidate records' }
	}
}

pub fn advisory_build_emitter(args AdvisoryMatchArgs) !&AdvisoryEmitter {
	if dir := args.output {
		return new_advisory_emitter(.directory, dir, args.verbose)
	}
	if args.json {
		return new_advisory_emitter(.json_output, '', false)
	}
	return new_advisory_emitter(.count, '', false)
}

fn advisory_registry_package_json(package vulns.MatchRegistryPackage) json2.Any {
	return json2.Any({
		'ecosystem': json2.Any(package.ecosystem)
		'name':      json2.Any(package.name)
		'version':   json2.Any(package.version)
		'purl':      json2.Any(package.purl)
	})
}

fn advisory_identity_json(identity vulns.MatchIdentity) json2.Any {
	mut data := map[string]json2.Any{}
	if repository := identity.git_repo {
		data['git_repo'] = json2.Any(repository)
	}
	if tag := identity.git_tag {
		data['git_tag'] = json2.Any(tag)
	}
	if package := identity.primary_package {
		data['primary_package'] = advisory_registry_package_json(package)
	}
	if identity.resource_packages.len > 0 {
		mut packages := map[string]json2.Any{}
		for name, package in identity.resource_packages {
			packages[name] = advisory_registry_package_json(package)
		}
		data['resource_packages'] = json2.Any(packages)
	}
	if identity.distro_packages.len > 0 {
		mut packages := map[string]json2.Any{}
		for ecosystem, names in identity.distro_packages {
			packages[ecosystem] = json2.Any(names.map(json2.Any(it)))
		}
		data['distro_packages'] = json2.Any(packages)
	}
	return json2.Any(data)
}

pub fn advisory_emit_index(matcher vulns.MatchMatcher, formula_names []string,
	core_tap_name string, core_tap_installed bool,
	loader AdvisoryFormulaLoader) !AdvisoryIndexResult {
	if !core_tap_installed {
		return error('Tap unavailable: ${core_tap_name}')
	}
	mut index := map[string]json2.Any{}
	mut errors := []string{}
	for name in formula_names {
		formula := loader(name) or {
			errors << "Error loading formula '${name}': ${err.msg()}"
			continue
		}
		identity := matcher.identify(formula)
		if identity.identifiable() {
			index[name] = advisory_identity_json(identity)
		}
	}
	return AdvisoryIndexResult{
		json: json2.encode(index, prettify: true)
		errors: errors
	}
}

pub fn run_advisory_match(input AdvisoryRunInput) !AdvisoryRunResult {
	mut stdout := []string{}
	mut stderr := []string{}
	mut repology := input.matcher.repology
	if input.args.repology != none {
		repology = advisory_local_repology(input.args.repology)!.database
	}
	matcher := vulns.new_matcher(repology, input.matcher.cpan_sec, input.args.all || input.args.index)
	if input.args.index {
		index := advisory_emit_index(matcher, input.core_formula_names, input.core_tap_name, input.core_tap_installed, input.formula_loader)!
		stdout << index.json
		stderr << index.errors
		return AdvisoryRunResult{
			stdout: advisory_stdout(stdout)
			stderr: advisory_stdout(stderr)
			factory_cache_enabled: true
			simulated_arch: 'arm'
		}
	}
	selection := advisory_each_formula(input.args, input.named_formulae, input.core_formula_names, input.core_tap_name, input.core_tap_installed, input.formula_loader)!
	stderr << selection.errors
	mut emitter := advisory_build_emitter(input.args)!
	identities := selection.formulae.map(matcher.identify(it))
	versions := selection.formulae.map(it.pkg_version)
	mut failed := false
	batches := vulns.match_each_advisory_batch(identities, versions, matcher.cpan_sec, input.query_batch, input.fetch) or {
		stderr << 'OSV query failed: ${err.msg()}'
		failed = true
		[][]vulns.MatchHit{len: selection.formulae.len}
	}
	for index, formula in selection.formulae {
		hits := if index < batches.len { batches[index] } else { []vulns.MatchHit{} }
		if advisory_text_mode(input.args) {
			stdout << advisory_report(formula, hits)
		}
		for hit in hits {
			if status := vulns.match_range_status(hit) {
				if status.status.state == .not_applicable {
					continue
				}
			}
			mut boundary := ?string(none)
			if !input.args.no_history {
				if first_fixed := vulns.match_first_fixed_version(formula, hit) {
					if first_fixed == 'never_affected' {
						continue
					}
					boundary = first_fixed
				}
			}
			emitter.append(vulns.match_to_brew_record(formula, hit, boundary, input.now))!
		}
	}
	stdout << emitter.messages
	stdout << emitter.finish()
	return AdvisoryRunResult{
		stdout: advisory_stdout(stdout)
		stderr: advisory_stdout(stderr)
		failed: failed
		factory_cache_enabled: true
		simulated_arch: 'arm'
		written: emitter.written
		unchanged: emitter.unchanged
		skipped_generated: emitter.skipped_generated
		emitted: if emitter.kind == .count {
			emitter.count
		} else if emitter.kind == .json_output {
			emitter.records.len
		} else {
			emitter.written
		}
	}
}
