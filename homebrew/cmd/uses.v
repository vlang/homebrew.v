module cmd

import homebrew.utils

pub struct UsesCommandOptions {
pub:
	recursive            bool
	installed            bool
	missing              bool
	eval_all             bool
	include_implicit     bool
	include_build        bool
	include_test         bool
	include_optional     bool
	skip_recommended     bool
	formula              bool
	cask                 bool
	tap_trust_configured bool
	stdout_tty           bool
	console_width        int = 80
}

pub struct UsesFormula {
pub:
	name                                 string
	full_name                            string
	runtime_installed_formula_dependents []DepsDependent
}

pub struct UsesCommandInput {
pub:
	options                   UsesCommandOptions
	named                     []string
	used_formulae             []UsesFormula
	formula_unavailable_error string
	installed_formulae        []DepsDependent
	installed_casks           []DepsDependent
	all_formulae              []DepsDependent
	all_casks                 []DepsDependent
	caskroom_casks            []DepsDependent
	registry                  map[string]DepsDependent
}

pub struct UsesCommandResult {
pub mut:
	stdout                string
	stderr                string
	failed                bool
	error                 string
	factory_cache_enabled bool
	formula_all_called    bool
	formula_all_eval_all  bool
}

fn uses_includes_ignores(options UsesCommandOptions) ([]string, []string) {
	mut includes := ['required', 'recommended']
	if options.include_implicit {
		includes << 'implicit'
	}
	if options.include_build {
		includes << 'build'
	}
	if options.include_test {
		includes << 'test'
	}
	if options.include_optional {
		includes << 'optional'
	}
	mut ignores := []string{}
	if options.skip_recommended {
		ignores << 'recommended'
	}
	if options.missing {
		ignores << 'satisfied'
	}
	return includes, ignores
}

fn uses_item_predicate(item DepsItem, predicate string) bool {
	return match predicate.trim_right('?') {
		'build' { item.build }
		'test' { item.test }
		'optional' { item.optional }
		'recommended' { item.recommended }
		'implicit' { item.implicit }
		'satisfied' { item.satisfied }
		'required' { !item.build && !item.test && !item.optional && !item.recommended }
		else { false }
	}
}

fn uses_item_included(item DepsItem, includes []string, ignores []string, at_root bool) bool {
	if ignores.any(uses_item_predicate(item, it)) {
		return false
	}
	for include in includes {
		if include.trim_right('?') == 'test' && !at_root {
			continue
		}
		if uses_item_predicate(item, include) {
			return true
		}
	}
	return false
}

fn uses_recursive_dependencies(dependent DepsDependent, includes []string, ignores []string,
	registry map[string]DepsDependent, root_name string, mut visiting map[string]bool) []DepsItem {
	if dependent.name in visiting {
		return []
	}
	visiting[dependent.name] = true
	mut dependencies := []DepsItem{}
	for dependency in dependent.deps {
		if dependency.name == dependent.name
			|| !uses_item_included(dependency, includes, ignores, dependent.name == root_name) {
			continue
		}
		if dependency.kind == .dependency && dependency.name !in visiting {
			if child := registry[dependency.name] {
				dependencies << uses_recursive_dependencies(child, includes, ignores, registry, root_name, mut visiting)
			} else if child := registry[dependency.full_name] {
				dependencies << uses_recursive_dependencies(child, includes, ignores, registry, root_name, mut visiting)
			}
		}
		dependencies << dependency
	}
	visiting.delete(dependent.name)
	return dependencies
}

fn uses_dependencies_for(dependent DepsDependent, recursive bool, includes []string,
	ignores []string, registry map[string]DepsDependent) []DepsItem {
	if !recursive {
		return dependent.deps.filter(uses_item_included(it, includes, ignores, true))
	}
	mut visiting := map[string]bool{}
	return uses_recursive_dependencies(dependent, includes, ignores, registry, dependent.name, mut visiting)
}

fn uses_dependency_matches(dependency DepsItem, formula UsesFormula) bool {
	if dependency.kind == .dependency && dependency.name.contains('/') {
		return dependency.full_name == formula.full_name
	}
	return dependency.name == formula.name
}

