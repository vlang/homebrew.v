module test_bot

pub struct FormulaeDependentsDependency {
pub:
	name             string
	formula_name     string
	build            bool
	test             bool
	optional         bool
	implicit         bool
	satisfied        bool
	bottled_or_built bool = true
}

pub struct FormulaeDependentsFormula {
pub:
	name                       string
	full_name                  string
	dependencies               []FormulaeDependentsDependency
	requirements               []FormulaeDependentsDependency
	conflicts                  []string
	recursive_dependencies     []string
	latest_version_installed   bool
	any_version_installed      bool
	deprecated                 bool
	disabled                   bool
	keg_only                   bool
	linked                     bool
	bottled                    bool
	bottled_on_current_version bool
	test_defined               bool
	unsatisfied_requirements   []string
	fetch_passed               bool = true
	install_passed             bool = true
	linkage_passed             bool = true
	test_passed                bool = true
}

pub struct FormulaeDependentPair {
pub:
	dependent    FormulaeDependentsFormula
	dependencies []FormulaeDependentsDependency
}

pub struct FormulaeDependentsArgs {
pub:
	formulae_dependents_shard    string
	only_formulae_dependents     bool
	dry_run                      bool
	build_dependents_from_source bool
	test_default_formula         bool
	skip_recursive_dependents    bool = true
}

pub enum FormulaeDependentsOperationKind {
	info_header
	output
	blank_line
	test_header
	cleanup
	download_artifacts
	install_bottle
	fetch
	install
	postinstall
	link
	linkage
	test
	uninstall
	untap
	unlink
	skipped
	annotation
}

pub struct FormulaeDependentsOperation {
pub:
	kind            FormulaeDependentsOperationKind
	text            string
	command         []string
	ignore_failures bool
	passed          bool = true
}

pub struct FormulaeDependentsConfig {
pub:
	tap_core_cask        bool
	core_cask_installed  bool
	github_actions       bool
	previous_github_sha  string
	formulae             map[string]FormulaeDependentsFormula
	dependent_pairs      map[string][]FormulaeDependentPair
	skip_candidates      []string
	artifact_cache_valid map[string]bool
	testing_formulae     []string
	tested_formulae      []string
	skipped_or_failed    []string
}

@[heap]
pub struct FormulaeDependents {
pub:
	tap_core_cask        bool
	core_cask_installed  bool
	github_actions       bool
	previous_github_sha  string
	formulae             map[string]FormulaeDependentsFormula
	configured_pairs     map[string][]FormulaeDependentPair
	artifact_cache_valid map[string]bool
pub mut:
	testing_formulae                        []string
	tested_formulae                         []string
	skipped_or_failed_formulae              []string
	testing_formulae_with_tested_dependents []string
	dependent_testing_formulae              []string
	tested_dependents                       []string
	formulae_dependents_filter              []string
	formulae_dependents_filter_set          bool
	dependent_pairs_by_formula              map[string][]FormulaeDependentPair
	skip_candidates                         []string
	tested_dependents_list                  []string
	operations                              []FormulaeDependentsOperation
}

pub struct FormulaeDependentsSelection {
pub:
	source_dependents   []FormulaeDependentsFormula
	bottled_dependents  []FormulaeDependentsFormula
	testable_dependents []FormulaeDependentsFormula
}

pub struct FormulaeDependentsRun {
pub:
	dependent_testing_formulae []string
	tested_dependents          []string
	skipped_or_failed_formulae []string
	filter                     []string
	operations                 []FormulaeDependentsOperation
}

pub fn new_formulae_dependents(config FormulaeDependentsConfig) &FormulaeDependents {
	return &FormulaeDependents{
		tap_core_cask: config.tap_core_cask
		core_cask_installed: config.core_cask_installed
		github_actions: config.github_actions
		previous_github_sha: config.previous_github_sha
		formulae: config.formulae.clone()
		configured_pairs: config.dependent_pairs.clone()
		artifact_cache_valid: config.artifact_cache_valid.clone()
		testing_formulae: config.testing_formulae.clone()
		tested_formulae: config.tested_formulae.clone()
		skipped_or_failed_formulae: config.skipped_or_failed.clone()
		skip_candidates: config.skip_candidates.clone()
		dependent_pairs_by_formula: map[string][]FormulaeDependentPair{}
	}
}

fn formulae_dependents_full_name(formula FormulaeDependentsFormula) string {
	return if formula.full_name == '' { formula.name } else { formula.full_name }
}

fn formulae_dependents_dependency_name(dependency FormulaeDependentsDependency) string {
	return if dependency.formula_name == '' { dependency.name } else { dependency.formula_name }
}

fn formulae_dependents_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if value !in result {
			result << value
		}
	}
	return result
}

fn formulae_dependents_without(values []string, removed []string) []string {
	return values.filter(it !in removed)
}

fn formulae_dependents_sorted(values []string) []string {
	mut result := values.clone()
	result.sort()
	return result
}

fn formulae_dependents_formula(values map[string]FormulaeDependentsFormula,
	name string) !FormulaeDependentsFormula {
	formula := values[name] or { return error('Formula unavailable: ${name}') }
	return formula
}

fn formulae_dependents_operation(kind FormulaeDependentsOperationKind, command []string,
	text string, passed bool, ignore_failures bool) FormulaeDependentsOperation {
	return FormulaeDependentsOperation{
		kind: kind
		command: command.clone()
		text: text
		passed: passed
		ignore_failures: ignore_failures
	}
}

fn formulae_dependents_valid_shard_part(part string) bool {
	if part == '' || part[0] == `0` {
		return false
	}
	for character in part.bytes() {
		if character < `0` || character > `9` {
			return false
		}
	}
	return true
}

fn formulae_dependents_group_min_name(group []FormulaeDependentPair) string {
	if group.len == 0 {
		return ''
	}
	mut result := formulae_dependents_full_name(group[0].dependent)
	for pair in group[1..] {
		name := formulae_dependents_full_name(pair.dependent)
		if name < result {
			result = name
		}
	}
	return result
}

fn formulae_dependents_sort_groups(mut groups [][]FormulaeDependentPair) {
	for left in 0 .. groups.len {
		mut best := left
		for right in left + 1 .. groups.len {
			if groups[right].len > groups[best].len
				|| (groups[right].len == groups[best].len
					&& formulae_dependents_group_min_name(groups[right]) < formulae_dependents_group_min_name(groups[best])) {
				best = right
			}
		}
		if best != left {
			temporary := groups[left]
			groups[left] = groups[best]
			groups[best] = temporary
		}
	}
}

fn formulae_dependents_sort_pairs(values []FormulaeDependentPair) []FormulaeDependentPair {
	mut result := values.clone()
	for left in 0 .. result.len {
		mut best := left
		for right in left + 1 .. result.len {
			if formulae_dependents_full_name(result[right].dependent) < formulae_dependents_full_name(result[best].dependent) {
				best = right
			}
		}
		if best != left {
			temporary := result[left]
			result[left] = result[best]
			result[best] = temporary
		}
	}
	return result
}

