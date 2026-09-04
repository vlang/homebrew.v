module cmd

// Translated from Homebrew/brew `cmd/--cellar.rb`.

// cellar_output renders the command's stdout after named formulae have been
// resolved to their rack paths. An empty rack list selects HOMEBREW_CELLAR.
pub fn cellar_output(cellar string, formula_racks []string) string {
	lines := if formula_racks.len == 0 { [cellar] } else { formula_racks }
	return '${lines.join('\n')}\n'
}
