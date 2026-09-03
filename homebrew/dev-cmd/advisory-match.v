module dev_cmd

import homebrew.vulns
import os
import x.json2

// Translated from Homebrew/brew `dev-cmd/advisory-match.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type AdvisoryFormulaLoader = fn(string) !vulns.MatchFormula

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

// Ruby method `run` at line 48.
pub fn ruby_advisory_match_l48_d1_run(input AdvisoryRunInput) !AdvisoryRunResult {
	return run_advisory_match(input)
}

// Ruby method `local_repology` at line 86.
pub fn ruby_advisory_match_l86_d2_local_repology(path ?string) !AdvisoryLocalRepology {
	return advisory_local_repology(path)
}

// Ruby method `each_formula` at line 93.
pub fn ruby_advisory_match_l93_d3_each_formula(args AdvisoryMatchArgs,
	named_formulae []vulns.MatchFormula, core_formula_names []string, core_tap_name string,
	core_tap_installed bool, loader AdvisoryFormulaLoader) !AdvisoryFormulaEnumeration {
	return advisory_each_formula(args, named_formulae, core_formula_names, core_tap_name, core_tap_installed, loader)
}

// Ruby method `text_mode?` at line 111.
pub fn ruby_advisory_match_l111_d4_text_mode(args AdvisoryMatchArgs) bool {
	return advisory_text_mode(args)
}

// Ruby method `report(matcher, formula, hits)` at line 119.
pub fn ruby_advisory_match_l119_d5_report(formula vulns.MatchFormula,
	hits []vulns.MatchHit) []string {
	return advisory_report(formula, hits)
}

// Ruby method `<<(record); end` at line 146.
pub fn ruby_advisory_match_l146_d6_anonymous(mut emitter AdvisoryEmitter,
	record vulns.MatchBrewRecord) ! {
	emitter.append(record)!
}

// Ruby method `finish; end` at line 149.
pub fn ruby_advisory_match_l149_d7_finish(emitter AdvisoryEmitter) string {
	return emitter.finish()
}

// Ruby method `initialize(dir, verbose:)` at line 154.
pub fn ruby_advisory_match_l154_d8_initialize(dir string,
	verbose bool) !&AdvisoryEmitter {
	return new_advisory_emitter(.directory, dir, verbose)
}

// Ruby method `<<(record)` at line 165.
pub fn ruby_advisory_match_l165_d9_anonymous(mut emitter AdvisoryEmitter,
	record vulns.MatchBrewRecord) ! {
	emitter.append(record)!
}

// Ruby method `existing_source(path)` at line 186.
pub fn ruby_advisory_match_l186_d10_existing_source(path string) ?string {
	return advisory_existing_source(path)
}

// Ruby method `finish` at line 193.
pub fn ruby_advisory_match_l193_d11_finish(emitter AdvisoryEmitter) string {
	return emitter.finish()
}

// Ruby method `initialize` at line 201.
pub fn ruby_advisory_match_l201_d12_initialize() !&AdvisoryEmitter {
	return new_advisory_emitter(.json_output, '', false)
}

// Ruby method `<<(record)` at line 207.
pub fn ruby_advisory_match_l207_d13_anonymous(mut emitter AdvisoryEmitter,
	record vulns.MatchBrewRecord) ! {
	emitter.append(record)!
}

// Ruby method `finish` at line 212.
pub fn ruby_advisory_match_l212_d14_finish(emitter AdvisoryEmitter) string {
	return emitter.finish()
}

// Ruby method `initialize` at line 219.
pub fn ruby_advisory_match_l219_d15_initialize() !&AdvisoryEmitter {
	return new_advisory_emitter(.count, '', false)
}

// Ruby method `<<(_record)` at line 225.
pub fn ruby_advisory_match_l225_d16_anonymous(mut emitter AdvisoryEmitter,
	record vulns.MatchBrewRecord) ! {
	emitter.append(record)!
}