pub fn dependents_for_shard(dependents []FormulaeDependentPair,
	shard string) ![]FormulaeDependentPair {
	parts := shard.split('/')
	if parts.len != 2 || !formulae_dependents_valid_shard_part(parts[0])
		|| !formulae_dependents_valid_shard_part(parts[1]) {
		return error('`--formulae-dependents-shard` must use the format <SHARD/TOTAL>.')
	}
	shard_index := parts[0].int()
	shard_count := parts[1].int()
	if shard_index > shard_count {
		return error('`--formulae-dependents-shard` must not be greater than the total shard count.')
	}
	if shard_count == 1 {
		return dependents.clone()
	}

	mut dependents_by_name := map[string]FormulaeDependentPair{}
	mut edges := map[string][]string{}
	for pair in dependents {
		name := formulae_dependents_full_name(pair.dependent)
		dependents_by_name[name] = pair
		edges[name] = []string{}
	}
	for pair in dependents {
		dependent_name := formulae_dependents_full_name(pair.dependent)
		for dependency in pair.dependencies {
			dependency_name := formulae_dependents_dependency_name(dependency)
			if dependency_name !in edges {
				continue
			}
			mut dependent_edges := edges[dependent_name]
			dependent_edges << dependency_name
			edges[dependent_name] = dependent_edges
			mut dependency_edges := edges[dependency_name]
			dependency_edges << dependent_name
			edges[dependency_name] = dependency_edges
		}
	}

	mut seen := map[string]bool{}
	mut groups := [][]FormulaeDependentPair{}
	max_group_size := (dependents.len + shard_count - 1) / shard_count
	for pair in dependents {
		dependent_name := formulae_dependents_full_name(pair.dependent)
		if seen[dependent_name] {
			continue
		}
		mut group := []FormulaeDependentPair{}
		mut queue := [dependent_name]
		for queue.len > 0 {
			name := queue[0]
			queue.delete(0)
			if seen[name] {
				continue
			}
			seen[name] = true
			group << dependents_by_name[name]
			if group.len >= max_group_size {
				break
			}
			for edge in edges[name] {
				if !seen[edge] {
					queue << edge
				}
			}
		}
		groups << group
	}

	formulae_dependents_sort_groups(mut groups)
	mut shards := [][]FormulaeDependentPair{len: shard_count}
	for group in groups {
		mut group_shard_index := 0
		for index, current_shard in shards {
			if current_shard.len < shards[group_shard_index].len {
				group_shard_index = index
			}
		}
		shards[group_shard_index] << group
	}
	return formulae_dependents_sort_pairs(shards[shard_index - 1])
}

fn formulae_dependents_prioritize_texlive(values []FormulaeDependentsFormula) []FormulaeDependentsFormula {
	mut result := []FormulaeDependentsFormula{}
	for formula in values {
		if formula.name == 'texlive' {
			result << formula
		}
	}
	for formula in values {
		if formula.name != 'texlive' {
			result << formula
		}
	}
	return result
}

fn formulae_dependents_contains_formula(values []FormulaeDependentsFormula,
	formula FormulaeDependentsFormula) bool {
	full_name := formulae_dependents_full_name(formula)
	return values.any(formulae_dependents_full_name(it) == full_name)
}

fn formulae_dependents_unique_formulae(values []FormulaeDependentsFormula) []FormulaeDependentsFormula {
	mut result := []FormulaeDependentsFormula{}
	for formula in values {
		if !formulae_dependents_contains_formula(result, formula) {
			result << formula
		}
	}
	return result
}

// Translated from Homebrew/brew `test_bot/formulae_dependents.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_writer `attr_writer :testing_formulae` at line 11.
pub fn ruby_formulae_dependents_l11_d1_testing_formulae(mut formulae_dependents FormulaeDependents,
	testing_formulae []string) []string {
	formulae_dependents.testing_formulae = testing_formulae.clone()
	return formulae_dependents.testing_formulae.clone()
}

// Ruby attr_writer `attr_writer :tested_formulae` at line 14.
pub fn ruby_formulae_dependents_l14_d2_tested_formulae(mut formulae_dependents FormulaeDependents,
	tested_formulae []string) []string {
	formulae_dependents.tested_formulae = tested_formulae.clone()
	return formulae_dependents.tested_formulae.clone()
}

// Ruby method `initialize(tap:, git:, dry_run:, fail_fast:, verbose:)` at line 25.
pub fn ruby_formulae_dependents_l25_d3_initialize(config FormulaeDependentsConfig) &FormulaeDependents {
	return new_formulae_dependents(config)
}

// Ruby method `run!(args:)` at line 36.
pub fn ruby_formulae_dependents_l36_d4_run(mut formulae_dependents FormulaeDependents,
	args FormulaeDependentsArgs) !FormulaeDependentsRun {
	return formulae_dependents.run(args)
}

// Ruby method `dependents_for_shard(dependents, shard)` at line 99.
pub fn ruby_formulae_dependents_l99_d5_dependents_for_shard(dependents []FormulaeDependentPair,
	shard string) ![]FormulaeDependentPair {
	return dependents_for_shard(dependents, shard)
}

// Ruby method `install_formulae_if_needed_from_bottles!(installable_bottles, args:)` at line 167.
pub fn ruby_formulae_dependents_l167_d6_install_formulae_if_needed_from_bottles(mut formulae_dependents FormulaeDependents,
	installable_bottles []string, args FormulaeDependentsArgs) ! {
	formulae_dependents.install_formulae_if_needed_from_bottles(installable_bottles, args)!
}

// Ruby method `dependent_formulae!(formula_name, args:)` at line 177.
pub fn ruby_formulae_dependents_l177_d7_dependent_formulae(mut formulae_dependents FormulaeDependents,
	formula_name string, args FormulaeDependentsArgs) ! {
	formulae_dependents.dependent_formulae(formula_name, args)!
}

// Ruby method `dependents_for_formula(formula, formula_name, args:)` at line 239.
pub fn ruby_formulae_dependents_l239_d8_dependents_for_formula(mut formulae_dependents FormulaeDependents,
	formula FormulaeDependentsFormula, formula_name string,
	args FormulaeDependentsArgs) !FormulaeDependentsSelection {
	return formulae_dependents.dependents_for_formula(formula, formula_name, args)
}

// Ruby method `dependent_pairs_for_formula(formula, formula_name, args:)` at line 293.
pub fn ruby_formulae_dependents_l293_d9_dependent_pairs_for_formula(mut formulae_dependents FormulaeDependents,
	formula FormulaeDependentsFormula, formula_name string,
	args FormulaeDependentsArgs) []FormulaeDependentPair {
	return formulae_dependents.dependent_pairs_for_formula(formula, formula_name, args)
}

// Ruby method `install_dependent(dependent, testable_dependents, args:, build_from_source: false)` at line 355.
pub fn ruby_formulae_dependents_l355_d10_install_dependent(mut formulae_dependents FormulaeDependents,
	dependent FormulaeDependentsFormula, testable_dependents []FormulaeDependentsFormula,
	args FormulaeDependentsArgs, build_from_source bool) ! {
	formulae_dependents.install_dependent(dependent, testable_dependents, args, build_from_source)!
}

