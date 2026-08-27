module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/leaves.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 26.
pub fn ruby_leaves_l26_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `installed_on_request?(formula)` at line 64.
pub fn ruby_leaves_l64_d2_installed_on_request(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_on_request?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask_dependent"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Leaves < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           List installed formulae that are not dependencies of another installed formula or cask.
// 14:         EOS
// 15:         switch "-r", "--installed-on-request",
// 16:                description: "Only list leaves that were manually installed."
// 17:         switch "-p", "--installed-as-dependency",
// 18:                description: "Only list leaves that were installed as dependencies."
// 19:
// 20:         conflicts "--installed-on-request", "--installed-as-dependency"
// 21:
// 22:         named_args :none
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         installed = Formula.installed
// 28:
// 29:         # Build a set of dependency names from tab data to avoid loading full Formula objects
// 30:         # via Formulary.resolve for each dependency (which is expensive I/O).
// 31:         formula_dep_names = installed.flat_map do |f|
// 32:           if (tab_deps = f.any_installed_keg&.runtime_dependencies)
// 33:             tab_deps.filter_map do |dep|
// 34:               full_name = dep["full_name"]
// 35:               next unless full_name
// 36:
// 37:               Utils.name_from_full_name(full_name)
// 38:             end
// 39:           else
// 40:             # Fallback for installations without tab runtime_dependencies.
// 41:             f.installed_runtime_formula_dependencies.map(&:name)
// 42:           end
// 43:         end
// 44:
// 45:         # Add direct cask formula dependency names; their transitive deps are already in dep_names.
// 46:         cask_dep_names = Cask::Caskroom.casks.flat_map do |cask|
// 47:           CaskDependent.new(cask).deps.map { |dep| Utils.name_from_full_name(dep.name) }
// 48:         end
// 49:
// 50:         dep_names = T.let((formula_dep_names + cask_dep_names).to_set, T::Set[String])
// 51:
// 52:         leaves_list = installed.reject { |f| dep_names.intersect?(f.possible_names) }
// 53:         leaves_list.select! { |leaf| installed_on_request?(leaf) } if args.installed_on_request?
// 54:         leaves_list.reject! { |leaf| installed_on_request?(leaf) } if args.installed_as_dependency?
// 55:
// 56:         leaves_list.map(&:full_name)
// 57:                    .sort
// 58:                    .each { |leaf| puts(leaf) }
// 59:       end
// 60:
// 61:       private
// 62:
// 63:       sig { params(formula: Formula).returns(T::Boolean) }
// 64:       def installed_on_request?(formula)
// 65:         formula.any_installed_keg&.tab&.installed_on_request == true
// 66:       end
// 67:     end
// 68:   end
// 69: end
