module cmd

// Translated from Homebrew/brew `cmd/formulae.rb`.
pub struct FormulaListing {
pub:
	full_name string
	name      string
}

pub fn formula_lines(formulae []FormulaListing) []string {
	mut lines := []string{cap: formulae.len * 2}
	for formula in formulae {
		lines << formula.full_name
		lines << formula.name
	}
	return sorted_distinct_strings(lines)
}