// Ruby method `skip_recursive_dependents?(_formula, args:)` at line 508.
pub fn ruby_formulae_dependents_l508_d11_skip_recursive_dependents(_formula FormulaeDependentsFormula,
	args FormulaeDependentsArgs) bool {
	return args.skip_recursive_dependents
}

// Ruby method `build_dependent_from_source?(_dependent)` at line 513.
pub fn formulae_dependents_build_dependent_from_source(_dependent FormulaeDependentsFormula) bool {
	return true
}

// Ruby method `unlink_conflicts(formula)` at line 518.
pub fn ruby_formulae_dependents_l518_d13_unlink_conflicts(mut formulae_dependents FormulaeDependents,
	formula FormulaeDependentsFormula) {
	formulae_dependents.unlink_conflicts(formula)
}

pub fn (mut formulae_dependents FormulaeDependents) install_formulae_if_needed_from_bottles(installable_bottles []string,
	args FormulaeDependentsArgs) ! {
	for formula_name in installable_bottles {
		formula := formulae_dependents_formula(formulae_dependents.formulae, formula_name)!
		if formula.latest_version_installed {
			continue
		}
		formulae_dependents.operations << formulae_dependents_operation(.install_bottle, [
			'brew',
			'install',
			'--formula',
			'--bottle',
			formula_name,
		], '', true, args.dry_run)
	}
}

pub fn (mut formulae_dependents FormulaeDependents) dependent_pairs_for_formula(_formula FormulaeDependentsFormula,
	formula_name string, args FormulaeDependentsArgs) []FormulaeDependentPair {
	if cached := formulae_dependents.dependent_pairs_by_formula[formula_name] {
		return cached.clone()
	}
	mut pairs := formulae_dependents.configured_pairs[formula_name].clone()
	pairs = pairs.filter(formulae_dependents_full_name(it.dependent) !in formulae_dependents.tested_formulae)
	mut filtered := []FormulaeDependentPair{}
	still_to_test := formulae_dependents_without(formulae_dependents.dependent_testing_formulae, formulae_dependents.testing_formulae_with_tested_dependents)
	for pair in pairs {
		mut dependencies := []FormulaeDependentsDependency{}
		for dependency in pair.dependencies {
			if dependency.optional || dependency.implicit {
				continue
			}
			dependencies << dependency
		}
		if !args.only_formulae_dependents
			&& dependencies.any(formulae_dependents_dependency_name(it) in still_to_test) {
			continue
		}
		filtered << FormulaeDependentPair{
			dependent: pair.dependent
			dependencies: dependencies
		}
	}
	formulae_dependents.dependent_pairs_by_formula[formula_name] = filtered.clone()
	return filtered
}

pub fn (mut formulae_dependents FormulaeDependents) dependents_for_formula(formula FormulaeDependentsFormula,
	formula_name string, args FormulaeDependentsArgs) FormulaeDependentsSelection {
	formulae_dependents.operations << formulae_dependents_operation(.info_header, []string{}, 'Determining dependents...', true, false)
	mut pairs := formulae_dependents.dependent_pairs_for_formula(formula, formula_name, args)
	if formulae_dependents.formulae_dependents_filter_set {
		pairs = pairs.filter(it.dependent.name in formulae_dependents.formulae_dependents_filter
			|| formulae_dependents_full_name(it.dependent) in formulae_dependents.formulae_dependents_filter)
	}
	pairs = pairs.filter(formulae_dependents_full_name(it.dependent) !in formulae_dependents.tested_dependents)

	mut source_dependents := []FormulaeDependentsFormula{}
	mut remaining := []FormulaeDependentPair{}
	for pair in pairs {
		all_deps_bottled_or_built := pair.dependencies.all(it.bottled_or_built)
		if formulae_dependents_build_dependent_from_source(pair.dependent)
			&& args.build_dependents_from_source && all_deps_bottled_or_built {
			source_dependents << pair.dependent
		} else {
			remaining << pair
		}
	}
	formula_full_name := formulae_dependents_full_name(formula)
	remaining = remaining.filter(it.dependencies.any(!it.build || it.test)
		&& it.dependencies.filter(!it.build || it.test).any(formulae_dependents_dependency_name(it) == formula_full_name
			|| formulae_dependents_dependency_name(it) == formula.name))
	mut bottled_dependents := []FormulaeDependentsFormula{}
	for pair in remaining {
		if pair.dependent.bottled {
			bottled_dependents << pair.dependent
		}
	}
	mut testable_dependents := source_dependents.filter(it.test_defined)
	testable_dependents << bottled_dependents.filter(it.test_defined)
	testable_dependents = formulae_dependents_unique_formulae(testable_dependents)

	for header in ['Source dependents:', 'Bottled dependents:', 'Testable dependents:'] {
		formulae_dependents.operations << formulae_dependents_operation(.info_header, []string{}, header, true, false)
	}
	return FormulaeDependentsSelection{
		source_dependents: source_dependents
		bottled_dependents: bottled_dependents
		testable_dependents: testable_dependents
	}
}

pub fn (mut formulae_dependents FormulaeDependents) unlink_conflicts(formula FormulaeDependentsFormula) {
	if formula.keg_only || formula.linked {
		return
	}
	mut conflict_names := formula.conflicts.clone()
	for dependency_name in formula.recursive_dependencies {
		if dependency := formulae_dependents.formulae[dependency_name] {
			conflict_names << dependency.conflicts
		}
	}
	for conflict_name in formulae_dependents_unique(conflict_names) {
		if conflict := formulae_dependents.formulae[conflict_name] {
			if conflict.any_version_installed {
				formulae_dependents.operations << formulae_dependents_operation(.unlink, [
					'brew',
					'unlink',
					conflict.name,
				], '', true, false)
			}
		}
	}
}

