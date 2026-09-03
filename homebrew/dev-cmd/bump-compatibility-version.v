module dev_cmd

import brew_runtime
import homebrew.extend.file as atomic_file
import homebrew.utils
import os

// Translated from Homebrew/brew `dev-cmd/bump-compatibility-version.rb`.
// The original source is retained below until every stub has a typed V body.
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
		utils.ast_formula_add_stanza(mut formula_ast, 'compatibility_version', brew_runtime.int_value(new_version), none)
	} else {
		utils.ast_formula_replace_stanza(mut formula_ast, 'compatibility_version', brew_runtime.int_value(new_version), none)
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

pub fn bump_compatibility_version_input_boundary(input &BumpCompatibilityVersionInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::BumpCompatibilityVersion::Input', '', {
		'bump_compatibility_version_input_address': u64(voidptr(input)).str()
	})
}

fn bump_compatibility_version_input_from_value(value brew_runtime.Value) &BumpCompatibilityVersionInput {
	address := value.attributes['bump_compatibility_version_input_address'] or {
		panic('invalid BumpCompatibilityVersion input')
	}
	return unsafe { &BumpCompatibilityVersionInput(voidptr(address.u64())) }
}

fn bump_compatibility_version_result_value(result BumpCompatibilityVersionResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'path':              brew_runtime.string_value(result.path)
		'bundler_groups':    brew_runtime.string_array_value(result.bundler_groups)
		'output':            brew_runtime.string_array_value(result.output)
		'commit_commands':   brew_runtime.array_value(result.commit_commands.map(brew_runtime.string_array_value(it)))
		'modified_formulae': brew_runtime.string_array_value(result.modified_formulae)
	})
}

// Ruby method `run` at line 28.
pub fn ruby_bump_compatibility_version_l28_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	result := run_bump_compatibility_version(bump_compatibility_version_input_from_value(args[0]).options) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return bump_compatibility_version_result_value(result)
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
// 9:     class BumpCompatibilityVersion < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Create a commit to increment the compatibility_version of <formula>. If no
// 13:           compatibility_version is present, "compatibility_version 1" will be added.
// 14:         EOS
// 15:         switch "-n", "--dry-run",
// 16:                description: "Print what would be done rather than doing it."
// 17:         switch "--write-only",
// 18:                description: "Make the expected file modifications without taking any Git actions."
// 19:         flag   "--message=",
// 20:                description: "Append <message> to the default commit message."
// 21:
// 22:         conflicts "--dry-run", "--write-only"
// 23:
// 24:         named_args :formula, min: 1, without_api: true
// 25:       end
// 26:
// 27:       sig { override.void }
// 28:       def run
// 29:         # As this command is simplifying user-run commands then let's just use a
// 30:         # user path, too.
// 31:         ENV["PATH"] = PATH.new(ORIGINAL_PATHS).to_s
// 32:
// 33:         Homebrew.install_bundler_gems!(groups: ["ast"]) unless args.dry_run?
// 34:
// 35:         args.named.to_formulae.each do |formula|
// 36:           current_compatibility_version = formula.compatibility_version || 0
// 37:           new_compatibility_version = current_compatibility_version + 1
// 38:
// 39:           if args.dry_run?
// 40:             unless args.quiet?
// 41:               old_text = "compatibility_version #{current_compatibility_version}"
// 42:               new_text = "compatibility_version #{new_compatibility_version}"
// 43:               if formula.compatibility_version.nil?
// 44:                 ohai "add #{new_text.inspect}"
// 45:               else
// 46:                 ohai "replace #{old_text.inspect} with #{new_text.inspect}"
// 47:               end
// 48:             end
// 49:           else
// 50:             require "utils/ast"
// 51:
// 52:             formula_ast = Utils::AST::FormulaAST.new(formula.path.read)
// 53:             if formula.compatibility_version.nil?
// 54:               formula_ast.add_stanza(:compatibility_version, new_compatibility_version)
// 55:             else
// 56:               formula_ast.replace_stanza(:compatibility_version, new_compatibility_version)
// 57:             end
// 58:             formula.path.atomic_write(formula_ast.process)
// 59:           end
// 60:
// 61:           message = "#{formula.name}: compatibility_version bump #{args.message}"
// 62:           if args.dry_run?
// 63:             ohai "git commit --no-edit --verbose --message=#{message} -- #{formula.path}"
// 64:           elsif !args.write_only?
// 65:             formula.path.parent.cd do
// 66:               safe_system "git", "commit", "--no-edit", "--verbose",
// 67:                           "--message=#{message}", "--", formula.path
// 68:             end
// 69:           end
// 70:         end
// 71:       end
// 72:     end
// 73:   end
// 74: end
