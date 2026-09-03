module test

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/formula_creator_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "parses` at line 56.
pub fn ruby_formula_creator_spec_l56_d1_parses(args ...brew_runtime.Value) brew_runtime.Value {
	tests := [
		homebrew.FormulaCreatorOptions{
			url: 'http://digit-labs.org/files/tools/synscan/releases/synscan-5.02.tar.gz'
		},
		homebrew.FormulaCreatorOptions{
			url: 'http://www.codesrc.com/gitweb/index.cgi?p=libzipper.git;a=summary'
		},
		homebrew.FormulaCreatorOptions{
			url: 'https://github.com/Homebrew/brew.git'
			fetch: true
		},
		homebrew.FormulaCreatorOptions{
			url: 'https://github.com/Homebrew/brew/archive/4.5.7.tar.gz'
			fetch: true
		},
		homebrew.FormulaCreatorOptions{
			url: 'https://github.com/stella-emu/stella/releases/download/6.7/stella-6.7-src.tar.xz'
			fetch: true
		},
		homebrew.FormulaCreatorOptions{
			url: 'https://github.com/buildpacks/pack'
			fetch: true
			latest_release: 'v0.37.0'
		},
		homebrew.FormulaCreatorOptions{
			url: 'https://github.com/RooVetGit/Roo-Code'
			name: 'roo'
		},
	]
	expected_names := ['synscan', 'libzipper', 'brew', 'brew', 'stella', 'pack', 'roo']
	expected_versions := ['5.02', '', '', '4.5.7', '6.7', 'v0.37.0', '']
	for index, options in tests {
		creator := homebrew.new_formula_creator(options)
		if creator.name != expected_names[index] || creator.version != expected_versions[index] {
			return brew_runtime.bool_value(false)
		}
	}
	latest := homebrew.new_formula_creator(tests[5])
	return brew_runtime.bool_value(tests.len == 7 && homebrew.new_formula_creator(tests[2]).head
		&& latest.url == 'https://github.com/buildpacks/pack/archive/refs/tags/v0.37.0.tar.gz')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula_creator"
// 5:
// 6: RSpec.describe Homebrew::FormulaCreator do
// 7:   describe ".new" do
// 8:     tests = {
// 9:       "generic tarball URL":             {
// 10:         url:              "http://digit-labs.org/files/tools/synscan/releases/synscan-5.02.tar.gz",
// 11:         expected_name:    "synscan",
// 12:         expected_version: "5.02",
// 13:       },
// 14:       "gitweb URL":                      {
// 15:         url:           "http://www.codesrc.com/gitweb/index.cgi?p=libzipper.git;a=summary",
// 16:         expected_name: "libzipper",
// 17:       },
// 18:       "GitHub repository URL with .git": {
// 19:         url:                    "https://github.com/Homebrew/brew.git",
// 20:         fetch:                  true,
// 21:         github_user_repository: ["Homebrew", "brew"],
// 22:         expected_name:          "brew",
// 23:         expected_head:          true,
// 24:       },
// 25:       "GitHub archive URL":              {
// 26:         url:                    "https://github.com/Homebrew/brew/archive/4.5.7.tar.gz",
// 27:         fetch:                  true,
// 28:         github_user_repository: ["Homebrew", "brew"],
// 29:         expected_name:          "brew",
// 30:         expected_version:       "4.5.7",
// 31:       },
// 32:       "GitHub releases URL":             {
// 33:         url:                    "https://github.com/stella-emu/stella/releases/download/6.7/stella-6.7-src.tar.xz",
// 34:         fetch:                  true,
// 35:         github_user_repository: ["stella-emu", "stella"],
// 36:         expected_name:          "stella",
// 37:         expected_version:       "6.7",
// 38:       },
// 39:       "GitHub latest release":           {
// 40:         url:                    "https://github.com/buildpacks/pack",
// 41:         fetch:                  true,
// 42:         github_user_repository: ["buildpacks", "pack"],
// 43:         latest_release:         { "tag_name" => "v0.37.0" },
// 44:         expected_name:          "pack",
// 45:         expected_url:           "https://github.com/buildpacks/pack/archive/refs/tags/v0.37.0.tar.gz",
// 46:         expected_version:       "v0.37.0",
// 47:       },
// 48:       "GitHub URL with name override":   {
// 49:         url:           "https://github.com/RooVetGit/Roo-Code",
// 50:         name:          "roo",
// 51:         expected_name: "roo",
// 52:       },
// 53:     }
// 54:
// 55:     test_each(tests) do |(description, test)|
// 56:       it "parses #{description}" do
// 57:         fetch = test.fetch(:fetch, false)
// 58:         if fetch
// 59:           github_user_repository = test.fetch(:github_user_repository)
// 60:           allow(GitHub).to receive(:repository).with(*github_user_repository)
// 61:           if (latest_release = test[:latest_release])
// 62:             expect(GitHub).to receive(:get_latest_release).with(*github_user_repository).and_return(latest_release)
// 63:           end
// 64:         end
// 65:
// 66:         formula_creator = described_class.new(url: test.fetch(:url), name: test[:name], fetch:)
// 67:
// 68:         expect(formula_creator.name).to eq(test.fetch(:expected_name))
// 69:         if (expected_version = test[:expected_version])
// 70:           expect(formula_creator.version).to eq(expected_version)
// 71:         else
// 72:           expect(formula_creator.version).to be_null
// 73:         end
// 74:         if (expected_url = test[:expected_url])
// 75:           expect(formula_creator.url).to eq(expected_url)
// 76:         end
// 77:         expect(formula_creator.head).to eq(test.fetch(:expected_head, false))
// 78:       end
// 79:     end
// 80:   end
// 81: end