pub fn (mut formulae_dependents FormulaeDependents) install_dependent(dependent FormulaeDependentsFormula,
	testable_dependents []FormulaeDependentsFormula, args FormulaeDependentsArgs,
	build_from_source bool) ! {
	full_name := formulae_dependents_full_name(dependent)
	if full_name in formulae_dependents.skip_candidates
		&& formulae_dependents.artifact_cache_valid[full_name] {
		formulae_dependents.tested_dependents_list << full_name
		formulae_dependents.operations << formulae_dependents_operation(.skipped, []string{}, '${full_name} has been tested at ${formulae_dependents.previous_github_sha}', true, false)
		return
	}
	if dependent.unsatisfied_requirements.len > 0 {
		formulae_dependents.operations << formulae_dependents_operation(.skipped, []string{}, dependent.unsatisfied_requirements.join('\n'), true, false)
		return
	}
	if dependent.deprecated || dependent.disabled {
		verb := if dependent.deprecated { 'deprecated' } else { 'disabled' }
		formulae_dependents.operations << formulae_dependents_operation(.skipped, []string{}, '${full_name} has been ${verb}!', true, false)
		return
	}

	formulae_dependents.operations << formulae_dependents_operation(.cleanup, []string{}, '', true, false)
	bottled_on_current_version := dependent.bottled_on_current_version
	dependent_was_previously_installed := dependent.latest_version_installed
	mut fetch_formulae := dependent.dependencies.filter(!it.optional && !it.satisfied).map(it.name)
	mut build_args := []string{}
	if !dependent_was_previously_installed {
		if build_from_source {
			build_args << '--build-from-source'
			formulae_dependents.operations << formulae_dependents_operation(.fetch, [
				'brew',
				'fetch',
				'--build-from-source',
				'--retry',
				full_name,
			], '', dependent.fetch_passed, false)
			if !dependent.fetch_passed {
				return
			}
		} else {
			fetch_formulae << full_name
		}
		if fetch_formulae.len > 0 {
			mut fetch_command := [
				'brew',
				'fetch',
				'--retry',
			]
			fetch_command << formulae_dependents_unique(fetch_formulae)
			formulae_dependents.operations << formulae_dependents_operation(.fetch, fetch_command, '', dependent.fetch_passed, false)
			if !dependent.fetch_passed {
				return
			}
		}
		formulae_dependents.unlink_conflicts(dependent)
		mut dependencies_command := ['brew', 'install']
		dependencies_command << build_args
		dependencies_command << ['--only-dependencies', full_name]
		formulae_dependents.operations << formulae_dependents_operation(.install, dependencies_command, '', true, !bottled_on_current_version)
		mut install_command := ['brew', 'install']
		install_command << build_args
		install_command << full_name
		formulae_dependents.operations << formulae_dependents_operation(.install, install_command, '', dependent.install_passed, !args.test_default_formula
			&& !bottled_on_current_version)
		if !dependent.install_passed {
			return
		}
	}
	if !dependent_was_previously_installed && !dependent.install_passed {
		return
	}
	if !dependent.keg_only && !dependent.linked {
		formulae_dependents.unlink_conflicts(dependent)
		formulae_dependents.operations << formulae_dependents_operation(.link, ['brew', 'link',
			full_name], '', true, false)
	}
	formulae_dependents.operations << formulae_dependents_operation(.install, ['brew', 'install',
		'--only-dependencies', full_name], '', true, false)
	formulae_dependents.operations << formulae_dependents_operation(.linkage, ['brew', 'linkage',
		'--test', full_name], '', dependent.linkage_passed, !args.test_default_formula && !bottled_on_current_version)
	if dependent.linkage_passed && !build_from_source {
		formulae_dependents.operations << formulae_dependents_operation(.linkage, [
			'brew',
			'linkage',
			'--cached',
			'--test',
			'--strict',
			full_name,
		], '', true, !args.test_default_formula)
	}
	mut test_passed := true
	if formulae_dependents_contains_formula(testable_dependents, dependent) {
		formulae_dependents.operations << formulae_dependents_operation(.install, [
			'brew',
			'install',
			'--only-dependencies',
			'--include-test',
			full_name,
		], '', true, false)
		formulae_dependents.operations << formulae_dependents_operation(.test, ['brew', 'test',
			'--retry', '--verbose', full_name], '', dependent.test_passed, !args.test_default_formula && !bottled_on_current_version)
		test_passed = dependent.test_passed
	}
	formulae_dependents.operations << formulae_dependents_operation(.uninstall, ['brew', 'uninstall',
		'--force', '--ignore-dependencies', full_name], '', true, false)
	all_tests_passed := (dependent_was_previously_installed || dependent.install_passed)
		&& dependent.linkage_passed && test_passed
	if all_tests_passed {
		formulae_dependents.tested_dependents_list << full_name
	}
	if formulae_dependents.github_actions && build_from_source
		&& !bottled_on_current_version && !dependent_was_previously_installed && all_tests_passed
		&& dependent.dependencies.all(it.bottled_or_built) {
		formulae_dependents.operations << formulae_dependents_operation(.annotation, []string{}, '${full_name} should be bottled: All tests passed.', true, false)
	}
}

pub fn (mut formulae_dependents FormulaeDependents) dependent_formulae(formula_name string,
	args FormulaeDependentsArgs) ! {
	formulae_dependents.operations << formulae_dependents_operation(.cleanup, []string{}, '', true, false)
	formulae_dependents.operations << formulae_dependents_operation(.test_header, []string{}, 'Running FormulaeDependents#dependent_formulae!(${formula_name})', true, false)
	formulae_dependents.testing_formulae_with_tested_dependents << formula_name
	formula := formulae_dependents_formula(formulae_dependents.formulae, formula_name)!
	selection := formulae_dependents.dependents_for_formula(formula, formula_name, args)
	if selection.source_dependents.len == 0 && selection.bottled_dependents.len == 0
		&& selection.testable_dependents.len == 0 {
		return
	}
	formulae_dependents.unlink_conflicts(formula)
	if !formula.keg_only {
		formulae_dependents.operations << formulae_dependents_operation(.link, ['brew', 'link',
			formula_name], '', true, false)
	}
	formulae_dependents.operations << formulae_dependents_operation(.install, ['brew', 'install',
		'--only-dependencies', formula_name], '', true, !formula.bottled)
	formulae_dependents.operations << formulae_dependents_operation(.postinstall, [
		'brew',
		'postinstall',
		formula_name,
	], '', true, !formula.bottled)
	source_dependents := formulae_dependents_prioritize_texlive(selection.source_dependents)
	bottled_dependents := formulae_dependents_prioritize_texlive(selection.bottled_dependents)
	for dependent in source_dependents {
		formulae_dependents.install_dependent(dependent, selection.testable_dependents, args, true)!
		if dependent.bottled {
			formulae_dependents.install_dependent(dependent, selection.testable_dependents, args, false)!
		}
	}
	for dependent in bottled_dependents {
		formulae_dependents.install_dependent(dependent, selection.testable_dependents, args, false)!
	}
	mut tested := formulae_dependents.tested_dependents.clone()
	for dependent in source_dependents {
		tested << formulae_dependents_full_name(dependent)
	}
	for dependent in bottled_dependents {
		tested << formulae_dependents_full_name(dependent)
	}
	formulae_dependents.tested_dependents = formulae_dependents_unique(tested)
}

