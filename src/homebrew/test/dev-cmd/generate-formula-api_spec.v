module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/generate-formula-api_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "writes formula executables to generated formula data" do` at line 30.
pub fn ruby_generate_formula_api_spec_l30_d1_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "attaches vulnerabilities from the advisory-database corpus to the public formula JSON" do` at line 43.
pub fn ruby_generate_formula_api_spec_l43_d2_attaches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attaches', ...args)
}

// Ruby it `it "omits the vulnerabilities field and warns when the advisory feed cannot be loaded" do` at line 71.
pub fn ruby_generate_formula_api_spec_l71_d3_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/generate-formula-api"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::GenerateFormulaApi do
// 8:   before do
// 9:     core_tap = instance_double(CoreTap, installed?: true, name: "homebrew/core", formula_names: ["foo"],
// 10:                                         alias_table: {}, formula_renames: {}, git_head: "formula-head",
// 11:                                         tap_migrations: {})
// 12:     allow(CoreTap).to receive(:instance).and_return(core_tap)
// 13:     allow(Formulary).to receive(:enable_factory_cache!)
// 14:     allow(Formula).to receive(:generating_hash!)
// 15:     allow(Formulary).to receive(:factory).with("foo").and_return(
// 16:       instance_double(Formula, name: "foo", pkg_version: PkgVersion.parse("1.0.0"),
// 17:                                to_hash_with_variations: { "name" => "foo" }),
// 18:     )
// 19:     allow(Homebrew::API).to receive(:download_executables_file_from_github_packages!) do |target|
// 20:       target.write "foo(1.0.0):foo-tool food\n"
// 21:       true
// 22:     end
// 23:     allow(Homebrew::API::Formula::FormulaStructGenerator).to receive(:generate_formula_struct_hash)
// 24:       .and_return(instance_double(Homebrew::API::FormulaStruct, serialize: { "name" => "foo" }))
// 25:     stub_const("OnSystem::VALID_OS_ARCH_TAGS", [Utils::Bottles::Tag.from_symbol(:arm64_sonoma)])
// 26:   end
// 27:
// 28:   it_behaves_like "parseable arguments"
// 29:
// 30:   it "writes formula executables to generated formula data" do
// 31:     allow(Homebrew::Vulns::AdvisoryDatabase).to receive(:load).and_return(nil)
// 32:
// 33:     Dir.mktmpdir do |tmpdir|
// 34:       path = Pathname.new(tmpdir)
// 35:       path.cd { described_class.new([]).run }
// 36:
// 37:       data = JSON.parse((path/"_data/formula/foo.json").read)
// 38:       expect(data["executables"]).to eq(["foo-tool", "food"])
// 39:       expect(data).not_to have_key("vulnerabilities")
// 40:     end
// 41:   end
// 42:
// 43:   it "attaches vulnerabilities from the advisory-database corpus to the public formula JSON" do
// 44:     advisories = Homebrew::Vulns::AdvisoryDatabase.new({
// 45:       "meta"       => {},
// 46:       "advisories" => {
// 47:         "foo" => [{
// 48:           "id"       => "BREW-foo-CVE-2024-1234",
// 49:           "upstream" => ["CVE-2024-1234"],
// 50:           "affected" => [{
// 51:             "package"            => { "ecosystem" => "Homebrew", "name" => "foo" },
// 52:             "ranges"             => [{ "type" => "ECOSYSTEM", "events" => [{ "introduced" => "0" }] }],
// 53:             "ecosystem_specific" => { "fix" => nil },
// 54:           }],
// 55:         }],
// 56:       },
// 57:     })
// 58:     allow(Homebrew::Vulns::AdvisoryDatabase).to receive(:load).and_return(advisories)
// 59:
// 60:     Dir.mktmpdir do |tmpdir|
// 61:       path = Pathname.new(tmpdir)
// 62:       path.cd { described_class.new([]).run }
// 63:
// 64:       vulns = JSON.parse((path/"_data/formula/foo.json").read)["vulnerabilities"]
// 65:       expect(vulns["open"].map { |e| e["id"] }).to eq ["BREW-foo-CVE-2024-1234"]
// 66:       expect(vulns["patched"]).to eq []
// 67:       expect(vulns["fixed_count"]).to eq 0
// 68:     end
// 69:   end
// 70:
// 71:   it "omits the vulnerabilities field and warns when the advisory feed cannot be loaded" do
// 72:     allow(Homebrew::Vulns::AdvisoryDatabase).to receive(:load)
// 73:       .and_raise(Homebrew::Vulns::CachedFeed::Error, "boom")
// 74:
// 75:     Dir.mktmpdir do |tmpdir|
// 76:       path = Pathname.new(tmpdir)
// 77:       expect { path.cd { described_class.new([]).run } }
// 78:         .to output(/Skipping vulnerabilities field: boom/).to_stderr
// 79:       expect(JSON.parse((path/"_data/formula/foo.json").read)).not_to have_key("vulnerabilities")
// 80:     end
// 81:   end
// 82: end
