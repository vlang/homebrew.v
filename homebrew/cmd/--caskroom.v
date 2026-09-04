module cmd

// Translated from Homebrew/brew `cmd/--caskroom.rb`.
pub fn caskroom_output(caskroom string, tokens []string) string {
	lines := if tokens.len == 0 { [caskroom] } else { tokens.map('${caskroom}/${it}') }
	return '${lines.join('\n')}\n'
}
