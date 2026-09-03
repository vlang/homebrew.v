module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/missing.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MissingCommandResult {
pub:
	output string
	failed bool
}

pub struct MissingCommandPackage {
pub:
	full_name            string
	display_name         string
	missing_dependencies []string
}

pub fn missing_command(formulae []MissingCommandPackage, casks []MissingCommandPackage,
	storage_exists bool) MissingCommandResult {
	if !storage_exists {
		return MissingCommandResult{}
	}
	mut sorted_formulae := formulae.clone()
	sorted_formulae.sort_with_compare(fn (left &MissingCommandPackage,
		right &MissingCommandPackage) int {
		return compare_strings(left.full_name, right.full_name)
	})
	mut sorted_casks := casks.clone()
	sorted_casks.sort_with_compare(fn (left &MissingCommandPackage,
		right &MissingCommandPackage) int {
		return compare_strings(left.full_name, right.full_name)
	})
	package_count := sorted_formulae.len + sorted_casks.len
	mut lines := []string{}
	for formula in sorted_formulae {
		if formula.missing_dependencies.len == 0 {
			continue
		}
		prefix := if package_count > 1 {
			'${if formula.display_name == '' { formula.full_name } else { formula.display_name }}: '
		} else {
			''
		}
		lines << prefix + formula.missing_dependencies.join(' ')
	}
	for cask in sorted_casks {
		if cask.missing_dependencies.len == 0 {
			continue
		}
		prefix := if package_count > 1 {
			'${if cask.display_name == '' { cask.full_name } else { cask.display_name }}: '
		} else {
			''
		}
		lines << prefix + cask.missing_dependencies.join(' ')
	}
	return MissingCommandResult{
		output: if lines.len == 0 { '' } else { lines.join('\n') + '\n' }
		failed: lines.len > 0
	}
}

// Ruby method `run` at line 26.
pub fn ruby_missing_l26_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	formulae := if args.len > 0 {
		missing_command_packages_from_value(args[0])
	} else {
		[]MissingCommandPackage{}
	}
	casks := if args.len > 1 {
		missing_command_packages_from_value(args[1])
	} else {
		[]MissingCommandPackage{}
	}
	storage_exists := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	result := missing_command(formulae, casks, storage_exists)
	return brew_runtime.structured_value('MissingCommandResult', result.output, {
		'output': result.output
		'failed': result.failed.str()
	})
}

fn missing_command_packages_from_value(value brew_runtime.Value) []MissingCommandPackage {
	return value.array_data.map(MissingCommandPackage{
		full_name: it.attributes['full_name'] or { it.as_string() }
		display_name: it.attributes['display_name'] or { it.as_string() }
		missing_dependencies: (it.attributes['missing_dependencies'] or { '' }).split(',').filter(it != '')
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask/caskroom"
// 7: require "missing"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     class Missing < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Check the given <formula> kegs and <cask> installations for missing dependencies.
// 15:           If no <formula> or <cask> are provided, check all kegs and casks. Will exit with
// 16:           a non-zero status if any kegs or casks are found to be missing dependencies.
// 17:         EOS
// 18:         comma_array "--hide",
// 19:                     description: "Act as if none of the specified <hidden> are installed. <hidden> should be " \
// 20:                                  "a comma-separated list of formulae or casks."
// 21:
// 22:         named_args [:formula, :cask]
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         return if !HOMEBREW_CELLAR.exist? && !Cask::Caskroom.path.exist?
// 28:
// 29:         formulae, casks = if args.no_named?
// 30:           [Formula.installed, Cask::Caskroom.casks]
// 31:         else
// 32:           args.named.to_resolved_formulae_to_casks
// 33:         end
// 34:         formulae = formulae.sort
// 35:         casks = casks.sort_by(&:full_name)
// 36:         hide = args.hide || []
// 37:         package_count = formulae.size + casks.size
// 38:         missing_deps = Homebrew::Missing.deps(formulae, casks, hide)
// 39:
// 40:         (formulae + casks).each do |formula_or_cask|
// 41:           missing = missing_deps[formula_or_cask.full_name]
// 42:           next if missing.blank?
// 43:
// 44:           Homebrew.failed = true
// 45:           print "#{formula_or_cask}: " if package_count > 1
// 46:           puts missing.join(" ")
// 47:         end
// 48:       end
// 49:     end
// 50:   end
// 51: end