pub fn select_used_dependents(dependents []DepsDependent, used_formulae []UsesFormula,
	recursive bool, includes []string, ignores []string,
	registry map[string]DepsDependent) []DepsDependent {
	mut selected := []DepsDependent{}
	for dependent in dependents {
		dependencies := uses_dependencies_for(dependent, recursive, includes, ignores, registry)
		mut uses_every_formula := true
		for formula in used_formulae {
			if !dependencies.any(uses_dependency_matches(it, formula)) {
				uses_every_formula = false
				break
			}
		}
		if uses_every_formula {
			selected << dependent
		}
	}
	return selected
}

fn uses_unique_dependents(dependents []DepsDependent) []DepsDependent {
	mut unique := []DepsDependent{}
	mut seen := map[string]bool{}
	for dependent in dependents {
		key := '${int(dependent.kind)}\x00${dependent.full_name}'
		if key in seen {
			continue
		}
		seen[key] = true
		unique << dependent
	}
	return unique
}

fn uses_runtime_formula_dependents(used_formulae []UsesFormula) []DepsDependent {
	if used_formulae.len == 0 {
		return []
	}
	mut intersection := uses_unique_dependents(used_formulae[0].runtime_installed_formula_dependents)
	for formula in used_formulae[1..] {
		keys := formula.runtime_installed_formula_dependents.map('${int(it.kind)}\x00${it.full_name}')
		intersection = intersection.filter('${int(it.kind)}\x00${it.full_name}' in keys)
	}
	return intersection.filter(it.any_version_installed)
}

pub fn intersection_of_dependents(input UsesCommandInput, use_runtime_dependents bool,
	used_formulae []UsesFormula) ![]DepsDependent {
	show_formulae_and_casks := !input.options.formula && !input.options.cask
	includes, mut ignores := uses_includes_ignores(input.options)
	mut dependents := []DepsDependent{}
	if use_runtime_dependents {
		if show_formulae_and_casks || input.options.formula {
			dependents << uses_runtime_formula_dependents(used_formulae)
		}
		if show_formulae_and_casks || input.options.cask {
			dependents << select_used_dependents(input.caskroom_casks, used_formulae, input.options.recursive, includes, ignores, input.registry)
		}
		return uses_unique_dependents(dependents)
	}

	eval_all := input.options.eval_all || input.options.tap_trust_configured
	if !input.options.installed && !eval_all {
		return error('`brew uses` needs `--installed`, `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!')
	}
	if show_formulae_and_casks || input.options.formula {
		dependents << if input.options.installed {
			input.installed_formulae
		} else {
			input.all_formulae
		}
	}
	if show_formulae_and_casks || input.options.cask {
		dependents << if input.options.installed { input.installed_casks } else { input.all_casks }
	}
	if input.options.missing {
		dependents = dependents.filter(!it.any_version_installed)
		ignores = ignores.filter(it.trim_right('?') != 'satisfied')
	}
	return select_used_dependents(dependents, used_formulae, input.options.recursive, includes, ignores, input.registry)
}

pub fn run_uses_command(input UsesCommandInput) UsesCommandResult {
	mut result := UsesCommandResult{
		factory_cache_enabled: true
	}
	mut used_formulae := input.used_formulae.clone()
	used_formulae_missing := input.formula_unavailable_error != ''
	if used_formulae_missing {
		result.stderr = 'Warning: ${input.formula_unavailable_error}\n'
		used_formulae = input.named.map(UsesFormula{
			name: it
			full_name: it
		})
	}
	use_runtime_dependents := input.options.installed && !used_formulae_missing
		&& !input.options.include_implicit && !input.options.include_build
		&& !input.options.include_test && !input.options.include_optional
		&& !input.options.skip_recommended
	result.formula_all_called = !use_runtime_dependents && !input.options.installed
	result.formula_all_eval_all = input.options.eval_all || input.options.tap_trust_configured
	uses := intersection_of_dependents(input, use_runtime_dependents, used_formulae) or {
		result.failed = true
		result.error = err.msg()
		result.stderr += 'Error: ${err.msg()}\n'
		return result
	}
	if uses.len == 0 {
		return result
	}
	mut names := uses.map(it.full_name)
	names.sort()
	result.stdout = utils.formatter_columns(names, input.options.console_width, input.options.stdout_tty, 2, 0)
	if used_formulae_missing {
		result.failed = true
		result.error = 'Missing formulae should not have dependents!'
		result.stderr += 'Error: ${result.error}\n'
	}
	return result
}

// Translated from Homebrew/brew `cmd/uses.rb`.
