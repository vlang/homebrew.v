module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/unbottled.rb`.

pub const unbottled_portable_formulae = [
	'portable-libffi',
	'portable-libxcrypt',
	'portable-libyaml',
	'portable-openssl',
	'portable-ruby',
	'portable-zlib',
]

pub struct UnbottledFormula {
pub:
	name                  string
	deprecated            bool
	disabled              bool
	bottled_tags          []string
	dependencies          []string
	optional_dependencies []string
	requires_macos        bool
	requires_linux        bool
	required_arch         string
	macos_supported       bool = true
}

pub struct UnbottledAnalyticsItem {
pub:
	formula   string
	count     i64
	available bool = true
}

pub struct UnbottledSelectionRequest {
pub:
	named_formulae []UnbottledFormula
	all_formulae   []UnbottledFormula
	analytics      []UnbottledAnalyticsItem
	dependents     bool
	eval_all       bool
}

pub struct UnbottledSelection {
pub:
	formulae         []UnbottledFormula
	all_formulae     []UnbottledFormula
	formula_installs map[string]i64
	sort_description string
}

pub struct UnbottledDependencyGraph {
pub:
	dependencies map[string][]UnbottledFormula
	uses         map[string][]UnbottledFormula
}

pub struct UnbottledBottleTag {
pub:
	name  string
	linux bool
	arch  string
}

pub struct UnbottledRunRequest {
pub:
	tag                  UnbottledBottleTag
	named_formulae       []UnbottledFormula
	all_formulae         []UnbottledFormula
	analytics            []UnbottledAnalyticsItem
	dependents           bool
	total                bool
	lost                 bool
	eval_all             bool
	tap_trust_configured bool
	core_tap_installed   bool
	git_log              string
	formula_renames      map[string]string
}

fn unbottled_formula_allowed(formula UnbottledFormula) bool {
	return !formula.deprecated && !formula.disabled && formula.name !in unbottled_portable_formulae
}

pub fn select_unbottled_formulae(request UnbottledSelectionRequest) !UnbottledSelection {
	mut formulae := []UnbottledFormula{}
	mut all_formulae := request.all_formulae.clone()
	mut installs := map[string]i64{}
	mut sort_description := ''
	if request.named_formulae.len > 0 {
		formulae = request.named_formulae.clone()
		all_formulae = request.named_formulae.clone()
	} else if request.dependents {
		if !request.eval_all {
			return error('`brew unbottled --dependents` needs `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!')
		}
		formulae = request.all_formulae.clone()
		sort_description = ' (sorted by number of dependents)'
	} else if request.eval_all {
		formulae = request.all_formulae.clone()
	} else {
		if request.analytics.len == 0 {
			return error('default sort by analytics data requires `\$HOMEBREW_NO_GITHUB_API` and `\$HOMEBREW_NO_ANALYTICS` to be unset.')
		}
		mut available := map[string]UnbottledFormula{}
		for formula in request.all_formulae {
			available[formula.name] = formula
		}
		for item in request.analytics {
			name := item.formula.fields().first()
			if name == '' || name.contains('/') || name in installs || !item.available
				|| name !in available {
				continue
			}
			installs[name] = item.count
			formulae << available[name]
		}
		sort_description = ' (sorted by installs in the last 90 days; top 10,000 only)'
	}
	formulae = formulae.filter(unbottled_formula_allowed(it))
	all_formulae = all_formulae.filter(unbottled_formula_allowed(it))
	return UnbottledSelection{
		formulae: formulae
		all_formulae: all_formulae
		formula_installs: installs
		sort_description: sort_description
	}
}

pub fn unbottled_dependency_graph(all_formulae []UnbottledFormula) UnbottledDependencyGraph {
	mut by_name := map[string]UnbottledFormula{}
	for formula in all_formulae {
		by_name[formula.name] = formula
	}
	mut dependencies := map[string][]UnbottledFormula{}
	mut uses := map[string][]UnbottledFormula{}
	for formula in all_formulae {
		mut formula_dependencies := []UnbottledFormula{}
		for dependency_name in formula.dependencies {
			if dependency_name in formula.optional_dependencies || dependency_name !in by_name {
				continue
			}
			dependency := by_name[dependency_name]
			formula_dependencies << dependency
			uses[dependency_name] << formula
		}
		dependencies[formula.name] = formula_dependencies
	}
	return UnbottledDependencyGraph{
		dependencies: dependencies
		uses: uses
	}
}

fn unbottled_has_tag(formula UnbottledFormula, tag string) bool {
	return tag in formula.bottled_tags
}

