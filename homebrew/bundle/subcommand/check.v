module subcommand

import brew_runtime
import homebrew.bundle

// Translated from Homebrew/brew `bundle/subcommand/check.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 30.
pub fn ruby_check_l30_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 && args[0].type_name == 'Hash' && '_dsl_set' in args[0].map_data {
		verbose := if args.len > 1 { args[1].as_bool() or { false } } else { false }
		quiet := if args.len > 2 { args[2].as_bool() or { false } } else { false }
		no_upgrade := if args.len > 3 { args[3].as_bool() or { false } } else { false }
		already_output_formulae := if args.len > 4 {
			args[4].as_string_array() or { [] }
		} else {
			[]
		}
		result := run_bundle_check(bundle.checker_state_from_value(args[0]), BundleCheckRunOptions{
			verbose: verbose
			quiet: quiet
			no_upgrade: no_upgrade
			already_output_formulae: already_output_formulae
		}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
		return bundle_check_result_value(result)
	}
	check := BundleDependencyCheck{
		work_to_be_done: if args.len > 0 { args[0].as_bool() or { false } } else { false }
		errors: if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	}
	options := BundleCheckCommandOptions{
		verbose: if args.len > 2 { args[2].as_bool() or { false } } else { false }
		quiet: if args.len > 3 { args[3].as_bool() or { false } } else { false }
		already_output_formulae: if args.len > 4 { args[4].as_string_array() or { [] } } else { [] }
	}
	result := render_bundle_check(check, options)
	return bundle_check_result_value(result)
}

fn bundle_check_result_value(result BundleCheckCommandResult) brew_runtime.Value {
	return brew_runtime.structured_value('Bundle::CheckSubcommand::Result', result.exit_code.str(), {
		'exit_code': result.exit_code.str()
		'stdout':    result.stdout
		'stderr':    result.stderr
	})
}

pub struct BundleCheckRunOptions {
pub:
	verbose                 bool
	quiet                   bool
	no_upgrade              bool
	already_output_formulae []string
}

pub fn run_bundle_check(state bundle.CheckerState,
	options BundleCheckRunOptions) !BundleCheckCommandResult {
	check := bundle.check_bundle_state(state, bundle.CheckerOptions{
		exit_on_first_error: !options.verbose
		no_upgrade: options.no_upgrade
		verbose: options.verbose
	})!
	return render_bundle_check(BundleDependencyCheck{
		work_to_be_done: check.work_to_be_done
		errors: check.errors
	}, BundleCheckCommandOptions{
		verbose: options.verbose
		quiet: options.quiet
		already_output_formulae: options.already_output_formulae
	})
}

pub struct BundleDependencyCheck {
pub:
	work_to_be_done bool
	errors          []string
}

pub struct BundleCheckCommandOptions {
pub:
	verbose                 bool
	quiet                   bool
	already_output_formulae []string
}

pub struct BundleCheckCommandResult {
pub:
	exit_code int
	stdout    string
	stderr    string
}

fn bundle_missing_formula_name(message string) ?string {
	prefix := 'Formula '
	suffix := ' needs to be installed'
	if !message.starts_with(prefix) {
		return none
	}
	end := message.index(suffix) or { return none }
	if end <= prefix.len {
		return none
	}
	return message[prefix.len..end]
}

pub fn render_bundle_check(check BundleDependencyCheck,
	options BundleCheckCommandOptions) BundleCheckCommandResult {
	if !check.work_to_be_done {
		return BundleCheckCommandResult{
			stdout: if options.quiet { '' } else { "The Brewfile's dependencies are satisfied.\n" }
		}
	}
	mut lines := []string{}
	if options.already_output_formulae.len == 0 {
		lines << "brew bundle can't satisfy your Brewfile's dependencies."
	}
	if options.verbose {
		for message in check.errors {
			name := bundle_missing_formula_name(message)
			if value := name {
				if value in options.already_output_formulae {
					continue
				}
			}
			lines << '→ ${message}'
		}
	} else {
		lines << 'Run `brew bundle check --verbose` to list unmet dependencies.'
	}
	lines << 'Satisfy missing dependencies with `brew bundle install`.'
	return BundleCheckCommandResult{
		exit_code: 1
		stderr: '${lines.join('\n')}\n'
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: require "bundle/checker"
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Bundle < Homebrew::AbstractCommand
// 10:       class CheckSubcommand < Homebrew::AbstractSubcommand
// 11:         subcommand_args do
// 12:           usage_banner <<~EOS
// 13:             `brew bundle check`:
// 14:             Check if all dependencies present in the `Brewfile` are installed.
// 15:
// 16:             This provides a successful exit code if everything is up-to-date, making it useful for scripting. Use `--verbose` to list unmet dependencies.
// 17:           EOS
// 18:           named_args :none
// 19:           switch "-v", "--verbose",
// 20:                  description: "List all missing dependencies."
// 21:           switch "--no-upgrade",
// 22:                  description: "Do not check for outdated dependencies. " \
// 23:                               "Note they may still be upgraded by `brew install` if needed.",
// 24:                  env:         :bundle_no_upgrade
// 25:           switch "--install",
// 26:                  description: "Run `install` before checking dependencies."
// 27:         end
// 28:
// 29:         sig { override.void }
// 30:         def run
// 31:           output_errors = context.verbose
// 32:           exit_on_first_error = !context.verbose
// 33:           check_result = Homebrew::Bundle::Checker.check(
// 34:             global: context.global, file: context.file,
// 35:             exit_on_first_error:, no_upgrade: context.no_upgrade, verbose: context.verbose
// 36:           )
// 37:
// 38:           # Allow callers of `brew bundle check` to specify when they've already
// 39:           # output some formulae errors.
// 40:           check_missing_formulae = ENV.fetch("HOMEBREW_BUNDLE_CHECK_ALREADY_OUTPUT_FORMULAE_ERRORS", "")
// 41:                                       .strip
// 42:                                       .split
// 43:
// 44:           if check_result.work_to_be_done
// 45:             $stderr.puts "brew bundle can't satisfy your Brewfile's dependencies." if check_missing_formulae.blank?
// 46:
// 47:             if output_errors
// 48:               check_result.errors.each do |error|
// 49:                 if (match = error.match(/^Formula (.+) needs to be installed/)) &&
// 50:                    check_missing_formulae.include?(match[1])
// 51:                   next
// 52:                 end
// 53:
// 54:                 $stderr.puts "→ #{error}"
// 55:               end
// 56:             else
// 57:               $stderr.puts "Run `brew bundle check --verbose` to list unmet dependencies."
// 58:             end
// 59:
// 60:             $stderr.puts "Satisfy missing dependencies with `brew bundle install`."
// 61:             exit 1
// 62:           end
// 63:
// 64:           puts "The Brewfile's dependencies are satisfied." unless quiet
// 65:         end
// 66:       end
// 67:     end
// 68:   end
// 69: end
