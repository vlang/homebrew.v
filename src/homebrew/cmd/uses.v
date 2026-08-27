module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/uses.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify <formula> as a required or recommended dependency for their stable builds.` at line 27.
pub fn ruby_uses_l27_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<formula>', ...args)
}

// Ruby method `run` at line 66.
pub fn ruby_uses_l66_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `intersection_of_dependents(use_runtime_dependents, used_formulae)` at line 101.
pub fn ruby_uses_l101_d3_intersection_of_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('intersection_of_dependents', ...args)
}

// Ruby method `select_used_dependents(dependents, used_formulae, recursive, includes, ignores)` at line 158.
pub fn ruby_uses_l158_d4_select_used_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('select_used_dependents', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask/caskroom"
// 7: require "dependencies_helpers"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     # `brew uses foo bar` returns formulae that use both foo and bar
// 12:     # If you want the union, run the command twice and concatenate the results.
// 13:     # The intersection is harder to achieve with shell tools.
// 14:     class Uses < AbstractCommand
// 15:       include DependenciesHelpers
// 16:
// 17:       class UnavailableFormula < T::Struct
// 18:         const :name, String
// 19:         const :full_name, String
// 20:       end
// 21:
// 22:       cmd_args do
// 23:         description <<~EOS
// 24:           Show formulae and casks that specify <formula> as a dependency; that is, show dependents
// 25:           of <formula>. When given multiple formula arguments, show the intersection
// 26:           of formulae that use <formula>. By default, `uses` shows all formulae and casks that
// 27:           specify <formula> as a required or recommended dependency for their stable builds.
// 28:
// 29:           *Note:* `--missing` and `--skip-recommended` have precedence over `--include-*`.
// 30:         EOS
// 31:         switch "--recursive",
// 32:                description: "Resolve more than one level of dependencies."
// 33:         switch "--installed",
// 34:                description: "Only list formulae and casks that are currently installed."
// 35:         switch "--missing",
// 36:                description: "Only list formulae and casks that are not currently installed."
// 37:         switch "--eval-all",
// 38:                description: "Evaluate all available formulae and casks, whether installed or not, to show " \
// 39:                             "their dependents.",
// 40:                env:         :eval_all,
// 41:                odeprecated: true
// 42:         switch "--include-implicit",
// 43:                description: "Include formulae that have <formula> as an implicit dependency for " \
// 44:                             "downloading and unpacking source files."
// 45:         switch "--include-build",
// 46:                description: "Include formulae that specify <formula> as a `:build` dependency."
// 47:         switch "--include-test",
// 48:                description: "Include formulae that specify <formula> as a `:test` dependency."
// 49:         switch "--include-optional",
// 50:                description: "Include formulae that specify <formula> as an `:optional` dependency."
// 51:         switch "--skip-recommended",
// 52:                description: "Skip all formulae that specify <formula> as a `:recommended` dependency."
// 53:         switch "--formula", "--formulae",
// 54:                description: "Include only formulae."
// 55:         switch "--cask", "--casks",
// 56:                description: "Include only casks."
// 57:
// 58:         conflicts "--formula", "--cask"
// 59:         conflicts "--installed", "--eval-all"
// 60:         conflicts "--missing", "--installed"
// 61:
// 62:         named_args :formula, min: 1
// 63:       end
// 64:
// 65:       sig { override.void }
// 66:       def run
// 67:         Formulary.enable_factory_cache!
// 68:
// 69:         used_formulae_missing = false
// 70:         used_formulae = begin
// 71:           args.named.to_formulae
// 72:         rescue FormulaUnavailableError => e
// 73:           opoo e
// 74:           used_formulae_missing = true
// 75:           # If the formula doesn't exist: fake the needed formula object name.
// 76:           args.named.map { |name| UnavailableFormula.new name:, full_name: name }
// 77:         end
// 78:
// 79:         use_runtime_dependents = args.installed? &&
// 80:                                  !used_formulae_missing &&
// 81:                                  !args.include_implicit? &&
// 82:                                  !args.include_build? &&
// 83:                                  !args.include_test? &&
// 84:                                  !args.include_optional? &&
// 85:                                  !args.skip_recommended?
// 86:
// 87:         uses = intersection_of_dependents(use_runtime_dependents, used_formulae)
// 88:
// 89:         return if uses.empty?
// 90:
// 91:         puts Formatter.columns(uses.map(&:full_name).sort)
// 92:         odie "Missing formulae should not have dependents!" if used_formulae_missing
// 93:       end
// 94:
// 95:       private
// 96:
// 97:       sig {
// 98:         params(use_runtime_dependents: T::Boolean, used_formulae: T::Array[T.any(Formula, UnavailableFormula)])
// 99:           .returns(T::Array[T.any(Formula, CaskDependent)])
// 100:       }
// 101:       def intersection_of_dependents(use_runtime_dependents, used_formulae)
// 102:         recursive = args.recursive?
// 103:         show_formulae_and_casks = !args.formula? && !args.cask?
// 104:         includes, ignores = args_includes_ignores(args)
// 105:
// 106:         deps = []
// 107:         if use_runtime_dependents
// 108:           # We can only get here if `used_formulae_missing` is false, thus there are no UnavailableFormula.
// 109:           used_formulae = T.cast(used_formulae, T::Array[Formula])
// 110:           if show_formulae_and_casks || args.formula?
// 111:             deps += T.must(used_formulae.map(&:runtime_installed_formula_dependents)
// 112:                      .reduce(&:&))
// 113:                      .select(&:any_version_installed?)
// 114:           end
// 115:           if show_formulae_and_casks || args.cask?
// 116:             deps += select_used_dependents(
// 117:               dependents(Cask::Caskroom.casks),
// 118:               used_formulae, recursive, includes, ignores
// 119:             )
// 120:           end
// 121:
// 122:           deps
// 123:         else
// 124:           eval_all = args.eval_all?
// 125:           eval_all ||= Homebrew::EnvConfig.tap_trust_configured?
// 126:
// 127:           if !args.installed? && !eval_all
// 128:             raise UsageError,
// 129:                   "`brew uses` needs `--installed`, `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 130:                   "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 131:           end
// 132:
// 133:           if show_formulae_and_casks || args.formula?
// 134:             deps += args.installed? ? Formula.installed : Formula.all(eval_all:)
// 135:           end
// 136:           if show_formulae_and_casks || args.cask?
// 137:             deps += args.installed? ? Cask::Caskroom.casks : Cask::Cask.all(eval_all:)
// 138:           end
// 139:
// 140:           if args.missing?
// 141:             deps.reject!(&:any_version_installed?)
// 142:             ignores.delete(:satisfied?)
// 143:           end
// 144:
// 145:           select_used_dependents(dependents(deps), used_formulae, recursive, includes, ignores)
// 146:         end
// 147:       end
// 148:
// 149:       sig {
// 150:         params(
// 151:           dependents:    T::Array[T.any(Formula, CaskDependent)],
// 152:           used_formulae: T::Array[T.any(Formula, UnavailableFormula)],
// 153:           recursive:     T::Boolean,
// 154:           includes:      T::Array[Symbol],
// 155:           ignores:       T::Array[Symbol],
// 156:         ).returns(T::Array[T.any(Formula, CaskDependent)])
// 157:       }
// 158:       def select_used_dependents(dependents, used_formulae, recursive, includes, ignores)
// 159:         dependents.select do |d|
// 160:           deps = if recursive
// 161:             recursive_dep_includes(d, includes, ignores)
// 162:           else
// 163:             select_includes(d.deps, ignores, includes)
// 164:           end
// 165:
// 166:           used_formulae.all? do |ff|
// 167:             deps.any? do |dep|
// 168:               match = case dep
// 169:               when Dependency
// 170:                 dep.to_formula.full_name == ff.full_name if dep.name.include?("/")
// 171:               when Requirement
// 172:                 nil
// 173:               else
// 174:                 T.absurd(dep)
// 175:               end
// 176:               next match unless match.nil?
// 177:
// 178:               dep.name == ff.name
// 179:             end
// 180:           rescue FormulaUnavailableError
// 181:             # Silently ignore this case as we don't care about things used in
// 182:             # taps that aren't currently tapped.
// 183:             next
// 184:           end
// 185:         end
// 186:       end
// 187:     end
// 188:   end
// 189: end