// Ruby method `finish` at line 230.
pub fn ruby_advisory_match_l230_d17_finish(emitter AdvisoryEmitter) string {
	return emitter.finish()
}

// Ruby method `build_emitter` at line 236.
pub fn ruby_advisory_match_l236_d18_build_emitter(args AdvisoryMatchArgs) !&AdvisoryEmitter {
	return advisory_build_emitter(args)
}

// Ruby method `emit_index(matcher)` at line 247.
pub fn ruby_advisory_match_l247_d19_emit_index(matcher vulns.MatchMatcher,
	formula_names []string, core_tap_name string, core_tap_installed bool,
	loader AdvisoryFormulaLoader) !AdvisoryIndexResult {
	return advisory_emit_index(matcher, formula_names, core_tap_name, core_tap_installed, loader)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "formula"
// 7: require "vulns/match"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class AdvisoryMatch < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Match <formula> against OSV.dev (GIT, language-registry and distro
// 15:           ecosystems) and CPANSA to produce candidate `BREW-*` advisory records
// 16:           for <https://github.com/Homebrew/advisory-database>.
// 17:
// 18:           This is authoring-time tooling for the advisory-database CI and the
// 19:           `homebrew-core` PR bot; use `brew vulns` to scan installed formulae.
// 20:         EOS
// 21:         switch "--all",
// 22:                description: "Match every formula in `homebrew/core`."
// 23:         switch "--index",
// 24:                description: "Emit the formula-identity index as JSON and exit."
// 25:         switch "--json",
// 26:                description: "Output candidate records as a JSON array."
// 27:         flag   "--output=",
// 28:                description: "Write each record to <directory> as " \
// 29:                             "`BREW-<formula>-<id>.json`, preserving existing " \
// 30:                             "`published`/`ranges` fields."
// 31:         flag   "--repology=",
// 32:                description: "Load the formula to distro-package index from " \
// 33:                             "<file> instead of the published `data/repology.json`."
// 34:         switch "--no-history",
// 35:                description: "Skip the `FormulaVersions` walk for the `fixed` " \
// 36:                             "boundary; use the current `pkg_version` instead."
// 37:         conflicts "--all", "--index"
// 38:         conflicts "--all", "--json"
// 39:         conflicts "--index", "--json"
// 40:         conflicts "--index", "--output"
// 41:
// 42:         named_args [:formula]
// 43:
// 44:         hide_from_man_page!
// 45:       end
// 46:
// 47:       sig { override.void }
// 48:       def run
// 49:         Formulary.enable_factory_cache!
// 50:         Homebrew.with_no_api_env do
// 51:           latest_macos = MacOSVersion.new((HOMEBREW_MACOS_NEWEST_UNSUPPORTED.to_i - 1).to_s).to_sym
// 52:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 53:             matcher = Homebrew::Vulns::Match.new(repology: local_repology, bulk: args.all? || args.index?)
// 54:             next emit_index(matcher) if args.index?
// 55:
// 56:             emitter = build_emitter
// 57:             begin
// 58:               matcher.each_advisory_batch(each_formula) do |formula, hits|
// 59:                 report(matcher, formula, hits) if text_mode?
// 60:                 hits.each do |hit|
// 61:                   # A `:not_applicable` hit (below every `introduced`) emitted
// 62:                   # as `{introduced: 0}` with no `fixed` reads to OSV consumers
// 63:                   # as currently affected; drop it instead.
// 64:                   status, = matcher.range_status(hit)
// 65:                   next if status&.state == :not_applicable
// 66:
// 67:                   first_fixed = matcher.first_fixed_version(formula, hit) unless args.no_history?
// 68:                   next if first_fixed == :never_affected
// 69:
// 70:                   boundary = first_fixed if first_fixed.is_a?(String)
// 71:                   emitter << matcher.to_brew_record(formula, hit, first_fixed: boundary)
// 72:                 end
// 73:               end
// 74:             rescue Homebrew::Vulns::OSV::Error => e
// 75:               onoe "OSV query failed: #{e.message}"
// 76:               Homebrew.failed = true
// 77:             end
// 78:             emitter.finish
// 79:           end
// 80:         end
// 81:       end
// 82:
// 83:       # A CI run that has just built the index locally (advisory-database's
// 84:       # Ingest) reads it directly instead of fetching the published copy.
// 85:       sig { returns(T.nilable(Homebrew::Vulns::Repology)) }
// 86:       def local_repology
// 87:         return unless (path = args.repology)
// 88:
// 89:         Homebrew::Vulns::Repology.from_file(Pathname(path))
// 90:       end
// 91:
// 92:       sig { returns(T::Enumerator[Formula]) }
// 93:       def each_formula
// 94:         return args.named.to_resolved_formulae.each unless args.all?
// 95:
// 96:         raise UsageError, "`--all` does not take named arguments" if args.named.any?
// 97:
// 98:         tap = CoreTap.instance
// 99:         raise TapUnavailableError, tap.name unless tap.installed?
// 100:
// 101:         Enumerator.new do |y|
// 102:           tap.formula_names.each do |name|
// 103:             y << Formulary.factory(name)
// 104:           rescue => e
// 105:             onoe "Error loading formula '#{name}': #{e}"
// 106:           end
// 107:         end
// 108:       end
// 109:
// 110:       sig { returns(T::Boolean) }
// 111:       def text_mode?
// 112:         !args.json? && args.output.nil?
// 113:       end
// 114:
// 115:       sig {
// 116:         params(matcher: Homebrew::Vulns::Match, formula: Formula,
// 117:                hits: T::Array[Homebrew::Vulns::Match::Hit]).void
// 118:       }
// 119:       def report(matcher, formula, hits)
// 120:         ohai "#{formula.name} #{formula.pkg_version}"
// 121:         if hits.empty?
// 122:           puts "  No advisories matched."
// 123:           return
// 124:         end
// 125:         hits.sort_by { |h| [-h.vulnerability.severity_level, h.canonical_id] }.each do |hit|
// 126:           v = hit.vulnerability
// 127:           status, = matcher.range_status(hit)
// 128:           state = case status&.state
// 129:           when nil       then "uncomparable"
// 130:           when :affected then "AFFECTED#{", upstream fix #{status&.fixed_in}" if status&.fixed_in}"
// 131:           when :fixed    then "fixed (upstream #{status&.fixed_in || "?"})"
// 132:           else "not applicable"
// 133:           end
// 134:           summary = v.summary&.slice(0, 60)
// 135:           puts "  #{hit.canonical_id} [#{hit.strategy}, #{matcher.confidence_for(hit, status)}] " \
// 136:                "#{v.severity_display} #{state}" \
// 137:                "#{" (resource: #{hit.resource})" if hit.resource}" \
// 138:                "#{" — #{summary}" if summary}"
// 139:         end
// 140:       end
// 141:
// 142:       # `--output` and text mode write per-record and only accumulate counts;
// 143:       # `--json` accumulates the array (single-formula / PR-bot use, so bounded).
// 144:       class Emitter
// 145:         sig { params(record: T::Hash[Symbol, T.untyped]).void }
// 146:         def <<(record); end
// 147:
// 148:         sig { void }
// 149:         def finish; end
// 150:       end
// 151:
// 152:       class DirEmitter < Emitter
// 153:         sig { params(dir: String, verbose: T::Boolean).void }
// 154:         def initialize(dir, verbose:)
// 155:           super()
// 156:           FileUtils.mkdir_p(dir)
// 157:           @dir = dir
// 158:           @verbose = verbose
// 159:           @written = T.let(0, Integer)
// 160:           @unchanged = T.let(0, Integer)
// 161:           @skipped_generated = T.let(0, Integer)
// 162:         end
// 163:
// 164:         sig { override.params(record: T::Hash[Symbol, T.untyped]).void }
// 165:         def <<(record)
// 166:           path = File.join(@dir, "#{record.fetch(:id)}.json")
// 167:           # A record already emitted by `generate-vulns-advisories` (a formula
// 168:           # `resolves` patch annotation) is more authoritative than a matched
// 169:           # candidate; overwriting it would drop `fix: "patch"` for a derived
// 170:           # `fix: null`/`"bump"`.
// 171:           if File.file?(path) && existing_source(path) == "generated"
// 172:             @skipped_generated += 1
// 173:             return
// 174:           end
// 175:           merged = Homebrew::Vulns::OsvExport.merge_existing(path, record)
// 176:           if merged.nil?
// 177:             @unchanged += 1
// 178:             return
// 179:           end
// 180:           File.write(path, "#{JSON.pretty_generate(merged)}\n")
// 181:           puts "  wrote #{path}" if @verbose
// 182:           @written += 1
// 183:         end
// 184:
// 185:         sig { params(path: String).returns(T.nilable(String)) }
// 186:         def existing_source(path)
// 187:           JSON.parse(File.read(path)).dig("database_specific", "source")
// 188:         rescue JSON::ParserError
// 189:           nil
// 190:         end
// 191:
// 192:         sig { override.void }
// 193:         def finish
// 194:           Utils::Output.ohai "#{@written} records written to #{@dir} " \
// 195:                              "(#{@unchanged} unchanged, #{@skipped_generated} generated left as-is)"
// 196:         end
// 197:       end
// 198:
// 199:       class JsonEmitter < Emitter
// 200:         sig { void }
// 201:         def initialize
// 202:           super
// 203:           @records = T.let([], T::Array[T::Hash[Symbol, T.untyped]])
// 204:         end
// 205:
// 206:         sig { override.params(record: T::Hash[Symbol, T.untyped]).void }
// 207:         def <<(record)
// 208:           @records << record
// 209:         end
// 210:
// 211:         sig { override.void }
// 212:         def finish
// 213:           puts JSON.pretty_generate(@records)
// 214:         end
// 215:       end
// 216:
// 217:       class CountEmitter < Emitter
// 218:         sig { void }
// 219:         def initialize
// 220:           super
// 221:           @count = T.let(0, Integer)
// 222:         end
// 223:
// 224:         sig { override.params(_record: T::Hash[Symbol, T.untyped]).void }
// 225:         def <<(_record)
// 226:           @count += 1
// 227:         end
// 228:
// 229:         sig { override.void }
// 230:         def finish
// 231:           Utils::Output.ohai "#{@count} candidate records"
// 232:         end
// 233:       end
// 234:
// 235:       sig { returns(Emitter) }
// 236:       def build_emitter
// 237:         if (dir = args.output)
// 238:           DirEmitter.new(dir, verbose: args.verbose?)
// 239:         elsif args.json?
// 240:           JsonEmitter.new
// 241:         else
// 242:           CountEmitter.new
// 243:         end
// 244:       end
// 245:
// 246:       sig { params(matcher: Homebrew::Vulns::Match).void }
// 247:       def emit_index(matcher)
// 248:         tap = CoreTap.instance
// 249:         raise TapUnavailableError, tap.name unless tap.installed?
// 250:
// 251:         index = tap.formula_names.each_with_object({}) do |name, h|
// 252:           identity = matcher.identify(Formulary.factory(name))
// 253:           next unless identity.identifiable?
// 254:
// 255:           h[name] = {
// 256:             git_repo:          identity.git_repo,
// 257:             git_tag:           identity.git_tag,
// 258:             primary_package:   identity.primary_package&.to_h,
// 259:             resource_packages: identity.resource_packages.transform_values(&:to_h),
// 260:             distro_packages:   identity.distro_packages,
// 261:           }.compact
// 262:         rescue => e
// 263:           onoe "Error loading formula '#{name}': #{e}"
// 264:         end
// 265:         puts JSON.pretty_generate(index)
// 266:       end
// 267:     end
// 268:   end
// 269: end
