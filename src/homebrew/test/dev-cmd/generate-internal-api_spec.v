module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/generate-internal-api_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "writes metadata and formula executables to each generated packages file" do` at line 10.
pub fn ruby_generate_internal_api_spec_l10_d1_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/generate-internal-api"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::GenerateInternalApi do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "writes metadata and formula executables to each generated packages file" do
// 11:     core_tap = instance_double(CoreTap, installed?: true, name: "homebrew/core", formula_names: ["foo"],
// 12:                                         alias_table: {}, formula_renames: {}, git_head: "formula-head",
// 13:                                         tap_migrations: {})
// 14:     cask_tap = instance_double(CoreCaskTap, installed?: true, name: "homebrew/cask", cask_files: [Pathname("c.rb")],
// 15:                                             cask_renames: {}, git_head: "cask-head", tap_migrations: {})
// 16:     bottle_tag = Utils::Bottles::Tag.from_symbol(:arm64_sonoma)
// 17:
// 18:     allow(CoreTap).to receive(:instance).and_return(core_tap)
// 19:     allow(CoreCaskTap).to receive(:instance).and_return(cask_tap)
// 20:     allow(Formulary).to receive(:enable_factory_cache!)
// 21:     allow(Formula).to receive(:generating_hash!)
// 22:     allow(Cask::Cask).to receive(:generating_hash!)
// 23:     allow(Formulary).to receive(:factory).with("foo").and_return(
// 24:       instance_double(Formula, name: "foo", to_hash_with_variations: { "name" => "foo" }),
// 25:     )
// 26:     allow(Cask::CaskLoader).to receive(:load).with(Pathname("c.rb")).and_return(
// 27:       instance_double(Cask::Cask, token: "c", to_hash_with_variations: { "token" => "c" }),
// 28:     )
// 29:     allow(Homebrew::API).to receive(:download_executables_file_from_github_packages!) do |target|
// 30:       target.write "foo(1.0.0):foo-tool food\n"
// 31:       true
// 32:     end
// 33:     allow(Homebrew::API::Formula::FormulaStructGenerator).to receive(:generate_formula_struct_hash)
// 34:       .with({ "name" => "foo", "executables" => ["foo-tool", "food"] }, bottle_tag:)
// 35:       .and_return(
// 36:         instance_double(
// 37:           Homebrew::API::FormulaStruct,
// 38:           serialize: { "name" => "foo", "executables" => ["foo-tool", "food"] },
// 39:         ),
// 40:       )
// 41:     allow(Homebrew::API::Cask::CaskStructGenerator).to receive(:generate_cask_struct_hash)
// 42:       .with({ "token" => "c" }, bottle_tag:)
// 43:       .and_return(instance_double(Homebrew::API::CaskStruct, serialize: { "token" => "c" }))
// 44:     allow(Time).to receive(:now).and_return(Time.at(1_714_056_000))
// 45:     stub_const("HOMEBREW_VERSION", "4.2.18")
// 46:     stub_const("OnSystem::VALID_OS_ARCH_TAGS", [bottle_tag])
// 47:
// 48:     mktmpdir do |path|
// 49:       path.cd { described_class.new([]).run }
// 50:
// 51:       json = JSON.parse((path/"api/internal/packages.arm64_sonoma.json").read)
// 52:       expect(json["metadata"]).to eq({
// 53:         "homebrew_version" => "4.2.18",
// 54:         "bottle_tag"       => "arm64_sonoma",
// 55:         "generated_at"     => 1_714_056_000,
// 56:       })
// 57:       expect(json.dig("formulae", "foo", "executables")).to eq(["foo-tool", "food"])
// 58:     end
// 59:   end
// 60: end
