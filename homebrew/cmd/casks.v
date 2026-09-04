module cmd

// Translated from Homebrew/brew `cmd/casks.rb`.
pub struct CaskListing {
pub:
	full_name string
	token     string
}

fn sorted_distinct_strings(values []string) []string {
	mut sorted := values.clone()
	sorted.sort()
	mut unique := []string{cap: sorted.len}
	for value in sorted {
		if unique.len == 0 || unique.last() != value {
			unique << value
		}
	}
	return unique
}

pub fn cask_lines(casks []CaskListing) []string {
	mut lines := []string{cap: casks.len * 2}
	for cask in casks {
		lines << cask.full_name
		lines << cask.token
	}
	return sorted_distinct_strings(lines)
}
