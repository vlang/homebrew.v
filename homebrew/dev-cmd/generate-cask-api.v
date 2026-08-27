module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/generate-cask-api.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 33.
pub fn ruby_generate_cask_api_l33_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `html_template(title)` at line 97.
pub fn ruby_generate_cask_api_l97_d2_html_template(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('html_template', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cask/cask"
// 6: require "fileutils"
// 7: require "formula"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class GenerateCaskApi < AbstractCommand
// 12:       CASK_JSON_TEMPLATE = <<~EOS
// 13:         ---
// 14:         layout: cask_json
// 15:         ---
// 16:         {{ content }}
// 17:       EOS
// 18:
// 19:       cmd_args do
// 20:         description <<~EOS
// 21:           Generate `homebrew/cask` API data files for <#{HOMEBREW_API_WWW}>.
// 22:           The generated files are written to the current directory.
// 23:         EOS
// 24:         switch "-n", "--dry-run",
// 25:                description: "Generate API data without writing it to files."
// 26:
// 27:         named_args :none
// 28:
// 29:         hide_from_man_page!
// 30:       end
// 31:
// 32:       sig { override.void }
// 33:       def run
// 34:         tap = CoreCaskTap.instance
// 35:         raise TapUnavailableError, tap.name unless tap.installed?
// 36:
// 37:         unless args.dry_run?
// 38:           directories = ["_data/cask", "api/cask", "api/cask-source", "cask", "api/internal"].freeze
// 39:           FileUtils.rm_rf directories
// 40:           FileUtils.mkdir_p directories
// 41:         end
// 42:
// 43:         Homebrew.with_no_api_env do
// 44:           tap_migrations_json = JSON.dump(tap.tap_migrations)
// 45:           File.write("api/cask_tap_migrations.json", tap_migrations_json) unless args.dry_run?
// 46:
// 47:           Cask::Cask.generating_hash!
// 48:
// 49:           all_casks = {}
// 50:           latest_macos = MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 51:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 52:             tap.cask_files.each do |path|
// 53:               cask = Cask::CaskLoader.load(path)
// 54:               name = cask.token
// 55:               all_casks[name] = cask.to_hash_with_variations
// 56:               json = JSON.pretty_generate(all_casks[name])
// 57:               cask_source = path.read
// 58:               html_template_name = html_template(name)
// 59:
// 60:               unless args.dry_run?
// 61:                 File.write("_data/cask/#{name.tr("+", "_")}.json", "#{json}\n")
// 62:                 File.write("api/cask/#{name}.json", CASK_JSON_TEMPLATE)
// 63:                 File.write("api/cask-source/#{name}.rb", cask_source)
// 64:                 File.write("cask/#{name}.html", html_template_name)
// 65:               end
// 66:             rescue
// 67:               onoe "Error while generating data for cask '#{path.stem}'."
// 68:               raise
// 69:             end
// 70:           end
// 71:
// 72:           canonical_json = JSON.pretty_generate(tap.cask_renames)
// 73:           File.write("_data/cask_canonical.json", "#{canonical_json}\n") unless args.dry_run?
// 74:
// 75:           OnSystem::VALID_OS_ARCH_TAGS.each do |bottle_tag|
// 76:             casks = all_casks.to_h do |token, hash|
// 77:               hash = Homebrew::API::Cask::CaskStructGenerator.generate_cask_struct_hash(hash, bottle_tag:)
// 78:                                                              .serialize
// 79:               [token, hash]
// 80:             end
// 81:
// 82:             json_contents = {
// 83:               casks:,
// 84:               renames:        tap.cask_renames,
// 85:               tap_git_head:   tap.git_head,
// 86:               tap_migrations: tap.tap_migrations,
// 87:             }
// 88:
// 89:             File.write("api/internal/cask.#{bottle_tag}.json", JSON.generate(json_contents)) unless args.dry_run?
// 90:           end
// 91:         end
// 92:       end
// 93:
// 94:       private
// 95:
// 96:       sig { params(title: String).returns(String) }
// 97:       def html_template(title)
// 98:         <<~EOS
// 99:           ---
// 100:           title: '#{title}'
// 101:           layout: cask
// 102:           ---
// 103:           {{ content }}
// 104:         EOS
// 105:       end
// 106:     end
// 107:   end
// 108: end
