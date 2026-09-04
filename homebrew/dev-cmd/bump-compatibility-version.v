module dev_cmd

import ruby
import homebrew.extend.file as atomic_file
import homebrew.utils
import os

// Translated from Homebrew/brew `dev-cmd/bump-compatibility-version.rb`.
pub struct CompatibilityVersionFormula {
pub:
	name                  string
	path                  string
	compatibility_version ?int
}

pub struct BumpCompatibilityVersionOptions {
pub:
	formulas       []CompatibilityVersionFormula
	dry_run        bool
	quiet          bool
	write_only     bool
	message        string
	original_paths []string
}

pub struct BumpCompatibilityVersionResult {
pub:
	path              string
	bundler_groups    []string
	output            []string
	commit_commands   [][]string
	modified_formulae []string
}

@[heap]
pub struct BumpCompatibilityVersionInput {
pub:
	options BumpCompatibilityVersionOptions
}

pub fn bump_compatibility_version_source(source string, current ?int) (string, int) {
	current_version := current or { 0 }
	new_version := current_version + 1
	mut formula_ast := utils.FormulaAst{
		contents: source
	}
	if current == none {
		utils.ast_formula_add_stanza(mut formula_ast, 'compatibility_version', ruby.int_value(new_version), none)
	} else {
		utils.ast_formula_replace_stanza(mut formula_ast, 'compatibility_version', ruby.int_value(new_version), none)
	}
	return formula_ast.contents, new_version
}

pub fn run_bump_compatibility_version(options BumpCompatibilityVersionOptions) !BumpCompatibilityVersionResult {
	mut output := []string{}
	mut commands := [][]string{}
	mut modified := []string{}
	for formula in options.formulas {
		current_version := formula.compatibility_version or { 0 }
		new_version := current_version + 1
		if options.dry_run {
			if !options.quiet {
				new_text := 'compatibility_version ${new_version}'
				if formula.compatibility_version == none {
					output << 'add "${new_text}"'
				} else {
					output << 'replace "compatibility_version ${current_version}" with "${new_text}"'
				}
			}
		} else {
			source := os.read_file(formula.path)!
			updated, _ := bump_compatibility_version_source(source, formula.compatibility_version)
			atomic_file.atomic_write_contents(formula.path, os.dir(formula.path), updated)!
			modified << formula.path
		}
		message := '${formula.name}: compatibility_version bump ${options.message}'
		command := ['git', 'commit', '--no-edit', '--verbose', '--message=${message}', '--',
			formula.path]
		if options.dry_run {
			output << command.join(' ')
		} else if !options.write_only {
			commands << command
		}
	}
	return BumpCompatibilityVersionResult{
		path: options.original_paths.join(':')
		bundler_groups: if options.dry_run { [] } else { ['ast'] }
		output: output
		commit_commands: commands
		modified_formulae: modified
	}
}

pub fn bump_compatibility_version_input_boundary(input &BumpCompatibilityVersionInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::BumpCompatibilityVersion::Input', '', {
		'bump_compatibility_version_input_address': u64(voidptr(input)).str()
	})
}

fn bump_compatibility_version_input_from_value(value ruby.Value) &BumpCompatibilityVersionInput {
	address := value.attributes['bump_compatibility_version_input_address'] or {
		panic('invalid BumpCompatibilityVersion input')
	}
	return unsafe { &BumpCompatibilityVersionInput(voidptr(address.u64())) }
}

fn bump_compatibility_version_result_value(result BumpCompatibilityVersionResult) ruby.Value {
	return ruby.map_value({
		'path':              ruby.string_value(result.path)
		'bundler_groups':    ruby.string_array_value(result.bundler_groups)
		'output':            ruby.string_array_value(result.output)
		'commit_commands':   ruby.array_value(result.commit_commands.map(ruby.string_array_value(it)))
		'modified_formulae': ruby.string_array_value(result.modified_formulae)
	})
}
