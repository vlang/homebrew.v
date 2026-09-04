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

// Ruby method `build_dependent_from_source?(_dependent)` at line 513.
pub fn formulae_dependents_build_dependent_from_source(_dependent FormulaeDependentsFormula) bool {
	return true
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
