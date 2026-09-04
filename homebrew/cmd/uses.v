module cmd

import ruby
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

pub fn uses_formula_value(formula UsesFormula) ruby.Value {
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.full_name
		attributes: {
			'name':      formula.name
			'full_name': formula.full_name
		}
		map_data: {
			'runtime_installed_formula_dependents': ruby.array_value(formula.runtime_installed_formula_dependents.map(deps_dependent_value(it)))
		}
	}
}

fn uses_formula_from_value(value ruby.Value) UsesFormula {
	runtime_values := (value.map_data['runtime_installed_formula_dependents'] or {
		ruby.array_value([])
	}).as_array() or { []ruby.Value{} }
	return UsesFormula{
		name: value.attributes['name'] or { value.repr.all_after_last('/') }
		full_name: value.attributes['full_name'] or { value.repr }
		runtime_installed_formula_dependents: runtime_values.map(deps_dependent_from_value(it))
	}
}

fn uses_option_bool(value ruby.Value, name string) bool {
	return if option := value.map_data[name] { option.as_bool() or { false } } else { false }
}

fn uses_options_from_value(value ruby.Value) UsesCommandOptions {
	width := if option := value.map_data['console_width'] {
		int(option.as_int() or { 80 })
	} else {
		80
	}
	return UsesCommandOptions{
		recursive: uses_option_bool(value, 'recursive')
		installed: uses_option_bool(value, 'installed')
		missing: uses_option_bool(value, 'missing')
		eval_all: uses_option_bool(value, 'eval_all')
		include_implicit: uses_option_bool(value, 'include_implicit')
		include_build: uses_option_bool(value, 'include_build')
		include_test: uses_option_bool(value, 'include_test')
		include_optional: uses_option_bool(value, 'include_optional')
		skip_recommended: uses_option_bool(value, 'skip_recommended')
		formula: uses_option_bool(value, 'formula')
		cask: uses_option_bool(value, 'cask')
		tap_trust_configured: uses_option_bool(value, 'tap_trust_configured')
		stdout_tty: uses_option_bool(value, 'stdout_tty')
		console_width: width
	}
}

pub fn uses_options_value(options UsesCommandOptions) ruby.Value {
	return ruby.map_value({
		'recursive':            ruby.bool_value(options.recursive)
		'installed':            ruby.bool_value(options.installed)
		'missing':              ruby.bool_value(options.missing)
		'eval_all':             ruby.bool_value(options.eval_all)
		'include_implicit':     ruby.bool_value(options.include_implicit)
		'include_build':        ruby.bool_value(options.include_build)
		'include_test':         ruby.bool_value(options.include_test)
		'include_optional':     ruby.bool_value(options.include_optional)
		'skip_recommended':     ruby.bool_value(options.skip_recommended)
		'formula':              ruby.bool_value(options.formula)
		'cask':                 ruby.bool_value(options.cask)
		'tap_trust_configured': ruby.bool_value(options.tap_trust_configured)
		'stdout_tty':           ruby.bool_value(options.stdout_tty)
		'console_width':        ruby.int_value(options.console_width)
	})
}

fn uses_values(value ruby.Value, name string) []ruby.Value {
	return (value.map_data[name] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
}

pub fn uses_command_input_value(input UsesCommandInput) ruby.Value {
	mut registry := map[string]ruby.Value{}
	for name, dependent in input.registry {
		registry[name] = deps_dependent_value(dependent)
	}
	return ruby.Value{
		type_name: 'Homebrew::Cmd::Uses'
		map_data: {
			'options':            uses_options_value(input.options)
			'named':              ruby.string_array_value(input.named)
			'used_formulae':      ruby.array_value(input.used_formulae.map(uses_formula_value(it)))
			'installed_formulae': ruby.array_value(input.installed_formulae.map(deps_dependent_value(it)))
			'installed_casks':    ruby.array_value(input.installed_casks.map(deps_dependent_value(it)))
			'all_formulae':       ruby.array_value(input.all_formulae.map(deps_dependent_value(it)))
			'all_casks':          ruby.array_value(input.all_casks.map(deps_dependent_value(it)))
			'caskroom_casks':     ruby.array_value(input.caskroom_casks.map(deps_dependent_value(it)))
			'registry':           ruby.map_value(registry)
		}
		attributes: {
			'formula_unavailable_error': input.formula_unavailable_error
		}
	}
}

fn uses_command_input_from_value(value ruby.Value) UsesCommandInput {
	options_value := value.map_data['options'] or { ruby.map_value({}) }
	registry_value := (value.map_data['registry'] or { ruby.map_value({}) }).as_map() or {
		map[string]ruby.Value{}
	}
	mut registry := map[string]DepsDependent{}
	for name, dependent in registry_value {
		registry[name] = deps_dependent_from_value(dependent)
	}
	return UsesCommandInput{
		options: uses_options_from_value(options_value)
		named: (value.map_data['named'] or { ruby.string_array_value([]) }).as_string_array() or {
			[]string{}
		}
		used_formulae: uses_values(value, 'used_formulae').map(uses_formula_from_value(it))
		formula_unavailable_error: value.attributes['formula_unavailable_error'] or { '' }
		installed_formulae: uses_values(value, 'installed_formulae').map(deps_dependent_from_value(it))
		installed_casks: uses_values(value, 'installed_casks').map(deps_dependent_from_value(it))
		all_formulae: uses_values(value, 'all_formulae').map(deps_dependent_from_value(it))
		all_casks: uses_values(value, 'all_casks').map(deps_dependent_from_value(it))
		caskroom_casks: uses_values(value, 'caskroom_casks').map(deps_dependent_from_value(it))
		registry: registry
	}
}

fn uses_result_value(result UsesCommandResult) ruby.Value {
	return ruby.Value{
		type_name: if result.error == '' { 'UsesCommandResult' } else { 'UsageError' }
		repr: if result.error == '' { result.stdout } else { result.error }
		attributes: {
			'stdout':                result.stdout
			'stderr':                result.stderr
			'failed':                result.failed.str()
			'error':                 result.error
			'factory_cache_enabled': result.factory_cache_enabled.str()
			'formula_all_called':    result.formula_all_called.str()
			'formula_all_eval_all':  result.formula_all_eval_all.str()
		}
	}
}

// Translated from Homebrew/brew `cmd/uses.rb`.
