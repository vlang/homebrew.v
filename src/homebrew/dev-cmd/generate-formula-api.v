module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/generate-formula-api.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 35.
pub fn ruby_generate_formula_api_l35_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `load_advisory_database` at line 115.
pub fn ruby_generate_formula_api_l115_d2_load_advisory_database(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('load_advisory_database', ...args)
}

// Ruby method `html_template(title)` at line 123.
pub fn ruby_generate_formula_api_l123_d3_html_template(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('html_template', ...args)
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
// 9: require "vulns/advisory_database"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class GenerateFormulaApi < AbstractCommand
// 14:       FORMULA_JSON_TEMPLATE = <<~EOS
// 15:         ---
// 16:         layout: formula_json
// 17:         ---
// 18:         {{ content }}
// 19:       EOS
// 20:
// 21:       cmd_args do
// 22:         description <<~EOS
// 23:           Generate `homebrew/core` API data files for <#{HOMEBREW_API_WWW}>.
// 24:           The generated files are written to the current directory.
// 25:         EOS
// 26:         switch "-n", "--dry-run",
// 27:                description: "Generate API data without writing it to files."
// 28:
// 29:         named_args :none
// 30:
// 31:         hide_from_man_page!
// 32:       end
// 33:
// 34:       sig { override.void }
// 35:       def run
// 36:         tap = CoreTap.instance
// 37:         raise TapUnavailableError, tap.name unless tap.installed?
// 38:
// 39:         unless args.dry_run?
// 40:           directories = ["_data/formula", "api/formula", "formula", "api/internal"]
// 41:           FileUtils.rm_rf directories + ["_data/formula_canonical.json"]
// 42:           FileUtils.mkdir_p directories
// 43:         end
// 44:
// 45:         executables_path = Pathname("api/internal/executables.txt")
// 46:         # Use the existing executables database as the API generation source.
// 47:         # It is generated from GitHub Packages metadata, not generated API JSON.
// 48:         if !args.dry_run? &&
// 49:            !Homebrew::API.download_executables_file_from_github_packages!(executables_path)
// 50:           odie "Failed to download #{executables_path}"
// 51:         end
// 52:         executables = ExecutablesDB.new(executables_path.to_s).to_hash
// 53:         advisories = load_advisory_database
// 54:
// 55:         Homebrew.with_no_api_env do
// 56:           tap_migrations_json = JSON.dump(tap.tap_migrations)
// 57:           File.write("api/formula_tap_migrations.json", tap_migrations_json) unless args.dry_run?
// 58:
// 59:           Formulary.enable_factory_cache!
// 60:           Formula.generating_hash!
// 61:
// 62:           all_formulae = {}
// 63:           latest_macos = MacOSVersion.new((HOMEBREW_MACOS_NEWEST_UNSUPPORTED.to_i - 1).to_s).to_sym
// 64:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 65:             tap.formula_names.each do |name|
// 66:               formula = Formulary.factory(name)
// 67:               name = formula.name
// 68:               all_formulae[name] = formula.to_hash_with_variations
// 69:               all_formulae[name]["executables"] = executables[name] if executables.key?(name)
// 70:               if (vulns = advisories&.status_for(name, formula.pkg_version))
// 71:                 all_formulae[name]["vulnerabilities"] = vulns
// 72:               end
// 73:               json = JSON.pretty_generate(all_formulae[name])
// 74:               html_template_name = html_template(name)
// 75:
// 76:               unless args.dry_run?
// 77:                 File.write("_data/formula/#{name.tr("+", "_")}.json", "#{json}\n")
// 78:                 File.write("api/formula/#{name}.json", FORMULA_JSON_TEMPLATE)
// 79:                 File.write("formula/#{name}.html", html_template_name)
// 80:               end
// 81:             rescue
// 82:               onoe "Error while generating data for formula '#{name}'."
// 83:               raise
// 84:             end
// 85:           end
// 86:
// 87:           canonical_json = JSON.pretty_generate(tap.formula_renames.merge(tap.alias_table))
// 88:           File.write("_data/formula_canonical.json", "#{canonical_json}\n") unless args.dry_run?
// 89:
// 90:           OnSystem::VALID_OS_ARCH_TAGS.each do |bottle_tag|
// 91:             formulae = all_formulae.to_h do |name, hash|
// 92:               hash = Homebrew::API::Formula::FormulaStructGenerator.generate_formula_struct_hash(hash, bottle_tag:)
// 93:                                                                    .serialize(bottle_tag:)
// 94:               [name, hash]
// 95:             end
// 96:
// 97:             json_contents = {
// 98:               formulae:,
// 99:               aliases:        tap.alias_table,
// 100:               renames:        tap.formula_renames,
// 101:               tap_git_head:   tap.git_head,
// 102:               tap_migrations: tap.tap_migrations,
// 103:             }
// 104:
// 105:             File.write("api/internal/formula.#{bottle_tag}.json", JSON.generate(json_contents)) unless args.dry_run?
// 106:           end
// 107:         end
// 108:       end
// 109:
// 110:       private
// 111:
// 112:       # An advisory-database or network failure must not break the API build;
// 113:       # the `vulnerabilities` field is omitted and the build proceeds.
// 114:       sig { returns(T.nilable(Homebrew::Vulns::AdvisoryDatabase)) }
// 115:       def load_advisory_database
// 116:         Homebrew::Vulns::AdvisoryDatabase.load
// 117:       rescue Homebrew::Vulns::CachedFeed::Error, ErrorDuringExecution => e
// 118:         opoo "Skipping vulnerabilities field: #{e.message.lines.first&.strip}"
// 119:         nil
// 120:       end
// 121:
// 122:       sig { params(title: String).returns(String) }
// 123:       def html_template(title)
// 124:         <<~EOS
// 125:           ---
// 126:           title: '#{title}'
// 127:           layout: formula
// 128:           redirect_from: /formula-linux/#{title}
// 129:           ---
// 130:           {{ content }}
// 131:         EOS
// 132:       end
// 133:     end
// 134:   end
// 135: end
