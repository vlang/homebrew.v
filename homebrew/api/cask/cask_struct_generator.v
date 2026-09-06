module cask

import ruby
import homebrew
import homebrew.api

// Translated from Homebrew/brew `api/cask/cask_struct_generator.rb`.

pub struct CaskStructGeneratorOptions {
pub:
	bottle_tag   string
	paths        api.ApiStructPaths
	ignore_types bool
}

struct CaskGeneratorLanguageStruct {
	variation map[string]ruby.Value
	cask      api.CaskStruct
}

fn cask_generator_macos_symbol(version string) ?string {
	normalized := version.trim_space().trim_string_left(':')
	versions := homebrew.macos_symbol_versions()
	if normalized in versions {
		return normalized
	}
	for symbol, number in versions {
		if number == normalized {
			return symbol
		}
	}
	return none
}