pub fn (mut formulae_dependents FormulaeDependents) run(args FormulaeDependentsArgs) !FormulaeDependentsRun {
	if args.formulae_dependents_shard != '' && !args.only_formulae_dependents {
		return error('`--formulae-dependents-shard` requires `--only-formulae-dependents`.')
	}
	if !formulae_dependents.tap_core_cask && formulae_dependents.core_cask_installed {
		formulae_dependents.operations << formulae_dependents_operation(.untap, ['brew', 'untap',
			'--force', 'homebrew/cask'], '', true, false)
	}
	installable_bottles := formulae_dependents_without(formulae_dependents.tested_formulae, formulae_dependents.skipped_or_failed_formulae)
	unneeded_formulae := formulae_dependents_without(formulae_dependents.tested_formulae, formulae_dependents.testing_formulae)
	mut skipped_or_failed_formulae := formulae_dependents.skipped_or_failed_formulae.clone()
	skipped_or_failed_formulae << unneeded_formulae
	formulae_dependents.skipped_or_failed_formulae = formulae_dependents_unique(skipped_or_failed_formulae)
	formulae_dependents.operations << formulae_dependents_operation(.info_header, []string{}, 'Skipped or failed formulae:', true, false)
	for formula_name in formulae_dependents.skipped_or_failed_formulae {
		formulae_dependents.operations << formulae_dependents_operation(.output, []string{}, formula_name, true, false)
	}
	formulae_dependents.testing_formulae_with_tested_dependents = []string{}
	formulae_dependents.tested_dependents_list = []string{}
	formulae_dependents.dependent_testing_formulae = formulae_dependents_without(formulae_dependents_sorted(formulae_dependents.testing_formulae), formulae_dependents.skipped_or_failed_formulae)
	formulae_dependents.install_formulae_if_needed_from_bottles(installable_bottles, args)!
	formulae_dependents.operations << formulae_dependents_operation(.download_artifacts, []string{}, 'dependents{,_*}', true, args.dry_run)
	if args.formulae_dependents_shard != '' {
		mut pairs := []FormulaeDependentPair{}
		for formula_name in formulae_dependents.dependent_testing_formulae {
			formula := formulae_dependents_formula(formulae_dependents.formulae, formula_name)!
			pairs << formulae_dependents.dependent_pairs_for_formula(formula, formula_name, args)
		}
		mut unique_pairs := []FormulaeDependentPair{}
		mut names := []string{}
		for pair in pairs {
			name := formulae_dependents_full_name(pair.dependent)
			if name !in names {
				names << name
				unique_pairs << pair
			}
		}
		selected := dependents_for_shard(unique_pairs, args.formulae_dependents_shard)!
		formulae_dependents.formulae_dependents_filter = selected.map(formulae_dependents_full_name(it.dependent))
		formulae_dependents.formulae_dependents_filter_set = true
	}
	for formula_name in formulae_dependents.dependent_testing_formulae {
		formulae_dependents.dependent_formulae(formula_name, args)!
		formulae_dependents.operations << formulae_dependents_operation(.blank_line, []string{}, '', true, false)
	}
	if formulae_dependents.github_actions && 'bash' in formulae_dependents.dependent_testing_formulae {
		formulae_dependents.operations << formulae_dependents_operation(.uninstall, [
			'brew',
			'uninstall',
			'--formula',
			'--force',
			'bash',
		], '', true, false)
	}
	return FormulaeDependentsRun{
		dependent_testing_formulae: formulae_dependents.dependent_testing_formulae.clone()
		tested_dependents: formulae_dependents.tested_dependents.clone()
		skipped_or_failed_formulae: formulae_dependents.skipped_or_failed_formulae.clone()
		filter: formulae_dependents.formulae_dependents_filter.clone()
		operations: formulae_dependents.operations.clone()
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     class FormulaeDependents < TestFormulae
// 7:       DependentWithDependencies = T.type_alias { [Formula, T::Array[Dependency]] }
// 8:       private_constant :DependentWithDependencies
// 9:
// 10:       sig { params(testing_formulae: T::Array[String]).returns(T::Array[String]) }
// 11:       attr_writer :testing_formulae
// 12:
// 13:       sig { params(tested_formulae: T::Array[String]).returns(T::Array[String]) }
// 14:       attr_writer :tested_formulae
// 15:
// 16:       sig {
// 17:         params(
// 18:           tap:       T.nilable(Tap),
// 19:           git:       T.nilable(String),
// 20:           dry_run:   T::Boolean,
// 21:           fail_fast: T::Boolean,
// 22:           verbose:   T::Boolean,
// 23:         ).void
// 24:       }
// 25:       def initialize(tap:, git:, dry_run:, fail_fast:, verbose:)
// 26:         super
// 27:         @testing_formulae_with_tested_dependents = T.let([], T::Array[String])
// 28:         @tested_dependents_list = T.let(nil, T.nilable(Pathname))
// 29:         @dependent_testing_formulae = T.let([], T::Array[String])
// 30:         @tested_dependents = T.let([], T::Array[String])
// 31:         @formulae_dependents_filter = T.let(nil, T.nilable(T::Array[String]))
// 32:         @dependent_pairs_by_formula = T.let({}, T::Hash[String, T::Array[DependentWithDependencies]])
// 33:       end
// 34:
// 35:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 36:       def run!(args:)
// 37:         if args.formulae_dependents_shard.present? && !args.only_formulae_dependents?
// 38:           raise UsageError, "`--formulae-dependents-shard` requires `--only-formulae-dependents`."
// 39:         end
// 40:
// 41:         test "brew", "untap", "--force", "homebrew/cask" if !tap&.core_cask_tap? && CoreCaskTap.instance.installed?
// 42:
// 43:         installable_bottles = @tested_formulae - @skipped_or_failed_formulae
// 44:         unneeded_formulae = @tested_formulae - @testing_formulae
// 45:         @skipped_or_failed_formulae += unneeded_formulae
// 46:
// 47:         info_header "Skipped or failed formulae:"
// 48:         puts skipped_or_failed_formulae
// 49:
// 50:         @testing_formulae_with_tested_dependents = []
// 51:         @tested_dependents_list = Pathname("tested-dependents-#{Utils::Bottles.tag}.txt")
// 52:
// 53:         @dependent_testing_formulae = sorted_formulae - skipped_or_failed_formulae
// 54:
// 55:         install_formulae_if_needed_from_bottles!(installable_bottles, args:)
// 56:
// 57:         download_artifacts_from_previous_run!("dependents{,_#{previous_run_artifact_specifier}*}",
// 58:                                               dry_run: args.dry_run?)
// 59:         @skip_candidates = T.let(
// 60:           if (tested_dependents_cache = artifact_cache/@tested_dependents_list).exist?
// 61:             tested_dependents_cache.read.split("\n")
// 62:           else
// 63:             []
// 64:           end,
// 65:           T.nilable(T::Array[String]),
// 66:         )
// 67:
// 68:         if args.formulae_dependents_shard.present?
// 69:           dependent_pairs = @dependent_testing_formulae.flat_map do |formula_name|
// 70:             dependent_pairs_for_formula(Formulary.factory(formula_name), formula_name, args:)
// 71:           end
// 72:           dependent_pairs.uniq! { |dependent, _| dependent.full_name }
// 73:
// 74:           @formulae_dependents_filter = dependents_for_shard(dependent_pairs, args.formulae_dependents_shard.to_s)
// 75:                                         .map { |dependent, _| dependent.full_name }
// 76:         end
// 77:
// 78:         @dependent_testing_formulae.each do |formula_name|
// 79:           dependent_formulae!(formula_name, args:)
// 80:           puts
// 81:         end
// 82:
// 83:         return unless GitHub::Actions.env_set?
// 84:
// 85:         # Remove `bash` after it is tested, since leaving a broken `bash`
// 86:         # installation in the environment can cause issues with subsequent
// 87:         # GitHub Actions steps.
// 88:         return unless @dependent_testing_formulae.include?("bash")
// 89:
// 90:         test "brew", "uninstall", "--formula", "--force", "bash"
// 91:       end
// 92:
// 93:       sig {
// 94:         params(
// 95:           dependents: T::Array[DependentWithDependencies],
// 96:           shard:      String,
// 97:         ).returns(T::Array[DependentWithDependencies])
// 98:       }
// 99:       def dependents_for_shard(dependents, shard)
// 100:         unless shard.match?(%r{\A[1-9]\d*/[1-9]\d*\z})
// 101:           raise UsageError, "`--formulae-dependents-shard` must use the format <SHARD/TOTAL>."
// 102:         end
// 103:
// 104:         shard_parts = shard.split("/", 2)
// 105:         shard_index = shard_parts.fetch(0).to_i
// 106:         shard_count = shard_parts.fetch(1).to_i
// 107:         if shard_index > shard_count
// 108:           raise UsageError, "`--formulae-dependents-shard` must not be greater than the total shard count."
// 109:         end
// 110:
// 111:         return dependents if shard_count == 1
// 112:
// 113:         dependents_by_name = dependents.to_h { |dependent, deps| [dependent.full_name, [dependent, deps]] }
// 114:         edges = dependents.to_h { |dependent, _| [dependent.full_name, T.let([], T::Array[String])] }
// 115:
// 116:         dependents.each do |dependent, deps|
// 117:           deps.each do |dep|
// 118:             dep_name = dep.to_formula.full_name
// 119:             next unless edges.key?(dep_name)
// 120:
// 121:             edges.fetch(dependent.full_name) << dep_name
// 122:             edges.fetch(dep_name) << dependent.full_name
// 123:           end
// 124:         end
// 125:
// 126:         seen = T.let(Set.new, T::Set[String])
// 127:         groups = T.let([], T::Array[T::Array[DependentWithDependencies]])
// 128:         max_group_size = (dependents.size + shard_count - 1) / shard_count
// 129:
// 130:         dependents.map(&:first).each do |dependent|
// 131:           next if seen.include?(dependent.full_name)
// 132:
// 133:           group = T.let([], T::Array[DependentWithDependencies])
// 134:           queue = T.let([dependent.full_name], T::Array[String])
// 135:
// 136:           until queue.empty?
// 137:             name = queue.fetch(0)
// 138:             queue.shift
// 139:             next if seen.include?(name)
// 140:
// 141:             seen << name
// 142:             group << dependents_by_name.fetch(name)
// 143:             break if group.size >= max_group_size
// 144:
// 145:             queue.concat(edges.fetch(name).reject { |edge| seen.include?(edge) })
// 146:           end
// 147:
// 148:           groups << group
// 149:         end
// 150:
// 151:         shards = Array.new(shard_count) { T.let([], T::Array[DependentWithDependencies]) }
// 152:         groups.sort_by { |group| [-group.count, group.map { |dependent, _| dependent.full_name }.min.to_s] }
// 153:               .each do |group|
// 154:           group_shard_index = 0
// 155:           shards.each_with_index do |current_shard, index|
// 156:             group_shard_index = index if current_shard.count < shards.fetch(group_shard_index).count
// 157:           end
// 158:           shards.fetch(group_shard_index).concat(group)
// 159:         end
// 160:
// 161:         shards.fetch(shard_index - 1).sort_by { |dependent, _| dependent.full_name }
// 162:       end
// 163:
// 164:       private
// 165:
// 166:       sig { params(installable_bottles: T::Array[String], args: Homebrew::Cmd::TestBotCmd::Args).void }
// 167:       def install_formulae_if_needed_from_bottles!(installable_bottles, args:)
// 168:         installable_bottles.each do |formula_name|
// 169:           formula = Formulary.factory(formula_name)
// 170:           next if formula.latest_version_installed?
// 171:
// 172:           install_formula_from_bottle!(formula_name, testing_formulae_dependents: true, dry_run: args.dry_run?)
// 173:         end
// 174:       end
// 175:
// 176:       sig { params(formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args).void }
// 177:       def dependent_formulae!(formula_name, args:)
// 178:         cleanup_during!(@dependent_testing_formulae, args:)
// 179:
// 180:         test_header(:FormulaeDependents, method: "dependent_formulae!(#{formula_name})")
// 181:         @testing_formulae_with_tested_dependents << formula_name
// 182:
// 183:         formula = Formulary.factory(formula_name)
// 184:
// 185:         source_dependents, bottled_dependents, testable_dependents =
// 186:           dependents_for_formula(formula, formula_name, args:)
// 187:
// 188:         return if source_dependents.blank? && bottled_dependents.blank? && testable_dependents.blank?
// 189:
// 190:         # If we installed this from a bottle, then the formula isn't linked.
// 191:         # If the formula isn't linked, `brew install --only-dependences` does
// 192:         # nothing with the message:
// 193:         #     Warning: formula x.y.z is already installed, it's just not linked.
// 194:         #     To link this version, run:
// 195:         #       brew link formula
// 196:         unlink_conflicts formula
// 197:         test "brew", "link", formula_name unless formula.keg_only?
// 198:
// 199:         # Install formula dependencies. These may not be installed.
// 200:         test "brew", "install", "--only-dependencies",
// 201:              named_args:      formula_name,
// 202:              ignore_failures: !bottled?(formula, no_older_versions: true),
// 203:              env:             { "HOMEBREW_DEVELOPER" => nil }
// 204:         return unless steps.fetch(-1).passed?
// 205:
// 206:         # Restore etc/var files that may have been nuked in the build stage.
// 207:         test "brew", "postinstall",
// 208:              named_args:      formula_name,
// 209:              ignore_failures: !bottled?(formula, no_older_versions: true)
// 210:         return unless steps.fetch(-1).passed?
// 211:
// 212:         # Test texlive first to avoid GitHub-hosted runners running out of storage.
// 213:         # TODO: Try generalising this by sorting dependents according to install size,
// 214:         #       where ideally install size should include recursive dependencies.
// 215:         [source_dependents, bottled_dependents].each do |dependent_array|
// 216:           texlive = dependent_array.find { |dependent| dependent.name == "texlive" }
// 217:           next unless texlive.present?
// 218:
// 219:           dependent_array.delete(texlive)
// 220:           dependent_array.unshift(texlive)
// 221:         end
// 222:
// 223:         source_dependents.each do |dependent|
// 224:           install_dependent(dependent, testable_dependents, build_from_source: true, args:)
// 225:           install_dependent(dependent, testable_dependents, args:) if bottled?(dependent)
// 226:         end
// 227:
// 228:         bottled_dependents.each do |dependent|
// 229:           install_dependent(dependent, testable_dependents, args:)
// 230:         end
// 231:
// 232:         @tested_dependents |= (source_dependents + bottled_dependents).map(&:full_name)
// 233:       end
// 234:
// 235:       sig {
// 236:         params(formula: Formula, formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args)
// 237:           .returns([T::Array[Formula], T::Array[Formula], T::Array[Formula]])
// 238:       }
// 239:       def dependents_for_formula(formula, formula_name, args:)
// 240:         info_header "Determining dependents..."
// 241:
// 242:         dependents = dependent_pairs_for_formula(formula, formula_name, args:)
// 243:         if (filter = @formulae_dependents_filter)
// 244:           dependents = dependents.select do |dependent, _|
// 245:             filter.include?(dependent.name) || filter.include?(dependent.full_name)
// 246:           end
// 247:         end
// 248:         dependents.reject! { |dependent, _| @tested_dependents.include?(dependent.full_name) }
// 249:
// 250:         # Split into dependents that we could potentially be building from source and those
// 251:         # we should not. The criteria is that a dependent must have bottled dependencies, and
// 252:         # either the `--build-dependents-from-source` flag was passed or a dependent has no
// 253:         # bottle on the current OS.
// 254:         source_dependents, dependents = dependents.partition do |dependent, deps|
// 255:           next false unless build_dependent_from_source?(dependent)
// 256:
// 257:           all_deps_bottled_or_built = deps.all? do |d|
// 258:             bottled_or_built?(d.to_formula, @dependent_testing_formulae)
// 259:           end
// 260:           args.build_dependents_from_source? && all_deps_bottled_or_built
// 261:         end
// 262:
// 263:         # From the non-source list, get rid of any dependents we are only a build dependency to
// 264:         dependents.select! do |_, deps|
// 265:           deps.reject { |d| d.build? && !d.test? }
// 266:               .map(&:to_formula)
// 267:               .include?(formula)
// 268:         end
// 269:
// 270:         dependents = dependents.transpose.first.to_a
// 271:         source_dependents = source_dependents.transpose.first.to_a
// 272:
// 273:         testable_dependents = source_dependents.select(&:test_defined?)
// 274:         bottled_dependents = dependents.select { |dep| bottled?(dep) }
// 275:         testable_dependents += bottled_dependents.select(&:test_defined?)
// 276:
// 277:         info_header "Source dependents:"
// 278:         puts source_dependents
// 279:
// 280:         info_header "Bottled dependents:"
// 281:         puts bottled_dependents
// 282:
// 283:         info_header "Testable dependents:"
// 284:         puts testable_dependents
// 285:
// 286:         [source_dependents, bottled_dependents, testable_dependents]
// 287:       end
// 288:
// 289:       sig {
// 290:         params(formula: Formula, formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args)
// 291:           .returns(T::Array[DependentWithDependencies])
// 292:       }
// 293:       def dependent_pairs_for_formula(formula, formula_name, args:)
// 294:         @dependent_pairs_by_formula[formula_name] ||= begin
// 295:           # Always skip recursive dependents on Intel. It's really slow.
// 296:           # Also skip recursive dependents on Linux unless it's a Linux-only formula.
// 297:           #
// 298:           skip_recursive_dependents = skip_recursive_dependents?(formula, args:)
// 299:
// 300:           uses_args = %w[--formula]
// 301:           uses_include_test_args = [*uses_args, "--include-test"]
// 302:           uses_include_test_args << "--recursive" unless skip_recursive_dependents
// 303:           uses_env = require_current_tap_trust_env.merge("HOMEBREW_STDERR" => "1")
// 304:           dependents = with_env(uses_env) do
// 305:             Utils.safe_popen_read("brew", "uses", *uses_include_test_args, formula_name)
// 306:                  .split("\n")
// 307:           end
// 308:
// 309:           # TODO: Consider handling the following case better.
// 310:           #       `foo` has a build dependency on `bar`, and `bar` has a runtime dependency on
// 311:           #       `baz`. When testing `baz` with `--build-dependents-from-source`, `foo` is
// 312:           #       not tested, but maybe should be.
// 313:           dependents += with_env(uses_env) do
// 314:             Utils.safe_popen_read("brew", "uses", *uses_args, "--include-build", formula_name)
// 315:                  .split("\n")
// 316:           end
// 317:           dependents.uniq!
// 318:           dependents.sort!
// 319:
// 320:           dependents -= @tested_formulae
// 321:           dependents = dependents.map { |d| Formulary.factory(d) }
// 322:
// 323:           dependents = dependents.zip(dependents.map do |f|
// 324:             if skip_recursive_dependents
// 325:               f.deps.reject(&:implicit?)
// 326:             else
// 327:               Dependency.expand(f, cache_key: "test-bot-dependents") do |_, dependency|
// 328:                 next Dependable::SKIP if dependency.implicit?
// 329:                 next Dependable::KEEP_BUT_PRUNE_RECURSIVE_DEPS if dependency.build? || dependency.test?
// 330:               end
// 331:             end.reject(&:optional?)
// 332:           end)
// 333:
// 334:           # Defer formulae which could be tested later
// 335:           # i.e. formulae that also depend on something else yet to be built in this test run.
// 336:           unless args.only_formulae_dependents?
// 337:             dependents.reject! do |_, deps|
// 338:               still_to_test = @dependent_testing_formulae - @testing_formulae_with_tested_dependents
// 339:               deps.map { |d| d.to_formula.full_name }.intersect?(still_to_test)
// 340:             end
// 341:           end
// 342:
// 343:           dependents
// 344:         end
// 345:       end
// 346:
// 347:       sig {
// 348:         params(
// 349:           dependent:           Formula,
// 350:           testable_dependents: T::Array[Formula],
// 351:           args:                Homebrew::Cmd::TestBotCmd::Args,
// 352:           build_from_source:   T::Boolean,
// 353:         ).void
// 354:       }
// 355:       def install_dependent(dependent, testable_dependents, args:, build_from_source: false)
// 356:         if @skip_candidates&.include?(dependent.full_name) &&
// 357:            artifact_cache_valid?(dependent, formulae_dependents: true)
// 358:           @tested_dependents_list&.write(dependent.full_name, mode: "a")
// 359:           @tested_dependents_list&.write("\n", mode: "a")
// 360:           skipped dependent.name, "#{dependent.full_name} has been tested at #{previous_github_sha}"
// 361:           return
// 362:         end
// 363:
// 364:         if (messages = unsatisfied_requirements_messages(dependent))
// 365:           skipped dependent.name, messages
// 366:           return
// 367:         end
// 368:
// 369:         if dependent.deprecated? || dependent.disabled?
// 370:           verb = dependent.deprecated? ? :deprecated : :disabled
// 371:           skipped dependent.name, "#{dependent.full_name} has been #{verb}!"
// 372:           return
// 373:         end
// 374:
// 375:         cleanup_during!(@dependent_testing_formulae, args:)
// 376:
// 377:         required_dependent_deps = dependent.deps.reject(&:optional?)
// 378:         bottled_on_current_version = bottled?(dependent, no_older_versions: true)
// 379:         dependent_was_previously_installed = dependent.latest_version_installed?
// 380:
// 381:         dependent_dependencies = Dependency.expand(
// 382:           dependent,
// 383:           cache_key: "test-bot-dependent-dependencies-#{dependent.full_name}",
// 384:         ) do |dep_dependent, dependency|
// 385:           next if !dependency.build? && !dependency.test? && !dependency.optional?
// 386:           next if dependency.test? &&
// 387:                   dep_dependent == dependent &&
// 388:                   !dependency.optional? &&
// 389:                   testable_dependents.include?(dependent)
// 390:
// 391:           next Dependable::PRUNE
// 392:         end
// 393:
// 394:         unless dependent_was_previously_installed
// 395:           build_args = []
// 396:
// 397:           fetch_formulae = dependent_dependencies.reject(&:satisfied?).map(&:name)
// 398:
// 399:           if build_from_source
// 400:             required_dependent_reqs = dependent.requirements.reject(&:optional?)
// 401:             install_curl_if_needed(dependent)
// 402:             install_mercurial_if_needed(required_dependent_deps, required_dependent_reqs)
// 403:             install_subversion_if_needed(required_dependent_deps, required_dependent_reqs)
// 404:
// 405:             build_args << "--build-from-source"
// 406:
// 407:             test "brew", "fetch", "--build-from-source", "--retry", dependent.full_name
// 408:             return if steps.fetch(-1).failed?
// 409:           else
// 410:             fetch_formulae << dependent.full_name
// 411:           end
// 412:
// 413:           if fetch_formulae.present?
// 414:             test "brew", "fetch", "--retry", *fetch_formulae
// 415:             return if steps.fetch(-1).failed?
// 416:           end
// 417:
// 418:           unlink_conflicts dependent
// 419:
// 420:           test "brew", "install", *build_args, "--only-dependencies",
// 421:                named_args:      dependent.full_name,
// 422:                ignore_failures: !bottled_on_current_version,
// 423:                env:             { "HOMEBREW_DEVELOPER" => nil }
// 424:
// 425:           env = {}
// 426:           env["HOMEBREW_GIT_PATH"] = nil if build_from_source && required_dependent_deps.any? do |d|
// 427:             d.name == "git" && (!d.test? || d.build?)
// 428:           end
// 429:           test "brew", "install", *build_args,
// 430:                named_args:      dependent.full_name,
// 431:                env:             env.merge({ "HOMEBREW_DEVELOPER" => nil }),
// 432:                ignore_failures: !args.test_default_formula? && !bottled_on_current_version
// 433:           install_step = steps.fetch(-1)
// 434:
// 435:           return unless install_step.passed?
// 436:         end
// 437:         return unless dependent.latest_version_installed?
// 438:
// 439:         if !dependent.keg_only? && !dependent.linked_keg.exist?
// 440:           unlink_conflicts dependent
// 441:           test "brew", "link", dependent.full_name
// 442:         end
// 443:         test "brew", "install", "--only-dependencies", dependent.full_name
// 444:         test "brew", "linkage", "--test",
// 445:              named_args:      dependent.full_name,
// 446:              ignore_failures: !args.test_default_formula? && !bottled_on_current_version
// 447:         linkage_step = steps.fetch(-1)
// 448:
// 449:         if linkage_step.passed? && !build_from_source
// 450:           # Check for opportunistic linkage. Ignore failures because
// 451:           # they can be unavoidable but we still want to know about them.
// 452:           test "brew", "linkage", "--cached", "--test", "--strict",
// 453:                named_args:      dependent.full_name,
// 454:                ignore_failures: !args.test_default_formula?
// 455:         end
// 456:
// 457:         if testable_dependents.include? dependent
// 458:           test "brew", "install", "--only-dependencies", "--include-test", dependent.full_name
// 459:
// 460:           dependent_dependencies.each do |dependency|
// 461:             dependency_f = dependency.to_formula
// 462:             next if dependency_f.keg_only?
// 463:             next if dependency_f.linked?
// 464:
// 465:             unlink_conflicts dependency_f
// 466:             test "brew", "link", dependency_f.full_name
// 467:           end
// 468:
// 469:           env = {}
// 470:           env["HOMEBREW_GIT_PATH"] = nil if required_dependent_deps.any? do |d|
// 471:             d.name == "git" && (!d.build? || d.test?)
// 472:           end
// 473:           test "brew", "test", "--retry", "--verbose",
// 474:                named_args:      dependent.full_name,
// 475:                env:,
// 476:                ignore_failures: !args.test_default_formula? && !bottled_on_current_version
// 477:           test_step = steps.fetch(-1)
// 478:         end
// 479:
// 480:         test "brew", "uninstall", "--force", "--ignore-dependencies", dependent.full_name
// 481:
// 482:         all_tests_passed = (dependent_was_previously_installed || install_step.passed?) &&
// 483:                            linkage_step.passed? &&
// 484:                            (testable_dependents.exclude?(dependent) || test_step&.passed?)
// 485:
// 486:         if all_tests_passed
// 487:           @tested_dependents_list&.write(dependent.full_name, mode: "a")
// 488:           @tested_dependents_list&.write("\n", mode: "a")
// 489:         end
// 490:
// 491:         return unless GitHub::Actions.env_set?
// 492:
// 493:         if build_from_source &&
// 494:            !bottled_on_current_version &&
// 495:            !dependent_was_previously_installed &&
// 496:            all_tests_passed &&
// 497:            dependent.deps.all? { |d| bottled?(d.to_formula, no_older_versions: true) }
// 498:           puts GitHub::Actions::Annotation.new(
// 499:             :notice,
// 500:             "All tests passed.",
// 501:             file:  dependent.path.to_s.delete_prefix("#{repository}/"),
// 502:             title: "#{dependent} should be bottled for #{Homebrew::TestBot.runner_os_title}!",
// 503:           )
// 504:         end
// 505:       end
// 506:
// 507:       sig { params(_formula: Formula, args: Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 508:       def skip_recursive_dependents?(_formula, args:)
// 509:         args.skip_recursive_dependents? != false
// 510:       end
// 511:
// 512:       sig { params(_dependent: Formula).returns(T::Boolean) }
// 513:       def build_dependent_from_source?(_dependent)
// 514:         true
// 515:       end
// 516:
// 517:       sig { params(formula: Formula).void }
// 518:       def unlink_conflicts(formula)
// 519:         return if formula.keg_only?
// 520:         return if formula.linked_keg.exist?
// 521:
// 522:         conflicts = formula.conflicts.map { |c| Formulary.factory(c.name) }.select(&:any_version_installed?)
// 523:         formula_recursive_dependencies = formula.recursive_dependencies
// 524:         formula_recursive_dependencies.each do |dependency|
// 525:           conflicts += dependency.to_formula.conflicts.map do |c|
// 526:             Formulary.factory(c.name)
// 527:           end.select(&:any_version_installed?)
// 528:         end
// 529:         conflicts.each do |conflict|
// 530:           test "brew", "unlink", conflict.name
// 531:         end
// 532:       end
// 533:     end
// 534:   end
// 535: end
