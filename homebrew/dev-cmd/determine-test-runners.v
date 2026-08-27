module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/determine-test-runners.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 39.
pub fn ruby_determine_test_runners_l39_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "test_runner_formula"
// 6: require "github_runner_matrix"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class DetermineTestRunners < AbstractCommand
// 11:       cmd_args do
// 12:         usage_banner <<~EOS
// 13:           `determine-test-runners` {<testing-formulae> [<deleted-formulae>]|--all-supported}
// 14:
// 15:           Determines the runners used to test formulae or their dependents. For internal use in Homebrew taps.
// 16:         EOS
// 17:         switch "--all-supported",
// 18:                description: "Instead of selecting runners based on the chosen formula, return all supported runners."
// 19:         switch "--eval-all",
// 20:                description: "Evaluate all available formulae, whether installed or not, to determine testing " \
// 21:                             "dependents.",
// 22:                env:         :eval_all,
// 23:                odeprecated: true
// 24:         switch "--dependents",
// 25:                description: "Determine runners for testing dependents."
// 26:         flag   "--dependent-shards=",
// 27:                description: "Split each dependent runner into the given number of shards.",
// 28:                depends_on:  "--dependents",
// 29:                hidden:      true
// 30:
// 31:         named_args max: 2
// 32:
// 33:         conflicts "--all-supported", "--dependents"
// 34:
// 35:         hide_from_man_page!
// 36:       end
// 37:
// 38:       sig { override.void }
// 39:       def run
// 40:         if args.no_named? && !args.all_supported?
// 41:           raise Homebrew::CLI::MinNamedArgumentsError, 1
// 42:         elsif args.all_supported? && !args.no_named?
// 43:           raise UsageError, "`--all-supported` is mutually exclusive to other arguments."
// 44:         end
// 45:
// 46:         eval_all = args.eval_all?
// 47:         eval_all ||= Homebrew::EnvConfig.tap_trust_configured?
// 48:
// 49:         testing_formulae = args.named.first&.split(",").to_a.map do |name|
// 50:           TestRunnerFormula.new(Formulary.factory(name), eval_all:)
// 51:         end.freeze
// 52:         deleted_formulae = args.named.second&.split(",").to_a.freeze
// 53:         dependent_shards = args.dependent_shards || "1"
// 54:         unless dependent_shards.match?(/\A[1-9]\d*\z/)
// 55:           raise UsageError,
// 56:                 "`--dependent-shards` must be a positive integer."
// 57:         end
// 58:
// 59:         runner_matrix = GitHubRunnerMatrix.new(testing_formulae, deleted_formulae,
// 60:                                                all_supported:    args.all_supported?,
// 61:                                                dependent_matrix: args.dependents?,
// 62:                                                dependent_shards: dependent_shards.to_i)
// 63:         runners = runner_matrix.active_runner_specs_hash
// 64:
// 65:         ohai "Runners", JSON.pretty_generate(runners)
// 66:
// 67:         # gracefully handle non-GitHub Actions environments
// 68:         github_output = if ENV.key?("GITHUB_ACTIONS")
// 69:           ENV.fetch("GITHUB_OUTPUT")
// 70:         else
// 71:           ENV.fetch("GITHUB_OUTPUT", nil)
// 72:         end
// 73:         return unless github_output
// 74:
// 75:         File.open(github_output, "a") do |f|
// 76:           f.puts("runners=#{runners.to_json}")
// 77:           f.puts("runners_present=#{runners.present?}")
// 78:         end
// 79:       end
// 80:     end
// 81:   end
// 82: end
