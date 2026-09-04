module test_bot

import homebrew.utils

pub struct BottlesFetch {
pub mut:
	testing_formulae []string
}

pub struct BottlesFetchFormula {
pub:
	name        string
	disabled    bool
	bottle_tags []utils.BottlesTag
}

pub struct BottlesFetchFormulaGroup {
pub:
	tag utils.BottlesTag
pub mut:
	formulae []string
}

pub enum BottlesFetchOperationKind {
	info_header
	output
	blank_line
	test_header
	cleanup
	fetch
}

pub struct BottlesFetchOperation {
pub:
	kind    BottlesFetchOperationKind
	text    string
	command []string
}

pub struct BottlesFetchTagPlan {
pub:
	tag        utils.BottlesTag
	formulae   []string
	header     string
	cleanup    bool
	passed     bool = true
	command    []string
	operations []BottlesFetchOperation
}

pub struct BottlesFetchRun {
pub:
	groups     []BottlesFetchFormulaGroup
	operations []BottlesFetchOperation
}

pub type BottlesFetchFormulaResolver = fn (name string, formulae map[string]BottlesFetchFormula) !BottlesFetchFormula

pub struct BottlesFetchConfig {
pub:
	formulae         map[string]BottlesFetchFormula
	formula_resolver BottlesFetchFormulaResolver = resolve_bottles_fetch_formula
}

pub fn resolve_bottles_fetch_formula(name string,
	formulae map[string]BottlesFetchFormula) !BottlesFetchFormula {
	formula := formulae[name] or { return error('Formula unavailable: ${name}') }
	return if formula.name == '' {
		BottlesFetchFormula{
			...formula
			name: name
		}
	} else {
		formula
	}
}

pub fn new_bottles_fetch(testing_formulae []string) BottlesFetch {
	return BottlesFetch{
		testing_formulae: testing_formulae.clone()
	}
}

pub fn (fetch &BottlesFetch) get_testing_formulae() []string {
	return fetch.testing_formulae.clone()
}

pub fn (mut fetch BottlesFetch) set_testing_formulae(testing_formulae []string) []string {
	fetch.testing_formulae = testing_formulae.clone()
	return fetch.testing_formulae.clone()
}

// Translated from Homebrew/brew `test_bot/bottles_fetch.rb`.

pub fn bottles_fetch_formulae_by_tag(testing_formulae []string,
	config BottlesFetchConfig) ![]BottlesFetchFormulaGroup {
	mut groups := []BottlesFetchFormulaGroup{}
	for formula_name in testing_formulae {
		formula := config.formula_resolver(formula_name, config.formulae)!
		if formula.disabled {
			continue
		}
		if formula.bottle_tags.len == 0 {
			return error('${formula_name} is missing bottles! Did you mean to use `brew pr-publish`?')
		}
		for tag in formula.bottle_tags {
			mut group_index := -1
			for index, group in groups {
				if group.tag.equals(tag) {
					group_index = index
					break
				}
			}
			if group_index < 0 {
				groups << BottlesFetchFormulaGroup{
					tag: tag
					formulae: [formula_name]
				}
				continue
			}
			if formula_name !in groups[group_index].formulae {
				groups[group_index].formulae << formula_name
			}
		}
	}
	return groups
}

pub fn bottles_fetch_for_tag(tag utils.BottlesTag, formulae []string) BottlesFetchTagPlan {
	header := 'Running BottlesFetch#fetch_bottles!(${tag})'
	mut command := ['brew', 'fetch', '--retry', '--formulae', '--bottle-tag=${tag}']
	command << formulae
	return BottlesFetchTagPlan{
		tag: tag
		formulae: formulae.clone()
		header: header
		cleanup: true
		command: command
		operations: [
			BottlesFetchOperation{
				kind: .test_header
				text: header
			},
			BottlesFetchOperation{
				kind: .cleanup
			},
			BottlesFetchOperation{
				kind: .fetch
				command: command
			},
		]
	}
}

pub fn bottles_fetch_run(fetch BottlesFetch, config BottlesFetchConfig) !BottlesFetchRun {
	mut operations := [BottlesFetchOperation{
		kind: .info_header
		text: 'Testing formulae:'
	}]
	for formula_name in fetch.testing_formulae {
		operations << BottlesFetchOperation{
			kind: .output
			text: formula_name
		}
	}
	operations << BottlesFetchOperation{
		kind: .blank_line
	}
	groups := bottles_fetch_formulae_by_tag(fetch.testing_formulae, config)!
	for group in groups {
		plan := bottles_fetch_for_tag(group.tag, group.formulae)
		operations << plan.operations
		operations << BottlesFetchOperation{
			kind: .blank_line
		}
	}
	return BottlesFetchRun{
		groups: groups
		operations: operations
	}
}
