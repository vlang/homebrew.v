module tapioca

import ruby

// Translated from Homebrew/brew `test/sorbet/tapioca/config_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:config) { YAML.load_file(File.join(__dir__, "../../../sorbet/tapioca/config.yml")) }` at line 8.
pub fn ruby_config_spec_l8_d1_config(args ...ruby.Value) ruby.Value {
	contents := if args.len > 0 { args[0].as_string() } else { '' }
	exclusions := tapioca_config_exclusions(contents)
	return ruby.map_value({
		'gem': ruby.map_value({
			'exclude': ruby.string_array_value(exclusions)
		})
	})
}

// Ruby it `it "only excludes dependencies" do` at line 10.
pub fn ruby_config_spec_l10_d2_only(args ...ruby.Value) ruby.Value {
	exclusions := if args.len > 0 {
		args[0].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	dependencies := if args.len > 1 {
		args[1].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return ruby.bool_value(tapioca_only_excludes_dependencies(exclusions, dependencies))
}

pub fn tapioca_config_exclusions(contents string) []string {
	mut exclusions := []string{}
	mut in_exclude := false
	for raw_line in contents.split_into_lines() {
		line := raw_line.trim_space()
		if line == 'exclude:' {
			in_exclude = true
			continue
		}
		if in_exclude && raw_line.len > 0 && raw_line[0] != ` ` && raw_line[0] != `\t` {
			break
		}
		if in_exclude && line.starts_with('- ') {
			exclusions << line[2..].trim_space()
		}
	}
	return exclusions
}

pub fn tapioca_only_excludes_dependencies(exclusions []string, dependencies []string) bool {
	return exclusions.all(it in dependencies)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundler"
// 5: require "yaml"
// 6:
// 7: RSpec.describe "Tapioca Config", type: :system do
// 8:   let(:config) { YAML.load_file(File.join(__dir__, "../../../sorbet/tapioca/config.yml")) }
// 9:
// 10:   it "only excludes dependencies" do
// 11:     exclusions = config.dig("gem", "exclude")
// 12:     dependencies = Bundler::Definition.build(
// 13:       HOMEBREW_LIBRARY_PATH/"Gemfile",
// 14:       HOMEBREW_LIBRARY_PATH/"Gemfile.lock",
// 15:       false,
// 16:     ).resolve.names
// 17:     expect(exclusions - dependencies).to be_empty
// 18:   end
// 19: end
