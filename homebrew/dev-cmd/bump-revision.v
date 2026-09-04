module dev_cmd

import ruby
import homebrew.extend.file as atomic_file
import homebrew.utils
import os

// Translated from Homebrew/brew `dev-cmd/bump-revision.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `run` at line 30.
pub fn ruby_bump_revision_l30_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	result := run_bump_revision(bump_revision_input_from_value(args[0]).options) or {
		return ruby.object_value('Error', err.msg())
	}
	return bump_revision_result_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class BumpRevision < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Create a commit to increment the revision of <formula>. If no revision is
// 13:           present, "revision 1" will be added.
// 14:         EOS
// 15:         switch "-n", "--dry-run",
// 16:                description: "Print what would be done rather than doing it."
// 17:         switch "--remove-bottle-block",
// 18:                description: "Remove the bottle block in addition to bumping the revision."
// 19:         switch "--write-only",
// 20:                description: "Make the expected file modifications without taking any Git actions."
// 21:         flag   "--message=",
// 22:                description: "Append <message> to the default commit message."
// 23:
// 24:         conflicts "--dry-run", "--write-only"
// 25:
// 26:         named_args :formula, min: 1, without_api: true
// 27:       end
// 28:
// 29:       sig { override.void }
// 30:       def run
// 31:         # As this command is simplifying user-run commands then let's just use a
// 32:         # user path, too.
// 33:         ENV["PATH"] = PATH.new(ORIGINAL_PATHS).to_s
// 34:
// 35:         Homebrew.install_bundler_gems!(groups: ["ast"]) unless args.dry_run?
// 36:
// 37:         args.named.to_formulae.each do |formula|
// 38:           current_revision = formula.revision
// 39:           new_revision = current_revision + 1
// 40:
// 41:           if args.dry_run?
// 42:             unless args.quiet?
// 43:               old_text = "revision #{current_revision}"
// 44:               new_text = "revision #{new_revision}"
// 45:               if current_revision.zero?
// 46:                 ohai "add #{new_text.inspect}"
// 47:               else
// 48:                 ohai "replace #{old_text.inspect} with #{new_text.inspect}"
// 49:               end
// 50:             end
// 51:           else
// 52:             require "utils/ast"
// 53:
// 54:             formula_ast = Utils::AST::FormulaAST.new(formula.path.read)
// 55:             if current_revision.zero?
// 56:               formula_ast.add_stanza(:revision, new_revision)
// 57:             else
// 58:               formula_ast.replace_stanza(:revision, new_revision)
// 59:             end
// 60:             formula_ast.remove_stanza(:bottle) if args.remove_bottle_block?
// 61:             formula.path.atomic_write(formula_ast.process)
// 62:           end
// 63:
// 64:           message = "#{formula.name}: revision bump #{args.message}"
// 65:           if args.dry_run?
// 66:             ohai "git commit --no-edit --verbose --message=#{message} -- #{formula.path}"
// 67:           elsif !args.write_only?
// 68:             formula.path.parent.cd do
// 69:               safe_system "git", "commit", "--no-edit", "--verbose",
// 70:                           "--message=#{message}", "--", formula.path
// 71:             end
// 72:           end
// 73:         end
// 74:       end
// 75:     end
// 76:   end
// 77: end