pub fn unbottled_total_output(formulae []UnbottledFormula, tag string) string {
	if tag == '' {
		return ''
	}
	unbottled_count := formulae.filter(!unbottled_has_tag(it, tag)).len
	return 'Unbottled :${tag} formulae\n${unbottled_count}/${formulae.len} remaining.\n'
}

fn unbottled_count_suffix(name string, noun string, counts map[string]i64) string {
	return if noun == '' { '' } else { ' (${counts[name]} ${noun})' }
}

pub fn unbottled_status_output(formulae []UnbottledFormula, graph UnbottledDependencyGraph,
	tag UnbottledBottleTag, noun string, counts map[string]i64, any_named_args bool,
	sort_description string) string {
	if tag.name == '' {
		return ''
	}
	mut lines := [':${tag.name} bottle status${sort_description}']
	mut any_found := false
	for formula in formulae {
		name := formula.name.to_lower()
		if formula.disabled {
			if any_named_args {
				lines << '${name}: formula disabled'
			}
			continue
		}
		if tag.linux && formula.requires_macos {
			if any_named_args {
				lines << '${name}: requires macOS'
			}
			continue
		}
		if tag.linux && formula.required_arch != '' && formula.required_arch != tag.arch {
			if any_named_args {
				lines << "${name}: doesn't support ${tag.arch} Linux"
			}
			continue
		}
		if !tag.linux && formula.requires_linux {
			if any_named_args {
				lines << '${name}: requires Linux'
			}
			continue
		}
		if !tag.linux && (!formula.macos_supported
			|| (formula.required_arch != '' && formula.required_arch != tag.arch)) {
			if any_named_args {
				lines << "${name}: doesn't support this macOS"
			}
			continue
		}
		if unbottled_has_tag(formula, tag.name) {
			if any_named_args {
				lines << '${name}: already bottled'
			}
			continue
		}
		deps := graph.dependencies[formula.name].filter(!unbottled_has_tag(it, tag.name))
		suffix := unbottled_count_suffix(formula.name, noun, counts)
		if deps.len == 0 {
			lines << '${name}${suffix}: ready to bottle'
			continue
		}
		any_found = true
		lines << '${name}${suffix}: unbottled deps: ${deps.map(it.name).join(' ')}'
	}
	if !any_found && !any_named_args {
		lines << 'No unbottled dependencies found!'
	}
	return '${lines.join('\n')}\n'
}

fn unbottled_record_lost(mut output []string, commit string, formula string, lost_bottles int,
	processed map[string]bool) {
	if commit != '' && formula != '' && lost_bottles > 0 && !processed[formula] {
		output << '${commit}: bottle lost for ${formula}'
	}
}

pub fn unbottled_lost_bottles_output(tag string, git_log string,
	formula_renames map[string]string) string {
	if tag == '' {
		return ''
	}
	mut output := [':${tag} lost bottles']
	mut processed := map[string]bool{}
	mut commit := ''
	mut formula := ''
	mut lost_bottles := 0
	for line in git_log.split_into_lines() {
		if line.starts_with('commit ') && line.fields().len == 2 && line.fields()[1].len == 40 {
			unbottled_record_lost(mut output, commit, formula, lost_bottles, processed)
			if formula != '' {
				processed[formula] = true
			}
			commit = line.fields()[1]
			formula = ''
		} else if line.starts_with('diff --git a/Formula/') {
			mut name := line.all_after_last('/').trim_space()
			name = name.trim_string_right('.rb')
			formula = formula_renames[name] or { name }
			lost_bottles = 0
		} else if line.len > 0 && line[0] in [`+`, `-`] && line.contains('sha256')
			&& line.contains(' ${tag}: ') {
			if !processed[formula] {
				lost_bottles += if line[0] == `+` { -1 } else { 1 }
			}
		} else if line.starts_with('+') && line.contains('sha256') && line.contains(' all: ') {
			lost_bottles--
		}
	}
	unbottled_record_lost(mut output, commit, formula, lost_bottles, processed)
	return '${output.join('\n')}\n'
}

fn unbottled_sort_by_dependents(formulae []UnbottledFormula,
	uses map[string][]UnbottledFormula) []UnbottledFormula {
	mut sorted := formulae.clone()
	for left in 0 .. sorted.len {
		for right in left + 1 .. sorted.len {
			if uses[sorted[right].name].len > uses[sorted[left].name].len {
				sorted[left], sorted[right] = sorted[right], sorted[left]
			}
		}
	}
	return sorted
}

