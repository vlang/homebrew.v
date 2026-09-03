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
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :testing_formulae` at line 8.
pub fn ruby_bottles_fetch_l8_d1_testing_formulae(fetch &BottlesFetch) []string {
	return fetch.get_testing_formulae()
}

// Ruby attr_accessor `attr_accessor :testing_formulae` at line 8.
pub fn ruby_bottles_fetch_l8_d2_testing_formulae(mut fetch BottlesFetch,
	testing_formulae []string) []string {
	return fetch.set_testing_formulae(testing_formulae)
}

// Ruby method `run!(args:)` at line 11.
pub fn ruby_bottles_fetch_l11_d3_run(fetch BottlesFetch,
	config BottlesFetchConfig) !BottlesFetchRun {
	return bottles_fetch_run(fetch, config)
}

// Ruby method `formulae_by_tag` at line 25.
pub fn ruby_bottles_fetch_l25_d4_formulae_by_tag(fetch BottlesFetch,
	config BottlesFetchConfig) ![]BottlesFetchFormulaGroup {
	return bottles_fetch_formulae_by_tag(fetch.testing_formulae, config)
}

// Ruby method `fetch_bottles!(tag, formulae, args:)` at line 45.
pub fn ruby_bottles_fetch_l45_d5_fetch_bottles(tag utils.BottlesTag,
	formulae []string) BottlesFetchTagPlan {
	return bottles_fetch_for_tag(tag, formulae)
}

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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     class BottlesFetch < TestFormulae
// 7:       sig { returns(T::Array[String]) }
// 8:       attr_accessor :testing_formulae
// 9:
// 10:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 11:       def run!(args:)
// 12:         info_header "Testing formulae:"
// 13:         puts testing_formulae
// 14:         puts
// 15:
// 16:         formulae_by_tag.each do |tag, formulae|
// 17:           fetch_bottles!(tag, formulae, args:)
// 18:           puts
// 19:         end
// 20:       end
// 21:
// 22:       private
// 23:
// 24:       sig { returns(T::Hash[Utils::Bottles::Tag, T::Set[String]]) }
// 25:       def formulae_by_tag
// 26:         tags = Hash.new { |hash, key| hash[key] = Set.new }
// 27:
// 28:         testing_formulae.each do |formula_name|
// 29:           formula = Formula[formula_name]
// 30:           next if formula.disabled?
// 31:
// 32:           formula_tags = formula.bottle_specification.collector.tags
// 33:
// 34:           odie "#{formula_name} is missing bottles! Did you mean to use `brew pr-publish`?" if formula_tags.blank?
// 35:
// 36:           formula_tags.each do |tag|
// 37:             tags[tag] << formula_name
// 38:           end
// 39:         end
// 40:
// 41:         tags
// 42:       end
// 43:
// 44:       sig { params(tag: Utils::Bottles::Tag, formulae: T::Set[String], args: Homebrew::Cmd::TestBotCmd::Args).void }
// 45:       def fetch_bottles!(tag, formulae, args:)
// 46:         test_header(:BottlesFetch, method: "fetch_bottles!(#{tag})")
// 47:
// 48:         cleanup_during!(args:)
// 49:         test "brew", "fetch", "--retry", "--formulae", "--bottle-tag=#{tag}", *formulae
// 50:       end
// 51:     end
// 52:   end
// 53: end
