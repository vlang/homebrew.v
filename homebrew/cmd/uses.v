module cmd

import brew_runtime
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

pub fn uses_formula_value(formula UsesFormula) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Formula'
		repr: formula.full_name
		attributes: {
			'name':      formula.name
			'full_name': formula.full_name
		}
		map_data: {
			'runtime_installed_formula_dependents': brew_runtime.array_value(formula.runtime_installed_formula_dependents.map(deps_dependent_value(it)))
		}
	}
}

fn uses_formula_from_value(value brew_runtime.Value) UsesFormula {
	runtime_values := (value.map_data['runtime_installed_formula_dependents'] or {
		brew_runtime.array_value([])
	}).as_array() or { []brew_runtime.Value{} }
	return UsesFormula{
		name: value.attributes['name'] or { value.repr.all_after_last('/') }
		full_name: value.attributes['full_name'] or { value.repr }
		runtime_installed_formula_dependents: runtime_values.map(deps_dependent_from_value(it))
	}
}

fn uses_option_bool(value brew_runtime.Value, name string) bool {
	return if option := value.map_data[name] { option.as_bool() or { false } } else { false }
}

fn uses_options_from_value(value brew_runtime.Value) UsesCommandOptions {
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

pub fn uses_options_value(options UsesCommandOptions) brew_runtime.Value {
	return brew_runtime.map_value({
		'recursive':            brew_runtime.bool_value(options.recursive)
		'installed':            brew_runtime.bool_value(options.installed)
		'missing':              brew_runtime.bool_value(options.missing)
		'eval_all':             brew_runtime.bool_value(options.eval_all)
		'include_implicit':     brew_runtime.bool_value(options.include_implicit)
		'include_build':        brew_runtime.bool_value(options.include_build)
		'include_test':         brew_runtime.bool_value(options.include_test)
		'include_optional':     brew_runtime.bool_value(options.include_optional)
		'skip_recommended':     brew_runtime.bool_value(options.skip_recommended)
		'formula':              brew_runtime.bool_value(options.formula)
		'cask':                 brew_runtime.bool_value(options.cask)
		'tap_trust_configured': brew_runtime.bool_value(options.tap_trust_configured)
		'stdout_tty':           brew_runtime.bool_value(options.stdout_tty)
		'console_width':        brew_runtime.int_value(options.console_width)
	})
}

fn uses_values(value brew_runtime.Value, name string) []brew_runtime.Value {
	return (value.map_data[name] or { brew_runtime.array_value([]) }).as_array() or {
		[]brew_runtime.Value{}
	}
}

pub fn uses_command_input_value(input UsesCommandInput) brew_runtime.Value {
	mut registry := map[string]brew_runtime.Value{}
	for name, dependent in input.registry {
		registry[name] = deps_dependent_value(dependent)
	}
	return brew_runtime.Value{
		type_name: 'Homebrew::Cmd::Uses'
		map_data: {
			'options':            uses_options_value(input.options)
			'named':              brew_runtime.string_array_value(input.named)
			'used_formulae':      brew_runtime.array_value(input.used_formulae.map(uses_formula_value(it)))
			'installed_formulae': brew_runtime.array_value(input.installed_formulae.map(deps_dependent_value(it)))
			'installed_casks':    brew_runtime.array_value(input.installed_casks.map(deps_dependent_value(it)))
			'all_formulae':       brew_runtime.array_value(input.all_formulae.map(deps_dependent_value(it)))
			'all_casks':          brew_runtime.array_value(input.all_casks.map(deps_dependent_value(it)))
			'caskroom_casks':     brew_runtime.array_value(input.caskroom_casks.map(deps_dependent_value(it)))
			'registry':           brew_runtime.map_value(registry)
		}
		attributes: {
			'formula_unavailable_error': input.formula_unavailable_error
		}
	}
}

fn uses_command_input_from_value(value brew_runtime.Value) UsesCommandInput {
	options_value := value.map_data['options'] or { brew_runtime.map_value({}) }
	registry_value := (value.map_data['registry'] or { brew_runtime.map_value({}) }).as_map() or {
		map[string]brew_runtime.Value{}
	}
	mut registry := map[string]DepsDependent{}
	for name, dependent in registry_value {
		registry[name] = deps_dependent_from_value(dependent)
	}
	return UsesCommandInput{
		options: uses_options_from_value(options_value)
		named: (value.map_data['named'] or { brew_runtime.string_array_value([]) }).as_string_array() or {
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

fn uses_result_value(result UsesCommandResult) brew_runtime.Value {
	return brew_runtime.Value{
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
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify <formula> as a required or recommended dependency for their stable builds.` at line 27.
pub fn ruby_uses_l27_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('CommandArgument', '<formula>', {
		'name':        '<formula>'
		'description': 'required or recommended dependency for stable builds'
	})
}

// Ruby method `run` at line 66.
pub fn ruby_uses_l66_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'run requires a Uses command input')
	}
	return uses_result_value(run_uses_command(uses_command_input_from_value(args[0])))
}

// Ruby method `intersection_of_dependents(use_runtime_dependents, used_formulae)` at line 101.
pub fn ruby_uses_l101_d3_intersection_of_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'intersection_of_dependents requires use_runtime_dependents and used_formulae')
	}
	use_runtime := args[0].as_bool() or { false }
	formula_values := args[1].as_array() or { []brew_runtime.Value{} }
	input := if args.len > 2 { uses_command_input_from_value(args[2]) } else { UsesCommandInput{} }
	dependents := intersection_of_dependents(input, use_runtime, formula_values.map(uses_formula_from_value(it))) or {
		return brew_runtime.object_value('UsageError', err.msg())
	}
	return brew_runtime.array_value(dependents.map(deps_dependent_value(it)))
}

// Ruby method `select_used_dependents(dependents, used_formulae, recursive, includes, ignores)` at line 158.
pub fn ruby_uses_l158_d4_select_used_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		return brew_runtime.object_value('ArgumentError', 'select_used_dependents requires dependents, used_formulae, recursive, includes and ignores')
	}
	dependent_values := args[0].as_array() or { []brew_runtime.Value{} }
	formula_values := args[1].as_array() or { []brew_runtime.Value{} }
	recursive := args[2].as_bool() or { false }
	includes := args[3].as_string_array() or { []string{} }
	ignores := args[4].as_string_array() or { []string{} }
	registry_values := if args.len > 5 {
		args[5].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	mut registry := map[string]DepsDependent{}
	for name, dependent in registry_values {
		registry[name] = deps_dependent_from_value(dependent)
	}
	selected := select_used_dependents(dependent_values.map(deps_dependent_from_value(it)), formula_values.map(uses_formula_from_value(it)), recursive, includes, ignores, registry)
	return brew_runtime.array_value(selected.map(deps_dependent_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask/caskroom"
// 7: require "dependencies_helpers"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     # `brew uses foo bar` returns formulae that use both foo and bar
// 12:     # If you want the union, run the command twice and concatenate the results.
// 13:     # The intersection is harder to achieve with shell tools.
// 14:     class Uses < AbstractCommand
// 15:       include DependenciesHelpers
// 16:
// 17:       class UnavailableFormula < T::Struct
// 18:         const :name, String
// 19:         const :full_name, String
// 20:       end
// 21:
// 22:       cmd_args do
// 23:         description <<~EOS
// 24:           Show formulae and casks that specify <formula> as a dependency; that is, show dependents
// 25:           of <formula>. When given multiple formula arguments, show the intersection
// 26:           of formulae that use <formula>. By default, `uses` shows all formulae and casks that
// 27:           specify <formula> as a required or recommended dependency for their stable builds.
// 28:
// 29:           *Note:* `--missing` and `--skip-recommended` have precedence over `--include-*`.
// 30:         EOS
// 31:         switch "--recursive",
// 32:                description: "Resolve more than one level of dependencies."
// 33:         switch "--installed",
// 34:                description: "Only list formulae and casks that are currently installed."
// 35:         switch "--missing",
// 36:                description: "Only list formulae and casks that are not currently installed."
// 37:         switch "--eval-all",
// 38:                description: "Evaluate all available formulae and casks, whether installed or not, to show " \
// 39:                             "their dependents.",
// 40:                env:         :eval_all,
// 41:                odeprecated: true
// 42:         switch "--include-implicit",
// 43:                description: "Include formulae that have <formula> as an implicit dependency for " \
// 44:                             "downloading and unpacking source files."
// 45:         switch "--include-build",
// 46:                description: "Include formulae that specify <formula> as a `:build` dependency."
// 47:         switch "--include-test",
// 48:                description: "Include formulae that specify <formula> as a `:test` dependency."
// 49:         switch "--include-optional",
// 50:                description: "Include formulae that specify <formula> as an `:optional` dependency."
// 51:         switch "--skip-recommended",
// 52:                description: "Skip all formulae that specify <formula> as a `:recommended` dependency."
// 53:         switch "--formula", "--formulae",
// 54:                description: "Include only formulae."
// 55:         switch "--cask", "--casks",
// 56:                description: "Include only casks."
// 57:
// 58:         conflicts "--formula", "--cask"
// 59:         conflicts "--installed", "--eval-all"
// 60:         conflicts "--missing", "--installed"
// 61:
// 62:         named_args :formula, min: 1
// 63:       end
// 64:
// 65:       sig { override.void }
// 66:       def run
// 67:         Formulary.enable_factory_cache!
// 68:
// 69:         used_formulae_missing = false
// 70:         used_formulae = begin
// 71:           args.named.to_formulae
// 72:         rescue FormulaUnavailableError => e
// 73:           opoo e
// 74:           used_formulae_missing = true
// 75:           # If the formula doesn't exist: fake the needed formula object name.
// 76:           args.named.map { |name| UnavailableFormula.new name:, full_name: name }
// 77:         end
// 78:
// 79:         use_runtime_dependents = args.installed? &&
// 80:                                  !used_formulae_missing &&
// 81:                                  !args.include_implicit? &&
// 82:                                  !args.include_build? &&
// 83:                                  !args.include_test? &&
// 84:                                  !args.include_optional? &&
// 85:                                  !args.skip_recommended?
// 86:
// 87:         uses = intersection_of_dependents(use_runtime_dependents, used_formulae)
// 88:
// 89:         return if uses.empty?
// 90:
// 91:         puts Formatter.columns(uses.map(&:full_name).sort)
// 92:         odie "Missing formulae should not have dependents!" if used_formulae_missing
// 93:       end
// 94:
// 95:       private
// 96:
// 97:       sig {
// 98:         params(use_runtime_dependents: T::Boolean, used_formulae: T::Array[T.any(Formula, UnavailableFormula)])
// 99:           .returns(T::Array[T.any(Formula, CaskDependent)])
// 100:       }
// 101:       def intersection_of_dependents(use_runtime_dependents, used_formulae)
// 102:         recursive = args.recursive?
// 103:         show_formulae_and_casks = !args.formula? && !args.cask?
// 104:         includes, ignores = args_includes_ignores(args)
// 105:
// 106:         deps = []
// 107:         if use_runtime_dependents
// 108:           # We can only get here if `used_formulae_missing` is false, thus there are no UnavailableFormula.
// 109:           used_formulae = T.cast(used_formulae, T::Array[Formula])
// 110:           if show_formulae_and_casks || args.formula?
// 111:             deps += T.must(used_formulae.map(&:runtime_installed_formula_dependents)
// 112:                      .reduce(&:&))
// 113:                      .select(&:any_version_installed?)
// 114:           end
// 115:           if show_formulae_and_casks || args.cask?
// 116:             deps += select_used_dependents(
// 117:               dependents(Cask::Caskroom.casks),
// 118:               used_formulae, recursive, includes, ignores
// 119:             )
// 120:           end
// 121:
// 122:           deps
// 123:         else
// 124:           eval_all = args.eval_all?
// 125:           eval_all ||= Homebrew::EnvConfig.tap_trust_configured?
// 126:
// 127:           if !args.installed? && !eval_all
// 128:             raise UsageError,
// 129:                   "`brew uses` needs `--installed`, `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 130:                   "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 131:           end
// 132:
// 133:           if show_formulae_and_casks || args.formula?
// 134:             deps += args.installed? ? Formula.installed : Formula.all(eval_all:)
// 135:           end
// 136:           if show_formulae_and_casks || args.cask?
// 137:             deps += args.installed? ? Cask::Caskroom.casks : Cask::Cask.all(eval_all:)
// 138:           end
// 139:
// 140:           if args.missing?
// 141:             deps.reject!(&:any_version_installed?)
// 142:             ignores.delete(:satisfied?)
// 143:           end
// 144:
// 145:           select_used_dependents(dependents(deps), used_formulae, recursive, includes, ignores)
// 146:         end
// 147:       end
// 148:
// 149:       sig {
// 150:         params(
// 151:           dependents:    T::Array[T.any(Formula, CaskDependent)],
// 152:           used_formulae: T::Array[T.any(Formula, UnavailableFormula)],
// 153:           recursive:     T::Boolean,
// 154:           includes:      T::Array[Symbol],
// 155:           ignores:       T::Array[Symbol],
// 156:         ).returns(T::Array[T.any(Formula, CaskDependent)])
// 157:       }
// 158:       def select_used_dependents(dependents, used_formulae, recursive, includes, ignores)
// 159:         dependents.select do |d|
// 160:           deps = if recursive
// 161:             recursive_dep_includes(d, includes, ignores)
// 162:           else
// 163:             select_includes(d.deps, ignores, includes)
// 164:           end
// 165:
// 166:           used_formulae.all? do |ff|
// 167:             deps.any? do |dep|
// 168:               match = case dep
// 169:               when Dependency
// 170:                 dep.to_formula.full_name == ff.full_name if dep.name.include?("/")
// 171:               when Requirement
// 172:                 nil
// 173:               else
// 174:                 T.absurd(dep)
// 175:               end
// 176:               next match unless match.nil?
// 177:
// 178:               dep.name == ff.name
// 179:             end
// 180:           rescue FormulaUnavailableError
// 181:             # Silently ignore this case as we don't care about things used in
// 182:             # taps that aren't currently tapped.
// 183:             next
// 184:           end
// 185:         end
// 186:       end
// 187:     end
// 188:   end
// 189: end