pub fn run_unbottled(request UnbottledRunRequest) !string {
	if request.tag.name == '' {
		return ''
	}
	if request.tag.arch !in ['x86_64', 'amd64', 'intel', 'arm64', 'aarch64', 'arm'] {
		return error('Unknown arch ${request.tag.arch}.')
	}
	if request.lost {
		if request.named_formulae.len > 0 {
			return error('`brew unbottled --lost` cannot be used with formula arguments!')
		}
		if !request.core_tap_installed {
			return error('`brew unbottled --lost` requires `homebrew/core` to be tapped locally!')
		}
		return unbottled_lost_bottles_output(request.tag.name, request.git_log, request.formula_renames)
	}
	eval_all := request.eval_all
		|| (request.named_formulae.len == 0 && (request.total || request.dependents)
			&& request.tap_trust_configured)
	if request.total && !eval_all {
		return error('`brew unbottled --total` needs `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!')
	}
	if request.named_formulae.len > 0 && eval_all {
		return error('Cannot specify formulae when evaluating all formulae or using `--total`.')
	}
	selection := select_unbottled_formulae(UnbottledSelectionRequest{
		named_formulae: request.named_formulae
		all_formulae: request.all_formulae
		analytics: request.analytics
		dependents: request.dependents
		eval_all: eval_all
	})!
	graph := unbottled_dependency_graph(selection.all_formulae)
	if request.dependents {
		formulae := unbottled_sort_by_dependents(selection.formulae, graph.uses)
		mut counts := map[string]i64{}
		for formula in formulae {
			counts[formula.name] = graph.uses[formula.name].len
		}
		return unbottled_status_output(formulae, graph, request.tag, 'dependents', counts, false, selection.sort_description)
	}
	if eval_all {
		return unbottled_total_output(selection.formulae, request.tag.name)
	}
	return unbottled_status_output(selection.formulae, graph, request.tag, if request.named_formulae.len > 0 {
		''
	} else {
		'installs'
	}, selection.formula_installs, request.named_formulae.len > 0, selection.sort_description)
}

fn unbottled_split_attribute(value string) []string {
	return value.split(',').map(it.trim_space()).filter(it != '')
}

fn unbottled_formula_from_value(value ruby.Value) UnbottledFormula {
	return UnbottledFormula{
		name: if value.attributes['name'] != '' {
			value.attributes['name']
		} else {
			value.as_string()
		}
		deprecated: value.attributes['deprecated'] == 'true'
		disabled: value.attributes['disabled'] == 'true'
		bottled_tags: unbottled_split_attribute(value.attributes['bottled_tags'])
		dependencies: unbottled_split_attribute(value.attributes['dependencies'])
		optional_dependencies: unbottled_split_attribute(value.attributes['optional_dependencies'])
		requires_macos: value.attributes['requires_macos'] == 'true'
		requires_linux: value.attributes['requires_linux'] == 'true'
		required_arch: value.attributes['required_arch']
		macos_supported: value.attributes['macos_supported'] != 'false'
	}
}

fn unbottled_formulae_from_value(value ruby.Value) []UnbottledFormula {
	values := value.as_array() or { return [] }
	return values.map(unbottled_formula_from_value(it))
}

fn unbottled_formula_value(formula UnbottledFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.name, {
		'name':                  formula.name
		'deprecated':            formula.deprecated.str()
		'disabled':              formula.disabled.str()
		'bottled_tags':          formula.bottled_tags.join(',')
		'dependencies':          formula.dependencies.join(',')
		'optional_dependencies': formula.optional_dependencies.join(',')
		'requires_macos':        formula.requires_macos.str()
		'requires_linux':        formula.requires_linux.str()
		'required_arch':         formula.required_arch
		'macos_supported':       formula.macos_supported.str()
	})
}

fn unbottled_formulae_value(formulae []UnbottledFormula) ruby.Value {
	return ruby.array_value(formulae.map(unbottled_formula_value(it)))
}

fn unbottled_graph_value(graph UnbottledDependencyGraph) ruby.Value {
	mut dependencies := map[string]ruby.Value{}
	mut uses := map[string]ruby.Value{}
	for name, formulae in graph.dependencies {
		dependencies[name] = unbottled_formulae_value(formulae)
	}
	for name, formulae in graph.uses {
		uses[name] = unbottled_formulae_value(formulae)
	}
	return ruby.map_value({
		'deps_hash': ruby.map_value(dependencies)
		'uses_hash': ruby.map_value(uses)
	})
}
