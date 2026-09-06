module formula

import ruby
import homebrew
import homebrew.api
import homebrew.utils

// Translated from Homebrew/brew `api/formula/formula_struct_generator.rb`.
pub const formula_struct_generator_supported_requirements = ['arch', 'linux', 'macos', 'maximum_macos',
	'xcode']

pub struct FormulaStructGeneratorOptions {
pub:
	bottle_tag          string
	paths               api.ApiStructPaths
	no_autobump_reasons []string
}

pub struct FormulaDependenciesResult {
pub:
	dependencies    []ruby.Value
	uses_from_macos []api.ApiStructArgPair
}

fn formula_generator_macos_symbol(version string) ?string {
	for symbol, value in homebrew.macos_symbol_versions() {
		if value == version {
			return symbol
		}
	}
	return none
}
