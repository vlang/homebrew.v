module dev_cmd

import ruby
import homebrew.extend.file as atomic_file
import homebrew.utils
import os

// Translated from Homebrew/brew `dev-cmd/bump-revision.rb`.
pub struct RevisionFormula {
pub:
	name     string
	path     string
	revision int
}

pub struct BumpRevisionOptions {
pub:
	formulas            []RevisionFormula
	dry_run             bool
	quiet               bool
	remove_bottle_block bool
	write_only          bool
	message             string
	original_paths      []string
}

pub struct BumpRevisionResult {
pub:
	path              string
	bundler_groups    []string
	output            []string
	commit_commands   [][]string
	modified_formulae []string
}

@[heap]
pub struct BumpRevisionInput {
pub:
	options BumpRevisionOptions
}

pub fn bump_revision_source(source string, current_revision int,
	remove_bottle_block bool) (string, int) {
	new_revision := current_revision + 1
	mut formula_ast := utils.FormulaAst{
		contents: source
	}
	if current_revision == 0 {
		utils.ast_formula_add_stanza(mut formula_ast, 'revision', ruby.int_value(new_revision), none)
	} else {
		utils.ast_formula_replace_stanza(mut formula_ast, 'revision', ruby.int_value(new_revision), none)
	}
	if remove_bottle_block {
		utils.ast_formula_remove_stanza(mut formula_ast, 'bottle', none)
	}
	return formula_ast.contents, new_revision
}

pub fn run_bump_revision(options BumpRevisionOptions) !BumpRevisionResult {
	mut output := []string{}
	mut commands := [][]string{}
	mut modified := []string{}
	for formula in options.formulas {
		new_revision := formula.revision + 1
		if options.dry_run {
			if !options.quiet {
				new_text := 'revision ${new_revision}'
				if formula.revision == 0 {
					output << 'add "${new_text}"'
				} else {
					output << 'replace "revision ${formula.revision}" with "${new_text}"'
				}
			}
		} else {
			source := os.read_file(formula.path)!
			updated, _ := bump_revision_source(source, formula.revision, options.remove_bottle_block)
			atomic_file.atomic_write_contents(formula.path, os.dir(formula.path), updated)!
			modified << formula.path
		}
		message := '${formula.name}: revision bump ${options.message}'
		command := ['git', 'commit', '--no-edit', '--verbose', '--message=${message}', '--',
			formula.path]
		if options.dry_run {
			output << command.join(' ')
		} else if !options.write_only {
			commands << command
		}
	}
	return BumpRevisionResult{
		path: options.original_paths.join(':')
		bundler_groups: if options.dry_run { [] } else { ['ast'] }
		output: output
		commit_commands: commands
		modified_formulae: modified
	}
}

pub fn bump_revision_input_boundary(input &BumpRevisionInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::BumpRevision::Input', '', {
		'bump_revision_input_address': u64(voidptr(input)).str()
	})
}

fn bump_revision_input_from_value(value ruby.Value) &BumpRevisionInput {
	address := value.attributes['bump_revision_input_address'] or {
		panic('invalid BumpRevision input')
	}
	return unsafe { &BumpRevisionInput(voidptr(address.u64())) }
}

fn bump_revision_result_value(result BumpRevisionResult) ruby.Value {
	return ruby.map_value({
		'path':              ruby.string_value(result.path)
		'bundler_groups':    ruby.string_array_value(result.bundler_groups)
		'output':            ruby.string_array_value(result.output)
		'commit_commands':   ruby.array_value(result.commit_commands.map(ruby.string_array_value(it)))
		'modified_formulae': ruby.string_array_value(result.modified_formulae)
	})
}
