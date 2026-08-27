module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/generate-internal-api.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 28.
pub fn ruby_generate_internal_api_l28_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "api"
// 6: require "executables_db"
// 7: require "fileutils"
// 8: require "formula"
// 9: require "cask/cask"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class GenerateInternalApi < AbstractCommand
// 14:       cmd_args do
// 15:         description <<~EOS
// 16:           Generate internal API data files for <#{HOMEBREW_API_WWW}>.
// 17:           The generated files are written to the current directory.
// 18:         EOS
// 19:         switch "-n", "--dry-run",
// 20:                description: "Generate internal API data without writing it to files."
// 21:
// 22:         named_args :none
// 23:
// 24:         hide_from_man_page!
// 25:       end
// 26:
// 27:       sig { override.void }
// 28:       def run
// 29:         core_tap = CoreTap.instance
// 30:         cask_tap = CoreCaskTap.instance
// 31:         raise TapUnavailableError, core_tap.name unless core_tap.installed?
// 32:         raise TapUnavailableError, cask_tap.name unless cask_tap.installed?
// 33:
// 34:         unless args.dry_run?
// 35:           FileUtils.rm_rf "api/internal"
// 36:           FileUtils.mkdir_p "api/internal"
// 37:         end
// 38:
// 39:         executables_path = Pathname("api/internal/executables.txt")
// 40:         # Use the existing executables database as the API generation source.
// 41:         # It is generated from GitHub Packages metadata, not generated API JSON.
// 42:         if !args.dry_run? &&
// 43:            !Homebrew::API.download_executables_file_from_github_packages!(executables_path)
// 44:           odie "Failed to download #{executables_path}"
// 45:         end
// 46:         executables = ExecutablesDB.new(executables_path.to_s).to_hash
// 47:
// 48:         Homebrew.with_no_api_env do
// 49:           Formulary.enable_factory_cache!
// 50:           Formula.generating_hash!
// 51:           Cask::Cask.generating_hash!
// 52:
// 53:           all_formulae = {}
// 54:           all_casks = {}
// 55:           latest_macos = MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 56:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 57:             core_tap.formula_names.each do |name|
// 58:               formula = Formulary.factory(name)
// 59:               name = formula.name
// 60:               all_formulae[name] = formula.to_hash_with_variations
// 61:               all_formulae[name]["executables"] = executables[name] if executables.key?(name)
// 62:             rescue
// 63:               onoe "Error while generating data for formula '#{name}'."
// 64:               raise
// 65:             end
// 66:
// 67:             cask_tap.cask_files.each do |path|
// 68:               cask = Cask::CaskLoader.load(path)
// 69:               name = cask.token
// 70:               all_casks[name] = cask.to_hash_with_variations
// 71:             rescue
// 72:               onoe "Error while generating data for cask '#{path.stem}'."
// 73:               raise
// 74:             end
// 75:           end
// 76:
// 77:           OnSystem::VALID_OS_ARCH_TAGS.each do |bottle_tag|
// 78:             formulae = all_formulae.to_h do |name, hash|
// 79:               hash = Homebrew::API::Formula::FormulaStructGenerator.generate_formula_struct_hash(hash, bottle_tag:)
// 80:                                                                    .serialize(bottle_tag:)
// 81:               [name, hash]
// 82:             end
// 83:
// 84:             casks = all_casks.to_h do |token, hash|
// 85:               hash = Homebrew::API::Cask::CaskStructGenerator.generate_cask_struct_hash(hash, bottle_tag:)
// 86:                                                              .serialize
// 87:               [token, hash]
// 88:             end
// 89:
// 90:             json_contents = {
// 91:               metadata:               {
// 92:                 homebrew_version: HOMEBREW_VERSION,
// 93:                 bottle_tag:       bottle_tag.to_s,
// 94:                 generated_at:     Time.now.to_i,
// 95:               },
// 96:               formulae:,
// 97:               casks:,
// 98:               formula_aliases:        core_tap.alias_table,
// 99:               formula_renames:        core_tap.formula_renames,
// 100:               cask_renames:           cask_tap.cask_renames,
// 101:               formula_tap_git_head:   core_tap.git_head,
// 102:               cask_tap_git_head:      cask_tap.git_head,
// 103:               formula_tap_migrations: core_tap.tap_migrations,
// 104:               cask_tap_migrations:    cask_tap.tap_migrations,
// 105:             }
// 106:
// 107:             File.write("api/internal/packages.#{bottle_tag}.json", JSON.generate(json_contents)) unless args.dry_run?
// 108:           end
// 109:         end
// 110:       end
// 111:     end
// 112:   end
// 113: end
